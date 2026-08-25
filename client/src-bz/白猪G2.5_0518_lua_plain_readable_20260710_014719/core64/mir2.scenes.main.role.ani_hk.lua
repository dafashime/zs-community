local cc2 = require("mir2.cc")
local def2 = import("..map.def")
local value = cc.Node.setPosition
local ani = class("role.ani", function(value2, value3, useColor)
	return m2spr.new(nil, nil, {
		setOffset = true,
		useColor = useColor
	})
end)

local function callback(self)
	if self and self.magicId and def.SPELL_ANI then
		return def.SPELL_ANI[self.magicId]
	end

	return ""
end

local function callback2(self)
	if def.SPELL_ANI and def.SPELL_ANI[self] then
		return def.SPELL_ANI[self]
	end

	return "spell"
end

table.merge(ani, {})

function ani:ctor(act, role)
	self.act = act
	self.role = role

	if self.act.alwaysPlay then
		self:playAni(act.imgid, act.offset, act.offsetEnd - act.offset + 1, nil, true, nil, nil, nil, 1)
	end
end

function ani:play(act, delay, value2)
	local actType = act.type
	local dir = act.dir
	local blend
	local mact = self.act

	mact.ani = nil

	if mact.alwaysPlay then
		return delay
	end

	local frameKey = actType

	if actType == "rushKung" then
		frameKey = "run"
	elseif actType == "digup" then
		if not mact.frame.digup then
			return delay
		end

		if mact.frame.digup.fixed then
			dir = 0
		end

		blend = mact.frame.digup.blend
	elseif actType == "digdown" then
		if not mact.frame.digdown then
			return delay
		end
	elseif act.stone then
		frameKey = "death"

		if mact.frame.digup and mact.frame.digup.fixed then
			dir = 0
		end
	elseif act.gutou and self.role.__cname == "mon" then
		frameKey = "death"
	end

	local config
	local count = 0
	local value3 = main_scene.ground.player

	if mact.flyaxe and frameKey == "attack" then
		-- block empty
	elseif frameKey == "spell" then
		if act.effect and act.effect.magicId then
			config = mact.frame[callback2(act.effect.magicId) or ""]

			if def.SPELL_OftIMES then
				count = def.SPELL_OftIMES[act.effect.magicId] or 0
			end
		end
	elseif value3 and frameKey == "walk" then
		local value4 = self.role.state

		if def.stateIsHave(value4, "stHorse") and def.openHorse then
			mact.ani = "walk"

			sound.playSound("mazou")
		else
			mact.ani = "walk"
		end
	elseif value3 and frameKey == "run" then
		local value5 = self.role.state

		if def.stateIsHave(value5, "stHorse") and def.openHorse then
			mact.ani = "run"

			sound.playSound("mapao")
		else
			mact.ani = "run"
		end
	elseif value3 and frameKey == "stand" then
		local value6 = self.role.state

		if def.stateIsHave(value6, "stHorse") and def.openHorse then
			mact.ani = "stand"
		else
			mact.ani = "stand"
		end
	end

	if not config then
		config = mact.frame[mact.ani or ""] or mact.frame[callback(act.hitEffect)] or mact.frame[frameKey]

		if def.SPELL_OftIMES and act.hitEffect and act.hitEffect.magicId then
			count = def.SPELL_OftIMES[act.hitEffect.magicId] or 0
		end
	end

	if not config or config.frame == 0 then
		return delay
	end

	delay = delay or (config.ftime + count) / 1000 * config.frame

	if self.role.__cname == "npc" then
		dir = dir % mact.direction

		if mact.type == "die" or config.fixed then
			dir = 0
		end
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
		local begin2 = mact.offset + config.start + dir * (config.frame + config.skip)

		self:stopAnimation()
		self:setImg(mact.imgid, begin2, true)

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

	local noForever
	local aniDelay

	if actType == "stand" then
		aniDelay = 0.3

		if def.openFrameFtime and config.ftime and config.ftime > 0 then
			aniDelay = config.ftime / 1000
		end

		if config.fixed == true then
			dir = 0
		end
	else
		aniDelay = delay / config.frame
		noForever = true
	end

	local begin3 = mact.offset + config.start + dir * (config.frame + config.skip) + signOffset

	if mact.id == 50149 then
		print("------------------begin", dir)
	end

	if not solt0190 then
		os.exit()
	end

	local value7 = mact.imgid
	local value8 = config.frame
	local value9 = config.skip
	local value10 = config.start

	if self.role.__cname == "hero" and act.effect and act.effect.magicId and def.ccy.isOpenCSSkill and def.ccy.isOpenCSSkill() then
		local magicConfigByUid = def.magic.getMagicConfigByUid(act.effect.magicId, self.role)

		if magicConfigByUid and magicConfigByUid.actFrame then
			local value11 = self.role.feature:get("sex")
			local text = self.role.job and tostring(self.role.job) or "-1"

			if magicConfigByUid.actFrame[text] then
				local value12 = magicConfigByUid.actFrame[text]
				local value13

				if value2 == "dress" and value12.dress then
					value13 = value12.dress
				elseif value2 == "hair" and value12.hair then
					value13 = value12.hair
				elseif value2 == "weapon" and value12.weapon then
					value13 = value12.weapon
				end

				if value13 then
					value9 = value13.skip or value9
					value8 = value13.frame or value8

					if not value13.rsc and value13.begin > 0 then
						value10 = mact.offset + value13.begin or 0
					elseif value13.rsc then
						local value14 = value13.begin or 0
						local value15 = value13.series or 0
						local value16 = (mact.id - value11) / 2
						local value17 = value13.limit or 9999

						value7 = string.lower(value13.rsc or value7)

						if value17 < value16 then
							local value18, value19 = math.modf(value16 / value17)

							value18 = value19 > 0 and value18 + 1 or value18
							value7 = value18 > 1 and value7 .. value18 or value7
							value16 = math.mod(value16, value17 + 1)
						end

						if value2 == "dress" or value2 == "weapon" then
							value16 = value16 * 2
						end

						value10 = value14 + value16 * value15 + value11 * value15
					end

					begin3 = value10 + dir * (value8 + value9)
					noForever = nil
					self.role.diyActEnd = aniDelay * value8 - aniDelay
				elseif value12.noActHidePart then
					begin3 = 6
					value8 = 1
				end
			end
		end
	end

	self:playAni(value7, begin3, value8, aniDelay, mact.blend or blend, nil, noForever)
	self:playRush(act)

	return delay
