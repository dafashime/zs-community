local current = ...
local bzUIConfig = require("mir2.bzUIConfig")
local common = import("..main.common.common")
local scene = class("loginScene", function()
	return display.newScene("login")
end)

table.merge(scene, {})

function scene:ctor(params)
	self.setNodeEventEnabled(self, true)

	self.params = params or {
		logout = true
	}

	local value = bzUIConfig.loginScene

	if value.zonePlayAni then
		local ani2 = res.getani2("pic/bzmir/newui/login/loginanimate/%d.png", 1, value.zonePlayAniMax, value.zonePlayAniInterval)

		if ani2 then
			ani2:retain()

			local value_2 = res.get2("pic/bzmir/newui/login/loginanimate/1.png"):addTo(self):center():fit()

			if value_2 then
				value_2:runForever(cc.Animate:create(ani2))
			end
		end
	else
		res.get("chrsel", 22):addto(self):center():fit()
	end

	local value2 = (MIR2_VERSION or "") .. (BZ_VERSION and "\n" .. BZ_VERSION or "")

	an.newLabel(value2, 16, 1, {
		color = cc.c3b(222, 222, 150)
	}):add2(self):pos(display.width - 30, 5):anchor(1, 0)

	if device.platform == "android" then
		self.setKeypadEnabled(self, true)
		self.addNodeEventListener(self, cc.KEYPAD_EVENT, function(event)
			if event.key == "back" then
				an.newMsgbox("是否退出游戏?", function(idx)
					if idx == 1 then
						os.exit(1)
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end)
	end
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

local function cleanup2(ac, pw)
	if not io.exists(device.writablePath .. "acccache") then
		ycFunction:mkdir(device.writablePath .. "acccache")
	end

	if not pw then
		local value = cleanup()

		if value and value.ac == ac then
			pw = value.pw
		end

		pw = pw or ""
	end

	io.writefile(device.writablePath .. "acccache/ac", crypto.encryptXXTEA(json.encode({
		ac = ac,
		pw = pw
	}), cache.safeKey))
end

function scene:onCleanup()
	return
end

function scene:connectServer()
	self.logined = false
	self.loadText = an.newLabel("正在连接, 请稍候...", 20, 1, {
		color = cc.c3b(255, 255, 0),
		sc = display.COLOR_BLACK
	}):anchor(0.5, 0):pos(display.cx, 115):add2(self)

	local IpPortparam1, IpPortparam2 = string.find(def.ip, ":")
	local IpResult = def.ip
	local PortResult = "7000"

	if IpPortparam2 >= 1 then
		PortResult = string.sub(def.ip, IpPortparam2 + 1, string.len(def.ip))
		IpResult = string.sub(def.ip, 1, IpPortparam2 - 1)
	end

	net.connect(IpResult, PortResult, self, nil, def.areaID)
end

function scene:chooseList()
	self.loadText:removeSelf()

	self.loadText = nil
end

function scene:onEnterTransitionFinish()
	if self.isLogined then
		return
	end

	self.isLogined = true

	local function login(isGplusLogin)
		if not self.params.logout then
			self:showLayer("areas", true, handler(self, self.onRepServerList))
		else
			self:showLayer("login", bzmir.gateIP, bzmir.gatePort, handler(self, self.loginEnd))
		end
	end

	if self.params then
		if not g_data.login.isSDKLogin or type(self.params) == "table" and self.params.logout and false and false then
			login()
		end
	elseif (device.platform == "ios" or device.platform == "android") and (DEBUG > 0 and not m2debug.setting.acLogin or DEBUG == 0) then
		scheduler.performWithDelayGlobal(function()
			login(true)
		end, 0)
	else
		login()
	end
end

function scene:onEnter()
	cc.Director:getInstance():purgeCachedData()
end

function scene:onExit()
	return
end

function scene:showLayer(name, ...)
	if self.layer then
		if self.layer.__cname == name then
			return
		else
			self.layer:removeSelf()
		end
	end

	self.layer = import("." .. name, current).new(self, ...):addto(self)
end

function scene:hideLayer(name)
	if self.layer and self.layer.__cname == name then
		self.layer:removeSelf()

		self.layer = nil
	end
end

function scene:reconectFuc(info)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info, function()
			return
		end, {
			center = true,
			btnTexts = {
				"重连游戏"
			}
		})
	end
end

function scene:socketEvent(data, status)
	if status == 2 then
		self.reconectFuc(self, "连接游戏失败")
	elseif status == 3 then
		self.reconectFuc(self, "与游戏服务器断开连接")
	end
end

function scene:onLoseConnect()
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	self.reconnectBox = self.reconectFuc(self, "网络连接已断开!")
end

