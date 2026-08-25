return {
	fealty = 0,
	unionState = 0,
	bNoTarget = false,
	heroType = 0,
	name = "",
	roleid = 0,
	unionProgress = 0,
	glory = 0,
	bagSize = 0,
	sex = 0,
	heroRank = 0,
	ability = getRecord("TAbility"),
	ability2 = getRecord("TSub2Ability"),
	ability3 = getRecord("TSub3Ability"),
	magicList = {},
	setRoleID = function(self, roleid)
		self.roleid = roleid
	end,
	setNoTarget = function(self, b)
		self.bNoTarget = b
	end,
	setName = function(self, name, heroType, heroRank)
		self.name = name
		self.heroType = heroType
		self.heroRank = heroRank
	end,
	setSex = function(self, sex)
		self.sex = sex
	end,
	setWineExp = function(self, cur, next)
		self.wineCurExp = cur
		self.wineNextExp = next
	end,
	setdrinkDrugStatus = function(self, cur, next)
		self.drinkDrugStatusValue = cur
		self.drinkDrugStatusValueNext = next
	end,
	setdrinkStatus = function(self, cur, next)
		self.drinkStatusValue = cur
		self.drinkStatusMaxValue = next
	end,
	setAbility = function(self, msg, buf, bufLen)
		self.job = Byte(msg.param)

		local tmpAll = getRecord("TAllAbility")

		net.record(tmpAll, buf, bufLen)

		for k, v in pairs(self.ability) do
			self.ability:set(k, tmpAll:get(k))
		end

		for k2, v2 in pairs(self.ability2) do
			self.ability2:set(k2, tmpAll:get(k2))
		end

		for k3, v3 in pairs(self.ability3) do
			self.ability3:set(k3, tmpAll:get(k3))
		end
	end,
	setBagSize = function(self, bagSize)
		self.bagSize = bagSize
	end,
	setGloryFealty = function(self, glory, fealty)
		self.glory = glory
		self.fealty = fealty
	end,
	getJobStr = function(jobOwner)
		return def.ccy.getJobName(jobOwner.job)
	end,
	setMagicList = function(self, buf, bufLen)
		self.magicList = {}

		local size = getRecordSize("TNewClientMagic")

		while size <= bufLen do
			self.magicList[#self.magicList + 1], buf, bufLen = net.record("TNewClientMagic", buf, bufLen)
		end
	end,
	addMagic = function(self, buf, bufLen)
		if bufLen >= getRecordSize("TNewClientMagic") then
			self.magicList[#self.magicList + 1] = net.record("TNewClientMagic", buf, bufLen)
		end
	end,
	setMagicExp = function(self, msg, buf, bufLen)
		local magic

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
	end,
	getMagic = function(self, magicID)
		for i, v in ipairs(self.magicList) do
			if v:get("magicId") == magicID then
				return v
			end
		end
	end,
	setUnionState = function(self, progress, state)
		self.unionProgress = progress
		self.unionState = state
	end
}
