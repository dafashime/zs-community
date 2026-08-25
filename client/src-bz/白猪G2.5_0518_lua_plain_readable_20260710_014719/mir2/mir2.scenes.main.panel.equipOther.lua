local scale = 1.3
local item = import("..common.item")
local extendUI = require("mir2.scenes.main.common.extendUI")
local titleTips = import("..common.titleInfo")
local cc2 = require("mir2.cc")
local equipOther = class("equipOther", function()
	return display.newNode()
end)

table.merge(equipOther, {})

function equipOther:initTabs()
	def.otherEquipCusTabs = {
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
		tabs = {}
	}
end

function equipOther:ctor(userInfo)
	self.userInfo = userInfo
	self.infoView = nil

	local bg = res.get2("pic/panels/equip/bg.png"):anchor(0, 0):addto(self)

	self.bg = bg

	self.anchor(self, 1, 1):pos(display.width - 60, display.height - 16):size(cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height))

	self._scale = 1
	self._supportMove = true

	if not def.otherEquipCusTabs then
		self:initTabs()
	end

	local items = {}

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self), self.geth(self) - 48):addto(self, 1)
	an.newLabel(userInfo.get(userInfo, "userName"), 22, 1, {
		color = def.colors.get(userInfo.get(userInfo, "nameColorIndex"))
	}):anchor(0.5, 0.5):pos(self.getw(self) / 2, self.geth(self) - 34):addto(self)

	self.guildLabel = an.newLabel("", 22, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self) * 0.5, 395)
	self.clanLabel = an.newLabel("", 20, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self) * 0.5, 360)

	local value = self:addTabs(items)

	value[1] = self:addTab(1, "equip", "装\n备", def.otherEquipCusTabs.startPosY, def.equipCusTabs.equipFrom or "left", value)
	self.infoViewContent = display.newNode():addto(self)
	self.infoViews = {}

	self:clickTab2(value[1], value)
end

