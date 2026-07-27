-- nvim-treesitter `main` branch: install parsers explicitly, start highlights
-- via FileType autocmd. Bundled Neovim parsers (c/lua/markdown/...) come with
-- queries that don't match nvim-treesitter's main-branch queries, so we need
-- nvim-treesitter's own parsers to be on rtp BEFORE any FileType autocmd
-- fires for a language it provides queries for. Hence the synchronous install.
--
-- Requires `tree-sitter` CLI to be on PATH (installed via mason or brew).

local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  vim.notify("nvim-treesitter not loaded: " .. tostring(ts), vim.log.levels.WARN)
  return
end

local parsers = {
  "bash",
  "c",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "go",
  "gomod",
  "gosum",
  "gotmpl",
  "gowork",
  "helm",
  "hcl",
  "html",
  "ini",
  "javascript",
  "jsdoc", -- injected into /** */ blocks in .ts/.js — without it they stay plain comments
  "json",
  "lua",
  "luadoc",
  "luap",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "sql",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

local install_dir = vim.fn.stdpath("data") .. "/site/parser"
vim.fn.mkdir(install_dir, "p")

local missing = vim.tbl_filter(function(p)
  return vim.fn.filereadable(install_dir .. "/" .. p .. ".so") == 0
end, parsers)

if #missing > 0 then
  if vim.fn.executable("tree-sitter") == 0 then
    vim.notify(
      (
        "nvim-treesitter: %d parsers missing and `tree-sitter` CLI not on PATH.\n"
        .. "After Mason installs `tree-sitter-cli` (in progress on first run), restart nvim.\n"
        .. "Or install manually: `brew install tree-sitter`."
      ):format(#missing),
      vim.log.levels.WARN
    )
  else
    vim.notify(("nvim-treesitter: installing %d parsers (one-time, ~1 min)…"):format(#missing), vim.log.levels.INFO)
    local handle = ts.install(missing)
    if handle and handle.wait then
      handle:wait(180000)
    end
    vim.notify("nvim-treesitter: parsers ready.", vim.log.levels.INFO)
  end
end

-- Enable highlights on FileType for any installed parser.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ts_start", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if not lang then
      return
    end
    pcall(vim.treesitter.start, ev.buf, lang)
  end,
})
