---Bufferline integration for tab-scoped workspaces.
---
---This module adapts bufferline.nvim to the local tabpage model in
---`utils.tabpage`: bufferline only shows buffers associated with the active
---tabpage and renders a right-aligned tab indicator.

local M = {}

---Keep the last file buffer highlighted while a special buffer has focus.
---
---Bufferline renders listed buffers only. This preserves the visible file
---anchor when focus moves to a picker, explorer, or other unlisted buffer.
local function keep_last_bufferline_buffer_visible()
  local last_bufferline_buffer

  local function is_listed_buffer(buf)
    return type(buf) == "number" and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end

  local buffer = require("bufferline.models").Buffer
  local original_current = buffer.current
  function buffer:current()
    if not is_listed_buffer(vim.api.nvim_get_current_buf()) and is_listed_buffer(last_bufferline_buffer) then
      return self.id == last_bufferline_buffer
    end
    return original_current(self)
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = vim.api.nvim_create_augroup("bufferline_last_file", { clear = true }),
    callback = function(args)
      if is_listed_buffer(args.buf) then
        last_bufferline_buffer = args.buf
      end
      vim.cmd("redrawtabline")
    end,
  })
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

---Return the tab entries used by the bufferline tab picker.
---@return table[] items Tab picker entries.
function M.tab_items()
  local current = vim.api.nvim_get_current_tabpage()
  local items = {}

  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local tabpage = require("utils.tabpage")
    local tab_name = tabpage.name(tab)
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    local current_buf = wins[1] and vim.api.nvim_win_get_buf(wins[1]) or nil
    local current_file = current_buf and vim.api.nvim_buf_get_name(current_buf) or ""
    current_file = current_file ~= "" and vim.fn.fnamemodify(current_file, ":t") or "[No File]"

    items[#items + 1] = {
      idx = index,
      tab = tab,
      file = current_file,
      text = string.format("%s%d  %s  %s", tab == current and "* " or "  ", index, tab_name, current_file),
    }
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

---Install bufferline-specific tab indicator highlights.
local function setup_highlights()
  vim.api.nvim_set_hl(0, "BufferLineTabUnderlineActive", { fg = "#57ab5a", bg = "NONE" })
  vim.api.nvim_set_hl(0, "BufferLineTabUnderlineInactive", { fg = "#768390", bg = "NONE" })
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

---Build bufferline.nvim options for this configuration.
---
---This preserves any existing `custom_filter`, then adds the tab workspace
---filter so global Neovim buffers only appear in the tab that owns them.
---@param opts table bufferline.nvim options table provided by lazy.nvim
function M.configure(opts)
  opts.options = opts.options or {}
  -- Theme integration: inactive buffers use the editor background instead of a
  -- separate black strip, while the active indicator matches the text color.
  opts.highlights = function()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local background = string.format("#%06x", normal.bg or 0)
    local foreground = string.format("#%06x", normal.fg or 0)

    return {
      background = { bg = background },
      buffer_visible = { bg = background, fg = foreground, bold = true },
      fill = { bg = background },
      -- Keep diagnostic indicators on the same background as the rest of the
      -- bufferline. Bufferline's defaults shade these groups, which becomes a
      -- distracting dark block in the current colorscheme.
      diagnostic = { bg = background },
      diagnostic_visible = { bg = background },
      diagnostic_selected = { bg = background },
      error = { bg = background },
      error_visible = { bg = background },
      error_selected = { bg = background },
      error_diagnostic = { bg = background },
      error_diagnostic_visible = { bg = background },
      error_diagnostic_selected = { bg = background },
      warning = { bg = background },
      warning_visible = { bg = background },
      warning_selected = { bg = background },
      warning_diagnostic = { bg = background },
      warning_diagnostic_visible = { bg = background },
      warning_diagnostic_selected = { bg = background },
      info = { bg = background },
      info_visible = { bg = background },
      info_selected = { bg = background },
      info_diagnostic = { bg = background },
      info_diagnostic_visible = { bg = background },
      info_diagnostic_selected = { bg = background },
      hint = { bg = background },
      hint_visible = { bg = background },
      hint_selected = { bg = background },
      hint_diagnostic = { bg = background },
      hint_diagnostic_visible = { bg = background },
      hint_diagnostic_selected = { bg = background },
      indicator_selected = { fg = foreground },
      indicator_visible = { fg = foreground },
      separator = { bg = background, fg = background },
      separator_visible = { bg = background, fg = background },
    }
  end
  opts.options.mode = "buffers"
  -- Snacks' sidebar offset would also move custom_areas.right to the
  -- editor/sidebar boundary. Keep Bufferline full-width so the tab switcher
  -- remains anchored to the screen edge when Explorer is open.
  opts.options.offsets = vim.tbl_filter(function(offset)
    return offset.filetype ~= "snacks_layout_box"
  end, opts.options.offsets or {})
  opts.options.diagnostics = "nvim_lsp"
  opts.options.separator_style = "thin"
  opts.options.show_buffer_close_icons = false
  opts.options.show_close_icon = false
  opts.options.show_tab_indicators = false
  opts.options.always_show_bufferline = true

  local previous_filter = opts.options.custom_filter
  opts.options.custom_filter = function(buf, buffers)
    if previous_filter and not previous_filter(buf, buffers) then
      return false
    end
    return require("utils.tabpage").filter_buffer(buf)
  end

  opts.options.custom_areas = opts.options.custom_areas or {}
  opts.options.custom_areas.right = tab_indicator_items

  setup_highlights()
  setup_refresh_autocmds()
end

---Install bufferline-specific behavior after bufferline has been configured.
---@return nil
function M.setup()
  keep_last_bufferline_buffer_visible()
end

return M
