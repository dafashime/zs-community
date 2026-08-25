local group = class("group", function ()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(group, {
	lightBtn,
	namesLayer,
	groupLeader = false
})

function group:ctor()
	self._supportMove = true
	self.groupLeader = false
	local bg = display.newSprite(res.gettex2("pic/common/black_0.png")):anchor(0, 0):add2(self)

	self:size(bg:getw(), bg:geth()):anchor(0.5, 0.5):center()
	display.newSprite(res.gettex2("pic/panels/group/title.png")):anchor(0.5, 0.5):pos(bg:getw() * 0.5, bg:geth() - 24):add2(bg)

	local width = {
		210,
		60,
		60,
		150
	}
	self.Titlelabel = {
		"角色名",
		"等级",
		"职业",
		"所属行会"
	}
	local posOffset = 143

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v * 0.5, self:geth() - 74):add2(self)

		self.Titlelabel[i] = an.newLabel(self.Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v * 0.5, self:geth() - 74):add2(self)
		posOffset = posOffset + v
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 9, self:geth() - 8):addto(self)

	if #g_data.player.groupMembers > 1 then
		g_data.player.groupEnable = true
	end

	self.stateLabel = an.newLabel("允许组队", 18, 1, {
		color = def.colors.labelGray
	}):anchor(1, 0.5):add2(bg):pos(110, 38)

	local function click()
		if #g_data.player.groupMembers > 1 then
			return
		end

		net.send({
			CM_GROUPMODE,
			param = self.groupBtn.isSelect and 0 or 1
		})
		self.groupBtn:setIsSelect(not self.groupBtn.isSelect)
	end

	self.groupBtn = an.newBtn(res.gettex2("pic/common/toggle10.png"), click, {
		support = "easy",
		select = {
			res.gettex2("pic/common/toggle11.png"),
			manual = true
		}
	}):anchor(0, 0.5):pos(118, 38):add2(bg)

	self.groupBtn:setIsSelect(g_data.player.groupEnable)

	self.labelTitle = {
		mine = {
			"角色名",
			"等级",
			"职业",
			"所在地图",
			{
				"退出队伍",
				"添加",
				"踢出队伍"
			},
			"当前未组队。",
			{
				"tuicdw",
				"tj",
				"tcdw"
			}
		},
		near = {
			"角色名",
			"等级",
			"职业",
			"所属行会",
			{
				"其他操作"
			},
			"当前附近无其他玩家。",
			{
				"cz"
			}
		},
		group = {
			"队长名",
			"等级",
			"人数",
			"队长行会",
			{
				"申请入队"
			},
			"当前附近无其他队伍。",
			{
				"sqrd"
			}
		},
		friends = {
			"角色名",
			"等级",
			"职业",
			"所属行会",
			{
				"邀请入队"
			},
			"当前无好友在线。",
			{
				"yqrd"
			}
		}
	}
	local texts = {
		"mine",
		"near",
		"group",
		"friends"
	}
	local tabs = {}

	local function click(btn)
		sound.playSound("103")

		for i, v in ipairs(tabs) do
			if v == btn then
				v:select()
			else
				v:unselect()
			end
		end

		if btn.page ~= self.page then
			self.page = btn.page

			if self.page == "near" then
				self:showPageInfo(btn.page)

				local list = {}

				if main_scene.ground.map then
					list = main_scene.ground.map:getHeroNameList()
				end

				local data = {}

				for i, v in ipairs(list) do
					print("Near player " .. ycFunction:getStringLenWithAscii(v) .. v)

					data[#data + 1] = {
						"string",
						v,
						15
					}
				end

				if #data > 0 then
					net.send({
						CM_QUERY_NEARBYPLAYER,
						param = #list
					}, nil, data)
					print("net.send({CM_QUERY_NEARBYPLAYER,param=#data},nil,data)")
				end
			elseif self.page == "friends" then
				local data = g_data.relation:getFriends()
				local online = {}

				for i, v in ipairs(data) do
					if v:get("isonline") == 1 then
						online[#online + 1] = v
					end
				end

				self:showPageInfo(btn.page, online)
			elseif self.page == "mine" then
				net.send({
					CM_QUERY_GROUP_MEMBERS
				})
				self:showPageInfo(btn.page, g_data.player.groupMembers)
			elseif self.page == "group" then
				self:showPageInfo(btn.page)
				print("CM_QUERY_NEARBYGROUP")
				net.send({
					CM_QUERY_NEARBYGROUP
				})
			end
		end
	end

	for i, v in ipairs(texts) do
		tabs[i] = an.newBtn(res.gettex2("pic/common/btn60.png"), click, {
			support = "easy",
			sprite = res.gettex2("pic/panels/group/" .. v .. "_n.png"),
			anchor = {
				0.5,
				0.5
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):add2(bg):anchor(0, 0.5):pos(18, 370 - 54 * (i - 1))
		tabs[i].page = v
	end

	click(tabs[1])
end

function group:enableAllow()
	self.groupBtn:setIsSelect(g_data.player.groupEnable)
end

function group:showPageInfo(page, data)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addto(self)

	self.content:size(539, 387):anchor(1, 1):pos(self:getw() - 16, self:geth() - 70)

	data = data or {}

	self.groupBtn:setTouchEnabled(#g_data.player.groupMembers == 0)

	local selectRole = nil

	local function clickfunc(cmd, name)
		if cmd == "退出队伍" then
			if #g_data.player.groupMembers == 0 then
				main_scene.ui:tip("您还没有队伍。")

				return
			end

			local msgbox = nil
			msgbox = an.newMsgbox("", function (isOk)
				if isOk == 1 then
					g_data.client:setLastTime("group", true)

					g_data.player.groupEnable = false

					net.send({
						CM_DELGROUPMEMBER
					}, {
						common.getPlayerName()
					})
				end
			end, {
				hasCancel = true
			})

			an.newLabel("您确定退出队伍吗？", 20, 1, {
				color = def.colors.cellNor
			}):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 180):anchor(0.5, 0.5)
		elseif cmd == "队伍链接" then
			main_scene.ui:tip("此功能暂未开放。")
		elseif cmd == "添加" then
			if #g_data.player.groupMembers > 0 and not g_data.player.isTeamLeader then
				main_scene.ui:tip("不是队长不能添加成员。")

				return
			end

			local msgbox = nil
			msgbox = an.newMsgbox("  输入邀请组队的玩家名.", function (idx)
				if idx == 1 then
					if msgbox.nameInput:getString() == "" then
						return
					end

					if msgbox.nameInput:getString() == common.getPlayerName() then
						main_scene.ui:tip("不可邀请自己组队。")

						return
					end

					g_data.client:setLastTime("group", true)
					net.send({
						#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
					}, {
						msgbox.nameInput:getString()
					})
				end
			end, {
				disableScroll = true,
				hasCancel = true
			})
			msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 14, {
				checkCLen = true,
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
					"",
					20,
					1,
					{
						color = cc.c3b(128, 128, 128)
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
		end

		if not name then
			return
		end

		if cmd == "邀请入队" then
			local msgbox = nil
			msgbox = an.newMsgbox("", function (isOk)
				if isOk == 1 then
					g_data.client:setLastTime("group", true)
					net.send({
						#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
					}, {
						name
					})
				end
			end, {
				hasCancel = true
			})

			an.newLabel("您确定邀请 " .. name .. " 加入队伍吗？", 20, 1, {
				color = def.colors.cellNor
			}):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 180):anchor(0.5, 0.5)
		elseif cmd == "申请入队" then
			if #g_data.player.groupMembers > 0 then
				main_scene.ui:tip("您已有队伍。")
			else
				local msgbox = nil
				msgbox = an.newMsgbox("", function (isOk)
					if isOk == 1 then
						g_data.client:setLastTime("group", true)
						net.send({
							CM_JOINGROUP
						}, {
							name
						})
					end
				end, {
					hasCancel = true
				})

				an.newLabel("您确定申请加入 " .. name .. " 的队伍吗？", 20, 1, {
					color = def.colors.cellNor
				}):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 180):anchor(0.5, 0.5)
			end
		elseif cmd == "踢出队伍" then
			print("踢出队伍")

			if #g_data.player.groupMembers == 0 then
				main_scene.ui:tip("您还没有队伍。")

				return
			end

			if #g_data.player.groupMembers > 0 and not g_data.player.isTeamLeader then
				main_scene.ui:tip("不是队长不能踢出成员。")

				return
			end

			local msgbox = nil
			msgbox = an.newMsgbox("", function (isOk)
				if isOk == 1 then
					g_data.client:setLastTime("group", true)
					net.send({
						CM_DELGROUPMEMBER
					}, {
						name
					})
				end
			end, {
				hasCancel = true
			})

			an.newLabel("您确定要求 " .. name .. " 离开队伍吗？", 20, 1, {
				color = def.colors.cellNor
			}):addTo(msgbox.bg):pos(msgbox.bg:getw() / 2, 180):anchor(0.5, 0.5)
		elseif cmd == "其他操作" then
			self:showMenu(cc.p(510, 58), name)
		end
	end

	local labels = self.labelTitle[page] or {}

	for i = 1, 4 do
		self.Titlelabel[i]:setString(labels[i] or "")
	end

	labels[5] = labels[5] or {}
	local btnSpr = labels[7] or {}

	for i, v in ipairs(labels[5]) do
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")
			clickfunc(v, selectRole)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/group/" .. btnSpr[i] .. ".png")
		}):add2(self.content):anchor(0.5, 0.5):pos(580 - i * 100, 38)
	end

	local infoView = an.newScroll(58, 62, 478, 300):add2(self.content)
	local h = 42

	infoView:setScrollSize(530, math.max(320, #data * h))

	local selectPic, selectData = nil

	if #data == 0 then
		an.newLabel(labels[6] or "", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(self.content:getw() / 2 + 40, self.content:geth() / 2 + 30):add2(self.content, 2)
	end

	for i, v in ipairs(data) do
		local info = {}
		local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i * h):add2(infoView)
		local tmpColor = (page == "mine" and v:get("isonline") == 1 or page == "near") and cc.c3b(255, 255, 255) or def.colors.cellOffline
		local name = g_data.player:fixStrLen(v:get("name"), 8)
		info[#info + 1] = an.newLabel(name or "", 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(105, h * 0.5)
		local label = v:get("level") .. ""
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(240, h * 0.5)
		label = page == "group" and v:get("job") .. "" or g_data.player:getOtherJobStr(v:get("job"))
		info[#info + 1] = an.newLabel(label, 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(300, h * 0.5)

		if page == "mine" then
			label = v:get("isonline") == 1 and v:get("guildName") or "离线"
		else
			label = v:get("guildName") or ""
		end

		info[#info + 1] = an.newLabel(label or "", 18, 1, {
			color = tmpColor
		}):add2(cell):anchor(0.5, 0.5):pos(405, h * 0.5)

		if v:get("isCaptain") == 1 then
			res.get2("pic/panels/group/icon.png"):add2(cell):anchor(0.5, 0.5):pos(30, h * 0.48)
		end

		cell:setTouchEnabled(true)
		cell:setTouchSwallowEnabled(false)
		cell:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				cell.offsetBeginY = event.y

				return true
			elseif event.name == "ended" then
				local offsetY = event.y - cell.offsetBeginY

				if math.abs(offsetY) <= 5 then
					if selectPic then
						for i, v in ipairs(selectPic.info) do
							v:setColor(selectPic.color or def.colors.cellNor)
						end

						selectPic:removeSelf()

						selectPic = nil
					end

					selectRole = v:get("name")
					selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, 0):add2(cell)
					selectPic.info = info
					selectPic.color = tmpColor

					for i, v in ipairs(info) do
						v:setColor(def.colors.cellSel)
					end
				end
			end
		end)

		if i == 1 then
			selectRole = v:get("name")
			selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, 0):add2(cell)
			selectPic.info = info
			selectPic.color = tmpColor

			for i, v in ipairs(info) do
				v:setColor(def.colors.cellSel)
			end
		end
	end
end

function group:allowRequest()
	return not g_data.client.lastTime.group or socket.gettime() - g_data.client.lastTime.group > 5
end

function group:showMenu(pos, name)
	local cellCfg = {}
	local interval = 6
	local operation = {}

	table.insert(operation, {
		title = "私聊",
		op = function ()
			common.changeChatStyle({
				{
					"target",
					name
				},
				{
					"channel",
					"私聊"
				}
			})
		end
	})
	table.insert(operation, {
		title = "查看信息",
		op = function ()
			net.send({
				CM_QUERYUSERSTATE
			}, {
				name
			})
		end
	})

	local relation = g_data.relation:getRelationShip(name)

	if not relation.isFriend then
		table.insert(operation, {
			title = "添加好友",
			op = function ()
				net.send({
					CM_ADD_RELATION_FRIEND
				}, {
					name
				})
			end
		})
	else
		table.insert(operation, {
			title = "删除好友",
			op = function ()
				net.send({
					CM_DEL_RELATION_FRIEND
				}, {
					name
				})
			end
		})
	end

	if not relation.isAttention then
		table.insert(operation, {
			title = "添加关注",
			op = function ()
				net.send({
					CM_ADD_RELATION_ATTENTION
				}, {
					name
				})
			end
		})
	end

	if not relation.isBlack then
		table.insert(operation, {
			title = "加黑名单",
			op = function ()
				net.send({
					CM_ADD_RELATION_NORMBLACKLIST
				}, {
					name
				})
			end
		})
	end

	table.insert(operation, {
		title = "邀请组队",
		op = function ()
			net.send({
				#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
			}, {
				name
			})
		end
	})

	if #g_data.player.groupMembers == 0 then
		table.insert(operation, {
			title = "申请入队",
			op = function ()
				net.send({
					CM_JOINGROUP
				}, {
					name
				})
			end
		})
	end

	local panel = nil

	for k, v in ipairs(operation) do
		local c = {
			w = 94,
			h = 41,
			idx = k - 1,
			op = v
		}

		function c.cellCls()
			local btn = an.newBtn(res.gettex2("pic/common/btn10.png"), function ()
				sound.playSound("103")
			end, {
				pressImage = res.gettex2("pic/common/btn11.png"),
				label = {
					c.op.title,
					18,
					1,
					{
						color = def.colors.btn20
					}
				}
			}):anchor(0, 0)

			btn:setTouchSwallowEnabled(false)

			return btn
		end

		cellCfg[k] = c
	end

	panel = common.createOperationMenu(cellCfg, interval, function (panel, cfg)
		local _ = cfg.op.op and cfg.op.op()

		panel:removeSelf()
	end, {
		width = 110
	}):add2(self):pos(pos.x, pos.y)
end

return group
