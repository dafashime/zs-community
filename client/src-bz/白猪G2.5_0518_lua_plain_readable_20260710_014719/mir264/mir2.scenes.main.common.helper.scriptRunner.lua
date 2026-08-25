local dummy = import(".dummy")
local guide = import(".guide")
local stage = import(".stage")
local videoPlayer = import(".videoPlayer")
local common = import("..common")
local mapDef = require("mir2.scenes.main.map.def")
local util = import(".util")

runner = {
	running = 0,
	scriptCache = {},
	settingCache = {},
	routeEffectTex = {},
	routeEffects = {},
	dummy = dummy,
	video = videoPlayer.new()
}

dummy.setRunner(runner)
runner.video.setRunner(runner)

runner.current = ...

local function tryCall(proc, finishCallback, ...)
	local args = {
		...
	}

	return function()
		xpcall(proc, function(...)
			print("========== 小助手脚本运行期间发生错误，以下是发生错误时的详细信息 ==========\n", ...)
			print(debug.traceback("", 2))
		end, unpack(args))

		if finishCallback then
			finishCallback()
		end
	end
end

function runner.getScriptCache(key)
	local playerName = common.getPlayerName()

	if runner.playerName ~= playerName then
		runner.settingCache = {}
		runner.playerName = playerName
	end

	if not runner.settingCache[key] then
		local data = cache.getHelperSerialize("script" .. key)

		if not data[playerName] then
			data[playerName] = {}
		end

		runner.settingCache[key] = data[playerName]
	end

	return runner.settingCache[key]
end

function runner.checkEvt(evt, key)
	local cache = runner.getScriptCache(evt .. "Guided")

	return cache[key]
end

function runner.getMap()
	if not runner.simStage then
		return main_scene.ground.map
	else
		return runner.simStage:getMap()
	end
end

local function getHelperScript(type, env)
	local script = runner.scriptCache[type]

	if not script then
		local scriptModule, err

		if DEBUG > 0 then
			local filename

			filename, err = package.searchpath("mir2.helperScript." .. type, package.path)

			if filename then
				scriptModule, err = loadfile(filename)

				if scriptModule == nil then
					return nil, err
				end
			else
				scriptModule = package.preload["mir2.helperScript." .. type]
			end
		else
			local key = "mir2.helperScript." .. type

			scriptModule = package.preload[key]

			if not scriptModule then
				return nil, "script not exist. " .. key
			end
		end

		if not scriptModule then
			return nil, err
		end

		script = {}

		setmetatable(script, {
			__index = env
		})
		setfenv(scriptModule, script)
		scriptModule(filename)

		if DEBUG > 0 then
			return script
		end

		runner.scriptCache[type] = script
	end

	return script
end

local function globalDataGetter(_, k)
	if not k then
		return
	end

	local k = string.upper(k)

	if k == "PLAYERLEVEL" then
		return main_scene.ground.player.level
	elseif k == "PLAYERJOB" then
		return g_data.player.job
	elseif k == "PLAYERSEX" then
		return g_data.player.sex
	elseif k == "PLAYERGUILD" then
		return g_data.player.guild.guildName
	elseif k == "PLAYERISLEADER" then
		return g_data.player:getIsLeader()
	elseif k == "HASITEM" then
		return function(itemName)
			return g_data.bag:getItemWithName(itemName) ~= nil
		end
	elseif k == "GETITEMCOUNT" then
		return function(itemName)
			return g_data.bag:getItemCount(itemName)
		end
	elseif k == "GETPLAYERLOCATION" then
		return function()
			local mapid = main_scene.ground.map.mapid
			local x = main_scene.ground.player.x
			local y = main_scene.ground.player.y

			return x, y, mapid
		end
	elseif k == "HASEQUIP" then
		return function(equipName)
			return g_data.equip:isEquipped(equipName)
		end
	elseif k == "HASMAGIC" then
		return function(magicId)
			return g_data.player:getMagic(magicId) ~= nil
		end
	elseif k == "GETMAGICLEVEL" then
		return function(magicId)
			local magic = g_data.player:getMagic(magicId)

			if magic then
				return magic:get("level")
			end
		end
	elseif k == "ISHELPERSHIDNG" then
		return main_scene.ground.helper:isHiding()
	elseif k == "HELPER" then
		-- block empty
	elseif k == "STAGE" then
		return runner.simStage
	elseif k == "FINDNPCWITHNAME" then
		return function(name)
			return main_scene.ground.map:findNPCWithName(name)
		end
	end
end

