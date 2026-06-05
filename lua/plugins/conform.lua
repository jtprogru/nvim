require("conform").setup({
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    go = { "goimports", "gofumpt" },
    markdown = { "markdownlint-cli2" },
    json = { "jq" },
    yaml = { "yamlfmt" },
    toml = { "taplo" },
  },
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = { start = { args.line1, 0 }, ["end"] = { args.line2, end_line:len() } }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  end
end, { bang = true })

local map = vim.keymap.set
map({ "n", "v" }, "<leader>cf", "<cmd>Format<cr>", { desc = "Format" })
map("n", "<leader>uf", "<cmd>FormatToggle<cr>", { desc = "Toggle autoformat (global)" })
map("n", "<leader>uF", "<cmd>FormatToggle!<cr>", { desc = "Toggle autoformat (buffer)" })
