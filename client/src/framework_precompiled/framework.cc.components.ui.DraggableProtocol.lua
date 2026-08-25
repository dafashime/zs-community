local Component = cc.Component
local DraggableProtocol = class("DraggableProtocol", Component)

function DraggableProtocol:ctor()
	DraggableProtocol.super.ctor(self, "DraggableProtocol")
end

function DraggableProtocol:setDraggableEnable(bEnable)
	if bEnable then
		self.target_:setTouchEnabled(true)
		self.target_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			return self:dragOnTouch_(event)
		end)
	else
		self.target_:setTouchEnabled(false)
	end

	return self.target_
end

function DraggableProtocol:exportMethods()
	self:exportMethods_({
		"setDraggableEnable"
	})

	return self.target_
end

function DraggableProtocol:dragOnTouch_(event)
	local boundingBox = self.target_:getCascadeBoundingBox()

	if event.name == "began" and not cc.rectContainsPoint(boundingBox, cc.p(event.x, event.y)) then
		printInfo("DraggableProtocol - touch didn't in viewRect")

		return false
	end

	if event.name == "began" then
		return true
	elseif event.name == "moved" then
		local posX, posY = self.target_:getPosition()

		self.target_:setPosition(posX + event.x - event.prevX, posY + event.y - event.prevY)
	elseif event.name == "ended" then
		-- Nothing
	end
end

return DraggableProtocol
