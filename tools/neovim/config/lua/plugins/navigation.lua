-- Navigate seamlessly between Neovim windows and tmux panes.
return {
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      -- Keep every navigation mapping below in one place. The plugin's
      -- built-in terminal mappings would otherwise overwrite these bindings.
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous" },
      -- Terminal mode forwards keys to the shell, so leave it before using
      -- the shared Neovim/tmux navigation commands.
      { "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", mode = "t", desc = "Navigate left" },
      { "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", mode = "t", desc = "Navigate down" },
      { "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", mode = "t", desc = "Navigate up" },
      { "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", mode = "t", desc = "Navigate right" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- Match LazyVim's compact lower-right WhichKey presentation.
      preset = "helix",
      delay = 300,
      spec = {
        { "<leader><tab>", group = "Tab" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>q", group = "Quit" },
        { "<leader>w", group = "Window" },
        { "<leader>R", group = "REST" },
      },
    },
  },
}
