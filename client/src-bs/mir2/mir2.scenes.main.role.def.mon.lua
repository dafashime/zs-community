local def = {
	monImgs = {
		[36.0] = "mon36",
		[33.0] = "mon33",
		[37.0] = "mon37",
		[255.0] = "mon38",
		[48.0] = "mon48",
		[254.0] = "mon38",
		[90.0] = "effect",
		[35.0] = "mon35",
		[39.0] = "mon39",
		[30.0] = "dbsj",
		[31.0] = "mon-kulou",
		[32.0] = "mon33",
		[34.0] = "mon34"
	},
	monImgsWithAppr = {
		[142.0] = "mon28"
	}
}

function def.getMonImg(appr)
	local key = math.modf(appr / 10)

	return def.monImgsWithAppr[appr] or def.monImgs[key] or "mon" .. key + 1
end

function def.getMonHitEffect(race, appr)
	if race == 16 then
		return "mon3", 1445, 4, 6
	elseif race == 20 then
		return "mon4", 1800, 7, 3
	elseif race == 21 then
		return "mon4", 1900, 6, 4
	elseif race == 24 then
		return "mon1", 760, 4, 6
	elseif race == 33 then
		return "mon15", 100, 10, 0, true, {
			frame = 5,
			maxFrame = 6
		}
	elseif race == 40 then
		return "mon5", 350, 6, 4
	elseif race == 52 then
		return "mon4", 3590, 6, 4
	elseif race == 53 then
		return "mon3", 3590, 8, 2
	elseif race == 64 then
		return "mon20", 720, 6, 4
	elseif race == 55 or appr == 142 then
		return "mon18", 820, 6, 4, nil, {
			frame = 5,
			maxFrame = 6
		}
	elseif race == 48 or race == 49 then
		return "mon7", 1680, 8, 2
	end
end

function def.getMonDieEffect(race)
	if race == 40 then
		return "mon5", 340, 10, 0, true
	elseif race == 65 then
		return "mon20", 350, 10, 0, true
	elseif race == 66 then
		return "mon20", 1600, 8, 2, true
	elseif race == 67 then
		return "mon20", 1160, 10, 0, false
	elseif race == 68 then
		return "mon20", 1600, 2, 2, true
	end
end

function def.getMonIsCannotMove(race)
	return checkExist(race, 13, 33, 34, 35, 43, 98, 99, 153)
end

function def.getMonDigupAct(race, appr)
	if race == 33 or race == 13 then
		return {
			"walk"
		}
	elseif race == 41 then
		return {
			"death"
		}
	elseif race == 54 or race == 55 then
		return {
			"death"
		}
	elseif race == 47 then
		return {
			"death"
		}
	elseif race == 48 or race == 49 then
		return {
			"death",
			true
		}
	elseif race == 23 then
		return {
			"death",
			true,
			true
		}
	end
end

function def.getMonDigdownAct(race, appr)
	if race == 33 or race == 13 then
		return "death"
	end
end

function def.getMonStone(race)
end

function def.getMonBlend(race)
	if race == 99 then
		return true
	end
end

return def
