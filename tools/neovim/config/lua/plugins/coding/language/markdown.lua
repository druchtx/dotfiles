-- Markdown-only editing defaults. The autocmd is registered during startup,
-- but it only runs when Neovim opens a Markdown buffer.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      local function disable_markdown_spell()
        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("dotfiles_disable_markdown_spell", { clear = true }),
          pattern = "markdown",
          callback = function()
            vim.opt_local.spell = false
          end,
        })

        if vim.bo.filetype == "markdown" then
          vim.opt_local.spell = false
        end
      end

      disable_markdown_spell()

      -- LazyVim registers its text-file defaults on VeryLazy when starting at
      -- the dashboard. Register again afterwards so this user preference wins.
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("dotfiles_markdown_defaults", { clear = true }),
        pattern = "VeryLazy",
        once = true,
        callback = function()
          vim.schedule(disable_markdown_spell)
        end,
      })
    end,
  },

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

  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },

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
