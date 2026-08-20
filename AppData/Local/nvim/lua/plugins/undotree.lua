return {
  "mbbill/undotree",
  keys = {
    -- Toggle Undotree with <leader>uu to avoid conflict with LazyVim's <leader>u UI toggles
    { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undotree Toggle" },
  },
  init = function()
    -- Layout 3: right side
    vim.g.undotree_WindowLayout = 3
    -- Fix Windows "diff not executable" error by using git's built-in diff
    vim.g.undotree_DiffCommand = "git diff --no-index"
  end,
}
