-- File explorer as a persistent sidebar on the RIGHT.
--
-- The side is the whole point: with the tree on the right the text area keeps
-- its left edge fixed, so toggling the explorer never shifts the code you are
-- reading. bufferline needs no extra config for this — its offset code derives
-- left/right from the window layout (see plugins/bufferline.lua).
--
-- Icons come from mini.icons via MiniIcons.mock_nvim_web_devicons() in
-- plugins/mini.lua, hence this file loads after "mini" in plugins/init.lua.
-- plenary.nvim and nui.nvim (hard deps) are already in config/pack.lua.

require("neo-tree").setup({
  -- Quitting the last real buffer should not leave a lone sidebar behind.
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  -- Opening a file from the tree must not hijack these windows.
  open_files_do_not_replace_types = { "terminal", "qf", "notify", "trouble" },

  window = {
    position = "right",
    width = 34,
    mappings = {
      -- <space> is the leader. Left bound to toggle_node it makes every leader
      -- chord inside the tree wait for timeoutlen before firing.
      ["<space>"] = "none",
      -- mini.files muscle memory: l enters, h goes back up.
      ["l"] = "open",
      ["h"] = "close_node",
      ["<Esc>"] = "close_window",
      -- Everything else is the neo-tree default: a/A add file/dir, d delete,
      -- r rename, c copy, m move, x/y/p cut/copy/paste, H toggle hidden,
      -- / fuzzy filter, R refresh, S/s split/vsplit, t tab, ? help.
    },
  },

  filesystem = {
    -- Root stays where the tree was opened; :cd elsewhere does not yank it away.
    bind_to_cwd = false,
    follow_current_file = { enabled = true, leave_dirs_open = false },
    -- inotify/FSEvents instead of polling: external changes show up at once.
    use_libuv_file_watcher = true,
    -- `nvim some/dir` and :edit on a directory open the tree instead of netrw.
    hijack_netrw_behavior = "open_default",
    filtered_items = {
      visible = false,
      -- This is a dotfiles repo — .github/, .stylua.toml, .githooks/ are work
      -- files, not noise. `H` still toggles the filter.
      hide_dotfiles = false,
      hide_gitignored = true,
      never_show = { ".git", ".DS_Store" },
    },
  },

  buffers = {
    follow_current_file = { enabled = true, leave_dirs_open = false },
  },
})

local map = vim.keymap.set
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorer (toggle)" })
map("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Explorer (reveal file)" })
