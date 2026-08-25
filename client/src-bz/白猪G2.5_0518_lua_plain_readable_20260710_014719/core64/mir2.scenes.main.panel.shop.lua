local itemInfo = import("..common.itemInfo")
local common = import("..common.common")
local shop = class("shop", function()
	return display.newNode()
end)

table.merge(shop, {
	content,
	nodes,
	selectData,
	shopcontain = {}
})

local tags = {
	hot = {
		var = 6,
		tag1 = "shop"
	},
	give = {
		var = 4,
		tag1 = "shop"
	},
	intensify = {
		var = 2,
		tag1 = "shop"
	},
	friend = {
		var = 3,
		tag1 = "shop"
	},
	limit = {
		var = 4,
		tag1 = "shop"
	},
	spicel = {
		var = 5,
		tag1 = "shop"
	}
}
local cc2 = require("mir2.cc")

function shop:ctor(name)
	self._supportMove = true

	g_data.shop:setEvtListener(self)

	params = params or {}

	if type(params.tag2) ~= "string" or tags[params.tag2] then
		params.tag2 = "hot"
	end

	params.tag1 = tags[params.tag2].tag1

	local bg = res.get2("pic/common/black_2.png"):addTo(self):anchor(0, 0)

	self:size(bg:getContentSize()):anchor(0.5, 0.5):center()
	res.get2("pic/panels/shop/title.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 14):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg:getw() - 9, bg:geth() - 8):anchor(1, 1)
	common.tabs(bg, {
		oy = 12,
		ox = 3,
		sprs = {
			"pic/panels/shop/shangc.png"
		}
	}, function(idx, btn)
		if idx == 1 then
			self.tag1 = "shop"

			self:load("hot")
		elseif idx == 2 then
			self.tag1 = "charge"

			self:load2()
		end
	end, {
		tabTp = 1,
		pos = {
			offset = 70,
			x = 0,
			y = bg:geth() - 38,
			anchor = cc.p(1, 1)
		}
	})
	def.role.call("@updateShop")
end

function shop:onCleanup()
	g_data.shop:setEvtListener(nil)
end

function shop:load()
	if self.tag1Node then
		self.tag1Node:removeSelf()
	end

	self.tag1Node = display.newNode():addTo(self)

	display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(127, 390)):addTo(self.tag1Node):pos(12, 15):anchor(0, 0)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.tag1Node):pos(146, 15):anchor(0, 0)

	local sprs = {
		"pic/panels/shop/rx.png",
		"pic/panels/shop/zs.png",
		"pic/panels/shop/bg.png",
		"pic/panels/shop/qh.png",
		"pic/panels/shop/xl.png",
		"pic/panels/shop/hy.png"
	}
	local initTag = {
		5,
		0,
		1,
		2,
		3,
		4
	}

	common.tabs(self.tag1Node, {
		sprs = sprs
	}, function(idx, btn)
		local tmpType = initTag[idx] or 0

		self.tag2 = ({
			shop = {
				"hot",
				"give",
				"intensify",
				"friend",
				"limit",
				"spicel"
			},
			charge = {}
		})[self.tag1][tmpType]

		local items = g_data.shop:getCurTypePageGoods(tmpType, 0)

		self.curSubIdx = tmpType

		if #items == 0 then
			self:query(0, tmpType)
			self:processUpt(-1)

			if self.tag2Node then
				self.tag2Node:removeSelf()

				self.tag2Node = nil
			end
		else
			self:processUpt(tmpType, items)
		end
	end, {
		tabTp = 2,
		pos = {
			offset = 50,
			x = 21,
			y = self:geth() - 84,
			anchor = cc.p(0, 0.5)
		}
	})
	self:processUpt(-1)
end

function shop:showLock()
	if tolua.isnull(self.infoView) then
		return
	end

	local covert = display.newNode()
	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 128))

	covert:addChild(layer)
	covert:setTouchEnabled(true)
	covert:setTouchSwallowEnabled(true)

	local loading = res.get2("pic/common/loading.png"):add2(layer)

	loading:runForever(cca.rotateBy(1, 360))

	function covert.setContentSize(_, ...)
		layer:setContentSize(...)

		local sz = layer:getContentSize()

		loading:pos(sz.width / 2, sz.height / 2)
	end

	function covert.getContentSize()
		return layer:getContentSize()
	end

	covert:add2(self.tag2Node):pos(self.infoView:getPosition()):size(self.infoView:getContentSize())

	self.covert = covert
end

function shop:releaseLock()
	if not tolua.isnull(self.covert) then
		self.covert:removeSelf()
	end
end

