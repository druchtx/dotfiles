local function to_hex(color)
  if not color then
    return nil
  end
  return string.format("#%06x", color)
end

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

local function clear_background_highlight(target)
  vim.api.nvim_set_hl(0, target, { bg = "NONE", sp = "NONE" })
end

local function git_systemlist(args)
  local output = vim.fn.systemlist(args)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return output
end

local function get_current_branch()
  local output = git_systemlist({ "git", "branch", "--show-current" })
  if not output or not output[1] or output[1] == "" then
    return nil
  end
  return vim.trim(output[1])
end

local function get_upstream_ref()
  local output = git_systemlist({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
  if not output or not output[1] or output[1] == "" then
    return nil
  end
  return vim.trim(output[1])
end

local function list_branch_refs()
  local refs = git_systemlist({ "git", "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" })
  if not refs then
    return {}
  end

  local result = {}
  local seen = {}
  table.sort(refs)
  for _, ref in ipairs(refs) do
    ref = vim.trim(ref)
    if ref ~= "" and ref ~= "HEAD" and not ref:match("/HEAD$") and not seen[ref] then
      seen[ref] = true
      table.insert(result, ref)
    end
  end

  return result
end

local function prioritize_refs(refs, priorities)
  local seen = {}
  local result = {}

  for _, ref in ipairs(refs) do
    seen[ref] = true
  end

  for _, ref in ipairs(priorities) do
    if ref and seen[ref] then
      table.insert(result, ref)
      seen[ref] = nil
    end
  end

  for _, ref in ipairs(refs) do
    if seen[ref] then
      table.insert(result, ref)
      seen[ref] = nil
    end
  end

  return result
end

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

  vim.cmd({
    cmd = "DiffviewOpen",
    args = { source .. "..." .. target, "--imply-local" },
  })
end

local function pick_ref(prompt, refs, on_choice)
  if #refs == 0 then
    vim.notify("No git refs found for comparison", vim.log.levels.WARN)
    return
  end

  vim.ui.select(refs, {
    prompt = prompt,
  }, function(choice)
    if choice then
      on_choice(choice)
    end
  end)
end

local function compare_pick_source_target()
  local refs = list_branch_refs()
  refs = prioritize_refs(refs, { get_current_branch(), get_upstream_ref(), "origin/main", "origin/master" })

  pick_ref("Select source branch:", refs, function(source)
    pick_ref("Select target branch:", refs, function(target)
      open_compare(source, target)
    end)
  end)
end

local function set_diffview_syntax_preserving_highlights()
  set_bg_only_highlight("DiffviewDiffAdd", "DiffAdd")
  set_bg_only_highlight("DiffviewDiffChange", "DiffChange")
  set_bg_only_highlight("DiffviewDiffText", "DiffText")
  set_bg_only_highlight("DiffviewDiffDelete", "DiffDelete")
  clear_background_highlight("DiffviewDiffDeleteDim")
  set_bg_only_highlight("DiffviewDiffAddAsDelete", "DiffDelete")
end

local function configure_diffview_buffer(bufnr, ctx)
  local windows = vim.fn.win_findbuf(bufnr)
  for _, winid in ipairs(windows) do
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_set_option_value("wrap", false, { win = winid })
    end
  end
end

local function set_window_option_if_valid(winid, name, value)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_option_value(name, value, { win = winid })
  end
end

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

  if left_window then
    left_window:use_winopts({ wrap = false, winhl = vim.split(left_winhl, ",") })
  end
  if right_window then
    right_window:use_winopts({ wrap = false, winhl = vim.split(right_winhl, ",") })
  end
end

local function configure_current_diffview_layout()
  local ok, lib = pcall(require, "diffview.lib")
  if not ok then
    return
  end

  local view = lib.get_current_view()
  if not view then
    return
  end

  configure_diffview_layout(view)
end

return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewCompare" },
  config = function()
    vim.api.nvim_create_user_command("DiffviewCompare", function(opts)
      if #opts.fargs == 2 then
        open_compare(opts.fargs[1], opts.fargs[2])
        return
      end

      compare_pick_source_target()
    end, {
      nargs = "*",
      complete = function()
        return list_branch_refs()
      end,
      desc = "Compare two git branches with Diffview",
    })

    require("diffview").setup({
      enhanced_diff_hl = true,
      hooks = {
        --test
        --#region
        diff_buf_read = function(bufnr, ctx)
          configure_diffview_buffer(bufnr, ctx)
        end,
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
  end,
}
