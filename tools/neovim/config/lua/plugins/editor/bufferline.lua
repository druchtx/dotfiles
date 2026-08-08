local function select_tab()
  require("snacks").picker.pick({
    title = "Tabs",
    finder = require("utils.bufferline").tab_items,
    format = "text",
    preview = "none",
    layout = { preset = "select" },
    confirm = function(picker, item)
      picker:close()
      if item and item.tab and vim.api.nvim_tabpage_is_valid(item.tab) then
        vim.api.nvim_set_current_tabpage(item.tab)
      end
    end,
  })
end

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
        select_tab,
        desc = "Select Tab",
      },
    },
    opts = function(_, opts)
      require("utils.bufferline").configure(opts)
    end,
    config = function(_, opts)
      require("bufferline").setup(opts)
      require("utils.bufferline").setup()
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
