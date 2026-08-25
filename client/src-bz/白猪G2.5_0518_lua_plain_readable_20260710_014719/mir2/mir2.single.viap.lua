local value3 = ...
local iap2 = {
	assert = "断言",
	autoRat = "挂机",
	equip = "装备",
	net = "通讯",
	other = "其他",
	bag = "背包",
	error = "lua错误",
	res = "资源",
	login = "登录",
	normal = "普通"
}
local evt = {
	fps = function(value4)
		cc.Director:getInstance():setDisplayStats(value4)
	end,
	同屏人数 = function(value4)
		cc.Director:getInstance():getNotificationNode().screenNode:setVisible(value4)
	end,
	ping值 = function(value4)
		cc.Director:getInstance():getNotificationNode().pingNode:setVisible(value4)
	end
}

function p2(self, ...)
	print("_debug_", self or "normal", ...)
end

function d2(self, value4, value5, value6)
	dump("_debug_", self or "normal", value4, value5, value6)
end

function __G__TRACKBACK__(errorMessage)
	p2("error", "----------------------------------------")
	p2("error", "error: " .. tostring(errorMessage) .. "\n")
	p2("error", debug.traceback("", 2))
	p2("error", "----------------------------------------")
end

function hockprint(...)
	return
end

if def.bzm2debug then
	local value2
	local callback2 = dump

	function dump(self, value4, value5, value6, value7)
		if self == "_debug_" then
			value2 = value4 or "normal"

			callback2(value5, value6, value7)

			value2 = nil
		else
			callback2(self, value4, value5, 1)
		end
	end

	_print = print

	function print(self, value5, ...)
		local value4

		if type(self) == "string" and (self == "12222221" or self:find("attackLuck") ~= nil or self:find("not always") ~= nil) then
			return
		end

		if self == "_debug_" then
			local items2 = {
				...
			}

			for index = 1, select("#", ...) do
				local cnameOwner = select(index, ...)
				local value6 = type(cnameOwner)

				if value6 == "boolean" then
					items2[index] = cnameOwner and "true" or "false"
				elseif value6 == "userdata" then
					items2[index] = "userdata(" .. (cnameOwner.__cname or tolua.type(cnameOwner)) .. ")"
				elseif value6 ~= "string" and value6 ~= "number" then
					items2[index] = value6
				end
			end

			value4 = table.concat(items2, "   ")
		else
			local items = {
				self,
				value5,
				...
			}
			local value8 = select("#", ...) + 2

			if value8 == 2 and value5 == nil then
				value8 = self == nil and 0 or 1
			end

			for index2 = 1, value8 do
				local cnameOwner2 = items[index2]
				local value7 = type(cnameOwner2)

				if value7 == "boolean" then
					items[index2] = cnameOwner2 and "true" or "false"
				elseif value7 == "userdata" then
					items[index2] = "userdata(" .. (cnameOwner2.__cname or tolua.type(cnameOwner2)) .. ")"
				elseif value7 ~= "string" and value7 ~= "number" then
					items[index2] = value7
				end
			end

			value4 = table.concat(items, "   ")
			value5 = value2 or "other"
		end

		if m2debug then
			if value4 and value4 ~= "" then
				if m2debug.enables[value5] then
					_print(string.format("[ %s ] %s", value5, value4))
				end

				m2debug.add(value5, value4)
			end

			if not value4 then
				m2debug.add(value5, "nil")
			end
		end
	end

	local callback3 = display.replaceScene
	local value

	function display:replaceScene(...)
		m2debug.show(self)

		if value then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(value)

			value = nil
		end

		callback3(self, ...)
	end

	local callback4 = cc.Director.pushScene

	function cc.Director:pushScene(value4, ...)
		if m2debug.node then
			m2debug.node:removeSelf()

			m2debug.node = nil
		end

		m2debug.show(value4)

		if value then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(value)

			value = nil
		end

		callback4(self, value4, ...)
	end

	local callback5 = cc.Director.popScene

	function cc.Director:popScene(...)
		if m2debug.node then
			m2debug.node:removeSelf()

			m2debug.node = nil
		end

		value = cc.EventListenerCustom:create("director_after_draw", function()
			local instance = cc.Director:getInstance()
			local runningScene = instance:getRunningScene().s

			m2debug.show(runningScene)
			instance:getEventDispatcher():removeEventListener(value)

			value = nil
		end)

		self:getEventDispatcher():addEventListenerWithFixedPriority(value, 1)
		callback5(self, ...)
	end

	local node = display.newNode()
	local screenNode = display.newNode():addTo(node)

	node.screenNode = screenNode

	local label2 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 185):add2(screenNode)
	local label3 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 165):add2(screenNode)
	local label6 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 145):add2(screenNode)
	local label7 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 125):add2(screenNode)
	local label8 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 105):add2(screenNode)
	local label4 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 85):add2(screenNode)
	local label5 = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 65):add2(screenNode)

	cc.Director:getInstance():setNotificationNode(node)
	scheduler.scheduleUpdateGlobal(function()
		if main_scene and main_scene.ground and main_scene.ground.map then
			local items = {}

			table.merge(items, main_scene.ground.map.heros)
			table.merge(items, main_scene.ground.map.mons)
			table.merge(items, main_scene.ground.map.npcs)

			local value4 = table.nums(items)
			local count = 0

			for _4, item3 in pairs(items) do
				if item3.isIgnore then
					count = count + 1
				end
			end

			label2:setString("同屏人数: " .. value4 - count .. " / " .. value4 .. " / " .. (main_scene.ground.map.current_frame_updatedRoles or 0))
			label3:setString("map消息: " .. main_scene.ground.map.msgs.size())
		end

		label4:setString("传奇资源纹理数: " .. res.getMir2TexCount())
		label5:setString("传奇资源精灵: " .. m2spr.debuginfo)
	end)

	node.pingNode = display.newNode():addTo(node)
	node.pingNode.label = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):addTo(node.pingNode):pos(0, 210)
