local progress = class("an.progress", function ()
	return display.newNode()
end)

table.merge(progress, {
	bg,
	bar,
	isV
})

function progress:ctor(barfile, bgfile, offset, isV)
	assert(barfile, "[an.progress] barfile must not nil.")

	offset = offset or {
		x = 0,
		y = 0
	}
	self.isV = isV
	self.bar = display.newSprite(barfile):anchor(0, 0):pos(offset.x, offset.y):add2(self, 1)

	if bgfile then
		self.bg = display.newSprite(bgfile):anchor(0, 0):add2(self)

		self:size(self.bg:getw(), self.bg:geth())
	else
		self.bg = nil

		self:size(self.bar:getw(), self.bar:geth())
	end

	self:setp(0)
end

function progress:setp(p)
	if p > 1 then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	local size = self.bar:getTexture():getContentSize()

	if self.isV then
		self.bar:setTextureRect(cc.rect(0, (1 - p) * size.height, size.width, size.height * p))
	else
		self.bar:setTextureRect(cc.rect(0, 0, size.width * p, size.height))
	end
end

return progress
