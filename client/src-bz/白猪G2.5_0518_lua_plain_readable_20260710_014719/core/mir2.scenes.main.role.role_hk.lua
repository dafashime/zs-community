local magic = import("..common.magic")
local common = import("..common.common")
local magicParticle = import("..common.magicParticle")
local mapDef = import("..map.def")
local ani = import(".ani")
local info = import(".info")
local role2 = class("role")
local cc2 = require("mir2.cc")
local position = cc.Node.setPosition

table.merge(role2, {})

role2.__P_A = {
	tickInterval = 0.15,
	colorName = "white",
	count = 3,
	followDirSmooth = 5,
	bodyRadius = 5,
	itemDetectRange = 8,
	enableAttackPlayer = true,
	wanderRadiusMax = 75,
	pauseHoverFreq = 1.6,
	enableItemPickup = true,
	followFormationSpread = 20,
	detectRange = 7,
	explodeArcLen = 25,
	chainHitMax = 5,
	orbitSpeed = 2,
	explodeArcCount = 6,
	followSpringK = 10,
	followFormationPattern = "fan",
	overflowStaggerMs = 200,
	afkSleepDelay = 60,
	wingSpan = 11,
	returnSpeed = 500,
	wanderWobbleFreq = 2.1,
	maxOrbsPerTarget = 0,
	wanderPauseMax = 5,
	wanderWobbleAmp = 0.3,
	followDamping = 5.5,
	glowRadius = 24,
	flyCurvature = 0.4,
	orbYScale = 0.5,
	followMode = false,
	followBehindDist = 55,
	pauseHoverAmp = 4,
	explodeDuration = 0.4,
	orbitRadius = 60,
	wanderSpeed = 0.2,
	fairyStyle = 0,
	followToIdleDelay = 0.4,
	wanderPauseMin = 3,
	wanderRadiusMin = 50,
	flySpeed = 800,
	enableAttackMon = true,
	sparkleCount = 3
}

function role2:ctor(params)
	params = params or {}
	self.node = display.newNode()

	function self.node.onEnter(node)
		self:onEnter()
	end

	self.map = params.map
	self.isPlayer = params.isPlayer
	self.roleid = params.roleid
	self.y = params.y or 0
	self.x = params.x or 0
	self.dir = params.dir or def.role.dir.bottom
	self.feature = params.feature or getRecord("TFeature")
	self.state = params.state or getRecord("TAllBodyState")
	self.level = params.level or 1
	self.hitSpeed = avoidPlugValue(0)
	self.roleClrTime = socket.gettime()
	self.shield = nil
	self.orbitingOrbs = nil
	self.sounds = {}
	self.filters = {}
	self.loops = {}
	self.acts = {}
	self.poisonTimes = 4
	self.parts = {}
	self.sprites = {}
	self.cur = {}
	self.last = {
		x = self.x,
		y = self.y,
		dir = self.dir,
		state = self.state,
		pos = cc.p(-1, -1)
	}
	self.lock = {
		execute = false
	}
	self.waits = {}
	self.actions = nil

	self.node:setCascadeOpacityEnabled(true)

	local size = def.role.size

	self.node:size(size.w, size.h)

	self.info = info.new(self, self.map)

	self.node:setNodeEventEnabled(true)

	self.isIgnore = false
	self.hitStatus = def.role.EHitStatus.stand
	self.lastHitedTime = 0
	self.roleStyleAnis = {}

	if def.ccy.isOpenCSSkill() then
		self.diyActEnd = nil
		self.diyDir = params.dir or def.role.dir.bottom
	end

	self.lastMsgTime = nil
end

function role2:removeLoop(value)
	if self.loops[value] then
		local value2, value3 = pcall(function()
			if tolua.cast(self.loops[value], "cc.Node") then
				self.loops[value]:stopAllActions()
				self.loops[value]:removeSelf()

				self.loops[value] = nil
			end
		end)

		if not value2 then
			print("clearLoops error:", value3)
		end
	end
end

function role2:clearLoops()
	for _, loop in pairs(self.loops) do
		if loop then
			local value, value2 = pcall(function()
				if tolua.cast(loop, "cc.Node") then
					loop:stopAllActions()
					loop:removeSelf()
				end
			end)

			if not value then
				print("clearLoops error:", value2)
			end
		end
	end

	self.loops = {}
end

local function updateVisible(self, value)
	return self and value and checkExist(value, unpack(self))
end

function role2:initEnd()
	return
end

function role2:onEnter()
	self:changeFeature(self.feature, true)

	if #self.acts <= 0 then
		self:addAct({
			type = "stand",
			loadMap = true,
			dir = self.dir,
			x = self.x,
			y = self.y
		})
	end

	self:uptInfoShow()
	self:uptSelfShow()
	self:reloadShield()
end

function role2:uptIsIgnore()
	local isIgnore = not self.isInScreen or self.isUnderOtherRole and not self.die and not self.isMoving and not self.isPlayer

	if isIgnore ~= self.isIgnore then
		self.isIgnore = isIgnore

		self:uptInfoShow()
		self:uptSelfShow()
	end
end

function role2:setIsUnderOtherRole(b)
	if self.isUnderOtherRole ~= b then
		self.isUnderOtherRole = b
	end
end

function role2:uptInfoShow()
	if self.noInfo or self.isIgnore or self.die or def.openRealHidden and self.__cname == "hero" and not self.isPlayer and def.stateIsHave(self.state, "stRealHidden") then
		self.info:hide()
	else
		self.info:show()
	end

	if self == g_data.nicerole and self.die and main_scene.ui.panels.nicehp then
		main_scene.ui:hidePanel("nicehp")
	end
end

function role2:uptSelfShow()
	local show = not self.isIgnore

	if show and self.die then
		show = not g_data.setting.base.hideCorpse
	end

	if def.openRealHidden and self.__cname == "hero" and not self.isPlayer and def.stateIsHave(self.state, "stRealHidden") then
		show = false
	end

	for k, v in pairs(self.sprites) do
		v:setVisible(show)
	end
end

function role2:clearLock()
	if not main_scene then
		return
	end

	local lock = main_scene.ui.console.controller.lock

	if lock.target.skill == self.roleid then
		lock.target.skill = nil
	end

	if type(lock.target.attack) == "number" then
		if lock.target.attack == self.roleid then
			lock.target.attack = nil
		end
	elseif lock.target.attack == self then
		lock.target.attack = nil
	elseif lock.role == self then
		lock.role = nil
	end
end

function role2:getDis(other)
	other = other or {
		x = self.x,
		y = self.x
	}

	local x2 = math.abs(self.x - other.x or self.x)
	local y2 = math.abs(self.y - other.y or self.x)

	return math.sqrt(x2 * x2 + y2 * y2)
end

function role2:getRace()
	return self.feature:get("race")
end

function role2:getAppr()
	return self.feature:get("dress")
end

function role2:getWeapon()
	return self.feature:get("weapon")
end

function role2:openFilter(name)
	if not self.filters[name] then
		self.filters[name] = true

		self:checkFilter()
	end
end

function role2:closeFilter(name)
	if not name then
		if table.nums(self.filters) > 0 then
			self.filters = {}

			self:checkFilter()
		end

		return
	end

	if self.filters[name] then
		self.filters[name] = nil

		self:checkFilter()
	end
end

function role2:checkFilter()
	if table.nums(self.filters) == 0 then
		for k, v in pairs(self.sprites) do
			v.spr:clearFilter()
		end

		return
	end

	local f

	if self.filters.die or self.filters.gray then
		f = res.getFilter("gray")
	elseif self.filters.outline then
		f = res.getFilter("outline_role")
	elseif self.filters.highlight then
		f = res.getFilter("high_light")
	elseif self.filters.outlineskill then
		f = res.getFilter("outline_skill")
	end

	if f then
		for k2, v2 in pairs(self.sprites) do
			v2.spr:setFilter(f)
		end
	end
end

function role2:getParts(feature)
	return {}, 0
end

function role2:changeFeature(newFeature, force)
	if type(newFeature) == "number" then
		newFeature = def.role.makeTFeature(newFeature)
	end

	local diff = false

	for k2, v2 in pairs(self.feature) do
		if type(v2) == "number" and v2 ~= newFeature[k2] then
			diff = true

			break
		end
	end

	if not diff and not force then
		return
	end

	local parts, sex = self:getParts(newFeature)

	for k, v in pairs(parts) do
		if not self.parts[k] or v.delete or self.parts[k].imgid ~= v.imgid or self.parts[k].id ~= v.id then
			v.type = k

			self:addAct(v)
		end
	end

	self.parts = parts
	self.sex = sex
	self.feature = newFeature
end

function role2:get()
	return
end

