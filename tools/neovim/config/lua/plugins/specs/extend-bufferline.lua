return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    require("plugins.modules.bufferline").setup_opts(opts)
  end,
}
