local common = import("..main.common.common")
local scene = class("notice", function()
	return display.newScene("notice")
end)

table.merge(scene, {
	submitting
})

function scene:ctor()
	if device.platform == "android" then
		self:setKeypadEnabled(true)
		self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
			if event.key == "back" then
				an.newMsgbox("确定要「退出游戏」吗？", function(idx)
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

	net.add(self)
end

function scene:showNotice(text)
	res.get2("pic/notice/bg.png"):center():addto(self)

	local newText = {}
	local finded = false

	for i, v in ipairs(utf8strs(text)) do
		if not finded and string.byte(v) ~= 32 and string.byte(v) ~= 27 then
			finded = true
		end

		if finded then
			newText[#newText + 1] = v
		end
	end

	text = table.concat(newText)
	text = string.gsub(text, "\\", "")

	local scroll = an.newScroll(0, 0, 250, 270, {
		labelM = {
			15,
			1
		}
	}):anchor(0.5, 0.5):pos(display.cx, display.cy + 20):addTo(self)
	local strs = string.split(text, string.char(27))

	for i2, v2 in ipairs(strs) do
		if v2 ~= "" and i2 ~= 2 then
			scroll.labelM:addLabel(string.trim(v2) or "")
			scroll.labelM:nextLine()
		end
	end

	if not checkMd5 then
		cc.Director:getInstance():endToLua()
		core_func_byby()
	else
		checkMd5()
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		if self.submitting then
			return
		end

		self.submitting = true

		sound.playSound("104")
		net.remove(self)

		if def.preloadRes then
			an.newLabel("Loading MainUI…", 18, 1, {
				color = def.colors.labelYellow
			}):pos(self:getw() / 2, 80):addto(self):anchor(0.5, 0.5)
		end

		game.gotoscene("main", nil, "fade", 0.5, display.COLOR_BLACK)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/common/confirm.png")
	}):pos(display.cx, display.cy - 140):addto(self)
end

function scene:onEnter()
	res.purgeCachedData()
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
		self.reconnectBox = an.newMsgbox(info .. "\n确定重连?", function(idx)
			if idx == 0 then
				common.gotoLogin({
					logout = true
				})
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
		self:reconectFuc("切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "其它网络"))
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

	if SM_SENDNOTICE == ident then
		self:showNotice(net.str(buf))
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
	elseif SM_CLIENT_CONF == ident then
		g_data.chat:setShieldMask(msg.recog)
	elseif SM_CHR_LIST == ident then
		g_data.login.roleInfo = {
			msg = msg,
			buf = buf,
			bufLen = bufLen
		}
	elseif SM_OUTOFCONNECTION_KICKOUT == ident then
		self:reconectFuc("已经被其他用户踢下线")
	elseif SM_LOGIN_ALREADY_ONLINE == ident then
		if msg.recog == 1 then
			self.kickoutBox = an.newMsgbox("此账号目前在线，是否强行登录?", function(idx)
				if idx == 1 then
					game.gotoscene("reconnect", nil, "fade", 0.5, display.COLOR_BLACK)
				else
					common.gotoLogin({
						logout = true
					})
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
			game.gotoscene("reconnect", nil, "fade", 0.5, display.COLOR_BLACK)
		end
	elseif SM_SELCHR_ERR == ident then
		scheduler.performWithDelayGlobal(function()
			an.newMsgbox("服务器维护中，请稍后再试", function()
				common.gotoLogin({
					logout = true
				})
			end, {
				center = true
			})
		end, 1)
	else
		return false
	end

	return true
end

return scene
