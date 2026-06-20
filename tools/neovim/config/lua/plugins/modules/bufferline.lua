---Bufferline integration for tab-scoped workspaces.
---
---This module adapts bufferline.nvim to the local tab workspace model in
---`config.tabs`: bufferline only shows buffers owned by the active tab, keeps
---its transparent styling after colorscheme changes, and renders a compact
---right-aligned tab indicator.

local M = {}

---Bufferline highlight groups whose background should remain transparent.
---@type string[]
local transparent_highlights = {
  "BufferLineFill",
  "BufferLineBackground",
  "BufferLineBufferVisible",
  "BufferLineBufferSelected",
  "BufferLineTab",
  "BufferLineTabSelected",
  "BufferLineTabSeparator",
  "BufferLineTabSeparatorSelected",
  "BufferLineSeparator",
  "BufferLineSeparatorSelected",
  "BufferLineSeparatorVisible",
}

---Remove the background color from one highlight group if it exists.
---@param name string Highlight group name
local function clear_bg(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then
    return
  end

  hl.bg = nil
  ---@diagnostic disable-next-line:param-type-mismatch
  pcall(vim.api.nvim_set_hl, 0, name, hl)
end

---Apply transparent backgrounds to all bufferline highlight groups.
local function apply_transparent_highlights()
  for _, name in ipairs(transparent_highlights) do
    clear_bg(name)
  end
end

---Build the right-side tab indicator items for bufferline.
---
---Each item is a clickable tab target using `%T` tabline syntax. Indicators are
---hidden when there is only one tab.
---@return table[] items Bufferline custom area items
local function tab_indicator_items()
  local current = vim.api.nvim_get_current_tabpage()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs < 2 then
    return {}
  end

  local items = {}
  for i, tab in ipairs(tabs) do
    items[#items + 1] = {
      text = "%" .. i .. "T" .. "▁▁" .. "%T",
      link = tab == current and "BufferLineTabUnderlineActive" or "BufferLineTabUnderlineInactive",
    }
    if i < #tabs then
      items[#items + 1] = { text = " ", bg = "NONE" }
    end
  end
  return items
end

---Force bufferline to recompute and redraw after buffer/tab mutations.
local function refresh_tabline()
  vim.schedule(function()
    -- Bufferline caches its components. Force a recompute before redraw so
    -- buffers opened through Snacks picker/explorer are reflected immediately.
    pcall(nvim_bufferline)
    vim.cmd.redrawtabline()
  end)
end

---Install bufferline-specific highlight definitions and colorscheme refreshes.
local function setup_highlights()
  vim.api.nvim_set_hl(0, "BufferLineTabUnderlineActive", { fg = "#57ab5a", bg = "NONE" })
  vim.api.nvim_set_hl(0, "BufferLineTabUnderlineInactive", { fg = "#768390", bg = "NONE" })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("bufferline_transparent", { clear = true }),
    callback = apply_transparent_highlights,
  })

  vim.schedule(apply_transparent_highlights)
end

---Register autocmds that keep bufferline synchronized with workspace changes.
local function setup_refresh_autocmds()
  local group = vim.api.nvim_create_augroup("bufferline_tab_indicator_refresh", { clear = true })

  vim.api.nvim_create_autocmd({
    "BufAdd",
    "BufEnter",
    "BufFilePost",
    "BufReadPost",
    "BufWinEnter",
    "BufDelete",
    "TabEnter",
    "TabNewEntered",
    "TabClosed",
  }, {
    group = group,
    callback = refresh_tabline,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "DiffviewViewOpened", "DiffviewViewClosed" },
    callback = refresh_tabline,
  })
end

---Patch bufferline.nvim options for this configuration.
---
---This preserves any existing `custom_filter`, then adds the tab workspace
---filter so global Neovim buffers only appear in the tab that owns them.
---@param opts table bufferline.nvim options table provided by lazy.nvim
function M.setup_opts(opts)
  opts.options = opts.options or {}
  opts.options.show_buffer_close_icons = false
  opts.options.show_close_icon = false
  opts.options.show_tab_indicators = false
  opts.options.always_show_bufferline = true

  local previous_filter = opts.options.custom_filter
  opts.options.custom_filter = function(buf, buffers)
    if previous_filter and not previous_filter(buf, buffers) then
      return false
    end
    return require("config.tabs").contains_current_tab(buf)
  end

  opts.options.custom_areas = opts.options.custom_areas or {}
  opts.options.custom_areas.right = tab_indicator_items

  setup_highlights()
  setup_refresh_autocmds()
end

return M
