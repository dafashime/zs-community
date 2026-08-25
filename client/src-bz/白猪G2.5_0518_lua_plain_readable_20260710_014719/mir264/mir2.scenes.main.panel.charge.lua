local common = import("mir2.scenes.main.common.common")
local charge = class("charge", function()
	return display.newNode()
end)

table.merge(charge, {
	lqhandler,
	chargedata,
	czconfig,
	u
})

local text = "pic/panels/charge/"
local text2 = "charge"
local value
local items = {}

function geta()
	return "MT"
end

function encodeURI(text3)
	text3 = string.gsub(text3, "([^%w%.%- ])", function(value2)
		return string.format("%%%02X", string.byte(value2))
	end)

	return string.gsub(text3, " ", "+")
end

function charge:ctor()
	self._supportMove = true
	self.chargedata = def.role.getConfig(text2)
	self.czconfig = {}

	if g_data.login.localLastSer then
		self.czconfig.czcheck = g_data.login.localLastSer.czcheck
		self.czconfig.czsvrcmcode = g_data.login.localLastSer.czsvrcmcode
		self.czconfig.chargeurl = g_data.login.localLastSer.chargeurl
		self.czconfig.czsvr = g_data.login.localLastSer.czsvr
	end

	self:getYB()

	local text3 = "lOSF"
	local value_2 = res.get2("pic/common/black_2.png"):addTo(self):anchor(0, 0)

	self:size(value_2:getContentSize()):anchor(0.5, 0.5):center()
	res.get2(text .. "cz.png"):addTo(value_2):pos(value_2:getw() / 2, value_2:geth() - 12):anchor(0.5, 1)

	local text4 = "9LHL"

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:stopLQHandler()
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(value_2):pos(value_2:getw() - 9, value_2:geth() - 8):anchor(1, 1)
	res.get2(text .. "banner.png"):addTo(value_2):pos(8, value_2:geth() - 132):anchor(0, 0)

	local a = geta()
	local text5 = "LIP="

	function xx()
		local text3 = "AxNz"
		local text4 = "L"

		text5 = "E", "P"

		return text3
	end

	local value2 = self.chargedata.info
	local number = 5
	local value3
	local value4 = xx()
	local number2 = 5
	local value5 = a .. value4 .. text5 .. "="

	function getu()
		return def.role.checkbase(value5)
	end

	self.u = getu()

	for index, item in ipairs(value2) do
		if index > 8 then
			break
		end

		local text6 = "item" .. index
		local value6 = index % 5
		local x = 85

		if value3 and value6 > 0 then
			x = number2 + value3:getw() + number
		end

		number2 = x

		local y = 240

		if index > 4 then
			y = 85
		end

		local value_22 = res.get2(text .. "itembg.png"):anchor(0, 1)

		value_22.add2(value_22, value_2):anchor(0.5, 0.5):pos(x, y)

		value3 = value_22

		res.get2(text .. "item.png"):pos(value_22:getw() / 2, value_22:geth() - 25):add2(value_22)

		local number3 = 20

		if #item.FName > 6 then
			number3 = 16
		end

		an.newLabel(item.FName, number3, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):add2(value_22):pos(value_22:getw() / 2, value_22:geth() - 55)
		an.newLabel(item.FDescription, 16, 0, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):add2(value_22):pos(value_22:getw() / 2, value_22:geth() - 80)

		local text7 = "￥" .. item.FPrice

		if item.Custom then
			text7 = item.FPrice
		end

		local number4 = 20
		local text8 = "btnCharge.png"
		local value7 = text .. text8

		an.newBtn(res.gettex2(value7), function()
			sound.playSound("103")

			if item.Custom then
				self:customMoney(item)
			else
				self:doCharge(item.FPrice)
			end
		end, {
			pressBig = true,
			pressImage = res.gettex2(value7),
			label = {
				text7,
				number4,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}):add2(value_22):anchor(0.5, 0.5):pos(value_22:getw() / 2, 30):setTag(index)
	end
end

function charge:doCharge(value3)
	if self.czconfig.chargeurl then
		local value2 = self.u
		local text3 = ""

		if main_scene.ground.map and main_scene.ground.map.player then
			text3 = main_scene.ground.map.player.info.name.texts[1]
		end

		if self.czconfig.chargeurl:find(value2) ~= nil then
			local msgbox = an.newMsgbox("", function(value2)
				return
			end, {
				disableScroll = true,
				btnTexts = {
					"知道了"
				}
			})
			local text4 = "正在前往充值平台充值"
			local size = cc.LabelTTF:create(text4, "", 20, cc.size(320, 0), 1)

			size.anchor(size, 0.5, 1)
			size.setPosition(size, msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 + 40)
			msgbox.bg:addChild(size)
			an.newLabel("充值后自动到账，如果无法自动到账，请找[NPC]领取", 16, 1, {
				color = cc.c3b(162, 78, 54)
			}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 - 18)
			device.openURL(self.czconfig.chargeurl .. "&ex=" .. encodeURI(text3) .. "&money=" .. value3)
		end
	end
end

function charge:stopLQHandler()
	if self.lqhandler then
		def.role.stopRepeater(self.lqhandler)
	end
end

function charge:getYB(value2)
	self:stopLQHandler()

	local count = 0
	local count2 = 1

	self.lqhandler = def.role.createRepeater(function()
		if not main_scene then
			return
		end

		count = count + 1

		if value2 and count > value2 then
			self:stopLQHandler()
		end

		local value2 = self.czconfig.czcheck

		if value2 then
			local text3 = ""

			if main_scene.ground.map and main_scene.ground.map.player then
				text3 = main_scene.ground.map.player.info.name.texts[1]
			end

			local hTTPRequest = network.createHTTPRequest(function(value2)
				if value2.name ~= "completed" then
					return
				end

				local value3 = value2.request

				if value3:getResponseStatusCode() ~= 200 then
					return
				end

				local jsonText = value3:getResponseData()

				if jsonText then
					local data = json.decode(jsonText)

					if data and data.value and data.value == "1" then
						local value4 = data.money

						if count2 <= 3 then
							common.addMsg("正在自动领取充值[数量：" .. value4 .. "]", 255, 253, true)
							def.role.sendCM("@cz")

							count2 = count2 + 1
						end
					end
				end
			end, value2, "POST")
			local value3 = self.czconfig.czsvr

			if value3 then
				hTTPRequest:setPOSTData("e" .. "x" .. "=" .. encodeURI(text3) .. "&svr=" .. value3)
			else
				hTTPRequest:setPOSTData("e" .. "x" .. "=" .. encodeURI(text3))
			end

			hTTPRequest:start()
		else
			common.addMsg("充值成功后请找[充值NPC]手动领取。", 255, 253, true)
			self:stopLQHandler()
		end
	end, 2)
end

function charge:customMoney(customTextOwner)
	local msgbox
	local value2 = customTextOwner.CustomText or "你要充多少？"

	msgbox = an.newMsgbox(value2, function()
		if msgbox.numInput:getString() == "" then
			return
		end

		local string = msgbox.numInput:getString()
		local number = tonumber(string)

		if number then
			if number < 1 then
				common.addMsg("充值金额不得低于1元。", 255, 253, true)
			else
				self:doCharge(string)
			end
		else
			common.addMsg("输入的充值数值格式不对。", 255, 253, true)
		end
	end, {
		disableScroll = true
	})
	msgbox.numInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 14, {
		checkCLen = true,
		label = {
			"",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		}
	}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
end

return charge
