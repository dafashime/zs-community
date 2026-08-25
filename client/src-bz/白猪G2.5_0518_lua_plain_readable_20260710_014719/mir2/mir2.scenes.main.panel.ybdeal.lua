local common = import("..common.common")
local item = import("..common.item")
local ybdeal = class("ybdeal", function()
	return display.newNode()
end)

table.merge(ybdeal, {
	context,
	tag,
	items,
	itembgs,
	tabs
})

function ybdeal:resetPanelPosition(type2)
	if type2 == "center" then
		self:anchor(0.5, 0.5):center()
	elseif type2 == "left" then
		self:anchor(0, 0.5):pos(0, display.cy)
	end

	return self
end

function ybdeal:query(value)
	local items2 = {
		CM_YBDEAL_QUERY_BUY,
		CM_YBDEAL_QUERY_SELL,
		function()
			self:upt(3)
		end,
		CM_YBDEAL_HISTROY_BUY,
		CM_YBDEAL_HISTROY_SELL,
		CM_DISPLAY_YBDEAL_SET
	}

	if type(items2[value]) == "function" then
		return items2[value]()
	else
		return net.send({
			items2[value]
		})
	end
end

function ybdeal:ctor(tagOwner)
	self._supportMove = true

	self:setNodeEventEnabled(true)

	self.items = {}
	self.itembgs = {}
	tagOwner = tagOwner or {}

	local var2 = tagOwner.tag or 1
	local value_2 = res.get2("pic/common/black_0.png"):addTo(self):pos(0, 0):anchor(0, 0)

	res.get2("pic/panels/ybdeal/title.png"):addTo(value_2):pos(value_2:getw() / 2, value_2:geth() - 14):anchor(0.5, 1)
	self:size(cc.size(value_2:getw(), value_2:geth())):resetPanelPosition("center")
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(value_2):anchor(1, 1):pos(value_2:getw() - 5, value_2:geth() - 9)

	local sprs2 = {
		"pic/panels/ybdeal/tab_buy.png",
		"pic/panels/ybdeal/tab_selling.png",
		"pic/panels/ybdeal/tab_sell.png",
		"pic/panels/ybdeal/tab_hisbuy.png",
		"pic/panels/ybdeal/tab_hissell.png",
		"pic/panels/ybdeal/tab_set.png"
	}

	self.tabs = common.tabs(value_2, {
		sprs = sprs2
	}, function(value, value2)
		self:query(value)
	end, {
		tabTp = 2,
		time = 2,
		pos = {
			offset = 55,
			x = 19,
			y = value_2:geth() - 60
		},
		default = {
			manual = true,
			var = var2
		}
	})

	display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 135, 60, cc.size(490, 344)):addTo(value_2):anchor(0, 0)
	self:upt(var2)
end

function ybdeal:onCleanup()
	self:clearItems()
end

