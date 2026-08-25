local common = import("..common.common")
local screenshot = class("screenshot", function ()
	return display.newNode()
end)

table.merge(screenshot, {
	canvas,
	editBtn,
	editting,
	tools,
	colorPoints
})

function screenshot:ctor()
	self._supportMove = true

	sound.playSound("screen")

	local color = nil
	color = display.newColorLayer(cc.c4b(255, 255, 255, 255)):add2(self):runs({
		cc.FadeOut:create(1),
		cc.CallFunc:create(function ()
			color:removeSelf()
			main_scene.ground.map:setTopRender(false)

			local glview = cc.Director:getInstance():getOpenGLView()

			glview:setDesignResolutionSize(display.sizeInPixels.width, display.sizeInPixels.height, cc.ResolutionPolicy.NO_BORDER)

			local screen = printscreen(main_scene)

			screen:retain()

			local listener = nil
			listener = cc.EventListenerCustom:create("director_after_draw", function ()
				glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)
				main_scene.ground.map:setTopRender(true)
				self:show(screen)
				screen:release()
				cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)
			end)

			cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
		end)
	})
end

function screenshot:show(screen)
	local picw = 615
	local picscale = picw / screen:getw()
	local pich = screen:geth() * picscale
	local size = cc.size(picw, pich)
	self.canvas = display.newNode():pos(13, 60):size(picw, pich):add2(self)
	self.canvas.output = display.newNode():size(picw, pich):add2(self.canvas)

	screen:scale(picscale):anchor(0, 0):add2(self.canvas.output)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, size):pos(self.canvas:getPosition()):anchor(0, 0):add2(self)

	local controlHeight = 110
	local b1 = res.get2("pic/panels/bigmap/bg1.png")
	local b2 = res.get2("pic/panels/bigmap/bg2.png")
	local b3 = res.get2("pic/panels/bigmap/bg3.png")

	self:size(b1:getw(), size.height + controlHeight):anchor(0.5, 0.5):center()
	self:addTouchFrame(cc.rect(0, 0, self:getw(), self:geth()), "main")
	self:scale(1 / picscale):scaleTo(0.2, 1)
	b3:anchor(0, 0):add2(self, -1)
	b2:anchor(0, 0):pos(0, b3:geth()):scaleY((self:geth() - b1:geth() - b3:geth()) / b2:geth()):add2(self, -1)
	b1:anchor(0, 1):pos(0, self:geth()):add2(self, -1)
	res.get2("pic/panels/screenshot/title.png"):add2(b1):pos(b1:getw() / 2, b1:geth() - 23)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):anchor(1, 1):pos(self:getw() - 5, self:geth() - 5):addto(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		pic.upload(self.canvas.output, common.getPlayerName())
		self:hide()
		scheduler.performWithDelayGlobal(function ()
			self:runs({
				cc.Show:create(),
				cc.ScaleTo:create(0.2, 0.01),
				cc.CallFunc:create(function ()
					self:hidePanel()
				end)
			})
		end, 0)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/screenshot/send.png")
	}):anchor(1, 1):pos(self:getw() - 13, 54):add2(self)

	self.editBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		if self.tools then
			self.tools:removeSelf()

			self.tools = nil
		end

		if self.colorPoints then
			for i, v in ipairs(self.colorPoints) do
				v:removeSelf()
			end

			self.colorPoints = nil
		end

		self.editting = not self.editting

		if self.editting then
			self.editBtn.sprite:setTex(res.gettex2("pic/panels/screenshot/reset.png"))
			self:showTools()
		else
			self.editBtn.sprite:setTex(res.gettex2("pic/panels/screenshot/edit.png"))
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/screenshot/edit.png")
	}):anchor(1, 1):pos(self:getw() - 133, 54):add2(self)
end

function screenshot:showTools()
	self.tools = display.newNode():add2(self)
	local colors = {
		cc.c4b(255, 0, 0, 255),
		cc.c4b(250, 155, 19, 255),
		cc.c4b(255, 255, 0, 255),
		cc.c4b(0, 255, 0, 255),
		cc.c4b(0, 255, 255, 255),
		cc.c4b(255, 0, 255, 255)
	}
	local colorPos = cc.p(20, 18)
	local selectIdx = 1
	local pre = nil

	for i, v in ipairs(colors) do
		display.newColorLayer(v):size(37, 37):pos(colorPos.x + (i - 1) * 45 - 2, colorPos.y - 2):add2(self.tools):anchor(0.5, 0.5)

		local btn = nil
		btn = res.get2("pic/panels/screenshot/frame.png"):anchor(0.5, 0.5):pos(colorPos.x + (i - 1) * 45 + 17, colorPos.y + 17):add2(self.tools):enableClick(function ()
			if pre then
				pre:setTouchEnabled(true)
				pre:setColor(cc.c3b(255, 255, 255))
			end

			pre = btn

			btn:setTouchEnabled(false)
			btn:setColor(cc.c3b(255, 0, 0))

			selectIdx = i
		end, {
			ani = false
		})

		if not pre then
			pre = btn

			btn:setTouchEnabled(false)
			btn:setColor(cc.c3b(255, 0, 0))
		end
	end

	self.colorPoints = {}
	local size = 6

	local function add(x, y)
		if x - size / 2 < 0 or y - size / 2 < 0 or self.canvas:getw() < x + size / 2 or self.canvas:geth() < y + size / 2 then
			return
		end

		self.colorPoints[#self.colorPoints + 1] = display.newColorLayer(colors[selectIdx]):size(size, size):pos(x - size / 2, y - size / 2):add2(self.canvas.output)
	end

	local lastpos = nil
	local touchNode = display.newNode():size(self.canvas:getContentSize()):pos(self.canvas:getPosition()):add2(self.tools)

	touchNode:setTouchEnabled(true)
	touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		local rect1 = self:getBoundingBox()
		local rect2 = self.canvas:getBoundingBox()
		local x = event.x - rect1.x - rect2.x
		local y = event.y - rect1.y - rect2.y

		if event.name == "began" then
			add(x, y)

			lastpos = cc.p(x, y)

			return true
		elseif event.name == "moved" then
			local stepMax = math.modf(math.max(math.abs(x - lastpos.x), math.abs(y - lastpos.y)) / (size / 2))
			local stepx = math.abs(x - lastpos.x) / stepMax
			local stepy = math.abs(y - lastpos.y) / stepMax
			local nextx = lastpos.x
			local nexty = lastpos.y

			for i = 1, stepMax do
				if nextx < x then
					nextx = nextx + stepx
				else
					nextx = nextx - stepx
				end

				if nexty < y then
					nexty = nexty + stepy
				else
					nexty = nexty - stepy
				end

				add(nextx, nexty)
			end

			add(x, y)

			lastpos = cc.p(x, y)
		elseif event.name == "ended" then
			add(x, y)
		end
	end)
end

return screenshot
