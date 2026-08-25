local current = ...
local bzUIConfig = require("mir2.bzUIConfig")
local btnEx = import("..btnEx")
local cc2 = require("mir2.cc")
local hp = class("widget_hp", function()
	return display.newNode()
end)

table.merge(hp, {
	config,
	mpPercent = 0,
	hpPercent = 0,
	data = {
		x = 0,
		y = 0
	}
})

function hp:ctor(config, data)
	local x = bzUIConfig.hpCfg

	if x then
		self.size(self, x.hpWidth, x.hpHeight):anchor(0.5, 0.5):pos(data.x, data.y)
		display.newNode():size(self.getContentSize(self)):pos(self.centerPos(self)):anchor(0.5, 0.5):add2(self):enableClick(function()
			if x.openMenu then
				main_scene.ui.ui_btnEx = btnEx.new()
			end
		end):setName("diyhp")

		self.hpbg = _get2("pic/bzmir/newui/hp/" .. x.hpbg.pic .. ".png"):anchor(0.5, 1):pos(self.getw(self) / 2 + x.hpbg.offsetX, self.geth(self) + x.hpbg.offsetY):addto(self)

		if x.hpbg2 then
			_get2("pic/bzmir/newui/hp/" .. x.hpbg2.pic .. ".png"):anchor(0.5, 1):pos(self.getw(self) / 2 + x.hpbg2.offsetX, self.geth(self) + x.hpbg2.offsetY):addto(self)
		end

		for _, btn in pairs(x.btns) do
			if self.addBtn then
				self:addBtn(btn)
			end
		end

		local value = _getani2("pic/bzmir/newui/hp/hp3/%d.png", x.hpAni.picStart, x.hpAni.picEnd, x.fps)

		if value then
			value.retain(value)

			local y = _get2("pic/bzmir/newui/hp/hp3/" .. x.hpAni.picStart .. ".png"):pos(self.hpbg.getw(self.hpbg) / 2 + x.hpAni.offsetX, x.hpAni.offsetY):add2(self.hpbg):anchor(1, 0)

			if y then
				self.hpSpr = _get2("pic/bzmir/newui/hp/hpbg.png"):anchor(0, 1):pos(0, y.geth(y)):addto(y, 2)

				y.runForever(y, cc.Animate:create(value))
			end
		end

		local value2 = _getani2("pic/bzmir/newui/hp/hp4/%d.png", x.mpAni.picStart, x.mpAni.picEnd, x.fps)

		if value2 then
			value2.retain(value2)

			local y2 = _get2("pic/bzmir/newui/hp/hp4/" .. x.mpAni.picStart .. ".png"):pos(self.hpbg.getw(self.hpbg) / 2 + x.mpAni.offsetX, x.mpAni.offsetY):add2(self.hpbg):anchor(0, 0)

			if y2 then
				self.mpSpr = _get2("pic/bzmir/newui/hp/mpbg.png"):anchor(0, 1):pos(0, y2.geth(y2)):addto(y2, 2)

				y2.runForever(y2, cc.Animate:create(value2))
			end
		end

		if x.additnalAni then
			local value3 = _getani2("pic/bzmir/newui/hp/additnal/%d.png", x.additnalAni.picStart, x.additnalAni.picEnd, x.fps)

			if value3 then
				value3.retain(value3)

				local value4 = _get2("pic/bzmir/newui/hp/additnal/" .. x.additnalAni.picStart .. ".png"):pos(self.hpbg.getw(self.hpbg) / 2 + x.additnalAni.offsetX, x.additnalAni.offsetY):add2(self.hpbg):anchor(0, 0)

				if value4 then
					value4.runForever(value4, cc.Animate:create(value3))
				end
			end
		end

		local y3 = _get2("pic/bzmir/newui/hp/hpValueBg.png"):pos(self.hpbg.getw(self.hpbg) / 2 + x.valueBg.offsetX, x.valueBg.offsetY):add2(self.hpbg)

		self.hplabel = an.newLabel("0/0", 12, 1):anchor(0.5, 0.5):pos(x.valueBg.hpValuePosX, y3.geth(y3) / 2):add2(y3)
		self.mplabel = an.newLabel("0/0", 12, 1):anchor(0.5, 0.5):pos(x.valueBg.mpValuePosX, y3.geth(y3) / 2):add2(y3)

		if def.openTalkWithNpc then
			self.openNpc = an.newLabel("", 18, 1, {
				color = display.COLOR_GREEN
			}):add2(self.hpbg, 1):anchor(1, 1):pos(self.hpbg:getw() - def.talkNpcOfstX or 120, self.hpbg:geth() + def.talkNpcOfstY or 40)

			self.openNpc:addUnderline(display.COLOR_GREEN)
			self.openNpc:setTouchEnabled(true)
			self.openNpc:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos)
				if startPos.name == "began" then
					self.openNpc:scale(1.1):setColor(cc.c3b(255, 0, 0))

					self.openNpc.disable = false
					self.startPos = startPos

					return true
				elseif startPos.name == "ended" then
					self.openNpc:scale(1):setColor(display.COLOR_GREEN)

					if not self.openNpc.disable then
						sound.playSound("103")

						if not self.role then
							return
						end

						net.send({
							CM_CLICKNPC,
							recog = self.role.roleid
						})
					end
				elseif cc.pGetDistance(self.startPos, startPos) > 35 then
					self.openNpc:scale(1):setColor(display.COLOR_GREEN)

					self.openNpc.disable = true
				end
			end)
		end
	end
