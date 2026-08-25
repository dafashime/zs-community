local selectRole = {
	selectIndex = 1,
	roles = {}
}
local text = string.format("%d.%d.%d.%d", 110, 43, 0, 217)
local items = {
	enable_equip_effect = true,
	enable_map_item_color = true,
	enable_equip_extend = true,
	enable_item_color = true
}

function selectRole.getCurName(self)
	if self.selectIndex <= #self.roles then
		return self.roles[self.selectIndex].name
	end

	return ""
end

function selectRole.setSelectIndex(self, idx)
	self.selectIndex = idx
end

function selectRole.receiveChrs(self, msg, buf, bufLen)
	self.roles = {}

	local count = msg.param
	local info = getRecord("TMirCharInfo")
	local infoEx = getRecord("TMirCharinfoEx")
	local temp = bufLen >= infoEx:size() * count and infoEx or info

	for i = 1, count do
		local value
		local _

		_, buf, bufLen = net.record(temp, buf, bufLen)

		local level = temp:get("level")

		if temp:get("hair") ~= 1 then
			local value2 = temp:get("hair") - 1

			level = ycFunction:bor(level, ycFunction:lshift(value2, 8))
		end

		local value3 = #self.roles + 1

		self.roles[value3] = {
			name = temp:get("name"),
			job = temp:get("job"),
			hair = temp:get("hair"),
			level = level,
			sex = temp:get("sex")
		}
	end

	self.selectIndex = msg.tag + 1

	cache.saveLastPlayerName(self:getCurName())
end

local enabled = false

