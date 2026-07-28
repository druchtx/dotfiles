return {
  "snacks.nvim",
  keys = {
    {
      "<leader>/",
      LazyVim.pick("grep", { root = false }),
      desc = "Grep (cwd)",
    },
    {
      "<leader><space>",
      LazyVim.pick("files", { root = false }),
      desc = "Find Files (cwd)",
    },
    {
      "<leader>ff",
      LazyVim.pick("files", { root = false }),
      desc = "Find Files (cwd)",
    },
    {
      "<leader>fF",
      LazyVim.pick("files"),
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>fe",
      function()
        require("plugins.modules.explorer").open()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    {
      "<leader>fE",
      function()
        require("plugins.modules.explorer").open({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (Root Dir)",
    },
    {
      "<leader>e",
      function()
        require("plugins.modules.explorer").open()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    {
      "<leader>E",
      function()
        require("plugins.modules.explorer").open({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (Root Dir)",
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit (cwd)",
    },
    {
      "<leader>gG",
      function()
        Snacks.lazygit({ cwd = LazyVim.root.git() })
      end,
      desc = "Lazygit (Root Dir)",
    },
    {
      "<leader>sg",
      LazyVim.pick("live_grep", { root = false }),
      desc = "Grep (cwd)",
    },
    {
      "<leader>sG",
      LazyVim.pick("live_grep"),
      desc = "Grep (Root Dir)",
    },
    {
      "<leader>sw",
      LazyVim.pick("grep_word", { root = false }),
      desc = "Visual selection or word (cwd)",
      mode = { "n", "x" },
    },
    {
      "<leader>sW",
      LazyVim.pick("grep_word"),
      desc = "Visual selection or word (Root Dir)",
      mode = { "n", "x" },
    },
  },
}
