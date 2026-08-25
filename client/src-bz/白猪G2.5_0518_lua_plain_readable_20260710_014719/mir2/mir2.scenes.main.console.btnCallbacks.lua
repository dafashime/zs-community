local common = import("..common.common")
local magic = import("..common.magic")
local helper = import("..common.helper.helper")
local btnCallbacks = class("btnCallbacks")
local cc2 = require("mir2.cc")

table.merge(btnCallbacks, {
	console
})

function btnCallbacks:ctor(console)
	self.console = console
	g_data.setting.base.autoatk = false
end

function btnCallbacks:handle(btntype, ...)
	self["handle_" .. btntype](self, ...)
end

function btnCallbacks:handle_normal(btn)
	sound.playSound("103")

	local key

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.key
	end

	if key == "btnChat" then
		main_scene.ui:togglePanel("chat")
	elseif key == "back" then
		common.backHome()
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
				btn.run(btn, cc.MoveTo:create(0.1, cc.p(btn.data.x, 21)))
			else
				btn.btn:setTex(res.gettex2("pic/console/btn_hide.png"))
				btn.run(btn, cc.MoveTo:create(0.1, cc.p(btn.data.x, btn.data.y)))
			end

			for k, v in pairs(self.console.widgets) do
				if v ~= btn and v.config.class == "btnMove" or has(k) then
					local x
					local y

					if v.data.btnpos then
						x, y = self.console:btnpos2pos(v.data.btnpos)
					else
						y = v.data.y
						x = v.data.x
					end

					if btn.isHide then
						v.runs(v, {
							cc.MoveTo:create(0.1, cc.p(x, y + 50)),
							cc.MoveTo:create(0.1, cc.p(x, y - display.height))
						})
					else
						v.run(v, cc.MoveTo:create(0.1, cc.p(x, y)))
					end
				end
			end

			return
		end

		if key == "btnGroup" then
			self.console.controller:setQuickGroup()
			btn.btn:setIsSelect(self.console.controller.quickGroup)
		elseif key == "btnAutoRat" then
			if cc2.isAutoXiama() then
				return
			end

			if self.console.autoRat.enableRat then
				self.console.autoRat:stop()
			elseif def.enableRatOnServer then
				def.role.call("@onEnableRat")

				return
			else
				self.console.autoRat:enable()
			end

			btn.btn:setIsSelect(self.console.autoRat.enableRat)
		end
	end
end

