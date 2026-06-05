require("which-key").setup({
  preset = "modern",
  spec = {
    { "<leader>b", group = "Buffer" },
    { "<leader>c", group = "Code" },
    { "<leader>d", group = "Debug", icon = { icon = "󰃤", color = "red" } },
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
