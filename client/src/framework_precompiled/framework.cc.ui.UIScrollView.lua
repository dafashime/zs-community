local UIScrollView = class("UIScrollView", function ()
	return cc.ClippingRegionNode:create()
end)
UIScrollView.BG_ZORDER = -100
UIScrollView.TOUCH_ZORDER = -99
UIScrollView.DIRECTION_BOTH = 0
UIScrollView.DIRECTION_VERTICAL = 1
UIScrollView.DIRECTION_HORIZONTAL = 2

function UIScrollView:ctor(params)
	self.bBounce = true
	self.nShakeVal = 5
	self.direction = UIScrollView.DIRECTION_BOTH
	self.layoutPadding = {
		top = 0,
		left = 0,
		bottom = 0,
		right = 0
	}
	self.speed = {
		x = 0,
		y = 0
	}

	if not params then
		return
	end

	if params.viewRect then
		self:setViewRect(params.viewRect)
	end

	if params.direction then
		self:setDirection(params.direction)
	end

	if params.scrollbarImgH then
		self.sbH = display.newScale9Sprite(params.scrollbarImgH, 100):addTo(self)
	end

	if params.scrollbarImgV then
		self.sbV = display.newScale9Sprite(params.scrollbarImgV, 100):addTo(self)
	end

	self:setTouchType(params.touchOnContent or true)
	self:addBgColorIf(params)
	self:addBgGradientColorIf(params)
	self:addBgIf(params)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (...)
		self:update_(...)
	end)
	self:scheduleUpdate()

	self.args_ = {
		params
	}
end

function UIScrollView:addBgColorIf(params)
	if not params.bgColor then
		return
	end

	cc.LayerColor:create(params.bgColor):size(params.viewRect.width, params.viewRect.height):pos(params.viewRect.x, params.viewRect.y):addTo(self, UIScrollView.BG_ZORDER):setTouchEnabled(false)
end

function UIScrollView:addBgGradientColorIf(params)
	if not params.bgStartColor or not params.bgEndColor then
		return
	end

	local layer = cc.LayerGradient:create(params.bgStartColor, params.bgEndColor):size(params.viewRect.width, params.viewRect.height):pos(params.viewRect.x, params.viewRect.y):addTo(self, UIScrollView.BG_ZORDER):setTouchEnabled(false)

	layer:setVector(params.bgVector)
end

function UIScrollView:addBgIf(params)
	if not params.bg then
		return
	end

	local bg = nil

	if params.bgScale9 then
		bg = display.newScale9Sprite(params.bg, nil, nil, nil, params.capInsets)
	else
		bg = display.newSprite(params.bg)
	end

	bg:size(params.viewRect.width, params.viewRect.height):pos(params.viewRect.x + params.viewRect.width / 2, params.viewRect.y + params.viewRect.height / 2):addTo(self, UIScrollView.BG_ZORDER):setTouchEnabled(false)
end

function UIScrollView:setViewRect(rect)
	self:setClippingRegion(rect)

	self.viewRect_ = rect
	self.viewRectIsNodeSpace = false

	return self
end

function UIScrollView:getViewRect()
	return self.viewRect_
end

function UIScrollView:setLayoutPadding(top, right, bottom, left)
	if not self.layoutPadding then
		self.layoutPadding = {}
	end

	self.layoutPadding.top = top
	self.layoutPadding.right = right
	self.layoutPadding.bottom = bottom
	self.layoutPadding.left = left

	return self
end

function UIScrollView:setActualRect(rect)
	self.actualRect_ = rect
end

function UIScrollView:setDirection(dir)
	self.direction = dir

	return self
end

function UIScrollView:getDirection()
	return self.direction
end

function UIScrollView:setBounceable(bBounceable)
	self.bBounce = bBounceable

	return self
end

function UIScrollView:setTouchType(bTouchOnContent)
	self.touchOnContent = bTouchOnContent

	return self
end

function UIScrollView:resetPosition()
	if UIScrollView.DIRECTION_VERTICAL ~= self.direction then
		return
	end

	local x, y = self.scrollNode:getPosition()
	local bound = self.scrollNode:getCascadeBoundingBox()
	local disY = self.viewRect_.y + self.viewRect_.height - bound.y - bound.height
	y = y + disY

	self.scrollNode:setPosition(x, y)
end

