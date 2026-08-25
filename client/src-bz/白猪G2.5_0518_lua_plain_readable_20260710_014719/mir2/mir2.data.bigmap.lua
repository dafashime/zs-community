local bigmap = {
	maps = {},
	group = {},
	scriptPath = {}
}

function bigmap:loadLike(map)
	self.maps[map] = self.maps[map] or {}

	local mapCache, likes = cache.getBigmap(map), {}

	if mapCache and mapCache.likes then
		likes = mapCache.likes
	end

	if not self.maps[map].likes then
		self.maps[map].likes = likes
	end
end

function bigmap:isExistLike(map, x, y)
	if not map or map == "" then
		return
	end

	self:loadLike(map)

	for i, v in ipairs(self.maps[map].likes) do
		if v.x == x and v.y == y then
			return true
		end
	end
end

function bigmap:addLike(map, name, x, y)
	if not map or map == "" then
		return
	end

	self:loadLike(map)

	for i, v in ipairs(self.maps[map].likes) do
		if v.x == x and v.y == y then
			return
		end
	end

	self.maps[map].likes[#self.maps[map].likes + 1] = {
		name = name,
		x = x,
		y = y
	}

	cache.saveBigmap(map)
end

function bigmap:removeLike(map, x, y)
	if not map or map == "" then
		return
	end

	self:loadLike(map)

	for i, v in ipairs(self.maps[map].likes) do
		if v.x == x and v.y == y then
			table.remove(self.maps[map].likes, i)
			self:removeLike(map, x, y)
			cache.saveBigmap(map)
		end
	end
end

function bigmap:getLikes(map)
	self:loadLike(map)

	return self.maps[map].likes
end

function bigmap:loadNpcs(map)
	self.maps[map] = self.maps[map] or cache.getBigmap(map) or {}
	self.maps[map].npcs = self.maps[map].npcs or {}
end

function bigmap:addNpcs(msg, buf, bufLen)
	local title = g_data.client.npcMap.title

	self.maps[title] = self.maps[title] or {}
	self.maps[title].npcs = {}

	local npc

	for i = 1, msg.tag do
		npc, buf, bufLen = net.record("TNpcDesc", buf, bufLen)
		npc.destMapid = g_data.client.npcMap.id
		self.maps[title].npcs[i] = npc
	end
end

function bigmap:getNpcs(map)
	if not self.maps[map] then
		return nil
	else
		return self.maps[map].npcs
	end
end

function bigmap:getGroupInfo(msg, buf, bufLen)
	self.group = {}

	local mem

	for i = 1, msg.param do
		mem, buf, bufLen = net.record("TGroupMemPosition", buf, bufLen)
		self.group[#self.group + 1] = mem
	end
end

function bigmap:scriptAutoPath(msg, buf, bufLen)
	self.scriptPath = {}

	local tmp

	for i = 1, msg.recog do
		tmp, buf, bufLen = net.record("TMapPathNode", buf, bufLen)
		self.scriptPath[#self.scriptPath + 1] = tmp
	end
end

function bigmap:getScriptPath(mapid)
	if #self.scriptPath > 0 then
		local tmp

		for i, v in ipairs(self.scriptPath) do
			if v.name == mapid then
				return v
			end
		end
	end
end

return bigmap