local function callback(self)
	local number2 = self.orbitFairyCfg

	if def.passiveOrbitSkills and def.role.stateHas(self.last.state, "csRevenge") then
		if self.orbitingOrbs and magicParticle and magicParticle.hasOrbiting and not magicParticle.hasOrbiting(self) then
			if magicParticle.stopOrbiting then
				magicParticle.stopOrbiting(self)
			end

			self.orbitingOrbs = nil
		end

		if not self.orbitingOrbs then
			local text = self.orbitStyleIdx
			local checkExist2 = text and def.passiveOrbitSkills[text] or def.passiveOrbitSkills[1]
			local value = text and def.passiveOrbitSkills[text] and text or 1

			if text and not def.passiveOrbitSkills[text] then
				print(string.format("[fairy][WARN] preset [%s] missing in bzconfig.passiveOrbitSkills, fallback to [1] (roleid=%s).", tostring(text), tostring(self.roleid)))
			end

			if checkExist2 and magicParticle and magicParticle.startOrbiting then
				local checkExist3 = checkExist2

				if number2 then
					local value2 = def.fairyMaxCount and def.fairyMaxCount > 0 and def.fairyMaxCount or 5
					local number = tonumber(number2.userCount) or 0
					local count2 = number > 0 and math.max(1, math.min(number, value2)) or checkExist2.count

					checkExist3 = {
						count = count2,
						enableAttackMon = number2.enableAttackMon,
						enableAttackPlayer = number2.enableAttackPlayer,
						enableItemPickup = number2.enableItemPickup
					}

					setmetatable(checkExist3, {
						__index = checkExist2
					})
				end

				if magicParticle.startOrbiting(self, checkExist3, value) then
					self.orbitingOrbs = true
				end
			end
		end
	elseif self.orbitingOrbs then
		if magicParticle and magicParticle.stopOrbiting then
			magicParticle.stopOrbiting(self)
		end

		self.orbitingOrbs = nil
	end
end

function role2:reloadShield()
	if (not def.openRealHidden or self.__cname ~= "hero" or not def.stateIsHave(self.last.state, "stRealHidden")) and def.role.stateHas(self.last.state, "stMagicShield") then
		if self.shield then
			self.shield:hide()
		end

		local magicConfigByUid = def.magic.getMagicConfigByUid(31, self)
		local copiedStartFrame = def.ccy.getCopiedStartFrame(magicConfigByUid, self.job)
		local value = copiedStartFrame.rsc or magicConfigByUid.rsc

		self.shield = m2spr.playAnimation(value, copiedStartFrame.always or 3890, copiedStartFrame.alwaysFrame or 3, 0.15, true):add2(self.node, 2)

		position(self.shield, 0, mapDef.tile.h)
		self.shield:show()
	elseif self.shield then
		self.shield:hide()
	end

	callback(self)
end

function role2:checkColor()
	if def.role.stateHas(self.last.state, "stPoisonFuchsia") then
		return true
	end

	if def.role.stateHas(self.last.state, "stPoisonGreen") then
		return true
	end

	if def.role.stateHas(self.last.state, "stPoisonRed") then
		return true
	end

	if def.role.stateHas(self.last.state, "stPoisonBlue") then
		return true
	end
end

function role2:updateSpriteForState(type2, sprite)
	local function update(t, spr)
		local state2 = self.last.state
		local hasColor

		if def.role.stateHas(state2, "stPoisonStone") then
			self:openFilter("gray")
		else
			self:closeFilter()

			if def.role.stateHas(state2, "stPoisonFuchsia") then
				spr:setColor(cc.c3b(255, 60, 255))

				hasColor = true
			end

			if def.role.stateHas(state2, "stPoisonGreen") and (t == "dress" or t == "hair") then
				spr:setColor(display.COLOR_GREEN)

				self.poisonTimes = 4
				hasColor = true
			end

			if def.role.stateHas(state2, "stPoisonRed") and (t == "dress" or t == "hair") then
				spr:setColor(display.COLOR_RED)

				self.poisonTimes = 4
				hasColor = true
			end

			if def.role.stateHas(state2, "stPoisonBlue") then
				spr:setColor(display.COLOR_BLUE)

				hasColor = true
			end
		end

		if not hasColor then
			spr:setColor(display.COLOR_WHITE)

			if self.selectedSpr then
				if self.filters.highlight then
					self:openFilter("highlight")
				elseif self.filters.outline then
					self:openFilter("outline")
				elseif self.filters.outlineskill then
					self:openFilter("outlineskill")
				end
			end
		else
			self:closeFilter()
		end

		if def.role.stateHas(state2, "stHidden") then
			spr:opacity(128)
		else
			spr:opacity(255)
		end

		if (not def.openRealHidden or self.__cname ~= "hero" or not def.stateIsHave(state2, "stRealHidden")) and def.role.stateHas(state2, "stMagicShield") then
			if not self.shield then
				local magicConfigByUid = def.magic.getMagicConfigByUid(31, self)
				local copiedStartFrame = def.ccy.getCopiedStartFrame(magicConfigByUid, self.job)
				local value = copiedStartFrame.rsc or "magic"

				self.shield = m2spr.playAnimation(value, copiedStartFrame.always or 3890, copiedStartFrame.alwaysFrame or 3, 0.15, true):add2(self.node, 2)

				position(self.shield, 0, mapDef.tile.h)
			end

			self.shield:show()
		elseif self.shield then
			self.shield:hide()
		end

		callback(self)

		if def.openRealHidden and self.__cname == "hero" then
			if def.stateIsHave(state2, "stRealHidden") then
				if not self.hideSpr then
					if self.isPlayer then
						self.hideSpr = m2spr.playAnimation("magic", 1520, 10, 0.1, true, true, true, function()
							self.hideSpr:hide()
						end):add2(self.node, 2)

						sound.playSound("m18-1")
						position(self.hideSpr, 0, mapDef.tile.h)
					else
						self.hideSpr = true
					end
				end

				if self.isPlayer then
					spr:opacity(128)
				else
					for _, sprite2 in pairs(self.sprites) do
						sprite2:setVisible(false)
					end

					self.info:hide()
				end

				self:uptSelfShow()
				self:uptInfoShow()
			elseif self.hideSpr then
				if self.isPlayer then
					self.hideSpr:removeSelf()

					if def.role.stateHas(state2, "stHidden") then
						spr:opacity(128)
					else
						spr:opacity(255)
					end
				end

				self.hideSpr = nil

				self.info:show()
				self:uptSelfShow()
				self:uptInfoShow()
			end
		end

		if def.openSpShield and self.__cname == "hero" then
			if def.stateIsHave(state2, "stSpShield") then
				if not self.noDieShield then
					self.noDieShield = m2spr.playAnimation("magic5", 790, 10, 0.1, true):add2(self.node, 2)

					sound.playSound("hero-shield")
					position(self.noDieShield, 0, mapDef.tile.h)
				end

				self.noDieShield:show()
			elseif self.noDieShield then
				self.noDieShield:hide()
			end
		end
	end

	if type2 and sprite then
		return update(type2, sprite.spr)
	end

	for k, v in pairs(self.sprites) do
		update(k, v.spr)
	end
end

function role2:selected()
	if self.selectedSpr then
		self.selectedSpr:removeFromParent()

		self.selectedSpr = nil
	end

	local x2, y2 = self.node:centerPos()

	self.selectedSpr = res.get2("pic/common/selectRole.png"):add2(self.node, -1):pos(x2, 15)

	if not self:checkColor() and def.openHighlight and self.selectedSpr then
		self:openFilter(def.highlight or "highlight")
	end
end

function role2:unselected()
	if not tolua.isnull(self.selectedSpr) then
		self.selectedSpr:removeFromParent()

		if not self:checkColor() and def.openHighlight then
			self:closeFilter(def.highlight or "highlight")
		end

		self.selectedSpr = nil
	end
end

function role2:highLight()
	for _, sprite in pairs(self.sprites) do
		sprite:setFilter(res.getFilter("high_light"))
	end
end

function role2:unHighLight()
	for _, sprite in pairs(self.sprites) do
		sprite:clearFilter()
	end
end

function role2:getSize()
	if self.parts.dress and self.parts.dress.ani then
		return self.parts.dress.ani:getContentSizeInPixels()
	end

	return self.node:getContentSize()
end

function role2:isHeroForPlayer()
	return g_data.hero and g_data.hero.roleid == self.roleid
end

function role2:isLocked()
	if self.lock.execute and self.cur.act and self.cur.act.type == "struck" then
		return false
	end

	return self.lock.execute
end

