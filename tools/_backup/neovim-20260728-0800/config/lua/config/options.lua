-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Line wrapping settings
vim.opt.wrap = true -- Enable line wrapping
vim.opt.linebreak = true -- Wrap at word boundaries, not in middle of words
vim.opt.breakindent = true -- Preserve indentation on wrapped lines
vim.opt.showbreak = "↪ " -- Show arrow at the beginning of wrapped lines

-- Better diff matching for moved/similar lines.
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:60" })
