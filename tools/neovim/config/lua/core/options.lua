-- Diff
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:60" })

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

-- Use the macOS clipboard locally, while keeping remote SSH sessions isolated.
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
