return {
  {
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
        "<cmd>ExplorerCwd<cr>",
        desc = "Explorer Snacks (cwd)",
      },
      {
        "<leader>fE",
        "<cmd>ExplorerRoot<cr>",
        desc = "Explorer Snacks (Root Dir)",
      },
      {
        "<leader>e",
        "<cmd>ExplorerCwd<cr>",
        desc = "Explorer Snacks (cwd)",
      },
      {
        "<leader>E",
        "<cmd>ExplorerRoot<cr>",
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
  },
  -- Share Ctrl-h/j/k/l with tmux so navigation crosses Neovim windows and
  -- tmux panes without changing muscle memory.
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "t" } },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "t" } },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "t" } },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "t" } },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    },
  },
}
