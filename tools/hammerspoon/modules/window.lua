-- ========================================
-- Vim-style Window Management
-- ========================================

local M = {}

hs.window.animationDuration = 0 -- Disable animations for faster response

-- Get current window and screen info
local function getWindowFrame()
	local win = hs.window.focusedWindow()
	if not win then
		return nil
	end
	return win, win:screen():frame()
end

-- Store only ONE previous frame for undo
local previousFrame = nil

-- Save current frame before moving
local function saveFrame(win)
	previousFrame = {
		id = win:id(),
		frame = win:frame(),
	}
end

-- Check if window is approximately in a position (with tolerance)
local function isInPosition(winFrame, targetFrame, tolerance)
	tolerance = tolerance or 10
	return math.abs(winFrame.x - targetFrame.x) < tolerance
		and math.abs(winFrame.y - targetFrame.y) < tolerance
		and math.abs(winFrame.w - targetFrame.w) < tolerance
		and math.abs(winFrame.h - targetFrame.h) < tolerance
end

-- Window position functions with cycle support
local windowPositions = {
	-- Left: 1/2 -> 2/3 -> 1/3 -> 1/2
	left = function(win, screen)
		local current = win:frame()
		local half = { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h }
		local twoThirds = { x = screen.x, y = screen.y, w = screen.w * 2 / 3, h = screen.h }
		local oneThird = { x = screen.x, y = screen.y, w = screen.w / 3, h = screen.h }

		saveFrame(win)

		if isInPosition(current, half) then
			-- Currently 1/2 -> expand to 2/3
			win:setFrame(twoThirds)
		elseif isInPosition(current, twoThirds) then
			-- Currently 2/3 -> shrink to 1/3
			win:setFrame(oneThird)
		else
			-- Default or 1/3 -> go to 1/2
			win:setFrame(half)
		end
	end,

	-- Right: 1/2 -> 2/3 -> 1/3 -> 1/2
	right = function(win, screen)
		local current = win:frame()
		local half = { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h }
		local twoThirds = { x = screen.x + screen.w / 3, y = screen.y, w = screen.w * 2 / 3, h = screen.h }
		local oneThird = { x = screen.x + screen.w * 2 / 3, y = screen.y, w = screen.w / 3, h = screen.h }

		saveFrame(win)

		if isInPosition(current, half) then
			-- Currently 1/2 -> expand to 2/3
			win:setFrame(twoThirds)
		elseif isInPosition(current, twoThirds) then
			-- Currently 2/3 -> shrink to 1/3
			win:setFrame(oneThird)
		else
			-- Default or 1/3 -> go to 1/2
			win:setFrame(half)
		end
	end,

	-- Top: 1/2 -> 2/3 -> 1/3 -> 1/2
	up = function(win, screen)
		local current = win:frame()
		local half = { x = screen.x, y = screen.y, w = screen.w, h = screen.h / 2 }
		local twoThirds = { x = screen.x, y = screen.y, w = screen.w, h = screen.h * 2 / 3 }
		local oneThird = { x = screen.x, y = screen.y, w = screen.w, h = screen.h / 3 }

		saveFrame(win)

		if isInPosition(current, half) then
			win:setFrame(twoThirds)
		elseif isInPosition(current, twoThirds) then
			win:setFrame(oneThird)
		else
			win:setFrame(half)
		end
	end,

	-- Bottom: 1/2 -> 2/3 -> 1/3 -> 1/2
	down = function(win, screen)
		local current = win:frame()
		local half = { x = screen.x, y = screen.y + screen.h / 2, w = screen.w, h = screen.h / 2 }
		local twoThirds = { x = screen.x, y = screen.y + screen.h / 3, w = screen.w, h = screen.h * 2 / 3 }
		local oneThird = { x = screen.x, y = screen.y + screen.h * 2 / 3, w = screen.w, h = screen.h / 3 }

		saveFrame(win)

		if isInPosition(current, half) then
			win:setFrame(twoThirds)
		elseif isInPosition(current, twoThirds) then
			win:setFrame(oneThird)
		else
			win:setFrame(half)
		end
	end,

	-- Maximize (fill screen but not native fullscreen)
	max = function(win, screen)
		saveFrame(win)
		win:setFrame({
			x = screen.x,
			y = screen.y,
			w = screen.w,
			h = screen.h,
		})
	end,

	-- Center
	center = function(win, screen)
		saveFrame(win)

		-- Set desired window size
		local targetWidth = screen.w * 0.85
		local targetHeight = screen.h * 0.95

		-- Calculate position to center the window
		local centerX = screen.x + (screen.w - targetWidth) / 2
		local centerY = screen.y + (screen.h - targetHeight) / 2

		win:setFrame({
			x = centerX,
			y = centerY,
			w = targetWidth,
			h = targetHeight,
		})
	end,

	-- Center without resizing
	center_keep_size = function(win, screen)
		saveFrame(win)

		local frame = win:frame()
		local centerX = screen.x + (screen.w - frame.w) / 2
		local centerY = screen.y + (screen.h - frame.h) / 2

		win:setFrame({
			x = centerX,
			y = centerY,
			w = frame.w,
			h = frame.h,
		})
	end,
}

-- ========================================
-- Exported Functions
-- ========================================

--- Execute window movement
--- @param position string Position name (left, right, up, down, max, center)
function M.moveWindow(position)
	local win, screen = getWindowFrame()
	if not win then
		hs.alert.show("No active window")
		return
	end

	if windowPositions[position] then
		windowPositions[position](win, screen)
	end
end

--- Toggle native fullscreen
function M.toggleFullscreen()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No active window")
		return
	end

	saveFrame(win)
	win:toggleFullScreen()
end

--- Move window to next/previous screen and focus it
--- @param direction string "next" or "previous"
function M.moveToScreen(direction)
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No active window")
		return
	end

	saveFrame(win)

	if direction == "next" then
		win:moveToScreen(win:screen():next())
	elseif direction == "previous" then
		win:moveToScreen(win:screen():previous())
	end

	-- Focus the window after moving
	win:focus()
end

--- Undo last window movement
function M.undoWindowMove()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No active window")
		return
	end

	if previousFrame and previousFrame.id == win:id() then
		win:setFrame(previousFrame.frame)
		previousFrame = nil -- Clear after undo
	else
		hs.alert.show("No previous layout")
	end
end

--- Resize window by a scale factor
--- @param direction string "grow" or "shrink"
function M.resizeWindow(direction)
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No active window")
		return
	end

	saveFrame(win)

	local frame = win:frame()
	local scale = direction == "grow" and 1.1 or 0.9 -- 10% change

	-- Calculate new size
	local newWidth = frame.w * scale
	local newHeight = frame.h * scale

	-- Keep window centered while resizing
	local newX = frame.x - (newWidth - frame.w) / 2
	local newY = frame.y - (newHeight - frame.h) / 2

	win:setFrame({
		x = newX,
		y = newY,
		w = newWidth,
		h = newHeight,
	})
end

return M
