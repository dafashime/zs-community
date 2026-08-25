local operate = {}

function operate.init()
	operate.pressed = {}

	def.operate.init()

	local listener = cc.EventListenerKeyboard:create()

	listener:registerScriptHandler(function(keyCode, evt)
		table.insert(operate.pressed, keyCode)
	end, cc.Handler.EVENT_KEYBOARD_PRESSED)
	listener:registerScriptHandler(function(keyCode, evt)
		local trigger = def.operate.isTrigger(keyCode, operate.pressed)

		if trigger and trigger.event then
			operate.handlerKeybord(trigger)
		end

		for idx, _keycode in ipairs(operate.pressed) do
			if keyCode == _keycode then
				table.remove(operate.pressed, idx)

				break
			end
		end
	end, cc.Handler.EVENT_KEYBOARD_RELEASED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

	local _mouseListener = cc.EventListenerMouse:create()

	_mouseListener:registerScriptHandler(function(evt)
		local keyCode = evt:getMouseButton()
		local trigger = def.operate.isTrigger(keyCode, operate.pressed)

		if trigger and trigger.event and operate[trigger.event .. "_begin"] then
			operate[trigger.event .. "_begin"](trigger, evt)
		end
	end, cc.Handler.EVENT_MOUSE_DOWN)
	_mouseListener:registerScriptHandler(function(evt)
		operate.mouseMoveControl(evt)

		local keyCode = evt:getMouseButton()
		local trigger = def.operate.isTrigger(keyCode, operate.pressed)

		if trigger and trigger.event and operate[trigger.event .. "_moved"] then
			operate[trigger.event .. "_moved"](trigger, evt)
		end
	end, cc.Handler.EVENT_MOUSE_MOVE)
	_mouseListener:registerScriptHandler(function(evt)
		local keyCode = evt:getMouseButton()
		local trigger = def.operate.isTrigger(keyCode, operate.pressed)

		if trigger and trigger.event and operate[trigger.event .. "_end"] then
			operate[trigger.event .. "_end"](trigger, evt)
		end
	end, cc.Handler.EVENT_MOUSE_UP)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(_mouseListener, 1)
	operate.hideUI()
end

function operate.hideUI()
	if main_scene then
		local rocker = main_scene.ui.console:get("rocker")

		if rocker then
			rocker:setVisible(false)
		end

		local lock = main_scene.ui.console:get("lock")

		if lock then
			lock:setVisible(false)
		end
	end
end

function operate.handlerKeybord(info)
	if info.keyType then
		if info.keyType == "panel" then
			if main_scene then
				sound.playSound("103")
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
			end
		elseif info.keyType == "skill" then
			if info.params and info.params.magicId then
				operate.useMagic(info.params.magicId)
			end
		elseif info.keyType == "normal" then
			if main_scene then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
			end
		elseif info.keyType == "base" then
			if main_scene then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
			end
		elseif info.keyType == "setting" then
			if main_scene then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
			end
		elseif info.keyType == "hero" then
			if main_scene then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
			end
		elseif operate[info.event] then
			operate[info.event](info)
		end
	elseif operate[info.event] then
		operate[info.event](info)
	end
end

function operate.mouseMoveControl(evt)
	operate.mouseX = evt:getCursorX()
	operate.mouseY = evt:getCursorY()

	if main_scene then
		local lock = main_scene.ui.console.controller.lock
		local target = operate.getTouchMonTarget(operate.mouseX, operate.mouseY)

		if target then
			local role = main_scene.ground.map:findRole(target)

			if role and not role.isPlayer and lock.target.select ~= role.roleid then
				lock:setSelectTarget(role)
			end
		elseif not lock.target.attack then
			lock:stop()
		end
	end
end

function operate.getTouchMonTarget(eventX, eventY)
	local map = main_scene.ground.map

	if map and map.player then
		local x, y = map:getMapPosWithScreenPos(eventX, eventY)
		local roles = {}

		table.merge(roles, map.mons)

		local roles = main_scene.ui.console.controller:sortRoles(table.values(roles))

		for i, v in ipairs(roles) do
			if cc.rectContainsPoint(v:getBoundingBox(), cc.p(x, y)) and not v.die then
				return v.roleid
			end
		end
	end
end

function operate.useMagic(magicId)
	if main_scene then
		local lock = main_scene.ui.console.controller.lock
		local map = main_scene.ground.map
		local magic_data = g_data.player:getMagic(magicId)

		main_scene.ui.console.btnCallbacks:handle("skill", magicId, magic_data)

		if lock.skill.enable then
			if lock.target.select then
				local role = map:findRole(lock.target.select)

				if checkExist("lock", lock.skill.config.type, lock.skill.config.first) then
					lock:setSkillTarget(role)
				end

				main_scene.ui.console.controller:useMagic(role.x, role.y)
			elseif map then
				local x, y = map:getMapPosWithScreenPos(operate.mouseX, operate.mouseY)

				main_scene.ui.console.controller:useMagic(map:getGamePos(x, y))
			end
		end
	end
end

function operate.onMouseLeft_begin(info, evt)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		local x, y = evt:getCursorX(), evt:getCursorY()

		main_scene.ui.console.controller.move.step = 1

		main_scene.ui.console.controller:handleTouch({
			name = "began",
			x = x,
			y = y
		})
	end
end

function operate.onMouseLeft_moved(info, evt)
	if main_scene then
		local x, y = evt:getCursorX(), evt:getCursorY()
		local controller = main_scene.ui.console.controller

		if not controller.move.step then
			return
		end

		if not operate.isCanTouch() then
			return
		end

		controller.move.step = 1

		controller:handleTouch({
			name = "moved",
			x = x,
			y = y
		})
	end
end

function operate.onMouseLeft_end(info, evt)
	if main_scene then
		if not main_scene.ui.console.controller.touchGround then
			return
		end

		local x, y = evt:getCursorX(), evt:getCursorY()

		main_scene.ui.console.controller:handleTouch({
			name = "ended",
			x = x,
			y = y
		})

		main_scene.ui.console.controller.move.step = nil
		main_scene.ui.console.controller.touchGround = nil
	end
end

function operate.onMouseRight_begin(info, evt)
	if main_scene then
		local x, y = evt:getCursorX(), evt:getCursorY()

		main_scene.ui.console.controller.move.step = 2

		main_scene.ui.console.controller:handleTouch({
			name = "began",
			x = x,
			y = y
		})
	end
end

function operate.onMouseRight_moved(info, evt)
	if main_scene then
		local x, y = evt:getCursorX(), evt:getCursorY()
		local controller = main_scene.ui.console.controller

		if not controller.move.step then
			return
		end

		controller.move.step = 2

		controller:handleTouch({
			name = "moved",
			x = x,
			y = y
		})
	end
end

function operate.onMouseRight_end(info, evt)
	if main_scene then
		local x, y = evt:getCursorX(), evt:getCursorY()

		main_scene.ui.console.controller:handleTouch({
			name = "ended",
			x = x,
			y = y
		})

		main_scene.ui.console.controller.move.step = nil
		main_scene.ui.console.controller.touchGround = nil
	end
end

function operate.onMouseLeft_SF_begin(info, evt)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		main_scene.ui.console.controller.openShift = true

		local map = main_scene.ground.map
		local player = main_scene.ground.player
		local x, y = map:getMapPosWithScreenPos(evt:getCursorX(), evt:getCursorY())
		local gameX, gameY = map:getGamePos(x, y)
		local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

		main_scene.ui.console.controller:forceAttackTest(dir)

		main_scene.ui.console.controller.openShift = false
	end
end

function operate.onMouseLeft_Alt_begin(info, evt)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		main_scene.ui.console.controller.autoWa = true

		local map = main_scene.ground.map
		local player = main_scene.ground.player
		local x, y = map:getMapPosWithScreenPos(evt:getCursorX(), evt:getCursorY())
		local gameX, gameY = map:getGamePos(x, y)
		local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

		if dir ~= player.dir then
			net.send({
				CM_TURN,
				recog = player.x,
				param = player.y,
				series = dir
			})
			player:addAct({
				type = "stand",
				dir = dir,
				x = player.x,
				y = player.y
			})
		end
	end
end

function operate.onMouseLeft_Alt_end(info, evt)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		main_scene.ui.console.controller.autoWa = false
	end
end

function operate.isCanTouch()
	if main_scene and main_scene.ui.console.controller.touchGround then
		return true
	end

	return false
end

function operate.onMouseRight_ctrl_begin(info)
	return
end

function operate.onKeybord_A(info)
	print("-------------onKeybord_A------------")
end

function operate.onKeybord_B(info)
	if main_scene then
		sound.playSound("103")
		main_scene.ui.console.btnCallbacks:handle("panel", "bag")
	end
end

function operate.onKeybord_C(info)
	print("-------------onKeybord_C------------")
end

function operate.onKeybord_SF_A(info)
	print("-------------onKeybord_SF_A------------")
end

return operate
