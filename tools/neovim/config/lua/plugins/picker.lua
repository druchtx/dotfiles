-- Find files, search text and switch loaded buffers.
return {
  "folke/snacks.nvim",
  version = "*",
  lazy = false,
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.files()
      end,
      desc = "Find files",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Find files",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.grep()
      end,
      desc = "Search text",
    },
    {
      "<leader>sg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Search text",
    },
    {
      "<leader>,",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Switch buffer",
    },
    {
      "<leader>bs",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Switch buffer",
    },
    {
      "<leader>fp",
      function()
        require("features.projects").pick()
      end,
      desc = "Find projects",
    },
  },
  opts = {
    -- Noice owns vim.notify so notifications remain available in :Noice history.
    notifier = { enabled = false },
    picker = {
      enabled = true,

      -- <A-w> uses the built-in mapping to cycle input, list and preview.
      win = {
        input = {
          keys = {
            ["<A-q>"] = { "close", mode = { "n", "i" } },
          },
        },
        list = {
          keys = {
            ["<A-q>"] = "close",
          },
        },
        preview = {
          keys = {
            ["<A-q>"] = "close",
          },
        },
      },
    },
  },
}
