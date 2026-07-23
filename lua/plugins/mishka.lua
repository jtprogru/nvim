-- Бренд-тема «Мишка на сервере» — слой поверх catppuccin.
--
-- Палитра и решения взяты из дизайн-кода блога jtprog.ru (BRANDING.md v0.2):
-- Latte на свету, Macchiato в темноте, единственный акцент — Sapphire.
-- catppuccin даёт базу и покрытие плагинов; всё «своё» живёт в `brand()` ниже.
--
-- Светлая/тёмная выбирается по `background`, который config/autocmds.lua держит
-- в синхроне с macOS. Поэтому цвета в statusline/bufferline нельзя хардкодить —
-- их надо брать через require("catppuccin.palettes").get_palette(), она отдаёт
-- палитру активного flavour и переезжает вместе с ним.

-- Latte Sapphire (#209fb5) даёт ~3.0:1 на светлом фоне и не проходит AA для
-- текста обычного размера (§2, §8) — это свойство самой палитры, а не тона:
-- catppuccin проектировался под подсветку синтаксиса. Поэтому ссылки на светлой
-- теме идут на затемнённой вручную ступени --accent-700. Единственный цвет вне
-- палитры, осознанный тред-офф ради контраста.
local ACCENT_700 = "#0b7285"

-- Бренд-слой. Одинаковый для обоих flavour, различается только цветом ссылок:
-- на тёмной хватает катпуччиновского Sapphire, на светлой — см. ACCENT_700.
--
-- §2: акцентная шкала одна. Sapphire трогает ссылки, рамки, курсор и иконки —
-- и не расползается дальше, палитры из многих равноправных цветов тут нет.
local function brand(c, link)
  return {
    -- Ссылки — акцент-текст.
    ["@markup.link"] = { fg = link },
    ["@markup.link.label"] = { fg = link },
    ["@markup.link.url"] = { fg = link, style = { "underline" } },
    Underlined = { fg = link, style = { "underline" } },
    RenderMarkdownLink = { fg = link },
    RenderMarkdownWikiLink = { fg = link },

    -- Декоративный акцент (--accent-400): рамки, курсор строки, парные скобки.
    -- Это не текст, контраст тут не нормируется.
    FloatBorder = { fg = c.sapphire, bg = c.mantle },
    WinSeparator = { fg = c.surface0 },
    CursorLineNr = { fg = c.sapphire, style = { "bold" } },
    MatchParen = { fg = c.sapphire, bg = c.surface1, style = { "bold" } },

    -- §4: блок кода живёт на --bg-elev (mantle), фон страницы — base. Оба из
    -- одной палитры и различаются едва заметно, так что блок читается «другим
    -- слоем», а не сбоем оттенка.
    RenderMarkdownCode = { bg = c.mantle },
    RenderMarkdownCodeInline = { fg = c.text, bg = c.surface0 },
    RenderMarkdownQuote = { fg = c.overlay1 },

    -- §2: семантика callouts на катпуччиновских тонах. Слева от каждого — тип
    -- callout'а в терминах дизайн-кода, справа — группа render-markdown,
    -- в которую этот тип попадает.
    RenderMarkdownInfo = { fg = c.lavender }, -- note
    RenderMarkdownSuccess = { fg = c.green }, -- tip
    RenderMarkdownHint = { fg = c.mauve }, -- important
    RenderMarkdownWarn = { fg = c.peach }, -- warn
    RenderMarkdownError = { fg = c.red }, -- danger
    RenderMarkdownTodo = { fg = c.sapphire },
  }
end

require("catppuccin").setup({
  -- "auto" = следовать `background`; конкретные flavour ниже (§2: Macchiato,
  -- а не Frappe — тот светлее и хуже держит контраст на длинных полотнах).
  flavour = "auto",
  background = { light = "latte", dark = "macchiato" },

  term_colors = true,
  transparent_background = false,
  dim_inactive = { enabled = false },

  -- Курсивы как были на gruvbox: комментарии да, строки и операторы нет.
  -- conditionals катпуччин курсивит по умолчанию — выключаем, чтобы код
  -- выглядел так же, как до переезда.
  styles = {
    comments = { "italic" },
    conditionals = {},
    strings = {},
    operators = {},
  },

  -- Явно перечислены только те, чьи плагины реально стоят (см. config/pack.lua).
  -- Остальное закрывает default_integrations.
  default_integrations = true,
  integrations = {
    blink_cmp = true,
    dap = true,
    dap_ui = true,
    fzf = true,
    gitsigns = true,
    mason = true,
    mini = { enabled = true, indentscope_color = "" },
    neotest = true,
    noice = true,
    render_markdown = true,
    which_key = true,
    native_lsp = { enabled = true },
    treesitter = true,
  },

  highlight_overrides = {
    latte = function(c)
      return brand(c, ACCENT_700)
    end,
    macchiato = function(c)
      return brand(c, c.sapphire)
    end,
  },
})

vim.cmd.colorscheme("catppuccin")
