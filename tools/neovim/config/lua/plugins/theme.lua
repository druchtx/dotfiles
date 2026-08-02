-- Keep the default theme close to GitHub's Dark Dimmed appearance.
return {
  "projekt0n/github-nvim-theme",
  lazy = false,
  priority = 1000,
  opts = {
    options = {
      dim_inactive = false,
    },
    -- Match the editor cursor line to Lualine's normal branch background.
    groups = {
      all = {
        CursorLine = { bg = "#2c3e56" },
      },
    },
  },
  config = function(_, opts)
    require("github-theme").setup(opts)
    vim.cmd.colorscheme("github_dark_dimmed")
  end,
}
