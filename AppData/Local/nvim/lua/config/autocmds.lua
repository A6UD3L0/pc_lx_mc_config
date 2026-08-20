-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight text temporarily on yank (copy)
local yank_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Automatically check if files changed outside of Vim
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "if mode() != 'c' && !getcmdwintype() | checktime | endif",
})

-- Remove trailing whitespaces automatically on save
autocmd("BufWritePre", {
  pattern = "*",
  command = "%s/\\s\\+$//e",
})
