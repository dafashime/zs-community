local selectRole = {
	selectIndex = 1,
	roles = {}
}

function selectRole:getCurName()
	if self.selectIndex <= #self.roles then
		return self.roles[self.selectIndex].name
	end

	return ""
end

function selectRole:setSelectIndex(idx)
	self.selectIndex = idx
end

function selectRole:receiveChrs(msg, buf, bufLen)
	self.roles = {}
	local count = msg.param
	local info = getRecord("TMirCharInfo")
	local infoEx = getRecord("TMirCharinfoEx")
	local temp = bufLen >= infoEx:size() * count and infoEx or info

	for i = 1, count do
		_, buf, bufLen = net.record(temp, buf, bufLen)
		local level = temp:get("level")

		if temp:get("hair") ~= 1 then
			level = ycFunction:bor(level, ycFunction:lshift(temp:get("hair") - 1, 8))
		end

		self.roles[#self.roles + 1] = {
			name = temp:get("name"),
			job = temp:get("job"),
			hair = temp:get("hair"),
			level = level,
			sex = temp:get("sex")
		}
	end

	self.selectIndex = msg.tag + 1

	cache.saveLastPlayerName(self:getCurName())
end

return selectRole