end

function ani:playRush(point)
	local value2 = point.type
	local value3 = point.dir
	local value4
	local mact = self.act
	local value5 = self.act.type

	if not value5 or type(value5) ~= "string" then
		return
	end

	if value2 == "rushLeft" or value2 == "rushRight" then
		if not def.shadowRushNeelLevel then
			return
		end

		local frameKey = value2

		if value2 == "rushKung" then
			frameKey = "run"
		end

		local config = mact.frame[frameKey]

		if not config or config.frame == 0 then
			return
		end

		local value6 = mact.offset + config.start + value3 * (config.frame + config.skip)
		local value7 = self.role.rushLevel or 0
		local value8 = def.shadowRushNeelLevel

		if value8 < value7 then
			local value9 = value7 - value8

			if def.maxRushShadows and value9 > def.maxRushShadows then
				value9 = def.maxRushShadows
			end

			local value10 = def.shadowRushOffsets or {
				{
					x = 0,
					y = 0
				},
				{
					x = -45,
					y = 10
				},
				{
					x = -35,
					y = 30
				},
				{
					x = -35,
					y = 50
				},
				{
					x = 0,
					y = 60
				},
				{
					x = 35,
					y = 45
				},
				{
					x = 35,
					y = 30
				},
				{
					x = 35,
					y = 20
				}
			}
			local number

			if value5 == "hair" then
				number = 99999
			elseif value5 == "dress" then
				number = 97777
			elseif value5 == "weapon" then
				number = value3 >= 5 and 95555 or 98888
			elseif value5 == "humEffect" then
				number = value3 >= 3 and value3 <= 5 and 96666 or 99998
			end

			local point2 = value10[value3 + 1]

			for index = 1, value9 do
				local mapPos, mapPos2 = self.role.map:getMapPos(point.x, point.y)
				local number2 = 20

				if index > 1 then
					number2 = 30

					if value3 == 2 or value3 == 6 then
						number2 = number2 + index * 3
					end
				end

				local value11 = index * number2
				local x = mapPos + point2.x + (value3 >= 1 and value3 <= 3 and -value11 or value3 >= 5 and value3 <= 7 and value11 or 0)
				local y = mapPos2 + point2.y + ((value3 <= 1 or value3 == 7) and -value11 or value3 >= 3 and value3 <= 5 and value11 or 0)
				local value12 = m2spr.playAnimation(mact.imgid, value6, value6, 9, mact.blend or value4):pos(x, y):addTo(self.role.map.layers.obj, number)

				value12:runs({
					cc.FadeOut:create(0.7),
					cc.CallFunc:create(function()
						value12:removeSelf()
					end)
				})
			end
		end
	end
end

return ani
