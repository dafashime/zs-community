local item = import("..common.item")
local box = class("box", function ()
	return display.newNode()
end)

function box:ctor(boxType, buf, buflen)
	self._supportMove = true
	self.curIndex = 1
	self.rotating = false
	self.boxType = boxType

	self:center()

	if boxType <= 2 then
		self.spr = m2spr.playAnimation("prguse3", 520 + (boxType + 1) * 20, 5, 0.1, false, false, true, handler(self, self.onAnimOk)):addTo(self)
		self.sprBlend = m2spr.playAnimation("prguse3", 527 + (boxType + 1) * 20, 5, 0.1, true, false, true):addTo(self)
	else
		self.spr = m2spr.playAnimation("prguse2", 130, 6, 0.1, false, false, true, handler(self, self.onAnimOk)):addTo(self)
		self.sprBlend = m2spr.playAnimation("prguse2", 137, 6, 0.1, true, false, true):addTo(self)
	end

	self.spr:anchor(0.5, 0.5)
	self.sprBlend:anchor(0.5, 0.5)

	local bg = display.newSprite(res.gettex("prguse2", 210)):addTo(self):anchor(0, 0):hide()
	self.bg = bg

	self:size(bg:getContentSize())
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		if self.rotating then
			return
		end

		sound.playSound("103")
		self:hidePanel()
		net.send({
			CM_BOX2_CLOSE
		})
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(bg:getw() - 3, bg:geth() - 3):addto(bg)
	an.newBtn(res.gettex("prguse2", 225), function ()
		sound.playSound("103")

		if self.rotating then
			return
		end

		for k, v in pairs(self.cellItems) do
			if v.clicker then
				v.clicker:removeFromParent()

				v.clicker = nil
			end
		end

		local data = {
			CM_BOX2_ROTATE
		}

		if self.openTimes ~= 0 then
			for k, v in pairs(g_data.bag.items) do
				if v.getVar("name") == g_data.usingTreasureKeyName then
					local keyIndex = v:get("makeIndex")
					data.param = Loword(keyIndex)
					data.tag = Hiword(keyIndex)

					break
				end
			end
		end

		self.openTimes = self.openTimes + 1

		net.send(data)
	end, {
		pressImage = res.gettex("prguse2", 226)
	}):anchor(0.5, 0):pos(bg:getw() / 2, 30):addto(bg)

	if not buflen then
		return
	end

	self.box2PrizeItems = {}

	while buflen > 0 do
		local item = getRecord("TBox2PrizeItem")
		_, buf, buflen = net.record(item, buf, buflen)

		table.insert(self.box2PrizeItems, item)
	end

	self.openTimes = 0
end

function box:onAnimOk()
	if self.boxType <= 2 then
		self.spr1 = m2spr.playAnimation("prguse3", 525 + (self.boxType + 1) * 20, 2, 0.2, false, false, true, handler(self, self.onOpened)):addTo(self)
		self.sprBlend1 = m2spr.playAnimation("prguse3", 532 + (self.boxType + 1) * 20, 2, 0.2, true, false, true):addTo(self)
	else
		self.spr1 = m2spr.playAnimation("prguse2", 135, 2, 0.1, false, false, true, handler(self, self.onOpened)):addTo(self)
		self.sprBlend1 = m2spr.playAnimation("prguse2", 142, 2, 0.1, true, false, true):addTo(self)
	end

	self.spr1:anchor(0.5, 0.5)
	self.sprBlend1:anchor(0.5, 0.5)
end

local itemPos = {
	{
		x = 52,
		y = 129
	},
	{
		x = 52,
		y = 81
	},
	{
		x = 104,
		y = 81
	},
	{
		x = 155,
		y = 81
	},
	{
		x = 155,
		y = 129
	},
	{
		x = 155,
		y = 177
	},
	{
		x = 104,
		y = 177
	},
	{
		x = 52,
		y = 177
	},
	{
		x = 104,
		y = 129
	},
	{
		x = 52,
		y = 237
	},
	{
		x = 155,
		y = 237
	},
	{
		x = 104,
		y = 237
	}
}

