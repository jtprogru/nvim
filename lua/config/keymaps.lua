local map = vim.keymap.set

-- Save / quit
map({ "n", "i", "v" }, "<C-s>", "<cmd>silent! w<cr>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })

-- Clear search highlight
map({ "n", "i", "v" }, "<Esc>", function()
  vim.cmd.nohlsearch()
  return "<Esc>"
end, { expr = true })

-- Buffers (kept from old config)
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete buffer (force)" })

-- Window navigation: smart-splits if loaded, else builtin
do
  local ok, ss = pcall(require, "smart-splits")
  if ok then
    map("n", "<C-h>", ss.move_cursor_left, { desc = "Window/pane left" })
    map("n", "<C-j>", ss.move_cursor_down, { desc = "Window/pane down" })
    map("n", "<C-k>", ss.move_cursor_up, { desc = "Window/pane up" })
    map("n", "<C-l>", ss.move_cursor_right, { desc = "Window/pane right" })
  else
    map("n", "<C-h>", "<C-w>h")
    map("n", "<C-j>", "<C-w>j")
    map("n", "<C-k>", "<C-w>k")
    map("n", "<C-l>", "<C-w>l")
  end
end
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete window" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep visual selection on indent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Better up/down on wrapped lines (without count = visual line)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Center on search
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Diagnostics
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- UI toggles
map("n", "<leader>uw", function()
  vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle wrap" })
map("n", "<leader>us", function()
  vim.opt.spell = not vim.opt.spell:get()
end, { desc = "Toggle spell" })
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>ul", function()
  vim.wo.number = not vim.wo.number
end, { desc = "Toggle line numbers" })
map("n", "<leader>uL", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "Toggle relative numbers" })
map("n", "<leader>uW", function()
  vim.wo.list = not vim.wo.list
end, { desc = "Toggle whitespace (list)" })

-- Gitsigns hop (kept binding from old config)
map("n", "<leader>gj", function()
  require("gitsigns").nav_hunk("next")
end, { desc = "Next git hunk" })
map("n", "<leader>gk", function()
  require("gitsigns").nav_hunk("prev")
end, { desc = "Prev git hunk" })
map("n", "]h", function()
  require("gitsigns").nav_hunk("next")
end, { desc = "Next hunk" })
map("n", "[h", function()
  require("gitsigns").nav_hunk("prev")
end, { desc = "Prev hunk" })
map("n", "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Stage hunk" })
map("n", "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })
map("n", "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
map("n", "<leader>ghb", "<cmd>Gitsigns blame_line<cr>", { desc = "Blame line" })
map("n", "<leader>gg", function()
  vim.cmd("LazyGit")
end, { desc = "LazyGit" })

-- Pickers (fzf-lua)
map("n", "<leader><space>", "<cmd>FzfLua files<cr>", { desc = "Find files" })
map("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Git files" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
map("n", "<leader>,", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
map("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Grep word under cursor" })
map("v", "<leader>sw", "<cmd>FzfLua grep_visual<cr>", { desc = "Grep selection" })
map("n", "<leader>sh", "<cmd>FzfLua helptags<cr>", { desc = "Help" })
map("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics (buffer)" })
map("n", "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Diagnostics (workspace)" })
map("n", "<leader>sc", "<cmd>FzfLua command_history<cr>", { desc = "Command history" })
map("n", "<leader>:", "<cmd>FzfLua command_history<cr>", { desc = "Command history" })
map("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume picker" })

-- File explorer (mini.files)
--   <CR>     open file / enter dir
--   l / h    enter dir / go up
--   q / <Esc> close
--   g?       show full help with all bindings
--   gh       toggle hidden files
--   <C-w>v   open in vertical split
--   <C-w>s   open in horizontal split
--   <C-w>t   open in new tab
--   Edit the buffer like text to create/delete/rename, then :w to sync.
map("n", "<leader>e", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
end, { desc = "Explorer (file dir)" })
map("n", "<leader>E", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Explorer (cwd)" })

-- which-key popup (shows current leader-group bindings)
map("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer keymaps (which-key)" })
