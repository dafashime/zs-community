local common = import("...common.common")
local magic = import("...common.magic")
local cc2 = require("mir2.cc")
local attackBtns = class("attackBtns", function()
	return display.newNode()
end)

table.merge(attackBtns, {
	bg,
	mon,
	player,
	attack,
	info = {
		player,
		energy,
		mobile
	},
	btnBg = {},
	default = {
		g = 0,
		a = 255,
		b = 0,
		r = 0
	},
	looks,
	monLooks
})

function attackBtns:clear()
	if self.btnBg.player then
		self.btnBg.player:removeSelf()

		self.btnBg.player = nil
	end

	if self.btnBg.mon then
		self.btnBg.mon:removeSelf()

		self.btnBg.mon = nil
	end

	if self.btnBg.normal then
		self.btnBg.normal:removeSelf()

		self.btnBg.normal = nil
	end
end

function attack()
	local value = main_scene.ground.player

	if cc2.isAutoXiama() then
		return
	end

	local value2 = main_scene.ui.console.controller.lock

	if not g_data.setting.autoRat.defaultAtkMagic.enable then
		value2:attackAny()
	elseif value2:canAttack() then
		if g_data.setting.autoRat.defaultAtkMagic.enable then
			value2:attackUseMagic(value2.role)

			return
		end
	else
		value2:lockAnyOnly()

		if value2:canAttack() and g_data.setting.autoRat.defaultAtkMagic.enable then
			value2.attackUseMagic(value2, value2.role)

			return
		end
	end
end

function player(self)
	local value = main_scene.ui.console.controller.lock

	def.role.mtry({
		function()
			value.lockPlayer(value)
		end
	})
end

function mon(self)
	local value = main_scene.ui.console.controller.lock

	def.role.mtry({
		function()
			value.lockMon(value)
		end
	})
end

function attackBtns:ctor(value, r)
	r.r = r.r or self.default.r
	r.g = r.g or self.default.g
	r.b = r.b or self.default.b
	r.a = r.a or self.default.a
	self.bg = res.get2("pic/console/attack/attackBg.png"):addTo(self):pos(0, 0):anchor(0, 0):scale(0.8)

	self.bg:setName("lock_slide")
	self.size(self, 170, 170):anchor(0.5, 0.5):pos(r.x, r.y)

	local count = 1

	if not g_data.setting.base.slideLock then
		count = 2
	end

	self.setLockType(self, count)
end

function attackBtns:chgAttackType()
	local count = 1

	if not g_data.setting.base.slideLock then
		count = 2
	end

	self:setLockType(count)
end

function attackBtns:playClickEffect()
	if not self.clickEffAni then
		self.clickEffAni = res.getani2("pic/effect/btnclick/%d.png", 1, 5, 0.06)

		self.clickEffAni:retain()
	end

	local value_2

	value_2 = res.get2("pic/effect/btnclick/1.png"):pos(self:centerPos()):add2(self.bg):scale(0.7):runs({
		cc.Animate:create(self.clickEffAni),
		cc.CallFunc:create(function()
			value_2:removeSelf()

			value_2 = nil
		end)
	})
end

