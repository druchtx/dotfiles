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
  keys = {
    {
      "<leader>gd",
      "<cmd>DiffviewOpen<cr>",
      desc = "Git: Diffview",
    },
  },
  config = function()
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
