local cc2 = require("mir2.cc")
local item = import("..common.item")
local items = {
	extend = function(value, value2, value3)
		local extendUI = require("mir2.scenes.main.common.extendUI")
		local extendUINew = require("mir2.scenes.main.common.extendUINew")

		value.timer = nil
		value.callTime = 1
		value.itemBoxs = {}
		value.isLoaded = false

		function value:hidePanel()
			if value3.hidePanel then
				value3:hidePanel(value2)
			end

			if self.timer then
				def.role.cancelAutoRun(self.timer)

				self.timer = nil
			end
		end

		function value:setFocus()
			if not main_scene.ui.isChoseItem then
				if value3.lastFocus then
					value3.lastFocus:setLocalZOrder(0)
				end

				value3.lastFocus = self

				self.setLocalZOrder(self, value3.z.focus)
			else
				self.setLocalZOrder(self, 0)
			end
		end

		function value:checkInPanel(value)
			local point = self.convertToWorldSpace(self, cc.p(0, 0))

			for _, touchFrame in pairs(self._touchFrames) do
				local size = touchFrame.rect

				if cc.rectContainsPoint(cc.rect(point.x + size.x * self.getScale(self), point.y + size.y * self.getScale(self), size.width * self.getScale(self), size.height * self.getScale(self)), value) then
					return true
				end
			end
		end

		function value:addTouchFrame(mask1, sender, event)
			self.removeTouchFrame(self, sender)

			local items2 = {
				rect = mask1
			}

			if not event then
				items2.mask1 = display.newNode():pos(mask1.x, mask1.y):size(mask1.width, mask1.height):addto(self, -999999999)

				items2.mask1:setTouchEnabled(true)
				items2.mask1:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(beganTouchPos)
					if not self._supportMove then
						return
					end

					if beganTouchPos.name == "began" then
						items2.beganPos = cc.p(self:getPosition())
						items2.beganTouchPos = cc.p(beganTouchPos.x, beganTouchPos.y)

						return true
					end

					if (beganTouchPos.name == "moved" or beganTouchPos.name == "ended") and items2.beganPos and items2.beganTouchPos then
						self:pos(beganTouchPos.x - items2.beganTouchPos.x + items2.beganPos.x, beganTouchPos.y - items2.beganTouchPos.y + items2.beganPos.y)
					end
				end)

				items2.mask2 = display.newNode():pos(mask1.x, mask1.y):size(mask1.width, mask1.height):addto(self, 999999999)

				items2.mask2:setTouchEnabled(true)
				items2.mask2:setTouchSwallowEnabled(false)
				items2.mask2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(nameOwner)
					if nameOwner.name == "began" then
						self:setFocus()

						return true
					end
				end)
			end

			self._touchFrames[sender] = items2
		end

		function value:removeTouchFrame(event)
			if self._touchFrames[event] then
				if self._touchFrames[event].mask1 then
					self._touchFrames[event].mask1:removeSelf()
				end

				if self._touchFrames[event].mask2 then
					self._touchFrames[event].mask2:removeSelf()
				end

				self._touchFrames[event] = nil
			end
		end

		function value:load(path)
			local enabled = false
			local enabled2 = false

			if path then
				local number = 5
				local enabled3 = false

				for _, item2 in ipairs(path) do
					local parts = string.split(item2, ":")
					local value = parts[1]

					if value == "CUSUI" then
						enabled2 = true
					elseif value == "CM" then
						self.cm_clientToServer = parts[2]
					elseif value == "Bg" then
						local value2
						local value3
						local value4
						local value5
						local value6
						local x
						local y
						local value7
						local value8

						if enabled2 then
							local string = loadstring("return {" .. parts[2] .. "}")

							if not string then
								break
							end

							local value9, point = pcall(string)

							if not value9 or not point then
								break
							end

							value2 = point.dir
							value3 = point.pic
							value4 = point.anchor or "left"
							value5 = point.pointWith or 0
							x = point.x or display.cx
							y = point.y or display.cy
							value6 = point.selfAlign or "center"
							value7 = point.nomove or 0
							value8 = point.full
						else
							value2 = parts[2]
							value3 = parts[3]
							value4 = parts[4] or "center"
							value5 = tonumber(parts[5]) or 0
							value6 = parts[8] or "center"
							x = tonumber(parts[6]) or display.cx
							y = tonumber(parts[7]) or display.cy
							value7 = tonumber(parts[9]) or 0
						end

						local value10 = bzmir.diynpc .. value2 .. bzmir.prefix .. value3 .. bzmir.ext

						if string.byte(value2) == 35 then
							value10 = value2 .. bzmir.prefix .. value3 .. bzmir.ext
						end

						local number2 = 0.5
						local number3 = 0.5

						if value6 == "left" then
							number2 = 0
							number3 = 0
						elseif value6 == "topleft" then
							number2 = 0
							number3 = 1
						elseif value6 == "right" then
							number2 = 1
							number3 = 0
						end

						if value7 == 1 then
							self._supportMove = false
						end

						self.mainbg = _get2(value10)

						local w = self.mainbg:getw()
						local h = self.mainbg:geth()

						if value8 then
							w, h = display.width, display.height
						end

						self:anchor(number2, number3):pos(x, y):size(cc.size(w, h))
						self:setNodeEventEnabled(true)
						self.mainbg:anchor(0, 0):pos(0, 0):add2(self)

						self.mainBgh = self.mainbg:geth()

						if enabled2 then
							self.extUIParams = extendUINew.init(self, "dtppanel_ext", nil, value4, value5)
						else
							self.extUIParams = extendUI.init(self, "dtppanel_ext", nil, value4, value5)
						end
					elseif value == "DBg" then
						local value11
						local value12
						local value13
						local value14
						local value15
						local value16
						local value17
						local x2
						local y2
						local value18
						local height
						local size
						local value19

						if enabled2 then
							local string2 = loadstring("return {" .. parts[2] .. "}")

							if not string2 then
								break
							end

							local value20
							local value21, value22 = pcall(string2)

							size = value22

							if not value21 or not size then
								break
							end

							value11 = size.dir
							value12 = size.pic
							value13 = size.scale or 1
							value14 = size.anchor or "left"
							value15 = size.pointWith or 0
							x2 = size.x or display.cx
							y2 = size.y or display.cy
							value16 = size.selfAlign or "center"
							value17 = size.nomove or 0
							value19 = size.full
						else
							value11 = parts[2]
							value12 = parts[3]
							value13 = tonumber(parts[4])
							value14 = parts[5] or "center"
							value15 = tonumber(parts[6]) or 0
							value16 = parts[9] or "center"
							value17 = tonumber(parts[12]) or 0
							x2 = tonumber(parts[7]) or display.cx
							y2 = tonumber(parts[8]) or display.cy
						end

						local number4 = 0.5
						local number5 = 0.5

						if value16 == "left" then
							number4 = 0
							number5 = 0
						elseif value16 == "topleft" then
							number4 = 0
							number5 = 1
						elseif value16 == "right" then
							number4 = 1
							number5 = 0
						end

						if value17 == 1 then
							self._supportMove = false
						end

						self.mainbg = display.newSprite(res.gettexforCUS(value11, value12))

						if enabled2 then
							value18 = size.width or self.mainbg:getw()
							height = size.height or self.mainbg:geth()
						else
							value18 = tonumber(parts[10]) or self.mainbg:getw()
							height = tonumber(parts[11]) or self.mainbg:geth()
						end

						if value19 then
							value18, height = display.width, display.height
						end

						self:anchor(number4, number5):pos(x2, y2):size(cc.size(value18 * value13, height * value13))
						self:setNodeEventEnabled(true)
						self.mainbg:scale(value13):anchor(0, 0):pos(0, 0):add2(self)

						self.mainBgh = self:geth()

						if enabled2 then
							self.extUIParams = extendUINew.init(self, "dtppanel_ext", nil, value14, value15)
						else
							self.extUIParams = extendUI.init(self, "dtppanel_ext", nil, value14, value15)
						end
					elseif value == "DExit" then
						local value23
						local value24
						local value25
						local value26
						local x3
						local y3

						if enabled2 then
							local string3 = loadstring("return {" .. parts[2] .. "}")

							if not string3 then
								break
							end

							local value27, point2 = pcall(string3)

							if not value27 or not point2 then
								break
							end

							value23 = point2.dir
							value24 = point2.pic
							value25 = point2.scale or 1
							x3 = point2.x or self:getw() - 9
							y3 = point2.y or self:geth() - 8
							value26 = point2.pressPic
						else
							value23 = parts[2]
							value24 = parts[3]
							value25 = tonumber(parts[4])
							value26 = parts[5]
							x3 = tonumber(parts[6]) or self:getw() - 9
							y3 = tonumber(parts[7]) or self:geth() - 8
						end

						local count = 0
						local count2 = 0

						if self.extUIParams then
							if self.extUIParams.align == "left" then
								count = 0
								count2 = 0
							elseif self.extUIParams.align == "topleft" then
								count = 0
								count2 = 1
							elseif self.extUIParams.align == "right" then
								count = 1
								count2 = 0
							elseif self.extUIParams.align == "center" then
								count = 0.5
								count2 = 0.5
							end

							if self.extUIParams.pointWith == 0 then
								y3 = self.mainBgh - y3
							end
						end

						an.newBtn(res.gettexforCUS(value23, value24), function()
							sound.playSound("103")
							self:hidePanel()
						end, {
							pressImage = res.gettexforCUS(value23, value26)
						}):anchor(count, count2):pos(x3, y3):addto(self, 9999):scale(value25)
					elseif value == "Exit" then
						local value28
						local value29
						local value30
						local x4
						local y4

						if enabled2 then
							local string4 = loadstring("return {" .. parts[2] .. "}")

							if not string4 then
								break
							end

							local value31, point3 = pcall(string4)

							if not value31 or not point3 then
								break
							end

							value28 = point3.dir
							value29 = point3.pic
							value30 = point3.pressPic
							x4 = point3.x or self:getw() - 9
							y4 = point3.y or self:geth() - 8
						else
							value28 = parts[2]
							value29 = parts[3]
							value30 = parts[4]
							x4 = tonumber(parts[5]) or self:getw() - 9
							y4 = tonumber(parts[6]) or self:geth() - 8
						end

						local value32 = bzmir.diynpc .. value28 .. bzmir.prefix .. value29 .. bzmir.ext
						local value33 = bzmir.diynpc .. value28 .. bzmir.prefix .. value30 .. bzmir.ext

						if string.byte(value28) == 35 then
							value32 = value28 .. bzmir.prefix .. value29 .. bzmir.ext
							value33 = value28 .. bzmir.prefix .. value30 .. bzmir.ext
						end

						local count3 = 0
						local count4 = 0

						if self.extUIParams then
							if self.extUIParams.align == "left" then
								count3 = 0
								count4 = 0
							elseif self.extUIParams.align == "topleft" then
								count3 = 0
								count4 = 1
							elseif self.extUIParams.align == "right" then
								count3 = 1
								count4 = 0
							elseif self.extUIParams.align == "center" then
								count3 = 0.5
								count4 = 0.5
							end

							if self.extUIParams.pointWith == 0 then
								y4 = self.mainBgh - y4
							end
						end

						an.newBtn(_gettex2(value32), function()
							sound.playSound("103")
							self:hidePanel()
						end, {
							pressImage = _gettex2(value33)
						}):anchor(count3, count4):pos(x4, y4):addto(self, 9999)
					elseif value == "Move" then
						local number6 = tonumber(parts[2])
						local number7 = tonumber(parts[3])
						local number8 = tonumber(parts[4]) or 0.2

						self:stopAllActions()
						self:moveTo(number8, number6, number7)
					elseif value == "AutoHide" then
						number = tonumber(parts[2])
						enabled3 = true
					elseif enabled2 then
						extendUINew.load(item2, self.extUIParams)
					else
						extendUI.load(item2, self.extUIParams)
					end

					if item2:find("PUTBOX") ~= nil then
						enabled = true
					end
				end

				if enabled3 then
					value.timer = def.role.autoRun(function()
						if main_scene and main_scene.ui and value and value.hidePanel then
							value:hidePanel()
						end
					end, number)
				end

				if enabled then
					self:showBag()
				end
			end
		end

		function value:show(data)
			if not data then
				return
			end

			def.role.cancelAutoRun(self.timer)

			local value

			if data.noFile then
				value = data.content
			else
				local config = def.role.getConfig(data)

				if config then
					value = config.panel
				end
			end

			self:load(value)

			if self.cm_clientToServer then
				def.role.call(self.cm_clientToServer)
			end
		end

		function value:refresh(data)
			local parts = string.split(data, "|")
			local enabled = false
			local enabled2 = false

			for _, item2 in ipairs(parts) do
				if item2 == "CUSUI" then
					enabled2 = true
				elseif enabled2 then
					extendUINew.load(item2, self.extUIParams)
				else
					extendUI.load(item2, self.extUIParams)
				end

				if item2:find("PUTBOX") ~= nil then
					enabled = true
				end
			end

			if enabled then
				self:showBag()
			end
		end

		function value:addItem(item2, boxLayer)
			if not item2 or not boxLayer then
				return
			end

			self:delItem(boxLayer)

			local itemData = item2.data

			if not itemData then
				return
			end

			g_data.bag:delItem(itemData:get("makeIndex"))

			g_data.bag.inBox[itemData:get("makeIndex")] = true

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:delItem(itemData:get("makeIndex"))
			end

			boxLayer.itemData = itemData
			boxLayer.item = item.new(itemData, self, {
				showbg = false,
				showEffect = true
			}):pos(boxLayer:getw() / 2, boxLayer:geth() / 2):anchor(0.5, 0.5):scale(1.2):add2(boxLayer)
			boxLayer.item.boxLayer = boxLayer

			local value = itemData:get("makeIndex")

			if boxLayer.putItemCmd then
				local itemDiff = def.ccy.getItemDiff(itemData)

				def.role.sendCM(bzmir.mcmd .. boxLayer.putItemCmd .. bzmir.cmdcnt .. itemData.getVar("name") .. bzmir.cmdcnt .. tostring(itemData:get("makeIndex")) .. bzmir.cmdcnt .. itemDiff)
			end
		end

		function value:delItem(makeIndex)
			if makeIndex.item then
				makeIndex.item:removeSelf()

				makeIndex.item = nil
			end

			if makeIndex.itemData then
				g_data.bag:addItem(makeIndex.itemData, true)

				g_data.bag.inBox[makeIndex.itemData:get("makeIndex")] = false

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(makeIndex.itemData:get("makeIndex"))
				end

				makeIndex.itemData = nil
			end
		end

		function value:putItem(item2, x, y)
			if putitem then
				return putitem(self, item2, x, y)
			end
		end

		function value:onCleanup()
			if self.timer then
				def.role.cancelAutoRun(self.timer)

				self.timer = nil
			end

			for _, itemBox in pairs(self.itemBoxs) do
				self:delItem(itemBox)
			end
		end

		function value:showBag(data, options)
			if not data then
				data, options = display.cx + 100, display.cy

				if self.extUIParams then
					if self.extUIParams.align == "left" then
						data = self:getw() + self:getPositionX() + 10
						options = self:getPositionY() * 2
					elseif self.extUIParams.align == "topleft" then
						data = self:getw() + self:getPositionX() + 10
						options = self:getPositionY()
					elseif self.extUIParams.align == "right" then
						data = self:getPositionX() + 10
						options = self:getPositionY() * 2
					else
						data = self:getPositionX() + self:getw() / 2 + 10
						options = self:getPositionY() + self:geth() / 2
					end
				end
			end

			if main_scene.ui.panels then
				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:pos(data, options)
				else
					main_scene.ui:togglePanel("bag")
					main_scene.ui.panels.bag:pos(data, options)
				end
			end
		end

		value._touchFrames = {}

		local rect = value._mainRect or cc.rect(0, 0, value.getw(value), value.geth(value))

		value.addTouchFrame(value, rect, "main")

		return value
	end
}
local panelFactory = class("panelFactory")

