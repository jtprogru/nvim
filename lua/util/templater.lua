-- Минимальный движок Obsidian Templater (<% tp.* %>) на Lua.
-- Поддерживает:
--   tp.date.now(fmt?, offset?)        -- offset: число дней или ISO "P[-]NY|M|W|D"
--   tp.date.tomorrow(fmt?), tp.date.yesterday(fmt?)
--   tp.date.weekday(fmt?, idx, anchor?) -- idx: 0=Mon..6=Sun, anchor: "YYYY-MM-DD"
--   tp.file.title  (+ .substring(s,e?), .split(sep)[i], .toUpperCase/.toLowerCase/.trim, .length)
--   tp.file.creation_date(fmt?)
--   tp.user.input(prompt?)
--   Конкатенация строк '+', строковые/числовые литералы.
--
-- Caveat: substring/split работают по байтам (не UTF-16 как в JS).
-- Для ASCII-дат и латинских разделителей это совпадает с поведением Templater.

local M = {}

local function moment_to_strftime(fmt)
  local out = {}
  local i = 1
  while i <= #fmt do
    local c = fmt:sub(i, i)
    if c == "[" then
      local close = fmt:find("]", i + 1, true) or #fmt + 1
      local lit = fmt:sub(i + 1, close - 1)
      table.insert(out, (lit:gsub("%%", "%%%%")))
      i = close + 1
    else
      local p4 = fmt:sub(i, i + 3)
      local p3 = fmt:sub(i, i + 2)
      local p2 = fmt:sub(i, i + 1)
      if p4 == "YYYY" then
        table.insert(out, "%Y")
        i = i + 4
      elseif p4 == "MMMM" then
        table.insert(out, "%B")
        i = i + 4
      elseif p4 == "dddd" then
        table.insert(out, "%A")
        i = i + 4
      elseif p3 == "MMM" then
        table.insert(out, "%b")
        i = i + 3
      elseif p3 == "ddd" then
        table.insert(out, "%a")
        i = i + 3
      elseif p2 == "YY" then
        table.insert(out, "%y")
        i = i + 2
      elseif p2 == "MM" then
        table.insert(out, "%m")
        i = i + 2
      elseif p2 == "DD" then
        table.insert(out, "%d")
        i = i + 2
      elseif p2 == "HH" then
        table.insert(out, "%H")
        i = i + 2
      elseif p2 == "mm" then
        table.insert(out, "%M")
        i = i + 2
      elseif p2 == "ss" then
        table.insert(out, "%S")
        i = i + 2
      elseif p2 == "ww" then
        table.insert(out, "%V")
        i = i + 2
      else
        if c == "%" then
          table.insert(out, "%%")
        else
          table.insert(out, c)
        end
        i = i + 1
      end
    end
  end
  return table.concat(out)
end

local function format_time(time, fmt)
  return tostring(os.date(moment_to_strftime(fmt or "YYYY-MM-DD"), time))
end

local function apply_offset(t_now, offset)
  local t = vim.deepcopy(t_now)
  if type(offset) == "number" then
    t.day = t.day + offset
  elseif type(offset) == "string" then
    local sign, num, unit = offset:match("^P([%+%-]?)(%d+)([YMWD])$")
    if sign then
      local n = tonumber(num) or 0
      if sign == "-" then
        n = -n
      end
      if unit == "Y" then
        t.year = t.year + n
      elseif unit == "M" then
        t.month = t.month + n
      elseif unit == "W" then
        t.day = t.day + n * 7
      elseif unit == "D" then
        t.day = t.day + n
      end
    end
  end
  return os.time(t)
end

local function tokenize(s)
  local tokens = {}
  local i = 1
  while i <= #s do
    local c = s:sub(i, i)
    if c:match("%s") then
      i = i + 1
    elseif c == '"' or c == "'" then
      local quote = c
      local j = i + 1
      local buf = {}
      while j <= #s and s:sub(j, j) ~= quote do
        if s:sub(j, j) == "\\" then
          table.insert(buf, s:sub(j + 1, j + 1))
          j = j + 2
        else
          table.insert(buf, s:sub(j, j))
          j = j + 1
        end
      end
      table.insert(tokens, { type = "string", value = table.concat(buf) })
      i = j + 1
    elseif c:match("%d") or (c == "-" and s:sub(i + 1, i + 1):match("%d")) then
      local j = i + 1
      while j <= #s and s:sub(j, j):match("[%d%.]") do
        j = j + 1
      end
      table.insert(tokens, { type = "number", value = tonumber(s:sub(i, j - 1)) })
      i = j
    elseif c:match("[%a_]") then
      local j = i
      while j <= #s and s:sub(j, j):match("[%w_]") do
        j = j + 1
      end
      table.insert(tokens, { type = "ident", value = s:sub(i, j - 1) })
      i = j
    elseif c:find("[%.%(%)%,%+%[%]]") then
      table.insert(tokens, { type = "op", value = c })
      i = i + 1
    else
      i = i + 1
    end
  end
  return tokens
