local common = import("..common.common")
local hotKeySetting = class("hotKeySetting", function ()
	return display.newNode()
end)

table.merge(hotKeySetting, {})

function hotKeySetting:ctor()
	self.cellList = {}
	self.pressedKey = {}

	self:initUI()
	self:registerKeyboardEvent()
	self:setNodeEventEnabled(true)
end

function hotKeySetting:onExit()
	print("·hotKeySetting onExit")

	g_data.hotKey.isSettingKey = false

	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.mouseListener)

		self.listener = nil
	end
end

function hotKeySetting:initUI()
	local bg = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self):anchor(0, 0)
	local scroll = an.newScroll(0, 0, bg:getw(), bg:geth(), {
		labelM = {
			23,
			1
		}
	}):anchor(0, 0):add2(self)

	scroll:setName("hotKeySetting_ScrollView")

	local item_w = 220
	local item_h = 40

	local function getSrollH()
		local rows = math.ceil((#g_data.hotKey:getHotKeySet() - 1) / 2)
		local h = rows * item_h + 30

		if h < bg:geth() then
			h = bg:geth()
		end

		return h
	end

	scroll:setScrollSize(scroll:getw(), getSrollH())

	local beginX = 20
	local beginY = scroll:getScrollSize().height - item_h - 15

	local function addSubItem(row, col, info)
		if not info then
			return
		end

		local keyInfos = g_data.hotKey:getInfo(info.id)
		local node = display.newNode():addTo(scroll):size(item_w, item_h):anchor(0, 0):pos(beginX + (col - 1) * item_w, beginY - (row - 1) * item_h)
		local lbl_title = an.newLabel(info.title, 23, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0, 0.5):pos(0, item_h / 2):add2(node)
		local key_spr_bg = display.newScale9Sprite("pic/scale/edit0.png", 0, 0, cc.size(100, 30)):anchor(0, 0.5):pos(110, item_h / 2):add2(node)
		local key_label = an.newLabel(keyInfos.keyName, 21, 1, {
			color = cc.c3b(255, 255, 255)
		}):anchor(0.5, 0.5):pos(key_spr_bg:getw() / 2, key_spr_bg:geth() / 2):add2(key_spr_bg)
		local select_spr = display.newScale9Sprite("pic/scale/scale17.png", 0, 0, cc.size(100, 30)):anchor(0, 0.5):pos(110, item_h / 2):add2(node)

		select_spr:setVisible(false)

		node.key_label = key_label
		node.select_spr = select_spr
		node.id = info.id

		key_label:setTouchEnabled(false)
		key_spr_bg:setTouchEnabled(true)
		key_spr_bg:setTouchSwallowEnabled(false)
		key_spr_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				return true
			elseif event.name == "ended" then
				if self.handler then
					self.pressed = {}
					g_data.hotKey.isSettingKey = true

					for _, v in ipairs(self.cellList) do
						if v == node then
							v.select_spr:setVisible(true)

							self.cur_select = v
						else
							v.select_spr:setVisible(false)
						end
					end
				else
					self.handler = scheduler.performWithDelayGlobal(function ()
						self.handler = nil
					end, 0.25)
				end
			end
		end)
		table.insert(self.cellList, node)
	end

	local hotKeySet = g_data.hotKey:getHotKeySet()

	for i = 1, #hotKeySet, 2 do
		addSubItem((i - 1) / 2 + 1, 1, hotKeySet[i])
		addSubItem((i - 1) / 2 + 1, 2, hotKeySet[i + 1])
	end
end

function hotKeySetting:registerKeyboardEvent()
	self.listener = cc.EventListenerKeyboard:create()

	self.listener:registerScriptHandler(function (keyCode, evt)
		if self.cur_select then
			table.insert(self.pressed, keyCode)
			self:setHotKey(keyCode)
		end
	end, cc.Handler.EVENT_KEYBOARD_PRESSED)
	self.listener:registerScriptHandler(function (keyCode, evt)
		if self.cur_select then
			for idx, _keycode in ipairs(self.pressed) do
				if keyCode == _keycode then
					table.remove(self.pressed, idx)

					break
				end
			end
		end
	end, cc.Handler.EVENT_KEYBOARD_RELEASED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener, 1)
end

function hotKeySetting:setHotKey(code)
	local succeed, errorMsg = g_data.hotKey:resetKey(self.cur_select.id, self.pressed)

	if succeed then
		self:updateKeyValue()
		cache.saveHotKey(common.getPlayerName())
	elseif errorMsg then
		main_scene.ui:tip(errorMsg)
	end
end

function hotKeySetting:updateKeyValue()
	for _, v in ipairs(self.cellList) do
		local keyInfo = g_data.hotKey:getInfo(v.id)

		if keyInfo then
			v.key_label:setString(keyInfo.keyName)
		else
			v.key_label:setString("")
		end
	end
end

return hotKeySetting
