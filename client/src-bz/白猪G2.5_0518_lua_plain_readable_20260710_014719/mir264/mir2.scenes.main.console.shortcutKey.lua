local common = import("..common.common")
local shortcutKey = {
	code = {},
	keyEvent = {
		["Alt+D"] = "lookfor",
		["Alt+T"] = "kickPreRoom",
		["Alt+S"] = "noSpeaking",
		["Alt+F"] = "gmToolShow",
		["Alt+A"] = "kickBlackHouse"
	},
	pos = {
		x = 0,
		y = 0
	}
}
local MOUSE_BUTTON_LEFT = 0
local MOUSE_BUTTON_RIGHT = 1
local MOUSE_BUTTON_MIDDLE = 2

function shortcutKey.init(scene)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

	if device.platform == "windows" then
		local function onKeyPressed(keycode, event)
			shortcutKey.code[#shortcutKey.code + 1] = shortcutKey.code2key(keycode)

			shortcutKey.progress()
		end

		local function onKeyReleased(keycode, event)
			table.removebyvalue(shortcutKey.code, shortcutKey.code2key(keycode), true)
		end

		local listener = cc.EventListenerKeyboard:create()

		listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
		listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)
	end

	if main_scene == scene then
		local function onMouseDown(event)
			if event:getMouseButton() == MOUSE_BUTTON_RIGHT then
				main_scene.ui.console.controller:changeMouseMode("right")

				local event = {
					name = "began",
					x = event:getCursorX(),
					y = event:getCursorY()
				}

				main_scene.ui.console.controller:handleTouch(event)
			end
		end

		local function onMouseMove(event)
			shortcutKey.pos.x = event:getCursorX()
			shortcutKey.pos.y = event:getCursorY()

			if event:getMouseButton() == MOUSE_BUTTON_RIGHT then
				local event = {
					name = "moved",
					x = event:getCursorX(),
					y = event:getCursorY()
				}

				main_scene.ui.console.controller:handleTouch(event)
			end
		end

		local function onMouseUp(event)
			if event:getMouseButton() == MOUSE_BUTTON_RIGHT then
				local event = {
					name = "ended",
					x = event:getCursorX(),
					y = event:getCursorY()
				}

				main_scene.ui.console.controller:handleTouch(event)
			end
		end

		local listener = cc.EventListenerMouse:create()

		listener:registerScriptHandler(onMouseDown, cc.Handler.EVENT_MOUSE_DOWN)
		listener:registerScriptHandler(onMouseMove, cc.Handler.EVENT_MOUSE_MOVE)
		listener:registerScriptHandler(onMouseUp, cc.Handler.EVENT_MOUSE_UP)
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scene)
	end
end

function shortcutKey.code2key(code)
	local char

	if code == 16 then
		char = "Alt"
	elseif code == 124 then
		char = "A"
	elseif code == 127 then
		char = "D"
	elseif code == 129 then
		char = "F"
	elseif code == 142 then
		char = "S"
	elseif code == 143 then
		char = "T"
	end

	return char
end

function shortcutKey.progress()
	for i, v in pairs(shortcutKey.keyEvent) do
		local match = true
		local keys = string.split(i, "+")

		for _, k in ipairs(keys) do
			if not table.indexof(shortcutKey.code, k) then
				match = false

				break
			end
		end

		if match then
			for _, k in ipairs(keys) do
				table.removebyvalue(shortcutKey.code, k, true)
			end

			shortcutKey[v]()
		end
	end
end

function shortcutKey.gmToolShow()
	do return end

	gmTool:getInstance():showWindow()
end

function shortcutKey.kickBlackHouse()
	do return end

	local name = shortcutKey.mousePlayerName()

	if name then
		local text = "请确认是否将角色: " .. name .. " 踢至小黑屋"
		local cmd = "@KickOut " .. name .. " sd000"

		shortcutKey.msgbox(text, cmd)
	end
end

function shortcutKey.kickPreRoom()
	do return end

	local name = shortcutKey.mousePlayerName()

	if name then
		local text = "请确认是否将角色: " .. name .. " 踢至准备室"
		local cmd = "@KickOut " .. name .. " 0139~1"

		shortcutKey.msgbox(text, cmd)
	end
end

function shortcutKey.lookFor()
	do return end

	local name = shortcutKey.mousePlayerName()

	if name then
		common.say("@lookfor " .. shortcutKey.mousePlayerName())
	end
end

function shortcutKey.noSpeaking()
	do return end

	local name = shortcutKey.mousePlayerName()

	if name then
		local text = "请确认是否将角色: " .. name .. " 禁言1小时"
		local cmd = "@OutSay " .. name .. " 3600"

		shortcutKey.msgbox(text, cmd)
	end
end

function shortcutKey.mousePlayerName()
	do return end

	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player then
		return false
	end

	local x, y = map:getMapPosWithScreenPos(shortcutKey.pos.x, shortcutKey.pos.y)
	local roles = table.values(clone(map.heros))

	table.sort(roles, function(a, b)
		return a:getPositionY() < b:getPositionY()
	end)

	for i, v in ipairs(roles) do
		if cc.rectContainsPoint(v:getBoundingBox(), cc.p(x, y)) and not v.die then
			return v.info:getName()
		end
	end
end

function shortcutKey.msgbox(text, cmd)
	local reason = "疑似挂机"
	local remark = ""
	local _, bg = common.msgbox("", {
		okFunc = function()
			common.say(cmd)
		end
	})

	an.newLabel(text, 20, 1):addTo(bg):pos(bg:getw() / 2, 225):anchor(0.5, 0.5)

	local reasonCfg = {
		"疑似挂机",
		"工作室批量挂机",
		"宣传或进行赌博",
		"扰乱游戏秩序",
		"骗子或恶意黑单",
		"非法外挂"
	}
	local tog = {}

	for i, v in ipairs(reasonCfg) do
		tog[#tog + 1] = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(b)
			if b then
				reason = v

				for _, k in ipairs(tog) do
					k.btn:setIsSelect(not b)
				end

				tog[i].btn:setIsSelect(b)
			else
				tog[i].btn:setIsSelect(not b)
			end
		end, {
			label = {
				v,
				18,
				1
			},
			default = i == 1
		}):addTo(bg):pos(i % 2 == 0 and bg:getw() / 2 + 30 or 30, 225 - math.floor((i + 1) / 2) * 35):anchor(0, 0.5)
	end

	an.newLabel("备注", 18, 1):addTo(bg):pos(75, 80):anchor(0, 0.5)

	local input

	input = an.newInput(125, 80, 200, 30, 100, {
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png")
		},
		stop_call = function()
			remark = input:getText() or ""
		end
	}):add2(bg):anchor(0, 0.5)
end

return shortcutKey
