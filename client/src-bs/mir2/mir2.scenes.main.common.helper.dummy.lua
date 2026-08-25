local magic = import("..magic")
local mapDef = require("mir2.scenes.main.map.def")
local autoFindPath = import("..autoFindPath")
local util = import(".util")
local common = import("..common")
dummy = class("dummy", function ()
	local obj = {}

	setmetatable(obj, {
		__index = function (_, k)
			return obj.role[k]
		end
	})

	return obj
end)
util.dummy = dummy

table.merge(dummy, {})

dummy.roleid = 1
dummy.say_default_bgColor = cc.c4b(150, 84, 13, 100)
dummy.say_default_fontSize = 17
dummy.say_default_strWidth = 300
dummy.say_default_duration = 4

function dummy.setEvtCallback(func)
	rawset(dummy, "evtCallback", func)

	if main_scene and not main_scene.ground.helper:isHiding() then
		main_scene.ground.helper.obj.evtCallback_ = func
	end
end

function dummy.getEvtCallback()
	return rawget(dummy, "evtCallback")
end

function dummy.setRunner(runner)
	rawset(dummy, "runner", runner)
end

function dummy.getMap()
	return dummy.runner.getMap()
end

dummy.WALK_INTERVAL = 0.7
dummy.FOLLOW_DISTANCE = 4
dummy.FOLLOW_DISTANCE_LIMIT = 20
dummy.GUIDE_DISTANCE_LIMIT = 7
dummy.GUIDE_DEFAULT_TIP = "跟我来"
dummy.acts = {
	WALK = SM_WALK,
	RUN = SM_RUN,
	TURN = SM_TURN,
	BACKSTEP = SM_BACKSTEP,
	DEATH = SM_DEATH,
	NOWDEATH = SM_NOWDEATH,
	HIT = SM_HIT,
	HEAVYHIT = SM_HEAVYHIT,
	BIGHIT = SM_BIGHIT,
	POWERHIT = SM_POWERHIT,
	LONGHIT = SM_LONGHIT,
	WIDEHIT = SM_WIDEHIT,
	FIREHIT = SM_FIREHIT,
	FOURFIREHIT = SM_4FIREHIT,
	HERO_LONGHIT = SM_HERO_LONGHIT,
	HERO_LASTHIT = SM_HERO_LASTHIT,
	SWORD_HIT = SM_SWORD_HIT,
	RUSH = SM_RUSH,
	RUSHKUNG = SM_RUSHKUNG,
	STRUCK = SM_STRUCK,
	SKELETON = SM_SKELETON,
	DIGUP = SM_DIGUP,
	DIGDOWN = SM_DIGDOWN,
	ALIVE = SM_ALIVE,
	SPACEMOVE_SHOW = SM_SPACEMOVE_SHOW,
	FLYAXE = SM_FLYAXE,
	BUTCH = SM_BUTCH,
	SPELL = SM_SPELL,
	HERO_LOGON = SM_HERO_LOGON,
	UNITEHIT0 = SM_UNITEHIT0,
	UNITEHIT1 = SM_UNITEHIT1,
	UNITEHIT2 = SM_UNITEHIT2,
	FEATURECHANGED = SM_FEATURECHANGED
}
dummy.state = {
	csNoDieState = "csNoDieState",
	csAssCritHit = "csAssCritHit",
	csAttPoisonMove = "csAttPoisonMove",
	csDingShen = "csDingShen",
	StBlueDiamond = "StBlueDiamond",
	stStone = "stStone",
	csRelive = "csRelive",
	stPoisonYellow = "stPoisonYellow",
	csTmpSSk = "csTmpSSk",
	csTmpStrength = "csTmpStrength",
	stBloodWarrior = "stBloodWarrior",
	stNil_UsedByClient = "stNil_UsedByClient",
	csVioletPoision = "csVioletPoision",
	StSskTaoist = "StSskTaoist",
	stWEBS = "stWEBS",
	csAttYLB = "csAttYLB",
	csTmpHQ = "csTmpHQ",
	stPoisonRed = "stPoisonRed",
	csDominateBuf = "csDominateBuf",
	csSXSL = "csSXSL",
	csNB = "csNB",
	stReleaseStone = "stReleaseStone",
	stMACShield = "stMACShield",
	stHeroLongHit = "stHeroLongHit",
	csTmpMAC = "csTmpMAC",
	csNoDamage = "csNoDamage",
	csWJD = "csWJD",
	csWJZQ = "csWJZQ",
	csRealHide = "csRealHide",
	stACShield = "stACShield",
	stZeroShield = "stZeroShield",
	csNil_48 = "csNil_48",
	csTmpSC = "csTmpSC",
	csHMSF = "csHMSF",
	csTmpNearHit = "csTmpNearHit",
	csTmpMaxHP = "csTmpMaxHP",
	csAssLK = "csAssLK",
	csTmpMC = "csTmpMC",
	csHorseRider = "csHorseRider",
	csZaiMaShang = "csZaiMaShang",
	csAssXJRS = "csAssXJRS",
	csNil_47 = "csNil_47",
	stPoisonStone = "stPoisonStone",
	stHackQuest = "stHackQuest",
	stDenyMagic = "stDenyMagic",
	stOpenHealth = "stOpenHealth",
	csTmpDC = "csTmpDC",
	stFreeze = "stFreeze",
	stPoisonGreen = "stPoisonGreen",
	stJFBF = "stJFBF",
	stDragonState = "stDragonState",
	csDurativeVioletDmg = "csDurativeVioletDmg",
	StDzxyFull = "StDzxyFull",
	csTmpUnion = "csTmpUnion",
	csRevenge = "csRevenge",
	csTmpDCSpeed = "csTmpDCSpeed",
	StSskWizard = "StSskWizard",
	csDecTmpDefence = "csDecTmpDefence",
	csBurn = "csBurn",
	csZLHT = "csZLHT",
	csTmpAM = "csTmpAM",
	csJinghun = "csJinghun",
	stPoisonFuchsia = "stPoisonFuchsia",
	StYellowDiamond = "StYellowDiamond",
	stManaProtected = "stManaProtected",
	csPoisonMove = "csPoisonMove",
	stHidden = "stHidden",
	csTmpMaxMP = "csTmpMaxMP",
	csTmpQR = "csTmpQR",
	csDurativeSdsDmg = "csDurativeSdsDmg",
	csBleeding = "csBleeding",
	stMagicShieldEx = "stMagicShieldEx",
	stAlwaysShowName = "stAlwaysShowName",
	csTmpAC = "csTmpAC",
	csAttHLKW = "csAttHLKW",
	stMagicShield = "stMagicShield",
	csAssRXPK = "csAssRXPK",
	csTmpCC = "csTmpCC",
	csLieHun = "csLieHun",
	stAutoLFTrain = "stAutoLFTrain",
	csDominaterPet = "csDominaterPet",
	stPoisonBlue = "stPoisonBlue"
}

