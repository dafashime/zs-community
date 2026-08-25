local scale = 0.8
local bigmapOther = class("bigmapOther", function ()
	return display.newNode()
end)

table.merge(bigmapOther, {
	texSize,
	point,
	mapScale,
	mapNode,
	findPathNode,
	findPathPoint,
	dest,
	destPoint,
	playerInThisMap
})

function bigmapOther:ctor(params)
	self._supportMove = true
	params = params or {}
	local tex = params.tex
	local mapData = params.mapData
	local user = params.user
	self.mapData = mapData
	local mapw = 615
	self.texSize = tex:getContentSize()
	self.mapScale = mapw / self.texSize.width
	local mapSize = cc.size(mapw, self.texSize.height * self.mapScale)
	local controlHeight = 112
	local bg = display.newNode():scale(scale):add2(self)
	local b1 = res.get2("pic/panels/bigmap/bg1.png")
	local b2 = res.get2("pic/panels/bigmap/bg2.png")
	local b3 = res.get2("pic/panels/bigmap/bg3.png")

	bg:size(b1:getw(), mapSize.height + controlHeight)
	b3:anchor(0, 0):add2(bg, -1)
	b2:anchor(0, 0):pos(0, b3:geth()):scaleY((bg:geth() - b1:geth() - b3:geth()) / b2:geth()):add2(bg, -1)
	b1:anchor(0, 1):pos(0, bg:geth()):add2(bg, -1)

	self.mapNode = display.newNode():pos(13, 14):size(mapSize):add2(bg, 1)
	local mapSpr = display.newSprite(tex):scale(self.mapScale):anchor(0, 0):add2(self.mapNode)

	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, mapSize):anchor(0, 0):add2(self.mapNode, 1)
	self:size(bg:getw() * scale, bg:geth() * scale):anchor(0.5, 0.5):center()
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):anchor(1, 1):pos(self:getw() - 4, self:geth() - 4):addto(self, 1)
	an.newLabelM(self:getw() - 30, 18, 1, {
		manual = true
	}):anchor(0, 0.5):pos(15, self:geth() - 58):add2(self):nextLine():addLabel(user, cc.c3b(0, 255, 0)):addLabel("当前位于"):addLabel(string.format("%s(%s,%s)", mapData.mapTitle, mapData.x, mapData.y), cc.c3b(0, 255, 0))

	if g_data.map.mapTitle == mapData.mapTitle and main_scene.ground.map.mapid == mapData.mapID then
		self.playerInThisMap = true
	end

	self:setDestPoint(mapData.x, mapData.y)

	if self.playerInThisMap then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			local x = mapData.x
			local y = mapData.y + 1

			if main_scene.ground.map:canWalk(x, y).block then
				main_scene.ui:tip("目标是阻挡, 无法传送！")

				return
			end

			if (not g_data.equip.items["7"] or g_data.equip.items["7"].getVar("name") ~= "传送戒指") and (not g_data.equip.items["8"] or g_data.equip.items["8"].getVar("name") ~= "传送戒指") then
				an.newMsgbox("需要佩戴传送戒指！", nil, {
					center = true
				})

				return
			end

			net.send_old({
				CM_SAY
			}, {
				"@传送 " .. x .. " " .. y
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/bigmap/cszt.png")
		}):anchor(1, 0.5):pos(self:getw() - 112, self:geth() - 58):add2(self)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			local x = mapData.x
			local y = mapData.y + 1

			if main_scene.ground.map:canWalk(x, y).block and main_scene.ground.map:canWalk(x, y - 1).block then
				main_scene.ui:tip("目标是阻挡, 无法到达！")

				return
			end

			main_scene.ui.console.controller.autoFindPath:searching(x, y)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/bigmap/xlzt.png")
		}):anchor(1, 0.5):pos(self:getw() - 12, self:geth() - 58):add2(self)
		self:pointUpt(main_scene.ground.map, main_scene.ground.player)

		if main_scene.ui.console.controller.autoFindPath.points then
			self:loadFindPathPoint(main_scene.ui.console.controller.autoFindPath.points)
		end
	end
end

function bigmapOther:mapPos(x, y)
	local w, h = nil

	if self.playerInThisMap then
		h = main_scene.ground.map.h
		w = main_scene.ground.map.w
	else
		local file = res.loadmap(self.mapData.mapID)
		h = file:geth()
		w = file:getw()
	end

	local percent = {
		x = self.texSize.width / w * self.mapScale,
		y = self.texSize.height / h * self.mapScale
	}

	return x * percent.x, (h - y - 1) * percent.y
end

function bigmapOther:setDestPoint(x, y)
	x, y = self:mapPos(x, y)
	local point = res.get2("pic/panels/bigmap/p-green.png"):anchor(0.5, 0):add2(self.mapNode, 1):pos(x, self.mapNode:geth()):moveTo(0.1, x, y)
end

function bigmapOther:removeAllFindPath()
	if not self.playerInThisMap then
		return
	end

	if self.findPathNode then
		self.findPathNode:removeSelf()

		self.findPathNode = nil
	end

	self.findPathPoint = nil
end

function bigmapOther:removePoint(key)
	if not self.playerInThisMap then
		return
	end

	if self.findPathPoint and self.findPathPoint[key] then
		self.findPathPoint[key]:removeSelf()

		self.findPathPoint[key] = nil
	end
end

function bigmapOther:loadFindPathPoint(points)
	if not self.playerInThisMap then
		return
	end

	self:removeAllFindPath()

	self.findPathNode = display.newNode():size(self.mapNode:getContentSize()):add2(self.mapNode)
	self.findPathPoint = {}

	for i, v in ipairs(points) do
		local point = display.newColorLayer(cc.c4b(0, 255, 255, 255)):size(4, 4):add2(self.findPathNode)
		local x, y = self:mapPos(v.x, v.y)

		point:pos(x - self.point:getw() / 2, y - self.point:geth() / 2)

		self.findPathPoint[v.key] = point
	end
end

function bigmapOther:pointUpt(map, player)
	if not self.playerInThisMap then
		return
	end

	if not self.point then
		self.point = display.newColorLayer(def.colors.get(251, true)):add2(self.mapNode, 1):size(6, 6)
	end

	local x, y = self:mapPos(player.x, player.y)

	self.point:pos(x - self.point:getw() / 2, y - self.point:geth() / 2)
end

return bigmapOther