end

local function escape_pat(s)
  return (s:gsub("([%%%-%.%+%[%]%(%)%$%^%?%*])", "%%%1"))
end

local function js_split(s, sep)
  local out = {}
  if sep == "" then
    for j = 1, #s do
      table.insert(out, s:sub(j, j))
    end
    return out
  end
  local pat = escape_pat(sep)
  local rest = s
  while true do
    local a, b = rest:find(pat)
    if not a then
      table.insert(out, rest)
      break
    end
    table.insert(out, rest:sub(1, a - 1))
    rest = rest:sub(b + 1)
  end
  return out
end

local function js_substring(s, a, b)
  a = a or 0
  if b == nil then
    return s:sub(a + 1)
  end
  if a > b then
    a, b = b, a
  end
  return s:sub(a + 1, b)
end

local function eval_expr(s, ctx)
  local tokens = tokenize(s)
  local pos = 1

  local function peek()
    return tokens[pos]
  end
  local function consume()
    local t = tokens[pos]
    pos = pos + 1
    return t
  end
  local function expect(value)
    local t = consume()
    if not t or t.value ~= value then
      error("expected '" .. value .. "'")
    end
    return t
  end

  local parse_expr

  local function parse_args()
    local args = {}
    if peek() and peek().value == ")" then
      return args
    end
    table.insert(args, parse_expr())
    while peek() and peek().value == "," do
      consume()
      table.insert(args, parse_expr())
    end
    return args
  end

  local function call_function(chain, args)
    local key = table.concat(chain, ".")
    local now = os.date("*t", ctx.now)
    if key == "tp.date.now" then
      return format_time(apply_offset(now, args[2]), args[1])
    elseif key == "tp.date.tomorrow" then
      return format_time(apply_offset(now, 1), args[1])
    elseif key == "tp.date.yesterday" then
      return format_time(apply_offset(now, -1), args[1])
    elseif key == "tp.date.weekday" then
      local fmt = args[1]
      local idx = args[2] or 0
      local anchor = args[3]
      local base
      if type(anchor) == "string" then
        local y, m, d = anchor:match("^(%d+)%-(%d+)%-(%d+)")
        if y then
          base = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
        end
      end
      base = base or ctx.now
      local bt = os.date("*t", base)
      local mon0 = (bt.wday - 2) % 7 -- 0=Mon..6=Sun
      bt.day = bt.day + (idx - mon0)
      return format_time(os.time(bt), fmt)
    elseif key == "tp.file.creation_date" then
      return format_time(ctx.creation or ctx.now, args[1])
    elseif key == "tp.user.input" then
      return vim.fn.input((args[1] or "Input") .. ": ")
    end
    error("unknown function: " .. key)
  end

  local function parse_primary()
    local t = peek()
    if not t then
      error("unexpected end")
    end
    if t.type == "string" or t.type == "number" then
      consume()
      return t.value
    end
    if t.type == "ident" then
      local first = consume().value
      if first == "tp" and peek() and peek().value == "." then
        consume()
        local ns = consume()
        if not ns or ns.type ~= "ident" then
          error("expected namespace after 'tp.'")
        end
        expect(".")
        local name = consume()
        if not name or name.type ~= "ident" then
          error("expected name after 'tp." .. ns.value .. ".'")
        end
        local chain = { "tp", ns.value, name.value }
        if peek() and peek().value == "(" then
          consume()
          local args = parse_args()
          expect(")")
          return call_function(chain, args)
        end
        local key = table.concat(chain, ".")
        if key == "tp.file.title" then
          return ctx.title or ""
        end
        if key == "tp.file.creation_date" then
          return format_time(ctx.creation or ctx.now)
        end
        error("unknown identifier: " .. key)
      end
      return first
    end
    if t.value == "(" then
      consume()
      local v = parse_expr()
      expect(")")
      return v
    end
    error("unexpected token: " .. tostring(t.value))
  end

  local function parse_postfix()
    local v = parse_primary()
    while peek() do
      local t = peek()
      if t.value == "." then
        consume()
        local member = consume()
        if not member or member.type ~= "ident" then
          error("expected identifier after '.'")
        end
        local name = member.value
        if peek() and peek().value == "(" then
          consume()
          local args = parse_args()
          expect(")")
          if name == "substring" then
            v = js_substring(v, args[1], args[2])
          elseif name == "split" then
            v = js_split(v, args[1] or "")
          elseif name == "toUpperCase" then
            v = string.upper(v)
          elseif name == "toLowerCase" then
            v = string.lower(v)
          elseif name == "trim" then
            v = vim.trim(v)
          elseif name == "replace" then
            v = (v:gsub(escape_pat(args[1] or ""), (args[2] or ""):gsub("%%", "%%%%")))
          else
            error("unknown method: " .. name)
          end
        else
          if name == "length" then
            v = #v
          else
            error("unknown property: " .. name)
          end
        end
      elseif t.value == "[" then
        consume()
        local idx = parse_expr()
        expect("]")
        if type(v) == "table" then
          v = v[(idx or 0) + 1]
        elseif type(v) == "string" then
          v = v:sub(idx + 1, idx + 1)
        end
      else
        break
      end
    end
    return v
  end

  parse_expr = function()
    local left = parse_postfix()
    while peek() and peek().value == "+" do
      consume()
      local right = parse_postfix()
      left = tostring(left) .. tostring(right)
    end
    return left
  end

  return parse_expr()
