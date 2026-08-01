-- Inspect Buffer changes and open the external Git UI.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Read-only hunk navigation and inspection.
        map("n", "]h", function()
          gitsigns.nav_hunk("next")
        end, "Next Git hunk")
        map("n", "[h", function()
          gitsigns.nav_hunk("prev")
        end, "Previous Git hunk")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Preview Git hunk")
        map("n", "<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, "Blame Git line")

        -- Stage only the current hunk or selected lines.
        map("n", "<leader>gs", gitsigns.stage_hunk, "Stage Git hunk")
        map("x", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selected Git lines")
      end,
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>gg",
        function()
          Snacks.lazygit({ cwd = vim.fn.getcwd() })
        end,
        desc = "Open lazygit",
      },
    },
    opts = {
      lazygit = {
      },
    },
  },
}
