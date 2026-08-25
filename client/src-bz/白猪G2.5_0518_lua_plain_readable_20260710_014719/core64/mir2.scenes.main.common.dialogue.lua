local dialogue = {}
local itemInfo = require("mir2.scenes.main.common.itemInfo")

function dialogue:design()
	local label2 = an.newLabel("-", 18, 1, {
		color = cc.c3b(0, 255, 127)
	}):anchor(0.5, 0):pos(0, -10):addto(self, 99)

	label2:setScaleX(display.width * 2)
	label2:setScaleY(0.8)

	local label3 = an.newLabel("|", 18, 1, {
		color = cc.c3b(0, 255, 127)
	}):anchor(0, 0.5):pos(0, 0):addto(self, 99)

	label3:setScaleX(0.8)
	label3:setScaleY(display.height * 2)

	local label4 = an.newLabel("", 18, 1):anchor(0, 1):pos(0, 0):addto(self, 99)
	local label5 = an.newLabel("", 18, 1):anchor(0, 0):pos(0, 0):addto(self, 99)
	local value_2 = res.get2("pic/debug/icon.png"):anchor(1, 1):pos(self:getw(), self:geth() - 22):addto(self, 5)

	value_2:setTouchEnabled(true)
	value_2:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(point)
		local value3 = math.abs(self:getw() - display.width) / 2
		local value4 = math.abs(self:geth() - display.height) / 2

		if point.name == "began" then
			-- block empty
		elseif point.name == "moved" then
			local value = point.x - value3
			local value2 = point.y - value4

			if value > self:getw() then
				value = self:getw()
			end

			if value2 > self:geth() then
				value2 = self:geth()
			end

			if value < 0 then
				value = 0
			end

			if value2 < 0 then
				value2 = 0
			end

			label4:setPosition(value - 80, value2)
			label5:setPosition(value + 2, value2 + 30)
			label4:setString(string.format("X %d", value))
			label5:setString(string.format("Y %d", value2))
			label2:setPositionX(value)
			label2:setPositionY(value2 - 10)
			label3:setPositionX(value - 2)
			label3:setPositionY(value2)
		end

		return true
	end)
end

