local equip = {
	serverUnlockTime = 0,
	isHero = false,
	lockState = 0,
	lockTime = 180000,
	items = {},
	takeOffing = {}
}

function equip:set(buf, bufLen)
	self.items = {}
	self.takeOffing = {}

	while bufLen > 0 do
		local equip = nil
		equip, buf, bufLen = net.record("TClientEquip", buf, bufLen)
		local index = equip:get("nPos")
		self.items[index] = equip:get("cliEquip")

		if self.isHero then
			print(self.items[index].getVar("name"))
		end
	end
end

function equip:upt(buf, bufLen)
	local data = getRecord("TClientItem")

	net.record(data, buf, bufLen)

	for k, v in pairs(self.items) do
		if v:get("makeIndex") == data:get("makeIndex") and v.getVar("name") == data.getVar("name") then
			print("equip:upt ", v.getVar("name"))
			dump(data)

			self.items[k] = data

			return data:get("makeIndex")
		end
	end
end

function equip:isEquipped(equipName)
	for k, v in pairs(self.items) do
		if v.getVar("name") == equipName then
			return true
		end
	end
end

function equip:checkEquips(equipTbl)
	for _, equipName in ipairs(equipTbl) do
		for k, v in pairs(self.items) do
			if v.getVar("name") == equipName then
				return true, v
			end
		end
	end
end

function equip:checkAmulet()
	amuletNames = {
		"护身符",
		"护身符(大)",
		"超级护身符"
	}

	return self:checkEquips(amuletNames)
end

function equip:isBlurryEquipped(itemsName)
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
end

function equip:duraChange(idx, dura, duraMax)
	local item = self.items[tonumber(idx)]

	if item then
		item:set("dura", dura)
		item:set("duraMax", duraMax)
	end
end

function equip:getItem(makeIndex)
	for k, v in pairs(self.items) do
		if makeIndex == v:get("makeIndex") then
			return k, v
		end
	end
end

function equip:delItem(makeIndex)
	for k, v in pairs(self.items) do
		if tonumber(makeIndex) == v:get("makeIndex") then
			self.items[k] = nil

			return true
		end
	end
end

function equip:setItem(where, item)
	self.items[tonumber(where)] = item
end

function equip:takeOff(makeIndex, params)
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
end

function equip:takeOffEnd(isSuccess)
	local ret = nil

	if not isSuccess and self.takeOffing.item then
		self:setItem(self.takeOffing.params.where, self.takeOffing.item)

		ret = self.takeOffing.item:get("makeIndex")
	end

	self.takeOffing = {}

	return ret
end

function equip:setLock(key)
	self.lockState = key
end

function equip:setServerUnlockTime(time)
	self.serverUnlockTime = time
end

return equip
