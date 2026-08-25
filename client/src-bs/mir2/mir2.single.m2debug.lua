local current = ...
local p2_print = print
local tags = {
	other = "其他",
	autoRat = "挂机",
	equip = "装备",
	net = "通讯",
	login = "登录",
	bag = "背包",
	error = "lua错误",
	res = "资源",
	assert = "断言",
	normal = "普通"
}
local shows = {
	fps = function (b)
		cc.Director:getInstance():setDisplayStats(b)
	end,
	["同屏人数"] = function (b)
		cc.Director:getInstance():getNotificationNode().screenNode:setVisible(b)
	end,
	ping值 = function (b)
		cc.Director:getInstance():getNotificationNode().pingNode:setVisible(b)
	end
}

function p2(tag, ...)
	p2_print("_debug_", tag or "normal", ...)
end

function d2(tag, value, desciption, nestin)
	dump("_debug_", tag or "normal", value, desciption, nestin)
end

function __G__TRACKBACK__(errorMessage)
	if LuaReportException then
		-- Nothing
	end

	p2("error", "----------------------------------------")
	p2("error", "LUA ERROR: " .. tostring(errorMessage) .. "\n")
	p2("error", debug.traceback("", 2))
	p2("error", "----------------------------------------")
end

if DEBUG > 0 then
	local _dumpTag = nil
	local _dump = dump

	function dump(mark, tag, value, desciption, nesting)
		if mark == "_debug_" then
			_dumpTag = tag or "normal"

			_dump(value, desciption, nesting)

			_dumpTag = nil
		else
			_dump(mark, tag, value, 1)
		end
	end

	_print = print

	local function tprint(mark, tag, ...)
		local str = nil

		if mark == "_debug_" then
			local params = {
				...
			}

			for i = 1, select("#", ...) do
				local v = select(i, ...)
				local valueType = type(v)

				if valueType == "boolean" then
					params[i] = v and "true" or "false"
				elseif valueType == "userdata" then
					params[i] = "userdata(" .. (v.__cname or tolua.type(v)) .. ")"
				elseif valueType ~= "string" and valueType ~= "number" then
					params[i] = valueType
				end
			end

			str = table.concat(params, "   ")
		else
			local params = {
				mark,
				tag,
				...
			}
			local arglen = select("#", ...) + 2

			if arglen == 2 and tag == nil then
				if mark == nil then
					arglen = 0
				else
					arglen = 1
				end
			end

			for i = 1, arglen do
				local v = params[i]
				local valueType = type(v)

				if valueType == "boolean" then
					params[i] = v and "true" or "false"
				elseif valueType == "userdata" then
					params[i] = "userdata(" .. (v.__cname or tolua.type(v)) .. ")"
				elseif valueType ~= "string" and valueType ~= "number" then
					params[i] = valueType
				end
			end

			str = table.concat(params, "   ")
			tag = _dumpTag or "other"
		end

		if m2debug then
			if m2debug.enables[tag] then
				_print(string.format("[ %s ] %s", tag, str))
			end

			m2debug.add(tag, str)
		end
	end

	if false then
		scheduler.performWithDelayGlobal(function ()
			tprint("---------- test print ----------")
			tprint(true, false)
			tprint(true)
			tprint(false)
			tprint(false, false, false)
			tprint(nil, false)
			tprint(nil, nil, nil)
			tprint(nil, nil, "arg")
			tprint(nil, "arg", "arg")
			tprint("string1", "string2", "string3", "string4", "string5")
			tprint("number", 1, 2, 3, 4, 5)
			tprint("node")
			tprint(display.newNode())
			tprint("_debug_", "other", "---------- test print2 ----------")
			tprint("_debug_", "other", true, false)
			tprint("_debug_", "other", true)
			tprint("_debug_", "other", false)
			tprint("_debug_", "other", false, false, false)
			tprint("_debug_", "other", nil, false)
			tprint("_debug_", "other", nil, nil, "arg")
			tprint("_debug_", "other", nil, "arg", "arg")
			tprint("_debug_", "other", "string1", "string2", "string3", "string4", "string5")
			tprint("_debug_", "other", "number", 1, 2, 3, 4, 5)
			tprint("_debug_", "other", "node")
			tprint("_debug_", "other", display.newNode())
		end, 1)
	end

	print = tprint
	local _replaceScene = display.replaceScene
	local afterDrawListener = nil

	function display.replaceScene(newScene, ...)
		m2debug.show(newScene)

		if afterDrawListener then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(afterDrawListener)

			afterDrawListener = nil
		end

		_replaceScene(newScene, ...)
	end

	local _pushScene = cc.Director.pushScene

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

		_pushScene(d, newScene, ...)
	end

	local _popScene = cc.Director.popScene

	function cc.Director.popScene(d, ...)
		if m2debug.node then
			m2debug.node:removeSelf()

			m2debug.node = nil
		end

		afterDrawListener = cc.EventListenerCustom:create("director_after_draw", function ()
			local dir = cc.Director:getInstance()
			local running = dir:getRunningScene().s

			m2debug.show(running)
			dir:getEventDispatcher():removeEventListener(afterDrawListener)

			afterDrawListener = nil
		end)

		d:getEventDispatcher():addEventListenerWithFixedPriority(afterDrawListener, 1)
		_popScene(d, ...)
	end

	local node = display.newNode()
	local screenNode = display.newNode():addTo(node)
	node.screenNode = screenNode
	local roleCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 185):add2(screenNode)
	local mapCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 165):add2(screenNode)
	local msgCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 145):add2(screenNode)
	local labelTexCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 125):add2(screenNode)
	local rsTexCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 105):add2(screenNode)
	local mir2TexCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 85):add2(screenNode)
	local m2sprCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 65):add2(screenNode)

	cc.Director:getInstance():setNotificationNode(node)
	scheduler.scheduleUpdateGlobal(function ()
		if main_scene and main_scene.ground and main_scene.ground.map then
			local roles = {}

			table.merge(roles, main_scene.ground.map.heros)
			table.merge(roles, main_scene.ground.map.mons)
			table.merge(roles, main_scene.ground.map.npcs)

			local allRoleCnt = table.nums(roles)
			local ignoreCnt = 0

			for k, v in pairs(roles) do
				if v.isIgnore then
					ignoreCnt = ignoreCnt + 1
				end
			end

			roleCnt:setString("同屏人数: " .. allRoleCnt - ignoreCnt .. " / " .. allRoleCnt .. " / " .. (main_scene.ground.map.current_frame_updatedRoles or 0))
			mapCnt:setString("map消息: " .. main_scene.ground.map.msgs.size())
		end

		mir2TexCnt:setString("传奇资源纹理数: " .. res.getMir2TexCount())
		m2sprCnt:setString("传奇资源精灵: " .. m2spr.debuginfo)
	end)

	node.pingNode = display.newNode():addTo(node)
	node.pingNode.label = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):addTo(node.pingNode):pos(0, 210)

	scheduler.scheduleGlobal(function ()
		if main_scene then
			net.sendPing()
			g_data.client:setLastTime("ping", true)
		end
	end, 5)
