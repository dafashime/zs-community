local magic = {}

function magic.getConfig(key)
	if not magic[key] then
		magic[key] = def.role.getConfig(key)
	end

	return magic[key]
end

function magic:buildSkillIcon()
	local magicConfigByUid = magic.getMagicConfigByUid(self, main_scene.ground.player) or nil

	if magicConfigByUid then
		if magicConfigByUid.picId then
			self = magicConfigByUid.picId
		elseif magicConfigByUid.name and string.find(magicConfigByUid.name, bzmir.hline) ~= nil then
			self = self .. bzmir.line .. g_data.player.job
		end
	end

	return bzmir.skillicons .. self .. bzmir.ext
end

function magic:checkGroupStyle(value2)
	if value2 and self and value2.magicStyles and def.magicStyles and def.ccy.isOpenCSSkill() then
		value2.info:genHeroFHS()

		for _, magicStyle in ipairs(value2.magicStyles) do
			local value = def.magicStyles[magicStyle]

			if value and value.magicId == self.uid and value.groupId and self["group_" .. value.groupId] then
				local value3 = self["group_" .. value.groupId]
				local info = clone(self)

				info.picId = "g" .. tostring(info.uid) .. bzmir.line .. value.groupId
				info.extName = value.extName or ""
				info.actFrame = value3.actFrame
				info.startFrame = value3.startFrame
				info.beatenFrame = value3.beatenFrame
				info.otherFrame = value3.otherFrame
				info.flyFrame = value3.flyFrame
				info.hitFrame = value3.hitFrame

				if value3.particle then
					info.particle = value3.particle
				end

				return info
			end
		end
	end

	return self
end

function magic.getMagicConfig(effectID, value)
	for _, info in ipairs(magic.getConfig("skillMagic")) do
		if info.effectID == tonumber(effectID) then
			return magic.checkGroupStyle(info, value)
		end
	end
end

function magic.getMagicConfigByUid(magicId, value)
	for _, info in ipairs(magic.getConfig("skillMagic")) do
		if info.uid == tonumber(magicId) then
			return magic.checkGroupStyle(info, value)
		end
	end
end

function magic.getMagicIds(job, isHero)
	local ret = {}

	for _, info in ipairs(magic.getConfig("skillMagic")) do
		local verAllow = true

		if info.version then
			verAllow = false

			for _2, version in ipairs(info.version) do
				if tostring(version) == tostring(def.gameVersionType) then
					verAllow = true
				end
			end
		end

		if info.job and info.job == job and verAllow then
			table.insert(ret, info.uid)
		elseif info.cjob and string.find(info.cjob, tostring(job)) ~= nil and verAllow and not isHero then
			table.insert(ret, info.uid)
		elseif string.find(tostring(info.job), tostring(job)) ~= nil and verAllow and not isHero then
			table.insert(ret, info.uid)
		end
	end

	return ret
end

return magic
