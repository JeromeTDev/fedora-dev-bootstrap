-- Keymaps are automatically loaded on the VeryLazy event
--
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--jj to escape
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })

-- MarkdownPreview browser
vim.api.nvim_set_keymap("n", "<Leader>m", ":MarkdownPreview<CR>", { noremap = true, silent = true })
