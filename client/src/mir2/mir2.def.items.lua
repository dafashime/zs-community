local items = {}

scheduler.performWithDelayGlobal(function ()
	local file = nil

	if DEBUG > 0 then
		local fu = cc.FileUtils:getInstance()

		if fu:isFileExist("wupin.txt") then
			p2("debug", "使用了未打包的道具表")

			file = fu:getStringFromFile("wupin.txt")
		else
			file = res.getfile("config/wupin.txt")
		end
	else
		file = res.getfile("config/wupin.txt")
	end

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
			get = function (self, k)
				return self[k]
			end
		}

		function record.getVar(k)
			return record:get(k)
		end

		return record, tonumber(data[1])
	end

	for i, v in ipairs(datas) do
		if v ~= "" then
			local record, idx = initItem(v)
			items[idx] = record
		end
	end

	items.defaultItem = initItem(",,未知物品")
	local descfile = res.getfile("config/itemdesc.txt")
	local descdatas = string.split(descfile, "\n")
	items.desc = {}

	for i, v in ipairs(descdatas) do
		if v ~= "" then
			local data = string.split(v, "=")
			items.desc[data[1]] = data[2]
		end
	end
end, 0)

function items.initFilt()
	local filtFileName = "config/itemFilt180.txt"

	if def.gameVersionType == "176" then
		filtFileName = "config/itemFilt176.txt"
	elseif def.gameVersionType == "185" then
		filtFileName = "config/itemFilt185.txt"
	end

	local filterfile = res.getfile(filtFileName)
	local filterdatas = string.split(filterfile, "\n")
	items.filt = {}
	local category = {}

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
			category[data[2]] = true
		end
	end

	items.category = {}

	for k, v in pairs(category) do
		table.insert(items.category, k)
	end
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
