return {
  "snacks.nvim",
  opts = function(_, opts)
    local ds_store_exclude = {
      ".DS_Store",
      "**/.DS_Store",
    }

    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    -- Explorer configuration (4:6 ratio, 85% width, 90% height)
    opts.picker.sources.explorer = {
      auto_close = true,
      hidden = true,   -- Show hidden files
      ignored = true,  -- Show gitignored files
      exclude = ds_store_exclude,
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
