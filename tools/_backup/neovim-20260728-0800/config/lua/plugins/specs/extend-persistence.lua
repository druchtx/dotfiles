return {
  "folke/persistence.nvim",
  keys = {
    { "<leader>qS", false },
    {
      "<leader>qw",
      function()
        require("persistence").save()
      end,
      desc = "Save Session",
    },
    {
      "<leader>qs",
      function()
        require("persistence").select()
      end,
      desc = "Select Session",
    },
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)
    require("plugins.modules.sessions").patch(persistence)
    persistence.select = require("plugins.modules.sessions").select
  end,
}
