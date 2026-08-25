local bzUIConfig = require("mir2.bzUIConfig")
local infoBar = class("infoBar", function()
	return display.newNode()
end)

table.merge(infoBar, {
	bg,
	default = {
		g = 0,
		a = 255,
		r = 0,
		b = 0
	},
	btns
})

local function updateVisible()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

function infoBar:ctor(config, data)
	data.r = data.r or self.default.r
	data.g = data.g or self.default.g
	data.b = data.b or self.default.b
	data.a = data.a or self.default.a
	self.btns = {}

	local cfg = {
		x = 4,
		y = 4
	}

	self.safeAreaAdjustment = updateVisible()
	self.safeAreaLeft = getSafeAreaInsets()

	local infoCfg = bzUIConfig.infoBarCfg

	if infoCfg then
		self.bg = _get2("pic/bzmir/newui/infobar/" .. infoCfg.topbg .. ".png"):anchor(0, 1):pos(0, display.height):add2(self)
		self.middleHeight = self.bg:geth() / 2

		if not def.hideInfobarMapInfo then
			self.map = an.newBtn(_gettex2("pic/bzmir/newui/infobar/" .. infoCfg.mapbg .. ".png"), function()
				if self.hideMiniMap then
					main_scene.ui:tip("本地图不支持查看小地图")
				elseif main_scene.ui.panels.minimap then
					main_scene.ui:hidePanel("minimap")
				else
					main_scene.ui:showPanel("minimap")
				end
			end):anchor(1, 1):pos(display.width, display.height):add2(self)

			local safeAreaInsets2, safeAreaInsets = getSafeAreaInsets()

			if safeAreaInsets > 0 then
				self.mapText = an.newLabel("", 14, 1):anchor(0, 0.5):pos(10, self.map:geth() / 2):add2(self.map)
			else
				self.mapText = an.newLabel("", 14, 1):anchor(0.5, 0.5):pos(self.map:getw() / 2, self.map:geth() / 2):add2(self.map)
			end
		end

		self.level = an.newLabel("", 16, 1):anchor(0, 0.5):pos(35, self.middleHeight):add2(self.bg)

		if infoCfg.hideLevel then
			self.level:setVisible(false)
		end

		self.coin = _get2("pic/bzmir/newui/infobar/gold.png"):anchor(0, 0.5):pos(self.level:getw() + 5, self.middleHeight):add2(self.bg)
		self.coinText = an.newLabel("", 16, 1):anchor(0, 0.5):pos(self.coin:getw() + 5, self.middleHeight):add2(self.bg)

		if infoCfg.hideCoin then
			self.coin:setVisible(false)
			self.coinText:setVisible(false)
		end

		self.yb = _get2("pic/bzmir/newui/infobar/yb.png"):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)
		self.ybText = an.newLabel("", 16, 1):anchor(0, 0.5):pos(10, 15):add2(self.bg)

		if infoCfg.hideYb then
			self.yb:setVisible(false)
			self.ybText:setVisible(false)
		end

		self.lingf = _get2("pic/bzmir/newui/infobar/lingfu.png"):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)
		self.lingfText = an.newLabel("", 16, 1):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)

		if infoCfg.hideLingfu then
			self.lingf:setVisible(false)
			self.lingfText:setVisible(false)
		end

		self.shengwang = _get2("pic/bzmir/newui/infobar/shengwang.png"):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)
		self.shengwangText = an.newLabel("", 16, 1):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)

		if infoCfg.hideShengwang then
			self.shengwang:setVisible(false)
			self.shengwangText:setVisible(false)
		end

		local cnt = 1

		for key, otherBtn in pairs(infoCfg.otherBtns) do
			if self.addOtherBtn then
				self:addOtherBtn(cnt, key, otherBtn)
			end

			cnt = cnt + 1
		end

		self.shuxing = _get2("pic/bzmir/newui/infobar/shuxing.png"):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)
		self.shuxingText = an.newLabel("", 16, 1):anchor(0, 0.5):pos(10, self.middleHeight):add2(self.bg)

		if infoCfg.hideShuxing then
			self.shuxing:setVisible(false)
			self.shuxingText:setVisible(false)
		end

		if infoCfg.lv_color then
			self.level:setColor(def.role.string2Color(infoCfg.lv_color))
		else
			self.level:setColor(cc.c3b(250, 210, 100))
		end

		if infoCfg.lf_color then
			self.lingfText:setColor(def.role.string2Color(infoCfg.lf_color))
		end

		if infoCfg.gold_color then
			self.coinText:setColor(def.role.string2Color(infoCfg.gold_color))
		end

		if infoCfg.yb_color then
			self.ybText:setColor(def.role.string2Color(infoCfg.yb_color))
		end

		if infoCfg.shengwang_color then
			self.shengwangText:setColor(def.role.string2Color(infoCfg.shengwang_color))
		end

		if infoCfg.shuxing_color then
			self.shuxingText:setColor(def.role.string2Color(infoCfg.shuxing_color))
		end

		self.infoCfg = infoCfg

		def.role.autoRun(function()
			if main_scene and main_scene.ui then
				self:uptLevel()
			end
		end, 1)
	end
