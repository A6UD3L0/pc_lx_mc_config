return {
  -- Layer 1: Inline suggestions / FIM via minuet
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    config = function()
      require("minuet").setup({
        provider = "gemini",
        provider_options = {
          gemini = {
            model = "gemini-3.7-flash", -- Default model
            stream = true,
            -- It automatically looks for the GEMINI_API_KEY environment variable.
          },
        },
      })

      -- Ordered list of Gemini Flash models for fast, cheap inline recommendations
      local gemini_models = {
        "gemini-3.7-flash",
        "gemini-3.6-flash",
        "gemini-3.5-flash",
        "gemini-3.1-flash-lite",
      }

      -- Keymap to cycle through Gemini models when experiencing 503 high demand
      vim.keymap.set("n", "<leader>af", function()
        local minuet = require("minuet")
        local current = minuet.config.provider_options.gemini.model
        
        -- Find current model in the list
        local idx = 1
        for i, m in ipairs(gemini_models) do
          if m == current then
            idx = i
            break
          end
        end
        
        -- Cycle to the next model, or loop back to the top
        local next_idx = (idx % #gemini_models) + 1
        local next_model = gemini_models[next_idx]
        
        minuet.config.provider_options.gemini.model = next_model
        vim.notify("Minuet model switched to: " .. next_model, vim.log.levels.INFO)
      end, { desc = "Cycle Gemini Fallback Model" })
    end,
  },

  -- Main UI Engine: blink.cmp
  {
    "saghen/blink.cmp",
    dependencies = { "milanglacier/minuet-ai.nvim" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      -- Combine existing default sources with minuet
      if type(opts.sources.default) == "table" then
        if not vim.tbl_contains(opts.sources.default, "minuet") then
          table.insert(opts.sources.default, "minuet")
        end
      else
        opts.sources.default = { "lsp", "path", "snippets", "buffer", "minuet" }
      end

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        score_offset = 100, -- Make minuet suggestions dominate
      }
    end,
  },

  -- Layer 2: Next Edit / AI Assistant
  {
    "folke/sidekick.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- Rely on defaults for visualization and AI integrations
    },
    keys = {
      { "<leader>ae", "<cmd>Sidekick next_edit<cr>", desc = "Sidekick Next Edit" },
      { "<leader>as", "<cmd>Sidekick toggle<cr>", desc = "Sidekick Toggle Terminal" },
    },
  },
}