function box:updateItems()
	for k, v in pairs(self.cellItems or {}) do
		v.clr:removeFromParent()
		v:removeFromParent()
	end

	self.cellItems = {}

	for k, v in pairs(self.box2PrizeItems) do
		local spr = res.get("items", v:get("looks")):addTo(self)

		spr:setPosition(itemPos[k])

		if k <= 9 then
			local clr = display.newColorLayer(cc.c4b(0, 0, 0, 196)):size(35, 35):addTo(self)
			spr.clr = clr
			local pos = itemPos[k]

			clr:setPosition(cc.p(pos.x - 18, pos.y - 18))
		end

		if k == 9 then
			self.preCell = spr

			spr.clr:setVisible(false)
			self:enableReceiveGift(spr)
		end

		self.cellItems[k] = spr
	end
end

function box:onOpened()
	self.spr:removeFromParent()
	self.sprBlend:removeFromParent()
	self.spr1:removeFromParent()
	self.sprBlend1:removeFromParent()
	self:setPosition(self:getPositionX() + 100, self:getPositionY() - 120)
	self.bg:show()
	self:updateItems()
end

function box:enableReceiveGift(spr, removeOnClose)
	spr.t = 0
	local sz = spr:getContentSize()
	local x = sz.width / 2
	local y = sz.height / 2
	spr.clicker = display.newNode():addto(spr):anchor(0.5, 0.5):pos(x, y)

	spr.clicker:setContentSize(cc.size(35, 35))
	spr.clicker:setTouchEnabled(true)
	spr.clicker:enableClick(function ()
		if os.time() - spr.t < 0.6 then
			net.send({
				CM_BOX2_GETPRIZE
			})

			if not tolua.isnull(self.lightEffect) then
				self.lightEffect:removeFromParent()
			end

			if spr.clicker then
				spr.clicker:setTouchEnabled(false)
			end

			return
		end

		spr.t = os.time()
	end)
end

function box:onRotate(index)
	self.rotating = true
	local flashType = math.random(9) - 1
	local co = nil
	co = coroutine.create(function ()
		local preFlash = nil

		for k = self.curIndex, 16 + index do
			if self.preCell then
				self.preCell.clr:setVisible(true)
			end

			local cell = self.cellItems[k % 8 + 1]
			self.preCell = cell

			print(k, cell, k % 8 + 1, index)

			if cell then
				cell.clr:setVisible(false)

				local off = k - self.curIndex
				local speed = 0

				if off < 4 then
					speed = 90
				elseif off < 8 then
					speed = 150
				elseif off < 12 then
					speed = 270
				elseif off == 16 + index then
					speed = 0.01
				else
					speed = 390
				end

				preFlash = m2spr.playAnimation("prguse3", 600 + flashType * 2, 2, speed / 3000, true, false, true, function ()
					if preFlash then
						preFlash:removeFromParent()
					end

					coroutine.resume(co)
				end):addTo(self):anchor(0.5, 0.5)
				local pos = itemPos[k % 8 + 1]

				preFlash:setPosition(cc.p(pos.x, pos.y))
			end

			coroutine.yield()
		end

		self.curIndex = index
		self.rotating = false

		self:enableReceiveGift(self.preCell)

		local light = m2spr.playAnimation("prguse2", 260, 5, 0.15, true, false, false):addTo(self):anchor(0.5, 0.5)
		local pos = itemPos[index + 1]

		light:setPosition(cc.p(pos.x, pos.y))

		self.lightEffect = light
	end)

	coroutine.resume(co)
end

function box:onGetPrize()
	if self.openTimes > 3 or self.openTimes == 0 then
		net.send({
			CM_BOX2_CLOSE
		})
		self:hidePanel()
	else
		local curItem = self.cellItems[self.curIndex + 1]

		curItem:runs({
			cca.fadeOut(0.5),
			cca.callFunc(function ()
				local tex = res.gettex("items", self.box2PrizeItems[9 + self.openTimes]:get("looks"))

				curItem:setTex(tex)
				curItem:setContentSize(35, 35)
			end),
			cca.fadeIn(0.5)
		})
		self.cellItems[9 + self.openTimes]:run(cca.fadeOut(0.5))
	end
end

return box