function role2:executeAct()
	self.lock.execute = true
	self.curActEnd = false
	self.cur.act = self.acts[1]

	local act2 = self.cur.act

	self.last.x = act2.x or self.last.x
	self.last.y = act2.y or self.last.y
	self.last.dir = act2.dir or self.last.dir
	self.last.state = act2.state or self.last.state

	if act2.type == "state" then
		self:updateSpriteForState()

		return self:executeEnd()
	end

	if checkExist(act2.type, "dress", "weapon", "hair", "humEffect") then
		if self.sprites[act2.type] then
			self.sprites[act2.type]:removeSelf()

			self.sprites[act2.type] = nil
		end

		if not act2.delete then
			local z = checkExist(act2.type, "hair", "humEffect") and 1 or 0
			local spr2 = ani.new(act2, self):addto(self.node, z):pos(0, mapDef.tile.h)

			self.sprites[act2.type] = spr2
			self.sprites[act2.type].actInfo = act2

			self:updateSpriteForState(act2.type, self.sprites[act2.type])

			if self.isIgnore then
				self.sprites[act2.type]:hide()
			end
		end

		self:executeSound()

		return self:executeEnd()
	end

	local delay2

	if self:isExecuteFast() then
		delay2 = def.role.speed.fast
	elseif checkExist(act2.type, "rushLeft", "rushRight") then
		delay2 = def.role.speed.rush
	elseif act2.type == "rushKung" then
		delay2 = def.role.speed.rushKung
	elseif checkExist(act2.type, "run", "walk", "hit", "spell", "heavyHit", "warMode", "bigHit") or updateVisible(def.AllActTypes, act2.type) then
		delay2 = def.role.speed.normal
	elseif act2.type == "struck" then
		delay2 = act2.delay
	end

	if not self.isPlayer and self.__cname == "hero" and def.ccy.isOpenCSSkill() then
		if act2.effect and act2.effect.magicId then
			local magicConfigByUid = def.magic.getMagicConfigByUid(act2.effect.magicId, self) or nil

			if magicConfigByUid and magicConfigByUid.actFrame then
				local text = self.job and tostring(self.job) or "-1"
				local value = magicConfigByUid.actFrame[text]

				if value and (value.dress or value.hair or value.weapon) and act2.dir ~= self.diyDir then
					act2.dir = self.diyDir
					self.dir = self.diyDir
				end
			end
		else
			self.diyDir = act2.dir
		end
	end

	for k, v in pairs(self.sprites) do
		local isOpenCSSkill = def.ccy.isOpenCSSkill() and k or nil

		delay2 = v:play(act2, delay2, isOpenCSSkill)
	end

	delay2 = delay2 or def.role.speed.normal

	if self.sprites.weapon then
		self.sprites.weapon.spr:setLocalZOrder((def.role.dir.rightBottom < act2.dir or act2.dir == def.role.dir.up) and -1 or 1)
	end

	if not self.isIgnore then
		if act2.hitEffect then
			magic.showHitEffect(act2.hitEffect.magicId, {
				x = act2.x,
				y = act2.y,
				dir = act2.dir,
				delay = delay2,
				type = act2.hitEffect.type,
				role = self,
				elmt = act2.hitEffect.elmt
			})
		end

		if act2.effect then
			magic.showSpellEffect(act2.effect.effectID, {
				x = act2.x,
				y = act2.y,
				delay = delay2,
				job = self.job,
				dir = act2.dir,
				role = self,
				elmt = act2.effect.elmt
			})
		end
	end

	if act2.flyaxe then
		local params = {
			role = self
		}

		table.merge(params, act2.flyaxe)
		self.map:showEffectForName("flyaxe", params)
	end

	if act2.otherEffect then
		local begin

		if act2.otherEffect.isFixed then
			begin = act2.otherEffect.begin
		else
			begin = act2.otherEffect.begin + act2.dir * (act2.otherEffect.frame + act2.otherEffect.skip)
		end

		local spr = m2spr.new(nil, nil, {
			blend = true,
			setOffset = true
		}):addto(self.node):pos(0, mapDef.tile.h)

		if act2.otherEffect.delayFrame and act2.otherEffect.delayMax then
			spr:runs({
				cc.DelayTime:create(delay2 / act2.otherEffect.delayMax * act2.otherEffect.delayFrame),
				cc.Show:create(),
				cc.CallFunc:create(function()
					spr:playAni(act2.otherEffect.img, begin, act2.otherEffect.frame, delay2 / act2.otherEffect.frame, true, true, true)
				end)
			})
		else
			spr:playAni(act2.otherEffect.img, begin, act2.otherEffect.frame, delay2 / act2.otherEffect.frame, true, true, true)
		end
	end

	local acttype = act2.type

	if acttype == "stand" then
		position(self.node, self.map:getMapPos(act2.x, act2.y))
		self:executeEnd()
	elseif acttype == "walk" or acttype == "run" or acttype == "rushLeft" or acttype == "rushRight" then
		local disx = math.abs(self.last.x - act2.x)
		local disy = math.abs(self.last.y - act2.y)

		if disx <= 2 and disy <= 2 and (disx == disy or disx == 0 or disy == 0) then
			local x3, y3 = self:getPosition()
			local destx2, desty2 = self.map:getMapPos(act2.x, act2.y)

			self:addAction({
				{
					"moveto",
					delay2,
					x3,
					y3,
					destx2,
					desty2
				},
				{
					"function",
					handler(self, self.executeEnd)
				}
			})
			self.map:uptRoleXY(self, true)
		else
			act2.type = "stand"

			self.node:pos(self.map:getMapPos(act2.x, act2.y))
			self:executeEnd()
		end
	elseif acttype == "hit" or acttype == "attack" or acttype == "heavyHit" or acttype == "bigHit" or updateVisible(def.HitTypes, acttype) then
		self.node:pos(self.map:getMapPos(act2.x, act2.y))
		self:addAction({
			{
				"delay",
				delay2
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	elseif acttype == "rushKung" then
		local x2, y2 = self:getPosition()
		local destx, desty = self.map:getMapPos(act2.x, act2.y)

		self:addAction({
			{
				"moveto",
				delay2 / 2,
				x2,
				y2,
				destx,
				desty
			},
			{
				"moveto",
				delay2 / 2,
				destx,
				desty,
				x2,
				y2
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
		self.map:uptRoleXY(self, true)
	elseif acttype == "digdown" and self.__cname == "mon" then
		self:addAction({
			{
				"delay",
				delay2
			},
			{
				"function",
				function()
					self.readyRemove = true
				end
			}
		})
	elseif (acttype == "spell" or updateVisible(def.SpellTypes, acttype)) and self.isPlayer then
		if act2.x and act2.y then
			self.node:pos(self.map:getMapPos(act2.x, act2.y))
		end

		self:addAction({
			{
				"delay",
				delay2
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	elseif acttype == "struck" then
		local value2 = self.last.state
		local value3 = not def.openRealHidden or self.__cname ~= "hero" or not def.stateIsHave(value2, "stRealHidden")

		if def.crashDun and value3 and def.role.stateHas(value2, "stMagicShield") and self.shield then
			local magicConfigByUid2 = def.magic.getMagicConfigByUid(31, self)
			local copiedStartFrame = def.ccy.getCopiedStartFrame(magicConfigByUid2, self.job)

			if copiedStartFrame and copiedStartFrame.crashed then
				local value4 = copiedStartFrame.rsc or magicConfigByUid2.rsc

				position(m2spr.playAnimation(value4, copiedStartFrame.crashed or 3900, copiedStartFrame.crashedFrame or 3, delay2 / 2, true, true, true):add2(self.node, 2):opacity(127.5), 0, mapDef.tile.h)
			end
		end

		self:addAction({
			{
				"delay",
				delay2
			},
			{
				"function",
				function()
					if act2 == self.cur.act and self.cur.act.type == "struck" then
						self:executeEnd()
					end
				end
			}
		})
	else
		if act2.x and act2.y then
			position(self.node, self.map:getMapPos(act2.x, act2.y))
		end

		if self.diyActEnd and def.ccy.isOpenCSSkill() then
			local value5 = self.diyActEnd - 0.4
			local value6 = scheduler.performWithDelayGlobal(function()
				self:addAction({
					{
						"delay",
						delay2
					},
					{
						"function",
						handler(self, self.executeEnd)
					}
				})

				self.diyActEnd = nil
			end, value5)
		else
			self:addAction({
				{
					"delay",
					delay2
				},
				{
					"function",
					handler(self, self.executeEnd)
				}
			})
		end
	end

	self:executeSound(delay2)

	local dirOwner = self.cur.act or self.last.act

	for key, sprite in pairs(self.sprites) do
		if checkExist(key, "weapon", "hair", "humEffect") and sprite.actInfo and sprite.actInfo.secondaryZorder then
			local count2 = 1

			if checkExist(dirOwner.dir, unpack(sprite.actInfo.secondaryZorder)) then
				count2 = -1
			end

			sprite.spr:setLocalZOrder(count2)
		end
	end
end

function role2:addAction(params)
	self.actions = params
	self.actionsCache = {}
end

function role2:executeActions(dt)
	local v = self.actions[1]

	if v[1] == "moveto" then
		local delay2 = v[2]
		local x2 = v[3]
		local y2 = v[4]
		local destx = v[5]
		local desty = v[6]

		self.actionsCache.dt = (self.actionsCache.dt or 0) + dt
		self.isMoving = true

		local cur = self.actionsCache.dt

		if delay2 <= cur then
			self.isMoving = false

			self.node:pos(destx, desty)

			self.actionsCache = {}

			table.remove(self.actions, 1)

			if #self.actions > 0 then
				self:executeActions(cur - delay2)
			end
		else
			self.actionsCache.speed = self.actionsCache.speed or {
				(destx - x2) / delay2,
				(desty - y2) / delay2
			}

			position(self.node, x2 + self.actionsCache.dt * self.actionsCache.speed[1], y2 + self.actionsCache.dt * self.actionsCache.speed[2])
		end
	elseif v[1] == "delay" then
		local delay3 = v[2]

		self.actionsCache.dt = (self.actionsCache.dt or 0) + dt

		local cur2 = self.actionsCache.dt

		if delay3 <= cur2 then
			self.actionsCache = {}

			table.remove(self.actions, 1)

			if #self.actions > 0 then
				self:executeActions(cur2 - delay3)
			end
		end
	elseif v[1] == "function" then
		table.remove(self.actions, 1)
		v[2]()
	end
end

function role2:isExecuteFast()
	return #self.acts > 1
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function role2:executeSound(delay2)
	local act2 = self.cur.act

	if not act2 then
		return
	end

	if self.isPlayer and checkExist(act2.type, "walk", "run", "rushLeft", "rushRight", "rushKung") then
		sound.play("footStep", {
			role = self,
			map = self.map,
			delay = delay2
		})

		return
	end

	if self.__cname == "npc" then
		-- block empty
	elseif self.__cname == "mon" then
		sound.play("mon", {
			role = self,
			act = act2,
			map = self.map
		})
	elseif self.__cname == "hero" and not self.isIgnore then
		local enabled = true

		if act2.effect and act2.effect.magicId and def.ccy.isOpenCSSkill() then
			local magicConfigByUid = def.magic.getMagicConfigByUid(act2.effect.magicId, self) or nil
			local text = self.job and tostring(self.job) or "-1"

			if magicConfigByUid and magicConfigByUid.actFrame and magicConfigByUid.actFrame[text] then
				local value = magicConfigByUid.actFrame[text]
				local value2 = value.shakeTime or -1

				if value.actMusic then
					local value4 = string.lower(value.actMusic.man or "")
					local value5 = string.lower(value.actMusic.woman or "")
					local value3 = self.sex == 0 and value4 or value5

					if value3 and value3 ~= "" then
						sound.playSound(value3, false)

						enabled = false
					end
				end

				if value2 and value2 >= 0 and self.isPlayer then
					local value6 = scheduler.performWithDelayGlobal(function()
						def.ccy.sceneShake()
					end, value2)
				end

				if not enabled then
					return
				end
			end
		end

		if act2.musicType then
			sound.play(act2.musicType, {
				role = self,
				effect = act2.hitEffect,
				delay = delay2
			})
		elseif act2.type == "hit" or act2.type == "heavyHit" or act2.type == "bigHit" then
			sound.play("hit", {
				role = self,
				effect = act2.hitEffect,
				delay = delay2
			})
		elseif act2.type == "hited" then
			sound.play("hited", {
				role = self,
				delay = delay2
			})
		elseif act2.type == "spell" and act2.effect then
			sound.play("skillSpell", {
				role = self,
				magicId = act2.effect.magicId
			})
		end
	end
end

function role2:spellDone()
	if not main_scene then
		return
	end

	local controller = main_scene.ui.console.controller
	local map2 = main_scene.ground.map

	if controller.stopAttack then
		controller.stopAttack = false
	end
end

function role2:executeEnd(act2)
	self.curActEnd = true

	if #self.waits > 0 then
		return
	end

	self.actions = nil
	self.lock.execute = false
	self.last.act = act2 or self.cur.act
	self.cur.act = nil

	table.remove(self.acts, 1)
	self.map:uptRoleXY(self, false, self.last.x, self.last.y)

	if self.isPlayer then
		if #self.acts > 0 then
			self:executeAct()
		end

		if self.last.act and (self.last.act.type == "spell" or updateVisible(def.SpellTypes, self.last.act.type) or self.last.act.type == "state") then
			self:spellDone()
		end
	elseif #self.acts == 0 and not self.isExecuteEnd then
		self:allExecuteEnd()
	end
end

function role2:allExecuteEnd()
	self.isExecuteEnd = true

	self:addStandAct()
end

function role2:executeFail(x2, y2, dir2)
	local act2

	if #self.waits > 0 then
		act2 = self.waits[1]
		self.dir = dir2 or act2.wait.dir or self.dir
		self.y = y2 or act2.wait.y or self.y
		self.x = x2 or act2.wait.x or self.x
		self.waits = {}
	end

	for k, v in pairs(self.parts) do
		if v.ani and v.ani.play then
			v.ani:play("stand", self.dir)
		end
	end

	self.node:stopAllActions()
	self.node:pos(self.map:getMapPos(self.x, self.y))
	self:executeEnd(act2)
end

function role2:executeSuccess()
	local act2 = self.waits[1]

	if act2 and (act2.type == "hit" or updateVisible(def.HitTypes, act2.type)) then
		self.hitStatus = def.role.EHitStatus.hit
	elseif act2 and act2.type == "stand" then
		self.hitStatus = def.role.EHitStatus.stand
	end

	if self.diyActEnd and def.ccy.isOpenCSSkill() then
		local value = self.diyActEnd
		local value2 = scheduler.performWithDelayGlobal(function()
			table.remove(self.waits, 1)

			if self.curActEnd then
				self:executeEnd()
			end

			self.diyActEnd = nil
		end, value)
	else
		table.remove(self.waits, 1)

		if self.curActEnd then
			self:executeEnd()
		end
	end
end

function role2:findAtkRoles(value)
	return
end

function role2:addAct(params)
	if self.die and params.type ~= "die" and not params.gutou then
		return
	elseif params.type == "die" and not self.node:isRunning() then
		self:onEnter()
	end

	if self.cur.act and self.cur.act.type == "struck" then
		self:executeEnd()
	elseif params.type == "struck" and self.isPlayer then
		def.role.beAttacking = true

		self:onStruck()

		self.beAttacking = true

		if def.role.timer[bzmir.cmatk .. self.roleid] then
			def.role.cancelAutoRun(def.role.timer[bzmir.cmatk .. self.roleid])

			def.role.timer[bzmir.cmatk .. self.roleid] = nil
		end

		def.role.timer[bzmir.cmatk .. self.roleid] = def.role.autoRun(function()
			if main_scene and main_scene.ui then
				if self.isPlayer then
					def.role.beAttacking = false
				end

				self.beAttacking = false
			end
		end, 6)
	end

	if params.type == "stand" and self.last.act and self.last.act.type == params.type and self.last.act.dir == params.dir and not params.loadMap and not params.stone then
		return
	end

	;(function()
		if self.isPlayer and params.x and params.y then
			if params.type == "walk" or params.type == "run" or params.type == "rushLeft" or params.type == "rushRight" then
				self.map:load(self.x, self.y, params.x - self.x, params.y - self.y)
			elseif self.x ~= params.x or self.y ~= params.y or params.loadMap then
				self.map:load(params.x, params.y)
			end
		end
	end)()

	params.x = params.x or self.x
	params.y = params.y or self.y
	params.dir = params.dir or self.dir

	if params.wait then
		self.waits[#self.waits + 1] = params
	end

	local enabled = false
	local enabled2 = false

	if params.type == "hit" or params.type == "bigHit" or params.type == "spell" or updateVisible(def.AllActTypes, params.type) then
		def.role.attacking = true

		if def.role.timer[bzmir.cmatk1] then
			def.role.cancelAutoRun(def.role.timer[bzmir.cmatk1])

			def.role.timer[bzmir.cmatk1] = nil
		end

		def.role.timer[bzmir.cmatk1] = def.role.autoRun(function()
			def.role.attacking = false
		end, 6)
	end

	if main_scene.ground.player then
		local value2 = def.safeZoneNoUseBuff and g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y)

		if self.isPlayer and params.type and not value2 and (params.type == "hit" or params.type == "bigHit" or params.type == "spell" or updateVisible(def.AllActTypes, params.type)) and not self:weaponHit(params) then
			if params.type == "spell" or updateVisible(def.SpellTypes, params.type) then
				enabled, enabled2 = self:magicHit(params)
			elseif params.type == "hit" or params.type == "bigHit" or updateVisible(def.HitTypes, params.type) then
				if params.hitEffect and params.hitEffect.magicId then
					if params.hitEffect.magicId == 12 then
						if self:getDis(main_scene.ui.console.controller.lock.role) >= 2 then
							enabled, enabled2 = self:magicHit(params)
						end
					else
						enabled, enabled2 = self:magicHit(params)
					end
				else
					self:attackHit(params)
				end
			else
				self:attackHit(params)
			end
		end
	end

	if enabled and enabled2 then
		params.hideEffect = true
	end

	self.acts[#self.acts + 1] = params
	self.dir = params.dir
	self.x = params.x
	self.y = params.y
	self.isExecuteEnd = false

	if params.type == "die" then
		if def.openOnDieCall and not self.isPlayer then
			local value = self.atkRoleid == g_data.player.roleid

			if not value and g_data.player:hasSlave() and self.atkRoleid then
				local role3 = main_scene.ground.map:findRole(self.atkRoleid)

				if role3 then
					local realName = role3.info:getRealName():split("(")[1]

					for _, slave in ipairs(g_data.player.slaves) do
						if string.match(string.gsub(slave, "%d", ""), realName) then
							value = true

							break
						end
					end
				end
			end

			if value then
				def.role.call("@onDieCall~" .. self.__cname .. bzmir.cmdcnt .. self.info:getRealName() .. bzmir.cmdcnt .. g_data.map.mapTitle)
			end
		end

		self.die = true

		self:uptInfoShow()
		self:uptSelfShow()
		self:clearLock()

		if main_scene and main_scene.ui.panels.minimap then
			main_scene.ui.panels.minimap:removePoint(self.roleid)
		end

		if self:isHeroForPlayer() and main_scene and main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead.headshot then
			main_scene.ui.panels.heroHead.headshot:setFilter(res.getFilter("gray"))
		end
	end

	if self.isPlayer and #self.acts == 1 then
		self:executeAct()
	end
end

function role2:addStandAct()
	self.hitStatus = def.role.EHitStatus.stand

	self:addAct({
		type = "stand",
		dir = self.dir,
		x = self.x,
		y = self.y
	})
end

function role2:processMsg(ident, x2, y2, dir2, feature, state2, params)
	self.lastMsgTime = socket.gettime()
	params = params or {}

	local elmt2 = params.elmt

	if SM_TURN == ident then
		self.hitStatus = def.role.EHitStatus.stand

		self:addAct({
			type = "stand",
			x = x2,
			y = y2,
			dir = dir2,
			stone = state2 and def.role.stateHas(state2, "stStone")
		})

		if self.__cname == "mon" then
			sound.play("born", self.sounds.born)
		end
	elseif SM_WALK == ident or SM_NPCWALK == ident then
		self.hitStatus = def.role.EHitStatus.walk

		self:addAct({
			type = "walk",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_RUN == ident then
		self.hitStatus = def.role.EHitStatus.run

		self:addAct({
			type = "run",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_BACKSTEP == ident then
		self:addAct({
			type = "walk",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_DEATH == ident then
		self:addAct({
			corpse = true,
			type = "die",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_NOWDEATH == ident then
		self:addAct({
			type = "die",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_HIT == ident then
		self.hitStatus = def.role.EHitStatus.hit

		local items
		local x3

		if self.__cname == "hero" then
			x3 = "hit"
			items = {
				elmt = elmt2
			}
		else
			x3 = "attack"
		end

		self:addAct({
			type = x3,
			x = x2,
			y = y2,
			dir = dir2,
			items
		})
	elseif SM_HEAVYHIT == ident then
		self:addAct({
			type = "heavyHit",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_BIGHIT == ident then
		self:addAct({
			type = "bigHit",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_POWERHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "pow",
				magicId = 7,
				elmt = params.elmt
			}
		})
	elseif SM_LONGHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "long",
				magicId = 12,
				elmt = params.elmt
			}
		})
	elseif SM_WIDEHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "wide",
				magicId = 25,
				elmt = params.elmt
			}
		})
	elseif SM_FIREHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "fire",
				magicId = 26,
				elmt = params.elmt
			}
		})
	elseif SM_XHHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "fire",
				magicId = 321,
				elmt = params.elmt
			}
		})
	elseif SM_LYHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "fire",
				magicId = 320,
				elmt = params.elmt
			}
		})
	elseif SM_SFZHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "sfz",
				magicId = 392,
				elmt = params.elmt
			}
		})
	elseif SM_4FIREHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "fire4",
				magicId = 26,
				elmt = params.elmt
			}
		})
	elseif SM_HERO_LONGHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "twn1",
				magicId = 34,
				elmt = params.elmt
			}
		})
	elseif SM_HERO_LASTHIT == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "twn2",
				magicId = 34,
				elmt = params.elmt
			}
		})
	elseif SM_SWORD_HIT == ident then
		self:addAct({
			type = "bigHit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "sword",
				effectID = 75,
				magicId = 58,
				elmt = params.elmt
			}
		})
	elseif SM_RUSH == ident then
		self:addAct({
			type = self.lastRushLeft and "rushRight" or "rushLeft",
			x = x2,
			y = y2,
			dir = dir2
		})

		self.lastRushLeft = not self.lastRushLeft
	elseif SM_RUSHKUNG == ident then
		self:addAct({
			type = "rushKung",
			rushx = x2,
			rushy = y2,
			dir = dir2
		})
	elseif SM_ASS_BLOODHIT_MOVE == ident then
		if self.actBLOODHIT2 then
			local function callback(self2, point)
				if self2 and point then
					return math.max(math.abs(self2.x - point.x), math.abs(self2.y - point.y))
				end

				return 999
			end

			self:actBLOODHIT2(x2, y2, dir2, position, mapDef, callback, params)
		end
	elseif SM_STRUCK == ident then
		if self.isPlayer then
			if self.hitStatus == def.role.EHitStatus.stand then
				local time = socket.gettime()

				if time - self.lastHitedTime > 1 then
					self:addAct({
						delay = 0.22,
						type = "struck",
						hiter = x2
					})

					if def.stateIsHave(self.state, "stHorse") then
						sound.playSound("mahited")
					else
						sound.play("hited", {
							role = self
						})
					end

					self.lastHitedTime = time
				end
			end

			if def.playOnStruckMagic then
				local value = m2spr.playAnimation("magic01", 0, 6, 0.1, true, true, true):add2(self.node, 2)

				position(value, 0, mapDef.tile.h)
				sound.playSound("jida")
			end
		else
			local time2 = socket.gettime()

			if time2 - self.lastHitedTime > 1 then
				local value4
				local delay2 = self.hitStatus == def.role.EHitStatus.stand and 0.22 or 0.1

				self:addAct({
					type = "struck",
					delay = delay2,
					hiter = x2
				})
				sound.play("hited", {
					role = self
				})

				self.lastHitedTime = time2
			end

			if def.playOnStruckMagic then
				local value2 = m2spr.playAnimation("magic01", 0, 6, 0.1, true, true, true):add2(self.node, 2)

				position(value2, 0, mapDef.tile.h)
				sound.playSound("jida")
			end
		end
	elseif SM_SHOWBODY_EFFECT == ident then
		local value3 = m2spr.playAnimation("magic5", 790, 10, 0.07, true, true, true):add2(self.node, 2)

		position(value3, 0, mapDef.tile.h)
		sound.playSound("hero-shield")
	elseif SM_FEATURECHANGED == ident then
		self:changeFeature(feature)
	elseif SM_CHARSTATUSCHANGED == ident then
		self.state = state2

		self:addAct({
			type = "state",
			state = self.state
		})
	elseif SM_SKELETON == ident then
		self:addAct({
			dir = 0,
			gutou = true,
			type = "die",
			x = x2,
			y = y2
		})
	elseif SM_DIGUP == ident then
		self:addAct({
			type = "digup"
		})
		sound.play("appr", self.sounds.appr)
	elseif SM_DIGDOWN == ident then
		self:addAct({
			type = "digdown",
			x = x2,
			y = y2
		})
		sound.play("sitdown", self.sounds.attack)
	elseif SM_ALIVE == ident then
		self.die = false

		self:uptInfoShow()
		self:addAct({
			type = "death"
		})
		sound.play("born", self.sounds.born)
	elseif SM_SPACEMOVE_SHOW == ident or SM_SPACEMOVE_SHOW2 == ident then
		self.attacking = false

		self:addAct({
			type = "spacemove",
			x = x2,
			y = y2,
			dir = dir2
		})
	elseif SM_FLYAXE == ident then
		self:addAct({
			type = "attack",
			x = x2,
			y = y2,
			dir = dir2,
			flyaxe = params
		})
	elseif SM_BUTCH == ident then
		self:addAct({
			type = "sitdown"
		})
	elseif SM_SPELL == ident then
		self:addAct({
			type = "spell",
			dir = def.role.getMoveDir(self.x, self.y, params.targetX, params.targetY),
			effect = params.effect
		})
	elseif SM_HERO_LOGON == ident then
		-- block empty
	elseif SM_HEALTHSPELLCHANGED == ident then
		print("SM_HEALTHSPELLCHANGED 待处理")
	elseif SM_UNITEHIT0 == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "zz",
				magicId = 50,
				elmt = params.elmt
			}
		})
	elseif SM_UNITEHIT1 == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "zf",
				magicId = 52,
				elmt = params.elmt
			}
		})
	elseif SM_UNITEHIT2 == ident then
		self:addAct({
			type = "hit",
			x = x2,
			y = y2,
			dir = dir2,
			hitEffect = {
				type = "zd",
				magicId = 51,
				elmt = params.elmt
			}
		})
	else
		print("role: ", ident)
	end

	return self
