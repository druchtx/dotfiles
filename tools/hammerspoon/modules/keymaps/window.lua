-- ========================================
-- Window Management Keybindings
-- ========================================

local windowManager = require("modules.window")

return {
	-- Basic directions with cycle support
	{
		mods = { "ctrl", "shift" },
		key = "H",
		action = function()
			windowManager.moveWindow("left")
		end,
		description = "Move window to left (cycle: 1/2 -> 2/3 -> 1/3)",
	},
	{
		mods = { "ctrl", "shift" },
		key = "L",
		action = function()
			windowManager.moveWindow("right")
		end,
		description = "Move window to right (cycle: 1/2 -> 2/3 -> 1/3)",
	},
	{
		mods = { "ctrl", "shift" },
		key = "K",
		action = function()
			windowManager.moveWindow("up")
		end,
		description = "Move window to top (cycle: 1/2 -> 2/3 -> 1/3)",
	},
	{
		mods = { "ctrl", "shift" },
		key = "J",
		action = function()
			windowManager.moveWindow("down")
		end,
		description = "Move window to bottom (cycle: 1/2 -> 2/3 -> 1/3)",
	},

	-- Maximize and center
	{
		mods = { "ctrl", "shift" },
		key = "return",
		action = function()
			windowManager.moveWindow("max")
		end,
		description = "Maximize window",
	},
	{
		mods = { "ctrl", "shift" },
		key = "C",
		action = function()
			windowManager.moveWindow("center")
		end,
		description = "Center window",
	},

	-- Native fullscreen toggle
	{
		mods = { "ctrl", "shift", "cmd" },
		key = "F",
		action = function()
			windowManager.toggleFullscreen()
		end,
		description = "Toggle fullscreen",
	},

	-- Move window to next/previous display
	{
		mods = { "ctrl", "shift" },
		key = "Left",
		action = function()
			windowManager.moveToScreen("previous")
		end,
		description = "Move window to previous display",
	},
	{
		mods = { "ctrl", "shift" },
		key = "Right",
		action = function()
			windowManager.moveToScreen("next")
		end,
		description = "Move window to next display",
	},

	-- Undo last layout
	{
		mods = { "ctrl", "shift" },
		key = "delete",
		action = function()
			windowManager.undoWindowMove()
		end,
		description = "Undo last window movement",
	},

	-- Resize window
	{
		mods = { "ctrl", "shift" },
		key = "=",
		action = function()
			windowManager.resizeWindow("grow")
		end,
		description = "Grow window size by 10%",
	},
	{
		mods = { "ctrl", "shift" },
		key = "-",
		action = function()
			windowManager.resizeWindow("shrink")
		end,
		description = "Shrink window size by 10%",
	},
}
