-- Plugin manager: vim.pack (native, since 0.12).
-- Add new plugins to the list below, restart, and they'll be cloned automatically.
-- :h vim.pack    — overview
-- :checkhealth vim.pack — diagnostics
-- vim.pack.update() — interactive update UI

vim.pack.add({
  -- core
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.nvim" },

  -- ui
  { src = "https://github.com/ellisonleao/gruvbox.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/folke/noice.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },

  -- editor
  { src = "https://github.com/mrjones2014/smart-splits.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/kdheepak/lazygit.nvim" },

  -- completion
  -- (nvim-treesitter intentionally dropped: nvim 0.12 ships bundled parsers
  -- for c/lua/markdown/query/vim/vimdoc/diff and starts them automatically
  -- via runtime ftplugins. To add more parsers, install them manually with
  -- tree-sitter-cli into ~/.local/share/nvim-new/site/parser/<lang>.so.)
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("v1") },

  -- formatting
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

  -- LSP server configs (data files for vim.lsp.config)
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- tooling
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})

-- ────────────────────────────── mason (early, so it survives later errors) ──────────────────────────────
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
    "lua-language-server",
    "ltex-ls-plus",
    "marksman",
    "ruff",
    "yaml-language-server",
    -- Linters
    "ansible-lint",
    "gitleaks",
    "golangci-lint",
    "markdownlint-cli2",
    "semgrep",
    "shellcheck",
    -- Formatters
    "gofumpt",
    "goimports",
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
    -- Misc
    "ast-grep",
    "gh",
    "markdown-toc",
    "tfsec",
  },
  auto_update = false,
  run_on_start = true,
  start_delay = 3000,
})

-- ────────────────────────────── colorscheme ──────────────────────────────
require("gruvbox").setup({
  terminal_colors = true,
  undercurl = true,
  underline = true,
  bold = true,
  italic = { strings = false, emphasis = true, comments = true, operators = false, folds = true },
  contrast = "",
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd.colorscheme("gruvbox")

-- ────────────────────────────── mini.* ──────────────────────────────
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()
require("mini.statusline").setup({ use_icons = true })
require("mini.files").setup({
  windows = { preview = true, width_preview = 60 },
  options = { permanent_delete = false },
  mappings = {
    go_in = "l",
    go_in_plus = "<CR>", -- Enter: open file (and close explorer) / enter dir
    go_out = "h",
    go_out_plus = "H",
    close = "q",
    reset = "<BS>",
    show_help = "g?",
    synchronize = "=",
    trim_left = "<",
    trim_right = ">",
    mark_goto = "'",
    mark_set = "m",
  },
})

-- Extra in-explorer bindings: <Esc> to close
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "<Esc>", function()
      require("mini.files").close()
    end, { buffer = args.data.buf_id, desc = "Close explorer" })
  end,
})
require("mini.surround").setup()
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.comment").setup()
require("mini.bufremove").setup()
require("mini.notify").setup({
  window = { config = { border = "rounded" } },
  lsp_progress = { enable = true },
})
vim.notify = require("mini.notify").make_notify()

-- ────────────────────────────── bufferline (tabs for buffers) ──────────────────────────────
require("bufferline").setup({
  options = {
    mode = "buffers",
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(_, _, diag)
      local icons = { error = " ", warning = " " }
      local ret = (diag.error and icons.error .. diag.error .. " " or "")
        .. (diag.warning and icons.warning .. diag.warning or "")
      return vim.trim(ret)
    end,
    offsets = {
      { filetype = "neo-tree", text = "Files", text_align = "center", highlight = "Directory" },
      { filetype = "MiniFiles", text = "Files", text_align = "center", highlight = "Directory" },
    },
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = "thin",
  },
})
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
vim.keymap.set("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Delete other buffers" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete buffers to the right" })
vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete buffers to the left" })

-- ────────────────────────────── noice (cmdline popup, LSP progress, messages) ──────────────────────────────
require("noice").setup({
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
  },
  popupmenu = { enabled = true, backend = "nui" },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    progress = { enabled = true },
    hover = { enabled = true },
    signature = { enabled = false }, -- blink.cmp handles signature
    message = { enabled = true },
  },
  presets = {
    bottom_search = true,         -- classic bottom cmdline for `/`
    command_palette = true,       -- centered popup for `:`
    long_message_to_split = true, -- long messages go to split
    inc_rename = false,
    lsp_doc_border = true,
  },
  messages = {
    enabled = true,
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
    view_history = "messages",
  },
  routes = {
    -- Quiet "no information available" hover
    { filter = { event = "msg_show", kind = "", find = "No information available" }, opts = { skip = true } },
    -- Suppress "written" save spam to bottom-right
    { filter = { event = "msg_show", kind = "", find = "written" }, view = "mini" },
  },
})
vim.keymap.set("n", "<leader>sn", "<cmd>NoiceHistory<cr>", { desc = "Noice history" })
vim.keymap.set("n", "<leader>un", "<cmd>NoiceDismiss<cr>", { desc = "Dismiss notifications" })

