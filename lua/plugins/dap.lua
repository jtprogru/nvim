local dap = require("dap")
local dapui = require("dapui")

-- UI: two panels — left (scopes/breakpoints/stacks/watches) + bottom (repl/console)
dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.30 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = { "repl", "console" },
      size = 0.25,
      position = "bottom",
    },
  },
  controls = { enabled = true, element = "repl" },
  floating = { border = "rounded" },
})

require("nvim-dap-virtual-text").setup({
  commented = true,
  highlight_changed_variables = true,
  show_stop_reason = true,
})

-- Auto-open/close UI on session start/end
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- Signs (breakpoint/stopped/rejected/logpoint)
local sign = vim.fn.sign_define
sign("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
sign("DapBreakpointCondition", { text = "◐", texthl = "DiagnosticWarn" })
sign("DapBreakpointRejected", { text = "✗", texthl = "DiagnosticError" })
sign("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
sign("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

-- Language adapters
require("dap-go").setup({
  delve = { detached = vim.fn.has("win32") == 0 },
})

-- debugpy installed by mason lives in its own venv
local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(vim.uv.fs_stat(mason_debugpy) and mason_debugpy or "/opt/homebrew/bin/python3")

-- Rust handled by rustaceanvim — :RustLsp debuggables uses codelldb if installed.
-- We override <leader>dc for rust filetype below to wire that in.

-- Keymaps under <leader>d
local map = vim.keymap.set
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>dB", function()
  vim.ui.input({ prompt = "Condition: " }, function(cond)
    if cond and cond ~= "" then dap.set_breakpoint(cond) end
  end)
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dL", function()
  vim.ui.input({ prompt = "Log message: " }, function(msg)
    if msg and msg ~= "" then dap.set_breakpoint(nil, nil, msg) end
  end)
end, { desc = "Log point" })
map("n", "<leader>dc", function() dap.continue() end, { desc = "Continue / start" })
map("n", "<leader>dC", function() dap.run_to_cursor() end, { desc = "Run to cursor" })
map("n", "<leader>di", function() dap.step_into() end, { desc = "Step into" })
map("n", "<leader>do", function() dap.step_over() end, { desc = "Step over" })
map("n", "<leader>dO", function() dap.step_out() end, { desc = "Step out" })
map("n", "<leader>dj", function() dap.down() end, { desc = "Down stack frame" })
map("n", "<leader>dk", function() dap.up() end, { desc = "Up stack frame" })
map("n", "<leader>dl", function() dap.run_last() end, { desc = "Run last" })
map("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
map("n", "<leader>dq", function() dap.terminate() end, { desc = "Terminate" })
map("n", "<leader>du", function() dapui.toggle() end, { desc = "Toggle UI" })
map({ "n", "v" }, "<leader>de", function() dapui.eval() end, { desc = "Eval expression" })

-- Rust-specific override: use rustaceanvim's debuggables picker
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    vim.keymap.set("n", "<leader>dc", function()
      vim.cmd.RustLsp("debuggables")
    end, { buffer = ev.buf, desc = "Continue (Rust debuggables)" })
  end,
})
