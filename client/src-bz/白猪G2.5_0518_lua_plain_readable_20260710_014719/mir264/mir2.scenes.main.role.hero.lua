local hero = require("mir2.scenes.main.role.hero1")
local data = json.decode(g_data.login.verinfo[1].str)

function hero:addAct(params)
	if self.endWarModeAction then
		self.node:stopAction(self.endWarModeAction)
	end

	if def.role.speed.normal ~= 0.6 - g_data.player.ability.hpResume * 10 / 1000 and (params.type == "walk" or params.type == "run") then
		def.role.speed.normal = 0.6 - g_data.player.ability.hpResume * 10 / 1000
	end

	if not Timer then
		Timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(hero.time, 30, false)
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

function hero:time()
	local record = getRecord("TClientMessage", {
		cmd = 29,
		sign = net.SEGMENTATION_IDENT,
		dataIndex = socket.gettime()
	})

	net.server:send(record.encode(record))
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

	print("12222221")

	return ret
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

return hero