else
	function print()
	end

	function dump()
	end

	return
end

local debugNode = nil
local m2debug = {
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

for k, v in pairs(tags) do
	m2debug.enables[k] = true
end

local filter = cache.getDebug("filter")

if filter then
	for k, v in pairs(filter) do
		m2debug.enables[k] = v
	end
end

for k, v in pairs(shows) do
	m2debug.showEnables[k] = true
end

local showEnables = cache.getDebug("shows")

if showEnables then
	for k, v in pairs(showEnables) do
		m2debug.showEnables[k] = v
	end
end

for k, v in pairs(shows) do
	shows[k](m2debug.showEnables[k])
end

local setting = cache.getDebug("setting")

if setting then
	m2debug.setting = setting
end

local roleSpeed = cache.getDebug("roleSpeed")

if roleSpeed then
	m2debug.roleSpeed = roleSpeed
end

for k, v in pairs(_G) do
	if type(v) == "number" then
		if string.find(k, "CM_") == 1 then
			m2debug.cmNames[v] = k
		elseif string.find(k, "SM_") == 1 then
			m2debug.smNames[v] = k
		end
	end
end

function m2debug.add(tag, str)
	m2debug.texts[#m2debug.texts + 1] = {
		tag,
		str
	}

	if m2debug.enables[tag] and m2debug.node then
		m2debug.node:addLog(tag, str)
	end
end

function m2debug.show(scene)
	if not m2debug.hideNode then
		m2debug.node = debugNode.new():add2(scene, an.z.debug)
	end
end

debugNode = class("debugNode", function ()
	return display.newNode()
end)

table.merge(debugNode, {
	btn,
	btns,
	beganPos,
	beganTouchPos,
	hasMove,
	lock,
	content,
	catchNode
})

function debugNode:ctor()
	self.btn = res.get2("pic/console/iconbg8.png")

	self.btn:pos(self.btn:centerPos()):add2(self, 1):setCascadeOpacityEnabled(true)
	res.get2("pic/debug/icon.png"):pos(self.btn:centerPos()):add2(self.btn)
	self:setCascadeOpacityEnabled(true)
	self:size(self.btn:getw(), self.btn:geth()):anchor(0.5, 0.5):pos(self:getw() / 2, display.height - self:geth() / 2):opacity(0):runs({
		cc.FadeIn:create(1),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function ()
			self:opacity(128)
		end)
	})
	self.btn:setTouchEnabled(true)
	self.btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if self.lock then
			return
		end

		if event.name == "began" then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(event.x, event.y)
			self.hasMove = false

			self:opacity(255)
			self:scale(1)
			self:stopAllActions()
		elseif event.name == "moved" then
			if self.hasMove or math.abs(self.beganTouchPos.x - event.x) > 10 or math.abs(self.beganTouchPos.y - event.y) > 10 then
				self.hasMove = true
				local x = event.x - self.beganTouchPos.x + self.beganPos.x
				local y = event.y - self.beganTouchPos.y + self.beganPos.y

				if x < 0 then
					x = 0
				end

				if display.width < x then
					x = display.width or x
				end

				if y < 0 then
					y = 0
				end

				if display.height < y then
					y = display.height or y
				end

				self:pos(x, y)
			end
		elseif event.name == "ended" then
			local function newx(x)
				if x < self:getw() / 2 then
					x = self:getw() / 2 or x
				end

				if x > display.width - self:getw() / 2 then
					x = display.width - self:getw() / 2 or x
				end

				return x
			end

			local function newy(y)
				if y < self:geth() / 2 then
					y = self:geth() / 2 or y
				end

				if y > display.height - self:geth() / 2 then
					y = display.height - self:geth() / 2 or y
				end

				return y
			end

			local function bothXY(x, y)
				if y < self:geth() then
					x = newx(x)
					y = self:geth() / 2
				elseif y > display.height - self:geth() then
					x = newx(x)
					y = display.height - self:geth() / 2
				elseif display.cx < x then
					x = display.width - self:getw() / 2
					y = newy(y)
				else
					x = self:getw() / 2
					y = newy(y)
				end

				return x, y
			end

			local function goto(x, y)
				if self.content then
					self:moveTo(0.25, x, y)
				else
					self:runs({
						cc.MoveTo:create(0.25, cc.p(x, y)),
						cc.DelayTime:create(3),
						cc.CallFunc:create(function ()
							self:opacity(128)
						end)
					})
				end
			end

			if not self.hasMove then
				self.lock = true

				self.btn:runs({
					cc.ScaleTo:create(0.1, 0.01),
					cc.ScaleTo:create(0.1, 1),
					cc.CallFunc:create(function ()
						self.lock = nil

						if self.content then
							self.content:removeSelf()

							self.content = nil

							goto(bothXY(self:getPosition()))
						else
							self:createContent()
						end
					end)
				})
			else
				local x = event.x - self.beganTouchPos.x + self.beganPos.x
				local y = event.y - self.beganTouchPos.y + self.beganPos.y

				if self.content then
					y = newy(y)
					x = newx(x)
				else
					x, y = bothXY(x, y)
				end

				goto(x, y)
			end
		end

		return true
	end)
