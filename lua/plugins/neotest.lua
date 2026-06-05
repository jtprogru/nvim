require("neotest").setup({
  adapters = {
    require("neotest-golang")({
      runner = "gotestsum", -- mason-installed; falls back to `go test` if absent
      go_test_args = { "-v", "-race", "-count=1" },
    }),
    require("neotest-python")({
      dap = { justMyCode = false },
      runner = "pytest",
      args = { "-vv" },
    }),
    require("neotest-plenary"), -- Lua/busted (plenary.busted) — for nvim plugin tests
  },
  discovery = { enabled = true, concurrent = 1 },
  running = { concurrent = true },
  output = { open_on_run = true },
  quickfix = { open = false },
  status = { virtual_text = true, signs = true },
  summary = {
    animated = true,
    open = "botright vsplit | vertical resize 50",
    mappings = {
      expand = { "<CR>", "l" },
      jumpto = "i",
      output = "o",
      run = "r",
      stop = "u",
      debug = "d",
      mark = "m",
    },
  },
  icons = {
    passed = "✓",
    running = "↻",
    running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
    failed = "✗",
    skipped = "↓",
    unknown = "?",
  },
})

local neotest = require("neotest")
local map = vim.keymap.set
map("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
map("n", "<leader>tT", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run file" })
map("n", "<leader>ta", function() neotest.run.run(vim.uv.cwd()) end, { desc = "Run all" })
map("n", "<leader>tl", function() neotest.run.run_last() end, { desc = "Run last" })
map("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Debug nearest" })
map("n", "<leader>tD", function() neotest.run.run({ vim.fn.expand("%"), strategy = "dap" }) end, { desc = "Debug file" })
map("n", "<leader>tS", function() neotest.run.stop() end, { desc = "Stop" })
map("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle summary" })
map("n", "<leader>to", function() neotest.output.open({ enter = true, auto_close = true }) end, { desc = "Show output" })
map("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = "Toggle output panel" })
map("n", "<leader>tw", function() neotest.watch.toggle(vim.fn.expand("%")) end, { desc = "Watch file" })
map("n", "[t", function() neotest.jump.prev({ status = "failed" }) end, { desc = "Prev failed test" })
map("n", "]t", function() neotest.jump.next({ status = "failed" }) end, { desc = "Next failed test" })

-- Rust-specific overrides: rustaceanvim's :RustLsp testables knows about
-- Cargo workspaces, feature flags, and integration test layout out of the box.
-- neotest doesn't have a maintained Rust adapter.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    vim.keymap.set("n", "<leader>tt", function()
      vim.cmd.RustLsp("testables")
    end, { buffer = ev.buf, desc = "Rust: testables" })
    vim.keymap.set("n", "<leader>tT", function()
      vim.cmd.RustLsp({ "testables", bang = true })
    end, { buffer = ev.buf, desc = "Rust: run all tests in file" })
  end,
})
