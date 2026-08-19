local function pick_projects()
  local snacks = require("snacks")
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

  local function format_project(item, picker)
    local path = item.file
    if type(path) ~= "string" then
      return snacks.picker.format.file(item, picker)
    end

    local name = project:display_name(path)
    if name == vim.fs.basename(path) then
      return snacks.picker.format.file(item, picker)
    end

    local display_item = vim.tbl_extend("force", {}, item, { file = name })
    display_item._path = nil
    return snacks.picker.format.file(display_item, picker)
  end

  snacks.picker.projects({
    dev = {},
    projects = project:projects(),
    recent = false,
    format = format_project,
    confirm = function(picker, item)
      if not item then
        return
      end

      picker:close()
      local path = item.file or item.text
      if project:open(path) then
        snacks.picker.explorer(require("utils.explorer").options({ cwd = path }))
      end
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
