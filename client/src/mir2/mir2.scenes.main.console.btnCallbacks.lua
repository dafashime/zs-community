local common = import("..common.common")
local magic = import("..common.magic")
local helper = import("..common.helper.helper")
local btnCallbacks = class("btnCallbacks")

table.merge(btnCallbacks, {
	console
})

function btnCallbacks:ctor(console)
	self.console = console
end

function btnCallbacks:handle(btntype, ...)
	self["handle_" .. btntype](self, ...)
end

function btnCallbacks:handle_normal(btn)
	sound.playSound("103")

	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.key
	end

	if key == "btnChat" then
		main_scene.ui:togglePanel("chat")
	else
		if key == "btnHide" then
			local needHides = {
				"rocker",
				"hp",
				"exp",
				"chat",
				"btnChat"
			}

			local function has(key)
				for i, v in ipairs(needHides) do
					if v == key then
						return true
					end
				end
			end

			btn.isHide = not btn.isHide

			if btn.isHide then
				btn.btn:setTex(res.gettex2("pic/console/btn_show.png"))
				btn:run(cc.MoveTo:create(0.1, cc.p(btn.data.x, 21)))
			else
				btn.btn:setTex(res.gettex2("pic/console/btn_hide.png"))
				btn:run(cc.MoveTo:create(0.1, cc.p(btn.data.x, btn.data.y)))
			end

			for k, v in pairs(self.console.widgets) do
				if v ~= btn and v.config.class == "btnMove" or has(k) then
					local x, y = nil

					if v.data.btnpos then
						x, y = self.console:btnpos2pos(v.data.btnpos)
					else
						y = v.data.y
						x = v.data.x
					end

					if btn.isHide then
						v:runs({
							cc.MoveTo:create(0.1, cc.p(x, y + 50)),
							cc.MoveTo:create(0.1, cc.p(x, y - display.height))
						})
					else
						v:run(cc.MoveTo:create(0.1, cc.p(x, y)))
					end
				end
			end

			return
		end

		if key == "btnGroup" then
			self.console.controller:setQuickGroup()
			btn.btn:setIsSelect(self.console.controller.quickGroup)
		elseif key == "btnAutoRat" then
			if self.console.autoRat.enableRat then
				self.console.autoRat:stop()
			else
				self.console.autoRat:enable()
			end

			btn.btn:setIsSelect(self.console.autoRat.enableRat)
		end
	end
end

