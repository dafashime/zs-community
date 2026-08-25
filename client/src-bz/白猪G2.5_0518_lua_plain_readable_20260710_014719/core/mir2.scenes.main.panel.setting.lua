local setting = class("setting", function()
	return display.newNode()
end)
local magic = import("..common.magic")
local common = import("..common.common")
local hotKeySetting = import("..pc.hotKeySetting")
local cc2 = require("mir2.cc")
local items = {}

table.merge(setting, {
	tabs,
	name,
	content,
	btns,
	cfg = {
		base = false,
		autoRat = false,
		item = false,
		job = false,
		drugs = false,
		display = false,
		protected = false,
		chat = false
	}
})

function setting:onCleanup()
	for key, setting in pairs(g_data.setting) do
		if type(setting) == "table" and self.cfg[key] then
			cache.saveSetting(common.getPlayerName(), key)

			self.cfg[key] = false
		end
	end

	if self.modifiedItem then
		main_scene.ground.map:updateItems()
		main_scene.ui.console.autoRat:updateModifyProperty()
	end
end

function setting:ctor(value2)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)
	self.setCascadeOpacityEnabled(self, true)

	local value_2 = res.get2("pic/common/settingbg.png"):anchor(0, 0):add2(self)

	self.size(self, value_2.getw(value_2), value_2.geth(value_2)):anchor(0.5, 0.5):pos(display.cx, display.cy + 20)
	res.get2("pic/panels/setting/title.png"):anchor(0.5, 1):pos(self.getw(self) / 2, self.geth(self) - 12):add2(value_2)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self)

	if package.loaded["mir2.settingConfig"] then
		package.loaded["mir2.settingConfig"] = nil
	end

	items = require("mir2.settingConfig")
	self.name = nil
	self.content = nil

	self.initTabList(self)
end

function setting:updateServerTime(deltaTime)
	if self.name == "常用" and self.serverTime and self.serverTime.setString then
		self.serverTime:setString(string.format("服务器时间: %s", os.date("%Y年%m月%d日 %H:%M:%S", deltaTime)))
	end
end

