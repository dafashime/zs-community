local ani = class("role.ani", function (act)
	return m2spr.new(nil, nil, {
		setOffset = true
	})
end)

table.merge(ani, {})

function ani:ctor(act, role)
	self.act = act
	self.role = role

	if self.act.alwaysPlay then
		self:playAni(act.imgid, act.offset, act.offsetEnd - act.offset + 1, nil, true, nil, nil, nil, 1)
	end
end

function ani:play(act, delay)
	local actType = act.type
	local dir = act.dir
	local blend = nil
	local mact = self.act

	if mact.alwaysPlay then
		return delay
	end

	local frameKey = actType

	if actType == "rushKung" then
		frameKey = "run"
	elseif actType == "digup" then
		if not mact.frame.digup then
			print("not have digup state")

			return delay
		end

		if mact.frame.digup.fixed then
			dir = 0
		end

		blend = mact.frame.digup.blend
	elseif actType == "digdown" then
		if not mact.frame.digdown then
			print("not have digdown state")

			return delay
		end
	elseif act.stone then
		frameKey = "death"

		if mact.frame.digup and mact.frame.digup.fixed then
			dir = 0

			if 0 then
				-- Nothing
			end
		end
	elseif act.gutou and self.role.__cname == "mon" then
		frameKey = "death"
	end

	local config = mact.frame[frameKey]

	if not config or config.frame == 0 then
		return delay
	end

	delay = delay or config.ftime / 1000 * config.frame

	if self.role.__cname == "npc" then
		dir = dir % mact.direction
	end

	if mact.cannotMove then
		dir = 0
	end

	if act.corpse or act.gutou then
		local begin = mact.offset + config.start + dir * (config.frame + config.skip)

		self:stopAnimation()
		self:setImg(mact.imgid, begin + config.frame - 1, true)
		self:setBlend(mact.blend or blend)

		return 0
	elseif act.stone then
		local begin = mact.offset + config.start + dir * (config.frame + config.skip)

		self:stopAnimation()
		self:setImg(mact.imgid, begin, true)

		return 0
	end

	local signOffset = 0

	if act.sign then
		if act.sign == "SabukDoor-1" and (actType == "stand" or actType == "struck") then
			signOffset = 8
		elseif act.sign == "SabukDoor-2" and (actType == "stand" or actType == "struck") then
			signOffset = 16
		end
	end

	local noForever, aniDelay = nil

	if actType == "stand" then
		aniDelay = 0.3
	else
		aniDelay = delay / config.frame
		noForever = true
	end

	local begin = mact.offset + config.start + dir * (config.frame + config.skip) + signOffset

	if mact.id == 50149 then
		print("------------------begin", dir)
	end
	
	self:playAni(mact.imgid, begin, config.frame, aniDelay, mact.blend or blend, nil, noForever)

	return delay
end

return ani
