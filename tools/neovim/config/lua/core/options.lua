-- Native Neovim options shared by every filetype and plugin.

-- User options
-- Visual line wrapping keeps long prose and code readable without hard breaks.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

-- Better diff matching for moved/similar lines.
vim.opt.diffopt:append({ "algorithm:histogram", "linematch:60" })

-- LazyVim patches
-- Preserve visual wrapping: LazyVim sets wrap to false in its defaults, but
-- this configuration intentionally wraps every filetype.
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("dotfiles_patch_lazyvim_options", { clear = true }),
  pattern = "LazyVimOptionsDefaults",
  once = true,
  callback = function()
    vim.opt.wrap = true
  end,
})
