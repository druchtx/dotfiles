return {
  "saghen/blink.cmp",
  optional = true,
  opts = {
    completion = {
      menu = {
        auto_show = true,
      },
    },
    keymap = {
      -- Overrides Vim's default insert-mode <C-e>, which copies a character from the next line.
      ["<C-e>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.cancel()
          end
          return cmp.show()
        end,
      },
    },
  },
}
