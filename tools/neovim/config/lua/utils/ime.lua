-- Keep Normal mode on the English macOS input source through Hammerspoon.
local M = {}

local defaults = {
  hammerspoon_cli = "/opt/homebrew/bin/hs",
  english_input_method = "com.apple.keylayout.ABC",
}

---@class ImeOptions
---@field hammerspoon_cli? string Absolute path to the Hammerspoon hs CLI
---@field english_input_method? string macOS input source ID used outside Insert mode

---@param opts? ImeOptions User overrides for the default IME integration
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  if vim.fn.executable(opts.hammerspoon_cli) ~= 1 then
    return
  end

  local function switch_to_english_in_normal_mode()
    if vim.api.nvim_get_mode().mode:match("^i") then
      return
    end

    local command = ('return hs.keycodes.currentSourceID("%s")'):format(opts.english_input_method)
    vim.system({ opts.hammerspoon_cli, "-c", command })
  end

  vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "WinEnter", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("dotfiles_normal_mode_input_method", { clear = true }),
    desc = "Use the English input method outside Insert mode",
    callback = switch_to_english_in_normal_mode,
  })
end

return M
