-- ========================================
-- Auto-reload Configuration
-- ========================================
local function reloadConfig(files)
	local doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configWatcher:start()

-- ========================================
-- Load modules
-- ========================================
require("modules.window")
require("modules.defaults")
require("modules.keymaps")

-- ========================================
-- Load completion message
-- ========================================
hs.alert.show("Hammerspoon Loaded")
