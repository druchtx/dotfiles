return {
  -- LazyVim's markdown extra adds `markdownlint-cli2` into conform's formatter
  -- chain for markdown. Keep prettier / markdown-toc, but drop markdownlint.
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs({ "markdown", "markdown.mdx" }) do
        local formatters = opts.formatters_by_ft[ft] or {}
        opts.formatters_by_ft[ft] = vim.tbl_filter(function(name)
          return name ~= "markdownlint-cli2"
        end, formatters)
      end
    end,
  },

  -- If nvim-lint is enabled for markdown, clear its markdown linters list so
  -- it does not run markdownlint-cli2 on read/write/insert-leave.
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },

  -- none-ls is the source that was actually publishing markdown diagnostics at
  -- runtime, so filter out the markdownlint source here.
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local filtered = {}

      for _, source in ipairs(opts.sources or {}) do
        if source.name ~= "markdownlint-cli2" and source.name ~= "markdownlint_cli2" then
          table.insert(filtered, source)
        end
      end

      opts.sources = filtered
    end,
  },
}
