local function pick_projects()
  local project = require("utils.project").new({
    search_paths = {
      vim.env.PROJECTS,
      vim.env.PLAYGROUNDS,
      vim.fs.joinpath(vim.env.HOME, ".dotfiles"),
    },
    max_depth = 3,
    ignored_dirs = {
      [".venv"] = true,
      ["node_modules"] = true,
      ["target"] = true,
      ["vendor"] = true,
    },
  })

  require("snacks").picker.projects({
    dev = {},
    projects = project:projects(),
    recent = false,
    confirm = function(picker, item)
      if not item then
        return
      end

      picker:close()
      project:open(item.file or item.text)
    end,
  })
end

return {
  "snacks.nvim",
  init = function()
    vim.api.nvim_create_user_command("ProjectPicker", pick_projects, {})
  end,
  keys = {
    {
      "<leader>fp",
      "<cmd>ProjectPicker<cr>",
      desc = "Projects",
    },
  },
}
