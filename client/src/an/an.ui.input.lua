local input = class("an.input", function ()
	return display.newNode()
end)
local testh = 280

table.merge(input, {
	bg,
	bgIsPressShow,
	label,
	content,
	cursor,
	maxLen,
	mask,
	testKeyboard,
	listener,
	password,
	passwordHandle,
	donotMove,
	donotClip,
	return_call,
	stop_call,
	show_call,
	hide_call,
	getWorldY_call,
	inputting,
	tip
})

function input:ctor(x, y, w, h, max, params)
	params = params or {}

	if DEBUG > 0 and params.bg and params.bg.tex and type(params.bg.tex) ~= "userdata" and tolua.type(params.bg.tex) ~= "cc.Texture2D" then
		printError("param[%s] must be 'cc.Texture2D' Type. ", params.bg.tex)

		return
	end

	local labelParams = params.label or {}
	local text = labelParams[1] or ""
	local fontSize = labelParams[2] or display.DEFAULT_TTF_FONT_SIZE
	local strokeSize = labelParams[3] or 0

	if params.bg then
		if params.bg.tex then
			local size = params.bg.tex:getContentSize()
			local frame = cc.SpriteFrame:createWithTexture(params.bg.tex, cc.rect(0, 0, size.width, size.height))
			local offset = params.bg.offset or {
				0,
				0
			}
			self.bg = display.newScale9Sprite(frame):size(w, params.bg.h or h):anchor(0, 0):pos(offset[1], offset[2]):addto(self)
		else
			local bgColor = params.bg.color or cc.c4b(0, 0, 0, 255)
			self.bg = display.newColorLayer(bgColor):size(w, params.bg.h or fontSize + 2):pos(0, params.bg.y or (h - fontSize) / 2):addto(self)
			self.bgIsPressShow = params.bg.pressShow

			self:checkBgShow(false)
		end
	else
		self.bgIsPressShow = nil
	end

	local clip = nil

	if not params.donotClip then
		clip = display.newClippingRegionNode(cc.rect(0, 0, w, h)):add2(self)
	end

	self.label = an.newLabelM(w, fontSize, strokeSize, {
		manual = true
	}):pos(0, (h - fontSize) / 2):add2(clip or self)
	self.cursor = display.newColorLayer(cc.c4b(0, 255, 255, 255)):size(2, fontSize):pos(0, (h - fontSize) / 2):addto(self):hide()
	self.listener = ycInputListener:create()

	self.listener:setListener(handler(self, self.callback))
	self:anchor(0.5, 0.5):pos(x, y):size(w, h)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			self:startInput()
		end
	end)
	self:setNodeEventEnabled(true)

	function self.onCleanup()
		ycInputListener:release(self.listener)

		if self.passwordHandle then
			scheduler.unscheduleGlobal(self.passwordHandle)

			self.passwordHandle = nil
		end
	end

	self.keyboardHeightMax = 0
	self.maxLen = max
	self.password = params.password
	self.donotMove = params.donotMove
	self.return_call = params.return_call
	self.start_call = params.start_call
	self.stop_call = params.stop_call
	self.show_call = params.show_call
	self.hide_call = params.hide_call
	self.getWorldY_call = params.getWorldY_call
	self.params = params
	self.mask = nil
	self.passwordHandle = nil
	self.inputting = nil

	self:setText(text)
	self:showTip(true)
end

