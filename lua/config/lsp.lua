-- Native LSP setup using vim.lsp.config / vim.lsp.enable (Neovim 0.11+).
-- Defaults for many servers ship in $VIMRUNTIME/lsp/*.lua — we only override what we need.
-- Servers must be on PATH (install via :MasonInstall or Homebrew).

local caps = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  -- Capabilities advertised by blink.cmp (loaded in plugins.lua before this module).
  (function()
    local ok, blink = pcall(require, "blink.cmp")
    return ok and blink.get_lsp_capabilities() or {}
  end)()
)

-- Apply capabilities to all servers globally.
vim.lsp.config("*", { capabilities = caps })

-- ────────────────────────────── per-server overrides ──────────────────────────────
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        fieldalignment = true,
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
})

vim.lsp.config("basedpyright", {
  -- Pick the interpreter per-project so uv's .venv imports resolve.
  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = require("util.python").path(config.root_dir)
  end,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = false,
        },
      },
    },
  },
})

vim.lsp.config("ruff", {
  init_options = { settings = { logLevel = "error" } },
  -- Disable hover from ruff so basedpyright provides it.
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})

-- harper-ls replaced ltex-ls here. ltex is LanguageTool on a JVM: 1405 MiB RSS
-- and 3657 ms to ready, against 165 MiB and 110 ms for harper's static binary.
--
-- The trade: harper is English-only. Russian *spelling* is still covered — the
-- built-in speller runs on markdown/gitcommit/text/tex (autocmds.lua) with
-- `spelllang = en_us,ru_ru`, and it flagged every Russian typo in the test note
-- that ltex did. What's gone is Russian *grammar*: repeated words, agreement,
-- punctuation. Bring ltex back if that turns out to matter — see README.
--
-- Filetypes come from nvim-lspconfig's shipped list (27 of them, code included,
-- so comments and docstrings get checked too) plus the prose types ltex used to
-- own. Reading it back rather than hardcoding keeps it from drifting.
vim.lsp.config("harper_ls", {
  filetypes = vim.list_extend(vim.deepcopy(vim.lsp.config.harper_ls.filetypes or {}), { "mdx", "text", "rst" }),
  settings = {
    ["harper-ls"] = {
      dialect = "American",
      -- Notes here are Russian with English technical terms sprinkled in. On a
      -- mixed paragraph this cut 6 diagnostics to 2: "Alertmanager" was being
      -- read as a misspelt "Micromanager" and Russian headings drew title-case
      -- complaints. What survives is the real English typo.
      isolateEnglish = true,
      -- "add to dictionary" code actions write to ~/.config/harper-ls/.
      markdown = { IgnoreLinkTitle = true },
    },
  },
})

-- marksman reports diagnostics for the WHOLE workspace, not just open files.
-- In the Obsidian vault that means ~6165 diagnostics for one open note, and
-- Neovim creates a buffer per published URI (`vim.uri_to_bufnr`) — ~2200 of
-- them. bufferline then walks all of it on every tabline redraw: 16.95 ms per
-- redraw and 1363 ms to quit, against 1.24 ms / 22 ms without marksman.
--
-- Inside the vault obsidian.nvim's own server covers the same ground
-- (definition, references, document/workspace symbols, rename, completion),
-- so marksman only starts outside it. Not calling `on_dir` skips the server
-- entirely — see |lsp-root_dir()|.
vim.lsp.config("marksman", {
  filetypes = { "markdown", "mdx" },
  root_dir = function(bufnr, on_dir)
    if require("util.vault").has_buf(bufnr) then
      return
    end
    on_dir(vim.fs.root(bufnr, { ".marksman.toml", ".git" }) or vim.fn.getcwd())
  end,
})

-- ansiblels shipped with `filetypes = { "yaml.ansible" }` only, and nothing in
-- this config ever produces that composite filetype — so the server could never
-- start. `:checkhealth vim.lsp` flagged it as "Unknown filetype 'yaml.ansible'".
--
-- Attaching to plain `yaml` and gating on a project marker beats teaching
-- `vim.filetype.add` to guess which YAML is a playbook: markers are unambiguous
-- and there is nothing to keep in sync. The gate is not optional — without it
-- `vim.lsp.enable` falls back to single-file mode when no marker is found and
-- would spawn the server for every YAML file on the system.
vim.lsp.config("ansiblels", {
  filetypes = { "yaml", "yaml.ansible" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "ansible.cfg", ".ansible-lint", "site.yml", "playbooks" })
    if root then
      on_dir(root)
    end
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = { globals = { "vim", "MiniIcons" } },
      hint = { enable = true },
      telemetry = { enable = false },
    },
  },
})

-- ────────────────────────────── enable servers ──────────────────────────────
-- LSP configs are provided by `nvim-lspconfig` plugin (it ships `lsp/<name>.lua`
-- files on rtp). `vim.lsp.enable(name)` then auto-loads them. Only enable
-- servers whose binary is installed (via :Mason or brew).
vim.lsp.enable({
  "gopls",
  "basedpyright",
  "ruff",
  "harper_ls",
  "marksman",
  "lua_ls",
  "bashls",
  "yamlls",
  "taplo",
  "ansiblels",
  "terraformls",
})
-- rust-analyzer is started by rustaceanvim — do NOT enable it here.

-- ────────────────────────────── LSP-attach keymaps ──────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature help")
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gr", function()
      require("fzf-lua").lsp_references()
    end, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Implementations")
    map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cs", function()
      require("fzf-lua").lsp_document_symbols()
    end, "Symbols (buffer)")
    map("n", "<leader>cS", function()
      require("fzf-lua").lsp_workspace_symbols()
    end, "Symbols (workspace)")
    map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP info")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint", ev.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
