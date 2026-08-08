---Runtime tabpage and buffer membership for the current Neovim session.
---
---All tabpages in one Neovim process implicitly form one workspace. This
---module owns the tab metadata and buffer relationships; persistence.nvim is
---responsible for serializing the snapshot, while UI integrations consume the
---query APIs below.

---@alias TabpageId integer
---@alias BufferId integer

---@class TabpageState
---@field order integer Current tabpage order.
---@field buffers table<BufferId, TabBufferEntry> Buffers associated with the tabpage.

---@class TabBufferEntry
---@field bufnr BufferId Buffer handle.
---@field name string Absolute buffer name.

---@class TabCreateOpts
---@field name? string Initial display name.
---@field cwd? string Initial tab-local working directory.

---@class TabCloseOpts
---@field event? table Native TabClosed autocmd event.

---@class TabBufferListOpts
---@field names? boolean Return names instead of buffer entries.

---@class TabpageSnapshotEntry
---@field order integer Tab number at save time.
---@field name string Display name.
---@field buffers string[] Absolute buffer names.

local M = {}

---@type table<TabpageId, TabpageState>
local tab_states = {}

---@type table<integer, TabpageId>
local tabs_by_number = {}

local setup_done = false
local tabpage_state_var = "tabpage_state"
local bind_buffer
local sync_current_tab_buffers
local clear_bindings

---Return the active tabpage handle.
---@return TabpageId
local function current_tab()
  return vim.api.nvim_get_current_tabpage()
end

---Check whether a tabpage handle is valid.
---@param tab TabpageId?
---@return boolean
local function valid_tab(tab)
  return tab ~= nil and vim.api.nvim_tabpage_is_valid(tab)
end

---Normalize an absolute filesystem path.
---@param path string?
---@return string?
local function normalize_path(path)
  if not path or path == "" then
    return nil
  end
  local normalized = vim.fn.fnamemodify(path, ":p")
  return (normalized:gsub("/$", ""))
end

---Return the current number for a tabpage handle.
---@param tab TabpageId?
---@return integer?
local function tab_number(tab)
  if not tab or not vim.api.nvim_tabpage_is_valid(tab) then
    return nil
  end
  return vim.api.nvim_tabpage_get_number(tab)
end

---Return a tabpage's local working directory.
---@param tab TabpageId?
---@return string?
local function tab_cwd(tab)
  local number = tab_number(tab)
  if not number then
    return nil
  end

  local ok, cwd = pcall(vim.fn.getcwd, -1, number)
  return ok and normalize_path(cwd) or nil
end

---Check whether a buffer is eligible for tabpage tracking.
---@param buf BufferId
---@return boolean
local function is_managed_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  if vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end

  local buftype = vim.bo[buf].buftype
  if buftype ~= "" and buftype ~= "nofile" then
    return false
  end

  return vim.bo[buf].filetype ~= "snacks_dashboard"
end

---Return a normalized name for a managed buffer.
---@param buf BufferId
---@return string?
local function buffer_name(buf)
  if not is_managed_buffer(buf) then
    return nil
  end

  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and normalize_path(name) or nil
end

---Return or initialize a tabpage's internal state.
---@param tab TabpageId?
---@return TabpageState
local function state(tab)
  tab = tab or current_tab()
  tab_states[tab] = tab_states[tab] or {
    order = tab_number(tab) or 0,
    buffers = {},
  }
  return tab_states[tab]
end

---Check whether a buffer is visible in a tabpage window.
---@param buf BufferId
---@param tab TabpageId?
---@return boolean
local function buffer_visible_in_tab(buf, tab)
  if not tab or not vim.api.nvim_tabpage_is_valid(tab) then
    return false
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      return true
    end
  end
  return false
end

---Check whether a buffer is visible in any live tabpage.
---@param buf BufferId
---@return boolean
local function buffer_visible_anywhere(buf)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if buffer_visible_in_tab(buf, tab) then
      return true
    end
  end
  return false
end

---Ensure every live tabpage has an initialized state record.
---@return nil
local function remember_tabs()
  tabs_by_number = {}
  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    tabs_by_number[index] = tab
    state(tab).order = index
  end
end

---Return a buffer entry within a tabpage.
---@param tab TabpageId?
---@param buf BufferId
---@return TabBufferEntry?
local function buffer_entry(tab, buf)
  return state(tab).buffers[buf]
end

---Bind a visible managed buffer if it is not already tracked.
---@param tab TabpageId
---@param buf BufferId
---@return boolean bound
local function remember_buffer(tab, buf)
  if not is_managed_buffer(buf) then
    return false
  end

  if buffer_entry(tab, buf) then
    return true
  end

  return bind_buffer(buf, tab)
end

---Return the current tabpage.
---@return TabpageId tabpage
function M.current()
  return current_tab()
end

---Return all valid tabpages in display order.
---@return TabpageId[] tabpages
function M.list()
  return vim.api.nvim_list_tabpages()
end

---Return a human-readable tab name.
---@param tab? TabpageId
---@return string
function M.name(tab)
  tab = tab or current_tab()
  local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
  if ok and type(name) == "string" and name ~= "" then
    return name
  end

  return "tab-" .. (tab_number(tab) or 1)