local function updateEnv(script)
	local EVT = {}
	local env = {
		EVT = EVT,
		waitEvt = function(evt)
			local co = coroutine.running()

			if type(evt) ~= "table" then
				evt = {
					evt
				}
			end

			local function evtProc(evtName, ...)
				local args = {
					...
				}

				for k, v in pairs(evt) do
					EVT[v] = nil
				end

				local delayHandler = scheduler.performWithDelayGlobal(function()
					coroutine.resume(co, evtName, unpack(args))
				end, 0)

				if runner.delayHandlers then
					table.insert(runner.delayHandlers, delayHandler)
				end
			end

			for k, v in pairs(evt) do
				EVT[v] = evtProc
			end

			return coroutine.yield()
		end,
		onEvent = function(evt, ...)
			local proc = EVT[evt]

			if proc then
				runner.running = runner.running + 1

				local evtCo = coroutine.create(tryCall(proc, function()
					runner.running = runner.running - 1
				end, evt, ...))

				coroutine.resume(evtCo)
			end
		end,
		playerMoveTo = function(x, y, mapid, closeTo)
			scheduler.performWithDelayGlobal(function()
				main_scene.ui.console.autoRat:clearAllAct()
				main_scene.ui.console.autoRat:stop()
				main_scene.ui.console.controller.autoFindPath:searching(x, y, mapid, nil, closeTo)
			end, 0)
		end,
		stopPlayerMove = function()
			scheduler.performWithDelayGlobal(function()
				main_scene.ui.console.controller.autoFindPath:multiMapPathStop()
			end, 0)
		end,
		isPlayerMoving = function()
			local points = main_scene.ui.console.controller.autoFindPath.points

			return points and #points > 0
		end
	}

	setmetatable(env, {
		__index = runner.baseEnv
	})

	env._G = env

	for k, v in pairs(script) do
		if type(v) == "function" then
			setfenv(v, env)
		end
	end

	function runner.baseEnv.GUIDE:untilNodeExist(name, timeout)
		local evt = "target_is_visible:" .. name
		local co = coroutine.running()

		EVT[evt] = function(...)
			local args = {
				...
			}

			EVT[evt] = nil

			local delayHandler = scheduler.performWithDelayGlobal(function()
				coroutine.resume(co, unpack(args))
			end, 0)

			if runner.delayHandlers then
				table.insert(runner.delayHandlers, delayHandler)
			end
		end

		gd:checkUntilNodeExist(name, function(state)
			if state == "ok" then
				env.onEvent(evt)
			else
				env.onEvent(evt, "timeout")
			end
		end, timeout)

		return coroutine.yield()
	end

	return script, env
end

function runner.skip()
	runner.SKIP_PLAY = true

	if runner.delayHandlers then
		for k, v in pairs(runner.delayHandlers) do
			scheduler.unscheduleGlobal(v)
		end
	end

	if runner.curCo then
		coroutine.resume(runner.curCo)
	end
end

