local widgetDef = import("..console.widget._def")
local detail = import("..console.detail")
local iconFunc = import("..console.iconFunc")
local common = import("..common.common")
local magic = import("..common.magic")
local diyBtn = import("..common.diyBtn")
local diy = class("diy", function()
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
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		main_scene.ui:hidePanel("diySave")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 8, self:geth() - 8):addto(self):setName("diy_close")

	local hideBtn

	hideBtn = an.newBtn(res.gettex2("pic/panels/diy/hide.png"), function()
		if hideBtn.lock then
			return
		end

		hideBtn.lock = true

		self.content:hide()
		self:runs({
			cc.ScaleTo:create(0.2, 0.01),
			cc.CallFunc:create(function()
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

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
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
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		main_scene.ui:togglePanel("diySave")
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/diy/dq.png")
	}):anchor(1, 0.5):pos(self:getw() - 30, 42):add2(self, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		local msgbox

		msgbox = an.newMsgbox("请输入想要保存的文件名", function(idx)
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
		cc.CallFunc:create(function()
			self.content:show()
		end)
	})
end

function diy:customSkicon(magicIdOwner)
	if magicIdOwner.magicId then
		return def.magic.buildSkillIcon(magicIdOwner.magicId)
	end
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

	for i, v2 in ipairs(keys) do
		local c = widgetDef.getConfig({
			key = v2
		})

		if c then
			config.widget.icons[#config.widget.icons + 1] = c
		end
	end

	for i2, v3 in pairs(widgetDef.config) do
		if type(v3) == "table" and v3.class == "btnMove" and v3.btntype == "base" then
			config.base.icons[#config.base.icons + 1] = v3
		end
	end

	local keys2 = def.magic.getMagicIds(g_data.player.job)

	for i3, v4 in ipairs(keys2) do
		local magicConfigByUid = def.magic.getMagicConfigByUid(v4, main_scene.ground.player)

		if magicConfigByUid and magicConfigByUid.name then
			local dic = clone(widgetDef.getConfig({
				key = "btnSkillTemp"
			}))

			dic._data = {
				key2 = "btnSkillTemp",
				key = "skill" .. v4,
				magicId = v4
			}
			config.skill.icons[#config.skill.icons + 1] = dic
		end
	end

	if def.gameVersionType == "185" then
		for i4, v5 in pairs(widgetDef.config) do
			if type(v5) == "table" and v5.class == "btnMove" and v5.btntype == "hero" then
				config.hero.icons[#config.hero.icons + 1] = v5
			end
		end
	end

	for i5, v6 in pairs(widgetDef.config) do
		if type(v6) == "table" and v6.class == "btnMove" and v6.btntype == "prop" then
			config.prop.icons[#config.prop.icons + 1] = v6
		end
	end

	for i6, v7 in pairs(widgetDef.config) do
		if type(v7) == "table" and v7.class == "btnMove" and v7.btntype == "setting" and (not v7.job or v7.job == g_data.player.job) then
			config.setting.icons[#config.setting.icons + 1] = v7
		end
	end

	for i7, v8 in pairs(widgetDef.config) do
		if type(v8) == "table" and v8.class == "btnMove" and v8.btntype == "panel" then
			config.panel.icons[#config.panel.icons + 1] = v8
		end
	end

	local titleSpace = 40
	local iconSpace = 80
	local begin = 12
	local iconLineNum = math.modf((self.content:getw() - begin) / iconSpace)
	local h = (function()
		local h = 0

		for k, v in pairs(config) do
			print(k, #v.icons)

			h = h + titleSpace + math.ceil(#v.icons / iconLineNum) * iconSpace
		end

		return h
	end)()

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
		local filter

		if config.class == "btnMove" and config.btntype == "skill" and not g_data.player:getMagic(tonumber(data.magicId)) then
			filter = res.getFilter("gray")
		end

		if self.customSkicon then
			local sprite = self:customSkicon(data)

			if sprite then
				files.sprite = sprite
			end
		end

		local tmpIcon
		local x = begin + wNumCount * iconSpace + iconSpace / 2
		local y = h - hCount - iconSpace / 2

		res.get2("pic/console/iconUnder.png"):pos(x, y):add2(scroll)

		local btn

		btn = an.newBtn(res.gettex2(files.bg), function()
			main_scene.ui.console:showRect(nil, data.key)

			local p = btn:convertToWorldSpace(cc.p(btn:centerPos()))

			detail.new(config, data, p.x, p.y, btn:getw(), btn:geth(), "diy")
		end, {
			pressBig = true,
			support = "drag",
			sprite = files.sprite and res.gettex2(files.sprite),
			filter = filter,
			filterOpen = filter ~= nil,
			call_drag_moving = function(btn, event)
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

				if def.openArangeSkills and config.btntype == "skill" then
					local boundingBox = self:getBoundingBox()

					main_scene.ui.console:skillBtnShow(math.ceil(boundingBox.x + tmpIcon:getPositionX()), math.ceil(boundingBox.y + tmpIcon:getPositionY()))
					self:skilldiyShow(math.ceil(boundingBox.x + tmpIcon:getPositionX()), math.ceil(boundingBox.y + tmpIcon:getPositionY()))
				end
			end,
			call_drag_end = function(btn, event)
				local rect = cc.rect(0, 0, self:getw(), self:geth())

				if not cc.rectContainsPoint(rect, cc.p(tmpIcon:getPosition())) then
					if filter == nil then
						if def.openArangeSkills then
							local rect2 = self:getBoundingBox()

							data.x = rect2.x + tmpIcon:getPositionX()
							data.y = rect2.y + tmpIcon:getPositionY()

							local value
							local enabled = false

							if config.btntype == "skill" then
								local value2 = self:skillShowpos(data.x, data.y)

								if value2 then
									if value2 and main_scene.ui.console:addWidgetByPanel(data, "diy", value2) == "exist" then
										an.newMsgbox("控件已存在!", nil, {
											center = true
										})
									end
								elseif self:AttackShowpos(data.x, data.y) then
									g_data.setting.autoRat.defaultAtkMagic.magicId = data.magicId

									main_scene.ui.console:call("attackBtns", "chgAttackType")
									an.newMsgbox("攻击技能设置成功!", nil, {
										center = true
									})
								else
									an.newMsgbox("请把技能拖到指定阴影位置!", nil, {
										center = true
									})
								end
							elseif config.btntype ~= "skill" and main_scene.ui.console:addWidgetByPanel(data, "diy") == "exist" then
								an.newMsgbox("控件已存在!", nil, {
									center = true
								})
							end
						else
							local boundingBox = self:getBoundingBox()

							data.x = boundingBox.x + tmpIcon:getPositionX()
							data.y = boundingBox.y + tmpIcon:getPositionY()

							if main_scene.ui.console:addWidgetByPanel(data, "diy") == "exist" then
								an.newMsgbox("控件已存在!", nil, {
									center = true
								})
							end
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

				if def.openArangeSkills and main_scene.ui.console.skillBtnShow then
					main_scene.ui.console:skillBtnShow(0, 0)
				end

				tmpIcon:removeSelf()

				if def.openArangeSkills then
					self:skilldiyShow(0, 0)
				end

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

	local orders

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

	for i8, v9 in ipairs(orders) do
		addTitle(v9.title)

		for i22, v22 in ipairs(v9.icons) do
			addIcon(v22, i22 < #v9.icons)
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
	if cache.getDiy(common.getPlayerName(), key) then
		main_scene.ui.leftTopTip:show("不能与现有配置表重名..")

		return
	end

	local listDatas = cache.getDiy(common.getPlayerName(), "_list") or {}

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

function diy:Attackrectpos(point)
	return cc.rect(point.x - 26, point.y - 26, 75, 75)
end

function diy:AttackShowpos(value, value2)
	local json = main_scene.ui.console:getjson()

	if json then
		for _, curAtkpo in ipairs(json.curAtkpos) do
			if cc.rectContainsPoint(self:Attackrectpos(curAtkpo), cc.p(math.ceil(display.width - value), value2)) then
				return true
			end
		end
	end
end

function diy:skillrectpos(skillData)
	return cc.rect(skillData.x - 26, skillData.y - 26, 52, 52)
end

function diy:skillShowpos(skillData, level)
	local json = main_scene.ui.console:getjson()

	if json then
		for _, skillbg in ipairs(json.skillbg) do
			if cc.rectContainsPoint(self:skillrectpos(skillbg), cc.p(math.ceil(display.width - skillData), level)) then
				return skillbg
			end
		end
	end
end

function diy:skillrectpos1(skillData)
	return cc.rect(skillData.x - 26, skillData.y - 26, 52, 52)
end

function diy:skillShowpos1(skillData, level)
	local json = main_scene.ui.console:getjson()

	if json then
		for _, skillbg in ipairs(json.skillbg) do
			if cc.rectContainsPoint(self:skillrectpos1(skillbg), cc.p(math.ceil(display.width - skillData), level)) then
				return skillbg.x, skillbg.y
			end
		end
	end
end

function diy:skilldiyShow(skillData, level)
	local value, y = self:skillShowpos1(skillData, level)

	if self.skilldiyBg then
		self.skilldiyBg:removeSelf()

		self.skilldiyBg = nil
	end

	if value and y then
		self.skilldiyBg = display.newScale9Sprite(res.getframe2("pic/console/newskill/skillcore.png")):anchor(2.2, 4.3):add2(self, 999)

		self.skilldiyBg:size(52, 52):pos(display.width - value, y)
	end
end

return diy
