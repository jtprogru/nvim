-- Plugin install list. Single source of truth — what we install lives here,
-- HOW each plugin is configured lives in lua/plugins/<name>.lua.
--
-- :h vim.pack                 — overview
-- :checkhealth vim.pack       — diagnostics
-- :lua vim.pack.update()      — interactive update UI (commit lockfile after)

vim.pack.add({
  -- core dependencies
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.nvim" },

  -- UI
  { src = "https://github.com/ellisonleao/gruvbox.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/folke/noice.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },

  -- editor
  { src = "https://github.com/mrjones2014/smart-splits.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/kdheepak/lazygit.nvim" },

  -- completion / formatting
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("v1") },
  { src = "https://github.com/stevearc/conform.nvim" },

  -- languages
  { src = "https://github.com/mrcjkb/rustaceanvim" },
  { src = "https://github.com/davidmh/mdx.nvim" },

  -- markdown / notes
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/HakonHarnes/img-clip.nvim" },
  { src = "https://github.com/obsidian-nvim/obsidian.nvim" },

  -- quarto / book authoring
  { src = "https://github.com/jmbuhr/otter.nvim" },
  { src = "https://github.com/quarto-dev/quarto-nvim" },

  -- LSP server configs
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- testing (neotest)
  { src = "https://github.com/nvim-neotest/neotest" },
  { src = "https://github.com/fredrikaverpil/neotest-golang" },
  { src = "https://github.com/nvim-neotest/neotest-python" },
  { src = "https://github.com/nvim-neotest/neotest-plenary" },

  -- debugging (nvim-dap)
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/leoluz/nvim-dap-go" },
  { src = "https://github.com/mfussenegger/nvim-dap-python" },

  -- tooling
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})
