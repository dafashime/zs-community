local setting = class("setting", function ()
	return display.newNode()
end)
local magic = import("..common.magic")
local common = import("..common.common")
local hotKeySetting = import("..pc.hotKeySetting")

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

setting.onCleanup = function (self)
	for k, v in pairs(g_data.setting) do
		if type(v) == "table" and self.cfg[k] then
			cache.saveSetting(common.getPlayerName(), k)

			self.cfg[k] = false
		end
	end

	if self.modifiedItem then
		main_scene.ground.map:updateItems()
		main_scene.ui.console.autoRat:updateModifyProperty()
	end

	return 
end
setting.ctor = function (self, name)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)
	self.setCascadeOpacityEnabled(self, true)

	local bg = res.get2("pic/common/black_2.png"):anchor(0, 0):add2(self)

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):pos(display.cx, display.cy + 20)
	res.get2("pic/panels/setting/title.png"):anchor(0.5, 1):pos(self.getw(self)/2, self.geth(self) - 12):add2(bg)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(127, 390)):addTo(bg):pos(12, 15):anchor(0, 0)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self)

	self.name = nil
	self.content = nil

	self.initTabList(self)

	return 
end
setting.initTabList = function (self)
	self.tabs = {}
	local name = 物品
	local btns = {
		"基本",
		"物品",
		"保护",
		"药品",
		"辅助",
		"显示",
		"聊天"
	}
	local sprs = {
		"jb",
		"wp",
		"bh",
		"yp",
		"fz",
		"xs",
		"lt"
	}

	if WIN32_OPERATE then
		local extendBtns = {
			{
				name = "快捷键",
				spr = "kj"
			}
		}

		for _, v in ipairs(extendBtns) do
			table.insert(btns, v.name)
			table.insert(sprs, v.spr)
		end
	end

	local enable = true

	local function click(btn)
		sound.playSound("103")

		if not enable then
			return 
		end

		local clickedIndex = 1

		for i, v in ipairs(self.tabs) do
			if v == btn then
				v.select(v)

				clickedIndex = i
			else
				v.unselect(v)
			end
		end

		if btns[clickedIndex] ~= self.name then
			self:load(btns[clickedIndex])
		end

		return 
	end

	self.tabList = an.newScroll(12, 20, 127, 375):add2(self)

	self.tabList:enableTouch(WIN32_OPERATE)

	local checkDrag = display.newNode():pos(12, 15):size(127, 390):add2(self)

	checkDrag.setTouchEnabled(checkDrag, true)
	checkDrag.setTouchSwallowEnabled(checkDrag, false)
	checkDrag.addNodeEventListener(checkDrag, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			checkDrag.offsetBeginY = event.y
			enable = true

			return true
		elseif event.name == "moved" then
			local offsetY = event.y - checkDrag.offsetBeginY

			if 5 <= math.abs(offsetY) then
				enable = false
			end
		end

		return 
	end)

	for i, v in ipairs(btns) do
		self.tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			sprite = res.gettex2("pic/panels/setting/" .. sprs[i] .. ".png"),
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):anchor(0.5, 0):add2(self.tabList):pos(63, (i - 1)*50 - 325)

		self.tabs[i]:setCascadeOpacityEnabled(true)
		self.tabs[i]:setTouchSwallowEnabled(false)

		if (name or btns[1]) == v then
			click(self.tabs[i])
		end
	end

	return 
end

