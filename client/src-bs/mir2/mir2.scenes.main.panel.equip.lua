local item = import("..common.item")
local magic = import("..common.magic")
local titleTips = import("..common.titleInfo")
local widgetDef = import("..console.widget._def")
local detail = import("..console.detail")
local iconFunc = import("..console.iconFunc")
local security = import("..panel.security")
local common = import("..common.common")
local equip = class("equip", function ()
	return display.newNode()
end)

table.merge(equip, {
	isRole = 0,
	disY = 0
})

equip.resetPanelPosition = function (self, type)
	if type == "right" then
		self.anchor(self, 1, 1):pos(display.width - 60, display.height - 60)
	elseif type == "right2" then
		self.anchor(self, 1, 1):pos(display.width - 40, display.height - 60)
	end

	return self
end
equip.ctor = function (self, params)
	if self.isHero then
		self.baseData = g_data.hero
		self.equipData = g_data.heroEquip
	else
		self.baseData = g_data.player
		self.equipData = g_data.equip
	end

	params = params or {}
	local bg = res.get2("pic/panels/equip/bg.png"):anchor(0, 0):addto(self)
	self.bg = bg

	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):resetPanelPosition((self.isHero and params.from == "equip" and "right2") or "right")

	self._scale = 1
	self._supportMove = true
	local closeHeight = (self.isHero and self.geth(self) - 50) or self.geth(self) - 40

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self), self.geth(self) - 48):addto(self, 1)

	local btnFiles = ""

	if self.isHero then
		btnFiles = "bag"

		an.newLabel(self.baseData.name, 22, 1):anchor(0.5, 0.5):pos(self.getw(self)/2, self.geth(self) - 34):addto(self)
	else
		btnFiles = "hero"

		if main_scene.ground.map and main_scene.ground.map.player then
			local name = main_scene.ground.map.player.info.name

			an.newLabel(name.texts[1], 22, 1, {
				color = def.colors.get(name.color)
			}):anchor(0.5, 0.5):pos(self.getw(self)/2, self.geth(self) - 34):addto(self)
		end
	end

	self.guildLabel = an.newLabel("", 22, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self)*0.5, 395)
	self.clanLabel = an.newLabel("", 20, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self)*0.5, 360)
	local texts = {
		"equip",
		"state",
		"attributes",
		"skill"
	}
	local titleInfo = {
		"装\n备",
		"状\n态",
		"属\n性",
		"技\n能"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v.select(v)
				v.setLocalZOrder(v, 5)
				v.label:setColor(cc.c3b(249, 237, 215))
			else
				v.setLocalZOrder(v, i - 5)
				v.unselect(v)
				v.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if btn.page ~= self.page then
			self:showContent(btn.page)
		end

		return 
	end

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn140.png"), function ()
			return 
		end, {
			label = {
				titleInfo[i],
				24,
				1,
				cc.c3b(166, 161, 151)
			},
			labelOffset = {
				x = 2,
				y = 12
			},
			select = {
				res.gettex2("pic/common/btn141.png"),
				manual = true
			}
		}):add2(self, i - 5):anchor(1, 1):pos(7, (i - 1)*86 - 412)

		tabs[i]:setTouchEnabled(false)
		display.newNode():size(tabs[i]:getw(), tabs[i]:geth() - 30):pos(0, 30):add2(tabs[i]):enableClick(function ()
			click(tabs[i])

			return 
		end)

		tabs[i].page = v

		if (params.page or texts[1]) == v then
			tabs[i]:select()
			tabs[i]:setLocalZOrder(5)
			tabs[i].label:setColor(cc.c3b(249, 237, 215))
			self.showContent(self, v)
		end
	end

	return 
