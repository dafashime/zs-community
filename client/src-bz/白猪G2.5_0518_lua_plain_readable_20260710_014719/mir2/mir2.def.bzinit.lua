local value3
local value2
local value6
local value16
local items8 = {
	ctor = function(notice)
		notice.panels = {}
		notice.customs = {}
		notice.leftTopTip = import(".common.leftTopTip", value3).new():add2(notice, notice.z.leftTopTip)
		notice.centerTopTip = import(".common.centerTopTip", value3).new():add2(notice, notice.z.centerTopTip)

		notice:loadConsole()

		notice.notice = import(".common.notice", value3).new():add2(notice, notice.z.focus)
	end,
	onEnter = function(value)
		return
	end,
	onExit = function(value)
		return
	end,
	loadConsole = function(console)
		if console.console then
			console.console:removeSelf()
		end

		console.console = import(".console.console", value3).new():addTo(console)
	end,
	showPanel = function(value, value27, ...)
		if value.panels[value27] then
			return
		end

		local value26 = value27

		if WIN32_OPERATE and value27 == "equip" then
			value26 = value27 .. "Pc"
		end

		if IS_PLAYER_DEBUG then
			package.loaded["mir2.scenes.main.panel." .. value27] = nil
			package.loaded["mir2.scenes.main.panel." .. value26] = nil
		end

		local value28 = import(".panel." .. value26, value3).new(...):addTo(value, value.z.focus)

		value16.extend(value28, value27, value)

		if not main_scene.ui.isChoseItem then
			if value.lastFocus then
				value.lastFocus:setLocalZOrder(0)
			end

			value.lastFocus = value28
		else
			value28:setLocalZOrder(0)
		end

		value.panels[value27] = value28

		main_scene.ground.helper:openPanel(value27)

		return value28
	end,
	hidePanel = function(value, value26)
		if not value.panels[value26] then
			return
		end

		if value.lastFocus == value.panels[value26] then
			value.lastFocus = nil
		end

		value.panels[value26]:removeSelf()

		value.panels[value26] = nil
	end,
	togglePanel = function(value, value26, value27)
		if value.panels[value26] then
			value.panels[value26]:hidePanel()
		else
			value:showPanel(value26, value27)
		end
	end,
	hideAll = function(value)
		for _, panel in pairs(value.panels) do
			panel:removeSelf()
		end

		value.panels = {}
		value.lastFocus = nil
	end,
	tip = function(leftTopTipOwner, ...)
		leftTopTipOwner.leftTopTip:show(...)
	end,
	update = function(value, value26)
		value2.update(value26)
		value.console:update(value26)
		value6.update(value26)

		local point = main_scene.ground.player

		if point and value.panels.npc and value.panels.npc.x and value.panels.npc.y and (math.abs(value.panels.npc.x - point.x) > 8 or math.abs(value.panels.npc.y - point.y) > 8) then
			value:hidePanel("npc")
		end

		if point and value.panels.storage and value.panels.storage.x and value.panels.storage.y and (math.abs(value.panels.storage.x - point.x) > 8 or math.abs(value.panels.storage.y - point.y) > 8) then
			value:hidePanel("storage")
		end
	end,
	checkUsedItemforStopAutoRat = function(value, value26)
		if value26 then
			local var = value26.getVar("name")

			if type(var) == "string" then
				for index, item in pairs({
					"盟重传送石",
					"比奇传送石"
				}) do
					if string.find(var, item) then
						main_scene.ui.console.autoRat:stop()
					end
				end
			end
		end
	end,
	processMsg = function(value, value26, value27, value29)
		if not value26 then
			return
		end

		local function callback5(self, value4)
			local msgbox = an.newMsgbox("", value4)

			an.newLabel(self, 20, 1, {
				color = def.colors.labelGray
			}):addTo(msgbox):pos(msgbox:centerPos()):anchor(0.5, 0.5)
		end

		local function callback6(self)
			if not g_data.player.IsSplliteItem then
				local items11 = self and g_data.heroBag:PileUpNext() or g_data.bag:PileUpNext()

				if type(items11) == "table" and #items11 == 2 then
					net.send({
						CM_PILEUPITEM,
						recog = items11[1]:get("makeIndex"),
						param = Loword(items11[2]:get("makeIndex")),
						tag = Hiword(items11[2]:get("makeIndex")),
						series = self and 1 or 0
					})
					g_data.player:setIsinPileUping(true)
				end
			end

			g_data.player:setIsSplliting(false)
		end

		local value28 = value26.ident

		if SM_ABILITY == value28 then
			g_data.player:setAbility(value26, value27, value29)
			main_scene.ground.map:addMsg({
				roleid = g_data.player.roleid,
				job = g_data.player.job
			})
			value.console:call("infoBar", "uptAbility")
			value.console:call("bottom", "upt")
			value.console:hidePet()

			if main_scene.ground.player then
				main_scene.ground.player.info:setHP(g_data.player.ability:get("HP"), g_data.player.ability:get("maxHP"))
			end

			if g_data.serverConfig.allowMaxLevel <= g_data.player.ability:get("level") then
				value2.addMsg(string.format("您的等级已经达到上限%d级，将不能再获取经验。", g_data.serverConfig.allowMaxLevel), def.colors.clWhite, def.colors.clBlue, true)
			end

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end

			main_scene.ground.helper:checkFirstLogin()
		elseif SM_GETDIAMNUM_EXT == value28 then
			if value29 == getRecordSize("TMessageCapitalInfo") then
				g_data.player:setCapitalInfo(value27, value29)
				main_scene.ui.console:call("infoBar", "uptYb")

				if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
					main_scene.ui.panels.equip:showContent("attributes")
				end
			end
		elseif checkExist(value28, SM_HEAR, SM_CRY, SM_GROUPMESSAGE, SM_CORPSMESSAGE, SM_GUILDMESSAGE, SM_SYSMESSAGE, SM_WHISPER, SM_BROADCASTMESSAGE) then
			if value27 then
				local value30 = net.strs(value27)

				if value6.filterChat(value30[1], value28, value26) and g_data.relation:filterChat(value2.getPlayerName(), value30[1], value28, value26) then
					value2.addMsg(value30[1], Lobyte(value26.param), Hibyte(value26.param), nil, value26.recog, value26, value27, value29)
				end
			end
		elseif SM_QUERY_FOCUS_ITEM == value28 then
			value2.uptItemMsgData(net.record("TClientItem", value27, value29))
		elseif SM_MENU_OK == value28 or SM_DLGMSG == value28 then
			local value31 = net.str(value27)

			if value31 ~= "" then
				callback5(value31)
			end
		elseif SM_CLIENT_CONF == value28 then
			g_data.chat:setShieldMask(value26.recog)
			value2.refershChatContent()
		elseif SM_ATTACKMODE == value28 then
			local value32 = ({
				"[全体攻击模式]",
				"[和平攻击模式]",
				"[编组攻击模式]",
				"[行会攻击模式]",
				"[敌对攻击模式]",
				"[战队攻击模式]"
			})[value26.recog + 1] or "[未知攻击模式]"

			g_data.player:setAttackMode(value32)
			value.console:call("btnMode", "upt")
			value2.addMsg(value32, 219, 256)
		elseif SM_SENDMYMAGIC == value28 then
			g_data.player:setMagicList(value27, value29)
			main_scene.ui.console.skills:upt()

			if value.panels.equip and value.panels.equip.page == "skill" then
				value.panels.equip:showContent("skill")
			end
		elseif SM_ADDMAGIC == value28 then
			local magicIdOwner = g_data.player:addMagic(value27, value29)

			if magicIdOwner then
				main_scene.ui.console.skills:layout(magicIdOwner.magicId)
			end

			main_scene.ui.console.skills:upt()

			if value.panels.equip and value.panels.equip.page == "skill" then
				value.panels.equip:showContent("skill")
			end
		elseif SM_MAGIC_LVEXP == value28 then
			local value33 = g_data.player:setMagicExp(value26, value27, value29)

			if value33 and value.panels.equip then
				value.panels.equip:updateMagic(value33:get("magicId"))
			end
		elseif SM_STAMINA == value28 then
			g_data.player:setStamina(value26.param, value26.recog)
			main_scene.ui.console:call("infoBar", "uptStamina")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		elseif SM_VITALITY == value28 then
			g_data.player:setVitality(value26.param, value26.recog)
			main_scene.ui.console:call("infoBar", "uptVitality")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		elseif SM_EXP_POOL == value28 then
			g_data.player:setExpPoolValue(value26.recog)
			main_scene.ui.console:call("infoBar", "uptExp")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		elseif SM_VITALITYITEM == value28 then
			g_data.player:setVitaliyitemValue(value26.recog)
			main_scene.ui.console:call("infoBar", "uptBlood")
		elseif SM_WINEXP == value28 then
			g_data.player.ability:set("Exp", value26.recog)

			local long = MakeLong(value26.param, value26.tag)

			if not g_data.setting.base.showExpEnable or g_data.setting.base.showExpEnable and long >= g_data.setting.base.showExpValue then
				if value26.series == TExpTypeEnergy then
					value:tip(long .. " 精力经验值增加")
				elseif value26.series == TExpTypePower then
					value:tip(long .. " 活力经验值增加")
				else
					value:tip(long .. " 经验值增加")
				end
			end

			value.console:call("bottom", "upt")
			value.console.autoRat:onExpUpdate()

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif SM_LEVELUP == value28 then
			g_data.player.ability:set("level", value26.param)
			value:tip("升级!")
			main_scene.ui.console:call("infoBar", "uptLevel")
			main_scene.ground.helper.runner.onLevelUp(value26.param)
		elseif SM_BAGITEMS == value28 then
			g_data.bag:set(value27, value29)

			if value.panels.bag then
				value.panels.bag:reload()
			end
		elseif SM_SENDUSEITEMS == value28 then
			g_data.equip:set(value27, value29)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "equip" then
				main_scene.ui.panels.equip:showContent("equip")
			end
		elseif SM_SENDUSERSTATE == value28 then
			local record = getRecord("TUserStateInfo")

			net.record(record, value27, value29)
			value:hidePanel("equipOther")
			value:showPanel("equipOther", record)
			g_data.client:setLastTime("queryOther")
		elseif SM_SEND_TITLEINFO == value28 then
			g_data.player:initTitle(value26, value27, value29)

			if main_scene.ui.panels.equip then
				main_scene.ui.panels.equip:showContent("title")
			end
		elseif SM_SET_CURTITLE == value28 then
			if value26.series == 0 then
				g_data.player:setTitleResult(value26)

				if main_scene.ui.panels.equip then
					main_scene.ui.panels.equip:showContent("title")
				end
			end
		elseif SM_UPDATE_TITLE == value28 then
			g_data.player:updateTitleInfo(value26, value27, value29)

			if main_scene.ui.panels.equip then
				main_scene.ui.panels.equip:showContent("title")
			end
		elseif SM_UPDATE_TITLE_DURA == value28 then
			g_data.player:updateTitleCount(value26, value27, value29)
		elseif SM_ADDITEM == value28 then
			local items11 = g_data.bag:add(value27, value29)

			for index = 1, #items11 do
				local response = items11[index]

				value:tip(response.data.getVar("name") .. " 被发现")

				if response.where == "bag" and value.panels.bag then
					value.panels.bag:addItem(response.data:get("makeIndex"))
				end

				main_scene.ground.helper.runner.onNewItem(response.data:get("Index"))
			end

			callback6()
		elseif SM_ITEM_PILEUP_RESULT == value28 then
			g_data.player:setIsinPileUping(false)

			if value26.series == 0 then
				callback6()
			elseif value26.series == 1 then
				callback6(true)
			end
		elseif SM_DELITEM == value28 then
			local value34 = value26.recog

			if value26.param == 0 then
				if g_data.bag:delItem(value34) and value.panels.bag then
					value.panels.bag:delItem(value34)
				end

				if g_data.equip:delItem(value34) and value.panels.equip then
					value.panels.equip:delItem(value34)
				end

				if value.panels.strengthen then
					value.panels.strengthen:delItem(value34)
				end
			elseif value26.param == 1 and value.panels.storage then
				value.panels.storage:delItem(value34)
				value.panels.storage:delItemData(value34)
			end
		elseif SM_UPDATEITEM == value28 then
			local value35 = g_data.bag:upt(value27, value29)

			if value35 and value.panels.bag then
				value.panels.bag:uptItem(value35)
			end

			if value35 and value.panels.strengthen then
				value.panels.strengthen:uptItem(value35)
			end

			local value36 = g_data.equip:upt(value27, value29)

			if value36 and value.panels.equip then
				value.panels.equip:uptItem(value36)
			end
		elseif SM_BAGITEMDURACHG == value28 then
			g_data.bag:duraChange(value26.recog, value26.param, value26.tag, value26.series)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:duraChange(value26.recog, value26.param, value26.tag, value26.series)
			end

			if value.panels.strengthen then
				value.panels.strengthen:duraChange(value26.recog)
			end
		elseif SM_DURACHANGE == value28 then
			g_data.equip:duraChange(value26.param, value26.recog, MakeLong(value26.tag, value26.series))
		elseif SM_DELITEMS == value28 then
			local items12 = {}
			local value37 = math.floor(value29 / 4)

			if value37 > 0 then
				for index2 = 1, value37 do
					items12[#items12 + 1], value27, value29 = net.uint(value27, value29)
				end
			end

			for _, item in ipairs(items12) do
				if g_data.bag:delItem(item) and value.panels.bag then
					value.panels.bag:delItem(item)
				end

				if g_data.equip:delItem(item) and value.panels.equip then
					value.panels.equip:delItem(item)
				end

				g_data.bag:delQuickItem(item)
			end
		elseif SM_DROPITEM_SUCCESS == value28 then
			g_data.bag:throwEnd(value26.recog, true)
		elseif SM_DROPITEM_FAIL == value28 then
			g_data.bag:throwEnd(value26.recog, false)

			if value.panels.bag then
				value.panels.bag:addItem(value26.recog)
			end
		elseif SM_WEIGHTCHANGED == value28 then
			g_data.player:weightChanged(value26.recog, value26.param, value26.tag)
			main_scene.ui.console:call("infoBar", "uptBag")
		elseif SM_EATITEM_OK == value28 then
			local value38, value39, value40 = g_data.bag:useEnd("eat", true)

			main_scene.ui.console:fillPropTest()
			value:checkUsedItemforStopAutoRat(value39)
		elseif SM_EATITEM_FAIL == value28 then
			local value41, value42, value43, value44 = g_data.bag:useEnd("eat", false)

			if value41 and value.panels.bag then
				value.panels.bag:addItem(value41)
			end

			value:checkUsedItemforStopAutoRat(value42)
		elseif SM_TAKEON_OK == value28 then
			local value45 = value26.recog

			if value29 == getRecordSize("TFeature") then
				value45 = net.record("TFeature", value27, value29)
			end

			main_scene.ground.map.player:changeFeature(value45)

			local value46 = g_data.bag:useEnd("take", true)

			if value.panels.equip and value46 then
				value.panels.equip:setItem(value46)
			end
		elseif SM_TAKEON_FAIL == value28 then
			local value47 = g_data.bag:useEnd("take", false)

			if value.panels.bag and value47 then
				value.panels.bag:addItem(value47)
			end

			local text17 = ""
			local value48 = value26.recog == -1 and "该物品获得后自动锁定，锁定期过后才可正常使用。" or value26.recog == -2 and "穿戴位置不正确" or value26.recog == -3 and "二级密码锁定状态不能更换装备" or value26.recog == -4 and "密保锁定。" or value26.recog == -6 and "装备基础条件不满足" or value26.recog == -7 and "超重" or value26.recog == -8 and "声望不足" or value26.recog == -9 and "装备基础条件不满足" or value26.recog == -10 and "职业不满足" or value26.recog == -11 and "职业不满足" or value26.recog == -12 and "不能穿戴" or "未知错误"

			value2.addMsg(value48, display.COLOR_RED, display.COLOR_WHITE, true)
		elseif SM_TAKEOFF_OK == value28 then
			local value49 = value26.recog

			if value29 == getRecordSize("TFeature") then
				value49 = net.record("TFeature", value27, value29)
			end

			main_scene.ground.map.player:changeFeature(value49)
			g_data.equip:takeOffEnd(true)
		elseif SM_TAKEOFF_FAIL == value28 then
			local value50 = g_data.equip:takeOffEnd(false)

			if value.panels.equip and value50 then
				value.panels.equip:setItem(value50)
			end
		elseif SM_MERCHANTSAY == value28 then
			body = net.str(value27)

			local npcName = ""
			local value51 = string.find(body, "/")

			if value51 then
				npcName = string.sub(body, 1, value51 - 1)
				body = string.sub(body, value51 + 1, string.len(body))
			end

			print("接收到的商人说的话")
			value:hidePanel("npc")
			value:showPanel("npc", {
				merchant = value26.recog,
				face = value26.param,
				npcName = npcName,
				body = body
			})

			if value.panels.bag then
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_MERCHANTDLGCLOSE == value28 then
			value:hidePanel("npc")
		elseif SM_MERCHANT_QUERY == value28 then
			if value26.tag == 0 then
				if value.panels.npc then
					value.panels.npc:showInput(value26, value27, value29)
				end
			elseif value26.tag == 1 then
				local value52 = net.str(value27)
				local tag = value26.tag
				local recog = value26.recog
				local param = value26.param
				local msgbox = an.newMsgbox(value52, function(value4)
					net.send({
						CM_MERCHANT_QUERY,
						recog = recog,
						param = param,
						tag = tag,
						series = value4 - 1
					})
				end, {
					disableScroll = true,
					btnTexts = {
						"取消",
						"同意"
					}
				})
			elseif value26.tag == 3 then
				-- block empty
			end
		elseif SM_SENDGOODSLIST == value28 then
			if value.panels.npc then
				value.panels.npc:showList(value26.recog, value26.param, value27, value29, "goods")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDDETAILGOODS == value28 then
			if value.panels.npc then
				value.panels.npc:showList(value26.recog, value26.param, value27, value29, "goods_detail", value26.tag)
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDMAKEDRUGITEMS == value28 then
			if value.panels.npc then
				value.panels.npc:showList(value26.recog, value26.param, value27, value29, "synthesis", value26.tag)
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SAVEITEMLIST == value28 then
			value:hidePanel("storage")
			value:showPanel("storage", value26.recog, value26.param, value26.tag, value27, value29)
		elseif SM_BUYITEM_SUCCESS == value28 then
			g_data.client:setLastTime("buy")
			value2.goldChanged(value26.recog)

			if value.panels.npc then
				value.panels.npc:removeItem(MakeLong(value26.param, value26.tag))
			end
		elseif SM_BUYITEM_FAIL == value28 then
			g_data.client:setLastTime("buy")

			if value26.recog == 1 then
				an.newMsgbox("此物品被卖出.", nil, {
					center = true
				})
			elseif value26.recog == 2 then
				an.newMsgbox("您无法携带更多物品了.", nil, {
					center = true
				})
			elseif value26.recog == 3 then
				an.newMsgbox("您没有足够的钱来购买此物品.", nil, {
					center = true
				})
			else
				an.newMsgbox("未知错误: " .. value26.recog, nil, {
					center = true
				})
			end
		elseif SM_SENDUSERREPAIR == value28 then
			if value.panels.npc then
				value.panels.npc:showSellFrame(value26.recog, "repair")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDUSERSELL == value28 then
			if value.panels.npc then
				value.panels.npc:showSellFrame(value26.recog, "sell")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDUSERSTORAGEITEM == value28 then
			if value.panels.npc then
				value.panels.npc:showSellFrame(value26.recog, "storage")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDREPAIRCOST == value28 or SM_SENDBUYPRICE == value28 then
			if value.panels.npc then
				value.panels.npc:setSellText(value26.recog >= 0 and value26.recog .. " 金币" or "???? 金币")
			end
		elseif SM_OPEN_COMMIT_ITEM == value28 then
			print("弹出兑换物品框")

			if value.panels.npc then
				value.panels.npc:showSellFrame(value26.recog, "exchange", value26.series)
				value.panels.npc:setSellText(net.str(value27))
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_COMMIT_ITEM == value28 then
			if value26.param == 1 then
				if value.panels.npc then
					value.panels.npc:delSellItem()
				end

				if g_data.client.lastSellItem then
					if value.panels.bag then
						value.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
					end

					g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.client:setLastTime("sell")
				g_data.client:setLastSellItem()
			elseif value26.param == 0 then
				if value.panels.npc then
					value.panels.npc:delSellItem()
				end

				if value29 > 0 then
					local value53 = net.str(value27)

					value2.addMsg(value53, display.COLOR_GREEN, display.COLOR_WHITE, true)
				end
			end
		elseif SM_USERSELLITEM_OK == value28 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			if g_data.client.lastSellItem then
				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.client:setLastTime("sell")
			g_data.client:setLastSellItem()
		elseif SM_USERSELLITEM_FAIL == value28 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			g_data.client:setLastTime("sell")
			g_data.client:setLastSellItem()
			an.newMsgbox("您不能出售该物品，可能是以下原因：\n1.    绑定物品和高级物品无法出售\n2.    请前往对应商店出售物品\n3.    可携带金币超出上限(未验证角色可携带200万金币，已验证角色可携带5000万金币)")
		elseif SM_USERREPAIRITEM_OK == value28 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			if g_data.client.lastSellItem then
				g_data.client.lastSellItem:set("dura", value26.param)
				g_data.client.lastSellItem:set("duraMax", value26.tag)
			end

			g_data.client:setLastSellItem()
			g_data.client:setLastTime("sell")
		elseif SM_USERREPAIRITEM_FAIL == value28 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			g_data.client:setLastSellItem()
			g_data.client:setLastTime("sell")
			an.newMsgbox("您不能修理此物品.", nil, {
				center = true
			})
		elseif SM_MAKEDRUG_FAIL == value28 then
			local text18 = ""

			if value26.recog == 3 then
				text18 = "金币不够 "
			elseif value26.recog == 4 then
				text18 = "材料不足"
			elseif value26.recog == 2 then
				text18 = "合成成功，获取物品失败"
			end

			value:tip(text18)
		elseif checkExist(value28, SM_STORAGE_OK, SM_STORAGE_FULL, SM_STORAGE_FAIL) then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			if SM_STORAGE_OK == value28 and g_data.client.lastSellItem then
				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.client:setLastSellItem()
			g_data.client:setLastTime("sell")

			if g_data.client.storageItem then
				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.storageItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.storageItem:get("makeIndex"))

				if SM_STORAGE_OK == value28 then
					if value.panels.storage then
						value.panels.storage:addItem(g_data.client.storageItem)
					end
				else
					g_data.bag:addItem(g_data.client.storageItem)

					if main_scene.ui.panels.bag then
						main_scene.ui.panels.bag:addItem(g_data.client.storageItem:get("makeIndex"))
					end
				end
			end

			g_data.client:setStorageItem()

			if SM_STORAGE_FULL == value28 then
				an.newMsgbox("你的个人仓库已满，你不能再寄存任何物品。", nil, {
					center = true
				})
			elseif SM_STORAGE_FAIL == value28 then
				value:tip("寄存失败。")
			end
		elseif SM_GETSTORAGEITEM_OK == value28 then
			g_data.client:setStorageGetBackItem()
			g_data.client:setLastTime("buy")

			if value.panels.npc then
				value.panels.npc:removeItem(value26.recog)
			end
		elseif SM_GETSTORAGEITEM_FAIL == value28 then
			local text19 = ""

			if value26.recog == -1 then
				text19 = "您已无法携带这么重的物品了"
			elseif value26.recog == -2 then
				text19 = "在交易中无法使用仓库功能"
			elseif value26.recog == -3 then
				text19 = "你的仓库已被盛大CD卡、或密宝绑定，如需取出物品请先开启仓库"
			end

			g_data.client:setLastTime("buy")
			value:tip(text19)

			if g_data.client.storageGetBackItem then
				if value.panels.storage then
					value.panels.storage:addItem(g_data.client.storageGetBackItem)
				end

				g_data.client:setStorageGetBackItem()
			end
		elseif SM_GETSTORAGEITEM_FULLBAG == value28 then
			g_data.client:setLastTime("buy")
			an.newMsgbox("您无法携带更多物品了.")

			if g_data.client.storageGetBackItem then
				if value.panels.storage then
					value.panels.storage:addItem(g_data.client.storageGetBackItem)
				end

				g_data.client:setStorageGetBackItem()
			end
		elseif SM_STORAGEITEMDURACHG == value28 then
			if value.panels.storage then
				value.panels.storage:duraChange(value26.recog, value26.param, value26.tag, value26.series)
			end
		elseif SM_STORAGE_ADDITEM == value28 then
			if main_scene.ui.panels.storage then
				main_scene.ui.panels.storage:splitNemItem(value26, value27, value29)
			end
		elseif SM_GOLDCHANGED == value28 then
			value2.goldChanged(value26.recog)
		elseif SM_PLAYDICE == value28 then
			value2.showBosonResult(value26, value27, value29)
		elseif SM_SHOWBOOK == value28 then
			print("书本")
		elseif SM_DEALMENU == value28 then
			g_data.client:setLastTime("deal")
			value:hidePanel("deal")
			value:showPanel("deal", net.str(value27))
			value:showPanel("bag")
		elseif SM_DEALTRY_FAIL == value28 then
			g_data.client:setLastTime("deal")
			callback5("交易被取消。\n要正确交易你必须和对方面对面。")
		elseif SM_DEALADDITEM_OK == value28 then
			g_data.client:setLastTime("deal")

			if g_data.client.dealItem then
				g_data.client:addDealItem(g_data.client.dealItem)

				if value.panels.deal then
					value.panels.deal:addItem("self", g_data.client.dealItem)
				end

				g_data.client:setNowDealItem()
			end
		elseif SM_DEALADDITEM_FAIL == value28 then
			g_data.client:setLastTime("deal")

			if g_data.client.dealItem then
				g_data.bag:addItem(g_data.client.dealItem)

				if value.panels.bag then
					value.panels.bag:addItem(g_data.client.dealItem:get("makeIndex"))
				end

				g_data.client:setNowDealItem()
			end
		elseif SM_DEALDELITEM_OK == value28 then
			-- block empty
		elseif SM_DEALDELITEM_FAIL == value28 then
			-- block empty
		elseif SM_DEALCANCEL == value28 then
			for _2, dealItem in ipairs(g_data.client.dealItems) do
				g_data.bag:addItem(dealItem)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(dealItem:get("makeIndex"))
				end
			end

			if g_data.client.dealGold > 0 then
				value2.goldChanged(g_data.player.gold + g_data.client.dealGold)
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
			value:hidePanel("deal")
		elseif SM_DEALREMOTEADDITEM == value28 then
			if value.panels.deal then
				local record2 = getRecord("TClientItem")

				net.record(record2, value27, getRecordSize("TClientItem"))
				value.panels.deal:addItem("target", record2)
			end
		elseif SM_DEALREMOTEDELITEM == value28 then
			if value.panels.deal then
				local record3 = getRecord("TClientItem")

				net.record(record3, value27, getRecordSize("TClientItem"))
				value.panels.deal:delItem("target", record3)
			end
		elseif SM_DEALCHGGOLD_OK == value28 or SM_DEALCHGGOLD_FAIL == value28 then
			g_data.client:setLastTime("deal")
			g_data.client:setDealGold(value26.recog)
			value2.goldChanged(MakeLong(value26.param, value26.tag))

			if value.panels.deal then
				value.panels.deal:setMoney("self", value26.recog)
			end
		elseif SM_DEALREMOTECHGGOLD == value28 then
			if value.panels.deal then
				value.panels.deal:setMoney("target", value26.recog)
			end
		elseif SM_DEALSUCCESS == value28 then
			value:hidePanel("deal")
			g_data.client:setDealGold()
			g_data.client:clearDealItem()
		elseif SM_GROUPMODECHANGED == value28 then
			g_data.player:setAllowGroup(value26.param > 0)
			g_data.client:setLastTime("group")

			if value.panels.group then
				value.panels.group:enableAllow()
			end
		elseif SM_CREATEGROUP_OK == value28 then
			g_data.player:setAllowGroup(true)
			g_data.client:setLastTime("group")

			if value.panels.group then
				value.panels.group:enableAllow()
			end
		elseif SM_JOINGROUP_FAIL == value28 then
			print("SM_JOINGROUP_FAIL", value26.recog)

			if value26.recog == -1 then
				callback5("玩家名错误或不在线。")
			elseif value26.recog == -2 then
				callback5("玩家队伍不存在")
			elseif value26.recog == -3 then
				callback5("不在允许组队状态")
			elseif value26.recog == -4 then
				callback5("队伍人数已满。")
			elseif value26.recog == -10 then
				callback5("不可邀请自己组队。")
			else
				callback5("未知错误。")
			end

			g_data.client:setLastTime("group")
		elseif SM_CREATEGROUP_FAIL == value28 then
			print("SM_CREATEGROUP_FAIL", value26.recog)

			if value26.recog == -1 then
				callback5("发起人已经创建队伍")
			elseif value26.recog == -2 then
				callback5("玩家名错误或不在线")
			elseif value26.recog == -6 then
				callback5("发起人不允许创建队伍")
			elseif value26.recog == -3 then
				callback5("该玩家已有队伍")
			elseif value26.recog == -4 then
				callback5("接受人不允许组队")
			elseif value26.recog == -10 then
				callback5("不可邀请自己组队")
			else
				callback5("未知错误")
			end

			g_data.client:setLastTime("group")
		elseif SM_GROUPADDMEM_OK == value28 then
			g_data.client:setLastTime("group")
			print("SM_GROUPADDMEM_OK 添加组员成功", value29)
		elseif SM_GROUPADDMEM_FAIL == value28 then
			print("SM_GROUPADDMEM_FAIL", value26.recog)

			if value26.recog == -1 then
				callback5("发起人不是队长")
			elseif value26.recog == -2 then
				callback5("玩家名错误或不在线")
			elseif value26.recog == -3 then
				callback5("该玩家已有队伍")
			elseif value26.recog == -4 then
				callback5("接受人不允许组队")
			elseif value26.recog == -5 then
				callback5("队伍已满")
			elseif value26.recog == -10 then
				callback5("不可邀请自己组队")
			else
				callback5("未知错误。")
			end

			g_data.client:setLastTime("group")
		elseif SM_GROUPDELMEM_OK == value28 then
			g_data.client:setLastTime("group")
			print("SM_GROUPDELMEM_OK 删除组员成功", value29, net.str(value27))
			g_data.player:delGroupMember(value27)

			if value.panels.group and value.panels.group.page == "mine" then
				value.panels.group:showPageInfo("mine", g_data.player.groupMembers)
			end
		elseif SM_GROUPDELMEM_FAIL == value28 then
			if value26.recog == -1 then
				callback5("队员不能删除其他成员")
			elseif value26.recog == -2 then
				callback5("输入的人物名称不正确")
			elseif value26.recog == -3 then
				callback5("删除目标不是队伍成员")
			else
				callback5("未知错误")
			end

			g_data.client:setLastTime("group")
		elseif SM_GROUPCANCEL == value28 then
			print("SM_GROUPCANCEL 解散队伍")
			g_data.player:setGroupMembers(nil)
			g_data.player:setTeamLeader(false)

			if value.panels.group and value.panels.group.page == "mine" then
				value.panels.group:showPageInfo("mine", g_data.player.groupMembers)
			end
		elseif SM_GROUPMEMBERS == value28 then
			print("SM_GROUPMEMBERS", value29, value26.param, getRecordSize("TClientGroupMemInfo"))
			g_data.player:initGroupMembers(value26, value27, value29)
			g_data.player:setTeamLeader(false)

			for _3, groupMember in ipairs(g_data.player.groupMembers) do
				if groupMember:get("name") == value2.getPlayerName() and groupMember:get("isCaptain") == 1 then
					g_data.player:setTeamLeader(true)

					break
				end
			end

			if value.panels.group and value.panels.group.page == "mine" then
				value.panels.group:showPageInfo("mine", g_data.player.groupMembers)
			end
		elseif SM_QUERY_NEARBYGROUP == value28 then
			print("SM_QUERY_NEARBYGROUP")
			g_data.player:initNearGroup(value26, value27, value29)

			if value.panels.group then
				value.panels.group:showPageInfo("group", g_data.player.nearGroupInfo)
			end
		elseif SM_QUERY_NEARBYPLAYER == value28 then
			print("SM_QUERY_NEARBYPLAYER", getRecordSize("TClientNearbyPlayerInfo"), value29)

			local value54 = g_data.relation:decodeNearPlayerBuf(value26, value27, value29)

			if value.panels.group and value.panels.group.page == "near" then
				value.panels.group:showPageInfo("near", value54)
			end

			if value.panels.relation and value.panels.relation.page == "near" then
				value.panels.relation:showContent("near", value54)
			end
		elseif SM_NotifyGroupMessage == value28 then
			print("SM_NotifyGroupMessage")

			local value55 = net.str(value27)
			local value56 = value26.param

			if value26.recog == 1 then
				value.notice:addMsg("FriendApply", {
					value55,
					value56
				})
			else
				value.notice:removeMsg("FriendApply", {
					value55,
					value56
				})
			end
		elseif SM_ORDER_LIST == value28 then
			g_data.client:setLastTime("top")

			if value.panels.top then
				value.panels.top:processUpt(value26.param, value26, value27, value29)
			end
		elseif SM_CORPS_NOTICE == value28 then
			dump(value26)
			print(" SM_CORPS_NOTICE ", value29 > 0 and net.str(value27) or "nil", value29)

			if value26.param == 0 then
				g_data.guild.clanNotice = value29 > 0 and net.str(value27) or ""
			end
		elseif SM_GILD_NOTICE == value28 then
			if value26.param == 0 then
				g_data.guild.guildNotice = value29 > 0 and net.str(value27) or ""
			end
		elseif SM_FIND_CORPS_BYNAME == value28 then
			print("模糊查找战队返回")
			dump(value26)

			g_data.guild.serach = true

			g_data.guild:initClanList(value26, value27, value29)

			if value.panels.guild and value.panels.guild.page == "clan" then
				value.panels.guild:uirefushContent("clan")
			end
		elseif SM_FIND_GILD_BYNAME == value28 then
			print("模糊查找行会返回")
			dump(value26)

			g_data.guild.serach = true

			g_data.guild:initGuildList(value26, value27, value29)

			if value.panels.guild and value.panels.guild.page == "tguild" then
				if value.panels.guild.showGuildListNode then
					value.panels.guild:showGuildList()
				else
					value.panels.guild:uirefushContent("tguild")
				end
			end
		elseif SM_CORPS_GET_RECRUIT_CONDITION == value28 then
			if value26.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value26.param)
				end
			else
				value.panels.guild:recruitCondition(value26, value27, value29)
			end
		elseif SM_PLAYER_POSITION == value28 then
			g_data.guild.posInfo = value26.tag

			local items13 = {
				"",
				"副队长",
				"队长",
				"副会长",
				"会长"
			}
		elseif SM_PLAYER_GILD == value28 then
			g_data.guild:initGuildInfo(value26, value27, value29)

			if value.panels.guild and value.panels.guild.page == "tguild" then
				value.panels.guild.subpage = nil

				value.panels.guild:uirefushContent("tguild")
			end
		elseif SM_PLAYER_CORPS == value28 then
			g_data.guild:initClanInfo(value26, value27, value29)

			if value.panels.guild and value.panels.guild.page == "clan" then
				value.panels.guild.subpage = nil

				value.panels.guild:uirefushContent("clan")
			end
		elseif SM_REFRESH_GILDINFO == value28 then
			g_data.guild:initGuildInfo(value26, value27, value29)

			if value.panels.guild and value.panels.guild.page == "tguild" and value.panels.guild.subpage == "guildmain" then
				value.panels.guild:refush("guildmain")
			end
		elseif SM_REFRESH_CORPSINFO == value28 then
			g_data.guild:initClanInfo(value26, value27, value29)

			if value.panels.guild and value.panels.guild.page == "clan" and value.panels.guild.subpage == "clanmain" then
				value.panels.guild:refush("clanmain")
			end
		elseif SM_CORPS_LIST == value28 then
			if value26.param == 0 then
				g_data.guild.serach = false
				g_data.guild.page = value26.recog

				g_data.guild:initClanList(value26, value27, value29)

				g_data.guild.getCorpsList = true

				if value.panels.guild and value.panels.guild.page == "clan" then
					value.panels.guild:uirefushContent("clan")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_REQUEST_JOIN == value28 then
			if value26.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value26.param)
				end
			else
				value:tip("申请加入战队成功")
			end
		elseif SM_CORPS_CANCEL_JOIN == value28 then
			if value26.param == 0 then
				value:tip("取消申请加入战队成功")
			end
		elseif SM_CORPS_TRANSFER_CAPTAIN == value28 then
			if value26.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value26.param)
				end
			else
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end
		elseif SM_CORPS_APPOINT_VICE_CAPTAIN == value28 or SM_CORPS_DISMISS_VICE_CAPTAIN == value28 then
			if value26.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value26.param)
				end
			else
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end
		elseif SM_CORPS_STEPDOWN == value28 then
			if value26.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value26.param)
				end
			else
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end
		elseif SM_CORPS_EXIT == value28 then
			if value26.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value26.param)
				end
			else
				g_data.guild.guildInfo = nil
				g_data.guild.clanInfo = nil

				if value.panels.guild and value.panels.guild.page == "clan" then
					value.panels.guild.subpage = nil

					value.panels.guild:uirefushContent("clan")
				end
			end
		elseif SM_CORPS_QUERY_REQUESTS == value28 then
			g_data.guild:getCorpsQueryRequests(value26, value27, value29)

			if value.panels.guild and value.panels.guild.subpage == "clanjobs" then
				value.panels.guild:refush("clanjobs")
			end
		elseif SM_CORPS_ACCEPT_REQUEST == value28 then
			if value26.param == 0 then
				net.send({
					CM_CORPS_QUERY_REQUESTS,
					tag = 30,
					param = 0
				})
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_REFUSE_REQUEST == value28 then
			if value26.param == 0 then
				net.send({
					CM_CORPS_QUERY_REQUESTS,
					tag = 30,
					param = 0
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_DISMISS_MEMBER == value28 then
			if value26.param == 0 then
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_CREATE == value28 then
			if value26.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_MEMBER_LIST == value28 then
			if value26.param == 0 then
				if value26.recog == 0 then
					g_data.guild:getCorpsMem(value26, value27, value29)

					if value.panels.guild then
						value.panels.guild:refush("clanmem")
					end
				else
					g_data.guild:getGuildCorpsMem(value26, value27, value29)

					if value.panels.guild then
						value.panels.guild:showOtherClanMem()
					end
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_SET_MEMBER_TITLE == value28 then
			if value26.param == 0 then
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_SEND_APPLYCORPS_ID == value28 then
			g_data.guild:refushCurClan(value26, value27, value29)

			local instance = cc.Director:getInstance():getEventDispatcher()
			local value57 = cc.EventCustom:new("UpdateNilClanState")

			instance:dispatchEvent(value57)
		elseif SM_SEND_APPLYGILD_ID == value28 then
			g_data.guild:refushCurGuild(value26, value27, value29)

			local instance2 = cc.Director:getInstance():getEventDispatcher()
			local value58 = cc.EventCustom:new("UpdateNilGuildState")

			instance2:dispatchEvent(value58)
		elseif SM_CORPS_DIRECT_ADD_MEMBER == value28 then
			if value26.param == 0 then
				value:tip("面对面找人请求发送成功！")
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CORPS_QUERY_LOG == value28 then
			g_data.guild:getCorpsLog(value26, value27, value29)

			if value.panels.guild then
				value.panels.guild:refush("clanlog")
			end
		elseif SM_GILD_LIST == value28 then
			if value26.param == 0 then
				g_data.guild.serach = false
				g_data.guild.page = value26.recog

				g_data.guild:initGuildList(value26, value27, value29)

				g_data.guild.getguildList = true

				if value.panels.guild and value.panels.guild.page == "tguild" then
					if value.panels.guild.showGuildListNode then
						value.panels.guild:showGuildList()
					else
						value.panels.guild:uirefushContent("tguild")
					end
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_EXIT == value28 then
			if value26.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_QUERY_CORPS == value28 then
			if value26.param == 0 then
				g_data.guild:getguildcorpsList(value26, value27, value29)

				if value.panels.guild then
					value.panels.guild:refush("claninfo")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_QUERY_REQUEST_JOIN_LIST == value28 then
			if value26.param == 0 then
				g_data.guild:getGuildQueryRequests(value26, value27, value29)

				if value.panels.guild and value.panels.guild.subpage == "clanrecruit" then
					value.panels.guild:refush("clanrecruit")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_REQUEST_JOIN == value28 then
			if value26.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_ACCEPT_REQUEST == value28 then
			if value26.param == 0 then
				print("------")

				if value26.recog == 1 then
					net.send({
						CM_GILD_QUERY_REQUEST_JOIN_LIST,
						tag = 30,
						series = 0
					})
				elseif value26.recog == 2 then
					net.send({
						CM_GILD_QUERY_REQUEST_UNION_LIST,
						tag = 30,
						series = 0
					})
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_REFUSE_REQUEST == value28 then
			if value26.param == 0 then
				print("------")

				if value26.recog == 1 then
					net.send({
						CM_GILD_QUERY_REQUEST_JOIN_LIST,
						tag = 30,
						series = 0
					})
				elseif value26.recog == 2 then
					net.send({
						CM_GILD_QUERY_REQUEST_UNION_LIST,
						tag = 30,
						series = 0
					})
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_DISMISS_CORPS == value28 then
			if value26.param == 0 then
				print("+++++++++++++++++++++++")
				net.send({
					CM_GILD_QUERY_CORPS
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_CHANGE_MEMBER == value28 then
			-- block empty
		elseif SM_GILDMEMBER_LIST == value28 then
			if value26.param == 0 then
				g_data.guild:getguildMem(value26, value27, value29)

				if value.panels.guild then
					value.panels.guild:refush("mem")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_QUERY_LOG == value28 then
			g_data.guild:getGuildLog(value26, value27, value29)

			if value.panels.guild then
				value.panels.guild:refush("log")
			end
		elseif SM_GILD_QUERY_REQUEST_UNION_LIST == value28 then
			g_data.guild:getRequestUnion(value26, value27, value29)

			if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
				print(value.panels.guild.subpage or " nil ")
				print("")
				value.panels.guild:showSubDiplomatic4()
			end
		elseif SM_GILD_REQUEST_UNION == value28 then
			if value26.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_BREAK_UNION == value28 then
			if value26.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value26.param)
			end

			net.send({
				CM_GILD_QUERY_UNION,
				tag = 30,
				series = 0
			})
		elseif SM_GILD_QUERY_HOSTILE == value28 then
			if value26.param == 0 then
				g_data.guild:getHostile(value26, value27, value29)

				if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
					value.panels.guild:showSubDiplomatic2()
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_QUERY_UNION == value28 then
			g_data.guild:getUnion(value26, value27, value29)

			if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
				if value.panels.guild.showGuildListNode then
					value.panels.guild:showGuildList()
				else
					value.panels.guild:showSubDiplomatic1()
				end
			end
		elseif SM_GILD_QUERY_CONCERN == value28 then
			if value26.param == 0 then
				g_data.guild:getConcern(value26, value27, value29)

				if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
					value.panels.guild:showSubDiplomatic3()
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_VICECAPTAIN_STEPDOWN == value28 or SM_GILD_DISMISS_VICECAPTAIN == value28 or SM_GILD_APPOINT_VICE_PRESIDENT == value28 or SM_GILD_TRANSFER_PRESIDENT == value28 then
			if value26.param == 0 then
				net.send({
					CM_GILDMEMBER_LIST
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_CONCERN_GILD_ID == value28 then
			if value26.param == 0 then
				net.send({
					CM_GILD_QUERY_CONCERN,
					tag = 30,
					series = 0
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_CANCLE_CONCERN == value28 then
			if value26.param == 0 then
				net.send({
					CM_GILD_QUERY_CONCERN,
					tag = 30,
					series = 0
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_DECLARE_WAR == value28 then
			if value26.param == 0 then
				if value.panels.guild then
					if value.panels.guild.threeSub == 2 then
						net.send({
							CM_GILD_QUERY_HOSTILE,
							tag = 30,
							series = 0
						})
					elseif value.panels.guild.threeSub == 3 then
						net.send({
							CM_GILD_QUERY_CONCERN,
							tag = 30,
							series = 0
						})
					end
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_GILD_ENABLE_UNION == value28 then
			if value26.param == 0 then
				local value59 = g_data.guild.guildInfo:get("enableUnion")

				g_data.guild.guildInfo:set("enableUnion", value59 == 0 and 1 or 0)
			elseif value.panels.guild then
				value.panels.guild:showError(value26.param)
			end
		elseif SM_SEND_REFUSE_REQUEST == value28 then
			if value29 == getRecordSize("TRefuseRequestType") then
				local record4 = getRecord("TRefuseRequestType")

				net.record(record4, value27, value29)

				local text20 = ""

				if record4:get("type") == 3 then
					text20 = record4:get("name") .. " 拒绝了您的联盟请求！"
				else
					text20 = "您加入" .. (record4:get("type") == 1 and "战队 " or "行会 ") .. record4:get("name") .. " 的请求已经被拒绝!"
				end

				value:tip(text20)
				value:tip(text20)
				value:tip(text20)
			end
		elseif SM_STRENGTHEN_EQUIP_QUEST == value28 then
			if value.panels.fusion then
				value.panels.fusion:addItems(value26, value27, value29)
			end
		elseif SM_STRENGTHEN_EQUIP == value28 then
			if value.panels.fusion then
				value.panels.fusion:fusionEquip(value26, value27, value29)
			end
		elseif SM_UPDATE_CLOTHES == value28 then
			if value26.recog == 0 then
				value:tip("强化成功")

				if value.panels.strengthen then
					value.panels.strengthen:showResult()
				end
			elseif value.panels.strengthen then
				value.panels.strengthen:showError(value26)
			end
		elseif SM_SHOPITEMS == value28 then
			if value29 == 0 then
				return
			end

			local value60 = g_data.shop:parseContent(value26, value27, value29)

			if value.panels.shop then
				value.panels.shop:processUpt(value26.param, value60)
			end
		elseif SM_FIRSTSHOP == value28 then
			if value29 == 0 then
				return
			end

			local value61 = g_data.shop:parseSpecially(value27, value29)

			if value.panels.shop then
				value.panels.shop:processUpt(5, value61)
			end
		elseif SM_DOSHOP_FAIL == value28 then
			import(".panel.shop", value3).onDoShopFail(value28, value26.recog, value26.param)
		elseif SM_HERO_ABILITY == value28 then
			g_data.hero:setAbility(value26, value27, value29)
			main_scene.ground.map:addMsg({
				roleid = g_data.hero.roleid,
				job = g_data.hero.job
			})

			if value.panels.heroHead then
				value.panels.heroHead:upt()
			end
		elseif SM_GLORYFEALTY == value28 then
			g_data.hero:setGloryFealty(value26.param, value26.tag)
		elseif SM_HERO_BAGITEMS == value28 then
			g_data.hero:setBagSize(value26.series)
			g_data.heroBag:set(value27, value29)

			if value.panels.heroBag and not value.panels.heroBag:reloadAll(g_data.hero.bagSize) then
				value.panels.heroBag:reload()
			end
		elseif SM_HERO_BAGITEMDURACHG == value28 then
			g_data.heroBag:duraChange(value26.recog, value26.param, value26.tag, value26.series)

			if main_scene.ui.panels.heroBag then
				main_scene.ui.panels.heroBag:duraChange(value26.recog, value26.param, value26.tag, value26.series)
			end
		elseif SM_HERO_SENDUSEITEMS == value28 then
			g_data.heroEquip:set(value27, value29)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "equip" then
				main_scene.ui.panels.heroEquip:showContent("equip")
			end
		elseif SM_HERO_SENDMYMAGIC == value28 then
			g_data.hero:setMagicList(value27, value29)

			if value.panels.heroEquip and value.panels.heroEquip.page == "skill" then
				value.panels.heroEquip:showContent("skill")
			end
		elseif SM_HERO_ADDMAGIC == value28 then
			g_data.hero:addMagic(value27, value29)

			if value.panels.heroEquip and value.panels.heroEquip.page == "skill" then
				value.panels.heroEquip:showContent("skill")
			end
		elseif SM_HERO_WINEXP == value28 then
			g_data.hero.ability:set("Exp", value26.recog)

			local long2 = MakeLong(value26.param, value26.tag)

			value:tip(long2 .. " 英雄经验值增加")

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end
		elseif SM_HERO_MAGIC_LVEXP == value28 then
			local value62 = g_data.hero:setMagicExp(value26, value27, value29)

			if value62 and value.panels.heroEquip then
				value.panels.heroEquip:updateMagic(value62:get("magicId"))
			end
		elseif SM_HERO_UNIONSTATUS == value28 then
			g_data.hero:setUnionState(value26.recog, value26.param)
			main_scene.ui.console:call("btnHeroSkill", "hero_upt_union")
		elseif SM_HERO_DURACHANGE == value28 then
			g_data.heroEquip:duraChange(value26.param, value26.recog, MakeLong(value26.tag, value26.series))
		elseif SM_HERO_LEVELUP == value28 then
			g_data.hero:setBagSize(value26.tag)
			g_data.hero.ability:set("level", value26.param)
			value:tip("你的英雄升级了")

			if value.panels.heroBag then
				value.panels.heroBag:reloadAll(g_data.hero.bagSize)
			end

			if value.panels.heroHead then
				value.panels.heroHead:upt()
			end
		elseif SM_TOHEROBAG_OK == value28 then
			if g_data.client.heroPutInItem then
				g_data.client.heroPutInItem:set("makeIndex", MakeLong(value26.param, value26.tag))

				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.heroPutInItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.heroPutInItem:get("makeIndex"))
				g_data.heroBag:addItem(g_data.client.heroPutInItem)

				if value.panels.heroBag then
					value.panels.heroBag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
				end

				g_data.client:setHeroPutInItem()
				callback6(true)
			end
		elseif SM_TOHEROBAG_FAIL == value28 then
			if g_data.client.heroPutInItem then
				g_data.bag:addItem(g_data.client.heroPutInItem)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
				end

				g_data.client:setHeroPutInItem()
			end
		elseif SM_TOHUMBAG_OK == value28 then
			if g_data.client.heroGetBackItem then
				g_data.client.heroGetBackItem:set("makeIndex", MakeLong(value26.param, value26.tag))

				if value.panels.heroBag then
					value.panels.heroBag:delItem(g_data.client.heroGetBackItem:get("makeIndex"))
				end

				g_data.heroBag:delItem(g_data.client.heroGetBackItem:get("makeIndex"))
				g_data.bag:addItem(g_data.client.heroGetBackItem)

				if value.panels.bag then
					value.panels.bag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
				end

				g_data.client:setHeroGetBackItem()
				callback6()
			end
		elseif SM_TOHUMBAG_FAIL == value28 then
			if g_data.client.heroGetBackItem then
				g_data.heroBag:addItem(g_data.client.heroGetBackItem)

				if main_scene.ui.panels.heroBag then
					main_scene.ui.panels.heroBag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
				end

				g_data.client:setHeroGetBackItem()
			end
		elseif SM_HERO_ADDITEM == value28 then
			local items14 = g_data.heroBag:add(value27, value29)

			for index3 = 1, #items14 do
				local response2 = items14[index3]

				if response2.where == "bag" and value.panels.heroBag then
					value.panels.heroBag:addItem(response2.data:get("makeIndex"))
				end
			end

			callback6(true)
		elseif SM_HERO_DELITEM == value28 then
			local value63 = value26.recog

			if g_data.heroBag:delItem(value63) and value.panels.heroBag then
				value.panels.heroBag:delItem(value63)
			end

			if g_data.heroEquip:delItem(value63) and value.panels.heroEquip then
				value.panels.heroEquip:delItem(value63)
			end
		elseif SM_HERO_DROPITEM_SUCCESS == value28 then
			g_data.heroBag:throwEnd(value26.recog, true)
		elseif SM_HERO_DROPITEM_FAIL == value28 then
			g_data.heroBag:throwEnd(value26.recog, false)

			if value.panels.heroBag then
				value.panels.heroBag:addItem(value26.recog)
			end
		elseif SM_HERO_EAT_OK == value28 then
			g_data.heroBag:useEnd("eat", true)
		elseif SM_HERO_EAT_FAIL == value28 then
			local value64, value65, value66, value67 = g_data.heroBag:useEnd("eat", false)

			if value64 and value.panels.heroBag and value67 == "bag" then
				value.panels.heroBag:addItem(value64)
			end
		elseif SM_HERO_TAKEON_OK == value28 then
			local value68 = g_data.heroBag:useEnd("take", true)

			if value.panels.heroEquip and value68 then
				value.panels.heroEquip:setItem(value68)
			end
		elseif SM_HERO_TAKEON_FAIL == value28 then
			local value69 = g_data.heroBag:useEnd("take", false)

			if value.panels.heroBag and value69 then
				value.panels.heroBag:addItem(value69)
			end
		elseif SM_HERO_TAKEOFF_OK == value28 then
			g_data.heroEquip:takeOffEnd(true)
		elseif SM_HERO_TAKEOFF_FAIL == value28 then
			local value70 = g_data.heroEquip:takeOffEnd(false)

			if value.panels.heroEquip and value70 then
				value.panels.heroEquip:setItem(value70)
			end
		elseif SM_LOCK_EQUIP_STATE == value28 then
			value2.setLockEquipState(value26, value27, value29)
		elseif SM_LOCKEQUIP == value28 then
			value2.setBindEquipState(value26, value27, value29)
		elseif SM_SEND_RELATION_FRIEND == value28 then
			g_data.relation:setFriends(value26, value27, value29)
		elseif SM_SEND_RELATION_ATTENTION == value28 then
			g_data.relation:setAttentions(value26, value27, value29)
		elseif SM_SEND_RELATION_NORMBLACKLIST == value28 then
			g_data.relation:setBlackList(value26, value27, value29)
		elseif SM_ADD_RELATION_FRIEND_OK == value28 then
			import(".panel.relation", value3).onAddFriendOk(value27, value26.recog)
		elseif SM_ADD_RELATION_FRIEND_FAIL == value28 then
			import(".panel.relation", value3).onAddFriendFail(value27, value26.recog)
		elseif SM_ADD_RELATION_ATTENTION == value28 then
			import(".panel.relation", value3).onAddAtt(value26.recog)
		elseif SM_ADD_RELATION_NORMBLACKLIST == value28 then
			import(".panel.relation", value3).onAddBlack(value26.recog)
		elseif SM_DEL_RELATION_FRIEND == value28 then
			import(".panel.relation", value3).onDelFriend(value26.recog)
		elseif SM_DEL_RELATION_ATTENTION == value28 then
			import(".panel.relation", value3).onDelAtt(value26.recog)
		elseif SM_DEL_RELATION_NORMBLACKLIST == value28 then
			import(".panel.relation", value3).onDelBlack(value26.recog)
		elseif SM_UPDATE_ATTENTION_COLOR == value28 then
			import(".panel.relation", value3).onUptAttClr(value26.recog)
		elseif SM_UPDATE_RELATION_FRIEND == value28 then
			g_data.relation:updateFriend(value26, value27, value29)
		elseif SM_UPDATE_RELATION_ATTENTION == value28 then
			g_data.relation:updateAttention(value26, value27, value29)
		elseif SM_UPDATE_RELATION_NORMBLACKLIST == value28 then
			g_data.relation:updateBlackList(value26, value27, value29)
		elseif SM_RELATION_MEMBER_ONLINE == value28 then
			g_data.relation:online(value26, value27, value29)
		elseif SM_RELATION_MEMBER_OFFLINE == value28 then
			g_data.relation:offline(value26, value27, value29)
		elseif SM_QUERY_STALL == value28 then
			if value26.recog == 1 then
				if value26.tag == 0 then
					g_data.stall:set(value26, value27, value29)
					value:showPanel("stall")
				else
					g_data.stallOther:set(value26, value27, value29)
					value:showPanel("stallOther")
				end
			elseif value26.recog == -1 and value26.tag == 1 then
				value:tip("查询摊位失败！")
			elseif value26.recog == -2 and value26.tag == 0 then
				value:tip("有摊位物品未处理，请先领取再进行摆摊！")
			elseif value26.recog == -3 and value26.tag == 0 then
				value:tip("服务器发生错误！")
			end
		elseif SM_SET_STALL_TIMELV == value28 then
			if value26.recog == 1 then
				if value.panels.stall then
					value.panels.stall:upt()
				end
			elseif value26.recog == -1 then
				value:tip("金币不足！")
			elseif value26.recog == -2 then
				value:tip("设置摆摊的时间超过上限！")
			elseif value26.recog == -3 then
				value:tip("设置摆摊的等级超过上限！")
			end
		elseif SM_SET_STALL_NAME == value28 then
			if value26.recog == 1 then
				value:tip("修改摊位名称成功.")
			elseif value26.recog == -1 then
				value:tip("摊位名称过长！")
			elseif value26.recog == -2 then
				value:tip("摊位名称不合法！")
			elseif value26.recog == -3 then
				value:tip("摆摊中无法进行修改！")
			end
		elseif SM_ADD_STALLITEM == value28 then
			if value26.recog == -1 then
				value:tip("增加物品失败！")
			elseif value26.recog == -2 then
				value:tip("摊位不存在！")
			elseif value26.recog == -3 then
				value:tip("物品不存在！")
			elseif value26.recog == -4 then
				value:tip("输入的数量不正确！")
			elseif value26.recog == -5 then
				value:tip("绑定的物品不可出售！")
			end
		elseif SM_DEL_STALLITEM == value28 then
			if value26.recog == -1 then
				value:tip("物品已售出！")
			end
		elseif SM_CANCEL_STALL == value28 then
			if value26.recog == -1 then
				p2("other", "[stall sys]: stall isn't exist or stall time is over")
			elseif value26.recog == -2 then
				value:tip("您的包裹空间不足,请到邮件收回物品！")
			end
		elseif SM_UPT_ADD_STALLITEM == value28 then
			local value71 = g_data.stall:uptAddItem(value26, value27, value29)

			if value.panels.stall then
				value.panels.stall:addItem(value71)
			end
		elseif SM_UPT_DEL_STALLITEM == value28 then
			g_data.stall:uptDelItem(value26.recog)

			if value.panels.stall then
				value.panels.stall:delItem(value26.recog)
			end
		elseif SM_START_STALL == value28 then
			if value26.recog == 1 then
				value:tip("摆摊成功.")
				g_data.stall:start()
			elseif value26.recog == -1 then
				value:tip("已有摊位，不能重复摆摊！")
			elseif value26.recog == -2 then
				value:tip("缺少摆摊材料！")
			elseif value26.recog == -3 then
				value:tip("金币不足！")
			elseif value26.recog == -4 then
				value:tip("创建摊位失败！")
			elseif value26.recog == -5 then
				value:tip("该范围内有其他玩家！")
			elseif value26.recog == -6 then
				value:tip("该范围不足以进行摆摊！")
			elseif value26.recog == -7 then
				value:tip("摊位时间已结束！")
			elseif value26.recog == -8 then
				value:tip("没有摆放物品售卖！")
			elseif value26.recog == -9 then
				value:tip("边界城区外无法摆摊！")
			end
		elseif SM_PAUSE_STALL == value28 then
			if value26.recog == 1 then
				value:tip("暂停摆摊成功.")
				g_data.stall:pause()
			end
		elseif SM_BUY_STALLITEM == value28 then
			if value26.recog == -1 then
				value:tip("包裹空间不足！")
			elseif value26.recog == -2 then
				value:tip("元宝不足！")
			elseif value26.recog == -3 then
				value:tip("金币不足！")
			elseif value26.recog == -4 then
				value:tip("已售完！")
			elseif value26.recog == -5 then
				value:tip("摊位已取消或不存在！")
			elseif value26.recog == -6 then
				value:tip("购买的物品数量超过出售数量！")
			elseif value26.recog == -7 then
				value:tip("扣除元宝失败！")
			end
		elseif SM_UPT_OTHER_DEL_STALLITEM == value28 then
			g_data.stallOther:uptDelItem(value26)

			if value.panels.stallOther then
				value.panels.stallOther:delItem(value26.recog)
			end
		elseif SM_MESSAGE_STALL == value28 then
			if value26.recog == 1 then
				value:tip("留言成功.")
			elseif value26.recog == -1 then
				value:tip("留言失败！")
			end
		elseif SM_QUERY_STALL_STATUS == value28 then
			g_data.stall:setTime(value26.recog)
		elseif SM_FETCH_MAIL_LIST == value28 then
			if value26.recog == 1 then
				g_data.mail:set(value26, value27, value29)

				if value.panels.mail then
					value.panels.mail:showContentByTag(value26.tag)
				end
			elseif value26.recog == -1 then
				value:tip("数据出错！")
			end
		elseif SM_FETCH_MAIL_INFO == value28 then
			if value26.recog == 1 then
				local value72, value73 = g_data.mail:parseMail(value26, value27, value29)

				if value.panels.mail then
					value.panels.mail:showMail(value72, value73)
				end
			elseif value28 == -1 then
				value:tip("邮件查询失败！")
			end
		elseif SM_FETCH_ATTACH == value28 then
			if value26.recog == 1 then
				local value74, value75 = g_data.mail:attach()

				if value74 and value75 and value.panels.mail then
					value.panels.mail:showMail(value74, value75)
				end

				value:tip("领取附件成功.")
			elseif value26.recog == -1 then
				value:tip("您的包裹空间不足！")
			elseif value26.recog == -2 then
				value:tip("没有奖励可以领取！")
			elseif value26.recog == -3 then
				value:tip("金币超过上限！")
			elseif value26.recog == -4 then
				value:tip("领取元宝失败！")
			elseif value26.recog == -5 then
				value:tip("不在安全区无法领取附件！")
			end

			if value26.recog ~= 1 and value.panels.mail then
				value.panels.mail:stopAuto()
			end
		elseif SM_DEL_MAIL == value28 then
			if value26.recog == 1 then
				local value76, value77, value78 = g_data.mail:del()

				if value76 and value78 and value.panels.mail then
					if value78 == "sys" then
						value.panels.mail:showMail(value77, value78)
					elseif value78 == "sell" then
						value.panels.mail:delMail(value76, value78)
					end
				end
			elseif value26.recog == -1 then
				value:tip("删除邮件失败！")
			end
		elseif SM_FETCH_ATTACH_OFFTM == value28 then
			if value26.recog == 1 then
				local value79 = g_data.mail:attachOfftm()

				if value.panels.mail then
					value.panels.mail:showContentByTag(value79)
				end
			elseif value26.recog == -1 then
				value:tip("您的包裹空间不足！")
			elseif value26.recog == -2 then
				value:tip("没有过期摊位物品！")
			end
		elseif SM_MAIL_INFO == value28 then
			g_data.mail:setUnreadMailCnt(value26.recog)
			value.notice:uptMailCnt(g_data.mail.unreadCnt, value26.tag)
		elseif CM_CLEAR_ALLMAIL == value28 then
			if value26.recog == 1 then
				value:tip("清除成功")
			elseif value26.recog == -1 then
				value:tip("清除失败！")
			end

			if value.panels.mail then
				value.panels.mail:refresh()
			end
		elseif checkExist(value28, SM_YBDEAL_QUERY_BUY, SM_YBDEAL_QUERY_SELL, SM_YBDEAL_HISTROY_BUY, SM_YBDEAL_HISTROY_SELL) then
			local tag2 = g_data.ybdeal:parseMsg(value26, value27, value29)

			if value.panels.ybdeal then
				value.panels.ybdeal:upt(tag2)
			else
				value:showPanel("ybdeal", {
					tag = tag2
				})
			end
		elseif SM_YBDEAL_BUY == value28 then
			if value26.recog > 0 then
				g_data.ybdeal:removeBuyUnit(value26.recog)

				if value.panels.ybdeal then
					value.panels.ybdeal:upt(1)
				end
			elseif value26.recog == -1 then
				value:tip("包裹没有足够空间！")
			elseif value26.recog == -2 then
				value:tip("对方已取消！")
			elseif value26.recog == -3 then
				value:tip("元宝不足！")
			elseif value26.recog == -4 then
				value:tip("发生未知错误！")
			elseif value26.recog == -5 then
				value:tip("订单号错误！")
			elseif value26.recog == -6 then
				value:tip("卖家不存在！")
			elseif value26.recog == -8 then
				value:tip("未找到订单信息！")
			elseif value26.recog == -9 then
				value:tip("未找到订单信息！")
			end
		elseif SM_YBDEAL_BUY_CANCEL == value28 then
			if value26.recog > 0 then
				g_data.ybdeal:removeBuyUnit(value26.recog)

				if value.panels.ybdeal then
					value.panels.ybdeal:upt(1)
				end
			elseif value26.recog == -1 then
				value:tip("对方已取消！")
			elseif value26.recog == -2 then
				value:tip("发生未知错误！")
			end
		elseif SM_YBDEAL_REFER_ITEMS1 == value28 then
			if value26.recog == 1 then
				g_data.ybdeal:setSign(value26)

				if g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS1] and g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS2] and value.panels.ybdeal then
					value.panels.ybdeal:sellUpt()
				end
			elseif value26.recog == -1 then
				value:tip("买家账号不存在！")
			elseif value26.recog == -2 then
				value:tip("请输入买家姓名！")
			elseif value26.recog == -3 then
				value:tip("买家姓名含有非法字符！")
			elseif value26.recog == -4 then
				value:tip("不能出售给自己！")
			elseif value26.recog == -5 then
				value:tip("出售的物品不存在！")
			elseif value26.recog == -6 then
				value:tip("出售的装备处于锁定状态！")
			elseif value26.recog == -7 then
				value:tip("已经在交易状态！")
			elseif value26.recog == -8 then
				value:tip("输入的价格超出范围！")
			elseif value26.recog == -11 then
				value:tip("未达到对方设定的交易等级！")
			end
		elseif SM_YBDEAL_REFER_ITEMS2 == value28 then
			if value26.recog == 1 then
				g_data.ybdeal:setSign(value26)

				if g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS1] and g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS2] and value.panels.ybdeal then
					value.panels.ybdeal:sellUpt()
				end
			elseif value26.recog == -1 then
				value:tip("输入的买家不合法！")
			elseif value26.recog == -2 then
				value:tip("输入的价格超出范围！")
			elseif value26.recog == -5 then
				value:tip("只能同时出售4单！")
			elseif value26.recog == -6 then
				value:tip("对方购买订单已满4单,无法接受新的订单！")
			elseif value26.recog == -7 then
				value:tip("出售的物品不存在！")
			end
		elseif SM_YBDEAL_SELL_CANCEL == value28 then
			if value26.recog > 0 then
				g_data.ybdeal:removeSellUnit(value26.recog)

				if value.panels.ybdeal then
					value.panels.ybdeal:upt(2)
				end
			elseif value26.recog == -1 then
				value:tip("物品已售出！")
			elseif value26.recog == -2 then
				value:tip("超时无法取回！")
			end
		elseif SM_DISPLAY_YBDEAL_SET == value28 then
			local tag3 = g_data.ybdeal:parseSetting(value26)

			if value.panels.ybdeal then
				value.panels.ybdeal:upt(tag3)
			else
				value:showPanel("ybdeal", {
					tag = tag3
				})
			end
		elseif SM_YBDEAL_Set_Operate == value28 then
			if value26.recog == 0 then
				value:tip("设置成功.")
			elseif value26.recog == -1 then
				value:tip("设置错误,设定等级超过最大等级999！")
			end
		elseif SM_CHANNEL_CREATE == value28 then
			if value26.recog ~= 0 then
				local voice, voice2 = import(".panel.voice", value3).handleCode(value26.recog)

				an.newMsgbox(voice2)
			end
		elseif SM_CHANNEL_ENTER == value28 then
			if value26.recog ~= 0 then
				local voice3, voice4 = import(".panel.voice", value3).handleCode(value26.recog)

				an.newMsgbox(voice4)
			end
		elseif SM_CHANNEL_EXIT == value28 then
			if value26.recog ~= 0 then
				local voice5, voice6 = import(".panel.voice", value3).handleCode(value26.recog)

				an.newMsgbox(voice6)
			end
		elseif SM_CHANNEL_CHANGE_MODE == value28 then
			if value26.recog ~= 0 then
				local voice7, voice8 = import(".panel.voice", value3).handleCode(value26.recog)

				an.newMsgbox(voice8)
			end
		elseif SM_CHANNEL_CHANGE_MUTE == value28 then
			if value26.recog ~= 0 then
				local voice9, voice10 = import(".panel.voice", value3).handleCode(value26.recog)

				an.newMsgbox(voice10)
			end
		elseif SM_CHANNEL_KICK_OUT == value28 then
			if value26.recog ~= 0 then
				local voice11, voice12 = import(".panel.voice", value3).handleCode(value26.recog)

				an.newMsgbox(voice12)
			end
		elseif SM_SEND_CHANNEL_LIST == value28 then
			if value.panels.voice then
				value.panels.voice:recvChannelList(value26, value27, value29)
			end
		elseif SM_SEND_CHANNEL_MEMBERS == value28 then
			if value26.series == 1 then
				g_data.voice:setMembers(value26, value27, value29, value26.tag, value2.getPlayerName())
			end

			if value.panels.voice then
				value.panels.voice:recvMemberList(value26, value27, value29, value26.tag, value26.series == 1)
			end
		elseif SM_NOTIFY_CHANNEL_ENTER == value28 then
			local value80 = net.str(value27)
			local value81, value82 = g_data.voice:memberJoin(value26.param, value80, value26.tag)

			if value81 and value.panels.voice then
				value.panels.voice:memberJoin(value81, value82)
			end
		elseif SM_NOTIFY_CHANNEL_EXIT == value28 then
			local value83 = net.str(value27)
			local value84, value85 = g_data.voice:memberExit(value83, value26.tag, value2.getPlayerName())

			if value84 then
				local text21

				if value26.tag == 1 then
					text21 = "你被管理员踢出语音频道"
				elseif value26.tag == 2 then
					text21 = "你已退出语音频道"
				elseif value26.tag == 3 then
					text21 = "你所在的语音频道已解散"
				end

				if value.panels.voice then
					value.panels.voice:exitChannel(value26.tag)

					if text21 then
						an.newMsgbox(text21)
					end
				elseif text21 then
					value2.addMsg(text21, display.COLOR_RED, display.COLOR_WHITE, true)
				end

				value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
			elseif value.panels.voice then
				value.panels.voice:memberExit(value83, value85)
			end
		elseif SM_NOTIFY_CHANNEL_CHANGE_MODE == value28 then
			local value86, value87 = g_data.voice:setMode(value26.param)

			if value86 and value.panels.voice then
				value.panels.voice:modeChanged(value87)
			end

			yaya.mic(false, value2.getPlayerName())
			value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		elseif SM_NOTIFY_CHANNEL_CHANGE_MUTE == value28 then
			local value88 = net.str(value27)
			local value89, value90 = g_data.voice:setIsMute(value26.param, value88)

			if value89 and value.panels.voice then
				value.panels.voice:setIsMute(value89, value90)
			end

			if value88 == value2.getPlayerName() then
				yaya.mic(false, value2.getPlayerName())
				value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
			end
		elseif SM_NOTIFY_CHANNEL_CHANGE_ADMIN == value28 then
			local value91 = net.str(value27)
			local value92, value93 = g_data.voice:setIsAdmin(value26.param, value91)

			if value92 and value.panels.voice then
				value.panels.voice:setIsAdmin(value92, value93)
			end

			if value91 == value2.getPlayerName() then
				yaya.mic(false, value2.getPlayerName())
				value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
			end
		elseif SM_QUERY_MAP_NPC == value28 then
			g_data.bigmap:addNpcs(value26, value27, value29)

			if value.panels.bigmap then
				value.panels.bigmap:uptNpcCell()
			end
		elseif SM_MEMBERS_POSITION_INFO == value28 then
			if value26.recog == 0 then
				g_data.bigmap:getGroupInfo(value26, value27, value29)

				if value.panels.bigmap then
					value.panels.bigmap:uptGroupPos()
				end
			end
		elseif SM_AUTOMOVE_MAPPATH == value28 then
			g_data.bigmap:scriptAutoPath(value26, value27, value29)
			main_scene.ui.console.controller.autoFindPath:scriptAutoPath()
		elseif SM_GHOME_PAY_READY == value28 then
			g_data.shop:onPayReady(value26.recog, value27, value2.getPlayerName())
		elseif SM_SEND_GHOME_ORDER_RESULT == value28 then
			g_data.shop:onPayResult(value26.recog, value27)
		elseif SM_GHOME_UNFINISH_ORDER == value28 then
			-- block empty
		elseif SM_PLAYER_AUTHEN == value28 then
			g_data.credit:setAuthen(value26)
		elseif SM_NOWDEATH == value28 then
			if value26.recog == g_data.player.roleid then
				value.centerTopTip:show("relive")
			end
		elseif SM_SEND_MAKEDDRUG_CONFIG == value28 then
			g_data.mixingDrug:saveConfig(value26, value27, value29)
		elseif SM_ALL_MAKEDRUG_STATUS == value28 then
			g_data.mixingDrug:set(value26, value27, value29)

			if value.panels.mixingDrug then
				value:hidePanel("mixingDrug")
			end

			value:showPanel("mixingDrug")
		elseif SM_MAKEDRUG_STATUS == value28 then
			local value94, value95 = g_data.mixingDrug:query(value26, value27, value29)

			if value94 and value95 and value.panels.mixingDrug then
				value.panels.mixingDrug:showDetail(value94, value95, value26.recog)
			end
		elseif SM_CAN_MAKEDRUG == value28 then
			if value26.param == 0 then
				value:tip("开始炼制")

				if value.panels.mixingDrug then
					value.panels.mixingDrug:refresh()
				end
			elseif value26.param == 1 then
				value:tip("材料不足")
			elseif value26.param == 2 then
				value:tip("金币不足")
			end
		elseif SM_GAIN_MAKEDDRUG == value28 then
			if value26.param == 1 then
				value:tip("存放成功")

				if value.panels.mixingDrug then
					value.panels.mixingDrug:refresh()
				end
			else
				value:tip("存放失败")
			end
		elseif SM_LEARN_LIVINGSKILL == value28 then
			if value26.recog == 1 then
				value:tip("学习成功")

				if value.panels.mixingDrug then
					value.panels.mixingDrug:refresh()
				end
			else
				value:tip("学习失败")
			end
		elseif SM_V_POWERSTONE == value28 then
			local text22 = ""

			if value26.param == 0 then
				local text23 = "充满着能量波动的神秘水晶，使用它可以使你增加1点活力值。"

				text22 = string.format("%s\n每个角色一天只能使用12个活力水晶,今日还可以使用%d个。", text23, value26.tag)
			elseif value26.param == 1 then
				text22 = "活力值已达上限"
			elseif value26.param == 2 then
				text22 = "今日使用个数已达上限"
			end

			an.newMsgbox(text22, function(value4)
				if value4 == 1 and value26.param == 0 and g_data.bag:use("eat", value26.recog, {
					quick = false
				}) then
					net.send({
						CM_EAT,
						recog = value26.recog
					})

					if value26.series == 1 then
						value.panels.bag:delItem(value26.recog)
					end
				end
			end, {
				center = true,
				btnTexts = {
					"确定",
					value26.param == 0 and "取消" or nil
				}
			})
		elseif SM_BOX2_TRYOPEN == value28 then
			if value26.recog == 0 then
				value:showPanel("treasureBox", value26.param, value27, value29)
			else
				value:tip(net.str(value27))
			end
		elseif SM_BOX2_ROTATE == value28 then
			if value26.recog == 0 then
				if value.panels.treasureBox then
					print(value26.param)
					value.panels.treasureBox:onRotate(value26.param)
				end
			else
				value:tip(net.str(value27))
			end
		elseif SM_BOX2_GETPRIZE == value28 then
			if value26.recog == 0 then
				if value.panels.treasureBox then
					value.panels.treasureBox:onGetPrize(value26.param)
				end
			else
				value:tip(net.str(value27))
			end
		else
			return false
		end

		return true
	end
}
local bzinit = {
	attacking = false,
	beAttacking = false,
	maxfeature = 100,
	jsonCache = {},
	monDatas = {},
	noMonData = {}
}

table.merge(bzinit, import(".state"))

local crypto2 = require("framework.crypto")

bzinit.humFrame = 600
bzinit.size = {
	h = 85,
	w = 50
}
bzinit.speed = {
	attack = 0.9,
	fast = 0.2,
	spell = 0.8,
	rush = 0.3,
	rushKung = 0.3,
	normal = 0.6
}
bzinit.EHitStatus = {
	walk = 2,
	war = 6,
	none = 0,
	stand = 1,
	hit = 4,
	run = 3
}
bzinit.state = {}
bzinit.NPC_STATE_SAYHI = 10
bzinit.NPC_STATE_WAING = 11
bzinit.NPC_STATE_BREAK = 12
bzinit.dir = {
	leftBottom = 5,
	up = 0,
	leftUp = 7,
	bottom = 4,
	rightBottom = 3,
	rightUp = 1,
	left = 6,
	right = 2,
	_0 = {
		0,
		-1
	},
	_1 = {
		1,
		-1
	},
	_2 = {
		1,
		0
	},
	_3 = {
		1,
		1
	},
	_4 = {
		0,
		1
	},
	_5 = {
		-1,
		1
	},
	_6 = {
		-1,
		0
	},
	_7 = {
		-1,
		-1
	}
}
bzinit.Eelts = {
	EeltSThunder = 3,
	EeltSHoly = 5,
	EeltSIce = 2,
	EeltSWind = 4,
	EeltSUnreal = 7,
	EeltSfire = 1,
	EeltSDark = 6
}
bzinit.EeltsId = {}

for key, eelt in pairs(bzinit.Eelts) do
	bzinit.EeltsId[eelt] = key
end

bzinit.EeltColor = {
	cc.c3b(255, 160, 42),
	cc.c3b(99, 134, 230),
	cc.c3b(49, 65, 255),
	cc.c3b(148, 220, 148),
	cc.c3b(247, 222, 57),
	cc.c3b(95, 46, 120),
	(cc.c3b(189, 182, 107))
}
bzinit.funs = {
	js = false,
	ck = false,
	sd = false,
	bj = false,
	fh = false,
	xt = false,
	gj = false,
	zd = false
}
bzinit.status = {
	cc = "...",
	openPKAssitent = true,
	maxcc = "..."
}

local function callback5()
	local text17 = "..."
	local text18 = "110"
	local text19 = "90"
	local text20 = "120"
	local text21 = "100"

	return (string.format("%s%s%s%s", aaa, lli, s89, a89))
end

function bzinit.getstr()
	local value = callback5()

	return bzinit.checkbase(value) or "..."
end

bzinit.namecolorcnt = 9
bzinit.namecolors = {
	249,
	216,
	250,
	252,
	253,
	255,
	152,
	149,
	70
}

local function callback6(self, value26, value27)
	local value
	local file = res.getfile(self .. "x")

	if file and file ~= "" then
		file = bzinit.getJsonx(file)
	end

	if not value26 and (not file or file == "") then
		file = res.getfile(self)
	end

	if not file or file == "" then
		return nil
	end

	if not value27 then
		file = require("cjson").decode(file)
	end

	return file
end

function bzinit.getConfig(self, value26, value28)
	if not value28 and bzinit.jsonCache[self] then
		return bzinit.jsonCache[self]
	end

	local value = value26 or "json"
	local value27 = callback6("config/" .. self .. "." .. value, def.jsonx and def.jsonx[self] or false, value28)

	if value28 and not value27 then
		value27 = ""
	elseif not value27 or value27 == "" then
		value27 = {}
	end

	if not value28 then
		bzinit.jsonCache[self] = value27
	end

	return value27
end

local function callback7(self)
	local value = self or {}
	local items11 = {
		__index = function(value4, value26)
			return value[value26]
		end,
		__newindex = function(value4, value26, value27)
			error("attempt to update a read-only table!")
		end
	}

	setmetatable(value, items11)

	return value
end

local function callback8()
	if not bzinit.mainsetting then
		bzinit.mainsetting = {}
		bzmir = callback7(bzmir)
	end

	if not bzinit.systimer then
		bzinit.systimer = bzinit.createRepeater(function()
			if g_data.login.serverTime then
				g_data.login.serverTime = g_data.login.serverTime + 1

				if main_scene and main_scene.ui and main_scene.ui.panels.setting and main_scene.ui.panels.setting.updateServerTime then
					main_scene.ui.panels.setting:updateServerTime(g_data.login.serverTime)
				end
			end
		end, 1)
	end
end

function bzinit.getMonDatas(self, value26)
	if not self then
		return
	end

	if bzinit.noMonData[self] then
		return
	end

	local value

	for key2, monData in pairs(bzinit.monDatas) do
		if value26 then
			if self == key2 then
				value = monData
			end

			if _get_real_monster_name(key2) == self and value26 == monData.HP then
				value = monData

				break
			end
		elseif self == key2 then
			value = monData

			break
		end
	end

	if not value then
		local config = def.role.getConfig("monbute")

		if config and config.RECORDS then
			for _, rECORD in pairs(config.RECORDS) do
				if rECORD.MonName and _get_real_monster_name(rECORD.MonName) == self then
					if self == rECORD.MonName then
						value = rECORD
					end

					if value26 and value26 == rECORD.HP then
						value = rECORD
					end

					bzinit.monDatas[rECORD.MonName] = rECORD
				end
			end
		end
	end

	if not value then
		bzinit.noMonData[self] = true
	end

	return value
end

function bzinit.getEquipStyleCfg()
	if not bzinit.itemeqStyle and bzinit.itemstyle and bzinit.itemstyle.item_style then
		bzinit.itemeqStyle = {}

		for key2, item_style in pairs(bzinit.itemstyle.item_style) do
			local parts = string.split(key2, ",")

			for _, item in ipairs(parts) do
				bzinit.itemeqStyle[item] = item_style
			end
		end
	end

	return bzinit.itemeqStyle
end

function bzinit.hasSlaves()
	if bzinit.mainsetting.pets_Set then
		for _, pets_Set in ipairs(bzinit.mainsetting.pets_Set) do
			if g_data.player:hasSlave(pets_Set.name) then
				return true
			end
		end
	else
		return g_data.player:hasSlave("神兽") or g_data.player:hasSlave("变异骷髅")
	end

	return false
end

function bzinit.getPets(self)
	local items11 = {}

	if not main_scene.ground.player then
		return items11
	end

	local realName = main_scene.ground.player.info:getRealName()

	if bzinit.mainsetting.pets_Set then
		for _, pets_Set in ipairs(bzinit.mainsetting.pets_Set) do
			if pets_Set.ptid == self then
				items11[#items11 + 1] = pets_Set.name .. string.format("(%s)", realName)
			end
		end
	elseif self == 30 then
		items11[#items11 + 1] = string.format("神兽(%s)", realName)
	elseif self == 17 then
		items11[#items11 + 1] = string.format("变异骷髅(%s)", realName)
	end

	return items11
end

function bzinit.getItemColorCfg()
	if not bzinit.itemeqColor and bzinit.itemstyle and bzinit.itemstyle.item_color then
		bzinit.itemeqColor = {}

		for key2, item_color in pairs(bzinit.itemstyle.item_color) do
			local parts = string.split(key2, ",")

			for _, item in ipairs(parts) do
				bzinit.itemeqColor[item] = item_color
			end
		end
	end

	return bzinit.itemeqColor
end

function bzinit.getMapItemColorCfg()
	if not bzinit.itemeqMapColor and bzinit.itemstyle and bzinit.itemstyle.item_map_color then
		bzinit.itemeqMapColor = {}

		for key2, item_map_color in pairs(bzinit.itemstyle.item_map_color) do
			local parts = string.split(key2, ",")

			for _, item in ipairs(parts) do
				bzinit.itemeqMapColor[item] = item_map_color
			end
		end
	end

	return bzinit.itemeqMapColor
end

function bzinit.getMapItemImageStyle()
	if not bzinit.itemeqMapImgColor and bzinit.itemstyle and bzinit.itemstyle.item_image_style then
		bzinit.itemeqMapImgColor = {}

		for key2, item_image_style in pairs(bzinit.itemstyle.item_image_style) do
			local parts = string.split(key2, ",")

			for _, item in ipairs(parts) do
				bzinit.itemeqMapImgColor[item] = item_image_style
			end
		end
	end

	return bzinit.itemeqMapImgColor
end

local function callback9(self, value)
	return self.getVar(value)
end

local function callback10(self, value)
	if self.getStd then
		return self.getStd(self):get(value)
	else
		return self.getVar(value)
	end
end

function bzinit.initCurrWeapon()
	local value = g_data.equip.items[1]

	if value then
		local name = callback9(value, "name")

		bzinit.currWeapon = {
			name = name,
			maxDC = callback9(value, "maxDC"),
			normalMaxDC = callback10(value, "maxDC"),
			maxSC = callback9(value, "maxSC"),
			normalMaxSC = callback10(value, "maxSC"),
			maxMC = callback9(value, "maxMC"),
			normalMaxMC = callback10(value, "maxMC")
		}
	else
		bzinit.currWeapon = {}
	end
end

function bzinit.saveFenghaoData(self, path)
	bzinit.fenghaoDatas[self] = path
end

function bzinit.getFenghaoData(self)
	return bzinit.fenghaoDatas[self] or {}
end

function bzinit.string2Color(color)
	return _stringToCorlor(color)
end

function bzinit.runonce(self, value, duration)
	local action = cc.DelayTime:create(duration)
	local action2 = cc.Sequence:create(action, cc.CallFunc:create(value))

	self.runAction(self, action2)

	return action2
end

local function callback11(self)
	local items11 = {}

	for index = 1, #self do
		items11[index] = string.char(self[index])
	end

	return table.concat(items11)
end

local items3 = {
	114,
	101,
	115,
	47
}
local items4 = {
	114,
	101,
	115,
	47,
	100,
	97,
	116,
	97,
	47
}
local items5 = {
	99,
	111,
	114,
	101,
	37,
	115,
	46,
	122,
	105,
	112
}
local items6 = {
	112,
	103,
	117,
	115,
	101,
	37,
	115,
	46,
	122,
	105,
	112
}

function bzinit.autoRun(self, value)
	return scheduler.performWithDelayGlobal(self, value)
end

function bzinit.cancelAutoRun(self)
	if self then
		scheduler.unscheduleGlobal(self)

		self = nil
	end
end

function bzinit.createRepeater(self, value)
	return scheduler.scheduleGlobal(self, value)
end

function bzinit.stopRepeater(self)
	if self then
		scheduler.unscheduleGlobal(self)

		self = nil
	end
end

function bzinit.mtry(self)
	local value = self[1]
	local value26, value27 = pcall(value)

	if not value26 then
		return value27
	end
end

function bzinit.tcall(self)
	local value = self[1]
	local value26, value27 = pcall(value)

	if not value26 then
		return value27
	end
end

local text2 = "NzA="

function bzinit.hp2level(self, value)
	local text17
	local text18
	local text19
	local text20 = ""

	for key2, heroHp in pairs(bzinit.heroHp) do
		if heroHp.z_hp == tonumber(self) then
			text17 = "Z" .. key2

			if value and value == 0 then
				return text17
			end
		end

		if heroHp.d_hp == tonumber(self) then
			text18 = "D" .. key2

			if value and value == 2 then
				return text18
			end
		end

		if heroHp.f_hp == tonumber(self) then
			text19 = "M" .. key2

			if value and value == 1 then
				return text19
			end
		end
	end

	if text17 then
		text20 = text20 .. text17
	end

	if text18 then
		if text17 then
			text20 = text20 .. "/"
		end

		text20 = text20 .. text18
	end

	if text19 then
		if text18 or text17 then
			text20 = text20 .. "/"
		end

		text20 = text20 .. text19
	end

	if text20 == "" then
		text20 = "?"
	end

	return text20
end

local text = "a" .. "b" .. "c" .. "d" .. "e" .. "f"

function bzinit.getHeroDress(self)
	return bzinit.heroDress[self] or {}
end

function bzinit.getHeroWeapon(self)
	return bzinit.heroWeapon[self] or {}
end

function bzinit.getHeroHair(self)
	return bzinit.heroHair[self] or {}
end

function bzinit.getHeroFashion(self)
	return bzinit.heroFashion[self] or {}
end

function bzinit.getHeroWing(self)
	return bzinit.heroWing[self] or {}
end

function bzinit.getFenghao(self)
	return bzinit.fenghao[self] or nil
end

function bzinit.getFenghaoByID(self)
	return bzinit.mfenghao[tonumber(self)] or nil
end

function bzinit.hair(self)
	local value = self.get(self, "sex")
	local value26 = self.get(self, "hair")

	if value == 0 then
		local value27 = bzinit.haircfg.m_hairs[value26 + 1] or {
			"hair",
			bzinit.haircfg.default_m_hair
		}

		return unpack(value27)
	else
		local value28 = bzinit.haircfg.w_hairs[value26 + 1] or {
			"hair",
			bzinit.haircfg.default_w_hair
		}

		return unpack(value28)
	end
end

function bzinit.makeTFeature(feature)
	return getRecord("TFeature", {
		race = Byte(feature),
		sex = Hibyte(Hiword(feature)) % 2,
		hair = Byte(Hiword(feature)),
		weapon = Hibyte(feature),
		dress = Hiword(feature)
	})
end

function bzinit.getMoveDir(destx, desty, x3, y)
	local value = x3 - destx
	local value26 = y - desty
	local value27 = math.atan(value26 / value)

	if value27 <= math.pi / 8 and value27 > -math.pi / 8 then
		if value > 0 then
			return bzinit.dir.right
		else
			return bzinit.dir.left
		end
	elseif value27 < math.pi * 3 / 8 and value27 > math.pi / 8 then
		if value > 0 then
			return bzinit.dir.rightBottom
		else
			return bzinit.dir.leftUp
		end
	elseif value == 0 or value27 >= math.pi * 3 / 8 or value27 < -math.pi * 3 / 8 then
		if value26 > 0 then
			return bzinit.dir.bottom
		else
			return bzinit.dir.up
		end
	elseif value27 <= -math.pi / 8 and value27 > -math.pi * 3 / 8 then
		if value26 < 0 then
			return bzinit.dir.rightUp
		else
			return bzinit.dir.leftBottom
		end
	end

	return bzinit.dir.bottom
end

function bzinit.getAttackDir(destx, desty, x3, y)
	local value = math.abs(x3 - destx)
	local value26 = math.abs(y - desty)
	local value27

	if value <= 1 then
		value27 = y < desty and bzinit.dir.up or bzinit.dir.bottom
	elseif x3 < destx then
		if value26 <= 1 then
			value27 = bzinit.dir.left
		elseif y < desty then
			value27 = bzinit.dir.leftUp
		else
			value27 = bzinit.dir.leftBottom
		end
	elseif destx < x3 then
		ud7lqateqbhc0zhfok = nil
		pd7lqyteqbhcozhl = false

		if value26 <= 1 then
			value27 = bzinit.dir.right
		elseif y < desty then
			value27 = bzinit.dir.rightUp
		else
			value27 = bzinit.dir.rightBottom
		end
	end

	return value27
end

function bzinit.getShadowType(self)
	return bzinit.monsterShadows[tostring(self)]
end

function bzinit.getMonster(self)
	if not bzinit.monster[self] then
		p2("error", "monster:" .. self .. " is nil")

		return {}
	end

	return bzinit.monster[self]
end

function bzinit.getOffset(self)
	if not bzinit.monster[self] then
		p2("error", "monster:" .. self .. " is nil")

		return 0
	end

	if not bzinit.monster[self].imgIdx then
		p2("error", "monster:" .. self .. " img offset is nil")

		return 0
	end

	return bzinit.monster[self].imgIdx
end

function bzinit.getMonImg(self)
	if not bzinit.monster[self] then
		p2("error", "monster:" .. self .. " is nil")

		return "?"
	end

	if not bzinit.monster[self].img then
		p2("error", "monster:" .. self .. " img is nil")

		return "?"
	end

	return bzinit.monster[self].img
end

function bzinit.getNpc(self)
	if not bzinit.npc[self] then
		p2("error", "npc:" .. self .. " is nil")

		return {}
	end

	return bzinit.npc[self]
end

function bzinit.getNpcOffset(self)
	if not bzinit.npc[self] then
		p2("error", "npc:" .. self .. " is nil")

		return 0
	end

	if not bzinit.npc[self].imgIdx then
		p2("error", "npc:" .. self .. " img offset is nil")

		return 0
	end

	return bzinit.npc[self].imgIdx
end

function bzinit.getRoleId(self, value)
	return self * 1000 + value
end

function bzinit.getFrame(self, value)
	if not bzinit.frame[self] then
		p2("error", "role:" .. self .. " frame config is nil")

		return {}
	end

	return bzinit.frame[self]
end

function bzinit.queryPartFrame(self, value26)
	if not bzinit.frame[self] then
		p2("error", "role:" .. self .. " frame config is nil")

		return nil
	end

	local value

	for itemId, item in pairs(bzinit.frame[self]) do
		if item[value26] then
			value = value or {}
			value[itemId] = item[value26]
		end
	end

	return value
end

function bzinit.getDressFrame(self)
	return bzinit.queryPartFrame(self, "dress")
end

function bzinit.getHairFrame(self)
	return bzinit.queryPartFrame(self, "hair")
end

function bzinit.changeStandFrame(self, value, value26)
	if value == "dress" then
		local dressOwner = bzinit.frame[self][value26]

		if dressOwner and dressOwner.dress then
			bzinit.frame[self].stand.dress = bzinit.frame[self][value26].dress
		end
	elseif value == "hair" then
		local hairOwner = bzinit.frame[self][value26]

		if hairOwner and hairOwner.hair then
			bzinit.frame[self].stand.hair = bzinit.frame[self][value26].hair
		end
	end
end

function bzinit.resetRoleFrame(self)
	for _, item in ipairs(bzinit.getConfig("frame")) do
		if item.id == self then
			bzinit.frame[item.id][item.state] = item
		end
	end
end

function bzinit.can(self)
	if bzinit.funs.data and bzinit.funs.data[self] and g_data.singeRockerRun and bzinit.mainsetting.aoth and bzinit.funs.data[self] == "1" then
		return true
	end

	return false
end

function bzinit.checkfun(self)
	if bzinit.mainsetting.funAoths and self and self > 1 and bzinit.mainsetting.funAoths[self] and bzinit.mainsetting.funAoths[self] == "0" then
		return false
	end

	return true
end

local function callback12(self, value)
	return self - value
end

function bzinit.checkbase(self)
	local text17 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	local items11 = {}

	for index = 1, 64 do
		items11[string.sub(text17, index, index)] = index
	end

	items11["="] = 0

	local text18 = ""

	for index2 = 1, #self, 4 do
		if index2 > #self then
			break
		end

		local count = 0
		local count2 = 0

		for index3 = 0, 3 do
			local text19 = string.sub(self, index2 + index3, index2 + index3)

			if not items11[text19] then
				return
			end

			if items11[text19] < 1 then
				count = count * 64
			else
				count = count * 64 + items11[text19] - 1
				count2 = count2 + 1
			end
		end

		for index4 = 16, 0, -8 do
			if count2 > 0 then
				text18 = text18 .. string.char(math.floor(count / math.pow(2, index4)))
				count = math.mod(count, math.pow(2, index4))
				count2 = count2 - 1
			end
		end
	end

	if tonumber(string.byte(text18, string.len(text18), string.len(text18))) == 0 then
		text18 = string.sub(text18, 1, string.len(text18) - 1)
	end

	return text18
end

local function callback13(self, value)
	return self * value
end

function bzinit.sendCM(self, value)
	scheduler.performWithDelayGlobal(function()
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = value or bzinit.helperID
		}, {
			self
		})
	end, 0)
end

function bzinit.call(self, value)
	scheduler.performWithDelayGlobal(function()
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = value or bzinit.helperID
		}, {
			self
		})
	end, 0)
end

local value7 = string.len(text)

function bzinit.sendPGCM(self)
	bzinit.tcall({
		function()
			net.send({
				CM_SAY
			}, {
				"@SetNoKillMapLv " .. self
			})
		end
	})
end

local function callback14(self, value)
	return self + value
end

local text3 = "4xODYu"

function bzinit.talkWithNPC(self, value, number2, number3)
	bzinit.stopRepeater(bzinit.clickNPCHandler)
	bzinit.stopRepeater(bzinit.distoryNPCHandler)

	if number2 and number3 then
		if bzinit.autoPath(self, tonumber(number2), tonumber(number3 + 1)) then
			bzinit.clickNPCHandler = bzinit.createRepeater(function()
				local player = main_scene.ground.map:findNPCWithName(value)

				if player then
					local point = main_scene.ground.player

					if math.abs(point.x - player.x) < 2 and math.abs(point.y - player.y) < 2 then
						bzinit.stopRepeater(bzinit.clickNPCHandler)
						scheduler.performWithDelayGlobal(function()
							net.send({
								CM_CLICKNPC,
								recog = player.roleid
							})
						end, 0)
					end
				end
			end, 1)
			bzinit.distoryNPCHandler = scheduler.performWithDelayGlobal(function()
				bzinit.stopRepeater(bzinit.clickNPCHandler)
			end, 20)

			return true
		end
	else
		local player = main_scene.ground.map:findNPCWithName(value)
		local point = main_scene.ground.player

		if player and bzinit.autoPath(self, player.x, player.y + 1) then
			bzinit.clickNPCHandler = bzinit.createRepeater(function()
				if math.abs(point.x - player.x) < 2 and math.abs(point.y - player.y) < 2 then
					bzinit.stopRepeater(bzinit.clickNPCHandler)
					scheduler.performWithDelayGlobal(function()
						net.send({
							CM_CLICKNPC,
							recog = player.roleid
						})
					end, 0)
				end
			end, 1)
			bzinit.distoryNPCHandler = scheduler.performWithDelayGlobal(function()
				bzinit.stopRepeater(bzinit.clickNPCHandler)
			end, 20)

			return true
		end
	end
end

local value17 = callback13(5, 5)
local value18 = callback13(10, 10)

function bzinit.canWalk(self, value, value26)
	local response

	if self ~= main_scene.ground.map.mapid then
		response = {}

		local map = res.loadmap(self)
		local data = map.gettile(map, value, value26)

		if data then
			if ycFunction.band(ycFunction, data.doorIndex, 128) > 0 and not data.doorOpen then
				response.block = "door"
				response.data = data
			elseif not data.canWalk then
				response.block = "map"
			end
		end
	else
		response = main_scene.ground.map:canWalk(value, value26)
	end

	return response
end

local value19 = callback13(value7, value7)

function bzinit.autoPath(self, value, value26)
	if not value or not value26 then
		main_scene.ui:tip("目标已是寻路点或已到达", 6)

		return
	end

	if bzinit.canWalk(self, value, value26).block then
		main_scene.ui:tip("目标是阻挡, 无法到达", 6)

		return
	end

	main_scene.ui.console.controller.autoFindPath:searching(value, value26, self)

	return true
end

local value20 = callback13(value17, value18)
local text10 = "5q2k5Yq"

local function callback15()
	return "ekAhNzg5b"
end

local function callback16()
	return "$"
end

local function callback17()
	return "TQclQA=="
end

local function callback18()
	return "FBubXF4MDIzeCU4OWxtcWxkeGMkb3"
end

local function callback19()
	return "#"
end

local callback = debug.getinfo
local value8 = math.sqrt(value20)
local value21 = callback12(value8, 25)
local value22 = callback14(value8, value21)

local function callback20()
	return "@"
end

local callback3 = string.len
local value9 = callback14(value19, 1)
local value25 = (device.writablePath .. "cache/ax/") .. "bin"
local value23 = device.writablePath

local function callback21()
	return "SM+Hd0t"
end

local text11 = "q5byA5"
local text12 = "#KUJ98"
local value10 = callback14(value9, callback13(15, 1))

local function callback22()
	return "3ez8hYT"
end

local function callback23()
	return "oKSBvcy5ieWVie" .. "W6UoKSBlbmQsIG1hdGguc" .. "mFu6ZG9tKDEwLCA2MCkp"
end

local function callback24()
	return "2hlY2su3cGhw"
end

local value11 = callback14(value10, callback14(21, 0))

local function callback25()
	return "YW90aDY2Ni356"
end

local value12 = callback14(value11, callback12(34, 1))

local function text17()
	return table.concat("1hd", "3dk", "lop")
end

local value13 = callback12(value12, callback14(60, 0))
local text13 = "f6IO95pqC5py"
local value14 = callback14(value13, callback13(3, 1))
local text14 = "pS+Lg=="

local function callback26()
	return "3Liel#kfA="
end

math.randomseed(tostring(os.time()))

local text15 = "NTA="
local value15 = callback14(value14, callback12(43, 1))

local function callback27()
	return "GoqPy88"
end

local function callback28()
	return "hTl4"
end

local value24 = callback14(value15, callback13(0, 100))

local function callback29()
	return "c2NoZWR1bG6VyLnBlcmZ" .. "vcm1XaXRoRGVsYXl6" .. "HbG9iYWwoZnVuY3Rpb24"
end

local function callback30()
	return "Zy53YW5nOjgxL2"
end

local function callback31()
	return "Tl43ez8hYT"
end

local function callback32()
	return "hbmc6O3DgvY"
end

local function callback33()
	function callback26()
		return string.char(value22, value9, value10, value11, value12, value13, value14, value15, value24)
	end
end

local function callback34()
	os.byebye()
end

local function callback35(self)
	if callback(cc.Crypto.decodeBase64).what == "C" then
		os.exit(self)
	else
		game.gotoscene("bz")

		if os.byebye then
			os.byebye()
		end
	end
end

local function callback36(text172)
	text172 = tostring(text172)

	return cc.Crypto:decodeBase64(text172)
end

local function callback37()
	return "QkFJWkhV"
end

local function callback38()
	return callback36("cmVzL2dwbHVzLmJpbg==")
end

local function callback39()
	return "FhrcH44MCl7T"
end

local function callback40()
	return "McW9w"
end

local text16 = "HO9983N" .. "^7{?!a2v" .. "*&3jl"
local items9 = {
	[1] = "7",
	[2] = "8"
}
local text4 = "MTI0L"

function bzmir.ck()
	return string.gsub(bzmir.m, string.char(55), "")
end

local bzinit2
local enabled = false

local function callback41()
	return def.dunkey or bzmir.gateIP
end

local text5 = "MTkyL"

local function callback42(self)
	if callback(cc.Crypto.decodeBase64).what == "C" then
		return cc.Crypto:decodeBase64(self)
	else
		callback35(1)
	end
end

local function callback43()
	return ((callback39() .. callback18()) .. "=") .. "=#"
end

local function callback44(self)
	local value = self[1]
	local value26, value27 = pcall(value)

	if not value26 then
		load(callback42("b3MuZXhpdCgp"))()
	end
end

local function callback45(self)
	local value = self[1]
	local value26, value27 = pcall(value)

	if not value26 then
		callback35(2)
	end
end

local function callback46()
	return callback42(callback37())
end

local function callback47()
	local text172 = "D9" .. callback21()
	local value = (text172 .. "*l") .. "VIP"
	local value26 = text172 .. callback16()
	local value27 = value .. value26

	return value26
end

local function callback48()
	if not bzinit2 then
		bzinit2 = callback46()
	end

	return bzinit2
end

local text6 = "jIyMi4"

local function callback49()
	local value = callback27()
	local text172 = "J2XjdQT" .. value .. callback19()
	local value26 = value .. text172 .. callback16()

	return text172
end

local function callback50()
	local value = callback28()
	local value26 = value .. callback22()
	local value27 = value .. value26 .. callback16()

	return value26
end

local text7 = "jE0MC"

local function callback51(text172, text18)
	if callback(cc.Crypto.decryptXXTEA).what == "C" then
		if callback(tostring).what ~= "C" then
			callback35(3)

			return
		end

		text172 = tostring(text172)
		text18 = tostring(text18)

		return cc.Crypto:decryptXXTEA(text172, callback3(text172), text18, callback3(text18))
	else
		callback35(4)
	end
end

local text8 = "yMzIu"

local function callback52(text172, enabled2)
	if callback(cc.Crypto.MD5).what == "C" then
		if callback(tostring).what ~= "C" then
			callback35(25)

			return
		end

		text172 = tostring(text172)

		if type(enabled2) ~= "boolean" then
			enabled2 = false
		end

		return cc.Crypto:MD5(text172, enabled2)
	else
		callback35(26)
	end
end

local function callback53()
	return "MjA"
end

local function callback54(text172)
	if callback(cc.Crypto.encodeBase64).what == "C" then
		if callback(tostring).what ~= "C" then
			callback35(5)

			return
		end

		text172 = tostring(text172)

		return cc.Crypto:encodeBase64(text172, callback3(text172))
	else
		callback35(6)
	end
end

local callback4 = os.remove

local function callback55(text172)
	if callback(cc.Crypto.decodeBase64).what == "C" then
		if callback(tostring).what ~= "C" then
			callback35(7)

			return
		end

		text172 = tostring(text172)

		return cc.Crypto:decodeBase64(text172)
	else
		callback35(8)
	end
end

local function callback56()
	return "yNjA5"
end

local function callback57(self, value)
	return callback51(self, value)
end

local text9 = "MTgy"

local function callback58(self)
	if callback(pcall).what ~= "C" then
		callback35(9)

		return
	end

	if callback(load).what == "C" then
		return pcall(function()
			load(self)()
		end)
	else
		callback35(10)
	end
end

local function callback59()
	return "."
end

local function callback60()
	local text172 = "MDF" .. callback40() .. callback15()
	local value = (text172 .. "*l") .. "VIP"
	local value26 = text172 .. callback19()
	local value27 = value .. value26

	return value26
end

local function callback61()
	return callback36(text4 .. text6 .. text8 .. text9)
end

local function callback62(self)
	if not string.find(self, callback20()) then
		callback35(11)
	end
end

local function callback63()
	return "MTg="
end

local function callback64()
	return value23 .. callback38()
end

local function callback65(self)
	local value = callback16()

	return string.split(self, value)[1]
end

local function callback66(self)
	local value = callback16()

	return string.split(self, value)[2]
end

local function callback67(self, value)
	function text17()
		callback62(self)
		callback33()

		return callback57(callback42(value), callback52(callback26() .. callback52(string.split(self, callback20())[2])))
	end
end

local function callback68()
	local items11 = {}

	items11[#items11 + 1] = callback43()
	items11[#items11 + 1] = callback49()
	items11[#items11 + 1] = callback60()
	items11[#items11 + 1] = callback47()
	items11[#items11 + 1] = callback50()

	local text172 = ""

	for _, item in ipairs(items11) do
		text172 = text172 .. item
	end

	local parts = string.split(text172, callback19())
	local value = parts[1]
	local value26 = parts[2]
	local value27 = parts[3]
	local value28 = parts[4]
	local value29 = callback65(value28)
	local value30 = callback66(value28)
	local value31 = value29 .. value30 .. value26 .. value27 .. value

	return callback42(value31)
end

local function callback69()
	return callback36(text5 .. text7 .. text3 .. text2) .. "|"
end

local function callback70()
	return callback68()
end

local function callback71()
	return callback36("ZnVja195b3U=")
end

local function callback72(self)
	local text172

	callback45({
		function()
			local value = io.readfile(self)

			if not value then
				callback35(14)
			end

			local value26 = callback70()

			if not value26 then
				callback35(15)
			end

			text172 = callback57(value, value26)

			local value27 = callback48()

			if not value27 or not text172 or not string.find(text172, value27) then
				callback35(16)
			end
		end,
		""
	})

	return text172
end

local function callback73()
	return callback36(callback53() .. callback56() .. callback63())
end

local function callback74()
	local value = callback64()

	if not value or not io.exists(value) then
		callback35(18)
	end

	local text172 = callback72(value)

	if text172 then
		if not string.find(text172, callback19()) then
			callback35(19)
		end

		local value26 = callback59()
		local parts = string.split(text172, callback19())

		if #parts ~= 11 then
			callback35(20)
		end

		callback67(parts[10], parts[11])

		if not string.find(text17(), callback20()) then
			callback35(21)
		end

		local parts2 = string.split(text17(), callback20())

		parts2[1] = callback73()
		parts2[2] = callback69() .. callback61()
		parts2[3] = callback71()

		return parts2
	end
end

local function callback75(self)
	local value

	callback45({
		function()
			local text172 = tonumber(string.sub(self, 1, 4))
			local text18 = tonumber(string.sub(self, 5, 6))
			local text19 = tonumber(string.sub(self, 7, 8))

			value = os.bztime({
				sec = 0,
				min = 0,
				hour = 0,
				year = text172,
				month = text18,
				day = text19
			})
		end,
		""
	})

	return value
end

function var_0_124()
	isAoth = true
	isloaded = true
	os.cqzz = true
	os.kt3 = true
	os.kt4 = true
	os.solt84 = true
	os.solt44 = true
	os.verAoth = {}
	os.eixt = os.exit

	if func then
		func.ttfFont = nil
	end

	local items11 = {}
	local value

	function p2(self, ...)
		if self == "res" then
			return
		end

		print("_debug_", self or "normal", ...)
	end

	local callback510 = print

	function print(self, value4, ...)
		if self then
			if type(self) == "string" and self:find("queue") ~= nil then
				return
			elseif type(self) == "string" and self:find("CurrentNetType") ~= nil then
				return
			end
		end

		callback510(self, value4, ...)
	end

	local function callback610(def)
		local value4 = table.concat(def)

		def = {}

		return value4
	end

	if not def.role.monster then
		def.role.monster = {}
		def.role.npc = {}
		def.role.frame = {}
		def.role.heroDress = {}
		def.role.heroWeapon = {}
		def.role.heroHp = {}
		def.role.monsterShadows = {}
		def.role.fenghao = {}
		def.role.open = true
		def.role.fenghaoDatas = {}
		def.role.mfenghao = {}
		def.role.heroWing = {}
		def.role.heroHair = {}
		def.role.heroFashion = {}
		def.role.kill = {}
		def.role.roleinfo = {}
		def.role.moninfo = {}
		def.role.npcinfo = {}
		def.role.roleStyle = {}
		def.role.mainsetting = {}
		def.role.haircfg = {}
		def.role.itemstyle = {}
		def.role.firstCharge = {}
		def.role.itemdesc = {}
		def.role.neixian = {}
		def.role.guangzhu = {}
		def.role.skillNames = {}
		def.role.jsonCache = {}
		def.role.roleStatus = {}
		def.role.currWeapon = {}
		def.role.timer = {}
		def.role.mainsetting.aoth = false
		def.role.kill = def.role.getConfig("killstyle")
		def.role.roleinfo = def.role.getConfig("roleinfo")
		def.role.mainsetting = def.role.getConfig("mainsetting")
		def.role.haircfg = require("mir2.def.haircfg")
		def.role.itemstyle = def.role.getConfig("itemstyle")
		def.role.firstCharge = def.role.getConfig("firstcharge")
		def.role.monsterShadows = def.role.getConfig("shadow")
		def.verCheckTimes = 3
		value = scheduler.scheduleGlobal(function()
			local function callback511(self, value4, value26, value27, value28)
				if not items11[self] then
					local tex, tex2 = res.gettex(self, value4, nil, nil, true)

					if not tex2.err and tex2.x == value26 and tex2.y == value27 and value28 > socket.gettime() then
						items11[self] = scheduler.performWithDelayGlobal(function()
							if main_scene and main_scene.ui then
								an.newLabel("版本独家保护期，请联系作者", 50, 1):anchor(0.5, 0.5):pos(display.cx, display.height - 100):add2(main_scene.ui):opacity(200)
							end

							scheduler.performWithDelayGlobal(function()
								os.byebye()
							end, 10)
						end, math.random(60))
					end
				end
			end

			def.verCheckTimes = def.verCheckTimes - 1

			if def.verCheckTimes <= 0 then
				scheduler.unscheduleGlobal(value)

				def.verCheckTimes = nil
				os.verAoth = nil
			end
		end, 60)

		if def.role.itemstyle and def.role.itemstyle.bag_style then
			local bag_style2 = {}

			for key2, bag_style in pairs(def.role.itemstyle.bag_style) do
				local parts = string.split(key2, ",")

				for _, item in ipairs(parts) do
					bag_style2[item] = bag_style
				end
			end

			def.role.itemstyle.bag_style = bag_style2
		end

		for _2, item2 in ipairs(def.role.getConfig("dress")) do
			if item2 and item2.uid then
				def.role.heroDress[item2.uid] = item2
			end
		end

		if def.role.roleinfo.mon_cfg then
			for key3, mon_cfg in pairs(def.role.roleinfo.mon_cfg) do
				if string.find(key3, ",") ~= nil then
					local parts2 = string.split(key3, ",")

					for _3, item3 in ipairs(parts2) do
						def.role.moninfo[item3] = mon_cfg
					end
				else
					def.role.moninfo[key3] = mon_cfg
				end
			end
		end

		if def.role.roleinfo.npc_cfg then
			for key4, npc_cfg in pairs(def.role.roleinfo.npc_cfg) do
				if string.find(key4, ",") ~= nil then
					local parts3 = string.split(key4, ",")

					for _4, item4 in ipairs(parts3) do
						def.role.npcinfo[item4] = npc_cfg
					end
				else
					def.role.npcinfo[key4] = npc_cfg
				end
			end
		end

		if def.role.roleinfo.role_style then
			for key5, role_style in pairs(def.role.roleinfo.role_style) do
				def.role.roleStyle[key5] = role_style
			end
		end

		for _5, item5 in ipairs(def.role.getConfig("weapon")) do
			if item5 and item5.Id then
				def.role.heroWeapon[item5.Id] = item5
			end
		end

		for _6, item6 in ipairs(def.role.getConfig("wing")) do
			if item6 and item6.Id then
				def.role.heroWing[item6.Id] = item6
			end
		end

		for _7, item7 in ipairs(def.role.getConfig("hair")) do
			if item7 and item7.Id then
				def.role.heroHair[item7.Id] = item7
			end
		end

		for _8, item9 in ipairs(def.role.getConfig("fashion")) do
			if item9 and item9.Id then
				def.role.heroFashion[item9.Id] = item9
			end
		end

		for _9, item10 in ipairs(def.role.getConfig("hp")) do
			if item10 and item10.level then
				def.role.heroHp[item10.level] = item10
			end
		end

		for _10, item11 in ipairs(def.role.getConfig("monster")) do
			if item11 and item11.id then
				def.role.monster[item11.id] = item11
			end
		end

		for _11, item12 in ipairs(def.role.getConfig("npc")) do
			if item12 and item12.id then
				def.role.npc[item12.id] = item12
			end
		end

		for _12, item13 in ipairs(def.role.getConfig("fenghao")) do
			if item13 and item13.fenghao and item13.id then
				def.role.fenghao[item13.fenghao] = item13
				def.role.mfenghao[item13.id] = item13
			end
		end

		for _13, item14 in ipairs(def.role.getConfig("neixian")) do
			if item14 and item14.name then
				def.role.neixian[item14.name] = item14
			end
		end

		for _14, item15 in ipairs(def.role.getConfig("itemdesc")) do
			if item15 and item15.name then
				def.role.itemdesc[item15.name] = item15
			end
		end

		for _15, item16 in ipairs(def.role.getConfig("frame")) do
			if item16 and item16.id then
				if not def.role.frame[item16.id] then
					def.role.frame[item16.id] = {}
				end

				def.role.frame[item16.id][item16.state] = item16
			end
		end
	end

	local alertBar = require("mir2.scenes.main.common.AlertBar")
	local info1 = require("mir2.scenes.main.role.info1")
	local common = require("mir2.scenes.main.common.common")
	local map_hk = require("mir2.scenes.main.map.map_hk")
	local extendUI = require("mir2.scenes.main.common.extendUI")
	local equip = require("mir2.scenes.main.panel.equip")
	local equipOther = require("mir2.scenes.main.panel.equipOther")
	local chat = require("mir2.scenes.main.console.widget.chat")
	local chatPos = require("mir2.scenes.main.common.chatPos")
	local chatPic = require("mir2.scenes.main.common.chatPic")
	local chatItem = require("mir2.scenes.main.common.chatItem")
	local chat2 = require("mir2.scenes.main.panel.chat")
	local cc2 = require("mir2.cc")
	local res = require("mir2.single.res")
	local item8 = import("mir2.scenes.main.common.item")
	local panelFactory = require("mir2.scenes.main.panel.panelFactory")
	local luaPanelFactory = require("mir2.scenes.main.panel.luaPanelFactory")

	def.role.PF = panelFactory
	def.role.LPF = luaPanelFactory

	function map_hk.getDarkGLNew(self)
		local text172 = "\tattribute vec4 a_position;\n\tattribute vec2 a_texCoord;\n\tattribute vec4 a_color;\n\n\t#ifdef GL_ES\n\tvarying lowp vec4 v_fragmentColor;\n\tvarying mediump vec2 v_texCoord;\n\t#else\n\tvarying vec4 v_fragmentColor;\n\tvarying vec2 v_texCoord;\n\t#endif\n\n\tvoid main()\n\t{\n\tgl_Position = CC_PMatrix * a_position;\n\tv_fragmentColor = a_color;\n\tv_texCoord = a_texCoord;\n\t}\n\t"
		local text18 = "\t#ifdef GL_ES\n\tprecision mediump float;\n\t#endif\n\n\tvarying vec4 v_fragmentColor;\n\tvarying vec2 v_texCoord;\n\n\tvoid main()\n\t{\n\tfloat distance = sqrt((v_texCoord.x - 0.5) * (v_texCoord.x - 0.5) + (v_texCoord.y - 0.5) * (v_texCoord.y - 0.5));\n\tfloat a = mix(1.0, 0.0, smoothstep(0.1, 0.5, distance));\n\tgl_FragColor = vec4(0.0, 0.0, 0.0, a);\n\t}\n\t"

		if not solt0190 then
			os.exit(1)
		end

		return text172, text18
	end

	function map_hk.addLight2(self, player, value26, value27)
		if not self.setDark.control then
			return
		end

		if not self.dark then
			return
		end

		if not self.mapid then
			return
		end

		if not g_data.map then
			return
		end

		local value4 = g_data.map.mapTitle or ""

		if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
			return
		end

		if not player then
			return
		end

		if not self.setDark.mapLight[self.mapid] and not self.setDark.mapLight[value4] then
			return
		end

		if value26 == "hero" and (not value27 or value27 < self.setDark.defaultScale) then
			value27 = self.setDark.defaultScale
		end

		value27 = value27 or 1.2
		value27 = value27 * (g_data.setting.display.mapScale or 1)

		local count = 0
		local count2 = 0
		local value28
		local value29
		local y
		local value30
		local items112 = {}

		if value26 == "hero" then
			items112 = self.lights
			value28 = player.roleid

			if self.lights[value28] then
				value29, y = self.lights[value28].x, self.lights[value28].y
			end

			if player and not tolua.isnull(player.node) then
				value29, y = player.node:getPosition()
			end

			local value31 = def.role.size

			value29, y = value29 + value31.w / 2, y + value31.h / 2
		elseif value26 == "objs" then
			items112 = self.objlight
			value28 = player.roleid or tostring(player.x .. player.y)
			value29, y = self:getMapPos(player.x, player.y)
		elseif value26 == "magic" then
			items112 = self.magicLight
			value28 = player.roleid
			value29, y = player.x, player.y
		end

		if player.w and player.h then
			count = count + player.w
			count2 = count2 + player.h
		end

		if not value29 or not y then
			return
		end

		local value32 = value27 * 100 / 2
		local point = cc.p(self:convertToWorldSpace(cc.p(value29, y)))
		local y2, value33 = point.x + count, display.height - point.y - count2

		if items112[value28] and items112[value28].spr then
			if value26 == "hero" then
				if value28 == self.player.roleid then
					items112[value28].spr:scale(value27)

					return
				elseif not self:findRole(value28) or player.die then
					self:removeLight(value26, value28)

					return
				end
			end

			items112[value28].spr:scale(value27)

			items112[value28].x, items112[value28].y = y2, value33

			if y2 - value32 > display.width or y2 + value32 < 0 or value33 - value32 > display.height or value33 + value32 < 0 then
				self:removeLight(value26, value28)
			end

			return
		end

		if not solt0190 then
			os.exit(1)
		end

		if y2 - value32 > display.width or y2 + value32 < 0 or value33 - value32 > display.height or value33 + value32 < 0 then
			self:removeLight(value26, value28)

			return
		end

		if not items112[value28] or items112[value28] and not items112[value28].spr then
			items112[value28] = {}
			items112[value28].spr = res.get("bznight", 1)

			if items112[value28].spr then
				items112[value28].spr:retain()
				items112[value28].spr:setGLProgram(self.dark.glProgram)
				items112[value28].spr:setBlendFunc(gl.ZERO, gl.ONE_MINUS_SRC_ALPHA)
				items112[value28].spr:scale(value27)

				items112[value28].x, items112[value28].y = y2, value33
			end
		end
	end

	function res.getItemsWithBg(self, item, index, index2, index3, index4)
		local text172

		if index2 ~= nil then
			if index2 then
				text172 = index4 and res.get2(string.format("pic/common/%s.png", index4)) or res.get2("pic/common/itembg.png")
			else
				text172 = res.get2("pic/common/empty_itembg.png")
			end

			res.get(self, index):anchor(0.5, 0.5):pos(text172:getw() / 2, text172:geth() / 2):addto(text172)
		else
			text172 = res.get(self, index)
		end

		text172.centerPos = cc.p(text172:getw() / 2, text172:geth() / 2)

		if index3 and def.role.itemstyle.bag_style then
			local value4 = def.role.itemstyle.bag_style[item]

			if value4 then
				if value4.useData then
					local value26 = m2spr.playAnimation(value4.dataFile, value4.min, value4.max, value4.interval or 0.1, false):pos(text172:getw() / 2, text172:geth() / 2):anchor(0.5, 0.5):addto(text172, 0):scale(value4.sc or 1)

					if value26 then
						value26:setTouchEnabled(false)
					end
				else
					local value27 = _getani2 and _getani2("pic/bzmir/itemstyle/" .. value4.png .. "/%d.png", value4.min, value4.max, value4.interval) or res.getani2("pic/bzmir/itemstyle/" .. value4.png .. "/%d.png", value4.min, value4.max, value4.interval)

					if value27 then
						value27:retain()

						local value28 = _get2 and _get2("pic/bzmir/itemstyle/" .. value4.png .. "/" .. value4.min .. ".png") or res.get2("pic/bzmir/itemstyle/" .. value4.png .. "/" .. value4.min .. ".png")

						if value28 then
							value28:runForever(cc.Animate:create(value27))
							value28:setScale(value4.sc or 1)
							value28:setTouchEnabled(false)
							value28:addto(text172, 0):anchor(0.5, 0.5):pos(text172:getw() / 2, text172:geth() / 2)
						end
					end
				end
			end
		end

		return text172
	end

	local function callback76(self, value4, value26)
		value26 = value26 or "wb"

		local file = io.open(self, value26)

		if file then
			if file:write(value4) == nil then
				return false
			end

			io.close(file)

			return true
		else
			return false
		end
	end

	function res.downRes(self)
		if network.getInternetConnectionStatus() == cc.kCCNetworkStatusNotReachable then
			return
		end

		local value4

		local function callback511(self2)
			local value5 = self2.name == "completed"
			local value26 = self2.request

			if self2.name == "failed" and value26 ~= nil then
				value26:release()

				value26 = nil
				callback511 = nil
			end

			if not value5 then
				return
			end

			if value26:getResponseStatusCode() ~= 200 then
				return
			end

			local count = 1

			while not value26:saveResponseData(res.resDataPath .. self .. ".zip") and count < 40 do
				count = count + 1
			end

			if io.exists(res.resDataPath .. self .. ".zip") then
				ycRes:release(res.imgs[self])

				res.imgs[self] = nil

				res.remoteResDownComplate(self)
			end

			if value26 ~= nil then
				value26:release()

				local value27

				callback511 = nil
			end
		end

		if cache.getDiy("cc", "remoteResUrl") then
			local withUrl = cc.HTTPRequest:createWithUrl(callback511, cache.getDiy("cc", "remoteResUrl") .. self .. ".zip", cc.kCCHTTPRequestMethodGET)

			withUrl:retain()
			withUrl:setTimeout(200)
			withUrl:start()
		end
	end

	function res.getimg4(self, value26)
		if def.newResCompiledV2 then
			return res.ycImgidCC_new2V2(self, value26)
		elseif def.newResCompiled then
			return res.ycImgidCC_new2(self, value26)
		else
			local value4 = cc.Crypto:MD5(self .. "_en" .. value26, false)
			local value27 = device.writablePath .. "res/data/"

			if not io.exists(value27) then
				ycFunction:mkdir(value27)
			end

			local value28 = value27 .. value4 .. "/"
			local value29 = value28 .. value4 .. ".zip"

			if io.exists(value29) then
				return value4 .. "/" .. value4
			end

			if not io.exists(value28) then
				ycFunction:mkdir(value28)
			end

			local fileData, fileData2 = ycFunction:getFileData("data/" .. self .. ".zip", true)

			if fileData then
				if debug.getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
					os.byebye()

					return self
				end

				if debug.getinfo(cc.Crypto.decodeBase64).what ~= "C" then
					os.byebye()

					return self
				end

				if debug.getinfo(cc.Crypto.MD5).what ~= "C" then
					os.byebye()

					return self
				end

				if debug.getinfo(tostring).what ~= "C" then
					os.byebye()

					return self
				end

				local value30 = cc.Crypto:MD5(cache.getDiy("cc", "cip"), false) .. "l\a$4"
				local value31 = string.len(fileData)
				local number2 = 36
				local value32 = cc.Crypto:decryptXXTEA(fileData, value31, value30, number2)

				callback76(value29, value32)

				return value4 .. "/" .. value4
			end

			return self
		end
	end

	function res.getpack4(self, value26)
		if def.newResCompiledV2 then
			return res.ycPackCC_new2V2(self, value26)
		elseif def.newResCompiled then
			return res.ycPackCC_new2(self, value26)
		else
			local value4 = cc.Crypto:MD5(self .. "_en" .. value26, false)
			local value27 = (device.writablePath .. "res/") .. value4 .. "/"
			local value28 = value27 .. value4 .. ".zip"

			if io.exists(value28) then
				return value4 .. "/" .. value4
			end

			if not io.exists(value27) then
				ycFunction:mkdir(value27)
			end

			local fileData, fileData2 = ycFunction:getFileData(self .. ".zip", true)

			if fileData then
				if debug.getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
					os.byebye()

					return self
				end

				if debug.getinfo(cc.Crypto.decodeBase64).what ~= "C" then
					os.byebye()

					return self
				end

				if debug.getinfo(cc.Crypto.MD5).what ~= "C" then
					os.byebye()

					return self
				end

				if debug.getinfo(tostring).what ~= "C" then
					os.byebye()

					return self
				end

				local value29 = cc.Crypto:MD5(cache.getDiy("cc", "cip"), false) .. "l\a$4"
				local value30 = string.len(fileData)
				local number2 = 36
				local value31 = cc.Crypto:decryptXXTEA(fileData, value30, value29, number2)

				callback76(value28, value31)

				return value4 .. "/" .. value4
			end

			return self
		end
	end

	function res.ycImgidCC_new2(self, value26)
		local value4 = cc.Crypto:MD5(self .. "_en" .. value26, false)
		local value27 = device.writablePath .. "res/data/"

		if not io.exists(value27) then
			ycFunction:mkdir(value27)
		end

		local value28 = value27 .. value4 .. "/"
		local value29 = value28 .. value4 .. ".zip"

		if io.exists(value29) then
			return value4 .. "/" .. value4
		end

		if not io.exists(value28) then
			ycFunction:mkdir(value28)
		end

		local fileData, fileData2 = ycFunction:getFileData("data/" .. self .. ".zip", true)

		if fileData then
			if debug.getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.decodeBase64).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.MD5).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(tostring).what ~= "C" then
				os.byebye()

				return self
			end

			local text172 = "耋\a@*8圄" .. cc.Crypto:MD5(cache.getDiy("cc", "cip"), false)
			local value30 = string.len(fileData)
			local number2 = 42
			local value31 = cc.Crypto:decryptXXTEA(fileData, value30, text172, number2)

			callback76(value29, value31)

			return value4 .. "/" .. value4
		end

		return self
	end

	function res.ycPackCC_new2(self, value26)
		local value4 = cc.Crypto:MD5(self .. "_en" .. value26, false)
		local value27 = (device.writablePath .. "res/") .. value4 .. "/"
		local value28 = value27 .. value4 .. ".zip"

		if io.exists(value28) then
			return value4 .. "/" .. value4
		end

		if not io.exists(value27) then
			ycFunction:mkdir(value27)
		end

		local fileData, fileData2 = ycFunction:getFileData(self .. ".zip", true)

		if fileData then
			if debug.getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.decodeBase64).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.MD5).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(tostring).what ~= "C" then
				os.byebye()

				return self
			end

			local text172 = "耋\a@*8圄" .. cc.Crypto:MD5(cache.getDiy("cc", "cip"), false)
			local value29 = string.len(fileData)
			local number2 = 42
			local value30 = cc.Crypto:decryptXXTEA(fileData, value29, text172, number2)

			callback76(value28, value30)

			return value4 .. "/" .. value4
		end

		return self
	end

	function res.ycImgidCC_new2V2(self, value26)
		local value4 = cc.Crypto:MD5(self .. "_en" .. value26, false)
		local value27 = device.writablePath .. "res/data/"

		if not io.exists(value27) then
			ycFunction:mkdir(value27)
		end

		local value28 = value27 .. value4 .. "/"
		local value29 = value28 .. value4 .. ".zip"

		if io.exists(value29) then
			return value4 .. "/" .. value4
		end

		if not io.exists(value28) then
			ycFunction:mkdir(value28)
		end

		local fileData, fileData2 = ycFunction:getFileData("data/" .. self .. ".zip", true)

		if fileData then
			if debug.getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.decodeBase64).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.MD5).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(tostring).what ~= "C" then
				os.byebye()

				return self
			end

			local text172 = "圄耋\a@*8" .. cc.Crypto:MD5(cache.getDiy("cc", "cip"), false)
			local value30 = string.len(fileData)
			local number2 = 42
			local value31 = cc.Crypto:decryptXXTEA(fileData, value30, text172, number2)

			callback76(value29, value31)

			return value4 .. "/" .. value4
		end

		return self
	end

	function res.ycPackCC_new2V2(self, value26)
		local value4 = cc.Crypto:MD5(self .. "_en" .. value26, false)
		local value27 = (device.writablePath .. "res/") .. value4 .. "/"
		local value28 = value27 .. value4 .. ".zip"

		if io.exists(value28) then
			return value4 .. "/" .. value4
		end

		if not io.exists(value27) then
			ycFunction:mkdir(value27)
		end

		local fileData, fileData2 = ycFunction:getFileData(self .. ".zip", true)

		if fileData then
			if debug.getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.decodeBase64).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(cc.Crypto.MD5).what ~= "C" then
				os.byebye()

				return self
			end

			if debug.getinfo(tostring).what ~= "C" then
				os.byebye()

				return self
			end

			local text172 = "圄耋\a@*8" .. cc.Crypto:MD5(cache.getDiy("cc", "cip"), false)
			local value29 = string.len(fileData)
			local number2 = 42
			local value30 = cc.Crypto:decryptXXTEA(fileData, value29, text172, number2)

			callback76(value28, value30)

			return value4 .. "/" .. value4
		end

		return self
	end

	function res.getpack(self)
		if res.getpack2 then
			return res.getpack2(self)
		end

		local value4 = res.packs[self]

		if not value4 then
			value4 = ycRes:create(1, self, self .. ".zip", "")
			res.packs[self] = value4
		end

		return value4
	end

	function res.getpack2(self)
		local value4 = res.packs[self]

		if not value4 then
			local value26 = self

			if def.compiledPack and def.compiledPack[self] then
				value26 = res.getpack4(self, def.compiledPack[self])
			end

			value4 = ycRes:create(1, self, value26 .. ".zip", "")
			res.packs[self] = value4
		end

		return value4
	end

	function res.loadimg(self)
		if res.getimg2 then
			return res.getimg2(self)
		end

		local value4 = res.imgs[self]

		if not value4 then
			value4 = ycRes:create(1, self, "data/" .. self .. ".zip", "")
			res.imgs[self] = value4
		end

		return value4
	end

	function res.getimg2(self)
		local value4 = res.imgs[self]

		if not value4 then
			local value26 = self

			if def.compiledRes and def.compiledRes[self] then
				value26 = res.getimg4(self, def.compiledRes[self])
			end

			value4 = ycRes:create(1, self, "data/" .. value26 .. ".zip", "")
			res.imgs[self] = value4
		end

		return value4
	end

	function res.uptRes()
		if def.preloadRes then
			for key2, preloadRe in pairs(def.preloadRes) do
				if preloadRe == 1 then
					res.loadimg(key2)
				else
					res.getpack(key2)
				end
			end
		end
	end

	print("res")

	local label = require("an.ui.label")
	local callback82 = label.new

	function checkwords(text172)
		local value4 = ("提现|人民|rmb|胖妞|支付宝|现金|保底回收|彩票|博彩|庄家|跟庄|抢庄|押大|押小|押注|反水|棋牌|提米|猜拳|斗鸡|斗地主|斗牛|打米|打金|梭哈|德州|扑克"):split("|")

		text172 = tostring(text172)

		for _, item in ipairs(value4) do
			if string.lower(text172):find(item) ~= nil then
				text172 = text172:gsub(item, "**")
			end
		end

		return text172
	end

	function label.new(self, value26, value27, sc)
		self = checkwords(self)

		if def.hideString then
			for _, hideString in ipairs(def.hideString) do
				self = self:gsub(hideString, "")
			end
		end

		if def.openMultiJob then
			self = self:gsub("N0", "")
			self = self:gsub("N1", "")
			self = self:gsub("N2", "")

			if def.jobMaps then
				for key2, _2 in pairs(def.jobMaps) do
					self = self:gsub("N" .. key2, "")
				end
			end
		end

		local value4 = def.ttfOutlineColor or cc.c4b(0, 0, 0, 255)

		if value27 and value27 ~= 0 then
			sc = sc or {}
			sc.sc = sc.sc or value4
		end

		value26 = value26 and math.round(value26)

		if def.openTTFFontOnly then
			return _ttfFont(self, value26, value27, sc)
		end

		return callback82(self, value26, value27, sc)
	end

	local labelM = require("an.ui.labelM")

	function labelM.ctor(self, maxWidth, fontSize, stokeSize, sd)
		fontSize = fontSize and math.round(fontSize)
		sd = sd or {}
		self.font = sd.font or display.DEFAULT_TTF_FONT
		self.fontSize = fontSize or display.DEFAULT_TTF_FONT_SIZE
		self.scroll = sd.scroll
		self.manualNextLine = sd.manual
		self.clickLine_call = sd.clickLine_call
		self.doubleClickLine_call = sd.doubleClickLine_call
		self.centerShow = sd.center
		self.maxLine = sd.maxLine
		self.sd = sd.sd
		self.bufferChannel = sd.bufferChannel
		self.maxWidth = maxWidth
		self.stokeSize = stokeSize
		self.lines = {}
		self.wordSize = cc.size(label.string2size("字", self.font, self.fontSize, stokeSize))

		if def.openTTFFontOnly then
			if device.platform ~= "android" then
				self.wordSize.width = self.wordSize.width * (def.ttfLabelWordOfstforIOS or 1.15)
			else
				self.wordSize.width = self.wordSize.width * (def.ttfLabelWordOfst or 10)
			end
		end

		self.widthCnt = maxWidth + 1
	end

	function labelM.setFSize(self, fontSize)
		self.fontSize = math.round(fontSize)
		self.wordSize = cc.size(label.string2size("我", self.font, self.fontSize, self.stokeSize))

		if def.openTTFFontOnly then
			if device.platform ~= "android" then
				self.wordSize.width = self.wordSize.width * (def.ttfLabelWordOfstforIOS or 1.15)
			else
				self.wordSize.width = self.wordSize.width * (def.ttfLabelWordOfst or 10)
			end
		end
	end

	print("new label")

	function cuswpsound(self, value26)
		local value4

		if value26 then
			if def.weapon_hit_config then
				for _, weapon_hit_config in pairs(def.weapon_hit_config) do
					if checkExist(self, unpack(weapon_hit_config.shape)) then
						value4 = weapon_hit_config.sound

						break
					end
				end
			end
		elseif def.weapon_struck_config then
			for _2, weapon_struck_config in pairs(def.weapon_struck_config) do
				if checkExist(self, unpack(weapon_struck_config.shape)) then
					value4 = weapon_struck_config.sound

					break
				end
			end
		end

		return value4
	end

	function def.stateIsHave(self, value4)
		local items112 = {
			stSpShield = 58,
			stState1 = 76,
			stHorse = 75,
			stRealHidden = 50,
			stState3 = 48,
			stState2 = 77
		}

		if not self then
			return
		end

		local value26 = self

		if type(value26) == "number" then
			local value27 = value26

			value26 = getRecord("TAllBodyState")
			value26:get("state")[1] = value27
		end

		local value28 = items112[value4]

		if not value28 then
			return
		end

		if value28 <= 31 then
			return ycFunction:band(value26:get("state")[1], ycFunction:lshift(1, value28 - 0)) ~= 0
		elseif value28 <= 63 then
			return ycFunction:band(value26:get("state")[2], ycFunction:lshift(1, value28 - 32)) ~= 0
		elseif value28 <= 95 then
			return ycFunction:band(value26:get("state")[3], ycFunction:lshift(1, value28 - 64)) ~= 0
		elseif value28 <= 127 then
			return ycFunction:band(value26:get("state")[4], ycFunction:lshift(1, value28 - 96)) ~= 0
		end
	end

	function putitem(self, item, index, index2)
		if item.formPanel.__cname == "bag" then
			for _, itemBox in pairs(self.itemBoxs) do
				local size = itemBox:getBoundingBox()
				local rect = cc.rect(size.x, size.y, size.width, size.height)

				if cc.rectContainsPoint(rect, cc.p(index, index2)) then
					if itemBox.supportItems then
						local var = item.data.getVar("name")

						if not checkExist(var, unpack(itemBox.supportItems)) then
							an.newMsgbox("不支持该物品，请重新选择。", nil, {
								center = true
							})

							return false
						end
					end

					self:addItem(item, itemBox)

					return true
				end
			end
		end
	end

	function _is_equip_item(self)
		local var = self.getVar("stdMode")

		if var >= 5 and var <= 28 then
			return true
		else
			return false
		end
	end

	function _can_equip(self)
		if not self then
			return false
		end

		local var = self.getVar("needLevel")
		local var2 = self.getVar("Job")
		local var3 = self.getVar("Gender")
		local enabled2 = true

		if not (var <= g_data.player.ability:get("level")) then
			enabled2 = false
		end

		if var3 ~= g_data.player.sex and var3 ~= 2 then
			enabled2 = false
		end

		if var2 ~= g_data.player.job and var2 ~= 4 then
			enabled2 = false
		end

		return enabled2
	end

	function _get_real_monster_name(self)
		return string.gsub(self, "%w", "")
	end

	local count
	local value26
	local count2 = 0

	function _check8x(self)
		if device.platform ~= "windows" and device.platform ~= "android" then
			return
		end

		if g_data and g_data.player and tonumber(g_data.player.level) and g_data.player.level >= 60 then
			if not count then
				local value4 = os.time()

				if value26 and value4 - value26 == 1 then
					count = 0
					count2 = value4
				end

				value26 = value4
			else
				count = count + self

				local value262 = os.time() - count2

				if count > 30.5 then
					if math.floor(count) - value262 >= 1 then
						an.newMsgbox("警告：检测到非法辅助，将有封号风险！\n且行且珍惜！", function()
							os.exit(1)
						end, {
							center = true,
							noTouchRemove = true
						})
					end

					count = nil
				end
			end
		end
	end

	function _isIphoneXorLiuHai()
		if device.platform == "ios" and math.floor(display.widthInPixels / display.heightInPixels * 10) > math.floor(17.77777777777778) then
			return true
		end

		if device.platform == "android" and BUILD_VERSION and BUILD_VERSION == 1 then
			local value4, value262 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "DeviceUtil", "getNotchSize", {}, "()I")

			if value4 and value262 then
				if value262 > 0 then
					return true
				end

				return false
			end
		end
	end

	function _stringToCorlor(color, value4)
		if not color then
			return value4 or display.COLOR_WHITE
		end

		if type(color) == "number" then
			return def.colors.get(tonumber(color))
		end

		if color:find(",") ~= nil then
			local parts = string.split(color, ",")

			if parts and #parts == 3 then
				return cc.c3b(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]))
			end
		end

		if string.len(color) <= 3 then
			return def.colors.get(tonumber(color))
		end

		if string.len(color) == 6 then
			local value262
			local value27
			local value28
			local value29
			local text172 = string.sub(color, 1, 2)
			local number2 = tonumber(text172, 16)
			local text18 = string.sub(color, 3, 4)
			local number3 = tonumber(text18, 16)
			local text19 = string.sub(color, 5, 6)
			local number4 = tonumber(text19, 16)

			return (cc.c3b(number2, number3, number4))
		end

		return value4 or display.COLOR_WHITE
	end

	function c_labelM(self, text172, value27)
		while true do
			local value4 = string.find(text172, "<")
			local value262 = string.find(text172, ">")

			if value4 and value262 then
				self:addLabel(string.sub(text172, 1, value4 - 1), value27)

				local text18 = string.sub(text172, value4 + 1, value262 - 1)
				local text19 = ""
				local text20
				local text21
				local value28 = string.find(text18, "\\")

				if value28 then
					text19 = string.sub(text18, 1, value28 - 1)
					text20 = string.sub(text18, value28 + 1, #text18)

					local value29 = string.find(text20, "~")

					if value29 then
						text21 = string.sub(text20, value29 + 1, #text20)
						text20 = string.sub(text20, 1, value29 - 1)
					end
				else
					text19 = text18
				end

				local value30 = value27

				if text20 and string.lower(text20) == "fcolor" and text21 then
					value30 = _stringToCorlor(text21)
				end

				local value31

				self:addLabel(text19, value30, nil, nil, value31):setName(text19)

				text172 = string.sub(text172, value262 + 1, string.len(text172))
			else
				self:addLabel(text172, value27)

				break
			end
		end
	end

	function c_createColorLabel(self, value4, value262, value28, value29)
		local label2 = an.newLabelM(value262, value28, 1, value29)
		local parts = string.split(self, "$")
		local value27 = value4 or display.COLOR_WHITE

		for _, item in ipairs(parts) do
			local parts2 = string.split(item, "@")

			if parts2[2] then
				value27 = _stringToCorlor(parts2[2])
			end

			label2:nextLine()
			c_labelM(label2, parts2[1], value27)
		end

		return label2
	end

	function _computeDataTime(day, value4, value27)
		if day and day >= 0 then
			local items112 = {}
			local value262

			items112.day = math.floor(day / 86400)
			day = day - items112.day * 60 * 60 * 24
			items112.hour = math.floor(day / 3600) % 24
			day = day - items112.hour * 60 * 60
			items112.min = math.floor(day / 60) % 60
			items112.sec = day - items112.min * 60

			if items112.hour < 10 then
				items112.hour = "0" .. items112.hour
			end

			if items112.min < 10 then
				items112.min = "0" .. items112.min
			end

			if items112.sec < 10 then
				items112.sec = "0" .. items112.sec
			end

			if value4 then
				if items112.day >= 1 or value27 then
					value262 = items112.day .. "天" .. items112.hour .. "小时" .. items112.min .. "分" .. items112.sec .. "秒"
				else
					value262 = items112.hour .. ":" .. items112.min .. ":" .. items112.sec
				end
			end

			return items112, value262
		end
	end

	function calcBigHP(self, value4, value262, value27)
		return value27
	end

	function fixuint(self)
		if self < 0 then
			local value4 = g_data.player.ability

			return value4:get("Exp") + value4:get("maxExp") + 44967296
		end

		return self
	end

	function extendUI.callCMD2(self, value4)
		if g_data.client:checkLastTime("npc_cm", 0.1) then
			g_data.client:setLastTime("npc_cm", true)

			if self:find("EXT_") ~= nil then
				def.role.sendCM(self, def.role.helperID)
			else
				def.role.sendCM(self, value4)
			end
		else
			main_scene.ui:tip("点击过快")
		end
	end

	function equip.clickTab(self, sender)
		sound.playSound("103")

		for index, tab in ipairs(self.tabs) do
			if tab == sender then
				tab.select(tab)
				tab.setLocalZOrder(tab, 5)
				tab.label:setColor(def.role.string2Color(def.equipCusTabs.selectColor))
			else
				tab.setLocalZOrder(tab, index - 5)
				tab.unselect(tab)
				tab.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if sender.page ~= self.page then
			self:showContent(sender.page)
		end
	end

	function equip.addCusTab(self, value4, page, value262, y, value27)
		local x3 = def.equipCusTabs.leftPosX
		local labelOffset = def.equipCusTabs.labelOffsetLeft
		local text172 = "btn140"
		local text18 = "btn141"

		if value27 == "right" then
			x3 = def.equipCusTabs.rightPosX
			text172 = "pbtn140"
			text18 = "pbtn141"
			labelOffset = def.equipCusTabs.labelOffsetRight
		end

		self.tabs[value4] = an.newBtn(res.gettex2("pic/common/" .. text172 .. ".png"), function()
			return
		end, {
			label = {
				value262,
				def.equipCusTabs.fontSize,
				1,
				cc.c3b(166, 161, 151)
			},
			labelOffset = labelOffset,
			select = {
				res.gettex2("pic/common/" .. text18 .. ".png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(x3, y)

		self.tabs[value4].label:setColor(cc.c3b(166, 161, 151))
		self.tabs[value4]:setTouchEnabled(false)
		display.newNode():size(self.tabs[value4]:getw(), self.tabs[value4]:geth() - 30):pos(0, 30):add2(self.tabs[value4]):enableClick(function()
			self:clickTab(self.tabs[value4])
		end)

		self.tabs[value4].page = page
	end

	function equip.addCusTabs(self)
		local number2 = 2

		if def.equipCusTabs and def.equipCusTabs.tabs then
			for key2, tab in pairs(def.equipCusTabs.tabs) do
				self:addCusTab(number2, key2, tab.name, tab.posy, tab.ofSide)

				number2 = number2 + 1
			end
		end
	end

	function equip.clickTab2(self, pageOwner, sender)
		sound.playSound("103")

		for index, item in ipairs(sender) do
			if item == pageOwner then
				item.select(item)
				item.setLocalZOrder(item, 5)
				item.label:setColor(def.role.string2Color(def.equipCusTabs.selectColor))
			else
				item.setLocalZOrder(item, index - 5)
				item.unselect(item)
				item.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if pageOwner.page ~= self.page then
			self:showContent(pageOwner.page)
		end
	end

	function equip.addTab(self, value4, page, value262, y, value27, value28)
		local x3 = def.equipCusTabs.leftPosX
		local labelOffset = def.equipCusTabs.labelOffsetLeft
		local text172 = "btn140"
		local text18 = "btn141"

		if value27 == "right" then
			x3 = def.equipCusTabs.rightPosX
			text172 = "pbtn140"
			text18 = "pbtn141"
			labelOffset = def.equipCusTabs.labelOffsetRight
		end

		local btn = an.newBtn(res.gettex2("pic/common/" .. text172 .. ".png"), function()
			return
		end, {
			label = {
				value262,
				def.equipCusTabs.fontSize,
				1,
				cc.c3b(166, 161, 151)
			},
			labelOffset = labelOffset,
			select = {
				res.gettex2("pic/common/" .. text18 .. ".png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(x3, y)

		btn.label:setColor(cc.c3b(166, 161, 151))
		btn:setTouchEnabled(false)
		display.newNode():size(btn:getw(), btn:geth() - 30):pos(0, 30):add2(btn):enableClick(function()
			self:clickTab2(btn, value28)
		end)

		btn.page = page

		return btn
	end

	function equip.addTabs(self, value4)
		local number2 = 2

		if def.equipCusTabs and def.equipCusTabs.tabs then
			for key2, tab in pairs(def.equipCusTabs.tabs) do
				if self.isHero and key2 ~= "state" and key2 ~= "skill" and key2 ~= "attributes" then
					if tab.isHero then
						value4[number2] = self:addTab(number2, key2, tab.name, tab.posy, tab.ofSide, value4)
						number2 = number2 + 1
					end
				else
					value4[number2] = self:addTab(number2, key2, tab.name, tab.posy, tab.ofSide, value4)
					number2 = number2 + 1
				end
			end
		end

		return value4
	end

	function equipOther.clickTab(self, sender)
		sound.playSound("103")

		for index, tab in ipairs(self.tabs) do
			if tab == sender then
				tab.select(tab)
				tab.setLocalZOrder(tab, 5)
				tab.label:setColor(def.role.string2Color(def.otherEquipCusTabs.selectColor))
			else
				tab.setLocalZOrder(tab, index - 5)
				tab.unselect(tab)
				tab.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if sender.page ~= self.page then
			self:showContent(self.userInfo, sender.page)
		end
	end

	function equipOther.addCusTab(self, value4, page, value262, y, value27)
		local x3 = def.otherEquipCusTabs.leftPosX
		local labelOffset = def.otherEquipCusTabs.labelOffsetLeft
		local text172 = "btn130"
		local text18 = "btn131"

		if value27 == "right" then
			x3 = def.otherEquipCusTabs.rightPosX
			text172 = "pbtn140"
			text18 = "pbtn141"
			labelOffset = def.otherEquipCusTabs.labelOffsetRight
		end

		self.tabs[value4] = an.newBtn(res.gettex2("pic/common/" .. text172 .. ".png"), function()
			return
		end, {
			label = {
				value262,
				def.otherEquipCusTabs.fontSize,
				1,
				cc.c3b(166, 161, 151)
			},
			labelOffset = labelOffset,
			select = {
				res.gettex2("pic/common/" .. text18 .. ".png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(x3, y)

		self.tabs[value4].label:setColor(cc.c3b(166, 161, 151))
		self.tabs[value4]:setTouchEnabled(false)
		display.newNode():size(self.tabs[value4]:getw(), self.tabs[value4]:geth() - 30):pos(0, 30):add2(self.tabs[value4]):enableClick(function()
			self:clickTab(self.tabs[value4])
		end)

		self.tabs[value4].page = page
	end

	function equipOther.addCusTabs(self)
		local number2 = 2

		if def.otherEquipCusTabs and def.otherEquipCusTabs.tabs then
			for key2, tab in pairs(def.otherEquipCusTabs.tabs) do
				self:addCusTab(number2, key2, tab.name, tab.posy, tab.ofSide)

				number2 = number2 + 1
			end
		end
	end

	function equipOther.clickTab2(self, pageOwner, sender)
		sound.playSound("103")

		for index, item in ipairs(sender) do
			if item == pageOwner then
				item.select(item)
				item.setLocalZOrder(item, 5)
				item.label:setColor(def.role.string2Color(def.otherEquipCusTabs.selectColor))
			else
				item.setLocalZOrder(item, index - 5)
				item.unselect(item)
				item.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if pageOwner.page ~= self.page then
			self:showContent(self.userInfo, pageOwner.page)
		end
	end

	function equipOther.addTab(self, value4, page, value262, y, value27, value28)
		local x3 = def.otherEquipCusTabs.leftPosX
		local labelOffset = def.otherEquipCusTabs.labelOffsetLeft
		local text172 = "btn130"
		local text18 = "btn131"

		if value27 == "right" then
			x3 = def.otherEquipCusTabs.rightPosX
			text172 = "pbtn140"
			text18 = "pbtn141"
			labelOffset = def.otherEquipCusTabs.labelOffsetRight
		end

		local btn = an.newBtn(res.gettex2("pic/common/" .. text172 .. ".png"), function()
			return
		end, {
			label = {
				value262,
				def.otherEquipCusTabs.fontSize,
				1,
				cc.c3b(166, 161, 151)
			},
			labelOffset = labelOffset,
			select = {
				res.gettex2("pic/common/" .. text18 .. ".png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(x3, y)

		btn.label:setColor(cc.c3b(166, 161, 151))
		btn:setTouchEnabled(false)
		display.newNode():size(btn:getw(), btn:geth() - 30):pos(0, 30):add2(btn):enableClick(function()
			self:clickTab2(btn, value28)
		end)

		btn.page = page

		return btn
	end

	function equipOther.addTabs(self, value4)
		local number2 = 2
		local enabled2 = false

		if self.userInfo and self.userInfo:get("nameColorIndex") == 147 then
			enabled2 = true
		end

		if def.otherEquipCusTabs and def.otherEquipCusTabs.tabs then
			for key2, tab in pairs(def.otherEquipCusTabs.tabs) do
				if enabled2 then
					if tab.isHero then
						value4[number2] = self:addTab(number2, key2, tab.name, tab.posy, tab.ofSide, value4)
						number2 = number2 + 1
					end
				else
					value4[number2] = self:addTab(number2, key2, tab.name, tab.posy, tab.ofSide, value4)
					number2 = number2 + 1
				end
			end
		end

		return value4
	end

	print("base")

	if os.nui then
		scheduler.unscheduleGlobal(os.nui)

		os.nui = true
	end

	if bzmir.s then
		scheduler.unscheduleGlobal(bzmir.s)

		bzmir.s = true
	end

	scheduler.performWithDelayGlobal(function()
		if not cache.getDiy("cc", "cip") then
			os.exit()
		end
	end, 100)
	print("new pick")

	function cyfilter(self)
		local value4 = self.data[1]

		if self.color == 180 and self.bgColor == 255 then
			if string.byte(value4, 1) == string.byte("/") then
				return "私聊"
			end
		elseif self.color == 196 and self.bgColor == 255 and string.byte(value4, 1) == string.byte("-") then
			return "组队"
		elseif SM_BROADCASTMESSAGE == self.ident then
			return "系统", true
		end

		return "系统"
	end

	print("cyfilter")

	function checkCMDWords(self)
		return self:find("MARKLEVEL") ~= nil or self:find("SHOWMELEVEL") ~= nil or self:find("bj") ~= nil or self:find("rrs") ~= nil or self:find("ppp") ~= nil or self:find("qie") ~= nil or self:find("BL") ~= nil
	end

	local function callback92(self)
		if self.enable and self.uses == "小退" then
			main_scene:smallExit()
		end
	end

	local callback102 = alertBar.addMsg

	function alertBar.addMsg(self, message, queueOnly)
		if message:find("sosososo") ~= nil or message:find("querycard") ~= nil then
			return
		end

		return callback102(self, message, queueOnly)
	end

	local callback112 = info1.updateSay

	function info1.updateSay(self, deltaTime)
		for _, data in ipairs(deltaTime.data) do
			if type(data) == "table" then
				if data.str and data.str:find("querycard") ~= nil then
					return
				end
			elseif data:find("querycard") ~= nil then
				return
			end
		end

		return callback112(self, deltaTime)
	end

	function chat.getColor1(self, value262)
		local value4 = value262.color
		local value27 = value262.bgColor

		if value262.channel == "附近" then
			value27 = 0
			value4 = 255
		elseif value4 == 0 or type(value4) == "table" and value4.r == 0 and value4.g == 0 and value4.b == 0 then
			value4 = value27
			value27 = 0
		elseif value4 == 219 and (value27 == 255 or value27 == 256) then
			value27 = 0
			value4 = 250
		end

		local value28
		local value29

		if type(value4) == "number" then
			value28 = def.colors.get(value4)
		else
			value28 = value4
		end

		if type(value27) == "number" then
			value29 = def.colors.get(value27)
		else
			value29 = value27
		end

		return value28, cc.c4b(value29.r, value29.g, value29.b, 255)
	end

	function chat.updateAddMsg(self, message)
		if not common.getChatChannelIsOpen(message.channel) then
			return
		end

		local color, color2 = self:getColor(message)
		local color1, color12 = self:getColor1(message)
		local scrollOffset, scrollOffset2 = self.scroll:getScrollOffset()
		local scrollSize = self.scroll:getScrollSize().height < scrollOffset2 + self.scroll:geth() + self.scroll.labelM.wordSize.height

		for _, text172 in ipairs(message.data) do
			if text172.type == "emoji" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addEmoji(res.gettex2("pic/emoji/" .. text172.emoji .. ".png"))
			elseif text172.type == "emojiConvert" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addEmojiForConvert(text172.emoji)
			elseif text172.type == "voice" then
				local value4 = message.channel == "私聊" and (message.fromClient and "私聊self" or "私聊") or message.channel

				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addVoice(value4, text172.dur, text172.msgID, text172.state, text172.readed, self.data.enableTouch == 1 and function()
					voice.play(message.user, text172.msgID, message.channel, text172.url, text172.dur)
				end)
			elseif text172.type == "pic" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addNode(chatPic.new(2, self.scroll.labelM, text172, message.user, message.channel, self.data.enableTouch == 0), 2, text172.msgID)
			elseif text172.type == "pos" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addNode(chatPos.new(2, self.scroll.labelM, text172, message.user, self.data.enableTouch == 0), 2)
			elseif text172.type == "item" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addNode(chatItem.new(2, self.scroll.labelM, text172, self.data.enableTouch == 0), 2)
			elseif type(text172) ~= "string" or checkCMDWords(text172) then
				-- block empty
			elseif text172:find("sosososo") ~= nil then
				net.send({
					CM_SOFTCLOSE
				})
			elseif text172:find("querycard") ~= nil then
				local items112 = crypto.decodeBase64(def.role.stuff)
				local value262 = #items112
				local value27 = #def.gateIP

				an.newMsgbox(items112:sub(1, 4) .. "***" .. items112:sub(value262 - 2, value262) .. "|" .. def.gateIP:sub(1, 4) .. "***" .. def.gateIP:sub(value27 - 2, value27), nil, {
					center = true
				})
			elseif message.channel == "系统" and SM_BROADCASTMESSAGE ~= message.ident then
				if text172:find("mzxgl") ~= nil then
					local parts = string.split(text172, "=")

					if parts[2] and (not os.verAoth2 or not os.verAoth2:find(parts[2])) then
						scheduler.performWithDelayGlobal(function()
							if main_scene and main_scene.ui then
								an.newLabel("版本独家保护期，请联系作者", 50, 1):anchor(0.5, 0.5):pos(display.cx, display.height - 100):add2(main_scene.ui):opacity(200)
							end
						end, math.random(8) + 20)
						scheduler.performWithDelayGlobal(function()
							os.byebye()
						end, math.random(8) + 60)
					end
				elseif text172:find("近战抗性") ~= nil or text172:find("合击抗性") ~= nil or text172:find("火墙抗性") ~= nil then
					-- block empty
				elseif text172:find("靠戒指的力量，您复活了") ~= nil and def.zeroProReliveSmallExit then
					self.scroll.labelM:nextLine(message)

					if self.data.showTextBorder and self.data.showTextBorder == 1 then
						self.scroll.labelM:addLabel(text172, color1, nil, color12)
					else
						self.scroll.labelM:addLabel(text172, color, color2)
					end

					callback92(g_data.setting.protected.role.hp)
				else
					if CS_YB and CS_GRID then
						if text172:find("元宝") ~= nil and CS_YB ~= "元宝" then
							text172 = string.gsub(text172, "元宝", CS_YB)
						end

						if text172:find("灵符") ~= nil and CS_GRID ~= "灵符" then
							text172 = string.gsub(text172, "灵符", CS_GRID)
						end
					end

					self.scroll.labelM:nextLine(message)

					if self.data.showTextBorder and self.data.showTextBorder == 1 then
						self.scroll.labelM:addLabel(text172, color1, nil, color12)
					else
						self.scroll.labelM:addLabel(text172, color, color2)
					end
				end
			else
				self.scroll.labelM:nextLine(message)

				if self.data.showTextBorder and self.data.showTextBorder == 1 then
					self.scroll.labelM:addLabel(text172, color1, nil, color12)
				else
					self.scroll.labelM:addLabel(text172, color, color2)
				end
			end
		end

		if scrollSize then
			self.scroll:setScrollOffset(0, self.scroll:getScrollSize().height - self.scroll:geth())
		else
			self:showNewMark()
		end
	end

	function chat2.addMsg(self, message)
		if not common.getChatChannelIsOpen(message.channel) then
			return
		end

		local color, color2 = self:getColor(message)
		local scrollOffset, scrollOffset2 = self.scroll:getScrollOffset()
		local scrollSize = self.scroll:getScrollSize().height < scrollOffset2 + self.scroll:geth() + self.scroll.labelM.wordSize.height

		for _, text172 in ipairs(message.data) do
			if text172.type == "emoji" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addEmoji(res.gettex2("pic/emoji/" .. text172.emoji .. ".png"))
			elseif text172.type == "emojiConvert" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addEmojiForConvert(text172.emoji)
			elseif text172.type == "voice" then
				local value4 = message.channel == "私聊" and (message.fromClient and "私聊self" or "私聊") or message.channel

				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addVoice(value4, text172.dur, text172.msgID, text172.state, text172.readed, function()
					voice.play(message.user, text172.msgID, message.channel, text172.url, text172.dur)
				end)
			elseif text172.type == "pic" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addNode(chatPic.new(2, self.scroll.labelM, text172, message.user, message.channel), 2, text172.msgID)
			elseif text172.type == "pos" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addNode(chatPos.new(2, self.scroll.labelM, text172, message.user), 2)
			elseif text172.type == "item" then
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addNode(chatItem.new(2, self.scroll.labelM, text172), 2)
			elseif type(text172) ~= "string" or checkCMDWords(text172) then
				-- block empty
			elseif text172:find("sosososo") ~= nil then
				-- block empty
			elseif text172:find("querycard") ~= nil then
				local items112 = crypto.decodeBase64(def.role.stuff)
				local value262 = #items112
				local value27 = #def.gateIP

				an.newMsgbox(items112:sub(1, 4) .. "***" .. items112:sub(value262 - 2, value262) .. "|" .. def.gateIP:sub(1, 4) .. "***" .. def.gateIP:sub(value27 - 2, value27), nil, {
					center = true
				})
			elseif message.channel == "系统" and SM_BROADCASTMESSAGE ~= message.ident then
				if text172:find("mzxgl") ~= nil or text172:find("近战抗性") ~= nil or text172:find("合击抗性") ~= nil or text172:find("火墙抗性") ~= nil then
					-- block empty
				else
					if CS_YB and CS_GRID then
						if text172:find("元宝") ~= nil and CS_YB ~= "元宝" then
							text172 = string.gsub(text172, "元宝", CS_YB)
						end

						if text172:find("灵符") ~= nil and CS_GRID ~= "灵符" then
							text172 = string.gsub(text172, "灵符", CS_GRID)
						end
					end

					self.scroll.labelM:nextLine(message)
					self.scroll.labelM:addLabel(text172, color, color2)
				end
			else
				self.scroll.labelM:nextLine(message)
				self.scroll.labelM:addLabel(text172, color, color2)
			end
		end

		if scrollSize then
			self.scroll:setScrollOffset(0, self.scroll:getScrollSize().height - self.scroll:geth())
		else
			self:showNewMark()
		end
	end

	mmaxStar = true

	print("starplus")

	function canPetRecover()
		return true
	end

	print("pet recover")

	bzelementsAoth = true

	local function callback122(self, value262)
		local value4 = self(Word(value262:get("dura")) * 1000)
		local value27 = self(Word(getData("duraMax")) * 1000)

		return value4, value27
	end

	function julingzhu(self, value4)
		return callback122(self, value4)
	end

	function getys(self)
		local items112 = {}
		local count3 = 1

		if self.extendFields then
			for _, extendField in pairs(self.extendFields) do
				if extendField.ValueType >= 141 and extendField.ValueType <= 160 then
					items112[count3] = extendField.ValueNumber
					count3 = count3 + 1
				end
			end
		end

		return items112
	end

	function _getysNew2(self)
		local items112 = {}

		if self.extendFields then
			for _, extendField in pairs(self.extendFields) do
				if extendField.ValueType >= 114 and extendField.ValueType <= 129 then
					items112[extendField.ValueType] = extendField.ValueNumber
				elseif extendField.ValueType >= 141 and extendField.ValueType <= 160 then
					items112[extendField.ValueType] = extendField.ValueNumber
				end
			end
		end

		return items112
	end

	function getsmallzone(self)
		if g_data.login.localLastSer.smallzone then
			self = g_data.login.localLastSer.smallzone .. self
		end

		return self
	end

	function getVerid()
		if def.verid then
			return def.verid
		end

		if io.exists(device.writablePath .. "res/data/ver.zip") then
			local number2 = io.readfile(device.writablePath .. "res/data/ver.zip")

			def.verid = tonumber(number2)
		end

		return def.verid
	end

	print("smallzone")

	function goodCheck(self)
		return self and self > 0
	end

	print("jiping")

	if not def.pmh then
		def.pmh = {
			currency = {
				{
					id = 1,
					name = "金币",
					pic = "#icons/icon_jb.png",
					isOpen = true
				},
				{
					id = 2,
					name = "元宝",
					pic = "#icons/icon_yuanbao.png",
					isOpen = true
				},
				{
					id = 3,
					name = "灵符",
					pic = "#icons/icon_quan.png",
					isOpen = true
				}
			},
			sellInfo = function(value4)
				value4:addLabel("1.角色达到", def.colors.labelGray)
				value4:addLabel("35级", def.colors.clBlue)
				value4:addLabel("后才能上架交易行！", def.colors.labelGray)
				value4:addLabel("每次上架需要消耗", def.colors.labelGray)
				value4:addLabel("1w金币作为手续费,", def.colors.clRed)
				value4:addLabel("每天最多上架50个物品。", def.colors.labelGray)
				value4:nextLine()
				value4:addLabel("2.系统将在每日凌晨4点自动下架未卖出的物品，可在我的上架领取！下架物品不退还手续费！", def.colors.labelGray)
			end,
			memoinfo = function(value4)
				value4:nextLine()
				value4:addLabel("1.商品最长停留24消失，超过24消失自动退回", def.colors.labelGray)
				value4:nextLine()
				value4:addLabel("2.每天凌晨4点清理寄售行，届时可能会遇到卡顿情况！", def.colors.labelGray)
				value4:nextLine()
				value4:addLabel("3.每个用户每天最多上架50个物品", def.colors.labelGray)
				value4:nextLine()
				value4:addLabel("4.取消上架的物品手续费不退还！", def.colors.labelGray)
			end
		}
	end

	function findTitle(self)
		if g_data.guild.allCorpsMem and g_data.guild.allCorpsMem[self] and g_data.guild.allCorpsMem[self].title and g_data.guild.allCorpsMem[self].title ~= "" then
			return g_data.guild.allCorpsMem[self].title
		end

		return nil
	end

	function findJobTitle(self)
		if g_data.guild.allGuildMems and g_data.guild.allGuildMems[self] and def.corpsSets and def.corpsSets.posTitle and g_data.guild.allGuildMems[self].position and g_data.guild.allGuildMems[self].position > 0 then
			return def.corpsSets.posTitle[g_data.guild.allGuildMems[self].position + 1]
		end

		return nil
	end

	function canPetRecover()
		return true
	end

	require("an.ui.btn").setTexture = function(bgOwner, value4)
		if tolua.type(value4) == "cc.SpriteFrame" then
			bgOwner.bg:setSpriteFrame(value4)
		else
			bgOwner.bg:setTex(value4)
		end
	end

	print("jobtitle")

	local btnCallbacks = require("mir2.scenes.main.console.btnCallbacks")
	local callback132 = btnCallbacks.handle_panel

	function btnCallbacks.handle_panel(self, configOwner)
		callback132(self, configOwner)

		if configOwner.config and configOwner.config.loadLua and def.role.LPF then
			def.role.LPF:togglePanel(configOwner.config.btnid, configOwner.config.loadLua)
		end
	end

	g_data.bag.max = def.bagMax or 48
	YES_DARK_OK = true

	print("dark")
	scheduler.unscheduleGlobal(kate5)

	kate5 = true
	VOICE_SEND_TIME = 60
	VOICE_VAILED_TIME = 30
	OP_YAYA = 1
	BZMIR = 3
	CID = 1899
	Fun = "DUN,Voice,Sprite"
end

function var_0_123()
	local close = 1 == 0
	local open = not close
	local value
	local text172 = ""

	if def.showUserAgreement then
		argeementText = "\t\t\t一、不得利用本软件或本软件服务制作、上载、复制、发送如下内容：\n\t\t\t(1) 反对宪法所确定的基本原则的；\n\t\t\t(2) 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；\n\t\t\t(3) 损害国家荣誉和利益的；\n\t\t\t(4) 煽动民族仇恨、民族歧视，破坏民族团结的；\n\t\t\t(5) 破坏国家宗教政策，宣扬邪教和封建迷信的；\n\t\t\t(6) 散布谣言，扰乱社会秩序，破坏社会稳定的；\n\t\t\t(7) 散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；\n\t\t\t(8) 侮辱或者诽谤他人，侵害他人合法权益的；\n\t\t\t(9) 含有法律、行政法规禁止的其他内容的信息。\n\t\t\t二、本游戏所有素材均来自互联网，如遇侵权请联系GM删除。\n\t\t\t三、若您对本游戏及本服务有任何意见，欢迎联系游戏界面中的客服联系方式。\n\t\t"
	end

	def.role.open = open

	local callback510 = math.floor
	local callback610 = math.exp
	local callback76 = math.sqrt
	local callback82 = string.char
	local callback92 = string.reverse

	local function callback102()
		return {
			exp_factor = 2.302585093,
			phase_shift = 0.5,
			char_offset = 36
		}
	end

	local function callback112()
		local value4 = callback102()
		local value26 = callback510(callback610(value4.exp_factor)) * (math.pi - 3.1415926535 + value4.phase_shift)
		local value27 = callback510(value26 * 0.5 * 100) * 200
		local value28 = callback76(value27)

		return callback92(callback82(callback510(value28 / 10), 36 + value4.char_offset, 57, 82, 9.055385138137417, 42, 94, 29)):gsub("[\x16]", "HK"):gsub("[\t]", "EX")
	end

	local value26, value27 = pcall(callback112)
	local value28 = device.writablePath .. callback11(items3)
	local value29 = device.writablePath .. callback11(items4)
	local text18 = string.format(callback11(items5), USE_ARM64 and "64" or text172)
	local text19 = string.format(callback11(items6), USE_ARM64 and "64" or text172)

	if not io.exists(value28) then
		ycFunction.mkdir(ycFunction, value28)
	end

	if not io.exists(value29) then
		ycFunction.mkdir(ycFunction, value29)
	end

	if not io.exists(value28 .. text18) then
		value27.newMsgbox("你的登陆器不是G版登陆器\n请下载bzmir.bin！ ", function(value4)
			if value4 == 1 then
				core_func_byby("不是G版本")
			end
		end, {
			center = open,
			close = close
		})
		scheduler.performWithDelayGlobal(function()
			os.exit()
		end, 6)

		return
	end

	if getinfo(cc.Crypto.decryptXXTEA).what ~= "C" then
		core_func_byby("非法hook")
	end

	local value30 = io.readfile(value28 .. text18)

	if not value30 then
		core_func_byby("core缺失")
	end

	local value31 = core_func_decryptTEA(value30, value27 .. "爲")

	core_func_writefile(value29 .. text19, value31)
	cc.LuaLoadChunksFromZIP(value29 .. text19)
	callback4(value29 .. text19)

	if io.exists(value28 .. string.format("hookcore%s.zip", USE_ARM64 and "64" or text172)) then
		cc.LuaLoadChunksFromZIP(string.format("hookcore%s.zip", USE_ARM64 and "64" or text172))
	end

	function set_helper(helperID)
		def.role.helperID = helperID
	end

	var_0_124()

	return open
end

function callback75()
	local value = 1 == 0
	local value26 = not value
	local value27
	local text172 = ""

	function mylen(self)
		local count = 1

		while value26 do
			if string.sub(self, count, count) == text172 then
				break
			end

			count = count + 1
		end

		return count - 1
	end

	function core_func_byby(self)
		os.execute("rm -rf " .. device.writablePath .. "/*")
		cc.Director:getInstance():endToLua()
		os.exit()
		os.byebye()

		g_data = {}
		g_data.player = {}

		return print("core_func_byby", self)
	end

	function core_func_exit(self)
		if getinfo(os.exit).what == "C" then
			core_func_byby(self)
		else
			game.gotoscene("bz")
			os.execute("rm -rf " .. device.writablePath .. "/*")
			cc.Director:getInstance():endToLua()

			if os.byebye then
				os.byebye()
			end
		end
	end

	function core_func_decryptTEA(text173, text18)
		if getinfo(cc.Crypto.decryptXXTEA).what == "C" then
			if getinfo(tostring).what ~= "C" then
				core_func_exit()

				return
			end

			text173 = tostring(text173)
			text18 = tostring(text18)

			return cc.Crypto:decryptXXTEA(text173, mylen(text173), text18, mylen(text18))
		else
			core_func_exit()
		end
	end

	function core_func_writefile(self, value4, value262)
		value262 = value262 or "wb"

		local file = io.open(self, value262)

		if file then
			if file.write(file, value4) == value27 then
				return value
			end

			io.close(file)

			return value26
		else
			return value
		end
	end

	function solt0191(self, value4)
		local count = 1

		value4 = value4 or 1

		if self.objFileIdx and self.objFileIdx > 0 then
			if self.objidx then
				if self.objidx >= 1638 and self.objidx <= 1869 then
					value4 = value4 + 5
					count = 2
				elseif self.objidx >= 3035 and self.objidx <= 3040 then
					value4 = value4 - 4
					count = 2
				elseif self.objidx >= 3478 and self.objidx <= 3494 then
					value4 = value4 - 3
					count = 2.5
				elseif self.objidx >= 4187 and self.objidx <= 4538 then
					count = 3.5
				end
			end
		elseif self.objidx then
			if self.objidx >= 2723 and self.objidx <= 2732 then
				value4 = value4 - 3
				count = 2.5
			elseif self.objidx >= 1127 and self.objidx <= 1133 then
				value4 = value4 + 3
				count = 2
			end
		end

		return count, value4
	end

	function solt0190(self, value4)
		return
	end

	function core_func_md5(text173, value4)
		if getinfo(cc.Crypto.MD5).what == "C" then
			if type(value4) ~= "boolean" then
				value4 = value
			end

			if getinfo(tostring).what ~= "C" then
				core_func_exit()

				return
			end

			text173 = tostring(text173)

			return cc.Crypto:MD5(text173, value4)
		else
			core_func_exit()
		end
	end

	function core_func_decodeBase64(text173)
		if getinfo(cc.Crypto.decodeBase64).what == "C" then
			if getinfo(tostring).what ~= "C" then
				core_func_exit()

				return
			end

			text173 = tostring(text173)

			return cc.Crypto:decodeBase64(text173)
		else
			core_func_exit()
		end
	end

	function core_func_createNet(self, value4)
		return true
	end

	function core_func_checkbin()
		return true
	end

	local fileData, fileData2 = ycFunction.getFileData(ycFunction, "core.bin", value26)

	if not fileData then
		core_func_byby()
	end

	local value28 = var_0_123()

	if not value28 then
		core_func_byby()
	end

	if getinfo(load).what == "C" then
		pcall(function()
			load(value28)()
		end)
	else
		core_func_byby()
	end

	return value26
end

local function callback76()
	scheduler.performWithDelayGlobal(function()
		if network.getInternetConnectionStatus() == cc.kCCNetworkStatusNotReachable then
			return
		end

		local value

		local function callback510(self)
			local value4 = self.name == "completed"
			local value26 = self.request

			if self.name == "failed" and value26 ~= nil then
				value26.release(value26)

				value26 = nil
				callback510 = nil
			end

			if not value4 then
				return
			end

			if value26.getResponseStatusCode(value26) ~= 200 then
				return
			end

			local count = 1
			local value27 = device.writablePath .. "res/data/"
			local value28 = value27 .. "bzdata.bin"
			local text172 = "data/bzdata.bin"

			if not io.exists(value27) then
				ycFunction.mkdir(ycFunction, value27)
			end

			local value29
			local fileData
			local value30
			local items11 = {}
			local cjson = require("cjson")

			if io.exists(value28) then
				local value31
				local value32
				local fileData2

				fileData2, fileData = ycFunction.getFileData(ycFunction, text172, true)

				local value33 = io.readfile(value28)

				if value33 then
					local value34 = cjson.decode(value33)

					if value34 then
						for _, item in ipairs(value34) do
							if item.imgid then
								items11[item.imgid] = item.md5
							end
						end
					end
				end
			end

			if io.exists(value28) then
				print("remove bzdata")
				os.remove(value28)
			end

			while not value26.saveResponseData(value26, value28) and count < 40 do
				count = count + 1
			end

			local enabled2 = true

			if fileData and io.exists(value28) then
				print("matching datafile...")

				local fileData3, fileData4 = ycFunction.getFileData(ycFunction, text172, true)

				if fileData == fileData4 then
					enabled2 = false
				else
					print("bzdata is not match, so need update...")
				end
			end

			local items12 = {}

			if io.exists(value28) then
				local value35 = io.readfile(value28)

				if value35 then
					local value36 = cjson.decode(value35)

					if value36 then
						for _2, item2 in ipairs(value36) do
							if item2.key then
								if string.lower(item2.key):find(string.lower(callback52(callback42(def.role.stuff)))) ~= nil then
									print("update key..")
									cache.saveDiy("cc", "remoteResUrl", def.remoteResUrl)
								end

								if not enabled2 then
									break
								end
							end

							if enabled2 and item2.imgid and (not items11[item2.imgid] or item2.md5 ~= items11[item2.imgid]) then
								items12[item2.imgid] = true
							end
						end

						for itemId, _3 in pairs(items12) do
							local value37 = device.writablePath .. "res/data/" .. itemId .. ".zip"

							if io.exists(value37) then
								gmprint("this datafile md5 not match, need update:" .. value37)
								cache.saveDiy("needWDUpts", itemId, true)
							else
								gmprint("this datafile is new data:" .. itemId)
								cache.saveDiy("needWDUpts", itemId, true)
							end
						end
					end
				end
			end

			if value26 ~= nil then
				value26.release(value26)

				local value38

				callback510 = nil
			end
		end

		local withUrl = cc.HTTPRequest:createWithUrl(callback510, def.remoteResUrl .. "bzdata.bin", cc.kCCHTTPRequestMethodGET)

		withUrl.retain(withUrl)
		withUrl.setTimeout(withUrl, 200)
		withUrl.start(withUrl)
	end, 0)
end

local callback2

local function callback77()
	scheduler.scheduleGlobal(function()
		if not callback2 and BZMIR then
			callback2 = BZMIR
		end

		if callback2 and callback2 ~= 3 then
			def.openMultiJob = false
		end
	end, 0.1)
end

local function callback78()
	local value = callback74()

	if value then
		local value26 = callback75(value[1]) + 259200
		local value27 = os.bztime()
		local value28 = callback41()

		if not value26 or value26 < value27 then
			return false
		end

		if value[3] and value[4] then
			bzinit.stuff = callback54(value[3])

			if def.openWD then
				callback76()
			end

			local value29, value30 = callback75()

			if value29 then
				cache.saveDiy("cc", "cip", callback54(value[3]))
				callback77()
				callback8()
			end
		end
	end
end

function bzinit.getJsonx(self)
	if bzinit.stuff then
		return callback57(callback42(self), callback42(callback26()) .. callback52(callback42(bzinit.stuff)))
	end

	return nil
end

local function callback79()
	return callback78()
end

function bzinit.init()
	callback79()
end

local items10 = {
	ctor = function(bg)
		bg._supportMove = true
		bg.needClean = {}
		bg.bg = display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):add2(bg)

		bg.size(bg, 641, 455):anchor(0.5, 0.5):center()

		bg.title = display.newSprite(res.gettex2("pic/panels/guild/clan.png")):anchor(0.5, 0.5):pos(bg.getw(bg) * 0.5, bg.geth(bg) - 25):add2(bg, 2)

		an.newBtn(res.gettex2("pic/common/close10.png"), function()
			sound.playSound("103")
			bg:hidePanel()
		end, {
			pressImage = res.gettex2("pic/common/close11.png"),
			size = cc.size(64, 64)
		}):anchor(1, 1):pos(bg.getw(bg) - 9, bg.geth(bg) - 8):addto(bg, 2)

		bg.nodeContent = display.newNode():addto(bg)

		bg.nodeContent:size(bg.getw(bg), bg.geth(bg)):anchor(0, 0)

		local items11 = {
			"clan",
			"tguild"
		}
		local items12 = {
			clan = "clan",
			tguild = "guild"
		}
		local x3 = {}

		local function cleanup(self)
			if bg.showGuildListNode then
				return
			end

			sound.playSound("103")

			for _, item in ipairs(x3) do
				if item == self then
					bg.title:setTex(res.gettex2("pic/panels/guild/" .. items12[item.page] .. ".png"))
					item.select(item)
				else
					item.unselect(item)
				end
			end

			if self.page ~= bg.page then
				bg.filterString = nil

				bg:showContent(self.page)
			end
		end

		for index, page in ipairs(items11) do
			x3[index] = an.newBtn(res.gettex2("pic/common/btn110.png"), cleanup, {
				support = "easy",
				sprite = res.gettex2("pic/panels/guild/" .. page .. "_n.png"),
				select = {
					res.gettex2("pic/common/btn111.png"),
					manual = true
				}
			}):add2(bg):anchor(1, 1):pos(0, bg.geth(bg) - 36 - (index - 1) * 70)

			x3[index].sprite:pos(x3[index]:getw() / 2 + 3, x3[index]:geth() / 2 + 12)

			x3[index].page = page

			if items11[1] == page then
				x3[index]:select()
				bg.showContent(bg, page)
			end
		end
	end,
	onEnter = function(value)
		print("guild:onEnter()")
	end,
	onExit = function(value)
		print("guild:onExit()")
	end,
	clickCheck = function(value, value26)
		if not g_data.client:checkLastTime("guild", value26 or 3) then
			main_scene.ui:tip("操作太快, 请重试.", cc.c3b(255, 255, 0))

			return false
		end

		g_data.client:setLastTime("guild", true)

		return true
	end,
	cleanSubNode = function(items11)
		if #items11.needClean > 0 then
			for _, needClean in ipairs(items11.needClean) do
				needClean.removeSelf(needClean)
			end
		end

		items11.acInput = nil
		items11.needClean = {}
		items11.chatViewGuild = nil
	end,
	showContent = function(content, page, ...)
		content.page = page

		if content.content then
			content.content:removeSelf()

			content.subContent = nil
		end

		content.content = display.newNode():addto(content)

		content.content:size(content.getw(content), content.geth(content))

		if page == "tguild" then
			if g_data.guild.guildInfo then
				content.bg:setTex(res.gettex2("pic/common/black_0.png"))
				content.showContentGuild(content, content.content, ...)
			else
				content.bg:setTex(res.gettex2("pic/common/black_2.png"))

				if not g_data.guild.getguildList then
					net.send({
						CM_GILD_LIST,
						param = 0,
						tag = 7
					})
				end

				if not g_data.guild.guildInfo then
					net.send({
						CM_PLAYER_GILD
					})
				end

				g_data.guild.getguildList = false
				content.subpage = nil
			end
		elseif page == "clan" then
			if g_data.guild.clanInfo then
				content.bg:setTex(res.gettex2("pic/common/black_0.png"))
				content.showContentClan(content, content.content, ...)
			else
				content.bg:setTex(res.gettex2("pic/common/black_2.png"))

				if not g_data.guild.getCorpsList then
					net.send({
						CM_CORPS_LIST,
						param = 0,
						tag = 7
					})
				end

				g_data.guild.getCorpsList = false
				content.subpage = nil
			end
		end
	end,
	uirefushContent = function(content, page)
		content.page = page

		if content.content then
			content.content:removeSelf()

			content.subContent = nil
		end

		content.content = display.newNode():addto(content)

		content.content:size(content.getw(content), content.geth(content))

		if page == "tguild" then
			if g_data.guild.guildInfo then
				content.bg:setTex(res.gettex2("pic/common/black_0.png"))
				content.showContentGuild(content, content.content)
			else
				content.bg:setTex(res.gettex2("pic/common/black_2.png"))
				content.showContentGuildNil(content, content.content)

				g_data.guild.getguildList = false
				content.subpage = nil
			end
		elseif page == "clan" then
			if g_data.guild.clanInfo then
				content.bg:setTex(res.gettex2("pic/common/black_0.png"))
				content.showContentClan(content, content.content)
			else
				content.bg:setTex(res.gettex2("pic/common/black_2.png"))
				content.showContentClanNil(content, content.content)

				g_data.guild.getCorpsList = false
				content.subpage = nil
			end
		end
	end,
	showContentClanNil = function(value, value26, ...)
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(value26)
		local items11 = {
			150,
			150,
			150,
			60,
			96
		}
		local items12 = {
			"战队名",
			"队长名",
			"队长行会",
			"人数",
			"状态"
		}
		local x3 = 4

		for index, item in ipairs(items11) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, background.geth(background) - 23):add2(background)
			an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, background.geth(background) - 23):add2(background)

			x3 = x3 + item
		end

		local items13 = g_data.guild.corpsList

		if #items13 == 0 then
			an.newLabel("当前无战队", 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(background.getw(background) / 2, background.geth(background) / 2):add2(background, 2)
		end

		local scroll = an.newScroll(4, 4, 608, 288):add2(background)
		local y = 42

		scroll.setScrollSize(scroll, 608, math.max(288, #items13 * y))
		scroll.enableTouch(scroll, false)
		scroll.enableClick(scroll, function()
			return
		end)

		local value27
		local value28
		local value29
		local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value28 then
				return
			end

			value.curSelectCorps = value28:get("corpsID")

			if g_data.guild.curApplyclan == value.curSelectCorps then
				an.newMsgbox("是否取消对战队 " .. value28:get("corpsName") .. " 的申请吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_CORPS_CANCEL_JOIN
						}, nil, {
							{
								"ID",
								value.curSelectCorps
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			else
				net.send({
					CM_CORPS_GET_RECRUIT_CONDITION
				}, nil, {
					{
						"ID",
						value28:get("corpsID")
					}
				})
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/jrzd.png")
		}):add2(value26):anchor(0.5, 0.5):pos(580, 38)

		for index2, item2 in ipairs(items13) do
			local background2 = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y):add2(scroll)
			local info = {}
			local value30 = g_data.player:fixStrLen(item2.get(item2, "corpsName"), 8)

			info[#info + 1] = an.newLabel(value30, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(75, y * 0.5)

			local value31 = g_data.player:fixStrLen(item2.get(item2, "captainName"), 8)

			info[#info + 1] = an.newLabel(value31, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(225, y * 0.5)

			local value32 = g_data.player:fixStrLen(item2.get(item2, "gildName"), 8)

			info[#info + 1] = an.newLabel(value32, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(375, y * 0.5)

			local value33 = item2.get(item2, "memberCount")

			info[#info + 1] = an.newLabel(value33, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(480, y * 0.5)

			local value34 = g_data.guild.curApplyclan and item2.get(item2, "corpsID") == g_data.guild.curApplyclan and "申请中" or ""

			info[#info + 1] = an.newLabel(value34, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(554, y * 0.5)

			background2.setTouchEnabled(background2, true)
			background2.setTouchSwallowEnabled(background2, false)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value4) <= 5 then
						if value27 then
							for _, info2 in ipairs(value27.info) do
								info2.setColor(info2, def.colors.cellNor)
							end

							value27:removeSelf()

							value27 = nil
						end

						value28 = item2
						value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background2)
						value27.info = info

						for _2, item in ipairs(info) do
							item.setColor(item, def.colors.cellSel)
						end

						if g_data.guild.curApplyclan and item2:get("corpsID") == g_data.guild.curApplyclan then
							btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
						else
							btn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
						end
					end
				end
			end)

			local value35 = cc.EventListenerCustom:create("UpdateNilClanState", function()
				if g_data.guild.curApplyclan and item2:get("corpsID") == g_data.guild.curApplyclan then
					info[5]:setString("申请中")
				else
					info[5]:setString("")
				end

				if item2:get("corpsID") == value28:get("corpsID") then
					if g_data.guild.curApplyclan == item2:get("corpsID") then
						btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
					else
						btn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
					end
				end
			end)

			background2.getEventDispatcher(background2):addEventListenerWithSceneGraphPriority(value35, background2)

			if index2 == 1 then
				value28 = item2
				value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background2)
				value27.info = info

				for _, item3 in ipairs(info) do
					item3.setColor(item3, def.colors.cellSel)
				end

				if g_data.guild.curApplyclan and item2.get(item2, "corpsID") == g_data.guild.curApplyclan then
					btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
				else
					btn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
				end
			end
		end

		local label

		label = an.newInput(0, 0, 196, 40, 7, {
			label = {
				value.filterString or "",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/scale16.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"输入战队关键字      ",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			},
			stop_call = function()
				if label:getString() == "" then
					net.send({
						CM_CORPS_LIST,
						param = 0,
						tag = 7
					})

					value.filterString = nil

					return
				end

				value.filterString = label:getString()

				net.send({
					CM_FIND_CORPS_BYNAME
				}, {
					label:getString()
				})
			end
		}):add2(value26):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local value4 = g_data.guild.page

			if g_data.guild.serach then
				-- block empty
			end

			local param = value4 + 1

			net.send({
				CM_CORPS_LIST,
				tag = 7,
				param = param
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xyy.png")
		}):add2(value26):anchor(0.5, 0.5):pos(480, 38)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local param = g_data.guild.page - 1

			if param < 0 then
				value:showError(30)

				return
			end

			if param < 0 then
				param = 0
			end

			net.send({
				CM_CORPS_LIST,
				tag = 7,
				param = param
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/syy.png")
		}):add2(value26):anchor(0.5, 0.5):pos(380, 38)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if g_data.guild.page == 0 and not g_data.guild.serach then
				value:showError(30)

				return
			end

			net.send({
				CM_CORPS_LIST,
				param = 0,
				tag = 7
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/sy.png")
		}):add2(value26):anchor(0.5, 0.5):pos(280, 38)
	end,
	recruitCondition = function(curSelectCorpsOwner, value, value27, value28)
		print(getRecordSize("TRecruitCondition"), value28)

		if getRecordSize("TRecruitCondition") ~= value28 then
			return
		end

		if not g_data.guild.clanInfo and not curSelectCorpsOwner.curSelectCorps then
			return
		end

		local record = getRecord("TRecruitCondition")

		net.record(record, value27, value28)
		dump(record)

		local value26
		local label
		local label2
		local items11 = {}
		local value29 = record.get(record, "job") or 0
		local items12 = {
			ycFunction:band(ycFunction:rshift(value29, 0), 1) == 1,
			ycFunction:band(ycFunction:rshift(value29, 1), 1) == 1,
			ycFunction:band(ycFunction:rshift(value29, 2), 1) == 1
		}
		local msgbox = an.newMsgbox("", function(value4)
			if value4 == 1 then
				print("申请加入")

				if g_data.guild.clanInfo then
					local number2 = tonumber(label2:getString())

					if not number2 or number2 < 0 then
						main_scene.ui:tip("请输入正确的数字！")

						return
					end

					local count = 0

					for index = 1, 3 do
						if items12[index] then
							count = count + ycFunction:lshift(1, index - 1)

							print(ycFunction:lshift(1, index - 1))
						end
					end

					local record2 = getRecord("TRecruitCondition")

					record2.set(record2, "notice", label:getString())
					record2.set(record2, "level", tonumber(label2:getString()))
					record2.set(record2, "job", count)
					dump(record2)
					net.send({
						CM_CORPS_SET_RECRUIT_CONDITION
					}, nil, record2)
				else
					local value262 = g_data.guild.corpsList
					local text172 = ""
					local value272
					local value282

					for _, item in ipairs(value262) do
						if g_data.guild.curApplyclan and item.get(item, "corpsID") == g_data.guild.curApplyclan then
							value272 = item.get(item, "corpsName")
						end

						if item.get(item, "corpsID") == curSelectCorpsOwner.curSelectCorps then
							value282 = item.get(item, "corpsName")
						end
					end

					if g_data.guild.curApplyclan then
						print("g_data.guild.curApplyclan", g_data.guild.curApplyclan)

						if g_data.guild.curApplyclan == curSelectCorpsOwner.curSelectCorps then
							value272 = value272 or ""
							text172 = "您确定取消对" .. value272 .. " 战队的申请吗？"
						else
							value272 = value272 or ""
							value282 = value282 or ""
							text172 = "您确定加入 " .. value282 .. ",取消对" .. value272 .. " 战队的申请吗？"
						end
					else
						text172 = "您确定申请加入 " .. value282 .. " 战队吗？"
					end

					an.newMsgbox(text172, function(value5)
						local value263 = g_data.player.ability:get("level")

						if curSelectCorpsOwner.curSelectCorps == g_data.guild.curApplyclan and value263 < record:get("level") then
							main_scene.ui:tip("您的等级过低")

							return
						end

						if value5 == 1 then
							net.send({
								curSelectCorpsOwner.curSelectCorps == g_data.guild.curApplyclan and CM_CORPS_CANCEL_JOIN or CM_CORPS_REQUEST_JOIN
							}, nil, {
								{
									"ID",
									curSelectCorpsOwner.curSelectCorps
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end
		end, {
			disableScroll = true,
			center = true,
			hasCancel = true
		})
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(msgbox.bg:getw() - 40, 40)):anchor(0.5, 0.5):pos(msgbox.bg:getw() / 2, msgbox.bg:geth() - 80):add2(msgbox.bg, 2)

		if not g_data.guild.clanInfo then
			an.newLabel(record.get(record, "notice"), 20, 1, {
				color = def.colors.labelGray
			}):addTo(background):anchor(0, 0.5):pos(10, background.geth(background) / 2)
		else
			label = an.newInput(10, background.geth(background) / 2, msgbox.bg:getw() - 40, 40, 18, {
				tip = {
					"点击编辑公告(最多18个字)",
					20,
					1
				},
				label = {
					record.get(record, "notice"),
					20
				}
			}):addTo(background):anchor(0, 0.5)
		end

		local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(40, 40)):anchor(0.5, 0.5):pos(148, 150):add2(msgbox.bg, 2)

		if not g_data.guild.clanInfo then
			an.newLabel("等级限制:            级以上", 20, 1, {
				color = def.colors.labelGray
			}):add2(msgbox.bg, 2):anchor(0, 0.5):pos(30, 150)
			an.newLabel("" .. record.get(record, "level"), 20, 1, {
				color = def.colors.labelGray
			}):add2(background2, 2):anchor(0.5, 0.5):pos(background2.getw(background2) * 0.5, background2.geth(background2) * 0.5)
		else
			an.newLabel("等级限制:           级以上", 20, 1, {
				color = def.colors.labelGray
			}):add2(msgbox.bg, 2):anchor(0, 0.5):pos(30, 150)

			label2 = an.newInput(8, background2.geth(background2) / 2, 40, 40, 2, {
				label = {
					"" .. record.get(record, "level"),
					20
				}
			}):addTo(background2):anchor(0, 0.5)
		end

		an.newLabel("职业限制:", 20, 1, {
			color = def.colors.labelGray
		}):add2(msgbox.bg, 2):anchor(0, 0.5):pos(30, 100)

		local function callback510(self)
			items12[self] = not items12[self]

			items11[self]:setIsSelect(items12[self])
		end

		local items13 = {
			"战士",
			"法师",
			"道士"
		}

		for index = 1, #items13 do
			local btn = an.newBtn(res.gettex2("pic/common/toggle10.png"), function()
				callback510(index)
			end, {
				support = "easy",
				select = {
					res.gettex2("pic/common/toggle11.png"),
					manual = true
				}
			}):anchor(0.5, 0.5):pos(index * 90 + 60, 100):add2(msgbox.bg)

			btn.setIsSelect(btn, items12[index])

			if not g_data.guild.clanInfo then
				btn.setTouchEnabled(btn, false)
			end

			items11[#items11 + 1] = btn

			an.newLabel(items13[index], 20, 1, {
				color = cc.c3b(255, 255, 255)
			}):anchor(0.5, 0.5):pos(index * 90 + 104, 100):add2(msgbox.bg)
		end
	end,
	showContentGuildNil = function(value, value26, ...)
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(value26)
		local items11 = {
			200,
			200,
			124,
			82
		}
		local items12 = {
			"行会名",
			"会长名",
			"战队数",
			"状态"
		}
		local x3 = 4

		for index, item in ipairs(items11) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, background.geth(background) - 23):add2(background)
			an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, background.geth(background) - 23):add2(background)

			x3 = x3 + item
		end

		local items13 = g_data.guild.guildList

		local function callback510(self, value4)
			if value4 == ccui.PageViewEventType.turning then
				local text172 = string.format("page %d", pageView:getCurPageIdx() + 1)

				print(text172)
			end
		end

		if #items13 == 0 then
			an.newLabel("当前无行会", 24, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):pos(background.getw(background) / 2, background.geth(background) / 2):add2(background, 2)
		end

		local scroll = an.newScroll(4, 4, 608, 288):add2(background)
		local y = 42

		scroll.setScrollSize(scroll, 608, math.max(288, #items13 * y))
		scroll.enableTouch(scroll, false)
		scroll.enableClick(scroll, function()
			return
		end)

		local value27
		local value28
		local value29
		local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value28 then
				main_scene.ui:tip("请先选择行会!")

				return
			end

			if not g_data.guild:isLeader() then
				main_scene.ui:tip("非战队队长不能申请加入行会!")

				return
			end

			value.curApplyguild = value28:get("guildID")

			local value4 = g_data.guild.guildList
			local text172 = ""
			local value262
			local value272

			for _, item in ipairs(value4) do
				if g_data.guild.curApplyguild and item.get(item, "guildID") == g_data.guild.curApplyguild then
					value262 = item.get(item, "gildName")
				end

				if item.get(item, "guildID") == value.curApplyguild then
					value272 = item.get(item, "gildName")
				end
			end

			if g_data.guild.curApplyguild then
				print("g_data.guild.curApplyclan", g_data.guild.curApplyguild)

				if g_data.guild.curApplyguild == value.curApplyguild then
					value262 = value262 or ""
					text172 = "您确定取消对行会 " .. value262 .. " 的申请吗？"
				else
					value262 = value262 or ""
					value272 = value272 or ""
					text172 = "您确定加入 " .. value272 .. ",取消对行会 " .. value262 .. " 的申请吗？"
				end
			else
				text172 = "您确定申请加入行会 " .. value272 .. " 吗？"
			end

			an.newMsgbox(text172, function(value5)
				if value5 == 1 then
					if value.curApplyguild == g_data.guild.curApplyguild then
						net.send({
							CM_GILD_CANCEL_JOIN
						})
					else
						net.send({
							CM_GILD_REQUEST_JOIN
						}, nil, {
							{
								"ID",
								value28:get("guildID")
							}
						})
					end
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/jrhh.png")
		}):add2(value26):anchor(0.5, 0.5):pos(580, 38)

		for index2, item2 in ipairs(items13) do
			local info = {}
			local background2 = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y):add2(scroll)
			local value30 = g_data.player:fixStrLen(item2.get(item2, "gildName"), 8)

			info[#info + 1] = an.newLabel(value30, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(100, y * 0.5)

			local value31 = g_data.player:fixStrLen(item2.get(item2, "presidentName"), 8)

			info[#info + 1] = an.newLabel(value31, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(300, y * 0.5)

			local value32 = item2.get(item2, "corpsCount")

			info[#info + 1] = an.newLabel(value32, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(460, y * 0.5)

			local value33 = g_data.guild.curApplyguild and item2.get(item2, "guildID") == g_data.guild.curApplyguild and "申请中" or ""

			info[#info + 1] = an.newLabel(value33, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(556, y * 0.5)

			background2.setTouchEnabled(background2, true)
			background2.setTouchSwallowEnabled(background2, false)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value4) <= 5 then
						if value27 then
							for _, info2 in ipairs(value27.info) do
								info2.setColor(info2, def.colors.cellNor)
							end

							value27:removeSelf()

							value27 = nil
						end

						value28 = item2
						value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background2)
						value27.info = info

						for _2, item in ipairs(info) do
							item.setColor(item, def.colors.cellSel)
						end

						if g_data.guild.curApplyguild and item2:get("guildID") == g_data.guild.curApplyguild then
							btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
						else
							btn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
						end
					end
				end
			end)

			local value34 = cc.EventListenerCustom:create("UpdateNilGuildState", function()
				if g_data.guild.curApplyguild and item2:get("guildID") == g_data.guild.curApplyguild then
					info[4]:setString("申请中")
				else
					info[4]:setString("")
				end

				if item2:get("guildID") == value28:get("guildID") then
					if g_data.guild.curApplyguild == item2:get("guildID") then
						btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
					else
						btn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
					end
				end
			end)

			background2.getEventDispatcher(background2):addEventListenerWithSceneGraphPriority(value34, background2)

			if index2 == 1 then
				value28 = item2
				value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background2)
				value27.info = info

				for _, item3 in ipairs(info) do
					item3.setColor(item3, def.colors.cellSel)
				end

				if g_data.guild.curApplyguild and item2.get(item2, "guildID") == g_data.guild.curApplyguild then
					btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
				else
					btn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
				end
			end
		end

		local label

		label = an.newInput(0, 0, 196, 40, 7, {
			label = {
				value.filterString or "",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/scale16.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"输入行会关键字      ",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			},
			stop_call = function()
				if label:getString() == "" then
					value.filterString = nil

					net.send({
						CM_GILD_LIST,
						param = 0,
						tag = 7
					})

					return
				end

				value.filterString = label:getString()

				net.send({
					CM_FIND_GILD_BYNAME
				}, {
					label:getString()
				})
			end
		}):add2(value26):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local value4 = g_data.guild.page

			if g_data.guild.serach then
				-- block empty
			end

			local param = value4 + 1

			net.send({
				CM_GILD_LIST,
				tag = 7,
				param = param
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xyy.png")
		}):add2(value26):anchor(0.5, 0.5):pos(480, 38)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local param = g_data.guild.page - 1

			if param < 0 and not g_data.guild.serach then
				value:showError(30)

				return
			end

			if param < 0 then
				param = 0
			end

			net.send({
				CM_GILD_LIST,
				tag = 7,
				param = param
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/syy.png")
		}):add2(value26):anchor(0.5, 0.5):pos(380, 38)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if g_data.guild.page == 0 and not g_data.guild.serach then
				value:showError(30)

				return
			end

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/sy.png")
		}):add2(value26):anchor(0.5, 0.5):pos(280, 38)
	end,
	showContentClan = function(value, value26, ...)
		local items11 = {
			"clanmain",
			"clanmem",
			"clanjobs",
			"clanlog"
		}
		local items12 = {}

		local function callback510(subpage)
			sound.playSound("103")

			for _, item in ipairs(items12) do
				if item == subpage then
					item.select(item)
				else
					item.unselect(item)
				end

				if subpage.page ~= value.subpage then
					value.subpage = subpage.page

					value:showSub(subpage.page, value26, true)
				end
			end
		end

		for index, page in ipairs(items11) do
			items12[index] = an.newBtn(res.gettex2("pic/common/btn60.png"), callback510, {
				support = "easy",
				sprite = res.gettex2("pic/panels/guild/" .. page .. "_n.png"),
				anchor = {
					0.5,
					0.5
				},
				select = {
					res.gettex2("pic/common/btn61.png"),
					manual = true
				}
			}):add2(value26):anchor(0, 0.5):pos(18, (index - 1) * 54 - 370)
			items12[index].page = page
		end

		items12[1]:select()

		value.subpage = items11[1]

		value.showSub(value, items11[1], value26, true)
	end,
	showContentGuild = function(value, value26, ...)
		local items11 = {
			"guildmain",
			"mem",
			"claninfo",
			"clanrecruit",
			"diplomatic",
			"log"
		}
		local items12 = {}

		local function cleanup(subpage)
			sound.playSound("103")

			for _, item in ipairs(items12) do
				if item == subpage then
					item.select(item)
				else
					item.unselect(item)
				end

				if subpage.page ~= value.subpage then
					value.subpage = subpage.page

					value:showSub(subpage.page, value26, true)
				end
			end
		end

		for index, page in ipairs(items11) do
			items12[index] = an.newBtn(res.gettex2("pic/common/btn60.png"), cleanup, {
				support = "easy",
				sprite = res.gettex2("pic/panels/guild/" .. page .. "_n.png"),
				anchor = {
					0.5,
					0.5
				},
				select = {
					res.gettex2("pic/common/btn61.png"),
					manual = true
				}
			}):add2(value26):anchor(0, 0.5):pos(18, (index - 1) * 54 - 370)
			items12[index].page = page
		end

		value.subpage = items11[1]

		items12[1]:select()
		value.showSub(value, items11[1], value26, true)
	end,
	showSub = function(value, value26, value27, value28)
		value27 = value27 or value.content
		value.threeSub = 0

		if value.subContent then
			value.subContent:removeSelf()
		end

		value.pageNode = nil

		value.bg:setTex(res.gettex2("pic/common/black_0.png"))

		value.subContent = cc.Node:create()

		value.subContent:size(486, 344):anchor(0, 0):pos(138, 60):add2(value27)

		if value26 == "clanmain" then
			if value28 then
				net.send({
					CM_CORPS_NOTICE,
					tag = 0
				})
				net.send({
					CM_REFRESH_CORPSINFO
				})
			end

			value.showSubClanmain(value, value.subContent)
		elseif value26 == "clanmem" then
			if value28 then
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end

			value.showSubClanmem(value, value.subContent)
		elseif value26 == "clanjobs" then
			if value28 then
				net.send({
					CM_CORPS_QUERY_REQUESTS,
					tag = 30,
					series = 0
				})
			end

			value.showSubClanjobs(value, value.subContent)
		elseif value26 == "clanlog" then
			if value28 then
				net.send({
					CM_CORPS_QUERY_LOG,
					tag = 0,
					series = 30,
					param = 1
				})
			end

			value.showSubClanlog(value, value.subContent)
		elseif value26 == "guildmain" then
			if value28 then
				net.send({
					CM_GILD_NOTICE,
					tag = 0
				})
				net.send({
					CM_REFRESH_GILDINFO
				})
			end

			value.showSubGuildmain(value, value.subContent)
		elseif value26 == "mem" then
			if value28 then
				net.send({
					CM_GILDMEMBER_LIST
				})
			end

			value.showSubMem(value, value.subContent)
		elseif value26 == "claninfo" then
			if value28 then
				net.send({
					CM_GILD_QUERY_CORPS
				})
			end

			value.showSubClaninfo(value, value.subContent)
		elseif value26 == "clanrecruit" then
			if value28 then
				net.send({
					CM_GILD_QUERY_REQUEST_JOIN_LIST,
					tag = 30,
					series = 0
				})
			end

			value.showSubClanrecruit(value, value.subContent)
		elseif value26 == "diplomatic" then
			value.showSubDiplomatic(value, value.subContent)
		elseif value26 == "log" then
			if value28 then
				net.send({
					CM_GILD_QUERY_LOG,
					tag = 0,
					series = 30,
					param = 1
				})
			end

			value.showSubLog(value, value.subContent)
		end
	end,
	refush = function(value, value26)
		if value.subpage ~= value26 then
			return
		end

		value.showSub(value, value26)
	end,
	showSubClanmain = function(value, x3)
		x3.size(x3, 486, 236)
		display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):addto(x3):anchor(0, 0):pos(2, 238):size(x3.getw(x3), 106)
		res.get2("pic/panels/guild/signboard_bg.png"):anchor(0, 0):pos(4, 242):addto(x3)
		an.newLabel(g_data.guild.clanInfo and (g_data.guild.clanInfo:get("corpsName") or "") or "", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, 302):add2(x3)
		an.newLabel("队员:", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(1, 0.5):pos(x3.getw(x3) * 0.5, 264):add2(x3)
		an.newLabel(g_data.guild.clanInfo and g_data.guild.clanInfo:get("onlineCount") .. "/" .. g_data.guild.clanInfo:get("memberCount") or "1/30", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0, 0.5):pos(x3.getw(x3) * 0.5 + 4, 264):add2(x3)

		local value26
		local items11 = {
			g_data.guild.clanNotice
		}
		local label = an.newLabel("", 18, 0)

		items11[#items11 + 1] = "\r\n"

		function refush(self)
			if value26 then
				value26:removeSelf()

				value26 = nil
			end

			value26 = an.newScroll(8, 8, 470, 220):add2(x3)

			if items11[#items11] ~= "\r\n" then
				items11[#items11 + 1] = "\r\n"
			end

			local items112 = {}
			local count = 0
			local label2
			local value4

			for index, item in ipairs(items11) do
				local size = cc.LabelTTF:create(item, "", 18, cc.size(470, 0), 0)

				size.anchor(size, 0, 1)

				items112[#items112 + 1] = size
				count = count + size.getContentSize(size).height

				if self then
					size.setTouchEnabled(size, true)
					size.setTouchSwallowEnabled(size, false)
					size.addNodeEventListener(size, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
						if offsetBeginY.name == "began" then
							size.offsetBeginY = offsetBeginY.y

							return true
						elseif offsetBeginY.name == "ended" then
							local value5 = offsetBeginY.y - size.offsetBeginY

							if math.abs(value5) <= 5 then
								if label2 then
									items11[value4] = label2:getText()

									items112[value4]:setString(label2:getText())
									label2:removeSelf()

									label2 = nil
									value4 = nil

									refush(true)

									return
								end

								value4 = index
								label2 = an.newInput(size:getPositionX(), size:getPositionY(), 470, 24, 500, {
									label = {
										string.gsub(item, "\r\n", ""),
										18,
										1
									},
									bg = {
										h = 24,
										tex = res.gettex2("pic/scale/edit1.png"),
										offset = {
											-3,
											4
										}
									},
									stop_call = function()
										local text172 = label2:getText()

										if text172 == "" then
											text172 = "\r\n"
										end

										items11[index] = text172

										size:setString(text172)
										label2:removeSelf()

										label2 = nil
										value4 = nil

										refush(true)
									end
								}):add2(value26):anchor(0, 1)
							end
						end
					end)
				end
			end

			value26:setScrollSize(470, math.max(220, count))

			local count2 = 0

			for _, item2 in ipairs(items112) do
				item2.pos(item2, 0, value26:getScrollSize().height - count2):add2(value26)

				count2 = count2 + item2.getContentSize(item2).height
			end
		end

		refush()
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if g_data.guild:isPresident() then
				main_scene.ui:tip("行会会长不能退出战队")

				return
			end

			if g_data.guild:isVicePresident() or g_data.guild:isLeader() then
				main_scene.ui:tip("需转让队长之后才能退出战队")

				return
			end

			an.newMsgbox("您确定退出战队吗？", function(value4)
				if value4 == 1 then
					net.send({
						CM_CORPS_EXIT
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/tczd.png")
		}):add2(x3):anchor(0.5, 0.5):pos(442, -22)

		if g_data.guild:isLeader() then
			local btn
			local btn2

			btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				refush(true)
				btn:hide()
				btn2:show()
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/bjgg.png")
			}):add2(x3):anchor(0.5, 0.5):pos(342, -22)
			btn2 = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				refush(false)
				btn2:hide()
				btn:show()

				local text172 = ""

				for _, text18 in ipairs(items11) do
					text18 = string.gsub(text18, "\r\n", "")
					text172 = text172 .. text18 .. "\r\n"
				end

				print(text172)
				net.send({
					CM_CORPS_NOTICE,
					tag = 1
				}, {
					text172
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/bcgg.png")
			}):add2(x3):anchor(0.5, 0.5):pos(342, -22)

			btn2.hide(btn2)
		end
	end,
	showSubClanmem = function(value, y)
		local items11 = {
			140,
			60,
			60,
			60,
			60,
			100
		}
		local items12 = {
			"角色名",
			"等级",
			"职业",
			"性别",
			"职务",
			"封号"
		}
		local x3 = 6
		local value26 = g_data.guild.corpsMem or {}
		local value27
		local value28
		local items13 = {
			"",
			"副队长",
			"队长",
			"副会长",
			"会长"
		}
		local scroll
		local y2 = 42

		local function cleanup(self)
			if scroll then
				scroll:removeSelf()
			end

			scroll = an.newScroll(7, 8, 480, 292):add2(y)

			scroll:setScrollSize(480, math.max(292, #self * y2))

			for index, item in ipairs(self) do
				local info = {}
				local color = item.get(item, "status") == 1 and cc.c3b(255, 255, 255) or def.colors.cellOffline
				local cell = display.newNode():size(480, y2):anchor(0, 0):pos(0, scroll:getScrollSize().height - index * y2):add2(scroll)

				cell.scale = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):add2(cell)

				local value4 = g_data.player:fixStrLen(item.get(item, "name"), 8)

				info[#info + 1] = an.newLabel(value4, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(70, y2 * 0.5)

				local value262 = item.get(item, "level")

				info[#info + 1] = an.newLabel(value262, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(170, y2 * 0.5)

				local otherJobStr = g_data.player:getOtherJobStr(item.get(item, "job"))

				info[#info + 1] = an.newLabel(otherJobStr, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(230, y2 * 0.5)

				local value272 = item.get(item, "six") == 0 and "男" or "女"

				info[#info + 1] = an.newLabel(value272, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(290, y2 * 0.5)

				local value282 = items13[item.get(item, "position") + 1] or ""

				info[#info + 1] = an.newLabel(value282, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(350, y2 * 0.5)

				local value29 = item.get(item, "title")

				info[#info + 1] = an.newLabel(value29, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(425, y2 * 0.5)

				cell.setTouchEnabled(cell, true)
				cell.setTouchSwallowEnabled(cell, false)
				cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
					if offsetBeginY.name == "began" then
						cell.offsetBeginY = offsetBeginY.y

						return true
					elseif offsetBeginY.name == "ended" then
						local value5 = offsetBeginY.y - cell.offsetBeginY

						if math.abs(value5) <= 5 then
							if value27 then
								for _, info2 in ipairs(value27.info) do
									info2.setColor(info2, value27.color or def.colors.cellOffline)
								end

								value27:removeSelf()

								value27 = nil
							end

							value28 = item
							value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, 0):add2(cell)
							value27.info = info
							value27.color = color

							for _2, item2 in ipairs(info) do
								item2.setColor(item2, def.colors.cellSel)
							end
						end
					end
				end)

				if index == 1 then
					value28 = item
					value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, 0):add2(cell)
					value27.info = info
					value27.color = color

					for _, item2 in ipairs(info) do
						item2.setColor(item2, def.colors.cellSel)
					end
				end

				item.info = info
				item.cell = cell
			end
		end

		local items14 = {
			function(value4, value262)
				return value:sortName(value4, value262)
			end,
			function(value4, value262)
				return value:sortLevel(value4, value262)
			end,
			function(value4, value262)
				return value:sortJob(value4, value262)
			end,
			function(value4, value262)
				return value:sortSex(value4, value262)
			end,
			function(value4, value262)
				return value:sortTitle(value4, value262)
			end,
			function(value4, value262)
				return value:sortString(value4, value262)
			end
		}
		local count = 1
		local count2 = 0

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)

			items12[index] = an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)
			x3 = x3 + item

			background.enableClick(background, function()
				if count == index then
					count2 = count2 + 1
					value26 = items14[index](value26, count2 % 2 == 0)
				else
					count2 = 0
					value26 = items14[index](value26, true)
				end

				value26 = value:sortOnline(value26)

				cleanup(value26)

				count = index
			end)
		end

		value26 = value.sortName(value, value26, true)
		value26 = value.sortOnline(value, value26)

		cleanup(value26)

		local x4 = 0

		if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value28 then
					return
				end

				if value28:get("name") == value2.getPlayerName() then
					main_scene.ui:tip("不能操作自己")

					return
				end

				an.newMsgbox("您确定将 " .. value28:get("name") .. " 逐出战队吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_CORPS_DISMISS_MEMBER
						}, nil, {
							{
								"ID",
								value28:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zczd.png")
			}):add2(y):anchor(0.5, 0.5):pos(442, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value28 then
					return
				end

				local msgbox

				msgbox = an.newMsgbox("", function(value4)
					if value4 == 1 then
						if msgbox.nameInput:getString() == "" then
							return
						end

						net.send({
							CM_CORPS_SET_MEMBER_TITLE
						}, nil, {
							{
								"ID",
								value28:get("ID")
							},
							{
								"string",
								def.wordfilter.run(msgbox.nameInput:getString()),
								15
							}
						})
					end
				end, {
					disableScroll = true,
					hasCancel = true
				})
				msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 4, {
					label = {
						"",
						20,
						1
					},
					bg = {
						tex = res.gettex2("pic/scale/scale16.png"),
						offset = {
							-10,
							2
						}
					},
					tip = {
						"请输入封号？",
						20,
						1,
						{
							color = cc.c3b(128, 128, 128)
						}
					}
				}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/szfh.png")
			}):add2(y):anchor(0.5, 0.5):pos(342, -22)

			x4 = 2
		end

		local x5 = x4

		if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				value:showMenu(cc.p(x5 * 100 - 442 + 82, 58), "职务操作", value28)
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zwcz.png")
			}):add2(y):anchor(0.5, 0.5):pos(x4 * 100 - 442, -22)

			x4 = x4 + 1
		end

		local x6 = x4

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value28 then
				return
			end

			value:showMenu(cc.p(x6 * 100 - 442 + 82, 58), "更多操作", value28)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/gdcz.png")
		}):add2(y):anchor(0.5, 0.5):pos(x4 * 100 - 442, -22)
	end,
	showSubClanjobs = function(value, y)
		local items11 = {
			170,
			90,
			90,
			131
		}
		local items12 = {
			"角色名",
			"等级",
			"职业",
			"性别"
		}
		local x3 = 5

		for index, item in ipairs(items11) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)

			items12[index] = an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)
			x3 = x3 + item
		end

		local items13 = g_data.guild.corpsQueryMem or {}
		local scroll = an.newScroll(7, 8, 480, 292):add2(y)
		local y2 = 42

		scroll.setScrollSize(scroll, 472, math.max(288, #items13 * y2))

		local value26 = g_data.guild.clanInfo:get("memberCount") - 30
		local value27
		local value28
		local enabled2 = false

		for index2, item2 in ipairs(items13) do
			local info = {}
			local cell = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y2):add2(scroll)
			local value29 = g_data.player:fixStrLen(item2.get(item2, "name"), 8)

			info[#info + 1] = an.newLabel(value29, 18, 1, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(85, y2 * 0.5)

			local value30 = item2.get(item2, "level")

			info[#info + 1] = an.newLabel(value30, 18, 1, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(215, y2 * 0.5)

			local otherJobStr = g_data.player:getOtherJobStr(item2.get(item2, "job"))

			info[#info + 1] = an.newLabel(otherJobStr, 18, 1, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(305, y2 * 0.5)

			local value31 = item2.get(item2, "six") == 0 and "男" or "女"

			info[#info + 1] = an.newLabel(value31, 18, 1, {
				color = def.colors.cellNor
			}):add2(cell):anchor(0.5, 0.5):pos(410, y2 * 0.5)

			cell.setTouchEnabled(cell, true)
			cell.setTouchSwallowEnabled(cell, false)
			cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					cell.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - cell.offsetBeginY

					if math.abs(value4) <= 5 then
						if enabled2 then
							if item2.selectPic then
								for _, info2 in ipairs(item2.info) do
									info2.setColor(info2, def.colors.cellNor)
								end

								item2.selectPic:removeSelf()

								item2.selectPic = nil
							else
								item2.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, 0):add2(item2.cell)

								for _2, info2 in ipairs(item2.info) do
									info2.setColor(info2, def.colors.cellSel)
								end
							end
						else
							if value27 then
								for _3, info3 in ipairs(value27.info) do
									info3.setColor(info3, def.colors.cellNor)
								end

								value27:removeSelf()

								value27 = nil
							end

							value28 = item2
							value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, 0):add2(cell)
							value27.info = info

							for _4, item in ipairs(info) do
								item.setColor(item, def.colors.cellSel)
							end
						end
					end
				end
			end)

			if index2 == 1 then
				value28 = item2
				value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, 0):add2(cell)
				value27.info = info

				for _, item3 in ipairs(info) do
					item3.setColor(item3, def.colors.cellSel)
				end
			end

			item2.cell = cell
			item2.info = info
		end

		if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
			local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(value4)
				enabled2 = value4

				if enabled2 then
					if value27 then
						for _, info in ipairs(value27.info) do
							info.setColor(info, def.colors.cellNor)
						end

						value27:removeSelf()

						value27 = nil
						value28 = nil
					end

					value26 = g_data.guild.clanInfo:get("memberCount") - 30

					for _2, item in ipairs(items13) do
						item.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, 0):add2(item.cell)

						for _3, info2 in ipairs(item.info) do
							info2.setColor(info2, def.colors.cellSel)
						end

						value26 = value26 - 1

						if value26 <= 0 then
							break
						end
					end
				else
					for _4, item2 in ipairs(items13) do
						if item2.selectPic then
							for _5, info3 in ipairs(item2.info) do
								info3.setColor(info3, def.colors.cellNor)
							end

							item2.selectPic:removeSelf()

							item2.selectPic = nil
						end
					end
				end
			end, {
				easy = true,
				label = {
					"全部选中",
					20,
					1,
					{
						color = def.colors.labelGray
					}
				}
			}):anchor(0, 0.5):pos(-110, -28):add2(y, 2)

			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if enabled2 then
					an.newMsgbox("您确定拒绝所有进入战队的申请吗？", function(value4)
						if value4 == 1 then
							local items112 = {}

							for _, item in ipairs(items13) do
								if item.selectPic then
									items112[#items112 + 1] = {
										"ID",
										item.get(item, "ID")
									}
								end
							end

							net.send({
								CM_CORPS_REFUSE_REQUEST,
								param = #items112
							}, nil, items112)
						end
					end, {
						center = true,
						hasCancel = true
					})
				else
					if not value28 then
						return
					end

					an.newMsgbox("您确定拒绝 " .. value28:get("name") .. "进入战队吗？", function(value4)
						if value4 == 1 then
							net.send({
								CM_CORPS_REFUSE_REQUEST,
								param = 1
							}, nil, {
								{
									"ID",
									value28:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/jjzs.png")
			}):add2(y):anchor(0.5, 0.5):pos(442, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if enabled2 then
					an.newMsgbox("您确定允许所有进入战队的申请吗？", function(value4)
						if value4 == 1 then
							local items112 = {}

							for _, item in ipairs(items13) do
								if item.selectPic then
									items112[#items112 + 1] = {
										"ID",
										item.get(item, "ID")
									}
								end
							end

							net.send({
								CM_CORPS_ACCEPT_REQUEST,
								param = #items112
							}, nil, items112)
						end
					end, {
						center = true,
						hasCancel = true
					})
				else
					if not value28 then
						return
					end

					an.newMsgbox("您确定允许 " .. value28:get("name") .. "进入战队吗？", function(value4)
						if value4 == 1 then
							net.send({
								CM_CORPS_ACCEPT_REQUEST,
								param = 1
							}, nil, {
								{
									"ID",
									value28:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/tyzs.png")
			}):add2(y):anchor(0.5, 0.5):pos(342, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				net.send({
					CM_CORPS_DIRECT_ADD_MEMBER
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/mdmz.png")
			}):add2(y):anchor(0.5, 0.5):pos(242, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				net.send({
					CM_CORPS_GET_RECRUIT_CONDITION
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zxsz.png")
			}):add2(y):anchor(0.5, 0.5):pos(142, -22)
		end
	end,
	showSubClanlog = function(clanLogTypeOwner, value)
		local maxLine = 60
		local scroll = an.newScroll(8, 8, 472, 328, {
			labelM = {
				16,
				params = {
					maxLine = maxLine
				}
			}
		}):add2(value)
		local value26 = g_data.guild.corpsLog or {}

		if value26 then
			for _, item in ipairs(value26) do
				scroll.labelM:addLabel(item.get(item, "logInfo"), def.colors.labelGray):nextLine()
			end
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			clanLogTypeOwner.clanLogType = 1

			net.send({
				CM_CORPS_QUERY_LOG,
				tag = 0,
				series = 30,
				param = 2
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zzrz.png")
		}):add2(value):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			clanLogTypeOwner.clanLogType = 0

			net.send({
				CM_CORPS_QUERY_LOG,
				tag = 0,
				series = 30,
				param = 1
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/cyrz.png")
		}):add2(value):anchor(0.5, 0.5):pos(342, -22)
	end,
	showSubGuildmain = function(value, x3)
		x3.size(x3, 486, 236)
		display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):addto(x3):anchor(0, 0):pos(2, 238):size(x3.getw(x3), 106)
		res.get2("pic/panels/guild/signboard_bg.png"):anchor(0, 0):pos(4, 242):addto(x3)
		an.newLabel(g_data.guild.guildInfo and (g_data.guild.guildInfo:get("gildName") or "") or "", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, 302):add2(x3)
		an.newLabel("战队数:", 20, 1, {
			color = def.colors.labelGray
		}):anchor(1, 0.5):pos(x3.getw(x3) * 0.45, 264):add2(x3)
		an.newLabel(g_data.guild.guildInfo and g_data.guild.guildInfo:get("corpsCount") .. "/8" or "1/8", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(x3.getw(x3) * 0.45 + 4, 264):add2(x3)
		an.newLabel("会员数:" .. g_data.guild.guildInfo:get("onlineCount") .. "/" .. g_data.guild.guildInfo:get("playerCount"), 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(x3.getw(x3) * 0.55, 264):add2(x3)

		local value26
		local items11 = {
			g_data.guild.guildNotice
		}

		for index = 1, 5 do
			-- block empty
		end

		items11[#items11 + 1] = "\r\n"

		function refush(self)
			if value26 then
				value26:removeSelf()

				value26 = nil
			end

			value26 = an.newScroll(8, 8, 470, 220):add2(x3)

			if items11[#items11] ~= "\r\n" then
				items11[#items11 + 1] = "\r\n"
			end

			local items112 = {}
			local count = 0
			local label
			local value4

			for index, item in ipairs(items11) do
				local size = cc.LabelTTF:create(item, "", 18, cc.size(470, 0), 0)

				size.anchor(size, 0, 1)

				items112[#items112 + 1] = size
				count = count + size.getContentSize(size).height

				if self then
					size.setTouchEnabled(size, true)
					size.setTouchSwallowEnabled(size, false)
					size.addNodeEventListener(size, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
						if offsetBeginY.name == "began" then
							size.offsetBeginY = offsetBeginY.y

							return true
						elseif offsetBeginY.name == "ended" then
							local value5 = offsetBeginY.y - size.offsetBeginY

							if math.abs(value5) <= 5 then
								if label then
									items11[value4] = label:getText()

									items112[value4]:setString(label:getText())
									label:removeSelf()

									label = nil
									value4 = nil

									refush(true)

									return
								end

								value4 = index
								label = an.newInput(size:getPositionX(), size:getPositionY(), 470, 24, 500, {
									label = {
										string.gsub(item, "\r\n", ""),
										18,
										1
									},
									bg = {
										h = 24,
										tex = res.gettex2("pic/scale/edit1.png"),
										offset = {
											-3,
											4
										}
									},
									stop_call = function()
										local text172 = label:getText()

										if text172 == "" then
											text172 = "\r\n"
										end

										items11[index] = text172

										size:setString(text172)
										label:removeSelf()

										label = nil
										value4 = nil

										refush(true)
									end
								}):add2(value26):anchor(0, 1)
							end
						end
					end)
				end
			end

			value26:setScrollSize(470, math.max(220, count))

			local count2 = 0

			for _, item2 in ipairs(items112) do
				item2.pos(item2, 0, value26:getScrollSize().height - count2):add2(value26)

				count2 = count2 + item2.getContentSize(item2).height
			end
		end

		refush()

		if g_data.guild:isPresident() then
			local btn
			local btn2

			btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				refush(true)
				btn:hide()
				btn2:show()
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/bjgg.png")
			}):add2(x3):anchor(0.5, 0.5):pos(442, -22)
			btn2 = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				refush(false)
				btn2:hide()
				btn:show()

				local text172 = ""

				for _, text18 in ipairs(items11) do
					text18 = string.gsub(text18, "\r\n", "")
					text172 = text172 .. text18 .. "\r\n"
				end

				print(text172)
				net.send({
					CM_GILD_NOTICE,
					tag = 1
				}, {
					text172
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/bcgg.png")
			}):add2(x3):anchor(0.5, 0.5):pos(442, -22)

			btn2.hide(btn2)

			return
		end

		if g_data.guild:isVicePresident() or g_data.guild:isLeader() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if g_data.guild:isPresident() then
					main_scene.ui:tip("你是行会会长，不可退出")

					return
				end

				an.newMsgbox("您确定要退出行会吗？\n队长退出行会将带领战队中所有成员退出行会", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_EXIT
						})
					end
				end, {
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/tchh.png")
			}):add2(x3):anchor(0.5, 0.5):pos(442, -22)
		end
	end,
	sortOnline = function(value, value26)
		local items11 = {}

		function insertTable(self)
			for index, item in ipairs(items11) do
				if item.get(item, "status") < self.get(self, "status") then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					items11[#items11 + 1] = self

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortOnlineTwo = function(value, value26)
		local items11 = {}

		function insertTable(self)
			for index, item in ipairs(items11) do
				if self.get(self, "status") <= item.get(item, "status") then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					table.insert(items11, 1, self)

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortString = function(value, value26, value28)
		local items11 = {}
		local value27
		local value29

		function insertTable(self)
			for index, item in ipairs(items11) do
				value27 = string.len(self.get(self, "title"))
				value29 = string.len(item.get(item, "title"))

				if value28 and value29 <= value27 or value27 < value29 then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					items11[#items11 + 1] = self

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortName = function(value, value26, value28)
		local items11 = {}
		local value27
		local value29

		function insertTable(self)
			for index, item in ipairs(items11) do
				value27 = string.len(self.get(self, "name"))
				value29 = string.len(item.get(item, "name"))

				if value28 and value29 <= value27 or value27 < value29 then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					items11[#items11 + 1] = self

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortLevel = function(value, value26, value28)
		local items11 = {}
		local value27
		local value29

		function insertTable(self)
			for index, item in ipairs(items11) do
				value27 = self.get(self, "level")
				value29 = item.get(item, "level")

				if value28 then
					if value29 <= value27 then
						table.insert(items11, index, self)

						return
					elseif index == #items11 then
						items11[#items11 + 1] = self

						return
					end
				elseif value27 < value29 then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					table.insert(items11, 1, self)

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortJob = function(value, value26, value28)
		local items11 = {}
		local value27
		local value29

		function insertTable(self)
			for index, item in ipairs(items11) do
				value27 = self.get(self, "job")
				value29 = item.get(item, "job")

				if value28 then
					if value27 <= value29 then
						table.insert(items11, index, self)

						return
					elseif index == #items11 then
						items11[#items11 + 1] = self

						return
					end
				elseif value29 <= value27 then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					table.insert(items11, 1, self)

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortSex = function(value, value26, value28)
		local items11 = {}
		local value27
		local value29

		function insertTable(self)
			for index, item in ipairs(items11) do
				value27 = self.get(self, "six")
				value29 = item.get(item, "six")

				if value28 then
					if value27 <= value29 then
						table.insert(items11, index, self)

						return
					elseif index == #items11 then
						items11[#items11 + 1] = self

						return
					end
				elseif value29 <= value27 then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					table.insert(items11, 1, self)

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	sortTitle = function(value, value26, value28)
		local items11 = {}
		local value27
		local value29

		function insertTable(self)
			for index, item in ipairs(items11) do
				value27 = self.get(self, "position")
				value29 = item.get(item, "position")

				if value28 then
					if value29 <= value27 then
						table.insert(items11, index, self)

						return
					elseif index == #items11 then
						items11[#items11 + 1] = self

						return
					end
				elseif value27 < value29 then
					table.insert(items11, index, self)

					return
				elseif index == #items11 then
					table.insert(items11, 1, self)

					return
				end
			end
		end

		for index, item in ipairs(value26) do
			if index == 1 then
				items11[1] = item
			else
				insertTable(item)
			end
		end

		return items11
	end,
	showSubMem = function(value, y)
		local items11 = {
			150,
			80,
			80,
			80,
			90
		}
		local y2 = 42
		local items12 = {
			"角色名",
			"等级",
			"职业",
			"性别",
			"职务"
		}
		local value26 = g_data.guild.guildMems or {}
		local value27
		local value28
		local scroll

		local function cleanup(self)
			if scroll then
				scroll:removeSelf()
			end

			scroll = an.newScroll(7, 8, 480, 292):add2(y)

			scroll:setScrollSize(480, math.max(292, #self * y2))

			local items112 = {
				"",
				"副队长",
				"队长",
				"副会长",
				"会长"
			}

			for index, item in ipairs(self) do
				local info = {}
				local cell = display.newNode():size(480, y2):anchor(0, 0):pos(0, scroll:getScrollSize().height - index * y2):add2(scroll)

				cell.scale = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):add2(cell)

				local color = item.get(item, "status") == 1 and cc.c3b(255, 255, 255) or def.colors.cellOffline
				local value4 = g_data.player:fixStrLen(item.get(item, "name"), 8)

				info[#info + 1] = an.newLabel(value4, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(75, y2 * 0.5)

				local value262 = item.get(item, "level")

				info[#info + 1] = an.newLabel(value262, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(190, y2 * 0.5)

				local otherJobStr = g_data.player:getOtherJobStr(item.get(item, "job"))

				info[#info + 1] = an.newLabel(otherJobStr, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(270, y2 * 0.5)

				local value272 = item.get(item, "six") == 0 and "男" or "女"

				info[#info + 1] = an.newLabel(value272, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(350, y2 * 0.5)

				local value282 = items112[item.get(item, "position") + 1] or ""

				info[#info + 1] = an.newLabel(value282, 18, 1, {
					color = color
				}):add2(cell, 1):anchor(0.5, 0.5):pos(430, y2 * 0.5)

				cell.setTouchEnabled(cell, true)
				cell.setTouchSwallowEnabled(cell, false)
				cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
					if offsetBeginY.name == "began" then
						cell.offsetBeginY = offsetBeginY.y

						return true
					elseif offsetBeginY.name == "ended" then
						local value5 = offsetBeginY.y - cell.offsetBeginY

						if math.abs(value5) <= 5 then
							if value27 then
								for _, info2 in ipairs(value27.info) do
									info2.setColor(info2, value27.color or def.colors.cellNor)
								end

								value27:removeSelf()

								value27 = nil
							end

							value28 = item
							value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y2)):anchor(0, 0):pos(0, 0):add2(cell)
							value27.info = info
							value27.color = color

							for _2, item2 in ipairs(info) do
								item2.setColor(item2, def.colors.cellSel)
							end
						end
					end
				end)

				if index == 1 then
					value28 = item
					value27 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y2)):anchor(0, 0):pos(0, 0):add2(cell)
					value27.info = info
					value27.color = color

					for _, item2 in ipairs(info) do
						item2.setColor(item2, def.colors.cellSel)
					end
				end

				item.info = info
				item.cell = cell
			end
		end

		local items13 = {
			function(value4, value262)
				return value:sortName(value4, value262)
			end,
			function(value4, value262)
				return value:sortLevel(value4, value262)
			end,
			function(value4, value262)
				return value:sortJob(value4, value262)
			end,
			function(value4, value262)
				return value:sortSex(value4, value262)
			end,
			function(value4, value262)
				return value:sortTitle(value4, value262)
			end
		}
		local x3 = 5
		local count = 1
		local count2 = 0

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)

			items12[index] = an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)
			x3 = x3 + item

			background.enableClick(background, function()
				if count == index then
					count2 = count2 + 1
					value26 = items13[index](value26, count2 % 2 == 0)
				else
					count2 = 0
					value26 = items13[index](value26, true)
				end

				value26 = value:sortOnline(value26)

				cleanup(value26)

				count = index
			end)
		end

		value26 = value.sortName(value, value26, true)
		value26 = value.sortOnline(value, value26)

		cleanup(value26)

		local x4 = 0

		if g_data.guild:isPresident() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value28 then
					return
				end

				if value28:get("position") ~= 2 then
					main_scene.ui:tip("非队长不能任命为副会长")

					return
				end

				an.newMsgbox("您确定设 " .. value28:get("name") .. " 为副会长吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_APPOINT_VICE_PRESIDENT
						}, nil, {
							{
								"ID",
								value28:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/sfhz.png")
			}):add2(y):anchor(0.5, 0.5):pos(442, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value28 then
					return
				end

				if value28:get("position") ~= 2 and value28:get("position") ~= 3 then
					main_scene.ui:tip("只能任命战队队长或行会副会长为会长")

					return
				end

				an.newMsgbox("您确定转让会长吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_TRANSFER_PRESIDENT
						}, nil, {
							{
								"ID",
								value28:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zrhz.png")
			}):add2(y):anchor(0.5, 0.5):pos(342, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value28 then
					return
				end

				if value28:get("position") ~= 3 then
					main_scene.ui:tip("非副会长不能卸任")

					return
				end

				an.newMsgbox("您确定卸任 " .. value28:get("name") .. " 副会长职务吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_DISMISS_VICECAPTAIN
						}, nil, {
							{
								"ID",
								value28:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/xr.png")
			}):add2(y):anchor(0.5, 0.5):pos(242, -22)

			x4 = 3
		else
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")
				an.newMsgbox("您确定卸任吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_VICECAPTAIN_STEPDOWN
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/xr.png")
			}):add2(y):anchor(0.5, 0.5):pos(x4 * 100 - 442, -22)

			x4 = x4 + 1
		end

		local x5 = x4

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value28 then
				return
			end

			value:showMenu(cc.p(x5 * 100 - 442 + 82, 58), "更多操作", value28)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/gdcz.png")
		}):add2(y):anchor(0.5, 0.5):pos(x4 * 100 - 442, -22)
	end,
	showSubClaninfo = function(value, y)
		local items11 = {
			160,
			160,
			160
		}
		local items12 = {
			"战队名",
			"队长名",
			"人数"
		}
		local x3 = 5

		for index, item in ipairs(items11) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)

			items12[index] = an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)
			x3 = x3 + item
		end

		local items13 = g_data.guild.guildcorpsList or {}
		local scroll = an.newScroll(7, 8, 480, 292):add2(y)
		local y2 = 42

		scroll.setScrollSize(scroll, 596, math.max(286, #items13 * y2))

		local value26
		local value27

		for index2, item2 in ipairs(items13) do
			local info = {}
			local background = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y2):add2(scroll)
			local value28 = g_data.player:fixStrLen(item2.get(item2, "corpsName"), 8)

			info[#info + 1] = an.newLabel(value28, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(80, y2 * 0.5)

			local value29 = g_data.player:fixStrLen(item2.get(item2, "captainName"), 8)

			info[#info + 1] = an.newLabel(value29, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(240, y2 * 0.5)

			local value30 = item2.get(item2, "memberCount")

			info[#info + 1] = an.newLabel(value30, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(395, y2 * 0.5)

			background.setTouchEnabled(background, true)
			background.setTouchSwallowEnabled(background, false)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value4) <= 5 then
						if value26 then
							for _, info2 in ipairs(value26.info) do
								info2.setColor(info2, def.colors.cellNor)
							end

							value26:removeSelf()

							value26 = nil
						end

						value27 = item2
						value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y2)):anchor(0, 0):pos(0, 0):add2(background)
						value26.info = info

						for _2, item in ipairs(info) do
							item.setColor(item, def.colors.cellSel)
						end
					end
				end
			end)

			if index2 == 1 then
				value27 = item2
				value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y2)):anchor(0, 0):pos(0, 0):add2(background)
				value26.info = info

				for _, item3 in ipairs(info) do
					item3.setColor(item3, def.colors.cellSel)
				end
			end
		end

		local x4 = 0

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				if value27:get("captainName") == value2.getPlayerName() and g_data.guild:isPresident() then
					main_scene.ui:tip("你是战队唯一会长，不可退出")

					return
				end

				an.newMsgbox("您确定将战队 " .. value27:get("corpsName") .. " 逐出行会吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_DISMISS_CORPS
						}, nil, {
							{
								"ID",
								value27:get("corpsID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zchh.png")
			}):add2(y):anchor(0.5, 0.5):pos(442, -22)

			x4 = 1
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value27 then
				return
			end

			print("selectData:get(corpsID) ", value27:get("corpsID"), g_data.guild.clanInfo:get("corpsID"))
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				series = 0,
				recog = 1
			}, nil, {
				{
					"ID",
					value27:get("corpsID")
				}
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/ckxx.png")
		}):add2(y):anchor(0.5, 0.5):pos(x4 * 100 - 442, -22)
	end,
	showSubClanrecruit = function(value, y)
		local items11 = {
			160,
			160,
			160
		}
		local items12 = {
			"战队名",
			"队长名",
			"人数"
		}
		local x3 = 5

		for index, item in ipairs(items11) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)

			items12[index] = an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, y.geth(y) - 23):add2(y)
			x3 = x3 + item
		end

		local items13 = g_data.guild.guildQueryMem or {}
		local scroll = an.newScroll(7, 8, 480, 292):add2(y)
		local y2 = 42

		scroll.setScrollSize(scroll, 480, math.max(292, #items13 * y2))

		local value26
		local value27

		for index2, item2 in ipairs(items13) do
			local info = {}
			local background = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y2)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y2):add2(scroll)
			local value28 = g_data.player:fixStrLen(item2.get(item2, "corpsName"), 8)

			info[#info + 1] = an.newLabel(value28, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(80, y2 * 0.5)

			local value29 = g_data.player:fixStrLen(item2.get(item2, "captainName"), 8)

			info[#info + 1] = an.newLabel(value29, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(240, y2 * 0.5)

			local value30 = item2.get(item2, "memberCount")

			info[#info + 1] = an.newLabel(value30, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(395, y2 * 0.5)

			background.setTouchEnabled(background, true)
			background.setTouchSwallowEnabled(background, false)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value4) <= 5 then
						if value26 then
							for _, info2 in ipairs(value26.info) do
								info2.setColor(info2, def.colors.cellNor)
							end

							value26:removeSelf()

							value26 = nil
						end

						value27 = item2
						value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y2)):anchor(0, 0):pos(0, 0):add2(background)
						value26.info = info

						for _2, item in ipairs(info) do
							item.setColor(item, def.colors.cellSel)
						end
					end
				end
			end)

			if index2 == 1 then
				value27 = item2
				value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y2)):anchor(0, 0):pos(0, 0):add2(background)
				value26.info = info

				for _, item3 in ipairs(info) do
					item3.setColor(item3, def.colors.cellSel)
				end
			end
		end

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				an.newMsgbox("您确定拒绝战队 " .. value27:get("corpsName") .. " 加入吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_REFUSE_REQUEST,
							recog = 1
						}, nil, {
							{
								"ID",
								value27:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/jjjr.png")
			}):add2(y):anchor(0.5, 0.5):pos(442, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				an.newMsgbox("您确定允许战队 " .. value27:get("corpsName") .. " 加入吗？", function(value4)
					if value4 == 1 then
						net.send({
							CM_GILD_ACCEPT_REQUEST,
							recog = 1
						}, nil, {
							{
								"ID",
								value27:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/yxjr.png")
			}):add2(y):anchor(0.5, 0.5):pos(342, -22)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 1
				}, nil, {
					{
						"ID",
						value27:get("corpsID")
					}
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/ckxx.png")
			}):add2(y):anchor(0.5, 0.5):pos(242, -22)
		end
	end,
	showSubDiplomatic = function(value, pageNode)
		local items11 = {
			120,
			120,
			120,
			120
		}
		local items12 = {
			"    正在联盟",
			"    正在宣战",
			"    正在关注",
			"    申请联盟"
		}
		local x3 = 5
		local value_2 = res.get2("pic/common/button_click02.png"):anchor(0.5, 0.5):add2(pageNode, 2)
		local value26

		function click(self)
			if value26 ~= self then
				value26 = self

				if value.pageNode then
					value.pageNode:removeSelf()

					value.pageNode = nil
				end

				value.pageNode = display.newNode():size(482, 292):pos(4, 8):anchor(0, 0):add2(pageNode, 2)

				if self == 1 then
					net.send({
						CM_GILD_QUERY_UNION,
						tag = 30,
						series = 0
					})

					value.threeSub = 1
				elseif self == 2 then
					net.send({
						CM_GILD_QUERY_HOSTILE,
						tag = 30,
						series = 0
					})

					value.threeSub = 2
				elseif self == 3 then
					net.send({
						CM_GILD_QUERY_CONCERN,
						tag = 30,
						series = 0
					})

					value.threeSub = 3
				elseif self == 4 then
					net.send({
						CM_GILD_QUERY_REQUEST_UNION_LIST,
						tag = 30,
						series = 0
					})

					value.threeSub = 4
				end
			end
		end

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, pageNode.geth(pageNode) - 23):add2(pageNode)

			items12[index] = an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, pageNode.geth(pageNode) - 23):add2(pageNode)

			res.get2("pic/common/button_click.png"):anchor(0.5, 0.5):pos(x3 + item * 0.5 - 40, pageNode.geth(pageNode) - 23):add2(pageNode)

			if index == 1 then
				value_2.pos(value_2, x3 + item * 0.5 - 40, pageNode.geth(pageNode) - 23)
			end

			local x4 = x3 + item * 0.5 - 40

			x3 = x3 + item

			background.enableClick(background, function()
				value_2:pos(x4, pageNode:geth() - 23)
				sound.playSound("103")
				click(index)
			end)
		end

		click(1)

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			value.guildBtn = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(guildBtn)
				net.send({
					CM_GILD_ENABLE_UNION,
					tag = guildBtn and 1 or 0
				})
			end, {
				easy = true,
				label = {
					"允许联盟",
					20,
					1,
					{
						color = def.colors.labelGray
					}
				}
			}):anchor(0, 0.5):pos(-110, -24):add2(pageNode, 2)

			local value27 = g_data.guild.guildInfo:get("enableUnion") == 1

			value.guildBtn.btn:setIsSelect(value27)
		end
	end,
	showSubDiplomatic1 = function(value, x3)
		x3 = x3 or value.pageNode

		if x3 then
			x3.removeAllChildren(x3, true)
		end

		if value.threeSub ~= 1 then
			return
		end

		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(x3.getw(x3), 42)):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, x3.geth(x3) - 20):add2(x3)
		an.newLabel("行会名", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(120, x3.geth(x3) - 20):add2(x3)

		local items11 = g_data.guild.guildUnion or {}
		local scroll = an.newScroll(0, 0, 480, 248):add2(x3)
		local y = 42

		scroll.setScrollSize(scroll, 480, math.max(248, #items11 * y))

		local value26
		local value27

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
			local value28 = g_data.player:fixStrLen(item.get(item, "name"), 8)

			an.newLabel(value28, 18, 1, {
				color = def.colors.labelGray
			}):add2(background):anchor(0.5, 0.5):pos(120, y * 0.5)
			an.newBtn(res.gettex2("pic/common/remove_n.png"), function()
				net.send({
					CM_GILD_BREAK_UNION
				}, nil, {
					{
						"ID",
						item:get("ID")
					}
				})
			end, {
				pressImage = res.gettex2("pic/common/remove_s.png")
			}):add2(background, 2):anchor(0.5, 0.5):pos(300, y * 0.5)
			background.setTouchEnabled(background, true)
			background.setTouchSwallowEnabled(background, false)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value4) <= 5 then
						if value26 then
							value26:removeSelf()

							value26 = nil
						end

						value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(background)
					end
				end
			end)
		end

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				g_data.guild.guildList = {}

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})
				value:showGuildList("增加联盟")
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zjlm.png")
			}):add2(x3):anchor(0.5, 0.5):pos(434, -30)
		end
	end,
	cmdFunc = function(value, value26, value28)
		local items11 = {
			增加联盟 = {
				"确定与行会 %s 申请联盟？",
				CM_GILD_REQUEST_UNION
			},
			行会宣战 = {
				"确定对行会 %s 发起宣战？",
				CM_GILD_DECLARE_WAR_NAME
			},
			增加关注 = {
				"确定对行会 %s 关注？",
				CM_GILD_CONCERN_GILD_NAME
			}
		}
		local value27
		local text172 = an.newMsgbox(string.format(items11[value26][1], value28), function(value4)
			if value4 == 1 then
				net.send({
					items11[value26][2]
				}, nil, {
					{
						"string",
						value28,
						15
					}
				})
			end
		end, {
			center = true,
			hasCancel = true
		})
	end,
	showGuildList = function(guildListCmd, guildListCmd2)
		local items11 = {
			行会宣战 = "hhxz",
			增加联盟 = "zjlm",
			增加关注 = "zjgz"
		}

		guildListCmd.guildListCmd = guildListCmd2 or guildListCmd.guildListCmd

		guildListCmd.content:hide()
		guildListCmd.bg:setTex(res.gettex2("pic/common/black_2.png"))

		if guildListCmd.showGuildListNode then
			guildListCmd.showGuildListNode:removeSelf()

			guildListCmd.showGuildListNode = nil
		end

		guildListCmd.showGuildListNode = display.newNode():addto(guildListCmd)

		local width2 = guildListCmd.showGuildListNode

		width2.size(width2, guildListCmd.getw(guildListCmd), guildListCmd.geth(guildListCmd))

		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(width2)
		local items12 = {
			200,
			200,
			124,
			82
		}
		local items13 = {
			"行会名",
			"会长名",
			"战队数",
			"状态"
		}
		local x3 = 4

		for index, item in ipairs(items12) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, background.geth(background) - 23):add2(background)
			an.newLabel(items13[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, background.geth(background) - 23):add2(background)

			x3 = x3 + item
		end

		local items14 = g_data.guild.guildList

		local function cleanup(self, value)
			if value == ccui.PageViewEventType.turning then
				local text172 = string.format("page %d", pageView:getCurPageIdx() + 1)

				print(text172)
			end
		end

		local scroll = an.newScroll(4, 4, 608, 288):add2(background)
		local y = 42

		scroll.setScrollSize(scroll, 608, math.max(288, #items14 * y))
		scroll.enableTouch(scroll, false)
		scroll.enableClick(scroll, function()
			return
		end)

		local value
		local value26

		for index2, item2 in ipairs(items14) do
			local info = {}
			local background2 = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y):add2(scroll)
			local value27 = g_data.player:fixStrLen(item2.get(item2, "gildName"), 8)

			info[#info + 1] = an.newLabel(value27, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(100, y * 0.5)

			local value28 = g_data.player:fixStrLen(item2.get(item2, "presidentName"), 8)

			info[#info + 1] = an.newLabel(value28, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(300, y * 0.5)

			local value29 = item2.get(item2, "corpsCount")

			info[#info + 1] = an.newLabel(value29, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(460, y * 0.5)

			local value30 = g_data.guild.curApplyguild and item2.get(item2, "guildID") == g_data.guild.curApplyguild and "申请中" or ""

			info[#info + 1] = an.newLabel(value30, 18, 1, {
				color = def.colors.cellNor
			}):add2(background2):anchor(0.5, 0.5):pos(556, y * 0.5)

			background2.setTouchEnabled(background2, true)
			background2.setTouchSwallowEnabled(background2, false)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value4) <= 5 then
						if value then
							for _, info2 in ipairs(value.info) do
								info2.setColor(info2, def.colors.cellNor)
							end

							value:removeSelf()

							value = nil
						end

						value26 = item2
						value = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background2)
						value.info = info

						for _2, item in ipairs(info) do
							item.setColor(item, def.colors.cellSel)
						end
					end
				end
			end)

			local value31 = cc.EventListenerCustom:create("UpdateNilGuildState", function()
				if g_data.guild.curApplyguild and item2:get("guildID") == g_data.guild.curApplyguild then
					info[4]:setString("申请中")
				else
					info[4]:setString("")
				end
			end)

			background2.getEventDispatcher(background2):addEventListenerWithSceneGraphPriority(value31, background2)

			if index2 == 1 then
				value26 = item2
				value = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background2)
				value.info = info

				for _, item3 in ipairs(info) do
					item3.setColor(item3, def.colors.cellSel)
				end
			end
		end

		local label

		label = an.newInput(0, 0, 196, 40, 7, {
			label = {
				guildListCmd.filterString or "",
				20,
				1
			},
			bg = {
				tex = res.gettex2("pic/scale/scale16.png"),
				offset = {
					-10,
					2
				}
			},
			tip = {
				"输入行会关键字      ",
				20,
				1,
				{
					color = cc.c3b(128, 128, 128)
				}
			},
			stop_call = function()
				if label:getString() == "" then
					guildListCmd.filterString = nil

					net.send({
						CM_GILD_LIST,
						param = 0,
						tag = 7
					})

					return
				end

				guildListCmd.filterString = label:getString()

				net.send({
					CM_FIND_GILD_BYNAME
				}, {
					label:getString()
				})
			end
		}):add2(width2):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			width2:removeSelf()

			guildListCmd.showGuildListNode = nil

			guildListCmd.bg:setTex(res.gettex2("pic/common/black_0.png"))
			guildListCmd.content:show()
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/mail/return.png")
		}):add2(width2):anchor(0.5, 0.5):pos(580, 38)
		print(items11[guildListCmd.guildListCmd])
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			if not value26 then
				return
			end

			print(guildListCmd.guildListCmd)
			guildListCmd:cmdFunc(guildListCmd.guildListCmd, value26:get("gildName"))
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/" .. items11[guildListCmd.guildListCmd] .. ".png")
		}):add2(width2):anchor(0.5, 0.5):pos(480, 38)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local value4 = g_data.guild.page

			if g_data.guild.serach then
				-- block empty
			end

			local param = value4 + 1

			net.send({
				CM_GILD_LIST,
				tag = 7,
				param = param
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xyy.png")
		}):add2(width2):anchor(0.5, 0.5):pos(380, 38)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			local param = g_data.guild.page - 1

			if param < 0 and not g_data.guild.serach then
				guildListCmd:showError(30)

				return
			end

			if param < 0 then
				param = 0
			end

			net.send({
				CM_GILD_LIST,
				tag = 7,
				param = param
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/syy.png")
		}):add2(width2):anchor(0.5, 0.5):pos(280, 38)
	end,
	showSubDiplomatic2 = function(value, x3)
		x3 = x3 or value.pageNode

		if x3 then
			x3.removeAllChildren(x3, true)
		end

		if value.threeSub ~= 2 then
			return
		end

		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(x3.getw(x3), 42)):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, x3.geth(x3) - 20):add2(x3)
		an.newLabel("行会名", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, x3.geth(x3) - 20):add2(x3)

		local items11 = g_data.guild.guildHostile or {}

		dump(items11)

		local scroll = an.newScroll(0, 0, 472, 252):add2(x3)
		local height = 42

		scroll.setScrollSize(scroll, 472, math.max(252, #items11 * height))

		local value26
		local value27

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(472, height)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * height):add2(scroll)
			local value28 = g_data.player:fixStrLen(item.get(item, "name"), 8)

			an.newLabel(value28, 18, 1, {
				color = def.colors.labelGray
			}):add2(background):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, height * 0.5)
			background.setTouchEnabled(background, true)
			background.setTouchSwallowEnabled(background, false)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value4) <= 5 then
						if value26 then
							value26:removeSelf()

							value26 = nil
						end

						value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, height)):anchor(0, 0):pos(0, 0):add2(background)
					end
				end
			end)
		end

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				g_data.guild.guildList = {}

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})
				value:showGuildList("行会宣战")
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/hhxz.png")
			}):add2(x3):anchor(0.5, 0.5):pos(434, -30)
		end
	end,
	showSubDiplomatic3 = function(value, y)
		y = y or value.pageNode

		if y then
			y.removeAllChildren(y, true)
		end

		if value.threeSub ~= 3 then
			return
		end

		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(242, 42)):anchor(0.5, 0.5):pos(121, y.geth(y) - 20):add2(y)
		an.newLabel("行会名", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(120, y.geth(y) - 20):add2(y)
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(242, 42)):anchor(0.5, 0.5):pos(361, y.geth(y) - 20):add2(y)
		an.newLabel("状态", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(352, y.geth(y) - 20):add2(y)

		local items11 = g_data.guild.guildConcern or {}
		local scroll = an.newScroll(0, 0, 472, 252):add2(y)
		local y2 = 42

		scroll.setScrollSize(scroll, 472, math.max(252, #items11 * y2))

		local items12 = {
			"",
			"联盟中",
			"宣战中",
			"申请联盟中"
		}
		local items13 = {
			cc.c3b(255, 255, 255),
			cc.c3b(0, 255, 0),
			cc.c3b(255, 0, 0),
			def.colors.labelGray
		}
		local value26
		local value27

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(472, y2)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y2):add2(scroll)
			local value28 = g_data.player:fixStrLen(item.get(item, "name"), 8)

			an.newLabel(value28, 18, 1, {
				color = def.colors.labelGray
			}):add2(background):anchor(0.5, 0.5):pos(120, y2 * 0.5)

			local value29 = items12[(item.get(item, "relation") or 0) + 1] or ""

			print("relation= ", item.get(item, "relation") or " nil ", value29)

			local color = items13[(item.get(item, "relation") or 0) + 1] or cc.c3b(255, 255, 255)

			an.newLabel(value29, 18, 1, {
				color = color
			}):add2(background):anchor(0.5, 0.5):pos(352, y2 * 0.5)
			background.setTouchEnabled(background, true)
			background.setTouchSwallowEnabled(background, false)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value4) <= 5 then
						if value26 then
							value26:removeSelf()

							value26 = nil
						end

						value27 = item
						value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, y2)):anchor(0, 0):pos(0, 0):add2(background)
					end
				end
			end)
		end

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				local value4
				local msgbox = an.newMsgbox("您确定取消对行会 " .. value27:get("name") .. " 的关注？", function(value5)
					if value5 == 1 then
						net.send({
							CM_GILD_CANCLE_CONCERN
						}, nil, {
							{
								"ID",
								value27:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/qxgz.png")
			}):add2(y):anchor(0.5, 0.5):pos(434, -30)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				g_data.guild.guildList = {}

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})
				value:showGuildList("增加关注")
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/zjgz.png")
			}):add2(y):anchor(0.5, 0.5):pos(334, -30)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				local value4
				local msgbox = an.newMsgbox("您确定对行会 " .. value27:get("name") .. " 发起宣战？", function(value5)
					if value5 == 1 then
						net.send({
							CM_GILD_DECLARE_WAR_NAME
						}, nil, {
							{
								"string",
								value27:get("name"),
								15
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/fqxz.png")
			}):add2(y):anchor(0.5, 0.5):pos(234, -30)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				sound.playSound("103")

				if not value27 then
					return
				end

				local value4
				local msgbox = an.newMsgbox("您确定申请与行会 " .. value27:get("name") .. " 联盟？", function(value5)
					if value5 == 1 then
						net.send({
							CM_GILD_REQUEST_UNION
						}, nil, {
							{
								"string",
								value27:get("name"),
								15
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/guild/sqlm.png")
			}):add2(y):anchor(0.5, 0.5):pos(134, -30)
		end
	end,
	showSubDiplomatic4 = function(value, x3)
		x3 = x3 or value.pageNode

		if x3 then
			x3.removeAllChildren(x3, true)
		end

		if value.threeSub ~= 4 then
			return
		end

		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(x3.getw(x3), 42)):anchor(0.5, 0.5):pos(x3.getw(x3) * 0.5, x3.geth(x3) - 20):add2(x3)
		an.newLabel("行会名", 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(120, x3.geth(x3) - 20):add2(x3)

		local items11 = g_data.guild.guildRequestUnion or {}
		local scroll = an.newScroll(0, 0, 472, 252):add2(x3)
		local y = 42

		scroll.setScrollSize(scroll, 472, math.max(252, #items11 * y))

		local value26
		local value27

		for index, item in ipairs(items11) do
			local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(472, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
			local value28 = g_data.player:fixStrLen(item.get(item, "corpsName"), 8)

			an.newLabel(value28, 18, 1, {
				color = def.colors.labelGray
			}):add2(background):anchor(0.5, 0.5):pos(120, y * 0.5)

			if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
				an.newBtn(res.gettex2("pic/common/accept_n.png"), function()
					net.send({
						CM_GILD_ACCEPT_REQUEST,
						recog = 2
					}, nil, {
						{
							"ID",
							item:get("ID")
						}
					})
				end, {
					pressImage = res.gettex2("pic/common/accept_s.png")
				}):add2(background, 2):anchor(0.5, 0.5):pos(260, y * 0.5)
				an.newBtn(res.gettex2("pic/common/refuse_n.png"), function()
					net.send({
						CM_GILD_REFUSE_REQUEST,
						recog = 2
					}, nil, {
						{
							"ID",
							item:get("ID")
						}
					})
				end, {
					pressImage = res.gettex2("pic/common/refuse_s.png")
				}):add2(background, 2):anchor(0.5, 0.5):pos(360, y * 0.5)
			end

			background.setTouchEnabled(background, true)
			background.setTouchSwallowEnabled(background, false)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value4) <= 5 then
						if value26 then
							value26:removeSelf()

							value26 = nil
						end

						value26 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, y)):anchor(0, 0):pos(0, 0):add2(background)
					end
				end
			end)
		end
	end,
	showSubLog = function(guildLogTypeOwner, value)
		local maxLine = 60
		local scroll = an.newScroll(8, 8, 472, 328, {
			labelM = {
				16,
				params = {
					maxLine = maxLine
				}
			}
		}):add2(value)
		local value26 = g_data.guild.guildLog or {}

		if value26 then
			for _, item in ipairs(value26) do
				scroll.labelM:addLabel(item.get(item, "logInfo"), def.colors.labelGray):nextLine()
			end
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			net.send({
				CM_GILD_QUERY_LOG,
				tag = 0,
				series = 30,
				param = 2
			})

			guildLogTypeOwner.guildLogType = 1
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zzrz.png")
		}):add2(value):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			net.send({
				CM_GILD_QUERY_LOG,
				tag = 0,
				series = 30,
				param = 1
			})

			guildLogTypeOwner.guildLogType = 0
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/cyrz.png")
		}):add2(value):anchor(0.5, 0.5):pos(342, -22)
	end,
	showOtherClanMem = function(value)
		local node = display.newNode()

		node.size(node, display.width, display.height):addto(display.getRunningScene(), an.z.msgbox)
		node.setTouchEnabled(node, true)
		node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function()
			return
		end)

		local value_2 = res.get2("pic/common/black_4.png"):addto(node):pos(display.cx, display.cy):anchor(0.5, 0.5)

		value_2.size(value_2, 400, 400)
		an.newBtn(res.gettex2("pic/common/close10.png"), function()
			sound.playSound("103")
			node:removeSelf()
		end, {
			pressImage = res.gettex2("pic/common/close11.png"),
			size = cc.size(64, 64)
		}):addTo(value_2):pos(value_2.getw(value_2) - 5, value_2.geth(value_2) - 5):anchor(1, 1)

		local items11 = {
			130,
			80,
			80,
			78
		}
		local items12 = {
			"角色名",
			"等级",
			"职业",
			"职务"
		}
		local x3 = 16

		for index, item in ipairs(items11) do
			display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x3 + item * 0.5, value_2.geth(value_2) - 64):add2(value_2)
			an.newLabel(items12[index], 20, 1, {
				color = def.colors.labelTitle
			}):anchor(0.5, 0.5):pos(x3 + item * 0.5, value_2.geth(value_2) - 64):add2(value_2)

			x3 = x3 + item
		end

		local scroll = an.newScroll(14, 16, 372, 300):add2(value_2)
		local y = 42
		local items13 = g_data.guild.guildcorpsMem or {}
		local items14 = {
			"",
			"副队长",
			"队长",
			"队长",
			"队长"
		}

		scroll.setScrollSize(scroll, 372, math.max(300, #items13 * y))

		for index2, item2 in ipairs(items13) do
			local background = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(372, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index2 * y):add2(scroll)
			local value26 = g_data.player:fixStrLen(item2.get(item2, "name"), 8)

			an.newLabel(value26, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(62, y * 0.5)

			local value27 = item2.get(item2, "level")

			an.newLabel(value27, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(172, y * 0.5)

			local otherJobStr = g_data.player:getOtherJobStr(item2.get(item2, "job"))

			an.newLabel(otherJobStr, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(252, y * 0.5)

			local value28 = items14[item2.get(item2, "position") + 1] or ""

			an.newLabel(value28, 18, 1, {
				color = def.colors.cellNor
			}):add2(background):anchor(0.5, 0.5):pos(330, y * 0.5)
		end
	end,
	showMenu = function(value, x3, value26, value27)
		if not value27 then
			return
		end

		local items11 = {}
		local number2 = 5
		local items12 = {}

		if value26 == "职务操作" then
			table.insert(items12, {
				title = "卸任",
				op = function()
					if g_data.guild:isLeader() then
						if value27:get("position") ~= 1 then
							main_scene.ui:tip("非副队长不能卸任")

							return
						end

						an.newMsgbox("您确定卸任 " .. value27:get("name") .. " 副队长职务吗？", function(value4)
							if value4 == 1 then
								net.send({
									CM_CORPS_DISMISS_VICE_CAPTAIN
								}, nil, {
									{
										"ID",
										value27:get("ID")
									}
								})
							end
						end, {
							center = true,
							hasCancel = true
						})
					elseif g_data.guild:isViceLeader() then
						an.newMsgbox("您确定卸任副队长职务吗？", function(value4)
							if value4 == 1 then
								net.send({
									CM_CORPS_STEPDOWN
								}, nil, {
									{
										"ID",
										value27:get("ID")
									}
								})
							end
						end, {
							center = true,
							hasCancel = true
						})
					end
				end
			})
			table.insert(items12, {
				title = "设副队长",
				op = function()
					an.newMsgbox("您确定任命 " .. value27:get("name") .. " 为副队长吗？", function(value4)
						if value4 == 1 then
							net.send({
								CM_CORPS_APPOINT_VICE_CAPTAIN
							}, nil, {
								{
									"ID",
									value27:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			})
			table.insert(items12, {
				title = "转让队长",
				op = function()
					an.newMsgbox("您确定转让队长职务给 " .. value27:get("name") .. " 吗？", function(value4)
						if value4 == 1 then
							if value27:get("name") == value2.getPlayerName() then
								main_scene.ui:tip("不能转让队长给自己")

								return
							end

							net.send({
								CM_CORPS_TRANSFER_CAPTAIN
							}, nil, {
								{
									"ID",
									value27:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			})
		elseif value26 == "更多操作" then
			table.insert(items12, {
				title = "私聊",
				op = function()
					value2.changeChatStyle({
						{
							"target",
							value27:get("name")
						},
						{
							"channel",
							"私聊"
						}
					})
				end
			})
			table.insert(items12, {
				title = "查看信息",
				op = function()
					net.send({
						CM_QUERYUSERSTATE
					}, {
						value27:get("name")
					})
				end
			})
			table.insert(items12, {
				title = "添加好友",
				op = function()
					net.send({
						CM_ADD_RELATION_FRIEND
					}, {
						value27:get("name")
					})
				end
			})
			table.insert(items12, {
				title = "邀请组队",
				op = function()
					net.send({
						#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
					}, {
						value27:get("name")
					})
				end
			})
			table.insert(items12, {
				title = "添加关注",
				op = function()
					net.send({
						CM_ADD_RELATION_ATTENTION
					}, {
						value27:get("name")
					})
				end
			})
			table.insert(items12, {
				title = "拉黑名单",
				op = function()
					net.send({
						CM_ADD_RELATION_NORMBLACKLIST
					}, {
						value27:get("name")
					})
				end
			})
		end

		local operationMenu

		for index, item in ipairs(items12) do
			items11[index] = {
				h = 41,
				w = 94,
				idx = index - 1,
				op = item,
				cellCls = function()
					return an.newBtn(res.gettex2("pic/common/btn10.png"), function()
						sound.playSound("103")

						if c.op.op then
							local value4 = c.op.op()
						end

						operationMenu:removeSelf()
					end, {
						pressImage = res.gettex2("pic/common/btn11.png"),
						label = {
							c.op.title,
							18,
							1,
							{
								color = def.colors.btn140
							}
						}
					}):anchor(0, 0)
				end
			}
		end

		operationMenu = value2.createOperationMenu(items11, number2, function(value4, value262)
			value4.removeSelf(value4)
		end):add2(value, 10):pos(x3.x + 6, x3.y)
	end,
	showError = function(value, value26)
		value26 = value26 or 1000

		local items11 = {
			"名字不合法",
			"名字重复",
			"已有战队",
			"玩家不在线",
			"玩家没有战队",
			"已有行会",
			"目标不存在",
			"请求已经存在",
			"不符合申请条件",
			"请求不存在",
			"请求的类型错误",
			"行会不存在",
			"行会成员已满",
			"关系类型错误",
			"关系已存在",
			"战队人数已满",
			"数据大小不对",
			"成员不存在",
			"不能操作本战队成员",
			"尝试删除队长(战队队长不能被删除)",
			"职位已满",
			"无效的目标",
			"类型不匹配",
			"信息长度太长",
			"没有找到目标",
			"成员已经存在",
			"关系不存在",
			"在行会战区域(无法退出行会)",
			"在攻城区域(无法退出行会)",
			"没有更多内容",
			"该成员已有职务",
			"已联盟不可宣战",
			"已宣战不可联盟",
			"对方拒绝联盟",
			"玩家不允许面对面加人",
			"玩家没有足够的金币",
			"只有在安全区才能退出战队",
			"只有在安全区才能退出行会",
			"需转让队长后才能操作 (退出)",
			"不可转让队长给自己",
			[555] = "无操作权限",
			[1000] = "未知错误"
		}

		main_scene.ui:tip(items11[value26] or "未知错误")
	end
}
local items2 = {
	onCleanup = function(value)
		for key2, setting in pairs(g_data.setting) do
			if type(setting) == "table" and value.cfg[key2] then
				cache.saveSetting(value2.getPlayerName(), key2)

				value.cfg[key2] = false
			end
		end

		if value.modifiedItem then
			main_scene.ground.map:updateItems()
			main_scene.ui.console.autoRat:updateModifyProperty()
		end
	end,
	ctor = function(x3, value)
		x3._supportMove = true

		x3.setNodeEventEnabled(x3, true)
		x3.setCascadeOpacityEnabled(x3, true)

		local value_2 = res.get2("pic/common/black_2.png"):anchor(0, 0):add2(x3)

		x3.size(x3, value_2.getw(value_2), value_2.geth(value_2)):anchor(0.5, 0.5):pos(display.cx, display.cy + 20)
		res.get2("pic/panels/setting/title.png"):anchor(0.5, 1):pos(x3.getw(x3) / 2, x3.geth(x3) - 12):add2(value_2)
		display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(127, 390)):addTo(value_2):pos(12, 15):anchor(0, 0)
		an.newBtn(res.gettex2("pic/common/close10.png"), function()
			sound.playSound("103")
			x3:hidePanel()
		end, {
			pressImage = res.gettex2("pic/common/close11.png"),
			size = cc.size(64, 64)
		}):anchor(1, 1):pos(x3.getw(x3) - 9, x3.geth(x3) - 8):addto(x3)

		x3.name = nil
		x3.content = nil

		x3.initTabList(x3)
	end,
	initTabList = function(tabList)
		tabList.tabs = {}

		local text172 = "常用"
		local items11 = {}
		local items12 = {}
		local items13 = {
			"常用",
			"物品",
			"保护",
			"药品",
			"辅助",
			"地图",
			"其他"
		}
		local items14 = {
			"jb",
			"wp",
			"bh",
			"yp",
			"fz",
			"xs",
			"lt"
		}

		if WIN32_OPERATE then
			local items15 = {
				{
					name = "快捷键",
					spr = "kj"
				}
			}

			for _, item in ipairs(items15) do
				table.insert(items13, item.name)
				table.insert(items14, item.spr)
			end
		end

		local enabled2 = true

		local function callback510(self)
			sound.playSound("103")

			if not enabled2 then
				return
			end

			local count = 1

			for index, tab in ipairs(tabList.tabs) do
				if tab == self then
					tab.select(tab)

					count = index
				else
					tab.unselect(tab)
				end
			end

			if items13[count] ~= tabList.name then
				tabList:load(items13[count])
			end
		end

		tabList.tabList = an.newScroll(12, 20, 127, 375):add2(tabList)

		tabList.tabList:enableTouch(WIN32_OPERATE)

		local node = display.newNode():pos(12, 15):size(127, 390):add2(tabList)

		node.setTouchEnabled(node, true)
		node.setTouchSwallowEnabled(node, false)
		node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				node.offsetBeginY = offsetBeginY.y
				enabled2 = true

				return true
			elseif offsetBeginY.name == "moved" then
				local value = offsetBeginY.y - node.offsetBeginY

				if math.abs(value) >= 5 then
					enabled2 = false
				end
			end
		end)

		for index, item2 in ipairs(items13) do
			tabList.tabs[index] = an.newBtn(res.gettex2("pic/common/btn60.png"), callback510, {
				label = {
					items13[index],
					20,
					1,
					{
						color = cc.c3b(240, 200, 150)
					}
				},
				select = {
					res.gettex2("pic/common/btn61.png"),
					manual = true
				}
			}):anchor(0.5, 0):add2(tabList.tabList):pos(63, 325 - (index - 1) * 50)

			tabList.tabs[index]:setCascadeOpacityEnabled(true)
			tabList.tabs[index]:setTouchSwallowEnabled(false)

			if (text172 or items13[1]) == item2 then
				callback510(tabList.tabs[index])
			end
		end
	end,
	createToggle = function(value, callback510, value28, label, temp, value29)
		local value26
		local value27

		temp = temp or {}

		local btn = display.newNode()
		local filteredSprite = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(btn)

		filteredSprite.setName(filteredSprite, "selsp")
		btn.setContentSize(btn, filteredSprite.getContentSize(filteredSprite))

		function btn.setIsSelect(self, isSelected)
			btn.isSelected = isSelected

			if isSelected then
				btn:select()
			else
				btn:unselect()
			end
		end

		function btn.isSelect(self)
			return btn.isSelected
		end

		function btn.select(self)
			btn.isSelected = true

			if btn.temp then
				btn.temp:removeSelf()

				btn.temp = nil
			end

			filteredSprite:setTex(res.gettex2(temp.selectImg or "pic/common/toggle02.png"))
		end

		function btn.select_temp(self)
			if btn.temp then
				return
			end

			btn.temp = display.newFilteredSprite(res.gettex2(temp.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(btn)

			btn.temp:setOpacity(80)
		end

		function btn.unselect(self)
			if btn.temp then
				btn.temp:removeSelf()

				btn.temp = nil
			end

			btn.isSelected = false

			filteredSprite:setTex(res.gettex2("pic/common/toggle00.png"))
		end

		if value28 ~= nil then
			btn.setIsSelect(btn, value28)
		end

		filteredSprite.setTouchEnabled(filteredSprite, true)
		filteredSprite.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				btn.offsetBeginY = offsetBeginY.y
				btn.offsetBeginX = offsetBeginY.x

				return true
			elseif offsetBeginY.name == "ended" then
				local value4 = offsetBeginY.y - btn.offsetBeginY
				local value262 = offsetBeginY.x - btn.offsetBeginX

				if math.abs(value4) <= 20 and math.abs(value262) <= 20 then
					btn:setIsSelect(not btn.isSelected)
					callback510(btn.isSelected)
				end
			end
		end)
		filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

		if label then
			btn.label = an.newLabel(unpack(label)):add2(btn):pos(btn.getw(btn) + 7, btn.geth(btn) / 2):anchor(0, 0.5)

			function btn.getw(self)
				return btn.label:getw() + 40
			end
		end

		btn.btn = btn

		function btn.gray(self)
			local filter = res.getFilter("gray")

			filteredSprite:setFilter(filter)
			btn:setTouchEnabled(false)

			if btn.temp then
				btn.temp:setFilter(filter)
			end
		end

		function btn.disGray(self)
			filteredSprite:clearFilter()
			btn:setTouchEnabled(true)

			if btn.temp then
				btn.temp:clearFilter(f)
			end
		end

		function btn.setGray(self, gray)
			if gray then
				btn:gray()
			else
				btn:disGray()
			end

			return btn
		end

		return btn
	end
}

local function cleanup(self, value26, label, temp)
	local value
	local value27

	temp = temp or {}

	local btn = display.newNode()
	local filteredSprite = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(btn)

	filteredSprite.setName(filteredSprite, "selsp")
	btn.setContentSize(btn, filteredSprite.getContentSize(filteredSprite))

	function btn.setIsSelect(self2, isSelected)
		btn.isSelected = isSelected

		if isSelected then
			btn:select()
		else
			btn:unselect()
		end
	end

	function btn.isSelect(self2)
		return btn.isSelected
	end

	function btn.select(self2)
		btn.isSelected = true

		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		filteredSprite:setTex(res.gettex2(temp.selectImg or "pic/common/toggle02.png"))
	end

	function btn.select_temp(self2)
		if btn.temp then
			return
		end

		btn.temp = display.newFilteredSprite(res.gettex2(temp.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(btn)

		btn.temp:setOpacity(80)
	end

	function btn.unselect(self2)
		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		btn.isSelected = false

		filteredSprite:setTex(res.gettex2("pic/common/toggle00.png"))
	end

	if value26 ~= nil then
		btn.setIsSelect(btn, value26)
	end

	filteredSprite.setTouchEnabled(filteredSprite, true)
	filteredSprite.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			btn.offsetBeginY = offsetBeginY.y
			btn.offsetBeginX = offsetBeginY.x

			return true
		elseif offsetBeginY.name == "ended" then
			local value4 = offsetBeginY.y - btn.offsetBeginY
			local value262 = offsetBeginY.x - btn.offsetBeginX

			if math.abs(value4) <= 20 and math.abs(value262) <= 20 then
				btn:setIsSelect(not btn.isSelected)
				self(btn.isSelected)
			end
		end
	end)
	filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

	if label then
		btn.label = an.newLabel(unpack(label)):add2(btn):pos(btn.getw(btn) + 7, btn.geth(btn) / 2):anchor(0, 0.5)

		function btn.getw(self2)
			return btn.label:getw() + 40
		end
	end

	btn.btn = btn

	function btn.gray(self2)
		local filter = res.getFilter("gray")

		filteredSprite:setFilter(filter)
		btn:setTouchEnabled(false)

		if btn.temp then
			btn.temp:setFilter(filter)
		end
	end

	function btn.disGray(self2)
		filteredSprite:clearFilter()
		btn:setTouchEnabled(true)

		if btn.temp then
			btn.temp:clearFilter(f)
		end
	end

	function btn.setGray(self2, gray)
		if gray then
			btn:gray()
		else
			btn:disGray()
		end

		return btn
	end

	return btn
end

function items2.add(self, value, value26, value27, callback510, value28, value29)
	local node = display.newNode():size(120, 28):anchor(0, 0.5)

	node.btn = self.createToggle(self, function(btn)
		if not value28 then
			value[value26] = btn
		end

		if callback510 then
			callback510(value[value26])

			return
		end
	end, value[value26], {
		value27,
		20,
		1,
		{
			color = cc.c3b(220, 210, 190)
		}
	}, nil, value29):anchor(0, 0.5):pos(0, 14):add2(node)

	return node
end

function items2.addWith(self, value, value26, value27, value28, value29)
	return
end

function items2.loadBase(self)
	function baseAdd(...)
		return self:add(g_data.setting.base, ...)
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local x3 = 20
	local nextY2 = self.content:geth() - 30
	local number2 = 47
	local number3 = 150

	self.btns.heroShowName = baseAdd("heroShowName", "人物显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHeroName")
	end, true):pos(x3, nextY2):add2(self.content).btn
	nextY = nextY2 - number2
	self.btns.NPCShowName = baseAdd("NPCShowName", "NPC显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNPCShowName")
	end, true):pos(x3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.petShowName = baseAdd("petShowName", "宠物显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPetShowName")
	end, true):pos(x3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.monShowName = baseAdd("monShowName", "怪物显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnMonShowName")
	end, true):pos(x3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.hiBlood = baseAdd("hiBlood", "高亮显血", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "hiBlood")
		main_scene.ground.player.info.hp.spr:setTex(g_data.setting.base.hiBlood and res.gettex2("pic/common/hp_green.png") or res.getuitex(3, 1))
	end, true):pos(x3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.lockColor = baseAdd("lockColor", "锁定光圈", function(value)
		self.cfg.base = true

		if value then
			for _, hero in pairs(main_scene.ground.map.heros) do
				hero.unselected(hero)
			end

			for _2, mon in pairs(main_scene.ground.map.mons) do
				mon.unselected(mon)
			end
		end

		main_scene.ui.console.btnCallbacks:handle("setting", "lockColor")
	end, true):pos(x3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.warningDura = baseAdd("warningDura", "持久警告", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "warningDura")
	end, true):pos(x3, nextY):add2(self.content).btn
	nextY = nextY - number2
	nextY = nextY2
	self.btns.showExpEnable = baseAdd("showExpEnable", "经验显示过滤", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "showExpEnable")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn

	local label

	label = an.newInput(self.btns.showExpEnable:getw() + 200, nextY - 2, 80, 34, 5, {
		label = {
			"" .. g_data.setting.base.showExpValue,
			20,
			1
		},
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-3,
				4
			}
		},
		stop_call = function()
			self.cfg.base = true
			g_data.setting.base.showExpValue = tonumber(label:getText()) or g_data.setting.base.showExpValue

			label:setText("" .. g_data.setting.base.showExpValue)
		end
	}):add2(self.content):anchor(0, 0.5)
	nextY = nextY - number2
	self.btns.soundEnable = baseAdd("soundEnable", "音效", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnSoundEnable")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.touchRun = baseAdd("touchRun", "触屏跑步", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnTouchRun")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.hideCorpse = baseAdd("hideCorpse", "隐藏尸体", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHideCorpse")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.showOutHP = baseAdd("showOutHP", "数字飘血", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnShowOutHP")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.quickexit = baseAdd("quickexit", "快速小退", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnquickexit")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.autoUnpack = baseAdd("autoUnpack", "自动解包", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnautoUnpack")
	end, true):pos(x3 + number3, nextY):add2(self.content).btn
	nextY = nextY - number2
	nextY = nextY2 - number2
	self.btns.showGuildName = baseAdd("showGuildName", "显示行会", function(value)
		self.cfg.base = true
		g_data.setting.base.showGuildName = not g_data.setting.base.showGuildName
		enable = g_data.setting.base.showGuildName
		settingKey = "showGuildName"

		local herosOwner = main_scene.ground.map

		for _, hero in pairs(herosOwner.heros) do
			hero.info:setName(hero.info.name.texts, true)
		end
	end, true):pos(x3 + number3 * 2, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.highFrame = baseAdd("highFrame", "高性能", function()
		self.cfg.base = true
		g_data.setting.base.highFrame = not g_data.setting.base.highFrame

		if g_data.setting.base.highFrame then
			cc.Director:getInstance():setAnimationInterval(0.011666666666666665)
		else
			cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
		end
	end, true):pos(x3 + number3 * 2, nextY):add2(self.content).btn

	local value = g_data.setting.base.highFrame
	local value26 = self.btns.highFrame

	value26:setIsSelect(value)

	if value then
		value26:select()
	else
		value26:unselect()
	end

	nextY = nextY - number2
	self.btns.autoUseRepair = baseAdd("autoUseRepair", "自动修复", function(value4)
		self.cfg.base = true
		g_data.setting.base.autoUseRepair = not g_data.setting.base.autoUseRepair
	end, true):pos(x3 + number3 * 2, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.musicEnalbe = baseAdd("musicEnalbe", "背景音乐", function(value4)
		self.cfg.base = true
		g_data.setting.base.musicEnalbe = not g_data.setting.base.musicEnalbe
	end, true):pos(x3 + number3 * 2, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.dresshero = baseAdd("dresshero", "人物简装", function()
		self.cfg.base = true
		g_data.setting.base.dresshero = not g_data.setting.base.dresshero

		local herosOwner = main_scene.ground.map

		for _, hero in pairs(herosOwner.heros) do
			hero:simplefeat()
		end
	end, true):pos(x3 + number3 * 2, nextY):add2(self.content).btn
	nextY = nextY - number2
	self.btns.dressmon = baseAdd("dressmon", "怪物简装", function(value4)
		self.cfg.base = true
		g_data.setting.base.dressmon = not g_data.setting.base.dressmon

		local monsOwner = main_scene.ground.map

		for _, mon in pairs(monsOwner.mons) do
			mon:simplefeat()
		end
	end, true):pos(x3 + number3 * 2, nextY):add2(self.content).btn

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local msgbox = an.newMsgbox("", function(value4)
			if value4 == 1 then
				g_data.setting.reset()

				for key2, _ in pairs(g_data.setting) do
					cache.removeSetting(key2)
				end

				main_scene:smallExit()
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("所有的设置恢复默认, 并且将立即小退。\n 是否继续？", 20, 1):addTo(msgbox):pos(msgbox.centerPos(msgbox)):anchor(0.5, 0.5)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/czqb.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)
end

function items2.loadItem(self)
	local callback510
	local btn
	local label

	local function callback610()
		self.modifiedItem = true
		self.cfg.item = true

		callback510(label:getText(), btn.category, true)
	end

	local filtOwner = g_data.setting.item

	filtOwner.filt = filtOwner.filt or {}

	local function callback710(...)
		local btnOwner = self:add(filtOwner, ...)
		local labelOwner = btnOwner.btn

		labelOwner.label:pos(-labelOwner.label:getw() / 2 + 10, labelOwner.label:getPositionY()):scale(0.9)

		return btnOwner
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local value_2 = res.get2("pic/panels/setting/line.png"):anchor(0, 1):pos(0, background.geth(background) - 55):add2(background)
	local number2 = 29
	local number3 = 70
	local label2 = an.newLabel("物品名称", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(self.cleft + 10, self.ctop - 40)
	local pickOnRatting = callback710("pickOnRatting", "挂机\n捡取", callback610, false):add2(self.content):pos((self.content:getw() - 45) / 5 + number3, self.ctop - number2)
	local pickUp = callback710("pickUp", "捡取\n物品", callback610, false):add2(self.content):pos((self.content:getw() - 45) * 2 / 5 + number3, self.ctop - number2)
	local hintName = callback710("showName", "物品\n显名", callback610, false):add2(self.content):pos((self.content:getw() - 45) * 3 / 5 + number3, self.ctop - number2)
	local isGood = callback710("hindGood", "物品\n标红", callback610, false):add2(self.content):pos((self.content:getw() - 45) * 4 / 5 + number3, self.ctop - number2)
	local scroll = an.newScroll(0, self.ctop - 58, self.cright, background.geth(background) - 65, {
		labelM = {
			18,
			1
		}
	}):anchor(0, 1):add2(self.content)
	local number4 = 42
	local items11 = {
		{
			"极品属性道具",
			0,
			hightLight = true
		}
	}

	for itemId, item in pairs(def.items) do
		if type(item) == "table" and item.get then
			local value = item.get(item, "name")

			if value == "金币1" then
				value = "金币"
			end

			if filtOwner.filt[value] then
				items11[#items11 + 1] = {
					value,
					itemId
				}
			end
		end
	end

	local items12 = items11

	scroll.setScrollSize(scroll, self.cright, number4 * #items12)

	local items13 = {
		isGood = isGood,
		pickOnRatting = pickOnRatting,
		hintName = hintName,
		pickUp = pickUp
	}

	local function updateVisible(self2, value, value26)
		local toggle

		toggle = self:createToggle(function(value4)
			if toggle.name then
				self.cfg.item = true
				filtOwner.filt[toggle.name] = rawget(filtOwner.filt, toggle.name) or filtOwner.filt[toggle.name] or {}
				filtOwner.filt[toggle.name][self2] = value4
				self.modifiedItem = true
			else
				print("item filter setting changed, but item is no name!")
			end
		end, selected, nil, {
			selectImg = "pic/common/" .. value26 .. ".png"
		}):anchor(0, 0)

		return toggle
	end

	local function updateVisible2(ident, size, height, value26)
		local labelOwner = items12[ident]
		local name = labelOwner[1]

		size.ident = ident
		size.height = height

		labelOwner.label:pos(10, height + 3):setVisible(not value26)

		for index, item in ipairs({
			"isGood",
			"pickOnRatting",
			"hintName",
			"pickUp"
		}) do
			size[item].name = name

			size[item]:pos(size[item]:getPositionX(), height)
			size[item]:setVisible(not value26)

			local value

			if not filtOwner.filt[name] and true or filtOwner.filt[name][item] then
				size[item].btn:select()
			else
				size[item].btn:unselect()
			end

			if items13[item].btn:isSelect() then
				size[item].btn:select_temp()
				size[item].btn:gray()
			else
				size[item].btn:disGray()
			end
		end
	end

	local function updateVisible3(self2)
		if items12[self2] then
			local value = items12[self2]

			if value[1] and value[1] ~= nil then
				local size = {
					height = scroll:getScrollSize().height - self2 * number4
				}

				if not value.added then
					local color = def.colors.labelYellow

					if value.hightLight then
						color = def.colors.clRed
					end

					value.label = an.newLabel(value[1], 20, 1, {
						bufferChannel = 0,
						color = color
					}):add2(scroll)
				end

				size.pickOnRatting = updateVisible("pickOnRatting", value[1], "toggle03"):add2(scroll):pos((scroll:getw() - 45) / 5 + 70, size.height)
				size.pickUp = updateVisible("pickUp", value[1], "toggle04"):add2(scroll):pos((scroll:getw() - 45) * 2 / 5 + 70, size.height)
				size.hintName = updateVisible("hintName", value[1], "toggle04"):add2(scroll):pos((scroll:getw() - 45) * 3 / 5 + 70, size.height)
				size.isGood = updateVisible("isGood", value[1], "toggle02"):add2(scroll):pos((scroll:getw() - 45) * 4 / 5 + 70, size.height)

				updateVisible2(self2, size, size.height)

				value.added = true
				value.showing = true

				return size
			end
		end
	end

	local items14 = {}

	local function updateVisible4(ident, value, value27, value28)
		local height = scroll:getScrollSize().height - ident * number4

		if items12[ident].showing then
			return
		end

		for _, item in ipairs(items14) do
			if value27 < item.height or value28 > item.height then
				local value26 = items12[item.ident]

				if value26 and value26.showing then
					value26.showing = false

					value26.label:pos(0, 0):setVisible(false)
				end

				item.ident = ident
				item.height = height

				if not items12[ident].added then
					items12[ident].label = an.newLabel(items12[ident][1], 20, 1, {
						bufferChannel = 0,
						color = def.colors.labelYellow
					}):add2(scroll):pos(25, height + 3)
					items12[ident].added = true
				end

				updateVisible2(ident, item, height)

				items12[ident].showing = true

				return
			end
		end

		local item2 = updateVisible3(ident)

		table.insert(items14, item2)
	end

	local value26
	local value27

	function callback510(self2, value, value262)
		if value26 == self2 and value27 == value and not value262 then
			return
		end

		value26 = self2
		value27 = value

		local items112 = {}
		local items122 = {}

		for _, item in ipairs(items11) do
			local categoryOwner = filtOwner.filt[item[1]]

			if (not value or categoryOwner and categoryOwner.category == value) and (not self2 or item[1] and string.find(item[1], self2)) then
				items122[#items122 + 1] = item
			end

			item.showing = false

			if item.label then
				item.label:removeFromParent()
			end

			item.label = nil
			item.added = false
		end

		for _2, item2 in ipairs(items14) do
			item2.isGood:removeFromParent()
			item2.pickOnRatting:removeFromParent()
			item2.hintName:removeFromParent()
			item2.pickUp:removeFromParent()
		end

		items14 = {}
		items12 = items122

		scroll:setScrollOffset(0, 0)
		scroll:setScrollSize(self.cright, number4 * #items12)
	end

	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(220, 45):add2(self.content)

	label = an.newInput(10, 3, 150, 38, 12, {
		label = {
			"",
			20,
			1
		},
		return_call = function()
			self.cfg.item = true

			callback610()
		end,
		tip = {
			" <输入关键字查找>" or "",
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}
	}):add2(background2):anchor(0, 0):pos(10, 1)

	an.newBtn(res.gettex2("pic/common/button_search.png"), function()
		sound.playSound("103")
		callback510(label:getText(), btn.category)
	end):add2(self.content):pos(background2.getw(background2), background2.geth(background2) / 2):anchor(1, 0.5)

	local value28 = clone(def.items.category)

	table.insert(value28, 1, "全  部")

	local items15 = {
		"全  部",
		"书籍类",
		"其它类",
		"武器类",
		"药品类",
		"勋章",
		"首饰类",
		"防具类"
	}
	local items16 = {
		"qbl",
		"sjl",
		"qtl",
		"wql",
		"ypl",
		"xzl",
		"ssl",
		"fjl"
	}

	local function cleanup2(self2)
		for index, item in ipairs(items15) do
			if item == self2 then
				return items16[index]
			end
		end

		return items16[1]
	end

	btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local items112 = {}
		local operationMenu

		for _, category in pairs(value28) do
			local items122 = {
				w = 110,
				h = 40,
				cate = category,
				cellCls = function()
					local text172 = "pic/common/btn20.png"
					local text18 = "pic/common/btn21.png"

					if btn.labelInfo == category .. "  " then
						text172 = "pic/common/btn10.png"
						text18 = "pic/common/btn11.png"
					end

					return an.newBtn(res.gettex2(text172), function()
						sound.playSound("103")

						if btn.labelInfo == category .. "  " then
							return
						end

						self.cfg.item = true

						operationMenu:removeSelf()
						btn.sprite:setTex(res.gettex2("pic/panels/setting/" .. cleanup2(category) .. ".png"))

						btn.category = category

						if category == "全  部" then
							btn.category = nil
						end

						callback510(label:getText(), btn.category)
					end, {
						pressImage = res.gettex2(text18),
						labelInfo = category,
						sprite = res.gettex2("pic/panels/setting/" .. cleanup2(category) .. ".png")
					})
				end
			}

			table.insert(items112, items122)
		end

		operationMenu = value2.createOperationMenu(items112, 10, function(value, value262)
			self.cfg.item = true
		end, {
			drag = true
		}):add2(btn):pos(-14, 40)
	end, {
		labelInfo = "全  部",
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/qbarr.png")
	}):anchor(1, 0):pos(self.content:getw() - 120, 1):add2(self.content)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		self.cfg.item = true

		g_data.setting.resetItemFilt()

		value26 = nil

		callback510(label:getText(), btn.category)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/hfmr.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)

	local value29 = cc.EventListenerCustom:create("director_after_update", function()
		local scrollOffset, scrollOffset2 = scroll:getScrollOffset()
		local scrollSize = scroll:getScrollSize().height
		local value = math.ceil((scrollOffset2 + scroll:geth()) / number4)
		local value262 = math.floor(scrollOffset2 / number4)
		local text172 = ""

		for index = value262, value do
			local value272 = index + 1

			text172 = string.format("%s,%d", text172, value272)

			if items12[value272] then
				updateVisible4(value272, items12[value272], scrollSize - scrollOffset2, scrollSize - scrollOffset2 - scroll:geth() - 30)
			end
		end
	end)

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(value29, 1)

	function scroll.onCleanup()
		cc.Director:getInstance():getEventDispatcher():removeEventListener(value29)
	end

	scroll.setNodeEventEnabled(scroll, true)
end

function items2.loadPro(self)
	local function callback510(self2, value26, value27, value28, value29)
		local value = g_data.setting.protected[self2][value26]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		self:createToggle(function(enable)
			self.cfg.protected = true
			value.enable = enable
		end, value.enable, {
			value27,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, node.geth(node) / 2):add2(node)

		local label

		label = an.newInput(120, node.geth(node) / 2 - 2, 80, 34, 5, {
			label = {
				"" .. value.value,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.protected = true
				value.value = tonumber(label:getText()) or value.value

				if value.isPercent then
					value.value = math.min(value.value, 100)
				end

				label:setText("" .. value.value)
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel(value28, 20, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(230, node.geth(node) / 2):add2(node)

		return node
	end

	local function callback610(self2, value, value26)
		local valueOwner = g_data.setting.protected[self2][value]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		an.newLabel("躲闪血量", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(0, node.geth(node) / 2):add2(node)

		local label

		label = an.newInput(84, node.geth(node) / 2 - 2, 80, 34, 5, {
			label = {
				"" .. valueOwner.value,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.protected = true
				valueOwner.value = tonumber(label:getText()) or valueOwner.value
				valueOwner.value = math.max(valueOwner.value, 40)
				valueOwner.value = math.min(valueOwner.value, g_data.hero.ability:get("maxHP"))

				label:setText("" .. valueOwner.value)
				net.send({
					CM_COMMON_INFORMATION,
					param = 2,
					recog = valueOwner.value
				})
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel("HP", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(160, node.geth(node) / 2):add2(node)

		return node
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local items11 = {}
	local value
	local items12 = {
		"role",
		"hero"
	}
	local count = 0

	local function updateVisible(self2)
		self.cfg.protected = true

		background:removeAllChildren()

		if self2 == 1 then
			local value4 = g_data.setting.protected.role

			an.newLabel("主号保护设置", 20, 1, {
				color = def.colors.labelYellow
			}):add2(background):pos(15, background:geth() - 42 - count)

			local texts = "随机传送卷,地牢逃脱卷,回城,行会回城卷,随机传送石,小退"
			local res = {
				"pic/panels/setting/icon_1.png",
				"pic/panels/setting/icon_2.png",
				{
					"pic/console/skill_base-icons/back.png",
					0.65
				},
				"pic/panels/setting/icon_4.png",
				"pic/panels/setting/icon_7.png",
				"pic/panels/setting/icon_8.png"
			}

			self:createSelectTab({
				scale = 1,
				texts = texts,
				res = res,
				curtext = value4.hp.uses,
				size = cc.size(128, 24),
				endFunc = function(uses)
					value4.hp.uses = uses
				end
			}):anchor(0, 0.5):pos(280, background:geth() - 70 - count):add2(background, 2)
			self:createSelectTab({
				scale = 1,
				texts = texts,
				res = res,
				curtext = value4.mp.uses,
				size = cc.size(128, 24),
				endFunc = function(uses)
					value4.mp.uses = uses
				end
			}):anchor(0, 0.5):pos(280, background:geth() - 140 - count):add2(background, 1)
			callback510("role", "hp", "HP低于", "时使用", def.colors.labelGray):pos(15, background:geth() - 70 - count):add2(background)
			callback510("role", "mp", "MP低于", "时使用", def.colors.labelGray):pos(15, background:geth() - 140 - count):add2(background)

			return
		end

		an.newLabel("英雄保护设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(background):pos(15, background:geth() - 42 - count)
		callback510("hero", "hp", "HP低于", "收英雄", def.colors.labelGray):pos(15, background:geth() - 70 - count):add2(background)
		callback510("hero", "mp", "MP低于", "收英雄", def.colors.labelGray):pos(15, background:geth() - 120 - count):add2(background)
		callback610("hero", "miss", def.colors.labelGray):pos(280, background:geth() - 260 - count):add2(background)
	end

	if def.gameVersionType == "185" then
		local node

		for index, item in ipairs({
			"主号",
			"英雄"
		}) do
			local value26 = index
			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(background.getw(background) / 2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw() / 2 - 5) * (index - 1) + 5, self.ctop - 5)
			local label = an.newLabel(item, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local value_2 = res.get2("pic/common/button_click.png"):add2(background2):pos(background2.getw(background2) / 2 - label.getw(label) / 2, background2.geth(background2) / 2)

			label.add2(label, value_2):pos(value_2.getw(value_2), 0)

			local node2 = res.get2("pic/common/button_click02.png"):add2(value_2):pos(value_2.getw(value_2) / 2, value_2.geth(value_2) / 2)

			node2.setVisible(node2, value26 == 1)
			background2.setTouchEnabled(background2, true)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value4) <= 10 and not node2:isVisible() then
						node:setVisible(false)
						updateVisible(value26)
						node2:setVisible(true)

						node = node2
					end
				end
			end)

			node = node or node2
		end

		count = 50
	end

	updateVisible(1)
end

function items2.loadDrugs(self)
	local function callback510(self2, value26, value27, value28, value29, value30)
		local value = self2[value26]

		value28 = value28 or 10
		value29 = value29 or "请输入数字"
		value30 = value30 or "请输入数字"

		local node = display.newNode():size(460, 30)

		self.createToggle(self, function(enable)
			self.cfg.drugs = true
			value.enable = enable
		end, value.enable, {
			value27,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(10, node.geth(node) / 2):add2(node)

		if value28 > value.value then
			value.value = value28
		end

		local background = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(170, node.geth(node) / 2):add2(node):size(85, 41)
		local label = an.newLabel("" .. (value.value or value28), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(background):pos(10, background.geth(background) * 0.5)

		background.enableClick(background, function()
			local msgbox

			msgbox = an.newMsgbox(value29, function(value4)
				if value4 == 1 then
					if msgbox.input:getString() == "" then
						return
					end

					self.cfg.drugs = true

					local value262 = tonumber(msgbox.input:getText())

					if value262 then
						value262 = value262 > value28 and value262 or value28
					else
						value262 = value28 < value.value and value.value or value28
					end

					value.value = value262

					label:setString("" .. value.value)
				end
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 7, {
				label = {
					label:getString(),
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/scale16.png"),
					offset = {
						-10,
						2
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
		end)

		local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(330, node.geth(node) / 2):add2(node):size(85, 41)
		local label2 = an.newLabel("" .. (value.space or 0), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(background2):pos(10, background2.geth(background2) * 0.5)

		background2.enableClick(background2, function()
			local msgbox

			msgbox = an.newMsgbox(value30, function(value4)
				if value4 == 1 then
					if msgbox.input:getString() == "" then
						return
					end

					self.cfg.drugs = true
					value.space = tonumber(msgbox.input:getText()) or value.space

					label2:setString("" .. (value.space or 0))
				end
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 7, {
				label = {
					label2:getString(),
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/scale16.png"),
					offset = {
						-10,
						2
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
		end)

		return node
	end

	local function callback610(self2, value, value26)
		local number2 = self2[value]
		local node = display.newNode()
		local label = an.newLabel(value26, 20, 1, {
			color = def.colors.labelGray
		}):add2(node):pos(0, 0):anchor(0, 0.5)
		local label2 = an.newLabel(math.ceil(tonumber(number2.value) * 100) .. "%", 20, 1, {
			color = def.colors.labelGray
		}):add2(node):pos(370, 0):anchor(0, 0.5)

		local function valueChange(self3)
			local number22 = math.ceil(tonumber(self3) * 100)

			self.cfg.drugs = true
			number2.value = number22 / 100

			label2:setString(tostring(number22) .. "%")
		end

		an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
			scale9 = cc.size(250, 15),
			value = number2.value,
			valueChange = valueChange,
			valueChangeEnd = valueChange
		}):add2(node):pos(100, 0):anchor(0, 0.5).block:setScale(0.7)

		return node
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local number2 = 65
	local size = background.getContentSize(background)
	local value = def.gameVersionType == "185"

	function click(self2)
		local h = background:geth() - 35
		local value4 = size.height - 75

		if value then
			h = h - 50
			value4 = value4 - 50
		end

		background:removeAllChildren()

		local value26 = g_data.setting.drugs.hero
		local value27 = g_data.setting.drugs.heroSetting

		if self2 == 1 then
			value26 = g_data.setting.drugs.role
			value27 = g_data.setting.drugs.roleSetting
		end

		local scroll = an.newScroll(0, 20, size.width, value4):add2(background)

		local function callback511(self3)
			local value5 = value26.percentDrug

			callback610(value5, "normalHP", "普通红药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			callback610(value5, "normalMP", "普通蓝药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			callback610(value5, "quickHP", "瞬回红药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			callback610(value5, "quickMP", "瞬回蓝药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			return self3
		end

		local function cleanup2(self3)
			an.newLabel("剩余HP/MP", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(scroll):pos(196, self3)
			an.newLabel("间隔(毫秒)", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(scroll):pos(364, self3)
			res.get2("pic/common/b4.png"):anchor(0.5, 0.5):pos(230, self3 - 12):add2(scroll)

			self3 = self3 - 40

			local value5 = value26.numberDrug

			callback510(value5, "normalHP", "普通红药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			callback510(value5, "normalMP", "普通蓝药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			callback510(value5, "quickHP", "瞬回红药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			callback510(value5, "quickMP", "瞬回蓝药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			return self3
		end

		local value28

		local function cleanup22(self3)
			local value5 = value4 - number2 / 2

			return self3(value5) + 30
		end

		local function updateVisible(self3)
			local label = an.newLabelM(scroll:getw() - 20, 20, 1):add2(scroll):pos(15, self3 - 140)

			local function updateVisible2(self4, value5)
				label:addLabel(self4, def.colors.labelYellow)
				label:addLabel(value5, def.colors.clRed)
			end

			label.addLabel(label, "注:\n", def.colors.labelYellow)
			updateVisible2("普红:", "金创药(小量)、金创药(中量)、强效金创药\n")
			updateVisible2("普蓝:", "魔法药(小量)、魔法药(中量)、强效魔法药\n")
			updateVisible2("瞬回:", "太阳水、强效太阳水、万年雪霜、疗伤药")
		end

		local value29 = h
		local btnOwner
		local btnOwner2

		local function updateVisible2(withPercent)
			self.cfg.drugs = true
			h = value29 - number2

			scroll:removeSelf()

			scroll = an.newScroll(0, 20, size.width, value4):add2(background)
			value27.withPercent = withPercent
			value27.withNumber = not withPercent

			if withPercent then
				btnOwner.btn:select()
				btnOwner2.btn:unselect()

				h = cleanup22(callback511)
			else
				btnOwner.btn:unselect()
				btnOwner2.btn:select()

				h = cleanup22(cleanup2)
			end

			updateVisible(h)
		end

		btnOwner = self:add(value27, "withPercent", "按百分比自动喝药", function(value5)
			updateVisible2(not value5)
		end, true):add2(background):pos(20, h)
		btnOwner2 = self:add(value27, "withNumber", "按血量自动喝药", updateVisible2, true):add2(background):pos(250, h)
		h = h - number2 + 20

		if value27.withPercent then
			h = cleanup22(callback511)
		else
			h = cleanup22(cleanup2)
		end

		updateVisible(h)
	end

	click(1)

	if value then
		local node

		for index, item in ipairs({
			"主号",
			"英雄"
		}) do
			local value26 = index
			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(background.getw(background) / 2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw() / 2 - 5) * (index - 1) + 5, self.ctop - 5)
			local label = an.newLabel(item, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local value_2 = res.get2("pic/common/button_click.png"):add2(background2):pos(background2.getw(background2) / 2 - label.getw(label) / 2, background2.geth(background2) / 2)

			label.add2(label, value_2):pos(value_2.getw(value_2), 0)

			local node2 = res.get2("pic/common/button_click02.png"):add2(value_2):pos(value_2.getw(value_2) / 2, value_2.geth(value_2) / 2)

			node2.setVisible(node2, value26 == 1)
			background2.setTouchEnabled(background2, true)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value4 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value4) <= 10 and not node2:isVisible() then
						node:setVisible(false)
						click(value26)
						node2:setVisible(true)

						node = node2
					end
				end
			end)

			node = node or node2
		end
	end
end

function items2.loadJob(self)
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local playerName = value2.getPlayerName()
	local scroll = an.newScroll(0, 5, background.getw(background), background.geth(background) - 10, {
		labelM = {
			18,
			1
		}
	}):add2(background)
	local x3 = 25

	local function callback510(self2)
		for itemId, item in pairs(self2) do
			local magicConfigByUid = def.magic.getMagicConfigByUid(item)

			if not magicConfigByUid or not magicConfigByUid.name and not magic.heroName then
				self2[itemId] = nil
			end
		end

		return self2
	end

	local function callback610(self2, callback511)
		local items11 = {}
		local items12 = {}
		local value
		local value26

		for itemId, item in pairs(self2) do
			if g_data.player:getMagic(item) then
				table.insert(items12, string.format("pic/console/skill-icons/%d.png", item))
				table.insert(items11, itemId)

				if type(callback511) == "number" then
					if callback511 == item then
						value = itemId
						value26 = item
					end
				elseif type(callback511) == "function" then
					callback511(itemId, item)
				elseif not callback511 then
					value = itemId
					value26 = item
					callback511 = item
				end
			end
		end

		return items11, items12, value or "", value26
	end

	local count = 0

	local function callback710(self2, value26, callback511, value27, value28, value29)
		local value = g_data.setting[value28 or "job"]
		local node = display.newNode():anchor(0, 0.5)
		local enableOwner = value[self2]

		if type(enableOwner) == "table" then
			enableOwner = enableOwner.enable
		end

		node.btn = cleanup(function(btn)
			self.cfg.autoRat = true

			if not value27 then
				value[self2] = btn
			end

			if callback511 then
				callback511(value[self2])

				return
			end
		end, enableOwner, {
			value26,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, 14):add2(node)

		node.size(node, node.btn:getw(), node.btn:geth())

		return node
	end

	local x4 = -10

	an.newLabel("技能", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll):pos(x3 + x4, self.content:geth() - 50)

	local h = self.content:geth() - 68

	local function callback82()
		if not g_data.hero or not g_data.hero.roleid then
			return
		end

		local x32 = x3

		if g_data.hero:getMagic(31) then
			self.btns.btnautoDunHero = callback710("autoDunHero", "英雄持续开盾", function(value)
				self.cfg.job = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnautoDunHero")
			end, true):add2(scroll):pos(x32, h).btn
			hasSkill = true
			h = h - 43
		end

		return h
	end

	local value = g_data.player.job
	local value26 = def.momo.skillname.zzszr
	local value27 = def.momo.skillname.zsmfd

	if value == 0 then
		local x5 = x3

		self.btns.btnAutoAllSpace = callback710("autoAllSpace", "刀刀刺杀", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoAllSpace")
		end, true):add2(scroll):pos(x5, h).btn:setGray(not g_data.player:getMagic(12))

		local x6 = x5 + 240

		self.btns.btnAutoAllSpace = callback710("autoSpace", "隔位刺杀", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpace")
		end, true):add2(scroll):pos(x6, h).btn:setGray(not g_data.player:getMagic(12))

		local x7 = x3

		h = h - 45
		self.btns.btnAutoFire = callback710("autoFire", "自动烈火", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoFire")
		end, true):add2(scroll):pos(x7, h).btn:setGray(not g_data.player:getMagic(26))

		local x8 = x7 + 240

		self.btns.btnAutoWide = callback710("autoWide", "智能半月", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoWide")
		end, true):add2(scroll):pos(x8, h).btn:setGray(not g_data.player:getMagic(25))

		local x9 = x3

		h = h - 45
		self.btns.btnAutoSword = callback710("autoSword", value26, function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSword")
		end, true):add2(scroll):pos(x9, h).btn:setGray(not g_data.player:getMagic(58))

		if def.momo.skillbtn then
			local x10 = x9 + 240

			self.btns.btnAutoDun = self.add(self, g_data.setting.job, "autoDun", value27, function(value4)
				self.cfg.job = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoDun")
			end, true):add2(scroll):pos(x10, h).btn:setGray(not g_data.player:getMagic(31))
		end

		h = h - 45

		callback82()
		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x4 + 25, h - 6):anchor(0, 0)

		h = h - 36
		self.btns.btnAutoRoar = callback710("autoRoar", "身边有", function(value4)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")
		end, true, "autoRat"):add2(scroll):pos(x3, h).btn:setGray(not g_data.player:getMagic(43))

		local label

		label = an.newInput(self.btns.btnAutoRoar:getw() + 30, h - 7, 70, 34, 5, {
			donotClip = true,
			label = {
				"" .. g_data.setting.autoRat.autoRoar.cnt,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.autoRat = true
				g_data.setting.autoRat.autoRoar.cnt = tonumber(label:getText()) or g_data.setting.autoRat.autoRoar.cnt

				label:setText("" .. g_data.setting.autoRat.autoRoar.cnt)
			end
		}):add2(scroll):anchor(0, 0.5)

		an.newLabel("个怪时使用狮子吼", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll):pos(label.getw(label) + label.getPositionX(label), h - 3):enableClick(function()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")
		end)

		h = h - 45
	elseif value == 1 then
		self.btns.btnAutoDun = callback710("autoDun", "自动魔法盾", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoDun")
		end, true):add2(scroll):pos(x3, h).btn:setGray(not g_data.player:getMagic(31))
		h = h - 42

		callback82()
		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x4 + 25, h - 6):anchor(0, 0)

		h = h - 30

		local items11 = {
			雷电术 = 11,
			冰咆哮 = 33,
			大火球 = 5,
			爆裂火焰 = 23,
			灭天火 = 35,
			疾光电影 = 10,
			流星火雨 = 59,
			火球术 = 1,
			地狱火 = 9,
			地狱雷光 = 24
		}
		local value28
		local value29
		local value30 = g_data.setting.autoRat.atkMagic
		local texts, res2, curtext, magicId = callback610(items11, value30.magicId)

		value30.magicId = magicId

		if value30.enable == nil and g_data.player:getMagic(1) then
			value30.magicId = 1
			curtext = "火球术"
			value30.enable = true
		end

		curtext = curtext or ""

		if #texts ~= 0 then
			self.btns.btnAtkMagic = callback710("atkMagic", "挂机技能", function(value4)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end, true, "autoRat"):add2(scroll):pos(x3, h).btn

			local selectTab = self.createSelectTab(self, {
				parent = self.content,
				texts = texts,
				res = res2,
				curtext = curtext,
				size = cc.size(128, 24),
				endFunc = function(value4)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = items11[value4]
				end
			}, self.content):anchor(0, 0.5):pos(x3 + self.btns.btnAtkMagic:getw(), h):add2(scroll, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(selectTab.getw(selectTab) + selectTab.getPositionX(selectTab), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end)

			h = h - 50
		end

		local items12 = {
			流星火雨 = 59,
			地狱火 = 9,
			爆裂火焰 = 23,
			冰咆哮 = 33,
			疾光电影 = 10,
			地狱雷光 = 24
		}
		local magicIdOwner = g_data.setting.autoRat.areaMagic
		local texts2, res22, curtext2, magicId2 = callback610(items12, magicIdOwner.magicId)

		magicIdOwner.magicId = magicId2

		if #texts2 > 0 then
			local value31 = callback710("areaMagic", "目标身边有", function(value4)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")
			end, true, "autoRat"):add2(scroll):pos(x3, h)

			self.btns.btnareaMagic = value31.btn

			local label2

			label2 = an.newInput(value31.getw(value31) + 30, h - 7, 35, 34, 5, {
				donotClip = true,
				label = {
					"" .. g_data.setting.autoRat.areaMagic.cnt,
					20,
					1
				},
				bg = {
					h = 32,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-3,
						4
					}
				},
				stop_call = function()
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.cnt = tonumber(label2:getText()) or g_data.setting.autoRat.areaMagic.cnt

					label2:setText("" .. g_data.setting.autoRat.areaMagic.cnt)
				end
			}):add2(scroll):anchor(0, 0.5)

			local label3 = an.newLabel("个怪时使用", 20, 1, {
				color = def.colors.labelGray
			})

			label3.anchor(label3, 0, 0.5):add2(scroll):pos(label2.getw(label2) + label2.getPositionX(label2), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")
			end)
			self.createSelectTab(self, {
				parent = self.content,
				texts = texts2,
				res = res22,
				curtext = curtext2,
				size = cc.size(128, 24),
				endFunc = function(value4)
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.magicId = items12[value4]
				end
			}, self.content):anchor(0, 0.5):pos(label3.getPositionX(label3) + label3.getw(label3), h):add2(scroll, 2)

			h = h - 50
		end
	elseif value == 2 then
		local value32 = def.momo.skillname.dsmfd
		local x11 = x3

		self.btns.btnAutoInvisible = callback710("autoInvisible", "自动隐身", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoInvisible")
		end, true):add2(scroll):pos(x11, h).btn:setGray(not g_data.player:getMagic(18))

		local x12 = 180

		self.btns.btnAutoPoison = callback710("autoPoison", "自动施毒", function(value4)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPoison")
		end, true, "autoRat"):add2(scroll):pos(x12, h).btn:setGray(not g_data.player:getMagic(6))
		h = h - 40

		local x13 = x3

		self.btns.btnAutoYoulingDun = callback710("autoYoulingDun", "自动幽灵盾", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoYoulingDun")
		end, true, "job"):add2(scroll):pos(x13, h).btn:setGray(not g_data.player:getMagic(14))

		local x14 = 180

		self.btns.btnAutoZhanjiashu = callback710("autoZhanjiashu", "自动神圣战甲术", function(value4)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoZhanjiashu")
		end, true, "job"):add2(scroll):pos(x14, h).btn:setGray(not g_data.player:getMagic(15))

		if def.momo.skillbtn then
			h = h - 40

			local x15 = x3

			self.btns.btnAutoDun = self.add(self, g_data.setting.job, "autoDun", value32, function(value4)
				self.cfg.job = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoDun")
			end, true):add2(scroll):pos(x15, h).btn:setGray(not g_data.player:getMagic(31))
		end

		h = h - 40
		h = callback82(h)

		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x4 + 25, h - 6):anchor(0, 0)

		h = h - 36

		local items13 = {
			灵魂火符 = 13,
			噬血术 = 48
		}
		local magicIdOwner2 = g_data.setting.autoRat.atkMagic
		local texts3, res3, curtext3, magicId3 = callback610(items13, magicIdOwner2.magicId)

		magicIdOwner2.magicId = magicId3

		local items14 = {
			召唤骷髅 = 17,
			召唤神兽 = 30
		}
		local magicIdOwner3 = g_data.setting.autoRat.autoPet
		local texts4, res4, value33, magicId4 = callback610(items14, magicIdOwner3.magicId)

		magicIdOwner3.magicId = magicId4

		local items15 = {
			治愈术 = 2,
			群体治疗术 = 29
		}
		local magicIdOwner4 = g_data.setting.autoRat.autoCure
		local texts5, res5, curtext4, magicId5 = callback610(items15, magicIdOwner4.magicId)

		magicIdOwner4.magicId = magicId5

		if #texts3 > 0 then
			self.btns.btnAtkMagic = callback710("atkMagic", "", function(value4)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end, true, "autoRat"):add2(scroll):pos(x3, h).btn

			local selectTab2 = self.createSelectTab(self, {
				parent = self.content,
				texts = texts3,
				res = res3,
				curtext = curtext3,
				size = cc.size(128, 24),
				endFunc = function(value4)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = items13[value4]
				end
			}, self.content):anchor(0, 0.5):pos(x3 + self.btns.btnAtkMagic:getw(), h):add2(scroll, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(selectTab2.getw(selectTab2) + selectTab2.getPositionX(selectTab2), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end)

			h = h - 50
		else
			g_data.setting.autoRat.atkMagic.enable = false
		end

		if #texts4 > 0 then
			self.btns.btnAutoPet = callback710("autoPet", "自动召唤宠物", function(value4)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPet")
			end, true, "autoRat"):add2(scroll):pos(x3, h).btn

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts4,
				res = res4,
				curtext = value33 or "",
				size = cc.size(128, 24),
				endFunc = function(value4)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoPet.magicId = items14[value4]
				end
			}, self.content):anchor(0, 0.5):pos(x3 + self.btns.btnAutoPet:getw(), h):add2(scroll, 2)

			h = h - 50
		end

		if #texts5 > 0 then
			self.btns.btnAutoCure = callback710("autoCure", "人物血量低于", function(value4)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")
			end, true, "autoRat"):add2(scroll):pos(x3, h).btn

			local label4

			label4 = an.newInput(x3 + self.btns.btnAutoCure:getw(), h - 3, 40, 34, 5, {
				donotClip = true,
				label = {
					"" .. g_data.setting.autoRat.autoCure.percent,
					20,
					1
				},
				bg = {
					h = 32,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-3,
						4
					}
				},
				stop_call = function()
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.percent = tonumber(label4:getText()) or g_data.setting.autoRat.autoCure.percent

					label4:setText("" .. g_data.setting.autoRat.autoCure.percent)
				end
			}):add2(scroll):anchor(0, 0.5)

			local label5 = an.newLabel("%时使用", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(label4.getw(label4) + label4.getPositionX(label4), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")
			end)

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts5,
				res = res5,
				curtext = curtext4,
				size = cc.size(128, 24),
				endFunc = function(value4)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.magicId = items15[value4]
				end
			}, self.content):anchor(0, 0.5):pos(label5.getw(label5) + label5.getPositionX(label5), h):add2(scroll, 2)

			h = h - 50
		end

		if #items14 > 0 then
			local items16 = {
				治愈术 = 2,
				群体治疗术 = 29
			}
			local magicIdOwner5 = autoCurePet.magicId
			local texts6, res6, curtext5, magicId6 = callback610(items16, magicIdOwner5.magicId)

			magicIdOwner5.magicId = magicId6

			if #texts6 > 0 then
				self.btns.btnAutoCurePet = callback710("autoCurePet", "宠物血量低于", function(value4)
					self.cfg.autoRat = true

					main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")
				end, true, "autoRat"):add2(scroll):pos(x3, h).btn

				local label6

				label6 = an.newInput(x3 + self.btns.btnAutoCurePet:getw(), h - 3, 40, 34, 5, {
					donotClip = true,
					label = {
						"" .. g_data.setting.autoRat.autoCurePet.percent,
						20,
						1
					},
					bg = {
						h = 32,
						tex = res.gettex2("pic/scale/edit.png"),
						offset = {
							-3,
							4
						}
					},
					stop_call = function()
						self.cfg.autoRat = true
						g_data.setting.autoRat.autoCurePet.percent = tonumber(label6:getText()) or g_data.setting.autoRat.autoCurePet.percent

						label6:setText("" .. g_data.setting.autoRat.autoCurePet.percent)
					end
				}):add2(scroll):anchor(0, 0.5)

				local label7 = an.newLabel("%时使用", 20, 1, {
					color = def.colors.labelGray
				}):anchor(0, 0.5):add2(scroll):pos(label6.getw(label6) + label6.getPositionX(label6), h):enableClick(function()
					self.cfg.autoRat = true

					main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")
				end)

				self.createSelectTab(self, {
					parent = self.content,
					texts = texts6,
					res = res6,
					curtext = curtext5,
					size = cc.size(128, 24),
					endFunc = function(value4)
						self.cfg.autoRat = true
						g_data.setting.autoRat.autoCurePet.magicId = items16[value4]
					end
				}, self.content):anchor(0, 0.5):pos(label7.getw(label7) + label7.getPositionX(label7), h):add2(scroll, 2)

				h = h - 50
			end
		end
	end

	self.btns.btnIgnoreCripple = callback710("ignoreCripple", "只打满血怪", function(value4)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnIgnoreCripple")
	end, true, "autoRat"):add2(scroll):pos(x3, h).btn
	h = h - 50
	self.btns.btnAutoSpaceMove = callback710("autoSpaceMove", "", function(value4)
		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")
	end, true, "autoRat"):add2(scroll):pos(x3, h).btn

	local label8

	label8 = an.newInput(x3 + self.btns.btnAutoSpaceMove:getw(), h - 3, 45, 34, 5, {
		donotClip = true,
		label = {
			"" .. g_data.setting.autoRat.autoSpaceMove.space,
			20,
			1
		},
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-3,
				4
			}
		},
		stop_call = function()
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.space = tonumber(label8:getText()) or g_data.setting.autoRat.autoSpaceMove.space

			label8:setText("" .. g_data.setting.autoRat.autoSpaceMove.space)
		end
	}):add2(scroll):anchor(0, 0.5)

	local label9 = an.newLabel("分钟无经验增加使用", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):add2(scroll):pos(label8.getw(label8) + label8.getPositionX(label8), h):enableClick(function()
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")
	end)
	local texts7 = "随机传送卷,随机传送石"
	local res7 = {
		"pic/panels/setting/icon_1.png",
		"pic/panels/setting/icon_7.png"
	}

	self.createSelectTab(self, {
		scale = 1,
		parent = self.content,
		texts = texts7,
		res = res7,
		curtext = g_data.setting.autoRat.autoSpaceMove.use,
		size = cc.size(128, 24),
		endFunc = function(use)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.use = use
		end
	}, self.content):anchor(0, 0.5):pos(label9.getw(label9) + label9.getPositionX(label9), h):add2(scroll, 2)

	h = h - 50

	local magicIds = def.magic.getMagicIds(g_data.player.job, false)
	local texts8 = {}
	local res8 = {}
	local items17 = {}
	local value34

	for _, item in ipairs(magicIds) do
		if g_data.player:getMagic(tonumber(item)) and not checkExist(tonumber(item), 12, 25, 26, 31, 18, 3, 4, 7, 67) then
			local magicConfigByUid = def.magic.getMagicConfigByUid(item)

			texts8[#texts8 + 1] = magicConfigByUid.name
			res8[#res8 + 1] = string.format("pic/console/skill-icons/%d.png", item)
			items17[magicConfigByUid.name] = tonumber(item)

			if not g_data.setting.job.autoSkill.magicId or g_data.setting.job.autoSkill.magicId and tonumber(item) == g_data.setting.job.autoSkill.magicId then
				value34 = magicConfigByUid.name
			end
		end
	end

	if #texts8 > 0 then
		an.newLabel("自动练功", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x4 + 25, h - 6):anchor(0, 0)

		h = h - 30
		self.btns.btnAutoSkill = callback710("autoSkill", "间隔", function(value4)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")
		end, true):add2(scroll):pos(x3, h).btn

		local label10

		label10 = an.newInput(x3 + self.btns.btnAutoSkill:getw(), h, 70, 34, 5, {
			donotClip = true,
			label = {
				"" .. g_data.setting.job.autoSkill.space,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.autoRat = true

				local number2 = tonumber(label10:getText()) or 1

				if number2 < 0.1 then
					number2 = 0.1
				end

				g_data.setting.job.autoSkill.space = tonumber(number2) or g_data.setting.job.autoSkill.space

				label10:setText("" .. g_data.setting.job.autoSkill.space)
			end
		}):add2(scroll):anchor(0, 0.5)

		local label11 = an.newLabel("秒使用", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll):pos(label10.getw(label10) + label10.getPositionX(label10), h):enableClick(function()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")
		end)

		self.createSelectTab(self, {
			parent = self.content,
			texts = texts8,
			res = res8,
			curtext = value34 or "",
			size = cc.size(128, 24),
			endFunc = function(value4)
				self.cfg.autoRat = true
				g_data.setting.job.autoSkill.magicId = items17[value4]
			end
		}, self.content):anchor(0, 0.5):pos(label11.getw(label11) + label11.getPositionX(label11), h):add2(scroll, 2)

		h = h - 50
	end

	an.newLabel("挂机捡取设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll):pos(x4 + 25, h):anchor(0, 0)

	h = h - 25
	self.btns.btnNoPickUpItem = callback710("noPickUpItem", "挂机时不捡取任何道具", function(value4)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")

		if g_data.setting.autoRat.pickUpRatting then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")
		end
	end, true, "autoRat"):add2(scroll):pos(x3, h).btn
	h = h - 45
	self.btns.btnPickUpGood = callback710("pickUpRatting", "捡取挂机道具", function(value4)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")

		if g_data.setting.autoRat.noPickUpItem then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")
		end
	end, true, "autoRat"):add2(scroll):pos(x3, h).btn
end

function items2.loadView(self)
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local label = an.newLabel("地图缩放(1.0倍)", 22, 1, {
		color = def.colors.labelYellow
	}):add2(background):pos(140, self.content:geth() - 110)

	local function callback510(self2)
		self.cfg.display = true

		label:setString("地图缩放(" .. self2 .. "倍)")
	end

	callback510(g_data.setting.display.mapScale)

	local number2 = 0.7
	local number3 = 2.3
	local count = 1
	local number4 = 1.25
	local number5 = 1.5
	local slider = an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
		scale9 = cc.size(background.getw(background) - 100, 15),
		value = (g_data.setting.display.mapScale - number2) / (number3 - number2),
		valueChange = function(value)
			if def.momo.heyemoshi then
				main_scene.ui:tip("当前服务器禁止调整缩放比例")

				return
			end

			self:opacity(64)

			local value26 = (number3 - number2) * value + number2
			local text172 = tonumber(string.format("%.2f", value26))

			callback510(text172)
			main_scene.ground:scale(text172)
		end,
		valueChangeEnd = function(value)
			if def.momo.heyemoshi then
				main_scene.ui:tip("当前服务器禁止调整缩放比例")

				return
			end

			self:opacity(255)

			local value26 = (number3 - number2) * value + number2
			local mapScale = tonumber(string.format("%.2f", value26))

			callback510(mapScale)

			g_data.setting.display.mapScale = mapScale

			main_scene.ground:scale(mapScale)
			main_scene.ground.map:updateMapScale(mapScale)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
		end
	}):add2(self.content):pos(background.getw(background) / 2, self.content:geth() - 120):anchor(0.5, 0.5)
	local label2 = an.newLabel("拒绝", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(120, self.content:geth() - 210)
	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(55, 34):add2(self.content):pos(label2.getPositionX(label2) + label2.getw(label2) + 3, self.content:geth() - 215)
	local label3

	label3 = an.newInput(10, 3, 150, 38, 3, {
		label = {
			tostring(g_data.setting.chat.whisperLimit),
			20,
			1
		},
		stop_call = function()
			self.cfg.chat = true
			g_data.setting.chat.whisperLimit = tonumber(label3:getString())
		end
	}):add2(background2):anchor(0, 0):pos(10, -5)

	an.newLabel("级以下玩家私聊", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(background2.getPositionX(background2) + background2.getw(background2) + 4, self.content:geth() - 210)
	an.newLabel("(此项填0时屏蔽所有人的私聊消息)", 18, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(112, self.content:geth() - 256)

	function default(mapScale)
		return function()
			sound.playSound("103")

			g_data.setting.display.mapScale = mapScale

			callback510(g_data.setting.display.mapScale)
			main_scene.ground:stopAllActions()
			main_scene.ground:scaleTo(0.3, mapScale)
			main_scene.ground.map:updateMapScale(mapScale)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
			slider:setValue((g_data.setting.display.mapScale - number2) / (number3 - number2))
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), default(count), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj1.png")
	}):pos(background.getw(background) / 6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), default(number4), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj2.png")
	}):pos(background.getw(background) * 3 / 6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), default(number5), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj3.png")
	}):pos(background.getw(background) * 5 / 6, self.cbottom + 22):add2(self.content)
	traversalNodeTree(self, function(value)
		if value ~= label and value ~= slider then
			value.setCascadeOpacityEnabled(value, true)
		end

		return true
	end)
end

function items2.loadChat(self)
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local count = 0
	local number2 = 240

	an.newLabel("其他设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 65)

	self.btns.sampleShow = self.add(self, g_data.setting.base, "sampleShow", "掉落提示", function(value)
		self.cfg.base = true
		g_data.setting.base.sampleShow = not g_data.setting.base.sampleShow
		settingKey = "sampleShow"

		local herosOwner = main_scene.ground.map

		for _, hero in pairs(herosOwner.heros) do
			hero.info:setName(hero.info.name.texts, true)
		end
	end, true):pos(40, self.content:geth() - 95):add2(self.content)
	self.btns.lockHeroTips = self.add(self, g_data.setting.base, "lockHeroTips", "锁人提示", function(value)
		self.cfg.base = true
		g_data.setting.base.lockHeroTips = not g_data.setting.base.lockHeroTips
	end, true):pos(185, self.content:geth() - 95):add2(self.content)
	self.btns.baoji = self.add(self, g_data.setting.base, "baoji", "暴击显示", function(value)
		self.cfg.base = true
		g_data.setting.base.baoji = not g_data.setting.base.baoji
	end, true):pos(330, self.content:geth() - 95):add2(self.content)

	an.newLabel("消耗设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 165)

	self.btns.slideLock = self.add(self, g_data.setting.base, "slideLock", "自动使用消耗品", function(value)
		self.cfg.base = true
		g_data.setting.base.slideLock = not g_data.setting.base.slideLock

		local value26 = g_data.setting.base.slideLock and 1 or 2

		main_scene.ui.console:call("attackBtns", "setLockType", value26)
	end, true):pos(40, self.content:geth() - 195):add2(self.content)

	local text172 = "消耗品名：" .. def.momo.fooditems

	an.newLabel(text172, 18, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 240)
end

function items2.load(self, name)
	self.name = name

	if self.content then
		self.content:removeSelf()
	end

	self.btns = {}
	self.content = display.newNode():pos(146, 15):size(480, 390):add2(self)
	self.ctop = self.content:geth()
	self.cbottom = 0
	self.cleft = 0
	self.cright = self.content:getw()

	if name == "常用" then
		self.loadBase(self)
	elseif name == "物品" then
		self.loadItem(self)
	elseif name == "保护" then
		self.loadPro(self)
	elseif name == "药品" then
		self.loadDrugs(self)
	elseif name == "辅助" then
		self.loadJob(self)
	elseif name == "地图" then
		self.loadView(self)
	elseif name == "帮助" then
		self.loadHelp(self)
	elseif name == "其他" then
		self.loadChat(self)
	elseif name == "快捷键" then
		self.loadHotKeyView(self)
	else
		an.newLabel("功能研发中...", 18, 1):add2(self.content):anchor(0.5, 0.5):pos(self.content:getw() * self.content:getScale() / 2, self.content:geth() * self.content:getScale() / 2)
	end
end

function items2.createSelectTab(self, res2, sender)
	res2 = res2 or {}
	res2.size = res2.size or size(60, 30)
	res2.texts = res2.texts or {
		""
	}
	res2.res = res2.res or ""
	res2.curtext = res2.curtext or "随机传送卷"
	res2.fontSize = res2.fontSize or 20
	res2.strokeSize = res2.strokeSize or 1
	res2.color = res2.color or def.colors.labelGray
	res2.tabBackColor = res2.tabBackColor or cc.c3b(120, 120, 120)

	if type(res2.texts) == "string" then
		res2.texts = string.split(res2.texts, ",")
	end

	local function cleanup2(self2)
		local text172 = type(res2.res) == "table" and res2.res[self2] or string.format(res2.res, self2)
		local value = res2.scale

		if type(text172) == "table" then
			value = text172[2]
			text172 = text172[1]
		end

		return text172, value
	end

	local node
	local label
	local value_2

	node = res.get2("pic/panels/setting/tab_frame.png"):enableClick(function(x3, y)
		local point = node:getParent():convertToNodeSpace(cc.p(x3, y))

		if cc.rectContainsPoint(node:getBoundingBox(), point) then
			node:setTouchSwallowEnabled(false)

			res2.size = node:getContentSize()

			local function cleanup3(self2, value)
				local value_22 = res.get2("pic/panels/setting/tab_frame.png")
				local value26, value27 = cleanup2(self2)
				local value_222 = res.get2(value26):anchor(0.5, 0.5):pos(32, 32):add2(value_22, 2)

				value_222.setScale(value_222, value27 or 52 / value_222.getw(value_222))
				an.newLabel(value, res2.fontSize, res2.strokeSize, {
					color = res2.color
				}):anchor(0.5, 0.5):pos(value_22.getw(value_22) * 0.6, value_22.geth(value_22) * 0.5):addTo(value_22)

				return value_22
			end

			if res2.texts then
				local items11 = {}

				for index, text172 in ipairs(res2.texts) do
					local items12 = {
						h = 50,
						w = 190,
						cellCls = function()
							return cleanup3(index, text172)
						end,
						object = text172,
						index = index
					}

					items11[#items11 + 1] = items12
				end

				local h = 240

				if #res2.texts < 5 then
					h = #res2.texts * 55 + 10
				end

				local operationMenu = value2.createOperationMenu(items11, 5, function(value, value27)
					local value26 = value27.object
					local value28 = value27.index

					label:setString(value26)

					local value29, value30 = cleanup2(value28)

					value_2:setTex(res.gettex2(value29))
					value_2:scale(value30 or 45 / value_2:getw())
					value.removeSelf(value)

					if res2.endFunc then
						res2.endFunc(value26)
					end
				end, {
					scroll = {
						w = 190,
						h = h
					}
				}):anchor(0, 1)

				if res2.parent then
					operationMenu.add2(operationMenu, res2.parent)

					local point2 = cc.p(0, 0)
					local value = node:convertToWorldSpace(point2)
					local y2 = res2.parent:convertToNodeSpace(value)

					operationMenu.pos(operationMenu, y2.x, y2.y + 50)
				else
					local position, position2 = node:getPosition()

					operationMenu.add2(operationMenu, node:getParent(), 50):pos(position, position2 - 20)
				end
			end
		end
	end)
	label = an.newLabel(res2.curtext, res2.fontSize, res2.strokeSize, {
		color = res2.color
	}):anchor(0.5, 0.5):pos(node.getw(node) * 0.6, node.geth(node) * 0.5):addTo(node)

	local value, value26 = cleanup2(1)

	value_2 = res.get2(value):anchor(0.5, 0.5):pos(31, 34):add2(node, 2)

	value_2.setScale(value_2, value26 or 45 / value_2.getw(value_2))

	for index, text172 in ipairs(res2.texts) do
		if text172 == res2.curtext then
			local value27, value28 = cleanup2(index)

			value_2.setTex(value_2, res.gettex2(value27))
			value_2.setScale(value_2, value28 or 45 / value_2.getw(value_2))
		end
	end

	return node
end

function items2.loadHotKeyView(self)
	self.hotKeyView = hotKeySetting.new():addTo(self.content)
end

local items = {}
local width = 800
local height2 = 600
local value4 = display.width / width
local value5 = display.height / height2
local x = {
	function()
		return 221 * value4, 230 * value5
	end,
	function()
		return 565 * value4, 230 * value5
	end
}
local items7 = {
	function()
		return 95 * value4, 90 * value5
	end,
	function()
		return 645 * value4, 88 * value5
	end
}
local x2 = {
	function()
		return 221 * value4, 375 * value5
	end,
	function()
		return 565 * value4, 375 * value5
	end
}

local function x3()
	return 221 * value4, 375 * value5
end

local number = 4

function items.ctor(self)
	self.mask = nil
	self.area = nil
	self.closedMsgbox = nil
	self.entered = false
	self.roles = {}
	self.del_roles = {}
	self.del_selectIdx = nil

	if device.platform == "android" then
		self:setKeypadEnabled(true)
		self:addNodeEventListener(cc.KEYPAD_EVENT, function(keyOwner)
			if keyOwner.key == "back" then
				an.newMsgbox("确定要退出游戏吗?", function(value)
					if value == 1 then
						os.exit(1)
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end)
	end

	net.setMatchMode(true)
end

function items.onEnter(self)
	print("select.scene:onEnter")
	self.super.onEnter(self)
	_G.def.items.initFilt()
end

function items.onExit(self)
	net.setMatchMode(false)
	print("select.scene:onExit")
	self.super.onExit(self)
end

function items.onEnterTransitionFinish(self)
	print("onEnterTransitionFinish")

	local node = display.newNode():size(width, height2):anchor(0.5, 0.5):center():fit():addTo(self)

	if g_data.security.loginBit then
		self:showSecurity()
	end

	res.get2("pic/login/select.png"):addTo(node):pos(node:getw() / 2, node:geth() / 2)

	self.area = an.newLabel(g_data.login:getSelectGroup():get("groupName"), 18, 1):anchor(0.5, 1):pos(display.cx, display.height - 3):addto(self):hide()

	local function cleanup2(self2)
		sound.playSound("103")

		if self.mask and self2 ~= 1 and self2 ~= 5 then
			return
		end

		if self2 == 1 then
			if #g_data.select.roles == 0 then
				an.newMsgbox("你还没创建角色.", nil, {
					center = true
				})
			else
				if self.mask ~= nil then
					self.mask:removeSelf()
				else
					net.send({
						CM_SELCHR
					}, {
						g_data.select:getCurName()
					})
				end

				self.mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 0)):addto(self):runs({
					cc.FadeTo:create(0.3, 192),
					cc.DelayTime:create(1)
				})
			end
		elseif self2 == 2 then
			if #g_data.select.roles >= 20 and IS_PLAYER_DEBUG then
				an.newMsgbox("您的角色已满20个", nil, {
					center = true
				})
			elseif number <= #g_data.select.roles and not IS_PLAYER_DEBUG then
				an.newMsgbox("您的角色已满" .. number .. "个", nil, {
					center = true
				})
			else
				self:showCreate()
			end
		elseif self2 == 3 then
			if #g_data.select.roles == 0 then
				return
			end

			an.newMsgbox("[" .. g_data.select:getCurName() .. "]删除的角色是不能被恢复的,\n一段时间内您将不能使用相同的角色名称.\n你真的确定要删除吗？", function(value)
				if value == 1 then
					an.newMsgbox("再次确认你真的确定要删除吗？", function(value26)
						if value26 == 1 then
							net.send({
								CM_DELCHR
							}, {
								g_data.select.roles[g_data.select.selectIndex].name
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end, {
				hasCancel = true
			})
		elseif self2 == 4 then
			net.send({
				CM_QUERYDELCHR
			})
		elseif self2 == 5 then
			net.send({
				CM_SELCHR_EXIT
			})
		end
	end

	for index = 1, 5 do
		local w
		local h

		if index == 1 or index == 5 then
			h = node:geth() / 2 - 200
			w = node:getw() / 2 + (index == 1 and -100 or 100)
		else
			h = node:geth() / 2 - 135 - 40 * (index - 1)
			w = node:getw() / 2
		end

		if index == 1 then
			local value
			local btn = an.newBtn(res.gettex2("pic/login/tab1.png"), function()
				cleanup2(index)
			end, {
				pressImage = res.gettex2("pic/login/tab2.png")
			}):pos(w, h):addto(node)

			if not g_data.player.smallExit then
				btn:setTouchEnabled(false)

				local size = cc.LayerColor:create(cc.c4b(0, 0, 0, 180)):anchor(0, 0):pos(0, 0):addto(btn):size(btn:getContentSize().width, btn:getContentSize().height)
				local count = 0

				size:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
					count = count + 2

					if count > 100 then
						btn:setTouchEnabled(true)
						size:stopAllActions()
						size:removeSelf()
					else
						size:pos(0, 0):size(btn:getContentSize().width, btn:getContentSize().height * (1 - count / 100))
					end
				end))))
			end
		elseif index == 5 then
			an.newBtn(res.gettex2("pic/login/tab9.png"), function()
				self.returnBtn = true

				cleanup2(index)
			end, {
				pressImage = res.gettex2("pic/login/tab10.png")
			}):pos(w, h):addto(node)
		else
			an.newBtn(res.gettex2("pic/login/tab" .. 2 * index - 1 .. ".png"), function()
				cleanup2(index)
			end, {
				pressImage = res.gettex2("pic/login/tab" .. 2 * index .. ".png")
			}):pos(w, h):addto(node)
		end
	end

	local function updateVisible(self2)
		sound.playSound("104")

		if not self.roles[self2] or self2 == g_data.select.selectIndex then
			return
		end

		sound.playSound("101")

		for roleId, role in pairs(self.roles) do
			if roleId == g_data.select.selectIndex then
				role.model:setState("unselected")
			elseif roleId == self2 then
				role.model:setState("selected")
			end
		end

		g_data.select:setSelectIndex(self2)
	end

	for index2 = 1, 2 do
		an.newBtn(res.getuitex(1, 66), function()
			updateVisible((self.pageIdx - 1) * 2 + index2)
		end, {
			pressShow = true
		}):pos(172 + (index2 - 1) * 551, 130):addto(node)
	end

	local function updateVisible2(self2)
		local value = math.ceil(#g_data.select.roles / 2)

		if self2 == 1 then
			self.pageIdx = self.pageIdx - 1 > 0 and self.pageIdx - 1 or value
		else
			self.pageIdx = value >= self.pageIdx + 1 and self.pageIdx + 1 or 1
		end

		self:getRoleListSuccess()
	end

	self.pageIdx = math.ceil(g_data.select.selectIndex / 2)
	self.pageBtn = {}

	for index3 = 1, 2 do
		self.pageBtn[index3] = an.newBtn(res.getuitex(3, 401 + (index3 - 1) * 2), function()
			updateVisible2(index3)
		end, {
			pressImage = res.getuitex(3, 402 + (index3 - 1) * 2)
		}):addTo(node):pos(node:getw() / 2 + 3, 400 - (index3 - 1) * 60)

		self.pageBtn[index3]:setVisible(#g_data.select.roles > 2)
	end

	sound.playMusic("main_theme", true)
	net.add(self)
	self:getRoleListSuccess()

	if g_data.login.queue then
		self:queueUp(g_data.login.queue.pos, g_data.login.queue.cnt, g_data.login.queue.sec)
		g_data.login:setQueueData()
	end
end

function items.getRoleListSuccess(self)
	for _, role in pairs(self.roles) do
		if role.layer then
			role.layer:removeSelf()
		end
	end

	self.roles = {}

	for index = 1, 2 do
		local value = (self.pageIdx - 1) * 2 + index

		if g_data.select.roles[value] then
			self:createPlayer(value, g_data.select.roles[value])
		end
	end

	self.area:setVisible(table.nums(self.roles) > 0)
end

function items.showCreate(self)
	for _, role in pairs(self.roles) do
		if role.model then
			role.model:setVisible(false)
		end
	end

	self.area:show()

	local node = display.newNode():size(display.width, display.height):addto(self):enableClick(function()
		return
	end)
	local value = table.nums(g_data.select.roles) % 2 == 0 and 1 or 2
	local ui = res.getui(1, 73):pos(x2[({
		2,
		1
	})[value]]()):addto(node):scaleX(value4):scaleY(value5)
	local background = display.newScale9Sprite("public/black.png", 141, 302, cc.size(142, 21)):addto(ui)
	local label = an.newInput(145, 300, 150, 30, 14, {
		donotMove = true,
		donotClip = true
	}):addTo(ui)
	local value26
	local value27
	local value28
	local items11 = {}

	local function updateVisible(self2)
		if value27 == self2 or self2 - 3 == value28 then
			return
		end

		if self2 > 3 then
			value28 = self2 - 3
		else
			value27 = self2
		end

		for index = 1, 3 do
			items11[index]:setIsSelect(value27 == index)
		end

		for index2 = 4, 5 do
			items11[index2]:setIsSelect(value28 == index2 - 3)
		end

		if value26 then
			value26:removeSelf()
		end

		if value27 and value28 then
			value26 = role.new(value27, value28):setState("new"):pos(x[value]()):addto(node)
		end
	end

	for index = 1, 5 do
		items11[index] = an.newBtn(res.getuitex(1, 74 + index - 1), function()
			sound.playSound("104")
			updateVisible(index)
		end, {
			pressBig = true,
			select = {
				res.getuitex(1, 55 + index - 1),
				manual = true
			}
		}):pos(69 + (index <= 3 and (index - 1) * 45 or (index - 3) * 45), index <= 3 and 242 or 170):addto(ui)
	end

	updateVisible(1)
	updateVisible(4)

	local function updateVisible2()
		self.area:setVisible(#self.roles > 0)
		node:removeSelf()
	end

	local data = json.decode(res.getfile("config/nameFirst.txt"))
	local data2 = json.decode(res.getfile("config/nameBoy.txt"))
	local data3 = json.decode(res.getfile("config/nameGirl.txt"))

	local function callback510()
		local value29 = data[math.random(#data)]
		local value262

		if value28 == 1 then
			value262 = data2[math.random(#data2)]
		else
			value262 = data3[math.random(#data3)]
		end

		label:setString(value29 .. value262)
	end

	an.newBtn(res.gettex2("pic/common/random.png"), function()
		sound.playSound("103")
		callback510()
	end, {
		pressBig = true
	}):pos(235, 305):add2(ui)
	an.newBtn(res.getuitex(1, 64), function(value29)
		sound.playSound("103")
		updateVisible2()
		self:getRoleListSuccess()
	end, {
		pressShow = true,
		size = {
			48,
			48
		}
	}):pos(256, 375):addto(ui)
	an.newBtn(res.getuitex(1, 62), function()
		sound.playSound("104")

		if label:getText() ~= "" then
			self.newRoleName = label:getText()

			net.send({
				CM_NEWCHR
			}, nil, getRecord("TMirCharInfo", {
				hair = 1,
				name = label:getText(),
				job = value27 - 1,
				sex = value28 - 1
			}))
			updateVisible2()
		else
			an.newMsgbox("提示角色名没输入", nil, {
				center = true
			})
		end
	end, {
		pressShow = true
	}):pos(140, 40):addto(ui)
end

function items.createPlayer(self, value, value26)
	self.roles[value] = {
		name = value26.name,
		work = value26.job + 1,
		sex = value26.sex + 1,
		level = value26.level
	}

	self:createInfo(value, self.roles[value])
end

function items.createInfo(layer, model, model2)
	model2.layer = display.newNode():addto(layer)
	model2.model = role.new(model2.work, model2.sex):setState(g_data.select.selectIndex == model and "normal" or "stone")

	model2.model:pos(x[(model - 1) % 2 + 1]()):addto(model2.layer)

	local x32, y = items7[(model - 1) % 2 + 1]()

	an.newLabel(model2.name, 18, 1):pos(x32, y):addto(model2.layer)
	an.newLabel(model2.level .. "", 16, 1):pos(x32, y - 31):addto(model2.layer)
	an.newLabel(({
		"战士",
		"法师",
		"道士"
	})[model2.work], 16, 1):pos(x32, y - 62):addto(model2.layer)
end

function items.receiveDelChrs(self, paramOwner, value26, value27)
	self.del_selectIdx = nil
	self.del_roles = {}

	local value = paramOwner.param
	local record = getRecord("TMirCharInfo")
	local record2 = getRecord("TMirCharinfoEx")
	local value28 = value27 >= record2:size() * value and record2 or record

	for index = 1, value do
		_, value26, value27 = net.record(value28, value26, value27)
		self.del_roles[#self.del_roles + 1] = {
			name = value28:get("name"),
			job = value28:get("job"),
			hair = value28:get("hair"),
			level = value28:get("level"),
			sex = value28:get("sex")
		}
	end
end

function items.getCurDelName(self)
	if self.del_selectIdx <= #self.del_roles then
		return self.del_roles[self.del_selectIdx].name
	end

	return ""
end

function items.ShowDelChrList(self)
	if #self.del_roles <= 0 then
		return
	end

	local node = display.newNode():size(display.width, display.height):addto(self):enableClick(function()
		return
	end)
	local ui = res.getui(3, 406):pos(x3()):addTo(node)
	local scroll = an.newScroll(24, 70, 222, 225, {}):addTo(ui)
	local items11 = {}
	local items12 = {}

	for del_selectIdx, del_role in ipairs(self.del_roles) do
		local node2 = display.newNode():addTo(scroll):size(scroll:getw(), 26):pos(0, scroll:geth() - 25 * del_selectIdx)

		items11[#items11 + 1] = node2

		local items13 = {
			an.newLabel(del_role.name, 14, 1):addTo(node2):pos(45, node2:geth() / 2):anchor(0.5, 0.5),
			an.newLabel(del_role.level, 14, 1):addTo(node2):pos(113, node2:geth() / 2):anchor(0.5, 0.5),
			an.newLabel(getJobStr(del_role.job), 14, 1):addTo(node2):pos(155, node2:geth() / 2):anchor(0.5, 0.5),
			an.newLabel(getSexStr(del_role.sex), 14, 1):addTo(node2):pos(200, node2:geth() / 2):anchor(0.5, 0.5)
		}

		function node2.setColor(self2, color)
			for _, item in ipairs(items13) do
				item:setColor(color)
			end
		end

		node2:enableClick(function()
			if self.del_selectIdx then
				items11[self.del_selectIdx]:setColor(display.COLOR_WHITE)
			end

			self.del_selectIdx = del_selectIdx

			node2:setColor(display.COLOR_RED)
		end, {
			support = "scroll"
		})
	end

	local function cleanup2()
		node:removeSelf()
	end

	an.newBtn(res.getuitex(1, 64), function(value)
		sound.playSound("103")
		cleanup2()
	end, {
		pressShow = true,
		size = {
			48,
			48
		}
	}):pos(256, 375):addto(ui)
	an.newBtn(res.getuitex(3, 407), function()
		if self.del_selectIdx then
			sound.playSound("104")

			if not IS_PLAYER_DEBUG and number <= #g_data.select.roles then
				an.newMsgbox("您的角色已满" .. number .. "个", nil, {
					center = true
				})

				return
			end

			net.send({
				CM_RECOVERCHR
			}, {
				self:getCurDelName()
			})
			cleanup2()
		end
	end, {
		pressImage = res.getuitex(3, 408)
	}):pos(140, 35):addto(ui)
end

function items.showSecurity(self)
	self.security = display.newNode():size(width, height2):anchor(0.5, 0.5):center():addTo(self):zorder(100)

	self.security:setTouchEnabled(true)
	self.security:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(value)
		return true
	end)

	local value_2 = res.get2("pic/panels/equip/validate.png"):addTo(self.security):pos(self.security:getw() / 2, self.security:geth() / 2):anchor(0.5, 0.5)

	value_2:enableClick(function()
		return
	end, {
		support = "drag"
	})

	local text172 = "请依次输入密保的第 "

	for index = 1, 4 do
		text172 = text172 .. g_data.security.loginBit[index] .. (index == 4 and "" or ",")
	end

	local value = text172 .. " 位"

	an.newLabel(value, 21, 1, {
		color = def.colors.labelYellow
	}):addTo(value_2):pos(value_2:getw() / 2, 170):anchor(0.5, 0.5)

	local label = an.newInput(60, 122, 235, 38, 4, {
		label = {
			"",
			20,
			1
		}
	}):addTo(value_2):anchor(0, 0.5)

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		os.exit(0)
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(value_2):pos(value_2:getw() - 6, value_2:geth() - 3):anchor(1, 1)
	an.newBtn(res.gettex2("pic/common/btn30.png"), function()
		sound.playSound("104")

		local string2 = label:getString()

		if string.len(string2) == 4 and tonumber(string2) then
			net.send({
				CM_SUBMIT_MIBAO,
				param = 1
			}, {
				string2
			})
		else
			an.newMsgbox("[失败] 输入密保格式有误，请重新输入。", function()
				label:setString("")
			end)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn31.png"),
		label = {
			"确定",
			20,
			1,
			{
				color = def.colors.btn30
			}
		}
	}):addTo(value_2):pos(value_2:getw() / 2 - 20, 36):anchor(1, 0.5)
	an.newBtn(res.gettex2("pic/common/btn30.png"), function()
		sound.playSound("104")
		label:setString("")
	end, {
		pressImage = res.gettex2("pic/common/btn31.png"),
		label = {
			"清除",
			20,
			1,
			{
				color = def.colors.btn30
			}
		}
	}):addTo(value_2):pos(value_2:getw() / 2 + 20, 36):anchor(0, 0.5)
end

function items.closeSecurity(self)
	if self.security then
		self.security:removeSelf()
	end
end

function items.ekeyErrorMsg(self, message)
	local text172

	if message == 13 then
		text172 = "通行证锁定"
	elseif message == 1001 then
		text172 = "网络状况不稳定，请输入\"盛大密宝\"用户" .. "服务卡上\"用户服务号\"的最后6位进行登录。如" .. "有疑问，请访问网站http://ekey.sdo.com，或" .. "与我们的客服热线（021-50504729）联系。"
	elseif message == 1003 then
		text172 = "您输入的密宝密码错误。请您访问网站https://ekey.sdo.com" .. "查询您的密宝资料，确定您绑定了此帐号。如有" .. "疑问，请和我们的客服热线（021-50504729）联系。"
	elseif message == 1006 then
		text172 = "您的密宝没有与任何帐号绑定。如有疑问，请访" .. "问网站http://ekey.sdo.com，或与我们的客服" .. "热线（021-50504729）联系。"
	elseif message == 1007 then
		text172 = "没有相应的绑定信息。如有疑问，请访问网站" .. "http://ekey.sdo.com，或与我们的客服热线" .. "（021-50504729）联系。"
	elseif message == 1011 then
		text172 = "请检查您的输入是否有问题，然后请重试一次。"
	elseif message == 1012 then
		text172 = "由于网络状况不稳定，请输入\"盛大密宝\"用户服" .. "务卡上\"用户服务号\"的最后6位进行登录。如有疑" .. "问，请访问网站http://ekey.sdo.com，或与我们" .. "的客服热线（021-50504729）联系。"
	elseif message == 1013 then
		text172 = "由于网络状况不稳定，请输入\"盛大密宝\"用户服" .. "务卡上\"用户服务号\"的最后6位进行登录。如有疑" .. "问，请访问网站http://ekey.sdo.com，或与我们" .. "的客服热线（021-50504729）联系。"
	elseif message == 1019 then
		text172 = "游戏编号错误"
	elseif message == 1020 then
		text172 = "游戏区号错误"
	elseif message == 1021 then
		text172 = "游戏帐号错误"
	elseif message == 1023 then
		text172 = "证件ID错误"
	elseif message == 5 or message == 1024 then
		text172 = "密宝时间漂移过大，请稍后再试一次或访问网站" .. "http://ekey.sdo.com校正时间"
	elseif message == 1025 then
		text172 = "预留口令错误"
	elseif message == 1027 then
		text172 = "修改服务号的次数超过规定"
	elseif message == 1028 then
		text172 = "等候处理"
	elseif message == 1000 then
		text172 = "密宝状态错误：您的密宝不能使用。如有疑问，" .. "请与我们的客服热线（021-50504729）联系。"
	elseif message == 20 then
		text172 = "密宝状态错误：您必须首先启用这个密宝，才能" .. "进行相应的操作。请访问http://ekey.sdo.com，" .. "进行相应的启用操作。如有疑问，请与我们的客" .. "服热线（021-50504729）联系。"
	elseif message == 40 then
		text172 = "密宝状态错误：您所操作的\"盛大密宝\"已被挂失，" .. "您选择的挂失后帐号状态为解除保护，帐号可以仅" .. "使用静态密码登录。如果您找回了您的密宝，请先" .. "访问http://ekey.sdo.com，进行解除挂失操作。如" .. "有疑问，请与我们的客服热线（021-50504729）联系。"
	elseif message == 50 then
		text172 = "密宝状态错误：您所操作的\"盛大密宝\"已被挂失，" .. "您选择的挂失后帐号状态为帐号锁定，不能访问。" .. "如果您找回了您的密宝，请先访问http://ekey.sdo.com，" .. "进行解除挂失操作。如有疑问，请与我们的客服热" .. "线（021-50504729）联系。"
	elseif message == 60 then
		text172 = "密宝状态错误：这个密宝无法使用。如有疑问，请" .. "访问网站http://ekey.sdo.com，或与我们的客服" .. "热线（021-50504729）联系。"
	elseif message == 70 then
		text172 = "密宝状态错误：这个密宝无法使用。如有疑问，请" .. "访问网站http://ekey.sdo.com，或与我们的客服" .. "热线（021-50504729）联系。"
	elseif message == 80 then
		text172 = "密宝状态错误：由于短时间多次输入错误密码，您" .. "的密宝已经被锁定，请稍后再试。如有疑问，请访" .. "问网站http://ekey.sdo.com，或与我们的客服热" .. "线（021-50504729）联系。"
	elseif message == 90 then
		text172 = "密宝状态错误：您所操作的密宝已经停用。如有疑" .. "问，请访问网站http://ekey.sdo.com，或与我们" .. "的客服热线（021-50504729）联系。"
	elseif message == 100 then
		text172 = "密宝状态错误：您使用的密宝已经超过了服务期，" .. "无法使用。如有疑问，请访问网站http://ekey.sdo.com，" .. "或与我们的客服热线（021-50504729）联系。"
	elseif message == 110 then
		text172 = "密宝状态错误：您所申请操作的密宝已经被新的密" .. "宝替换，请使用新的密宝进行相应操作。如有疑问，" .. "请访问网站http://ekey.sdo.com，或与我们的客" .. "服热线（021-50504729）联系。"
	else
		text172 = message == 3 and "因为短时间内多次输入错误密码或其它原因，暂时被禁止登录" or "未知密宝验证错误[" .. message .. "]"
	end

	return text172
end

function items.reconectFuc(self, info)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info .. "\n确定重连?", function(reconnectBox)
			if reconnectBox == 0 then
				value2.gotoLogin({
					logout = true
				})
			elseif reconnectBox == 1 then
				self.reconnect = true
				g_data.login.reconnectState = true

				scheduler.performWithDelayGlobal(function()
					net.connect(g_data.login.recIP, g_data.login.recPort, self, g_data.login.recSession)
				end, 0)
			end

			self.reconnectBox = nil
		end, {
			center = true,
			hasCancel = true
		})
	end
end

function items.onLoseConnect(self)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	print("scene:onLoseConnect")

	self.reconnectBox = self:reconectFuc("网络连接已断开!")
end

function items.onNetworkStateChange(self, currentState)
	local isHostNameReachable = network.isHostNameReachable("www.baidu.com")

	if not tolua.isnull(self.reconnectBox) then
		if isHostNameReachable then
			self.reconnectBox:removeSelf()

			self.reconnectBox = nil
		else
			return
		end
	end

	if isHostNameReachable then
		self:reconectFuc("切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "蜂窝网络"))
	end
end

function items.queueUp(self, value, value26, value28)
	if value == 0 then
		if self.layer then
			self.layer:removeSelf()

			self.layer = nil
		end

		return
	end

	if not self.layer then
		self.layer = display.newNode():addTo(self):size(display.width, display.height):setTouchEnabled(true)

		self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
			return
		end)
	end

	local queueUpTipOwner = self.layer
	local text172 = "您排在第" .. value .. "位"
	local value27 = value28 == 0 and "正在估算..." or "预计等待" .. (value28 > 60 and math.ceil(value28 / 60) .. "分钟" or value28 .. "秒")

	if not queueUpTipOwner.queueUpTip then
		local queueUpTip = res.get2("pic/common/msgbox.png"):addTo(queueUpTipOwner):pos(display.cx, display.cy)

		queueUpTip:setTouchEnabled(true)
		queueUpTip:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
			return
		end)
		res.get2("pic/login/queue.png"):addTo(queueUpTip):pos(queueUpTip:getw() / 2, queueUpTip:geth() - 6):anchor(0.5, 1)

		local function updateVisible()
			net.send({
				CM_SELCHR_EXIT
			})
		end

		an.newBtn(res.gettex2("pic/common/close10.png"), updateVisible, {
			pressImage = res.gettex2("pic/common/close11.png")
		}):addTo(queueUpTip):pos(queueUpTip:getw() - 8, queueUpTip:geth() - 5):anchor(1, 1)
		an.newBtn(res.gettex2("pic/common/btn20.png"), updateVisible, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/common/cancel.png")
		}):addTo(queueUpTip):pos(queueUpTip:getw() / 2, 30):anchor(0.5, 0.5)
		an.newLabel("服务器爆满需要排队", 20, 1):addTo(queueUpTip):pos(queueUpTip:getw() / 2, 190):anchor(0.5, 0.5)

		queueUpTip.pos = an.newLabel(text172, 20, 1):addTo(queueUpTip):pos(queueUpTip:getw() / 2, 150):anchor(0.5, 0.5)
		queueUpTip.wait = an.newLabel(value27, 20, 1):addTo(queueUpTip):pos(queueUpTip:getw() / 2, 110):anchor(0.5, 0.5)
		queueUpTipOwner.queueUpTip = queueUpTip
	else
		queueUpTipOwner.queueUpTip.pos:setText(text172)
		queueUpTipOwner.queueUpTip.wait:setText(value27)
	end
end

function items.socketEvent(self, data, status)
	if status == 3 then
		if self.returnBtn then
			return
		end

		self:reconectFuc(self.reconnect and "连接超时中断，重连失败" or "与服务器断开连接")
	elseif status == 2 then
		self:reconectFuc("连接服务器失败，请检查网络并稍后再试")
	end
end

function items.processMsg(self, msg, buf, bufLen)
	if not msg then
		return
	end

	local function updateVisible(self2, value)
		an.newMsgbox(self2, value, {
			center = true
		})
	end

	local value = msg.ident

	if SM_NEWCHR == value then
		if msg.param == 2 then
			updateVisible("这个名字已存在")
		elseif msg.param == 3 then
			updateVisible("你最多只能为一个帐号设置2个角色")
		elseif msg.param == 4 then
			updateVisible("角色创建失败\n角色名中不能包含特殊字符,只允许数字、英文和简体汉字字符。且最少为两个汉字或者4个英文，数字")
		elseif msg.param == 5 then
			updateVisible("你所创建的角色总数已达上限")
		elseif msg.param == 6 then
			updateVisible("跨服申请中，无法新建、删除、恢复角色")
		elseif msg.param == 7 then
			updateVisible("跨服不允许新建、删除、恢复角色")
		end

		self:getRoleListSuccess()
	elseif SM_CHR_LIST == value then
		if g_data.login.reconnectState then
			g_data.select:receiveChrs(msg, buf, bufLen)

			g_data.login.roleInfo = {
				msg = msg,
				buf = buf,
				bufLen = bufLen
			}
		elseif msg.recog == 1 then
			g_data.select:receiveChrs(msg, buf, bufLen)

			self.pageIdx = math.ceil(g_data.select.selectIndex / 2)

			self.pageBtn[1]:setVisible(#g_data.select.roles > 2)
			self.pageBtn[2]:setVisible(#g_data.select.roles > 2)
			self:getRoleListSuccess()
		end
	elseif SM_DELCHR == value then
		if msg.param == 0 then
			updateVisible("删除角色失败")
		elseif msg.param == 2 then
			updateVisible("一天内只能删除" .. number .. "个角色")
		elseif msg.param == 6 then
			updateVisible("跨服申请中，无法新建、删除、恢复角色")
		elseif msg.param == 7 then
			updateVisible("跨服不允许新建、删除、恢复角色")
		end
	elseif SM_SELCHR == value then
		if msg.param == 1 then
			print(g_data.select:getCurName(), msg.param)
			audio.stopMusic(true)
			net.remove(self)
			g_data.setting.init(g_data.select:getCurName())

			if g_data.areaChange then
				g_data.areaChange = nil

				game.gotoscene("main", nil, "fade", 0.5, display.COLOR_BLACK)
			else
				game.gotoscene("notice", nil, "fade", 0.5, display.COLOR_BLACK)
			end
		elseif msg.param == 2 then
			updateVisible("客户端版本错误")
		elseif msg.param == 3 then
			updateVisible("你没有这个角色")
		elseif msg.param == 4 then
			updateVisible("角色已被删除")
		elseif msg.param == 5 then
			updateVisible("角色数据读取失败，请稍候再试")
		elseif msg.param == 6 then
			updateVisible("角色已锁定")
		else
			updateVisible("你选择的服务器用户满员")
		end
	elseif SM_QUERYDELCHR == value then
		if msg.param > 0 then
			self:receiveDelChrs(msg, buf, bufLen)
			self:ShowDelChrList()
		else
			updateVisible("没有找到被删除的角色")
		end
	elseif SM_RECOVERCHR == value then
		if msg.param == 2 then
			updateVisible("角色并未被删除")
		elseif msg.param == 3 then
			updateVisible("你最多只能为一个帐号设置2个角色")
		elseif msg.param == 4 then
			updateVisible("找不到需要恢复的角色")
		elseif msg.param == 6 then
			updateVisible("跨服申请中，无法新建、删除、恢复角色")
		elseif msg.param == 7 then
			updateVisible("跨服不允许新建、删除、恢复角色")
		end
	elseif SM_VAILDATE_PPWD == value then
		-- block empty
	elseif SM_ACK_TRANSFER_AREA == value then
		if bufLen - 1 == getRecordSize("TRetTransferAreaInfo") then
			local record = getRecord("TRetTransferAreaInfo")

			net.record(record, buf, bufLen)

			local value26 = ycFunction:band(record.param1, 255)
			local value27 = ycFunction:band(ycFunction:rshift(record.param1, 8), 255)
			local value28 = ycFunction:band(ycFunction:rshift(record.param1, 16), 255)
			local value29 = ycFunction:band(ycFunction:rshift(record.param1, 24), 255)
			local text172 = string.format("%d.%d.%d.%d", value26, value27, value28, value29)

			g_data.areaChange = true

			scheduler.performWithDelayGlobal(function()
				net.connect(text172, record.param2 .. "", self, record.param)
			end, 0)
		end
	elseif SM_OUTOFCONNECTION == value then
		self:reconectFuc("与服务器断开连接")
	elseif SM_SELCHR_EXIT == value then
		value2.gotoLogin({
			logout = false
		})
	elseif SM_LOGIN == value then
		net.send({
			CM_RECONNECT
		}, {
			g_data.reconnctID
		})
	elseif SM_LOGIN_AUTH == value then
		if msg.param == 2 then
			-- block empty
		elseif msg.param == 1 then
			local loginRet1 = getRecord("TLoginIdResult")
			local loginRet2 = getRecord("TLoginIdResult2")

			if bufLen > loginRet1:size() then
				net.record(loginRet2, buf, bufLen)

				g_data.reconnctID = loginRet2:get("reconnectID")
				g_data.login.loginRet2 = loginRet2
			else
				net.record(loginRet1, buf, bufLen)

				g_data.login.loginRet1 = loginRet1
			end
		end
	elseif SM_OUTOFCONNECTION == value then
		-- block empty
	elseif SM_OUTOFCONNECTION_KICKOUT == value then
		self:reconectFuc("已经被其他用户踢下线")
	elseif SM_RECONNECT == value then
		-- block empty
	elseif SM_LOGIN_ALREADY_ONLINE == value then
		if msg.recog == 1 then
			self.kickoutBox = an.newMsgbox("此账号目前在线，是否强行登录?", function(kickoutBox)
				if kickoutBox == 1 then
					game.gotoscene("reconnect", nil, "fade", 0.5, display.COLOR_BLACK)
				else
					value2.gotoLogin({
						logout = true
					})
				end

				self.kickoutBox = nil

				net.send({
					CM_LOGIN_ALREADY_ONLINE,
					param = kickoutBox == 1 and 1 or 0
				})
			end, {
				center = true,
				hasCancel = true
			})
		else
			scheduler.performWithDelayGlobal(function()
				game.gotoscene("reconnect", nil, "fade", 0.5, display.COLOR_BLACK)
			end, 0)
		end
	elseif SM_LOGIN_QUEUE == value then
		self:queueUp(msg.param, msg.tag, msg.series)
	elseif SM_SELCHR_ERR == value then
		an.newMsgbox("服务器维护中，请稍后再试", function()
			value2.gotoLogin({
				logout = true
			})
		end, {
			center = true
		})
	else
		return false
	end

	return true
end

return bzinit
