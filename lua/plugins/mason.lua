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
    "eslint-lsp",
    "harper-ls",
    "json-lsp",
    "lua-language-server",
    "marksman",
    "ruff",
    "terraform-ls",
    "vtsls", -- TypeScript / JavaScript (not ts_ls — see lua/config/lsp.lua)
    "yaml-language-server",
    -- Linters
    "ansible-lint",
    "bandit", -- Python SAST
    "gitleaks",
    "golangci-lint",
    "hadolint", -- Dockerfile linter
    "kube-linter", -- k8s YAML / Helm security static analysis
    "markdownlint-cli2",
    "semgrep",
    "shellcheck",
    "trivy", -- vuln + misconfig + secrets across the whole stack (incl. Rust)
    -- Formatters
    "gofumpt",
    "goimports",
    "prettierd",
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
    "codelldb", -- Rust / C / C++ via rustaceanvim's :RustLsp debuggables
    -- Misc
    "ast-grep",
    "gh",
    "markdown-toc",
    "tfsec",
    "tree-sitter-cli", -- needed by nvim-treesitter to compile parsers
  },
  auto_update = false,
  run_on_start = true,
  start_delay = 3000,
})
