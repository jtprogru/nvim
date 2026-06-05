-- Plugin configs loaded in dependency order.
-- New plugin? Add to lua/config/pack.lua AND create lua/plugins/<name>.lua,
-- then append <name> to the list below.

local order = {
  "mason",         -- early so :MasonInstall is available even if later setups error
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
}

for _, name in ipairs(order) do
  require("plugins." .. name)
end