end

function role2:addStruckAct()
	self.hitStatus = def.role.EHitStatus.stand

	local lastHitedTime = socket.gettime()

	if lastHitedTime - self.lastHitedTime > 1 then
		self:addAct({
			delay = 0.22,
			type = "struck",
			hiter = self.x
		})
		sound.play("hited", {
			role = self
		})

		self.lastHitedTime = lastHitedTime
	end
end

function role2:onStruck()
	if def.role.mainsetting.openStruckStyle then
		self:struckStyle()
	end

	if def.role.mainsetting.openOnStruckEvent then
		def.role.call("@onStruck")
	end
end

local getPosition = cc.Node.getPosition

function role2:getPosition()
	return getPosition(self.node)
end

function role2:update(spr)
	if not self.isPlayer and not self.lock.execute and #self.acts > 0 then
		self:executeAct()
	end

	if self.actions and #self.actions ~= 0 then
		self:executeActions(spr)
	end

	if self.readyRemove then
		self.map:addMsg({
			remove = true,
			roleid = self.roleid
		})

		return
	end

	local x2, y2 = self:getPosition()
	local lpos = self.last.pos

	if lpos.x ~= x2 or lpos.y ~= y2 then
		lpos.x = x2
		lpos.y = y2

		self.info:uptPos(x2, y2)

		local _, y3 = self.map:getGamePos(x2, y2)

		self.node:setLocalZOrder(y3)

		if main_scene and main_scene.ui.panels.minimap then
			if def.hideMinimapHero and self.__cname == "hero" then
				if g_data.player.roleid == self.roleid then
					main_scene.ui.panels.minimap:pointUpt(self.map, self)
				end
			else
				main_scene.ui.panels.minimap:pointUpt(self.map, self)
			end
		end

		if self.isPlayer then
			self.map:scroll()

			if main_scene.ui.panels.minimap then
				main_scene.ui.panels.minimap:scroll(self.map, self)
			end

			if main_scene.ui.panels.bigmap then
				main_scene.ui.panels.bigmap:pointUpt(self.map, self)
			end

			if main_scene.ui.panels.bigmapOther then
				main_scene.ui.panels.bigmapOther:pointUpt(self.map, self)
			end
		end
	end

	if def.openEeltColor and self.__cname == "hero" and socket.gettime() - self.roleClrTime > 4 then
		self.roleClrTime = socket.gettime()

		if not self.die and self.state and self.isInScreen and def.stateIsHave(self.state, "stState3") and (self.info and self.info.name and self.info.name.color == 255 or not checkExist(self.info.name.color, 47, 249, 221, 147, 180, 69)) then
			local value2 = math.random(7)
			local value = def.EeltColor[value2]

			if value then
				self.info:setNameColor(value)
			end
		end
	end

	self.info:update(spr)
