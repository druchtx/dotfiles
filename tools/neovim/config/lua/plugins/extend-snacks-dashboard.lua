return {
  "snacks.nvim",
  keys = {},
  opts = function(_, opts)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.enabled = true
    opts.dashboard.sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    }

    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = ""
    opts.dashboard.preset.keys = opts.dashboard.preset.keys or {}

    local filtered = {}
    for _, item in ipairs(opts.dashboard.preset.keys) do
      if not vim.tbl_contains({ "f", "g", "c", "l", "x", "s" }, item.key) then
        table.insert(filtered, item)
      end
    end

    table.insert(
      filtered,
      4,
      { icon = "󰑓", key = "s", desc = "Select Session", action = require("persistence").select }
    )
    table.insert(filtered, 3, { icon = "", key = "e", desc = "Explore", action = ":lua Snacks.explorer()" })

    opts.dashboard.preset.keys = filtered
  end,
}
