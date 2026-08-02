-- Buffer saving belongs to the editor workflow; implementation lives in utils.
return {
  "folke/snacks.nvim",
  keys = {
    {
      "<C-s>",
      function()
        require("utils.buffer_save").sync_and_save()
      end,
      desc = "Sync and Save File",
      mode = { "n", "i" },
    },
  },
}
