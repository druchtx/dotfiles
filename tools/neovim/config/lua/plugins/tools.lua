-- Ensure external development tools are installed through Mason.
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
  },
  opts = {
    -- Managed formatters, linters and other non-LSP tools.
    ensure_installed = {
      "golangci-lint",
    },
    auto_update = false,
    run_on_start = true,
  },
}
