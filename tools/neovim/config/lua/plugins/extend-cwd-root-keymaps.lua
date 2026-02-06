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
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (Root Dir)",
    },
    {
      "<leader>e",
      "<leader>fe",
      desc = "Explorer Snacks (cwd)",
      remap = true,
    },
    {
      "<leader>E",
      "<leader>fE",
      desc = "Explorer Snacks (Root Dir)",
      remap = true,
    },
    {
      "<leader>ft",
      function()
        Snacks.terminal()
      end,
      desc = "Terminal (cwd)",
    },
    {
      "<leader>fT",
      function()
        Snacks.terminal(nil, { cwd = LazyVim.root() })
      end,
      desc = "Terminal (Root Dir)",
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
