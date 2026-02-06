-- ========================================
-- Keyboard Settings
-- ========================================

return {
	{
		command = "defaults write -g ApplePressAndHoldEnabled -bool false",
		description = "Disable press-and-hold for keys (enable key repeat)",
	},
	{
		command = "defaults write NSGlobalDomain KeyRepeat -int 1",
		description = "Set fast key repeat rate",
	},
}
