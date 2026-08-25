local common = import("mir2.scenes.main.common.common")
local item = import("mir2.scenes.main.common.item")
local nicehp = class("nicehp", function()
	return display.newNode()
end)

table.merge(diy, {
	data
})

local function callback(self)
	self.label:stopAllActions()

	if self.label:getContentSize().width > 130 then
		local size = self.label:getContentSize().width - 128
		local duration = size / 10

		if size > 5 then
			self.label:setAnchorPoint(cc.p(0, 0))
			self.label:setPositionX(0)

			local action = cc.MoveBy:create(duration, cc.p(-size, 0))
			local action2 = cc.MoveBy:create(duration, cc.p(size, 0))
			local action3 = cc.Sequence:create(action, action2)
			local value = cc.RepeatForever:create(action3)

			self.label:runAction(value)
		end
	end
end

local function callback2(color, value)
	local node = cc.Node:create()
	local rect = cc.ClippingRectangleNode:create(cc.rect(0, 0, 130, 50))

	rect:setPosition(cc.p(0, 0))
	node:addChild(rect)

	local label = an.newLabel(value, 14, 1, {
		bufferChannel = 0,
		color = color
	})

	label:setAnchorPoint(cc.p(0.5, 0))
	label:setPosition(62, -3)
	rect:addChild(label)

	node.label = label

	callback(node)

	return node
end

function nicehp:ctor(nicerole, roleName)
	self._supportMove = false
	g_data.nicerole = nicerole
	self.roleName = roleName

	local value = display.COLOR_WHITE
	local text = "pic/panels/newhp/mon/head.png"
	local x = display.cx
	local y = display.height - 22

	if def.mon_cfg and def.mon_cfg.monheadpos then
		x = def.mon_cfg.monheadpos.x or x
		y = def.mon_cfg.monheadpos.y or y
	end

	if nicerole.__cname == "hero" then
		local text2 = "male"

		if nicerole.sex == 1 then
			text2 = "female"
		end

		text = "pic/panels/newhp/role/" .. text2 .. "_head_" .. tostring(nicerole.job) .. ".png"
	elseif def.mon_cfg and def.mon_cfg[roleName] then
		value = def.mon_cfg[roleName].color or display.COLOR_WHITE
		text = "pic/panels/newhp/mon/" .. (def.mon_cfg[roleName].head or "pic/panels/newhp/mon/head") .. ".png"
	end

	local value_2 = res.get2("pic/panels/newhp/bghp.png"):anchor(0, 0):add2(self):pos(0, 0)

	self.head = res.get2(text):add2(value_2):pos(19, 19):enableClick(function()
		self.label2:stopAllActions()
		self.label2:runs({
			cc.ScaleTo:create(0.1, 1.3),
			cc.ScaleTo:create(0.1, 1)
		})

		if g_data.client:checkLastTime("queryOther", 1) then
			g_data.client:setLastTime("queryOther", true)

			if nicerole.__cname == "hero" then
				self:showMenu(nicerole.info:getName())
			else
				self:setmonvalue(nicerole.info:getName())
			end
		else
			main_scene.ui:tip("你查看太快了!!!")
		end
	end)

	self:size(value_2:getw(), value_2:geth()):anchor(0.5, 0.5):pos(x, y)

	self.sprhp = an.newProgress(res.gettex2("pic/panels/newhp/hp.png"), res.gettex2("pic/panels/newhp/hp1.png"), {
		x = 0,
		y = 0
	}):pos(39, 1):add2(value_2)

	self.sprhp:setp(1)

	self.label = an.newLabel("", 10, 1, {
		bufferChannel = 0
	}):pos(self.sprhp:getw() / 2, self.sprhp:geth() / 2 - 1):anchor(0.5, 0.5):add2(self.sprhp, 1)
	self.label2 = callback2(value, roleName):add2(value_2)

	self.label2:setPosition(41, value_2:geth() - 17)

	if nicerole.__cname ~= "hero" then
		local monData = self:getMonData(roleName)

		if monData and monData.Level then
			an.newLabel("Lv" .. tostring(monData.Level), 10, 1, {
				bufferChannel = 0,
				color = display.COLOR_WHITE
			}):pos(self.head:getw() / 2, 5):anchor(0.5, 0.5):addTo(self.head)
		end
	end

	self.rolecolse = an.newBtn(res.gettex2("pic/panels/newhp/close1.png"), function()
		main_scene.ui.console.controller.lock:stop()
	end, {
		pressImage = res.gettex2("pic/panels/newhp/close.png")
	}):anchor(0.5, 0.5):pos(value_2:getw() - 19, value_2:geth() / 2 + 1):addto(value_2)
	self.rolelook = an.newBtn(res.gettex2("pic/panels/newhp/ck1.png"), function()
		if g_data.client:checkLastTime("queryOther", 1) then
			g_data.client:setLastTime("queryOther", true)
			self.label2.label:stopAllActions()
			self.label2.label:runs({
				cc.ScaleTo:create(0.1, 1.3),
				cc.ScaleTo:create(0.1, 1)
			})

			if def.openShowMonDropItems then
				if nicerole.__cname == "mon" then
					self:showMonDropItems(nicerole.info:getName())
				else
					self:showMenu(nicerole.info:getRealName())
				end
			elseif nicerole.__cname == "mon" then
				self:setmonvalue(nicerole.info:getName())
			else
				self:showMenu(nicerole.info:getRealName())
			end
		else
			main_scene.ui:tip("你查看太快了!!!")
		end
	end, {
		pressImage = res.gettex2("pic/panels/newhp/ck.png")
	}):anchor(0.5, 0.5):pos(value_2:getw() - 58, value_2:geth() / 2 + 1):addto(value_2)
