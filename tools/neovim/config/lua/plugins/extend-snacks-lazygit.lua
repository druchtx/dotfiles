return {
  "snacks.nvim",
  opts = {
    lazygit = {
      configure = true,
      win = {
        width = 0,
        height = 0,
      },
      config = {
        os = {
          editPreset = "nvim-remote",
        },
        gui = {
          nerdFontsVersion = "3",
        },
        git = {
          paging = {
            colorArg = "always",
            pager = "delta --dark --paging=never",
          },
        },
      },
    },
  },
}