-- ────────────────────────────── treesitter ──────────────────────────────
-- No nvim-treesitter. Bundled parsers (c/lua/markdown/markdown_inline/query/
-- vim/vimdoc/diff) are auto-started by Neovim's own ftplugins. For extra
-- languages, install parsers manually: see README.md → "Treesitter parsers".

-- ────────────────────────────── completion ──────────────────────────────
require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-y>"] = { "select_and_accept" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = false },
    list = { selection = { preselect = false, auto_insert = true } },
    menu = { border = "rounded" },
  },
  signature = { enabled = true, window = { border = "rounded" } },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})

-- ────────────────────────────── git ──────────────────────────────
require("gitsigns").setup({
  signs = {
    add = { text = "" },
    change = { text = "󰦓" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "󰘓" },
  },
  signs_staged = {
    add = { text = "" },
    change = { text = "󰦓" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "󰘓" },
  },
  signs_staged_enable = true,
  signcolumn = true,
  numhl = true,
  linehl = true,
  word_diff = false,
  watch_gitdir = { follow_files = true },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 500,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = "<author> (<author_time:%Y-%m-%d %H:%M>) - <summary>",
  sign_priority = 6,
  update_debounce = 100,
  max_file_length = 40000,
  preview_config = { style = "minimal", relative = "cursor", row = 0, col = 1 },
})

-- ────────────────────────────── pickers ──────────────────────────────
require("fzf-lua").setup({
  "default-title",
  winopts = { preview = { default = "bat" } },
  files = { git_icons = true, file_icons = true },
})
-- Route vim.ui.select through fzf-lua. This makes <leader>ca (code actions),
-- vim.lsp.buf.references fallbacks, mason package picker, and any other
-- code calling vim.ui.select() open as a proper centered fuzzy picker
-- instead of the bare "Type number and <Enter>" cmdline prompt.
require("fzf-lua").register_ui_select()

-- ────────────────────────────── editor ──────────────────────────────
require("smart-splits").setup({
  ignored_buftypes = { "nofile", "quickfix", "prompt" },
})

