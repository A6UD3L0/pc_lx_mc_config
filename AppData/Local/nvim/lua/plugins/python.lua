return {
  -- Import the LazyVim python extra is now in lazy.lua

  -- Override lspconfig to use BasedPyright (better for ML and type checking) and configure Ruff
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- basedpyright is a community fork of pyright with better type inference, especially useful for ML libraries like pandas/numpy
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
        pyright = {
          -- Disable pyright if basedpyright is used
          enabled = false, 
        },
        -- Ruff for ultra-fast linting and formatting
        ruff = {
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Organize Imports",
            },
          },
        },
      },
      setup = {
        ruff = function()
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == "ruff" then
                client.server_capabilities.hoverProvider = false
              end
            end,
          })
        end,
      },
    },
  },

  -- Configure formatters for "beautiful" formatting on save
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Use ruff for formatting (it's a drop-in replacement for Black but 100x faster)
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
