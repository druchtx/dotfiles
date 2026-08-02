---Responsive Snacks explorer layout helpers.
---
---This module centralizes every Explorer entrypoint so keymaps, dashboard
---actions, and project selection all use the same layout policy:
---use a sidebar on wide screens and a floating picker with preview on narrow
---screens.

local M = {}

---Minimum editor width required before Explorer opens as a right sidebar.
---@type integer
local float_threshold = 120

---Wide-screen Explorer layout.
---
---The sidebar is persistent, avoids preview by default, and keeps the input at
---the top so it matches the standard Snacks picker presentation.
---@type table
local sidebar_layout = {
  preset = "sidebar",
  preview = false,
  hidden = {},
  layout = {
    backdrop = false,
    width = 40,
    min_width = 40,
    height = 0,
    position = "right",
    border = "none",
    box = "vertical",
    {
      win = "input",
      height = 1,
      border = true,
      title = "{title} {flags}",
      title_pos = "center",
    },
    { win = "list", border = "none" },
  },
}

---Narrow-screen Explorer layout.
---
---The floating layout keeps the editor from being squeezed horizontally and
---enables a lower preview pane because there is enough vertical space inside
---the modal picker.
---@type table
local float_layout = {
  preview = true,
  hidden = {},
  layout = {
    backdrop = false,
    width = 0.9,
    min_width = 40,
    height = 0.85,
    min_height = 16,
    border = "rounded",
    title = "{title} {flags}",
    title_pos = "center",
    box = "vertical",
    {
      win = "input",
      height = 1,
      border = "bottom",
    },
    { win = "list", border = "none" },
    { win = "preview", title = "{preview}", height = 0.4, border = "top" },
  },
}

---Return the Explorer layout for the current editor width.
---
---The threshold is evaluated when Explorer opens rather than on every resize;
---this avoids closing or reshaping an active picker while the user is working.
---@return table layout Snacks picker layout config
function M.layout()
  if vim.o.columns < float_threshold then
    return float_layout
  end

  return vim.deepcopy(sidebar_layout)
end

---Return whether Explorer should use the floating layout at the current width.
---@return boolean floating True when Explorer will open as a floating picker
function M.is_float()
  return vim.o.columns < float_threshold
end

local function equalize_editor_windows()
  vim.schedule(function()
    vim.cmd("wincmd =")
  end)
end

---Open Snacks Explorer with the responsive layout.
---
---Call this instead of `Snacks.explorer()` or `Snacks.picker.explorer()` so all
---Explorer surfaces share the same sidebar/floating behavior.
---Floating Explorer closes after opening a file; sidebar Explorer remains open.
---@param opts? table Snacks explorer options, such as `{ cwd = path }`
---@return any picker The value returned by `Snacks.picker.explorer`
function M.open(opts)
  local floating = M.is_float()
  local on_show = opts and opts.on_show
  local on_close = opts and opts.on_close

  opts = vim.tbl_deep_extend("force", opts or {}, {
    jump = {
      close = floating,
    },
    layout = M.layout(),
  })

  if not floating then
    opts.on_show = function(picker)
      if on_show then
        on_show(picker)
      end
      equalize_editor_windows()
    end
    opts.on_close = function(picker)
      if on_close then
        on_close(picker)
      end
      equalize_editor_windows()
    end
  end

  return require("snacks").picker.explorer(opts)
end

return M
