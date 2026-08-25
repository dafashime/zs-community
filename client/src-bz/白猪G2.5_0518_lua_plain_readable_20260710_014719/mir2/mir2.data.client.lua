local cc = require("mir2.cc")

return {
	dealGold = 0,
	lastTime = {},
	cacheTime = {},
	dealItems = {},
	fusionItems = {},
	lastScale = {
		storage = 1,
		heroBag = 1,
		bag = 1.1,
		npc = 1
	},
	initLastTime = function(lastTimeOwner)
		local common = require("mir2.scenes.main.common.common")
		local diy = cache.getDiy(common.getPlayerName(), "_cachetime")

		if diy then
			for itemId, item in pairs(diy) do
				lastTimeOwner.lastTime[itemId] = item
			end
		end
	end,
	cacheLastTime = function(value, value2)
		local common = require("mir2.scenes.main.common.common")

		if value.lastTime[value2] then
			value.cacheTime[value2] = value.lastTime[value2]

			cache.saveDiy(common.getPlayerName(), "_cachetime", value.cacheTime)
		end
	end,
	setLastTime = function(self, key, time)
		self.lastTime[key] = time and socket.gettime() or nil
	end,
	checkLastTime = function(self, key, time)
		return not self.lastTime[key] or time < socket.gettime() - self.lastTime[key]
	end,
	setLastSellItem = function(self, data)
		self.lastSellItem = data
	end,
	setStorageItem = function(self, data)
		self.storageItem = data
	end,
	setStorageGetBackItem = function(self, data)
		self.storageGetBackItem = data
	end,
	setHeroPutInItem = function(self, data)
		self.heroPutInItem = data
	end,
	setHeroGetBackItem = function(self, data)
		self.heroGetBackItem = data
	end,
	setNowDealItem = function(self, data)
		self.dealItem = data
	end,
	addDealItem = function(self, data)
		self.dealItems[#self.dealItems + 1] = data
	end,
	clearDealItem = function(self)
		self.dealItems = {}
	end,
	setNowFusionItem = function(self, data)
		self.fusionItem = data
	end,
	addfusionItem = function(self, data)
		self.fusionItems[#self.fusionItems + 1] = data
	end,
	clearfusionItem = function(self)
		self.fusionItems = {}
	end,
	setDealGold = function(self, gold)
		self.dealGold = gold or 0
	end,
	setLastScale = function(self, key, scale)
		self.lastScale[key] = scale
	end,
	setLastQueryChatItem = function(self, makeIndex, name, x, y)
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
	end,
	setLastNpcMap = function(self, data)
		self.npcMap = data
	end,
	setLastMail = function(self, id)
		self.mailId = id
	end
}
