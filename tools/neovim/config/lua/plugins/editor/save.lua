-- Buffer saving belongs to the editor workflow; implementation lives in utils.
return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    require("utils.buffer").setup()
    return opts
  end,
  keys = {
    {
      "<C-s>",
      function()
        require("utils.buffer").save()
      end,
      desc = "Sync and Save File",
      mode = { "n", "i" },
    },
  },
}
