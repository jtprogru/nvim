vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Profiler must hook `require` before anything else is loaded.
-- Enable with NVIM_PROFILE=1 or --cmd 'lua vim.g.nvim_profile = true'.
if vim.env.NVIM_PROFILE == "1" or vim.g.nvim_profile then
  require("util.profile").setup({
    dump_on_exit = vim.env.NVIM_PROFILE_DUMP == "1",
    sample = vim.env.NVIM_PROFILE_SAMPLE == "1",
  })
end

require("config.options")
require("config.pack") -- install plugins (vim.pack.add)
require("plugins") -- per-plugin configs (lua/plugins/*.lua)
require("config.statusline") -- mini.statusline (after plugins/mini.lua sets up mini.icons)
require("config.lsp") -- after blink so its capabilities are available
require("config.keymaps") -- after plugins so requires resolve
require("config.autocmds")