end

function infoBar:addOtherBtn(value, icon, labelColor)
	local items = {
		name = icon,
		btn = labelColor
	}

	if labelColor.icon then
		items.icon = _get2("pic/bzmir/newui/infobar/" .. icon .. ".png"):anchor(0, 0.5):pos(30, self.middleHeight):add2(self.bg)
	end

	items.text = an.newLabel("", labelColor.fontSize, 1):anchor(0, 0.5):pos(self.coin:getw() + 5, self.middleHeight):add2(self.bg)

	items.text:setColor(def.role.string2Color(labelColor.fontColor))

	self.btns[value] = items
end

function infoBar:uptPosition()
	local number = 10
	local x2 = 35

	if self.safeAreaAdjustment then
		x2 = math.max(x2, self.safeAreaLeft / 2)
	end

	if not self.infoCfg or not self.infoCfg.hideLevel then
		self.level:pos(x2, self.middleHeight)

		x2 = self.level:getPositionX() + self.level:getw() + number
	end

	if not self.infoCfg or not self.infoCfg.hideCoin then
		self.coinText:pos(self.coin:getw() + x2, self.middleHeight)

		x2 = self.coinText:getPositionX() + self.coinText:getw() + number
	end

	if not self.infoCfg or not self.infoCfg.hideYb then
		self.yb:pos(x2, self.middleHeight)

		x2 = x2 + self.yb:getw() + 4

		self.ybText:pos(x2, self.middleHeight)

		x2 = x2 + self.ybText:getw() + number
	end

	if not self.infoCfg or not self.infoCfg.hideLingfu then
		self.lingf:pos(x2, self.middleHeight)

		x2 = x2 + self.lingf:getw() + 4

		self.lingfText:pos(x2, self.middleHeight)

		x2 = x2 + self.lingfText:getw() + number
	end

	for _, btn2 in ipairs(self.btns) do
		if btn2.btn.icon then
			btn2.icon:pos(x2, self.middleHeight)

			x2 = x2 + btn2.icon:getw() + 4
		end

		btn2.text:pos(x2, self.middleHeight)

		x2 = x2 + btn2.text:getw() + number
	end

	def.newUIInb = true
end

function infoBar:uptPos()
	local space = 10
	local x2 = 35

	if self.safeAreaAdjustment then
		x2 = math.max(x2, self.safeAreaLeft / 2)
	end

	local function callback(self2, obj)
		if self2 then
			self2:pos(x2, self.middleHeight)

			x2 = x2 + self2:getw() + 4
		end

		if obj then
			obj:pos(x2, self.middleHeight)

			x2 = x2 + obj:getw() + space
		end
	end

	if not self.infoCfg or not self.infoCfg.hideLevel then
		self.level:pos(x2, self.middleHeight)

		x2 = self.level:getPositionX() + self.level:getw() + space + 2
	end

	if not self.infoCfg or not self.infoCfg.hideCoin then
		callback(self.coin, self.coinText)
	end

	if not self.infoCfg or not self.infoCfg.hideYb then
		callback(self.yb, self.ybText)
	end

	if not self.infoCfg or not self.infoCfg.hideLingfu then
		callback(self.lingf, self.lingfText)
	end

	if not self.infoCfg or not self.infoCfg.hideShengwang then
		callback(self.shengwang, self.shengwangText)
	end

	for _, btn2 in ipairs(self.btns) do
		callback(btn2.icon, btn2.text)
	end

	if not self.infoCfg or not self.infoCfg.hideShuxing then
		callback(self.shuxing, self.shuxingText)
	end

	def.newUIInb = true
