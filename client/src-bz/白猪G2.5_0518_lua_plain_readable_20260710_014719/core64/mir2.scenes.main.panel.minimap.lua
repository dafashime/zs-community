local panelSize = cc.size(120, 120)
local role = import("..role.role")
local common = import("..common.common")
local minimap = class("minimap", function()
	return display.newClippingRectangleNode(cc.rect(0, 0, panelSize.width, panelSize.height))
end)

table.merge(minimap, {})

local position = cc.Node.setPosition

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

function minimap:startEdit()
	self.diyMask = display.newNode():size(self:getContentSize()):addto(self, 999)

	self.diyMask:setTouchEnabled(true)
end

function minimap:endEdit()
	if self.diyMask then
		self.diyMask:removeSelf()

		self.diyMask = nil
	end
end

local function callback()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

function minimap:ctor()
	self:setNodeEventEnabled(true)
	self:size(panelSize.width, panelSize.height):anchor(1, 1):pos(display.width, display.height - (def.minimapHeightOffet or 30))
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, cc.size(self:getw(), self:geth())):anchor(0, 0):add2(self, 1)
	res.get2("pic/console/emptyminimap.png"):size(self:getw() - 2, self:geth() - 2):anchor(0, 0):pos(1, 1):add2(self)

	self.mmapPos = an.newLabel("0:0", 13, 1, {
		color = cc.c3b(245, 245, 245)
	}):pos(self:getw() - 5, 15):addTo(self, 99999999):anchor(1, 0.5)
	self.zoneSafe = an.newLabel("", 13, 1, {
		color = cc.c3b(245, 245, 245)
	}):pos(5, 15):addTo(self, 99999999):anchor(0, 0.5)
	self.maploading = an.newLabel("小地图生成中", 12, 1, {
		color = display.COLOR_GREEN
	}):pos(self:getw() / 2, self:geth() / 2):addTo(self):anchor(0.5, 0.5)
	self.mapInfo = an.newLabel("", 13, 1, {
		color = display.COLOR_GREEN
	}):pos(self:getw() / 2, self:geth() - 13):addTo(self, 99999999):anchor(0.5, 0.5)
	self.isTranslucent = true
	self.dark = {}

	if main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead:isInPos("hideMap") then
		main_scene.ui.panels.heroHead:resetPanelPosition("openMap")
	end

	minimap.pointTexture = minimap.pointTexture or self:createPointTexture()

	self:reload()
end

function minimap:uptNight(value2)
	local value = main_scene.ground.map

	if value2 and value then
		local count = 1

		if main_scene.ground.map and main_scene.ground.map.setDark.control then
			local typeOwner = value.setDark.mapLight[value.mapid] or value.setDark.mapLight[g_data.map.mapTitle] or {}

			count = value:getOpaWithTime(typeOwner.type)
		end

		local value3 = math.floor(count * 255 + 0.5)

		self.dark.node = display.newNode():size(self.bg:getContentSize()):add2(self):scale(self.cameraPow)
		self.dark.mask = display.newColorLayer(cc.c4b(0, 0, 0, value3))

		local node = display.newNode()

		res.get("bznight", 1):pos(self.bg:getw() / 2, self.bg:geth() / 2 - 2):scale(0.05):add2(node)

		local value4 = cc.ClippingNode:create():addTo(self.dark.node)

		value4:setInverted(true)
		value4:setStencil(node)
		self.dark.mask:add2(value4)
		value4:setAlphaThreshold(0)
	end
end

function minimap:onEnter()
	return
end

function minimap:onCleanup()
	if main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead:isInPos("openMap") then
		main_scene.ui.panels.heroHead:resetPanelPosition("hideMap")
	end
end

