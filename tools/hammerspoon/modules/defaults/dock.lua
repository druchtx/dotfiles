-- ========================================
-- Dock Settings
-- ========================================

return {
	{
		command = "defaults write com.apple.dock wvous-tr-corner -int 12",
		description = "Set top-right hot corner to Notification Center (part 1)",
	},
	{
		command = "defaults write com.apple.dock wvous-tr-modifier -int 0",
		description = "Set top-right hot corner to Notification Center (part 2)",
	},
}
