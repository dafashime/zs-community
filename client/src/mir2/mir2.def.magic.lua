local magic = {}

function magic.getConfig(key)
	if not magic[key] then
		magic[key] = parseJson("config/" .. key .. ".json")
	end

	return magic[key]
end

function magic.getMagicConfig(effectID)
	for _, info in ipairs(magic.getConfig("skillMagic")) do
		if info.effectID == tonumber(effectID) then
			return info
		end
	end
end

function magic.getMagicConfigByUid(magicId)
	for _, info in ipairs(magic.getConfig("skillMagic")) do
		if info.uid == tonumber(magicId) then
			return info
		end
	end
end

function magic.getMagicIds(job, isHero)
	local ret = {}

	for _, info in ipairs(magic.getConfig("skillMagic")) do
		local verAllow = true

		if info.version then
			verAllow = false

			for _, version in ipairs(info.version) do
				if tostring(version) == tostring(def.gameVersionType) then
					verAllow = true
				end
			end
		end

		if info.job and info.job == job and verAllow then
			table.insert(ret, info.uid)
		end
	end

	return ret
end

return magic
