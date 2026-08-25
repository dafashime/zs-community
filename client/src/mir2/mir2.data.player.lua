local player = {
	isTeamLeader = false,
	stamina = 0,
	staminaMax = 0,
	expPoolValue = 0,
	gold = 0,
	IsSplliteItem = false,
	inPileUping = false,
	job = 0,
	initedAbility = false,
	vitality = 0,
	groupEnable = false,
	sex = 0,
	vitaliyitemValue = 0,
	attackMode = "",
	vitalityMax = 0,
	roleid = 0,
	goldNum = {
		point = 0,
		diamond = 0,
		limtGird = 0,
		gird = 0,
		gold = 0,
		silver = 0,
		silverExp = 0
	},
	goldName = {
		point = "",
		diamond = "",
		limtGird = "",
		gird = "",
		gold = "",
		silver = "",
		silverExp = ""
	},
	ability = getRecord("TAbility"),
	ability2 = getRecord("TSub2Ability"),
	ability3 = getRecord("TSub3Ability"),
	magicList = {},
	hitEnables = {
		long = false
	},
	groupMembers = {},
	nearMemInfo = {},
	nearGroupInfo = {},
	guild = {
		isAllowAlly = false,
		memberShowType = false,
		curIndex = 0,
		focusVer = 0,
		allyVer = 0,
		rankName = "",
		isLastAllyPage = false,
		isGetRelationShipInfo = false,
		recruitGuildInfo = "",
		recvAllyVer = 0,
		guildRight = 0,
		heroTeamMember = 0,
		killVer = 0,
		hasGuild = false,
		guildName = "",
		log = {},
		relationShip = {},
		hasAllyList = {}
	},
	slaves = {}
}

function player:setIsSplliting(inSplliting)
	self.IsSplliteItem = inSplliting
end

function player:setIsinPileUping(isinPileUping)
	self.inPileUping = isinPileUping
end

function player:setRoleID(roleid)
	self.roleid = roleid
end

function player:setIdentify(identify)
	self.identify = identify
end

function player:setSex(sex)
	self.sex = sex
end

function player:setWineExp(cur, next)
	self.wineCurExp = cur
	self.wineNextExp = next
end

function player:setdrinkDrugStatus(cur, next)
	self.drinkDrugStatusValue = cur
	self.drinkDrugStatusValueNext = next
end

function player:setdrinkStatus(cur, next)
	self.drinkStatusValue = cur
	self.drinkStatusMaxValue = next
end

function player:setGold(gold)
	self.gold = gold
end

function player:setIngot(gold)
	self.goldNum.gold = gold
end

function player:getIngot()
	return self.goldNum.gold
end

function player:setGird(gold)
	self.goldNum.gird = gold
end

function player:getGird()
	return self.goldNum.gird
end

function player:setLimitGird(gold)
	self.goldNum.limtGird = gold
end

function player:getLimitGird()
	return self.goldNum.limtGird
end

function player:setDiamond(gold)
	self.goldNum.diamond = gold
end

function player:getDiamond()
	return self.goldNum.diamond
end

function player:setSilver(gold)
	self.goldNum.silver = gold
end

function player:getSilver()
	return self.goldNum.silver
end

function player:setCapitalInfo(buf, bufLen)
	local msgCapital = getRecord("TMessageCapitalInfo")

	net.record(msgCapital, buf, bufLen)

	self.goldNum.gold = msgCapital:get("yuanbao")
	self.goldNum.diamond = msgCapital:get("diamon")
	self.goldNum.gird = msgCapital:get("linfu")
	self.goldNum.limtGird = msgCapital:get("limitLf")
	self.goldNum.silver = msgCapital:get("silver")
	self.goldNum.silverExp = msgCapital:get("silverExp")
end

function player:setAbility(msg, buf, bufLen)
	local tmpAll = getRecord("TAllAbility")

	net.record(tmpAll, buf, bufLen)

	self.gold = msg.recog
	self.job = Byte(msg.param)
	self.initedAbility = true

	for k, v in pairs(self.ability) do
		self.ability:set(k, tmpAll:get(k))
	end

	for k, v in pairs(self.ability2) do
		self.ability2:set(k, tmpAll:get(k))
	end

	for k, v in pairs(self.ability3) do
		self.ability3:set(k, tmpAll:get(k))
	end

	print("attackLuck ", tmpAll:get("attackLuck"))
end