function input:callback(dic)
	if dic.type == "keyboardWillShow" then
		if self.inputting and not self.donotMove then
			local worldY = nil

			if self.getWorldY_call then
				worldY = self.getWorldY_call()
			else
				local p = self:convertToWorldSpace(cc.p(0, 0))
				worldY = p.y
			end

			local y = nil

			if dic.eh then
				y = dic.eh - worldY
			else
				y = display.height - worldY - self:geth() - 120
			end

			if y > 0 then
				if self.params.keyboardEx then
					y = y + self.params.keyboardEx.get():geth()
				end

				if self.show_call then
					self.show_call(dic.duration, y, worldY)
				else
					display.getRunningScene():stopAllActions()
					display.getRunningScene():moveTo(dic.duration, 0, y)

					if self.params.keyboardEx then
						self.params.keyboardEx.get():pos(0, worldY)
					end
				end
			end
		end
	elseif dic.type == "keyboardWillHide" then
		if not self.donotMove then
			if self.hide_call then
				self.hide_call(dic.duration)
			else
				display.getRunningScene():stopAllActions()
				display.getRunningScene():moveTo(dic.duration, 0, 0)
			end
		end
	elseif dic.type == "insertText" then
		if dic.text == "\n" or (device.platform == "mac" or device.platform == "windows") and dic.text == "\\" then
			self:stopInput()

			if self.return_call then
				self.return_call()
			end

			return
		end

		local len = #self.content
		local strs = utf8strs(dic.text)

		for i, v in ipairs(strs) do
			self.content[#self.content + 1] = v
		end

		if self.params.checkCLen then
			local newContent = {}
			local cnt = 0

			for i, v in ipairs(self.content) do
				local wordLen = type(v) == "string" and ycFunction:getStringLenWithAscii(v) or 2

				if self.maxLen < cnt + wordLen then
					break
				end

				cnt = cnt + wordLen
				newContent[#newContent + 1] = v
			end

			self.content = newContent
		elseif self.maxLen < #self.content then
			for i = self.maxLen + 1, #self.content do
				self.content[i] = nil
			end
		end

		if #self.content == len then
			return
		end

		if self.password then
			local showstr = self:getStarText(len) .. dic.text

			self:uptLabelM(showstr)

			if self.passwordHandle then
				scheduler.unscheduleGlobal(self.passwordHandle)
			end

			self.passwordHandle = scheduler.performWithDelayGlobal(function ()
				if self.passwordHandle then
					scheduler.unscheduleGlobal(self.passwordHandle)

					self.passwordHandle = nil
				end

				self:uptLabelM()
				self:uptCursor()
			end, 1)
		else
			self:uptLabelM()
		end

		self:uptCursor()
	elseif dic.type == "deleteBackward" and #self.content > 0 then
		self.content[#self.content] = nil

		self:uptLabelM()
		self:uptCursor()
	end
end

function input:getStarText(len)
	if len > 0 then
		local tmp = ""

		for i = 1, len do
			tmp = tmp .. "*"
		end

		return tmp
	end

	return ""
end

function input:uptLabelMPos()
	self.label:pos(self:getw() < self.label.widthCnt and self:getw() - self.label.widthCnt or 0, self.label:getPositionY())
end

function input:uptLabelM(text)
	self.label:clear():nextLine()

	if text then
		self.label:addLabel(text)
		self:uptLabelMPos()

		return
	end

	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. (self.password and "*" or v)
		else
			if str ~= "" then
				self.label:addLabel(str)
			end

			str = ""

			if v.type == "emoji" then
				self.label:addEmoji(v.tex)
			elseif v.type == "label" then
				self.label:addLabel(v.text, v.color, nil, v.strokeColor)
			end
		end
	end

	if str ~= "" then
		self.label:addLabel(str)
	end

	self:uptLabelMPos()
	self:uptCursor()
end

function input:addEmoji(tex, content)
	if #self.content < self.maxLen then
		self.content[#self.content + 1] = {
			type = "emoji",
			tex = tex,
			content = content
		}

		self:uptLabelM()
	end
end

function input:addLabel(text, color, strokeColor, content)
	if #self.content < self.maxLen then
		self.content[#self.content + 1] = {
			type = "label",
			text = text,
			color = color,
			strokeColor = strokeColor,
			content = content
		}

		self:uptLabelM()
	end
end

function input:setText(text)
	self.content = utf8strs(text)

	self:uptLabelM()
end

function input:getText()
	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. v
		else
			str = str .. (v.content or v.text or "")
		end
	end

	return str
end

function input:getRichText()
	local ret = {}
	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. (self.password and "*" or v)
		else
			if str ~= "" then
				ret[#ret + 1] = str
			end

			str = ""
			ret[#ret + 1] = {
				v.content or v.text or ""
			}
		end
	end

	if str ~= "" then
		ret[#ret + 1] = str
	end

	return ret
end

function input:getTextForListenner()
	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. v
		else
			str = str .. "我"
		end
	end

	return str
end

function input:setString(...)
	self:setText(...)
end

function input:getString()
	return self:getText()
end

function input:clear()
	self:setText("")
end

function input:isInputting()
	return self.inputting
end

function input:showMask(b)
	if self.mask then
		self.mask:removeSelf()

		self.mask = nil
	end

	if b then
		self.mask = display.newNode():addto(display.getRunningScene(), an.z.input):anchor(0.5, 0.5):center():size(display.width, display.height)

		self.mask:setTouchEnabled(true)
		self.mask:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				self:stopInput()
			end
		end)
	end
end

function input:showTestKeyboard(b)
	if device.platform ~= "windows" and device.platform ~= "mac" then
		return
	end

	if b == (self.testKeyboard ~= nil) then
		return
	end

	if b then
		local scene = display.getRunningScene()
		self.testKeyboard = display.newColorLayer(cc.c4b(255, 0, 0, 128)):size(display.width, testh):add2(scene, an.z.input)

		self.testKeyboard:runForever(transition.sequence({
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function ()
				self.testKeyboard:pos(0, -scene:getPositionY())
			end)
		}))
		an.newLabel("软键盘", 30, 2):anchor(0.5, 0.5):pos(self.testKeyboard:centerPos()):add2(self.testKeyboard)

		return
	end

	self.testKeyboard:removeSelf()

	self.testKeyboard = nil
end

function input:checkBgShow(b)
	if not self.bg then
		return
	end

	if self.bgIsPressShow and not b then
		self.bg:hide()
	else
		self.bg:show()
	end
end

function input:showCursor(isshow)
	self.cursor:stopAllActions()
	self.cursor:setVisible(isshow)

	if isshow then
		self.cursor:run(cc.RepeatForever:create(transition.sequence({
			cc.Hide:create(),
			cc.DelayTime:create(0.3),
			cc.Show:create(),
			cc.DelayTime:create(0.3)
		})))
	end
end

function input:uptCursor()
	self.cursor:pos(math.min(self.label.widthCnt, self:getw()), self.cursor:getPositionY())
end

function input:showTip(isshow)
	if not self.params.tip then
		return
	end

	if not self.tip then
		self.tip = an.newLabel(unpack(self.params.tip)):anchor(0.5, 0.5):pos(self:centerPos()):add2(self)
	end

	self.tip:setVisible(isshow and #self.content == 0)
end

function input:setKeyboardVisable(b)
	if b then
		self.listener:attachWithIME()
	else
		self.listener:detachWithIME()
	end

	self:showTestKeyboard(b)
	self:keyboardVisableCallback(b)
end

function input:keyboardVisableCallback(b)
	if b then
		if device.platform == "android" then
			luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "getKeyboardHeight", {
				function (height)
					if not self.inputting then
						return
					end

					height = tonumber(height) or 0

					if height == 0 then
						self:stopInput()
					else
						self:callback({
							type = "keyboardWillShow",
							duration = 0.3,
							eh = height / display.contentScaleFactor
						})
					end
				end
			})
		elseif device.platform == "windows" or device.platform == "mac" then
			self:callback({
				type = "keyboardWillShow",
				duration = 0.3,
				eh = testh
			})
		end
	else
		self:callback({
			type = "keyboardWillHide",
			duration = 0.3
		})

		if device.platform == "android" then
			luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "cancelGetKeyboardHeight")
		end
	end
end

function input:startInput()
	self.inputting = true

	self:checkBgShow(true)
	self:showMask(true)
	self:showTestKeyboard(true)
	self:showCursor(true)
	self:showTip(false)
	self:uptCursor()
	self.listener:setContentText(self:getTextForListenner())
	self.listener:attachWithIME()
	self:keyboardVisableCallback(true)

	if self.start_call then
		self.start_call()
	end
end

function input:stopInput()
	self.inputting = false

	self:checkBgShow(false)
	self:showMask(false)
	self:showTestKeyboard(false)
	self:showCursor(false)
	self:showTip(true)
	self.listener:setContentText(self:getTextForListenner())
	self.listener:detachWithIME()

	if self.params.keyboardEx then
		self.params.keyboardEx:remove()
	end

	self:keyboardVisableCallback(false)

	if self.stop_call then
		self.stop_call()
	end
end

return input
