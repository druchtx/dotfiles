-- Run external linters and publish their results through vim.diagnostic.
return {
  "mfussenegger/nvim-lint",
  ft = {
    "go",
  },
  config = function()
    local lint = require("lint")

    -- Linters selected for each language.
    lint.linters_by_ft = {
      go = { "golangcilint" },
    }

    -- Run the current language's linters after saving.
    local group = vim.api.nvim_create_augroup("lint_on_save", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
