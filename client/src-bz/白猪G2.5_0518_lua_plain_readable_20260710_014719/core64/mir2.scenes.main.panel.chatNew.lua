local common = import("..common.common")
local itemInfo = import("..common.itemInfo")
local voiceBtn = import("..common.voiceBtn")
local chatPos = import("..common.chatPos")
local chatPic = import("..common.chatPic")
local chatItem = import("..common.chatItem")
local keyboardEx2 = import("..common.keyboardEx")
local chat = class("chat", function()
	return display.newNode()
end)

table.merge(chat, {
	leftContent,
	content,
	scroll,
	input,
	newMark,
	sayerNode
})

function chat:onCleanup()
	cache.saveSetting(common.getPlayerName(), "chat")
end

function chat:ctor()
	self._supportMove = true

	self:setNodeEventEnabled(true)

	local background = display.newScale9Sprite(res.getframe2("pic/bzmir/newui/chat/left_chat.png"))

	background:size(500, display.height):anchor(0, 0):add2(self):opacity(255)
	self:size(background:getw(), background:geth()):anchor(0, 0.5):pos(-background:getw(), display.cy):run(cc.MoveBy:create(0.3, cc.p(background:getw(), 0)))

	local node = display.newNode():add2(self, -1):size(display.width + self:getw(), display.height):anchor(0, 0)

	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x)
		if x.name == "ended" and not cc.rectContainsPoint(background:getBoundingBox(), cc.p(x.x, x.y)) then
			sound.playSound("103")
			self:runs({
				cc.MoveBy:create(0.3, cc.p(-background:getw(), 0)),
				cc.CallFunc:create(function()
					self:hidePanel()
				end)
			})
		end

		return true
	end)

	local number = 130
	local number2 = 130

	display.newSprite(res.getframe2("pic/bzmir/newui/chat/left_close.png")):add2(background):anchor(0, 0.5):pos(background:getw(), background:geth() / 2)
	self:checkCannelStateIsOpen()

	self.page = ""

	self:loadLeftContent()
end

function chat:checkCannelStateIsOpen()
	local tabs = {
		"全部",
		"附近",
		"私聊",
		"喊话",
		"组队",
		"战队",
		"行会",
		"系统"
	}

	for i, v in ipairs(tabs) do
		if not common.getChatChannelIsOpen(v) then
			common.setChatChannelIsOpen(v, true)
		end
	end
end

function chat:moveChat()
	self:runs({
		cc.MoveBy:create(0.3, cc.p(-bg:getw(), 0)),
		cc.CallFunc:create(function()
			self:hidePanel()
		end)
	})
end

