_print = print

_TRACEFH = nil

function __G__TRACKBACK__(errorMessage)
	local msg = "----------------------------------------\nLUA ERROR: " .. tostring(errorMessage) .. "\n" .. debug.traceback("", 2) .. "\n----------------------------------------\n"
	if _TRACEFH then
		_TRACEFH:write(os.date("%H:%M:%S") .. " [LUA_ERROR]\n" .. msg .. "\n")
		_TRACEFH:flush()
	end
	_print(msg)
end

function MAIN_LOOP_BEGIN()
end

function DISPATCH_GLOBAL_EVENT(jsonStr)
	xpcall(function ()
		local dispatcher = cc.Director:getInstance():getEventDispatcher()

		if dispatcher:isEnabled() then
			local data = json.decode(jsonStr)
			local eventcustom = cc.EventCustom:new(data.evt)

			eventcustom:setDataString(tostring(data.ex))
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventcustom)
		else
			scheduler.performWithDelayGlobal(function ()
				DISPATCH_GLOBAL_EVENT(jsonStr)
			end, 0.2)
		end
	end, __G__TRACKBACK__)
end

require("config")

-- ============================================================
-- MODRUN TRACE instrumentation (debug only; see 魔改包(白筑).md)
-- tees print() + require() + heartbeat + instruction hook to a
-- file so a busy-loop / missing-module failure can be located.
-- ============================================================
local TRACE_PATH = "D:/Dev/ZhanS/_mumu/run_trace_" .. tostring(LUAMODE or "?") .. ".log"
local traceFH = io.open(TRACE_PATH, "w")
local function slog(...)
	if not traceFH then return end
	local parts = {}
	for i = 1, select("#", ...) do
		parts[i] = tostring(select(i, ...))
	end
	traceFH:write(os.date("%H:%M:%S") .. " [" .. table.concat(parts, " ") .. "]\n")
	traceFH:flush()
end
slog("TRACE", "boot started, path=" .. TRACE_PATH .. " LUAMODE=" .. tostring(LUAMODE))
_TRACEFH = traceFH

local _origPrint = print
print = function(...)
	local parts = {}
	for i = 1, select("#", ...) do
		parts[i] = tostring(select(i, ...))
	end
	if traceFH then
		traceFH:write(os.date("%H:%M:%S") .. " [PRINT] " .. table.concat(parts, "\t") .. "\n")
		traceFH:flush()
	end
	return _origPrint(...)
end

local _origRequire = require
require = function(name)
	local t0 = os.clock()
	local ok, res = pcall(_origRequire, name)
	local dt = string.format("%.1fms", (os.clock() - t0) * 1000)
	if ok then
		slog("REQ", name, dt)
		return res
	end
	slog("REQ_FAIL", name, dt, tostring(res))
	error(res, 2)
end

if DEBUG > 0 then
	-- intercept mod license/watchdog os.exit() calls; log caller instead of dying
	_G._ORIG_OS_EXIT = os.exit
	os.exit = function(code, ...)
		slog("OS_EXIT_CALLED", tostring(code), debug.traceback("", 2))
		if _ORIG_OS_EXIT then
			-- keep process alive for diagnosis unless the caller insists on kill
			return false
		end
		return _ORIG_OS_EXIT(code, ...)
	end
	slog("TRACE", "os.exit intercepted")
end

if DEBUG > 0 and debug and debug.sethook then
	pcall(function () jit.off() end) -- interpreter mode so count hooks fire reliably
	local hookN = 0
	debug.sethook(function ()
		hookN = hookN + 1
		if hookN % 8 == 0 then
			local info = debug.getinfo(2, "Sl")
			if info then
				slog("HOOK", (info.short_src or "?"), info.currentline or info.linedefined or "?")
			end
		end
	end, "c", 4000000)
	slog("TRACE", "instruction hook installed (count=4M)")
end

local fileUtils = cc.FileUtils:getInstance()

