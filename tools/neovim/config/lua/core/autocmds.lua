-- Keep Normal Mode commands on the ABC input source.
local hammerspoon = "/opt/homebrew/bin/hs"
local english_input_method = "com.apple.keylayout.ABC"
if vim.fn.executable(hammerspoon) == 1 then
  local switch_pending = false
  local switch_command = ([[
    local target = "%s"
    if hs.keycodes.currentSourceID() ~= target then
      return hs.keycodes.currentSourceID(target)
    end
    return true
  ]]):format(english_input_method)

  local function switch_to_english_in_normal_mode()
    if switch_pending or vim.api.nvim_get_mode().mode:match("^i") then
      return
    end

    switch_pending = true
    vim.system({ hammerspoon, "-c", switch_command }, {}, function()
      switch_pending = false
    end)
  end

  vim.api.nvim_create_autocmd({ "InsertLeave", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("english_input_method", { clear = true }),
    desc = "Use the English input method outside Insert mode",
    callback = switch_to_english_in_normal_mode,
  })
end
