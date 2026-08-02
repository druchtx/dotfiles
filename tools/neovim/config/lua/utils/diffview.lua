local git = require("utils.git_refs")

---Diffview integration for project-scoped Git workflows.
---
---This module keeps one Diffview tab per project, returns focus to the source
---workspace after closing Diffview, adds project-aware compare commands, and
---normalizes Diffview highlights/window options for the active colorscheme.

local M = {}

-- Diffview owns its own tabpages. Keep a project-root -> source-tab mapping so
-- closing a Diffview returns to the workspace that opened or focused it.
---@type table<string, integer>
local diffview_source_tabs = {}

---Convert a numeric Neovim color value to a CSS-style hex color.
---@param color? integer Neovim RGB integer
---@return string? hex Hex string such as `#57ab5a`
local function to_hex(color)
  if not color then
    return nil
  end
  return string.format("#%06x", color)
end

---Copy only background/special colors from one highlight group to another.
---@param target string Highlight group to update
---@param source string Highlight group to read
local function set_bg_only_highlight(target, source)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = source, link = false })
  if not ok then
    return
  end

  local spec = {}
  if hl.bg then
    spec.bg = to_hex(hl.bg)
  end
  if hl.sp then
    spec.sp = to_hex(hl.sp)
  end

  vim.api.nvim_set_hl(0, target, spec)
end

---Clear background and special color from a highlight group.
---@param target string Highlight group to update
local function clear_background_highlight(target)
  vim.api.nvim_set_hl(0, target, { bg = "NONE", sp = "NONE" })
end

---Resolve the Git root represented by a Diffview view object.
---@param view? table Diffview view object
---@return string? root Normalized project root
local function view_git_root(view)
  return view and view.adapter and view.adapter.ctx and git.root(view.adapter.ctx.toplevel)
end

---Remember which tab opened or focused a Diffview for a project.
---@param root? string Project root
---@param diffview_tab? integer Diffview-owned tabpage handle to ignore
local function remember_diffview_source(root, diffview_tab)
  if not root then
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  if diffview_tab and tab == diffview_tab then
    return
  end

  diffview_source_tabs[root] = tab
end

---Return focus to the tab that launched a Diffview view.
---@param view? table Diffview view object passed by Diffview hooks
local function return_to_diffview_source(view)
  local root = view_git_root(view)
  local tab = root and diffview_source_tabs[root]

  if root then
    diffview_source_tabs[root] = nil
  end

  if not tab then
    return
  end

  vim.schedule(function()
    if vim.api.nvim_tabpage_is_valid(tab) then
      vim.api.nvim_set_current_tabpage(tab)
    end
  end)
end

---Focus an existing Diffview tab for a project if one exists.
---@param root? string Project root
---@return boolean focused True when an existing Diffview tab was focused
local function focus_existing_diffview(root)
  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    return false
  end

  for _, view in ipairs(lib.views or {}) do
    if view_git_root(view) == root and vim.api.nvim_tabpage_is_valid(view.tabpage) then
      remember_diffview_source(root, view.tabpage)
      vim.api.nvim_set_current_tabpage(view.tabpage)
      return true
    end
  end

  return false
end

---Open Diffview for the current project, or focus its existing Diffview tab.
---@param args? string[] Diffview open arguments
function M.open_or_focus(args)
  -- The current tab workspace, not the current buffer path, is the source of
  -- truth for project-scoped Diffview operations.
  local root = git.current_project_root()
  if root and focus_existing_diffview(root) then
    return
  end

  remember_diffview_source(root)
  require("diffview").open(args or {})
end

---Open a branch comparison with Diffview.
---@param source? string Source branch/ref
---@param target? string Target branch/ref
local function open_compare(source, target)
  source = vim.trim(source or "")
  target = vim.trim(target or "")
  if source == "" or target == "" then
    vim.notify("Missing source or target branch for comparison", vim.log.levels.WARN)
    return
  end
  if source == target then
    vim.notify("Source and target branches are the same", vim.log.levels.WARN)
    return
  end

  M.open_or_focus({ source .. "..." .. target, "--imply-local" })
end

---Prompt for a Git ref and pass the choice to a callback.
---@param prompt string vim.ui.select prompt
---@param refs string[] Candidate refs
---@param on_choice fun(choice: string) Callback invoked with the selected ref
local function pick_ref(prompt, refs, on_choice)
  if #refs == 0 then
    vim.notify("No git refs found for comparison", vim.log.levels.WARN)
    return
  end

  vim.ui.select(refs, { prompt = prompt }, function(choice)
    if choice then
      on_choice(choice)
    end
  end)
end

---Interactively choose source and target refs for a Diffview comparison.
local function compare_pick_source_target()
  local root = git.current_project_root()
  local refs = git.branch_refs(root)
  refs = git.prioritize_refs(refs, {
    git.current_branch(root),
    git.upstream_ref(root),
    "origin/main",
    "origin/master",
  })

  pick_ref("Select source branch:", refs, function(source)
    local target_refs = vim.tbl_filter(function(ref)
      return ref ~= source
    end, refs)

    pick_ref("Select target branch:", target_refs, function(target)
      open_compare(source, target)
    end)
  end)
