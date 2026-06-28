require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "SecondBrain",
      path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain",
      strict = true,
    },
  },
  daily_notes = {
    folder = "05. Дневник/",
    date_format = "%Y/%m/%Y-%m-%d",
    alias_format = "%B %-d, %Y",
    default_tags = { "journal/daily" },
    template = "Ежедневная заметка.md",
  },
  new_notes_location = "/00. Входящие",
  templates = {
    folder = "_Система/1. Шаблоны",
    date_format = "%Y-%m-%d",
    time_format = "%H:%M",
  },
  picker = {
    name = "fzf-lua",
    note_mappings = { new = "<C-x>", insert_link = "<C-l>" },
    tag_mappings = { tag_note = "<C-x>", insert_tag = "<C-l>" },
  },
  ui = { enable = false },
  attachments = {
    folder = "_Система/2. Статика",
    confirm_img_paste = true,
  },
  completion = { min_chars = 3 },
  frontmatter = {
    func = function(note)
      local out = { aliases = note.aliases, tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          if k ~= "id" then
            out[k] = v
          end
        end
      end
      return out
    end,
  },
})

-- Templater user commands (engine in lua/util/templater.lua)
local function tp()
  return require("util.templater")
end
vim.api.nvim_create_user_command("TemplaterInsert", function()
  tp().pick_and_insert()
end, {})
vim.api.nvim_create_user_command("TemplaterDaily", function()
  tp().daily()
end, {})
vim.api.nvim_create_user_command("TemplaterYesterday", function()
  tp().daily({ offset = -1 })
end, {})
vim.api.nvim_create_user_command("TemplaterTomorrow", function()
  tp().daily({ offset = 1 })
end, {})
vim.api.nvim_create_user_command("TemplaterFromName", function(o)
  tp().insert_at_cursor(o.args)
end, { nargs = 1 })

-- Obsidian / Templater keymaps
local map = vim.keymap.set
map("n", "<leader>oo", "<cmd>Obsidian quick_switch<cr>", { desc = "Obsidian: quick switch" })
map("n", "<leader>oq", "<cmd>Obsidian quick_switch<cr>", { desc = "Obsidian: switch note" })
map("n", "<leader>od", "<cmd>TemplaterDaily<cr>", { desc = "Templater: today" })
map("n", "<leader>oy", "<cmd>TemplaterYesterday<cr>", { desc = "Templater: yesterday" })
map("n", "<leader>oT", "<cmd>TemplaterTomorrow<cr>", { desc = "Templater: tomorrow" })
map("n", "<leader>oD", "<cmd>Obsidian today<cr>", { desc = "Obsidian (native): today" })
map("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "Obsidian: new note" })
map("n", "<leader>os", "<cmd>Obsidian search<cr>", { desc = "Obsidian: search" })
map("n", "<leader>ot", "<cmd>Obsidian tags<cr>", { desc = "Obsidian: tags" })
map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "Obsidian: backlinks" })
map("n", "<leader>ol", "<cmd>Obsidian links<cr>", { desc = "Obsidian: links" })
map("n", "<leader>oL", "<cmd>Obsidian follow_link<cr>", { desc = "Obsidian: follow link" })
map("n", "<leader>oi", "<cmd>TemplaterInsert<cr>", { desc = "Templater: insert" })
map("n", "<leader>oI", "<cmd>Obsidian template<cr>", { desc = "Obsidian (native): insert template" })
map("n", "<leader>op", "<cmd>Obsidian paste_img<cr>", { desc = "Obsidian: paste image" })
map("n", "<leader>or", "<cmd>Obsidian rename<cr>", { desc = "Obsidian: rename note" })
map("n", "<leader>ow", "<cmd>Obsidian workspace<cr>", { desc = "Obsidian: switch workspace" })
map("n", "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", { desc = "Obsidian: toggle checkbox" })
