-- Minimal runtimepath for headless unit tests.
-- Adds the config root (so `require("util.*")` resolves) and plenary
-- (busted harness) from the vim.pack opt directory. No plugins are loaded,
-- so specs stay fast and isolated from the full config.

local root = vim.fn.fnamemodify(vim.fn.expand("<sfile>:p"), ":h:h")
vim.opt.runtimepath:prepend(root)

local pack_opt = vim.fn.stdpath("data") .. "/site/pack/core/opt"
local plenary = pack_opt .. "/plenary.nvim"
if vim.uv.fs_stat(plenary) then
  vim.opt.runtimepath:append(plenary)
else
  io.stderr:write("plenary.nvim not found at " .. plenary .. "\n")
  io.stderr:write("install plugins first (open nvim once), then re-run tests\n")
  vim.cmd("cquit 1")
end

vim.cmd("runtime plugin/plenary.vim")