local function createToggle(cb, default, label, config)
	config = config or {}
	local base = display.newNode()
	local selsp = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(base)

	base.setContentSize(base, selsp.getContentSize(selsp))

	base.setIsSelect = function (self, enable)
		base.isSelected = enable

		if enable then
			base:select()
		else
			base:unselect()
		end

		return 
	end
	base.isSelect = function (self)
		return base.isSelected
	end
	base.select = function (self)
		base.isSelected = true

		if base.temp then
			base.temp:removeSelf()

			base.temp = nil
		end

		selsp:setTex(res.gettex2(config.selectImg or "pic/common/toggle02.png"))

		return 
	end
	base.select_temp = function (self)
		if base.temp then
			return 
		end

		base.temp = display.newFilteredSprite(res.gettex2(config.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(base)

		base.temp:setOpacity(80)

		return 
	end
	base.unselect = function (self)
		if base.temp then
			base.temp:removeSelf()

			base.temp = nil
		end

		base.isSelected = false

		selsp:setTex(res.gettex2("pic/common/toggle00.png"))

		return 
	end

	if default ~= nil then
		base.setIsSelect(base, default)
	end

	base.setTouchEnabled(base, true)
	base.addNodeEventListener(base, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			base.offsetBeginY = event.y
			base.offsetBeginX = event.x

			return true
		elseif event.name == "ended" then
			local offsetY = event.y - base.offsetBeginY
			local offsetX = event.x - base.offsetBeginX

			if math.abs(offsetY) <= 20 and math.abs(offsetX) <= 20 then
				base:setIsSelect(not base.isSelected)
				cb(base.isSelected)
			end
		end

		return 
	end)
	base.setTouchSwallowEnabled(base, false)

	if label then
		base.label = an.newLabel(unpack(label)):add2(base):pos(base.getw(base) + 7, base.geth(base)/2):anchor(0, 0.5)
		base.getw = function (self)
			return base.label:getw() + 40
		end
	end

	base.btn = base
	base.gray = function (self)
		local f = res.getFilter("gray")

		selsp:setFilter(f)
		base:setTouchEnabled(false)

		if base.temp then
			base.temp:setFilter(f)
		end

		return 
	end
	base.disGray = function (self)
		selsp:clearFilter()
		base:setTouchEnabled(true)

		if base.temp then
			base.temp:clearFilter(f)
		end

		return 
	end
	base.setGray = function (self, enable)
		if enable then
			base:gray()
		else
			base:disGray()
		end

		return base
	end

	return base
end

setting.add = function (data, key, name, func, externHandle)
	local node = display.newNode():size(120, 28):anchor(0, 0.5)
	node.btn = createToggle(function (b)
		if not externHandle then
			data[key] = b
		end

		if func then
			func(data[key])

			return 
		end

		return 
	end, data[key], {
		name,
		20,
		1,
		{
			color = def.colors.labelGray
		}
	}):anchor(0, 0.5):pos(0, 14):add2(node)

	return node
end
setting.addWith = function (types, data, key, name, func, externHandle)
	return 
end
setting.loadBase = function (self)
	baseAdd = handler(g_data.setting.base, setting.add)
	local bg = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local left = 20
	local top = self.content:geth() - 30
	local interval = 47
	self.btns.heroShowName = baseAdd("heroShowName", "人物显名", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHeroName")

		return 
	end, true):pos(left, top):add2(self.content).btn
	nextY = top - interval
	self.btns.NPCShowName = baseAdd("NPCShowName", "NPC显名", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNPCShowName")

		return 
	end, true):pos(left, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.petShowName = baseAdd("petShowName", "宠物显名", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPetShowName")

		return 
	end, true):pos(left, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.monShowName = baseAdd("monShowName", "怪物显名", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnMonShowName")

		return 
	end, true):pos(left, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.hiBlood = baseAdd("hiBlood", "高亮显血", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "hiBlood")
		main_scene.ground.player.info.hp.spr:setTex((g_data.setting.base.hiBlood and res.gettex2("pic/common/hp_green.png")) or res.getuitex(3, 1))

		return 
	end, true):pos(left, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.lockColor = baseAdd("lockColor", "锁定提示", function (b)
		self.cfg.base = true

		if b then
			for k, v in pairs(main_scene.ground.map.heros) do
				v.unselected(v)
			end

			for k, v in pairs(main_scene.ground.map.mons) do
				v.unselected(v)
			end
		end

		main_scene.ui.console.btnCallbacks:handle("setting", "lockColor")

		return 
	end, true):pos(left, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.warningDura = baseAdd("warningDura", "持久警告", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "warningDura")

		return 
	end, true):pos(left, nextY):add2(self.content).btn
	nextY = nextY - interval
	nextY = top
	self.btns.showExpEnable = baseAdd("showExpEnable", "经验显示过滤", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "showExpEnable")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	local valueInput = nil
	valueInput = an.newInput(self.btns.showExpEnable:getw() + 225, nextY - 2, 80, 34, 5, {
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
		stop_call = function ()
			self.cfg.base = true
			g_data.setting.base.showExpValue = tonumber(valueInput:getText()) or g_data.setting.base.showExpValue

			valueInput:setText("" .. g_data.setting.base.showExpValue)

			return 
		end
	}):add2(self.content):anchor(0, 0.5)
	nextY = nextY - interval
	self.btns.soundEnable = baseAdd("soundEnable", "音效", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnSoundEnable")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.touchRun = baseAdd("touchRun", "触屏跑步", function ()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnTouchRun")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.hideCorpse = baseAdd("hideCorpse", "隐藏尸体", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHideCorpse")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.showOutHP = baseAdd("showOutHP", "数字飘血", function (b)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnShowOutHP")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.quickexit = baseAdd("quickexit", "快速小退", function ()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnquickexit")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	nextY = nextY - interval
	self.btns.autoUnpack = baseAdd("autoUnpack", "自动解包", function ()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnautoUnpack")

		return 
	end, true):pos(left + 180, nextY):add2(self.content).btn
	nextY = nextY - interval

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local msgbox = an.newMsgbox("", function (idx)
			if idx == 1 then
				g_data.setting.reset()

				for k, v in pairs(g_data.setting) do
					cache.removeSetting(k)
				end

				main_scene:smallExit()
			end

			return 
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("所有的设置恢复默认, 并且将立即小退。\n 是否继续？", 20, 1):addTo(msgbox):pos(msgbox.centerPos(msgbox)):anchor(0.5, 0.5)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/czqb.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)

	return 
end
setting.loadItem = function (self)
	local indexBtn, cateFilt, valueInput = nil

	local function frash()
		self.modifiedItem = true

		indexBtn(valueInput:getText(), cateFilt.category, true)

		return 
	end

	local itemSetting = g_data.setting.item

	local function addS(...)
		local btn = self.add(itemSetting, ...)
		local tog = btn.btn

		tog.label:pos(-tog.label:getw()/2 + 10, tog.label:getPositionY()):scale(0.9)

		return btn
	end

	local bg = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local line = res.get2("pic/panels/setting/line.png"):anchor(0, 1):pos(0, bg.geth(bg) - 55):add2(bg)
	local nameTitle = an.newLabel("物品名称", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(self.cleft + 10, self.ctop - 40)
	local arItemTitle = addS("pickOnRatting", "挂机\n捡取", frash, false):add2(self.content):pos((self.content:getw() - 45)/5 + 70, self.ctop - 29)
	local pickUp = addS("pickUp", "捡取\n物品", frash, false):add2(self.content):pos(((self.content:getw() - 45)*2)/5 + 70, self.ctop - 29)
	local shownameTitle = addS("showName", "物品\n显名", frash, false):add2(self.content):pos(((self.content:getw() - 45)*3)/5 + 70, self.ctop - 29)
	local goodTitle = addS("hindGood", "极品\n特显", frash, false):add2(self.content):pos(((self.content:getw() - 45)*4)/5 + 70, self.ctop - 29)
	local scroll = an.newScroll(0, self.ctop - 58, self.cright, bg.geth(bg) - 65, {
		labelM = {
			18,
			1
		}
	}):anchor(0, 1):add2(self.content)
	local itemHeight = 42
	local orgItems = {
		{
			"极品属性道具",
			0,
			hightLight = true
		}
	}

	for k, v in pairs(def.items) do
		if type(v) == "table" and v.get then
			local itemName = v.get(v, "name")

			if itemName == "金币1" then
				itemName = "金币"
			end

			if itemSetting.filt[itemName] then
				orgItems[#orgItems + 1] = {
					itemName,
					k
				}
			end
		end
	end

	local items = orgItems

	scroll.setScrollSize(scroll, self.cright, itemHeight*#items)

	local tog2title = {
		isGood = goodTitle,
		pickOnRatting = arItemTitle,
		hintName = shownameTitle,
		pickUp = pickUp
	}

	local function addItemToggle(key, itemName, img)
		local btn = nil
		btn = createToggle(function (b)
			if btn.name then
				self.cfg.item = true
				itemSetting.filt[btn.name] = rawget(itemSetting.filt, btn.name) or false
				itemSetting.filt[btn.name][key] = b
				self.modifiedItem = true
			end

			return 
		end, selected, nil, {
			selectImg = "pic/common/" .. img .. ".png"
		}):anchor(0, 0)

		return btn
	end

	local function setSubData(ident, sub, height, disable)
		local data = items[ident]
		local itemName = data[1]
		sub.ident = ident
		sub.height = height

		data.label:pos(10, height + 3):setVisible(not disable)

		for k, v in ipairs({
			"isGood",
			"pickOnRatting",
			"hintName",
			"pickUp"
		}) do
			sub[v].name = itemName

			sub[v]:pos(sub[v]:getPositionX(), height)
			sub[v]:setVisible(not disable)

			local selected = nil

			if not itemSetting.filt[itemName] then
				selected = true
			else
				selected = itemSetting.filt[itemName][v]
			end

			if selected then
				sub[v].btn:select()
			else
				sub[v].btn:unselect()
			end

			if tog2title[v].btn:isSelect() then
				sub[v].btn:select_temp()
				sub[v].btn:gray()
			else
				sub[v].btn:disGray()
			end
		end

		return 
	end

	local function addSubItem(ident)
		if items[ident] then
			local data = items[ident]
			local subData = {
				height = scroll:getScrollSize().height - ident*itemHeight
			}

			if not data.added then
				local color = def.colors.labelYellow

				if data.hightLight then
					color = def.colors.clRed
				end

				data.label = an.newLabel(data[1], 20, 1, {
					bufferChannel = 0,
					color = color
				}):add2(scroll)
			end

			subData.pickOnRatting = addItemToggle("pickOnRatting", data[1], "toggle03"):add2(scroll):pos((scroll:getw() - 45)/5 + 70, subData.height)
			subData.pickUp = addItemToggle("pickUp", data[1], "toggle04"):add2(scroll):pos(((scroll:getw() - 45)*2)/5 + 70, subData.height)
			subData.hintName = addItemToggle("hintName", data[1], "toggle04"):add2(scroll):pos(((scroll:getw() - 45)*3)/5 + 70, subData.height)
			subData.isGood = addItemToggle("isGood", data[1], "toggle02"):add2(scroll):pos(((scroll:getw() - 45)*4)/5 + 70, subData.height)

			setSubData(ident, subData, subData.height)

			data.added = true
			data.showing = true

			return subData
		end

		return 
	end

	local itemSetters = {}

	local function setSubItem(ident, data, top, bottom)
		local curheight = scroll:getScrollSize().height - ident*itemHeight

		if items[ident].showing then
			return 
		end

		for k, v in ipairs(itemSetters) do
			if top < v.height or v.height < bottom then
				local pdata = items[v.ident]

				if pdata and pdata.showing then
					pdata.showing = false

					pdata.label:pos(0, 0):setVisible(false)
				end

				v.ident = ident
				v.height = curheight

				if not items[ident].added then
					items[ident].label = an.newLabel(items[ident][1], 20, 1, {
						bufferChannel = 0,
						color = def.colors.labelYellow
					}):add2(scroll):pos(25, curheight + 3)
					items[ident].added = true
				end

				setSubData(ident, v, curheight)

				items[ident].showing = true

				return 
			end
		end

		local subData = addSubItem(ident)

		table.insert(itemSetters, subData)

		return 
	end

	local preSearchName, preCate = nil

	function indexBtn(name, category, force)
		if preSearchName == name and preCate == category and not force then
			return 
		end

		preSearchName = name
		preCate = category
		local titems = {}
		local temp = {}

		for k, v in ipairs(orgItems) do
			local fs = itemSetting.filt[v[1]]

			if (not category or (fs and fs.category == category)) and (not name or string.find(v[1], name)) then
				temp[#temp + 1] = v
			end

			v.showing = false

			if v.label then
				v.label:removeFromParent()
			end

			v.label = nil
			v.added = false
		end

		for k, v in ipairs(itemSetters) do
			v.isGood:removeFromParent()
			v.pickOnRatting:removeFromParent()
			v.hintName:removeFromParent()
			v.pickUp:removeFromParent()
		end

		itemSetters = {}
		items = temp

		scroll:setScrollOffset(0, 0)
		scroll:setScrollSize(self.cright, itemHeight*#items)

		return 
	end

	local inputBack = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(220, 45):add2(self.content)
	valueInput = an.newInput(10, 3, 150, 38, 12, {
		label = {
			"",
			20,
			1
		},
		return_call = function ()
			self.cfg.item = true

			frash()

			return 
		end,
		tip = {
			" <输入关键字查找>" or "",
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}
	}):add2(inputBack):anchor(0, 0):pos(10, 1)

	an.newBtn(res.gettex2("pic/common/button_search.png"), function ()
		sound.playSound("103")
		indexBtn(valueInput:getText(), cateFilt.category)

		return 
	end):add2(self.content):pos(inputBack.getw(inputBack), inputBack.geth(inputBack)/2):anchor(1, 0.5)

	local cates = clone(def.items.category)

	table.insert(cates, 1, "全  部")

	local labels = {
		"全  部",
		"书籍类",
		"其它类",
		"武器类",
		"药品类",
		"勋章",
		"首饰类",
		"防具类"
	}
	local sprs = {
		"qbl",
		"sjl",
		"qtl",
		"wql",
		"ypl",
		"xzl",
		"ssl",
		"fjl"
	}

	local function getSpr(tType)
		for i, v in ipairs(labels) do
			if v == tType then
				return sprs[i]
			end
		end

		return sprs[1]
	end

	cateFilt = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local menuList = {}
		local menu = nil

		for k, v in pairs(cates) do
			local sub = {
				w = 110,
				h = 40,
				cate = v,
				cellCls = function ()
					local tex = "pic/common/btn20.png"
					local pretex = "pic/common/btn21.png"

					if cateFilt.labelInfo == v .. "  " then
						tex = "pic/common/btn10.png"
						pretex = "pic/common/btn11.png"
					end

					return an.newBtn(res.gettex2(tex), function ()
						sound.playSound("103")

						if cateFilt.labelInfo == v .. "  " then
							return 
						end

						self.cfg.item = true

						menu:removeSelf()
						cateFilt.sprite:setTex(res.gettex2("pic/panels/setting/" .. getSpr(v) .. ".png"))

						cateFilt.category = v

						if v == "全  部" then
							cateFilt.category = nil
						end

						indexBtn(valueInput:getText(), cateFilt.category)

						return 
					end, {
						pressImage = res.gettex2(pretex),
						labelInfo = v,
						sprite = res.gettex2("pic/panels/setting/" .. getSpr(v) .. ".png")
					})
				end
			}

			table.insert(menuList, sub)
		end

		menu = common.createOperationMenu(menuList, 10, function (pnl, cell)
			self.cfg.item = true

			return 
		end, {
			drag = true
		}):add2(cateFilt):pos(-14, 40)

		return 
	end, {
		labelInfo = "全  部",
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/qbarr.png")
	}):anchor(1, 0):pos(self.content:getw() - 120, 1):add2(self.content)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		self.cfg.item = true

		g_data.setting.resetItemFilt()

		preSearchName = nil

		indexBtn(valueInput:getText(), cateFilt.category)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/hfmr.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)

	local listener = cc.EventListenerCustom:create("director_after_update", function ()
		local x, y = scroll:getScrollOffset()
		local ssheight = scroll:getScrollSize().height
		local tItemIndex = math.ceil((y + scroll:geth())/itemHeight)
		local bItemIndex = math.floor(y/itemHeight)
		local str = ""

		for i = bItemIndex, tItemIndex, 1 do
			local ident = i + 1
			str = string.format("%s,%d", str, ident)

			if items[ident] then
				setSubItem(ident, items[ident], ssheight - y, ssheight - y - scroll:geth() - 30)
			end
		end

		return 
	end)

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

	scroll.onCleanup = function ()
		cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)

		return 
	end

	scroll.setNodeEventEnabled(scroll, true)

	return 
end
setting.loadPro = function (self)
	local function add(type, key, name, info, color)
		local data = g_data.setting.protected[type][key]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		createToggle(function (b)
			self.cfg.protected = true
			data.enable = b

			return 
		end, data.enable, {
			name,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, node.geth(node)/2):add2(node)

		local valueInput = nil
		valueInput = an.newInput(120, node.geth(node)/2 - 2, 80, 34, 5, {
			label = {
				"" .. data.value,
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
			stop_call = function ()
				self.cfg.protected = true
				data.value = tonumber(valueInput:getText()) or data.value

				if data.isPercent then
					data.value = math.min(data.value, 100)
				end

				valueInput:setText("" .. data.value)

				return 
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel(info, 20, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(230, node.geth(node)/2):add2(node)

		return node
	end

	local function addHeroProtected(type, key, color)
		local data = g_data.setting.protected[type][key]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		an.newLabel("躲闪血量", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(0, node.geth(node)/2):add2(node)

		local valueInput = nil
		valueInput = an.newInput(84, node.geth(node)/2 - 2, 80, 34, 5, {
			label = {
				"" .. data.value,
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
			stop_call = function ()
				self.cfg.protected = true
				data.value = tonumber(valueInput:getText()) or data.value
				data.value = math.max(data.value, 40)
				data.value = math.min(data.value, g_data.hero.ability:get("maxHP"))

				valueInput:setText("" .. data.value)
				net.send({
					CM_COMMON_INFORMATION,
					param = 2,
					recog = data.value
				})

				return 
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel("HP", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(160, node.geth(node)/2):add2(node)

		return node
	end

	local cellNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local tabs = {}
	local curName = nil
	local btns = {
		"role",
		"hero"
	}
	local offTop = 0

	local function click(selectIndex)
		self.cfg.protected = true

		cellNode:removeAllChildren()

		if selectIndex == 1 then
			local data = g_data.setting.protected.role

			an.newLabel("主号保护设置", 20, 1, {
				color = def.colors.labelYellow
			}):add2(cellNode):pos(15, cellNode:geth() - 42 - offTop)

			local labels = "随机传送卷,地牢逃脱卷,回城,行会回城卷,随机传送石,小退"
			local icons = {
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
				texts = labels,
				res = icons,
				curtext = data.hp.uses,
				size = cc.size(128, 24),
				endFunc = function (obj)
					data.hp.uses = obj

					return 
				end
			}):anchor(0, 0.5):pos(280, cellNode:geth() - 70 - offTop):add2(cellNode, 2)
			self:createSelectTab({
				scale = 1,
				texts = labels,
				res = icons,
				curtext = data.mp.uses,
				size = cc.size(128, 24),
				endFunc = function (obj)
					data.mp.uses = obj

					return 
				end
			}):anchor(0, 0.5):pos(280, cellNode:geth() - 140 - offTop):add2(cellNode, 1)
			add("role", "hp", "HP低于", "时使用", def.colors.labelGray):pos(15, cellNode:geth() - 70 - offTop):add2(cellNode)
			add("role", "mp", "MP低于", "时使用", def.colors.labelGray):pos(15, cellNode:geth() - 140 - offTop):add2(cellNode)

			return 
		end

		an.newLabel("英雄保护设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(cellNode):pos(15, cellNode:geth() - 42 - offTop)
		add("hero", "hp", "HP低于", "收英雄", def.colors.labelGray):pos(15, cellNode:geth() - 70 - offTop):add2(cellNode)
		add("hero", "mp", "MP低于", "收英雄", def.colors.labelGray):pos(15, cellNode:geth() - 120 - offTop):add2(cellNode)
		addHeroProtected("hero", "miss", def.colors.labelGray):pos(280, cellNode:geth() - 260 - offTop):add2(cellNode)
	end

	if def.gameVersionType == "185" then
		local preState = nil

		for k, v in ipairs({
			"主号",
			"英雄"
		}) do
			local index = k
			local sp = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(cellNode.getw(cellNode)/2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw()/2 - 5)*(k - 1) + 5, self.ctop - 5)
			local label = an.newLabel(v, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local selsp = res.get2("pic/common/button_click.png"):add2(sp):pos(sp.getw(sp)/2 - label.getw(label)/2, sp.geth(sp)/2)

			label.add2(label, selsp):pos(selsp.getw(selsp), 0)

			local selstate = res.get2("pic/common/button_click02.png"):add2(selsp):pos(selsp.getw(selsp)/2, selsp.geth(selsp)/2)

			selstate.setVisible(selstate, index == 1)
			sp.setTouchEnabled(sp, true)
			sp.addNodeEventListener(sp, cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					sp.offsetBeginY = event.y

					return true
				elseif event.name == "ended" then
					local offsetY = event.y - sp.offsetBeginY

					if math.abs(offsetY) <= 10 and not selstate:isVisible() then
						preState:setVisible(false)
						click(index)
						selstate:setVisible(true)

						preState = selstate
					end
				end

				return 
			end)

			preState = preState or selstate
		end

		offTop = 50
	end

	click(1)

	return 
end
setting.loadDrugs = function (self)
	local function add(settingData, key, name, min, info0, info1)
		local data = settingData[key]
		min = min or 10
		info0 = info0 or "请输入数字"
		info1 = info1 or "请输入数字"
		local node = display.newNode():size(460, 30)

		createToggle(function (b)
			self.cfg.drugs = true
			data.enable = b

			return 
		end, data.enable, {
			name,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(10, node.geth(node)/2):add2(node)

		if data.value < min then
			data.value = min
		end

		local inputBack = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(170, node.geth(node)/2):add2(node):size(85, 41)
		local inputLabel = an.newLabel("" .. (data.value or min), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(inputBack):pos(10, inputBack.geth(inputBack)*0.5)

		inputBack.enableClick(inputBack, function ()
			local msgbox = nil
			msgbox = an.newMsgbox(info0, function (idx)
				if idx == 1 then
					if msgbox.input:getString() == "" then
						return 
					end

					self.cfg.drugs = true
					local inputValue = tonumber(msgbox.input:getText())

					if inputValue then
						inputValue = (min < inputValue and inputValue) or min
					else
						inputValue = (min < data.value and data.value) or min
					end

					data.value = inputValue

					inputLabel:setString("" .. data.value)
				end

				return 
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 7, {
				label = {
					inputLabel:getString(),
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
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 20)

			return 
		end)

		local inputTimeBack = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(330, node.geth(node)/2):add2(node):size(85, 41)
		local inputTimeLabel = an.newLabel("" .. (data.space or 0), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(inputTimeBack):pos(10, inputTimeBack.geth(inputTimeBack)*0.5)

		inputTimeBack.enableClick(inputTimeBack, function ()
			local msgbox = nil
			msgbox = an.newMsgbox(info1, function (idx)
				if idx == 1 then
					if msgbox.input:getString() == "" then
						return 
					end

					self.cfg.drugs = true
					data.space = tonumber(msgbox.input:getText()) or data.space

					inputTimeLabel:setString("" .. (data.space or 0))
				end

				return 
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 7, {
				label = {
					inputTimeLabel:getString(),
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
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 20)

			return 
		end)

		return node
	end

	local function addPerItem(settingData, key, label)
		local data = settingData[key]
		local node = display.newNode()
		local lb = an.newLabel(label, 20, 1, {
			color = def.colors.labelGray
		}):add2(node):pos(0, 0):anchor(0, 0.5)
		local lbValue = an.newLabel(math.ceil(tonumber(data.value)*100) .. "%", 20, 1, {
			color = def.colors.labelGray
		}):add2(node):pos(370, 0):anchor(0, 0.5)

		local function valueChg(value)
			local per = math.ceil(tonumber(value)*100)
			self.cfg.drugs = true
			data.value = per/100

			lbValue:setString(tostring(per) .. "%")

			return 
		end

		local slider = an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
			scale9 = cc.size(250, 15),
			value = data.value,
			valueChange = valueChg,
			valueChangeEnd = valueChg
		}):add2(node):pos(100, 0):anchor(0, 0.5)

		slider.block:setScale(0.7)

		return node
	end

	local cellNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local space = 65
	local contentSize = cellNode.getContentSize(cellNode)
	local hasHero = def.gameVersionType == "185"

	function click(k)
		local top = cellNode:geth() - 35
		local contentHeight = contentSize.height - 75

		if hasHero then
			top = top - 50
			contentHeight = contentHeight - 50
		end

		cellNode:removeAllChildren()

		local settingData = g_data.setting.drugs.hero
		local cfg = g_data.setting.drugs.heroSetting

		if k == 1 then
			settingData = g_data.setting.drugs.role
			cfg = g_data.setting.drugs.roleSetting
		end

		local settingNode = an.newScroll(0, 20, contentSize.width, contentHeight):add2(cellNode)

		local function putItemsPercent(topPos)
			local data = settingData.percentDrug

			addPerItem(data, "normalHP", "普通红药"):add2(settingNode):pos(25, topPos)

			topPos = topPos - space

			addPerItem(data, "normalMP", "普通蓝药"):add2(settingNode):pos(25, topPos)

			topPos = topPos - space

			addPerItem(data, "quickHP", "瞬回红药"):add2(settingNode):pos(25, topPos)

			topPos = topPos - space

			addPerItem(data, "quickMP", "瞬回蓝药"):add2(settingNode):pos(25, topPos)

			topPos = topPos - space

			return topPos
		end

		local function putItemsNumber(topPos)
			topPos = topPos + space/2

			an.newLabel("剩余HP/MP", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(settingNode):pos(196, topPos)
			an.newLabel("间隔(毫秒)", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(settingNode):pos(364, topPos)
			res.get2("pic/common/b4.png"):anchor(0.5, 0.5):pos(230, topPos - 12):add2(settingNode)

			topPos = topPos - 40
			local data = settingData.numberDrug

			add(data, "normalHP", "普通红药", 0):pos(25, topPos):add2(settingNode):anchor(0, 0.5)

			topPos = topPos - space

			add(data, "normalMP", "普通蓝药", 0):pos(25, topPos):add2(settingNode):anchor(0, 0.5)

			topPos = topPos - space

			add(data, "quickHP", "瞬回红药", 0):pos(25, topPos):add2(settingNode):anchor(0, 0.5)

			topPos = topPos - space

			add(data, "quickMP", "瞬回蓝药", 0):pos(25, topPos):add2(settingNode):anchor(0, 0.5)

			topPos = topPos - space

			return topPos
		end

		local dataTypes = nil

		local function showItems(putItems)
			local topPos = contentHeight - space/2
			topPos = putItems(topPos)

			return topPos + 30
		end

		local function showAnnotation(topPos)
			local lb = an.newLabelM(settingNode:getw() - 20, 20, 1):add2(settingNode):pos(10, topPos - 90)

			local function put(title, annotation)
				lb:addLabel(title, def.colors.labelYellow)
				lb:addLabel(annotation, def.colors.clRed)

				return 
			end

			lb.addLabel(lb, "注:\n", def.colors.labelYellow)
			put("普通红药:", "金创药(小量)、金创药(中量)、强效金创药\n")
			put("普通蓝药:", "魔法药(小量)、魔法药(中量)、强效魔法药\n")
			put("瞬回药:", "太阳水、强效太阳水、万年雪霜、疗伤药")

			return 
		end

		local curTop = top
		local perTog, numTog = nil

		local function switch(b)
			self.cfg.drugs = true
			top = curTop - space

			settingNode:removeSelf()

			settingNode = an.newScroll(0, 20, contentSize.width, contentHeight):add2(cellNode)
			cfg.withPercent = b
			cfg.withNumber = not b

			if b then
				perTog.btn:select()
				numTog.btn:unselect()

				top = showItems(putItemsPercent)
			else
				perTog.btn:unselect()
				numTog.btn:select()

				top = showItems(putItemsNumber)
			end

			showAnnotation(top)

			return 
		end

		perTog = setting.add(cfg, "withPercent", "按百分比自动喝药", function (b)
			switch(not b)

			return 
		end, true):add2(cellNode):pos(20, top)
		numTog = setting.add(cfg, "withNumber", "按血量自动喝药", switch, true):add2(cellNode):pos(250, top)
		top = top - space + 20

		if cfg.withPercent then
			top = showItems(putItemsPercent)
		else
			top = showItems(putItemsNumber)
		end

		showAnnotation(top)

		return 
	end

	click(1)

	if hasHero then
		local preState = nil

		for k, v in ipairs({
			"主号",
			"英雄"
		}) do
			local index = k
			local sp = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(cellNode.getw(cellNode)/2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw()/2 - 5)*(k - 1) + 5, self.ctop - 5)
			local label = an.newLabel(v, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local selsp = res.get2("pic/common/button_click.png"):add2(sp):pos(sp.getw(sp)/2 - label.getw(label)/2, sp.geth(sp)/2)

			label.add2(label, selsp):pos(selsp.getw(selsp), 0)

			local selstate = res.get2("pic/common/button_click02.png"):add2(selsp):pos(selsp.getw(selsp)/2, selsp.geth(selsp)/2)

			selstate.setVisible(selstate, index == 1)
			sp.setTouchEnabled(sp, true)
			sp.addNodeEventListener(sp, cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					sp.offsetBeginY = event.y

					return true
				elseif event.name == "ended" then
					local offsetY = event.y - sp.offsetBeginY

					if math.abs(offsetY) <= 10 and not selstate:isVisible() then
						preState:setVisible(false)
						click(index)
						selstate:setVisible(true)

						preState = selstate
					end
				end

				return 
			end)

			preState = preState or selstate
		end
	end

	return 
end
setting.loadJob = function (self)
	local cellNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local playerName = common.getPlayerName()
	local scroll = an.newScroll(0, 5, cellNode.getw(cellNode), cellNode.geth(cellNode) - 10, {
		labelM = {
			18,
			1
		}
	}):add2(cellNode)
	local offsetX = 25

	local function generateSklSelectData(skillNames, func)
		local labels = {}
		local icons = {}
		local curText, default = nil

		for k, v in pairs(skillNames) do
			if g_data.player:getMagic(v) then
				table.insert(icons, string.format("pic/console/skill-icons/%d.png", v))
				table.insert(labels, k)

				if type(func) == "number" then
					if func == v then
						curText = k
						default = v
					end
				elseif type(func) == "function" then
					func(k, v)
				elseif not func then
					curText = k
					default = v
					func = v
				end
			end
		end

		return labels, icons, curText or "", default
	end

	local nextPosY = 0

	local function add(key, name, func, externHandle, setting, gray)
		local data = g_data.setting[setting or "job"]
		local node = display.newNode():anchor(0, 0.5)
		local enable = data[key]

		if type(enable) == "table" then
			enable = enable.enable
		end

		node.btn = createToggle(function (b)
			self.cfg.autoRat = true

			if not externHandle then
				data[key] = b
			end

			if func then
				func(data[key])

				return 
			end

			return 
		end, enable, {
			name,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, 14):add2(node)

		node.size(node, node.btn:getw(), node.btn:geth())

		return node
	end

	local titleOff = -10

	an.newLabel("技能", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll):pos(offsetX + titleOff, self.content:geth() - 50)

	nextPosY = self.content:geth() - 68

	local function addHeroCfg()
		if not g_data.hero or not g_data.hero.roleid then
			return 
		end

		local x = offsetX

		if g_data.hero:getMagic(31) then
			self.btns.btnautoDunHero = add("autoDunHero", "英雄持续开盾", function (b)
				self.cfg.job = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnautoDunHero")

				return 
			end, true):add2(scroll):pos(x, nextPosY).btn
			hasSkill = true
			nextPosY = nextPosY - 43
		end

		return nextPosY
	end

	local playerJob = g_data.player.job

	if playerJob == 0 then
		local x = offsetX
		self.btns.btnAutoAllSpace = add("autoAllSpace", "刀刀刺杀", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoAllSpace")

			return 
		end, true):add2(scroll):pos(x, nextPosY).btn:setGray(not g_data.player:getMagic(12))
		x = x + 240
		self.btns.btnAutoAllSpace = add("autoSpace", "隔位刺杀", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpace")

			return 
		end, true):add2(scroll):pos(x, nextPosY).btn:setGray(not g_data.player:getMagic(12))
		x = offsetX
		nextPosY = nextPosY - 45
		self.btns.btnAutoFire = add("autoFire", "自动烈火", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoFire")

			return 
		end, true):add2(scroll):pos(x, nextPosY).btn:setGray(not g_data.player:getMagic(26))
		x = x + 240
		self.btns.btnAutoWide = add("autoWide", "智能半月", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoWide")

			return 
		end, true):add2(scroll):pos(x, nextPosY).btn:setGray(not g_data.player:getMagic(25))
		x = offsetX
		nextPosY = nextPosY - 45
		self.btns.btnAutoSword = add("autoSword", "逐日剑法", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSword")

			return 
		end, true):add2(scroll):pos(x, nextPosY).btn:setGray(not g_data.player:getMagic(58))
		nextPosY = nextPosY - 45

		addHeroCfg()
		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(titleOff + 25, nextPosY - 6):anchor(0, 0)

		nextPosY = nextPosY - 36
		self.btns.btnAutoRoar = add("autoRoar", "身边有", function (b)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")

			return 
		end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn:setGray(not g_data.player:getMagic(43))
		local roarInput = nil
		roarInput = an.newInput(self.btns.btnAutoRoar:getw() + 30, nextPosY - 7, 70, 34, 5, {
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
			stop_call = function ()
				self.cfg.autoRat = true
				g_data.setting.autoRat.autoRoar.cnt = tonumber(roarInput:getText()) or g_data.setting.autoRat.autoRoar.cnt

				roarInput:setText("" .. g_data.setting.autoRat.autoRoar.cnt)

				return 
			end
		}):add2(scroll):anchor(0, 0.5)

		an.newLabel("个怪时使用狮子吼", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll):pos(roarInput.getw(roarInput) + roarInput.getPositionX(roarInput), nextPosY - 3):enableClick(function ()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")

			return 
		end)

		nextPosY = nextPosY - 45
	elseif playerJob == 1 then
		self.btns.btnAutoDun = add("autoDun", "自动魔法盾", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoDun")

			return 
		end, true):add2(scroll):pos(offsetX, nextPosY).btn:setGray(not g_data.player:getMagic(31))
		nextPosY = nextPosY - 42

		addHeroCfg()
		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(titleOff + 25, nextPosY - 6):anchor(0, 0)

		nextPosY = nextPosY - 30
		local skillNames = {
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
		local curAtkMagic, curAreaMagic = nil
		local atkMagic = g_data.setting.autoRat.atkMagic
		local labels, icons, curAtkMagic, magicId = generateSklSelectData(skillNames, atkMagic.magicId)
		atkMagic.magicId = magicId

		if atkMagic.enable == nil and g_data.player:getMagic(1) then
			atkMagic.magicId = 1
			curAtkMagic = "火球术"
			atkMagic.enable = true
		end

		curAtkMagic = curAtkMagic or ""

		if #labels ~= 0 then
			self.btns.btnAtkMagic = add("atkMagic", "挂机技能", function (b)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")

				return 
			end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
			local atkMagic = self.createSelectTab(self, {
				parent = self.content,
				texts = labels,
				res = icons,
				curtext = curAtkMagic,
				size = cc.size(128, 24),
				endFunc = function (obj)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = skillNames[obj]

					return 
				end
			}, self.content):anchor(0, 0.5):pos(offsetX + self.btns.btnAtkMagic:getw(), nextPosY):add2(scroll, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(atkMagic.getw(atkMagic) + atkMagic.getPositionX(atkMagic), nextPosY):enableClick(function ()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")

				return 
			end)

			nextPosY = nextPosY - 50
		end

		local areaSkillNames = {
			流星火雨 = 59,
			地狱火 = 9,
			爆裂火焰 = 23,
			冰咆哮 = 33,
			疾光电影 = 10,
			地狱雷光 = 24
		}
		local areaMagic = g_data.setting.autoRat.areaMagic
		local areaLabels, areaIcons, curAreaMagic, magicId = generateSklSelectData(areaSkillNames, areaMagic.magicId)
		areaMagic.magicId = magicId

		if 0 < #areaLabels then
			local areaMagic = add("areaMagic", "目标身边有", function (b)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")

				return 
			end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY)
			self.btns.btnareaMagic = areaMagic.btn
			local roarInput = nil
			roarInput = an.newInput(areaMagic.getw(areaMagic) + 30, nextPosY - 7, 35, 34, 5, {
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
				stop_call = function ()
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.cnt = tonumber(roarInput:getText()) or g_data.setting.autoRat.areaMagic.cnt

					roarInput:setText("" .. g_data.setting.autoRat.areaMagic.cnt)

					return 
				end
			}):add2(scroll):anchor(0, 0.5)
			local label = an.newLabel("个怪时使用", 20, 1, {
				color = def.colors.labelGray
			})

			label.anchor(label, 0, 0.5):add2(scroll):pos(roarInput.getw(roarInput) + roarInput.getPositionX(roarInput), nextPosY):enableClick(function ()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")

				return 
			end)
			self.createSelectTab(self, {
				parent = self.content,
				texts = areaLabels,
				res = areaIcons,
				curtext = curAreaMagic,
				size = cc.size(128, 24),
				endFunc = function (obj)
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.magicId = areaSkillNames[obj]

					return 
				end
			}, self.content):anchor(0, 0.5):pos(label.getPositionX(label) + label.getw(label), nextPosY):add2(scroll, 2)

			nextPosY = nextPosY - 50
		end
	elseif playerJob == 2 then
		local nextPosX = offsetX
		self.btns.btnAutoInvisible = add("autoInvisible", "自动隐身", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoInvisible")

			return 
		end, true):add2(scroll):pos(nextPosX, nextPosY).btn:setGray(not g_data.player:getMagic(18))
		nextPosX = 180
		self.btns.btnAutoPoison = add("autoPoison", "自动施毒", function (b)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPoison")

			return 
		end, true, "autoRat"):add2(scroll):pos(nextPosX, nextPosY).btn:setGray(not g_data.player:getMagic(6))
		nextPosY = nextPosY - 40
		nextPosX = offsetX
		self.btns.btnAutoYoulingDun = add("autoYoulingDun", "自动幽灵盾", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoYoulingDun")

			return 
		end, true, "job"):add2(scroll):pos(nextPosX, nextPosY).btn:setGray(not g_data.player:getMagic(14))
		nextPosX = 180
		self.btns.btnAutoZhanjiashu = add("autoZhanjiashu", "自动神圣战甲术", function (b)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoZhanjiashu")

			return 
		end, true, "job"):add2(scroll):pos(nextPosX, nextPosY).btn:setGray(not g_data.player:getMagic(15))
		nextPosY = nextPosY - 40
		nextPosY = addHeroCfg(nextPosY)

		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(titleOff + 25, nextPosY - 6):anchor(0, 0)

		nextPosY = nextPosY - 36
		local skillNames = {
			灵魂火符 = 13,
			噬血术 = 48
		}
		local atkMagic = g_data.setting.autoRat.atkMagic
		local labels, icons, curText, magicId = generateSklSelectData(skillNames, atkMagic.magicId)
		atkMagic.magicId = magicId
		local skillNames1 = {
			召唤骷髅 = 17,
			召唤神兽 = 30
		}
		local autoPet = g_data.setting.autoRat.autoPet
		local labels1, icons1, curText1, magicId = generateSklSelectData(skillNames1, autoPet.magicId)
		autoPet.magicId = magicId
		local skillNames2 = {
			治愈术 = 2,
			群体治疗术 = 29
		}
		local autoCure = g_data.setting.autoRat.autoCure
		local labels2, icons2, curText2, magicId = generateSklSelectData(skillNames2, autoCure.magicId)
		autoCure.magicId = magicId

		if 0 < #labels then
			self.btns.btnAtkMagic = add("atkMagic", "", function (b)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")

				return 
			end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
			local atkMagic = self.createSelectTab(self, {
				parent = self.content,
				texts = labels,
				res = icons,
				curtext = curText,
				size = cc.size(128, 24),
				endFunc = function (obj)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = skillNames[obj]

					return 
				end
			}, self.content):anchor(0, 0.5):pos(offsetX + self.btns.btnAtkMagic:getw(), nextPosY):add2(scroll, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(atkMagic.getw(atkMagic) + atkMagic.getPositionX(atkMagic), nextPosY):enableClick(function ()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")

				return 
			end)

			nextPosY = nextPosY - 50
		else
			g_data.setting.autoRat.atkMagic.enable = false
		end

		if 0 < #labels1 then
			self.btns.btnAutoPet = add("autoPet", "自动召唤宠物", function (b)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPet")

				return 
			end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn

			self.createSelectTab(self, {
				parent = self.content,
				texts = labels1,
				res = icons1,
				curtext = curText1 or "",
				size = cc.size(128, 24),
				endFunc = function (obj)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoPet.magicId = skillNames1[obj]

					return 
				end
			}, self.content):anchor(0, 0.5):pos(offsetX + self.btns.btnAutoPet:getw(), nextPosY):add2(scroll, 2)

			nextPosY = nextPosY - 50
		end

		if 0 < #labels2 then
			self.btns.btnAutoCure = add("autoCure", "人物血量低于", function (b)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")

				return 
			end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
			local percentInput = nil
			percentInput = an.newInput(offsetX + self.btns.btnAutoCure:getw(), nextPosY - 3, 40, 34, 5, {
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
				stop_call = function ()
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.percent = tonumber(percentInput:getText()) or g_data.setting.autoRat.autoCure.percent

					percentInput:setText("" .. g_data.setting.autoRat.autoCure.percent)

					return 
				end
			}):add2(scroll):anchor(0, 0.5)
			local autoSkillText = an.newLabel("%时使用", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(percentInput.getw(percentInput) + percentInput.getPositionX(percentInput), nextPosY):enableClick(function ()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")

				return 
			end)

			self.createSelectTab(self, {
				parent = self.content,
				texts = labels2,
				res = icons2,
				curtext = curText2,
				size = cc.size(128, 24),
				endFunc = function (obj)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.magicId = skillNames2[obj]

					return 
				end
			}, self.content):anchor(0, 0.5):pos(autoSkillText.getw(autoSkillText) + autoSkillText.getPositionX(autoSkillText), nextPosY):add2(scroll, 2)

			nextPosY = nextPosY - 50
		end

		if 0 < #skillNames1 then
			local skillNames = {
				治愈术 = 2,
				群体治疗术 = 29
			}
			local autoCurePet = autoCurePet.magicId
			local labels, icons, curText, magicId = generateSklSelectData(skillNames, autoCurePet.magicId)
			autoCurePet.magicId = magicId

			if 0 < #labels then
				self.btns.btnAutoCurePet = add("autoCurePet", "宠物血量低于", function (b)
					self.cfg.autoRat = true

					main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")

					return 
				end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
				local percentInput = nil
				percentInput = an.newInput(offsetX + self.btns.btnAutoCurePet:getw(), nextPosY - 3, 40, 34, 5, {
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
					stop_call = function ()
						self.cfg.autoRat = true
						g_data.setting.autoRat.autoCurePet.percent = tonumber(percentInput:getText()) or g_data.setting.autoRat.autoCurePet.percent

						percentInput:setText("" .. g_data.setting.autoRat.autoCurePet.percent)

						return 
					end
				}):add2(scroll):anchor(0, 0.5)
				local autoSkillText = an.newLabel("%时使用", 20, 1, {
					color = def.colors.labelGray
				}):anchor(0, 0.5):add2(scroll):pos(percentInput.getw(percentInput) + percentInput.getPositionX(percentInput), nextPosY):enableClick(function ()
					self.cfg.autoRat = true

					main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")

					return 
				end)

				self.createSelectTab(self, {
					parent = self.content,
					texts = labels,
					res = icons,
					curtext = curText,
					size = cc.size(128, 24),
					endFunc = function (obj)
						self.cfg.autoRat = true
						g_data.setting.autoRat.autoCurePet.magicId = skillNames[obj]

						return 
					end
				}, self.content):anchor(0, 0.5):pos(autoSkillText.getw(autoSkillText) + autoSkillText.getPositionX(autoSkillText), nextPosY):add2(scroll, 2)

				nextPosY = nextPosY - 50
			end
		end
	end

	self.btns.btnIgnoreCripple = add("ignoreCripple", "只打满血怪", function (b)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnIgnoreCripple")

		return 
	end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
	nextPosY = nextPosY - 50
	self.btns.btnAutoSpaceMove = add("autoSpaceMove", "", function (b)
		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")

		return 
	end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
	local skillInput = nil
	skillInput = an.newInput(offsetX + self.btns.btnAutoSpaceMove:getw(), nextPosY - 3, 45, 34, 5, {
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
		stop_call = function ()
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.space = tonumber(skillInput:getText()) or g_data.setting.autoRat.autoSpaceMove.space

			skillInput:setText("" .. g_data.setting.autoRat.autoSpaceMove.space)

			return 
		end
	}):add2(scroll):anchor(0, 0.5)
	local spaceMoveText = an.newLabel("分钟无经验增加使用", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):add2(scroll):pos(skillInput.getw(skillInput) + skillInput.getPositionX(skillInput), nextPosY):enableClick(function ()
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")

		return 
	end)
	local labels = "随机传送卷,随机传送石"
	local icons = {
		"pic/panels/setting/icon_1.png",
		"pic/panels/setting/icon_7.png"
	}

	self.createSelectTab(self, {
		scale = 1,
		parent = self.content,
		texts = labels,
		res = icons,
		curtext = g_data.setting.autoRat.autoSpaceMove.use,
		size = cc.size(128, 24),
		endFunc = function (obj)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.use = obj

			return 
		end
	}, self.content):anchor(0, 0.5):pos(spaceMoveText.getw(spaceMoveText) + spaceMoveText.getPositionX(spaceMoveText), nextPosY):add2(scroll, 2)

	nextPosY = nextPosY - 50
	local keys = def.magic.getMagicIds(g_data.player.job, false)
	local labels = {}
	local icons = {}
	local kList = {}
	local curSkillName = nil

	for i, v in ipairs(keys) do
		if g_data.player:getMagic(tonumber(v)) and not checkExist(tonumber(v), 12, 25, 26, 31, 18, 3, 4, 7, 67) then
			local magicCfg = def.magic.getMagicConfigByUid(v)
			labels[#labels + 1] = magicCfg.name
			icons[#icons + 1] = string.format("pic/console/skill-icons/%d.png", v)
			kList[magicCfg.name] = tonumber(v)

			if not g_data.setting.job.autoSkill.magicId or (g_data.setting.job.autoSkill.magicId and tonumber(v) == g_data.setting.job.autoSkill.magicId) then
				curSkillName = magicCfg.name
			end
		end
	end

	if 0 < #labels then
		an.newLabel("自动练功", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(titleOff + 25, nextPosY - 6):anchor(0, 0)

		nextPosY = nextPosY - 30
		self.btns.btnAutoSkill = add("autoSkill", "间隔", function (b)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")

			return 
		end, true):add2(scroll):pos(offsetX, nextPosY).btn
		local skillInput = nil
		skillInput = an.newInput(offsetX + self.btns.btnAutoSkill:getw(), nextPosY, 70, 34, 5, {
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
			stop_call = function ()
				self.cfg.autoRat = true
				g_data.setting.job.autoSkill.space = tonumber(skillInput:getText()) or g_data.setting.job.autoSkill.space

				skillInput:setText("" .. g_data.setting.job.autoSkill.space)

				return 
			end
		}):add2(scroll):anchor(0, 0.5)
		local autoSkillText = an.newLabel("秒使用", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll):pos(skillInput.getw(skillInput) + skillInput.getPositionX(skillInput), nextPosY):enableClick(function ()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")

			return 
		end)

		self.createSelectTab(self, {
			parent = self.content,
			texts = labels,
			res = icons,
			curtext = curSkillName or "",
			size = cc.size(128, 24),
			endFunc = function (obj)
				self.cfg.autoRat = true
				g_data.setting.job.autoSkill.magicId = kList[obj]

				return 
			end
		}, self.content):anchor(0, 0.5):pos(autoSkillText.getw(autoSkillText) + autoSkillText.getPositionX(autoSkillText), nextPosY):add2(scroll, 2)

		nextPosY = nextPosY - 50
	end

	an.newLabel("挂机捡取设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll):pos(titleOff + 25, nextPosY):anchor(0, 0)

	nextPosY = nextPosY - 25
	self.btns.btnNoPickUpItem = add("noPickUpItem", "挂机时不捡取任何道具", function (b)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")

		if g_data.setting.autoRat.pickUpRatting then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")
		end

		return 
	end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn
	nextPosY = nextPosY - 45
	self.btns.btnPickUpGood = add("pickUpRatting", "捡取挂机道具", function (b)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")

		if g_data.setting.autoRat.noPickUpItem then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")
		end

		return 
	end, true, "autoRat"):add2(scroll):pos(offsetX, nextPosY).btn

	return 
end
setting.loadView = function (self)
	local bg = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local num = an.newLabel("地图缩放(1.0倍)", 22, 1, {
		color = def.colors.labelYellow
	}):add2(bg):pos(50, self.content:geth() - 150)

	local function upt(scale)
		self.cfg.display = true

		num:setString("地图缩放(" .. scale .. "倍)")

		return 
	end

	upt(g_data.setting.display.mapScale)

	local scaleMin = 0.7
	local scaleMax = 2.3
	local scaleDefault = 1
	local scaleDefault2 = 1.25
	local scaleDefault3 = 1.5
	local slider = an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
		scale9 = cc.size(bg.getw(bg) - 100, 15),
		value = (g_data.setting.display.mapScale - scaleMin)/(scaleMax - scaleMin),
		valueChange = function (value)
			self:opacity(64)

			local scale = (scaleMax - scaleMin)*value + scaleMin
			scale = tonumber(string.format("%.2f", scale))

			upt(scale)
			main_scene.ground:scale(scale)

			return 
		end,
		valueChangeEnd = function (value)
			self:opacity(255)

			local scale = (scaleMax - scaleMin)*value + scaleMin
			scale = tonumber(string.format("%.2f", scale))

			upt(scale)

			g_data.setting.display.mapScale = scale

			main_scene.ground:scale(scale)
			main_scene.ground.map:updateMapScale(scale)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)

			return 
		end
	}):add2(self.content):pos(bg.getw(bg)/2, self.content:geth() - 170):anchor(0.5, 0.5)

	function default(v)
		return function ()
			sound.playSound("103")

			g_data.setting.display.mapScale = v

			upt(g_data.setting.display.mapScale)
			main_scene.ground:stopAllActions()
			main_scene.ground:scaleTo(0.3, v)
			main_scene.ground.map:updateMapScale(v)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
			slider:setValue((g_data.setting.display.mapScale - scaleMin)/(scaleMax - scaleMin))

			return 
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), default(scaleDefault), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj1.png")
	}):pos(bg.getw(bg)/6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), default(scaleDefault2), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj2.png")
	}):pos((bg.getw(bg)*3)/6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), default(scaleDefault3), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj3.png")
	}):pos((bg.getw(bg)*5)/6, self.cbottom + 22):add2(self.content)
	traversalNodeTree(self, function (n)
		if n ~= num and n ~= slider then
			n.setCascadeOpacityEnabled(n, true)
		end

		return true
	end)

	return 
end
setting.loadChat = function (self)
	local bg = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local cnt = 0
	local y = 240

	local function add(root, key, name, y, func)
		local data = g_data.setting.chat[root]
		local col = cnt%3
		local line = math.modf(cnt/3)
		local pos = cc.p(col*170 + 40, self.content:geth() - (y or 140) - line*60)

		createToggle(function (b)
			self.cfg.chat = true
			self.needSaveSetting = true
			data[key] = b

			if not b then
				voice.removeAutoPlayItemWithChannel(key)
			end

			if func then
				func(data[key])
			end

			return 
		end, data[key], {
			name or key,
			18,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(pos.x, pos.y):add2(self.content)

		cnt = cnt + 1

		return 
	end

	local limitLabel1 = an.newLabel("拒绝", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 65)
	local inputBack = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(55, 34):add2(self.content):pos(limitLabel1.getPositionX(limitLabel1) + limitLabel1.getw(limitLabel1) + 3, self.content:geth() - 70)
	local valueInput = nil
	valueInput = an.newInput(10, 3, 150, 38, 3, {
		label = {
			tostring(g_data.setting.chat.whisperLimit),
			20,
			1
		},
		stop_call = function ()
			self.cfg.chat = true
			g_data.setting.chat.whisperLimit = tonumber(valueInput:getString())

			return 
		end
	}):add2(inputBack):anchor(0, 0):pos(10, -5)

	an.newLabel("级以下玩家私聊", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(inputBack.getPositionX(inputBack) + inputBack.getw(inputBack) + 4, self.content:geth() - 65)
	an.newLabel("(此项填0时屏蔽所有人的私聊消息)", 18, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(50, self.content:geth() - 100)
	self.add(g_data.setting.chat, "alwaysTranslate", "只发送语音翻译文字"):add2(self.content):pos(40, self.content:geth() - 135)
	an.newLabel("自动播放语音", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 205)
	add("autoPlayVoice", "附近", "公聊", 240)
	add("autoPlayVoice", "私聊", nil, 240)
	add("autoPlayVoice", "喊话", nil, 240)
	add("autoPlayVoice", "组队", nil, 240)
	add("autoPlayVoice", "行会", nil, 240)
	add("autoPlayVoice", "战队", nil, 240)

	return 
end
setting.load = function (self, name)
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

	if name == "基本" then
		self.loadBase(self)
	elseif name == "物品" then
		self.loadItem(self)
	elseif name == "保护" then
		self.loadPro(self)
	elseif name == "药品" then
		self.loadDrugs(self)
	elseif name == "辅助" then
		self.loadJob(self)
	elseif name == "显示" then
		self.loadView(self)
	elseif name == "帮助" then
		self.loadHelp(self)
	elseif name == "聊天" then
		self.loadChat(self)
	elseif name == "快捷键" then
		self.loadHotKeyView(self)
	else
		an.newLabel("功能研发中...", 18, 1):add2(self.content):anchor(0.5, 0.5):pos((self.content:getw()*self.content:getScale())/2, (self.content:geth()*self.content:getScale())/2)
	end

	return 
end
setting.createSelectTab = function (self, params, content)
	params = params or {}
	params.size = params.size or size(60, 30)
	params.texts = params.texts or {
		""
	}
	params.res = params.res or ""
	params.curtext = params.curtext or "随机传送卷"
	params.fontSize = params.fontSize or 20
	params.strokeSize = params.strokeSize or 1
	params.color = params.color or def.colors.labelGray
	params.tabBackColor = params.tabBackColor or cc.c3b(120, 120, 120)

	if type(params.texts) == "string" then
		params.texts = string.split(params.texts, ",")
	end

	local function getIconTex(i)
		local iconImg = (type(params.res) == "table" and params.res[i]) or string.format(params.res, i)
		local scale = params.scale

		if type(iconImg) == "table" then
			scale = iconImg[2]
			iconImg = iconImg[1]
		end

		return iconImg, scale
	end

	local control, showLabel, showIcon = nil
	control = res.get2("pic/panels/setting/tab_frame.png"):enableClick(function (eventX, eventY)
		local pt = control:getParent():convertToNodeSpace(cc.p(eventX, eventY))

		if cc.rectContainsPoint(control:getBoundingBox(), pt) then
			control:setTouchSwallowEnabled(false)

			params.size = control:getContentSize()

			local function createTabCell(index, object)
				local cell = res.get2("pic/panels/setting/tab_frame.png")
				local img, scale = getIconTex(index)
				local icon = res.get2(img):anchor(0.5, 0.5):pos(32, 32):add2(cell, 2)

				icon.setScale(icon, scale or icon.getw(icon)/50)
				an.newLabel(object, params.fontSize, params.strokeSize, {
					color = params.color
				}):anchor(0.5, 0.5):pos(cell.getw(cell)*0.6, cell.geth(cell)*0.5):addTo(cell)

				return cell
			end

			if params.texts then
				local cellList = {}

				for i, v in ipairs(params.texts) do
					local cell = {
						cellCls = function ()
							return createTabCell(i, v)
						end,
						w = 190,
						h = 50,
						object = v,
						index = i
					}
					cellList[#cellList + 1] = cell
				end

				local h = 240

				if #params.texts < 5 then
					h = #params.texts*55 + 10
				end

				local menu = common.createOperationMenu(cellList, 5, function (popMenu, cell)
					local object = cell.object
					local index = cell.index

					showLabel:setString(object)

					local img, scale = getIconTex(index)

					showIcon:setTex(res.gettex2(img))
					showIcon:scale(scale or showIcon:getw()/45)
					popMenu.removeSelf(popMenu)

					if params.endFunc then
						params.endFunc(object)
					end

					return 
				end, {
					scroll = {
						w = 190,
						h = h
					}
				}):anchor(0, 1)

				if params.parent then
					menu.add2(menu, params.parent)

					local pos = cc.p(0, 0)
					pos = control:convertToWorldSpace(pos)
					pos = params.parent:convertToNodeSpace(pos)

					menu.pos(menu, pos.x, pos.y + 50)
				else
					local x, y = control:getPosition()

					menu.add2(menu, control:getParent(), 50):pos(x, y - 20)
				end
			end
		end

		return 
	end)
	showLabel = an.newLabel(params.curtext, params.fontSize, params.strokeSize, {
		color = params.color
	}):anchor(0.5, 0.5):pos(control.getw(control)*0.6, control.geth(control)*0.5):addTo(control)
	local img, scale = getIconTex(1)
	showIcon = res.get2(img):anchor(0.5, 0.5):pos(31, 34):add2(control, 2)

	showIcon.setScale(showIcon, scale or showIcon.getw(showIcon)/45)

	for i, v in ipairs(params.texts) do
		if v == params.curtext then
			local img, scale = getIconTex(i)

			showIcon.setTex(showIcon, res.gettex2(img))
			showIcon.setScale(showIcon, scale or showIcon.getw(showIcon)/45)
		end
	end

	return control
end
setting.loadHotKeyView = function (self)
	self.hotKeyView = hotKeySetting.new():addTo(self.content)

	return 
end

return setting
