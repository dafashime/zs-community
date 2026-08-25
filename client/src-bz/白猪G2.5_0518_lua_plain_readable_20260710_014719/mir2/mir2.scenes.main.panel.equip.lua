local item = import("..common.item")
local magic = import("..common.magic")
local titleInfo = import("..common.titleInfo")
local def2 = import("..console.widget._def")
local detail = import("..console.detail")
local iconFunc = import("..console.iconFunc")
local security = import("..panel.security")
local common = import("..common.common")
local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local equip = class("equip", function()
	return display.newNode()
end)

U_Horse = 15
U_XueYu = 16
equip.extend = nil

table.merge(equip, {
	isRole = 0,
	disY = 0
})

function equip:resetPanelPosition(type2)
	if type2 == "right" then
		self.anchor(self, 1, 1):pos(display.width - 100, display.height - 60)
	elseif type2 == "right2" then
		self.anchor(self, 1, 1):pos(display.width - 40, display.height - 60)
	end

	return self
end

function equip:initTabs()
	def.equipCusTabs = {
		leftPosX = 7,
		startPosY = 410,
		fontSize = 24,
		rightPosX = 370,
		selectColor = 150,
		labelOffsetLeft = {
			x = 2,
			y = 12
		},
		labelOffsetRight = {
			x = -2,
			y = 12
		},
		tabs = {
			state = {
				ofSide = "left",
				name = "状\n态",
				posy = 324
			},
			attributes = {
				ofSide = "left",
				name = "属\n性",
				posy = 238
			},
			skill = {
				ofSide = "left",
				name = "技\n能",
				posy = 152
			}
		}
	}
end

function equip:ctor(value)
	if self.isHero then
		self.baseData = g_data.hero
		self.equipData = g_data.heroEquip
	else
		self.baseData = g_data.player
		self.equipData = g_data.equip
	end

	if not def.equipCusTabs then
		self:initTabs()
	end

	local items = {}

	value = value or {}

	local bg = res.get2("pic/panels/equip/bg.png"):anchor(0, 0):addto(self)

	self.bg = bg

	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):resetPanelPosition(self.isHero and value.from == "equip" and "right2" or "right")

	self._scale = 1
	self._supportMove = true

	if not self.isHero or not (self.geth(self) - 50) then
		local h = self.geth(self) - 40
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self), self.geth(self) - 48):addto(self, 1)

	local text = ""

	if self.isHero then
		local text2 = "bag"

		an.newLabel(self.baseData.name, 22, 1):anchor(0.5, 0.5):pos(self.getw(self) / 2, self.geth(self) - 34):addto(self)
	else
		local text3 = "hero"

		if main_scene.ground.map and main_scene.ground.map.player then
			local value3 = main_scene.ground.map.player.info.name
			local color2 = type(value3.color) == "number" and def.colors.get(value3.color) or value3.color

			an.newLabel(value3.texts[1], 22, 1, {
				color = color2
			}):anchor(0.5, 0.5):pos(self.getw(self) / 2, self.geth(self) - 34):addto(self)
		end
	end

	self.guildLabel = an.newLabel("", 22, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self) * 0.5, 395)
	self.clanLabel = an.newLabel("", 20, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self) * 0.5, 360)

	local value2 = self:addTabs(items)

	value2[1] = self:addTab(1, "equip", "装\n备", def.equipCusTabs.startPosY, def.equipCusTabs.equipFrom or "left", value2)

	local value4 = value2[1]

	if value.page then
		for _, item2 in ipairs(value2) do
			if item2.page == value.page then
				value4 = item2

				break
			end
		end
	end

	self.infoViewContent = display.newNode():addto(self)
	self.infoViews = {}

	self:clickTab2(value4, value2)
end

