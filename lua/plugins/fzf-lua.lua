require("fzf-lua").setup({
  "default-title",
  winopts = { preview = { default = "bat" } },
  files = { git_icons = true, file_icons = true },
})

-- Route vim.ui.select through fzf-lua. This makes <leader>ca (code actions),
-- vim.lsp.buf.references fallbacks, mason package picker, and any other
-- code calling vim.ui.select() open as a proper centered fuzzy picker
-- instead of the bare "Type number and <Enter>" cmdline prompt.
require("fzf-lua").register_ui_select()
