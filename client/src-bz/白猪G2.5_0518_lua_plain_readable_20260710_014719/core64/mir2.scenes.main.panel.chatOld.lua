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

	local background = display.newScale9Sprite(res.getframe2("pic/bzmir/newui/chat/bg.png")):anchor(0, 0):add2(self):opacity(255)

	self:size(background:getw(), background:geth()):anchor(0.5, 0.5):pos(display.cx, display.cy + 40)
	res.get2("pic/bzmir/newui/chat/title.png"):add2(background):pos(background:getw() / 2, background:geth() - 33)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(0, 1):pos(self:getw() - 10, self:geth() - 8):addto(self)

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
	local sprs = {
		"all",
		"fujin",
		"siliao",
		"hanhua",
		"zudui",
		"zhandui",
		"hanghui",
		"xitong"
	}

	local function cleanup(self)
		for index, item in ipairs(tabs) do
			if item == self then
				return sprs[index]
			end
		end

		return sprs[1]
	end

	self.channelBtn = {}

	local function cleanup2(page, value2)
		local value
		local btn = an.newBtn(res.gettex2("pic/bzmir/newui/chat/btn2.png"), function()
			sound.playSound("103")
			self.channelBtn[self.page]:unselect()
			self.channelBtn[page]:select()

			self.page = page

			self:loadContent()
		end, {
			support = "easy",
			sprite = res.gettex2("pic/bzmir/newui/chat/channel/" .. cleanup(page) .. ".png"),
			select = {
				res.gettex2("pic/bzmir/newui/chat/btn1.png"),
				manual = true
			}
		}):pos(76 + (value2 - 1) * 91, self:geth() - 72):addto(self)

		self.channelBtn[page] = btn
	end

	for index, item in ipairs(tabs) do
		cleanup2(item, index)
	end

	self:checkCannelStateIsOpen()

	self.page = "全部"

	self:loadContent()
	self.channelBtn[self.page]:select()
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
	self.content = display.newNode():pos(32, 82):size(760, 363):add2(self, 99)

	local maxLine = 60

	self.scroll = an.newScroll(2, 2, self.content:getw() - 50, self.content:geth() - 10, {
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

	self.input = display.newNode():size(self.content:getw(), 25):pos(-5, -35):add2(self.content)

	display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):size(490, 38):anchor(0, 0.5):pos(80, self.input:geth() / 2):add2(self.input)

	local filenames = {
		私聊 = "siliao",
		组队 = "bz",
		喊话 = "hanhua",
		战队 = "zhandui",
		千里传音 = "ql",
		行会 = "hanghui",
		附近 = "fujin"
	}
	local channelBtn
	local x = 40

	channelBtn = an.newBtn(res.gettex2("pic/common/btn70.png"), function()
		common.chatChannelChoose():anchor(0.5, 0):pos(channelBtn:getPositionX(), channelBtn:geth() + 3):add2(self.input)
	end, {
		sprite = res.gettex2("pic/bzmir/newui/chat/" .. (filenames[g_data.chat.style.channel] or "pd") .. ".png"),
		pressImage = res.gettex2("pic/common/btn71.png")
	}):add2(self.input):pos(x, self.input:geth() / 2)

	local labelw = 110

	if g_data.chat.style.channel == "私聊" then
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

		labelw = labelw + label:getw() + 3
	end

	local number = 440

	self.input.keyboard = an.newInput(labelw, self.input:geth() / 2 - 2, number, 28, 50, {
		label = {
			oldstr,
			20,
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
				self.input:setPositionY(8)

				return keyboardEx2.create(self.input.keyboard)
			end,
			remove = function()
				self.input:setPositionY(-35)

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
		self.newMark = res.get2("pic/common/msgNew.png"):add2(self, 99999):run(cc.RepeatForever:create(transition.sequence({
			cc.ScaleTo:create(0.5, 0.7),
			cc.ScaleTo:create(0.5, 1)
		}))):enableClick(function()
			self.newMark:hide()
			print(444)
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
