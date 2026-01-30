-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Diff current buffer with another file
vim.api.nvim_create_user_command("DiffWith", function(opts)
  local other_file = opts.args
  if other_file == "" then
    vim.notify("Usage: :DiffWith <filepath>", vim.log.levels.ERROR)
    return
  end

  -- Expand path and check if file exists
  other_file = vim.fn.expand(other_file)
  if vim.fn.filereadable(other_file) == 0 then
    vim.notify("File not found: " .. other_file, vim.log.levels.ERROR)
    return
  end

  -- Store original window
  local orig_win = vim.api.nvim_get_current_win()
  local orig_filename = vim.fn.expand("%:t")
  local other_filename = vim.fn.fnamemodify(other_file, ":t")

  -- Enable diff for current buffer
  vim.cmd("diffthis")

  -- Create new vertical split with other file
  vim.cmd("vnew")
  local other_win = vim.api.nvim_get_current_win()
  local other_buf = vim.api.nvim_get_current_buf()

  -- Read other file
  vim.cmd("silent! read " .. vim.fn.fnameescape(other_file))
  vim.cmd("normal! ggdd")

  -- Configure other buffer
  vim.bo[other_buf].buftype = "nofile"
  vim.bo[other_buf].bufhidden = "wipe"
  vim.bo[other_buf].buflisted = false
  vim.bo[other_buf].swapfile = false
  vim.bo[other_buf].modifiable = false
  vim.api.nvim_buf_set_name(other_buf, other_filename .. " [COMPARE]")

  -- Enable diff
  vim.cmd("diffthis")

  -- Set winbar for both windows
  vim.wo[orig_win].winbar = "%#DiagnosticSignInfo# 󰽙 " .. orig_filename .. " (Current)%*"
  vim.wo[other_win].winbar = "%#DiagnosticSignWarn# 󰪺 " .. other_filename .. " (Compare)%*"

  -- Go back to original window
  vim.api.nvim_set_current_win(orig_win)
end, { nargs = 1, complete = "file", desc = "Diff current buffer with another file" })

-- Function to close diff view
local function close_diff()
  if vim.wo.diff then
    vim.cmd("diffoff!")
    vim.cmd("only")
    vim.wo.winbar = ""
  end
end

-- Auto-set Ctrl+C keybinding when entering diff mode
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "diff",
  callback = function()
    if vim.wo.diff then
      -- In diff mode: map Ctrl+C to close diff
      vim.keymap.set("n", "<C-c>", close_diff, { buffer = true, desc = "Close diff view" })
    else
      -- Not in diff mode: unmap Ctrl+C
      pcall(vim.keymap.del, "n", "<C-c>", { buffer = true })
    end
  end,
  desc = "Setup Ctrl+C to close diff view",
})

-- Toggle diff between current buffer and file on disk
vim.api.nvim_create_user_command("DiffDisk", function()
  -- Check if we're already in diff mode
  if vim.wo.diff then
    close_diff()
  else
    -- Get current file info
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")
    local ft = vim.bo.filetype

    -- Check if file exists on disk
    if vim.fn.filereadable(filepath) == 0 then
      vim.notify("File not saved to disk yet", vim.log.levels.WARN)
      return
    end

    -- Store original window and enable diff
    local orig_win = vim.api.nvim_get_current_win()
    vim.cmd("diffthis")

    -- Create new vertical split with disk version
    vim.cmd("vnew")
    local disk_win = vim.api.nvim_get_current_win()
    local disk_buf = vim.api.nvim_get_current_buf()

    -- Read file from disk into new buffer
    vim.cmd("silent! read " .. vim.fn.fnameescape(filepath))
    vim.cmd("normal! ggdd") -- Remove extra blank line at top

    -- Configure disk buffer
    vim.bo[disk_buf].filetype = ft
    vim.bo[disk_buf].buftype = "nofile"
    vim.bo[disk_buf].bufhidden = "wipe"
    vim.bo[disk_buf].buflisted = false
    vim.bo[disk_buf].swapfile = false
    vim.bo[disk_buf].modifiable = false
    vim.api.nvim_buf_set_name(disk_buf, filename .. " [DISK]")

    -- Enable diff for disk buffer
    vim.cmd("diffthis")

    -- Set winbar (top bar) for both windows to show source
    vim.wo[orig_win].winbar = "%#DiagnosticSignInfo# 󰽙 Buffer (Unsaved)%*"
    vim.wo[disk_win].winbar = "%#DiagnosticSignWarn# 󰪺 Disk (Saved)%*"

    -- Go back to original window
    vim.api.nvim_set_current_win(orig_win)
  end
end, { desc = "Toggle diff: buffer vs disk file" })
