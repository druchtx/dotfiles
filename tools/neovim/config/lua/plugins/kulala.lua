return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send HTTP request" },
    { "<leader>Ra", "<cmd>lua require('kulala').run_all()<cr>", desc = "Send all HTTP requests" },
    { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open HTTP scratchpad" },
  },
  opts = {
    ui = {
      display_mode = "split",
      split_direction = "right",
    },
  },
}
