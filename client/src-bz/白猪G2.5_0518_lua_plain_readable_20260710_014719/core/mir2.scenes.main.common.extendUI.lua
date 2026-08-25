local extendUI = {}
local item = import("..common.item")
local textInfo = import("..common.textInfo")
local itemInfo = import("..common.itemInfo")

function _posWithCenter(self)
	return display.cx + self
end

local function callback()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

function extendUI.init(content2, mainName, merchant, align2, pointWith, options)
	local items = {
		content = content2
	}

	items.mainBgh = 0
	items.merchant = merchant or def.role.helperID
	items.mainName = mainName or "extend_ui"
	items.align = align2
	items.pointWith = pointWith
	items.lowPixelsRate = 0.6
	items.x_offset = 0

	if options then
		if options == "HIGH" then
			items.highPixels = true
		elseif options == "HLEFT" then
			items.highPixels = true
			items.align = "topleft"
		elseif options == "IOS" and callback() then
			items.x_offset = getSafeAreaInsets()
		end
	end

	extendUI.registerEvent(content2, items)

	return items
end

function extendUI.create(content2, text2, mainName, merchant, align2, pointWith, value)
	if content2 and text2 then
		local items = {
			content = content2
		}

		items.mainBgh = 0
		items.merchant = merchant or def.role.helperID
		items.mainName = mainName or "extend_ui"
		items.align = align2 or "center"
		items.pointWith = pointWith or 0
		items.lowPixelsRate = 0.6
		items.x_offset = 0

		if value then
			if value == "HIGH" then
				items.highPixels = true
			elseif value == "HLEFT" then
				items.highPixels = true
				items.align = "topleft"
			elseif value == "IOS" and callback() then
				items.x_offset = getSafeAreaInsets()
			end
		end

		local parts = string.split(text2, "|")

		for _, item2 in ipairs(parts) do
			extendUI.load(item2, items)
		end

		extendUI.registerEvent(content2, items)

		return items
	end

	return nil
end

