require("render-markdown").setup({
  enabled = true,
  render_modes = { "n", "c", "t" },
  file_types = { "markdown", "mdx" },
  html = { enabled = false },
  latex = { enabled = false },
  yaml = { enabled = false },
  heading = {
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    signs = { "󰫎 " },
    width = "full",
    above = "▄",
    below = "▀",
  },
  code = {
    style = "full",
    border = "thin",
    left_pad = 2,
    right_pad = 2,
    above = "▄",
    below = "▀",
  },
  bullet = { icons = { "●", "○", "◆", "◇" } },
  checkbox = {
    unchecked = { icon = "󰄱 " },
    checked = { icon = "󰱒 " },
    custom = {
      todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
      important = { raw = "[~]", rendered = "󰓎 ", highlight = "RenderMarkdownWarn" },
    },
  },
  link = { image = "󰥶 ", email = "󰀓 ", hyperlink = "󰌹 ", wiki = { icon = "󱗖 " } },
  indent = { enabled = true, per_level = 2, skip_level = 1 },
})
