local UILabel = nil
UILabel = class("UILabel", function (options)
	if not options then
		return
	end

	if options.UILabelType == 1 then
		return UILabel.newBMFontLabel_(options)
	elseif not options.UILabelType or options.UILabelType == 2 then
		return UILabel.newTTFLabel_(options)
	else
		printInfo("UILabel unkonw UILabelType")
	end
end)
UILabel.LABEL_TYPE_BM = 1
UILabel.LABEL_TYPE_TTF = 2

function UILabel:ctor(options)
	makeUIControl_(self)
	self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)
	self:align(display.LEFT_CENTER)

	self.args_ = {
		options
	}
end

function UILabel:setLayoutSize(width, height)
	self:getComponent("components.ui.LayoutProtocol"):setLayoutSize(width, height)

	return self
end

function UILabel:createCloneInstance_()
	return UILabel.new(unpack(self.args_))
end

function UILabel:copyClonedWidgetChildren_(node)
end

function UILabel.newBMFontLabel_(params)
	return display.newBMFontLabel(params)
end

function UILabel.newTTFLabel_(params)
	return display.newTTFLabel(params)
end

return UILabel