function dummy:ctor(name, race, dress, weapon, sex, hair, offset, realPos, time)
	if type(name) == "table" then
		local name = params.name
		local race = params.race
		local dress = params.dress
		local weapon = params.weapon
		local sex = params.sex
		local hair = params.hair
		local offset = params.offset
		local realPos = params.pos
		local time = params.time or 5
	end

	local name = name or ""
	local roleid = name .. dummy.roleid
	dummy.roleid = dummy.roleid + 1
	self.evtCallback_ = dummy.evtCallback

	if race == nil or race == "hero" then
		race = 0
		self.dressid = dress or 0
		self.weaponid = weapon or 0
		local items = def.items
		local dressData = items[dress]

		if dressData then
			dress = dressData.shape
		end

		local weaponData = items[weapon]

		if weaponData then
			weapon = weaponData.shape
		end
	end

	local feature = getRecord("TFeature")

	feature:set("race", race or 0)
	feature:set("sex", sex or 0)
	feature:set("dress", dress or 0)
	feature:set("weapon", weapon or 0)
	feature:set("hair", hair or 0)

	self.feature = feature
	local map = dummy.getMap()
	local model = self:getRoleModel()
	model.feature = feature
	model.roleid = roleid
	self.roleid = roleid

	if not realPos then
		if offset.off2 then
			model.y = offset.y
			model.x = offset.x
		else
			local offsetTo = map.player
			model.x = offsetTo.x + (offset and (offset.x or 1))
			model.y = offsetTo.y + (offset and (offset.y or 0))
		end
	else
		model.x = realPos.x
		model.y = realPos.y
	end

	model.name = name
	self.role = map:newRole(model)
	self.role.isDummy = true

	self.role.info:setName(name)

	self.role.name = name

	if time ~= nil and time > 0 then
		self.role.node:performWithDelay(handler(self, self.removeSelf), time)
	end

	self.pathFinder = autoFindPath.new()

	getmetatable(self).__newindex = function (t, k, v)
		if k == "walkFunc" then
			rawset(self, k, v)

			return
		elseif k == "name" then
			self.role.info:setName(tostring(v))
		elseif k == "clickCallback" then
			-- Nothing
		elseif k == "dir" then
			assert(v)

			if not self.role.node:isRunning() then
				self.role.last.dir = v
			end

			self.role:processMsg(SM_TURN, self.x, self.y, v, feature, state)
		end

		self.role[k] = v
	end
