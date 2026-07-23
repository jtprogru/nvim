-- mini.statusline configuration: brand-themed sections and highlights.
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

local function hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

-- Палитра берётся заново на каждый вызов, а не один раз при загрузке: тема
-- переключается между Latte и Macchiato в рантайме (autocmds.lua синхронизирует
-- `background` с macOS), и get_palette() отдаёт цвета активного flavour.
--
-- Три уровня фона, как было на gruvbox: crust (неактивная строка) < surface0
-- (имя файла) < surface1 (мета). Режимы — на катпуччиновских тонах, Normal
-- забирает брендовый Sapphire (см. plugins/mishka.lua).
local function paint()
  local c = require("catppuccin.palettes").get_palette()

  local function mode(color)
    return { fg = c.base, bg = color, bold = true }
  end

  hl("MiniStatuslineModeNormal", mode(c.sapphire))
  hl("MiniStatuslineModeInsert", mode(c.green))
  hl("MiniStatuslineModeVisual", mode(c.mauve))
  hl("MiniStatuslineModeReplace", mode(c.red))
  hl("MiniStatuslineModeCommand", mode(c.peach))
  hl("MiniStatuslineModeOther", mode(c.lavender))

  hl("MiniStatuslineDevinfo", { fg = c.subtext0, bg = c.surface1 })
  hl("MiniStatuslineFilename", { fg = c.text, bg = c.surface0, bold = true })
  hl("MiniStatuslineFileinfo", { fg = c.subtext0, bg = c.surface1 })
  hl("MiniStatuslineInactive", { fg = c.overlay1, bg = c.crust, italic = true })
end

MiniStatusline.setup({ use_icons = true, content = { active = active } })
paint()
vim.api.nvim_create_autocmd("ColorScheme", { callback = paint })
