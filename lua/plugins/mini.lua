-- mini.icons must be set up first — other plugins (which-key, bufferline,
-- render-md, mini.statusline) read icons from it via mock_nvim_web_devicons().
-- mini.statusline itself is configured in config/statusline.lua.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- File explorer is neo-tree (right sidebar), see plugins/neo-tree.lua.
require("mini.surround").setup()
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.comment").setup()
require("mini.bufremove").setup()

require("mini.notify").setup({
  window = { config = { border = "rounded" } },
  -- LSP progress is handled by noice (bottom-right mini view). Disabling it
  -- here prevents a duplicate top-right popup for the same indexing event.
  lsp_progress = { enable = false },
})
vim.notify = require("mini.notify").make_notify()
