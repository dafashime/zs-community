local bottom = class("bottom", function ()
	return display.newNode()
end)

table.merge(bottom, {
	config,
	data,
	progress,
	mapTitle,
	mapPos,
	zoneInfo
})

function bottom:ctor(config, data)
	self:size(display.width, 28):anchor(0.5, 0.5):pos(data.x, data.y)

	local bg1 = res.get2("pic/console/bottom/bg1.png"):anchor(0, 0):add2(self)
	local bg2 = res.get2("pic/console/bottom/bg2.png"):anchor(0, 0):pos(bg1:getw(), 0):add2(self)
	local bg3 = res.get2("pic/console/bottom/bg3.png"):anchor(1, 0):pos(display.width, 0):add2(self)

	bg2:scalex((display.width - bg1:getw() - bg3:getw()) / bg2:getw())

	self.mapTitle = an.newLabel(g_data.map.mapTitle .. "", 16, 1):pos(2, 0):add2(self)
	self.zoneInfo = an.newLabel("", 16, 1):pos(4 + self.mapTitle:getw(), 0):add2(self)
	self.mapPos = an.newLabel("", 16, 1):pos(2, 20):add2(self)

	res.get2("pic/console/bottom/w1.png"):anchor(1, 0):pos(display.width, 0):add2(self)
	res.get2("pic/console/bottom/expFont.png"):anchor(1, 0.5):pos(display.width - 517, self:geth() / 2):add2(self)

	self.progress = an.newProgress(res.gettex2("pic/console/bottom/exp2.png"), res.gettex2("pic/console/bottom/expbg.png"), {
		x = 1,
		y = 5
	}):anchor(1, 0):pos(display.width - 107, 6):add2(self)
	self.text = an.newLabel("", 14, 1):anchor(0.5, 0.5):pos(self.progress:getw() / 2, self.progress:geth() / 2 + 3):add2(self.progress, 1)
end

function bottom:upt()
	local ability = g_data.player.ability
	local p = ability:get("Exp") / ability:get("maxExp")

	if p > 1 then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	self.progress:setp(p)
	self.text:setString(string.format("%s / %s (%.2f％)", ability:get("Exp"), tostring(ability:get("maxExp")), p * 100))
end

function bottom:update(dt)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player then
		return
	end

	self.mapPos:setString(player.x .. ":" .. player.y)
end

function bottom:uptMap()
	self.mapTitle:setString(g_data.map.mapTitle .. "")
	self.zoneInfo:setString(getMapStateStr(g_data.map.mapState))
	self.zoneInfo:pos(4 + self.mapTitle:getw(), 0)
	self.zoneInfo:setColor(g_data.map.mapState == 1 and display.COLOR_RED or display.COLOR_GREEN)
end

return bottom
