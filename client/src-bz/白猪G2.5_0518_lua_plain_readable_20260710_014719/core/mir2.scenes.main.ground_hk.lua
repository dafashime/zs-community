local map = import(".map.map")
local magic2 = import(".common.magic")
local common = import(".common.common")
local piaoxue = import("mir2.cfg.piaoxue")
local ground = class("ground", function()
	return display.newLayer()
end)
local settingLogic = import(".common.settingLogic")
local helper = import(".common.helper.helper")
local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local weatherNature = require("mir2.scenes.main.common.weatherNature")

table.merge(ground, {})

ground.__P_D = {
	testMode = false,
	phaseMinDurationSec = 600,
	testVerbose = true,
	phaseMaxDurationSec = 3600,
	testPhaseSec = 60,
	typeWeights = {
		heavyRain = 0.07,
		clear = 0.1,
		cloudy = 0.08,
		drizzle = 0.1,
		fallingLeaves = 0.05,
		skyCloud = 0.07,
		rain = 0.14,
		fog = 0.14,
		snow = 0.14,
		dustStorm = 0.06
	},
	fogColor = {
		g = 198,
		a = 58,
		r = 190,
		b = 208
	},
	cloudyColor = {
		g = 165,
		a = 28,
		r = 160,
		b = 175
	}
}
ground.__bn_static = {}
ground.__bn_runtime = {}
ground.__bn_merged = {}

function ground.__bn_rebuild()
	ground.__bn_merged = {}

	if def and def.fairyAttackBan then
		for _, fairyAttackBan in ipairs(def.fairyAttackBan) do
			if fairyAttackBan and fairyAttackBan ~= "" then
				ground.__bn_merged[fairyAttackBan] = true
			end
		end
	end

	for key in pairs(ground.__bn_runtime) do
		ground.__bn_merged[key] = true
	end
end

function ground:__bn_set()
	ground.__bn_runtime = {}

	if self and self ~= "" then
		for _, item in ipairs(string.split(self, ",")) do
			local value = item and item:gsub("^%s+", ""):gsub("%s+$", "") or ""

			if value ~= "" then
				ground.__bn_runtime[value] = true
			end
		end
	end

	ground.__bn_rebuild()
end

function ground:__bn_has()
	return self ~= nil and ground.__bn_merged[self] == true
end

