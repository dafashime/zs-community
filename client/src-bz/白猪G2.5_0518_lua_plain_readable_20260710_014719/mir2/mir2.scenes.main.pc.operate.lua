local common = import("..common.common")
local mapDef = import("..map.def")
local operate = {}

function operate.init()
	operate.pressed = {}

	def.operate.init()

	operate.listener = cc.EventListenerKeyboard:create()

	operate.listener:registerScriptHandler(function(keyCode, evt)
		if not main_scene or g_data.hotKey.isSettingKey then
			return
		end

		operate.keyBoard_event_down(keyCode, evt)
	end, cc.Handler.EVENT_KEYBOARD_PRESSED)
	operate.listener:registerScriptHandler(function(keyCode, evt)
		if not main_scene or g_data.hotKey.isSettingKey then
			return
		end

		operate.keyBoard_event_up(keyCode, evt)
	end, cc.Handler.EVENT_KEYBOARD_RELEASED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(operate.listener, 1)

	operate.mouseListener = cc.EventListenerMouse:create()

	operate.mouseListener:registerScriptHandler(function(evt)
		if not main_scene or g_data.hotKey.isSettingKey then
			return
		end

		operate.mouseX = evt:getCursorX()
		operate.mouseY = evt:getCursorY()

		operate.mouse_event_down(evt)
	end, cc.Handler.EVENT_MOUSE_DOWN)
	operate.mouseListener:registerScriptHandler(function(evt)
		if not main_scene or g_data.hotKey.isSettingKey then
			return
		end

		operate.mouseX = evt:getCursorX()
		operate.mouseY = evt:getCursorY()

		operate.mouseMoveControl()
		operate.mouse_event_move(evt)
	end, cc.Handler.EVENT_MOUSE_MOVE)
	operate.mouseListener:registerScriptHandler(function(evt)
		if not main_scene or g_data.hotKey.isSettingKey then
			return
		end

		operate.mouseX = evt:getCursorX()
		operate.mouseY = evt:getCursorY()

		operate.mouse_event_up(evt)
	end, cc.Handler.EVENT_MOUSE_UP)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(operate.mouseListener, 1)
	operate.hideUI()
end

function operate.unRegisterEvent()
	if operate.mouseListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(operate.mouseListener)

		operate.mouseListener = nil
	end

	if operate.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(operate.listener)

		operate.listener = nil
	end
end

function operate.keyBoard_event_down(keyCode, evt)
	table.insert(operate.pressed, keyCode)

	local trigger = g_data.hotKey:isTrigger(keyCode, operate.pressed)

	if trigger then
		if trigger.isKeybord then
			operate.handlerKeybord(trigger)
		else
			if operate.mouseTrigger then
				operate.stopWalk()
			end

			if trigger and trigger.event then
				operate.mouseTrigger = trigger

				if operate[operate.mouseTrigger.event .. "_begin"] then
					operate.mouseTrigger.owner = "keyboard"

					operate[operate.mouseTrigger.event .. "_begin"](operate.mouseTrigger)
				end
			end
		end
	end
end

function operate.keyBoard_event_up(keyCode, evt)
	if operate.mouseTrigger and operate.mouseTrigger.event then
		if operate[operate.mouseTrigger.event .. "_end"] then
			operate.mouseTrigger.owner = "keyboard"

			operate[operate.mouseTrigger.event .. "_end"](operate.mouseTrigger)
		end

		operate.mouseTrigger = nil
	end

	local trigger = g_data.hotKey:isTrigger(keyCode, operate.pressed)

	if trigger and trigger.event and operate[trigger.event .. "_up"] then
		operate[trigger.event .. "_up"](trigger)
	end

	for idx, _keycode in ipairs(operate.pressed) do
		if keyCode == _keycode then
			table.remove(operate.pressed, idx)

			break
		end
	end
end

function operate.mouse_event_down(evt)
	if operate.mouseTrigger then
		return
	end

	operate.mouseKeyCode = evt:getMouseButton()

	table.insert(operate.pressed, operate.mouseKeyCode)

	operate.mouseTrigger = g_data.hotKey:isTrigger(operate.mouseKeyCode, operate.pressed)

	if operate.mouseTrigger and operate.mouseTrigger.event and operate[operate.mouseTrigger.event .. "_begin"] then
		operate.mouseTrigger.owner = "mouse"

		operate[operate.mouseTrigger.event .. "_begin"](operate.mouseTrigger)
	end
end

function operate.mouse_event_move(evt)
	if operate.mouseTrigger and operate.mouseTrigger.event and operate[operate.mouseTrigger.event .. "_moved"] then
		operate.mouseTrigger.owner = "mouse"

		operate[operate.mouseTrigger.event .. "_moved"](operate.mouseTrigger)
	end
end

function operate.mouse_event_up(evt)
	if operate.mouseTrigger and operate.mouseTrigger.event and operate[operate.mouseTrigger.event .. "_end"] then
		operate.mouseTrigger.owner = "mouse"

		operate[operate.mouseTrigger.event .. "_end"](operate.mouseTrigger)
	end

	for idx, _keycode in ipairs(operate.pressed) do
		if operate.mouseKeyCode == _keycode then
			table.remove(operate.pressed, idx)

			break
		end
	end

	operate.mouseTrigger = nil
	operate.mouseKeyCode = nil
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

		local btnDiy = main_scene.ui.console:get("btnDiy")

		if btnDiy then
			btnDiy:setVisible(false)
		end

		local btnPet = main_scene.ui.console:get("btnPet")

		if btnPet then
			btnPet:setVisible(false)
		end

		local btnPropHongyao = main_scene.ui.console:get("btnPropHongyao")

		if btnPropHongyao then
			btnPropHongyao:setVisible(false)
		end

		local btnPropLanyao = main_scene.ui.console:get("btnPropLanyao")

		if btnPropLanyao then
			btnPropLanyao:setVisible(false)
		end

		local btnPropShunhui = main_scene.ui.console:get("btnPropShunhui")

		if btnPropShunhui then
			btnPropShunhui:setVisible(false)
		end

		local btnAttack = main_scene.ui.console:get("btnAttack")

		if btnAttack then
			btnAttack:setVisible(false)
		end

		local btnLock = main_scene.ui.console:get("btnLock")

		if btnLock then
			btnLock:setVisible(false)
		end

		local btnShift = main_scene.ui.console:get("btnShift")

		if btnShift then
			btnShift:setVisible(false)
		end

		local btnPanelEquip = main_scene.ui.console:get("btnPanelEquip")

		if btnPanelEquip then
			btnPanelEquip:setVisible(false)
		end

		local btnPanelBag = main_scene.ui.console:get("btnPanelBag")

		if btnPanelBag then
			btnPanelBag:setVisible(false)
		end

		local btnPanelSkill = main_scene.ui.console:get("btnPanelSkill")

		if btnPanelSkill then
			btnPanelSkill:setVisible(false)
		end

		local btnBackHome = main_scene.ui.console:get("btnBackHome")

		if btnBackHome then
			btnBackHome:setVisible(false)
		end

		local chat = main_scene.ui.console:get("chat")

		if chat then
			chat.data.w = 480
			chat.data.h = 150

			chat:size(chat.data.w, chat.data.h)

			if chat.frame then
				chat.frame:size(chat:getContentSize()):pos(chat:centerPos())
			end

			chat.data.fontSize = 14

			chat:loadScroll()
			chat:loadInput()
			chat:pos(540, 102)
		end

		local hp = main_scene.ui.console:get("hp")

		if hp then
			hp:pos(210, 69)
		end

		local btnChat = main_scene.ui.console:get("btnChat")

		if btnChat then
			btnChat:pos(256, 154)
		end
	end
end

function operate.handlerKeybord(info)
	if info.keyType then
		if info.keyType == "panel" then
			if main_scene then
				sound.playSound("103")

				if info.params and info.params.name then
					if (info.params.name == "equip" or info.params.name == "state" or info.params.name == "attributes" or info.params.name == "skill") and main_scene.ui.panels.equip and main_scene.ui.panels.equip.page ~= info.params.name then
						main_scene.ui:hidePanel("equip")
					end

					main_scene.ui.console.btnCallbacks:handle(info.keyType, info.params.name)
				end
			end
		elseif info.keyType == "skill" then
			if info.params and info.params.magicId then
				operate.useMagic(info.params.magicId)
			end
		elseif info.keyType == "customs" then
			if main_scene then
				for _, btn in ipairs(main_scene.ui.customs) do
					if tonumber(info.params.index) == tonumber(btn.config.id) then
						main_scene.ui.console.btnCallbacks:handle("custom", btn)

						break
					end
				end
			end
		elseif info.keyType == "normal" then
			if info.params and info.params.name then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.params.name)
			end
		elseif info.keyType == "base" then
			if info.params and info.params.name then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.params.name)
			end
		elseif info.keyType == "setting" then
			if info.params and info.params.name then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.params.name)
			end
		elseif info.keyType == "hero" then
			if info.params and info.params.name then
				main_scene.ui.console.btnCallbacks:handle(info.keyType, info.params.name)
			end
		elseif info.keyType == "pet" then
			net.send({
				CM_SAY
			}, {
				"@rest"
			})
		elseif info.keyType == "attackMode" then
			local texts = {
				{
					"quanti",
					"全体"
				},
				{
					"heping",
					"和平"
				},
				{
					"bianzu",
					"编组"
				},
				{
					"hanghui",
					"行会"
				},
				{
					"shane",
					"善恶"
				},
				{
					"shitu",
					"战队"
				}
			}
			local btnMode = main_scene.ui.console:get("btnMode")

			for i, v in ipairs(texts) do
				if v[1] == btnMode:mode2filename(g_data.player.attackMode) then
					local next_i = i % 6

					net.send({
						CM_ATTACKMODE,
						tag = next_i
					})
				end
			end
		elseif info.keyType == "exit" then
			local btnExit = main_scene.ui.console:get("btnExit")

			if btnExit then
				btnExit:click()
			end
		elseif info.event and operate[info.event] then
			operate[info.event](info)
		end
	elseif info.event and operate[info.event] then
		operate[info.event](info)
	end
