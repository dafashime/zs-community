local common = import("..common.common")
local chatPos = import("..common.chatPos")
local chatPic = import("..common.chatPic")
local chatItem = import("..common.chatItem")
local guild = class("guild", function ()
	return display.newNode()
end)
local tmpGuildPrivilege = def.guild.guildPrivilege

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

guild.ctor = function (self)
	self._supportMove = true
	self.needClean = {}
	local bg = display.newSprite(res.gettex2("pic/common/black_2.png")):anchor(0, 0):add2(self)
	self.bg = bg
	self.size(self, 641, 455):anchor(0.5, 0.5):center()
	self.title = display.newSprite(res.gettex2("pic/panels/guild/clan.png")):anchor(0.5, 0.5):pos(self.getw(self)*0.5, self.geth(self) - 25):add2(self, 2)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self, 2)
	self.nodeContent = display.newNode():addto(self)
	self.nodeContent:size(self.getw(self), self.geth(self)):anchor(0, 0)
	local texts = {
		"clan",
		"tguild"
	}
	local titlePic = {
		clan = "clan",
		tguild = "guild"
	}
	local tabs = {}
	local function click(btn)
		if self.showGuildListNode then
			return 
		end
		sound.playSound("103")
		for i, v in ipairs(tabs) do
			if v == btn then
				self.title:setTex(res.gettex2("pic/panels/guild/" .. titlePic[v.page] .. ".png"))
				v.select(v)
			else
				v.unselect(v)
			end
		end
		if btn.page ~= self.page then
			self.filterString = nil

			self:showContent(btn.page)
		end

		return 
	end
	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn110.png"), click, {
			support = "easy",
			sprite = res.gettex2("pic/panels/guild/" .. v .. "_n.png"),
			select = {
				res.gettex2("pic/common/btn111.png"),
				manual = true
			}
		}):add2(self):anchor(1, 1):pos(0, self.geth(self) - 36 - (i - 1)*70)

		tabs[i].sprite:pos(tabs[i]:getw()/2 + 3, tabs[i]:geth()/2 + 12)

		tabs[i].page = v

		if texts[1] == v then
			tabs[i]:select()
			self.showContent(self, v)
		end
	end

	return 
end
guild.onEnter = function (self)
	print("guild:onEnter()")

	return 
end
guild.onExit = function (self)
	print("guild:onExit()")

	return 
end
guild.clickCheck = function (self, time)
	if not g_data.client:checkLastTime("guild", time or 3) then
		main_scene.ui:tip("操作太快, 请重试.", cc.c3b(255, 255, 0))

		return false
	end

	g_data.client:setLastTime("guild", true)

	return true
end
guild.cleanSubNode = function (self)
	if 0 < #self.needClean then
		for i, v in ipairs(self.needClean) do
			v.removeSelf(v)
		end
	end

	self.acInput = nil
	self.needClean = {}
	self.chatViewGuild = nil

	return 
end
guild.showContent = function (self, page, ...)
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

			if not g_data.guild.getCorpsList then
				net.send({
					CM_CORPS_LIST,
					param = 0,
					tag = 7
				})
			end

			g_data.guild.getCorpsList = false
			self.subpage = nil
		end
	end

	return 
end
guild.uirefushContent = function (self, page)
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

	return 