end

function nicehp:setActionType(actionType, actionType2, actionType3)
	return
end

function nicehp:getMonData(value2)
	local value

	if g_data.nicerole and g_data.nicerole.info and g_data.nicerole.info.hp then
		value = g_data.nicerole.info.hp.max
	end

	return def.role.getMonDatas(value2, value)
end

function nicehp:showMonDropItems(item2)
	if self.itemTips then
		self.itemTips:removeSelf()

		self.itemTips = nil
	end

	self.itemTips = display.newNode():size(display.width, display.height):addto(self)

	self.itemTips:setTouchEnabled(true)
	self.itemTips:setTouchSwallowEnabled(false)

	local background = display.newScale9Sprite(res.getframe2("pic/panels/newhp/dropItemsBg.png"), 0, 0, cc.size(248, 50)):addto(self.itemTips):anchor(0, 1)

	background:setVisible(false)
	background:pos(0, -2)

	local scroll = an.newScroll(0, 0, background:getw(), background:geth(), {
		dir = 2
	}):addto(background):anchor(0, 1):pos(0, background:geth())

	scroll:setTouchEnabled(true)
	scroll:setTouchSwallowEnabled(false)

	local monData = self:getMonData(item2)

	if monData then
		def.role.call("@ShowMonDropItems~" .. item2 .. "~" .. monData.MonName)
	else
		def.role.call("@ShowMonDropItems~" .. item2 .. "~none")
	end

	cc.EventProxy.new(_Events, self.itemTips):addEventListener("MonDropItems", function(response)
		if not response.data then
			return
		end

		background:setVisible(true)

		local value = response.data:split(",")
		local x = 25
		local y = 25
		local number = 45

		for _, item2 in ipairs(value) do
			local value2 = item2:split(":")
			local itemByName = def.items.getItemByName(value2[1], 3)

			if itemByName then
				local x2 = item.new(itemByName, self, {
					showbg = true,
					idx = 1,
					showEffect = true
				}, true):addto(scroll):pos(x, y)

				x2:setTouchEnabled(true)
				x2:setTouchSwallowEnabled(false)

				if value2[2] then
					an.newLabel(value2[2], 10, 1, {
						bufferChannel = 0,
						color = display.COLOR_WHITE
					}):pos(x2:getw() / 2, -14):anchor(0.5, 0.5):add2(x2, 1)
				end
			end

			x = x + number
		end
	end)
end

function nicehp:updateHP(text, deltaTime)
	local value = text / deltaTime

	if value > 1 then
		value = 1
	end

	if value < 0 then
		value = 0
	end

	self.sprhp:setp(value)

	if not def.hideHPNumber then
		local value2 = text / deltaTime

		if deltaTime >= 1000000 or main_scene.ground:smr() then
			local value3 = value2 * 100
			local text2 = string.format("%d", value3)

			self.label:setString(text2 .. "%")
		else
			self.label:setString(tostring(text) .. "/" .. tostring(deltaTime))
		end
	end

	if def.openGuiShu then
		if g_data.nicerole.guishu then
			if self.guishu ~= g_data.nicerole.guishu then
				self.guishu = g_data.nicerole.guishu

				self.label2.label:setString(self.roleName .. "(" .. func.filterNameFlag(self.guishu) .. ")")
				callback(self.label2)
			end
		elseif g_data.nicerole.atkRoleid then
			local role = main_scene.ground.map:findRole(g_data.nicerole.atkRoleid)

			if role and role.info and role.info:getName() ~= self.guishu then
				local guishu = role.info:getName()

				if guishu ~= self.guishu then
					self.guishu = guishu

					self.label2.label:setString(self.roleName .. "(归属:" .. func.filterNameFlag(self.guishu) .. ")")
					callback(self.label2)
				end
			end
		end
	end
end

