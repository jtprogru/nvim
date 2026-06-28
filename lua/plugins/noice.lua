require("noice").setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },
  popupmenu = { enabled = true, backend = "nui" },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    progress = { enabled = true, view = "mini" }, -- bottom-right small
    hover = { enabled = true },
    signature = { enabled = false }, -- blink.cmp handles signature
    message = { enabled = true, view = "mini" }, -- merge with progress, no top-right popup
  },
  presets = {
    bottom_search = true, -- classic bottom cmdline for `/`
    command_palette = true, -- centered popup for `:`
    long_message_to_split = true, -- long messages go to split
    inc_rename = false,
    lsp_doc_border = true,
  },
  messages = {
    enabled = true,
    view = "mini", -- regular :echo / msg_show go to bottom-right
    view_error = "notify", -- errors stay loud (top-right popup)
    view_warn = "notify", -- warnings stay loud
    view_history = "messages",
  },
  routes = {
    -- Quiet "no information available" hover
    { filter = { event = "msg_show", kind = "", find = "No information available" }, opts = { skip = true } },
    -- Suppress "written" save spam to bottom-right
    { filter = { event = "msg_show", kind = "", find = "written" }, view = "mini" },
  },
})

vim.keymap.set("n", "<leader>sn", "<cmd>NoiceHistory<cr>", { desc = "Noice history" })
vim.keymap.set("n", "<leader>un", "<cmd>NoiceDismiss<cr>", { desc = "Dismiss notifications" })