end

function dummy:setName(name)
	self.role.info:setName(name)
end

function dummy:actDelay(delay)
	return cca.delay(delay)
end

function dummy:actAttack(skillIndex, offset, dir)
	return cca.callFunc(function ()
		self:attack(skillIndex, offset, dir)
	end)
end

function dummy:actPlayAct(actid, offset, dir, feature, state)
	return cca.callFunc(function ()
		self:playAct(actid, offset, dir, feature, state)
	end)
end

function dummy:actMagic(magicID, target, offset, dir)
	return cca.callFunc(function ()
		self:magic(magicID, target, offset, dir)
	end)
end

function dummy:actRemoveSelf()
	return cca.callFunc(function ()
		self:removeSelf()
	end)
end

function dummy:actAssign(key, value)
	return cca.callFunc(function ()
		self[key] = value
	end)
end

function dummy:getRoleModel()
	local dir = def.role.dir.bottom
	local allBodyState = getRecord("TAllBodyState")

	return {
		dir = dir,
		state = allBodyState
	}
end

function dummy:removeSelf()
	local map = dummy.getMap()

	if not tolua.isnull(map) and not tolua.isnull(self.role.node) then
		map:removeRole(self.role.roleid)
	end
end

function dummy:addState(stateName)
	if tolua.isnull(self.role.node) then
		return
	end

	local last = self.role.last

	def.role.addState(last.state, stateName)
	self.role:processMsg(SM_CHARSTATUSCHANGED, nil, nil, nil, last.state)
end

function dummy:removeState(stateName)
	if tolua.isnull(self.role.node) then
		return
	end

	local last = self.role.last

	def.role.removeState(last.state, stateName)
	self.role:processMsg(SM_CHARSTATUSCHANGED, nil, nil, nil, last.state)
end

function dummy:say(text, bgColor, fontSize, strWidth, dur)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(text) == "table" and not bgColor then
		local params = text
		text = params.text
		bgColor = params.bgColor
		fontSize = params.fontSize
		strWidth = params.strWidth
	end

	bgColor = bgColor or self.say_default_bgColor
	local adapt = nil

	if type(bgColor) == "function" then
		adapt = bgColor
		bgColor = nil
	end

	local msg = {
		color = 0,
		channel = "dummy",
		bgColor = 255,
		data = {
			{
				str = text,
				bgColor = bgColor
			}
		},
		ident = SM_HEAR,
		target = self.name,
		user = self.name,
		adapt = adapt,
		duration = dur or self.say_default_duration,
		fontSize = fontSize or self.say_default_fontSize,
		strWidth = strWidth or self.say_default_strWidth
	}
	local info = self.role.info

	info:say(msg)
	common.addMsg(string.format("%s:%s", self.name, text), 255, bgColor, true, self.name)
