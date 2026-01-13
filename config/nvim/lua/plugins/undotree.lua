-- Undotree: Visual undo history
return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
  },
  config = function()
    -- Open on the left side
    vim.g.undotree_WindowLayout = 3
    -- Set window width
    vim.g.undotree_SplitWidth = 35
    -- Auto-focus when opened
    vim.g.undotree_SetFocusWhenToggle = 1
    -- Short timestamps
    vim.g.undotree_ShortIndicators = 1
    -- Hide diff panel by default (toggle with D)
    vim.g.undotree_DiffAutoOpen = 0
  end,
}
