-- ========================================
-- macOS Defaults Manager
-- ========================================
-- This module applies macOS system defaults settings
-- Settings are organized by category and applied on each Hammerspoon reload

local M = {}

-- Logger
local logger = hs.logger.new("defaults", "info")

-- ========================================
-- Common Execution Function
-- ========================================

--- Apply a list of default configurations
--- @param configs table List of configuration items
--- @param category string Category name for logging
function M.applyDefaults(configs, category)
	if not configs or #configs == 0 then
		return
	end

	logger.i(string.format("Applying %s settings...", category))

	for _, config in ipairs(configs) do
		local success, result = pcall(function()
			return hs.execute(config.command)
		end)

		if success then
			if config.description then
				logger.d(string.format("  ✓ %s", config.description))
			end
		else
			logger.e(string.format("  ✗ Failed: %s - %s", config.description or config.command, result))
		end
	end
end

-- ========================================
-- Load and Apply All Modules
-- ========================================

logger.i("Loading macOS defaults modules...")

-- Load all default configuration modules
local modules = {
	{ name = "keyboard", config = require("modules.defaults.keyboard") },
	{ name = "finder", config = require("modules.defaults.finder") },
	{ name = "dock", config = require("modules.defaults.dock") },
	{ name = "network", config = require("modules.defaults.network") },
	{ name = "safari", config = require("modules.defaults.safari") },
	{ name = "vscode", config = require("modules.defaults.vscode") },
}

-- Apply all configurations
for _, module in ipairs(modules) do
	M.applyDefaults(module.config, module.name)
end

logger.i("macOS defaults applied successfully")

return M