end

function dummy.sayDialogAdapt(node, digImg, offset)
	local sz = node:getContentSize()
	sz.width = sz.width + 20
	sz.height = sz.height + 35
	local w = sz.width

	if sz.height < 65 then
		sz.height = 65
	end

	if sz.width < 316 then
		sz.width = 316
	end

	local dig = display.newScale9Sprite(res.getframe2(digImg), 0, 0, sz):pos(offset.x, offset.y):anchor(0, 0)

	node:add2(dig):pos(sz.width / 2, 25):anchor(0.5, 0)
	dig:setCapInsets(cc.rect(20, 20, 10, 50))
	dig:setScale(1 / (g_data.setting.display.mapScale or 1.5))

	local p = display.newNode()

	p:setContentSize(sz.width, sz.height)
	dig:add2(p)

	return p
end

function dummy:sayDL(text, fontSize, strWidth, dur)
	self:say(text, function (node)
		return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box.png", cc.p(20, -20))
	end, fontSize, strWidth, dur)
end

function dummy:sayDR(text, fontSize, strWidth, dur)
	self:say(text, function (node)
		return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box02.png", cc.p(75, -20))
	end, fontSize, strWidth, dur)
end

function dummy.createSayDL(texts, strWidth, fontSize)
	if type(texts) == "string" then
		texts = {
			texts
		}
	end

	local msg = {
		data = texts,
		strWidth = strWidth or dummy.say_default_strWidth,
		fontSize = fontSize or dummy.say_default_fontSize
	}
	local node = common.createChatLabel(msg)

	return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box.png", cc.p(40, 0))
end

function dummy.createSayDR(texts, strWidth, fontSize)
	if type(texts) == "string" then
		texts = {
			texts
		}
	end

	local msg = {
		data = texts,
		strWidth = strWidth or dummy.say_default_strWidth,
		fontSize = fontSize or dummy.say_default_fontSize
	}
	local node = common.createChatLabel(msg)

	return dummy.sayDialogAdapt(node, "pic/helperScript/dialog_box02.png", cc.p(75, 0))
end

function dummy:moveTo_(pos)
	local myObj = self.role

	if myObj.x == pos.x and myObj.y == pos.y then
		-- Nothing
	else
		local dir = util.getDir(myObj, pos)

		if cc.pGetDistance(cc.p(myObj.x, myObj.y), pos) < 2 then
			myObj:processMsg(SM_WALK, pos.x, pos.y, dir)
		else
			myObj:processMsg(SM_RUN, pos.x, pos.y, dir)
		end
	end
end