function nicehp:showMenu(data)
	local items = {}
	local number = 6
	local items2 = {}

	table.insert(items2, {
		title = "查看信息",
		op = function()
			if main_scene.ground:smr() then
				main_scene.ui:tip("乱斗模式无法查看他人信息")
			elseif g_data.nicerole then
				net.send({
					CM_QUERYUSERSTATE,
					recog = g_data.nicerole.roleid,
					param = g_data.nicerole.x,
					tag = g_data.nicerole.y
				})
				net.send({
					CM_QUERY_TITLE,
					0,
					recog = g_data.nicerole.roleid,
					param = g_data.nicerole.x,
					tag = g_data.nicerole.y
				})
			else
				net.send({
					CM_QUERYUSERSTATE
				}, {
					data
				})
			end
		end
	})
	table.insert(items2, {
		title = "私聊",
		op = function()
			common.changeChatStyle({
				{
					"target",
					data
				},
				{
					"channel",
					"私聊"
				}
			})
		end
	})

	local relationShip = g_data.relation:getRelationShip(data)

	if not relationShip.isFriend then
		table.insert(items2, {
			title = "添加好友",
			op = function()
				net.send({
					CM_ADD_RELATION_FRIEND
				}, {
					data
				})
			end
		})
	else
		table.insert(items2, {
			title = "删除好友",
			op = function()
				net.send({
					CM_DEL_RELATION_FRIEND
				}, {
					data
				})
			end
		})
	end

	if not relationShip.isAttention then
		table.insert(items2, {
			title = "添加关注",
			op = function()
				net.send({
					CM_ADD_RELATION_ATTENTION
				}, {
					data
				})
			end
		})
	end

	if not relationShip.isBlack then
		table.insert(items2, {
			title = "加黑名单",
			op = function()
				net.send({
					CM_ADD_RELATION_NORMBLACKLIST
				}, {
					data
				})
			end
		})
	end

	table.insert(items2, {
		title = "邀请组队",
		op = function()
			net.send({
				#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
			}, {
				data
			})
		end
	})

	if #g_data.player.groupMembers == 0 then
		table.insert(items2, {
			title = "申请入队",
			op = function()
				net.send({
					CM_JOINGROUP
				}, {
					data
				})
			end
		})
	end

	local value

	for index, item2 in ipairs(items2) do
		local items3 = {
			w = 94,
			h = 41,
			idx = index - 1,
			op = item2
		}

		function items3.cellCls()
			local btn = an.newBtn(res.gettex2("pic/common/btn10.png"), function()
				sound.playSound("103")
			end, {
				pressImage = res.gettex2("pic/common/btn11.png"),
				label = {
					items3.op.title,
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

		items[index] = items3
	end

	local operationMenu = common.createOperationMenu(items, number, function(value, opOwner)
		if opOwner.op.op then
			local value2 = opOwner.op.op()
		end

		value:removeSelf()
	end, {
		width = 110
	}):add2(self):pos(38, -1 * (#items2 + 1) * 40 - 13)
end

function nicehp:setmonvalue(monvalue)
	local items = {}

	if self.monlayer then
		self.monlayer:removeSelf()

		self.monlayer = nil
	end

	local function cleanup(self, color)
		self = self or ""
		items[#items + 1] = an.newLabel(self, 18, 1, {
			color = color
		})
	end

	local value

	if g_data.nicerole and g_data.nicerole.info and g_data.nicerole.info.hp then
		local value2 = g_data.nicerole.info.hp.max
	end

	local monData = self:getMonData(monvalue)

	if monData then
		if monData.MonName then
			cleanup(_get_real_monster_name(monData.MonName), def.colors.get(251))
		end

		if monData.Undead == 0 then
			cleanup("[自然系怪物]", cc.c3b(0, 255, 0))
		else
			cleanup("[不死系怪物]", def.colors.get(255))
		end

		if monData.Level then
			cleanup(CS_LEVEL .. "：" .. monData.Level, def.colors.get(255))
		end

		if monData.Exp then
			cleanup("经验：" .. monData.Exp, def.colors.get(255))
		end

		if monData.DcMax then
			cleanup(CS_DC .. "：" .. monData.DcMax, def.colors.get(255))
		end

		if monData.HP then
			cleanup("血量：" .. monData.HP, def.colors.get(255))
		end

		if monData.MAc then
			cleanup(CS_AC .. "：" .. monData.MAc, def.colors.get(255))
		end

		if monData.WalkSpd then
			cleanup("移速：" .. monData.WalkSpd, def.colors.get(255))
		end

		if monData.Speed then
			cleanup("攻速：" .. monData.Speed, def.colors.get(255))
		end
	end

	if #items > 0 then
		self.monlayer = display.newNode():size(display.width, display.height):addto(self)

		self.monlayer:setTouchEnabled(true)
		self.monlayer:setTouchSwallowEnabled(false)
		self.monlayer:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(nameOwner)
			if nameOwner.name == "ended" and self.monlayer then
				self.monlayer:removeSelf()

				self.monlayer = nil
			end

			return true
		end)

		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(self.monlayer):anchor(0, 1)
		local width = 0
		local y = 7
		local number = -2

		for index = #items, 1, -1 do
			if index == 2 then
				y = y + 5
			end

			local value3 = items[index]:addto(background, 99):anchor(0, 0.1):pos(10, y)

			width = math.max(width, value3:getw())
			y = y + value3:geth() + number
		end

		background:size(width + 20, y):pos(38, 0)
	else
		main_scene.ui:tip("此怪物属性无法查看!")
	end
end

return nicehp
