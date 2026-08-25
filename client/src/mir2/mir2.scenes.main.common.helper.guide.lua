local current = ...
local guide = class("guide")
guide.SWALLOW_PRIORITY = -10000000
guide.TIP_ZORDER = 1000000
guide.current = current

function guide:ctor()
	-- local debug: disable newbee guide layer
	self.guideDisabled = true
	self.dragGuideImage_ = {}
	self.twinkleNodeStops_ = {}
	self.widgetCheckers_ = {}
	self.hightLights_ = {}
	self.preTouchPosition = {}
	self.tipTexts_ = {}
	self.currentFocus = nil
	self.evtCallback_ = nil
	local handler = nil

	local function createGuideLayer()
		if main_scene then
			self.guideLayer = display.newNode()

			if not tolua.isnull(self.guideLayer) then
				self.guideLayer:removeFromParent()
			end

			self.guideLayer:add2(main_scene)
			self.guideLayer:setNodeEventEnabled(true)

			function self.guideLayer:onCleanup()
				handler = scheduler.scheduleUpdateGlobal(createGuideLayer, 0)
			end

			scheduler.unscheduleGlobal(handler)
		end
	end

	-- handler = scheduler.scheduleUpdateGlobal(createGuideLayer)
end

function guide:getEventNodesByPos(pos)
	local nodes = {}

	traversalNodeTree(main_scene, function (n)
		if cc.Node.hitTest(n, pos, false) and n:getName() ~= "" and n:getName() ~= "nameLabel_byGuide" then
			table.insert(nodes, n)
		end

		return true
	end)

	return nodes
end

function guide:setEvtCallback(func)
	self.evtCallback_ = func
end

if DEBUG > 0 then
	function guide:debug()
		self.debug = true
		self._mouseEventListener = cc.EventListenerMouse:create()

		self._mouseEventListener:registerScriptHandler(handler(self, self.onMouseMove), cc.Handler.EVENT_MOUSE_MOVE)
		self._mouseEventListener:registerScriptHandler(handler(self, self.onMouseDown), cc.Handler.EVENT_MOUSE_DOWN)

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

		eventDispatcher:addEventListenerWithFixedPriority(self._mouseEventListener, 1000)
	end

	function guide:disDebug()
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

		eventDispatcher:removeEventListener(self._mouseEventListener)
	end

	local oleListenerAdder = cc.Node.addNodeEventListener

	function cc.Node:addNodeEventListener(evt, hdl, tag, priority)
		local stack = debug.traceback()
		local node = self

		if evt == cc.NODE_TOUCH_EVENT then
			scheduler.performWithDelayGlobal(function ()
				if not tolua.isnull(node) and main_scene and main_scene.ui and node:getName() == "" then
					for k, v in pairs(main_scene.ui.panels) do
						if isChildOf(node, v) then
							local pos = node:convertToWorldSpace(cc.p(0, 0))
							pos = v:convertToNodeSpace(pos)

							node:setName(k .. string.format("(%s,%s)", math.floor(pos.x), math.floor(pos.y)))

							break
						end
					end
				end
			end, 0)
		end

		return oleListenerAdder(self, evt, hdl, tag, priority)
	end

	function guide:onMouseMove(event)
		if self.__handler then
			scheduler.unscheduleGlobal(self.__handler)
		end

		local mousePos = cc.p(event:getCursorX(), event:getCursorY())
		self.__handler = scheduler.performWithDelayGlobal(function ()
			local nodes = self:getEventNodesByPos(mousePos)

			for k, v in pairs(self.preNodes or {}) do
				if not tolua.isnull(v) then
					local nlb = v:getChildByName("nameLabel_byGuide")

					if nlb then
						nlb:removeFromParent()
					end
				end
			end

			self.preNodes = nodes

			for k, v in pairs(nodes) do
				if not tolua.isnull(v) then
					local lb = an.newLabel(v:getName(), 22, 1):add2(v):pos(v:centerPos()):anchor(0.5, 0.5)

					lb:setName("nameLabel_byGuide")
					lb:setGlobalZOrder(9999)
				end
			end
		end, 0.1)
	end

	function guide:onMouseDown(event)
		local common = import("..common", current)

		if event:getMouseButton() == 1 then
			local mousePos = cc.p(event:getCursorX(), event:getCursorY())

			if not tolua.isnull(self.pre) and not tolua.isnull(self.preMenu) then
				local pos = self.pre:convertToNodeSpace(cc.p(mousePos.x - self.pre:getw() / 2, mousePos.y - self.pre:geth() / 2))

				print(string.format("curPos :x:%d,y:%d", pos.x, pos.y))

				return
			end

			print(not tolua.isnull(self.pre) and not tolua.isnull(self.preMenu))

			local nodes = self:getEventNodesByPos(mousePos)
			local cells = {}

			for k, v in pairs(nodes) do
				local cell = {
					w = 250,
					h = 25
				}

				function cell.cellCls()
					local lb = v:getName()

					if not lb or lb == "" then
						lb = v.listener_id__
					end

					cell.stack = cell.node.stack__
					cell.lb = lb

					print(lb)

					return an.newLabel(lb, 22, 1):anchor(0.5, 0.5)
				end

				cell.node = v

				table.insert(cells, cell)
			end

			if #cells <= 0 then
				return
			end

			local menu = common.createOperationMenu(cells, 5, function (pnl, cell)
				if not tolua.isnull(cell.node) then
					self.pre = cell.node
				end

				local data = self:createTouchData("began", mousePos.x, mousePos.y)

				cell.node:EventDispatcher(cc.NODE_TOUCH_EVENT, data)

				local data = self:createTouchData("ended", mousePos.x, mousePos.y)

				cell.node:EventDispatcher(cc.NODE_TOUCH_EVENT, data)

				return true
			end):add2(self.guideLayer):center():anchor(0.5, 0.5)

			traversalNodeTree(menu, function (n)
				n:setGlobalZOrder(999999999999.0)

				return true
			end)

			if not tolua.isnull(self.preMenu) then
				self.preMenu:removeSelf()
			end

			self.preMenu = menu
		end
	end