end

function role2:processBuff(dirOwner, value, value2, value3)
	if not self.addBuff then
		return
	end

	if value then
		if (value.buffPercent or 30) < math.random(100) then
			return false
		end

		local role3
		local name
		local enabled = false

		if main_scene.ui.console.controller.lock then
			role3 = main_scene.ui.console.controller.lock.role

			if role3 and not role3.die and self:getDis(role3) < 10 then
				if role3.info then
					name = role3.info:getName()
				end

				enabled = role3.__cname == "hero"
			else
				role3 = nil
			end
		end

		if not solt0190 then
			os.exit()
		end

		if value.style then
			local lockid2 = "1000"

			if role3 then
				lockid2 = role3.roleid
			end

			if value.active_role and value.active_role == 0 then
				self:addBuff({
					buffme = true,
					role = main_scene.ground.player,
					dir = dirOwner.dir,
					style = value.style,
					lockid = lockid2
				})
			elseif role3 then
				self:addBuff({
					buffme = false,
					role = role3,
					dir = dirOwner.dir,
					style = value.style,
					lockid = lockid2
				})
			end
		end

		if role3 then
			local text = "0"

			if enabled then
				text = "1"
			end

			def.role.call(bzmir.mcmd .. value2 .. bzmir.cmdcnt .. value3 .. bzmir.cmdcnt .. (value.style or "notset") .. bzmir.cmdcnt .. (name or "notset") .. bzmir.cmdcnt .. text)
		else
			def.role.call(bzmir.mcmd .. value2 .. bzmir.cmdcnt .. value3 .. bzmir.cmdcnt .. (value.style or "notset") .. "~notset~0")
		end

		return true
	end

	return false
