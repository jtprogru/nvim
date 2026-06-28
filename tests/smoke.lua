-- Smoke test: the full user config is loaded headless by nvim before this
-- script runs (via `nvim --headless -l tests/smoke.lua` the config is NOT
-- loaded, so we invoke it as a `-c` command after normal startup instead).
--
-- It asserts the config actually took effect and that the util modules the
-- unit tests cover still resolve. Any error here exits nvim with code 1.

local errors = {}

local function check(ok, msg)
  if not ok then
    table.insert(errors, msg)
  end
end

-- init.lua ran and set the leaders.
check(vim.g.mapleader == " ", "mapleader not set to <space>")
check(vim.g.maplocalleader == "\\", "maplocalleader not set to '\\'")

-- Core config modules loaded without throwing.
for _, mod in ipairs({ "util.python", "util.templater", "config.options", "config.keymaps" }) do
  local ok, err = pcall(require, mod)
  check(ok, "require('" .. mod .. "') failed: " .. tostring(err))
end

if #errors > 0 then
  io.stderr:write("SMOKE FAILED:\n")
  for _, e in ipairs(errors) do
    io.stderr:write("  - " .. e .. "\n")
  end
  vim.cmd("cquit 1")
else
  io.stdout:write("smoke OK\n")
  vim.cmd("qa")
end
