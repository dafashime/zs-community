local mark = {
	playerName = "",
	group = 2,
	chat = 4,
	near = 1,
	maxCount = 30,
	friend = 3,
	guild = 5,
	memList = {}
}

function mark:check(name, priority, reset)
	if name == self.playerName then
		return true
	end

	for key, value in pairs(self.memList) do
		if value.tar == name then
			if reset then
				if priority <= value.pri then
					return true
				else
					table.remove(self.memList, key)

					return false
				end
			else
				return true
			end
		end
	end

	return false
end

function mark:removeWithType(type)
	for i = #self.memList, 1, -1 do
		if self.memList[i].src == type then
			table.remove(self.memList, i)
		end
	end
end

function mark:reorder()
	local function _sort(a, b)
		return b.pri < a.pri
	end

	table.sort(self.memList, _sort)

	if self.maxCount < #self.memList then
		for i = #self.memList, self.maxCount, -1 do
			table.remove(self.memList, i)
		end
	end
end

function mark:getNames()
	local data = {}

	for key, value in pairs(self.memList) do
		data[#data + 1] = value.tar
	end

	return data
end

function mark:addMem(name, priority, source, reset)
	if type(name) == "table" then
		for i, v in ipairs(name) do
			if type(v) == "string" and not self:check(v, priority, reset) then
				self.memList[#self.memList + 1] = {
					tar = v,
					pri = priority,
					src = source
				}
			end
		end
	elseif type(name) == "string" and not self:check(name, priority, reset) then
		self.memList[#self.memList + 1] = {
			tar = name,
			pri = priority,
			src = source
		}
	end

	self:reorder()
end

function mark:addNear(name)
	self:removeWithType("near")
	self:addMem(name, self.near, "near", true)
end

function mark:addGroup(name)
	self:addMem(name, self.group, "group", true)
end

function mark:addFriend(name)
	self:addMem(name, self.friend, "friend", true)
end

function mark:addChat(name)
	self:addMem(name, self.chat, "chat", true)
end

function mark:addGuild(name)
	self:addMem(name, self.guild, "guild", true)
end

return mark
