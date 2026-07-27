-- Headless profiling driver. Not meant to be run directly — use scripts/profile.sh
-- (or `make profile`), which sets NVIM_PROFILE=1 and the env knobs below.
--
--   PROFILE_WAIT    ms to wait for each file to settle          (default 15000)
--   PROFILE_SETTLE  ms of quiet before a file counts as settled (default 1500)
--   PROFILE_EDITS   simulated keystrokes per file               (default 0)
--   PROFILE_EDIT_MS delay between simulated keystrokes          (default 150)
--   PROFILE_OUT     JSON output path                            (default state dir)
--
-- Files come from the nvim arglist, so: nvim --headless a.md b.md -c 'luafile ...'

local uv = vim.uv or vim.loop
local prof = require("util.profile")

local function env(name, default)
  return tonumber(vim.env[name] or "") or default
end

local WAIT = env("PROFILE_WAIT", 15000)
local SETTLE = env("PROFILE_SETTLE", 1500)
local EDITS = env("PROFILE_EDITS", 0)
local EDIT_MS = env("PROFILE_EDIT_MS", 150)

local function out(fmt, ...)
  io.stdout:write((select("#", ...) > 0 and fmt:format(...) or fmt) .. "\n")
end

if not prof.enabled then
  out("!! profiler is not enabled — run with NVIM_PROFILE=1 (module load times will be missing)")
  prof.setup()
end

--- Count LSP requests still in flight for the current buffer's clients.
local function inflight()
  local n = 0
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    for _, r in pairs(c.requests or {}) do
      if r.type == "pending" then
        n = n + 1
      end
    end
  end
  return n
end

--- Block until the buffer stops changing: no pending requests and a stable
--- diagnostic count for SETTLE ms, or WAIT ms elapsed.
--- @return integer ms actually waited
--- @return boolean settled
local function wait_idle()
  local t0 = uv.hrtime()
  local last_sig, last_t = nil, uv.hrtime()
  local settled = vim.wait(WAIT, function()
    local sig = #vim.diagnostic.get(0) .. ":" .. inflight()
    if sig ~= last_sig then
      last_sig, last_t = sig, uv.hrtime()
      return false
    end
    return inflight() == 0 and (uv.hrtime() - last_t) / 1e6 >= SETTLE
  end, 100)
  return (uv.hrtime() - t0) / 1e6, settled
end

--- Append a character at the end of the buffer, like a keystroke would.
local function poke(i)
  local n = vim.api.nvim_buf_line_count(0)
  local line = vim.api.nvim_buf_get_lines(0, n - 1, n, false)[1] or ""
  vim.api.nvim_buf_set_text(0, n - 1, #line, n - 1, #line, { (i % 2 == 0) and "a" or "" })
  if i % 2 == 1 then
    -- odd rounds delete instead of insert, so the file never really grows
    if #line > 0 then
      vim.api.nvim_buf_set_text(0, n - 1, #line - 1, n - 1, #line, { "" })
    end
  end
end

local files = vim.fn.argv()
if #files == 0 then
  out("no files given")
  vim.cmd("qa!")
  return
end

out("profiling %d file(s): wait=%dms settle=%dms edits=%d", #files, WAIT, SETTLE, EDITS)
out("")

local per_file = {}

for i, f in ipairs(files) do
  local t0 = uv.hrtime()
  vim.cmd.edit({ args = { vim.fn.fnameescape(f) }, mods = { silent = true } })
  local open_ms, settled = wait_idle()

  local edit_ms = 0
  if EDITS > 0 then
    local e0 = uv.hrtime()
    for k = 1, EDITS do
      poke(k)
      vim.wait(EDIT_MS)
    end
    local drain = wait_idle()
    edit_ms = (uv.hrtime() - e0) / 1e6
    vim.bo.modified = false
    _ = drain
  end

  local clients = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    clients[#clients + 1] = c.name
  end

  local rec = {
    file = f,
    lines = vim.api.nvim_buf_line_count(0),
    ft = vim.bo.filetype,
    open_ms = open_ms,
    edit_ms = edit_ms,
    settled = settled,
    diagnostics = #vim.diagnostic.get(0),
    clients = clients,
    total_ms = (uv.hrtime() - t0) / 1e6,
  }
  per_file[#per_file + 1] = rec

  out(
    "[%2d/%2d] %7.0fms open %7.0fms edits %4d diag %-5s %-9s %s",
    i,
    #files,
    rec.open_ms,
    rec.edit_ms,
    rec.diagnostics,
    settled and "ok" or "TIMEOUT",
    rec.ft,
    vim.fn.fnamemodify(f, ":t")
  )
end

out("")
out(table.concat(prof.report(), "\n"))
out("")
out("PER-FILE SUMMARY")
table.sort(per_file, function(a, b)
  return a.total_ms > b.total_ms
end)
for _, r in ipairs(per_file) do
  out(
    "  %8.0fms  %5d lines  %3d diag  [%s]  %s",
    r.total_ms,
    r.lines,
    r.diagnostics,
    table.concat(r.clients, ","),
    r.file
  )
end

prof.state.per_file = per_file
local path = prof.dump(vim.env.PROFILE_OUT ~= "" and vim.env.PROFILE_OUT or nil)
out("")
out("json: %s", path)

vim.cmd("qa!")
