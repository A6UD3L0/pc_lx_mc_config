return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, {
        { "<leader>a", group = "+ai/companion" },
        { "<leader>i", group = "+iron/repl" },
        { "<leader>m", group = "+molten/jupyter" },
      })
    end,
  },
}