end

function infoBar:uptOtherAbility()
	if g_data.player.cmAbil then
		for _, btn2 in ipairs(self.btns) do
			local number = g_data.player.cmAbil[btn2.name]

			if number then
				btn2.text:setString(" " .. def.ccy.priceFormat(tonumber(number)))
			end
		end

		self.uptPos(self)
	end
end

function infoBar:uptAbility()
	def.role.mtry({
		function()
			self:uptGold()
			self:uptYb()
			self:uptLingfu()
			self:uptShengwan()
			self:uptShuxing()
		end
	})
end

function infoBar:uptLevel()
	local ability = g_data.player.ability

	self.level:setString("Lv: " .. ability:get("level"))
	self:uptPos()
end

function infoBar:uptGold()
	self.coinText:setString(" " .. def.ccy.priceFormat(g_data.player.gold))
	self.uptPos(self)
end

function infoBar:uptYb()
	local value = g_data.player.goldNum.gold

	self.ybText:setString(" " .. def.ccy.priceFormat(value))
	self.uptPos(self)
end

function infoBar:uptLingfu()
	local value = g_data.player.goldNum.gird

	self.lingfText:setString(" " .. def.ccy.priceFormat(value))
	self.uptPos(self)
end

function infoBar:uptShengwan()
	local value = g_data.player.ability3

	self.shengwangText:setString(" " .. def.ccy.priceFormat(value:get("prestige")))
	self:uptPos()
end

function infoBar:uptShuxing()
	local function callback(self2)
		local p = g_data.player.ability:get(self2)

		if g_data.player.cmAbil and g_data.player.cmAbil[self2] then
			p = p - g_data.player.cmAbil[self2]

			if p < 0 then
				p = 0
			end
		end

		return p
	end

	local value = CS_FULLDC .. ":"
	local value2 = callback("DC")
	local value3 = callback("maxDC")

	if def.ccy.useMC and (g_data.player.job == 1 or def.ccy.useMC()) then
		value = CS_FULLMC .. ":"
		value2 = callback("MC")
		value3 = callback("maxMC")
	elseif def.ccy.useSC and (g_data.player.job == 2 or def.ccy.useSC()) then
		value = CS_FULLSC .. ":"
		value2 = callback("SC")
		value3 = callback("maxSC")
	end

	local value4 = callback("AC")
	local value5 = callback("maxAC")
	local value6 = callback("MAC")
	local value7 = callback("maxMAC")
	local value8 = ((value .. def.ccy.priceFormat(value2) .. "-" .. def.ccy.priceFormat(value3)) .. " " .. CS_AC .. ":" .. def.ccy.priceFormat(value4) .. "-" .. def.ccy.priceFormat(value5)) .. " " .. CS_MAC .. ":" .. def.ccy.priceFormat(value6) .. "-" .. def.ccy.priceFormat(value7)

	self.shuxingText:setString(" " .. value8)
	self:uptPos()
end

function infoBar:uptTime()
	return
end

function infoBar:uptSignal()
	return
end

function infoBar:uptBattery()
	return
end

function infoBar:uptMap(value, value2)
	if not def.hideInfobarMapInfo then
		local function callback(self2)
			if self2 == cAreaStateFight then
				return display.COLOR_RED
			elseif self2 == cAreaStateSafe then
				return display.COLOR_GREEN
			elseif self2 == cAreaStateGuildWar then
				return cc.c3b(250, 210, 100)
			elseif self2 == cAreaStateDareWar then
				return display.COLOR_RED
			elseif self2 == cAreaStateReliveable then
				return display.COLOR_GREEN
			end

			return display.COLOR_GREEN
		end

		if not value or value == "" then
			value = g_data.map.mapTitle
		end

		self.hideMiniMap = false

		if value and value ~= "" then
			if self.mapText then
				self.mapText:setString(value)
				self.mapText:setColor(callback(value2))
			end

			local items = def.role.mainsetting.map_Set

			if items and #items > 0 then
				for _, item in ipairs(items) do
					if string.find(item.mapname, value) ~= nil and item.hideMiniMap then
						self.hideMiniMap = true

						break
					end
				end
			end
		end

		if self.hideMiniMap then
			main_scene.ui:hidePanel("minimap")
		else
			main_scene.ui:showPanel("minimap")
		end
	end
end

return infoBar