else
	print = hockprint
	__G__TRACKBACK__ = hockprint
	dump = hockprint
	p2 = hockprint
	d2 = hockprint

	return
end

local debugNode
local iap = {
	allowTouch = true,
	catch = false,
	enables = {},
	showEnables = {},
	texts = {},
	cmNames = {},
	smNames = {},
	setting = {
		acLogin = true
	}
}

for itemId2, _ in pairs(iap2) do
	iap.enables[itemId2] = true
end

local debug2 = cache.getDebug("filter")

if debug2 then
	for itemId3, item in pairs(debug2) do
		iap.enables[itemId3] = item
	end
end

for itemId4, _2 in pairs(evt) do
	iap.showEnables[itemId4] = false
end

local debug3 = cache.getDebug("shows")

if debug3 then
	for itemId5, item2 in pairs(debug3) do
		iap.showEnables[itemId5] = item2
	end
end

for itemId, _3 in pairs(evt) do
	evt[itemId](iap.showEnables[itemId])
end

local setting2 = cache.getDebug("setting")

if setting2 then
	iap.setting = setting2
end

local roleSpeed = cache.getDebug("roleSpeed")

if roleSpeed then
	iap.roleSpeed = roleSpeed
end

for key, g in pairs(_G) do
	if type(g) == "number" then
		if string.find(key, "CM_") == 1 then
			iap.cmNames[g] = key
		elseif string.find(key, "SM_") == 1 then
			iap.smNames[g] = key
		end
	end
end

function iap:add(value4)
	iap.texts[#iap.texts + 1] = {
		self,
		value4
	}

	if iap.enables[self] and iap.node then
		iap.node:addLog(self, value4)
	end
end

function iap:show()
	if not iap.hideNode then
		iap.node = debugNode.new():add2(self, an.z.debug)
	end
end

debugNode = class("debugNode", function()
	return display.newNode()
end)

table.merge(debugNode, {
	btn,
	btns,
	beganPos,
	beganTouchPos,
	hasMove,
	lock,
	content,
	catchNode
})

function debugNode:ctor()
	self.btn = res.get2("pic/console/iconbg8.png")

	self.btn:pos(self.btn:centerPos()):add2(self, 1):setCascadeOpacityEnabled(true)
	res.get2("pic/debug/icon.png"):pos(self.btn:centerPos()):add2(self.btn)
	self:setCascadeOpacityEnabled(true)
	self:size(self.btn:getw(), self.btn:geth()):anchor(0.5, 0.5):pos(self:getw() / 2, display.height - self:geth() / 2):opacity(0):runs({
		cc.FadeIn:create(1),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function()
			self:opacity(128)
		end)
	})
	self.btn:setTouchEnabled(true)
	self.btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(beganTouchPos2)
		if self.lock then
			return
		end

		if beganTouchPos2.name == "began" then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(beganTouchPos2.x, beganTouchPos2.y)
			self.hasMove = false

			self:opacity(255)
			self:scale(1)
			self:stopAllActions()
		elseif beganTouchPos2.name == "moved" then
			if self.hasMove or math.abs(self.beganTouchPos.x - beganTouchPos2.x) > 10 or math.abs(self.beganTouchPos.y - beganTouchPos2.y) > 10 then
				self.hasMove = true

				local x2 = beganTouchPos2.x - self.beganTouchPos.x + self.beganPos.x
				local y2 = beganTouchPos2.y - self.beganTouchPos.y + self.beganPos.y

				if x2 < 0 then
					x2 = 0
				end

				x2 = x2 > display.width and display.width or x2

				if y2 < 0 then
					y2 = 0
				end

				y2 = y2 > display.height and display.height or y2

				self:pos(x2, y2)
			end
		elseif beganTouchPos2.name == "ended" then
			local function cleanup(self3)
				self3 = self3 < self:getw() / 2 and self:getw() / 2 or self3
				self3 = self3 > display.width - self:getw() / 2 and display.width - self:getw() / 2 or self3

				return self3
			end

			local function cleanup2(self4)
				self4 = self4 < self:geth() / 2 and self:geth() / 2 or self4
				self4 = self4 > display.height - self:geth() / 2 and display.height - self:geth() / 2 or self4

				return self4
			end

			local function cleanup3(self2, h2)
				if h2 < self:geth() then
					self2 = cleanup(self2)
					h2 = self:geth() / 2
				elseif h2 > display.height - self:geth() then
					self2 = cleanup(self2)
					h2 = display.height - self:geth() / 2
				elseif self2 > display.cx then
					self2 = display.width - self:getw() / 2
					h2 = cleanup2(h2)
				else
					self2 = self:getw() / 2
					h2 = cleanup2(h2)
				end

				return self2, h2
			end

			local function cleanup4(self5, y3)
				if self.content then
					self:moveTo(0.25, self5, y3)
				else
					self:runs({
						cc.MoveTo:create(0.25, cc.p(self5, y3)),
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							self:opacity(128)
						end)
					})
				end
			end

			if not self.hasMove then
				self.lock = true

				self.btn:runs({
					cc.ScaleTo:create(0.1, 0.01),
					cc.ScaleTo:create(0.1, 1),
					cc.CallFunc:create(function()
						self.lock = nil

						if self.content then
							self.content:removeSelf()

							self.content = nil

							cleanup4(cleanup3(self:getPosition()))
						else
							self:createContent()
						end
					end)
				})
			else
				local value4 = beganTouchPos2.x - self.beganTouchPos.x + self.beganPos.x
				local value5 = beganTouchPos2.y - self.beganTouchPos.y + self.beganPos.y

				if self.content then
					value5 = cleanup2(value5)
					value4 = cleanup(value4)
				else
					value4, value5 = cleanup3(value4, value5)
				end

				cleanup4(value4, value5)
			end
		end

		return true
	end)
end

function debugNode:createContentBase(type2)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():anchor(0, 1):pos(self.btn:getw() / 2 + 5, self.btn:geth() / 2 - 5):size(500, 500):add2(self)
	self.content.type = type2

	display.newColorLayer(cc.c4b(0, 0, 0, 200)):size(self.content:getContentSize()):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)
