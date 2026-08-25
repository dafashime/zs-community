local mixingDrug = {}

function mixingDrug:saveConfig(msg, buf, bufLen)
	self.cfg = {}
	local cnt = bufLen / getRecordSize("TMixingDrugConfig")
	local item = nil

	for i = 1, cnt do
		item, buf, bufLen = net.record("TMixingDrugConfig", buf, bufLen)
		self.cfg[#self.cfg + 1] = item
	end

	dump(self.cfg)
end

function mixingDrug:getConfig(id)
	for i, v in ipairs(self.cfg) do
		if v.id and v.id == tonumber(id) then
			return v
		end
	end
end

function mixingDrug:set(msg, buf, bufLen)
	self.lst = {}
	local cnt = bufLen / getRecordSize("TMixingDrugListInfo")
	local item = nil

	for i = 1, cnt do
		item, buf, bufLen = net.record("TMixingDrugListInfo", buf, bufLen)
		self.lst[#self.lst + 1] = item
	end
end

function mixingDrug:update(id, state)
	if self.lst then
		for _, v in ipairs(self.lst) do
			if v.id == id then
				v.state = state

				return true
			end
		end
	end
end

function mixingDrug:query(msg, buf, bufLen)
	local find, state = nil

	for _, v in ipairs(self.lst) do
		if v.id == msg.recog then
			find = true
			v.state = msg.tag

			break
		end
	end

	if not find then
		assert(false, "[mixingDrug system] : query the id is not exist !")

		return
	end

	local act = ({
		"begin",
		"during",
		"ended"
	})[msg.tag]
	local data = {}

	if msg.tag == 1 then
		data, buf, bufLen = net.record("TMixingDrugBegin", buf, bufLen)
	elseif msg.tag == 2 then
		data, buf, bufLen = net.record("TMixingDrugDuring", buf, bufLen)
	elseif msg.tag == 3 then
		data.items = {}

		for i = 1, msg.param do
			local item = nil
			item, buf, bufLen = net.record("TClientItem", buf, bufLen)
			data.items[#data.items + 1] = item
		end
	end

	table.merge(data, net.record("TMixingDrugLevelInfo", buf, bufLen))

	return act, data
end

return mixingDrug
