return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "json",
        "markdown",
      })
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.indent = opts.indent or {}
      opts.indent.enable = true
    end,
  },
}
