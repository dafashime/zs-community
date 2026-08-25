local item = import("..common.item")
local heroBag = class("heroBag", function()
	return display.newNode()
end)

table.merge(heroBag, {})

function heroBag:resetPanelPosition(type)
	if type == "left" then
		self:anchor(0, 1):pos(100, display.height - 16)
	elseif type == "right" then
		self:anchor(1, 1):pos(display.width - 60, display.height - 16)
	end

	if self.setFocus then
		self:setFocus()
	end

	return self
end

function heroBag:ctor(from)
	self._scale = self:getScale()
	self._supportMove = true

	self:reloadAll(g_data.hero.bagSize, true, from)

	if main_scene.ui.panels and main_scene.ui.panels.bag then
		local posX = main_scene.ui.panels.bag:getPositionX() + main_scene.ui.panels.bag:getCascadeBoundingBox().width

		self:anchor(0, 1):pos(posX - 16, display.height - 16)
	end
end

function heroBag:bagsize2row(bagSize)
	return math.ceil(bagSize / 5)
end

function heroBag:reloadAll(bagSize, first, from)
	if self.bagSize == bagSize then
		return
	end

	self.bagSize = bagSize

	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():add2(self)

	local space = 45
	local itemTotalHeight = self:bagsize2row(bagSize) * space
	local bg1 = res.get2("pic/panels/heroBag/bg1.png")
	local bg2 = res.get2("pic/panels/heroBag/bg2.png")
	local bg3 = res.get2("pic/panels/heroBag/bg3.png")

	self:size(cc.size(bg1:getw(), bg1:geth() + bg3:geth() + itemTotalHeight - 12)):scale(g_data.client.lastScale.heroBag):resetPanelPosition(from == "bag" and "right" or "left")

	if not first then
		self:removeTouchFrame("main")
		self:addTouchFrame(cc.rect(0, 0, self:getw(), self:geth()), "main")
	end

	bg1:anchor(0, 1):pos(0, self:geth()):add2(self.content)
	bg2:anchor(0, 0):scaley((self:geth() - bg1:geth() - bg3:geth()) / bg2:geth()):pos(0, bg3:geth()):add2(self.content)
	bg3:anchor(0, 0):add2(self.content)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 6, self:geth() - 5):addto(self.content)

	local scaleBtn

	scaleBtn = an.newBtn(res.gettex2("pic/common/scaleBig20.png"), function()
		sound.playSound("103")
		self:stopAllActions()

		local scale = self:getScale() + 0.1

		if scale > 1.6 then
			scale = 1
		end

		self._scale = scale

		self:scaleTo(0.3, scale)
		g_data.client:setLastScale("heroBag", scale)
		scaleBtn.label:setString("x" .. string.format("%01d", (scale - 1) * 10 + 1))
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
			x = 13,
			y = -12
		}
	}):pos(255, 28):add2(self.content)

	for i = 1, bagSize do
		local col = (i - 1) % 5
		local line = math.modf((i - 1) / 5)

		res.get2("pic/common/itembg2.png"):pos(47 + col * space, self:geth() - 78 - line * space):add2(self.content)
	end

	self.items = {}

	self:reload()
end

function heroBag:reload()
	for k, v in pairs(self.items) do
		v:removeSelf()
	end

	self.items = {}

	for i = 1, 40 do
		local v = g_data.heroBag.items[i]

		if v then
			self.items[i] = item.new(v, self, {
				idx = i
			}):addto(self.content):pos(self:idx2pos(i))
			self.items[i].owner = "heroBag"
		end
	end
end

function heroBag:idx2pos(idx)
	idx = idx - 1

	local h = idx % 5
	local v = math.modf(idx / 5)

	return 47 + h * item.w, self:geth() - 78 - v * item.h
end

function heroBag:pos2idx(x, y)
	local h = (x - 47) / item.w + 0.5
	local v = (self:geth() - 78 - y) / item.h + 0.5

	if h > 0 and h < 5 and v > 0 and v < 8 then
		return math.floor(v) * 5 + math.floor(h) + 1
	end

	return -1
end

function heroBag:addItem(makeIndex)
	local i, v = g_data.heroBag:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		self.items[i] = item.new(v, self, {
			idx = i
		}):addto(self.content):pos(self:idx2pos(i))
		self.items[i].owner = "heroBag"
	end
end

function heroBag:delItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end
end

function heroBag:uptItem(makeIndex)
	local i, v = g_data.heroBag:getItem(makeIndex)

	if v and self.items[i] then
		self.items[i].data = v
	end
end

function heroBag:putInItem(item)
	if not g_data.client.heroPutInItem then
		local data = item.data

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
		end

		g_data.bag:delItem(data:get("makeIndex"))
		g_data.client:setHeroPutInItem(data)

		local makeIndex = data:get("makeIndex")

		net.send({
			CM_HERO_TOHEROBAG,
			recog = makeIndex
		}, {
			data.getVar("name")
		})
	end
end

function heroBag:getBackItem(item)
	if not g_data.client.heroGetBackItem then
		local data = item.data

		self:delItem(data:get("makeIndex"))
		g_data.heroBag:delItem(data:get("makeIndex"))
		g_data.client:setHeroGetBackItem(data)

		local makeIndex = data:get("makeIndex")

		net.send({
			CM_HERO_TOHUMBAG,
			recog = makeIndex
		}, {
			data.getVar("name")
		})
	end
end

function heroBag:putItem(item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		self:putInItem(item)
	elseif form == "heroEquip" then
		item:takeOff()
	elseif form == "heroBag" then
		local putIdx = self:pos2idx(x / self:getScale(), y / self:getScale())

		if putIdx == -1 or item.params.idx == putIdx then
			return
		end

		local srcIdx = item.params.idx

		if g_data.heroBag:isAallCanPileUp(srcIdx, putIdx) then
			local item1 = self.items[putIdx].data
			local makeIndex2 = self.items[srcIdx].data:get("makeIndex")

			if item1.isNeedResetPos(self.items[srcIdx].data) then
				self.items[putIdx]:pos(self:idx2pos(putIdx))
				self.items[srcIdx]:pos(self:idx2pos(srcIdx))
			end

			net.send({
				CM_PILEUPITEM,
				series = 1,
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

			self.items[srcIdx], self.items[putIdx] = target, item

			g_data.heroBag:changePos(srcIdx, putIdx)
		end

		return true
	end
end

function heroBag:duraChange(makeindex)
	for k, v in pairs(self.items) do
		if makeindex == v.data:get("makeIndex") then
			v:duraChange()

			return
		end
	end
end

return heroBag