end

function debugNode:createContent(value7)
	self:createContentBase("main")

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	self.content.beginpos = 1
	self.content.scroll = scroll

	local enabled

	scroll:enableTouch(iap.allowTouch)
	scroll:setListenner(function(nameOwner)
		local scrollOffset2, scrollOffset = scroll:getScrollOffset()

		if nameOwner.name == "moved" then
			if scrollOffset + scroll.labelM.wordSize.height > scroll:getScrollSize().height - scroll:geth() then
				self:hideNewMark()
			end

			if scrollOffset < 0 and not enabled and self.content.beginpos > 1 then
				enabled = true
			end
		elseif nameOwner.name == "ended" and enabled then
			local items = {}

			for beginpos2 = self.content.beginpos - 1, 1, -1 do
				local value5 = iap.texts[beginpos2]

				if iap.enables[value5[1]] then
					self.content.beginpos = beginpos2

					table.insert(items, 1, value5)

					if #items >= 100 then
						break
					end
				end
			end

			if #items > 0 then
				local label9 = an.newLabelM(scroll:getw(), scroll.labelM.fontSize, 0)

				for _5, item3 in ipairs(items) do
					label9:nextLine():addLabel("[ " .. item3[1] .. " ] ", self:getColor(item3[1])):addLabel(item3[2])
				end

				display.newColorLayer(cc.c4b(255, 255, 0, 255)):size(label9:getw(), 1):add2(label9)
				scroll.labelM:insertNodeToFront(label9, #label9.lines)
				scroll:setScrollOffset(0, scrollOffset + label9:geth() - label9.wordSize.height / 2)
			end

			enabled = nil
		end
	end)

	local items2 = {}

	for beginpos = #iap.texts, 1, -1 do
		local value4 = iap.texts[beginpos]

		if iap.enables[value4[1]] then
			self.content.beginpos = beginpos

			table.insert(items2, 1, value4)

			if #items2 >= 30 then
				break
			end
		end
	end

	for _4, item4 in ipairs(items2) do
		self:addLog(item4[1], item4[2])
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		if not iap.logging and g_data.login and g_data.login.ticket then
			print("已手动保存日志，自动日志中……")
			print("文件位置：" .. cache.debugPath() .. os.date("%Y-%m-%d") .. g_data.login.ticket .. ".txt")

			iap.logging = true

			local value6 = os.date("%Y-%m-%d") .. g_data.login.ticket .. ".txt"

			cache.saveDebug(value6, iap.texts)

			iap.logging = false

			self:createContentForTips("已保存到[" .. value6 .. "]")
		end
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"保存",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, self.content:geth() - 30)

	iap.autoSaving = an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		if not iap.logtimer then
			print("开启自动记录日志，记录批次：" .. os.date("%Y-%m-%d"))

			iap.logtimer = scheduler.scheduleGlobal(function()
				if not iap.logging then
					iap.logging = true

					local value8 = os.date("%Y-%m-%d") .. ".txt"

					cache.saveDebug(value8, iap.texts)

					iap.logging = false
				end
			end, 0.1)

			iap.autoSaving.label:setText("记录中…")
		else
			print("自动日志中……")
		end
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"自动保存",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, self.content:geth() - 80)

	if iap.logtimer then
		iap.autoSaving.label:setText("记录中…")
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:showLogContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"查看日志",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, self.content:geth() - 130)

	if value7 then
		local function callback7(self3)
			local string2 = loadstring(self3)

			if string2 then
				string2()
			else
				print("lua格式有误.")
			end
		end

		local label10
		local enabled2 = true

		if (device.platform == "mac" or device.platform == "windows") and enabled2 then
			label10 = cc.ui.UIInput.new({
				UIInputType = 1,
				size = cc.size(self.content:getw(), 40),
				image = display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")),
				listener = function(value9)
					if value9 == "changed" then
						local text = label10:getText()

						if string.byte(string.reverse(text)) == string.byte("\\") then
							callback7(string.sub(text, 1, #text - 1))
							label10:setText("")
						end
					else
						callback7(label10:getText())
						label10:setText("")
					end
				end
			}):anchor(0, 1):opacity(0):fadeIn(0.1):pos(0, 24):moveTo(0.1, 0, 4):add2(self.content)
		else
			label10 = an.newInput(0, 0, self.content:getw(), 40, 255, {
				label = {
					"",
					22,
					0
				},
				bg = {
					h = 40,
					tex = res.gettex2("pic/scale/scale2.png"),
					offset = {
						-10,
						0
					}
				},
				return_call = function()
					callback7(label10:getText())
					label10:setText("")
				end
			}):anchor(0, 1):opacity(0):fadeIn(0.1):pos(10, 24):moveTo(0.1, 10, 4):add2(self.content)
		end

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(label10:getContentSize()):add2(label10, -1)
	end

	local count = 0

	local function callback6(self2, callback8)
		local number = 30
		local btn2

		btn2 = an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
			callback8(btn2)
		end, {
			pressBig = true,
			scale9 = cc.size(string.utf8len(self2) * number, 40),
			label = {
				self2,
				20,
				1,
				{
					color = display.COLOR_GREEN
				}
			}
		}):add2(self.content, -1):anchor(0, 0):pos(28 + count, self.content:geth() - 4)

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(btn2:getContentSize()):add2(btn2, -1)

		count = count + btn2:getw() + 2
	end

	callback6(iap.allowTouch and "可触摸" or "不可触摸", function(labelOwner)
		iap.allowTouch = not iap.allowTouch

		if iap.allowTouch then
			labelOwner.label:setText("可触摸")
		else
			labelOwner.label:setText("不可触摸")
		end

		scroll:enableTouch(iap.allowTouch)
	end)
	callback6("清空", function()
		scroll.labelM:clear()
	end)

	if def.advbzm2debug then
		callback6("过滤", function()
			self:createContentForFilter()
		end)
		callback6("lua", function()
			self:createContentForLua()
		end)
		callback6("设置", function()
			self:createContentForSetting()
		end)
		callback6("GM", function()
			self:createContentForGMCmd()
		end)
	end
end

function debugNode:showLogContent()
	local value7 = os.date("%Y-%m-%d") .. ".txt"
	local debug4 = cache.getDebug(value7)

	if not debug4 then
		print("无日志可读取")

		return
	end

	self:createContentBase("log")

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	self.content.beginpos = 1
	self.content.scroll = scroll

	local enabled

	scroll:enableTouch(iap.allowTouch)
	scroll:setListenner(function(nameOwner)
		local scrollOffset2, scrollOffset = scroll:getScrollOffset()

		if nameOwner.name == "moved" then
			if scrollOffset + scroll.labelM.wordSize.height > scroll:getScrollSize().height - scroll:geth() then
				self:hideNewMark()
			end

			if scrollOffset < 0 and not enabled and self.content.beginpos > 1 then
				enabled = true
			end
		elseif nameOwner.name == "ended" and enabled then
			local items = {}

			for beginpos2 = self.content.beginpos - 1, 1, -1 do
				local value5 = debug4[beginpos2]

				if iap.enables[value5[1]] then
					self.content.beginpos = beginpos2

					table.insert(items, 1, value5)

					if #items >= 500 then
						break
					end
				end
			end

			if #items > 0 then
				local label9 = an.newLabelM(scroll:getw(), scroll.labelM.fontSize, 0)

				for _5, item3 in ipairs(items) do
					label9:nextLine():addLabel("[ " .. item3[1] .. " ] ", self:getColor(item3[1])):addLabel(item3[2])
				end

				display.newColorLayer(cc.c4b(255, 255, 0, 255)):size(label9:getw(), 1):add2(label9)
				scroll.labelM:insertNodeToFront(label9, #label9.lines)
				scroll:setScrollOffset(0, scrollOffset + label9:geth() - label9.wordSize.height / 2)
			end

			enabled = nil
		end
	end)

	local items2 = {}

	for beginpos = #debug4, 1, -1 do
		local value4 = debug4[beginpos]

		if iap.enables[value4[1]] then
			self.content.beginpos = beginpos

			table.insert(items2, 1, value4)

			if #items2 >= 500 then
				break
			end
		end
	end

	for _4, item4 in ipairs(items2) do
		self:addHistoryLog(item4[1], item4[2])
	end

	local count = 0

	;(function(value6, callback6)
		local number = 30
		local btn2

		btn2 = an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
			callback6(btn2)
		end, {
			pressBig = true,
			scale9 = cc.size(string.utf8len(value6) * number, 40),
			label = {
				value6,
				20,
				1,
				{
					color = display.COLOR_GREEN
				}
			}
		}):add2(self.content, -1):anchor(0, 0):pos(28 + count, self.content:geth() - 4)

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(btn2:getContentSize()):add2(btn2, -1)

		count = count + btn2:getw() + 2
	end)("历史日志：" .. os.date("%Y-%m-%d"), function(value8)
		return
	end)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForFilter()
	self:createContentBase()
	self.content:setNodeEventEnabled(true)

	function self.content.onCleanup()
		cache.saveDebug("filter", iap.enables)
	end

	local count = 0

	local function callback6(self2, value5)
		local value4 = count % 3
		local value6 = math.modf(count / 3)
		local point = cc.p(20 + value4 * 160, self.content:geth() - 40 - value6 * 60)
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(value7)
			iap.enables[self2] = value7
		end, {
			easy = true,
			default = iap.enables[self2],
			label = {
				value5 .. "[" .. self2 .. "]",
				20,
				1,
				{
					color = self:getColor(self2)
				}
			}
		}):anchor(0, 0.5):pos(point.x, point.y):add2(self.content)

		count = count + 1
	end

	for itemId6, item3 in pairs(iap2) do
		callback6(itemId6, item3)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLua()
	self:createContentBase()

	local items = {
		{
			"执行lua语句..",
			function()
				self:createContent(true)
			end
		},
		{
			"查询全局变量值..",
			function()
				self:createContentForLuaQueryVar()
			end
		},
		{
			"查看常量值..",
			function()
				self:createContentForLuaQueryConst()
			end
		},
		{
			"当前版本:" .. (MIR2_VERSION or "")
		}
	}

	for index, item3 in ipairs(items) do
		an.newLabel(item3[1], 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):pos(20, self.content:geth() - 80 - (index - 1) * 60):add2(self.content):enableClick(item3[2], {
			ani = true
		})
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLuaQueryVar()
	self:createContentBase()
	an.newLabel("变量名: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(20, self.content:geth() - 50):add2(self.content)

	local label9 = an.newInput(130, self.content:geth() - 52, 200, 32, 15, {
		label = {
			"g_data",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		}
	}):anchor(0, 0.5):add2(self.content)
	local items = {
		"def",
		"g_data",
		"game",
		"res",
		"display",
		"device"
	}

	for index, item3 in ipairs(items) do
		local value4 = math.modf((index - 1) / 3)
		local value5 = (index - 1) % 3

		an.newLabel(item3, 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0.5, 0.5):pos(60 + value5 * 170, self.content:geth() - 120 - value4 * 50):add2(self.content):enableClick(function()
			label9:setString(item3)
		end, {
			ani = true,
			size = cc.size(120, 40)
		})
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContentForLuaQueryVarDetail(label9:getText())
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 150, 30)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContentForLua()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLuaQueryVarDetail(value5, items)
	self:createContentBase()

	items = items or {}
	items[#items + 1] = value5

	local function callback6()
		if #items == 1 then
			self:createContentForLuaQueryVar()
		else
			items[#items] = nil

			local value9 = items[#items]

			items[#items] = nil

			self:createContentForLuaQueryVarDetail(value9, clone(items))
		end
	end

	local res2 = ""

	for index, item3 in ipairs(items) do
		if index == 1 then
			res2 = item3
		elseif type(item3) == "string" then
			res2 = res2 .. "[\"" .. item3 .. "\"]"
		elseif type(item3) == "number" then
			res2 = res2 .. "[" .. item3 .. "]"
		else
			res2 = res2 .. ":get(\"" .. item3[1] .. "\")"
		end
	end

	local text3 = "local var = " .. res2 .. " return var"
	local string2 = loadstring(text3)

	if not string2 then
		self:createContentForTips("查询失败. [" .. text3 .. "]", callback6)

		return
	end

	print(res2)

	local value6 = string2()

	if type(value6) ~= "table" then
		self:createContentForTips("变量[" .. value5 .. "]并不是table类型", callback6)

		return
	end

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			22,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	scroll.labelM:nextLine():addLabel("变量名: " .. res2, cc.c3b(255, 0, 255)):nextLine()

	local value7 = value6
	local value8 = table.keys(value7)

	table.sort(value8, function(text, text2)
		return tostring(text) < tostring(text2)
	end)

	for _4, item4 in pairs(value8) do
		local value4 = value7[item4]

		if type(value4) == "table" then
			scroll.labelM:nextLine():addLabel(type(value4) .. "  ", display.COLOR_GREEN):addLabel(item4 .. "  ", cc.c3b(0, 255, 255)):addLabel("查看详情[" .. table.nums(value4) .. "]", cc.c3b(255, 255, 0), nil, nil, {
				ani = true,
				callback = function()
					self:createContentForLuaQueryVarDetail(item4, clone(items))
				end
			})
		elseif type(value4) == "number" or type(value4) == "string" then
			scroll.labelM:nextLine():addLabel(type(value4) .. "  ", display.COLOR_GREEN):addLabel(item4 .. "  ", cc.c3b(0, 255, 255)):addLabel(value4)
		end
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), callback6, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLuaQueryConst()
	self:createContentBase()

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	local items = {
		{
			"原始版本",
			MIR2_VERSION_BASE
		},
		{
			"现在版本",
			MIR2_VERSION
		},
		{
			"登录服务器ip",
			def.ip
		},
		{
			"区服id",
			def.areaID
		},
		{
			"更新服务器ip",
			import("...upt.def", value3).httpRoot
		},
		{
			"中央服地址",
			def.loginCenterIP
		},
		{
			"chatHttpRoot",
			def.chatHttpRoot
		},
		{
			"useIGW",
			def.useIGW
		},
		{
			"gameType",
			def.gameType
		},
		{
			"屏幕宽高",
			display.width .. " * " .. display.height
		},
		{
			"版本类型",
			def.gameVersionType
		},
		{
			"客户端版本号",
			def.MIR_VERSION_NUMBER
		}
	}

	for _4, item3 in ipairs(items) do
		scroll.labelM:nextLine():addLabel(item3[1] .. ": ", display.COLOR_GREEN):addLabel(item3[2])
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContentForLua()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForAdaptSpeed()
	self:createContentBase()

	if not iap.roleSpeed then
		iap.roleSpeed = def.role.speed
	else
		def.role.speed = iap.roleSpeed
	end

	config = {
		{
			"一般动作",
			"normal"
		},
		{
			"加速",
			"fast"
		},
		{
			"冲撞失败",
			"rushKung"
		},
		{
			"野蛮冲撞",
			"rush"
		},
		{
			"基础释法间隔",
			"spell"
		},
		{
			"基础攻击间隔",
			"attack"
		}
	}

	local value4
	local items = {}
	local count = 0

	for _4, config2 in pairs(config) do
		count = count + 45

		local label10

		local function stop_call2()
			print(config2[1], num)

			if not tolua.isnull(label10) then
				local number = tonumber(label10:getString())

				def.role.speed[config2[2]] = number

				cache.saveDebug("roleSpeed", def.role.speed)
				print(config2[1], number)
			end
		end

		label10 = an.newInput(200, self.content:geth() - count, 170, 32, 15, {
			label = {
				"" .. def.role.speed[config2[2]],
				22,
				1
			},
			bg = {
				h = 40,
				tex = res.gettex2("pic/scale/scale2.png"),
				offset = {
					-10,
					0
				}
			},
			start_call = function()
				if value4 and value4 ~= label10 then
					value4:stopInput()
				end

				value4 = label10
			end,
			stop_call = stop_call2
		}):anchor(0, 0.5):add2(self.content)

		function label10.onCleanup()
			stop_call2()
			label10:stopInput()
		end

		local label9 = an.newLabel(config2[1] .. ":", 22, 0, {
			color = cc.c3b(255, 255, 255)
		}):pos(10, self.content:geth() - count - 10):add2(self.content)
	end
end

function debugNode:createContentForTest()
	local function callback6(self2)
		local scene = require("upt.scene")

		SKIP_UPT = false
		s = scene.new(function()
			s:setTitle("请重启游戏")
		end)

		s:rmdir(device.writablePath .. "cache/")
		s:rmdir(s.storagePath .. "res/")
		s:rmdir(s.storagePath .. "rs/")
		s:rmdir(s.storagePath .. "upt/")
		os.remove(s.storagePath .. "project.manifest")
		os.remove(s.storagePath .. "version.manifest")
		display.replaceScene(s)
		s:saveRemoteAddress(self2)
	end

	local items = {
		{
			"获取技能书",
			function()
				local magicIds = def.magic.getMagicIds(g_data.player.job, false)

				for _4, item3 in pairs(magicIds) do
					net.send({
						CM_SAY
					}, {
						"@doresou " .. def.magic.getMagicConfigByUid(item3).name
					})
				end
			end
		},
		{
			"升级技能",
			function(label9)
				local number2 = tonumber(label9:getString()) or 3

				if number2 then
					local magicIds2 = def.magic.getMagicIds(g_data.player.job, false)
					local name = main_scene.ground.player.info:getName()

					for _5, item4 in pairs(magicIds2) do
						local text = string.format("@upuserskill %s %s %d", name, def.magic.getMagicConfigByUid(item4).name, number2)

						net.send({
							CM_SAY
						}, {
							text
						})
					end
				end
			end,
			true
		},
		{
			"道士消耗品",
			function()
				local items2 = {
					"超级护身符",
					"超级灰色药粉",
					"超级黄色药粉"
				}

				for _6, item5 in pairs(items2) do
					net.send({
						CM_SAY
					}, {
						"@doresou " .. item5
					})
				end
			end
		},
		{
			"使用测试版热更服务器",
			function()
				callback6("http://116.211.22.22:8989/")
			end
		},
		{
			"使用运维版热更服务器",
			function()
				callback6("http://mir2ys.webpatch.sdg-china.com/")
			end
		},
		{
			"刷假人",
			function()
				require("mir2.scenes.main.common.helper.util").stressTest()
			end
		},
		{
			"刷假人,重复",
			function(label10)
				local number = tonumber(label10:getString()) or 3
				local util = require("mir2.scenes.main.common.helper.util")
				local value4

				function c()
					if number > 0 then
						value4 = util.stressTest(false, true)
						number = number - 1

						scheduler.performWithDelayGlobal(c, 1)
						scheduler.performWithDelayGlobal(value4, 0.5)
					end
				end

				c()
			end,
			true
		},
		{
			"刷假人随机衣服",
			function()
				require("mir2.scenes.main.common.helper.util").stressTest(false, true)
			end
		},
		{
			"刷假人随机衣服技能",
			function()
				require("mir2.scenes.main.common.helper.util").stressTest(true, true)
			end
		}
	}

	self:createContentForSetting(items)
end

function debugNode:createContentForSetting(value4)
	self:createContentBase()

	value4 = value4 or {
		{
			"添加测试服务器",
			function()
				self:createContentForSettingServer()
			end
		},
		{
			"设置界面调试信息",
			function()
				self:createContentForSettingShows()
			end
		},
		{
			"隐藏工具图标",
			function()
				if iap.node then
					iap.node:removeSelf()

					iap.node = nil
				end

				iap.hideNode = true
			end
		},
		{
			"测试lua error",
			function()
				(nil):func()
			end
		},
		{
			"测试崩溃",
			function()
				ycFunction:testCrash()
			end
		},
		{
			"清理游戏数据",
			function()
				s = require("upt.scene").new(function()
					s:setTitle("请重启游戏")
				end, false)

				s:rmdir(device.writablePath .. "cache/")
				s:rmdir(s.storagePath .. "res/")
				s:rmdir(s.storagePath .. "rs/")
				s:rmdir(s.storagePath .. "upt/")
				os.remove(s.storagePath .. "project.manifest")
				os.remove(s.storagePath .. "version.manifest")

				SKIP_UPT = true

				display.replaceScene(s)
				s:setTitle("请重启游戏")
			end
		},
		{
			"执行更新",
			function()
				local scene

				scene = require("upt.scene").new(function()
					scene:setTitle("请重启游戏")
				end, true)

				display.replaceScene(scene)
			end
		},
		{
			"播放CG动画",
			function()
				local helper = require("mir2.scenes.main.common.helper.helper")

				def.magic.getConfig("skillMagic")
				helper.call("CG")
			end
		},
		{
			"调整动作速度",
			function()
				self:createContentForAdaptSpeed()
			end
		},
		{
			"清理CG初次标记",
			function()
				cache.cgClear()
				self.content:removeSelf()

				self.content = nil
			end
		},
		{
			iap.setting.manualServer and "切换为自动选服" or "切换为手动选服",
			function()
				iap.setting.manualServer = not iap.setting.manualServer

				cache.saveDebug("setting", iap.setting)
				self:createContentForSetting()
			end
		},
		{
			"辅助测试",
			function()
				self:createContentForTest()
			end
		},
		{
			"测试例",
			function()
				local testm2spr = require("test.testm2spr")()

				self:createContentForSetting(testm2spr)
			end
		},
		{
			iap.setting.acLogin and "切换为G+登录" or "切换为账号登录",
			function()
				iap.setting.acLogin = not iap.setting.acLogin

				cache.saveDebug("setting", iap.setting)
				self:createContentForSetting()
			end
		}
	}

	local h2 = self.content:geth() - 40
	local x2 = 20
	local count = 0

	for _4, item3 in ipairs(value4) do
		local input
		local label9 = an.newLabel(item3[1], 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):pos(x2, h2):add2(self.content):enableClick(function()
			item3[2](input)
		end, {
			ani = true
		})

		if item3[3] then
			input = an.newInput(0, 0, 40, 30, 255, {
				donotClip = true,
				bg = {
					h = 35,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						0
					}
				}
			}):addTo(label9):pos(label9:getw() + 30, 28):anchor(0, 1)
		end

		count = math.max(label9:getw(), count)
		h2 = h2 - 45

		if h2 < 0 then
			x2 = x2 + count + 20
			count = 0
			h2 = self.content:geth() - 40
		end
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForSettingShows()
	self:createContentBase()
	self.content:setNodeEventEnabled(true)

	function self.content.onCleanup()
		cache.saveDebug("shows", iap.showEnables)
	end

	local count = 0

	local function callback6(self2, value7)
		local value5 = count % 3
		local value6 = math.modf(count / 3)
		local point = cc.p(20 + value5 * 160, self.content:geth() - 40 - value6 * 60)
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(value4)
			iap.showEnables[self2] = value4

			evt[self2](value4)
		end, {
			easy = true,
			default = iap.showEnables[self2],
			label = {
				self2,
				20,
				1,
				{
					color = self:getColor(self2)
				}
			}
		}):anchor(0, 0.5):pos(point.x, point.y):add2(self.content)

		count = count + 1
	end

	for itemId6, _4 in pairs(evt) do
		callback6(itemId6)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForSettingServer()
	self:createContentBase()
	an.newLabel("服务器IP: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(20, self.content:geth() - 50):add2(self.content)

	local value7
	local value8
	local label9 = an.newInput(130, self.content:geth() - 52, 170, 32, 22, {
		label = {
			"",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		},
		start_call = function()
			return
		end
	}):anchor(0, 0.5):add2(self.content)

	an.newLabel("端口: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(300, self.content:geth() - 50):add2(self.content)

	local label10 = an.newInput(390, self.content:geth() - 52, 90, 32, 6, {
		label = {
			"",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		},
		start_call = function()
			label9:stopInput()
		end
	}):anchor(0, 0.5):add2(self.content)

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		local function callback6(self2)
			self:createContentForTips(self2, function()
				self:createContentForSetting()
			end)
		end

		label9:stopInput()
		label10:stopInput()

		local text2 = label9:getText()
		local text = label10:getText()

		text = text == "" and 80 or tonumber(text)

		;(function(value4, curIP2, value6)
			if not iap.setting[value4] then
				iap.setting[value4] = {}
			end

			iap.setting[value4][curIP2] = value6
			iap.setting.ip_history.curIP = curIP2
		end)("ip_history", text2, text)
		cache.saveDebug("setting", iap.setting)
		game.gotoscene("login")
		self:createContentForSettingServer()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 150, 30)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContentForSetting()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)

	local y2 = 30

	iap.setting.ip_history = iap.setting.ip_history or {
		[def.loginCenterIP] = def.loginCenterPort
	}

	for itemId6, item3 in pairs(iap.setting.ip_history or {}) do
		if itemId6 ~= "curIP" then
			local curIP = itemId6
			local value5 = item3
			local color2 = cc.c3b(255, 255, 0)

			if itemId6 == iap.setting.ip_history.curIP then
				color2 = cc.c3b(255, 0, 0)
			end

			an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
				def.setLoginCenter(curIP, value5)

				iap.setting.ip_history.curIP = curIP

				cache.saveDebug("setting", iap.setting)
				game.gotoscene("login")
			end, {
				pressBig = true,
				scale9 = cc.size(180, 40),
				label = {
					itemId6 .. ":" .. value5,
					18,
					1,
					{
						color = color2
					}
				}
			}):add2(self.content):pos(120, y2)

			y2 = y2 + 40
		end
	end
