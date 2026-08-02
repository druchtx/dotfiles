-- Project selection is limited to the explicit roots in utils.project_index.
return {
  "snacks.nvim",
  keys = {
    {
      "<leader>fp",
      function()
        require("utils.project_index").pick()
      end,
      desc = "Projects",
    },
  },
}