end
guild.showContentClanNil = function (self, parent, ...)
	local back1 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(parent)
	local width = {
		150,
		150,
		150,
		60,
		96
	}
	local Titlelabel = {
		"战队名",
		"队长名",
		"队长行会",
		"人数",
		"状态"
	}
	local posOffset = 4

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, back1.geth(back1) - 23):add2(back1)
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, back1.geth(back1) - 23):add2(back1)

		posOffset = posOffset + v
	end

	local dataList = g_data.guild.corpsList

	if #dataList == 0 then
		an.newLabel("当前无战队", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(back1.getw(back1)/2, back1.geth(back1)/2):add2(back1, 2)
	end

	local infoView = an.newScroll(4, 4, 608, 288):add2(back1)
	local h = 42

	infoView.setScrollSize(infoView, 608, math.max(288, #dataList*h))
	infoView.enableTouch(infoView, false)
	infoView.enableClick(infoView, function ()
		return 
	end)

	local selectPic, selectData, sqBtn = nil
	sqBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if not selectData then
			return 
		end

		self.curSelectCorps = selectData:get("corpsID")

		if g_data.guild.curApplyclan == self.curSelectCorps then
			an.newMsgbox("是否取消对战队 " .. selectData:get("corpsName") .. " 的申请吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_CORPS_CANCEL_JOIN
					}, nil, {
						{
							"ID",
							self.curSelectCorps
						}
					})
				end

				return 
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
					selectData:get("corpsID")
				}
			})
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/jrzd.png")
	}):add2(parent):anchor(0.5, 0.5):pos(580, 38)

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local info = {}
		local label = g_data.player:fixStrLen(v.get(v, "corpsName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(75, h*0.5)
		label = g_data.player:fixStrLen(v.get(v, "captainName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(225, h*0.5)
		label = g_data.player:fixStrLen(v.get(v, "gildName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(375, h*0.5)
		label = v.get(v, "memberCount")
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(480, h*0.5)

		if g_data.guild.curApplyclan and v.get(v, "corpsID") == g_data.guild.curApplyclan then
			label = "申请中"
		else
			label = ""
		end

		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(554, h*0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v.setColor(v, def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectData = v
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, 0):add2(cell)
					selectPic.info = info

					for i, v in ipairs(info) do
						v.setColor(v, def.colors.cellSel)
					end

					if g_data.guild.curApplyclan and v:get("corpsID") == g_data.guild.curApplyclan then
						sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
					else
						sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
					end
				end
			end

			return 
		end)

		local listener = cc.EventListenerCustom:create("UpdateNilClanState", function ()
			if g_data.guild.curApplyclan and v:get("corpsID") == g_data.guild.curApplyclan then
				info[5]:setString("申请中")
			else
				info[5]:setString("")
			end

			if v:get("corpsID") == selectData:get("corpsID") then
				if g_data.guild.curApplyclan == v:get("corpsID") then
					sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
				else
					sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
				end
			end

			return 
		end)

		cell.getEventDispatcher(cell):addEventListenerWithSceneGraphPriority(listener, cell)

		if i == 1 then
			selectData = v
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end

			if g_data.guild.curApplyclan and v.get(v, "corpsID") == g_data.guild.curApplyclan then
				sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
			else
				sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/jrzd.png"))
			end
		end
	end

	local filterInput = nil
	filterInput = an.newInput(0, 0, 196, 40, 7, {
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
		stop_call = function ()
			if filterInput:getString() == "" then
				net.send({
					CM_CORPS_LIST,
					param = 0,
					tag = 7
				})

				self.filterString = nil

				return 
			end

			self.filterString = filterInput:getString()

			net.send({
				CM_FIND_CORPS_BYNAME
			}, {
				filterInput:getString()
			})

			return 
		end
	}):add2(parent):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local page = g_data.guild.page + ((not g_data.guild.serach or 0) and 1)

		net.send({
			CM_CORPS_LIST,
			tag = 7,
			param = page
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(480, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local page = g_data.guild.page - 1

		if page < 0 then
			self:showError(30)

			return 
		end

		if page < 0 then
			page = 0
		end

		net.send({
			CM_CORPS_LIST,
			tag = 7,
			param = page
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(380, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
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

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/sy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(280, 38)

	return 
end
guild.recruitCondition = function (self, msg, buf, bufLen)
	print(getRecordSize("TRecruitCondition"), bufLen)

	if getRecordSize("TRecruitCondition") ~= bufLen then
		return 
	end

	if not g_data.guild.clanInfo and not self.curSelectCorps then
		return 
	end

	local value = getRecord("TRecruitCondition")

	net.record(value, buf, bufLen)
	dump(value)

	local box, inputNotice, inputLevel = nil
	local toggleBtns = {}
	local localJob = value.get(value, "job") or 0
	local selectJob = {
		ycFunction:band(ycFunction:rshift(localJob, 0), 1) == 1,
		ycFunction:band(ycFunction:rshift(localJob, 1), 1) == 1,
		ycFunction:band(ycFunction:rshift(localJob, 2), 1) == 1
	}
	box = an.newMsgbox("", function (isOk)
		if isOk == 1 then
			print("申请加入")

			if g_data.guild.clanInfo then
				local count = tonumber(inputLevel:getString())

				if not count or count < 0 then
					main_scene.ui:tip("请输入正确的数字！")

					return 
				end

				local job = 0

				for i = 1, 3, 1 do
					if selectJob[i] then
						job = job + ycFunction:lshift(1, i - 1)

						print(ycFunction:lshift(1, i - 1))
					end
				end

				local tmpValue = getRecord("TRecruitCondition")

				tmpValue.set(tmpValue, "notice", inputNotice:getString())
				tmpValue.set(tmpValue, "level", tonumber(inputLevel:getString()))
				tmpValue.set(tmpValue, "job", job)
				dump(tmpValue)
				net.send({
					CM_CORPS_SET_RECRUIT_CONDITION
				}, nil, tmpValue)
			else
				local dataList = g_data.guild.corpsList
				local target = ""
				local preName, willName = nil

				for i, v in ipairs(dataList) do
					if g_data.guild.curApplyclan and v.get(v, "corpsID") == g_data.guild.curApplyclan then
						preName = v.get(v, "corpsName")
					end

					if v.get(v, "corpsID") == self.curSelectCorps then
						willName = v.get(v, "corpsName")
					end
				end

				if g_data.guild.curApplyclan then
					print("g_data.guild.curApplyclan", g_data.guild.curApplyclan)

					if g_data.guild.curApplyclan == self.curSelectCorps then
						preName = preName or ""
						target = "您确定取消对" .. preName .. " 战队的申请吗？"
					else
						preName = preName or ""
						willName = willName or ""
						target = "您确定加入 " .. willName .. ",取消对" .. preName .. " 战队的申请吗？"
					end
				else
					target = "您确定申请加入 " .. willName .. " 战队吗？"
				end

				an.newMsgbox(target, function (isOk)
					local level = g_data.player.ability:get("level")

					if self.curSelectCorps == g_data.guild.curApplyclan and level < value:get("level") then
						main_scene.ui:tip("您的等级过低")

						return 
					end

					if isOk == 1 then
						net.send({
							(self.curSelectCorps == g_data.guild.curApplyclan and CM_CORPS_CANCEL_JOIN) or CM_CORPS_REQUEST_JOIN
						}, nil, {
							{
								"ID",
								self.curSelectCorps
							}
						})
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})
			end
		end

		return 
	end, {
		disableScroll = true,
		center = true,
		hasCancel = true
	})
	local base = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(box.bg:getw() - 40, 40)):anchor(0.5, 0.5):pos(box.bg:getw()/2, box.bg:geth() - 80):add2(box.bg, 2)

	if not g_data.guild.clanInfo then
		an.newLabel(value.get(value, "notice"), 20, 1, {
			color = def.colors.labelGray
		}):addTo(base):anchor(0, 0.5):pos(10, base.geth(base)/2)
	else
		inputNotice = an.newInput(10, base.geth(base)/2, box.bg:getw() - 40, 40, 18, {
			tip = {
				"点击编辑公告(最多18个字)",
				20,
				1
			},
			label = {
				value.get(value, "notice"),
				20
			}
		}):addTo(base):anchor(0, 0.5)
	end

	base = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(40, 40)):anchor(0.5, 0.5):pos(148, 150):add2(box.bg, 2)

	if not g_data.guild.clanInfo then
		an.newLabel("等级限制:            级以上", 20, 1, {
			color = def.colors.labelGray
		}):add2(box.bg, 2):anchor(0, 0.5):pos(30, 150)
		an.newLabel("" .. value.get(value, "level"), 20, 1, {
			color = def.colors.labelGray
		}):add2(base, 2):anchor(0.5, 0.5):pos(base.getw(base)*0.5, base.geth(base)*0.5)
	else
		an.newLabel("等级限制:           级以上", 20, 1, {
			color = def.colors.labelGray
		}):add2(box.bg, 2):anchor(0, 0.5):pos(30, 150)

		inputLevel = an.newInput(8, base.geth(base)/2, 40, 40, 2, {
			label = {
				"" .. value.get(value, "level"),
				20
			}
		}):addTo(base):anchor(0, 0.5)
	end

	an.newLabel("职业限制:", 20, 1, {
		color = def.colors.labelGray
	}):add2(box.bg, 2):anchor(0, 0.5):pos(30, 100)

	local function click(idx)
		selectJob[idx] = not selectJob[idx]

		toggleBtns[idx]:setIsSelect(selectJob[idx])

		return 
	end

	local textList = {
		"战士",
		"法师",
		"道士"
	}

	for i = 1, #textList, 1 do
		local btn = an.newBtn(res.gettex2("pic/common/toggle10.png"), function ()
			click(i)

			return 
		end, {
			support = "easy",
			select = {
				res.gettex2("pic/common/toggle11.png"),
				manual = true
			}
		}):anchor(0.5, 0.5):pos(i*90 + 60, 100):add2(box.bg)

		btn.setIsSelect(btn, selectJob[i])

		if not g_data.guild.clanInfo then
			btn.setTouchEnabled(btn, false)
		end

		toggleBtns[#toggleBtns + 1] = btn

		an.newLabel(textList[i], 20, 1, {
			color = cc.c3b(255, 255, 255)
		}):anchor(0.5, 0.5):pos(i*90 + 104, 100):add2(box.bg)
	end

	return 
end
guild.showContentGuildNil = function (self, parent, ...)
	local back1 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(parent)
	local width = {
		200,
		200,
		124,
		82
	}
	local Titlelabel = {
		"行会名",
		"会长名",
		"战队数",
		"状态"
	}
	local posOffset = 4

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, back1.geth(back1) - 23):add2(back1)
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, back1.geth(back1) - 23):add2(back1)

		posOffset = posOffset + v
	end

	local dataList = g_data.guild.guildList

	local function pageViewEvent(sender, eventType)
		if eventType == ccui.PageViewEventType.turning then
			local pageInfo = string.format("page %d", pageView:getCurPageIdx() + 1)

			print(pageInfo)
		end

		return 
	end

	if #dataList == 0 then
		an.newLabel("当前无行会", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(back1.getw(back1)/2, back1.geth(back1)/2):add2(back1, 2)
	end

	local infoView = an.newScroll(4, 4, 608, 288):add2(back1)
	local h = 42

	infoView.setScrollSize(infoView, 608, math.max(288, #dataList*h))
	infoView.enableTouch(infoView, false)
	infoView.enableClick(infoView, function ()
		return 
	end)

	local selectPic, selectData, sqBtn = nil
	sqBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if not selectData then
			main_scene.ui:tip("请先选择行会!")

			return 
		end

		if not g_data.guild:isLeader() then
			main_scene.ui:tip("非战队队长不能申请加入行会!")

			return 
		end

		self.curApplyguild = selectData:get("guildID")
		local dataList = g_data.guild.guildList
		local target = ""
		local preName, willName = nil

		for i, v in ipairs(dataList) do
			if g_data.guild.curApplyguild and v.get(v, "guildID") == g_data.guild.curApplyguild then
				preName = v.get(v, "gildName")
			end

			if v.get(v, "guildID") == self.curApplyguild then
				willName = v.get(v, "gildName")
			end
		end

		if g_data.guild.curApplyguild then
			print("g_data.guild.curApplyclan", g_data.guild.curApplyguild)

			if g_data.guild.curApplyguild == self.curApplyguild then
				preName = preName or ""
				target = "您确定取消对行会 " .. preName .. " 的申请吗？"
			else
				preName = preName or ""
				willName = willName or ""
				target = "您确定加入 " .. willName .. ",取消对行会 " .. preName .. " 的申请吗？"
			end
		else
			target = "您确定申请加入行会 " .. willName .. " 吗？"
		end

		an.newMsgbox(target, function (isOk)
			if isOk == 1 then
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
							selectData:get("guildID")
						}
					})
				end
			end

			return 
		end, {
			center = true,
			hasCancel = true
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/jrhh.png")
	}):add2(parent):anchor(0.5, 0.5):pos(580, 38)

	for i, v in ipairs(dataList) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "gildName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(100, h*0.5)
		label = g_data.player:fixStrLen(v.get(v, "presidentName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(300, h*0.5)
		label = v.get(v, "corpsCount")
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(460, h*0.5)

		if g_data.guild.curApplyguild and v.get(v, "guildID") == g_data.guild.curApplyguild then
			label = "申请中"
		else
			label = ""
		end

		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(556, h*0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v.setColor(v, def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectData = v
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, 0):add2(cell)
					selectPic.info = info

					for i, v in ipairs(info) do
						v.setColor(v, def.colors.cellSel)
					end

					if g_data.guild.curApplyguild and v:get("guildID") == g_data.guild.curApplyguild then
						sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
					else
						sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
					end
				end
			end

			return 
		end)

		local listener = cc.EventListenerCustom:create("UpdateNilGuildState", function ()
			if g_data.guild.curApplyguild and v:get("guildID") == g_data.guild.curApplyguild then
				info[4]:setString("申请中")
			else
				info[4]:setString("")
			end

			if v:get("guildID") == selectData:get("guildID") then
				if g_data.guild.curApplyguild == v:get("guildID") then
					sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
				else
					sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
				end
			end

			return 
		end)

		cell.getEventDispatcher(cell):addEventListenerWithSceneGraphPriority(listener, cell)

		if i == 1 then
			selectData = v
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end

			if g_data.guild.curApplyguild and v.get(v, "guildID") == g_data.guild.curApplyguild then
				sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/qxsq.png"))
			else
				sqBtn.sprite:setTex(res.gettex2("pic/panels/guild/jrhh.png"))
			end
		end
	end

	local filterInput = nil
	filterInput = an.newInput(0, 0, 196, 40, 7, {
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
		stop_call = function ()
			if filterInput:getString() == "" then
				self.filterString = nil

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})

				return 
			end

			self.filterString = filterInput:getString()

			net.send({
				CM_FIND_GILD_BYNAME
			}, {
				filterInput:getString()
			})

			return 
		end
	}):add2(parent):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local page = g_data.guild.page + ((not g_data.guild.serach or 0) and 1)

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = page
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(480, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local page = g_data.guild.page - 1

		if page < 0 and not g_data.guild.serach then
			self:showError(30)

			return 
		end

		if page < 0 then
			page = 0
		end

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = page
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(380, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
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

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/sy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(280, 38)

	return 
end
guild.showContentClan = function (self, parent, ...)
	local texts = {
		"clanmain",
		"clanmem",
		"clanjobs",
		"clanlog"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v.select(v)
			else
				v.unselect(v)
			end

			if btn.page ~= self.subpage then
				self.subpage = btn.page

				self:showSub(btn.page, parent, true)
			end
		end

		return 
	end

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			support = "easy",
			sprite = res.gettex2("pic/panels/guild/" .. v .. "_n.png"),
			anchor = {
				0.5,
				0.5
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(parent):anchor(0, 0.5):pos(18, (i - 1)*54 - 370)
		tabs[i].page = v
	end

	tabs[1]:select()

	self.subpage = texts[1]

	self.showSub(self, texts[1], parent, true)

	return 
end
guild.showContentGuild = function (self, parent, ...)
	local texts = {
		"guildmain",
		"mem",
		"claninfo",
		"clanrecruit",
		"diplomatic",
		"log"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v.select(v)
			else
				v.unselect(v)
			end

			if btn.page ~= self.subpage then
				self.subpage = btn.page

				self:showSub(btn.page, parent, true)
			end
		end

		return 
	end

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			support = "easy",
			sprite = res.gettex2("pic/panels/guild/" .. v .. "_n.png"),
			anchor = {
				0.5,
				0.5
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(parent):anchor(0, 0.5):pos(18, (i - 1)*54 - 370)
		tabs[i].page = v
	end

	self.subpage = texts[1]

	tabs[1]:select()
	self.showSub(self, texts[1], parent, true)

	return 
end
guild.showSub = function (self, page, parent, sendcmd)
	parent = parent or self.content
	self.threeSub = 0

	if self.subContent then
		self.subContent:removeSelf()
	end

	self.pageNode = nil

	self.bg:setTex(res.gettex2("pic/common/black_0.png"))

	self.subContent = cc.Node:create()

	self.subContent:size(486, 344):anchor(0, 0):pos(138, 60):add2(parent)

	if page == "clanmain" then
		if sendcmd then
			net.send({
				CM_CORPS_NOTICE,
				tag = 0
			})
			net.send({
				CM_REFRESH_CORPSINFO
			})
		end

		self.showSubClanmain(self, self.subContent)
	elseif page == "clanmem" then
		if sendcmd then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 0,
				series = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end

		self.showSubClanmem(self, self.subContent)
	elseif page == "clanjobs" then
		if sendcmd then
			net.send({
				CM_CORPS_QUERY_REQUESTS,
				tag = 30,
				series = 0
			})
		end

		self.showSubClanjobs(self, self.subContent)
	elseif page == "clanlog" then
		if sendcmd then
			net.send({
				CM_CORPS_QUERY_LOG,
				param = 1,
				series = 30,
				tag = 0
			})
		end

		self.showSubClanlog(self, self.subContent)
	elseif page == "guildmain" then
		if sendcmd then
			net.send({
				CM_GILD_NOTICE,
				tag = 0
			})
			net.send({
				CM_REFRESH_GILDINFO
			})
		end

		self.showSubGuildmain(self, self.subContent)
	elseif page == "mem" then
		if sendcmd then
			net.send({
				CM_GILDMEMBER_LIST
			})
		end

		self.showSubMem(self, self.subContent)
	elseif page == "claninfo" then
		if sendcmd then
			net.send({
				CM_GILD_QUERY_CORPS
			})
		end

		self.showSubClaninfo(self, self.subContent)
	elseif page == "clanrecruit" then
		if sendcmd then
			net.send({
				CM_GILD_QUERY_REQUEST_JOIN_LIST,
				tag = 30,
				series = 0
			})
		end

		self.showSubClanrecruit(self, self.subContent)
	elseif page == "diplomatic" then
		self.showSubDiplomatic(self, self.subContent)
	elseif page == "log" then
		if sendcmd then
			net.send({
				CM_GILD_QUERY_LOG,
				param = 1,
				series = 30,
				tag = 0
			})
		end

		self.showSubLog(self, self.subContent)
	end

	return 
end
guild.refush = function (self, page)
	if self.subpage ~= page then
		return 
	end

	self.showSub(self, page)

	return 
end
guild.showSubClanmain = function (self, parent)
	parent.size(parent, 486, 236)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):addto(parent):anchor(0, 0):pos(2, 238):size(parent.getw(parent), 106)
	res.get2("pic/panels/guild/signboard_bg.png"):anchor(0, 0):pos(4, 242):addto(parent)
	an.newLabel((g_data.guild.clanInfo and (g_data.guild.clanInfo:get("corpsName") or "")) or "", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, 302):add2(parent)
	an.newLabel("队员:", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(1, 0.5):pos(parent.getw(parent)*0.5, 264):add2(parent)
	an.newLabel((g_data.guild.clanInfo and g_data.guild.clanInfo:get("onlineCount") .. "/" .. g_data.guild.clanInfo:get("memberCount")) or "1/30", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0, 0.5):pos(parent.getw(parent)*0.5 + 4, 264):add2(parent)

	local editInfo = nil
	local strs = {
		g_data.guild.clanNotice
	}
	local splitLabel = an.newLabel("", 18, 0)

	for slot8 = 1, 5, 1 do
	end

	strs[#strs + 1] = "\r\n"

	function refush(canEdit)
		if editInfo then
			editInfo:removeSelf()

			editInfo = nil
		end

		editInfo = an.newScroll(8, 8, 470, 220):add2(parent)

		if strs[#strs] ~= "\r\n" then
			strs[#strs + 1] = "\r\n"
		end

		local labels = {}
		local hMax = 0
		local valueInput, oldindex = nil

		for i, v in ipairs(strs) do
			local tmpLabel = cc.LabelTTF:create(v, "", 18, cc.size(470, 0), 0)

			tmpLabel.anchor(tmpLabel, 0, 1)

			labels[#labels + 1] = tmpLabel
			hMax = hMax + tmpLabel.getContentSize(tmpLabel).height

			if canEdit then
				tmpLabel.setTouchEnabled(tmpLabel, true)
				tmpLabel.setTouchSwallowEnabled(tmpLabel, false)
				tmpLabel.addNodeEventListener(tmpLabel, cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						tmpLabel.offsetBeginY = event.y

						return true
					elseif event.name == "ended" then
						local offsetY = event.y - tmpLabel.offsetBeginY

						if math.abs(offsetY) <= 5 then
							if valueInput then
								strs[oldindex] = valueInput:getText()

								labels[oldindex]:setString(valueInput:getText())
								valueInput:removeSelf()

								valueInput = nil
								oldindex = nil

								refush(true)

								return 
							end

							oldindex = i
							valueInput = an.newInput(tmpLabel:getPositionX(), tmpLabel:getPositionY(), 470, 24, 500, {
								label = {
									string.gsub(v, "\r\n", ""),
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
								stop_call = function ()
									local inputValue = valueInput:getText()

									if inputValue == "" then
										inputValue = "\r\n"
									end

									strs[i] = inputValue

									tmpLabel:setString(inputValue)
									valueInput:removeSelf()

									valueInput = nil
									oldindex = nil

									refush(true)

									return 
								end
							}):add2(editInfo):anchor(0, 1)
						end
					end

					return 
				end)
			end
		end

		editInfo:setScrollSize(470, math.max(220, hMax))

		hMax = 0

		for i, v in ipairs(labels) do
			v.pos(v, 0, editInfo:getScrollSize().height - hMax):add2(editInfo)

			hMax = hMax + v.getContentSize(v).height
		end

		return 
	end

	refush()
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if g_data.guild:isPresident() then
			main_scene.ui:tip("行会会长不能退出战队")

			return 
		end

		if g_data.guild:isVicePresident() or g_data.guild:isLeader() then
			main_scene.ui:tip("需转让队长之后才能退出战队")

			return 
		end

		an.newMsgbox("您确定退出战队吗？", function (isOk)
			if isOk == 1 then
				net.send({
					CM_CORPS_EXIT
				})
			end

			return 
		end, {
			center = true,
			hasCancel = true
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/tczd.png")
	}):add2(parent):anchor(0.5, 0.5):pos(442, -22)

	if g_data.guild:isLeader() then
		local editbtn, savebtn = nil
		editbtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			refush(true)
			editbtn:hide()
			savebtn:show()

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bjgg.png")
		}):add2(parent):anchor(0.5, 0.5):pos(342, -22)
		savebtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			refush(false)
			savebtn:hide()
			editbtn:show()

			local notice = ""

			for i, v in ipairs(strs) do
				v = string.gsub(v, "\r\n", "")
				notice = notice .. v .. "\r\n"
			end

			print(notice)
			net.send({
				CM_CORPS_NOTICE,
				tag = 1
			}, {
				notice
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bcgg.png")
		}):add2(parent):anchor(0.5, 0.5):pos(342, -22)

		savebtn.hide(savebtn)
	end

	return 
end
guild.showSubClanmem = function (self, parent)
	local width = {
		140,
		60,
		60,
		60,
		60,
		100
	}
	local Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"性别",
		"职务",
		"封号"
	}
	local posOffset = 6
	local dataList = g_data.guild.corpsMem or {}
	local selectPic, selectData = nil
	local posTitle = {
		"",
		"副队长",
		"队长",
		"副会长",
		"会长"
	}
	local infoView = nil
	local h = 42

	local function creteOrder(dataList)
		if infoView then
			infoView:removeSelf()
		end

		infoView = an.newScroll(7, 8, 480, 292):add2(parent)

		infoView:setScrollSize(480, math.max(292, #dataList*h))

		for i, v in ipairs(dataList) do
			local info = {}
			local tmpColor = (v.get(v, "status") == 1 and cc.c3b(255, 255, 255)) or def.colors.cellOffline
			local cell = display.newNode():size(480, h):anchor(0, 0):pos(0, infoView:getScrollSize().height - i*h):add2(infoView)
			cell.scale = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(480, h)):anchor(0, 0):add2(cell)
			local label = g_data.player:fixStrLen(v.get(v, "name"), 8)
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(70, h*0.5)
			label = v.get(v, "level")
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(170, h*0.5)
			label = g_data.player:getOtherJobStr(v.get(v, "job"))
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(230, h*0.5)

			if v.get(v, "six") == 0 then
				label = "男"
			else
				label = "女"
			end

			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(290, h*0.5)
			label = posTitle[v.get(v, "position") + 1] or ""
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(350, h*0.5)
			label = v.get(v, "title")
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(425, h*0.5)

			cell.setTouchEnabled(cell, true)
			cell.setTouchSwallowEnabled(cell, false)
			cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					cell.offsetBeginY = event.y

					return true
				elseif event.name == "ended" then
					local offsetY = event.y - cell.offsetBeginY

					if math.abs(offsetY) <= 5 then
						if selectPic then
							for i, v in ipairs(selectPic.info) do
								v.setColor(v, selectPic.color or def.colors.cellOffline)
							end

							selectPic:removeSelf()

							selectPic = nil
						end

						selectData = v
						selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, 0):add2(cell)
						selectPic.info = info
						selectPic.color = tmpColor

						for i, v in ipairs(info) do
							v.setColor(v, def.colors.cellSel)
						end
					end
				end

				return 
			end)

			if i == 1 then
				selectData = v
				selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, 0):add2(cell)
				selectPic.info = info
				selectPic.color = tmpColor

				for i, v in ipairs(info) do
					v.setColor(v, def.colors.cellSel)
				end
			end

			v.info = info
			v.cell = cell
		end

		return 
	end

	local func = {
		function (data, value)
			return self:sortName(data, value)
		end,
		function (data, value)
			return self:sortLevel(data, value)
		end,
		function (data, value)
			return self:sortJob(data, value)
		end,
		function (data, value)
			return self:sortSex(data, value)
		end,
		function (data, value)
			return self:sortTitle(data, value)
		end,
		function (data, value)
			return self:sortString(data, value)
		end
	}
	local sortType = 1
	local sortCount = 0

	for i, v in ipairs(width) do
		local back = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		Titlelabel[i] = an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		posOffset = posOffset + v

		back.enableClick(back, function ()
			if sortType == i then
				sortCount = sortCount + 1
				dataList = func[i](dataList, sortCount%2 == 0)
			else
				sortCount = 0
				dataList = func[i](dataList, true)
			end

			dataList = self:sortOnline(dataList)

			creteOrder(dataList)

			sortType = i

			return 
		end)
	end

	dataList = self.sortName(self, dataList, true)
	dataList = self.sortOnline(self, dataList)

	creteOrder(dataList)

	local posMux = 0

	if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			if selectData:get("name") == common.getPlayerName() then
				main_scene.ui:tip("不能操作自己")

				return 
			end

			an.newMsgbox("您确定将 " .. selectData:get("name") .. " 逐出战队吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_CORPS_DISMISS_MEMBER
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zczd.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			local msgbox = nil
			msgbox = an.newMsgbox("", function (idx)
				if idx == 1 then
					if msgbox.nameInput:getString() == "" then
						return 
					end

					net.send({
						CM_CORPS_SET_MEMBER_TITLE
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						},
						{
							"string",
							def.wordfilter.run(msgbox.nameInput:getString()),
							15
						}
					})
				end

				return 
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
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 20)

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/szfh.png")
		}):add2(parent):anchor(0.5, 0.5):pos(342, -22)

		posMux = 2
	end

	local menuPos = posMux

	if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			self:showMenu(cc.p(menuPos*100 - 442 + 82, 58), "职务操作", selectData)

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zwcz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(posMux*100 - 442, -22)

		posMux = posMux + 1
	end

	local menuPos1 = posMux

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if not selectData then
			return 
		end

		self:showMenu(cc.p(menuPos1*100 - 442 + 82, 58), "更多操作", selectData)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/gdcz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(posMux*100 - 442, -22)

	return 
end
guild.showSubClanjobs = function (self, parent)
	local width = {
		170,
		90,
		90,
		131
	}
	local Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"性别"
	}
	local posOffset = 5

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)

		Titlelabel[i] = an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		posOffset = posOffset + v
	end

	local dataList = g_data.guild.corpsQueryMem or {}
	local infoView = an.newScroll(7, 8, 480, 292):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 472, math.max(288, #dataList*h))

	local maxMem = g_data.guild.clanInfo:get("memberCount") - 30
	local selectPic, selectData = nil
	local allSelect = false

	for i, v in ipairs(dataList) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "name"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(85, h*0.5)
		label = v.get(v, "level")
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(215, h*0.5)
		label = g_data.player:getOtherJobStr(v.get(v, "job"))
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(305, h*0.5)

		if v.get(v, "six") == 0 then
			label = "男"
		else
			label = "女"
		end

		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(410, h*0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if allSelect then
						if v.selectPic then
							for i, obj in ipairs(v.info) do
								obj.setColor(obj, def.colors.cellNor)
							end

							v.selectPic:removeSelf()

							v.selectPic = nil
						else
							v.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, 0):add2(v.cell)

							for i, obj in ipairs(v.info) do
								obj.setColor(obj, def.colors.cellSel)
							end
						end
					else
						if selectPic then
							for i, v in ipairs(selectPic.info) do
								v.setColor(v, def.colors.cellNor)
							end

							selectPic:removeSelf()

							selectPic = nil
						end

						selectData = v
						selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, 0):add2(cell)
						selectPic.info = info

						for i, v in ipairs(info) do
							v.setColor(v, def.colors.cellSel)
						end
					end
				end
			end

			return 
		end)

		if i == 1 then
			selectData = v
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end
		end

		v.cell = cell
		v.info = info
	end

	if g_data.guild:isLeader() or g_data.guild:isViceLeader() then
		local allAllow = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			allSelect = b

			if allSelect then
				if selectPic then
					for i, v in ipairs(selectPic.info) do
						v.setColor(v, def.colors.cellNor)
					end

					selectPic:removeSelf()

					selectPic = nil
					selectData = nil
				end

				maxMem = g_data.guild.clanInfo:get("memberCount") - 30

				for i, v in ipairs(dataList) do
					v.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, 0):add2(v.cell)

					for i, obj in ipairs(v.info) do
						obj.setColor(obj, def.colors.cellSel)
					end

					maxMem = maxMem - 1

					if maxMem <= 0 then
						break
					end
				end
			else
				for i, v in ipairs(dataList) do
					if v.selectPic then
						for i, obj in ipairs(v.info) do
							obj.setColor(obj, def.colors.cellNor)
						end

						v.selectPic:removeSelf()

						v.selectPic = nil
					end
				end
			end

			return 
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
		}):anchor(0, 0.5):pos(-110, -28):add2(parent, 2)

		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if allSelect then
				an.newMsgbox("您确定拒绝所有进入战队的申请吗？", function (isOk)
					if isOk == 1 then
						local data = {}

						for i, v in ipairs(dataList) do
							if v.selectPic then
								data[#data + 1] = {
									"ID",
									v.get(v, "ID")
								}
							end
						end

						net.send({
							CM_CORPS_REFUSE_REQUEST,
							param = #data
						}, nil, data)
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})
			else
				if not selectData then
					return 
				end

				an.newMsgbox("您确定拒绝 " .. selectData:get("name") .. "进入战队吗？", function (isOk)
					if isOk == 1 then
						net.send({
							CM_CORPS_REFUSE_REQUEST,
							param = 1
						}, nil, {
							{
								"ID",
								selectData:get("ID")
							}
						})
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})
			end

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/jjzs.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if allSelect then
				an.newMsgbox("您确定允许所有进入战队的申请吗？", function (isOk)
					if isOk == 1 then
						local data = {}

						for i, v in ipairs(dataList) do
							if v.selectPic then
								data[#data + 1] = {
									"ID",
									v.get(v, "ID")
								}
							end
						end

						net.send({
							CM_CORPS_ACCEPT_REQUEST,
							param = #data
						}, nil, data)
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})
			else
				if not selectData then
					return 
				end

				an.newMsgbox("您确定允许 " .. selectData:get("name") .. "进入战队吗？", function (isOk)
					if isOk == 1 then
						net.send({
							CM_CORPS_ACCEPT_REQUEST,
							param = 1
						}, nil, {
							{
								"ID",
								selectData:get("ID")
							}
						})
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})
			end

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/tyzs.png")
		}):add2(parent):anchor(0.5, 0.5):pos(342, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			net.send({
				CM_CORPS_DIRECT_ADD_MEMBER
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/mdmz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(242, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			net.send({
				CM_CORPS_GET_RECRUIT_CONDITION
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zxsz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(142, -22)
	end

	return 
end
guild.showSubClanlog = function (self, parent)
	local maxLine = 60
	local chatView = an.newScroll(8, 8, 472, 328, {
		labelM = {
			16,
			params = {
				maxLine = maxLine
			}
		}
	}):add2(parent)
	local msgs = g_data.guild.corpsLog or {}

	if msgs then
		for i, v in ipairs(msgs) do
			chatView.labelM:addLabel(v.get(v, "logInfo"), def.colors.labelGray):nextLine()
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		self.clanLogType = 1

		net.send({
			CM_CORPS_QUERY_LOG,
			param = 2,
			series = 30,
			tag = 0
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/zzrz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		self.clanLogType = 0

		net.send({
			CM_CORPS_QUERY_LOG,
			param = 1,
			series = 30,
			tag = 0
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/cyrz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(342, -22)

	return 
end
guild.showSubGuildmain = function (self, parent)
	parent.size(parent, 486, 236)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):addto(parent):anchor(0, 0):pos(2, 238):size(parent.getw(parent), 106)
	res.get2("pic/panels/guild/signboard_bg.png"):anchor(0, 0):pos(4, 242):addto(parent)
	an.newLabel((g_data.guild.guildInfo and (g_data.guild.guildInfo:get("gildName") or "")) or "", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, 302):add2(parent)
	an.newLabel("战队数:", 20, 1, {
		color = def.colors.labelGray
	}):anchor(1, 0.5):pos(parent.getw(parent)*0.45, 264):add2(parent)
	an.newLabel((g_data.guild.guildInfo and g_data.guild.guildInfo:get("corpsCount") .. "/8") or "1/8", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):pos(parent.getw(parent)*0.45 + 4, 264):add2(parent)
	an.newLabel("会员数:" .. g_data.guild.guildInfo:get("onlineCount") .. "/" .. g_data.guild.guildInfo:get("playerCount"), 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):pos(parent.getw(parent)*0.55, 264):add2(parent)

	local editInfo = nil
	local strs = {
		g_data.guild.guildNotice
	}

	for slot7 = 1, 5, 1 do
	end

	strs[#strs + 1] = "\r\n"

	function refush(canEdit)
		if editInfo then
			editInfo:removeSelf()

			editInfo = nil
		end

		editInfo = an.newScroll(8, 8, 470, 220):add2(parent)

		if strs[#strs] ~= "\r\n" then
			strs[#strs + 1] = "\r\n"
		end

		local labels = {}
		local hMax = 0
		local valueInput, oldindex = nil

		for i, v in ipairs(strs) do
			local tmpLabel = cc.LabelTTF:create(v, "", 18, cc.size(470, 0), 0)

			tmpLabel.anchor(tmpLabel, 0, 1)

			labels[#labels + 1] = tmpLabel
			hMax = hMax + tmpLabel.getContentSize(tmpLabel).height

			if canEdit then
				tmpLabel.setTouchEnabled(tmpLabel, true)
				tmpLabel.setTouchSwallowEnabled(tmpLabel, false)
				tmpLabel.addNodeEventListener(tmpLabel, cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						tmpLabel.offsetBeginY = event.y

						return true
					elseif event.name == "ended" then
						local offsetY = event.y - tmpLabel.offsetBeginY

						if math.abs(offsetY) <= 5 then
							if valueInput then
								strs[oldindex] = valueInput:getText()

								labels[oldindex]:setString(valueInput:getText())
								valueInput:removeSelf()

								valueInput = nil
								oldindex = nil

								refush(true)

								return 
							end

							oldindex = i
							valueInput = an.newInput(tmpLabel:getPositionX(), tmpLabel:getPositionY(), 470, 24, 500, {
								label = {
									string.gsub(v, "\r\n", ""),
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
								stop_call = function ()
									local inputValue = valueInput:getText()

									if inputValue == "" then
										inputValue = "\r\n"
									end

									strs[i] = inputValue

									tmpLabel:setString(inputValue)
									valueInput:removeSelf()

									valueInput = nil
									oldindex = nil

									refush(true)

									return 
								end
							}):add2(editInfo):anchor(0, 1)
						end
					end

					return 
				end)
			end
		end

		editInfo:setScrollSize(470, math.max(220, hMax))

		hMax = 0

		for i, v in ipairs(labels) do
			v.pos(v, 0, editInfo:getScrollSize().height - hMax):add2(editInfo)

			hMax = hMax + v.getContentSize(v).height
		end

		return 
	end

	refush()

	if g_data.guild:isPresident() then
		local editbtn, savebtn = nil
		editbtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			refush(true)
			editbtn:hide()
			savebtn:show()

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bjgg.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
		savebtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			refush(false)
			savebtn:hide()
			editbtn:show()

			local notice = ""

			for i, v in ipairs(strs) do
				v = string.gsub(v, "\r\n", "")
				notice = notice .. v .. "\r\n"
			end

			print(notice)
			net.send({
				CM_GILD_NOTICE,
				tag = 1
			}, {
				notice
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/bcgg.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)

		savebtn.hide(savebtn)

		return 
	end

	if g_data.guild:isVicePresident() or g_data.guild:isLeader() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if g_data.guild:isPresident() then
				main_scene.ui:tip("你是行会会长，不可退出")

				return 
			end

			an.newMsgbox("您确定要退出行会吗？\n队长退出行会将带领战队中所有成员退出行会", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_EXIT
					})
				end

				return 
			end, {
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/tchh.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
	end
end
guild.sortOnline = function (self, list)
	local tmpList = {}

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			if v.get(v, "status") < data.get(data, "status") then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				tmpList[#tmpList + 1] = data

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortOnlineTwo = function (self, list)
	local tmpList = {}

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			if data.get(data, "status") <= v.get(v, "status") then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				table.insert(tmpList, 1, data)

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortString = function (self, list, order)
	local tmpList = {}
	local value1, value2 = nil

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			value1 = string.len(data.get(data, "title"))
			value2 = string.len(v.get(v, "title"))
			local ret = (order and value2 <= value1) or value1 < value2

			if ret then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				tmpList[#tmpList + 1] = data

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortName = function (self, list, order)
	local tmpList = {}
	local value1, value2 = nil

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			value1 = string.len(data.get(data, "name"))
			value2 = string.len(v.get(v, "name"))
			local ret = (order and value2 <= value1) or value1 < value2

			if ret then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				tmpList[#tmpList + 1] = data

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortLevel = function (self, list, order)
	local tmpList = {}
	local value1, value2 = nil

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			value1 = data.get(data, "level")
			value2 = v.get(v, "level")

			if order then
				if value2 <= value1 then
					table.insert(tmpList, i, data)

					return 
				elseif i == #tmpList then
					tmpList[#tmpList + 1] = data

					return 
				end
			elseif value1 < value2 then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				table.insert(tmpList, 1, data)

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortJob = function (self, list, order)
	local tmpList = {}
	local value1, value2 = nil

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			value1 = data.get(data, "job")
			value2 = v.get(v, "job")

			if order then
				if value1 <= value2 then
					table.insert(tmpList, i, data)

					return 
				elseif i == #tmpList then
					tmpList[#tmpList + 1] = data

					return 
				end
			elseif value2 <= value1 then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				table.insert(tmpList, 1, data)

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortSex = function (self, list, order)
	local tmpList = {}
	local value1, value2 = nil

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			value1 = data.get(data, "six")
			value2 = v.get(v, "six")

			if order then
				if value1 <= value2 then
					table.insert(tmpList, i, data)

					return 
				elseif i == #tmpList then
					tmpList[#tmpList + 1] = data

					return 
				end
			elseif value2 <= value1 then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				table.insert(tmpList, 1, data)

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.sortTitle = function (self, list, order)
	local tmpList = {}
	local value1, value2 = nil

	function insertTable(data)
		for i, v in ipairs(tmpList) do
			value1 = data.get(data, "position")
			value2 = v.get(v, "position")

			if order then
				if value2 <= value1 then
					table.insert(tmpList, i, data)

					return 
				elseif i == #tmpList then
					tmpList[#tmpList + 1] = data

					return 
				end
			elseif value1 < value2 then
				table.insert(tmpList, i, data)

				return 
			elseif i == #tmpList then
				table.insert(tmpList, 1, data)

				return 
			end
		end

		return 
	end

	for i, v in ipairs(list) do
		if i == 1 then
			tmpList[1] = v
		else
			insertTable(v)
		end
	end

	return tmpList
end
guild.showSubMem = function (self, parent)
	local width = {
		150,
		80,
		80,
		80,
		90
	}
	local h = 42
	local Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"性别",
		"职务"
	}
	local dataList = g_data.guild.guildMems or {}
	local selectPic, selectData, infoView = nil

	local function creteOrder(dataList)
		if infoView then
			infoView:removeSelf()
		end

		infoView = an.newScroll(7, 8, 480, 292):add2(parent)

		infoView:setScrollSize(480, math.max(292, #dataList*h))

		local posTitle = {
			"",
			"副队长",
			"队长",
			"副会长",
			"会长"
		}

		for i, v in ipairs(dataList) do
			local info = {}
			local cell = display.newNode():size(480, h):anchor(0, 0):pos(0, infoView:getScrollSize().height - i*h):add2(infoView)
			cell.scale = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(480, h)):anchor(0, 0):add2(cell)
			local tmpColor = (v.get(v, "status") == 1 and cc.c3b(255, 255, 255)) or def.colors.cellOffline
			local label = g_data.player:fixStrLen(v.get(v, "name"), 8)
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(75, h*0.5)
			label = v.get(v, "level")
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(190, h*0.5)
			label = g_data.player:getOtherJobStr(v.get(v, "job"))
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(270, h*0.5)

			if v.get(v, "six") == 0 then
				label = "男"
			else
				label = "女"
			end

			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(350, h*0.5)
			label = posTitle[v.get(v, "position") + 1] or ""
			info[#info + 1] = an.newLabel(label, 18, 1, {
				color = tmpColor
			}):add2(cell, 1):anchor(0.5, 0.5):pos(430, h*0.5)

			cell.setTouchEnabled(cell, true)
			cell.setTouchSwallowEnabled(cell, false)
			cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					cell.offsetBeginY = event.y

					return true
				elseif event.name == "ended" then
					local offsetY = event.y - cell.offsetBeginY

					if math.abs(offsetY) <= 5 then
						if selectPic then
							for i, v in ipairs(selectPic.info) do
								v.setColor(v, selectPic.color or def.colors.cellNor)
							end

							selectPic:removeSelf()

							selectPic = nil
						end

						selectData = v
						selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
						selectPic.info = info
						selectPic.color = tmpColor

						for i, v in ipairs(info) do
							v.setColor(v, def.colors.cellSel)
						end
					end
				end

				return 
			end)

			if i == 1 then
				selectData = v
				selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
				selectPic.info = info
				selectPic.color = tmpColor

				for i, v in ipairs(info) do
					v.setColor(v, def.colors.cellSel)
				end
			end

			v.info = info
			v.cell = cell
		end

		return 
	end

	local func = {
		function (data, value)
			return self:sortName(data, value)
		end,
		function (data, value)
			return self:sortLevel(data, value)
		end,
		function (data, value)
			return self:sortJob(data, value)
		end,
		function (data, value)
			return self:sortSex(data, value)
		end,
		function (data, value)
			return self:sortTitle(data, value)
		end
	}
	local posOffset = 5
	local sortType = 1
	local sortCount = 0

	for i, v in ipairs(width) do
		local back = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		Titlelabel[i] = an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		posOffset = posOffset + v

		back.enableClick(back, function ()
			if sortType == i then
				sortCount = sortCount + 1
				dataList = func[i](dataList, sortCount%2 == 0)
			else
				sortCount = 0
				dataList = func[i](dataList, true)
			end

			dataList = self:sortOnline(dataList)

			creteOrder(dataList)

			sortType = i

			return 
		end)
	end

	dataList = self.sortName(self, dataList, true)
	dataList = self.sortOnline(self, dataList)

	creteOrder(dataList)

	local posMux = 0

	if g_data.guild:isPresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			if selectData:get("position") ~= 2 then
				main_scene.ui:tip("非队长不能任命为副会长")

				return 
			end

			an.newMsgbox("您确定设 " .. selectData:get("name") .. " 为副会长吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_APPOINT_VICE_PRESIDENT
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/sfhz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			if selectData:get("position") ~= 2 and selectData:get("position") ~= 3 then
				main_scene.ui:tip("只能任命战队队长或行会副会长为会长")

				return 
			end

			an.newMsgbox("您确定转让会长吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_TRANSFER_PRESIDENT
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zrhz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(342, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			if selectData:get("position") ~= 3 then
				main_scene.ui:tip("非副会长不能卸任")

				return 
			end

			an.newMsgbox("您确定卸任 " .. selectData:get("name") .. " 副会长职务吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_DISMISS_VICECAPTAIN
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xr.png")
		}):add2(parent):anchor(0.5, 0.5):pos(242, -22)

		posMux = 3
	else
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			an.newMsgbox("您确定卸任吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_VICECAPTAIN_STEPDOWN
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/xr.png")
		}):add2(parent):anchor(0.5, 0.5):pos(posMux*100 - 442, -22)

		posMux = posMux + 1
	end

	local menuPos = posMux

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if not selectData then
			return 
		end

		self:showMenu(cc.p(menuPos*100 - 442 + 82, 58), "更多操作", selectData)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/gdcz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(posMux*100 - 442, -22)

	return 
end
guild.showSubClaninfo = function (self, parent)
	local width = {
		160,
		160,
		160
	}
	local Titlelabel = {
		"战队名",
		"队长名",
		"人数"
	}
	local posOffset = 5

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)

		Titlelabel[i] = an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		posOffset = posOffset + v
	end

	local dataList = g_data.guild.guildcorpsList or {}
	local infoView = an.newScroll(7, 8, 480, 292):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 596, math.max(286, #dataList*h))

	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "corpsName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(80, h*0.5)
		label = g_data.player:fixStrLen(v.get(v, "captainName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(240, h*0.5)
		label = v.get(v, "memberCount")
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(395, h*0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v.setColor(v, def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectData = v
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
					selectPic.info = info

					for i, v in ipairs(info) do
						v.setColor(v, def.colors.cellSel)
					end
				end
			end

			return 
		end)

		if i == 1 then
			selectData = v
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end
		end
	end

	local posMux = 0

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			if selectData:get("captainName") == common.getPlayerName() and g_data.guild:isPresident() then
				main_scene.ui:tip("你是战队唯一会长，不可退出")

				return 
			end

			an.newMsgbox("您确定将战队 " .. selectData:get("corpsName") .. " 逐出行会吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_DISMISS_CORPS
					}, nil, {
						{
							"ID",
							selectData:get("corpsID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zchh.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)

		posMux = 1
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if not selectData then
			return 
		end

		print("selectData:get(corpsID) ", selectData:get("corpsID"), g_data.guild.clanInfo:get("corpsID"))
		net.send({
			CM_CORPS_MEMBER_LIST,
			tag = 30,
			recog = 1,
			series = 0
		}, nil, {
			{
				"ID",
				selectData:get("corpsID")
			}
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/ckxx.png")
	}):add2(parent):anchor(0.5, 0.5):pos(posMux*100 - 442, -22)

	return 
end
guild.showSubClanrecruit = function (self, parent)
	local width = {
		160,
		160,
		160
	}
	local Titlelabel = {
		"战队名",
		"队长名",
		"人数"
	}
	local posOffset = 5

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)

		Titlelabel[i] = an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		posOffset = posOffset + v
	end

	local dataList = g_data.guild.guildQueryMem or {}
	local infoView = an.newScroll(7, 8, 480, 292):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 480, math.max(292, #dataList*h))

	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "corpsName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(80, h*0.5)
		label = g_data.player:fixStrLen(v.get(v, "captainName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(240, h*0.5)
		label = v.get(v, "memberCount")
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(395, h*0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v.setColor(v, def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectData = v
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
					selectPic.info = info

					for i, v in ipairs(info) do
						v.setColor(v, def.colors.cellSel)
					end
				end
			end

			return 
		end)

		if i == 1 then
			selectData = v
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end
		end
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			an.newMsgbox("您确定拒绝战队 " .. selectData:get("corpsName") .. " 加入吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_REFUSE_REQUEST,
						recog = 1
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/jjjr.png")
		}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			an.newMsgbox("您确定允许战队 " .. selectData:get("corpsName") .. " 加入吗？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_ACCEPT_REQUEST,
						recog = 1
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/yxjr.png")
		}):add2(parent):anchor(0.5, 0.5):pos(342, -22)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				recog = 1,
				series = 0
			}, nil, {
				{
					"ID",
					selectData:get("corpsID")
				}
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/ckxx.png")
		}):add2(parent):anchor(0.5, 0.5):pos(242, -22)
	end

	return 
end
guild.showSubDiplomatic = function (self, parent)
	local width = {
		120,
		120,
		120,
		120
	}
	local Titlelabel = {
		"    正在联盟",
		"    正在宣战",
		"    正在关注",
		"    申请联盟"
	}
	local posOffset = 5
	local selectPic = res.get2("pic/common/button_click02.png"):anchor(0.5, 0.5):add2(parent, 2)
	local curSelect = nil

	function click(tar)
		if curSelect ~= tar then
			curSelect = tar

			if self.pageNode then
				self.pageNode:removeSelf()

				self.pageNode = nil
			end

			self.pageNode = display.newNode():size(482, 292):pos(4, 8):anchor(0, 0):add2(parent, 2)

			if tar == 1 then
				net.send({
					CM_GILD_QUERY_UNION,
					tag = 30,
					series = 0
				})

				self.threeSub = 1
			elseif tar == 2 then
				net.send({
					CM_GILD_QUERY_HOSTILE,
					tag = 30,
					series = 0
				})

				self.threeSub = 2
			elseif tar == 3 then
				net.send({
					CM_GILD_QUERY_CONCERN,
					tag = 30,
					series = 0
				})

				self.threeSub = 3
			elseif tar == 4 then
				net.send({
					CM_GILD_QUERY_REQUEST_UNION_LIST,
					tag = 30,
					series = 0
				})

				self.threeSub = 4
			end
		end

		return 
	end

	for i, v in ipairs(width) do
		local eventBack = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)
		Titlelabel[i] = an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, parent.geth(parent) - 23):add2(parent)

		res.get2("pic/common/button_click.png"):anchor(0.5, 0.5):pos((posOffset + v*0.5) - 40, parent.geth(parent) - 23):add2(parent)

		if i == 1 then
			selectPic.pos(selectPic, (posOffset + v*0.5) - 40, parent.geth(parent) - 23)
		end

		local targetPox = (posOffset + v*0.5) - 40
		posOffset = posOffset + v

		eventBack.enableClick(eventBack, function ()
			selectPic:pos(targetPox, parent:geth() - 23)
			sound.playSound("103")
			click(i)

			return 
		end)
	end

	click(1)

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		self.guildBtn = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			net.send({
				CM_GILD_ENABLE_UNION,
				tag = (b and 1) or 0
			})

			return 
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
		}):anchor(0, 0.5):pos(-110, -24):add2(parent, 2)
		local value = g_data.guild.guildInfo:get("enableUnion") == 1

		self.guildBtn.btn:setIsSelect(value)
	end

	return 
end
guild.showSubDiplomatic1 = function (self, parent)
	parent = parent or self.pageNode

	if parent then
		parent.removeAllChildren(parent, true)
	end

	if self.threeSub ~= 1 then
		return 
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(parent.getw(parent), 42)):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, parent.geth(parent) - 20):add2(parent)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, parent.geth(parent) - 20):add2(parent)

	local dataList = g_data.guild.guildUnion or {}
	local infoView = an.newScroll(0, 0, 480, 248):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 480, math.max(248, #dataList*h))

	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(480, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "name"), 8)

		an.newLabel(label, 18, 1, {
			color = def.colors.labelGray
		}):add2(cell):anchor(0.5, 0.5):pos(120, h*0.5)
		an.newBtn(res.gettex2("pic/common/remove_n.png"), function ()
			net.send({
				CM_GILD_BREAK_UNION
			}, nil, {
				{
					"ID",
					v:get("ID")
				}
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/remove_s.png")
		}):add2(cell, 2):anchor(0.5, 0.5):pos(300, h*0.5)
		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						selectPic:removeSelf()

						selectPic = nil
					end

					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(478, h)):anchor(0, 0):pos(0, 0):add2(cell)
				end
			end

			return 
		end)
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			g_data.guild.guildList = {}

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
			self:showGuildList("增加联盟")

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zjlm.png")
		}):add2(parent):anchor(0.5, 0.5):pos(434, -30)
	end

	return 
end
guild.cmdFunc = function (self, cmd, name)
	local cmdData = {
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
	local msgbox = nil
	msgbox = an.newMsgbox(string.format(cmdData[cmd][1], name), function (idx)
		if idx == 1 then
			net.send({
				cmdData[cmd][2]
			}, nil, {
				{
					"string",
					name,
					15
				}
			})
		end

		return 
	end, {
		center = true,
		hasCancel = true
	})

	return 
end
guild.showGuildList = function (self, cmd)
	local tmpPic = {
		增加联盟 = "zjlm",
		行会宣战 = "hhxz",
		增加关注 = "zjgz"
	}
	self.guildListCmd = cmd or self.guildListCmd

	self.content:hide()
	self.bg:setTex(res.gettex2("pic/common/black_2.png"))

	if self.showGuildListNode then
		self.showGuildListNode:removeSelf()

		self.showGuildListNode = nil
	end

	self.showGuildListNode = display.newNode():addto(self)
	local parent = self.showGuildListNode

	parent.size(parent, self.getw(self), self.geth(self))

	local back1 = display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 0, 0, cc.size(614, 336)):anchor(0, 0):pos(14, 64):add2(parent)
	local width = {
		200,
		200,
		124,
		82
	}
	local Titlelabel = {
		"行会名",
		"会长名",
		"战队数",
		"状态"
	}
	local posOffset = 4

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, back1.geth(back1) - 23):add2(back1)
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, back1.geth(back1) - 23):add2(back1)

		posOffset = posOffset + v
	end

	local dataList = g_data.guild.guildList

	local function pageViewEvent(sender, eventType)
		if eventType == ccui.PageViewEventType.turning then
			local pageInfo = string.format("page %d", pageView:getCurPageIdx() + 1)

			print(pageInfo)
		end

		return 
	end

	local infoView = an.newScroll(4, 4, 608, 288):add2(back1)
	local h = 42

	infoView.setScrollSize(infoView, 608, math.max(288, #dataList*h))
	infoView.enableTouch(infoView, false)
	infoView.enableClick(infoView, function ()
		return 
	end)

	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "gildName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(100, h*0.5)
		label = g_data.player:fixStrLen(v.get(v, "presidentName"), 8)
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(300, h*0.5)
		label = v.get(v, "corpsCount")
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(460, h*0.5)

		if g_data.guild.curApplyguild and v.get(v, "guildID") == g_data.guild.curApplyguild then
			label = "申请中"
		else
			label = ""
		end

		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(556, h*0.5)

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v.setColor(v, def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectData = v
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, 0):add2(cell)
					selectPic.info = info

					for i, v in ipairs(info) do
						v.setColor(v, def.colors.cellSel)
					end
				end
			end

			return 
		end)

		local listener = cc.EventListenerCustom:create("UpdateNilGuildState", function ()
			if g_data.guild.curApplyguild and v:get("guildID") == g_data.guild.curApplyguild then
				info[4]:setString("申请中")
			else
				info[4]:setString("")
			end

			return 
		end)

		cell.getEventDispatcher(cell):addEventListenerWithSceneGraphPriority(listener, cell)

		if i == 1 then
			selectData = v
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(608, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info

			for i, v in ipairs(info) do
				v.setColor(v, def.colors.cellSel)
			end
		end
	end

	local filterInput = nil
	filterInput = an.newInput(0, 0, 196, 40, 7, {
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
		stop_call = function ()
			if filterInput:getString() == "" then
				self.filterString = nil

				net.send({
					CM_GILD_LIST,
					param = 0,
					tag = 7
				})

				return 
			end

			self.filterString = filterInput:getString()

			net.send({
				CM_FIND_GILD_BYNAME
			}, {
				filterInput:getString()
			})

			return 
		end
	}):add2(parent):anchor(0, 0):pos(25, 14):add(res.get2("pic/panels/voice/search.png"):pos(170, 20))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		parent:removeSelf()

		self.showGuildListNode = nil

		self.bg:setTex(res.gettex2("pic/common/black_0.png"))
		self.content:show()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mail/return.png")
	}):add2(parent):anchor(0.5, 0.5):pos(580, 38)
	print(tmpPic[self.guildListCmd])
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		if not selectData then
			return 
		end

		print(self.guildListCmd)
		self:cmdFunc(self.guildListCmd, selectData:get("gildName"))

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/" .. tmpPic[self.guildListCmd] .. ".png")
	}):add2(parent):anchor(0.5, 0.5):pos(480, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local page = g_data.guild.page + ((not g_data.guild.serach or 0) and 1)

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = page
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(380, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		local page = g_data.guild.page - 1

		if page < 0 and not g_data.guild.serach then
			self:showError(30)

			return 
		end

		if page < 0 then
			page = 0
		end

		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = page
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):add2(parent):anchor(0.5, 0.5):pos(280, 38)

	return 
end
guild.showSubDiplomatic2 = function (self, parent)
	parent = parent or self.pageNode

	if parent then
		parent.removeAllChildren(parent, true)
	end

	if self.threeSub ~= 2 then
		return 
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(parent.getw(parent), 42)):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, parent.geth(parent) - 20):add2(parent)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, parent.geth(parent) - 20):add2(parent)

	local dataList = g_data.guild.guildHostile or {}

	dump(dataList)

	local infoView = an.newScroll(0, 0, 472, 252):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 472, math.max(252, #dataList*h))

	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(472, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "name"), 8)

		an.newLabel(label, 18, 1, {
			color = def.colors.labelGray
		}):add2(cell):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, h*0.5)
		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						selectPic:removeSelf()

						selectPic = nil
					end

					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, h)):anchor(0, 0):pos(0, 0):add2(cell)
				end
			end

			return 
		end)
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			g_data.guild.guildList = {}

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
			self:showGuildList("行会宣战")

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/hhxz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(434, -30)
	end

	return 
end
guild.showSubDiplomatic3 = function (self, parent)
	parent = parent or self.pageNode

	if parent then
		parent.removeAllChildren(parent, true)
	end

	if self.threeSub ~= 3 then
		return 
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(242, 42)):anchor(0.5, 0.5):pos(121, parent.geth(parent) - 20):add2(parent)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, parent.geth(parent) - 20):add2(parent)
	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(242, 42)):anchor(0.5, 0.5):pos(361, parent.geth(parent) - 20):add2(parent)
	an.newLabel("状态", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(352, parent.geth(parent) - 20):add2(parent)

	local dataList = g_data.guild.guildConcern or {}
	local infoView = an.newScroll(0, 0, 472, 252):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 472, math.max(252, #dataList*h))

	local state = {
		"",
		"联盟中",
		"宣战中",
		"申请联盟中"
	}
	local colorArray = {
		cc.c3b(255, 255, 255),
		cc.c3b(0, 255, 0),
		cc.c3b(255, 0, 0),
		def.colors.labelGray
	}
	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(472, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "name"), 8)

		an.newLabel(label, 18, 1, {
			color = def.colors.labelGray
		}):add2(cell):anchor(0.5, 0.5):pos(120, h*0.5)

		label = state[(v.get(v, "relation") or 0) + 1] or ""

		print("relation= ", v.get(v, "relation") or " nil ", label)

		local tmpColor = colorArray[(v.get(v, "relation") or 0) + 1] or cc.c3b(255, 255, 255)

		an.newLabel(label, 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(352, h*0.5)
		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						selectPic:removeSelf()

						selectPic = nil
					end

					selectData = v
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, h)):anchor(0, 0):pos(0, 0):add2(cell)
				end
			end

			return 
		end)
	end

	if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			local msgbox = nil
			msgbox = an.newMsgbox("您确定取消对行会 " .. selectData:get("name") .. " 的关注？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_CANCLE_CONCERN
					}, nil, {
						{
							"ID",
							selectData:get("ID")
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/qxgz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(434, -30)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			g_data.guild.guildList = {}

			net.send({
				CM_GILD_LIST,
				param = 0,
				tag = 7
			})
			self:showGuildList("增加关注")

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/zjgz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(334, -30)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			local msgbox = nil
			msgbox = an.newMsgbox("您确定对行会 " .. selectData:get("name") .. " 发起宣战？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_DECLARE_WAR_NAME
					}, nil, {
						{
							"string",
							selectData:get("name"),
							15
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/fqxz.png")
		}):add2(parent):anchor(0.5, 0.5):pos(234, -30)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			if not selectData then
				return 
			end

			local msgbox = nil
			msgbox = an.newMsgbox("您确定申请与行会 " .. selectData:get("name") .. " 联盟？", function (isOk)
				if isOk == 1 then
					net.send({
						CM_GILD_REQUEST_UNION
					}, nil, {
						{
							"string",
							selectData:get("name"),
							15
						}
					})
				end

				return 
			end, {
				center = true,
				hasCancel = true
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/guild/sqlm.png")
		}):add2(parent):anchor(0.5, 0.5):pos(134, -30)
	end

	return 
end
guild.showSubDiplomatic4 = function (self, parent)
	parent = parent or self.pageNode

	if parent then
		parent.removeAllChildren(parent, true)
	end

	if self.threeSub ~= 4 then
		return 
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(parent.getw(parent), 42)):anchor(0.5, 0.5):pos(parent.getw(parent)*0.5, parent.geth(parent) - 20):add2(parent)
	an.newLabel("行会名", 20, 1, {
		color = def.colors.labelTitle
	}):anchor(0.5, 0.5):pos(120, parent.geth(parent) - 20):add2(parent)

	local dataList = g_data.guild.guildRequestUnion or {}
	local infoView = an.newScroll(0, 0, 472, 252):add2(parent)
	local h = 42

	infoView.setScrollSize(infoView, 472, math.max(252, #dataList*h))

	local selectPic, selectData = nil

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(472, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "corpsName"), 8)

		an.newLabel(label, 18, 1, {
			color = def.colors.labelGray
		}):add2(cell):anchor(0.5, 0.5):pos(120, h*0.5)

		if g_data.guild:isPresident() or g_data.guild:isVicePresident() then
			an.newBtn(res.gettex2("pic/common/accept_n.png"), function ()
				net.send({
					CM_GILD_ACCEPT_REQUEST,
					recog = 2
				}, nil, {
					{
						"ID",
						v:get("ID")
					}
				})

				return 
			end, {
				pressImage = res.gettex2("pic/common/accept_s.png")
			}):add2(cell, 2):anchor(0.5, 0.5):pos(260, h*0.5)
			an.newBtn(res.gettex2("pic/common/refuse_n.png"), function ()
				net.send({
					CM_GILD_REFUSE_REQUEST,
					recog = 2
				}, nil, {
					{
						"ID",
						v:get("ID")
					}
				})

				return 
			end, {
				pressImage = res.gettex2("pic/common/refuse_s.png")
			}):add2(cell, 2):anchor(0.5, 0.5):pos(360, h*0.5)
		end

		cell.setTouchEnabled(cell, true)
		cell.setTouchSwallowEnabled(cell, false)
		cell.addNodeEventListener(cell, cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						selectPic:removeSelf()

						selectPic = nil
					end

					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(472, h)):anchor(0, 0):pos(0, 0):add2(cell)
				end
			end

			return 
		end)
	end

	return 
end
guild.showSubLog = function (self, parent)
	local maxLine = 60
	local chatView = an.newScroll(8, 8, 472, 328, {
		labelM = {
			16,
			params = {
				maxLine = maxLine
			}
		}
	}):add2(parent)
	local msgs = g_data.guild.guildLog or {}

	if msgs then
		for i, v in ipairs(msgs) do
			chatView.labelM:addLabel(v.get(v, "logInfo"), def.colors.labelGray):nextLine()
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		net.send({
			CM_GILD_QUERY_LOG,
			param = 2,
			series = 30,
			tag = 0
		})

		self.guildLogType = 1

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/zzrz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(442, -22)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		net.send({
			CM_GILD_QUERY_LOG,
			param = 1,
			series = 30,
			tag = 0
		})

		self.guildLogType = 0

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/cyrz.png")
	}):add2(parent):anchor(0.5, 0.5):pos(342, -22)

	return 
end
guild.showOtherClanMem = function (self)
	local back = display.newNode()

	back.size(back, display.width, display.height):addto(display.getRunningScene(), an.z.msgbox)
	back.setTouchEnabled(back, true)
	back.addNodeEventListener(back, cc.NODE_TOUCH_EVENT, function ()
		return 
	end)

	local bg = res.get2("pic/common/black_4.png"):addto(back):pos(display.cx, display.cy):anchor(0.5, 0.5)

	bg.size(bg, 400, 400)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		back:removeSelf()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg.getw(bg) - 5, bg.geth(bg) - 5):anchor(1, 1)

	local width = {
		130,
		80,
		80,
		78
	}
	local Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"职务"
	}
	local posOffset = 16

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v*0.5, bg.geth(bg) - 64):add2(bg)
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v*0.5, bg.geth(bg) - 64):add2(bg)

		posOffset = posOffset + v
	end

	local infoView = an.newScroll(14, 16, 372, 300):add2(bg)
	local h = 42
	local dataList = g_data.guild.guildcorpsMem or {}
	local posTitle = {
		"",
		"副队长",
		"队长",
		"队长",
		"队长"
	}

	infoView.setScrollSize(infoView, 372, math.max(300, #dataList*h))

	for i, v in ipairs(dataList) do
		local cell = display.newScale9Sprite(res.getframe2((i%2 == 0 and "pic/scale/scale18.png") or "pic/scale/scale19.png"), 0, 0, cc.size(372, h)):anchor(0, 0):pos(0, infoView.getScrollSize(infoView).height - i*h):add2(infoView)
		local label = g_data.player:fixStrLen(v.get(v, "name"), 8)

		an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(62, h*0.5)

		label = v.get(v, "level")

		an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(172, h*0.5)

		label = g_data.player:getOtherJobStr(v.get(v, "job"))

		an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(252, h*0.5)

		label = posTitle[v.get(v, "position") + 1] or ""

		an.newLabel(label, 18, 1, {
			color = def.colors.cellNor
		}):add2(cell):anchor(0.5, 0.5):pos(330, h*0.5)
	end

	return 
end
guild.showMenu = function (self, pos, btn, data)
	if not data then
		return 
	end

	local cellCfg = {}
	local interval = 5
	local operation = {}

	if btn == "职务操作" then
		table.insert(operation, {
			title = "卸任",
			op = function ()
				if g_data.guild:isLeader() then
					if data:get("position") ~= 1 then
						main_scene.ui:tip("非副队长不能卸任")

						return 
					end

					an.newMsgbox("您确定卸任 " .. data:get("name") .. " 副队长职务吗？", function (isOk)
						if isOk == 1 then
							net.send({
								CM_CORPS_DISMISS_VICE_CAPTAIN
							}, nil, {
								{
									"ID",
									data:get("ID")
								}
							})
						end

						return 
					end, {
						center = true,
						hasCancel = true
					})
				elseif g_data.guild:isViceLeader() then
					an.newMsgbox("您确定卸任副队长职务吗？", function (isOk)
						if isOk == 1 then
							net.send({
								CM_CORPS_STEPDOWN
							}, nil, {
								{
									"ID",
									data:get("ID")
								}
							})
						end

						return 
					end, {
						center = true,
						hasCancel = true
					})
				end

				return 
			end
		})
		table.insert(operation, {
			title = "设副队长",
			op = function ()
				an.newMsgbox("您确定任命 " .. data:get("name") .. " 为副队长吗？", function (isOk)
					if isOk == 1 then
						net.send({
							CM_CORPS_APPOINT_VICE_CAPTAIN
						}, nil, {
							{
								"ID",
								data:get("ID")
							}
						})
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})

				return 
			end
		})
		table.insert(operation, {
			title = "转让队长",
			op = function ()
				an.newMsgbox("您确定转让队长职务给 " .. data:get("name") .. " 吗？", function (isOk)
					if isOk == 1 then
						if data:get("name") == common.getPlayerName() then
							main_scene.ui:tip("不能转让队长给自己")

							return 
						end

						net.send({
							CM_CORPS_TRANSFER_CAPTAIN
						}, nil, {
							{
								"ID",
								data:get("ID")
							}
						})
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})

				return 
			end
		})
	elseif btn == "更多操作" then
		table.insert(operation, {
			title = "私聊",
			op = function ()
				common.changeChatStyle({
					{
						"target",
						data:get("name")
					},
					{
						"channel",
						"私聊"
					}
				})

				return 
			end
		})
		table.insert(operation, {
			title = "查看信息",
			op = function ()
				net.send({
					CM_QUERYUSERSTATE
				}, {
					data:get("name")
				})

				return 
			end
		})
		table.insert(operation, {
			title = "添加好友",
			op = function ()
				net.send({
					CM_ADD_RELATION_FRIEND
				}, {
					data:get("name")
				})

				return 
			end
		})
		table.insert(operation, {
			title = "邀请组队",
			op = function ()
				net.send({
					(#g_data.player.groupMembers == 0 and CM_CREATEGROUP) or CM_ADDGROUPMEMBER
				}, {
					data:get("name")
				})

				return 
			end
		})
		table.insert(operation, {
			title = "添加关注",
			op = function ()
				net.send({
					CM_ADD_RELATION_ATTENTION
				}, {
					data:get("name")
				})

				return 
			end
		})
		table.insert(operation, {
			title = "拉黑名单",
			op = function ()
				net.send({
					CM_ADD_RELATION_NORMBLACKLIST
				}, {
					data:get("name")
				})

				return 
			end
		})
	end

	local panel = nil

	for k, v in ipairs(operation) do
		local c = {
			w = 94,
			h = 41,
			idx = k - 1,
			op = v,
			cellCls = function ()
				return an.newBtn(res.gettex2("pic/common/btn10.png"), function ()
					sound.playSound("103")

					local _ = c.op.op and c.op.op()

					panel:removeSelf()

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn11.png"),
					label = {
						c.op.title,
						18,
						1,
						{
							color = def.colors.btn140
						}
					}
				}):anchor(0, 0)
			end
		}
		cellCfg[k] = c
	end

	panel = common.createOperationMenu(cellCfg, interval, function (panel, cfg)
		panel.removeSelf(panel)

		return 
	end):add2(self, 10):pos(pos.x + 6, pos.y)

	return 
end
guild.showError = function (self, errorCode)
	errorCode = errorCode or 1000
	local errorMsg = {
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
		"尝试删除队长(战队队长不能被删除)",
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
		"需转让队长后才能操作 (退出)",
		"不可转让队长给自己",
		[555] = "无操作权限",
		[1000] = "未知错误"
	}

	main_scene.ui:tip(errorMsg[errorCode] or "未知错误")

	return 
end

return guild
