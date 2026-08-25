local current = ...
local ui = import(".ui")
local ground = import(".ground")
local common = import(".common.common")
local operate = import(".pc.operate")
local alertBar = import(".common.AlertBar")
local tipsBar = import(".common.TipsBar")
local cusTipsBar = import(".common.cusTipsBar")
local baseScene = import("..baseScene", current)
local scene = class("main", baseScene)

table.merge(scene, {})

function scene:ctor()
	main_scene = self
	self.ground = ground.new():addto(self, 0)
	self.ui = ui.new():addto(self, 100):hide()
	self.ui.barCreater = alertBar
	self.ui.common = common

	local text = "pic/bzmir/alert/bg.png"

	text = def.alertTips and def.alertTips.bg or text
	self.ui.tipsBar = tipsBar.new(text):add2(self.ui, 3)

	if def.alertTips then
		self.ui.tipsBar:setBorder(def.alertTips.border or 1)
		self.ui.tipsBar:setPos(def.alertTips.posx or display.cx, def.alertTips.posy or display.cy - 100)

		self.ui.tipsBar.color1 = _stringToCorlor(def.alertTips.color1)
		self.ui.tipsBar.color2 = _stringToCorlor(def.alertTips.color2)

		if def.alertTips.color3 then
			self.ui.tipsBar.color3 = _stringToCorlor(def.alertTips.color3)
		end

		if def.alertTips.color4 then
			self.ui.tipsBar.color4 = _stringToCorlor(def.alertTips.color4)
		end

		if def.alertTips.color5 then
			self.ui.tipsBar.color5 = _stringToCorlor(def.alertTips.color5)
		end
	end

	if not def.clrTipsBar then
		def.clrTipsBar = {
			fontSize = 16,
			bg = "pic/bzmir/alert/bg.png",
			posx = display.cx,
			posy = display.cy + 200,
			fontColor = display.COLOR_WHITE
		}
	end

	self.ui.customBar = cusTipsBar.new(def.clrTipsBar.bg or "pic/bzmir/alert/bg.png"):add2(self.ui, 3)

	self.ui.customBar:setBorder(1)
	self.ui.customBar:setPos(def.clrTipsBar.posx or display.cx, def.clrTipsBar.posy or display.cy + 200)

	self.ui.alertbar = alertBar.new("pic/bzmir/alert/bg.png", 0.6, 35, 300):add2(self.ui, 3)
	self.ui.alertbars = {}

	pic.setListenner(import(".common.picListenner", current))
	voice.setListenner(import(".common.voiceListenner", current))
	net.add(self)
	net.add(self.ui)
	net.add(self.ground)
	net.send({
		CM_LOGINNOTICEOK
	}, nil, getRecord("TOsVersion3"))
	net.setWaitMsg(SM_NEWMAP, SM_MAPINFO_EX)

	if not checkMd5 then
		cc.Director:getInstance():endToLua()
		core_func_byby()
	else
		checkMd5()
	end

	if device.platform == "android" then
		self:setKeypadEnabled(true)
		self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
			if event.key == "back" then
				if def.offToSaftyOnline then
					an.newMsgbox("确定要「退出游戏」吗？", function(value)
						if value == 1 then
							net.send({
								1314
							})
							os.exit(1)
						end
					end, {
						center = true,
						hasCancel = true
					})
				else
					an.newMsgbox("确定要「退出游戏」吗？", function(idx)
						if idx == 1 then
							net.send({
								CM_SOFTCLOSE
							})
							os.exit(1)
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end
		end)
	end

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(...)
		self.ground:update(...)
		self.ui:update(...)
	end)
	self:scheduleUpdate()

	if DEBUG > 0 then
		net.sendPing()
		g_data.client:setLastTime("ping", true)
	end

	if WIN32_OPERATE then
		operate.init()
		self:initHotKey()
	end

	self:setNormalFPS()
end

function scene:setNormalFPS()
	if g_data.setting.base.highFrame then
		cc.Director:getInstance():setAnimationInterval(0.016666666666666666)
	else
		cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
	end