end

function M.render(content, ctx)
  ctx = ctx or {}
  ctx.now = ctx.now or os.time()
  ctx.title = ctx.title or ""
  ctx.creation = ctx.creation or ctx.now
  return (content:gsub("<%%%-?(.-)%-?%%>", function(expr)
    local ok, val = pcall(eval_expr, expr, ctx)
    if not ok then
      vim.notify("Templater: " .. tostring(val) .. "\nexpr: <%" .. expr .. "%>", vim.log.levels.WARN)
      return "<%" .. expr .. "%>"
    end
    return tostring(val)
  end))
end

local TEMPLATES_DIR = vim.fn.expand(
  "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain/_Система/1. Шаблоны"
)
local VAULT_DIR = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain")

function M.templates_dir()
  return TEMPLATES_DIR
end

function M.vault_dir()
  return VAULT_DIR
end

function M.list_templates()
  local items = {}
  local handle = vim.uv.fs_scandir(TEMPLATES_DIR)
  if not handle then
    return items
  end
  while true do
    local name, t = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if t == "file" and name:match("%.md$") then
      table.insert(items, name)
    end
  end
  table.sort(items)
  return items
end

function M.read_template(name)
  local path = TEMPLATES_DIR .. "/" .. name
  local f = io.open(path, "rb")
  if not f then
    error("template not found: " .. path)
  end
  local content = f:read("*a")
  f:close()
  return content, path
end

local function current_ctx()
  local file = vim.api.nvim_buf_get_name(0)
  local title = vim.fn.fnamemodify(file, ":t:r")
  local creation = vim.fn.getftime(file)
  if creation == -1 then
    creation = os.time()
  end
  return { now = os.time(), title = title, creation = creation }
end

function M.insert_at_cursor(template_name)
  local ok, content = pcall(M.read_template, template_name)
  if not ok then
    vim.notify(content, vim.log.levels.ERROR)
    return
  end
  local rendered = M.render(content, current_ctx())
  local lines = vim.split(rendered, "\n", { plain = true })
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
end

function M.pick_and_insert()
  local items = M.list_templates()
  if #items == 0 then
    vim.notify("Шаблоны не найдены: " .. TEMPLATES_DIR, vim.log.levels.WARN)
    return
  end
  vim.ui.select(items, { prompt = "Шаблон Templater:" }, function(choice)
    if choice then
      M.insert_at_cursor(choice)
    end
  end)
end

-- Создаёт/открывает дневную заметку (имя YYYY-MM-DD) с применением шаблона "Ежедневная заметка.md".
function M.daily(opts)
  opts = opts or {}
  local offset = opts.offset or 0
  local now = os.time() + offset * 86400
  local date_str = os.date("%Y-%m-%d", now)
  local year = os.date("%Y", now)
  local month = os.date("%m", now)
  local path = VAULT_DIR .. "/05. Дневник/" .. year .. "/" .. month .. "/" .. date_str .. ".md"
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local exists = vim.uv.fs_stat(path) ~= nil
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  if not exists then
    local ok, content = pcall(M.read_template, "Ежедневная заметка.md")
    if ok then
      local ctx = { now = now, title = date_str, creation = now }
      local rendered = M.render(content, ctx)
      local lines = vim.split(rendered, "\n", { plain = true })
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
  end
end

return M
