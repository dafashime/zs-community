local item = import("..common.item")
local cc2 = require("mir2.cc")
local heroBag = require("mir2.scenes.main.panel.heroBag1")

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
	self.quick = false

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

	an.newBtn(res.gettex2("pic/panels/bag/zlbb.png"), function()
		if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
			main_scene.ui:fadeLabel("仓库快速存取开启中，无法操作")
		else
			self.quick = not self.quick

			if self.quick then
				main_scene.ui:fadeLabel("英雄背包快速存取：开")
			else
				main_scene.ui:fadeLabel("英雄背包快速存取：关")
			end
		end
	end, {
		manual = true,
		sprite = res.gettex2("pic/panels/bag/quick.png"),
		select = {
			res.gettex2("pic/panels/bag/zlbb2.png")
		}
	}):addTo(self.content, 2):pos(60, 20):scale(0.8)

	for i = 1, bagSize do
		local col = (i - 1) % 5
		local line = math.modf((i - 1) / 5)

		res.get2("pic/common/itembg2.png"):pos(47 + col * space, self:geth() - 78 - line * space):add2(self.content)
	end

	self.items = {}

	self:reload()
end

function heroBag:reload()
	for k, v2 in pairs(self.items) do
		v2:removeSelf()
	end

	self.items = {}

	for i = 1, 40 do
		local v = g_data.heroBag.items[i]

		if v then
			self.items[i] = item.new(v, self, {
				showbg = false,
				showEffect = true,
				idx = i
			}):addto(self.content):pos(self:idx2pos(i))
			self.items[i].owner = "heroBag"

			self.items[i]:runs({
				cc.DelayTime:create(0.2),
				cc.CallFunc:create(function()
					local takeOnPosition = getTakeOnPosition(v.getVar("stdMode"))

					if takeOnPosition then
						local value = v
						local value2 = g_data.heroEquip.items

						if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
							self.items[i].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[i], 3):pos(12, -12)
						end
					end
				end)
			})
		end
	end
end

function heroBag:addItem(makeIndex)
	local i, v = g_data.heroBag:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		self.items[i] = item.new(v, self, {
			showbg = false,
			showEffect = true,
			idx = i
		}):addto(self.content):pos(self:idx2pos(i))
		self.items[i].owner = "heroBag"

		self.items[i]:runs({
			cc.DelayTime:create(0.2),
			cc.CallFunc:create(function()
				local takeOnPosition = getTakeOnPosition(v.getVar("stdMode"))

				if takeOnPosition then
					local value = v
					local value2 = g_data.heroEquip.items

					if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
						self.items[i].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[i], 3):pos(12, -12)
					end
				end
			end)
		})
	end
end

return heroBag
