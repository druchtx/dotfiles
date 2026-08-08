-- Go language configuration.
-- This file replaces lazyvim.plugins.extras.lang.go so every Go feature is
-- configured explicitly here.

local go_root_markers = {
  "go.work",
  "go.mod",
  ".golangci.yml",
  ".golangci.yaml",
  ".golangci.toml",
  ".golangci.json",
  ".git",
}

local function go_root(bufnr)
  return require("utils.lsp").root(bufnr, "gopls")
    or require("utils.project").root(bufnr, go_root_markers)
    or vim.fn.getcwd()
end

-- Linting: run golangci-lint for the whole Go module or workspace.
local function golangci_linter()
  -- Reuse nvim-lint's official command, version handling, and JSON parser.
  local official = require("lint.linters.golangcilint")
  local linter = vim.deepcopy(official)
  linter.cwd = go_root(vim.api.nvim_get_current_buf())
  linter.args = vim.deepcopy(official.args or {})

  -- Replace the official current-file target with the whole module/workspace.
  linter.args[#linter.args] = function()
    return "./..."
  end
  linter.append_fname = false

  return linter
end

return {
  -- Syntax highlighting and Treesitter-based code understanding.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "go", "gomod", "gowork", "gosum" },
    },
  },

  -- LSP: completion, navigation, diagnostics, hints, and code actions.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          init_options = {
            semanticTokens = true,
          },
          settings = {
            gopls = {
              -- Use the stricter Go formatter when gopls formats directly.
              gofumpt = true,

              -- Code lenses shown above Go declarations.
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },

              -- Inline type and parameter hints.
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },

              -- Extra gopls analyzers.
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },

              usePlaceholders = true,
              completeUnimported = true,

              -- golangci-lint owns staticcheck diagnostics to avoid duplicates.
              staticcheck = false,

              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            },
          },
        },
      },
      setup = {
        -- Compatibility workaround for gopls semantic tokens.
        gopls = function(_, _)
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if
              client.config
              and client.config.init_options
              and client.config.init_options.semanticTokens
              and not client.server_capabilities.semanticTokensProvider
            then
              local capabilities = client.config.capabilities
              local text_document = capabilities and capabilities.textDocument
              local semantic = text_document and text_document.semanticTokens
              if not semantic then
                return
              end

              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end)
        end,
      },
    },
  },

  -- Tool installation: Mason keeps Go tools available.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        -- Formatters.
        "goimports",
        "gofumpt",
        -- Code actions.
        "gomodifytags",
        "impl",
        -- Linter.
        "golangci-lint",
        -- Debugger.
        "delve",
      })
    end,
  },

  -- Code actions: generate struct tags and interface implementations.
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        null_ls.builtins.code_actions.gomodifytags,
        null_ls.builtins.code_actions.impl,
      })
    end,
  },

  -- Linting: nvim-lint runs golangci-lint after saving.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- Custom linter startup override based on the official definition.
        golangcilint = golangci_linter,
      },
      linters_by_ft = {
        go = { "golangcilint" },
      },
    },
  },

  -- Formatting: Conform runs goimports followed by gofumpt on save.
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.go = { "goimports", "gofumpt" }
    end,
  },

  -- Debugging: Delve integration for nvim-dap.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "leoluz/nvim-dap-go",
        opts = {},
      },
    },
  },

  -- Testing: Neotest adapter for Go tests.
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          dap_go_enabled = true,
        },
      },
    },
  },

  -- Icons for Go-related files and filetypes.
  {
    "nvim-mini/mini.icons",
    opts = {
      file = {
        [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
      },
      filetype = {
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
  },
}
