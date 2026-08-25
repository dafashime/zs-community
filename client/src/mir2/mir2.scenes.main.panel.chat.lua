local common = import("..common.common")
local itemInfo = import("..common.itemInfo")
local voiceBtn = import("..common.voiceBtn")
local chatPos = import("..common.chatPos")
local chatPic = import("..common.chatPic")
local chatItem = import("..common.chatItem")
local keyboardEx = import("..common.keyboardEx")
local chat = class("chat", function ()
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

local path = "pic/panels/chat/"

function chat:onCleanup()
	cache.saveSetting(common.getPlayerName(), "chat")
end

function chat:ctor()
	self._supportMove = true

	self:setNodeEventEnabled(true)

	local bg = res.get2("pic/common/black_0.png"):anchor(0, 0):add2(self)

	self:size(bg:getw(), bg:geth()):anchor(0.5, 0.5):pos(display.cx, display.cy + 67)
	res.get2(path .. "title.png"):add2(bg):pos(bg:getw() / 2, bg:geth() - 23)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 9, self:geth() - 8):addto(self)
	self:loadLeftContent()
end

function chat:loadLeftContent()
	if self.leftContent then
		self.leftContent:removeSelf()
	end

	self.leftContent = an.newScroll(0, 72, 134, 326):add2(self)
	local tabs = {
		"附近",
		"私聊",
		"喊话",
		"组队",
		"战队",
		"行会",
		"系统"
	}
	local sprs = {
		"fj",
		"sl",
		"hhua",
		"zd",
		"zdui",
		"hh",
		"shezhi"
	}

	for i, v in ipairs(tabs) do
		local btn = an.newBtn(res.gettex2("pic/common/btn60.png"), function ()
			common.setChatChannelIsOpen(v, not common.getChatChannelIsOpen(v))
		end, {
			support = "scroll",
			sprite = res.gettex2("pic/panels/chat/" .. sprs[i] .. ".png"),
			pressImage = res.gettex2("pic/common/btn61.png"),
			spriteOffset = cc.p(10, 0)
		}):anchor(0, 0.5):add2(self.leftContent):pos(18, self.leftContent:geth() - 23 - (i - 1) * 52)

		if i < #tabs then
			res.get2("pic/common/button_click.png"):add2(btn):pos(24, btn:geth() / 2)

			if common.getChatChannelIsOpen(v) then
				res.get2("pic/common/button_click02.png"):add2(btn):pos(24, btn:geth() / 2)
			end
		end
	end

	self:loadContent()
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
	self.content = display.newNode():pos(144, 20):size(480, 380):add2(self)
	local scrollbg = display.newColorLayer(cc.c4b(255, 255, 255, 255)):size(self.content:getw(), self.content:geth() - 50):pos(0, 50):add2(self.content)
	local maxLine = 60
	self.scroll = an.newScroll(0, 0, scrollbg:getw(), scrollbg:geth(), {
		labelM = {
			22,
			0,
			params = {
				maxLine = maxLine,
				doubleClickLine_call = function (msg)
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
	}):addTo(scrollbg)

	self.scroll:setListenner(function (event)
		if event.name == "moved" then
			local x, y = self.scroll:getScrollOffset()

			if y + self.scroll.labelM.wordSize.height > self.scroll:getScrollSize().height - self.scroll:geth() then
				self:hideNewMark()
			end
		end
	end)

	local msgs = g_data.chat:getMsgs(common.getAllOpenChatChannel(), maxLine)

	for i, v in ipairs(msgs) do
		self:addMsg(v)
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

	self.input = display.newNode():size(self.content:getw(), 50):pos(0, -8):add2(self.content)

	display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):size(380, 40):anchor(0, 0.5):pos(90, self.input:geth() / 2):add2(self.input)

	local filenames = {
		["私聊"] = "siliao",
		["组队"] = "bz",
		["喊话"] = "hanhua",
		["战队"] = "zhandui",
		["千里传音"] = "ql",
		["行会"] = "hanghui",
		["附近"] = "fujin"
	}
	local channelBtn = nil
	channelBtn = an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		common.chatChannelChoose():anchor(0.5, 0):pos(channelBtn:getPositionX(), channelBtn:geth() + 3):add2(self.input)
	end, {
		sprite = res.gettex2("pic/panels/chat/" .. (filenames[g_data.chat.style.channel] or "pd") .. ".png"),
		pressImage = res.gettex2("pic/common/btn71.png")
	}):add2(self.input):pos(40, self.input:geth() / 2)
	local labelw = 110
	local channel = g_data.chat.style.channel

	if channel == "私聊" then
		local text = nil

		if g_data.chat.style.target == "" then
			text = "(点击设置)"
		else
			text = "" .. g_data.chat.style.target
		end

		label = an.newLabel(text, 20, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0, 0.5):pos(labelw, self.input:geth() / 2 - 2):add2(self.input)

		label:enableClick(function ()
			g_data.mark:addNear(main_scene.ground.map:getHeroNameList())

			local msgbox = nil
			msgbox = an.newMsgbox("\n请输入对方名字.\n", function ()
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

	self.input.keyboard = an.newInput(labelw, self.input:geth() / 2 - 2, 330, 28, 50, {
		label = {
			oldstr,
			20,
			1
		},
		return_call = function ()
			self:say()
		end,
		getWorldY_call = function ()
			return self:getPositionY() - self:geth() * self:getAnchorPoint().y + self.content:getPositionY()
		end,
		keyboardEx = {
			get = function ()
				return keyboardEx.create(self.input.keyboard)
			end,
			remove = function ()
				return keyboardEx.destory()
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
	local c1, c2 = nil

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

function chat:addMsg(msg)
	if not common.getChatChannelIsOpen(msg.channel) then
		return
	end

	local c1, c2 = self:getColor(msg)
	local x, y = self.scroll:getScrollOffset()
	local isInEnd = self.scroll:getScrollSize().height < y + self.scroll:geth() + self.scroll.labelM.wordSize.height

	self.scroll.labelM:nextLine(msg)

	for i, v in ipairs(msg.data) do
		if v.type == "emoji" then
			self.scroll.labelM:addEmoji(res.gettex2("pic/emoji/" .. v.emoji .. ".png"))
		elseif v.type == "emojiConvert" then
			self.scroll.labelM:addEmojiForConvert(v.emoji)
		elseif v.type == "voice" then
			local bgkey = msg.channel == "私聊" and (msg.fromClient and "私聊self" or "私聊") or msg.channel

			self.scroll.labelM:addVoice(bgkey, v.dur, v.msgID, v.state, v.readed, function ()
				voice.play(msg.user, v.msgID, msg.channel, v.url, v.dur)
			end)
		elseif v.type == "pic" then
			self.scroll.labelM:addNode(chatPic.new(2, self.scroll.labelM, v, msg.user, msg.channel), 2, v.msgID)
		elseif v.type == "pos" then
			self.scroll.labelM:addNode(chatPos.new(2, self.scroll.labelM, v, msg.user), 2)
		elseif v.type == "item" then
			self.scroll.labelM:addNode(chatItem.new(2, self.scroll.labelM, v), 2)
		else
			self.scroll.labelM:addLabel(v, c1, c2)
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
		}))):enableClick(function ()
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
