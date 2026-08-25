local voice = {
	members = {},
	logs = {}
}

function voice:reset()
	self.roomData = nil
	self.channelType = nil
	self.members = {}
	self.logs = {}
	self.playerData = nil
end

function voice:setMembers(msg, buf, bufLen, channelType, playerName)
	self:reset()

	self.roomData, buf, bufLen = getRecord("TClientChannelHeadInfo"):decode(buf, bufLen, true)

	for i = 1, msg.param do
		self.members[#self.members + 1], buf, bufLen = getRecord("TClientMemberInfo"):decode(buf, bufLen, true)
	end

	self.channelType = channelType

	for i, v in ipairs(self.members) do
		if v:get("name") == playerName then
			self.playerData = v

			break
		end
	end

	self.logs = {}

	self:addModeLog(self.roomData:get("mode"))

	for i, v in ipairs(self.members) do
		self:addEnterLog(v:get("name"))
	end
end

function voice:getMember(name)
	for i, v in ipairs(self.members) do
		if v:get("name") == name then
			return v
		end
	end
end

function voice:setMode(mode)
	if not self.roomData then
		return
	end

	self.roomData:set("mode", mode)

	return true, self:addModeLog(mode)
end

function voice:memberJoin(isAdmin, name, isMute)
	local data = getRecord("TClientMemberInfo", {
		isAdmin = isAdmin,
		name = name,
		isMute = isMute
	})

	self.members[#self.members + 1] = data

	return data, self:addEnterLog(name)
end

function voice:memberExit(name, exitType, playerName)
	if name == playerName then
		self:reset()

		return true
	end

	for i, v in ipairs(self.members) do
		if v:get("name") == name then
			table.remove(self.members, i)

			return false, self:addExitLog(v:get("name"), exitType)
		end
	end
end

function voice:setIsMute(isMute, name)
	for i, v in ipairs(self.members) do
		if v:get("name") == name then
			v:set("isMute", isMute)

			return v, self:addMuteLog(v:get("name"), isMute)
		end
	end
end

function voice:setIsAdmin(isAdmin, name)
	for i, v in ipairs(self.members) do
		if v:get("name") == name then
			v:set("isAdmin", isAdmin)

			return v, self:addAdminLog(v:get("name"), isAdmin)
		end
	end
end

function voice:addModeLog(mode)
	return self:addLog("当前频道为: " .. (mode == 0 and "自由模式" or "指挥模式"))
end

function voice:addEnterLog(name)
	return self:addLog(string.format("%s 加入了频道", name))
end

function voice:addExitLog(name, exitType)
	if exitType == 1 then
		return self:addLog(name .. " 被管理员踢出了频道")
	end

	return self:addLog(name .. " 退出了频道")
end

function voice:addMuteLog(name, isMute)
	if isMute == 1 then
		return self:addLog(name .. " 被管理员禁言")
	else
		return self:addLog(name .. " 被管理员解禁")
	end
end

function voice:addAdminLog(name, isAdmin)
	if isAdmin == 1 then
		return self:addLog(name .. " 成为管理员")
	else
		return self:addLog(name .. " 管理员被取消")
	end
end

function voice:addLog(text)
	if not self.logs then
		return
	end

	self.logs[#self.logs + 1] = text

	return text
end

function voice:getLastLog(num)
	local ret = {}

	for i = #self.logs, 1, -1 do
		ret[#ret + 1] = self.logs[i]

		if num <= #ret then
			break
		end
	end

	return ret
end

return voice
