local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local notice = class("notice", function()
	return display.newNode()
end)

table.merge(notice, {
	mainbg,
	mainBgh,
	extUIParams = {}
})

notice.timer = nil

function notice:ctor(value)
	self.mainbg = nil
	self.mainBgh = nil
	self.extUIParams = {}
	self.cm_clientToServer = nil
	self._supportMove = false

	def.role.cancelAutoRun(notice.timer)
	self:show(value)
end

function notice:show(data)
	local value

	if not data then
		return
	end

	if data.json and data.file then
		local config = def.role.getConfig(data.file)

		if config then
			value = config.panel
		end
	else
		if not data.body then
			return
		end

		value = string.split(data.body, "|")
	end

	if not value then
		return
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

			self.mainbg = res.get2("pic/bzmir/diynpc/" .. value3 .. "/" .. value4 .. ".png")

			self.anchor(self, 0.5, 0.5):pos(display.width / 2, display.height / 2):size(cc.size(self.mainbg:getw(), self.mainbg:geth()))
			self.setNodeEventEnabled(self, true)

			local number3 = tonumber(parts[6]) or self:getw() / 2
			local number4 = tonumber(parts[7]) or self:geth() / 2

			self.mainbg:anchor(0.5, 0.5):pos(number3, number4):add2(self)

			self.mainBgh = self.mainbg:geth()
			self.extUIParams = extendUI.init(self.mainbg, "ntcpanel_ext", nil, value5, number2)
		elseif value2 == "DBg" then
			local value6 = parts[2]
			local value7 = parts[3]
			local number5 = tonumber(parts[4])
			local value8 = parts[5] or "center"
			local number6 = tonumber(parts[6]) or 0
			local value9 = parts[9] or "center"
			local number7 = 0.5
			local number8 = 0.5

			if value9 == "left" then
				number7 = 0
			elseif value9 == "topleft" then
				number7 = 0
				number8 = 1
			elseif value9 == "right" then
				number7 = 1
			end

			local number9 = tonumber(parts[7]) or display.cx
			local number10 = tonumber(parts[8]) or display.cy

			self.mainbg = display.newSprite(res.gettex2(value7 .. ".png", "data/" .. value6))

			self:anchor(number7, number8):pos(number9, number10):size(cc.size(self.mainbg:getw() * number5, self.mainbg:geth() * number5))
			self:setNodeEventEnabled(true)
			self.mainbg:scale(number5):anchor(0, 0):pos(0, 0):add2(self)

			self.mainBgh = self:geth()
			self.extUIParams = extendUI.init(self, "ntcpanel_ext", nil, value8, number6)
		elseif value2 == "DExit" then
			local value10 = parts[2]
			local value11 = parts[3]
			local number11 = tonumber(parts[4])
			local value12 = parts[5]
			local number12 = tonumber(parts[6]) or self:getw() - 9
			local number13 = tonumber(parts[7]) or self:geth() - 8
			local number14 = 0.5
			local number15 = 0.5

			if self.extUIParams then
				if self.extUIParams.align == "left" then
					number14 = 0
				elseif self.extUIParams.align == "topleft" then
					number14 = 0
					number15 = 1
				elseif self.extUIParams.align == "right" then
					number14 = 1
				end

				if self.extUIParams.pointWith == 0 then
					number13 = self.mainBgh - number13
				end
			end

			an.newBtn(res.gettex2(value11 .. ".png", "data/" .. value10), function()
				sound.playSound("103")
				self:hidePanel()
			end, {
				pressImage = res.gettex2(value12 .. ".png", "data/" .. value10)
			}):anchor(number14, number15):pos(number12, number13):addto(self.mainbg):scale(number11)
		elseif value2 == "Exit" then
			local value13 = parts[2]
			local value14 = parts[3]
			local value15 = parts[4]
			local number16 = tonumber(parts[5]) or self:getw() - 9
			local number17 = tonumber(parts[6]) or self:geth() - 8
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

			an.newBtn(res.gettex2("pic/bzmir/diynpc/" .. value13 .. "/" .. value14 .. ".png"), function()
				sound.playSound("103")
				self:hidePanel()
			end, {
				pressImage = res.gettex2("pic/bzmir/diynpc/" .. value13 .. "/" .. value15 .. ".png")
			}):anchor(number18, number19):pos(number16, number17):addto(self.mainbg)
		elseif value2 == "Move" then
			local number20 = tonumber(parts[2])
			local number21 = tonumber(parts[3])
			local number22 = tonumber(parts[4]) or 0.2

			self:stopAllActions()
			self:moveTo(number22, number20, number21)
		elseif value2 == "AutoHide" then
			number = tonumber(parts[2])
			enabled = true
		else
			extendUI.load(item, self.extUIParams)
		end
	end

	main_scene.ui.panels.notice = notice

	if enabled then
		if notice.timer then
			def.role.cancelAutoRun(notice.timer)
		end

		notice.timer = def.role.autoRun(function()
			if main_scene and main_scene.ui and main_scene.ui.panels.notice then
				main_scene.ui.panels.notice:hidePanel()
			end
		end, number)
	end
end

function notice:refresh(data)
	if not data then
		return
	end

	local parts = string.split(data, "|")

	for _, item in ipairs(parts) do
		extendUI.load(item, self.extUIParams)
	end
end

return notice
