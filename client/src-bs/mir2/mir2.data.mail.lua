local mail = {
	unreadCnt,
	handler,
	sys = {},
	sell = {},
	offtm = {},
	msg = {},
	infos = {
		sys = {},
		sell = {}
	}
}

local function sort(a, b)
	local ret = true

	if a.mailState ~= b.mailState then
		ret = a.mailState < b.mailState
	elseif a.attachState ~= b.attachState then
		ret = a.attachState < b.attachState
	elseif a.time ~= b.time then
		ret = b.time < a.time
	else
		ret = false
	end

	return ret
end

function mail:cfg()
	return {
		sell = 4,
		sys = 1,
		offtm = 5,
		msg = 6
	}
end

function mail:tag2Var(key)
	key = key or 1

	for k, v in pairs(self:cfg()) do
		if type(key) == "string" and key == k then
			return v
		elseif type(key) == "number" and key == v then
			return key
		end
	end

	if type(key) ~= "string" and type(key) ~= "number" then
		return tags.sys
	end
end

function mail:set(msg, buf, bufLen)
	local cfg = self:cfg()
	local cnt = msg.param

	if cfg.sys == msg.tag then
		self.sys = {}
		local data = nil

		for i = 1, cnt do
			data, buf, bufLen = net.record("TMailListInfo", buf, bufLen)
			data.time = TDateTimeToUnixDate(data.time)
			self.sys[#self.sys + 1] = data
		end

		table.sort(self.sys, sort)
	elseif cfg.sell == msg.tag then
		self.sell = {}
		local data = nil

		for i = 1, cnt do
			data, buf, bufLen = net.record("TMailListInfo", buf, bufLen)
			data.time = TDateTimeToUnixDate(data.time)
			self.sell[#self.sell + 1] = data
		end

		for i = 1, cnt do
			self.sell[i].itemEx, buf, bufLen = net.record("TClientItem", buf, bufLen)
		end

		table.sort(self.sell, sort)
	elseif cfg.offtm == msg.tag then
		self.offtm = {}
		local data = nil

		for i = 1, cnt do
			data, buf, bufLen = net.record("TMailInfo", buf, bufLen)
			data.items = {}
			local item = nil

			for i = 1, data.cnt do
				item, buf, bufLen = net.record("TClientItem", buf, bufLen)
				data.items[#data.items + 1] = item
			end

			if data.cnt > 0 then
				self.offtm[#self.offtm + 1] = data
			end
		end
	else
		self.msg = {}
		local data = nil

		for i = 1, cnt do
			data, buf, bufLen = net.record("TMailMsg", buf, bufLen)
			self.msg[#self.msg + 1] = data
		end
	end
end

function mail:parseMail(msg, buf, bufLen)
	local data = nil
	data, buf, bufLen = net.record("TMailInfo", buf, bufLen)
	data.items = {}

	for i = 1, data.cnt do
		item, buf, bufLen = net.record("TClientItem", buf, bufLen)
		data.items[#data.items + 1] = item
	end

	local from = nil

	for _, v in ipairs(self.sys) do
		if data.id == v.id then
			from = "sys"

			break
		end
	end

	if not from then
		for _, v in ipairs(self.sell) do
			if data.id == v.id then
				from = "sell"

				break
			end
		end
	end

	if from then
		self.infos[from][data.id] = data
	end

	return data.id, from
end

function mail:attach()
	if not g_data.client.mailId then
		return
	end

	local id = g_data.client.mailId
	local from = nil

	for i, v in ipairs(self.sys) do
		if id == v.id then
			v.attachState = 2
			from = "sys"

			break
		end
	end

	if self.infos.sys[id] then
		self.infos.sys[id].attachState = 2
	end

	if not from then
		for i, v in ipairs(self.sell) do
			if id == v.id then
				v.attachState = 2
				from = "sell"

				break
			end
		end

		if self.infos.sell[id] then
			self.infos.sell[id].attachState = 2
		end
	end

	return id, from
end

function mail:del()
	if not g_data.client.mailId then
		return
	end

	local id = g_data.client.mailId
	local next, from = nil

	if self.infos.sys and self.infos.sys[id] then
		self.infos.sys[id] = nil
		from = "sys"

		for i, v in ipairs(self.sys) do
			if id == v.id then
				next = i <= #self.sys and self.sys[i + 1] and self.sys[i + 1].id or nil

				table.remove(self.sys, i)

				break
			end
		end
	end

	if not from and self.infos.sell and self.infos.sell[id] then
		self.infos.sell[id] = nil
		from = "sell"

		for i, v in ipairs(self.sell) do
			if id == v.id then
				table.remove(self.sell, i)

				break
			end
		end
	end

	return id, next, from
end

function mail:attachOfftm()
	self.offtm = {}
end

function mail:setUnreadMailCnt(cnt)
	self.unreadCnt = cnt
end

function mail:cleanup()
	if self.handler then
		scheduler.unscheduleGlobal(self.handler)

		self.handler = nil
	end
end

function mail:startSchedule()
	self.handler = scheduler.scheduleGlobal(function ()
		net.send({
			CM_SYSTEM_NEWMAIL
		})
	end, 1800)
end

return mail