end

function operate.mouseMoveControl()
	if main_scene then
		local controller = main_scene.ui.console.controller
		local lock = controller.lock
		local map = main_scene.ground.map

		if controller.move.step then
			controller.move.x = operate.mouseX
			controller.move.y = operate.mouseY
		end

		local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

		if touchTarget then
			if type(touchTarget) == "number" then
				local role = map:findRole(touchTarget)

				if not role.isPlayer then
					if operate.select_role and operate.select_role ~= role then
						operate.select_role.info:setForceName(false)

						if not operate.select_role.info:isShowName() then
							operate.select_role.info:setName(operate.select_role.info.name.texts, true)
						end

						operate.select_role:unHighLight()

						operate.select_role = nil
					end

					role:highLight()

					if not role.info:isShowName() then
						role.info:setForceName(true)
						role.info:setName(role.info.name.texts, true)
					end

					operate.select_role = role
				end
			end
		elseif operate.select_role then
			for _, role in ipairs(operate.getRoles()) do
				if operate.select_role == role then
					operate.select_role.info:setForceName(false)

					if not operate.select_role.info:isShowName() then
						operate.select_role.info:setName(operate.select_role.info.name.texts, true)
					end

					operate.select_role:unHighLight()

					break
				end
			end

			operate.select_role = nil
		end
	end