function shop:load2(tag2)
	if self.tag1Node then
		self.tag1Node:removeSelf()
	end

	self.tag1Node = display.newNode():addTo(self)

	if self.tag2Node then
		self.tag2Node:removeSelf()
	end

	self.tag2Node = display.newNode():addTo(self)
	self.curSubIdx = nil

	display.newScale9Sprite(res.getframe2("pic/scale/scale14.png")):addto(self.tag2Node):anchor(0, 0):pos(14, 14):size(self:getw() - 28, self:geth() - 60)
	an.newBtn(res.gettex2("pic/common/btn10.png"), function()
		local btns = {
			"确定"
		}
		local helperText = "支付结果可能存在延迟,请耐心等待.\n支付过程中请勿关闭游戏，否则您成功购买\n的商品可能会延期半小时以上才能发放。"
		local ops = {}
		local box = an.newMsgbox("", function(idx)
			if ops[idx] then
				ops[idx]()
			end
		end, {
			disableScroll = true,
			hasCancel = false
		})

		an.newLabel(helperText, 20, 1):addTo(box):pos(box:centerPos()):anchor(0.5, 0.5)
	end, {
		pressImage = res.gettex2("pic/common/btn11.png"),
		label = {
			"充值帮助",
			18,
			1,
			{
				color = def.colors.btn20
			}
		}
	}):add2(self.tag2Node):anchor(0, 0.5):pos(20, self:geth() - 72)
	an.newBtn(res.gettex2("pic/common/btn10.png"), function()
		g_data.shop:checkPaidOrder()
	end, {
		pressImage = res.gettex2("pic/common/btn11.png"),
		label = {
			"刷新订单",
			18,
			1,
			{
				color = def.colors.btn20
			}
		}
	}):add2(self.tag2Node):anchor(0, 0.5):pos(120, self:geth() - 72)
	an.newLabel("若充值有问题，请点击充值帮助!", 20, 0):anchor(0.5, 0.5):add2(self.tag2Node):pos(self:getw() * 0.5 + 50, self:geth() - 72)

	local lists = g_data.shop:getProducts()
	local infoView = an.newScroll(12, 18, self:getw() - 28, self:geth() - 114):add2(self.tag2Node)

	self.infoView = infoView

	local h = 160

	infoView:setScrollSize(self:getw() - 28, math.max(self:geth() - 110, math.modf((#lists - 1) / 4) * h))

	if #lists <= 0 then
		local sz = infoView:getScrollSize()
		local txt = "正在从苹果服务端请求商品列表"

		if device.platform ~= "ios" then
			txt = "当前仅支持通过iOS客户端进行充值"
		end

		an.newLabel(txt, 20, 0):anchor(0.5, 1):add2(infoView):pos(sz.width / 2, sz.height * 0.618)
	end

	for i, v in ipairs(lists) do
		local node = res.get2("pic/panels/shop/bg2.png"):anchor(0, 1):pos((i - 1) % 4 * 152 + 4, infoView:getScrollSize().height - math.modf((i - 1) / 4) * h):add2(infoView)

		an.newLabel(v.name, 20, 0):anchor(0.5, 0.5):add2(node):pos(node:getw() * 0.5, node:geth() - 24)
		res.get2("pic/panels/shop/line02.png"):pos(node:getw() * 0.5, node:geth() - 40):add2(node):scaleX(0.6)

		if v.effOffSet == 1 then
			res.get2("pic/panels/shop/gold.png"):pos(node:getw() * 0.5 - 8, node:geth() * 0.5 + 8):add2(node)
			res.get2("pic/panels/shop/gold.png"):pos(node:getw() * 0.5 + 8, node:geth() * 0.5 - 8):add2(node)
		else
			res.get2("pic/panels/shop/yb.png"):pos(node:getw() * 0.5 - 8, node:geth() * 0.5 + 8):add2(node)
			res.get2("pic/panels/shop/yb.png"):pos(node:getw() * 0.5 + 8, node:geth() * 0.5 - 8):add2(node)
		end

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			if g_data.shop:hasPayingOrder() then
				if main_scene and main_scene.ui then
					main_scene.ui:tip("当前正在处理其他订单,请稍后...")
				end

				return
			end

			local function buy()
				self:showLock()
				g_data.shop:addPayOrder(v.identifier)
			end

			local text = "是否确认购买 " .. v.name .. " ?"
			local msgbox = an.newMsgbox("", function(isOk)
				if isOk == 1 then
					buy()
				end
			end, {
				hasCancel = true
			})

			an.newLabel(v.name, 22, 1):add2(msgbox.bg):pos(280, 190):anchor(0.5, 0)
			an.newLabel("充值金额", 22, 1, {
				color = def.colors.cellTitle
			}):add2(msgbox.bg):pos(50, 190)
			res.get2("pic/panels/setting/line.png"):pos(msgbox.bg:getw() * 0.5, 175):add2(msgbox.bg):scaleX(0.6)
			an.newLabel(g_data.login:getSelectGroup():get("groupName"), 22, 1):add2(msgbox.bg):pos(280, 135):anchor(0.5, 0)
			an.newLabel("充值服务器", 22, 1, {
				color = def.colors.cellTitle
			}):add2(msgbox.bg):pos(50, 135)
			res.get2("pic/panels/setting/line.png"):pos(msgbox.bg:getw() * 0.5, 120):add2(msgbox.bg):scaleX(0.6)
			an.newLabel("当前角色", 22, 1):add2(msgbox.bg):pos(280, 80):anchor(0.5, 0)
			an.newLabel("充值对象", 22, 1, {
				color = def.colors.cellTitle
			}):add2(msgbox.bg):pos(50, 80)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"￥ " .. v.price,
				22,
				1,
				{
					color = def.colors.btn20
				}
			}
		}):add2(node):anchor(0.5, 0.5):pos(node:getw() * 0.5, 30)
	end

	if g_data.shop:hasPayingOrder() then
		self:showLock()
	end
end

function shop:onPaymentEvent(step, code, msg)
	if not main_scene or not main_scene.ui or tolua.isnull(self) then
		return
	end

	if not tolua.isnull(main_scene.ui.panels.shop) and not g_data.shop:hasPayingOrder() then
		print("releaseLock")
		main_scene.ui.panels.shop:releaseLock()
	end

	code = tonumber(code)

	if step == "onUpdatedProducts" then
		if not self.curSubIdx then
			self:load2()
		end
	elseif step == "onPayReady" then
		if code == -1 then
			main_scene.ui:tip("存在未完成订单,请稍后重试.")
		else
			main_scene.ui:tip("未知错误")
		end
	elseif step == "onPayEnd" then
		if code == 1002 then
			main_scene.ui:tip("订单取消")
		elseif code == 1011 then
			main_scene.ui:tip("查询订单超时,如果您已经成功支付,我们将在稍后同步支付结果")
		elseif code ~= 0 and msg then
			main_scene.ui:tip(msg)
		end
	elseif step == "onPayResult" then
		if code == -1 then
			main_scene.ui:tip("订单查询异常,如果您已经成功支付,我们将在稍后同步支付结果")
		elseif code == -2 then
			main_scene.ui:tip("订单查询超时,如果您已经成功支付,我们将在稍后同步支付结果")
		elseif code < 0 then
			main_scene.ui:tip("服务异常,如果您已经成功支付,请联系客服解决此问题")
		end

		print("onPayResult", code)
	elseif code ~= 0 then
		main_scene.ui:tip("购买异常,异常ID:" .. code)
	end
end

function shop:currenyType2Icon(value)
	if value == 0 then
		return res.gettex2("pic/panels/shop/yb.png")
	elseif value == 1 then
		return res.gettex2("pic/panels/shop/gold.png")
	elseif value == 2 then
		return res.gettex2("pic/panels/shop/lingfu.png")
	elseif value == 3 then
		return res.gettex2("pic/panels/shop/sw.png")
	elseif value == 4 then
		return res.gettex2("pic/panels/shop/czd.png")
	else
		return res.gettex2("pic/panels/shop/yb.png")
	end
end

function shop:currenyType2Text(value)
	if value == 0 then
		return CS_YB
	elseif value == 1 then
		return "金币"
	elseif value == 2 then
		return CS_GRID
	elseif value == 3 then
		return CS_PRESTIGE
	elseif value == 4 then
		return "充值点"
	else
		return CS_YB
	end
end

function shop:processUpt(tag2Var, items)
	if self.curSubIdx ~= tag2Var or not items then
		return
	end

	if self.tag2Node then
		self.tag2Node:removeSelf()
	end

	self.tag2Node = display.newNode():addTo(self)

	local infoView = an.newScroll(150, 19, 478, 384):add2(self.tag2Node)
	local h = 126

	infoView:setScrollSize(478, math.max(384, math.modf((#items - 1) / 2) * h))

	for i, v in ipairs(items) do
		local node = res.get2("pic/panels/shop/bg1.png"):anchor(0, 1):pos(i % 2 == 0 and 240 or 0, infoView:getScrollSize().height - math.modf((i - 1) / 2) * h):add2(infoView)

		res.get2("pic/panels/shop/frame.png"):pos(50, 50):add2(node):enableClick(function(x, y)
			self:show(v, cc.p(x, y))
		end)
		res.getItemsWithBg("items", v:get("name"), v:get("looks"), false, def.itemShopShowEffect):addto(node):pos(50, 50)
		an.newLabel(v:get("name"), 20, 1):anchor(0.5, 0.5):add2(node):pos(node:getw() * 0.5, node:geth() - 24)
		res.get2("pic/panels/shop/line02.png"):pos(node:getw() * 0.5, node:geth() - 40):add2(node)

		local sprite = self:currenyType2Icon(v:get("effOffSet"))
		local value = v:get("curPrice")
		local value2 = self:currenyType2Text(v:get("effOffSet"))

		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			local function buy()
				net.send({
					CM_DOSHOP,
					recog = 1
				}, {
					v:get("name")
				})
			end

			local msgbox = an.newMsgbox("", function(isOk)
				if isOk == 1 then
					buy()
				end
			end, {
				disableScroll = true,
				hasCancel = true
			})

			an.newLabel(string.format("使用「%s」购买 %s ?", value2, v:get("name")), 20, 1):addTo(msgbox):pos(msgbox:centerPos()):anchor(0.5, 0.5)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				self:toString(value, v:get("price")),
				16,
				1,
				{
					color = def.colors.btn20
				}
			},
			labelOffset = cc.p(-20, 0),
			sprite = sprite,
			spriteOffset = cc.p(20, 0)
		}):add2(node):anchor(0.5, 0.5):pos(160, 50)
	end
end

function shop:toString(value, text)
	if def.multipleCurrencyShop then
		if value == 1 then
			text = text * 10000
		end

		if text >= 10000 then
			if text % 10000 < 1000 then
				return string.format("%d万", math.floor(text / 10000))
			else
				return string.format("%.1f万", (text - text % 1000) / 10000)
			end
		else
			return tostring(text)
		end
	else
		return tostring(text)
	end
end

function shop:show(data, scenePos, params)
	params = params or {}

	local layer = display.newNode():size(display.width, display.height):addto(params.parent or main_scene.ui, params.z or main_scene.ui.z.textInfo)

	layer:setTouchEnabled(true)
	layer:setTouchSwallowEnabled(false)
	layer:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
		if event.name == "ended" then
			layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2
	local h2 = h + 160
	local infos = {}
	local introduces = string.split(data:get("descStr"), "|")

	for i, _ in ipairs(introduces) do
		infos[#infos + 1] = an.newLabel(introduces[i], 20, 1)
		h2 = h2 + 22
	end

	res.get2("pic/panels/shop/frame.png"):pos(50, h2 - 50):add2(bg)
	res.getItemsWithBg("items", data:get("name"), data:get("looks"), false, def.itemShopShowEffect):addto(bg):pos(50, h2 - 50)

	local itemName = an.newLabel(data:get("name"), 20, 1):anchor(0, 0.5):add2(bg):pos(90, h2 - 50)
	local w2 = math.max(w, itemName:getw() + 20 + 90)
	local posh = h2 - 120

	for i2, v in ipairs(infos) do
		v:addto(bg, 99):anchor(0, 0):pos(10, posh - (i2 - 1) * 22)

		w2 = math.max(w2, v:getw() + 20)
	end

	local sprite = self:currenyType2Icon(data:get("effOffSet"))
	local value = data:get("curPrice")
	local value2 = self:currenyType2Text(data:get("effOffSet"))

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		local function callback()
			net.send({
				CM_DOSHOP,
				recog = 1
			}, {
				data:get("name")
			})
		end

		local msgbox = an.newMsgbox("", function(value)
			if value == 1 then
				callback()
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel(string.format("使用「%s」购买 %s ?", value2, data:get("name")), 20, 1):addTo(msgbox):pos(msgbox:centerPos()):anchor(0.5, 0.5)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			self:toString(value, data:get("price")),
			16,
			1,
			{
				color = def.colors.btn20
			}
		},
		labelOffset = cc.p(-20, 0),
		sprite = sprite,
		spriteOffset = cc.p(20, 0)
	}):add2(bg):anchor(0.5, 0.5):pos(w2 * 0.5, 30)

	local rect = cc.rect(params.minx or 0, params.miny or 0, params.maxx or display.width, params.maxy or display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w2 then
		p.x = rect.width - w2
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h2 < rect.y then
		p.y = h2 + rect.y
	end

	bg:size(w2, h2):pos(p.x, p.y)
end

function shop.onDoShopFail(ident, recog, param)
	local text

	if recog == 0 then
		text = "非法物品名"
	elseif recog == -1 then
		text = "不存在你想购买的物品"
	elseif recog == -2 then
		text = "请先进行充值"
	elseif recog == -3 then
		text = string.format("你帐号中的%s数不够", CS_YB)
	elseif recog == -4 then
		text = "你无法携带更多的物品"
	elseif recog == -5 then
		text = "购买物品不在商城中"
	elseif recog == -6 then
		text = "您的购买速度过快"
	elseif recog == -8 then
		text = string.format("您的专属%s不足", CS_YB)
	else
		text = recog == -9 and "您不是主宰者不能购买" or string.format("你无法购买: %s", recog)
	end

	main_scene.ui:tip(string.format("你无法购买: %s", text))
end

function shop:query(page, type)
	net.send({
		CM_REQSEESHOP,
		recog = type
	})
end

return shop
