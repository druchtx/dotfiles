-- Keep the command line directly above the global statusline.
return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
        enabled = true,
        view = "cmdline_popup",
      })

      opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
        cmdline_popup = {
          position = { row = -1, col = 0 },
          size = { width = "100%", height = "auto" },
          border = { style = "none", padding = { 0, 0 } },
        },
      })

      opts.routes = opts.routes or {}
      vim.list_extend(opts.routes, {
        {
          view = "split",
          opts = { enter = true, size = "30%" },
          filter = {
            event = "msg_show",
            kind = { "shell_out", "shell_err", "shell_ret" },
          },
        },
      })
    end,
  },
}
