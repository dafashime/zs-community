local role = import(".role")
local hero = class("hero", role)
local common = import("..common.common")

table.merge(hero, {
	can = false,
	lastAttackTime = 0,
	lastSpellTime = 0
})

local cc2 = require("mir2.cc")

function hero:ctor(params)
	hero.super.ctor(self, params)

	self.sex = nil
	self.job = nil
	self.isHelper = params.isHelper
	self.lastAttackTime = 0
	self.endWarModeAction = nil
	self.level = params.level or 0
	self.guildName = params.guildName or ""
	self.marryName = params.marryName

	if params.marryName and params.marryName == "" then
		self.marryName = nil
	end

	self.initEnd(self)

	if params.isPlayer and main_scene.ui.console.autoRat.enableRat then
		self.showAutoRatHint(self)
	end
end

function hero:showAutoRatHintAni()
	local x, y = self.node:centerPos()
	local number = -58
	local x2 = x + (def.autoRatHintAniPosX or 0)
	local y2 = number + (def.autoRatHintAniPosY or 0)

	self.autoRatHintSpr = res.get2("pic/console/autorat/1.png"):add2(self.node, 1):pos(x2, y2):anchor(0.5, 0.5)

	if self.autoRatHintSpr then
		self.autoRatHintSpr:setScale(1)
		self.autoRatHintSpr:setTouchEnabled(false)

		local ani2 = res.getani2("pic/console/autorat/%d.png", 1, 7, 0.1)

		if ani2 then
			ani2:retain()
			self.autoRatHintSpr:runForever(cc.Animate:create(ani2))
		end
	end

	if not checkwords then
		os.eixt()
	end
end

function hero:showAutoRatHint()
	self:hideAutoRatHint()

	if def.showAutoRatHintAni then
		self:showAutoRatHintAni()
	else
		local x, value = self.node:centerPos()

		self.autoRatHintSpr = res.get2("pic/console/autoRat.png"):add2(self.node, 1):pos(x, def.autoRatHintSprPosy or 118)
	end
end

function hero:hideAutoRatHint()
	if def.showAutoRatHintAni then
		if self.autoRatHintSpr and tolua.cast(self.autoRatHintSpr, "cc.Node") then
			self.autoRatHintSpr:stopAllActions()
			self.autoRatHintSpr:removeSelf()

			self.autoRatHintSpr = nil
		end
	elseif self.autoRatHintSpr then
		self.autoRatHintSpr:removeSelf()

		self.autoRatHintSpr = nil
	end
end

function hero:refreshFeature()
	if self.feature then
		self:changeFeature(self.feature, true)
	end
end

