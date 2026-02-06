-- ========================================
-- Network Settings
-- ========================================

return {
	{
		command = "defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1",
		description = "Enable AirDrop over all network interfaces",
	},
}
