local UIScrollView = cc.ui.UIScrollView

function UIScrollView.new2(rect, direction)
	direction = direction or cc.ui.UIScrollView.DIRECTION_VERTICAL
	local scroll = cc.ui.UIScrollView.new({
		viewRect = rect,
		direction = direction
	})

	scroll:addScrollNode(display.newNode():anchor(0, 1))
	scroll:setContentSize(0, 0)

	return scroll
end

function UIScrollView:setContentOffset(x, y)
	if not self.scrollNode then
		return
	end

	self.scrollNode:pos(self:getViewRect().x - x, self:getViewRect().y + self:getViewRect().height - y)
end

function UIScrollView:setContentSize(width, height)
	if not self.scrollNode then
		return
	end

	if width < self:getViewRect().width then
		width = self:getViewRect().width or width
	end

	if height < self:getViewRect().height then
		height = self:getViewRect().height or height
	end

	self.scrollNode:size(width, height)
	self:setContentOffset(0, 0)
end

function UIScrollView:getContentSize()
	if not self.scrollNode then
		return cc.size(0, 0)
	end

	return self.scrollNode:getContentSize()
end

function UIScrollView:view()
	return self.scrollNode
end
