local extendUI = require("mir2.scenes.main.common.extendUI")
local dynamicPanel = class("dynamicPanel", function()
	return display.newNode()
end)

table.merge(dynamicPanel, {
	mainbg,
	mainBgh,
	extUIParams = {}
})

dynamicPanel.timer = nil

function dynamicPanel:ctor(value)
	self.mainbg = nil
	self.mainBgh = nil
	self.extUIParams = {}
	self.cm_clientToServer = nil
	self._supportMove = true

	def.role.cancelAutoRun(dynamicPanel.timer)
	self:show(value)
end

function dynamicPanel:show(data)
	data = data or {}

	local value

	if data.json then
		local jdata = def.role.getConfig(data.file)

		g_data.jdata = jdata

		if jdata then
			value = jdata.panel
		end
	else
		value = string.split(data.body, "|")
	end

	local number = 5
	local enabled = false

	for _, item in ipairs(value) do
		local parts = string.split(item, ":")
		local value2 = parts[1]

		if value2 == "CM" then
			self.cm_clientToServer = parts[2]
		elseif value2 == "Bg" then
			local value3 = parts[2]
			local value4 = parts[3]
			local value5 = parts[4] or "center"
			local number2 = tonumber(parts[5]) or 0
			local value6 = parts[8] or "center"
			local number3 = 0.5
			local number4 = 0.5

			if value6 == "left" then
				number3 = 0
			elseif value6 == "topleft" then
				number3 = 0
				number4 = 1
			elseif value6 == "right" then
				number3 = 1
			end

			local number5 = tonumber(parts[6]) or display.cx
			local number6 = tonumber(parts[7]) or display.cy

			self.mainbg = _get2("pic/bzmir/diynpc/" .. value3 .. "/" .. value4 .. ".png")

			self:anchor(number3, number4):pos(number5, number6):size(cc.size(self.mainbg:getw(), self.mainbg:geth()))
			self:setNodeEventEnabled(true)
			self.mainbg:anchor(0, 0):pos(0, 0):add2(self)

			self.mainBgh = self.mainbg:geth()
			self.extUIParams = extendUI.init(self, "dypanel_ext", nil, value5, number2)
		elseif value2 == "DBg" then
			local value7 = parts[2]
			local value8 = parts[3]
			local number7 = tonumber(parts[4])
			local value9 = parts[5] or "center"
			local number8 = tonumber(parts[6]) or 0
			local value10 = parts[9] or "center"
			local number9 = 0.5
			local number10 = 0.5

			if value10 == "left" then
				number9 = 0
			elseif value10 == "topleft" then
				number9 = 0
				number10 = 1
			elseif value10 == "right" then
				number9 = 1
			end

			local number11 = tonumber(parts[7]) or display.cx
			local number12 = tonumber(parts[8]) or display.cy

			self.mainbg = display.newSprite(res.gettexforCUS(value7, value8))

			local number13 = tonumber(parts[10]) or self.mainbg:getw()
			local number14 = tonumber(parts[11]) or self.mainbg:geth()

			self:anchor(number9, number10):pos(number11, number12):size(cc.size(number13 * number7, number14 * number7))
			self:setNodeEventEnabled(true)
			self.mainbg:scale(number7):anchor(0, 0):pos(0, 0):add2(self)

			self.mainBgh = self:geth()
			self.extUIParams = extendUI.init(self, "dypanel_ext", nil, value9, number8)
		elseif value2 == "DExit" then
			local value11 = parts[2]
			local value12 = parts[3]
			local number15 = tonumber(parts[4])
			local value13 = parts[5]
			local number16 = tonumber(parts[6]) or self:getw() - 9
			local number17 = tonumber(parts[7]) or self:geth() - 8
			local number18 = 0.5
			local number19 = 0.5

			if self.extUIParams then
				if self.extUIParams.align == "left" then
					number18 = 0
				elseif self.extUIParams.align == "topleft" then
					number18 = 0
					number19 = 1
				elseif self.extUIParams.align == "right" then
					number18 = 1
				end

				if self.extUIParams.pointWith == 0 then
					number17 = self.mainBgh - number17
				end
			end

			an.newBtn(res.gettexforCUS(value11, value12), function()
				sound.playSound("103")
				self:hidePanel()
			end, {
				pressImage = res.gettexforCUS(value11, value13)
			}):anchor(number18, number19):pos(number16, number17):addto(self):scale(number15)
		elseif value2 == "Exit" then
			local value14 = parts[2]
			local value15 = parts[3]
			local value16 = parts[4]
			local number20 = tonumber(parts[5]) or self:getw() - 9
			local number21 = tonumber(parts[6]) or self:geth() - 8
			local number22 = 0.5
			local number23 = 0.5

			if self.extUIParams then
				if self.extUIParams.align == "left" then
					number22 = 0
				elseif self.extUIParams.align == "topleft" then
					number22 = 0
					number23 = 1
				elseif self.extUIParams.align == "right" then
					number22 = 1
				end

				if self.extUIParams.pointWith == 0 then
					number21 = self.mainBgh - number21
				end
			end

			an.newBtn(_gettex2("pic/bzmir/diynpc/" .. value14 .. "/" .. value15 .. ".png"), function()
				sound.playSound("103")
				self:hidePanel()
			end, {
				pressImage = _gettex2("pic/bzmir/diynpc/" .. value14 .. "/" .. value16 .. ".png")
			}):anchor(number22, number23):pos(number20, number21):addto(self.mainbg)
		elseif value2 == "Move" then
			local number24 = tonumber(parts[2])
			local number25 = tonumber(parts[3])
			local number26 = tonumber(parts[4]) or 0.2

			self:stopAllActions()
			self:moveTo(number26, number24, number25)
		elseif value2 == "AutoHide" then
			number = tonumber(parts[2])
			enabled = true
		else
			extendUI.load(item, self.extUIParams)
		end
	end

	if self.cm_clientToServer then
		def.role.call(self.cm_clientToServer)
	end

	main_scene.ui.panels.dynamicPanel = dynamicPanel

	if enabled then
		dynamicPanel.timer = def.role.autoRun(function()
			if main_scene.ui.panels.dynamicPanel then
				main_scene.ui.panels.dynamicPanel:hidePanel()
			end
		end, number)
	end
end

function dynamicPanel:refresh(data)
	local parts = string.split(data, "|")

	for _, item in ipairs(parts) do
		extendUI.load(item, self.extUIParams)
	end
end

return dynamicPanel