function UIScrollView:isItemInViewRect(item)
	if type(item) ~= "userdata" then
		item = nil
	end

	if not item then
		print("UIScrollView - isItemInViewRect item is not right")

		return
	end

	local bound = item:getCascadeBoundingBox()

	return cc.rectIntersectsRect(self:getViewRectInWorldSpace(), bound)
end

function UIScrollView:setTouchEnabled(bEnabled)
	if not self.scrollNode then
		return
	end

	self.scrollNode:setTouchEnabled(bEnabled)

	return self
end

function UIScrollView:addScrollNode(node)
	self:addChild(node)

	self.scrollNode = node

	if not self.viewRect_ then
		self.viewRect_ = self.scrollNode:getCascadeBoundingBox()

		self:setViewRect(self.viewRect_)
	end

	node:setTouchSwallowEnabled(false)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
		return self:onTouchCapture_(event)
	end)
	self:addTouchNode()

	return self
end

function UIScrollView:getScrollNode()
	return self.scrollNode
end

function UIScrollView:onScroll(listener)
	self.scrollListener_ = listener

	return self
end

function UIScrollView:calcLayoutPadding()
	local boundBox = self.scrollNode:getCascadeBoundingBox()
	self.layoutPadding.left = boundBox.x - self.actualRect_.x
	self.layoutPadding.right = self.actualRect_.x + self.actualRect_.width - boundBox.x - boundBox.width
	self.layoutPadding.top = boundBox.y - self.actualRect_.y
	self.layoutPadding.bottom = self.actualRect_.y + self.actualRect_.height - boundBox.y - boundBox.height
end

function UIScrollView:update_(dt)
	self:drawScrollBar()
end

function UIScrollView:onTouchCapture_(event)
	if (event.name == "began" or event.name == "moved" or event.name == "ended") and self:isTouchInViewRect(event) then
		return true
	else
		return false
	end
end

function UIScrollView:onTouch_(event)
	if event.name == "began" and not self:isTouchInViewRect(event) then
		printInfo("UIScrollView - touch didn't in viewRect")

		return false
	end

	if event.name == "began" and self.touchOnContent then
		local cascadeBound = self.scrollNode:getCascadeBoundingBox()

		if not cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y)) then
			return false
		end
	end

	if event.name == "began" then
		self.prevX_ = event.x
		self.prevY_ = event.y
		self.bDrag_ = false
		local x, y = self.scrollNode:getPosition()
		self.position_ = {
			x = x,
			y = y
		}

		transition.stopTarget(self.scrollNode)
		self:callListener_({
			name = "began",
			x = event.x,
			y = event.y
		})
		self:enableScrollBar()

		self.scaleToWorldSpace_ = self:scaleToParent_()

		return true
	elseif event.name == "moved" then
		if self:isShake(event) then
			return
		end

		self.bDrag_ = true
		self.speed.x = event.x - event.prevX
		self.speed.y = event.y - event.prevY

		if self.direction == UIScrollView.DIRECTION_VERTICAL then
			self.speed.x = 0
		elseif self.direction == UIScrollView.DIRECTION_HORIZONTAL then
			self.speed.y = 0
		end

		self:scrollBy(self.speed.x, self.speed.y)
		self:callListener_({
			name = "moved",
			x = event.x,
			y = event.y
		})
	elseif event.name == "ended" then
		if self.bDrag_ then
			self.bDrag_ = false

			self:scrollAuto()
			self:callListener_({
				name = "ended",
				x = event.x,
				y = event.y
			})
			self:disableScrollBar()
		else
			self:callListener_({
				name = "clicked",
				x = event.x,
				y = event.y
			})
		end
	end
end

function UIScrollView:isTouchInViewRect(event)
	local viewRect = self:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
	viewRect.width = self.viewRect_.width
	viewRect.height = self.viewRect_.height

	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function UIScrollView:isTouchInScrollNode(event)
	local cascadeBound = self:getScrollNodeRect()

	return cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y))
end

function UIScrollView:scrollTo(p, y)
	local x_, y_ = nil

	if type(p) == "table" then
		x_ = p.x or 0
		y_ = p.y or 0
	else
		x_ = p
		y_ = y
	end

	self.position_ = cc.p(x_, y_)

	self.scrollNode:setPosition(self.position_)
end

