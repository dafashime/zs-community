local map = import("...map.map")
local mapdef = import("...map.def")
local stage = class("simulationStage", function()
	local scene = display.newScene("SimulateStage")

	return scene
end)

table.merge(stage, {})

function stage:ctor(mapid, x, y, image, disableSkip)
	local ground = display.newNode():add2(self)

	self.ground = ground
	self.player = {
		node = display.newNode():size(1, 1),
		x = x,
		y = y
	}

	if mapid == "image" then
		mapid = "0"
		self.image = true
	end

	if mapid then
		local map = map.new(mapid):add2(ground)

		ground.map = map
		self.map = map

		self.player.node:addTo(map.layers.obj)
		map.layers.infoHpBg:setVisible(false)

		if image then
			if not string.find(image, ".") then
				image = image .. ".png"
			end

			self.image = res.get2_helper("pic/helperScript/" .. image):add2(ground)

			self.image:setLocalZOrder(-999)
			self.image:schedule(function()
				self.image:setPosition(self.player.node:convertToWorldSpace(cc.p(0, 0)))
			end, 0)
		end

		ground:scale(g_data.setting.display.mapScale)
		map:setPlayer(self.player)

		self.curx, self.cury = x, y

		self:moveTo(x, y, false)

		local pos = self.player.node:convertToWorldSpace(cc.p(0, 0))
		local offx = display.cx - pos.x
		local offy = display.cy - pos.y

		self.ground:setPosition(offx, offy)
		self:schedule(function()
			local dt = cc.Director:getInstance():getDeltaTime()

			self.map:update(dt)
		end, 0)

		self.map.screenw = 50
		self.map.screenh = 50
	end

	if not disableSkip then
		self:enableSkip()
	end
end

function stage:setEvtCallback(cb)
	self.evtCallback = cb
end

function stage:onEnterTransitionFinish()
	self.evtCallback("stage_onTransFinish")
end

function stage:enableSkip()
	local node = display.newNode():add2(self)

	node:setGlobalZOrder(99999999)

	self.skipLayer = node

	local eventDispatcher = node:getEventDispatcher()
	local listener = cc.EventListenerTouchOneByOne:create()

	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function(touch, event)
		if node.entered then
			return
		end

		node.entered = true

		an.newMsgbox("确定要跳过剧情吗?", function(idx)
			node.entered = false

			if idx == 1 then
				self.runner.skip()
			end
		end, {
			center = true,
			hasCancel = true
		})

		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function stage:disableSkip()
	self.skipLayer:removeSelf()
end

function stage:updateLookArea()
	local mx, my = self.map:getPosition()

	mx = -mx + display.cx
	my = -my + display.cy
	mx = mx + mapdef.tile.w / 2
	my = my + mapdef.tile.h / 2

	self.map:updateLookArea(mx, my)
end

function stage:moveTo(x, y, isAnim, dur)
	local dis = cc.pGetDistance(cc.p(self.curx, self.cury), cc.p(x, y))

	dur = dur or dis * 2

	local mx, my = self.map:getMapPos(x, y)

	mx = mx + mapdef.tile.w / 2
	my = my + mapdef.tile.h / 2

	if not self.image then
		if isAnim then
			local step = 0
			local disX = x - self.curx
			local disY = y - self.cury
			local dis = math.sqrt(disX * disX + disY * disY)

			local function cb()
				local per = step / dis

				if per >= 1 then
					self.player.x = x
					self.player.y = y

					self.map:load(x, y)
					self:stopAction(hAct)

					return
				end

				local nx = math.floor(per * disX + 0.5) + self.curx
				local ny = math.floor(per * disY + 0.5) + self.cury

				self.player.x = nx
				self.player.y = ny

				self.map:load(nx, ny)

				step = step + 1
			end

			local hAct

			hAct = self:schedule(cb, dur / (dis / 2))
			self.curx, self.cury = x, y

			cb()
		else
			self.player.x = x
			self.player.y = y

			self.map:load(x, y)
		end
	end

	self.map.isStage = true

	self.player.node:setPosition(mx, my)
	self.map:scroll(isAnim, dur)

	self.curx, self.cury = x, y
end

function stage:setMapScale(s)
	self.ground:setScale(s)
	self.map:updateMapScale(s)
	self:moveTo(self.player.x, self.player.y, true)
end

function stage:getMap()
	return self.map
end

return stage
