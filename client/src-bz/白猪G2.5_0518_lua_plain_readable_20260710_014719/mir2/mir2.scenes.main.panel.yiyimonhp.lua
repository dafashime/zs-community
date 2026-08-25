local yiyimon = class("yiyimon", function()
	return display.newNode()
end)

table.merge(diy, {
	data
})

function yiyimon:ctor(yiyirole, label2)
	self._supportMove = false
	g_data.yiyirole = yiyirole

	local color = display.COLOR_WHITE
	local text = "pic/panels/yiyi/mon/head.png"
	local x = display.width / 2
	local y = display.height - 60

	if def.mon_cfg then
		if def.mon_cfg.monheadpos then
			x = def.mon_cfg.monheadpos.x or x
			y = def.mon_cfg.monheadpos.y or y
		end

		if def.mon_cfg[label2] then
			color = def.mon_cfg[label2].color or display.COLOR_WHITE
			text = "pic/panels/yiyi/mon/" .. (def.mon_cfg[label2].head or "pic/panels/yiyi/mon/head") .. ".png"
		end
	end

	if yiyirole.__cname == "hero" then
		text = "pic/panels/yiyi/mon/phead.png"
	end

	local value_2 = res.get2("pic/panels/yiyi/mon/bg.png"):anchor(0, 0):add2(self):pos(0, 0)
	local value_22 = res.get2("pic/panels/yiyi/mon/bghp.png"):anchor(0, 0):add2(value_2):pos(0, -15)

	self.head = res.get2(text):anchor(0.5, 0.3):add2(value_2):pos(-30, 0)

	self:size(value_2:getw(), value_2:geth()):anchor(0.5, 0.5):pos(x, y)

	self.sprhp = display.newSprite(res.gettex2("pic/panels/yiyi/mon/hp.png")):add2(value_22):anchor(0, 0):pos(2, 2)
	self.label = an.newLabel("", 16, 1, {
		bufferChannel = 0
	}):pos(self:getw() / 2, 8):anchor(0.5, 0.5):addTo(self.sprhp)
	self.label2 = an.newLabel(label2, 16, 1, {
		bufferChannel = 0,
		color = color
	}):pos(self:getw() / 2, self:geth() / 2 + 5):anchor(0.5, 0):addTo(value_22)
end

function yiyimon:updateHP(text, deltaTime)
	local value = text / deltaTime

	if deltaTime >= 1000000 or main_scene.ground:smr() then
		local value2 = value * 100
		local text2 = string.format("%d", value2)

		self.label:setString(text2 .. "%")
	else
		self.label:setString(tostring(text) .. "/" .. tostring(deltaTime))
	end

	local value3 = math.min(1, math.max(text / (deltaTime == 0 and 1 or deltaTime), 0))

	self.sprhp:setTextureRect(cc.rect(0, 0, self:getw() * value3, self.sprhp:geth()))
end

return yiyimon