function dialogue:createSprite(text2, value6, value2, merchantOwner, show)
	local string2 = loadstring("return {" .. value6 .. "}")()

	if value2 == "slider" then
		if not self.scroll["slider_" .. tostring(string2.id)] then
			if string2.showBG then
				display.newColorLayer(cc.c4b(0, 0, 0, 128)):pos(0, 0):size(tonumber(string2.w) or 0, tonumber(string2.h) or 0):add2(text2):pos(tonumber(string2.x) or 0, tonumber(string2.y) or 0)
			end

			self.scroll["slider_" .. tostring(string2.id)] = an.newScroll(0, 0, tonumber(string2.w) or 0, tonumber(string2.h) or 0, {
				dir = tonumber(string2.dir) or 1
			}):addto(text2):pos(tonumber(string2.x) or 0, tonumber(string2.y) or 0)
		end

		return
	end

	if string2.onSlider then
		text2 = self.scroll["slider_" .. tostring(string2.onSlider)]
	end

	local node = display.newNode():addTo(text2)
	local label2 = an.newLabelM(500, 16, 1)

	function getLooks(self3)
		for _3, item15 in ipairs(def.items) do
			if item15.getVar("name") == self3 then
				return item15.getVar("looks")
			end
		end

		return false
	end

	function callCMD(self4, value12)
		if g_data.client:checkLastTime("npc_cm", 0.1) then
			g_data.client:setLastTime("npc_cm", true)
			def.role.sendCM(self4, value12 or def.role.helperID)
		else
			main_scene.ui:tip("点击过快")
		end
	end

	function getAnchor(self2)
		if type(self2) ~= "string" then
			return
		end

		if self2 == "leftTop" then
			return 0, 1
		elseif self2 == "rightTop" then
			return 1, 1
		elseif self2 == "leftBottom" then
			return 0, 0
		elseif self2 == "rightBottom" then
			return 1, 0
		elseif self2 == "center" then
			return 0.5, 0.5
		end

		return 0, 0
	end

	local value3 = string2.space or 58
	local x2 = string2.posx or text2:getw() / 2
	local y2 = string2.posy or text2:geth() / 2
	local value = string2.anchor or ""
	local items3 = {}

	function click(self5)
		for _4, item6 in ipairs(items3) do
			if item6 == self5 then
				item6:select()
			else
				item6:unselect()
			end
		end
	end

	for index, text in ipairs(string2) do
		if string2.rank then
			if string2.rank == "top" then
				y2 = (string2.posy or text2:geth() / 2) + (index - 1) * value3
			elseif string2.rank == "bottom" then
				y2 = (string2.posy or text2:geth() / 2) - (index - 1) * value3
			elseif string2.rank == "left" then
				x2 = (string2.posx or text2:getw() / 2) - (index - 1) * value3
			else
				x2 = (string2.posx or text2:getw() / 2) + (index - 1) * value3
			end
		end

		if value2 == "items" then
			local looks = getLooks(text)

			if not looks then
				return
			end

			local value5 = def.items.getItemIdByName[text]
			local value7 = value5 and def.items[value5] or nil
			local value4 = res.get("items", looks):addTo(node):anchor(getAnchor(value)):pos(x2, y2):scale(string2.scale or 1)

			value4:setTouchEnabled(true)
			value4:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(point)
				if point.name == "began" then
					return true
				elseif point.name == "ended" then
					itemInfo.show(value7, {
						x = point.x,
						y = point.y
					}, {
						onlyStdItem = true
					})
				end
			end)
			value4:setLocalZOrder(string2.zOrder or 1)
		end

		if value2 == "label" then
			local value8 = string2.size or 16
			local number

			if string.find(text, "/c=") then
				local parts7 = string.split(text, "/c=")[2]

				text = string.gsub(text, "/c=" .. parts7, "", 1)
				number = tonumber(parts7)
			end

			an.newLabel(text, value8, 1, {
				color = def.colors.get(tonumber(number or string2.color or 255))
			}):addTo(node):anchor(getAnchor(value)):pos(x2, y2):setLocalZOrder(string2.zOrder or 1)
		end

		if value2 == "text" then
			local value9 = string2.size or 16
			local value10 = string.find(text, "<")
			local value11 = string.find(text, ">")

			label2:setFSize(value9)
			label2:addTo(node):anchor(value == "" and 0, 1 or getAnchor(value)):pos(x2, y2)
			label2:setLocalZOrder(string2.zOrder or 1)

			if value10 and value11 then
				local parts43 = string.split(text, ">")

				for index2, item5 in ipairs(parts43) do
					if item5 ~= "" then
						local parts8 = string.split(item5, "<")[1] or ""
						local parts9 = string.split(item5, "<")[2] or ""

						col = string.split(parts9, "/c=")[2]

						local parts10 = string.split(parts9, "/c=")[1]

						if index2 == 1 then
							label2:nextLine():addLabel(parts8, def.colors.get(tonumber(string2.color or 255)))
							label2:addLabel(parts10, def.colors.get(tonumber(col or string2.color or 255)))
						else
							label2:addLabel(parts8, def.colors.get(tonumber(string2.color or 255)))
							label2:addLabel(parts10, def.colors.get(tonumber(col or string2.color or 255)))
						end
					end
				end
			else
				label2:nextLine():addLabel(text, def.colors.get(tonumber(string2.color or 255)))
			end
		end

		if value2 == "btn" then
			local items = {}
			local items2 = {}

			if string.find(string2.name, ":") then
				local parts44 = string.split(string2.name, ":")

				for _, item16 in ipairs(parts44) do
					items[#items + 1] = item16
				end

				local parts45 = string.split(string2.cmd, ":")

				for _2, item17 in ipairs(parts45) do
					items2[#items2 + 1] = item17
				end
			end

			if #items > 0 then
				items3[index] = an.newBtn(res.gettex2("pic/" .. string2.dir .. "/" .. text .. ".png"), function()
					sound.playSound("104")
					callCMD(bzmir.mcmd .. items2[index], merchantOwner.merchant)
				end, {
					pressBig = true,
					label = {
						items[index],
						16,
						1,
						{
							color = def.colors.get(tonumber(string2.color or 255))
						}
					},
					select = {
						res.gettex2("pic/common/toggle03.png"),
						manual = true
					}
				}):addTo(node):anchor(getAnchor(value)):pos(x2, y2):scale(string2.scale or 1)

				items3[index]:setLocalZOrder(string2.zOrder or 1)
			else
				items3[index] = an.newBtn(res.gettex2("pic/" .. string2.dir .. "/" .. text .. ".png"), function()
					sound.playSound("104")
					callCMD(bzmir.mcmd .. string2.cmd, merchantOwner.merchant)
				end, {
					pressBig = true,
					label = {
						string2.name,
						16,
						1,
						{
							color = def.colors.get(tonumber(string2.color or 255))
						}
					}
				}):addTo(node):anchor(getAnchor(value)):pos(x2, y2):scale(string2.scale or 1)

				items3[index]:setLocalZOrder(string2.zOrder or 1)
			end
		end

		if value2 == "image" then
			local btn
			local parts2
			local parts11
			local node3 = res.get2("pic/" .. string2.dir .. "/" .. text .. ".png"):addTo(node):anchor(getAnchor(value)):pos(x2, y2)

			node3:setScale(string2.scale or 1)
			node3:enableClick(function()
				if string2.text then
					show.show = not show.show

					show.bg:setVisible(show.show)
					show.labelM:clear()

					if string.find(string2.text, ":cmd:") then
						local parts15 = string.split(string2.text, ":cmd:")[2]

						string2.text = string.split(string2.text, ":cmd:")[1]
						parts2 = string.split(parts15, "@")[2]
						parts11 = string.split(parts15, "@")[1]
					end

					if string.find(string2.text, "\n") then
						local parts46 = string.split(string2.text, "\n")

						for _5, item in ipairs(parts46) do
							local value13 = string.find(item, "<")
							local value14 = string.find(item, ">")

							if value13 and value14 then
								local parts47 = string.split(item, ">")

								for index3, item7 in ipairs(parts47) do
									if item7 ~= "" then
										local parts16 = string.split(item7, "<")[1] or ""
										local parts17 = string.split(item7, "<")[2] or ""

										col = string.split(parts17, "/c=")[2]

										local parts18 = string.split(parts17, "/c=")[1]

										if index3 == 1 then
											show.labelM:nextLine():addLabel(parts16, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts18, def.colors.get(tonumber(col or string2.color or 255)))
										else
											show.labelM:addLabel(parts16, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts18, def.colors.get(tonumber(col or string2.color or 255)))
										end
									end
								end
							else
								show.labelM:nextLine():addLabel(item, def.colors.get(tonumber(255)))
							end
						end
					else
						local value15 = string.find(string2.text, "<")
						local value16 = string.find(string2.text, ">")

						if value15 and value16 then
							local parts48 = string.split(string2.text, ">")

							for index4, item8 in ipairs(parts48) do
								if item8 ~= "" then
									local parts19 = string.split(item8, "<")[1] or ""
									local parts20 = string.split(item8, "<")[2] or ""

									col = string.split(parts20, "/c=")[2]

									local parts21 = string.split(parts20, "/c=")[1]

									if index4 == 1 then
										show.labelM:nextLine():addLabel(parts19, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts21, def.colors.get(tonumber(col or string2.color or 255)))
									else
										show.labelM:addLabel(parts19, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts21, def.colors.get(tonumber(col or string2.color or 255)))
									end
								end
							end
						else
							show.labelM:nextLine():addLabel(string2.text, def.colors.get(tonumber(255)))
						end
					end

					if parts2 then
						btn = an.newBtn(res.gettex2("pic/common/btn90.png"), function()
							sound.playSound("104")
							callCMD(bzmir.mcmd .. parts2, merchantOwner.merchant)
						end, {
							pressBig = true,
							label = {
								parts11,
								16,
								1,
								{
									color = def.colors.get(tonumber(251))
								}
							}
						}):addTo(show.layer):anchor(0.5, 0):pos(0, 8)
					end

					if btn then
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn:geth())
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn:geth())
						show.bg:setPosition(node3:getPosition())
						show.labelM:setPositionY(btn:geth() + 18)
						btn:setPositionX(show.bg:getContentSize().width / 2)
					else
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:setPosition(node3:getPosition())
					end

					return
				elseif not string2.cmd then
					return
				end

				sound.playSound("103")
				callCMD(bzmir.mcmd .. string2.cmd, merchantOwner.merchant)
			end)
			node3:setLocalZOrder(string2.zOrder or 1)
		end

		if value2 == "spr" then
			local btn2
			local parts3
			local parts12
			local sprite = display.newSprite(res.gettex(string2.dir, text)):addTo(node):anchor(getAnchor(value)):pos(x2, y2):scale(string2.scale or 1)

			sprite:enableClick(function()
				if string2.text then
					show.show = not show.show

					show.bg:setVisible(show.show)
					show.labelM:clear()

					if string.find(string2.text, ":cmd:") then
						local parts22 = string.split(string2.text, ":cmd:")[2]

						string2.text = string.split(string2.text, ":cmd:")[1]
						parts3 = string.split(parts22, "@")[2]
						parts12 = string.split(parts22, "@")[1]
					end

					if string.find(string2.text, "\n") then
						local parts49 = string.split(string2.text, "\n")

						for _6, item2 in ipairs(parts49) do
							local value17 = string.find(item2, "<")
							local value18 = string.find(item2, ">")

							if value17 and value18 then
								local parts50 = string.split(item2, ">")

								for index5, item9 in ipairs(parts50) do
									if item9 ~= "" then
										local parts23 = string.split(item9, "<")[1] or ""
										local parts24 = string.split(item9, "<")[2] or ""

										col = string.split(parts24, "/c=")[2]

										local parts25 = string.split(parts24, "/c=")[1]

										if index5 == 1 then
											show.labelM:nextLine():addLabel(parts23, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts25, def.colors.get(tonumber(col or string2.color or 255)))
										else
											show.labelM:addLabel(parts23, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts25, def.colors.get(tonumber(col or string2.color or 255)))
										end
									end
								end
							else
								show.labelM:nextLine():addLabel(item2, def.colors.get(tonumber(255)))
							end
						end
					else
						local value19 = string.find(string2.text, "<")
						local value20 = string.find(string2.text, ">")

						if value19 and value20 then
							local parts51 = string.split(string2.text, ">")

							for index6, item10 in ipairs(parts51) do
								if item10 ~= "" then
									local parts26 = string.split(item10, "<")[1] or ""
									local parts27 = string.split(item10, "<")[2] or ""

									col = string.split(parts27, "/c=")[2]

									local parts28 = string.split(parts27, "/c=")[1]

									if index6 == 1 then
										show.labelM:nextLine():addLabel(parts26, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts28, def.colors.get(tonumber(col or string2.color or 255)))
									else
										show.labelM:addLabel(parts26, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts28, def.colors.get(tonumber(col or string2.color or 255)))
									end
								end
							end
						else
							show.labelM:nextLine():addLabel(string2.text, def.colors.get(tonumber(255)))
						end
					end

					if parts3 then
						btn2 = an.newBtn(res.gettex2("pic/common/btn90.png"), function()
							sound.playSound("104")
							callCMD(bzmir.mcmd .. parts3, merchantOwner.merchant)
						end, {
							pressBig = true,
							label = {
								parts12,
								16,
								1,
								{
									color = def.colors.get(tonumber(251))
								}
							}
						}):addTo(show.layer):anchor(0.5, 0):pos(0, 8)
					end

					if btn2 then
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn2:geth())
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn2:geth())
						show.bg:setPosition(sprite:getPosition())
						show.labelM:setPositionY(btn2:geth() + 18)
						btn2:setPositionX(show.bg:getContentSize().width / 2)
					else
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:setPosition(sprite:getPosition())
					end

					return
				elseif not string2.cmd then
					return
				end

				sound.playSound("103")
				callCMD(bzmir.mcmd .. string2.cmd, merchantOwner.merchant)
			end)
			sprite:setLocalZOrder(string2.zOrder or 1)
		end

		if value2 == "ani" then
			local btn3
			local parts4
			local parts13
			local parts = string.split(text, ":")
			local ani2 = res.getani2("pic/" .. string2.dir .. "/%d.png", parts[1], parts[2], parts[3])

			ani2:retain()

			local node2 = res.get2("pic/" .. string2.dir .. "/" .. parts[1] .. ".png")

			node2:runForever(cc.Animate:create(ani2))
			node2:addTo(node):anchor(getAnchor(value)):pos(x2, y2)
			node2:setScale(string2.scale or 1)
			node2:enableClick(function()
				if string2.text then
					show.show = not show.show

					show.bg:setVisible(show.show)
					show.labelM:clear()

					if string.find(string2.text, ":cmd:") then
						local parts29 = string.split(string2.text, ":cmd:")[2]

						string2.text = string.split(string2.text, ":cmd:")[1]
						parts4 = string.split(parts29, "@")[2]
						parts13 = string.split(parts29, "@")[1]
					end

					if string.find(string2.text, "\n") then
						local parts52 = string.split(string2.text, "\n")

						for _7, item3 in ipairs(parts52) do
							local value21 = string.find(item3, "<")
							local value22 = string.find(item3, ">")

							if value21 and value22 then
								local parts53 = string.split(item3, ">")

								for index7, item11 in ipairs(parts53) do
									if item11 ~= "" then
										local parts30 = string.split(item11, "<")[1] or ""
										local parts31 = string.split(item11, "<")[2] or ""

										col = string.split(parts31, "/c=")[2]

										local parts32 = string.split(parts31, "/c=")[1]

										if index7 == 1 then
											show.labelM:nextLine():addLabel(parts30, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts32, def.colors.get(tonumber(col or string2.color or 255)))
										else
											show.labelM:addLabel(parts30, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts32, def.colors.get(tonumber(col or string2.color or 255)))
										end
									end
								end
							else
								show.labelM:nextLine():addLabel(item3, def.colors.get(tonumber(255)))
							end
						end
					else
						local value23 = string.find(string2.text, "<")
						local value24 = string.find(string2.text, ">")

						if value23 and value24 then
							local parts54 = string.split(string2.text, ">")

							for index8, item12 in ipairs(parts54) do
								if item12 ~= "" then
									local parts33 = string.split(item12, "<")[1] or ""
									local parts34 = string.split(item12, "<")[2] or ""

									col = string.split(parts34, "/c=")[2]

									local parts35 = string.split(parts34, "/c=")[1]

									if index8 == 1 then
										show.labelM:nextLine():addLabel(parts33, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts35, def.colors.get(tonumber(col or string2.color or 255)))
									else
										show.labelM:addLabel(parts33, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts35, def.colors.get(tonumber(col or string2.color or 255)))
									end
								end
							end
						else
							show.labelM:nextLine():addLabel(string2.text, def.colors.get(tonumber(255)))
						end
					end

					if parts4 then
						btn3 = an.newBtn(res.gettex2("pic/common/btn90.png"), function()
							sound.playSound("104")
							callCMD(bzmir.mcmd .. parts4, merchantOwner.merchant)
						end, {
							pressBig = true,
							label = {
								parts13,
								16,
								1,
								{
									color = def.colors.get(tonumber(251))
								}
							}
						}):addTo(show.layer):anchor(0.5, 0):pos(0, 8)
					end

					if btn3 then
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn3:geth())
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn3:geth())
						show.bg:setPosition(node2:getPosition())
						show.labelM:setPositionY(btn3:geth() + 18)
						btn3:setPositionX(show.bg:getContentSize().width / 2)
					else
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:setPosition(node2:getPosition())
					end

					return
				elseif not string2.cmd then
					return
				end

				sound.playSound("103")
				callCMD(bzmir.mcmd .. string2.cmd, merchantOwner.merchant)
			end)
			node2:setLocalZOrder(string2.zOrder or 1)
		end

		if value2 == "sprAni" then
			local btn4
			local parts5
			local parts14
			local parts6 = string.split(text, ":")
			local node4 = m2spr.playAnimation(string2.dir, parts6[1], parts6[2], parts6[3], false, false, false):addTo(node):anchor(getAnchor(value)):pos(x2, y2)

			node4:setScale(string2.scale or 1)
			node4:enableClick(function()
				if string2.text then
					show.show = not show.show

					show.bg:setVisible(show.show)
					show.labelM:clear()

					if string.find(string2.text, ":cmd:") then
						local parts36 = string.split(string2.text, ":cmd:")[2]

						string2.text = string.split(string2.text, ":cmd:")[1]
						parts5 = string.split(parts36, "@")[2]
						parts14 = string.split(parts36, "@")[1]
					end

					if string.find(string2.text, "\n") then
						local parts55 = string.split(string2.text, "\n")

						for _8, item4 in ipairs(parts55) do
							local value25 = string.find(item4, "<")
							local value26 = string.find(item4, ">")

							if value25 and value26 then
								local parts56 = string.split(item4, ">")

								for index9, item13 in ipairs(parts56) do
									if item13 ~= "" then
										local parts37 = string.split(item13, "<")[1] or ""
										local parts38 = string.split(item13, "<")[2] or ""

										col = string.split(parts38, "/c=")[2]

										local parts39 = string.split(parts38, "/c=")[1]

										if index9 == 1 then
											show.labelM:nextLine():addLabel(parts37, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts39, def.colors.get(tonumber(col or string2.color or 255)))
										else
											show.labelM:addLabel(parts37, def.colors.get(tonumber(string2.color or 255)))
											show.labelM:addLabel(parts39, def.colors.get(tonumber(col or string2.color or 255)))
										end
									end
								end
							else
								show.labelM:nextLine():addLabel(item4, def.colors.get(tonumber(255)))
							end
						end
					else
						local value27 = string.find(string2.text, "<")
						local value28 = string.find(string2.text, ">")

						if value27 and value28 then
							local parts57 = string.split(string2.text, ">")

							for index10, item14 in ipairs(parts57) do
								if item14 ~= "" then
									local parts40 = string.split(item14, "<")[1] or ""
									local parts41 = string.split(item14, "<")[2] or ""

									col = string.split(parts41, "/c=")[2]

									local parts42 = string.split(parts41, "/c=")[1]

									if index10 == 1 then
										show.labelM:nextLine():addLabel(parts40, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts42, def.colors.get(tonumber(col or string2.color or 255)))
									else
										show.labelM:addLabel(parts40, def.colors.get(tonumber(string2.color or 255)))
										show.labelM:addLabel(parts42, def.colors.get(tonumber(col or string2.color or 255)))
									end
								end
							end
						else
							show.labelM:nextLine():addLabel(string2.text, def.colors.get(tonumber(255)))
						end
					end

					if parts5 then
						btn4 = an.newBtn(res.gettex2("pic/common/btn90.png"), function()
							sound.playSound("104")
							callCMD(bzmir.mcmd .. parts5, merchantOwner.merchant)
						end, {
							pressBig = true,
							label = {
								parts14,
								16,
								1,
								{
									color = def.colors.get(tonumber(251))
								}
							}
						}):addTo(show.layer):anchor(0.5, 0):pos(0, 8)
					end

					if btn4 then
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn4:geth())
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 18 + btn4:geth())
						show.bg:setPosition(node4:getPosition())
						show.labelM:setPositionY(btn4:geth() + 18)
						btn4:setPositionX(show.bg:getContentSize().width / 2)
					else
						show.layer:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:size(show.labelM:getContentSize().width + 8, show.labelM:getContentSize().height + 8)
						show.bg:setPosition(node4:getPosition())
					end

					return
				elseif not string2.cmd then
					return
				end

				sound.playSound("103")
				callCMD(bzmir.mcmd .. string2.cmd, merchantOwner.merchant)
			end)
			node4:setLocalZOrder(string2.zOrder or 1)
		end
	end
end

return dialogue
