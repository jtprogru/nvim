require("gruvbox").setup({
  terminal_colors = true,
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = false,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  contrast = "",
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd.colorscheme("gruvbox")
