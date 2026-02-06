-- ========================================
-- VS Code Settings
-- ========================================

return {
	{
		command = "defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false",
		description = "Disable press-and-hold for VS Code (enable key repeat)",
	},
	{
		command = "defaults write com.google.antigravity ApplePressAndHoldEnabled -bool false",
		description = "Disable press-and-hold for Antigravity",
	},
}