end

function role2:attackHit(value)
	local config = def.role.getConfig("buff")

	if config and config.attack_buff and config.attack_buff.buffs then
		for key, buff in pairs(config.attack_buff.buffs) do
			if def.role.roleStatus.buffs and def.role.roleStatus.buffs:find(key) ~= nil and self:processBuff(value, buff, "attackHit", key, true) then
				return true
			end
		end
	end

	return false
end

function role2:magicHit(value)
	local function loadMapTest()
		if (value.type == "spell" or updateVisible(def.SpellTypes, value.type)) and value.effect and value.effect.magicId then
			return value.effect.magicId
		elseif (value.type == "hit" or value.type == "bigHit" or updateVisible(def.HitTypes, value.type)) and value.hitEffect and value.hitEffect.magicId then
			return value.hitEffect.magicId
		end

		return nil
	end

	local config = def.role.getConfig("buff")

	if config and config.skill_buff then
		local text2 = loadMapTest()

		if text2 then
			local text = config.skill_buff[tostring(text2)] or config.skill_buff[tostring(text2) .. "-" .. tostring(g_data.player.job)]

			if text and text.buffs then
				for key, buff in pairs(text.buffs) do
					if def.role.roleStatus.buffs and def.role.roleStatus.buffs:find(key) ~= nil and self:processBuff(value, buff, "magicHit", key) then
						return true, buff.hideOrgEffect
					end
				end
			end
		end
	end

	return false
end

function role2:weaponHit(value2)
	if not self.addBuff then
		return
	end

	local function callback(self2, value5)
		if self2[value5] then
			return self2[value5]
		else
			for itemId, item in pairs(self2) do
				if itemId:find("[" .. value5 .. "]") ~= nil then
					return item
				end
			end
		end

		return nil
	end

	if def.role.mainsetting.openWeaponAttackingEvent then
		if not def.role.attacking then
			return
		end

		local config = def.role.getConfig("buff")

		if config and config.weapon_buff and def.role.currWeapon.name then
			local value3 = callback(config.weapon_buff, def.role.currWeapon.name)

			if value3 then
				local text2 = def.role.currWeapon["max" .. value3.abil] or 0
				local value4 = def.role.currWeapon["normalMax" .. value3.abil]

				if value4 and value4 < text2 then
					local text = tostring(text2 - value4)
					local value = value3.buffs["buff_" .. text]

					if value then
						if (value.buffPercent or 30) < math.random(100) then
							return
						end

						if value.active_skill and value.active_skill ~= -1 then
							if value2.type == "spell" or updateVisible(def.SpellTypes, value2.type) then
								if not value2.effect or not value2.effect.magicId then
									return
								elseif value.active_skill ~= value2.effect.magicId then
									return
								end
							elseif value2.type == "hit" or updateVisible(def.HitTypes, value2.type) then
								if not value2.hitEffect or not value2.hitEffect.magicId then
									return
								elseif value2.hitEffect.magicId ~= value.active_skill then
									return
								end
							end
						end

						local role3
						local value6
						local enabled = false

						if main_scene.ui.console.controller.lock then
							role3 = main_scene.ui.console.controller.lock.role

							if role3 and not role3.die and self:getDis(role3) < 10 then
								if role3.info and role3.info.texts and role3.info.texts[1] then
									value6 = role3.info.texts[1]
								end

								enabled = role3.__cname == "hero"
							else
								role3 = nil
							end
						end

						local lockid2 = "1000"

						if role3 then
							lockid2 = role3.roleid
						end

						if value.style then
							if value.active_role and value.active_role == 0 then
								self:addBuff({
									buffme = true,
									role = main_scene.ground.player,
									dir = value2.dir,
									style = value.style,
									lockid = lockid2
								})
							elseif role3 then
								self:addBuff({
									buffme = false,
									role = role3,
									dir = value2.dir,
									style = value.style,
									lockid = lockid2
								})
							end
						end

						if role3 then
							local text3 = "0"

							if enabled then
								text3 = "1"
							end

							def.role.call("@weaponHit~" .. text .. bzmir.cmdcnt .. (value.style or "notset") .. bzmir.cmdcnt .. (value6 or "notset") .. bzmir.cmdcnt .. text3)
						else
							def.role.call("@weaponHit~" .. text .. bzmir.cmdcnt .. (value.style or "notset") .. "~notset~0")
						end

						return true
					end
				end
			end
		end
	end
end

function role2:roleNormalStyle(value)
	local x2, value4 = self.node:centerPos()
	local value2 = _get2(bzmir.eftfd .. value.WhichLib .. bzmir.prefix .. (value.start or 1) .. bzmir.ext):scale(value.sc or 1):anchor(0.5, 0.5):pos(x2 + (value.offsetx or 0), value4 + (value.offsety or 0)):add2(self.node)

	if value2 then
		value2:setTouchEnabled(false)

		local duration = value.playtimes or (value.frame or 1) * (value.interval or 0.1)
		local value3 = _getani2(bzmir.eftfd .. value.WhichLib .. bzmir.ext1, value.start or 1, value.frame or 1, value.interval or 0.1)

		if value3 then
			if value.sound then
				sound.playSound(value.sound)
			end

			if value.addStruck then
				self:addStruckAct()
			end

			value3:retain()
			value2:runForever(cc.Animate:create(value3))
			value2:runs({
				cc.DelayTime:create(duration or 1),
				cc.CallFunc:create(function()
					if value2 then
						if value2 then
							value2:removeSelf()

							value2 = nil
						end

						if value.callback and (value.publicCall or main_scene.ground.player and main_scene.ground.player.roleid == self.roleid) then
							def.role.call(value.callback)
						end
					end
				end)
			})

			if value.name then
				self.loops[value.name] = value2
			else
				self.loops["loop" .. os.time()] = value2
			end
		end
	end
end

