local opt = vim.opt
local HOME = os.getenv("HOME")

vim.g.python3_host_prog = HOME .. "/.config/nvim-new/venv/bin/python3"

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = "120"
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

opt.termguicolors = true
opt.background = "dark"
opt.guicursor = "n-v-c:block,i:block,r-cr-o:hor20"

opt.undofile = true
opt.swapfile = false
opt.updatetime = 200
opt.timeoutlen = 300

opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
opt.pumheight = 12
opt.pumblend = 10

opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  space = "·",
  eol = "↴",
  precedes = "«",
  extends = "»",
}
opt.fillchars = { eob = " ", fold = " ", foldopen = "v", foldclose = ">", foldsep = "│" }

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.confirm = true

opt.spell = false
opt.spelllang = { "en_us", "ru_ru" }

vim.g.bigfile_size = 1024 * 1024 * 1024 * 1.5

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".*/templates/.*%.gotmpl"] = "helm",
    [".*/.*%.gotmpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
    spacing = 2,
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  float = { border = "rounded", source = true },
})