end

function operate.stopWalk()
	if main_scene then
		local controller = main_scene.ui.console.controller

		controller.move.enable = false
		controller.move.step = nil
	end
end

function operate.onMouseLeft_begin(info)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		local controller = main_scene.ui.console.controller
		local x, y = operate.mouseX, operate.mouseY

		controller.autoFindPath:multiMapPathStop()

		controller.autoMining = false

		local touchTarget = operate.getTouchTarget(x, y)

		if not touchTarget then
			controller.move.enable = "pos"
			controller.move.step = 1
			controller.move.x = x
			controller.move.y = y
		end
	end
end

function operate.onMouseLeft_end(info)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		local controller = main_scene.ui.console.controller
		local lock = controller.lock
		local map = main_scene.ground.map
		local x, y = operate.mouseX, operate.mouseY
		local touchTarget = operate.getTouchTarget(x, y)

		if touchTarget then
			if type(touchTarget) == "number" then
				local role = map:findRole(touchTarget)

				if role then
					if role.__cname == "npc" then
						net.send({
							CM_CLICKNPC,
							recog = touchTarget
						})
					elseif not role.isPlayer then
						if role.__cname == "hero" then
							if lock.target.select ~= role.roleid then
								lock:setSelectTarget(role)
							end
						else
							lock:cancelSelect()
							lock:setAttackTarget(role)
						end
					elseif role.isPlayer then
						local pos = role.node:convertToNodeSpace(cc.p(x, y))

						if pos.y >= 0 and pos.y < 30 then
							local player = main_scene.ground.player

							controller:pickupTest(map, player, true)
						end
					end
				end
			elseif touchTarget.type and touchTarget.type == "stall" then
				if lock.target and lock.target.attack then
					local selectRole = lock.target.attack

					if type(lock.target.attack) == "number" then
						selectRole = map:findRole(selectRole)
					end

					lock:setSelectTarget(selectRole)
				end

				lock:setAttackTarget()

				local open = false

				if main_scene.ui.panels.stall or main_scene.ui.panels.stallOther then
					open = true

					main_scene.ui:hidePanel("stall")
					main_scene.ui:hidePanel("stallOther")
				end

				if not open then
					net.send({
						CM_QUERY_STALL
					}, nil, {
						{
							"ID",
							touchTarget.id
						}
					})
				end
			end
		else
			lock:cancelSelect()
			lock:setAttackTarget()
		end

		controller.move.enable = false
		controller.move.step = nil
		controller.touchGround = nil
	end