function UIScrollView:moveXY(orgX, orgY, speedX, speedY)
	if self.bBounce then
		return orgX + speedX, orgY + speedY
	end

	local cascadeBound = self:getScrollNodeRect()
	local viewRect = self:getViewRectInWorldSpace()
	local x = orgX
	local y = orgY
	local disX, disY = nil

	if speedX > 0 then
		if cascadeBound.x < viewRect.x then
			disX = viewRect.x - cascadeBound.x
			disX = disX / self.scaleToWorldSpace_.x
			x = orgX + math.min(disX, speedX)
		end
	elseif cascadeBound.x + cascadeBound.width > viewRect.x + viewRect.width then
		disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
		disX = disX / self.scaleToWorldSpace_.x
		x = orgX + math.max(disX, speedX)
	end

	if speedY > 0 then
		if cascadeBound.y < viewRect.y then
			disY = viewRect.y - cascadeBound.y
			disY = disY / self.scaleToWorldSpace_.y
			y = orgY + math.min(disY, speedY)
		end
	elseif cascadeBound.y + cascadeBound.height > viewRect.y + viewRect.height then
		disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
		disY = disY / self.scaleToWorldSpace_.y
		y = orgY + math.max(disY, speedY)
	end

	return x, y
end

function UIScrollView:scrollBy(x, y)
	self.position_.x, self.position_.y = self:moveXY(self.position_.x, self.position_.y, x, y)

	self.scrollNode:setPosition(self.position_)

	if self.actualRect_ then
		self.actualRect_.x = self.actualRect_.x + x
		self.actualRect_.y = self.actualRect_.y + y
	end
end

function UIScrollView:scrollAuto()
	if self:twiningScroll() then
		return
	end

	self:elasticScroll()
end

function UIScrollView:twiningScroll()
	if self:isSideShow() then
		return false
	end

	if math.abs(self.speed.x) < 10 and math.abs(self.speed.y) < 10 then
		return false
	end

	local disX, disY = self:moveXY(0, 0, self.speed.x * 6, self.speed.y * 6)

	transition.moveBy(self.scrollNode, {
		easing = "sineOut",
		time = 0.3,
		x = disX,
		y = disY,
		onComplete = function ()
			self:elasticScroll()
		end
	})
end

function UIScrollView:elasticScroll()
	local cascadeBound = self:getScrollNodeRect()
	local disX = 0
	local disY = 0
	local viewRect = self:getViewRect()
	local t = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
	cascadeBound.x = t.x
	cascadeBound.y = t.y
	self.scaleToWorldSpace_ = self.scaleToWorldSpace_ or {
		x = 1,
		y = 1
	}
	cascadeBound.width = cascadeBound.width / self.scaleToWorldSpace_.x
	cascadeBound.height = cascadeBound.height / self.scaleToWorldSpace_.y

	if cascadeBound.width < viewRect.width then
		disX = viewRect.x - cascadeBound.x
	elseif viewRect.x < cascadeBound.x then
		disX = viewRect.x - cascadeBound.x
	elseif cascadeBound.x + cascadeBound.width < viewRect.x + viewRect.width then
		disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
	end

	if cascadeBound.height < viewRect.height then
		disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
	elseif viewRect.y < cascadeBound.y then
		disY = viewRect.y - cascadeBound.y
	elseif cascadeBound.y + cascadeBound.height < viewRect.y + viewRect.height then
		disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
	end

	if disX == 0 and disY == 0 then
		return
	end

	transition.moveBy(self.scrollNode, {
		easing = "backout",
		time = 0.3,
		x = disX,
		y = disY,
		onComplete = function ()
			self:callListener_({
				name = "scrollEnd"
			})
		end
	})
end

function UIScrollView:getScrollNodeRect()
	local bound = self.scrollNode:getCascadeBoundingBox()

	return bound
end

function UIScrollView:getViewRectInWorldSpace()
	local rect = self:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
	rect.width = self.viewRect_.width
	rect.height = self.viewRect_.height

	return rect
end

function UIScrollView:isSideShow()
	local bound = self.scrollNode:getCascadeBoundingBox()
	local localPos = self:convertToNodeSpace(cc.p(bound.x, bound.y))
	local verticalSideShow = self.viewRect_.y < localPos.y or localPos.y + bound.height < self.viewRect_.y + self.viewRect_.height
	local horizontalSideShow = self.viewRect_.x < localPos.x or localPos.x + bound.width < self.viewRect_.x + self.viewRect_.width

	if UIScrollView.DIRECTION_VERTICAL == self.direction then
		return verticalSideShow
	elseif UIScrollView.DIRECTION_HORIZONTAL == self.direction then
		return horizontalSideShow
	else
		return verticalSideShow or horizontalSideShow
	end

	return false
end

