local magic = import("..common.magic")
local mapDef = import("..map.def")
local ani = import(".ani")
local info = import(".info")
local role = class("role")
local __position = cc.Node.setPosition

table.merge(role, {
	isUnderOtherRole
})

function role:ctor(params)
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
	self.shield = nil
	self.sounds = {}
	self.filters = {}
	self.acts = {}
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
end

function role:initEnd()
end

function role:onEnter()
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
end

function role:uptIsIgnore()
	local isIgnore = not self.isInScreen or self.isUnderOtherRole and not self.die and not self.isMoving and not self.isPlayer

	if isIgnore ~= self.isIgnore then
		self.isIgnore = isIgnore

		self:uptInfoShow()
		self:uptSelfShow()
	end
end

function role:setIsUnderOtherRole(b)
	if self.isUnderOtherRole ~= b then
		self.isUnderOtherRole = b
	end
end

function role:uptInfoShow()
	if self.noInfo or self.isIgnore or self.die then
		self.info:hide()
	else
		self.info:show()
	end
end

function role:uptSelfShow()
	local show = not self.isIgnore

	if show and self.die then
		show = not g_data.setting.base.hideCorpse
	end

	for k, v in pairs(self.sprites) do
		v:setVisible(show)
	end
end

function role:clearLock()
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
	end
end

function role:getDis(other)
	local x = math.abs(self.x - other.x)
	local y = math.abs(self.y - other.y)

	return math.sqrt(x * x + y * y)
end

function role:getRace()
	return self.feature:get("race")
end

function role:getAppr()
	return self.feature:get("dress")
end

function role:getWeapon()
	return self.feature:get("weapon")
end

function role:openFilter(name)
	if not self.filters[name] then
		self.filters[name] = true

		self:checkFilter()
	end
end

function role:closeFilter(name)
	if self.filters[name] then
		self.filters[name] = nil

		self:checkFilter()
	end
end

function role:checkFilter()
	if table.nums(self.filters) == 0 then
		for k, v in pairs(self.sprites) do
			v.spr:clearFilter()
		end

		return
	end

	local f = nil

	if self.filters.die or self.filters.gray then
		f = res.getFilter("gray")
	elseif self.filters.outline then
		f = res.getFilter("outline_role")
	end

	if f then
		for k, v in pairs(self.sprites) do
			v.spr:setFilter(f)
		end
	end
end

function role:getParts(feature)
	return {}, 0
end

function role:changeFeature(newFeature, force)
	if type(newFeature) == "number" then
		newFeature = def.role.makeTFeature(newFeature)
	end

	local diff = false

	for k, v in pairs(self.feature) do
		if type(v) == "number" and v ~= newFeature[k] then
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

function role:updateSpriteForState(type, sprite)
	local function update(t, spr)
		local state = self.last.state
		local hasColor = nil

		if def.role.stateHas(state, "stPoisonStone") then
			self:openFilter("gray")
		else
			self:closeFilter("gray")

			if def.role.stateHas(state, "stPoisonFuchsia") then
				spr:setColor(cc.c3b(255, 60, 255))

				hasColor = true
			end

			if def.role.stateHas(state, "stPoisonGreen") and (t == "dress" or t == "hair") then
				spr:setColor(display.COLOR_GREEN)

				hasColor = true
			end

			if def.role.stateHas(state, "stPoisonRed") and (t == "dress" or t == "hair") then
				spr:setColor(display.COLOR_RED)

				hasColor = true
			end
		end

		if not hasColor then
			spr:setColor(display.COLOR_WHITE)
		end

		if def.role.stateHas(state, "stHidden") then
			spr:opacity(128)
		else
			spr:opacity(255)
		end

		if def.role.stateHas(state, "stMagicShield") then
			if not self.shield then
				self.shield = m2spr.playAnimation("magic", 3890, 2, 0.15, true):add2(self.node, 2)

				__position(self.shield, 0, mapDef.tile.h)
			end

			self.shield:show()
		elseif self.shield then
			self.shield:hide()
		end
	end

	if type and sprite then
		return update(type, sprite.spr)
	end

	for k, v in pairs(self.sprites) do
		update(k, v.spr)
	end
end

function role:selected()
	if not self.selectedSpr and not WIN32_OPERATE then
		local x, y = self.node:centerPos()
		self.selectedSpr = res.get2("pic/common/selectRole.png"):add2(self.node, -1):pos(x, 15)
	end
end

function role:unselected()
	if not tolua.isnull(self.selectedSpr) then
		self.selectedSpr:removeFromParent()

		self.selectedSpr = nil
	end
