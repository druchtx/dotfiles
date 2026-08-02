-- Editing UI configuration. Complex Bufferline behavior lives in `utils` so
-- this file stays focused on plugin declarations and user-facing mappings.
return {
  {
    "akinsho/bufferline.nvim",
    init = function()
      pcall(vim.keymap.del, "n", "<leader>wd")
    end,
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>wq", "<C-W>c", desc = "Close Window", remap = true },
      {
        "<leader><tab>s",
        function()
          require("utils.bufferline").select_tab()
        end,
        desc = "Select Tab",
      },
    },
    opts = function(_, opts)
      require("utils.bufferline").setup_opts(opts)
    end,
    config = function(_, opts)
      require("utils.bufferline").setup(opts)
    end,
  },
  {
    "folke/snacks.nvim",
    -- Override LazyVim's buffer-close keys before its mappings are registered.
    init = function()
      for _, lhs in ipairs({ "<leader>bd", "<leader>bD" }) do
        pcall(vim.keymap.del, "n", lhs)
      end
    end,
    keys = {
      {
        "<leader>bq",
        function()
          Snacks.bufdelete()
        end,
        desc = "Close Buffer",
      },
      { "<leader>bQ", "<cmd>bd<cr>", desc = "Close Buffer and Window" },
    },
  },
}
