-- ========================================
-- IntelliJ IdeaVim input-source handling
-- ========================================

local M = {}

-- This is the English input source currently enabled on this Mac.
local englishSource = "com.apple.keylayout.ABC"

local intellijBundleIds = {
	["com.jetbrains.intellij"] = true,
	["com.jetbrains.intellij.ce"] = true,
	["com.jetbrains.intellij.eap"] = true,
}

local function isIntelliJFocused()
	local app = hs.application.frontmostApplication()
	return app ~= nil and intellijBundleIds[app:bundleID()] == true
end

local function switchToEnglish()
	if not isIntelliJFocused() then
		return
	end

	if hs.keycodes.currentSourceID() ~= englishSource then
		hs.keycodes.currentSourceID(englishSource)
	end
end

local escapeKey = hs.keycodes.map.escape or 53
local ctrlGKey = hs.keycodes.map.g

M.ideaVimInputWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	if not isIntelliJFocused() then
		return false
	end

	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	local isEscape = keyCode == escapeKey
	local isCtrlG = keyCode == ctrlGKey and flags.ctrl

	if isEscape or isCtrlG then
		switchToEnglish()
	end

	return false
end)

M.ideaVimInputWatcher:start()

return M