end

function guide:getNodeByName(name)
	local c = nil

	traversalNodeTree(main_scene, function (child)
		if child:getName() == name then
			c = child

			return false
		end

		return true
	end)

	return c
end

function guide:getNodeByNames(names, checkScroll)
	local nodes = {}

	traversalNodeTree(main_scene, function (child)
		local name = child:getName()

		for k, v in pairs(names) do
			if v == name then
				nodes[v] = child
			end
		end

		return true
	end)

	if checkScroll then
		for k, v in pairs(nodes) do
			if v.__cname == "an.scroll" then
				nodes[k] = v.scrollView.touchNode_
			end
		end
	end

	return nodes
end

function guide:createTouchData(evt, x, y)
	local data = {}

	if evt == "began" then
		data.x = x
		data.y = y
		data.prevX = x
		data.prevY = y
	else
		data.x = x
		data.y = y
		data.prevX = self.preTouchPosition[1]
		data.prevY = self.preTouchPosition[2]
	end

	self.preTouchPosition = {
		x,
		y
	}
	data.name = evt
	data.phase = "capturing"

	return data
end

function guide:touchSwallower(touchCb, priority)
	local listener = cc.EventListenerTouchOneByOne:create()

	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function (touch, event)
		local pos = touch:getLocation()

		if touchCb("began", event, pos) then
			print("swallow touch by helper-guide")

			return true
		end
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function (touch, event)
		local pos = touch:getLocation()

		touchCb("moved", event, pos)
	end, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(function (touch, event)
		local pos = touch:getLocation()

		touchCb("ended", event, pos)
	end, cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

	eventDispatcher:addEventListenerWithFixedPriority(listener, priority or guide.SWALLOW_PRIORITY)

	return listener
end

function guide:talkWithNPC(name)
	local npc = main_scene.ground.map:findNPCWithName(name)

	if npc then
		print("talk with ", npc.roleid)
		scheduler.performWithDelayGlobal(function ()
			net.send({
				CM_CLICKNPC,
				recog = npc.roleid
			})
		end, 0)

		return true
	end
end

function guide:showTipText(name, tipParams, offset)
	local tip = an.newLabel(unpack(tipParams))
	local lbsz = tip:getContentSize()
	lbsz.width = lbsz.width + 30
	lbsz.height = lbsz.height + 30
	local node = display.newScale9Sprite(res.getframe2("pic/helperScript/guide/frame.png"), 0, 0, lbsz)
	local arrow = res.get2("pic/helperScript/guide/frame_arrows.png"):add2(node, 10):anchor(0, 0.5)

	tip:add2(node):pos(15, 15)
	node:setVisible(false)
	node:schedule(function ()
		node:setVisible(true)

		local pos = self:calcWorldPos(name, offset)

		if not pos then
			return
		end

		local lbsz = tip:getContentSize()
		lbsz.width = lbsz.width + 30
		lbsz.height = lbsz.height + 30

		node:setContentSize(lbsz)

		if tipParams.align then
			if tipParams.align == "left" then
				node:anchor(0, 0.5)
				arrow:pos(6, lbsz.height / 2)
				arrow:setRotation(180)

				pos.x = pos.x + 60
			elseif tipParams.align == "top" then
				node:anchor(0.5, 1)
				arrow:pos(lbsz.width / 2, lbsz.height - 6)
				arrow:setRotation(-90)

				pos.y = pos.y - 60
			elseif tipParams.align == "right" then
				node:anchor(1, 0.5)
				arrow:pos(lbsz.width - 6, lbsz.height / 2)
				arrow:setRotation(0)

				pos.x = pos.x - 60
			elseif tipParams.align == "bottom" then
				node:anchor(0.5, 0)
				arrow:pos(lbsz.width / 2, 6)
				arrow:setRotation(90)

				pos.y = pos.y + 60
			end
		end

		node:pos(pos.x, pos.y)
	end, 0)
	node:add2(self.guideLayer)
	setGlobalZOrderCascade(node, guide.TIP_ZORDER + 1)
	node:setLocalZOrder(guide.TIP_ZORDER)
	table.insert(self.tipTexts_, node)

	return node
end

function guide:removeTipText(tip)
	for k, v in pairs(self.tipTexts_) do
		if v == tip then
			table.remove(self.tipTexts_, k)

			break
		end
	end

	if not tolua.isnull(tip) then
		tip:removeFromParent()
	end
end

function guide:hightLightNode(names)
	local nodes = nil

	if type(names) == "string" then
		names = {
			names
		}
	end

	nodes = self:getNodeByNames(names, true)
	local zorders = {}
	local sp = nil

	if not tolua.isnull(self.grayPanel) then
		self.grayPanel:removeSelf()
	end

	local base = display.newNode():add2(self.guideLayer)
	sp = cc.NVGDrawNode:create():add2(base)

	sp:drawSolidRect(cc.p(0, 0), cc.p(display.cx * 2, display.cy * 2), cc.c4b(0, 0, 0, 0.5))

	self.grayPanel = base

	for k, v in ipairs(names) do
		local node = nodes[v]

		if tolua.isnull(node) then
			if string.find(v, "panel_") == 1 then
				node = main_scene.ui.panels[string.sub(v, string.find(v, "_") + 1)]
			end

			nodes[v] = node
		end

		if node then
			local function zsetter(n)
				if not zorders[n] then
					zorders[n] = n:getGlobalZOrder()

					n:setGlobalZOrder(guide.TIP_ZORDER - 3)
				end

				return true
			end

			traversalNodeTree(node, zsetter)
		end
	end

	local function resume()
		for k, v in pairs(zorders) do
			if not tolua.isnull(k) then
				k:setGlobalZOrder(v)
			end
		end

		if #self.hightLights_ <= 0 and not tolua.isnull(self.grayPanel) then
			self.grayPanel:removeSelf()

			self.grayPanel = nil
		end
	end

	table.insert(self.hightLights_, resume)

	return resume
end

function guide:disableHightLight(resumer)
	for k, v in pairs(self.hightLights_) do
		if v == resumer then
			table.remove(self.hightLights_, k)

			break
		end
	end

	resumer()
end

function guide:setScrollOffsetX(name, x)
	local scroll = self:getNodeByName(name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll:getScrollOffset()

		scroll:setScrollOffset(x, oy)
	end
end

function guide:setScrollOffsetY(name, y)
	local scroll = self:getNodeByName(name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll:getScrollOffset()

		scroll:setScrollOffset(ox, y)
	end
end

function guide:getScrollOffsetX(name)
	local scroll = self:getNodeByName(name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll:getScrollOffset()

		return ox
	end
end

function guide:getScrollOffsetY(name)
	local scroll = self:getNodeByName(name)

	if scroll and scroll.__cname == "an.scroll" then
		local ox, oy = scroll:getScrollOffset()

		return oy
	end
end

function guide:stopBounce(name)
	local scroll = self:getNodeByName(name)

	if scroll and scroll.__cname == "an.scroll" then
		local tn = scroll.scrollView.touchNode_
		local pos = tn:convertToWorldSpace(cc.p(tn:getw() / 2, tn:geth() / 2))
		local data = self:createTouchData("began", pos.x, pos.y)

		tn:EventDispatcher(cc.NODE_TOUCH_EVENT, data)

		local data = self:createTouchData("ended", pos.x, pos.y)

		tn:EventDispatcher(cc.NODE_TOUCH_EVENT, data)
	end
end

function guide:focusNodeByName(names, evtCb, lockAll, swallowAnyway)
	if self.currentFocus then
		self:stopCurrentFocus()
	end

	local nodes = nil

	if type(names) == "string" then
		names = {
			names
		}
	end

	nodes = self:getNodeByNames(names, true)
	local evtCallback = self.evtCallback_

	for k, v in pairs(nodes) do
		local n = display.newNode()

		v:addChild(n)
		n:setNodeEventEnabled(true)

		function n:onCleanup()
			evtCallback("clean," .. k)
		end
	end

	local listener = nil
	listener = self:touchSwallower(function (evtName, event, pos)
		local hited = nil

		if evtName == "moved" then
			return
		end

		if evtName == "began" then
			for k, name in ipairs(names) do
				local node = nodes[name]

				if node and node:hitTest(pos, true) then
					hited = node

					break
				end
			end

			self.curNode = hited
		else
			hited = self.curNode
		end

		if hited then
			if evtName == "ended" and not hited:hitTest(pos, true) then
				evtName = "canceled"
			end

			if evtCb(evtName, pos, hited:getName()) then
				local data = self:createTouchData(evtName, pos.x, pos.y)

				print("swallowAnyway", not not swallowAnyway)
				listener:setSwallowTouches(not not swallowAnyway)

				return true
			end
		end

		listener:setSwallowTouches(true)

		if evtName == "ended" or evtName == "canceled" then
			self.curNode = nil
		end

		if lockAll then
			return true
		end
	end)
	self.currentFocus = {
		listener_ = listener,
		focus = node,
		guider_ = self,
		stop = function (self)
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

			eventDispatcher:removeEventListener(listener)

			self.guider_.currentFocus = nil

			if grayOther then
				traversalNodeTree(node, function (n)
					n:setGlobalZOrder(zorders[n] or 0)

					return true
				end)
				sp:removeFromParent()
			end
		end
	}

	return self.currentFocus
end

function guide:stopCurrentFocus()
	if self.currentFocus then
		self.currentFocus:stop()
	end
end

function guide:calcWorldPos(name, offset)
	assert(name, "get world position faild. not name spacify")

	local function nodePos(node, name, off)
		local n = node or self:getNodeByNames({
			name
		})[name]
		local pos = nil

		if n then
			pos = n:convertToWorldSpace(cc.p(n:getw() / 2, n:geth() / 2))

			if off then
				pos = cc.pAdd(pos, off)
			end
		else
			print("calcWolrdPos, target not exist", name, pos)
		end

		return pos
	end

	local pos = name

	if type(name) == "string" then
		pos = nodePos(nil, name, offset)
	elseif not tolua.isnull(name) then
		pos = nodePos(name, nil, offset)
	end

	return pos
end

function guide:useOnceAct(idx)
	scheduler.performWithDelayGlobal(function ()
		net.send({
			CM_EXEC_FRESHMAN_TASK_CMD,
			recog = idx
		})
	end, 0)
end

function guide:dragGuide(start, goal, params)
	params = params or {
		finger = {}
	}
	params.finger = params.finger or {}
	local img = res.get2(params.image or "pic/helperScript/guide/finger.png"):add2(self.guideLayer):anchor(1, 1)

	img:setRotation(params.finger.r or 0)
	img:setScaleY(params.finger.flipX and 1 or -1)
	img:setScaleX(params.finger.flipY and 1 or -1)

	local startPos = self:calcWorldPos(start, params.startOffset or cc.p(0, 0))
	local goalPos = self:calcWorldPos(goal, params.goalOffset or cc.p(0, 0))
	local dis = cc.pGetDistance(startPos, goalPos)
	local arrow = display.newScale9Sprite(res.getframe2("pic/helperScript/guide/arrows_translucence02.png"), (startPos.x + goalPos.x) / 2, (startPos.y + goalPos.y) / 2, cc.size(28, dis))

	arrow:add2(self.guideLayer):rotation(90 - math.deg(cc.pGetAngle(startPos, goalPos))):anchor(0.5, 0.5)

	local function runActs()
		img:setGlobalZOrder(guide.TIP_ZORDER)
		img:setPosition(startPos)
		img:runs({
			cca.place(startPos.x, startPos.y),
			cca.delay(params.interval or 0),
			cca.fadeIn(0.2),
			cca.moveTo(params.duration or 1.3, goalPos.x, goalPos.y),
			cca.fadeOut(1),
			cca.callFunc(runActs)
		})
	end

	runActs()
	table.insert(self.dragGuideImage_, img)
	img:setNodeEventEnabled(true)

	function img.onCleanup()
		arrow:removeSelf()
	end

	return img
end

function guide:stopDragGuide(img)
	for k, v in pairs(self.dragGuideImage_) do
		if v == img then
			table.remove(self.dragGuideImage_, k)

			break
		end
	end

	if not tolua.isnull(img) then
		img:removeFromParent()
	end
end

function guide:isNodeExist(name)
	if string.find(name, "panel_") == 1 then
		local panel = main_scene.ui.panels[string.sub(name, string.find(name, "_") + 1)]

		if panel then
			return true
		end
	end

	return not not self:getNodeByName(name)
end

function guide:isNodeVisible(node)
	local p = node

	while p do
		p = p:getParent()

		if tolua.type(p) == "cc.ClippingRectangleNode" then
			p = p:getParent()

			break
		end
	end

	if not p then
		return true
	end

	return cc.rectIntersectsRect(node:getCascadeBoundingBox(), p:getBoundingBox())
end

function guide:checkUntilNodeExist(name, cb, timeout)
	local timeoutHandler, updateHandler = nil
	updateHandler = scheduler.scheduleUpdateGlobal(function ()
		if self:isNodeExist(name) then
			if timeoutHandler then
				scheduler.unscheduleGlobal(timeoutHandler)
			end

			cb("ok")
			scheduler.unscheduleGlobal(updateHandler)
		end
	end)

	local function stopCheck()
		scheduler.unscheduleGlobal(updateHandler)
		cb("timeout")
	end

	if timeout then
		scheduler.performWithDelayGlobal(stopCheck, timeout)
	end

	table.insert(self.widgetCheckers_, stopCheck)

	return stopCheck
end

function guide:scrollNodeToCenter(name, scrollName, offset)
	offset = offset or cc.p(0, 0)
	local scroll = self:getNodeByName(scrollName)

	if iskindof(scroll, "an.scroll") then
		scroll = scroll.scrollView
	end

	if not iskindof(scroll, "UIScrollView") then
		error(scrollName .. " is not a scroll node")
	end

	local node = self:getNodeByName(name)

	if not node then
		error(name .. " is not exist!")
	end

	local wp = node:convertToWorldSpace(cc.p(0, 0))
	local n = scroll:getScrollNode()
	local np = n:convertToNodeSpace(wp)
	np.x = scroll:getViewRect().width / 2 + np.x + offset.x
	np.y = np.y - scroll:getViewRect().height / 2 + offset.y
	local dir = scroll:getDirection()

	if dir == cc.ui.UIScrollView.DIRECTION_VERTICAL then
		n:run(cca.moveTo(0.5, 0, np.y))
	elseif dir == cc.ui.UIScrollView.DIRECTION_VERTICAL then
		scroll:scrollTo(np.x, 0)
	else
		scroll:scrollTo(np)
	end
end

function guide:twinkleNodeWidthName(name, params)
	speed = speed or 1

	if not name then
		error("未指定控件名")

		return
	end

	local node = self:getNodeByNames({
		name
	})
	node = node[name]

	if not node then
		error("指定的控件不存在" .. name)

		return
	end

	local drawNodes = {}
	local vst = nil
	local borderColor = params.boderColor or {
		g = 0.27058823529411763,
		a = 0,
		r = 0.9333333333333333,
		b = 0
	}
	local innner = cc.c4f(borderColor.r * 4, borderColor.g * 4, borderColor.b * 4, borderColor.a)

	for k = 1, 5 do
		local dn = cc.NVGDrawNode:create():add2(self.guideLayer)
		dn.dn2 = cc.NVGDrawNode:create():add2(self.guideLayer)

		dn:setLineWidth(5)
		dn.dn2:setLineWidth(3)
		table.insert(drawNodes, dn)

		dn.per = 100 - (k - 1) * 20

		dn:setLocalZOrder(guide.TIP_ZORDER - 1)
		dn.dn2:setLocalZOrder(guide.TIP_ZORDER - 1)
	end

	local function stopTwinkle()
		if not tolua.isnull(drawNodes[1]) then
			for k, v in pairs(drawNodes) do
				v.dn2:removeFromParent()
				v:removeFromParent()
			end
		end
	end

	local function update()
		if tolua.isnull(node) then
			stopTwinkle()

			return
		end

		local pos = self:calcWorldPos(node, params.offset)

		for k, drawNode in pairs(drawNodes) do
			if tolua.isnull(drawNode) then
				return
			end

			local per = drawNode.per - 1.6

			if per < 0 then
				per = 100
			end

			drawNode.per = per

			if per < 10 then
				borderColor.a = 0.7 * per / 10
			else
				borderColor.a = (1 - per / 100) * 0.7
			end

			if per < 10 then
				per = 10
			end

			if params.circle then
				drawNode:clear()
				drawNode:drawCircle(pos, params.radio + per - 10, borderColor)

				innner.a = borderColor.a

				drawNode.dn2:clear()
				drawNode.dn2:drawCircle(pos, params.radio + per - 10, innner)
			else
				per = per - 10
				local w = params.w * (1 + per / 25)
				local h = params.h * (1 + per / 25)
				local cx = pos.x + (display.cx - pos.x) * (w - params.w) / (display.size.width - params.w)
				local cy = pos.y + (display.cy - pos.y) * (h - params.h) / (display.size.height - params.h)

				drawNode:clear()
				drawNode:drawRect(cc.p(cx - w / 2, cy - h / 2), cc.p(cx + w / 2, cy - h / 2), cc.p(cx + w / 2, cy + h / 2), cc.p(cx - w / 2, cy + h / 2), borderColor)

				innner.a = borderColor.a

				drawNode.dn2:clear()
				drawNode.dn2:drawRect(cc.p(cx - w / 2, cy - h / 2), cc.p(cx + w / 2, cy - h / 2), cc.p(cx + w / 2, cy + h / 2), cc.p(cx - w / 2, cy + h / 2), innner)
			end
		end
	end

	drawNodes[1]:schedule(update, 0)
	table.insert(self.twinkleNodeStops_, stopTwinkle)

	return stopTwinkle
end

function guide:stopTwinkleNode(stoper)
	for k, v in pairs(self.twinkleNodeStops_) do
		if v == stoper then
			table.remove(self.twinkleNodeStops_, k)

			break
		end
	end

	stoper()
end

function guide:getNodePositionRelative(name, relative)
	local node = self:getNodeByName(name)
	local relative = self:getNodeByName(relative)
	local pos = node:convertToWorldSpace(cc.p(0, 0))

	return relative:convertToNodeSpace(pos)
end

function guide:focusToNode(names, lockOther, stopEvt, params)
	local handler = nil
	local swallowAnyway = false

	if params then
		if type(params) == "table" then
			timeout = params.timeout
			swallowAnyway = params.swallowAnyway
		else
			timeout = params
		end

		if timeout then
			handler = scheduler.performWithDelayGlobal(function ()
				self.evtCallback_("timeout")
			end, timeout)
		end
	end

	return self:focusNodeByName(names, function (evt, pos, widName)
		self.evtCallback_(string.format("%s,%s", evt, widName))

		if evt == stopEvt then
			self:stopCurrentFocus()
		end

		if handler then
			scheduler.unscheduleGlobal(handler)
		end

		return true
	end, lockOther, swallowAnyway)
end

function guide:tip(text)
	main_scene.ui:tip(text)
end

function guide:showGuideBoard(text, hightLight, btns)
	local n = display.newNode():add2(self.guideLayer)

	n:setContentSize(display.size.width, display.size.height)
	n:setLocalZOrder(999)

	if hightLight then
		local layer = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(display.size.width * 2, display.size.width * 2):pos(-display.size.width / 2, -display.size.width / 2):add2(n)

		layer:setLocalZOrder(-1)
	end

	local spr = res.get2("pic/helperScript/guide/guideBoard.png"):add2(n):anchor(0.5, 0.5):pos(display.cx - 70, display.cy)

	spr:setLocalZOrder(1)

	local label = an.newLabelM(310, 20, 1):add2(spr):pos(330, 210):anchor(0, 1)

	label:nextLine():addLabel(text, cc.c3b(255, 255, 255))

	if btns then
		local confirm = true
		local cancel = true

		if type(btns) == "table" then
			confirm = btns.confirm
			cancel = btns.cancel
		end

		if confirm then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				self.evtCallback_("GuideBoardEvt_confirm")
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/common/confirm.png")
			}):pos(370, 15):addto(spr)
		end

		if cancel then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				self.evtCallback_("GuideBoardEvt_cancel")
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/common/cancel.png")
			}):pos(480, 15):addto(spr)
		end
	end

	return n
