return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<CR>", desc = "Initialize Molten" },
      { "<leader>me", "<cmd>MoltenEvaluateOperator<CR>", desc = "Evaluate operator" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<CR>", desc = "Evaluate line" },
      { "<leader>mc", "<cmd>MoltenReevaluateCell<CR>", desc = "Re-evaluate cell" },
      { "<leader>mv", "<cmd><C-u>MoltenEvaluateVisual<CR>gv", mode = "v", desc = "Evaluate visual" },
      { "<leader>md", "<cmd>MoltenDelete<CR>", desc = "Delete cell" },
      { "<leader>mh", "<cmd>MoltenHideOutput<CR>", desc = "Hide Output" },
    },
  }
}