function equip:showContent(page, options)
	if self.content then
		self.content:removeSelf()
	end

	for _, infoView in pairs(self.infoViews) do
		infoView:setVisible(false)
	end

	self.content = display.newNode():addto(self)
	page = page or "equip"
	self.page = page

	self.guildLabel:setString("")
	self.clanLabel:setString("")

	if not self.styleitems then
		self.styleitems = {}
	end

	if self.styleitems then
		for index2 = 1, #self.styleitems do
			self.styleitems[index2]:removeSelf()

			self.styleitems[index2] = nil
		end

		self.styleitems = {}
	end

	if page == "equip" then
		self.content:setScale(1.2)

		local value6 = self.isHero and g_data.hero.sex or g_data.player.sex

		self.disY = 0

		local value14 = self.isHero and ".png" or ".png"
		local value11 = value6 == 0 and "pic/panels/equip/sex0" or "pic/panels/equip/sex1"

		if g_data.player.job >= 8 then
			value11 = value6 == 0 and "pic/panels/equip/sex" .. tostring(g_data.player.job) .. "0" or "pic/panels/equip/sex" .. tostring(g_data.player.job) .. "1"
		end

		self.bg:setTex(res.gettex2(value11 .. value14))

		if not self.isHero or false then
			local text = ""

			if g_data.guild.guildInfo or g_data.guild.clanInfo then
				if g_data.guild.guildInfo then
					local value15 = g_data.guild.guildInfo:get("gildName")

					self.guildLabel:setString(value15)
				end

				if g_data.guild.clanInfo then
					local value16 = g_data.guild.clanInfo:get("corpsName")

					self.clanLabel:setString(value16)
				end
			end
		end

		local value25

		if self.isHero then
			if main_scene.ground.player and main_scene.ground.player.hero then
				local value26 = main_scene.ground.player.hero.hair
			end
		elseif main_scene.ground.player then
			local value27 = main_scene.ground.player.hair
		end

		if g_data.player.job >= 8 then
			local x3 = 139
			local y2 = 240

			if def.jobMaps and def.jobMaps[tostring(g_data.player.job)] then
				x3 = def.jobMaps[g_data.player.job].equipHairPosX or x3
				y2 = def.jobMaps[g_data.player.job].equipHairPosY or y2
			end

			res.getui(1, 442 + g_data.player.job + value6):addto(self.content):anchor(0.5, 1):pos(x3, y2)
		else
			res.getui(1, 442 + value6):addto(self.content):anchor(0.5, 1):pos(139, 240)
		end

		self.items = {}

		for itemId, item4 in pairs(self.equipData.items) do
			local count2 = 0

			if itemId == 2 or itemId == 3 or itemId >= 5 and itemId <= 8 then
				count2 = self.disY
			end

			local x4, y4, value17, isSetOffset2, x2 = self.idx2pos(self, itemId)
			local hideJPTips2 = false

			if itemId == 0 or itemId == 1 or itemId == 13 or itemId == 4 or itemId == 14 or itemId == 15 or def.hideEquipJPItemTips then
				hideJPTips2 = true
			end

			self.items[itemId] = item.new(item4, self, {
				img = "stateitem",
				isSetOffset = isSetOffset2,
				idx = itemId,
				hideJPTips = hideJPTips2
			}):addto(self.content, value17):pos(x4, y4 + count2)

			if x2 then
				self.items[itemId .. "_attach"] = item.new(item4, self, {
					idx = itemId
				}):addto(self.content, x2[3]):pos(x2[1], x2[2])
			end
		end

		local equipStyleCfg = def.role.getEquipStyleCfg()

		if equipStyleCfg then
			for _2, item2 in pairs(self.items) do
				local var = item2.data.getVar("name")

				if var and equipStyleCfg and equipStyleCfg[var] ~= nil then
					local value2 = equipStyleCfg[var]
					local point = self:convertToNodeSpace(item2:convertToWorldSpace(cc.p(item2:getw() * 0.5 - 2, item2:geth() * 0.5 - 5)))

					if value2.useData then
						local value10 = m2spr.playAnimation(value2.dataFile, value2.min, value2.max, value2.interval or 0.1, false):pos(point.x + (value2.offsetX or 0), point.y + (value2.offsetY or 0)):add2(self, 1):scale(value2.sc or 1)

						if value10 then
							value10:setTouchEnabled(false)

							self.styleitems[#self.styleitems + 1] = value10
						end
					else
						local value4 = _get2("pic/bzmir/itemstyle/" .. value2.png .. "/1.png"):pos(point.x + (value2.offsetX or 0), point.y + (value2.offsetY or 0)):add2(self, 1)

						if value4 then
							value4:setScale(value2.sc or 1)
							value4:setTouchEnabled(false)

							local value7 = _getani2("pic/bzmir/itemstyle/" .. value2.png .. "/%d.png", value2.min or 1, value2.max or 100, value2.interval or 0.1)

							if value7 then
								value7.retain(value7)
								value4:runForever(cc.Animate:create(value7))

								self.styleitems[#self.styleitems + 1] = value4
							end
						end
					end
				end
			end
		end

		if self.items[13] and self.items[4] and self.isHero then
			self.items[4]:hide()
		end

		if not self.isHero and (g_data.security.equipBit or g_data.equip.lockState > 0) then
			self.btnSecurity = an.newBtn(res.gettex2("pic/panels/equip/security0.png"), function()
				sound.playSound("103")

				if g_data.equip.lockState == 0 then
					return
				end

				local time = socket.gettime()

				if g_data.client.lastTime.clickUnlockTime and time - g_data.client.lastTime.clickUnlockTime < 3 then
					return
				end

				local value20 = time - g_data.client.lastTime.equipUnlockTime
				local value13 = math.floor(g_data.equip.serverUnlockTime - value20)

				if value13 > 0 then
					common.addMsg("请等待" .. value13 .. "秒之后再解锁装备", display.COLOR_WHITE, display.COLOR_RED)
				else
					net.send({
						CM_LOCK_UNLOCK_EQUIP
					})
					g_data.client:setLastTime("clickUnlockTime", true)
				end
			end, {
				support = "easy",
				pressImage = res.gettex2("pic/panels/equip/security1.png"),
				select = {
					res.gettex2("pic/panels/equip/security2.png"),
					manual = true
				}
			}):pos(290, 347):add2(self.content):scale(0.9)
		end

		if not self.isHero then
			if self.extendCache then
				self:genExtend(self.extendCache)
			end

			self:reqExtend()
		end
	else
		if page == "state" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local count = 0
			local y3 = 372

			local function callback3(self3, value21)
				an.newLabel(self3, 20, 0, {
					color = cc.c3b(191, 173, 126)
				}):anchor(0, 0.5):addto(self.content):pos(26, y3 - count * 48)
				res.get2("pic/panels/equip/attback.png"):anchor(0, 0.5):pos(90, y3 - count * 48):add2(self.content)
				an.newLabel(value21, 20, 0, {
					color = cc.c3b(188, 188, 188)
				}):anchor(0, 0.5):addto(self.content):pos(98, y3 - count * 48)

				count = count + 1
			end

			local value18 = self.baseData.ability
			local value28 = self.baseData.ability3

			local function callback2(self2)
				local value5 = value18:get(self2)

				if g_data.player.cmAbil and g_data.player.cmAbil[self2] then
					value5 = value5 - g_data.player.cmAbil[self2]

					if value5 < 0 then
						value5 = 0
					end
				end

				return value5
			end

			local items4 = {
				{
					CS_AC,
					callback2("AC") .. "-" .. callback2("maxAC")
				},
				{
					CS_MAC,
					callback2("MAC") .. "-" .. callback2("maxMAC")
				},
				{
					CS_DC,
					callback2("DC") .. "-" .. callback2("maxDC")
				},
				{
					CS_MC,
					callback2("MC") .. "-" .. callback2("maxMC")
				},
				{
					CS_SC,
					callback2("SC") .. "-" .. callback2("maxSC")
				},
				{
					CS_HP,
					callback2("HP") .. "/" .. callback2("maxHP")
				},
				{
					CS_MP,
					callback2("MP") .. "/" .. callback2("maxMP")
				}
			}

			for _3, item5 in ipairs(items4) do
				callback3(item5[1], item5[2])
			end

			return
		end

		if page == "attributes" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local scroll = an.newScroll(28, 34, 278, 368):add2(self.content)
			local number = 30
			local items2 = {}

			local function callback(self4, value22)
				items2[#items2 + 1] = {
					self4,
					value22
				}
			end

			local value = self.baseData.ability
			local value8 = self.baseData.ability3

			callback(CS_JOB, self.baseData:getJobStr())
			callback(CS_LEVEL, value.get(value, "level"))
			callback("幸运值", value8.get(value8, "attackLuck"))

			if not self.isHero then
				callback(CS_PRESTIGE, value8.get(value8, "prestige"))
				callback(CS_YB, self.baseData:getIngot())
				callback(CS_GRID, self.baseData:getGird())
			end

			callback(CS_EXP, fixuint(value.get(value, "Exp")))
			callback(CS_MAXEXP, fixuint(value.get(value, "maxExp")))
			callback(CS_WEIGHT, value.get(value, "weight") .. "/" .. value.get(value, "maxWeight"))
			callback(CS_WAREWEIGHT, value.get(value, "wearWeight") .. "/" .. value.get(value, "maxWearWeight"))
			callback(CS_HAND, value.get(value, "handWeight") .. "/" .. value.get(value, "maxHandWeight"))
			callback(CS_HIT, value.get(value, "hitRate"))
			callback(CS_QUICK, value.get(value, "quickRate"))
			callback(CS_ANTI, "+" .. value.get(value, "antiMagic") * 10 .. "%")
			callback(CS_POIS, "+" .. value.get(value, "poisAC") .. "%")
			callback(CS_BUPOIS, "+" .. value.get(value, "buPoisResume") * 10 .. "%")
			callback(CS_HPR, "+" .. value.get(value, "hpResume") .. "%")
			callback(CS_MPR, "+" .. value.get(value, "mpResume") .. "%")
			scroll.setScrollSize(scroll, 278, math.max(368, #items2 * number))

			for index, item6 in ipairs(items2) do
				an.newLabel(item6[1], 20, 0, {
					color = cc.c3b(217, 207, 183)
				}):addto(scroll):pos(16, scroll.getScrollSize(scroll).height - index * number)
				an.newLabel(item6[2], 20, 0, {
					color = cc.c3b(217, 207, 183)
				}):addto(scroll):pos(133, scroll.getScrollSize(scroll).height - index * number)
			end

			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.content):anchor(0, 0)
			local value_22 = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(background.getw(background) * 0.5, background.geth(background) - 42):add2(background)

			scroll.setListenner(scroll, function(nameOwner)
				if nameOwner.name == "moved" then
					local scrollOffset3, scrollOffset = scroll:getScrollOffset()
					local scrollSize = scroll:getScrollSize().height - scroll:geth()

					if scrollOffset < 0 then
						scrollOffset = 0
					end

					scrollOffset = scrollSize < scrollOffset and scrollSize or scrollOffset

					value_22:setPositionY((background:geth() - 42) * (1 - scrollOffset / scrollSize))
				end
			end)
		elseif page == "skill" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local rect = cc.rect(0, 0, 310, 368)
			local magicIds = def.magic.getMagicIds(self.baseData.job, self.isHero)

			if self.isHero and g_data.hero.roleid ~= 0 then
				local items3 = {
					"50",
					"55",
					"53",
					"52",
					"51",
					"54"
				}
				local value29 = g_data.player.job

				if g_data.player.job == g_data.hero.job then
					magicIds[#magicIds + 1] = items3[g_data.player.job + 1]
				else
					magicIds[#magicIds + 1] = items3[g_data.player.job + g_data.hero.job + 3]
				end
			end

			local items = {}

			for _4, item7 in ipairs(magicIds) do
				if self.baseData:getMagic(tonumber(item7)) then
					items[#items + 1] = item7
				end
			end

			for _5, item3 in ipairs(magicIds) do
				if not self.baseData:getMagic(tonumber(item3)) then
					local callback4 = def.magic.getMagicConfigByUid
					local value19 = item3

					if self.isHero then
						-- block empty
					end

					local value12 = callback4(value19, main_scene.ground.player)

					if self.isHero and value12.heroName or not self.isHero and value12.name then
						items[#items + 1] = item3
					end
				end
			end

			local number2 = 90
			local scroll2 = an.newScroll(12, 34, rect.width, rect.height):addto(self.content)

			scroll2.setScrollSize(scroll2, rect.width, math.max(rect.height, #items * number2))

			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.content):anchor(0, 0)
			local value_23 = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(background2.getw(background2) * 0.5, background2.geth(background2) - 42):add2(background2)
			local value9

			self.magics = {}

			for cellindex, item8 in ipairs(items) do
				local value_2 = res.get2("pic/panels/equip/skillback0.png"):anchor(0, 0):add2(scroll2):pos(14, scroll2.getScrollSize(scroll2).height - cellindex * number2)

				value_2.cellindex = cellindex

				value_2.setTouchEnabled(value_2, true)
				value_2.setTouchSwallowEnabled(value_2, false)
				value_2.addNodeEventListener(value_2, cc.NODE_TOUCH_EVENT, function(offsetBeginX)
					if offsetBeginX.name == "began" then
						value_2.offsetBeginX = offsetBeginX.x
						value_2.offsetBeginY = offsetBeginX.y

						return true
					elseif offsetBeginX.name == "ended" then
						local value23 = offsetBeginX.x - value_2.offsetBeginX
						local value24 = offsetBeginX.y - value_2.offsetBeginY

						if math.abs(value23) < 5 and math.abs(value24) < 5 then
							if value9 then
								value9:setTex("pic/panels/equip/skillback0.png")
							end

							value9 = value_2

							value9:setTex("pic/panels/equip/skillback1.png")
						end
					end
				end)
				self.updateMagic(self, item8, value_2)

				self.magics[item8] = value_2
			end

			scroll2.setListenner(scroll2, function(nameOwner2)
				if nameOwner2.name == "moved" then
					local scrollOffset4, scrollOffset2 = scroll2:getScrollOffset()
					local scrollSize2 = scroll2:getScrollSize().height - scroll2:geth()

					if scrollOffset2 < 0 then
						scrollOffset2 = 0
					end

					scrollOffset2 = scrollSize2 < scrollOffset2 and scrollSize2 or scrollOffset2

					value_23:setPositionY((background2:geth() - 42) * (1 - scrollOffset2 / scrollSize2))
				end
			end)
		else
			local value3 = def.equipCusTabs.tabs[page]

			if value3 then
				self.bg:setTex(res.gettex2("pic/panels/equip/" .. (value3.bg or "bg") .. ".png"))

				local node = self.infoViews[page]

				if not node then
					if value3.infoHeight > 368 then
						node = an.newScroll(28, 34, 278, 368):add2(self.infoViewContent)

						if value3.infoHeight then
							node:setScrollSize(278, value3.infoHeight)
						end
					else
						node = display.newNode():addto(self.infoViewContent):pos(20, 20):size(self.bg:getw() - 20, self.bg:geth() - 100)
					end

					self.infoViews[page] = node
				end

				node:setVisible(true)
				node:removeAllChildren()

				if value3.callMethod then
					def.role.call(bzmir.mcmd .. value3.callMethod)
				end
			else
				self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))
			end
		end
	end
end

function equip:initPosTable()
	if def.itemPosTable then
		self.itemPosTable = def.itemPosTable
	else
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

		cc2.ms({
			function()
				if def.role.itemstyle.lock_34 == nil or def.role.itemstyle.lock_34 then
					if #self.itemPosTable == 13 then
						self.itemPosTable[#self.itemPosTable + 1] = {
							50,
							222,
							2
						}
						self.itemPosTable[#self.itemPosTable + 1] = {
							179,
							173,
							2
						}
						self.itemPosTable[#self.itemPosTable + 1] = {
							20,
							70,
							2
						}
					end
				elseif #self.itemPosTable == 13 then
					self.itemPosTable[#self.itemPosTable + 1] = {
						50,
						222,
						2,
						true
					}
					self.itemPosTable[#self.itemPosTable + 1] = {
						179,
						173,
						2,
						true
					}
					self.itemPosTable[#self.itemPosTable + 1] = {
						20,
						70,
						2,
						true
					}
				end
			end
		})
	end
end

function equip:idx2pos(idx2)
	self.initPosTable(self)

	local number = self.itemPosTable[tonumber(idx2)] or {
		0,
		0,
		0,
		0
	}

	return number[1], number[2], number[3], number[4], number.attach
end

function equip:pos2idx(x2, y2)
	self.initPosTable(self)

	for key3, itemPosTable in pairs(self.itemPosTable) do
		local rect = cc.rect(itemPosTable[1] - item.w / 2, itemPosTable[2] - item.h / 2, item.w, item.h)

		if itemPosTable[4] then
			rect = cc.rect(itemPosTable[5], itemPosTable[6], itemPosTable[7], itemPosTable[8])
		end

		if cc.rectContainsPoint(rect, cc.p(x2, y2)) then
			return key3
		end

		if itemPosTable.attach then
			local rect2 = cc.rect(itemPosTable.attach[1] - item.w / 2, itemPosTable.attach[2] - item.h / 2, item.w, item.h)

			if cc.rectContainsPoint(rect2, cc.p(x2, y2)) then
				return key3
			end
		end
	end

	return "-1"
end

function equip:setItem(item2)
	if self.page == "equip" then
		local idx2, item3 = self.equipData:getItem(item2)

		if item3 then
			if self.items[idx2] then
				self.items[idx2]:removeSelf()
			end

			if self.items[idx2 .. "_attach"] then
				self.items[idx2 .. "_attach"]:removeSelf()
			end

			local count = 0

			if idx2 == 2 or idx2 == 3 or idx2 >= 5 and idx2 <= 8 then
				count = self.disY
			end

			local x3, y2, value, isSetOffset2, x2 = self.idx2pos(self, idx2)

			self.items[idx2] = item.new(item3, self, {
				img = "stateitem",
				isSetOffset = isSetOffset2,
				idx = idx2
			}):addto(self.content, value):pos(x3, y2 + count)

			if x2 then
				self.items[idx2 .. "_attach"] = item.new(item3, self, {
					idx = idx2
				}):addto(self.content, x2[3]):pos(x2[1], x2[2])
			end

			if idx2 == 13 and self.items[4] and self.isHero then
				self.items[4]:hide()
			end

			if idx2 == 4 and self.items[13] and self.isHero then
				self.items[4]:hide()
			end
		end

		self:showContent(self.page, true)
	end
end

function equip:delItem(makeIndex)
	if self.page == "equip" then
		for itemId, item2 in pairs(self.items) do
			if item2.data:get("makeIndex") == tonumber(makeIndex) then
				self.items[itemId]:removeSelf()

				self.items[itemId] = nil

				if itemId == 13 and self.items[4] and self.isHero then
					self.items[4]:show()
				end
			end
		end

		self:showContent(self.page, true)
	end
end

function equip:uptItem(makeIndex)
	local item2, data = self.equipData:getItem(makeIndex)

	if data then
		if self.items[item2] then
			self.items[item2].data = data
		end

		if self.items[item2 .. "_attach"] then
			self.items[item2 .. "_attach"].data = data
		end

		if item2 == 13 and self.items[4] and self.isHero then
			self.items[4]:hide()
		end

		if item2 == 4 and self.items[13] and self.isHero then
			self.items[4]:hide()
		end
	end

	if self.page == "equip" then
		self:showContent(self.page, true)
	end
end

function equip:updateMagic(text, deltaTime)
	if self.page == "skill" then
		text = tostring(text)
		deltaTime = deltaTime or self.magics[text]

		if not deltaTime then
			return
		end

		deltaTime.removeAllChildren(deltaTime)

		local callback = def.magic.getMagicConfigByUid
		local value9 = text

		if self.isHero then
			-- block empty
		end

		local value2 = callback(value9, main_scene.ground.player)
		local items
		local value3

		if value2 then
			value3 = clone(def2.getConfig({
				key = "btnSkillTemp"
			}))
			items = {
				key2 = "btnSkillTemp",
				key = "skill" .. text,
				magicId = text
			}
		else
			return
		end

		local number = self.baseData:getMagic(tonumber(text))
		local filenames = iconFunc:getFilenames(value3, items)
		local filter2

		if not number then
			filter2 = res.getFilter("gray")
		end

		local value = number and number:get("magicName") or ""

		filenames.sprite = def.magic.buildSkillIcon(text)

		local callback2 = def.magic.getMagicConfigByUid
		local value10 = text

		if self.isHero then
			-- block empty
		end

		local text2 = callback2(value10, main_scene.ground.player)

		text2 = text2 or nil

		if text2 and text2.name then
			if string.find(text2.name, "|") ~= nil then
				local parts = string.split(text2.name, "|")
				local value4 = g_data.player.job

				if value4 >= 8 then
					value4 = value4 - 5
				end

				value = parts[value4 + 1]
			elseif value == "" then
				value = text2.name
			end

			if text2.extName then
				value = value .. text2.extName
			end
		end

		local btn2
		local tex2 = res.gettex2(filenames.bg)

		btn2 = an.newBtn(tex2, function()
			if number then
				table.merge(value3, {
					SkillLv = number:get("level")
				})
			end

			local point = btn2:convertToWorldSpace(cc.p(btn2:centerPos()))

			detail.new(value3, items, point.x, point.y, btn2:getw(), btn2:geth(), self.isHero and "skillHero" or "skill")
		end, {
			pressBig = true,
			sprite = filenames.sprite and res.gettex2(filenames.sprite),
			filter = filter2,
			filterOpen = filter2 ~= nil
		}):pos(45, deltaTime.geth(deltaTime) / 2 + 1):add2(deltaTime)

		if number then
			local function cleanup(self2, value5)
				self2 = self2 or cc.c3b(193, 173, 142)
				value5 = value5 or cc.c3b(87, 164, 107)

				local label = an.newLabelM(0, 20, 1, {
					manual = true
				}):pos(78, 8):add2(deltaTime):nextLine():addLabel(value, self2):addLabel(" Lv " .. number:get("level"), value5):nextLine()
				local value11 = number:get("level")
				local value7 = number:get("curTrain")
				local value8 = number:get("maxTrain")

				if value11 == 3 or value8 <= value7 then
					label.addLabel(label, "经验已满", cc.c3b(192, 183, 170))
				else
					label.addLabel(label, "经验: " .. value7 .. " / " .. value8, cc.c3b(192, 183, 170))
				end

				return label
			end

			local value6 = number.get(number, "key")
			local x2

			if value6 == 255 then
				x2 = cleanup(def.colors.labelGray, def.colors.labelGray)
			else
				x2 = cleanup(cc.c3b(193, 173, 142), cc.c3b(87, 164, 107))
			end

			if self.isHero and not value2.heroCannotClose then
				local btn

				local function cleanup2()
					btn:setIsSelect(not btn.isSelect)
					number:set("key", btn.isSelect and 255 or 0)
					net.send({
						CM_HERO_SKILL_HOTKEY,
						recog = text,
						param = number:get("key")
					})

					if btn.isSelect then
						x2:removeSelf()

						x2 = cleanup(def.colors.labelGray, def.colors.labelGray)
					else
						x2:removeSelf()

						x2 = cleanup()
					end
				end

				btn = an.newBtn(res.gettex2("pic/panels/equip/pictext_0.png"), cleanup2, {
					support = "easy",
					select = {
						res.gettex2("pic/panels/equip/pictext_1.png"),
						manual = true
					}
				}):anchor(0.5, 1):pos(250, deltaTime.geth(deltaTime) / 2):add2(deltaTime)

				btn.setIsSelect(btn, value6 == 255)
			end

			x2.anchor(x2, 0, 0.5)
			x2.pos(x2, 88, deltaTime.geth(deltaTime) * 0.5)
		elseif value2.name then
			local label2 = an.newLabelM(0, 20, 1, {
				manual = true
			}):pos(88, 8):add2(deltaTime):nextLine():addLabel(self.isHero and value2.heroName or value, cc.c3b(162, 69, 69)):nextLine():addLabel("未学习", cc.c3b(162, 69, 69))

			label2:anchor(0, 0.5)
			label2:pos(88, deltaTime.geth(deltaTime) * 0.5)
		elseif value2.heroName and self.isHero then
			local label3 = an.newLabelM(0, 20, 1, {
				manual = true
			}):pos(88, 8):add2(deltaTime):nextLine():addLabel(value2.heroName, cc.c3b(162, 69, 69)):nextLine():addLabel("未学习", cc.c3b(162, 69, 69))

			label3:anchor(0, 0.5)
			label3:pos(88, deltaTime.geth(deltaTime) * 0.5)
		end
	end
end

function equip:putItem(item2, x2, y2)
	local value2 = item2.formPanel.__cname

	if self.page == "equip" and value2 == "bag" then
		local anchorPoint = self.content:getAnchorPoint()
		local point = cc.p(self.content:getw() * anchorPoint.x, self.content:geth() * anchorPoint.y)

		y2 = y2 - self.content:getPositionY() + point.y
		x2 = x2 - self.content:getPositionX() + point.x

		local value = self.pos2idx(self, x2, y2)

		if value == "-1" then
			return
		end

		item2.use(item2, value)
	end

	if self.page == "equip" then
		self:showContent(self.page, true)
	end
end

function equip:setSecurityState(securityState)
	if securityState then
		self.btnSecurity:select()
	else
		self.btnSecurity:unselect()
	end
end

function equip:reqExtend()
	def.role.call("@equipExtend")
end

function equip:genExtend(extendCache)
	if self.page == "equip" and extendCache then
		self.extLoaded = true
		self.extendCache = extendCache

		extendUI.create(self.content, extendCache, "equip_ext")
	end
end

function equip:updateContent(value, deltaTime)
	if deltaTime then
		if self.infoViews[deltaTime] then
			extendUI.create(self.infoViews[deltaTime], value, "equip_extview")
		end
	elseif self.infoViews[self.page] then
		extendUI.create(self.infoViews[self.page], value, "equip_extview")
	end
end

return equip
