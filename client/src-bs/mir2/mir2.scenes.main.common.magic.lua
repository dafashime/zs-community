local mapDef = import("..map.def")
local magic = {
	maxFrame = 10,
	cache = {},
	getEffect = function (id)
		return 
	end
}
local __position = cc.Node.setPosition
magic.showMagic = function (map, role, targetID, x, y, effectID)
	local config = def.magic.getMagicConfig(effectID)
	local magicId = config.uid

	sound.play("skillPlay", {
		magicId = magicId
	})

	if not config.beatenFrame and not config.flyFrame then
		return 
	end

	if effectID == 8 then
		local begin = config.beatenFrame.begin + role.dir*magic.maxFrame*2
		local x, y = map.getMapPos(map, role.x, role.y)
		local spr = m2spr.playAnimation(config.rsc, begin, config.beatenFrame.frame, config.beatenFrame.delay, true, true, true):addto(map.layers.obj, y + mapDef.tile.h)

		__position(spr, x, y + mapDef.tile.h)
	elseif effectID == 7 then
		local power = 4
		local info = def.role.dir["_" .. role.dir]
		local destx = role.x + info[1]*power
		local desty = role.y + info[2]*power
		x, y = map.getMapPos(map, role.x, role.y)
		destx, desty = map.getMapPos(map, destx, desty)

		for i = 1, power, 1 do
			local spr = nil
			spr, ani = m2spr.playAnimation(config.rsc, config.beatenFrame.begin, config.beatenFrame.frame, config.beatenFrame.delay, true)

			spr.addto(spr, map.layers.obj, y + mapDef.tile.h):runs({
				cca.hide(),
				cca.delay((i - 1)*0.1),
				cca.show(),
				cca.moveTo(0.4, cc.p(destx, desty)),
				cca.removeSelf()
			})
			__position(spr, x, y + mapDef.tile.h)
		end
	else
		if effectID == 11 or effectID == 12 then
			if not config.flyFrame then
				return 
			end

			local begin = config.flyFrame.begin + role.dir*magic.maxFrame*2
			local destx, desty = map.getMapPos(map, x, y)
			local x, y = map.getMapPos(map, role.x, role.y)
			local delay_fly = 0.15
			local spr = nil
			spr = m2spr.playAnimation(config.rsc, begin, config.flyFrame.frame, config.flyFrame.delay, true):addto(map.layers.obj, y + mapDef.tile.h):runs({
				cc.MoveTo:create(delay_fly, cc.p(destx, desty + mapDef.tile.h)),
				cc.CallFunc:create(function ()
					sound.play("skillPlay", {
						idx = 3,
						magicId = magicId
					})
					spr:removeSelf()

					local spr, ani = m2spr.playAnimation(config.rsc, config.beatenFrame.begin, config.beatenFrame.frame, config.beatenFrame.delay, true, true, true)
					local desty = desty + mapDef.tile.h

					spr.addto(spr, map.layers.obj, desty)
					__position(spr, destx, desty)

					return 
				end)
			})

			__position(spr, x, y + mapDef.tile.h)

			return 
		end

		if effectID == 1 or effectID == 3 or effectID == 10 or effectID == 17 or effectID == 39 or effectID == 63 or effectID == 100 or effectID == 101 then
			if not config.flyFrame then
				return 
			end

			local begin = config.flyFrame.begin + role.dir*magic.maxFrame*(config.flyFrame.dir or 2)
			local target = nil

			if effectID == 17 then
				target = map.findRoelWithPos(map, x, y)
			else
				target = map.findRole(map, targetID)
			end

			local destx, desty, delay_fly, destMapX, destMapY = nil

			if target then
				destMapY = target.y
				destMapX = target.x
				destx, desty, delay_fly = map.getMapPos(map, destMapX, destMapY)
				delay_fly = 0.3
			else
				local info = def.role.dir["_" .. role.dir]
				destMapY = role.y + info[2]*12
				destMapX = role.x + info[1]*12
				destx, desty = map.getMapPos(map, destMapX, destMapY)
				delay_fly = 1
			end

			local x, y = map.getMapPos(map, role.x, role.y)
			local spr = nil
			spr = m2spr.playAnimation(config.rsc, begin, config.flyFrame.frame, config.flyFrame.delay, true):addto(map.layers.obj, y + mapDef.tile.h):runs({
				cc.MoveTo:create(delay_fly, cc.p(destx, desty)),
				cc.CallFunc:create(function ()
					spr:removeSelf()

					if target and checkMagicLastPlayTime(effectID, x, y) then
						sound.play("skillPlay", {
							idx = 3,
							magicId = magicId
						})

						local spr, ani = m2spr.playAnimation(config.rsc, config.beatenFrame.begin, config.beatenFrame.frame, config.beatenFrame.delay, true, true, true)

						spr.addto(spr, map.layers.obj, desty + mapDef.tile.h)
						__position(spr, destx, desty + mapDef.tile.h)
					end

					return 
				end)
			})

			__position(spr, x, y + mapDef.tile.h)
		else
			if effectID == 35 then
				y = role.y
				x = role.x
			end

			if checkMagicLastPlayTime(effectID, x, y) then
				local mx, my = map.getMapPos(map, x, y)
				local spr, ani = m2spr.playAnimation(config.rsc, config.beatenFrame.begin, config.beatenFrame.frame, config.beatenFrame.delay, true, true, true)

				spr.addto(spr, map.layers.obj, y + mapDef.tile.h)
				__position(spr, mx, my + mapDef.tile.h)

				if tonumber(magicId) == 6 and map.findRole(map, targetID) then
					sound.play("skillPlay", {
						idx = 3,
						magicId = magicId
					})
				end
			end
		end
	end