function setting:initTabList()
	self.tabs = {}

	local text = "常用"
	local items2 = {}
	local items3 = {}

	if def.role.mainsetting.banProtect or def.role.mainsetting.needProtect then
		items2 = {
			"常用",
			"物品",
			"保护",
			"药品",
			"挂机",
			"显示",
			"聊天"
		}
		items3 = {
			"jb",
			"wp",
			"bh",
			"yp",
			"fz",
			"xs",
			"lt"
		}
	else
		items2 = {
			"常用",
			"物品",
			"药品",
			"挂机",
			"显示",
			"聊天"
		}
		items3 = {
			"jb",
			"wp",
			"yp",
			"fz",
			"xs",
			"lt"
		}
	end

	if WIN32_OPERATE then
		local items4 = {
			{
				name = "快捷键",
				spr = "kj"
			}
		}

		for _, item2 in ipairs(items4) do
			table.insert(items2, item2.name)
			table.insert(items3, item2.spr)
		end
	end

	local enabled = true

	local function callback(self2)
		sound.playSound("103")

		if not enabled then
			return
		end

		local count = 1

		for index3, tab in ipairs(self.tabs) do
			if tab == self2 then
				tab.select(tab)

				count = index3
			else
				tab.unselect(tab)
			end
		end

		if items2[count] ~= self.name then
			self:load(items2[count])
		end
	end

	self.tabList = an.newScroll(12, 20, 127, 465):add2(self)

	self.tabList:enableTouch(WIN32_OPERATE)

	local node = display.newNode():pos(12, 15):size(127, 390):add2(self)

	node.setTouchEnabled(node, true)
	node.setTouchSwallowEnabled(node, false)
	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			node.offsetBeginY = offsetBeginY.y
			enabled = true

			return true
		elseif offsetBeginY.name == "moved" then
			local value2 = offsetBeginY.y - node.offsetBeginY

			if math.abs(value2) >= 5 then
				enabled = false
			end
		end
	end)

	for index2, item3 in ipairs(items2) do
		self.tabs[index2] = an.newBtn(res.gettex2("pic/common/btn60.png"), callback, {
			label = {
				items2[index2],
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
		}):anchor(0.5, 0):add2(self.tabList):pos(61, 400 - (index2 - 1) * 50)

		self.tabs[index2]:setCascadeOpacityEnabled(true)
		self.tabs[index2]:setTouchSwallowEnabled(false)

		if (text or items2[1]) == item3 then
			callback(self.tabs[index2])
		end
	end
end

function setting.createToggle(self4, callback, value2, label2, temp, value7)
	local value5
	local value6

	temp = temp or {}

	local btn = display.newNode()
	local filteredSprite = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(btn)

	filteredSprite.setName(filteredSprite, "selsp")
	btn.setContentSize(btn, filteredSprite.getContentSize(filteredSprite))

	function btn:setIsSelect(isSelected)
		btn.isSelected = isSelected

		if isSelected then
			btn:select()
		else
			btn:unselect()
		end
	end

	function btn.isSelect(self5)
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

	function btn.select_temp(self6)
		if btn.temp then
			return
		end

		btn.temp = display.newFilteredSprite(res.gettex2(temp.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(btn)

		btn.temp:setOpacity(80)
	end

	function btn.unselect(self3)
		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		btn.isSelected = false

		filteredSprite:setTex(res.gettex2("pic/common/toggle00.png"))
	end

	if value2 ~= nil then
		btn.setIsSelect(btn, value2)
	end

	filteredSprite.setTouchEnabled(filteredSprite, true)
	filteredSprite.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			btn.offsetBeginY = offsetBeginY.y
			btn.offsetBeginX = offsetBeginY.x

			return true
		elseif offsetBeginY.name == "ended" then
			local value3 = offsetBeginY.y - btn.offsetBeginY
			local value4 = offsetBeginY.x - btn.offsetBeginX

			if math.abs(value3) <= 20 and math.abs(value4) <= 20 then
				btn:setIsSelect(not btn.isSelected)
				callback(btn.isSelected)
			end
		end
	end)
	filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

	if label2 then
		btn.label = an.newLabel(unpack(label2)):add2(btn):pos(btn.getw(btn) + 7, btn.geth(btn) / 2):anchor(0, 0.5)

		function btn.getw(self7)
			return btn.label:getw() + 40
		end
	end

	btn.btn = btn

	function btn.gray(self8)
		local filter = res.getFilter("gray")

		filteredSprite:setFilter(filter)
		btn:setTouchEnabled(false)

		if btn.temp then
			btn.temp:setFilter(filter)
		end
	end

	function btn.disGray(self9)
		filteredSprite:clearFilter()
		btn:setTouchEnabled(true)

		if btn.temp then
			btn.temp:clearFilter(f)
		end
	end

	function btn.setGray(self10, gray)
		if gray then
			btn:gray()
		else
			btn:disGray()
		end

		return btn
	end

	return btn
end

local function cleanup(self4, value2, label2, temp)
	local value5
	local value6

	temp = temp or {}

	local btn = display.newNode()
	local filteredSprite = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(btn)

	filteredSprite.setName(filteredSprite, "selsp")
	btn.setContentSize(btn, filteredSprite.getContentSize(filteredSprite))

	function btn:setIsSelect(isSelected)
		btn.isSelected = isSelected

		if isSelected then
			btn:select()
		else
			btn:unselect()
		end
	end

	function btn.isSelect(self5)
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

	function btn.select_temp(self6)
		if btn.temp then
			return
		end

		btn.temp = display.newFilteredSprite(res.gettex2(temp.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(btn)

		btn.temp:setOpacity(80)
	end

	function btn.unselect(self3)
		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		btn.isSelected = false

		filteredSprite:setTex(res.gettex2("pic/common/toggle00.png"))
	end

	if value2 ~= nil then
		btn.setIsSelect(btn, value2)
	end

	filteredSprite.setTouchEnabled(filteredSprite, true)
	filteredSprite.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			btn.offsetBeginY = offsetBeginY.y
			btn.offsetBeginX = offsetBeginY.x

			return true
		elseif offsetBeginY.name == "ended" then
			local value3 = offsetBeginY.y - btn.offsetBeginY
			local value4 = offsetBeginY.x - btn.offsetBeginX

			if math.abs(value3) <= 20 and math.abs(value4) <= 20 then
				btn:setIsSelect(not btn.isSelected)
				self4(btn.isSelected)
			end
		end
	end)
	filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

	if label2 then
		btn.label = an.newLabel(unpack(label2)):add2(btn):pos(btn.getw(btn) + 7, btn.geth(btn) / 2):anchor(0, 0.5)

		function btn.getw(self7)
			return btn.label:getw() + 40
		end
	end

	btn.btn = btn

	function btn.gray(self8)
		local filter = res.getFilter("gray")

		filteredSprite:setFilter(filter)
		btn:setTouchEnabled(false)

		if btn.temp then
			btn.temp:setFilter(filter)
		end
	end

	function btn.disGray(self9)
		filteredSprite:clearFilter()
		btn:setTouchEnabled(true)

		if btn.temp then
			btn.temp:clearFilter(f)
		end
	end

	function btn.setGray(self10, gray)
		if gray then
			btn:gray()
		else
			btn:disGray()
		end

		return btn
	end

	return btn
end

function setting:add(value2, value3, value4, callback, value5, value6)
	local node = display.newNode():size(120, 28):anchor(0, 0.5)

	node.btn = self.createToggle(self, function(btn)
		if not value5 then
			value2[value3] = btn
		end

		if callback then
			callback(value2[value3])

			return
		end
	end, value2[value3], {
		value4,
		20,
		1,
		{
			color = cc.c3b(220, 210, 190)
		}
	}, nil, value6):anchor(0, 0.5):pos(0, 14):add2(node)

	return node
end

function setting:addWith(value2, value3, value4, value5, value6)
	return
end

function setting:loadBase()
	local function callback(...)
		return self:add(g_data.setting.base, ...)
	end

	local x = 15
	local h2 = self.content:geth() - 30
	local number = 47
	local number2 = 145

	self.btns.heroShowName = callback("heroShowName", "人物显名", function(value9)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHeroName")
	end, true):pos(x, h2):add2(self.content).btn

	local y2 = h2 - number

	self.btns.NPCShowName = callback("NPCShowName", "NPC显名", function(value10)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNPCShowName")
	end, true):pos(x, y2):add2(self.content).btn

	local y3 = y2 - number

	self.btns.petShowName = callback("petShowName", "宠物显名", function(value11)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPetShowName")
	end, true):pos(x, y3):add2(self.content).btn

	local y4 = y3 - number

	self.btns.monShowName = callback("monShowName", "怪物显名", function(value12)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnMonShowName")
	end, true):pos(x, y4):add2(self.content).btn

	local y5 = y4 - number

	self.btns.hiBlood = callback("hiBlood", "高亮显血", function(value13)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "hiBlood")
		main_scene.ground.player.info.hp.spr:setTex(g_data.setting.base.hiBlood and res.gettex2("pic/common/hp_green.png") or res.getuitex(3, 1))
	end, true):pos(x, y5):add2(self.content).btn

	local y6 = y5 - number

	self.btns.lockColor = callback("lockColor", "锁定光圈", function(value4)
		self.cfg.base = true

		if value4 then
			for _, hero in pairs(main_scene.ground.map.heros) do
				hero.unselected(hero)
			end

			for _2, mon in pairs(main_scene.ground.map.mons) do
				mon.unselected(mon)
			end
		end

		main_scene.ui.console.btnCallbacks:handle("setting", "lockColor")
	end, true):pos(x, y6):add2(self.content).btn

	local y7 = y6 - number

	self.btns.warningDura = callback("warningDura", "持久警告", function(value14)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "warningDura")
	end, true):pos(x, y7):add2(self.content).btn

	local y8 = y7 - number

	self.btns.showGuildName = callback("showGuildName", "显示行会", function(value15)
		self.cfg.base = true
		g_data.setting.base.showGuildName = not g_data.setting.base.showGuildName
		enable = g_data.setting.base.showGuildName
		settingKey = "showGuildName"

		local herosOwner = main_scene.ground.map

		for _3, hero2 in pairs(herosOwner.heros) do
			hero2.info:setName(hero2.info.name.texts, true)
		end
	end, true):pos(x, y8):add2(self.content).btn

	local value7 = y8 - number
	local y = h2

	self.btns.showExpEnable = callback("showExpEnable", "经验显示过滤", function(value16)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "showExpEnable")
	end, true):pos(x + number2, y):add2(self.content).btn

	local label2

	label2 = an.newInput(self.btns.showExpEnable:getw() + 200, y - 2, 80, 34, 5, {
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
			g_data.setting.base.showExpValue = tonumber(label2:getText()) or g_data.setting.base.showExpValue

			label2:setText("" .. g_data.setting.base.showExpValue)
		end
	}):add2(self.content):anchor(0, 0.5)

	local y9 = y - number

	self.btns.soundEnable = callback("soundEnable", "音效", function(value17)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnSoundEnable")
	end, true):pos(x + number2, y9):add2(self.content).btn

	local y10 = y9 - number

	self.btns.touchRun = callback("touchRun", "触屏跑步", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnTouchRun")
	end, true):pos(x + number2, y10):add2(self.content).btn

	local y11 = y10 - number

	self.btns.hideCorpse = callback("hideCorpse", "隐藏尸体", function(value18)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHideCorpse")
	end, true):pos(x + number2, y11):add2(self.content).btn

	local y12 = y11 - number

	self.btns.showOutHP = callback("showOutHP", "数字飘血", function(value19)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnShowOutHP")
	end, true):pos(x + number2, y12):add2(self.content).btn

	local y13 = y12 - number

	self.btns.quickexit = callback("quickexit", "快速小退", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnquickexit")
	end, true):pos(x + number2, y13):add2(self.content).btn

	local y14 = y13 - number

	self.btns.autoUnpack = callback("autoUnpack", "自动解包", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnautoUnpack")
	end, true):pos(x + number2, y14):add2(self.content).btn

	local y15 = y14 - number

	self.btns.heroShowTitle = callback("heroShowTitle", "显示称号", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHeroTitle")
	end, true):pos(x + number2, y15):add2(self.content).btn

	local value8 = y15 - number
	local y16 = h2 - number

	self.btns.highFrame = callback("highFrame", "高性能", function()
		self.cfg.base = true
		g_data.setting.base.highFrame = not g_data.setting.base.highFrame

		if g_data.setting.base.highFrame then
			cc.Director:getInstance():setAnimationInterval(0.016666666666666666)
		else
			cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
		end
	end, true):pos(x + number2 * 2, y16):add2(self.content).btn

	local value3 = g_data.setting.base.highFrame
	local value2 = self.btns.highFrame

	value2:setIsSelect(value3)

	if value3 then
		value2:select()
	else
		value2:unselect()
	end

	local y17 = y16 - number

	self.btns.autoUseRepair = callback("autoUseRepair", "自动修复", function(value20)
		self.cfg.base = true
		g_data.setting.base.autoUseRepair = not g_data.setting.base.autoUseRepair
	end, true):pos(x + number2 * 2, y17):add2(self.content).btn

	local y18 = y17 - number

	self.btns.singleRocker = callback("singleRocker", "单摇杆", function(value21)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnSingleRocker")
	end, true):pos(x + number2 * 2, y18):add2(self.content).btn

	local y19 = y18 - number

	self.btns.newEquipTip = callback("newEquipTip", "穿戴提示", function(value22)
		self.cfg.base = true
		g_data.setting.base.newEquipTip = not g_data.setting.base.newEquipTip
	end, true):pos(x + number2 * 2, y19):add2(self.content).btn

	local y20 = y19 - number

	self.btns.goodsTip = callback("goodsTip", "掉落提示", function(value23)
		self.cfg.base = true
		g_data.setting.base.goodsTip = not g_data.setting.base.goodsTip
	end, true):pos(x + number2 * 2, y20):add2(self.content).btn

	local y21 = y20 - number

	if not def.closeSampleRole then
		self.btns.sampleHero = callback("sampleHero", "人物简装", function(value24)
			self.cfg.base = true
			g_data.setting.base.sampleHero = not g_data.setting.base.sampleHero

			local herosOwner2 = main_scene.ground.map

			for _4, hero3 in pairs(herosOwner2.heros) do
				hero3:refreshFeature()
			end
		end, true):pos(x + number2 * 2, y21):add2(self.content).btn

		local y26 = y21 - number

		self.btns.sampleMon = callback("sampleMon", "怪物简装", function(value25)
			self.cfg.base = true
			g_data.setting.base.sampleMon = not g_data.setting.base.sampleMon

			local monsOwner = main_scene.ground.map

			for _5, mon2 in pairs(monsOwner.mons) do
				mon2:refreshFeature()
			end
		end, true):pos(x + number2 * 2, y26):add2(self.content).btn
	end

	local y22 = h2 - number

	self.btns.lockHeroTips = callback("lockHeroTips", "锁人提示", function(value26)
		self.cfg.base = true
		g_data.setting.base.lockHeroTips = not g_data.setting.base.lockHeroTips
	end, true):pos(x + number2 * 3, y22):add2(self.content).btn

	local y23 = y22 - number

	self.btns.showOtherbj = callback("showOtherbj", "他人暴击", function(value27)
		self.cfg.base = true
		g_data.setting.base.showOtherbj = not g_data.setting.base.showOtherbj
	end, true):pos(x + number2 * 3, y23):add2(self.content).btn

	local y24 = y23 - number

	self.btns.aotoChangeLock = callback("aotoChangeLock", "自动锁定", function(value28)
		self.cfg.base = true
		g_data.setting.base.aotoChangeLock = not g_data.setting.base.aotoChangeLock

		if g_data.setting.base.aotoChangeLock then
			main_scene.ui:fadeLabel("可自动切换攻击对象")
		else
			main_scene.ui:fadeLabel("需手动切换攻击对象")
		end
	end, true):pos(x + number2 * 3, y24):add2(self.content).btn

	local y25 = y24 - number

	self.btns.lockPlayerFirst = callback("lockPlayerFirst", "杀人优先", function(value29)
		self.cfg.base = true
		g_data.setting.base.lockPlayerFirst = not g_data.setting.base.lockPlayerFirst
	end, true):pos(x + number2 * 3, y25):add2(self.content).btn

	local y27 = y25 - number

	if def.BIGAttackBtn then
		self.btns.slideLock = callback("slideLock", "滑动锁定", function(value30)
			self.cfg.base = true
			g_data.setting.base.slideLock = not g_data.setting.base.slideLock

			local value5 = g_data.setting.base.slideLock and 1 or 2

			main_scene.ui.console:call("attackBtns", "setLockType", value5)
		end, true):pos(x + number2 * 3, y27):add2(self.content).btn
	end

	self.serverTime = an.newLabel("", 18, 1):anchor(0, 0):pos(25, 25):add2(self)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local msgbox = an.newMsgbox("", function(value6)
			if value6 == 1 then
				self.cfg.autoRat = true
				g_data.setting.autoRat.atkMagic.enable = true
				g_data.setting.autoRat.atkMagic.magicId = 1

				if g_data.setting.autoRat.defaultAtkMagic then
					g_data.setting.autoRat.defaultAtkMagic.magicId = 1
					g_data.setting.autoRat.defaultAtkMagic.enable = false
				end

				main_scene.ui.console:call("attackBtns", "chgAttackType")
				g_data.setting.reset()

				for key, _6 in pairs(g_data.setting) do
					cache.removeSetting(key)
				end

				LocalAutoCusSkills = true

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

function setting:loadItem()
	local callback
	local btn
	local label3

	local function callback2()
		self.modifiedItem = true
		self.cfg.item = true

		callback(label3:getText(), btn.category, true)
	end

	local filtOwner = g_data.setting.item

	filtOwner.filt = filtOwner.filt or {}

	local function callback3(...)
		local btnOwner = self:add(filtOwner, ...)
		local labelOwner = btnOwner.btn

		labelOwner.label:pos(-labelOwner.label:getw() / 2 + 10, labelOwner.label:getPositionY()):scale(0.9)

		return btnOwner
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_51.png"), 0, 50, cc.size(580, 400)):addTo(self.content):anchor(0, 0)
	local value_2 = res.get2("pic/panels/setting/line.png"):anchor(0, 1):pos(0, background.geth(background) - 55):add2(background)
	local number2 = 29
	local number3 = 70
	local label2 = an.newLabel("物品名称", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(self.cleft + 10, self.ctop - 40)
	local pickOnRatting2 = callback3("pickOnRatting", "挂机\n捡取", callback2, false):add2(self.content):pos((self.content:getw() - 45) / 5 + number3, self.ctop - number2)
	local pickUp2 = callback3("pickUp", "捡取\n物品", callback2, false):add2(self.content):pos((self.content:getw() - 45) * 2 / 5 + number3, self.ctop - number2)
	local hintName2 = callback3("showName", "物品\n显名", callback2, false):add2(self.content):pos((self.content:getw() - 45) * 3 / 5 + number3, self.ctop - number2)
	local isGood2 = callback3("hindGood", "物品\n标红", callback2, false):add2(self.content):pos((self.content:getw() - 45) * 4 / 5 + number3, self.ctop - number2)
	local scroll2 = an.newScroll(0, self.ctop - 58, self.cright, background.geth(background) - 65, {
		labelM = {
			18,
			1
		}
	}):anchor(0, 1):add2(self.content)
	local number = 42
	local items3 = {
		{
			"极品属性道具",
			0,
			hightLight = true
		}
	}

	for itemId, item4 in pairs(def.items) do
		if type(item4) == "table" and item4.get then
			local value3 = item4.get(item4, "name")

			if value3 == "金币1" then
				value3 = "金币"
			end

			if filtOwner.filt[value3] then
				items3[#items3 + 1] = {
					value3,
					itemId
				}
			end
		end
	end

	local items2 = items3

	scroll2.setScrollSize(scroll2, self.cright, number * #items2)

	local items8 = {
		isGood = isGood2,
		pickOnRatting = pickOnRatting2,
		hintName = hintName2,
		pickUp = pickUp2
	}

	local function updateVisible(self4, value19, value12)
		local toggle

		toggle = self:createToggle(function(value13)
			if toggle.name then
				self.cfg.item = true
				filtOwner.filt[toggle.name] = rawget(filtOwner.filt, toggle.name) or filtOwner.filt[toggle.name] or {}
				filtOwner.filt[toggle.name][self4] = value13
				self.modifiedItem = true
			else
				print("item filter setting changed, but item is no name!")
			end
		end, selected, nil, {
			selectImg = "pic/common/" .. value12 .. ".png"
		}):anchor(0, 0)

		return toggle
	end

	local function updateVisible2(ident2, size2, height2, value11)
		local labelOwner2 = items2[ident2]
		local name2 = labelOwner2[1]

		size2.ident = ident2
		size2.height = height2

		labelOwner2.label:pos(10, height2 + 3):setVisible(not value11)

		for index4, item8 in ipairs({
			"isGood",
			"pickOnRatting",
			"hintName",
			"pickUp"
		}) do
			size2[item8].name = name2

			size2[item8]:pos(size2[item8]:getPositionX(), height2)
			size2[item8]:setVisible(not value11)

			local value20

			if not filtOwner.filt[name2] and true or filtOwner.filt[name2][item8] then
				size2[item8].btn:select()
			else
				size2[item8].btn:unselect()
			end

			if items8[item8].btn:isSelect() then
				size2[item8].btn:select_temp()
				size2[item8].btn:gray()
			else
				size2[item8].btn:disGray()
			end
		end
	end

	local function updateVisible3(self2)
		if items2[self2] then
			local value2 = items2[self2]

			if value2[1] and value2[1] ~= nil then
				local size3 = {
					height = scroll2:getScrollSize().height - self2 * number
				}

				if not value2.added then
					local color2 = def.colors.labelYellow

					if value2.hightLight then
						color2 = def.colors.clRed
					end

					value2.label = an.newLabel(value2[1], 20, 1, {
						bufferChannel = 0,
						color = color2
					}):add2(scroll2)
				end

				size3.pickOnRatting = updateVisible("pickOnRatting", value2[1], "toggle03"):add2(scroll2):pos((scroll2:getw() - 45) / 5 + 70, size3.height)
				size3.pickUp = updateVisible("pickUp", value2[1], "toggle04"):add2(scroll2):pos((scroll2:getw() - 45) * 2 / 5 + 70, size3.height)
				size3.hintName = updateVisible("hintName", value2[1], "toggle04"):add2(scroll2):pos((scroll2:getw() - 45) * 3 / 5 + 70, size3.height)
				size3.isGood = updateVisible("isGood", value2[1], "toggle02"):add2(scroll2):pos((scroll2:getw() - 45) * 4 / 5 + 70, size3.height)

				updateVisible2(self2, size3, size3.height)

				value2.added = true
				value2.showing = true

				return size3
			end
		end
	end

	local items5 = {}

	local function updateVisible4(ident, value21, value14, value15)
		local height3 = scroll2:getScrollSize().height - ident * number

		if items2[ident].showing then
			return
		end

		for _, item3 in ipairs(items5) do
			if value14 < item3.height or value15 > item3.height then
				local value4 = items2[item3.ident]

				if value4 and value4.showing then
					value4.showing = false

					value4.label:pos(0, 0):setVisible(false)
				end

				item3.ident = ident
				item3.height = height3

				if not items2[ident].added then
					items2[ident].label = an.newLabel(items2[ident][1], 20, 1, {
						bufferChannel = 0,
						color = def.colors.labelYellow
					}):add2(scroll2):pos(25, height3 + 3)
					items2[ident].added = true
				end

				updateVisible2(ident, item3, height3)

				items2[ident].showing = true

				return
			end
		end

		local item7 = updateVisible3(ident)

		table.insert(items5, item7)
	end

	local value7
	local value8

	function callback(self3, value5, value16)
		if value7 == self3 and value8 == value5 and not value16 then
			return
		end

		value7 = self3
		value8 = value5

		local items11 = {}
		local items4 = {}

		for _2, item2 in ipairs(items3) do
			local categoryOwner = filtOwner.filt[item2[1]]

			if (not value5 or categoryOwner and categoryOwner.category == value5) and (not self3 or item2[1] and string.find(item2[1], self3)) then
				items4[#items4 + 1] = item2
			end

			item2.showing = false

			if item2.label then
				item2.label:removeFromParent()
			end

			item2.label = nil
			item2.added = false
		end

		for _3, item5 in ipairs(items5) do
			item5.isGood:removeFromParent()
			item5.pickOnRatting:removeFromParent()
			item5.hintName:removeFromParent()
			item5.pickUp:removeFromParent()
		end

		items5 = {}
		items2 = items4

		scroll2:setScrollOffset(0, 0)
		scroll2:setScrollSize(self.cright, number * #items2)
	end

	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(220, 45):add2(self.content)

	label3 = an.newInput(10, 3, 150, 38, 12, {
		label = {
			"",
			20,
			1
		},
		return_call = function()
			self.cfg.item = true

			callback2()
		end,
		tip = {
			" <输入关键字查找>",
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}
	}):add2(background2):anchor(0, 0):pos(10, 1)

	an.newBtn(res.gettex2("pic/common/button_search.png"), function()
		sound.playSound("103")
		callback(label3:getText(), btn.category)
	end):add2(self.content):pos(background2.getw(background2), background2.geth(background2) / 2):anchor(1, 0.5)

	local value9 = clone(def.items.category)

	table.insert(value9, 1, "全  部")

	local items9 = {
		"全  部",
		"书籍类",
		"其它类",
		"武器类",
		"药品类",
		"勋章",
		"首饰类",
		"防具类"
	}
	local items6 = {
		"qbl",
		"sjl",
		"qtl",
		"wql",
		"ypl",
		"xzl",
		"ssl",
		"fjl"
	}

	local function cleanup(self5)
		for index2, item6 in ipairs(items9) do
			if item6 == self5 then
				return items6[index2]
			end
		end

		return items6[1]
	end

	btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local items7 = {}
		local operationMenu

		for _4, category in pairs(value9) do
			local items10 = {
				w = 110,
				h = 40,
				cate = category,
				cellCls = function()
					local text = "pic/common/btn20.png"
					local text2 = "pic/common/btn21.png"

					if btn.labelInfo == category .. "  " then
						text = "pic/common/btn10.png"
						text2 = "pic/common/btn11.png"
					end

					return an.newBtn(res.gettex2(text), function()
						sound.playSound("103")

						if btn.labelInfo == category .. "  " then
							return
						end

						self.cfg.item = true

						operationMenu:removeSelf()
						btn.sprite:setTex(res.gettex2("pic/panels/setting/" .. cleanup(category) .. ".png"))

						btn.category = category

						if category == "全  部" then
							btn.category = nil
						end

						callback(label3:getText(), btn.category)
					end, {
						pressImage = res.gettex2(text2),
						labelInfo = category,
						sprite = res.gettex2("pic/panels/setting/" .. cleanup(category) .. ".png")
					})
				end
			}

			table.insert(items7, items10)
		end

		operationMenu = common.createOperationMenu(items7, 10, function(value22, value23)
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

		value7 = nil

		callback(label3:getText(), btn.category)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/hfmr.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)

	local value10 = cc.EventListenerCustom:create("director_after_update", function()
		local scrollOffset2, scrollOffset = scroll2:getScrollOffset()
		local scrollSize = scroll2:getScrollSize().height
		local value17 = math.ceil((scrollOffset + scroll2:geth()) / number)
		local value18 = math.floor(scrollOffset / number)
		local text3 = ""

		for index3 = value18, value17 do
			local value6 = index3 + 1

			text3 = string.format("%s,%d", text3, value6)

			if items2[value6] then
				updateVisible4(value6, items2[value6], scrollSize - scrollOffset, scrollSize - scrollOffset - scroll2:geth() - 30)
			end
		end
	end)

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(value10, 1)

	function scroll2.onCleanup()
		cc.Director:getInstance():getEventDispatcher():removeEventListener(value10)
	end

	scroll2.setNodeEventEnabled(scroll2, true)
end

function setting:loadPro()
	local function callback(self2, value6, value7, value8, value12)
		local value2 = g_data.setting.protected[self2][value6]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		self:createToggle(function(enable2)
			self.cfg.protected = true
			value2.enable = enable2
		end, value2.enable, {
			value7,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, node.geth(node) / 2):add2(node)

		local label3

		label3 = an.newInput(120, node.geth(node) / 2 - 2, 80, 34, 10, {
			label = {
				"" .. value2.value,
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
				value2.value = tonumber(label3:getText()) or value2.value

				if value2.isPercent then
					value2.value = math.min(value2.value, 100)
				end

				label3:setText("" .. value2.value)
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel(value8, 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(205, node.geth(node) / 2):add2(node)

		return node
	end

	local function callback3(self3, value9, value13)
		local valueOwner = g_data.setting.protected[self3][value9]
		local node2 = display.newNode():anchor(0, 0.5):size(400, 30)

		an.newLabel("躲闪血量", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(0, node2.geth(node2) / 2):add2(node2)

		local label4

		label4 = an.newInput(84, node2.geth(node2) / 2 - 2, 80, 34, 10, {
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
				valueOwner.value = tonumber(label4:getText()) or valueOwner.value
				valueOwner.value = math.max(valueOwner.value, 40)
				valueOwner.value = math.min(valueOwner.value, g_data.hero.ability:get("maxHP"))

				label4:setText("" .. valueOwner.value)
				net.send({
					CM_COMMON_INFORMATION,
					param = 2,
					recog = valueOwner.value
				})
			end
		}):add2(node2):anchor(0, 0.5)

		an.newLabel("HP", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(160, node2.geth(node2) / 2):add2(node2)

		return node2
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_50.png"), 0, 0, cc.size(580, 460)):addTo(self.content):anchor(0, 0)
	local items2 = {}
	local value11
	local items3 = {
		"role",
		"hero"
	}
	local number = 10

	local function callback2(self4)
		self.cfg.protected = true

		background:removeAllChildren()

		local value3 = g_data.setting.protected.role
		local value5 = g_data.setting.protected.hero

		if self4 == 1 then
			an.newLabel("保护设置", 20, 1, {
				color = def.colors.labelYellow
			}):add2(background):pos(15, background:geth() - 42 - number)

			local texts2 = def.role.mainsetting.protectSutffs or "随机传送卷,地牢逃脱卷,回城,行会回城卷,随机传送石,小退"
			local res2 = {
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
				texts = texts2,
				res = res2,
				curtext = value3.hp.uses,
				size = cc.size(128, 24),
				endFunc = function(uses)
					value3.hp.uses = uses
				end
			}):anchor(0, 0.5):pos(310, background:geth() - 70 - number):add2(background, 2)
			self:createSelectTab({
				scale = 1,
				texts = texts2,
				res = res2,
				curtext = value3.mp.uses,
				size = cc.size(128, 24),
				endFunc = function(uses2)
					value3.mp.uses = uses2
				end
			}):anchor(0, 0.5):pos(310, background:geth() - 130 - number):add2(background, 1)

			if value3.hp.isPercent then
				callback("role", "hp", "HP低于", "%时使用", def.colors.labelGray):pos(15, background:geth() - 70 - number):add2(background)
			else
				callback("role", "hp", "HP低于", "时使用", def.colors.labelGray):pos(15, background:geth() - 70 - number):add2(background)
			end

			if value3.mp.isPercent then
				callback("role", "mp", "MP低于", "%时使用", def.colors.labelGray):pos(15, background:geth() - 130 - number):add2(background)
			else
				callback("role", "mp", "MP低于", "时使用", def.colors.labelGray):pos(15, background:geth() - 130 - number):add2(background)
			end

			return
		end

		an.newLabel("英雄保护设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(background):pos(15, background:geth() - 42 - number)

		if value5.hp.isPercent then
			callback("hero", "hp", "HP低于", "%收英雄", def.colors.labelGray):pos(15, background:geth() - 70 - number):add2(background)
		else
			callback("hero", "hp", "HP低于", "收英雄", def.colors.labelGray):pos(15, background:geth() - 70 - number):add2(background)
		end

		if value5.mp.isPercent then
			callback("hero", "mp", "MP低于", "%收英雄", def.colors.labelGray):pos(15, background:geth() - 130 - number):add2(background)
		else
			callback("hero", "mp", "MP低于", "收英雄", def.colors.labelGray):pos(15, background:geth() - 130 - number):add2(background)
		end

		callback3("hero", "miss", def.colors.labelGray):pos(350, background:geth() - 70 - number):add2(background)
	end

	if def.gameVersionType == "185" then
		local node4

		for index2, item2 in ipairs({
			"主号",
			"英雄"
		}) do
			local value4 = index2
			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(background.getw(background) / 2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw() / 2 - 5) * (index2 - 1) + 5, self.ctop - 5)
			local label2 = an.newLabel(item2, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local value_2 = res.get2("pic/common/button_click.png"):add2(background2):pos(background2.getw(background2) / 2 - label2.getw(label2) / 2, background2.geth(background2) / 2)

			label2.add2(label2, value_2):pos(value_2.getw(value_2), 0)

			local node3 = res.get2("pic/common/button_click02.png"):add2(value_2):pos(value_2.getw(value_2) / 2, value_2.geth(value_2) / 2)

			node3.setVisible(node3, value4 == 1)
			background2.setTouchEnabled(background2, true)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value10 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value10) <= 10 and not node3:isVisible() then
						node4:setVisible(false)
						callback2(value4)
						node3:setVisible(true)

						node4 = node3
					end
				end
			end)

			node4 = node4 or node3
		end

		number = 60
	end

	callback2(1)
end

function setting:loadDrugs()
	local function callback(self4, value14, value15, value2, value9, value10)
		local value4 = self4[value14]

		value2 = value2 or 10
		value9 = value9 or "请输入数字"
		value10 = value10 or "请输入数字"

		local node = display.newNode():size(460, 30)

		self.createToggle(self, function(enable2)
			self.cfg.drugs = true
			value4.enable = enable2
		end, value4.enable, {
			value15,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(10, node.geth(node) / 2):add2(node)

		if value2 > value4.value then
			value4.value = value2
		end

		local background3 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(200, node.geth(node) / 2):add2(node):size(85, 41)
		local label4 = an.newLabel("" .. (value4.value or value2), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(background3):pos(10, background3.geth(background3) * 0.5)

		background3.enableClick(background3, function()
			local msgbox

			msgbox = an.newMsgbox(value9, function(value16)
				if value16 == 1 then
					if msgbox.input:getString() == "" then
						return
					end

					self.cfg.drugs = true

					local value3 = tonumber(msgbox.input:getText())

					if value3 then
						value3 = value3 > value2 and value3 or value2
					else
						value3 = value2 < value4.value and value4.value or value2
					end

					value4.value = value3

					label4:setString("" .. value4.value)
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
					label4:getString(),
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

		local background4 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(360, node.geth(node) / 2):add2(node):size(85, 41)
		local label5 = an.newLabel("" .. (value4.space or 0), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(background4):pos(10, background4.geth(background4) * 0.5)

		background4.enableClick(background4, function()
			local msgbox2

			msgbox2 = an.newMsgbox(value10, function(value17)
				if value17 == 1 then
					if msgbox2.input:getString() == "" then
						return
					end

					self.cfg.drugs = true
					value4.space = tonumber(msgbox2.input:getText()) or value4.space

					label5:setString("" .. (value4.space or 0))
				end
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox2.input = an.newInput(0, 0, msgbox2.bg:getw() - 60, 40, 7, {
				label = {
					label5:getString(),
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
			}):add2(msgbox2.bg):pos(msgbox2.bg:getw() * 0.5 + 10, msgbox2.bg:geth() * 0.5 + 20)
		end)

		return node
	end

	local function callback2(self5, value18, value19)
		local number2 = self5[value18]
		local node2 = display.newNode()
		local label7 = an.newLabel(value19, 20, 1, {
			color = def.colors.labelGray
		}):add2(node2):pos(0, 0):anchor(0, 0.5)
		local label6 = an.newLabel(math.ceil(tonumber(number2.value) * 100) .. "%", 20, 1, {
			color = def.colors.labelGray
		}):add2(node2):pos(490, 0):anchor(0, 0.5)

		local function valueChange2(self6)
			local number = math.ceil(tonumber(self6) * 100)

			self.cfg.drugs = true
			number2.value = number / 100

			label6:setString(tostring(number) .. "%")
		end

		an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
			scale9 = cc.size(380, 15),
			value = number2.value,
			valueChange = valueChange2,
			valueChangeEnd = valueChange2
		}):add2(node2):pos(100, 0):anchor(0, 0.5).block:setScale(0.7)

		return node2
	end

	local background2 = display.newScale9Sprite(res.getframe2("pic/common/black_50.png"), 0, 35, cc.size(580, 420)):addTo(self.content):anchor(0, 0)
	local number3 = 65
	local size2 = background2.getContentSize(background2)
	local value12 = def.gameVersionType == "185"

	local function callback3(self7)
		local h2 = background2:geth() - 35
		local value6 = size2.height - 75

		if value12 then
			h2 = h2 - 50
			value6 = value6 - 50
		end

		background2:removeAllChildren()

		local value11 = g_data.setting.drugs.hero
		local value5 = g_data.setting.drugs.heroSetting

		if self7 == 1 then
			value11 = g_data.setting.drugs.role
			value5 = g_data.setting.drugs.roleSetting
		end

		local scroll2 = an.newScroll(0, 20, size2.width, value6):add2(background2)

		local function callback4(self3)
			local value7 = value11.percentDrug

			callback2(value7, "normalHP", "普通红药"):add2(scroll2):pos(25, self3)

			self3 = self3 - number3

			callback2(value7, "normalMP", "普通蓝药"):add2(scroll2):pos(25, self3)

			self3 = self3 - number3

			callback2(value7, "quickHP", "瞬间红药"):add2(scroll2):pos(25, self3)

			self3 = self3 - number3

			callback2(value7, "quickMP", "瞬间蓝药"):add2(scroll2):pos(25, self3)

			self3 = self3 - number3

			return self3
		end

		local function cleanup2(self2)
			an.newLabel("剩余HP/MP", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(scroll2):pos(236, self2)
			an.newLabel("间隔(毫秒)", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(scroll2):pos(394, self2)
			display.newScale9Sprite(res.getframe2("pic/common/b4.png"), 10, self2 - 12, cc.size(560, 1)):addTo(scroll2):anchor(0, 0.5)

			self2 = self2 - 40

			local value8 = value11.numberDrug

			callback(value8, "normalHP", "普通红药", 0):pos(25, self2):add2(scroll2):anchor(0, 0.5)

			self2 = self2 - number3

			callback(value8, "normalMP", "普通蓝药", 0):pos(25, self2):add2(scroll2):anchor(0, 0.5)

			self2 = self2 - number3

			callback(value8, "quickHP", "瞬间红药", 0):pos(25, self2):add2(scroll2):anchor(0, 0.5)

			self2 = self2 - number3

			callback(value8, "quickMP", "瞬间蓝药", 0):pos(25, self2):add2(scroll2):anchor(0, 0.5)

			self2 = self2 - number3

			return self2
		end

		local value25

		local function cleanup(self8)
			local value21 = value6 - number3 / 2

			return self8(value21) + 30
		end

		local function updateVisible2(self9)
			local label3 = an.newLabelM(scroll2:getw() - 20, 20, 1):add2(scroll2):pos(15, self9 - 120)

			local function updateVisible(self10, value22)
				label3:addLabel(self10, def.colors.labelYellow)
				label3:addLabel(value22, def.colors.clRed)
			end

			label3.addLabel(label3, "注:\n", def.colors.labelYellow)
			updateVisible("普红:", string.format("%s\n", def.drugsHPShow or "强效、中量、小量金创药"))
			updateVisible("普蓝:", string.format("%s\n", def.drugsMPShow or "强效、中量、小量魔法药"))
			updateVisible("瞬回:", def.drugsInstantShow or "太阳水、万年雪霜、疗伤药")
		end

		local value20 = h2
		local btnOwner
		local btnOwner2

		local function updateVisible3(withPercent)
			self.cfg.drugs = true
			h2 = value20 - number3

			scroll2:removeSelf()

			scroll2 = an.newScroll(0, 20, size2.width, value6):add2(background2)
			value5.withPercent = withPercent
			value5.withNumber = not withPercent

			if withPercent then
				btnOwner.btn:select()
				btnOwner2.btn:unselect()

				h2 = cleanup(callback4)
			else
				btnOwner.btn:unselect()
				btnOwner2.btn:select()

				h2 = cleanup(cleanup2)
			end

			updateVisible2(h2)
		end

		btnOwner = self:add(value5, "withPercent", "按百分比自动喝药", function(value23)
			updateVisible3(not value23)
		end, true):add2(background2):pos(20, h2)
		btnOwner2 = self:add(value5, "withNumber", "按血量自动喝药", updateVisible3, true):add2(background2):pos(250, h2)
		h2 = h2 - number3 + 20

		if value5.withPercent then
			h2 = cleanup(callback4)
		else
			h2 = cleanup(cleanup2)
		end

		updateVisible2(h2)
	end

	callback3(1)

	if value12 then
		local node4

		for index2, item2 in ipairs({
			"主号",
			"英雄"
		}) do
			local value13 = index2
			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(background2.getw(background2) / 2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw() / 2 - 5) * (index2 - 1) + 5, self.ctop - 5)
			local label2 = an.newLabel(item2, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local value_2 = res.get2("pic/common/button_click.png"):add2(background):pos(background.getw(background) / 2 - label2.getw(label2) / 2, background.geth(background) / 2)

			label2.add2(label2, value_2):pos(value_2.getw(value_2), 0)

			local node3 = res.get2("pic/common/button_click02.png"):add2(value_2):pos(value_2.getw(value_2) / 2, value_2.geth(value_2) / 2)

			node3.setVisible(node3, value13 == 1)
			background.setTouchEnabled(background, true)
			background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value24 = offsetBeginY.y - background.offsetBeginY

					if math.abs(value24) <= 10 and not node3:isVisible() then
						node4:setVisible(false)
						callback3(value13)
						node3:setVisible(true)

						node4 = node3
					end
				end
			end)

			node4 = node4 or node3
		end
	end
end

function setting:loadJob()
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_50.png"), 0, 50, cc.size(580, 395)):addTo(self.content):anchor(0, 0)
	local playerName = common.getPlayerName()
	local scroll2 = an.newScroll(0, 5, background.getw(background), background.geth(background), {
		labelM = {
			18,
			1
		}
	}):add2(background)
	local x = 25

	local function callback6(self4)
		for itemId3, item3 in pairs(self4) do
			local magicConfigByUid3 = def.magic.getMagicConfigByUid(item3, main_scene.ground.player)

			if not magicConfigByUid3 or not magicConfigByUid3.name and not magic.heroName then
				self4[itemId3] = nil
			end
		end

		return self4
	end

	local function callback4(self3)
		cc2.ms({
			function()
				if def.role.mainsetting.skill_Names and def.role.mainsetting.skill_Names[self3] then
					self3 = def.role.mainsetting.skill_Names[self3]
				end
			end
		})

		return self3
	end

	local function callback2(self6, callback3)
		local items3 = {}
		local items4 = {}
		local value9
		local value10

		for itemId, item2 in pairs(self6) do
			if g_data.player:getMagic(item2) then
				local magicConfigByUid2 = def.magic.getMagicConfigByUid(item2, main_scene.ground.player)
				local value6 = item2

				if magicConfigByUid2.name and string.find(magicConfigByUid2.name, "|") ~= nil then
					value6 = value6 .. "-" .. g_data.player.job
				end

				if magicConfigByUid2.picId then
					value6 = magicConfigByUid2.picId
				end

				local value3 = itemId

				if magicConfigByUid2.extName then
					value3 = value3 .. magicConfigByUid2.extName
				end

				table.insert(items4, "pic/console/skill-icons/" .. value6 .. ".png")
				table.insert(items3, itemId)

				if type(callback3) == "number" then
					if callback3 == item2 then
						value9 = value3
						value10 = item2
					end
				elseif type(callback3) == "function" then
					callback3(value3, item2)
				elseif not callback3 then
					value9 = value3
					value10 = item2
					callback3 = item2
				end
			end
		end

		return items3, items4, value9 or "", value10
	end

	local count = 0

	local function callback(self5, value18, callback5, value19, value12, value31)
		local value11 = g_data.setting[value12 or "job"]
		local node = display.newNode():anchor(0, 0.5)
		local enableOwner = value11[self5]

		if type(enableOwner) == "table" then
			enableOwner = enableOwner.enable
		end

		node.btn = cleanup(function(btn)
			if value12 and value12 == "autoRat" then
				self.cfg.autoRat = true
			else
				self.cfg.job = true
			end

			if not value19 then
				value11[self5] = btn
			end

			if callback5 then
				callback5(value11[self5])

				return
			end
		end, enableOwner, {
			value18,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, 14):add2(node)

		node.size(node, node.btn:getw(), node.btn:geth())

		return node
	end

	local x3 = -10
	local label7 = an.newLabel("自动技能", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll2):pos(x3 + 25, self.content:geth() - 50)
	local h2 = self.content:geth() - 72

	local function callback7(self2, value13)
		if not g_data.hero or not g_data.hero.roleid then
			return nil
		end

		value13 = value13 or 240

		if g_data.hero:getMagic(31) then
			if self2 == x then
				self2 = self2 + value13
			else
				self2 = x
				h2 = h2 - 45
			end

			self.btns.btnautoDunHero = callback("autoDunHero", "英雄持续开盾", function(value32)
				self.cfg.job = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnautoDunHero")

				return nil
			end, true):add2(scroll2):pos(self2, h2).btn
			hasSkill = true
		end

		return h2
	end

	local x2 = 0

	if items.autoSkills then
		for key, autoSkill in pairs(items.autoSkills) do
			if x2 == 0 then
				x2 = x
			elseif x2 == x then
				x2 = x2 + 240
			else
				x2 = x
				h2 = h2 - 45
			end

			local text2 = "job"

			if autoSkill.autoRat then
				text2 = "autoRat"
				self.cfg.autoRat = true
			else
				self.cfg.job = true
			end

			if autoSkill.magicId == 6 then
				self.btns.btnAutoPoison = callback(key, autoSkill.name, function(value33)
					if g_data.player:getMagic(autoSkill.magicId) then
						self.cfg.autoRat = true

						main_scene.ui.console.btnCallbacks:handle("setting", autoSkill.btn)
					end
				end, true, "autoRat"):add2(scroll2):pos(x2, h2).btn:setGray(not g_data.player:getMagic(autoSkill.magicId))
			else
				self.btns[autoSkill.btn] = callback(key, autoSkill.name, function(value34)
					if g_data.player:getMagic(autoSkill.magicId) then
						if autoSkill.autoRat then
							self.cfg.autoRat = true
						else
							self.cfg.job = true
						end

						main_scene.ui.console.btnCallbacks:handle("setting", autoSkill.btn, text2)
					end
				end, true, text2):add2(scroll2):pos(x2, h2).btn:setGray(not g_data.player:getMagic(autoSkill.magicId))
			end
		end
	end

	if def.csSkills and def.ccy.isOpenCSSkill() then
		for _, csSkill in pairs(def.csSkills) do
			if csSkill.autoSkill and (csSkill.job == g_data.player.job or csSkill.job == 3) then
				if x2 == 0 then
					x2 = x
				elseif x2 == x then
					x2 = x2 + 240
				else
					x2 = x
					h2 = h2 - 45
				end

				self.btns[csSkill.key] = callback(csSkill.key, callback4(csSkill.name), function(value35)
					if g_data.player:getMagic(csSkill.magicId) then
						self.cfg.job = true

						main_scene.ui.console.btnCallbacks:handle("setting", csSkill.key, "job")
					end
				end, true):add2(scroll2):pos(x2, h2).btn:setGray(not g_data.player:getMagic(csSkill.magicId))
			end
		end
	end

	callback7(x2)

	h2 = h2 - 45

	an.newLabel("挂机设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll2):pos(x3 + 25, h2 - 7):anchor(0, 0)

	h2 = h2 - 35

	if g_data.player:getMagic(43) then
		self.btns.btnAutoRoar = callback("autoRoar", "身边有", function(value36)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")
		end, true, "autoRat"):add2(scroll2):pos(x, h2).btn:setGray(not g_data.player:getMagic(43))

		local label8

		label8 = an.newInput(self.btns.btnAutoRoar:getw() + 30, h2 - 3, 70, 34, 5, {
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
				g_data.setting.autoRat.autoRoar.cnt = tonumber(label8:getText()) or g_data.setting.autoRat.autoRoar.cnt

				label8:setText("" .. g_data.setting.autoRat.autoRoar.cnt)
			end
		}):add2(scroll2):anchor(0, 0.5)

		an.newLabel(string.format("个怪时使用%s", callback4("狮子吼")), 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll2):pos(label8.getw(label8) + label8.getPositionX(label8), h2 - 3):enableClick(function()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")
		end)

		h2 = h2 - 45
	end

	if items.autoRatSkillNames then
		local value27
		local value28
		local magicIdOwner = g_data.setting.autoRat.atkMagic

		if magicIdOwner.magicId == 1 and g_data.player.job == 2 then
			magicIdOwner.magicId = 13
		end

		local texts3, res3, curtext3, magicId3 = callback2(items.autoRatSkillNames, magicIdOwner.magicId)

		magicIdOwner.magicId = magicId3
		curtext3 = curtext3 or ""

		if #texts3 ~= 0 then
			self.btns.btnAtkMagic = callback("atkMagic", "挂机技能", function(value37)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

			local selectTab = self.createSelectTab(self, {
				parent = self.content,
				texts = texts3,
				res = res3,
				curtext = curtext3,
				size = cc.size(128, 24),
				endFunc = function(value20)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = items.autoRatSkillNames[value20]
				end
			}, self.content):anchor(0, 0.5):pos(x + self.btns.btnAtkMagic:getw(), h2):add2(scroll2, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll2):pos(selectTab.getw(selectTab) + selectTab.getPositionX(selectTab), h2):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end)

			h2 = h2 - 50
		end
	end

	if items.areaSkillNames then
		local magicIdOwner2 = g_data.setting.autoRat.areaMagic
		local texts4, res4, curtext4, magicId4 = callback2(items.areaSkillNames, magicIdOwner2.magicId)

		magicIdOwner2.magicId = magicId4

		if #texts4 > 0 then
			local value7 = callback("areaMagic", "目标身边有", function(value38)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")
			end, true, "autoRat"):add2(scroll2):pos(x, h2)

			self.btns.btnareaMagic = value7.btn

			local label9

			label9 = an.newInput(value7.getw(value7) + 30, h2 - 7, 35, 34, 5, {
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
					g_data.setting.autoRat.areaMagic.cnt = tonumber(label9:getText()) or g_data.setting.autoRat.areaMagic.cnt

					label9:setText("" .. g_data.setting.autoRat.areaMagic.cnt)
				end
			}):add2(scroll2):anchor(0, 0.5)

			local label2 = an.newLabel("个怪时使用", 20, 1, {
				color = def.colors.labelGray
			})

			label2.anchor(label2, 0, 0.5):add2(scroll2):pos(label9.getw(label9) + label9.getPositionX(label9), h2):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")
			end)
			self.createSelectTab(self, {
				parent = self.content,
				texts = texts4,
				res = res4,
				curtext = curtext4,
				size = cc.size(128, 24),
				endFunc = function(value21)
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.magicId = items.areaSkillNames[value21]
				end
			}, self.content):anchor(0, 0.5):pos(label2.getPositionX(label2) + label2.getw(label2), h2):add2(scroll2, 2)

			h2 = h2 - 50
		end
	end

	if items.petSkillNames then
		local magicIdOwner3 = g_data.setting.autoRat.autoPet
		local texts5, res5, value15, magicId5 = callback2(items.petSkillNames, magicIdOwner3.magicId)

		magicIdOwner3.magicId = magicId5

		if #texts5 > 0 then
			self.btns.btnAutoPet = callback("autoPet", "自动召唤宠物", function(value39)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPet")
			end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts5,
				res = res5,
				curtext = value15 or "",
				size = cc.size(128, 24),
				endFunc = function(value22)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoPet.magicId = items.petSkillNames[value22]
				end
			}, self.content):anchor(0, 0.5):pos(x + self.btns.btnAutoPet:getw(), h2):add2(scroll2, 2)

			h2 = h2 - 50
		end
	end

	if items.selfRecoverSkillNames then
		local magicIdOwner4 = g_data.setting.autoRat.autoCure
		local texts6, res6, curtext5, magicId6 = callback2(items.selfRecoverSkillNames, magicIdOwner4.magicId)

		magicIdOwner4.magicId = magicId6

		if #texts6 > 0 then
			self.btns.btnAutoCure = callback("autoCure", "人物血量低于", function(value40)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")
			end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

			local label10

			label10 = an.newInput(x + self.btns.btnAutoCure:getw(), h2 - 3, 40, 34, 5, {
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
					g_data.setting.autoRat.autoCure.percent = tonumber(label10:getText()) or g_data.setting.autoRat.autoCure.percent

					label10:setText("" .. g_data.setting.autoRat.autoCure.percent)
				end
			}):add2(scroll2):anchor(0, 0.5)

			local label3 = an.newLabel("%时使用", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll2):pos(label10.getw(label10) + label10.getPositionX(label10), h2):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")
			end)

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts6,
				res = res6,
				curtext = curtext5,
				size = cc.size(128, 24),
				endFunc = function(value23)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.magicId = items.selfRecoverSkillNames[value23]
				end
			}, self.content):anchor(0, 0.5):pos(label3.getw(label3) + label3.getPositionX(label3), h2):add2(scroll2, 2)

			h2 = h2 - 50
		end
	end

	if items.selfRecoverSkillNames and items.openPetCure then
		local magicIdOwner5 = g_data.setting.autoRat.autoCurePet
		local texts7, res7, curtext6, magicId7 = callback2(items.selfRecoverSkillNames, magicIdOwner5.magicId)

		magicIdOwner5.magicId = magicId7

		if #texts7 > 0 then
			self.btns.btnAutoCurePet = callback("autoCurePet", "宠物血量低于", function(value41)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")
			end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

			local label11

			label11 = an.newInput(x + self.btns.btnAutoCurePet:getw(), h2 - 3, 40, 34, 5, {
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
					g_data.setting.autoRat.autoCurePet.percent = tonumber(label11:getText()) or g_data.setting.autoRat.autoCurePet.percent

					label11:setText("" .. g_data.setting.autoRat.autoCurePet.percent)
				end
			}):add2(scroll2):anchor(0, 0.5)

			local label4 = an.newLabel("%时使用", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll2):pos(label11.getw(label11) + label11.getPositionX(label11), h2):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")
			end)

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts7,
				res = res7,
				curtext = curtext6,
				size = cc.size(128, 24),
				endFunc = function(value24)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCurePet.magicId = items.selfRecoverSkillNames[value24]
				end
			}, self.content):anchor(0, 0.5):pos(label4.getw(label4) + label4.getPositionX(label4), h2):add2(scroll2, 2)

			h2 = h2 - 50
		end
	end

	self.btns.btnIgnoreCripple = callback("ignoreCripple", "只打满血怪", function(value42)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnIgnoreCripple")
	end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
	h2 = h2 - 50

	if not def.closeCounterAttack then
		self.btns.btnAutoCounterAttack = callback("autoCounterAttack", "挂机自动反击", function(value43)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoCounterAttack = not g_data.setting.autoRat.autoCounterAttack
		end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
		h2 = h2 - 50
	end

	if g_data.player:getMagic(13) then
		self.btns.closeAttack = callback("closeAttack", "灵魂火符近身「平砍」", function(value44)
			self.cfg.autoRat = true
			g_data.setting.autoRat.closeAttack = not g_data.setting.autoRat.closeAttack
		end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
		h2 = h2 - 50
	end

	if items.openMagicAvoid then
		self.btns.closeAttack = callback("magicAvoid", "魔法技能「站撸」施法", function(value45)
			self.cfg.autoRat = true
			g_data.setting.autoRat.magicAvoid = not g_data.setting.autoRat.magicAvoid
		end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
		h2 = h2 - 50
	end

	self.btns.btnAutoSpaceMove = callback("autoSpaceMove", "", function(value46)
		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")
	end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

	local label12

	label12 = an.newInput(x + self.btns.btnAutoSpaceMove:getw(), h2 - 3, 45, 34, 5, {
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

			local space = tonumber(label12:getText()) or g_data.setting.autoRat.autoSpaceMove.space

			if space < 1 then
				space = 1
			end

			g_data.setting.autoRat.autoSpaceMove.space = space

			label12:setText("" .. g_data.setting.autoRat.autoSpaceMove.space)
		end
	}):add2(scroll2):anchor(0, 0.5)

	local label5 = an.newLabel("分钟无经验增加使用", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):add2(scroll2):pos(label12.getw(label12) + label12.getPositionX(label12), h2):enableClick(function()
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")
	end)
	local texts9 = "随机传送卷,随机传送石"
	local res8 = {
		"pic/panels/setting/icon_1.png",
		"pic/panels/setting/icon_7.png"
	}

	self.createSelectTab(self, {
		scale = 1,
		parent = self.content,
		texts = texts9,
		res = res8,
		curtext = g_data.setting.autoRat.autoSpaceMove.use,
		size = cc.size(128, 24),
		endFunc = function(use)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.use = use
		end
	}, self.content):anchor(0, 0.5):pos(label5.getw(label5) + label5.getPositionX(label5), h2):add2(scroll2, 2)

	h2 = h2 - 50

	if def.BIGAttackBtn and items.BIGAttackSkillNames then
		local value16 = items.BIGAttackSkillNames
		local value29
		local value30
		local value2 = g_data.setting.autoRat.defaultAtkMagic
		local value8 = callback6(value16)
		local texts8, res9, curtext2, magicId8 = callback2(value8, value2.magicId)

		value2.magicId = magicId8

		if value2.enable == nil and g_data.player:getMagic(1) then
			for itemId2, magicId2 in pairs(value8) do
				value2.magicId = magicId2
				curtext2 = itemId2
				value2.enable = true

				break
			end
		end

		curtext2 = curtext2 or ""

		if #texts8 ~= 0 then
			an.newLabel("设置大键攻击技能", 20, 1, {
				color = def.colors.labelYellow
			}):add2(scroll2):pos(x3 + 25, h2 - 6):anchor(0, 0)

			h2 = h2 - 30
			self.btns.btnDefauleAtkMagic = callback("defaultAtkMagic", "技能", function(value47)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnDefaultAtkMagic")
				main_scene.ui.console:call("attackBtns", "chgAttackType")
			end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

			local selectTab2 = self.createSelectTab(self, {
				parent = self.content,
				texts = texts8,
				res = res9,
				curtext = curtext2,
				size = cc.size(128, 24),
				endFunc = function(value25)
					self.cfg.autoRat = true
					g_data.setting.autoRat.defaultAtkMagic.magicId = value8[value25]

					main_scene.ui.console:call("attackBtns", "chgAttackType")
				end
			}, self.content):anchor(0, 0.5):pos(x + self.btns.btnDefauleAtkMagic:getw(), h2):add2(scroll2, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll2):pos(selectTab2.getw(selectTab2) + selectTab2.getPositionX(selectTab2), h2):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnDefaultAtkMagic")
			end)

			h2 = h2 - 50
		end
	end

	local magicIds = def.magic.getMagicIds(g_data.player.job, false)
	local texts2 = {}
	local res2 = {}
	local items2 = {}
	local value14
	local value17 = items.autoSkillPractice or {
		12,
		25,
		26,
		31,
		18,
		3,
		4,
		7,
		67
	}

	for _2, magicId in pairs(magicIds) do
		if g_data.player:getMagic(tonumber(magicId)) and not checkExist(tonumber(magicId), unpack(value17)) then
			local number2 = g_data.player:getMagic(tonumber(magicId))
			local magicConfigByUid = def.magic.getMagicConfigByUid(magicId, main_scene.ground.player)

			if magicConfigByUid.name or magic.heroName then
				local value4 = magicId
				local text = magicConfigByUid.name

				if text and string.find(text, "|") ~= nil then
					local parts = string.split(text, "|")
					local value5 = g_data.player.job

					if value5 >= 8 then
						value5 = value5 - 5
					end

					text = parts[value5 + 1]
					value4 = value4 .. "-" .. g_data.player.job
				end

				if magicConfigByUid.picId then
					value4 = magicConfigByUid.picId
				end

				if magicConfigByUid.extName then
					text = text and text .. magicConfigByUid.extName
				end

				if text or magic.heroName then
					texts2[#texts2 + 1] = text or magic.heroName
					res2[#res2 + 1] = "pic/console/skill-icons/" .. value4 .. ".png"
					items2[text or magic.heroName] = tonumber(magicId)

					if not g_data.setting.job.autoSkill.magicId or g_data.setting.job.autoSkill.magicId and tonumber(magicId) == g_data.setting.job.autoSkill.magicId then
						value14 = text or magic.heroName
						g_data.setting.job.autoSkill.magicId = magicId
					end
				end
			end
		end
	end

	if #texts2 > 0 then
		an.newLabel("自动练功", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll2):pos(x3 + 25, h2 - 6):anchor(0, 0)

		h2 = h2 - 30
		self.btns.btnAutoSkill = callback("autoSkill", "间隔", function(value48)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")
		end, true):add2(scroll2):pos(x, h2).btn

		local label13

		label13 = an.newInput(x + self.btns.btnAutoSkill:getw(), h2, 70, 34, 5, {
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
				self.cfg.job = true

				local number = tonumber(label13:getText()) or 1

				g_data.setting.job.autoSkill.space = tonumber(number) or g_data.setting.job.autoSkill.space

				label13:setText("" .. g_data.setting.job.autoSkill.space)
			end
		}):add2(scroll2):anchor(0, 0.5)

		local label6 = an.newLabel("秒使用", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll2):pos(label13.getw(label13) + label13.getPositionX(label13), h2):enableClick(function()
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")
		end)

		self.createSelectTab(self, {
			parent = self.content,
			texts = texts2,
			res = res2,
			curtext = value14 or "",
			size = cc.size(128, 24),
			endFunc = function(value26)
				self.cfg.job = true
				g_data.setting.job.autoSkill.magicId = items2[value26]
			end
		}, self.content):anchor(0, 0.5):pos(label6.getw(label6) + label6.getPositionX(label6), h2):add2(scroll2, 2)

		h2 = h2 - 45
	end

	an.newLabel("挂机捡取设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll2):pos(x3 + 25, h2 - 7):anchor(0, 0)

	h2 = h2 - 35
	self.btns.btnNoPickUpItem = callback("noPickUpItem", "挂机时不捡取任何道具", function(value49)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")

		if g_data.setting.autoRat.pickUpRatting then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")
		end
	end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
	h2 = h2 - 45
	self.btns.btnPickUpGood = callback("pickUpRatting", "捡取挂机道具", function(value50)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")

		if g_data.setting.autoRat.noPickUpItem then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")
		end
	end, true, "autoRat"):add2(scroll2):pos(x, h2).btn

	if def.openHorse then
		h2 = h2 - 55

		an.newLabel("自动上马设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll2):pos(x3 + 25, h2):anchor(0, 0)

		h2 = h2 - 30
		self.btns.autoShangma = callback("autoShangma", "大力拉摇杆自动上马", function(value51)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoShangma = not g_data.setting.autoRat.autoShangma
		end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
	end

	if def.role.mainsetting.autoStuffs then
		h2 = h2 - 55

		an.newLabel("自动使用消耗品", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll2):pos(x3 + 25, h2):anchor(0, 0)

		h2 = h2 - 30
		self.btns.btnAutoStuffs = callback("autoStuffs", "自动使用背包中指定消耗品", function(value52)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoStuffs = not g_data.setting.autoRat.autoStuffs
		end, true, "autoRat"):add2(scroll2):pos(x, h2).btn
		h2 = h2 - 45

		an.newLabel(string.format("(支持的消耗品：%s)", def.role.mainsetting.autoStuffs), 16, 1, {
			color = def.colors.labelYellow
		}):add2(scroll2):pos(x, h2)
	end

	scroll2.scrollView:scrollTo(0, 350)
end

function setting:loadView()
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_50.png"), 0, 50, cc.size(580, 460)):addTo(self.content):anchor(0, 0)
	local number = 150

	if def.showTasks then
		number = 60
		self.btns.taskShow = self.add(self, g_data.setting.base, "taskShow", "默认展开面板", function(value11)
			self.cfg.base = true
			g_data.setting.base.taskShow = not g_data.setting.base.taskShow
		end, true):pos(50, self.content:geth() - number):add2(self.content)
		self.btns.defaultTaskTab = self.add(self, g_data.setting.base, "defaultTaskTab", "默认显示任务", function(value12)
			self.cfg.base = true
			g_data.setting.base.defaultTaskTab = not g_data.setting.base.defaultTaskTab
		end, true):pos(250, self.content:geth() - number):add2(self.content)
		number = number + 130
	end

	local label2 = an.newLabel("地图缩放(1.0倍)", 22, 1, {
		color = def.colors.labelYellow
	}):add2(background):pos(50, self.content:geth() - number)

	local function callback(self2)
		self.cfg.display = true

		label2:setString(string.format("地图缩放(%s倍)", self2))
	end

	callback(g_data.setting.display.mapScale)

	local value5 = number + 10
	local value2 = def.minmapScale or 1
	local number2 = 1.8
	local count = 1
	local number3 = 1.25
	local number4 = 1.5
	local slider = an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
		scale9 = cc.size(background.getw(background) - 100, 15),
		value = (g_data.setting.display.mapScale - value2) / (number2 - value2),
		valueChange = function(value7)
			self:opacity(64)

			local value8 = (number2 - value2) * value7 + value2
			local mapScale2 = tonumber(string.format("%.2f", value8))

			callback(mapScale2)
			main_scene.ground:scale(mapScale2)

			g_data.setting.display.mapScale = mapScale2

			if main_scene.ground.map.setDark.control then
				main_scene.ground.map:uptSelfLight()
				main_scene.ground.map:uptRoleLightPosition()
			end
		end,
		valueChangeEnd = function(value9)
			self:opacity(255)

			local value10 = (number2 - value2) * value9 + value2
			local mapScale = tonumber(string.format("%.2f", value10))

			callback(mapScale)

			g_data.setting.display.mapScale = mapScale

			main_scene.ground:scale(mapScale)
			main_scene.ground.map:updateMapScale(mapScale)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
			main_scene.ground:uptNight()

			if main_scene.ground.map.setDark.control then
				main_scene.ground.map:uptSelfLight()
				main_scene.ground.map:uptRoleLightPosition()
			end
		end
	}):add2(self.content):pos(background.getw(background) / 2, self.content:geth() - value5):anchor(0.5, 0.5)
	local value4 = value5 + 65

	self.btns.moveSearch = self.add(self, g_data.setting.base, "moveSearch", "触屏后寻路到目标", function(value13)
		self.cfg.base = true
		g_data.setting.base.moveSearch = not g_data.setting.base.moveSearch
	end, true):pos(50, self.content:geth() - value4):add2(self.content).btn:setGray(not def.openMovetoAni)
	self.btns.musicEnalbe = self.add(self, g_data.setting.base, "musicEnalbe", "地图音乐", function(value14)
		self.cfg.base = true
		g_data.setting.base.musicEnalbe = not g_data.setting.base.musicEnalbe

		if g_data.setting.base.musicEnalbe then
			if g_data.setting.base.mapMusic then
				sound.playMusic(g_data.setting.base.mapMusic, true)
			end
		else
			sound.stopMusic()
		end
	end, true):pos(350, self.content:geth() - value4):add2(self.content)

	local value6 = value4 + 60

	self.btns.liuhaier = self.add(self, g_data.setting.base, "liuhaier", "手机刘海屏、灵动岛显示优化", function(value15)
		self.cfg.base = true
		g_data.setting.base.liuhaier = not g_data.setting.base.liuhaier
	end, true):pos(50, self.content:geth() - value6):add2(self.content)

	local function callback2(mapScale3)
		return function()
			sound.playSound("103")

			g_data.setting.display.mapScale = mapScale3

			callback(g_data.setting.display.mapScale)
			main_scene.ground:stopAllActions()
			main_scene.ground:scaleTo(0.3, mapScale3)
			main_scene.ground.map:updateMapScale(mapScale3)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
			slider:setValue((g_data.setting.display.mapScale - value2) / (number2 - value2))

			if main_scene.ground.map.setDark.control then
				main_scene.ground.map:uptSelfLight()
			end
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), callback2(count), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj1.png")
	}):pos(background.getw(background) / 6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), callback2(number3), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj2.png")
	}):pos(background.getw(background) * 3 / 6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), callback2(number4), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj3.png")
	}):pos(background.getw(background) * 5 / 6, self.cbottom + 22):add2(self.content)
	traversalNodeTree(self, function(value3)
		if value3 ~= label2 and value3 ~= slider then
			value3.setCascadeOpacityEnabled(value3, true)
		end

		return true
	end)
end

function setting:loadChat()
	local background2 = display.newScale9Sprite(res.getframe2("pic/common/black_50.png"), 0, 0, cc.size(580, 390)):addTo(self.content):anchor(0, 0)
	local count = 0
	local number = 240

	local function updateVisible(self2, value2, value5, value7, callback)
		local value3 = g_data.setting.chat[self2]
		local x = count % 3
		local value6 = math.modf(count / 3)
		local point = cc.p(x * 170 + 40, self.content:geth() - (value7 or 140) - value6 * 60)
		local value8 = cleanup(function(value4)
			self.cfg.chat = true
			self.needSaveSetting = true
			value3[value2] = value4

			if not value4 then
				-- block empty
			end

			if callback then
				callback(value3[value2])
			end
		end, value3[value2], {
			value5 or value2,
			18,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(point.x, point.y):add2(self.content)

		count = count + 1
	end

	local label2 = an.newLabel("拒绝", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 65)
	local background = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(55, 34):add2(self.content):pos(label2.getPositionX(label2) + label2.getw(label2) + 3, self.content:geth() - 70)
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
	}):add2(background):anchor(0, 0):pos(10, -5)

	an.newLabel("级以下玩家私聊", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(background.getPositionX(background) + background.getw(background) + 4, self.content:geth() - 65)
	an.newLabel("(此项填0时屏蔽所有人的私聊消息)", 18, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(50, self.content:geth() - 100)
	an.newLabel("自动播放语音", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 205)
	updateVisible("autoPlayVoice", "附近", "公聊", 240)
	updateVisible("autoPlayVoice", "私聊", nil, 240)
	updateVisible("autoPlayVoice", "喊话", nil, 240)
	updateVisible("autoPlayVoice", "组队", nil, 240)
	updateVisible("autoPlayVoice", "行会", nil, 240)
	updateVisible("autoPlayVoice", "战队", nil, 240)
end

function setting:load(name2)
	self.name = name2

	if self.content then
		self.content:removeSelf()
	end

	self.btns = {}
	self.content = display.newNode():pos(142, 15):size(580, 450):add2(self)
	self.ctop = self.content:geth()
	self.cbottom = 0
	self.cleft = 0
	self.cright = self.content:getw()

	if self.serverTime then
		self.serverTime:setVisible(false)
	end

	if name2 == "常用" then
		self.loadBase(self)

		if self.serverTime then
			self.serverTime:setVisible(true)
		end
	elseif name2 == "物品" then
		self.loadItem(self)
	elseif name2 == "保护" then
		self.loadPro(self)
	elseif name2 == "药品" then
		self.loadDrugs(self)
	elseif name2 == "挂机" then
		self.loadJob(self)
	elseif name2 == "显示" then
		self.loadView(self)
	elseif name2 == "帮助" then
		self.loadHelp(self)
	elseif name2 == "聊天" then
		self.loadChat(self)
	elseif name2 == "快捷键" then
		self.loadHotKeyView(self)
	else
		an.newLabel("功能研发中...", 18, 1):add2(self.content):anchor(0.5, 0.5):pos(self.content:getw() * self.content:getScale() / 2, self.content:geth() * self.content:getScale() / 2)
	end
end

function setting.createSelectTab(self3, res2, sender)
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

	local function cleanup(self)
		local text = type(res2.res) == "table" and res2.res[self] or string.format(res2.res, self)
		local value2 = res2.scale

		if type(text) == "table" then
			value2 = text[2]
			text = text[1]
		end

		return text, value2
	end

	local node
	local label2
	local value_2

	node = res.get2("pic/panels/setting/tab_frame.png"):enableClick(function(x, y2)
		local point = node:getParent():convertToNodeSpace(cc.p(x, y2))

		if cc.rectContainsPoint(node:getBoundingBox(), point) then
			node:setTouchSwallowEnabled(false)

			res2.size = node:getContentSize()

			local function cleanup2(self2, value11)
				local value_22 = res.get2("pic/panels/setting/tab_frame.png")
				local value12, value13 = cleanup(self2)
				local value_23 = res.get2(value12):anchor(0.5, 0.5):pos(32, 32):add2(value_22, 2)

				value_23.setScale(value_23, value13 or 52 / value_23.getw(value_23))
				an.newLabel(value11, res2.fontSize, res2.strokeSize, {
					color = res2.color
				}):anchor(0.5, 0.5):pos(value_22.getw(value_22) * 0.6, value_22.geth(value_22) * 0.5):addTo(value_22)

				return value_22
			end

			if res2.texts then
				local items2 = {}

				for index2, text2 in ipairs(res2.texts) do
					local items3 = {
						h = 50,
						w = 190,
						cellCls = function()
							return cleanup2(index2, text2)
						end,
						object = text2,
						index = index2
					}

					items2[#items2 + 1] = items3
				end

				local h2 = 240

				if #res2.texts < 5 then
					h2 = #res2.texts * 55 + 10
				end

				local operationMenu = common.createOperationMenu(items2, 5, function(value3, value5)
					local value4 = value5.object
					local value14 = value5.index

					label2:setString(value4)

					local value15, value16 = cleanup(value14)

					value_2:setTex(res.gettex2(value15))
					value_2:scale(value16 or 45 / value_2:getw())
					value3.removeSelf(value3)

					if res2.endFunc then
						res2.endFunc(value4)
					end
				end, {
					scroll = {
						w = 190,
						h = h2
					}
				}):anchor(0, 1)

				if res2.parent then
					operationMenu.add2(operationMenu, res2.parent)

					local point2 = cc.p(0, 0)
					local value10 = node:convertToWorldSpace(point2)
					local y = res2.parent:convertToNodeSpace(value10)

					operationMenu.pos(operationMenu, y.x, y.y + 50)
				else
					local position, position2 = node:getPosition()

					operationMenu.add2(operationMenu, node:getParent(), 50):pos(position, position2 - 20)
				end
			end
		end
	end)
	label2 = an.newLabel(res2.curtext, res2.fontSize, res2.strokeSize, {
		color = res2.color
	}):anchor(0.5, 0.5):pos(node.getw(node) * 0.6, node.geth(node) * 0.5):addTo(node)

	local value6, value7 = cleanup(1)

	value_2 = res.get2(value6):anchor(0.5, 0.5):pos(31, 34):add2(node, 2)

	value_2.setScale(value_2, value7 or 45 / value_2.getw(value_2))

	for index3, text3 in ipairs(res2.texts) do
		if text3 == res2.curtext then
			local value8, value9 = cleanup(index3)

			value_2.setTex(value_2, res.gettex2(value8))
			value_2.setScale(value_2, value9 or 45 / value_2.getw(value_2))
		end
	end

	return node
end

function setting:loadHotKeyView()
	self.hotKeyView = hotKeySetting.new():addTo(self.content)
end

return setting
