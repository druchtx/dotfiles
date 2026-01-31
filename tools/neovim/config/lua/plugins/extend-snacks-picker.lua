return {
  "snacks.nvim",
  opts = function(_, opts)
    -- Enable picker
    opts.picker = opts.picker or {}
    opts.picker.enabled = true

    -- Picker global settings (apply to all sources)
    opts.picker.hidden = true -- Show hidden files in all pickers
    opts.picker.ignored = true -- Show gitignored files in all pickers
    opts.picker.follow = true -- Follow symlinks in all pickers
  end,
}