end

function role:highLight()
	for _, sprite in pairs(self.sprites) do
		sprite:setFilter(res.getFilter("high_light"))
	end
end

function role:unHighLight()
	for _, sprite in pairs(self.sprites) do
		sprite:clearFilter()
	end
end

function role:getSize()
	if self.parts.dress and self.parts.dress.ani then
		return self.parts.dress.ani:getContentSizeInPixels()
	end

	return self.node:getContentSize()
end

function role:isHeroForPlayer()
	return g_data.hero == self.roleid
end

function role:isLocked()
	if self.lock.execute and self.cur.act and self.cur.act.type == "struck" then
		return false
	end

	return self.lock.execute
end

function role:executeAct()
	self.lock.execute = true
	self.curActEnd = false
	self.cur.act = self.acts[1]
	local act = self.cur.act
	local checkExist = checkExist
	self.last.x = act.x or self.last.x
	self.last.y = act.y or self.last.y
	self.last.dir = act.dir or self.last.dir
	self.last.state = act.state or self.last.state

	if act.type == "state" then
		self:updateSpriteForState()

		return self:executeEnd()
	end

	if checkExist(act.type, "dress", "weapon", "hair", "humEffect") then
		if self.sprites[act.type] then
			self.sprites[act.type]:removeSelf()

			self.sprites[act.type] = nil
		end

		if not act.delete then
			local z = checkExist(act.type, "hair", "humEffect") and 1 or 0
			local spr = ani.new(act, self):addto(self.node, z):pos(0, mapDef.tile.h)
			self.sprites[act.type] = spr

			self:updateSpriteForState(act.type, self.sprites[act.type])

			if self.isIgnore then
				self.sprites[act.type]:hide()
			end
		end

		self:executeSound()

		return self:executeEnd()
	end

	local delay = nil

	if self:isExecuteFast() then
		delay = def.role.speed.fast
	elseif checkExist(act.type, "rushLeft", "rushRight") then
		delay = def.role.speed.rush
	elseif act.type == "rushKung" then
		delay = def.role.speed.rushKung
	elseif checkExist(act.type, "run", "walk", "hit", "spell", "heavyHit", "bigHit") then
		delay = def.role.speed.normal
	elseif act.type == "struck" then
		delay = act.delay
	end

	for k, v in pairs(self.sprites) do
		delay = v:play(act, delay)
	end

	delay = delay or def.role.speed.normal

	if self.sprites.weapon then
		self.sprites.weapon.spr:setLocalZOrder((def.role.dir.rightBottom < act.dir or act.dir == def.role.dir.up) and -1 or 1)
	end

	if not self.isIgnore then
		if act.hitEffect then
			magic.showHitEffect(act.hitEffect.magicId, {
				x = act.x,
				y = act.y,
				dir = act.dir,
				delay = delay,
				type = act.hitEffect.type,
				role = self
			})
		end

		if act.effect then
			magic.showSpellEffect(act.effect.effectID, {
				x = act.x,
				y = act.y,
				delay = delay,
				job = self.job
			})
		end
	end

	if act.flyaxe then
		local params = {
			role = self
		}

		table.merge(params, act.flyaxe)
		self.map:showEffectForName("flyaxe", params)
	end

	if act.otherEffect then
		local begin = nil

		if act.otherEffect.isFixed then
			begin = act.otherEffect.begin
		else
			begin = act.otherEffect.begin + act.dir * (act.otherEffect.frame + act.otherEffect.skip)
		end

		local spr = m2spr.new(nil, nil, {
			blend = true,
			setOffset = true
		}):addto(self.node):pos(0, mapDef.tile.h)

		if act.otherEffect.delayFrame and act.otherEffect.delayMax then
			spr:runs({
				cc.DelayTime:create(delay / act.otherEffect.delayMax * act.otherEffect.delayFrame),
				cc.Show:create(),
				cc.CallFunc:create(function ()
					spr:playAni(act.otherEffect.img, begin, act.otherEffect.frame, delay / act.otherEffect.frame, true, true, true)
				end)
			})
		else
			spr:playAni(act.otherEffect.img, begin, act.otherEffect.frame, delay / act.otherEffect.frame, true, true, true)
		end
	end

	local acttype = act.type

	if acttype == "stand" then
		__position(self.node, self.map:getMapPos(act.x, act.y))
		self:executeEnd()
	elseif acttype == "walk" or acttype == "run" or acttype == "rushLeft" or acttype == "rushRight" then
		local disx = math.abs(self.last.x - act.x)
		local disy = math.abs(self.last.y - act.y)

		if disx <= 2 and disy <= 2 and (disx == disy or disx == 0 or disy == 0) then
			local x, y = self:getPosition()
			local destx, desty = self.map:getMapPos(act.x, act.y)

			self:addAction({
				{
					"moveto",
					delay,
					x,
					y,
					destx,
					desty
				},
				{
					"function",
					handler(self, self.executeEnd)
				}
			})
			self.map:uptRoleXY(self, true)
		else
			act.type = "stand"

			self.node:pos(self.map:getMapPos(act.x, act.y))
			self:executeEnd()
		end
	elseif acttype == "hit" or acttype == "attack" or acttype == "heavyHit" or acttype == "bigHit" then
		self.node:pos(self.map:getMapPos(act.x, act.y))
		self:addAction({
			{
				"delay",
				delay
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	elseif acttype == "rushKung" then
		local x, y = self:getPosition()
		local destx, desty = self.map:getMapPos(act.x, act.y)

		self:addAction({
			{
				"moveto",
				delay / 2,
				x,
				y,
				destx,
				desty
			},
			{
				"moveto",
				delay / 2,
				destx,
				desty,
				x,
				y
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
				delay
			},
			{
				"function",
				function ()
					self.readyRemove = true
				end
			}
		})
	elseif acttype == "spell" and self.isPlayer then
		if act.x and act.y then
			self.node:pos(self.map:getMapPos(act.x, act.y))
		end

		self:addAction({
			{
				"delay",
				delay
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	elseif acttype == "struck" then
		self:addAction({
			{
				"delay",
				delay
			},
			{
				"function",
				function ()
					if act == self.cur.act and self.cur.act.type == "struck" then
						self:executeEnd()
					end
				end
			}
		})
	else
		if act.x and act.y then
			__position(self.node, self.map:getMapPos(act.x, act.y))
		end

		self:addAction({
			{
				"delay",
				delay
			},
			{
				"function",
				handler(self, self.executeEnd)
			}
		})
	end

	self:executeSound(delay)
end

function role:addAction(params)
	self.actions = params
	self.actionsCache = {}
end

function role:executeActions(dt)
	local v = self.actions[1]

	if v[1] == "moveto" then
		local delay = v[2]
		local x = v[3]
		local y = v[4]
		local destx = v[5]
		local desty = v[6]
		self.actionsCache.dt = (self.actionsCache.dt or 0) + dt
		self.isMoving = true
		local cur = self.actionsCache.dt

		if delay <= cur then
			self.isMoving = false

			self.node:pos(destx, desty)

			self.actionsCache = {}

			table.remove(self.actions, 1)

			if #self.actions > 0 then
				self:executeActions(cur - delay)
			end
		else
			self.actionsCache.speed = self.actionsCache.speed or {
				(destx - x) / delay,
				(desty - y) / delay
			}

			__position(self.node, x + self.actionsCache.dt * self.actionsCache.speed[1], y + self.actionsCache.dt * self.actionsCache.speed[2])
		end
	elseif v[1] == "delay" then
		local delay = v[2]
		self.actionsCache.dt = (self.actionsCache.dt or 0) + dt
		local cur = self.actionsCache.dt

		if delay <= cur then
			self.actionsCache = {}

			table.remove(self.actions, 1)

			if #self.actions > 0 then
				self:executeActions(cur - delay)
			end
		end
	elseif v[1] == "function" then
		table.remove(self.actions, 1)
		v[2]()
	end
end

function role:isExecuteFast()
	return #self.acts > 1
end

function role:executeSound(delay)
	local act = self.cur.act

	if not act then
		return
	end

	if self.isPlayer and checkExist(act.type, "walk", "run", "rushLeft", "rushRight", "rushKung") then
		sound.play("footStep", {
			role = self,
			map = self.map,
			delay = delay
		})

		return
	end

	if self.__cname == "npc" then
		-- Nothing
	elseif self.__cname == "mon" then
		sound.play("mon", {
			role = self,
			act = act,
			map = self.map
		})
	elseif self.__cname == "hero" and not self.isIgnore then
		if act.type == "hit" or act.type == "heavyHit" or act.type == "bigHit" then
			sound.play("hit", {
				role = self,
				effect = act.hitEffect,
				delay = delay
			})
		elseif act.type == "hited" then
			sound.play("hited", {
				role = self,
				delay = delay
			})
		elseif act.type == "spell" and act.effect then
			sound.play("skillSpell", {
				role = self,
				magicId = act.effect.magicId
			})
		end
	end
end

function role:spellDone()
	if not main_scene then
		return
	end

	local controller = main_scene.ui.console.controller
	local map = main_scene.ground.map

	if controller.stopAttack then
		controller.stopAttack = false
	end
end

function role:executeEnd(act)
	self.curActEnd = true

	if #self.waits > 0 then
		return
	end

	self.actions = nil
	self.lock.execute = false
	self.last.act = act or self.cur.act
	self.cur.act = nil

	table.remove(self.acts, 1)
	self.map:uptRoleXY(self, false, self.last.x, self.last.y)

	if self.isPlayer then
		if #self.acts > 0 then
			self:executeAct()
		end

		if self.last.act and (self.last.act.type == "spell" or self.last.act.type == "state") then
			self:spellDone()
		end
	elseif #self.acts == 0 and not self.isExecuteEnd then
		self:allExecuteEnd()
	end
end

function role:allExecuteEnd()
	self.isExecuteEnd = true

	self:addStandAct()
end

function role:executeFail(x, y, dir)
	local act = nil

	if #self.waits > 0 then
		act = self.waits[1]
		self.dir = dir or act.wait.dir or self.dir
		self.y = y or act.wait.y or self.y
		self.x = x or act.wait.x or self.x
		self.waits = {}
	end

	for k, v in pairs(self.parts) do
		if v.ani then
			v.ani:play("stand", self.dir)
		end
	end

	self.node:stopAllActions()
	self.node:pos(self.map:getMapPos(self.x, self.y))
	self:executeEnd(act)
end

function role:executeSuccess()
	local act = self.waits[1]

	if act and act.type == "hit" then
		self.hitStatus = def.role.EHitStatus.hit
	elseif act and act.type == "stand" then
		self.hitStatus = def.role.EHitStatus.stand
	end

	table.remove(self.waits, 1)

	if self.curActEnd then
		self:executeEnd()
	end
end

function role:addAct(params)
	if self.die and params.type ~= "die" and not params.gutou then
		return
	elseif params.type == "die" and not self.node:isRunning() then
		self:onEnter()
	end

	if self.cur.act and self.cur.act.type == "struck" then
		self:executeEnd()
	elseif params.type == "struck" and #self.acts > 0 then
		-- Nothing
	end

	if params.type == "stand" and self.last.act and self.last.act.type == params.type and self.last.act.dir == params.dir and not params.loadMap and not params.stone then
		return
	end

	local function loadMapTest()
		if self.isPlayer and params.x and params.y then
			if params.type == "walk" or params.type == "run" or params.type == "rushLeft" or params.type == "rushRight" then
				self.map:load(self.x, self.y, params.x - self.x, params.y - self.y)
			elseif self.x ~= params.x or self.y ~= params.y or params.loadMap then
				self.map:load(params.x, params.y)
			end
		end
	end

	loadMapTest()

	params.x = params.x or self.x
	params.y = params.y or self.y
	params.dir = params.dir or self.dir

	if params.wait then
		self.waits[#self.waits + 1] = params
	end

	self.acts[#self.acts + 1] = params
	self.dir = params.dir
	self.x = params.x
	self.y = params.y
	self.isExecuteEnd = false

	if params.type == "die" then
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

function role:addStandAct()
	self.hitStatus = def.role.EHitStatus.stand

	self:addAct({
		type = "stand",
		dir = self.dir,
		x = self.x,
		y = self.y
	})
end

function role:processMsg(ident, x, y, dir, feature, state, params)
	if SM_TURN == ident then
		self.hitStatus = def.role.EHitStatus.stand

		self:addAct({
			type = "stand",
			x = x,
			y = y,
			dir = dir,
			stone = state and def.role.stateHas(state, "stStone")
		})

		if self.__cname == "mon" then
			sound.play("born", self.sounds.born)
		end
	elseif SM_WALK == ident or SM_NPCWALK == ident then
		self.hitStatus = def.role.EHitStatus.walk

		self:addAct({
			type = "walk",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_RUN == ident then
		self.hitStatus = def.role.EHitStatus.run

		self:addAct({
			type = "run",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_BACKSTEP == ident then
		self:addAct({
			type = "walk",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_DEATH == ident then
		self:addAct({
			corpse = true,
			type = "die",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_NOWDEATH == ident then
		self:addAct({
			type = "die",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_HIT == ident then
		self.hitStatus = def.role.EHitStatus.hit

		self:addAct({
			type = self.__cname == "hero" and "hit" or "attack",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_HEAVYHIT == ident then
		self:addAct({
			type = "heavyHit",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_BIGHIT == ident then
		self:addAct({
			type = "bigHit",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_POWERHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "pow",
				magicId = 7
			}
		})
	elseif SM_LONGHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "long",
				magicId = 12
			}
		})
	elseif SM_WIDEHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "wide",
				magicId = 25
			}
		})
	elseif SM_FIREHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "fire",
				magicId = 26
			}
		})
	elseif SM_4FIREHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "fire4",
				magicId = 26
			}
		})
	elseif SM_HERO_LONGHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "twn1",
				magicId = 34
			}
		})
	elseif SM_HERO_LASTHIT == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "twn2",
				magicId = 34
			}
		})
	elseif SM_SWORD_HIT == ident then
		self:addAct({
			type = "bigHit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "sword",
				effectID = 75,
				magicId = 58
			}
		})
	elseif SM_RUSH == ident then
		self:addAct({
			type = self.lastRushLeft and "rushRight" or "rushLeft",
			x = x,
			y = y,
			dir = dir
		})

		self.lastRushLeft = not self.lastRushLeft
	elseif SM_RUSHKUNG == ident then
		self:addAct({
			type = "rushKung",
			rushx = x,
			rushy = y,
			dir = dir
		})
	elseif SM_STRUCK == ident then
		if self.isPlayer then
			if self.hitStatus == def.role.EHitStatus.stand then
				local time = socket.gettime()

				if time - self.lastHitedTime > 1 then
					self:addAct({
						delay = 0.22,
						type = "struck",
						hiter = x
					})
					sound.play("hited", {
						role = self
					})

					self.lastHitedTime = time
				end
			end
		else
			local time = socket.gettime()

			if time - self.lastHitedTime > 1 then
				local delay = nil

				if self.hitStatus == def.role.EHitStatus.stand then
					delay = 0.22
				else
					delay = 0.1
				end

				self:addAct({
					type = "struck",
					delay = delay,
					hiter = x
				})
				sound.play("hited", {
					role = self
				})

				self.lastHitedTime = time
			end
		end
	elseif SM_SHOWBODY_EFFECT == ident then
		-- Nothing
	elseif SM_FEATURECHANGED == ident then
		self:changeFeature(feature)
	elseif SM_CHARSTATUSCHANGED == ident then
		self.state = state

		self:addAct({
			type = "state",
			state = self.state
		})
	elseif SM_SKELETON == ident then
		self:addAct({
			dir = 0,
			gutou = true,
			type = "die",
			x = x,
			y = y
		})
	elseif SM_DIGUP == ident then
		self:addAct({
			type = "digup"
		})
		sound.play("appr", self.sounds.appr)
	elseif SM_DIGDOWN == ident then
		self:addAct({
			type = "digdown",
			x = x,
			y = y
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
		self:addAct({
			type = "spacemove",
			x = x,
			y = y,
			dir = dir
		})
	elseif SM_FLYAXE == ident then
		self:addAct({
			type = "attack",
			x = x,
			y = y,
			dir = dir,
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
		-- Nothing
	elseif SM_HEALTHSPELLCHANGED == ident then
		-- Nothing
	elseif SM_UNITEHIT0 == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "zz",
				magicId = 50
			}
		})
	elseif SM_UNITEHIT1 == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "zf",
				magicId = 52
			}
		})
	elseif SM_UNITEHIT2 == ident then
		self:addAct({
			type = "hit",
			x = x,
			y = y,
			dir = dir,
			hitEffect = {
				type = "zd",
				magicId = 51
			}
		})
	else
		print("role未处理: ", ident)
	end

	return self
end

local __getPosition = cc.Node.getPosition

function role:getPosition()
	return __getPosition(self.node)
end

function role:update(dt)
	if not self.isPlayer and not self.lock.execute and #self.acts > 0 then
		self:executeAct()
	end

	if self.actions and #self.actions ~= 0 then
		self:executeActions(dt)
	end

	if self.readyRemove then
		self.map:addMsg({
			remove = true,
			roleid = self.roleid
		})

		return
	end

	local x, y = self:getPosition()
	local lpos = self.last.pos

	if lpos.x ~= x or lpos.y ~= y then
		lpos.x = x
		lpos.y = y

		self.info:uptPos(x, y)

		local _, y = self.map:getGamePos(x, y)

		self.node:setLocalZOrder(y)

		if main_scene and main_scene.ui.panels.minimap then
			main_scene.ui.panels.minimap:pointUpt(self.map, self)
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
end

return role
