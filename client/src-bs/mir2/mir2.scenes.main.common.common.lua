local ByteArray = require("framework.cc.utils.ByteArray")
local itemInfo = import(".itemInfo")
local chatPic = import(".chatPic")
local chatPos = import(".chatPos")
local chatItem = import(".chatItem")
local common = {
	buf = {
		msg = newList()
	},
	getPlayerName = function ()
		return main_scene.ground.player and main_scene.ground.player.info:getName() or g_data.select:getCurName() or ""
	end,
	goldChanged = function (gold)
		if g_data.player.gold < gold then
			main_scene.ui:tip(gold - g_data.player.gold .. " 金币增加.")
		end

		g_data.player:setGold(gold)
		main_scene.ui.console:call("infoBar", "uptGold")

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:uptGold()
		end

		sound.playSound(sound.s_money)
	end,
	ingotChanged = function (gold)
		g_data.player:setIngot(gold)
		main_scene.ui.console:call("infoBar", "uptYb")
	end,
	encodeEmoji = function (str)
		local ret = {}
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

		return table.concat(ret)
	end,
	encodeRich = function (params)
		if params.type == "voice" then
			local str = string.format("{@vi%s|%d|%s}%s", params.url, params.dur, params.expand, params.text)
			str = string.gsub(str, "/", "!")

			return str
		elseif params.type == "pic" then
			local str = string.format("{@pi%s|%d|%s}", params.url, params.size, params.msgID)
			str = string.gsub(str, "/", "!")

			return str
		elseif params.type == "pos" then
			return string.format("{@ps%s|%s|%s|%s}", params.mapID, params.mapTitle, params.x, params.y)
		elseif params.type == "item" then
			return string.format("{@it%s|%s|%s|%s}", params.makeIndex, params.lookID, params.name, params.weight)
		elseif params.type == "emoji" then
			return string.format("{@em%03d}", params.id)
		end
	end,
	decodeMsg = function (str, msg)
		if msg and msg.ident == SM_WHISPER then
			local pos = string.find(str, "=>")

			if pos then
				local addstr = ""

				if msg.series == 0 then
					addstr = string.format("[%d级]", msg.tag)
				else
					addstr = string.format("[%d级%d+]", msg.tag, msg.series)
				end

				str = string.sub(str, 1, pos - 1) .. addstr .. string.sub(str, pos, #str)
			end
		end

		local ret = {}

		while true do
			local startMark = string.find(str, "{")
			local endMark = string.find(str, "}")

			if startMark and endMark and startMark < endMark then
				local frontStr = string.sub(str, 1, endMark)
				local lastStartMark = startMark

				while true do
					lastStartMark = string.find(frontStr, "{", lastStartMark + 1)

					if lastStartMark then
						startMark = lastStartMark
					else
						break
					end
				end

				if startMark > 1 then
					ret[#ret + 1] = string.sub(frontStr, 1, startMark - 1)
				end

				ret[#ret + 1] = {
					string.sub(frontStr, startMark, endMark)
				}
				str = string.sub(str, endMark + 1, #str)
			else
				ret[#ret + 1] = str

				break
			end
		end

		local function parseRichMsg(str)
			if #str < 6 then
				return str
			end

			local msgType = string.sub(str, 2, 4)
			local msgData = string.sub(str, 5, #str - 1)

			if msgType == "@ej" and #msgData == 8 then
				msgData = string.gsub(msgData, "!", "/")

				return {
					type = "emojiConvert",
					emoji = crypto.decodeBase64(msgData)
				}
			elseif msgType == "@em" and #msgData == 3 then
				return {
					type = "emoji",
					emoji = tonumber(msgData) or 0
				}
			elseif msgType == "@vi" then
				msgData = string.gsub(msgData, "!", "/")
				local array = string.split(msgData, "|")

				if #array >= 3 then
					return {
						type = "voice",
						url = array[1],
						dur = array[2],
						msgID = array[3]
					}
				end
			elseif msgType == "@pi" then
				msgData = string.gsub(msgData, "!", "/")
				local array = string.split(msgData, "|")

				if #array >= 3 then
					return {
						type = "pic",
						url = array[1],
						size = array[2],
						msgID = array[3]
					}
				end
			elseif msgType == "@ps" then
				local array = string.split(msgData, "|")

				if #array >= 4 then
					return {
						type = "pos",
						mapID = array[1],
						mapTitle = array[2],
						x = tonumber(array[3]) or 0,
						y = tonumber(array[4]) or 0
					}
				end
			elseif msgType == "@it" then
				local array = string.split(msgData, "|")

				if #array >= 4 then
					return {
						type = "item",
						makeIndex = tonumber(array[1]) or 0,
						lookID = array[2] or "",
						name = array[3] or "",
						weight = tonumber(array[4]) or 0
					}
				end
			end

			return str
		end

		for i, v in ipairs(ret) do
			if type(v) == "table" then
				ret[i] = parseRichMsg(v[1])
			end
		end

		return ret
	end
}

function common.createChatLabel(msg, touch)
	local label = an.newLabelM(msg.strWidth or 150, msg.fontSize or 14, 1, {
		bufferChannel = 2
	})
	local user = msg.user or common.getPlayerName()

	for i, v in ipairs(msg.data) do
		if v.type == "emoji" then
			label:addEmoji(res.gettex2("pic/emoji/" .. v.emoji .. ".png"))
		elseif v.type == "emojiConvert" then
			label:addEmojiForConvert(v.emoji)
		elseif v.type == "voice" then
			local bgkey = msg.channel == "私聊" and (msg.fromClient and "私聊self" or "私聊") or msg.channel

			label:addVoice(bgkey, v.dur, v.msgID, v.state, v.readed, touch and function ()
				voice.play(user, v.msgID, msg.channel, v.url, v.dur)

				v.readed = true
			end)
		elseif v.type == "pic" then
			label:addNode(chatPic.new(2, label, v, user, msg.channel, not touch), 2, v.msgID)
		elseif v.type == "pos" then
			label:addNode(chatPos.new(2, label, v, user, not touch), 2)
		elseif v.type == "item" then
			label:addNode(chatItem.new(2, label, v, not touch), 2)
		elseif type(v) == "table" then
			label:addLabel(v.str, v.fontColor, v.bgColor, v.strokeColor, v.clickCallback, v.params)
		else
			label:addLabel(v)
		end
	end

	local itemWidth = msg.strWidth

	if #label.lines == 1 then
		local l = label.lines[1]
		local max = 0

		for k, v in ipairs(l:getChildren()) do
			local w = v:getPosition() + v:getw()

			if max < w then
				max = w
			end
		end

		itemWidth = max

		label:setContentSize(itemWidth, label:geth())
	end

	return label
end

function common.addMsg(text, color, bgColor, fromClient, user, netMsg, buf, bufLen)
	common.buf.msg.pushBack({
		text,
		color,
		bgColor,
		fromClient,
		user,
		netMsg,
		buf,
		bufLen
	})
end

function common.updateAddMsg(text, color, bgColor, fromClient, user, netMsg, buf, bufLen)
	local roleid = nil

	if type(user) == "number" then
		roleid = user
		user = nil
	end

	local data = common.decodeMsg(text, netMsg)

	if not data then
		return
	end

	local msg = g_data.chat:addMsg(data, color, bgColor, fromClient, user, netMsg and netMsg.ident)

	if common.getPlayerName() == msg.user then
		g_data.chat:setVoiceReaded(msg)
		g_data.chat:setPicLoaded(msg)
	else
		if g_data.setting.chat.autoLoadVoice.enable then
			for i, v in ipairs(data) do
				if v.type == "voice" then
					voice.download(v.msgID, msg.channel, voice.filename(msg.user, v.msgID), v.url)
				end
			end
		end

		if g_data.setting.chat.autoPlayVoice[msg.channel] then
			for i, v in ipairs(data) do
				if v.type == "voice" then
					voice.autoPlay(msg.user, v.msgID, msg.channel, v.url, v.dur)
				end
			end
		end
	end

	main_scene.ui.console:call("chat", "addMsg", msg)

	if main_scene.ui.panels.chat then
		main_scene.ui.panels.chat:addMsg(msg)
	end

	if msg.channel == "行会" then
		-- Nothing
	end

	if msg.channel == "附近" then
		local role = nil

		if roleid then
			role = main_scene.ground.map:findRole(roleid)
		else
			role = main_scene.ground.map:findHeroWithName(msg.user)
		end

		if role then
			role.info:say(msg)
		end
	end
end

function common.getAllChatLabelM(channel, noNear)
	local ret = {}

	if main_scene.ui.console:get("chat") then
		ret[#ret + 1] = main_scene.ui.console:get("chat").scroll.labelM
	end

	if main_scene.ui.panels.chat then
		ret[#ret + 1] = main_scene.ui.panels.chat.scroll.labelM
	end

	if channel == "行会" and not noNear and main_scene.ui.panels.guild and main_scene.ui.panels.guild:isChatInterface() then
		ret[#ret + 1] = main_scene.ui.panels.guild.content.labelM
	end

	if channel == "附近" and not noNear then
		for k, v in pairs(main_scene.ground.map.heros) do
			if v.info.sayLabel then
				ret[#ret + 1] = v.info.sayLabel
			end
		end
	end

	if channel == "私聊" then
		local relationPnl = main_scene.ui.panels.relation

		if relationPnl and relationPnl.page == "friend" then
			local clms = relationPnl:getChatLabelMs()

			for k, v in ipairs(clms) do
				table.insert(ret, v)
			end
		end
	end

	return ret
end

function common.uptVoiceMsgState(msgID, channel, state)
	g_data.chat:uptVoiceMsgState(msgID, state, state == "start")

	local checks = common.getAllChatLabelM(channel)

	for i, v in ipairs(checks) do
		local voiceBubble = v:findVoiceBubbleForMsgID(msgID)

		if voiceBubble then
			voiceBubble:setState(state)

			if state == "start" then
				voiceBubble:hideUnread()
			end
		end
	end
end

function common.uptPicMsgState(msgID, channel, state, path, user)
	g_data.chat:uptPicMsgState(msgID, state)

	local checks = common.getAllChatLabelM(channel)

	for i, v in ipairs(checks) do
		local node = v:findNodeForClassNameAndTag("chatPic", msgID)

		if node then
			node:setState(state, path)
		end
	end

	if state == "loadOk" then
		main_scene.ui:hidePanel("screenshotLook")
		main_scene.ui:showPanel("screenshotLook", {
			user = user,
			diskpath = path
		})
	end
end

function common.uptItemMsgData(data)
	g_data.chat:uptItemMsgData(data)

	if g_data.client.lastQueryChatItem then
		if g_data.client.lastQueryChatItem.makeIndex == data:get("makeIndex") then
			itemInfo.show(data, cc.p(g_data.client.lastQueryChatItem.x, g_data.client.lastQueryChatItem.y))
		end

		g_data.client:setLastQueryChatItem()
	end
end

function common.changeChatStyle(array)
	for i, v in ipairs(array) do
		g_data.chat:setStyle(v[1], v[2])
	end

	main_scene.ui.console:call("chat", "loadInput")

	if main_scene.ui.panels.chat then
		main_scene.ui.panels.chat:loadInput()
	end
end

function common.getItemDatasFromInputContent(content)
	local ret = nil
	local tmpstr = ""

	for i, v in ipairs(content) do
		if type(v) == "table" then
			if v.type == "label" then
				ret = ret or {}

				v.params:set("pos", ycFunction:getStringLenWithAscii(tmpstr))

				ret[#ret + 1] = v
				tmpstr = tmpstr .. "[" .. v.params:get("name") .. "]"
			elseif v.type == "emoji" then
				tmpstr = tmpstr .. string.format("{@em%03d}", v.id)
			end
		elseif type(v) == "string" then
			tmpstr = tmpstr .. v
		end
	end

	return ret
end

function common.say(data)
	if g_data.chat.style.channel == "私聊" and g_data.chat.style.target == "" then
		an.newMsgbox("未设置私聊对象.")

		return
	end

	local function filterText(str, first)
		if first and string.find(str, "@") == 1 and g_data.chat.style.channel == "附近" then
			return str
		end

		return def.wordfilter.run(str)
	end

	local hasRich, str = nil

	if type(data) == "string" then
		str = filterText(data, true)
	else
		str = ""

		for i, v in ipairs(data) do
			if type(v) == "string" then
				str = str .. filterText(v, i == 1)
			else
				str = str .. v[1]
				hasRich = true
			end
		end
	end

	if str == "" then
		return
	end

	str = g_data.chat:getSayText(str)

	net.send({
		CM_SAY,
		param = hasRich and 1
	}, {
		common.encodeEmoji(str)
	})

	if g_data.chat.style.channel == "私聊" then
		local playerName = common.getPlayerName()

		common.addMsg(str, 180, 255, true, playerName)
		g_data.relation:recordChat(g_data.chat.style.target, string.sub(str, string.find(str, " ") + 1), playerName)
	end

	return true
end

function common.update(dt)
	local cnt = 0
	local loopMaxLoad = 5

	while cnt < loopMaxLoad and not common.buf.msg.isEmpty() do
		common.updateAddMsg(unpack(common.buf.msg.popFront()))

		cnt = cnt + 1
	end
end

function common.msgbox(text, params)
	params = params or {}
	local msgbox = nil
	msgbox = an.newMsgbox(text or "", function (idx)
		if idx == 0 then
			if params.cancelFunc then
				params.cancelFunc()
			end

			msgbox:removeSelf()
		elseif idx == 1 and (not params.okFunc or params.okFunc and not params.okFunc()) then
			msgbox:removeSelf()
		end
	end, {
		hasCancel = true,
		manualRemove = true,
		disableScroll = not params.scroll,
		input = params.input,
		title = params.title,
		center = params.center
	})

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")

		if params.closeFunc then
			params.closeFunc()
		end

		msgbox:removeSelf()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(msgbox.bg):pos(msgbox.bg:getw() - 5, msgbox.bg:geth() - 5):anchor(1, 1)

	return msgbox, msgbox.bg
end

local defConfig = {
	{
		size = 20,
		file = {
			n = "pic/common/btn110.png",
			s = "pic/common/btn111.png"
		},
		lc = {
			n = def.colors.btn110,
			s = def.colors.btn111
		},
		sc = {
			n = def.colors.btn110s,
			s = def.colors.btn111s
		}
	},
	{
		size = 18,
		file = {
			n = "pic/common/btn60.png",
			s = "pic/common/btn61.png"
		},
		lc = {
			n = def.colors.btn30,
			s = def.colors.btn31
		},
		sc = {
			n = def.colors.btn30s,
			s = def.colors.btn31s
		}
	},
	{
		size = 20,
		file = {
			n = "pic/common/btn120.png",
			s = "pic/common/btn121.png"
		},
		lc = {
			n = def.colors.btn110,
			s = def.colors.btn111
		},
		sc = {
			n = def.colors.btn110s,
			s = def.colors.btn111s
		}
	},
	[10] = {
		size = 18,
		file = {
			n = "pic/common/btn20.png",
			s = "pic/common/btn21.png"
		},
		lc = {
			n = def.colors.btn20,
			s = def.colors.btn20
		},
		sc = {
			n = def.colors.btn20s,
			s = def.colors.btn20
		}
	}
}

function common.tabs(parent, labels, callback, params)
	local hasTest = false
	local isSpr = false

	if labels then
		if labels.strs and #labels.strs ~= 0 then
			hasTest = true
		elseif labels.sprs and #labels.sprs ~= 0 then
			hasTest = true
			isSpr = true
		end
	end

	if not hasTest then
		p2("other", "[Create tabs error]: tab has no text!")

		return
	end

	if not callback then
		p2("other", "Tabs create without callback")
	end

	params = params or {}
	local config = params.tabTp and defConfig[params.tabTp] or defConfig[1]
	local normalImg, selectImg, normalLabelColor, selectLabelColor, normalStrokeColor, selectStrokeColor, labelSize, tabPosx, tabPosy, tabOffset, tabDir, tabAnchor, tabDefaultSelect, tabManualClick = nil
	normalImg = params.file and params.file.normal or config.file.n
	selectImg = params.file and params.file.select or config.file.s
	normalLabelColor = labels.lc and labels.lc.normal or config.lc.n
	selectLabelColor = labels.lc and labels.lc.select or config.lc.s
	normalStrokeColor = labels.sc and labels.sc.normal or config.sc.n
	selectStrokeColor = labels.sc and labels.sc.select or config.sc.s
	labelSize = labels.size or config.size
	tabPosx = params.pos and params.pos.x or 0
	tabPosy = params.pos and params.pos.y or 0
	tabOffset = params.pos and params.pos.offset or 90
	tabDir = params.pos and params.pos.dir or 0
	tabAnchor = params.pos and params.pos.anchor or cc.p(0, 1)
	tabDefaultSelect = params.default and params.default.var or 1
	tabManualClick = params.default and params.default.manual or false
	local tabs = {}

	function tabs.click(var, manualClk)
		local btn = type(var) == "number" and tabs.btns[var] or var

		if params.time then
			local nowtime = socket.gettime()

			for i, v in ipairs(tabs.btns) do
				if v == btn then
					if not v.time or params.time <= nowtime - v.time then
						v.time = nowtime

						break
					end

					common.addMsg(string.format("操作频繁,请间隔%d秒再试.", params.time), display.COLOR_WHITE, display.COLOR_RED)

					if btn.state then
						btn:select()
						btn:zorder(1)

						if not isSpr then
							btn.label:setColor(selectLabelColor)
							btn.label:setStrokeColor(selectStrokeColor)
						end
					else
						btn:unselect()
						btn:zorder(0)

						if not isSpr then
							btn.label:setColor(normalLabelColor)
							btn.label:setStrokeColor(normalStrokeColor)
						end
					end


					break
				end
			end
		end

		for k, v in ipairs(tabs.btns) do
			if v == btn then
				v:select()
				v:zorder(1)

				if not isSpr then
					v.label:setColor(selectLabelColor)
					v.label:setStrokeColor(selectStrokeColor)
				end

				if (params.repeatClk or not v.state) and not manualClk and callback then
					callback(k, v)
				end

				v.state = true
			else
				v:unselect()
				v:zorder(0)

				if not isSpr then
					v.label:setColor(normalLabelColor)
					v.label:setStrokeColor(normalStrokeColor)
				end

				v.state = false
			end
		end
	end

	tabs.btns = {}

	for i = 1, isSpr and #labels.sprs or #labels.strs do
		local textLabel, textSpr = nil

		if isSpr then
			textSpr = res.gettex2(labels.sprs[i])
		else
			textLabel = {
				labels.strs[i] or "",
				labelSize,
				1,
				{
					color = normalLabelColor
				}
			}
		end

		local x = tabDir == 0 and tabPosx or tabPosx + (i - 1) * tabOffset
		local y = tabDir == 0 and tabPosy - (i - 1) * tabOffset or tabPosy
		tabs.btns[i] = an.newBtn(res.gettex2(normalImg), function (btn)
			sound.playSound("103")
			tabs.click(btn)
		end, {
			manual = true,
			select = {
				res.gettex2(selectImg)
			},
			label = textLabel,
			sprite = textSpr,
			labelOffset = {
				x = labels.ox or 0,
				y = labels.oy or 0
			},
			spriteOffset = {
				x = labels.ox or 0,
				y = labels.oy or 0
			},
			scale = params.scale or 1
		}):addTo(parent or display.getRunningScene()):pos(x, y):anchor(tabAnchor.x, tabAnchor.y)

		if params.datas and params.datas[i] then
			tabs.btns[i].data = params.datas[i]
		end

		if i == tabDefaultSelect then
			tabs.click(tabs.btns[i], tabManualClick)
		end
	end

	return tabs
end

function common.showBosonResult(msg, buf, bufLen)
	if getRecordSize("TMessageBodyWL") < bufLen then
		local wl, buf, bufLen = net.record("TMessageBodyWL", buf, bufLen)
		local npcSay = net.str(buf)
		local diceCount = msg.param
		local result = {
			[#result + 1] = Lobyte(Loword(wl:get("param1")))
		}
		local tmpValue = Hibyte(Loword(wl:get("param1")))

		if tmpValue > 0 then
			result[#result + 1] = tmpValue
		end

		tmpValue = Lobyte(Hiword(wl:get("param1")))

		if tmpValue > 0 then
			result[#result + 1] = tmpValue
		end

		tmpValue = Hibyte(Hiword(wl:get("param1")))

		if tmpValue > 0 then
			result[#result + 1] = tmpValue
		end

		local node = display.newNode()

		node:anchor(0.5, 0.5):pos(display.cx, display.cy):addto(display.getRunningScene(), an.z.msgbox)
		node:setTouchEnabled(true)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ()
		end)

		local bg = res.get2("pic/notice/bg2.png"):anchor(0, 0):addto(node)

		node:size(bg:getw(), bg:geth())

		local disWidth = 50
		local beginX = bg:getw() * 0.5
		beginX = beginX - (#result - 1) * disWidth / 2

		for i, v in ipairs(result) do
			local pic = res.get("items", 383):anchor(0.5, 0.5):pos(beginX + (i - 1) * disWidth, bg:geth() * 0.5):add2(bg)

			pic:runs({
				cc.DelayTime:create(0.6),
				cc.Animate:create(common.getrandani("items", 383, 386, 0.65, 6)),
				cc.CallFunc:create(function ()
					pic:setTex(res.gettex("items", 375 + result[i]))
				end),
				cc.DelayTime:create(2),
				cc.CallFunc:create(function ()
					net.send({
						CM_MERCHANTDLGSELECT,
						recog = msg.recog
					}, {
						npcSay
					})
					node:removeSelf()
				end)
			})
		end
	end
end

function common.getrandani(imgid, beginidx, endidx, delay, total)
	local frames = {}

	for index = 1, total do
		local curIndex = math.random(beginidx, endidx)
		local frame = res.getframe(imgid, curIndex)

		if frame then
			frames[#frames + 1] = frame
		else
			break
		end
	end

	if #frames > 0 then
		local animation = cc.Animation:createWithSpriteFrames(frames, delay)

		animation:retain()

		return animation
	else
		print("frames cnt == 0")
	end
end

function common.setLockEquipState(msg, buf, bufLen)
	g_data.equip:setServerUnlockTime(msg.recog)

	if not g_data.client.lastTime.equipUnlockTime then
		g_data.client:setLastTime("equipUnlockTime", true)
	end

	local str, state = nil

	if msg.param == 1 then
		str = "您穿戴的装备已锁定，点击装备栏右上角的“密宝”按钮可进行解锁"
		state = false
	elseif msg.param == 2 then
		str = "您穿戴的装备已解除锁定，再点击“密宝”按钮可对装备进行锁定"
		state = true
	end

	if str then
		common.addMsg(str and str or "", display.COLOR_WHITE, display.COLOR_RED)
		g_data.equip:setLock(msg.param)

		if main_scene.ui.panels.equip then
			main_scene.ui.panels.equip:setSecurityState(state)
		end
	end
end

function common.setBindEquipState(msg, buf, bufLen)
	local str = ""
	local unlockTime = nil

	if msg.param < 9 then
		main_scene.ui.console:call("hp", "setEquipLockVisible", true)

		if msg.recog > 0 then
			local tt, nn, ss = nil
			unLockTime = g_data.equip.lockTime - msg.recog
			tt = math.floor(unLockTime / 1000)
			nn = math.floor(tt / 60)
			ss = tt % 60

			if tt <= 0 then
				-- Nothing
			end

			str = nn > 0 and nn .. "分" or ""
			str = str .. (ss > 0 and ss .. "秒" or "")
		end
	end

	local function addMsg(str)
		common.addMsg(str and str or "", display.COLOR_WHITE, display.COLOR_RED)
	end

	if msg.param == 0 then
		if str ~= 0 then
			addMsg("你的装备已经被密宝绑定，" .. str .. "后点击血球右下角的密宝按钮进行验证")
		end
	elseif msg.param == 1 then
		if str ~= 0 then
			addMsg(str .. "后可点击游戏界面右下角的密宝按钮，进行验证成功后，方可使用此功能")
		end
	elseif msg.param == 2 then
		addMsg("装备解绑失败，游戏中断")
	elseif msg.param == 3 then
		addMsg("装备成功解除绑定")
		main_scene.ui.console:call("hp", "setEquipLockVisible", false)
	elseif msg.param == 4 then
		addMsg("装备解绑失败，密宝时间偏差，请到网页上矫正密宝时间")
	elseif msg.param == 5 then
		addMsg("服务器忙，请稍后再试...")
	elseif msg.param == 6 then
		addMsg("请重新登录后，再来进行此操作")
	elseif checkIn(msg.param, 8, 18) or PPW_SM_EQUIP_SPLIT == msg.param then
		if msg.series > 0 then
			if msg.series > 10000 then
				g_data.security:setEquipBit(msg.series)
			end

			if msg.param == 8 then
				addMsg("你的装备已经被密宝绑定，请点击血球右下角的密宝按钮进行验证")
				main_scene.ui.console:call("hp", "setEquipLockVisible", true)
			elseif msg.param == 9 then
				if g_data.security.equipBit and not main_scene.ui.panels.security then
					main_scene.ui:togglePanel("security", {
						tag = 1
					})
				end
			elseif msg.param == 10 then
				-- Nothing
			elseif msg.param == 11 then
				-- Nothing
			elseif msg.param == 12 then
				-- Nothing
			elseif msg.param == 13 then
				-- Nothing
			elseif msg.param == 14 then
				-- Nothing
			elseif msg.param == 15 then
				-- Nothing
			elseif msg.param == 16 then
				-- Nothing
			elseif msg.param == 17 then
				-- Nothing
			elseif msg.param == 18 then
				-- Nothing
			elseif PPW_SM_EQUIP_SPLIT == msg.param then
				-- Nothing
			end
		end
	else
		addMsg("装备解绑失败，请稍后再试...")
	end
end

function common.enablePopStyle(node, swallowTouch, cbFunc, params)
	params = params or {
		casecade = true
	}
	local casecade = params.casecade
	local listener = cc.EventListenerTouchOneByOne:create()

	if swallowTouch then
		listener:setSwallowTouches(true)
	end

	listener:registerScriptHandler(function (touch, event)
		local pos = touch:getLocation()
		local hited = node:hitTest(pos, casecade)

		if params.reverse then
			hited = not hited
		end

		if not hited then
			if cbFunc then
				cbFunc()
			elseif not swallowTouch then
				node:removeSelf()
			end

			if swallowTouch then
				return true
			end
		end
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function (touch, event)
		local pos = touch:getLocation()

		if not node:hitTest(pos, casecade) and swallowTouch then
			node:removeSelf()
		end
	end, cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = node:getEventDispatcher()

	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

	node.popStyleListener__ = listener
end

function common.unablePopStyle(node)
	if node.popStyleListener__ then
		local eventDispatcher = node:getEventDispatcher()

		eventDispatcher:removeEventListener(node.popStyleListener__)

		node.popStyleListener__ = nil
	end
end

function common.createOperationMenu(menuList, interval, clickCB, params)
	local panel = nil
	params = params or {}
	local itemCnt = #menuList
	local view = display.newNode()
	local preY = interval
	local selectPic = nil

	for k = itemCnt, 1, -1 do
		local v = menuList[k]
		local offX = v.w / 2
		local cell = display.newNode():pos(0, preY):size(v.w, v.h):add2(view):anchor(0.5, 0)
		preY = preY + v.h + interval
		local cellContent = v.cellCls():add2(cell):anchor(0.5, 0.5):pos(v.w / 2, v.h / 2)
		cell.cellData = v

		cell:setTouchEnabled(true)
		cell:setTouchSwallowEnabled(false)
		cell:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y
				cell.offsetBeginX = event.x

				if selectPic then
					selectPic:removeSelf()

					selectPic = nil
				end

				selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(v.w + interval, cell.cellData.h + interval)):anchor(0, 0):add2(cell):pos(-interval / 2, -interval / 2)

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY
				local offsetX = event.x - cell.offsetBeginX

				if math.abs(offsetY) <= 7 and math.abs(offsetX) <= 7 then
					clickCB(panel, cell.cellData)
				end
			end
		end)
	end

	local viewRect = view:getCascadeBoundingBox()
	viewRect.height = viewRect.height + interval

	if params.width then
		viewRect.width = params.width
	else
		viewRect.width = viewRect.width + interval
	end

	view:pos(viewRect.width / 2, 0)

	if params.scroll then
		panel = display.newScale9Sprite(res.getframe2(params.bgTex or "pic/scale/scale16.png"), 0, 0, cc.size(params.scroll.w, params.scroll.h)):anchor(0, 0)
		local scroll = an.newScroll(0, 0, params.scroll.w, params.scroll.h, {
			labelM = {
				18,
				1
			}
		}):add2(panel)

		scroll:setScrollSize(viewRect.width, viewRect.height)
		view:add2(scroll):pos(params.scroll.w / 2, 0)
	else
		panel = display.newScale9Sprite(res.getframe2(params and params.bgTex or "pic/scale/scale16.png"), 0, 0, cc.size(viewRect.width, viewRect.height + interval)):anchor(0, 0)

		view:add2(panel)
		panel:setTouchEnabled(true)
	end

	if not params.disPopStyle then
		common.enablePopStyle(panel, true, nil, {
			cascade = false
		})
	end

	if params.drag then
		panel:enableClick(function ()
		end, {
			support = "drag",
			call_drag_end = function (x, y)
				print(panel:getPosition())
			end
		})
	end

	return panel
end

function common.chatChannelChoose(removeSelf)
	local texts = {
		"附近",
		"私聊",
		"喊话",
		"组队",
		"战队",
		"行会",
		"千里传音"
	}
	local filenames = {
		"fujin",
		"siliao",
		"hanhua",
		"bz",
		"zhandui",
		"hanghui",
		"ql"
	}
	local space = 45
	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale21.png")):size(80, #texts * space + 10)

	common.enablePopStyle(bg, true)

	for i, v in ipairs(texts) do
		an.newBtn(res.gettex2("pic/common/btn50.png"), function ()
			common.changeChatStyle({
				{
					"channel",
					v
				}
			})

			if removeSelf then
				bg:removeSelf()
			end
		end, {
			sprite = res.gettex2("pic/panels/chat/" .. filenames[i] .. ".png"),
			pressImage = res.gettex2("pic/common/btn51.png")
		}):add2(bg):pos(bg:getw() / 2, 5 + (i - 0.5) * space)
	end

	return bg
end

function common.getMinimapTexture(mapid, func)
	local minimapID = def.map.getMinimapID(mapid)

	if not minimapID then
		func()

		return
	end

	local tex, err = res.gettex2(minimapID .. ".png", "data/mmap")

	if not err then
		func(tex)

		return
	end

	tex = cache.getMinimap(minimapID)

	if tex then
		func(tex)

		return
	end

	if makeMinimap(mapid, cache.minimapFullPath(minimapID)) then
		scheduler.performWithDelayGlobal(function ()
			func(cache.getMinimap(minimapID))
		end, 0)
	else
		func()
	end
end

common.allChatChannels = {
	["附近"] = {
		2,
		"允许接收公聊信息",
		"拒绝接收公聊信息"
	},
	["喊话"] = {
		3,
		"允许接收(黄颜色字体)喊话",
		"拒绝接收(黄颜色字体)喊话"
	},
	["行会"] = {
		4,
		"允许接收行会喊话信息",
		"拒绝接收行会喊话信息"
	},
	["私聊"] = {
		1,
		"允许接收私聊信息",
		"拒绝接收私聊信息"
	},
	["组队"] = {
		"允许接收组队信息",
		"拒绝接收组队信息",
		localSave = true
	},
	["战队"] = {
		"允许接收战队信息",
		"拒绝接收战队信息",
		localSave = true
	},
	["系统"] = {}
}

function common.getAllOpenChatChannel()
	local ret = {}

	for k, v in pairs(common.allChatChannels) do
		if common.getChatChannelIsOpen(k) then
			ret[#ret + 1] = k
		end
	end

	return ret
end

function common.getChatChannelIsOpen(channel)
	if channel == "系统" then
		return true
	end

	local config = common.allChatChannels[channel]

	if not config then
		return
	end

	if config.localSave then
		return g_data.setting.chat.opens[channel]
	end

	return ycFunction:band(g_data.chat.shieldMask, ycFunction:lshift(1, config[1])) == 0
end

function common.setChatChannelIsOpen(channel, b, donotRefersh)
	if channel == "系统" then
		return
	end

	local config = common.allChatChannels[channel]

	if not config then
		return
	end

	if config.localSave then
		g_data.setting.chat.opens[channel] = b

		cache.saveSetting(common.getPlayerName(), "chat")
		common.addMsg(config[b and 1 or 2], b and 219 or 249, 255, true)
	else
		local value = nil

		if b then
			value = g_data.chat.shieldMask - ycFunction:lshift(1, config[1])
		else
			value = g_data.chat.shieldMask + ycFunction:lshift(1, config[1])
		end

		g_data.chat:setShieldMask(value)
		common.addMsg(config[b and 2 or 3], b and 219 or 249, 255, true)
		net.send({
			CM_SWITCH_LISTEN,
			recog = b and 0 or 1,
			param = config[1]
		})
	end

	common.refershChatContent()
end

function common.refershChatContent()
	main_scene.ui.console:call("chat", "loadScroll")

	if main_scene.ui.panels.chat then
		main_scene.ui.panels.chat:loadLeftContent()
	end
end

function common.checkAmulet(force)
	local state = g_data.equip:checkAmulet()

	if not state then
		if g_data.client:checkLastTime("common.checkAmulet", 0.5) then
			state = g_data.bag:equipAmulet(force)

			if state then
				g_data.client:setLastTime("common.checkAmulet", true)
			end
		else
			state = true
		end
	end

	return state
end

function common.gotoLogin(params)
	net.close()
	game.gotoscene("login", params, "fade", 0.5, display.COLOR_BLACK)
end

function common.backHome()
	if g_data.client:checkLastTime("common.checkAmulet", 5) then
		g_data.client:setLastTime("common.checkAmulet", true)
		net.send({
			CM_CLICK_BACKHOME
		})
		main_scene.ui.console.autoRat:stop()
		main_scene.ui.console.controller.autoFindPath:multiMapPathStop()
	else
		main_scene.ui:tip("操作太快.")
	end
end

return common
