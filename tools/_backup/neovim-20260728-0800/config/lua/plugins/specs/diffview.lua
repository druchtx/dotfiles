return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewCompare", "DiffviewOpenProject" },
  config = function()
    require("plugins.modules.diffview").setup()
  end,
}