function runner.init()
	local gd = guide.new()

	runner.guide = gd

	if DEBUG then
		_G.gd = gd
	end

	local env

	env = {
		def = def,
		print = print,
		type = type,
		tonumber = tonumber,
		dump = dump,
		ipairs = ipairs,
		pairs = pairs,
		createRole = dummy.new,
		ACTS = dummy.acts,
		color = cc.c4b,
		pos = cc.p,
		mapPos = function(gameX, gameY)
			return gameX * mapDef.tile.w, (self.h - gameY) * mapDef.tile.h
		end,
		off2p = util.off2p,
		off2h = util.off2h,
		off2t = util.off2t,
		DIR = def.role.dir,
		math = math,
		getfenv = getfenv,
		getDir = util.getDir,
		inSet = util.inSet,
		featu = util.featu,
		state = dummy.state,
		string = string,
		table = table,
		GUIDE = gd,
		ITEMS = def.items,
		action = cca,
		display = {
			width = display.width,
			height = display.height,
			cx = display.cx,
			cy = display.cy
		},
		sound = sound,
		delay = function(time)
			local co = coroutine.running()
			local delayHandler = scheduler.performWithDelayGlobal(function()
				coroutine.resume(co)
			end, time)

			if runner.delayHandlers then
				table.insert(runner.delayHandlers, delayHandler)
			end

			coroutine.yield()
		end,
		bind = function(func, obj, ...)
			local args = {
				...
			}

			return function()
				return func(obj, unpack(args))
			end
		end,
		assign = function(obj, key, value)
			return function()
				obj[key] = value
			end
		end,
		createColorLayer = function(color, w, h, parent)
			return cc.LayerColor:create(color or cc.c4b(0, 0, 0, 255), w or display.width, h or display.height):add2(parent or runner.simStage or main_scene)
		end,
		createLabel = function(text, fontSize, outlineSize, params, parent)
			return an.newLabel(text, fontSize, outlineSize, params):add2(parent or runner.simStage or main_scene)
		end,
		createImage = function(name, parent)
			return res.get2_helper("pic/" .. name):add2(parent or runner.simStage or main_scene)
		end,
		createNode = function(parent)
			return display.newNode():add2(parent or runner.simStage or main_scene)
		end,
		createFrameAni = function(preFix, start, num, speed, parant)
			local ani = res.getani2("pic/helperScript/" .. preFix .. "%d.png", start, num, 1 / speed)
			local spr = display.newSprite():add2(parent or runner.simStage or main_scene)

			spr:runs({
				cc.Animate:create(ani),
				cca.callFunc(function()
					if spr.cb then
						local t = spr.cb

						spr.cb = nil

						t()
					end

					local evtCb = dummy.getEvtCallback()

					if evtCb then
						evtCb("frameAniFinish")
					end
				end)
			})

			return spr
		end,
		createSay = function(texts, strWidth, fontSize, dir, dur, parent)
			local node

			if dir == "left" then
				node = dummy.createSayDL(texts, strWidth, fontSize)
			else
				node = dummy.createSayDR(texts, strWidth, fontSize)
			end

			if dur then
				node:runs({
					cca.delay(dur),
					cca.removeSelf()
				})
			end

			return node:add2(parent or runner.simStage or main_scene)
		end,
		createSayDL = function(texts, strWidth, fontSize, dur, parent)
			return env.createSay(texts, strWidth, fontSize, "left", dur, parent)
		end,
		createSayDR = function(texts, strWidth, fontSize, dur, parent)
			return env.createSay(texts, strWidth, fontSize, "right", dur, parent)
		end,
		runActs = function(acts)
			table.insert(acts, cca.removeSelf())

			return display.newNode():add2(runner.simStage or main_scene):runs(acts)
		end,
		runActsRepeat = function(acts, times)
			return display.newNode():add2(runner.simStage or main_scene):runs({
				cca.req(acts, times),
				cca.removeSelf()
			})
		end,
		runActsForever = function(acts)
			return display.newNode():add2(runner.simStage or main_scene):runForever(cca.seq(acts))
		end,
		playVideo = function(videoName, keepAspectRatio)
			scheduler.performWithDelayGlobal(function()
				runner.video:setEvtCallback(dummy.evtCallback)
				runner.video:play("res/video/" .. videoName, {
					keepAspectRatio = keepAspectRatio
				})
			end, 0)
		end,
		getDeltaTime = function()
			return cc.Director:getInstance():getDeltaTime()
		end,
		enterStage = function(mapid, x, y, params)
			env.delay(0.01)
			res.purgeCachedData()

			local simStage

			if type(params) == "string" then
				params = {
					image = params
				}
			else
				params = params or {}
			end

			simStage = stage.new(mapid, x, y, params.image, params.disableSkip)

			simStage:setEvtCallback(dummy.evtCallback)

			trans = params.trans or {}

			if runner.simStage then
				display.replaceScene(simStage, unpack(trans))
			else
				cc.Director:getInstance():pushScene(simStage, unpack(trans))
			end

			runner.simStage = simStage
			simStage.runner = runner
		end,
		exitStage = function()
			if runner.simStage then
				res.purgeCachedData()
				cc.Director:getInstance():popScene()

				runner.simStage = nil
			end
		end,
		EFFIDS = mapDef,
		showEffect = function(etType, pos, dur)
			local map = runner.getMap()

			if not tolua.isnull(map) then
				dummy._showEvents(map, {
					pos
				}, etType, dur)
			end
		end,
		SKIP_PLAY = function()
			return runner.SKIP_PLAY
		end,
		isPanelOpenning = function(name)
			return not not main_scene.ui.panels[name]
		end,
		openPanel = function(name)
			main_scene.ui:showPanel(name)
		end,
		checkPlayerSkill = function(id)
			return not not g_data.player:getMagic(id)
		end,
		playerSay = function(str)
			scheduler.performWithDelayGlobal(function()
				net.send({
					CM_SAY
				}, {
					str
				})
			end, 0)
		end,
		STOP = function()
			runner.finish()
			coroutine.yield()
		end,
		gl = gl
	}
	runner.baseEnv = env

	setmetatable(env, {
		__index = globalDataGetter
	})

	if DEBUG > 0 then
		local reged = {}

		local function reg(m)
			reged[m] = true
		end

		getHelperScript("mod.init", {
			reg = reg
		})

		env.mod = {}

		setmetatable(env.mod, {
			__index = function(_, k)
				if not reged[k] then
					helper.obj:say("模块" .. k .. "未找到！", cc.c4b(150, 0, 0, 255))

					return
				end

				local script, err = getHelperScript("mod." .. k, env)

				if err then
					print("runner:init mod faild:", k, err)
				end

				local _, env = updateEnv(script)

				return function(...)
					local preEvtCallback = dummy.evtCallback

					local function cb(evt, ...)
						env.onEvent(evt, ...)
					end

					dummy.setEvtCallback(cb)
					runner.baseEnv.GUIDE:setEvtCallback(cb)

					local rets = {
						script.main(...)
					}

					dummy.setEvtCallback(preEvtCallback)

					return unpack(rets)
				end
			end
		})
	else
		local mod = {}

		local function reg(m)
			local script = getHelperScript("mod." .. m, env)

			mod[m] = script.main
		end

		env.mod = {}

		setmetatable(env.mod, {
			__index = function(_, k)
				local script = mod[k]
				local _, env = updateEnv(script)

				if script then
					return function(...)
						local preEvtCallback = dummy.evtCallback

						dummy.setEvtCallback(function(evt, ...)
							env.onEvent(evt, ...)
						end)

						local rets = {
							script.main(...)
						}

						dummy.setEvtCallback(preEvtCallback)

						return unpack(rets)
					end
				end
			end
		})
		getHelperScript("mod.init", {
			reg = reg
		})
	end
