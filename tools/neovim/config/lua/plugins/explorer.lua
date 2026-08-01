-- Browse directories and show file Git status.
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>e",
      "<cmd>Neotree filesystem toggle right dir=.<cr>",
      desc = "Toggle explorer",
    },
  },
  opts = {
    enable_git_status = true,
    enable_diagnostics = false,
    filesystem = {
      window = {
        mappings = {
          ["/"] = "filter_on_submit",
        },
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)

    local function match_sidebar_background()
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "Normal" })
    end

    match_sidebar_background()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("neotree_sidebar_background", { clear = true }),
      callback = match_sidebar_background,
    })
  end,
}
