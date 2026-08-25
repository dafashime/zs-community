local value = ...
local common = import(".common.common")
local yayaListenner = import(".common.yayaListenner")
local yaya = require("mir2.single.yaya")
local settingLogic = import(".common.settingLogic")
local delegate = import(".panel._delegate")
local cc2 = require("mir2.cc")
local mainui = class("mainui", function()
	return display.newNode()
end)

mainui.__fx_map = {}
mainui.__P_B = {
	fireball = {
		trail = {
			angleVar = 25,
			startSize = 65,
			startA = 1,
			endG = 0.3,
			gravityY = 0,
			endB = 0,
			endA = 0.3,
			startR = 1,
			startB = 0.4,
			endSizeVar = 5,
			posVarY = 4,
			endSize = 20,
			speed = 6,
			gravityX = 0,
			angle = 90,
			endR = 1,
			blend = true,
			total = 150,
			speedVar = 3,
			posVarX = 4,
			startSizeVar = 15,
			life = 0.4,
			startG = 0.85,
			lifeVar = 0.1
		},
		burst = {
			angleVar = 360,
			startSize = 40,
			startA = 1,
			endG = 0.2,
			gravityY = -120,
			endB = 0,
			endA = 0.2,
			startR = 1,
			startB = 0.3,
			endSizeVar = 3,
			posVarY = 6,
			endSize = 5,
			speed = 150,
			duration = 0.5,
			angle = 0,
			gravityX = 0,
			endR = 0.9,
			blend = true,
			total = 150,
			speedVar = 50,
			posVarX = 6,
			startSizeVar = 12,
			life = 0.55,
			startG = 0.8,
			lifeVar = 0.2
		},
		caster = {
			angleVar = 180,
			startSize = 48,
			startA = 1,
			endB = 0,
			endSizeVar = 4,
			endA = 0,
			orbitCount = 3,
			startR = 1,
			startB = 0.15,
			endG = 0.3,
			posVarY = 3,
			orbitRadius = 25,
			offsetY = 15,
			speedVar = 4,
			angle = 90,
			speed = 8,
			endR = 1,
			blend = true,
			total = 60,
			orbitSpeed = 8,
			endSize = 15,
			posVarX = 3,
			startSizeVar = 10,
			life = 0.3,
			startG = 0.7,
			lifeVar = 0.1
		}
	},
	lightning = {
		caster = {
			angleVar = 35,
			startSize = 18,
			startA = 1,
			endG = 0.5,
			gravityY = 0,
			endB = 1,
			endA = 0,
			startR = 0.8,
			startB = 1,
			endSizeVar = 2,
			posVarY = 4,
			endSize = 3,
			speed = 180,
			gravityX = 0,
			angle = 90,
			endR = 0.4,
			blend = true,
			total = 80,
			speedVar = 60,
			posVarX = 12,
			style = "spark",
			startSizeVar = 8,
			life = 0.25,
			startG = 0.9,
			lifeVar = 0.1
		},
		bolt = {
			burstCloudRadius = 28,
			shrinkFactor = 0.48,
			phase4Duration = 0.1,
			branchIterations = 4,
			height = 350,
			groundArcCount = 6,
			groundArcCoreW = 0.6,
			phase4Glow = 2,
			phase1Duration = 0.08,
			branchChance = 0.28,
			wanderArcCount = 8,
			groundArcDisp = 18,
			groundArcGlowW = 2.5,
			groundArcSpread = 28,
			phase1Atmo = 0,
			phase1Glow = 1.6,
			phase2Atmo = 0,
			burstCloudCount = 2,
			phase4Atmo = 0,
			afterimageDuration = 0.4,
			displacement = 44,
			wanderArcDisp = 14,
			flickerInterval = 0.03,
			lightningColor = "white",
			phase3Duration = 0.14,
			phase3Glow = 6.4,
			wanderDuration = 1,
			phase2Core = 1.2,
			groundArcHeight = 45,
			afterimageCoreWidth = 0.4,
			afterimageGlowWidth = 1.6,
			wanderArcLen = 50,
			iterations = 6,
			phase3Core = 2,
			groundArcIter = 5,
			wanderArcIter = 5,
			burstCloudSpreadX = 30,
			phase1Core = 0.5,
			phase2Glow = 4,
			branchDisplacement = 16,
			groundArcOuterW = 5,
			phase2Duration = 0.08,
			branchMaxDepth = 2,
			branchLength = 0.3,
			wanderRadius = 60,
			phase3Atmo = 0,
			phase4Core = 0.6
		},
		hit = {
			angleVar = 180,
			startSize = 10,
			startA = 1,
			endG = 0.4,
			gravityY = 0,
			endB = 1,
			endA = 0,
			startR = 0.8,
			startB = 1,
			endSizeVar = 1,
			posVarY = 20,
			endSize = 2,
			speed = 80,
			duration = 0.5,
			angle = 90,
			gravityX = 0,
			endR = 0.3,
			blend = true,
			total = 60,
			speedVar = 40,
			posVarX = 14,
			startSizeVar = 5,
			life = 0.2,
			startG = 0.9,
			lifeVar = 0.08
		}
	},
	iceRoar = {
		trail = {
			angleVar = 40,
			startSize = 14,
			startA = 0.8,
			endB = 1,
			endSizeVar = 1,
			endA = 0,
			endSize = 3,
			startR = 0.7,
			startB = 1,
			endG = 0.6,
			posVarY = 8,
			speed = 12,
			angle = 90,
			endR = 0.4,
			blend = true,
			total = 40,
			speedVar = 6,
			posVarX = 8,
			startSizeVar = 5,
			life = 0.3,
			startG = 0.9,
			lifeVar = 0.1
		},
		burst = {
			angleVar = 360,
			startSize = 12,
			startA = 1,
			endG = 0.5,
			gravityY = -30,
			endB = 0.9,
			endA = 0,
			startR = 0.6,
			startB = 1,
			endSizeVar = 1,
			posVarY = 10,
			endSize = 2,
			speed = 90,
			duration = 0.3,
			angle = 0,
			gravityX = 0,
			endR = 0.3,
			blend = true,
			total = 70,
			speedVar = 35,
			posVarX = 10,
			startSizeVar = 4,
			life = 0.4,
			startG = 0.85,
			lifeVar = 0.15
		}
	},
	healing = {
		burst = {
			angleVar = 30,
			startSize = 8,
			startA = 0.8,
			endG = 0.8,
			gravityY = 15,
			endB = 0.2,
			endA = 0,
			startR = 0.2,
			startB = 0.3,
			endSizeVar = 1,
			posVarY = 5,
			endSize = 2,
			speed = 30,
			duration = 0.5,
			angle = 90,
			gravityX = 0,
			endR = 0.1,
			blend = true,
			total = 30,
			speedVar = 10,
			posVarX = 18,
			startSizeVar = 3,
			life = 0.6,
			startG = 1,
			lifeVar = 0.2
		}
	}
}

local value2

function mainui.__fx_a0(self)
	if value2 and scheduler and scheduler.unscheduleGlobal then
		pcall(scheduler.unscheduleGlobal, scheduler, value2)
	end

	value2 = nil
end

function mainui.__fx_a1(self, value3, number3, number4)
	mainui.__fx_a0()

	if not value3 or value3 == "" then
		return
	end

	if not sound or not sound.playSound then
		return
	end

	if not scheduler or not scheduler.performWithDelayGlobal then
		return
	end

	local number = tonumber(number3) or 22
	local number2 = tonumber(number4) or 45

	if number2 < number then
		number, number2 = number2, number
	end

	local function callback()
		if def.openNatureWeather and sound and sound.playSound then
			pcall(sound.playSound, sound, value3)
		end

		if scheduler and scheduler.performWithDelayGlobal then
			local value32 = number + math.random() * (number2 - number)

			value2 = scheduler.performWithDelayGlobal(callback, value32)
		end
	end

	local value4 = 1 + math.random() * 3

	value2 = scheduler.performWithDelayGlobal(callback, value4)
end

function mainui.__fx_tick(self, value3)
	return
end

function _isIphoneXorLiuHai()
	if device.platform == "ios" and math.floor(display.widthInPixels / display.heightInPixels * 10) > math.floor(17.77777777777778) then
		return true
	end

	if device.platform == "android" and BUILD_VERSION and BUILD_VERSION == 1 then
		local value3, value4 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "DeviceUtil", "getNotchSize", {}, "()I")

		if value3 and value4 then
			if value4 > 0 then
				return true
			end

			return false
		end
	end
end

function needsSafeAreaAdjustment()
	local instance = cc.Director:getInstance()

	if instance and instance.getOpenGLView then
		local openGLView = instance:getOpenGLView()

		if openGLView and openGLView.getSafeAreaInsets then
			local safeAreaInsets = openGLView:getSafeAreaInsets()

			print("getSafeAreaInsets part", safeAreaInsets.left)

			return safeAreaInsets.left > 0 or safeAreaInsets.right > 0
		elseif openGLView and openGLView.getSafeAreaRect then
			local size = openGLView:getSafeAreaRect()
			local frameSize = openGLView:getFrameSize().height - (size.y + size.height)

			print("getSafeAreaRect part", frameSize)

			return frameSize > 0
		end
	end

	print("custom part")

	return g_data.setting.base.liuhaier or _isIphoneXorLiuHai()
end

function getSafeAreaInsets()
	local instance = cc.Director:getInstance()

	if instance and instance.getOpenGLView then
		local openGLView = instance:getOpenGLView()

		if openGLView and openGLView.getSafeAreaInsets then
			local safeAreaInsets = openGLView:getSafeAreaInsets()

			if safeAreaInsets.left > 0 and safeAreaInsets.right > 0 then
				return safeAreaInsets.left, safeAreaInsets.right, safeAreaInsets.top, safeAreaInsets.bottom
			end
		elseif openGLView and openGLView.getSafeAreaRect then
			local size = openGLView:getSafeAreaRect()
			local size2 = openGLView:getFrameSize()
			local value3 = size2.height - (size.y + size.height)
			local value4 = size2.width - (size.x + size.width)

			if value4 > 0 and value3 > 0 then
				return value4 / 2, value4 / 2, value3 / 2, value3 / 2
			end
		end
	end

	return 55, 0, 0, 0
end

local function callback(self, value3)
	local function callback2(self2)
		local number, number2, number3, number4 = self2:match("(%d+)%.(%d+)%.(%d+)%-?(%d*)")

		return {
			major = tonumber(number) or 0,
			minor = tonumber(number2) or 0,
			patch = tonumber(number3) or 0,
			build = tonumber(number4) or 0
		}
	end

	local value4 = callback2(self)
	local value5 = callback2(value3)

	if value4.major > value5.major then
		return true
	elseif value4.major < value5.major then
		return false
	end

	if value4.minor > value5.minor then
		return true
	elseif value4.minor < value5.minor then
		return false
	end

	if value4.patch > value5.patch then
		return true
	elseif value4.patch < value5.patch then
		return false
	end

	if value4.build > value5.build then
		return true
	else
		return false
	end