end

iap.setting.ip_history = iap.setting.ip_history or {}
iap.setting.ip_history["center.peibanmir2.com"] = 8088
iap.setting.ip_history["172.18.10.161"] = 80

if iap.setting.ip_history and iap.setting.ip_history and iap.setting.ip_history.curIP then
	iap.setting.ip_history[def.loginCenterIP] = def.loginCenterPort

	def.setLoginCenter(iap.setting.ip_history.curIP, iap.setting.ip_history[iap.setting.ip_history.curIP])
end

function debugNode:createContentForTips(value4, value5)
	self:createContentBase()
	an.newLabel(value4, 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0.5, 0.5):pos(self.content:centerPos()):add2(self.content)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), value5 or function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForGMCmd()
	self:createContentBase()

	local cmdList = self:createCmdList("common")

	an.newLabel("命令类别", 18, 1, {
		color = display.COLOR_RED
	}):addTo(cmdList):pos(10, cmdList.h):anchor(0, 1)

	local y2 = cmdList.h - cmdList.space
	local count = 1

	for key2, _4 in pairs(def.gmCmd.sort) do
		an.newLabel(key2, 18, 1):addTo(cmdList):pos((count + 2) % 3 * 150 + 10, y2):anchor(0, 1):enableClick(function()
			self:createCmdList(key2)
		end)

		count = count + 1
		y2 = y2 - (count % 3 == 1 and cmdList.space or 0)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createCmdList(value4)
	self:createContentBase()

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	scroll.h = scroll:geth() - 5
	scroll.space = 30

	local items
	local callback6

	if value4 == "common" then
		items = def.gmCmd.common

		function callback6()
			self:createContentForGMCmd()
		end

		an.newLabel("常用命令", 18, 1, {
			color = display.COLOR_RED
		}):addTo(scroll):pos(10, scroll.h):anchor(0, 1)

		scroll.h = scroll.h - scroll.space
	else
		for key2, sort in pairs(def.gmCmd.sort) do
			if key2 == value4 then
				items = sort

				break
			end
		end

		function callback6()
			self:createCmdList(value4)
		end

		an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
			self:createContentForGMCmd()
		end, {
			pressBig = true,
			scale9 = cc.size(80, 40),
			label = {
				"返回",
				18,
				1,
				{
					color = cc.c3b(255, 255, 0)
				}
			}
		}):add2(scroll):pos(scroll:getw() - 40, 24)
	end

	local count = 1

	for index, item3 in ipairs(items) do
		local label9 = an.newLabel(item3[1], 18, 1):addTo(scroll):pos((count + 2) % 3 * 155, scroll.h):anchor(0, 1):enableClick(function()
			self:createCmd(item3, callback6)
		end)

		count = count + 1
		scroll.h = scroll.h - ((count % 3 == 1 or index == #items) and scroll.space or 0)
	end

	return scroll
end

function debugNode:createCmd(value4, value6)
	self:createContentBase()
	self.content:setNodeEventEnabled(true)

	function self.content.onCleanup()
		iap.catchNode = nil
	end

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	dump(value4)

	local x2 = 10
	local h2 = scroll:geth() - 10
	local number2 = 150
	local number = 40

	an.newLabelM(self.content:getw() - 20, 20, 1):addTo(scroll):pos(x2, h2):anchor(0, 1):nextLine():addLabel("命令描述: " .. value4[2])

	local y2 = h2 - number
	local items2 = {}
	local enabled = false
	local label11

	if value4[4] ~= "" then
		local string2 = loadstring("return " .. value4[4])

		for _4, item3 in ipairs(string2()) do
			local value8
			local value9
			local label9 = an.newLabel(item3, 20, 1):addTo(scroll):pos(10, y2):anchor(0, 1)
			local label10 = an.newInput(0, 0, 120, 35, 255, {
				donotClip = true,
				bg = {
					h = 35,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						0
					}
				}
			}):addTo(scroll):pos(30 + label9:getw(), y2):anchor(0, 1)

			items2[#items2 + 1] = label10

			if string.find(item3, "角色名") or string.find(item3, "怪物名") then
				enabled = true

				an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
					print("catch name ", iap.catchName)
					label10:setText(iap.catchName and iap.catchName or "")
				end, {
					pressBig = true,
					scale9 = cc.size(80, 40),
					label = {
						"获取名字",
						18,
						1,
						{
							color = cc.c3b(255, 255, 0)
						}
					}
				}):add2(scroll):pos(label10:getPositionX() + label10:getw() + 30, y2):anchor(0, 1)
			end

			if string.find(item3, "地图ID") then
				label11 = label10
			end

			y2 = y2 - number
		end
	end

	local items = {}
	local value5

	if value4[5] ~= "" then
		local string3 = loadstring("return " .. value4[5])

		for index2, item4 in ipairs(string3()) do
			local value10
			local btn2 = an.newBtn(res.gettex2("pic/common/toggle10.png"), function(value7)
				for _5, item5 in ipairs(items) do
					if item5 == value7 then
						item5:select()

						value5 = item4
					else
						item5:unselect()
					end
				end
			end, {
				manual = true,
				label = {
					item4,
					20,
					1,
					{
						color = def.colors.btn20,
						sc = def.colors.btn20s
					}
				},
				labelOffset = {
					x = 50,
					y = 0
				},
				select = {
					res.gettex2("pic/common/toggle11.png")
				}
			}):addTo(scroll):anchor(0, 1)

			items[#items + 1] = btn2

			btn2:pos((#items + 2) % 3 * number2 + x2, y2)

			if index2 == 1 then
				btn2:select()

				value5 = item4
			end
		end
	end

	if label11 then
		local items4 = {
			["0"] = "比奇省",
			sldg = "边界城",
			["2"] = "毒蛇山谷",
			["3"] = "盟重省",
			["11"] = "白日门",
			["6"] = "魔龙城",
			["5"] = "苍月岛",
			["1"] = "沃玛森林",
			["4"] = "封魔谷"
		}
		local count = 1

		for itemId6, item8 in pairs(items4) do
			an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
				label11:setText(itemId6)
			end, {
				pressBig = true,
				scale9 = cc.size(80, 40),
				label = {
					item8,
					20,
					1,
					{
						color = cc.c3b(255, 255, 0)
					}
				}
			}):add2(scroll):pos((count - (count > 5 and 6 or 1)) * 90, y2):anchor(0, 1)

			count = count + 1

			if count == 6 then
				y2 = y2 - number
			end
		end
	end

	if enabled then
		self.catchNode = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(catch2)
			iap.catch = catch2
		end, {
			easy = true,
			default = iap.catch,
			label = {
				"允许获取",
				20,
				1
			}
		}):addTo(scroll):pos(10, 24):anchor(0, 0.5)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function()
		local text4 = "@" .. value4[3]

		for _6, item7 in ipairs(items2) do
			if item7:getText() ~= "" then
				text4 = text4 .. " " .. item7:getText()
			end
		end

		if value5 then
			text4 = text4 .. " " .. value5
		end

		local function callback6(self2)
			print(self2)

			local items3 = {}

			if self2 then
				self2 = utf8strs(self2)

				for index, item6 in ipairs(self2) do
					if string.len(item6) >= 4 then
						local text3 = crypto.encodeBase64(item6)
						local text = string.sub(text3, 1, string.len(text3) - 1)
						local text2 = string.gsub(text, "/", "!")

						items3[index] = "{@ej" .. text2 .. "}"
					else
						items3[index] = item6
					end
				end
			end

			print(table.concat(items3))

			return table.concat(items3)
		end

		net.send({
			CM_SAY
		}, {
			callback6(text4)
		})
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(scroll):pos(scroll:getw() - 150, 24)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), value6, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(scroll):pos(scroll:getw() - 40, 24)
end

function debugNode:getColor(value4)
	if value4 == "error" or value4 == "assert" then
		return display.COLOR_RED
	end

	return display.COLOR_GREEN
end

function debugNode:addHistoryLog(value5, value6)
	if not self.content then
		return
	end

	local value4 = self.content.scroll
	local scrollOffset2, scrollOffset = value4:getScrollOffset()
	local scrollSize = value4:getScrollSize().height < scrollOffset + value4:geth() + value4.labelM.wordSize.height

	value4.labelM:nextLine():addLabel("[ " .. value5 .. " ] ", self:getColor(value5)):addLabel(value6)

	if scrollSize then
		value4:setScrollOffset(0, value4:getScrollSize().height - value4:geth())
	else
		self:showNewMark()
	end

	return true
end

function debugNode:addLog(value5, value6)
	if not self.content or self.content.type ~= "main" then
		return
	end

	local value4 = self.content.scroll
	local scrollOffset2, scrollOffset = value4:getScrollOffset()
	local scrollSize = value4:getScrollSize().height < scrollOffset + value4:geth() + value4.labelM.wordSize.height

	value4.labelM:nextLine():addLabel("[ " .. value5 .. " ] ", self:getColor(value5)):addLabel(value6)

	if scrollSize then
		value4:setScrollOffset(0, value4:getScrollSize().height - value4:geth())
	else
		self:showNewMark()
	end

	return true
end

function debugNode:showNewMark()
	if not self.content.newMark then
		self.content.newMark = res.get2("pic/common/msgNew.png"):add2(self.content, 1):run(cc.RepeatForever:create(transition.sequence({
			cc.ScaleTo:create(0.5, 0.7),
			cc.ScaleTo:create(0.5, 1)
		}))):enableClick(function()
			self.content.newMark:hide()
			self.content.scroll:setScrollOffset(0, self.content.scroll:getScrollSize().height - self.content.scroll:geth())
		end)
	end

	self.content.newMark:show():pos(self.content:getw() - 20, 24)
end

function debugNode:hideNewMark()
	if self.content.newMark then
		self.content.newMark:hide()
	end
end

return iap
