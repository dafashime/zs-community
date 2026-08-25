local role = import(".role")
local hero = class("hero", role)

table.merge(hero, {
	lastAttackTime = 0,
	lastSpellTime = 0
})

function hero:ctor(params)
	hero.super.ctor(self, params)

	self.sex = nil
	self.job = nil
	self.isHelper = params.isHelper
	self.lastAttackTime = 0
	self.endWarModeAction = nil

	self:initEnd()

	if params.isPlayer and main_scene.ui.console.autoRat.enableRat then
		self:showAutoRatHint()
	end
end

function hero:showAutoRatHint()
	if not self.autoRatHintSpr then
		local x, y = self.node:centerPos()
		self.autoRatHintSpr = res.get2("pic/console/autoRat.png"):add2(self.node, 1):pos(x, 108)
	end
end

function hero:hideAutoRatHint()
	if self.autoRatHintSpr then
		self.autoRatHintSpr:removeSelf()

		self.autoRatHintSpr = nil
	end
end

function hero:getParts(feature)
	local parts = {}
	local sex = feature:get("sex")
	local weapon = def.role.getHeroWeapon(feature:get("weapon") * 2 + sex)
	local dress = def.role.getHeroDress(feature:get("dress") * 2 + sex)
	local hairImg, hair = def.role.hair(feature)
	self.sex = sex
	self.hair = hair
	local frame = def.role.getDressFrame(0)
	parts.dress = {
		id = dress.Id,
		imgid = string.lower(dress.WhichLib or ""),
		offset = dress.OffSet,
		frame = frame or {}
	}
	parts.weapon = {
		id = weapon.Id,
		imgid = string.lower(weapon.WhichLib or ""),
		offset = weapon.OffSet,
		frame = frame or {}
	}

	if self.sex == 1 then
		parts.weapon.delete = weapon.Id == 1
	else
		parts.weapon.delete = not weapon.Id
	end

	parts.hair = {
		id = hair,
		imgid = hairImg,
		offset = def.role.humFrame * hair,
		frame = frame or {},
		delete = hair == 0
	}

	if dress.WihichEffectLib then
		parts.humEffect = {
			blend = true,
			id = dress.Id,
			imgid = string.lower(dress.WihichEffectLib or ""),
			offset = dress.EffectOffSet,
			offsetEnd = dress.offsetEnd,
			delay = dress.delay,
			alwaysPlay = dress.alwaysPlay,
			frame = frame
		}
	else
		parts.humEffect = {
			delete = true
		}
	end

	return parts, sex
end

function hero:addAct(params)
	if self.endWarModeAction then
		self.node:stopAction(self.endWarModeAction)
	end

	if params.type == "hit" or params.type == "spell" or params.type == "heavyHit" or params.type == "bigHit" then
		if params.type == "spell" then
			lastSpellTime = socket.gettime()
		end

		self.lastAttackTime = socket.gettime()
	elseif params.type == "die" then
		if self.isPlayer then
			self.map:setGrayState()
			main_scene.ui.console.autoRat:stop()
		end

		if not params.corpse then
			sound.playSound(sound.s_man_die + self.sex)
		end
	end

	hero.super.addAct(self, params)
end

function hero:allExecuteEnd()
	if not self.die and self.last.act then
		local time = socket.gettime() - self.lastAttackTime

		if time < 4 then
			local act = {
				type = "warMode",
				dir = self.last.act.dir or self.dir
			}

			for k, v in pairs(self.sprites) do
				v:play(act)
			end

			_, self.endWarModeAction = self.node:runs({
				cc.DelayTime:create(4 - time),
				cc.CallFunc:create(function ()
					self:addStandAct()

					self.endWarModeAction = nil
				end)
			})
		else
			hero.super.allExecuteEnd(self)
		end
	end

	self.isExecuteEnd = true
end

function hero:getHitTime()
	local hitSpeed = tonumber(avoidPlugValue(self.hitSpeed, true)) or 0
	local ret = math.max(0, def.role.speed.attack - math.min(300, hitSpeed * 60) / 1000)

	return ret
end

function hero:canNextHit()
	return self:getHitTime() < socket.gettime() - self.lastAttackTime
end

function hero:getNextMagicDelay(magicId)
	local time = def.role.speed.spell + g_data.player:getMagicDelay(magicId) / 1000

	return self.lastSpellTime + time - socket.gettime()
end

function hero:canNextSpell(magicId)
	if self:isLocked() then
		return false
	end

	return self:getNextMagicDelay(magicId) <= 0
end

return hero
