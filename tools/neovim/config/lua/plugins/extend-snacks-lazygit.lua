-- Extend snacks.nvim lazygit configuration
return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      -- Fullscreen window (not floating)
      win = {
        width = 0, -- 0 means 100% width
        height = 0, -- 0 means 100% height
      },
      -- Force the Neovim-integrated lazygit instance to use the dotfiles-backed config.
      env = {
        LG_CONFIG_FILE = vim.fn.expand("~/.config/lazygit/config.yml"),
      },
      configure = false,
    },
  },
  -- Terminal mode keybindings are set via autocmd (see config/autocmds.lua)
}
