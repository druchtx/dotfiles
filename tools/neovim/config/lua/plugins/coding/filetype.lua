-- Filetype is part of the coding workflow. LazyVim routes vim.ui.select through
-- Snacks, so this mapping belongs with the Snacks-backed coding UI.
return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fm",
      function()
        vim.ui.select(vim.fn.getcompletion("", "filetype"), {
          prompt = "Select filetype:",
        }, function(choice)
          if choice then
            vim.bo.filetype = choice
          end
        end)
      end,
      desc = "Set filetype",
    },
  },
}