function dummy:walkTo(x, y, mapid, tip, guideDis, maxDis, waitEvt, arriveEvt, faildEvt, unshowRoute)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(x) == "table" then
		local params = x
		x = params.x
		y = params.y
		mapid = params.mapid
		waitEvt = params.waitEvt
		arriveEvt = params.arriveEvt
		maxDis = params.maxDis
		unshowRoute = params.unshowRoute
	end

	if type(mapid) == "number" then
		mapid = "" .. mapid
	end

	if not unshowRoute then
		local size = def.role.size
		self.guideTipSpr = res.get2("pic/common/guideTip.png"):add2(self.role):pos(size.w / 2, size.h + 25)

		self.guideTipSpr:setGlobalZOrder(self.role.node:getGlobalZOrder() + 1)
		self.guideTipSpr:runForever(transition.sequence({
			cc.MoveBy:create(1, cc.p(0, 15)),
			cc.MoveBy:create(1, cc.p(0, -15))
		}))
	end

	self.walkFunc = {
		function (...)
			self:walkTo_(x, y, mapid, tip, guideDis, maxDis, waitEvt, arriveEvt, faildEvt)

			if not unshowRoute then
				local myObj = self.role
				local map = dummy.getMap()
				local player = main_scene.ground.player

				self.pathFinder:singleMapPathStop()

				local routePoints = self.pathFinder:search(player.x, player.y, myObj.x, myObj.y, nil, true, true)
				local effect = res.getani2("pic/effect/followHelper/%d.png", 1, 6, 0.1)

				for k, off in ipairs(routePoints) do
					if off then
						local x, y = map:getMapPos(off.x, off.y)
						local spr = display.newSprite():addto(map.layers.mid, y + mapDef.tile.h):pos(x + mapDef.tile.w / 2, y + mapDef.tile.h / 2):runs({
							cc.DelayTime:create(0.1 * k),
							cc.Animate:create(effect),
							cc.RemoveSelf:create()
						})
					else
						break
					end
				end
			end
		end,
		{}
	}
end

function dummy:walkTo_(x, y, mapid, tip, guideDis, maxDis, waitEvt, arriveEvt, faildEvt)
	if tolua.isnull(self.role.node) then
		self.walkFunc = nil

		return
	end

	local player = main_scene.ground.player
	local myObj = self.role
	local map = dummy.getMap()

	if mapid and map.mapid ~= mapid then
		if not tolua.isnull(self.guideTipSpr) then
			self.guideTipSpr:removeFromParent()
		end

		if type(faildEvt) == "function" then
			faildEvt("faild")
		elseif self.evtCallback_ and faildEvt then
			self.evtCallback_(faildEvt, self)
		end

		self.walkFunc = {
			self.followPlayer,
			{
				self
			}
		}

		return
	end

	local dis = player:getDis(myObj)

	if (guideDis or dummy.GUIDE_DISTANCE_LIMIT) < dis then
		if (maxDis or dummy.FOLLOW_DISTANCE_LIMIT) < dis then
			myObj:processMsg(SM_SPACEMOVE_SHOW, player.x, player.y, 0)

			self.points = nil

			return
		else
			if type(waitEvt) == "function" then
				waitEvt("wait")
			elseif self.evtCallback_ and waitEvt then
				self.evtCallback_(waitEvt, self)
			end

			return
		end
	end

	if self.x == x and self.y == y then
		self.walkFunc = nil

		if not tolua.isnull(self.guideTipSpr) then
			self.guideTipSpr:removeFromParent()
		end

		if type(arriveEvt) == "function" then
			arriveEvt("arrive")
		elseif self.evtCallback_ and arriveEvt then
			self.evtCallback_(arriveEvt, self)
		end

		return
	end

	if not self.points or #self.points == 0 then
		self.pathFinder:singleMapPathStop()

		local points = self.pathFinder:search(myObj.x, myObj.y, x, y, nil, true)

		if points then
			self.points = points
		else
			self.walkFunc = {
				self.followPlayer,
				{
					self
				}
			}

			return
		end
	end

	table.remove(self.points, 1)

	local pos = self.points[1]

	if pos then
		self:moveTo_(pos)
	end

	if tip then
		self:say(tip)
	end
end

function dummy:followPlayer(followDistance, distanceLimit)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(followDistance) == "table" then
		local params = followDistance
		followDistance = params.followDistance
		distanceLimit = params.distanceLimit
	end

	self.walkFunc = {
		dummy.followPlayer_,
		{
			self,
			followDistance or dummy.FOLLOW_DISTANCE,
			distanceLimit or dummy.FOLLOW_DISTANCE_LIMIT
		}
	}
end