end

function operate.onMouseRight_begin(info)
	if main_scene then
		if main_scene.ui.isChoseItem then
			return
		end

		local controller = main_scene.ui.console.controller
		local x, y = operate.mouseX, operate.mouseY

		controller.autoFindPath:multiMapPathStop()

		controller.autoMining = false
		controller.move.enable = "pos"
		controller.move.step = 2
		controller.move.x = x
		controller.move.y = y
	end
end

function operate.onMouseRight_end(info)
	if main_scene then
		local controller = main_scene.ui.console.controller

		controller.move.enable = false
		controller.move.step = nil
		controller.touchGround = nil
	end
end

function operate.onMouseLeft_SF_begin(info)
	if main_scene then
		local x, y = operate.mouseX, operate.mouseY

		if not operate.isCanTouch(x, y) then
			return
		end

		main_scene.ui.console.controller.openShift = true

		local controller = main_scene.ui.console.controller

		if controller.openShift then
			local lock = controller.lock
			local map = main_scene.ground.map
			local x, y = operate.mouseX, operate.mouseY
			local touchTarget = operate.getTouchTarget(x, y)

			if touchTarget then
				if type(touchTarget) == "number" then
					local role = map:findRole(touchTarget)

					if role and not role.isPlayer and (role.__cname == "mon" or role.__cname == "hero") then
						if role.__cname == "hero" then
							if lock.target.select ~= role.roleid then
								lock:setSelectTarget(role)
							end
						else
							lock:cancelSelect()
						end

						lock:setAttackTarget(role)
					end
				end
			else
				if lock.target.attack then
					lock:cancelSelect()
					lock:setAttackTarget()
				end

				local player = main_scene.ground.player
				local i_x, i_y = map:getMapPosWithScreenPos(operate.mouseX, operate.mouseY)
				local gameX, gameY = map:getGamePos(i_x, i_y)
				local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

				controller:forceAttackTest(dir)
			end
		end
	end
end

function operate.onMouseLeft_SF_end(info)
	if main_scene then
		local controller = main_scene.ui.console.controller

		if info.owner == "keyboard" then
			local lock = controller.lock
			local map = main_scene.ground.map
			local attack = lock.target.attack

			if attack then
				if type(attack) == "number" then
					attack = map:findRole(attack)
				end

				if attack and attack.__cname == "hero" then
					lock:setAttackTarget()
				end
			end
		end

		controller.openShift = false
	end
