local current = ...
local btnEx = import("..btnEx")
local hp = class("widget_hp", function ()
	return display.newNode()
end)

table.merge(hp, {
	config,
	data,
	mpPercent = 0,
	hpPercent = 0
})

function hp:ctor(config, data)
	self:size(120, 120):anchor(0.5, 0.5):pos(data.x, data.y)

	local hpbg = res.get2("pic/console/hp/hpbg.png"):anchor(0.5, 1):pos(self:getw() / 2, self:geth() + 14):addto(self)
	self.hpNull = res.get2("pic/console/hp/hp4.png"):anchor(0, 0):pos(70, 36):addto(hpbg)
	self.hpSpr = res.get2("pic/console/hp/hp3.png"):anchor(0, 0):pos(70, 36):addto(hpbg)
	self.mpSpr = res.get2("pic/console/hp/hp2.png"):anchor(0, 0):pos(70, 36):addto(hpbg):hide()
	local hpvaluebg = res.get2("pic/console/hp/hpValueBg.png"):pos(hpbg:getw() / 2, 8):add2(hpbg)
	self.hplabel = an.newLabel("0/0", 14, 1):anchor(0.5, 0.5):pos(37, hpvaluebg:geth() / 2 + 1):add2(hpvaluebg)
	self.mplabel = an.newLabel("0/0", 14, 1):anchor(0.5, 0.5):pos(108, hpvaluebg:geth() / 2 + 1):add2(hpvaluebg)

	display.newNode():size(self:getContentSize()):pos(self:centerPos()):anchor(0.5, 0.5):add2(self):enableClick(function ()
		btnEx.new()
	end):setName("diyhp")
end

function hp:update(dt)
	local ability = g_data.player.ability

	if not self.isDoublePost and (g_data.player.job == 0 and ability:get("level") >= 28 or g_data.player.job == 1 and ability:get("level") >= 7 or g_data.player.job == 2 and ability:get("level") >= 7) then
		self.isDoublePost = true

		self.hpNull:removeSelf()

		self.hpNull = nil

		self.hpSpr:setTex(res.gettex2("pic/console/hp/hp1.png"))
		self.mpSpr:show()
	end

	local hpPercent = ability:get("HP") / ability:get("maxHP")

	if hpPercent > 1 then
		hpPercent = 1
	end

	if hpPercent < 0 then
		hpPercent = 0
	end

	if hpPercent ~= self.hpPercent then
		self.hpPercent = hpPercent
		local size = self.hpSpr:getTexture():getContentSize()

		self.hpSpr:setTextureRect(cc.rect(0, size.height * (1 - hpPercent), size.width, size.height * hpPercent))
	end

	local mpPercent = ability:get("MP") / ability:get("maxMP")

	if mpPercent > 1 then
		mpPercent = 1
	end

	if mpPercent < 0 then
		mpPercent = 0
	end

	if mpPercent ~= self.mpPercent then
		self.mpPercent = mpPercent
		local size = self.mpSpr:getTexture():getContentSize()

		self.mpSpr:setTextureRect(cc.rect(0, size.height * (1 - mpPercent), size.width, size.height * mpPercent))
	end

	self.hplabel:setString(ability:get("HP") .. "/" .. ability:get("maxHP"))
	self.mplabel:setString(ability:get("MP") .. "/" .. ability:get("maxMP"))
end

function hp:setEquipLockVisible(visible)
	self.security:setVisible(visible)
end

return hp
