local current = ...
local autoRat = class("autoRat", function ()
	local tbl = {}

	return tbl
end)
local magic = import("..common.magic")
local common = import("..common.common")
local getDir = import("..common.helper.util").getDir
local settingLogic = import("..common.settingLogic")
local mapDef = require("mir2.scenes.main.map.def")
autoRat.current = current

table.merge(autoRat, {})

autoRat.checkInterval = 0.1
autoRat.maxLoseAtkTime = 12
autoRat.maxTryCallPetTime = 10
autoRat.avoidInterval = 2
autoRat.amuletInterval = 3
autoRat.spellTime = 1
autoRat.maxActFail = 3
autoRat.closeAtkDis = 2
autoRat.rangeAtkDis = 9
autoRat.itemProperty = -10

function autoRat:ctor(console)
	self.console = console
	self.pathFinder = import("..common.autoFindPath", current).new()
	self.checkedAtkCnt = 0
	self.roarTimer = 0
	self.tryCallPetTimer = 0
	self.lastExpUpdateTime = -1
	self.cntActFail = 0
	self.settings = g_data.setting.autoRat
	self.tempData = {}

	setmetatable(self.tempData, {
		__mode = "k"
	})
end

function autoRat:setTempData(target, key, value)
	if target then
		self.tempData[target] = self.tempData[target] or {}
		self.tempData[target][key] = value

		return true
	end
end

function autoRat:tempMarkObject(target, key, time)
	if self:setTempData(target, key, true) then
		scheduler.performWithDelayGlobal(function ()
			self:setTempData(target, key, nil)
		end, time)
	end
end

function autoRat:getTempData(target, key)
	return self.tempData[target] and self.tempData[target][key]
end

function autoRat:isCanWalk(x, y)
	local map = main_scene.ground.map
	local block = map:canWalk(x, y).block

	if block then
		return false
	end

	local points = mapDef.doorPoint[map.mapid] or {}

	for k, v in pairs(points) do
		if v.x == x and v.y == y then
			return false
		end
	end

	return true
end

autoRat.lowProperty = {
	["蝙蝠"] = 4
}

local function pStack(...)
	p2("autoRat", ...)
end

function autoRat:updateModifyProperty()
	self.modifyProperty = {}
	local itemSettings = g_data.setting.item.filt or {}
	local items = def.items

	for k, v in pairs(items) do
		if type(v) == "table" and v.get then
			local itemName = v:get("name")

			if itemName == "金币1" then
				itemName = "金币"
			end

			if settingLogic.isRattingItem(itemName) then
				self.modifyProperty[itemName] = autoRat.itemProperty
			end
		end
	end

	setmetatable(self.modifyProperty, {
		__index = autoRat.lowProperty
	})
end

function autoRat:checkClose(target, closeTo)
	local player = main_scene.ground.player

	return self.pathFinder:checkClose(player.x, player.y, target.x, target.y, 400, false, closeTo)
end

local function getDis(a, b)
	return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

function autoRat:checkMonster(mon)
	assert(self.atkRangeDis, "self.atkRangeDis is nil")

	local player = main_scene.ground.player

	if getDis(player, mon) < (self:getTempData(mon, "tempAttackRange") or self.atkRangeDis) then
		return true
	end

	return self:checkClose(mon, self.atkRangeDis)
end