function ybdeal:upt(tag2)
	self.tag = tag2

	self:clearItems()

	if self.context then
		self.context:removeSelf()
	end

	self.context = display.newNode():addTo(self):pos(0, 0):anchor(0, 0)

	if tag2 ~= 3 then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function(value8)
			sound.playSound("103")
			self.tabs.click(tag2)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/ybdeal/refresh.png")
		}):addTo(self.context):pos(575, 33):anchor(0.5, 0.5)
	end

	local scroll = an.newScroll(135, 65, 490, 335):addTo(self.context):anchor(0, 0)
	local number3 = 335
	local number4 = 210
	local items3 = {
		"当前无玩家向你下单。",
		"当前无正在出售的订单。",
		nil,
		"当前无历史购买过的订单。",
		"当前无历史出售过的订单。"
	}

	local function callback(self2)
		if self2 == 0 then
			an.newLabel(items3[tag2], 24, 1, {
				color = def.colors.labelGray
			}):addTo(scroll):pos(scroll:getw() / 2, scroll:geth() / 2):anchor(0.5, 0.5)
		end
	end

	local value6

	if tag2 == 1 then
		local count = 0

		for index3 = 1, #g_data.ybdeal.list_buy do
			repeat
				local value2 = g_data.ybdeal.list_buy[index3]

				if value2.timeOut ~= 0 or value2.cancel ~= 0 then
					break
				end

				count = count + 1

				local cell2 = self:createCell(value2, true):addTo(scroll):pos(scroll:getw() / 2, number3 - 5 - (count - 1) * number4):anchor(0.5, 1)

				an.newBtn(res.gettex2("pic/common/btn20.png"), function(value9)
					sound.playSound("103")

					local value10, x2 = common.msgbox("", {
						okFunc = function()
							net.send({
								CM_YBDEAL_BUY,
								recog = value2.id
							})
						end
					})

					an.newLabel(string.format("确认花费%d元宝购买这些物品么?", value2.num), 20, 1):addTo(x2):pos(x2:getw() / 2, x2:geth() / 2):anchor(0.5, 0.5)
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					sprite = res.gettex2("pic/panels/ybdeal/buy.png")
				}):addTo(cell2):pos(405, 100):anchor(0.5, 0.5)
				an.newBtn(res.gettex2("pic/common/btn20.png"), function(value11)
					sound.playSound("103")

					local value12, x3 = common.msgbox("", {
						okFunc = function()
							net.send({
								CM_YBDEAL_BUY_CANCEL,
								recog = value2.id
							})
						end
					})

					an.newLabel("确认取消此单交易么?", 20, 1):addTo(x3):pos(x3:getw() / 2, x3:geth() / 2):anchor(0.5, 0.5)
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					sprite = res.gettex2("pic/panels/ybdeal/cancel.png")
				}):addTo(cell2):pos(405, 45):anchor(0.5, 0.5)
			until true
		end

		callback(count)
	elseif tag2 == 2 then
		local count2 = 0

		for index4 = 1, #g_data.ybdeal.list_sell do
			repeat
				local value = g_data.ybdeal.list_sell[index4]

				if value.getLost and value.getLost ~= 0 then
					break
				end

				count2 = count2 + 1

				local cell = self:createCell(value, nil, nil, true):addTo(scroll):pos(scroll:getw() / 2, number3 - 5 - (count2 - 1) * number4):anchor(0.5, 1)

				an.newBtn(res.gettex2("pic/common/btn20.png"), function(value13)
					sound.playSound("103")

					local value14, x4 = common.msgbox("", {
						okFunc = function()
							net.send({
								CM_YBDEAL_SELL_CANCEL,
								recog = value.id
							})
						end
					})
					local value5 = value.timeOut ~= 0 and "订单已超时,取回物品需支付1元宝。\n是否取回?" or "确认取消此单交易,取回物品么?"

					an.newLabel(value5, 20, 1):addTo(x4):pos(x4:getw() / 2, x4:geth() / 2):anchor(0.5, 0.5)
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					sprite = res.gettex2("pic/panels/ybdeal/cancel.png")
				}):addTo(cell):pos(405, 75):anchor(0.5, 0.5)

				if value.timeOut ~= 0 then
					an.newLabel("已过期", 18, 1, {
						color = display.COLOR_RED
					}):addTo(cell):pos(405, 35):anchor(0.5, 0.5)
				elseif value.cancel ~= 0 then
					an.newLabel("买家已取消", 18, 1, {
						color = display.COLOR_RED
					}):addTo(cell):pos(405, 35):anchor(0.5, 0.5)
				end
			until true
		end

		callback(count2)
	elseif tag2 == 4 then
		for index = 1, #g_data.ybdeal.list_buyHis do
			self:createCell(g_data.ybdeal.list_buyHis[index], true, true):addTo(scroll):pos(scroll:getw() / 2, number3 - 5 - (index - 1) * number4):anchor(0.5, 1)
		end

		callback(#g_data.ybdeal.list_buyHis)
	elseif tag2 == 5 then
		for index2 = 1, #g_data.ybdeal.list_sellHis do
			self:createCell(g_data.ybdeal.list_sellHis[index2], false, true, true):addTo(scroll):pos(scroll:getw() / 2, number3 - 5 - (index2 - 1) * number4):anchor(0.5, 1)
		end

		callback(#g_data.ybdeal.list_sellHis)
	elseif tag2 == 3 then
		main_scene.ui:showPanel("bag")
		main_scene.ui.panels.bag:resetPanelPosition("ybdeal")
		main_scene.ui.panels.bag:setScaleMul(1)
		self:resetPanelPosition("left")

		local node = display.newNode():addTo(self.context):size(490, 335):pos(135, 65):anchor(0, 0)
		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale22.png"), 0, 0, cc.size(390, 175)):addTo(node):pos(node:getw() / 2, 315):anchor(0.5, 1)
		local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale23.png"), 0, 0, cc.size(350, 150)):addTo(background):pos(background:getw() / 2, 12):anchor(0.5, 0)

		self.itembgs = {}

		for index5 = 1, 2 do
			for index6 = 1, 5 do
				self.itembgs[#self.itembgs + 1] = res.get2("pic/panels/ybdeal/item.png"):addTo(background2):pos(25 + (index6 - 1) * 61, 135 - (index5 - 1) * 65):anchor(0, 1)
			end
		end

		an.newLabel("买家姓名：", 20, 1, {
			color = def.colors.labelYellow
		}):addTo(node):pos(175, 100):anchor(1, 0.5)
		an.newLabel("价格：", 20, 1, {
			color = def.colors.labelYellow
		}):addTo(node):pos(175, 50):anchor(1, 0.5)

		local label2 = an.newInput(190, 100, 200, 42, 14, {
			checkCLen = true,
			donotClip = true,
			bg = {
				h = 42,
				tex = res.gettex2("pic/scale/scale23.png"),
				offset = {
					-10,
					0
				}
			}
		}):addTo(node):anchor(0, 0.5)
		local label3 = an.newInput(190, 50, 200, 42, 5, {
			donotClip = true,
			bg = {
				h = 42,
				tex = res.gettex2("pic/scale/scale23.png"),
				offset = {
					-10,
					0
				}
			}
		}):addTo(node):anchor(0, 0.5)

		an.newBtn(res.gettex2("pic/common/btn20.png"), function(value15)
			sound.playSound("103")

			local tag3 = table.nums(self.items)
			local name2 = label2:getText()
			local text2 = label3:getText()
			local number = tonumber(text2)

			if tag3 <= 0 then
				main_scene.ui:tip("请先选择物品出售！")
			elseif string.len(name2) == 0 then
				main_scene.ui:tip("请输入买家姓名！")
			elseif string.len(text2) == 0 or not number then
				main_scene.ui:tip("请输入正确价格(1~99999)！")
			elseif number then
				if number > math.floor(number) then
					main_scene.ui:tip("请输入整数价格！")
				elseif number < 1 or number > 99999 then
					main_scene.ui:tip("请输入正确价格(1~99999)！")
				else
					local items2 = {
						getRecord("TYBDealDataHead", {
							name = name2,
							price = number
						})
					}

					for _, item2 in pairs(self.items) do
						items2[#items2 + 1] = getRecord("TYBDealData", {
							name = item2.data.getVar("name"),
							makeIndex = item2.data:get("makeIndex")
						})
					end

					g_data.ybdeal:resetSign()
					net.send({
						CM_YBDEAL_REFER_ITEMS,
						tag = tag3
					}, nil, items2)
				end
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/ybdeal/confirm_sell.png")
		}):addTo(self.context):pos(270, 33):anchor(0.5, 0.5)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function(value16)
			sound.playSound("103")
			self:upt(3)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/ybdeal/cancel.png")
		}):addTo(self.context):pos(475, 33):anchor(0.5, 0.5)
	elseif tag2 == 6 then
		local value3 = number3 - 10
		local value7 = text

		text = an.newLabel("交易设置", 22, 1, {
			color = def.colors.labelYellow
		}):addTo(scroll):pos(scroll:getw() / 2, value3):anchor(0.5, 1)

		local y2 = value3 - text:geth() - 10

		text = an.newLabel("设置接受交易的卖家最低等级", 18, 1, {
			color = display.COLOR_WHITE
		}):addTo(scroll):pos(30, y2):anchor(0, 1)

		local label

		label = an.newInput(30 + text:getw() + 10, y2 - text:geth() / 2, 84, 30, 3, {
			donotClip = true,
			bg = {
				h = 30,
				tex = res.gettex2("pic/scale/edit.png")
			},
			stop_call = function()
				local number2 = tonumber(label:getString())

				if string.len(label:getString()) == 0 or not number2 or number2 < 1 or number2 > 999 then
					main_scene.ui:tip("请输入正确等级！")
				else
					net.send({
						CM_YBDEAL_SET_OPERATE,
						param = number2
					})
				end
			end
		}):addTo(scroll):anchor(0, 0.5)

		label:setString(g_data.ybdeal.level .. "")

		local y3 = y2 - text:geth() - 10

		text = an.newLabel("设置成功后低于该等级的玩家无法向您进行元宝交易。", 18, 1, {
			color = cc.c3b(255, 191, 0)
		}):addTo(scroll):pos(30, y3):anchor(0, 1)

		local value4 = y3 - text:geth() - 10

		text = an.newLabel("交易协议", 22, 1, {
			color = def.colors.labelYellow
		}):addTo(scroll):pos(scroll:getw() / 2, value4):anchor(0.5, 1)

		local y4 = value4 - text:geth() - 10

		an.newLabelM(445, 18, 1):addTo(scroll):pos(20, y4):anchor(0, 1):nextLine():addLabel("您确定已仔细阅读了《元宝交易协议》并接受协议内的所有条款"):nextLine():addLabel("1.充值元宝是针对同一服务器的账号进行的，同一服务器下该账号的所有角色均可以使用这些元宝。"):nextLine():addLabel("2.如果物品放在NPC处出售超过3天，交易将被终止，同时卖方取回物品时需额外再支付1个元宝。"):nextLine():addLabel("3.每个角色最多同时出售4笔未完成的交易。"):nextLine():addLabel("4.卖家等级低于目标设置的交易最低等级将无法进行下单。"):nextLine()
	end
