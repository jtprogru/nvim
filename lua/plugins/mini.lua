-- mini.icons must be set up first — other plugins (which-key, bufferline,
-- render-md, mini.statusline) read icons from it via mock_nvim_web_devicons().
-- mini.statusline itself is configured in config/statusline.lua.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("mini.files").setup({
  windows = { preview = true, width_preview = 60 },
  options = { permanent_delete = false },
  mappings = {
    go_in = "l",
    go_in_plus = "<CR>", -- Enter: open file (and close explorer) / enter dir
    go_out = "h",
    go_out_plus = "H",
    close = "q",
    reset = "<BS>",
    show_help = "g?",
    synchronize = "=",
    trim_left = "<",
    trim_right = ">",
    mark_goto = "'",
    mark_set = "m",
  },
})
-- Extra in-explorer binding: <Esc> to close
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "<Esc>", function()
      require("mini.files").close()
    end, { buffer = args.data.buf_id, desc = "Close explorer" })
  end,
})

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
