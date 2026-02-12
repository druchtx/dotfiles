return {
  "snacks.nvim",
  opts = function(_, opts)
    -- Enable picker
    opts.picker = opts.picker or {}
    opts.picker.enabled = true

    -- Global defaults (conservative - exclude hidden/ignored by default)
    opts.picker.hidden = false
    opts.picker.ignored = false
    opts.picker.follow = true -- Follow symlinks

    -- Source-specific overrides
    opts.picker.sources = opts.picker.sources or {}

    -- File pickers: show hidden and gitignored files
    opts.picker.sources.files = {
      hidden = true,
      ignored = true,
    }

    -- Grep/search: exclude hidden and gitignored files (use defaults)
    opts.picker.sources.grep = {
      hidden = false,
      ignored = false,
    }
  end,
}