function minimap:uptZoneinfo()
	local function cleanup(self)
		if self == cAreaStateFight then
			return "[战斗]"
		elseif self == cAreaStateSafe or g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
			return "[安全]"
		elseif self == cAreaStateGuildWar then
			return "[攻城]"
		elseif self == cAreaStateDareWar then
			return "[挑战]"
		elseif self == cAreaStateReliveable then
			return "[复活]"
		else
			return "[激情]"
		end
	end

	local function cleanup2(self)
		if self == cAreaStateFight then
			return display.COLOR_RED
		elseif self == cAreaStateSafe or g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
			return display.COLOR_GREEN
		elseif self == cAreaStateGuildWar then
			return cc.c3b(250, 210, 100)
		elseif self == cAreaStateDareWar then
			return display.COLOR_RED
		elseif self == cAreaStateReliveable then
			return display.COLOR_GREEN
		end

		return def.colors.get(149)
	end

	local stateOnMap = cleanup(g_data.map.mapState)

	if g_data.player.stateOnMap ~= stateOnMap then
		if checkExist(stateOnMap, "[安全]") then
			common.addMsg("你处于安全区域!", def.colors.get(0), display.COLOR_GREEN)
		elseif checkExist(stateOnMap, "[激情]", "[攻城]") then
			common.addMsg("你处于激情区域，可能掉落装备!", def.colors.get(0), def.colors.get(149))
		elseif checkExist(stateOnMap, "[战斗]", "[挑战]") then
			common.addMsg("你处于战斗区域，可放心战斗!", display.COLOR_WHITE, display.COLOR_RED)
		end

		g_data.player.stateOnMap = stateOnMap
	end

	self:uptZoneSafe(stateOnMap, cleanup2(g_data.map.mapState))
end

function minimap:uptZoneSafe(value, value2)
	self.zoneSafe:setString(value)
	self.zoneSafe:setColor(value2)
end

function minimap:uptMapInfo(value)
	self.mapInfo:setString(value)
end

function minimap:reload()
	if self.bg then
		self.bg:removeSelf()

		self.bg = nil
	end

	if self.dark.node then
		self.dark.node:removeSelf()

		self.dark = {}
	end

	if self.pointNode then
		self.pointNode:removeSelf()

		self.pointNode = nil
	end

	if self.touchNode then
		self.touchNode:removeSelf()

		self.touchNode = nil
	end

	self.points = {}
	self.pointDns = {}
	self.percent = nil

	if not def.openWD then
		self:reloadMap()

		return
	end

	local minimapID = def.map.getMinimapID(main_scene.ground.map.mapid)

	if not minimapID then
		self:reloadMap(true)

		return
	end

	local function callback()
		return cache.getMinimap(minimapID) and cache.getMinimap(minimapID):getContentSize().width ~= 2
	end

	local tex2, tex22 = res.gettex2(minimapID .. ".png", "data/mmap")

	if tex22 and not callback() then
		main_scene.ground:joinMinimapMaker(main_scene.ground.map.mapid)
	else
		self:reloadMap()
	end
end

function minimap:reloadMap(value)
	if value then
		if g_data.map.mapTitle then
			if self.mapTitle then
				self.mapTitle:setString(g_data.map.mapTitle)
			end
		else
			common.addMsg("没有可用的地图", def.colors.clRed, 256, true)
		end
	else
		common.getMinimapTexture(main_scene.ground.map.mapid, function(tex)
			if tex and self then
				if self.load then
					self:load(tex)
				end
			elseif g_data.map.mapTitle then
				if self.mapTitle then
					self.mapTitle:setString(g_data.map.mapTitle)
				end
			else
				common.addMsg("没有可用的地图", def.colors.clRed, 256, true)
			end
		end, true)
	end

	if main_scene.ui.panels.bigmap and main_scene.ui.panels.bigmap.closeBigMapOrNo then
		main_scene.ui.panels.bigmap:closeBigMapOrNo()
	end
end

