local current = ...
local mapDef = import(".def")
local maptile = import(".maptile")
local role = import("..role.role")
local hero = import("..role.hero")
local npc = import("..role.npc")
local mon = import("..role.mon")
local roleInfo = import("..role.info")
local stall = import("..role.stall")
local magic = import("..common.magic")
local settingLogic = import("..common.settingLogic")
local map = class("map", function ()
	return ycMap:create()
end)
local __position = cc.Node.setPosition

table.merge(map, {
	isStage = false
})

function map:ctor(mapid)
	self.mapid = mapid
	self.replaceMapid = g_data.map.mapReplace[mapid]
	self.hasRes = def.map.isHasRes(self.mapid) or def.map.isHasRes(self.replaceMapid)
	self.player = nil
	self.gray = false
	self.mons = {}
	self.npcs = {}
	self.heros = {}
	self.items = {}
	self.doors = {}
	self.stalls = {}
	self.safezoneEffs = {}
	self.events = {}
	self.readyTiles = {}
	self.roleXYs = {}
	self.msgs = newList()
	self.file = res.loadmap(self.replaceMapid or self.mapid)

	print("=====================================\nself.file", self.file)

	self.h = self.file:geth()
	self.w = self.file:getw()
	self.layers = {
		bg = display.newNode():addto(self),
		mid = display.newNode():addto(self),
		obj = display.newNode():addto(self),
		itemName = display.newNode():addto(self),
		itemEff = display.newNode():addto(self),
		infoHpBg = display.newNode():addto(self),
		infoHpSpr = display.newNode():addto(self),
		infoHpOut = display.newNode():addto(self)
	}
	self.tiles = {}

	self:size(self.file:getw() * mapDef.tile.w, self.file:geth() * mapDef.tile.h)
	self:runForever(transition.sequence({
		cc.DelayTime:create(20),
		cc.CallFunc:create(handler(self, self.clearTiles))
	}))

	if not self.hasRes and main_scene and main_scene.ui then
		main_scene.ui:tip("该地图的环境正在施工中.")
	end

	self.relationHandler = handler(self, self.onRelationUpdate)

	g_data.relation:addNotifyListener(self.relationHandler)

	function self.onCleanup()
		g_data.relation:removeNotifyListener(self.relationHandler)
	end

	self.blocks = {}

	self:updateMapScale()
end

function map:onRelationUpdate(_, rel, ole, new)
	if (rel == "attention" or rel == "attentionColor") and (ole or new) then
		local name = ole and ole:get("name") or new:get("name")
		local role = nil

		for k, v in pairs(self.heros) do
			print(v.info:getName(), name)

			if v.info:getName() == name then
				role = v

				break
			end
		end

		if role then
			if new then
				role.info:setNameColor(new:get("color"))
			elseif ole.realNameColor then
				role.info:setNameColor(ole.realNameColor)
			end
		end
	end
end

function map:updateMapScale(s)
	local scale = s or g_data.setting.display.mapScale
	self.screenw = math.ceil(display.width / mapDef.tile.w / scale)
	self.screenh = math.ceil(display.height / mapDef.tile.h / scale)
end

function map:setAllRoleInScreen(inScreen)
	for k, roles in pairs(self.roleXYs) do
		for k, v in pairs(roles) do
			if v.isInScreen ~= inScreen then
				v.isInScreen = inScreen

				v:uptIsIgnore()
			end
		end
	end
end

function map:updateRoleInScreen(x, y, endx, endy, inScreen)
	if endx < x then
		endx = x
		x = endx
	end

	if endy < y then
		endy = y
		y = endy
	end

	local uptIsIgnore = role.uptIsIgnore

	for mx = x, endx do
		mx = mx * 10000

		for my = y + mx, endy + mx do
			local roles = self.roleXYs[my]

			if roles then
				for k, v in pairs(roles) do
					if v.isInScreen ~= inScreen then
						v.isInScreen = inScreen

						uptIsIgnore(v)
					else
						break
					end
				end
			end
		end
	end
