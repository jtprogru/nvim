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

-- Resolve the Python interpreter for a given project root:
--   1. an activated virtualenv ($VIRTUAL_ENV),
--   2. a project-local .venv (uv's default), searched upward from the root,
--   3. fall back to the pinned Homebrew python.
local function python_path(root)
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and vim.uv.fs_stat(venv .. "/bin/python") then
    return venv .. "/bin/python"
  end
  local hit = vim.fs.find(".venv", {
    path = root or vim.fn.getcwd(),
    upward = true,
    type = "directory",
  })[1]
  if hit and vim.uv.fs_stat(hit .. "/bin/python") then
    return hit .. "/bin/python"
  end
  return "/opt/homebrew/bin/python3"
end

vim.lsp.config("basedpyright", {
  -- Pick the interpreter per-project so uv's .venv imports resolve.
  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = python_path(config.root_dir)
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

vim.lsp.config("ltex_plus", {
  cmd = { "ltex-ls-plus" },
  filetypes = { "markdown", "mdx", "gitcommit", "tex", "plaintex", "rst", "text" },
  settings = {
    ltex = {
      language = "ru-RU",
      additionalRules = { enablePickyRules = true, motherTongue = "ru-RU" },
      dictionary = { ["ru-RU"] = {}, ["en-US"] = {} },
    },
  },
})

vim.lsp.config("marksman", {
  filetypes = { "markdown", "mdx" },
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
  "ltex_plus",
  "marksman",
  "lua_ls",
  "bashls",
  "yamlls",
  "taplo",
  "ansiblels",
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
    map("n", "gr", function() require("fzf-lua").lsp_references() end, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Implementations")
    map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cs", function() require("fzf-lua").lsp_document_symbols() end, "Symbols (buffer)")
    map("n", "<leader>cS", function() require("fzf-lua").lsp_workspace_symbols() end, "Symbols (workspace)")
    map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP info")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint", ev.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