if IS_PLAYER_DEBUG then
	USE_SOURCE_LUA = true
	USE_SOURCE_RES = true
end

if string.sub(WRITABLEPATH, -1) ~= "/" then
	WRITABLEPATH = WRITABLEPATH .. "/"
end

if not USE_SOURCE_LUA then
	local frwkFilePath = string.format("res/framework_precompiled%s.zip", USE_ARM64 and "64" or "")

	if fileUtils:isFileExist(WRITABLEPATH .. frwkFilePath) then
		frwkFilePath = WRITABLEPATH .. frwkFilePath
	end

	print("quick framework path:" .. frwkFilePath)
	cc.LuaLoadChunksFromZIP(frwkFilePath)
end

require("framework.init")

-- global scheduler (mir2.init.lua also sets this; needed earlier here so the
-- upt scene + console 'l' command work before the game code runs)
scheduler = require("framework.scheduler")

device.writablePath = WRITABLEPATH

if DEBUG > 0 then
	local tickN = 0
	pcall(function ()
		local sched = require("framework.scheduler")
		slog("HEARTBEAT", "pre-schedule, has scheduleGlobal=" .. tostring(type(sched.scheduleGlobal)) .. " has schedule=" .. tostring(type(sched.schedule)))
		sched.scheduleGlobal(function ()
			tickN = tickN + 1
			if tickN % 30 == 0 then
				local info = "?"
				pcall(function ()
					local sc = display.getRunningScene and display.getRunningScene()
					info = tostring(sc) .. " cls=" .. tostring(sc and sc.__cname)
				end)
				slog("HEARTBEAT", tickN, info)
			end
		end, 1.0)
		slog("HEARTBEAT", "post-schedule")
	end, function (err)
		slog("HEARTBEAT_FAIL", tostring(err))
		slog("HEARTBEAT_FAIL_TRACE", debug.traceback("", 1))
	end)
end

if IS_PLAYER_DEBUG then
	SKIP_UPT = true
end

local debugErr = nil

if DEBUG > 0 then
	xpcall(function ()
		local console = cc.Director:getInstance():getConsole()

		console:listenOnTCP(8844)
		console:addCommand({
			name = "l",
			help = "execute lua script"
		}, function (fd, args)
			if type(args) == "string" then
				scheduler.performWithDelayGlobal(function ()
					local func, err = loadstring(args)

					if err then
						print(err)
					else
						func()
					end
				end, 0)
			end
		end)
		console:addCommand({
			name = "say",
			help = "use mir2 say"
		}, function (fd, args)
			scheduler.performWithDelayGlobal(function ()
				local args = ycFunction:a2u(args, string.len(args))
				args = string.trim(args)

				print(args)
				net.send({
					CM_SAY
				}, {
					args
				})
			end, 0)
		end)
	end, function (errstr, msg)
		debugErr = "err: " .. errstr
		debugErr = debugErr .. "\n"
	end)
end

