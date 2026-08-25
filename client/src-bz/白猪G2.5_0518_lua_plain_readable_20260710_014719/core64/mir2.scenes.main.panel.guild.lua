local common = import("..common.common")
local chatPos = import("..common.chatPos")
local chatPic = import("..common.chatPic")
local chatItem = import("..common.chatItem")
local guild = class("guild", function()
	return display.newNode()
end)
local value = def.guild.guildPrivilege

table.merge(guild, {
	home,
	members,
	content,
	tabNode,
	leaderControl,
	friends,
	needClean,
	info,
	oldOffsetY,
	guilds
})

function guild:ctor()
	self._supportMove = true
	self.needClean = {}
	self.viceCorpTitle = "副队长"
	self.corpsTitle = "队长"
	self.viceGuildTitle = "副会长"
	self.guildTitle = "会长"

	if def.corpsSets and def.corpsSets.openCusShow and def.corpsSets.posTitle then
		self.viceCorpTitle = def.corpsSets.posTitle[2]
		self.corpsTitle = def.corpsSets.posTitle[3]
		self.viceGuildTitle = def.corpsSets.posTitle[4]
		self.guildTitle = def.corpsSets.posTitle[5]
	end

	self.bg = display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):add2(self)

	self.size(self, 641, 455):anchor(0.5, 0.5):center()

	self.title = display.newSprite(res.gettex2("pic/panels/guild/clan.png")):anchor(0.5, 0.5):pos(self.getw(self) * 0.5, self.geth(self) - 25):add2(self, 2)

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self, 2)

	self.nodeContent = display.newNode():addto(self)

	self.nodeContent:size(self.getw(self), self.geth(self)):anchor(0, 0)

	local items = {
		"clan",
		"tguild"
	}
	local items2 = {
		clan = "clan",
		tguild = "guild"
	}
	local x = {}

	local function callback(self2)
		if self.showGuildListNode then
			return
		end

		sound.playSound("103")

		for _, item in ipairs(x) do
			if item == self2 then
				self.title:setTex(res.gettex2("pic/panels/guild/" .. items2[item.page] .. ".png"))
				item.select(item)
				item:setLocalZOrder(99)
			else
				item.unselect(item)
				item:setLocalZOrder(0)
			end
		end

		if self2.page ~= self.page then
			self.filterString = nil

			self:showContent(self2.page)
		end
	end

	for index, page in ipairs(items) do
		x[index] = an.newBtn(res.gettex2("pic/common/btn110.png"), callback, {
			support = "easy",
			sprite = res.gettex2("pic/panels/guild/" .. page .. "_n.png"),
			select = {
				res.gettex2("pic/common/btn111.png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(0, self.geth(self) - 36 - (index - 1) * 70)

		x[index].sprite:pos(x[index]:getw() / 2 + 3, x[index]:geth() / 2 + 12)

		x[index].page = page

		if items[1] == page then
			x[index]:select()
			x[index]:setLocalZOrder(99)
			self.showContent(self, page)
		end
	end
end

function guild:onEnter()
	return
end

function guild:onExit()
	return
end

function guild:addClan(value3)
	if not value3 then
		return
	end

	local value2 = value3:get("name")

	net.send({
		CM_CORPS_ACCEPT_REQUEST,
		param = 1
	}, nil, {
		{
			"ID",
			value3:get("ID")
		}
	})
	common.addMsg("检验 " .. value2 .. " 的入队信息", display.COLOR_GREEN, display.COLOR_WHITE, true)
	def.role.autoRun(function()
		net.send({
			CM_CORPS_MEMBER_LIST,
			tag = 30,
			series = 0,
			recog = 0
		}, nil, {
			{
				"ID",
				g_data.guild.clanInfo:get("corpsID")
			}
		})
	end, 0.5)
	def.role.autoRun(function()
		local value4 = g_data.guild.corpsMem or {}

		for _, item in ipairs(value4) do
			if item:get("name") == value2 then
				net.send({
					CM_CORPS_DISMISS_MEMBER
				}, nil, {
					{
						"ID",
						item:get("ID")
					}
				})
				def.role.sendCM("@joinCorps~" .. value2 .. "~" .. g_data.guild.clanInfo:get("corpsName"))
			end
		end
	end, 1)
	def.role.autoRun(function()
		net.send({
			CM_CORPS_QUERY_REQUESTS,
			tag = 30,
			series = 0
		})
		def.role.autoRun(function()
			local value5 = g_data.guild.corpsQueryMem or {}
			local enabled = false

			for _2, item2 in ipairs(value5) do
				if item2:get("name") == value2 then
					net.send({
						CM_CORPS_ACCEPT_REQUEST,
						param = 1
					}, nil, {
						{
							"ID",
							item2:get("ID")
						}
					})
					net.send({
						CM_CORPS_QUERY_REQUESTS,
						tag = 30,
						series = 0
					})
					common.addMsg("检验通过，" .. value2 .. " 已加入本战队", display.COLOR_GREEN, display.COLOR_WHITE, true)

					enabled = true
				end
			end

			if not enabled then
				common.addMsg("检验失败，" .. value2 .. " 不在线或未响应，从战队移除。", display.COLOR_RED, display.COLOR_WHITE, true)
			end
		end, 2)
	end, 2)
end

function guild:clickCheck(sender)
	if not g_data.client:checkLastTime("guild", sender or 3) then
		main_scene.ui:tip("操作太快", cc.c3b(255, 255, 0))

		return false
	end

	g_data.client:setLastTime("guild", true)

	return true
end

function guild:cleanSubNode()
	if #self.needClean > 0 then
		for _, needClean2 in ipairs(self.needClean) do
			needClean2.removeSelf(needClean2)
		end
	end

	self.acInput = nil
	self.needClean = {}
	self.chatViewGuild = nil
end

function guild:showContent(page, ...)
	self.page = page

	if self.content then
		self.content:removeSelf()

		self.subContent = nil
	end

	self.content = display.newNode():addto(self)

	self.content:size(self.getw(self), self.geth(self))

	if page == "tguild" then
		if g_data.guild.guildInfo then
			self.bg:setTex(res.gettex2("pic/common/black_0.png"))
			self.showContentGuild(self, self.content, ...)
		else
			self.bg:setTex(res.gettex2("pic/common/black_2.png"))

			if not g_data.guild.getguildList then
				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})
			end

			if not g_data.guild.guildInfo then
				net.send({
					CM_PLAYER_GILD
				})
			end

			g_data.guild.getguildList = false
			self.subpage = nil
		end
	elseif page == "clan" then
		if g_data.guild.clanInfo then
			self.bg:setTex(res.gettex2("pic/common/black_0.png"))
			self.showContentClan(self, self.content, ...)
		else
			self.bg:setTex(res.gettex2("pic/common/black_2.png"))
			net.send({
				CM_CORPS_LIST,
				param = 0,
				tag = 7
			})

			self.subpage = nil
		end
	end
end

function guild:uirefushContent(page)
	self.page = page

	if self.content then
		self.content:removeSelf()

		self.subContent = nil
	end

	self.content = display.newNode():addto(self)

	self.content:size(self.getw(self), self.geth(self))

	if page == "tguild" then
		if g_data.guild.guildInfo then
			self.bg:setTex(res.gettex2("pic/common/black_0.png"))
			self.showContentGuild(self, self.content)
		else
			self.bg:setTex(res.gettex2("pic/common/black_2.png"))
			self.showContentGuildNil(self, self.content)

			g_data.guild.getguildList = false
			self.subpage = nil
		end
	elseif page == "clan" then
		if g_data.guild.clanInfo then
			self.bg:setTex(res.gettex2("pic/common/black_0.png"))
			self.showContentClan(self, self.content)
		else
			self.bg:setTex(res.gettex2("pic/common/black_2.png"))
			self.showContentClanNil(self, self.content)

			g_data.guild.getCorpsList = false
			self.subpage = nil
		end
	end
end

function guild:showContentClanNil(data, ...)
	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(data)
	local items2 = {
		150,
		150,
		150,
		60,
		96
	}
	local items3 = {
		"战队名",
		self.corpsTitle .. "名",
		self.corpsTitle .. "行会",
		"人数",
		"状态"
	}
	local x = 4

	for index2, item2 in ipairs(items2) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x + item2 * 0.5, background2.geth(background2) - 23):add2(background2)
		an.newLabel(items3[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item2 * 0.5, background2.geth(background2) - 23):add2(background2)

		x = x + item2
	end

	local items = g_data.guild.corpsList

	if #items == 0 then
		an.newLabel("附近没有其他战队玩家", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(background2.getw(background2) / 2, background2.geth(background2) / 2):add2(background2, 2)
	end

	local scroll = an.newScroll(4, 4, 608, 288):add2(background2)
	local y = 42

	scroll.setScrollSize(scroll, 608, math.max(288, #items * y))
	scroll.enableTouch(scroll, false)
	scroll.enableClick(scroll, function()
		return
	end)

	local value2
	local value3
	local value13
	local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if not value3 then
			return
		end

		self.curSelectCorps = value3:get("corpsID")

		if g_data.guild.curApplyclan == self.curSelectCorps then
			an.newMsgbox(string.format("是否取消对战队 %s 的申请吗？", value3:get("corpsName")), function(value10)
				if value10 == 1 then
					net.send({
						CM_CORPS_CANCEL_JOIN
					}, nil, {
						{
							"ID",
							self.curSelectCorps
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		else
			net.send({
				CM_CORPS_GET_RECRUIT_CONDITION
			}, nil, {
				{
					"ID",
					value3:get("corpsID")
				}
			})
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/jrzd.png")
	}):add2(data):anchor(0.5, 0.5):pos(580, 38)

	for index, item in ipairs(items) do
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local info2 = {}
		local value4 = g_data.player:fixStrLen(item.get(item, "corpsName"), 8)

		info2[#info2 + 1] = an.newLabel(value4, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(75, y * 0.5)

		local value5 = g_data.player:fixStrLen(item.get(item, "captainName"), 8)

		info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(225, y * 0.5)

		local value6 = g_data.player:fixStrLen(item.get(item, "gildName"), 8)

		info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(375, y * 0.5)

		local value7 = item.get(item, "memberCount")

		info2[#info2 + 1] = an.newLabel(value7, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(480, y * 0.5)

		local value8 = g_data.guild.curApplyclan and item.get(item, "corpsID") == g_data.guild.curApplyclan and "申请中" or ""

		info2[#info2 + 1] = an.newLabel(value8, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(554, y * 0.5)

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value11 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value11) <= 5 then
					if value2 then
						for _2, info3 in ipairs(value2.info) do
							info3.setColor(info3, def.colors.cellNor)
						end

						value2:removeSelf()

						value2 = nil
					end

					value3 = item
					value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background)
					value2.info = info2

					for _3, item4 in ipairs(info2) do
						item4.setColor(item4, def.colors.cellSel)
					end

					if g_data.guild.curApplyclan and item:get("corpsID") == g_data.guild.curApplyclan then
						btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
					else
						btn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
					end
				end
			end
		end)

		local value9 = cc.EventListenerCustom:create("UpdateNilClanState", function()
			if g_data.guild.curApplyclan and item:get("corpsID") == g_data.guild.curApplyclan then
				info2[5]:setString("申请中")
			else
				info2[5]:setString("")
			end

			if item:get("corpsID") == value3:get("corpsID") then
				if g_data.guild.curApplyclan == item:get("corpsID") then
					btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
				else
					btn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
				end
			end
		end)

		background.getEventDispatcher(background):addEventListenerWithSceneGraphPriority(value9, background)

		if index == 1 then
			value3 = item
			value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background)
			value2.info = info2

			for _, item3 in ipairs(info2) do
				item3.setColor(item3, def.colors.cellSel)
			end

			if g_data.guild.curApplyclan and item.get(item, "corpsID") == g_data.guild.curApplyclan then
				btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
			else
				btn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
			end
		end
	end

	local label2

	label2 = an.newInput(0, 0, 196, 40, 7, {
		label = {
			self.filterString or "",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"输入战队关键字      ",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function()
			if label2:getString() == "" then
				net.send({
					CM_CORPS_LIST,
					param = 0,
					tag = 7
				})

				self.filterString = nil

				return
			end

			self.filterString = label2:getString()

			net.send({
				CM_FIND_CORPS_BYNAME
			}, {
				label2:getString()
			})
		end
	}):add2(data):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local value12 = g_data.guild.page

		if g_data.guild.serach then
			-- block empty
		end

		local param3 = value12 + 1

		net.send({
			CM_CORPS_LIST,
			tag = 7,
			param = param3
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):add2(data):anchor(0.5, 0.5):pos(480, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local param2 = g_data.guild.page - 1

		if param2 < 0 then
			self:showError(30)

			return
		end

		if param2 < 0 then
			param2 = 0
		end

		net.send({
			CM_CORPS_LIST,
			tag = 7,
			param = param2
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):add2(data):anchor(0.5, 0.5):pos(380, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if g_data.guild.page == 0 and not g_data.guild.serach then
			self:showError(30)

			return
		end

		net.send({
			CM_CORPS_LIST,
			param = 0,
			tag = 7
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/sy.png")
	}):add2(data):anchor(0.5, 0.5):pos(280, 38)
end

function guild:showContentGuildNil(data, ...)
	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(data)
	local items2 = {
		200,
		200,
		124,
		82
	}
	local items3 = {
		"行会名",
		self.guildTitle,
		"战队数",
		"状态"
	}
	local x = 4

	for index2, item3 in ipairs(items2) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item3 + 2, 42)):anchor(0.5, 0.5):pos(x + item3 * 0.5, background2.geth(background2) - 23):add2(background2)
		an.newLabel(items3[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item3 * 0.5, background2.geth(background2) - 23):add2(background2)

		x = x + item3
	end

	local items = g_data.guild.guildList

	local function callback(self2, value11)
		if value11 == ccui.PageViewEventType.turning then
			local text = string.format("page %d", pageView:getCurPageIdx() + 1)

			print(text)
		end
	end

	if #items == 0 then
		an.newLabel("当前无行会", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(background2.getw(background2) / 2, background2.geth(background2) / 2):add2(background2, 2)
	end

	local scroll = an.newScroll(4, 4, 608, 288):add2(background2)
	local y = 42

	scroll.setScrollSize(scroll, 608, math.max(288, #items * y))
	scroll.enableTouch(scroll, false)
	scroll.enableClick(scroll, function()
		return
	end)

	local value2
	local value4
	local value16
	local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if not value4 then
			main_scene.ui:fadeLabel("请先选择行会!")

			return
		end

		if not g_data.guild:isLeader() then
			main_scene.ui:fadeLabel("请先加入战队，再申请加入行会!")

			return
		end

		self.curApplyguild = value4:get("guildID")

		local value12 = g_data.guild.guildList
		local text2 = ""
		local value3
		local value5

		for _2, item2 in ipairs(value12) do
			if g_data.guild.curApplyguild and item2.get(item2, "guildID") == g_data.guild.curApplyguild then
				value3 = item2.get(item2, "gildName")
			end

			if item2.get(item2, "guildID") == self.curApplyguild then
				value5 = item2.get(item2, "gildName")
			end
		end

		if g_data.guild.curApplyguild then
			print("g_data.guild.curApplyclan", g_data.guild.curApplyguild)

			if g_data.guild.curApplyguild == self.curApplyguild then
				value3 = value3 or ""
				text2 = string.format("您确定取消对行会 %s 的申请吗？", value3)
			else
				value3 = value3 or ""
				value5 = value5 or ""
				text2 = string.format("您确定加入 %s,取消对行会 %s 的申请吗？", value5, value3)
			end
		else
			text2 = string.format("您确定申请加入行会 %s 吗？", value5)
		end

		an.newMsgbox(text2, function(value13)
			if value13 == 1 then
				if self.curApplyguild == g_data.guild.curApplyguild then
					net.send({
						CM_GILD_CANCEL_JOIN
					})
				else
					net.send({
						CM_GILD_REQUEST_JOIN
					}, nil, {
						{
							"ID",
							value4:get("guildID")
						}
					})
				end
			end
		end, {
			center = true,
			hasCancel = true
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/jrhh.png")
	}):add2(data):anchor(0.5, 0.5):pos(580, 38)

	for index, item in ipairs(items) do
		local info2 = {}
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value6 = g_data.player:fixStrLen(item.get(item, "gildName"), 8)

		info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(100, y * 0.5)

		local value7 = g_data.player:fixStrLen(item.get(item, "presidentName"), 8)

		info2[#info2 + 1] = an.newLabel(value7, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(300, y * 0.5)

		local value8 = item.get(item, "corpsCount")

		info2[#info2 + 1] = an.newLabel(value8, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(460, y * 0.5)

		local value9 = g_data.guild.curApplyguild and item.get(item, "guildID") == g_data.guild.curApplyguild and "申请中" or ""

		info2[#info2 + 1] = an.newLabel(value9, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(556, y * 0.5)

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value14 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value14) <= 5 then
					if value2 then
						for _3, info3 in ipairs(value2.info) do
							info3.setColor(info3, def.colors.cellNor)
						end

						value2:removeSelf()

						value2 = nil
					end

					value4 = item
					value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background)
					value2.info = info2

					for _4, item5 in ipairs(info2) do
						item5.setColor(item5, def.colors.cellSel)
					end

					if g_data.guild.curApplyguild and item:get("guildID") == g_data.guild.curApplyguild then
						btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
					else
						btn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
					end
				end
			end
		end)

		local value10 = cc.EventListenerCustom:create("UpdateNilGuildState", function()
			if g_data.guild.curApplyguild and item:get("guildID") == g_data.guild.curApplyguild then
				info2[4]:setString("申请中")
			else
				info2[4]:setString("")
			end

			if item:get("guildID") == value4:get("guildID") then
				if g_data.guild.curApplyguild == item:get("guildID") then
					btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
				else
					btn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
				end
			end
		end)

		background.getEventDispatcher(background):addEventListenerWithSceneGraphPriority(value10, background)

		if index == 1 then
			value4 = item
			value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background)
			value2.info = info2

			for _, item4 in ipairs(info2) do
				item4.setColor(item4, def.colors.cellSel)
			end

			if g_data.guild.curApplyguild and item.get(item, "guildID") == g_data.guild.curApplyguild then
				btn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
			else
				btn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
			end
		end
	end

	local label2

	label2 = an.newInput(0, 0, 196, 40, 7, {
		label = {
			self.filterString or "",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"输入行会关键字      ",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function()
			if label2:getString() == "" then
				self.filterString = nil

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})

				return
			end

			self.filterString = label2:getString()

			net.send({
				CM_FIND_GILD_BYNAME
			}, {
				label2:getString()
			})
		end
	}):add2(data):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local value15 = g_data.guild.page

		if g_data.guild.serach then
			-- block empty
		end

		local param3 = value15 + 1

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = param3
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):add2(data):anchor(0.5, 0.5):pos(480, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local param2 = g_data.guild.page - 1

		if param2 < 0 and not g_data.guild.serach then
			self:showError(30)

			return
		end

		if param2 < 0 then
			param2 = 0
		end

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = param2
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):add2(data):anchor(0.5, 0.5):pos(380, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if g_data.guild.page == 0 and not g_data.guild.serach then
			self:showError(30)

			return
		end

		net.send({
			CM_GILD_LIST,
			param = 0,
			tag = 7
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/sy.png")
	}):add2(data):anchor(0.5, 0.5):pos(280, 38)
end

function guild:showContentClan(data, ...)
	local items = {
		"clanmain",
		"clanmem",
		"clanjobs",
		"clanlog"
	}

	if main_scene.ground:smr() then
		items = {
			"clanmain",
			"clanmem",
			"clanjobs"
		}
	end

	local items2 = {}

	local function callback(subpage)
		sound.playSound("103")

		for _, item in ipairs(items2) do
			if item == subpage then
				item.select(item)
			else
				item.unselect(item)
			end

			if subpage.page ~= self.subpage then
				self.subpage = subpage.page

				self:showSub(subpage.page, data, true)
			end
		end
	end

	for index, page in ipairs(items) do
		items2[index] = an.newBtn(res.gettex2("pic/common/btn60.png"), callback, {
			support = "easy",
			sprite = res.gettex2("pic/panels/guild/" .. page .. "_n.png"),
			anchor = {
				0.5,
				0.5
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(data):anchor(0, 0.5):pos(18, 370 - (index - 1) * 54)
		items2[index].page = page
	end

	items2[1]:select()

	self.subpage = items[1]

	self.showSub(self, items[1], data, true)
end

function guild:showContentGuild(data, ...)
	local items = {
		"guildmain",
		"mem",
		"claninfo",
		"clanrecruit",
		"diplomatic",
		"log"
	}

	if main_scene.ground:smr() then
		items = {
			"guildmain",
			"mem",
			"claninfo",
			"clanrecruit",
			"diplomatic"
		}
	end

	local items2 = {}

	local function cleanup(subpage)
		sound.playSound("103")

		for _, item in ipairs(items2) do
			if item == subpage then
				item.select(item)
			else
				item.unselect(item)
			end

			if subpage.page ~= self.subpage then
				self.subpage = subpage.page

				self:showSub(subpage.page, data, true)
			end
		end
	end

	for index, page in ipairs(items) do
		items2[index] = an.newBtn(res.gettex2("pic/common/btn60.png"), cleanup, {
			support = "easy",
			sprite = res.gettex2("pic/panels/guild/" .. page .. "_n.png"),
			anchor = {
				0.5,
				0.5
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(data):anchor(0, 0.5):pos(18, 370 - (index - 1) * 54)
		items2[index].page = page
	end

	self.subpage = items[1]

	items2[1]:select()
	self.showSub(self, items[1], data, true)
end

function guild:showSub(data, options2, options)
	options2 = options2 or self.content
	self.threeSub = 0

	if self.subContent then
		self.subContent:removeSelf()
	end

	self.pageNode = nil

	self.bg:setTex(res.gettex2("pic/common/black_0.png"))

	self.subContent = cc.Node:create()

	self.subContent:size(486, 344):anchor(0, 0):pos(138, 60):add2(options2)

	if data == "clanmain" then
		if options then
			net.send({
				CM_CORPS_NOTICE,
				tag = 0
			})
			net.send({
				CM_REFRESH_CORPSINFO
			})
		end

		self.showSubClanmain(self, self.subContent)
	elseif data == "clanmem" then
		if options then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end

		self.showSubClanmem(self, self.subContent)
	elseif data == "clanjobs" then
		if options then
			net.send({
				CM_CORPS_QUERY_REQUESTS,
				tag = 30,
				series = 0
			})
		end

		self.showSubClanjobs(self, self.subContent)
	elseif data == "clanlog" then
		if options then
			net.send({
				CM_CORPS_QUERY_LOG,
				tag = 0,
				series = 30,
				param = 1
			})
		end

		self.showSubClanlog(self, self.subContent)
	elseif data == "guildmain" then
		if options then
			net.send({
				CM_GILD_NOTICE,
				tag = 0
			})
			net.send({
				CM_REFRESH_GILDINFO
			})
		end

		self.showSubGuildmain(self, self.subContent)
	elseif data == "mem" then
		if options then
			net.send({
				CM_GILDMEMBER_LIST
			})
		end

		self.showSubMem(self, self.subContent)
	elseif data == "claninfo" then
		if options then
			net.send({
				CM_GILD_QUERY_CORPS
			})
		end

		self.showSubClaninfo(self, self.subContent)
	elseif data == "clanrecruit" then
		if options then
			net.send({
				CM_GILD_QUERY_REQUEST_JOIN_LIST,
				tag = 30,
				series = 0
			})
		end

		self.showSubClanrecruit(self, self.subContent)
	elseif data == "diplomatic" then
		self.showSubDiplomatic(self, self.subContent)
	elseif data == "log" then
		if options then
			net.send({
				CM_GILD_QUERY_LOG,
				tag = 0,
				series = 30,
				param = 1
			})
		end

		self.showSubLog(self, self.subContent)
	end
end

function guild:refush(value2)
	if self.subpage ~= value2 then
		return
	end

	self.showSub(self, value2)
end

function guild:recruitCondition(value15, value9, value6)
	if getRecordSize("TRecruitCondition") ~= value6 then
		return
	end

	if not g_data.guild.clanInfo and not self.curSelectCorps then
		return
	end

	local record = getRecord("TRecruitCondition")

	net.record(record, value9, value6)

	local value16
	local label3
	local label2
	local items = {}
	local value4 = record.get(record, "job") or 0
	local items3 = {
		ycFunction:band(ycFunction:rshift(value4, 0), 1) == 1,
		ycFunction:band(ycFunction:rshift(value4, 1), 1) == 1,
		ycFunction:band(ycFunction:rshift(value4, 2), 1) == 1
	}
	local msgbox = an.newMsgbox("", function(value10)
		if value10 == 1 then
			if g_data.guild.clanInfo then
				local number = tonumber(label2:getString())

				if not number or number < 0 then
					main_scene.ui:fadeLabel("请输入正确的数字！")

					return
				end

				local count = 0

				for index2 = 1, 3 do
					if items3[index2] then
						count = count + ycFunction:lshift(1, index2 - 1)

						print(ycFunction:lshift(1, index2 - 1))
					end
				end

				local record2 = getRecord("TRecruitCondition")

				record2.set(record2, "notice", label3:getString())
				record2.set(record2, "level", tonumber(label2:getString()))
				record2.set(record2, "job", count)
				dump(record2)
				net.send({
					CM_CORPS_SET_RECRUIT_CONDITION
				}, nil, record2)
			else
				local value11 = g_data.guild.corpsList
				local text = ""
				local value2
				local value3

				for _, item in ipairs(value11) do
					if g_data.guild.curApplyclan and item.get(item, "corpsID") == g_data.guild.curApplyclan then
						value2 = item.get(item, "corpsName")
					end

					if item.get(item, "corpsID") == self.curSelectCorps then
						value3 = item.get(item, "corpsName")
					end
				end

				if g_data.guild.curApplyclan then
					if g_data.guild.curApplyclan == self.curSelectCorps then
						value2 = value2 or ""
						text = string.format("您确定取消行会%s的申请吗?", value2)
					else
						value2 = value2 or ""
						value3 = value3 or ""
						text = string.format("您确定加入 %s,取消对行会 %s 的申请吗？", value3, value2)
					end
				else
					text = string.format("您确定申请加入行会 %s 吗？", value3)
				end

				an.newMsgbox(text, function(value12)
					local value13 = g_data.player.ability:get("level")

					if self.curSelectCorps == g_data.guild.curApplyclan and value13 < record:get("level") then
						main_scene.ui:fadeLabel("您的等级过低")

						return
					end

					local diy = cache.getDiy("sys", "quitcorps" .. common.getPlayerName())

					if diy then
						local value14 = g_data.login.serverTime or socket.gettime()
						local value7 = def.joinCorpsNeedTime or 0
						local value8 = value14 - diy

						if value8 < value7 then
							local value5 = value7 - value8
							local text2 = ""

							if value5 > 3600 then
								text2 = string.format("加入失败，需等待 %s 小时后才能加入新战队。", tostring(math.floor(value5 / 3600)))
							else
								text2 = string.format("加入失败，需等待 %s 秒后才能加入新战队。", tostring(math.floor(value5)))
							end

							an.newMsgbox(text2, function(value17)
								return
							end, {
								center = true,
								hasCancel = false
							})

							return
						end
					end

					if value12 == 1 then
						net.send({
							self.curSelectCorps == g_data.guild.curApplyclan and CM_CORPS_CANCEL_JOIN or CM_CORPS_REQUEST_JOIN
						}, nil, {
							{
								"ID",
								self.curSelectCorps
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end
	end, {
		disableScroll = true,
		center = true,
		hasCancel = true
	})
	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(msgbox.bg:getw() - 40, 40)):anchor(0.5, 0.5):pos(msgbox.bg:getw() / 2, msgbox.bg:geth() - 80):add2(msgbox.bg, 2)

	if not g_data.guild.clanInfo then
		an.newLabel(record.get(record, "notice"), 20, 1, {
			color = def.colors.labelGray
		}):addTo(background2):anchor(0, 0.5):pos(10, background2.geth(background2) / 2)
	else
		label3 = an.newInput(10, background2.geth(background2) / 2, msgbox.bg:getw() - 40, 40, 18, {
			tip = {
				"点击编辑公告(最多18个字)",
				20,
				1
			},
			label = {
				record.get(record, "notice"),
				20
			}
		}):addTo(background2):anchor(0, 0.5)
	end

	local background = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(40, 40)):anchor(0.5, 0.5):pos(148, 150):add2(msgbox.bg, 2)

	if not g_data.guild.clanInfo then
		an.newLabel("等级限制:            级以上", 20, 1, {
			color = def.colors.labelGray
		}):add2(msgbox.bg, 2):anchor(0, 0.5):pos(30, 150)
		an.newLabel("" .. record.get(record, "level"), 20, 1, {
			color = def.colors.labelGray
		}):add2(background, 2):anchor(0.5, 0.5):pos(background.getw(background) * 0.5, background.geth(background) * 0.5)
	else
		an.newLabel("等级限制:            级以上", 20, 1, {
			color = def.colors.labelGray
		}):add2(msgbox.bg, 2):anchor(0, 0.5):pos(30, 150)

		label2 = an.newInput(8, background.geth(background) / 2, 40, 40, 2, {
			label = {
				"" .. record.get(record, "level"),
				20
			}
		}):addTo(background):anchor(0, 0.5)
	end

	an.newLabel("职业限制:", 20, 1, {
		color = def.colors.labelGray
	}):add2(msgbox.bg, 2):anchor(0, 0.5):pos(30, 100)

	local function cleanup(self2)
		items3[self2] = not items3[self2]

		items[self2]:setIsSelect(items3[self2])
	end

	local items2 = {
		"战士",
		"法师",
		"道士"
	}

	for index = 1, #items2 do
		local btn = an.newBtn(res.gettex2("pic/common/toggle10.png"), function()
			cleanup(index)
		end, {
			support = "easy",
			select = {
				res.gettex2("pic/common/toggle11.png"),
				manual = true
			}
		}):anchor(0.5, 0.5):pos(index * 90 + 60, 100):add2(msgbox.bg)

		btn.setIsSelect(btn, items3[index])

		if not g_data.guild.clanInfo then
			btn.setTouchEnabled(btn, false)
		end

		items[#items + 1] = btn

		an.newLabel(items2[index], 20, 1, {
			color = cc.c3b(255, 255, 255)
		}):anchor(0.5, 0.5):pos(index * 90 + 104, 100):add2(msgbox.bg)
	end
end

function guild:showSubClanmain(data)
	data.size(data, 486, 236)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):addto(data):anchor(0, 0):pos(2, 238):size(data.getw(data), 106)
	res.get2("pic/panels/guild/signboard_bg.png"):anchor(0, 0):pos(4, 242):addto(data)
	an.newLabel(g_data.guild.clanInfo and (g_data.guild.clanInfo:get("corpsName") or "") or "", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, 302):add2(data)
	an.newLabel("队员:", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(1, 0.5):pos(data.getw(data) * 0.5, 264):add2(data)
	an.newLabel(g_data.guild.clanInfo and g_data.guild.clanInfo:get("onlineCount") .. "/" .. g_data.guild.clanInfo:get("memberCount") or "1/30", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0, 0.5):pos(data.getw(data) * 0.5 + 4, 264):add2(data)

	local value2
	local items = {
		g_data.guild.clanNotice
	}
	local label2 = an.newLabel("", 18, 0)

	for index2 = 1, 5 do
		-- block empty
	end

	items[#items + 1] = "\r\n"

	function refush(self2)
		if value2 then
			value2:removeSelf()

			value2 = nil
		end

		value2 = an.newScroll(8, 8, 470, 220):add2(data)

		if items[#items] ~= "\r\n" then
			items[#items + 1] = "\r\n"
		end

		local items2 = {}
		local count = 0
		local label3
		local value3

		for index, item2 in ipairs(items) do
			local size2 = cc.LabelTTF:create(item2, "", 18, cc.size(470, 0), 0)

			size2.anchor(size2, 0, 1)

			items2[#items2 + 1] = size2
			count = count + size2.getContentSize(size2).height

			if self2 then
				size2.setTouchEnabled(size2, true)
				size2.setTouchSwallowEnabled(size2, false)
				size2.addNodeEventListener(size2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
					if offsetBeginY.name == "began" then
						size2.offsetBeginY = offsetBeginY.y

						return true
					elseif offsetBeginY.name == "ended" then
						local value4 = offsetBeginY.y - size2.offsetBeginY

						if math.abs(value4) <= 5 then
							if label3 then
								items[value3] = label3:getText()

								items2[value3]:setString(label3:getText())
								label3:removeSelf()

								label3 = nil
								value3 = nil

								refush(true)

								return
							end

							value3 = index
							label3 = an.newInput(size2:getPositionX(), size2:getPositionY(), 470, 24, 500, {
								label = {
									string.gsub(item2, "\r\n", ""),
									18,
									1
								},
								bg = {
									h = 24,
									tex = res.gettex2("pic/scale/edit1.png"),
									offset = {
										-3,
										4
									}
								},
								stop_call = function()
									local text2 = label3:getText()

									if text2 == "" then
										text2 = "\r\n"
									end

									items[index] = text2

									size2:setString(text2)
									label3:removeSelf()

									label3 = nil
									value3 = nil

									refush(true)
								end
							}):add2(value2):anchor(0, 1)
						end
					end
				end)
			end
		end

		value2:setScrollSize(470, math.max(220, count))

		local count2 = 0

		for _, item in ipairs(items2) do
			item.pos(item, 0, value2:getScrollSize().height - count2):add2(value2)

			count2 = count2 + item.getContentSize(item).height
		end
	end

	refush()
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if g_data.guild:isPresident() then
			main_scene.ui:fadeLabel(string.format("行会%s不能退出战队", self.guildTitle))

			return
		end

		if g_data.guild:isVicePresident() or g_data.guild:isLeader() then
			main_scene.ui:fadeLabel(string.format("需转让%s之后才能退出战队", self.corpsTitle))

			return
		end

		local text3 = def.joinCorpsNeedTime or 86400
		local text5 = ""

		if text3 > 3600 then
			text5 = string.format("您确定退出战队吗？退出后需要等待【%s】小时后才能加入新战队。", tostring(math.floor(text3 / 3600)))
		else
			text5 = string.format("您确定退出战队吗？退出后需要等待【%s】秒才能加入新战队。", tostring(text3))
		end

		an.newMsgbox(text5, function(value5)
			if value5 == 1 then
				net.send({
					CM_CORPS_EXIT
				})
			end

			local value6 = g_data.login.serverTime or socket.gettime()

			cache.saveDiy("sys", "quitcorps" .. common.getPlayerName(), value6)
		end, {
			center = true,
			hasCancel = true
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/tczd.png")
	}):add2(data):anchor(0.5, 0.5):pos(442, -22)

	if g_data.guild:isLeader() then
		local btn2
		local btn

		btn2 = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			refush(true)
			btn2:hide()
			btn:show()
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bjgg.png")
		}):add2(data):anchor(0.5, 0.5):pos(342, -22)
		btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			refush(false)
			btn:hide()
			btn2:show()

			local text4 = ""

			for _2, text in ipairs(items) do
				text = string.gsub(text, "\r\n", "")
				text4 = text4 .. text .. "\r\n"
			end

			print(text4)
			net.send({
				CM_CORPS_NOTICE,
				tag = 1
			}, {
				text4
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bcgg.png")
		}):add2(data):anchor(0.5, 0.5):pos(342, -22)

		btn.hide(btn)
	end
end

function guild:showSubClanmem(data)
	local items4 = {
		140,
		60,
		60,
		60,
		60,
		100
	}
	local items = {
		"角色名",
		CS_LEVEL,
		CS_JOB,
		"性别",
		"职务",
		"封号"
	}
	local x2 = 6
	local value2 = g_data.guild.corpsMem or {}
	local value4
	local value3
	local items2 = {
		"",
		"副队长",
		"队长",
		"副会长",
		"会长"
	}

	if def.corpsSets and def.corpsSets.openCusShow and def.corpsSets.posTitle then
		items2 = def.corpsSets.posTitle
	end

	local scroll
	local y = 42

	local function cleanup(self2)
		if scroll then
			scroll:removeSelf()
		end

		scroll = an.newScroll(7, 8, 480, 292):add2(data)

		scroll:setScrollSize(480, math.max(292, #self2 * y))

		for index2, item in ipairs(self2) do
			local info2 = {}
			local color2 = item.get(item, "status") == 1 and cc.c3b(255, 255, 255) or def.colors.cellOffline
			local cell = display.newNode():size(480, y):anchor(0, 0):pos(0, scroll:getScrollSize().height - index2 * y):add2(scroll)

			cell.scale = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):add2(cell)

			local value5 = g_data.player:fixStrLen(item.get(item, "name"), 8)

			info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(70, y * 0.5)

			local value6 = item.get(item, "level")

			info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(170, y * 0.5)

			local otherJobStr = g_data.player:getOtherJobStr(item.get(item, "job"))

			info2[#info2 + 1] = an.newLabel(otherJobStr, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(230, y * 0.5)

			local value7 = item.get(item, "six") == 0 and "男" or "女"

			info2[#info2 + 1] = an.newLabel(value7, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(290, y * 0.5)

			local value8 = items2[item.get(item, "position") + 1] or ""

			info2[#info2 + 1] = an.newLabel(value8, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(350, y * 0.5)

			local value9 = item.get(item, "title")

			info2[#info2 + 1] = an.newLabel(value9, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(425, y * 0.5)

			cell.setTouchEnabled(cell, true)
			cell.setTouchSwallowEnabled(cell, false)
			cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					cell.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value10 = offsetBeginY.y - cell.offsetBeginY

					if math.abs(value10) <= 5 then
						if value4 then
							for _2, info3 in ipairs(value4.info) do
								info3.setColor(info3, value4.color or def.colors.cellOffline)
							end

							value4:removeSelf()

							value4 = nil
						end

						value3 = item
						value4 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, 0):add2(cell)
						value4.info = info2
						value4.color = color2

						for _3, item4 in ipairs(info2) do
							item4.setColor(item4, def.colors.cellSel)
						end
					end
				end
			end)

			if index2 == 1 then
				value3 = item
				value4 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, 0):add2(cell)
				value4.info = info2
				value4.color = color2

				for _, item3 in ipairs(info2) do
					item3.setColor(item3, def.colors.cellSel)
				end
			end

			item.info = info2
			item.cell = cell
		end
	end

	local items3 = {
		function(value11, value12)
			return self:sortName(value11, value12)
		end,
		function(value13, value14)
			return self:sortLevel(value13, value14)
		end,
		function(value15, value16)
			return self:sortJob(value15, value16)
		end,
		function(value17, value18)
			return self:sortSex(value17, value18)
		end,
		function(value19, value20)
			return self:sortTitle(value19, value20)
		end,
		function(value21, value22)
			return self:sortString(value21, value22)
		end
	}
	local count2 = 1
	local count = 0

	for index, item2 in ipairs(items4) do
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x2 + item2 * 0.5, data.geth(data) - 23):add2(data)

		items[index] = an.newLabel(items[index], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x2 + item2 * 0.5, data.geth(data) - 23):add2(data)
		x2 = x2 + item2

		background.enableClick(background, function()
			if count2 == index then
				count = count + 1
				value2 = items3[index](value2, count % 2 == 0)
			else
				count = 0
				value2 = items3[index](value2, true)
			end

			value2 = self:sortOnline(value2)

			cleanup(value2)

			count2 = index
		end)
	end

	value2 = self.sortName(self, value2, true)
	value2 = self.sortOnline(self, value2)

	cleanup(value2)

	local x = 0

	if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value3 then
				return
			end

			if value3:get("name") == common.getPlayerName() then
				main_scene.ui:fadeLabel("不能操作自己")

				return
			end

			an.newMsgbox(string.format("您确定将 %s 逐出战队吗？", value3:get("name")), function(value23)
				if value23 == 1 then
					net.send({
						CM_CORPS_DISMISS_MEMBER
					}, nil, {
						{
							"ID",
							value3:get("ID")
						}
					})

					if g_data.guild.clanInfo then
						net.send({
							CM_CORPS_MEMBER_LIST,
							tag = 30,
							series = 0,
							recog = 0
						}, nil, {
							{
								"ID",
								g_data.guild.clanInfo:get("corpsID")
							}
						})
					end

					common.addMsg(value3:get("name") .. " 已逐出战队。", display.COLOR_GREEN, display.COLOR_WHITE, true)
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zczd.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value3 then
				return
			end

			local msgbox

			msgbox = an.newMsgbox("", function(value24)
				if value24 == 1 then
					if msgbox.nameInput:getString() == "" then
						return
					end

					net.send({
						CM_CORPS_SET_MEMBER_TITLE
					}, nil, {
						{
							"ID",
							value3:get("ID")
						},
						{
							"string",
							def.wordfilter.run(msgbox.nameInput:getString()),
							15
						}
					})
				end
			end, {
				disableScroll = true,
				hasCancel = true
			})
			msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 4, {
				label = {
					"",
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/scale16.png"),
					offset = {
						-10,
						2
					}
				},
				tip = {
					"请输入封号？",
					20,
					1,
					{
						color = cc.c3b(128, 128, 128)
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/szfh.png")
		}):add2(data):anchor(0.5, 0.5):pos(342, -22)

		x = 2
	end

	local x3 = x

	if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			self:showMenu(cc.p(x3 * 100 - 80 + 82, 58), "职务操作", value3)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zwcz.png")
		}):add2(data):anchor(0.5, 0.5):pos(x * 100 - 80, -22)

		x = x + 1
	end

	local x4 = x

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if not value3 then
			return
		end

		self:showMenu(cc.p(x4 * 100 - 80 + 82, 58), "更多操作", value3)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/gdcz.png")
	}):add2(data):anchor(0.5, 0.5):pos(x * 100 - 80, -22)
end

function guild:showSubClanjobs(data)
	local items5 = {
		170,
		90,
		90,
		131
	}
	local items4 = {
		"角色名",
		CS_LEVEL,
		CS_JOB,
		"性别"
	}
	local x = 5

	for index2, item2 in ipairs(items5) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x + item2 * 0.5, data.geth(data) - 23):add2(data)

		items4[index2] = an.newLabel(items4[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item2 * 0.5, data.geth(data) - 23):add2(data)
		x = x + item2
	end

	local items = g_data.guild.corpsQueryMem or {}
	local scroll = an.newScroll(7, 8, 480, 292):add2(data)
	local y = 42

	scroll.setScrollSize(scroll, 472, math.max(288, #items * y))

	local value4 = g_data.guild.clanInfo:get("memberCount") - 30
	local value2
	local value3
	local enabled = false

	for index, item in ipairs(items) do
		local info2 = {}
		local cell = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value5 = g_data.player:fixStrLen(item.get(item, "name"), 8)

		info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(85, y * 0.5)

		local value6 = item.get(item, "level")

		info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(215, y * 0.5)

		local otherJobStr = g_data.player:getOtherJobStr(item.get(item, "job"))

		info2[#info2 + 1] = an.newLabel(otherJobStr, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(305, y * 0.5)

		local value7 = item.get(item, "six") == 0 and "男" or "女"

		info2[#info2 + 1] = an.newLabel(value7, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(410, y * 0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				cell.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value8 = offsetBeginY.y - cell.offsetBeginY

				if math.abs(value8) <= 5 then
					if enabled then
						if item.selectPic then
							for _2, info3 in ipairs(item.info) do
								info3.setColor(info3, def.colors.cellNor)
							end

							item.selectPic:removeSelf()

							item.selectPic = nil
						else
							item.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, 0):add2(item.cell)

							for _3, info4 in ipairs(item.info) do
								info4.setColor(info4, def.colors.cellSel)
							end
						end
					else
						if value2 then
							for _4, info5 in ipairs(value2.info) do
								info5.setColor(info5, def.colors.cellNor)
							end

							value2:removeSelf()

							value2 = nil
						end

						value3 = item
						value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, 0):add2(cell)
						value2.info = info2

						for _5, item8 in ipairs(info2) do
							item8.setColor(item8, def.colors.cellSel)
						end
					end
				end
			end
		end)

		if index == 1 then
			value3 = item
			value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, 0):add2(cell)
			value2.info = info2

			for _, item7 in ipairs(info2) do
				item7.setColor(item7, def.colors.cellSel)
			end
		end

		item.cell = cell
		item.info = info2
	end

	if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(value9)
			enabled = value9

			if enabled then
				if value2 then
					for _6, info6 in ipairs(value2.info) do
						info6.setColor(info6, def.colors.cellNor)
					end

					value2:removeSelf()

					value2 = nil
					value3 = nil
				end

				value4 = g_data.guild.clanInfo:get("memberCount") - 30

				for _7, item4 in ipairs(items) do
					item4.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, 0):add2(item4.cell)

					for _8, info7 in ipairs(item4.info) do
						info7.setColor(info7, def.colors.cellSel)
					end

					value4 = value4 - 1

					if value4 <= 0 then
						break
					end
				end
			else
				for _9, item3 in ipairs(items) do
					if item3.selectPic then
						for _10, info8 in ipairs(item3.info) do
							info8.setColor(info8, def.colors.cellNor)
						end

						item3.selectPic:removeSelf()

						item3.selectPic = nil
					end
				end
			end
		end, {
			easy = true,
			label = {
				"全部选中",
				20,
				1,
				{
					color = def.colors.labelGray
				}
			}
		}):anchor(0, 0.5):pos(-110, -28):add2(data, 2)

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if enabled then
				an.newMsgbox("您确定拒绝所有进入战队的申请吗？", function(value10)
					if value10 == 1 then
						local items2 = {}

						for _11, item5 in ipairs(items) do
							if item5.selectPic then
								items2[#items2 + 1] = {
									"ID",
									item5.get(item5, "ID")
								}
							end
						end

						net.send({
							CM_CORPS_REFUSE_REQUEST,
							param = #items2
						}, nil, items2)
					end
				end, {
					center = true,
					hasCancel = true
				})
			else
				if not value3 then
					return
				end

				an.newMsgbox(string.format("您确定拒绝 %s 进入战队吗？", value3:get("name")), function(value11)
					if value11 == 1 then
						net.send({
							CM_CORPS_REFUSE_REQUEST,
							param = 1
						}, nil, {
							{
								"ID",
								value3:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/jjzs.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if enabled then
				if self.addClan and def.openADVCopros then
					common.addMsg("暂时不支持批量操作入战队！", display.COLOR_GREEN, display.COLOR_WHITE, true)
				else
					an.newMsgbox("您确定允许所有进入战队的申请吗？", function(value12)
						if value12 == 1 then
							local items3 = {}

							for _12, item6 in ipairs(items) do
								if item6.selectPic then
									items3[#items3 + 1] = {
										"ID",
										item6.get(item6, "ID")
									}
								end
							end

							net.send({
								CM_CORPS_ACCEPT_REQUEST,
								param = #items3
							}, nil, items3)
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			else
				if not value3 then
					return
				end

				an.newMsgbox(string.format("您确定允许 %s 进入战队吗？", value3:get("name")), function(value13)
					if value13 == 1 then
						if self.addClan and def.openADVCopros then
							self:addClan(value3)
						else
							net.send({
								CM_CORPS_ACCEPT_REQUEST,
								param = 1
							}, nil, {
								{
									"ID",
									value3:get("ID")
								}
							})
						end
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/tyzs.png")
		}):add2(data):anchor(0.5, 0.5):pos(342, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			if def.closeMDMJoinCoprs then
				common.addMsg("暂时不支持面对面招收！", display.COLOR_GREEN, display.COLOR_WHITE, true)
			else
				sound.playSound("103")
				net.send({
					CM_CORPS_DIRECT_ADD_MEMBER
				})
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/mdmz.png")
		}):add2(data):anchor(0.5, 0.5):pos(242, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			net.send({
				CM_CORPS_GET_RECRUIT_CONDITION
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zxsz.png")
		}):add2(data):anchor(0.5, 0.5):pos(142, -22)
	end
end

function guild:showSubClanlog(data)
	local maxLine2 = 60

	if main_scene.ground:smr() then
		main_scene.ui:fadeLabel("乱斗模式无法查看日志")

		return
	end

	local scroll = an.newScroll(8, 8, 472, 328, {
		labelM = {
			16,
			params = {
				maxLine = maxLine2
			}
		}
	}):add2(data)
	local value3 = g_data.guild.corpsLog or {}
	local text = ""

	if value3 then
		for _, item in ipairs(value3) do
			local value2 = item:get("logInfo")

			if value2 and value2:find("被逐出战队") == nil and text ~= value2 then
				scroll.labelM:addLabel(value2, def.colors.labelGray):nextLine()

				text = value2
			end
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		self.clanLogType = 1

		net.send({
			CM_CORPS_QUERY_LOG,
			tag = 0,
			series = 30,
			param = 2
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/zzrz.png")
	}):add2(data):anchor(0.5, 0.5):pos(442, -22)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		self.clanLogType = 0

		net.send({
			CM_CORPS_QUERY_LOG,
			tag = 0,
			series = 30,
			param = 1
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/cyrz.png")
	}):add2(data):anchor(0.5, 0.5):pos(342, -22)
end

function guild:showSubGuildmain(data)
	data.size(data, 486, 236)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):addto(data):anchor(0, 0):pos(2, 238):size(data.getw(data), 106)
	res.get2("pic/panels/guild/signboard_bg.png"):anchor(0, 0):pos(4, 242):addto(data)
	an.newLabel(g_data.guild.guildInfo and (g_data.guild.guildInfo:get("gildName") or "") or "", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, 302):add2(data)
	an.newLabel("战队数:", 20, 1, {
		color = def.colors.labelGray
	}):anchor(1, 0.5):pos(data.getw(data) * 0.45, 264):add2(data)
	an.newLabel(g_data.guild.guildInfo and g_data.guild.guildInfo:get("corpsCount") .. "/8" or "1/8", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):pos(data.getw(data) * 0.45 + 4, 264):add2(data)
	an.newLabel("会员数:" .. g_data.guild.guildInfo:get("onlineCount") .. "/" .. g_data.guild.guildInfo:get("playerCount"), 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):pos(data.getw(data) * 0.55, 264):add2(data)

	local value2
	local items = {
		g_data.guild.guildNotice
	}

	for index2 = 1, 5 do
		-- block empty
	end

	items[#items + 1] = "\r\n"

	function refush(self2)
		if value2 then
			value2:removeSelf()

			value2 = nil
		end

		value2 = an.newScroll(8, 8, 470, 220):add2(data)

		if items[#items] ~= "\r\n" then
			items[#items + 1] = "\r\n"
		end

		local items2 = {}
		local count = 0
		local label2
		local value3

		for index, item2 in ipairs(items) do
			local size2 = cc.LabelTTF:create(item2, "", 18, cc.size(470, 0), 0)

			size2.anchor(size2, 0, 1)

			items2[#items2 + 1] = size2
			count = count + size2.getContentSize(size2).height

			if self2 then
				size2.setTouchEnabled(size2, true)
				size2.setTouchSwallowEnabled(size2, false)
				size2.addNodeEventListener(size2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
					if offsetBeginY.name == "began" then
						size2.offsetBeginY = offsetBeginY.y

						return true
					elseif offsetBeginY.name == "ended" then
						local value4 = offsetBeginY.y - size2.offsetBeginY

						if math.abs(value4) <= 5 then
							if label2 then
								items[value3] = label2:getText()

								items2[value3]:setString(label2:getText())
								label2:removeSelf()

								label2 = nil
								value3 = nil

								refush(true)

								return
							end

							value3 = index
							label2 = an.newInput(size2:getPositionX(), size2:getPositionY(), 470, 24, 500, {
								label = {
									string.gsub(item2, "\r\n", ""),
									18,
									1
								},
								bg = {
									h = 24,
									tex = res.gettex2("pic/scale/edit1.png"),
									offset = {
										-3,
										4
									}
								},
								stop_call = function()
									local text2 = label2:getText()

									if text2 == "" then
										text2 = "\r\n"
									end

									items[index] = text2

									size2:setString(text2)
									label2:removeSelf()

									label2 = nil
									value3 = nil

									refush(true)
								end
							}):add2(value2):anchor(0, 1)
						end
					end
				end)
			end
		end

		value2:setScrollSize(470, math.max(220, count))

		local count2 = 0

		for _, item in ipairs(items2) do
			item.pos(item, 0, value2:getScrollSize().height - count2):add2(value2)

			count2 = count2 + item.getContentSize(item).height
		end
	end

	refush()

	if g_data.guild:isPresident() then
		local btn2
		local btn

		btn2 = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			refush(true)
			btn2:hide()
			btn:show()
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bjgg.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)
		btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			refush(false)
			btn:hide()
			btn2:show()

			local text3 = ""

			for _2, text in ipairs(items) do
				text = string.gsub(text, "\r\n", "")
				text3 = text3 .. text .. "\r\n"
			end

			print(text3)
			net.send({
				CM_GILD_NOTICE,
				tag = 1
			}, {
				text3
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bcgg.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)

		btn.hide(btn)

		return
	end

	if g_data.guild:isVicePresident() or g_data.guild:isLeader() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if g_data.guild:isPresident() then
				main_scene.ui:fadeLabel(string.format("你是行会%s，不可退出", self.guildTitle))

				return
			end

			an.newMsgbox(string.format("您确定要退出行会吗？\n%s退出行会将带领战队中所有成员退出行会", self.corpsTitle), function(value5)
				if value5 == 1 then
					net.send({
						CM_GILD_EXIT
					})
				end
			end, {
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/tchh.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)
	end
end

function guild.sortOnline(self2, value2)
	local items = {}

	function insertTable(self)
		for index, item2 in ipairs(items) do
			if item2.get(item2, "status") < self.get(self, "status") then
				table.insert(items, index, self)

				return
			elseif index == #items then
				items[#items + 1] = self

				return
			end
		end
	end

	for index2, item in ipairs(value2) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortOnlineTwo(self2, value2)
	local items = {}

	function insertTable(self)
		for index, item2 in ipairs(items) do
			if self.get(self, "status") <= item2.get(item2, "status") then
				table.insert(items, index, self)

				return
			elseif index == #items then
				table.insert(items, 1, self)

				return
			end
		end
	end

	for index2, item in ipairs(value2) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortString(self2, value4, value5)
	local items = {}
	local value2
	local value3

	function insertTable(self)
		for index, item2 in ipairs(items) do
			value2 = string.len(self.get(self, "title"))
			value3 = string.len(item2.get(item2, "title"))

			if value5 and value3 <= value2 or value2 < value3 then
				table.insert(items, index, self)

				return
			elseif index == #items then
				items[#items + 1] = self

				return
			end
		end
	end

	for index2, item in ipairs(value4) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortName(self2, value4, value5)
	local items = {}
	local value2
	local value3

	function insertTable(self)
		for index, item2 in ipairs(items) do
			value2 = string.len(self.get(self, "name"))
			value3 = string.len(item2.get(item2, "name"))

			if value5 and value3 <= value2 or value2 < value3 then
				table.insert(items, index, self)

				return
			elseif index == #items then
				items[#items + 1] = self

				return
			end
		end
	end

	for index2, item in ipairs(value4) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortLevel(self2, value4, value5)
	local items = {}
	local value2
	local value3

	function insertTable(self)
		for index, item2 in ipairs(items) do
			value2 = self.get(self, "level")
			value3 = item2.get(item2, "level")

			if value5 then
				if value3 <= value2 then
					table.insert(items, index, self)

					return
				elseif index == #items then
					items[#items + 1] = self

					return
				end
			elseif value2 < value3 then
				table.insert(items, index, self)

				return
			elseif index == #items then
				table.insert(items, 1, self)

				return
			end
		end
	end

	for index2, item in ipairs(value4) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortJob(self2, value4, value5)
	local items = {}
	local value2
	local value3

	function insertTable(self)
		for index, item2 in ipairs(items) do
			value2 = self.get(self, "job")
			value3 = item2.get(item2, "job")

			if value5 then
				if value2 <= value3 then
					table.insert(items, index, self)

					return
				elseif index == #items then
					items[#items + 1] = self

					return
				end
			elseif value3 <= value2 then
				table.insert(items, index, self)

				return
			elseif index == #items then
				table.insert(items, 1, self)

				return
			end
		end
	end

	for index2, item in ipairs(value4) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortSex(self2, value4, value5)
	local items = {}
	local value2
	local value3

	function insertTable(self)
		for index, item2 in ipairs(items) do
			value2 = self.get(self, "six")
			value3 = item2.get(item2, "six")

			if value5 then
				if value2 <= value3 then
					table.insert(items, index, self)

					return
				elseif index == #items then
					items[#items + 1] = self

					return
				end
			elseif value3 <= value2 then
				table.insert(items, index, self)

				return
			elseif index == #items then
				table.insert(items, 1, self)

				return
			end
		end
	end

	for index2, item in ipairs(value4) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild.sortTitle(self2, value4, value5)
	local items = {}
	local value2
	local value3

	function insertTable(self)
		for index, item2 in ipairs(items) do
			value2 = self.get(self, "position")
			value3 = item2.get(item2, "position")

			if value5 then
				if value3 <= value2 then
					table.insert(items, index, self)

					return
				elseif index == #items then
					items[#items + 1] = self

					return
				end
			elseif value2 < value3 then
				table.insert(items, index, self)

				return
			elseif index == #items then
				table.insert(items, 1, self)

				return
			end
		end
	end

	for index2, item in ipairs(value4) do
		if index2 == 1 then
			items[1] = item
		else
			insertTable(item)
		end
	end

	return items
end

function guild:showSubMem(data)
	local items4 = {
		150,
		80,
		80,
		80,
		90
	}
	local y = 42
	local items = {
		"角色名",
		CS_LEVEL,
		CS_JOB,
		"性别",
		"职务"
	}
	local value3 = g_data.guild.guildMems or {}
	local value4
	local value2
	local scroll

	local function cleanup(self2)
		if scroll then
			scroll:removeSelf()
		end

		scroll = an.newScroll(7, 8, 480, 292):add2(data)

		scroll:setScrollSize(480, math.max(292, #self2 * y))

		local items3 = {
			"",
			"副队长",
			"队长",
			"副会长",
			"会长"
		}

		if def.corpsSets and def.corpsSets.openCusShow and def.corpsSets.posTitle then
			items3 = def.corpsSets.posTitle
		end

		for index2, item in ipairs(self2) do
			local info2 = {}
			local cell = display.newNode():size(480, y):anchor(0, 0):pos(0, scroll:getScrollSize().height - index2 * y):add2(scroll)

			cell.scale = display.newScale9Sprite(res.getframe2(index2 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):add2(cell)

			local color2 = item.get(item, "status") == 1 and cc.c3b(255, 255, 255) or def.colors.cellOffline
			local value5 = g_data.player:fixStrLen(item.get(item, "name"), 8)

			info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(75, y * 0.5)

			local value6 = item.get(item, "level")

			info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(190, y * 0.5)

			local otherJobStr = g_data.player:getOtherJobStr(item.get(item, "job"))

			info2[#info2 + 1] = an.newLabel(otherJobStr, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(270, y * 0.5)

			local value7 = item.get(item, "six") == 0 and "男" or "女"

			info2[#info2 + 1] = an.newLabel(value7, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(350, y * 0.5)

			local value8 = items3[item.get(item, "position") + 1] or ""

			info2[#info2 + 1] = an.newLabel(value8, 18, 1, {
				color = color2
			}):add2(cell, 1):anchor(0.5, 0.5):pos(430, y * 0.5)

			cell.setTouchEnabled(cell, true)
			cell.setTouchSwallowEnabled(cell, false)
			cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					cell.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value9 = offsetBeginY.y - cell.offsetBeginY

					if math.abs(value9) <= 5 then
						if value4 then
							for _2, info3 in ipairs(value4.info) do
								info3.setColor(info3, value4.color or def.colors.cellNor)
							end

							value4:removeSelf()

							value4 = nil
						end

						value2 = item
						value4 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(cell)
						value4.info = info2
						value4.color = color2

						for _3, item4 in ipairs(info2) do
							item4.setColor(item4, def.colors.cellSel)
						end
					end
				end
			end)

			if index2 == 1 then
				value2 = item
				value4 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(cell)
				value4.info = info2
				value4.color = color2

				for _, item3 in ipairs(info2) do
					item3.setColor(item3, def.colors.cellSel)
				end
			end

			item.info = info2
			item.cell = cell
		end
	end

	local items2 = {
		function(value10, value11)
			return self:sortName(value10, value11)
		end,
		function(value12, value13)
			return self:sortLevel(value12, value13)
		end,
		function(value14, value15)
			return self:sortJob(value14, value15)
		end,
		function(value16, value17)
			return self:sortSex(value16, value17)
		end,
		function(value18, value19)
			return self:sortTitle(value18, value19)
		end
	}
	local x2 = 5
	local count2 = 1
	local count = 0

	for index, item2 in ipairs(items4) do
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x2 + item2 * 0.5, data.geth(data) - 23):add2(data)

		items[index] = an.newLabel(items[index], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x2 + item2 * 0.5, data.geth(data) - 23):add2(data)
		x2 = x2 + item2

		background.enableClick(background, function()
			if count2 == index then
				count = count + 1
				value3 = items2[index](value3, count % 2 == 0)
			else
				count = 0
				value3 = items2[index](value3, true)
			end

			value3 = self:sortOnline(value3)

			cleanup(value3)

			count2 = index
		end)
	end

	value3 = self.sortName(self, value3, true)
	value3 = self.sortOnline(self, value3)

	cleanup(value3)

	local x = 0

	if g_data.guild:isPresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			if value2:get("position") ~= 2 then
				main_scene.ui:fadeLabel(string.format("非%s不能任命为%s", self.corpsTitle, self.viceGuildTitle))

				return
			end

			an.newMsgbox(string.format("您确定设 %s 为%s吗？", value2:get("name"), self.viceGuildTitle), function(value20)
				if value20 == 1 then
					net.send({
						CM_GILD_APPOINT_VICE_PRESIDENT
					}, nil, {
						{
							"ID",
							value2:get("ID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/sfhz.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			if value2:get("position") ~= 2 and value2:get("position") ~= 3 then
				main_scene.ui:fadeLabel(string.format("只能任命战队%s或行会%s为%s", self.corpsTitle, self.viceGuildTitle, self.guildTitle))

				return
			end

			an.newMsgbox(string.format("您确定转让%s吗？", self.guildTitle), function(value21)
				if value21 == 1 then
					net.send({
						CM_GILD_TRANSFER_PRESIDENT
					}, nil, {
						{
							"ID",
							value2:get("ID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zrhz.png")
		}):add2(data):anchor(0.5, 0.5):pos(342, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			if value2:get("position") ~= 3 then
				main_scene.ui:fadeLabel(string.format("非%s不能卸任", self.viceGuildTitle))

				return
			end

			an.newMsgbox(string.format("您确定卸任 %s %s 职务吗？", value2:get("name"), self.viceGuildTitle), function(value22)
				if value22 == 1 then
					net.send({
						CM_GILD_DISMISS_VICECAPTAIN
					}, nil, {
						{
							"ID",
							value2:get("ID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xr.png")
		}):add2(data):anchor(0.5, 0.5):pos(242, -22)

		x = 3
	else
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			an.newMsgbox("您确定卸任吗？", function(value23)
				if value23 == 1 then
					net.send({
						CM_GILD_VICECAPTAIN_STEPDOWN
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xr.png")
		}):add2(data):anchor(0.5, 0.5):pos(x * 100 - 442, -22)

		x = x + 1
	end

	local x3 = x

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if not value2 then
			return
		end

		self:showMenu(cc.p(x3 * 100 - 160 + 82, 58), "更多操作", value2)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/gdcz.png")
	}):add2(data):anchor(0.5, 0.5):pos(x * 100 - 160, -22)
end

function guild:showSubClaninfo(data)
	local items3 = {
		160,
		160,
		160
	}
	local items2 = {
		"战队名",
		self.corpsTitle .. "名",
		"人数"
	}
	local x = 5

	for index2, item2 in ipairs(items3) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x + item2 * 0.5, data.geth(data) - 23):add2(data)

		items2[index2] = an.newLabel(items2[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item2 * 0.5, data.geth(data) - 23):add2(data)
		x = x + item2
	end

	local items = g_data.guild.guildcorpsList or {}
	local scroll = an.newScroll(7, 8, 480, 292):add2(data)
	local y = 42

	scroll.setScrollSize(scroll, 596, math.max(286, #items * y))

	local value3
	local value2

	for index, item in ipairs(items) do
		local info2 = {}
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value4 = g_data.player:fixStrLen(item.get(item, "corpsName"), 8)

		info2[#info2 + 1] = an.newLabel(value4, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(80, y * 0.5)

		local value5 = g_data.player:fixStrLen(item.get(item, "captainName"), 8)

		info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(240, y * 0.5)

		local value6 = item.get(item, "memberCount")

		info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(395, y * 0.5)

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value7 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value7) <= 5 then
					if value3 then
						for _2, info3 in ipairs(value3.info) do
							info3.setColor(info3, def.colors.cellNor)
						end

						value3:removeSelf()

						value3 = nil
					end

					value2 = item
					value3 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(background)
					value3.info = info2

					for _3, item4 in ipairs(info2) do
						item4.setColor(item4, def.colors.cellSel)
					end
				end
			end
		end)

		if index == 1 then
			value2 = item
			value3 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(background)
			value3.info = info2

			for _, item3 in ipairs(info2) do
				item3.setColor(item3, def.colors.cellSel)
			end
		end
	end

	local count = 0

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			if value2:get("captainName") == common.getPlayerName() and g_data.guild:isPresident() then
				main_scene.ui:fadeLabel(string.format("你是战队唯一%s，不可退出", self.guildTitle))

				return
			end

			an.newMsgbox(string.format("您确定将战队 %s 逐出行会吗？", value2:get("corpsName")), function(value8)
				if value8 == 1 then
					net.send({
						CM_GILD_DISMISS_CORPS
					}, nil, {
						{
							"ID",
							value2:get("corpsID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zchh.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)

		count = 1
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if not value2 then
			return
		end

		print("selectData:get(corpsID) ", value2:get("corpsID"), g_data.guild.clanInfo:get("corpsID"))
		net.send({
			CM_CORPS_MEMBER_LIST,
			tag = 30,
			series = 0,
			recog = 1
		}, nil, {
			{
				"ID",
				value2:get("corpsID")
			}
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/ckxx.png")
	}):add2(data):anchor(0.5, 0.5):pos(442 - count * 100, -22)
end

function guild:showSubClanrecruit(data)
	local items3 = {
		160,
		160,
		160
	}
	local items2 = {
		"战队名",
		self.corpsTitle .. "名",
		"人数"
	}
	local x = 5

	for index2, item2 in ipairs(items3) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x + item2 * 0.5, data.geth(data) - 23):add2(data)

		items2[index2] = an.newLabel(items2[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item2 * 0.5, data.geth(data) - 23):add2(data)
		x = x + item2
	end

	local items = g_data.guild.guildQueryMem or {}
	local scroll = an.newScroll(7, 8, 480, 292):add2(data)
	local y = 42

	scroll.setScrollSize(scroll, 480, math.max(292, #items * y))

	local value3
	local value2

	for index, item in ipairs(items) do
		local info2 = {}
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value4 = g_data.player:fixStrLen(item.get(item, "corpsName"), 8)

		info2[#info2 + 1] = an.newLabel(value4, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(80, y * 0.5)

		local value5 = g_data.player:fixStrLen(item.get(item, "captainName"), 8)

		info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(240, y * 0.5)

		local value6 = item.get(item, "memberCount")

		info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(395, y * 0.5)

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value7 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value7) <= 5 then
					if value3 then
						for _2, info3 in ipairs(value3.info) do
							info3.setColor(info3, def.colors.cellNor)
						end

						value3:removeSelf()

						value3 = nil
					end

					value2 = item
					value3 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(background)
					value3.info = info2

					for _3, item4 in ipairs(info2) do
						item4.setColor(item4, def.colors.cellSel)
					end
				end
			end
		end)

		if index == 1 then
			value2 = item
			value3 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(background)
			value3.info = info2

			for _, item3 in ipairs(info2) do
				item3.setColor(item3, def.colors.cellSel)
			end
		end
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			an.newMsgbox(string.format("您确定拒绝战队 %s 加入吗？", value2:get("corpsName")), function(value8)
				if value8 == 1 then
					net.send({
						CM_GILD_REFUSE_REQUEST,
						recog = 1
					}, nil, {
						{
							"ID",
							value2:get("ID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/jjjr.png")
		}):add2(data):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			an.newMsgbox(string.format("您确定允许战队 %s 加入吗？", value2:get("corpsName")), function(value9)
				if value9 == 1 then
					net.send({
						CM_GILD_ACCEPT_REQUEST,
						recog = 1
					}, nil, {
						{
							"ID",
							value2:get("ID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/yxjr.png")
		}):add2(data):anchor(0.5, 0.5):pos(342, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				series = 0,
				recog = 1
			}, nil, {
				{
					"ID",
					value2:get("corpsID")
				}
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/ckxx.png")
		}):add2(data):anchor(0.5, 0.5):pos(242, -22)
	end
end

function guild:showSubDiplomatic(pageNode)
	local items2 = {
		120,
		120,
		120,
		120
	}
	local items = {
		"    正在联盟",
		"    正在宣战",
		"    正在关注",
		"    申请联盟"
	}
	local x = 5
	local value_2 = res.get2("pic/common/button_click02.png"):anchor(0.5, 0.5):add2(pageNode, 2)
	local value2

	function click(self2)
		if value2 ~= self2 then
			value2 = self2

			if self.pageNode then
				self.pageNode:removeSelf()

				self.pageNode = nil
			end

			self.pageNode = display.newNode():size(482, 292):pos(4, 8):anchor(0, 0):add2(pageNode, 2)

			if self2 == 1 then
				net.send({
					CM_GILD_QUERY_UNION,
					tag = 30,
					series = 0
				})

				self.threeSub = 1
			elseif self2 == 2 then
				net.send({
					CM_GILD_QUERY_HOSTILE,
					tag = 30,
					series = 0
				})

				self.threeSub = 2
			elseif self2 == 3 then
				net.send({
					CM_GILD_QUERY_CONCERN,
					tag = 30,
					series = 0
				})

				self.threeSub = 3
			elseif self2 == 4 then
				net.send({
					CM_GILD_QUERY_REQUEST_UNION_LIST,
					tag = 30,
					series = 0
				})

				self.threeSub = 4
			end
		end
	end

	for index, item in ipairs(items2) do
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x + item * 0.5, pageNode.geth(pageNode) - 23):add2(pageNode)

		items[index] = an.newLabel(items[index], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item * 0.5, pageNode.geth(pageNode) - 23):add2(pageNode)

		res.get2("pic/common/button_click.png"):anchor(0.5, 0.5):pos(x + item * 0.5 - 40, pageNode.geth(pageNode) - 23):add2(pageNode)

		if index == 1 then
			value_2.pos(value_2, x + item * 0.5 - 40, pageNode.geth(pageNode) - 23)
		end

		local x2 = x + item * 0.5 - 40

		x = x + item

		background.enableClick(background, function()
			value_2:pos(x2, pageNode:geth() - 23)
			sound.playSound("103")
			click(index)
		end)
	end

	click(1)

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		self.guildBtn = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(guildBtn)
			net.send({
				CM_GILD_ENABLE_UNION,
				tag = guildBtn and 1 or 0
			})
		end, {
			easy = true,
			label = {
				"允许联盟",
				20,
				1,
				{
					color = def.colors.labelGray
				}
			}
		}):anchor(0, 0.5):pos(-110, -24):add2(pageNode, 2)

		local value3 = g_data.guild.guildInfo:get("enableUnion") == 1

		self.guildBtn.btn:setIsSelect(value3)
	end
end

function guild:showSubDiplomatic1(data)
	data = data or self.pageNode

	if data then
		data.removeAllChildren(data, true)
	end

	if self.threeSub ~= 1 then
		return
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(data.getw(data), 42)):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, data.geth(data) - 20):add2(data)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, data.geth(data) - 20):add2(data)

	local items = g_data.guild.guildUnion or {}
	local scroll = an.newScroll(0, 0, 480, 248):add2(data)
	local y = 42

	scroll.setScrollSize(scroll, 480, math.max(248, #items * y))

	local value2
	local value5

	for index, item in ipairs(items) do
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(480, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value3 = g_data.player:fixStrLen(item.get(item, "name"), 8)

		an.newLabel(value3, 18, 1, {
			color = def.colors.labelGray
		}):add2(background):anchor(0.5, 0.5):pos(120, y * 0.5)
		an.newBtn(res.gettex2("pic/common/remove_n.png"), function()
			net.send({
				CM_GILD_BREAK_UNION
			}, nil, {
				{
					"ID",
					item:get("ID")
				}
			})
		end, {
			pressImage = res.gettex2("pic/common/remove_s.png")
		}):add2(background, 2):anchor(0.5, 0.5):pos(300, y * 0.5)
		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value4 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value4) <= 5 then
					if value2 then
						value2:removeSelf()

						value2 = nil
					end

					value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, y)):anchor(0, 0):pos(0, 0):add2(background)
				end
			end
		end)
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			g_data.guild.guildList = {}

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
			self:showGuildList("增加联盟")
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zjlm.png")
		}):add2(data):anchor(0.5, 0.5):pos(434, -30)
	end
end

function guild:cmdFunc(value2, value3)
	local items = {
		增加联盟 = {
			"确定与行会 %s 申请联盟？",
			CM_GILD_REQUEST_UNION
		},
		行会宣战 = {
			"确定对行会 %s 发起宣战？",
			CM_GILD_DECLARE_WAR_NAME
		},
		增加关注 = {
			"确定对行会 %s 关注？",
			CM_GILD_CONCERN_GILD_NAME
		}
	}
	local value5
	local text = an.newMsgbox(string.format(items[value2][1], value3), function(value4)
		if value4 == 1 then
			net.send({
				items[value2][2]
			}, nil, {
				{
					"string",
					value3,
					15
				}
			})
		end
	end, {
		center = true,
		hasCancel = true
	})
end

function guild:showGuildList(guildListCmd)
	local items2 = {
		行会宣战 = "hhxz",
		增加联盟 = "zjlm",
		增加关注 = "zjgz"
	}

	self.guildListCmd = guildListCmd or self.guildListCmd

	self.content:hide()
	self.bg:setTex(res.gettex2("pic/common/black_2.png"))

	if self.showGuildListNode then
		self.showGuildListNode:removeSelf()

		self.showGuildListNode = nil
	end

	self.showGuildListNode = display.newNode():addto(self)

	local width = self.showGuildListNode

	width.size(width, self.getw(self), self.geth(self))

	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(width)
	local items3 = {
		200,
		200,
		124,
		82
	}
	local items4 = {
		"行会名",
		self.guildTitle,
		"战队数",
		"状态"
	}
	local x = 4

	for index2, item2 in ipairs(items3) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x + item2 * 0.5, background2.geth(background2) - 23):add2(background2)
		an.newLabel(items4[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item2 * 0.5, background2.geth(background2) - 23):add2(background2)

		x = x + item2
	end

	local items = g_data.guild.guildList

	local function cleanup(self2, value9)
		if value9 == ccui.PageViewEventType.turning then
			local text = string.format("page %d", pageView:getCurPageIdx() + 1)

			print(text)
		end
	end

	local scroll = an.newScroll(4, 4, 608, 288):add2(background2)
	local y = 42

	scroll.setScrollSize(scroll, 608, math.max(288, #items * y))
	scroll.enableTouch(scroll, false)
	scroll.enableClick(scroll, function()
		return
	end)

	local value2
	local value3

	for index, item in ipairs(items) do
		local info2 = {}
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value4 = g_data.player:fixStrLen(item.get(item, "gildName"), 8)

		info2[#info2 + 1] = an.newLabel(value4, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(100, y * 0.5)

		local value5 = g_data.player:fixStrLen(item.get(item, "presidentName"), 8)

		info2[#info2 + 1] = an.newLabel(value5, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(300, y * 0.5)

		local value6 = item.get(item, "corpsCount")

		info2[#info2 + 1] = an.newLabel(value6, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(460, y * 0.5)

		local value7 = g_data.guild.curApplyguild and item.get(item, "guildID") == g_data.guild.curApplyguild and "申请中" or ""

		info2[#info2 + 1] = an.newLabel(value7, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(556, y * 0.5)

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value10 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value10) <= 5 then
					if value2 then
						for _2, info3 in ipairs(value2.info) do
							info3.setColor(info3, def.colors.cellNor)
						end

						value2:removeSelf()

						value2 = nil
					end

					value3 = item
					value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background)
					value2.info = info2

					for _3, item4 in ipairs(info2) do
						item4.setColor(item4, def.colors.cellSel)
					end
				end
			end
		end)

		local value8 = cc.EventListenerCustom:create("UpdateNilGuildState", function()
			if g_data.guild.curApplyguild and item:get("guildID") == g_data.guild.curApplyguild then
				info2[4]:setString("申请中")
			else
				info2[4]:setString("")
			end
		end)

		background.getEventDispatcher(background):addEventListenerWithSceneGraphPriority(value8, background)

		if index == 1 then
			value3 = item
			value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, y)):anchor(0, 0):pos(0, 0):add2(background)
			value2.info = info2

			for _, item3 in ipairs(info2) do
				item3.setColor(item3, def.colors.cellSel)
			end
		end
	end

	local label2

	label2 = an.newInput(0, 0, 196, 40, 7, {
		label = {
			self.filterString or "",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"输入行会关键字      ",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		},
		stop_call = function()
			if label2:getString() == "" then
				self.filterString = nil

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})

				return
			end

			self.filterString = label2:getString()

			net.send({
				CM_FIND_GILD_BYNAME
			}, {
				label2:getString()
			})
		end
	}):add2(width):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		width:removeSelf()

		self.showGuildListNode = nil

		self.bg:setTex(res.gettex2("pic/common/black_0.png"))
		self.content:show()
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mail/return.png")
	}):add2(width):anchor(0.5, 0.5):pos(580, 38)
	print(items2[self.guildListCmd])
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		if not value3 then
			return
		end

		print(self.guildListCmd)
		self:cmdFunc(self.guildListCmd, value3:get("gildName"))
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/" .. items2[self.guildListCmd] .. ".png")
	}):add2(width):anchor(0.5, 0.5):pos(480, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local value11 = g_data.guild.page

		if g_data.guild.serach then
			-- block empty
		end

		local param3 = value11 + 1

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = param3
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):add2(width):anchor(0.5, 0.5):pos(380, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local param2 = g_data.guild.page - 1

		if param2 < 0 and not g_data.guild.serach then
			self:showError(30)

			return
		end

		if param2 < 0 then
			param2 = 0
		end

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = param2
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):add2(width):anchor(0.5, 0.5):pos(280, 38)
end

function guild:showSubDiplomatic2(data)
	data = data or self.pageNode

	if data then
		data.removeAllChildren(data, true)
	end

	if self.threeSub ~= 2 then
		return
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(data.getw(data), 42)):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, data.geth(data) - 20):add2(data)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, data.geth(data) - 20):add2(data)

	local items = g_data.guild.guildHostile or {}

	dump(items)

	local scroll = an.newScroll(0, 0, 472, 252):add2(data)
	local height = 42

	scroll.setScrollSize(scroll, 472, math.max(252, #items * height))

	local value2
	local value5

	for index, item in ipairs(items) do
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(472, height)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * height):add2(scroll)
		local value3 = g_data.player:fixStrLen(item.get(item, "name"), 8)

		an.newLabel(value3, 18, 1, {
			color = def.colors.labelGray
		}):add2(background):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, height * 0.5)
		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value4 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value4) <= 5 then
					if value2 then
						value2:removeSelf()

						value2 = nil
					end

					value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, height)):anchor(0, 0):pos(0, 0):add2(background)
				end
			end
		end)
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			g_data.guild.guildList = {}

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
			self:showGuildList("行会宣战")
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/hhxz.png")
		}):add2(data):anchor(0.5, 0.5):pos(434, -30)
	end
end

function guild:showSubDiplomatic3(data)
	data = data or self.pageNode

	if data then
		data.removeAllChildren(data, true)
	end

	if self.threeSub ~= 3 then
		return
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(242, 42)):anchor(0.5, 0.5):pos(121, data.geth(data) - 20):add2(data)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, data.geth(data) - 20):add2(data)
	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(242, 42)):anchor(0.5, 0.5):pos(361, data.geth(data) - 20):add2(data)
	an.newLabel("状态", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(352, data.geth(data) - 20):add2(data)

	local items = g_data.guild.guildConcern or {}
	local scroll = an.newScroll(0, 0, 472, 252):add2(data)
	local y = 42

	scroll.setScrollSize(scroll, 472, math.max(252, #items * y))

	local items2 = {
		"",
		"联盟中",
		"宣战中",
		"申请联盟中"
	}
	local items3 = {
		cc.c3b(255, 255, 255),
		cc.c3b(0, 255, 0),
		cc.c3b(255, 0, 0),
		def.colors.labelGray
	}
	local value3
	local value2

	for index, item in ipairs(items) do
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(472, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value5 = g_data.player:fixStrLen(item.get(item, "name"), 8)

		an.newLabel(value5, 18, 1, {
			color = def.colors.labelGray
		}):add2(background):anchor(0.5, 0.5):pos(120, y * 0.5)

		local value4 = items2[(item.get(item, "relation") or 0) + 1] or ""

		print("relation= ", item.get(item, "relation") or " nil ", value4)

		local color2 = items3[(item.get(item, "relation") or 0) + 1] or cc.c3b(255, 255, 255)

		an.newLabel(value4, 18, 1, {
			color = color2
		}):add2(background):anchor(0.5, 0.5):pos(352, y * 0.5)
		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value6 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value6) <= 5 then
					if value3 then
						value3:removeSelf()

						value3 = nil
					end

					value2 = item
					value3 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, y)):anchor(0, 0):pos(0, 0):add2(background)
				end
			end
		end)
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			local value10
			local text = an.newMsgbox(string.format("您确定取消对行会 %s 的关注？", value2:get("name")), function(value7)
				if value7 == 1 then
					net.send({
						CM_GILD_CANCLE_CONCERN
					}, nil, {
						{
							"ID",
							value2:get("ID")
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/qxgz.png")
		}):add2(data):anchor(0.5, 0.5):pos(434, -30)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			g_data.guild.guildList = {}

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
			self:showGuildList("增加关注")
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zjgz.png")
		}):add2(data):anchor(0.5, 0.5):pos(334, -30)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			local value11
			local text2 = an.newMsgbox(string.format("确定对行会 %s 发起宣战？", value2:get("name")), function(value8)
				if value8 == 1 then
					net.send({
						CM_GILD_DECLARE_WAR_NAME
					}, nil, {
						{
							"string",
							value2:get("name"),
							15
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/fqxz.png")
		}):add2(data):anchor(0.5, 0.5):pos(234, -30)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if not value2 then
				return
			end

			local value12
			local text3 = an.newMsgbox(string.format("确定与行会 %s 申请联盟？", value2:get("name")), function(value9)
				if value9 == 1 then
					net.send({
						CM_GILD_REQUEST_UNION
					}, nil, {
						{
							"string",
							value2:get("name"),
							15
						}
					})
				end
			end, {
				center = true,
				hasCancel = true
			})
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/sqlm.png")
		}):add2(data):anchor(0.5, 0.5):pos(134, -30)
	end
end

function guild:showSubDiplomatic4(data)
	data = data or self.pageNode

	if data then
		data.removeAllChildren(data, true)
	end

	if self.threeSub ~= 4 then
		return
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(data.getw(data), 42)):anchor(0.5, 0.5):pos(data.getw(data) * 0.5, data.geth(data) - 20):add2(data)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, data.geth(data) - 20):add2(data)

	local items = g_data.guild.guildRequestUnion or {}
	local scroll = an.newScroll(0, 0, 472, 252):add2(data)
	local y = 42

	scroll.setScrollSize(scroll, 472, math.max(252, #items * y))

	local value2
	local value5

	for index, item in ipairs(items) do
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(472, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value3 = g_data.player:fixStrLen(item.get(item, "corpsName"), 8)

		an.newLabel(value3, 18, 1, {
			color = def.colors.labelGray
		}):add2(background):anchor(0.5, 0.5):pos(120, y * 0.5)

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/accept_n.png"), function()
				net.send({
					CM_GILD_ACCEPT_REQUEST,
					recog = 2
				}, nil, {
					{
						"ID",
						item:get("ID")
					}
				})
			end, {
				pressImage = res.gettex2("pic/common/accept_s.png")
			}):add2(background, 2):anchor(0.5, 0.5):pos(260, y * 0.5)
			an.newBtn(res.gettex2("pic/common/refuse_n.png"), function()
				net.send({
					CM_GILD_REFUSE_REQUEST,
					recog = 2
				}, nil, {
					{
						"ID",
						item:get("ID")
					}
				})
			end, {
				pressImage = res.gettex2("pic/common/refuse_s.png")
			}):add2(background, 2):anchor(0.5, 0.5):pos(360, y * 0.5)
		end

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value4 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value4) <= 5 then
					if value2 then
						value2:removeSelf()

						value2 = nil
					end

					value2 = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, y)):anchor(0, 0):pos(0, 0):add2(background)
				end
			end
		end)
	end
end

function guild:showSubLog(data)
	local maxLine2 = 60

	if main_scene.ground:smr() then
		main_scene.ui:fadeLabel("乱斗模式无法查看日志")

		return
	end

	local scroll = an.newScroll(8, 8, 472, 328, {
		labelM = {
			16,
			params = {
				maxLine = maxLine2
			}
		}
	}):add2(data)
	local value2 = g_data.guild.guildLog or {}

	if value2 then
		for _, item in ipairs(value2) do
			scroll.labelM:addLabel(item.get(item, "logInfo"), def.colors.labelGray):nextLine()
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")
		net.send({
			CM_GILD_QUERY_LOG,
			tag = 0,
			series = 30,
			param = 2
		})

		self.guildLogType = 1
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/zzrz.png")
	}):add2(data):anchor(0.5, 0.5):pos(442, -22)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")
		net.send({
			CM_GILD_QUERY_LOG,
			tag = 0,
			series = 30,
			param = 1
		})

		self.guildLogType = 0
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/cyrz.png")
	}):add2(data):anchor(0.5, 0.5):pos(342, -22)
end

function guild:showOtherClanMem()
	local node = display.newNode()

	node.size(node, display.width, display.height):addto(display.getRunningScene(), an.z.msgbox)
	node.setTouchEnabled(node, true)
	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function()
		return
	end)

	local value_2 = res.get2("pic/common/black_4.png"):addto(node):pos(display.cx, display.cy):anchor(0.5, 0.5)

	value_2.size(value_2, 400, 400)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		node:removeSelf()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(value_2):pos(value_2.getw(value_2) - 5, value_2.geth(value_2) - 5):anchor(1, 1)

	local items3 = {
		130,
		80,
		80,
		78
	}
	local items4 = {
		"角色名",
		CS_LEVEL,
		CS_JOB,
		"职务"
	}
	local x = 16

	for index2, item2 in ipairs(items3) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item2 + 2, 42)):anchor(0.5, 0.5):pos(x + item2 * 0.5, value_2.geth(value_2) - 64):add2(value_2)
		an.newLabel(items4[index2], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item2 * 0.5, value_2.geth(value_2) - 64):add2(value_2)

		x = x + item2
	end

	local scroll = an.newScroll(14, 16, 372, 300):add2(value_2)
	local y = 42
	local items = g_data.guild.guildcorpsMem or {}
	local items2 = {
		"",
		"副队长",
		"队长",
		"队长",
		"队长"
	}

	if def.corpsSets and def.corpsSets.openCusShow and def.corpsSets.posTitle then
		items2[2] = def.corpsSets.posTitle[2]
		items2[3] = def.corpsSets.posTitle[3]
		items2[4] = def.corpsSets.posTitle[3]
		items2[5] = def.corpsSets.posTitle[3]
	end

	scroll.setScrollSize(scroll, 372, math.max(300, #items * y))

	for index, item in ipairs(items) do
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(372, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local value2 = g_data.player:fixStrLen(item.get(item, "name"), 8)

		an.newLabel(value2, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(62, y * 0.5)

		local value3 = item.get(item, "level")

		an.newLabel(value3, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(172, y * 0.5)

		local otherJobStr = g_data.player:getOtherJobStr(item.get(item, "job"))

		an.newLabel(otherJobStr, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(252, y * 0.5)

		local value4 = items2[item.get(item, "position") + 1] or ""

		an.newLabel(value4, 18, 1, {
			color = def.colors.cellNor
		}):add2(background):anchor(0.5, 0.5):pos(330, y * 0.5)
	end
end

function guild:showMenu(data, options2, options)
	if not options then
		return
	end

	local items3 = {}
	local number = 5
	local items = {}

	if options2 == "职务操作" then
		table.insert(items, {
			title = "卸任",
			op = function()
				if g_data.guild:isLeader() then
					if options:get("position") ~= 1 then
						main_scene.ui:fadeLabel(string.format("非%s不能卸任", self.viceCorpTitle))

						return
					end

					an.newMsgbox(string.format("您确定卸任 %s %s 职务吗？", options:get("name"), self.viceCorpTitle), function(value3)
						if value3 == 1 then
							net.send({
								CM_CORPS_DISMISS_VICE_CAPTAIN
							}, nil, {
								{
									"ID",
									options:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				elseif g_data.guild:isViceLeader() then
					an.newMsgbox(string.format("您确定卸任%s职务吗？", self.viceCorpTitle), function(value4)
						if value4 == 1 then
							net.send({
								CM_CORPS_STEPDOWN
							}, nil, {
								{
									"ID",
									options:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end
		})
		table.insert(items, {
			title = string.format("设置%s", self.viceCorpTitle),
			op = function()
				an.newMsgbox(string.format("您确定任命 %s 为%s吗？", options:get("name"), self.viceCorpTitle), function(value5)
					if value5 == 1 then
						net.send({
							CM_CORPS_APPOINT_VICE_CAPTAIN
						}, nil, {
							{
								"ID",
								options:get("ID")
							}
						})
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		})

		if def.openTransferCorps then
			table.insert(items, {
				title = string.format("转让%s", self.corpsTitle),
				op = function()
					an.newMsgbox(string.format("您确定转让%s职务给 %s 吗？", self.corpsTitle, options:get("name")), function(value6)
						if value6 == 1 then
							if options:get("name") == common.getPlayerName() then
								main_scene.ui:fadeLabel(string.format("不能转让%s给自己", self.corpsTitle))

								return
							end

							net.send({
								CM_CORPS_TRANSFER_CAPTAIN
							}, nil, {
								{
									"ID",
									options:get("ID")
								}
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			})
		end
	elseif options2 == "更多操作" then
		table.insert(items, {
			title = "私聊",
			op = function()
				common.changeChatStyle({
					{
						"target",
						options:get("name")
					},
					{
						"channel",
						"私聊"
					}
				})
			end
		})
		table.insert(items, {
			title = "查看信息",
			op = function()
				net.send({
					CM_QUERYUSERSTATE
				}, {
					options:get("name")
				})
			end
		})
		table.insert(items, {
			title = "添加好友",
			op = function()
				net.send({
					CM_ADD_RELATION_FRIEND
				}, {
					options:get("name")
				})
			end
		})
		table.insert(items, {
			title = "邀请组队",
			op = function()
				net.send({
					#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
				}, {
					options:get("name")
				})
			end
		})
		table.insert(items, {
			title = "添加关注",
			op = function()
				net.send({
					CM_ADD_RELATION_ATTENTION
				}, {
					options:get("name")
				})
			end
		})
		table.insert(items, {
			title = "加黑名单",
			op = function()
				net.send({
					CM_ADD_RELATION_NORMBLACKLIST
				}, {
					options:get("name")
				})
			end
		})
	end

	local value7

	for index, item in ipairs(items) do
		local items2 = {
			w = 94,
			h = 41,
			idx = index - 1,
			op = item
		}

		function items2.cellCls()
			return an.newBtn(res.gettex2("pic/common/btn10.png"), function()
				sound.playSound("103")

				if items2.op.op then
					local value8 = items2.op.op()
				end

				if items2 then
					items2:removeSelf()
				end
			end, {
				pressImage = res.gettex2("pic/common/btn11.png"),
				label = {
					items2.op.title,
					18,
					1,
					{
						color = def.colors.btn140
					}
				}
			}):anchor(0, 0)
		end

		items3[index] = items2
	end

	local operationMenu = common.createOperationMenu(items3, number, function(value2, value9)
		value2.removeSelf(value2)
	end):add2(self, 10):pos(data.x + 6, data.y)
end

function guild:showError(data)
	data = data or 1000

	local items = {
		"名字不合法",
		"名字重复",
		"已有战队",
		"玩家不在线",
		"玩家没有战队",
		"已有行会",
		"目标不存在",
		"请求已经存在",
		"不符合申请条件",
		"请求不存在",
		"请求的类型错误",
		"行会不存在",
		"行会成员已满",
		"关系类型错误",
		"关系已存在",
		"战队人数已满",
		"数据大小不对",
		"成员不存在",
		"不能操作本战队成员",
		string.format("尝试删除%s(战队%s不能被删除)", self.corpsTitle, self.corpsTitle),
		"职位已满",
		"无效的目标",
		"类型不匹配",
		"信息长度太长",
		"没有找到目标",
		"成员已经存在",
		"关系不存在",
		"在行会战区域(无法退出行会)",
		"在攻城区域(无法退出行会)",
		"没有更多内容",
		"该成员已有职务",
		"已联盟不可宣战",
		"已宣战不可联盟",
		"对方拒绝联盟",
		"玩家不允许面对面加人",
		"玩家没有足够的金币",
		"只有在安全区才能退出战队",
		"只有在安全区才能退出行会",
		string.format("需转让%s后才能操作 (退出)", self.corpsTitle),
		string.format("不可转让%s给自己", self.corpsTitle),
		[555] = "无操作权限",
		[1000] = "未知错误"
	}

	main_scene.ui:tip(items[data] or "未知错误")
end

return guild
