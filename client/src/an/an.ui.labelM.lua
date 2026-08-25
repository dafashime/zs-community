local label = import(".label")
local labelM = class("an.labelM", function ()
	return display.newNode()
end)

table.merge(labelM, {
	font,
	fontSize,
	maxWidth,
	stokeSize,
	wordSize,
	lines,
	widthCnt,
	scroll,
	manualNextLine,
	centerShow,
	clickLine_call,
	doubleClickLine_call,
	maxLine
})

function labelM:ctor(maxWidth, fontSize, stokesize, params)
	fontSize = fontSize and math.round(fontSize)
	params = params or {}
	self.font = params.font or display.DEFAULT_TTF_FONT
	self.fontSize = fontSize or display.DEFAULT_TTF_FONT_SIZE
	self.scroll = params.scroll
	self.manualNextLine = params.manual
	self.clickLine_call = params.clickLine_call
	self.doubleClickLine_call = params.doubleClickLine_call
	self.centerShow = params.center
	self.maxLine = params.maxLine
	self.sd = params.sd
	self.bufferChannel = params.bufferChannel
	self.maxWidth = maxWidth
	self.stokeSize = stokesize
	self.lines = {}
	self.wordSize = cc.size(label.string2size("我", self.font, self.fontSize, stokesize))
	self.widthCnt = maxWidth + 1
end

function labelM:clear()
	for i, v in ipairs(self.lines) do
		v:removeSelf()
	end

	self.lines = {}
	self.widthCnt = self.maxWidth + 1

	if self.scroll then
		self.scroll:setScrollSize(self.scroll:getw(), self.scroll:geth())
		self:anchor(0, 1):pos(0, self.scroll:getScrollSize().height)
	end

	return self
end

function labelM:setFontSize(fontSize)
	self.fontSize = math.round(fontSize)
	self.wordSize = cc.size(label.string2size("我", self.font, self.fontSize, self.stokeSize))
end

function labelM:findVoiceBubbleForMsgID(msgID)
	for i, v in ipairs(self.lines) do
		for i2, v2 in ipairs(v:getChildren()) do
			if v2.__cname == "an.voiceBubble" and v2.msgID == msgID then
				return v2
			end
		end
	end
end

function labelM:findNodeForClassNameAndTag(name, tag)
	for i, v in ipairs(self.lines) do
		for i2, v2 in ipairs(v:getChildren()) do
			if v2.__cname == name and v2.tag == tag then
				return v2
			end
		end
	end
end

function labelM:addEmojiForConvert(emoji)
	if self.maxWidth < self.widthCnt + self.wordSize.width then
		self:nextLine()
	end

	self:addSubLabel_(emoji, display.COLOR_WHITE, bgColor, nil, nil, 0)
end

function labelM:addEmoji(tex)
	local node = display.newSprite(tex)

	node:scale(self.wordSize.height / node:geth())
	self:addNode(node, 1)
end

