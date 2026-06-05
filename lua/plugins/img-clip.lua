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
