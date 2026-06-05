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
    offsets = {
      { filetype = "neo-tree", text = "Files", text_align = "center", highlight = "Directory" },
      { filetype = "MiniFiles", text = "Files", text_align = "center", highlight = "Directory" },
    },
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = "thin",
  },
})

local map = vim.keymap.set
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Delete other buffers" })
map("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete buffers to the right" })
map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete buffers to the left" })
