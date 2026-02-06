return {
  "snacks.nvim",
  -- Snacks already uses <a-w> to cycle picker windows. Preview buffers can
  -- become real file buffers, so we reapply the same key there to keep picker
  -- navigation consistent without overriding native <c-w> behavior.
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
        end, {
          buffer = buf,
          desc = "Cycle Picker Window",
          nowait = true,
          silent = true,
        })
      end,
    })
  end,
  ---@param opts snacks.Config
  opts = function(_, opts)
    local picker_utils = require("shared.snacks_picker")

    opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
      enabled = true,
      hidden = true,
      ignored = false,
      follow = true,
      layouts = {
        -- Compact layout used by vim.ui.select-style pickers, such as sessions
        -- and small action menus.
        select = {
          layout = {
            width = 0.4,
            min_width = 40,
            max_width = 80,
            height = 0.3,
          },
        },
      },
      sources = {
        -- File pickers should behave like an explicit filesystem browser:
        -- include hidden and ignored files, but still drop .DS_Store noise.
        files = {
          hidden = true,
          ignored = true,
          exclude = picker_utils.ds_store_exclude,
        },
        -- Grep stays closer to project search defaults so results are not
        -- polluted by hidden or ignored paths unless toggled manually.
        grep = {
          hidden = false,
          ignored = false,
        },
      },
    })
  end,
}
