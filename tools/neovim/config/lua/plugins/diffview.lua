-- Diffview.nvim - Git diff viewer with side-by-side comparison
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy", -- Load early to override LazyVim defaults
  keys = {
    {
      "<leader>gd",
      function()
        local lib = require("diffview.lib")
        local view = lib.get_current_view()
        if view then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Git: Local Changes",
    },
    {
      "<leader>gD",
      "<cmd>DiffviewOpen origin/HEAD<cr>",
      desc = "Git: Diff vs Origin",
    },
    {
      "<leader>gf",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "Git: File History",
    },
    {
      "<leader>gl",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "Git: Commits Log",
    },
    {
      "<leader>gL",
      "<cmd>DiffviewFileHistory --all<cr>",
      desc = "Git: All Branches Log",
    },
  },
  config = function()
    -- Set custom colors for section headers
    vim.api.nvim_set_hl(0, "DiffviewFilePanelTitle", { fg = "#e0af68", bold = true }) -- Orange
    vim.api.nvim_set_hl(0, "DiffviewFilePanelCounter", { fg = "#9ece6a" }) -- Green

    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
      },
    })
  end,
}
