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
        position = { row = 1, col = "100%" },
        reverse = false,
        timeout = 3000,
      },
      cmdline_popup = {
        position = { row = -1, col = 0 },
        size = { width = "100%", height = "auto" },
        border = { style = "none", padding = { 0, 0 } },
      },
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "#474557", fg = "#B79FD2" })
  end,
}
