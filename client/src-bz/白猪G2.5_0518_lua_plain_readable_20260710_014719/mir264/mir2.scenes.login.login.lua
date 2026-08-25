local scale = 1.8
local login = class("login", function()
	return display.newNode()
end)
local loginer = import(".loginer")

table.merge(login, {
	submitting = false
})

function login:ctor(scene, ip, port, loginEndCallback)
	self.scene = scene

	self.setNodeEventEnabled(self, true)

	local info = game.loadDeviceInfo()

	self.m = game.initLoginer(loginer, info.uuid or cache.check_uuid("" .. math.random()))

	self.m:selectServer(ip, port)
	self.m:setEvtListener(self)

	self.loginEndCallback = loginEndCallback
	self.agreement = nil
	self.acInput = nil
	self.pwInput = nil
end

local function cleanup()
	if not io.exists(device.writablePath .. "acccache") then
		ycFunction:mkdir(device.writablePath .. "acccache")
	end

	local value = io.readfile(device.writablePath .. "acccache/ac")

	if value then
		return json.decode(crypto.decryptXXTEA(value, cache.safeKey))
	end
end

function login:onEnter()
	local scene = self.scene

	res.getui(1, 60):addto(self):center():scale(scale)

	local function submit()
		sound.playSound("104")

		if self.submitting then
			return
		end

		if string.len(self.acInput:getText()) < 4 then
			an.newMsgbox("帐号格式不对", nil, {
				center = true
			})
		elseif string.len(self.pwInput:getText()) < 4 then
			an.newMsgbox("密码格式不对", nil, {
				center = true
			})
		elseif def.agreement and def.agreement.open and not self.agreement.isSelect() then
			an.newMsgbox("请阅读并勾选服务协议", nil, {
				center = true
			})
		else
			self.submitting = true
			g_data.login.ac = self.acInput:getText()
			g_data.login.pw = self.pwInput:getText()
			self.loginNode = display.newNode():size(display.width, display.height):add2(display.getRunningScene(), 777)

			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale26.png")):addto(self.loginNode):anchor(0.5, 0.5):size(200, 60):pos(display.cx, display.cy)

			an.newLabel("登陆游戏中…", 20, nil, {
				color = display.COLOR_WHITE
			}):addTo(background):anchor(0.5, 0.5):pos(background:getw() / 2, background:geth() / 2)

			self.logining = def.role.createRepeater(function()
				if isAoth then
					self.m:login(g_data.login.ac, g_data.login.pw)

					self._isLoginProc = true

					self.loginNode:removeSelf()
					def.role.stopRepeater(self.logining)

					self.submitting = false
				end
			end, 0.1)
		end
	end

	self.acInput = an.newInput(display.cx + scale * 20, display.cy + scale * 32, scale * 135, scale * 36, 32, {
		label = {
			"",
			scale * 16
		},
		return_call = function()
			self.pwInput:startInput()
		end
	}):addTo(self)
	self.pwInput = an.newInput(display.cx + scale * 20, display.cy - scale * 1, scale * 135, scale * 36, 16, {
		password = true,
		label = {
			"",
			scale * 16
		},
		return_call = submit
	}):addTo(self)

	local account = cleanup()

	if account then
		self.acInput.setText(self.acInput, account.ac)
		self.pwInput.setText(self.pwInput, account.pw)
	end

	local function exitCallback()
		self.accPanel:removeSelf()
	end

	local default = self:readDefaultAgent()

	an.newBtn(res.getuitex(1, 61), function()
		local submitting = def.agent and def.agent.agentName or "代理人"
		local lbs = {
			"用户名",
			"密码",
			"安全码",
			submitting
		}

		sound.playSound("104")

		local items = {
			{
				text = "用户名"
			},
			{
				text = "密码",
				password = true
			},
			{
				text = "安全码"
			}
		}

		if def.agent and def.agent.openGameAgent then
			items = {
				{
					text = "用户名"
				},
				{
					text = "密码",
					password = true
				},
				{
					text = "安全码"
				},
				{
					text = submitting,
					default = default
				}
			}
		end

		self:showPanel("注册", items, {
			{
				text = "确定",
				cb = function(inputs)
					for k, v in pairs(inputs) do
						if k == 4 then
							if v == submitting or v == "" then
								if def.agent and def.agent.agentNecessary then
									an.newMsgbox(lbs[k] .. "不能为空", nil, {
										center = true
									})

									return
								end
							elseif string.len(v) < 6 then
								an.newMsgbox(lbs[k] .. "的长度不应小于6", nil, {
									center = true
								})

								return
							elseif string.find(v, "[^%w!@#$]") then
								an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function(value)
									return
								end, {
									center = true
								})

								return
							end
						elseif string.len(v) < 6 then
							an.newMsgbox(lbs[k] .. "的长度不应小于6", nil, {
								center = true
							})

							return
						elseif string.find(v, "[^%w!@#$]") then
							an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function(value)
								return
							end, {
								center = true
							})

							return
						end
					end

					if def.showUserAgreement then
						self.tipNode = display.newNode():size(display.width, display.height):add2(display.getRunningScene(), 777)

						local background = display.newScale9Sprite(res.getframe2("pic/scale/scale26.png")):addto(self.tipNode):anchor(0.5, 0.5):size(200, 60):pos(display.cx, display.cy)

						an.newLabel("协议读取中", 20, nil, {
							color = display.COLOR_WHITE
						}):addTo(background):anchor(0.5, 0.5):pos(background:getw() / 2, background:geth() / 2)
						def.role.autoRun(function()
							self:showAgreement2(inputs)
						end, 0.1)
					else
						self.m:register(unpack(inputs))
					end
				end
			},
			{
				text = "绑定游客账号",
				cb = function()
					self.accPanel:removeSelf()
					self:showPanel("绑定游客账号", {
						{
							text = "用户名"
						},
						{
							text = "密码",
							password = true
						},
						{
							text = "安全码"
						}
					}, {
						{
							text = "确定",
							cb = function(inputs)
								for k, v in pairs(inputs) do
									if string.len(v) < 6 then
										an.newMsgbox(lbs[k] .. "的长度不应小于6", nil, {
											center = true
										})

										return
									elseif string.find(v, "[^%w!@#$]") then
										an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function(value)
											return
										end, {
											center = true
										})

										return
									end
								end

								self.m:bind(unpack(inputs))
							end
						}
					}, exitCallback)
				end
			}
		}, exitCallback)
	end, {
		pressShow = true
	}):pos(display.cx - scale * 73, display.cy - scale * 96):addto(self):scale(scale)
	an.newBtn(res.getuitex(1, 62), submit, {
		pressShow = true
	}):pos(display.cx + scale * 59, display.cy - scale * 53):addto(self):scale(scale)
	an.newBtn(res.getuitex(1, 53), function(event)
		local items = {
			"用户名",
			"密码",
			"安全码"
		}

		sound.playSound("104")
		self:showPanel("修改密码", {
			{
				text = "用户名"
			},
			{
				text = "新密码",
				password = true
			},
			{
				text = "安全码"
			}
		}, {
			{
				text = "确定",
				cb = function(inputs)
					for k, v in pairs(inputs) do
						if string.len(v) < 6 then
							an.newMsgbox(items[k] .. "的长度不应小于6", nil, {
								center = true
							})

							return
						elseif string.find(v, "[^%w!@#$]") then
							an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function(value)
								return
							end, {
								center = true
							})

							return
						end
					end

					self.m:chgPsw(unpack(inputs))
				end
			}
		}, exitCallback)
	end, {
		pressShow = true
	}):pos(display.cx + scale * 46, display.cy - scale * 96):addto(self):scale(scale)
	an.newBtn(res.getuitex(1, 64), function(event)
		sound.playSound("103")
		os.exit(1)
	end, {
		pressShow = true,
		size = {
			36,
			36
		}
	}):pos(display.cx + scale * 112, display.cy + scale * 86):addto(self):scale(scale)

	if def.agreement and def.agreement.open then
		local cache = self:getCache("isdefaultAgree") or {
			defaultAgree = def.agreement.defaultAgree or false
		}

		self.agreement = self.createToggle(self, function(agreement)
			self:saveCache("isdefaultAgree", {
				defaultAgree = agreement
			})
		end, cache.defaultAgree, {
			def.agreement.title or "同意相关《服务协议》",
			20,
			1,
			{
				color = cc.c3b(220, 210, 190)
			}
		}, nil, nil):anchor(0, 0.5):pos(display.cx - 222, display.cy - 110):add2(self)
	end
