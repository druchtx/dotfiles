-- Diffview.nvim - Git diff viewer with side-by-side comparison
local function open_compare(ref)
  ref = vim.trim(ref or "")
  if ref == "" then
    vim.notify("Missing Git ref for comparison", vim.log.levels.WARN)
    return
  end

  vim.cmd({
    cmd = "DiffviewOpen",
    args = { ref .. "...HEAD", "--imply-local" },
  })
end

local function get_upstream_ref()
  local output = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
  if vim.v.shell_error ~= 0 or not output[1] or output[1] == "" then
    return nil
  end
  return vim.trim(output[1])
end

local function compare_upstream()
  local upstream = get_upstream_ref()
  if upstream then
    open_compare(upstream)
    return
  end

  vim.notify("No upstream found. Falling back to origin/HEAD", vim.log.levels.INFO)
  open_compare("origin/HEAD")
end

local function get_current_branch()
  local output = vim.fn.systemlist({ "git", "branch", "--show-current" })
  if vim.v.shell_error ~= 0 or not output[1] or output[1] == "" then
    return nil
  end
  return vim.trim(output[1])
end

local function list_git_refs(namespaces)
  local cmd = { "git", "for-each-ref", "--format=%(refname:short)" }
  vim.list_extend(cmd, namespaces)

  local refs = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
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

local function compare_pick_local_branch()
  local refs = list_git_refs({ "refs/heads" })
  local current = get_current_branch()
  local filtered = {}
  for _, ref in ipairs(refs) do
    if ref ~= current then
      table.insert(filtered, ref)
    end
  end

  if #filtered == 0 then
    vim.notify("No other local branch found for comparison", vim.log.levels.WARN)
    return
  end

  vim.ui.select(filtered, {
    prompt = "Diff current branch against local branch:",
  }, function(choice)
    if choice then
      open_compare(choice)
    end
  end)
end

local function compare_pick_remote_branch()
  local refs = list_git_refs({ "refs/remotes" })
  refs = prioritize_refs(refs, { get_upstream_ref(), "origin/main", "origin/master" })
  if #refs == 0 then
    vim.notify("No remote branch found for comparison", vim.log.levels.WARN)
    return
  end

  vim.ui.select(refs, {
    prompt = "Diff current branch against remote branch:",
  }, function(choice)
    if choice then
      open_compare(choice)
    end
  end)
end

local function compare_pick_any_ref()
  local refs = list_git_refs({ "refs/heads", "refs/remotes", "refs/tags" })
  refs = prioritize_refs(refs, { get_upstream_ref(), "origin/main", "origin/master" })
  if #refs == 0 then
    vim.notify("Could not list refs. Use :DiffviewCompare <ref>", vim.log.levels.WARN)
    return
  end

  vim.ui.select(refs, {
    prompt = "Diff current branch against ref (branch/tag):",
  }, function(choice)
    if choice then
      open_compare(choice)
    end
  end)
end

return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy", -- Load early to override LazyVim defaults
  keys = {
    {
      "<leader>gd",
      function()
        local lib = require("diffview.lib")
        local view = lib.get_current_view()
        if view then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Git: Local Changes",
    },
    {
      "<leader>gD",
      compare_upstream,
      desc = "Git: Diff vs Upstream",
    },
    {
      "<leader>gC",
      compare_pick_remote_branch,
      desc = "Git: Diff vs Remote Branch",
    },
    {
      "<leader>gc",
      compare_pick_local_branch,
      desc = "Git: Diff vs Local Branch",
    },
    {
      "<leader>gf",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "Git: File History",
    },
    {
      "<leader>gl",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "Git: Commits Log",
    },
    {
      "<leader>gL",
      "<cmd>DiffviewFileHistory --all<cr>",
      desc = "Git: All Branches Log",
    },
  },
  config = function()
    vim.api.nvim_create_user_command("DiffviewCompare", function(opts)
      if opts.args ~= "" then
        open_compare(opts.args)
      else
        compare_pick_any_ref()
      end
    end, {
      nargs = "?",
      desc = "Compare current branch against branch/tag/commit",
    })

    -- Set custom colors for section headers
    vim.api.nvim_set_hl(0, "DiffviewFilePanelTitle", { fg = "#e0af68", bold = true }) -- Orange
    vim.api.nvim_set_hl(0, "DiffviewFilePanelCounter", { fg = "#9ece6a" }) -- Green

    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
      },
    })
  end,
}