function dummy:followPlayer_(followDistance, distanceLimit)
	local player = main_scene.ground.player
	local myObj = self.role
	local map = dummy.getMap()
	local dis = player:getDis(myObj)

	if dis < followDistance then
		return
	end

	if dis <= distanceLimit then
		local x = player.x
		local y = player.y
		local points = self.pathFinder:search(myObj.x, myObj.y, x, y, math.pow(distanceLimit, 2), true, followDistance)

		if points then
			local pos = points[2]

			if pos then
				self:moveTo_(pos)
			end

			return
		end
	end

	self:playAct(SM_SPACEMOVE_SHOW, util.off2p(1, 0), def.role.dir.bottom)
end

function dummy:jumpToPlayer()
	local player = main_scene.ground.player
	self.points = nil

	self:playAct(SM_SPACEMOVE_SHOW, util.off2p(0, 0), 0)
end

function dummy._showEvents(map, pos, type, delay)
	local ids = {}

	for k, v in pairs(pos) do
		local id = string.format("%d,%d", v.x, v.y)

		map:showEvent(id, v.x, v.y, type)
		table.insert(ids, id)
	end

	map:performWithDelay(function ()
		for k, v in ipairs(ids) do
			map:hideEvent(v)
		end
	end, delay)
end

function dummy:magic(magicID, target, offset, dir)
	if magicID == 4 then
		return
	end

	if tolua.isnull(self.role.node) then
		return
	end

	if type(magicID) == "table" then
		local params = magicID
		magicID = params.magicID
		target = params.target
		offset = params.offset
	end

	local noTarget = false

	if target == "player" then
		target = main_scene.ground.player
	elseif target == nil then
		if dir == def.role.dir.up then
			target = util.off2t(0, -1, self)
		elseif dir == def.role.dir.rightUp then
			target = util.off2t(1, -1, self)
		elseif dir == def.role.dir.right then
			target = util.off2t(1, 0, self)
		elseif dir == def.role.dir.rightBottom then
			target = util.off2t(1, 1, self)
		elseif dir == def.role.dir.bottom then
			target = util.off2t(0, 1, self)
		elseif dir == def.role.dir.leftBottom then
			target = util.off2t(-1, 1, self)
		elseif dir == def.role.dir.left then
			target = util.off2t(-1, 0, self)
		elseif dir == def.role.dir.leftUp then
			target = util.off2t(-1, -1, self)
		else
			noTarget = true
			target = self
		end
	end

	offset = offset or cc.p(0, 0)

	if util.inSet(magicID, {
		3,
		7,
		12,
		25,
		26,
		27,
		58,
		300,
		301
	}) then
		dir = dir or util.getDir(self, target)

		self:attack(magicID, offset, dir)

		return
	end

	self.dir = dir or self.dir
	local map = dummy.getMap()
	local skill = def.magic.getMagicConfigByUid(magicID)
	local effectID = skill and skill.effectID

	if effectID then
		local params = {
			effect = {
				effectID = effectID - 1,
				magicId = magicID
			},
			targetX = target.x,
			targetY = target.y
		}

		self.role:processMsg(SM_SPELL, nil, nil, self.dir, nil, nil, params)
	end

	local x, y = nil

	if offset.off2 then
		y = offset.y
		x = offset.x
	else
		x = target.x + offset.x
		y = target.y + offset.y
	end

	if effectID then
		map:performWithDelay(function ()
			if not tolua.isnull(map) then
				if "" .. magicID == "22" and not noTarget then
					local pos = {}

					table.insert(pos, cc.p(x, y))
					table.insert(pos, cc.p(x + 1, y))
					table.insert(pos, cc.p(x - 1, y))
					table.insert(pos, cc.p(x, y + 1))
					table.insert(pos, cc.p(x, y - 1))
					dummy._showEvents(map, pos, mapDef.ET_FIRE, 15)
				elseif "" .. magicID == "31" then
					self:addState("stMagicShield")
					self.role.node:performWithDelay(function ()
						self:removeState("stMagicShield")
					end, 15)
				elseif "" .. magicID == "18" and noTarget then
					self:addState("stHidden")
					self.role.node:performWithDelay(function ()
						self:removeState("stHidden")
					end, 15)
				elseif "" .. magicID == "16" then
					local pos = {}

					table.insert(pos, cc.p(x + 2, y - 1))
					table.insert(pos, cc.p(x + 2, y + 1))
					table.insert(pos, cc.p(x - 2, y - 1))
					table.insert(pos, cc.p(x - 2, y + 1))
					table.insert(pos, cc.p(x + 1, y - 2))
					table.insert(pos, cc.p(x - 1, y - 2))
					table.insert(pos, cc.p(x + 1, y + 2))
					table.insert(pos, cc.p(x - 1, y + 2))
					dummy._showEvents(map, pos, mapDef.ET_HOLYCURTAIN, 15)
				elseif not noTarget and not tolua.isnull(self.role.node) then
					magic.showMagic(map, self.role, target.roleid, x, y, effectID)
				end
			end
		end, 0.5)
	end