function player:setStamina(cur, max)
	self.stamina = cur or 0
	self.staminaMax = max or 0
end

function player:setVitality(cur, max)
	self.vitality = cur or 0
	self.vitalityMax = max or 0
end

function player:setExpPoolValue(cur)
	self.expPoolValue = cur or 0
end

function player:setVitaliyitemValue(cur)
	self.vitaliyitemValue = cur or 0
end

function player:getJobStr()
	if self.job == 0 then
		return "战士"
	elseif self.job == 1 then
		return "法师"
	elseif self.job == 2 then
		return "道士"
	end

	return "刺客"
end

function player:getOtherJobStr(job)
	if job == 0 then
		return "战士"
	elseif job == 1 then
		return "法师"
	elseif job == 2 then
		return "道士"
	end

	return "刺客"
end

function player:setAttackMode(mode)
	self.attackMode = mode
end

function player:setHitEnable(key, value)
	self.hitEnables[key] = value
end

function player:setIsUnlimitedMove(b)
	self.isUnlimitedMove = b
end

function player:setMagicList(buf, bufLen)
	self.magicList = {}
	local size = getRecordSize("TNewClientMagic")

	while size <= bufLen do
		self.magicList[#self.magicList + 1], buf, bufLen = net.record("TNewClientMagic", buf, bufLen)
	end

	if WIN32_OPERATE then
		g_data.hotKey:loadMagicHotKey()
	end
end

function player:getMagicDelay(magicId)
	for k, v in pairs(self.magicList) do
		if v:get("magicId") == magicId then
			return v:get("delayTime")
		end
	end
end

function player:addMagic(buf, bufLen)
	if getRecordSize("TNewClientMagic") <= bufLen then
		local magic = net.record("TNewClientMagic", buf, bufLen)
		self.magicList[#self.magicList + 1] = magic

		return magic
	end
end

function player:setMagicExp(msg, buf, bufLen)
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

		if bufLen == 4 then
			magic:set("maxTrain", net.int(buf, bufLen))
		end
	else
		local record = getRecord("TClientSkillExp", buf, bufLen)

		magic:set("level", record:get("skillLv"))
		magic:set("curTrain", record:get("curExp"))
		magic:set("maxTrain", record:get("nextExp"))
	end

	return magic
end

function player:setMagicKey(magicID, key)
	local changes = {}

	for i, v in ipairs(self.magicList) do
		if v:get("magicId") == magicID then
			v:set("key", key)

			changes[#changes + 1] = v
		elseif v:get("key") == key and key ~= 0 then
			v:set("key", 0)

			changes[#changes + 1] = v
		end
	end

	return changes
end

function player:getMagic(magicID)
	for i, v in ipairs(self.magicList) do
		if v:get("magicId") == magicID then
			return v
		end
	end
end

function player:weightChanged(weight, wearWeight, handWeight)
	self.ability:set("weight", weight)
	self.ability:set("wearWeight", wearWeight)
	self.ability:set("handWeight", handWeight)
end

function player:setAllowGroup(groupEnable)
	self.groupEnable = groupEnable
end

function player:setGroupMembers(list)
	self.groupMembers = {}

	if list then
		for i, v in ipairs(list) do
			if v ~= "" then
				self.groupMembers[#self.groupMembers + 1] = string.sub(v, 2)
			end
		end
	end
end

function player:initGroupMembers(msg, buf, bufLen)
	if msg.recog * getRecordSize("TClientGroupMemInfo") ~= bufLen then
		return
	end

	self.groupMembers = {}
	local mem = nil

	for i = 1, msg.recog do
		mem, buf, bufLen = net.record("TClientGroupMemInfo", buf, bufLen)
		self.groupMembers[#self.groupMembers + 1] = mem

		g_data.mark:addGroup(mem:get("name"))
	end
end

function player:getLeaderName()
	if not self.groupMembers then
		return ""
	end

	for i, v in ipairs(self.groupMembers) do
		if v:get("isCaptain") == 1 then
			return v:get("name")
		end
	end

	return ""
end

function player:setTeamLeader(leader)
	self.isTeamLeader = leader
end

function player:getIsTeamLeader()
	return self.isTeamLeader
end

function player:delGroupMember(buf)
	if not self.groupMembers then
		return
	end

	for i, v in ipairs(self.groupMembers) do
		local name = string.sub(v:get("name"), 2)

		print("name " .. name)

		if name == net.str(buf) then
			table.remove(self.groupMembers, i)

			break
		end
	end
end

function player:initNearPlayer(msg, buf, bufLen)
	self.nearMemInfo = {}

	for i = 1, msg.param do
		self.nearMemInfo[#self.nearMemInfo + 1], buf, bufLen = net.record("TClientNearbyGroupInfo", buf, bufLen)
	end
end

function player:initNearGroup(msg, buf, bufLen)
	self.nearGroupInfo = {}

	for i = 1, msg.param do
		self.nearGroupInfo[#self.nearGroupInfo + 1], buf, bufLen = net.record("TClientNearbyGroupInfo", buf, bufLen)
	end
end

function player:exitGuildSuccess()
	self.guild.info = nil
	self.guild.guildName = ""
	self.guild.rankName = ""
	self.guild.rankList = nil
	self.guild.memberList = {}
	self.guild.guildRight = 0
	self.guild.hasGuild = false
	self.guild.isAllowAlly = false
	self.guild.log = {}
	self.guild.heroTeamMember = 0
	self.guild.relationShip = {}
	self.guild.isGetRelationShipInfo = false
	self.guild.recvAllyVer = 0
	self.guild.allyVer = 0
	self.guild.focusVer = 0
	self.guild.killVer = 0
end

function player:setGuildInfo(guildinfo)
	self.guild.info = guildinfo

	if guildinfo then
		self:setGuildRight(guildinfo:get("conferRight"))

		local value = ycFunction:band(def.guild.guildFlag.tfAllowAlly, self.guild.info:get("guildFlag"))

		self:setAllowAlly(value == 1)
	end
end

function player:getIsLeader()
	if self.guild.info then
		local value = ycFunction:band(ycFunction:rshift(self.guild.info:get("conferRight"), def.guild.guildPrivilege.gpOwner - 1), 1)

		return value == 1
	end

	print("info is nil")

	return false
end

function player:getIsFirstLeader()
	if self.guild.info then
		local value = ycFunction:band(ycFunction:rshift(self.guild.info:get("conferRight"), def.guild.guildPrivilege.gpFirstOwner - 1), 1)

		return value == 1
	end

	print("info is nil")

	return false
end

function player:getDisTime(timeNow, timeLocal)
	timeLocal = timeLocal or math.floor(self.guild.info:get("gsTime"):double())
	local disTime = math.floor(timeLocal - timeNow)

	if disTime < 1 then
		return "1天内"
	elseif disTime >= 14 then
		return "14天前"
	else
		return disTime .. "天前"
	end
end

function player:setGuildName(guildName)
	self.guild.guildName = guildName

	self:setHasGuild(string.length(guildName) > 0)
end

function player:getGuildName()
	if self.guild.info then
		return self.guild.info:get("gName")
	else
		return ""
	end
end

function player:setHasGuild(hasGuild)
	self.guild.hasGuild = hasGuild
end

function player:getHasGuild()
	return self.guild.hasGuild
end

function player:setAllowAlly(isAllowAlly)
	self.guild.isAllowAlly = isAllowAlly
end

function player:getAllowAlly()
	return self.guild.isAllowAlly
end

function player:parseLog(buf, bufLen, type)
	local ibegin = 1
	local strs = {}

	for i = 1, bufLen do
		if string.byte(buf, i) == 0 and i ~= ibegin then
			local tmpLabel = string.sub(buf, ibegin, i)
			tmpLabel = ycFunction:a2u(tmpLabel, i - ibegin + 1)
			strs[#strs + 1] = tmpLabel
			ibegin = i + 1
		end
	end

	self.guild.log[type] = strs
end

function player:isNeedSendrelationship()
	return isGetRelationShipInfo
end

function player:relationShip(buf, bufLen, type)
	bufLen = bufLen or 0
	local ibegin = 1
	local strs = {}

	for i = 1, bufLen do
		if string.byte(buf, i) == 0 and i ~= ibegin then
			local tmpLabel = string.sub(buf, ibegin, i)
			tmpLabel = ycFunction:a2u(tmpLabel, i - ibegin + 1)
			strs[#strs + 1] = tmpLabel
			ibegin = i + 1
		end
	end

	isGetRelationShipInfo = true
	self.guild.relationShip[type] = strs
end

function player:getRelationShip(type)
	return self.guild.relationShip[type]
end

function player:getLog(type)
	return self.guild.log[type]
end

function player:setHeroTeamMember(shotCode)
	self.guild.heroTeamMember = shotCode
end

function player:getHeroTeamMember()
	return self.guild.heroTeamMember
end

function player:setRankName(rankName)
	self.guild.rankName = rankName
end

function player:getRankName()
	return self.guild.rankName
end

function player:setGuildName(guildName)
	self.guild.guildName = guildName
end

function player:getGuildName()
	return self.guild.guildName
end

function player:setRankList(rankList)
	self.guild.rankList = rankList
end

function player:getRankList()
	return self.guild.rankList
end

function player:getOtherRankName(rankId)
	if not rankId then
		return ""
	end

	for i, v in ipairs(self.guild.rankList) do
		if v:get("rankID") == rankId then
			return v:get("rankName")
		end
	end

	return ""
end

function player:setMemberList(RankKey, memberList)
	if not self.guild.memberList then
		self.guild.memberList = {}
	end

	self.guild.memberList[RankKey] = memberList
end

function player:getMemberList(RankKey)
	if not self.guild.memberList then
		return {}
	end

	return self.guild.memberList[RankKey] or {}
end

function player:DelMember(name)
	for i, v in pairs(self.guild.memberList) do
		for j, value in ipairs(v) do
			if value:get("chrName") == name then
				table.remove(v, j)

				return i
			end
		end
	end
end

function player:updateMemberInfo(member)
	if not self.guild.memberList then
		return
	end

	for i, v in pairs(self.guild.memberList) do
		for j, value in ipairs(v) do
			if value:get("chrName") == member:get("chrName") then
				table.remove(v, j)
			end
		end
	end

	local rankList = self.guild.memberList[member:get("rankID")]

	if not rankList then
		rankList = {}
		self.guild.memberList[member:get("rankID")] = rankList
	end

	rankList[#rankList + 1] = member
end

function player:setGuildInfoText(info)
	print("player:setGuildInfoText")

	info = info or ""
	self.guild.recruitGuildInfo = info
end

function player:getGuildInfoText()
	return self.guild.recruitGuildInfo
end

function player:setAllyVer(value)
	allyVer = value or 0
end

function player:setRecvAllyVer(value)
	recvAllyVer = value or 0
end

function player:setFocusVer(value)
	focusVer = value or 0
end

function player:setKillVer(value)
	killVer = value or 0
end

function player:setMemberShowType(type)
	self.guild.memberShowType = type
end

function player:getMemberShowType()
	return self.guild.memberShowType
end

function player:chargeRight(setType, value)
	return ycFunction:band(ycFunction:rshift(value, setType), 1) == 1
end

function player:AddLshift(a, b, c)
	return ycFunction:bor(a, ycFunction:lshift(b, c))
end

function player:setGuildRight(guildPrivilege)
	if not guildPrivilege then
		return
	end

	print("设置行会权限")

	local tmpGuildPrivilege = def.guild.guildPrivilege
	local tmpGuildRight = 0
	local privilege = {}

	if self:chargeRight(tmpGuildPrivilege.gpOwner - 1, guildPrivilege) then
		privilege = {
			def.guild.guildActiveRight.garChgNotice,
			def.guild.guildActiveRight.garAddMember,
			def.guild.guildActiveRight.garDelMember,
			def.guild.guildActiveRight.garStartKill,
			def.guild.guildActiveRight.garAllyGuild,
			def.guild.guildActiveRight.garMoveRankMember,
			def.guild.guildActiveRight.garCreateRank,
			def.guild.guildActiveRight.garEditRank,
			def.guild.guildActiveRight.garSetFactoryRank,
			def.guild.guildActiveRight.garBuildWeapon,
			def.guild.guildActiveRight.garUpgradeWeapon,
			def.guild.guildActiveRight.garUseWeapon
		}
	else
		if self:chargeRight(tmpGuildPrivilege.gpLeader - 1, guildPrivilege) then
			privilege[#privilege + 1] = def.guild.guildActiveRight.garMoveRankMember
			privilege[#privilege + 1] = def.guild.guildActiveRight.garBuildWeapon
			privilege[#privilege + 1] = def.guild.guildActiveRight.garUpgradeWeapon
			privilege[#privilege + 1] = def.guild.guildActiveRight.garUseWeapon
		end

		if self:chargeRight(tmpGuildPrivilege.gpDomestic - 1, guildPrivilege) then
			privilege[#privilege + 1] = def.guild.guildActiveRight.garAddMember
			privilege[#privilege + 1] = def.guild.guildActiveRight.garDelMember
		end

		if self:chargeRight(tmpGuildPrivilege.gpForeign - 1, guildPrivilege) then
			privilege[#privilege + 1] = def.guild.guildActiveRight.garStartKill
			privilege[#privilege + 1] = def.guild.guildActiveRight.garAllyGuild
		end
	end

	for i = 1, #privilege do
		tmpGuildRight = self:AddLshift(tmpGuildRight, 1, privilege[i])
	end

	self.guild.guildRight = tmpGuildRight
end

function player:hasStartKill()
	return self:chargeRight(def.guild.guildActiveRight.garStartKill, self.guild.guildRight)
end

function player:hasEditRank()
	return self:chargeRight(def.guild.guildActiveRight.garEditRank, self.guild.guildRight)
end

function player:hasMoveRankMember()
	return self:chargeRight(def.guild.guildActiveRight.garMoveRankMember, self.guild.guildRight)
end

function player:hasChangeMember()
	return self:chargeRight(def.guild.guildActiveRight.garAddMember, self.guild.guildRight)
end

function player:hasAllyGuild()
	return self:chargeRight(def.guild.guildActiveRight.garAllyGuild, self.guild.guildRight)
end

function player:initTitle(msg, buf, bufLen)
	if bufLen == 0 then
		return
	end

	local titleInfo = {
		curTitleID = msg.tag == 1 and 0 or msg.param,
		ActorID = msg.recog
	}
	local titleCount = msg.tag
	titleInfo.data = {}

	print("bufLen " .. bufLen .. " TClientTitleInfo " .. getRecordSize("TClientTitleInfo"), " msg.tag " .. msg.tag)

	if msg.tag > 0 then
		for i = 1, msg.tag do
			titleInfo.data[#titleInfo.data + 1], buf, bufLen = net.record("TClientTitleInfo", buf, bufLen)
		end
	end

	self.titleInfo = self.titleInfo or {}

	for i, v in ipairs(self.titleInfo) do
		if v.ActorID == titleInfo.ActorID then
			table.remove(self.titleInfo, i)
		end
	end

	self.titleInfo[#self.titleInfo + 1] = titleInfo
end

function player:setTitleResult(msg)
	if not self.titleInfo or #self.titleInfo == 0 then
		return
	end

	for i, v in ipairs(self.titleInfo) do
		if v.ActorID == self.roleid then
			if msg.tag == 0 then
				v.curTitleID = 0

				break
			end

			v.curTitleID = msg.param

			break
		end
	end
end

function player:updateTitleInfo(msg, buf, bufLen)
	if msg.tag == 0 then
		local title = nil
		title, buf, bufLen = net.record("TClientTitleInfo", buf, bufLen)

		for i, v in ipairs(self.titleInfo) do
			if v.ActorID == self.roleid then
				for j, t in ipairs(v.data) do
					if t:get("ID") == title:get("ID") then
						table.remove(v.data, j)
					end
				end

				v.data[#v.data + 1] = title
			end
		end
	else
		for i, v in ipairs(self.titleInfo) do
			if v.ActorID == self.roleid then
				for j, t in ipairs(v.data) do
					if t:get("ID") == msg.param then
						table.remove(v.data, j)
					end
				end
			end
		end
	end
end

function player:updateTitleCount(msg, buf, bufLen)
	for i, v in ipairs(self.titleInfo) do
		if v.ActorID == self.roleid then
			for j, t in ipairs(v.data) do
				if t:get("ID") == msg.param then
					t:set("UseTimes", msg.tag)
				end
			end
		end
	end
end

function player:addSlave(name)
	table.insert(self.slaves, name)
end

function player:removeSlave(name)
	for k, v in ipairs(self.slaves) do
		if v == name then
			table.remove(self.slaves, k)

			return true
		end
	end

	return false
end

function player:hasSlave(name)
	if not name then
		return #self.slaves > 0
	end

	for k, v in ipairs(self.slaves) do
		if string.find(v, name) then
			return true
		end
	end
end

function player:fixStrLen(text, len)
	local strs = utf8strs(text)

	if len < #strs then
		local ret = ""

		for k = 1, len do
			ret = ret .. strs[k]
		end

		return ret .. "..."
	end

	return text
end

return player
