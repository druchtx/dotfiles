-- ========================================
-- Application Launcher Keybindings
-- ========================================

local windowManager = require("modules.window")

-- Launch or focus an app, then position its main/focused window.
-- position defaults to "center_keep_size" on the screen of the currently focused window.
-- Use position = "none" to skip positioning.
local function launchAppAt(appName, position)
	local activeWin = hs.window.focusedWindow()
	local targetScreen = activeWin and activeWin:screen() or hs.screen.mainScreen()
	local desiredPosition = position or "center_keep_size"

	hs.application.launchOrFocus(appName)

	local function tryMove(attempts)
		local app = hs.application.get(appName)
		local win = app and (app:focusedWindow() or app:mainWindow())
		if win then
			win:focus()
			if targetScreen then
				win:moveToScreen(targetScreen)
			end
			if desiredPosition ~= "none" then
				windowManager.moveWindow(desiredPosition)
			end
			return
		end
		if attempts < 15 then
			hs.timer.doAfter(0.1, function()
				tryMove(attempts + 1)
			end)
		end
	end

	tryMove(0)
end

local launchers = {
	{
		mods = { "ctrl", "shift" },
		key = "G",
		app = "Ghostty",
		position = "center_keep_size",
		description = "Launch or focus Ghostty",
	},
	{
		mods = { "ctrl", "shift" },
		key = "g",
		app = "Ghostty",
		position = "center_keep_size",
		description = "Launch or focus Ghostty (normal instance)",
	},
	{
		mods = { "ctrl", "shift" },
		key = "W",
		app = "Safari",
		position = "none",
		description = "Launch or focus Safari",
	},
	{
		mods = { "ctrl", "shift" },
		key = "V",
		app = "Visual Studio Code",
		position = "none",
		description = "Launch or focus VS Code",
	},
	{
		mods = { "ctrl", "shift" },
		key = "S",
		app = "Wechat",
		position = "none",
		description = "Launch or focus Wechat",
	},
	{
		mods = { "ctrl", "shift" },
		key = "D",
		app = "Dictionaries",
		position = "none",
		description = "Launch or focus Dictionaries",
	},
	{
		mods = { "ctrl", "shift" },
		key = "F",
		app = "Finder",
		position = "none",
		description = "Launch or focus Finder",
	},
}

local keymaps = {}
for _, item in ipairs(launchers) do
	table.insert(keymaps, {
		mods = item.mods,
		key = item.key,
		action = function()
			launchAppAt(item.app, item.position)
		end,
		description = item.description or ("Launch or focus " .. item.app),
	})
end

return keymaps
