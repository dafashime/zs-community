print("===========================================================")
print("              LOAD QUICK FRAMEWORK")
print("===========================================================")

if type(DEBUG) ~= "number" then
	DEBUG = 0
end

if type(DEBUG_FPS) ~= "boolean" then
	DEBUG_FPS = false
end

if type(DEBUG_MEM) ~= "boolean" then
	DEBUG_MEM = false
end

if type(LOAD_SHORTCODES_API) ~= "boolean" then
	LOAD_SHORTCODES_API = true
end

if type(LOAD_DEPRECATED_API) ~= "boolean" then
	LOAD_DEPRECATED_API = false
end

if type(DISABLE_DEPRECATED_WARNING) ~= "boolean" then
	DISABLE_DEPRECATED_WARNING = false
end

if type(USE_DEPRECATED_EVENT_ARGUMENTS) ~= "boolean" then
	USE_DEPRECATED_EVENT_ARGUMENTS = false
end

local CURRENT_MODULE_NAME = ...
cc = cc or {}
cc.PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6)

if cc.Node.removeTouchEvent then
	cc.bPlugin_ = false
end

require(cc.PACKAGE_NAME .. ".debug")
require(cc.PACKAGE_NAME .. ".functions")
require(cc.PACKAGE_NAME .. ".cocos2dx")
printInfo("")
printInfo("# DEBUG                        = " .. DEBUG)
printInfo("#")

device = require(cc.PACKAGE_NAME .. ".device")
transition = require(cc.PACKAGE_NAME .. ".transition")
display = require(cc.PACKAGE_NAME .. ".display")
filter = require(cc.PACKAGE_NAME .. ".filter")
audio = require(cc.PACKAGE_NAME .. ".audio")
network = require(cc.PACKAGE_NAME .. ".network")
crypto = require(cc.PACKAGE_NAME .. ".crypto")
local cjson = require(cc.PACKAGE_NAME .. ".json")

if cjson then
	json = cjson
else
	require("cocos.cocos2d.json")
end

if device.platform == "android" then
	require(cc.PACKAGE_NAME .. ".platform.android")
elseif device.platform == "ios" then
	require(cc.PACKAGE_NAME .. ".platform.ios")
elseif device.platform == "mac" then
	require(cc.PACKAGE_NAME .. ".platform.mac")
end

require(cc.PACKAGE_NAME .. ".cc.init")

if LOAD_DEPRECATED_API then
	ui = require(cc.PACKAGE_NAME .. ".ui")
	local dp = cc.PACKAGE_NAME .. ".deprecated."

	require(dp .. "deprecated_functions")
end

if LOAD_SHORTCODES_API then
	require(cc.PACKAGE_NAME .. ".shortcodes")
end

local sharedTextureCache = cc.Director:getInstance():getTextureCache()
local sharedDirector = cc.Director:getInstance()

if DEBUG_FPS then
	sharedDirector:setDisplayStats(true)
else
	sharedDirector:setDisplayStats(false)
end

if DEBUG_MEM then
	local sharedTextureCache = cc.Director:getInstance():getTextureCache()

	local function showMemoryUsage()
		printInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
		printInfo(sharedTextureCache:getCachedTextureInfo())
		printInfo("---------------------------------------------------")
	end

	sharedDirector:getScheduler():scheduleScriptFunc(showMemoryUsage, DEBUG_MEM_INTERVAL or 10, false)
end
