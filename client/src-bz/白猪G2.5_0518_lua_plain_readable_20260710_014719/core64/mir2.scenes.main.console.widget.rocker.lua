local staticAlpha = 122
local sizeMin = 200
local sizeMax = 400
local enabled = false
local x2 = 0
local y2 = 0
local count = 0
local count2 = 0
local cc2 = require("mir2.cc")
local common = require("mir2.scenes.main.common.common")
local rocker = class("rocker", function()
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
	if g_data.setting.base.singleRocker then
		self.default.type = 1
		self.data.type = 1
	else
		self.default.type = 2
		self.data.type = 2
	end

	if self.spr_walk then
		self.spr_walk:removeSelf()

		self.spr_walk = nil
	end

	if self.spr_run then
		self.spr_run:removeSelf()

		self.spr_run = nil
	end

	if self.data.type == 2 then
		self.spr_walk = res.get2("pic/console/rock_walk.png"):pos(self.walkSprPos(self)):add2(self, 1)

		self.spr_walk:setName("rocker_walk")

		self.spr_run = res.get2("pic/console/rock_run.png"):pos(self.runSprPos(self)):add2(self, 1)

		self.spr_run:setName("rocker_run")
	else
		self.spr_run = res.get2("pic/console/singlerock_run.png"):pos(self.runSprPos(self)):add2(self, 1)

		self.spr_run:setName("rocker_run")
	end
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
		valueChange = function(value)
			local size = (sizeMax - sizeMin) * value + sizeMin

			self.data.size = math.modf(size)

			upt(true)
		end,
		valueChangeEnd = function(value)
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
		local value = g_data.setting.base.single_rocket_pos or 0.5

		if value < 0.2 or value > 0.8 then
			value = 0.5
		end

		return self.getw(self) * value, self.geth(self) * value
	end

	return self.getw(self) * 0.66, self.geth(self) * 0.66
end

function rocker:showbg(b, x, y)
	if b then
		if self.data.type == 1 then
			if self.sprBg then
				self.sprBg:hide()
			end

			self.sprBg = res.get2("pic/console/rocker_walk.png"):add2(self)
		else
			if self.sprBg then
				self.sprBg:hide()
			end

			self.sprBg = res.get2("pic/console/rockBg.png"):add2(self)
		end

		x2 = x
		y2 = y

		self.sprBg:show():pos(x, y)
	elseif self.sprBg then
		self.sprBg:hide()
	end
end

function rocker:calcRockerBg()
	local text = ""

	if self >= 359.99 and self < 360 or self >= 0 and self < 0.01 then
		text = "pic/console/rocker_up.png"
		count = 0
	elseif self >= 0.01 and self < 0.02 then
		text = "pic/console/rocker_topright.png"
		count = 1
	elseif self >= 0.02 and self < 0.035 then
		text = "pic/console/rocker_right.png"
		count = 2
	elseif self >= 0.035 and self < 0.045 then
		text = "pic/console/rocker_downright.png"
		count = 3
	elseif self >= 0.045 and self <= 0.06 or self >= 359.94 and self < 359.95 then
		text = "pic/console/rocker_down.png"
		count = 4
	elseif self >= 359.95 and self < 359.96 then
		text = "pic/console/rocker_downleft.png"
		count = 5
	elseif self >= 359.96 and self < 359.98 then
		text = "pic/console/rocker_left.png"
		count = 6
	elseif self >= 359.98 and self < 359.99 then
		text = "pic/console/rocker_topleft.png"
		count = 7
	end

	return text
end

function rocker:handleTouch(event)
	local controller = main_scene.ui.console.controller
	local maxDis = 100
	local x = event.x - self.getPositionX(self) + self.getw(self) / 2
	local y = event.y - self.getPositionY(self) + self.geth(self) / 2

	if event.name == "began" then
		main_scene.ui.console.autoRat:stop()
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
		local value = math.atan2(x - self.use.beginPos.x, y - self.use.beginPos.y)
		local destx = x
		local desty = y
		local dis = cc.pGetDistance(self.use.beginPos, cc.p(destx, desty))

		if maxDis < dis then
			destx = self.use.beginPos.x + math.sin(angle) * maxDis
			desty = self.use.beginPos.y + math.cos(angle) * maxDis
		end

		self.use.spr:pos(destx, desty)

		if dis > self.use.len then
			local pi = 3.14
			local angle2 = 180 / pi * angle
			local value2 = pi / 180 * value

			if angle2 < 0 then
				angle2 = angle2 + 360
			end

			if value2 < 0 then
				value2 = value2 + 360
			end

			local value3
			local idx = math.ceil(angle2 / 22.5)
			local dir = (idx == 1 or idx == 16) and 0 or math.ceil(idx / 2 - 0.5)

			controller.move.enable = "dir"
			controller.move.dir = math.abs(dir)

			if self.data.type == 1 then
				local step = dis >= self.use.runLen and 2 or 1

				if step == 2 then
					local value4 = self.calcRockerBg(value2)

					if count2 ~= count or not enabled then
						if self.sprBg then
							self.sprBg:hide()
						end

						self.sprBg = res.get2(value4):add2(self)

						self.sprBg:show():pos(x2, y2)

						count2 = count
					end

					enabled = true
				elseif enabled then
					if self.sprBg then
						self.sprBg:hide()
					end

					self.sprBg = res.get2("pic/console/rocker_walk.png"):add2(self)

					self.sprBg:show():pos(x2, y2)

					enabled = false
				end

				self.use.step = step
				controller.move.step = self.use.step

				if controller.move.step == 1 and socket.gettime() - self.use.beginTime < 0.2 then
					controller.move.enable = false
				end
			else
				controller.move.step = self.use.step
			end

			local stateOwner = main_scene.ground.player

			if def.openHorse and dis >= 150 and g_data.setting.autoRat.autoShangma and stateOwner and not def.stateIsHave(stateOwner.state, "stHorse") then
				if def.role.attacking or def.role.beAttacking then
					if g_data.client:checkLastTime("shangmatips", 5) then
						g_data.client:setLastTime("shangmatips", true)
						main_scene.ui:tip("未脱离攻击状态无法自动上马")
					end

					return
				end

				if not g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
					return
				end

				if g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
					g_data.client:setLastTime("docsZaiMaShang", true)

					local value5 = main_scene.ui.console:get("btnHorse")

					if value5 then
						controller:showcd(value5, 0.5, 0.5)
					end

					main_scene.ui.console.autoRat:stop()
					controller.lock:stop()
					controller.lock:stopAttack()

					self.use.aothShangma = true

					def.role.call("@shangma")
				end
			end
		else
			controller.move.enable = false
		end
	elseif event.name == "ended" then
		if common.cancelBackhome then
			common.cancelBackhome()
		end

		local stateOwner2 = main_scene.ground.player

		if def.openHorse and self.use.aothShangma and g_data.setting.autoRat.autoShangma and stateOwner2 and def.stateIsHave(stateOwner2.state, "stHorse") and g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
			g_data.client:setLastTime("docsZaiMaShang", true)

			local value6 = main_scene.ui.console:get("btnHorse")

			if value6 then
				controller:showcd(value6, 0.5, 0.5)
			end

			self.use.aothShangma = false

			def.role.call("@xiama")
		end

		local angle3 = math.atan2(self.use.spr:getPositionX() - self.use.originPos.x, self.use.spr:getPositionY() - self.use.originPos.y)
		local dis2 = cc.pGetDistance(self.use.originPos, cc.p(self.use.spr:getPosition())) + 20
		local destx2 = self.use.spr:getPositionX() - math.sin(angle3) * dis2
		local desty2 = self.use.spr:getPositionY() - math.cos(angle3) * dis2

		self.use.spr:runs({
			cc.MoveTo:create(0.2, cc.p(destx2, desty2)),
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
			scheduler.performWithDelayGlobal(function()
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