function extendUI:registerEvent(event)
	if self.isEventProxyRegd then
		return
	end

	local function cleanup(self2)
		local value6 = self2:split("@")
		local value7 = self

		if value6[2] then
			local value28, value29 = extendUI.checkType(value6[2])
			local value30 = extendUI.genname(value28, value29, nil, nil, event.mainName)
			local child = extendUI.getChild(value30, self)

			if child then
				value7 = child
			end
		end

		local value31, value32 = extendUI.checkType(value6[1])
		local value33 = extendUI.genname(value31, value32 or "nil", nil, nil, event.mainName)

		return extendUI.getChild(value33, value7), value7
	end

	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_TEXT, function(response10)
		local label3 = cleanup(response10.data.elmtName)

		if label3 then
			label3:setString(response10.data.text)
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_TEXTM, function(response11)
		local value8 = cleanup(response11.data.elmtName)

		if value8 then
			value8:clear()

			local parts2 = string.split(response11.data.textLines, "$")

			for _, item3 in ipairs(parts2) do
				local parts = string.split(item3, "@")

				value8:nextLine():addLabel(parts[1], _stringToCorlor(parts[2]))
			end
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_TEXTCOLOR, function(response12)
		local value16 = cleanup(response12.data.elmtName)

		if value16 then
			value16:setColor(response12.data.color)
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_IMG, function(response4)
		local value17 = cleanup(response4.data.elmtName)

		if value17 then
			local value9 = response4.data.filePath
			local value18 = extendUI.genpicpath(response4.data.fileName)
			local text3 = "pic/bzmir/diynpc/" .. value9 .. "/" .. value18 .. ".png"

			if string.byte(value9) == 35 then
				text3 = value9 .. "/" .. value18 .. ".png"
			end

			value17:setTex(_gettex2(text3))
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_DIMG, function(response5)
		local value19 = cleanup(response5.data.elmtName)

		if value19 then
			local value34 = response5.data.dataFile
			local value35 = response5.data.fileName

			value19:setTex(res.gettex2(value35 .. ".png", "data/" .. value34))
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_STOP_SPR, function(response14)
		local value20 = cleanup(response14.data.elmtName)

		if value20 then
			value20:removeSelf()

			local value57
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_RBTN, function(response)
		local value2 = cleanup(response.data.elmtName)

		if value2 then
			local value10 = extendUI.genpicpath(response.data.filePath)
			local value36 = response.data.btnFile
			local value21 = response.data.pressFile
			local value11 = response.data.textOrSprite
			local value37 = response.data.isSprite
			local text4 = "pic/bzmir/diynpc/" .. value10 .. "/" .. value36 .. ".png"

			value2:setTex(_gettex2(text4))

			value2.imageTex = _gettex2(text4)

			if value21 then
				local text5 = "pic/bzmir/diynpc/" .. value10 .. "/" .. value21 .. ".png"

				value2.params.pressImage = _gettex2(text5)
			end

			if value11 then
				if value37 then
					value2.sprite:setTex(_gettex2("pic/bzmir/diynpc/" .. value10 .. "/" .. value11 .. ".png"))
				elseif value2.label then
					value2.label:setString(value11)
				end
			end
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_DRBTN, function(response2)
		local value3 = cleanup(response2.data.elmtName)

		if value3 then
			local value5 = response2.data.dataFile
			local value22 = response2.data.btnFile
			local value12 = response2.data.textOrSprite
			local value23 = response2.data.pressFile
			local value38 = response2.data.isSprite

			value3:setTex(res.gettex2(value22 .. ".png", "data/" .. value5))

			value3.imageTex = res.gettex2(value22 .. ".png", "data/" .. value5)

			if value23 then
				value3.params.pressImage = res.gettex2(value23 .. ".png", "data/" .. value5)
			end

			if value12 then
				if value38 then
					value3.sprite:setTex(res.gettex2(value12 .. ".png", "data/" .. value5))
				elseif value3.label then
					value3.label:setString(value12)
				end
			end
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_RCMD, function(response6)
		local label2 = cleanup(response6.data.elmtName)

		if label2 then
			local value39 = response6.data.text
			local value40 = response6.data.fontColor

			label2:setString(value39)
			label2:setColor(value40)
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_ITEM, function(response3)
		local node, value41 = cleanup(response3.data.elmtName)

		if node then
			local value58 = response3.data.elmtName
			local value24 = response3.data.itemName
			local value42 = response3.data.scale
			local value43 = response3.data.showBg
			local value44 = response3.data.showEffect
			local posx2 = node.params.posx
			local posy2 = node.params.posy
			local align2 = node.params.align
			local aligny2 = node.params.aligny
			local itemByName2 = def.items.getItemByName(value24, 3, 3)
			local itemsWithBg = res.getItemsWithBg("items", value24, itemByName2.looks, value43, value44):anchor(align2, aligny2):pos(posx2, posy2):addto(value41):scale(value42)

			itemsWithBg.params = {
				posx = posx2,
				posy = posy2,
				align = align2,
				aligny = aligny2
			}

			itemsWithBg:setName(node:getName())
			itemsWithBg:setTouchEnabled(true)
			itemsWithBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					itemsWithBg.offsetBeginY = offsetBeginY.y
					itemsWithBg.offsetBeginX = offsetBeginY.x

					return true
				elseif offsetBeginY.name == "ended" then
					local value45 = offsetBeginY.y - itemsWithBg.offsetBeginY
					local value46 = offsetBeginY.x - itemsWithBg.offsetBeginX

					if math.abs(value45) <= 10 and math.abs(value46) <= 10 and itemByName2 then
						local items2 = {
							x = offsetBeginY.x,
							y = offsetBeginY.y
						}

						itemInfo.create(itemByName2, items2, {
							from = "extUI"
						})
					end
				end
			end)
			node:setVisible(false)
			node:removeSelf()

			local value59
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_ITEMM, function(response7)
		local value, value60 = cleanup(response7.data.elmtName)

		if value then
			local value61 = response7.data.elmtName
			local value47 = response7.data.itemName
			local value4 = value.params.lineNum
			local value13 = value.params.pic
			local value25 = value.params.bgpic
			local value48 = value.params.scale
			local value49 = value.params.align
			local value50 = value.params.aligny
			local value51 = value.params.showEffect
			local value52 = value.params.checkbag
			local items = value47:split("$")
			local number = 3
			local text2 = "pic/bzmir/diynpc/" .. value13 .. "/" .. value25 .. ".png"

			if string.byte(value13) == 35 then
				text2 = value13 .. "/" .. value25 .. ".png"
			end

			local value26 = _get2(text2)
			local h = value26:geth() + number
			local w = value26:getw() + number
			local count = 1
			local width = w * value4
			local height = h * math.modf(#items / value4)

			value:size(width, height)
			value:clear()

			value.items = {}

			local x3 = 0
			local y2 = height

			for _2, item2 in ipairs(items) do
				local enabled = true

				if value52 then
					local itemWithName, itemWithName2 = g_data.bag.getItemWithName(item2)

					if not itemWithName then
						enabled = false
					end
				end

				local itemByName = def.items.getItemByName(item2, 3, 3)

				if itemByName and enabled then
					local x2 = _get2(text2):anchor(value49, value50):pos(x3, y2):add2(value)
					local itemsWithBg2 = res.getItemsWithBg("items", item2, itemByName.looks, false, value51):anchor(0.5, 0.5):pos(x2:getw() / 2, x2:geth() / 2):addto(x2):scale(value48)

					itemsWithBg2:setTouchEnabled(true)
					itemsWithBg2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(offsetBeginY2)
						if offsetBeginY2.name == "began" then
							itemsWithBg2.offsetBeginY = offsetBeginY2.y
							itemsWithBg2.offsetBeginX = offsetBeginY2.x

							return true
						elseif offsetBeginY2.name == "ended" then
							local value54 = offsetBeginY2.y - itemsWithBg2.offsetBeginY
							local value55 = offsetBeginY2.x - itemsWithBg2.offsetBeginX

							if math.abs(value54) <= 10 and math.abs(value55) <= 10 and itemByName then
								local items3 = {
									x = offsetBeginY2.x,
									y = offsetBeginY2.y
								}

								itemInfo.create(itemByName, items3, {
									from = "extUI"
								})
							end
						end
					end)

					local value27 = count % value4
					local value53 = math.modf(count / value4)

					if value27 == value4 then
						x3 = 0
					else
						x3 = 0 + value27 * w
						y2 = height - value53 * h
					end

					value.items[count] = x2
					count = count + 1
				end
			end
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_INPUT, function(response13)
		local label4 = cleanup(response13.data.elmtName)

		if label4 then
			label4:setText(response13.data.inputText)
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_SET_CHECK, function(response8)
		local value14 = cleanup(response8.data.elmtName)

		if value14 then
			value14:setIsSelect(response8.data.check)
			value14:setGray(response8.data.setGray)
		end
	end)
	cc.EventProxy.new(_Events, self):addEventListener(_Events.AC_DEL_ITEM, function(response9)
		local value56, value15 = cleanup(response9.data.elmtName)

		if value56 and value15.itemBoxs[response9.data.boxid] then
			value15:delItem(value15.itemBoxs[response9.data.boxid])
		end
	end)

	self.isEventProxyRegd = true
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function extendUI.createToggle(self4, value, label2, temp)
	local value4
	local value5

	temp = temp or {}

	local btn = display.newNode()
	local filteredSprite = display.newFilteredSprite(_gettex2(temp.unCheckImg)):anchor(0, 0):add2(btn)

	filteredSprite.setName(filteredSprite, "selsp")
	btn.setContentSize(btn, filteredSprite.getContentSize(filteredSprite))

	function btn:setIsSelect(isSelected)
		btn.isSelected = isSelected

		if isSelected then
			btn:select()
		else
			btn:unselect()
		end
	end

	function btn.isSelect(self5)
		return btn.isSelected
	end

	function btn.select(self2)
		btn.isSelected = true

		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		filteredSprite:setTex(_gettex2(temp.checkedImg))
	end

	function btn.select_temp(self6)
		if btn.temp then
			return
		end

		btn.temp = display.newFilteredSprite(_gettex2(temp.unCheckImg)):anchor(0, 0):add2(btn)

		btn.temp:setOpacity(80)
	end

	function btn.unselect(self3)
		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		btn.isSelected = false

		filteredSprite:setTex(_gettex2(temp.unCheckImg))
	end

	if value ~= nil then
		btn.setIsSelect(btn, value)
	end

	filteredSprite.setTouchEnabled(filteredSprite, true)
	filteredSprite.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			btn.offsetBeginY = offsetBeginY.y
			btn.offsetBeginX = offsetBeginY.x

			return true
		elseif offsetBeginY.name == "ended" then
			local value2 = offsetBeginY.y - btn.offsetBeginY
			local value3 = offsetBeginY.x - btn.offsetBeginX

			if math.abs(value2) <= 20 and math.abs(value3) <= 20 then
				btn:setIsSelect(not btn.isSelected)
				self4(btn.isSelected)
			end
		end
	end)
	filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

	if label2 then
		btn.label = an.newLabel(unpack(label2)):add2(btn):pos(btn.getw(btn) + 7, btn.geth(btn) / 2):anchor(0, 0.5)

		btn.label:setTouchEnabled(true)
		btn.label:setTouchSwallowEnabled(false)
		btn.label:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x2)
			if x2.name == "began" then
				sound.playSound("105")

				btn.label.disable = false

				btn.label:scale(1.1):setColor(cc.c3b(255, 0, 0))

				btn.label.startPos = cc.p(x2.x, x2.y)

				return true
			elseif x2.name == "ended" then
				btn.label:scale(1):setColor(label2[4].color)
				btn:setIsSelect(not btn.isSelected)
				self4(btn.isSelected)
			elseif cc.pGetDistance(btn.label.startPos, x2) > 35 then
				btn.label:scale(1):setColor(label2[4].color)

				btn.label.disable = true
			end
		end)

		function btn.getw(self7)
			return btn.label:getw() + 40
		end
	end

	btn.btn = btn

	function btn.gray(self8)
		local filter = res.getFilter("gray")

		filteredSprite:setFilter(filter)
		filteredSprite:setTouchEnabled(false)
		btn:setTouchEnabled(false)

		if btn.label then
			btn.label:setTouchEnabled(false)
		end

		if btn.temp then
			btn.temp:setFilter(filter)
		end
	end

	function btn.disGray(self9)
		local filter2 = res.getFilter("gray")

		filteredSprite:clearFilter()
		filteredSprite:setTouchEnabled(true)
		btn:setTouchEnabled(true)

		if btn.label then
			btn.label:setTouchEnabled(true)
		end

		if btn.temp then
			btn.temp:clearFilter(filter2)
		end
	end

	function btn.setGray(self10, gray)
		if gray then
			btn:gray()
		else
			btn:disGray()
		end

		return btn
	end

	return btn
end