end

function login:saveCache(path, data)
	local value = device.writablePath .. "cache/" .. def.ccy.md(g_data.login.localLastSer.zonename .. path) .. "/"

	if not io.exists(value) then
		ycFunction:mkdir(value)
	end

	local text = string.format("%s/%s", value, def.ccy.md(g_data.login.localLastSer.zonename .. path))
	local value2 = crypto.encodeBase64(json.encode(data))

	if value2 then
		io.writefile(text, value2)
	end
end

function login:getCache(value2)
	local value = device.writablePath .. "cache/" .. def.ccy.md(g_data.login.localLastSer.zonename .. value2) .. "/"

	if not io.exists(value) then
		ycFunction:mkdir(value)
	end

	local text = string.format("%s/%s", value, def.ccy.md(g_data.login.localLastSer.zonename .. value2))

	if io.exists(text) then
		local value3 = io.readfile(text)

		if value3 then
			return json.decode(crypto.decodeBase64(value3))
		end
	end

	return nil
end

function login:createToggle(callback, value3, label, temp, value4)
	local value
	local value2

	temp = temp or {}

	local layer = display.newNode()
	local filteredSprite = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(layer)

	filteredSprite.setName(filteredSprite, "selsp")
	layer.setContentSize(layer, filteredSprite.getContentSize(filteredSprite))

	function layer:setIsSelect(isSelected)
		layer.isSelected = isSelected

		if isSelected then
			layer:select()
		else
			layer:unselect()
		end
	end

	function layer:isSelect()
		return layer.isSelected
	end

	function layer:select()
		layer.isSelected = true

		if layer.temp then
			layer.temp:removeSelf()

			layer.temp = nil
		end

		filteredSprite:setTex(res.gettex2(temp.selectImg or "pic/common/toggle02.png"))
	end

	function layer:select_temp()
		if layer.temp then
			return
		end

		layer.temp = display.newFilteredSprite(res.gettex2(temp.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(layer)

		layer.temp:setOpacity(80)
	end

	function layer:unselect()
		if layer.temp then
			layer.temp:removeSelf()

			layer.temp = nil
		end

		layer.isSelected = false

		filteredSprite:setTex(res.gettex2("pic/common/toggle00.png"))
	end

	if value3 ~= nil then
		layer.setIsSelect(layer, value3)
	end

	filteredSprite.setTouchEnabled(filteredSprite, true)
	filteredSprite.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			layer.offsetBeginY = offsetBeginY.y
			layer.offsetBeginX = offsetBeginY.x

			return true
		elseif offsetBeginY.name == "ended" then
			local value = offsetBeginY.y - layer.offsetBeginY
			local value2 = offsetBeginY.x - layer.offsetBeginX

			if math.abs(value) <= 20 and math.abs(value2) <= 20 then
				layer:setIsSelect(not layer.isSelected)
				callback(layer.isSelected)
			end
		end
	end)
	filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

	if label then
		layer.label = an.newLabel(unpack(label)):add2(layer):pos(layer.getw(layer) + 7, layer.geth(layer) / 2):anchor(0, 0.5)

		layer.label:setTouchEnabled(true)
		layer.label:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x)
			if x.name == "began" then
				sound.playSound("105")

				layer.label.disable = false

				layer.label:scale(1.1):setColor(cc.c3b(255, 0, 0))

				layer.label.startPos = cc.p(x.x, x.y)

				return true
			elseif x.name == "ended" then
				layer.label:scale(1):setColor(cc.c3b(220, 210, 190))
				self:showAgreement()
			elseif cc.pGetDistance(lb.startPos, x) > 35 then
				layer.label:scale(1):setColor(cc.c3b(220, 210, 190))

				layer.label.disable = true
			end
		end)

		function layer:getw()
			return layer.label:getw() + 40
		end
	end

	layer.btn = layer

	function layer:gray()
		local filter = res.getFilter("gray")

		filteredSprite:setFilter(filter)
		layer:setTouchEnabled(false)

		if layer.temp then
			layer.temp:setFilter(filter)
		end
	end

	function layer:disGray()
		filteredSprite:clearFilter()
		layer:setTouchEnabled(true)

		if layer.temp then
			layer.temp:clearFilter(f)
		end
	end

	function layer:setGray(gray)
		if gray then
			layer:gray()
		else
			layer:disGray()
		end

		return layer
	end

	return layer
