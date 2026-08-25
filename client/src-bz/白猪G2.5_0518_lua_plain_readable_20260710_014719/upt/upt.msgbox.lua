local msgbox = class("upt_msgbox", function()
	return display.newNode()
end)

function msgbox:ctor(text, callback)
	self:size(display.width, display.height):addTo(display.getRunningScene(), 70001)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
		return
	end)

	local bg = display.newSprite("public/msgbox.png"):center():addTo(self)

	display.newTTFLabel({
		x = 20,
		size = 18,
		text = text,
		y = bg:getContentSize().height - 20,
		dimensions = cc.size(400, 170)
	}):addTo(bg):setAnchorPoint(cc.p(0, 1))

	local ok = cc.ui.UIPushButton.new({
		pressed = "public/ok2.png",
		normal = "public/ok1.png"
	}):addTo(bg)

	ok:setAnchorPoint(1, 0)
	ok:pos(bg:getContentSize().width - 120, 20)
	ok:onButtonClicked(function()
		callback(true)
	end)
	ok:updateButtonImage_()

	local cancel = cc.ui.UIPushButton.new({
		pressed = "public/cancel2.png",
		normal = "public/cancel1.png"
	}):addTo(bg)

	cancel:setAnchorPoint(1, 0)
	cancel:pos(bg:getContentSize().width - 20, 20)
	cancel:onButtonClicked(function()
		callback()
	end)
	cancel:updateButtonImage_()
end

return msgbox
