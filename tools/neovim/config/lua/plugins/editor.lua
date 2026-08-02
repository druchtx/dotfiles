-- Configure editing-focused UI enhancements.
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
  -- Show code nesting with subtle guides and a clearer current lexical scope.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local hooks = require("ibl.hooks")

      -- Keep ordinary nesting quiet and reserve a cool gray-blue for the scope
      -- containing the cursor. Reapply the colors after every theme change.
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#30363d" })
        vim.api.nvim_set_hl(0, "IblScope", { fg = "#8b949e" })
      end)

      require("ibl").setup({
        indent = {
          char = "▏",
          highlight = "IblIndent",
        },
        scope = {
          char = "│",
          highlight = "IblScope",
          show_start = false,
          show_end = false,
        },
      })
    end,
  },
  -- Show open file buffers in a theme-aware tab line.
  {
    "akinsho/bufferline.nvim",
    version = "*",
    -- BufEnter also covers :enew, which creates an unnamed buffer without a
    -- BufReadPost or BufNewFile event.
    event = { "BufReadPost", "BufNewFile", "BufEnter" },
    dependencies = "nvim-tree/nvim-web-devicons",
    -- Custom navigation: cycle through open buffers with Shift-H / Shift-L.
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      -- Theme integration: derive colors from Normal so inactive buffers blend
      -- into the active colorscheme instead of using a separate black background.
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
      -- Keep diagnostics and thin separators, while hiding close buttons to
      -- reduce visual noise.
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
  },
  -- Mirror LazyVim's default lualine sections without its framework helpers.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
          },
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              fmt = function(mode)
                return mode:sub(1, 1)
              end,
            },
          },
          lualine_b = { "branch" },
          lualine_c = {
            {
              function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
              end,
              icon = "󰉋",
            },
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1 },
          },
          lualine_x = {
            Snacks.profiler.status(),
            {
              function()
                return require("noice").api.status.command.get()
              end,
              cond = function()
                return package.loaded.noice and require("noice").api.status.command.has()
              end,
              color = function()
                return { fg = Snacks.util.color("Statement") }
              end,
            },
            {
              function()
                return "  " .. require("dap").status()
              end,
              cond = function()
                return package.loaded.dap and require("dap").status() ~= ""
              end,
              color = function()
                return { fg = Snacks.util.color("Debug") }
              end,
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function()
                return { fg = Snacks.util.color("Special") }
              end,
            },
            {
              "diff",
              symbols = { added = "+", modified = "~", removed = "-" },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "lazy", "fzf" },
      }
    end,
  },
}
