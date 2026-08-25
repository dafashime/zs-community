local cusTipsBar = class("cusTipsBar", function()
	return display.newNode()
end)

function cusTipsBar:ctor(frameName)
	local background = display.newScale9Sprite(res.getframe2(frameName))

	background:add2(self)

	self.clipSize = background:getContentSize()

	if self.clipSize.width > 2 and self.clipSize.height > 2 then
		background:setAnchorPoint(cc.p(0, 0))
		background:setPosition(-self.clipSize.width * 0.5, -self.clipSize.height * 0.5)

		local rect = cc.rect(0, 0, self.clipSize.width, self.clipSize.height)

		self.clipNode = display.newClippingRegionNode()

		self.clipNode:setClippingRegion(rect)
		self.clipNode:setAnchorPoint(cc.p(0, 0))
		self.clipNode:setPosition(-self.clipSize.width * 0.5, -self.clipSize.height * 0.5 + 4)
		self:pos(display.cx, display.cy - 100)
		self.clipNode:add2(self)

		self.tailLabel = nil
		self.msg = nil
		self.autoVisible = true
		self.isRunHideAction = false
		self.border = 1

		self:setVisible(false)
		self:setAutoVisible(true)
	end
end

function cusTipsBar:addMsg(msg)
	if not self.clipNode then
		main_scene.ui:tip("no background file path")

		return false
	end

	self.msg = msg

	self:startShowMsg()

	return true
end

function cusTipsBar:setBorder(border)
	self.border = border
end

function cusTipsBar:setPos(pos, pos2)
	self:pos(pos, pos2)
end

function cusTipsBar:setAutoVisible(autoVisible)
	if self.autoVisible == autoVisible then
		return
	end

	self.autoVisible = autoVisible

	self:updateVisible()
end

function cusTipsBar:startShowMsg()
	self:updateVisible()

	if not self.msg then
		return
	end

	self:showMsg(self.msg)

	self.msg = nil

	local action = cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
		self:startShowMsg()
	end))

	self:runAction(action)
end

function cusTipsBar:showMsg(message)
	local clipWidth = self.clipSize.width * 0.5
	local centerY = self.clipSize.height * 0.5

	if self.tailLabel and tolua.cast(self.tailLabel, "cc.Node") then
		self.tailLabel:stopAllActions()
		self.tailLabel:removeSelf()

		self.tailLabel = nil
	end

	if not c_createColorLabel then
		os.exit()
	end

	local tailLabel = c_createColorLabel(message, def.clrTipsBar.fontColor or display.COLOR_WHITE, self.clipSize.width, def.clrTipsBar.fontSize or 16):add2(self.clipNode, 1)

	tailLabel:setAnchorPoint({
		x = 0,
		y = 0.5
	})
	tailLabel:setPosition({
		x = clipWidth - tailLabel.widthCnt / 2,
		y = centerY
	})

	self.tailLabel = tailLabel
end

function cusTipsBar:updateVisible()
	if self.autoVisible then
		if self.msg then
			self:runShowAction()
		else
			self:runHideAction()
		end
	else
		self:runShowAction()
	end
end

function cusTipsBar:runHideAction()
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
		self.tailLabel:clear()
	end

	self:stopAllActions()
	self:setCascadeOpacityEnabled(true)
	self:setOpacity(255)
	self:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(onComplete)))

	if self.tailLabel and tolua.cast(self.tailLabel, "cc.Node") then
		self.tailLabel:stopAllActions()
		self.tailLabel:setCascadeOpacityEnabled(true)
		self.tailLabel:setOpacity(255)
		self.tailLabel:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(onComplete)))
	end
end

function cusTipsBar:runShowAction()
	self.isRunHideAction = false

	self:stopAllActions()
	self:setOpacity(255)

	if self.tailLabel and tolua.cast(self.tailLabel, "cc.Node") then
		self.tailLabel:stopAllActions()
		self.tailLabel:setOpacity(255)
	end

	self:setVisible(true)
	self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.01, 1.8), cc.ScaleTo:create(0.15, 0.9), cc.ScaleTo:create(0.05, 1)))
end

return cusTipsBar
