-- Make the active buffer clearly stand out. The default bufferline highlights
-- leave the selected buffer almost indistinguishable from the fill. We give the
-- tabline three background levels (fill < inactive < selected) plus a bold
-- active label and an accent bar.
--
-- `highlights` is passed as a *function* rather than a table: bufferline calls
-- it again on every ColorScheme (config.lua Config:resolve -> bufferline.lua
-- ColorScheme autocmd), so reading the catppuccin palette inside keeps the
-- tabline on whatever flavour is active. It also derives the per-buffer icon
-- backgrounds from these values, keeping the file icon on the same background
-- as its tab.
--
-- catppuccin has no palette-as-highlight-groups to link against, so colors are
-- resolved from its palette API instead. Accent is Sapphire — the single brand
-- accent, same one plugins/mishka.lua uses for links and borders.

require("bufferline").setup({
  options = {
    mode = "buffers",
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(_, _, diag)
      local icons = { error = " ", warning = " " }
      local ret = (diag.error and icons.error .. diag.error .. " " or "")
        .. (diag.warning and icons.warning .. diag.warning or "")
      return vim.trim(ret)
    end,
    -- The explorer sits on the right (plugins/neo-tree.lua); bufferline works
    -- out the side from the window layout, so one entry covers both.
    offsets = {
      { filetype = "neo-tree", text = "Files", text_align = "center", highlight = "Directory" },
    },
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = "thin",
    -- A thin accent bar on the left of the active buffer. No underline.
    indicator = { style = "icon", icon = "▎" },
  },
  highlights = function()
    local c = require("catppuccin.palettes").get_palette()
    -- fill < inactive < selected, from the most-contrasted level down to the
    -- editor background itself.
    local bg0, bg1, bg2 = c.base, c.surface0, c.surface1
    local fg1, gray, accent = c.text, c.overlay1, c.sapphire

    -- The three depth levels, as fresh tables. No italic anywhere.
    local function inactive()
      return { fg = gray, bg = bg1, bold = false, italic = false }
    end
    local function selected()
      return { fg = fg1, bg = bg0, bold = true, italic = false }
    end

    local hl = {
      -- Whole bar frame: the most-contrasted level.
      fill = { bg = bg2 },
      -- Inactive buffers: dimmed text on a mid level.
      background = inactive(),
      buffer_visible = inactive(),
      numbers = inactive(),
      numbers_visible = inactive(),
      duplicate = { fg = gray, bg = bg1, italic = false },
      duplicate_visible = { fg = gray, bg = bg1, italic = false },
      modified = { fg = accent, bg = bg1 },
      modified_visible = { fg = accent, bg = bg1 },
      -- Active buffer: editor background + bold, so it reads as "raised".
      buffer_selected = selected(),
      numbers_selected = selected(),
      duplicate_selected = { fg = gray, bg = bg0, italic = false },
      modified_selected = { fg = accent, bg = bg0 },
      indicator_selected = { fg = accent, bg = bg0 },
      -- Separators blend into each side's background.
      separator = { fg = bg2, bg = bg1 },
      separator_visible = { fg = bg2, bg = bg1 },
      separator_selected = { fg = bg2, bg = bg0 },
    }

    -- Neutralize the diagnostic-driven name styling. Once an LSP (e.g. ltex)
    -- attaches, bufferline colors a buffer's *name* with these groups, whose
    -- defaults carry a different background and italics — making tabs with
    -- diagnostics look inconsistent with clean ones. Map them all onto our own
    -- levels so every tab looks identical regardless of diagnostics.
    local bases = { "diagnostic" }
    for _, sev in ipairs({ "hint", "info", "warning", "error" }) do
      bases[#bases + 1] = sev
      bases[#bases + 1] = sev .. "_diagnostic"
    end
    for _, base in ipairs(bases) do
      hl[base] = inactive()
      hl[base .. "_visible"] = inactive()
      hl[base .. "_selected"] = selected()
    end

    return hl
  end,
})

local map = vim.keymap.set
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Delete other buffers" })
map("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete buffers to the right" })
map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete buffers to the left" })
