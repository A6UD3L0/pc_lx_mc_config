-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Quick exit from insert mode (Standardized to jk to avoid chord lag)
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Navigate code cells (e.g., # %%)
map({ "n", "v" }, "]c", "/# %%<CR><cmd>nohlsearch<CR>", { desc = "Next Code Cell" })
map({ "n", "v" }, "[c", "?# %%<CR><cmd>nohlsearch<CR>", { desc = "Previous Code Cell" })

-- Note: Window navigation (<C-h/j/k/l>), visual indents (<, >), search centering (n, N), 
-- and line moving (<A-j>, <A-k>) are already perfectly configured by LazyVim.
