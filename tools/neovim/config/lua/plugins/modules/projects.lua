local picker_utils = require("shared.snacks_picker")

local M = {}

-- Add parent directories here when the automatic fallback roots are not enough.
-- Only direct child directories are indexed to keep project selection predictable.
M.scan_roots = {}

local fallback_scan_roots = {
  vim.env.PROJECTS,
  "~/dev",
  "~/projects",
}

local cache_file = vim.fn.stdpath("cache") .. "/snacks-projects-cache.json"

local function normalize_path(path)
  return path and vim.fn.fnamemodify(vim.fn.expand(path), ":p"):gsub("/$", "") or nil
end

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

function M.configured_scan_roots()
  local roots = #M.scan_roots > 0 and M.scan_roots or fallback_scan_roots
  return uniq_paths(roots)
end

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

local function write_cache(snapshot)
  local file = io.open(cache_file, "w")
  if not file then
    return
  end
  file:write(vim.json.encode(snapshot))
  file:close()
end

function M.cached_projects()
  local cache = read_cache()
  return type(cache) == "table" and type(cache.projects) == "table" and cache.projects or {}
end

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

function M.refresh_picker_source()
  local picker = require("snacks").picker.get({ source = "projects" })[1]
  M.sync_cache({ picker = picker, force = true })
end

function M.open(path)
  path = normalize_path(path)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return
  end

  vim.cmd.tcd(vim.fn.fnameescape(path))
  local tabs = require("config.tabs")
  tabs.set_project(path)
  tabs.attach_current_tab_buffers()
  require("snacks").picker.explorer({ cwd = path })
end

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
