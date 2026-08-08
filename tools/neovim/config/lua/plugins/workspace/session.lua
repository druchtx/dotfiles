-- Session feature declaration. Session behavior lives in utils.session;
-- this file only assembles persistence, picker UI, commands, and keymaps.

local session = require("utils.session")

---Delete selected sessions from the picker.
---@param picker table Snacks picker instance.
local function delete_sessions(picker)
  for _, item in ipairs(picker:selected({ fallback = true })) do
    session.delete(item)
  end
  picker:refresh()
end

---Rename the selected session's display name.
---@param picker table Snacks picker instance.
local function rename_session(picker)
  local item = picker:selected({ fallback = true })[1]
  if not item then
    return
  end

  vim.ui.input({
    prompt = "Session name: ",
    default = item.name or item.cwd,
  }, function(value)
    if value ~= nil then
      session.rename(item, value)
      picker:refresh()
    end
  end)
end

---Open the session picker.
local function select_session()
  require("snacks").picker.pick({
    title = "Sessions",
    finder = function()
      return session.list({ mode = "directory" })
    end,
    format = function(item)
      return { { item.name or vim.fn.fnamemodify(item.cwd, ":t") } }
    end,
    preview = "none",
    layout = {
      preset = "select",
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        ---@cast item SessionRecord
        session.restore(item)
      end
    end,
    actions = {
      delete_session = delete_sessions,
      rename_session = rename_session,
    },
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "delete_session", mode = { "n", "i" } },
          ["<c-r>"] = { "rename_session", mode = { "n", "i" } },
        },
      },
    },
  })
end

return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  cmd = { "SessionSelect", "SessionLoadLast" },
  opts = {
    branch = true,
    -- Add path fragments here when a tool creates sessions to ignore.
    ignored_paths = {
      "tmp.",
    },
  },
  init = function()
    pcall(vim.keymap.del, "n", "<leader><tab>d")
  end,
  keys = {
    { "<leader>qS", false },
    { "<leader>qw", session.save, desc = "Save Session" },
    { "<leader>qs", select_session, desc = "Select Session" },
    {
      "<leader><tab>q",
      function()
        require("utils.tabpage").close()
      end,
      desc = "Close Tab",
    },
  },
  config = function(_, opts)
    session.setup(opts)
    vim.api.nvim_create_user_command("SessionSelect", select_session, { force = true })
    vim.api.nvim_create_user_command("SessionLoadLast", function()
      session.load({ last = true })
    end, { force = true })
  end,
}