end

function runner.execute_(evtType, key)
	if runner.running > 0 then
		return
	end

	local env = runner.baseEnv
	local script, err = getHelperScript(evtType, env)

	if not script then
		if err == "script not exist" then
			print("事件对应脚本不存在，事件类型：" .. evtType)

			return
		else
			print(evtType)
		end

		if DEBUG > 0 then
			error(err)
		else
			return
		end
	end

	if script.Region then
		local mapid = main_scene.ground.map.mapid
		local mapRegion = script.Region[mapid] or script.Region["" .. mapid]

		if mapRegion then
			local x = main_scene.ground.player.x
			local y = main_scene.ground.player.y
			local ok = false

			for k, v in ipairs(mapRegion) do
				if math.abs(v.x - x) < (v.radio or 2) and math.abs(v.y - y) < (v.radio or 2) then
					if evtType == "enterRegion" then
						key = string.format("%s,%d,%d", mapid, v.x, v.y)
					end

					break
				end
			end
		end

		if not key then
			return
		end
	end

	if key then
		if script.MaxLevel and script.MaxLevel[key] and script.MaxLevel[key] <= main_scene.ground.player.level then
			print("max level")

			return
		end

		if script.MinLevel and script.MinLevel[key] and script.MinLevel[key] > main_scene.ground.player.level then
			print("min level")

			return
		end

		if script.Map then
			print("map")

			if not util.inSet(main_scene.ground.map.mapid, script.Map[key]) then
				return
			end
		end

		if not script.GuideAlways or not util.inSet(key, script.GuideAlways) then
			local cachename = evtType .. "Guided"
			local data = runner.getScriptCache(cachename)

			if data[key] == nil then
				data[key] = true
			else
				print("not always", evtType, key)

				return
			end
		end
	end

	local c = coroutine.create(tryCall(function(...)
		runner.running = runner.running + 1

		local _, env = updateEnv(script)

		dummy.setEvtCallback(function(evt, ...)
			env.onEvent(evt, ...)
		end)
		script.main(...)
	end, runner.finish, key))

	coroutine.resume(c)

	return true
end

function runner.execute(...)
	if not runner.execute_(...) then
		runner.finishCallback = nil

		return false
	end

	return true
end

function runner.onGlobalEvent(evt)
	print("scriptRunner onGlobalEvent ", evt)
	runner.execute("globalEvent", evt)
end

function runner.onClickHelper()
	runner.execute("clickedHelper")
end

function runner.onNewSkill(magicId)
	runner.execute("newSkill", magicId)
end

function runner.onLevelUp(level)
	runner.execute("levelUp", level)
end

function runner.onNewItem(itemid)
	runner.execute("newItem", itemid)
end

function runner.onKilledMonster(MonsterId)
	runner.execute("killedMonster", bossId)
end

function runner.onEnterMap(mapid)
	runner.execute("enterMap", mapid)
end

function runner.onOpenPanel(name)
	runner.execute("openPanel", name)
end

function runner.onBloodChg(percent)
	runner.execute("bloodChg", math.floor(percent * 100))
end

function runner.onUpdatePosition()
	runner.execute("enterRegion")
end

function runner.finish()
	runner.running = runner.running - 1
	runner.curCo = nil
	runner.SKIP_PLAY = nil
	runner.delayHandlers = nil

	if runner.finishCallback then
		t = runner.finishCallback
		runner.finishCallback = nil

		t()
	end
end

function runner.call(mod, ...)
	if runner.running > 0 then
		return
	end

	local proc = runner.baseEnv.mod[mod]

	runner.running = runner.running + 1
	runner.delayHandlers = {}

	local evtCo = coroutine.create(tryCall(proc, runner.finish, ...))

	coroutine.resume(evtCo)

	runner.curCo = evtCo
end

runner.init()

return runner
