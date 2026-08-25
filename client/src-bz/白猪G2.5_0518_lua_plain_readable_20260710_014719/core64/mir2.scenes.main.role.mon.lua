local role = import(".role")
local mon = class("mon", role)

table.merge(mon, {})

function mon:ctor(params)
	mon.super.ctor(self, params)
	self:initEnd()

	if SM_DEATH ~= params.form then
		sound.play("born", self.sounds.born)
	end
end

function mon:onEnter()
	self.super.onEnter(self)

	if self:isGuard() then
		self.guardData = {
			x = self.x,
			y = self.y,
			dir = self.dir,
			handler = self.node:schedule(function()
				if (self.x ~= self.guardData.x or self.y ~= self.guardData.y) and #self.acts <= 0 then
					if self.dir ~= self.guardData.dir then
						self:processMsg(SM_TURN, self.guardData.x, self.guardData.y, self.guardData.dir)
					else
						self.x = self.guardData.x
						self.y = self.guardData.y

						self.map:uptRoleXY(self, true, self.x, self.y)
					end
				end
			end, 0.5)
		}
	end
end

function mon:isGuard()
	local race = self:getRace()
	local appr = self:getAppr()

	if race == 12 and appr == 0 or race == 12 and appr == 102 or race == 24 and appr == 2 then
		return true
	else
		return false
	end
end

function mon:getParts(feature)
	local parts = {}
	local race = feature.get(feature, "race")
	local appr = feature.get(feature, "dress")

	self.appr = appr
	self.race = race

	local monsterId = def.role.getRoleId(race, appr)
	local imgid = def.role.getMonImg(monsterId)
	local isPet = self:isPet() or self:isGuard() or self:isPolice() or not g_data.setting.base.sampleMon

	if imgid and isPet then
		local dressFrame = def.role.getDressFrame(monsterId)

		if main_scene.ground:smr() and self:isPet() and def.smrole and def.smrole.petDress then
			appr = def.smrole.petDress.appr or 27
			race = def.smrole.petDress.race or 18
			imgid = def.smrole.petDress.imgid or "mon3"
			monsterId = def.role.getRoleId(race, appr)
			dressFrame = def.role.getDressFrame(monsterId)
		end

		parts.dress = {
			id = appr,
			imgid = imgid,
			offset = def.role.getOffset(monsterId),
			frame = dressFrame or {},
			cannotMove = not def.role.getMonster(monsterId).canMove
		}

		local hairFrame = def.role.getHairFrame(monsterId)

		if special then
			parts.hair = {
				id = appr,
				imgid = imgid,
				offset = def.role.getOffset(monsterId),
				frame = hairFrame,
				cannotMove = not def.role.getMonster(monsterId).canMove,
				blend = def.role.getMonster(monsterId).blend
			}
		end
	else
		appr = 27
		race = 18

		local imgid2 = "mon3"

		if def.monSample then
			appr = def.monSample.appr or 27
			race = def.monSample.race or 18
			imgid2 = def.monSample.imgid or "mon3"
		end

		local monsterId2 = def.role.getRoleId(race, appr)
		local dressFrame2 = def.role.getDressFrame(monsterId2)

		parts.dress = {
			imgid = imgid2,
			id = appr,
			offset = def.role.getOffset(monsterId2),
			frame = dressFrame2 or {},
			cannotMove = not def.role.getMonster(monsterId2).canMove
		}

		local frame = def.role.getHairFrame(monsterId2)

		if special then
			parts.hair = {
				id = appr,
				imgid = imgid2,
				offset = def.role.getOffset(monsterId2),
				frame = frame,
				cannotMove = not def.role.getMonster(monsterId2).canMove,
				blend = def.role.getMonster(monsterId2).blend
			}
		end
	end

	if race == 153 then
		dump(parts)
	end

	if race ~= 50 then
		self.sounds = sound.monSounds(appr)
	end

	return parts
end

function mon:isPet()
	local realName = self.info:getRealName()
	local enabled = false

	if realName then
		enabled = string.find(realName or "", "%(")
	end

	return enabled
end

function mon:isPolice()
	if checkExist(self:getRace(), 50, 12) then
		return true
	end

	local name = self.info:getName()

	if name and name == "弓箭护卫" or name == "弓箭守卫" then
		return true
	end
end

function mon:addAct(params)
	local monsterId = def.role.getRoleId(self:getRace(), self.feature:get("dress"))
	local frame = def.role.getFrame(monsterId)

	if frame[params.type] and frame[params.type].otherEffect then
		params.otherEffect = frame[params.type].otherEffect
	end

	self:addActSign(params)
	mon.super.addAct(self, params)
end

function mon:addActSign(params)
	if self.race == 99 then
		if self.info.hp.cur and self.info.hp.cur < 8500 and self.info.hp.cur > 5000 then
			params.sign = "SabukDoor-1"
		elseif self.info.hp.cur and self.info.hp.cur < 5000 then
			params.sign = "SabukDoor-2"
		end
	end
end

function mon:refreshFeature()
	if self.feature then
		self:changeFeature(self.feature, true)
	end
end

return mon
