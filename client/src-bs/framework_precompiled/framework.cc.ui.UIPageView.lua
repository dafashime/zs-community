local UIPageViewItem = import(".UIPageViewItem")
local UIPageView = class("UIPageView", function ()
	local node = display.newClippingRegionNode()

	return node
end)

function UIPageView:ctor(params)
	self.items_ = {}
	self.viewRect_ = params.viewRect or cc.rect(0, 0, display.width, display.height)
	self.column_ = params.column or 1
	self.row_ = params.row or 1
	self.columnSpace_ = params.columnSpace or 0
	self.rowSpace_ = params.rowSpace or 0
	self.padding_ = params.padding or {
		top = 0,
		left = 0,
		bottom = 0,
		right = 0
	}
	self.bCirc = params.bCirc or false

	self:setClippingRegion(self.viewRect_)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		return self:onTouch_(event)
	end)

	self.args_ = {
		params
	}
end

function UIPageView:newItem()
	local item = UIPageViewItem.new()
	local itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right - self.columnSpace_ * (self.column_ - 1)) / self.column_
	local itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom - self.rowSpace_ * (self.row_ - 1)) / self.row_

	item:setContentSize(itemW, itemH)

	return item
end

function UIPageView:addItem(item)
	table.insert(self.items_, item)

	return self
end

function UIPageView:removeItem(item)
	local itemIdx = nil

	for i, v in ipairs(self.items_) do
		if v == item then
			itemIdx = i
		end
	end

	if not itemIdx then
		print("ERROR! item isn't exist")

		return self
	end

	if itemIdx then
		table.remove(self.items_, itemIdx)
	end

	self:reload(self.curPageIdx_)

	return self
end

function UIPageView:removeAllItems()
	self.items_ = {}

	self:reload(self.curPageIdx_)

	return self
end

function UIPageView:onTouch(listener)
	self.touchListener = listener

	return self
end

function UIPageView:reload(idx)
	local page, pageCount = nil
	self.pages_ = {}

	for i, v in ipairs(self.items_) do
		v:retain()
	end

	self:removeAllChildren()

	pageCount = self:getPageCount()

	if pageCount < 1 then
		return self
	end

	if pageCount > 0 then
		for i = 1, pageCount do
			page = self:createPage_(i)

			page:setVisible(false)
			table.insert(self.pages_, page)
			self:addChild(page)
		end
	end

	if not idx or idx < 1 then
		idx = 1
	elseif pageCount < idx then
		idx = pageCount
	end

	self.curPageIdx_ = idx

	self.pages_[idx]:setVisible(true)
	self.pages_[idx]:setPosition(self.viewRect_.x, self.viewRect_.y)

	for i, v in ipairs(self.items_) do
		v:release()
	end

	return self
end

function UIPageView:gotoPage(pageIdx, bSmooth, bLeftToRight)
	if pageIdx < 1 or self:getPageCount() < pageIdx then
		return self
	end

	if pageIdx == self.curPageIdx_ and bSmooth then
		return self
	end

	if bSmooth then
		self:resetPagePos(pageIdx, bLeftToRight)
		self:scrollPagePos(pageIdx, bLeftToRight)
	else
		self.pages_[self.curPageIdx_]:setVisible(false)
		self.pages_[pageIdx]:setVisible(true)
		self.pages_[pageIdx]:setPosition(self.viewRect_.x, self.viewRect_.y)

		self.curPageIdx_ = pageIdx

		self:notifyListener_({
			name = "pageChange"
		})
	end

	return self
end

function UIPageView:getPageCount()
	return math.ceil(table.nums(self.items_) / (self.column_ * self.row_))
end

function UIPageView:getCurPageIdx()
	return self.curPageIdx_
end

function UIPageView:setCirculatory(bCirc)
	self.bCirc = bCirc

	return self
end

function UIPageView:createPage_(pageNo)
	local page = display.newNode()
	local item = nil
	local beginIdx = self.row_ * self.column_ * (pageNo - 1) + 1
	local itemW, itemH = nil
	itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right - self.columnSpace_ * (self.column_ - 1)) / self.column_
	itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom - self.rowSpace_ * (self.row_ - 1)) / self.row_
	local bBreak = false

	for row = 1, self.row_ do
		for column = 1, self.column_ do
			item = self.items_[beginIdx]
			beginIdx = beginIdx + 1

			if not item then
				bBreak = true

				break
			end

			page:addChild(item)
			item:setAnchorPoint(cc.p(0.5, 0.5))
			item:setPosition(self.padding_.left + (column - 1) * self.columnSpace_ + column * itemW - itemW / 2, self.viewRect_.height - self.padding_.top - (row - 1) * self.rowSpace_ - row * itemH + itemH / 2)
		end

		if bBreak then
			break
		end
	end

	page:setTag(1500 + pageNo)

	return page
end

