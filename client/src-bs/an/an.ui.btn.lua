local btn = class("an.btn", function ()
	return display.newNode()
end)

table.merge(btn, {
	imageTex,
	listener,
	params,
	bg,
	sprite,
	label,
	isSelect,
	beganPos,
	beganTouchPos,
	hasDrag,
	lastClick
})

function btn:ctor(imageTex, listener, params)
	params = params or {}

	if DEBUG > 0 then
		if type(imageTex) ~= "userdata" and tolua.type(imageTex) ~= "cc.Texture2D" then
			printError("param[%s] must be 'cc.Texture2D' Type. ", imageTex)

			return
		end

		if params.select then
			if type(params.select) == "string" then
				printError("param[select] must be 'table' Type.")

				return
			elseif type(params.select[1]) ~= "userdata" and tolua.type(params.select[1]) ~= "cc.Texture2D" then
				printError("param[%s] must be 'cc.Texture2D' Type. ", imageTex)
			end
		end

		if params.pressImage and type(params.pressImage) ~= "userdata" and tolua.type(params.pressImage) ~= "cc.Texture2D" then
			printError("param[%s] must be 'cc.Texture2D' Type.", params.pressImage)

			return
		end
	end

	self.imageTex = imageTex
	self.listener = listener
	self.params = params
	local class = nil

	if params.filter then
		class = cc.FilteredSpriteWithOne
	elseif params.scale9 then
		class = ccui.Scale9Sprite
		local size = imageTex:getContentSize()
		imageTex = cc.SpriteFrame:createWithTexture(imageTex, cc.rect(0, 0, size.width, size.height))
	else
		class = cc.Sprite
	end

	self.bg = display.newSprite(imageTex, nil, nil, {
		class = class,
		size = params.scale9
	}):add2(self)

	if params.scale then
		self.bg:scale(params.scale)
	end

	if params.anchor then
		self.bg:anchor(params.anchor[1], params.anchor[2])
	end

	if params.pressShow then
		self.bg:setOpacity(0)
	end

	if params.label then
		self.label = an.newLabel(params.label[1], params.label[2], params.label[3], params.label[4]):anchor(0.5, 0.5):addto(self)
	end

	if params.sprite then
		if params.filter then
			self.sprite = display.newSprite(params.sprite, nil, nil, {
				class = cc.FilteredSpriteWithOne
			})
		else
			self.sprite = display.newSprite(params.sprite)
		end

		self.sprite:anchor(0.5, 0.5):add2(self)
	end

	self:size(self.bg:getContentSize().width * self.bg:getScale(), self.bg:getContentSize().height * self.bg:getScale())

	if params.size then
		display.newNode():anchor(0.5, 0.5):pos(self:centerPos()):size(params.size):add2(self, an.z.max)
	end

	self:anchor(0.5, 0.5)

	if not params.externTouch then
		if params.support == "scroll" then
			self:setTouchSwallowEnabled(false)
		end

		self:setTouchEnabled(true)
		self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.handleTouch))
	end

	imageTex:retain()

	if params.select then
		params.select[1]:retain()
	end

	if params.pressImage then
		params.pressImage:retain()
	end

	self:setNodeEventEnabled(true)

	function self.onCleanup()
		imageTex:release()

		if params.select then
			params.select[1]:release()
		end

		if params.pressImage then
			params.pressImage:release()
		end

		if params.call_remove then
			params.call_remove()
		end
	end

	if params.filterOpen then
		self:openFilter()
	end
end

function btn:size(width, height)
	if type(width) == "table" then
		self:setContentSize(width)
	else
		self:setContentSize(cc.size(width, height))
	end

	local anchor = self.bg:getAnchorPoint()

	self.bg:pos(anchor.x * self:getw(), anchor.y * self:geth())

	if self.label then
		local anchor = self.label:getAnchorPoint()
		local offset = self.params.labelOffset or {
			x = 0,
			y = 0
		}

		self.label:pos(anchor.x * self:getw() + offset.x, anchor.x * self:geth() + offset.y)
	end

	if self.sprite then
		local anchor = self.sprite:getAnchorPoint()
		local offset = self.params.spriteOffset or {
			x = 0,
			y = 0
		}

		self.sprite:pos(anchor.x * self:getw() + offset.x, anchor.x * self:geth() + offset.y)
	end

	return self
end

