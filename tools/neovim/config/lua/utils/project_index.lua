-- Project discovery for explicitly configured parent directories.
--
-- Projects are Git repositories below a configured root. Discovery is done
-- when the picker opens, so no cache or background refresh is required.
local M = {}

-- Add a project directory or a directory containing projects here.
---@type string[]
M.roots = {
  vim.env.PROJECTS or "~/projects",
  vim.env.PLAYGROUNDS or "~/playground",
  vim.fs.joinpath(vim.env.HOME, ".dotfiles"),
}

-- A direct child of a root has depth one.
local max_depth = 3

local ignored_dirs = {
  [".venv"] = true,
  ["node_modules"] = true,
  ["target"] = true,
  ["vendor"] = true,
}

---@param path string
---@return string
local function normalize_path(path)
  return vim.fs.normalize(vim.fn.expand(path))
end

---@param path string
---@return boolean
local function has_git(path)
  return vim.uv.fs_stat(vim.fs.joinpath(path, ".git")) ~= nil
end

---@param path string
---@return string[]
local function visible_dirs(path)
  local dirs = {}
  local ok, entries = pcall(vim.fs.dir, path)
  if not ok or not entries then
    return dirs
  end

  for name, kind in entries do
    if kind == "directory" and name:sub(1, 1) ~= "." and not ignored_dirs[name] then
      dirs[#dirs + 1] = vim.fs.joinpath(path, name)
    end
  end

  table.sort(dirs)
  return dirs
end

---@param path string
---@param depth integer
---@param projects string[]
local function find_git_projects(path, depth, projects)
  if has_git(path) then
    projects[#projects + 1] = path
    return
  end

  if depth >= max_depth then
    return
  end

  for _, dir in ipairs(visible_dirs(path)) do
    find_git_projects(dir, depth + 1, projects)
  end
end

---List Git projects below the configured roots.
---@return string[]
function M.projects()
  local projects = {}
  local seen = {}

  for _, root in ipairs(M.roots) do
    if root and root ~= "" then
      root = normalize_path(root)
      if has_git(root) then
        projects[#projects + 1] = root
        seen[root] = true
      else
        for _, first_level in ipairs(visible_dirs(root)) do
          local found = {}
          find_git_projects(first_level, 1, found)

          -- A non-Git direct child is still a useful selectable workspace.
          if #found == 0 then
            found[1] = first_level
          end

          for _, project in ipairs(found) do
            if not seen[project] then
              seen[project] = true
              projects[#projects + 1] = project
            end
          end
        end
      end
    end
  end

  table.sort(projects)
  return projects
end

---Open a project in the current tab workspace.
---@param path string
function M.open(path)
  path = normalize_path(path)
  if vim.fn.isdirectory(path) ~= 1 then
    return
  end

  vim.cmd.tcd(vim.fn.fnameescape(path))
  local tabs = require("utils.tabs")
  tabs.set_project(path)
  tabs.attach_current_tab_buffers()
  require("utils.explorer_layout").open({ cwd = path })
end

---Show the configured projects in Snacks.
function M.pick()
  Snacks.picker.projects({
    dev = {},
    projects = M.projects(),
    recent = false,
    confirm = function(picker, item)
      if not item then
        return
      end

      picker:close()
      M.open(item.file or item.text)
    end,
  })
end

return M
