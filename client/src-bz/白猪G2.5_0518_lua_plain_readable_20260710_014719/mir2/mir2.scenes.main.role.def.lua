local def = {}

table.merge(def, import(".def.weapon"))
table.merge(def, import(".def.hp"))
table.merge(def, import(".def.state"))

def.humFrame = 600
def.size = {
	w = 50,
	h = 85
}
def.speed = {
	rushKung = 0.3,
	normal = 0.6,
	spell = 0.4,
	rush = 0.3,
	attack = 0.9,
	fast = 0.2
}
def.state = {}
def.dir = {
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
def.namecolorcnt = 9
def.namecolors = {
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
def.config = {}
def.config.dress = json.decode(res.getfile("config/dress.txt"))
def.config.weapon = json.decode(res.getfile("config/weapon.txt"))

function def.dress(dressid)
	return def.config.dress[tostring(dressid)] or {}
end

function def.weapon(weapon)
	return def.config.weapon[tostring(weapon)] or {}
end

function def.hair(feature)
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

function def.makeTFeature(feature)
	return getRecord("TFeature", {
		race = Byte(feature),
		sex = Hibyte(Hiword(feature)) % 2,
		hair = Byte(Hiword(feature)),
		weapon = Hibyte(feature),
		dress = Hiword(feature)
	})
end

function def.getMoveDir(destx, desty, x, y)
	local offX = x - destx
	local offY = y - desty
	local angle = math.atan(offY / offX)

	if angle <= math.pi / 8 and angle > -math.pi / 8 then
		if offX > 0 then
			return def.dir.right
		else
			return def.dir.left
		end
	elseif angle < math.pi * 3 / 8 and angle > math.pi / 8 then
		if offX > 0 then
			return def.dir.rightBottom
		else
			return def.dir.leftUp
		end
	elseif offX == 0 or angle >= math.pi * 3 / 8 or angle < -math.pi * 3 / 8 then
		if offY > 0 then
			return def.dir.bottom
		else
			return def.dir.up
		end
	elseif angle <= -math.pi / 8 and angle > -math.pi * 3 / 8 then
		if offY < 0 then
			return def.dir.rightUp
		else
			return def.dir.leftBottom
		end
	end

	return def.dir.bottom
end

function def.getAttackDir(destx, desty, x, y)
	local disx, disy = math.abs(x - destx), math.abs(y - desty)
	local dir

	if disx <= 1 then
		dir = y < desty and def.dir.up or def.dir.bottom
	elseif x < destx then
		if disy <= 1 then
			dir = def.dir.left
		elseif y < desty then
			dir = def.dir.leftUp
		else
			dir = def.dir.leftBottom
		end
	elseif destx < x then
		if disy <= 1 then
			dir = def.dir.right
		elseif y < desty then
			dir = def.dir.rightUp
		else
			dir = def.dir.rightBottom
		end
	end

	return dir
end

return def
