-- Browse directories and show file Git status.
local function is_sidebar(win)
  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree"
end

local source_labels = {
  filesystem = "Filesystem",
  git_status = "Git",
  buffers = "Buffers",
}

local function show_current_source(state)
  if not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
    return
  end

  -- Custom winbar: show only the active source at Neo-tree's right edge. This
  -- replaces the full source selector so it does not compete with Bufferline.
  local label = source_labels[state.name] or state.name
  vim.wo[state.winid].winbar = string.format("%%=%%#NeoTreeSourceLabel# %s ", label)
end

local function copy_node_name(state)
  local node = state.tree:get_node()
  if not node or not node.name then
    return
  end

  -- Custom copy: Neo-tree's rendered line includes icons and Git status. Copy
  -- the node name itself to both Neovim's unnamed register and macOS clipboard.
  vim.fn.setreg('"', node.name)
  vim.fn.setreg("+", node.name)
  vim.notify("Copied filename: " .. node.name, vim.log.levels.INFO)
end

local function move_node_to_trash(state)
  local node = state.tree:get_node()
  if not node or not node.path then
    return
  end

  local choice = vim.fn.confirm(
    string.format("Move %s to the Trash?", node.name),
    "&Trash\n&Cancel",
    2
  )
  if choice ~= 1 then
    return
  end

  -- macOS provides /usr/bin/trash, which is recoverable through Finder's
  -- Trash instead of Neo-tree's default permanent delete action.
  vim.system({ "/usr/bin/trash", node.path }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify("Could not move to Trash: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
        return
      end

      vim.cmd("Neotree filesystem refresh")
      vim.notify("Moved to Trash: " .. node.name, vim.log.levels.INFO)
    end)
  end)
end

local function reveal_current_file()
  local sidebar_was_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_sidebar(win) then
      sidebar_was_open = true
      break
    end
  end

  -- Reveal the active file instead of opening an unrelated project root.
  vim.cmd("Neotree filesystem reveal right")

  if sidebar_was_open then
    return
  end

  -- Opening a sidebar alongside multiple editor columns should preserve their
  -- equal-width layout instead of shrinking only the window next to Neo-tree.
  vim.schedule(function()
    local editor_columns = {}
    local available_width = 0
    local has_sidebar = false

    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative == "" then
        if is_sidebar(win) then
          has_sidebar = true
        else
          local column = vim.api.nvim_win_get_position(win)[2]
          if not editor_columns[column] then
            editor_columns[column] = win
            available_width = available_width + vim.api.nvim_win_get_width(win)
          end
        end
      end
    end

    local columns = vim.tbl_keys(editor_columns)
    if not has_sidebar or #columns < 2 then
      return
    end

    table.sort(columns)
    local width = math.floor(available_width / #columns)
    local remaining = available_width
    for index, column in ipairs(columns) do
      local target = index == #columns and remaining or width
      vim.api.nvim_win_set_width(editor_columns[column], target)
      remaining = remaining - target
    end
  end)
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>e",
      reveal_current_file,
      desc = "Explorer (cwd)",
    },
  },
  opts = {
    enable_git_status = true,
    enable_diagnostics = false,

    -- The active source is rendered as a compact right-aligned winbar label by
    -- the after_render handler below, instead of showing all source tabs.
    source_selector = {
      winbar = false,
      statusline = false,
    },
    event_handlers = {
      { event = "after_render", handler = show_current_source },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      window = {
        mappings = {
          ["/"] = "filter_on_submit",
          ["Y"] = { copy_node_name, desc = "Copy filename" },
          ["d"] = { move_node_to_trash, desc = "Move to Trash" },
        },
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)

    local function match_sidebar_background()
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "Normal" })

      -- Keep Neo-tree's row selection neutral while CursorLine is blue in editors.
      vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#30363d", bold = true })

      -- Custom label color: use the normal foreground because NeoTreeTabActive
      -- is unset when the built-in source selector is disabled.
      vim.api.nvim_set_hl(0, "NeoTreeSourceLabel", { link = "Normal" })
    end

    match_sidebar_background()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("neotree_sidebar_background", { clear = true }),
      callback = match_sidebar_background,
    })
  end,
}