function equipOther:showContent(userInfo, page)
	if self.content then
		self.content:removeSelf()
	end

	for _, infoView in pairs(self.infoViews) do
		infoView:removeAllChildren()
		infoView:setVisible(false)
	end

	if not self.styleitems then
		self.styleitems = {}
	end

	if self.styleitems then
		for index = 1, #self.styleitems do
			self.styleitems[index]:removeSelf()

			self.styleitems[index] = nil
		end

		self.styleitems = {}
	end

	self.content = display.newNode():addto(self)
	page = page or "equip"
	self.page = page

	self.guildLabel:setString("")
	self.clanLabel:setString("")

	if page == "equip" then
		self.content:setScale(1.2)

		self.disY = 0

		local tmpsex = Hibyte(Hiword(userInfo.get(userInfo, "feature")))
		local bgend = userInfo.get(userInfo, "clanName") == " 的英雄" and ".png" or ".png"
		local bghead = tmpsex % 2 == 0 and "pic/panels/equip/sex0" or "pic/panels/equip/sex1"
		local jobbyName = func.getJobbyName(userInfo:get("userName"))

		if jobbyName and jobbyName.job and jobbyName.job >= 8 then
			bghead = tmpsex % 2 == 0 and "pic/panels/equip/sex" .. tostring(jobbyName.job) .. "0" or "pic/panels/equip/sex" .. tostring(jobbyName.job) .. "1"
		end

		self.bg:setTex(res.gettex2(bghead .. bgend))

		local value = Lobyte(Hiword(userInfo.get(userInfo, "feature")))
		local hairID = ycFunction:band(value, 15)

		if hairID > 0 then
			if jobbyName and jobbyName.job and jobbyName.job >= 8 then
				local x = 139
				local y = 240

				if def.jobMaps then
					local text = def.jobMaps[tostring(jobbyName.job)]

					if text then
						x = text.equipHairPosX or x
						y = text.equipHairPosY or y
					end
				end

				res.getui(1, 442 + jobbyName.job + tmpsex):add2(self.content):anchor(0.5, 1):pos(x, y)
			else
				res.getui(1, hairID + 440):add2(self.content):anchor(0.5, 1):pos(139, 240)
			end
		end

		self.items = {}

		local tmpDisY = 0

		for i, v in ipairs(userInfo.get(userInfo, "userItems")) do
			if v.get(v, "Index") ~= 0 then
				local tmpDisY2 = 0

				if i == 3 or i == 4 or i >= 6 and i <= 9 then
					tmpDisY2 = self.disY
				end

				local k = false

				if i == 1 or i == 2 or i == 14 or i == 5 or i == 15 or i == 16 or def.hideEquipJPItemTips then
					k = true
				end

				local x2, y2, z, isSetOffset, attach = self.idx2pos(self, i - 1)

				self.items[i] = item.new(v, self, {
					mute = true,
					img = "stateitem",
					donotMove = true,
					isSetOffset = isSetOffset,
					idx = i,
					hideJPTips = k
				}):addto(self.content, z):pos(x2, y2 + tmpDisY2)

				if attach then
					self.items[i .. "_attach"] = item.new(v, self, {
						donotMove = true,
						idx = i
					}):addto(self.content, attach[3]):pos(attach[1], attach[2])
				end
			end
		end

		if userInfo.get(userInfo, "clanName") == " 的英雄" then
			if self.items[14] and self.items[5] then
				self.items[5]:hide()
			end

			an.newLabel(userInfo.get(userInfo, "guildName") .. userInfo.get(userInfo, "clanName"), 16, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):addto(self.content):pos(150, 368)
		else
			local info = ""

			if net.str(userInfo.get(userInfo, "guildName")) == "" and net.str(userInfo.get(userInfo, "clanName")) == "" then
				self.guildLabel:setString(info)
				self.clanLabel:setString(info)
			else
				local info2 = userInfo.get(userInfo, "guildName")

				self.guildLabel:setString(info2)

				local info3 = userInfo.get(userInfo, "clanName")

				self.clanLabel:setString(info3)
			end
		end

		local equipStyleCfg = def.role.getEquipStyleCfg()

		if equipStyleCfg then
			for _2, item2 in pairs(self.items) do
				cc2.ms({
					function()
						local var = item2.data.getVar("name")

						if var and equipStyleCfg and equipStyleCfg[var] ~= nil then
							local value = equipStyleCfg[var]
							local point = self:convertToNodeSpace(item2:convertToWorldSpace(cc.p(item2:getw() * 0.5 - 2, item2:geth() * 0.5 - 5)))

							if value.useData then
								local value2 = m2spr.playAnimation(value.dataFile, value.min, value.max, value.interval or 0.1, false):pos(point.x + (value.offsetX or 0), point.y + (value.offsetY or 0)):add2(self, 1):scale(value.sc or 1)

								if value2 then
									value2:setTouchEnabled(false)

									self.styleitems[#self.styleitems + 1] = value2
								end
							else
								local value3 = _get2("pic/bzmir/itemstyle/" .. value.png .. "/1.png"):pos(point.x + (value.offsetX or 0), point.y + (value.offsetY or 0)):add2(self, 1)

								if value3 then
									value3:setScale(value.sc or 1)
									value3:setTouchEnabled(false)

									local value4 = _getani2("pic/bzmir/itemstyle/" .. value.png .. "/%d.png", value.min or 1, value.max or 100, value.interval or 0.1)

									if value4 then
										value4.retain(value4)
										value3:runForever(cc.Animate:create(value4))

										self.styleitems[#self.styleitems + 1] = value3
									end
								end
							end
						end
					end
				})
			end
		end

		self:reqExtend()
	else
		local value2 = def.otherEquipCusTabs.tabs[page]

		if value2 then
			local node = self.infoViews[page]

			self.bg:setTex(res.gettex2("pic/panels/equip/" .. (value2.bg or "bg") .. ".png"))

			if not node then
				if value2.infoHeight > 368 then
					node = an.newScroll(28, 34, 278, 368):add2(self.infoViewContent)

					if value2.infoHeight then
						node:setScrollSize(278, value2.infoHeight)
					end

					local background = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.infoViewContent):anchor(0, 0)
					local value_2 = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(background.getw(background) * 0.5, background.geth(background) - 42):add2(background)

					node.setListenner(node, function(nameOwner)
						if nameOwner.name == "moved" then
							local scrollOffset, tmpDisY = node:getScrollOffset()
							local scrollSize = node:getScrollSize().height - node:geth()

							if tmpDisY < 0 then
								tmpDisY = 0
							end

							tmpDisY = scrollSize < tmpDisY and scrollSize or tmpDisY

							value_2:setPositionY((background:geth() - 42) * (1 - tmpDisY / scrollSize))
						end
					end)
				else
					node = display.newNode():addto(self.infoViewContent):pos(20, 20):size(self.bg:getw() - 20, self.bg:geth() - 100)
				end

				self.infoViews[page] = node
			end

			node:setVisible(true)
			node:removeAllChildren()

			if value2.callMethod then
				def.role.call(bzmir.mcmd .. value2.callMethod .. bzmir.cmdcnt .. self.userInfo.userName)
			end
		else
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))
		end
	end
end

U_Horse = 15

function equipOther:initPosTable()
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

function equipOther:idx2pos(idx)
	self.initPosTable(self)

	local pos = self.itemPosTable[tonumber(idx)] or {
		0,
		0,
		0,
		0
	}

	return pos[1], pos[2], pos[3], pos[4], pos.attach
end

function equipOther:reqExtend()
	def.role.sendCM("@equipOtherExtend~" .. self.userInfo.userName)
end

function equipOther:genExtend(value)
	if self.page == "equip" then
		self.extLoaded = true

		extendUI.create(self.content, value, "equipother_ext")
	end
end

function equipOther:updateContent(value, deltaTime)
	if deltaTime then
		if self.infoViews[deltaTime] then
			extendUI.create(self.infoViews[deltaTime], value, "otherequip_extview")
		end
	elseif self.infoViews[self.page] then
		extendUI.create(self.infoViews[self.page], value, "otherequip_extview")
	end
end

return equipOther
