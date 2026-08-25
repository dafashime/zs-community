local item = import("..common.item")
local bag = class("bag", function ()
	return display.newNode()
end)

table.merge(bag, {})

function bag:resetPanelPosition(type)
	if type == "left" then
		self:anchor(0, 1):pos(0, display.height)
	elseif type == "right" then
		self:anchor(1, 1):pos(display.width - 50, display.height - 50)
	elseif type == "stall" then
		self:anchor(0, 0.5):pos(display.cx - 50, display.cy + 50)
	elseif type == "ybdeal" then
		self:anchor(0, 0.5):pos(display.cx + 65, display.cy)
	elseif type == "storage" then
		self:anchor(0, 1):pos(display.cx + 15, display.height - 50)
	end

	if self.setFocus then
		self:setFocus()
	end

	return self
end

function bag:ctor()
	self._scale = g_data.client.lastScale.bag or 1
	self._supportMove = true

	self:setNodeEventEnabled(true)

	local bg = res.get2("pic/panels/bag/bg.png"):anchor(0, 0):addto(self)

	res.get2("pic/panels/bag/title.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 22):anchor(0.5, 0.5)
	self:size(cc.size(bg:getContentSize().width, bg:getContentSize().height)):scale(g_data.client.lastScale.bag):resetPanelPosition("left")
	display.newNode():size(self:getw() - 40, self:geth() - 110):pos(20, 60):add2(self):enableClick(function ()
	end)

	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("right")
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 12, self:geth() - 9):addto(self):setName("bag_close")
	an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		sound.playSound("103")

		if g_data.client:checkLastTime("queryBag", 1) then
			g_data.client:setLastTime("queryBag", true)
			net.send({
				CM_QUERYBAGITEMS
			})
		else
			main_scene.ui:tip("你整理的太快了。")
		end
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		sprite = res.gettex2("pic/panels/bag/sort.png")
	}):pos(310, 34):add2(self)

	self.scaleBtn = an.newBtn(res.gettex2("pic/common/scaleBig20.png"), function ()
		sound.playSound("103")
		self:stopAllActions()

		local scale = self:getScale() + 0.1

		if scale > 1.6 then
			scale = 1
		end

		if main_scene.ui.panels and main_scene.ui.panels.heroBag then
			local posX = self:getPositionX() + (self:getCascadeBoundingBox().width / self._scale - 10) * scale

			main_scene.ui.panels.heroBag:anchor(0, 1)
			main_scene.ui.panels.heroBag:moveTo(0.3, posX, display.height - 16)
		end

		self._scale = scale

		self:scaleTo(0.3, scale)
		g_data.client:setLastScale("bag", scale)
		self.scaleBtn.label:setString("x" .. string.format("%01d", (scale - 1) * 10 + 1))
	end, {
		pressImage = res.gettex2("pic/common/scaleBig21.png"),
		label = {
			"x" .. string.format("%01d", (self:getScale() - 1) * 10 + 1),
			20,
			1,
			{
				color = def.colors.btn40
			}
		},
		labelOffset = {
			x = 12,
			y = -16
		}
	}):pos(385, 32):add2(self)

	self.scaleBtn.label:pos(68, 30)
	res.get2("pic/panels/bag/gold_bg.png"):addTo(bg):pos(20, 36):anchor(0, 0.5)

	local gold = getRecord("TClientItem")

	gold.setIndex(1)
	item.new(gold, self, {
		isGold = true,
		tex = res.gettex2("pic/panels/bag/gold.png")
	}):addto(self):pos(45, 36)

	self.gold = an.newLabel(change2GoldStyle(g_data.player.gold), 20, 0, {
		color = cc.c3b(191, 165, 127)
	}):pos(81, 24):addto(self)
	self.items = {}

	self:reload()
end

function bag:onCleanup()
	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("left")
	end
end

