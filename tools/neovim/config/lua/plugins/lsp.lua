-- Install LSP servers with Mason and enable their Neovim configurations.
return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    -- LSP action: format through the active language server or formatter.
    { "<leader>cf", vim.lsp.buf.format, desc = "Format code" },
  },
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
