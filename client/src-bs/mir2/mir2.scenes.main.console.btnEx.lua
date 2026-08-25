local h = 80
local btnEx = class("btnEx", function ()
	return display.newNode()
end)

table.merge(btnEx, {
	bg,
	content,
	btns
})

function btnEx:hide()
	self:removeSelf()

	if main_scene then
		main_scene:stopAllActions()
		main_scene:moveTo(0.2, 0, 0)
		main_scene.ground:stopAllActions()
		main_scene.ground:moveTo(0.2, 0, 0)

		if not tolua.isnull(main_scene.ground.helper.runner.guide.guideLayer) then
			main_scene.ground.helper.runner.guide.guideLayer:stopAllActions()
			main_scene.ground.helper.runner.guide.guideLayer:moveTo(0.2, 0, 0)
		end
	end
end

function btnEx:ctor()
	self:setNodeEventEnabled(true)

	self.btns = {}

	if main_scene then
		main_scene:stopAllActions()
		main_scene:moveTo(0.2, 0, h)
		main_scene.ground:stopAllActions()
		main_scene.ground:moveTo(0.2, 0, -h / 2)

		if not tolua.isnull(main_scene.ground.helper.runner.guide.guideLayer) then
			main_scene.ground.helper.runner.guide.guideLayer:stopAllActions()
			main_scene.ground.helper.runner.guide.guideLayer:moveTo(0.2, 0, -h)
		end
	end

	self:size(display.width, display.height):add2(display.getRunningScene(), an.z.max)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			self:hide()
		end
	end)

	self.bg = display.newScale9Sprite(res.getframe2("pic/console/boardscale.png")):anchor(0, 1):add2(self):size(display.width, h)

	self:loadMain()
end

function btnEx:onCleanup()
	if self.btns.stall then
		self.btns.stall:stopTime()
	end
end

function btnEx:loadMain()
	self.content = display.newNode():pos(0, -h):size(display.width, h):add2(self):enableClick(function ()
	end)
	local btns = {
		"equip",
		"bag",
		"skill",
		"group",
		"guild",
		"relation",
		"top",
		"deal",
		"stall",
		"mail",
		"setting",
		"shop",
		"link"
	}

	if VERSION_REVIEW then
		btns = {
			"bag",
			"equip",
			"skill",
			"deal",
			"group",
			"guild",
			"relation",
			"top",
			"shop",
			"setting"
		}
	end

	local space = 80
	local allwidth = #btns * space
	local scale = allwidth < display.width and 1 or display.width / allwidth
	allwidth = allwidth * scale
	space = space * scale

	for i, v in ipairs(btns) do
		local btn = an.newBtn(res.gettex2("pic/console/iconbg11.png"), function ()
			sound.playSound("103")
			main_scene.ui.console.btnCallbacks:handle("panel", v)
			self:hide()
		end, {
			pressBig = true,
			sprite = res.gettex2("pic/console/panel-icons/" .. v .. ".png")
		}):pos(display.cx - allwidth / 2 + (i - 0.5) * space, h / 2):scale(scale):add2(self.content)
		self.btns[v] = btn

		btn:setName("btnEx_" .. v)

		if self[v .. "Extend"] then
			self[v .. "Extend"](self, btn)
		end
	end

	self.btns.stall:startTime()
end

function btnEx:stallExtend(target)
	local function getTime(time)
		if time > 43200 then
			p2("other", "[Stall sys]: Stall time is out of 12 hours!")

			return ""
		end

		local hour = math.floor(time / 3600)
		local min = math.floor(time / 60 - hour * 60)
		local sec = time - hour * 3600 - min * 60

		return string.format("%02d:%02d:%02d", hour, min, sec)
	end

	function target:startTime()
		target:stopTime()

		target.time = g_data.stall.time

		if target.time > 0 then
			if not target.label then
				target.label = an.newLabel(getTime(target.time), 16, 1, {
					color = def.colors.labelGray
				}):addTo(target):pos(target:getw() / 2, 45):anchor(0.5, 0.5)
			end

			target._scheduler = scheduler.scheduleGlobal(function ()
				if target.time > 0 then
					target.time = target.time - 1

					target.label:setString(getTime(target.time))
				else
					target.label:setString("")
					scheduler.unscheduleGlobal(target._scheduler)

					target._scheduler = nil
				end
			end, 1)
		end
	end

	function target:stopTime()
		target.time = 0

		if target._scheduler then
			scheduler.unscheduleGlobal(target._scheduler)

			target._scheduler = nil
		end
	end
end

return btnEx
