-- Tab-scoped workspace state for Neovim.
--
-- Neovim buffers are process-global, but this config treats each tabpage as an
-- independent workspace. This module tracks which managed file buffers belong
-- to each tab, exposes that ownership to bufferline filtering, cleans up hidden
-- buffers when a tab closes, and persists the workspace mapping across
-- persistence.nvim sessions.
--
-- Core flow:
-- - remember_tabs() rebuilds the tab-number cache after tab lifecycle events so
--   TabClosed can resolve the closed tab number back to its tabpage handle.
-- - attach() records buffer ownership for the current tab, using a monotonic
--   sequence so the most recent legitimate owner wins when Neovim fires buffer
--   events during tab creation or session restore.
-- - contains_current_tab() is the bufferline filter. It only shows buffers
--   owned by, or visibly displayed in, the active tab.
-- - save_session_state() serializes each tab workspace as tab index, project
--   path, and buffer file paths. append_session_state() writes that snapshot
--   into the generated session file.
-- - restore_session_state() rebuilds workspace ownership after persistence.nvim
--   sources a session, because restored buffer ids are not stable.

local M = {}

local workspaces = {}
local tabs_by_number = {}
local setup_done = false
local session_state_var = "tab_workspaces"
local session_project_var = "tab_session_project"
local attach_sequence = 0
local session_project_path = nil

local function current_tab()
  return vim.api.nvim_get_current_tabpage()
end

local function normalize_path(path)
  return path and vim.fn.fnamemodify(path, ":p"):gsub("/$", "") or nil
end

