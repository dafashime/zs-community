local item = import("mir2.scenes.main.common.item")
local common = import("mir2.scenes.main.common.common")
local freedeal = class("freedeal", function()
	return display.newNode()
end)
local items2 = {
	weapon = "武器",
	book = "技能书",
	jewelry = "首饰",
	dress = "衣服",
	bamboo = "斗笠",
	medal = "勋章",
	blstone = "魔血石",
	armor = "防具",
	other = "其他"
}
local items = {
	selled = "已售出",
	timeout = "超时下架",
	selling = "售卖中",
	unsell = "已下架",
	settled = "已结算",
	getback = "已退还"
}

function freedeal:loadres()
	display.addSpriteFrames("resource/forge/forge.plist", "resource/forge/forge.png")
	display.addSpriteFrames("resource/common.plist", "resource/common.png")
	display.addSpriteFrames("resource/icons.plist", "resource/icons.png")
	display.addSpriteFrames("resource/getProps/getProps.plist", "resource/getProps/getProps.png")
end

function freedeal:initEvents()
	self.listener = cc.EventProxy.new(_Events, self.bg):addEventListener(_Events.JSH_SELL, function(listener)
		self.tmp_imgbg:setTouchEnabled(true)

		if self.tmp_data ~= nil then
			local value = self.tmp_data:get("makeIndex")

			net.send({
				CM_COMMIT_ITEM,
				series = 1,
				recog = self.merchant,
				param = Loword(value),
				tag = Hiword(value)
			}, {
				self.tmp_data.getVar("name")
			})

			self.tmp_data = nil
		end
	end)

	self.listener:addEventListener(_Events.JSH_DOWN, function(value2)
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = self.merchant
		}, {
			"@NDownItem~" .. self.tmp_act
		})
	end)
	self.listener:addEventListener(_Events.JSH_TIMEOUT_DOWN, function(value3)
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = self.merchant
		}, {
			"@NDownItem~" .. self.tmp_act
		})
	end)
	self.listener:addEventListener(_Events.JSH_SAVING, function(value4)
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = self.merchant
		}, {
			"@NReceiveItem~" .. self.tmp_act
		})
	end)
	self.listener:addEventListener(_Events.JSH_BUY, function(value5)
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = self.merchant
		}, {
			"@NBuyItem~" .. self.rightPage
		})
	end)
end

function freedeal:ctor(merchant)
	local bg = res.get2("resource/bg/com_bg_kuang_5.png"):anchor(0, 0):add2(self)

	self.bg = bg
	self.tmp_data = nil

	self:loadres()
	self:size(bg:getw() + 100, bg:geth()):anchor(0.5, 0.5):pos(display.cx, display.cy):scale(0.8)

	self._supportMove = true
	merchant = merchant or {}
	self.merchant = merchant.merchant or def.role.helperID

	res.get2("resource/bg/title_jsh.png"):anchor(0.5, 0.5):add2(bg):pos(bg:getw() / 2 - 3, 624)

	self._scale = 0.8
	self.page = ""

	local items3 = {}

	local function callback(self2)
		sound.playSound("103")

		if self.page == self2.page then
			return
		end

		for index2, item2 in ipairs(items3) do
			if item2 == self2 then
				item2.select(item2)
				item2.label:setColor(cc.c3b(228, 220, 206))
				item2.setLocalZOrder(item2, 6)

				clickedIndex = index2
			else
				item2.unselect(item2)
				item2.label:setColor(cc.c3b(240, 200, 150))
				item2.setLocalZOrder(item2, 6 - index2)
			end
		end

		self:showMaincontent(self2.page)
		self:showRightContent()
	end

	local items4 = {
		"buy",
		"seal",
		"now",
		"introduce"
	}
	local items5 = {
		"购\n买",
		"上\n架",
		"我\n的",
		"说\n明"
	}

	for index, item3 in ipairs(items5) do
		items3[index] = an.newBtn(res.gettex2("#common/role_tab4.png"), callback, {
			label = {
				item3,
				22,
				1,
				{
					color = cc.c3b(240, 200, 150)
				}
			},
			labelOffset = {
				x = -2,
				y = 5
			},
			select = {
				res.gettex2("#common/role_tab3.png"),
				manual = true
			}
		}):anchor(0, 1):add2(self.bg, 6 - index):pos(bg:getw() - 3, bg:geth() - 50 - (index - 1) * 95)
		items3[index].page = items4[index]

		items3[index]:setCascadeOpacityEnabled(true)
		items3[index]:setTouchSwallowEnabled(false)
	end

	callback(items3[1])
	an.newBtn(res.gettex2("#common/btn_guanbi.png"), function()
		self:hidePanel()
	end, {
		pressImage = res.gettex2("#common/btn_guanbi2.png")
	}):add2(bg):anchor(0.5, 0.5):pos(882, 616)
end

function freedeal:onCleanup()
	if main_scene.ui.panels.bag and not main_scene.ui.panels.fusion and not main_scene.ui.panels.strengthen then
		main_scene.ui.panels.bag:resetPanelPosition("left")
	end

	self:delSellItem()
end

local function callback(self)
	local parts = string.split(self, "+")

	if not def.showItemNameWithPlus then
		return parts[1]
	end

	return self
end

function freedeal:showSellContent(dura, options)
	self:loadres()

	local var = dura.getVar("name")
	local node = display.newNode():size(display.width, display.height):addto(main_scene.ui, 2)
	local value_2 = res.get2("#getProps/get_bg.png"):add2(node):anchor(0.5, 0.5):pos(display.cx, display.cy)

	node:setTouchEnabled(true)
	node:setTouchSwallowEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(x2)
		if x2.name == "ended" and not cc.rectContainsPoint(value_2:getBoundingBox(), cc.p(x2.x, x2.y)) then
			node:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)
	an.newLabel(callback(var), 24, 1, {
		color = cc.c3b(217, 180, 135)
	}):add2(value_2):pos(value_2:getw() / 2, 343):anchor(0.5, 0.5)
	display.newScale9Sprite("#common/9s_dating_tipsbg.png", 0, 0, cc.size(value_2:getw() + 3, value_2:geth() + 3)):add2(value_2, -1):pos(value_2:getw() / 2, value_2:geth() / 2):anchor(0.5, 0.5)

	local background = display.newScale9Sprite("#common/rule_bg.png", 0, 0, cc.size(150, 36)):add2(value_2):pos(115, 178):anchor(0, 0)
	local label2
	local count2 = 1

	label2 = an.newInput(65, 15, 115, 80, 32, {
		label = {
			"1",
			20,
			1,
			{
				color = cc.c3b(255, 27, 205)
			}
		},
		stop_call = function()
			local number = tonumber(label2:getText())

			if number then
				if number > 0 then
					label2:setText(tostring(number))
				elseif number > 99999999 then
					main_scene.ui:fadeLabel("最高输入9999万")
					label2:setText("1")
				else
					main_scene.ui:fadeLabel("请输入大于0数字")
					label2:setText("1")
				end
			else
				main_scene.ui:fadeLabel("请输入数字")
				label2:setText("1")
			end
		end
	}):addTo(background)

	local items3 = {}

	local function callback(self2)
		sound.playSound("103")

		for _, item2 in ipairs(items3) do
			if item2 == self2 then
				item2.select(item2)
			else
				item2.unselect(item2)
			end

			count2 = self2.idx
		end
	end

	local count = 1

	for idx2, currency in pairs(def.pmh.currency) do
		if currency.isOpen then
			local value3
			local x3 = count % 2 == 1 and 112 or 200
			local value4 = count % 2
			local value5 = math.modf(count / 2)

			items3[count] = an.newBtn(res.gettex2("#common/checkbox_select_disabled.png"), callback, {
				select = {
					res.gettex2("#common/checkbox_select_up.png"),
					manual = true
				}
			}):pos(x3, 140 - math.floor((count - 1) / 2) * 40):addto(value_2):anchor(0, 0.5)

			an.newLabel(currency.name, 20, 1):add2(value_2):pos(x3 + 30, 140 - math.floor((count - 1) / 2) * 40):anchor(0, 0.5)

			items3[count].idx = idx2
			count = count + 1
		end
	end

	callback(items3[1])
	an.newLabel("价格", 20, 1, {
		color = cc.c3b(255, 255, 255)
	}):add2(value_2):pos(104, 180):anchor(1, 0)
	an.newLabel("出售货币", 20, 1, {
		color = cc.c3b(255, 255, 255)
	}):add2(value_2):pos(104, 125):anchor(1, 0)

	local value = item.new(dura, self, {
		showbg = false,
		idx = 1,
		showEffect = true
	}):addto(value_2):pos(159, 261):scale(1.05)

	if dura.isPileUp and dura.isPileUp() then
		self.dura = an.newLabel("" .. dura:get("dura"), 12, 1, {
			color = cc.c3b(0, 255, 0)
		}):anchor(1, 0):pos(16, -20):add2(value, 1)
	end

	local function cleanup()
		node:runs({
			cc.DelayTime:create(0.01),
			cc.RemoveSelf:create(true)
		})
	end

	an.newBtn(res.gettex2("#common/tips_btn.png"), function(value6)
		sound.playSound("103")

		msgbox = an.newMsgbox(string.format("确定以 %s 上架该物品吗？", label2:getText() .. def.pmh.currency[count2].name), function(value2)
			if value2 == 1 then
				options:setTouchEnabled(false)
				self:sellItem(label2:getText(), count2, dura, options)
				cleanup()
			end
		end, {
			center = true,
			hasCancel = true
		})
	end, {
		pressImage = res.gettex2("#common/tips_btn1.png"),
		label = {
			"上架",
			20,
			1,
			{
				color = cc.c3b(255, 215, 161)
			}
		}
	}):pos(158, 41):addto(value_2):anchor(0.5, 0.5)
	an.newBtn(res.gettex2("#common/btn_guanbi.png"), function()
		cleanup()
	end, {
		pressImage = res.gettex2("#common/btn_guanbi2.png")
	}):add2(value_2):anchor(1, 1):pos(value_2:getw(), value_2:geth())