function extendUI.load(self2, path)
	if path.content and self2 then
		if def.debug then
			print(self2)
		end

		local count

		if def.customBtnTopzOrder then
			count = 1
		end

		local parts = string.split(self2, ":")
		local parts8 = string.split(parts[1], bzmir.mcmd)
		local value11 = parts8[1]

		if value11 == "1" then
			local value2, value3 = extendUI.checkType(parts[2])
			local align2 = 0.5
			local aligny2 = 0.5

			if path.align == "left" then
				align2 = 0
			elseif path.align == "topleft" then
				align2 = 0
				aligny2 = 1
			elseif path.align == "right" then
				align2 = 1
			end

			local value = path.content

			if parts8[2] then
				local value74, value75 = extendUI.checkType(parts8[2])
				local value76 = extendUI.genname(value74, value75, nil, nil, path.mainName)
				local child2 = extendUI.getChild(value76, path.content)

				if child2 then
					value = child2
				end
			end

			local mainBgh = value:geth()

			path.mainBgh = mainBgh

			if value2 == "Text" then
				local number28 = tonumber(parts[3]) or 5
				local number11 = tonumber(parts[4]) or mainBgh / 2

				if path.pointWith == 0 then
					number11 = mainBgh - number11
				end

				if path.highPixels then
					number28 = _posWithCenter(number28)
				end

				local x10 = number28 + path.x_offset
				local value37 = extendUI.genname(value2, value3, x10, number11, path.mainName)

				extendUI.rebuildelm(value37, value)

				local number59 = tonumber(parts[5]) or 20
				local text6 = parts[6] or "未指定文本"
				local color5 = cc.c3b(245, 210, 100)

				if string.find(text6, bzmir.mcmd) ~= nil then
					local parts15 = string.split(text6, bzmir.mcmd)

					color5 = _stringToCorlor(parts15[2])
					text6 = parts15[1]
				end

				local value16 = parts[7]

				if value16 then
					if value16 == "left" then
						align2 = 0
					elseif value16 == "right" then
						align2 = 1
					end
				end

				local label4 = an.newLabel(text6, number59, 1, {
					color = color5
				}):anchor(align2, aligny2):addTo(value):pos(x10, number11)

				label4:setName(value37)

				local number4 = tonumber(parts[8])

				if number4 and path.highPixels then
					number4 = _posWithCenter(number4)
				end

				local number46 = tonumber(parts[9]) or mainBgh / 2
				local value38 = parts[10]

				if number4 and number46 and value38 and label4 and tolua.cast(label4, "cc.Node") then
					label4:stopAllActions()
					label4:moveTo(value38, number4, number46)
				end
			elseif value2 == "LabelM" then
				local number29 = tonumber(parts[3]) or 5
				local number12 = tonumber(parts[4]) or mainBgh / 2
				local number60 = tonumber(parts[5]) or 100

				if path.pointWith == 0 then
					number12 = mainBgh - number12
				end

				if path.highPixels then
					number29 = _posWithCenter(number29)
				end

				local x11 = number29 + path.x_offset
				local value39 = extendUI.genname(value2, value3, x11, number12, path.mainName)

				extendUI.rebuildelm(value39, value)

				local number61 = tonumber(parts[6]) or 20
				local value77 = parts[7] or "未指定文本"
				local value9 = parts[8]

				if value9 then
					if value9 == "left" then
						align2 = 0
					elseif value9 == "topleft" then
						align2 = 0
						aligny2 = 1
					elseif value9 == "right" then
						align2 = 1
					end
				end

				if not c_createColorLabel then
					os.exit()
				end

				c_createColorLabel(value77, display.COLOR_WHITE, number60, number61, {
					manual = false,
					center = value9 == "center"
				}):anchor(align2, aligny2):addTo(value):pos(x11, number12):setName(value39)
			elseif value2 == "Img" then
				local value17 = parts[3]:split(bzmir.mcmd)[1]
				local enabled = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled = true
				end

				local value40 = extendUI.genpicpath(parts[4])
				local value41 = bzmir.diynpc .. value17 .. bzmir.prefix .. value40 .. bzmir.ext

				if string.byte(value17) == 35 then
					value41 = value17 .. bzmir.prefix .. value40 .. bzmir.ext
				end

				local number30 = tonumber(parts[5]) or 5
				local number5 = tonumber(parts[6]) or 5

				if path.pointWith == 0 then
					number5 = mainBgh - number5
				end

				if path.highPixels then
					number30 = _posWithCenter(number30)
				end

				local x6 = number30 + path.x_offset
				local value18 = extendUI.genname(value2, value3, x6, number5, path.mainName)

				extendUI.rebuildelm(value18, value)

				local text2 = parts[7]
				local text7 = parts[8]
				local value42 = _gettex2(value41)

				if text2 and text2 ~= "" and text2 ~= "nil" then
					local parts9 = string.split(text7, bzmir.mcmd)
					local enabled5 = false
					local value19 = bzmir.mcmd

					if parts9[2] then
						value19 = value19 .. parts9[2]
						enabled5 = true
					end

					local items = {}
					local items13 = {}

					items13.pressBig = true

					if enabled then
						items13.support = "scroll"
					end

					local btn2 = an.newBtn(value42, function()
						return
					end, items13):anchor(align2, aligny2):pos(x6, number5):add2(value)

					btn2:setName(value18)
					btn2:setTouchEnabled(true)

					if enabled then
						btn2:setTouchSwallowEnabled(false)
					end

					btn2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos2)
						if startPos2.name == "began" then
							btn2.startPos = cc.p(startPos2.x, startPos2.y)

							return true
						elseif startPos2.name == "ended" and cc.pGetDistance(btn2.startPos, startPos2) <= 10 then
							local texts = {}
							local items5 = {}

							if string.find(text2, "\\") ~= nil then
								items5 = string.split(text2, "\\")
							else
								items5[#items5 + 1] = text2
							end

							for _2, item3 in ipairs(items5) do
								local items15 = {
									text = item3
								}

								if string.find(item3, bzmir.mcmd) ~= nil then
									local parts16 = string.split(item3, bzmir.mcmd)

									items15.color = _stringToCorlor(parts16[2])
									items15.text = parts16[1]
								end

								texts[#texts + 1] = items15
							end

							items.texts = texts

							if enabled5 then
								items.btns = {}

								local items20 = {
									name = parts9[1],
									click = function()
										sound.playSound("103")
										extendUI.callCMD2(value19, path.merchant)
									end
								}

								items.btns[#items.btns + 1] = items20
							end

							local items21 = {
								x = startPos2.x,
								y = startPos2.y
							}

							textInfo.create(items, items21, {
								from = "npc"
							})
						end
					end)
				else
					display.newSprite(value42):anchor(align2, aligny2):pos(x6, number5):add2(value):setName(value18)
				end
			elseif value2 == "DImg" then
				local value43 = parts[3]:split(bzmir.mcmd)[1]
				local enabled2 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled2 = true
				end

				local value44 = parts[4]
				local number47 = tonumber(parts[5])
				local number31 = tonumber(parts[6]) or 5
				local number6 = tonumber(parts[7]) or 5

				if path.pointWith == 0 then
					number6 = mainBgh - number6
				end

				if path.highPixels then
					number31 = _posWithCenter(number31)
				end

				local x7 = number31 + path.x_offset
				local value20 = extendUI.genname(value2, value3, x7, number6, path.mainName)

				extendUI.rebuildelm(value20, value)

				local text3 = parts[8]
				local text8 = parts[9]
				local texforCUS3 = res.gettexforCUS(value43, value44)

				if text3 and text3 ~= "" and text3 ~= "nil" then
					local parts10 = string.split(text8, bzmir.mcmd)
					local enabled6 = false
					local value21 = bzmir.mcmd

					if parts10[2] then
						value21 = value21 .. parts10[2]
						enabled6 = true
					end

					local items2 = {}
					local items14 = {}

					items14.pressBig = true

					if enabled2 then
						items14.support = "scroll"
					end

					local btn = an.newBtn(texforCUS3, function()
						sound.playSound("103")
					end, items14):anchor(align2, aligny2):pos(x7, number6):add2(value)

					btn:setName(value20)
					btn:setScale(number47)
					btn:setTouchEnabled(true)

					if enabled2 then
						btn:setTouchSwallowEnabled(false)
					end

					btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos3)
						if startPos3.name == "began" then
							btn.startPos = cc.p(startPos3.x, startPos3.y)

							return true
						elseif startPos3.name == "ended" and cc.pGetDistance(btn.startPos, startPos3) <= 10 then
							local texts2 = {}
							local items6 = {}

							if string.find(text3, "\\") ~= nil then
								items6 = string.split(text3, "\\")
							else
								items6[#items6 + 1] = text3
							end

							for _3, item4 in ipairs(items6) do
								local items16 = {
									text = item4
								}

								if string.find(item4, bzmir.mcmd) ~= nil then
									local parts17 = string.split(item4, bzmir.mcmd)

									items16.color = _stringToCorlor(parts17[2])
									items16.text = parts17[1]
								end

								texts2[#texts2 + 1] = items16
							end

							items2.texts = texts2

							if enabled6 then
								items2.btns = {}

								local items22 = {
									name = parts10[1],
									click = function()
										sound.playSound("103")
										extendUI.callCMD2(value21, path.merchant)
									end
								}

								items2.btns[#items2.btns + 1] = items22
							end

							local items23 = {
								x = startPos3.x,
								y = startPos3.y
							}

							textInfo.create(items2, items23, {
								from = "npc"
							})
						end
					end)
				else
					display.newSprite(res.gettexforCUS(value43, value44)):anchor(align2, aligny2):pos(x7, number6):add2(value):scale(number47):setName(value20)
				end
			elseif value2 == "Item" then
				local value12 = parts[3]:split(bzmir.mcmd)[1]
				local enabled7 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled7 = true
				end

				local number62 = tonumber(parts[4]) or 0
				local number63 = tonumber(parts[5]) or 1
				local number32 = tonumber(parts[6]) or 5
				local number7 = tonumber(parts[7]) or 5
				local value78 = parts[8] and parts[8] == "1" or false
				local value79 = parts[9] and parts[9] == "1" or false
				local value80 = parts[10]

				if path.pointWith == 0 then
					number7 = mainBgh - number7
				end

				if path.highPixels then
					number32 = _posWithCenter(number32)
				end

				local posx2 = number32 + path.x_offset
				local value45 = extendUI.genname(value2, value3, posx2, number7, path.mainName)

				extendUI.rebuildelm(value45, value)

				local item7
				local var
				local value108

				if value12 == "1" then
					local item8

					item8, item7 = g_data.bag:getItem(number62)

					if item7 then
						value12 = item7.getVar("name")
						var = item7.getVar("looks")
					end
				else
					item7 = def.items.getItemByName(value12, 3, 3)
					var = item7 and item7.looks
				end

				if item7 then
					local itemsWithBg = res.getItemsWithBg("items", value12, var, value78, value79, value80):anchor(align2, aligny2):pos(posx2, number7):addto(value):scale(number63)

					itemsWithBg.params = {
						posx = posx2,
						posy = number7,
						align = align2,
						aligny = aligny2
					}

					itemsWithBg:setName(value45)
					itemsWithBg:setTouchEnabled(true)

					if enabled7 then
						itemsWithBg:setTouchSwallowEnabled(false)
					end

					itemsWithBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos)
						if startPos.name == "began" then
							itemsWithBg.startPos = cc.p(startPos.x, startPos.y)

							return true
						elseif startPos.name == "ended" and cc.pGetDistance(itemsWithBg.startPos, startPos) <= 10 then
							local enabled3 = false

							if itemsWithBg.centerPos then
								local point = itemsWithBg:convertToWorldSpace(itemsWithBg.centerPos)

								if startPos.x >= point.x - itemsWithBg.centerPos.x and startPos.x <= point.x + itemsWithBg.centerPos.x and startPos.y >= point.y - itemsWithBg.centerPos.y and startPos.y <= point.y + itemsWithBg.centerPos.y then
									enabled3 = true
								end
							else
								enabled3 = true
							end

							if enabled3 and item7 then
								itemInfo.create(item7, cc.p(startPos.x, startPos.y), {
									from = "extUI"
								})
							end
						end
					end)
				end
			elseif value2 == "ItemM" then
				local value81 = parts[3]
				local number48 = tonumber(parts[4]) or 1
				local number33 = tonumber(parts[5]) or 5
				local number13 = tonumber(parts[6]) or 5
				local number3 = tonumber(parts[7]) or 5
				local pic2 = parts[8]
				local bgpic2 = parts[9]
				local showEffect2 = parts[10] and parts[10] == "1" or false
				local checkbag2 = parts[11] and parts[11] == "1" or false

				if path.pointWith == 0 then
					number13 = mainBgh - number13
				end

				if path.highPixels then
					number33 = _posWithCenter(number33)
				end

				local x12 = number33 + path.x_offset
				local value46 = extendUI.genname(value2, value3, x12, number13, path.mainName)

				extendUI.rebuildelm(value46, value)

				local node = display.newNode():addTo(value):anchor(align2, aligny2):pos(x12, number13)

				node.params = {
					lineNum = number3,
					pic = pic2,
					scale = number48,
					bgpic = bgpic2,
					showEffect = showEffect2,
					checkbag = checkbag2,
					align = align2,
					aligny = aligny2
				}
				node.items = {}

				function node:clear()
					for index, item9 in self.items do
						item9:removeSelf()

						item9 = nil
					end
				end

				local items9 = value81:split("$")
				local number91 = 3
				local value22 = bzmir.diynpc .. pic2 .. bzmir.prefix .. bgpic2 .. bzmir.ext

				if string.byte(pic2) == 35 then
					value22 = pic2 .. bzmir.prefix .. bgpic2 .. bzmir.ext
				end

				local value47 = _get2(value22)
				local h = value47:geth() + number91
				local w = value47:getw() + number91
				local count2 = 1
				local width = w * number3
				local height = h * math.modf(#items9 / number3)

				node:size(width, height)
				node:setName(value46)

				local x8 = 0
				local y2 = height

				for _, item2 in ipairs(items9) do
					local enabled8 = true

					if checkbag2 then
						local itemWithName, itemWithName2 = g_data.bag.getItemWithName(item2)

						if not itemWithName then
							enabled8 = false
						end
					end

					local itemByName = def.items.getItemByName(item2, 3, 3)

					if itemByName and enabled8 then
						local x5 = _get2(value22):anchor(align2, aligny2):pos(x8, y2):add2(node)
						local itemsWithBg2 = res.getItemsWithBg("items", item2, itemByName.looks, false, showEffect2):anchor(0.5, 0.5):pos(x5:getw() / 2, x5:geth() / 2):addto(x5):scale(number48)

						itemsWithBg2:setTouchEnabled(true)
						itemsWithBg2:setTouchSwallowEnabled(false)
						itemsWithBg2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x3)
							if x3.name == "began" then
								return true
							elseif x3.name == "ended" then
								local enabled4 = false

								if itemsWithBg2.centerPos then
									local point2 = itemsWithBg2:convertToWorldSpace(itemsWithBg2.centerPos)

									if x3.x >= point2.x - itemsWithBg2.centerPos.x and x3.x <= point2.x + itemsWithBg2.centerPos.x and x3.y >= point2.y - itemsWithBg2.centerPos.y and x3.y <= point2.y + itemsWithBg2.centerPos.y then
										enabled4 = true
									end
								else
									enabled4 = true
								end

								if enabled4 and itemByName then
									itemInfo.create(itemByName, cc.p(x3.x, x3.y), {
										from = "extUI"
									})
								end
							end
						end)

						local value48 = count2 % number3
						local value82 = math.modf(count2 / number3)

						if value48 == number3 then
							x8 = 0
						else
							x8 = 0 + value48 * w
							y2 = height - value82 * h
						end

						node.items[count2] = x5
						count2 = count2 + 1
					end
				end
			elseif value2 == "DSpr" then
				local value23 = extendUI.genpicpath(parts[3]:split(bzmir.mcmd)[1])
				local enabled9 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled9 = true
				end

				local number34 = tonumber(parts[4]) or 1
				local number49 = tonumber(parts[5]) or 2
				local number35 = tonumber(parts[6]) or 5
				local number8 = tonumber(parts[7]) or 5

				if path.pointWith == 0 then
					number8 = mainBgh - number8
				end

				if path.highPixels then
					number35 = _posWithCenter(number35)
				end

				local x9 = number35 + path.x_offset
				local text4 = parts[10]
				local text9 = parts[11]
				local value49 = extendUI.genname(value2, value3, x9, number8, path.mainName)

				extendUI.rebuildelm(value49, value)

				local number90 = 0.1
				local number9
				local enabled10 = true

				if parts[8] then
					local number88 = parts[8]:split(bzmir.mcmd)

					number90 = tonumber(number88[1])
					number9 = tonumber(number88[2])

					if number88[3] and number88[3] == "1" then
						enabled10 = false
					end
				end

				local number50 = tonumber(parts[9]) or 1

				number9 = number9 or tonumber(parts[12])

				local value4
				local value10

				if number9 then
					value10 = m2spr.new(value23, number34, {
						setOffset = true
					})
					value4 = value10.spr

					value4:pos(x9, number8):add2(value):anchor(align2, aligny2):scale(number50):runs({
						cc.DelayTime:create(number9),
						cc.CallFunc:create(function()
							if enabled10 then
								if value4 then
									value4:removeSelf()

									value4 = nil
									value10 = nil
								end
							else
								value10:stopAnimation()
							end
						end)
					})
					value10:playAni(value23, number34, number49, number90, false)
				else
					value4 = m2spr.playAnimation(value23, number34, number49, number90, false):pos(x9, number8):add2(value):anchor(align2, aligny2):scale(number50)
				end

				value4:setName(value49)
				value4:show()

				if text4 and text4 ~= "nil" then
					local items3 = {}
					local parts11 = string.split(text9, bzmir.mcmd)
					local enabled11 = false
					local value24 = bzmir.mcmd

					if parts11[2] then
						value24 = value24 .. parts11[2]
						enabled11 = true
					end

					value4:setTouchEnabled(true)

					if enabled9 then
						value4:setTouchSwallowEnabled(false)
					end

					value4:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos4)
						if startPos4.name == "began" then
							value4.startPos = cc.p(startPos4.x, startPos4.y)

							return true
						elseif startPos4.name == "ended" and cc.pGetDistance(value4.startPos, startPos4) <= 10 then
							local texts3 = {}
							local items7 = {}

							if string.find(text4, "\\") ~= nil then
								items7 = string.split(text4, "\\")
							else
								items7[#items7 + 1] = text4
							end

							for _4, item5 in ipairs(items7) do
								local items17 = {
									text = item5
								}

								if string.find(item5, bzmir.mcmd) ~= nil then
									local parts18 = string.split(item5, bzmir.mcmd)

									items17.color = _stringToCorlor(parts18[2])
									items17.text = parts18[1]
								end

								texts3[#texts3 + 1] = items17
							end

							items3.texts = texts3

							if enabled11 then
								items3.btns = {}

								local items24 = {
									name = parts11[1],
									click = function()
										sound.playSound("103")
										extendUI.callCMD2(value24, path.merchant)
									end
								}

								items3.btns[#items3.btns + 1] = items24
							end

							local items25 = {
								x = startPos4.x,
								y = startPos4.y
							}

							textInfo.create(items3, items25, {
								from = "npc"
							})
						end
					end)
				end
			elseif value2 == "Spr" then
				local value50 = extendUI.genpicpath(parts[3]:split(bzmir.mcmd)[1])
				local enabled12 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled12 = true
				end

				local number51 = tonumber(parts[4]) or 1
				local number64 = tonumber(parts[5]) or 2
				local number36 = tonumber(parts[6]) or 5
				local number14 = tonumber(parts[7]) or 5

				if path.pointWith == 0 then
					number14 = mainBgh - number14
				end

				if path.highPixels then
					number36 = _posWithCenter(number36)
				end

				local x13 = number36 + path.x_offset
				local text5 = parts[10]
				local text10 = parts[11]
				local number52 = tonumber(parts[12])
				local value51 = extendUI.genname(value2, value3, x13, number14, path.mainName)

				extendUI.rebuildelm(value51, value)

				local number65 = tonumber(parts[8]) or 0.1
				local number66 = tonumber(parts[9]) or 1
				local value25 = _getani2(bzmir.diynpc .. value50 .. bzmir.ext1, number51, number64, number65)

				value25.retain(value25)

				local value5 = _get2(bzmir.diynpc .. value50 .. bzmir.prefix .. number51 .. bzmir.ext):pos(x13, number14):add2(value):anchor(align2, aligny2)

				value5:setScale(number66)
				value5:runForever(cc.Animate:create(value25))

				if number52 then
					value5:runs({
						cc.DelayTime:create(number52),
						cc.CallFunc:create(function()
							if value5 then
								value5:removeSelf()

								value5 = nil
							end
						end)
					})
				end

				value5:setName(value51)

				if text5 and text5 ~= "nil" then
					local items4 = {}
					local parts12 = string.split(text10, bzmir.mcmd)
					local enabled13 = false
					local value26 = bzmir.mcmd

					if parts12[2] then
						value26 = value26 .. parts12[2]
						enabled13 = true
					end

					value5:setTouchEnabled(true)

					if enabled12 then
						value5:setTouchSwallowEnabled(false)
					end

					value5:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos5)
						if startPos5.name == "began" then
							value5.startPos = cc.p(startPos5.x, startPos5.y)

							return true
						elseif startPos5.name == "ended" and cc.pGetDistance(value5.startPos, startPos5) <= 10 then
							local texts4 = {}
							local items8 = {}

							if string.find(text5, "\\") ~= nil then
								items8 = string.split(text5, "\\")
							else
								items8[#items8 + 1] = text5
							end

							for _5, item6 in ipairs(items8) do
								local items18 = {
									text = item6
								}

								if string.find(item6, bzmir.mcmd) ~= nil then
									local parts19 = string.split(item6, bzmir.mcmd)

									items18.color = _stringToCorlor(parts19[2])
									items18.text = parts19[1]
								end

								texts4[#texts4 + 1] = items18
							end

							items4.texts = texts4

							if enabled13 then
								items4.btns = {}

								local items26 = {
									name = parts12[1],
									click = function()
										sound.playSound("103")
										extendUI.callCMD2(value26, path.merchant)
									end
								}

								items4.btns[#items4.btns + 1] = items26
							end

							local items27 = {
								x = startPos5.x,
								y = startPos5.y
							}

							textInfo.create(items4, items27, {
								from = "npc"
							})
						end
					end)
				end
			elseif value2 == "RBtn" then
				local value7 = extendUI.genpicpath(parts[3]:split(bzmir.mcmd)[1])
				local enabled14 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled14 = true
				end

				local text11 = parts[4]
				local number37 = tonumber(parts[5]) or 5
				local number15 = tonumber(parts[6]) or 5

				if path.pointWith == 0 then
					number15 = mainBgh - number15
				end

				if path.highPixels then
					number37 = _posWithCenter(number37)
				end

				local x14 = number37 + path.x_offset
				local value52 = extendUI.genname(value2, value3, x14, number15, path.mainName)

				extendUI.rebuildelm(value52, value)

				local text12 = parts[7]
				local number53 = tonumber(parts[8]) or 18
				local value53 = _stringToCorlor(parts[9])
				local number67 = tonumber(parts[10]) or 0
				local parts4 = string.split(text11, bzmir.mcmd)
				local value54 = bzmir.diynpc .. value7 .. bzmir.prefix .. parts4[1] .. bzmir.ext

				if string.byte(value7) == 35 then
					value54 = value7 .. bzmir.prefix .. parts4[1] .. bzmir.ext
				end

				local value83 = _gettex2(value54)
				local parts2 = string.split(text12, bzmir.mcmd)
				local text19 = ""

				if parts2[2] then
					text19 = bzmir.mcmd .. parts2[2]
				else
					text19 = "@no"
				end

				local items10 = {}

				if number53 == 0 then
					items10.sprite = _gettex2(bzmir.diynpc .. value7 .. bzmir.prefix .. parts2[1] .. bzmir.ext)
				elseif parts2[1] and parts2[1] ~= "" then
					local color6 = cc.c3b(245, 245, 245)

					if value53 then
						color6 = value53
					end

					items10.label = {
						parts2[1],
						number53,
						1,
						{
							color = color6
						}
					}
				end

				if parts4[2] then
					local value27 = bzmir.diynpc .. value7 .. bzmir.prefix .. parts4[2] .. bzmir.ext

					if string.byte(value7) == 35 then
						value27 = value7 .. bzmir.prefix .. parts4[2] .. bzmir.ext
					end

					if number67 == 0 then
						items10.pressImage = _gettex2(value27)
					else
						items10.select = {
							_gettex2(value27)
						}
					end
				else
					items10.pressBig = true
				end

				if enabled14 then
					items10.support = "scroll"
				end

				local btn3 = an.newBtn(value83, function()
					sound.playSound("103")
					extendUI.callCMD2(text19, path.merchant)
				end, items10):anchor(align2, aligny2):pos(x14, number15):addto(value, count)

				btn3:setTouchEnabled(true)
				btn3:setName(value52)
			elseif value2 == "DRBtn" then
				local value13 = parts[3]:split(bzmir.mcmd)[1]
				local enabled15 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled15 = true
				end

				local text13 = parts[4]
				local number68 = tonumber(parts[5])
				local number38 = tonumber(parts[6]) or 5
				local number16 = tonumber(parts[7]) or 5

				if path.pointWith == 0 then
					number16 = mainBgh - number16
				end

				if path.highPixels then
					number38 = _posWithCenter(number38)
				end

				local x15 = number38 + path.x_offset
				local value55 = extendUI.genname(value2, value3, x15, number16, path.mainName)

				extendUI.rebuildelm(value55, value)

				local text14 = parts[8]
				local number54 = tonumber(parts[9]) or 18
				local value56 = _stringToCorlor(parts[10])
				local number69 = tonumber(parts[11]) or 0
				local parts7 = string.split(text13, bzmir.mcmd)
				local texforCUS4 = res.gettexforCUS(value13, parts7[1])
				local parts3 = string.split(text14, bzmir.mcmd)
				local text20 = ""

				if parts3[2] then
					text20 = bzmir.mcmd .. parts3[2]
				else
					text20 = "@no"
				end

				local items11 = {}

				if number54 == 0 then
					items11.sprite = res.gettexforCUS(value13, parts3[1])
				elseif parts3[1] and parts3[1] ~= "" then
					local color7 = cc.c3b(245, 245, 245)

					if value56 then
						color7 = value56
					end

					items11.label = {
						parts3[1],
						number54,
						1,
						{
							color = color7
						}
					}
				end

				if parts7[2] then
					if number69 == 0 then
						items11.pressImage = res.gettexforCUS(value13, parts7[2])
					else
						items11.select = {
							res.gettexforCUS(value13, parts7[2])
						}
					end
				else
					items11.pressBig = true
				end

				if enabled15 then
					items11.support = "scroll"
				end

				local btn4 = an.newBtn(texforCUS4, function()
					sound.playSound("103")
					extendUI.callCMD2(text20, path.merchant)
				end, items11):anchor(align2, aligny2):pos(x15, number16):addto(value):scale(number68)

				btn4:setTouchEnabled(true)
				btn4:setName(value55)
			elseif value2 == "RCmd" then
				local number39 = tonumber(parts[3]) or 5
				local number17 = tonumber(parts[4]) or 5

				if path.pointWith == 0 then
					number17 = mainBgh - number17
				end

				if path.highPixels then
					number39 = _posWithCenter(number39)
				end

				local x16 = number39 + path.x_offset
				local value57 = extendUI.genname(value2, value3, x16, number17, path.mainName)

				extendUI.rebuildelm(value57, value)

				local number70 = tonumber(parts[5]) or 20
				local color2 = _stringToCorlor(parts[6])
				local text15 = parts[7]
				local parts13 = string.split(text15, bzmir.mcmd)
				local text21 = ""

				if parts13[2] then
					text21 = bzmir.mcmd .. parts13[2]
				else
					text21 = "@no"
				end

				local value28 = parts[8]

				if value28 then
					if value28 == "left" then
						align2 = 0
					elseif value28 == "right" then
						align2 = 1
					end
				end

				local label2 = an.newLabel(parts13[1] or "确定", number70, 1, {
					color = color2
				}):addTo(value, count):anchor(align2, aligny2):pos(x16, number17)

				label2:setName(value57)
				label2.setTouchEnabled(label2, true)
				label2:setTouchSwallowEnabled(false)
				label2.addNodeEventListener(label2, cc.NODE_TOUCH_EVENT, function(startPos6)
					if startPos6.name == "began" then
						label2.disable = false

						label2:scale(1.1):setColor(cc.c3b(255, 0, 0))

						label2.startPos = cc.p(startPos6.x, startPos6.y)

						return true
					elseif startPos6.name == "ended" then
						if cc.pGetDistance(label2.startPos, startPos6) <= 10 then
							sound.playSound("105")
							label2:scale(1):setColor(color2)

							if not label2.disable then
								extendUI.callCMD2(text21, path.merchant)
							end
						end
					elseif cc.pGetDistance(label2.startPos, startPos6) > 35 then
						label2:scale(1):setColor(color2)

						label2.disable = true
					end
				end)
			elseif value2 == "Btn" then
				local value8 = extendUI.genpicpath(parts[3]:split(bzmir.mcmd)[1])
				local enabled16 = false

				if parts[3]:split(bzmir.mcmd)[2] then
					enabled16 = true
				end

				local text16 = parts[4]
				local number40 = tonumber(parts[5]) or 5
				local number18 = tonumber(parts[6]) or 5

				if path.pointWith == 0 then
					number18 = mainBgh - number18
				end

				if path.highPixels then
					number40 = _posWithCenter(number40)
				end

				local x17 = number40 + path.x_offset
				local value58 = extendUI.genname(value2, value3, x17, number18, path.mainName)

				extendUI.rebuildelm(value58, value)

				local text17 = parts[7]
				local number71 = tonumber(parts[8]) or 18
				local value59 = _stringToCorlor(parts[9])
				local number72 = tonumber(parts[10]) or 0
				local parts5 = string.split(text16, bzmir.mcmd)
				local value60 = bzmir.diynpc .. value8 .. bzmir.prefix .. parts5[1] .. bzmir.ext

				if string.byte(value8) == 35 then
					value60 = value8 .. bzmir.prefix .. parts5[1] .. bzmir.ext
				end

				local value84 = _gettex2(value60)
				local parts6 = string.split(text17, bzmir.mcmd)
				local text22 = ""

				if parts6[2] then
					text22 = bzmir.mcmd .. parts6[2]
				else
					text22 = "@no"
				end

				local items12 = {}

				if parts6[1] and parts6[1] ~= "" then
					local color8 = cc.c3b(245, 245, 245)

					if value59 then
						color8 = value59
					end

					items12.label = {
						parts6[1],
						number71,
						1,
						{
							color = color8
						}
					}
				end

				items12.pressBig = true

				if parts5[2] then
					local value29 = bzmir.diynpc .. value8 .. bzmir.prefix .. parts5[2] .. bzmir.ext

					if string.byte(value8) == 35 then
						value29 = value8 .. bzmir.prefix .. parts5[2] .. bzmir.ext
					end

					if number72 == 1 then
						items12.pressImage = _gettex2(value29)
					else
						items12.select = {
							_gettex2(value29),
							manual = true
						}
					end
				end

				if enabled16 then
					items12.support = "scroll"
				end

				an.newBtn(value84, function()
					sound.playSound("103")
					extendUI.callCMD2(text22, path.merchant)
				end, items12):anchor(align2, aligny2):pos(x17, number18):addto(value, count):setName(value58)
			elseif value2 == "Cmd" then
				local number41 = tonumber(parts[3]) or 5
				local number19 = tonumber(parts[4]) or 5

				if path.pointWith == 0 then
					number19 = mainBgh - number19
				end

				if path.highPixels then
					number41 = _posWithCenter(number41)
				end

				local x18 = number41 + path.x_offset
				local value61 = extendUI.genname(value2, value3, x18, number19, path.mainName)

				extendUI.rebuildelm(value61, value)

				local number73 = tonumber(parts[5]) or 20
				local color3 = _stringToCorlor(parts[6])
				local text18 = parts[7]
				local parts14 = string.split(text18, bzmir.mcmd)
				local text23 = ""

				if parts14[2] then
					text23 = bzmir.mcmd .. parts14[2]
				else
					text23 = "@no"
				end

				local label3 = an.newLabel(parts14[1] or "确定", number73, 1, {
					color = color3
				}):addTo(value, count):anchor(align2, aligny2):pos(x18, number19)

				label3:setName(value61)
				label3.setTouchEnabled(label3, true)
				label3:setTouchSwallowEnabled(false)
				label3.addNodeEventListener(label3, cc.NODE_TOUCH_EVENT, function(startPos7)
					if startPos7.name == "began" then
						label3.disable = false

						label3:scale(1.1):setColor(cc.c3b(255, 0, 0))

						label3.startPos = cc.p(startPos7.x, startPos7.y)

						return true
					elseif startPos7.name == "ended" then
						if cc.pGetDistance(label3.startPos, startPos7) <= 10 then
							sound.playSound("105")
							label3:scale(1):setColor(color3)

							if not label3.disable then
								extendUI.callCMD2(text23, path.merchant)
							end
						end
					elseif cc.pGetDistance(label3.startPos, startPos7) > 35 then
						label3:scale(1):setColor(color3)

						label3.disable = true
					end
				end)
			elseif value2 == "PUTBOX" then
				local value85 = parts[3]:split(bzmir.mcmd)[1]
				local value86 = parts[4]
				local putItemCmd = parts[5]
				local value87 = parts[6]
				local number20 = tonumber(parts[7]) or 5
				local number21 = tonumber(parts[8]) or 5
				local sc = parts[9] or 1
				local supportItems

				if parts[10] then
					supportItems = parts[10]:split("$")
				end

				local value62 = extendUI.genname(value2, value3, number20, number21, path.mainName)

				extendUI.rebuildelm(value62, value)

				local value88 = bzmir.diynpc .. value85 .. bzmir.prefix .. value86 .. bzmir.ext
				local value89 = _gettex2(value88)

				if path.pointWith == 0 then
					number21 = mainBgh - number21
				end

				if path.highPixels then
					number20 = _posWithCenter(number20)
				end

				local sprite = display.newSprite(value89):anchor(align2, aligny2):pos(number20, number21):add2(value, 2)

				sprite:setTouchEnabled(true)

				if parts[3]:split(bzmir.mcmd)[2] then
					sprite:setTouchSwallowEnabled(false)
				end

				sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(point3)
					if point3.name == "began" then
						return true
					elseif point3.name == "ended" and value.showBag then
						value:showBag(point3.x + 50, point3.y + 50)
					end
				end)
				sprite:setScale(sc)
				sprite:setName(value62)

				sprite.putItemCmd = putItemCmd
				sprite.sc = sc
				sprite.supportItems = supportItems
				value.itemBoxs[value87] = sprite
			elseif value2 == "DELITEM" then
				if value.itemBoxs[parts[3]] then
					value:delItem(value.itemBoxs[parts[3]])
				end
			elseif value2 == "S" then
				local number42 = tonumber(parts[3]) or 5
				local number22 = tonumber(parts[4]) or 5
				local number74 = tonumber(parts[5]) or 100
				local number75 = tonumber(parts[6]) or 100
				local number76 = tonumber(parts[7]) or 0
				local number55 = tonumber(parts[8])
				local number77 = tonumber(parts[9]) or 1

				if path.pointWith == 0 then
					number22 = mainBgh - number22
				end

				if path.highPixels then
					number42 = _posWithCenter(number42)
				end

				local x19 = number42 + path.x_offset
				local node2 = an.newScroll(x19, number22, number74, number75, {
					dir = number77
				}):addTo(value):anchor(align2, aligny2):pos(x19, number22)
				local value90 = extendUI.genname(value2, value3, nil, nil, path.mainName)

				node2:setName(value90)

				if number55 then
					node2.scrollView:scrollTo(0, number55)
				end

				if number76 == 1 then
					node2:setVisible(false)
				end

				return
			elseif value2 == "SetS" then
				local value91, value92 = extendUI.checkType(parts[3])
				local value63 = extendUI.genname(value91, value92, nil, nil, path.mainName)

				if value63 then
					local label7 = extendUI.getChild(value63, value)

					if label7 and parts[4] then
						if label7.setString then
							label7:setString(parts[4])
						elseif label7.label and label7.label.setString then
							label7.label:setString(parts[4])
						end
					end
				end
			elseif value2 == "CheckBox" then
				local value64 = parts[3]
				local value93 = parts[4]
				local value94 = parts[5] == "1"
				local number43 = tonumber(parts[6]) or 5
				local number23 = tonumber(parts[7]) or 5
				local number78 = tonumber(parts[8]) or 16
				local value95 = parts[9]

				if parts[10] ~= nil and parts[10] == "" then
					-- block empty
				end

				local value65 = parts[10]

				if not tonumber(parts[11]) then
					local count3 = 1
				end

				if path.pointWith == 0 then
					number23 = mainBgh - number23
				end

				if path.highPixels then
					number43 = _posWithCenter(number43)
				end

				local x20 = number43 + path.x_offset
				local value66 = extendUI.genname(value2, value3, x20, number23, path.mainName)

				extendUI.rebuildelm(value66, value)

				local color4 = value95:split(bzmir.mcmd)
				local value30 = value93:split(bzmir.mcmd)
				local unCheckImg2 = bzmir.diynpc .. value64 .. bzmir.prefix .. value30[1] .. bzmir.ext
				local checkedImg2 = value30[2] and bzmir.diynpc .. value64 .. bzmir.prefix .. value30[2] .. bzmir.ext or unCheckImg2

				extendUI.createToggle(function(value106)
					if value65 then
						local value107 = value106 and "1" or "0"

						extendUI.callCMD2(bzmir.mcmd .. value65 .. bzmir.cmdcnt .. parts[2] .. bzmir.cmdcnt .. value107)
					end
				end, value94, {
					color4[1],
					number78,
					1,
					{
						color = color4[2] and _stringToCorlor(color4[2], cc.c3b(220, 210, 190))
					}
				}, {
					unCheckImg = unCheckImg2,
					checkedImg = checkedImg2
				}):addTo(value, count):anchor(align2, aligny2):pos(x20, number23):setName(value66)
			elseif value2 == "Input" then
				local number44 = tonumber(parts[3]) or 5
				local number24 = tonumber(parts[4]) or 5
				local number79 = tonumber(parts[5]) or 10
				local number80 = tonumber(parts[6]) or 10
				local number56 = tonumber(parts[7]) or 16
				local value31 = parts[8]
				local number81 = tonumber(parts[9]) or 1

				if parts[10] ~= nil and parts[10] == "" then
					-- block empty
				end

				local value67 = parts[10]
				local password2 = parts[11] == "1"
				local number89 = parts[12] == "1"

				if path.pointWith == 0 then
					number24 = mainBgh - number24
				end

				if path.highPixels then
					number44 = _posWithCenter(number44)
				end

				local value68 = number44 + path.x_offset
				local value69 = extendUI.genname(value2, value3, value68, number24, path.mainName)

				extendUI.rebuildelm(value69, value)

				local label5

				label5 = an.newInput(value68, number24, number79, number80, number56, {
					password = password2,
					label = {
						"",
						number56
					},
					return_call = function()
						if value67 then
							if number89 then
								local items19 = {
									ident = SM_MERCHANT_QUERY,
									param = tonumber(number89),
									recog = path.merchant,
									CM_MERCHANT_QUERY,
									tag = 0
								}

								items19.series = 1

								net.send(items19, {
									label5:getText()
								})
							else
								extendUI.callCMD2(bzmir.mcmd .. value67 .. bzmir.cmdcnt .. label5:getText())
							end
						end
					end,
					start_call = function()
						if label5:getText() == value31 then
							label5:clear()
						end
					end
				}):addTo(value, count):scale(number81):anchor(align2, aligny2)

				label5:setName(value69)

				if value31 then
					label5:setText(value31)
				end
			elseif value2 == "Number" then
				local value6 = parts[3]
				local value32 = extendUI.genpicpath(parts[4])
				local value14 = parts[5]
				local value33 = parts[6]
				local number45 = tonumber(parts[7]) or 5
				local number10 = tonumber(parts[8]) or mainBgh / 2
				local number57 = tonumber(parts[9])
				local number58 = tonumber(parts[10])
				local number25 = tonumber(parts[11])
				local number82 = tonumber(parts[12])
				local value34 = parts[13]
				local value15 = parts[14]
				local value96 = parts[15]
				local number83 = tonumber(parts[16]) or 0
				local number84 = tonumber(parts[17]) or 1

				if value34 then
					if value34 == "left" then
						align2 = 0
					elseif value34 == "right" then
						align2 = 1
					end
				end

				if value33 and number57 and number58 then
					if path.pointWith == 0 then
						number10 = mainBgh - number10
					end

					if path.highPixels then
						number45 = _posWithCenter(number45)
					end

					local x2 = number45 + path.x_offset
					local value35 = extendUI.genname(value2, value3, x2, number10, path.mainName)

					extendUI.rebuildelm(value35, value)

					local texforCUS
					local texforCUS2

					if value14 and value14 == "1" then
						texforCUS = res.gettexforCUS(value6, value32)
					else
						local value70 = bzmir.diynpc .. value6 .. bzmir.prefix .. value32 .. bzmir.ext

						if string.byte(value6) == 35 then
							value70 = value6 .. bzmir.prefix .. value32 .. bzmir.ext
						end

						texforCUS = _gettex2(value70)
					end

					if value15 then
						if value14 and value14 == "1" then
							texforCUS2 = res.gettexforCUS(value6, value15)
						else
							local value71 = bzmir.diynpc .. value6 .. bzmir.prefix .. value15 .. bzmir.ext

							if string.byte(value6) == 35 then
								value71 = value6 .. bzmir.prefix .. value15 .. bzmir.ext
							end

							texforCUS2 = _gettex2(value71)
						end
					end

					if texforCUS then
						local value72 = string.byte("0")

						if number25 and number25 == 1 then
							value72 = string.byte(bzmir.prefix)
						end

						local label6 = cc.Label:createWithCharMap(texforCUS, number57, number58, value72):anchor(align2, aligny2):pos(x2, number10):add2(value):scale(number82 or 1)

						label6:setName(value35)

						if number25 and number25 == 1 then
							label6:setString(bzmir.prefix .. value33)
						else
							label6:setString(value33)
						end

						if texforCUS2 then
							local value73 = value35 .. "unit"

							extendUI.rebuildelm(value73, value)

							local x4 = 0
							local value36 = 30 + number83

							if value96 == "1" then
								if align2 == 0.5 then
									x4 = x2 - value36 - 3 - label6:getw() / 2
								elseif align2 == 1 then
									x4 = x2 - value36 - 3 - label6:getw()
								else
									x4 = x2 - value36 - 3
								end
							elseif align2 == 0.5 then
								x4 = x2 + label6:getw() / 2 + 3
							elseif align2 == 1 then
								x4 = x2 + 3
							else
								x4 = x2 + label6:getw() + 3
							end

							display.newSprite(texforCUS2):anchor(0, aligny2):pos(x4, number10):add2(value):scale(number84):setName(value73)
						end
					end
				end
			end
		elseif value11 == "0" then
			local value97, value98 = extendUI.checkType(parts[2])
			local number = tonumber(parts[3]) or 0
			local number26 = tonumber(parts[4]) or 0

			if number26 and path.pointWith == 0 then
				number26 = path.mainBgh - number26
			end

			if number and path.highPixels then
				number = _posWithCenter(number)
			end

			number = number and number + path.x_offset

			local value99 = extendUI.genname(value97, value98, number, number26, path.mainName)

			extendUI.rebuildelm(value99, path.content)
		elseif value11 == "2" then
			local value100, value101 = extendUI.checkType(parts[2])
			local number85 = tonumber(parts[3]) or 0
			local number2 = tonumber(parts[4]) or 0
			local number27 = tonumber(parts[5]) or 0

			if number27 and path.pointWith == 0 then
				number27 = path.mainBgh - number27
			end

			if number2 and path.highPixels then
				number2 = _posWithCenter(number2)
			end

			number2 = number2 and number2 + path.x_offset

			local value102 = extendUI.genname(value100, value101, number2, number27, path.mainName)
			local node3 = extendUI.getChild(value102, path.content)

			if node3 then
				if number85 == 1 then
					node3:setVisible(false)
				else
					node3:setVisible(true)
				end
			end
		elseif value11 == "ScrollTo" then
			local value103, value104 = extendUI.checkType(parts[2])
			local number86 = tonumber(parts[3]) or 0
			local number87 = tonumber(parts[4]) or 0
			local value105 = extendUI.genname(value103, value104, nil, nil, path.mainName)
			local child = extendUI.getChild(value105, path.content)

			if child and child.scrollView then
				child.scrollView:scrollTo(number86, number87)
			end
		end
	end
end

function extendUI:checkType()
	local parts = string.split(self, "-")

	return parts[1], parts[2]
end

function extendUI:callCMD2(value)
	if g_data.client:checkLastTime("npc_cm", 0.1) then
		g_data.client:setLastTime("npc_cm", true)
	else
		main_scene.ui:tip("点击过快")
	end
end

function extendUI:genpicpath()
	local value = self

	if self:find("-") ~= nil then
		local parts = string.split(self, "-")

		for index, item2 in ipairs(parts) do
			if index == 1 then
				value = item2
			else
				value = value .. bzmir.prefix .. item2
			end
		end
	end

	return value
end

function extendUI:genname(value, text2, text3, value2)
	if value then
		return value2 .. self .. value
	else
		return value2 .. self .. "-" .. tostring(text2) .. "-" .. tostring(text3)
	end
end

function extendUI:getChild(value)
	if value then
		local childByName = value:getChildByName(self)

		if not childByName and value then
			local children = value:getChildren()

			if children then
				for _, item2 in ipairs(children) do
					if item2 then
						childByName = item2:getChildByName(self)

						if childByName then
							return childByName
						elseif item2 then
							local children2 = item2:getChildren()

							if children2 then
								for _2, item3 in ipairs(children2) do
									if item3 then
										childByName = item3:getChildByName(self)

										if childByName then
											return childByName
										end
									end
								end
							end
						end
					end
				end
			end
		end

		return childByName
	end

	return nil
end

function extendUI:rebuildelm(value)
	local node = extendUI.getChild(self, value)

	if node then
		node:setVisible(false)
		node:removeSelf()

		local value2
	end
end

return extendUI
