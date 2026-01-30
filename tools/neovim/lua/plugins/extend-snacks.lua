return {
  "snacks.nvim",
  opts = function(_, opts)
    -- Picker
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.explorer = opts.picker.sources.explorer or {}

    -- Explorer configuration
    opts.picker.sources.explorer = {
      hidden = true, -- Show hidden files by default
      auto_close = true,
      layout = {
        preview = true, -- Enable preview by default
        layout = {
          backdrop = false,
          width = 0.9, -- Window width (90% of screen)
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

    -- Dashboard
    opts.dashboard.preset.header = ""
    table.insert(
      opts.dashboard.preset.keys,
      7,
      { icon = "S", key = "S", desc = "Select Session", action = require("persistence").select }
    )
  end,
}
