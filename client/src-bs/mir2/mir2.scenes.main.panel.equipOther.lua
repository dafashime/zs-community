local scale = 1.3
local item = import("..common.item")
local titleTips = import("..common.titleInfo")
local equipOther = class("equipOther", function ()
	return display.newNode()
end)

table.merge(equipOther, {})

function equipOther:ctor(userInfo)
	local bg = res.get2("pic/panels/equip/bg.png"):anchor(0, 0):addto(self)
	self.bg = bg

	self:anchor(1, 1):pos(display.width - 60, display.height - 16):size(cc.size(bg:getContentSize().width, bg:getContentSize().height))

	self._scale = 1
	self._supportMove = true

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw(), self:geth() - 48):addto(self, 1)
	an.newLabel(userInfo:get("userName"), 22, 1, {
		color = def.colors.get(userInfo:get("nameColorIndex"))
	}):anchor(0.5, 0.5):pos(self:getw() / 2, self:geth() - 34):addto(self)

	self.guildLabel = an.newLabel("", 22, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self:getw() * 0.5, 395)
	self.clanLabel = an.newLabel("", 20, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self:getw() * 0.5, 360)
	local texts = {
		"equip"
	}
	local titleInfo = {
		"装\n备"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v:select()
				v:setLocalZOrder(5)
				v.label:setColor(cc.c3b(232, 204, 216))
			else
				v:setLocalZOrder(5 - i)
				v:unselect()
				v.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if btn.page ~= self.page then
			self:showContent(userInfo, btn.page)
		end
	end

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn130.png"), function ()
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
				res.gettex2("pic/common/btn131.png"),
				manual = true
			}
		}):add2(self, 5 - i):anchor(1, 1):pos(8, 402 - 86 * (i - 1))

		tabs[i]:setTouchEnabled(false)
		display.newNode():size(tabs[i]:getw(), tabs[i]:geth() - 30):pos(0, 30):add2(tabs[i]):enableClick(function ()
			click(tabs[i])
		end)

		tabs[i].page = v
	end

	click(tabs[1])
end

