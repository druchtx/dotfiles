local function open_explorer(opts)
  local explorer = require("utils.explorer")
  return require("snacks").picker.explorer(explorer.options(opts))
end

local function open_current_directory()
  open_explorer()
end

local function open_root_directory()
  open_explorer({ cwd = LazyVim.root() })
end

local function register_commands()
  vim.api.nvim_create_user_command("ExplorerCwd", open_current_directory, {
    force = true,
    desc = "Open Explorer in the current working directory",
  })
  vim.api.nvim_create_user_command("ExplorerRoot", open_root_directory, {
    force = true,
    desc = "Open Explorer in the project root",
  })
end

return {
  "snacks.nvim",
  keys = {
    { "<leader>fe", "<cmd>ExplorerCwd<cr>", desc = "Explorer Snacks (cwd)" },
    { "<leader>fE", "<cmd>ExplorerRoot<cr>", desc = "Explorer Snacks (Root Dir)" },
    { "<leader>e", "<cmd>ExplorerCwd<cr>", desc = "Explorer Snacks (cwd)" },
    { "<leader>E", "<cmd>ExplorerRoot<cr>", desc = "Explorer Snacks (Root Dir)" },
  },
  opts = function(_, opts)
    register_commands()
    local explorer = require("utils.explorer")
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}
    opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, explorer.options({
      auto_close = false,
      hidden = true,
      ignored = true,
      exclude = { ".DS_Store", "**/.DS_Store" },
      win = {
        input = { keys = { ["?"] = { "toggle_help_input", mode = { "n", "i" } } } },
      },
    }))
  end,
}
