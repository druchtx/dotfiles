return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- make the statusline transparent
    local theme = require("lualine.themes.auto")
    local fg = require("github-theme.palette").load("github_dark_dimmed").fg
    for name, mode in pairs(theme) do
      for _, section in pairs(mode) do
        section.bg = "NONE"
      end
      if mode.a then
        mode.a.fg = name == "inactive" and fg.muted or fg.default
      end
    end

    opts.options.theme = theme

    opts.options.component_separators = { left = "|", right = "|" }
    opts.options.section_separators = { left = "", right = "" }
    opts.sections.lualine_a = {
      {
        "mode",
        -- fmt mode to one character, Normal -> N
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    }
  end,
}
