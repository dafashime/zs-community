local extendUINew = {}
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

function extendUINew.init(content2, mainName, merchant, align2, pointWith, options)
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

	extendUINew.registerEvent(content2, items)

	return items
end

function extendUINew.create(content2, text2, mainName, merchant, align2, pointWith, value)
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
			extendUINew.load(item2, items)
		end

		extendUINew.registerEvent(content2, items)

		return items
	end

	return nil
end

function extendUINew:registerEvent(event)
	if self.isEventProxyRegd then
		return
	end

	local function cleanup(self2)
		local value6 = self2:split("@")
		local value7 = self

		if value6[2] then
			local value28, value29 = extendUINew.checkType(value6[2])
			local value30 = extendUINew.genname(value28, value29, nil, nil, event.mainName)
			local child = extendUINew.getChild(value30, self)

			if child then
				value7 = child
			end
		end

		local value31, value32 = extendUINew.checkType(value6[1])
		local value33 = extendUINew.genname(value31, value32 or "nil", nil, nil, event.mainName)

		return extendUINew.getChild(value33, value7), value7
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
			local value18 = extendUINew.genpicpath(response4.data.fileName)
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
			local value10 = extendUINew.genpicpath(response.data.filePath)
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

function extendUINew.createToggle(self4, value, label2, temp)
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

