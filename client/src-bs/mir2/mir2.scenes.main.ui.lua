local current = ...
local common = import(".common.common")
local settingLogic = import(".common.settingLogic")
local panelDelegate = import(".panel._delegate")

local draw = rawget(_G, "draw")
if type(draw) ~= "table" then
	draw = {}
	_G.draw = draw
end

draw.ufact = draw.ufact or {}
draw.ufact.quick_itembg = draw.ufact.quick_itembg or {}
draw.ufact.UseItem = draw.ufact.UseItem or function ()
	return nil
end

local mainui = class("mainui", function ()
	return display.newNode()
end)

table.merge(mainui, {
	z = {
		leftTopTip = 3,
		replaceAsk = 7,
		diyBtn = 6,
		chatChannel = 9,
		textInfo = 2,
		voiceTip = 5,
		centerTopTip = 4,
		focus = 1,
		detail = 8
	}
})

function mainui:ctor()
	self.panels = {}
	self.customs = {}
	self.leftTopTip = import(".common.leftTopTip", current).new():add2(self, self.z.leftTopTip)
	self.centerTopTip = import(".common.centerTopTip", current).new():add2(self, self.z.centerTopTip)

	self:loadConsole()

	self.notice = import(".common.notice", current).new():add2(self, self.z.focus)
end

function mainui:onEnter()
end

function mainui:onExit()
end

function mainui:loadConsole()
	if self.console then
		self.console:removeSelf()
	end

	self.console = import(".console.console", current).new():addTo(self)
end

function mainui:showPanel(name, ...)
		
	if self.panels[name] then
		return
	end
	
	if name == "npc" then
		if self.panels["chat"] then
			if self.panels["chat"].input.keyboard then
				self.panels["chat"].input.keyboard:stopInput()
			end
			self:hidePanel("chat")
		end
	end
	
	local formName = name

	if WIN32_OPERATE and name == "equip" then
		formName = name .. "Pc"
	end

	if IS_PLAYER_DEBUG then
		package.loaded["mir2.scenes.main.panel." .. name] = nil
		package.loaded["mir2.scenes.main.panel." .. formName] = nil
	end

	local panel = import(".panel." .. formName, current).new(...):addTo(self, self.z.focus)

	panelDelegate.extend(panel, name, self)

	if not main_scene.ui.isChoseItem then
		if self.lastFocus then
			self.lastFocus:setLocalZOrder(0)
		end

		self.lastFocus = panel
	else
		panel:setLocalZOrder(0)
	end

	self.panels[name] = panel

	main_scene.ground.helper:openPanel(name)
	
	local unableClick = function(b) 
		for k, v in pairs(draw.ufact.quick_itembg or {}) do
			if v.cbox then
				v.cbox:setEnabled(b)
			end
		end
	end
	
	local isClick = true
	
	for k, v in pairs(self.panels) do
		if k ~= "assist" and k ~= "equipOther" and k ~= "chat" and k ~= "minimap" then		
			isClick = false						
			break
		end
	end
	
	unableClick(isClick)
	
	return panel
end

function mainui:hidePanel(name)
	
	if not self.panels[name] then
		return
	end

	if self.lastFocus == self.panels[name] then
		self.lastFocus = nil
	end

	self.panels[name]:removeSelf()

	self.panels[name] = nil
	
	--dump(self.panels)
	local unableClick = function(b) 
		for k, v in pairs(draw.ufact.quick_itembg or {}) do
			if v.cbox then
				v.cbox:setEnabled(b)
			end
		end
	end
	
	local isClick = true
	
	for k, v in pairs(self.panels) do
		if k ~= "assist" and k ~= "equipOther" and k ~= "chat" and k ~= "minimap" then
			isClick = false						
			break
		end
	end
	
	unableClick(isClick)
	
end

function mainui:togglePanel(name, params)
	if self.panels[name] then
		self.panels[name]:hidePanel()
	else
		self:showPanel(name, params)
	end
end

function mainui:hideAll()
	for k, v in pairs(self.panels) do
		v:removeSelf()
	end

	self.panels = {}
	self.lastFocus = nil
end

function mainui:tip(...)
	self.leftTopTip:show(...)
end

function mainui:update(dt)
	common.update(dt)
	self.console:update(dt)
	settingLogic.update(dt)

	local player = main_scene.ground.player

	if player and self.panels.npc and self.panels.npc.x and self.panels.npc.y and (math.abs(self.panels.npc.x - player.x) > 8 or math.abs(self.panels.npc.y - player.y) > 8) then
		self:hidePanel("npc")
	end

	if player and self.panels.storage and self.panels.storage.x and self.panels.storage.y and (math.abs(self.panels.storage.x - player.x) > 8 or math.abs(self.panels.storage.y - player.y) > 8) then
		self:hidePanel("storage")
	end
end

function mainui:checkUsedItemforStopAutoRat(itemdata)
	if itemdata then
		local itemName = itemdata.getVar("name")

		if type(itemName) == "string" then
			for k, v in pairs({
				"盟重传送石",
				"比奇传送石"
			}) do
				if string.find(itemName, v) then
					main_scene.ui.console.autoRat:stop()
				end
			end
		end
	end
end

