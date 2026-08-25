local staticAlpha = 122
local sizeMin = 200
local sizeMax = 400
local rocker = class("rocker", function ()
	return display.newNode()
end)

table.merge(rocker, {
	config,
	data,
	spr_walk,
	spr_run,
	sprBg,
	beginPos,
	use = {
		beginPos,
		originPos,
		step,
		spr,
		len
	},
	default = {
		size = 300,
		type = 2
	}
})

function rocker:ctor(config, data)
	data.size = data.size or self.default.size
	data.type = self.default.type

	self:size(data.size, data.size):anchor(0.5, 0.5):pos(data.x, data.y)

	self.data = data
	self.config = config

	self:loadSpr()
end

function rocker:loadSpr()
	if self.spr_walk then
		self.spr_walk:removeSelf()

		self.spr_walk = nil
	end

	if self.spr_run then
		self.spr_run:removeSelf()

		self.spr_run = nil
	end

	if self.data.type == 2 then
		self.spr_walk = res.get2("pic/console/rock1.png"):pos(self:walkSprPos()):add2(self, 1)

		self.spr_walk:setName("rocker_walk")
	end

	self.spr_run = res.get2("pic/console/rock2.png"):pos(self:runSprPos()):add2(self, 1)

	self.spr_run:setName("rocker_run")
end

function rocker:getEditNode()
	local node = display.newNode():size(400, 80)
	local num = an.newLabel("", 16, 1, {
		color = cc.c3b(0, 255, 255)
	}):add2(node):anchor(0.5, 1):pos(node:getw() / 2, node:geth())

	local function upt(uptUI)
		num:setString("摇杆大小(" .. self.data.size .. ")")

		if uptUI then
			self:size(self.data.size, self.data.size)

			if self.spr_walk then
				self.spr_walk:pos(self:walkSprPos())
			end

			self.spr_run:pos(self:runSprPos())
			self:_sizeChanged()
		end
	end

	upt()

	local slider = an.newSlider(res.gettex2("pic/common/sliderBg.png"), res.gettex2("pic/common/sliderBar.png"), res.gettex2("pic/common/sliderBlock.png"), {
		value = (self.data.size - sizeMin) / (sizeMax - sizeMin),
		valueChange = function (value)
			local size = (sizeMax - sizeMin) * value + sizeMin
			self.data.size = math.modf(size)

			upt(true)
		end,
		valueChangeEnd = function (value)
			local size = (sizeMax - sizeMin) * value + sizeMin
			self.data.size = math.modf(size)

			upt(true)
		end
	}):add2(node):anchor(0.5, 0.5):pos(node:getw() / 2, node:geth() - 50)

	return node
end

function rocker:walkSprPos()
	return self:getw() * 0.33, self:geth() * 0.33
end

function rocker:runSprPos()
	if self.data.type == 1 then
		return self:getw() * 0.5, self:geth() * 0.5
	end

	return self:getw() * 0.66, self:geth() * 0.66
end

function rocker:showbg(b, x, y)
	if b then
		if not self.sprBg then
			self.sprBg = res.get2("pic/console/rockBg.png"):add2(self)
		end

		self.sprBg:show():pos(x, y)
	elseif self.sprBg then
		self.sprBg:hide()
	end
end

function rocker:handleTouch(event)
	local controller = main_scene.ui.console.controller
	local maxDis = 100
	local x = event.x - self:getPositionX() + self:getw() / 2
	local y = event.y - self:getPositionY() + self:geth() / 2

	if event.name == "began" then
		controller.autoFindPath:multiMapPathStop()

		self.use = {
			beginRealPos = cc.p(event.x, event.y),
			beginPos = cc.p(x, y),
			beginTime = socket.gettime()
		}

		if self.data.type == 1 then
			self.use.spr = self.spr_run
			self.use.originPos = cc.p(self:runSprPos())
			self.use.len = 30
			self.use.runLen = 80
		elseif x <= self:getw() / 2 and y <= self:geth() / 2 then
			self.use.spr = self.spr_walk
			self.use.step = 1
			self.use.originPos = cc.p(self:walkSprPos())
			self.use.len = 30
		else
			self.use.spr = self.spr_run
			self.use.step = 2
			self.use.originPos = cc.p(self:runSprPos())
			self.use.len = 40
		end

		self.use.spr:stopAllActions()
		self.use.spr:pos(x, y)
		self:showbg(true, x, y)

		return true
	elseif event.name == "moved" then
		local angle = math.atan2(x - self.use.beginPos.x, y - self.use.beginPos.y)
		local destx = x
		local desty = y
		local dis = cc.pGetDistance(self.use.beginPos, cc.p(destx, desty))

		if maxDis < dis then
			destx = self.use.beginPos.x + math.sin(angle) * maxDis
			desty = self.use.beginPos.y + math.cos(angle) * maxDis
		end

		self.use.spr:pos(destx, desty)

		if self.use.len < dis then
			local pi = 3.14
			angle = 180 / pi * angle

			if angle < 0 then
				angle = angle + 360
			end

			local dir = nil
			local idx = math.ceil(angle / 22.5)
			dir = (idx == 1 or idx == 16) and 0 or math.ceil(idx / 2 - 0.5)
			controller.move.enable = "dir"
			controller.move.dir = math.abs(dir)

			if self.data.type == 1 then
				controller.move.step = self.use.runLen <= dis and 2 or 1

				if controller.move.step == 1 and socket.gettime() - self.use.beginTime < 0.2 then
					controller.move.enable = false
				end
			else
				controller.move.step = self.use.step
			end

			if main_scene.ui.console.autoRat.enableRat then
				main_scene.ui.console.autoRat:stop()
			end
		else
			controller.move.enable = false
		end
	elseif event.name == "ended" then
		local angle = math.atan2(self.use.spr:getPositionX() - self.use.originPos.x, self.use.spr:getPositionY() - self.use.originPos.y)
		local dis = cc.pGetDistance(self.use.originPos, cc.p(self.use.spr:getPosition())) + 20
		local destx = self.use.spr:getPositionX() - math.sin(angle) * dis
		local desty = self.use.spr:getPositionY() - math.cos(angle) * dis

		self.use.spr:runs({
			cc.MoveTo:create(0.2, cc.p(destx, desty)),
			cc.MoveTo:create(0.1, self.use.originPos)
		})
		self:showbg()

		controller.move.enable = false

		if math.abs(self.use.beginRealPos.x - event.x) < 10 and math.abs(self.use.beginRealPos.y - event.y) < 10 and socket.gettime() - self.use.beginTime < 25 then
			main_scene.ui.console.controller:handleTouch({
				name = "began",
				x = event.x,
				y = event.y
			})
			scheduler.performWithDelayGlobal(function ()
				main_scene.ui.console.controller:handleTouch({
					name = "ended",
					x = event.x,
					y = event.y
				})
			end, 0)
		end
	end
end

return rocker
