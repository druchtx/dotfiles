-- Keep Normal Mode commands on the ABC input source.
local hammerspoon = "/opt/homebrew/bin/hs"
local english_input_method = "com.apple.keylayout.ABC"
if vim.fn.executable(hammerspoon) == 1 then
  local function switch_to_english_in_normal_mode()
    if vim.api.nvim_get_mode().mode:match("^i") then
      return
    end

    local command = ('return hs.keycodes.currentSourceID("%s")'):format(english_input_method)
    vim.system({ hammerspoon, "-c", command })
  end

  vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "WinEnter", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("english_input_method", { clear = true }),
    desc = "Use the English input method outside Insert mode",
    callback = switch_to_english_in_normal_mode,
  })
end

-- Do not let focus changes discard local edits after another tool changes a file.
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = vim.api.nvim_create_augroup("external_file_changes", { clear = true }),
  callback = function(event)
    if vim.v.fcs_reason ~= "conflict" then
      return
    end

    vim.v.fcs_choice = ""
    if vim.b[event.buf].sync_write_pending then
      return
    end

    vim.b[event.buf].sync_write_pending = true
    vim.schedule(function()
      vim.notify("File changed on disk. Press Ctrl-S to compare and merge.", vim.log.levels.WARN)
    end)
  end,
})
