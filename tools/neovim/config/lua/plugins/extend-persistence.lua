local function decode_session(session)
  local config = require("persistence.config")
  local file = session:sub(#config.options.dir + 1, -5)
  local dir = vim.split(file, "%%", { plain = true })[1]:gsub("%%", "/")

  if jit.os:find("Windows") then
    dir = dir:gsub("^(%w)/", "%1:/")
  end

  return dir
end

local function session_items()
  local persistence = require("persistence")
  local items = {}
  local seen = {}

  for _, session in ipairs(persistence.list()) do
    local stat = vim.uv.fs_stat(session)
    if stat then
      local dir = decode_session(session)
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

local function select_session()
  Snacks.picker.pick({
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

return {
  "folke/persistence.nvim",
  keys = {
    { "<leader>qS", false },
    {
      "<leader>qw",
      function()
        require("persistence").save()
      end,
      desc = "Save Session",
    },
    {
      "<leader>qs",
      function()
        require("persistence").select()
      end,
      desc = "Select Session",
    },
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)
    persistence.select = select_session
  end,
}
