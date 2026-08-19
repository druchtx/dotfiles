local M = {}

---@class Project
---@field search_paths string[]
---@field max_depth integer
---@field ignored_dirs table<string, boolean>
---@field display_names table<string, string>
local Project = {}
Project.__index = Project

local function normalize_path(path)
  return vim.fs.normalize(vim.fn.expand(path))
end

local function has_git(path)
  return vim.uv.fs_stat(vim.fs.joinpath(path, ".git")) ~= nil
end

local function bare_git_directory(path)
  local result = vim.system({ "git", "-C", path, "rev-parse", "--git-common-dir" }, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  local git_directory = vim.trim(result.stdout or "")
  if git_directory == "" then
    return nil
  end

  if git_directory:sub(1, 1) ~= "/" then
    git_directory = vim.fs.joinpath(path, git_directory)
  end
  git_directory = normalize_path(git_directory)

  local bare_result = vim.system({ "git", "--git-dir", git_directory, "rev-parse", "--is-bare-repository" }, {
    text = true,
  }):wait()
  if bare_result.code == 0 and vim.trim(bare_result.stdout or "") == "true" then
    return git_directory
  end
end

local function visible_dirs(path, ignored_dirs)
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

local function find_git_projects(path, depth, max_depth, ignored_dirs, projects)
  if has_git(path) then
    projects[#projects + 1] = path
    return
  end

  if depth >= max_depth then
    return
  end

  for _, dir in ipairs(visible_dirs(path, ignored_dirs)) do
    find_git_projects(dir, depth + 1, max_depth, ignored_dirs, projects)
  end
end

---@param bufnr integer
---@param markers string[]
---@return string?
function M.root(bufnr, markers)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return nil
  end

  local directory = vim.fs.dirname(filename)
  for _, marker in ipairs(markers) do
    local found = vim.fs.find(marker, { path = directory, upward = true })[1]
    if found then
      return vim.fs.dirname(found)
    end
  end
end

---@param opts? { search_paths?: string[], max_depth?: integer, ignored_dirs?: table<string, boolean> }
---@return Project
function M.new(opts)
  opts = opts or {}
  return setmetatable({
    search_paths = opts.search_paths or {},
    max_depth = opts.max_depth or 3,
    ignored_dirs = opts.ignored_dirs or {},
    display_names = {},
  }, Project)
end

---@return string[]
function Project:projects()
  local projects = {}
  local seen = {}

  for _, search_path in ipairs(self.search_paths) do
    if search_path and search_path ~= "" then
      search_path = normalize_path(search_path)
      if has_git(search_path) then
        projects[#projects + 1] = search_path
        seen[search_path] = true
      else
        for _, first_level in ipairs(visible_dirs(search_path, self.ignored_dirs)) do
          local found = {}
          find_git_projects(first_level, 1, self.max_depth, self.ignored_dirs, found)

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

---Return the name shown for a project in the project picker.
---@param path string
---@return string
function Project:display_name(path)
  path = normalize_path(path)
  if self.display_names[path] then
    return self.display_names[path]
  end

  local name = vim.fs.basename(path)
  local git_directory = bare_git_directory(path)
  if git_directory then
    name = vim.fs.basename(vim.fs.dirname(git_directory))
  end

  self.display_names[path] = name
  return name
end

---@param path string
---@return boolean opened True when the directory became the current tab cwd.
function Project:open(path)
  path = normalize_path(path)
  if vim.fn.isdirectory(path) ~= 1 then
    return false
  end

  vim.cmd.tcd(vim.fn.fnameescape(path))
  return true
end

return M