end

function scene:onEnter()
	print("main.scene:onEnter")
	self.super.onEnter(self)
	g_data.shop:init()
end

function scene:onExit()
	print("main.scene:onExit")
	self.super.onExit(self)
end

function scene:smallExit()
	self.smallExitState = true

	net.send({
		CM_SOFTCLOSE
	})
end

function scene:bigExit()
	self:clearGameData()
	common.gotoLogin({
		logout = true
	})
end

function scene:clearGameData()
	if IS_PLAYER_DEBUG then
		package.loaded["mir2.scenes.main.scene"] = nil
		package.loaded["mir2.scenes.main.ground"] = nil
		package.loaded["mir2.scenes.main.ui"] = nil
	end

	local function createProgress()
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
			cc.CallFunc:create(function()
				prodata = prodata + 0.02

				self.reprogress:setp(prodata > 1 and 1 or prodata)

				if prodata > 1 and prodata < 1.1 and self.reprogress then
					self.reprogress:stopAllActions()
					self.reprogress:removeSelf()

					self.reprogress = nil
				end
			end)
		}))
	end

	if not main_scene then
		createProgress()

		return
	end

	self.ui.console.controller.autoFindPath:multiMapPathStop()
	self:removeAllNodeEventListeners()
	self.ui:removeSelf()
	self.ground:removeSelf()

	if g_data.login.reconnectState then
		self:add(an.newLabel("正在重连中..", 20, 1, {
			color = cc.c3b(255, 255, 0),
			sc = display.COLOR_BLACK
		}):anchor(0.5, 0):pos(display.cx, 30))
		createProgress()
	else
		self:add(an.newLabel("正在退出..", 20, 1, {
			color = cc.c3b(255, 255, 0),
			sc = display.COLOR_BLACK
		}):anchor(0.5, 0):pos(display.cx, 30))
	end

	main_scene = nil

	net.clearMsgs()
	g_data.cleanup()
	g_data.reset()
	audio.stopAllSounds()
	res.purgeCachedData()
	pic.removeListenner()
	voice.removeListenner()
end

function scene:phone_listenner(state, number)
	if state == 1 then
		-- block empty
	end
end