end

function login:readAgreement()
	local value = device.writablePath .. "res/" .. def.agreement.agreementFile or "agreement.html"

	if io.exists(value) then
		return io.readfile(value)
	end

	return ""
end

function login:readDefaultAgent()
	local value = device.writablePath .. "res/agent.bin"

	if io.exists(value) then
		return io.readfile(value)
	end

	return ""
end

function login:showAgreement()
	local text = self:readAgreement()
	local node = display.newNode():size(display.width, display.height):addTo(self)
	local node2 = res.get2("pic/common/black_2.png"):addTo(node):pos(node.centerPos(node)):anchor(0.5, 0.5):scale(0.1)

	node2.runAction(node2, cc.ScaleTo:create(0.2, 1))
	node.setTouchEnabled(node, true)
	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function(x)
		if x.name == "ended" and not cc.rectContainsPoint(node2:getBoundingBox(), cc.p(x.x, x.y)) then
			node:removeSelf()
		end

		return true
	end)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		node:removeSelf()
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):addTo(node2):pos(node2.getw(node2) - 8, node2.geth(node2) - 8):anchor(1, 1)
	display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), 14, 14, cc.size(node2.getw(node2) - 28, node2.geth(node2) - 68)):addTo(node2):anchor(0, 0)

	local scroll = an.newScroll(25, 20, node2.getw(node2) - 50, node2.geth(node2) - 80):addTo(node2):anchor(0, 0)
	local label = an.newLabelM(node2.getw(node2) - 50, 20, 1, {
		manual = false
	}):addTo(scroll):pos(0, node2.geth(node2) - 80):anchor(0, 1):nextLine()
	local enabled = true

	local function print(text)
		local value = string.find(text, "/>")
		local text2 = string.trim(string.sub(text, 1, value + 1))
		local parts = string.split(text2, " ")
		local number = {}

		for _, item in ipairs(parts) do
			local parts2 = string.split(item, "=")

			if parts2[1] and parts2[2] then
				number[parts2[1]] = parts2[2]
			end
		end

		label:setFontSize(tonumber(number.size) or 20)

		local parts3 = string.split(number.urlcolor, "|")
		local number2 = cc.c3b(tonumber(parts3[1] or 255) or 255, tonumber(parts3[2] or 255), tonumber(parts3[3] or 255))
		local parts4 = string.split(number.textcolor, "|")
		local number3 = cc.c3b(tonumber(parts4[1] or 255) or 255, tonumber(parts4[2] or 255), tonumber(parts4[3] or 255))

		if number.urladdr then
			label:addLabel(number.urltext or number.urladdr, number2, nil, nil, function()
				device.openURL(number.urladdr)
			end)
		end

		text = string.sub(text, value + 2)

		local value2 = string.find(text, "<t")
		local value3 = string.find(text, "/>")

		if value2 and value3 then
			local text3 = string.sub(text, value2 + 3, value3 - 1)
			local text4 = string.gsub(text3, "\\n", "\n")

			label:addLabel(text4, number3)
		end
	end

	while true do
		local value = string.find(text, "<b")
		local value2 = string.find(text, "</b>")

		if value and value2 then
			local code = string.sub(text, value + 3, value2 - 1)

			print(code)

			if string.len(text) <= value2 + 4 then
				break
			else
				text = string.sub(text, value2 + 4)
			end
		end
	end
