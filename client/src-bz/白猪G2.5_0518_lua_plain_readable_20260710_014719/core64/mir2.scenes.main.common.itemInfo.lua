local info = {}

import("mir2.bzelements")
import("mir2.bz.suitEquips")

local ipush = require("mir2.single.ipush")
local items2 = {
	"tipsBg1",
	"tipsBg2",
	"tipsBg3"
}
local enabled2 = true
local enabled3 = false
local value3
local value4
local value5
local number = 220
local number2 = 260
local enabled4 = false
local enabled5 = false
local enabled6 = false
local value
local fromOwner
local items = {}
local itemColorCfg
local enabled = false
local text
local value2
local width = {
	itemInfoTitleSize = 18,
	itemEffectWidth = 278,
	showItemLogo = false,
	itemEffectHeight = 634,
	itemInfoScrollMaxHeight = 520,
	itemInfoSize = 16,
	openItemInfoScroll = true,
	title_jpss = "[极品元素]@77",
	itemLogoEffect = false,
	openItemEffect = true,
	itemEffectNeedItems = ""
}
local items3 = {
	{
		desc = "可限时的道具。",
		name = "限时道具",
		conf = math.ldexp(1, 15)
	},
	{
		desc = "效果未知",
		name = "租赁道具",
		conf = math.ldexp(1, 14)
	},
	{
		desc = "该物品不允许放到英雄背包。",
		name = "禁给英雄",
		conf = math.ldexp(1, 13)
	},
	{
		desc = "使绑定的物品可以拾取。",
		name = "拾取绑定",
		conf = math.ldexp(1, 12)
	},
	{
		desc = "该物品禁止丢弃,禁止交易,禁止卖出。但死亡可爆出且无法拾取",
		name = "永久绑定",
		conf = math.ldexp(1, 11)
	},
	{
		desc = "字面意思为三天内绑定",
		name = "三天绑定",
		conf = math.ldexp(1, 10)
	},
	{
		desc = "字面意思为一天内绑定",
		name = "一天绑定",
		conf = math.ldexp(1, 9)
	},
	{
		desc = "该物品不允许卖给NPC。",
		name = "禁止卖出",
		conf = math.ldexp(1, 8)
	},
	{
		desc = "该物品不允许存放进仓库。",
		name = "禁止存仓",
		conf = math.ldexp(1, 7)
	},
	{
		desc = "当该物品从怪物身上掉落时有几率附加极品属性。",
		name = "可爆极品",
		conf = math.ldexp(1, 6)
	},
	{
		desc = "该物品不允许扔在地上。",
		name = "禁止丢弃",
		conf = math.ldexp(1, 5)
	},
	{
		desc = "该物品在角色死亡时不会爆出。",
		name = "死亡不爆",
		conf = math.ldexp(1, 4)
	},
	{
		desc = "穿戴时,该物品将在角色死亡后消失。",
		name = "死亡消失",
		conf = math.ldexp(1, 3)
	},
	{
		desc = "该物品穿戴后不允许取下。",
		name = "禁止取下",
		conf = math.ldexp(1, 2)
	},
	{
		desc = "该物品穿戴后必须使用神水才能取下。",
		name = "神水取下",
		conf = math.ldexp(1, 1)
	}
}

local function text2(self)
	return string.gsub(self, "[%+%-%?%*%(%%)%$%^%.]", "#")
end

local function callback(self)
	local var = value.getVar(self)
	local var2 = value.getVar("stdMode")
	local items4 = {}

	if aryjpmap then
		items4 = aryjpmap(var2)
	end

	local value6 = items4[self]

	if value.addpa and value6 then
		var = var + value.addpa[value6]
	end

	return var
end

local function callback2(self)
	if fromOwner.from and value.getStd then
		return value:getStd():get(self)
	else
		return value.getVar(self)
	end
end

function getData(k)
	return callback(k)
end

function getDataStd(k)
	return callback2(k)
end

function getDataStd2(self)
	local value6 = data.extendField and data.extendField[self]

	if value6 == nil then
		if not data._item then
			data._item = data.getStd(data)
		end

		value6 = data._item and data._item[self]
	end

	return value6
end

local function isUpgrade()
	if getData("normalStateSet") then
		return ycFunction:band(getData("normalStateSet"), 1) ~= 0
	end
end

local function callback3()
	if getData("normalStateSet") and ycFunction:band(getData("normalStateSet"), 2) ~= 0 then
		return "(绑)"
	end

	return ""
end

local function callback4(self, value7)
	local value6

	if checkExist(self or 0, 15, 19, 20, 21, 22, 23, 24, 26) then
		value6 = checkExist(value7 or 0, 130, 131, 132)
	end

	return value6
end

