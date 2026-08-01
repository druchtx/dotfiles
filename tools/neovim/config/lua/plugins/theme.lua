-- Keep the default theme close to GitHub's Dark Dimmed appearance.
return {
  "projekt0n/github-nvim-theme",
  lazy = false,
  priority = 1000,
  opts = {
    options = {
      dim_inactive = false,
    },
  },
  config = function(_, opts)
    require("github-theme").setup(opts)
    vim.cmd.colorscheme("github_dark_dimmed")
  end,
}