end

function login:showAgreement2(data)
	if not self.agreeNode then
		self.agreeNode = display.newNode():size(display.width, display.height):add2(display.getRunningScene(), 888):hide()
		self.agreeNode.noticebg = res.get2("pic/common/black_2.png"):addTo(self.agreeNode):pos(self.agreeNode.centerPos(self.agreeNode)):anchor(0.5, 0.5)

		an.newBtn(res.gettex2("pic/common/close10.png"), function()
			self.agreeNode:setVisible(false)
		end, {
			pressImage = res.gettex2("pic/common/close11.png")
		}):addTo(self.agreeNode.noticebg):pos(self.agreeNode.noticebg.getw(self.agreeNode.noticebg) - 8, self.agreeNode.noticebg.geth(self.agreeNode.noticebg) - 8):anchor(1, 1)
		display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), 14, 14, cc.size(self.agreeNode.noticebg.getw(self.agreeNode.noticebg) - 28, self.agreeNode.noticebg.geth(self.agreeNode.noticebg) - 68)):addTo(self.agreeNode.noticebg):anchor(0, 0)

		self.agreeNode.scroll = an.newScroll(25, 20, self.agreeNode.noticebg.getw(self.agreeNode.noticebg) - 50, self.agreeNode.noticebg.geth(self.agreeNode.noticebg) - 80):addTo(self.agreeNode.noticebg):anchor(0, 0)
		self.agreeNode.labelM = an.newLabelM(self.agreeNode.noticebg.getw(self.agreeNode.noticebg) - 85, 20, 1, {
			manual = false
		}):addTo(self.agreeNode.scroll):pos(20, self.agreeNode.noticebg.geth(self.agreeNode.noticebg) - 80):anchor(0, 1):nextLine()

		self.agreeNode.labelM:addLabel(argeementText)

		argeementText = ""
		argeementText = nil
		self.agreeBg = display.newScale9Sprite(res.getframe2("pic/scale/scale26.png")):addto(self.agreeNode.scroll):anchor(0.5, 0.5):size(400, 80):pos(self.agreeNode.scroll:getw() / 2, 300 - self.agreeNode.labelM:geth())

		an.newBtn(res.gettex2("pic/common/btn201.png"), function()
			if data then
				self.m:register(unpack(data))
				self.agreeNode:setVisible(false)

				return
			end
		end, {
			pressBig = true,
			label = {
				"I Read and Argee《用户协议》",
				20,
				2,
				display.COLOR_GREEN
			}
		}):add2(self.agreeBg):pos(self.agreeBg:getw() / 2, self.agreeBg:geth() / 2)
		an.newLabel("《用户服务协议》", 20, nil, {
			color = display.COLOR_WHITE
		}):addTo(self.agreeNode.noticebg):anchor(0.5, 0.5):pos(self.agreeNode.noticebg:getw() / 2, self.agreeNode.noticebg:geth() - 25)
	end

	self.tipNode:removeSelf()
	self.agreeNode:setVisible(true)
