local common = import("..common.common")
local item = import("..common.item")
local cc2 = require("mir2.cc")
local stall = class("stall", function()
	return display.newNode()
end)

table.merge(stall, {})

function stall:getPrice(level)
	return (def.stallPrice or {
		2000,
		4000,
		7000,
		12000
	})[level]
end

function stall:getMaxTime(value)
	return (def.stallTimeMax or {
		12,
		12,
		12,
		12
	})[value]
end

function stall:getMaxBox(value)
	return value * 5
end

function stall:resetPanelPosition(type)
	if type == "left" then
		self:anchor(1, 0.5):pos(display.cx - 70, display.cy + 50)
	elseif type == "center" then
		self:anchor(0.5, 0.5):pos(display.cx, display.cy)
	end

	return self
end

function stall:ctor()
	self._supportMove = true
	self.level = 1
	self.timeValue = 1
	self.items = {}

	if table.nums(g_data.stall.items) <= 0 and g_data.stall.state == 0 then
		self:showChoosePanel()
	else
		self:showStallPanel()
	end
end

function stall:showChoosePanel()
	local bg2 = res.get2("pic/common/msgbox.png"):addTo(self):anchor(0, 0)

	self.choosePanel = bg2

	self:size(bg2:getContentSize()):resetPanelPosition("center")
	res.get2("pic/panels/stall/level.png"):addTo(bg2):pos(bg2:getw() / 2, bg2:geth() - 20)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg2):pos(bg2:getw() - 5, bg2:geth() - 4):anchor(1, 1)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if self.level == 0 then
			main_scene.ui:tip("请选择您的摊位类型！")
		elseif self.timeValue == 0 then
			main_scene.ui:tip("请选择您的摆摊时间！")
		elseif g_data.player.gold < self:getPrice(self.level) * self.timeValue then
			main_scene.ui:tip("您的金币不足！")
		else
			net.send({
				CM_SET_STALL_TIMELV,
				tag = self.level,
				param = self.timeValue
			})
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"确定",
			18,
			1
		}
	}):addTo(bg2):pos(bg2:getw() / 2 - 75, 13):anchor(0.5, 0)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"取消",
			18,
			1
		}
	}):addTo(bg2):pos(bg2:getw() / 2 + 75, 13):anchor(0.5, 0)

	local setPrice
	local value2
	local timeMax = self:getMaxTime(self.level)
	local x2 = 125
	local desc2 = an.newLabel("可出售道具数量:", 18, 1):addTo(bg2):pos(x2, 220):anchor(0, 0.5)
	local gridNum = an.newLabel("", 18, 1):addTo(bg2):pos(x2 + desc2:getw() + 10, 220):anchor(0, 0.5)
	local label2 = an.newLabel("选择摆摊时间:", 18, 1):addTo(bg2):pos(x2, 185):anchor(0, 0.5)
	local label3 = an.newLabel("1小时", 18, 1):addTo(bg2):pos(x2 + label2:getw() + 10, 185):anchor(0, 0.5)

	local function timeChange()
		label3:setString(self.timeValue .. "小时")
		setPrice()
	end

	local slider = an.newSlider(res.gettex2("pic/common/sliderBg3.png"), res.gettex2("pic/common/sliderBg3.png"), res.gettex2("pic/common/sliderBlock3.png"), {
		valueChangeEnd = function(value)
			self.timeValue = math.modf((timeMax - 1) * value + 1)

			timeChange()
		end
	}):addTo(bg2):anchor(0.5, 0.5):pos(x2 + 135, 135)

	an.newBtn(res.gettex2("pic/common/minus_n.png"), function(btn)
		sound.playSound("103")

		if self.timeValue > 1 then
			self.timeValue = self.timeValue - 1

			timeChange()
			slider:setValue((self.timeValue - 1) / (timeMax - 1))
		end
	end, {
		pressImage = res.gettex2("pic/common/minus_s.png")
	}):addTo(bg2):pos(x2, 135):anchor(0, 0.5)
	an.newBtn(res.gettex2("pic/common/add_n.png"), function(btn2)
		sound.playSound("103")

		if self.timeValue < 12 then
			self.timeValue = self.timeValue + 1

			timeChange()
			slider:setValue((self.timeValue - 1) / (timeMax - 1))
		end
	end, {
		pressImage = res.gettex2("pic/common/add_s.png")
	}):addTo(bg2):pos(x2 + 237, 135):anchor(0, 0.5)

	local desc = an.newLabel("摆摊费用:", 18, 1):addTo(bg2):pos(x2, 90):anchor(0, 0.5)
	local pnum = an.newLabel(tostring(self:getPrice(self.level) * self.timeValue), 18, 1):addTo(bg2):pos(x2 + desc:getw() + 10, 90):anchor(0, 0.5)
	local ptype = an.newLabel("金币", 18, 1, {
		color = def.colors.labelYellow
	}):addTo(bg2):pos(x2 + desc:getw() + pnum:getw() + 15, 90):anchor(0, 0.5)

	function setPrice()
		pnum:setString(tostring(self:getPrice(self.level) * self.timeValue))
		ptype:pos(x2 + desc:getw() + pnum:getw() + 15, 90)
	end

	local sprs2 = {
		"pic/panels/stall/level1.png",
		"pic/panels/stall/level2.png",
		"pic/panels/stall/level3.png",
		"pic/panels/stall/level4.png"
	}

	function setBox()
		timeMax = self:getMaxTime(self.level)
	end

	common.tabs(bg2, {
		sprs = sprs2
	}, function(idx2, btn3)
		self.level = idx2

		gridNum:setString(self:getMaxBox(self.level) .. "格")
		setBox()
		setPrice()
	end, {
		tabTp = 10,
		pos = {
			offset = 44,
			x = 20,
			y = bg2:geth() - 70,
			anchor = cc.p(0, 0.5)
		}
	})
