local common = import("..main.common.common")
local scene = class("reconnect", function ()
	return display.newScene("reconnect")
end)

function scene:ctor()
	net.add(self)
	self:add(an.newLabel("正在重连中..", 20, 1, {
		color = cc.c3b(255, 255, 0),
		sc = display.COLOR_BLACK
	}):anchor(0.5, 0):pos(display.cx, 30))
	self:showProgress()
end

function scene:showProgress()
	if self.reprogress then
		self.reprogress:stopAllActions()
		self.reprogress:removeSelf()

		self.reprogress = nil
	end

	self.reprogress = an.newProgress(res.gettex2("pic/console/bottom/pro2.png"), res.gettex2("pic/console/bottom/probg.png"), {
		x = 43,
		y = 4
	}):anchor(0.5, 0):pos(display.width * 0.5, 0):add2(self, 1)

	self.reprogress:setp(0)

	local prodata = 0

	self.reprogress:runForever(transition.sequence({
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ()
			prodata = prodata + 0.02

			self.reprogress:setp(prodata > 1 and 1 or prodata)

			if prodata > 1 and prodata < 1.1 and self.reprogress then
				self.reprogress:stopAllActions()
				self.reprogress:removeSelf()

				self.reprogress = nil

				if not self.reconnectBox then
					game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
				end
			end
		end)
	}))
end

function scene:onEnter()
end

function scene:onExit()
	net.remove(self)
end

function scene:reconectFuc(info)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info .. "\n确定重连?", function (idx)
			if idx == 0 then
				common.gotoLogin({
					logout = true
				})
			elseif idx == 1 then
				self.reconnect = true
				g_data.login.reconnectState = true

				scheduler.performWithDelayGlobal(function ()
					net.connect(g_data.login.recIP, g_data.login.recPort, self, g_data.login.recSession)
				end, 0)
			end

			self.reconnectBox = nil
		end, {
			center = true,
			hasCancel = true
		})
	end
end

function scene:onLoseConnect()
	print("scene:onLoseConnect")

	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	self.reconnectBox = self:reconectFuc("网络连接已断开!")
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
		self:reconectFuc("切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "蜂窝网络"))
	end
end

function scene:enterSelectScene(msg, buf, bufLen)
	print("enterSelectScene reconnect")

	if msg.recog == 1 then
		g_data.select:receiveChrs(msg, buf, bufLen)

		if self.reconnect then
			self.reconnect = false
			g_data.login.reconnectState = false

			self:showProgress()
			self:runs({
				cc.DelayTime:create(5),
				cc.CallFunc:create(function ()
					net.remove(self)

					if not self.reconnectBox then
						game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
					end
				end)
			})
		else
			net.remove(self)
			g_data.select:receiveChrs(msg, buf, bufLen)
			game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
		end
	end
end

function scene:socketEvent(data, status)
	if status == 3 then
		self:reconectFuc(self.reconnect and "连接超时中断，重连失败" or "与服务器断开连接")
	elseif status == 2 then
		self:reconectFuc("连接服务器失败，请检查网络并稍后再试")
	end
end

function scene:processMsg(msg, buf, bufLen)
	if not msg then
		return
	end

	local function tip(str, func)
		an.newMsgbox(str, func)
	end

	local ident = msg.ident

	if SM_LOGIN == ident then
		print("SM_LOGIN reconnect")
		net.send({
			CM_RECONNECT
		}, {
			g_data.reconnctID
		})
	elseif SM_LOGIN_AUTH == ident then
		if msg.param == 2 then
			-- Nothing
		elseif msg.param == 1 then
			local ret1 = getRecord("TLoginIdResult")
			local ret2 = getRecord("TLoginIdResult2")

			if ret1:size() < bufLen then
				print("SM_LOGIN_AUTH reconnect")
				net.record(ret2, buf, bufLen)

				g_data.reconnctID = ret2:get("reconnectID")
				g_data.login.loginRet2 = ret2
			else
				net.record(ret1, buf, bufLen)

				g_data.login.loginRet1 = ret1
			end
		end
	elseif SM_CLIENT_CONF == ident then
		g_data.chat:setShieldMask(msg.recog)
	elseif SM_CHR_LIST == ident then
		print("SM_CHR_LIST reconnect")

		g_data.login.roleInfo = {
			msg = msg,
			buf = buf,
			bufLen = bufLen
		}
	elseif SM_OUTOFCONNECTION_KICKOUT == ident then
		self:reconectFuc("已经被其他用户踢下线")
	elseif SM_LOGIN_ALREADY_ONLINE == ident then
		if msg.recog == 1 then
			print("SM_LOGIN_ALREADY_ONLINE 1 reconnect")

			self.kickoutBox = an.newMsgbox("此账号目前在线，是否强行登录?", function (idx)
				if idx == 1 then
					self:enterSelectScene(g_data.login.roleInfo.msg, g_data.login.roleInfo.buf, g_data.login.roleInfo.bufLen)
				end

				self.kickoutBox = nil

				net.send({
					CM_LOGIN_ALREADY_ONLINE,
					param = idx == 1 and 1 or 0
				})
			end, {
				center = true,
				hasCancel = true
			})
		else
			print("SM_LOGIN_ALREADY_ONLINE 0 reconnect")
			self:enterSelectScene(g_data.login.roleInfo.msg, g_data.login.roleInfo.buf, g_data.login.roleInfo.bufLen)
		end
	elseif SM_SELCHR_ERR == ident then
		an.newMsgbox("服务器维护中，请稍后再试", function ()
			common.gotoLogin({
				logout = true
			})
		end, {
			center = true
		})
	else
		return false
	end

	return true
end

return scene
