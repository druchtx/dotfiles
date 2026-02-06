local picker_utils = require("shared.snacks_picker")

-- User-configurable project roots.
-- Fill this with one or more parent directories whose immediate subdirectories
-- should appear in the projects picker.
-- Example:
-- local project_scan_roots = {
--   "~/work",
--   "~/personal",
-- }
local project_scan_roots = {}

-- Used only when `project_scan_roots` is empty.
local fallback_project_scan_roots = {
  vim.env.PROJECTS,
  "~/dev",
  "~/projects",
}

local cache_file = vim.fn.stdpath("cache") .. "/snacks-projects-cache.json"

local function uniq_paths(paths)
  local ret = {}
  local seen = {}

  for _, path in ipairs(paths) do
    if path and path ~= "" then
      local expanded = vim.fn.expand(path):gsub("/$", "")
      if expanded ~= "" and seen[expanded] ~= true then
        seen[expanded] = true
        ret[#ret + 1] = expanded
      end
    end
  end

  return ret
end

local function configured_scan_roots()
  local roots = #project_scan_roots > 0 and project_scan_roots or fallback_project_scan_roots
  return uniq_paths(roots)
end

local function scan_projects()
  local projects = {}

  for _, root in ipairs(configured_scan_roots()) do
    if vim.fn.isdirectory(root) == 1 then
      local handle = io.popen(string.format([[find "%s" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort]], root))
      if handle then
        for raw_path in handle:lines() do
          local path = raw_path:gsub("/$", "")
          if vim.fn.isdirectory(path) == 1 and not picker_utils.is_ds_store(path) then
            projects[#projects + 1] = path
          end
        end
        handle:close()
      end
    end
  end

  projects = uniq_paths(projects)
  return {
    roots = configured_scan_roots(),
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

  local decoded = vim.json.decode(data)
  if type(decoded) ~= "table" then
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

local function cached_projects()
  local cache = read_cache()
  return type(cache) == "table" and type(cache.projects) == "table" and cache.projects or {}
end

local function sync_projects_cache(opts)
  opts = opts or {}
  local picker = opts.picker
  local force = opts.force == true

  local snapshot = scan_projects()
  local cache = read_cache()
  local changed = force
    or type(cache) ~= "table"
    or cache.hash ~= snapshot.hash
    or vim.deep_equal(cache.roots or {}, snapshot.roots) ~= true

  if changed then
    write_cache(snapshot)
  end

  if picker and changed then
    picker.opts.projects = snapshot.projects
    picker:find()
  end
end

local function refresh_project_source()
  local Snacks = require("snacks")
  local picker = Snacks.picker.get({ source = "projects" })[1]
  sync_projects_cache({ picker = picker, force = true })
end

return {
  "snacks.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.picker = opts.picker or {}
    opts.picker.enabled = true
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.projects = vim.tbl_deep_extend("force", opts.picker.sources.projects or {}, {
      dev = {},
      projects = cached_projects(),
      recent = true,
      on_show = function(picker)
        vim.schedule(function()
          sync_projects_cache({ picker = picker })
        end)
      end,
      confirm = function(picker, item)
        local path = item.file or item.text
        if path and vim.fn.isdirectory(path) == 1 then
          picker:close()
          vim.fn.chdir(path)
          require("snacks").picker.explorer({ cwd = path })
        end
      end,
      filter = {
        filter = function(item)
          return not picker_utils.is_ds_store(item.file or item.text)
        end,
      },
    })

    return opts
  end,
  init = function()
    vim.api.nvim_create_user_command("SnacksProjectsRefresh", refresh_project_source, {
      desc = "Refresh Snacks projects cache",
    })
  end,
}