local function callback5(self)
	local items4 = {}

	if items3 and self then
		for _, item in ipairs(items3) do
			if self >= item.conf then
				items4[#items4 + 1] = item
				self = self - item.conf
			end

			if self <= 0 then
				break
			end
		end
	end

	return items4
end

local function callback6(self)
	local items4 = {}

	for index in string.gfind(self, "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*") do
		items4[#items4 + 1] = index
	end

	return items4
end

local function callback7(text22, text3)
	if text22:find("<") ~= nil then
		local value6 = text22:find("<")
		local value7 = text22:find(">")

		if value6 and value7 then
			local value8 = text22:sub(value6 + 1, value7 - 1)
			local text4 = loadstring("return " .. value8:gsub("v", tostring(text3)))()

			if text4 then
				local text5 = math.floor(text4)

				text22 = text22:sub(1, value6 - 1) .. tostring(text5) .. text22:sub(value7 + 1, #text22)
			end
		end
	end

	return text22
end

local function callback8(text22, value6, value8, value10, imgdir, value12, offsetX, offsetY, offsetH, isHide)
	text22 = text22 or ""

	local addH = 0

	text22 = string.gsub(text22, "{br}", "\n")

	local value7

	value7 = value8 or 16

	local value9 = width.itemInfoSize
	local color = value6

	if (color == display.COLOR_WHITE or color == nil) and itemColorCfg and itemColorCfg[text22] ~= nil then
		local value11 = def.role.string2Color(itemColorCfg[text22].color or 223)

		if value11 then
			color = value11
		end
	end

	items[#items + 1] = an.newLabel(text22, value9, 1, {
		color = color
	})
	items[#items].__cname = "label"
	items[#items].noText = text22:match("^%s*$") ~= nil
	items[#items].text = text22
	items[#items].isHide = isHide

	local value13 = number
	local imgWidth = 0
	local enabled7 = false

	if addH > 0 then
		items[#items].addH = addH
	end

	if value10 then
		local img = value10:split("@")

		items[#items].img = img
		items[#items].imgdir = imgdir
		items[#items].imgScale = value12 or 1
		items[#items].needImg = true
		items[#items].offsetX = offsetX
		items[#items].offsetY = offsetY
		items[#items].offsetH = offsetH

		local value14 = _get2("pic/bzmir/effect/" .. imgdir .. "/" .. img[1] .. ".png"):anchor(0, 1):scale(value12 or 1)

		if value14 then
			imgWidth = value14:getw() * (value12 or 1)
			value13 = value13 - imgWidth - 2
		end

		items[#items].imgWidth = imgWidth
	end

	local text3 = ""
	local items4 = callback6(text22)
	local text4 = ""
	local count = 1

	if value10 then
		if value13 < items[#items]:getw() then
			local label = items[#items]

			for _, item in pairs(items4) do
				local value15 = text4 .. item

				label:setString(value15)

				if value13 < label:getw() and count < #items4 then
					text4 = ""

					local label2 = an.newLabel(text4, value9, 1, {
						color = color
					})

					label2.__cname = "label"

					if value10 then
						label2.needImg = true
						label2.imgWidth = imgWidth
					end

					if not items[#items].subLabels then
						items[#items].subLabels = {}
					end

					items[#items].subLabels[#items[#items].subLabels + 1] = label2
					label = label2

					local enabled8 = false
				else
					text4 = value15
				end

				count = count + 1
			end
		end
	elseif value13 < items[#items]:getw() then
		for _2, item2 in pairs(items4) do
			local value16 = text4 .. item2

			items[#items]:setString(value16)

			if value13 < items[#items]:getw() and count < #items4 then
				text4 = ""

				local label3 = an.newLabel(text4, value9, 1, {
					color = color
				})

				label3.__cname = "label"

				if value10 then
					label3.needImg = true
					label3.imgWidth = imgWidth
				end

				items[#items + 1] = label3

				local enabled9 = false
			else
				text4 = value16
			end

			count = count + 1
		end
	end

	return #items
end

local function add(self, value6, value7, value8, value9, value10)
	return callback8(self, value6, value7, value8, value9, value10)
end

local function callback9(self)
	local value6 = self:get("makeIndex")

	for index = 0, 16 do
		local value7 = g_data.equip.items[index]

		if value7 and value6 == value7:get("makeIndex") then
			return index
		end
	end

	return nil
end

local function callback10(self)
	local var = self.getVar("stdMode")
	local value6 = self:get("makeIndex")
	local items4 = {}
	local items5 = {}

	for index = 0, 16 do
		local value7 = g_data.equip.items[index]

		if value7 and value6 ~= value7:get("makeIndex") and (checkExist(var, 5, 6) and checkExist(value7.getVar("stdMode"), 5, 6) or checkExist(var, 10, 11) and checkExist(value7.getVar("stdMode"), 10, 11) or checkExist(var, 20, 21, 19) and checkExist(value7.getVar("stdMode"), 20, 21, 19) or checkExist(var, 22, 23) and checkExist(value7.getVar("stdMode"), 22, 23) or checkExist(var, 26, 24) and checkExist(value7.getVar("stdMode"), 26, 24) or var == value7.getVar("stdMode")) then
			items4[#items4 + 1] = value7
			items5[#items5 + 1] = index
		end
	end

	return items4, items5
end

local function callback11(self)
	return self >= 5 and self <= 29 or checkExist(self, 30, 34)
end

local function callback12(self, value6, value7, value8)
	local data = getData(value6) or 0

	if value7 then
		add(self .. data)

		return
	end

	local data2 = getData("max" .. value6) or 0

	if data > 0 or data2 > 0 then
		if def.noAfterWithGood then
			add(self .. data .. "-" .. data2)
		else
			local dataStd = getDataStd("max" .. value6)

			if value8 and dataStd and dataStd == 0 then
				return
			end

			if dataStd and dataStd < data2 and not callback4(getData("stdMode"), getData("shape")) then
				if value8 then
					add(self .. data .. "-" .. dataStd)
				else
					local value9 = display.COLOR_GREEN
					local text22 = data2 - dataStd
					local text3 = ""

					if def.newElements and def.newElements.jpStyle then
						for _, jpStyle in ipairs(def.newElements.jpStyle) do
							if jpStyle.rule and loadstring("return " .. jpStyle.rule:gsub("v", tostring(text22)))() then
								value9 = _stringToCorlor(jpStyle.color, display.COLOR_GREEN)

								if jpStyle.extFlag then
									text3 = jpStyle.extFlag
								end

								break
							end
						end
					end

					add(self .. data .. "-" .. data2 .. "  (+" .. text22 .. ")" .. text3, value9)
				end
			else
				add(self .. data .. "-" .. data2)
			end
		end
	end
end

local function callback13(text22, value6, normalValue, value7, attachText, value8)
	attachText = attachText or ""

	if value8 and normalValue then
		add(text22 .. normalValue .. attachText, value7)
	elseif normalValue and normalValue < value6 and not callback4(getData("stdMode"), getData("shape")) then
		add(text22 .. value6 .. attachText .. "  (+" .. value6 - normalValue .. attachText .. ")", display.COLOR_GREEN)
	else
		add(text22 .. value6 .. attachText, value7)
	end
end

local function callback14(a, b)
	if type(a) == "string" then
		a = tonumber(a)
	end

	return b <= a and display.COLOR_WHITE or display.COLOR_RED
end

function info.create(self, point, fromOwner2)
	local getVarOwner = self

	if not getVarOwner.getVar then
		getVarOwner = self.data
	end

	local items4, value6 = callback10(getVarOwner)
	local xOffset = 0
	local y = point.y
	local value7 = #items4 * xOffset
	local bgCount = 1
	local extra, value8 = info.show(getVarOwner, point, fromOwner2)

	if fromOwner2.from == "equip" or fromOwner2.from == "heroEquip" or fromOwner2.from == "heroBag" or not def.enableEquipPair then
		return extra
	end

	if not extra then
		return nil
	end

	local childByName = extra:getChildByName(items2[bgCount])

	if point.x > display.width / 2 then
		enabled2 = true
	else
		enabled2 = false
		xOffset = value8:getw()
	end

	local x = 0

	for itemId, item in pairs(items4) do
		if enabled2 then
			x = point.x - xOffset - 15
		else
			x = point.x
		end

		bgCount = bgCount + 1

		local point2, point3 = info.show(item, cc.p(x, y), {
			from = "equip",
			extra = extra,
			xOffset = xOffset,
			idx = value6[itemId],
			bgCount = bgCount
		})

		xOffset = xOffset + point3:getw()
	end

	return extra
end

function info.initRemote()
	if def.itemInfo then
		width.openItemInfoScroll = def.itemInfo.openItemInfoScroll
		width.itemInfoScrollMaxHeight = def.itemInfo.itemInfoScrollMaxHeight or 520
		width.itemInfoSize = def.itemInfo.itemInfoSize or 16
		width.itemInfoTitleSize = def.itemInfo.itemInfoTitleSize or 16
		width.openItemEffect = def.itemInfo.openItemEffect
		width.itemEffectNeedItems = def.itemInfo.itemEffectNeedItems or ""
		width.itemEffectHeight = def.itemInfo.itemEffectHeight or 634
		width.itemEffectWidth = def.itemInfo.itemEffectWidth or 278
		width.showItemLogo = def.itemInfo.showItemLogo
		width.itemLogoEffect = def.itemInfo.itemLogoEffect
		width.title_jpss = def.itemInfo.title_jpss or "[极品元素]@77"
	end
end

function info.addSpicalAttrRemote(self, value6, text22, value7)
	local function callback15(self2)
		local value62 = callback(self2) or 0
		local value72 = callback("max" .. self2) or 0

		if value62 > 0 or value72 > 0 then
			local value8 = callback2("max" .. self2)

			if value8 and value8 < value72 then
				return value72 - value8
			end
		end

		return 0
	end

	local function callback22()
		if not info.show_Jpss then
			local parts = string.split(text22.title_jpss, "@")

			callback8(parts[1], _stringToCorlor(parts[2], def.colors.get(251)))

			info.show_Jpss = true
		end
	end

	local function callback32(text23, text3)
		if text23:find("<") ~= nil then
			local value62 = text23:find("<")
			local value72 = text23:find(">")

			if value62 and value72 then
				local value8 = text23:sub(value62 + 1, value72 - 1)
				local text4 = loadstring("return " .. value8:gsub("v", tostring(text3)))()

				if text4 then
					local text5 = math.floor(text4)

					text23 = text23:sub(1, value62 - 1) .. tostring(text5) .. text23:sub(value72 + 1, #text23)
				end
			end
		end

		return text23
	end

	local function callback42(self2, text23)
		local parts = string.split(text23, "@")

		parts[1] = string.gsub(parts[1], "{v}", tostring(self2))
		parts[1] = callback32(parts[1], self2)

		callback8(parts[1], _stringToCorlor(parts[2], display.COLOR_WHITE))
	end

	local function callback52(self2, value62)
		if self2 > 0 and value62 then
			callback22()
			callback42(self2, value62)
		end
	end

	local parts = string.split(self, "#")
	local text3 = parts[1]

	if text3 then
		if text3:find("MAX") ~= nil then
			local count = 0
			local value8 = callback15("DC")

			if count < value8 then
				count = value8
			end

			local value9 = callback15("MC")

			if count < value9 then
				count = value9
			end

			local value10 = callback15("SC")

			if count < value10 then
				count = value10
			end

			if text3:find("_") ~= nil then
				local parts2 = string.split(text3, "_")

				if tonumber(parts2[2]) == count then
					callback52(count, parts[2])
				end
			elseif text3:find(">") ~= nil then
				local parts3 = string.split(text3, ">")

				if count > 0 and count > tonumber(parts3[2]) then
					callback52(count, parts[2])
				end
			elseif text3:find("<") ~= nil then
				local parts4 = string.split(text3, "<")

				if count > 0 and count < tonumber(parts4[2]) then
					callback52(count, parts[2])
				end
			else
				callback52(count, parts[2])
			end
		elseif text3:find("ALL") ~= nil then
			local value11 = 0 + callback15("DC") + callback15("MC") + callback15("SC")

			if text3 == "ALL" then
				callback52(value11, parts[2])
			elseif text3:find("_") ~= nil then
				local parts5 = string.split(text3, "_")

				if tonumber(parts5[2]) == value11 then
					callback52(value11, parts[2])
				end
			elseif text3:find(">") ~= nil then
				local parts6 = string.split(text3, ">")

				if value11 > 0 and value11 > tonumber(parts6[2]) then
					callback52(value11, parts[2])
				end
			elseif text3:find("<") ~= nil then
				local parts7 = string.split(text3, "<")

				if value11 > 0 and value11 < tonumber(parts7[2]) then
					callback52(value11, parts[2])
				end
			else
				callback52(value11, parts[2])
			end

			return true
		elseif text3:find("DM") ~= nil then
			local value12 = 0 + callback15("DC") + callback15("MC")

			if text3:find("_") ~= nil then
				local parts8 = string.split(text3, "_")

				if tonumber(parts8[2]) == value12 then
					callback52(value12, parts[2])
				end
			elseif text3:find(">") ~= nil then
				local parts9 = string.split(text3, ">")

				if value12 > 0 and value12 > tonumber(parts9[2]) then
					callback52(value12, parts[2])
				end
			elseif text3:find("<") ~= nil then
				local parts10 = string.split(text3, "<")

				if value12 > 0 and value12 < tonumber(parts10[2]) then
					callback52(value12, parts[2])
				end
			else
				callback52(value12, parts[2])
			end

			return true
		elseif text3:find("DS") ~= nil then
			local value13 = 0 + callback15("DC") + callback15("SC")

			if text3:find("_") ~= nil then
				local parts11 = string.split(text3, "_")

				if tonumber(parts11[2]) == value13 then
					callback52(value13, parts[2])
				end
			elseif text3:find(">") ~= nil then
				local parts12 = string.split(text3, ">")

				if value13 > 0 and value13 > tonumber(parts12[2]) then
					callback52(value13, parts[2])
				end
			elseif text3:find("<") ~= nil then
				local parts13 = string.split(text3, "<")

				if value13 > 0 and value13 < tonumber(parts13[2]) then
					callback52(value13, parts[2])
				end
			else
				callback52(value13, parts[2])
			end

			return true
		elseif text3:find("MS") ~= nil then
			local value14 = 0 + callback15("SC") + callback15("MC")

			if text3:find("_") ~= nil then
				local parts14 = string.split(text3, "_")

				if tonumber(parts14[2]) == value14 then
					callback52(value14, parts[2])
				end
			elseif text3:find(">") ~= nil then
				local parts15 = string.split(text3, ">")

				if value14 > 0 and value14 > tonumber(parts15[2]) then
					callback52(value14, parts[2])
				end
			elseif text3:find("<") ~= nil then
				local parts16 = string.split(text3, "<")

				if value14 > 0 and value14 < tonumber(parts16[2]) then
					callback52(value14, parts[2])
				end
			else
				callback52(value14, parts[2])
			end

			return true
		elseif text3:find("XY") ~= nil and getData("stdMode") == 19 then
			local data = getData("maxMAC")
			local dataStd = getDataStd("maxMAC")
			local count2 = 0

			if data > 0 and dataStd < data then
				count2 = data - dataStd
			end

			if count2 > 0 then
				if text3:find("_") ~= nil then
					local parts17 = string.split(text3, "_")

					if tonumber(parts17[2]) == count2 then
						callback52(count2, parts[2])
					end
				elseif text3:find(">") ~= nil then
					local parts18 = string.split(text3, ">")

					if count2 > 0 and count2 > tonumber(parts18[2]) then
						callback52(count2, parts[2])
					end
				elseif text3:find("<") ~= nil then
					local parts19 = string.split(text3, "<")

					if count2 > 0 and count2 < tonumber(parts19[2]) then
						callback52(count2, parts[2])
					end
				else
					callback52(count2, parts[2])
				end
			end
		else
			if text3:find("_") ~= nil then
				local parts20 = string.split(text3, "_")
				local value15 = callback15(parts20[1])

				if value15 == tonumber(parts20[2]) then
					callback52(value15, parts[2])
				end
			elseif text3:find(">") ~= nil then
				local parts21 = string.split(text3, ">")
				local value16 = callback15(parts21[1])

				if value16 > 0 and value16 > tonumber(parts21[2]) then
					callback52(value16, parts[2])
				end
			elseif text3:find("<") ~= nil then
				local parts22 = string.split(text3, "<")
				local value17 = callback15(parts22[1])

				if value17 > 0 and value17 < tonumber(parts22[2]) then
					callback52(value17, parts[2])
				end
			else
				local value18 = callback15(text3)

				callback52(value18, parts[2])
			end

			return true
		end
	end

	return false
end

function info.addSpicalAttr2Remote(self, value6, text22, value7, callback52)
	local function callback15(self2)
		local value62 = callback(self2) or 0
		local value72 = callback("max" .. self2) or 0

		if value62 > 0 or value72 > 0 then
			local value8 = callback2("max" .. self2)

			if value8 and value8 < value72 then
				return value72 - value8
			end
		end

		return 0
	end

	local function callback22(self2)
		local color = self2:split("@")
		local value62 = display.COLOR_WHITE

		if color[2] then
			value62 = _stringToCorlor(color[2])
		end

		return value62, color[1]
	end

	local function callback32()
		if text22.jp_Show.title and not info.show_Jpmw then
			local parts = string.split(text22.jp_Show.title, "@")

			callback8(parts[1], _stringToCorlor(parts[2], def.colors.get(251)))

			info.show_Jpmw = true
		end
	end

	local function callback42(text23, text3)
		if text23:find("<") ~= nil then
			local value62 = text23:find("<")
			local value72 = text23:find(">")

			if value62 and value72 then
				local value8 = text23:sub(value62 + 1, value72 - 1)
				local text4 = loadstring("return " .. value8:gsub("v", tostring(text3)))()

				if text4 then
					local text5 = math.floor(text4)

					text23 = text23:sub(1, value62 - 1) .. tostring(text5) .. text23:sub(value72 + 1, #text23)
				end
			end
		end

		return text23
	end

	local function callback62(self2, text23)
		if self2 then
			local parts = string.split(self2, "$")

			if #parts > 1 then
				if not enabled then
					callback52()

					enabled = true
				end

				callback32()

				local value62, text3 = callback22(parts[4] or "")
				local text4 = string.gsub(text3, "{v}", tostring(text23))
				local value72 = callback42(text4, text23)

				callback8(value72, value62, nil, parts[2], parts[1], tonumber(parts[3]) or 1, tonumber(parts[5]) or 0, tonumber(parts[6]) or 0, tonumber(parts[7]) or 0)
			end
		end
	end

	if self then
		if self:find("MAX") ~= nil then
			local count = 0
			local value8 = callback15("DC")

			if count < value8 then
				count = value8
			end

			local value9 = callback15("MC")

			if count < value9 then
				count = value9
			end

			local value10 = callback15("SC")

			if count < value10 then
				count = value10
			end

			local parts = string.split(self, "_")

			if tonumber(parts[2]) == count then
				callback62(value6, count)
			end
		elseif self:find("ALL") ~= nil then
			local value11 = 0 + callback15("DC") + callback15("MC") + callback15("SC")

			if self:find("_") ~= nil then
				local parts2 = string.split(self, "_")

				if tonumber(parts2[2]) == value11 then
					callback62(value6, value11)
				end
			elseif self:find(">") ~= nil then
				local parts3 = string.split(self, ">")

				if value11 > 0 and value11 > tonumber(parts3[2]) then
					callback62(value6, value11)
				end
			elseif self:find("<") ~= nil then
				local parts4 = string.split(self, "<")

				if value11 > 0 and value11 < tonumber(parts4[2]) then
					callback62(value6, value11)
				end
			else
				callback62(value6, value11)
			end

			return true
		elseif self:find("DM") ~= nil then
			local value12 = 0 + callback15("DC") + callback15("MC")

			if self:find("_") ~= nil then
				local parts5 = string.split(self, "_")

				if tonumber(parts5[2]) == value12 then
					callback62(value6, value12)
				end
			elseif self:find(">") ~= nil then
				local parts6 = string.split(self, ">")

				if value12 > 0 and value12 > tonumber(parts6[2]) then
					callback62(value6, value12)
				end
			elseif self:find("<") ~= nil then
				local parts7 = string.split(self, "<")

				if value12 > 0 and value12 < tonumber(parts7[2]) then
					callback62(value6, value12)
				end
			else
				callback62(value6, value12)
			end

			return true
		elseif self:find("DS") ~= nil then
			local value13 = 0 + callback15("DC") + callback15("SC")

			if self:find("_") ~= nil then
				local parts8 = string.split(self, "_")

				if tonumber(parts8[2]) == value13 then
					callback62(value6, value13)
				end
			elseif self:find(">") ~= nil then
				local parts9 = string.split(self, ">")

				if value13 > 0 and value13 > tonumber(parts9[2]) then
					callback62(value6, value13)
				end
			elseif self:find("<") ~= nil then
				local parts10 = string.split(self, "<")

				if value13 > 0 and value13 < tonumber(parts10[2]) then
					callback62(value6, value13)
				end
			else
				callback62(value6, value13)
			end

			return true
		elseif self:find("MS") ~= nil then
			local value14 = 0 + callback15("SC") + callback15("MC")

			if self:find("_") ~= nil then
				local parts11 = string.split(self, "_")

				if tonumber(parts11[2]) == value14 then
					callback62(value6, value14)
				end
			elseif self:find(">") ~= nil then
				local parts12 = string.split(self, ">")

				if value14 > 0 and value14 > tonumber(parts12[2]) then
					callback62(value6, value14)
				end
			elseif self:find("<") ~= nil then
				local parts13 = string.split(self, "<")

				if value14 > 0 and value14 < tonumber(parts13[2]) then
					callback62(value6, value14)
				end
			else
				callback62(value6, value14)
			end

			return true
		elseif self:find("XY") ~= nil and getData("stdMode") == 19 then
			local data = getData("maxMAC")
			local dataStd = getDataStd("maxMAC") or 0
			local count2 = 0

			if data > 0 and dataStd < data then
				count2 = data - dataStd
			end

			if count2 > 0 then
				if self:find("_") ~= nil then
					local parts14 = string.split(self, "_")

					if tonumber(parts14[2]) == count2 then
						callback62(count2, strs[2])
					end
				elseif self:find(">") ~= nil then
					local parts15 = string.split(self, ">")

					if count2 > 0 and count2 > tonumber(parts15[2]) then
						callback62(count2, strs[2])
					end
				elseif self:find("<") ~= nil then
					local parts16 = string.split(self, "<")

					if count2 > 0 and count2 < tonumber(parts16[2]) then
						callback62(count2, strs[2])
					end
				else
					callback62(count2, strs[2])
				end
			end
		else
			if self:find("_") ~= nil then
				local parts17 = string.split(self, "_")
				local value15 = callback15(parts17[1])

				if value15 == tonumber(parts17[2]) then
					callback62(value6, value15)
				end
			elseif self:find(">") ~= nil then
				local parts18 = string.split(self, ">")
				local value16 = callback15(parts18[1])

				if value16 > 0 and value16 > tonumber(parts18[2]) then
					callback62(value6, value16)
				end
			elseif self:find("<") ~= nil then
				local parts19 = string.split(self, "<")
				local value17 = callback15(parts19[1])

				if value17 > 0 and value17 < tonumber(parts19[2]) then
					callback62(value6, value17)
				end
			else
				local value18 = callback15(self)

				callback62(value6, value18)
			end

			return true
		end
	end
end

function info.findByNameOrMode(self, text3, value6)
	local text22 = value6[self] or value6[tostring(text3)]

	if not text22 then
		local text4 = string.gsub(self, "+", "^")
		local value7 = text2(text4)
		local value8 = value7

		if value7:find("^") ~= nil then
			value8 = value7:split("^")[1]
		end

		for itemId, item in pairs(value6) do
			local text5 = string.gsub(itemId, "+", "^")
			local value9 = text2(text5)

			if value9 == "ALL" or value9:match(value7) or value9:match(value8 .. "^ALL") or value9:match(tostring(text3)) then
				text22 = item

				break
			end
		end
	end

	return text22
end

function info.addSpicalAttr3(self, jp_ShowOwner, value6, value7)
	if jp_ShowOwner and jp_ShowOwner.jp_Show then
		local var = self.getVar("name")
		local var2 = self.getVar("stdMode")
		local byNameOrMode = info.findByNameOrMode(var, var2, jp_ShowOwner.jp_Show)

		if byNameOrMode then
			for itemId, item in pairs(byNameOrMode) do
				info.addSpicalAttr2(itemId, item, jp_ShowOwner, value6, value7)
			end
		end
	end
end

function info.addBreakLevel(self, text22)
	local function callback15(self2)
		local color = self2:split("@")
		local value6 = display.COLOR_WHITE

		if color[2] then
			value6 = _stringToCorlor(color[2])
		end

		return value6, color[1]
	end

	if def.makeValues and def.makeValues[self:get("makeIndex")] and text22 and text22.breaklevel_Show then
		local var = self.getVar("name")
		local var2 = self.getVar("stdMode")
		local byNameOrMode = info.findByNameOrMode(var, var2, text22.breaklevel_Show)

		if byNameOrMode then
			local text3 = def.makeValues[self:get("makeIndex")]
			local text4 = byNameOrMode["BL_" .. tostring(text3.key)]

			if text4 then
				if text22.breaklevel_Show.title then
					local parts = string.split(text22.breaklevel_Show.title, "@")

					callback8(parts[1], _stringToCorlor(parts[2], def.colors.get(251)))
				end

				local parts2 = string.split(text4, "$")

				if #parts2 > 1 then
					local value6, text5 = callback15(parts2[4] or "")

					if text3.v1 then
						text5 = string.gsub(text5, "{v1}", tostring(text3.v1))
					end

					callback8(text5, value6, nil, parts2[2], parts2[1], tonumber(parts2[3]) or 1, tonumber(parts2[5]) or 0, tonumber(parts2[6]) or 0, tonumber(parts2[7]) or 0)
				end
			end
		end
	end
end

function info.extendName(self, jp_CusnameOwner, value6)
	local function callback15(self2)
		local value62 = callback(self2) or 0
		local text22 = "max" .. self2
		local value7 = callback(text22) or 0

		if value62 > 0 or value7 > 0 then
			local value8 = callback2(text22)

			if value8 and value8 < value7 then
				return value7 - value8
			end
		end

		return 0
	end

	if text then
		local parts = string.split(text, "@")

		if parts[2] then
			return self .. parts[1], parts[2]
		else
			return self .. parts[1]
		end
	elseif jp_CusnameOwner and jp_CusnameOwner.jp_Cusname then
		local var = value6.getVar("name")
		local var2 = value6.getVar("stdMode")
		local byNameOrMode = info.findByNameOrMode(var, var2, jp_CusnameOwner.jp_Cusname)

		if not byNameOrMode then
			return self
		end

		local value7 = 0 + callback15("DC") + callback15("MC") + callback15("SC")
		local text22 = "ALL_" .. value7
		local text3 = "DC_" .. callback15("DC")
		local text4 = "SC_" .. callback15("SC")
		local text5 = "MC_" .. callback15("MC")

		for itemId, item in pairs(byNameOrMode) do
			local text6

			if itemId:find(">") ~= nil then
				local parts2 = string.split(itemId, ">")

				if parts2[2] and value7 > tonumber(parts2[2]) then
					text6 = item
				end
			elseif itemId == text22 then
				text6 = item
			elseif itemId == text3 then
				text6 = item
			elseif itemId == text4 then
				text6 = item
			elseif itemId == text5 then
				text6 = item
			end

			if text6 then
				local parts3 = string.split(text6, "@")

				if parts3[2] then
					return self .. parts3[1], parts3[2]
				else
					return self .. parts3[1]
				end
			end
		end
	end

	return self
end

function info.init()
	if info.initRemote then
		info.initRemote()
	end
end

function info.addSpicalAttr(self, value6)
	if info.addSpicalAttrRemote then
		info.addSpicalAttrRemote(self, value6, width, enabled5)
	end
end

function info.addSpicalAttr2(self, value6, value7, value8, value9)
	if info.addSpicalAttr2Remote then
		info.addSpicalAttr2Remote(self, value6, value7, value8, value9)
	end
end

local function callback15(self)
	local color = self:split("@")

	return _stringToCorlor(color[2], display.COLOR_WHITE), color[1]
end

local function callback16(self, value6, value7, text22, items4, value8, text4, value10, value11)
	if not self then
		return
	end

	local color

	if not _gettex2 then
		_gettex2 = res.gettex2
	end

	local function callback17(self2)
		if self2:find("<") ~= nil then
			local value62 = self2:find("<")
			local value72 = self2:find(">")

			if value62 and value72 then
				return self2:sub(value62 + 1, value72 - 1), value62, value72
			end
		end

		return nil
	end

	local function callback22(self2)
		if self2 then
			local text23 = loadstring("return " .. self2:gsub("v", tostring(self)))()

			if text23 then
				return (math.floor(text23))
			end
		end

		return nil
	end

	local function callback32(text23)
		while true do
			if text23:find("<") == nil then
				break
			end

			local value62, value72, value82 = callback17(text23)

			if value62 then
				local text3 = callback22(value62)

				if text3 then
					text23 = text23:sub(1, value72 - 1) .. tostring(text3) .. text23:sub(value82 + 1, #text23)
				end
			end
		end

		return text23
	end

	;(function()
		for _, item in pairs(value6) do
			if item.rules then
				local enabled7 = true

				for _2, rule in pairs(item.rules) do
					if not enabled7 then
						break
					end

					local items42 = rule:split("|")

					if rule:find("{v}") ~= nil then
						if #items42 == 3 and checkExist(items42[2], ">", "<", "=", ">=", "<=") then
							if items42[2] == ">" then
								enabled7 = enabled7 and self > tonumber(items42[3])
							elseif items42[2] == ">=" then
								enabled7 = enabled7 and self >= tonumber(items42[3])
							elseif items42[2] == "<" then
								enabled7 = enabled7 and self < tonumber(items42[3])
							elseif items42[2] == "<=" then
								enabled7 = enabled7 and self <= tonumber(items42[3])
							elseif items42[2] == "=" then
								enabled7 = enabled7 and self == tonumber(items42[3])
							end
						else
							print("语法错误:" .. rule)

							enabled7 = false
						end
					elseif rule:find("{nameExist}") ~= nil then
						if #items42 == 2 then
							enabled7 = enabled7 and checkExist(value7, unpack(items42[2]:split(",")))
						else
							print("语法错误:" .. rule)

							enabled7 = false
						end
					elseif rule:find("{stdModeExist}") ~= nil then
						if #items42 == 2 then
							enabled7 = enabled7 and checkExist(tostring(text22), unpack(items42[2]:split(",")))
						else
							print("语法错误:" .. rule)

							enabled7 = false
						end
					end
				end

				if enabled7 then
					color = item

					break
				end
			end
		end
	end)()

	if color then
		if not value10 and color.title then
			local color2 = color.title:split("@")
			local text3 = callback32(color2[1]):gsub("{v}", tostring(self))

			callback8(text3, color2[2] and _stringToCorlor(color2[2], def.colors.get(251)))
		end

		if color.itemNameExt then
			text = color.itemNameExt
		end

		if color.stars then
			local value9 = callback17(color.stars)

			if value9 then
				value2 = callback22(value9)
			end
		end

		if color.results then
			color = color.results

			if color.desc then
				for _, desc in pairs(color.desc) do
					local parts = string.split(desc, "$")

					if #parts > 1 then
						local value12, value13 = callback15(parts[4])
						local text5 = callback32(value13)
						local text6 = callback32(parts[2]):gsub("{v}", tostring(self))
						local text7 = text5 and string.gsub(text5, "{v}", tostring(self)) or " "
						local imgdir = parts[1]
						local number3 = tonumber(parts[3])
						local offsetX = tonumber(parts[5]) or 0
						local offsetY = tonumber(parts[6]) or 0
						local offsetH = tonumber(parts[7]) or 0

						if text7:find("{") ~= nil and text7:find("}") ~= nil then
							local img = text6:split("@")
							local value14 = _get2("pic/bzmir/effect/" .. imgdir .. "/" .. img[1] .. ".png")
							local imgWidth = 0

							if value14 then
								imgWidth = value14:getw() * (number3 or 1)
							end

							local value15 = number - imgWidth - 2

							if value15 < 32 then
								value15 = number
							end

							local label = an.newLabelM(value15, width.itemInfoSize or 16, 1, {
								manual = false
							})

							string.parseContent(label, text7, "{", "}")

							label.__cname = "labelM"
							label.img = img
							label.imgdir = imgdir
							label.imgScale = number3 or 1
							label.imgWidth = imgWidth
							label.needImg = true
							label.offsetX = offsetX
							label.offsetY = offsetY
							label.offsetH = offsetH
							items4[#items4 + 1] = label
						else
							callback8(text7, value12, nil, text6, imgdir, number3, offsetX, offsetY, offsetH)
						end
					else
						local value16, value17 = callback15(parts[1])
						local text8 = callback32(value17)
						local text9 = string.gsub(text8, "{v}", tostring(self))

						if text9:find("{") ~= nil and text9:find("}") ~= nil then
							local label2 = an.newLabelM(number, width.itemInfoSize or 16, 1, {
								manual = false
							})

							string.parseContent(label2, text9, "{", "}")

							label2.__cname = "labelM"
							items4[#items4 + 1] = label2
						else
							local value18, value19 = callback15(parts[1])
							local text10 = callback32(value19)

							callback8(string.gsub(text10, "{v}", tostring(self)), value18)
						end
					end
				end
			end

			if color.progressBar then
				local text11 = "pic/bzmir/effect/progress/" .. color.progressBar.folder .. "/"
				local progress = an.newProgress(_gettex2(text11 .. color.progressBar.full), _gettex2(text11 .. color.progressBar.empty), color.progressBar.offset)

				progress.__cname = "progress"
				progress.offsetX = color.progressBar.offsetX
				progress.offsetY = color.progressBar.offsetY
				progress.offsetH = color.progressBar.offsetH

				local value20 = color.progressBar.max

				if color.progressBar.sMax then
					local value21, value22, value23 = callback17(color.progressBar.sMax)

					if value21 then
						local value24 = callback22(value21)

						if value24 then
							value20 = value24
						end
					end
				end

				local value25 = self / value20

				if value25 > 1 then
					value25 = 1
				end

				if value25 < 0 then
					value25 = 0
				end

				progress:setp(value25)

				items4[#items4 + 1] = progress
			end

			if color.button and value8 == "equip" then
				local text12 = "pic/bzmir/effect/" .. color.button.folder .. "/"
				local items5 = {}
				local value26 = _gettex2(text12 .. color.button.bg)

				if color.button.text then
					items5.label = {
						color.button.text,
						color.button.fontSize or 16,
						1,
						{
							color = color.button.fontColor and _stringToCorlor(color.button.fontColor, cc.c3b(245, 245, 245))
						}
					}
				end

				if color.button.pressBg then
					items5.pressImage = _gettex2(text12 .. color.button.pressBg)
				else
					items5.pressBig = true
				end

				local btn = an.newBtn(value26, function()
					sound.playSound("103")

					if color.button.command then
						def.role.call("@" .. color.button.command .. "~" .. (text4 and tostring(text4) or ""))
					end
				end, items5):scale(color.button.scale or 1)

				btn.__cname = "button"
				btn.offsetX = color.button.offsetX
				btn.offsetY = color.button.offsetY
				btn.offsetH = color.button.offsetH
				items4[#items4 + 1] = btn
			end
		end

		if value11 then
			items4[value11].isHide = false
		end
	end
end

function info.showElements(self, data, options, options2, options3, options4, options5, options6, options7)
	return callback16(self, data, options, options2, options3, options4, options5, options6, options7)
end

function info.show(data, scenePos, params)
	params = params or {}
	value = data
	fromOwner = params
	info.show_Jpss = false
	info.show_Jpmw = false
	enabled = false
	text = nil
	value2 = nil

	if bzelements then
		bzelements = nil
	end

	if def.itemInfoMaxWidth then
		number = def.itemInfoMaxWidth
		number2 = def.itemInfoMaxWidth + 40
	end

	local value6
	local value7
	local items4 = {}
	local items5 = {}

	if ipush then
		local callback17 = ipush[1]
		local callback22 = ipush[2]

		items4 = callback17 and callback17(data) or {}
		items5 = callback22 and callback22(data) or {}
	end

	local layer
	local height = width.itemInfoScrollMaxHeight

	if params.extra then
		layer = params.extra
	else
		if g_data.player.showTips then
			return
		end

		g_data.player.showTips = true
		layer = display.newNode():size(display.width, display.height):addto(params.parent or display.getRunningScene(), params.z or an.z.max)
		info.layer = layer

		layer:setTag(2020)

		layer.params = params

		layer.setTouchEnabled(layer, true)
		layer.setTouchSwallowEnabled(layer, false)
		layer.addNodeEventListener(layer, cc.NODE_TOUCH_CAPTURE_EVENT, function(nameOwner)
			if nameOwner.name == "began" then
				enabled3 = false
			elseif nameOwner.name == "ended" and not enabled3 then
				g_data.player.showTips = false

				info.layer:runs({
					cc.DelayTime:create(0.01),
					cc.RemoveSelf:create(true)
				})
			end

			return true
		end)
	end

	local playerorhero

	if params.from == "heroBag" or params.from == "heroEquip" then
		playerorhero = g_data.hero
	elseif params.from == "bag" or params.from == "equip" then
		playerorhero = g_data.player
	else
		playerorhero = g_data.player
	end

	info.init()

	itemColorCfg = def.role.getItemColorCfg()

	local node = display.newNode()
	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(layer):anchor(0, 1)
	local data2 = getData("name")
	local stdMode = getData("stdMode")

	items = {}

	local function callback32(offsetH, value62, isHide)
		if not def.itemShowLine then
			return
		end

		local data3 = getData("stdMode")

		if callback11(data3) or value62 then
			local value_2 = res.get2("pic/common/line_item.png")

			value_2.__cname = "line"
			value_2.offsetH = offsetH
			value_2.isHide = isHide
			items[#items + 1] = value_2

			return #items
		end
	end

	local enabled7 = true
	local enabled8 = false
	local enabled9 = false
	local enabled10 = false
	local enabled11 = false
	local enabled12 = false
	local enabled13 = false

	if def.closeBaseAttributes then
		local function callback42(self)
			local value62 = def.closeBaseAttributes.jpAfterHide[self]

			if value62 then
				if value62 == "ALL" then
					return true
				elseif checkExist(data2, unpack(value62:split(","))) then
					return true
				end
			end

			return false
		end

		if bzelementsAoth and def.closeBaseAttributes.open and def.closeBaseAttributes.items then
			if def.closeBaseAttributes.items == "ALL" then
				enabled7 = false
			elseif checkExist(data2, unpack(def.closeBaseAttributes.items:split(","))) then
				enabled7 = false
			end
		end

		if def.closeBaseAttributes.jpAfterHide then
			enabled8 = callback42("DC")
			enabled10 = callback42("SC")
			enabled9 = callback42("MC")
			enabled11 = callback42("AC")
			enabled12 = callback42("MAC")
			enabled13 = callback42("ZQ")
		end
	end

	if not def.hideItemInfoImg then
		enabled4 = true
	end

	local function callback52(key)
		local front = getData(key) or 0
		local after = getData("max" .. key) or 0

		if front > 0 or after > 0 then
			local normalAfter = getDataStd("max" .. key)

			if normalAfter and normalAfter < after then
				return after - normalAfter
			end
		end

		return -1
	end

	local function addNeed()
		if not enabled7 then
			return
		end

		local need = getData("need")
		local needLevel = getData("needLevel")
		local data3 = getData("aniCount")

		if needLevel ~= 0 then
			if need == 0 then
				add("需要" .. CS_LEVEL .. ": " .. needLevel .. "级", callback14(playerorhero.ability:get("level"), needLevel))
			elseif need == 1 then
				add("需要攻击力: " .. needLevel, callback14(playerorhero.ability:get("maxDC"), needLevel))
			elseif need == 2 then
				add("需要魔法力: " .. needLevel, callback14(playerorhero.ability:get("maxMC"), needLevel))
			elseif need == 3 then
				add("需要道术力: " .. needLevel, callback14(playerorhero.ability:get("maxSC"), needLevel))
			elseif need == 4 then
				add("需要转生" .. CS_LEVEL .. ": " .. needLevel, callback14(g_data.player.ability3:get("prestige"), needLevel))
			elseif need == 40 then
				add("需要转生&" .. CS_LEVEL .. ": " .. needLevel, display.COLOR_WHITE)
			elseif need == 41 then
				add("需要转生&" .. CS_DC .. ": " .. needLevel, display.COLOR_WHITE)
			elseif need == 42 then
				add("需要转生&" .. CS_MC .. ": " .. needLevel, display.COLOR_WHITE)
			elseif need == 43 then
				add("需要转生&" .. CS_SC .. ": " .. needLevel, display.COLOR_WHITE)
			elseif need == 44 then
				add("需要转生&" .. CS_PRESTIGE .. ": " .. needLevel, display.COLOR_WHITE)
			elseif need == 5 then
				add("需要转生&" .. CS_PRESTIGE .. ": " .. needLevel, display.COLOR_WHITE)
			end
		end

		if need == 6 then
			add("行会成员专用", display.COLOR_WHITE)
		elseif need == 60 then
			add("行会掌门专用", display.COLOR_WHITE)
		elseif need == 7 then
			add("沙城成员专用", display.COLOR_WHITE)
		elseif need == 70 then
			add("沙城掌门专用", display.COLOR_WHITE)
		elseif need == 8 then
			add("会员专用", display.COLOR_WHITE)
		elseif need == 81 then
			add("会员类型 =" .. Loword(needLevel) .. "&" .. CS_LEVEL .. ">=" .. Hiword(needLevel), display.COLOR_WHITE)
		elseif need == 82 then
			add("会员类型 >= " .. Loword(needLevel) .. "&" .. CS_LEVEL .. ">=" .. Hiword(needLevel), display.COLOR_WHITE)
		end

		local dataStd = getDataStd("needJob")
		local value62
		local items42 = {}
		local items52 = {}

		if dataStd == 1 then
			items52[#items52 + 1] = "战士"
			items42[#items42 + 1] = 0
		end

		if dataStd == 2 then
			items52[#items52 + 1] = "法师"
			items42[#items42 + 1] = 1
		end

		if dataStd == 4 then
			items52[#items52 + 1] = "道士"
			items42[#items42 + 1] = 2
		elseif dataStd >= 8 and def.jobMaps and def.jobMaps[tostring(dataStd)] then
			items52[#items52 + 1] = def.jobMaps[tostring(dataStd)].name or "未知职业"
			items42[#items42 + 1] = dataStd
		end

		local value72 = g_data.player.job
		local number3 = -1

		if checkExist(value72, unpack(items42)) then
			number3 = 1
		end

		if items52 and #items52 ~= 3 and dataStd ~= 7 then
			add(CS_JOB .. ": " .. table.concat(items52, " "), callback14(number3, 0))
		end
	end

	local function addNeed2(self)
		return
	end

	local function tmpModf(value62)
		local int, f = math.modf(value62)

		return f >= 0.5 and int + 1 or int
	end

	local function getDuraColor(v)
		v = v or 1000

		local value62 = data:get("dura")

		if value62 then
			return tmpModf(Word(value62 or getData("duraMax")) / v) == 0 and display.COLOR_RED or display.COLOR_WHITE
		else
			return display.COLOR_WHITE
		end
	end

	local function duraStr(self)
		self = self or 1000

		local text22 = ""
		local value62 = data:get("dura")

		if params.onlyStdItem then
			text22 = params.hideMaxDura and "-/-" or math.modf(Word(getData("duraMax")) / self)
		end

		if params.hideMaxDura then
			if value62 then
				text22 = tmpModf(Word(value62) / self)
			else
				text22 = tmpModf(Word(getData("duraMax")) / self)
			end
		elseif value62 then
			text22 = tmpModf(Word(value62) / self) .. "/" .. tmpModf(Word(getData("duraMax")) / self)
		else
			text22 = tmpModf(Word(getData("duraMax")) / self) .. "/" .. tmpModf(Word(getData("duraMax")) / self)
		end

		return text22
	end

	local function callback62()
		if not enabled7 then
			return
		end

		local data3 = getData("Memo")
		local value62 = common.decodeMemo(data3)

		for itemId, item in pairs(value62) do
			if itemId == "NeedSkillIdx" and item[1] and item[2] then
				local number3 = tonumber(item[2])
				local number4 = tonumber(item[1])
				local magic = g_data.player:getMagic(number4)
				local magicConfigByUid = def.magic.getMagicConfigByUid(number4, main_scene.ground.player)

				if not magic then
					magic = {}
					magic.FLevel = 0
				end

				magic.FMagicName = magicConfigByUid.name or ""

				if magicConfigByUid.name and string.find(magicConfigByUid.name, "|") ~= nil then
					local parts = string.split(magicConfigByUid.name, "|")
					local value72 = g_data.player.job

					if value72 >= 8 then
						value72 = value72 - 5
					end

					magic.FMagicName = parts[value72 + 1]
				end

				if magicConfigByUid.extName then
					magic.FMagicName = magic.FMagicName .. magicConfigByUid.extName
				end

				add("需要" .. magic.FMagicName .. "：" .. number3 .. "级", callback14(magic.FLevel, number3))
			end
		end
	end

	local function callback72()
		local number3 = getData("AttributeRefin") and tonumber(getData("AttributeRefin"))
		local value62 = cc.c3b(0, 176, 240)

		if number3 and number3 >= 1 then
			if number3 == 1 then
				add("[可精炼]", value62)
			elseif number3 == 2 then
				local identifyListByIdx = def.identify.getIdentifyListByIdx(data.FIndex)

				if type(identifyListByIdx) == "table" then
					add("精炼属性：", value62)

					for _, item in pairs(identifyListByIdx) do
						add(item.text .. item.value, value62)
					end
				end
			end
		end
	end

	local btns = {}
	local value8 = #items

	if stdMode then
		local data3 = getData("weight")

		add("重量: " .. data3, display.COLOR_WHITE)

		if stdMode == 0 then
			if getData("AC") > 0 then
				add("HP+" .. getData("AC"), display.COLOR_GREEN)
			end

			if getData("MAC") > 0 then
				add("MP+" .. getData("MAC"), display.COLOR_GREEN)
			end
		elseif stdMode == 1 then
			local shape = getData("shape") or 0

			if checkExist(shape, 1, 2, 5, 6, 7) then
				add("持续: " .. duraStr() .. " 小时")
			elseif checkExist(shape, 3, 4, 8, 9, 10) then
				add("累积: " .. duraStr() .. " 小时")
			elseif shape == 30 then
				add("使用: " .. duraStr(10) .. " 次")
			elseif shape == 34 then
				add("持久: " .. duraStr(1))
			elseif shape == 35 then
				add("使用: " .. duraStr(1) .. " 次")
			end
		elseif stdMode == 2 then
			local shape2 = getData("shape") or 0

			if shape2 == 9 then
				add("修复装备持久: " .. duraStr(100) .. "点", display.COLOR_GREEN)
			elseif shape2 == 20 then
				add("容量: " .. duraStr(), display.COLOR_GREEN)
				add(CS_LEVEL .. ": " .. getData("needLevel"), display.COLOR_GREEN)
				add("品质: " .. getData("source"), display.COLOR_GREEN)
				add("酒精度: " .. getData("aniCount") .. "C°", display.COLOR_GREEN)
			elseif shape2 == 21 then
				add("品质: " .. getData("source"), display.COLOR_GREEN)
			elseif checkExist(shape2, 10, 23) and julingzhu then
				local value9, value10 = julingzhu(tmpModf, data)

				if value10 <= value9 then
					add("已储：" .. value9 .. "/" .. value10 .. "经验", display.COLOR_GREEN)
					add("已储满可以使用了，双击就能获得经验！", display.COLOR_GREEN)
				else
					add("已储：" .. value9 .. "/" .. value10 .. "经验", display.COLOR_RED)
					add("储满才能双击使用！", display.COLOR_GREEN)
				end
			else
				add("可用: " .. duraStr() .. "次", display.COLOR_GREEN)
			end
		elseif stdMode == 4 then
			local shape3 = getData("shape") or 0

			if checkExist(shape3, 0, 1, 2) then
				local names = {
					"战士秘籍",
					"魔法秘籍",
					"道士秘籍"
				}

				add(names[shape3 + 1], display.COLOR_GREEN)
			end

			if def.openMultiJob and shape3 > 2 and def.jobMaps and def.jobMaps[tostring(shape3)] then
				local text22 = def.jobMaps[tostring(shape3)]

				if text22.skillBookName then
					add(text22.skillBookName, display.COLOR_GREEN)
				else
					add("技能秘籍", display.COLOR_RED)
				end
			end

			if not params.hideMaxDura and enabled7 then
				local needLevel = math.modf(Word(getData("duraMax")))

				add("需要" .. CS_LEVEL .. ": " .. needLevel .. "级", callback14(playerorhero.ability:get("level"), needLevel))
			end
		elseif checkExist(stdMode, 5, 6) then
			if isUpgrade() then
				items[1]:setString("(可升级)" .. getData("name"))
				items[1]:setColor(display.COLOR_GREEN)
			end

			add("持久: " .. duraStr(), getDuraColor())

			if def.enableItemInfoGroupTips and enabled7 then
				add(CS_BASEITEMDESC, def.colors.get(251))
			end

			if enabled7 then
				callback12(CS_FULLDC .. ": ", "DC", nil, enabled8)
				callback12(CS_FULLMC .. ": ", "MC", nil, enabled9)
				callback12(CS_FULLSC .. ": ", "SC", nil, enabled10)
			end

			local source = getData("source")
			local sourceN = getDataStd("source")

			if enabled7 then
				if checkIn(source, 1, 10) then
					callback13("强度: +", source, sourceN)
				elseif checkIn(source, -50, -1) then
					callback13("神圣: +", -source, -sourceN, display.COLOR_WHITE)
				elseif checkIn(source, -100, -51) then
					add("神圣: -" .. -source - 50, display.COLOR_RED)
				end
			end

			local AC = getData("AC")
			local maxAC = getData("maxAC")
			local MAC = getData("MAC")
			local maxMAC = getData("maxMAC")
			local ACN = getDataStd("AC")
			local maxACN = getDataStd("maxAC")
			local MACN = getDataStd("MAC")
			local maxMACN = getDataStd("maxMAC")

			if maxAC > 0 and enabled7 then
				local ac = getData("accurate") or maxAC

				callback13(CS_HIT .. ": +", ac, maxACN, display.COLOR_WHITE, nil, enabled13)
			end

			if maxMAC > 0 then
				if maxMAC > 10 then
					if macN then
						macN = maxMACN
						macN = macN > 10 and macN - 10 or macN
					end

					if enabled7 then
						callback13("攻击速度: +", maxMAC - 10, macN, display.COLOR_WHITE)
					end
				elseif enabled7 then
					add("攻击速度: -" .. maxMAC, display.COLOR_RED)
				end
			end

			if AC > 0 and enabled7 then
				callback13("幸运值: +", AC, acN or ACN, display.COLOR_WHITE)
			end

			if MAC > 0 and enabled7 then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end

			addNeed()
			addNeed2()
		elseif stdMode == 7 then
			local shape4 = getData("shape") or 0

			if checkExist(shape4, 0, 1, 2, 3) then
				local front = {
					"次数: ",
					"HP ",
					"MP ",
					"HPMP "
				}
				local after = {
					" 次",
					" 万",
					" 万",
					" 万"
				}

				add(front[shape4 + 1] .. duraStr() .. after[shape4 + 1])
			end

			addNeed()
			addNeed2()
		elseif checkExist(stdMode, 10, 11) then
			add("持久: " .. duraStr(), getDuraColor())

			if def.enableItemInfoGroupTips and enabled7 then
				add(CS_BASEITEMDESC, def.colors.get(251))
			end

			if enabled7 then
				callback12(CS_AC .. ": ", "AC", nil, enabled11)
				callback12(CS_MAC .. ": ", "MAC", nil, enabled12)
				callback12(CS_FULLDC .. ": ", "DC", nil, enabled8)
				callback12(CS_FULLMC .. ": ", "MC", nil, enabled9)
				callback12(CS_FULLSC .. ": ", "SC", nil, enabled10)

				if getData("intparam2") > 0 then
					callback12(CS_HP .. ": ", "intparam2", true, enabled10)
				end
			end

			local source2 = getData("source")
			local sourceN2 = getDataStd("source")

			if Lobyte(source2) > 0 and enabled7 then
				callback13("幸运值: +", Lobyte(source2), sourceN2 and Lobyte(sourceN2), display.COLOR_WHITE)
			end

			if Hibyte(source2) > 0 and enabled7 then
				add("诅咒: +" .. Hibyte(source2), display.COLOR_RED)
			end

			addNeed()
			addNeed2()
		elseif checkExist(stdMode, 15, 16, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 34, 52, 62, 53, 63, 54, 64) then
			if getData("shape") == 188 then
				local name = getData("name")
			end

			if not getData("shape") then
				local count = 0
			end

			if stdMode ~= 64 then
				add("持久: " .. duraStr(), getDuraColor())
			end

			if def.enableItemInfoGroupTips and enabled7 then
				add(CS_BASEITEMDESC, def.colors.get(251))
			end

			if not getData("shape") then
				local count2 = 0
			end

			local AC2 = getData("AC")
			local maxAC2 = getData("maxAC")
			local MAC2 = getData("MAC")
			local maxMAC2 = getData("maxMAC")
			local ACN2 = getDataStd("AC")
			local maxACN2 = getDataStd("maxAC")
			local MACN2 = getDataStd("MAC")
			local maxMACN2 = getDataStd("maxMAC")
			local dataStd = getDataStd("CC")
			local dataStd2 = getDataStd("maxCC")

			if stdMode == 19 or stdMode == 53 then
				if maxAC2 > 0 and enabled7 then
					callback13(CS_ANTI .. ": +", maxAC2, maxACN2, display.COLOR_WHITE, "0％")
				end

				if MAC2 > 0 and enabled7 then
					add("诅咒: +" .. MAC2, display.COLOR_RED)
				end

				if maxMAC2 > 0 and enabled7 then
					callback13("幸运值: +", maxMAC2, maxMACN2, display.COLOR_WHITE)
				end
			elseif stdMode == 20 or stdMode == 24 then
				if maxAC2 > 0 and enabled7 then
					callback13(CS_HIT .. ": +", maxAC2, maxACN2, display.COLOR_WHITE, nil, enabled13)
				end

				if maxMAC2 > 0 and enabled7 then
					callback13(CS_QUICK .. ": +", maxMAC2, maxMACN2, display.COLOR_WHITE)
				end
			elseif stdMode == 21 then
				if maxAC2 > 0 and enabled7 then
					callback13(CS_HPR .. ": +", maxAC2, maxACN2, display.COLOR_WHITE, "0％")
				end

				if maxMAC2 > 0 and enabled7 then
					callback13(CS_MPR .. ": +", maxMAC2, maxMACN2, display.COLOR_WHITE, "0％")
				end

				if AC2 > 0 and enabled7 then
					callback13("攻击速度: +", AC2, ACN2, display.COLOR_WHITE)
				end

				if MAC2 > 0 and enabled7 then
					add("攻击速度: -" .. MAC2, display.COLOR_RED)
				end
			elseif stdMode == 23 then
				if maxAC2 > 0 and enabled7 then
					callback13(CS_POIS .. ": +", maxAC2, maxACN2, display.COLOR_WHITE, "0％")
				end

				if maxMAC2 > 0 and enabled7 then
					callback13(CS_BUPOIS .. ": +", maxMAC2, maxMACN2, display.COLOR_WHITE, "0％")
				end

				if AC2 > 0 and enabled7 then
					callback13("攻击速度: +", AC2, ACN2, display.COLOR_WHITE)
				end

				if MAC2 > 0 and enabled7 then
					add("攻击速度: -" .. MAC2, display.COLOR_RED)
				end
			elseif stdMode == 28 or stdMode == 27 then
				if enabled7 then
					callback12(CS_AC .. ": ", "AC", nil, enabled11)
					callback12(CS_MAC .. ": ", "MAC", nil, enabled12)
				end

				if getData("aniCount") > 0 then
					add("负重: +" .. getData("aniCount"), display.COLOR_WHITE)
				end
			elseif stdMode == 63 then
				if AC2 > 0 then
					add("HP: +" .. AC2, display.COLOR_GREEN)
				end

				if maxAC2 > 0 then
					add("MP: +" .. maxAC2, display.COLOR_GREEN)
				end

				if maxMAC2 > 0 and enabled7 then
					callback13("幸运值 +", maxMAC2, maxMACN2, display.COLOR_WHITE)
				end

				if MAC2 > 0 and enabled7 then
					add("诅咒: +" .. MAC2, display.COLOR_RED)
				end
			elseif enabled7 then
				callback12(CS_AC .. ": ", "AC", nil, enabled11)
				callback12(CS_MAC .. ": ", "MAC", nil, enabled12)
			end

			if enabled7 then
				callback12(CS_FULLDC .. ": ", "DC", nil, enabled8)
				callback12(CS_FULLMC .. ": ", "MC", nil, enabled9)
				callback12(CS_FULLSC .. ": ", "SC", nil, enabled10)

				if getData("intparam2") > 0 then
					callback12(CS_HP .. ": ", "intparam2", true, enabled10)
				end
			end

			local source3 = getData("source")

			if enabled7 then
				if checkIn(source3, -50, -1) then
					add("神圣: +" .. -source3, display.COLOR_WHITE)
				elseif checkIn(source3, -100, -51) then
					add("神圣: -" .. -source3 - 50, display.COLOR_RED)
				end
			end

			if stdMode ~= 52 and stdMode ~= 64 then
				addNeed()
				addNeed2()
			end
		elseif stdMode == 25 then
			local shape5 = getData("shape") or 0

			if shape5 == 9 then
				add("容量: " .. duraStr(1))
			elseif shape5 == 10 or shape5 == 11 then
				add("持久: " .. duraStr(100))
			elseif shape5 == 8 then
				if getData("name") == "祝福罐" or getData("name") == "魔令包" then
					add("容量: " .. duraStr(100))
				else
					add("容量: " .. duraStr(10))
				end
			else
				add("数量: " .. duraStr(100))
			end
		elseif stdMode == 40 then
			add("品质: " .. math.modf(Word(data:get("dura")) / 1000))
		elseif (stdMode ~= 42 or false) and stdMode == 43 and not params.onlyStdItem then
			add("纯度: " .. math.modf(Word(data:get("dura")) / 1000))
		elseif stdMode == 48 then
			-- block empty
		elseif stdMode == 49 then
			-- block empty
		end
	end

	if #items == 1 then
		add(" ")
	end

	local enabled14 = false

	if bzelementsAoth and (def.elements or def.newElements) and info.showElements then
		if not _getysNew2 then
			os.exit()
		end

		local value11 = _getysNew2(data)

		if items5.元素1 and items5.元素1 > 0 then
			value11[113] = items5.元素1
		end

		if value.elemts then
			for index, elemt in ipairs(value.elemts) do
				if elemt > 0 then
					value11[112 + index] = value.elemts[index] or 0
				end
			end
		end

		if not solt0190 then
			os.exit()
		end

		if def.debug then
			value11[113] = 200
			value11[114] = 45
			value11[115] = 23
			value11[116] = 23
			value11[117] = 43
			value11[118] = 54
		end

		if def.openIdentifyItem then
			if value11[114] then
				enabled14 = value11[114] > 0
			end

			if not enabled14 and value11[142] then
				enabled14 = value11[142] > 0
			end
		end

		local value12 = callback9(data)
		local data4 = getData("needConf")

		if data4 == 10676 then
			local value13 = value11[127] or value11[158]
			local value14 = value11[128] or value11[159]
			local value15 = value11[129] or value11[160]

			if value13 and value14 and value15 then
				local value16 = g_data.login.serverTime or socket.gettime()
				local number3 = os.date("%m", value16)
				local number4 = os.date("%d", value16)
				local number5 = os.date("%H", value16)

				add("[限时装备]", def.colors.get(251))
				add("剩余：" .. value13 - tonumber(number3) .. "个月" .. value14 - tonumber(number4) .. "天" .. value15 - tonumber(number5) .. "小时")
			end
		elseif def.newElements and def.newElements.elements then
			local items6 = {}

			if def.newElements.group then
				for _, group in ipairs(def.newElements.group) do
					local color = group.title:split("@")
					local value17 = color[1]
					local value18

					if group.line then
						value18 = callback32(nil, true, true)
					end

					local value19 = callback8(value17, color[2] and _stringToCorlor(color[2], def.colors.get(251)), nil, nil, nil, nil, nil, nil, nil, true)

					for _2, elmtID in ipairs(group.elmtID) do
						info.showElements(value11[112 + elmtID] or value11[140 + elmtID], def.newElements.elements[elmtID], data2, stdMode, items, params.from, value12, group.title, value19)

						items6[#items6 + 1] = elmtID
					end

					if value18 and not items[value19].isHide then
						items[value18].isHide = false
					end
				end
			end

			for index2, element in ipairs(def.newElements.elements) do
				if not checkExist(index2, unpack(items6)) then
					info.showElements(value11[112 + index2] or value11[140 + index2], element, data2, stdMode, items, params.from, value12)
				end
			end
		else
			if def.elements.elements1 then
				info.showElements(value11[113] or value11[141], def.elements.elements1, data2, stdMode, items, params.from, value12)
			end

			if def.elements.elements2 then
				info.showElements(value11[114] or value11[142], def.elements.elements2, data2, stdMode, items, params.from, value12)
			end

			if def.elements.elements3 then
				info.showElements(value11[115] or value11[143], def.elements.elements3, data2, stdMode, items, params.from, value12)
			end

			if def.elements.elements4 then
				info.showElements(value11[116] or value11[144], def.elements.elements4, data2, stdMode, items, params.from, value12)
			end

			if def.elements.elements5 then
				info.showElements(value11[117] or value11[145], def.elements.elements5, data2, stdMode, items, params.from, value12)
			end

			if def.elements.elements6 then
				info.showElements(value11[118] or value11[146], def.elements.elements6, data2, stdMode, items, params.from, value12)
			end
		end

		local function callback82(self)
			local value62 = callback(self) or 0
			local value72 = callback("max" .. self) or 0

			if value62 > 0 or value72 > 0 then
				local value82 = callback2("max" .. self)

				if value82 and value82 < value72 then
					return value72 - value82
				end
			end

			return nil
		end

		local value20 = (function()
			local value62
			local data3 = getData("maxAC")
			local dataStd = getDataStd("maxAC")

			if data3 and dataStd then
				if checkExist(stdMode, 5, 6) then
					local data22 = getData("accurate") or data3

					if dataStd < data22 then
						value62 = data22 - dataStd
					end
				elseif checkExist(stdMode, 20, 24) and dataStd < data3 then
					value62 = data3 - dataStd
				end
			end

			return value62
		end)()
		local value21 = callback82("DC")
		local value22 = callback82("SC")
		local value23 = callback82("MC")
		local value24 = callback82("AC")
		local value25 = callback82("MAC")

		if data4 == 10676 and value20 and value21 and value23 then
			local value26 = g_data.login.serverTime or socket.gettime()
			local value27 = os.date("%m", value26)
			local value28 = os.date("%d", value26)
			local value29 = os.date("%H", value26)

			add("[限时装备]", def.colors.get(251))
			add("剩余：" .. value20 - value27 .. "个月" .. value21 - value28 .. "天" .. value23 - value29 .. "小时")
		else
			if def.elements.jpelements1 and value20 then
				info.showElements(value20, def.elements.jpelements1, data2, stdMode, items, params.from, value12)
			end

			if def.elements.jpelements2 and value21 then
				info.showElements(value21, def.elements.jpelements2, data2, stdMode, items, params.from, value12)
			end

			if def.elements.jpelements3 and value22 then
				info.showElements(value22, def.elements.jpelements3, data2, stdMode, items, params.from, value12)
			end

			if def.elements.jpelements4 and value23 then
				info.showElements(value23, def.elements.jpelements4, data2, stdMode, items, params.from, value12)
			end

			if def.elements.jpelements5 and value24 then
				info.showElements(value24, def.elements.jpelements5, data2, stdMode, items, params.from, value12)
			end

			if def.elements.jpelements6 and value25 then
				info.showElements(value25, def.elements.jpelements6, data2, stdMode, items, params.from, value12)
			end
		end
	end

	local config = def.role.getConfig("buff")

	local function callback92(self, text22)
		local parts = string.split(text22, "$")

		if #parts > 1 then
			local parts2 = string.split(parts[4], "@")
			local value62

			if parts2[2] then
				value62 = _stringToCorlor(parts2[2])
			end

			if not enabled then
				if value8 < #items then
					callback32()
				end

				enabled = true
			end

			add(self, def.colors.get(251))
			add(parts2[1], value62, nil, parts[2], parts[1], tonumber(parts[3]), tonumber(parts[5]) or 0, tonumber(parts[6]) or 0, tonumber(parts[7]) or 0)
		end
	end

	if config and config.weapon_buff then
		local value30 = config.weapon_buff[getData("name")]

		if value30 then
			local value31 = config.weapon_buff.buffName or "[铭文镶嵌]"
			local text3 = callback52(value30.abil)

			if text3 > 0 then
				local text4 = value30.buffs["buff_" .. tostring(text3)]

				if text4 then
					callback92(value31, text4.itemStr)
				end
			else
				local itemStrOwner = config.weapon_buff.empty

				if itemStrOwner then
					callback92(value31, itemStrOwner.itemStr)
				end
			end
		end
	end

	info.addSpicalAttr3(data, config, enabled6, callback32)

	local descOwner = def.role.itemdesc[getData("name")]

	if descOwner then
		local items7 = descOwner.desc

		if items7 then
			if def.enableItemInfoGroupTips then
				add(CS_ADDIITEMDESC, def.colors.get(251))
			end

			if #items7 > 0 then
				if value8 < #items then
					callback32()
				end

				value8 = #items
			end

			for _3, item in ipairs(items7) do
				if string.find(item.itemdesc, "/") ~= nil then
					local parts = string.split(item.itemdesc, "/")

					for _4, item2 in ipairs(parts) do
						add(item2, _stringToCorlor(item.color), nil)
					end
				else
					add(item.itemdesc, _stringToCorlor(item.color), nil)
				end
			end
		end
	end

	if enabled14 then
		add("*该装备被封印了部分属性", display.COLOR_GREEN)
	end

	local function callback102(self)
		if type(self) ~= "table" then
			return nil
		end

		local items42 = {}

		for itemId, item in pairs(self) do
			local value62 = type(item)

			if value62 == "table" then
				items42[itemId] = callback102(item)
			elseif value62 == "thread" then
				items42[itemId] = item
			elseif value62 == "userdata" then
				items42[itemId] = item
			else
				items42[itemId] = item
			end
		end

		return items42
	end

	local value32

	if def.useNewSuits then
		value32 = callback102(def.newSuits)
	else
		value32 = callback102(def.role.getConfig("suitEquips"))
	end

	local function callback112(self)
		return self.getVar("name")
	end

	local function callback122(self, value72, value82, value9)
		if not self then
			return
		end

		self.activeAll = true

		local value62 = g_data.equip.items

		if params.from == "heroEquip" then
			value62 = g_data.heroEquip.items
		end

		local count = 0

		if def.enableItemInfoGroupTips then
			add(value82, def.suitNameColor or cc.c3b(0, 206, 209))
		end

		for _, item in ipairs(self) do
			local count2 = 0
			local value10 = item.name

			for index = 0, 16 do
				if value62[index] then
					local value11 = value62[index]
					local value12 = callback112(value11)
					local value13 = text2(value10)
					local value14 = text2(value12)

					if value11 and value13:find(value14) ~= nil then
						if value13:find("|") ~= nil then
							local items42 = value13:split("|")

							for index2 = 1, #items42 do
								if value14 == items42[index2] then
									value10 = value12

									break
								end
							end
						end

						local value15 = text2(value10)

						if item.num and item.num == 2 then
							if value14 == value15 then
								count2 = count2 + 1
							end
						elseif value14 == value15 then
							item.isActive = true
							count = count + 1

							break
						end
					end
				end
			end

			if item.num and item.num == 2 then
				if count2 >= 2 then
					count = count + 1
					item.isActive = true
				else
					value10 = value10 .. "*2"
				end
			end

			local value16 = value10:gsub("|", ",")

			if not def.showItemNameWithPlus then
				value16 = value16:split("+")[1]
			end

			if item.isActive then
				add("[" .. value16 .. "]", def.suitActiveColor or display.COLOR_GREEN)
			else
				add("[" .. value16 .. "]", def.suitDeActiveColor or cc.c3b(119, 136, 153))

				self.activeAll = false
			end
		end

		local value17 = def.suitAttrDeActiveColor or cc.c3b(119, 136, 153)
		local value18 = def.suitAttrActiveColor or cc.c3b(255, 140, 0)

		if def.enableItemInfoGroupTips then
			add(value9 .. "：", def.suitAttrNameColor or cc.c3b(255, 140, 0))
		end

		if value72 then
			for _2, item2 in ipairs(value72) do
				if item2.needNums then
					if count >= item2.needNums then
						add(item2.abil, value18)
					else
						add(item2.abil, value17)
					end
				elseif self.activeAll then
					add(item2.abil, value18)
				else
					add(item2.abil, value17)
				end
			end
		end
	end

	local enabled15 = false

	if value32 and callback11(stdMode) then
		for _5, item3 in ipairs(value32) do
			if item3.suitE then
				local enabled16 = false
				local value33 = item3

				for _6, suitE in ipairs(value33.suitE) do
					local value34 = text2(suitE.name)
					local value35 = text2(callback112(data))

					if value34:find("|") ~= nil then
						local value36 = value34:split("|")

						for _7, item4 in ipairs(value36) do
							if item4 == value35 then
								enabled16 = true

								break
							end
						end

						if enabled16 then
							break
						end
					elseif value34 == value35 then
						enabled16 = true

						break
					end
				end

				if enabled16 then
					if not enabled15 then
						enabled15 = true

						if value8 < #items then
							callback32()
						end

						value8 = #items
					end

					callback122(value33.suitE, value33.suitAbil, value33.suitName or CS_SUITEITEMDESC, value33.suitAtvName or "激活属性")
				end
			end
		end
	end

	if not params.fromSmelting then
		local desc = def.items.desc[getData("name")]

		if desc then
			if def.debug then
				desc = desc .. def.mwinfo or "\\buff$6$1$@255$0$0$0\\buff$6$1$@255$44$0$-40\\buff$6$1$@255$88$0$-40\\LINE\\测试<多彩/SCOLOR=251>颜色\\测试内容1\\测试内容2@251"
			end

			local strs = string.split(desc, "\\")

			if strs then
				if #strs > 0 then
					if value8 < #items then
						callback32()
					end

					value8 = #items
				end

				for i, v in ipairs(strs) do
					v = string.gsub(v, "{br}", "\n")

					if string.find(v, "#") then
						info.addSpicalAttr(v)
					elseif v == "LINE" then
						callback32(nil, true)
					elseif v:find("<") ~= nil and v:find(">") ~= nil then
						local label = an.newLabelM(number2 - 5, width.itemInfoSize or 16, 1, {
							manual = false
						})

						string.parseContent(label, v)

						label.__cname = "labelM"
						items[#items + 1] = label
					else
						local value37
						local parts2 = string.split(v, "$")

						if #parts2 > 1 then
							local parts3 = string.split(parts2[4], "@")

							if parts3[2] then
								value37 = _stringToCorlor(parts3[2])
							end

							callback8(parts3[1], value37, nil, parts2[2], parts2[1], tonumber(parts2[3]), tonumber(parts2[5]) or 0, tonumber(parts2[6]) or 0, tonumber(parts2[7]) or 0)
						else
							local parts4 = string.split(v, "@")

							if parts4[2] then
								value37 = _stringToCorlor(parts4[2])
							end

							add(parts4[1], value37)
						end
					end
				end
			end
		end
	end

	if params.extend then
		for i2, v2 in ipairs(params.extend) do
			add(v2, display.COLOR_RED)
		end
	end

	local function release(name)
		local value62
		local value72
		local count = 0
		local msgBox = an.newMsgbox("", function(idx)
			if idx == 1 and count > 0 then
				local useCnt = math.min(count, 6)

				local function use()
					if g_data.bag:use("eat", data.FItemIdent) then
						net.send({
							CM_EAT,
							recog = data.get(data, "makeIndex")
						})

						useCnt = useCnt - 1

						if useCnt > 0 then
							scheduler.performWithDelayGlobal(use, 0.5)
						end
					end
				end

				use()
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("当前有" .. data:get("dura") / 100 .. "个" .. name, 18, 1):addTo(msgBox.bg):pos(60, 190):anchor(0, 0.5)

		local label = an.newLabel("取出0个" .. name .. "(一次最多取6个)", 18, 1):addTo(msgBox.bg):pos(60, 160):anchor(0, 0.5)
		local slider = an.newSlider(res.gettex2("pic/common/sliderBg3.png"), nil, res.gettex2("pic/common/sliderBlock3.png"), {
			scale9 = cc.size(280, 31),
			valueChange = function(value63)
				count = math.min(data:get("dura") / 100, 6) * value63

				label:setString("取出" .. math.ceil(count) .. "个" .. name .. "(一次最多取6个)")
			end
		}):add2(msgBox.bg):pos(msgBox.bg:getw() / 2, 110):anchor(0.5, 0.5)
	end

	if params.itemLink then
		btns[#btns + 1] = {
			name = "添加链接",
			click = params.itemLink
		}
	end

	local function splitItem()
		local input
		local msgbox = an.newMsgbox("", function(idx)
			if idx == 1 then
				local count = tonumber(input:getString())

				if not count or count < 1 or count >= data:get("dura") then
					main_scene.ui:fadeLabel("请输入1-" .. data:get("dura") .. "之间数字")
				else
					net.send({
						CM_SPLITITEM,
						tag = 0,
						recog = data:get("makeIndex"),
						param = count,
						series = params.from == "heroBag" and 1 or 0
					})
					playerorhero:setIsSplliting(true)
				end
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("当前堆叠数量为" .. data:get("dura") .. ", 请输入拆分数量", 18, 1):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 180):anchor(0.5, 0.5)

		input = an.newInput(0, 0, 300, 36, 4, {
			bg = {
				h = 36,
				tex = res.gettex2("pic/scale/edit.png")
			}
		}):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 140):anchor(0.5, 0.5)
	end

	if not params.hidePileUp and params.from and (params.from == "bag" or params.from == "heroBag") and data.isPileUp(data) and data:get("dura") > 1 then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/split.png",
			click = splitItem
		}
	end

	if not params.hidePileUp and params.from and params.from == "storage" and data.isPileUp(data) and data:get("dura") > 1 then
		btns[#btns + 1] = {
			sprite = "pic/panels/bag/split.png",
			click = splitItem
		}
	end

	if params.bgCount then
		bg:setName(items2[params.bgCount])
	else
		bg:setName(items2[1])
	end

	local w = 0
	local h = 7
	local value38 = def.itemLineSpace or 4

	;(function(value62, value72)
		local function callback17(self)
			if not self then
				return ""
			end

			local items42 = self:split("-")

			if #items42 == 2 then
				local items52 = items42[1]:split("/")

				if #items52 == 3 then
					local number3 = tonumber(os.date("%Y", os.time()))

					if math.abs(number3 - tonumber(items52[1])) <= 5 then
						local value63 = utf8strs(items52[1])

						return value63[1] .. value63[2] .. value63[3] .. value63[4] .. "-" .. items52[2] .. "-" .. items52[3] .. " " .. items42[2]
					end
				end
			end

			return ""
		end

		local function callback22(self)
			if not self then
				return
			end

			add(CS_SOURCE_PLAYER .. self, display.COLOR_WHITE)
		end

		local player = value62.角色

		if def.openMultiJob then
			player = player and player:gsub("^N(%d?)", ""):gsub("^N", "")
		end

		if not value.laiyuan then
			value.laiyuan = {
				player = player,
				date = callback17(value62.时间),
				map = value62.地图,
				monster = value62.怪物
			}
		end

		if value.laiyuan.player then
			if value8 < #items then
				callback32()
			end

			add(CS_SOURCE_TITLE, display.COLOR_GREEN)

			if not value.laiyuan.map then
				add(CS_SOURCE_SYS, display.COLOR_WHITE)
				callback22(value.laiyuan.player)
				add(CS_SOURCE_BUILD_TIME .. value.laiyuan.date, display.COLOR_WHITE)
			else
				if value.laiyuan.map then
					add(CS_SOURCE_MAP .. value.laiyuan.map, display.COLOR_WHITE)
				end

				if value.laiyuan.monster then
					add(CS_SOURCE_MON .. value.laiyuan.monster, display.COLOR_WHITE)
				end

				callback22(value.laiyuan.player)
				add(CS_SOURCE_DROP_TIME .. value.laiyuan.date, display.COLOR_WHITE)
			end
		end
	end)(items4)

	if width.showItemLogo then
		if width.itemLogoEffect then
			local value39 = _getani2("pic/bzmir/effect/tipsEffect/logo/%d.png", 1, 20, 0.08)

			if value39 then
				value39:retain()

				local value40 = _get2("pic/bzmir/effect/tipsEffect/logo/1.png"):anchor(0, 0):pos(bg:getw() / 2, h):addTo(node, 99)

				if value40 then
					value40:runForever(cc.Animate:create(value39))

					w = math.max(w, value40:getw())
					h = h + value40:geth() + value38 + 15
				end
			end
		else
			local value41 = _get2("pic/bzmir/effect/tipsEffect/logo.png"):anchor(0, 0):pos(bg:getw() / 2, h):addTo(node, 99)

			if value41 then
				w = math.max(w, value41:getw())
				h = h + value41:geth() + value38 + 15
			end
		end
	end

	for i3, v3 in ipairs(btns) do
		local params2 = {
			pressImage = res.gettex2("pic/common/btn91.png")
		}

		if v3.name then
			params2.label = {
				v3.name or "",
				20,
				1,
				{
					color = def.colors.btn30
				}
			}
		elseif v3.sprite then
			params2.sprite = res.gettex2(v3.sprite)
		end

		local btn = an.newBtn(res.gettex2("pic/common/btn90.png"), function()
			v3.click()
		end, params2):anchor(0.5, 0):pos(w * 0.5, h):add2(bg, 999):scale(0.9)

		btns[i3] = btn
		w = math.max(w, btn.getw(btn))
		h = h + btn.geth(btn) + value38
	end

	local itemsWithBg = res.getItemsWithBg("items", getData("name"), getData("looks"), true, true)
	local w2 = itemsWithBg:getw()
	local h2 = itemsWithBg:geth()

	local function callback132(self, value72)
		local value62 = ccui.RichText:create()

		value62.setContentSize(value62, value72, self.geth(self))
		value62.ignoreContentAdaptWithSize(value62, false)

		local text22 = ccui.RichElementText:create(99, self.color, 255, string.sub(self.text, 1, -2), self.font, self.fontSize)

		value62.pushBackElement(value62, text22)
		value62.formatText(value62)

		return value62
	end

	local value42 = #items
	local count3 = 0

	for index3 = value42, 1, -1 do
		local items8 = items[index3]

		if not items8.isHide then
			w = math.max(w, items8:getw())

			local x = 10
			local count4 = 0

			if not items8.noText then
				count4 = items8:geth() + 2
			end

			if items8.__cname == "label" then
				if enabled4 and (index3 == 1 or index3 == 2) then
					if index3 == 1 then
						count3 = h + count4 - 6
					end

					if index3 == 1 or index3 == 2 then
						x = 10 + w2 + 6
					end

					if index3 == 2 then
						h = h + math.max(0, h2 - (count4 * 2 + value38 * 2)) + 3
					end
				end

				if items8.imgWidth then
					x = 10 + items8.imgWidth + 8
				end

				if items8.img ~= nil then
					local count5 = 0
					local value43

					if #items8.img == 1 then
						value43 = _get2("pic/bzmir/effect/" .. items8.imgdir .. "/" .. items8.img[1] .. ".png"):scale(items8.imgScale or 1)

						value43:anchor(0, 0):pos(10 + (items8.offsetX or 0), h - 4 + (items8.offsetY or 0)):addto(node, 99)

						count5 = value43:geth() * (items8.imgScale or 1)
					else
						local number6 = _getani2("pic/bzmir/effect/" .. items8.imgdir .. "/%d.png", tonumber(items8.img[1]), tonumber(items8.img[2]), tonumber(items8.img[3]) or 0.1)

						if number6 then
							number6:retain()

							value43 = _get2("pic/bzmir/effect/" .. items8.imgdir .. "/" .. items8.img[1] .. ".png"):scale(items8.imgScale or 1)

							if value43 then
								count5 = value43:geth() * (items8.imgScale or 1)

								value43:anchor(0, 0):pos(10 + (items8.offsetX or 0), h - 4 + (items8.offsetY or 0)):addto(node, 99)
								value43:runForever(cc.Animate:create(number6))
							end
						end
					end

					local value44 = math.max(count5, count4)

					if items8.subLabels then
						value44 = math.max(value44, (#items8.subLabels + 1) * count4)
					end

					count4 = value44

					if items8.offsetH then
						count4 = count4 + items8.offsetH
					end

					local value45 = h + count4 + value38

					if not items8.noText then
						local y = value45

						items8:addto(node, 99):pos(x, y):anchor(0, 1)

						if items8.subLabels then
							for _8, subLabel in pairs(items8.subLabels) do
								y = y - subLabel:geth() - value38

								subLabel:addto(node, 99):pos(x, y):anchor(0, 1)
							end
						end

						value43:setPositionY(value45 - count5)
					end
				else
					items8:addto(node, 99):pos(x, h):anchor(0, 0)
				end
			elseif items8.__cname == "node" then
				items8:addto(node, 99):pos(x + (items8.offsetX or 0), h + (items8.offsetY or 0)):anchor(0, 0)

				if items8.offsetH then
					count4 = count4 + items8.offsetH
				end
			elseif items8.__cname == "progress" then
				items8:addto(node, 99):pos(x + (items8.offsetX or 0), h + (items8.offsetY or 0)):anchor(0, 0)

				if items8.offsetH then
					count4 = count4 + items8.offsetH
				end
			elseif items8.__cname == "button" then
				items8:addto(node, 99):pos(x + (items8.offsetX or 0), h + (items8.offsetY or 0)):anchor(0, 0)

				if items8.offsetH then
					count4 = count4 + items8.offsetH
				end
			elseif items8.__cname == "labelM" then
				if items8.img ~= nil then
					if items8.imgWidth then
						x = 10 + items8.imgWidth + 8
					end

					local count6 = 0
					local value46

					if #items8.img == 1 then
						value46 = _get2("pic/bzmir/effect/" .. items8.imgdir .. "/" .. items8.img[1] .. ".png"):scale(items8.imgScale or 1)

						value46:anchor(0, 0):pos(10 + (items8.offsetX or 0), h - 4 + (items8.offsetY or 0)):addto(node, 99)

						count6 = value46:geth() * (items8.imgScale or 1)
					else
						local number7 = _getani2("pic/bzmir/effect/" .. items8.imgdir .. "/%d.png", tonumber(items8.img[1]), tonumber(items8.img[2]), tonumber(items8.img[3]) or 0.1)

						if number7 then
							number7:retain()

							value46 = _get2("pic/bzmir/effect/" .. items8.imgdir .. "/" .. items8.img[1] .. ".png"):scale(items8.imgScale or 1)

							if value46 then
								count6 = value46:geth() * (items8.imgScale or 1)

								value46:anchor(0, 0):pos(10 + (items8.offsetX or 0), h - 4 + (items8.offsetY or 0)):addto(node, 99)
								value46:runForever(cc.Animate:create(number7))
							end
						end
					end

					count4 = math.max(count6, items8:geth() or 0)

					if items8.offsetH then
						count4 = count4 + items8.offsetH
					end

					local y2 = h + count4 + value38

					items8:addto(node, 99):pos(x, y2):anchor(0, 1)

					if value46 then
						value46:setPositionY(y2 - count6)
					end
				else
					items8:addto(node, 99):pos(x + (items8.offsetX or 0), h + (items8.offsetY or 0)):anchor(0, 0)

					if items8.offsetH then
						count4 = count4 + items8.offsetH
					end
				end
			elseif items8.__cname == "line" then
				items8:addto(node, 99):pos(x, h + (items8.offsetH or 0)):anchor(0, 0):size(width.itemEffectWidth, items8:geth())

				if items8.offsetH then
					count4 = count4 + items8.offsetH
				end
			end

			if items8.addH then
				count4 = count4 + items8.addH
			end

			h = h + count4 + value38
		end
	end

	if not checkMd5 then
		cc.Director:getInstance():endToLua()
		core_func_byby()
	else
		checkMd5()
	end

	if enabled4 and itemsWithBg then
		itemsWithBg:anchor(0.5, 1):pos(10 + itemsWithBg:getw() / 2, count3):addto(node, 99)
		itemsWithBg:setTouchEnabled(false)
	end

	local data5 = getData("name")
	local enabled17 = false
	local enabled18 = false
	local value47 = def.maxStar or 8

	if data5:find("+") ~= nil then
		local parts5 = string.split(data5, "+")
		local number8 = tonumber(parts5[2]) or 0

		if not def.hideStar then
			data5 = parts5[1]
			value2 = number8
		elseif not def.showItemNameWithPlus then
			data5 = parts5[1]
		end
	end

	if def.testStar then
		value2 = 37
	end

	if not def.hideStar and value2 and value2 > 0 then
		h = h + def.starHeightSpace or 35
		enabled17 = true

		local value48 = def.starStepSpace or 30

		local function callback142(self, value72)
			local value62 = _getani2(self .. "%d.png", 1, 10, 0.1)

			if value62 then
				value62:retain()

				local value82 = _get2(self .. "1.png"):anchor(0, 1):pos(10 + value72 * value48, h):add2(node, 99)

				if value82 then
					value82:runForever(cc.Animate:create(value62))
				end
			end
		end

		local function callback152(self, value62)
			value62 = value62 or 5

			local items42 = {}
			local value72 = self
			local level = 0

			while value72 > 0 do
				local count = value72 % value62

				value72 = math.floor(value72 / value62)

				local value82
				local text22 = level == 0 and "pic/bzmir/effect/itemstar/" or string.format("pic/bzmir/effect/itemstar/%d/", level)

				table.insert(items42, {
					level = level,
					count = count,
					image = text22
				})

				level = level + 1
			end

			if #items42 == 0 then
				return {
					{
						count = 0,
						level = 0
					}
				}
			end

			return items42
		end

		if def.autoUpgradeStar then
			local labels = callback152(value2, value47)
			local count7 = 0

			for i4 = #labels, 1, -1 do
				local value49 = labels[i4]

				if value49.count > 0 then
					for index4 = 1, value49.count do
						callback142(value49.image, count7)

						count7 = count7 + 1
					end
				end
			end
		else
			value2 = math.min(value2, value47)

			for index5 = 1, value2 do
				callback142("pic/bzmir/effect/itemstar/", index5 - 1)
			end
		end
	end

	local label2 = an.newLabelM(number, width.itemInfoTitleSize or 18, 1):anchor(0, 0):addto(node, 99):pos(10, h + 5):anchor(0, 0)
	local value50 = cc.c3b(255, 255, 0)

	if itemColorCfg and itemColorCfg[getData("name")] ~= nil then
		local value51 = def.role.string2Color(itemColorCfg[getData("name")].color or 223)

		if value51 then
			value50 = value51
		end
	elseif def.role.itemstyle.itemColor then
		value50 = def.role.string2Color(def.role.itemstyle.itemColor)
	end

	local value52 = data5

	if checkExist(stdMode, 5, 6) then
		value52 = data5 .. callback3()

		if isUpgrade() then
			value52 = "(*)" .. data5 .. callback3()
		end
	else
		value52 = value52 .. callback3()
	end

	local value53
	local value54, color2 = info.extendName(value52, config, data)

	if color2 then
		value50 = _stringToCorlor(color2)
	end

	label2.addLabel(label2, value54, value50)

	if enabled14 then
		label2.addLabel(label2, "(封)", value50)
	end

	h = h + 20 + value38

	local w3 = math.max(w, label2.widthCnt) + 15

	if enabled17 then
		local value55 = 20 + value47 * 30

		if w3 < value55 then
			w3 = value55
		end
	end

	if w3 < number2 then
		w3 = number2
	end

	h = h + 10

	;(function()
		node:size(w3, h)

		if h > height and width.openItemInfoScroll then
			local scroll = an.newScroll(0, 5, w3, height - 5):addto(bg, 55)

			node:addTo(scroll):anchor(0, 0):pos(0, 0)
			scroll:setScrollSize(w3, h)
			scroll:setListenner(function(nameOwner)
				if nameOwner.name == "moved" and not enabled3 then
					enabled3 = true
				end
			end)

			h = height

			bg:size(w3 + 2, height + 10)
		else
			node:addTo(bg, 55):anchor(0, 0):pos(0, 5)
			bg:size(w3 + 2, h + 15)
		end
	end)()

	if params.from == "equip" and stdMode ~= 7 and stdMode ~= 25 then
		res.get2("pic/common/tips_equip.png"):pos(bg:getw() - 22, bg:geth() - 22):add2(bg, 102):scale(0.8)
	end

	if def.debug then
		width.openItemEffect = true
	end

	if width.openItemEffect and h > 100 and width.itemEffectNeedItems and (width.itemEffectNeedItems == "" or string.find(text2(width.itemEffectNeedItems), text2(data5)) ~= nil) then
		local value56 = _getani2("pic/bzmir/effect/tipsEffect/%d.png", 1, 20, 0.08)

		if value56 then
			value56:retain()

			local value57 = _get2("pic/bzmir/effect/tipsEffect/1.png"):add2(bg):scalex(w3 / width.itemEffectWidth):scaley(h / width.itemEffectHeight):anchor(0, 0)

			if value57 then
				value57:runForever(cc.Animate:create(value56))
			end
		end
	end

	for i5, v4 in ipairs(btns) do
		v4.setPositionX(v4, w3 * 0.5)
	end

	local rect = cc.rect(params.minx or 0, params.miny or 0, params.maxx or display.width, params.maxy or display.height)

	if params.extra then
		if enabled2 then
			scenePos.x = scenePos.x - w3
		else
			scenePos.x = scenePos.x + params.xOffset
		end
	end

	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w3 then
		if not params.extra then
			p.x = p.x - w3
		else
			p.x = scenePos.x - w3 - params.xOffset - 5
		end
	end

	if p.y - h < rect.y then
		p.y = p.y + (h - p.y + 10)
	end

	if rect.height < p.y then
		p.y = rect.height - 10
	end

	bg.pos(bg, p.x, p.y)

	return layer, bg
end

return info