end

function operate.onKeybord_SF()
	if main_scene then
		local controller = main_scene.ui.console.controller
		local lock = controller.lock
		local map = main_scene.ground.map

		if lock.target.select then
			local role = map:findRole(lock.target.select)

			if role.__cname == "hero" and not role.isPlayer then
				lock:setAttackTarget(role)
			end
		end
	end
end

function operate.onKeybord_SF_up(info)
	info.owner = "keyboard"

	operate.onMouseLeft_SF_end(info)
end

function operate.onMouseLeft_Alt_begin(info)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		main_scene.ui.console.controller.autoWa = true

		local map = main_scene.ground.map
		local player = main_scene.ground.player
		local x, y = map:getMapPosWithScreenPos(operate.mouseX, operate.mouseY)
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

function operate.onMouseLeft_Alt_end(info)
	if main_scene then
		if not operate.isCanTouch() then
			return
		end

		main_scene.ui.console.controller.autoWa = false
	end
end

function operate.onMouseRight_ctrl_end(info)
	if main_scene then
		local x, y = operate.mouseX, operate.mouseY

		if not operate.isCanTouch(x, y) then
			return
		end

		local controller = main_scene.ui.console.controller
		local lock = controller.lock
		local map = main_scene.ground.map
		local touchTarget = operate.getTouchTarget(x, y)

		if touchTarget then
			local role = map:findRole(touchTarget)

			if role and role.__cname == "hero" and not role.isPlayer then
				if g_data.client:checkLastTime("queryOther", 1) then
					g_data.client:setLastTime("queryOther", true)
					net.send({
						CM_QUERYUSERSTATE,
						recog = role.roleid,
						param = role.x,
						tag = role.y
					})
					net.send({
						CM_QUERY_TITLE,
						0,
						recog = role.roleid,
						param = role.x,
						tag = role.y
					})
				else
					main_scene.ui:tip("你查看太快了!!!")
				end
			end
		end
	end
end

function operate.onKeybord_ctrl_W(info, evt)
	local controller = main_scene.ui.console.controller
	local lock = controller.lock
	local map = main_scene.ground.map
	local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

	if touchTarget and g_data.client:checkLastTime("heroLock", 1) then
		g_data.client:setLastTime("heroLock", true)

		local gameX, gameY = map:getGamePos(operate.mouseX, operate.mouseY)

		net.send({
			CM_HERO_APPTARG,
			recog = touchTarget,
			param = gameX,
			tag = gameY
		})
	end
end

function operate.onKeybord_ctrl_Q(info, evt)
	local controller = main_scene.ui.console.controller
	local lock = controller.lock
	local map = main_scene.ground.map
	local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

	if touchTarget and g_data.client:checkLastTime("heroGuard", 1) then
		g_data.client:setLastTime("heroGuard", true)

		local gameX, gameY = map:getGamePos(operate.mouseX, operate.mouseY)

		net.send({
			CM_HERO_APPTARG,
			series = 1,
			param = gameX,
			tag = gameY
		})
	end
end

function operate.onKeybord_Alt_W(info, evt)
	local controller = main_scene.ui.console.controller
	local lock = controller.lock
	local map = main_scene.ground.map
	local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

	if touchTarget then
		local role = map:findRole(touchTarget)

		if role and not role.isPlayer and role.__cname == "hero" then
			local name = role.info:getName()

			if name and name ~= "" then
				g_data.client:setLastTime("group", true)
				net.send({
					#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
				}, {
					name
				})
			end
		end
	end
end

function operate.onKeybord_Alt_S(info, evt)
	local controller = main_scene.ui.console.controller
	local lock = controller.lock
	local map = main_scene.ground.map
	local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

	if touchTarget then
		local role = map:findRole(touchTarget)

		if role and not role.isPlayer and role.__cname == "hero" then
			local name = role.info:getName()

			if name and name ~= "" then
				net.send({
					CM_ADD_RELATION_NORMBLACKLIST
				}, {
					name
				})
			end
		end
	end