function btn:setTex(tex)
	if self.params.scale9 then
		if tolua.type(tex) ~= "cc.SpriteFrame" then
			local size = tex:getContentSize()
			local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, size.width, size.height))

			self.bg:setSpriteFrame(frame)
		else
			self.bg:setSpriteFrame(tex)
		end

		self.bg:size(self.params.scale9)
	else
		self:setTexture(tex)
	end
end

function btn:setTexture(tex)
	self.bg:setTex(tex)
end

function btn:touchIn(isTouchIn)
	if isTouchIn then
		if self.params.pressShow then
			self.bg:setOpacity(255)
		end

		if self.params.pressBig then
			local power = 1.3

			if type(self.params.pressBig) == "number" then
				power = self.params.pressBig
			end

			self.bg:scaleTo(0.1, power * (self.params.scale or 1))

			if self.sprite then
				self.sprite:scaleTo(0.1, power * (self.params.scale or 1))
			end
		end

		if self.params.pressImage then
			self:setTex(self.params.pressImage)
		end
	else
		if self.params.pressShow then
			self.bg:setOpacity(0)
		end

		if self.params.pressBig then
			self.bg:scaleTo(0.1, self.params.scale or 1)

			if self.sprite then
				self.sprite:scaleTo(0.1, self.params.scale or 1)
			end
		end

		if self.params.pressImage then
			self:setTex(self.imageTex)
		end
	end
end

function btn:select()
	if self.params.select and not self.isSelect then
		self.isSelect = true

		self:setTex(self.params.select[1])
	end
end

function btn:unselect()
	if self.params.select and self.isSelect then
		self.isSelect = false

		self:setTex(self.imageTex)
	end
end

function btn:setIsSelect(b)
	if b then
		self:select()
	else
		self:unselect()
	end

	return self
end

function btn:openFilter()
	if self.params.filter then
		self.bg:setFilter(self.params.filter)

		if self.sprite then
			self.sprite:setFilter(self.params.filter)
		end
	end
end

function btn:closeFilter()
	if self.params.filter then
		self.bg:clearFilter()

		if self.sprite then
			self.sprite:clearFilter()
		end
	end
end

function btn:handleTouch(event)
	local function click()
		if self.params.clickSpace then
			local curtime = socket.gettime()

			if self.lastClick and curtime - self.lastClick < self.params.clickSpace then
				return
			end

			self.lastClick = curtime
		end

		if self.params.select and not self.params.select.manual then
			if self.isSelect then
				self:unselect()
			else
				self:select()
			end
		end

		if self.listener then
			self:listener()
		end
	end

	local touchInBtn = true

	if self.params.customTouchCheck then
		touchInBtn = self.params.customTouchCheck(event.x, event.y)
	end

	if event.name == "began" and touchInBtn then
		self:touchIn(true)

		if self.params.support == "easy" then
			click()
		elseif self.params.support == "drag" or self.params.support == "scroll" then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(event.x, event.y)
			self.hasDrag = false
		end

		return true
	end

	if not self.params.customTouchCheck then
		touchInBtn = self:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))
	end

	if event.name == "moved" then
		if self.params.support == "drag" or self.params.support == "scroll" then
			if math.abs(self.beganTouchPos.x - event.x) > 10 or math.abs(self.beganTouchPos.y - event.y) > 10 then
				self.hasDrag = true
			end

			if self.hasDrag then
				if self.params.support == "drag" then
					self:pos(event.x - self.beganTouchPos.x + self.beganPos.x, event.y - self.beganTouchPos.y + self.beganPos.y)

					if self.params.call_drag_moving then
						self.params.call_drag_moving(self, event)
					end
				elseif self.params.support == "scroll" then
					self:touchIn(false)
				end
			end
		else
			self:touchIn(touchInBtn)
		end
	elseif event.name == "ended" then
		if self.params.support == "easy" then
			-- Nothing
		elseif self.params.support == "drag" then
			if self.hasDrag then
				if self.params.call_drag_end then
					self.params.call_drag_end(self, event)
				end
			elseif touchInBtn then
				click()
			end
		elseif self.params.support == "scroll" then
			if not self.hasDrag and touchInBtn then
				click()
			end
		elseif touchInBtn then
			click()
		end

		if not tolua.isnull(self) then
			self:touchIn(false)
		end
	else
		self:touchIn(false)
	end
end

return btn
