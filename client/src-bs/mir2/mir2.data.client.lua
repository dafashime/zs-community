local client = {
	dealGold = 0,
	lastTime = {},
	dealItems = {},
	fusionItems = {},
	lastScale = {
		heroBag = 1,
		storage = 1,
		bag = 1.1,
		npc = 1
	}
}

function client:setLastTime(key, time)
	self.lastTime[key] = time and socket.gettime() or nil
end

function client:checkLastTime(key, time)
	return not self.lastTime[key] or time < socket.gettime() - self.lastTime[key]
end

function client:setLastSellItem(data)
	self.lastSellItem = data
end

function client:setStorageItem(data)
	self.storageItem = data
end

function client:setStorageGetBackItem(data)
	self.storageGetBackItem = data
end

function client:setHeroPutInItem(data)
	self.heroPutInItem = data
end

function client:setHeroGetBackItem(data)
	self.heroGetBackItem = data
end

function client:setNowDealItem(data)
	self.dealItem = data
end

function client:addDealItem(data)
	self.dealItems[#self.dealItems + 1] = data
end

function client:clearDealItem()
	self.dealItems = {}
end

function client:setNowFusionItem(data)
	self.fusionItem = data
end

function client:addfusionItem(data)
	self.fusionItems[#self.fusionItems + 1] = data
end

function client:clearfusionItem()
	self.fusionItems = {}
end

function client:setDealGold(gold)
	self.dealGold = gold or 0
end

function client:setLastScale(key, scale)
	self.lastScale[key] = scale
end

function client:setLastQueryChatItem(makeIndex, name, x, y)
	if makeIndex then
		self.lastQueryChatItem = {
			makeIndex = makeIndex,
			name = name,
			x = x,
			y = y
		}
	else
		self.lastQueryChatItem = nil
	end
end

function client:setLastNpcMap(data)
	self.npcMap = data
end

function client:setLastMail(id)
	self.mailId = id
end

return client