function equipOther:showContent(userInfo, page)
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

		self.disY = 0
		local tmpsex = Hibyte(Hiword(userInfo:get("feature")))

		if def.gameVersionType == "176" then
			self.disY = -26
			local bghead = sex == 0 and "pic/panels/equip/equip176_0.png" or "pic/panels/equip/equip176_1.png"

			self.bg:setTex(res.gettex2(bghead))
		else
			local bgend = userInfo:get("clanName") == " 的英雄" and "_0.png" or ".png"
			local bghead = tmpsex % 2 == 0 and "pic/panels/equip/sex0" or "pic/panels/equip/sex1"

			self.bg:setTex(res.gettex2(bghead .. bgend))
		end

		local hairID = Lobyte(Hiword(userInfo:get("feature")))
		hairID = ycFunction:band(hairID, 15)

		if hairID > 0 then
			res.getui(1, 440 + hairID):add2(self.content):anchor(0.5, 1):pos(139, 240)
		end

		self.items = {}
		local tmpDisY = 0

		for i, v in ipairs(userInfo:get("userItems")) do
			if v:get("Index") ~= 0 then
				tmpDisY = 0

				if i == 3 or i == 4 or i >= 6 and i <= 9 then
					tmpDisY = self.disY
				end

				local x, y, z, isSetOffset, attach = self:idx2pos(i - 1)
				self.items[i] = item.new(v, self, {
					mute = true,
					img = "stateitem",
					donotMove = true,
					isSetOffset = isSetOffset,
					idx = k
				}):addto(self.content, z):pos(x, y + tmpDisY)

				if attach then
					self.items[i .. "_attach"] = item.new(v, self, {
						donotMove = true,
						idx = i
					}):addto(self.content, attach[3]):pos(attach[1], attach[2])
				end
			end
		end

		if userInfo:get("clanName") == " 的英雄" then
			if self.items[14] and self.items[5] then
				self.items[5]:hide()
			end

			an.newLabel(userInfo:get("guildName") .. userInfo:get("clanName"), 16, 1, {
				color = def.colors.labelGray
			}):anchor(0.5, 0.5):addto(self.content):pos(150, 368)
		else
			local info = ""

			if net.str(userInfo:get("guildName")) == "" and net.str(userInfo:get("clanName")) == "" then
				self.guildLabel:setString(info)
				self.clanLabel:setString(info)
			else
				info = userInfo:get("guildName")

				self.guildLabel:setString(info)

				info = userInfo:get("clanName")

				self.clanLabel:setString(info)
			end
		end
	elseif page == "title" then
		res.get2("pic/panels/equip/title.png"):anchor(0.5, 0):pos(self:getw() * 0.5, 42):add2(self.content)

		local titleInfo = g_data.player.titleInfo

		if not titleInfo or #titleInfo == 0 then
			return
		end

		local hero = main_scene.ground.map:findHeroWithName(userInfo:get("userName"))

		if not hero or not hero.roleid then
			return
		end

		local tmpRoleID = hero.roleid
		local curbg = res.get2("pic/panels/equip/titlebg0.png"):anchor(0.5, 0):pos(self:getw() * 0.5, 290):add2(self.content)
		local curTitleList = {}

		for i, v in ipairs(titleInfo) do
			if v.ActorID == tmpRoleID then
				curTitleList = v

				break
			end
		end

		if not curTitleList.data then
			return
		end

		an.newLabel("封号列表", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):addto(self.content):pos(self:getw() * 0.5, 270)

		local curSetTitle = nil

		for i, v in ipairs(curTitleList.data or {}) do
			if v:get("ID") == curTitleList.curTitleID then
				local btn = nil
				btn = an.newBtn(res.gettex("ui1", v:get("Look")), function ()
				end, {
					select = {
						res.gettex("ui1", v:get("Look") + 1)
					}
				}):anchor(0.5, 0.5):pos(38, curbg:geth() * 0.55):add2(curbg)

				btn:setTouchEnabled(false)
				an.newLabel(v:get("TitleName"), 24, 1, {
					color = cc.c3b(255, 255, 0)
				}):anchor(0.5, 0.5):addto(curbg):pos(curbg:getw() * 0.6, curbg:geth() * 0.55):enableClick(function (x, y)
					titleTips.show(v, cc.p(x, y), {
						noshow = true
					})
				end)
			end
		end

		local h = 66
		local scroll = an.newScroll(40, 52, 248, h * 3):addto(self.content)

		scroll:setScrollSize(248, math.max(h * 3, #curTitleList.data * h))

		for i = 1, #curTitleList.data do
			local title = curTitleList.data[i]
			local bg = res.get2("pic/panels/equip/titlebg0.png"):anchor(0.5, 0):pos(124, scroll:getScrollSize().height - h * i):add2(scroll)
			local btn = nil
			btn = an.newBtn(res.gettex("ui1", title:get("Look")), function ()
			end, {
				select = {
					res.gettex("ui1", title:get("Look") + 1)
				}
			}):anchor(0.5, 0.5):pos(38, bg:geth() * 0.55):add2(bg)

			btn:setTouchEnabled(false)
			an.newLabel(title:get("TitleName"), 16, 1, {
				color = cc.c3b(0, 255, 0)
			}):anchor(0, 0.5):addto(bg):pos(bg:getw() * 0.3, bg:geth() * 0.34):enableClick(function (x, y)
				titleTips.show(title, cc.p(x, y), {
					noshow = true
				})
			end)
		end
	end
end

function equipOther:initPosTable()
	self.itemPosTable = self.itemPosTable or {
		[0] = {
			44,
			240,
			0,
			true,
			68,
			10,
			90,
			130
		},
		{
			44,
			240,
			1,
			true,
			15,
			55,
			65,
			155
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
			74,
			140,
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
end

function equipOther:idx2pos(idx)
	self:initPosTable()

	local pos = self.itemPosTable[tonumber(idx)] or {
		0,
		0,
		0,
		0
	}

	return pos[1], pos[2], pos[3], pos[4], pos.attach
end

return equipOther
