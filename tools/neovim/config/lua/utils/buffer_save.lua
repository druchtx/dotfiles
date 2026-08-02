-- Save directly unless the file was changed outside Neovim.
local M = {}
local disk_versions = {}
local setup_done = false

local function disk_version(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end

  -- A file's modification time, size, and inode together are a lightweight
  -- version marker that detects edits made by AI tools or another process.
  return table.concat({ stat.mtime.sec, stat.mtime.nsec, stat.size, stat.ino }, ":")
end

local function remember_disk_version(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  if path ~= "" and vim.bo[buf].buftype == "" then
    disk_versions[buf] = disk_version(path)
  end
end

local function save_new_buffer(buf)
  vim.ui.input({
    prompt = "Save as (relative to current directory): ",
  }, function(input)
    input = input and vim.trim(input) or ""
    if input == "" or not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    -- Expand home-relative paths and resolve relative names from the current
    -- directory before giving the unnamed buffer a file identity.
    local path = vim.fn.fnamemodify(vim.fn.expand(input), ":p")
    local saved, err = pcall(function()
      vim.api.nvim_buf_set_name(buf, path)
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent write")
      end)
    end)

    if not saved then
      vim.notify("Could not save " .. path .. ": " .. err, vim.log.levels.ERROR)
      return
    end

    remember_disk_version(buf)
    vim.notify("Saved " .. vim.fn.fnamemodify(path, ":~:."), vim.log.levels.INFO)
  end)
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("buffer_save_disk_versions", { clear = true }),
    callback = function(args)
      remember_disk_version(args.buf)
    end,
  })
end

function M.sync_and_save()
  -- Saving is a command-style action: leave Insert mode before writing.
  if vim.api.nvim_get_mode().mode:match("^i") then
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  end

  vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    local path = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].buftype ~= "" then
      vim.notify("This buffer is not a file", vim.log.levels.WARN)
      return
    end

    if path == "" then
      save_new_buffer(buf)
      return
    end

    local current_version = disk_version(path)
    if disk_versions[buf] and current_version ~= disk_versions[buf] then
      -- Let :edit show Neovim's native conflict prompt only when the disk copy
      -- changed after this buffer was last synchronized.
      vim.cmd("edit")
    end

    vim.cmd("silent write")
    remember_disk_version(buf)
    vim.notify("Saved " .. vim.fn.fnamemodify(path, ":~:."), vim.log.levels.INFO)
  end)
end

return M
