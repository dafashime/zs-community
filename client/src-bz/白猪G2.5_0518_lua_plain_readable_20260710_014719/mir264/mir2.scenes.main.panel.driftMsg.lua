local driftMsg = class("driftMsg", function()
	return display.newNode()
end)

table.merge(driftMsg, {
	btn,
	btns,
	beganPos,
	beganTouchPos,
	hasMove,
	lock,
	content
})

function driftMsg:ctor()
	self.btn = res.get2("pic/console/iconbg8.png")

	self.btn:pos(self.btn:centerPos()):add2(self, 1):setCascadeOpacityEnabled(true)
	res.get2("pic/debug/icon.png"):pos(self.btn:centerPos()):add2(self.btn)
	self:setCascadeOpacityEnabled(true)
	self:size(self.btn:getw(), self.btn:geth()):anchor(0.5, 0.5):pos(self:getw() / 2, display.height - self:geth() / 2):opacity(0):runs({
		cc.FadeIn:create(1),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function()
			self:opacity(128)
		end)
	})
	self.btn:setTouchEnabled(true)
	self.btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if self.lock then
			return
		end

		if event.name == "began" then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(event.x, event.y)
			self.hasMove = false

			self:opacity(255)
			self:scale(1)
			self:stopAllActions()
		elseif event.name == "moved" then
			if self.hasMove or math.abs(self.beganTouchPos.x - event.x) > 10 or math.abs(self.beganTouchPos.y - event.y) > 10 then
				self.hasMove = true

				local x, y = event.x - self.beganTouchPos.x + self.beganPos.x, event.y - self.beganTouchPos.y + self.beganPos.y

				x = x < 0 and 0 or x
				x = x > display.width and display.width or x
				y = y < 0 and 0 or y
				y = y > display.height and display.height or y

				self:pos(x, y)
			end
		elseif event.name == "ended" then
			local function newx(x)
				x = x < self:getw() / 2 and self:getw() / 2 or x
				x = x > display.width - self:getw() / 2 and display.width - self:getw() / 2 or x

				return x
			end

			local function newy(y)
				y = y < self:geth() / 2 and self:geth() / 2 or y
				y = y > display.height - self:geth() / 2 and display.height - self:geth() / 2 or y

				return y
			end

			local function bothXY(x, y)
				if y < self:geth() then
					x = newx(x)
					y = self:geth() / 2
				elseif y > display.height - self:geth() then
					x = newx(x)
					y = display.height - self:geth() / 2
				elseif x > display.cx then
					x = display.width - self:getw() / 2
					y = newy(y)
				else
					x = self:getw() / 2
					y = newy(y)
				end

				return x, y
			end

			local function goto(x, y)
				if self.content then
					self:moveTo(0.25, x, y)
				else
					self:runs({
						cc.MoveTo:create(0.25, cc.p(x, y)),
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							self:opacity(128)
						end)
					})
				end
			end

			if not self.hasMove then
				self.lock = true

				self.btn:runs({
					cc.ScaleTo:create(0.1, 0.01),
					cc.ScaleTo:create(0.1, 1),
					cc.CallFunc:create(function()
						self.lock = nil

						if self.content then
							self.content:removeSelf()

							self.content = nil

							goto(bothXY(self:getPosition()))
						else
							self:createContentBase()
						end
					end)
				})
			else
				local x, y = event.x - self.beganTouchPos.x + self.beganPos.x, event.y - self.beganTouchPos.y + self.beganPos.y

				if self.content then
					x, y = newx(x), newy(y)
				else
					x, y = bothXY(x, y)
				end

				goto(x, y)
			end
		end

		return true
	end)
end

function driftMsg:createContentBase(type)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():anchor(0, 1):pos(self.btn:getw() / 2 + 5, self.btn:geth() / 2 - 5):size(240, 140):add2(self)
	self.content.type = type

	display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(self.content:getContentSize()):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)
end

return driftMsg
