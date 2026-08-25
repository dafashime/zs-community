local current = ...
local tags = {
	assert = "断言",
	normal = "普通",
	net = "通讯",
	error = "lua错误"
}

function p2(tag, ...)
	print("_debug_", tag or "normal", ...)
end

function d2(tag, value2, desciption, nestin)
	dump("_debug_", tag or "normal", value2, desciption, nestin)
end

function __G__TRACKBACK__(errorMessage)
	p2("error", "----------------------------------------")
	p2("error", "程序错误: " .. tostring(errorMessage) .. "\n")
	p2("error", debug.traceback("", 2))
	p2("error", "----------------------------------------")
end

local dumpTag
local dump2 = dump

function dump(mark, tag, value2, desciption, nesting)
	if mark == "_debug_" then
		dumpTag = tag or "normal"

		dump2(value2, desciption, nesting)

		dumpTag = nil
	else
		dump2(mark, tag, value2, 1)
	end
end

_print = print

function print(mark, tag, ...)
	local str

	if mark == "_debug_" then
		local params = {
			...
		}

		for i = 1, select("#", ...) do
			local v4 = select(i, ...)
			local valueType = type(v4)

			if valueType == "boolean" then
				params[i] = v4 and "true" or "false"
			elseif valueType == "userdata" then
				params[i] = "userdata(" .. (v4.__cname or tolua.type(v4)) .. ")"
			elseif valueType ~= "string" and valueType ~= "number" then
				params[i] = valueType
			end
		end

		str = table.concat(params, "   ")
	else
		local params2 = {
			mark,
			tag,
			...
		}
		local arglen = select("#", ...) + 2

		if arglen == 2 and tag == nil then
			arglen = mark == nil and 0 or 1
		end

		for i2 = 1, arglen do
			local v5 = params2[i2]
			local valueType2 = type(v5)

			if valueType2 == "boolean" then
				params2[i2] = v5 and "true" or "false"
			elseif valueType2 == "userdata" then
				params2[i2] = "userdata(" .. (v5.__cname or tolua.type(v5)) .. ")"
			elseif valueType2 ~= "string" and valueType2 ~= "number" then
				params2[i2] = valueType2
			end
		end

		str = table.concat(params2, "   ")
		tag = dumpTag or "other"
	end

	if m2debug then
		if m2debug.enables[tag] then
			_print(string.format("[ %s ] %s", tag, str))
		end

		m2debug.add(tag, str)
	end
end

local replaceScene = display.replaceScene
local afterDrawListener

function display.replaceScene(newScene, ...)
	m2debug.show(newScene)

	if afterDrawListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(afterDrawListener)

		afterDrawListener = nil
	end

	replaceScene(newScene, ...)
end

local pushScene = cc.Director.pushScene

function cc.Director.pushScene(d, newScene, ...)
	if m2debug.node then
		m2debug.node:removeSelf()

		m2debug.node = nil
	end

	m2debug.show(newScene)

	if afterDrawListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(afterDrawListener)

		afterDrawListener = nil
	end

	pushScene(d, newScene, ...)
end

local popScene = cc.Director.popScene

function cc.Director.popScene(d, ...)
	if m2debug.node then
		m2debug.node:removeSelf()

		m2debug.node = nil
	end

	afterDrawListener = cc.EventListenerCustom:create("director_after_draw", function()
		local dir = cc.Director:getInstance()
		local running = dir.getRunningScene(dir).s

		m2debug.show(running)
		dir.getEventDispatcher(dir):removeEventListener(afterDrawListener)

		afterDrawListener = nil
	end)

	d.getEventDispatcher(d):addEventListenerWithFixedPriority(afterDrawListener, 1)
	popScene(d, ...)
end

local node = display.newNode()
local screenNode = display.newNode():addTo(node)

node.screenNode = screenNode

local roleCnt = an.newLabel("", 18, 0.8, {
	sd = true,
	color = display.COLOR_RED
}):pos(0, 45):add2(screenNode)

cc.Director:getInstance():setNotificationNode(node)

local value
local m2debug2 = {
	allowTouch = true,
	catch = false,
	enables = {},
	showEnables = {},
	texts = {},
	cmNames = {},
	smNames = {},
	setting = {
		acLogin = true
	}
}

for k2, v3 in pairs(tags) do
	m2debug2.enables[k2] = true
end

local filter = cache.getDebug("filter")

if filter then
	for k3, v2 in pairs(filter) do
		m2debug2.enables[k3] = v2
	end
end

local setting2 = cache.getDebug("setting")

if setting2 then
	m2debug2.setting = setting2
end

local roleSpeed = cache.getDebug("roleSpeed")

if roleSpeed then
	m2debug2.roleSpeed = roleSpeed
end

for k, v in pairs(_G) do
	if type(v) == "number" then
		if string.find(k, "CM_") == 1 then
			m2debug2.cmNames[v] = k
		elseif string.find(k, "SM_") == 1 then
			m2debug2.smNames[v] = k
		end
	end
end

function m2debug2.add(tag, str)
	m2debug2.texts[#m2debug2.texts + 1] = {
		tag,
		str
	}

	if m2debug2.enables[tag] and m2debug2.scroll then
		m2debug2.addLog(tag, str)
	end
end

function tcall(self)
	local value2 = self[1]
	local value3, value4 = pcall(value2)

	if not value3 then
		roleCnt:setString("捕获错误:" .. value4)
	end

	if not value3 then
		return value4
	end
end

function m2debug2.show(scene)
	if not m2debug2.hideNode and scene then
		tcall({
			function()
				if not m2debug2.scroll then
					m2debug2.createContent()
				end
			end
		})
	end
end

m2debug2.setting.ip_history = m2debug2.setting.ip_history or {}

function m2debug2.createContent()
	local scroll = an.newScroll(50, 10, 600, 700, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(screenNode)

	m2debug2.scroll = scroll
end

function m2debug2:addLog(value2)
	return true
end

return m2debug2
