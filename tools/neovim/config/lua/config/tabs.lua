local M = {}

-- Neovim buffers are global, while this setup treats each tab as a lightweight
-- workspace. A workspace owns the buffers opened from that tab and carries the
-- explicit project selected by the project picker.
local workspaces = {}
local tabs_by_number = {}
local setup_done = false

local function current_tab()
  return vim.api.nvim_get_current_tabpage()
end

local function normalize_path(path)
  return path and vim.fn.fnamemodify(path, ":p"):gsub("/$", "") or nil
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

local function buffer_owned_elsewhere(closed_tab, buf)
  for tab, state in pairs(workspaces) do
    if tab ~= closed_tab and vim.api.nvim_tabpage_is_valid(tab) and state.buffers[buf] then
      return true
    end
  end

  return false
end

function M.attach(buf, tab)
  buf = buf or vim.api.nvim_get_current_buf()
  tab = tab or current_tab()

  if not is_managed_buffer(buf) then
    return false
  end

  workspace(tab).buffers[buf] = true
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

function M.set_project(path, tab)
  path = normalize_path(path)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return nil
  end

  local state = workspace(tab)
  state.project = path
  return path
end

function M.project(tab)
  local state = workspace(tab)
  return state.project or M.set_project(vim.fn.getcwd(0), tab)
end

function M.contains_current_tab(buf)
  local tab = current_tab()
  if workspace(tab).buffers[buf] then
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
        workspace(tab).buffers[buf] = nil
      end
    end,
  })

  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = cleanup_closed_tab,
  })

  remember_tabs()
  M.set_project(vim.fn.getcwd(0))
  M.attach_current_tab_buffers({ listed = true })
end

return M
