---Session selection and persistence.nvim integration.
---
---This module wraps persistence.nvim so temporary project sessions are hidden
---and skipped, exposes a Snacks picker for session selection/deletion, and
---connects session save/load with tab workspace persistence in `config.tabs`.

local M = {}

---Decode a persistence.nvim session file path back into its project directory.
---@param session string Absolute session file path
---@return string dir Decoded project directory
local function decode_session_dir(session)
  local config = require("persistence.config")
  local file = session:sub(#config.options.dir + 1, -5)
  local dir = vim.split(file, "%%", { plain = true })[1]:gsub("%%", "/")

  if jit.os:find("Windows") then
    dir = dir:gsub("^(%w)/", "%1:/")
  end

  return dir
end

---Return whether a directory belongs to a temporary project tree.
---@param dir string Directory path
---@return boolean temporary True when the path or basename starts with `tmp.`
local function is_temporary_dir(dir)
  local tail = vim.fn.fnamemodify(dir, ":t")
  return tail:match("^tmp%.") ~= nil or dir:match("[/\\]tmp%.[^/\\]+") ~= nil
end

---Return whether a session file belongs to a temporary project.
---@param session string Absolute session file path
---@return boolean temporary True when the encoded session name contains `tmp.`
local function is_temporary_session_file(session)
  return session:match("[/\\%%]tmp%.") ~= nil
end

---Return whether persistence should skip saving/loading the current cwd.
---@param persistence table persistence.nvim module
---@return boolean skip True when cwd or branch is temporary
local function should_skip_current_session(persistence)
  local tabs = require("config.tabs")
  local cwd = tabs.session_project() or vim.fn.getcwd()
  local branch = persistence.branch()
  return is_temporary_dir(cwd) or (branch and branch:match("^tmp%.") ~= nil)
end

---Build Snacks picker items from persistence.nvim sessions.
---
---Only the newest session per decoded directory is shown.
---@return table[] items Session picker items sorted newest first
local function session_items()
  local persistence = require("persistence")
  local items = {}
  local seen = {}

  for _, session in ipairs(persistence.list()) do
    local stat = vim.uv.fs_stat(session)
    if stat then
      local dir = decode_session_dir(session)
      if not seen[dir] then
        seen[dir] = true
        items[#items + 1] = {
          session = session,
          dir = dir,
          file = dir,
          text = vim.fn.fnamemodify(dir, ":p:~"),
          mtime = stat.mtime.sec,
        }
      end
    end
  end

  table.sort(items, function(a, b)
    return a.mtime > b.mtime
  end)

  return items
end

---Change cwd to the selected session directory and load its session.
---@param item? table Session picker item
local function load_session(item)
  if not item then
    return
  end

  require("config.tabs").set_session_project(item.dir)
  vim.fn.chdir(item.dir)
  require("persistence").load()
end

---Delete selected session files from disk and refresh the picker.
---@param picker table Snacks picker instance
local function delete_sessions(picker)
  for _, item in ipairs(picker:selected({ fallback = true })) do
    if item.session then
      os.remove(item.session)
    end
  end
  picker:refresh()
end

---Open the custom session picker.
---
---`<c-x>` deletes the selected session file; confirming loads the session.
function M.select()
  require("snacks").picker.pick({
    title = "Sessions",
    finder = session_items,
    format = "file",
    preview = "none",
    layout = {
      preset = "select",
    },
    confirm = function(picker, item)
      picker:close()
      load_session(item)
    end,
    actions = {
      delete_session = delete_sessions,
    },
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "delete_session", mode = { "n", "i" } },
        },
      },
    },
  })
end

---Patch persistence.nvim with local filtering and tab workspace hooks.
---
---The wrapper preserves persistence's public API while:
---1. hiding temporary sessions from `list`;
---2. skipping save/load in temporary cwd/branch contexts;
---3. restoring tab workspace state after load;
---4. appending tab workspace state after save.
---@param persistence table persistence.nvim module
function M.patch(persistence)
  local config = require("persistence.config")
  local list = persistence.list
  local load = persistence.load
  local save = persistence.save

  -- Persistence encodes session names from paths. tmp.* entries are created by
  -- temporary project directories and should not appear in normal session flows.
  persistence.list = function()
    return vim.tbl_filter(function(session)
      return not is_temporary_session_file(session)
    end, list())
  end

  persistence.current = function(opts)
    opts = opts or {}
    local session_dir = require("config.tabs").session_project() or vim.fn.getcwd()
    local name = session_dir:gsub("[\\/:]+", "%%")
    if config.options.branch and opts.branch ~= false then
      local branch = persistence.branch()
      if branch and branch ~= "main" and branch ~= "master" then
        name = name .. "%%" .. branch:gsub("[\\/:]+", "%%")
      end
    end
    return config.options.dir .. name .. ".vim"
  end

  persistence.load = function(opts)
    opts = opts or {}
    if not opts.last and should_skip_current_session(persistence) then
      return
    end
    local ret = load(opts)
    require("config.tabs").restore_session_state()
    return ret
  end

  persistence.save = function()
    if should_skip_current_session(persistence) then
      return
    end
    local tabs = require("config.tabs")
    tabs.session_project()
    tabs.save_session_state()
    local ret = save()
    tabs.append_session_state(persistence.current())
    return ret
  end
end

return M
