return {
  "snacks.nvim",
  opts = function(_, opts)
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    -- Explorer configuration (4:6 ratio, 85% width, 90% height)
    opts.picker.sources.explorer = {
      auto_close = true,
      layout = {
        preview = true,
        layout = {
          backdrop = false,
          width = 0.85,
          height = 0.9,
          border = "rounded",
          box = "horizontal",
          {
            box = "vertical",
            width = 0.4,
            { win = "input", height = 1, border = "rounded", title = "Search" },
            { win = "list", border = "rounded", title = "{flags}" },
          },
          {
            win = "preview",
            width = 0.6,
            border = "rounded",
            title = "{preview}",
          },
        },
      },
    }
  end,
}
