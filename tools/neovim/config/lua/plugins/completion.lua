-- Show and combine completion candidates from multiple sources.
return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    -- Personal choices: default keys and required candidate sources.
    keymap = {
      preset = "default",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Keep completion limited to Insert mode.
    cmdline = {
      enabled = false,
    },

    -- Leave bracket insertion to the selected completion item.
    completion = {
      accept = {
        auto_brackets = {
          enabled = false,
        },
      },
    },
  },
}
