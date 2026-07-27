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

-- ── TypeScript / JavaScript ──
-- vtsls over ts_ls: same tsserver underneath, but it exposes
-- `typescript.goToSourceDefinition` (see the `gd` override at the bottom of this
-- file), updates imports when a file is renamed, and takes VS Code's
-- `typescript.*` settings verbatim. Enabling both would mean two tsservers.
--
-- root_dir is deliberately not overridden: the one shipped by nvim-lspconfig
-- anchors on the package-manager lockfile and lets vtsls resolve the per-package
-- tsconfig itself, so a monorepo gets ONE server instead of one per workspace.
-- It also refuses to start next to a deno.json.
local ts_inlay_hints = {
  -- `literals` only: naming every argument, including the ones already passed as
  -- named variables, buries the line in hints.
  parameterNames = { enabled = "literals" },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}

vim.lsp.config("vtsls", {
  settings = {
    -- tsserver ships with inlay hints off, so the `inlay_hint.enable` in LspAttach
    -- below has nothing to show until they're requested here.
    typescript = {
      inlayHints = ts_inlay_hints,
      updateImportsOnFileMove = { enabled = "always" },
      suggest = { completeFunctionCalls = true },
    },
    javascript = { inlayHints = ts_inlay_hints },
    vtsls = {
      -- Use the TypeScript from node_modules, not the one bundled with vtsls —
      -- otherwise diagnostics disagree with what `tsc` in CI reports.
      autoUseWorkspaceTsdk = true,
      experimental = { completion = { enableServerSideFuzzyMatch = true } },
      -- Default heap is ~3 GiB. A large monorepo hits it and tsserver starts
      -- dropping requests instead of erroring, which reads as "LSP got slow".
      tsserver = { maxTsServerMemory = 8192 },
    },
  },
})

-- eslint-lsp rather than eslint in nvim-lint: the server gives code actions and
-- fix-all, a linter integration would only give diagnostics. It runs the eslint
-- from the project's node_modules and stays off in repos without an eslint config.
--
-- Capture the shipped on_attach BEFORE overriding — after `vim.lsp.config()` the
-- field reads back as our own function and wrapping it would recurse. It defines
-- the buffer-local :LspEslintFixAll used below.
local eslint_on_attach = vim.lsp.config.eslint.on_attach
local eslint_fix_group = vim.api.nvim_create_augroup("eslint_fix_on_save", { clear = true })

vim.lsp.config("eslint", {
  on_attach = function(client, bufnr)
    if eslint_on_attach then
      eslint_on_attach(client, bufnr)
    end
    vim.api.nvim_clear_autocmds({ group = eslint_fix_group, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = eslint_fix_group,
      buffer = bufnr,
      callback = function()
        -- Same switches conform's format_on_save honours, so <leader>uf and
        -- <leader>uF silence the formatter and eslint --fix in one move.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        vim.cmd("LspEslintFixAll")
      end,
    })
  end,
})

-- jsonls without schemas is a syntax checker and nothing more. The schemastore.org
-- catalog is what makes tsconfig.json, package.json and friends complete and
-- validate field by field.
local ok_schemastore, schemastore = pcall(require, "schemastore")
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = ok_schemastore and schemastore.json.schemas() or nil,
      validate = { enable = true },
    },
  },
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
  "vtsls",
  "eslint",
  "jsonls",
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

-- In TypeScript `gd` on anything from node_modules lands in a generated .d.ts.
-- vtsls exposes `typescript.goToSourceDefinition`, which resolves the same symbol
-- in the published source when the package ships it. Falls back to the plain
-- definition request when it doesn't (or when the symbol really is a type).
local function goto_source_definition(client, bufnr)
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:exec_cmd({
    command = "typescript.goToSourceDefinition",
    arguments = { params.textDocument.uri, params.position },
  }, { bufnr = bufnr }, function(err, result)
    if err or type(result) ~= "table" or vim.tbl_isempty(result) then
      return vim.lsp.buf.definition()
    end
    if #result == 1 then
      return vim.lsp.util.show_document(result[1], client.offset_encoding, { focus = true, reuse_win = true })
    end
    vim.fn.setqflist({}, " ", {
      title = "Source definitions",
      items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
    })
    require("fzf-lua").quickfix()
  end)
end

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
    -- Call hierarchy: "who calls this" walked recursively, which a flat reference
    -- list can't answer. Both drill down with <CR> inside the picker.
    map("n", "<leader>ci", function()
      require("fzf-lua").lsp_incoming_calls()
    end, "Incoming calls")
    map("n", "<leader>co", function()
      require("fzf-lua").lsp_outgoing_calls()
    end, "Outgoing calls")
    map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP info")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint", ev.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
    if client and client.name == "vtsls" then
      map("n", "gd", function()
        goto_source_definition(client, ev.buf)
      end, "Go to source definition")
    end
  end,
})