function btnCallbacks:handle_base(btn)
	local key

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "attack" then
		if cc2.isAutoXiama() then
			return
		end

		local value = self.console.controller.lock

		value.attackAny(value)
	elseif key == "player" then
		self.handle_lockplayer(self)
	elseif key == "mon" then
		self.handle_lockmon(self)
	elseif key == "lock" then
		if cc2.isAutoXiama() then
			return
		end

		if not btn.looks then
			btn.looks = {}
		end

		local roles = {}

		for k, v in pairs(main_scene.ground.map.heros) do
			if not v.die and not v.isPlayer and not v.isDummy then
				roles[#roles + 1] = v
			end
		end

		for k2, v2 in pairs(main_scene.ground.map.mons) do
			if not v2.die and not v2.isPolice(v2) and not v2.isDummy then
				roles[#roles + 1] = v2
			end
		end

		table.sort(roles, function(a, b)
			return main_scene.ground.player:getDis(a) < main_scene.ground.player:getDis(b)
		end)

		local choose

		for i, v3 in ipairs(roles) do
			if not btn.looks[v3.roleid] then
				btn.looks[v3.roleid] = true
				choose = v3

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

		lock.stop(lock)

		if choose then
			lock.setSelectTarget(lock, choose)
		else
			main_scene.ui:tip(CS_NOBODY)
		end
	elseif key == "shift" then
		if cc2.isAutoXiama() then
			return
		end

		self.console.controller:toggleShift()

		if self.console.controller.openShift then
			self.console:call("lock", "stop")

			if self.console.controller.autoWa then
				self.handle(self, "base", self.console:get("btnWa"))
			end
		end

		btn.btn:setIsSelect(self.console.controller.openShift)
	elseif key == "wa" then
		if cc2.isAutoXiama() then
			return
		end

		self.console.controller:toggleWa()

		if self.console.controller.autoWa then
			self.console:call("lock", "stop")

			if self.console.controller.openShift then
				self.handle(self, "base", self.console:get("btnShift"))
			end
		end

		btn.btn:setIsSelect(self.console.controller.autoWa)
	elseif key == "back" then
		common.backHome()
	elseif key == "shiqu" then
		sound.playSound("103")

		if not btn or type(btn) == "string" then
			btn = self.console:get("btnShiqu")
		end

		g_data.setting.autoRat.noAutoPickup = not g_data.setting.autoRat.noAutoPickup

		if btn and btn.btn then
			btn.btn:setIsSelect(not g_data.setting.autoRat.noAutoPickup)
		end

		if g_data.setting.autoRat.noAutoPickup then
			def.role.call("@autoPick~0")
		else
			def.role.call("@autoPick~1")
		end
	elseif key == "horse" then
		sound.playSound("103")
		cc2.switchHorse()
	elseif key == "pet" then
		net.send({
			CM_SAY
		}, {
			"@b"
		})
		net.send({
			CM_SAY
		}, {
			"@rest"
		})
	end
end

function btnCallbacks:handle_setting(btn, value)
	local key

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.key
	end

	local enable
	local settingKey

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

		local map2 = main_scene.ground.map

		for k2, v2 in pairs(map2.npcs) do
			v2.info:setName(v2.info.name.texts, true)
		end
	elseif key == "btnPetShowName" then
		g_data.setting.base.petShowName = not g_data.setting.base.petShowName
		enable = g_data.setting.base.petShowName
		settingKey = "petShowName"

		local map3 = main_scene.ground.map

		for k3, v3 in pairs(map3.heros) do
			v3.info:setName(v3.info.name.texts, true)
		end

		for k4, v4 in pairs(map3.mons) do
			v4.info:setName(v4.info.name.texts, true)
		end
	elseif key == "btnMonShowName" then
		g_data.setting.base.monShowName = not g_data.setting.base.monShowName
		enable = g_data.setting.base.monShowName
		settingKey = "monShowName"

		local map4 = main_scene.ground.map

		for k5, v5 in pairs(map4.mons) do
			v5.info:setName(v5.info.name.texts, true)
		end
	elseif key == "btnOnlyname" then
		g_data.setting.base.showNameOnly = not g_data.setting.base.showNameOnly
		enable = g_data.setting.base.showNameOnly
		settingKey = "showNameOnly"

		local map5 = main_scene.ground.map

		for k6, v6 in pairs(map5.heros) do
			v6.info:setName(v6.info.name.texts)
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
	elseif key == "btnSingleRocker" then
		g_data.setting.base.singleRocker = not g_data.setting.base.singleRocker
		enable = g_data.setting.base.singleRocker
		settingKey = "singleRocker"

		main_scene.ui.console:call("rocker", "loadSpr")
	elseif key == "btnSoundEnable" then
		g_data.setting.base.soundEnable = not g_data.setting.base.soundEnable
		enable = g_data.setting.base.soundEnable
		settingKey = "soundEnable"

		sound.setEnable(enable)
	elseif key == "btnHideCorpse" then
		g_data.setting.base.hideCorpse = not g_data.setting.base.hideCorpse
		enable = g_data.setting.base.hideCorpse
		settingKey = "hideCorpse"

		local map6 = main_scene.ground.map

		for k7, v7 in pairs(map6.heros) do
			v7.uptSelfShow(v7)
		end

		for k8, v8 in pairs(map6.mons) do
			v8.uptSelfShow(v8)
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
	elseif key == "btnAutoPickupWhenAutorat" then
		g_data.setting.autoRat.autoPickupWhenAutorat = not g_data.setting.autoRat.autoPickupWhenAutorat
		enable = g_data.setting.autoRat.autoPickupWhenAutorat
		settingKey = "btnAutoPickupWhenAutorat"
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
	elseif key == "btnDefaultAtkMagic" then
		g_data.setting.autoRat.defaultAtkMagic.enable = not g_data.setting.autoRat.defaultAtkMagic.enable
		enable = g_data.setting.autoRat.defaultAtkMagic.enable
		settingKey = "btnDefaultAtkMagic"
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
	elseif key == "autoattack" then
		local value2 = self.console.controller.lock

		value2.autoAttack(value2, btn)
	elseif key == "btnHeroTitle" then
		g_data.setting.base.heroShowTitle = not g_data.setting.base.heroShowTitle
		enable = g_data.setting.base.heroShowTitle
		settingKey = "btnHeroTitle"

		local herosOwner = main_scene.ground.map

		for _, hero in pairs(herosOwner.heros) do
			hero.info:setName(hero.info.name.texts)
		end
	elseif value == "autoRat" then
		g_data.setting.autoRat[key] = not g_data.setting.autoRat[key]
		enable = g_data.setting.autoRat[key]
		settingKey = key
	else
		g_data.setting.job[key] = not g_data.setting.job[key]
		enable = g_data.setting.job[key]
		settingKey = key
	end

	local btn2 = self.console:get(key)

	if btn2 then
		btn2.btn:setIsSelect(enable)
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
			main_scene.ui:tip("背包测试!!!")
		end
	end

	if btn.config.btnid == "chuansong" then
		local config

		for i, v in ipairs(def.cmds.all) do
			if v[1] == "@传送" then
				config = v

				break
			end
		end

		if config then
			local msgbox

			msgbox = an.newMsgbox(config[1] .. "\n" .. config[4], function()
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
					main_scene.ui:tip(CS_OPTBUSY)
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

	if (btn.config.btnid ~= "qianlichuanyin" or false) and (btn.config.btnid ~= "shuaxinbeibao" or false) then
		if btn.config.btnid == "jujuesiliao" then
			sendCmd(def.cmds.get("@拒绝私聊"))
		elseif btn.config.btnid == "jinzhijiaoyi" then
			sendCmd(def.cmds.get("@禁止交易"))
		elseif btn.config.btnid == "shituchuansong" then
			sendCmd(def.cmds.get("@师徒传送"))
		elseif btn.config.btnid == "fuqichuansong" then
			sendCmd(def.cmds.get("@夫妻传送"))
		end
	end
end

function btnCallbacks:handle_panel(btn)
	local key

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
	elseif key == "fusion" then
		main_scene.ui:togglePanel("fusion")
	elseif key == "relation" then
		main_scene.ui:togglePanel("relation")
	elseif key == "guild" then
		if g_data.client:checkLastTime("guild", 2) then
			g_data.client:setLastTime("guild", true)
			main_scene.ui:showPanel("guild", "")
		else
			an.newMsgbox(CS_OPTBUSY)
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
		if def.role.mainsetting.closeczpanel then
			device.openURL(g_data.login.shopUrl)
		else
			main_scene.ui:togglePanel("charge")
		end
	elseif key == "player" then
		self.handle_lockplayer(self)
	elseif key == "mon" then
		self.handle_lockmon(self)
	elseif key == "btnHidebtn" then
		g_data.setting.base.hidebtnEnable = not g_data.setting.base.hidebtnEnable
		enable = g_data.setting.base.hidebtnEnable
		settingKey = "hidebtnEnable"

		local items = {}

		if def.role.mainsetting.hiddenablePanels then
			for _, hiddenablePanel in ipairs(def.role.mainsetting.hiddenablePanels) do
				table.insert(items, hiddenablePanel.key)
			end
		end

		local function callback(self)
			for _, item in ipairs(items) do
				if item == self then
					return true
				end
			end
		end

		for key2, widget in pairs(self.console.widgets) do
			if callback(key2) then
				local x
				local y

				if widget.data.btnpos then
					x, y = self.console:btnpos2pos(widget.data.btnpos)
				else
					y = widget.data.y
					x = widget.data.x
				end

				if enable then
					widget.runs(widget, {
						cc.MoveTo:create(0.1, cc.p(x - 50, y)),
						cc.MoveTo:create(0.1, cc.p(x + display.width, y))
					})
				else
					widget.run(widget, cc.MoveTo:create(0.1, cc.p(x, y)))
				end
			end
		end

		local response = self.console:get(key)

		if response then
			local x2
			local y2

			if response.data.btnpos then
				x2, y2 = self.console:btnpos2pos(response.data.btnpos)
			else
				y2 = response.data.y
				x2 = response.data.x
			end

			if enable then
				response:setScaleX(-1)
				response.run(response, cc.MoveTo:create(0.1, cc.p(x2, y2)))
			else
				response:setScaleX(1)
			end
		end
	elseif key == "exitGame" then
		local function callback2()
			if g_data.player.mailSched then
				scheduler.unscheduleGlobal(g_data.player.mailSched)

				g_data.player.mailSched = nil
			end

			if def.role.timer then
				for _, timer in pairs(def.role.timer) do
					def.role.stopRepeater(timer)
				end
			end

			def.role.roleStatus.buffs = ""
			def.role.roleStatus.canRecover = false
			def.role.roleStatus.canLostHPCall = false
			def.role.currWeapon = {}
			g_data.guild.initialization = false
			g_data.player.isLogined = false

			if main_scene.ui.console.controller.lock then
				main_scene.ui.console.controller.lock:onExit()
			end
		end

		if def.offToSaftyOnline then
			an.newMsgbox(CS_EXITTYPE, function(value)
				if value == 1 then
					callback2()
					main_scene:smallExit()
				elseif value == 2 then
					net.send({
						1314
					})
					os.exit(1)
				end
			end, {
				disableScroll = true,
				center = true,
				btnTexts = {
					CS_CACCT,
					CS_CEXIT
				}
			})
		elseif g_data.setting.base.quickexit then
			callback2()
			main_scene:smallExit()
		else
			an.newMsgbox(CS_EXIT, function(value)
				if value == 1 then
					callback2()
					main_scene:smallExit()
				end
			end, {
				disableScroll = true,
				center = true,
				hasCancel = true
			})
		end
	elseif key == "hp" then
		g_data.setting.base.hideMenu = not g_data.setting.base.hideMenu
		enable = g_data.setting.base.hideMenu
		settingKey = "hideMenu"

		local items2 = {
			"btnPanelSkill",
			"btnPanelShop"
		}

		local function callback3(self)
			for _, item in ipairs(items2) do
				if item == self then
					return true
				end
			end
		end

		for key3, widget2 in pairs(self.console.widgets) do
			if callback3(key3) then
				local x3
				local y3

				if widget2.data.btnpos then
					x3, y3 = self.console:btnpos2pos(widget2.data.btnpos)
				else
					y3 = widget2.data.y
					x3 = widget2.data.x
				end

				if enable then
					widget2.runs(widget2, {
						cc.MoveTo:create(0.1, cc.p(x3 - 50, y3)),
						cc.MoveTo:create(0.1, cc.p(x3 + display.width, y3))
					})
				else
					widget2.run(widget2, cc.MoveTo:create(0.1, cc.p(x3, y3)))
				end
			end
		end

		local response2 = self.console:get(key)

		if response2 then
			local x4
			local y4

			if response2.data.btnpos then
				x4, y4 = self.console:btnpos2pos(response2.data.btnpos)
			else
				y4 = response2.data.y
				x4 = response2.data.x
			end

			if enable then
				response2:setScaleX(-1)
				response2.run(response2, cc.MoveTo:create(0.1, cc.p(x4, y4)))
			else
				response2:setScaleX(1)
			end
		end
	elseif def.role.mainsetting.hiddenablePanels then
		for _2, hiddenablePanel2 in pairs(def.role.mainsetting.hiddenablePanels) do
			if key == hiddenablePanel2.key then
				if hiddenablePanel2.jsonFile and hiddenablePanel2.jsonID then
					def.role.PF:togglePanel(hiddenablePanel2.jsonID, hiddenablePanel2.jsonFile)
				else
					main_scene.ui:tip("缺少按钮参数")
				end
			end
		end
	end

	if btn.config and btn.config.call then
		def.role.call("@" .. btn.config.call)
	end
end

function btnCallbacks:handle_lockmon()
	cc2.ms({
		function()
			local value = self.console.controller.lock

			value.lockMon(value)
		end
	})
end

function btnCallbacks:handle_lockplayer()
	cc2.ms({
		function()
			local value = self.console.controller.lock

			value.lockPlayer(value)
		end
	})
end

function btnCallbacks:handle_custom(btn)
	if not btn.makeIndex then
		return
	end

	local _, data = g_data.bag:getItem(btn.makeIndex)
	local bagData
	local equipData
	local eatMsg
	local takeonMsg
	local isPlayer = true
	local source

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

		if self.canUseEquip(self, data, bagData, isPlayer) and bagData.use(bagData, "take", data.get(data, "makeIndex"), {
			where = where
		}) then
			net.send({
				takeonMsg,
				recog = data.get(data, "makeIndex"),
				param = where
			}, {
				data.getVar("name")
			})

			if source then
				source.delItem(source, data.get(data, "makeIndex"))
			end
		end
	else
		if equipIdx then
			return
		end

		if not self.canUseEquip(self, data, bagData, isPlayer) then
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
			an.newMsgbox(string.format("[%s] " .. CS_DOTRAIN, data.getVar("name")), function(isOk)
				if isOk == 1 then
					use()
				end
			end, {
				center = true,
				hasCancel = true
			}):setName("msgBoxLearnSkill")
		elseif data.getVar("stdMode") == 47 then
			if data.getVar("name") == "传情烟花" then
				local msgbox

				msgbox = an.newMsgbox("请输入传情烟花文字", function(idx)
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
			elseif data.getVar("name") == CS_COIN then
				an.newMsgbox(CS_CHANGECOIN, function()
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
	local var = item.getVar("needJob")

	if getTakeOnPosition(item.getVar("stdMode")) then
		local ret = true

		if need == 0 then
			ret = chargeNeed(CS_LEVEL .. CS_NOTENF, needLevel <= playerData.ability:get("level"))
		elseif need == 1 then
			ret = chargeNeed(CS_DC1 .. CS_NOTENF1, needLevel <= playerData.ability:get("maxDC"))
		elseif need == 2 then
			ret = chargeNeed(CS_MC1 .. CS_NOTENF1, needLevel <= playerData.ability:get("maxMC"))
		elseif need == 3 then
			ret = chargeNeed(CS_SC1 .. CS_NOTENF1, needLevel <= playerData.ability:get("maxSC"))
		elseif need == 5 and isPlayer then
			ret = chargeNeed(CS_YOUR .. CS_PRESTIGE .. CS_NOTENF1 .. "，" .. CS_NOWEAE, needLevel >= g_data.player.ability3:get("prestige"))
		end

		if var >= 8 then
			ret = chargeNeed(CS_JOBNOMACH, var == g_data.player.job)
		end

		if not ret then
			return
		end
	end

	if playerData.ability:get("maxHandWeight") < item.getVar("weight") then
		common.addMsg(CS_TOOHAV, display.COLOR_RED, display.COLOR_WHITE, true)

		return false
	end

	if item.getVar("stdMode") == 4 then
		if (item.getVar("shape") or 0) ~= playerData.job then
			common.addMsg(CS_NOSTUDYOTR, display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end

		if math.modf(Word(item.getVar("duraMax"))) > playerData.ability:get("level") then
			common.addMsg(CS_LEVEL .. CS_NOTENF, display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end
	elseif item.getVar("stdMode") ~= 5 and item.getVar("stdMode") ~= 6 and playerData.ability:get("maxWearWeight") - playerData.ability:get("wearWeight") < item.getVar("weight") then
		common.addMsg(CS_WEIGHT1 .. CS_NOTENF, display.COLOR_RED, display.COLOR_WHITE, true)

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

	if def.role.mainsetting.banShuiji and data.getVar("name") == CS_SUIJI then
		main_scene.ui:tip(CS_CANSUIJI)

		return
	end

	if g_data.bag:use("eat", data.get(data, "makeIndex"), {
		quick = true
	}) then
		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data.get(data, "makeIndex"))
		end

		sound.play("item", data)
		net.send({
			CM_EAT,
			recog = data.get(data, "makeIndex")
		}, {
			data.getVar("name")
		})
	end
end

function btnCallbacks:handle_hero(btn)
	local key

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
		main_scene.ui:tip(CS_NOHERO)

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
	elseif key == "fallowatk" then
		self.console.controller.lock:openHeroFollow(btn)
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

	local magicID
	local data
	local btn2

	if type(btn) == "number" then
		magicID = btn
		btn2 = main_scene.ui.console.widgets["skill" .. tostring(btn)]
		data = skillData
	else
		magicID = btn.data.magicId
		data = btn.skillData
		btn2 = btn
	end

	local magicID2 = tonumber(magicID)

	if not magicID2 or not data then
		return
	end

	if checkExist(magicID2, 3, 4, 7, 67) then
		return
	end

	if g_data.player.ability:get("MP") < data.get(data, "needMp") then
		main_scene.ui:tip(CS_NOMFZ)

		return
	end

	local config = def.magic.getMagicConfigByUid(magicID2, player)

	if not config then
		return
	end

	if cc2.isAutoXiama(magicID2 == 31) then
		return
	end

	local enabled

	if config and def.ccy.isOpenCSSkill() then
		local text = tostring(g_data.player.job)

		if config.actFrame and config.actFrame[text] and config.actFrame[text].first == "self" then
			enabled = true
		end

		local duration = def.ccy.findCsSkillbyMagic(magicID2, g_data.player.job)

		if duration then
			data.cdtime = duration.cdtime
			data.magicIdent = duration.magicIdent
			data.actType = duration.actType

			if duration.manualSelect then
				local value = def.ccy.calcCDTime(duration.cdtime * 1000, config)

				if not g_data.client:checkLastTime("magic" .. tostring(duration.magicId), value) then
					return
				elseif g_data.player.hitEnables[duration.key] then
					return
				else
					g_data.player:setHitEnable(duration.key, true)
					common.addMsg(duration.name .. CS_OPENOK .. "..", 219, 256)
					player.node:runs({
						cc.DelayTime:create(duration.manualSelectDelay),
						cc.CallFunc:create(function()
							if g_data.player.hitEnables[duration.key] then
								g_data.player:setHitEnable(duration.key, false)
								common.addMsg(duration.name .. CS_CLOSEOK .. "...", 219, 256)
							end
						end)
					})

					return
				end
			end
		end
	end

	if config.type == "immediate" or enabled then
		local config2 = def.role.dir["_" .. player.dir]

		self.console.controller:useMagic(player.x + config2[1], player.y + config2[2], player.dir, data)

		return
	end

	if data.get(data, "effectType") == 0 then
		if magicID2 == 26 and not g_data.client:checkLastTime("fire", config.cmDelaytime or def.ccy.getAttackSKillCDs("fire")) then
			return
		end

		if magicID2 == 27 then
			if not g_data.client:checkLastTime("rush", config.cmDelaytime or def.ccy.getAttackSKillCDs("rush")) then
				return
			end

			if btn2 then
				btn2.key = "skill" .. tostring(magicID2)

				main_scene.ui.console.controller:showcd(btn2, config.cmDelaytime or def.ccy.getAttackSKillCDs("rush"), 0.5)
			end
		end

		if magicID2 == 58 and not g_data.client:checkLastTime("swordhit", config.cmDelaytime or def.ccy.getAttackSKillCDs("swordhit")) then
			return
		end

		if not g_data.client:checkLastTime("spell", 0.5) then
			return
		end

		local x = player.x
		local y = player.y

		if magicID2 == 27 then
			g_data.client:setLastTime("rush", true)

			y = 0
			x = player.dir

			local text2 = "10010"
			local text3 = main_scene.ui.console.controller.lock

			if text3 and text3.role and not text3.role.die then
				text2 = tostring(text3.role.roleid)
			end

			net.send({
				CM_SAY
			}, {
				"rrs|" .. tostring(player.roleid) .. "|rush|" .. tostring(player.dir) .. "|" .. text2
			})
		end

		g_data.client:setLastTime("spell", true)
		net.send({
			CM_SPELL,
			param = x,
			tag = y,
			series = data.get(data, "magicId")
		})
	else
		local enabled2 = true

		if g_data.setting.job.autoSkill.enable and magicID2 == g_data.setting.job.autoSkill.magicId then
			enabled2 = false
		end

		if btn2 then
			data.btn = btn2
		end

		if enabled2 and magicID2 ~= 2 and magicID2 ~= 14 and magicID2 ~= 15 and magicID2 ~= 19 and magicID2 ~= 29 then
			local value2 = main_scene.ui.console.controller.lock

			value2.lockAnyOnly(value2)
		end

		self.console.skills:select(tostring(magicID2))

		if not WIN32_OPERATE then
			self.console:call("lock", "useSkill", data, config)
			self.console.controller:useMagic()
		end
	end
end

return btnCallbacks
