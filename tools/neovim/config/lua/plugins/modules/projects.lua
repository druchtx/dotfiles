local picker_utils = require("shared.snacks_picker")

---Project picker and cache integration for Snacks.
---
---The module scans a small set of parent directories, caches direct child
---projects for fast picker startup, and opens selected projects through the
---tab workspace and responsive Explorer entrypoints.

local M = {}

-- Add parent directories here when the automatic fallback roots are not enough.
-- Only direct child directories are indexed to keep project selection predictable.
---@type string[]
M.scan_roots = {}

---Default parent directories used when `M.scan_roots` is empty.
---@type string[]
local fallback_scan_roots = {
  vim.env.PROJECTS,
  "~/dev",
  "~/projects",
}

---JSON cache file used to avoid scanning projects on every picker startup.
---@type string
local cache_file = vim.fn.stdpath("cache") .. "/snacks-projects-cache.json"

---Expand and canonicalize a path.
---@param path? string Path that may contain `~` or environment expansion
---@return string? path Absolute path without a trailing slash
local function normalize_path(path)
  return path and vim.fn.fnamemodify(vim.fn.expand(path), ":p"):gsub("/$", "") or nil
end

---Normalize and deduplicate a path list while preserving first-seen order.
---@param paths string[] Raw path list
---@return string[] paths Unique normalized paths
local function uniq_paths(paths)
  local result = {}
  local seen = {}

  for _, path in ipairs(paths) do
    path = normalize_path(path)
    if path and path ~= "" and not seen[path] then
      seen[path] = true
      result[#result + 1] = path
    end
  end

  return result
end

---Return the configured project scan roots.
---
---Explicit `M.scan_roots` take precedence over fallback roots.
---@return string[] roots Normalized scan roots
function M.configured_scan_roots()
  local roots = #M.scan_roots > 0 and M.scan_roots or fallback_scan_roots
  return uniq_paths(roots)
end

---List direct child directories under one scan root.
---@param root string Normalized parent directory
---@return string[] projects Sorted child project directories
local function child_project_dirs(root)
  local projects = {}
  local ok, iter = pcall(vim.fs.dir, root)
  if not ok or not iter then
    return projects
  end

  for name, kind in iter do
    if kind == "directory" then
      local path = normalize_path(root .. "/" .. name)
      if path and not picker_utils.is_ds_store(path) then
        projects[#projects + 1] = path
      end
    end
  end

  table.sort(projects)
  return projects
end

---Scan all configured roots and build a project snapshot.
---@return table snapshot `{ roots, projects, hash }`
function M.scan()
  local projects = {}

  for _, root in ipairs(M.configured_scan_roots()) do
    if vim.fn.isdirectory(root) == 1 then
      vim.list_extend(projects, child_project_dirs(root))
    end
  end

  projects = uniq_paths(projects)
  return {
    roots = M.configured_scan_roots(),
    projects = projects,
    hash = vim.fn.sha256(table.concat(projects, "\n")),
  }
end

---Read the project cache from disk.
---@return table? snapshot Cached project snapshot, or nil when missing/invalid
local function read_cache()
  local file = io.open(cache_file, "r")
  if not file then
    return nil
  end

  local ok, data = pcall(file.read, file, "*a")
  file:close()
  if not ok or not data or data == "" then
    return nil
  end

  local decoded_ok, decoded = pcall(vim.json.decode, data)
  if not decoded_ok or type(decoded) ~= "table" then
    return nil
  end
  return decoded
end

---Write a project snapshot to the cache file.
---@param snapshot table Project snapshot returned by `M.scan`
local function write_cache(snapshot)
  local file = io.open(cache_file, "w")
  if not file then
    return
  end
  file:write(vim.json.encode(snapshot))
  file:close()
end

---Return cached project paths without forcing a rescan.
---@return string[] projects Cached projects or an empty list
function M.cached_projects()
  local cache = read_cache()
  return type(cache) == "table" and type(cache.projects) == "table" and cache.projects or {}
end

---Synchronize the on-disk cache with the current scan result.
---
---When a picker is supplied, its project list is updated and refiltered only if
---the cache content actually changed.
---@param opts? { picker?: table, force?: boolean }
function M.sync_cache(opts)
  opts = opts or {}
  local picker = opts.picker
  local snapshot = M.scan()
  local cache = read_cache()
  local changed = opts.force == true
    or type(cache) ~= "table"
    or cache.hash ~= snapshot.hash
    or not vim.deep_equal(cache.roots or {}, snapshot.roots)

  if changed then
    write_cache(snapshot)
  end

  if picker and changed then
    picker.opts.projects = snapshot.projects
    picker:find()
  end
end

---Force refresh the active projects picker source, if it is open.
function M.refresh_picker_source()
  local picker = require("snacks").picker.get({ source = "projects" })[1]
  M.sync_cache({ picker = picker, force = true })
end

---Open a project in the current tab workspace.
---
---This updates tab-local cwd/project state, attaches current tab buffers, then
---opens Explorer rooted at the selected project.
---@param path string Project directory
function M.open(path)
  path = normalize_path(path)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return
  end

  vim.cmd.tcd(vim.fn.fnameescape(path))
  local tabs = require("config.tabs")
  tabs.set_project(path)
  tabs.attach_current_tab_buffers()
  require("plugins.modules.explorer").open({ cwd = path })
end

---Configure Snacks' `projects` picker source.
---
---The picker starts with cached projects for responsiveness and refreshes its
---source asynchronously when shown.
---@param opts table Snacks options table
---@return table opts The same options table after mutation
function M.configure_picker(opts)
  opts.picker = opts.picker or {}
  opts.picker.enabled = true
  opts.picker.sources = opts.picker.sources or {}
  opts.picker.sources.projects = vim.tbl_deep_extend("force", opts.picker.sources.projects or {}, {
    dev = {},
    projects = M.cached_projects(),
    recent = true,
    on_show = function(picker)
      vim.schedule(function()
        M.sync_cache({ picker = picker })
      end)
    end,
    confirm = function(picker, item)
      local path = item.file or item.text
      if path and vim.fn.isdirectory(path) == 1 then
        picker:close()
        M.open(path)
      end
    end,
    filter = {
      filter = function(item)
        return not picker_utils.is_ds_store(item.file or item.text)
      end,
    },
  })

  return opts
end

return M