function UIScrollView:callListener_(event)
	if not self.scrollListener_ then
		return
	end

	event.scrollView = self

	self.scrollListener_(event)
end

function UIScrollView:enableScrollBar()
	local bound = self.scrollNode:getCascadeBoundingBox()

	if self.sbV then
		self.sbV:setVisible(false)
		transition.stopTarget(self.sbV)
		self.sbV:setOpacity(128)

		local size = self.sbV:getContentSize()

		if self.viewRect_.height < bound.height then
			local barH = self.viewRect_.height * self.viewRect_.height / bound.height

			if barH < size.width then
				barH = size.width
			end

			self.sbV:setContentSize(size.width, barH)
			self.sbV:setPosition(self.viewRect_.x + self.viewRect_.width - size.width / 2, self.viewRect_.y + barH / 2)
		end
	end

	if self.sbH then
		self.sbH:setVisible(false)
		transition.stopTarget(self.sbH)
		self.sbH:setOpacity(128)

		local size = self.sbH:getContentSize()

		if self.viewRect_.width < bound.width then
			local barW = self.viewRect_.width * self.viewRect_.width / bound.width

			if barW < size.height then
				barW = size.height
			end

			self.sbH:setContentSize(barW, size.height)
			self.sbH:setPosition(self.viewRect_.x + barW / 2, self.viewRect_.y + size.height / 2)
		end
	end
end

function UIScrollView:disableScrollBar()
	if self.sbV then
		transition.fadeOut(self.sbV, {
			time = 0.3,
			onComplete = function ()
				self.sbV:setOpacity(128)
				self.sbV:setVisible(false)
			end
		})
	end

	if self.sbH then
		transition.fadeOut(self.sbH, {
			time = 1.5,
			onComplete = function ()
				self.sbH:setOpacity(128)
				self.sbH:setVisible(false)
			end
		})
	end
end

function UIScrollView:drawScrollBar()
	if not self.bDrag_ then
		return
	end

	if not self.sbV and not self.sbH then
		return
	end

	local bound = self.scrollNode:getCascadeBoundingBox()

	if self.sbV then
		self.sbV:setVisible(true)

		local size = self.sbV:getContentSize()
		local posY = (self.viewRect_.y - bound.y) * (self.viewRect_.height - size.height) / (bound.height - self.viewRect_.height) + self.viewRect_.y + size.height / 2
		local x, y = self.sbV:getPosition()

		self.sbV:setPosition(x, posY)
	end

	if self.sbH then
		self.sbH:setVisible(true)

		local size = self.sbH:getContentSize()
		local posX = (self.viewRect_.x - bound.x) * (self.viewRect_.width - size.width) / (bound.width - self.viewRect_.width) + self.viewRect_.x + size.width / 2
		local x, y = self.sbH:getPosition()

		self.sbH:setPosition(posX, y)
	end
end

function UIScrollView:addScrollBarIf()
	if not self.sb then
		self.sb = cc.DrawNode:create():addTo(self)
	end

	drawNode = cc.DrawNode:create()

	drawNode:drawSegment(points[1], points[2], radius, borderColor)
end

function UIScrollView:changeViewRectToNodeSpaceIf()
	if self.viewRectIsNodeSpace then
		return
	end

	local posX, posY = self:getPosition()
	local ws = self:convertToWorldSpace(cc.p(posX, posY))
	self.viewRect_.x = self.viewRect_.x + ws.x
	self.viewRect_.y = self.viewRect_.y + ws.y
	self.viewRectIsNodeSpace = true
end

function UIScrollView:isShake(event)
	if math.abs(event.x - self.prevX_) < self.nShakeVal and math.abs(event.y - self.prevY_) < self.nShakeVal then
		return true
	end
end

function UIScrollView:scaleToParent_()
	local parent = nil
	local node = self
	local scale = {
		x = 1,
		y = 1
	}

	while true do
		scale.x = scale.x * node:getScaleX()
		scale.y = scale.y * node:getScaleY()
		parent = node:getParent()

		if not parent then
			break
		end

		node = parent
	end

	return scale
end

function UIScrollView:addTouchNode()
	local node = nil

	if self.touchNode_ then
		node = self.touchNode_
	else
		node = display.newNode()
		self.touchNode_ = node

		node:setLocalZOrder(UIScrollView.TOUCH_ZORDER)
		node:setTouchSwallowEnabled(true)
		node:setTouchEnabled(true)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			return self:onTouch_(event)
		end)
		self:addChild(node)
	end

	node:setContentSize(self.viewRect_.width, self.viewRect_.height)
	node:setPosition(self.viewRect_.x, self.viewRect_.y)

	return self
