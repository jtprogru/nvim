require("quarto").setup({
  lspFeatures = {
    enabled = true,
    chunks = "all",
    languages = { "python", "bash", "lua", "html", "yaml", "json" },
    diagnostics = { enabled = true, triggers = { "BufWritePost" } },
    completion = { enabled = true },
  },
  codeRunner = { enabled = false },
  keymap = {
    hover = false,
    definition = false,
    rename = false,
    references = false,
    format = false,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "quarto", "markdown" },
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "<leader>qp", function()
      require("quarto").quartoPreview()
    end, vim.tbl_extend("force", opts, { desc = "Quarto Preview" }))
    vim.keymap.set("n", "<leader>qc", function()
      require("quarto").quartoClosePreview()
    end, vim.tbl_extend("force", opts, { desc = "Quarto Close Preview" }))
    vim.keymap.set("n", "<leader>qa", function()
      require("quarto").activate()
    end, vim.tbl_extend("force", opts, { desc = "Quarto Activate (otter LSP)" }))
  end,
})
