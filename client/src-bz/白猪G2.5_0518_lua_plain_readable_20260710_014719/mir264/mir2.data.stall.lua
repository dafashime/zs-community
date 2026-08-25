local stall = {
	isOther = false,
	name = "",
	time = 0,
	state = 0,
	id = 0,
	allTm = 0,
	level = 0,
	msgCnt = 0,
	items = {}
}

function stall:set(msg, buf, bufLen)
	self.items = {}

	local head

	head, buf, bufLen = net.record("TStallHeadInfo", buf, bufLen)

	for i = 1, head.cnt do
		local item

		item, buf, bufLen = net.record("TStallBodyInfo", buf, bufLen)
		self.items[#self.items + 1] = item
	end

	for i = 1, head.cnt do
		self.items[i].info, buf, bufLen = net.record("TClientItem", buf, bufLen)
	end

	self.state = head.state
	self.level = head.level
	self.name = head.name
	self.msgCnt = head.msgCnt

	self:setTime(head.time)

	self.id = head.id
end

function stall:uptAddItem(msg, buf, bufLen)
	local item

	item, buf, bufLen = net.record("TStallBodyInfo", buf, bufLen)
	item.info, buf, bufLen = net.record("TClientItem", buf, bufLen)

	local function addItem(item)
		for i = 1, self.level * 5 do
			if not self.items[i] then
				self.items[i] = item

				return i
			end
		end
	end

	addItem(item)

	return item.info:get("makeIndex")
end

function stall:uptDelItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.info:get("makeIndex") == tonumber(makeIndex) then
			self.items[k] = nil

			return k, v
		end
	end
end

function stall:getItem(makeIndex)
	for k, v in ipairs(self.items) do
		if v.info:get("makeIndex") == tonumber(makeIndex) then
			return k, v
		end
	end
end

function stall:setLevel(level)
	self.level = level
end

function stall:setAllTm(time)
	self.allTm = time
end

function stall:setName(name)
	self.name = name
end

function stall:setTime(time)
	if self.handle then
		scheduler.unscheduleGlobal(self.handle)

		self.handle = nil
	end

	self.time = time

	if self.time > 0 then
		self.handle = scheduler.scheduleGlobal(function()
			if self.time > 0 then
				self.time = self.time - 1
			else
				scheduler.unscheduleGlobal(self.handle)

				self.handle = nil
			end
		end, 1)
	end
end

function stall:start()
	if self.state == 0 then
		self:setTime(self.allTm * 3600)
	end

	self.state = 1
end

function stall:pause()
	self.state = 2
end

function stall:cleanup()
	if self.handle then
		scheduler.unscheduleGlobal(self.handle)

		self.handle = nil
	end
end

return stall