end
equip.showContent = function (self, page)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addto(self)
	page = page or "equip"
	self.page = page

	self.guildLabel:setString("")
	self.clanLabel:setString("")

	if page == "equip" then
		self.content:setScale(1.2)

		local sex = (self.isHero and g_data.hero.sex) or g_data.player.sex
		self.disY = 0

		if def.gameVersionType == "176" then
			self.disY = -26
			local bghead = (sex == 0 and "pic/panels/equip/equip176_0.png") or "pic/panels/equip/equip176_1.png"

			self.bg:setTex(res.gettex2(bghead))
		else
			bgend = (self.isHero and ".png") or ".png"
			local bghead = (sex == 0 and "pic/panels/equip/sex0") or "pic/panels/equip/sex1"

			self.bg:setTex(res.gettex2(bghead .. bgend))
		end

		if not self.isHero or false then
			local info = ""

			if g_data.guild.guildInfo or g_data.guild.clanInfo then
				if g_data.guild.guildInfo then
					info = g_data.guild.guildInfo:get("gildName")

					self.guildLabel:setString(info)
				end

				if g_data.guild.clanInfo then
					info = g_data.guild.clanInfo:get("corpsName")

					self.clanLabel:setString(info)
				end
			end
		end

		local hair = nil

		if self.isHero then
			if main_scene.ground.player and main_scene.ground.player.hero then
				hair = main_scene.ground.player.hero.hair
			end
		elseif main_scene.ground.player then
			hair = main_scene.ground.player.hair
		end

		if hair and 0 < hair then
			hair = hair + 438

			res.getui(1, hair):addto(self.content):anchor(0.5, 1):pos(139, 240)
		end

		self.items = {}

		for k, v in pairs(self.equipData.items) do
			local tmpDisY = 0

			if k == 2 or k == 3 or (5 <= k and k <= 8) then
				tmpDisY = self.disY
			end

			local x, y, z, isSetOffset, attach = self.idx2pos(self, k)
			self.items[k] = item.new(v, self, {
				img = "stateitem",
				isSetOffset = isSetOffset,
				idx = k
			}):addto(self.content, z):pos(x, y + tmpDisY)

			if attach then
				self.items[k .. "_attach"] = item.new(v, self, {
					idx = k
				}):addto(self.content, attach[3]):pos(attach[1], attach[2])
			end
		end

		if self.items[13] and self.items[4] and self.isHero then
			self.items[4]:hide()
		end

		if not self.isHero and (g_data.security.equipBit or 0 < g_data.equip.lockState) then
			self.btnSecurity = an.newBtn(res.gettex2("pic/panels/equip/security0.png"), function ()
				sound.playSound("103")

				if g_data.equip.lockState == 0 then
					return 
				end

				local nowTime = socket.gettime()

				if g_data.client.lastTime.clickUnlockTime and nowTime - g_data.client.lastTime.clickUnlockTime < 3 then
					return 
				end

				local spaceTime = nowTime - g_data.client.lastTime.equipUnlockTime
				local remainTime = math.floor(g_data.equip.serverUnlockTime - spaceTime)

				if 0 < remainTime then
					common.addMsg("请等待" .. remainTime .. "秒之后再解锁装备", display.COLOR_WHITE, display.COLOR_RED)
				else
					net.send({
						CM_LOCK_UNLOCK_EQUIP
					})
					g_data.client:setLastTime("clickUnlockTime", true)
				end

				return 
			end, {
				support = "easy",
				pressImage = res.gettex2("pic/panels/equip/security1.png"),
				select = {
					res.gettex2("pic/panels/equip/security2.png"),
					manual = true
				}
			}):pos(290, 347):add2(self.content):scale(0.9)
		end
	else
		if page == "state" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local cnt = 0
			local begin = 372

			local function add(text1, text2)
				an.newLabel(text1, 20, 0, {
					color = cc.c3b(191, 173, 126)
				}):anchor(0, 0.5):addto(self.content):pos(26, begin - cnt*48)
				res.get2("pic/panels/equip/attback.png"):anchor(0, 0.5):pos(90, begin - cnt*48):add2(self.content)
				an.newLabel(text2, 20, 0, {
					color = cc.c3b(188, 188, 188)
				}):anchor(0, 0.5):addto(self.content):pos(98, begin - cnt*48)

				cnt = cnt + 1

				return 
			end

			local ability = self.baseData.ability
			local ability3 = self.baseData.ability3
			local value = {
				{
					"物防",
					ability.get(ability, "AC") .. "-" .. ability.get(ability, "maxAC")
				},
				{
					"魔防",
					ability.get(ability, "MAC") .. "-" .. ability.get(ability, "maxMAC")
				},
				{
					"攻击",
					ability.get(ability, "DC") .. "-" .. ability.get(ability, "maxDC")
				},
				{
					"魔法",
					ability.get(ability, "MC") .. "-" .. ability.get(ability, "maxMC")
				},
				{
					"道术",
					ability.get(ability, "SC") .. "-" .. ability.get(ability, "maxSC")
				},
				{
					"生命值",
					ability.get(ability, "HP") .. "/" .. ability.get(ability, "maxHP")
				},
				{
					"魔法值",
					ability.get(ability, "MP") .. "/" .. ability.get(ability, "maxMP")
				}
			}

			for i, v in ipairs(value) do
				add(v[1], v[2])
			end

			return 
		end

		if page == "attributes" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local infoView = an.newScroll(28, 34, 278, 368):add2(self.content)
			local h = 30
			local data = {}

			local function add(text1, text2)
				data[#data + 1] = {
					text1,
					text2
				}

				return 
			end

			local ability = self.baseData.ability
			local ability3 = self.baseData.ability3

			add("职业", self.baseData:getJobStr())
			add("等级", ability.get(ability, "level"))
			add("幸运值", ability3.get(ability3, "attackLuck"))

			if not self.isHero then
				add("声望", ability3.get(ability3, "prestige"))
				add("元宝", self.baseData:getIngot())
				add("灵符", self.baseData:getGird())
			end

			add("当前经验", ability.get(ability, "Exp"))
			add("升级经验", ability.get(ability, "maxExp"))

			slot8 = self.isHero or slot8

			add("背包负重", ability.get(ability, "weight") .. "/" .. ability.get(ability, "maxWeight"))
			add("穿戴负重", ability.get(ability, "wearWeight") .. "/" .. ability.get(ability, "maxWearWeight"))
			add("腕力", ability.get(ability, "handWeight") .. "/" .. ability.get(ability, "maxHandWeight"))
			add("准确", ability.get(ability, "hitRate"))
			add("敏捷", ability.get(ability, "quickRate"))
			add("魔法躲避", "+" .. ability.get(ability, "antiMagic")*10 .. "%")
			add("毒物躲避", "+" .. ability.get(ability, "poisAC") .. "%")
			add("中毒恢复", "+" .. ability.get(ability, "buPoisResume")*10 .. "%")
			add("体力恢复", "+" .. ability.get(ability, "hpResume") .. "%")
			add("魔法恢复", "+" .. ability.get(ability, "mpResume") .. "%")

			slot8 = self.isHero or slot8

			infoView.setScrollSize(infoView, 278, math.max(368, #data*h))

			for i, v in ipairs(data) do
				an.newLabel(v[1], 20, 0, {
					color = cc.c3b(217, 207, 183)
				}):addto(infoView):pos(16, infoView.getScrollSize(infoView).height - i*h)
				an.newLabel(v[2], 20, 0, {
					color = cc.c3b(217, 207, 183)
				}):addto(infoView):pos(133, infoView.getScrollSize(infoView).height - i*h)
			end

			local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.content):anchor(0, 0)
			local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)

			infoView.setListenner(infoView, function (event)
				if event.name == "moved" then
					local x, y = infoView:getScrollOffset()
					local maxOffset = infoView:getScrollSize().height - infoView:geth()

					if y < 0 then
						y = 0
					end

					if maxOffset < y then
						y = maxOffset or y
					end

					rollCeil:setPositionY((rollbg:geth() - 42)*(y/maxOffset - 1))
				end

				return 
			end)
		elseif page == "skill" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local rect = cc.rect(0, 0, 310, 368)
			local keys = def.magic.getMagicIds(self.baseData.job, self.isHero)

			if self.isHero and g_data.hero.roleid ~= 0 then
				local tmpSkill = {
					"50",
					"55",
					"53",
					"52",
					"51",
					"54"
				}

				if g_data.player.job == g_data.hero.job then
					keys[#keys + 1] = tmpSkill[g_data.player.job + 1]
				else
					keys[#keys + 1] = tmpSkill[g_data.player.job + g_data.hero.job + 3]
				end
			end

			local allMagicId = {}

			for i, v in ipairs(keys) do
				if self.baseData:getMagic(tonumber(v)) then
					allMagicId[#allMagicId + 1] = v
				end
			end

			for i, v in ipairs(keys) do
				if not self.baseData:getMagic(tonumber(v)) then
					allMagicId[#allMagicId + 1] = v
				end
			end

			local h = 90
			local scroll = an.newScroll(12, 34, rect.width, rect.height):addto(self.content)

			scroll.setScrollSize(scroll, rect.width, math.max(rect.height, #allMagicId*h))

			local rollbg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.content):anchor(0, 0)
			local rollCeil = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(rollbg.getw(rollbg)*0.5, rollbg.geth(rollbg) - 42):add2(rollbg)
			local selectImage = nil
			self.magics = {}

			for i, v in ipairs(allMagicId) do
				local node = res.get2("pic/panels/equip/skillback0.png"):anchor(0, 0):add2(scroll):pos(14, scroll.getScrollSize(scroll).height - i*h)
				node.cellindex = i

				node.setTouchEnabled(node, true)
				node.setTouchSwallowEnabled(node, false)
				node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						node.offsetBeginX = event.x
						node.offsetBeginY = event.y

						return true
					elseif event.name == "ended" then
						local offsetX = event.x - node.offsetBeginX
						local offsetY = event.y - node.offsetBeginY

						if math.abs(offsetX) < 5 and math.abs(offsetY) < 5 then
							if selectImage then
								selectImage:setTex("pic/panels/equip/skillback0.png")
							end

							selectImage = node

							selectImage:setTex("pic/panels/equip/skillback1.png")
						end
					end

					return 
				end)
				self.updateMagic(self, v, node)

				self.magics[v] = node
			end

			scroll.setListenner(scroll, function (event)
				if event.name == "moved" then
					local x, y = scroll:getScrollOffset()
					local maxOffset = scroll:getScrollSize().height - scroll:geth()

					if y < 0 then
						y = 0
					end

					if maxOffset < y then
						y = maxOffset or y
					end

					rollCeil:setPositionY((rollbg:geth() - 42)*(y/maxOffset - 1))
				end

				return 
			end)
		end
	end
end
equip.initPosTable = function (self)
	self.itemPosTable = self.itemPosTable or {
		[0] = {
			44,
			240,
			0,
			true,
			130,
			90,
			60,
			120
		},
		{
			42,
			240,
			1,
			true,
			80,
			90,
			45,
			200
		},
		{
			226,
			218,
			2
		},
		{
			226,
			280,
			2
		},
		{
			44,
			242,
			2,
			true,
			130,
			215,
			60,
			40
		},
		{
			50,
			162,
			2
		},
		{
			226,
			162,
			2
		},
		{
			50,
			104,
			2
		},
		{
			226,
			104,
			2
		},
		{
			50,
			44,
			2
		},
		{
			107,
			44,
			2
		},
		{
			165,
			44,
			2
		},
		{
			226,
			44,
			2
		},
		{
			44,
			242,
			2,
			true,
			74,
			140,
			60,
			40
		}
	}

	return 
end
equip.idx2pos = function (self, idx)
	self.initPosTable(self)

	local pos = self.itemPosTable[tonumber(idx)] or {
		0,
		0,
		0,
		0
	}

	return pos[1], pos[2], pos[3], pos[4], pos.attach
end
equip.pos2idx = function (self, x, y)
	self.initPosTable(self)

	for k, v in pairs(self.itemPosTable) do
		local rect = cc.rect(v[1] - item.w/2, v[2] - item.h/2, item.w, item.h)

		if v[4] then
			rect = cc.rect(v[5], v[6], v[7], v[8])
		end

		if cc.rectContainsPoint(rect, cc.p(x, y)) then
			return k
		end

		if v.attach then
			local rect = cc.rect(v.attach[1] - item.w/2, v.attach[2] - item.h/2, item.w, item.h)

			if cc.rectContainsPoint(rect, cc.p(x, y)) then
				return k
			end
		end
	end

	return "-1"
end
equip.setItem = function (self, makeIndex)
	if self.page == "equip" then
		local k, v = self.equipData:getItem(makeIndex)

		if v then
			if self.items[k] then
				self.items[k]:removeSelf()
			end

			if self.items[k .. "_attach"] then
				self.items[k .. "_attach"]:removeSelf()
			end

			local tmpDisY = 0

			if k == 2 or k == 3 or (5 <= k and k <= 8) then
				tmpDisY = self.disY
			end

			local x, y, z, isSetOffset, attach = self.idx2pos(self, k)
			self.items[k] = item.new(v, self, {
				img = "stateitem",
				isSetOffset = isSetOffset,
				idx = k
			}):addto(self.content, z):pos(x, y + tmpDisY)

			if attach then
				self.items[k .. "_attach"] = item.new(v, self, {
					idx = k
				}):addto(self.content, attach[3]):pos(attach[1], attach[2])
			end

			if k == 13 and self.items[4] and self.isHero then
				self.items[4]:hide()
			end

			if k == 4 and self.items[13] and self.isHero then
				self.items[4]:hide()
			end
		end
	end

	return 
end
equip.delItem = function (self, makeIndex)
	if self.page == "equip" then
		for k, v in pairs(self.items) do
			if v.data:get("makeIndex") == tonumber(makeIndex) then
				self.items[k]:removeSelf()

				self.items[k] = nil

				if k == 13 and self.items[4] and self.isHero then
					self.items[4]:show()
				end
			end
		end
	end

	return 
end
equip.uptItem = function (self, makeIndex)
	local i, v = self.equipData:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i].data = v
		end

		if self.items[i .. "_attach"] then
			self.items[i .. "_attach"].data = v
		end

		if i == 13 and self.items[4] and self.isHero then
			self.items[4]:hide()
		end

		if i == 4 and self.items[13] and self.isHero then
			self.items[4]:hide()
		end
	end

	return 
end
equip.updateMagic = function (self, magicId, node)
	if self.page == "skill" then
		magicId = tostring(magicId)
		node = node or self.magics[magicId]

		if not node then
			return 
		end

		node.removeAllChildren(node)

		local magicConfig = def.magic.getMagicConfigByUid(magicId)
		local data, config = nil

		if magicConfig then
			config = clone(widgetDef.getConfig({
				key = "btnSkillTemp"
			}))
			data = {
				key2 = "btnSkillTemp",
				key = "skill" .. magicId,
				magicId = magicId
			}
		else
			return 
		end

		local magicData = self.baseData:getMagic(tonumber(magicId))
		local files = iconFunc:getFilenames(config, data)
		local filter = nil

		if not magicData then
			filter = res.getFilter("gray")
		end

		local btn = nil
		slot11 = res.gettex2(files.bg)
		btn = an.newBtn(slot11, function ()
			if magicData then
				table.merge(config, {
					SkillLv = magicData:get("level")
				})
			end

			local p = btn:convertToWorldSpace(cc.p(btn:centerPos()))

			detail.new(config, data, p.x, p.y, btn:getw(), btn:geth(), (self.isHero and "skillHero") or "skill")

			return 
		end, {
			pressBig = true,
			sprite = files.sprite and res.gettex2(files.sprite),
			filter = filter,
			filterOpen = filter ~= nil
		}):pos(45, node.geth(node)/2 + 1):add2(node)

		if magicData then
			local function resetSkillTableInfo(color, colorLv)
				color = color or cc.c3b(193, 173, 142)
				colorLv = colorLv or cc.c3b(87, 164, 107)
				local label = an.newLabelM(0, 20, 1, {
					manual = true
				}):pos(78, 8):add2(node):nextLine():addLabel(magicData:get("magicName"), color):addLabel(" Lv " .. magicData:get("level"), colorLv):nextLine()
				local level = magicData:get("level")
				local curTrain = magicData:get("curTrain")
				local maxTrain = magicData:get("maxTrain")

				if level == 3 or maxTrain <= curTrain then
					label.addLabel(label, "经验已满", cc.c3b(192, 183, 170))
				else
					label.addLabel(label, "经验: " .. curTrain .. " / " .. maxTrain, cc.c3b(192, 183, 170))
				end

				return label
			end

			local skillkey = magicData.get(magicData, "key")
			local info = nil

			if skillkey == 255 then
				info = resetSkillTableInfo(def.colors.labelGray, def.colors.labelGray)
			else
				info = resetSkillTableInfo(cc.c3b(193, 173, 142), cc.c3b(87, 164, 107))
			end

			if self.isHero and not magicConfig.heroCannotClose then
				local toggleBtn = nil

				local function click()
					toggleBtn:setIsSelect(not toggleBtn.isSelect)
					magicData:set("key", (toggleBtn.isSelect and 255) or 0)
					net.send({
						CM_HERO_SKILL_HOTKEY,
						recog = magicId,
						param = magicData:get("key")
					})

					if toggleBtn.isSelect then
						info:removeSelf()

						info = resetSkillTableInfo(def.colors.labelGray, def.colors.labelGray)
					else
						info:removeSelf()

						info = resetSkillTableInfo()
					end

					return 
				end

				toggleBtn = an.newBtn(res.gettex2("pic/panels/equip/pictext_0.png"), click, {
					support = "easy",
					select = {
						res.gettex2("pic/panels/equip/pictext_1.png"),
						manual = true
					}
				}):anchor(0.5, 1):pos(250, node.geth(node)/2):add2(node)

				toggleBtn.setIsSelect(toggleBtn, skillkey == 255)
			end

			info.anchor(info, 0, 0.5)
			info.pos(info, 88, node.geth(node)*0.5)
		else
			slot11 = an.newLabelM(0, 20, 1, {
				manual = true
			}):pos(88, 8):add2(node):nextLine()
			local info = an.newLabelM(0, 20, 1, {
				manual = true
			}).pos(88, 8).add2(node).nextLine().addLabel(slot11, (self.isHero and magicConfig.heroName) or magicConfig.name, cc.c3b(162, 69, 69)):nextLine():addLabel("未学习", cc.c3b(162, 69, 69))

			info.anchor(info, 0, 0.5)
			info.pos(info, 88, node.geth(node)*0.5)
		end
	end

	return 
end
equip.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if self.page == "equip" and form == "bag" then
		local anchor = self.content:getAnchorPoint()
		local offset = cc.p(self.content:getw()*anchor.x, self.content:geth()*anchor.y)
		y = y - self.content:getPositionY() + offset.y
		x = x - self.content:getPositionX() + offset.x
		local putIdx = self.pos2idx(self, x, y)

		if putIdx == "-1" then
			return 
		end

		item.use(item, putIdx)
	end

	return 
end
equip.setSecurityState = function (self, state)
	if state then
		self.btnSecurity:select()
	else
		self.btnSecurity:unselect()
	end

	return 
end

return equip
