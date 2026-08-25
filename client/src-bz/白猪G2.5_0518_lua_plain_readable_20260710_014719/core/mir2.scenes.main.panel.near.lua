local near = class("near", function()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(near, {
	lightBtn,
	namesLayer,
	lock,
	groupLeader = false
})

function near:ctor()
	self._supportMove = true
	self.groupLeader = false
	self.lock = main_scene.ui.console.controller.lock

	local sprite = display.newSprite(res.gettex2("pic/bzmir/newui/near/black_near.png")):anchor(0, 0):add2(self)

	self.size(self, sprite.getw(sprite), sprite.geth(sprite)):anchor(0.5, 0.5):center()
	display.newSprite(res.gettex2("pic/bzmir/newui/near/title.png")):anchor(0.5, 0.5):pos(sprite.getw(sprite) * 0.5, sprite.geth(sprite) - 24):add2(sprite)

	local items3 = {
		210,
		60,
		150
	}

	self.Titlelabel = {
		"角色名",
		CS_JOB,
		"所属行会"
	}

	local x = 10

	for index, item in ipairs(items3) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(item + 2, 42)):anchor(0.5, 0.5):pos(x + item * 0.5, self.geth(self) - 74):add2(self)

		self.Titlelabel[index] = an.newLabel(self.Titlelabel[index], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(x + item * 0.5, self.geth(self) - 74):add2(self)
		x = x + item
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self)

	self.labelTitle = {
		"角色名",
		CS_LEVEL,
		CS_JOB,
		"所属行会",
		{
			"其他操作"
		},
		"操作",
		{
			"view"
		}
	}

	local items2 = {}

	if main_scene.ground.map then
		items2 = main_scene.ground.map:getHeroNameList()
	end

	local items = {}

	for _, item2 in pairs(self.lock.getLockPlayers(self.lock)) do
		item2.info:setName(item2.info.name.texts)

		local name = item2.info:getName()

		for _2, item3 in ipairs(items2) do
			if name == item3 then
				items[#items + 1] = item2
			end
		end
	end

	self:showPageInfo(items)
end

function near:showPageInfo(data)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addto(self)

	self.content:size(430, 380):anchor(1, 1):pos(self.getw(self) - 30, self.geth(self) - 75)

	data = data or {}

	local value3

	local function callback(self2, infoOwner)
		if not infoOwner then
			return
		end

		if self2 == "其他操作" then
			self:showMenu(cc.p(445, 58), infoOwner.info:getName())
		end
	end

	local value2 = self.labelTitle or {}

	self.Titlelabel[1]:setString(value2[1] or "")

	value2[5] = value2[5] or {}

	if not value2[7] then
		local items = {}
	end

	local text = "附近没有可攻击玩家"

	if g_data.player.attackMode and type(g_data.player.attackMode) == "string" then
		if g_data.player.attackMode:find("全体攻击模式") ~= nil or g_data.player.attackMode:find("全体攻击模式") ~= nil then
			attackStatus = 0
			text = "附近没有可攻击玩家"
		elseif g_data.player.attackMode:find("行会攻击模式") ~= nil then
			attackStatus = 1
			text = "附近没有其他行会玩家"
		elseif g_data.player.attackMode:find("组队攻击模式") ~= nil then
			text = "附近没有其他队伍玩家"
			attackStatus = 2
		elseif g_data.player.attackMode:find("善恶攻击模式") ~= nil then
			attackStatus = 3
			text = "附近没有敌对势力玩家"
		elseif g_data.player.attackMode:find("战队攻击模式") ~= nil then
			attackStatus = 4
			text = "附近没有其他战队玩家"
		else
			attackStatus = 5
			text = "附近没有可攻击玩家"
		end
	end

	for index2, item4 in ipairs(value2[5]) do
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")
			callback(item4, value3)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"当前附近无可选玩家。",
				20,
				1,
				{
					color = def.colors.labelGray
				}
			}
		}):add2(self):anchor(0.5, 0.5):pos(170 + index2 * 200, 45)
	end

	local scroll = an.newScroll(38, 62, 440, 300):add2(self.content)
	local y = 42

	scroll.setScrollSize(scroll, 440, math.max(320, #data * y))

	local value
	local value7

	if #data == 0 then
		an.newLabel(text or "", 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(self.content:getw() / 2 + 30, self.content:geth() / 2 + 30):add2(self.content, 2)
	end

	for index, item in ipairs(data) do
		local info = {}
		local background = display.newScale9Sprite(res.getframe2(index % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(400, y)):anchor(0, 0):pos(0, scroll.getScrollSize(scroll).height - index * y):add2(scroll)
		local color2 = cc.c3b(255, 255, 255)
		local name = item.info:getName()

		info[#info + 1] = an.newLabel(name or "", 18, 1, {
			color = color2
		}):add2(background):anchor(0.5, 0.5):pos(95, y * 0.5)

		local value4 = item.info.role.job
		local jobName = def.ccy.getJobName(value4)

		info[#info + 1] = an.newLabel(jobName, 18, 1, {
			color = color2
		}):add2(background):anchor(0.5, 0.5):pos(230, y * 0.5)

		local value5 = item.info.guildName or ""

		info[#info + 1] = an.newLabel(value5 or "", 18, 1, {
			color = color2
		}):add2(background):anchor(0.5, 0.5):pos(340, y * 0.5)

		background.setTouchEnabled(background, true)
		background.setTouchSwallowEnabled(background, false)
		background.addNodeEventListener(background, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
			if offsetBeginY.name == "began" then
				background.offsetBeginY = offsetBeginY.y

				return true
			elseif offsetBeginY.name == "ended" then
				local value6 = offsetBeginY.y - background.offsetBeginY

				if math.abs(value6) <= 5 then
					if value then
						for _2, info2 in ipairs(value.info) do
							info2.setColor(info2, value.color or def.colors.cellNor)
						end

						value:removeSelf()

						value = nil
					end

					value3 = item
					value = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(400, y)):anchor(0, 0):pos(0, 0):add2(background)
					value.info = info
					value.color = color2

					self.lock.setSelectTarget(self.lock, item)
					main_scene.ui:fadeLabel("锁定玩家 " .. item.info:getName())

					for _3, item3 in ipairs(info) do
						item3.setColor(item3, def.colors.cellSel)
					end
				end
			end
		end)

		if index == 1 then
			value3 = item
			value = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(400, y)):anchor(0, 0):pos(0, 0):add2(background)
			value.info = info
			value.color = color2

			for _, item2 in ipairs(info) do
				item2.setColor(item2, def.colors.cellSel)
			end
		end
	end