end

function login:onExit()
	self.m:destroy()
end

function login:onCetSvrEvt(code, desc, res)
	if tolua.isnull(self) then
		return
	end

	if code == -110 then
		desc = "当前设备似乎未曾以游客身份进入过游戏"
	end

	if self._isLoginProc then
		self._isLoginProc = false

		if code == 0 then
			self.loginEndCallback(res)

			if not tolua.isnull(self.accPanel) then
				self.accPanel:removeSelf()
			end
		else
			an.newMsgbox(desc or "", function(idx)
				return
			end, {
				center = true
			})
		end
	else
		an.newMsgbox(desc, function(idx)
			if code == 0 then
				if self.accPanel.action == "注册" then
					local value = self.accPanel.inputWids[1]:getText()
					local value2 = self.accPanel.inputWids[2]:getText()

					self.acInput:setText(value)
					self.pwInput:setText(value2)
				end

				self.accPanel:removeSelf()
			end
		end, {
			center = true
		})

		return
	end
end

function login:showPanel(title, inputs, btnsCfg, exitCallback)
	local internal = 55
	local w = 550
	local h = internal * #inputs + 160
	local colorTitle = cc.c3b(0, 176, 240)
	local colorInputBg = cc.c4b(55, 62, 64, 255)
	local colorInputTitle = cc.c3b(0, 179, 140)
	local colorBtnBg = cc.c4b(241, 76, 75, 255)
	local colorBtnTitle = cc.c3b(255, 255, 255)

	self.accPanel = display.newNode():size(display.size):addto(display.getRunningScene(), 1)

	self.accPanel:setTouchEnabled(true)

	self.accPanel.action = title

	local layer = display.newScale9Sprite(res.getframe2("pic/bzmir/newui/login/netease_bg.png"), 0, 0, cc.size(w, h)):add2(self.accPanel):anchor(0.5, 0.5):pos(display.cx, display.cy)

	layer.setTouchEnabled(layer, true)
	an.newLabel(title, 24, nil, {
		color = colorTitle
	}):addTo(layer):anchor(0.5, 0.5):pos(w / 2, h - 30)
	an.newBtn(res.gettex2("pic/bzmir/newui/login/netease_close.png"), function()
		if exitCallback then
			exitCallback()
		end
	end, {
		pressBig = true
	}):addTo(layer):anchor(1, 0.5):pos(w - 15, h - 30)

	local off = 90
	local inputWids = {}

	for k, v in pairs(inputs) do
		local iw = 180
		local ih = 32
		local ip = an.newInput(0, 0, iw, ih, 12, {
			label = {
				v.default or "",
				24
			},
			password = v.password
		}):addTo(layer, 1):pos(w / 2 + 20, h - off)
		local base = display.newColorLayer(colorInputBg):addto(layer)

		base.setContentSize(base, ip.getContentSize(ip))
		base.setPosition(base, w / 2 - iw / 2 + 20, h - off - ih / 2)
		an.newLabel(tostring(v.text), 22, nil, {
			color = colorInputTitle
		}):addto(base):pos(-10, ih / 2):anchor(1, 0.5)

		inputWids[k] = ip
		off = off + internal
	end

	self.accPanel.inputWids = inputWids

	local btns = {}
	local totalWidth = 0

	for k2, v2 in pairs(btnsCfg) do
		local text = an.newLabel(v2.text, 24, nil, {
			color = colorBtnTitle
		})
		local size = text.getContentSize(text)
		local btn = display.newScale9Sprite(res.getframe2("pic/bzmir/newui/login/netease_btn.png"), 0, 0, cc.size(size.width + 24, size.height + 5)):add2(layer):anchor(0, 0)

		btn.addChild(btn, text)
		text.pos(text, size.width / 2 + 10, size.height / 2 + 2.5):anchor(0.5, 0.5)

		btns[k2] = btn
		totalWidth = totalWidth + btn.getw(btn)

		text.enableClick(text, function()
			local inputStrings = {}

			for k, v in pairs(inputWids) do
				inputStrings[k] = v.getString(v)
			end

			v2.cb(inputStrings)
		end)
	end

	local gap = (w - totalWidth) / (#btnsCfg + 1)
	local btnY = 30
	local off2 = 0

	for k3, v3 in pairs(btns) do
		v3.pos(v3, off2 + gap, btnY)

		off2 = off2 + gap + v3.getw(v3)
	end
end

return login