end

function ybdeal:createCell(value, value2, value3, value4)
	local background = display.newScale9Sprite(res.getframe2("pic/scale/scale22.png"), 0, 0, cc.size(480, 200))

	res.get2("pic/panels/ybdeal/yb.png"):addTo(background):pos(-2, 170):anchor(0, 0.5)
	an.newLabel((value.num and value.num or "0") .. "", 20, 1, {
		color = display.COLOR_WHITE
	}):addTo(background):pos(48, 170):anchor(0, 0.5)

	local x2 = 140
	local label = x2 + an.newLabel(value2 and "卖家：" or "买家：", 18, 1, {
		color = display.COLOR_WHITE
	}):addTo(background):pos(x2, 170):anchor(0, 0):getw()
	local label2 = an.newLabel(value.name, 22, 1, {
		color = def.colors.labelYellow
	}):addTo(background):pos(label, 168):anchor(0, 0)

	if not value4 then
		local x3 = label + label2:getw()
		local label3 = an.newLabel(" (Lv" .. value.level .. ")", 18, 1, {
			color = display.COLOR_WHITE
		}):addTo(background):pos(x3, 170):anchor(0, 0)
	end

	an.newLabel(os.date("%m-%d-%Y  %X", TDateTimeToUnixDate(value.time and value.time or os.time())), 18, 1, {
		color = display.COLOR_WHITE
	}):addTo(background):pos(140, 165):anchor(0, 1)

	local size2

	if value3 then
		size2 = cc.size(330, 135)
	else
		size2 = cc.size(450, 135)
	end

	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale23.png"), 0, 0, size2):addTo(background):pos(background:getw() / 2, 7):anchor(0.5, 0)
	local value5
	local value6

	for index = 1, 10 do
		local x4 = index < 6 and 15 + (index - 1) * 61 or 15 + (index - 6) * 61
		local y2 = index < 6 and 96 or 34
		local value_2 = res.get2("pic/panels/ybdeal/item.png"):addTo(background2):pos(x4, y2):anchor(0, 0.5)

		if value.items and value.items[index] then
			item.new(value.items[index], self, {
				showbg = false,
				showEffect = true,
				donotMove = true
			}):addTo(value_2):pos(value_2:getw() / 2, value_2:geth() / 2):anchor(0.5, 0.5)
		end
	end

	return background
