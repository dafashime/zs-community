local common = import("mir2.scenes.main.common.common")
local itemInfo = import("mir2.scenes.main.common.itemInfo")
local tip = class("leftTopTip", function()
	return display.newNode()
end)
local cc2 = require("mir2.cc")

table.merge(tip, {
	msgs = {},
	ui_sets = {}
})

local function cleanup()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

function tip:ctor()
	self.msgs = {}
	self.ui_sets = def.role.mainsetting.uiTips_Sets

	if not def.role.mainsetting.uiTips_Sets then
		self.ui_sets = {
			fontSize = 20,
			fontColor = 250,
			maxLine = 5,
			offsetY = 100,
			fromLeft = true,
			lineSpace = 22,
			offsetX = 50
		}
	end

	local count = 0

	if cleanup() then
		count = getSafeAreaInsets()
	end

	if self.ui_sets.fromLeft then
		self:pos(self.ui_sets.offsetX + count, display.height + self.ui_sets.offsetY - self.ui_sets.maxLine * self.ui_sets.lineSpace)
	else
		self:pos(display.cx + self.ui_sets.offsetX + count, display.cy + self.ui_sets.offsetY - self.ui_sets.maxLine * self.ui_sets.lineSpace)
	end
end

function tip:getSpace()
	return 24
end

function tip:upt()
	for i, v in ipairs(self.msgs) do
		v:pos(0, (self.ui_sets.maxLine - i) * self.ui_sets.lineSpace)
	end
end

