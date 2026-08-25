local value

value = device.platform == "android"

local yaya = {
	freeMode = true,
	logined = false,
	appid = "mediasoup",
	isonMic = false,
	authed = false
}

yaya.listenner = nil

local count = 0

function yaya.reset()
	yaya.authed = false
	yaya.logined = false
	yaya.freeMode = true
	yaya.isonMic = false
end

function yaya.setListenner(listenner)
	yaya.listenner = listenner

	if device.platform == "android" then
		if not _G.mediasoup_callback_wrapper then
			function _G:mediasoup_callback_wrapper()
				yaya_callback(self)
			end
		end

		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "setLuaCallback", {
			_G.mediasoup_callback_wrapper
		})

		if not value2 then
			print("mediasoup.setLuaCallback call err. ->", value3)
		else
			return yaya.listenner
		end
	elseif device.platform == "ios" then
		if not _G.mediasoup_callback_wrapper then
			function _G:mediasoup_callback_wrapper()
				yaya_callback(self)
			end
		end

		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "setLuaCallback", {
			callbackId = _G.mediasoup_callback_wrapper
		})

		if not value4 then
			print("mediasoup.setLuaCallback call err. ->", value5)
		else
			return yaya.listenner
		end
	end
end

function yaya.removeListenner()
	yaya.listenner = nil

	if device.platform == "android" then
		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "setLuaCallback", {
			0
		})

		if not value2 then
			print("mediasoup.setLuaCallback(clear) call err. ->", value3)
		end
	elseif device.platform == "ios" then
		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "setLuaCallback", {
			callbackId = 0
		})

		if not value4 then
			print("mediasoup.setLuaCallback(clear) call err. ->", value5)
		end
	end

	if _G.mediasoup_callback_wrapper then
		_G.mediasoup_callback_wrapper = nil
	end
end

function yaya.call(key, ...)
	if yaya.listenner and yaya.listenner[key] then
		yaya.listenner[key](...)
	end
end

function yaya.initSDK(istest, data)
	if device.platform == "android" then
		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "initSDK", {
			istest,
			yaya.appid
		})

		if not value2 then
			print("mediasoup.initSDK call err. ->", value3)
		else
			return yaya.setListenner(data)
		end
	elseif device.platform == "ios" then
		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "initSDK", {
			istest = istest,
			appid = yaya.appid
		})

		if not value4 then
			print("mediasoup.initSDK call err. ->", value5)
		else
			return yaya.setListenner(data)
		end
	end
end

function yaya.login(roomID)
	yaya.reset()

	local token, token2 = auth_token.getToken()

	if not token then
		if yaya.listenner and yaya.listenner.loginEnd then
			yaya.listenner.loginEnd({
				result = -1,
				msg = "获取授权token失败: " .. (token2 or "unknown error")
			})
		end

		return
	end

	if device.platform == "android" then
		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "login", {
			tostring(roomID),
			token
		})

		if not value2 then
			print("[mediasoup] ERROR: login call failed:", value3)
		else
			print("[mediasoup] login call succeeded")
		end
	elseif device.platform == "ios" then
		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "loginWithRoomID", {
			roomID = tostring(roomID),
			token = token
		})

		if not value4 then
			print("[mediasoup] ERROR: login call failed:", value5)
		else
			print("[mediasoup] login call succeeded")
		end
	end
end

function yaya.logout()
	yaya.reset()

	if device.platform == "android" then
		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "logout", {})

		if not value2 then
			print("mediasoup.logout call err. ->", value3)
		end
	elseif device.platform == "ios" then
		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "logout", {})

		if not value4 then
			print("mediasoup.logout call err. ->", value5)
		end
	end
end

function yaya.sendText(text, gamedata)
	print("mediasoup.sendText - not implemented (realtime voice only)")
end

function yaya.mic(ison, gamedata)
	if device.platform == "android" then
		local text = tostring(gamedata)
		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "mic", {
			ison,
			text
		})

		if not value2 then
			print("mediasoup.mic call err. ->", value3)
		else
			print("[LUA] Java mic() call succeeded")
		end
	elseif device.platform == "ios" then
		local text2 = tostring(gamedata)
		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "mic", {
			ison = ison,
			gamedata = text2
		})

		if not value4 then
			print("mediasoup.mic call err. ->", value5)
		else
			print("[LUA] iOS mic() call succeeded")
		end
	end
end

function yaya.setMode(mode)
	if device.platform == "android" then
		local value2, value3 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "MediasoupBridge", "setMicMode", {
			mode
		}, "(I)V")

		if not value2 then
			print("mediasoup.setMode call err. ->", value3)
		end
	elseif device.platform == "ios" then
		local value4, value5 = luaoc.callStaticMethod("MediasoupBridge", "setMicMode", {
			mode = mode
		})

		if not value4 then
			print("mediasoup.setMode call err. ->", value5)
		end
	end

	yaya.freeMode = mode == 0
end

function yaya.uploadVoice(path, dur, expand)
	print("mediasoup.uploadVoice - not implemented (realtime voice only)")
end

function yaya.uploadPic(path, size, msgID)
	print("mediasoup.uploadPic - not implemented (realtime voice only)")
end

function yaya.callSDK(methodName, ...)
	print("mediasoup.callSDK - deprecated, use direct methods instead")
end

function yaya_callback(dic)
	if type(dic) == "string" then
		dic = json.decode(dic)

		if not dic then
			printError("mediasoup_callback decode err. ->[%s]", dic)

			return
		end
	end

	if dic.gameData and not dic.gamedata then
		dic.gamedata = dic.gameData
	end

	local value2 = dic.type

	if yaya["call_" .. value2] then
		yaya["call_" .. value2](dic)
	end

	yaya.call(value2, dic)
end

function yaya.call_initEnd(dic)
	return
end

function yaya.call_authEnd(dic)
	local result = dic.result
	local msg = dic.msg

	yaya.authed = result == 0
end

function yaya.call_loginEnd(dic)
	local result = dic.result
	local msg = dic.msg
	local yunvaid = dic.yunvaid
	local leaderID = dic.leaderID
	local isLeader = dic.isLeader

	yaya.freeMode = dic.micMode and dic.micMode == 0
	yaya.logined = result == 0
	yaya.yunvaid = yunvaid

	if not yaya.freeMode then
		yaya.setMode(0)
	end
end

function yaya.call_logoutEnd(dic)
	local result = dic.result
	local msg = dic.msg

	yaya.reset()
end

function yaya.call_sendTextSuccess(dic)
	return
end

function yaya.call_sendTextErr(dic)
	return
end

function yaya.call_textNotify(dic)
	return
end

function yaya.call_micEnd(dic)
	local result = dic.result
	local msg = dic.msg
	local ison = dic.ison

	yaya.isonMic = ison
end

function yaya.call_realtimeVoice(dic)
	local roomID = dic.roomID
	local gamedata = dic.gameData
	local yunvaid = dic.yunvaid
end

function yaya.call_realtimeVoiceErr(dic)
	local result = dic.result
	local msg = dic.msg
	local ison = dic.ison
end

function yaya.call_micModeEnd(dic)
	local result = dic.result
	local msg = dic.msg

	yaya.freeMode = dic.result == 0
end

function yaya.call_micModeNotify(dic)
	local mode = dic.mode

	yaya.freeMode = dic.mode == 0
end

function yaya.call_relogin(dic)
	local result = dic.result
	local tryReLoginTimes = dic.tryReLoginTimes
end

function yaya.call_uploadVoiceEnd(dic)
	return
end

function yaya.call_uploadPicEnd(dic)
	return
end

return yaya
