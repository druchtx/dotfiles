-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles_disable_markdown_spell", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Restore the English input source whenever editing returns to Normal mode.
-- The Hammerspoon CLI sends the switch request to the already-running
-- Hammerspoon process through hs.ipc, avoiding a separate input-method tool.
local hammerspoon_cli = "/opt/homebrew/bin/hs"
local english_input_method = "com.apple.keylayout.ABC"

if vim.fn.executable(hammerspoon_cli) == 1 then
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("dotfiles_normal_mode_input_method", { clear = true }),
    desc = "Switch to the English input method after leaving Insert mode",
    callback = function()
      local command = ('return hs.keycodes.currentSourceID("%s")'):format(english_input_method)
      -- Keep the mode transition responsive while Hammerspoon handles the request.
      vim.system({ hammerspoon_cli, "-c", command })
    end,
  })
end