end

function operate.onKeybord_Alt_R(info, evt)
	local controller = main_scene.ui.console.controller
	local lock = controller.lock
	local map = main_scene.ground.map
	local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

	if touchTarget then
		local role = map:findRole(touchTarget)

		if role and not role.isPlayer and role.__cname == "hero" then
			local name = role.info:getName()

			if name and name ~= "" then
				net.send({
					CM_ADD_RELATION_ATTENTION
				}, {
					name
				})
			end
		end
	end
end

function operate.isCanTouch(x, y)
	if not main_scene then
		return false
	end

	if main_scene.ui.isChoseItem then
		return false
	end

	local controller = main_scene.ui.console.controller

	if x and y then
		local nodes = sortNodes(table.values(controller.console.widgets))

		for i, v in ipairs(nodes) do
			if v:isVisible() then
				if v.getClickRect and cc.rectContainsPoint(v:getClickRect(), cc.p(x, y)) then
					return false
				end

				if v.getBoundingBox and cc.rectContainsPoint(v:getBoundingBox(), cc.p(x, y)) then
					return false
				end
			end
		end

		for _, v in pairs(main_scene.ui.panels) do
			if v:isVisible() and v:checkInPanel(cc.p(x, y)) then
				return false
			end
		end
	else
		return controller.touchGround
	end

	return true
end

function operate.getRoles()
	local map = main_scene.ground.map
	local roles = {}

	table.merge(roles, map.heros)
	table.merge(roles, map.mons)
	table.merge(roles, map.npcs)

	roles = main_scene.ui.console.controller:sortRoles(table.values(roles))

	return roles
end

function operate.getTouchTarget(eventX, eventY)
	local map = main_scene.ground.map

	if map and map.player then
		local x, y = map:getMapPosWithScreenPos(eventX, eventY)
		local roles = operate.getRoles()

		for i, v in ipairs(roles) do
			if cc.rectContainsPoint(v.node:getBoundingBox(), cc.p(x, y)) and not v.die then
				return v.roleid
			end
		end

		for i, v in pairs(map.stalls) do
			if cc.rectContainsPoint(v.npc:getBoundingBox(), v:convertToNodeSpace(cc.p(x, y))) or cc.rectContainsPoint(v.stall:getBoundingBox(), v:convertToNodeSpace(cc.p(x, y))) then
				v.type = "stall"

				return v
			end
		end
	end
end

function operate.useMagic(magicId)
	if main_scene then
		local controller = main_scene.ui.console.controller
		local lock = controller.lock
		local console = main_scene.ui.console
		local map = main_scene.ground.map
		local magic_data = g_data.player:getMagic(magicId)

		console.btnCallbacks:handle("skill", magicId, magic_data)

		lock.skill.data = magic_data
		lock.skill.config = def.magic.getMagicConfigByUid(magicId)

		if not lock.skill.config then
			return
		end

		if lock.skill.config.type ~= "area" then
			lock.target.skill = lock.target.skill or lock.target.attack

			local touchTarget = operate.getTouchTarget(operate.mouseX, operate.mouseY)

			if touchTarget then
				if type(touchTarget) == "number" then
					local role = map:findRole(touchTarget)

					if (role.__cname == "mon" or role.__cname == "hero") and not role.isPlayer then
						if checkExist("lock", lock.skill.config.type, lock.skill.config.first) then
							lock:setSkillTarget(role)
						end

						controller:useMagic(role.x, role.y)
					end
				end
			elseif lock.target.skill then
				controller:useMagic()
			else
				controller:useMagic()

				if map then
					local x, y = map:getMapPosWithScreenPos(operate.mouseX, operate.mouseY)

					controller:useMagic(map:getGamePos(x - 1, y))
				end
			end
		elseif map then
			local x, y = map:getMapPosWithScreenPos(operate.mouseX, operate.mouseY)

			controller:useMagic(map:getGamePos(x - 1, y))
		end
	end
end

return operate