local function normalize_buf_name(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and normalize_path(name) or nil
end

local function set_session_project_internal(path)
  path = normalize_path(path)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return nil
  end

  session_project_path = path
  vim.g[session_project_var] = path
  return path
end

local function workspace(tab)
  tab = tab or current_tab()
  workspaces[tab] = workspaces[tab] or { buffers = {} }
  return workspaces[tab]
end

local function remember_tabs()
  tabs_by_number = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    tabs_by_number[vim.api.nvim_tabpage_get_number(tab)] = tab
    workspace(tab)
  end
end

local function is_managed_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local buftype = vim.bo[buf].buftype
  if buftype ~= "" and buftype ~= "nofile" then
    return false
  end

  return vim.bo[buf].filetype ~= "snacks_dashboard"
end

local function buffer_visible_in_tab(buf, tab)
  if not vim.api.nvim_tabpage_is_valid(tab) then
    return false
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      return true
    end
  end

  return false
end

local function buffer_visible_anywhere(buf)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if buffer_visible_in_tab(buf, tab) then
      return true
    end
  end

  return false
end

local function buffer_visible_elsewhere(buf, tab)
  for _, other_tab in ipairs(vim.api.nvim_list_tabpages()) do
    if other_tab ~= tab and buffer_visible_in_tab(buf, other_tab) then
      return true
    end
  end

  return false
end

local function buffer_owned_elsewhere(closed_tab, buf)
  for tab, state in pairs(workspaces) do
    if tab ~= closed_tab and vim.api.nvim_tabpage_is_valid(tab) and state.buffers[buf] then
      return true
    end
  end

  return false
end

local function preferred_owner(buf)
  local owner
  local owner_score = -1

  for tab, state in pairs(workspaces) do
    if vim.api.nvim_tabpage_is_valid(tab) and state.buffers[buf] then
      local order = type(state.buffers[buf]) == "number" and state.buffers[buf] or 1
      local score = order
      if buffer_visible_in_tab(buf, tab) then
        score = score + 1000000
      end

      if score > owner_score then
        owner = tab
        owner_score = score
      end
    end
  end

  return owner
end

local function tab_project(tab)
  local state = workspace(tab)
  if state.project then
    return state.project
  end

  local ok, cwd = pcall(vim.fn.getcwd, -1, vim.api.nvim_tabpage_get_number(tab))
  if ok then
    return normalize_path(cwd)
  end

  return nil
end

local function first_tab_project()
  local first_tab = vim.api.nvim_list_tabpages()[1]
  if not (first_tab and vim.api.nvim_tabpage_is_valid(first_tab)) then
    return nil
  end

  return tab_project(first_tab)
end

function M.attach(buf, tab)
  buf = buf or vim.api.nvim_get_current_buf()
  tab = tab or current_tab()

  if not is_managed_buffer(buf) then
    return false
  end

  attach_sequence = attach_sequence + 1
  workspace(tab).buffers[buf] = attach_sequence
  return true
end

function M.attach_current_tab_buffers(opts)
  opts = opts or {}
  local tab = current_tab()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buffer_visible_in_tab(buf, tab) or (opts.listed and vim.bo[buf].buflisted) then
      M.attach(buf, tab)
    end
  end
end

function M.save_session_state()
  remember_tabs()

  local snapshot = {}
  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local state = workspace(tab)
    local seen = {}
    local buffers = {}

    local function add_buffer(buf, owned)
      if not is_managed_buffer(buf) then
        return
      end

      if owned and preferred_owner(buf) ~= tab then
        return
      end

      local name = normalize_buf_name(buf)
      if name and not seen[name] then
        seen[name] = true
        buffers[#buffers + 1] = name
      end
    end

    for buf in pairs(state.buffers) do
      if vim.api.nvim_buf_is_valid(buf) then
        add_buffer(buf, true)
      end
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_is_valid(win) then
        add_buffer(vim.api.nvim_win_get_buf(win), false)
      end
    end

    table.sort(buffers)
    snapshot[#snapshot + 1] = {
      index = index,
      project = tab_project(tab),
      buffers = buffers,
    }
  end

  vim.g[session_state_var] = snapshot
  vim.g[session_project_var] = first_tab_project() or M.session_project() or M.project()
end

function M.append_session_state(session_file)
  local snapshot = vim.g[session_state_var]
  local session_project = vim.g[session_project_var]
  if type(snapshot) ~= "table" or type(session_file) ~= "string" or session_file == "" then
    return
  end

  local encoded = vim.json.encode(snapshot)
  local lines = {
    "",
    '" Tab workspace state',
  }

  if type(session_project) == "string" and session_project ~= "" then
    lines[#lines + 1] = "lua vim.g."
      .. session_project_var
      .. " = "
      .. string.format("%q", session_project)
  end

  lines[#lines + 1] = "lua vim.g."
    .. session_state_var
    .. " = vim.json.decode("
    .. string.format("%q", encoded)
    .. ")"
  vim.fn.writefile(lines, session_file, "a")
end

function M.restore_session_state()
  local snapshot = vim.g[session_state_var]
  if type(vim.g[session_project_var]) == "string" then
    set_session_project_internal(vim.g[session_project_var])
  end

  if type(snapshot) ~= "table" then
    remember_tabs()
    M.session_project()
    return
  end

  workspaces = {}
  remember_tabs()

  local buffers_by_name = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_managed_buffer(buf) then
      local name = normalize_buf_name(buf)
      if name then
        buffers_by_name[name] = buf
      end
    end
  end

  local tabs = vim.api.nvim_list_tabpages()
  for index, item in ipairs(snapshot) do
    local tab = tabs[tonumber(item.index) or index]
    if tab and vim.api.nvim_tabpage_is_valid(tab) then
      local state = workspace(tab)
      state.buffers = {}

      if type(item.project) == "string" then
        M.set_project(item.project, tab)
      end

      if type(item.buffers) == "table" then
        for _, name in ipairs(item.buffers) do
          local buf = buffers_by_name[normalize_path(name)]
          if buf then
            M.attach(buf, tab)
          end
        end
      end

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if vim.api.nvim_win_is_valid(win) then
          M.attach(vim.api.nvim_win_get_buf(win), tab)
        end
      end
    end
  end

  local first_project = snapshot[1] and type(snapshot[1].project) == "string" and snapshot[1].project or nil
  if first_project then
    set_session_project_internal(first_project)
  elseif not session_project_path then
    for _, item in ipairs(snapshot) do
      if type(item.project) == "string" and set_session_project_internal(item.project) then
        break
      end
    end
  end

  vim.schedule(function()
    pcall(nvim_bufferline)
    vim.cmd.redrawtabline()
  end)
end

function M.set_project(path, tab)
  path = normalize_path(path)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return nil
  end

  local state = workspace(tab)
  state.project = path
  return path
end

function M.set_session_project(path)
  return set_session_project_internal(path)
end

function M.session_project()
  local first_project = first_tab_project()
  if first_project and set_session_project_internal(first_project) then
    return session_project_path
  end

  if session_project_path and vim.fn.isdirectory(session_project_path) == 1 then
    return session_project_path
  end

  if type(vim.g[session_project_var]) == "string" and set_session_project_internal(vim.g[session_project_var]) then
    return session_project_path
  end

  return set_session_project_internal(vim.fn.getcwd(0))
end

function M.project(tab)
  local state = workspace(tab)
  return state.project or M.set_project(vim.fn.getcwd(0), tab)
end

function M.contains_current_tab(buf)
  local tab = current_tab()
  if workspace(tab).buffers[buf] then
    if preferred_owner(buf) ~= tab then
      return false
    end

    if buffer_visible_elsewhere(buf, tab) and not buffer_visible_in_tab(buf, tab) then
      return false
    end

    return true
  end

  -- Bufferline calls this as a filter. Keep it side-effect free so a transient
  -- buffer inherited by :tabnew does not become permanently owned by the new tab.
  return buffer_visible_in_tab(buf, tab)
end

local function cleanup_tab(tab)
  local state = workspaces[tab]
  workspaces[tab] = nil

  if not state then
    return
  end

  vim.schedule(function()
    for buf in pairs(state.buffers) do
      if
        vim.api.nvim_buf_is_valid(buf)
        and not vim.bo[buf].modified
        and not buffer_visible_anywhere(buf)
        and not buffer_owned_elsewhere(tab, buf)
      then
        pcall(vim.api.nvim_buf_delete, buf, { force = false })
      end
    end
  end)
end

local function cleanup_closed_tab(event)
  local tabnr = tonumber(event.file) or tonumber(event.match)
  local tab = tabnr and tabs_by_number[tabnr]

  if tab then
    cleanup_tab(tab)
  end

  vim.schedule(remember_tabs)
end

function M.open_project_tab(path)
  local cwd = normalize_path(path) or M.project() or vim.fn.getcwd(0)
  if vim.fn.isdirectory(cwd) ~= 1 then
    cwd = vim.fn.getcwd(0)
  end

  vim.cmd.tabnew()
  vim.cmd.tcd(vim.fn.fnameescape(cwd))
  M.set_project(cwd)
  M.session_project()
  M.attach()
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  local group = vim.api.nvim_create_augroup("dotfiles_tabs", { clear = true })

  vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "BufReadPost", "BufWinEnter", "BufNewFile" }, {
    group = group,
    callback = function(event)
      remember_tabs()
      M.attach(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "TabEnter", "TabNewEntered" }, {
    group = group,
    callback = function()
      remember_tabs()
    end,
  })

  vim.api.nvim_create_autocmd("TabNewEntered", {
    group = group,
    callback = function()
      local tab = current_tab()
      local buf = vim.api.nvim_get_current_buf()

      if buffer_owned_elsewhere(tab, buf) then
        if buffer_visible_elsewhere(buf, tab) then
          workspace(tab).buffers[buf] = nil
        else
          M.attach(buf, tab)
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = cleanup_closed_tab,
  })

  remember_tabs()
  M.session_project()
  M.set_project(vim.fn.getcwd(0))
  M.attach_current_tab_buffers({ listed = true })
end

return M
