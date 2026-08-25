local hero = {
	fealty = 0,
	unionState = 0,
	name = "",
	heroType = 0,
	bNoTarget = false,
	roleid = 0,
	unionProgress = 0,
	glory = 0,
	bagSize = 0,
	sex = 0,
	heroRank = 0,
	ability = getRecord("TAbility"),
	ability2 = getRecord("TSub2Ability"),
	ability3 = getRecord("TSub3Ability"),
	magicList = {}
}

function hero:setRoleID(roleid)
	self.roleid = roleid
end

function hero:setNoTarget(b)
	self.bNoTarget = b
end

function hero:setName(name, heroType, heroRank)
	self.name = name
	self.heroType = heroType
	self.heroRank = heroRank
end

function hero:setSex(sex)
	self.sex = sex
end

function hero:setWineExp(cur, next)
	self.wineCurExp = cur
	self.wineNextExp = next
end

function hero:setdrinkDrugStatus(cur, next)
	self.drinkDrugStatusValue = cur
	self.drinkDrugStatusValueNext = next
end

function hero:setdrinkStatus(cur, next)
	self.drinkStatusValue = cur
	self.drinkStatusMaxValue = next
end

function hero:setAbility(msg, buf, bufLen)
	self.job = Byte(msg.param)
	local tmpAll = getRecord("TAllAbility")

	net.record(tmpAll, buf, bufLen)

	for k, v in pairs(self.ability) do
		self.ability:set(k, tmpAll:get(k))
	end

	for k, v in pairs(self.ability2) do
		self.ability2:set(k, tmpAll:get(k))
	end

	for k, v in pairs(self.ability3) do
		self.ability3:set(k, tmpAll:get(k))
	end
end

function hero:setBagSize(bagSize)
	self.bagSize = bagSize
end

function hero:setGloryFealty(glory, fealty)
	self.glory = glory
	self.fealty = fealty
end

function hero:getJobStr()
	if self.job == 0 then
		return "战士"
	elseif self.job == 1 then
		return "法师"
	elseif self.job == 2 then
		return "道士"
	end

	return "刺客"
end

function hero:setMagicList(buf, bufLen)
	self.magicList = {}
	local size = getRecordSize("TNewClientMagic")

	while size <= bufLen do
		self.magicList[#self.magicList + 1], buf, bufLen = net.record("TNewClientMagic", buf, bufLen)
	end
end

function hero:addMagic(buf, bufLen)
	if getRecordSize("TNewClientMagic") <= bufLen then
		self.magicList[#self.magicList + 1] = net.record("TNewClientMagic", buf, bufLen)
	end
end

function hero:setMagicExp(msg, buf, bufLen)
	local magic = nil

	for i, v in ipairs(self.magicList) do
		if v:get("magicId") == msg.recog then
			magic = v

			break
		end
	end

	if not magic then
		return
	end

	if bufLen < getRecordSize("TClientSkillExp") then
		magic:set("level", msg.param)
		magic:set("curTrain", MakeLong(msg.tag, msg.series))
	else
		local record = getRecord("TClientSkillExp", buf, bufLen)

		magic:set("level", record:get("skillLv"))
		magic:set("curTrain", record:get("curExp"))
		magic:set("maxTrain", record:get("nextExp"))
	end

	return magic
end

function hero:getMagic(magicID)
	for i, v in ipairs(self.magicList) do
		if v:get("magicId") == magicID then
			return v
		end
	end
end

function hero:setUnionState(progress, state)
	self.unionProgress = progress
	self.unionState = state
end

return hero
