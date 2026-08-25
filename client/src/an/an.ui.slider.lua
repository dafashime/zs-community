local slider = class("an.slider", function ()
	return display.newNode()
end)

table.merge(slider, {
	bar,
	block
})

function slider:ctor(bg, bar, block, params)
	if DEBUG > 0 then
		if type(bg) ~= "userdata" and tolua.type(bg) ~= "cc.Texture2D" then
			printError("param[%s] must be 'cc.Texture2D' Type. ", bg)

			return
		end

		if bar and type(bar) ~= "userdata" and tolua.type(bar) ~= "cc.Texture2D" then
			printError("param[%s] must be 'cc.Texture2D' Type. ", bg)

			return
		end

		if type(block) ~= "userdata" and tolua.type(block) ~= "cc.Texture2D" then
			printError("param[%s] must be 'cc.Texture2D' Type. ", bg)

			return
		end
	end

	params = params or {}
	local class = nil

	if params.scale9 then
		class = ccui.Scale9Sprite
		local size = bg:getContentSize()
		bg = cc.SpriteFrame:createWithTexture(bg, cc.rect(0, 0, size.width, size.height))
	else
		class = cc.Sprite
	end

	local bg = display.newSprite(bg, nil, nil, {
		class = class,
		size = params.scale9
	}):anchor(0, 0):add2(self)

	self:size(bg:getContentSize())

	if bar then
		local class = nil

		if params.scale9bar then
			class = ccui.Scale9Sprite
			local size = bar:getContentSize()
			bar = cc.SpriteFrame:createWithTexture(bar, cc.rect(0, 0, size.width, size.height))
		else
			class = cc.Sprite
		end

		self.bar = display.newSprite(bar, nil, nil, {
			class = class,
			size = params.scale9bar
		}):anchor(0, 0):add2(self)
	end

	self.block = display.newSprite(block):anchor(0.5, 0.5):pos(0, self:geth() / 2):add2(self)
	local beginPos, beginTouchPos = nil

	self.block:setTouchEnabled(true)
	self.block:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			beginPos = cc.p(self.block:getPosition())
			beginTouchPos = cc.p(event.x, event.y)

			return true
		elseif event.name == "moved" or event.name == "ended" then
			local x = event.x - beginTouchPos.x + beginPos.x
			local value = math.max(0, math.min(self:getw(), x)) / self:getw()

			self:setValue(value)

			if params.valueChange and event.name == "moved" then
				params.valueChange(value)
			end

			if params.valueChangeEnd and event.name == "ended" then
				params.valueChangeEnd(value)
			end
		end
	end)

	self.params = params

	self:setValue(params.value or 0)
end

function slider:setValue(value)
	if self.params.scale9bar then
		local size = cc.size(self.params.scale9bar.width * value, self.params.scale9bar.height)

		self.block:pos(size.width, self.block:getPositionY())

		if self.bar then
			self.bar:size(size)
		end
	else
		self.block:pos(self:getw() * value, self.block:getPositionY())

		if self.bar then
			self.bar:setTextureRect(cc.rect(0, 0, self.block:getPositionX(), self.bar:geth()))
		end
	end
end

return slider
