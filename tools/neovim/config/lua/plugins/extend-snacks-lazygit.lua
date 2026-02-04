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
      -- Configure lazygit with theme integration
      configure = true,
      -- Force using XDG config path (works on both macOS and Linux)
      args = {
        "--use-config-file",
        vim.fn.expand("~/.config/lazygit/config.yml"),
      },
      -- Override theme using highlight groups for better visibility
    },
  },
  -- Terminal mode keybindings are set via autocmd (see config/autocmds.lua)
}
