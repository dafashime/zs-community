local panelSize = cc.size(120, 120)
local role = import("..role.role")
local common = import("..common.common")
local minimap = class("minimap", function ()
	return display.newClippingRectangleNode(cc.rect(0, 0, panelSize.width, panelSize.height))
end)

table.merge(minimap, {})

local __position = cc.Node.setPosition

function minimap:createPointTexture()
	local dn = cc.DrawNode:create()

	dn:drawPoint(cc.p(0, 0), 8, cc.c4f(1, 1, 1, 1))

	local pointTexture = cc.RenderTexture:create(1, 1)

	pointTexture:begin()
	dn:visit()
	pointTexture:endToLua()
	pointTexture:retain()

	return pointTexture:getSprite():getTexture()
end

function minimap:ctor()
	self:setNodeEventEnabled(true)
	self:size(panelSize.width, panelSize.height):anchor(1, 1):pos(display.width, display.height - 29)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, cc.size(self:getw(), self:geth())):anchor(0, 0):add2(self, 1)

	self.isTranslucent = true

	display.newNode():size(self:getw(), self:geth()):add2(self):enableClick(function ()
		if self.bg then
			if main_scene.ui.panels.bigmap then
				main_scene.ui:hidePanel("bigmap")
			else
				main_scene.ui:showPanel("bigmap")
			end
		end
	end)

	if main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead:isInPos("hideMap") then
		main_scene.ui.panels.heroHead:resetPanelPosition("openMap")
	end

	minimap.pointTexture = minimap.pointTexture or self:createPointTexture()

	self:reload()
end

function minimap:onCleanup()
	if main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead:isInPos("openMap") then
		main_scene.ui.panels.heroHead:resetPanelPosition("hideMap")
	end
end

function minimap:reload()
	if self.bg then
		self.bg:removeSelf()

		self.bg = nil
	end

	if self.pointNode then
		self.pointNode:removeSelf()

		self.pointNode = nil
	end

	self.points = {}
	self.pointDns = {}
	self.percent = nil

	common.getMinimapTexture(main_scene.ground.map.mapid, function (tex)
		if tex then
			self:load(tex)
		else
			common.addMsg("没有可用的地图", def.colors.clRed, 256)
		end
	end)
end

function minimap:load(tex)
	self.cameraPow = 1

	if main_scene.ground.map then
		self.cameraPow = math.max(main_scene.ground.map.w / tex:getContentSize().width * 2, 0.6)
	end

	self.bg = display.newSprite(tex):anchor(0, 0):add2(self):scale(self.cameraPow)
	self.pointNode = display.newNode():size(self.bg:getContentSize()):add2(self):scale(self.cameraPow)

	self:scroll(main_scene.ground.map, main_scene.ground.player)

	if main_scene.ground.map then
		local roles = {}

		table.merge(roles, main_scene.ground.map.heros)
		table.merge(roles, main_scene.ground.map.mons)
		table.merge(roles, main_scene.ground.map.npcs)

		for k, v in pairs(roles) do
			self:pointUpt(main_scene.ground.map, v)
		end
	end

	if main_scene.ui.panels.bigmap then
		main_scene.ui:hidePanel("bigmap")
		main_scene.ui:showPanel("bigmap")
	end
end

function minimap:setTranslucent(isTranslucent)
	self.isTranslucent = isTranslucent

	if self.bg then
		self.bg:opacity(isTranslucent and 128 or 255)
	end
end

function minimap:computePercent(map)
	if not self.percent and self.bg then
		local size = self.bg:getTexture():getContentSize()
		self.percent = {
			x = size.width / map.w,
			y = size.height / map.h
		}
	end
end

function minimap:scroll(map, player)
	if not self.bg or not map or not player then
		return
	end

	self:computePercent(map)

	local x = math.max(0, player.x * self.percent.x - self:getw() / 2 / self.cameraPow)
	local y = math.max(0, player.y * self.percent.y - self:geth() / 2 / self.cameraPow)

	self.bg:setTextureRect(cc.rect(x, y, self:getw() / self.cameraPow, self:geth() / self.cameraPow))

	local size = self.bg:getTexture():getContentSize()
	x = math.max(0, player.x * self.percent.x * self.cameraPow - self:getw() / 2)
	y = math.max(0, player.y * self.percent.y * self.cameraPow - self:geth() / 2)

	self.pointNode:pos(-x, y + self:geth() - size.height * self.cameraPow)
end

function minimap:addPoint(role)
	if not self.bg or role.die then
		return
	end

	local color = nil
	local race = role:getRace()
	local pointsSz = 8 / self.cameraPow

	if checkExist(race, 50, 12) then
		color = 215
	elseif checkExist(race, 0, 150) then
		color = 251

		if g_data.player.roleid == role.roleid then
			color = 255
		end
	else
		color = 249
	end

	local point = display.newSprite(minimap.pointTexture):add2(self.pointNode):scale(3 / self.cameraPow)
	self.points[role.roleid] = point

	point:setColor(def.colors.get(color, true))

	return point
end

function minimap:removePoint(roleid)
	if self.points[roleid] then
		self.points[roleid]:removeSelf()

		self.points[roleid] = nil
	end
end

function minimap:pointUpt(map, role)
	if not self.bg then
		return
	end

	if role.die then
		self:removePoint(role.roleid)
	else
		local point = self.points[role.roleid]
		point = point or self:addPoint(role)

		self:computePercent(map)
		__position(point, role.x * self.percent.x - point:getw() / 2, (map.h - role.y - 1) * self.percent.y - point:geth() / 2)
	end
end

return minimap
