return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options.component_separators = { left = "|", right = "|" }
    opts.options.section_separators = { left = "", right = "" }
    -- table.insert(opts.sections.lualine_x, 2, LazyVim.lualine.cmp_source("codeium"))
    opts.sections.lualine_a = {
      {
        "mode",
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    }
  end,
}
