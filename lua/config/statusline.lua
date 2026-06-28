-- mini.statusline configuration: gruvbox-themed sections and highlights.
-- Owns MiniStatusline.setup() entirely; plugins/mini.lua only ensures the
-- mini.nvim pack is on rtp. Loaded from init.lua after plugins/.

local MiniStatusline = require("mini.statusline")

local function section_location()
  if vim.bo.buftype ~= "" then
    return ""
  end
  return "%2l:%-2v %P"
end

local function section_lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  local names = {}
  for _, c in ipairs(clients) do
    names[#names + 1] = c.name
  end
  return " " .. table.concat(names, ",")
end

local function section_filename()
  if vim.bo.buftype == "terminal" then
    return "%t"
  end
  return "%f%m%r"
end

local function active()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git = MiniStatusline.section_git({ trunc_width = 75 })
  local diff = MiniStatusline.section_diff({ trunc_width = 75 })
  local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
  local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, section_lsp() } },
    "%<",
    { hl = "MiniStatuslineFilename", strings = { section_filename() } },
    "%=",
    { hl = "MiniStatuslineFilename", strings = { search } },
    { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
    { hl = mode_hl, strings = { section_location() } },
  })
end

-- Gruvbox palette (Pappas, dark medium-contrast).
local g = {
  bg0_h = "#1d2021",
  bg1 = "#3c3836",
  bg2 = "#504945",
  fg1 = "#ebdbb2",
  fg3 = "#bdae93",
  fg4 = "#a89984",
  red = "#fb4934",
  green = "#b8bb26",
  yellow = "#fabd2f",
  blue = "#83a598",
  purple = "#d3869b",
  aqua = "#8ec07c",
  orange = "#fe8019",
}

local function hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

local function paint()
  hl("MiniStatuslineModeNormal", { fg = g.bg0_h, bg = g.aqua, bold = true })
  hl("MiniStatuslineModeInsert", { fg = g.bg0_h, bg = g.green, bold = true })
  hl("MiniStatuslineModeVisual", { fg = g.bg0_h, bg = g.orange, bold = true })
  hl("MiniStatuslineModeReplace", { fg = g.bg0_h, bg = g.red, bold = true })
  hl("MiniStatuslineModeCommand", { fg = g.bg0_h, bg = g.yellow, bold = true })
  hl("MiniStatuslineModeOther", { fg = g.bg0_h, bg = g.purple, bold = true })

  hl("MiniStatuslineDevinfo", { fg = g.fg3, bg = g.bg2 })
  hl("MiniStatuslineFilename", { fg = g.fg1, bg = g.bg1, bold = true })
  hl("MiniStatuslineFileinfo", { fg = g.fg3, bg = g.bg2 })
  hl("MiniStatuslineInactive", { fg = g.fg4, bg = g.bg0_h, italic = true })
end

MiniStatusline.setup({ use_icons = true, content = { active = active } })
paint()
vim.api.nvim_create_autocmd("ColorScheme", { callback = paint })
