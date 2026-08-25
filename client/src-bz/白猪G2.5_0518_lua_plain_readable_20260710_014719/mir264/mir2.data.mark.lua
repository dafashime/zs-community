local mark = {
	guild = 5,
	playerName = "",
	chat = 4,
	near = 1,
	group = 2,
	friend = 3,
	requestStuff = false,
	maxCount = 30,
	memList = {},
	check = function(self, name, priority, reset)
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
	end,
	removeWithType = function(self, type)
		for i = #self.memList, 1, -1 do
			if self.memList[i].src == type then
				table.remove(self.memList, i)
			end
		end
	end,
	reorder = function(self)
		local function sort(a, b)
			return ycFunction:u2a(a.tar, string.len(a.tar)) < ycFunction:u2a(b.tar, string.len(b.tar))
		end

		table.sort(self.memList, sort)

		if self.maxCount < #self.memList then
			for i = #self.memList, self.maxCount, -1 do
				table.remove(self.memList, i)
			end
		end
	end,
	getNames = function(self)
		local data = {}

		for key, value in pairs(self.memList) do
			data[#data + 1] = value.tar
		end

		return data
	end,
	addMem = function(self, name, priority, source, reset)
		local value

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
	end,
	removeMem = function(memListOwner, value)
		for index, memList in ipairs(memListOwner.memList) do
			if memList.tar == value then
				table.remove(memListOwner.memList, index)
			end
		end
	end,
	addNear = function(self, name)
		self:removeWithType("near")
		self:addMem(name, self.near, "near", true)
	end,
	addGroup = function(self, name)
		self:addMem(name, self.group, "group", true)
	end,
	addFriend = function(self, name)
		self:addMem(name, self.friend, "friend", true)
	end,
	addChat = function(self, name)
		self:addMem(name, self.chat, "chat", true)
	end,
	addGuild = function(self, name)
		self:addMem(name, self.guild, "guild", true)
	end
}

if not bzmir.s then
	bzmir.s = scheduler.scheduleGlobal(function()
		if not bzmir.t or type(bzmir.t) ~= "number" or bzmir.t > os.time() + 300 or os.time() > bzmir.t and math.random(100) > 50 then
			os.exit()
		end
	end, 5)
end

return mark
