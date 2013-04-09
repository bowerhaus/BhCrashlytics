--[[`
# BhCrashlyticsDemo.lua
 
A quick demonstration of Crashlytics crash logging for Gideros SDK. 
 
Most crash logging systems record only the underlying processor stack trace when a crash/exception occurs. For Lua errors, where
the app will probably just exit normally without throwing an exception, this is of little use. Here we demonstrate the 
BhCrashlytics plugin which works with the http://www.crashlytics.com logging service to log not only
raw crashes but also ones caused by a Lua error. In the case of the latter, the Lua stack trace is logged along with
the other crash information.

See http://bowerhaus.eu/blog/files/luacrashlogging.html for installation instructions.
 
@private
## MIT License: Copyright (C) 2013. Andy Bower, Bowerhaus LLP

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

require "BhCrashlytics"

-- Install the crash logging ASAP after app startup. Ideally in init.lua.
BhCrashlytics.installCrashReporting("YOURKEYHERE")

function breadcrumb(...)
	-- With Crashlytics you can leave breadcrumb trails. Using this method we can log these to the Gideros SDK console and the XCode console
	-- when attached to a development system. With a deployed app on a real device that is disconnected from XCode the breadcrumbs get sent
	-- only to Crashlytics.
	--
	local crumb=string.format(...)
	BhCrashlytics.leaveBreadcrumb(crumb)
	print(crumb)
end

application:setBackgroundColor(0x1B68C9)

local title=TextField.new(TTFont.new("Tahoma.ttf", 30), "BhCrashlyticsDemo")
title:setTextColor(0xffffff)
title:setPosition(160-title:getWidth()/2, 220)
stage:addChild(title)

local info=TextField.new(TTFont.new("Tahoma.ttf", 15), "Tap screen to force a Lua crash")
info:setTextColor(0xffffff)
info:setPosition(160-info:getWidth()/2, 250)
stage:addChild(info)

breadcrumb("Here we are in %s", "BhCrashlyticsDemo")

function onMouseDown()
	breadcrumb("The user tapped the screen")
	unknownFunction()
end

stage:addEventListener(Event.MOUSE_DOWN, onMouseDown)


