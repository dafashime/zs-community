local mapDef = import("..map.def")
local stall = class("stall", function()
	return display.newNode()
end)

table.merge(stall, {})

function stall:ctor(params)
	self:setNodeEventEnabled(true)

	self.x = params.x
	self.y = params.y
	self.map = params.map
	self.id = params.data.id
	self.level = params.data.msg
	self.username = params.data.desc
	self.name = params.data.name
	self.npc = display.newNode():size(cc.size(25, 70)):addTo(self):pos(25, 35):anchor(0, 1)

	m2spr.playAnimation("npc", 1560, 4, 0.3, false, false, false):addTo(self):pos(mapDef.tile.w - 35, -1 * mapDef.tile.h + 15)

	self.stall = res.get2("pic/panels/stall/stall" .. self.level .. ".png"):addTo(self):pos(0, 0):anchor(0, 1)

	an.newLabel(self.username .. "", 14, 1, {
		color = display.COLOR_WHITE
	}):addTo(self):pos(self.npc:getPositionX() + self.npc:getw() / 2, self.npc:getPositionY() - self.npc:geth() + 25):anchor(0.5, 0.5)
	an.newLabel(self.name, 14, 1, {
		color = cc.c3b(232, 150, 40)
	}):addTo(self):pos(self.npc:getPositionX() + self.npc:getw() / 2, self.npc:getPositionY() + 10):anchor(0.5, 0.5)

	function self.onCleanup()
		self.map:removeStall(params.serverID)
	end
end

return stall