function autoRat:getNearestTarget(noItem)
	local targets = {}

	for k, v in pairs(main_scene.ground.map.mons) do
		local name = v.info:getName()

		if not v.die and not v:isPolice() and not v.isDummy and name and not string.find(name, "%(") and not self:getTempData(v, "tooStronger") and not self:getTempData(v, "cannotClose") then
			targets[#targets + 1] = v
		end
	end

	local player = main_scene.ground.player
	local modifyProperty = self.modifyProperty
	local items = main_scene.ground.map.items
	local itemSettings = g_data.setting.item.filt or {}
	local pickUpRatting = self.settings.pickUpRatting
	local pickGoodAttItem = g_data.setting.getGoodAttItemSetting().pickOnRatting

	if not noItem and pickUpRatting then
		local ability = g_data.player.ability
		local wei = ability:get("weight")
		local maxWei = ability:get("maxWeight") + 100000

		for _, item in pairs(items) do
			if item.owner == player.roleid and not self:getTempData(item, "cannotPick") and getDis(player, item) <= 10 then
				local itemName = item.itemName

				if wei < maxWei and g_data.bag:getFreeCount() > 0 or itemName == "金币" then
					if item.state > 0 and pickGoodAttItem then
						table.insert(targets, item)
					end

					if modifyProperty[itemName] then
						table.insert(targets, item)
					end
				end
			end
		end
	end

	table.sort(targets, function (a, b)
		local disA = getDis(player, a)

		if self:isMonster(a) then
			disA = disA + (modifyProperty[a.info and a.info:getName()] or 0)

			if def.role.stateHas(a.last.state, "stStone") then
				disA = disA + 3
			end
		elseif a.state > 0 and pickGoodAttItem then
			disA = disA + autoRat.itemProperty
		else
			disA = disA + (modifyProperty[a.itemName] or 0)
		end

		local disB = getDis(player, b)

		if self:isMonster(b) then
			disB = disB + (modifyProperty[b.info and b.info:getName()] or 0)

			if def.role.stateHas(b.last.state, "stStone") then
				disB = disB + 3
			end
		elseif b.state > 0 and pickGoodAttItem then
			disB = disB + autoRat.itemProperty
		else
			disB = disB + (modifyProperty[b.itemName] or 0)
		end

		return disA < disB
	end)

	for k, v in ipairs(targets) do
		if v.__cname == "mon" then
			if not self:getTempData(v, "attacked") and self.settings.ignoreCripple and v.info.hp and v.info.hp.max ~= v.info.hp.cur then
				local preHp = v.info.hp.cur
				local handler = nil
				handler = scheduler.scheduleGlobal(function ()
					if not tolua.isnull(v.node) then
						if preHp == v.info.hp.cur then
							v.info.hp.cur = v.info.hp.max
						else
							return
						end
					end

					scheduler.unscheduleGlobal(handler)
				end, 50)
			else
				local dis = getDis(player, v)
				local cls = self:checkMonster(v)

				if not cls then
					self:tempMarkObject(target, "cannotClose", 10)
				end

				if dis ~= 0 and (dis < self.atkRangeDis or cls) then
					return v
				end
			end
		elseif player.x == v.x and player.y == v.y or self:checkClose(v) then
			return v
		end
	end
end

function autoRat:isMonster(target)
	return target and target.__cname == "mon"
end

function autoRat:checkTarget()
	local target = self.target
	local nearestTarget = self:getNearestTarget(false, true)

	if target == nearestTarget then
		return target
	end

	if target and not self:isMonster(target) or tolua.isnull(target and target.node) or not self:checkMonster(target) or not not target.die then
		if target and target.die then
			self.tempData[target.roleid] = nil
		end

		target = nearestTarget

		if self:isMonster(target) and self.target ~= nearestTarget then
			self.preTargetHP = target.info.hp.max
			self.checkedAtkCnt = 0
		end
	elseif not nearestTarget then
		return target
	else
		local player = main_scene.ground.player

		if self.atkRangeDis <= getDis(player, target) then
			target = nearestTarget

			if self:isMonster(target) then
				self.preTargetHP = target.info.hp.max
				self.checkedAtkCnt = 0
			end
		end
	end

	if self.target ~= target then
		self.checkedAtkCnt = 0
	end

	self.target = target

	return target
end

function autoRat:isCloseAttack(skipAmulet)
	if g_data.player.job == 1 and self.settings.atkMagic.enable == nil and g_data.player:getMagic(1) then
		self.settings.atkMagic.enable = true
		self.settings.atkMagic.magicId = 1
	end

	if not skipAmulet and self.settings.atkMagic.enable and self.settings.atkMagic.magicId == 48 then
		if not common.checkAmulet(true) then
			if g_data.client:checkLastTime("autoRatCheckAmult", 1) then
				g_data.client:setLastTime("autoRatCheckAmult", true)
				common.addMsg("护身符用尽, 请检查护身符。", 255, 252, true)
			end

			return true
		end

		local data = g_data.player:getMagic(48)

		if g_data.player.ability:get("MP") < data:get("needMp") then
			if g_data.client:checkLastTime("autoRatUseMagic", 1) then
				g_data.client:setLastTime("autoRatUseMagic", true)
				main_scene.ui:tip("没有足够的魔法点数!")
			end

			return true
		end
	end

	return not self.settings.atkMagic.enable or not g_data.player:getMagic(self.settings.atkMagic.magicId) or self.settings.atkMagic.magicId == 13
end

function autoRat:setAttackRange(range)
	assert(range)

	self.atkRangeDis = range
end

function autoRat:enable()
	self.console.controller.autoFindPath.autoRatting = self.enableRat
	self._dt = 0
	self.checkedAtkCnt = 0
	self.roarTimer = 0
	self.tryCallPetTimer = 0
	self.avoidedDCnter = 0
	self.amuletAttack = 0
	self.lastExpUpdateTime = os.time()

	self:updateModifyProperty()
	main_scene.ui:tip("开启自动打怪.")

	self.enableRat = true

	main_scene.ground.player:showAutoRatHint()
end

function autoRat:clearAllAct()
	self.console:setWidgetSelect("btnAutoRat", false)

	self.controller = self.console.controller
	local findPath = self.controller.autoFindPath

	findPath:multiMapPathStop()

	if not tolua.isnull(main_scene.ground.player.node) then
		main_scene.ground.player:hideAutoRatHint()
	end

	self.console.controller.move.enable = false
	self.target = nil
	local lock = self.controller.lock

	lock:setAttackTarget(nil)
end

function autoRat:stop()
	if self.enableRat then
		self.enableRat = false

		main_scene.ui:tip("自动打怪已关闭.")
		self:clearAllAct()
	end
end

function autoRat:getPets(petid)
	if petid == 30 then
		name = string.format("神兽(%s)", common.getPlayerName())
	elseif petid == 17 then
		name = string.format("变异骷髅(%s)", common.getPlayerName())
	else
		return false
	end

	local pets = {}

	for k, v in pairs(main_scene.ground.map.mons) do
		if not v.die and v.info:getName() == name then
			v.isPet = true

			table.insert(pets, v)
		end
	end

	return pets
end

function autoRat:getRegionRoleCnt(pos, radio, type)
	local cnt = 0
	local map = main_scene.ground.map
	local roles = {}

	for x = -radio, radio do
		for y = -radio, radio do
			local role = map:findRoelWithPos(pos.x + x, pos.y + y, type)

			if role and not role.die then
				roles[#roles + 1] = role
				cnt = cnt + 1
			end
		end
	end

	return cnt, roles
end

function autoRat:checkRoar()
	local setting = self.settings.autoRoar

	if setting.enable and g_data.player:getMagic(43) then
		local player = main_scene.ground.player

		if self.roarTimer > 0 then
			self.roarTimer = self.roarTimer - 1

			return
		end

		local cnt = self:getRegionRoleCnt(player, 2, "mon")

		if setting.cnt <= cnt then
			self.roarTimer = setting.space / autoRat.checkInterval

			if self:useMagic(nil, 43) then
				return true
			end
		end
	end
end

function autoRat:checkPets()
	local name = nil

	if not common.checkAmulet(true) then
		if g_data.client:checkLastTime("autoRatCheckPets", 1) then
			g_data.client:setLastTime("autoRatCheckPets", true)
			common.addMsg("护身符用尽, 请检查护身符。", 255, 252, true)
		end

		return
	end

	local petid = nil

	if self.settings.autoPet.enable then
		petid = tonumber(self.settings.autoPet.magicId)
	else
		return false
	end

	if not g_data.player:getMagic(petid) then
		return false
	end

	if not g_data.player:hasSlave("神兽") and not g_data.player:hasSlave("变异骷髅") then
		self.tryCallPetTimer = self.tryCallPetTimer - 1

		if self.tryCallPetTimer > autoRat.maxTryCallPetTime / 2 then
			self:useMagic(nil, petid)

			return true
		elseif self.tryCallPetTimer < -autoRat.maxTryCallPetTime then
			self.tryCallPetTimer = autoRat.maxTryCallPetTime
		end
	end
end

function autoRat:checkCureSelf()
	local setting = self.settings.autoCure

	if setting.enable then
		if not g_data.player:getMagic(setting.magicId) then
			return false
		end

		local player = main_scene.ground.player

		if not player.info.hp.cur then
			return
		end

		local curHpPercent = player.info.hp.cur / player.info.hp.max

		if curHpPercent * 100 <= setting.percent then
			return self:useMagic(player, setting.magicId)
		end
	end

	return false
end

function autoRat:checkCurePet()
	local setting = self.settings.autoCurePet

	if setting.enable then
		if not g_data.player:getMagic(setting.magicId) then
			return false
		end

		for _, petid in ipairs({
			30,
			17
		}) do
			local pets = self:getPets(petid)

			for k, v in ipairs(pets) do
				if v.info and v.info.hp.cur and self:getTempData(v, "preHP") ~= v.info.hp.cur then
					local curHpPercent = v.info.hp.cur / v.info.hp.max

					if curHpPercent * 100 <= setting.percent then
						self:setTempData(v, "preHP", v.info.hp.cur)

						return self:useMagic(v, setting.magicId)
					end
				end
			end
		end
	end

	return false
end

function autoRat:checkPoison()
	local player = main_scene.ground.player
	local tar = self.target

	if self.settings.autoPoison and self:isMonster(tar) and not tar.die and getDis(player, tar) <= autoRat.rangeAtkDis and g_data.player:getMagic(6) then
		local redPoison, greenPoison, equiped = self.console.controller:getPoisonItems(tar)

		if redPoison and not def.role.stateHas(tar.state, "stPoisonRed") or greenPoison and not def.role.stateHas(tar.state, "stPoisonGreen") then
			local ret = self:useMagic(tar, 6)

			return ret
		end
	end
end

function autoRat:usePet(petid)
	self.petid = petid
end

function autoRat:setMagic(magicid)
	local data = g_data.player:getMagic(magicid)

	if data then
		local config = def.magic.getMagicConfigByUid(magicid)

		self.console.skills:select(tostring(magicID))
		self.console:call("lock", "useSkill", data, config)
	end
end

local explorer = class("explorer")

function explorer:ctor(map, findPath, autoRater)
	self.map = map
	self.findPath = findPath
	self.autoRater = autoRater
	self.expDis = math.floor(math.pow(map.w + 5, 0.6))
	self.maxExplorePoints = map.w * map.h / math.pow(self.expDis * 2, 2) * 0.7
	self.points = {}
	self.complete = false
end

function explorer:_tryTarget(curPos, pos)
	local findPath = self.findPath

	if self.autoRater:isCanWalk(pos.x, pos.y) then
		findPath:singleMapPathStop()
		findPath:searchForRun(curPos.x, curPos.y, pos.x, pos.y, nil, false, 1)

		if findPath.points and #findPath.points > 0 then
			self.preTargetPosition = pos

			return true
		end
	end
end

function explorer:tryExploredPoints(curPos)
	local findPath = self.findPath

	for tryCnt = 1, 10 do
		local index = math.random(#self.points)
		local pos = self.points[index]

		if self:_tryTarget(curPos, pos) then
			return true
		end
	end
end

function explorer:getNext(curPos)
	local findPath = self.findPath
	local pos = nil

	if not self.complete and self.maxExplorePoints <= #self.points then
		self:_generatePatrolPath()
	end

	if self.preTargetPosition and getDis(self.preTargetPosition, curPos) > self.expDis / 2 then
		pos = self.preTargetPosition
	elseif self.complete then
		if self.preTargetPosition then
			pos = self.preTargetPosition.next

			if not pos then
				pos = self.points[1]
			end
		elseif self:tryExploredPoints(curPos) then
			return
		end
	end

	if not pos or not self:_tryTarget(curPos, pos) then
		local startPos = curPos
		local dis = self.expDis
		local dbdis = dis * 2

		for tryCnt = 1, 15 do
			local x = math.random(-dbdis, dbdis)
			local y = math.random(-dbdis, dbdis)
			local pos = cc.p(startPos.x + x, startPos.y + y)
			local ok = true

			for k, v in ipairs(self.points) do
				if getDis(v, pos) < dis then
					local index = math.random(#self.points)
					startPos = self.points[index]
					ok = false

					break
				end
			end

			if ok and self:_tryTarget(curPos, pos) then
				self:addNewPos(pos)

				return
			end
		end
	else
		return
	end

	self:tryExploredPoints(curPos)
end

function explorer:_generatePatrolPath()
	if self.complete then
		return
	end

	local findPath = self.findPath

	local function generater()
		local ignore = {}
		local cur = nil

		for index, _ in ipairs(self.points) do
			cur = cur or _
			ignore[cur] = true
			local min = 99999999
			local minPoint = nil

			for _, pos in ipairs(self.points) do
				local dis = getDis(cur, pos)

				if dis and not ignore[pos] and dis < min then
					min = dis
					minPoint = pos
				end
			end

			if minPoint then
				cur.next = minPoint
				minPoint.pre = cur
				cur = minPoint
			end
		end

		self.complete = true
		self.co_patrolPathGenerater = nil
	end

	generater()
end

function explorer:addNewPos(pos)
	table.insert(self.points, pos)
end

function autoRat:explore()
	local findPath = self.controller.autoFindPath
	local lock = self.controller.lock

	lock:setAttackTarget(nil)

	if findPath.points and #findPath.points > 0 then
		return
	end

	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if map.mapid ~= self.curmapid then
		self.curmapid = map.mapid
		self.explorer = explorer.new(map, findPath, self)
	end

	self.explorer:getNext(player)
end

function autoRat:checkAttackRange()
	local dis = nil
	local player = main_scene.ground.player
	local atkMagic = self.settings.atkMagic
	dis = self:isCloseAttack() and 2 or self.atkRangeDis

	if atkMagic and atkMagic.enable and g_data.player:getMagic(atkMagic.magicId) then
		if checkExist(atkMagic.magicId, 1, 5, 13) then
			local map = main_scene.ground.map

			if not map:checkFlyTo(player, self.target) then
				self:setTempData(self.target, "tempAttackRange", 2)

				dis = 2
			else
				self:setTempData(self.target, "tempAttackRange", dis)
			end
		end

		if dis > 3 and def.role.stateHas(self.target.last.state, "stStone") then
			dis = 3
		end
	end

	self:setAttackRange(dis)
end

function autoRat:closeToTarget()
	local dis = nil
	local tar = self.target
	local player = main_scene.ground.player

	if self:isMonster(self.target) then
		self:checkAttackRange()

		dis = self.atkRangeDis
	end

	local findPath = self.controller.autoFindPath

	findPath:singleMapPathStop()

	if dis then
		if math.abs(player.x - tar.x) < dis and math.abs(player.y - tar.y) < dis then
			return true
		end
	elseif player.x == tar.x and player.y == tar.y then
		return true
	end

	local lock = self.controller.lock

	lock:setAttackTarget(nil)
	findPath:searchForRun(player.x, player.y, tar.x, tar.y, nil, false, dis)

	return false
end

function autoRat:useMagic(target, magicId)
	local lock = self.controller.lock

	if target then
		lock:setSkillTarget(target)
	else
		target = main_scene.ground.player
	end

	local data = g_data.player:getMagic(magicId)

	if not data then
		if g_data.client:checkLastTime("autoRatUseMagic", 1) then
			g_data.client:setLastTime("autoRatUseMagic", true)
			main_scene.ui:tip("技能不可用!")
		end

		return false
	end

	if g_data.player.ability:get("MP") < data:get("needMp") then
		if g_data.client:checkLastTime("autoRatUseMagic", 1) then
			g_data.client:setLastTime("autoRatUseMagic", true)
			main_scene.ui:tip("没有足够的魔法点数!")
		end

		return false
	end

	self:setMagic(magicId)
	self.controller:useMagic(target.x, target.y, nil, data)

	local player = main_scene.ground.player

	return true
end

function autoRat:attackUseMagic()
	local tar = self.target

	if tar.die then
		return false
	end

	if g_data.player.job == 1 then
		local areaMagic = self.settings.areaMagic

		if areaMagic.enable and areaMagic.magicId and g_data.player:getMagic(areaMagic.magicId) then
			local cnt, roles = self:getRegionRoleCnt(tar, 1, "mon")

			if areaMagic.cnt <= cnt then
				for k, v in pairs(roles) do
					if not v.info.hp.cur or v.info.hp.cur == v.info.hp.max then
						self:setTempData(v, "attacked", true)
					end
				end

				self:useMagic(tar, areaMagic.magicId)

				return true
			end
		end
	end

	local atkMagic = self.settings.atkMagic

	if atkMagic.enable and atkMagic.magicId and g_data.player:getMagic(atkMagic.magicId) then
		local sklDis = 10

		self:useMagic(tar, atkMagic.magicId)

		return true
	end
end

function autoRat:attack()
	local tar = self.target

	if tar.die then
		return false
	end

	local lock = self.controller.lock

	lock:setAttackTarget(tar)

	local player = main_scene.ground.player

	if self.settings.atkMagic.enable and self.settings.atkMagic.magicId == 13 and self.amuletAttack <= 0 then
		if player:canNextSpell(13) then
			self:useMagic(tar, 13)
		end

		if player:isLocked() then
			self.amuletAttack = autoRat.amuletInterval

			return true
		end
	end

	if not player:canNextHit() then
		return true
	end

	self.controller:attackRole(main_scene.ground.map, player, tar)

	self.amuletAttack = self.amuletAttack - 1

	return true
end

function autoRat:pickUpItem()
	local tar = self.target

	if self.picking then
		return true
	end

	local player = main_scene.ground.player
	local map = main_scene.ground.map

	if not self:isMonster(tar) and player.x == tar.x and player.y == tar.y then
		self.picking = true

		scheduler.performWithDelayGlobal(function ()
			self.picking = false

			if map.items and map.items[tar.itemid] then
				self:setTempData(tar, "cannotPick", true)

				self.target = nil

				scheduler.performWithDelayGlobal(function ()
					if map.items ~= nil and not map.items[tar.itemid] then
						self:setTempData(tar, "cannotPick", nil)
					end
				end, 15)
			end
		end, 2)

		return true
	end
end

function autoRat:checkHit()
	local target = self.target

	if target.info.hp.cur == self.preTargetHP then
		local player = main_scene.ground.player

		if player:isLocked() then
			self.checkedAtkCnt = self.checkedAtkCnt + 1
		end

		if autoRat.maxLoseAtkTime < self.checkedAtkCnt then
			self:tempMarkObject(target, "tooStronger", 30)

			self.target = nil
		end
	else
		self.checkedAtkCnt = 0
		self.preTargetHP = target.info.hp.cur
	end
end

function autoRat:useItem(itemName)
	local item = g_data.bag:getItemWithName(itemName)

	if item then
		g_data.bag:use("eat", item:get("makeIndex"), {
			quick = true
		})
		sound.play("item", item)
		net.send({
			CM_EAT,
			recog = item:get("makeIndex")
		}, {
			item.getVar("name")
		})
		g_data.bag:delItem(item:get("makeIndex"))

		if g_data.bag:delItem(makeIndex) and self.panels.bag then
			self.panels.bag:delItem(makeIndex)
		end
	end
end

function autoRat:checkAvoid()
	if not self:isMonster(self.target) then
		return
	end

	if self.settings.atkMagic.enable and self.settings.atkMagic.magicId ~= 13 then
		if self.avoidedDCnter > 0 then
			self.avoidedDCnter = self.avoidedDCnter - 1

			return
		end

		local player = main_scene.ground.player
		local nearObjsPos = {}
		local nearObjsDir = {}
		local map = main_scene.ground.map
		minDis = 4

		for k, v in pairs(map.mons) do
			local name = v.info:getName()
			local disX = math.abs(player.x - v.x)
			local disY = math.abs(player.y - v.y)
			local dis = math.max(disX, disY) + (self.modifyProperty[v.info:getName()] or 0)

			if not v.die and not v:isPolice() and not v.isDummy and (not name or not string.find(name, "%(")) and dis < 4 then
				if dis < minDis then
					minDis = dis
				end

				local dir = def.role.getMoveDir(player.x, player.y, v.x, v.y)
				nearObjsDir[dir] = (nearObjsDir[dir] or 0) + 4 / dis
			end
		end

		if minDis > 2 then
			return
		end

		local wDirs = {}

		for k = 0, 7 do
			local cnt = nearObjsDir[k] or 0.01
			wDirs[k] = 1 / cnt
		end

		local goodDirs = {}

		for k = 0, 7 do
			goodDirs[k] = (wDirs[(k + 7) % 8] or 0) / 3 + (wDirs[(k + 1) % 8] or 0) / 3 + wDirs[k]
		end

		local max = 0

		for k, v in pairs(goodDirs) do
			local config = def.role.dir["_" .. k]

			if not self:isCanWalk(player.x + config[1], player.y + config[2]) then
				v = 0
			elseif not self:isCanWalk(player.x + config[1] * 2, player.y + config[2] * 2) then
				v = v * 0.4
			elseif not self:isCanWalk(player.x + config[1] * 3, player.y + config[2] * 3) then
				v = v * 0.6
			elseif not self:isCanWalk(player.x + config[1] * 4, player.y + config[2] * 4) then
				v = v * 0.8
			end

			if max < v then
				max = v
				dir = k
			elseif max == v and math.random() < 0.5 then
				dir = k
			end
		end

		local config = def.role.dir["_" .. dir]

		if not self:isCanWalk(player.x + config[1], player.y + config[2]) then
			self.controller.move.enable = false

			return false
		end

		step = 2

		if not self:isCanWalk(player.x + config[1] * 2, player.y + config[2] * 2) then
			step = 1
		end

		self.controller.move.enable = "dir"
		self.controller.move.dir = dir
		self.controller.move.step = step
		self.avoidedDCnter = autoRat.avoidInterval

		return true
	end
end

function autoRat:checkAutoSpaceMove()
	local setting = self.settings.autoSpaceMove

	if setting.enable then
		if self.lastExpUpdateTime <= 0 then
			self.lastExpUpdateTime = os.time()

			return
		end

		local curtime = os.time()

		if curtime - self.lastExpUpdateTime < setting.space * 60 then
			return false
		end

		self.lastExpUpdateTime = os.time()

		self:useItem(setting.use)

		return true
	end
end

function autoRat:onExpUpdate()
	self.lastExpUpdateTime = os.time()
end

function autoRat:onActFail(x, y, dir)
	self.cntActFail = self.cntActFail + 1

	if autoRat.maxActFail < self.cntActFail then
		local player = main_scene.ground.player
		local cnt, mon = self:getRegionRoleCnt(player, 1, "mon")

		for k, v in pairs(mon) do
			self:tempMarkObject(v, "tooStronger", 6)
		end

		self:tempMarkObject(self.target, "tooStronger", 6)

		self.target = nil
		self.cntActFail = 0
	end
end

function autoRat:onActGood(x, y, dir)
	self.cntActFail = 0
end

function autoRat:updateAttackRange(skipAmulet)
	if self:isCloseAttack(skipAmulet) then
		self:setAttackRange(autoRat.closeAtkDis)
	else
		self:setAttackRange(autoRat.rangeAtkDis)
	end
end

function autoRat:executeTest(dt)
	if not self.enableRat then
		return
	end

	local player = main_scene.ground.player

	if DEBUG > 0 and not tolua.isnull(main_scene.ui.panels.bigmap) and self.explorer and self.explorer.points then
		main_scene.ui.panels.bigmap:loadFlagPoints("explore", self.explorer.points, self.explorer.complete and cc.c4b(0, 255, 255, 255) or cc.c4b(0, 255, 0, 255))
	end

	if def.role.stateHas(player.state, "stPoisonStone") then
		return
	end

	if tolua.isnull(main_scene) then
		self:enable()

		return
	end

	self.controller = self.console.controller
	self.controller.move.enable = false

	self:updateAttackRange(false)

	if g_data.player.job ~= 0 or not self:checkRoar() then
		if g_data.player.job == 2 then
			if not self:checkPets() and not self:checkCureSelf() and not self:checkCurePet() then
				if self:checkPoison() then
					-- Nothing
				end
			end
		elseif self:checkTarget() then
			self:updateAttackRange(true)

			if self:closeToTarget() then
				if self:isMonster(self.target) then
					self:setTempData(self.target, "attacked", true)

					if self:isCloseAttack() then
						self:attack()
					else
						self:attackUseMagic()
					end

					self:checkHit()
				elseif self:pickUpItem() then
					-- Nothing
				end
			end
		else
			self:explore()
		end
	end

	self:checkAutoSpaceMove()

	if player:isLocked() then
		return true
	elseif not self:isCloseAttack() then
		self:checkAvoid()
	end
end

return autoRat
