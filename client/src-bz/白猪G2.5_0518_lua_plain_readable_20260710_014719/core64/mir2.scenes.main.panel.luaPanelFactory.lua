local cc2 = require("mir2.cc")
local item = import("..common.item")
local items = {
	extend = function(value, value2, value3)
		function value:hidePanel()
			if value3.darkLayer then
				value3.darkLayer:removeSelf()

				value3.darkLayer = nil
			end

			if value3.hidePanel then
				value3:hidePanel(value2)
			end
		end

		function value:call(value)
			def.role.call("@" .. value)
		end

		function value:active(runningPanel)
			if runningPanel then
				self.runningPanel = runningPanel
			end

			self.player = g_data.player
		end

		function value:processMsg(message, options)
			if self.runningPanel and self.runningPanel.processMsg then
				self.runningPanel:processMsg(message, options)
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

					if beganTouchPos.name == "moved" or beganTouchPos.name == "ended" then
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

		function value:show(data)
			if not data then
				return
			end

			local value = device.writablePath .. "res/lua/"

			if not io.exists(value) then
				ycFunction:mkdir(value)
			end

			if io.exists(value .. data .. ".lua") then
				local file, file2 = loadfile(value .. data .. ".lua")

				if not file then
					an.newMsgbox("加载失败: " .. file2, nil, {
						center = true
					})

					return
				end

				local value2, value3 = pcall(function()
					return file()
				end)

				if not value2 then
					an.newMsgbox("加载程序失败: " .. file2, nil, {
						center = true
					})

					return
				end

				if value3.ctor then
					local value4, value5 = pcall(function()
						return value3.new(self)
					end)

					if not value4 then
						an.newMsgbox("构造函数执行失败: " .. value5, nil, {
							center = true
						})

						return
					end
				else
					an.newMsgbox("构造函数不存在", nil, {
						center = true
					})
				end
			end
		end

		function value:findRole(value)
			return main_scene.ground.map:findRole(value)
		end

		function value:getAbil(value)
			return self.player.ability:get(value) or self.player.ability2:get(value) or self.player.ability3:get(value)
		end

		function value:getItem(makeIndex)
			return g_data.bag:getItem(makeIndex)
		end

		value._touchFrames = {}

		local rect = value._mainRect or cc.rect(0, 0, value.getw(value), value.geth(value))

		value.addTouchFrame(value, rect, "main")

		return value
	end
}
local luaPanelFactory = class("luaPanelFactory")

function luaPanelFactory:ctor(...)
	return
end

function luaPanelFactory:togglePanel(value, value2)
	if main_scene.ui.panels[value] and main_scene.ui.panels[value].hidePanel then
		main_scene.ui.panels[value]:hidePanel()
	else
		self:showPanel("luaCustomPanel", value2)
	end
end

function luaPanelFactory:createPanel(value, value2)
	if main_scene.ui.panels[value] and main_scene.ui.panels[value].hidePanel then
		main_scene.ui.panels[value]:hidePanel()
	end

	self:showPanel(value, value2)
end

function luaPanelFactory:showPanel(panelName, options, options2)
	local lastFocus = display.newNode()

	lastFocus:size(display.width, display.height)

	lastFocus.darkLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100)):add2(lastFocus)

	lastFocus.darkLayer:setContentSize(lastFocus:getContentSize())
	items.extend(lastFocus, panelName, main_scene.ui)

	lastFocus._supportMove = false
	lastFocus.__cname = "luaCustomPanel"

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

return luaPanelFactory