xpcall(function ()
	local searchPaths = fileUtils:getSearchPaths()

	table.insert(searchPaths, 1, "res/")

	if USE_SOURCE_RES then
		table.insert(searchPaths, 1, "rs/")
	end

	table.insert(searchPaths, 1, WRITABLEPATH)
	table.insert(searchPaths, 1, WRITABLEPATH .. "res/")
	fileUtils:setSearchPaths(searchPaths)
	dump(fileUtils:getSearchPaths())

	local function appRun()
		slog("APP", "appRun begin, LUAMODE=" .. tostring(LUAMODE))
		if device.platform ~= "mac" or not IS_PLAYER_DEBUG then
			cc.LuaLoadChunksFromZIP(string.format("an%s.zip", USE_ARM64 and "64" or ""))
			slog("APP", "an.zip loaded")
		end

		if not USE_SOURCE_LUA then
			if LUAMODE == "mod" then
				-- 白筑魔改版: 生产客户端整套(204 模块, 已适配本地 def.init)
				slog("APP", "loading mir2_modpatch.zip")
				cc.LuaLoadChunksFromZIP("mir2_modpatch.zip")
				slog("APP", "mir2_modpatch.zip loaded")
			else
				cc.LuaLoadChunksFromZIP(string.format("mir2%s.zip", USE_ARM64 and "64" or ""))
				slog("APP", "mir2.zip loaded")
			end
		end

		slog("APP", "require an.init")
		require("an.init")
		slog("APP", "require mir2.init")
		require("mir2.init")
		if type(def) == "table" then
			pcall(function ()
				-- local SF list is openresty 8089 / mir2666; prod default (8088/7g9egjkew)
				-- has no /serverlist on the local stack -> would loop/timeout
				if def.setSF then
					def.setSF("127.0.0.1", 8089, "mir2666")
				end
				-- mod def.init only sets def.loginCenter (URL string); login/areas flow
				-- reads def.loginCenterIP / def.loginCenterPort (nil -> request fails ->
				-- "获取服务器信息失败" loop). set them explicitly for the local stack.
				local hookErr = nil
		local function hk(modname, fnname)
			local ok, m = pcall(require, modname)
			if not ok or type(m) ~= "table" or type(m[fnname]) ~= "function" then
				slog("HK", modname, fnname, "n/a", tostring(ok), tostring(m))
				return
			end
			local orig = m[fnname]
			m[fnname] = function(...)
				slog("HK", modname, fnname, "->")
				local ok2, ret = pcall(orig, ...)
				if ok2 then
					slog("HK", modname, fnname, "ok")
					return ret
				end
				slog("HK", modname, fnname, "ERR", tostring(ret))
				hookErr = true
				error(ret, 2)
			end
		end
		hk("mir2.scenes.login.scene", "serverlistCallback")
		hk("mir2.scenes.login.scene", "showLayer")
		hk("mir2.scenes.login.scene", "loginEnd")
		hk("mir2.scenes.login.scene", "connectServer")
		hk("mir2.scenes.login.areas", "goLoginAccount")
		hk("mir2.scenes.login.areas", "requestServerList")
		hk("mir2.scenes.login.areas", "selectServer")
		hk("mir2.scenes.login.login", "ctor")
		hk("mir2.scenes.login.login", "initLoginer")
		if type(def.lazyLoadConfig) == "function" then
			local o = def.lazyLoadConfig
			def.lazyLoadConfig = function(...)
				slog("HK", "def.lazyLoadConfig", "->")
				local ok2, ret = pcall(o, ...)
				slog("HK", "def.lazyLoadConfig", ok2 and "ok" or ("ERR " .. tostring(ret)))
				if not ok2 then error(ret, 2) end
				return ret
			end
		end
		if type(import) == "function" then
			local oi = import
			import = function(...)
				local ok2, ret = pcall(oi, ...)
				if ok2 then return ret end
				slog("HK", "import", "ERR", tostring(select(1, ...)), tostring(ret))
				error(ret, 2)
			end
		end
		slog("HK", "instrumentation installed")

		if def.loginCenterIP == nil or def.loginCenterPort == nil then
					def.loginCenter = "http://127.0.0.1:8088"
					def.loginCenterIP = "127.0.0.1"
					def.loginCenterPort = 8088
					slog("APP", "def.loginCenterIP/Port -> 127.0.0.1:8088 (local login center)")
				end
				slog("APP", "def.setSF -> 127.0.0.1:8089/mir2666 (local SF)")
			end)
		end
		slog("APP", "appRun done")
	end

	local scene = require("upt.scene").new(appRun)

	display.replaceScene(scene)

	if DEBUG > 0 then
		print("====searchPaths====")

		for k, v in pairs(searchPaths) do
			print("*  " .. v)
		end

		print("===================")

		if debugErr then
			scene.debugErr:setString(debugErr)
		end
	end
end, __G__TRACKBACK__)
