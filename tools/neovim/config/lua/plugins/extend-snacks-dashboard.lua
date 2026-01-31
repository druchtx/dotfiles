return {
  "snacks.nvim",
  opts = function(_, opts)
    -- Enable dashboard
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.enabled = true

    -- Dashboard preset
    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = ""
    opts.dashboard.preset.keys = opts.dashboard.preset.keys or {}
    table.insert(
      opts.dashboard.preset.keys,
      7,
      { icon = "S", key = "S", desc = "Select Session", action = require("persistence").select }
    )
  end,
}
