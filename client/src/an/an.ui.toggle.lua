local btn = import(".btn")
local label = import(".label")
local toggle = class("an.toggle", function ()
	return display.newNode()
end)

table.merge(toggle, {
	btn,
	label,
	isSelect,
	isDisable
})

function toggle:ctor(imageName, imageName2, callback, params)
	params = params or {}

	local function click()
		if self.isDisable then
			return
		end

		self.btn:setIsSelect(not self.btn.isSelect)

		if callback then
			callback(self.btn.isSelect)
		end
	end

	self.btn = an.btn.new(imageName, click, {
		select = {
			imageName2,
			manual = true
		},
		support = params.easy and "easy",
		scale9 = params.scale9
	}):anchor(0, 0):add2(self)

	if params.default then
		self.btn:select()
	end

	if params.label then
		self.label = an.newLabel(unpack(params.label)):anchor(0, 0.5):pos(self.btn:getw() + (params.space or 10), self.btn:geth() / 2):add2(self)

		self:size(self.btn:getw() + 10 + self.label:getw(), self.btn:geth()):enableClick(click, {
			support = params.easy and "easy"
		})
	else
		self:size(self.btn:getContentSize())
	end

	self.isSelect = params.default
	self.isDisable = params.isDisable
end

function toggle:isSelected()
	return self.btn.isSelect
end

function toggle:setIsSelect(bSelect)
	if bSelect == self.btn.isSelect then
		return
	end

	self.btn:setIsSelect(bSelect)
end

function toggle:setIsDisable(b)
	self.isDisable = b

	return self
end

return toggle
