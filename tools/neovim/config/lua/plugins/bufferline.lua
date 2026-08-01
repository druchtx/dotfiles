-- Show open file buffers in a theme-aware tab line.
local function keep_last_bufferline_buffer_visible()
  local last_bufferline_buffer

  local function is_listed_buffer(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end

  -- Special-buffer compatibility: Bufferline only renders listed buffers. When
  -- focus enters any unlisted buffer, it has no current item to anchor overflow
  -- around. Keep the last listed buffer selected until focus returns to one.
  local buffer = require("bufferline.models").Buffer
  local original_current = buffer.current
  function buffer:current()
    if not is_listed_buffer(vim.api.nvim_get_current_buf()) and is_listed_buffer(last_bufferline_buffer) then
      return self.id == last_bufferline_buffer
    end
    return original_current(self)
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = vim.api.nvim_create_augroup("bufferline_last_file", { clear = true }),
    callback = function(args)
      if is_listed_buffer(args.buf) then
        last_bufferline_buffer = args.buf
      end
      vim.cmd("redrawtabline")
    end,
  })
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = "nvim-tree/nvim-web-devicons",

  -- Custom navigation: cycle through open buffers with Shift-H / Shift-L.
  keys = {
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  },
  opts = {
    -- Theme integration: derive colors from Normal so inactive buffers blend into
    -- the active colorscheme instead of using a separate black background.
    -- Visible buffers stay readable when focus moves to Neo-tree or another pane.
    highlights = function()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local background = string.format("#%06x", normal.bg)

      return {
        background = { bg = background },
        buffer_visible = { bg = background, fg = string.format("#%06x", normal.fg), bold = true },
        fill = { bg = background },
        indicator_selected = { fg = string.format("#%06x", normal.fg) },
        indicator_visible = { fg = string.format("#%06x", normal.fg) },
        separator = { bg = background, fg = background },
        separator_visible = { bg = background, fg = background },
      }
    end,

    -- Bufferline behavior: keep LSP diagnostics and thin separators, while hiding
    -- close buttons to reduce visual noise.
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      separator_style = "thin",
      show_buffer_close_icons = false,
      show_close_icon = false,
    },
  },

  config = function(_, opts)
    require("bufferline").setup(opts)
    keep_last_bufferline_buffer_visible()
  end,
}
