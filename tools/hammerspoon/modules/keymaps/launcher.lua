-- ========================================
-- Application Launcher Keybindings
-- ========================================

return {
	{
		mods = { "ctrl", "shift" },
		key = "G",
		action = function()
			hs.application.launchOrFocus("Ghostty")
		end,
		description = "Launch or focus Ghostty",
	},
	{
		mods = { "ctrl", "shift" },
		key = "g",
		action = function()
			hs.application.launchOrFocus("Ghostty")
		end,
		description = "Launch or focus Ghostty (normal instance)",
	},
	{
		mods = { "ctrl", "shift" },
		key = "W",
		action = function()
			hs.application.launchOrFocus("Safari")
		end,
		description = "Launch or focus Safari",
	},
	{
		mods = { "ctrl", "shift" },
		key = "V",
		action = function()
			hs.application.launchOrFocus("Visual Studio Code")
		end,
		description = "Launch or focus VS Code",
	},
	{
		mods = { "ctrl", "shift" },
		key = "S",
		action = function()
			hs.application.launchOrFocus("Wechat")
		end,
		description = "Launch or focus Wechat",
	},
	{
		mods = { "ctrl", "shift" },
		key = "D",
		action = function()
			hs.application.launchOrFocus("Dictionaries")
		end,
		description = "Launch or focus Dictionaries",
	},
	{
		mods = { "ctrl", "shift" },
		key = "F",
		action = function()
			hs.application.launchOrFocus("Finder")
		end,
		description = "Launch or focus Finder",
	},
}
