-- nvim-lint — security scanners surfaced as inline diagnostics (no terminal).
--
-- Binaries come from mason (`lua/plugins/mason.lua`), which prepends its bin to
-- PATH, so `bandit`/`hadolint`/`trivy`/`golangci-lint` resolve without full paths.
-- Findings show up like any diagnostic: underlines in the code, `]d`/`[d` to jump,
-- `<leader>sd` for the fzf-lua list. Repo-wide tools that don't fit per-file
-- linting (gitleaks, semgrep) stay manual — see the cheatsheet in KEYMAPS.md.
local lint = require("lint")

-- Only security-relevant linters here (style linters live elsewhere / in LSP).
--   trivy       — misconfig scan per file: Terraform/HCL, k8s YAML, Dockerfile
--   bandit      — Python SAST
--   hadolint    — Dockerfile best-practice / security
--   golangcilint— Go; surfaces gosec ONLY if enabled in the repo's .golangci.yml
lint.linters_by_ft = {
  python = { "bandit" },
  dockerfile = { "hadolint", "trivy" },
  terraform = { "trivy" },
  hcl = { "trivy" },
  yaml = { "trivy" },
  go = { "golangcilint" },
}

-- Run on read + save. Not on InsertLeave: trivy/golangci-lint spawn a process
-- each time and would thrash while typing. Go's golangci-lint can be slow on
-- large modules — drop "go" from the table above or lint on save only if it lags.
local aug = vim.api.nvim_create_augroup("nvim_lint_security", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = aug,
  callback = function()
    lint.try_lint()
  end,
})

-- Manual re-lint (e.g. after changing a scanner config without saving the buffer).
vim.keymap.set("n", "<leader>cx", function()
  lint.try_lint()
end, { desc = "Run security linters (nvim-lint)" })
