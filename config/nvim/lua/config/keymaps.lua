-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here
-- NOTE: Molten keymaps are defined in plugins/datascience.lua

local map = vim.keymap.set

-- Exit insert mode with jk
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Buffer management
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete buffer (force)" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })
map("n", "<leader>bx", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<S-q>", "<cmd>bdelete<cr>", { desc = "Close buffer (Shift+Q)" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
