-- Brewfile is Ruby syntax, so LazyVim's ruby extra runs RuboCop on save.
-- Homebrew's DSL is not a RuboCop project and the formatter times out.
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("dotfiles_brewfile_no_format", { clear = true }),
        pattern = "ruby",
        callback = function(args)
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":t")
          if name == "Brewfile" or name:match("^Brewfile%.") then
            vim.b[args.buf].autoformat = false
          end
        end,
      })
    end,
  },
}
