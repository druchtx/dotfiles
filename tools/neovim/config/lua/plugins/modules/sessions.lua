local M = {}

local function decode_session_dir(session)
  local config = require("persistence.config")
  local file = session:sub(#config.options.dir + 1, -5)
  local dir = vim.split(file, "%%", { plain = true })[1]:gsub("%%", "/")

  if jit.os:find("Windows") then
    dir = dir:gsub("^(%w)/", "%1:/")
  end

  return dir
end

local function is_temporary_dir(dir)
  local tail = vim.fn.fnamemodify(dir, ":t")
  return tail:match("^tmp%.") ~= nil or dir:match("[/\\]tmp%.[^/\\]+") ~= nil
end

local function is_temporary_session_file(session)
  return session:match("[/\\%%]tmp%.") ~= nil
end

local function should_skip_current_session(persistence)
  local branch = persistence.branch()
  return is_temporary_dir(vim.fn.getcwd()) or (branch and branch:match("^tmp%.") ~= nil)
end

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

local function load_session(item)
  if not item then
    return
  end

  vim.fn.chdir(item.dir)
  require("persistence").load()
end

local function delete_sessions(picker)
  for _, item in ipairs(picker:selected({ fallback = true })) do
    if item.session then
      os.remove(item.session)
    end
  end
  picker:refresh()
end

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

function M.patch(persistence)
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

  persistence.load = function(opts)
    opts = opts or {}
    if not opts.last and should_skip_current_session(persistence) then
      return
    end
    return load(opts)
  end

  persistence.save = function()
    if should_skip_current_session(persistence) then
      return
    end
    return save()
  end
end

return M
