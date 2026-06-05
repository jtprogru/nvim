vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.pack")        -- install plugins (vim.pack.add)
require("plugins")            -- per-plugin configs (lua/plugins/*.lua)
require("config.lsp")         -- after blink so its capabilities are available
require("config.keymaps")     -- after plugins so requires resolve
require("config.autocmds")