end

function stall:showStallPanel()
	main_scene.ui:showPanel("bag")
	main_scene.ui.panels.bag:resetPanelPosition("stall")
	main_scene.ui.panels.bag:setScaleMul(2)

	local bg2 = res.get2("pic/panels/stall/bg1.png"):addTo(self):anchor(0, 0)

	res.get2("pic/panels/stall/title.png"):addTo(bg2):anchor(0.5, 0.5):pos(bg2:getw() / 2, bg2:geth() - 23)

	self.stallPanel = bg2

	self:size(bg2:getContentSize()):resetPanelPosition("left")

	if self._touchFrames and self._touchFrames.main then
		local rect = cc.rect(0, 0, self:getw(), self:geth())

		self:addTouchFrame(rect, "main")
	end

	local value
	local nameBtn
	local isEdit
	local nameInput = an.newInput(115, 378, 165, 36, 15, {
		label = {
			g_data.stall.name,
			18
		},
		bg = {
			h = 36,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-1,
				0
			}
		},
		start_call = function()
			isEdit = true

			nameBtn.sprite:setTex(res.gettex2("pic/common/confirm.png"))
		end
	}):addTo(bg2):anchor(0, 0.5)

	nameBtn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		isEdit = not isEdit

		if isEdit then
			nameInput:startInput()
			nameBtn.sprite:setTex(res.gettex2("pic/common/confirm.png"))
		else
			local string2 = nameInput:getString()

			if cc2.ms and def.role.mainsetting.invaildNames then
				local parts = string.split(def.role.mainsetting.invaildNames, "|")

				for _, item2 in pairs(parts) do
					if string.find(string2, item2) ~= nil then
						main_scene.ui:fadeLabel("摊位名称有违规词！")

						return
					end
				end
			end

			net.send({
				CM_SET_STALL_NAME
			}, {
				nameInput:getString()
			})
			nameBtn.sprite:setTex(res.gettex2("pic/panels/stall/name.png"))
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/stall/name.png")
	}):addTo(bg2):pos(18, 378):anchor(0, 0.5)

	self:createItemsPanel()
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if g_data.stall.state == 1 then
			net.send({
				CM_PAUSE_STALL
			})
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/stall/pause.png")
	}):addTo(bg2):pos(bg2:getw() / 2 - 20, 133):anchor(1, 0.5)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if g_data.stall.state ~= 1 then
			if table.nums(g_data.stall.items) == 0 then
				main_scene.ui:tip("没有摆放物品售卖！")
			else
				net.send({
					CM_START_STALL
				})
			end
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/stall/start.png")
	}):addTo(bg2):pos(bg2:getw() / 2 + 20, 133):anchor(0, 0.5)
	res.get2("pic/panels/stall/bg2.png"):addTo(bg2):pos(bg2:getw() / 2, 14):anchor(0.5, 0)
	an.newLabel("买家留言", 18, 1):addTo(bg2):pos(bg2:getw() / 2, 96):anchor(0.5, 0.5)

	if g_data.stall.msgCnt > 0 then
		an.newLabelM(bg2:getw() - 50, 16, 1):addTo(bg2):anchor(0, 1):pos(25, 75):nextLine():addLabel("您的摊位目前有", def.colors.btn20):addLabel(g_data.stall.msgCnt .. "", def.colors.labelYellow):addLabel("条买家留言,请去邮件中查看.", def.colors.btn20)
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg2):anchor(1, 1):pos(bg2:getw() - 8, bg2:geth() - 7)

	if table.nums(g_data.stall.items) > 0 then
		for k, v in ipairs(g_data.stall.items) do
			self:addItem(v.info:get("makeIndex"))
		end
	end
