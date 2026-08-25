local UILoadingBar = class("UILoadingBar", function ()
	local node = cc.ClippingRegionNode:create()

	return node
end)
UILoadingBar.DIRECTION_LEFT_TO_RIGHT = 0
UILoadingBar.DIRECTION_RIGHT_TO_LEFT = 1

function UILoadingBar:ctor(params)
	if params.scale9 then
		self.scale9 = true
		local scale9sp = ccui.Scale9Sprite or cc.Scale9Sprite

		if string.byte(params.image) == 35 then
			self.bar = scale9sp:createWithSpriteFrameName(string.sub(params.image, 2), params.capInsets)
		else
			self.bar = scale9sp:create(params.capInsets, params.image)
		end

		self:setClippingRegion(cc.rect(0, 0, params.viewRect.width, params.viewRect.height))
	else
		self.bar = display.newSprite(params.image)
	end

	self.direction_ = params.direction or UILoadingBar.DIRECTION_LEFT_TO_RIGHT

	self:setViewRect(params.viewRect)
	self.bar:setAnchorPoint(cc.p(0, 0))
	self.bar:setPosition(0, 0)
	self:setPercent(params.percent or 0)
	self:addChild(self.bar)

	self.args_ = {
		params
	}
end

function UILoadingBar:setPercent(percent)
	self.percent_ = percent
	local rect = cc.rect(self.viewRect_.x, self.viewRect_.y, self.viewRect_.width, self.viewRect_.height)
	local newWidth = rect.width * self.percent_ / 100
	rect.x = 0
	rect.y = 0

	if self.scale9 then
		self.bar:setPreferredSize(cc.size(newWidth, rect.height))

		if UILoadingBar.DIRECTION_LEFT_TO_RIGHT ~= self.direction_ then
			self.bar:setPosition(rect.width - newWidth, 0)
		end
	elseif UILoadingBar.DIRECTION_LEFT_TO_RIGHT == self.direction_ then
		rect.width = newWidth

		self:setClippingRegion(cc.rect(rect.x, rect.y, rect.width, rect.height))
	else
		rect.x = rect.x + rect.width - newWidth
		rect.width = newWidth

		self:setClippingRegion(cc.rect(rect.x, rect.y, rect.width, rect.height))
	end

	return self
end

function UILoadingBar:getPercent()
	return self.percent_
end

function UILoadingBar:setDirction(dir)
	self.direction_ = dir

	if UILoadingBar.DIRECTION_LEFT_TO_RIGHT ~= self.direction_ and self.bar.setFlippedX then
		self.bar:setFlippedX(true)
	end

	return self
end

function UILoadingBar:setViewRect(rect)
	self.viewRect_ = rect

	self.bar:setContentSize(rect.width, rect.height)

	return self
end

function UILoadingBar:createCloneInstance_()
	self.args_.viewRect = self.viewRect_
	self.args_.direction = self.direction_

	return UILoadingBar.new(unpack(self.args_))
end

return UILoadingBar
