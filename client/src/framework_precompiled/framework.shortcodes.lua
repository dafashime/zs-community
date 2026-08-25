local c = cc
local Node = c.Node

function Node:add(child, zorder, tag)
	self:addChild(child, zorder or child:getLocalZOrder(), tag or child:getTag())

	return self
end

function Node:addTo(target, zorder, tag)
	target:addChild(self, zorder or self:getLocalZOrder(), tag or self:getTag())

	return self
end

function Node:show()
	self:setVisible(true)

	return self
end

function Node:hide()
	self:setVisible(false)

	return self
end

local __setPosition = Node.setPosition

function Node:pos(x, y)
	__setPosition(self, x, y)

	return self
end

function Node:center()
	__setPosition(self, display.cx, display.cy)

	return self
end

function Node:scale(scale)
	self:setScale(scale)

	return self
end

function Node:rotation(r)
	self:setRotation(r)

	return self
end

function Node:size(width, height)
	if type(width) == "table" then
		self:setContentSize(width)
	else
		self:setContentSize(cc.size(width, height))
	end

	return self
end

function Node:opacity(opacity)
	self:setOpacity(opacity)

	return self
end

function Node:zorder(z)
	self:setLocalZOrder(z)

	return self
end

local Sprite = c.Sprite
Sprite.playOnce = Sprite.playAnimationOnce
Sprite.playForever = Sprite.playAnimationForever

function Sprite:displayFrame(frame)
	self:setSpriteFrame(frame)

	return self
end

function Sprite:flipX(b)
	self:setFlippedX(b)

	return self
end

function Sprite:flipY(b)
	self:setFlippedY(b)

	return self
end

local Layer = c.Layer

function Layer:onTouch(listener)
	if USE_DEPRECATED_EVENT_ARGUMENTS then
		self:addNodeEventListener(c.NODE_TOUCH_EVENT, function (event)
			return listener(event.name, event.x, event.y, event.prevX, event.prevY)
		end)
	else
		self:addNodeEventListener(c.NODE_TOUCH_EVENT, listener)
	end

	return self
end

function Layer:enableTouch(enabled)
	self:setTouchEnabled(enabled)

	return self
end

function Layer:onKeypad(listener)
	if USE_DEPRECATED_EVENT_ARGUMENTS then
		self:addNodeEventListener(c.KEYPAD_EVENT, function (event)
			return listener(event.name)
		end)
	else
		self:addNodeEventListener(c.KEYPAD_EVENT, listener)
	end

	return self
end

function Layer:enableKeypad(enabled)
	self:setKeypadEnabled(enabled)

	return self
end

function Layer:onAccelerate(listener)
	if USE_DEPRECATED_EVENT_ARGUMENTS then
		self:addNodeEventListener(c.ACCELERATE_EVENT, function (event)
			return listener(event.x, event.y, event.z, event.timestamp)
		end)
	else
		self:addNodeEventListener(c.ACCELERATE_EVENT, listener)
	end

	return self
end

function Layer:enableAccelerometer(enabled)
	self:setAccelerometerEnabled(enabled)

	return self
end

function Node:stop()
	self:stopAllActions()

	return self
end

function Node:fadeIn(time)
	self:runAction(cc.FadeIn:create(time))

	return self
end

function Node:fadeOut(time)
	self:runAction(cc.FadeOut:create(time))

	return self
end

function Node:fadeTo(time, opacity)
	self:runAction(cc.FadeTo:create(time, opacity))

	return self
end

function Node:moveTo(time, x, y)
	self:runAction(cc.MoveTo:create(time, cc.p(x or self:getPositionX(), y or self:getPositionY())))

	return self
end

function Node:moveBy(time, x, y)
	self:runAction(cc.MoveBy:create(time, cc.p(x or 0, y or 0)))

	return self
end

function Node:rotateTo(time, rotation)
	self:runAction(cc.RotateTo:create(time, rotation))

	return self
end

function Node:rotateBy(time, rotation)
	self:runAction(cc.RotateBy:create(time, rotation))

	return self
end

function Node:scaleTo(time, scale)
	self:runAction(cc.ScaleTo:create(time, scale))

	return self
end

function Node:scaleBy(time, scale)
	self:runAction(cc.ScaleBy:create(time, scale))

	return self
end

function Node:skewTo(time, sx, sy)
	self:runAction(cc.SkewTo:create(time, sx or self:getSkewX(), sy or self:getSkewY()))

	return self
end

function Node:skewBy(time, sx, sy)
	self:runAction(cc.SkewBy:create(time, sx or 0, sy or 0))

	return self
end

function Node:tintTo(time, r, g, b)
	self:runAction(cc.TintTo:create(time, r or 0, g or 0, b or 0))

	return self
end

function Node:tintBy(time, r, g, b)
	self:runAction(cc.TintBy:create(time, r or 0, g or 0, b or 0))

	return self
end