end

function stall:createItemsPanel()
	if not self.stallPanel then
		return
	end

	if self.stallPanel.node then
		self.stallPanel.node:removeSelf()
	end

	self.stallPanel.node = display.newNode():addTo(self.stallPanel)

	local w2 = 245
	local h2 = ({
		57,
		104,
		153,
		199
	})[g_data.stall.level]

	display.newScale9Sprite(res.getframe2("pic/scale/scale27.png"), 0, 0, cc.size(w2, h2)):anchor(0, 0):addTo(self.stallPanel.node):anchor(0.5, 1):pos(self.stallPanel:getw() / 2, 356)

	for i = 1, g_data.stall.level do
		res.get2("pic/panels/stall/items.png"):addTo(self.stallPanel.node):pos(self.stallPanel:getw() / 2, 397 - i * 47):anchor(0.5, 1)
	end
end

function stall:putItem(item2, x2, y2)
	repeat
		if not self.stallPanel then
			break
		end

		if item2.data.isBinded() then
			main_scene.ui:tip("绑定的物品不可出售！")

			break
		end

		local form = item2.formPanel.__cname

		if form == "bag" then
			self:putInItem(item2)

			break
		end

		if form == "stall" then
			break
		end

		main_scene.ui:tip("只能出售包裹里的道具.")
	until true

	return false
end

function stall:getBackItem(item2)
	net.send({
		CM_DEL_STALLITEM,
		recog = item2.data:get("makeIndex")
	})
end

function stall:putInItem(item2)
	local level = g_data.stall.level

	if table.nums(g_data.stall.items) >= self:getMaxBox(level) then
		if level < 4 and g_data.stall.state == 0 then
			local _, bg2 = common.msgbox("", {
				okFunc = function()
					net.send({
						CM_SET_STALL_TIMELV,
						tag = level + 1,
						param = g_data.stall.allTm
					})
				end
			})

			an.newLabelM(370, 20, 1):anchor(0, 1):pos(20, bg2:geth() - 60):addTo(bg2):nextLine():addLabel(string.format("您的摊位出售栏已达上限, 是否需要提升摊位等级?(提升到%s摊位需要支付", ({
				"普通",
				"中级",
				"高级"
			})[level]), def.colors.btn20):addLabel(string.format("%d", self:getPrice(level + 1) * self.timeValue), def.colors.labelYellow):addLabel("金币)", def.colors.btn20)
		elseif level < 4 and g_data.stall.state > 0 then
			local h2, m = math.modf(g_data.stall.time / 60 / 60)
			local _2, bg3 = common.msgbox("", {
				okFunc = function()
					net.send({
						CM_SET_STALL_TIMELV,
						tag = level + 1,
						param = g_data.stall.allTm
					})
				end
			})

			an.newLabelM(370, 20, 1):anchor(0, 1):pos(20, bg3:geth() - 60):addTo(bg3):nextLine():addLabel(string.format("距离您摆摊结束时间还有%d小时%d分。您提升到%s摊位需要再支付", h2, math.floor(m * 60), ({
				"普通",
				"中级",
				"高级"
			})[level]), def.colors.btn20):addLabel(string.format("%d", (self:getPrice(level + 1) - self:getPrice(level)) * math.ceil(g_data.stall.time / 60 / 60)), def.colors.labelYellow):addLabel("金币的摊位差价。请确认是否升级摊位类型?", def.colors.btn20)
		else
			main_scene.ui:tip("您的摊位等级已经是最高等级, 出售道具数量达到上限!")
		end
	else
		self:showItemSetting(item2)
	end
end

