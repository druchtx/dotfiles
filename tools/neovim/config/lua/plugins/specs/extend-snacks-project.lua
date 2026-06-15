return {
  "snacks.nvim",
  opts = function(_, opts)
    return require("plugins.modules.projects").configure_picker(opts or {})
  end,
  init = function()
    vim.api.nvim_create_user_command("SnacksProjectsRefresh", function()
      require("plugins.modules.projects").refresh_picker_source()
    end, {
      desc = "Refresh Snacks projects cache",
    })
  end,
}
