return {
  "snacks.nvim",
  opts = function(_, opts)
    -- opts.picker = opts.picker or {}
    -- opts.picker.focus = "list"
    -- Remove LazyVim dashboard logo/header
    opts.dashboard.preset.header = ""
    table.insert(
      opts.dashboard.preset.keys,
      7,
      { icon = "S", key = "S", desc = "Select Session", action = require("persistence").select }
    )
  end,
}