end

function dummy:attack(skillIndex, offset, dir)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(skillIndex) == "table" then
		local params = skillIndex
		x = params.x
		y = params.y
		dir = params.dir
	end

	if skillIndex == 3 then
		self:playAct(dummy.acts.HIT, offset, dir)
	elseif skillIndex == 7 then
		self:playAct(dummy.acts.POWERHIT, offset, dir)
	elseif skillIndex == 12 then
		self:playAct(dummy.acts.LONGHIT, offset, dir)
	elseif skillIndex == 25 then
		self:playAct(dummy.acts.WIDEHIT, offset, dir)
	elseif skillIndex == 26 then
		self:playAct(dummy.acts.FIREHIT, offset, dir)
	elseif skillIndex == 12 then
		self:playAct(dummy.acts.FOURFIREHIT, offset, dir)
	elseif skillIndex == 27 then
		self:playAct(dummy.acts.RUSH, offset, dir)
	elseif skillIndex == 58 then
		self:playAct(dummy.acts.SWORD_HIT, offset, dir)
	end
end

function dummy:playBigSkill()
	local sprs = {
		m2spr.playAnimation("cbohum", 24580, 10, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h),
		m2spr.playAnimation("cboweapon", 104580, 10, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h),
		m2spr.playAnimation("cbohair", 4580, 10, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h)
	}

	m2spr.playAnimation("cboeffect", 580, 10, 0.1, true, true, true):addto(self.role.node, 1):pos(0, mapDef.tile.h)

	for k, v in pairs(self.role.sprites) do
		v:setVisible(false)
	end

	self.role.node:performWithDelay(function ()
		sound.playSound("cboZs4_start")
	end, 0.1)
	self.role.node:performWithDelay(function ()
		for k, v in pairs(self.role.sprites) do
			v:setVisible(true)
		end

		for k, v in pairs(sprs) do
			v:removeSelf()
		end
	end, 1.4000000000000001)
end

function dummy:playBigSkill1()
	local time = 1
	local sprs = {
		m2spr.playAnimation("hum", 7408, 5, 0.1, false, false, true):addto(self.role.node, 0):pos(0, mapDef.tile.h),
		m2spr.playAnimation("weapon", 31408, 5, 0.1, false, false, true):addto(self.role.node, 1):pos(0, mapDef.tile.h),
		m2spr.playAnimation("hair", 2608, 5, 0.1, false, false, true):addto(self.role.node, 2):pos(0, mapDef.tile.h)
	}

	self.role.node:performWithDelay(function ()
		sound.playSound("m12-1")
	end, 0.3)
	m2spr.playAnimation("magic2", 760, 14, 0.08, true, true, true):addto(self.role.node, 2):pos(0, mapDef.tile.h)

	for k, v in pairs(self.role.sprites) do
		v:setVisible(false)
	end

	self.role.node:performWithDelay(function ()
		for k, v in pairs(self.role.sprites) do
			v:setVisible(true)
		end

		for k, v in pairs(sprs) do
			v:removeSelf()
		end
	end, time)
