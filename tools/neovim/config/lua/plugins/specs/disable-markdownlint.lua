return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local filtered = {}

      for _, source in ipairs(opts.sources or {}) do
        if source.name ~= "markdownlint_cli2" then
          table.insert(filtered, source)
        end
      end

      opts.sources = filtered
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },
}
