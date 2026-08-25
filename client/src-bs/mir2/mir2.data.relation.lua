local relation = {
	listeners_ = {},
	chatRecords = {}
}
local notifier = {
	addNotifyListener = function (self, func)
		self.listeners_ = self.listeners_ or {}
		self.listeners_[#self.listeners_ + 1] = func
	end,
	removeNotifyListener = function (self, func)
		for k, v in ipairs(self.listeners_) do
			if v == func then
				table.remove(self.listeners_, k)
			end
		end
	end,
	notify = function (self, t, ...)
		for k, v in ipairs(self.listeners_ or {}) do
			v("relation", t, ...)
		end
	end
}

table.merge(relation, notifier)

function relation:decodeArray_(num, recordName, buf, bufLen)
	local list = {}

	for k = 1, num do
		local record = nil
		record, buf, bufLen = net.record(recordName, buf, bufLen)
		list[k] = record
	end

	return list
end

function relation:sort_(list)
	if list.sorted__ then
		return list
	end

	local function compare(l, r)
		local lonline = l:get("isonline")
		local ronline = r:get("isonline")
		local llevel = l:get("level")
		local rlevel = r:get("level")

		if ronline < lonline then
			return true
		elseif lonline == ronline and rlevel < llevel then
			return true
		else
			return false
		end
	end

	table.sort(list, compare)

	list.sorted__ = true

	return list
end

function relation:setFriends(msg, buf, bufLen)
	local num = msg.param
	self.friends = self:decodeArray_(num, "TClientFriendRelation", buf, bufLen)

	for i, v in ipairs(self.friends) do
		print("relation:setFriends", v:get("name"))
		g_data.mark:addFriend(v:get("name"))
	end

	self:notify("friend")
end

function relation:setAttentions(msg, buf, bufLen)
	local num = msg.param
	self.attentions = self:decodeArray_(num, "TClientAttentionRelation", buf, bufLen)

	for i, v in ipairs(self.attentions) do
		print("relation:setAttentions", v:get("name"))
		g_data.mark:addFriend(v:get("name"))
	end

	self:notify("attention")
end

function relation:setBlackList(msg, buf, bufLen)
	local num = msg.param
	self.blackList = self:decodeArray_(num, "TClientNormalBlackRelation", buf, bufLen)

	for i, v in ipairs(self.blackList) do
		print("relation:setBlackList", v:get("name"))
		g_data.mark:addFriend(v:get("name"))
	end

	self:notify("blackList")
end

function relation:update_(act, arr, recordName, buf, bufLen)
	if act == 0 then
		arr.sorted__ = false
		local record, buf, bufLen = net.record(recordName, buf, bufLen)
		arr[#arr + 1] = record

		return record
	elseif act == 1 then
		local item, idx = self:getItemByName(arr, net.str(buf))

		if idx then
			table.remove(arr, idx)
		end

		return item
	elseif act == 2 then
		arr.sorted__ = false
		local record, buf, bufLen = net.record(recordName, buf, bufLen)
		local item, index = self:getItemByName(arr, record:get("name"))

		if index then
			arr[index] = record
		end

		return item, record
	end
end

function relation:updateFriend(msg, buf, bufLen)
	if not self.friends then
		return
	end

	self:update_(msg.param, self.friends, "TClientFriendRelation", buf, bufLen)

	for i, v in ipairs(self.friends) do
		print("relation:updateFriend", v:get("name"))
		g_data.mark:addFriend(v:get("name"))
	end

	self:notify("friend")
end

function relation:updateAttention(msg, buf, bufLen)
	if not self.attentions then
		return
	end

	local ole, new = self:update_(msg.param, self.attentions, "TClientAttentionRelation", buf, bufLen)

	for i, v in ipairs(self.attentions) do
		print("relation:updateAttention", v:get("name"))
		g_data.mark:addFriend(v:get("name"))
	end

	self:notify("attention", ole, new)
end

function relation:updateBlackList(msg, buf, bufLen)
	if not self.blackList then
		return
	end

	self:update_(msg.param, self.blackList, "TClientNormalBlackRelation", buf, bufLen)

	for i, v in ipairs(self.blackList) do
		print("relation:updateBlackList", v:get("name"))
		g_data.mark:addFriend(v:get("name"))
	end

	self:notify("blackList")
end

function relation:getItemByName(arr, name)
	for k, v in ipairs(arr) do
		if v:get("name") == name then
			return v, k
		end
	end
end

function relation:setOnline_(msg, isonline, buf, bufLen)
	local name = net.str(buf)
	local list, typeName = nil

	if msg.param == 0 then
		list = self.friends
		typeName = "friend"
	elseif msg.param == 1 then
		list = self.attentions
		typeName = "attention"
	elseif msg.param == 2 then
		list = self.blackList
		typeName = "blackList"
	end

	if not list then
		return
	end

	list.sorted__ = false
	local item = self:getItemByName(list, name)

	item:set("isonline", isonline)
	self:notify(typeName)
end

function relation:online(msg, buf, bufLen)
	self:setOnline_(msg, 1, buf, bufLen)
end

function relation:offline(msg, buf, bufLen)
	self:setOnline_(msg, 0, buf, bufLen)
end

function relation:getFriends()
	if self.friends then
		self:sort_(self.friends)

		return self.friends
	else
		return {}
	end
end

function relation:getAttentions()
	if self.attentions then
		self:sort_(self.attentions)

		return self.attentions
	else
		return {}
	end
end

function relation:getBlackList()
	if self.blackList then
		self:sort_(self.blackList)

		return self.blackList
	else
		return {}
	end
end

function relation:decodeNearPlayerBuf(msg, buf, bufLen)
	local num = msg.param
	local arr = self:decodeArray_(num, "TClientNearbyPlayerInfo", buf, bufLen)

	return arr
end

function relation:getNearList()
	local list = {}

	if main_scene.ground.map then
		list = main_scene.ground.map:getHeroNameList()
	end

	local data = {}

	for i, v in ipairs(list) do
		data[#data + 1] = {
			"string",
			v,
			15
		}
	end

	net.send({
		CM_QUERY_NEARBYPLAYER,
		param = #list
	}, nil, data)

	self.nearList = list

	return list
end

function relation:setAttentionColor(playername, coloridx)
	local att = self:getAttention(playername)

	if att then
		net.send({
			CM_UPDATE_ATTENTION_COLOR,
			param = coloridx
		}, {
			playername
		})
		att:set("color", coloridx)
		self:notify("attentionColor", att, att)
	end
end

function relation:getRelationShip(name)
	local r = {}

	if self:getItemByName(self.friends, name) then
		r.isFriend = true
	end

	if self:getItemByName(self.attentions, name) then
		r.isAttention = true
	end

	if self:getItemByName(self.blackList, name) then
		r.isBlack = true
	end

	return r
end

function relation:getFriend(name)
	return self.friends and self:getItemByName(self.friends, name)
end

function relation:getAttention(name)
	return self.attentions and self:getItemByName(self.attentions, name)
end

function relation:getBlack(name)
	return self.blackList and self:getItemByName(self.blackList, name)
end

local chatRecord = class("relation.chatRecord", notifier)

function chatRecord:ctor(player, target, size)
	self.data = cache.getFriendChatRecord(player, target)
	self.data.pos = self.data.pos or 1
	self.data.maxSize = self.data.maxSize or size
	self.data.curSize = self.data.curSize or 0
	self.data.record = self.data.record or {}
	self.data.unread = self.data.unread or 0
end

function chatRecord:add(content)
	local data = self.data
	data.record[data.pos] = content

	if data.maxSize <= data.pos then
		data.pos = 1
	else
		data.pos = data.pos + 1

		if data.curSize < data.maxSize then
			data.curSize = data.curSize + 1
		end
	end

	self:notify("newItem", content)
end

function chatRecord:readed()
	self.data.unread = 0
end

function chatRecord:getUnreadCnt()
	return self.data.unread
end

function chatRecord:get(pos)
	local data = self.data

	if data.maxSize <= data.curSize then
		pos = data.pos + pos - 1
	end

	if data.maxSize < pos then
		pos = pos - data.maxSize
	end

	return data.record[pos]
end

function chatRecord:iterator()
	local pos = 1

	return function ()
		if self.data.curSize < pos then
			return nil
		end

		local re = self:get(pos)
		pos = pos + 1

		return re
	end
end

function chatRecord:rIterator()
	local pos = self.data.pos - 1

	return function ()
		if self.data.curSize < pos then
			return nil
		end

		local re = self:get(pos)
		pos = pos - 1

		return re
	end
end

local function testChatRecord()
	local r1 = chatRecord.new(10)

	for k = 1, 5 do
		r1:add(k)
	end

	local exp = 1

	for v in r1:iterator() do
		assert(v == exp, "should be equal")

		exp = 1 + exp
	end

	local r2 = chatRecord.new(10)

	for k = 1, 10 do
		r2:add(k)
	end

	local exp = 1

	for v in r2:iterator() do
		assert(v == exp, "should be equal")

		exp = 1 + exp
	end

	local r3 = chatRecord.new(10)

	for k = 1, 20 do
		r3:add(k)
	end

	local exp = 11

	for v, k in r3:iterator() do
		assert(v == exp, "should be equal")

		exp = 1 + exp
	end
end

function relation:recordChat(target, text, playerName)
	self:getRecords(playerName, target):add({
		isOther = false,
		name = playerName,
		text = text,
		time = os.time()
	})
end

function relation:getRecords(playerName, target)
	if not self.chatRecords[target] then
		self.chatRecords[target] = chatRecord.new(playerName, target, 1000)
	end

	return self.chatRecords[target]
end

function relation:filterChat(playername, text, ident, msg)
	local name = nil

	if SM_WHISPER == ident then
		name = string.sub(text, 0, string.find(text, "=> ") - 1)
	elseif SM_CRY == ident then
		name = string.sub(text, 4, string.find(text, ":") - 1)
	else
		local idx = string.find(text, ":")

		if not idx then
			return true
		end

		name = string.sub(text, 0, idx - 1)
	end

	if self:getBlack(name) then
		return false
	end

	if SM_WHISPER == ident and self:getFriend(name) then
		local record = self:getRecords(playername, name)
		record.data.unread = record.data.unread + 1

		record:add({
			isOther = true,
			name = name,
			text = string.sub(text, string.find(text, "=> ") + 3),
			user = msg.recog,
			time = os.time()
		})
	end

	return true
end

return relation
