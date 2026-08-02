-- Present command input and messages without using Neovim's bottom command line.
return {
  "folke/noice.nvim",
  -- Load before startup plugins so their notifications are retained in history.
  lazy = false,
  priority = 1000,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    messages = {
      enabled = true,
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
    },
    notify = {
      enabled = true,
      view = "mini",
    },
    routes = {
      {
        view = "split",
        opts = { enter = true, size = "30%" },
        filter = {
          event = "msg_show",
          kind = { "shell_out", "shell_err", "shell_ret" },
        },
      },
    },
    commands = {
      history = {
        view = "split",
        opts = { enter = true, format = "details" },
        filter = {},
      },
    },
    views = {
      confirm = {
        position = { row = "50%", col = "50%" },
      },
      mini = {
        position = { row = -1, col = "100%" },
        reverse = true,
        timeout = 3000,
      },
      cmdline_popup = {
        position = { row = -1, col = 0 },
        size = { width = "100%", height = "auto" },
        border = { style = "none", padding = { 0, 0 } },
      },
      -- Keep vim.ui.input prompts, such as Save As, away from the bottom
      -- status area while leaving the regular command line in place.
      cmdline_input = {
        position = { row = "50%", col = "50%" },
        size = { width = 60, height = "auto" },
        border = { style = "rounded", padding = { 0, 1 } },
      },
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#474557", fg = "#B79FD2" })
  end,
}
