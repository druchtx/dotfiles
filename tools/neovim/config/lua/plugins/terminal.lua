-- Reuse one bottom terminal per tabpage for shell work related to the active tab.
local tab_terminals = {}

local terminal_win = {
  position = "bottom",
  height = 0.4,
}

local function current_snacks_terminal()
  local current_buffer = vim.api.nvim_get_current_buf()

  for _, terminal in ipairs(Snacks.terminal.list()) do
    if terminal.buf == current_buffer then
      return terminal
    end
  end
end

local function toggle_tab_terminal()
  -- Ctrl-/ hides whichever Snacks terminal is focused, including LazyGit.
  local current_terminal = current_snacks_terminal()
  if current_terminal then
    current_terminal:hide()
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local terminal = tab_terminals[tab]

  if terminal and terminal:buf_valid() then
    terminal:show():focus()
    return
  end

  -- Capture the active window's cwd only when creating the terminal. Future
  -- toggles reuse its running shell even if the tab's cwd later changes.
  tab_terminals[tab] = Snacks.terminal.open(nil, {
    cwd = vim.fn.getcwd(),
    win = vim.deepcopy(terminal_win),
  })
end

return {
  "folke/snacks.nvim",
  keys = {
    {
      "<C-/>",
      toggle_tab_terminal,
      desc = "Toggle tab terminal",
      mode = { "n", "t" },
    },
    -- Most terminals send Ctrl-/ as Ctrl-_. Keep this alias so the mapping
    -- works consistently in both normal and terminal mode.
    {
      "<C-_>",
      toggle_tab_terminal,
      desc = "Toggle tab terminal",
      mode = { "n", "t" },
    },
  },
}