end

function guide:stop()
	local t = self.widgetCheckers_
	self.widgetCheckers_ = {}

	for k, v in pairs(t) do
		v()
	end

	local t = self.twinkleNodeStops_
	self.twinkleNodeStops_ = {}

	for k, v in pairs(t) do
		v()
	end

	local t = self.dragGuideImage_
	self.dragGuideImage_ = {}

	for k, v in pairs(t) do
		if not tolua.isnull(v) then
			v:removeSelf()
		end
	end

	local t = self.tipTexts_
	self.tipTexts_ = {}

	for k, v in pairs(t) do
		if not tolua.isnull(v) then
			v:removeSelf()
		end
	end

	local t = self.hightLights_
	self.hightLights_ = {}

	for k, v in pairs(t) do
		v()
	end

	self:stopCurrentFocus()
end

function guide:testTouchSwallower()
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local l10000 = nil
	l10000 = self:touchSwallower(function (evt)
		print(evt, "func10000")

		if evt == "ended" then
			eventDispatcher:removeEventListener(l10000)
		end
	end, -10000)
	local l100000 = nil
	l100000 = self:touchSwallower(function (evt)
		print(evt, "func100000")

		if evt == "ended" then
			eventDispatcher:removeEventListener(l100000)
		end
	end, -100000)