function scene:reconectFuc(info)
	if not tolua.isnull(self.reconnectBox) then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info .. "\n确定重连?", function(idx)
			if idx == 0 then
				self:bigExit()
			elseif idx == 1 then
				self.reconnect = true
				g_data.login.reconnectState = true

				scheduler.performWithDelayGlobal(function()
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

function scene:reconectFuc2(reconnectBox)
	if not tolua.isnull(self.reconnectBox) then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(reconnectBox .. "\n请重新进入游戏。", function(reconnectBox)
			os.exit(1)
		end, {
			center = true,
			hasCancel = false
		})
	end
end

function scene:socketEvent(data, status)
	if status == 3 then
		self:reconectFuc(self.reconnect and "连接超时中断，重连失败" or "与服务器断开连接")
	elseif status == 2 then
		self:reconectFuc("连接服务器失败，请检查网络并稍后再试")
	end
end

function scene:onLoseConnect()
	print("scene:onLoseConnect")

	if not tolua.isnull(self.reconnectBox) then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	self.reconnectBox = self:reconectFuc("网络连接已断开!")
end

if device.platform == "android" then
	function scene:onNetworkStateChange(currentState)
		print("android,scene:onNetworkStateChange", currentState)

		if not tolua.isnull(self.reconnectBox) then
			self.reconnectBox:removeSelf()

			self.reconnectBox = nil
		end

		self:reconectFuc("切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "其它网络"))
	end
else
	function scene:onNetworkStateChange(currentState)
		print("ios,scene:onNetworkStateChange", currentState)

		if network.isHostNameReachable("www.baidu.com") then
			if not tolua.isnull(self.reconnectBox) then
				self.reconnectBox:removeSelf()

				self.reconnectBox = nil

				self:reconectFuc("切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "其它网络"))
			end

			if currentState == cc.kCCNetworkStatusReachableViaWiFi then
				if self.ui then
					self.ui:tip("切换到WIFI网络")
				end
			elseif self.ui then
				self.ui:tip("切换到蜂窝网络")
			end
		else
			self:reconectFuc("网络连接已断开")
		end
	end
end

function scene:enterSelectScene(msg, buf, bufLen)
	if msg.recog == 1 then
		net.remove(self.ui)
		net.remove(self.ground)
		g_data.select:receiveChrs(msg, buf, bufLen)
		self:clearGameData()

		if self.reconnect then
			self.reconnect = false
			g_data.login.reconnectState = false

			self:runs({
				cc.DelayTime:create(5),
				cc.CallFunc:create(function()
					net.remove(self)

					if not self.reconnectBox then
						print("ReIn Game ")

						if self.isLoginQueue then
							game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
						else
							net.send({
								CM_SELCHR
							}, {
								g_data.select:getCurName()
							})
							game.gotoscene("notice", nil, "fade", 0.5, display.COLOR_BLACK)
						end
					end
				end)
			})
		else
			net.remove(self)
			game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
		end
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

	if SM_CHR_LIST == ident then
		self.isLoginQueue = false

		if not self.smallExitState then
			g_data.login.roleInfo = {
				msg = msg,
				buf = buf,
				bufLen = bufLen
			}
		else
			self.smallExitState = false

			self:enterSelectScene(msg, buf, bufLen)

			if WIN32_OPERATE then
				operate.unRegisterEvent()
			end
		end
	elseif SM_New_Version == ident then
		-- block empty
	elseif SM_LOGIN == ident then
		net.send({
			CM_RECONNECT
		}, {
			g_data.reconnctID
		})
	elseif SM_LOGIN_AUTH == ident then
		if msg.param == 2 then
			-- block empty
		elseif msg.param == 1 then
			local ret1 = getRecord("TLoginIdResult")
			local ret2 = getRecord("TLoginIdResult2")

			if bufLen > ret1:size() then
				net.record(ret2, buf, bufLen)

				g_data.reconnctID = ret2:get("reconnectID")
				g_data.login.loginRet2 = ret2
			else
				net.record(ret1, buf, bufLen)

				g_data.login.loginRet1 = ret1
			end
		end
	elseif SM_OUTOFCONNECTION == ident then
		-- block empty
	elseif SM_OUTOFCONNECTION_KICKOUT == ident then
		self:reconectFuc2("已经被其他用户踢下线")
	elseif SM_RECONNECT == ident then
		-- block empty
	elseif SM_LOGIN_ALREADY_ONLINE == ident then
		self:enterSelectScene(g_data.login.roleInfo.msg, g_data.login.roleInfo.buf, g_data.login.roleInfo.bufLen)

		if msg.recog == 1 then
			self.kickoutBox = an.newMsgbox("此账号目前在线，是否强行登录?", function(idx)
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
			self:enterSelectScene(g_data.login.roleInfo.msg, g_data.login.roleInfo.buf, g_data.login.roleInfo.bufLen)
		end
	elseif SM_LOGIN_QUEUE == ident then
		self.isLoginQueue = true

		g_data.login:setQueueData(msg)
	elseif SM_SELCHR_ERR == ident then
		an.newMsgbox("服务器维护中，请稍后再试", function()
			self:bigExit()
		end, {
			center = true
		})
	elseif ident == 11706 then
		an.newMsgbox("重连失败,请重新登陆", function()
			self:bigExit()
		end, {
			center = true
		})
	elseif SM_JPUSH_SETALIAS == ident then
		local alias = net.str(buf)

		jpush.setAlias(alias)
	end

	return true
end

function scene:initHotKey()
	local data = cache.getHotKey(common.getPlayerName()) or def.operate.hotKey

	g_data.hotKey:setKeyInfos(data)
end

return scene
