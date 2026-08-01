-- Save safely when another tool such like agent has changed the file on disk.
local M = {}

local uv = vim.uv or vim.loop

local function file_version(path)
  local stat = uv.fs_stat(path)
  if not stat then
    return nil
  end

  return {
    size = stat.size,
    sec = stat.mtime.sec,
    nsec = stat.mtime.nsec,
  }
end

local function same_version(left, right)
  return left
    and right
    and left.size == right.size
    and left.sec == right.sec
    and left.nsec == right.nsec
end

local function clear_diff(buf)
  vim.cmd("silent! diffoff!")

  local disk_win = vim.b[buf].sync_write_disk_win
  if disk_win and vim.api.nvim_win_is_valid(disk_win) then
    vim.api.nvim_win_close(disk_win, true)
  end

  vim.b[buf].sync_write_version = nil
  vim.b[buf].sync_write_disk_win = nil
end

local function show_conflict(buf, path)
  local lines = vim.fn.readfile(path, "b")
  local disk_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(disk_buf, path .. " [disk]")
  vim.api.nvim_buf_set_lines(disk_buf, 0, -1, false, lines)
  vim.bo[disk_buf].bufhidden = "wipe"
  vim.bo[disk_buf].buftype = "nofile"
  vim.bo[disk_buf].modifiable = false

  local source_win = vim.api.nvim_get_current_win()
  vim.cmd("leftabove vsplit")
  local disk_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(disk_win, disk_buf)

  vim.api.nvim_set_current_win(source_win)
  vim.cmd("diffthis")
  vim.api.nvim_set_current_win(disk_win)
  vim.cmd("diffthis")
  vim.api.nvim_set_current_win(source_win)

  vim.b[buf].sync_write_version = file_version(path)
  vim.b[buf].sync_write_disk_win = disk_win
  vim.notify("File changed on disk. Merge into the right buffer, then press Ctrl-S again to save.", vim.log.levels.WARN)
end

function M.write()
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local pending_conflict = vim.b[buf].sync_write_pending

  vim.b[buf].sync_write_pending = nil

  if path == "" or vim.bo[buf].buftype ~= "" then
    vim.notify("This buffer is not a file", vim.log.levels.WARN)
    return
  end

  if pending_conflict then
    show_conflict(buf, path)
    return
  end

  local merged_version = vim.b[buf].sync_write_version
  if merged_version then
    if same_version(merged_version, file_version(path)) then
      vim.cmd("write!")
      clear_diff(buf)
      return
    end

    clear_diff(buf)
  end

  local conflict = false
  local check_id = vim.api.nvim_create_autocmd("FileChangedShell", {
    buffer = buf,
    callback = function()
      if vim.v.fcs_reason == "conflict" then
        conflict = true
        vim.v.fcs_choice = ""
      elseif vim.v.fcs_reason == "changed" then
        vim.v.fcs_choice = "reload"
      end
    end,
  })

  vim.cmd("checktime " .. buf)
  pcall(vim.api.nvim_del_autocmd, check_id)

  if conflict then
    show_conflict(buf, path)
  elseif vim.bo[buf].modified then
    vim.cmd("write")
  end
end

return M
