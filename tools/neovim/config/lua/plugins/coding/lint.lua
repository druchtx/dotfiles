-- Shared lint behavior. Language-specific linters live under coding/language.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Whole-project linters are intentionally run on save, not InsertLeave.
      events = { "BufWritePost" },
    },
  },
}
