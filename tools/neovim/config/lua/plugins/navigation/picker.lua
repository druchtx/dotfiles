-- Configure shared Snacks picker defaults and picker-specific navigation.
return {
  "snacks.nvim",
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpenProject<cr>", desc = "Git: Diffview" },
    { "<leader>gD", "<cmd>DiffviewCompare<cr>", desc = "Git: Compare branches" },
  },
  init = function()
    local Snacks = require("snacks")
    local group = vim.api.nvim_create_augroup("user.snacks_picker_preview_keys", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      group = group,
      callback = function()
        local win = vim.api.nvim_get_current_win()
        if vim.w[win]["snacks_picker_preview"] ~= true then
          return
        end
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.b[buf]["snacks_picker_preview_alt_w"] == true then
          return
        end
        vim.b[buf]["snacks_picker_preview_alt_w"] = true
        vim.keymap.set("n", "<a-w>", function()
          for _, picker in ipairs(Snacks.picker.get({ tab = true })) do
            if picker:current_win() then
              Snacks.picker.actions.cycle_win(picker)
              return
            end
          end
          vim.cmd("normal! w")
        end, { buffer = buf, desc = "Cycle Picker Window", nowait = true, silent = true })
      end,
    })
  end,
  opts = function(_, opts)
    opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
      enabled = true,
      hidden = true,
      ignored = false,
      follow = true,
      layouts = { select = { layout = { width = 0.4, min_width = 40, max_width = 80, height = 0.3 } } },
      sources = {
        files = { hidden = true, ignored = true, exclude = { ".DS_Store", "**/.DS_Store" } },
        grep = { hidden = false, ignored = false },
      },
    })
  end,
}
