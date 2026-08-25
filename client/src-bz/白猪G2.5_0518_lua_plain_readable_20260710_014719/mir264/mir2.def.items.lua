local items = {}

scheduler.performWithDelayGlobal(function()
	local file = def.role.getConfig("wupin", "txt", true)
	local datas = string.split(file, "\n")

	local function initItem(dataStr)
		local data = string.split(dataStr, ",")
		local record = {
			allowFlag = tonumber(data[2]) or 0,
			name = data[3] or "",
			stdMode = tonumber(data[4]) or 0,
			shape = tonumber(data[5]),
			source = tonumber(data[6]) or 0,
			outlook = tonumber(data[7]),
			looks = tonumber(data[8]) or 0,
			weight = tonumber(data[9]) or 0,
			duraMax = tonumber(data[10]) or 0,
			aniCount = tonumber(data[11]) or 0,
			needConf = tonumber(data[12]) or 0,
			AC = tonumber(data[13]) or 0,
			maxAC = tonumber(data[14]) or 0,
			MAC = tonumber(data[15]) or 0,
			maxMAC = tonumber(data[16]) or 0,
			DC = tonumber(data[17]) or 0,
			maxDC = tonumber(data[18]) or 0,
			MC = tonumber(data[19]) or 0,
			maxMC = tonumber(data[20]) or 0,
			SC = tonumber(data[21]) or 0,
			maxSC = tonumber(data[22]) or 0,
			CC = tonumber(data[23]) or 0,
			maxCC = tonumber(data[24]) or 0,
			need = tonumber(data[25]) or 0,
			needLevel = tonumber(data[26]) or 0,
			antiqueLv = tonumber(data[27]) or 0,
			wParam1 = tonumber(data[28]) or 0,
			wParam2 = tonumber(data[29]) or 0,
			intParam = tonumber(data[30]) or 0,
			itemScore = tonumber(data[31]) or 0,
			price = tonumber(data[32]) or 0,
			itemType1 = tonumber(data[33]) or 0,
			itemType2 = tonumber(data[34]) or 0,
			itemType3 = tonumber(data[35]) or 0,
			itemLevel = tonumber(data[36]) or 0,
			suitEquipType = tonumber(data[37]) or 0,
			intparam2 = tonumber(data[38]) or 0,
			intparam3 = tonumber(data[39]) or 0,
			maxSteelLv = tonumber(data[40]) or 0,
			maxVeinsLv = tonumber(data[41]) or 0,
			baseEffectID = tonumber(data[42]) or 0,
			itemExtAbil = data[43],
			needJob = tonumber(data[44]) or 7,
			ItemConf = tonumber(data[45]) or 0,
			get = function(self, k2)
				return self[k2]
			end
		}

		function record.getVar(k)
			return record:get(k)
		end

		return record, tonumber(data[1])
	end

	local name2Index = {}

	for i, v in ipairs(datas) do
		if v ~= "" then
			local record2, idx = initItem(v)

			items[idx] = record2
			name2Index[record2.name] = idx
		end
	end

	items.name2Index = name2Index
	items.defaultItem = initItem(",,未知物品")

	local descfile = def.role.getConfig("itemdesc", "txt", true)
	local descdatas = string.split(descfile, "\n")

	items.desc = {}

	for i2, v2 in ipairs(descdatas) do
		if v2 ~= "" then
			local data2 = string.split(v2, "=")

			items.desc[data2[1]] = data2[2]
		end
	end
end, 0)

function items.initFilt()
	local text = "itemFilt180"

	if def.gameVersionType == "176" then
		text = "itemFilt176"
	elseif def.gameVersionType == "185" then
		text = "itemFilt185"
	end

	local filterfile = def.role.getConfig(text, "txt", true)
	local filterdatas = string.split(filterfile, "\n")

	items.filt = {}

	local category2 = {}

	for i, v in ipairs(filterdatas) do
		if v ~= "" then
			local data = string.split(v, ",")

			items.filt[data[1]] = {
				category = data[2],
				pickOnRatting = string.find(data[3], "1") ~= nil,
				pickUp = string.find(data[4], "1") ~= nil,
				hintName = string.find(data[5], "1") ~= nil,
				isGood = string.find(data[6], "1") ~= nil
			}
			category2[data[2]] = true
		end
	end

	items.category = {}

	for k, v2 in pairs(category2) do
		table.insert(items.category, k)
	end
end

function items:getItemByName(item)
	if item and item == 3 and items.name2Index then
		local value = items.name2Index[self]

		if value and value <= #items then
			return items[value]
		else
			return nil
		end
	end
end

function items:getItemIdByName()
	if items.name2Index then
		return items.name2Index[self]
	end
end

function items:getItemById()
	if self and self <= #items then
		return items[self]
	else
		return nil
	end
end

function items:getStdItemById()
	return items.setStdItemData(items.getItemById(self), self)
end

function items:setStdItemData(FIndex2)
	local items2 = {
		FItemIdent = 1,
		FIndex = FIndex2,
		FDura = self and self.duraMax or 0,
		FDuraMax = self and self.duraMax or 0,
		FItemValueList = {}
	}

	setmetatable(items2, {
		__index = gItemOp
	})

	local function callback(self2)
		self2._item = self

		if not self2._item then
			return
		end

		self2.extendField = {}

		if self.AC then
			print("items.AC------", self.AC)

			self2.extendField.AC = self.AC
		end

		if self.maxAC then
			self2.extendField.maxAC = self.maxAC
		end

		if self.MAC then
			self2.extendField.MAC = self.MAC
		end

		if self.DC then
			print("items.DC------", self.DC)

			self2.extendField.DC = self.DC
		end

		if self.maxDC then
			print("items.maxDC------", self.maxDC)

			self2.extendField.maxDC = self.maxDC
		end

		return self2
	end

	items2 = items2 and callback(items2)

	return items2
end

items.valueType2Key = {
	[0] = "AC",
	"maxAC",
	"MAC",
	"maxMAC",
	"DC",
	"maxDC",
	"MC",
	"maxMC",
	"SC",
	"maxSC",
	"CC",
	"maxCC",
	"normalStateSet",
	"need",
	"needLevel",
	"antiqueLv",
	"maxDura",
	"hitSpeed",
	"quickRate",
	"accurate",
	"posiAC",
	"HP",
	"MP",
	"price",
	"strength",
	"AttributeDC",
	"AttributeAC",
	"AttributeMAC",
	"AttributeMaxMC",
	"AttributeMaxSC",
	"AttributeLucky",
	"AttributeStrength",
	"AttributeHitSpeed",
	"AttributeSTONE_DEF",
	"AttributePOIS_RESUME",
	"AttributeAccurate",
	"AttributeDura",
	"AttributeQuickRate",
	"AttributeMaxDura",
	"AttributeMcAvoid",
	"JewelType",
	"JewelAbil",
	"JewelDC",
	"JewelMC",
	"JewelSC",
	"JewelAC",
	"JewelMAC",
	"JewelDura",
	"JewelHitSpeed",
	"JewelQuickRate",
	"JewelAccurate",
	"JewelPoisAc",
	"JewelDownSpeed",
	"JewelStrength",
	"VTGiftProp"
}

return items