end

---Set a tab's display name and mirror it as a tabpage variable for plugins.
---@param tab? TabpageId
---@param name string
---@return boolean
function M.set_name(tab, name)
  tab = tab or current_tab()
  if not valid_tab(tab) or type(name) ~= "string" or name == "" then
    return false
  end

  vim.api.nvim_tabpage_set_var(tab, "name", name)
  vim.api.nvim_exec_autocmds("User", { pattern = "TabsChanged" })
  return true
end

---Return the tab-local working directory.
---@param tab? TabpageId
---@return string?
function M.cwd(tab)
  return tab_cwd(tab or current_tab())
end

---Create a clean tabpage and return its tabpage handle.
---@param opts? TabCreateOpts
---@return TabpageId tabpage
function M.create(opts)
  opts = opts or {}
  local cwd = normalize_path(opts.cwd or vim.fn.getcwd(0))
  if not cwd or vim.fn.isdirectory(cwd) ~= 1 then
    cwd = normalize_path(vim.fn.getcwd(0))
  end
  if not cwd then
    error("Unable to determine the tabpage working directory")
  end

  vim.cmd.tabnew()
  local tab = current_tab()
  -- `:tabnew` can briefly inherit the previous tab's current buffer. A new tab
  -- starts with no buffer relation, so the previous tab's current
  -- buffer is not leaked into the new tab's Bufferline view.
  clear_bindings(tab)
  vim.cmd.enew()
  vim.cmd.tcd(vim.fn.fnameescape(cwd))
  if opts.name then
    M.set_name(tab, opts.name)
  end
  sync_current_tab_buffers()
  return tab
end

---Switch to a tabpage.
---@param tab TabpageId
---@return boolean
function M.select(tab)
  if not valid_tab(tab) then
    return false
  end
  vim.api.nvim_set_current_tabpage(tab)
  return true
end

---Delete closed-tab buffers that no longer have a tabpage relation.
---@param closed_state TabpageState
---@return nil
local function cleanup_closed_tab_buffers(closed_state)
  for buf in pairs(closed_state.buffers) do
    if vim.api.nvim_buf_is_valid(buf) and not buffer_visible_anywhere(buf) then
      local still_bound = false
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if buffer_entry(tab, buf) then
          still_bound = true
          break
        end
      end

      if not still_bound and not vim.bo[buf].modified then
        pcall(vim.api.nvim_buf_delete, buf, { force = false })
      end
    end
  end
end

---Close a tabpage or handle a native TabClosed event.
---@param tab? TabpageId
---@param opts? TabCloseOpts
---@return boolean
function M.close(tab, opts)
  opts = opts or {}

  if opts.event then
    local tabnr = tonumber(opts.event.file) or tonumber(opts.event.match)
    local closed_tab = tabnr and tabs_by_number[tabnr]
    local closed_state = closed_tab and tab_states[closed_tab]

    if closed_tab then
      tab_states[closed_tab] = nil
    end
    if closed_state then
      cleanup_closed_tab_buffers(closed_state)
    end
    vim.schedule(remember_tabs)
    return true
  end

  tab = tab or current_tab()
  if not valid_tab(tab) then
    return false
  end

  local number = tab_number(tab)

  local ok, err = pcall(function()
    if tab == current_tab() then
      vim.cmd.tabclose()
    elseif number then
      vim.cmd("tabclose " .. number)
    end
  end)

  if not ok then
    remember_tabs()
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return false
  end

  return true
end

---Bind a buffer to a tabpage internally.
---@param buf? BufferId
---@param tab? TabpageId
---@return boolean
bind_buffer = function(buf, tab)
  tab = tab or current_tab()
  buf = buf or vim.api.nvim_get_current_buf()
  if buffer_entry(tab, buf) ~= nil then
    return true
  end

  local name = buffer_name(buf)
  if not name then
    return false
  end

  state(tab).buffers[buf] = {
    bufnr = buf,
    name = name,
  }
  vim.api.nvim_exec_autocmds("User", { pattern = "TabsChanged" })
  return true
end