function panelFactory:ctor(...)
	return
end

function panelFactory:togglePanel(value, value2)
	if main_scene.ui.panels[value] and main_scene.ui.panels[value].hidePanel then
		main_scene.ui.panels[value]:hidePanel()
	else
		self:showPanel(value, value2)
	end
end

function panelFactory:createPanel(value, value2)
	if main_scene.ui.panels[value] and main_scene.ui.panels[value].hidePanel then
		main_scene.ui.panels[value]:hidePanel()
	end

	self:showPanel(value, value2)
end

function panelFactory:showPanel(panelName, options, options2)
	local lastFocus = display.newNode()

	items.extend(lastFocus, panelName, main_scene.ui)

	if options.cannotMove or options2 then
		lastFocus._supportMove = false
	else
		lastFocus._supportMove = true
	end

	lastFocus.__cname = "customPanel"

	lastFocus:addTo(main_scene.ui, main_scene.ui.z.focus)
	lastFocus:show(options)

	local rect = cc.rect(0, 0, lastFocus:getw(), lastFocus:geth())

	lastFocus:addTouchFrame(rect, panelName)

	if not main_scene.ui.isChoseItem then
		if main_scene.ui.lastFocus then
			main_scene.ui.lastFocus:setLocalZOrder(0)
		end

		main_scene.ui.lastFocus = lastFocus
	else
		lastFocus:setLocalZOrder(0)
	end

	lastFocus.__panelName = panelName
	main_scene.ui.panels[panelName] = lastFocus

	return lastFocus
end

return panelFactory
