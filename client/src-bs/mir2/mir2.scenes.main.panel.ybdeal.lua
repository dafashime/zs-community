local common = import("..common.common")
local item = import("..common.item")
local ybdeal = class("ybdeal", function ()
	return display.newNode()
end)

table.merge(ybdeal, {
	context,
	tag,
	items,
	itembgs,
	tabs
})

ybdeal.resetPanelPosition = function (self, type)
	if type == "center" then
		self.anchor(self, 0.5, 0.5):center()
	elseif type == "left" then
		self.anchor(self, 0, 0.5):pos(0, display.cy)
	end

	return self
end
ybdeal.query = function (self, tag)
	local cmds = {
		CM_YBDEAL_QUERY_BUY,
		CM_YBDEAL_QUERY_SELL,
		function ()
			self:upt(3)

			return 
		end,
		CM_YBDEAL_HISTROY_BUY,
		CM_YBDEAL_HISTROY_SELL,
		CM_DISPLAY_YBDEAL_SET
	}

	if type(cmds[tag]) == "function" then
		return cmds[tag]()
	else
		return net.send({
			cmds[tag]
		})
	end

	return 
end
ybdeal.ctor = function (self, params)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	self.items = {}
	self.itembgs = {}
	params = params or {}
	local tag = params.tag or 1
	local bg = res.get2("pic/common/black_0.png"):addTo(self):pos(0, 0):anchor(0, 0)

	res.get2("pic/panels/ybdeal/title.png"):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 14):anchor(0.5, 1)
	self.size(self, cc.size(bg.getw(bg), bg.geth(bg))):resetPanelPosition("center")
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):anchor(1, 1):pos(bg.getw(bg) - 5, bg.geth(bg) - 9)

	local sprs = {
		"pic/panels/ybdeal/tab_buy.png",
		"pic/panels/ybdeal/tab_selling.png",
		"pic/panels/ybdeal/tab_sell.png",
		"pic/panels/ybdeal/tab_hisbuy.png",
		"pic/panels/ybdeal/tab_hissell.png",
		"pic/panels/ybdeal/tab_set.png"
	}
	self.tabs = common.tabs(bg, {
		sprs = sprs
	}, function (idx, btn)
		self:query(idx)

		return 
	end, {
		tabTp = 2,
		time = 2,
		pos = {
			offset = 55,
			x = 19,
			y = bg.geth(bg) - 60
		},
		default = {
			manual = true,
			var = tag
		}
	})

	display.newScale9Sprite(res.getframe2("pic/scale/scale16.png"), 135, 60, cc.size(490, 344)):addTo(bg):anchor(0, 0)
	self.upt(self, tag)

	return 
end
ybdeal.onCleanup = function (self)
	self.clearItems(self)

	return 