function role2:roleAniStyle(value, value5, number3)
	if not value then
		return
	end

	local value3 = value.start or 0
	local value4 = value.frame or 1
	local value7 = value.skip or 0
	local value6 = value.interval or 0.1

	if value.withDir and value5 then
		value3 = value3 + (value4 + value7) * value5
	end

	if value.sound then
		sound.playSound(value.sound)
	end

	if value.addStruck then
		self:addStruckAct()
	end

	local enabled = true
	local duration = value.playtimes

	if duration then
		enabled = false
	end

	duration = duration or value4 * value6

	if value.WhichLib and value.WhichLib ~= "" then
		local value2

		if enabled then
			value2 = m2spr.playAnimation(value.WhichLib, value3, value4, value6, value.isBlend, enabled, true, nil, nil, nil, 1):add2(self.node, 2):scale(value.sc or 1)
		else
			value2 = m2spr.playAnimation(value.WhichLib, value3, value4, value6, value.isBlend, enabled, false, nil, nil, nil, 1):add2(self.node, 2):scale(value.sc or 1):runs({
				cc.DelayTime:create(duration),
				cc.CallFunc:create(function()
					if value2 then
						value2:removeSelf()

						value2 = nil
					end

					if value.callback and (value.publicCall or main_scene and main_scene.ground and main_scene.ground.player and main_scene.ground.player.roleid == self.roleid) then
						def.role.call(value.callback)
					end

					if value.otherEffect then
						self:roleAniStyle(value.otherEffect, value5)
					end

					if value.flyaxe then
						local items2 = {
							role = self
						}

						table.merge(items2, value.flyaxe)
						self.map:showEffectForName("flyaxe", items2)
					end

					if value.targetEffect and number3 then
						local number2 = main_scene.ground.map:findRole(tonumber(number3), {}, true)

						if number2 and not role2.die and self:getDis(number2) < 10 then
							number2:roleAniStyle(value.targetEffect, nil)
						end
					end
				end)
			})
		end

		if value2 then
			position(value2, 0, mapDef.tile.h)

			if value.name then
				self.loops[value.name] = value2
			else
				self.loops["loop" .. os.time()] = value2
			end
		end
	else
		if value.callback and (value.publicCall or main_scene.ground.player and main_scene.ground.player.roleid == self.roleid) then
			def.role.call(value.callback)
		end

		if value.otherEffect then
			self:roleAniStyle(value.otherEffect, value5)
		end

		if value.flyaxe then
			local items = {
				role = self
			}

			table.merge(items, value.flyaxe)
			self.map:showEffectForName("flyaxe", items)
		end

		if value.targetEffect and number3 then
			local number = main_scene.ground.map:findRole(tonumber(number3), {}, true)

			if number and not role2.die and self:getDis(number) < 10 then
				number:roleAniStyle(value.targetEffect, nil)
			end
		end
	end
end

function role2:showBJ()
	local x2, y2 = self.node:centerPos()
	local value = _get2("pic/bzmir/effect/bjeffect/1.png"):anchor(0.5, 0.5):pos(x2, y2):add2(self.node)

	if value then
		value:setTouchEnabled(false)

		local value2 = _getani2("pic/bzmir/effect/bjeffect/%d.png", 1, 4, 0.1)

		if value2 then
			value2.retain(value2)
			value.runForever(value, cc.Animate:create(value2))
			value:runs({
				cc.DelayTime:create(0.4),
				cc.CallFunc:create(function()
					if value then
						value:removeSelf()

						value = nil
					end
				end)
			})

			self.loops["loop" .. os.time()] = value
		end
	end
end

function role2:addBuff(text)
	if text.buffme then
		net.send({
			CM_SAY
		}, {
			bzmir.mrss .. tostring(text.role.roleid) .. bzmir.hline .. text.style .. bzmir.hline .. tostring(text.dir) .. bzmir.hline .. text.lockid
		})
	else
		net.send({
			CM_SAY
		}, {
			bzmir.mrss .. tostring(text.role.roleid) .. bzmir.hline .. text.style
		})
	end
end

function role2:roleStyle(value2)
	if not main_scene.ground.player then
		return
	end

	local value3 = def.safeZoneNoUseBuff and g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y)

	if value2 and value2.name and not value3 then
		local config = def.role.getConfig("buff")

		if config and config.buff_style then
			local value = config.buff_style[value2.name]

			if value and value.effectType then
				if value.effectType == 0 then
					self:roleNormalStyle(value)
				elseif value.withDir then
					self:roleAniStyle(value, value2.dir, value2.lockid)
				else
					self:roleAniStyle(value, nil, value2.lockid)
				end
			end
		end
	end
end

function role2:struckStyle()
	local infoOwner = main_scene.ground.player

	if infoOwner and infoOwner.info and infoOwner.info.hp.cur / infoOwner.info.hp.max <= 0.2 then
		local value = _get2("pic/bzmir/effect/struck/1.png"):anchor(0.5, 0.5):pos(display.cx, display.cy):add2(main_scene.ground):fit()

		if value then
			value:setTouchEnabled(false)

			local value2 = _getani2("pic/bzmir/effect/struck/%d.png", 1, 5, 0.1)

			if value2 then
				value2:retain()
				value:runForever(cc.Animate:create(value2))
				value:runs({
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function()
						if value then
							value:removeSelf()

							value = nil
						end
					end)
				})
			end
		end

		self.loops["loop" .. os.time()] = value
	end
end

function role2:actBLOODHIT(x2, y2, dir2, value4, value5, callback)
	if main_scene.ui.console.controller.lock then
		local value2
		local value3
		local text = "0"
		local value = main_scene.ui.console.controller.lock.role

		if value and not value.die then
			if callback(main_scene.ground.player, value) > 10 then
				return main_scene.ui:fadeLabel("目标距离太远，无法到达！")
			end

			if g_data.map:isInSafeZone(main_scene.ground.map.mapid, x2, y2) then
				text = "1"
			end

			if value.info then
				local name = value.info:getName() .. "," .. x2 .. "," .. y2 .. ",68," .. text

				def.role.call("@Close2Attack2~" .. name)
			end
		else
			return main_scene.ui:fadeLabel("目标已丢失！")
		end

		self:addAct({
			type = "heavyHit",
			x = x2,
			y = y2,
			dir = dir2
		})
	end
end

function role2:actBLOODHIT2(x2, y2, dir2, value, value2, value3, value4)
	self:addAct({
		type = "heavyHit",
		x = x2,
		y = y2,
		dir = dir2
	})
end

role2.__LC_MAP = {
	white = {
		core = {
			1,
			1,
			1,
			1
		},
		glow = {
			0.7,
			0.82,
			1,
			0.55
		},
		outerGlow = {
			0.45,
			0.55,
			0.9,
			0.1
		},
		atmosphere = {
			0.55,
			0.65,
			1,
			0.08
		},
		afterimage = {
			0.4,
			0.5,
			1,
			0.3
		},
		burstCloud = {
			0.5,
			0.6,
			1,
			0.18
		},
		spark = {
			0.85,
			0.92,
			1
		}
	},
	blue = {
		core = {
			0.65,
			0.88,
			1,
			1
		},
		glow = {
			0.3,
			0.55,
			1,
			0.55
		},
		outerGlow = {
			0.12,
			0.3,
			0.85,
			0.1
		},
		atmosphere = {
			0.25,
			0.45,
			1,
			0.08
		},
		afterimage = {
			0.15,
			0.35,
			1,
			0.3
		},
		burstCloud = {
			0.2,
			0.4,
			1,
			0.18
		},
		spark = {
			0.4,
			0.65,
			1
		}
	},
	red = {
		core = {
			1,
			0.7,
			0.45,
			1
		},
		glow = {
			1,
			0.2,
			0.05,
			0.55
		},
		outerGlow = {
			0.8,
			0.08,
			0,
			0.1
		},
		atmosphere = {
			1,
			0.25,
			0.05,
			0.08
		},
		afterimage = {
			0.8,
			0.1,
			0,
			0.25
		},
		burstCloud = {
			1,
			0.2,
			0.05,
			0.16
		},
		spark = {
			1,
			0.35,
			0.15
		}
	},
	black = {
		core = {
			0.6,
			0.15,
			1,
			1
		},
		glow = {
			0.25,
			0,
			0.5,
			0.6
		},
		outerGlow = {
			0.08,
			0,
			0.15,
			0.15
		},
		atmosphere = {
			0.45,
			0.1,
			0.8,
			0.1
		},
		afterimage = {
			0.25,
			0,
			0.45,
			0.35
		},
		burstCloud = {
			0.4,
			0.08,
			0.7,
			0.18
		},
		voidRim = {
			0.9,
			0.3,
			1,
			0.25
		},
		spark = {
			0.5,
			0.1,
			0.8
		}
	},
	dark = {
		core = {
			0.05,
			0.05,
			0.05,
			1
		},
		glow = {
			0.12,
			0.1,
			0.15,
			0.7
		},
		outerGlow = {
			0.08,
			0.06,
			0.1,
			0.12
		},
		atmosphere = {
			0.1,
			0.08,
			0.12,
			0.08
		},
		afterimage = {
			0.08,
			0.06,
			0.1,
			0.3
		},
		burstCloud = {
			0.1,
			0.08,
			0.12,
			0.16
		},
		spark = {
			0.15,
			0.12,
			0.18
		}
	}
}

function role2:__boltColor()
	return role2.__LC_MAP[self or "white"] or role2.__LC_MAP.white
end