end

function map:load(x, y, ofsx, ofsy)
	local function loadArea(beginx, beginy, endx, endy)
		beginx = math.max(0, math.min(self.w, beginx))
		endx = math.max(0, math.min(self.w, endx))
		beginy = math.max(0, math.min(self.h, beginy))
		endy = math.max(0, math.min(self.h, endy))

		for i = beginx, endx do
			for j = beginy, endy do
				self:addTile(i, j)
			end
		end
	end

	local screenw = self.screenw
	local screenh = self.screenh
	local rangew = screenw + mapDef.loadOutsideArea * 2
	local newx = x
	local newy = y
	local beginx, endx, beginy, endy = nil

	if ofsx and ofsy then
		newy = y + ofsy
		newx = x + ofsx

		if ofsx ~= 0 then
			local rbeginx, rendx, ey = nil

			if ofsx > 0 then
				beginx = math.floor(x + rangew / 2)
				endx = beginx + ofsx
				rendx = math.floor(x - rangew / 2) - 1
				rbeginx = rendx - ofsx - 1
			else
				endx = math.floor(x - rangew / 2) - 1
				beginx = endx + ofsx - 1
				rbeginx = math.floor(x + rangew / 2)
				rendx = rbeginx - ofsx
			end

			beginy = math.floor(y - screenh / 2 - mapDef.loadOutsideArea) + ofsy
			ey = beginy + screenh
			endy = ey + mapDef.loadOutsideAreaBottom + mapDef.loadOutsideArea

			loadArea(beginx, beginy, endx, endy)

			if screenw <= 24 then
				self:updateRoleInScreen(rbeginx, beginy, rendx, ey, false)
				self:updateRoleInScreen(beginx, beginy, endx, ey, true)
			end
		end

		if ofsy ~= 0 then
			local rbeginy, rendy, by, ey = nil

			if ofsy > 0 then
				beginy = math.floor(y + screenh / 2 + mapDef.loadOutsideAreaBottom)
				by = beginy - mapDef.loadOutsideAreaBottom
				endy = beginy + ofsy
				ey = endy
				rendy = math.floor(y - screenh / 2)
				rbeginy = rendy - ofsy
			else
				endy = math.floor(y - screenh / 2 - mapDef.loadOutsideArea)
				ey = endy + mapDef.loadOutsideArea
				beginy = endy + ofsy
				by = beginy
				rbeginy = math.floor(y + screenh / 2)
				rendy = rbeginy - ofsy
			end

			beginx = math.floor(x - rangew / 2 + ofsx)
			endx = beginx + rangew

			loadArea(beginx, beginy, endx, endy)

			if screenh <= 24 then
				self:updateRoleInScreen(beginx, rbeginy + 2, endx, rendy + 1, false)
				self:updateRoleInScreen(beginx, by, endx, ey, true)
			end
		end
	else
		endx = math.floor(x + rangew / 2)
		beginx = math.floor(x - rangew / 2)
		endy = math.floor(y + screenh / 2 + mapDef.loadOutsideAreaBottom)
		beginy = math.floor(y - screenh / 2 - mapDef.loadOutsideArea)

		loadArea(beginx, beginy, endx, endy)

		if screenh > 24 and screenw > 24 then
			self:setAllRoleInScreen(true)
		else
			self:setAllRoleInScreen(false)
			self:updateRoleInScreen(beginx, math.floor(y - screenh / 2), endx, math.floor(y + screenh / 2), true)
		end
	end

	local safezonexDatas = g_data.map:isSeeSafeZoneEdge(self.mapid, newx, newy, screenw, screenh)

	if safezonexDatas then
		for i, v in ipairs(safezonexDatas) do
			self:addSafeZoneEff(v.x, v.y, v.rang)
		end
	end
end

function map:updateLookArea(x, y)
	self.lookArea = cc.rect(x - display.cx / g_data.setting.display.mapScale, y - display.cy / g_data.setting.display.mapScale, display.width / g_data.setting.display.mapScale, display.height / g_data.setting.display.mapScale + 500)
