local item = import("..common.item")
local deal = class("deal", function ()
	return display.newNode()
end)

table.merge(deal, {
	targetLayer,
	targetMoney,
	targetItems,
	selfLayer,
	selfMoney,
	selfItems
})

function deal:ctor(targetName)
	local offsety = 35
	self.selfLayer = res.get2("pic/panels/deal/bg.png"):anchor(0, 0):add2(self)
	self.targetLayer = res.get2("pic/panels/deal/bg.png"):anchor(0, 0):add2(self):pos(0, self.selfLayer:geth() + offsety)

	self:size(self.selfLayer:getw(), self.selfLayer:geth() + self.targetLayer:geth() + offsety):anchor(1, 1):pos(display.width - 90, display.height - 40)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")

		if not g_data.client.lastTime.deal or socket.gettime() - g_data.client.lastTime.deal > 4 then
			net.send({
				CM_DEALCANCEL
			})
		end
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):anchor(0.5, 0.5):pos(256, 196):addto(self.selfLayer)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if not g_data.client.lastTime.deal or socket.gettime() - g_data.client.lastTime.deal > 4 then
			net.send({
				CM_DEALEND
			})
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/deal/jy.png")
	}):pos(216, 34):scale(0.85):addto(self.selfLayer)
	an.newLabel(targetName, 18, 1):anchor(0.5, 1):pos(self:getw() / 2 - 5, self:geth() - 12):add2(self)
	an.newLabel(main_scene.ground.player.info:getName(), 18, 1):anchor(0.5, 1):pos(self:getw() / 2 - 5, self.selfLayer:geth() - 12):add2(self)

	self.selfMoney = an.newLabel("0", 16, 1):pos(84, 22):add2(self)
	self.targetMoney = an.newLabel("0", 16, 1):pos(84, 22 + self.selfLayer:geth() + offsety):add2(self)
	self.selfItems = {}
	self.targetItems = {}
end

function deal:idx2pos(idx)
	idx = math.min(idx - 1, 9)
	local h = idx % 5
	local v = math.modf(idx / 5)

	return 44 + h * item.w, 140 - v * item.h
end

function deal:setMoney(who, money)
	sound.playSound(sound.s_money)

	if who == "self" then
		self.selfMoney:setString(change2GoldStyle(money))
	else
		self.targetMoney:setString(change2GoldStyle(money))
	end
end

function deal:addItem(who, data)
	sound.play("item", data)

	if who == "self" then
		local idx = #self.selfItems + 1
		self.selfItems[idx] = item.new(data, self, {
			idx = idx
		}):addto(self.selfLayer):pos(self:idx2pos(idx))
	else
		local idx = #self.targetItems + 1
		self.targetItems[idx] = item.new(data, self, {
			idx = idx
		}):addto(self.targetLayer):pos(self:idx2pos(idx))
	end
end

function deal:itemsBack2bag()
	local makeIndexs = {}

	for i, v in ipairs(self.bagItemDatas) do
		g_data.bag:addItem(v)

		makeIndexs[#makeIndexs + 1] = v:get("makeIndex")
	end

	if main_scene.ui.panels.bag then
		for i, v in ipairs(makeIndexs) do
			main_scene.ui.panels.bag:addItem(v)
		end
	end
end

function deal:putItem(item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		if g_data.client.dealItem then
			an.newMsgbox("放入失败， 当前网络慢， 请重试！", nil, {
				center = true
			})

			return
		end

		if g_data.client:checkLastTime("deal", 4) then
			local data = item.data

			g_data.client:setNowDealItem(data)
			g_data.bag:delItem(data:get("makeIndex"))
			item.formPanel:delItem(data:get("makeIndex"))
			g_data.client:setLastTime("deal", true)
			net.send({
				CM_DEALADDITEM,
				recog = data:get("makeIndex")
			}, {
				data.getVar("name")
			})
		end
	end
end

function deal:putGold(item)
	local form = item.formPanel.__cname

	if form == "bag" then
		sound.playSound(sound.s_money)

		local msgbox = nil
		msgbox = an.newMsgbox("\n请输入金币数量\n", function ()
			if msgbox.input:getString() == "" then
				return
			end

			local gold = tonumber(msgbox.input:getString())

			if not gold or gold < 1 then
				return
			end

			if not g_data.client.lastTime.deal or socket.gettime() - g_data.client.lastTime.deal > 4 then
				net.send({
					CM_DEALCHGGOLD,
					recog = gold
				})
			else
				an.newMsgbox("网络异常, 请重试", nil, {
					center = true
				})
			end
		end, {
			disableScroll = true,
			input = 20
		})
	end
end

return deal