end

function UIScrollView:fill(nodes, params)
	local function extend(param1, param2)
		if not param2 then
			return param1
		end

		for k, v in pairs(param2) do
			param1[k] = param2[k]
		end

		return param1
	end

	local params = extend({
		heightGap = 0,
		rowCount = 3,
		cellCount = 3,
		autoTable = true,
		widthGap = 0,
		autoGap = true,
		itemSize = cc.size(50, 50)
	}, params)

	if #nodes == 0 then
		return nil
	end

	local function SIZE(node)
		return node:getContentSize()
	end

	local function W(node)
		return node:getContentSize().width
	end

	local function H(node)
		return node:getContentSize().height
	end

	local function S_SIZE(node, w, h)
		return node:setContentSize(cc.size(w, h))
	end

	local function S_XY(node, x, y)
		node:setPosition(x, y)
	end

	local function AX(node)
		return node:getAnchorPoint().x
	end

	local function AY(node)
		return node:getAnchorPoint().y
	end

	local innerContainer = display.newNode()

	S_SIZE(innerContainer, self:getViewRect().width, self:getViewRect().height)
	self:addScrollNode(innerContainer)
	S_XY(innerContainer, self.viewRect_.x, self.viewRect_.y)

	if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
		if params.autoTable then
			params.cellCount = math.floor(self.viewRect_.width / params.itemSize.width)
		end

		if params.autoGap then
			params.widthGap = (self.viewRect_.width - params.cellCount * params.itemSize.width) / (params.cellCount + 1)
			params.heightGap = params.widthGap
		end

		params.rowCount = math.ceil(#nodes / params.cellCount)
		local v_h = (params.itemSize.height + params.heightGap) * params.rowCount + params.heightGap

		if v_h < self.viewRect_.height then
			v_h = self.viewRect_.height
		end

		S_SIZE(innerContainer, self.viewRect_.width, v_h)

		for i = 1, #nodes do
			local n = nodes[i]
			local x = 0
			local y = 0
			x = params.widthGap + math.floor((i - 1) % params.cellCount) * (params.widthGap + params.itemSize.width)
			y = H(innerContainer) - (math.floor((i - 1) / params.cellCount) + 1) * (params.heightGap + params.itemSize.height)
			x = x + W(n) * AX(n)
			y = y + H(n) * AY(n)

			S_XY(n, x, y)
			n:addTo(innerContainer)
		end
	else
		if params.autoTable then
			params.rowCount = math.floor(self.viewRect_.height / params.itemSize.height)
		end

		if params.autoGap then
			params.heightGap = (self.viewRect_.height - params.rowCount * params.itemSize.height) / (params.rowCount + 1)
			params.widthGap = params.heightGap
		end

		params.cellCount = math.ceil(#nodes / params.rowCount)
		local v_w = (params.itemSize.width + params.widthGap) * params.cellCount + params.widthGap

		if v_w < self.viewRect_.width then
			v_h = self.viewRect_.width
		end

		S_SIZE(innerContainer, v_w, self.viewRect_.height)

		for i = 1, #nodes do
			local n = nodes[i]
			local x = 0
			local y = 0
			x = params.widthGap + math.floor((i - 1) / params.rowCount) * (params.widthGap + params.itemSize.width)
			y = H(innerContainer) - (math.floor((i - 1) % params.rowCount) + 1) * (params.heightGap + params.itemSize.height)
			x = x + W(n) * AX(n)
			y = y + H(n) * AY(n)

			S_XY(n, x, y)
			n:addTo(innerContainer)
		end
	end
end

function UIScrollView:createCloneInstance_()
	return UIScrollView.new(unpack(self.args_))
end

function UIScrollView:copyClonedWidgetChildren_(node)
	local scrollNode = node:getScrollNode()
	local cloneScrollNode = scrollNode:clone()

	self:addScrollNode(cloneScrollNode)
end

function UIScrollView:copySpecialProperties_(node)
	self:setViewRect(node.viewRect_)
	self:setDirection(node:getDirection())
	self:setLayoutPadding(node.layoutPadding.top, node.layoutPadding.right, node.layoutPadding.bottom, node.layoutPadding.left)
	self:setBounceable(node.bBounce)
	self:setTouchType(node.touchOnContent)
end

return UIScrollView