function role2.__genBolt(x2, y2, x3, y3, value3, value4, value5)
	local role3 = {
		{
			x = x2,
			y = y2
		},
		{
			x = x3,
			y = y3
		}
	}
	local value = value3 or 40
	local value2 = value5 or 0.52

	for index2 = 1, value4 or 5 do
		local items = {
			role3[1]
		}

		for index = 1, #role3 - 1 do
			local point2 = role3[index]
			local point = role3[index + 1]
			local x4 = (point2.x + point.x) * 0.5 + (math.random() - 0.5) * value
			local y4 = (point2.y + point.y) * 0.5

			items[#items + 1] = {
				x = x4,
				y = y4
			}
			items[#items + 1] = point
		end

		role3 = items
		value = value * value2
	end

	return role3
end

function role2:__drawBolt(x2, value, value8, value4, value9, value10)
	if not self or not x2 or #x2 < 2 then
		return
	end

	local callback = cc.c4f

	if not callback then
		return
	end

	if value10 and value10 > 0 and value.atmosphere then
		local value2 = value.atmosphere
		local value11 = callback(value2[1], value2[2], value2[3], value2[4])

		for index = 1, #x2 - 1 do
			self:drawSegment(cc.p(x2[index].x, x2[index].y), cc.p(x2[index + 1].x, x2[index + 1].y), value10, value11)
		end
	end

	if value9 and value9 > 0 then
		local value3 = value.outerGlow
		local value12 = callback(value3[1], value3[2], value3[3], value3[4])

		for index2 = 1, #x2 - 1 do
			self:drawSegment(cc.p(x2[index2].x, x2[index2].y), cc.p(x2[index2 + 1].x, x2[index2 + 1].y), value9, value12)
		end
	end

	if value.voidRim then
		local value5 = value.voidRim
		local value13 = (value4 or 8) * 0.65
		local value14 = callback(value5[1], value5[2], value5[3], value5[4])

		for index3 = 1, #x2 - 1 do
			self:drawSegment(cc.p(x2[index3].x, x2[index3].y), cc.p(x2[index3 + 1].x, x2[index3 + 1].y), value13, value14)
		end
	end

	if value4 and value4 > 0 then
		local value6 = value.glow
		local value15 = callback(value6[1], value6[2], value6[3], value6[4])

		for index4 = 1, #x2 - 1 do
			self:drawSegment(cc.p(x2[index4].x, x2[index4].y), cc.p(x2[index4 + 1].x, x2[index4 + 1].y), value4, value15)
		end
	end

	if value8 and value8 > 0 then
		local value7 = value.core
		local value16 = callback(value7[1], value7[2], value7[3], value7[4])

		for index5 = 1, #x2 - 1 do
			self:drawSegment(cc.p(x2[index5].x, x2[index5].y), cc.p(x2[index5 + 1].x, x2[index5 + 1].y), value8, value16)
		end
	end
end

function role2:__drawGroundArc(value18, coreOwner, value)
	if not self then
		return
	end

	local callback = cc.c4f

	if not callback then
		return
	end

	local value2 = value.groundArcCount or 6
	local value10 = value.groundArcHeight or 45
	local value11 = value.groundArcSpread or 28
	local value12 = value.groundArcDisp or 18
	local value13 = value.groundArcIter or 5
	local number = -5

	for index = 1, value2 do
		local value6 = (math.random() - 0.5) * value11 * 0.6
		local value7 = number + (math.random() - 0.5) * 4
		local value3 = value10 * (0.3 + math.random() * 0.7)
		local value14 = index <= value2 * 0.5 and -1 or 1
		local value8 = value3 * (0.6 + math.random() * 0.5) * value14

		if value2 > 2 then
			local value15 = (index - 1) / value2 * math.pi * 2

			value8 = math.cos(value15) * value3 * (0.5 + math.random() * 0.4)
		end

		local x2 = value6 + value8
		local y2 = value7 + value3
		local value16 = role2.__genBolt(value6, value7, x2, y2, value12, value13, 0.5)
		local value4 = 0.4 + math.random() * 0.6
		local value9 = (value.groundArcCoreW or 0.6) * value4
		local value17 = (value.groundArcGlowW or 2.5) * value4
		local value19 = (value.groundArcOuterW or 5) * value4

		role2.__drawBolt(self, value16, coreOwner, value9, value17, 0, 0)

		local value5 = coreOwner.core

		self:drawDot(cc.p(x2, y2), value9 * 1.2, callback(value5[1], value5[2], value5[3], 0.7))
	end
end

function role2:__drawWanderArc(value27, value12, value, value15)
	if not self then
		return
	end

	local callback = cc.c4f

	if not callback then
		return
	end

	local value22 = value.wanderArcCount or 8
	local value13 = value.wanderRadius or 60
	local value14 = value.wanderArcLen or 50
	local value23 = value.wanderArcDisp or 14
	local value24 = value.wanderArcIter or 5
	local value4 = 1 - value15 * value15

	if value4 <= 0.02 then
		return
	end

	for index2 = 1, value22 do
		local value5 = math.random() * math.pi * 2
		local value16 = math.random() * value13
		local value6 = math.cos(value5) * value16
		local value7 = math.sin(value5) * value16 * 0.5 - 5
		local value17 = value5 + (math.random() - 0.5) * math.pi * 1.2
		local value18 = math.random() * value13 * 0.8
		local value8 = math.cos(value17) * value18
		local value9 = math.sin(value17) * value18 * 0.5 - 5
		local value10 = value8 - value6
		local value11 = value9 - value7
		local value19 = math.sqrt(value10 * value10 + value11 * value11)

		if value14 < value19 then
			local value20 = value14 / value19

			value8 = value6 + value10 * value20
			value9 = value7 + value11 * value20
		end

		local x2 = role2.__genBolt(value6, value7, value8, value9, value23, value24, 0.5)
		local value21 = 0.3 + math.random() * 0.5
		local value25 = 0.3 * value21
		local value26 = 1.2 * value21
		local value2 = value12.core
		local value3 = value12.glow

		for index = 1, #x2 - 1 do
			self:drawSegment(cc.p(x2[index].x, x2[index].y), cc.p(x2[index + 1].x, x2[index + 1].y), value26, callback(value3[1], value3[2], value3[3], value3[4] * value4))
			self:drawSegment(cc.p(x2[index].x, x2[index].y), cc.p(x2[index + 1].x, x2[index + 1].y), value25, callback(value2[1], value2[2], value2[3], value2[4] * value4))
		end
	end
end

function role2:__drawBurst(value3, value5, value6)
	if not self then
		return
	end

	local callback = cc.c4f

	if not callback then
		return
	end

	local value7 = value5.burstCloudCount or 2
	local value8 = value5.burstCloudRadius or 28
	local value9 = value5.burstCloudSpreadX or 30
	local value = value3.burstCloud or value3.atmosphere

	if not value then
		return
	end

	local value10 = math.sin(value6 * math.pi)
	local value4 = (1 - value6) * value[4]

	if value4 <= 0.01 then
		return
	end

	for index = 1, value7 do
		local x2 = (index == 1 and -1 or 1) * value9 * math.min(1, value6 * 2.5)
		local y2 = -5 + (math.random() - 0.5) * 6
		local value2 = value8 * value10

		if value2 > 2 then
			self:drawDot(cc.p(x2, y2), value2, callback(value[1], value[2], value[3], value4))
			self:drawDot(cc.p(x2 + (math.random() - 0.5) * 12, y2 + (math.random() - 0.5) * 8), value2 * 0.7, callback(value[1], value[2], value[3], value4 * 0.7))

			for index2 = 1, math.random(2, 3) do
				local x3 = x2 + (math.random() - 0.5) * value2 * 1.5
				local y3 = y2 + (math.random() - 0.5) * value2
				local value11 = x2 + (math.random() - 0.5) * value2 * 1.5
				local value12 = y2 + (math.random() - 0.5) * value2
				local value13 = value4 * 0.6

				self:drawSegment(cc.p(x3, y3), cc.p(value11, value12), 0.4, callback(value3.glow[1], value3.glow[2], value3.glow[3], value13))
			end
		end
	end
end

function role2:__genFullBolt()
	local value = role2.__genBolt(0, self.height, 0, 0, self.displacement, self.iterations, self.shrinkFactor)
	local items = {}
	local value2 = self.branchMaxDepth or 2

	local function callback(self2, depth2, value7)
		if depth2 > value2 then
			return
		end

		local value5 = (self.branchChance or 0.28) * (1 - (depth2 - 1) * 0.35)
		local value6 = (self.branchLength or 0.35) * math.pow(0.55, depth2 - 1)
		local value3 = math.pow(0.5, depth2 - 1)

		for index = 2, #self2 - 2 do
			if value5 > math.random() then
				local point = self2[index]
				local value8 = math.random() > 0.5 and 1 or -1
				local value4 = value7 * value6
				local value9 = (20 + math.random() * 30) * value3
				local value10 = point.x + value8 * value9
				local value11 = point.y - value4 * (0.4 + math.random() * 0.4)
				local value12 = (self.branchDisplacement or 15) * value3
				local value13 = math.max(2, (self.branchIterations or 3) - (depth2 - 1))
				local pts2 = role2.__genBolt(point.x, point.y, value10, value11, value12, value13, 0.5)

				items[#items + 1] = {
					pts = pts2,
					depth = depth2
				}

				if depth2 < value2 and #pts2 > 3 then
					callback(pts2, depth2 + 1, value4)
				end
			end
		end
	end

	callback(value, 1, self.height)

	return value, items
end

return role2