end

function debugNode:createContentBase(type)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():anchor(0, 1):pos(self.btn:getw() / 2 + 5, self.btn:geth() / 2 - 5):size(480, 320):add2(self)
	self.content.type = type

	display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(self.content:getContentSize()):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)
end

function debugNode:createContent(hasInput)
	self:createContentBase("main")

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	self.content.beginpos = 1
	self.content.scroll = scroll
	local loadFront = nil

	scroll:enableTouch(m2debug.allowTouch)
	scroll:setListenner(function (event)
		local x, y = scroll:getScrollOffset()

		if event.name == "moved" then
			if y + scroll.labelM.wordSize.height > scroll:getScrollSize().height - scroll:geth() then
				self:hideNewMark()
			end

			if y < 0 and not loadFront and self.content.beginpos > 1 then
				loadFront = true
			end
		elseif event.name == "ended" and loadFront then
			local source = {}

			for i = self.content.beginpos - 1, 1, -1 do
				local v = m2debug.texts[i]

				if m2debug.enables[v[1]] then
					self.content.beginpos = i

					table.insert(source, 1, v)

					if #source >= 20 then
						break
					end
				end
			end

			if #source > 0 then
				local labelM = an.newLabelM(scroll:getw(), scroll.labelM.fontSize, 0)

				for i, v in ipairs(source) do
					labelM:nextLine():addLabel("[ " .. v[1] .. " ] ", self:getColor(v[1])):addLabel(v[2])
				end

				display.newColorLayer(cc.c4b(255, 255, 0, 255)):size(labelM:getw(), 1):add2(labelM)
				scroll.labelM:insertNodeToFront(labelM, #labelM.lines)
				scroll:setScrollOffset(0, y + labelM:geth() - labelM.wordSize.height / 2)
			end

			loadFront = nil
		end
	end)

	local source = {}

	for i = #m2debug.texts, 1, -1 do
		local v = m2debug.texts[i]

		if m2debug.enables[v[1]] then
			self.content.beginpos = i

			table.insert(source, 1, v)

			if #source >= 20 then
				break
			end
		end
	end

	for i, v in ipairs(source) do
		self:addLog(v[1], v[2])
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		local folder = os.date("%Y-%m-%d")
		local key = os.date("%H-%M-%S") .. ".txt"
		local value = {}

		for i, v in ipairs(m2debug.texts) do
			value[#value + 1] = string.format("[%s]  %s", v[1], v[2])
		end

		cache.saveDebugLog(folder, key, value)
		self:createContentForTips("已保存到[" .. folder .. "/" .. key .. "]")
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"保存",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, self.content:geth() - 50)

	if hasInput then
		local function executeLua(text)
			local f = loadstring(text)

			if f then
				f()
			else
				print("lua格式有误.")
			end
		end

		local input = nil
		local mac_use_source_keyboard = true

		if (device.platform == "mac" or device.platform == "windows") and mac_use_source_keyboard then
			input = cc.ui.UIInput.new({
				UIInputType = 1,
				size = cc.size(self.content:getw(), 40),
				image = display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")),
				listener = function (type)
					if type == "changed" then
						local text = input:getText()

						if string.byte(string.reverse(text)) == string.byte("\\") then
							executeLua(string.sub(text, 1, #text - 1))
							input:setText("")
						end
					else
						executeLua(input:getText())
						input:setText("")
					end
				end
			}):anchor(0, 1):opacity(0):fadeIn(0.1):pos(0, 24):moveTo(0.1, 0, 4):add2(self.content)
		else
			input = an.newInput(0, 0, self.content:getw(), 40, 255, {
				label = {
					"",
					22,
					0
				},
				bg = {
					h = 40,
					tex = res.gettex2("pic/scale/scale2.png"),
					offset = {
						-10,
						0
					}
				},
				return_call = function ()
					executeLua(input:getText())
					input:setText("")
				end
			}):anchor(0, 1):opacity(0):fadeIn(0.1):pos(10, 24):moveTo(0.1, 10, 4):add2(self.content)
		end

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(input:getContentSize()):add2(input, -1)
	end

	local posx = 0

	local function add(text, func)
		local w = 30
		local btn = nil
		btn = an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
			func(btn)
		end, {
			pressBig = true,
			scale9 = cc.size(string.utf8len(text) * w, 40),
			label = {
				text,
				18,
				1,
				{
					color = cc.c3b(255, 255, 0)
				}
			}
		}):add2(self.content, -1):anchor(0, 0):pos(28 + posx, self.content:geth() - 4)

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(btn:getContentSize()):add2(btn, -1)

		posx = posx + btn:getw() + 2
	end

	add(m2debug.allowTouch and "可触摸" or "不可触摸", function (btn)
		m2debug.allowTouch = not m2debug.allowTouch

		if m2debug.allowTouch then
			btn.label:setText("可触摸")
		else
			btn.label:setText("不可触摸")
		end

		scroll:enableTouch(m2debug.allowTouch)
	end)
	add("清空", function ()
		scroll.labelM:clear()
	end)
	add("过滤", function ()
		self:createContentForFilter()
	end)
	add("lua", function ()
		self:createContentForLua()
	end)
	add("设置", function ()
		self:createContentForSetting()
	end)
	add("GM", function ()
		self:createContentForGMCmd()
	end)
end

function debugNode:createContentForFilter()
	self:createContentBase()
	self.content:setNodeEventEnabled(true)

	function self.content.onCleanup()
		cache.saveDebug("filter", m2debug.enables)
	end

	local cnt = 0

	local function add(key, text)
		local col = cnt % 3
		local line = math.modf(cnt / 3)
		local pos = cc.p(20 + col * 160, self.content:geth() - 40 - line * 60)
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			m2debug.enables[key] = b
		end, {
			easy = true,
			default = m2debug.enables[key],
			label = {
				text .. "[" .. key .. "]",
				20,
				1,
				{
					color = self:getColor(key)
				}
			}
		}):anchor(0, 0.5):pos(pos.x, pos.y):add2(self.content)
		cnt = cnt + 1
	end

	for k, v in pairs(tags) do
		add(k, v)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLua()
	self:createContentBase()

	local config = {
		{
			"执行lua语句..",
			function ()
				self:createContent(true)
			end
		},
		{
			"查询全局变量值..",
			function ()
				self:createContentForLuaQueryVar()
			end
		},
		{
			"查看常量值..",
			function ()
				self:createContentForLuaQueryConst()
			end
		},
		{
			"当前版本:" .. (MIR2_VERSION or "")
		}
	}

	for i, v in ipairs(config) do
		an.newLabel(v[1], 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):pos(20, self.content:geth() - 80 - (i - 1) * 60):add2(self.content):enableClick(v[2], {
			ani = true
		})
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLuaQueryVar()
	self:createContentBase()
	an.newLabel("变量名: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(20, self.content:geth() - 50):add2(self.content)

	local input = an.newInput(130, self.content:geth() - 52, 200, 32, 15, {
		label = {
			"g_data",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		}
	}):anchor(0, 0.5):add2(self.content)
	local config = {
		"def",
		"g_data",
		"game",
		"res",
		"display",
		"device"
	}

	for i, v in ipairs(config) do
		local col = math.modf((i - 1) / 3)
		local line = (i - 1) % 3

		an.newLabel(v, 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0.5, 0.5):pos(60 + line * 170, self.content:geth() - 120 - col * 50):add2(self.content):enableClick(function ()
			input:setString(v)
		end, {
			ani = true,
			size = cc.size(120, 40)
		})
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForLuaQueryVarDetail(input:getText())
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 150, 30)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForLua()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLuaQueryVarDetail(varText, parent)
	self:createContentBase()

	parent = parent or {}
	parent[#parent + 1] = varText

	local function goback()
		if #parent == 1 then
			self:createContentForLuaQueryVar()
		else
			parent[#parent] = nil
			local lastVar = parent[#parent]
			parent[#parent] = nil

			self:createContentForLuaQueryVarDetail(lastVar, clone(parent))
		end
	end

	local fullVarText = ""

	for i, v in ipairs(parent) do
		if i == 1 then
			fullVarText = v
		elseif type(v) == "string" then
			fullVarText = fullVarText .. "[\"" .. v .. "\"]"
		elseif type(v) == "number" then
			fullVarText = fullVarText .. "[" .. v .. "]"
		else
			fullVarText = fullVarText .. ":get(\"" .. v[1] .. "\")"
		end
	end

	local str = "local var = " .. fullVarText .. " return var"
	local f = loadstring(str)

	if not f then
		self:createContentForTips("查询失败. [" .. str .. "]", goback)

		return
	end

	print(fullVarText)

	local var = f()

	if type(var) ~= "table" then
		self:createContentForTips("变量[" .. varText .. "]并不是table类型", goback)

		return
	end

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			22,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	scroll.labelM:nextLine():addLabel("变量名: " .. fullVarText, cc.c3b(255, 0, 255)):nextLine()

	local showVar = var
	local keys = table.keys(showVar)

	table.sort(keys, function (a, b)
		return tostring(a) < tostring(b)
	end)

	for i, k in pairs(keys) do
		local v = showVar[k]

		if type(v) == "table" then
			scroll.labelM:nextLine():addLabel(type(v) .. "  ", display.COLOR_GREEN):addLabel(k .. "  ", cc.c3b(0, 255, 255)):addLabel("查看详情[" .. table.nums(v) .. "]", cc.c3b(255, 255, 0), nil, nil, {
				ani = true,
				callback = function ()
					self:createContentForLuaQueryVarDetail(k, clone(parent))
				end
			})
		elseif type(v) == "number" or type(v) == "string" then
			scroll.labelM:nextLine():addLabel(type(v) .. "  ", display.COLOR_GREEN):addLabel(k .. "  ", cc.c3b(0, 255, 255)):addLabel(v)
		end
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), goback, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForLuaQueryConst()
	self:createContentBase()

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	local config = {
		{
			"原始版本",
			MIR2_VERSION_BASE
		},
		{
			"现在版本",
			MIR2_VERSION
		},
		{
			"登录服务器ip",
			def.ip
		},
		{
			"区服id",
			def.areaID
		},
		{
			"更新服务器ip",
			import("...upt.def", current).httpRoot
		},
		{
			"中央服地址",
			def.loginCenterIP
		},
		{
			"chatHttpRoot",
			def.chatHttpRoot
		},
		{
			"useIGW",
			def.useIGW
		},
		{
			"gameType",
			def.gameType
		},
		{
			"屏幕宽高",
			display.width .. " * " .. display.height
		},
		{
			"版本类型",
			def.gameVersionType
		},
		{
			"客户端版本号",
			def.MIR_VERSION_NUMBER
		}
	}

	for i, v in ipairs(config) do
		scroll.labelM:nextLine():addLabel(v[1] .. ": ", display.COLOR_GREEN):addLabel(v[2])
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForLua()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForAdaptSpeed()
	self:createContentBase()

	if not m2debug.roleSpeed then
		m2debug.roleSpeed = def.role.speed
	else
		def.role.speed = m2debug.roleSpeed
	end

	config = {
		{
			"一般动作",
			"normal"
		},
		{
			"加速",
			"fast"
		},
		{
			"冲撞失败",
			"rushKung"
		},
		{
			"野蛮冲撞",
			"rush"
		},
		{
			"基础释法间隔",
			"spell"
		},
		{
			"基础攻击间隔",
			"attack"
		}
	}
	local preInput = nil
	local adapt2input = {}
	local h = 0

	for k, v in pairs(config) do
		h = h + 45
		local input = nil

		local function stopCb()
			print(v[1], num)

			if not tolua.isnull(input) then
				local num = tonumber(input:getString())
				def.role.speed[v[2]] = num

				cache.saveDebug("roleSpeed", def.role.speed)
				print(v[1], num)
			end
		end

		input = an.newInput(200, self.content:geth() - h, 170, 32, 15, {
			label = {
				"" .. def.role.speed[v[2]],
				22,
				1
			},
			bg = {
				h = 40,
				tex = res.gettex2("pic/scale/scale2.png"),
				offset = {
					-10,
					0
				}
			},
			start_call = function ()
				if preInput and preInput ~= input then
					preInput:stopInput()
				end

				preInput = input
			end,
			stop_call = stopCb
		}):anchor(0, 0.5):add2(self.content)

		function input.onCleanup()
			stopCb()
			input:stopInput()
		end

		local lb = an.newLabel(v[1] .. ":", 22, 0, {
			color = cc.c3b(255, 255, 255)
		}):pos(10, self.content:geth() - h - 10):add2(self.content)
	end
end

function debugNode:createContentForTest()
	local function setAssetServerUrl(url)
		local uptScene = require("upt.scene")
		SKIP_UPT = false
		s = uptScene.new(function ()
			s:setTitle("请重启游戏")
		end)

		s:rmdir(device.writablePath .. "cache/")
		s:rmdir(s.storagePath .. "res/")
		s:rmdir(s.storagePath .. "rs/")
		s:rmdir(s.storagePath .. "upt/")
		os.remove(s.storagePath .. "project.manifest")
		os.remove(s.storagePath .. "version.manifest")
		display.replaceScene(s)
		s:saveRemoteAddress(url)
	end

	local config = {
		{
			"获取技能书",
			function ()
				local keys = def.magic.getMagicIds(g_data.player.job, false)

				for k, v in pairs(keys) do
					net.send({
						CM_SAY
					}, {
						"@doresou " .. def.magic.getMagicConfigByUid(v).name
					})
				end
			end
		},
		{
			"升级技能",
			function (edit)
				local level = tonumber(edit:getString()) or 3

				if level then
					local keys = def.magic.getMagicIds(g_data.player.job, false)
					local playername = main_scene.ground.player.info:getName()

					for k, v in pairs(keys) do
						local cmd = string.format("@upuserskill %s %s %d", playername, def.magic.getMagicConfigByUid(v).name, level)

						net.send({
							CM_SAY
						}, {
							cmd
						})
					end
				end
			end,
			true
		},
		{
			"道士消耗品",
			function ()
				local f = {
					"超级护身符",
					"超级灰色药粉",
					"超级黄色药粉"
				}

				for k, v in pairs(f) do
					net.send({
						CM_SAY
					}, {
						"@doresou " .. v
					})
				end
			end
		},
		{
			"使用测试版热更服务器",
			function ()
				setAssetServerUrl("http://116.211.22.22:8989/")
			end
		},
		{
			"使用运维版热更服务器",
			function ()
				setAssetServerUrl("http://mir2ys.webpatch.sdg-china.com/")
			end
		},
		{
			"刷假人",
			function ()
				local util = require("mir2.scenes.main.common.helper.util")

				util.stressTest()
			end
		},
		{
			"刷假人,重复",
			function (edit)
				local num = tonumber(edit:getString()) or 3
				local util = require("mir2.scenes.main.common.helper.util")
				local ret = nil

				function c()
					if num > 0 then
						ret = util.stressTest(false, true)
						num = num - 1

						scheduler.performWithDelayGlobal(c, 1)
						scheduler.performWithDelayGlobal(ret, 0.5)
					end
				end

				c()
			end,
			true
		},
		{
			"刷假人随机衣服",
			function ()
				local util = require("mir2.scenes.main.common.helper.util")

				util.stressTest(false, true)
			end
		},
		{
			"刷假人随机衣服技能",
			function ()
				local util = require("mir2.scenes.main.common.helper.util")

				util.stressTest(true, true)
			end
		}
	}

	self:createContentForSetting(config)
end

function debugNode:createContentForSetting(cfg)
	self:createContentBase()

	if not cfg then
		local config = {
			{
				"添加测试服务器",
				function ()
					self:createContentForSettingServer()
				end
			},
			{
				"设置界面调试信息",
				function ()
					self:createContentForSettingShows()
				end
			},
			{
				"隐藏工具图标",
				function ()
					if m2debug.node then
						m2debug.node:removeSelf()

						m2debug.node = nil
					end

					m2debug.hideNode = true
				end
			},
			{
				"测试lua error",
				function ()
					local testLuaError = nil

					testLuaError:func()
				end
			},
			{
				"测试崩溃",
				function ()
					ycFunction:testCrash()
				end
			},
			{
				"清理游戏数据",
				function ()
					local uptScene = require("upt.scene")
					s = uptScene.new(function ()
						s:setTitle("请重启游戏")
					end, false)

					s:rmdir(device.writablePath .. "cache/")
					s:rmdir(s.storagePath .. "res/")
					s:rmdir(s.storagePath .. "rs/")
					s:rmdir(s.storagePath .. "upt/")
					os.remove(s.storagePath .. "project.manifest")
					os.remove(s.storagePath .. "version.manifest")

					SKIP_UPT = true

					display.replaceScene(s)
					s:setTitle("请重启游戏")
				end
			},
			{
				"执行更新",
				function ()
					local s = nil
					local uptScene = require("upt.scene")
					s = uptScene.new(function ()
						s:setTitle("请重启游戏")
					end, true)

					display.replaceScene(s)
				end
			},
			{
				"播放CG动画",
				function ()
					local helper = require("mir2.scenes.main.common.helper.helper")

					def.magic.getConfig("skillMagic")
					helper.call("CG")
				end
			},
			{
				"调整动作速度",
				function ()
					self:createContentForAdaptSpeed()
				end
			},
			{
				"清理CG初次标记",
				function ()
					cache.cgClear()
					self.content:removeSelf()

					self.content = nil
				end
			},
			{
				m2debug.setting.manualServer and "切换为自动选服" or "切换为手动选服",
				function ()
					m2debug.setting.manualServer = not m2debug.setting.manualServer

					cache.saveDebug("setting", m2debug.setting)
					self:createContentForSetting()
				end
			},
			{
				"辅助测试",
				function ()
					self:createContentForTest()
				end
			},
			{
				"测试例",
				function ()
					local cases = require("test.testm2spr")()

					self:createContentForSetting(cases)
				end
			},
			{
				m2debug.setting.acLogin and "切换为G+登录" or "切换为账号登录",
				function ()
					m2debug.setting.acLogin = not m2debug.setting.acLogin

					cache.saveDebug("setting", m2debug.setting)
					self:createContentForSetting()
				end
			}
		}
	end

	local pos = self.content:geth() - 40
	local left = 20
	local maxWidth = 0

	for i, v in ipairs(config) do
		local edit = nil
		local lb = an.newLabel(v[1], 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):pos(left, pos):add2(self.content):enableClick(function ()
			v[2](edit)
		end, {
			ani = true
		})

		if v[3] then
			edit = an.newInput(0, 0, 40, 30, 255, {
				donotClip = true,
				bg = {
					h = 35,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						0
					}
				}
			}):addTo(lb):pos(lb:getw() + 30, 28):anchor(0, 1)
		end

		maxWidth = math.max(lb:getw(), maxWidth)
		pos = pos - 45

		if pos < 0 then
			left = left + maxWidth + 20
			maxWidth = 0
			pos = self.content:geth() - 40
		end
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForSettingShows()
	self:createContentBase()
	self.content:setNodeEventEnabled(true)

	function self.content.onCleanup()
		cache.saveDebug("shows", m2debug.showEnables)
	end

	local cnt = 0

	local function add(key, func)
		local col = cnt % 3
		local line = math.modf(cnt / 3)
		local pos = cc.p(20 + col * 160, self.content:geth() - 40 - line * 60)
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			m2debug.showEnables[key] = b

			shows[key](b)
		end, {
			easy = true,
			default = m2debug.showEnables[key],
			label = {
				key,
				20,
				1,
				{
					color = self:getColor(key)
				}
			}
		}):anchor(0, 0.5):pos(pos.x, pos.y):add2(self.content)
		cnt = cnt + 1
	end

	for k, v in pairs(shows) do
		add(k)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForSettingServer()
	self:createContentBase()
	an.newLabel("服务器IP: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(20, self.content:geth() - 50):add2(self.content)

	local input, areaInput = nil
	input = an.newInput(130, self.content:geth() - 52, 170, 32, 22, {
		label = {
			"",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		},
		start_call = function ()
		end
	}):anchor(0, 0.5):add2(self.content)

	an.newLabel("端口: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(300, self.content:geth() - 50):add2(self.content)

	areaInput = an.newInput(390, self.content:geth() - 52, 90, 32, 6, {
		label = {
			"",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		},
		start_call = function ()
			input:stopInput()
		end
	}):anchor(0, 0.5):add2(self.content)

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		local function tip(text)
			self:createContentForTips(text, function ()
				self:createContentForSetting()
			end)
		end

		input:stopInput()
		areaInput:stopInput()

		local ip = input:getText()
		local port = areaInput:getText()
		port = port == "" and 80 or tonumber(port)

		local function checkHistory(key, ip, port)
			if not m2debug.setting[key] then
				m2debug.setting[key] = {}
			end

			m2debug.setting[key][ip] = port
			m2debug.setting.ip_history.curIP = ip
		end

		checkHistory("ip_history", ip, port)
		cache.saveDebug("setting", m2debug.setting)
		game.gotoscene("login")
		self:createContentForSettingServer()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 150, 30)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForSetting()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)

	local pos = 30
	m2debug.setting.ip_history = m2debug.setting.ip_history or {
		[def.loginCenterIP] = def.loginCenterPort
	}

	for k, v in pairs(m2debug.setting.ip_history or {}) do
		if k ~= "curIP" then
			local t = k
			local p = v
			local clr = cc.c3b(255, 255, 0)

			if k == m2debug.setting.ip_history.curIP then
				clr = cc.c3b(255, 0, 0)
			end

			an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
				def.setLoginCenter(t, p)

				m2debug.setting.ip_history.curIP = t

				cache.saveDebug("setting", m2debug.setting)
				game.gotoscene("login")
			end, {
				pressBig = true,
				scale9 = cc.size(180, 40),
				label = {
					k .. ":" .. p,
					18,
					1,
					{
						color = clr
					}
				}
			}):add2(self.content):pos(120, pos)

			pos = pos + 40
		end
	end
end

m2debug.setting.ip_history = m2debug.setting.ip_history or {}
m2debug.setting.ip_history["center.peibanmir2.com"] = 8088
m2debug.setting.ip_history["172.18.10.161"] = 80

if m2debug.setting.ip_history and m2debug.setting.ip_history and m2debug.setting.ip_history.curIP then
	m2debug.setting.ip_history[def.loginCenterIP] = def.loginCenterPort

	def.setLoginCenter(m2debug.setting.ip_history.curIP, m2debug.setting.ip_history[m2debug.setting.ip_history.curIP])
end

function debugNode:createContentForTips(text, func)
	self:createContentBase()
	an.newLabel(text, 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0.5, 0.5):pos(self.content:centerPos()):add2(self.content)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), func or function ()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createContentForGMCmd()
	self:createContentBase()

	local scroll = self:createCmdList("common")

	an.newLabel("命令类别", 18, 1, {
		color = display.COLOR_RED
	}):addTo(scroll):pos(10, scroll.h):anchor(0, 1)

	local h = scroll.h - scroll.space
	local cnt = 1

	for i, v in pairs(def.gmCmd.sort) do
		an.newLabel(i, 18, 1):addTo(scroll):pos((cnt + 2) % 3 * 150 + 10, h):anchor(0, 1):enableClick(function ()
			self:createCmdList(i)
		end)

		cnt = cnt + 1
		h = h - (cnt % 3 == 1 and scroll.space or 0)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)
