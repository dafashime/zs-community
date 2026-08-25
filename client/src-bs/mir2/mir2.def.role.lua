local role = {}

table.merge(role, import(".state"))

role.humFrame = 600
role.size = {
	w = 50,
	h = 85
}
role.speed = {
	rushKung = 0.3,
	normal = 0.6,
	spell = 0.8,
	rush = 0.3,
	attack = 0.9,
	fast = 0.2
}
role.EHitStatus = {
	walk = 2,
	hit = 4,
	none = 0,
	stand = 1,
	run = 3
}
role.state = {}
role.dir = {
	leftBottom = 5,
	up = 0,
	leftUp = 7,
	bottom = 4,
	rightBottom = 3,
	rightUp = 1,
	left = 6,
	right = 2,
	_0 = {
		0,
		-1
	},
	_1 = {
		1,
		-1
	},
	_2 = {
		1,
		0
	},
	_3 = {
		1,
		1
	},
	_4 = {
		0,
		1
	},
	_5 = {
		-1,
		1
	},
	_6 = {
		-1,
		0
	},
	_7 = {
		-1,
		-1
	}
}
role.namecolorcnt = 9
role.namecolors = {
	249,
	216,
	250,
	252,
	253,
	255,
	152,
	149,
	70
}

function role.getConfig(key)
	return parseJson("config/" .. key .. ".json")
end

function role.init()
	role.monster = {}
	role.npc = {}
	role.frame = {}
	role.heroDress = {}
	role.heroWeapon = {}
	role.heroHp = {}

	for _, info in ipairs(role.getConfig("dress")) do
		role.heroDress[info.uid] = info
	end

	for _, info in ipairs(role.getConfig("weapon")) do
		role.heroWeapon[info.Id] = info
	end

	for _, info in ipairs(role.getConfig("hp")) do
		role.heroHp[info.level] = info
	end

	for _, info in ipairs(role.getConfig("monster")) do
		role.monster[info.id] = info
	end

	for _, info in ipairs(role.getConfig("npc")) do
		role.npc[info.id] = info
	end

	for _, info in ipairs(role.getConfig("frame")) do
		if not role.frame[info.id] then
			role.frame[info.id] = {}
		end

		role.frame[info.id][info.state] = info
	end
end

function role.hp2level(hp, job)
	local zstr, dstr, fstr = nil
	local str = ""

	for lv, info in pairs(role.heroHp) do
		if info.z_hp == tonumber(hp) then
			zstr = "Z" .. lv

			if job and job == 0 then
				return zstr
			end
		end

		if info.d_hp == tonumber(hp) then
			dstr = "D" .. lv

			if job and job == 2 then
				return dstr
			end
		end

		if info.f_hp == tonumber(hp) then
			fstr = "M" .. lv

			if job and job == 1 then
				return fstr
			end
		end
	end

	if zstr then
		str = str .. zstr
	end

	if dstr then
		if zstr then
			str = str .. "/"
		end

		str = str .. dstr
	end

	if fstr then
		if dstr or zstr then
			str = str .. "/"
		end

		str = str .. fstr
	end

	if str == "" then
		str = "?"
	end

	return str
end

function role.getHeroDress(dressid)
	return role.heroDress[dressid] or {}
end

function role.getHeroWeapon(weapon)
	return role.heroWeapon[weapon] or {}
end

function role.hair(feature)
	if feature:get("sex") == 0 then
		local hairs = {
			{
				"hair",
				0
			},
			{
				"hair",
				4
			},
			{
				"hair2",
				6
			},
			{
				"hair2",
				7
			},
			{
				"hair2",
				8
			}
		}
		local ret = hairs[feature:get("hair") + 1] or {
			"hair",
			0
		}

		return unpack(ret)
	else
		local hairs = {
			{
				"hair",
				3
			},
			{
				"hair",
				5
			},
			{
				"hair2",
				6
			},
			{
				"hair2",
				7
			}
		}
		local ret = hairs[feature:get("hair") + 1] or {
			"hair",
			0
		}

		return unpack(ret)
	end
end

function role.makeTFeature(feature)
	return getRecord("TFeature", {
		race = Byte(feature),
		sex = Hibyte(Hiword(feature)) % 2,
		hair = Byte(Hiword(feature)),
		weapon = Hibyte(feature),
		dress = Hiword(feature)
	})
end

