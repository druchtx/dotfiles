return {
  "snacks.nvim",
  opts = function(_, opts)
    local function is_ds_store(path)
      return vim.fs.basename(path or "") == ".DS_Store"
    end

    opts = opts or {}
    opts.picker = opts.picker or {}
    opts.picker.enabled = true
    opts.picker.sources = opts.picker.sources or {}

    -- Configure projects source
    opts.picker.sources.projects = opts.picker.sources.projects or {}

    -- Scan $PROJECTS directory for all subdirectories
    local project_dirs = {}
    local projects_env = vim.env.PROJECTS

    if projects_env and projects_env ~= "" then
      local projects_dir = vim.fn.expand(projects_env)
      if vim.fn.isdirectory(projects_dir) == 1 then
        local handle = io.popen(
          string.format(
            [[find "%s" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort]],
            projects_dir
          )
        )
        if handle then
          for raw_path in handle:lines() do
            local path = raw_path
            path = path:gsub("/$", "")
            if vim.fn.isdirectory(path) == 1 and not is_ds_store(path) then
              table.insert(project_dirs, path)
            end
          end
          handle:close()
        end
      end
    end

    -- Merge with existing projects config
    -- Don't use 'dev' + 'patterns' approach, use explicit 'projects' list
    opts.picker.sources.projects = vim.tbl_deep_extend("force", opts.picker.sources.projects or {}, {
      dev = {}, -- Clear dev so it doesn't scan with patterns
      projects = project_dirs, -- Explicit list of project directories
      recent = true, -- Include recent projects
      filter = {
        filter = function(item)
          return not is_ds_store(item.file or item.text)
        end,
      },
    })

    return opts
  end,
}
