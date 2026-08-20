return {
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      -- Shifted from <C-a> to <leader>aa to preserve Vim's number increment
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Companion Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle Companion Chat" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = "n", desc = "Companion Inline Prompt" },
      { "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to Companion Chat" },
    },
    opts = {
      strategies = {
        chat = { adapter = 'gemini' },
        inline = { adapter = 'gemini' },
        agent = { adapter = 'gemini_cli' },
      },
      adapters = {
        http = {
          gemini = function()
            return require('codecompanion.adapters').extend('gemini', {
              env = { api_key = 'GEMINI_API_KEY' },
              schema = {
                model = {
                  default = 'gemini-3.7-flash',
                },
              },
            })
          end,
        },
        acp = {
          gemini_cli = function()
            return require('codecompanion.adapters').extend('gemini_cli', {
              defaults = { auth_method = 'gemini-api-key' },
            })
          end,
        },
      }
    }
  }
}
