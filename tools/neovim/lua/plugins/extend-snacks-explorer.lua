return {
  "snacks.nvim",
  opts = function(_, opts)
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    -- Explorer
    opts.picker.sources.explorer = {
      auto_close = true,
      layout = {
        preview = true, -- Enable preview by default
        layout = {
          backdrop = false,
          width = 0.99, -- Window width (99% of screen)
          height = 0.9, -- Window height (90% of screen)
          border = "rounded",
          box = "horizontal", -- Horizontal layout (preview on right)
          {
            -- Left side: input + list
            box = "vertical",
            width = 0.4, -- List area takes 40% width
            {
              win = "input",
              height = 1, -- Small height for search input
              border = "rounded",
              title = "Search",
            },
            {
              win = "list",
              border = "rounded",
              title = "{flags}",
            },
          },
          {
            -- Right side: preview
            win = "preview",
            width = 0.6, -- Preview takes 60% width
            border = "rounded",
            title = "{preview}",
          },
        },
      },
    }
  end,
}
