local parser = import(".Parser")
local AlertBar = class("AlertBar", function()
	return display.newNode()
end)

function AlertBar:ctor(frameName, widthScale, height, yOffset, newStyle, color, fontSize)
	local background = display.newScale9Sprite(res.getframe2(frameName), 0, 0, cc.size(display.width * widthScale, height))

	background:add2(self)

	self.clipSize = background:getContentSize()
	self.newStyle = newStyle
	self.defcolor = _stringToCorlor(color)
	self.defsize = tonumber(fontSize)

	background:setAnchorPoint(cc.p(0, 0))
	background:setPosition(-self.clipSize.width * 0.5, -self.clipSize.height * 0.5)

	self.clipSize.width = self.clipSize.width - 20

	local rect = cc.rect(0, 0, self.clipSize.width, self.clipSize.height)

	self.clipNode = display.newClippingRegionNode()

	self.clipNode:setClippingRegion(rect)
	self.clipNode:setAnchorPoint(cc.p(0, 0))
	self.clipNode:setPosition(-self.clipSize.width * 0.5, -self.clipSize.height * 0.5 + 4)
	self:pos(display.cx, display.cy + yOffset)
	self.clipNode:add2(self)

	self.tailLabel = nil
	self.totalMsgQue = {}
	self.autoVisible = nil
	self.isRunHideAction = false

	self:setVisible(false)
	self:setAutoVisible(true)
end

function AlertBar:addMsg(message, queueOnly)
	if message == nil or message == "" then
		return
	end

	if #self.totalMsgQue >= 30 then
		print("滚动效果过多")

		return
	end

	table.insert(self.totalMsgQue, message)

	if queueOnly then
		return
	end

	self:startShowMsg()
end

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function AlertBar:startShowMsg()
	if self.tailLabel then
		return
	end

	self:updateVisible()

	if #self.totalMsgQue == 0 then
		return
	end

	for _, totalMsgQue in pairs(self.totalMsgQue) do
		self:showMsg(totalMsgQue, #self.totalMsgQue > 2)
	end

	self.totalMsgQue = {}
end

function AlertBar:setAutoVisible(autoVisible)
	if self.autoVisible == autoVisible then
		return
	end

	self.autoVisible = autoVisible

	self:updateVisible()
end

function AlertBar:showMsg(message, options)
	local number = 100
	local clipWidth = self.clipSize.width
	local centerY = self.clipSize.height * 0.5

	if self.tailLabel ~= nil then
		clipWidth = self.tailLabel.widthCnt + self.tailLabel:getPositionX()
	end

	local x = clipWidth + number
	local tailLabel

	if not self.newStyle then
		local parsedItems = parser:parse(message)

		if #parsedItems == 0 then
			print(string.format("格式不合法解析失败: %s", message))

			return
		end

		tailLabel = an.newLabelM(1000000, parsedItems[1].size, 1):add2(self.clipNode, 1)

		tailLabel:clear():nextLine()

		for _, item in pairs(parsedItems) do
			tailLabel:addLabel(item.str, item.color)
		end
	else
		if not c_createColorLabel then
			os.exit()
		end

		tailLabel = c_createColorLabel(message, self.defcolor, 1000000, self.defsize):add2(self.clipNode, 1)
	end

	tailLabel:setAnchorPoint({
		x = 0,
		y = 0.5
	})
	tailLabel:setPosition({
		x = x,
		y = centerY
	})

	self.tailLabel = tailLabel

	local textWidth = tailLabel.widthCnt
	local duration = (textWidth + x) / 200

	local function onComplete()
		if self.tailLabel == tailLabel then
			self.tailLabel = nil

			local action = cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
				self:startShowMsg()
			end))

			self:runAction(action)
		end
	end

	if not options then
		duration = duration * 2
	end

	local action = cc.Sequence:create(cc.MoveTo:create(duration, {
		x = -textWidth,
		y = centerY
	}), cc.CallFunc:create(onComplete), cc.RemoveSelf:create())

	tailLabel:runAction(action)
end

function AlertBar:updateVisible()
	if self.autoVisible then
		if #self.totalMsgQue > 0 then
			self:runShowAction()
		else
			self:runHideAction()
		end
	else
		self:runShowAction()
	end
end

function AlertBar:runHideAction()
	if self:isVisible() == false then
		return
	end

	if self.isRunHideAction then
		return
	end

	self.isRunHideAction = true

	local function onComplete()
		self.isRunHideAction = false

		self:setVisible(false)
	end

	self:stopAllActions()
	self:setCascadeOpacityEnabled(true)
	self:setOpacity(255)
	self:runAction(cc.Sequence:create(cc.FadeOut:create(1.5), cc.CallFunc:create(onComplete)))
end

function AlertBar:runShowAction()
	self.isRunHideAction = false

	self:stopAllActions()
	self:setOpacity(255)
	self:setVisible(true)
end

return AlertBar
