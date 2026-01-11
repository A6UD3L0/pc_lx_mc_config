-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here
-- NOTE: Molten keymaps are defined in plugins/datascience.lua

local map = vim.keymap.set

-- Exit insert mode with jk
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
