local security = class("security", function()
	return display.newNode()
end)

table.merge(security, {})

function security:resetPanelPosition(type)
	if type == "center" then
		self:anchor(0.5, 0.5):pos(display.width / 2, display.height / 2)
	end

	return self
end

function security:ctor(params)
	self._supportMove = true
	self.tag = params.tag

	local bg = res.get2("pic/panels/equip/validate.png"):addTo(self):anchor(0, 0)

	self:size(cc.size(bg:getContentSize().width, bg:getContentSize().height)):resetPanelPosition("center")

	self.edit = an.newInput(60, 122, 235, 38, 5, {
		label = {
			"",
			20,
			1
		}
	}):addTo(self):anchor(0, 0.5)

	local str = "请依次输入密保的第 "
	local bits = utf8strs(g_data.security.equipBit .. "")

	for i = 1, #bits do
		str = str .. bits[i] .. (i == #bits and "" or ",")
	end

	str = str .. " 位"

	an.newLabel(str, 21, 1, {
		color = def.colors.labelYellow
	}):addTo(self):pos(bg:getw() / 2, 170):anchor(0.5, 0.5)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(self):pos(self:getw() - 6, self:geth() - 3):anchor(1, 1)
	an.newBtn(res.gettex2("pic/common/btn30.png"), function()
		sound.playSound("103")
		self:submit()
	end, {
		pressImage = res.gettex2("pic/common/btn31.png"),
		label = {
			"确定",
			20,
			1,
			{
				color = def.colors.btn30
			}
		}
	}):addTo(self):pos(self:getw() / 2 - 20, 36):anchor(1, 0.5)
	an.newBtn(res.gettex2("pic/common/btn30.png"), function()
		sound.playSound("103")
		self.edit:setString("")
	end, {
		pressImage = res.gettex2("pic/common/btn31.png"),
		label = {
			"清除",
			20,
			1,
			{
				color = def.colors.btn30
			}
		}
	}):addTo(self):pos(self:getw() / 2 + 20, 36):anchor(0, 0.5)
end

function security:submit()
	local str = self.edit:getString()

	if tonumber(str) and string.len(str) == 5 then
		self:hidePanel()
		net.send({
			CM_TRY_UNLOCK_EQUIP,
			recog = tonumber(str),
			param = self.tag
		}, {
			str
		})
	else
		an.newMsgbox("[失败] 输入密保格式有误，请重新输入。", function()
			self.edit:setString("")
		end)
	end
end

return security