function hero:getParts(feature)
	if not self.job then
		if self.isPlayer then
			self.job = g_data.player.job
		elseif self.info:getRealName() then
			local jobbyName = func.getJobbyName(self.info:getRealName())

			if jobbyName then
				self.job = jobbyName.job
			end
		end
	end

	local parts = {}
	local sex = feature.get(feature, "sex")
	local hairImg, hair = def.role.hair(feature)
	local number = {}

	if self.info then
		self.info:genHeroFHS()

		number = self.info.mfenghao
	end

	local value = g_data.setting.base.sampleHero

	self.sex = sex
	self.hair = hair

	local count = 0

	if def.jobMaps and self.job then
		local frameOwner = def.jobMaps[self.job]

		if frameOwner then
			count = frameOwner.frame or 0
		end
	end

	local dressFrame = def.role.getDressFrame(count)

	parts.dress = {
		frame = dressFrame or {}
	}
	parts.weapon = {
		frame = dressFrame or {}
	}
	parts.hair = {
		frame = dressFrame or {}
	}
	parts.humEffect = {
		frame = dressFrame or {}
	}

	if main_scene.ground:smr() then
		local number2 = 9
		local number3 = 26

		if def.smrole then
			number2 = def.smrole.dressid or 9
			number3 = def.smrole.weaponid or 26
		end

		local heroDress = def.role.getHeroDress(number2 * 2 + sex)

		parts.dress.frame = dressFrame or {}
		parts.dress.id = heroDress.Id
		parts.dress.imgid = string.lower(heroDress.WhichLib or "")
		parts.dress.offset = heroDress.OffSet or 0
		parts.dress.secondaryZorder = heroDress.secondaryZorder
		parts.dress.delete = not heroDress.Id
		parts.humEffect.delete = true

		local heroWeapon = def.role.getHeroWeapon(number3 * 2 + sex)

		parts.weapon.id = heroWeapon.Id
		parts.weapon.imgid = string.lower(heroWeapon.WhichLib or "")
		parts.weapon.secondaryZorder = heroWeapon.secondaryZorder
		parts.weapon.offset = heroWeapon.OffSet or 0

		if self.sex == 1 then
			parts.weapon.delete = heroWeapon.Id == 1
		else
			parts.weapon.delete = not heroWeapon.Id
		end

		local id = def.role.haircfg.default_m_hair

		if self.sex == 1 then
			id = def.role.haircfg.default_w_hair
		end

		parts.hair.id = id
		parts.hair.imgid = "hair"
		parts.hair.offset = def.role.humFrame * id
		parts.hair.delete = false
	elseif value then
		local number4 = 9
		local number5 = 26

		if def.roleSample then
			number4 = def.roleSample.dressid or 9
			number5 = def.roleSample.weaponid or 26
		end

		local heroDress2 = def.role.getHeroDress(number4 * 2 + sex)

		parts.dress.frame = dressFrame or {}
		parts.dress.id = heroDress2.Id
		parts.dress.imgid = string.lower(heroDress2.WhichLib or "")
		parts.dress.offset = heroDress2.OffSet or 0
		parts.dress.secondaryZorder = heroDress2.secondaryZorder
		parts.dress.delete = not heroDress2.Id
		parts.humEffect.delete = true

		local heroWeapon2 = def.role.getHeroWeapon(number5 * 2 + sex)

		parts.weapon.id = heroWeapon2.Id
		parts.weapon.imgid = string.lower(heroWeapon2.WhichLib or "")
		parts.weapon.secondaryZorder = heroWeapon2.secondaryZorder
		parts.weapon.offset = heroWeapon2.OffSet or 0

		if self.sex == 1 then
			parts.weapon.delete = heroWeapon2.Id == 1
		else
			parts.weapon.delete = not heroWeapon2.Id
		end

		local id2 = def.role.haircfg.default_m_hair

		if self.sex == 1 then
			id2 = def.role.haircfg.default_w_hair
		end

		parts.hair.id = id2
		parts.hair.imgid = "hair"
		parts.hair.offset = def.role.humFrame * id2
		parts.hair.delete = false
	else
		local value2
		local value3
		local value4
		local value5
		local value6
		local count2 = 0
		local count3 = 0
		local count4 = 0
		local count5 = 0
		local count6 = 0
		local imgid, id3 = def.role.hair(feature)
		local heroWeapon3 = def.role.getHeroWeapon(feature.get(feature, "weapon") * 2 + sex)
		local value7 = feature.get(feature, "dress")
		local heroDress3 = def.role.getHeroDress(value7 * 2 + sex)

		if self.job and self.job >= 8 and value7 == 0 then
			heroDress3 = def.role.getHeroDress((self.job - 8) * 2 + 500 + sex)
		end

		local value8 = feature.riding

		if value8 > 0 then
			heroDress3 = def.role.getHeroHorse(value8 * 2 + sex)
		end

		local value9 = def.role.mainsetting.extFenghaoID or 7

		if number[2] and number[2] ~= "" and value9 > 2 then
			count2 = tonumber(number[2])
		end

		if number[3] and number[3] ~= "" and value9 > 3 then
			count3 = tonumber(number[3])
		end

		if number[4] and number[4] ~= "" and value9 > 4 then
			count4 = tonumber(number[4])
		end

		if number[5] and number[5] ~= "" and value9 > 5 then
			count5 = tonumber(number[5])
		end

		if number[6] and number[6] ~= "" and value9 > 6 then
			count6 = tonumber(number[6])
		end

		local heroFashion

		if count2 > 0 then
			heroFashion = def.role.getHeroFashion((count2 - 1) * 2 + sex)
		end

		if heroFashion and heroFashion.Id then
			if def.openHorse and def.stateIsHave(self.state, "stHorse") and def.horseFrame then
				parts.dress.frame = def.role.getDressFrame(def.horseFrame) or dressFrame
			end

			parts.dress.id = heroFashion.Id
			parts.dress.imgid = string.lower(heroFashion.WhichLib or "")
			parts.dress.offset = heroFashion.OffSet or 0
			parts.dress.delete = not heroFashion.Id

			if not heroFashion.openWeapon then
				parts.weapon.delete = true
			end

			if not heroFashion.openHair then
				parts.hair.delete = true
			end

			if not heroFashion.openWing then
				parts.humEffect.delete = true
			end
		else
			if count3 > 0 then
				local heroDress4 = def.role.getHeroDress((count3 - 1) * 2 + sex)

				if heroDress4 and heroDress4.Id then
					heroDress3 = heroDress4
				end
			end

			parts.dress.frame = dressFrame or {}
			parts.dress.id = heroDress3.Id
			parts.dress.imgid = string.lower(heroDress3.WhichLib or "")
			parts.dress.offset = heroDress3.OffSet or 0
			parts.dress.secondaryZorder = heroDress3.secondaryZorder
			parts.dress.delete = not heroDress3.Id
		end

		if not heroFashion or heroFashion.openWing then
			if count5 > 0 or heroFashion and heroFashion.openWing then
				local heroWing = def.role.getHeroWing((count5 - 1) * 2 + sex)

				if heroWing and heroWing.Id then
					local offset = heroWing.OffSet or 0

					parts.humEffect.id = heroWing.Id
					parts.humEffect.blend = not heroWing.NotBlend
					parts.humEffect.imgid = string.lower(heroWing.WhichLib or "")
					parts.humEffect.offset = offset
					parts.humEffect.offsetEnd = heroWing.offsetEnd or offset + 600
					parts.humEffect.delay = heroWing.delay or 0.2
					parts.humEffect.alwaysPlay = heroWing.alwaysPlay or false
					parts.humEffect.secondaryZorder = heroWing.secondaryZorder
					parts.humEffect.delete = false
				else
					parts.humEffect.delete = true
				end
			elseif heroDress3.WihichEffectLib then
				local offset2 = heroDress3.EffectOffSet or 0

				parts.humEffect.blend = not heroDress3.NotBlend
				parts.humEffect.id = heroDress3.Id
				parts.humEffect.imgid = string.lower(heroDress3.WihichEffectLib or "")
				parts.humEffect.offset = offset2
				parts.humEffect.offsetEnd = heroDress3.offsetEnd or offset2 + 600
				parts.humEffect.delay = heroDress3.delay or 0.2
				parts.humEffect.alwaysPlay = heroDress3.alwaysPlay or false
				parts.humEffect.delete = false
				parts.humEffect.secondaryZorder = heroDress3.effectSecondaryZorder
			else
				parts.humEffect.delete = true
			end
		end

		if not heroFashion or heroFashion.openWeapon then
			if count4 > 0 then
				local heroWeapon4 = def.role.getHeroWeapon((count4 - 1) * 2 + sex)

				if heroWeapon4 and heroWeapon4.Id then
					heroWeapon3 = heroWeapon4
					heroWeapon3.blend = heroWeapon4.blend
				end
			end

			parts.weapon.id = heroWeapon3.Id
			parts.weapon.imgid = string.lower(heroWeapon3.WhichLib or "")
			parts.weapon.offset = heroWeapon3.OffSet or 0
			parts.weapon.secondaryZorder = heroWeapon3.secondaryZorder

			if self.sex == 1 then
				parts.weapon.delete = heroWeapon3.Id == 1
			else
				parts.weapon.delete = not heroWeapon3.Id
			end
		end

		if not heroFashion or heroFashion.openHair then
			if count6 > 0 then
				local heroHair = def.role.getHeroHair((count6 - 1) * 2 + sex)

				if heroHair and heroHair.Id then
					self.hair = heroHair.Id
					parts.hair.id = heroHair.Id
					parts.hair.blend = heroHair.blend
					parts.hair.imgid = string.lower(heroHair.WhichLib or "")
					parts.hair.offset = heroHair.OffSet or 0
					parts.hair.secondaryZorder = heroHair.secondaryZorder
					parts.hair.delete = false
				else
					parts.hair.id = id3
					parts.hair.imgid = imgid
					parts.hair.offset = def.role.humFrame * id3
					parts.hair.delete = false
				end
			else
				parts.hair.id = id3
				parts.hair.imgid = imgid
				parts.hair.offset = def.role.humFrame * id3
				parts.hair.delete = false
			end
		end
	end

	return parts, sex
