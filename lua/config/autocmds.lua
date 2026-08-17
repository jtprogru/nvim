local aug = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

-- Highlight on yank
au("TextYankPost", {
  group = aug("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Auto-resize splits on terminal resize
au("VimResized", {
  group = aug("resize_splits", { clear = true }),
  command = "tabdo wincmd =",
})

-- Strip trailing whitespace on save (except in markdown)
au("BufWritePre", {
  group = aug("strip_trailing_ws", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].filetype:match("^markdown") or vim.bo[ev.buf].filetype == "mdx" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Spell on for markdown / gitcommit
au("FileType", {
  group = aug("wrap_spell", { clear = true }),
  pattern = { "markdown", "mdx", "gitcommit", "text", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Close some buffers with q
au("FileType", {
  group = aug("close_with_q", { clear = true }),
  pattern = { "help", "qf", "checkhealth", "lspinfo", "man", "notify" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})