end

function map:scroll(isAnima, dura)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local x, y = self.player.node:getPosition()

	if isAnima then
		self:moveTo(dura or 0.2, -x + display.cx - tw / 2, -y + display.cy - th / 2)
	else
		self:pos(-x + display.cx - tw / 2, -y + display.cy - th / 2)
	end

	self:updateLookArea(x, y)
end

function map:setGrayState()
	self.gray = true
	local f = res.getFilter("gray")

	for k, v in pairs(self.tiles) do
		for k2, v2 in pairs(v) do
			if v2.sprites.bg then
				v2.sprites.bg:setFilter(f)
			end

			if v2.sprites.mid then
				v2.sprites.mid:setFilter(f)
			end

			if v2.sprites.midAni then
				v2.sprites.midAni:setFilter(f)
			end

			if v2.sprites.obj then
				v2.sprites.obj:setFilter(f)
			end

			if v2.sprites.ani then
				v2.sprites.ani:setFilter(f)
			end
		end
	end

	for k, v in pairs(self.heros) do
		v:openFilter("die")
	end

	for k, v in pairs(self.mons) do
		v:openFilter("die")
	end

	for k, v in pairs(self.npcs) do
		v:openFilter("die")
	end
end

function map:getMapPosWithScreenPos(x, y)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local diffx = x - display.cx
	local diffy = y - display.cy
	local node = self.player.node

	return node:getPositionX() + tw / 2 + diffx / main_scene.ground:getScale(), node:getPositionY() + th / 2 + diffy / main_scene.ground:getScale()
end

function map:getMapPos(gameX, gameY)
	return gameX * mapDef.tile.w, (self.h - gameY) * mapDef.tile.h
end

function map:getGamePos(x, y)
	return math.floor(x / mapDef.tile.w), math.floor(self.h - y / mapDef.tile.h + 1)
end

function map:addDoorTile(data, x, y)
	local idx = ycFunction:band(data.doorIndex, 127)
	local door = self.doors[idx]

	if not door then
		door = {}
		self.doors[idx] = door
	end

	for k, v in pairs(door) do
		if v.x == x and v.y == y then
			return
		end
	end

	door[#door + 1] = {
		x = x,
		y = y,
		data = data
	}
end

function map:setDoorState(isOpen, x, y)
	local data = self.file:gettile(x, y)

	if data then
		local idx = ycFunction:band(data.doorIndex, 127)
		local door = self.doors[idx]

		if door then
			for k, v in pairs(door) do
				local tile = self.tiles[v.x][v.y]

				if tile then
					v.data.doorOpen = isOpen

					tile:setDoorState(v.data)
				end
			end
		end
	end
end

function map:addSafeZoneEff(x, y, range)
	local key = self:xy2key(x, y)

	if self.safezoneEffs[key] then
		return
	end

	self.safezoneEffs[key] = true
	local points = {
		{
			flag = 0,
			x = x - range,
			y = y - range - 1
		},
		{
			flag = 2,
			x = x + range,
			y = y - range - 1
		},
		{
			flag = 4,
			x = x + range,
			y = y + range - 1
		},
		{
			flag = 6,
			x = x - range,
			y = y + range - 1
		}
	}

	for i = 1, range * 2 + 1 do
		points[#points + 1] = {
			flag = 1,
			x = x - range + i - 1,
			y = y - range - 1
		}
		points[#points + 1] = {
			flag = 3,
			x = x + range,
			y = y - range + i - 2
		}
		points[#points + 1] = {
			flag = 5,
			x = x - range + i - 1,
			y = y + range + 1
		}
		points[#points + 1] = {
			flag = 7,
			x = x - range - 2,
			y = y - range + i - 2
		}
	end

	for i, v in ipairs(points) do
		local x = v.x
		local y = v.y

		if self.mapid ~= "0" or x < 319 or x > 337 or y < 261 or y > 276 then
			local spr = m2spr.playAnimation("magic10", 2040 + v.flag * 10, 4, 0.2, true, nil, nil, nil, nil, 1):addto(self.layers.mid, 99999)

			__position(spr, x * mapDef.tile.w, (self.h - y) * mapDef.tile.h)
		end
	end