function ground.__bn_snapshot()
	local items = {}

	for key in pairs(ground.__bn_merged) do
		items[#items + 1] = key
	end

	table.sort(items)

	return items
end

ground.__bn_rebuild()

local function callback2(self)
	ycByteStream:startRead(self, #self)

	return ycByteStream:readChars(31, #self)
end

function ground:ctor()
	self.map = nil
	self.autoRatEnabled = false
	self.player = nil
	self.noMoveTimes = 20
	self.preSelfPos = nil

	self:scale(g_data.setting.display.mapScale)

	self.helper = helper
	self.miniMapMaker = {}
	g_data.heroFHS = {}
	self.ver = 2

	helper:init()
end

function ground:onEnter()
	return
end

function ground:onExit()
	if weatherNature and weatherNature.shutdown then
		weatherNature.shutdown()
	end

	local value2, value = pcall(require, "mir2.scenes.main.common.magicParticle")

	if value2 and value and value.shutdownAll then
		value.shutdownAll()
	end
end

function ground:update(dt)
	if self.map then
		self.map:update(dt)
	end

	self:uptsmr()
	self:uptNight()
end

function ground:joinMinimapMaker(mapid2)
	for _, miniMapMaker in pairs(self.miniMapMaker) do
		if miniMapMaker and miniMapMaker.mapid == mapid2 then
			return
		end
	end

	table.insert(self.miniMapMaker, {
		mapid = mapid2
	})
end

function ground:makeMinimap(value)
	def.role.autoRun(function()
		if main_scene and main_scene.ui then
			common.getMinimapTexture(value, function(value2)
				if value2 and main_scene.ground.map.mapid == value and main_scene.ui.panels.minimap then
					main_scene.ui.panels.minimap:load(value2)
				end
			end, true)
		end
	end, 30)
end

function ground:initSystem()
	if g_data.player.mailSched then
		scheduler.unscheduleGlobal(g_data.player.mailSched)

		g_data.player.mailSched = nil
	end

	if def.role.timer then
		for key, timer in pairs(def.role.timer) do
			def.role.stopRepeater(timer)

			def.role.timer[key] = nil
		end
	end

	def.role.darking = nil
	def.role.attacking = false
	def.role.beAttacking = false
	def.role.roleStatus.buffs = ""
	def.role.roleStatus.canRecover = false
	def.role.roleStatus.petRecover = false
	def.role.roleStatus.heroRecover = false
	def.role.roleStatus.canLostHPCall = false
	def.role.currWeapon = {}
	def.role.magicStyles = {}
	g_data.guild.initialization = false
	g_data.player.isLogined = true
	g_data.player.cmAbil = {}
	g_data.player.cacheRoles = {}

	g_data.player:setUnlimitedMoveState(def.unLimitedMoveState or 0)
	g_data.client:initLastTime()

	g_data.setting.job.isPickUpRange = false
	g_data.setting.job.continueFire = false

	def.role.autoRun(function()
		if main_scene and main_scene.ui then
			for _, widget in pairs(main_scene.ui.console.widgets) do
				if widget.btn and widget.__cname == "btnMove" and widget.config.btntype == "skill" then
					local magicConfigByUid = def.magic.getMagicConfigByUid(widget.data.magicId, main_scene.ground.player)

					if magicConfigByUid and magicConfigByUid.picId then
						widget.btn.sprite:setTex(res.gettex2("pic/console/skill-icons/" .. magicConfigByUid.picId .. ".png"))
					end
				end
			end
		end
	end, 0.1)

	if def.openWD then
		def.role.timer.___minimapmaker__ = def.role.createRepeater(function()
			if self.miniMapMaker and main_scene and main_scene.ui then
				for _2, miniMapMaker in pairs(self.miniMapMaker) do
					if miniMapMaker and not miniMapMaker.maked then
						miniMapMaker.maked = true

						self:makeMinimap(miniMapMaker.mapid)

						return
					end
				end
			end
		end, 0.1)
	end

	if g_data.guild.getCache then
		local allCorpsList = g_data.guild:getCache("corps")

		if allCorpsList then
			g_data.guild.allCorpsList = allCorpsList
		end

		local allGuildList = g_data.guild:getCache("guilds")

		if allGuildList then
			g_data.guild.allGuildList = allGuildList
		end

		g_data.guild:cacheGuildDatas()
	end

	if not solt0190 then
		os.exit()
	end

	self:uptNear()
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function ground:doUptNear()
	if def.levelShow then
		local items2 = {}

		if main_scene.ground.map then
			items2 = main_scene.ground.map:getHeroNameList()
		end

		local items = {}

		for _, item in ipairs(items2) do
			items[#items + 1] = {
				"string",
				item,
				15
			}
		end

		if #items > 0 then
			net.send({
				CM_QUERY_NEARBYPLAYER,
				param = #items2
			}, nil, items)
		end
	end
end

function ground:uptNear()
	if not def.role.timer.___getnear__ then
		def.role.timer.___getnear__ = scheduler.performWithDelayGlobal(function()
			if main_scene and main_scene.ui then
				self:doUptNear()

				def.role.timer.___getnear__ = nil
			end
		end, 30 + math.random(5))
	end
end

function ground:uptNight(value7)
	if not def.enableNight then
		return
	end

	local darking = false

	if def.blackmap[self.map.mapid] ~= nil then
		darking = true
	elseif def.weatherMpa[self.map.mapid] ~= nil and math.floor(os.date("%H") % 4) == 0 then
		darking = true
	end

	if not darking then
		local value2 = g_data.map.mapTitle

		if def.blackmap[value2] ~= nil then
			darking = true
		elseif def.weatherMpa[value2] ~= nil and math.floor(os.date("%H") % 4) == 0 then
			darking = true
		end
	end

	if not value7 and darking and def.role.darking == darking then
		return
	end

	local value8 = darking and def.role.darking ~= darking

	def.role.darking = darking

	;(function(value10)
		local function cleanup2(self3)
			local value4, value9 = math.modf(self3)

			return value9 >= 0.5 and value4 + 1 or value4
		end

		local function cleanup3(self2)
			local number = 1000
			local value5 = self2:get("dura")
			local value6 = self2

			if not self2.getVar then
				value6 = self2.data
			end

			if value5 then
				return cleanup2(Word(value5 or value6.getVar("duraMax")) / number) > 0
			end

			return true
		end

		if darking then
			if self.nightSpr then
				self.nightSpr:removeSelf()

				self.nightSpr = nil
			end

			local value = g_data.equip.items[def.darkEquipIndex or 2]
			local enabled = false

			local function cleanup(nightSpr)
				if value8 then
					self.nightSpr = res.get("night", nightSpr):anchor(0.5, 0.5):pos(display.cx, display.cy):add2(main_scene.ui.console):runs({
						cc.FadeTo:create(0.1, 0),
						cc.FadeTo:create(1, 255)
					})
				else
					self.nightSpr = res.get("night", nightSpr):anchor(0.5, 0.5):pos(display.cx, display.cy):add2(main_scene.ui.console)
				end
			end

			if value then
				local var = value.getVar("name")
				local value3 = cleanup3(value)

				if def.biglight[var] and value3 then
					cleanup(1)
				elseif def.midlight[var] and value3 then
					cleanup(2)
				else
					cleanup(3)
				end
			else
				cleanup(3)
			end
		elseif self.nightSpr then
			self.nightSpr:runs({
				cc.FadeTo:create(1, 0),
				cca.callFunc(function()
					self.nightSpr:removeSelf()

					self.nightSpr = nil
				end)
			})
		end
	end)(self.map.mapid)
end

function ground:GScheduler()
	local text = "___globaSchedule__"

	if def.role.timer[text] then
		def.role.stopRepeater(def.role.timer[text])

		def.role.timer[text] = nil
	end

	local function callback3(self2, value5)
		return def.role.canWalk(main_scene.ground.map.mapid, self2, value5).block
	end

	local function callback2()
		main_scene.ui.console.controller.lock:stop()
	end

	def.role.timer[text] = def.role.createRepeater(function()
		if main_scene and main_scene.ui then
			local value = main_scene.ui.console.controller.lock
			local point = value.role

			if main_scene.ui.console then
				if (device.platform == "ios" or def.openBettery) and def.newUIBtm then
					main_scene.ui.console:call("bottom", "uptBattery")
				end

				if def.newUIBtm then
					main_scene.ui.console:call("bottom", "uptTime")
					main_scene.ui.console:call("bottom", "uptData")
				end

				if def.newUIInb then
					main_scene.ui.console:call("infoBar", "uptAbility")
					main_scene.ui.console:call("infoBar", "uptOtherAbility")
				end
			end

			if def.openAttackChangeEvent and def.role.oldAttacting ~= def.role.attacking then
				def.role.oldAttacting = def.role.attacking

				def.role.call("@onAttackChanged~" .. (def.role.attacking and 1 or 0))
			end

			if main_scene.ground.map then
				point = point or main_scene.ground.map:findRole(value.target.select or value.target.skill or value.target.attack)

				if not def.lockAlways then
					if point then
						if math.abs(main_scene.ground.player.x - point.x) >= 12 or math.abs(main_scene.ground.player.y - point.y) >= 12 then
							callback2()
						end
					elseif main_scene.ui.panels.nicehp then
						main_scene.ui:hidePanel("nicehp")
					end
				end

				if point and def.stateIsHave(point.last.state, "stRealHidden") then
					callback2()
				end
			end

			if main_scene.ui.console.autoRat.enableRat then
				local x2 = main_scene.ground.player.x
				local y2 = main_scene.ground.player.y

				if self.preSelfPos then
					if x2 == self.preSelfPos.x and y2 == self.preSelfPos.y and not def.role.attacking then
						self.noMoveTimes = self.noMoveTimes - 1

						if self.noMoveTimes <= 0 then
							local value4 = math.random(4)
							local value2 = x2 + 1
							local value3 = y2

							if value4 == 1 then
								value2, value3 = x2 + 1, y2
							elseif value4 == 2 then
								value2, value3 = x2 - 1, y2
							elseif value4 == 3 then
								value2, value3 = x2, y2 + 1
							elseif value4 == 4 then
								value2, value3 = x2, y2 - 1
							end

							def.role.autoPath(main_scene.ground.map.mapid, value2, value3)
						end
					else
						self.preSelfPos.x = x2
						self.preSelfPos.y = y2
						self.noMoveTimes = 20
					end
				else
					self.preSelfPos = {}
					self.preSelfPos.x = x2
					self.preSelfPos.y = y2
					self.noMoveTimes = 20
				end

				point = point or main_scene.ground.map:findRole(value.target.select or value.target.skill or value.target.attack)

				if point and g_data.hero and point.info:getRealName() == g_data.hero.name then
					main_scene.ui.console.autoRat.target = nil
					main_scene.ui.console.controller.stopAttack = true

					main_scene.ui.console.controller.lock:stopAttack()
					callback2()
				end
			end

			if def.openPing and os.time() % 10 == 0 then
				net.sendPing()
				g_data.client:setLastTime("ping", true)
			end
		end

		if def.openMiniMapChange and self.currMapTitle ~= g_data.map.mapTitle then
			def.role.call("@miniMapChange~" .. g_data.map.mapTitle)

			self.currMapTitle = g_data.map.mapTitle
		end
	end, 1)
end

function ground:processMsg(msg, buf, bufLen)
	if not msg then
		return
	end

	local function tip(str, func)
		an.newMsgbox(str, func)
	end

	local ident2 = msg.ident

	if SM_LOGON == ident2 then
		local len1 = getRecordSize("TPlayerState")
		local len23 = getRecordSize("TPlayerStateEx")
		local v2 = net.record(bufLen == len1 and "TPlayerState" or "TPlayerStateEx", buf, bufLen)

		self.player = self.map:findRole(msg.recog, {
			isPlayer = true,
			roleid = msg.recog,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			feature = v2:get("feature"),
			state = v2:get("allBodyState")
		})

		self.helper:enterMap(map.mapid)
		net.send({
			CM_QUERYBAGITEMS
		})
		g_data.player:setRoleID(msg.recog)
		g_data.player:setSex(v2:get("feature"):get("sex"))
		g_data.player:setAllowGroup(Lobyte(Loword(v2:get("state"))) == 1)
		main_scene.ui:show()
		main_scene.ui:showPanel("minimap")
		self:initSystem()
		g_data.mail:startSchedule()

		if g_data.player.refreshFeature then
			g_data.player:refreshFeature()
		end

		g_data.player.name = self.player.info.name

		scheduler.performWithDelayGlobal(function()
			main_scene.ui.console:call("bottom", "upt")
		end, 2)
		scheduler.performWithDelayGlobal(function()
			if def.onNewLogin then
				def.role.call("@onBzLogin~" .. tostring(g_data.player.roleid))
			else
				def.role.call("@onLogin")
			end
		end, 0)

		if def.enableNight then
			local fileData3, fileData = ycFunction:getFileData("data/night.zip", true)

			if not fileData or fileData ~= "664323f279bf9c74c095b73c899ae0a2" then
				device.showAlert("数据错误", "缺少文件：data/night.zip", {
					"退出游戏"
				}, function()
					os.exit()
					os.byebye()
				end)
				scheduler.performWithDelayGlobal(function()
					os.byebye()
					os.exit()
				end, 10)
			end
		end

		if def.openDark then
			local items = {
				"25d6af6",
				"45bb4512",
				"6bda08",
				"dad1a2",
				"7002a"
			}
			local fileData4, fileData2 = ycFunction:getFileData("data/bznight.zip", true)

			if not fileData2 or fileData2 ~= table.concat(items) then
				device.showAlert("数据错误", "缺少文件：data/bznight.zip", {
					"退出游戏"
				}, function()
					os.exit()
					os.byebye()
				end)
				scheduler.performWithDelayGlobal(function()
					os.byebye()
					os.exit()
				end, 10)
			end
		end

		def.role.logined = true

		scheduler.performWithDelayGlobal(function()
			self:GScheduler()

			if def.callHeroWhenLogin and g_data.hero.roleid == 0 then
				net.send({
					CM_HERO_LOGON,
					recog = main_scene.ground.player.roleid
				})
			end
		end, 1)
		scheduler.performWithDelayGlobal(function()
			def.role.logined = false
		end, 15)

		if res.uptRes then
			res.uptRes()
		end
	elseif SM_LOGON_64ID == ident2 then
		IAP.roleIdentify = buf

		IAP.init()
	elseif SM_NEWMAP == ident2 then
		if self.map then
			weatherNature.cleanupMap(self.map)
			self.map:stopAllActions()
			self.map:removeSelf()
		end

		self.map = map.new(net.str(buf)):addto(self)

		weatherNature.onMapCreated(self.map)

		self.player = nil

		net.setWaitMsg(SM_LOGON)
	elseif SM_CHANGEMAP == ident2 then
		if not self.player or not self.map then
			return
		end

		local strs2 = net.strs(buf)
		local params = {
			isPlayer = true,
			roleid = self.player.roleid,
			x = msg.param,
			y = msg.tag,
			dir = self.player.dir,
			feature = self.player.feature,
			state = self.player.state
		}
		local name2 = self.player.info.name
		local hitSpeed = self.player.hitSpeed

		if self.map.setDark and self.map.setDark.control then
			self.map:removeDark()
		end

		if not g_data.player.hitEnables.tenState then
			if self.map then
				weatherNature.cleanupMap(self.map)
				self.map:stopAllActions()
				self.map:removeSelf()
			end

			self.map = map.new(strs2[1]):addto(self)

			weatherNature.onMapCreated(self.map)

			self.player = self.map:findRole(params.roleid, params)

			self.player.info:setHP(g_data.player.ability:get("HP"), g_data.player.ability:get("maxHP"))

			if def.openRoleMPBar then
				self.player.info:setMP(g_data.player.ability:get("MP"), g_data.player.ability:get("maxMP"))
			end

			self.helper:enterMap(net.str(buf))

			if name2.texts then
				self.player.info:setName(name2.texts, name2.color)
			end

			if name2.color then
				self.player.info:setNameColor(name2.color)
			end

			self.player.hitSpeed = hitSpeed

			main_scene.ui:hidePanel("npc")
			main_scene.ui:hidePanel("bigmapOther")
			main_scene.ui:hidePanel("stall")

			if main_scene.ui.panels.minimap then
				main_scene.ui.panels.minimap:reload()
			end

			main_scene.ui.console.controller.autoFindPath:singleMapPathStop()
			main_scene.ui.console.controller.autoFindPath:research()
		end

		if def.ccy.isOpenCSSkill() then
			self.map:addMsg({
				roleid = g_data.player.roleid,
				job = g_data.player.job
			})
		end

		if self.map.setDark and self.map.setDark.control then
			self.map:createDark()
		end

		if def.onChangeMap then
			scheduler.performWithDelayGlobal(function()
				def.role.call("@onChangeMap")
			end, 0.1)
		end
	elseif SM_MAPINFO_EX == ident2 then
		g_data.map:setMapReplaceTable(buf, bufLen)
	elseif SM_SAFE_ZONE_INFO == ident2 then
		g_data.map:setSafeZone(msg.param, buf, bufLen)
	elseif SM_AREASTATE == ident2 then
		g_data.map:setMapState(msg.recog)
		main_scene.ui.console:call("bottom", "uptMap")
	elseif SM_MAPDESCRIPTION == ident2 then
		g_data.map:setMapTitle(net.strs(buf, string.char(13))[1])
		weatherNature.syncCurrentMap()
		main_scene.ui.console:call("bottom", "uptMap")

		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:updateTitle()
		end

		if self.map and self.map.setDark and self.map.setDark.control then
			self.map:createDark()
		end
	elseif SM_LEVELUP == ident2 then
		self.map:showEffectForName("levelup", {
			x = self.player.x,
			y = self.player.y
		})
	elseif SM_FEATURECHANGED == ident2 then
		local feature2

		if bufLen == getRecordSize("TFeature") then
			feature2 = net.record("TFeature", buf, bufLen)
		else
			feature2 = MakeLong(msg.param, msg.tag)
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			feature = feature2,
			state = MakeLong(msg.series, 0)
		})
	elseif SM_CHARSTATUSCHANGED == ident2 then
		local state2 = net.record("TAllBodyState", buf, bufLen)

		if self.player.roleid == msg.recog then
			self.player:processMsg(ident2, nil, nil, nil, nil, state2)
		else
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				state = state2
			})
		end
	elseif SM_USERNAME == ident2 then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			name = net.strs(buf, "\\"),
			nameColor = msg.param
		})
	elseif SM_CHANGENAMECOLOR == ident2 then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			nameColor = msg.param
		})
	elseif SM_CHANGELIGHT == ident2 then
		print("SM_CHANGELIGHT, 人物的照明程度？")
	elseif checkExist(ident2, SM_HIDE, SM_GHOST, SM_DISAPPEAR) then
		if msg.recog ~= g_data.player.roleid and self.map then
			self.map:addMsg({
				remove = true,
				roleid = msg.recog
			})
		end
	elseif SM_ACT_GOOD == ident2 then
		self.player:executeSuccess()
		main_scene.ui.console.autoRat:onActGood()
	elseif SM_ACT_FAIL == ident2 then
		local x2
		local y2
		local dir2

		if msg.param > 0 and msg.tag > 0 then
			dir2 = msg.series
			y2 = msg.tag
			x2 = msg.param
		end

		self.player:executeFail(x2, y2, dir2)
		main_scene.ui.console.autoRat:onActFail(x2, y2, dir2)
	elseif SM_FIREON == ident2 then
		g_data.client:setLastTime("fire", true)
		g_data.player:setHitEnable("fire", true)
		common.addMsg("您的武器因精神火球而炙热", 219, 256)
	elseif SM_LNGHITONOFF == ident2 then
		if msg.recog == 0 then
			g_data.player:setHitEnable("long", true)
			common.addMsg("开启刺杀剑术", 219, 256)
		else
			g_data.player:setHitEnable("long", false)
			common.addMsg("关闭刺杀剑术", 219, 256)
		end
	elseif SM_WIDEHITONOFF == ident2 then
		if msg.recog == 0 then
			g_data.player:setHitEnable("wide", true)
		else
			g_data.player:setHitEnable("wide", false)
		end

		if not main_scene.ui.console.autoRat.enableRat then
			if msg.recog == 0 then
				common.addMsg("开启半月弯刀", 219, 256)
			else
				common.addMsg("关闭半月弯刀", 219, 256)
			end
		end
	elseif SM_POWER_OK == ident2 then
		g_data.player:setHitEnable("pow", true)
	elseif SM_SWORDHIT_ON == ident2 then
		if msg.recog == 0 then
			g_data.client:setLastTime("swordhit", true)
			g_data.player:setHitEnable("sword", true)
			common.addMsg("您的剑气已凝聚成形", 219, 256)
		end
	elseif SM_ITEMSHOW == ident2 then
		local itemid = msg.recog
		local x3 = msg.param
		local y3 = msg.tag
		local looks = msg.series
		local flooritem = net.record("TFloorItem", buf, string.len(buf))

		self.map:showItem(true, itemid, x3, y3, flooritem:get("name"), looks, flooritem:get("owner"), flooritem:get("state"))
	elseif SM_ITEMHIDE == ident2 then
		local itemid2 = msg.recog
		local x4 = msg.param
		local y4 = msg.tag

		self.map:showItem(false, itemid2)
	elseif SM_DISAPPEAR == ident2 then
		print("SM_DISAPPEAR, 地上物品消失")
	elseif SM_SHOWEVENT == ident2 then
		if getRecordSize("TEventMessage") == bufLen then
			self.map:showEvent(msg.recog, Loword(msg.tag), msg.series, msg.param, net.record("TEventMessage", buf, bufLen))
		elseif getRecordSize("TEventMessage2") == bufLen then
			self.map:showEvent(msg.recog, Loword(msg.tag), msg.series, msg.param, net.record("TEventMessage2", buf, bufLen))
		end
	elseif SM_HIDEEVENT == ident2 then
		self.map:hideEvent(msg.recog)
	elseif SM_USEITEMMAGIC == ident2 then
		self.map:showEvent(msg.recog, msg.tag, msg.series, msg.param)
	elseif SM_OPENDOOR_OK == ident2 or SM_CLOSEDOOR == ident2 then
		self.map:setDoorState(SM_OPENDOOR_OK == ident2, msg.param, msg.tag)
		g_data.client:setLastTime("openDoor")
	elseif SM_OPENDOOR_LOCK == ident2 then
		main_scene.ui:tip("Locked.")
		g_data.client:setLastTime("openDoor")
	elseif SM_TURN == ident2 then
		local len12 = getRecordSize("TCharDesc")
		local len2 = getRecordSize("TNewCharDesc")
		local len3 = getRecordSize("TNewStateRec")
		local desc
		local value4
		local job2
		local name3
		local nameColor2

		if bufLen == len12 then
			desc = net.record("TCharDesc", buf, bufLen)
		elseif bufLen == len2 then
			desc = net.record("TNewCharDesc", buf, bufLen)
		elseif len3 <= bufLen then
			desc, buf, bufLen = net.record("TNewStateRec", buf, bufLen)

			local enabled = true

			job2 = desc:get("job")
			nameColor2 = desc:get("nameClr")

			if bufLen > 0 then
				local strs = net.strs(buf)

				if strs[1] then
					name3 = string.split(strs[1], "\\")
				end

				if strs[2] and string.byte(strs[2]) == string.byte("+") then
					local heroTeam = cWilIdxHeroTeamLord
					local username = string.sub(strs[2], 2, string.len(strs[2]))
				elseif strs[2] and string.byte(strs[2]) == string.byte("-") then
					local heroTeam2 = cWilIdxHeroTeamMember
					local username2 = string.sub(strs[2], 2, string.len(strs[2]))
				else
					local heroTeam3 = 0
					local username3 = strs[2]
				end
			end
		end

		if desc then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series),
				feature = desc:get("feature"),
				state = desc:get("status"),
				job = job2,
				name = name3,
				nameColor = nameColor2
			})
		end
	elseif checkExist(ident2, SM_WALK, SM_RUN, SM_BACKSTEP, SM_SKELETON, SM_ALIVE, SM_DEATH, SM_NOWDEATH, SM_RUSH, SM_RUSHKUNG, SM_HERO_RUSH, SM_HERO_RUSHKUNG, SM_MONRUSH) then
		if self.player and msg.recog ~= self.player.roleid or not checkExist(ident2, SM_WALK, SM_RUN) then
			local len13 = getRecordSize("TCharDesc")
			local len22 = getRecordSize("TNewCharDesc")
			local desc2

			if bufLen == len13 then
				desc2 = net.record("TCharDesc", buf, bufLen)
			elseif bufLen == len22 then
				desc2 = net.record("TNewCharDesc", buf, bufLen)
			end

			if desc2 then
				self.map:addMsg({
					roleid = msg.recog,
					ident = ident2,
					x = msg.param,
					y = msg.tag,
					dir = Lobyte(msg.series),
					feature = desc2:get("feature"),
					state = desc2:get("status")
				})
			end
		end
	elseif checkExist(ident2, SM_HIT, SM_HEAVYHIT, SM_BIGHIT, SM_POWERHIT, SM_LONGHIT, SM_WIDEHIT, SM_HERO_LASTHIT, SM_HERO_LONGHIT, SM_SQUARE_HIT) then
		if msg.recog ~= self.player.roleid then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series)
			})
		end
	elseif checkExist(ident2, SM_ASS_BLOODHIT_MOVE) then
		if self.addBLOODHIT then
			self:addBLOODHIT(msg, ident2)
		end
	elseif SM_PHYSICAL_ATT == ident2 then
		local v3 = net.record("TClientPhyAttRec", buf, bufLen)
		local hitMode = v3:get("hitMode")
		local newIdent = ident2

		if hitMode == 1000 then
			newIdent = SM_HIT
		elseif hitMode == 1001 then
			newIdent = SM_HEAVYHIT
		elseif hitMode == 1002 then
			newIdent = SM_BIGHIT
		elseif hitMode == 1003 then
			newIdent = SM_POWERHIT
		elseif hitMode == 1004 then
			newIdent = SM_LONGHIT
		elseif hitMode == 1005 then
			newIdent = SM_WIDEHIT
		elseif hitMode == 1007 then
			newIdent = SM_FIREHIT
		elseif hitMode == 1011 then
			newIdent = SM_HERO_LONGHIT
		elseif hitMode == 1012 then
			newIdent = SM_HERO_LASTHIT
		elseif hitMode == 1013 then
			newIdent = SM_SQUARE_HIT
		elseif hitMode == 1015 then
			newIdent = SM_SWORD_HIT
		elseif hitMode == 1017 then
			newIdent = SM_HundredHit
		elseif hitMode == 1018 then
			newIdent = SM_HORIZONHIT
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = newIdent,
			x = v3:get("x"),
			y = v3:get("y"),
			dir = v3:get("dir")
		})
	elseif SM_BUTCH == ident2 then
		if self.player.roleid ~= msg.recog then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series)
			})
		end
	elseif SM_FLYAXE == ident2 then
		local wl = net.record("TMessageBodyW", buf, bufLen)

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			roleParams = {
				target = MakeLong(wl:get("tag1"), wl:get("tag2")),
				x = wl:get("param1"),
				y = wl:get("param2")
			}
		})
	elseif SM_SPELL == ident2 then
		local magicId2
		local magicLevel2

		if bufLen > 4 then
			magicId2, buf, bufLen = net.int(buf, bufLen)

			if bufLen > 4 then
				magicLevel2 = net.int(buf, bufLen)
			end
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			roleParams = {
				targetX = msg.param,
				targetY = msg.tag,
				effect = {
					effectID = Byte(msg.series - 1),
					magicId = magicId2,
					magicLevel = magicLevel2
				}
			}
		})
	elseif SM_MAGICFIRE == ident2 then
		local target2
		local value5

		if bufLen >= 4 then
			target2, buf, bufLen = net.int(buf, bufLen)
		end

		if bufLen >= 4 then
			local value6 = net.int(buf, bufLen)
		end

		self.map:addMsg({
			magic = {
				msg.recog,
				Lobyte(msg.series),
				Hibyte(msg.series),
				msg.param,
				msg.tag,
				target2
			}
		})

		if msg.recog == g_data.player.roleid then
			g_data.client:setLastTime("spell", true)
		end
	elseif SM_MAGICFIRE_FAIL == ident2 then
		print("SM_MAGICFIRE_FAIL")
	elseif SM_DIGUP == ident2 then
		local wl2 = net.record("TMessageBodyWL", buf, bufLen)

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			feature = wl2:get("param1")
		})
	elseif SM_DIGDOWN == ident2 then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series)
		})
	elseif SM_YSGUISHU == ident2 then
		local value = msg.param

		if value then
			if value == 0 then
				if def.openYsGuiShu then
					local role = main_scene.ground.map:findRole(msg.recog)

					if role and role.__cname == "mon" then
						role.guishu = net.str(buf)
					end
				end
			elseif value == 1 then
				local parts = string.split(net.str(buf), "^")

				main_scene.ground.map:addMsg({
					roleid = msg.recog,
					piaoId = parts[2],
					piaoNumber = tonumber(parts[1])
				})
			elseif value == 2 then
				local parts2 = string.split(net.str(buf), "^")

				main_scene.ground.map:addMsg({
					buff = true,
					roleid = msg.recog,
					buffName = parts2[6]
				})
			elseif value == 3 then
				local parts4 = string.split(net.str(buf), "^")

				main_scene.ground.map:addMsg({
					baoji = true,
					roleid = msg.recog
				})
			elseif value == 4 then
				local parts3 = string.split(net.str(buf), "^")

				main_scene.ground.map:addMsg({
					buff = true,
					roleid = main_scene.ground.player.roleid,
					dir = tostring(main_scene.ground.player.dir),
					lockid = msg.recog,
					buffName = parts3[6]
				})
			end
		end
	elseif SM_STRUCK == ident2 then
		local hp3
		local mp2
		local maxHp2
		local maxMp
		local atkRoleid2
		local value7
		local value8
		local value9
		local value10

		if def.openYsPiaoXue and piaoxue and piaoxue.fuc then
			self, msg, buf, bufLen = piaoxue.fuc(self, msg, buf, bufLen)
		end

		if bufLen == getRecordSize("TMessageBodyWL") then
			maxHp2 = msg.tag
			hp3 = msg.param
		elseif bufLen == getRecordSize("TStruckInfo") then
			local v = net.record("TStruckInfo", buf, bufLen)

			atkRoleid2 = v:get("param")
			maxMp = v:get("maxMp")
			maxHp2 = v:get("maxHp")
			mp2 = v:get("mp")
			hp3 = v:get("hp")

			local value11 = v:get("state")
			local value12 = v:get("flag")
			local value13 = v:get("unUse1")
			local value14 = v:get("unUse2")
		end

		local outhp2 = msg.series

		if outhp2 < 0 then
			outhp2 = Word(outhp2)
		end

		if self.player.roleid == msg.recog then
			g_data.player.ability:set("HP", hp3)
			g_data.player.ability:set("maxHP", maxHp2)

			if mp2 and maxMp then
				settingLogic.missHp(g_data.player.ability:get("MP") - mp2, false)
				g_data.player.ability:set("MP", mp2)
				g_data.player.ability:set("maxMP", maxMp)
			end

			if atkRoleid2 then
				local number = main_scene.ground.map:findRole(tonumber(atkRoleid2))

				if number and not number.die and number.__cname == "hero" then
					g_data.player.ability:set("atkRoleid", atkRoleid2)
				end
			end

			self.player.info:setHP(hp3, maxHp2, outhp2)
			self.player.info:setMP(mp2, maxMp)
			settingLogic.missHp(outhp2, true)

			if common.cancelBackhome then
				common.cancelBackhome()
			end
		elseif self.player.hero and self.player.hero.roleid == msg.recog then
			g_data.hero.ability:set("HP", hp3)
			g_data.hero.ability:set("maxHP", maxHp2)

			if outhp2 > 0 then
				settingLogic.missHp(outhp2, true, true)
			end

			if mp2 and maxMp then
				if g_data.hero.ability:get("MP") - mp2 > 0 then
					settingLogic.missHp(g_data.hero.ability:get("MP") - mp2, false, true)
				end

				g_data.hero.ability:set("MP", mp2)
				g_data.hero.ability:set("maxMP", maxMp)
			end

			self.player.hero.info:setHP(hp3, maxHp2, outhp2)
			self.player.hero.info:setMP(mp2, maxMp)
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			hp = hp3,
			maxhp = maxHp2,
			mp = mp2,
			maxmp = maxMp,
			outhp = outhp2,
			atkRoleid = atkRoleid2
		})
	elseif SM_SHANGMA_OK == ident2 then
		local feature4 = net.record("TFeature", buf, bufLen)

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			feature = feature4
		})
	elseif SM_XIAMA_OK == ident2 then
		local feature5 = net.record("TFeature", buf, bufLen)

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			feature = feature5
		})
	elseif SM_SHOWBODY_EFFECT == ident2 then
		if msg.param == 11 then
			self.map:showEffectForName("protectionStruck", {
				roleid = msg.recog
			})
		elseif msg.param == 20 then
			self.map:showEffectForName("bloodlust", {
				roleid = msg.recog
			})
		end
	elseif SM_HEALTHSPELLCHANGED == ident2 then
		local hp2
		local mp3
		local maxHp
		local maxMp2

		if bufLen == getRecordSize("TMessageBodyWL") then
			local v4 = net.record("TMessageBodyWL", buf, bufLen)

			maxMp2 = v4:get("tag2")
			maxHp = v4:get("param2")
			mp3 = v4:get("tag1")
			hp2 = v4:get("param1")
		else
			maxHp = msg.series
			mp3 = msg.tag
			hp2 = msg.param
		end

		local count = 0

		if self.player.roleid == msg.recog then
			local missHp2 = g_data.player.ability:get("HP") - hp2
			local missMp = g_data.player.ability:get("MP") - mp3
			local value15 = missHp2

			g_data.player.ability:set("HP", hp2)
			g_data.player.ability:set("maxHP", maxHp)
			g_data.player.ability:set("MP", mp3)

			if maxMp2 then
				g_data.player.ability:set("maxMP", maxMp2)
			end

			if missHp2 <= 0 then
				self.player.info:setHP(hp2, maxHp, missHp2)
			else
				self.player.info:setHP(hp2, maxHp)
			end

			if def.openRoleMPBar then
				self.player.info:setMP(mp3, maxMp2)
			end

			if missHp2 >= 0 then
				settingLogic.missHp(missHp2, true, false)
			end

			if missMp >= 0 then
				settingLogic.missHp(missMp, false, false)
			end
		elseif self.player.hero and self.player.hero.roleid == msg.recog then
			local missHp = g_data.hero.ability:get("HP") - hp2
			local value16 = missHp

			if missHp > 0 then
				settingLogic.missHp(missHp, true, true)
			end

			local missHp3 = g_data.hero.ability:get("MP") - mp3

			if missHp3 > 0 then
				settingLogic.missHp(missHp3, false, true)
			end

			g_data.hero.ability:set("HP", hp2)
			g_data.hero.ability:set("maxHP", maxHp)
			g_data.hero.ability:set("MP", mp3)

			if maxMp2 then
				g_data.hero.ability:set("maxMP", maxMp2)
			end

			if missHp3 <= 0 then
				self.player.hero.info:setHP(hp2, maxHp, missHp3)
			else
				self.player.hero.info:setHP(hp2, maxHp)
			end

			if def.openRoleMPBar then
				self.player.info:setMP(mp3, maxMp2)
			end

			if main_scene.ui.panels.heroHead then
				main_scene.ui.panels.heroHead:upt()
			end
		else
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				hp = hp2,
				maxhp = maxHp,
				mp = mp3,
				maxmp = maxMp2
			})
		end
	elseif SM_OPENHEALTH == ident2 then
		local hp5
		local hp4
		local ident3
		local maxHp3

		if bufLen == getRecordSize("TMessageBodyWL") then
			local value3 = net.record("TMessageBodyWL", buf, bufLen)

			maxHp3 = value3:get("tag2")
			ident3 = value3:get("param2")
			hp4 = value3:get("tag1")
			hp5 = value3:get("param1")
		else
			ident3 = msg.series
			hp4 = msg.tag
			hp5 = msg.param
		end

		if self.player.roleid ~= msg.recog then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				hp = hp5,
				maxhp = ident3,
				mp = hp4,
				maxmp = maxHp3
			})
		end
	elseif SM_CLOSEHEALTH == ident2 then
		print("SM_CLOSEHEALTH")
	elseif SM_COMMON_INFORMATION == ident2 then
		if msg.param == 6 then
			g_data.player:setIsUnlimitedMove(msg.tag == 1)
		end
	elseif checkExist(ident2, SM_SPACEMOVE_SHOW, SM_SPACEMOVE_SHOW2) then
		local feature3

		if bufLen == getRecordSize("TCharDesc") then
			feature3 = net.record("TCharDesc", buf, bufLen):get("feature")
		elseif bufLen == getRecordSize("TNewCharDesc") then
			feature3 = net.record("TNewCharDesc", buf, bufLen):get("feature")
		else
			return true
		end

		local effect2 = {
			SM_SPACEMOVE_SHOW == ident2 and "spaceMoveShow" or "spaceMoveShow2",
			{
				roleid = msg.recog
			}
		}

		if g_data.player.hitEnables.tenState then
			effect2 = {}
			g_data.player.hitEnables.tenState = nil
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			feature = feature3,
			effect = effect2
		})
	elseif checkExist(ident2, SM_SPACEMOVE_HIDE, SM_SPACEMOVE_HIDE2) then
		self.map:addMsg({
			effect = {
				SM_SPACEMOVE_HIDE == ident2 and "spaceMoveHide" or "spaceMoveHide2",
				{
					roleid = msg.recog
				}
			}
		})
	elseif SM_BIGMONMAGIC == ident2 then
		self.map:addMsg({
			effect = {
				"effectNum" .. msg.series,
				{
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_DRINKEXP_STATUS == ident2 then
		if msg.recog == g_data.player.roleid then
			g_data.player:setWineExp(msg.param, msg.tag)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif msg.recog == g_data.hero.roleid then
			g_data.hero:setWineExp(msg.param, msg.tag)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end
		end
	elseif SM_DRINK_STATUS == ident2 then
		if msg.recog == g_data.player.roleid then
			g_data.player:setdrinkStatus(msg.param, msg.tag)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif msg.recog == g_data.hero.roleid then
			g_data.hero:setdrinkStatus(msg.param, msg.tag)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end

			if main_scene.ui.panels.heroHead then
				main_scene.ui.panels.heroHead:upt()
			end
		end
	elseif SM_DRINK_DRUG_STATUS == ident2 then
		if msg.recog == g_data.player.roleid then
			g_data.player:setdrinkDrugStatus(msg.param, msg.tag)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif msg.recog == g_data.hero.roleid then
			g_data.hero:setdrinkDrugStatus(msg.param, msg.tag)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end

			if main_scene.ui.panels.heroHead then
				main_scene.ui.panels.heroHead:upt()
			end
		end
	elseif SM_HERO_LOGON == ident2 then
		sound.playSound(sound.hero_login)

		if getRecordSize("TNewHeroLook") == bufLen then
			local desc3 = net.record("TNewHeroLook", buf, bufLen)

			self.map:addMsg({
				roleid = msg.recog,
				ident = ident2,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series),
				feature = desc3:get("feature"),
				state = desc3:get("status")
			})
			g_data.hero:setRoleID(msg.recog)
			g_data.hero:setSex(desc3:get("feature"):get("sex"))

			if self.map.player and not self.map.player.hero then
				self.map.player.hero = self.map:findRole(msg.recog)
			end

			main_scene.ui:showPanel("heroHead")

			if def.autoHideHeroCall and main_scene.ui.console.widgets.btnHeroCall then
				main_scene.ui.console.widgets.btnHeroCall.hide = true

				main_scene.ui.console.widgets.btnHeroCall:setVisible(false)
			end

			if def.openHeroLoginEvent then
				def.role.call("@onHeroLogin")
			end
		end
	elseif SM_HERO_LOGOUT == ident2 then
		sound.playSound(sound.hero_logout)

		self.player.hero = nil

		g_data.hero:_data_reset()
		g_data.heroBag:_data_reset()
		g_data.heroEquip:_data_reset()
		main_scene.ui.console:call("btnHeroSkill", "hero_upt_union")

		if main_scene.ui.console.widgets.btnHeroCall then
			local value2 = main_scene.ui.panels[heroHead]

			if value2 then
				main_scene.ui.console.widgets.btnHeroCall:setPosition(value2:getPositionX() + value2:getw() / 2, value2:getPositionY() + value2:geth() / 2)
			end

			if def.autoHideHeroCall then
				main_scene.ui.console.widgets.btnHeroCall.hide = false

				main_scene.ui.console.widgets.btnHeroCall:setVisible(true)
			end
		end

		main_scene.ui:hidePanel("heroHead")
	elseif SM_HERO_LOGMAGIC == ident2 then
		self.map:addMsg({
			effect = {
				"heroBorn",
				{
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_HERO_QUITMAGIC == ident2 then
		self.map:addMsg({
			effect = {
				"heroHide",
				{
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_HERO_NAME == ident2 then
		local name4 = net.str(buf)
		local heroType = msg.param
		local heroRank = msg.tag

		g_data.hero:setName(name4, heroType, heroRank)
	elseif checkExist(ident2, SM_UNITEHIT0, SM_UNITEHIT1, SM_UNITEHIT2) then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident2,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series)
		})
	elseif SM_HERO_SPLITSHADOW == ident2 then
		self.map:addMsg({
			effect = {
				"heroSplistShadow",
				{
					roleid = msg.recog,
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_HERO_HELPOP_OK == ident2 then
		if msg.recog == 1 then
			if main_scene.ui.console.controller.heroLock then
				main_scene.ui.console.controller:toggleHeroLock()
				main_scene.ui.console:setWidgetSelect("btnHeroLock", main_scene.ui.console.controller.heroLock)
			end
		elseif msg.recog == 2 and main_scene.ui.console.controller.heroGuard then
			main_scene.ui.console.controller:toggleHeroGuard()
			main_scene.ui.console:setWidgetSelect("btnHeroGuard", main_scene.ui.console.controller.heroGuard)
		end
	elseif SM_SHOWHELPER == ident2 then
		if msg.recog == 1 then
			-- block empty
		elseif msg.recog == 2 then
			self.helper.runner.onKilledMonster(net.str(buf))
		end
	elseif SM_SLAVE_BORN == ident2 then
		if buf then
			g_data.player:addSlave(net.str(buf))
		end
	elseif SM_SLAVE_VANISH == ident2 then
		if buf then
			g_data.player:removeSlave(net.str(buf))
		end
	elseif SM_EXEC_FRESHMAN_TASK_CMD == ident2 then
		local errorMsg = {
			[-3] = "不能再次使用",
			[-2] = "无此任务",
			[-1] = "未知错误"
		}

		if errorMsg[msg.recog] then
			main_scene.ui:tip(errorMsg[msg.recog])
		end
	else
		return false
	end

	return true
end

function ground:addBLOODHIT(value, ident2)
	if main_scene.ground.map:canWalk(value.param, value.tag).block then
		main_scene.ui:tip("目标区域不可达")

		return
	end

	self.map:addMsg({
		roleid = value.recog,
		ident = ident2,
		x = value.param,
		y = value.tag,
		dir = Lobyte(value.series)
	})
end

function ground:smr()
	return def.smmap and def.smmap[g_data.map.mapTitle]
end

function ground:uptsmr()
	if not self.player then
		return
	end

	if self:smr() then
		if not self.player.smrState then
			for _, hero in pairs(main_scene.ground.map.heros) do
				hero.info:setName(hero.info.name.texts, true, true)
			end

			for _2, mon in pairs(main_scene.ground.map.mons) do
				mon.info:setName(mon.info.name.texts, true, true)
			end

			self.player.smrState = true

			net.send({
				CM_ATTACKMODE,
				tag = 0
			})
		end
	elseif self.player.smrState then
		self.player.info:setName(self.player.info.name.texts, true, true)

		self.player.smrState = false
	end
end

function ground:genExtend(value)
	cc2.ms({
		function()
			extendUI.create(self, value, "main_ext")
		end
	})
end

local btnCallbacks = require("mir2.scenes.main.console.btnCallbacks")
local callback = btnCallbacks.handle_panel

function btnCallbacks:handle_panel(configOwner)
	local value

	if type(configOwner) == "string" then
		value = configOwner
	else
		value = configOwner.config.btnid
	end

	if value == "link" then
		if def.chargeConfig then
			main_scene.ui:togglePanel("chargeNew")
		elseif def.role.mainsetting.closeczpanel then
			device.openURL(g_data.login.shopUrl)
		else
			main_scene.ui:togglePanel("charge")
		end

		return
	end

	callback(self, configOwner)
end

return ground
