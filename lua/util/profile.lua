-- Runtime profiler for this config: module load, buffer opens, LSP lifecycle,
-- server-side indexing and diagnostics latency, plus a UI-stall detector.
--
-- Off by default. Turn on before the config loads:
--
--   NVIM_PROFILE=1 nvim note.md          -- env
--   nvim --cmd 'lua vim.g.nvim_profile = true' note.md
--
-- Then:  :Profile          report in a scratch buffer
--        :ProfileDump      write JSON to stdpath('state')/profile/
--        :ProfileReset     clear collected samples
--
-- Everything hangs off public APIs (`vim.lsp.start`, LspAttach/LspRequest/
-- LspNotify/LspProgress autocmds, a per-client publishDiagnostics handler), so
-- nothing here depends on Neovim internals beyond 0.11's LSP event surface.

local M = {}

local uv = vim.uv or vim.loop
local T0 = uv.hrtime()

local function now()
  return uv.hrtime()
end

local function ms(ns)
  return ns / 1e6
end

local function elapsed()
  return ms(now() - T0)
end

-- ────────────────────────────── collected state ──────────────────────────────

local function new_state()
  return {
    modules = {}, -- { name, total_ms, self_ms, at_ms }
    bufs = {}, -- { path, ft, bytes, lines, read_ms, ft_ms, draw_ms, at_ms }
    clients = {}, -- [client_id] = { name, root, start_ms, ready_ms, attaches, stopped_ms }
    requests = {}, -- ["client/method"] = { n, err, samples = {ms...} }
    progress = {}, -- { client, title, message, ms, at_ms }
    diags = {}, -- ["client"] = { n, count_max, samples = {ms...} }
    stalls = {}, -- { at_ms, ms, mode, buf, ft }
    shutdown = {}, -- { at_ms, ms, clients }
    lua_samples = {}, -- [folded stack] = sample count
  }
end

M.state = new_state()
M.enabled = false
M.opts = {
  stall_ms = 200, -- report main-loop blocks longer than this
  stall_tick = 100, -- detector timer period
  max_samples = 5000, -- per bucket, keeps memory bounded
  dump_on_exit = false,
  sample = false, -- LuaJIT sampling profiler: attributes stalls to Lua frames
  sample_ms = 5, -- sampling interval
  sample_depth = 6, -- stack frames per sample
}

local function bucket(tbl, key)
  local b = tbl[key]
  if not b then
    b = { n = 0, err = 0, samples = {} }
    tbl[key] = b
  end
  return b
end