function tip:show(text, color)
	local msg

	if not color or type(color) ~= "table" then
		color = _stringToCorlor(self.ui_sets.fontColor)
	end

	msg = an.newLabel(text, self.ui_sets.fontSize, 1, {
		color = color
	}):add2(self):runs({
		cc.DelayTime:create(3),
		cc.FadeOut:create(0.3),
		cc.CallFunc:create(function()
			cc2.ms({
				function()
					if msg then
						table.removebyvalue(self.msgs, msg)
						msg:removeSelf()

						msg = nil

						self:upt()
					end
				end
			})
		end)
	})

	msg:setCascadeOpacityEnabled(true)

	self.msgs[#self.msgs + 1] = msg

	if self.ui_sets.maxLine < #self.msgs then
		self.msgs[1]:removeSelf()
		table.remove(self.msgs, 1)
	end

	self:upt()
end

function tip:newEquip(sprite, value)
	if not sprite then
		return
	end

	if not g_data.setting.base.newEquipTip then
		return
	end

	local canUseEquip = def.ccy.canUseEquip(sprite, true, true, value)

	if not canUseEquip then
		return
	end

	local enabled = false
	local value2 = value and g_data.heroBag or g_data.bag
	local var = sprite.getVar("stdMode")
	local value3 = sprite:get("makeIndex")

	local function cleanup(self)
		local items = {}
		local items2 = {}
		local value = value and g_data.heroEquip.items or g_data.equip.items

		for index = 0, 16 do
			local value2 = value[index]

			if value2 and value3 ~= value2:get("makeIndex") and (checkExist(var, 5, 6) and checkExist(value2.getVar("stdMode"), 5, 6) or checkExist(var, 10, 11) and checkExist(value2.getVar("stdMode"), 10, 11) or checkExist(var, 20, 21, 19) and checkExist(value2.getVar("stdMode"), 20, 21, 19) or checkExist(var, 22, 23) and checkExist(value2.getVar("stdMode"), 22, 23) or checkExist(var, 26, 24) and checkExist(value2.getVar("stdMode"), 26, 24) or var == value2.getVar("stdMode")) then
				items[#items + 1] = value2
				items2[#items2 + 1] = index
			end
		end

		return items, items2
	end

	local where = getTakeOnPosition(sprite.getVar("stdMode"))
	local items, items2 = cleanup(sprite)

	if #items > 0 then
		if items2 and #items2 == 1 then
			if var == 22 or var == 23 then
				where = items2[1] == 7 and 8 or 7
				enabled = true
			elseif var == 24 or var == 26 then
				where = items2[1] == 5 and 6 or 5
				enabled = true
			elseif cc2.superior(sprite, items[1], nil, value) then
				where = items2[1]
				enabled = true
			end
		else
			for index, item in ipairs(items) do
				if cc2.superior(sprite, item, nil, value) then
					where = items2[index]
					enabled = true
				end
			end
		end
	else
		enabled = true
	end

	if not enabled then
		return
	end

	local function cleanup2()
		if def.role.timer.__newEquip__ then
			scheduler.unscheduleGlobal(def.role.timer.__newEquip__)

			def.role.timer.__newEquip__ = nil
		end

		if self.equipBg then
			self.equipBg:removeSelf()

			self.equipBg = nil
		end
	end

	cleanup2()

	self.equipBg = res.get2("pic/bzmir/better/bg.png"):pos(display.cx + 320, display.cy - 90):add2(main_scene.ui, 9999):anchor(0.5, 0.5)

	an.newBtn(res.gettex2("pic/bzmir/better/use.png"), function()
		sound.playSound("103")

		if main_scene.ui.panels.deal then
			main_scene.ui:tip("面对面交易无法穿戴")

			return
		end

		if canUseEquip and value2.use(value2, "take", sprite.get(sprite, "makeIndex"), {
			where = where
		}) then
			net.send({
				value and CM_HERO_TAKEON or CM_TAKEONITEM,
				recog = sprite:get("makeIndex"),
				param = where
			}, {
				sprite.getVar("name")
			})
			def.ccy.equipChgTrigger("on", tostring(where), sprite)

			local value = value and main_scene.ui.panels.heroBag or main_scene.ui.panels.bag

			if value then
				value:delItem(sprite:get("makeIndex"))
			end
		end

		cleanup2()
	end, {
		pressImage = res.gettex2("pic/bzmir/better/use1.png"),
		label = {
			"使用",
			16,
			1,
			{
				color = display.COLOR_WHITE
			}
		}
	}):anchor(0.5, 0.5):pos(self.equipBg:getw() / 2 + 1, 30):addto(self.equipBg)
	an.newBtn(res.gettex2("pic/bzmir/better/close.png"), function()
		sound.playSound("103")
		cleanup2()
	end, {
		pressImage = res.gettex2("pic/bzmir/better/close1.png"),
		label = {
			"",
			16,
			1,
			{
				color = display.COLOR_WHITE
			}
		}
	}):anchor(0, 1):pos(self.equipBg:getw(), self.equipBg:geth()):addto(self.equipBg)

	self.sprite = res.getItemsWithBg("items", sprite.getVar("name"), sprite.getVar("looks") or 0, 0, 1):pos(self.equipBg:getw() / 2, self.equipBg:geth() / 2 + 30):add2(self.equipBg):anchor(0.5, 0.5):scale(1.3)

	self.sprite:setTouchEnabled(true)
	self.sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(point)
		if point.name == "began" then
			self.sprite.offsetBeginY = point.y
			self.sprite.offsetBeginX = point.x

			return true
		elseif point.name == "ended" then
			local value = point.y - self.sprite.offsetBeginY
			local value2 = point.x - self.sprite.offsetBeginX

			if math.abs(value) <= 10 and math.abs(value2) <= 10 then
				local items = {
					x = point.x,
					y = point.y
				}

				itemInfo.create({
					data = sprite
				}, items, {
					from = "bag"
				})
			end
		end
	end)
	res.get2("pic/common/diffbetter.png"):addTo(self.sprite, 3):pos(self.sprite:getw() - 6, 8):scale(0.8)

	def.role.timer.__newEquip__ = scheduler.performWithDelayGlobal(function()
		if main_scene and main_scene.ui and self.equipBg then
			self.equipBg:removeSelf()

			self.equipBg = nil
		end
	end, 10)
end

return tip