function attackBtns:setLockType(lockType)
	self.bg.removeChildByName(self.bg, "player")
	self.bg.removeChildByName(self.bg, "normal")
	self.bg.removeChildByName(self.bg, "mon")
	self.bg.removeChildByName(self.bg, "attack")
	self.bg.removeChildByName(self.bg, "magic")

	if self.bg then
		self.bg:removeSelf()

		self.bg = nil
	end

	self.bg = res.get2("pic/console/attack/attackBg.png"):addTo(self):pos(0, 0):anchor(0, 0)

	self.bg:setName("lock_slide")

	if lockType == 1 then
		local enabled = false
		local enabled2 = false
		local enabled3 = false
		local enabled4 = false

		display.newSprite(res.getframe2("pic/console/attack/attack-normal.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("normal")
		an.newBtn(res.gettex2("pic/console/attack/attackBig.png"), function()
			sound.playSound("103")
		end, {
			size = cc.size(100, 100),
			pressImage = res.gettex2("pic/console/attack/attack-pressed.png")
		}):pos(self.getw(self) / 2, self.geth(self) / 2):addto(self.bg):addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(point)
			local number = 150
			local number2 = 50
			local value = point.x - self.getPositionX(self) + 50 + (point.y - self.getPositionY(self) + 50)

			if point.name == "began" then
				-- block empty
			elseif point.name == "moved" then
				enabled4 = true

				if value < number2 then
					if not enabled then
						enabled = true
						enabled2 = false
						enabled3 = false

						self.bg.removeChildByName(self.bg, "player")
						self.bg.removeChildByName(self.bg, "normal")
						self.bg.removeChildByName(self.bg, "mon")
						display.newSprite(res.getframe2("pic/console/attack/attackBg-mon.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("mon")
					end
				elseif number < value then
					if not enabled2 then
						enabled = false
						enabled2 = true
						enabled3 = false

						self.bg.removeChildByName(self.bg, "player")
						self.bg.removeChildByName(self.bg, "normal")
						self.bg.removeChildByName(self.bg, "mon")
						display.newSprite(res.getframe2("pic/console/attack/attackBg-player.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("player")
					end
				elseif value <= number and number2 <= value and not enabled3 then
					enabled = false
					enabled2 = false
					enabled3 = true

					self.bg.removeChildByName(self.bg, "player")
					self.bg.removeChildByName(self.bg, "normal")
					self.bg.removeChildByName(self.bg, "mon")
					display.newSprite(res.getframe2("pic/console/attack/attack-normal.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("normal")
				end
			elseif point.name == "ended" or point.name == "cancelled" then
				if enabled4 then
					if value < number2 then
						mon(self)
					elseif number < value then
						player(self)
					elseif value <= number and number2 <= value then
						attack()
						self:playClickEffect()
					end
				else
					attack()
					self:playClickEffect()
				end

				enabled = false
				enabled2 = false
				enabled3 = false
				enabled4 = false

				self.bg.removeChildByName(self.bg, "player")
				self.bg.removeChildByName(self.bg, "normal")
				self.bg.removeChildByName(self.bg, "mon")
				display.newSprite(res.getframe2("pic/console/attack/attack-normal.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("normal")
			end

			return true
		end)

		if g_data.setting.autoRat.defaultAtkMagic.enable and g_data.setting.autoRat.defaultAtkMagic.magicId then
			local magicConfigByUid = def.magic.getMagicConfigByUid(g_data.setting.autoRat.defaultAtkMagic.magicId, main_scene.ground.player)
			local value = g_data.setting.autoRat.defaultAtkMagic.magicId

			if magicConfigByUid.name and string.find(magicConfigByUid.name, "|") ~= nil then
				value = value .. "-" .. g_data.player.job
			end

			if magicConfigByUid.picId then
				value = magicConfigByUid.picId
			end

			local frameName = "pic/console/skill-icons/" .. value .. ".png"

			display.newSprite(res.getframe2(frameName), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):scale(1.35):add2(self.bg):setName("magic")
		end
	else
		self.player = an.newBtn(res.gettex2("pic/console/attack/player.png"), function()
			player(self)
		end, {
			pressImage = res.gettex2("pic/console/attack/player-pressed.png"),
			size = cc.size(25, 25)
		}):addTo(self.bg):pos(self.getw(self) / 2 + 35, self.getw(self) / 2 + 35):anchor(0.5, 0.5)
		self.mon = an.newBtn(res.gettex2("pic/console/attack/mon.png"), function()
			mon(self)
		end, {
			pressImage = res.gettex2("pic/console/attack/mon-pressed.png"),
			size = cc.size(25, 25)
		}):addTo(self.bg):pos(self.getw(self) / 2 - 35, self.getw(self) / 2 - 35):anchor(0.5, 0.5)
		self.attack = an.newBtn(res.gettex2("pic/console/attack/attack.png"), function()
			attack()
		end, {
			pressImage = res.gettex2("pic/console/attack/attack-opressed.png"),
			size = cc.size(60, 60)
		}):addTo(self.bg):pos(self.getw(self) / 2, self.geth(self) / 2):anchor(0.5, 0.5)
	end
end

function attackBtns:handleTouch(event)
	local number = 150
	local number2 = 50
	local value = event.x - self.getPositionX(self) + 50 + (event.y - self.getPositionY(self) + 50)

	if event.name == "began" then
		print("new-------------------")
	elseif event.name == "moved" then
		self.isMoved = true

		if g_data.setting.base.slideLock then
			if value < number2 then
				if not self.isMon then
					self.isMon = true
					self.isPlayer = false
					self.isNormal = false

					self.bg.removeChildByName(self.bg, "player")
					self.bg.removeChildByName(self.bg, "normal")
					self.bg.removeChildByName(self.bg, "mon")
					self:clear()

					self.btnBg.mon = display.newSprite(res.getframe2("pic/console/attack/attackBg-mon.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("mon")
				end
			elseif number < value then
				if not self.isPlayer then
					self.isMon = false
					self.isPlayer = true
					self.isNormal = false

					self.bg.removeChildByName(self.bg, "player")
					self.bg.removeChildByName(self.bg, "normal")
					self.bg.removeChildByName(self.bg, "mon")
					self:clear()

					self.btnBg.player = display.newSprite(res.getframe2("pic/console/attack/attackBg-player.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("player")
				end
			elseif value <= number and number2 <= value and not self.isNormal then
				self.isMon = false
				self.isPlayer = false
				self.isNormal = true

				self.bg.removeChildByName(self.bg, "player")
				self.bg.removeChildByName(self.bg, "normal")
				self.bg.removeChildByName(self.bg, "mon")
				self:clear()

				self.btnBg.normal = display.newSprite(res.getframe2("pic/console/attack/attack-normal.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("normal")
			end
		end
	elseif (event.name == "ended" or event.name == "cancelled") and g_data.setting.base.slideLock then
		if self.isMoved then
			if value < number2 then
				mon(self)
			elseif number < value then
				player(self)
			elseif value <= number and number2 <= value then
				attack()
			end
		else
			attack()
		end

		self.isMon = false
		self.isPlayer = false
		self.isNormal = false
		self.isMoved = false

		self.bg.removeChildByName(self.bg, "player")
		self.bg.removeChildByName(self.bg, "normal")
		self.bg.removeChildByName(self.bg, "mon")
		self:clear()

		self.btnBg.normal = display.newSprite(res.getframe2("pic/console/attack/attack-normal.png"), self.getw(self) / 2, self.geth(self) / 2, cc.size(150, 150)):add2(self.bg):setName("normal")
	end

	return true
end

return attackBtns
