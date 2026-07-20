-- ========================================
-- Keyboard Settings
-- ========================================

return {
	{
		command = "defaults write -g ApplePressAndHoldEnabled -bool false",
		description = "Disable press-and-hold for keys (enable key repeat)",
	},
	{
		command = "defaults write NSGlobalDomain InitialKeyRepeat -int 12",
		description = "Set short initial key repeat delay",
	},
	{
		command = "defaults write NSGlobalDomain KeyRepeat -int 2",
		description = "Set balanced key repeat rate",
	},
}