function role.getMoveDir(destx, desty, x, y)
	local offX = x - destx
	local offY = y - desty
	local angle = math.atan(offY / offX)

	if angle <= math.pi / 8 and angle > -math.pi / 8 then
		if offX > 0 then
			return role.dir.right
		else
			return role.dir.left
		end
	elseif angle < math.pi * 3 / 8 and angle > math.pi / 8 then
		if offX > 0 then
			return role.dir.rightBottom
		else
			return role.dir.leftUp
		end
	elseif offX == 0 or angle >= math.pi * 3 / 8 or angle < -math.pi * 3 / 8 then
		if offY > 0 then
			return role.dir.bottom
		else
			return role.dir.up
		end
	elseif angle <= -math.pi / 8 and angle > -math.pi * 3 / 8 then
		if offY < 0 then
			return role.dir.rightUp
		else
			return role.dir.leftBottom
		end
	end

	return role.dir.bottom
end

function role.getAttackDir(destx, desty, x, y)
	local disx = math.abs(x - destx)
	local disy = math.abs(y - desty)
	local dir = nil

	if disx <= 1 then
		dir = y < desty and role.dir.up or role.dir.bottom
	elseif x < destx then
		if disy <= 1 then
			dir = role.dir.left
		elseif y < desty then
			dir = role.dir.leftUp
		else
			dir = role.dir.leftBottom
		end
	elseif destx < x then
		if disy <= 1 then
			dir = role.dir.right
		elseif y < desty then
			dir = role.dir.rightUp
		else
			dir = role.dir.rightBottom
		end
	end

	return dir
end

function role.getMonster(monsterId)
	if not role.monster[monsterId] then
		p2("error", "monster:" .. monsterId .. " is nil")

		return {}
	end

	return role.monster[monsterId]
end

function role.getOffset(monsterId)
	if not role.monster[monsterId] then
		p2("error", "monster:" .. monsterId .. " is nil")

		return 0
	end

	if not role.monster[monsterId].imgIdx then
		p2("error", "monster:" .. monsterId .. " img offset is nil")

		return 0
	end

	return role.monster[monsterId].imgIdx
end

function role.getMonImg(monsterId)
	if not role.monster[monsterId] then
		p2("error", "monster:" .. monsterId .. " is nil")

		return "?"
	end

	if not role.monster[monsterId].img then
		p2("error", "monster:" .. monsterId .. " img is nil")

		return "?"
	end

	return role.monster[monsterId].img
end

function role.getNpc(npdId)
	if not role.npc[npdId] then
		p2("error", "npc:" .. npdId .. " is nil")

		return {}
	end

	return role.npc[npdId]
end

function role.getNpcOffset(npdId)
	if not role.npc[npdId] then
		p2("error", "npc:" .. npdId .. " is nil")

		return 0
	end

	if not role.npc[npdId].imgIdx then
		p2("error", "npc:" .. npdId .. " img offset is nil")

		return 0
	end

	return role.npc[npdId].imgIdx
end

function role.getRoleId(race, appr)
	return race * 1000 + appr
end

function role.getFrame(roleId)
	if not role.frame[roleId] then
		p2("error", "role:" .. roleId .. " frame config is nil")

		return {}
	end

	return role.frame[roleId]
end

function role.getDressFrame(roleId)
	if not role.frame[roleId] then
		p2("error", "role:" .. roleId .. " frame config is nil")

		return {}
	end

	local dressFrame = {}

	for state, info in pairs(role.frame[roleId]) do
		if info.dress then
			dressFrame[state] = info.dress
		end
	end

	return dressFrame
end

function role.changeStandFrame(roleId, i_type, i_state)
	if i_type == "dress" then
		local info = role.frame[roleId][i_state]

		if info and info.dress then
			role.frame[roleId].stand.dress = role.frame[roleId][i_state].dress
		end
	elseif i_type == "hair" then
		local info = role.frame[roleId][i_state]

		if info and info.hair then
			role.frame[roleId].stand.hair = role.frame[roleId][i_state].hair
		end
	end
end

function role.resetRoleFrame(roleId)
	for _, info in ipairs(role.getConfig("frame")) do
		if info.id == roleId then
			role.frame[info.id][info.state] = info
		end
	end
end

function role.getHairFrame(roleId)
	if not role.frame[roleId] then
		p2("error", "role:" .. roleId .. " frame config is nil")

		return nil
	end

	local hairFrame = nil

	for state, info in pairs(role.frame[roleId]) do
		if info.hair then
			hairFrame = hairFrame or {}
			hairFrame[state] = info.hair
		end
	end

	return hairFrame
end

return role