local function sample(b, value)
  b.n = b.n + 1
  if #b.samples < M.opts.max_samples then
    b.samples[#b.samples + 1] = value
  end
end

-- ────────────────────────────── module load timing ──────────────────────────────

-- Swapping the global `require` is the only way to time module loads that
-- happen inside plugins we don't control.
-- selene: allow(global_usage)
local orig_require = _G.require
local req_stack = {}

local function timed_require(name)
  if package.loaded[name] ~= nil then
    return orig_require(name)
  end
  local rec = { start = now(), child = 0 }
  req_stack[#req_stack + 1] = rec
  local ok, res = pcall(orig_require, name)
  req_stack[#req_stack] = nil
  local total = now() - rec.start
  local parent = req_stack[#req_stack]
  if parent then
    parent.child = parent.child + total
  end
  M.state.modules[#M.state.modules + 1] = {
    name = name,
    total_ms = ms(total),
    self_ms = ms(total - rec.child),
    at_ms = elapsed(),
    ok = ok,
  }
  if not ok then
    error(res, 0)
  end
  return res
end

-- ────────────────────────────── buffer open timing ──────────────────────────────

local pending_buf = {}

local function buf_hook(group)
  local au = function(ev, cb)
    vim.api.nvim_create_autocmd(ev, { group = group, callback = cb })
  end

  au("BufReadPre", function(ev)
    pending_buf[ev.buf] = { t0 = now(), at_ms = elapsed(), path = ev.file }
  end)

  au("BufReadPost", function(ev)
    local p = pending_buf[ev.buf]
    if not p then
      return
    end
    p.read_ms = ms(now() - p.t0)
    p.lines = vim.api.nvim_buf_line_count(ev.buf)
    local ok, st = pcall(uv.fs_stat, ev.file)
    p.bytes = (ok and st and st.size) or 0
  end)

  au("FileType", function(ev)
    local p = pending_buf[ev.buf]
    if not p or p.ft_ms then
      return
    end
    p.ft = vim.bo[ev.buf].filetype
    p.ft_ms = ms(now() - p.t0)
  end)

  au("BufWinEnter", function(ev)
    local p = pending_buf[ev.buf]
    if not p or p.done then
      return
    end
    p.done = true
    -- One redraw cycle later: everything queued by FileType (treesitter,
    -- render-markdown, LSP attach) has had its turn on the main loop.
    vim.schedule(function()
      p.draw_ms = ms(now() - p.t0)
      p.ft = p.ft or vim.bo[ev.buf].filetype
      M.state.bufs[#M.state.bufs + 1] = {
        path = p.path,
        ft = p.ft,
        bytes = p.bytes,
        lines = p.lines,
        read_ms = p.read_ms,
        ft_ms = p.ft_ms,
        draw_ms = p.draw_ms,
        at_ms = p.at_ms,
      }
      pending_buf[ev.buf] = nil
    end)
  end)

  au("BufDelete", function(ev)
    pending_buf[ev.buf] = nil
  end)
end

-- ────────────────────────────── LSP lifecycle ──────────────────────────────

local orig_lsp_start = vim.lsp.start
local last_change = {} -- ["client_id:bufnr"] = ns of last didOpen/didChange

local function client_rec(id)
  local c = M.state.clients[id]
  if not c then
    local client = vim.lsp.get_client_by_id(id)
    c = {
      id = id,
      name = client and client.name or ("client_" .. id),
      root = client and client.root_dir or nil,
      start_ms = elapsed(),
      attaches = {},
    }
    M.state.clients[id] = c
  end
  return c
end

local function install_diagnostic_timer(client)
  if not client or client._profile_diag then
    return
  end
  client._profile_diag = true
  -- Respect a handler the client config already installed; otherwise fall back
  -- to the same default `vim.lsp.handlers` would have used.
  local delegate = client.handlers["textDocument/publishDiagnostics"]
    or vim.lsp.handlers["textDocument/publishDiagnostics"]
    or vim.lsp.diagnostic.on_publish_diagnostics
  client.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    local key = ctx.client_id .. ":" .. (result and result.uri or "?")
    local t0 = last_change[key]
    if t0 then
      local b = bucket(M.state.diags, client.name)
      sample(b, ms(now() - t0))
      b.count_max = math.max(b.count_max or 0, result and #(result.diagnostics or {}) or 0)
      last_change[key] = nil
    end
    return delegate(err, result, ctx, config)
  end
end

local function lsp_hook(group)
  vim.lsp.start = function(config, opts)
    local t0 = now()
    local id = orig_lsp_start(config, opts)
    if id then
      local c = M.state.clients[id]
      if c then
        c.reused = (c.reused or 0) + 1
      else
        c = client_rec(id)
        c.start_ms = elapsed()
        c.spawn_ms = ms(now() - t0) -- synchronous part of vim.lsp.start()
        c.cmd = type(config) == "table" and config.cmd or nil
      end
    end
    return id
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
      local c = client_rec(ev.data.client_id)
      c.ready_ms = c.ready_ms or (elapsed() - c.start_ms)
      c.attaches[#c.attaches + 1] = {
        buf = vim.api.nvim_buf_get_name(ev.buf),
        at_ms = elapsed(),
        since_start_ms = elapsed() - c.start_ms,
      }
      install_diagnostic_timer(vim.lsp.get_client_by_id(ev.data.client_id))
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(ev)
      local c = M.state.clients[ev.data.client_id]
      if c then
        c.detaches = (c.detaches or 0) + 1
      end
    end,
  })

  -- Request round-trip: LspRequest fires with type 'pending' then
  -- 'complete'/'cancel' for the same request_id.
  local inflight = {}
  vim.api.nvim_create_autocmd("LspRequest", {
    group = group,
    callback = function(ev)
      local d = ev.data
      local key = d.client_id .. "#" .. d.request_id
      local t = d.request.type
      if t == "pending" then
        inflight[key] = now()
      else
        local t0 = inflight[key]
        inflight[key] = nil
        if not t0 then
          return
        end
        local c = M.state.clients[d.client_id]
        local name = (c and c.name) or ("client_" .. d.client_id)
        local b = bucket(M.state.requests, name .. " " .. d.request.method)
        sample(b, ms(now() - t0))
        if t == "cancel" then
          b.err = b.err + 1
        end
      end
    end,
  })

  -- Outgoing didOpen/didChange stamp the clock that publishDiagnostics stops.
  vim.api.nvim_create_autocmd("LspNotify", {
    group = group,
    callback = function(ev)
      local m = ev.data.method
      if m ~= "textDocument/didOpen" and m ~= "textDocument/didChange" then
        return
      end
      local uri = ev.data.params and ev.data.params.textDocument and ev.data.params.textDocument.uri
      if not uri then
        return
      end
      local key = ev.data.client_id .. ":" .. uri
      if not last_change[key] then -- keep the oldest un-answered edit
        last_change[key] = now()
      end
    end,
  })

  -- $/progress is how servers report indexing / workspace loading.
  local progress = {}
  vim.api.nvim_create_autocmd("LspProgress", {
    group = group,
    callback = function(ev)
      local p = ev.data.params
      local v = p and p.value
      if type(v) ~= "table" then
        return
      end
      local key = ev.data.client_id .. "#" .. tostring(p.token)
      if v.kind == "begin" then
        progress[key] = { t0 = now(), title = v.title, at_ms = elapsed() }
      elseif v.kind == "end" then
        local rec = progress[key]
        progress[key] = nil
        if not rec then
          return
        end
        local c = M.state.clients[ev.data.client_id]
        M.state.progress[#M.state.progress + 1] = {
          client = (c and c.name) or ("client_" .. ev.data.client_id),
          title = rec.title or "?",
          message = v.message,
          ms = ms(now() - rec.t0),
          at_ms = rec.at_ms,
        }
      end
    end,
  })
end

-- ────────────────────────────── main-loop stall detector ──────────────────────────────

local stall_timer

local function stall_hook()
  local period = M.opts.stall_tick
  stall_timer = uv.new_timer()
  local last = now()
  stall_timer:start(
    period,
    period,
    vim.schedule_wrap(function()
      local t = now()
      local late = ms(t - last) - period
      last = t
      if late >= M.opts.stall_ms then
        local buf = vim.api.nvim_get_current_buf()
        M.state.stalls[#M.state.stalls + 1] = {
          at_ms = elapsed(),
          ms = late,
          mode = vim.api.nvim_get_mode().mode,
          buf = vim.api.nvim_buf_get_name(buf),
          ft = vim.bo[buf].filetype,
        }
      end
    end)
  )
end

-- ────────────────────────────── Lua sampling profiler ──────────────────────────────
-- The stall detector says *when* the main loop was blocked; this says *where*.
-- LuaJIT interrupts every `sample_ms` and hands us the current stack; folding
-- those into counts gives a flat profile of Lua-side time. It only sees Lua
-- frames — time inside C (regex, RPC decode, syscalls) lands on whichever Lua
-- frame called in.

local jit_profile

local function sampler_start()
  local ok, jp = pcall(require, "jit.profile")
  if not ok then
    vim.notify("jit.profile unavailable — Lua sampling disabled", vim.log.levels.WARN)
    return
  end
  jit_profile = jp
  local depth = M.opts.sample_depth
  jp.start("i" .. M.opts.sample_ms, function(thread, count)
    local ok2, stack = pcall(jp.dumpstack, thread, "F;", depth)
    if ok2 and stack then
      -- Read M.state on every sample so :ProfileReset really starts over
      -- instead of leaving the sampler filling an orphaned table.
      local acc = M.state.lua_samples
      acc[stack] = (acc[stack] or 0) + count
    end
  end)
end

local function sampler_stop()
  if jit_profile then
    pcall(jit_profile.stop)
    jit_profile = nil
  end
end

-- ────────────────────────────── shutdown timing ──────────────────────────────

local function exit_hook(group)
  local t0
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      t0 = now()
      local names = {}
      for _, c in ipairs(vim.lsp.get_clients()) do
        names[#names + 1] = c.name
      end
      M.state.shutdown = { at_ms = elapsed(), clients = names }
    end,
  })
  vim.api.nvim_create_autocmd("VimLeave", {
    group = group,
    callback = function()
      if t0 then
        M.state.shutdown.ms = ms(now() - t0)
      end
      sampler_stop()
      if M.opts.dump_on_exit then
        pcall(M.dump)
      end
    end,
  })
end

-- ────────────────────────────── stats helpers ──────────────────────────────

local function pct(sorted, p)
  if #sorted == 0 then
    return 0
  end
  local i = math.max(1, math.ceil(p * #sorted))
  return sorted[math.min(i, #sorted)]
end

local function stats(samples)
  local s = vim.deepcopy(samples)
  table.sort(s)
  local sum = 0
  for _, v in ipairs(s) do
    sum = sum + v
  end
  return {
    n = #s,
    sum = sum,
    p50 = pct(s, 0.5),
    p90 = pct(s, 0.9),
    max = #s > 0 and s[#s] or 0,
  }
end

-- ────────────────────────────── report ──────────────────────────────

--- Render the collected data as plain text lines.
--- @return string[]
function M.report()
  local out = {}
  local function add(fmt, ...)
    out[#out + 1] = select("#", ...) > 0 and string.format(fmt, ...) or fmt
  end

  add("nvim profile — uptime %.0f ms, pid %d", elapsed(), vim.fn.getpid())
  add("")

  -- modules
  add("MODULE LOAD (self time, top 20)")
  local mods = vim.deepcopy(M.state.modules)
  table.sort(mods, function(a, b)
    return a.self_ms > b.self_ms
  end)
  local mod_total = 0
  for _, m in ipairs(M.state.modules) do
    mod_total = mod_total + m.self_ms
  end
  add("  %8s %8s  %s", "self", "total", "module")
  for i = 1, math.min(20, #mods) do
    local m = mods[i]
    add("  %7.1fm %7.1fm  %s%s", m.self_ms, m.total_ms, m.name, m.ok and "" or "  [ERROR]")
  end
  add("  %7.1fm %7s   (%d modules)", mod_total, "", #mods)
  add("")

  -- buffers
  add("BUFFER OPENS (read -> filetype -> first draw)")
  add("  %8s %8s %8s %8s %7s  %-10s %s", "read", "ftype", "draw", "lines", "KiB", "ft", "file")
  for _, b in ipairs(M.state.bufs) do
    add(
      "  %7.1fm %7.1fm %7.1fm %8d %7.0f  %-10s %s",
      b.read_ms or 0,
      b.ft_ms or 0,
      b.draw_ms or 0,
      b.lines or 0,
      (b.bytes or 0) / 1024,
      b.ft or "-",
      vim.fn.fnamemodify(b.path or "", ":t")
    )
  end
  if #M.state.bufs == 0 then
    add("  (none)")
  end
  add("")

  -- clients
  add("LSP CLIENTS (spawn -> first attach)")
  add("  %8s %8s %6s  %-16s %s", "ready", "spawn", "bufs", "client", "root")
  local ids = vim.tbl_keys(M.state.clients)
  table.sort(ids)
  for _, id in ipairs(ids) do
    local c = M.state.clients[id]
    add(
      "  %7.1fm %7.1fm %6d  %-16s %s",
      c.ready_ms or 0,
      c.spawn_ms or 0,
      #c.attaches,
      c.name,
      vim.fn.fnamemodify(c.root or "-", ":~")
    )
  end
  if #ids == 0 then
    add("  (none)")
  end
  add("")

  -- indexing
  add("SERVER PROGRESS ($/progress — indexing, workspace load)")
  local prog = vim.deepcopy(M.state.progress)
  table.sort(prog, function(a, b)
    return a.ms > b.ms
  end)
  for i = 1, math.min(20, #prog) do
    local p = prog[i]
    add("  %8.1fm  %-16s %s%s", p.ms, p.client, p.title, p.message and (" — " .. p.message) or "")
  end
  if #prog == 0 then
    add("  (none — no server reported work-done progress)")
  end
  add("")

  -- diagnostics latency
  add("DIAGNOSTICS LATENCY (didOpen/didChange -> publishDiagnostics)")
  add("  %6s %8s %8s %8s %9s  %s", "n", "p50", "p90", "max", "total", "client")
  local dkeys = vim.tbl_keys(M.state.diags)
  table.sort(dkeys)
  for _, k in ipairs(dkeys) do
    local s = stats(M.state.diags[k].samples)
    add("  %6d %7.1fm %7.1fm %7.1fm %8.2fs  %s", M.state.diags[k].n, s.p50, s.p90, s.max, s.sum / 1000, k)
  end
  if #dkeys == 0 then
    add("  (none)")
  end
  add("")

  -- requests
  add("LSP REQUESTS (round-trip, top 25 by total time)")
  add("  %6s %8s %8s %8s %9s  %s", "n", "p50", "p90", "max", "total", "client / method")
  local rkeys = vim.tbl_keys(M.state.requests)
  local rstats = {}
  for _, k in ipairs(rkeys) do
    rstats[#rstats + 1] = { key = k, s = stats(M.state.requests[k].samples), b = M.state.requests[k] }
  end
  table.sort(rstats, function(a, b)
    return a.s.sum > b.s.sum
  end)
  for i = 1, math.min(25, #rstats) do
    local r = rstats[i]
    add("  %6d %7.1fm %7.1fm %7.1fm %8.2fs  %s", r.b.n, r.s.p50, r.s.p90, r.s.max, r.s.sum / 1000, r.key)
  end
  if #rstats == 0 then
    add("  (none)")
  end
  add("")

  -- stalls
  add(("UI STALLS (main loop blocked > %d ms)"):format(M.opts.stall_ms))
  local stalls = vim.deepcopy(M.state.stalls)
  table.sort(stalls, function(a, b)
    return a.ms > b.ms
  end)
  local stall_sum = 0
  for _, s in ipairs(M.state.stalls) do
    stall_sum = stall_sum + s.ms
  end
  add("  %9s %6s  %-10s %s", "blocked", "mode", "ft", "buffer")
  for i = 1, math.min(20, #stalls) do
    local s = stalls[i]
    add("  %8.0fm %6s  %-10s %s", s.ms, s.mode, s.ft or "-", vim.fn.fnamemodify(s.buf or "", ":t"))
  end
  add("  %d stalls, %.2fs blocked in total", #M.state.stalls, stall_sum / 1000)

  if next(M.state.lua_samples) then
    add("")
    add("LUA SAMPLES (%d ms interval — where main-loop time went)", M.opts.sample_ms)
    local flat, total = {}, 0
    for stack, n in pairs(M.state.lua_samples) do
      flat[#flat + 1] = { stack = stack, n = n }
      total = total + n
    end
    table.sort(flat, function(a, b)
      return a.n > b.n
    end)
    add("  %8s %6s  %s", "time", "share", "stack (innermost first)")
    for i = 1, math.min(20, #flat) do
      local f = flat[i]
      add("  %7.0fm %5.1f%%  %s", f.n * M.opts.sample_ms, 100 * f.n / total, (f.stack:gsub(";%s*$", "")))
    end
    add("  %7.0fm total sampled Lua time in %d distinct stacks", total * M.opts.sample_ms, #flat)
  end

  if M.state.shutdown and M.state.shutdown.ms then
    add("")
    add("SHUTDOWN: %.0f ms waiting on %s", M.state.shutdown.ms, table.concat(M.state.shutdown.clients or {}, ", "))
  end

  return out
end

--- Open the report in a scratch buffer.
function M.show()
  if not M.enabled then
    vim.notify("profiler is off — start nvim with NVIM_PROFILE=1", vim.log.levels.WARN)
    return
  end
  local lines = M.report()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_name(buf, "nvim-profile://report")
  vim.cmd.tabnew()
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo.wrap = false
  vim.keymap.set("n", "q", "<cmd>tabclose<cr>", { buffer = buf, silent = true })
end

--- Write the raw samples as JSON.
--- @param path? string
--- @return string path written
function M.dump(path)
  local dir = vim.fs.joinpath(vim.fn.stdpath("state"), "profile")
  vim.fn.mkdir(dir, "p")
  path = path or vim.fs.joinpath(dir, ("profile-%d-%d.json"):format(os.time(), vim.fn.getpid()))

  -- Client configs can carry functions (`cmd`, `before_init`); JSON can't.
  local clients = {}
  for id, c in pairs(M.state.clients) do
    local copy = vim.deepcopy(c)
    copy.cmd = type(c.cmd) == "table" and table.concat(c.cmd, " ") or (c.cmd and tostring(c.cmd) or nil)
    clients[tostring(id)] = copy
  end

  local payload = {
    pid = vim.fn.getpid(),
    nvim = tostring(vim.version()),
    uptime_ms = elapsed(),
    started_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    opts = M.opts,
    modules = M.state.modules,
    bufs = M.state.bufs,
    clients = clients,
    progress = M.state.progress,
    stalls = M.state.stalls,
    lua_samples = M.state.lua_samples,
    shutdown = M.state.shutdown,
    per_file = M.state.per_file, -- filled in by scripts/profile_run.lua
    requests = {},
    diagnostics = {},
  }
  for k, v in pairs(M.state.requests) do
    payload.requests[k] = vim.tbl_extend("force", stats(v.samples), { cancelled = v.err })
  end
  for k, v in pairs(M.state.diags) do
    payload.diagnostics[k] = vim.tbl_extend("force", stats(v.samples), { count_max = v.count_max })
  end

  local fd = assert(io.open(path, "w"))
  fd:write(vim.json.encode(payload))
  fd:close()
  return path
end

function M.reset()
  M.state = new_state()
  T0 = uv.hrtime()
end

--- @param opts? table
function M.setup(opts)
  if M.enabled then
    return M
  end
  M.opts = vim.tbl_extend("force", M.opts, opts or {})
  M.enabled = true

  local group = vim.api.nvim_create_augroup("nvim_profile", { clear = true })
  -- selene: allow(global_usage)
  _G.require = timed_require
  buf_hook(group)
  lsp_hook(group)
  stall_hook()
  exit_hook(group)
  if M.opts.sample then
    sampler_start()
  end

  vim.api.nvim_create_user_command("Profile", function()
    M.show()
  end, { desc = "Profiler: show report" })
  vim.api.nvim_create_user_command("ProfileDump", function(a)
    local p = M.dump(a.args ~= "" and a.args or nil)
    vim.notify("profile written to " .. p)
  end, { nargs = "?", complete = "file", desc = "Profiler: dump JSON" })
  vim.api.nvim_create_user_command("ProfileReset", function()
    M.reset()
    vim.notify("profile samples cleared")
  end, { desc = "Profiler: reset samples" })

  return M
end

return M
