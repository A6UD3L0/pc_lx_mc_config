-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Ensure Leader Key is Space (LazyVim does this by default, but enforcing explicitly)
vim.g.mapleader = " "

local map = vim.keymap.set

-- Quick exit from insert mode (jk already here, added jj)
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("i", "jj", "<ESC>", { desc = "Exit insert mode" })

-- Navigate code cells (e.g., # %%)
map({ "n", "v" }, "]c", "/# %%<CR><cmd>nohlsearch<CR>", { desc = "Next Code Cell" })
map({ "n", "v" }, "[c", "?# %%<CR><cmd>nohlsearch<CR>", { desc = "Previous Code Cell" })

-- Visual Line Moves (J / K)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Centered Scrolling/Searching
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Prev search result centered" })

-- Void Register Paste
map("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- System Clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Window Navigation (LazyVim handles this, but explicitly redefining as requested)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })
