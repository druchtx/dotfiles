local function apply_indent_highlights()
  vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#30363d", bg = "NONE" })
  vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#8b949e", bg = "NONE" })
end

return {
  "snacks.nvim",
  opts = function(_, opts)
    opts.indent = opts.indent or {}
    opts.indent.indent = vim.tbl_deep_extend("force", opts.indent.indent or {}, {
      char = "▏",
      hl = "SnacksIndent",
    })
    opts.indent.scope = vim.tbl_deep_extend("force", opts.indent.scope or {}, {
      char = "│",
      hl = "SnacksIndentScope",
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("snacks_indent_rainbow", { clear = true }),
      callback = apply_indent_highlights,
    })

    vim.schedule(apply_indent_highlights)
  end,
}
