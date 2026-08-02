-- Markdown-only editing defaults. The autocmd is registered during startup,
-- but it only runs when Neovim opens a Markdown buffer.
return {
  "nvim-treesitter/nvim-treesitter",
  init = function()
    local function disable_markdown_spell()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("dotfiles_disable_markdown_spell", { clear = true }),
        pattern = "markdown",
        callback = function()
          vim.opt_local.spell = false
        end,
      })

      if vim.bo.filetype == "markdown" then
        vim.opt_local.spell = false
      end
    end

    disable_markdown_spell()

    -- LazyVim registers its text-file defaults on VeryLazy when starting at
    -- the dashboard. Register again afterwards so this user preference wins.
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("dotfiles_markdown_defaults", { clear = true }),
      pattern = "VeryLazy",
      once = true,
      callback = function()
        vim.schedule(disable_markdown_spell)
      end,
    })
  end,
}
