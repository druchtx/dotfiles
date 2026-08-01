-- Select a project and use it as the current Tabpage workspace.
local M = {}

-- Add a project or a directory containing projects here.
local project_roots = {
  vim.env.PROJECTS or "~/projects",
  vim.fs.joinpath(vim.env.HOME, ".dotfiles"),
}

-- Depth includes the direct child of a project root as level 1.
local max_depth = 3

local ignored_dirs = {
  ["node_modules"] = true,
  ["vendor"] = true,
  [".venv"] = true,
  ["target"] = true,
}

local function normalize(path)
  return vim.fs.normalize(vim.fn.expand(path))
end

local function has_git(path)
  return vim.uv.fs_stat(path .. "/.git") ~= nil
end

local function visible_dirs(path)
  local dirs = {}
  local ok, entries = pcall(vim.fs.dir, path)

  if not ok or not entries then
    return dirs
  end

  for name, kind in entries do
    if kind == "directory" and name:sub(1, 1) ~= "." and not ignored_dirs[name] then
      dirs[#dirs + 1] = path .. "/" .. name
    end
  end

  table.sort(dirs)
  return dirs
end

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

local function project_dirs()
  local projects = {}
  local seen = {}

  for _, configured_root in ipairs(project_roots) do
    if configured_root and configured_root ~= "" then
      local root = normalize(configured_root)

      if has_git(root) then
        if not seen[root] then
          seen[root] = true
          projects[#projects + 1] = root
        end
      else
        for _, first_level in ipairs(visible_dirs(root)) do
          local found = {}
          find_git_projects(first_level, 1, found)

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

function M.pick()
  Snacks.picker.projects({
    dev = {},
    projects = project_dirs(),
    recent = false,
    confirm = function(picker, item)
      if not item then
        return
      end

      local project = item.file or item.text
      picker:close()
      vim.cmd.tcd(vim.fn.fnameescape(project))
      vim.cmd("Neotree filesystem show right dir=" .. vim.fn.fnameescape(project))
    end,
  })
end

return M
