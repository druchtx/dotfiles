return {
  "snacks.nvim",
  opts = function(_, opts)
    local picker_utils = require("shared.snacks_picker")
    local explorer = require("plugins.modules.explorer")

    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    opts.picker.sources.explorer = {
      auto_close = false,
      hidden = true, -- Show hidden files
      ignored = true, -- Show gitignored files
      exclude = picker_utils.ds_store_exclude,
      jump = {
        close = explorer.is_float(),
      },
      layout = explorer.layout(),
      win = {
        input = {
          keys = {
            ["?"] = { "toggle_help_input", mode = { "n", "i" } },
          },
        },
      },
    }
  end,
}
