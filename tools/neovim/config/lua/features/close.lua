-- Close buffers and windows without unexpectedly collapsing the editor layout.
local M = {}

local function confirm_save_or_discard(action)
  if not vim.bo.modified then
    action(false)
    return
  end

  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  local choice = vim.fn.confirm(
    "Save changes to " .. name .. "?",
    "&Save and close\n&Discard changes\n&Cancel",
    3
  )

  if choice == 1 then
    vim.cmd.write()
    action(false)
  elseif choice == 2 then
    action(true)
  end
end

local function delete_current_buffer(force)
  local current = vim.api.nvim_get_current_buf()
  local has_other_file = false

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      has_other_file = true
      break
    end
  end

  if has_other_file then
    vim.cmd("BufferLineCyclePrev")
  else
    vim.cmd("enew")
  end

  vim.api.nvim_buf_delete(current, { force = force })
end

function M.buffer()
  confirm_save_or_discard(delete_current_buffer)
end

function M.window()
  confirm_save_or_discard(function(force)
    vim.cmd(force and "close!" or "close")
  end)
end

function M.all()
  -- Use Neovim's native save/discard/cancel dialog for every modified buffer.
  vim.cmd("confirm qall")
end

-- Feature mappings: keep every close action beside its confirmation behavior.
vim.keymap.set("n", "<leader>bq", M.buffer, { desc = "Quit buffer" })
vim.keymap.set("n", "<leader>wq", M.window, { desc = "Quit window" })
vim.keymap.set("n", "<leader><tab>q", "<cmd>tabclose<cr>", { desc = "Quit tabpage" })
vim.keymap.set("n", "<leader>qq", M.all, { desc = "Save all and quit Neovim" })

return M
