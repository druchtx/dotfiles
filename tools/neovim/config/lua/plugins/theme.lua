-- https://github.com/projekt0n/github-nvim-theme
return {
  "projekt0n/github-nvim-theme",
  name = "github-theme",
  lazy = false,
  priority = 1000,
  config = function()
    require("github-theme").setup({
      options = {
        -- Keep the editor and inactive statusline on the same theme surface.
        transparent = false,
        dim_inactive = false,
      },
    })

    vim.cmd("colorscheme github_dark_dimmed")
  end,
}
