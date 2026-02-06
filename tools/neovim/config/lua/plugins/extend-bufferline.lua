return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.show_buffer_close_icons = false
    opts.options.show_close_icon = false
    opts.options.show_tab_indicators = false

    vim.api.nvim_set_hl(0, "BufferLineTabUnderlineActive", { fg = "#57ab5a", bg = "NONE" })
    vim.api.nvim_set_hl(0, "BufferLineTabUnderlineInactive", { fg = "#768390", bg = "NONE" })

    opts.options.custom_areas = opts.options.custom_areas or {}
    opts.options.custom_areas.right = function()
      local current = vim.api.nvim_get_current_tabpage()
      local tabs = vim.api.nvim_list_tabpages()
      if #tabs < 2 then
        return {}
      end

      local items = {}
      for i, tab in ipairs(tabs) do
        items[#items + 1] = {
          text = "%" .. i .. "T" .. "▁▁" .. "%T",
          link = tab == current and "BufferLineTabUnderlineActive" or "BufferLineTabUnderlineInactive",
        }
        if i < #tabs then
          items[#items + 1] = { text = " ", bg = "NONE" }
        end
      end
      return items
    end

    local function clear_bg(name)
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      if ok and hl then
        hl.bg = nil
        ---@diagnostic disable-next-line:param-type-mismatch
        pcall(vim.api.nvim_set_hl, 0, name, hl)
      end
    end

    local function apply()
      for _, name in ipairs({
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineBufferVisible",
        "BufferLineBufferSelected",
        "BufferLineTab",
        "BufferLineTabSelected",
        "BufferLineTabSeparator",
        "BufferLineTabSeparatorSelected",
        "BufferLineSeparator",
        "BufferLineSeparatorSelected",
        "BufferLineSeparatorVisible",
      }) do
        clear_bg(name)
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("bufferline_transparent", { clear = true }),
      callback = apply,
    })

    vim.api.nvim_create_autocmd({ "TabEnter", "TabNewEntered", "TabClosed" }, {
      group = vim.api.nvim_create_augroup("bufferline_tab_indicator_refresh", { clear = true }),
      callback = function()
        vim.schedule(function()
          vim.cmd.redrawtabline()
        end)
      end,
    })

    vim.schedule(apply)
  end,
}
