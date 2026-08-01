-- Install LSP servers with Mason and enable their Neovim configurations.
return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "mason-org/mason.nvim",
      opts = {
        -- Prefer tools already selected by the project environment.
        PATH = "append",
      },
    },
    "neovim/nvim-lspconfig",
  },
  opts = {
    -- Managed language servers.
    ensure_installed = { "gopls" },
    automatic_enable = { "gopls" },
  },
}
