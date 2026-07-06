-- Floating-window UI for vim.pack. The :Pack* commands work without setup();
-- calling it here registers the optional <leader>p keymaps and (since which-key
-- is loaded earlier) a "pack-ui" which-key group.
require("pack_ui").setup()
