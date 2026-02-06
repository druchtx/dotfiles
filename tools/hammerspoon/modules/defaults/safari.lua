-- ========================================
-- Safari Settings
-- ========================================

return {
	{
		command = "defaults write com.apple.Safari.plist ShowFavoritesBar -bool false",
		description = "Hide Safari bookmark bar",
	},
	{
		command = "defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true",
		description = "Enable Safari develop menu (SandboxBroker)",
	},
	{
		command = "defaults write com.apple.Safari.plist IncludeDevelopMenu -bool true",
		description = "Enable Safari develop menu (IncludeDevelopMenu)",
	},
	{
		command = "defaults write com.apple.Safari.plist WebKitDeveloperExtrasEnabledPreferenceKey -bool true",
		description = "Enable Safari WebKit developer extras",
	},
	{
		command = "defaults write com.apple.Safari.plist 'com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled' -bool true",
		description = "Enable Safari WebKit2 developer extras",
	},
	{
		command = "defaults write NSGlobalDomain WebKitDeveloperExtras -bool true",
		description = "Enable WebKit developer extras globally",
	},
}
