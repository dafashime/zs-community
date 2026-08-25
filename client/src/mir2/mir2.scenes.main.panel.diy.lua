local widgetDef = import("..console.widget._def")
local detail = import("..console.detail")
local iconFunc = import("..console.iconFunc")
local common = import("..common.common")
local magic = import("..common.magic")
local diyBtn = import("..common.diyBtn")
local diy = class("diy", function ()
	return display.newNode()
end)

table.merge(diy, {
	content,
	icons
})

function diy:onCleanup()
	main_scene.ui.console:showEditBg(false)
	main_scene.ui.console:hideAllRect()
	main_scene.ui.console:endEdit()
end

function diy:ready()
	for k, v in pairs(main_scene.ui.panels) do
		if k ~= "diy" and k ~= "heroHead" and k ~= "minimap" then
			main_scene.ui:hidePanel(k)
		end
	end

	main_scene.ui.console:showEditBg(true)
	main_scene.ui.console:startEdit()
end

function diy:ctor(name)
	self._supportMove = true

	self:setNodeEventEnabled(true)

	local bg = res.get2("pic/panels/diy/bg.png"):anchor(0, 0):add2(self)

	self:size(bg:getw(), bg:geth()):anchor(0, 1):pos(90, display.height - 30)
	display.newSprite(res.gettex2("pic/panels/diy/title.png")):add2(self):anchor(0.5, 0.5):pos(self:getw() / 2, self:geth() - 24)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		main_scene.ui:hidePanel("diySave")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 8, self:geth() - 8):addto(self):setName("diy_close")

	local hideBtn = nil
	hideBtn = an.newBtn(res.gettex2("pic/panels/diy/hide.png"), function ()
		if hideBtn.lock then
			return
		end

		hideBtn.lock = true

		self.content:hide()
		self:runs({
			cc.ScaleTo:create(0.2, 0.01),
			cc.CallFunc:create(function ()
				hideBtn.lock = false

				diyBtn.new()
				self:hide()
			end)
		})
	end, {
		pressImage = res.gettex2("pic/panels/diy/hide.png"),
		spriteOffset = {
			x = -13,
			y = 17
		}
	}):anchor(0.5, 0.5):pos(20, self:geth() - 25):add2(self, 1)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		local text = "所有主界面的控件/均可编辑/, /拖动/面板上的/图标/可拖至主界面, /红色区域/代表按钮会/自动对齐/, /其他区域/均可/任意摆放/, /单击/主界面控件可以/编辑详情/, /拖动/可以/摆放位置/, 熟练使用该系统将有助于让你在玛法大陆/叱诧风云/！"
		local array = string.split(text, "/")
		local texts = {}

		for i, v in ipairs(array) do
			if i % 2 == 1 then
				texts[#texts + 1] = {
					v
				}
			else
				texts[#texts + 1] = {
					v,
					cc.c3b(255, 255, 0)
				}
			end
		end

		an.newMsgbox(texts, nil, {
			fontSize = 16
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/diy/bz.png")
	}):anchor(0, 0.5):pos(26, 42):add2(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		main_scene.ui:togglePanel("diySave")
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/diy/dq.png")
	}):anchor(1, 0.5):pos(self:getw() - 30, 42):add2(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		local msgbox = nil
		msgbox = an.newMsgbox("请输入想要保存的文件名", function (idx)
			if idx == 2 then
				local fileName = msgbox.input:getString()

				if string.len(fileName) > 16 or string.len(fileName) < 1 then
					main_scene.ui.leftTopTip:show("请输入1-16位名字..")
				else
					self:saveArchive(msgbox.input:getString())
				end
			end
		end, {
			disableScroll = true,
			input = 20,
			btnTexts = {
				"关闭",
				"保存"
			}
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/diy/cd.png")
	}):anchor(1, 0.5):pos(self:getw() - 160, 42):add2(self, 1)
	an.newLabel("按钮可点击或拖至主界面", 18, 1, {
		color = def.colors.labelGray
	}):anchor(0.5, 0.5):pos(self:getw() * 0.39, 42):add2(self, 1)
	self:ready()
	self:loadContent()
end

function diy:setShow(x, y)
	self:runs({
		cc.Place:create(cc.p(x, y)),
		cc.Show:create(),
		cc.ScaleTo:create(0.2, 1),
		cc.CallFunc:create(function ()
			self.content:show()
		end)
	})
end

function diy:loadContent()
	self.icons = {}

	if self.content then
		self.content:removeSelf()
	end

	self.content = res.get2("pic/panels/diy/bg2.png"):anchor(0.5, 0):pos(self:getw() * 0.5, 78):add2(self)
	local scroll = an.newScroll(4, 4, self.content:getw() - 8, self.content:geth() - 8):addTo(self.content)

	scroll:setName("diyPanel_ScrollView")

	local config = {
		widget = {
			title = "基本控件",
			icons = {}
		},
		base = {
			title = "天生技能",
			icons = {}
		},
		skill = {
			title = "职业技能",
			icons = {}
		},
		hero = {
			title = "英雄",
			icons = {}
		},
		prop = {
			title = "道具-快捷键",
			icons = {}
		},
		setting = {
			title = "设置-快捷键",
			icons = {}
		},
		panel = {
			title = "面板-快捷键",
			icons = {}
		}
	}

	if def.gameVersionType ~= "185" then
		local cfg = {}

		for k, v in pairs(config) do
			if k ~= "hero" then
				cfg[k] = v
			end
		end

		config = cfg
	end

	local keys = {
		"rocker",
		"chat",
		"btnChat",
		"btnVoice",
		"btnAutoRat",
		"btnVoiceJIT",
		"btnPet",
		"btnHide",
		"btnHelper",
		"btnGroup"
	}

	for i, v in ipairs(keys) do
		local c = widgetDef.getConfig({
			key = v
		})

		if c then
			config.widget.icons[#config.widget.icons + 1] = c
		end
	end

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "base" then
			config.base.icons[#config.base.icons + 1] = v
		end
	end

	local keys = def.magic.getMagicIds(g_data.player.job)

	for i, v in ipairs(keys) do
		local data = def.magic.getMagicConfigByUid(v)

		if data then
			local dic = clone(widgetDef.getConfig({
				key = "btnSkillTemp"
			}))
			dic._data = {
				key2 = "btnSkillTemp",
				key = "skill" .. v,
				magicId = v
			}
			config.skill.icons[#config.skill.icons + 1] = dic
		end
	end

	if def.gameVersionType == "185" then
		for i, v in pairs(widgetDef.config) do
			if type(v) == "table" and v.class == "btnMove" and v.btntype == "hero" then
				config.hero.icons[#config.hero.icons + 1] = v
			end
		end
	end

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "prop" then
			config.prop.icons[#config.prop.icons + 1] = v
		end
	end

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "setting" and (not v.job or v.job == g_data.player.job) then
			config.setting.icons[#config.setting.icons + 1] = v
		end
	end

	for i, v in pairs(widgetDef.config) do
		if type(v) == "table" and v.class == "btnMove" and v.btntype == "panel" then
			config.panel.icons[#config.panel.icons + 1] = v
		end
	end

	local titleSpace = 40
	local iconSpace = 80
	local begin = 12
	local iconLineNum = math.modf((self.content:getw() - begin) / iconSpace)

	local function getH()
		local h = 0

		for k, v in pairs(config) do
			print(k, #v.icons)

			h = h + titleSpace + math.ceil(#v.icons / iconLineNum) * iconSpace
		end

		return h
	end

	local h = getH()

	scroll:setScrollSize(scroll:getw(), h)

	local wNumCount = 0
	local hCount = 0

	local function addTitle(text)
		an.newLabel(text, 18, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0, 0.5):pos(begin + 10, h - hCount - titleSpace / 2):add2(scroll)

		hCount = hCount + titleSpace
	end

	local function addIcon(config, hasNext)
		local data = {
			key = config.key
		}

		if config._data then
			table.merge(data, config._data)
		end

		local files = iconFunc:getFilenames(config, data)
		local filter = nil

		if config.class == "btnMove" and config.btntype == "skill" and not g_data.player:getMagic(tonumber(data.magicId)) then
			filter = res.getFilter("gray")
		end

		local tmpIcon = nil
		local x = begin + wNumCount * iconSpace + iconSpace / 2
		local y = h - hCount - iconSpace / 2

		res.get2("pic/console/iconUnder.png"):pos(x, y):add2(scroll)

		local btn = nil
		btn = an.newBtn(res.gettex2(files.bg), function ()
			main_scene.ui.console:showRect(nil, data.key)

			local p = btn:convertToWorldSpace(cc.p(btn:centerPos()))

			detail.new(config, data, p.x, p.y, btn:getw(), btn:geth(), "diy")
		end, {
			pressBig = true,
			support = "drag",
			sprite = files.sprite and res.gettex2(files.sprite),
			filter = filter,
			filterOpen = filter ~= nil,
			call_drag_moving = function (btn, event)
				if not tmpIcon then
					btn:hide()

					tmpIcon = res.get2(files.bg):scale(1.5):add2(self)

					res.get2(files.sprite):add2(tmpIcon):pos(tmpIcon:centerPos())

					if files.text then
						res.get2(files.text):add2(tmpIcon):pos(tmpIcon:getw() / 2, 10)
					end

					tmpIcon:setName("diy_tmpIcon")
				end

				local p = btn:convertToWorldSpace(cc.p(btn:centerPos()))
				local rect = self:getBoundingBox()

				tmpIcon:pos(p.x - rect.x, p.y - rect.y)

				if config.class == "btnMove" then
					main_scene.ui.console:checkBtnAreaShow(cc.p(tmpIcon:getPositionX() + rect.x, tmpIcon:getPositionY() + rect.y))
				end
			end,
			call_drag_end = function (btn, event)
				local rect = cc.rect(0, 0, self:getw(), self:geth())

				if not cc.rectContainsPoint(rect, cc.p(tmpIcon:getPosition())) then
					if filter == nil then
						local rect = self:getBoundingBox()
						data.x = rect.x + tmpIcon:getPositionX()
						data.y = rect.y + tmpIcon:getPositionY()

						if main_scene.ui.console:addWidgetByPanel(data, "diy") == "exist" then
							an.newMsgbox("控件已存在!", nil, {
								center = true
							})
						end
					else
						an.newMsgbox("控件未激活!", nil, {
							center = true
						})
					end

					btn:show():pos(x, y):scale(0.01):scaleTo(0.1, 1)
				else
					btn:show():moveTo(0.1, x, y)
				end

				main_scene.ui.console:checkBtnAreaShow(nil, true)
				tmpIcon:removeSelf()

				tmpIcon = nil
			end
		}):pos(x, y):add2(scroll)

		if config.key == "btnSkillTemp" then
			btn:setName("diyPanel_" .. config._data.key)
		else
			btn:setName("diyPanel_" .. config.key)
		end

		if files.text then
			res.get2(files.text):pos(btn:getw() / 2, 10):add2(btn)
		end

		wNumCount = wNumCount + 1

		if iconLineNum <= wNumCount and hasNext then
			wNumCount = 0
			hCount = hCount + iconSpace
		end

		self.icons[data.key] = btn

		self:checkSelect(data.key)
	end

	local orders = nil

	if def.gameVersionType ~= "185" then
		orders = {
			config.widget,
			config.base,
			config.skill,
			config.prop,
			config.setting,
			config.panel
		}
	else
		orders = {
			config.widget,
			config.base,
			config.skill,
			config.hero,
			config.prop,
			config.setting,
			config.panel
		}
	end

	for i, v in ipairs(orders) do
		addTitle(v.title)

		for i2, v2 in ipairs(v.icons) do
			addIcon(v2, i2 < #v.icons)
		end

		hCount = hCount + iconSpace
		wNumCount = 0
	end
end

function diy:checkSelect(key, console)
	local btn = self.icons[key]

	if not btn then
		return
	end

	if not btn.selectMark then
		btn.selectMark = res.get2("pic/common/selectMark.png"):anchor(1, 1):pos(btn:getw() - 20, btn:geth() + 20):add2(btn)
	end

	console = console or main_scene.ui.console

	btn.selectMark:setVisible(console:get(key) ~= nil)
end

function diy:saveArchive(key)
	local listDatas = cache.getDiy(common.getPlayerName(), key)

	if listDatas then
		main_scene.ui.leftTopTip:show("不能与现有配置表重名..")

		return
	end

	listDatas = cache.getDiy(common.getPlayerName(), "_list")
	listDatas = listDatas or {}

	if #listDatas >= 7 then
		main_scene.ui.leftTopTip:show("最多只能保存七个配置表..")

		return
	end

	local timeValue = os.date("%Y-%m-%d")
	listDatas[#listDatas + 1] = {
		key,
		timeValue
	}

	cache.removeDiy(common.getPlayerName(), "_list")
	cache.saveDiy(common.getPlayerName(), "_list", listDatas)
	cache.removeDiy(common.getPlayerName(), key)
	main_scene.ui.console:saveEdit(key)
	main_scene.ui.leftTopTip:show("配置保存成功..")
end

return diy