---Synchronize visible buffers into the current tabpage internally.
---@param opts? { listed?: boolean }
---@return integer count
sync_current_tab_buffers = function(opts)
  opts = opts or {}
  local tab = current_tab()
  local count = 0
  local candidates = {}
  local seen = {}

  local function add_candidate(buf)
    if not seen[buf] then
      seen[buf] = true
      candidates[#candidates + 1] = buf
    end
  end

  -- Tab switches only need to inspect buffers displayed by this tab. The
  -- global listed-buffer scan is reserved for initial synchronization.
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_is_valid(win) then
      add_candidate(vim.api.nvim_win_get_buf(win))
    end
  end

  if opts.listed then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buflisted then
        add_candidate(buf)
      end
    end
  end

  for _, buf in ipairs(candidates) do
    if remember_buffer(tab, buf) then
      count = count + 1
    end
  end

  return count
end

---Clear a tabpage's internal buffer bindings.
---@param tab? TabpageId
---@return nil
clear_bindings = function(tab)
  tab = tab or current_tab()
  state(tab).buffers = {}
end

---Return whether a buffer belongs to a tab or is visibly displayed there.
---@param tab? TabpageId
---@param buf? BufferId
---@return boolean
function M.contains(tab, buf)
  tab = tab or current_tab()
  buf = buf or vim.api.nvim_get_current_buf()
  return is_managed_buffer(buf) and (buffer_entry(tab, buf) ~= nil or buffer_visible_in_tab(buf, tab))
end

---Return buffers associated with a tabpage in buffer ID order.
---@param tab? TabpageId
---@param opts? TabBufferListOpts
---@overload fun(tab?: TabpageId, opts?: { names?: false }): TabBufferEntry[]
---@overload fun(tab?: TabpageId, opts: { names: true }): string[]
---@return TabBufferEntry[]|string[]
function M.buffers(tab, opts)
  tab = tab or current_tab()
  opts = opts or {}
  local result = {}

  for buf, entry in pairs(state(tab).buffers) do
    local name = buffer_name(buf)
    if vim.api.nvim_buf_is_valid(buf) and name then
      entry.name = name
      result[#result + 1] = entry
    end
  end

  table.sort(result, function(a, b)
    return a.bufnr < b.bufnr
  end)

  if opts.names then
    return vim.tbl_map(function(item)
      return item.name
    end, result)
  end
  return result
end

---Bufferline-facing filter for the current tab.
---@param buf BufferId
---@param tab? TabpageId
---@return boolean
function M.filter_buffer(buf, tab)
  return M.contains(tab or current_tab(), buf)
end

---Return a serializable snapshot of all tabpage state.
---@return TabpageSnapshotEntry[]
function M.snapshot()
  remember_tabs()
  local snapshot = {}

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local buffers = {}
    for _, item in ipairs(M.buffers(tab, { names = true })) do
      if item then
        buffers[#buffers + 1] = item
      end
    end
    table.sort(buffers)

    snapshot[#snapshot + 1] = {
      order = state(tab).order,
      name = M.name(tab),
      buffers = buffers,
    }
  end

  return snapshot
end

---Store tabpage state in a global before persistence saves.
---@return nil
function M.save_state()
  vim.g[tabpage_state_var] = M.snapshot()
end

---Append tabpage state to a persistence.nvim session file.
---@param session_file string
---@return nil
function M.append_state(session_file)
  local snapshot = vim.g[tabpage_state_var]
  if type(snapshot) ~= "table" or type(session_file) ~= "string" or session_file == "" then
    return
  end

  local lines = { "", '" Tabpage state' }
  lines[#lines + 1] = "lua vim.g."
    .. tabpage_state_var
    .. " = vim.json.decode("
    .. string.format("%q", vim.json.encode(snapshot))
    .. ")"
  vim.fn.writefile(lines, session_file, "a")
end

---Restore tabpage state after persistence loads native tabpages and buffers.
---@return nil
function M.restore_state()
  local snapshot = vim.g[tabpage_state_var]
  tab_states = {}
  remember_tabs()
  if type(snapshot) ~= "table" then
    return
  end

  local buffers_by_name = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = buffer_name(buf)
    if name then
      buffers_by_name[name] = buf
    end
  end

  local tabs = vim.api.nvim_list_tabpages()
  for position, item in ipairs(snapshot) do
    local tab = tabs[tonumber(item.order) or tonumber(item.index) or position]
    if valid_tab(tab) then
      if type(item.name) == "string" then
        M.set_name(tab, item.name)
      end
      if type(item.buffers) == "table" then
        for _, name in ipairs(item.buffers) do
          local buf = buffers_by_name[normalize_path(name)]
          if buf then
            bind_buffer(buf, tab)
          end
        end
      end

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if vim.api.nvim_win_is_valid(win) then
          remember_buffer(tab, vim.api.nvim_win_get_buf(win))
        end
      end
    end
  end

  vim.api.nvim_exec_autocmds("User", { pattern = "TabsChanged" })
end

---Remove a deleted buffer from every tabpage state.
---@param buf BufferId
---@return nil
local function remove_buffer(buf)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    state(tab).buffers[buf] = nil
  end
end

---Register tabpage and buffer lifecycle autocmds.
---
---This module is not a lazy.nvim plugin, so this explicit entrypoint is what
---installs its event handlers before plugin configurations open buffers.
---@return nil
function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  local group = vim.api.nvim_create_augroup("dotfiles_tabs", { clear = true })

  vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "BufReadPost", "BufWinEnter", "BufNewFile" }, {
    group = group,
    callback = function(event)
      remember_buffer(current_tab(), event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(event)
      remove_buffer(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function(event)
      M.close(nil, { event = event })
    end,
  })

  vim.api.nvim_create_autocmd({ "TabEnter", "TabNewEntered" }, {
    group = group,
    callback = function()
      remember_tabs()
      sync_current_tab_buffers()
      vim.api.nvim_exec_autocmds("User", { pattern = "TabsChanged" })
    end,
  })

  remember_tabs()
  sync_current_tab_buffers({ listed = true })
end

return M
