-- Plugin configs loaded in dependency order.
-- New plugin? Add to lua/config/pack.lua AND create lua/plugins/<name>.lua,
-- then append <name> to the list below.

local order = {
  "mason",         -- first: prepends mason/bin to PATH (treesitter needs tree-sitter-cli)
  "treesitter",    -- second: blocks on parser install (one-time on fresh setup)
  "mini",          -- icons used by which-key / bufferline / render-md
  "gruvbox",       -- colorscheme
  "which-key",
  "bufferline",
  "noice",
  "fzf-lua",       -- before blink (some keymaps reference fzf-lua)
  "smart-splits",
  "gitsigns",
  "blink",         -- before config.lsp (capabilities)
  "conform",
  "render-md",
  "img-clip",
  "obsidian",
  "quarto",
  "rustaceanvim",
  "dap",           -- after rustaceanvim (rust filetype override needs RustLsp)
  "neotest",       -- after dap (neotest's <leader>td uses dap strategy)
}

for _, name in ipairs(order) do
  require("plugins." .. name)
end