end

function debugNode:createCmdList(key)
	self:createContentBase()

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	scroll.h = scroll:geth() - 5
	scroll.space = 30
	local data, goback = nil

	if key == "common" then
		data = def.gmCmd.common

		function goback()
			self:createContentForGMCmd()
		end

		an.newLabel("常用命令", 18, 1, {
			color = display.COLOR_RED
		}):addTo(scroll):pos(10, scroll.h):anchor(0, 1)

		scroll.h = scroll.h - scroll.space
	else
		for i, v in pairs(def.gmCmd.sort) do
			if i == key then
				data = v

				break
			end
		end

		function goback()
			self:createCmdList(key)
		end

		an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
			self:createContentForGMCmd()
		end, {
			pressBig = true,
			scale9 = cc.size(80, 40),
			label = {
				"返回",
				18,
				1,
				{
					color = cc.c3b(255, 255, 0)
				}
			}
		}):add2(scroll):pos(scroll:getw() - 40, 24)
	end

	local cnt = 1

	for i, v in ipairs(data) do
		local label = an.newLabel(v[1], 18, 1):addTo(scroll):pos((cnt + 2) % 3 * 155, scroll.h):anchor(0, 1):enableClick(function ()
			self:createCmd(v, goback)
		end)
		cnt = cnt + 1
		scroll.h = scroll.h - ((cnt % 3 == 1 or i == #data) and scroll.space or 0)
	end

	return scroll
end

function debugNode:createCmd(data, func)
	self:createContentBase()
	self.content:setNodeEventEnabled(true)

	function self.content.onCleanup()
		m2debug.catchNode = nil
	end

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	dump(data)

	local w = 10
	local h = scroll:geth() - 10
	local sw = 150
	local sh = 40

	an.newLabelM(self.content:getw() - 20, 20, 1):addTo(scroll):pos(w, h):anchor(0, 1):nextLine():addLabel("命令描述: " .. data[2])

	h = h - sh
	local edits = {}
	local needCatch = false
	local mapEdit = nil

	if data[4] ~= "" then
		local t = loadstring("return " .. data[4])

		for i, v in ipairs(t()) do
			local opt, edit = nil
			opt = an.newLabel(v, 20, 1):addTo(scroll):pos(10, h):anchor(0, 1)
			edit = an.newInput(0, 0, 120, 35, 255, {
				donotClip = true,
				bg = {
					h = 35,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						0
					}
				}
			}):addTo(scroll):pos(30 + opt:getw(), h):anchor(0, 1)
			edits[#edits + 1] = edit

			if string.find(v, "角色名") or string.find(v, "怪物名") then
				needCatch = true

				an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
					print("catch name ", m2debug.catchName)
					edit:setText(m2debug.catchName and m2debug.catchName or "")
				end, {
					pressBig = true,
					scale9 = cc.size(80, 40),
					label = {
						"获取名字",
						18,
						1,
						{
							color = cc.c3b(255, 255, 0)
						}
					}
				}):add2(scroll):pos(edit:getPositionX() + edit:getw() + 30, h):anchor(0, 1)
			end

			if string.find(v, "地图ID") then
				mapEdit = edit
			end

			h = h - sh
		end
	end

	local options = {}
	local selected = nil

	if data[5] ~= "" then
		local t = loadstring("return " .. data[5])

		for i, v in ipairs(t()) do
			local opt = nil
			opt = an.newBtn(res.gettex2("pic/common/toggle10.png"), function (btn)
				for _, tog in ipairs(options) do
					if tog == btn then
						tog:select()

						selected = v
					else
						tog:unselect()
					end
				end
			end, {
				manual = true,
				label = {
					v,
					20,
					1,
					{
						color = def.colors.btn20,
						sc = def.colors.btn20s
					}
				},
				labelOffset = {
					x = 50,
					y = 0
				},
				select = {
					res.gettex2("pic/common/toggle11.png")
				}
			}):addTo(scroll):anchor(0, 1)
			options[#options + 1] = opt

			opt:pos((#options + 2) % 3 * sw + w, h)

			if i == 1 then
				opt:select()

				selected = v
			end
		end
	end

	if mapEdit then
		local mapCfg = {
			["0"] = "比奇省",
			["1"] = "沃玛森林",
			["2"] = "毒蛇山谷",
			["3"] = "盟重省",
			["11"] = "白日门",
			["6"] = "魔龙城",
			["5"] = "苍月岛",
			sldg = "边界城",
			["4"] = "封魔谷"
		}
		local cnt = 1

		for i, v in pairs(mapCfg) do
			an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
				mapEdit:setText(i)
			end, {
				pressBig = true,
				scale9 = cc.size(80, 40),
				label = {
					v,
					20,
					1,
					{
						color = cc.c3b(255, 255, 0)
					}
				}
			}):add2(scroll):pos((cnt - (cnt > 5 and 6 or 1)) * 90, h):anchor(0, 1)

			cnt = cnt + 1

			if cnt == 6 then
				h = h - sh
			end
		end
	end

	if needCatch then
		self.catchNode = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			m2debug.catch = b
		end, {
			easy = true,
			default = m2debug.catch,
			label = {
				"允许获取",
				20,
				1
			}
		}):addTo(scroll):pos(10, 24):anchor(0, 0.5)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		local str = "@" .. data[3]

		for i, v in ipairs(edits) do
			if v:getText() ~= "" then
				str = str .. " " .. v:getText()
			end
		end

		if selected then
			str = str .. " " .. selected
		end

		local function encodeMsg(str)
			local ret = {}

			if str then
				str = utf8strs(str)

				for i, v in ipairs(str) do
					if string.len(v) >= 4 then
						local t = crypto.encodeBase64(v)
						t = string.sub(t, 1, string.len(t) - 1)
						t = string.gsub(t, "/", "!")
						ret[i] = "{@ej" .. t .. "}"
					else
						ret[i] = v
					end
				end
			end

			return table.concat(ret)
		end

		net.send({
			CM_SAY
		}, {
			encodeMsg(str)
		})
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(scroll):pos(scroll:getw() - 150, 24)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), func, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(scroll):pos(scroll:getw() - 40, 24)
end

function debugNode:getColor(tag)
	if tag == "error" or tag == "assert" then
		return display.COLOR_RED
	end

	return display.COLOR_GREEN
end

function debugNode:addLog(tag, str)
	if not self.content or self.content.type ~= "main" then
		return
	end

	local scroll = self.content.scroll
	local x, y = scroll:getScrollOffset()
	local isInEnd = scroll:getScrollSize().height < y + scroll:geth() + scroll.labelM.wordSize.height

	scroll.labelM:nextLine():addLabel("[ " .. tag .. " ] ", self:getColor(tag)):addLabel(str)

	if isInEnd then
		scroll:setScrollOffset(0, scroll:getScrollSize().height - scroll:geth())
	else
		self:showNewMark()
	end

	return true
end

function debugNode:showNewMark()
	if not self.content.newMark then
		self.content.newMark = res.get2("pic/common/msgNew.png"):add2(self.content, 1):run(cc.RepeatForever:create(transition.sequence({
			cc.ScaleTo:create(0.5, 0.7),
			cc.ScaleTo:create(0.5, 1)
		}))):enableClick(function ()
			self.content.newMark:hide()
			self.content.scroll:setScrollOffset(0, self.content.scroll:getScrollSize().height - self.content.scroll:geth())
		end)
	end

	self.content.newMark:show():pos(self.content:getw() - 20, 24)
end

function debugNode:hideNewMark()
	if self.content.newMark then
		self.content.newMark:hide()
	end
end

return m2debug
