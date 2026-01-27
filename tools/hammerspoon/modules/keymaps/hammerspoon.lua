-- ========================================
-- Hammerspoon System Keybindings
-- ========================================

return {
	{
		mods = { "ctrl", "shift" },
		key = "R",
		action = function()
			hs.openConsole()
		end,
		description = "Open Hammerspoon Console (view logs)",
	},
}