end

function hp:addBtn(value)
	local items = {}

	if value.pressPic then
		items = {
			pressImage = _gettex2("pic/bzmir/newui/hp/" .. value.pressPic .. ".png")
		}
	end

	an.newBtn(_gettex2("pic/bzmir/newui/hp/" .. value.pic .. ".png"), function()
		sound.playSound("103")

		if value.panelId and value.jsonFile then
			def.role.PF:togglePanel(value.panelId, value.jsonFile)
		elseif value.panel then
			main_scene.ui:togglePanel(value.panel)
		end

		if value.btnCallbacksKey and value.btnCallbacksCMD then
			main_scene.ui.console.btnCallbacks:handle(value.btnCallbacksKey, value.btnCallbacksCMD)
		elseif value.callCMD then
			def.role.call(bzmir.mcmd .. value.callCMD)
		end
	end, items):anchor(0.5, 0.5):pos(self.hpbg.getw(self.hpbg) / 2 + value.offsetX, value.offsetY):addto(self, 1):scale(value.scale)
end

function hp:setHpprocess(hpPercent)
	if hpPercent ~= self.hpPercent then
		self.hpPercent = hpPercent

		local size = self.hpSpr:getTexture():getContentSize()

		self.hpSpr:setTextureRect(cc.rect(0, 0, size.width, size.height * (1 - hpPercent)))
	end
end

function hp:setMpprocess(mpPercent)
	if mpPercent ~= self.mpPercent then
		self.mpPercent = mpPercent

		local size = self.mpSpr:getTexture():getContentSize()

		self.mpSpr:setTextureRect(cc.rect(0, 0, size.width, size.height * (1 - mpPercent)))
	end
end

function hp:update(dt)
	local ability = g_data.player.ability

	if not ability then
		return
	end

	local hpPercent = ability.HP / ability.maxHP

	if hpPercent > 1 then
		hpPercent = 1
	end

	if hpPercent < 0 then
		hpPercent = 0
	end

	self:setHpprocess(hpPercent)

	local mpPercent = ability.MP / ability.maxMP

	if mpPercent > 1 then
		mpPercent = 1
	end

	if mpPercent < 0 then
		mpPercent = 0
	end

	self:setMpprocess(mpPercent)
	self.mplabel:setString(ability.MP .. "/" .. ability.maxMP)
	self.hplabel:setString(ability.HP .. "/" .. ability.maxHP)

	if main_scene.ground.map and def.openTalkWithNpc then
		local role
		local role2

		for _, npc in pairs(main_scene.ground.map.npcs) do
			if math.abs(main_scene.ground.player.x - npc.x) <= 2 and math.abs(main_scene.ground.player.y - npc.y) <= 2 then
				if role and math.abs(main_scene.ground.player.x - npc.x) < role.near_x and math.abs(main_scene.ground.player.y - npc.y) < role.near_y then
					role2 = npc
				end

				role = npc
				role.near_x = math.abs(main_scene.ground.player.x - npc.x)
				role.near_y = math.abs(main_scene.ground.player.y - npc.y)
			end
		end

		if role2 then
			self.role = role2

			self.openNpc:setVisible(true)
			self.openNpc:setString("对话 " .. role2.info:getName())
		elseif role then
			self.role = role

			self.openNpc:setVisible(true)
			self.openNpc:setString("对话 " .. role.info:getName())
		else
			self.role = nil

			self.openNpc:setVisible(false)
		end
	end
end

function hp:setEquipLockVisible(visible)
	return
end

return hp
