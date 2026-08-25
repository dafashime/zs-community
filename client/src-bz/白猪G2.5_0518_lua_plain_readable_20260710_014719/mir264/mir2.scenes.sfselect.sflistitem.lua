local sflistitem = class("sflistitem", function()
	return display.newNode()
end)

table.merge(sflistitem, {
	data = {}
})

function sflistitem:ctor(delegate, size, color)
	self:setContentSize(size)

	self.delegate = delegate

	self:enableClick(function(x, y)
		if self.delegate then
			self.delegate:onTouchSfList(self.scrollIndex)
		end
	end, {
		support = "scroll"
	})

	self.bg_root = display.newNode():add2(self)
	self.bg = display.newColorLayer(cc.c4b(254, 254, 0, 255)):size(size):add2(self.bg_root)
	self.content = display.newNode():add2(self):size(size)
	self.serverNameLabel = an.newLabel("", 18, 1, {
		color = def.colors.text
	}):add2(self.content):pos(self.content:getw() / 3 / 2, self.content:geth() / 2):anchor(0.5, 0.5)
	self.introduceLabel = an.newLabel("", 18, 1, {
		color = def.colors.text
	}):add2(self.content):pos(self.content:getw() * 2 / 3, self.content:geth() / 2):anchor(0.5, 0.5)

	local paddingLine = display.newLine({
		{
			self.content:getw() / 3,
			0
		},
		{
			self.content:getw() / 3,
			self.content:geth()
		}
	}, {
		borderWidth = 1,
		borderColor = cc.c4f(0, 0, 0, 1)
	}):add2(self.content):anchor(0, 0)
	local bottomLine = display.newLine({
		{
			0,
			0
		},
		{
			self.content:getw(),
			0
		}
	}, {
		borderWidth = 1,
		borderColor = cc.c4f(0, 0, 0, 1)
	}):add2(self.content):anchor(0, 0)
end

function sflistitem:setData(data)
	self.data = data

	local serverName = data.serverName
	local introduce = data.introduce

	if string.utf8len(data.serverName) > 6 then
		serverName = string.utf8sub(data.serverName, 1, 6) .. "..."
	end

	if string.utf8len(data.introduce) > 18 then
		introduce = string.utf8sub(data.introduce, 1, 18) .. "..."
	end

	self.serverNameLabel:setText(serverName)
	self.introduceLabel:setText(introduce)
end

function sflistitem:setScrollIndex(index)
	self.scrollIndex = index

	if index == 1 then
		display.newLine({
			{
				0,
				self.content:geth()
			},
			{
				self.content:getw(),
				self.content:geth()
			}
		}, {
			borderWidth = 1,
			borderColor = cc.c4f(0, 0, 0, 1)
		}):add2(self.content):anchor(0, 0)
	end
end

function sflistitem:setBgColor(color)
	if self.bg then
		self.bg:removeSelf()
	end

	self.bg = display.newColorLayer(color or cc.c4b(254, 254, 254, 255)):size(self:getContentSize()):add2(self.bg_root)
end

return sflistitem