local function cleanup()
	local tabs = {
		"全部",
		"附近",
		"私聊",
		"喊话",
		"组队",
		"战队",
		"行会",
		"系统"
	}
	local number = 5
	local background = display.newScale9Sprite("pic/common/com_bg_kuang_3.png"):size(100, #tabs * (number + 37) + 18)

	common.enablePopStyle(background, true)

	for i, v in ipairs(tabs) do
		local btn = an.newBtn(res.gettex2("pic/bzmir/newui/chat/left_btn1.png"), function()
			common.setChatChannelIsOpen(v, not common.getChatChannelIsOpen(v))
		end, {
			label = {
				string.utf8sub(tabs[i], 1, 1) .. " " .. string.utf8sub(tabs[i], 2, 2),
				14,
				2,
				{
					color = cc.c3b(214, 198, 132)
				}
			},
			pressImage = res.gettex2("pic/bzmir/newui/chat/left_btn2.png"),
			labelOffset = {
				x = 15,
				y = 0
			}
		}):add2(background):pos(background:getw() / 2, 9 + (i - 1) * (37 + number)):anchor(0.5, 0)

		if i < #tabs then
			res.get2("pic/common/checkbox_select_disabled.png"):add2(btn):pos(5, btn:geth() / 2):anchor(0, 0.5)

			if common.getChatChannelIsOpen(v) then
				res.get2("pic/common/checkbox_select_up.png"):add2(btn):pos(5, btn:geth() / 2):anchor(0, 0.5)
			end
		end
	end

	return background
end

function chat:loadLeftContent()
	if self.leftContent then
		self.leftContent:removeSelf()
	end

	self.leftContent = an.newScroll(8, 120, 115, display.height - 130):add2(self):anchor(0, 0)

	local items = {
		"全部",
		"附近",
		"私聊",
		"喊话",
		"组队",
		"战队",
		"行会",
		"系统"
	}
	local items2 = {}

	local function callback(page)
		sound.playSound("103")

		for _, item in ipairs(items2) do
			if item == page then
				item.select(item)
			else
				item.unselect(item)
			end
		end

		if page.page ~= self.page then
			self.page = page.page

			self:loadContent()
		end
	end

	for index, page in ipairs(items) do
		items2[index] = an.newBtn(res.gettex2("pic/bzmir/newui/chat/left_btn2.png"), function()
			return
		end, {
			select = {
				res.gettex2("pic/bzmir/newui/chat/left_btn1.png"),
				manual = true
			},
			label = {
				page,
				18,
				2,
				{
					color = cc.c3b(214, 198, 132)
				}
			}
		}):anchor(0, 1):add2(self.leftContent):pos(0, self.leftContent:geth() - (index - 1) * 52)

		items2[index]:setTouchEnabled(true)
		items2[index]:setTouchSwallowEnabled(false)
		items2[index].addNodeEventListener(items2[index], cc.NODE_TOUCH_EVENT, function(point)
			if point.name == "began" then
				self.isMove = false
				items2[index].offsetBeginX = point.x
				items2[index].offsetBeginY = point.y

				return true
			elseif point.name == "moved" then
				if math.abs(items2[index].offsetBeginX - point.x) > 5 or math.abs(items2[index].offsetBeginY - point.y) > 5 then
					self.isMove = true
				end
			elseif point.name == "ended" then
				local value = point.x - items2[index].offsetBeginX
				local value2 = point.y - items2[index].offsetBeginY

				if not self.isMove then
					callback(items2[index])
				end
			end
		end)

		items2[index].page = page
	end

	callback(items2[1])

	local value
	local value2
	local btn = an.newBtn(res.gettex2("pic/common/chat_setting.png"), function()
		sound.playSound("103")

		value = not value

		cleanup(value):anchor(0.5, 0):pos(self.leftContent:getw() / 2, 0):add2(self.leftContent)
	end, {
		pressBig = true
	}):anchor(0.5, 0.5):pos(self.leftContent:getw() / 2, 60):add2(self)
end

function chat:loadContent()
	local oldstr = ""

	if self.input and self.input.keyboard then
		oldstr = self.input.keyboard:getText()
	end

	if self.content then
		self.content:removeSelf()
	end

	self.scroll = nil
	self.input = nil
	self.sayerNode = nil
	self.content = display.newNode():pos(130, 14):size(370, display.height - 20):add2(self, 99)

	local maxLine = 60

	self.scroll = an.newScroll(2, 50, self.content:getw() - 10, self.content:geth() - 55, {
		labelM = {
			20,
			1,
			params = {
				bufferChannel = 11,
				maxLine = maxLine,
				doubleClickLine_call = function(msg)
					if not msg or msg.target == "" then
						return
					end

					if g_data.chat.style.channel == "私聊" and g_data.chat.style.target == msg.target then
						return
					end

					common.changeChatStyle({
						{
							"channel",
							"私聊"
						},
						{
							"target",
							msg.target
						}
					})
				end
			}
		}
	}):addTo(self.content)

	self.scroll:setListenner(function(event)
		if event.name == "moved" then
			local x, y = self.scroll:getScrollOffset()

			if y + self.scroll.labelM.wordSize.height > self.scroll:getScrollSize().height - self.scroll:geth() then
				self:hideNewMark()
			end
		end
	end)

	local msgs = g_data.chat:getMsgs(self.page, maxLine)

	for i, v in ipairs(msgs) do
		self:processMsg(v)
	end

	self:loadInput(oldstr)
end

function chat:loadInput(oldstr)
	oldstr = oldstr or ""

	if self.input and self.input.keyboard then
		oldstr = self.input.keyboard:getText()
	end

	if self.input then
		self.input:removeSelf()
	end

	self.input = display.newNode():size(self.content:getw(), 50):pos(-28, -4):add2(self.content)

	display.newScale9Sprite(res.getframe2("pic/bzmir/newui/chat/left_inputbg.png")):size(300, 34):anchor(0, 0.5):pos(90, self.input:geth() / 2 - 5):add2(self.input)

	local filenames = {
		"私聊",
		"组队",
		"喊话",
		"战队",
		"千里传音",
		"行会",
		"附近"
	}
	local labelw = 92
	local channel = g_data.chat.style.channel

	if channel == "千里传音" then
		channel = "传音"
	end

	local btn

	btn = an.newBtn(res.gettex2("pic/common/btn50.png"), function()
		common.chatChannelChoose():anchor(0.5, 0):pos(btn:getPositionX() + 10, btn:geth() + 5):add2(self.input)
	end, {
		pressImage = res.gettex2("pic/common/btn51.png"),
		label = {
			channel,
			20,
			1,
			{
				color = cc.c3b(214, 198, 132)
			}
		}
	}):add2(self.input):pos(55, self.input:geth() / 2 - 4)

	if channel == "私聊" then
		local value
		local value2 = g_data.chat.style.target == "" and "(点击设置)" or "" .. g_data.chat.style.target
		local label = an.newLabel(value2, 20, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0, 0.5):pos(labelw, self.input:geth() / 2 - 2):add2(self.input)

		label:enableClick(function()
			g_data.mark:addNear(main_scene.ground.map:getHeroNameList())

			local msgbox

			msgbox = an.newMsgbox("\n请输入对方名字.\n", function()
				common.changeChatStyle({
					{
						"channel",
						"私聊"
					},
					{
						"target",
						msgbox.input:getString()
					}
				})
			end, {
				disableScroll = true,
				input = 20,
				inputList = {
					"<猜你要选>",
					g_data.mark:getNames()
				}
			})

			msgbox.input:setString(g_data.chat.style.target)
		end, {
			size = cc.size(label:getw(), 12),
			anchor = cc.p(0, 1),
			pos = cc.p(0, 0)
		})

		labelw = labelw + label:getw() - 3
	end

	self.input.keyboard = an.newInput(labelw, self.input:geth() / 2 - 2, 280, 34, 50, {
		label = {
			oldstr,
			18,
			1
		},
		return_call = function()
			self:say()
		end,
		getWorldY_call = function()
			return self:getPositionY() - self:geth() * self:getAnchorPoint().y + self.content:getPositionY()
		end,
		keyboardEx = {
			get = function()
				return keyboardEx2.create(self.input.keyboard)
			end,
			remove = function()
				return keyboardEx2.destory()
			end
		}
	}):anchor(0, 0.5):addto(self.input, 0)
end

function chat:hideSayer()
	if self.sayerNode then
		self.sayerNode:removeSelf()

		self.sayerNode = nil
	end
end

function chat:showSayer(msg)
	if not common.getChatChannelIsOpen(msg.channel) then
		return
	end

	self:hideSayer()

	local size = cc.size(self.content:getw(), 24)

	self.sayerNode = display.newClippingRegionNode(cc.rect(0, 0, size.width, size.height)):pos(0, self.content:geth() - size.height + 2):add2(self.content, 1)

	local c1, c2 = self:getColor(msg)

	display.newColorLayer(cc.c4b(0, 255, 255, 188)):size(size):add2(self.sayerNode)

	local user = an.newLabel(msg.user .. ":", 22, 1, {
		color = c1,
		sc = c2
	}):anchor(0, 0.5):pos(5, size.height / 2):add2(self.sayerNode)

	for i, v in ipairs(msg.data) do
		if v.type == "voice" then
			local bgkey = msg.channel == "私聊" and (msg.fromClient and "私聊self" or "私聊") or msg.channel

			an.newVoiceBubble(size.height, bgkey, v.dur, v.msgID, v.state, true):anchor(0, 0.5):pos(user:getPositionX() + user:getw() + 3, size.height / 2):add2(self.sayerNode)

			break
		end
	end
end

function chat:getColor(msg)
	local color = msg.color
	local bgColor = msg.bgColor
	local c1
	local c2

	if type(color) == "number" then
		c1 = def.colors.get(color)
	else
		c1 = color
	end

	if type(bgColor) == "number" then
		c2 = def.colors.get(bgColor, true)
	elseif bgColor then
		c2 = cc.c4b(bgColor.r, bgColor.g, bgColor.b, 255)
	end

	return c1, c2
end

function chat:getColor1(value2)
	local value = value2.color
	local value3 = value2.bgColor

	if value2.channel == "附近" then
		value3 = 0
		value = 255
	elseif value == 0 or type(value) == "table" and value.r == 0 and value.g == 0 and value.b == 0 then
		value = value3
		value3 = 0
	elseif value == 219 and (value3 == 255 or value3 == 256) then
		value3 = 0
		value = 250
	end

	local value4
	local value5

	if type(value) == "number" then
		value4 = def.colors.get(value)
	else
		value4 = value
	end

	if type(value3) == "number" then
		value5 = def.colors.get(value3)
	else
		value5 = value3
	end

	return value4, cc.c4b(value5.r, value5.g, value5.b, 255)
end

function chat:processMsg(msg)
	if not common.getChatChannelIsOpen(msg.channel) then
		return
	end

	if self.page ~= "全部" and self.page ~= msg.channel then
		return
	end

	local color1, color12 = self:getColor1(msg)
	local x, y = self.scroll:getScrollOffset()
	local isInEnd = self.scroll:getScrollSize().height < y + self.scroll:geth() + self.scroll.labelM.wordSize.height

	self.scroll.labelM:nextLine(msg)

	local items = {
		私聊 = "single",
		系统 = "xiton",
		喊话 = "loudly",
		组队 = "group",
		战队 = "clan",
		千里传音 = "far",
		行会 = "guild",
		附近 = "near"
	}

	self.scroll.labelM:addEmoji(res.gettex2("pic/bzmir/newui/chat/chatimg/" .. items[msg.channel] .. ".png"))

	for i, v in ipairs(msg.data) do
		if v.type == "emoji" then
			self.scroll.labelM:addEmoji(res.gettex2("pic/emoji/" .. v.emoji .. ".png"))
		elseif v.type == "emojiConvert" then
			self.scroll.labelM:addEmojiForConvert(v.emoji)
		elseif v.type == "voice" then
			local bgkey = msg.channel == "私聊" and (msg.fromClient and "私聊self" or "私聊") or msg.channel

			self.scroll.labelM:addVoice(bgkey, v.dur, v.msgID, v.state, v.readed, function()
				voice.play(msg.user, v.msgID, msg.channel, v.url, v.dur)
			end)
		elseif v.type == "pic" then
			self.scroll.labelM:addNode(chatPic.new(2, self.scroll.labelM, v, msg.user, msg.channel), 2, v.msgID)
		elseif v.type == "pos" then
			self.scroll.labelM:addNode(chatPos.new(2, self.scroll.labelM, v, msg.user), 2)
		elseif v.type == "item" then
			self.scroll.labelM:addNode(chatItem.new(2, self.scroll.labelM, v), 2)
		else
			if CS_YB and CS_GRID then
				if v:find("元宝") ~= nil and CS_YB ~= "元宝" then
					v = string.gsub(v, "元宝", CS_YB)
				end

				if v:find("灵符") ~= nil and CS_GRID ~= "灵符" then
					v = string.gsub(v, "灵符", CS_GRID)
				end
			end

			local color13, color14 = self:getColor1(msg)

			self.scroll.labelM:addLabel(v, color13, nil, color14)
		end
	end

	if isInEnd then
		self.scroll:setScrollOffset(0, self.scroll:getScrollSize().height - self.scroll:geth())
	else
		self:showNewMark()
	end
end

function chat:showNewMark()
	if not self.newMark then
		self.newMark = res.get2("pic/common/msgNew.png"):add2(self, 1):run(cc.RepeatForever:create(transition.sequence({
			cc.ScaleTo:create(0.5, 0.7),
			cc.ScaleTo:create(0.5, 1)
		}))):enableClick(function()
			self.newMark:hide()
			self.scroll:setScrollOffset(0, self.scroll:getScrollSize().height - self.scroll:geth())
		end)
	end

	self.newMark:show():pos(self:getw() - 50, self.input:geth() + 60)
end

function chat:hideNewMark()
	if self.newMark then
		self.newMark:hide()
	end
end

function chat:say()
	if common.say(self.input.keyboard:getText(), self.input.keyboard.content) then
		self.input.keyboard:setText("")
	end
end

return chat
