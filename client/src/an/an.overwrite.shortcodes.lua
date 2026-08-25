local c = cc
local Node = c.Node

function Node:addto(target, zorder, tag)
	target:addChild(self, zorder or 0, tag or 0)

	return self
end

function Node:add2(target, zorder, tag)
	target:addChild(self, zorder or 0, tag or 0)

	return self
end

function Node:anchor(x, y)
	self:setAnchorPoint(cc.p(x, y))

	return self
end

function Node:scaleX(scale)
	self:setScaleX(scale)

	return self
end

function Node:scalex(scale)
	self:setScaleX(scale)

	return self
end

function Node:scaleY(scale)
	self:setScaleY(scale)

	return self
end

function Node:scaley(scale)
	self:setScaleY(scale)

	return self
end

function Node:fit()
	self:setScaleX(display.width / self:getContentSize().width)
	self:setScaleY(display.height / self:getContentSize().height)

	return self
end

function Node:run(action)
	self:runAction(action)

	return self
end

function Node:runForever(action)
	self:runAction(cc.RepeatForever:create(action))

	return self
end

function Node:runs(actions)
	local prev = actions[1]

	for i = 2, #actions do
		prev = cc.Sequence:create(prev, actions[i])
	end

	self:runAction(prev)

	return self, prev
end

function Node:runsAtSameTime(actions)
	local prev = actions[1]

	for i = 2, #actions do
		prev = cc.Spawn:create(prev, actions[i])
	end

	self:runAction(prev)

	return self
end

function Node:getw()
	return self:getContentSize().width
end

function Node:geth()
	return self:getContentSize().height
end

function Node:centerPos()
	return self:getw() / 2, self:geth() / 2
end

function Node:posAdd(x, y)
	return self:pos(self:getPositionX() + x, self:getPositionY() + y)
end

function Node:sizeScale(size, scale)
	return self:size(size.width * scale, size.height * scale)
end

function Node:enableClick(func, params)
	params = params or {}

	if params.size and tolua.type(self) ~= "cc.Label" then
		local pos = params.pos or cc.p(self:getw() / 2, self:geth() / 2)
		local anchor = params.anchor or cc.p(0.5, 0.5)

		display.newNode():size(params.size):anchor(anchor):pos(pos.x, pos.y):add2(self)
	end

	local function click(x, y)
		func(x, y)
	end

	local beganPos, beganTouchPos, hasDrag = nil

	if params.support == "scroll" then
		self:setTouchSwallowEnabled(false)
	end

	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if params.support == "easy" then
				click(event.x, event.y)
			elseif params.support == "drag" or params.support == "scroll" then
				beganPos = cc.p(self:getPosition())
				beganTouchPos = cc.p(event.x, event.y)
				hasDrag = false
			end

			if params.ani then
				self:runs({
					cc.ScaleTo:create(0.1, 1.5),
					cc.ScaleTo:create(0.1, 1)
				})
			end

			return true
		elseif event.name == "moved" then
			if params.support == "drag" or params.support == "scroll" then
				if math.abs(beganTouchPos.x - event.x) > 10 or math.abs(beganTouchPos.y - event.y) > 10 then
					hasDrag = true
				end

				if params.support == "drag" and hasDrag then
					self:pos(event.x - beganTouchPos.x + beganPos.x, event.y - beganTouchPos.y + beganPos.y)

					if params.call_drag_moving then
						params.call_drag_moving(event)
					end
				end
			end
		elseif event.name == "ended" then
			local touchIn = self:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

			if params.support == "easy" then
				-- Nothing
			elseif params.support == "drag" then
				if hasDrag then
					if params.call_drag_end then
						params.call_drag_end(event)
					end
				elseif touchIn then
					click(event.x, event.y)
				end
			elseif params.support == "scroll" then
				if not hasDrag and touchIn then
					click(event.x, event.y)
				end
			elseif touchIn then
				click(event.x, event.y)
			end
		end
	end)

	return self
end

function Node:debug()
	self:enableDebugdraw()

	return self
end

local Sprite = c.Sprite

function Sprite:setTex(filename)
	local tex = nil

	if type(filename) == "string" then
		tex = cc.Director:getInstance():getTextureCache():addImage(filename)
	else
		tex = filename
	end

	if tex then
		local size = tex:getContentSize()

		self:setTexture(tex)
		self:setTextureRect(cc.rect(0, 0, size.width, size.height))
	end

	return self
end

local Label = c.Label
Label.setText = Label.setString
