return {
  "Vigemus/iron.nvim",
  keys = {
    { "<leader>ir", "<cmd>IronRepl<cr>", desc = "Start REPL" },
    { "<leader>iR", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
    { "<leader>if", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
    { "<leader>ih", "<cmd>IronHide<cr>", desc = "Hide REPL" },
  },
  main = "iron.core",
  opts = function()
    return {
      config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
          sh = {
            -- Can be a table or a function that
            -- returns a table (see below)
            command = { "pwsh" },
          },
          python = {
            command = { "ipython", "--no-autoindent" },
            format = require("iron.fts.common").bracketed_paste_python,
          },
        },
        -- How the repl window will be displayed
        -- See below for more information
        repl_open_cmd = require("iron.view").split.vertical.botright(40),
      },
      -- Namespaced to <leader>i to avoid random localleader conflicts
      keymaps = {
        send_motion = "<leader>ic",
        visual_send = "<leader>iv",
        send_file = "<leader>iF",
        send_line = "<leader>il",
        send_paragraph = "<leader>ip",
        send_until_cursor = "<leader>iu",
        send_mark = "<leader>im",
        mark_motion = "<leader>imc",
        mark_visual = "<leader>imc",
        remove_mark = "<leader>imd",
        cr = "<leader>i<cr>",
        interrupt = "<leader>i<space>",
        exit = "<leader>iq",
        clear = "<leader>ix",
      },
      -- If the highlight is on, you can change how it looks
      -- For the available options, check nvim_set_hl
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
    }
  end,
}