end

function near:showMenu(data, options)
	local items2 = {}
	local number = 6
	local items = {}

	table.insert(items, {
		title = "私聊",
		op = function()
			common.changeChatStyle({
				{
					"target",
					options
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
				options
			})
		end
	})

	local relationShip = g_data.relation:getRelationShip(options)

	if not relationShip.isFriend then
		table.insert(items, {
			title = "添加好友",
			op = function()
				net.send({
					CM_ADD_RELATION_FRIEND
				}, {
					options
				})
			end
		})
	else
		table.insert(items, {
			title = "删除好友",
			op = function()
				net.send({
					CM_DEL_RELATION_FRIEND
				}, {
					options
				})
			end
		})
	end

	if not relationShip.isAttention then
		table.insert(items, {
			title = "添加关注",
			op = function()
				net.send({
					CM_ADD_RELATION_ATTENTION
				}, {
					options
				})
			end
		})
	end

	if not relationShip.isBlack then
		table.insert(items, {
			title = "加黑名单",
			op = function()
				net.send({
					CM_ADD_RELATION_NORMBLACKLIST
				}, {
					options
				})
			end
		})
	end

	table.insert(items, {
		title = "邀请组队",
		op = function()
			net.send({
				#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
			}, {
				options
			})
		end
	})

	if #g_data.player.groupMembers == 0 then
		table.insert(items, {
			title = "申请入队",
			op = function()
				net.send({
					CM_JOINGROUP
				}, {
					options
				})
			end
		})
	end

	local value2

	for index, item in ipairs(items) do
		items2[index] = {
			h = 41,
			w = 94,
			idx = index - 1,
			op = item,
			cellCls = function()
				local btn = an.newBtn(res.gettex2("pic/common/btn10.png"), function()
					sound.playSound("103")
				end, {
					pressImage = res.gettex2("pic/common/btn11.png"),
					label = {
						item.title,
						18,
						1,
						{
							color = def.colors.btn20
						}
					}
				}):anchor(0.5, 0.5)

				btn.setTouchSwallowEnabled(btn, false)

				return btn
			end
		}
	end

	local operationMenu = common.createOperationMenu(items2, number, function(value, opOwner)
		if opOwner.op.op then
			local value3 = opOwner.op.op()
		end

		value.removeSelf(value)
	end, {
		width = 110
	}):add2(self):pos(data.x, data.y)
end

return near
