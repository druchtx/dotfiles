return {
  "akinsho/bufferline.nvim",
  keys = {
    {
      "<leader><tab>s",
      function()
        require("plugins.modules.bufferline").select_tab()
      end,
      desc = "Select Tab",
    },
  },
  opts = function(_, opts)
    require("plugins.modules.bufferline").setup_opts(opts)
  end,
}
