local diyBtn = class("diyBtn", function()
	return display.newNode()
end)

table.merge(diyBtn, {
	btn,
	btns,
	beganPos,
	beganTouchPos,
	hasMove,
	lock
})

function diyBtn:ctor()
	self.btn = res.get2("pic/panels/diy/icon.png"):anchor(0, 0):add2(self)

	self:setCascadeOpacityEnabled(true)
	self:size(self.btn:getw(), self.btn:geth()):anchor(0.5, 0.5):pos(main_scene.ui.panels.diy:getPosition()):opacity(0):runs({
		cc.FadeIn:create(1),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function()
			self:opacity(128)
		end)
	}):add2(main_scene.ui, main_scene.ui.z.diyBtn)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
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
			if not self.hasMove then
				self.lock = true

				self:runs({
					cc.ScaleTo:create(0.2, 0.01),
					cc.CallFunc:create(function()
						self:removeSelf()

						if main_scene.ui.panels.diy then
							main_scene.ui.panels.diy:setShow(self:getPosition())
						end
					end)
				})
			else
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

				local x, y = event.x - self.beganTouchPos.x + self.beganPos.x, event.y - self.beganTouchPos.y + self.beganPos.y

				x, y = newx(x), newy(y)

				if false then
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
				end

				self:runs({
					cc.MoveTo:create(0.25, cc.p(x, y)),
					cc.DelayTime:create(3),
					cc.CallFunc:create(function()
						self:opacity(128)
					end)
				})
			end
		end

		return true
	end)
end

return diyBtn
