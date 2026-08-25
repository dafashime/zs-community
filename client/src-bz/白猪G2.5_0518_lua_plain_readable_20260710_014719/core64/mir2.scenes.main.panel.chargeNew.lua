local common = import("..common.common")
local chargeNew = class("chargeNew", function()
	return display.newNode()
end)

table.merge(chargeNew, {})

local function callback(text)
	text = string.gsub(text, "([^%w%.%- ])", function(value)
		return string.format("%%%02X", string.byte(value))
	end)

	return string.gsub(text, " ", "+")
end

function chargeNew.ctor(self)
	self._supportMove = true

	local value_2 = res.get2("pic/common/black_2.png"):addTo(self):anchor(0, 0)

	self:size(value_2:getContentSize()):anchor(0.5, 0.5):center()
	res.get2("pic/panels/charge1/title.png"):addTo(value_2):pos(value_2:getw() / 2, value_2:geth() - 14):anchor(0.5, 1):scale(0.8)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:stopLQHandler()
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(value_2):pos(value_2:getw() - 9, value_2:geth() - 8):anchor(1, 1)

	self.czconfig = {}

	if g_data.login.localLastSer then
		local function callback2()
			local value

			local function callback3(self2)
				local jsonText = io.readfile(self2)

				return (json.decode(jsonText))
			end

			local value2 = device.writablePath .. "version.manifest"

			if io.exists(value2) then
				local serverUrlOwner = callback3(value2)

				if serverUrlOwner then
					value = serverUrlOwner.serverUrl
				end
			end

			return value
		end

		if def.openAutoCharge then
			local value = callback2()

			if value then
				self.czconfig.czcheck = value .. "pay/mirpaycall.php"
			end
		end

		self.czconfig.chargeurl = g_data.login.localLastSer.chargeurl or "https://by.1234500000.com/cz/10YnRN?gid=16732"
		self.czconfig.czsvr = g_data.login.localLastSer.czsvr or 1
	end

	self:load()
end

function chargeNew.onCleanup(self)
	self:stopLQHandler()
end

function chargeNew.stopLQHandler(self)
	if def.role.timer.__charge__ then
		def.role.stopRepeater(def.role.timer.__charge__)
	end
end

function chargeNew.getYB(self, value)
	if def.openAutoCharge then
		self:stopLQHandler()

		local count = 0

		def.role.timer.__charge__ = def.role.createRepeater(function()
			if not main_scene then
				def.role.stopRepeater(def.role.timer.__charge__)

				return
			end

			if not main_scene.ui.panels.chargeNew then
				def.role.stopRepeater(def.role.timer.__charge__)

				return
			end

			count = count + 1

			if value and count > value then
				self:stopLQHandler()
			end

			local value2 = self.czconfig.czcheck

			if value2 then
				local text = ""

				if main_scene.ground.map and main_scene.ground.map.player then
					text = main_scene.ground.map.player.info.name.texts[1]
				end

				local hTTPRequest = network.createHTTPRequest(function(value3)
					if value3.name ~= "completed" then
						return
					end

					local value22 = value3.request

					if value22:getResponseStatusCode() ~= 200 then
						return
					end

					local jsonText = value22:getResponseData()

					if jsonText then
						local data = json.decode(jsonText)

						if data and data.value and data.value == "1" then
							local value32 = data.money

							common.addMsg("正在自动领取充值[数量：" .. value32 .. "]", 255, 253, true)
							def.role.sendCM("@getCharge")
							self:stopLQHandler()
						end
					end
				end, value2, "POST")
				local value22 = self.czconfig.czsvr or 1

				if value22 then
					hTTPRequest:setPOSTData("e" .. "x" .. "=" .. callback(text) .. "&svr=" .. value22)
				else
					hTTPRequest:setPOSTData("e" .. "x" .. "=" .. callback(text))
				end

				hTTPRequest:start()
			else
				self:stopLQHandler()
			end
		end, 1)
	end
end

function chargeNew.openWeb(self, data)
	device.openURL(data)
end

function chargeNew.openStudy(self, url)
	main_scene.ui:togglePanel("webView", {
		height = 550,
		title = "教程与说明",
		width = 700,
		url = url
	})
end