function stall:showItemSetting(item2)
	local wN = 1
	local wT = 0
	local wP = 0

	local function ok()
		if (function()
			local isError = false

			if math.floor(wN) < wN or wN < 1 or wN > 999 then
				isError = true
			end

			if item2.data:isPileUp() and item2.data:get("dura") < wN then
				isError = true
			end

			if not item2.data:isPileUp() and wN > 1 then
				isError = true
			end

			return isError
		end)() then
			main_scene.ui:tip("请输入正确的出售数量")
		elseif wT == 0 and (wP < 1 or wP > 5000000) then
			main_scene.ui:tip("请输入正确的金币数量")
		elseif wT == 1 and (wP < 0.1 or wP > 99999) then
			main_scene.ui:tip("请输入正确的元宝数量")
		else
			net.send({
				CM_ADD_STALLITEM,
				recog = item2.data:get("makeIndex"),
				tag = wT,
				param = wN
			}, nil, {
				{
					"int",
					wP,
					4
				}
			})

			return false
		end

		return true
	end

	local _, bg2 = common.msgbox("", {
		okFunc = ok
	})

	local function addLabel(params)
		return an.newLabel(params.str, 18, 1, {
			color = display.COLOR_WHITE
		}):addTo(bg2):pos(params.x, params.y):anchor(params.ax or 0.5, params.ay or 0.5)
	end

	addLabel({
		str = "出售道具:",
		x = 70,
		y = 200
	})
	addLabel({
		str = "个",
		x = 335,
		y = 200
	})
	addLabel({
		x = 260,
		y = 168,
		str = string.format("该道具栏有%d个", item2.data.isPileUp() and item2.data:get("dura") or 1)
	})
	addLabel({
		str = "出售方式:",
		x = 70,
		y = 135
	})
	addLabel({
		str = "金币",
		y = 132,
		x = 170,
		ax = 0
	})
	addLabel({
		str = "元宝",
		y = 132,
		x = 275,
		ax = 0
	})
	addLabel({
		str = "单价:",
		x = 70,
		y = 90
	})

	local priceType = addLabel({
		str = "金币",
		y = 90,
		x = 260,
		ax = 0
	})
	local icon = res.get2("pic/common/itembg3.png"):addTo(bg2):pos(125, 200):anchor(0, 0.5)

	item.new(item2.data, self, {
		showbg = false,
		showEffect = true
	}):addto(icon):pos(icon:getw() / 2, icon:geth() / 2):anchor(0.5, 0.5)

	local inputL = {}
	local inputs = {
		{
			str = "1",
			limit = 3,
			pos = {
				x = 200,
				y = 200
			},
			size = {
				w = 120,
				h = 36
			}
		},
		{
			str = "请输入价格",
			limit = 7,
			pos = {
				x = 125,
				y = 90
			},
			size = {
				w = 130,
				h = 36
			}
		}
	}

	for k, v in ipairs(inputs) do
		inputL[k] = an.newInput(v.pos.x, v.pos.y, v.size.w, v.size.h, v.limit, {
			label = {
				v.str,
				18
			},
			bg = {
				h = 36,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-1,
					0
				}
			},
			start_call = function()
				inputL[k]:setString("")
			end,
			stop_call = function()
				local num = tonumber(inputL[k]:getString())

				if not num then
					main_scene.ui:tip("请输入正确的数字!")

					wN = k == 1 and 0 or wN
					wP = k == 2 and 0 or wP
				elseif k == 1 then
					wN = num
				else
					wP = wT == 0 and math.floor(num) or num - num % 0.1

					inputL[k]:setString(wP .. "")
				end
			end
		}):addTo(bg2):pos(v.pos.x, v.pos.y):anchor(0, 0.5)
	end

	local tog = {}

	for i = 1, 2 do
		tog[i] = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle10.png"), function(b)
			if b then
				tog[({
					2,
					1
				})[i]].btn:setIsSelect(not b)
				tog[i].btn:setIsSelect(b)
				tog[({
					2,
					1
				})[i]].spr:setVisible(not b)
				tog[i].spr:setVisible(b)
				inputL[2]:setString("请输入价格")

				wT = i - 1
				wP = 0

				priceType:setString(wT == 0 and "金币" or "元宝")
			end
		end):addTo(bg2):pos(({
			[1] = 125,
			[2] = 230
		})[i], 133):anchor(0, 0.5)
		tog[i].spr = res.get2("pic/common/toggle11.png"):addTo(tog[i]):pos(tog[i]:getw() / 2, tog[i]:geth() / 2):hide()
	end

	tog[1].spr:show()
end

function stall:upt()
	if self.choosePanel then
		g_data.stall:setLevel(self.level)
		g_data.stall:setAllTm(self.timeValue)
		g_data.stall:setName(common.getPlayerName() .. "的摊位")
		self.choosePanel:removeSelf()

		self.choosePanel = nil

		self:showStallPanel()
	else
		g_data.stall:setLevel(g_data.stall.level + 1)
		self:createItemsPanel()
	end
end

function stall:idx2pos(idx2)
	idx2 = idx2 - 1

	local h2 = idx2 % 5
	local v = math.modf(idx2 / 5)

	return 59 + h2 * 47, 328 - v * 48
end

function stall:addItem(makeIndex)
	local i, v = g_data.stall:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		local price = "价格:" .. v.price .. (v.type == 0 and "金币" or "元宝")

		self.items[i] = item.new(v.info, self, {
			idx = i,
			extend = {
				price
			}
		}):addTo(self.stallPanel, 1):pos(self:idx2pos(i))
	end
end

function stall:delItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			v:removeSelf()

			self.items[k] = nil
		end
	end
end

return stall