end

---Install Diffview diff highlights that preserve syntax foreground colors.
---
---Only diff backgrounds are copied so syntax groups inside changed lines remain
---readable with the active colorscheme.
local function set_diffview_syntax_preserving_highlights()
  set_bg_only_highlight("DiffviewDiffAdd", "DiffAdd")
  set_bg_only_highlight("DiffviewDiffChange", "DiffChange")
  set_bg_only_highlight("DiffviewDiffText", "DiffText")
  set_bg_only_highlight("DiffviewDiffDelete", "DiffDelete")
  clear_background_highlight("DiffviewDiffDeleteDim")
  set_bg_only_highlight("DiffviewDiffAddAsDelete", "DiffDelete")
end

---Configure a Diffview buffer after it is read.
---@param bufnr integer Buffer handle supplied by Diffview
local function configure_diffview_buffer(bufnr)
  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_set_option_value("wrap", false, { win = winid })
    end
  end
end

---Set a window-local option only when the window handle is valid.
---@param winid? integer Window handle
---@param name string Option name
---@param value any Option value
local function set_window_option_if_valid(winid, name, value)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_option_value(name, value, { win = winid })
  end
end

---Apply wrapping and highlight rules to Diffview's side-by-side windows.
---@param view? table Diffview view object
local function configure_diffview_layout(view)
  local layout = view and view.cur_layout
  local left_window = layout and layout.a
  local right_window = layout and layout.b
  local left_winid = left_window and left_window.id
  local right_winid = right_window and right_window.id
  local left_winhl = table.concat({
    "DiffAdd:DiffviewDiffAddAsDelete",
    "DiffDelete:Normal",
    "DiffChange:DiffviewDiffChange",
    "DiffText:DiffviewDiffText",
  }, ",")
  local right_winhl = table.concat({
    "DiffAdd:DiffviewDiffAdd",
    "DiffDelete:Normal",
    "DiffChange:DiffviewDiffChange",
    "DiffText:DiffviewDiffText",
  }, ",")

  set_window_option_if_valid(left_winid, "wrap", false)
  set_window_option_if_valid(right_winid, "wrap", false)
  set_window_option_if_valid(left_winid, "winhl", left_winhl)
  set_window_option_if_valid(right_winid, "winhl", right_winhl)

  -- Diffview recreates windows during layout changes, so update both the
  -- current Neovim window options and Diffview's reusable window templates.
  if left_window then
    left_window:use_winopts({ wrap = false, winhl = vim.split(left_winhl, ",") })
  end
  if right_window then
    right_window:use_winopts({ wrap = false, winhl = vim.split(right_winhl, ",") })
  end
end

---Apply layout configuration to the currently active Diffview view.
local function configure_current_diffview_layout()
  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    return
  end

  local view = lib.get_current_view()
  if view then
    configure_diffview_layout(view)
  end
end

---Create local Diffview commands that preserve project-scoped behavior.
local function create_commands()
  pcall(vim.api.nvim_del_user_command, "DiffviewOpen")
  vim.api.nvim_create_user_command("DiffviewOpen", function(opts)
    M.open_or_focus(opts.fargs)
  end, {
    nargs = "*",
    complete = function(arg_lead, cmd_line, cursor_pos)
      return require("diffview").completion(arg_lead, cmd_line, cursor_pos)
    end,
    desc = "Open or focus Diffview for the current project",
  })

  vim.api.nvim_create_user_command("DiffviewOpenProject", function(opts)
    M.open_or_focus(opts.fargs)
  end, {
    nargs = "*",
    desc = "Open or focus Diffview for the current project",
  })

  vim.api.nvim_create_user_command("DiffviewCompare", function(opts)
    if #opts.fargs == 2 then
      open_compare(opts.fargs[1], opts.fargs[2])
      return
    end

    compare_pick_source_target()
  end, {
    nargs = "*",
    complete = function()
      return git.branch_refs(git.current_project_root())
    end,
    desc = "Compare two git branches with Diffview",
  })
end

---Configure diffview.nvim and register commands/autocmds.
function M.setup()
  create_commands()

  require("diffview").setup({
    enhanced_diff_hl = true,
    hooks = {
      view_closed = return_to_diffview_source,
      diff_buf_read = configure_diffview_buffer,
    },
    keymaps = {
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<A-q>", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<A-q>", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
      file_history_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<A-q>", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
    },
  })

  set_diffview_syntax_preserving_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("dotfiles_diffview_highlights", { clear = true }),
    callback = set_diffview_syntax_preserving_highlights,
  })

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("dotfiles_diffview_layout", { clear = true }),
    pattern = { "DiffviewViewPostLayout", "DiffviewDiffBufWinEnter" },
    callback = configure_current_diffview_layout,
  })
end

return M
