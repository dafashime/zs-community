local ybdeal = {
	level = 1,
	list_buy = {},
	list_buyHis = {},
	list_sell = {},
	list_sellHis = {},
	sign = {
		[SM_YBDEAL_REFER_ITEMS1] = false,
		[SM_YBDEAL_REFER_ITEMS2] = false
	}
}

function ybdeal:getName(ident)
	return ({
		[SM_YBDEAL_QUERY_BUY] = "list_buy",
		[SM_YBDEAL_QUERY_SELL] = "list_sell",
		[SM_YBDEAL_HISTROY_BUY] = "list_buyHis",
		[SM_YBDEAL_HISTROY_SELL] = "list_sellHis"
	})[ident]
end

function ybdeal:getTag(ident)
	return ({
		[SM_YBDEAL_QUERY_BUY] = 1,
		[SM_YBDEAL_QUERY_SELL] = 2,
		[SM_YBDEAL_HISTROY_BUY] = 4,
		[SM_YBDEAL_HISTROY_SELL] = 5,
		[SM_DISPLAY_YBDEAL_SET] = 6
	})[ident]
end

function ybdeal:parseMsg(msg, buf, bufLen)
	local name = self:getName(msg.ident)

	self:clearList(name)

	local unit

	for i = 1, msg.param do
		unit, buf, bufLen = net.record("TYBDealClientItems", buf, bufLen)
		unit.items = {}

		for i = 1, unit.cnt do
			local item

			item, buf, bufLen = net.record("TClientItem", buf, bufLen)

			function item.isPileUp()
				return item.getVar("stdMode") > 150
			end

			unit.items[#unit.items + 1] = item
		end

		self:addUnit(name, unit)
	end

	return self:getTag(msg.ident)
end

function ybdeal:clearList(name)
	if self[name] then
		self[name] = {}
	end
end

function ybdeal:addUnit(name, item)
	if self[name] then
		self[name][#self[name] + 1] = item
	end
end

function ybdeal:resetSign()
	self.sign = {
		[SM_YBDEAL_REFER_ITEMS1] = false,
		[SM_YBDEAL_REFER_ITEMS2] = false
	}
end

function ybdeal:setSign(msg)
	self.sign[msg.ident] = true
end

function ybdeal:removeBuyUnit(id)
	for k, v in ipairs(self.list_buy) do
		if id == v.id then
			table.remove(self.list_buy, k)

			break
		end
	end
end

function ybdeal:removeSellUnit(id)
	for k, v in ipairs(self.list_sell) do
		if id == v.id then
			table.remove(self.list_sell, k)

			break
		end
	end
end

function ybdeal:parseSetting(msg)
	self.level = msg.recog

	return self:getTag(msg.ident)
end

return ybdeal