function minimap:load(tex)
	self.cameraPow = 1

	if main_scene.ground.map then
		self.cameraPow = math.max(main_scene.ground.map.w / tex:getContentSize().width * 2, 0.6)
	end

	self.bg = display.newSprite(tex):anchor(0, 0):add2(self):scale(self.cameraPow)
	self.pointNode = display.newNode():size(self.bg:getContentSize()):add2(self):scale(self.cameraPow)

	self:scroll(main_scene.ground.map, main_scene.ground.player)

	self.touchNode = display.newNode():size(self:getw(), self:geth()):add2(self):enableClick(function()
		sound.playSound("103")

		if def.role.darking then
			main_scene.ui:fadeLabel("黑夜模式下不支持查看地图！")

			return
		end

		if self.bg then
			if main_scene.ui.panels.bigmap then
				main_scene.ui:hidePanel("bigmap")
			else
				main_scene.ui:showPanel("bigmap")
			end
		end
	end)

	if main_scene.ground.map then
		local roles = {}

		if not solt0190 then
			os.exit()
		end

		table.merge(roles, main_scene.ground.map.heros)
		table.merge(roles, main_scene.ground.map.mons)
		table.merge(roles, main_scene.ground.map.npcs)

		for k, v in pairs(roles) do
			if def.hideMinimapHero then
				if g_data.player.roleid == v.roleid then
					self:pointUpt(main_scene.ground.map, v)
				end
			elseif v.__cname ~= "hero" or not def.stateIsHave(v.last.state, "stRealHidden") then
				self:pointUpt(main_scene.ground.map, v)
			end
		end

		if def.role.darking then
			self:uptNight(def.role.darking)
		else
			self:uptNight(main_scene.ground.map.setDark.control)
		end
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
	local x2 = math.max(0, player.x * self.percent.x * self.cameraPow - self:getw() / 2)
	local y2 = math.max(0, player.y * self.percent.y * self.cameraPow - self:geth() / 2)

	self.pointNode:pos(-x2, y2 + self:geth() - size.height * self.cameraPow)
end

function minimap:addPoint(role2)
	if not self.bg or role2.die then
		return
	end

	local color
	local race = role2:getRace()
	local value = 5 / self.cameraPow

	if checkExist(race, 50, 12) then
		color = 215

		if role2.roleid then
			-- block empty
		end
	elseif checkExist(race, 0, 150) then
		color = 215

		if role2.roleid then
			color = 251
		end

		if g_data.player.roleid == role2.roleid then
			color = 255
		end
	else
		color = 249
	end

	local point

	if role2.monTitle and role2.monTitle ~= "" then
		local parts = string.split(role2.monTitle, ",")
		local color2 = _stringToCorlor(parts[2])

		point = an.newLabel(parts[1], 10, 1, {
			color = color2
		}):addTo(self.pointNode, 3)
	else
		point = display.newSprite(minimap.pointTexture):add2(self.pointNode, 3):scale(value)

		point:setColor(def.colors.get(color, true))
	end

	self.points[role2.roleid] = point

	return point
end

function minimap:removePoint(roleid)
	if self.points[roleid] then
		self.points[roleid]:removeSelf()

		self.points[roleid] = nil
	end
end

function minimap:pointUpt(map, role2)
	if not self.bg then
		return
	end

	local point = main_scene.ground.player

	if not map or not point then
		return
	end

	local value = point.x .. ":" .. point.y

	if self.mmapPos then
		self.mmapPos:setString(value)
	end

	if def.role.darking and g_data.player.roleid ~= role2.roleid then
		return
	end

	if role2.die then
		self:removePoint(role2.roleid)
	else
		local point2 = self.points[role2.roleid] or self:addPoint(role2)

		self:computePercent(map)
		position(point2, role2.x * self.percent.x - point2:getw() / 2, (map.h - role2.y - 1) * self.percent.y - point2:geth() / 2)
	end

	if role2.__cname == "hero" and not role2.die and role2.state and def.stateIsHave(role2.state, "stRealHidden") and g_data.player.roleid ~= role2.roleid then
		if self.points[role2.roleid] then
			self.points[role2.roleid]:hide()
		end
	elseif self.points[role2.roleid] then
		self.points[role2.roleid]:show()
	end

	self:uptZoneinfo()
end

function minimap:uptPointAct(player)
	local node = self.points[player.roleid] or self:addPoint(player)
	local value

	for _, target in pairs(main_scene.ui.console.controller.lock.target) do
		if target then
			value = target

			break
		end
	end

	if player.roleid == value then
		self.pointAction = cc.RepeatForever:create(transition.sequence({
			cc.FadeOut:create(0.5),
			cc.FadeIn:create(0.5)
		}))

		if node then
			node:runAction(self.pointAction)
		end
	end
end

function minimap:stopPointAct(role2)
	local point = self.points[role2.roleid]

	if point then
		point:stopAllActions()

		self.pointAction = nil
	end
end

return minimap
