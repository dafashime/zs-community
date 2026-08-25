local scroll = class("an.scroll", function ()
	return display.newNode()
end)

table.merge(scroll, {
	scrollView,
	labelM
})

function scroll:ctor(x, y, w, h, params)
	params = params or {}
	self.scrollView = cc.ui.UIScrollView.new({
		viewRect = cc.rect(0, 0, w, h),
		direction = params.dir or 1
	}):addScrollNode(display.newNode():anchor(0, 1))

	getmetatable(self).addChild(self, self.scrollView, 0, 0)
	self:pos(x, y):size(w, h)

	if params.labelM then
		local labelMParams = params.labelM.params or {}
		labelMParams.scroll = self
		self.labelM = an.newLabelM(w, params.labelM[1], params.labelM[2], labelMParams):addto(self)
	end

	self:setScrollSize(0, 0)
	self:setScrollOffset(0, 0)
end

function scroll:addChild(child, zorder, tag)
	if self.scrollView.scrollNode then
		self.scrollView.scrollNode:add(child, zorder, tag)
	end
end

function scroll:setScrollOffset(x, y)
	if not self.scrollView.scrollNode then
		return
	end

	self.scrollView.scrollNode:pos(x, self.scrollView:getViewRect().height + y)
end

function scroll:getScrollOffset()
	local x, y = self.scrollView.scrollNode:getPosition()

	return x, y - self.scrollView:getViewRect().height
end

function scroll:setScrollSize(width, height)
	if not self.scrollView.scrollNode then
		return
	end

	if width < self.scrollView:getViewRect().width then
		width = self.scrollView:getViewRect().width or width
	end

	if height < self.scrollView:getViewRect().height then
		height = self.scrollView:getViewRect().height or height
	end

	self.scrollView.scrollNode:size(width, height)
end

function scroll:getScrollSize()
	if not self.scrollView.scrollNode then
		return cc.size(0, 0)
	end

	return self.scrollView.scrollNode:getContentSize()
end

function scroll:enableTouch(isEnable)
	self.scrollView.scrollNode:setTouchEnabled(isEnable)
	self.scrollView.touchNode_:setTouchEnabled(isEnable)

	return self
end

function scroll:setListenner(listener)
	self.scrollView:onScroll(listener)
end

return scroll