function btnCallbacks:handle_base(btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "attack" then
		local lock = self.console.controller.lock

		if lock.target.skill then
			local role = main_scene.ground.map:findRole(lock.target.skill)

			if role then
				lock:stop()
				lock:setAttackTarget(role)

				return
			end
		end

		if lock.target.select then
			local role = main_scene.ground.map:findRole(lock.target.select)

			if role then
				lock:setAttackTarget(role)

				return
			end
		end

		if lock.target.attack then
			local role = main_scene.ground.map:findRole(lock.target.select)

			if role and not role.die then
				return
			else
				lock:setAttackTarget()
			end
		end

		local role = main_scene.ground.map:findNearMon()

		if role then
			lock:setAttackTarget(role)
		else
			lock:setAttackTarget()
			main_scene.ui:tip("附近没有怪物.")
		end
	elseif key == "lock" then
		if not btn.looks then
			btn.looks = {}
		end

		local roles = {}

		for k, v in pairs(main_scene.ground.map.heros) do
			if not v.die and not v.isPlayer and not v.isDummy then
				roles[#roles + 1] = v
			end
		end

		for k, v in pairs(main_scene.ground.map.mons) do
			if not v.die and not v:isPolice() and not v.isDummy then
				roles[#roles + 1] = v
			end
		end

		table.sort(roles, function (a, b)
			return main_scene.ground.player:getDis(a) < main_scene.ground.player:getDis(b)
		end)

		local choose = nil

		for i, v in ipairs(roles) do
			if not btn.looks[v.roleid] then
				btn.looks[v.roleid] = true
				choose = v

				break
			end
		end

		if not choose then
			btn.looks = {}

			if #roles > 0 then
				btn.looks[roles[1].roleid] = true
				choose = roles[1]
			end
		end

		local lock = self.console.controller.lock

		lock:stop()

		if choose then
			lock:setSelectTarget(choose)
		else
			main_scene.ui:tip("附近没有人物或怪物.")
		end
	elseif key == "shift" then
		self.console.controller:toggleShift()

		if self.console.controller.openShift then
			self.console:call("lock", "stop")

			if self.console.controller.autoWa then
				self:handle("base", self.console:get("btnWa"))
			end
		end

		btn.btn:setIsSelect(self.console.controller.openShift)
	elseif key == "wa" then
		self.console.controller:toggleWa()

		if self.console.controller.autoWa then
			self.console:call("lock", "stop")

			if self.console.controller.openShift then
				self:handle("base", self.console:get("btnShift"))
			end
		end

		btn.btn:setIsSelect(self.console.controller.autoWa)
	elseif key == "back" then
		common.backHome()
	end
end

function btnCallbacks:handle_setting(btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.key
	end

	local enable, settingKey = nil

	if key == "btnHeroName" then
		g_data.setting.base.heroShowName = not g_data.setting.base.heroShowName
		enable = g_data.setting.base.heroShowName
		settingKey = "heroShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnNPCShowName" then
		g_data.setting.base.NPCShowName = not g_data.setting.base.NPCShowName
		enable = g_data.setting.base.NPCShowName
		settingKey = "NPCShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.npcs) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnPetShowName" then
		g_data.setting.base.petShowName = not g_data.setting.base.petShowName
		enable = g_data.setting.base.petShowName
		settingKey = "petShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setName(v.info.name.texts, true)
		end

		for k, v in pairs(map.mons) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnMonShowName" then
		g_data.setting.base.monShowName = not g_data.setting.base.monShowName
		enable = g_data.setting.base.monShowName
		settingKey = "monShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.mons) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnOnlyname" then
		g_data.setting.base.showNameOnly = not g_data.setting.base.showNameOnly
		enable = g_data.setting.base.showNameOnly
		settingKey = "showNameOnly"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setName(v.info.name.texts)
		end
	elseif key == "hiBlood" then
		g_data.setting.base.hiBlood = not g_data.setting.base.hiBlood
		enable = g_data.setting.base.hiBlood
		settingKey = "hiBlood"
	elseif key == "warningDura" then
		g_data.setting.base.warningDura = not g_data.setting.base.warningDura
		enable = g_data.setting.base.warningDura
		settingKey = "warningDura"
	elseif key == "showExpEnable" then
		g_data.setting.base.showExpEnable = not g_data.setting.base.showExpEnable
		enable = g_data.setting.base.showExpEnable
		settingKey = "showExpEnable"
	elseif key == "lockColor" then
		g_data.setting.base.lockColor = not g_data.setting.base.lockColor
		enable = g_data.setting.base.lockColor
		settingKey = "lockColor"
	elseif key == "btnTouchRun" then
		g_data.setting.base.touchRun = not g_data.setting.base.touchRun
		enable = g_data.setting.base.touchRun
		settingKey = "touchRun"

		self.console.controller:setTouchRun(enable)
	elseif key == "btnShowOutHP" then
		g_data.setting.base.showOutHP = not g_data.setting.base.showOutHP
		enable = g_data.setting.base.showOutHP
		settingKey = "showOutHP"
	elseif key == "btnSoundEnable" then
		g_data.setting.base.soundEnable = not g_data.setting.base.soundEnable
		enable = g_data.setting.base.soundEnable
		settingKey = "soundEnable"

		sound.setEnable(enable)
	elseif key == "btnHideCorpse" then
		g_data.setting.base.hideCorpse = not g_data.setting.base.hideCorpse
		enable = g_data.setting.base.hideCorpse
		settingKey = "hideCorpse"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v:uptSelfShow()
		end

		for k, v in pairs(map.mons) do
			v:uptSelfShow()
		end
	elseif key == "btnfirePeral" then
		g_data.setting.base.firePeral = not g_data.setting.base.firePeral
		enable = g_data.setting.base.firePeral
		settingKey = "firePeral"
	elseif key == "btnguild" then
		g_data.setting.base.guild = not g_data.setting.base.guild
		enable = g_data.setting.base.guild
		settingKey = "guild"
	elseif key == "btnquickexit" then
		g_data.setting.base.quickexit = not g_data.setting.base.quickexit
		enable = g_data.setting.base.quickexit
		settingKey = "quickexit"
	elseif key == "btnautoUnpack" then
		g_data.setting.base.autoUnpack = not g_data.setting.base.autoUnpack
		enable = g_data.setting.base.autoUnpack
		settingKey = "autoUnpack"
	elseif key == "btnAutoFire" then
		g_data.setting.job.autoFire = not g_data.setting.job.autoFire
		enable = g_data.setting.job.autoFire
		settingKey = "autoFire"
	elseif key == "btnAutoWide" then
		g_data.setting.job.autoWide = not g_data.setting.job.autoWide
		enable = g_data.setting.job.autoWide
		settingKey = "autoWide"
	elseif key == "btnAutoAllSpace" then
		g_data.setting.job.autoAllSpace = not g_data.setting.job.autoAllSpace
		enable = g_data.setting.job.autoAllSpace
		settingKey = "autoAllSpace"
	elseif key == "btnAutoSword" then
		g_data.setting.job.autoSword = not g_data.setting.job.autoSword
		enable = g_data.setting.job.autoSword
		settingKey = "autoSword"
	elseif key == "btnAutoSpace" then
		g_data.setting.job.autoSpace = not g_data.setting.job.autoSpace
		enable = g_data.setting.job.autoSpace
		settingKey = "autoSpace"
	elseif key == "btnAutoDun" then
		g_data.setting.job.autoDun = not g_data.setting.job.autoDun
		enable = g_data.setting.job.autoDun
		settingKey = "autoDun"
	elseif key == "btnautoDunHero" then
		g_data.setting.job.autoDunHero = not g_data.setting.job.autoDunHero
		enable = g_data.setting.job.autoDunHero
		settingKey = "autoDunHero"

		net.send({
			CM_HERO_CHGSTATE,
			param = 1,
			recog = enable and 1 or 0
		})
	elseif key == "btnAutoInvisible" then
		g_data.setting.job.autoInvisible = not g_data.setting.job.autoInvisible
		enable = g_data.setting.job.autoInvisible
		settingKey = "autoInvisible"
	elseif key == "btnAutoSkill" then
		g_data.setting.job.autoSkill.enable = not g_data.setting.job.autoSkill.enable
		enable = g_data.setting.job.autoSkill.enable
		settingKey = "autoSkill"
	elseif key == "btnAutoSpaceMove" then
		g_data.setting.autoRat.autoSpaceMove.enable = not g_data.setting.autoRat.autoSpaceMove.enable
		enable = g_data.setting.autoRat.autoSpaceMove.enable
		settingKey = "autoSpaceMove"
	elseif key == "btnNoPickUpItem" then
		g_data.setting.autoRat.noPickUpItem = not g_data.setting.autoRat.noPickUpItem
		enable = g_data.setting.autoRat.noPickUpItem
		settingKey = "btnNoPickUpItem"
	elseif key == "btnPickUpGood" then
		g_data.setting.autoRat.pickUpRatting = not g_data.setting.autoRat.pickUpRatting
		enable = g_data.setting.autoRat.pickUpRatting
		settingKey = "btnPickUpGood"
	elseif key == "btnIgnoreCripple" then
		g_data.setting.autoRat.ignoreCripple = not g_data.setting.autoRat.ignoreCripple
		enable = g_data.setting.autoRat.ignoreCripple
		settingKey = "btnIgnoreCripple"
	elseif key == "btnAutoRoar" then
		g_data.setting.autoRat.autoRoar.enable = not g_data.setting.autoRat.autoRoar.enable
		enable = g_data.setting.autoRat.autoRoar.enable
		settingKey = "btnAutoRoar"
	elseif key == "btnAtkMagic" then
		g_data.setting.autoRat.atkMagic.enable = not g_data.setting.autoRat.atkMagic.enable
		enable = g_data.setting.autoRat.atkMagic.enable
		settingKey = "btnAtkMagic"
	elseif key == "btnareaMagic" then
		g_data.setting.autoRat.areaMagic.enable = not g_data.setting.autoRat.areaMagic.enable
		enable = g_data.setting.autoRat.areaMagic.enable
		settingKey = "btnareaMagic"
	elseif key == "btnAutoPoison" then
		g_data.setting.autoRat.autoPoison = not g_data.setting.autoRat.autoPoison
		enable = g_data.setting.autoRat.autoPoison
		settingKey = "btnAutoPoison"
	elseif key == "btnAutoYoulingDun" then
		g_data.setting.job.autoYoulingDun = not g_data.setting.job.autoYoulingDun
		enable = g_data.setting.job.autoYoulingDun
		settingKey = "btnAutoYoulingDun"
	elseif key == "btnAutoZhanjiashu" then
		g_data.setting.job.autoZhanjiashu = not g_data.setting.job.autoZhanjiashu
		enable = g_data.setting.job.autoZhanjiashu
		settingKey = "btnAutoZhanjiashu"
	elseif key == "btnAutoPet" then
		g_data.setting.autoRat.autoPet.enable = not g_data.setting.autoRat.autoPet.enable
		enable = g_data.setting.autoRat.autoPet.enable
		settingKey = "btnAutoPet"
	elseif key == "btnAutoCure" then
		g_data.setting.autoRat.autoCure.enable = not g_data.setting.autoRat.autoCure.enable
		enable = g_data.setting.autoRat.autoCure.enable
		settingKey = "btnAutoCure"
	elseif key == "btnAutoCurePet" then
		g_data.setting.autoRat.autoCurePet.enable = not g_data.setting.autoRat.autoCurePet.enable
		enable = g_data.setting.autoRat.autoCurePet.enable
		settingKey = "btnAutoCurePet"
	end

	local btn = self.console:get(key)

	if btn then
		btn.btn:setIsSelect(enable)
	end

	if main_scene.ui.panels.setting and main_scene.ui.panels.setting.btns[settingKey] then
		if enable then
			main_scene.ui.panels.setting.btns[settingKey].btn:select()
		else
			main_scene.ui.panels.setting.btns[settingKey].btn:unselect()
		end
	end
end

function btnCallbacks:handle_cmd(btn)
	local function sendCmd(cmd)
		if g_data.client:checkLastTime("sendCmd", 0.5) then
			g_data.client:setLastTime("sendCmd", true)
			net.send({
				CM_SAY
			}, {
				cmd
			})
		else
			main_scene.ui:tip("你操作太快了!!!")
		end
	end

	if btn.config.btnid == "chuansong" then
		local config = nil

		for i, v in ipairs(def.cmds.all) do
			if v[1] == "@传送" then
				config = v

				break
			end
		end

		if config then
			local msgbox = nil
			msgbox = an.newMsgbox(config[1] .. "\n" .. config[4], function ()
				if msgbox.input:getString() == "" then
					return
				end

				if g_data.client:checkLastTime("sendCmd", 0.5) then
					g_data.client:setLastTime("sendCmd", true)
					net.send({
						CM_SAY
					}, {
						config[2] .. " " .. msgbox.input:getString()
					})
				else
					main_scene.ui:tip("你操作太快了!!!")
				end
			end, {
				disableScroll = true,
				input = 20
			})

			msgbox.input:setString("d5071")
			msgbox.input:startInput()
		end

		return
	end

	if btn.config.btnid == "qianlichuanyin" then
		-- Nothing
	elseif btn.config.btnid == "shuaxinbeibao" then
		-- Nothing
	elseif btn.config.btnid == "jujuesiliao" then
		sendCmd(def.cmds.get("@拒绝私聊"))
	elseif btn.config.btnid == "jinzhijiaoyi" then
		sendCmd(def.cmds.get("@禁止交易"))
	elseif btn.config.btnid == "shituchuansong" then
		sendCmd(def.cmds.get("@师徒传送"))
	elseif btn.config.btnid == "fuqichuansong" then
		sendCmd(def.cmds.get("@夫妻传送"))
	end
end

function btnCallbacks:handle_panel(btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "bag" then
		main_scene.ui:togglePanel("bag")
	elseif key == "equip" then
		main_scene.ui:togglePanel("equip")
	elseif key == "skill" then
		main_scene.ui:togglePanel("equip", {
			page = "skill"
		})
	elseif key == "deal" then
		if g_data.client:checkLastTime("deal", 3) then
			g_data.client:setLastTime("deal", true)
			net.send({
				CM_DEALTRY
			}, {
				""
			})
		end
	elseif key == "group" then
		main_scene.ui:togglePanel("group")
	elseif key == "relation" then
		main_scene.ui:togglePanel("relation")
	elseif key == "guild" then
		if g_data.client:checkLastTime("guild", 2) then
			g_data.client:setLastTime("guild", true)
			main_scene.ui:showPanel("guild", "")
		else
			an.newMsgbox("你操作太快了, 请稍候再试.")
		end
	elseif key == "shop" then
		main_scene.ui:togglePanel("shop")
	elseif key == "top" then
		main_scene.ui:togglePanel("top")
	elseif key == "stall" then
		if main_scene.ui.panels.stallOther then
			main_scene.ui:hidePanel("stallOther")
			net.send({
				CM_QUERY_STALL
			}, nil, {
				{
					"ID",
					g_data.stall.id
				}
			})
		elseif main_scene.ui.panels.stall then
			main_scene.ui:hidePanel("stall")
		else
			net.send({
				CM_QUERY_STALL
			}, nil, {
				{
					"ID",
					g_data.stall.id
				}
			})
		end
	elseif key == "mail" then
		main_scene.ui:togglePanel("mail")
	elseif key == "voice" then
		main_scene.ui:togglePanel("voice")
	elseif key == "setting" then
		main_scene.ui:togglePanel("setting")
	elseif key == "link" then
		device.openURL(g_data.login.shopUrl)
	end
end

function btnCallbacks:handle_custom(btn)
	if not btn.makeIndex then
		return
	end

	local _, data = g_data.bag:getItem(btn.makeIndex)
	local bagData, equipData, eatMsg, takeonMsg = nil
	local isPlayer = true
	local source = nil

	if btn.source == "bag" then
		source = main_scene.ui.panels.bag
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	elseif btn.source == "heroBag" then
		source = main_scene.ui.panels.heroBag
		equipData = g_data.heroEquip
		bagData = g_data.heroBag
		takeonMsg = CM_HERO_TAKEON
		eatMsg = CM_HERO_EAT
	end

	local where = getTakeOnPosition(data.getVar("stdMode"))

	if where then
		if U_RINGL == where or U_RINGR == where then
			if equipIdx then
				where = equipIdx
			elseif not equipData.items[U_RINGL] then
				where = U_RINGL
			elseif not equipData.items[U_RINGR] then
				where = U_RINGR
			elseif equipData.lastTakeOnRingIsLeft then
				equipData.lastTakeOnRingIsLeft = false
				where = U_RINGR
			else
				equipData.lastTakeOnRingIsLeft = true
				where = U_RINGL
			end
		elseif U_ARMRINGL == where or U_ARMRINGR == where then
			if equipIdx then
				where = equipIdx
			elseif not equipData.items[U_ARMRINGL] then
				where = U_ARMRINGL
			elseif not equipData.items[U_ARMRINGR] then
				where = U_ARMRINGR
			elseif equipData.lastTakeOnBraceletIsLeft then
				equipData.lastTakeOnBraceletIsLeft = false
				where = U_ARMRINGR
			else
				equipData.lastTakeOnBraceletIsLeft = true
				where = U_ARMRINGL
			end
		end

		if self:canUseEquip(data, bagData, isPlayer) and bagData:use("take", data:get("makeIndex"), {
			where = where
		}) then
			net.send({
				takeonMsg,
				recog = data:get("makeIndex"),
				param = where
			}, {
				data.getVar("name")
			})

			if source then
				source:delItem(data:get("makeIndex"))
			end
		end
	else
		if equipIdx then
			return
		end

		if not self:canUseEquip(data, bagData, isPlayer) then
			return
		end

		local function use()
			if bagData:use("eat", data:get("makeIndex")) then
				net.send({
					eatMsg,
					recog = data:get("makeIndex")
				})

				if source then
					source:delItem(data:get("makeIndex"))
				end
			end
		end

		if data.getVar("stdMode") == 4 then
			an.newMsgbox(string.format("[%s] 你想要开始训练吗? ", data.getVar("name")), function (isOk)
				if isOk == 1 then
					use()
				end
			end, {
				center = true,
				hasCancel = true
			}):setName("msgBoxLearnSkill")
		elseif data.getVar("stdMode") == 47 then
			if data.getVar("name") == "传情烟花" then
				local msgbox = nil
				msgbox = an.newMsgbox("请输入传情烟花文字", function (idx)
					if idx == 2 then
						if msgbox.input:getString() == "" then
							return
						end

						net.send({
							CM_YANHUA_TEXT,
							recog = data:get("makeIndex")
						}, {
							msgbox.input:getString()
						})
					end
				end, {
					disableScroll = true,
					input = 20,
					btnTexts = {
						"关闭",
						"确定"
					}
				})
			elseif data.getVar("name") == "金条" then
				an.newMsgbox("确定使用一根金条兑换998000金币吗？", function ()
					if g_data.bag:use("eat", data:get("makeIndex"), {
						quick = false
					}) then
						net.send({
							eatMsg,
							recog = data:get("makeIndex")
						})

						if source then
							source:delItem(data:get("makeIndex"))
						end
					end
				end, {
					center = true
				})
			end
		else
			use()
		end
	end
end

function btnCallbacks:canUseEquip(item, dataFrom, isPlayer)
	if not item then
		return
	end

	local function chargeNeed(info, value)
		if value then
			return true
		else
			common.addMsg(info, display.COLOR_RED, display.COLOR_WHITE, true)
		end
	end

	local playerData = isPlayer and g_data.player or g_data.hero
	local need = item.getVar("need")
	local needLevel = item.getVar("needLevel")
	local where = getTakeOnPosition(item.getVar("stdMode"))

	if where then
		local ret = true

		if need == 0 then
			ret = chargeNeed("等级不够", needLevel <= playerData.ability:get("level"))
		elseif need == 1 then
			ret = chargeNeed("攻击力不足", needLevel <= g_data.player.ability:get("maxDC"))
		elseif need == 2 then
			ret = chargeNeed("魔法力不足", needLevel <= g_data.player.ability:get("maxMC"))
		elseif need == 3 then
			ret = chargeNeed("精神力不足", needLevel <= g_data.player.ability:get("maxSC"))
		elseif need == 5 and isPlayer then
			ret = chargeNeed("你的声望不足，不能佩戴", g_data.player.ability3:get("prestige") <= needLevel)
		end

		if not ret then
			return
		end
	end

	if playerData.ability:get("maxHandWeight") < item.getVar("weight") then
		common.addMsg("太重了", display.COLOR_RED, display.COLOR_WHITE, true)

		return false
	end

	if item.getVar("stdMode") == 4 then
		local shape = item.getVar("shape") or 0

		if shape ~= playerData.job then
			common.addMsg("不能学习其他职业技能书", display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end

		local needLevel = math.modf(Word(item.getVar("duraMax")))

		if playerData.ability:get("level") < needLevel then
			common.addMsg("等级不够", display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end
	elseif item.getVar("stdMode") ~= 5 and item.getVar("stdMode") ~= 6 and item.getVar("weight") > playerData.ability:get("maxWearWeight") - playerData.ability:get("wearWeight") then
		common.addMsg("负重不够", display.COLOR_RED, display.COLOR_WHITE, true)

		return false
	end

	return true
end

function btnCallbacks:handle_prop(btn)
	if not btn.makeIndex then
		return
	end

	local _, data = g_data.bag:getItem(btn.makeIndex)

	if not data then
		return
	end

	if g_data.bag:use("eat", data:get("makeIndex"), {
		quick = true
	}) then
		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
		end

		sound.play("item", data)
		net.send({
			CM_EAT,
			recog = data:get("makeIndex")
		}, {
			data.getVar("name")
		})
	end
end

function btnCallbacks:handle_hero(btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "call" then
		if g_data.hero.roleid == 0 then
			net.send({
				CM_HERO_LOGON,
				recog = main_scene.ground.player.roleid
			})
		else
			net.send({
				CM_HERO_LOGOUT,
				recog = g_data.hero.roleid
			})
		end

		return
	end

	if g_data.hero.roleid == 0 then
		main_scene.ui:tip("您还未召唤出英雄!")

		return
	end

	if key == "bag" then
		main_scene.ui:togglePanel("heroBag")
	elseif key == "equip" then
		main_scene.ui:togglePanel("heroEquip")
	elseif key == "skill" then
		net.send({
			CM_HERO_POWERUP
		})
	elseif key == "mode" then
		net.send({
			CM_SAY
		}, {
			"@RestHero"
		})
	elseif key == "lock" then
		self.console.controller:closeHeroGuard()
		self.console.controller:toggleHeroLock()
		btn.btn:setIsSelect(self.console.controller.heroLock)

		local lock = self.console.controller.lock

		if lock.target.skill then
			if g_data.client:checkLastTime("heroLock", 1) then
				g_data.client:setLastTime("heroLock", true)
				g_data.hero:setNoTarget(false)
				net.send({
					CM_HERO_APPTARG,
					recog = lock.target.skill
				})
			end

			return
		end

		if lock.target.select then
			if g_data.client:checkLastTime("heroLock", 1) then
				g_data.client:setLastTime("heroLock", true)
				g_data.hero:setNoTarget(false)
				net.send({
					CM_HERO_APPTARG,
					recog = lock.target.select
				})
			end

			return
		end

		if lock.target.attack then
			if g_data.client:checkLastTime("heroLock", 1) then
				g_data.client:setLastTime("heroLock", true)
				g_data.hero:setNoTarget(false)
				net.send({
					CM_HERO_APPTARG,
					recog = lock.target.attack
				})
			end

			return
		end

		g_data.hero:setNoTarget(true)
	elseif key == "guard" then
		self.console.controller:closeHeroLock()
		self.console.controller:toggleHeroGuard(btn)
		btn.btn:setIsSelect(self.console.controller.heroGuard)
	end
end

function btnCallbacks:handle_skill(btn, skillData)
	local player = main_scene.ground.map.player

	if not player then
		return
	end

	if def.role.stateHas(player.state, "stPoisonStone") then
		return
	end

	local magicID, data = nil

	if type(btn) == "number" then
		magicID = btn
		data = skillData
	else
		magicID = btn.data.magicId
		data = btn.skillData
	end

	magicID = tonumber(magicID)

	if not magicID or not data then
		return
	end

	if checkExist(magicID, 3, 4, 7, 67) then
		return
	end

	if g_data.player.ability:get("MP") < data:get("needMp") then
		main_scene.ui:tip("没有足够的魔法点数!!")

		return
	end

	local config = def.magic.getMagicConfigByUid(magicID)

	if not config then
		return
	end

	if config.type == "immediate" then
		local config = def.role.dir["_" .. player.dir]

		self.console.controller:useMagic(player.x + config[1], player.y + config[2], player.dir, data)

		return
	end

	local effectType = data:get("effectType")

	if effectType == 0 then
		if magicID == 26 and not g_data.client:checkLastTime("fire", 10) then
			return
		end

		if magicID == 27 and not g_data.client:checkLastTime("rush", 3.1) then
			return
		end

		if not g_data.client:checkLastTime("spell", 0.5) then
			return
		end

		local x = player.x
		local y = player.y

		if magicID == 27 then
			g_data.client:setLastTime("rush", true)

			y = 0
			x = player.dir
		end

		g_data.client:setLastTime("spell", true)
		net.send({
			CM_SPELL,
			param = x,
			tag = y,
			series = data:get("magicId")
		})
	else
		self.console.skills:select(tostring(magicID))

		if not WIN32_OPERATE then
			self.console:call("lock", "useSkill", data, config)
			self.console.controller:useMagic()
		end
	end
end

return btnCallbacks