end
magic.showSpellEffect = function (effectID, params)
	effectID = effectID + 1
	local map = getMap()

	if not map then
		return 
	end

	for _, info in ipairs(def.magic.getConfig("skillMagic")) do
		if effectID == info.effectID then
			if not info.startFrame then
				return 
			end

			local startInfo = nil

			if #info.startFrame == 1 then
				startInfo = info.startFrame[1]
			else
				for _, v in ipairs(info.startFrame) do
					if v.job and params.job and v.job == params.job then
						startInfo = v

						break
					end
				end
			end

			if not startInfo then
				p2("error", "get start effect frame info error")
			end

			local x, y = map.getMapPos(map, params.x, params.y)
			local spr, ani = m2spr.playAnimation(info.rsc, startInfo.begin, startInfo.frame, params.delay/startInfo.frame, true, true, true, nil, nil, params.asyncPriority)

			spr.addto(spr, map.layers.obj, y + mapDef.tile.h)
			__position(spr, x, y + mapDef.tile.h)

			break
		end
	end

	return 
end
magic.showHitEffect = function (imgid, params, hitConfig)
	local map = getMap()

	if not map then
		return 
	end

	if not hitConfig then
		for _, info in ipairs(def.magic.getConfig("skillMagic")) do
			if info.uid == imgid then
				if not info.hitFrame then
					return 
				end

				for _, v in ipairs(info.hitFrame) do
					if v.type then
						if v.type == params.type then
							hitConfig = v
							hitConfig.rsc = info.rsc
							hitConfig.otherFrame = info.otherFrame
						end
					else
						hitConfig = v
						hitConfig.rsc = info.rsc
						hitConfig.otherFrame = info.otherFrame
					end
				end

				break
			end
		end

		if not hitConfig then
			return 
		end
	end

	local begin = hitConfig.begin

	if not hitConfig.nodir then
		begin = begin + params.dir*((hitConfig.skip or 0) + hitConfig.frame)
	end

	local x, y = map.getMapPos(map, params.x, params.y)
	local spr = nil
	spr = m2spr.playAnimation(hitConfig.rsc, begin, hitConfig.frame, hitConfig.delay or params.delay/hitConfig.frame, true, false, true, function ()
		spr:removeSelf()

		if hitConfig.next then
			if not hitConfig.otherFrame then
				p2("error", "otherFrame is null next frame can not find")

				return 
			end

			for _, v in ipairs(info.otherFrame) do
				if v.name == hitConfig.next then
					v.rsc = hitConfig.rsc
					v.otherFrame = hitConfig.otherFrame

					magic.showHitEffect(imgid, params, v)

					break
				end
			end
		end

		return 
	end, nil, params.asyncPriority):addto(map.layers.obj, y + mapDef.tile.h)

	__position(spr, x, y + mapDef.tile.h)

	return 
end
magic.showWithName = function (map, name, params)
	for _, info in ipairs(def.magic.getConfig("mapMagic")) do
		if info.name == name and (not info.byRace or info.byRace == params.role:getRace()) then
			if info.sound then
				sound.playSound(tostring(info.sound))
			end

			if info.playType == 1 then
				local role = map.findRole(map, params.roleid)

				if not role then
					return 
				end

				if not checkMagicLastPlayTime(info.name, role.x, role.y) then
					return 
				end

				params.y = role.y
				params.x = role.x
			elseif info.playType == 2 then
				if not info.skip then
					p2("show map magic " .. info.name .. " not find key skip")
				end

				local begin = info.rscIdx + (info.frame + info.skip)*params.role.dir*2
				local x, y = map.getMapPos(map, params.role.x, params.role.y)
				local destx, desty = map.getMapPos(map, params.x, params.y)
				local spr = nil
				spr = m2spr.playAnimation(info.rsc, begin, info.frame, info.delay, not info.noBlend):addto(map.layers.obj, y + mapDef.tile.h):runs({
					cc.MoveTo:create(0.2, cc.p(destx, desty + mapDef.tile.h)),
					cca.removeSelf()
				})

				__position(spr, x, y + mapDef.tile.h)

				return 
			elseif info.playType == 3 then
				local role = map.findRole(map, params.roleid)

				if not role then
					return 
				end

				local x, y = map.getMapPos(map, params.x, params.y)
				local begin = info.rscIdx + role.dir*10
				local spr = nil
				spr = m2spr.playAnimation(info.rsc, begin, info.frame, info.delay, not info.noBlend, nil, true, function ()
					spr:removeSelf()

					if info.next then
						magic:showWithName(map, info.next, params)
					end

					return 
				end):addto(map.layers.obj, y + mapDef.tile.h)

				__position(spr, x, y + mapDef.tile.h)

				return 
			end

			local x, y = map.getMapPos(map, params.x, params.y)
			local spr = m2spr.playAnimation(info.rsc, info.rscIdx, info.frame, info.delay, not info.noBlend, true, true):addto(map.layers.obj, y + mapDef.tile.h)

			__position(spr, x, y + mapDef.tile.h)

			return 
		end
	end

	return 
end
local lastTimes = {}

function checkMagicLastPlayTime(effectID, x, y)
	local key = effectID .. "-" .. x .. "-" .. y
	local current = socket.gettime()
	local last = lastTimes[key]
	lastTimes[key] = current

	return not last or 0.3 < current - last
end

function getMap()
	if not main_scene then
		return 
	end

	return main_scene.ground.map
end

return magic
