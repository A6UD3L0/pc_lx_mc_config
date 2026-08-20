-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_python_lsp = 'basedpyright'
vim.g.lazyvim_python_ruff = 'ruff'
vim.g.transparent_enabled = true


-- UI & Display
vim.opt.number = true                  -- Show absolute line numbers
vim.opt.relativenumber = true          -- Use relative line numbers (essential for Vim motions)
vim.opt.cursorline = true              -- Highlight the current line
vim.opt.termguicolors = true           -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"             -- Always show sign column (prevents text shifting)
vim.opt.scrolloff = 15                  -- Keep 8 lines visible above/below the cursor
vim.opt.sidescrolloff = 15              -- Keep 8 columns visible left/right of the cursor
vim.opt.wrap = false                   -- Disable line wrapping for cleaner code structure
vim.opt.breakindent = true             -- Maintain indentation on wrapped lines if wrapping is enabled

-- Searching & Behavior
vim.opt.ignorecase = true              -- Case-insensitive searching...
vim.opt.smartcase = true               -- ...unless capital letters are explicitly used
vim.opt.hlsearch = true                -- Highlight search matches
vim.opt.incsearch = true               -- Show search matches dynamically as you type
vim.opt.mouse = "a"                    -- Enable mouse support across all modes

-- Performance & Timing
vim.opt.updatetime = 250               -- Faster completion and diagnostics update (ms)
vim.opt.timeoutlen = 300               -- Lower time threshold for chorded key sequences (e.g., jk)
vim.opt.lazyredraw = false             -- Set to true if experiencing macro lag

-- System & State (undofile is already handled above)
vim.opt.backup = false                 -- Do not write backup files
vim.opt.writebackup = false            -- Do not write backup files during modification
vim.opt.swapfile = false               -- Disable swap files to prevent clutter
vim.opt.clipboard = "unnamedplus"      -- Sync Neovim clipboard with system clipboard

-- Shell configuration for Windows (use PowerShell)
if vim.fn.has("win32") == 1 then
  vim.opt.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end