function scene:onNetworkStateChange(currentState)
	local connectable = network.isHostNameReachable("www.baidu.com")

	if not tolua.isnull(self.reconnectBox) then
		if connectable then
			self.reconnectBox:removeSelf()

			self.reconnectBox = nil
		else
			return
		end
	end

	if connectable then
		self.reconectFuc(self, "切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "其它网络"))
	end
end

function scene:processMsg(msg, buf, bufLen)
	if not msg then
		return
	end

	local function tip(str)
		an.newMsgbox(str, nil, {
			center = true
		})
	end

	local ident = msg.ident

	if SM_SERVER_LIST == ident then
		g_data.login:setGroupList(msg, buf, bufLen)
		self.hideLayer(self, "servers")
		self.chooseList(self)

		local name = g_data.login:getSelectGroup():get("groupName")

		net.send({
			CM_SELECT_SERVER,
			param = 1,
			recog = -1,
			series = 0,
			tag = def.useIGW
		}, {
			name
		})
	elseif SM_SELECT_SERVER == ident then
		if msg.recog == 0 then
			print(msg.series)

			if msg.series == 2 then
				tip("你选择的游戏服已满员")
			elseif msg.series == 3 then
				tip("你选择的游戏服务器正在维护中")
			elseif msg.series == 4 then
				tip("配置的区组ID或服务器名字不一致")
			end

			if self.layer.__cname == "areas" and self.layer.mask then
				self.layer:removeMask()
			end
		else
			local ip = int2ip(MakeLong(msg.tag, msg.series))
			local port = msg.param
			local sessionID = msg.recog
			local serverMsg, buf2, bufLen2 = net.record("TSelectServerMsg", buf, bufLen)
			local serverMsg2 = getRecord("TSelectServerMsg2")

			g_data.login.recIP = ip
			g_data.login.recPort = port
			g_data.login.recSession = sessionID
			g_data.login.serverMsg = serverMsg

			if bufLen2 >= serverMsg2.size(serverMsg2) then
				net.record(serverMsg2, buf2, buflen)

				g_data.login.serverMsg2 = serverMsg2
			end

			scheduler.performWithDelayGlobal(function()
				net.connect(ip, port, self, sessionID)
			end, 0)
		end
	elseif SM_LOGIN == ident then
		if IOS_REVIEW then
			local info = game.loadDeviceInfo()
			local ac = ccy.md(info.uuid or "unknow")

			net.send({
				CM_LOGIN_AUTH,
				recog = def.MIR_VERSION_NUMBER,
				param = net.platformCode()
			}, {
				ac,
				"123456",
				def.gameType,
				"mobile-mac-address"
			})
		else
			net.send({
				CM_LOGIN_AUTH,
				recog = def.MIR_VERSION_NUMBER,
				param = net.platformCode()
			}, {
				g_data.login.ticket,
				"",
				def.gameType,
				"mobile-mac-address"
			})

			if msg.param == 1 then
				-- block empty
			end
		end
	elseif SM_LOGIN_AUTH == ident then
		if msg.param ~= 2 or false then
			if msg.param == 1 then
				local ret1 = getRecord("TLoginIdResult")
				local ret2 = getRecord("TLoginIdResult2")

				if bufLen > ret1.size(ret1) then
					net.record(ret2, buf, bufLen)

					g_data.reconnctID = ret2.get(ret2, "reconnectID")
					g_data.login.loginRet2 = ret2
				else
					net.record(ret1, buf, bufLen)

					g_data.login.loginRet1 = ret1
				end

				if g_data.login.ac and g_data.login.ac ~= "" then
					if def.oldSaveAccount then
						cache.saveAccount(g_data.login.ac, g_data.login.pw)
					else
						cleanup2(g_data.login.ac, g_data.login.pw)
					end
				end

				self.hideLayer(self, "login")
			else
				dump(msg)

				local value

				if buf then
					tip(net.str(buf))
				elseif msg.recog == -1 then
					tip("[失败]：认证失败")
				elseif msg.recog == -2 then
					tip("[失败]：认证超时，请重新登录")
				elseif msg.recog == -3 then
					tip("[失败]：系统错误")
				elseif msg.recog == -4 then
					tip("[失败]：系统繁忙，请稍后登录")
				elseif msg.recog == -5 then
					tip("[失败]：对不起，发生连接错误，请稍后登陆")
				else
					tip("[失败]：登陆错误")
				end

				if self.layer and self.layer.__cname == "login" then
					self.layer.submitting = false
				end

				if self.layer.__cname == "areas" and self.layer.mask then
					self.layer:removeMask()
				end
			end
		end
	elseif SM_CHR_LIST == ident then
		g_data.login.roleInfo = {
			msg = msg,
			buf = buf,
			bufLen = bufLen
		}
	elseif (SM_SDOA_AUTH_NOTIFY_RESULT ~= ident or false) and (SM_SDOA_AUTH_NOTIFY_ERROR ~= ident or false) then
		if SM_REQUIRE_MIBAO == ident then
			g_data.security:setLoginBit(msg, buf, bufLen)
		elseif SM_NEED_VALIDATE_IMAGE == ident then
			local input
			local msgbox = an.newMsgbox("ViewImage: ", function(idx)
				if idx == 1 then
					os.exit(1)
				elseif idx == 2 then
					net.send({
						CM_SUBMIT_VALIDATE_IMAGE
					}, {
						input:getString()
					})
				elseif idx == 3 then
					net.send({
						CM_SUBMIT_VALIDATE_IMAGE,
						param = 1
					})
				end
			end, {
				disableScroll = true,
				hasCancel = true,
				btnTexts = {
					"取消",
					"确定",
					msg.param > 0 and "NEXT" or nil
				}
			})

			input = an.newInput(130, msgbox.bg:geth() - 47, 200, 30, 8, {
				label = {
					"",
					18,
					1
				},
				bg = {
					h = 32,
					tex = res.gettex2("pic/scale/edit2.png"),
					offset = {
						-10,
						0
					}
				},
				getWorldY_call = function()
					return 250
				end
			}):add2(msgbox.bg):anchor(0, 0)

			local tex = ycFunction:makeTexWithRawData(buf, msg.tag, msg.series, bufLen)

			display.newSprite(tex):add2(msgbox.bg):anchor(0, 0):pos(30, 94)
		elseif SM_LOGIN_ALREADY_ONLINE == ident then
			if msg.recog == 1 then
				self.kickoutBox = an.newMsgbox("此账号目前在线，是否强行登录?", function(idx)
					if idx == 1 then
						if g_data.login.roleInfo.msg.recog == 1 then
							self:showLayer("door")
							g_data.select:receiveChrs(g_data.login.roleInfo.msg, g_data.login.roleInfo.buf, g_data.login.roleInfo.bufLen)
						end
					elseif self.layer and self.layer.__cname == "areas" and self.layer.mask then
						self.layer:removeMask()
					end

					net.send({
						CM_LOGIN_ALREADY_ONLINE,
						param = idx == 1 and 1 or 0
					})
				end, {
					center = true,
					hasCancel = true
				})
			else
				self.showLayer(self, "door")
				g_data.select:receiveChrs(g_data.login.roleInfo.msg, g_data.login.roleInfo.buf, g_data.login.roleInfo.bufLen)
			end
		elseif SM_LOGIN_QUEUE == ident then
			g_data.login:setQueueData(msg)
		elseif SM_SELCHR_ERR == ident then
			an.newMsgbox("游戏维护中，请稍后再试", nil, {
				center = true
			})
		else
			return false
		end
	end

	return true
end

function scene:loginEnd(data)
	g_data.login.phone = data.phone

	g_data.login:setForceList(data.list.forces)
	g_data.login:setNetLastName(data.last)

	g_data.login.ticket = data.ticket

	self.connectServer(self)
end

function scene:onRepServerList()
	def.lazyLoadConfig()
	self.showLayer(self, "login", bzmir.gateIP, bzmir.gatePort, handler(self, self.loginEnd))
end

local function getServerList(callback)
	return
end

scene.ERRCODE_INIT = {
	[0] = "成功",
	[-10862709] = "用户未登录",
	[-10862710] = "未初始化错误",
	[-10862703] = "参数错误",
	[-10862705] = "正在支付，请稍后",
	[-10862901] = "初始化失败",
	[-10862706] = "支付失败",
	[-10862707] = "系统错误，请稍后重试(与服务端建立安全通信通道失败)",
	[-10862712] = "支付取消",
	[-10862711] = "登录取消(接入方通常要对这个参数做些处理)",
	[-10862801] = "请绑定游客至G家账号",
	[-10862713] = "服务器异常",
	[-10862702] = "网络错误",
	[-10862704] = "无ticket错误",
	[-10862802] = "游客升级成功",
	[-10862714] = "用户已经登录，不能重复登录",
	[-10862701] = "系统错误",
	[-10862708] = "登录失败",
	[-10862750] = "当前渠道不支持此扩展方法"
}

function scene:gplusInitEnd(code, msg)
	return
end

function scene:gplusLoginEnd(code, msg, ticket, userid, phone)
	return
end

return scene
