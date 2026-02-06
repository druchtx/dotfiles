-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- GUI Font settings (for Neovide, etc.)
vim.opt.guifont = "Fira Code:h13"
vim.opt.linespace = 2

-- Disable spell checking (doesn't work well with multiple languages)
vim.opt.spell = false

-- Line wrapping settings
vim.opt.wrap = true -- Enable line wrapping
vim.opt.linebreak = true -- Wrap at word boundaries, not in middle of words
vim.opt.breakindent = true -- Preserve indentation on wrapped lines
vim.opt.showbreak = "↪ " -- Show arrow at the beginning of wrapped lines
