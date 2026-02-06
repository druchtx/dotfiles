return {
  "snacks.nvim",
  opts = function(_, opts)
    local picker_utils = require("shared.snacks_picker")

    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    -- Explorer configuration (4:6 ratio, 85% width, 90% height)
    opts.picker.sources.explorer = {
      auto_close = false,
      hidden = true, -- Show hidden files
      ignored = true, -- Show gitignored files
      exclude = picker_utils.ds_store_exclude,
      on_change = function(picker)
        if picker:is_focused() and picker.resolved_layout.preview == "main" and not picker.preview.win:valid() then
          picker:toggle("preview", { enable = true, focus = picker:current_win() })
        end
      end,
      layout = {
        preset = "sidebar",
        preview = "main",
        hidden = {},
        layout = {
          backdrop = false,
          width = 40,
          min_width = 40,
          height = 0,
          position = "left",
          border = "none",
          box = "vertical",
          {
            win = "input",
            height = 1,
            border = true,
            title = "{flags}",
            title_pos = "center",
          },
          { win = "list", border = "none" },
          {
            win = "preview",
            title = "{preview}",
            height = 0.4,
            border = "top",
          },
        },
      },
      win = {
        input = {
          keys = {
            ["?"] = { "toggle_help_input", mode = { "n", "i" } },
          },
        },
      },
      -- layout = {
      --   preview = true,
      --   layout = {
      --     backdrop = false,
      --     width = 0.85,
      --     height = 0.9,
      --     border = "rounded",
      --     box = "horizontal",
      --     {
      --       box = "vertical",
      --       width = 0.4,
      --       { win = "input", height = 1, border = "rounded", title = "Search" },
      --       { win = "list", border = "rounded", title = "{flags}" },
      --     },
      --     {
      --       win = "preview",
      --       width = 0.6,
      --       border = "rounded",
      --       title = "{preview}",
      --     },
      --   },
      -- },
    }
  end,
}
