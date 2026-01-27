-- ========================================
-- Keymaps Manager
-- ========================================
-- This module manages all keyboard shortcuts
-- Keymaps are organized by category and application

local M = {}

-- Logger
local logger = hs.logger.new("keymaps", "info")

-- ========================================
-- Helper Functions
-- ========================================

--- Generate a unique key identifier from modifiers and key
--- @param mods table List of modifier keys
--- @param key string The key
--- @return string Unique identifier
local function getKeymapId(mods, key)
	-- Sort modifiers to ensure consistent ordering
	local sortedMods = {}
	for _, mod in ipairs(mods) do
		table.insert(sortedMods, mod)
	end
	table.sort(sortedMods)

	return table.concat(sortedMods, "+") .. "+" .. key
end

--- Detect keymap conflicts across all modules
--- @param modules table List of module configurations
--- @return table List of conflicts
local function detectConflicts(modules)
	local keymapRegistry = {}
	local conflicts = {}

	for _, module in ipairs(modules) do
		for _, keymap in ipairs(module.keymaps) do
			local id = getKeymapId(keymap.mods, keymap.key)

			if keymapRegistry[id] then
				-- Conflict found
				table.insert(conflicts, {
					id = id,
					first = keymapRegistry[id],
					second = {
						category = module.name,
						description = keymap.description or "No description",
					},
				})
			else
				-- Register this keymap
				keymapRegistry[id] = {
					category = module.name,
					description = keymap.description or "No description",
				}
			end
		end
	end

	return conflicts
end

-- ========================================
-- Common Binding Function
-- ========================================

--- Bind a list of keymaps
--- @param keymaps table List of keymap configurations
--- @param category string Category name for logging
function M.bindKeymaps(keymaps, category)
	if not keymaps or #keymaps == 0 then
		return
	end

	logger.i(string.format("Binding %s keymaps...", category))

	for _, keymap in ipairs(keymaps) do
		local success, result = pcall(function()
			hs.hotkey.bind(keymap.mods, keymap.key, keymap.action)
		end)

		if success then
			if keymap.description then
				logger.d(string.format("  ✓ %s", keymap.description))
			end
		else
			logger.e(string.format("  ✗ Failed to bind: %s - %s", keymap.description or keymap.key, result))
		end
	end
end

-- ========================================
-- Load and Bind All Keymaps
-- ========================================

logger.i("Loading keymaps...")

-- Load all keymap modules
local modules = {
	{ name = "system", keymaps = require("modules.keymaps.hammerspoon") },
	{ name = "window", keymaps = require("modules.keymaps.window") },
	{ name = "launcher", keymaps = require("modules.keymaps.launcher") },
}

-- Detect conflicts before binding
local conflicts = detectConflicts(modules)

if #conflicts > 0 then
	-- Show alert to user
	local alertMsg = string.format(
		"⚠️  %d Keymap Conflict%s Detected!\nCheck Console for details",
		#conflicts,
		#conflicts > 1 and "s" or ""
	)
	hs.alert.show(alertMsg, 5)

	-- Log detailed conflict information
	logger.w(string.format("⚠️  Found %d keymap conflict(s):", #conflicts))
	for _, conflict in ipairs(conflicts) do
		logger.w(string.format("  • %s", conflict.id))
		logger.w(string.format("    - %s: %s", conflict.first.category, conflict.first.description))
		logger.w(string.format("    - %s: %s", conflict.second.category, conflict.second.description))
	end
	logger.w("Note: Later bindings will override earlier ones")
else
	logger.i("✓ No keymap conflicts detected")
end

-- Bind all keymaps
for _, module in ipairs(modules) do
	M.bindKeymaps(module.keymaps, module.name)
end

logger.i("Keymaps loaded successfully")

return M
