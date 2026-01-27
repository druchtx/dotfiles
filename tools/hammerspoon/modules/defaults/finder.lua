-- ========================================
-- Finder Settings
-- ========================================

return {
	{
		command = "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'",
		description = "Set Finder default view to list view",
	},
	{
		command = "chflags nohidden ~/Library",
		description = "Show ~/Library folder",
	},
	{
		command = "defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true",
		description = "Show external hard drives on Desktop",
	},
	{
		command = "defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true",
		description = "Show removable media on Desktop",
	},
}