function bag:reload()
	for k, v in pairs(self.items) do
		v:removeSelf()
	end

	self.items = {}

	for i = 1, g_data.bag.max do
		res.get2("pic/common/grid.png"):addTo(self):pos(self:idx2pos(i))

		local v = g_data.bag.items[i]

		if v then
			self.items[i] = item.new(v, self, {
				idx = i
			}):addto(self):pos(self:idx2pos(i))

			self.items[i].sprite:setName("bag_" .. v.getVar("name"))

			self.items[i].owner = "bag"
		end
	end
end

function bag:uptGold(gold)
	self.gold:setString(change2GoldStyle(g_data.player.gold))
end

function bag:idx2pos(idx)
	idx = idx - 1
	local h = idx % 8
	local v = math.modf(idx / 8)

	return 48 + h * 46.5, 321 - v * 46.5
end

function bag:pos2idx(x, y)
	local h = (x - 48) / 46.5 + 0.5
	local v = (321 - y) / 46.5 + 0.5

	if h > 0 and h < 8 and v > 0 and v < 6 then
		return math.floor(v) * 8 + math.floor(h) + 1
	end

	return -1
end

function bag:getItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			return v
		end
	end
end

function bag:addItem(makeIndex)
	local i, v = g_data.bag:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		self.items[i] = item.new(v, self, {
			idx = i
		}):addto(self):pos(self:idx2pos(i))

		self.items[i].sprite:setName("bag_" .. v.getVar("name"))

		self.items[i].owner = "bag"
	end
end

function bag:delItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end
end

function bag:uptItem(makeIndex)
	local i, v = g_data.bag:getItem(makeIndex)

	if v and self.items[i] then
		self.items[i].data = v
	end
end

function bag:putItem(item, x, y)
	local form = item.formPanel.__cname

	if form == "equip" then
		item:takeOff()
	elseif form == "bag" then
		local putIdx = self:pos2idx(x / self:getScale(), y / self:getScale())

		if putIdx == -1 or item.params.idx == putIdx then
			return
		end

		local srcIdx = item.params.idx

		if g_data.bag:isAallCanPileUp(srcIdx, putIdx) then
			local item1 = self.items[putIdx].data
			local makeIndex2 = self.items[srcIdx].data:get("makeIndex")

			if item1.isNeedResetPos(self.items[srcIdx].data) then
				self.items[putIdx]:pos(self:idx2pos(putIdx))
				self.items[srcIdx]:pos(self:idx2pos(srcIdx))
			end

			net.send({
				CM_PILEUPITEM,
				series = 0,
				recog = item1:get("makeIndex"),
				param = Loword(makeIndex2),
				tag = Hiword(makeIndex2)
			})
			g_data.player:setIsinPileUping(true)
		else
			item.params.idx = putIdx

			item:pos(self:idx2pos(putIdx))

			local target = self.items[putIdx]

			if target then
				target.params.idx = srcIdx

				target:pos(self:idx2pos(srcIdx))
			end

			self.items[putIdx] = item
			self.items[srcIdx] = target

			g_data.bag:changePos(srcIdx, putIdx)
		end

		return true
	elseif form == "npc" then
		item.formPanel:delSellItem()
	elseif form == "deal" then
		an.newMsgbox("交易的物品不可以取回，要取回物品请取消再重新交易！！！")
	elseif form == "storage" or form == "heroBag" then
		item.formPanel:getBackItem(item)
	elseif form == "stall" then
		item.formPanel:getBackItem(item)
	elseif form == "ybdeal" then
		item.formPanel:getBackItem(item)
	elseif form == "fusion" then
		item.formPanel:getBackItem(item)
	elseif form == "strengthen" then
		item.formPanel:getBackItem(item)
	end
end

function bag:duraChange(makeindex)
	for k, v in pairs(self.items) do
		if makeindex == v.data:get("makeIndex") then
			v:duraChange()

			return
		end
	end
end

function bag:setScaleMul(num)
	local scale = 1 + (num - 1) * 0.1
	self._scale = scale

	self:scale(scale)
	g_data.client:setLastScale("bag", scale)
	self.scaleBtn.label:setString("x" .. string.format("%01d", num))
end

return bag
