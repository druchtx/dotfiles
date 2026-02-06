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
      -- Use lazygit's default config (~/.config/lazygit/config.yml)
      -- which is symlinked from tools/lazygit/config.yml by dot tool
      configure = false,
    },
  },
  -- Terminal mode keybindings are set via autocmd (see config/autocmds.lua)
}