require("which-key").setup({
  preset = "modern",
  spec = {
    { "<leader>b", group = "Buffer" },
    { "<leader>c", group = "Code" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git", icon = { icon = "󰊢", color = "orange" } },
    { "<leader>gh", group = "Hunks" },
    { "<leader>o", group = "Obsidian", icon = { icon = "󰠮", color = "purple" } },
    { "<leader>q", group = "Quarto", icon = { icon = "󰐩", color = "blue" } },
    { "<leader>s", group = "Search" },
    { "<leader>u", group = "UI" },
    { "<leader>w", group = "Window" },
  },
})

-- ────────────────────────────── formatting ──────────────────────────────
require("conform").setup({
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    go = { "goimports", "gofumpt" },
    markdown = { "markdownlint-cli2" },
    json = { "jq" },
    yaml = { "yamlfmt" },
    toml = { "taplo" },
  },
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = { start = { args.line1, 0 }, ["end"] = { args.line2, end_line:len() } }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  end
end, { bang = true })

vim.keymap.set({ "n", "v" }, "<leader>cf", "<cmd>Format<cr>", { desc = "Format" })
vim.keymap.set("n", "<leader>uf", "<cmd>FormatToggle<cr>", { desc = "Toggle autoformat (global)" })
vim.keymap.set("n", "<leader>uF", "<cmd>FormatToggle!<cr>", { desc = "Toggle autoformat (buffer)" })

-- ────────────────────────────── render-markdown ──────────────────────────────
require("render-markdown").setup({
  enabled = true,
  render_modes = { "n", "c", "t" },
  file_types = { "markdown", "mdx" },
  html = { enabled = false },
  latex = { enabled = false },
  yaml = { enabled = false },
  heading = {
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    signs = { "󰫎 " },
    width = "full",
    above = "▄",
    below = "▀",
  },
  code = { style = "full", border = "thin", left_pad = 2, right_pad = 2, above = "▄", below = "▀" },
  bullet = { icons = { "●", "○", "◆", "◇" } },
  checkbox = {
    unchecked = { icon = "󰄱 " },
    checked = { icon = "󰱒 " },
    custom = {
      todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
      important = { raw = "[~]", rendered = "󰓎 ", highlight = "RenderMarkdownWarn" },
    },
  },
  link = { image = "󰥶 ", email = "󰀓 ", hyperlink = "󰌹 ", wiki = { icon = "󱗖 " } },
  indent = { enabled = true, per_level = 2, skip_level = 1 },
})

-- ────────────────────────────── img-clip ──────────────────────────────
require("img-clip").setup({
  default = {
    embed_image_as_base64 = false,
    prompt_for_file_name = true,
    drag_and_drop = { insert_mode = true },
    use_absolute_path = false,
  },
  filetypes = {
    markdown = { url_encode_path = true, template = "![$CURSOR]($FILE_PATH)" },
  },
})
vim.keymap.set("n", "<leader>P", "<cmd>PasteImage<cr>", { desc = "Paste image from clipboard" })

-- ────────────────────────────── mdx ──────────────────────────────
-- mdx.nvim has no setup() — it activates via after/queries and plugin/*.lua.

-- ────────────────────────────── obsidian + templater ──────────────────────────────
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

-- Obsidian keymaps (kept from old config)
local obs_map = function(lhs, cmd, desc)
  vim.keymap.set("n", lhs, cmd, { desc = desc })
end
obs_map("<leader>oo", "<cmd>Obsidian quick_switch<cr>", "Obsidian: quick switch")
obs_map("<leader>oq", "<cmd>Obsidian quick_switch<cr>", "Obsidian: switch note")
obs_map("<leader>od", "<cmd>TemplaterDaily<cr>", "Templater: today")
obs_map("<leader>oy", "<cmd>TemplaterYesterday<cr>", "Templater: yesterday")
obs_map("<leader>oT", "<cmd>TemplaterTomorrow<cr>", "Templater: tomorrow")
obs_map("<leader>oD", "<cmd>Obsidian today<cr>", "Obsidian (native): today")
obs_map("<leader>on", "<cmd>Obsidian new<cr>", "Obsidian: new note")
obs_map("<leader>os", "<cmd>Obsidian search<cr>", "Obsidian: search")
obs_map("<leader>ot", "<cmd>Obsidian tags<cr>", "Obsidian: tags")
obs_map("<leader>ob", "<cmd>Obsidian backlinks<cr>", "Obsidian: backlinks")
obs_map("<leader>ol", "<cmd>Obsidian links<cr>", "Obsidian: links")
obs_map("<leader>oL", "<cmd>Obsidian follow_link<cr>", "Obsidian: follow link")
obs_map("<leader>oi", "<cmd>TemplaterInsert<cr>", "Templater: insert")
obs_map("<leader>oI", "<cmd>Obsidian template<cr>", "Obsidian (native): insert template")
obs_map("<leader>op", "<cmd>Obsidian paste_img<cr>", "Obsidian: paste image")
obs_map("<leader>or", "<cmd>Obsidian rename<cr>", "Obsidian: rename note")
obs_map("<leader>ow", "<cmd>Obsidian workspace<cr>", "Obsidian: switch workspace")
obs_map("<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", "Obsidian: toggle checkbox")

-- ────────────────────────────── quarto ──────────────────────────────
require("quarto").setup({
  lspFeatures = {
    enabled = true,
    chunks = "all",
    languages = { "python", "bash", "lua", "html", "yaml", "json" },
    diagnostics = { enabled = true, triggers = { "BufWritePost" } },
    completion = { enabled = true },
  },
  codeRunner = { enabled = false },
  keymap = { hover = false, definition = false, rename = false, references = false, format = false },
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "quarto", "markdown" },
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "<leader>qp", function()
      require("quarto").quartoPreview()
    end, vim.tbl_extend("force", opts, { desc = "Quarto Preview" }))
    vim.keymap.set("n", "<leader>qc", function()
      require("quarto").quartoClosePreview()
    end, vim.tbl_extend("force", opts, { desc = "Quarto Close Preview" }))
    vim.keymap.set("n", "<leader>qa", function()
      require("quarto").activate()
    end, vim.tbl_extend("force", opts, { desc = "Quarto Activate (otter LSP)" }))
  end,
})

-- ────────────────────────────── rustaceanvim ──────────────────────────────
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        checkOnSave = true,
        check = { command = "clippy", extraArgs = { "--no-deps" } },
        procMacro = {
          enable = true,
          ignored = {
            ["async-trait"] = { "async_trait" },
            ["napi-derive"] = { "napi" },
            ["async-recursion"] = { "async_recursion" },
          },
        },
        inlayHints = {
          bindingModeHints = { enable = false },
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
          closureReturnTypeHints = { enable = "never" },
          lifetimeElisionHints = { enable = "never", useParameterNames = false },
          maxLength = 25,
          parameterHints = { enable = true },
          reborrowHints = { enable = "never" },
          renderColons = true,
          typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
        },
      },
    },
  },
}

-- ────────────────────────────── mason tools ──────────────────────────────
-- mason.setup() runs at the top of this file. Install tools once via :MasonInstall <name>:
--   ansible-language-server ansible-lint ast-grep bash-language-server codelldb
--   delve gh gitleaks gofumpt goimports golangci-lint gomodifytags gopls gotests
--   gotestsum impl ltex-ls-plus lua-language-server markdown-toc markdownlint-cli2
--   marksman ruff basedpyright debugpy iferr semgrep shellcheck shfmt stylua taplo
--   tfsec tree-sitter-cli uv yaml-language-server
