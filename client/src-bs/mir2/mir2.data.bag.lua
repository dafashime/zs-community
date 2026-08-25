local bag = {
	max = 48,
	isHero = false,
	items = {},
	quickItems = {},
	customs = {},
	throwing = {},
	eat = {},
	take = {},
	split = {},
	fusion = {},
	strengthen = {}
}

function bag:set(buf, bufLen)
	self.items = {}
	self.throwing = {}
	self.eat = {}
	self.take = {}

	self:delAllQuickItem()

	while bufLen > 0 do
		local item = getRecord("TClientItem")
		_, buf, bufLen = net.record(item, buf, bufLen)

		if not self:isInFusion(item) and not self:isInStrengthen(item) then
			self.items[#self.items + 1] = item
		end
	end

	for i, v in pairs(self.quickItems) do
		self:fillQuickItemTest(i)
	end
end

function bag:isInFusion(item)
	for i, v in pairs(self.fusion) do
		if item:get("makeIndex") == v:get("makeIndex") then
			return true
		end
	end

	return false
end

function bag:isInStrengthen(item)
	for i, v in pairs(self.strengthen) do
		if item:get("makeIndex") == v:get("makeIndex") then
			return true
		end
	end

	return false
end

function bag:equipAmulet(force)
	local amuletNames = {
		"护身符"
	}
	local item, where = nil

	for k, am in ipairs(amuletNames) do
		for k, v in pairs(self.items) do
			if string.find(v.getVar("name"), am) then
				item = v
				where = getTakeOnPosition(item.getVar("stdMode"))

				break
			end
		end

		if item then
			break
		end

		for k, v in pairs(self.quickItems) do
			if v.item and am == v.item.getVar("name") then
				item = v
				where = getTakeOnPosition(item.getVar("stdMode"))

				break
			end
		end

		if item then
			break
		end
	end

	if item and self:use("take", item:get("makeIndex"), {
		where = where,
		force = force
	}) then
		net.send({
			CM_TAKEONITEM,
			recog = item:get("makeIndex"),
			param = where
		}, {
			item.getVar("name")
		})

		local bagPanel = main_scene.ui.panels.bag

		if bagPanel then
			bagPanel:delItem(item:get("makeIndex"))
		end

		return true
	end

	return false
end

function bag:add(buf, bufLen)
	local ret = {}

	while bufLen > 0 do
		local item = getRecord("TClientItem")
		_, buf, bufLen = net.record(item, buf, bufLen)

		self:addItem(item)

		ret[#ret + 1] = {
			where = "bag",
			data = item
		}
	end

	return ret
end

function bag:upt(buf, bufLen)
	local data = getRecord("TClientItem")

	net.record(data, buf, bufLen)

	if self:isInStrengthen(data) then
		for k, v in pairs(self.strengthen) do
			if v:get("makeIndex") == data:get("makeIndex") and v.getVar("name") == data.getVar("name") then
				self.strengthen[k] = data

				return data:get("makeIndex")
			end
		end
	else
		for k, v in pairs(self.items) do
			if v:get("makeIndex") == data:get("makeIndex") and v.getVar("name") == data.getVar("name") then
				self.items[k] = data

				return data:get("makeIndex")
			end
		end
	end
end

function bag:bindQuickItem(btnid, use, callback)
	if self.quickItems[btnid] then
		return
	end

	self.quickItems[btnid] = {
		use = use,
		callback = callback
	}
end

function bag:bindCustomsItem(btnid, use, makeIndex, callback)
	self:bindQuickItem(btnid, use, callback)

	local quick = self.quickItems[btnid]
	quick.custom = true

	for k, v in ipairs(quick.use) do
		for i, v2 in pairs(self.items) do
			if v2:get("makeIndex") == tonumber(makeIndex) then
				quick.item = v2

				quick.callback(v2:get("makeIndex"))

				quick.itemName = v2.getVar("name")

				for id, i_quick in pairs(self.quickItems) do
					if id ~= btnid and i_quick.item and i_quick.item:get("makeIndex") == makeIndex then
						i_quick.callback()

						i_quick.item = nil

						self:fillQuickItemTest(id)
					end
				end
			end
		end
	end
end

function bag:isInQuicks(makeIndex)
	for k, v in pairs(self.quickItems) do
		if v.custom and v.item and v.item:get("makeIndex") == tonumber(makeIndex) then
			return true
		end
	end

	return false
end

function bag:unbindQuickItem(btnid)
	if self.quickItems[btnid] then
		self.quickItems[btnid] = nil
	end
end

function bag:addItemForQuickBtn(data)
	for k, v in pairs(self.quickItems) do
		if not v.item then
			for i, v2 in ipairs(v.use) do
				if data.getVar("name") == v2 and not self:isInQuicks(data:get("makeIndex")) then
					v.item = data

					v.callback(data:get("makeIndex"))
				end
			end
		end
	end
end

function bag:fillQuickItemTest(btnid)
	local quick = self.quickItems[btnid]

	if not quick then
		return
	end

	if quick.item then
		return
	end

	if quick.itemName then
		for k, v in pairs(self.items) do
			if v.getVar("name") == quick.itemName and not self:isInQuicks(v:get("makeIndex")) then
				quick.item = v

				quick.callback(v:get("makeIndex"))

				quick.item.fill = true

				return
			end
		end
	end

	for k, v in ipairs(quick.use) do
		for i, v2 in pairs(self.items) do
			if v2.getVar("name") == v and not self:isInQuicks(v2:get("makeIndex")) then
				quick.item = v2

				quick.callback(v2:get("makeIndex"))

				quick.itemName = v2.getVar("name")
				quick.item.fill = true

				return
			end
		end
	end
end

function bag:delQuickItem(makeIndex)
	for k, v in pairs(self.quickItems) do
		if v.item and v.item:get("makeIndex") == tonumber(makeIndex) then
			v.callback()

			v.item = nil

			break
		end
	end
end

function bag:delAllQuickItem()
	for k, v in pairs(self.quickItems) do
		if v.item then
			v.callback()

			v.item = nil
		end
	end
end

function bag:getQuickItemCount()
	local cnt = 0

	for k, v in pairs(self.quickItems) do
		if v.item then
			cnt = cnt + 1
		end
	end

	return cnt
end

function bag:getItem(makeIndex)
	for k, v in pairs(self.items) do
		if makeIndex == v:get("makeIndex") then
			return k, v
		end
	end
end

function bag:getItemStrengthen(makeIndex)
	for k, v in pairs(self.strengthen) do
		if makeIndex == v:get("makeIndex") then
			return v
		end
	end
end

function bag:getItemWithTable(names)
	for i, v in ipairs(names) do
		for k, v2 in pairs(self.items) do
			if v == v2.getVar("name") then
				return v2, "bag"
			end
		end
	end
end

function bag:getItemWithName(name)
	for k, v in pairs(self.items) do
		if name == v.getVar("name") then
			return v, "bag"
		end
	end
end

function bag:getItemWithShortName(name)
	local function getItem(sName)
		for k, v in pairs(self.items) do
			local itemName = v.getVar("name")

			if string.find(itemName, sName) then
				return v
			end
		end
	end

	local tarItem = nil

	if type(name) == "table" then
		for i, v in ipairs(name) do
			if type(v) == "string" then
				tarItem = getItem(v)

				if tarItem then
					return tarItem, "bag"
				end
			end
		end
	elseif type(name) == "string" then
		tarItem = getItem(name)

		if tarItem then
			return tarItem, "bag"
		end
	end
end

function bag:getItemWithNameAndDura(name, dura)
	local function getItem(sName, dura)
		for k, v in pairs(self.items) do
			local itemName = v.getVar("name")

			if string.find(itemName, sName) and dura <= v:get("dura") then
				return v
			end
		end
	end

	return getItem(name, dura)
end

function bag:getItemCount(name)
	local cnt = 0

	for k, v in pairs(self.items) do
		if name == v.getVar("name") then
			if v.isPileUp() then
				cnt = cnt + v:get("dura")
			else
				cnt = cnt + 1
			end
		end
	end

	return cnt
end

function bag:getFreeCount()
	local cnt = 0

	for i = 1, self.max do
		if not self.items[i] then
			cnt = cnt + 1
		end
	end

	return cnt
end

function bag:addItem(data)
	for i = 1, self.max do
		if not self.items[i] then
			self.items[i] = data

			self:addItemForQuickBtn(data)

			return i
		end
	end
end

function bag:delItem(makeIndex)
	self:delQuickItem(makeIndex)

	local isSuccess = nil

	for k, v in pairs(self.items) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			self.items[k] = nil
			isSuccess = true
		end
	end

	if isSuccess then
		for k, v in pairs(self.quickItems) do
			if v.item and v.item:get("makeIndex") == tonumber(makeIndex) then
				v.callback()

				v.item = nil

				break
			end
		end
	end

	return isSuccess
end

function bag:delStrengthenItem(makeIndex)
	for k, v in pairs(self.strengthen) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			self.strengthen[k] = nil
		end
	end
end

function bag:changePos(idx1, idx2)
	self.items[idx2] = self.items[idx1]
	self.items[idx1] = self.items[idx2]
end

function bag:isAallCanPileUp(idx1, idx2)
	local item1 = self.items[idx1]
	local item2 = self.items[idx2]

	if item1 and item2 and item1.isCanPileUp(item2) then
		return true
	end

	return false
end

function bag:throw(makeIndex)
	local isSuccess = nil

	for k, v in pairs(self.items) do
		if makeIndex == v:get("makeIndex") then
			self.throwing[makeIndex] = v
			self.items[k] = nil
			isSuccess = true

			break
		end
	end

	if isSuccess then
		for k, v in pairs(self.quickItems) do
			if v.item and v.item:get("makeIndex") == tonumber(makeIndex) then
				v.callback()

				v.item = nil

				break
			end
		end
	end
end

function bag:throwEnd(makeIndex, isSuccess)
	if not isSuccess and self.throwing[makeIndex] then
		self:addItem(self.throwing[makeIndex])
	end

	self.throwing[makeIndex] = nil
end

function bag:use(action, makeIndex, params)
	local limit = 5

	if params and params.force then
		limit = 0.2
	end

	if self[action].item and limit > socket.gettime() - self[action].time then
		return
	end

	local isSuccess = nil

	for k, v in pairs(self.items) do
		if makeIndex == v:get("makeIndex") then
			self[action].item = v
			self[action].time = socket.gettime()
			self[action].params = params
			self.items[k] = nil
			isSuccess = true

			break
		end
	end

	if isSuccess then
		for k, v in pairs(self.quickItems) do
			if v.item and v.item:get("makeIndex") == makeIndex then
				v.callback()

				v.item = nil
			end
		end
	end

	return isSuccess
end

function bag:useEnd(action, isSuccess)
	local ret, item, isQuick, where = nil

	if self[action].item then
		item = self[action].item
		ret = self[action].item:get("makeIndex")
		isQuick = self[action].params and self[action].params.quick

		if isSuccess then
			if action == "take" then
				if self.isHero then
					g_data.heroEquip:setItem(self[action].params.where, self[action].item)
				else
					g_data.equip:setItem(self[action].params.where, self[action].item)
				end
			end
		else
			self:addItem(self[action].item)
		end
	end

	self[action] = {}

	return ret, item, isQuick, where
end

function bag:duraChange(makeindex, dura, duraMax, price)
	for k, v in pairs(self.items) do
		if makeindex == v:get("makeIndex") then
			v:set("dura", dura)
			v:set("duraMax", duraMax)

			return
		end
	end

	if self.eat.item and makeindex == self.eat.item:get("makeIndex") then
		self.eat.item:set("dura", dura)
		self.eat.item:set("duraMax", duraMax)
	end

	for k, v in pairs(self.strengthen) do
		if makeindex == v:get("makeIndex") then
			v:set("dura", dura)
			v:set("duraMax", duraMax)

			return
		end
	end
end

function bag:PileUpNext()
	if g_data.player.inPileUping then
		return false
	end

	for i, v in pairs(self.items) do
		local ret = self:AutoItemAdd(v)

		if ret then
			return ret
		end
	end
end

function bag:AutoItemAdd(item)
	for i, v in pairs(self.items) do
		if v.isCanPileUp(item) then
			return {
				v,
				item
			}
		end
	end
end

function bag:tmpPrintItem(str)
	for i, v in pairs(self.items) do
		print(i, v.getVar("name"), v:get("makeIndex"), v.getVar("stdMode"), v:get("dura"))
	end
end

function bag:addCustoms(custom_id, makeIndex, name, source)
	if not self.customs then
		self.customs = {}
	end

	self.customs[custom_id] = {
		makeIndex = makeIndex,
		name = name,
		source = source
	}
end

function bag:delCustoms(custom_id)
	self.customs[custom_id] = nil
end

function bag:getCustom(custom_id)
	if not self.customs then
		self.customs = {}
	end

	return self.customs[custom_id]
end

return bag