function chargeNew.load(self)
	if self.tag1Node then
		self.tag1Node:removeSelf()
	end

	self:getYB()

	self.tag1Node = display.newNode():addTo(self)

	if self.tag2Node then
		self.tag2Node:removeSelf()
	end

	self.tag2Node = display.newNode():addTo(self)
	self.curSubIdx = nil

	display.newScale9Sprite(res.getframe2("pic/scale/scale14.png")):addto(self.tag2Node):anchor(0, 0):pos(14, 14):size(self:getw() - 28, self:geth() - 60)
	an.newBtn(res.gettex2("pic/common/btn10.png"), function()
		local items = {
			"确定"
		}
		local value = def.chargeMemo or "支付仅支持极简支付平台，领取时\n将自动前往极简支付平台支付。\n支付成功后支持自动领取到账，\n如果未自动领取，请手动领取充值。"
		local items2 = {}
		local msgbox = an.newMsgbox("", function(value2)
			if items2[value2] then
				items2[value2]()
			end
		end, {
			disableScroll = true,
			hasCancel = false
		})
		local size = cc.LabelTTF:create(value, "", 20, cc.size(320, 0), 1)

		size.anchor(size, 0.5, 0.5)
		size.setPosition(size, msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5)
		msgbox.bg:addChild(size)
	end, {
		pressImage = res.gettex2("pic/common/btn11.png"),
		label = {
			(def.chargeTitle or "充值") .. "帮助",
			18,
			1,
			{
				color = def.colors.btn20
			}
		}
	}):add2(self.tag2Node):anchor(0, 0.5):pos(20, self:geth() - 72)
	an.newBtn(res.gettex2("pic/common/btn10.png"), function()
		if g_data.client:checkLastTime("charge", 3) then
			g_data.client:setLastTime("charge", true)
			main_scene.ui:fadeLabel("正在领取…")
			def.role.sendCM("@getCharge")
		else
			main_scene.ui:fadeLabel("领取中，请耐心等待")
		end
	end, {
		pressImage = res.gettex2("pic/common/btn11.png"),
		label = {
			"领取" .. (def.chargeTitle or "充值"),
			18,
			1,
			{
				color = def.colors.btn20
			}
		}
	}):add2(self.tag2Node):anchor(0, 0.5):pos(120, self:geth() - 72)
	an.newLabel(def.chargeTips or "若充值有问题，请点击充值帮助!", 20, 0):anchor(0.5, 0.5):add2(self.tag2Node):pos(self:getw() * 0.5 + 50, self:geth() - 72)

	local items = {}

	if def.chargeList then
		for _, chargeList in pairs(def.chargeList) do
			items[#items + 1] = chargeList
		end
	end

	local infoView = an.newScroll(12, 18, self:getw() - 28, self:geth() - 114):add2(self.tag2Node)

	self.infoView = infoView

	local number = 160

	if #items <= 0 then
		local size = infoView:getScrollSize()
		local text = "需对接极简支付功能，从特邀入口注册才可使用\n注册成功后请联系QQ：20628133 审核账号。"
		local label = an.newLabel(text, 20, 0):anchor(0.5, 1):add2(infoView):pos(size.width / 2, size.height * 0.718)

		an.newBtn(res.gettex2("pic/common/btn10.png"), function()
			local items2 = {
				"https:",
				"//shimo.im",
				"/docs/5b",
				"qndaPNxZizpLAy/"
			}

			self:openStudy(table.concat(items2))
		end, {
			pressImage = res.gettex2("pic/common/btn11.png"),
			label = {
				"对接教程",
				18,
				1,
				{
					color = def.colors.btn20
				}
			}
		}):add2(infoView):anchor(0.5, 1):pos(size.width / 2, 60)
	end

	infoView:setScrollSize(self:getw() - 28, math.max(self:geth() - 110, math.modf((#items - 1) / 4) * number))

	local text2 = "9LHL"
	local text3 = "LIP="
	local text4 = "lOSF"

	function geta()
		return "MT"
	end

	function xx()
		local text = "AxNz"
		local text22 = "L"

		text3 = "E", "P"

		return text
	end

	local value = xx()
	local a = geta() .. value .. text3 .. "="

	local function callback2()
		return def.role.checkbase(a)
	end

	local text5 = ""

	if main_scene.ground.map and main_scene.ground.map.player then
		text5 = main_scene.ground.map.player.info.name.texts[1]
	end

	table.sort(items, function(priceOwner, priceOwner2)
		return priceOwner.price < priceOwner2.price
	end)

	for index, item in ipairs(items) do
		local value_2 = res.get2("pic/panels/charge1/bg.png"):anchor(0, 1):pos((index - 1) % 4 * 152 + 5, infoView:getScrollSize().height - math.modf((index - 1) / 4) * number):add2(infoView)

		an.newLabel(item.name, 20, 0):anchor(0.5, 0.5):add2(value_2):pos(value_2:getw() * 0.5, value_2:geth() - 24)
		res.get2("pic/panels/charge1/line.png"):pos(value_2:getw() * 0.5, value_2:geth() - 40):add2(value_2):scaleX(0.6)
		res.get2("pic/panels/charge1/yb.png"):pos(value_2:getw() * 0.5 - 8, value_2:geth() * 0.5 + 8):add2(value_2)
		res.get2("pic/panels/charge1/yb.png"):pos(value_2:getw() * 0.5 + 8, value_2:geth() * 0.5 - 8):add2(value_2)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			local function callback3()
				local value2 = callback2()
				local value22 = item.price or 1
				local value3 = self.czconfig.chargeurl

				if value3 and value3:find(value2) ~= nil then
					if not ccexp.WebView then
						local msgbox = an.newMsgbox("", function(value4)
							if value4 == 1 then
								if g_data.client:checkLastTime("charge", 3) then
									g_data.client:setLastTime("charge", true)
									main_scene.ui:fadeLabel("正在领取…")
									def.role.sendCM("@getCharge")
								else
									main_scene.ui:fadeLabel("领取中，请耐心等待")
								end
							end
						end, {
							disableScroll = true,
							btnTexts = {
								"领取" .. (def.chargeTitle or "充值"),
								"关闭"
							}
						})
						local text = "请跳转到平台进行支付处理…"
						local size = cc.LabelTTF:create(text, "", 20, cc.size(320, 0), 1)

						size.anchor(size, 0.5, 1)
						size.setPosition(size, msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 + 40)
						msgbox.bg:addChild(size)
						an.newLabel("支付成功后，可以在界面中领取" .. (def.chargeTitle or "充值"), 16, 1, {
							color = cc.c3b(162, 78, 54)
						}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 - 18)
					end

					self:openWeb(value3 .. "&ex=" .. callback(text5) .. "&money=" .. value22)
				else
					local msgbox2 = an.newMsgbox("", function(value4)
						if value4 == 1 then
							self:openStudy("https://shimo.im/docs/5bqndaPNxZizpLAy/")
						end
					end, {
						disableScroll = true,
						btnTexts = {
							"对接教程",
							"关闭"
						}
					})
					local text22 = "需对接极简支付功能，从特邀入口注册才可使用\n注册成功后请联系QQ：20628133 审核账号。"
					local size2 = cc.LabelTTF:create(text22, "", 20, cc.size(320, 0), 1)

					size2.anchor(size2, 0.5, 0.5)
					size2.setPosition(size2, msgbox2.bg:getw() * 0.5, msgbox2.bg:geth() * 0.5)
					msgbox2.bg:addChild(size2)
				end
			end

			local msgbox = an.newMsgbox("", function(value2)
				if value2 == 1 then
					callback3()
				end
			end, {
				hasCancel = true
			})

			an.newLabel(item.name, 22, 1):add2(msgbox.bg):pos(280, 190):anchor(0.5, 0)
			an.newLabel((def.chargeTitle or "充值") .. "额度", 22, 1, {
				color = def.colors.cellTitle
			}):add2(msgbox.bg):pos(50, 190)
			res.get2("pic/panels/setting/line.png"):pos(msgbox.bg:getw() * 0.5, 175):add2(msgbox.bg):scaleX(0.6)
			an.newLabel(g_data.login:getSelectGroup():get("groupName"), 22, 1):add2(msgbox.bg):pos(280, 135):anchor(0.5, 0)
			an.newLabel("服务器", 22, 1, {
				color = def.colors.cellTitle
			}):add2(msgbox.bg):pos(50, 135)
			res.get2("pic/panels/setting/line.png"):pos(msgbox.bg:getw() * 0.5, 120):add2(msgbox.bg):scaleX(0.6)
			an.newLabel(text5, 22, 1):add2(msgbox.bg):pos(280, 80):anchor(0.5, 0)
			an.newLabel("角色", 22, 1, {
				color = def.colors.cellTitle
			}):add2(msgbox.bg):pos(50, 80)
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"￥ " .. item.price,
				22,
				1,
				{
					color = def.colors.btn20
				}
			}
		}):add2(value_2):anchor(0.5, 0.5):pos(value_2:getw() * 0.5, 30)
	end
end

return chargeNew
