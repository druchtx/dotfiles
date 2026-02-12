-- ========================================
-- Application Launcher Keybindings
-- ========================================

local defaultApp = require("modules.utils.default_app")

-- Launch or focus an app without moving or positioning windows
local function launchAppAt(item, position)
	local appName = item.app
	local bundleID = item.bundle_id

	if not appName and not bundleID then
		hs.alert.show("No app name or bundle id")
		return
	end

	if bundleID then
		hs.application.launchOrFocusByBundleID(bundleID)
	else
		hs.application.launchOrFocus(appName)
	end
end

local launchers = {
	{
		mods = { "ctrl", "shift" },
		key = "G",
		app = "Ghostty",
		description = "Launch or focus Ghostty",
	},
	{
		mods = { "ctrl", "shift" },
		key = "g",
		app = "Ghostty",
		description = "Launch or focus Ghostty (normal instance)",
	},
	{
		mods = { "ctrl", "shift" },
		key = "W",
		bundle_id = defaultApp.Browser.bundleID(),
		description = "Launch or focus Default Browser",
	},
	{
		mods = { "ctrl", "shift" },
		key = "V",
		app = "Visual Studio Code",
		description = "Launch or focus VS Code",
	},
	{
		mods = { "ctrl", "shift" },
		key = "S",
		app = "Wechat",
		description = "Launch or focus Wechat",
	},
	{
		mods = { "ctrl", "shift" },
		key = "D",
		app = "Dictionaries",
		description = "Launch or focus Dictionaries",
	},
	{
		mods = { "ctrl", "shift" },
		key = "F",
		app = "Finder",
		description = "Launch or focus Finder",
	},
}

local keymaps = {}
for _, item in ipairs(launchers) do
	table.insert(keymaps, {
		mods = item.mods,
		key = item.key,
		action = function()
			launchAppAt(item, item.position)
		end,
		description = item.description or ("Launch or focus " .. (item.app or item.bundle_id or "app")),
	})
end

return keymaps