function labelM:addVoice(bgkey, dur, msgID, state, readed, clickCallback)
	local voiceBubble = an.newVoiceBubble(self.wordSize.height, bgkey, dur, msgID, state, readed)

	if not self.manualNextLine and self.maxWidth < self.widthCnt + voiceBubble:getw() then
		self:nextLine()
	end

	if clickCallback then
		voiceBubble:enableClick(clickCallback)
	end

	voiceBubble:anchor(0, 0.5):pos(self.widthCnt, self.wordSize.height / 2):add2(self.lines[#self.lines])

	self.widthCnt = self.widthCnt + voiceBubble:getw()

	return voiceBubble
end

function labelM:insertNodeToFront(node, line, tag)
	local lineNum = #self.lines

	self:nextLine()
	self:addNode(node, line, tag)

	local newLines = {}

	for i = lineNum + 1, #self.lines do
		newLines[#newLines + 1] = self.lines[i]
		self.lines[i] = nil
	end

	for i = #newLines, 1, -1 do
		table.insert(self.lines, 1, newLines[i])
	end

	local y = 0

	for i = #self.lines, 1, -1 do
		local v = self.lines[i]

		v:pos(v:getPositionX(), y)

		y = y + self.wordSize.height
	end
end

function labelM:addNode(node, line, tag)
	if not self.manualNextLine and self.maxWidth < self.widthCnt + node:getw() * node:getScale() then
		self:nextLine()
	end

	node.tag = tag

	node:anchor(0, 1):pos(self.widthCnt, self.wordSize.height):add2(self.lines[#self.lines])

	self.widthCnt = self.widthCnt + node:getw() * node:getScale()

	for i = 2, line do
		self:nextLine()
	end
end

function labelM:addLabel(text, color, bgColor, strokeColor, clickCallback, params)
	local strs = string.split(text, "\n")

	for i, v in ipairs(strs) do
		if v ~= "" then
			if self.manualNextLine then
				self:addSubLabel_(v, color, bgColor, strokeColor, clickCallback, params)
			else
				self:addLabel_(v, color, bgColor, strokeColor, clickCallback, params)
			end
		end

		if i < #strs then
			self:nextLine()
		end
	end

	return self
end

function labelM:nextLine(params)
	for i, v in ipairs(self.lines) do
		v:pos(v:getPositionX(), v:getPositionY() + self.wordSize.height)
	end

	local line = display.newNode():size(self.maxWidth, self.wordSize.height):addto(self)

	if self.clickLine_call or self.doubleClickLine_call then
		if self.doubleClickLine_call then
			local y, handler, clicked = nil

			local function click()
				if clicked then
					if self.doubleClickLine_call then
						self.doubleClickLine_call(params)
					end
				elseif self.clickLine_call then
					self.clickLine_call(params)
				end

				clicked = nil
				handler = nil
			end

			line:setTouchEnabled(true)
			line:setTouchSwallowEnabled(false)
			line:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				local touchInBtn = line:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

				if event.name == "began" then
					if handler then
						clicked = true

						return false
					end

					y = event.y

					return true
				elseif event.name == "ended" and math.abs(event.y - y) < line:geth() then
					handler = scheduler.performWithDelayGlobal(click, 0.25)
				end
			end)
		else
			local y = nil

			line:setTouchEnabled(true)
			line:setTouchSwallowEnabled(false)
			line:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				local touchInBtn = line:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

				if event.name == "began" then
					y = event.y

					return true
				elseif event.name == "ended" and math.abs(event.y - y) < line:geth() then
					self.clickLine_call(params)
				end
			end)
		end
	end

	self.lines[#self.lines + 1] = line

	if self.maxLine and self.maxLine < #self.lines then
		self.lines[1]:removeSelf()
		table.remove(self.lines, 1)
	end

	self.widthCnt = 0
	local h = 0

	for i, v in ipairs(self.lines) do
		h = h + v:geth()
	end

	self:size(self.maxWidth, h)

	if self.scroll then
		self.scroll:setScrollSize(self:getw(), self:geth())
		self:anchor(0, 1):pos(0, self.scroll:getScrollSize().height)
	end

	return self
end

function labelM:setCurLineWidthCnt(cnt)
	self.widthCnt = cnt
end

function labelM:isNotOutstrip_(text, addChar)
	addChar = addChar or 0

	return self.widthCnt + (string.utf8len(text) + addChar) * self.wordSize.width <= self.maxWidth
end

function labelM:addLabel_(text, color, bgColor, strokeColor, clickCallback, params)
	local words = utf8strs(text)

	if self.widthCnt + #words * self.wordSize.width <= self.maxWidth then
		return self:addSubLabel_(text, color, bgColor, strokeColor, clickCallback, params)
	end

	if self.maxWidth < self.widthCnt + label.string2size(words[1], self.font, self.fontSize, self.stokeSize) then
		self:nextLine()
	end

	local tmp = {}
	local i = 1

	while i <= #words do
		tmp[#tmp + 1] = words[i]

		if self.widthCnt + (#tmp + 1) * self.wordSize.width >= self.maxWidth then
			local tmpStr = table.concat(tmp)
			local tmpCnt = label.string2size(tmpStr, self.font, self.fontSize, self.stokeSize)

			while self.widthCnt + tmpCnt < self.maxWidth do
				i = i + 1

				if i > #words then
					break
				end

				tmp[#tmp + 1] = words[i]
				tmpStr = table.concat(tmp)
				tmpCnt = tmpCnt + label.string2size(words[i], self.font, self.fontSize, self.stokeSize)
			end

			if i <= #words then
				i = i - 1
				tmp[#tmp] = nil
				tmpStr = table.concat(tmp)
			end

			self:addSubLabel_(tmpStr, color, bgColor, strokeColor, clickCallback, params)

			if i < #words then
				self:nextLine()
			end

			tmp = {}
		end

		i = i + 1
	end

	if #tmp > 0 then
		self:addSubLabel_(table.concat(tmp), color, bgColor, strokeColor, clickCallback, params)
	end
end

function labelM:addSubLabel_(text, color, bgColor, strokeColor, clickCallback, stokeSize, params)
	local offY = -3
	local l = label.new(text, self.fontSize, stokeSize or self.stokeSize, {
		color = color,
		sc = strokeColor,
		bufferChannel = self.bufferChannel,
		sd = self.sd
	}):addTo(self.lines[#self.lines])

	if self.centerShow then
		l:anchor(0.5, 0):pos(self:getw() / 2, offY)
	else
		l:pos(self.widthCnt, offY)
	end

	if params and params.tag then
		l:setTag(params.tag)
	end

	if bgColor then
		local color = display.newColorLayer(bgColor):size(l:getContentSize()):addTo(self.lines[#self.lines], -1)

		if self.centerShow then
			color:anchor(0.5, 0):pos(self:getw() / 2, offY)
		else
			color:pos(self.widthCnt, offY)
		end
	end

	if clickCallback then
		local x, y = l:getPosition()
		local sz = l:getContentSize()
		local callback, noUnderLine, easyTouch, size, ani = nil

		if type(clickCallback) == "table" then
			callback = clickCallback.callback
			noUnderLine = clickCallback.noUnderLine
			easyTouch = clickCallback.easyTouch
			ani = clickCallback.ani

			if ani then
				l:anchor(0.5, 0.5):pos(x + sz.width / 2, y + sz.height / 2)

				x, y = l:getPosition()
			end

			if clickCallback.addTouchSizeX or clickCallback.addTouchSizeY then
				size = cc.size(sz.width + (clickCallback.addTouchSizeX or 0), sz.height + (clickCallback.addTouchSizeY or offY))
			end
		else
			callback = clickCallback
		end

		l:enableClick(callback, {
			ani = true,
			size = size
		})

		if not noUnderLine then
			color = color or display.COLOR_WHITE
			local ac = l:getAnchorPoint()

			display.newColorLayer(cc.c4b(color.r, color.g, color.b, 255)):pos(x - sz.width * ac.x, y - sz.height * ac.y + 2):size(sz.width, 1):addto(self.lines[#self.lines], 1)
		end
	end

	self.widthCnt = self.widthCnt + l:getContentSize().width
end

return labelM