end

function guide:testFocus()
	self:focusNodeByName("relation(-43,22)", function (evtName, pos, hited)
		if evtName == "ended" and hited then
			self:stopCurrentFocus()
		end

		return true
	end)
end

function guide:testDrag()
	self:dragGuide("rocker_walk", "rocker_run")
	scheduler.performWithDelayGlobal(function ()
		self:stopDragGuide()
	end, 10)
end

function guide:testFocusDynamic()
	self:focusNodeByName({
		"diy_tmpIcon",
		"diyPanel_btnPanelBag",
		"diy(20,82)"
	}, function (evtName, pos, hited)
		return true
	end, true)
	self:checkUntilNodeExist("diy_背包", function (evt)
		print(evt)
		self:stopCurrentFocus()
	end)
end

function guide:testCheckWidget()
	print(self:isNodeExist("diy_挖取"))
	self:checkUntilNodeExist("diy_小助手", function (state)
		print(state)
	end, 10)
end

function guide:testHightLight()
	local resume = self:hightLightNode({
		"diy_下属"
	})

	scheduler.performWithDelayGlobal(function ()
		self:disableHightLight(resume)
	end, 10)
end

function guide:testTwinkle()
	self:twinkleNodeWidthName("diy_下属", {
		w = 35,
		circle = false,
		h = 65,
		radio = 40
	})
end

return guide
