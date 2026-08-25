local common = import("..common.common")
local chatItem = import("..common.chatItem")
local voiceBtn = import("..common.voiceBtn")
local keyboardEx = import("..common.keyboardEx")
local relation = class("relation", function ()
	return display.newNode()
end)
local titleFontSize = 20
local itemFontSize = 18
local btnTitleFontSize = 18
local chatNameFontSize = 18
local chatContentFontSize = 18

table.merge(relation, {
	home,
	members,
	content,
	tabNode
})

relation.ATTENTION_COLORS = {
	250,
	253,
	254,
	5
}
relation.uiColor = {
	cellSel = cc.c3b(250, 206, 0),
	cellNor = cc.c3b(245, 235, 205),
	cellOffline = cc.c3b(53, 53, 53, 255),
	cellTitle = cc.c3b(219, 194, 122)
}

function relation:ctor()
	self._supportMove = true
	self.needClean = {}
	local bg = display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):add2(self)

	self:size(bg:getw(), bg:geth()):anchor(0.5, 0.5):center()
	display.newSprite(res.gettex2("pic/panels/friend/title.png")):anchor(0.5, 0.5):pos(bg:getw() * 0.5, bg:geth() - 24):add2(bg)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 9, self:geth() - 8):addto(self)

	self.nodeContent = display.newNode():addto(self)

	self.nodeContent:size(bg:getw(), bg:geth()):anchor(0, 0)

	local texts = {
		"friend",
		"near",
		"attention",
		"black"
	}
	local textlabels = {
		"friendTitle",
		"nearTitle",
		"attentionTitle",
		"blackTitle"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v:select()
				v:setLocalZOrder(5)
			else
				v:unselect()
				v:setLocalZOrder(i)
			end
		end

		if btn.page ~= self.page then
			self:showContentWithRefresh(btn.page)
		end
	end

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn110.png"), click, {
			support = "easy",
			sprite = res.gettex2("pic/panels/friend/" .. textlabels[i] .. ".png"),
			spriteOffset = {
				x = 3,
				y = 10
			},
			select = {
				res.gettex2("pic/common/btn111.png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(0, bg:geth() - 38 - 70 * (i - 1))
		tabs[i].page = v

		if texts[1] == v then
			click(tabs[i])
		end
	end

	self.dataHandler = handler(self, self.onDataUpdate)

	g_data.relation:addNotifyListener(self.dataHandler)
	self:setNodeEventEnabled(true)

	function self.onCleanup()
		g_data.relation:removeNotifyListener(self.dataHandler)
	end
end

function relation:onDataUpdate(src, relation)
	if relation == "friend" and self.page == "friend" or relation == "near" and self.page == "near" or relation == "attention" and self.page == "attention" or relation == "blackList" and self.page == "black" then
		self:showContent(self.page)
	end
end

function relation:showContentWithRefresh(page)
	self:showContent(page)

	if page == "friend" then
		net.send({
			CM_QUERY_RELATION_FRIEND
		})
	elseif page == "attention" then
		net.send({
			CM_QUERY_RELATION_ATTENTION
		})
	elseif page == "black" then
		net.send({
			CM_QUERY_RELATION_NORMBLACKLIST
		})
	end
end

function relation:showContent(page, ...)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addto(self)

	self.content:size(self:getw(), self:geth())

	if page == "friend" then
		self:showContentFriend(self.content, ...)
	elseif page == "near" then
		self:showContentNear(self.content, ...)
	elseif page == "attention" then
		self:showContentAttention(self.content, ...)
	elseif page == "black" then
		self:showContentBlack(self.content, ...)
	end
end

function relation.setCellColor(cell, color)
	for k, v in ipairs(cell:getChildren()) do
		if tolua.type(v) == "cc.Node" then
			v:setColor(color)
		end
	end
end

function relation:selectPlayer(name)
	local cell = nil

	if type(name) == "string" then
		cell = self.cellList[name]
	else
		cell = name
		name = cell.name
	end

	if not tolua.isnull(cell) then
		if self.selectPic_ and not tolua.isnull(self.selectPic_) then
			self.selectPic_:removeSelf()
		end

		self.selectPic_ = display.newScale9Sprite(res.getframe2("pic/scale/scale25.png"), 0, 0, cc.size(cell.width, cell.height)):anchor(0, 0):pos(0, 0):add2(cell)

		if not tolua.isnull(self.selectedCell_) then
			if self.selectedCell_.data:get("isonline") == 0 then
				relation.setCellColor(self.selectedCell_, relation.uiColor.cellOffline)
			else
				relation.setCellColor(self.selectedCell_, relation.uiColor.cellNor)
			end
		end

		if cell.data:get("isonline") ~= 0 then
			relation.setCellColor(cell, relation.uiColor.cellSel)
		end

		self.selectedCell_ = cell
	end

	if self.page == "friend" and g_data.relation:getFriend(name) then
		self:initChatList(name)
	end
end

function relation:enableSelect(cell)
	cell:setTouchEnabled(true)
	cell:setTouchSwallowEnabled(false)
	cell:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			cell.offsetBeginY = event.y

			return true
		elseif event.name == "ended" then
			local offsetY = event.y - cell.offsetBeginY

			if math.abs(offsetY) <= 5 then
				self:selectPlayer(cell.name)
			end
		end
	end)
end

local chatListView = class("listView", function ()
	return display.newNode()
end)
chatListView.wdayStrs = {
	"星期日",
	"星期一",
	"星期二",
	"星期三",
	"星期四",
	"星期五",
	"星期六"
}

function chatListView:ctor(chatRecord)
	self.chatRecord = chatRecord
	self.itemInterval = 5

	local function onNewChat(from, evt, content)
		if evt == "newItem" then
			local node = self:createChatItem(content)

			table.insert(self.items, 1, node)
			self:arrange()
			self.chatRecord:readed()
		end
	end

	chatRecord:addNotifyListener(onNewChat)
	self:setNodeEventEnabled(true)

	function self.onCleanup()
		chatRecord:removeNotifyListener(onNewChat)
	end

	self.lastChatTime = 0
end

function chatListView:clear()
	self.preY = 0

	self:removeAllChildren()

	self.items = {}
end

function chatListView:createChatItem(itemData)
	local n = display.newNode():add2(self)
	local posY = 0
	local itv = itemData.time - self.lastChatTime

	if itv > 300 then
		local timeTable = os.date("*t", itemData.time)
		local wdaystr = chatListView.wdayStrs[timeTable.wday]
		local noon = timeTable.hour >= 12 and " 下午 " or " 上午 "
		timeStr = string.format("%s %s %02d:%02d", wdaystr, noon, timeTable.hour, timeTable.min)
		local timeItem = an.newLabel(timeStr, chatNameFontSize, 1):add2(n):pos(self.viewWidth / 2, -posY):anchor(0.5, 1)

		timeItem:setColor(relation.uiColor.cellNor)

		posY = posY + timeItem:geth() + self.itemInterval
	end

	self.lastChatTime = itemData.time
	local nameItem = an.newLabel(itemData.name, chatNameFontSize, 1):add2(n):pos(itemData.isOther and 3 or self.viewWidth - 3, -posY):anchor(itemData.isOther and 0 or 1, 1)

	nameItem:setColor(relation.uiColor.cellTitle)

	posY = posY + nameItem:geth() + self.itemInterval
	local chatData = common.decodeMsg(itemData.text)
	local chatItem = common.createChatLabel({
		strWidth = 320,
		channel = "私聊",
		data = chatData,
		user = itemData.name,
		fontSize = chatContentFontSize
	}, true):add2(n):anchor(0, 1)

	for k, v in pairs(chatData) do
		local voice = chatItem:findVoiceBubbleForMsgID(v.msgID)

		if voice then
			voice:hideUnread()
		end
	end

	local itemWidth = 345

	if #chatItem.lines == 1 then
		local l = chatItem.lines[1]
		local max = 0

		for k, v in ipairs(l:getChildren()) do
			local w = v:getPosition() + v:getw()

			if max < w then
				max = w
			end
		end

		itemWidth = max
	end

	chatItem:pos(itemData.isOther and 20 or self.viewWidth - itemWidth - 20, -posY - 12)

	n.chatLabel = chatItem
	local offsetX = itemData.isOther and -9 or itemWidth + 18

	if itemWidth < 80 then
		itemWidth = 80
	end

	local pnl = display.newScale9Sprite(res.getframe2(string.format("pic/scale/chatBubble%d.png", itemData.isOther and 1 or 2)), offsetX, -8, cc.size(itemWidth + 30, chatItem:geth() + 24)):anchor(itemData.isOther and 0 or 1, 0):add2(chatItem, -1)

	pnl:setCapInsets(cc.rect(itemData.isOther and 59 or 15, 23, 5, 5))

	posY = posY + self.itemInterval + pnl:geth()
	n.height = posY

	return n, posY
end

function chatListView:arrange()
	local start = 0

	for k, v in pairs(self.items) do
		start = start + v.height

		v:pos(0, start)
	end

	self.preY = -start + self.viewHeight
end

function chatListView:initChatList(defaultItemCnt)
	self:clear()

	self.viewWidth = self:getParent():getw()
	self.viewHeight = self:getParent():geth()
	self.start = 0
	local iter = self.chatRecord:rIterator()
	local defaultItemCnt = defaultItemCnt or 10

	for k = 1, defaultItemCnt do
		local item = iter()

		if not item then
			break
		end

		local node, itemHeight = self:createChatItem(item)
		self.items[k] = node
	end

	self:arrange()
	self:pos(0, 0)
end

function chatListView:loadFront()
	local iter = self.chatRecord:rIterator()
	local defaultItemCnt = #self.items + 10

	for k = 1, defaultItemCnt do
		local item = iter()

		if not self.items[k] then
			if not item then
				break
			end

			local node, itemHeight = self:createChatItem(item)
			self.items[k] = node
		end
	end

	self:arrange()
end

function relation:getChatLabelMs()
	print("relation:getChatLabelMs")

	local ret = {}

	if not tolua.isnull(self.chatListView) then
		for k, v in pairs(self.chatListView.items) do
			table.insert(ret, v.chatLabel)
		end
	end

	return ret
end

function relation:initChatList(friendName)
	print("relation:initChatList")

	if tolua.isnull(self.chatView) then
		return
	end

	if not tolua.isnull(self.chatListView) then
		self.chatListView:removeSelf()

		self.chatListView = nil
	end

	self.chattingPlayer = friendName

	self:loadInput(true)

	local chatRecord = g_data.relation:getRecords(common.getPlayerName(), friendName)

	if not chatRecord then
		return
	end

	local chat = chatListView.new(chatRecord):add2(self.chatView)

	chatRecord:readed()

	local scroll = self.chatView

	scroll:setScrollOffset(0, 0)

	local loadFront = false

	self.chatView:setListenner(function (event)
		local x, y = scroll:getScrollOffset()

		if event.name == "moved" then
			if chat.preY and y < chat.preY then
				loadFront = true
			end
		elseif event.name == "ended" then
			if loadFront then
				print("loadFront", loadFront)
				chat:loadFront()
			end
		elseif event.name == "began" then
			loadFront = false
		end
	end)
	chat:initChatList()

	self.chatListView = chat

	if self.selectedCell_ and self.selectedCell_:getChildByName("unread") then
		self.selectedCell_:getChildByName("unread"):setVisible(false)
	end
end

function relation:fixStrLen(text, len)
	local strs = utf8strs(text)

	if len < #strs then
		local ret = ""

		for k = 1, len do
			ret = ret .. strs[k]
		end

		return ret .. "..."
	end

	return text
end

function relation:showContentFriend(parent)
	print("relation:showContentFriend")

	self.page = "friend"
	self.chattingPlayer = nil
	local dataList = g_data.relation:getFriends()
	local back1 = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(196, 336)):anchor(0, 0):pos(20, 64):add2(parent)
	local back2 = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(392, 336)):anchor(0, 0):pos(228, 64):add2(parent)
	local n = display.newNode():add2(back1)
	local width = {
		138,
		51
	}
	local Titlelabel = {
		"角色名",
		"等级"
	}
	local posOffset = 3

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)
		an.newLabel(Titlelabel[i], titleFontSize, 1, {
			color = relation.uiColor.cellTitle
		}):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)

		posOffset = posOffset + v
	end

	local chatView = an.newScroll(4, 4, 384, 286):add2(back2)

	chatView:setScrollSize(384, 286)

	self.chatView = chatView

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(388, 42)):anchor(0.5, 0.5):pos(back2:getw() * 0.5, back2:geth() - 23):add2(back2)
	an.newLabel("好友私聊", 20, 1, {
		color = relation.uiColor.cellTitle
	}):anchor(0.5, 0.5):pos(back2:getw() * 0.5, back2:geth() - 23):add2(back2)

	local data = {}
	local friendView = an.newScroll(4, 4, 188, 286):add2(back1)
	local h = 42

	friendView:setScrollSize(188, math.max(286, #data * h))

	if #dataList == 0 then
		an.newLabel("当前无好友", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(friendView:getw() / 2, friendView:geth() / 2):add2(friendView, 2)
	end

	self.cellList = {}

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(188, h)):anchor(0, 0):pos(0, friendView:getScrollSize().height - i * h):add2(friendView)
		local label = v:get("name")
		cell.name = label
		cell.height = h
		cell.width = 188

		an.newLabel(self:fixStrLen(label, 8), 18, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(70, h * 0.5)

		label = v:get("level")

		an.newLabel(label, 18, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(162, h * 0.5)
		self:enableSelect(cell)

		cell.data = v

		if not next(self.cellList) then
			self:selectPlayer(cell)
		end

		self.cellList[cell.name] = cell

		if v:get("isonline") == 0 then
			relation.setCellColor(cell, relation.uiColor.cellOffline)
		end

		local unread = display.newSprite(res.gettex2("pic/panels/friend/unread.png")):add2(cell):pos(width[1], cell:geth()):anchor(0.5, 1)

		unread:setName("unread")
		unread:scale(0.8)

		local chatRecord = g_data.relation:getRecords(common.getPlayerName(), cell.name)
		local unreadLabel = an.newLabel(tostring(chatRecord:getUnreadCnt()), 14, 1, {
			color = relation.uiColor.cellTitle
		}):add2(unread):pos(unread:getw() / 2, unread:geth() / 2):anchor(0.5, 0.5)

		unread:setVisible(chatRecord:getUnreadCnt() ~= 0)

		local function onUpdate()
			scheduler.performWithDelayGlobal(function ()
				if tolua.isnull(cell) then
					chatRecord:removeNotifyListener(onUpdate)

					return
				end

				if cell == self.selectedCell_ then
					return
				end

				unread:setVisible(chatRecord:getUnreadCnt() ~= 0)
				unreadLabel:removeFromParent()

				unreadLabel = an.newLabel(tostring(chatRecord:getUnreadCnt()), 14, 1, {
					color = relation.uiColor.cellTitle
				}):add2(unread):pos(unread:getw() / 2, unread:geth() / 2):anchor(0.5, 0.5)
			end, 0)
		end

		chatRecord:addNotifyListener(onUpdate)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		relation.showInputDialog(self.page, function (name)
			if not name or name == "" then
				main_scene.ui:tip("名称不能为空")

				return
			end

			self.addFriend(name)
		end)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/tj.png")
	}):add2(parent):anchor(0.5, 0.5):pos(68, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:showMenu(cc.p(111, 50))
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/cz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(170, 36)
end

function relation:transChatTarget()
	common.changeChatStyle({
		{
			"target",
			self.chattingPlayer
		},
		{
			"channel",
			"私聊"
		}
	})
end

function relation:loadInput()
	if self.page ~= "friend" then
		return
	end

	local parent = self.content
	local orgBase = parent:getChildByName("chatBase")

	if not self.chattingPlayer or g_data.relation:getFriend(self.chattingPlayer):get("isonline") == 0 then
		if orgBase then
			orgBase:removeFromParent()
		end

		return
	end

	if orgBase then
		if unreload then
			return
		else
			if g_data.chat.style.input == self.inputType then
				return
			end

			orgBase:removeFromParent()
		end
	end

	self.inputType = g_data.chat.style.input
	local base = display.newScale9Sprite(res.getframe2("pic/scale/edit.png"), 0, 0, cc.size(340, 42)):anchor(0.5, 0.5):pos(186, 32)

	base:add2(parent):anchor(0.5, 0.5):pos(448, 38):setName("chatBase")

	local input = an.newInput(10, base:geth() / 2, 280, 40, 80, {
		placeholder = "",
		label = {
			"",
			20
		}
	}):addTo(base):anchor(0, 0.5):hide()
	self.keyboard = an.newInput(10, base:geth() / 2, 320, 40, 50, {
		defaultString = "",
		label = {
			"",
			20
		},
		return_call = function ()
			self:say()
		end,
		getWorldY_call = function ()
			return self:getPositionY() - self:geth() * self:getAnchorPoint().y + self.content:getPositionY()
		end,
		keyboardEx = {
			get = function ()
				self:transChatTarget()

				return keyboardEx.create(self.keyboard)
			end,
			remove = function ()
				return keyboardEx.destory()
			end
		}
	}):addto(base):anchor(0, 0.5)
	local vb = voiceBtn.new(res.gettex2("pic/panels/friend/voice0.png"), res.gettex2("pic/panels/friend/voice1.png")):add2(base):anchor(1, 0):pos(-5, 1)
	local listener = cc.EventListenerTouchOneByOne:create()

	listener:setSwallowTouches(false)
	listener:registerScriptHandler(function (touch, event)
		local pos = touch:getLocation()

		if not tolua.isnull(vb) and vb.hitTest and vb:hitTest(pos) then
			self:transChatTarget()
		end
	end, cc.Handler.EVENT_TOUCH_BEGAN)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

	eventDispatcher:addEventListenerWithFixedPriority(listener, -1)

	function base:onCleanup()
		eventDispatcher:removeEventListener(listener)
	end
end

function relation:say()
	self:transChatTarget()

	if common.say(self.keyboard:getRichText()) then
		self.keyboard:setText("")
	end
end

function relation:showContentNear(parent, list)
	print("relation:showContentNear")

	self.page = "near"
	local dataList = list or g_data.relation:getNearList()
	local back1 = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(602, 336)):anchor(0, 0):pos(20, 64):add2(parent)
	local width = {
		178,
		80,
		80,
		80,
		178
	}
	local Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"性别",
		"所属行会"
	}
	local posOffset = 3

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)
		an.newLabel(Titlelabel[i], titleFontSize, 1, {
			color = relation.uiColor.cellTitle
		}):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)

		posOffset = posOffset + v
	end

	local data = {}
	local friendView = an.newScroll(4, 4, 596, 286):add2(back1)
	local h = 42

	friendView:setScrollSize(596, math.max(286, #data * h))

	if #dataList == 0 then
		an.newLabel("当前附近无其他玩家", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(friendView:getw() / 2, friendView:geth() / 2):add2(friendView, 2)
	end

	self.cellList = {}

	for i, v in ipairs(dataList) do
		local name = v
		local level = ""
		local job = ""
		local sex = ""
		local guild = ""

		if type(v) ~= "string" then
			name = v:get("name")
			level = v:get("level")
			job = v:get("job")

			if job == 0 then
				job = "战士"
			elseif job == 1 then
				job = "法师"
			elseif job == 2 then
				job = "道士"
			end

			if v:get("sex") == 0 then
				sex = "男"
			else
				sex = "女"
			end

			guild = self:fixStrLen(v:get("guildName") or "", 11)
		end

		local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(596, h)):anchor(0, 0):pos(0, friendView:getScrollSize().height - i * h):add2(friendView)
		local label = name
		cell.name = name
		cell.height = h
		cell.width = 596

		an.newLabel(self:fixStrLen(label, 11), itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(86, h * 0.5)

		label = level

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(220, h * 0.5)

		label = job

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(300, h * 0.5)

		label = sex

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(380, h * 0.5)

		label = guild

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(504, h * 0.5)
		self:enableSelect(cell)

		if type(v) ~= "string" then
			cell.data = v

			if not next(self.cellList) then
				self:selectPlayer(cell)
			end

			self.cellList[cell.name] = cell
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:showMenu(cc.p(525, 50))
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/cz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(576, 36)
end

function relation:showContentAttention(parent)
	print("relation:showContentAttention")

	self.page = "attention"
	local dataList = g_data.relation:getAttentions()
	local back1 = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(602, 336)):anchor(0, 0):pos(20, 64):add2(parent)
	local width = {
		200,
		120,
		120,
		156
	}
	local Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"显示颜色"
	}
	local posOffset = 3

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)
		an.newLabel(Titlelabel[i], titleFontSize, 1, {
			color = relation.uiColor.cellTitle
		}):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)

		posOffset = posOffset + v
	end

	local data = {}
	local friendView = an.newScroll(4, 4, 596, 286):add2(back1)
	local h = 42

	friendView:setScrollSize(596, math.max(286, #data * h))

	if #dataList == 0 then
		an.newLabel("当前未关注其他玩家", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(friendView:getw() / 2, friendView:geth() / 2):add2(friendView, 2)
	end

	self.cellList = {}

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(596, h)):anchor(0, 0):pos(0, friendView:getScrollSize().height - i * h):add2(friendView)
		local label = v:get("name")
		cell.name = label
		cell.height = h
		cell.width = 596

		an.newLabel(self:fixStrLen(label, 12), itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(98, h * 0.5)

		label = v:get("level")

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(260, h * 0.5)

		label = v:get("job")

		if label == 0 then
			label = "战士"
		elseif label == 1 then
			label = "法师"
		elseif label == 2 then
			label = "道士"
		end

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(380, h * 0.5)

		local colorIndex = v:get("color")
		local c = def.colors.get(colorIndex, true)

		display.newColorLayer(c):pos(500, 8):addto(cell):size(26, 26):setName("color")
		self:enableSelect(cell)

		cell.data = v

		if not next(self.cellList) then
			self:selectPlayer(cell)
		end

		self.cellList[cell.name] = cell

		if v:get("isonline") == 0 then
			relation.setCellColor(cell, relation.uiColor.cellOffline)
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:showAttentionColorMenu()
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/szys.png")
	}):add2(parent):anchor(0.5, 0.5):pos(376, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		relation.showInputDialog(self.page, function (name)
			if not name or name == "" then
				main_scene.ui:tip("名称不能为空")

				return
			end

			relation.addAttention(name)
		end)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/tjgz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(476, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if self.selectedCell_ then
			relation.removeAttention(self.selectedCell_.name)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/qxgz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(576, 36)
end

function relation:showContentBlack(parent)
	print("relation:showContentBlack")

	self.page = "black"
	local dataList = g_data.relation:getBlackList()
	local back1 = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(602, 336)):anchor(0, 0):pos(20, 64):add2(parent)
	local width = {
		300,
		296
	}
	local Titlelabel = {
		"角色名",
		"等级"
	}
	local posOffset = 3

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)
		an.newLabel(Titlelabel[i], titleFontSize, 1, {
			color = relation.uiColor.cellTitle
		}):anchor(0.5, 0.5):pos(posOffset + v * 0.5, back1:geth() - 23):add2(back1)

		posOffset = posOffset + v
	end

	local data = {}
	local friendView = an.newScroll(4, 4, 596, 286):add2(back1)
	local h = 42

	friendView:setScrollSize(596, math.max(286, #data * h))

	if #dataList == 0 then
		an.newLabel("当前未添加玩家进入黑名单", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(friendView:getw() / 2, friendView:geth() / 2):add2(friendView, 2)
	end

	local selectPic = nil
	self.cellList = {}

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(596, h)):anchor(0, 0):pos(0, friendView:getScrollSize().height - i * h):add2(friendView)
		local label = v:get("name")
		cell.name = label
		cell.height = h
		cell.width = 596

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(150, h * 0.5)

		label = v:get("level")

		an.newLabel(label, itemFontSize, 1, {
			color = relation.uiColor.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(450, h * 0.5)
		self:enableSelect(cell)

		cell.data = v

		if not next(self.cellList) then
			self:selectPlayer(cell)
		end

		self.cellList[cell.name] = cell

		if v:get("isonline") == 0 then
			relation.setCellColor(cell, relation.uiColor.cellOffline)
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		relation.showInputDialog(self.page, function (name)
			if not name or name == "" then
				main_scene.ui:tip("名称不能为空")

				return
			end

			relation.addBlackList(name)
		end)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/tj.png")
	}):add2(parent):anchor(0.5, 0.5):pos(476, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if self.selectedCell_ then
			relation.removeBlackList(self.selectedCell_.name)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/friend/sc.png")
	}):add2(parent):anchor(0.5, 0.5):pos(576, 36)
end

function relation:clickCheck(time)
	if not g_data.client:checkLastTime("friend", time or 3) then
		main_scene.ui:tip("操作太快, 请重试.", cc.c3b(255, 255, 0))

		return false
	end

	g_data.client:setLastTime("friend", true)

	return true
end

function relation.showInputDialog(type, cb)
	local tip = nil

	if type == "friend" then
		tip = "请输入想要添加好友的玩家名称:"
	elseif type == "attention" then
		tip = "请输入想要添加关注的玩家名称:"
	elseif type == "black" then
		tip = "请输入想要添加黑名单的玩家名称:"
	end

	local titlePng = "pic/common/msgtitle.png"
	local input = nil
	local _, bg = common.msgbox("", {
		okFunc = function ()
			local str = input:getText()

			cb(str)
		end
	})

	an.newLabel(tip, 20, 1):addTo(bg):pos(bg:getw() / 2, 180):anchor(0.5, 0.5)

	input = an.newInput(bg:getw() / 2, 140, 250, 36, 14, {
		checkCLen = true,
		bg = {
			h = 36,
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		}
	}):addTo(bg):anchor(0.5, 0.5)
end

function relation:showAttentionColorMenu()
	if tolua.isnull(self.selectedCell_) then
		return
	end

	local playerName = self.selectedCell_.name
	local cellCfg = {}
	local interval = 20

	for k, v in ipairs(relation.ATTENTION_COLORS) do
		local c = {
			w = 92,
			h = 40,
			idx = v
		}
		local clr = def.colors.get(v, true)
		c.clr = clr

		function c.cellCls()
			sound.playSound("103")

			local n = display.newNode():size(c.w, c.h)

			display.newColorLayer(c.clr):size(c.w, c.h):add2(n)

			return n
		end

		cellCfg[k] = c
	end

	common.createOperationMenu(cellCfg, interval, function (panel, cfg)
		panel:removeSelf()
		self.selectedCell_:getChildByName("color"):removeSelf()
		display.newColorLayer(cfg.clr):pos(500, 8):addto(self.selectedCell_):size(26, 26):setName("color")
		g_data.relation:setAttentionColor(playerName, cfg.idx)
	end):add2(self):pos(324, 48)
end

function relation:showMenu(pos)
	if tolua.isnull(self.selectedCell_) then
		return
	end

	local playerName = self.selectedCell_.name
	local cellCfg = {}
	local interval = 6
	local operation = {}

	if self.page ~= "friend" then
		table.insert(operation, {
			title = "私聊",
			op = function ()
				relation.chatWith(playerName)
			end
		})
	end

	table.insert(operation, {
		title = "查看信息",
		op = function ()
			relation.showInfo(playerName)
		end
	})

	local relation = g_data.relation:getRelationShip(playerName)

	if not relation.isFriend then
		table.insert(operation, {
			title = "添加好友",
			op = function ()
				self.addFriend(playerName)
			end
		})
	else
		table.insert(operation, {
			title = "删除好友",
			op = function ()
				self.removeFriend(playerName)
			end
		})
	end

	if not relation.isAttention then
		table.insert(operation, {
			title = "添加关注",
			op = function ()
				self.addAttention(playerName)
			end
		})
	end

	if not relation.isBlack then
		table.insert(operation, {
			title = "加黑名单",
			op = function ()
				self.addBlackList(playerName)
			end
		})
	end

	table.insert(operation, {
		title = "邀请组队",
		op = function ()
			self.addGroupMember(playerName)
		end
	})

	if #g_data.player.groupMembers == 0 then
		table.insert(operation, {
			title = "申请入队",
			op = function ()
				self.joinGroup(playerName)
			end
		})
	end

	local panel = nil

	for k, v in ipairs(operation) do
		local c = {
			w = 94,
			h = 41,
			idx = k - 1,
			op = v
		}

		function c.cellCls()
			local btn = an.newBtn(res.gettex2("pic/common/btn10.png"), function ()
				sound.playSound("103")
			end, {
				pressImage = res.gettex2("pic/common/btn11.png"),
				label = {
					c.op.title,
					18,
					1,
					{
						color = def.colors.btn20
					}
				}
			}):anchor(0, 0)

			btn:setTouchSwallowEnabled(false)

			return btn
		end

		cellCfg[k] = c
	end

	panel = common.createOperationMenu(cellCfg, interval, function (panel, cfg)
		local _ = cfg.op.op and cfg.op.op()

		panel:removeSelf()
	end, {
		width = 110
	}):add2(self):pos(pos.x, pos.y)
end

function relation.onAddFriendOk(buf, recog)
	if buf then
		main_scene.ui:tip(net.str(buf) .. " 同意成为您的好友")
	end
end

function relation.onAddFriendFail(buf, recog)
	local name = buf and net.str(buf) or "对方"
	local tip = {
		[-2.0] = "不能添加自己为好友",
		[-4.0] = "好友人数达到上限",
		[-1] = name .. "不在线或输入名错误",
		[-3] = name .. "已是好友",
		[-5] = "添加" .. name .. "失败"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.onAddAtt(recog)
	local tip = {
		[0] = "添加关注成功",
		[-4.0] = "关注人数达到上限",
		[-1.0] = "名字为空6",
		[-3.0] = "不能关注自己",
		[-5.0] = "对方已被关注",
		[-2.0] = "对方不在线或输入名错误"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.onAddBlack(recog)
	local tip = {
		[0] = "添加黑名单成功",
		[-4.0] = "黑名单人数达到上限",
		[-1.0] = "名字为空",
		[-3.0] = "不能添加自己",
		[-5.0] = "对方已在黑名单中",
		[-2.0] = "对方不在线或输入名错误"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.onDelFriend(recog)
	local tip = {
		[0] = "好友删除成功",
		[-1.0] = "不能删除自己",
		[-2.0] = "对方不是好友"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.onDelAtt(recog)
	local tip = {
		[0] = "取消关注成功",
		[-1.0] = "对方未被关注"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.onDelBlack(recog)
	local tip = {
		[0] = "取消黑名单成功",
		[-1.0] = "对方未被加入黑名单"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.onUptAttClr(recog)
	local tip = {
		[0] = "设置关注颜色成功",
		[-1.0] = "对方未被关注",
		[-2.0] = "设置关注颜色失败"
	}

	main_scene.ui:tip(tip[recog])
end

function relation.addFriend(name)
	net.send({
		CM_ADD_RELATION_FRIEND
	}, {
		name
	})
end

function relation.addAttention(name)
	net.send({
		CM_ADD_RELATION_ATTENTION
	}, {
		name
	})
end

function relation.addBlackList(name)
	net.send({
		CM_ADD_RELATION_NORMBLACKLIST
	}, {
		name
	})
end

function relation.removeFriend(name)
	net.send({
		CM_DEL_RELATION_FRIEND
	}, {
		name
	})
end

function relation.removeAttention(name)
	net.send({
		CM_DEL_RELATION_ATTENTION
	}, {
		name
	})
end

function relation.removeBlackList(name)
	net.send({
		CM_DEL_RELATION_NORMBLACKLIST
	}, {
		name
	})
end

function relation.addGroupMember(name)
	net.send({
		#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
	}, {
		name
	})
end

function relation.joinGroup(name)
	net.send({
		CM_JOINGROUP
	}, {
		name
	})
	main_scene.ui:tip("申请加入 " .. name .. " 的队伍")
end

function relation.chatWith(name)
	if g_data.relation:getFriend(name) then
		main_scene.ui:showPanel("relation")

		local friendPanel = main_scene.ui.panels.relation

		friendPanel:showContent("friend")
		friendPanel:selectPlayer(name)
	else
		common.changeChatStyle({
			{
				"target",
				name
			},
			{
				"channel",
				"私聊"
			}
		})
	end
end

function relation.showInfo(name)
	net.send({
		CM_QUERYUSERSTATE
	}, {
		name
	})
end

return relation