end

function ybdeal:sellUpt()
	self.items = {}

	self.tabs.click(2)
end

function ybdeal:putItem(item2, x2, y2)
	repeat
		if self.tag ~= 3 then
			break
		end

		if item2.data.isBinded and item2.data.isBinded() then
			main_scene.ui:tip("绑定的物品不可出售！")

			break
		end

		if table.nums(self.items) >= 10 then
			main_scene.ui:tip("只能出售十个物品！")

			break
		end

		local enabled
		local value2 = item2.data:get("makeIndex")

		for _, item3 in ipairs(self.items) do
			if value2 == item3.data:get("makeIndex") then
				enabled = true

				break
			end
		end

		if enabled then
			main_scene.ui:tip("已选中该物品！")

			break
		end

		local value = item2.formPanel.__cname

		if value == "bag" then
			self:putInItem(item2)

			break
		end

		if value == "ybdeal" then
			break
		end

		main_scene.ui:tip("只能出售包裹里的道具！")
	until true

	return false
end

function ybdeal:putInItem(item2)
	local curIdx = self:getCurIdx()
	local x2 = self.itembgs[curIdx]
	local value = item.new(item2.data, self, {
		showbg = false,
		showEffect = true,
		form = "ybdeal"
	}):addTo(x2:getParent(), 1):pos(x2:getPositionX() + x2:getw() / 2, x2:getPositionY() - x2:geth() / 2):anchor(0.5, 0.5)

	self:addItem(value, curIdx)
end

function ybdeal:getBackItem(item2)
	self:removeItem(item2.data:get("makeIndex"))
end

function ybdeal:getCurIdx()
	if not self.items then
		self.items = {}
	end

	for index = 1, 10 do
		if not self.items[index] then
			return index
		end
	end
end

function ybdeal:addItem(item2, data)
	self.items[data] = item2

	self:delBagItem(item2.data:get("makeIndex"))
end

function ybdeal:removeItem(item3)
	for itemId, item2 in pairs(self.items) do
		if item2.data:get("makeIndex") == item3 then
			self:addBagItem(item2.data)
			item2:removeSelf()

			self.items[itemId] = nil

			break
		end
	end
end

function ybdeal:clearItems()
	local items2 = {}

	for _, item2 in pairs(self.items) do
		items2[#items2 + 1] = item2.data:get("makeIndex")
	end

	for index = 1, #items2 do
		self:removeItem(items2[index])
	end

	self.items = {}
end

function ybdeal:addBagItem(item2)
	g_data.bag:addItem(item2)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(item2:get("makeIndex"))
	end
end

function ybdeal:delBagItem(item2)
	g_data.bag:delItem(item2)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(item2)
	end
end

return ybdeal
