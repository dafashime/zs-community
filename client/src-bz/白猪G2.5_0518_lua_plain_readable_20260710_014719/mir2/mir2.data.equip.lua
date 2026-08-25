return {
	serverUnlockTime = 0,
	isHero = false,
	lockState = 0,
	lockTime = 180000,
	items = {},
	takeOffing = {},
	set = function(self, buf, bufLen)
		self.items = {}
		self.takeOffing = {}

		while bufLen > 0 do
			local value
			local equip

			equip, buf, bufLen = net.record("TClientEquip", buf, bufLen)

			local index = equip:get("nPos")

			self.items[index] = equip:get("cliEquip")
		end
	end,
	upt = function(self, buf, bufLen)
		local data = getRecord("TClientItem")

		net.record(data, buf, bufLen)

		for k, v in pairs(self.items) do
			if v:get("makeIndex") == data:get("makeIndex") and v.getVar("name") == data.getVar("name") then
				dump(data)

				self.items[k] = data

				return data:get("makeIndex")
			end
		end
	end,
	isEquipped = function(self, equipName)
		for k, v in pairs(self.items) do
			if v.getVar("name") == equipName then
				return true
			end
		end
	end,
	checkEquips = function(self, equipTbl)
		for _, equipName in ipairs(equipTbl) do
			for k, v in pairs(self.items) do
				if v.getVar("name") == equipName then
					return true, v
				end
			end
		end
	end,
	checkAmulet = function(self)
		local equip = {
			"护身符",
			"护身符(大)",
			"超级护身符"
		}

		return self:checkEquips(equip)
	end,
	isBlurryEquipped = function(self, itemsName)
		local names = {}

		if type(itemsName) == "string" then
			names[1] = itemsName
		elseif type(itemsName) == "table" then
			names = itemsName
		end

		for i, name in ipairs(names) do
			if type(name) == "string" then
				for k, v in pairs(self.items) do
					if string.find(v.getVar("name"), name) then
						return true
					end
				end
			end
		end
	end,
	duraChange = function(self, idx, dura, duraMax)
		local item = self.items[tonumber(idx)]

		if item then
			item:set("dura", dura)
			item:set("duraMax", duraMax)
		end
	end,
	getItem = function(self, makeIndex)
		for k, v in pairs(self.items) do
			if makeIndex == v:get("makeIndex") then
				return k, v
			end
		end
	end,
	delItem = function(self, makeIndex)
		for k, v in pairs(self.items) do
			if tonumber(makeIndex) == v:get("makeIndex") then
				self.items[k] = nil

				return true
			end
		end
	end,
	setItem = function(self, where, item)
		self.items[tonumber(where)] = item
	end,
	takeOff = function(self, makeIndex, params)
		if self.takeOffing.item and socket.gettime() - self.takeOffing.time < 5 then
			return
		end

		for k, v in pairs(self.items) do
			if makeIndex == v:get("makeIndex") then
				self.takeOffing.item = v
				self.takeOffing.time = socket.gettime()
				self.takeOffing.params = params
				self.items[k] = nil

				return true
			end
		end
	end,
	takeOffEnd = function(self, isSuccess)
		local ret

		if not isSuccess and self.takeOffing.item then
			self:setItem(self.takeOffing.params.where, self.takeOffing.item)

			ret = self.takeOffing.item:get("makeIndex")
		end

		if self.takeOffing.params.where == 2 then
			local value = main_scene.ground.map

			if value and value.setDark.control and value.opacity > 0 then
				value:addLight2(value.player, "hero", nil)
			end
		end

		self.takeOffing = {}

		return ret
	end,
	setLock = function(self, key)
		self.lockState = key
	end,
	setServerUnlockTime = function(self, time)
		self.serverUnlockTime = time
	end
}
