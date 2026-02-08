-- ========================================
-- Default App Utilities
-- ========================================

local M = {}

local function getDefaultHandler(scheme)
	return hs.urlevent.getDefaultHandler(scheme)
end

local function nameForBundleID(bundleID)
	return bundleID and hs.application.nameForBundleID(bundleID) or nil
end

local function pathForBundleID(bundleID)
	return bundleID and hs.application.pathForBundleID(bundleID) or nil
end

M.Browser = {
	bundleID = function()
		return getDefaultHandler("http") or getDefaultHandler("https")
	end,
	buildID = function()
		return getDefaultHandler("http") or getDefaultHandler("https")
	end,
	name = function()
		local bundleID = M.Browser.bundleID()
		return nameForBundleID(bundleID)
	end,
	path = function()
		local bundleID = M.Browser.bundleID()
		return pathForBundleID(bundleID)
	end,
}

return M
