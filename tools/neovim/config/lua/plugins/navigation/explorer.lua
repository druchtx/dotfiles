-- Configure Snacks Explorer. The custom layout policy is shared by Explorer
-- entrypoints through the independently named Explorer layout feature.
return {
  "snacks.nvim",
  opts = function(_, opts)
    local explorer = require("utils.explorer_layout")
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.explorer = {
      auto_close = false,
      hidden = true,
      ignored = true,
      exclude = { ".DS_Store", "**/.DS_Store" },
      jump = { close = explorer.is_float() },
      layout = explorer.layout(),
      win = {
        input = { keys = { ["?"] = { "toggle_help_input", mode = { "n", "i" } } } },
      },
    }
  end,
}