end
ybdeal.upt = function (self, tag)
	self.tag = tag

	self.clearItems(self)

	if self.context then
		self.context:removeSelf()
	end

	self.context = display.newNode():addTo(self):pos(0, 0):anchor(0, 0)

	if tag ~= 3 then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
			sound.playSound("103")
			self.tabs.click(tag)

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/ybdeal/refresh.png")
		}):addTo(self.context):pos(575, 33):anchor(0.5, 0.5)
	end

	local scroll = an.newScroll(135, 65, 490, 335):addTo(self.context):anchor(0, 0)
	local y = 335
	local sy = 210
	local msgs = {
		"当前无玩家向你下单。",
		"当前无正在出售的订单。",
		nil,
		"当前无历史购买过的订单。",
		"当前无历史出售过的订单。"
	}

	local function defaultMsg(cnt)
		if cnt == 0 then
			an.newLabel(msgs[tag], 24, 1, {
				color = def.colors.labelGray
			}):addTo(scroll):pos(scroll:getw()/2, scroll:geth()/2):anchor(0.5, 0.5)
		end

		return 
	end

	local index = nil

	if tag == 1 then
		index = 0

		for i = 1, #g_data.ybdeal.list_buy, 1 do
			while true do
				local cellData = g_data.ybdeal.list_buy[i]

				if cellData.timeOut ~= 0 or cellData.cancel ~= 0 then
					break
				end

				index = index + 1
				local cell = self.createCell(self, cellData, true):addTo(scroll):pos(scroll.getw(scroll)/2, y - 5 - (index - 1)*sy):anchor(0.5, 1)

				an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
					sound.playSound("103")

					local _, bg = common.msgbox("", {
						okFunc = function ()
							net.send({
								CM_YBDEAL_BUY,
								recog = cellData.id
							})

							return 
						end
					})

					an.newLabel(string.format("确认花费%d元宝购买这些物品么?", cellData.num), 20, 1):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg)/2):anchor(0.5, 0.5)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					sprite = res.gettex2("pic/panels/ybdeal/buy.png")
				}):addTo(cell):pos(405, 100):anchor(0.5, 0.5)
				an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
					sound.playSound("103")

					local _, bg = common.msgbox("", {
						okFunc = function ()
							net.send({
								CM_YBDEAL_BUY_CANCEL,
								recog = cellData.id
							})

							return 
						end
					})

					an.newLabel("确认取消此单交易么?", 20, 1):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg)/2):anchor(0.5, 0.5)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					sprite = res.gettex2("pic/panels/ybdeal/cancel.png")
				}):addTo(cell):pos(405, 45):anchor(0.5, 0.5)

				break
			end
		end

		defaultMsg(index)
	elseif tag == 2 then
		index = 0

		for i = 1, #g_data.ybdeal.list_sell, 1 do
			while true do
				local cellData = g_data.ybdeal.list_sell[i]

				if cellData.getLost and cellData.getLost ~= 0 then
					break
				end

				index = index + 1
				local cell = self.createCell(self, cellData, nil, nil, true):addTo(scroll):pos(scroll.getw(scroll)/2, y - 5 - (index - 1)*sy):anchor(0.5, 1)

				an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
					sound.playSound("103")

					local _, bg = common.msgbox("", {
						okFunc = function ()
							net.send({
								CM_YBDEAL_SELL_CANCEL,
								recog = cellData.id
							})

							return 
						end
					})
					local str = (cellData.timeOut ~= 0 and "订单已超时,取回物品需支付1元宝。\n是否取回?") or "确认取消此单交易,取回物品么?"

					an.newLabel(str, 20, 1):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg)/2):anchor(0.5, 0.5)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					sprite = res.gettex2("pic/panels/ybdeal/cancel.png")
				}):addTo(cell):pos(405, 75):anchor(0.5, 0.5)

				if cellData.timeOut ~= 0 then
					an.newLabel("已过期", 18, 1, {
						color = display.COLOR_RED
					}):addTo(cell):pos(405, 35):anchor(0.5, 0.5)
				elseif cellData.cancel ~= 0 then
					an.newLabel("买家已取消", 18, 1, {
						color = display.COLOR_RED
					}):addTo(cell):pos(405, 35):anchor(0.5, 0.5)
				end

				break
			end
		end

		defaultMsg(index)
	elseif tag == 4 then
		for i = 1, #g_data.ybdeal.list_buyHis, 1 do
			self.createCell(self, g_data.ybdeal.list_buyHis[i], true, true):addTo(scroll):pos(scroll.getw(scroll)/2, y - 5 - (i - 1)*sy):anchor(0.5, 1)
		end

		defaultMsg(#g_data.ybdeal.list_buyHis)
	elseif tag == 5 then
		for i = 1, #g_data.ybdeal.list_sellHis, 1 do
			self.createCell(self, g_data.ybdeal.list_sellHis[i], false, true, true):addTo(scroll):pos(scroll.getw(scroll)/2, y - 5 - (i - 1)*sy):anchor(0.5, 1)
		end

		defaultMsg(#g_data.ybdeal.list_sellHis)
	else
		if tag == 3 then
			main_scene.ui:showPanel("bag")
			main_scene.ui.panels.bag:resetPanelPosition("ybdeal")
			main_scene.ui.panels.bag:setScaleMul(1)
			self.resetPanelPosition(self, "left")

			local node = display.newNode():addTo(self.context):size(490, 335):pos(135, 65):anchor(0, 0)
			local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale22.png"), 0, 0, cc.size(390, 175)):addTo(node):pos(node.getw(node)/2, 315):anchor(0.5, 1)
			local itembg = display.newScale9Sprite(res.getframe2("pic/scale/scale23.png"), 0, 0, cc.size(350, 150)):addTo(bg):pos(bg.getw(bg)/2, 12):anchor(0.5, 0)
			self.itembgs = {}

			for j = 1, 2, 1 do
				for i = 1, 5, 1 do
					self.itembgs[#self.itembgs + 1] = res.get2("pic/panels/ybdeal/item.png"):addTo(itembg):pos((i - 1)*61 + 25, (j - 1)*65 - 135):anchor(0, 1)
				end
			end

			an.newLabel("买家姓名：", 20, 1, {
				color = def.colors.labelYellow
			}):addTo(node):pos(175, 100):anchor(1, 0.5)
			an.newLabel("价格：", 20, 1, {
				color = def.colors.labelYellow
			}):addTo(node):pos(175, 50):anchor(1, 0.5)

			local name = an.newInput(190, 100, 200, 42, 14, {
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
			local price = an.newInput(190, 50, 200, 42, 5, {
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

			an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
				sound.playSound("103")

				local num = table.nums(self.items)
				local strName = name:getText()
				local strPrice = price:getText()
				local numPrice = tonumber(strPrice)

				if num <= 0 then
					main_scene.ui:tip("请先选择物品出售！")
				elseif string.len(strName) == 0 then
					main_scene.ui:tip("请输入买家姓名！")
				elseif string.len(strPrice) == 0 or not numPrice then
					main_scene.ui:tip("请输入正确价格(1~99999)！")
				elseif numPrice then
					if math.floor(numPrice) < numPrice then
						main_scene.ui:tip("请输入整数价格！")
					elseif numPrice < 1 or 99999 < numPrice then
						main_scene.ui:tip("请输入正确价格(1~99999)！")
					else
						local buf = {
							getRecord("TYBDealDataHead", {
								name = strName,
								price = numPrice
							})
						}

						for k, v in pairs(self.items) do
							buf[#buf + 1] = getRecord("TYBDealData", {
								name = v.data.getVar("name"),
								makeIndex = v.data:get("makeIndex")
							})
						end

						g_data.ybdeal:resetSign()
						net.send({
							CM_YBDEAL_REFER_ITEMS,
							tag = num
						}, nil, buf)
					end
				end

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/ybdeal/confirm_sell.png")
			}):addTo(self.context):pos(270, 33):anchor(0.5, 0.5)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
				sound.playSound("103")
				self:upt(3)

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/ybdeal/cancel.png")
			}):addTo(self.context):pos(475, 33):anchor(0.5, 0.5)

			return 
		end

		if tag == 6 then
			local posY = y - 10
			slot9 = text
			text = an.newLabel("交易设置", 22, 1, {
				color = def.colors.labelYellow
			}):addTo(scroll):pos(scroll.getw(scroll)/2, posY):anchor(0.5, 1)
			posY = posY - text:geth() - 10
			text = an.newLabel("设置接受交易的卖家最低等级", 18, 1, {
				color = display.COLOR_WHITE
			}):addTo(scroll):pos(30, posY):anchor(0, 1)
			local level = nil
			level = an.newInput(text:getw() + 30 + 10, posY - text:geth()/2, 84, 30, 3, {
				donotClip = true,
				bg = {
					h = 30,
					tex = res.gettex2("pic/scale/edit.png")
				},
				stop_call = function ()
					local lvNum = tonumber(level:getString())

					if string.len(level:getString()) == 0 or not lvNum or lvNum < 1 or 999 < lvNum then
						main_scene.ui:tip("请输入正确等级！")
					else
						net.send({
							CM_YBDEAL_SET_OPERATE,
							param = lvNum
						})
					end

					return 
				end
			}):addTo(scroll):anchor(0, 0.5)

			level.setString(level, g_data.ybdeal.level .. "")

			posY = posY - text:geth() - 10
			text = an.newLabel("设置成功后低于该等级的玩家无法向您进行元宝交易。", 18, 1, {
				color = cc.c3b(255, 191, 0)
			}):addTo(scroll):pos(30, posY):anchor(0, 1)
			posY = posY - text:geth() - 10
			text = an.newLabel("交易协议", 22, 1, {
				color = def.colors.labelYellow
			}):addTo(scroll):pos(scroll.getw(scroll)/2, posY):anchor(0.5, 1)
			posY = posY - text:geth() - 10

			an.newLabelM(445, 18, 1):addTo(scroll):pos(20, posY):anchor(0, 1):nextLine():addLabel("您确定已仔细阅读了《元宝交易协议》并接受协议内的所有条款"):nextLine():addLabel("1.充值元宝是针对同一服务器的账号进行的，同一服务器下该账号的所有角色均可以使用这些元宝。"):nextLine():addLabel("2.如果物品放在NPC处出售超过3天，交易将被终止，同时卖方取回物品时需额外再支付1个元宝。"):nextLine():addLabel("3.每个角色最多同时出售4笔未完成的交易。"):nextLine():addLabel("4.卖家等级低于目标设置的交易最低等级将无法进行下单。"):nextLine()
		end
	end
end
ybdeal.createCell = function (self, data, toMe, history, notLv)
	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale22.png"), 0, 0, cc.size(480, 200))

	res.get2("pic/panels/ybdeal/yb.png"):addTo(bg):pos(-2, 170):anchor(0, 0.5)
	an.newLabel(((data.num and data.num) or "0") .. "", 20, 1, {
		color = display.COLOR_WHITE
	}):addTo(bg):pos(48, 170):anchor(0, 0.5)

	local posx = 140
	local label = an.newLabel((toMe and "卖家：") or "买家：", 18, 1, {
		color = display.COLOR_WHITE
	}):addTo(bg):pos(posx, 170):anchor(0, 0)
	posx = posx + label.getw(label)
	label = an.newLabel(data.name, 22, 1, {
		color = def.colors.labelYellow
	}):addTo(bg):pos(posx, 168):anchor(0, 0)

	if not notLv then
		posx = posx + label.getw(label)
		label = an.newLabel(" (Lv" .. data.level .. ")", 18, 1, {
			color = display.COLOR_WHITE
		}):addTo(bg):pos(posx, 170):anchor(0, 0)
	end

	an.newLabel(os.date("%m-%d-%Y  %X", TDateTimeToUnixDate((data.time and data.time) or os.time())), 18, 1, {
		color = display.COLOR_WHITE
	}):addTo(bg):pos(140, 165):anchor(0, 1)

	local size = nil

	if history then
		size = cc.size(330, 135)
	else
		size = cc.size(450, 135)
	end

	local itembg = display.newScale9Sprite(res.getframe2("pic/scale/scale23.png"), 0, 0, size):addTo(bg):pos(bg.getw(bg)/2, 7):anchor(0.5, 0)
	local x, y = nil

	for i = 1, 10, 1 do
		x = (i < 6 and (i - 1)*61 + 15) or (i - 6)*61 + 15

		if i < 6 then
			y = 96
		else
			y = 34
		end

		local grid = res.get2("pic/panels/ybdeal/item.png"):addTo(itembg):pos(x, y):anchor(0, 0.5)

		if data.items and data.items[i] then
			item.new(data.items[i], self, {
				donotMove = true
			}):addTo(grid):pos(grid.getw(grid)/2, grid.geth(grid)/2):anchor(0.5, 0.5)
		end
	end

	return bg
end
ybdeal.sellUpt = function (self)
	self.items = {}

	self.tabs.click(2)

	return 
end
ybdeal.putItem = function (self, bagItem, x, y)
	if self.tag == 3 or false then
		if bagItem.data.isBinded() then
			main_scene.ui:tip("绑定的物品不可出售！")
		elseif 10 <= table.nums(self.items) then
			main_scene.ui:tip("只能出售十个物品！")
		else
			local find = nil
			local makeIndex = bagItem.data:get("makeIndex")

			for i, v in ipairs(self.items) do
				if makeIndex == v.data:get("makeIndex") then
					find = true

					break
				end
			end

			if find then
				main_scene.ui:tip("已选中该物品！")
			else
				local form = bagItem.formPanel.__cname

				if form == "bag" then
					self.putInItem(self, bagItem)
				elseif form ~= "ybdeal" or false then
					main_scene.ui:tip("只能出售包裹里的道具！")
				end
			end
		end
	end

	return false
end
ybdeal.putInItem = function (self, bagItem)
	local idx = self.getCurIdx(self)
	local bg = self.itembgs[idx]
	local newItem = item.new(bagItem.data, self, {
		form = "ybdeal"
	}):addTo(bg.getParent(bg), 1):pos(bg.getPositionX(bg) + bg.getw(bg)/2, bg.getPositionY(bg) - bg.geth(bg)/2):anchor(0.5, 0.5)

	self.addItem(self, newItem, idx)

	return 
end
ybdeal.getBackItem = function (self, item)
	self.removeItem(self, item.data:get("makeIndex"))

	return 
end
ybdeal.getCurIdx = function (self)
	if not self.items then
		self.items = {}
	end

	for i = 1, 10, 1 do
		if not self.items[i] then
			return i
		end
	end

	return 
end
ybdeal.addItem = function (self, item, idx)
	self.items[idx] = item

	self.delBagItem(self, item.data:get("makeIndex"))

	return 
end
ybdeal.removeItem = function (self, makeIndex)
	for i, v in pairs(self.items) do
		if v.data:get("makeIndex") == makeIndex then
			self.addBagItem(self, v.data)
			v.removeSelf(v)

			self.items[i] = nil

			break
		end
	end

	return 
end
ybdeal.clearItems = function (self)
	local makeIndexs = {}

	for k, v in pairs(self.items) do
		makeIndexs[#makeIndexs + 1] = v.data:get("makeIndex")
	end

	for i = 1, #makeIndexs, 1 do
		self.removeItem(self, makeIndexs[i])
	end

	self.items = {}

	return 
end
ybdeal.addBagItem = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.get(data, "makeIndex"))
	end

	return 
end
ybdeal.delBagItem = function (self, makeIndex)
	g_data.bag:delItem(makeIndex)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(makeIndex)
	end

	return 
end

return ybdeal