end

if device.platform == "ios" then
	SupportOnlineVoice = GOWN_ENGINE_VERSION and callback(GOWN_ENGINE_VERSION, "1.3.0-0")
else
	SupportOnlineVoice = GOWN_ENGINE_VERSION and callback(GOWN_ENGINE_VERSION, "1.3.0-148")
end

attrTips_Img = {
	DC = "numsx_4",
	MC = "numsx_9",
	maxMP = "numsx_20",
	maxDC = "numsx_11",
	MAC = "numsx_12",
	maxAC = "numsx_5",
	maxHP = "numsx_3",
	maxMAC = "numsx_18",
	maxMC = "numsx_15",
	maxSC = "numsx_16",
	AC = "numsx_24",
	SC = "numsx_10"
}

function attrTips_chkChange(self)
	if not def.showAttrTips then
		return
	end

	local value3 = g_data.player.ability
	local value4 = self.ability

	if not value4 then
		return
	end

	local function cleanup(self2, value32)
		if value32 and value3:get(self2) - value32 ~= 0 then
			main_scene.ui.attrTips:show(self2, value3:get(self2) - value32)
		end
	end

	cleanup("AC", value4.AC)
	cleanup("maxAC", value4.maxAC)
	cleanup("DC", value4.DC)
	cleanup("maxDC", value4.maxDC)
	cleanup("MC", value4.MC)
	cleanup("maxMC", value4.maxMC)
	cleanup("SC", value4.SC)
	cleanup("maxSC", value4.maxSC)
	cleanup("maxHP", value4.maxHP)
	cleanup("maxMP", value4.maxMP)
	cleanup("MAC", value4.MAC)
	cleanup("maxMAC", value4.maxMAC)
end

table.merge(mainui, {
	z = {
		replaceAsk = 7,
		centerTopTip = 4,
		diyBtn = 6,
		chatChannel = 9,
		textInfo = 2,
		voiceTip = 5,
		leftTopTip = 3,
		centerTip = 11,
		focus = 1,
		detail = 8
	}
})

function mainui.ctor(self)
	self.panels = {}
	self.customs = {}
	self.leftTopTip = import(".common.leftTopTip", value).new():add2(self, self.z.leftTopTip)
	self.centerTopTip = import(".common.centerTopTip", value).new():add2(self, self.z.centerTopTip)
	self.attrTips = import(".common.attrTips", value).new():add2(self, self.z.centerTopTip)

	self:loadConsole()

	self.notice = import(".common.notice", value).new():add2(self, self.z.focus)
	self.fadeN = 0

	if SupportOnlineVoice and _G.yayayListenner == nil and OP_YAYA then
		_G.yayayListenner = yaya.initSDK(false, yayaListenner)
	end
end

function mainui.onEnter(self)
	return
end

function mainui.onExit(self)
	return
end

function mainui.loadConsole(self)
	if self.console then
		self.console:removeSelf()
	end

	self.console = import(".console.console", value).new():addTo(self)
end

function mainui.showPanel(self, data, ...)
	if self.panels[data] then
		return
	end

	local value3 = data

	if WIN32_OPERATE and data == "equip" then
		value3 = data .. "Pc"
	end

	if IS_PLAYER_DEBUG then
		package.loaded["mir2.scenes.main.panel." .. data] = nil
		package.loaded["mir2.scenes.main.panel." .. value3] = nil
	end

	local value4 = import(".panel." .. value3, value).new(...):addTo(self, self.z.focus)

	delegate.extend(value4, data, self)

	if not main_scene.ui.isChoseItem then
		if self.lastFocus then
			self.lastFocus:setLocalZOrder(0)
		end

		self.lastFocus = value4
	else
		value4:setLocalZOrder(0)
	end

	self.panels[data] = value4

	main_scene.ground.helper:openPanel(data)

	return value4
end

function mainui.hidePanel(self, value3)
	if not self.panels[value3] then
		return
	end

	if self.lastFocus == self.panels[value3] then
		self.lastFocus = nil
	end

	self.panels[value3]:removeSelf()

	self.panels[value3] = nil
end

function mainui.togglePanel(self, value3, value4)
	if self.panels[value3] then
		self.panels[value3]:hidePanel()
	else
		self:showPanel(value3, value4)
	end
end

function mainui.hideAll(self)
	for _, panel in pairs(self.panels) do
		panel:removeSelf()
	end

	self.panels = {}
	self.lastFocus = nil
end

function mainui.tip(self, ...)
	self.leftTopTip:show(...)
end

function mainui.fadeLabel(self, value3)
	if not def.openFadeLabel then
		self:tip(value3)

		return
	end

	if not def.fadeLabel then
		def.fadeLabel = {
			fontSize = 20,
			dy = 60,
			dx = 0,
			fly = 0.5,
			delay = 1,
			pic = "pic/bzmir/alert/bg.png",
			x = display.cx,
			y = display.cy - 100,
			fontColor = display.COLOR_GREEN
		}
	end

	local x = def.fadeLabel.x or display.cx
	local y = def.fadeLabel.y or display.cy - 100
	local x2 = def.fadeLabel.dx or 0
	local y2 = def.fadeLabel.dy or 60
	local duration = def.fadeLabel.fly or 0.5
	local duration2 = def.fadeLabel.delay or 1
	local value4 = def.fadeLabel.fontSize or 20
	local color = def.fadeLabel.fontColor or display.COLOR_WHITE
	local frameName = def.fadeLabel.pic or "pic/bzmir/alert/bg.png"
	local background = display.newScale9Sprite(res.getframe2(frameName)):anchor(0.5, 0.5):addTo(self, self.z.centerTip):pos(x, y)

	an.newLabel(value3, value4, 1, {
		color = color
	}):anchor(0.5, 0.5):addTo(background):pos(background:getw() / 2, background:geth() / 2)

	self.fadeH = background:geth()

	if self.fadeT and os.time() - self.fadeT >= 2 then
		self.fadeN = 0
	end

	self.fadeT = os.time()

	if self.fadeN > 0 then
		y2 = y2 - self.fadeN * self.fadeH
	end

	self.fadeN = self.fadeN + 1

	if self.fadeN > 2 then
		self.fadeN = 0
	end

	background:runs({
		cc.MoveBy:create(duration, cc.p(x2, y2)),
		cc.DelayTime:create(duration2),
		cca.fadeOut(0.2),
		cc.CallFunc:create(function()
			if background then
				background:removeSelf()

				background = nil
			end
		end)
	})
end

GOW64 = GOWN_ENGINE_VERSION

function GOW64_VERSION(self)
	if GOWN_ENGINE_VERSION then
		return GOWN_ENGINE_VERSION == self
	end

	return nil
end

local callback2 = device.openURL

function device.openURL(self)
	if self then
		if ccexp.WebView ~= nil and self:find("1234500000.com") ~= nil and self:find("10171") ~= nil then
			main_scene.ui:togglePanel("webView", {
				title = "网页充值",
				height = 550,
				width = 700,
				url = self,
				callback = function(value3, value4)
					local text = value4

					if string.find(text, "status=success") then
						device.showAlert("支付成功", "如果充值未到账，请返回手动领取。", {
							"好的"
						}, function()
							main_scene.ui:fadeLabel("正在领取充值…")
							def.role.sendCM("@getCharge")
						end)
					elseif string.find(text, "status=back") and value3 then
						value3:hidePanel()
					end
				end
			})
		else
			callback2(self)
		end
	end
end

local function callback3(self, value3)
	local items

	if not g_data.player.IsSplliteItem then
		items = g_data.bag:PileUpNext(self, value3)

		if type(items) == "table" and #items == 2 then
			net.send({
				CM_PILEUPITEM,
				series = 0,
				recog = items[2]:get("makeIndex"),
				param = Loword(items[1]:get("makeIndex")),
				tag = Hiword(items[1]:get("makeIndex"))
			})
			g_data.player:setIsinPileUping(true)
		end
	end

	g_data.player:setIsinPileUping(false)
	g_data.player:setIsSplliting(false)

	return items
end

function mainui.update(self, dt)
	common.update(dt)
	self.console:update(dt)
	settingLogic.update(dt)
	self:__fx_tick(dt)

	local point = main_scene.ground.player

	if point and self.panels.npc and self.panels.npc.x and self.panels.npc.y and (math.abs(self.panels.npc.x - point.x) > 8 or math.abs(self.panels.npc.y - point.y) > 8) then
		self:hidePanel("npc")
	end

	if point and self.panels.storage and self.panels.storage.x and self.panels.storage.y and (math.abs(self.panels.storage.x - point.x) > 8 or math.abs(self.panels.storage.y - point.y) > 8) then
		self:hidePanel("storage")
	end
