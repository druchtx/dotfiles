return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      {
        "<leader>or",
        function()
          require("kulala").run()
        end,
        desc = "rest client",
        mode = { "n", "v" },
        ft = { "http", "rest" },
      },
    },
    opts = {
      lsp = {
        enable = true,
        filetypes = { "http", "rest" },
        keymaps = false,
      },
      kulala_keymaps = {
        ["Previous tab"] = {
          "gh",
          function()
            require("kulala.ui").show_previous_tab()
          end,
          mode = { "n" },
        },
        ["Next tab"] = {
          "gl",
          function()
            require("kulala.ui").show_next_tab()
          end,
          mode = { "n" },
        },
      },
    },
  },
}