end

function dummy:magicEffect(magicID, offset)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(magicID) == "table" then
		local params = magicID
		magicID = params.magicID
		offset = params.offset
	end

	offset = offset or cc.p(0, 0)
	local map = dummy.getMap()
	local skill = def.magic.getMagicConfigByUid(magicID)
	local effectID = skill and skill.effectID
	local x, y = nil

	if offset.off2 then
		y = offset.y
		x = offset.x
	else
		x = self.role.x + offset.x
		y = self.role.y + offset.y
	end

	if not tolua.isnull(map) then
		magic.showMagic(map, self.role, self.role, x, y, effectID)
	end
end

function dummy:playAct(actid, offset, dir, feature, state)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(actid) == "table" then
		local params = actid
		actid = params.actid
		offset = params.offset
		dir = params.dir
		feature = params.feature
		state = params.state
	end

	offset = offset or cc.p(0, 0)
	local feature = self.role.feature

	if feature.race then
		feature:set("race", feature.race)
	end

	if feature.dress then
		feature:set("dress", feature.dress)
	end

	if feature.weapon then
		feature:set("weapon", feature.weapon)
	end

	if feature.hair then
		feature:set("hair", feature.hair)
	end

	local x, y = nil

	if offset.off2 then
		y = offset.y
		x = offset.x
	else
		x = offset.x + self.role.x
		y = offset.y + self.role.y
	end

	local dir = dir or self.dir

	self.role:processMsg(actid, x, y, dir, feature, state)

	if actid == dummy.acts.SPACEMOVE_SHOW then
		magic.showWithName(dummy.getMap(), "spaceMoveShow", {
			roleid = self.roleid
		})
	end
end

function dummy:showEquip(time, dressid, weaponid)
	if tolua.isnull(self.role.node) then
		return
	end

	if type(time) == "table" then
		local params = time
		dressid = params.dressid
		weaponid = params.weaponid
	end

	dressid = dressid or self.dressid
	weaponid = weaponid or self.weaponid
	local model = getRecord("TUserStateInfo")
	local items = model:get("userItems")
	local itemDress, itemWeapon = nil

	if dressid then
		itemDress = getRecord("TClientItem")

		itemDress:set("Index", dressid)
		itemDress:set("makeIndex", -1)
	end

	if weaponid then
		itemWeapon = getRecord("TClientItem")

		itemWeapon:set("Index", weaponid)
		itemWeapon:set("makeIndex", -1)
	end

	model:set("nameColorIndex", self.nameColorIndex or 255)
	model:set("userItems", {
		itemDress,
		itemWeapon
	})

	local role = self.role

	model:set("userName", role.info:getName())

	local pnl = main_scene.ui:showPanel("equipOther", model)

	if time and time > 0 then
		pnl:performWithDelay(function ()
			self:hideEquip()
		end, time)
	end
end

function dummy:hideEquip()
	if not tolua.isnull(main_scene) then
		main_scene.ui:hidePanel("equipOther")
	end
end

function dummy:setNameColor(color, delay)
	self.role.node:performWithDelay(function ()
		self.role.info:setNameColor(color)
	end, delay or 0.1)
end

function dummy:dirTo(pos)
	if tolua.isnull(self.role.node) then
		return
	end

	if pos == "player" then
		pos = main_scene.ground.player
	end

	self.role.dir = util.getDir(self, pos)
end

function dummy:update(dt)
	if self.walkFunc then
		self.walkFunc[1](unpack(self.walkFunc[2]))
	end
end

local function unableModify(tbl)
	local metatable = getmetatable(tbl)

	if not metatable then
		metatable = {}

		setmetatable(tbl, metatable)
	end

	function metatable.__newindex(_, n)
		error("unable to write current table " .. n, 2)
	end
end

unableModify(dummy)

return dummy
