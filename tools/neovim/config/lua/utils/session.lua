---Session workflow built on persistence.nvim and tabpage state.
---
---The plugin spec owns user-facing picker UI, keys, and commands. This module
---owns the concrete session behavior: persistence integration, filtering,
---tabpage state hooks, and session file operations.

local M = {}

---@class SessionRecord
---@field id string Persistence session file path.
---@field cwd string Session working directory.
---@field name? string User-facing session name.
---@field text string Default display/search text.
---@field mtime integer Session modification timestamp.

---@class SessionListOpts
---@field mode? "all"|"directory" Return all sessions or one per directory.

---@class SessionSetupOpts
---@field dir? string Persistence session directory.
---@field need? integer Minimum number of buffers required to save.
---@field branch? boolean Save branch-specific sessions.
---@field ignored_paths? string[] Path fragments excluded from listing and saving.

local setup_done = false
local persistence
local persistence_config
local tabs
local raw_list
local raw_load
local raw_save
local ignored_paths = {}

---Return the current tabpage cwd, falling back to Neovim's cwd.
---@return string cwd Current session directory.
local function current_cwd()
  return require("utils.tabpage").cwd() or vim.fn.getcwd()
end

---Decode a persistence.nvim session file path back into its directory.
---@param session_file string Absolute session file path.
---@return string dir Decoded directory.
local function decode_session_dir(session_file)
  local file = session_file:sub(#persistence_config.options.dir + 1, -5)
  local dir = vim.split(file, "%%", { plain = true })[1]:gsub("%%", "/")

  if jit.os:find("Windows") then
    dir = dir:gsub("^(%w)/", "%1:/")
  end

  return dir
end

---Return whether a path is configured to be ignored.
---@param path string? Path or branch to inspect.
---@return boolean ignored True when the path matches ignored_paths.
local function is_ignored_path(path)
  if type(path) ~= "string" then
    return false
  end

  for _, ignored in ipairs(ignored_paths) do
    if type(ignored) == "string" and ignored ~= "" and path:find(ignored, 1, true) then
      return true
    end
  end

  return false
end

---Return the path used for persistent session display names.
---@return string path JSON metadata path.
local function session_names_path()
  return persistence_config.options.dir .. "names.json"
end

---Read user-facing session names from disk.
---@return table<string, string> names Session file to display name map.
local function read_session_names()
  local path = session_names_path()
  if vim.fn.filereadable(path) == 0 then
    return {}
  end

  local ok, names = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  return ok and type(names) == "table" and names or {}
end

---Write user-facing session names to disk.
---@param names table<string, string> Session file to display name map.
---@return nil
local function write_session_names(names)
  local path = session_names_path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(names) }, path)
end

---Return whether the current session should be skipped.
---@return boolean skip True when the current cwd or branch is ignored.
local function should_skip_current_session()
  return is_ignored_path(current_cwd()) or is_ignored_path(persistence.branch())
end

---Return session files that are allowed by the configured filters.
---@return string[] files Filtered persistence session paths.
local function session_files()
  return vim.tbl_filter(function(session_file)
    return not is_ignored_path(decode_session_dir(session_file))
  end, raw_list())
end

---Return whether persistence has enough buffers to save a session.
---@return boolean enough True when the configured buffer threshold is met.
local function has_enough_buffers()
  local need = persistence_config.options.need
  if need <= 0 then
    return true
  end

  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      if buftype == "" and not vim.tbl_contains({ "gitcommit", "gitrebase", "jj" }, filetype)
          and vim.api.nvim_buf_get_name(buf) ~= "" then
        count = count + 1
      end
    end
  end

  return count >= need
end

---Install the tabpage-aware replacement for persistence's exit hook.
---@return nil
local function install_save_hook()
  persistence.stop()

  local group = vim.api.nvim_create_augroup("dotfiles_session", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if has_enough_buffers() then
        M.save()
      end
    end,
  })
end

---Ensure the session integration has been initialized.
---@return nil
local function ensure_setup()
  if not setup_done then
    error("utils.session.setup() must be called before using session APIs")
  end
end

---Initialize persistence.nvim and install session/tabpage integration.
---@param opts? SessionSetupOpts Persistence options plus `ignored_paths`.
---@return nil
function M.setup(opts)
  if setup_done then
    return
  end

  ---@type SessionSetupOpts
  local setup_opts = vim.deepcopy(opts or {})
  ignored_paths = setup_opts.ignored_paths or {}
  setup_opts.ignored_paths = nil

  persistence = require("persistence")
  persistence.setup(setup_opts)
  persistence_config = require("persistence.config")
  tabs = require("utils.tabpage")
  raw_list = persistence.list
  raw_load = persistence.load
  raw_save = persistence.save

  install_save_hook()

  setup_done = true
end

---List available sessions.
---@param opts? SessionListOpts
---@return SessionRecord[] sessions Available sessions.
function M.list(opts)
  ensure_setup()
  local names = read_session_names()
  local sessions = {}

  for _, session_file in ipairs(session_files()) do
    local stat = vim.uv.fs_stat(session_file)
    if stat then
      local dir = decode_session_dir(session_file)
      sessions[#sessions + 1] = {
        id = session_file,
        cwd = dir,
        name = names[session_file],
        text = names[session_file] or vim.fn.fnamemodify(dir, ":p:~"),
        mtime = stat.mtime.sec,
      }
    end
  end

  if opts and opts.mode == "directory" then
    -- Keep the first persistence entry for each directory. persistence.nvim
    -- returns entries newest first; restore() later lets persistence choose the
    -- session for the selected directory's current branch.
    local seen = {}
    local result = {}
    for _, item in ipairs(sessions) do
      if not seen[item.cwd] then
        seen[item.cwd] = true
        result[#result + 1] = item
      end
    end
    return result
  end

  return sessions
end

---Restore the selected directory through persistence's branch-aware loading.
---@param session SessionRecord
---@return any result Persistence load result.
function M.restore(session)
  ensure_setup()
  vim.cmd.tcd(vim.fn.fnameescape(session.cwd))
  return M.load()
end

---Restore the current or last session.
---@param opts? table Persistence load options.
---@return any result Persistence load result.
function M.load(opts)
  ensure_setup()
  opts = opts or {}
  if not opts.last and should_skip_current_session() then
    return
  end

  local result = raw_load(opts)
  tabs.restore_state()
  return result
end

---Save the current session and its tabpage state.
---@return any result Persistence save result.
function M.save()
  ensure_setup()
  if should_skip_current_session() then
    return
  end

  tabs.save_state()
  local result = raw_save()
  tabs.append_state(persistence.current())
  return result
end

---Delete a session file and its optional display name.
---@param session SessionRecord
---@return boolean deleted True when the session file was deleted.
function M.delete(session)
  ensure_setup()
  local deleted = os.remove(session.id) == true
  if deleted then
    local names = read_session_names()
    if names[session.id] then
      names[session.id] = nil
      write_session_names(names)
    end
  end
  return deleted
end

---Rename a session's display name without changing its persistence path.
---@param session SessionRecord
---@param name string? Empty or nil clears the custom display name.
---@return boolean renamed True when metadata was written.
function M.rename(session, name)
  ensure_setup()
  local names = read_session_names()
  name = vim.trim(name or "")
  if name == "" then
    names[session.id] = nil
  else
    names[session.id] = name
  end
  write_session_names(names)
  return true
end

return M