end

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function mainui.checkUsedItemforStopAutoRat(self, item)
	if item then
		local var = item.getVar("name")

		if type(var) == "string" then
			for index, item2 in pairs({
				"盟重传送石",
				"比奇传送石"
			}) do
				if string.find(var, item2) then
					main_scene.ui.console.autoRat:stop()
				end
			end
		end
	end
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function mainui.processMsg(self, msg, buf, bufLen)
	if not msg then
		return
	end

	local function callback4(self2, value3)
		local msgbox = an.newMsgbox("", value3)

		an.newLabel(self2, 20, 1, {
			color = def.colors.labelGray
		}):addTo(msgbox):pos(msgbox:centerPos()):anchor(0.5, 0.5)
	end

	local function callback32(self2)
		if not g_data.player.IsSplliteItem then
			local items = self2 and g_data.heroBag:PileUpNext() or g_data.bag:PileUpNext()

			if type(items) == "table" and #items == 2 then
				net.send({
					CM_PILEUPITEM,
					recog = items[1]:get("makeIndex"),
					param = Loword(items[2]:get("makeIndex")),
					tag = Hiword(items[2]:get("makeIndex")),
					series = self2 and 1 or 0
				})
				g_data.player:setIsinPileUping(true)
			end
		end

		g_data.player:setIsSplliting(false)
	end

	local value3 = msg.ident

	if SM_ABILITY == value3 then
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

			if def.openRoleMPBar then
				main_scene.ground.player.info:setMP(g_data.player.ability:get("MP"), g_data.player.ability:get("maxMP"))
			end
		end

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end

		main_scene.ground.helper:checkFirstLogin()
	elseif SM_GETDIAMNUM_EXT == value3 then
		if bufLen == getRecordSize("TMessageCapitalInfo") then
			g_data.player:setCapitalInfo(buf, bufLen)
			main_scene.ui.console:call("infoBar", "uptYb")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		end
	elseif checkExist(value3, SM_HEAR, SM_CRY, SM_GROUPMESSAGE, SM_CORPSMESSAGE, SM_GUILDMESSAGE, SM_SYSMESSAGE, SM_WHISPER, SM_BROADCASTMESSAGE) then
		if buf then
			local value4 = net.strs(buf)

			if settingLogic.filterChat(value4[1], value3, msg) and g_data.relation:filterChat(common.getPlayerName(), value4[1], value3, msg) then
				common.addMsg(value4[1], Lobyte(msg.param), Hibyte(msg.param), nil, msg.recog, msg, buf, bufLen)
			end
		end
	elseif SM_QUERY_FOCUS_ITEM == value3 then
		common.uptItemMsgData(net.record("TClientItem", buf, bufLen))
	elseif SM_MENU_OK == value3 or SM_DLGMSG == value3 then
		local value5 = net.str(buf)

		if value5 ~= "" then
			callback4(value5)
		end
	elseif SM_CLIENT_CONF == value3 then
		g_data.chat:setShieldMask(msg.recog)
		common.refershChatContent()
	elseif SM_ATTACKMODE == value3 then
		def.ccy.changeMode(msg.recog)
	elseif SM_SENDMYMAGIC == value3 then
		g_data.player:setMagicList(buf, bufLen)
		main_scene.ui.console.skills:upt()

		if self.panels.equip and self.panels.equip.page == "skill" then
			self.panels.equip:showContent("skill")
		end
	elseif SM_ADDMAGIC == value3 then
		local magicIdOwner = g_data.player:addMagic(buf, bufLen)

		if magicIdOwner then
			main_scene.ui.console.skills:layout(magicIdOwner.magicId)
		end

		main_scene.ui.console.skills:upt()

		if self.panels.equip and self.panels.equip.page == "skill" then
			self.panels.equip:showContent("skill")
		end

		LocalAutoCusSkills = true
	elseif SM_MAGIC_LVEXP == value3 then
		local value6 = g_data.player:setMagicExp(msg, buf, bufLen)

		if value6 and self.panels.equip then
			self.panels.equip:updateMagic(value6:get("magicId"))
		end
	elseif SM_STAMINA == value3 then
		g_data.player:setStamina(msg.param, msg.recog)
		main_scene.ui.console:call("infoBar", "uptStamina")

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end
	elseif SM_VITALITY == value3 then
		g_data.player:setVitality(msg.param, msg.recog)
		main_scene.ui.console:call("infoBar", "uptVitality")

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end
	elseif SM_EXP_POOL == value3 then
		g_data.player:setExpPoolValue(msg.recog)
		main_scene.ui.console:call("infoBar", "uptExp")

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
			main_scene.ui.panels.equip:showContent("attributes")
		end
	elseif SM_VITALITYITEM == value3 then
		g_data.player:setVitaliyitemValue(msg.recog)
		main_scene.ui.console:call("infoBar", "uptBlood")
	elseif SM_WINEXP == value3 then
		g_data.player.ability:set("Exp", msg.recog)

		local long = MakeLong(msg.param, msg.tag)

		if not g_data.setting.base.showExpEnable or g_data.setting.base.showExpEnable and long >= g_data.setting.base.showExpValue then
			if msg.series == TExpTypeEnergy then
				self:tip(long .. " 精力经验值增加")
			elseif msg.series == TExpTypePower then
				self:tip(long .. " 活力经验值增加")
			else
				self:tip(long .. " 经验增加")
			end
		end

		self.console:call("bottom", "upt")
		self.console.autoRat:onExpUpdate()

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
			main_scene.ui.panels.equip:showContent("state")
		end
	elseif SM_LEVELUP == value3 then
		g_data.player.ability:set("level", msg.param)
		self:tip("升级!")
		main_scene.ui.console:call("infoBar", "uptLevel")
		main_scene.ground.helper.runner.onLevelUp(msg.param)
	elseif SM_BAGITEMS == value3 then
		g_data.bag:set(buf, bufLen)

		if self.panels.bag then
			self.panels.bag:reload()
		end

		for _, item in pairs(g_data.bag.items) do
			local var = item.getVar("stdMode")

			if var == 153 and item.getVar("duraMax") <= 9999 then
				local takeOnPosition = getTakeOnPosition(var)

				callback3(takeOnPosition, item)
			end
		end
	elseif SM_SENDUSEITEMS == value3 then
		g_data.equip:set(buf, bufLen)

		if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "equip" then
			main_scene.ui.panels.equip:showContent("equip")
		end

		main_scene.ground:uptNight(true)
	elseif SM_SENDUSERSTATE == value3 then
		local record = getRecord("TUserStateInfo")

		net.record(record, buf, bufLen)
		self:hidePanel("equipOther")
		self:showPanel("equipOther", record)
		g_data.client:setLastTime("queryOther")
	elseif SM_SEND_TITLEINFO == value3 then
		g_data.player:initTitle(msg, buf, bufLen)

		if main_scene.ui.panels.equip then
			main_scene.ui.panels.equip:showContent("title")
		end
	elseif SM_SET_CURTITLE == value3 then
		if msg.series == 0 then
			g_data.player:setTitleResult(msg)

			if main_scene.ui.panels.equip then
				main_scene.ui.panels.equip:showContent("title")
			end
		end
	elseif SM_UPDATE_TITLE == value3 then
		g_data.player:updateTitleInfo(msg, buf, bufLen)

		if main_scene.ui.panels.equip then
			main_scene.ui.panels.equip:showContent("title")
		end
	elseif SM_UPDATE_TITLE_DURA == value3 then
		g_data.player:updateTitleCount(msg, buf, bufLen)
	elseif SM_ADDITEM == value3 then
		local items = g_data.bag:add(buf, bufLen)

		for index = 1, #items do
			local response = items[index]

			self:tip(def.ccy.getItemName(response) .. " 被发现")

			if response.where == "bag" and self.panels.bag then
				self.panels.bag:addItem(response.data:get("makeIndex"))
			end

			main_scene.ground.helper.runner.onNewItem(response.data:get("Index"))
		end

		callback32()
	elseif SM_ITEM_PILEUP_RESULT == value3 then
		g_data.player:setIsinPileUping(false)

		if msg.series == 0 then
			callback32()
		elseif msg.series == 1 then
			callback32(true)
		end
	elseif SM_DELITEM == value3 then
		local value7 = msg.recog

		if msg.param == 0 then
			if g_data.bag:delItem(value7) and self.panels.bag then
				self.panels.bag:delItem(value7)
			end

			if g_data.equip:delItem(value7) and self.panels.equip then
				self.panels.equip:delItem(value7)
				main_scene.ground:uptNight(true)
			end

			if self.panels.strengthen then
				self.panels.strengthen:delItem(value7)
			end
		elseif msg.param == 1 and self.panels.storage then
			self.panels.storage:delItem(value7)
			self.panels.storage:delItemData(value7)
		end
	elseif SM_UPDATEITEM == value3 then
		local value8 = g_data.bag:upt(buf, bufLen)

		if value8 and self.panels.bag then
			self.panels.bag:uptItem(value8)
		end

		if value8 and self.panels.strengthen then
			self.panels.strengthen:uptItem(value8)
		end

		local value9 = g_data.equip:upt(buf, bufLen)

		if value9 and self.panels.equip then
			self.panels.equip:uptItem(value9)
			main_scene.ground:uptNight(true)
		end
	elseif SM_BAGITEMDURACHG == value3 then
		g_data.bag:duraChange(msg.recog, msg.param, msg.tag, msg.series)

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:duraChange(msg.recog, msg.param, msg.tag, msg.series)
		end

		if self.panels.strengthen then
			self.panels.strengthen:duraChange(msg.recog)
		end
	elseif SM_DURACHANGE == value3 then
		g_data.equip:duraChange(msg.param, msg.recog, MakeLong(msg.tag, msg.series))
		main_scene.ground:uptNight(true)
	elseif SM_DELITEMS == value3 then
		local items2 = {}
		local value10 = math.floor(bufLen / 4)

		if value10 > 0 then
			for index2 = 1, value10 do
				items2[#items2 + 1], buf, bufLen = net.uint(buf, bufLen)
			end
		end

		for _2, item2 in ipairs(items2) do
			if g_data.bag:delItem(item2) and self.panels.bag then
				self.panels.bag:delItem(item2)
			end

			if g_data.equip:delItem(item2) and self.panels.equip then
				self.panels.equip:delItem(item2)
				main_scene.ground:uptNight(true)
			end

			g_data.bag:delQuickItem(item2)
		end
	elseif SM_DROPITEM_SUCCESS == value3 then
		g_data.bag:throwEnd(msg.recog, true)
	elseif SM_DROPITEM_FAIL == value3 then
		g_data.bag:throwEnd(msg.recog, false)

		if self.panels.bag then
			self.panels.bag:addItem(msg.recog)
		end
	elseif SM_WEIGHTCHANGED == value3 then
		g_data.player:weightChanged(msg.recog, msg.param, msg.tag)
		main_scene.ui.console:call("infoBar", "uptBag")
	elseif SM_EATITEM_OK == value3 then
		local value11, value12, value13 = g_data.bag:useEnd("eat", true)

		main_scene.ui.console:fillPropTest()
		self:checkUsedItemforStopAutoRat(value12)
	elseif SM_EATITEM_FAIL == value3 then
		local value14, value15, value16, value17 = g_data.bag:useEnd("eat", false)

		if value14 and self.panels.bag then
			self.panels.bag:addItem(value14)
		end

		self:checkUsedItemforStopAutoRat(value15)
	elseif SM_TAKEON_OK == value3 then
		local value18 = msg.recog

		if bufLen == getRecordSize("TFeature") then
			value18 = net.record("TFeature", buf, bufLen)
		end

		main_scene.ground.map.player:changeFeature(value18)

		local value19 = g_data.bag:useEnd("take", true)

		if self.panels.equip and value19 then
			self.panels.equip:setItem(value19)
		end

		main_scene.ground:uptNight(true)
		def.role.call("@OnTakeChanged")
	elseif SM_TAKEON_FAIL == value3 then
		local value20 = g_data.bag:useEnd("take", false)

		if self.panels.bag and value20 then
			self.panels.bag:addItem(value20)
		end

		local text = ""

		if msg.recog == -1 then
			text = "该物品获得后自动锁定，锁定期过后才可正常使用。"
		elseif msg.recog == -2 then
			text = "穿戴位置不正确"
		elseif msg.recog == -3 then
			text = "二级密码锁定状态不能更换装备"
		elseif msg.recog == -4 then
			text = "密保锁定。"
		elseif msg.recog == -6 then
			text = "装备基础条件不满足"
		elseif msg.recog == -7 then
			text = "超重"
		elseif msg.recog == -8 then
			text = CS_TAKEON_FAIL_SW
		else
			text = msg.recog == -9 and "装备基础条件不满足" or msg.recog == -10 and "职业不满足" or msg.recog == -11 and "性别不符合，无法穿戴" or msg.recog == -12 and "不能穿戴" or "未知错误"
		end

		common.addMsg(text, display.COLOR_RED, display.COLOR_WHITE, true)
		main_scene.ground:uptNight(true)
	elseif SM_TAKEOFF_OK == value3 then
		local value21 = msg.recog

		if bufLen == getRecordSize("TFeature") then
			value21 = net.record("TFeature", buf, bufLen)
		end

		main_scene.ground.map.player:changeFeature(value21)
		g_data.equip:takeOffEnd(true)
		main_scene.ground:uptNight(true)
		def.role.call("@OnTakeChanged")
	elseif SM_TAKEOFF_FAIL == value3 then
		local value22 = g_data.equip:takeOffEnd(false)

		if self.panels.equip and value22 then
			self.panels.equip:setItem(value22)
			main_scene.ground:uptNight(true)
		end
	elseif SM_MERCHANTSAY == value3 then
		local body = net.str(buf)

		if body == crypto.decodeBase64("TlBDL0hlbHBlcjox") then
			set_helper(msg.recog)
		else
			local npcName = ""
			local value23 = string.find(body, "/")

			if value23 then
				npcName = string.sub(body, 1, value23 - 1)
				body = string.sub(body, value23 + 1, string.len(body))
			end

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
		end
	elseif SM_MERCHANTDLGCLOSE == value3 then
		self:hidePanel("npc")
	elseif SM_MERCHANT_QUERY == value3 then
		if msg.tag == 0 then
			if self.panels.npc then
				self.panels.npc:showInput(msg, buf, bufLen)
			end
		elseif msg.tag == 1 then
			local value24 = net.str(buf)
			local tag = msg.tag
			local recog = msg.recog
			local param = msg.param
			local msgbox = an.newMsgbox(value24, function(value32)
				net.send({
					CM_MERCHANT_QUERY,
					recog = recog,
					param = param,
					tag = tag,
					series = value32 - 1
				})
			end, {
				disableScroll = true,
				btnTexts = {
					"取消",
					"同意"
				}
			})
		elseif msg.tag == 3 then
			-- block empty
		end
	elseif SM_SENDGOODSLIST == value3 then
		if self.panels.npc then
			self.panels.npc:showList(msg.recog, msg.param, buf, bufLen, "goods")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDDETAILGOODS == value3 then
		if self.panels.npc then
			self.panels.npc:showList(msg.recog, msg.param, buf, bufLen, "goods_detail", msg.tag)
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDMAKEDRUGITEMS == value3 then
		if self.panels.npc then
			self.panels.npc:showList(msg.recog, msg.param, buf, bufLen, "synthesis", msg.tag)
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SAVEITEMLIST == value3 then
		self:hidePanel("storage")
		self:showPanel("storage", msg.recog, msg.param, msg.tag, buf, bufLen)
	elseif SM_BUYITEM_SUCCESS == value3 then
		g_data.client:setLastTime("buy")
		common.goldChanged(msg.recog)

		if self.panels.npc then
			self.panels.npc:removeItem(MakeLong(msg.param, msg.tag))
		end
	elseif SM_BUYITEM_FAIL == value3 then
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
	elseif SM_SENDUSERREPAIR == value3 then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "repair")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDUSERSELL == value3 then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "sell")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDUSERSTORAGEITEM == value3 then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "storage")
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_SENDREPAIRCOST == value3 or SM_SENDBUYPRICE == value3 then
		if self.panels.npc then
			self.panels.npc:setSellText(msg.recog >= 0 and msg.recog .. " 金币" or "???? 金币")

			if self.panels.npc.sell.itemData then
				self.panels.npc.sell.itemData.price = msg.recog
			end
		end
	elseif SM_OPEN_COMMIT_ITEM == value3 then
		if self.panels.npc then
			self.panels.npc:showSellFrame(msg.recog, "exchange", msg.series)
			self.panels.npc:setSellText(net.str(buf))
			self:showPanel("bag")
			self.panels.bag:resetPanelPosition("right")
		end
	elseif SM_COMMIT_ITEM == value3 then
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
				local value25 = net.str(buf)

				common.addMsg(value25, display.COLOR_GREEN, display.COLOR_WHITE, true)
			end
		end
	elseif SM_USERSELLITEM_OK == value3 then
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
	elseif SM_USERSELLITEM_FAIL == value3 then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		g_data.client:setLastTime("sell")
		g_data.client:setLastSellItem()

		local text2 = "\t\t\t您不能出售该物品，可能是以下原因：\n\t\t\t1.    绑定物品和高级物品无法出售\n\t\t\t2.    请前往对应商店出售物品\n\t\t\t3.    可携带金币超出上限(未验证角色可携带200万金币，已验证角色可携带5000万金币)"

		an.newMsgbox(text2)
	elseif SM_USERREPAIRITEM_OK == value3 then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		if g_data.client.lastSellItem then
			g_data.client.lastSellItem:set("dura", msg.param)
			g_data.client.lastSellItem:set("duraMax", msg.tag)
		end

		g_data.client:setLastSellItem()
		g_data.client:setLastTime("sell")
	elseif SM_USERREPAIRITEM_FAIL == value3 then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		g_data.client:setLastSellItem()
		g_data.client:setLastTime("sell")
		an.newMsgbox("您不能修理此物品.", nil, {
			center = true
		})
	elseif SM_MAKEDRUG_FAIL == value3 then
		local text3 = ""

		if msg.recog == 3 then
			text3 = "金币不够 "
		elseif msg.recog == 4 then
			text3 = "材料不足"
		elseif msg.recog == 2 then
			text3 = "合成成功，获取物品失败"
		end

		self:tip(text3)
	elseif checkExist(value3, SM_STORAGE_OK, SM_STORAGE_FULL, SM_STORAGE_FAIL) then
		if self.panels.npc then
			self.panels.npc:delSellItem()
		end

		if SM_STORAGE_OK == value3 and g_data.client.lastSellItem then
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

			if SM_STORAGE_OK == value3 then
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

		if SM_STORAGE_FULL == value3 then
			an.newMsgbox("你的个人仓库已满，你不能再寄存任何物品。", nil, {
				center = true
			})
		elseif SM_STORAGE_FAIL == value3 then
			self:tip("寄存失败。")
		end
	elseif SM_GETSTORAGEITEM_OK == value3 then
		g_data.client:setStorageGetBackItem()
		g_data.client:setLastTime("buy")

		if self.panels.npc then
			self.panels.npc:removeItem(msg.recog)
		end
	elseif SM_GETSTORAGEITEM_FAIL == value3 then
		local text4 = ""

		if msg.recog == -1 then
			text4 = "您已无法携带这么重的物品了"
		elseif msg.recog == -2 then
			text4 = "在交易中无法使用仓库功能"
		elseif msg.recog == -3 then
			text4 = "你的仓库已密宝绑定，如需取出物品请先开启仓库"
		end

		g_data.client:setLastTime("buy")
		self:tip(text4)

		if g_data.client.storageGetBackItem then
			if self.panels.storage then
				self.panels.storage:addItem(g_data.client.storageGetBackItem)
			end

			g_data.client:setStorageGetBackItem()
		end
	elseif SM_GETSTORAGEITEM_FULLBAG == value3 then
		g_data.client:setLastTime("buy")
		an.newMsgbox("您无法携带更多物品了.")

		if g_data.client.storageGetBackItem then
			if self.panels.storage then
				self.panels.storage:addItem(g_data.client.storageGetBackItem)
			end

			g_data.client:setStorageGetBackItem()
		end
	elseif SM_STORAGEITEMDURACHG == value3 then
		if self.panels.storage then
			self.panels.storage:duraChange(msg.recog, msg.param, msg.tag, msg.series)
		end
	elseif SM_STORAGE_ADDITEM == value3 then
		if main_scene.ui.panels.storage then
			main_scene.ui.panels.storage:splitNemItem(msg, buf, bufLen)
		end
	elseif SM_GOLDCHANGED == value3 then
		common.goldChanged(msg.recog)
	elseif SM_PLAYDICE == value3 then
		common.showBosonResult(msg, buf, bufLen)
	elseif SM_SHOWBOOK == value3 then
		print("书本")
	elseif SM_DEALMENU == value3 then
		g_data.client:setLastTime("deal")
		self:hidePanel("deal")
		self:showPanel("deal", net.str(buf))
		self:showPanel("bag")
	elseif SM_DEALTRY_FAIL == value3 then
		g_data.client:setLastTime("deal")
		callback4("交易被取消。\n要正确交易你必须和对方面对面。")
	elseif SM_DEALADDITEM_OK == value3 then
		g_data.client:setLastTime("deal")

		if g_data.client.dealItem then
			g_data.client:addDealItem(g_data.client.dealItem)

			if self.panels.deal then
				self.panels.deal:addItem("self", g_data.client.dealItem)
			end

			g_data.client:setNowDealItem()
		end
	elseif SM_DEALADDITEM_FAIL == value3 then
		g_data.client:setLastTime("deal")

		if g_data.client.dealItem then
			g_data.bag:addItem(g_data.client.dealItem)

			if self.panels.bag then
				self.panels.bag:addItem(g_data.client.dealItem:get("makeIndex"))
			end

			g_data.client:setNowDealItem()
		end
	elseif SM_DEALDELITEM_OK == value3 then
		-- block empty
	elseif SM_DEALDELITEM_FAIL == value3 then
		-- block empty
	elseif SM_DEALCANCEL == value3 then
		for _3, dealItem in ipairs(g_data.client.dealItems) do
			g_data.bag:addItem(dealItem)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(dealItem:get("makeIndex"))
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
	elseif SM_DEALREMOTEADDITEM == value3 then
		if self.panels.deal then
			local record2 = getRecord("TClientItem")

			net.record(record2, buf, getRecordSize("TClientItem"))
			self.panels.deal:addItem("target", record2)
		end
	elseif SM_DEALREMOTEDELITEM == value3 then
		if self.panels.deal then
			local record3 = getRecord("TClientItem")

			net.record(record3, buf, getRecordSize("TClientItem"))
			self.panels.deal:delItem("target", record3)
		end
	elseif SM_DEALCHGGOLD_OK == value3 or SM_DEALCHGGOLD_FAIL == value3 then
		g_data.client:setLastTime("deal")
		g_data.client:setDealGold(msg.recog)
		common.goldChanged(MakeLong(msg.param, msg.tag))

		if self.panels.deal then
			self.panels.deal:setMoney("self", msg.recog)
		end
	elseif SM_DEALREMOTECHGGOLD == value3 then
		if self.panels.deal then
			self.panels.deal:setMoney("target", msg.recog)
		end
	elseif SM_DEALSUCCESS == value3 then
		self:hidePanel("deal")
		g_data.client:setDealGold()
		g_data.client:clearDealItem()
	elseif SM_GROUPMODECHANGED == value3 then
		g_data.player:setAllowGroup(msg.param > 0)
		g_data.client:setLastTime("group")

		if self.panels.group then
			self.panels.group:enableAllow()
		end
	elseif SM_CREATEGROUP_OK == value3 then
		g_data.player:setAllowGroup(true)
		g_data.client:setLastTime("group")

		if self.panels.group then
			self.panels.group:enableAllow()
		end
	elseif SM_JOINGROUP_FAIL == value3 then
		if msg.recog == -1 then
			callback4("玩家名错误或不在线。")
		elseif msg.recog == -2 then
			callback4("玩家队伍不存在")
		elseif msg.recog == -3 then
			callback4("不在允许组队状态")
		elseif msg.recog == -4 then
			callback4("队伍人数已满。")
		elseif msg.recog == -10 then
			callback4("不可邀请自己组队。")
		else
			callback4("未知错误。")
		end

		g_data.client:setLastTime("group")
	elseif SM_CREATEGROUP_FAIL == value3 then
		if msg.recog == -1 then
			callback4("发起人已经创建队伍")
		elseif msg.recog == -2 then
			callback4("玩家名错误或不在线")
		elseif msg.recog == -6 then
			callback4("发起人不允许创建队伍")
		elseif msg.recog == -3 then
			callback4("该玩家已有队伍")
		elseif msg.recog == -4 then
			callback4("接受人不允许组队")
		elseif msg.recog == -10 then
			callback4("不可邀请自己组队")
		else
			callback4("未知错误")
		end

		g_data.client:setLastTime("group")
	elseif SM_GROUPADDMEM_OK == value3 then
		g_data.client:setLastTime("group")
	elseif SM_GROUPADDMEM_FAIL == value3 then
		if msg.recog == -1 then
			callback4("发起人不是队长")
		elseif msg.recog == -2 then
			callback4("玩家名错误或不在线")
		elseif msg.recog == -3 then
			callback4("该玩家已有队伍")
		elseif msg.recog == -4 then
			callback4("接受人不允许组队")
		elseif msg.recog == -5 then
			callback4("队伍已满")
		elseif msg.recog == -10 then
			callback4("不可邀请自己组队")
		else
			callback4("未知错误")
		end

		g_data.client:setLastTime("group")
	elseif SM_GROUPDELMEM_OK == value3 then
		g_data.client:setLastTime("group")
		g_data.player:delGroupMember(buf)

		if self.panels.group and self.panels.group.page == "mine" then
			self.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		end
	elseif SM_GROUPDELMEM_FAIL == value3 then
		if msg.recog == -1 then
			callback4("队员不能删除其他成员")
		elseif msg.recog == -2 then
			callback4("输入的人物名称不正确")
		elseif msg.recog == -3 then
			callback4("删除目标不是队伍成员")
		else
			callback4("未知错误")
		end

		g_data.client:setLastTime("group")
	elseif SM_GROUPCANCEL == value3 then
		g_data.player:setGroupMembers(nil)
		g_data.player:setTeamLeader(false)

		if self.panels.group and self.panels.group.page == "mine" then
			self.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		end
	elseif SM_GROUPMEMBERS == value3 then
		g_data.player:initGroupMembers(msg, buf, bufLen)
		g_data.player:setTeamLeader(false)

		for _4, groupMember in ipairs(g_data.player.groupMembers) do
			if groupMember:get("name") == common.getPlayerName() and groupMember:get("isCaptain") == 1 then
				g_data.player:setTeamLeader(true)

				break
			end
		end

		if self.panels.group and self.panels.group.page == "mine" then
			self.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		end
	elseif SM_QUERY_NEARBYGROUP == value3 then
		g_data.player:initNearGroup(msg, buf, bufLen)

		if self.panels.group then
			self.panels.group:showPageInfo("group", g_data.player.nearGroupInfo)
		end
	elseif SM_QUERY_NEARBYPLAYER == value3 then
		local value26 = g_data.relation:decodeNearPlayerBuf(msg, buf, bufLen)

		for _5, item3 in pairs(value26) do
			local value27 = item3:get("name")
			local job = item3:get("job")
			local level = item3:get("level")

			if value27 then
				local heroWithName = main_scene.ground.map:findHeroWithName(value27)

				if heroWithName then
					heroWithName.job = job
					heroWithName.level = level
				end

				local value28 = g_data.player.cacheRoles[value27]

				if not value28 then
					value28 = {}
					g_data.player.cacheRoles[value27] = value28
				end

				if level then
					value28.level = level
				end

				if job then
					value28.job = job
				end
			end
		end

		if self.panels.group and self.panels.group.page == "near" then
			self.panels.group:showPageInfo("near", value26)
		end

		if self.panels.relation and self.panels.relation.page == "near" then
			self.panels.relation:showContent("near", value26)
		end
	elseif SM_NotifyGroupMessage == value3 then
		local value29 = net.str(buf)
		local value30 = msg.param

		if msg.recog == 1 then
			self.notice:addMsg("FriendApply", {
				value29,
				value30
			})
		else
			self.notice:removeMsg("FriendApply", {
				value29,
				value30
			})
		end
	elseif SM_ORDER_LIST == value3 then
		g_data.client:setLastTime("top")

		if self.panels.top then
			self.panels.top:processUpt(msg.param, msg, buf, bufLen)
		end
	elseif SM_CORPS_NOTICE == value3 then
		dump(msg)

		if msg.param == 0 then
			g_data.guild.clanNotice = bufLen > 0 and net.str(buf) or ""
		end
	elseif SM_GILD_NOTICE == value3 then
		if msg.param == 0 then
			g_data.guild.guildNotice = bufLen > 0 and net.str(buf) or ""
		end
	elseif SM_FIND_CORPS_BYNAME == value3 then
		dump(msg)

		g_data.guild.serach = true

		g_data.guild:initClanList(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "clan" then
			self.panels.guild:uirefushContent("clan")
		end
	elseif SM_FIND_GILD_BYNAME == value3 then
		dump(msg)

		g_data.guild.serach = true

		g_data.guild:initGuildList(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "tguild" then
			if self.panels.guild.showGuildListNode then
				self.panels.guild:showGuildList()
			else
				self.panels.guild:uirefushContent("tguild")
			end
		end
	elseif SM_CORPS_GET_RECRUIT_CONDITION == value3 then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			self.panels.guild:recruitCondition(msg, buf, bufLen)
		end
	elseif SM_PLAYER_POSITION == value3 then
		g_data.guild.posInfo = msg.tag

		local items3 = {
			"",
			"副队长",
			"队长",
			"副会长",
			"会长"
		}
	elseif SM_PLAYER_GILD == value3 then
		g_data.guild:initGuildInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "tguild" then
			self.panels.guild.subpage = nil

			self.panels.guild:uirefushContent("tguild")
		end
	elseif SM_PLAYER_CORPS == value3 then
		g_data.guild:initClanInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "clan" then
			self.panels.guild.subpage = nil

			self.panels.guild:uirefushContent("clan")
		end
	elseif SM_REFRESH_GILDINFO == value3 then
		g_data.guild:initGuildInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "tguild" and self.panels.guild.subpage == "guildmain" then
			self.panels.guild:refush("guildmain")
		end
	elseif SM_REFRESH_CORPSINFO == value3 then
		g_data.guild:initClanInfo(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.page == "clan" and self.panels.guild.subpage == "clanmain" then
			self.panels.guild:refush("clanmain")
		end
	elseif SM_CORPS_LIST == value3 then
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
	elseif SM_CORPS_REQUEST_JOIN == value3 then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			self:fadeLabel("申请加入战队成功")
		end
	elseif SM_CORPS_CANCEL_JOIN == value3 then
		if msg.param == 0 then
			self:fadeLabel("取消申请加入战队成功")
		end
	elseif SM_CORPS_TRANSFER_CAPTAIN == value3 then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 200,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	elseif SM_CORPS_APPOINT_VICE_CAPTAIN == value3 or SM_CORPS_DISMISS_VICE_CAPTAIN == value3 then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 200,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	elseif SM_CORPS_STEPDOWN == value3 then
		if msg.param ~= 0 then
			if self.panels.guild then
				self.panels.guild:showError(msg.param)
			end
		else
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 200,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	elseif SM_CORPS_EXIT == value3 then
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
	elseif SM_CORPS_QUERY_REQUESTS == value3 then
		g_data.guild:getCorpsQueryRequests(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.subpage == "clanjobs" then
			self.panels.guild:refush("clanjobs")
		end
	elseif SM_CORPS_ACCEPT_REQUEST == value3 then
		if msg.param == 0 then
			net.send({
				CM_CORPS_QUERY_REQUESTS,
				tag = 200,
				param = 0
			})
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 200,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_REFUSE_REQUEST == value3 then
		if msg.param == 0 then
			net.send({
				CM_CORPS_QUERY_REQUESTS,
				tag = 200,
				param = 0
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_DISMISS_MEMBER == value3 then
		if msg.param == 0 then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 200,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_CREATE == value3 then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_MEMBER_LIST == value3 then
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
	elseif SM_CORPS_SET_MEMBER_TITLE == value3 then
		if msg.param == 0 then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 200,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_SEND_APPLYCORPS_ID == value3 then
		g_data.guild:refushCurClan(msg, buf, bufLen)

		local instance = cc.Director:getInstance():getEventDispatcher()
		local value31 = cc.EventCustom:new("UpdateNilClanState")

		instance:dispatchEvent(value31)
	elseif SM_SEND_APPLYGILD_ID == value3 then
		g_data.guild:refushCurGuild(msg, buf, bufLen)

		local instance2 = cc.Director:getInstance():getEventDispatcher()
		local value32 = cc.EventCustom:new("UpdateNilGuildState")

		instance2:dispatchEvent(value32)
	elseif SM_CORPS_DIRECT_ADD_MEMBER == value3 then
		if msg.param == 0 then
			self:fadeLabel("面对面找人请求发送成功！")
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CORPS_QUERY_LOG == value3 then
		g_data.guild:getCorpsLog(msg, buf, bufLen)

		if self.panels.guild then
			self.panels.guild:refush("clanlog")
		end
	elseif SM_GILD_LIST == value3 then
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
	elseif SM_GILD_EXIT == value3 then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_CORPS == value3 then
		if msg.param == 0 then
			g_data.guild:getguildcorpsList(msg, buf, bufLen)

			if self.panels.guild then
				self.panels.guild:refush("claninfo")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_REQUEST_JOIN_LIST == value3 then
		if msg.param == 0 then
			g_data.guild:getGuildQueryRequests(msg, buf, bufLen)

			if self.panels.guild and self.panels.guild.subpage == "clanrecruit" then
				self.panels.guild:refush("clanrecruit")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_REQUEST_JOIN == value3 then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_ACCEPT_REQUEST == value3 then
		if msg.param == 0 then
			if msg.recog == 1 then
				net.send({
					CM_GILD_QUERY_REQUEST_JOIN_LIST,
					tag = 200,
					series = 0
				})
			elseif msg.recog == 2 then
				net.send({
					CM_GILD_QUERY_REQUEST_UNION_LIST,
					tag = 200,
					series = 0
				})
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_REFUSE_REQUEST == value3 then
		if msg.param == 0 then
			if msg.recog == 1 then
				net.send({
					CM_GILD_QUERY_REQUEST_JOIN_LIST,
					tag = 200,
					series = 0
				})
			elseif msg.recog == 2 then
				net.send({
					CM_GILD_QUERY_REQUEST_UNION_LIST,
					tag = 200,
					series = 0
				})
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_DISMISS_CORPS == value3 then
		if msg.param == 0 then
			net.send({
				CM_GILD_QUERY_CORPS
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_CHANGE_MEMBER == value3 then
		-- block empty
	elseif SM_GILDMEMBER_LIST == value3 then
		if msg.param == 0 then
			g_data.guild:getguildMem(msg, buf, bufLen)

			if self.panels.guild then
				self.panels.guild:refush("mem")
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_LOG == value3 then
		g_data.guild:getGuildLog(msg, buf, bufLen)

		if self.panels.guild then
			self.panels.guild:refush("log")
		end
	elseif SM_GILD_QUERY_REQUEST_UNION_LIST == value3 then
		g_data.guild:getRequestUnion(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
			self.panels.guild:showSubDiplomatic4()
		end
	elseif SM_GILD_REQUEST_UNION == value3 then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_BREAK_UNION == value3 then
		if msg.param ~= 0 and self.panels.guild then
			self.panels.guild:showError(msg.param)
		end

		net.send({
			CM_GILD_QUERY_UNION,
			tag = 200,
			series = 0
		})
	elseif SM_GILD_QUERY_HOSTILE == value3 then
		if msg.param == 0 then
			g_data.guild:getHostile(msg, buf, bufLen)

			if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
				self.panels.guild:showSubDiplomatic2()
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_QUERY_UNION == value3 then
		g_data.guild:getUnion(msg, buf, bufLen)

		if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
			if self.panels.guild.showGuildListNode then
				self.panels.guild:showGuildList()
			else
				self.panels.guild:showSubDiplomatic1()
			end
		end
	elseif SM_GILD_QUERY_CONCERN == value3 then
		if msg.param == 0 then
			g_data.guild:getConcern(msg, buf, bufLen)

			if self.panels.guild and self.panels.guild.subpage == "diplomatic" then
				self.panels.guild:showSubDiplomatic3()
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_VICECAPTAIN_STEPDOWN == value3 or SM_GILD_DISMISS_VICECAPTAIN == value3 or SM_GILD_APPOINT_VICE_PRESIDENT == value3 or SM_GILD_TRANSFER_PRESIDENT == value3 then
		if msg.param == 0 then
			net.send({
				CM_GILDMEMBER_LIST
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_CONCERN_GILD_ID == value3 then
		if msg.param == 0 then
			net.send({
				CM_GILD_QUERY_CONCERN,
				tag = 200,
				series = 0
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_CANCLE_CONCERN == value3 then
		if msg.param == 0 then
			net.send({
				CM_GILD_QUERY_CONCERN,
				tag = 200,
				series = 0
			})
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_DECLARE_WAR == value3 then
		if msg.param == 0 then
			if self.panels.guild then
				if self.panels.guild.threeSub == 2 then
					net.send({
						CM_GILD_QUERY_HOSTILE,
						tag = 200,
						series = 0
					})
				elseif self.panels.guild.threeSub == 3 then
					net.send({
						CM_GILD_QUERY_CONCERN,
						tag = 200,
						series = 0
					})
				end
			end
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_GILD_ENABLE_UNION == value3 then
		if msg.param == 0 then
			local value33 = g_data.guild.guildInfo:get("enableUnion")

			g_data.guild.guildInfo:set("enableUnion", value33 == 0 and 1 or 0)
		elseif self.panels.guild then
			self.panels.guild:showError(msg.param)
		end
	elseif SM_SEND_REFUSE_REQUEST == value3 then
		if bufLen == getRecordSize("TRefuseRequestType") then
			local record4 = getRecord("TRefuseRequestType")

			net.record(record4, buf, bufLen)

			local text5 = ""

			if record4:get("type") == 3 then
				text5 = record4:get("name") .. " 拒绝了您的联盟请求！"
			else
				text5 = "您加入" .. (record4:get("type") == 1 and "战队 " or "行会 ") .. record4:get("name") .. " 的请求已经被拒绝!"
			end

			self:fadeLabel(text5)
		end
	elseif SM_STRENGTHEN_EQUIP_QUEST == value3 then
		if self.panels.fusion then
			self.panels.fusion:addItems(msg, buf, bufLen)
		end
	elseif SM_STRENGTHEN_EQUIP == value3 then
		if self.panels.fusion then
			self.panels.fusion:fusionEquip(msg, buf, bufLen)
		end
	elseif SM_UPDATE_CLOTHES == value3 then
		if msg.recog == 0 then
			self:tip("强化成功")

			if self.panels.strengthen then
				self.panels.strengthen:showResult()
			end
		elseif self.panels.strengthen then
			self.panels.strengthen:showError(msg)
		end
	elseif SM_SHOPITEMS == value3 then
		if bufLen == 0 then
			return
		end

		local value34 = g_data.shop:parseContent(msg, buf, bufLen)

		if self.panels.shop then
			self.panels.shop:processUpt(msg.param, value34)
		end
	elseif SM_FIRSTSHOP == value3 then
		if bufLen == 0 then
			return
		end

		local value35 = g_data.shop:parseSpecially(buf, bufLen)

		if self.panels.shop then
			self.panels.shop:processUpt(5, value35)
		end
	elseif SM_DOSHOP_FAIL == value3 then
		import(".panel.shop", value).onDoShopFail(value3, msg.recog, msg.param)
	elseif SM_HERO_ABILITY == value3 then
		g_data.hero:setAbility(msg, buf, bufLen)
		main_scene.ground.map:addMsg({
			isHero = true,
			roleid = g_data.hero.roleid,
			job = g_data.hero.job
		})

		if self.panels.heroHead then
			self.panels.heroHead:upt()
		end
	elseif SM_GLORYFEALTY == value3 then
		g_data.hero:setGloryFealty(msg.param, msg.tag)
	elseif SM_HERO_BAGITEMS == value3 then
		g_data.hero:setBagSize(msg.series)
		g_data.heroBag:set(buf, bufLen)

		if self.panels.heroBag and not self.panels.heroBag:reloadAll(g_data.hero.bagSize) then
			self.panels.heroBag:reload()
		end
	elseif SM_HERO_BAGITEMDURACHG == value3 then
		g_data.heroBag:duraChange(msg.recog, msg.param, msg.tag, msg.series)

		if main_scene.ui.panels.heroBag then
			main_scene.ui.panels.heroBag:duraChange(msg.recog, msg.param, msg.tag, msg.series)
		end
	elseif SM_HERO_SENDUSEITEMS == value3 then
		g_data.heroEquip:set(buf, bufLen)

		if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "equip" then
			main_scene.ui.panels.heroEquip:showContent("equip")
		end
	elseif SM_HERO_SENDMYMAGIC == value3 then
		g_data.hero:setMagicList(buf, bufLen)

		if self.panels.heroEquip and self.panels.heroEquip.page == "skill" then
			self.panels.heroEquip:showContent("skill")
		end
	elseif SM_HERO_ADDMAGIC == value3 then
		g_data.hero:addMagic(buf, bufLen)

		if self.panels.heroEquip and self.panels.heroEquip.page == "skill" then
			self.panels.heroEquip:showContent("skill")
		end
	elseif SM_HERO_WINEXP == value3 then
		g_data.hero.ability:set("Exp", msg.recog)

		local long2 = MakeLong(msg.param, msg.tag)

		self:tip(long2 .. " 英雄经验值增加")

		if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
			main_scene.ui.panels.heroEquip:showContent("state")
		end
	elseif SM_HERO_MAGIC_LVEXP == value3 then
		local value36 = g_data.hero:setMagicExp(msg, buf, bufLen)

		if value36 and self.panels.heroEquip then
			self.panels.heroEquip:updateMagic(value36:get("magicId"))
		end
	elseif SM_HERO_UNIONSTATUS == value3 then
		g_data.hero:setUnionState(msg.recog, msg.param)
		main_scene.ui.console:call("btnHeroSkill", "hero_upt_union")
	elseif SM_HERO_DURACHANGE == value3 then
		g_data.heroEquip:duraChange(msg.param, msg.recog, MakeLong(msg.tag, msg.series))
	elseif SM_HERO_LEVELUP == value3 then
		g_data.hero:setBagSize(msg.tag)
		g_data.hero.ability:set("level", msg.param)
		self:tip("你的英雄升级了")

		if self.panels.heroBag then
			self.panels.heroBag:reloadAll(g_data.hero.bagSize)
		end

		if self.panels.heroHead then
			self.panels.heroHead:upt()
		end
	elseif SM_TOHEROBAG_OK == value3 then
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
			callback32(true)
		end
	elseif SM_TOHEROBAG_FAIL == value3 then
		if g_data.client.heroPutInItem then
			g_data.bag:addItem(g_data.client.heroPutInItem)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
			end

			g_data.client:setHeroPutInItem()
		end
	elseif SM_TOHUMBAG_OK == value3 then
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
			callback32()
		end
	elseif SM_TOHUMBAG_FAIL == value3 then
		if g_data.client.heroGetBackItem then
			g_data.heroBag:addItem(g_data.client.heroGetBackItem)

			if main_scene.ui.panels.heroBag then
				main_scene.ui.panels.heroBag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
			end

			g_data.client:setHeroGetBackItem()
		end
	elseif SM_HERO_ADDITEM == value3 then
		local items4 = g_data.heroBag:add(buf, bufLen)

		for index3 = 1, #items4 do
			local response2 = items4[index3]

			if response2.where == "bag" and self.panels.heroBag then
				self.panels.heroBag:addItem(response2.data:get("makeIndex"))
			end
		end

		callback32(true)
	elseif SM_HERO_DELITEM == value3 then
		local value37 = msg.recog

		if g_data.heroBag:delItem(value37) and self.panels.heroBag then
			self.panels.heroBag:delItem(value37)
		end

		if g_data.heroEquip:delItem(value37) and self.panels.heroEquip then
			self.panels.heroEquip:delItem(value37)
		end
	elseif SM_HERO_DROPITEM_SUCCESS == value3 then
		g_data.heroBag:throwEnd(msg.recog, true)
	elseif SM_HERO_DROPITEM_FAIL == value3 then
		g_data.heroBag:throwEnd(msg.recog, false)

		if self.panels.heroBag then
			self.panels.heroBag:addItem(msg.recog)
		end
	elseif SM_HERO_EAT_OK == value3 then
		g_data.heroBag:useEnd("eat", true)
	elseif SM_HERO_EAT_FAIL == value3 then
		local value38, value39, value40, value41 = g_data.heroBag:useEnd("eat", false)

		if value38 and self.panels.heroBag and value41 == "bag" then
			self.panels.heroBag:addItem(value38)
		end
	elseif SM_HERO_TAKEON_OK == value3 then
		local value42 = g_data.heroBag:useEnd("take", true)

		if self.panels.heroEquip and value42 then
			self.panels.heroEquip:setItem(value42)
		end
	elseif SM_HERO_TAKEON_FAIL == value3 then
		local value43 = g_data.heroBag:useEnd("take", false)

		if self.panels.heroBag and value43 then
			self.panels.heroBag:addItem(value43)
		end
	elseif SM_MAP_RANGE_PICK == value3 then
		g_data.player.isPickUpRange = msg.param == 1 and true or false
	elseif SM_HERO_TAKEOFF_OK == value3 then
		g_data.heroEquip:takeOffEnd(true)
	elseif SM_HERO_TAKEOFF_FAIL == value3 then
		local value44 = g_data.heroEquip:takeOffEnd(false)

		if self.panels.heroEquip and value44 then
			self.panels.heroEquip:setItem(value44)
		end
	elseif SM_LOCK_EQUIP_STATE == value3 then
		common.setLockEquipState(msg, buf, bufLen)
	elseif SM_LOCKEQUIP == value3 then
		common.setBindEquipState(msg, buf, bufLen)
	elseif SM_SEND_RELATION_FRIEND == value3 then
		g_data.relation:setFriends(msg, buf, bufLen)
	elseif SM_SEND_RELATION_ATTENTION == value3 then
		g_data.relation:setAttentions(msg, buf, bufLen)
	elseif SM_SEND_RELATION_NORMBLACKLIST == value3 then
		g_data.relation:setBlackList(msg, buf, bufLen)
	elseif SM_ADD_RELATION_FRIEND_OK == value3 then
		import(".panel.relation", value).onAddFriendOk(buf, msg.recog)
	elseif SM_ADD_RELATION_FRIEND_FAIL == value3 then
		import(".panel.relation", value).onAddFriendFail(buf, msg.recog)
	elseif SM_ADD_RELATION_ATTENTION == value3 then
		import(".panel.relation", value).onAddAtt(msg.recog)
	elseif SM_ADD_RELATION_NORMBLACKLIST == value3 then
		import(".panel.relation", value).onAddBlack(msg.recog)
	elseif SM_DEL_RELATION_FRIEND == value3 then
		import(".panel.relation", value).onDelFriend(msg.recog)
	elseif SM_DEL_RELATION_ATTENTION == value3 then
		import(".panel.relation", value).onDelAtt(msg.recog)
	elseif SM_DEL_RELATION_NORMBLACKLIST == value3 then
		import(".panel.relation", value).onDelBlack(msg.recog)
	elseif SM_UPDATE_ATTENTION_COLOR == value3 then
		import(".panel.relation", value).onUptAttClr(msg.recog)
	elseif SM_UPDATE_RELATION_FRIEND == value3 then
		g_data.relation:updateFriend(msg, buf, bufLen)
	elseif SM_UPDATE_RELATION_ATTENTION == value3 then
		g_data.relation:updateAttention(msg, buf, bufLen)
	elseif SM_UPDATE_RELATION_NORMBLACKLIST == value3 then
		g_data.relation:updateBlackList(msg, buf, bufLen)
	elseif SM_RELATION_MEMBER_ONLINE == value3 then
		g_data.relation:online(msg, buf, bufLen)
	elseif SM_RELATION_MEMBER_OFFLINE == value3 then
		g_data.relation:offline(msg, buf, bufLen)
	elseif SM_QUERY_STALL == value3 then
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
	elseif SM_SET_STALL_TIMELV == value3 then
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
	elseif SM_SET_STALL_NAME == value3 then
		if msg.recog == 1 then
			self:tip("修改摊位名称成功.")
		elseif msg.recog == -1 then
			self:tip("摊位名称过长！")
		elseif msg.recog == -2 then
			self:tip("摊位名称不合法！")
		elseif msg.recog == -3 then
			self:tip("摆摊中无法进行修改！")
		end
	elseif SM_ADD_STALLITEM == value3 then
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
	elseif SM_DEL_STALLITEM == value3 then
		if msg.recog == -1 then
			self:tip("物品已售出！")
		end
	elseif SM_CANCEL_STALL == value3 then
		if msg.recog == -1 then
			-- block empty
		elseif msg.recog == -2 then
			self:tip("您的包裹空间不足,请到邮件收回物品！")
		end
	elseif SM_UPT_ADD_STALLITEM == value3 then
		local value45 = g_data.stall:uptAddItem(msg, buf, bufLen)

		if self.panels.stall then
			self.panels.stall:addItem(value45)
		end
	elseif SM_UPT_DEL_STALLITEM == value3 then
		g_data.stall:uptDelItem(msg.recog)

		if self.panels.stall then
			self.panels.stall:delItem(msg.recog)
		end
	elseif SM_START_STALL == value3 then
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
	elseif SM_PAUSE_STALL == value3 then
		if msg.recog == 1 then
			self:tip("暂停摆摊成功.")
			g_data.stall:pause()
		end
	elseif SM_BUY_STALLITEM == value3 then
		if msg.recog == -1 then
			self:tip("包裹空间不足！")
		elseif msg.recog == -2 then
			self:tip(CS_YB .. "不足！")
		elseif msg.recog == -3 then
			self:tip("金币不足！")
		elseif msg.recog == -4 then
			self:tip("已售完！")
		elseif msg.recog == -5 then
			self:tip("摊位已取消或不存在！")
		elseif msg.recog == -6 then
			self:tip("购买的物品数量超过出售数量！")
		elseif msg.recog == -7 then
			self:tip("扣除" .. CS_YB .. "失败！")
		end
	elseif SM_UPT_OTHER_DEL_STALLITEM == value3 then
		g_data.stallOther:uptDelItem(msg)

		if self.panels.stallOther then
			self.panels.stallOther:delItem(msg.recog)
		end
	elseif SM_MESSAGE_STALL == value3 then
		if msg.recog == 1 then
			self:tip("留言成功.")
		elseif msg.recog == -1 then
			self:tip("留言失败！")
		end
	elseif SM_QUERY_STALL_STATUS == value3 then
		g_data.stall:setTime(msg.recog)
	elseif SM_FETCH_MAIL_LIST == value3 then
		if msg.recog == 1 then
			g_data.mail:set(msg, buf, bufLen)

			if self.panels.mail then
				self.panels.mail:showContentByTag(msg.tag)
			end
		elseif msg.recog == -1 then
			self:tip("数据出错！")
		end
	elseif SM_SHANGMA_OK == value3 then
		if msg.recog == g_data.player.roleid then
			local btnOwner = main_scene.ui.console:get("btnHorse")

			if btnOwner then
				btnOwner.btn:select(true)
			end
		end
	elseif SM_XIAMA_OK == value3 then
		if msg.recog == g_data.player.roleid then
			local btnOwner2 = main_scene.ui.console:get("btnHorse")

			if btnOwner2 then
				btnOwner2.btn:unselect(true)
			end
		end
	elseif SM_FETCH_MAIL_INFO == value3 then
		if msg.recog == 1 then
			local value46, value47 = g_data.mail:parseMail(msg, buf, bufLen)

			if self.panels.mail then
				self.panels.mail:showMail(value46, value47)
			end
		elseif value3 == -1 then
			self:tip("邮件查询失败！")
		end
	elseif SM_FETCH_ATTACH == value3 then
		if msg.recog == 1 then
			local value48, value49 = g_data.mail:attach()

			if value48 and value49 and self.panels.mail then
				self.panels.mail:showMail(value48, value49)
			end

			self:fadeLabel("领取附件成功.")
		elseif msg.recog == -1 then
			self:tip("您的包裹空间不足！")
		elseif msg.recog == -2 then
			self:tip("没有奖励可以领取！")
		elseif msg.recog == -3 then
			self:tip("金币超过上限！")
		elseif msg.recog == -4 then
			self:tip("领取" .. CS_YB .. "失败！")
		elseif msg.recog == -5 then
			self:tip("不在安全区无法领取附件！")
		end

		if msg.recog ~= 1 and self.panels.mail then
			self.panels.mail:stopAuto()
		end
	elseif SM_DEL_MAIL == value3 then
		if msg.recog == 1 then
			local value50, value51, value52 = g_data.mail:del()

			if value50 and value52 and self.panels.mail then
				if value52 == "sys" then
					self.panels.mail:showMail(value51, value52)
				elseif value52 == "sell" then
					self.panels.mail:delMail(value50, value52)
				end
			end
		elseif msg.recog == -1 then
			self:tip("删除邮件失败！")
		end
	elseif SM_FETCH_ATTACH_OFFTM == value3 then
		if msg.recog == 1 then
			local value53 = g_data.mail:attachOfftm()

			if self.panels.mail then
				self.panels.mail:showContentByTag(value53)
			end
		elseif msg.recog == -1 then
			self:tip("您的包裹空间不足！")
		elseif msg.recog == -2 then
			self:tip("没有过期摊位物品！")
		end
	elseif SM_MAIL_INFO == value3 then
		g_data.mail:setUnreadMailCnt(msg.recog)
		self.notice:uptMailCnt(g_data.mail.unreadCnt, msg.tag)
	elseif CM_CLEAR_ALLMAIL == value3 then
		if msg.recog == 1 then
			self:tip("清除成功")
		elseif msg.recog == -1 then
			self:tip("清除失败！")
		end

		if self.panels.mail then
			self.panels.mail:refresh()
		end
	elseif checkExist(value3, SM_YBDEAL_QUERY_BUY, SM_YBDEAL_QUERY_SELL, SM_YBDEAL_HISTROY_BUY, SM_YBDEAL_HISTROY_SELL) then
		local tag2 = g_data.ybdeal:parseMsg(msg, buf, bufLen)

		if self.panels.ybdeal then
			self.panels.ybdeal:upt(tag2)
		else
			self:showPanel("ybdeal", {
				tag = tag2
			})
		end
	elseif SM_YBDEAL_BUY == value3 then
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
			self:tip(CS_YB .. "不足！")
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
	elseif SM_YBDEAL_BUY_CANCEL == value3 then
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
	elseif SM_YBDEAL_REFER_ITEMS1 == value3 then
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
	elseif SM_YBDEAL_REFER_ITEMS2 == value3 then
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
	elseif SM_YBDEAL_SELL_CANCEL == value3 then
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
	elseif SM_DISPLAY_YBDEAL_SET == value3 then
		local tag3 = g_data.ybdeal:parseSetting(msg)

		if self.panels.ybdeal then
			self.panels.ybdeal:upt(tag3)
		else
			self:showPanel("ybdeal", {
				tag = tag3
			})
		end
	elseif SM_YBDEAL_Set_Operate == value3 then
		if msg.recog == 0 then
			self:tip("设置成功.")
		elseif msg.recog == -1 then
			self:tip("设置错误,设定等级超过最大等级999！")
		end
	elseif SM_CHANNEL_CREATE == value3 then
		if msg.recog ~= 0 then
			local voice, voice2 = import(".panel.voice", value).handleCode(msg.recog)

			an.newMsgbox(voice2)
		end
	elseif SM_CHANNEL_ENTER == value3 then
		if SupportOnlineVoice then
			local value54 = g_data.voice.roomData:get("ID")

			yaya.login(value54)
		end

		if msg.recog ~= 0 then
			local voice3, voice4 = import(".panel.voice", value).handleCode(msg.recog)

			an.newMsgbox(voice4)
		end
	elseif SM_CHANNEL_EXIT == value3 then
		if msg.recog ~= 0 then
			local voice5, voice6 = import(".panel.voice", value).handleCode(msg.recog)

			an.newMsgbox(voice6)
		end

		if SupportOnlineVoice then
			yaya.logout()
		end
	elseif SM_CHANNEL_CHANGE_MODE == value3 then
		if msg.recog ~= 0 then
			local voice7, voice8 = import(".panel.voice", value).handleCode(msg.recog)

			an.newMsgbox(voice8)
		end
	elseif SM_CHANNEL_CHANGE_MUTE == value3 then
		if msg.recog ~= 0 then
			local voice9, voice10 = import(".panel.voice", value).handleCode(msg.recog)

			an.newMsgbox(voice10)
		end
	elseif SM_CHANNEL_KICK_OUT == value3 then
		if msg.recog ~= 0 then
			local voice11, voice12 = import(".panel.voice", value).handleCode(msg.recog)

			an.newMsgbox(voice12)
		end
	elseif SM_SEND_CHANNEL_LIST == value3 then
		if self.panels.voice then
			self.panels.voice:recvChannelList(msg, buf, bufLen)
		end
	elseif SM_SEND_CHANNEL_MEMBERS == value3 then
		if msg.series == 1 then
			g_data.voice:setMembers(msg, buf, bufLen, msg.tag, common.getPlayerName())
		end

		if self.panels.voice then
			self.panels.voice:recvMemberList(msg, buf, bufLen, msg.tag, msg.series == 1)
		end
	elseif SM_NOTIFY_CHANNEL_ENTER == value3 then
		local value55 = net.str(buf)
		local value56, value57 = g_data.voice:memberJoin(msg.param, value55, msg.tag)

		if value56 and self.panels.voice then
			self.panels.voice:memberJoin(value56, value57)
		end
	elseif SM_NOTIFY_CHANNEL_EXIT == value3 then
		local value58 = net.str(buf)
		local value59, value60 = g_data.voice:memberExit(value58, msg.tag, common.getPlayerName())

		if value59 then
			local text6

			if SupportOnlineVoice then
				yaya.logout()
			end

			if msg.tag == 1 then
				text6 = "你被管理员踢出语音频道"
			elseif msg.tag == 2 then
				text6 = "你已退出语音频道"
			elseif msg.tag == 3 then
				text6 = "你所在的语音频道已解散"
			end

			if self.panels.voice then
				self.panels.voice:exitChannel(msg.tag)

				if text6 then
					an.newMsgbox(text6)
				end
			elseif text6 then
				common.addMsg(text6, display.COLOR_RED, display.COLOR_WHITE, true)
			end

			self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		elseif self.panels.voice then
			self.panels.voice:memberExit(value58, value60)
		end
	elseif SM_NOTIFY_CHANNEL_CHANGE_MODE == value3 then
		local value61, value62 = g_data.voice:setMode(msg.param)

		if value61 and self.panels.voice then
			self.panels.voice:modeChanged(value62)
		end

		yaya.mic(false, common.getPlayerName())
		self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
	elseif SM_NOTIFY_CHANNEL_CHANGE_MUTE == value3 then
		local value63 = net.str(buf)
		local value64, value65 = g_data.voice:setIsMute(msg.param, value63)

		if value64 and self.panels.voice then
			self.panels.voice:setIsMute(value64, value65)
		end

		if value63 == common.getPlayerName() then
			yaya.mic(false, common.getPlayerName())
			self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		end
	elseif SM_NOTIFY_CHANNEL_CHANGE_ADMIN == value3 then
		local value66 = net.str(buf)
		local value67, value68 = g_data.voice:setIsAdmin(msg.param, value66)

		if value67 and self.panels.voice then
			self.panels.voice:setIsAdmin(value67, value68)
		end

		if value66 == common.getPlayerName() then
			yaya.mic(false, common.getPlayerName())
			self.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		end
	elseif SM_QUERY_MAP_NPC == value3 then
		g_data.bigmap:addNpcs(msg, buf, bufLen)

		if self.panels.bigmap then
			self.panels.bigmap:uptNpcCell()
		end
	elseif SM_MEMBERS_POSITION_INFO == value3 then
		if msg.recog == 0 then
			g_data.bigmap:getGroupInfo(msg, buf, bufLen)

			if self.panels.bigmap then
				self.panels.bigmap:uptGroupPos()
			end
		end
	elseif SM_AUTOMOVE_MAPPATH == value3 then
		g_data.bigmap:scriptAutoPath(msg, buf, bufLen)
		main_scene.ui.console.controller.autoFindPath:scriptAutoPath()
	elseif SM_GHOME_PAY_READY == value3 then
		g_data.shop:onPayReady(msg.recog, buf, common.getPlayerName())
	elseif SM_SEND_GHOME_ORDER_RESULT == value3 then
		g_data.shop:onPayResult(msg.recog, buf)
	elseif SM_GHOME_UNFINISH_ORDER == value3 then
		-- block empty
	elseif SM_PLAYER_AUTHEN == value3 then
		g_data.credit:setAuthen(msg)
	elseif SM_NOWDEATH == value3 then
		if msg.recog == g_data.player.roleid then
			self.centerTopTip:show("relive")
		end
	elseif SM_SEND_MAKEDDRUG_CONFIG == value3 then
		g_data.mixingDrug:saveConfig(msg, buf, bufLen)
	elseif SM_ALL_MAKEDRUG_STATUS == value3 then
		g_data.mixingDrug:set(msg, buf, bufLen)

		if self.panels.mixingDrug then
			self:hidePanel("mixingDrug")
		end

		self:showPanel("mixingDrug")
	elseif SM_MAKEDRUG_STATUS == value3 then
		local value69, value70 = g_data.mixingDrug:query(msg, buf, bufLen)

		if value69 and value70 and self.panels.mixingDrug then
			self.panels.mixingDrug:showDetail(value69, value70, msg.recog)
		end
	elseif SM_CAN_MAKEDRUG == value3 then
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
	elseif SM_GAIN_MAKEDDRUG == value3 then
		if msg.param == 1 then
			self:tip("存放成功")

			if self.panels.mixingDrug then
				self.panels.mixingDrug:refresh()
			end
		else
			self:tip("存放失败")
		end
	elseif SM_LEARN_LIVINGSKILL == value3 then
		if msg.recog == 1 then
			self:tip("学习成功")

			if self.panels.mixingDrug then
				self.panels.mixingDrug:refresh()
			end
		else
			self:tip("学习失败")
		end
	elseif SM_V_POWERSTONE == value3 then
		local text7 = ""

		if msg.param == 0 then
			local text8 = "充满着能量波动的神秘水晶，使用它可以使你增加1点活力值。"

			text7 = string.format("%s\n每个角色一天只能使用12个活力水晶,今日还可以使用%d个。", text8, msg.tag)
		elseif msg.param == 1 then
			text7 = "活力值已达上限"
		elseif msg.param == 2 then
			text7 = "今日使用个数已达上限"
		end

		an.newMsgbox(text7, function(value32)
			if value32 == 1 and msg.param == 0 and g_data.bag:use("eat", msg.recog, {
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
	elseif SM_BOX2_TRYOPEN == value3 then
		if msg.recog == 0 then
			self:showPanel("treasureBox", msg.param, buf, bufLen)
		else
			self:tip(net.str(buf))
		end
	elseif SM_BOX2_ROTATE == value3 then
		if msg.recog == 0 then
			if self.panels.treasureBox then
				self.panels.treasureBox:onRotate(msg.param)
			end
		else
			self:tip(net.str(buf))
		end
	elseif SM_BOX2_GETPRIZE == value3 then
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

function mainui.fairyTriggerAttack(self)
	local value3 = main_scene and main_scene.ground and main_scene.ground.player

	if not value3 then
		return 0
	end

	return require("mir2.scenes.main.common.magicParticle").triggerAttack(value3)
end

function mainui.fairyTriggerPickup(self)
	local value3 = main_scene and main_scene.ground and main_scene.ground.player

	if not value3 then
		return 0
	end

	return require("mir2.scenes.main.common.magicParticle").triggerPickup(value3)
end

return mainui