function mainui:processMsg(msg, buf, bufLen)
	if not msg then
		return
	end

	local function tip(str, func)
		local msgbox = an.newMsgbox("", func)

		an.newLabel(str, 20, 1, {
			color = def.colors.labelGray
		}):addTo(msgbox):pos(msgbox:centerPos()):anchor(0.5, 0.5)
	end

	local function PileUpItem(isHero)
		if not g_data.player.IsSplliteItem then
			local ret = isHero and g_data.heroBag:PileUpNext() or g_data.bag:PileUpNext()

			if type(ret) == "table" and #ret == 2 then
				net.send({
					CM_PILEUPITEM,
					recog = ret[1]:get("makeIndex"),
					param = Loword(ret[2]:get("makeIndex")),
					tag = Hiword(ret[2]:get("makeIndex")),
					series = isHero and 1 or 0
				})
				g_data.player:setIsinPileUping(true)
			end
		end

		g_data.player:setIsSplliting(false)
	end

	local ident = msg.ident

	if SM_ABILITY == ident then
		g_data.player:setAbility(msg, buf, bufLen)
		main_scene.ground.map:addMsg({
			roleid = g_data.player.roleid,
			job = g_data.player.job
		})
		self.console:call("infoBar", "uptAbility")
		self.console:call("bottom", "upt")
		self.console:hidePet()

		if main_scene.ground.player then
			main_scene.ground.player.info:setHP(g_data.player.ability:get("HP"), g_data.player.ability:get("maxHP"))
		end

		if g_data.serverConfig.allowMaxLevel <= g_data.player.ability:get("level") then
			common.addMsg(string.format("您的等级已经达到上限%d级，将不能再获取经验。", g_data.serverConfig.allowMaxLevel), def.colors.clWhite, def.colors.clBlue, true)
		end

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end

		main_scene.ground.helper:checkFirstLogin()
	elseif SM_GETDIAMNUM_EXT == ident then
		if bufLen == getRecordSize("TMessageCapitalInfo") then
			g_data.player:setCapitalInfo(buf, bufLen)
			main_scene.ui.console:call("infoBar", "uptYb")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		end
	elseif checkExist(ident, SM_HEAR, SM_CRY, SM_GROUPMESSAGE, SM_CORPSMESSAGE, SM_GUILDMESSAGE, SM_SYSMESSAGE, SM_WHISPER, SM_BROADCASTMESSAGE) then
		if buf then
			local strs = net.strs(buf)

			if settingLogic.filterChat(strs[1], ident, msg) and g_data.relation:filterChat(common.getPlayerName(), strs[1], ident, msg) then
				common.addMsg(strs[1], Lobyte(msg.param), Hibyte(msg.param), nil, msg.recog, msg, buf, bufLen)
			end
		end
	elseif SM_QUERY_FOCUS_ITEM == ident then
		common.uptItemMsgData(net.record("TClientItem", buf, bufLen))
	elseif SM_MENU_OK == ident or SM_DLGMSG == ident then
		local str = net.str(buf)

		if str ~= "" then
			tip(str)
		end
	elseif SM_CLIENT_CONF == ident then
		g_data.chat:setShieldMask(msg.recog)
		common.refershChatContent()
	elseif SM_ATTACKMODE == ident then
		local modes = {
			"[全体攻击模式]",
			"[和平攻击模式]",
			"[编组攻击模式]",
			"[行会攻击模式]",
			"[敌对攻击模式]",
			"[战队攻击模式]"
		}
		local mode = modes[msg.recog + 1] or "[未知攻击模式]"

		g_data.player:setAttackMode(mode)
		self.console:call("btnMode", "upt")
		common.addMsg(mode, 219, 256)
	elseif SM_SENDMYMAGIC == ident then
		g_data.player:setMagicList(buf, bufLen)
		main_scene.ui.console.skills:upt()

		if self.panels.equip and self.panels.equip.page == "skill" then
			self.panels.equip:showContent("skill")
		end
	elseif SM_ADDMAGIC == ident then
		local data = g_data.player:addMagic(buf, bufLen)

		if data then
			main_scene.ui.console.skills:layout(data.magicId)
		end

		main_scene.ui.console.skills:upt()

		if self.panels.equip and self.panels.equip.page == "skill" then
			self.panels.equip:showContent("skill")
		end
	elseif SM_MAGIC_LVEXP == ident then
		local v = g_data.player:setMagicExp(msg, buf, bufLen)

		if v and self.panels.equip then
			self.panels.equip:updateMagic(v:get("magicId"))
		end
	elseif SM_STAMINA == ident then
		g_data.player:setStamina(msg.param, msg.recog)
		main_scene.ui.console:call("infoBar", "uptStamina")

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end
	elseif SM_VITALITY == ident then
		g_data.player:setVitality(msg.param, msg.recog)
		main_scene.ui.console:call("infoBar", "uptVitality")

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end
	elseif SM_EXP_POOL == ident then
		g_data.player:setExpPoolValue(msg.recog)
		main_scene.ui.console:call("infoBar", "uptExp")

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end
	elseif SM_VITALITYITEM == ident then
		g_data.player:setVitaliyitemValue(msg.recog)
		main_scene.ui.console:call("infoBar", "uptBlood")
	elseif SM_WINEXP == ident then
		g_data.player.ability:set("Exp", msg.recog)

		local expGet = MakeLong(msg.param, msg.tag)

		if not g_data.setting.base.showExpEnable or g_data.setting.base.showExpEnable and g_data.setting.base.showExpValue <= expGet then
			if msg.series == TExpTypeEnergy then
				self:tip(expGet .. " 精力经验值增加")
			elseif msg.series == TExpTypePower then
				self:tip(expGet .. " 活力经验值增加")
			else
				self:tip(expGet .. " 经验值增加")
			end
		end

		self.console:call("bottom", "upt")
		self.console.autoRat:onExpUpdate()

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
			main_scene.ui.panels.equip:showContent("state")
		end
	elseif SM_LEVELUP == ident then
		g_data.player.ability:set("level", msg.param)
		self:tip("升级!")
		main_scene.ui.console:call("infoBar", "uptLevel")
		main_scene.ground.helper.runner.onLevelUp(msg.param)
	elseif SM_BAGITEMS == ident then
		g_data.bag:set(buf, bufLen)

		if self.panels.bag then
			self.panels.bag:reload()
		end
	elseif SM_SENDUSEITEMS == ident then
		g_data.equip:set(buf, bufLen)

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "equip" then
			main_scene.ui.panels.equip:showContent("equip")
		end
	elseif SM_SENDUSERSTATE == ident then
		local userInfo = getRecord("TUserStateInfo")
		
		net.record(userInfo, buf, bufLen)
	
		if not def.userInfo then
			def.userInfo = {}
		end
		
		local user = userInfo:get("userName")
		
		--记录上一次状态
		local tmpInfo = def.userInfo[user] or nil
		local function update()
			def.userInfo[user] = userInfo
			cache.saveDiy(user, "_userInfo", userInfo:get("guildName")) -- return nil
			local map = main_scene.ground.map
			
			for k, v in pairs(map.heros) do
				if user == v.info.name.texts[1] then
					v.info:setName(v.info.name.texts, true)
				end
			end
		end
		-- 过滤重复
		--过滤未改变数据
		if tmpInfo and tmpInfo:get("guildName") == userInfo:get("guildName") then
			print('Skip repetition')
		--新加入数据 或 退出数据
		else 
			print('Update guild info')
			update()
		end
		
		self:hidePanel("equipOther")
		self:showPanel("equipOther", userInfo)
		g_data.client:setLastTime("queryOther")
	elseif SM_SEND_TITLEINFO == ident then
		g_data.player:initTitle(msg, buf, bufLen)

		if main_scene.ui.panels.equip then
			main_scene.ui.panels.equip:showContent("title")
		end
	elseif SM_SET_CURTITLE == ident then
		if msg.series == 0 then
			g_data.player:setTitleResult(msg)

			if main_scene.ui.panels.equip then
				main_scene.ui.panels.equip:showContent("title")
			end
		end
	elseif SM_UPDATE_TITLE == ident then
		g_data.player:updateTitleInfo(msg, buf, bufLen)

		if main_scene.ui.panels.equip then
			main_scene.ui.panels.equip:showContent("title")
		end
	elseif SM_UPDATE_TITLE_DURA == ident then
		g_data.player:updateTitleCount(msg, buf, bufLen)
	elseif SM_ADDITEM == ident then
		local ret = g_data.bag:add(buf, bufLen)
		
		for i = 1, #ret do
			local v = ret[i]
			
			self:tip(v.data.getVar("name") .. " 被发现")

			if v.where == "bag" and self.panels.bag then
				self.panels.bag:addItem(v.data:get("makeIndex"))
			end
			
			main_scene.ground.helper.runner.onNewItem(v.data:get("Index"))

			--新装备
			draw.ufact.UseItem(self, v);

		end
		g_data.player.del_queip_info = nil
		PileUpItem()
	elseif SM_ITEM_PILEUP_RESULT == ident then
		g_data.player:setIsinPileUping(false)

		if msg.series == 0 then
			PileUpItem()
		elseif msg.series == 1 then
			PileUpItem(true)
		end
	elseif SM_DELITEM == ident then
		local makeIndex = msg.recog

		if msg.param == 0 then
			if g_data.bag:delItem(makeIndex) and self.panels.bag then
				self.panels.bag:delItem(makeIndex)
			end

			if g_data.equip:delItem(makeIndex) and self.panels.equip then
				self.panels.equip:delItem(makeIndex)
			end

			if self.panels.strengthen then
				self.panels.strengthen:delItem(makeIndex)
			end
		elseif msg.param == 1 and self.panels.storage then
			self.panels.storage:delItem(makeIndex)
			self.panels.storage:delItemData(makeIndex)
		end
	elseif SM_UPDATEITEM == ident then
		local makeIndex = g_data.bag:upt(buf, bufLen)

		if makeIndex and self.panels.bag then
			self.panels.bag:uptItem(makeIndex)
		end

		if makeIndex and self.panels.strengthen then
			self.panels.strengthen:uptItem(makeIndex)
		end

		local makeIndex = g_data.equip:upt(buf, bufLen)

		if makeIndex and self.panels.equip then
			self.panels.equip:uptItem(makeIndex)
		end
	elseif SM_BAGITEMDURACHG == ident then
		g_data.bag:duraChange(msg.recog, msg.param, msg.tag, msg.series)

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:duraChange(msg.recog, msg.param, msg.tag, msg.series)
		end

		if self.panels.strengthen then
			self.panels.strengthen:duraChange(msg.recog)
		end
	elseif SM_DURACHANGE == ident then
		g_data.equip:duraChange(msg.param, msg.recog, MakeLong(msg.tag, msg.series))
	elseif SM_DELITEMS == ident then
		local idxs = {}
		local count = math.floor(bufLen / 4)

		if count > 0 then
			for i = 1, count do
				idxs[#idxs + 1], buf, bufLen = net.uint(buf, bufLen)
			end
		end

		for i, v in ipairs(idxs) do
			if g_data.bag:delItem(v) and self.panels.bag then
				self.panels.bag:delItem(v)
			end

			if g_data.equip:delItem(v) and self.panels.equip then
				self.panels.equip:delItem(v)
			end

			g_data.bag:delQuickItem(v)
		end
	elseif SM_DROPITEM_SUCCESS == ident then
		g_data.bag:throwEnd(msg.recog, true)
	elseif SM_DROPITEM_FAIL == ident then
		g_data.bag:throwEnd(msg.recog, false)

		if self.panels.bag then
			self.panels.bag:addItem(msg.recog)
		end
	elseif SM_WEIGHTCHANGED == ident then
		g_data.player:weightChanged(msg.recog, msg.param, msg.tag)
		main_scene.ui.console:call("infoBar", "uptBag")
	elseif SM_EATITEM_OK == ident then
		local _, data, isQuick = g_data.bag:useEnd("eat", true)

		main_scene.ui.console:fillPropTest()
		self:checkUsedItemforStopAutoRat(data)
	elseif SM_EATITEM_FAIL == ident then
		local makeIndex, data, isQuick, where = g_data.bag:useEnd("eat", false)

		if makeIndex and self.panels.bag then
			self.panels.bag:addItem(makeIndex)
		end

		self:checkUsedItemforStopAutoRat(data)
	elseif SM_TAKEON_OK == ident then
		local feature = msg.recog

		if bufLen == getRecordSize("TFeature") then
			feature = net.record("TFeature", buf, bufLen)
		end
		
		main_scene.ground.map.player:changeFeature(feature)

		local makeIndex = g_data.bag:useEnd("take", true)

		if self.panels.equip and makeIndex then
			self.panels.equip:setItem(makeIndex)
		end
	elseif SM_TAKEON_FAIL == ident then
		local makeIndex = g_data.bag:useEnd("take", false)

		if self.panels.bag and makeIndex then
			self.panels.bag:addItem(makeIndex)
		end

		local str = ""

		if msg.recog == -1 then
			str = "该物品获得后自动锁定，锁定期过后才可正常使用。"
		elseif msg.recog == -2 then
			str = "穿戴位置不正确"
		elseif msg.recog == -3 then
			str = "二级密码锁定状态不能更换装备"
		elseif msg.recog == -4 then
			str = "密保锁定。"
		elseif msg.recog == -6 then
			str = "装备基础条件不满足"
		elseif msg.recog == -7 then
			str = "超重"
		elseif msg.recog == -8 then
			str = "声望不足"
		elseif msg.recog == -9 then
			str = "装备基础条件不满足"
		elseif msg.recog == -10 then
			str = "职业不满足"
		elseif msg.recog == -11 then
			str = "职业不满足"
		elseif msg.recog == -12 then
			str = "不能穿戴"
		else
			str = "未知错误"
		end

		common.addMsg(str, display.COLOR_RED, display.COLOR_WHITE, true)
	elseif SM_TAKEOFF_OK == ident then
		local feature = msg.recog

		if bufLen == getRecordSize("TFeature") then
			feature = net.record("TFeature", buf, bufLen)
		end

		main_scene.ground.map.player:changeFeature(feature)
		
		g_data.equip:takeOffEnd(true)
	elseif SM_TAKEOFF_FAIL == ident then
		local makeIndex = g_data.equip:takeOffEnd(false)

		if self.panels.equip and makeIndex then
			self.panels.equip:setItem(makeIndex)
		end
	elseif SM_MERCHANTSAY == ident then
		body = net.str(buf)
		local npcName = ""
		local pos = string.find(body, "/")

		if pos then
			npcName = string.sub(body, 1, pos - 1)
			body = string.sub(body, pos + 1, string.len(body))
		end

		print("接收到的商人说的话")
		self:hidePanel("npc")
		self:showPanel("npc", {
			merchant = msg.recog,
			face = msg.param,
			npcName = npcName,
			body = body
		})

		if self.panels.bag then
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_MERCHANTDLGCLOSE == ident then
		self:hidePanel("npc")
	elseif SM_MERCHANT_QUERY == ident then
		if msg.tag == 0 then
			if self.panels.npc then
				self.panels.npc:showInput(msg, buf, bufLen)
			end
		elseif msg.tag == 1 then
			local text = net.str(buf)
			local inputType = msg.tag
			local sessionid = msg.recog
			local param = msg.param
			local msgbox = an.newMsgbox(text, function (idx)
				net.send({
					CM_MERCHANT_QUERY,
					recog = sessionid,
					param = param,
					tag = inputType,
					series = idx - 1
				})
			end, {
				disableScroll = true,
				btnTexts = {
					"取消",
					"同意"
				}
			})
		elseif msg.tag == 3 then
			-- Nothing
		end
	elseif SM_SENDGOODSLIST == ident then
		if self.panels.npc then
			self.panels.npc:showList(msg.recog, msg.param, buf, bufLen, "goods")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDDETAILGOODS == ident then
		if self.panels.npc then
			self.panels.npc:showList(msg.recog, msg.param, buf, bufLen, "goods_detail", msg.tag)
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDMAKEDRUGITEMS == ident then
		if self.panels.npc then
			self.panels.npc:showList(msg.recog, msg.param, buf, bufLen, "synthesis", msg.tag)
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SAVEITEMLIST == ident then
		self:hidePanel("storage")
		self:showPanel("storage", msg.recog, msg.param, msg.tag, buf, bufLen)
	elseif SM_BUYITEM_SUCCESS == ident then
		g_data.client:setLastTime("buy")
		common.goldChanged(msg.recog)

		if self.panels.npc then
			self.panels.npc:removeItem(MakeLong(msg.param, msg.tag))
		end
	elseif SM_BUYITEM_FAIL == ident then
		g_data.client:setLastTime("buy")

		if msg.recog == 1 then
			an.newMsgbox("此物品被卖出.", nil, {
				center = true
			})
		elseif msg.recog == 2 then
			an.newMsgbox("您无法携带更多物品了.", nil, {
				center = true
			})
		elseif msg.recog == 3 then
			an.newMsgbox("您没有足够的钱来购买此物品.", nil, {
				center = true
			})
		else
			an.newMsgbox("未知错误: " .. msg.recog, nil, {
				center = true
			})
		end
	elseif SM_SENDUSERREPAIR == ident then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "repair")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDUSERSELL == ident then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "sell")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDUSERSTORAGEITEM == ident then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "storage")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDREPAIRCOST == ident or SM_SENDBUYPRICE == ident then
		if self.panels.npc then
			self.panels.npc:setSellText(msg.recog >= 0 and msg.recog .. " 金币" or "???? 金币")
		end
	elseif SM_OPEN_COMMIT_ITEM == ident then
		print("弹出兑换物品框")

		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "exchange", msg.series)
			self.panels.npc:setSellText(net.str(buf))
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_COMMIT_ITEM == ident then
		if msg.param == 1 then
			if self.panels.npc then
				self.panels.npc:delSellItem()
			end

			if g_data.client.lastSellItem then
				if self.panels.bag then
					self.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.client:setLastTime("sell")
			g_data.client:setLastSellItem()
		elseif msg.param == 0 then
			if self.panels.npc then
				self.panels.npc:delSellItem()
			end

			if bufLen > 0 then
				local str = net.str(buf)

				common.addMsg(str, display.COLOR_GREEN, display.COLOR_WHITE, true)
			end
		end
	elseif SM_USERSELLITEM_OK == ident then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		if g_data.client.lastSellItem then
			if self.panels.bag then
				self.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
		end

		g_data.client:setLastTime("sell")
		g_data.client:setLastSellItem()
	elseif SM_USERSELLITEM_FAIL == ident then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		g_data.client:setLastTime("sell")
		g_data.client:setLastSellItem()
		an.newMsgbox([[
您不能出售该物品，可能是以下原因：
1.    绑定物品和高级物品无法出售
2.    请前往对应商店出售物品
3.    可携带金币超出上限(未验证角色可携带200万金币，已验证角色可携带5000万金币)]])
	elseif SM_USERREPAIRITEM_OK == ident then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		if g_data.client.lastSellItem then
			g_data.client.lastSellItem:set("dura", msg.param)
			g_data.client.lastSellItem:set("duraMax", msg.tag)
		end

		g_data.client:setLastSellItem()
		g_data.client:setLastTime("sell")
	elseif SM_USERREPAIRITEM_FAIL == ident then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		g_data.client:setLastSellItem()
		g_data.client:setLastTime("sell")
		an.newMsgbox("您不能修理此物品.", nil, {
			center = true
		})
	elseif SM_MAKEDRUG_FAIL == ident then
		local str = ""

		if msg.recog == 3 then
			str = "金币不够 "
		elseif msg.recog == 4 then
			str = "材料不足"
		elseif msg.recog == 2 then
			str = "合成成功，获取物品失败"
		end

		self:tip(str)
	elseif checkExist(ident, SM_STORAGE_OK, SM_STORAGE_FULL, SM_STORAGE_FAIL) then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		if SM_STORAGE_OK == ident and g_data.client.lastSellItem then
			if self.panels.bag then
				self.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
		end

		g_data.client:setLastSellItem()
		g_data.client:setLastTime("sell")

		if g_data.client.storageItem then
			if self.panels.bag then
				self.panels.bag:delItem(g_data.client.storageItem:get("makeIndex"))
			end

			g_data.bag:delItem(g_data.client.storageItem:get("makeIndex"))

			if SM_STORAGE_OK == ident then
				if self.panels.storage then
					self.panels.storage:addItem(g_data.client.storageItem)
				end
			else
				g_data.bag:addItem(g_data.client.storageItem)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(g_data.client.storageItem:get("makeIndex"))
				end
			end
		end

		g_data.client:setStorageItem()

		if SM_STORAGE_FULL == ident then
			an.newMsgbox("你的个人仓库已满，你不能再寄存任何物品。", nil, {
				center = true
			})
		elseif SM_STORAGE_FAIL == ident then
			self:tip("寄存失败。")
		end
	elseif SM_GETSTORAGEITEM_OK == ident then
		g_data.client:setStorageGetBackItem()
		g_data.client:setLastTime("buy")

		if self.panels.npc then
			self.panels.npc:removeItem(msg.recog)
		end
	elseif SM_GETSTORAGEITEM_FAIL == ident then
		local str = ""

		if msg.recog == -1 then
			str = "您已无法携带这么重的物品了"
		elseif msg.recog == -2 then
			str = "在交易中无法使用仓库功能"
		elseif msg.recog == -3 then
			str = "你的仓库已被盛大CD卡、或密宝绑定，如需取出物品请先开启仓库"
		end

		g_data.client:setLastTime("buy")
		self:tip(str)

		if g_data.client.storageGetBackItem then
			if self.panels.storage then
				self.panels.storage:addItem(g_data.client.storageGetBackItem)
			end

			g_data.client:setStorageGetBackItem()
		end
	elseif SM_GETSTORAGEITEM_FULLBAG == ident then
		g_data.client:setLastTime("buy")
		an.newMsgbox("您无法携带更多物品了.")

		if g_data.client.storageGetBackItem then
			if self.panels.storage then
				self.panels.storage:addItem(g_data.client.storageGetBackItem)
			end

			g_data.client:setStorageGetBackItem()
		end
	elseif SM_STORAGEITEMDURACHG == ident then
		if self.panels.storage then
			self.panels.storage:duraChange(msg.recog, msg.param, msg.tag, msg.series)
		end
	elseif SM_STORAGE_ADDITEM == ident then
		if main_scene.ui.panels.storage then
			main_scene.ui.panels.storage:splitNemItem(msg, buf, bufLen)
		end
	elseif SM_GOLDCHANGED == ident then
		common.goldChanged(msg.recog)
	elseif SM_PLAYDICE == ident then
		common.showBosonResult(msg, buf, bufLen)
	elseif SM_SHOWBOOK == ident then
		print("书本")
	elseif SM_DEALMENU == ident then
		g_data.client:setLastTime("deal")
		self:hidePanel("deal")
		self:showPanel("deal", net.str(buf))
		self:showPanel("bag")
	elseif SM_DEALTRY_FAIL == ident then
		g_data.client:setLastTime("deal")
		tip("交易被取消。\n要正确交易你必须和对方面对面。")
	elseif SM_DEALADDITEM_OK == ident then
		g_data.client:setLastTime("deal")

		if g_data.client.dealItem then
			g_data.client:addDealItem(g_data.client.dealItem)

			if self.panels.deal then
				self.panels.deal:addItem("self", g_data.client.dealItem)
			end

			g_data.client:setNowDealItem()
		end
	elseif SM_DEALADDITEM_FAIL == ident then
		g_data.client:setLastTime("deal")

		if g_data.client.dealItem then
			g_data.bag:addItem(g_data.client.dealItem)

			if self.panels.bag then
				self.panels.bag:addItem(g_data.client.dealItem:get("makeIndex"))
			end

			g_data.client:setNowDealItem()
		end
	elseif SM_DEALDELITEM_OK == ident then
		-- Nothing
	elseif SM_DEALDELITEM_FAIL == ident then
		-- Nothing
	elseif SM_DEALCANCEL == ident then
		for i, v in ipairs(g_data.client.dealItems) do
			g_data.bag:addItem(v)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(v:get("makeIndex"))
			end
		end

		if g_data.client.dealGold > 0 then
			common.goldChanged(g_data.player.gold + g_data.client.dealGold)
		end

		if g_data.client.dealItem then
			g_data.bag:addItem(g_data.client.dealItem)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(g_data.client.dealItem:get("makeIndex"))
			end
		end

		g_data.client:setDealGold()
		g_data.client:setNowDealItem()
		g_data.client:clearDealItem()
		self:hidePanel("deal")
	elseif SM_DEALREMOTEADDITEM == ident then
		if self.panels.deal then
			local item = getRecord("TClientItem")

			net.record(item, buf, getRecordSize("TClientItem"))
			self.panels.deal:addItem("target", item)
		end
	elseif SM_DEALREMOTEDELITEM == ident then
		if self.panels.deal then
			local item = getRecord("TClientItem")

			net.record(item, buf, getRecordSize("TClientItem"))
			self.panels.deal:delItem("target", item)
		end
	elseif SM_DEALCHGGOLD_OK == ident or SM_DEALCHGGOLD_FAIL == ident then
		g_data.client:setLastTime("deal")
		g_data.client:setDealGold(msg.recog)
		common.goldChanged(MakeLong(msg.param, msg.tag))

		if self.panels.deal then
			self.panels.deal:setMoney("self", msg.recog)
		end
	elseif SM_DEALREMOTECHGGOLD == ident then
		if self.panels.deal then
			self.panels.deal:setMoney("target", msg.recog)
		end
	elseif SM_DEALSUCCESS == ident then
		self:hidePanel("deal")
		g_data.client:setDealGold()
		g_data.client:clearDealItem()
	elseif SM_GROUPMODECHANGED == ident then
		g_data.player:setAllowGroup(msg.param > 0)
		g_data.client:setLastTime("group")

		if self.panels.group then
			self.panels.group:enableAllow()
		end
	elseif SM_CREATEGROUP_OK == ident then
		g_data.player:setAllowGroup(true)
		g_data.client:setLastTime("group")

		if self.panels.group then
			self.panels.group:enableAllow()
		end
	elseif SM_JOINGROUP_FAIL == ident then
		print("SM_JOINGROUP_FAIL", msg.recog)

		if msg.recog == -1 then
			tip("玩家名错误或不在线。")
		elseif msg.recog == -2 then
			tip("玩家队伍不存在")
		elseif msg.recog == -3 then
			tip("不在允许组队状态")
		elseif msg.recog == -4 then
			tip("队伍人数已满。")
		elseif msg.recog == -10 then
			tip("不可邀请自己组队。")
		else
			tip("未知错误。")
		end

		g_data.client:setLastTime("group")
	elseif SM_CREATEGROUP_FAIL == ident then
		print("SM_CREATEGROUP_FAIL", msg.recog)

		if msg.recog == -1 then
			tip("发起人已经创建队伍")
		elseif msg.recog == -2 then
			tip("玩家名错误或不在线")
		elseif msg.recog == -6 then
			tip("发起人不允许创建队伍")
		elseif msg.recog == -3 then
			tip("该玩家已有队伍")
		elseif msg.recog == -4 then
			tip("接受人不允许组队")
		elseif msg.recog == -10 then
			tip("不可邀请自己组队")
		else
			tip("未知错误")
		end

		g_data.client:setLastTime("group")
	elseif SM_GROUPADDMEM_OK == ident then
		g_data.client:setLastTime("group")
		print("SM_GROUPADDMEM_OK 添加组员成功", bufLen)
	elseif SM_GROUPADDMEM_FAIL == ident then
		print("SM_GROUPADDMEM_FAIL", msg.recog)

		if msg.recog == -1 then
			tip("发起人不是队长")
		elseif msg.recog == -2 then
			tip("玩家名错误或不在线")
		elseif msg.recog == -3 then
			tip("该玩家已有队伍")
		elseif msg.recog == -4 then
			tip("接受人不允许组队")
		elseif msg.recog == -5 then
			tip("队伍已满")
		elseif msg.recog == -10 then
			tip("不可邀请自己组队")
		else
			tip("未知错误。")
		end

		g_data.client:setLastTime("group")
	elseif SM_GROUPDELMEM_OK == ident then
		g_data.client:setLastTime("group")
		print("SM_GROUPDELMEM_OK 删除组员成功", bufLen, net.str(buf))
		g_data.player:delGroupMember(buf)

		if self.panels.group and self.panels.group.page == "mine" then
			self.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		end
	elseif SM_GROUPDELMEM_FAIL == ident then
		if msg.recog == -1 then
			tip("队员不能删除其他成员")
		elseif msg.recog == -2 then
			tip("输入的人物名称不正确")
		elseif msg.recog == -3 then
			tip("删除目标不是队伍成员")
		else
			tip("未知错误")
		end

		g_data.client:setLastTime("group")
	elseif SM_GROUPCANCEL == ident then
		print("SM_GROUPCANCEL 解散队伍")
		g_data.player:setGroupMembers(nil)
		g_data.player:setTeamLeader(false)

		if self.panels.group and self.panels.group.page == "mine" then
			self.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		end
	elseif SM_GROUPMEMBERS == ident then
		print("SM_GROUPMEMBERS", bufLen, msg.param, getRecordSize("TClientGroupMemInfo"))
		g_data.player:initGroupMembers(msg, buf, bufLen)
		g_data.player:setTeamLeader(false)

		for i, v in ipairs(g_data.player.groupMembers) do
			if v:get("name") == common.getPlayerName() and v:get("isCaptain") == 1 then
				g_data.player:setTeamLeader(true)

				break
			end
		end

		if self.panels.group and self.panels.group.page == "mine" then
			self.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		end
	elseif SM_QUERY_NEARBYGROUP == ident then
		print("SM_QUERY_NEARBYGROUP")
		g_data.player:initNearGroup(msg, buf, bufLen)

		if self.panels.group then
			self.panels.group:showPageInfo("group", g_data.player.nearGroupInfo)
		end
	elseif SM_QUERY_NEARBYPLAYER == ident then
		print("SM_QUERY_NEARBYPLAYER", getRecordSize("TClientNearbyPlayerInfo"), bufLen)

		local nearList = g_data.relation:decodeNearPlayerBuf(msg, buf, bufLen)

		if self.panels.group and self.panels.group.page == "near" then
			self.panels.group:showPageInfo("near", nearList)
		end

		if self.panels.relation and self.panels.relation.page == "near" then
			self.panels.relation:showContent("near", nearList)
		end
	elseif SM_NotifyGroupMessage == ident then
		print("SM_NotifyGroupMessage")

		local name = net.str(buf)
		local cmd = msg.param

		if msg.recog == 1 then
			self.notice:addMsg("FriendApply", {
				name,
				cmd
			})
		else
			self.notice:removeMsg("FriendApply", {
				name,
				cmd
			})
		end
	elseif SM_ORDER_LIST == ident then
		g_data.client:setLastTime("top")

		if self.panels.top then
			self.panels.top:processUpt(msg.param, msg, buf, bufLen)
		end
	elseif SM_CORPS_NOTICE == ident then
		--dump(msg)
		print(" SM_CORPS_NOTICE ", bufLen > 0 and net.str(buf) or "nil", bufLen)

		if msg.param == 0 then
			g_data.guild.clanNotice = bufLen > 0 and net.str(buf) or ""
		end
	elseif SM_GILD_NOTICE == ident then
		if msg.param == 0 then
			g_data.guild.guildNotice = bufLen > 0 and net.str(buf) or ""
		end
	elseif SM_FIND_CORPS_BYNAME == ident then
		print("模糊查找战队返回")
		--dump(msg)

		g_data.guild.serach = true

		g_data.guild:initClanList(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "clan" then
			self.panels.guild:uirefushContent("clan")
		end
	elseif SM_FIND_GILD_BYNAME == ident then
		print("模糊查找行会返回")
		--dump(msg)

		g_data.guild.serach = true

		g_data.guild:initGuildList(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "tguild" then
			if self.panels.guild.showGuildListNode then
				self.panels.guild:showGuildList()
			else
				self.panels.guild:uirefushContent("tguild")
			end
		end
	elseif SM_CORPS_GET_RECRUIT_CONDITION == ident then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			self.panels.guild:recruitCondition(msg, buf, bufLen)
		end
	elseif SM_PLAYER_POSITION == ident then
		g_data.guild.posInfo = msg.tag
		local info = {
			"",
			"副队长",
			"队长",
			"副会长",
			"会长"
		}
	elseif SM_PLAYER_GILD == ident then
		g_data.guild:initGuildInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "tguild" then
			self.panels.guild.subpage = nil

			self.panels.guild:uirefushContent("tguild")
		end
	elseif SM_PLAYER_CORPS == ident then
		g_data.guild:initClanInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "clan" then
			self.panels.guild.subpage = nil

			self.panels.guild:uirefushContent("clan")
		end
	elseif SM_REFRESH_GILDINFO == ident then
		g_data.guild:initGuildInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "tguild" and self.panels.guild.subpage == "guildmain" then
			self.panels.guild:refush("guildmain")
		end
	elseif SM_REFRESH_CORPSINFO == ident then
		g_data.guild:initClanInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "clan" and self.panels.guild.subpage == "clanmain" then
			self.panels.guild:refush("clanmain")
		end
	elseif SM_CORPS_LIST == ident then
		if msg.param == 0 then
			g_data.guild.serach = false
			g_data.guild.page = msg.recog

			g_data.guild:initClanList(msg, buf, bufLen)

			g_data.guild.getCorpsList = true

			if self.panels.guild and self.panels.guild.page == "clan" then
				self.panels.guild:uirefushContent("clan")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_REQUEST_JOIN == ident then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			self:tip("申请加入战队成功")
		end
	elseif SM_CORPS_CANCEL_JOIN == ident then
		if msg.param == 0 then
			self:tip("取消申请加入战队成功")
		end
	elseif SM_CORPS_TRANSFER_CAPTAIN == ident then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	elseif SM_CORPS_APPOINT_VICE_CAPTAIN == ident or SM_CORPS_DISMISS_VICE_CAPTAIN == ident then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	elseif SM_CORPS_STEPDOWN == ident then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	elseif SM_CORPS_EXIT == ident then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			g_data.guild.guildInfo = nil
			g_data.guild.clanInfo = nil

			if self.panels.guild and self.panels.guild.page == "clan" then
				self.panels.guild.subpage = nil

				self.panels.guild:uirefushContent("clan")
			end
		end
	elseif SM_CORPS_QUERY_REQUESTS == ident then
		g_data.guild:getCorpsQueryRequests(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.subpage == "clanjobs" then
			self.panels.guild:refush("clanjobs")
		end
	elseif SM_CORPS_ACCEPT_REQUEST == ident then
		if msg.param == 0 then
			net.send({
				CM_CORPS_QUERY_REQUESTS,
				tag = 30,
				param = 0
			})
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_REFUSE_REQUEST == ident then
		if msg.param == 0 then
			net.send({
				CM_CORPS_QUERY_REQUESTS,
				tag = 30,
				param = 0
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_DISMISS_MEMBER == ident then
		if msg.param == 0 then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_CREATE == ident then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_MEMBER_LIST == ident then
		if msg.param == 0 then
			if msg.recog == 0 then
				g_data.guild:getCorpsMem(msg, buf, bufLen)

				if self.panels.guild then
					self.panels.guild:refush("clanmem")
				end
			else
				g_data.guild:getGuildCorpsMem(msg, buf, bufLen)

				if self.panels.guild then
					self.panels.guild:showOtherClanMem()
				end
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_SET_MEMBER_TITLE == ident then
		if msg.param == 0 then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_SEND_APPLYCORPS_ID == ident then
		g_data.guild:refushCurClan(msg, buf, bufLen)

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new("UpdateNilClanState")

		eventDispatcher:dispatchEvent(event)
	elseif SM_SEND_APPLYGILD_ID == ident then
		g_data.guild:refushCurGuild(msg, buf, bufLen)

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new("UpdateNilGuildState")

		eventDispatcher:dispatchEvent(event)
	elseif SM_CORPS_DIRECT_ADD_MEMBER == ident then
		if msg.param == 0 then
			self:tip("面对面找人请求发送成功！")
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_QUERY_LOG == ident then
		g_data.guild:getCorpsLog(msg, buf, bufLen)

		if self.panels.guild then
			self.panels.guild:refush("clanlog")
		end
	elseif SM_GILD_LIST == ident then
		if msg.param == 0 then
			g_data.guild.serach = false
			g_data.guild.page = msg.recog

			g_data.guild:initGuildList(msg, buf, bufLen)

			g_data.guild.getguildList = true

			if self.panels.guild and self.panels.guild.page == "tguild" then
				if self.panels.guild.showGuildListNode then
					self.panels.guild:showGuildList()
				else
					self.panels.guild:uirefushContent("tguild")
				end
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_EXIT == ident then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_CORPS == ident then
		if msg.param == 0 then
			g_data.guild:getguildcorpsList(msg, buf, bufLen)

			if self.panels.guild then
				self.panels.guild:refush("claninfo")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_REQUEST_JOIN_LIST == ident then
		if msg.param == 0 then
			g_data.guild:getGuildQueryRequests(msg, buf, bufLen)

			if self.panels.guild and self.panels.guild.subpage == "clanrecruit" then
				self.panels.guild:refush("clanrecruit")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_REQUEST_JOIN == ident then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_ACCEPT_REQUEST == ident then
		if msg.param == 0 then
			print("------")

			if msg.recog == 1 then
				net.send({
					CM_GILD_QUERY_REQUEST_JOIN_LIST,
					tag = 30,
					series = 0
				})
			elseif msg.recog == 2 then
				net.send({
					CM_GILD_QUERY_REQUEST_UNION_LIST,
					tag = 30,
					series = 0
				})
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_REFUSE_REQUEST == ident then
		if msg.param == 0 then
			print("------")

			if msg.recog == 1 then
				net.send({
					CM_GILD_QUERY_REQUEST_JOIN_LIST,
					tag = 30,
					series = 0
				})
			elseif msg.recog == 2 then
				net.send({
					CM_GILD_QUERY_REQUEST_UNION_LIST,
					tag = 30,
					series = 0
				})
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_DISMISS_CORPS == ident then
		if msg.param == 0 then
			print("+++++++++++++++++++++++")
			net.send({
				CM_GILD_QUERY_CORPS
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CHANGE_MEMBER == ident then
		-- Nothing
	elseif SM_GILDMEMBER_LIST == ident then
		if msg.param == 0 then
			g_data.guild:getguildMem(msg, buf, bufLen)

			if self.panels.guild then
				self.panels.guild:refush("mem")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_LOG == ident then
		g_data.guild:getGuildLog(msg, buf, bufLen)

		if self.panels.guild then
			self.panels.guild:refush("log")
		end
	elseif SM_GILD_QUERY_REQUEST_UNION_LIST == ident then
		g_data.guild:getRequestUnion(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
			print(self.panels.guild.subpage or " nil ")
			print("")
			self.panels.guild:showSubDiplomatic4()
		end
	elseif SM_GILD_REQUEST_UNION == ident then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_BREAK_UNION == ident then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end

		net.send({
			CM_GILD_QUERY_UNION,
			tag = 30,
			series = 0
		})
	elseif SM_GILD_QUERY_HOSTILE == ident then
		if msg.param == 0 then
			g_data.guild:getHostile(msg, buf, bufLen)

			if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
				self.panels.guild:showSubDiplomatic2()
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_UNION == ident then
		g_data.guild:getUnion(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
			if self.panels.guild.showGuildListNode then
				self.panels.guild:showGuildList()
			else
				self.panels.guild:showSubDiplomatic1()
			end
		end
	elseif SM_GILD_QUERY_CONCERN == ident then
		if msg.param == 0 then
			g_data.guild:getConcern(msg, buf, bufLen)

			if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
				self.panels.guild:showSubDiplomatic3()
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_VICECAPTAIN_STEPDOWN == ident or SM_GILD_DISMISS_VICECAPTAIN == ident or SM_GILD_APPOINT_VICE_PRESIDENT == ident or SM_GILD_TRANSFER_PRESIDENT == ident then
		if msg.param == 0 then
			net.send({
				CM_GILDMEMBER_LIST
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_CONCERN_GILD_ID == ident then
		if msg.param == 0 then
			net.send({
				CM_GILD_QUERY_CONCERN,
				tag = 30,
				series = 0
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_CANCLE_CONCERN == ident then
		if msg.param == 0 then
			net.send({
				CM_GILD_QUERY_CONCERN,
				tag = 30,
				series = 0
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_DECLARE_WAR == ident then
		if msg.param == 0 then
			if self.panels.guild then
				if self.panels.guild.threeSub == 2 then
					net.send({
						CM_GILD_QUERY_HOSTILE,
						tag = 30,
						series = 0
					})
				elseif self.panels.guild.threeSub == 3 then
					net.send({
						CM_GILD_QUERY_CONCERN,
						tag = 30,
						series = 0
					})
				end
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_ENABLE_UNION == ident then
		if msg.param == 0 then
			local old = g_data.guild.guildInfo:get("enableUnion")

			g_data.guild.guildInfo:set("enableUnion", old == 0 and 1 or 0)
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_SEND_REFUSE_REQUEST == ident then
		if bufLen == getRecordSize("TRefuseRequestType") then
			local value = getRecord("TRefuseRequestType")

			net.record(value, buf, bufLen)

			local info = ""

			if value:get("type") == 3 then
				info = value:get("name") .. " 拒绝了您的联盟请求！"
			else
				info = "您加入" .. (value:get("type") == 1 and "战队 " or "行会 ") .. value:get("name") .. " 的请求已经被拒绝!"
			end

			self:tip(info)
			self:tip(info)
			self:tip(info)
		end
	elseif SM_STRENGTHEN_EQUIP_QUEST == ident then
		if self.panels.fusion then
			self.panels.fusion:addItems(msg, buf, bufLen)
		end
	elseif SM_STRENGTHEN_EQUIP == ident then
		if self.panels.fusion then
			self.panels.fusion:fusionEquip(msg, buf, bufLen)
		end
	elseif SM_UPDATE_CLOTHES == ident then
		if msg.recog == 0 then
			self:tip("强化成功")

			if self.panels.strengthen then
				self.panels.strengthen:showResult()
			end
		elseif self.panels.strengthen then
			self.panels.strengthen:showError(msg)
		end
	elseif SM_SHOPITEMS == ident then
		if bufLen == 0 then
			return
		end

		local items = g_data.shop:parseContent(msg, buf, bufLen)

		if self.panels.shop then
			self.panels.shop:processUpt(msg.param, items)
		end
	elseif SM_FIRSTSHOP == ident then
		if bufLen == 0 then
			return
		end

		local items = g_data.shop:parseSpecially(buf, bufLen)

		if self.panels.shop then
			self.panels.shop:processUpt(5, items)
		end
	elseif SM_DOSHOP_FAIL == ident then
		import(".panel.shop", current).onDoShopFail(ident, msg.recog, msg.param)
	elseif SM_HERO_ABILITY == ident then
		g_data.hero:setAbility(msg, buf, bufLen)
		main_scene.ground.map:addMsg({
			roleid = g_data.hero.roleid,
			job = g_data.hero.job
		})

		if self.panels.heroHead then
			self.panels.heroHead:upt()
		end
	elseif SM_GLORYFEALTY == ident then
		g_data.hero:setGloryFealty(msg.param, msg.tag)
	elseif SM_HERO_BAGITEMS == ident then
		g_data.hero:setBagSize(msg.series)
		g_data.heroBag:set(buf, bufLen)

		if self.panels.heroBag and not self.panels.heroBag:reloadAll(g_data.hero.bagSize) then
			self.panels.heroBag:reload()
		end
	elseif SM_HERO_BAGITEMDURACHG == ident then
		g_data.heroBag:duraChange(msg.recog, msg.param, msg.tag, msg.series)

		if main_scene.ui.panels.heroBag then
			main_scene.ui.panels.heroBag:duraChange(msg.recog, msg.param, msg.tag, msg.series)
		end
	elseif SM_HERO_SENDUSEITEMS == ident then
		g_data.heroEquip:set(buf, bufLen)

		if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "equip" then
			main_scene.ui.panels.heroEquip:showContent("equip")
		end
	elseif SM_HERO_SENDMYMAGIC == ident then
		g_data.hero:setMagicList(buf, bufLen)

		if self.panels.heroEquip and self.panels.heroEquip.page == "skill" then
			self.panels.heroEquip:showContent("skill")
		end
	elseif SM_HERO_ADDMAGIC == ident then
		g_data.hero:addMagic(buf, bufLen)

		if self.panels.heroEquip and self.panels.heroEquip.page == "skill" then
			self.panels.heroEquip:showContent("skill")
		end
	elseif SM_HERO_WINEXP == ident then
		g_data.hero.ability:set("Exp", msg.recog)

		local expGet = MakeLong(msg.param, msg.tag)

		self:tip(expGet .. " 英雄经验值增加")

		if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
			main_scene.ui.panels.heroEquip:showContent("state")
		end
	elseif SM_HERO_MAGIC_LVEXP == ident then
		local v = g_data.hero:setMagicExp(msg, buf, bufLen)

		if v and self.panels.heroEquip then
			self.panels.heroEquip:updateMagic(v:get("magicId"))
		end
	elseif SM_HERO_UNIONSTATUS == ident then
		g_data.hero:setUnionState(msg.recog, msg.param)
		main_scene.ui.console:call("btnHeroSkill", "hero_upt_union")
	elseif SM_HERO_DURACHANGE == ident then
		g_data.heroEquip:duraChange(msg.param, msg.recog, MakeLong(msg.tag, msg.series))
	elseif SM_HERO_LEVELUP == ident then
		g_data.hero:setBagSize(msg.tag)
		g_data.hero.ability:set("level", msg.param)
		self:tip("你的英雄升级了")

		if self.panels.heroBag then
			self.panels.heroBag:reloadAll(g_data.hero.bagSize)
		end

		if self.panels.heroHead then
			self.panels.heroHead:upt()
		end
	elseif SM_TOHEROBAG_OK == ident then
		if g_data.client.heroPutInItem then
			g_data.client.heroPutInItem:set("makeIndex", MakeLong(msg.param, msg.tag))

			if self.panels.bag then
				self.panels.bag:delItem(g_data.client.heroPutInItem:get("makeIndex"))
			end

			g_data.bag:delItem(g_data.client.heroPutInItem:get("makeIndex"))
			g_data.heroBag:addItem(g_data.client.heroPutInItem)

			if self.panels.heroBag then
				self.panels.heroBag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
			end

			g_data.client:setHeroPutInItem()
			PileUpItem(true)
		end
	elseif SM_TOHEROBAG_FAIL == ident then
		if g_data.client.heroPutInItem then
			g_data.bag:addItem(g_data.client.heroPutInItem)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
			end

			g_data.client:setHeroPutInItem()
		end
	elseif SM_TOHUMBAG_OK == ident then
		if g_data.client.heroGetBackItem then
			g_data.client.heroGetBackItem:set("makeIndex", MakeLong(msg.param, msg.tag))

			if self.panels.heroBag then
				self.panels.heroBag:delItem(g_data.client.heroGetBackItem:get("makeIndex"))
			end

			g_data.heroBag:delItem(g_data.client.heroGetBackItem:get("makeIndex"))
			g_data.bag:addItem(g_data.client.heroGetBackItem)

			if self.panels.bag then
				self.panels.bag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
			end

			g_data.client:setHeroGetBackItem()
			PileUpItem()
		end
	elseif SM_TOHUMBAG_FAIL == ident then
		if g_data.client.heroGetBackItem then
			g_data.heroBag:addItem(g_data.client.heroGetBackItem)

			if main_scene.ui.panels.heroBag then
				main_scene.ui.panels.heroBag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
			end

			g_data.client:setHeroGetBackItem()
		end
	elseif SM_HERO_ADDITEM == ident then
		local ret = g_data.heroBag:add(buf, bufLen)

		for i = 1, #ret do
			local v = ret[i]

			if v.where == "bag" and self.panels.heroBag then
				self.panels.heroBag:addItem(v.data:get("makeIndex"))
			end
		end

		PileUpItem(true)
	elseif SM_HERO_DELITEM == ident then
		local makeIndex = msg.recog

		if g_data.heroBag:delItem(makeIndex) and self.panels.heroBag then
			self.panels.heroBag:delItem(makeIndex)
		end

		if g_data.heroEquip:delItem(makeIndex) and self.panels.heroEquip then
			self.panels.heroEquip:delItem(makeIndex)
		end
	elseif SM_HERO_DROPITEM_SUCCESS == ident then
		g_data.heroBag:throwEnd(msg.recog, true)
	elseif SM_HERO_DROPITEM_FAIL == ident then
		g_data.heroBag:throwEnd(msg.recog, false)

		if self.panels.heroBag then
			self.panels.heroBag:addItem(msg.recog)
		end
	elseif SM_HERO_EAT_OK == ident then
		g_data.heroBag:useEnd("eat", true)
	elseif SM_HERO_EAT_FAIL == ident then
		local makeIndex, _, _, where = g_data.heroBag:useEnd("eat", false)

		if makeIndex and self.panels.heroBag and where == "bag" then
			self.panels.heroBag:addItem(makeIndex)
		end
	elseif SM_HERO_TAKEON_OK == ident then
		local makeIndex = g_data.heroBag:useEnd("take", true)

		if self.panels.heroEquip and makeIndex then
			self.panels.heroEquip:setItem(makeIndex)
		end
	elseif SM_HERO_TAKEON_FAIL == ident then
		local makeIndex = g_data.heroBag:useEnd("take", false)

		if self.panels.heroBag and makeIndex then
			self.panels.heroBag:addItem(makeIndex)
		end
	elseif SM_HERO_TAKEOFF_OK == ident then
		g_data.heroEquip:takeOffEnd(true)
	elseif SM_HERO_TAKEOFF_FAIL == ident then
		local makeIndex = g_data.heroEquip:takeOffEnd(false)

		if self.panels.heroEquip and makeIndex then
			self.panels.heroEquip:setItem(makeIndex)
		end
	elseif SM_LOCK_EQUIP_STATE == ident then
		common.setLockEquipState(msg, buf, bufLen)
	elseif SM_LOCKEQUIP == ident then
		common.setBindEquipState(msg, buf, bufLen)
	elseif SM_SEND_RELATION_FRIEND == ident then
		g_data.relation:setFriends(msg, buf, bufLen)
	elseif SM_SEND_RELATION_ATTENTION == ident then
		g_data.relation:setAttentions(msg, buf, bufLen)
	elseif SM_SEND_RELATION_NORMBLACKLIST == ident then
		g_data.relation:setBlackList(msg, buf, bufLen)
	elseif SM_ADD_RELATION_FRIEND_OK == ident then
		local relation = import(".panel.relation", current)

		relation.onAddFriendOk(buf, msg.recog)
	elseif SM_ADD_RELATION_FRIEND_FAIL == ident then
		import(".panel.relation", current).onAddFriendFail(buf, msg.recog)
	elseif SM_ADD_RELATION_ATTENTION == ident then
		import(".panel.relation", current).onAddAtt(msg.recog)
	elseif SM_ADD_RELATION_NORMBLACKLIST == ident then
		import(".panel.relation", current).onAddBlack(msg.recog)
	elseif SM_DEL_RELATION_FRIEND == ident then
		import(".panel.relation", current).onDelFriend(msg.recog)
	elseif SM_DEL_RELATION_ATTENTION == ident then
		import(".panel.relation", current).onDelAtt(msg.recog)
	elseif SM_DEL_RELATION_NORMBLACKLIST == ident then
		import(".panel.relation", current).onDelBlack(msg.recog)
	elseif SM_UPDATE_ATTENTION_COLOR == ident then
		import(".panel.relation", current).onUptAttClr(msg.recog)
	elseif SM_UPDATE_RELATION_FRIEND == ident then
		g_data.relation:updateFriend(msg, buf, bufLen)
	elseif SM_UPDATE_RELATION_ATTENTION == ident then
		g_data.relation:updateAttention(msg, buf, bufLen)
	elseif SM_UPDATE_RELATION_NORMBLACKLIST == ident then
		g_data.relation:updateBlackList(msg, buf, bufLen)
	elseif SM_RELATION_MEMBER_ONLINE == ident then
		g_data.relation:online(msg, buf, bufLen)
	elseif SM_RELATION_MEMBER_OFFLINE == ident then
		g_data.relation:offline(msg, buf, bufLen)
	elseif SM_QUERY_STALL == ident then
		if msg.recog == 1 then
			if msg.tag == 0 then
				g_data.stall:set(msg, buf, bufLen)
				self:showPanel("stall")
			else
				g_data.stallOther:set(msg, buf, bufLen)
				self:showPanel("stallOther")
			end
		elseif msg.recog == -1 and msg.tag == 1 then
			self:tip("查询摊位失败！")
		elseif msg.recog == -2 and msg.tag == 0 then
			self:tip("有摊位物品未处理，请先领取再进行摆摊！")
		elseif msg.recog == -3 and msg.tag == 0 then
			self:tip("服务器发生错误！")
		end
	elseif SM_SET_STALL_TIMELV == ident then
		if msg.recog == 1 then
			if self.panels.stall then
				self.panels.stall:upt()
			end
		elseif msg.recog == -1 then
			self:tip("金币不足！")
		elseif msg.recog == -2 then
			self:tip("设置摆摊的时间超过上限！")
		elseif msg.recog == -3 then
			self:tip("设置摆摊的等级超过上限！")
		end
	elseif SM_SET_STALL_NAME == ident then
		if msg.recog == 1 then
			self:tip("修改摊位名称成功.")
		elseif msg.recog == -1 then
			self:tip("摊位名称过长！")
		elseif msg.recog == -2 then
			self:tip("摊位名称不合法！")
		elseif msg.recog == -3 then
			self:tip("摆摊中无法进行修改！")
		end
	elseif SM_ADD_STALLITEM == ident then
		if msg.recog == -1 then
			self:tip("增加物品失败！")
		elseif msg.recog == -2 then
			self:tip("摊位不存在！")
		elseif msg.recog == -3 then
			self:tip("物品不存在！")
		elseif msg.recog == -4 then
			self:tip("输入的数量不正确！")
		elseif msg.recog == -5 then
			self:tip("绑定的物品不可出售！")
		end
	elseif SM_DEL_STALLITEM == ident then
		if msg.recog == -1 then
			self:tip("物品已售出！")
		end
	elseif SM_CANCEL_STALL == ident then
		if msg.recog == -1 then
			p2("other", "[stall sys]: stall isn't exist or stall time is over")
		elseif msg.recog == -2 then
			self:tip("您的包裹空间不足,请到邮件收回物品！")
		end
	elseif SM_UPT_ADD_STALLITEM == ident then
		local makeIndex = g_data.stall:uptAddItem(msg, buf, bufLen)

		if self.panels.stall then
			self.panels.stall:addItem(makeIndex)
		end
	elseif SM_UPT_DEL_STALLITEM == ident then
		g_data.stall:uptDelItem(msg.recog)

		if self.panels.stall then
			self.panels.stall:delItem(msg.recog)
		end
	elseif SM_START_STALL == ident then
		if msg.recog == 1 then
			self:tip("摆摊成功.")
			g_data.stall:start()
		elseif msg.recog == -1 then
			self:tip("已有摊位，不能重复摆摊！")
		elseif msg.recog == -2 then
			self:tip("缺少摆摊材料！")
		elseif msg.recog == -3 then
			self:tip("金币不足！")
		elseif msg.recog == -4 then
			self:tip("创建摊位失败！")
		elseif msg.recog == -5 then
			self:tip("该范围内有其他玩家！")
		elseif msg.recog == -6 then
			self:tip("该范围不足以进行摆摊！")
		elseif msg.recog == -7 then
			self:tip("摊位时间已结束！")
		elseif msg.recog == -8 then
			self:tip("没有摆放物品售卖！")
		elseif msg.recog == -9 then
			self:tip("边界城区外无法摆摊！")
		end
	elseif SM_PAUSE_STALL == ident then
		if msg.recog == 1 then
			self:tip("暂停摆摊成功.")
			g_data.stall:pause()
		end
	elseif SM_BUY_STALLITEM == ident then
		if msg.recog == -1 then
			self:tip("包裹空间不足！")
		elseif msg.recog == -2 then
			self:tip("元宝不足！")
		elseif msg.recog == -3 then
			self:tip("金币不足！")
		elseif msg.recog == -4 then
			self:tip("已售完！")
		elseif msg.recog == -5 then
			self:tip("摊位已取消或不存在！")
		elseif msg.recog == -6 then
			self:tip("购买的物品数量超过出售数量！")
		elseif msg.recog == -7 then
			self:tip("扣除元宝失败！")
		end
	elseif SM_UPT_OTHER_DEL_STALLITEM == ident then
		g_data.stallOther:uptDelItem(msg)

		if self.panels.stallOther then
			self.panels.stallOther:delItem(msg.recog)
		end
	elseif SM_MESSAGE_STALL == ident then
		if msg.recog == 1 then
			self:tip("留言成功.")
		elseif msg.recog == -1 then
			self:tip("留言失败！")
		end
	elseif SM_QUERY_STALL_STATUS == ident then
		g_data.stall:setTime(msg.recog)
	elseif SM_FETCH_MAIL_LIST == ident then
		if msg.recog == 1 then
			g_data.mail:set(msg, buf, bufLen)

			if self.panels.mail then
				self.panels.mail:showContentByTag(msg.tag)
			end
		elseif msg.recog == -1 then
			self:tip("数据出错！")
		end
	elseif SM_FETCH_MAIL_INFO == ident then
		if msg.recog == 1 then
			local id, from = g_data.mail:parseMail(msg, buf, bufLen)

			if self.panels.mail then
				self.panels.mail:showMail(id, from)
			end
		elseif ident == -1 then
			self:tip("邮件查询失败！")
		end
	elseif SM_FETCH_ATTACH == ident then
		if msg.recog == 1 then
			local id, from = g_data.mail:attach()

			if id and from and self.panels.mail then
				self.panels.mail:showMail(id, from)
			end

			self:tip("领取附件成功.")
		elseif msg.recog == -1 then
			self:tip("您的包裹空间不足！")
		elseif msg.recog == -2 then
			self:tip("没有奖励可以领取！")
		elseif msg.recog == -3 then
			self:tip("金币超过上限！")
		elseif msg.recog == -4 then
			self:tip("领取元宝失败！")
		elseif msg.recog == -5 then
			self:tip("不在安全区无法领取附件！")
		end

		if msg.recog ~= 1 and self.panels.mail then
			self.panels.mail:stopAuto()
		end
	elseif SM_DEL_MAIL == ident then
		if msg.recog == 1 then
			local id, next, from = g_data.mail:del()

			if id and from and self.panels.mail then
				if from == "sys" then
					self.panels.mail:showMail(next, from)
				elseif from == "sell" then
					self.panels.mail:delMail(id, from)
				end
			end
		elseif msg.recog == -1 then
			self:tip("删除邮件失败！")
		end
	elseif SM_FETCH_ATTACH_OFFTM == ident then
		if msg.recog == 1 then
			local tag = g_data.mail:attachOfftm()

			if self.panels.mail then
				self.panels.mail:showContentByTag(tag)
			end
		elseif msg.recog == -1 then
			self:tip("您的包裹空间不足！")
		elseif msg.recog == -2 then
			self:tip("没有过期摊位物品！")
		end
	elseif SM_MAIL_INFO == ident then
		g_data.mail:setUnreadMailCnt(msg.recog)
		self.notice:uptMailCnt(g_data.mail.unreadCnt, msg.tag)
	elseif CM_CLEAR_ALLMAIL == ident then
		if msg.recog == 1 then
			self:tip("清除成功")
		elseif msg.recog == -1 then
			self:tip("清除失败！")
		end

		if self.panels.mail then
			self.panels.mail:refresh()
		end
	elseif checkExist(ident, SM_YBDEAL_QUERY_BUY, SM_YBDEAL_QUERY_SELL, SM_YBDEAL_HISTROY_BUY, SM_YBDEAL_HISTROY_SELL) then
		local tag = g_data.ybdeal:parseMsg(msg, buf, bufLen)

		if self.panels.ybdeal then
			self.panels.ybdeal:upt(tag)
		else
			self:showPanel("ybdeal", {
				tag = tag
			})
		end
	elseif SM_YBDEAL_BUY == ident then
		if msg.recog > 0 then
			g_data.ybdeal:removeBuyUnit(msg.recog)

			if self.panels.ybdeal then
				self.panels.ybdeal:upt(1)
			end
		elseif msg.recog == -1 then
			self:tip("包裹没有足够空间！")
		elseif msg.recog == -2 then
			self:tip("对方已取消！")
		elseif msg.recog == -3 then
			self:tip("元宝不足！")
		elseif msg.recog == -4 then
			self:tip("发生未知错误！")
		elseif msg.recog == -5 then
			self:tip("订单号错误！")
		elseif msg.recog == -6 then
			self:tip("卖家不存在！")
		elseif msg.recog == -8 then
			self:tip("未找到订单信息！")
		elseif msg.recog == -9 then
			self:tip("未找到订单信息！")
		end
	elseif SM_YBDEAL_BUY_CANCEL == ident then
		if msg.recog > 0 then
			g_data.ybdeal:removeBuyUnit(msg.recog)

			if self.panels.ybdeal then
				self.panels.ybdeal:upt(1)
			end
		elseif msg.recog == -1 then
			self:tip("对方已取消！")
		elseif msg.recog == -2 then
			self:tip("发生未知错误！")
		end
	elseif SM_YBDEAL_REFER_ITEMS1 == ident then
		if msg.recog == 1 then
			g_data.ybdeal:setSign(msg)

			if g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS1] and g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS2] and self.panels.ybdeal then
				self.panels.ybdeal:sellUpt()
			end
		elseif msg.recog == -1 then
			self:tip("买家账号不存在！")
		elseif msg.recog == -2 then
			self:tip("请输入买家姓名！")
		elseif msg.recog == -3 then
			self:tip("买家姓名含有非法字符！")
		elseif msg.recog == -4 then
			self:tip("不能出售给自己！")
		elseif msg.recog == -5 then
			self:tip("出售的物品不存在！")
		elseif msg.recog == -6 then
			self:tip("出售的装备处于锁定状态！")
		elseif msg.recog == -7 then
			self:tip("已经在交易状态！")
		elseif msg.recog == -8 then
			self:tip("输入的价格超出范围！")
		elseif msg.recog == -11 then
			self:tip("未达到对方设定的交易等级！")
		end
	elseif SM_YBDEAL_REFER_ITEMS2 == ident then
		if msg.recog == 1 then
			g_data.ybdeal:setSign(msg)

			if g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS1] and g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS2] and self.panels.ybdeal then
				self.panels.ybdeal:sellUpt()
			end
		elseif msg.recog == -1 then
			self:tip("输入的买家不合法！")
		elseif msg.recog == -2 then
			self:tip("输入的价格超出范围！")
		elseif msg.recog == -5 then
			self:tip("只能同时出售4单！")
		elseif msg.recog == -6 then
			self:tip("对方购买订单已满4单,无法接受新的订单！")
		elseif msg.recog == -7 then
			self:tip("出售的物品不存在！")
		end
	elseif SM_YBDEAL_SELL_CANCEL == ident then
		if msg.recog > 0 then
			g_data.ybdeal:removeSellUnit(msg.recog)

			if self.panels.ybdeal then
				self.panels.ybdeal:upt(2)
			end
		elseif msg.recog == -1 then
			self:tip("物品已售出！")
		elseif msg.recog == -2 then
			self:tip("超时无法取回！")
		end
	elseif SM_DISPLAY_YBDEAL_SET == ident then
		local tag = g_data.ybdeal:parseSetting(msg)

		if self.panels.ybdeal then
			self.panels.ybdeal:upt(tag)
		else
			self:showPanel("ybdeal", {
				tag = tag
			})
		end
	elseif SM_YBDEAL_Set_Operate == ident then
		if msg.recog == 0 then
			self:tip("设置成功.")
		elseif msg.recog == -1 then
			self:tip("设置错误,设定等级超过最大等级999！")
		end
	elseif SM_CHANNEL_CREATE == ident then
		if msg.recog ~= 0 then
			local _, str = import(".panel.voice", current).handleCode(msg.recog)

			an.newMsgbox(str)
		end
	elseif SM_CHANNEL_ENTER == ident then
		if msg.recog ~= 0 then
			local _, str = import(".panel.voice", current).handleCode(msg.recog)

			an.newMsgbox(str)
		end
	elseif SM_CHANNEL_EXIT == ident then
		if msg.recog ~= 0 then
			local _, str = import(".panel.voice", current).handleCode(msg.recog)

			an.newMsgbox(str)
		end
	elseif SM_CHANNEL_CHANGE_MODE == ident then
		if msg.recog ~= 0 then
			local _, str = import(".panel.voice", current).handleCode(msg.recog)

			an.newMsgbox(str)
		end
	elseif SM_CHANNEL_CHANGE_MUTE == ident then
		if msg.recog ~= 0 then
			local _, str = import(".panel.voice", current).handleCode(msg.recog)

			an.newMsgbox(str)
		end
	elseif SM_CHANNEL_KICK_OUT == ident then
		if msg.recog ~= 0 then
			local _, str = import(".panel.voice", current).handleCode(msg.recog)

			an.newMsgbox(str)
		end
	elseif SM_SEND_CHANNEL_LIST == ident then
		if self.panels.voice then
			self.panels.voice:recvChannelList(msg, buf, bufLen)
		end
	elseif SM_SEND_CHANNEL_MEMBERS == ident then
		if msg.series == 1 then
			g_data.voice:setMembers(msg, buf, bufLen, msg.tag, common.getPlayerName())
		end

		if self.panels.voice then
			self.panels.voice:recvMemberList(msg, buf, bufLen, msg.tag, msg.series == 1)
		end
	elseif SM_NOTIFY_CHANNEL_ENTER == ident then
		local name = net.str(buf)
		local data, log = g_data.voice:memberJoin(msg.param, name, msg.tag)

		if data and self.panels.voice then
			self.panels.voice:memberJoin(data, log)
		end
	elseif SM_NOTIFY_CHANNEL_EXIT == ident then
		local name = net.str(buf)
		local isSelfExit, log = g_data.voice:memberExit(name, msg.tag, common.getPlayerName())

		if isSelfExit then
			local tipstr = nil

			if msg.tag == 1 then
				tipstr = "你被管理员踢出语音频道"
			elseif msg.tag == 2 then
				tipstr = "你已退出语音频道"
			elseif msg.tag == 3 then
				tipstr = "你所在的语音频道已解散"
			end

			if self.panels.voice then
				self.panels.voice:exitChannel(msg.tag)

				if tipstr then
					an.newMsgbox(tipstr)
				end
			elseif tipstr then
				common.addMsg(tipstr, display.COLOR_RED, display.COLOR_WHITE, true)
			end

			self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		elseif self.panels.voice then
			self.panels.voice:memberExit(name, log)
		end
	elseif SM_NOTIFY_CHANNEL_CHANGE_MODE == ident then
		local ok, log = g_data.voice:setMode(msg.param)

		if ok and self.panels.voice then
			self.panels.voice:modeChanged(log)
		end

		yaya.mic(false, common.getPlayerName())
		self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
	elseif SM_NOTIFY_CHANNEL_CHANGE_MUTE == ident then
		local name = net.str(buf)
		local data, log = g_data.voice:setIsMute(msg.param, name)

		if data and self.panels.voice then
			self.panels.voice:setIsMute(data, log)
		end

		if name == common.getPlayerName() then
			yaya.mic(false, common.getPlayerName())
			self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		end
	elseif SM_NOTIFY_CHANNEL_CHANGE_ADMIN == ident then
		local name = net.str(buf)
		local data, log = g_data.voice:setIsAdmin(msg.param, name)

		if data and self.panels.voice then
			self.panels.voice:setIsAdmin(data, log)
		end

		if name == common.getPlayerName() then
			yaya.mic(false, common.getPlayerName())
			self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		end
	elseif SM_QUERY_MAP_NPC == ident then
		g_data.bigmap:addNpcs(msg, buf, bufLen)

		if self.panels.bigmap then
			self.panels.bigmap:uptNpcCell()
		end
	elseif SM_MEMBERS_POSITION_INFO == ident then
		if msg.recog == 0 then
			g_data.bigmap:getGroupInfo(msg, buf, bufLen)

			if self.panels.bigmap then
				self.panels.bigmap:uptGroupPos()
			end
		end
	elseif SM_AUTOMOVE_MAPPATH == ident then
		g_data.bigmap:scriptAutoPath(msg, buf, bufLen)
		main_scene.ui.console.controller.autoFindPath:scriptAutoPath()
	elseif SM_GHOME_PAY_READY == ident then
		g_data.shop:onPayReady(msg.recog, buf, common.getPlayerName())
	elseif SM_SEND_GHOME_ORDER_RESULT == ident then
		g_data.shop:onPayResult(msg.recog, buf)
	elseif SM_GHOME_UNFINISH_ORDER == ident then
		-- Nothing
	elseif SM_PLAYER_AUTHEN == ident then
		g_data.credit:setAuthen(msg)
	elseif SM_NOWDEATH == ident then
		if msg.recog == g_data.player.roleid then
			self.centerTopTip:show("relive")
		end
	elseif SM_SEND_MAKEDDRUG_CONFIG == ident then
		g_data.mixingDrug:saveConfig(msg, buf, bufLen)
	elseif SM_ALL_MAKEDRUG_STATUS == ident then
		g_data.mixingDrug:set(msg, buf, bufLen)

		if self.panels.mixingDrug then
			self:hidePanel("mixingDrug")
		end

		self:showPanel("mixingDrug")
	elseif SM_MAKEDRUG_STATUS == ident then
		local act, data = g_data.mixingDrug:query(msg, buf, bufLen)

		if act and data and self.panels.mixingDrug then
			self.panels.mixingDrug:showDetail(act, data, msg.recog)
		end
	elseif SM_CAN_MAKEDRUG == ident then
		if msg.param == 0 then
			self:tip("开始炼制")

			if self.panels.mixingDrug then
				self.panels.mixingDrug:refresh()
			end
		elseif msg.param == 1 then
			self:tip("材料不足")
		elseif msg.param == 2 then
			self:tip("金币不足")
		end
	elseif SM_GAIN_MAKEDDRUG == ident then
		if msg.param == 1 then
			self:tip("存放成功")

			if self.panels.mixingDrug then
				self.panels.mixingDrug:refresh()
			end
		else
			self:tip("存放失败")
		end
	elseif SM_LEARN_LIVINGSKILL == ident then
		if msg.recog == 1 then
			self:tip("学习成功")

			if self.panels.mixingDrug then
				self.panels.mixingDrug:refresh()
			end
		else
			self:tip("学习失败")
		end
	elseif SM_V_POWERSTONE == ident then
		local str = ""

		if msg.param == 0 then
			local info = "充满着能量波动的神秘水晶，使用它可以使你增加1点活力值。"
			str = string.format("%s\n每个角色一天只能使用12个活力水晶,今日还可以使用%d个。", info, msg.tag)
		elseif msg.param == 1 then
			str = "活力值已达上限"
		elseif msg.param == 2 then
			str = "今日使用个数已达上限"
		end

		an.newMsgbox(str, function (idx)
			if idx == 1 and msg.param == 0 and g_data.bag:use("eat", msg.recog, {
				quick = false
			}) then
				net.send({
					CM_EAT,
					recog = msg.recog
				})

				if msg.series == 1 then
					self.panels.bag:delItem(msg.recog)
				end
			end
		end, {
			center = true,
			btnTexts = {
				"确定",
				msg.param == 0 and "取消" or nil
			}
		})
	elseif SM_BOX2_TRYOPEN == ident then
		if msg.recog == 0 then
			self:showPanel("treasureBox", msg.param, buf, bufLen)
		else
			self:tip(net.str(buf))
		end
	elseif SM_BOX2_ROTATE == ident then
		if msg.recog == 0 then
			if self.panels.treasureBox then
				print(msg.param)
				self.panels.treasureBox:onRotate(msg.param)
			end
		else
			self:tip(net.str(buf))
		end
	elseif SM_BOX2_GETPRIZE == ident then
		if msg.recog == 0 then
			if self.panels.treasureBox then
				self.panels.treasureBox:onGetPrize(msg.param)
			end
		else
			self:tip(net.str(buf))
		end
	else
		return false
	end

	return true
end

return mainui