end

function map:canWalk(gamex, gamey, params)
	local ret = {}

	if params and params.useBlockInfo then
		if self.file:getblock(gamex, gamey) then
			ret.block = "block"
		end
	else
		local data = self.file:gettile(gamex, gamey)

		if data then
			if ycFunction:band(data.doorIndex, 128) > 0 and not data.doorOpen then
				ret.block = "door"
				ret.data = data
			elseif not data.canWalk then
				ret.block = "map"
			end
		end
	end

	if not ret.block then
		ret = self:isObjblock(gamex, gamey)
	end

	return ret
end

function map:canFly(gamex, gamey, params)
	local data = self.file:gettile(gamex, gamey)

	return data.canFly
end

function map:getObjeBlocks()
	local objects = {}

	local function checkRoles(roles)
		for k, v in pairs(roles) do
			if not v.isDummy and not v.die then
				objects[#objects + 1] = cc.p(v.x, v.y)
			end
		end
	end

	checkRoles(self.mons)
	checkRoles(self.npcs)
	checkRoles(self.heros)

	for k, v in pairs(self.stalls) do
		if not v.isDummy and not g_data.map:isInSafeZone(self.mapid, v.x, v.y) then
			for i = 0, 2 do
				for j = 0, 2 do
					objects[#objects] = cc.p(v.x + i, v.y + j)
				end
			end
		end
	end

	return objects
end

function map:isObjblock(gamex, gamey)
	local ret = {}

	if not ret.block then
		for k, v in pairs(self.mons) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "mon"

				break
			end
		end
	end

	if not ret.block then
		for k, v in pairs(self.npcs) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "npc"

				break
			end
		end
	end

	if not ret.block then
		for k, v in pairs(self.heros) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "hero"

				break
			end
		end
	end

	if not ret.block then
		for k, v in pairs(self.stalls) do
			if not v.die and v.x <= gamex and gamex <= v.x + 2 and v.y <= gamey and gamey <= v.y + 2 then
				ret.block = "map"

				break
			end
		end
	end

	return ret
end

function map:procAllRoles(f)
	for k, roles in ipairs({
		self.heros,
		self.npcs,
		self.mons
	}) do
		for k, v in pairs(roles) do
			f(v)
		end
	end
end

function map:findRole(roleid, params)
	local role = nil
	role = self.heros[roleid]

	if role then
		return role
	end

	role = self.npcs[roleid]

	if role then
		return role
	end

	role = self.mons[roleid]

	if role then
		return role
	end

	if params and params.feature then
		if type(params.feature) == "number" then
			params.feature = def.role.makeTFeature(params.feature)
		end

		return self:newRole(params), true
	end
end

function map:findRoelWithPos(x, y, type)
	if not type or type == "hero" then
		for k, v in pairs(self.heros) do
			if v.x == x and v.y == y then
				return v
			end
		end
	end

	if not type or type == "mon" then
		for k, v in pairs(self.mons) do
			if v.x == x and v.y == y then
				return v
			end
		end
	end

	if not type or type == "npc" then
		for k, v in pairs(self.npcs) do
			if v.x == x and v.y == y then
				return v
			end
		end
	end
end

function map:findHeroWithName(name)
	for k, v in pairs(self.heros) do
		if v.info:getName() == name then
			return v
		end
	end
end

function map:findNPCWithName(name)
	for k, v in pairs(self.npcs) do
		if v.info:getName() == name then
			return v
		end
	end
end

function map:findNearMon()
	local bestDis, bestMon = nil

	for k, v in pairs(self.mons) do
		local name = v.info:getName()

		if not v.die and not v:isPolice() then
			local x = math.abs(self.player.x - v.x)
			local y = math.abs(self.player.y - v.y)
			local dis = math.sqrt(x * x + y * y)

			if not bestDis or dis < bestDis then
				bestDis = dis
				bestMon = v
			end
		end
	end

	return bestMon
end

function map:newRole(params)
	assert(params.roleid, "map.newRole -> roleid must be not nil")

	params.map = self
	local race = params.feature:get("race")
	local ret = nil

	if race == 0 or race == 1 or race == 150 then
		ret = hero.new(params)

		ret.node:addTo(self.layers.obj)

		self.heros[params.roleid] = ret

		if params.isPlayer then
			self:setPlayer(ret)
		end
	elseif race == 50 then
		ret = npc.new(params)

		ret.node:addTo(self.layers.obj)

		self.npcs[params.roleid] = ret
	else
		ret = mon.new(params)

		ret.node:addTo(self.layers.obj)

		self.mons[params.roleid] = ret
	end

	if main_scene and main_scene.ui.panels.minimap then
		main_scene.ui.panels.minimap:addPoint(ret)
	end

	self:uptRoleXY(ret, false, params.x, params.y)

	return ret
end

function map:removeRole(roleid)
	local role = nil
	role = self.heros[roleid]

	if role then
		self:uptRoleXY(role, true)
		role.info:remove()
		role.node:removeSelf()
	end

	self.heros[roleid] = nil
	role = self.npcs[roleid]

	if role then
		self:uptRoleXY(role, true)
		role.info:remove()
		role.node:removeSelf()
	end

	self.npcs[roleid] = nil
	role = self.mons[roleid]

	if role then
		self:uptRoleXY(role, true)
		role.info:remove()
		role.node:removeSelf()
	end

	self.mons[roleid] = nil

	if main_scene and main_scene.ui.panels.minimap then
		main_scene.ui.panels.minimap:removePoint(roleid)
	end
end

function map:setPlayer(player)
	if self.player then
		self:removeTopRenderNode(self.player)
		self.player.node:removeSelf()
	end

	self.player = player

	self:addTopRenderNode(self.player.node)
end

function map:xy2key(x, y)
	return x * 10000 + y
end

function map:uptRoleXY(role, isRemove, x, y)
	local oldKey = role.xyKey
	local newKey = x and y and self:xy2key(x, y)

	if oldKey == newKey then
		return
	end

	if oldKey then
		local roles = self.roleXYs[oldKey]

		if roles then
			for i, v in ipairs(roles) do
				if v == role then
					table.remove(roles, i)

					break
				end
			end
		end
	end

	if isRemove then
		return
	end

	local roles = self.roleXYs[newKey]

	if not roles then
		roles = {}
		self.roleXYs[newKey] = roles
	end

	roles[#roles + 1] = role

	if self.player and not self.isStage then
		role.isInScreen = math.abs(x - self.player.x + 1) <= self.screenw / 2 + 1 and math.abs(y - self.player.y) < self.screenh / 2 + 2
	else
		role.isInScreen = true
	end

	for i, v in ipairs(roles) do
		v:uptIsIgnore()
	end

	role:uptIsIgnore()

	role.xyKey = newKey
end

function map:showItem(isshow, itemid, gamex, gamey, name, imgid, owner, state)
	if isshow ~= (self.items[itemid] ~= nil) then
		if isshow then
			local x, y = self:getMapPos(gamex, gamey)
			local item = {
				x = gamex,
				y = gamey,
				owner = owner,
				imgid = imgid,
				itemid = itemid,
				spr = m2spr.new("dnitems", imgid, {
					asyncPriority = 1
				}):addto(self.layers.obj, gamey):pos(x + mapDef.tile.w / 2, y + mapDef.tile.h / 2):runs({
					cc.DelayTime:create(math.random(3000) / 1000),
					cc.RepeatForever:create(transition.sequence({
						cc.CallFunc:create(function ()
							local spr = m2spr.playAnimation("prguse", 410, 9, 0.08, true, true, true, nil, nil, 1):addto(self.layers.itemEff)

							__position(spr, x, y + mapDef.tile.h)
						end),
						cc.DelayTime:create(0.54),
						cc.DelayTime:create(5)
					}))
				})
			}
			local isGood = false
			local showName = false

			if state and state > 0 then
				isGood = g_data.setting.getGoodAttItemSetting().isGood
				showName = g_data.setting.getGoodAttItemSetting().hintName
			end

			isGood = isGood or settingLogic.isGoodItem(name)
			showName = showName or settingLogic.showItemName(name)

			if showName or isGood then
				local nameColor = def.colors.skyBlue

				if isGood then
					nameColor = def.colors.clRed
				end

				if state and state > 0 then
					nameColor = def.colors.clpurple
				end

				item.state = state
				item.name = an.newLabel(name, 12, 1, {
					bufferChannel = 8,
					color = nameColor
				}):addto(self.layers.itemName)

				__position(item.name, x, y + 20)
			end

			self.items[itemid] = item
			item.itemName = name

			return
		end

		local item = self.items[itemid]

		item.spr:removeSelf()

		if item.name then
			item.name:removeSelf()
		end

		self.items[itemid] = nil
	end
end

function map:updateItems()
	local t = self.items
	self.items = {}

	for k, v in pairs(t) do
		v.spr:removeSelf()

		if v.name then
			v.name:removeSelf()
		end

		self:showItem(true, k, v.x, v.y, v.itemName, v.imgid, v.owner, v.state)
	end
end

function map:getItems(x, y)
	local ret = {}

	for k, v in pairs(self.items) do
		if v.x == x and v.y == y then
			ret[#ret + 1] = v
		end
	end

	return ret
end

function map:showMagic(roleid, effectType, effectID, x, y, target)
	local role = self:findRole(roleid)

	if not role then
		return
	end

	magic.showMagic(self, role, target, x, y, effectID)
end

function map:showEffectForName(name, params)
	magic.showWithName(self, name, params)
end

local __position = cc.Node.setPosition

function map:showEvent(serverID, x, y, type, eventMsg)
	self:hideEvent(serverID)

	if mapDef.ET_FIRE == type then
		local imgid = "magic"
		local begin = 1630
		local frame = 6
		x, y = self:getMapPos(x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):opacity(76.5):addto(self.layers.obj, y + mapDef.tile.h)
	elseif mapDef.ET_HOLYCURTAIN == type then
		local imgid = "magic"
		local begin = 1390
		local frame = 10
		x, y = self:getMapPos(x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):addto(self.layers.obj, y + mapDef.tile.h)
	elseif mapDef.ET_PILESTONES == type then
		local imgid = "effect"
		local begin = 64
		local frame = 5
		x, y = self:getMapPos(x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.12, false, false, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_DIGOUTZOMBI == type then
		local imgid = "mon6"
		local begin = 420
		local frame = 6
		x, y = self:getMapPos(x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.3, false, false, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_YanHuaTextEvent == type then
		x, y = self:getMapPos(x, y)
		x = x - 130
		self.events[serverID] = an.newLabel(eventMsg:get("desc"), 100, 0.5, {
			color = cc.c3b(255, 255, 0),
			sc = display.COLOR_WHITE
		}):addto(self.layers.obj, 99999)
	elseif mapDef.ET_CAKEFIRE == type then
		local imgid = "prguse3"
		local begin = mapDef.CAKEFIREBASE
		local frame = 30
		x, y = self:getMapPos(x, y)
		self.events[serverID] = m2spr.playAnimation(imgid, begin, frame, 0.08, true):addto(self.layers.obj, y + mapDef.tile.h)
	elseif mapDef.ET_INTENTLY <= type and type <= mapDef.ET_SUCHASFOGDREAM then
		local frameBegin = {
			20,
			20,
			16,
			16,
			16,
			16,
			16
		}
		local imgid = "magic3"
		local begin = 60 + (type - mapDef.ET_INTENTLY) * 20
		local frame = frameBegin[type - mapDef.ET_INTENTLY + 1]
		x, y = self:getMapPos(x, y)

		m2spr.playAnimation(imgid, begin, frame, 0.12, true, true, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_STALL_EVENT == type then
		x, y = self:getMapPos(x, y)
		self.events[serverID] = stall.new({
			x = x,
			y = y,
			serverID = serverID,
			map = self,
			data = eventMsg
		}):addto(self.layers.obj, 99999)
		self.stalls[serverID] = self.events[serverID]
	end

	if self.events[serverID] then
		self.events[serverID]:pos(x, y + mapDef.tile.h)
	end
end

function map:hideEvent(serverID)
	if self.events[serverID] then
		self.events[serverID]:removeSelf()

		self.events[serverID] = nil
	end
end

function map:removeStall(serverID)
	if self.stalls[serverID] then
		self.stalls[serverID] = nil
	end
end

function map:getHeroNameList()
	local ret = {}

	for k, v in pairs(self.heros) do
		if not v.isPlayer and v.info:getName() and not v.info:isHero() and not v.isDummy then
			ret[#ret + 1] = v.info:getName()
		end
	end

	return ret
end

function map:addTile(x, y)
	self.readyTiles[self:xy2key(x, y)] = {
		x,
		y
	}
end

function map:processTile(x, y)
	if not self.tiles[x] then
		self.tiles[x] = {}
	end

	if not self.tiles[x][y] then
		self.tiles[x][y] = maptile.new(self, x, y)

		return true
	end
end

function map:processTiles(dt)
	local cnt = 0

	for k, v in pairs(self.readyTiles) do
		self.readyTiles[k] = nil

		if self:processTile(v[1], v[2]) then
			cnt = cnt + 1

			if mapDef.loadNum < cnt then
				return
			end
		end
	end

	if self.gray then
		self:setGrayState()
	end
end

function map:clearTiles()
	local x = self.player.x
	local y = self.player.y
	local dis = math.floor(display.width / mapDef.tile.w) + mapDef.loadOutsideAreaBottom * 2

	for k, v in pairs(self.tiles) do
		for k2, v2 in pairs(v) do
			if dis < math.abs(x - k) or dis < math.abs(y - k2) then
				v2:remove()

				self.tiles[k][k2] = nil
			end
		end
	end

	for k, v in pairs(self.readyTiles) do
		if dis < math.abs(x - v[1]) or dis < math.abs(y - v[2]) then
			self.readyTiles[k] = nil
		end
	end
end

function map:addMsg(params)
	if params.remove then
		local tmpList = newList()

		while not self.msgs.isEmpty() do
			local msg = self.msgs.popFront()

			if msg.roleid ~= params.roleid then
				tmpList.pushBack(msg)
			end
		end

		self.msgs = tmpList

		self:removeRole(params.roleid)

		return
	end

	self.msgs.pushBack(params)
end

function map:processMsg(v)
	if v.roleid then
		local role, isNewCreate = self:findRole(v.roleid, v)

		if role then
			if v.ident then
				role:processMsg(v.ident, v.x, v.y, v.dir, v.feature, v.state, v.roleParams)
			end

			if v.job then
				role.job = v.job
			end

			if v.name then
				local race = role:getRace()

				if race ~= 98 then
					if race ~= 153 then
						role.info:setName(v.name)
					end
				end
			end

			while true do
				if role.__cname == "hero" then
					local pName = role.info:getName()
					local attData = g_data.relation:getAttention(pName)

					if attData then
						local colorIdx = attData:get("color")

						role.info:setNameColor(colorIdx)

						if v.nameColor then
							attData.realNameColor = v.nameColor
						end

						break
					end
				end

				if v.nameColor then
					role.info:setNameColor(v.nameColor)
				end

				break
			end

			if v.hp and v.maxhp then
				role.info:setHP(v.hp, v.maxhp, v.outhp)
			end

			if isNewCreate and v.roleid == g_data.hero.roleid then
				self.player.hero = role
			end
		end
	end

	if v.magic then
		self:showMagic(unpack(v.magic))
	end

	if v.effect then
		self:showEffectForName(v.effect[1], v.effect[2])
	end
end

function map:processMsgs(dt)
	local begin = socket.gettime()

	while not self.msgs.isEmpty() do
		self:processMsg(self.msgs.popFront())

		if socket.gettime() - begin > 0.01 then
			break
		end
	end
end

function map:update(dt)
	self:processTiles(dt)
	self:processMsgs(dt)

	local roleSize = def.role.size
	local infoUpdate = roleInfo.update
	local roleUpdate = role.update
	local uptIsIgnore = role.uptIsIgnore
	local getPosition = role.getPosition
	local rnum = 0

	for k, roles in ipairs({
		self.heros,
		self.npcs,
		self.mons
	}) do
		for k, v in pairs(roles) do
			if #v.acts > 0 or v.isPlayer then
				rnum = rnum + 1

				roleUpdate(v, dt)
			end

			if v.info.dirty then
				infoUpdate(v.info, dt)
			end
		end
	end

	self.current_frame_updatedRoles = rnum
end

function map:checkFlyTo(from, to)
	local i, adist, dist, dir = nil
	local x = from.x
	local y = from.y
	local tx = to.x
	local ty = to.y
	adist = math.abs(x - tx) + math.abs(y - ty)

	for i = 0, 8 do
		dir = self:getNextDirection(x, y, tx, ty)
		local ok = nil
		x, y, ok = self:getNextPosition(x, y, dir, 1)

		if not ok or not self:canFly(x, y) then
			return false
		end

		if x == tx and y == ty then
			return true
		else
			dist = math.abs(x - tx) + math.abs(y - ty)

			if adist < dist then
				return true
			end
		end
	end

	return true
end

function map:getNextDirection(x, y, tx, ty)
	local fx, fy = nil

	if x < tx then
		fx = 1
	elseif x == tx then
		fx = 0
	else
		fx = -1
	end

	if math.abs(y - ty) > 2 and x >= tx - 1 and x <= tx + 1 then
		fx = 0
	end

	if y < ty then
		fy = 1
	elseif y == ty then
		fy = 0
	else
		fy = -1
	end

	if math.abs(x - tx) > 2 and y > ty - 1 and y < ty + 1 then
		fy = 0
	end

	if fx == 0 and fy == -1 then
		return def.role.dir.up
	elseif fx == 1 and fy == -1 then
		return def.role.dir.rightUp
	elseif fx == 1 and fy == 0 then
		return def.role.dir.right
	elseif fx == 1 and fy == 1 then
		return def.role.dir.rightBottom
	elseif fx == 0 and fy == 1 then
		return def.role.dir.bottom
	elseif fx == -1 and fy == 1 then
		return def.role.dir.leftBottom
	elseif fx == -1 and fy == 0 then
		return def.role.dir.left
	elseif fx == -1 and fy == -1 then
		return def.role.dir.leftUp
	else
		return def.role.dir.up
	end
end

function map:getNextPosition(nx, ny, dir, step)
	local x = nx
	local y = ny

	if dir == def.role.dir.up then
		if y > step - 1 then
			y = y - step
		end
	elseif dir == def.role.dir.rightUp then
		if x > step - 1 and y < self.h - step then
			x = x + step
			y = y - step
		end
	elseif dir == def.role.dir.right then
		if x < self.w - step then
			x = x + step
		end
	elseif dir == def.role.dir.rightBottom then
		if x < self.w - step and y < self.h - step then
			x = x + step
			y = y + step
		end
	elseif dir == def.role.dir.bottom then
		if y < self.h - step then
			y = y + step
		end
	elseif dir == def.role.dir.leftBottom then
		if x < self.w - step and y > step - 1 then
			x = x - step
			y = y + step
		end
	elseif dir == def.role.dir.left then
		if x > step - 1 then
			x = x - step
		end
	elseif dir == def.role.dir.leftUp and x > step - 1 and y > step - 1 then
		x = x - step
		y = y - step
	end

	return x, y, x ~= nx or y ~= ny
end

return map
