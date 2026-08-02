---Scratch workspace helpers for Snacks.
---
---The built-in Snacks scratch picker manages persistent scratch buffers. This
---module keeps that behavior intact and adds a project-scoped file/grep layer
---so extra folders can participate in the same scratch workflow.
local M = {}

---Additional directories that should be indexed alongside scratch buffers.
---
---Leave empty to fall back to the current LazyVim root. Add any number of
---extra folders here when you want scratch search to span more than one repo.
---@type string[]
M.roots = {
  "~/Workspace/memo/",
}

---@return string[] roots Normalized unique roots
local function configured_roots()
  local roots = #M.roots > 0 and M.roots or { LazyVim.root() }
  local seen = {}
  local ret = {}

  for _, root in ipairs(roots) do
    root = root and vim.fn.fnamemodify(vim.fn.expand(root), ":p"):gsub("/$", "")
    if root and root ~= "" and not seen[root] then
      seen[root] = true
      ret[#ret + 1] = root
    end
  end

  return ret
end

---Open a picker that combines scratch buffers and scratch-searchable files.
function M.open()
  require("snacks").picker.pick({ source = "scratch_workspace" })
end

---Open a file-name picker over the configured scratch roots.
function M.files()
  require("snacks").picker.pick({ source = "scratch_files" })
end

---Configure Snacks picker sources for scratch workspace search.
---@param opts snacks.Config
---@return snacks.Config opts The same options table after mutation
function M.configure_picker(opts)
  opts = opts or {}
  local roots = configured_roots()

  opts.picker = opts.picker or {}
  opts.picker.sources = opts.picker.sources or {}

  if #roots > 0 then
    opts.picker.sources.scratch_files = vim.tbl_deep_extend("force", opts.picker.sources.scratch_files or {}, {
      finder = "files",
      format = "file",
      hidden = true,
      ignored = true,
      follow = true,
      dirs = roots,
      exclude = { ".DS_Store", "**/.DS_Store" },
    })
    opts.picker.sources.scratch_grep = vim.tbl_deep_extend("force", opts.picker.sources.scratch_grep or {}, {
      finder = "grep",
      hidden = true,
      ignored = true,
      follow = true,
      dirs = roots,
      exclude = { ".DS_Store", "**/.DS_Store" },
    })
    opts.picker.sources.scratch_workspace = vim.tbl_deep_extend("force", opts.picker.sources.scratch_workspace or {}, {
      multi = { "scratch", "scratch_files" },
    })
  end

  return opts
end

return M