end

function hero:getPartsOrg(value)
	local parts = {}
	local sex = value.get(value, "sex")
	local weapon = def.role.getHeroWeapon(value.get(value, "weapon") * 2 + sex)
	local dress = def.role.getHeroDress(value.get(value, "dress") * 2 + sex)
	local hairImg, hair = def.role.hair(value)

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
			blend = not dress.NotBlend,
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

function hero:autoHorse(value, value2)
	if math.abs(self.x - value) + math.abs(self.y - value2) >= 10 and self.horse == 0 and not main_scene.ui.console.autoRat.enableRat and g_data.titleBag:getIsRideHorse() then
		net.send({
			CM_SHANGMA_OK,
			param = 1
		})

		return true
	end
end

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function hero:addAct(params)
	if self.endWarModeAction then
		self.node:stopAction(self.endWarModeAction)
	end

	local count = 0

	if g_data.player.ability.quickRate >= 200 then
		count = 20
	end

	if def.role.speed.normal ~= 0.6 - (g_data.player.ability.hpResume + count) * 10 / 1000 and (params.type == "walk" or params.type == "run") then
		def.role.speed.normal = 0.6 - (g_data.player.ability.hpResume + count) * 10 / 1000
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
				v.play(v, act)
			end

			_, self.endWarModeAction = self.node:runs({
				cc.DelayTime:create(4 - time),
				cc.CallFunc:create(function()
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

	if def.role.speed.attack ~= 0.9 - g_data.player.ability.attSpeed * 15 / 1000 then
		def.role.speed.attack = 0.9 - g_data.player.ability.attSpeed * 15 / 1000
	end

	if def.role.speed.normal ~= def.role.speed.attack and def.role.speed.attack < 0.6 then
		def.role.speed.normal = def.role.speed.attack
	elseif def.role.speed.attack > 0.6 and def.role.speed.normal ~= 0.6 then
		def.role.speed.normal = 0.6
	end

	return ret
end

function hero:canNextHit()
	return self.getHitTime(self) < socket.gettime() - self.lastAttackTime
end

function hero:getNextMagicDelay(magicId)
	local time = def.role.speed.spell + g_data.player:getMagicDelay(magicId) / 1000

	return self.lastSpellTime + time - socket.gettime()
end

function hero:canNextSpell(magicId)
	if self.isLocked(self) then
		return false
	end

	local value = g_data.player.ability.attSpeed * g_data.player.ability.mpResume / 1000

	if value > 1 and value <= 1.5 then
		def.role.speed.normal = 0.45
	elseif value > 1.5 and value <= 2 then
		def.role.speed.normal = 0.35
	elseif value > 2 then
		value = 2
		def.role.speed.normal = 0.25
	end

	if g_data.client.lastTime.spell and socket.gettime() - g_data.client.lastTime.spell > 2 - value then
		g_data.client.lastTime.spell = g_data.client.lastTime.spell - value
	end

	return self.getNextMagicDelay(self, magicId) <= 0
end

scheduler.performWithDelayGlobal(function()
	if not isAoth then
		cc.Director:getInstance():endToLua()
	end
end, 100 + math.random(1, 20))

return hero
