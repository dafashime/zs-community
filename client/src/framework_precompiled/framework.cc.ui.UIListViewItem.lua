local UIScrollView = import(".UIScrollView")
local UIListViewItem = class("UIListViewItem", function ()
	return cc.Node:create()
end)
UIListViewItem.BG_TAG = 1
UIListViewItem.BG_Z_ORDER = 1
UIListViewItem.CONTENT_TAG = 11
UIListViewItem.CONTENT_Z_ORDER = 11
UIListViewItem.ID_COUNTER = 0

function UIListViewItem:ctor(item)
	self.width = 0
	self.height = 0
	self.margin_ = {
		top = 0,
		left = 0,
		bottom = 0,
		right = 0
	}
	UIListViewItem.ID_COUNTER = UIListViewItem.ID_COUNTER + 1
	self.id = UIListViewItem.ID_COUNTER

	self:setTag(self.id)
	self:addContent(item)
end

function UIListViewItem:addContent(content)
	if not content then
		return
	end

	self:addChild(content, UIListViewItem.CONTENT_Z_ORDER, UIListViewItem.CONTENT_TAG)
end

function UIListViewItem:getContent()
	return self:getChildByTag(UIListViewItem.CONTENT_TAG)
end

function UIListViewItem:setItemSize(w, h, bNoMargin)
	if not bNoMargin then
		if UIScrollView.DIRECTION_VERTICAL == self.lvDirection_ then
			h = h + self.margin_.top + self.margin_.bottom
		else
			w = w + self.margin_.left + self.margin_.right
		end
	end

	local oldSize = {
		width = self.width,
		height = self.height
	}
	local newSize = {
		width = w,
		height = h
	}
	self.width = w or 0
	self.height = h or 0

	self:setContentSize(w, h)

	local bg = self:getChildByTag(UIListViewItem.BG_TAG)

	if bg then
		bg:setContentSize(w, h)
		bg:setPosition(cc.p(w / 2, h / 2))
	end

	self:listener(newSize, oldSize)
end

function UIListViewItem:getItemSize()
	return self.width, self.height
end

function UIListViewItem:setMargin(margin)
	self.margin_ = margin
end

function UIListViewItem:getMargin()
	return self.margin_
end

function UIListViewItem:setBg(bg)
	local sp = nil
	local bgType = tolua.type(bg)

	if bgType == "string" then
		sp = display.newScale9Sprite(bg)

		sp:setAnchorPoint(cc.p(0.5, 0.5))
		sp:setPosition(cc.p(self.width / 2, self.height / 2))
	elseif bgType == "ccui.Scale9Sprite" or bgType == "cc.Sprite" then
		sp = bg
	elseif bgType == "cc.SpriteFrame" then
		sp = ccui.Scale9Sprite:createWithSpriteFrame(bg)
	end

	self:addChild(sp, UIListViewItem.BG_Z_ORDER, UIListViewItem.BG_TAG)
end

function UIListViewItem:getBg()
	return self:getChildByTag(UIListViewItem.BG_TAG)
end

function UIListViewItem:onSizeChange(listener)
	self.listener = listener

	return self
end

function UIListViewItem:setDirction(dir)
	self.lvDirection_ = dir
end

function UIListViewItem:createCloneInstance_()
	return UIListViewItem.new(self:getContent():clone())
end

function UIListViewItem:copyClonedWidgetChildren_(node)
end

function UIListViewItem:copySpecialProperties_(node)
	self.listener = node.listener

	self:setMargin(node:getMargin())

	local bg = node:getBg()

	if bg then
		if tolua.type(bg) == "ccui.Scale9Sprite" then
			self:setBg(bg:getSprite():getSpriteFrame())
		else
			self:setBg(bg:getSpriteFrame())
		end
	end

	self:setItemSize(node:getItemSize())
end

return UIListViewItem