function UIPageView:isTouchInViewRect_(event, rect)
	rect = rect or self.viewRect_
	local viewRect = self:convertToWorldSpace(cc.p(rect.x, rect.y))
	viewRect.width = rect.width
	viewRect.height = rect.height

	return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function UIPageView:onTouch_(event)
	if event.name == "began" and not self:isTouchInViewRect_(event) then
		printInfo("UIPageView - touch didn't in viewRect")

		return false
	end

	if event.name == "began" then
		self:stopAllTransition()

		self.bDrag_ = false
	elseif event.name == "moved" then
		self.bDrag_ = true
		self.speed = event.x - event.prevX

		self:scroll(self.speed)
	elseif event.name == "ended" then
		if self.bDrag_ then
			self:scrollAuto()
		else
			self:resetPages_()
			self:onClick_(event)
		end
	end

	return true
end

function UIPageView:resetPages_()
	local x, y = self.pages_[self.curPageIdx_]:getPosition()

	if x == self.viewRect_.x then
		return
	end

	print("UIPageView - resetPages_")
	self:disablePage()
	self:gotoPage(self.curPageIdx_)
end

function UIPageView:resetPagePos(pos, bLeftToRight)
	local pageIdx = self.curPageIdx_
	local page = nil
	local pageWidth = self.viewRect_.width
	local dis = nil
	local count = #self.pages_
	dis = pos - pageIdx

	if self.bCirc then
		local disL, disR = nil

		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if bLeftToRight == nil then
			dis = math.abs(disR) < math.abs(disL) and disR or disL
		elseif bLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = self.pages_[pageIdx]:getPosition()

	for i = 1, disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
			x = x + pageWidth
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
			x = x - pageWidth
		end

		pageIdx = pageIdx % count

		if pageIdx == 0 then
			pageIdx = count
		end

		page = self.pages_[pageIdx]

		if page then
			page:setVisible(true)
			page:setPosition(x, self.viewRect_.y)
		end
	end
end

function UIPageView:scrollPagePos(pos, bLeftToRight)
	local pageIdx = self.curPageIdx_
	local page = nil
	local pageWidth = self.viewRect_.width
	local dis = nil
	local count = #self.pages_
	dis = pos - pageIdx

	if self.bCirc then
		local disL, disR = nil

		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if bLeftToRight == nil then
			dis = math.abs(disR) < math.abs(disL) and disR or disL
		elseif bLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = self.viewRect_.x
	local movedis = dis * pageWidth

	for i = 1, disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
		end

		pageIdx = pageIdx % count

		if pageIdx == 0 then
			pageIdx = count
		end

		page = self.pages_[pageIdx]

		if page then
			page:setVisible(true)
			transition.moveBy(page, {
				time = 0.3,
				y = 0,
				x = -movedis
			})
		end
	end

	transition.moveBy(self.pages_[self.curPageIdx_], {
		time = 0.3,
		y = 0,
		x = -movedis,
		onComplete = function ()
			local pageIdx = (self.curPageIdx_ + dis + count) % count

			if pageIdx == 0 then
				pageIdx = count
			end

			self.curPageIdx_ = pageIdx

			self:disablePage()
			self:notifyListener_({
				name = "pageChange"
			})
		end
	})
end

function UIPageView:stopAllTransition()
	for i, v in ipairs(self.pages_) do
		transition.stopTarget(v)
	end
end

function UIPageView:disablePage()
	local pageIdx = self.curPageIdx_
	local page = nil

	for i, v in ipairs(self.pages_) do
		if i ~= self.curPageIdx_ then
			v:setVisible(false)
		end
	end
end

function UIPageView:scroll(dis)
	local threePages = {}
	local count = nil

	if self.pages_ then
		count = #self.pages_
	else
		count = 0
	end

	local page = nil

	if count == 0 then
		return
	elseif count == 1 then
		table.insert(threePages, false)
		table.insert(threePages, self.pages_[self.curPageIdx_])
	elseif count == 2 then
		local posX, posY = self.pages_[self.curPageIdx_]:getPosition()

		if self.viewRect_.x < posX then
			page = self:getNextPage(false)
			page = page or false

			table.insert(threePages, page)
			table.insert(threePages, self.pages_[self.curPageIdx_])
		else
			table.insert(threePages, false)
			table.insert(threePages, self.pages_[self.curPageIdx_])
			table.insert(threePages, self:getNextPage(true))
		end
	else
		page = self:getNextPage(false)
		page = page or false

		table.insert(threePages, page)
		table.insert(threePages, self.pages_[self.curPageIdx_])
		table.insert(threePages, self:getNextPage(true))
	end

	self:scrollLCRPages(threePages, dis)
end

function UIPageView:scrollLCRPages(threePages, dis)
	local posX, posY = nil
	local pageL = threePages[1]
	local page = threePages[2]
	local pageR = threePages[3]
	posX, posY = page:getPosition()
	posX = posX + dis

	page:setPosition(posX, posY)

	posX = posX - self.viewRect_.width

	if pageL and type(pageL) ~= "boolean" then
		pageL:setPosition(posX, posY)

		if not pageL:isVisible() then
			pageL:setVisible(true)
		end
	end

	posX = posX + self.viewRect_.width * 2

	if pageR then
		pageR:setPosition(posX, posY)

		if not pageR:isVisible() then
			pageR:setVisible(true)
		end
	end
