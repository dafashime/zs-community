local scale = 1.8
local login = class("login", function ()
	return display.newNode()
end)
local loginer = import(".loginer")

table.merge(login, {
	submitting
})

function login:ctor(scene, ip, port, loginEndCallback)
	print(scene, ip, port, loginEndCallback)

	self.scene = scene

	self:setNodeEventEnabled(true)

	local info = game.loadDeviceInfo()
	self.m = game.initLoginer(loginer, info.uuid or cache.check_uuid("" .. math.random()))

	self.m:selectServer(ip, port)
	self.m:setEvtListener(self)

	self.loginEndCallback = loginEndCallback
end

function login:onEnter()
	local scene = self.scene

	res.getui(1, 60):addto(self):center():scale(scale)

	local acInput, pwInput = nil

	local function submit()
		sound.playSound("104")

		if self.submitting then
			return
		end

		if string.len(acInput:getText()) < 4 then
			an.newMsgbox("帐号格式不对", nil, {
				center = true
			})
		elseif string.len(pwInput:getText()) < 4 then
			an.newMsgbox("密码格式不对", nil, {
				center = true
			})
		else
			g_data.login.ac = acInput:getText()
			g_data.login.pw = pwInput:getText()

			self.m:login(g_data.login.ac, g_data.login.pw)

			self._isLoginProc = true
		end
	end

	acInput = an.newInput(display.cx + 20 * scale, display.cy + 32 * scale, 135 * scale, 36 * scale, 32, {
		label = {
			"",
			16 * scale
		},
		return_call = function ()
			pwInput:startInput()
		end
	}):addTo(self)
	pwInput = an.newInput(display.cx + 20 * scale, display.cy - 1 * scale, 135 * scale, 36 * scale, 16, {
		password = true,
		label = {
			"",
			16 * scale
		},
		return_call = submit
	}):addTo(self)
	local account = cache.getAccount()

	if account then
		acInput:setText(account.ac)
		pwInput:setText(account.pw)
	end

	local function exitCallback()
		self.accPanel:removeSelf()
	end

	an.newBtn(res.getuitex(1, 61), function ()
		local lbs = {
			"用户名",
			"密　码",
			"安全码"
		}

		sound.playSound("104")
		self:showPanel("注册", {
			{
				text = "用户名"
			},
			{
				text = "密　码",
				password = true
			},
			{
				text = "安全码"
			}
		}, {
			{
				text = "确　定",
				cb = function (inputs)
					for k, v in pairs(inputs) do
						if string.len(v) < 6 then
							an.newMsgbox(lbs[k] .. "的长度不应小于6", nil, {
								center = true
							})

							return
						elseif string.find(v, "[^%w!@#$]") then
							an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function (idx)
							end, {
								center = true
							})

							return
						end
					end

					self.m:register(unpack(inputs))
				end
			},
			{
				text = "绑定游客账号",
				cb = function ()
					self.accPanel:removeSelf()
					self:showPanel("绑定游客账号", {
						{
							text = "用户名"
						},
						{
							text = "密　码",
							password = true
						},
						{
							text = "安全码"
						}
					}, {
						{
							text = "确　定",
							cb = function (inputs)
								for k, v in pairs(inputs) do
									if string.len(v) < 6 then
										an.newMsgbox(lbs[k] .. "的长度不应小于6", nil, {
											center = true
										})

										return
									elseif string.find(v, "[^%w!@#$]") then
										an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function (idx)
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
	}):pos(display.cx - 73 * scale, display.cy - 96 * scale):addto(self):scale(scale)
	an.newBtn(res.getuitex(1, 62), submit, {
		pressShow = true
	}):pos(display.cx + 59 * scale, display.cy - 53 * scale):addto(self):scale(scale)
	an.newBtn(res.getuitex(1, 53), function (event)
		sound.playSound("104")
		self:showPanel("修改密码", {
			{
				text = "用户名"
			},
			{
				text = "新密码",
				password = true
			},
			{
				text = "安全码"
			}
		}, {
			{
				text = "确　定",
				cb = function (inputs)
					for k, v in pairs(inputs) do
						if string.len(v) < 6 then
							an.newMsgbox(lbs[k] .. "的长度不应小于6", nil, {
								center = true
							})

							return
						elseif string.find(v, "[^%w!@#$]") then
							an.newMsgbox("不允许使用除字母数字及\"!\"\"@\"\"#\"\"$\"以外的特殊字符", function (idx)
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
	}):pos(display.cx + 46 * scale, display.cy - 96 * scale):addto(self):scale(scale)
	an.newBtn(res.gettex2("pic/login/bVLogin1.png"), function (event)
		sound.playSound("104")
		self.m:login(nil, nil, 1)

		self._isLoginProc = true
	end, {
		pressImage = res.gettex2("pic/login/bVLogin2.png")
	}):pos(display.cx - 59 * scale, display.cy - 53 * scale):addto(self):scale(1.4):addChild(res.get2("pic/login/youkedenglu.png"):pos(84, 20))
	an.newBtn(res.getuitex(1, 64), function (event)
		sound.playSound("103")
		os.exit(1)
	end, {
		pressShow = true,
		size = {
			36,
			36
		}
	}):pos(display.cx + 112 * scale, display.cy + 86 * scale):addto(self):scale(scale)
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
			print(code)
			an.newMsgbox(desc or "", function (idx)
			end, {
				center = true
			})
		end
	else
		an.newMsgbox(desc, function (idx)
			if code == 0 then
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

	local layer = display.newScale9Sprite(res.getframe2("pic/login/netease_bg.png"), 0, 0, cc.size(w, h)):add2(self.accPanel):anchor(0.5, 0.5):pos(display.cx, display.cy)

	layer:setTouchEnabled(true)
	an.newLabel(title, 24, nil, {
		color = colorTitle
	}):addTo(layer):anchor(0.5, 0.5):pos(w / 2, h - 30)
	an.newBtn(res.gettex2("pic/login/netease_close.png"), function ()
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
				"",
				24
			},
			password = v.password
		}):addTo(layer, 1):pos(w / 2 + 20, h - off)
		local base = display.newColorLayer(colorInputBg):addto(layer)

		base:setContentSize(ip:getContentSize())
		base:setPosition(w / 2 - iw / 2 + 20, h - off - ih / 2)
		an.newLabel(tostring(v.text), 22, nil, {
			color = colorInputTitle
		}):addto(base):pos(-10, ih / 2):anchor(1, 0.5)

		inputWids[k] = ip
		off = off + internal
	end

	local btns = {}
	local totalWidth = 0

	for k, v in pairs(btnsCfg) do
		local text = an.newLabel(v.text, 24, nil, {
			color = colorBtnTitle
		})
		local sz = text:getContentSize()
		local btn = display.newScale9Sprite(res.getframe2("pic/login/netease_btn.png"), 0, 0, cc.size(sz.width + 24, sz.height + 5)):add2(layer):anchor(0, 0)

		btn:addChild(text)
		text:pos(sz.width / 2 + 10, sz.height / 2 + 2.5):anchor(0.5, 0.5)

		btns[k] = btn
		totalWidth = totalWidth + btn:getw()

		text:enableClick(function ()
			local inputStrings = {}

			for k, v in pairs(inputWids) do
				inputStrings[k] = v:getString()
			end

			v.cb(inputStrings)
		end)
	end

	local gap = (w - totalWidth) / (#btnsCfg + 1)
	local btnY = 30
	local off = 0

	for k, v in pairs(btns) do
		v:pos(off + gap, btnY)

		off = off + gap + v:getw()
	end
end

return login