end

function freedeal:pageable(value)
	return
end

function freedeal:tabsable(value)
	if self.tabs then
		for _, tab in ipairs(self.tabs) do
			tab:setTouchEnabled(value)
		end
	end
end

function freedeal:showMaincontent(page)
	self.sell = {}

	if self.gold then
		self.gold:removeSelf()

		self.gold = nil
	end

	if self.yb then
		self.yb:removeSelf()

		self.yb = nil
	end

	if self.lingFu then
		self.lingFu:removeSelf()

		self.lingFu = nil
	end

	if self.requestItem then
		self.requestItem:removeSelf()

		self.requestItem = nil
	end

	if self.rightContent then
		self.rightContent:removeSelf()

		self.rightContent = nil
	end

	if self.priceInput then
		self.priceInput:removeSelf()

		self.priceInput = nil
	end

	if self.itemlayer then
		self.itemlayer:removeSelf()

		self.itemlayer = nil
	end

	if self.itemName then
		self.itemName:removeSelf()

		self.itemName = nil
	end

	if self.content then
		self.content:removeSelf()

		self.content = nil
	end

	self.page = page
	self.content = display.newNode():add2(self.bg)

	self:loadres()

	if page == "buy" then
		local count2 = 1
		local background = display.newScale9Sprite("#common/chat_bg_bg2.png", 0, 0, cc.size(690, 40)):add2(self.content):pos(195, 36):anchor(0, 0)
		local scroll = an.newScroll(23, 31, 160, 560):add2(self.content)

		display.newScale9Sprite("#forge/forge_bg3.png", 0, 0, cc.size(160, 560)):add2(self.content):pos(23, 31):anchor(0, 0)
		display.newScale9Sprite("#forge/forge_bg3.png", 0, 0, cc.size(700, 560)):add2(self.content):pos(190, 31):anchor(0, 0)

		self.tabs = {}

		local items5 = {
			"weapon",
			"dress",
			"armor",
			"bamboo",
			"jewelry",
			"blstone",
			"medal",
			"book",
			"other"
		}
		local items6 = {
			"武器",
			"衣服",
			"防具",
			"斗笠",
			"首饰",
			"魔血石",
			"勋章",
			"技能书",
			"其他"
		}

		self.rightPage = ""

		local function callback(rightPage)
			sound.playSound("103")

			if self.rightPage == rightPage.page then
				return
			end

			for index3, tab in ipairs(self.tabs) do
				if tab == rightPage then
					tab.select(tab)
					tab.label:setColor(cc.c3b(228, 220, 206))

					clickedIndex = index3
				else
					tab.unselect(tab)
					tab.label:setColor(cc.c3b(240, 200, 150))
				end
			end

			count2 = 1
			self.loading = an.newLabel("loading...", 24, 1, {
				color = cc.c3b(213, 165, 111)
			}):add2(self.content):pos(540, 300):anchor(0.5, 0.5)
			self.rightPage = rightPage.page

			self:showRightContent()
			self:tabsable(false)
			net.send({
				CM_MERCHANTDLGSELECT,
				recog = self.merchant
			}, {
				"@RequestItem~" .. self.rightPage
			})
		end

		for index, item5 in ipairs(items6) do
			self.tabs[index] = an.newBtn(res.gettex2("#common/tab_01_2.png"), callback, {
				label = {
					item5,
					22,
					1,
					{
						color = cc.c3b(240, 200, 150)
					}
				},
				select = {
					res.gettex2("#common/tab_01_1.png"),
					manual = true
				}
			}):anchor(0.5, 1):add2(scroll):pos(80, 550 - (index - 1) * 55)
			self.tabs[index].page = items5[index]

			self.tabs[index]:setCascadeOpacityEnabled(true)
			self.tabs[index]:setTouchSwallowEnabled(false)
		end

		callback(self.tabs[1])
		res.get2("#icons/icon_jb.png"):add2(background):pos(5, background:geth() / 2):anchor(0, 0.5)

		self.gold = an.newLabel(change2GoldStyle(g_data.player.gold), 18, 1, {
			color = cc.c3b(191, 165, 127)
		}):pos(40, background:geth() / 2):addto(background):anchor(0, 0.5)

		res.get2("#icons/icon_yuanbao.png"):add2(background):pos(self.gold:getPositionX() + self.gold:getw() + 5, background:geth() / 2):anchor(0, 0.5)

		self.yb = an.newLabel(g_data.player.goldNum.gold, 18, 1, {
			color = cc.c3b(191, 165, 127)
		}):pos(self.gold:getPositionX() + self.gold:getw() + 40, background:geth() / 2):addto(background):anchor(0, 0.5)

		res.get2("#icons/icon_quan.png"):add2(background):pos(self.yb:getPositionX() + self.yb:getw() + 5, background:geth() / 2):anchor(0, 0.5)

		self.lingFu = an.newLabel(g_data.player:getGird(), 18, 1, {
			color = cc.c3b(191, 165, 127)
		}):pos(self.yb:getPositionX() + self.yb:getw() + 40, background:geth() / 2):addto(background):anchor(0, 0.5)
	elseif page == "receive" then
		def.role.call("@RequestReceive")
	elseif page == "seal" then
		an.newLabel("选择上架物品：", 24, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.content):pos(30, 548):anchor(0, 0)

		local function x2(self2)
			self2 = self2 - 1

			local value4 = self2 % 10
			local value5 = math.modf(self2 / 10)

			return 47 + value4 * 85, 330 - value5 * 85
		end

		net.send({
			CM_QUERYBAGITEMS
		})

		local background3 = display.newScale9Sprite("#common/chat_bg_bg2.png", 0, 0, cc.size(857, 384)):add2(self.content):pos(30, 151):anchor(0, 0)
		local scroll2 = an.newScroll(31, 151, 857, 382):add2(self.content)

		local function cleanup4(self5)
			return
		end

		for index5 = 1, g_data.bag.max do
			local value = g_data.bag.items[index5]

			if value then
				local text3 = "items"
				local var = value.getVar("looks") or 0

				if var > 10000 then
					text3 = text3 .. math.floor(var / 10000)
					var = var % 10000
				end

				local var2 = value.getVar("quality") or 1
				local value_2 = res.get2("#icons/quality_" .. var2 .. ".png"):scale(1.3):add2(scroll2):pos(x2(index5))

				res.get2("#common/iteminfo_bg2.png"):add2(value_2):pos(value_2:getw() / 2, value_2:geth() / 2):anchor(0.5, 0.5)
				res.get(text3, var):add2(value_2):pos(value_2:getw() / 2, value_2:geth() / 2):anchor(0.5, 0.5)

				local count = 0
				local items7 = {
					"DC",
					"MC",
					"SC",
					"AC",
					"MAC"
				}

				local function cleanup2(self3)
					return value.getVar(self3)
				end

				local function cleanup3(self4)
					return value.getStd():get(self4)
				end

				for _, item4 in ipairs(items7) do
					local value2 = cleanup2("max" .. item4) or 0
					local value3 = cleanup3("max" .. item4) or 0

					count = math.max(count, value2 - value3)
				end

				if count > 0 then
					an.newLabel("+" .. count, 15, 1, {
						color = cc.c3b(194, 191, 77)
					}):add2(value_2, 99):pos(value_2:getw() - 5, 3):anchor(1, 0)
				end

				value_2:setTouchEnabled(true)
				value_2:setTouchSwallowEnabled(false)
				value_2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(offsetBeginX)
					if offsetBeginX.name == "began" then
						self.isMove = false
						value_2.offsetBeginX = offsetBeginX.x
						value_2.offsetBeginY = offsetBeginX.y

						return true
					elseif offsetBeginX.name == "moved" then
						if math.abs(value_2.offsetBeginX - offsetBeginX.x) > 5 or math.abs(value_2.offsetBeginY - offsetBeginX.y) > 5 then
							self.isMove = true
						end
					elseif offsetBeginX.name == "ended" then
						local value8 = offsetBeginX.x - value_2.offsetBeginX
						local value9 = offsetBeginX.y - value_2.offsetBeginY

						if not self.isMove then
							sound.playSound("103")
							self:showSellContent(value, value_2)
						end
					end
				end)
				cc.EventProxy.new(_Events, background3):addEventListener(_Events.JSH_DeleteItem, function(response)
					if response.data.makeIndex == value:get("makeIndex") and value_2 then
						value_2:removeSelf()

						value_2 = nil
					end
				end)
			end
		end

		local label2 = an.newLabelM(880, 20, 0):add2(self.content):pos(30, 140):anchor(0, 1)

		if def.pmh.sellInfo then
			def.pmh.sellInfo(label2)
		end
	elseif page == "now" then
		net.send({
			CM_MERCHANTDLGSELECT,
			recog = self.merchant
		}, {
			"@NowSell"
		})
	elseif page == "request" then
		local scroll3 = an.newScroll(23, 31, 160, 560):add2(self.content)

		display.newScale9Sprite("#forge/forge_bg3.png", 0, 0, cc.size(160, 490)):add2(self.content):pos(23, 100):anchor(0, 0)
		display.newScale9Sprite("#forge/forge_bg3.png", 0, 0, cc.size(700, 490)):add2(self.content):pos(190, 100):anchor(0, 0)

		local items8 = {
			"他人求购",
			"我的求购",
			"完成求购"
		}
		local items3 = {}

		local function cleanup(requestPage)
			sound.playSound("103")

			for index4, item2 in ipairs(items3) do
				if item2 == requestPage then
					item2.select(item2)
					item2.label:setColor(cc.c3b(228, 220, 206))

					clickedIndex = index4
				else
					item2.unselect(item2)
					item2.label:setColor(cc.c3b(240, 200, 150))
				end
			end

			self.requestPage = requestPage.page

			net.send({
				CM_MERCHANTDLGSELECT,
				recog = self.merchant
			}, {
				"@Request~" .. requestPage.page
			})
		end

		for index2, page2 in ipairs(items8) do
			items3[index2] = an.newBtn(res.gettex2("#common/tab_01_2.png"), cleanup, {
				label = {
					page2,
					22,
					1,
					{
						color = cc.c3b(240, 200, 150)
					}
				},
				select = {
					res.gettex2("#common/tab_01_1.png"),
					manual = true
				}
			}):anchor(0.5, 1):add2(scroll3):pos(80, 550 - (index2 - 1) * 55)
			items3[index2].page = page2

			items3[index2]:setCascadeOpacityEnabled(true)
			items3[index2]:setTouchSwallowEnabled(false)
		end

		cleanup(items3[1])

		local background2 = display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(867, 65)):add2(self.content, 2):pos(23, 30):anchor(0, 0)

		an.newLabel("物品名称：", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(background2):pos(15, 32.5):anchor(0, 0.5)

		local background4 = display.newScale9Sprite("#common/9s_bg_2.png", 0, 0, cc.size(150, 32)):add2(background2):pos(120, 32.5):anchor(0, 0.5)
		local label5

		label5 = an.newInput(100, 16, 200, 40, 32, {
			label = {
				"输入求购物品",
				20
			},
			stop_call = function()
				local text2 = label5:getText()

				if text2 ~= "" then
					local itemByName = def.items.getItemByName(text2, 3)

					if itemByName then
						if self.requestItem then
							self.requestItem:removeSelf()

							self.requestItem = nil
						end

						self.requestItem = item.new(itemByName, self, {
							showbg = false,
							idx = 1,
							showEffect = true
						}, true):addto(background2):pos(700, 32.5)
					else
						if self.requestItem then
							self.requestItem:removeSelf()

							self.requestItem = nil
						end

						main_scene.ui:fadeLabel("请输入正确的物品名称")
						label5:setText("")
					end
				end
			end
		}):addTo(background4)

		an.newLabel("价格：", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(background2):pos(280, 32.5):anchor(0, 0.5)

		local background5 = display.newScale9Sprite("#common/9s_bg_2.png", 0, 0, cc.size(100, 32)):add2(background2):pos(340, 32.5):anchor(0, 0.5)
		local label4

		label4 = an.newInput(50, 16, 100, 40, 32, {
			label = {
				"1",
				20
			},
			stop_call = function()
				local number = tonumber(label4:getText())

				if number then
					if number > 0 then
						label4:setText(tostring(number))
					else
						main_scene.ui:fadeLabel("请输入大于0数字")
						label4:setText("1")
					end
				else
					main_scene.ui:fadeLabel("请输入数字")
					label4:setText("1")
				end
			end
		}):addTo(background5)

		local items9 = {
			"元宝",
			"火龙币"
		}
		local text4 = "元宝"
		local btn

		btn = an.newBtn(res.gettex2("#common/tips_btn.png"), function()
			sound.playSound("103")

			local items4 = {}
			local operationMenu

			for _2, item3 in pairs(items9) do
				local items10 = {
					w = 110,
					h = 40,
					cate = item3,
					cellCls = function()
						return an.newBtn(res.gettex2("#common/tips_btn.png"), function()
							sound.playSound("103")

							if btn.labelInfo == "  " then
								return
							end

							operationMenu:removeSelf()
							btn.label:setString(item3)

							text4 = item3

							if item3 == "全  部" then
								btn.category = nil
							end
						end, {
							pressImage = res.gettex2("#common/tips_btn1.png"),
							labelInfo = item3,
							label = {
								item3,
								20,
								1,
								{
									color = cc.c3b(204, 170, 128)
								}
							}
						})
					end
				}

				table.insert(items4, items10)
			end

			operationMenu = common.createOperationMenu(items4, 10, function(value10, value11)
				return
			end, {
				drag = true
			}):add2(btn):pos(-7, 50)
		end, {
			labelInfo = "元宝",
			pressImage = res.gettex2("#common/tips_btn.png"),
			label = {
				"元宝",
				20,
				1,
				{
					color = cc.c3b(204, 170, 128)
				}
			}
		}):anchor(0, 0.5):pos(465, 32.5):add2(background2)

		an.newLabel("展示：", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(background2):pos(600, 32.5):anchor(0, 0.5)

		local value7
		local btn2 = an.newBtn(res.gettex2("#common/tips_btn.png"), function()
			sound.playSound("103")

			local text = label5:getText()

			if text ~= "" then
				if def.items.getItemByName(text, 3) then
					msgbox = an.newMsgbox("确定发布 " .. callback(text) .. " 的求购信息吗？", function(value6)
						if value6 == 1 then
							def.role.call("@JSHUpRequest~" .. callback(text) .. "~" .. label4:getText() .. "~" .. text4)
						end
					end, {
						center = true,
						hasCancel = true
					})
				else
					main_scene.ui:fadeLabel("请输入正确的物品名称")

					return
				end
			else
				main_scene.ui:fadeLabel("请输入正确的物品名称")

				return
			end
		end, {
			pressImage = res.gettex2("#common/tips_btn1.png"),
			label = {
				"发布求购",
				20,
				1,
				{
					color = cc.c3b(239, 199, 149)
				}
			}
		}):anchor(0.5, 0.5):pos(800, 32.5):addto(background2)
	elseif page == "introduce" then
		local label3 = an.newLabelM(800, 24, 0):add2(self.content):pos(41, 562):anchor(0, 1)

		if def.pmh.memoinfo then
			def.pmh.memoinfo(label3)
		end
	end
end

function freedeal:showRightContent()
	self:loadres()

	if self.rightContent then
		self.rightContent:removeSelf()

		self.rightContent = nil
	end

	self.rightContent = display.newNode():add2(self.content)

	if self.page == "request" then
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(240, 40)):add2(self.rightContent):pos(195, 585):anchor(0, 1)
		an.newLabel("商品名称", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(315, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(110, 40)):add2(self.rightContent):pos(440, 585):anchor(0, 1)
		an.newLabel(self.requestPage == "完成求购" and "卖家名字" or "求购者", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(495, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(90, 40)):add2(self.rightContent):pos(555, 585):anchor(0, 1)
		an.newLabel("价格", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(600, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(150, 40)):add2(self.rightContent):pos(650, 585):anchor(0, 1)
		an.newLabel("剩余时间", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(725, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(80, 40)):add2(self.rightContent):pos(805, 585):anchor(0, 1)
	elseif self.page == "now" then
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(240, 40)):add2(self.rightContent):pos(30, 585):anchor(0, 1)
		an.newLabel("商品名称", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(150, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(110, 40)):add2(self.rightContent):pos(275, 585):anchor(0, 1)
		an.newLabel("类型", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(330, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(90, 40)):add2(self.rightContent):pos(390, 585):anchor(0, 1)
		an.newLabel("价格", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(435, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(250, 40)):add2(self.rightContent):pos(485, 585):anchor(0, 1)
		an.newLabel("剩余时间", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(610, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(150, 40)):add2(self.rightContent):pos(740, 585):anchor(0, 1)
		an.newLabel("下架", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(815, 565):anchor(0.5, 0.5)
	elseif self.page == "receive" then
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(240, 40)):add2(self.rightContent):pos(30, 585):anchor(0, 1)
		an.newLabel("商品名称", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(150, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(110, 40)):add2(self.rightContent):pos(275, 585):anchor(0, 1)
		an.newLabel("状态", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(330, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(90, 40)):add2(self.rightContent):pos(390, 585):anchor(0, 1)
		an.newLabel("价格", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(435, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(250, 40)):add2(self.rightContent):pos(485, 585):anchor(0, 1)
		an.newLabel("时间", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(610, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(150, 40)):add2(self.rightContent):pos(740, 585):anchor(0, 1)
		an.newLabel("领取", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(815, 565):anchor(0.5, 0.5)
	elseif self.page == "buy" then
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(240, 40)):add2(self.rightContent):pos(195, 585):anchor(0, 1)
		an.newLabel("商品名称", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(315, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(110, 40)):add2(self.rightContent):pos(440, 585):anchor(0, 1)
		an.newLabel("卖家", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(495, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(120, 40)):add2(self.rightContent):pos(555, 585):anchor(0, 1)
		an.newLabel("价格", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(615, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(120, 40)):add2(self.rightContent):pos(680, 585):anchor(0, 1)
		an.newLabel("状态", 20, 1, {
			color = cc.c3b(224, 174, 117)
		}):add2(self.rightContent):pos(740, 565):anchor(0.5, 0.5)
		display.newScale9Sprite("#common/com_bg_kuang_xian3.png", 0, 0, cc.size(80, 40)):add2(self.rightContent):pos(805, 585):anchor(0, 1)
	end
end

function freedeal:addSellItem(item2)
	self:delSellItem()

	local itemData = item2.data

	g_data.bag:delItem(itemData:get("makeIndex"))

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(itemData:get("makeIndex"))
	end

	self.sell.itemData = itemData
	self.sell.item = item.new(itemData, self):pos(60, 60):add2(self.itemlayer):scale(1.2)

	if itemData.isPileUp and itemData.isPileUp() then
		self.dura = an.newLabel("" .. itemData:get("dura"), 12, 1, {
			color = cc.c3b(0, 255, 0)
		}):anchor(1, 0):pos(16, -20):add2(self.sell.item, 1)
	end

	if self.itemName then
		self.itemName:setString(callback(itemData.getVar("name")))
	end
end

function freedeal:sellItem(item2, index3, tmp_data, tmp_imgbg)
	if self.sellDT and os.time() - self.sellDT < 3 then
		main_scene.ui:fadeLabel("操作过于频繁，请稍后再试！")
		tmp_imgbg:setTouchEnabled(true)

		return
	end

	local var2 = tmp_data.getVar("stdMode")
	local items8 = {
		nil,
		nil,
		nil,
		8,
		1,
		1,
		6,
		nil,
		nil,
		2,
		2,
		nil,
		nil,
		nil,
		3,
		4,
		nil,
		nil,
		5,
		5,
		5,
		5,
		5,
		5,
		nil,
		5,
		3,
		3,
		nil,
		7,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		9,
		nil,
		nil,
		nil,
		nil,
		nil,
		9,
		[100] = 9
	}
	local var = tmp_data.getVar("needConf")

	if var and checkExist(var, 2048, 2064, 2320, 6414, 6144, 6400, 2304, 256, 4096, 4112) or tmp_data.getVar("normalStateSet") and ycFunction:band(tmp_data.getVar("normalStateSet"), 2) ~= 0 then
		main_scene.ui:fadeLabel("绑定物品暂时无法上架！")
		tmp_imgbg:setTouchEnabled(true)

		return
	end

	if not _getysNew2 then
		os.exit()
	end

	local value = _getysNew2(tmp_data)
	local value7
	local items6 = {}
	local value8
	local items5 = {}
	local ipush = require("mir2.single.ipush")

	if ipush then
		local callback = ipush[2]

		items6 = callback and callback(tmp_data) or {}

		local callback2 = ipush[1]

		items5 = callback2 and callback2(tmp_data) or {}
	end

	if items6.元素1 and items6.元素1 > 0 then
		value[113] = items6.元素1
	end

	local function callback3(self2)
		if not self2 then
			return ""
		end

		local items4 = self2:split("-")

		if #items4 == 2 then
			local items3 = items4[1]:split("/")

			if #items3 == 3 then
				local number = tonumber(os.date("%Y", os.time()))

				if math.abs(number - tonumber(items3[1])) <= 5 then
					local value2 = utf8strs(items3[1])

					return value2[1] .. value2[2] .. value2[3] .. value2[4] .. "-" .. items3[2] .. "-" .. items3[3] .. " " .. items4[2]
				end
			end
		end

		return ""
	end

	local text = ""
	local value4 = items5.来源

	if value4 then
		local value3 = items5.角色

		if def.openMultiJob then
			value3 = value3:gsub("^N(%d?)", ""):gsub("^N", "")
		end

		text = text .. value3 .. "@" .. callback3(items5.时间)

		if value4 ~= "系统制造" then
			text = text .. "@" .. items5.地图 .. "@" .. items5.怪物
		end
	end

	local value5 = items8[var2] or 9
	local items7 = {}

	for index = 1, 20 do
		items7[index] = 0

		if value[112 + index] and value[112 + index] > 0 then
			items7[index] = value[112 + index]
		elseif value[140 + index] and value[140 + index] > 0 then
			items7[index] = value[140 + index]
		end
	end

	local function callback4(self3)
		local text2 = ""

		for index2 = 1, 20 do
			if text2 == "" then
				text2 = tostring(self3[index2])
			else
				text2 = text2 .. "~" .. tostring(self3[index2])
			end
		end

		return text2
	end

	local count = 0

	if tmp_data.isPileUp and tmp_data.isPileUp() then
		count = tmp_data.get(tmp_data, "dura")
	end

	local value6 = tmp_data:get("makeIndex")

	def.role.call("@SellItem~" .. value5 .. "~" .. item2 .. "~" .. index3 .. "~" .. callback4(items7) .. "~" .. value6 .. "~" .. count .. "~" .. text)
	main_scene.ui:fadeLabel("商品正在上架…")

	self.tmp_imgbg = tmp_imgbg
	self.tmp_data = tmp_data
	self.sellDT = os.time()
end

function aryjpmap(self)
	local items3 = {
		maxDC = 3,
		maxMAC = 2,
		maxMC = 4,
		maxSC = 5,
		maxAC = 1
	}

	if checkExist(self, 5, 6) then
		items3 = {
			maxDC = 1,
			AC = 4,
			maxMC = 2,
			maxSC = 3,
			MAC = 5
		}
	end

	return items3
end

function freedeal:getCurrencyInfoByName(value)
	for _, currency in pairs(def.pmh.currency) do
		if value == currency.name then
			return currency
		end
	end

	return nil
end

function freedeal:intNowSell(text)
	if self.page ~= "now" then
		return
	end

	self:loadres()

	local parts2 = string.split(text.body, "|")
	local scroll = an.newScroll(25, 31, 870, 515):add2(self.rightContent)

	if #parts2 == 2 then
		an.newLabel("暂无上架商品信息", 24, 1, {
			color = cc.c3b(213, 165, 111)
		}):add2(scroll):pos(435, 270):anchor(0.5, 0.5)
	end

	local items3 = {}

	for index, item2 in ipairs(parts2) do
		if index > 1 and item2 ~= "" then
			local parts3 = string.split(item2, "~")

			table.insert(items3, parts3)
		end
	end

	table.sort(items3, function(number3, number4)
		return tonumber(number3[32]) > tonumber(number4[32])
	end)

	for index2, item3 in ipairs(items3) do
		local number2 = item3
		local value2 = number2[1]
		local value12 = number2[2]
		local number = tonumber(number2[3])
		local value4 = number2[4]
		local value3 = number2[6]
		local background = display.newScale9Sprite("#common/bag_piliangbg_0.png", 0, 0, cc.size(860, 80)):pos(5, 510 - (index2 - 1) * 85):add2(scroll):anchor(0, 1)
		local value = clone(def.items.getItemByName(value2, 3))

		if value then
			value.addpa = {
				tonumber(number2[8]) or 0,
				tonumber(number2[9]) or 0,
				tonumber(number2[10]) or 0,
				tonumber(number2[11]) or 0,
				tonumber(number2[12]) or 0
			}
			value.elemts = {
				tonumber(number2[13]) or 0,
				tonumber(number2[14]) or 0,
				tonumber(number2[15]) or 0,
				tonumber(number2[16]) or 0,
				tonumber(number2[17]) or 0,
				tonumber(number2[18]) or 0,
				tonumber(number2[19]) or 0,
				tonumber(number2[20]) or 0,
				tonumber(number2[21]) or 0,
				tonumber(number2[22]) or 0,
				tonumber(number2[23]) or 0,
				tonumber(number2[24]) or 0,
				tonumber(number2[25]) or 0,
				tonumber(number2[26]) or 0,
				tonumber(number2[27]) or 0,
				tonumber(number2[28]) or 0,
				tonumber(number2[29]) or 0,
				tonumber(number2[30]) or 0,
				tonumber(number2[31]) or 0,
				tonumber(number2[32]) or 0
			}

			local text2 = number2[30]
			local parts = string.split(text2, "@")

			if #parts > 1 then
				value.laiyuan = {
					player = parts[1],
					date = parts[2],
					map = parts[3],
					monster = parts[4]
				}
			end

			local value5 = item.new(value, self, {
				showbg = false,
				idx = 1,
				showEffect = true
			}, true):addto(background):pos(35, 42)

			if tonumber(number2[31]) and tonumber(number2[31]) > 0 then
				self.dura = an.newLabel("" .. number2[31], 12, 1, {
					color = cc.c3b(0, 255, 0)
				}):anchor(1, 0):pos(16, -20):add2(value5, 1)
			end

			local value6 = (value.quality or 0) + 1
			local items4 = {
				cc.c3b(255, 255, 255),
				cc.c3b(40, 238, 0),
				cc.c3b(40, 238, 0),
				cc.c3b(0, 99, 249),
				cc.c3b(0, 99, 249),
				cc.c3b(253, 5, 130),
				cc.c3b(241, 102, 0),
				cc.c3b(245, 21, 0),
				cc.c3b(255, 255, 0)
			}
			local count = 0

			for _, addpa in ipairs(value.addpa) do
				count = math.max(count, addpa)
			end

			if count > 0 then
				an.newLabel("+" .. count, 15, 1, {
					color = cc.c3b(194, 191, 77)
				}):add2(background, 99):pos(55, 18):anchor(1, 0)
			end

			an.newLabel(callback(value2), 20, 1, {
				color = items4[value6]
			}):add2(background):pos(70, 42):anchor(0, 0.5)
			an.newLabel(items2[value3], 20, 1, {
				color = cc.c3b(1, 89, 249)
			}):add2(background):pos(300, 42):anchor(0.5, 0.5)

			local node = display.newNode():add2(background):anchor(0.5, 0.5)
			local label3 = an.newLabel(number, 20, 1, {
				color = cc.c3b(213, 165, 111)
			}):add2(node):anchor(0, 0.5)
			local currencyInfoByName = self:getCurrencyInfoByName(value4).pic
			local value_2 = res.get2(currencyInfoByName):add2(node):anchor(0, 0.5):scale(0.7):pos(label3:getw(), 0)

			node:pos(415 - (label3:getw() + value_2:getw()) / 2, 42)

			local label2 = an.newLabel(items[number2[5]], 20, 1, {
				color = cc.c3b(227, 227, 227)
			}):add2(background):pos(580, 42):anchor(0.5, 0.5)
			local btn

			if number2[5] == "selling" then
				btn = an.newBtn(res.gettex2("#common/btn_8.png"), function()
					sound.playSound("103")

					if self.downDT and os.time() - self.downDT < 3 then
						main_scene.ui:fadeLabel("操作过于频繁，请稍后再试！")

						return
					end

					msgbox = an.newMsgbox(string.format("确定下架   %s   吗？\n下架后，手续费不退还！", callback(value2)), function(value7)
						if value7 == 1 then
							def.role.call("@DownItem~" .. number2[7] .. "~" .. number2[6])
							main_scene.ui:fadeLabel("商品正在下架…")

							self.tmp_act = number2[6]

							cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_DOWN_SUC, function(response)
								local value8 = response.data.typename
								local value9 = response.data.idx

								if value8 == value3 and value9 == number2[7] then
									if btn then
										btn:removeSelf()

										btn = nil
									end

									if label2 then
										label2:setString("已下架")
										label2:setColor(cc.c3b(67, 148, 31))
									end

									res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(785, 42):anchor(0.5, 0.5)
								end
							end)

							self.downDT = os.time()
						end
					end, {
						center = true,
						hasCancel = true
					})
				end, {
					pressImage = res.gettex2("#common/btn_7.png"),
					label = {
						"下架",
						18,
						1,
						{
							color = cc.c3b(239, 199, 149)
						}
					}
				}):anchor(0.5, 0.5):pos(785, 42):addto(background)
			elseif number2[5] == "timeout" then
				btn = an.newBtn(res.gettex2("#common/btn_8.png"), function()
					sound.playSound("103")

					if self.downDT and os.time() - self.downDT < 3 then
						main_scene.ui:fadeLabel("操作过于频繁，请稍后再试！")

						return
					end

					def.role.call("@DownItem~" .. number2[7] .. "~" .. number2[5])
					main_scene.ui:fadeLabel("商品超时正在下架…")

					self.tmp_act = number2[5]

					cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_DOWN_SUC, function(response2)
						local value13 = response2.data.typename

						if response2.data.idx == number2[7] then
							if btn then
								btn:removeSelf()

								btn = nil
							end

							if label2 then
								label2:setString("已退还")
								label2:setColor(cc.c3b(67, 148, 31))
							end

							res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(785, 42):anchor(0.5, 0.5)
						end
					end)

					self.downDT = os.time()
				end, {
					pressImage = res.gettex2("#common/btn_7.png"),
					label = {
						"退还",
						18,
						1,
						{
							color = cc.c3b(239, 199, 149)
						}
					}
				}):anchor(0.5, 0.5):pos(785, 42):addto(background)
			elseif number2[5] == "selled" then
				btn = an.newBtn(res.gettex2("#common/btn_8.png"), function()
					sound.playSound("103")

					if self.downDT and os.time() - self.downDT < 3 then
						main_scene.ui:fadeLabel("操作过于频繁，请稍后再试！")

						return
					end

					def.role.call("@ReceiveItem~" .. number2[7] .. "~" .. number2[6])
					main_scene.ui:fadeLabel("商品正在结算…")

					self.tmp_act = number2[6]

					cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_DOWN_SUC, function(response3)
						local value10 = response3.data.typename
						local value11 = response3.data.idx

						if value10 == value3 and value11 == number2[7] then
							if btn then
								btn:removeSelf()

								btn = nil
							end

							if label2 then
								label2:setString("已结算")
								label2:setColor(cc.c3b(67, 148, 31))
							end

							res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(785, 42):anchor(0.5, 0.5)
						end
					end)

					self.downDT = os.time()
				end, {
					pressImage = res.gettex2("#common/btn_7.png"),
					label = {
						"结算",
						18,
						1,
						{
							color = cc.c3b(239, 199, 149)
						}
					}
				}):anchor(0.5, 0.5):pos(785, 42):addto(background)
			end
		end
	end
end

function freedeal:intItem(item4)
	if self.page ~= "buy" then
		return
	end

	self:loadres()

	local scroll = an.newScroll(190, 76, 870, 470):add2(self.rightContent):anchor(0, 0)

	scroll.scrollView:scrollTo(0, 430)

	local parts2 = string.split(item4.body, "|")

	if #parts2 == 2 then
		an.newLabel("暂无商品信息", 24, 1, {
			color = cc.c3b(213, 165, 111)
		}):add2(scroll):pos(350, 300):anchor(0.5, 0.5)
	end

	local items3 = {}

	for index, item2 in ipairs(parts2) do
		if index > 1 and item2 ~= "" then
			local parts3 = string.split(item2, "~")

			table.insert(items3, parts3)
		end
	end

	table.sort(items3, function(number3, number4)
		return tonumber(number3[32]) > tonumber(number4[32])
	end)

	for index2, item3 in ipairs(items3) do
		local number2 = item3
		local value2 = number2[1]
		local value3 = number2[2]
		local number = tonumber(number2[3])
		local value4 = number2[4]
		local background = display.newScale9Sprite("#common/bag_piliangbg_0.png", 0, 0, cc.size(690, 80)):pos(5, 510 - (index2 - 1) * 85):add2(scroll):anchor(0, 1)
		local value = clone(def.items.getItemByName(value2, 3))

		if value then
			value.addpa = {
				tonumber(number2[8]) or 0,
				tonumber(number2[9]) or 0,
				tonumber(number2[10]) or 0,
				tonumber(number2[11]) or 0,
				tonumber(number2[12]) or 0
			}
			value.elemts = {
				tonumber(number2[13]) or 0,
				tonumber(number2[14]) or 0,
				tonumber(number2[15]) or 0,
				tonumber(number2[16]) or 0,
				tonumber(number2[17]) or 0,
				tonumber(number2[18]) or 0,
				tonumber(number2[19]) or 0,
				tonumber(number2[20]) or 0,
				tonumber(number2[21]) or 0,
				tonumber(number2[22]) or 0,
				tonumber(number2[23]) or 0,
				tonumber(number2[24]) or 0,
				tonumber(number2[25]) or 0,
				tonumber(number2[26]) or 0,
				tonumber(number2[27]) or 0,
				tonumber(number2[28]) or 0,
				tonumber(number2[29]) or 0,
				tonumber(number2[30]) or 0,
				tonumber(number2[31]) or 0,
				tonumber(number2[32]) or 0
			}

			local text = number2[30]
			local parts = string.split(text, "@")

			if #parts > 1 then
				value.laiyuan = {
					player = parts[1],
					date = parts[2],
					map = parts[3],
					monster = parts[4]
				}
			end

			local value5 = item.new(value, self, {
				showbg = false,
				idx = 1,
				showEffect = true
			}, true):addto(background):pos(35, 42)

			if tonumber(number2[31]) and tonumber(number2[31]) > 0 then
				self.dura = an.newLabel("" .. number2[31], 12, 1, {
					color = cc.c3b(0, 255, 0)
				}):anchor(1, 0):pos(16, -20):add2(value5, 1)
			end

			local value6 = (value.quality or 0) + 1
			local items4 = {
				cc.c3b(255, 255, 255),
				cc.c3b(40, 238, 0),
				cc.c3b(40, 238, 0),
				cc.c3b(0, 99, 249),
				cc.c3b(0, 99, 249),
				cc.c3b(253, 5, 130),
				cc.c3b(241, 102, 0),
				cc.c3b(245, 21, 0),
				cc.c3b(255, 255, 0)
			}
			local count = 0

			for _, addpa in ipairs(value.addpa) do
				count = math.max(count, addpa)
			end

			if count > 0 then
				an.newLabel("+" .. count, 15, 1, {
					color = cc.c3b(194, 191, 77)
				}):add2(background, 99):pos(55, 18):anchor(1, 0)
			end

			an.newLabel(callback(value2), 20, 1, {
				color = items4[value6]
			}):add2(background):pos(70, 42):anchor(0, 0.5)
			an.newLabel(value3, 20, 1, {
				color = cc.c3b(1, 89, 249)
			}):add2(background):pos(300, 42):anchor(0.5, 0.5)

			local node = display.newNode():add2(background):anchor(0.5, 0.5)
			local label3 = an.newLabel(number, 20, 1, {
				color = cc.c3b(213, 165, 111)
			}):add2(node):anchor(0, 0.5)
			local currencyInfoByName = self:getCurrencyInfoByName(value4)
			local value7 = currencyInfoByName.pic
			local value_2 = res.get2(value7):add2(node):anchor(0, 0.5):scale(0.7):pos(label3:getw(), 0)

			node:pos(430 - (label3:getw() + value_2:getw()) / 2, 42)

			local value11
			local label2 = an.newLabel(items[number2[5]], 20, 1, {
				color = number2[5] == "selling" and cc.c3b(227, 227, 227) or cc.c3b(184, 13, 13)
			}):add2(background):pos(545, 42):anchor(0.5, 0.5)
			local btn

			if number2[5] == "selling" then
				btn = an.newBtn(res.gettex2("#common/btn_8.png"), function()
					sound.playSound("103")

					if self.downDT and os.time() - self.downDT < 3 then
						main_scene.ui:fadeLabel("操作过于频繁，请稍后再试！")

						return
					end

					if currencyInfoByName.id == 1 then
						if g_data.player.gold < number then
							main_scene.ui:fadeLabel(string.format("%不足，无法购买", currencyInfoByName.name))

							return
						end
					elseif currencyInfoByName.id == 2 then
						if g_data.player.goldNum.gold < number then
							main_scene.ui:fadeLabel(string.format("%不足，无法购买", currencyInfoByName.name))

							return
						end
					elseif currencyInfoByName.id == 3 and g_data.player:getGird() < number then
						main_scene.ui:fadeLabel(string.format("%不足，无法购买", currencyInfoByName.name))

						return
					end

					msgbox = an.newMsgbox(string.format("确定花费  %s  购买  %s  吗？", number .. currencyInfoByName.name, callback(value2)), function(value8)
						if value8 == 1 then
							def.role.call("@BuyItem~" .. number2[7] .. "~" .. tostring(g_data.player.roleid) .. "~" .. self.rightPage)
							main_scene.ui:fadeLabel("正在购买商品…")
							cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_BUY_SUC, function(response)
								local value9 = response.data.typename
								local value10 = response.data.idx

								if value9 == number2[6] and value10 == number2[7] then
									if btn then
										btn:removeSelf()

										btn = nil
									end

									if label2 then
										label2:setString("已购买")
										label2:setColor(cc.c3b(67, 148, 31))
									end

									res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(640, 42):anchor(0.5, 0.5)
								end
							end)

							self.downDT = os.time()
						end
					end, {
						center = true,
						hasCancel = true
					})
				end, {
					pressImage = res.gettex2("#common/btn_7.png"),
					label = {
						"购买",
						18,
						1,
						{
							color = cc.c3b(239, 199, 149)
						}
					}
				}):anchor(0.5, 0.5):pos(640, 42):addto(background)
			end
		end
	end

	self:pageable(true)
	self:tabsable(true)

	if self.loading then
		self.loading:removeSelf()

		self.loading = nil
	end
end

function freedeal:commitByData(value)
	if not value then
		NEWITEM = nil

		return
	end

	local value2 = value:get("makeIndex")

	net.send({
		CM_COMMIT_ITEM,
		series = 1,
		recog = self.merchant,
		param = Loword(value2),
		tag = Hiword(value2)
	}, {
		value.getVar("name")
	})

	NEWITEM = nil
end

function freedeal:updataNum()
	if self.gold then
		self.gold:setString(change2GoldStyle(g_data.player.gold))
	end

	if self.yb then
		self.yb:setString(g_data.player.goldNum.gold)
	end

	if self.lingFu then
		self.lingFu:setString(g_data.player:getGird())
	end
end

function freedeal:putItem(item2, x2, y2)
	if not self.itemlayer then
		return
	end

	if item2.formPanel.__cname == "bag" then
		local size = self.itemlayer:getBoundingBox()
		local rect = cc.rect(size.x * self:getScale(), size.y * self:getScale(), size.width * self:getScale(), size.height * self:getScale())

		if cc.rectContainsPoint(rect, cc.p(x2, y2)) then
			self:addSellItem(item2)

			return true
		end
	end
end

function freedeal:intRequest(text2)
	if self.page ~= "request" then
		return
	end

	self:loadres()

	local scroll = an.newScroll(190, 31, 700, 515):add2(self.rightContent)
	local parts2 = string.split(text2.body, "|")

	for index, item2 in ipairs(parts2) do
		if index > 1 and item2 ~= "" then
			local parts = string.split(item2, "~")
			local value = parts[1]
			local value3 = parts[2]
			local number2 = tonumber(parts[3])
			local value2 = parts[4]
			local number = self.requestPage ~= "完成求购" and 86400 - tonumber(parts[5]) or parts[5]
			local text

			if self.requestPage ~= "完成求购" then
				text = string.format("%s:%s:%s", math.modf(number / 3600), math.modf(number % 3600 / 60), number - math.modf(number / 3600) * 3600 - math.modf(number % 3600 / 60) * 60)
			else
				text = string.sub(number, string.find(number, "年") + 3, string.find(number, "分") - 3)
			end

			local background = display.newScale9Sprite("#common/bag_piliangbg_0.png", 0, 0, cc.size(690, 80)):pos(5, 510 - (index - 2) * 85):add2(scroll):anchor(0, 1)
			local itemByName = def.items.getItemByName(value, 3)

			if itemByName then
				local value7 = item.new(itemByName, self, {
					showbg = false,
					idx = 1,
					showEffect = true
				}, true):addto(background):pos(35, 42)
				local value4 = (itemByName.quality or 0) + 1
				local items3 = {
					cc.c3b(255, 255, 255),
					cc.c3b(40, 238, 0),
					cc.c3b(40, 238, 0),
					cc.c3b(0, 99, 249),
					cc.c3b(0, 99, 249),
					cc.c3b(253, 5, 130),
					cc.c3b(241, 102, 0),
					cc.c3b(245, 21, 0),
					cc.c3b(255, 255, 0)
				}

				an.newLabel(callback(value), 20, 1, {
					color = items3[value4]
				}):add2(background):pos(70, 42):anchor(0, 0.5)
				an.newLabel(value3, 20, 1, {
					color = cc.c3b(1, 89, 249)
				}):add2(background):pos(300, 42):anchor(0.5, 0.5)

				local node = display.newNode():add2(background):anchor(0.5, 0.5)
				local label3 = an.newLabel(number2, 20, 1, {
					color = cc.c3b(213, 165, 111)
				}):add2(node):anchor(0, 0.5)
				local currencyInfoByName = self:getCurrencyInfoByName(value2).pic
				local value_2 = res.get2(currencyInfoByName):add2(node):anchor(0, 0.5):scale(0.7):pos(label3:getw(), 0)

				node:pos(415 - (label3:getw() + value_2:getw()) / 2, 42)

				local value8
				local label2 = an.newLabel(text, 20, 1, {
					color = cc.c3b(227, 227, 227)
				}):add2(background):pos(530, 42):anchor(0.5, 0.5)

				if self.requestPage ~= "完成求购" then
					label2:run(cc.RepeatForever:create(transition.sequence({
						cc.DelayTime:create(1),
						cc.CallFunc:create(function()
							number = number - 1

							if number <= 0 then
								if buyBtn then
									buyBtn:removeSelf()

									buyBtn = nil
								end

								if label2 then
									label2:removeSelf()

									label2 = nil
								end

								res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(580, 42):anchor(0.5, 0.5)
							else
								label2:setString(string.format("%s:%s:%s", math.modf(number / 3600), math.modf(number % 3600 / 60), number - math.modf(number / 3600) * 3600 - math.modf(number % 3600 / 60) * 60))
							end
						end)
					})))
				end

				local btn

				btn = an.newBtn(res.gettex2("#common/btn_8.png"), function()
					sound.playSound("103")

					if self.requestPage == "他人求购" then
						msgbox = an.newMsgbox("确认将您的  " .. callback(value) .. "  物品以  " .. number2 .. value2 .. "  价格卖给他吗？   ", function(value5)
							if value5 == 1 then
								def.role.call("@JSHReqGive~" .. parts[6])
								cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_REQ_GIVE_SUC, function(response)
									if response.data.idx == parts[6] then
										if btn then
											btn:removeSelf()

											btn = nil
										end

										if label2 then
											label2:removeSelf()

											label2 = nil
										end

										res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(580, 42):anchor(0.5, 0.5)
									end
								end)
							end
						end, {
							center = true,
							hasCancel = true
						})
					elseif self.requestPage == "我的求购" then
						msgbox = an.newMsgbox("确认下架您的  " .. callback(value) .. "  物品的求购信息吗？", function(value6)
							if value6 == 1 then
								def.role.call("@JSHReqDown~" .. parts[6])
								cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_REQ_DOWN_SUC, function(response2)
									if response2.data.idx == parts[6] then
										if btn then
											btn:removeSelf()

											btn = nil
										end

										if label2 then
											label2:removeSelf()

											label2 = nil
										end

										res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(580, 42):anchor(0.5, 0.5)
									end
								end)
							end
						end, {
							center = true,
							hasCancel = true
						})
					elseif self.requestPage == "完成求购" then
						def.role.call("@JSHReqGet~" .. parts[6])
						cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_REQ_GET_SUC, function(response3)
							if response3.data.idx == parts[6] then
								if btn then
									btn:removeSelf()

									btn = nil
								end

								if label2 then
									label2:removeSelf()

									label2 = nil
								end

								res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(580, 42):anchor(0.5, 0.5)
							end
						end)
					end
				end, {
					pressImage = res.gettex2("#common/btn_7.png"),
					label = {
						self.requestPage == "他人求购" and "卖给他" or self.requestPage == "我的求购" and "下架" or "领取",
						18,
						1,
						{
							color = cc.c3b(239, 199, 149)
						}
					}
				}):anchor(0.5, 0.5):pos(640, 42):addto(background)
			end
		end
	end
end

function freedeal:intReceiveItem(item3)
	self:loadres()

	local parts2 = string.split(item3.body, "|")
	local scroll = an.newScroll(25, 31, 870, 515):add2(self.rightContent)

	for index, item2 in ipairs(parts2) do
		if index > 1 and item2 ~= "" then
			local parts = string.split(item2, "~")
			local value2 = parts[1]
			local value9 = parts[2]
			local number = tonumber(parts[3])
			local value3 = parts[4]
			local text = parts[5]
			local value4 = parts[6]
			local background = display.newScale9Sprite("#common/bag_piliangbg_0.png", 0, 0, cc.size(860, 80)):pos(5, 510 - (index - 2) * 85):add2(scroll):anchor(0, 1)
			local value = clone(def.items.getItemByName(value2, 3))

			if value then
				value.addpa = {
					tonumber(parts[8]) or 0,
					tonumber(parts[9]) or 0,
					tonumber(parts[10]) or 0,
					tonumber(parts[11]) or 0,
					tonumber(parts[12]) or 0
				}
				value.elemts = {
					tonumber(parts[13]) or 0,
					tonumber(parts[14]) or 0,
					tonumber(parts[15]) or 0,
					tonumber(parts[16]) or 0,
					tonumber(parts[17]) or 0,
					tonumber(parts[18]) or 0,
					tonumber(parts[19]) or 0,
					tonumber(parts[20]) or 0,
					tonumber(parts[21]) or 0,
					tonumber(parts[22]) or 0,
					tonumber(parts[23]) or 0,
					tonumber(parts[24]) or 0,
					tonumber(parts[25]) or 0,
					tonumber(parts[26]) or 0,
					tonumber(parts[27]) or 0,
					tonumber(parts[28]) or 0,
					tonumber(parts[29]) or 0,
					tonumber(parts[30]) or 0,
					tonumber(parts[31]) or 0,
					tonumber(parts[32]) or 0
				}

				local value5 = item.new(value, self, {
					showbg = false,
					idx = 1,
					showEffect = true
				}, true):addto(background):pos(35, 42)

				if tonumber(parts[31]) and tonumber(parts[31]) > 0 then
					self.dura = an.newLabel("" .. parts[31], 12, 1, {
						color = cc.c3b(0, 255, 0)
					}):anchor(1, 0):pos(16, -20):add2(value5, 1)
				end

				local value6 = (value.quality or 0) + 1
				local items3 = {
					cc.c3b(255, 255, 255),
					cc.c3b(40, 238, 0),
					cc.c3b(40, 238, 0),
					cc.c3b(0, 99, 249),
					cc.c3b(0, 99, 249),
					cc.c3b(253, 5, 130),
					cc.c3b(241, 102, 0),
					cc.c3b(245, 21, 0),
					cc.c3b(255, 255, 0)
				}
				local count = 0

				for _, addpa in ipairs(value.addpa) do
					count = math.max(count, addpa)
				end

				if count > 0 then
					an.newLabel("+" .. count, 15, 1, {
						color = cc.c3b(194, 191, 77)
					}):add2(background, 99):pos(55, 18):anchor(1, 0)
				end

				an.newLabel(callback(value2), 20, 1, {
					color = items3[value6]
				}):add2(background):pos(70, 42):anchor(0, 0.5)
				an.newLabel(value4, 20, 1, {
					color = cc.c3b(1, 89, 249)
				}):add2(background):pos(300, 42):anchor(0.5, 0.5)

				local node = display.newNode():add2(background):anchor(0.5, 0.5)
				local label3 = an.newLabel(number, 20, 1, {
					color = cc.c3b(213, 165, 111)
				}):add2(node):anchor(0, 0.5)
				local value7 = value3 == "元宝" and "#icons/icon_yuanbao.png" or "#icons/icon_hlb.png"
				local value_2 = res.get2(value7):add2(node):anchor(0, 0.5):scale(0.7):pos(label3:getw(), 0)

				node:pos(415 - (label3:getw() + value_2:getw()) / 2, 42)

				local value10
				local label2 = an.newLabel(string.sub(text, string.find(text, "年") + 3, string.find(text, "分") - 3), 20, 1, {
					color = cc.c3b(227, 227, 227)
				}):add2(background):pos(565, 42):anchor(0.5, 0.5)
				local btn

				btn = an.newBtn(res.gettex2("#common/btn_8.png"), function()
					sound.playSound("103")
					def.role.call("@ReceiveItem~" .. parts[7] .. "~" .. parts[6])
					cc.EventProxy.new(_Events, background):addEventListener(_Events.JSH_QUEST_SUC, function(response)
						local value8 = response.data.idx

						if response.data.typename == parts[6] and value8 == parts[7] then
							if btn then
								btn:removeSelf()

								btn = nil
							end

							if label2 then
								label2:removeSelf()

								label2 = nil
							end

							res.get2("#common/m_task_yiwancheng.png"):add2(background):pos(580, 42):anchor(0.5, 0.5)
						end
					end)
				end, {
					pressImage = res.gettex2("#common/btn_7.png"),
					label = {
						"领取",
						18,
						1,
						{
							color = cc.c3b(239, 199, 149)
						}
					}
				}):anchor(0.5, 0.5):pos(785, 42):addto(background)
			end
		end
	end
end

return freedeal
