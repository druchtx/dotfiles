-- Workspace persistence. Session filtering and tab-state restoration live in
-- `utils.session`; dashboard, projects, and scratch will join this domain.
return {
  "folke/persistence.nvim",
  init = function()
    pcall(vim.keymap.del, "n", "<leader><tab>d")
  end,
  keys = {
    { "<leader>qS", false },
    { "<leader>qw", function() require("persistence").save() end, desc = "Save Session" },
    { "<leader>qs", function() require("persistence").select() end, desc = "Select Session" },
    { "<leader><tab>q", "<cmd>tabclose<cr>", desc = "Close Tab" },
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)
    local session = require("utils.session")
    session.patch(persistence)
    persistence.select = session.select
  end,
}