end

function UIPageView:scrollAuto()
	local page = self.pages_[self.curPageIdx_]
	local pageL = self:getNextPage(false)
	local pageR = self:getNextPage(true)
	local bChange = false
	local posX, posY = page:getPosition()
	local dis = posX - self.viewRect_.x
	local pageRX = self.viewRect_.x + self.viewRect_.width
	local pageLX = self.viewRect_.x - self.viewRect_.width
	local count = #self.pages_

	if count == 0 then
		return
	elseif count == 1 then
		pageL, pageR = nil
	end

	if (dis > self.viewRect_.width / 2 or self.speed > 10) and (self.curPageIdx_ > 1 or self.bCirc) and count > 1 then
		bChange = true
	elseif (-dis > self.viewRect_.width / 2 or -self.speed > 10) and (self.curPageIdx_ < self:getPageCount() or self.bCirc) and count > 1 then
		bChange = true
	end

	if dis > 0 then
		if bChange then
			transition.moveTo(page, {
				time = 0.3,
				x = pageRX,
				y = posY,
				onComplete = function ()
					self.curPageIdx_ = self:getNextPageIndex(false)

					self:disablePage()
					self:notifyListener_({
						name = "pageChange"
					})
				end
			})
			transition.moveTo(pageL, {
				time = 0.3,
				x = self.viewRect_.x,
				y = posY
			})
		else
			transition.moveTo(page, {
				time = 0.3,
				x = self.viewRect_.x,
				y = posY,
				onComplete = function ()
					self:disablePage()
					self:notifyListener_({
						name = "pageChange"
					})
				end
			})

			if pageL then
				transition.moveTo(pageL, {
					time = 0.3,
					x = pageLX,
					y = posY
				})
			end
		end
	elseif bChange then
		transition.moveTo(page, {
			time = 0.3,
			x = pageLX,
			y = posY,
			onComplete = function ()
				self.curPageIdx_ = self:getNextPageIndex(true)

				self:disablePage()
				self:notifyListener_({
					name = "pageChange"
				})
			end
		})
		transition.moveTo(pageR, {
			time = 0.3,
			x = self.viewRect_.x,
			y = posY
		})
	else
		transition.moveTo(page, {
			time = 0.3,
			x = self.viewRect_.x,
			y = posY,
			onComplete = function ()
				self:disablePage()
				self:notifyListener_({
					name = "pageChange"
				})
			end
		})

		if pageR then
			transition.moveTo(pageR, {
				time = 0.3,
				x = pageRX,
				y = posY
			})
		end
	end
end

function UIPageView:onClick_(event)
	local itemW, itemH = nil
	itemW = (self.viewRect_.width - self.padding_.left - self.padding_.right - self.columnSpace_ * (self.column_ - 1)) / self.column_
	itemH = (self.viewRect_.height - self.padding_.top - self.padding_.bottom - self.rowSpace_ * (self.row_ - 1)) / self.row_
	local itemRect = {
		width = itemW,
		height = itemH
	}
	local clickIdx = nil

	for row = 1, self.row_ do
		itemRect.y = self.viewRect_.y + self.viewRect_.height - self.padding_.top - row * itemH - (row - 1) * self.rowSpace_

		for column = 1, self.column_ do
			itemRect.x = self.viewRect_.x + self.padding_.left + (column - 1) * (itemW + self.columnSpace_)

			if self:isTouchInViewRect_(event, itemRect) then
				clickIdx = (row - 1) * self.column_ + column

				break
			end
		end

		if clickIdx then
			break
		end
	end

	if not clickIdx then
		return
	end

	clickIdx = clickIdx + self.column_ * self.row_ * (self.curPageIdx_ - 1)

	self:notifyListener_({
		name = "clicked",
		item = self.items_[clickIdx],
		itemIdx = clickIdx
	})
end

function UIPageView:notifyListener_(event)
	if not self.touchListener then
		return
	end

	event.pageView = self
	event.pageIdx = self.curPageIdx_

	self.touchListener(event)
end

function UIPageView:getNextPage(bRight)
	if not self.pages_ then
		return
	end

	if self.pages_ and #self.pages_ < 2 then
		return
	end

	local pos = self:getNextPageIndex(bRight)

	return self.pages_[pos]
end

function UIPageView:getNextPageIndex(bRight)
	local count = #self.pages_
	local pos = nil

	if bRight then
		pos = self.curPageIdx_ + 1
	else
		pos = self.curPageIdx_ - 1
	end

	if self.bCirc then
		pos = pos + count
		pos = pos % count

		if pos == 0 then
			pos = count
		end
	end

	return pos
end

function UIPageView:createCloneInstance_()
	return UIPageView.new(unpack(self.args_))
end

function UIPageView:copyClonedWidgetChildren_(node)
	local children = node.items_

	if not children or #children == 0 then
		return
	end

	for i, child in ipairs(children) do
		local cloneChild = child:clone()

		if cloneChild then
			self:addItem(cloneChild)
		end
	end
end

function UIPageView:copySpecialProperties_(node)
	self.bCirc = node.bCirc
end

return UIPageView
