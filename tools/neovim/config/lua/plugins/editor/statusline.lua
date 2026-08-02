return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Mirror LazyVim's status sections while keeping a compact, arrow-free UI.
    opts.options.theme = "auto"
    opts.options.globalstatus = true
    opts.options.disabled_filetypes = {
      statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
    }
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }
    opts.sections.lualine_a = {
      {
        "mode",
        fmt = function(mode)
          return mode:sub(1, 1)
        end,
      },
    }
    opts.sections.lualine_b = { "branch" }
    opts.sections.lualine_c = {
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
    }
    opts.sections.lualine_x = {
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
    }
    opts.sections.lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    }
    opts.sections.lualine_z = {
      function()
        return " " .. os.date("%R")
      end,
    }
    opts.extensions = { "lazy", "fzf" }
  end,
}
