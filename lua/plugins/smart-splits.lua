require("smart-splits").setup({
  ignored_buftypes = { "nofile", "quickfix", "prompt" },
})
-- Cursor-move keymaps (<C-h/j/k/l>) live in lua/config/keymaps.lua so the
-- whole "navigate windows" cluster is in one place.
