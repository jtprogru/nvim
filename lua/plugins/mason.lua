require("mason").setup({
  max_concurrent_installers = 6,
  ui = {
    icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
  },
})

-- mason-tool-installer drives `ensure_installed` (mason itself doesn't).
require("mason-tool-installer").setup({
  ensure_installed = {
    -- LSP
    "ansible-language-server",
    "bash-language-server",
    "basedpyright",
    "gopls",
    "lua-language-server",
    "ltex-ls-plus",
    "marksman",
    "ruff",
    "yaml-language-server",
    -- Linters
    "ansible-lint",
    "gitleaks",
    "golangci-lint",
    "markdownlint-cli2",
    "semgrep",
    "shellcheck",
    -- Formatters
    "gofumpt",
    "goimports",
    "shfmt",
    "stylua",
    "taplo",
    -- Go tools
    "delve",
    "gomodifytags",
    "gotests",
    "gotestsum",
    "iferr",
    "impl",
    -- Python tools
    "debugpy",
    -- Debug adapters
    "codelldb",       -- Rust / C / C++ via rustaceanvim's :RustLsp debuggables
    -- Misc
    "ast-grep",
    "gh",
    "markdown-toc",
    "tfsec",
  },
  auto_update = false,
  run_on_start = true,
  start_delay = 3000,
})
