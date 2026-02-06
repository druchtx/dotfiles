-- Extend snacks.nvim lazygit configuration
local function quit_terminal(self)
  local job = vim.b[self.buf].terminal_job_id
  if job then
    vim.api.nvim_chan_send(job, "q")
  end
end

return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      -- Fullscreen window (not floating)
      win = {
        -- width = 0, -- 0 means 100% width
        -- height = 0, -- 0 means 100% height
        keys = {
          ["<a-h>"] = { "<a-h>", "hide", mode = { "n", "t" }, desc = "Hide" },
          ["<a-q>"] = { "<a-q>", quit_terminal, mode = { "n", "t" }, desc = "Quit" },
        },
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