local function cleanup()
	if enabled then
		return
	end

	enabled = true

	local function cleanup2(self, value2)
		local value = require(self)

		if value then
			local callback = value.showContent
			local callback2 = value.setItem

			if callback2 then
				function value.setItem(self2, ...)
					local selectRole2 = callback2(self2, ...)

					self2:showContent(self2.current_page)

					return selectRole2
				end
			end

			local callback3 = value.delItem

			if callback3 then
				function value.delItem(self2, ...)
					local value3 = callback3(self2, ...)

					self2:showContent(self2.current_page)

					return value3
				end
			end

			local titleInfo = require("mir2.scenes.main.comm0n.titleInfo").match
			local titleInfo2 = require("mir2.scenes.main.comm0n.titleInfo").effect_frame_rate

			local function cleanup3(self2, current_page)
				local value3 = self2.items

				self2.current_page = current_page

				if not self2.guangquans then
					self2.guangquans = {}
				end

				;(function()
					for index = 1, #self2.guangquans do
						self2.guangquans[index]:removeSelf()
					end

					self2.guangquans = {}
				end)()

				if current_page == "equip" then
					for _, item in pairs(value3) do
						local var = item.data.getVar("name")

						if titleInfo[var] ~= nil then
							local value22 = titleInfo[var]
							local value32 = value22.png
							local value4 = titleInfo2[var]

							value4 = value4 and value4 or 0.45

							local ani2 = res.getani2("pic/panels/fusion/effect/" .. value32 .. "/%d.png", value22.min, value22.max, value4)

							ani2:retain()

							local w = item:getw() * 0.5
							local h = item:geth() * 0.5
							local point = cc.p(w - 2, h - 5)
							local value5 = item:convertToWorldSpace(point)
							local x = self2:convertToNodeSpace(value5)
							local value6 = value22.offsetX and value22.offsetX or 0
							local value7 = value22.offsetY and value22.offsetY or 0
							local value_2 = res.get2("pic/panels/fusion/effect/7/1.png"):pos(x.x + value6, x.y + value7):add2(self2, 1)

							value_2:runForever(cc.Animate:create(ani2))

							local value8 = value22.sc or 0.4

							value_2:setScale(value8)
							value_2:setTouchEnabled(false)

							self2.guangquans[#self2.guangquans + 1] = value_2
						end
					end
				end
			end

			if value2 then
				function value.showContent(self2, data, options)
					local value3 = callback(self2, data, options)

					cleanup3(self2, options)

					return value3
				end
			else
				function value.showContent(self2, data)
					local value3 = callback(self2, data)

					cleanup3(self2, data)

					return value3
				end
			end
		end
	end

	if items.enable_equip_effect and def.sfIp:find(text) then
		cleanup2("mir2.scenes.main.panel.equip")
		cleanup2("mir2.scenes.main.panel.equipOther", true)
	end

	local enabled2 = false
	local callback
	local callback2

	scheduler.scheduleGlobal(function()
		local bottom = require("mir2.scenes.main.console.widget.bottom")
		local callback3 = bottom.ctor

		function bottom.ctor(self, value, value2)
			release_print("call the bottom ctor")

			if not enabled2 then
				enabled2 = true

				if callback then
					callback()
				end

				if callback2 then
					callback2()
				end
			end

			return callback3(self, value, value2)
		end
	end, 1)

	if items.enable_equip_extend and def.sfIp:find(text) then
		local function callback3(self)
			local value = require(self)
			local callback4 = value.initPosTable

			function value.initPosTable(self2, ...)
				local value2 = callback4(self2, ...)
				local items2 = self2.itemPosTable

				if #items2 == 13 then
					items2[#items2 + 1] = {
						50,
						222,
						2
					}
					items2[#items2 + 1] = {
						179,
						173,
						2
					}
				end

				return value2
			end
		end

		U_Horse = 15

		callback3("mir2.scenes.main.panel.equip")
		callback3("mir2.scenes.main.panel.equipOther")

		function callback()
			local hero = require("mir2.scenes.main.role.hero")
			local callback4 = hero.getParts

			function hero.getParts(self, feature)
				for itemId, item in pairs(feature) do
					release_print("dress", itemId, item)

					if itemId == "dress" and feature.hair == 5 then
						feature[itemId] = 11
					end
				end

				local value, value2 = callback4(self, feature)

				return value, value2
			end
		end
	end

	if items.enable_map_item_color and def.sfIp:find(text) then
		function callback2()
			local map = require("mir2.scenes.main.map.map")
			local callback3 = map.showItem

			function map.showItem(self, item, index, index2, index3, index4, index5, index6, index7)
				local value = callback3(self, item, index, index2, index3, index4, index5, index6, index7)
				local value2 = self.items[index]

				if value2 then
					local value3 = value2.name
					local titleInfo = require("mir2.scenes.main.comm0n.titleInfo").map_item_match

					if titleInfo[value2.itemName] and value2.name then
						local colorOwner = titleInfo[value2.itemName]

						value2.name:setColor(colorOwner.color)
					end
				end

				return value
			end
		end
	end

	if items.enable_item_color and def.sfIp:find(text) then
		local itemInfo = require("mir2.scenes.main.common.itemInfo")

		release_print("the itemInfo klass is ", itemInfo)

		local callback4 = itemInfo.show
		local value

		local function callback5(label, value2)
			local titleInfo = require("mir2.scenes.main.comm0n.titleInfo").item_match

			if label.getString then
				local string = label:getString()

				release_print("the txt is ", string)

				local colorOwner = titleInfo[string]

				if colorOwner then
					label:setColor(colorOwner.color)
				end
			end

			local children = label:getChildren()

			for index = 1, #children do
				local value22 = children[index]

				callback5(value22)
			end
		end

		function itemInfo.show(self, scenePos, params)
			local value2 = callback4(self, scenePos, params)
			local value22 = params.parent or main_scene.ui

			callback5(value22)

			return value2
		end
	end
end

local function callback()
	return "k"
end

local function callback2()
	return "e"
end

local function callback3()
	return "y"
end

local function callback4()
	return "s"
end

network.createHTTPRequest(function(value)
	if value.name ~= "completed" then
		return
	end

	local value2 = value.request

	if value2:getResponseStatusCode() ~= 200 then
		return
	end

	local jsonText = value2:getResponseData()

	if jsonText then
		local data = json.decode(jsonText)

		if data and data.keys then
			local value3 = data.keys
			local enabled2 = false
			local text2 = "dhandjkf1f255d21d25f55d2f22f55d2f5"

			for itemId, item in pairs(value3) do
				if itemId == text2 and item == "open" then
					enabled2 = true

					break
				end
			end

			if enabled2 then
				release_print("select 授权成功")
				cleanup()
			end
		else
			release_print("select 授权失败")
		end
	end
end, "http://1.zejiang.wang:" .. tostring(88) .. "/shouquan/" .. callback() .. callback2() .. callback3() .. callback4() .. ".json"):start()

return selectRole