function extendUINew.load(self2, path)
	if path.content and self2 then
		if def.debug then
			print(self2)
		end

		local align2 = 0
		local aligny2 = 0
		local count = 1

		local function callback(self3)
			if self3 then
				if self3 == "left" then
					return 0, 0
				elseif self3 == "topleft" then
					return 0, 1
				elseif self3 == "right" then
					return 1, 0
				elseif self3 == "center" then
					return 0.5, 0.5
				end
			end

			return align2, aligny2
		end

		local parts = string.split(self2, ":")
		local text7 = parts[1]
		local value16 = parts[2]
		local value41 = parts[3]

		if not value41 then
			return
		end

		local parts2 = string.split(text7, bzmir.mcmd)
		local value17 = parts2[1]
		local value42 = parts2[2]
		local color2 = loadstring("return {" .. value41 .. "}")()

		if not color2 then
			return
		end

		local value145

		if value17 == "1" then
			local value4, value81 = extendUINew.checkType(value16)

			align2, aligny2 = callback(path.align)

			local value = path.content

			if value42 then
				local value82, value83 = extendUINew.checkType(value42)
				local value84 = extendUINew.genname(value82, value83, nil, nil, path.mainName)
				local child2 = extendUINew.getChild(value84, path.content)

				if child2 then
					value = child2
				end
			end

			local h = value:geth()
			local posx2 = color2.x or 0
			local posy2 = color2.y or 0

			if color2.center then
				posx2 = value:getw() / 2
				posy2 = value:geth() / 2
			else
				if path.pointWith == 0 then
					posy2 = h - posy2
				end

				if path.highPixels then
					posx2 = _posWithCenter(posx2)
				end

				posx2 = posx2 + path.x_offset
			end

			local width = color2.width
			local height = color2.height
			local value23 = color2.anchor

			if value23 then
				align2, aligny2 = callback(value23)
			end

			local value3 = color2.z or 1
			local value2 = extendUINew.genname(value4, value81, posx2, posy2, path.mainName)

			if value4 == "Text" then
				local value85 = color2.fontSize or 20
				local text6 = color2.text or "未指定文本"
				local color6 = cc.c3b(245, 210, 100)

				if string.find(text6, bzmir.mcmd) ~= nil then
					local parts3 = string.split(text6, bzmir.mcmd)

					color6 = _stringToCorlor(parts3[2])
					text6 = parts3[1]
				end

				extendUINew.rebuildelm(value2, value)

				local label4 = an.newLabel(text6, value85, 1, {
					color = color6
				}):anchor(align2, aligny2):addTo(value, value3 or count):pos(posx2, posy2)

				label4:setName(value2)

				local value13 = color2.movetoX

				if value13 and path.highPixels then
					value13 = _posWithCenter(value13)
				end

				local value43 = color2.movetoY or h / 2
				local value44 = color2.delay

				if value13 and value43 and value44 and label4 and tolua.cast(label4, "cc.Node") then
					label4:stopAllActions()
					label4:moveTo(value44, value13, value43)
				end
			elseif value4 == "LabelM" then
				width = width or 100

				local value86 = color2.fontSize or 20
				local value87 = color2.text or "未指定文本"

				extendUINew.rebuildelm(value2, value)

				if not c_createColorLabel then
					os.exit()
				end

				c_createColorLabel(value87, display.COLOR_WHITE, width, value86, {
					manual = false,
					center = value23 == "center"
				}):anchor(align2, aligny2):addTo(value, value3 or count):pos(posx2, posy2):setName(value2)
			elseif value4 == "Img" then
				local value24 = color2.dir
				local value88 = color2.scale or 1
				local value45 = color2.touch

				extendUINew.rebuildelm(value2, value)

				local value46 = extendUINew.genpicpath(color2.pic)
				local value47 = bzmir.diynpc .. value24 .. bzmir.prefix .. value46 .. bzmir.ext

				if string.byte(value24) == 35 then
					value47 = value24 .. bzmir.prefix .. value46 .. bzmir.ext
				end

				local text2 = color2.text
				local value48 = _gettex2(value47)

				if text2 and text2 ~= "" and text2 ~= "nil" then
					local enabled4 = false
					local value25 = bzmir.mcmd

					if color2.cmd then
						value25 = value25 .. color2.cmd
						enabled4 = true
					end

					local items = {}
					local items14 = {}

					items14.pressBig = true

					if value45 then
						items14.support = "scroll"
					end

					local btn = an.newBtn(value48, function()
						return
					end, items14):anchor(align2, aligny2):pos(posx2, posy2):add2(value, value3 or count)

					btn:setName(value2)
					btn:setScale(value88)
					btn:setTouchEnabled(true)

					if value45 then
						btn:setTouchSwallowEnabled(false)
					end

					btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos2)
						if startPos2.name == "began" then
							btn.startPos = cc.p(startPos2.x, startPos2.y)

							return true
						elseif startPos2.name == "ended" and cc.pGetDistance(btn.startPos, startPos2) <= 10 then
							local texts = {}
							local items6 = {}

							if string.find(text2, "\\") ~= nil then
								items6 = string.split(text2, "\\")
							else
								items6[#items6 + 1] = text2
							end

							for _2, item3 in ipairs(items6) do
								local items16 = {
									text = item3
								}

								if string.find(item3, bzmir.mcmd) ~= nil then
									local parts4 = string.split(item3, bzmir.mcmd)

									items16.color = _stringToCorlor(parts4[2])
									items16.text = parts4[1]
								end

								texts[#texts + 1] = items16
							end

							items.texts = texts

							if enabled4 then
								items.btns = {}

								local items21 = {
									name = color2.cmdText or "",
									click = function()
										sound.playSound("103")
										extendUINew.callCMD2(value25, path.merchant)
									end
								}

								items.btns[#items.btns + 1] = items21
							end

							local items22 = {
								x = startPos2.x,
								y = startPos2.y
							}

							textInfo.create(items, items22, {
								from = "npc"
							})
						end
					end)
				else
					display.newSprite(value48):anchor(align2, aligny2):pos(posx2, posy2):add2(value, value3 or count):setName(value2)
				end
			elseif value4 == "DImg" then
				local value49 = color2.dir
				local enabled = false

				if color2.touch then
					enabled = true
				end

				local value50 = color2.pic
				local value51 = color2.scale or 1
				local text3 = color2.text

				extendUINew.rebuildelm(value2, value)

				local texforCUS3 = res.gettexforCUS(value49, value50)

				if text3 and text3 ~= "" and text3 ~= "nil" then
					local enabled5 = false
					local value26 = bzmir.mcmd

					if color2.cmd then
						value26 = value26 .. color2.cmd
						enabled5 = true
					end

					local items2 = {}
					local items15 = {}

					items15.pressBig = true

					if enabled then
						items15.support = "scroll"
					end

					local btn2 = an.newBtn(texforCUS3, function()
						sound.playSound("103")
					end, items15):anchor(align2, aligny2):pos(posx2, posy2):add2(value, value3 or count)

					btn2:setName(value2)
					btn2:setScale(value51)
					btn2:setTouchEnabled(true)

					if enabled then
						btn2:setTouchSwallowEnabled(false)
					end

					btn2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos3)
						if startPos3.name == "began" then
							btn2.startPos = cc.p(startPos3.x, startPos3.y)

							return true
						elseif startPos3.name == "ended" and cc.pGetDistance(btn2.startPos, startPos3) <= 10 then
							local texts2 = {}
							local items7 = {}

							if string.find(text3, "\\") ~= nil then
								items7 = string.split(text3, "\\")
							else
								items7[#items7 + 1] = text3
							end

							for _3, item4 in ipairs(items7) do
								local items17 = {
									text = item4
								}

								if string.find(item4, bzmir.mcmd) ~= nil then
									local parts5 = string.split(item4, bzmir.mcmd)

									items17.color = _stringToCorlor(parts5[2])
									items17.text = parts5[1]
								end

								texts2[#texts2 + 1] = items17
							end

							items2.texts = texts2

							if enabled5 then
								items2.btns = {}

								local items23 = {
									name = color2.cmdText or "",
									click = function()
										sound.playSound("103")
										extendUINew.callCMD2(value26, path.merchant)
									end
								}

								items2.btns[#items2.btns + 1] = items23
							end

							local items24 = {
								x = startPos3.x,
								y = startPos3.y
							}

							textInfo.create(items2, items24, {
								from = "npc"
							})
						end
					end)
				else
					display.newSprite(res.gettexforCUS(value49, value50)):anchor(align2, aligny2):pos(posx2, posy2):add2(value, value3 or count):scale(value51):setName(value2)
				end
			elseif value4 == "Item" then
				local value18 = color2.itemName
				local enabled6 = false

				if color2.touch then
					enabled6 = true
				end

				local value89 = color2.makeindex or 0
				local value90 = color2.scale or 1
				local value91 = color2.showBg
				local value92 = color2.showEffect
				local value93 = color2.customBg
				local value146 = color2.anchor
				local item7
				local var
				local value147

				extendUINew.rebuildelm(value2, value)

				if value18 == "1" then
					local item8

					item8, item7 = g_data.bag:getItem(value89)

					if item7 then
						value18 = item7.getVar("name")
						var = item7.getVar("looks")
					end
				else
					item7 = def.items.getItemByName(value18, 3, 3)
					var = item7 and item7.looks
				end

				if item7 then
					local itemsWithBg = res.getItemsWithBg("items", value18, var, value91, value92, value93):anchor(align2, aligny2):pos(posx2, posy2):addto(value, value3 or count):scale(value90)

					itemsWithBg.params = {
						posx = posx2,
						posy = posy2,
						align = align2,
						aligny = aligny2
					}

					itemsWithBg:setName(value2)
					itemsWithBg:setTouchEnabled(true)

					if enabled6 then
						itemsWithBg:setTouchSwallowEnabled(false)
					end

					itemsWithBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos)
						if startPos.name == "began" then
							itemsWithBg.startPos = cc.p(startPos.x, startPos.y)

							return true
						elseif startPos.name == "ended" and cc.pGetDistance(itemsWithBg.startPos, startPos) <= 10 then
							local enabled2 = false

							if itemsWithBg.centerPos then
								local point = itemsWithBg:convertToWorldSpace(itemsWithBg.centerPos)

								if startPos.x >= point.x - itemsWithBg.centerPos.x and startPos.x <= point.x + itemsWithBg.centerPos.x and startPos.y >= point.y - itemsWithBg.centerPos.y and startPos.y <= point.y + itemsWithBg.centerPos.y then
									enabled2 = true
								end
							else
								enabled2 = true
							end

							if enabled2 and item7 then
								itemInfo.create(item7, cc.p(startPos.x, startPos.y), {
									from = "extUI"
								})
							end
						end
					end)
				end
			elseif value4 == "ItemM" then
				local value94 = color2.itemName
				local scale2 = color2.scale or 1
				local lineNum2 = color2.lineNum or 5
				local pic2 = color2.bgDir
				local bgpic2 = color2.bgPic
				local showEffect2 = color2.showEffect
				local checkbag2 = color2.checkInbag

				extendUINew.rebuildelm(value2, value)

				local node = display.newNode():addTo(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2)

				node.params = {
					lineNum = lineNum2,
					pic = pic2,
					scale = scale2,
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

				local items10 = value94:split("$")
				local number12 = 3
				local value27 = bzmir.diynpc .. pic2 .. bzmir.prefix .. bgpic2 .. bzmir.ext

				if string.byte(pic2) == 35 then
					value27 = pic2 .. bzmir.prefix .. bgpic2 .. bzmir.ext
				end

				local value52 = _get2(value27)
				local h2 = value52:geth() + number12
				local w = value52:getw() + number12
				local count3 = 1
				local width2 = w * lineNum2
				local height2 = h2 * math.modf(#items10 / lineNum2)

				node:size(width2, height2)
				node:setName(value2)

				local x5 = 0
				local y2 = height2

				for _, item2 in ipairs(items10) do
					local enabled7 = true

					if checkbag2 then
						local itemWithName, itemWithName2 = g_data.bag.getItemWithName(item2)

						if not itemWithName then
							enabled7 = false
						end
					end

					local itemByName = def.items.getItemByName(item2, 3, 3)

					if itemByName and enabled7 then
						local x4 = _get2(value27):anchor(align2, aligny2):pos(x5, y2):add2(node)
						local itemsWithBg2 = res.getItemsWithBg("items", item2, itemByName.looks, false, showEffect2):anchor(0.5, 0.5):pos(x4:getw() / 2, x4:geth() / 2):addto(x4):scale(scale2)

						itemsWithBg2:setTouchEnabled(true)
						itemsWithBg2:setTouchSwallowEnabled(false)
						itemsWithBg2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x2)
							if x2.name == "began" then
								return true
							elseif x2.name == "ended" then
								local enabled3 = false

								if itemsWithBg2.centerPos then
									local point2 = itemsWithBg2:convertToWorldSpace(itemsWithBg2.centerPos)

									if x2.x >= point2.x - itemsWithBg2.centerPos.x and x2.x <= point2.x + itemsWithBg2.centerPos.x and x2.y >= point2.y - itemsWithBg2.centerPos.y and x2.y <= point2.y + itemsWithBg2.centerPos.y then
										enabled3 = true
									end
								else
									enabled3 = true
								end

								if enabled3 and itemByName then
									itemInfo.create(itemByName, cc.p(x2.x, x2.y), {
										from = "extUI"
									})
								end
							end
						end)

						local value53 = count3 % lineNum2
						local value95 = math.modf(count3 / lineNum2)

						if value53 == lineNum2 then
							x5 = 0
						else
							x5 = 0 + value53 * w
							y2 = height2 - value95 * h2
						end

						node.items[count3] = x4
						count3 = count3 + 1
					end
				end
			elseif value4 == "DSpr" then
				local value28 = extendUINew.genpicpath(color2.dir)
				local enabled8 = false

				if color2.touch then
					enabled8 = true
				end

				local value29 = color2.pic or 1
				local value54 = color2.pnum or 2
				local text4 = color2.text
				local value55 = color2.interval or 0.1
				local duration = color2.runTimes
				local value96 = color2.autoRemove
				local value56 = color2.scale or 1
				local value5
				local value14

				extendUINew.rebuildelm(value2, value)

				if duration then
					value14 = m2spr.new(value28, value29, {
						setOffset = true
					})
					value5 = value14.spr

					value5:pos(posx2, posy2):add2(value, value3 or count):anchor(align2, aligny2):scale(value56):runs({
						cc.DelayTime:create(duration),
						cc.CallFunc:create(function()
							if value96 then
								if value5 then
									value5:removeSelf()

									value5 = nil
									value14 = nil
								end
							else
								value14:stopAnimation()
							end
						end)
					})
					value14:playAni(value28, value29, value54, value55, false)
				else
					value5 = m2spr.playAnimation(value28, value29, value54, value55, false):pos(posx2, posy2):add2(value, value3 or count):anchor(align2, aligny2):scale(value56)
				end

				value5:setName(value2)
				value5:show()

				if text4 and text4 ~= "nil" then
					local items3 = {}
					local enabled9 = false
					local value30 = bzmir.mcmd

					if color2.cmd then
						value30 = value30 .. color2.cmd
						enabled9 = true
					end

					value5:setTouchEnabled(true)

					if enabled8 then
						value5:setTouchSwallowEnabled(false)
					end

					value5:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos4)
						if startPos4.name == "began" then
							value5.startPos = cc.p(startPos4.x, startPos4.y)

							return true
						elseif startPos4.name == "ended" and cc.pGetDistance(value5.startPos, startPos4) <= 10 then
							local texts3 = {}
							local items8 = {}

							if string.find(text4, "\\") ~= nil then
								items8 = string.split(text4, "\\")
							else
								items8[#items8 + 1] = text4
							end

							for _4, item5 in ipairs(items8) do
								local items18 = {
									text = item5
								}

								if string.find(item5, bzmir.mcmd) ~= nil then
									local parts6 = string.split(item5, bzmir.mcmd)

									items18.color = _stringToCorlor(parts6[2])
									items18.text = parts6[1]
								end

								texts3[#texts3 + 1] = items18
							end

							items3.texts = texts3

							if enabled9 then
								items3.btns = {}

								local items25 = {
									name = color2.cmdText or "",
									click = function()
										sound.playSound("103")
										extendUINew.callCMD2(value30, path.merchant)
									end
								}

								items3.btns[#items3.btns + 1] = items25
							end

							local items26 = {
								x = startPos4.x,
								y = startPos4.y
							}

							textInfo.create(items3, items26, {
								from = "npc"
							})
						end
					end)
				end
			elseif value4 == "Spr" then
				local value57 = extendUINew.genpicpath(color2.dir)
				local enabled10 = false

				if color2.touch then
					enabled10 = true
				end

				local value58 = color2.pstart or 1
				local value97 = color2.pend or 2
				local text5 = color2.text
				local duration2 = color2.runTimes
				local value98 = color2.interval or 0.1
				local value99 = color2.scale or 1

				extendUINew.rebuildelm(value2, value)

				local value31 = _getani2(bzmir.diynpc .. value57 .. bzmir.ext1, value58, value97, value98)

				value31.retain(value31)

				local value6 = _get2(bzmir.diynpc .. value57 .. bzmir.prefix .. value58 .. bzmir.ext):pos(posx2, posy2):add2(value, value3 or count):anchor(align2, aligny2)

				value6:setScale(value99)
				value6:runForever(cc.Animate:create(value31))

				if duration2 then
					value6:runs({
						cc.DelayTime:create(duration2),
						cc.CallFunc:create(function()
							if value6 then
								value6:removeSelf()

								value6 = nil
							end
						end)
					})
				end

				value6:setName(value2)

				if text5 and text5 ~= "nil" then
					local items4 = {}
					local enabled11 = false
					local value32 = bzmir.mcmd

					if color2.cmd then
						value32 = value32 .. color2.cmd
						enabled11 = true
					end

					value6:setTouchEnabled(true)

					if enabled10 then
						value6:setTouchSwallowEnabled(false)
					end

					value6:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos5)
						if startPos5.name == "began" then
							value6.startPos = cc.p(startPos5.x, startPos5.y)

							return true
						elseif startPos5.name == "ended" and cc.pGetDistance(value6.startPos, startPos5) <= 10 then
							local texts4 = {}
							local items9 = {}

							if string.find(text5, "\\") ~= nil then
								items9 = string.split(text5, "\\")
							else
								items9[#items9 + 1] = text5
							end

							for _5, item6 in ipairs(items9) do
								local items19 = {
									text = item6
								}

								if string.find(item6, bzmir.mcmd) ~= nil then
									local parts7 = string.split(item6, bzmir.mcmd)

									items19.color = _stringToCorlor(parts7[2])
									items19.text = parts7[1]
								end

								texts4[#texts4 + 1] = items19
							end

							items4.texts = texts4

							if enabled11 then
								items4.btns = {}

								local items27 = {
									name = color2.cmdText or "",
									click = function()
										sound.playSound("103")
										extendUINew.callCMD2(value32, path.merchant)
									end
								}

								items4.btns[#items4.btns + 1] = items27
							end

							local items28 = {
								x = startPos5.x,
								y = startPos5.y
							}

							textInfo.create(items4, items28, {
								from = "npc"
							})
						end
					end)
				end
			elseif value4 == "RBtn" then
				local value8 = extendUINew.genpicpath(color2.dir)
				local enabled12 = false

				if color2.touch then
					enabled12 = true
				end

				local value100 = color2.fontSize or 18
				local value59 = _stringToCorlor(color2.fontColor)
				local value101 = color2.isCheck
				local value60 = bzmir.diynpc .. value8 .. bzmir.prefix .. color2.pic .. bzmir.ext

				if string.byte(value8) == 35 then
					value60 = value8 .. bzmir.prefix .. color2.pic .. bzmir.ext
				end

				extendUINew.rebuildelm(value2, value)

				local value102 = _gettex2(value60)
				local text8 = ""

				if color2.cmd then
					text8 = bzmir.mcmd .. color2.cmd
				else
					text8 = "@no"
				end

				local items11 = {}

				if color2.sprite then
					items11.sprite = _gettex2(bzmir.diynpc .. value8 .. bzmir.prefix .. color2.sprite .. bzmir.ext)
				elseif color2.cmdText and color2.cmdText ~= "" then
					local color7 = cc.c3b(245, 245, 245)

					if value59 then
						color7 = value59
					end

					items11.label = {
						color2.cmdText,
						value100,
						1,
						{
							color = color7
						}
					}
				end

				if color2.pressPic then
					local value33 = bzmir.diynpc .. value8 .. bzmir.prefix .. color2.pressPic .. bzmir.ext

					if string.byte(value8) == 35 then
						value33 = value8 .. bzmir.prefix .. color2.pressPic .. bzmir.ext
					end

					if not value101 then
						items11.pressImage = _gettex2(value33)
					else
						items11.select = {
							_gettex2(value33)
						}
					end
				else
					items11.pressBig = true
				end

				if enabled12 then
					items11.support = "scroll"
				end

				local btn3 = an.newBtn(value102, function()
					sound.playSound("103")
					extendUINew.callCMD2(text8, path.merchant)
				end, items11):anchor(align2, aligny2):pos(posx2, posy2):addto(value, value3 or count)

				btn3:setTouchEnabled(true)
				btn3:setName(value2)
			elseif value4 == "DRBtn" then
				local value19 = color2.dir
				local enabled13 = false

				if color2.touch then
					enabled13 = true
				end

				local value103 = color2.scale or 1
				local value104 = color2.fontSize or 18
				local value61 = _stringToCorlor(color2.fontColor)
				local value105 = color2.isCheck
				local texforCUS4 = res.gettexforCUS(value19, color2.pic)
				local text9 = ""

				if color2.cmd then
					text9 = bzmir.mcmd .. color2.cmd
				else
					text9 = "@no"
				end

				local items12 = {}

				extendUINew.rebuildelm(value2, value)

				if color2.sprite then
					items12.sprite = res.gettexforCUS(value19, color2.sprite)
				elseif color2.cmdText and color2.cmdText ~= "" then
					local color8 = cc.c3b(245, 245, 245)

					if value61 then
						color8 = value61
					end

					items12.label = {
						color2.cmdText,
						value104,
						1,
						{
							color = color8
						}
					}
				end

				if color2.pressPic then
					if not value105 then
						items12.pressImage = res.gettexforCUS(value19, color2.pressPic)
					else
						items12.select = {
							res.gettexforCUS(value19, color2.pressPic)
						}
					end
				else
					items12.pressBig = true
				end

				if enabled13 then
					items12.support = "scroll"
				end

				local btn4 = an.newBtn(texforCUS4, function()
					sound.playSound("103")
					extendUINew.callCMD2(text9, path.merchant)
				end, items12):anchor(align2, aligny2):pos(posx2, posy2):addto(value, value3 or count):scale(value103)

				btn4:setTouchEnabled(true)
				btn4:setName(value2)
			elseif value4 == "RCmd" then
				local value106 = color2.fontSize or 20
				local color4 = _stringToCorlor(color2.fontColor)
				local value62 = color2.cmd
				local text10 = ""

				if value62 then
					text10 = bzmir.mcmd .. value62
				else
					text10 = "@no"
				end

				extendUINew.rebuildelm(value2, value)

				local label2 = an.newLabel(color2.cmdText or "确定", value106, 1, {
					color = color4
				}):addTo(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2)

				label2:setName(value2)
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
							label2:scale(1):setColor(color4)

							if not label2.disable then
								extendUINew.callCMD2(text10, path.merchant)
							end
						end
					elseif cc.pGetDistance(label2.startPos, startPos6) > 35 then
						label2:scale(1):setColor(color4)

						label2.disable = true
					end
				end)
			elseif value4 == "Btn" then
				local value11 = extendUINew.genpicpath(color2.dir)
				local enabled14 = false

				if color2.touch then
					enabled14 = true
				end

				local value107 = color2.fontSize or 18
				local value63 = _stringToCorlor(color2.fontColor)
				local value108 = color2.isCheck
				local value64 = bzmir.diynpc .. value11 .. bzmir.prefix .. color2.pic .. bzmir.ext

				if string.byte(value11) == 35 then
					value64 = value11 .. bzmir.prefix .. color2.pic .. bzmir.ext
				end

				extendUINew.rebuildelm(value2, value)

				local value109 = _gettex2(value64)
				local text11 = ""

				if color2.cmd then
					text11 = bzmir.mcmd .. color2.cmd
				else
					text11 = "@no"
				end

				local items13 = {}

				if color2.cmdText and color2.cmdText ~= "" then
					local color9 = cc.c3b(245, 245, 245)

					if value63 then
						color9 = value63
					end

					items13.label = {
						color2.cmdText,
						value107,
						1,
						{
							color = color9
						}
					}
				end

				items13.pressBig = true

				if color2.pressPic then
					local value34 = bzmir.diynpc .. value11 .. bzmir.prefix .. color2.pressPic .. bzmir.ext

					if string.byte(value11) == 35 then
						value34 = value11 .. bzmir.prefix .. color2.pressPic .. bzmir.ext
					end

					if value108 then
						items13.pressImage = _gettex2(value34)
					else
						items13.select = {
							_gettex2(value34),
							manual = true
						}
					end
				end

				if enabled14 then
					items13.support = "scroll"
				end

				an.newBtn(value109, function()
					sound.playSound("103")
					extendUINew.callCMD2(text11, path.merchant)
				end, items13):anchor(align2, aligny2):pos(posx2, posy2):addto(value, value3 or count):setName(value2)
			elseif value4 == "Cmd" then
				local value110 = color2.fontSize or 20
				local color5 = _stringToCorlor(color2.fontColor)
				local text12 = ""

				if color2.cmd then
					text12 = bzmir.mcmd .. color2.cmd
				else
					text12 = "@no"
				end

				extendUINew.rebuildelm(value2, value)

				local label3 = an.newLabel(color2.cmdText or "确定", value110, 1, {
					color = color5
				}):addTo(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2)

				label3:setName(value2)
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
							label3:scale(1):setColor(color5)

							if not label3.disable then
								extendUINew.callCMD2(text12, path.merchant)
							end
						end
					elseif cc.pGetDistance(label3.startPos, startPos7) > 35 then
						label3:scale(1):setColor(color5)

						label3.disable = true
					end
				end)
			elseif value4 == "PUTBOX" then
				local value111 = color2.dir
				local value112 = color2.pic
				local putItemCmd = color2.putCmd
				local value113 = color2.boxId
				local sc = color2.scale or 1
				local supportItems

				if color2.items then
					supportItems = color2.items:split("$")
				end

				local value114 = bzmir.diynpc .. value111 .. bzmir.prefix .. value112 .. bzmir.ext
				local value115 = _gettex2(value114)

				extendUINew.rebuildelm(value2, value)

				local sprite = display.newSprite(value115):anchor(align2, aligny2):pos(posx2, posy2):add2(value, value3 or count)

				sprite:setTouchEnabled(true)

				if color2.touch then
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
				sprite:setName(value2)

				sprite.putItemCmd = putItemCmd
				sprite.sc = sc
				sprite.supportItems = supportItems
				value.itemBoxs[value113] = sprite
			elseif value4 == "DELITEM" then
				if value.itemBoxs[color2.boxId] then
					value:delItem(value.itemBoxs[color2.boxId])
				end
			elseif value4 == "S" then
				width = width or 100
				height = height or 100

				local value116 = color2.hidden
				local value65 = color2.scrollTo
				local dir2 = color2.dir or 1

				extendUINew.rebuildelm(value2, value)

				local node3 = an.newScroll(0, 0, width, height, {
					dir = dir2
				}):addTo(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2)

				node3:setName(value2)

				if value65 then
					node3.scrollView:scrollTo(0, value65)
				end

				if value116 then
					node3:setVisible(false)
				end

				return
			elseif value4 == "SetS" then
				if value2 then
					local label7 = extendUINew.getChild(value2, value)

					if label7 and color2.text then
						if label7.setString then
							label7:setString(color2.text)
						elseif label7.label and label7.label.setString then
							label7.label:setString(color2.text)
						end
					end
				end
			elseif value4 == "CheckBox" then
				local value66 = color2.dir
				local value117 = color2.pic
				local value148 = color2.checkPic
				local value67 = color2.isCheck
				local value118 = color2.fontSize or 16
				local color10 = _stringToCorlor(color2.fontColor, cc.c3b(220, 210, 190))
				local value119 = color2.cmdText
				local value68 = color2.cmd

				extendUINew.rebuildelm(value2, value)

				local unCheckImg2 = bzmir.diynpc .. value66 .. bzmir.prefix .. value117 .. bzmir.ext
				local checkedImg2 = color2.checkPic and bzmir.diynpc .. value66 .. bzmir.prefix .. color2.checkPic .. bzmir.ext or unCheckImg2

				extendUINew.createToggle(function(value149)
					if value68 then
						local value144 = value67 and "1" or "0"

						extendUINew.callCMD2(bzmir.mcmd .. value68 .. bzmir.cmdcnt .. value16 .. bzmir.cmdcnt .. value144)
					end
				end, value67, {
					value119,
					value118,
					1,
					{
						color = color10
					}
				}, {
					unCheckImg = unCheckImg2,
					checkedImg = checkedImg2
				}):addTo(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2):setName(value2)
			elseif value4 == "Input" then
				width = width or 100
				height = height or 30

				local value69 = color2.fontSize or 16
				local value35 = color2.text
				local value120 = color2.scale or 1
				local value70 = color2.cmd
				local password2 = color2.password
				local number11 = color2.ok

				extendUINew.rebuildelm(value2, value)

				local label5

				label5 = an.newInput(posx2, posy2, width, height, value69, {
					password = password2,
					label = {
						"",
						value69
					},
					return_call = function()
						if value70 then
							if number11 then
								local items20 = {
									ident = SM_MERCHANT_QUERY,
									param = tonumber(number11),
									recog = path.merchant,
									CM_MERCHANT_QUERY,
									tag = 0
								}

								items20.series = 1

								net.send(items20, {
									label5:getText()
								})
							else
								extendUINew.callCMD2(bzmir.mcmd .. value70 .. bzmir.cmdcnt .. label5:getText())
							end
						end
					end,
					start_call = function()
						if label5:getText() == value35 then
							label5:clear()
						end
					end
				}):addTo(value, value3 or count):scale(value120):anchor(align2, aligny2)

				label5:setName(value2)

				if value35 then
					label5:setText(value35)
				end
			elseif value4 == "Number" then
				local value7 = color2.dir
				local value36 = color2.pic
				local value71 = color2.useData
				local value37 = color2.number
				local value72 = color2.numWidth
				local value73 = color2.numHeight
				local value74 = color2.havePlus
				local value121 = color2.scale or 1
				local value20 = color2.unitPic
				local value122 = color2.unitFront
				local value123 = color2.unitOfsetx or 0
				local value124 = color2.unitScale or 1

				if value37 and value72 and value73 then
					extendUINew.rebuildelm(value2, value)

					local texforCUS
					local texforCUS2

					if value71 then
						texforCUS = res.gettexforCUS(value7, value36)
					else
						local value75 = bzmir.diynpc .. value7 .. bzmir.prefix .. value36 .. bzmir.ext

						if string.byte(value7) == 35 then
							value75 = value7 .. bzmir.prefix .. value36 .. bzmir.ext
						end

						texforCUS = _gettex2(value75)
					end

					if value20 then
						if value71 then
							texforCUS2 = res.gettexforCUS(value7, value20)
						else
							local value76 = bzmir.diynpc .. value7 .. bzmir.prefix .. value20 .. bzmir.ext

							if string.byte(value7) == 35 then
								value76 = value7 .. bzmir.prefix .. value20 .. bzmir.ext
							end

							texforCUS2 = _gettex2(value76)
						end
					end

					if texforCUS then
						local value77 = string.byte("0")

						if value74 then
							value77 = string.byte(bzmir.prefix)
						end

						local label6 = cc.Label:createWithCharMap(texforCUS, value72, value73, value77):anchor(align2, aligny2):pos(posx2, posy2):add2(value, value3 or count):scale(value121 or 1)

						label6:setName(value2)

						if value74 then
							label6:setString(bzmir.prefix .. value37)
						else
							label6:setString(value37)
						end

						if texforCUS2 then
							local value78 = value2 .. "unit"

							extendUINew.rebuildelm(value78, value)

							local x3 = 0
							local value38 = 30 + value123

							if value122 then
								if align2 == 0.5 then
									x3 = posx2 - value38 - 3 - label6:getw() / 2
								elseif align2 == 1 then
									x3 = posx2 - value38 - 3 - label6:getw()
								else
									x3 = posx2 - value38 - 3
								end
							elseif align2 == 0.5 then
								x3 = posx2 + label6:getw() / 2 + 3
							elseif align2 == 1 then
								x3 = posx2 + 3
							else
								x3 = posx2 + label6:getw() + 3
							end

							display.newSprite(texforCUS2):anchor(0, aligny2):pos(x3, posy2):add2(value, value3 or count):scale(value124):setName(value78)
						end
					end
				end
			elseif value4 == "Layer" then
				width = width or display.width
				height = height or display.height

				local color3

				if color2.color then
					color3 = _stringToCorlor(color3)
				end

				extendUINew.rebuildelm(value2, value)

				local node2 = display.newNode():add2(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2):size(width, height)

				node2:setName(value2)

				if color3 then
					cc.LayerColor:create(color3):size(node2.w, node2.h):add2(node2)
				end
			elseif value4 == "Progress" then
				local number8 = tonumber(color2.offx) or 0
				local number9 = tonumber(color2.offy) or 0
				local value79 = color2.dir
				local value125 = color2.bg
				local value126 = color2.bar
				local number2 = tonumber(color2.step)
				local number3 = tonumber(color2.cur)
				local number4 = tonumber(color2.max)
				local value127 = color2.isV
				local progress = an.newProgress(res.gettex2(bzmir.diynpc .. value79 .. bzmir.prefix .. value126 .. bzmir.ext), res.gettex2(bzmir.diynpc .. value79 .. bzmir.prefix .. value125 .. bzmir.ext), {
					x = number8,
					y = number9
				}, value127)

				extendUINew.rebuildelm(value2, value)
				progress:add2(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2)
				progress:setName(value2)

				if number2 then
					progress:setp(number2)
				elseif number3 and number4 then
					local value39 = number3 / number4

					if value39 > 1 then
						value39 = 1
					end

					progress:setp(value39)
				end
			elseif value4 == "ProgressSpr" then
				if not tonumber(color2.offx) then
					local count6 = 0
				end

				if not tonumber(color2.offy) then
					local count7 = 0
				end

				local value40 = color2.dir
				local value128 = color2.bg
				local value129 = color2.bar
				local number5 = tonumber(color2.step)
				local number6 = tonumber(color2.cur)
				local number7 = tonumber(color2.max)
				local value80 = color2.isV
				local number10 = tonumber(color2.fps) or 0.1
				local items5 = value129:split(bzmir.mcmd)

				if #items5 ~= 2 then
					return
				end

				local number = _getani2(bzmir.diynpc .. value40 .. bzmir.prefix .. "%d.png", tonumber(items5[1]), tonumber(items5[2]), number10)
				local value15

				if number then
					number:retain()
					extendUINew.rebuildelm(value2, value)

					local value12 = _get2(bzmir.diynpc .. value40 .. bzmir.prefix .. items5[1] .. bzmir.ext):add2(value, value3 or count):anchor(align2, aligny2):pos(posx2, posy2)

					value12:setName(value2)

					if value12 then
						local w2 = value12:getw()
						local y3 = 0
						local count4 = 1
						local count5 = 0

						if value80 then
							count4, count5 = 0, 1
							w2, y3 = 0, 0
						end

						value15 = _get2(bzmir.diynpc .. value40 .. bzmir.prefix .. value128 .. bzmir.ext):anchor(count4, count5):pos(w2, y3):addto(value12, 2)

						value12.runForever(value12, cc.Animate:create(number))
					end
				end

				if value15 then
					local count2 = 0

					if number5 then
						count2 = number5
					elseif number6 and number7 then
						count2 = number6 / number7

						if count2 > 1 then
							count2 = 1
						end
					end

					local size = value15:getTexture():getContentSize()

					if value80 then
						value15:setTextureRect(cc.rect(0, 0, size.width, size.height * (1 - count2)))
					else
						value15:setTextureRect(cc.rect(size.width * (1 - count2), 0, size.width * count2, size.height))
					end
				end
			elseif value4 == "C9Sprite" then
				local value130 = color2.dir
				local value131 = color2.bg

				extendUINew.rebuildelm(value2, value)
				display.newScale9Sprite(res.getframe2(bzmir.diynpc .. value130 .. bzmir.prefix .. value131 .. bzmir.ext)):size(width, height):pos(posx2, posy2):anchor(align2, aligny2):add2(value, value3 or count):setName(value2)
			end
		elseif value17 == "0" then
			local value132, value133 = extendUINew.checkType(value16)
			local value9 = color2.x or 0
			local value21 = color2.y or 0

			if value21 and path.pointWith == 0 then
				value21 = path.mainBgh - value21
			end

			if value9 and path.highPixels then
				value9 = _posWithCenter(value9)
			end

			value9 = value9 and value9 + path.x_offset

			local value134 = extendUINew.genname(value132, value133, value9, value21, path.mainName)

			extendUINew.rebuildelm(value134, path.content)
		elseif value17 == "2" then
			local value135, value136 = extendUINew.checkType(value16)
			local value137 = color2.hidden
			local value10 = color2.x or 0
			local value22 = color2.y or 0

			if not color2.width then
				local number13 = 100
			end

			if not color2.height then
				local number14 = 100
			end

			if value22 and path.pointWith == 0 then
				value22 = path.mainBgh - value22
			end

			if value10 and path.highPixels then
				value10 = _posWithCenter(value10)
			end

			value10 = value10 and value10 + path.x_offset

			local value138 = extendUINew.genname(value135, value136, value10, value22, path.mainName)
			local node4 = extendUINew.getChild(value138, path.content)

			if node4 then
				if value137 == 1 then
					node4:setVisible(false)
				else
					node4:setVisible(true)
				end
			end
		elseif value17 == "ScrollTo" then
			local value139, value140 = extendUINew.checkType(parts[1])
			local value141 = color2.x or 0
			local value142 = color2.y or 0
			local value143 = extendUINew.genname(value139, value140, nil, nil, path.mainName)
			local child = extendUINew.getChild(value143, path.content)

			if child and child.scrollView then
				child.scrollView:scrollTo(value141, value142)
			end
		end
	end
end

function extendUINew:checkType()
	local parts = string.split(self, "-")

	return parts[1], parts[2]
end

function extendUINew:callCMD2(value)
	if g_data.client:checkLastTime("npc_cm", 0.1) then
		g_data.client:setLastTime("npc_cm", true)

		if self:find("EXT_") ~= nil then
			def.role.sendCM(self, def.role.helperID)
		else
			def.role.sendCM(self, value)
		end
	else
		main_scene.ui:tip("点击过快")
	end
end

function extendUINew:genpicpath()
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

function extendUINew:genname(value, text2, text3, value2)
	if value then
		return value2 .. self .. value
	else
		return value2 .. self .. "-" .. tostring(text2) .. "-" .. tostring(text3)
	end
end

function extendUINew:getChild(value)
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

function extendUINew:rebuildelm(value)
	local node = extendUINew.getChild(self, value)

	if node then
		node:setVisible(false)
		node:removeSelf()

		local value2
	end
end

return extendUINew
