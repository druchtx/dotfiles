-- Provide a small start screen for opening work quickly.
return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      enabled = true,
      width = 36,
      sections = {
        {
          gap = 1,
          padding = 1,
          {
            icon = " ",
            key = "n",
            desc = "New",
            action = function()
              vim.cmd.enew()
            end,
          },
	  -- disable the <leader>e keybinding
          {
            key = "<leader>e",
            hidden = true,
            action = function() end,
          },
          {
            icon = " ",
            key = "e",
            desc = "Explorer",
            action = function()
              vim.cmd("Neotree filesystem float dir=" .. vim.fn.fnameescape(vim.fn.getcwd()))
            end,
          },
          {
            icon = " ",
            key = "p",
            desc = "Project",
            action = function()
              require("features.projects").pick()
            end,
          },
          {
            icon = " ",
            key = "S",
            desc = "Sessions",
            action = function()
              require("persistence").select()
            end,
          },
          {
            icon = " ",
            key = "l",
            desc = "Restore",
            action = function()
              require("persistence").load({ last = true })
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = function()
              Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
            end,
          },
        },
      },
    },
  },
}
