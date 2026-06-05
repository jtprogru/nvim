require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-y>"] = { "select_and_accept" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = false },
    list = { selection = { preselect = false, auto_insert = true } },
    menu = { border = "rounded" },
  },
  signature = { enabled = true, window = { border = "rounded" } },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})
