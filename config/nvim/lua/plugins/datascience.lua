-- Data Science plugins for LazyVim
return {
  -- Molten.nvim: Jupyter Notebooks in Neovim
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    ft = { "python", "quarto", "markdown" },
    dependencies = {
      "3rd/image.nvim",
    },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_wrap_output = true
      vim.g.molten_auto_open_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    config = function()
      -- Function to find cell boundaries using # %% markers
      local function get_cell_range()
        local current_line = vim.fn.line(".")
        local start_line = current_line
        local end_line = current_line
        local total_lines = vim.fn.line("$")

        -- Search backward for # %% or start of file
        for i = current_line, 1, -1 do
          local line = vim.fn.getline(i)
          if line:match("^# ?%%%%") then
            start_line = i + 1
            break
          elseif i == 1 then
            start_line = 1
          end
        end

        -- Search forward for next # %% or end of file
        for i = current_line + 1, total_lines do
          local line = vim.fn.getline(i)
          if line:match("^# ?%%%%") then
            end_line = i - 1
            break
          elseif i == total_lines then
            end_line = total_lines
          end
        end

        -- Handle case where cursor is on # %% line
        if vim.fn.getline(current_line):match("^# ?%%%%") then
          start_line = current_line + 1
          for i = current_line + 1, total_lines do
            local line = vim.fn.getline(i)
            if line:match("^# ?%%%%") then
              end_line = i - 1
              break
            elseif i == total_lines then
              end_line = total_lines
            end
          end
        end

        return start_line, end_line
      end

      -- Evaluate current cell (# %% delimited)
      vim.api.nvim_create_user_command("MoltenEvaluateCell", function()
        local start_line, end_line = get_cell_range()
        if start_line <= end_line then
          vim.fn.MoltenEvaluateRange(start_line, end_line)
        end
      end, { desc = "Evaluate current cell" })

      -- Navigate to next cell
      vim.api.nvim_create_user_command("MoltenNextCell", function()
        local current_line = vim.fn.line(".")
        local total_lines = vim.fn.line("$")
        for i = current_line + 1, total_lines do
          if vim.fn.getline(i):match("^# ?%%%%") then
            vim.cmd(tostring(i))
            return
          end
        end
      end, { desc = "Go to next cell" })

      -- Navigate to previous cell
      vim.api.nvim_create_user_command("MoltenPrevCell", function()
        local current_line = vim.fn.line(".")
        for i = current_line - 1, 1, -1 do
          if vim.fn.getline(i):match("^# ?%%%%") then
            vim.cmd(tostring(i))
            return
          end
        end
      end, { desc = "Go to previous cell" })
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Molten Init Kernel" },
      { "<leader>me", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten Evaluate Operator" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten Evaluate Line" },
      { "<leader>mv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Molten Evaluate Visual" },
      { "<leader>mc", "<cmd>MoltenEvaluateCell<cr>", desc = "Molten Evaluate Cell (# %%)" },
      { "<leader>mC", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten Re-evaluate Cell" },
      { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Molten Delete Cell" },
      { "<leader>mo", "<cmd>MoltenShowOutput<cr>", desc = "Molten Show Output" },
      { "<leader>mh", "<cmd>MoltenHideOutput<cr>", desc = "Molten Hide Output" },
      { "<leader>mx", "<cmd>MoltenInterrupt<cr>", desc = "Molten Interrupt Kernel" },
      { "<leader>mr", "<cmd>MoltenRestart!<cr>", desc = "Molten Restart Kernel" },
      { "<leader>ms", "<cmd>MoltenSave<cr>", desc = "Molten Save" },
      { "<leader>mL", "<cmd>MoltenLoad<cr>", desc = "Molten Load" },
      { "<leader>mn", "<cmd>MoltenNextCell<cr>", desc = "Next Cell" },
      { "<leader>mp", "<cmd>MoltenPrevCell<cr>", desc = "Previous Cell" },
      { "<leader>ma", "<cmd>MoltenEvaluateCell<cr><cmd>MoltenNextCell<cr>", desc = "Run Cell & Advance" },
    },
  },

  -- image.nvim: Terminal image rendering (sixel backend for Docker/tmux)
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki", "quarto" },
        },
      },
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = 50,
      max_width_window_percentage = nil,
      window_overlap_clear_enabled = true,
      tmux_show_only_in_active_window = true,
    },
    config = function(_, opts)
      local ok, err = pcall(function()
        require("image").setup(opts)
      end)
      if not ok then
        vim.notify("image.nvim: " .. tostring(err), vim.log.levels.WARN)
      end
    end,
  },

  -- Quarto support for literate programming
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        languages = { "python", "r", "julia" },
        chunks = "all",
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
  },

  -- Otter.nvim: LSP for embedded code in markdown/quarto
  {
    "jmbuhr/otter.nvim",
    ft = { "quarto", "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- OSC52 clipboard (works in Docker/SSH/tmux)
  {
    "ojroques/nvim-osc52",
    event = "VeryLazy",
    config = function()
      local function copy()
        if vim.v.event.operator == "y" or vim.v.event.operator == "d" then
          require("osc52").copy_register("+")
        end
      end
      vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
    end,
  },
}
