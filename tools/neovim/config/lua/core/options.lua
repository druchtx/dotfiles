-- Diff
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:60" })

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

-- Use the macOS clipboard locally, while keeping remote SSH sessions isolated.
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Default editing policy. Filetype plugins and formatters may override these
-- values when a language has its own indentation or formatting convention.
vim.opt.autowrite = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.formatoptions = "jcroqlnt"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Interface behavior: let Neovim own mouse input, hide redundant built-in
-- indicators, and keep completion menus compact and unobtrusive.
vim.opt.mouse = "a"
vim.opt.conceallevel = 2
vim.opt.list = true
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.ruler = false
vim.opt.showmode = false

-- Fold and separator styling: keep folds expanded by default while retaining
-- indentation-based fold information for manual use.
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.foldcolumn = "0"
vim.opt.fillchars = {
  diff = "╱",
  eob = " ",
}

-- Navigation and command-line defaults.
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.jumpoptions = "view"
vim.opt.shiftround = true
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.splitkeep = "screen"
vim.opt.timeoutlen = 300
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.winminwidth = 5

-- Session state: restore the same workspace context when Persistence reloads.
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Keep Markdown's filetype plugin from replacing the shared indentation policy.
vim.g.markdown_recommended_style = 0

-- Editing safety and history: confirm destructive buffer actions and preserve
-- undo history across Neovim restarts.
vim.opt.confirm = true
vim.opt.undofile = true

-- Search and cursor context: searches ignore case unless a capital is used,
-- and scrolling keeps useful context around the cursor.
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Stable layout: reserve the sign column so diagnostics do not shift text, and
-- open standard splits in the familiar below/right directions.
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Faster idle updates keep diagnostics and Git indicators responsive.
vim.opt.updatetime = 200

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
