local isAndroid = device.platform == "android"
local yaya = {
	logined = true,
	appid = "1000309",
	authed = true
}

function yaya.reset()
	yaya.authed = nil
	yaya.logined = nil
	yaya.freeMode = nil
	yaya.isonMic = nil
end

function yaya.setListenner(listenner)
	yaya.listenner = listenner
end

function yaya.removeListenner()
	yaya.listenner = nil
end

function yaya.call(key, ...)
	if yaya.listenner and yaya.listenner[key] then
		yaya.listenner[key](...)
	end
end

function yaya.initSDK(istest)
	yaya.callSDK("initSDK", {
		"istest",
		istest
	}, {
		"appid",
		yaya.appid
	})
end

function yaya.login(roomID)
	yaya.reset()
	yaya.callSDK("login", {
		"seq",
		tostring(roomID)
	})
end

function yaya.logout()
	yaya.reset()
	yaya.callSDK("logout")
end

function yaya.sendText(text, gamedata)
	yaya.callSDK("sendText", {
		"text",
		text
	}, {
		"gamedata",
		tostring(gamedata)
	})
end

function yaya.mic(ison, gamedata)
	yaya.callSDK("mic", {
		"ison",
		ison
	}, {
		"gamedata",
		tostring(gamedata)
	})
end

function yaya.setMode(mode)
	yaya.callSDK("setMicMode", {
		"mode",
		mode
	}, {
		sign = "(I)V"
	})
end

function yaya.uploadVoice(path, dur, expand)
	yaya.callSDK("uploadVoiceAndTranslate", {
		"path",
		path
	}, {
		"dur",
		dur
	}, {
		"expand",
		expand
	}, {
		"retainTime",
		8
	})
end

function yaya.uploadPic(path, size, msgID)
	yaya.callSDK("uploadPic", {
		"path",
		path
	}, {
		"size",
		size
	}, {
		"msgID",
		msgID
	}, {
		"retainTime",
		8
	}, {
		"filetype",
		"jpg"
	})
end

function yaya.callSDK(methodName, ...)
	if device.platform == "ios" then
		local params = {
			type = methodName .. ":"
		}
		local t = {
			...
		}

		for i, v in ipairs(t) do
			if v.sign then
				break
			end

			params[v[1]] = v[2]
		end

		if not luaoc.callStaticMethod("yayaSDK", "call", params) then
			print("yaya.callSDK call err. ->", methodName, ...)
		end

		dump(params)
	elseif device.platform == "android" then
		local params = {}
		local t = {
			...
		}
		local sign = nil

		for i, v in ipairs(t) do
			if v.sign then
				sign = v.sign

				break
			end

			params[#params + 1] = v[2]
		end

		dump(params)

		if not luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "yayaSDK", methodName, params, sign) then
			print("yaya.callSDK call err. ->", methodName, ...)
		end
	end
end

function yaya.call_initEnd(dic)
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
	local gamedata = dic.gamedata
end

function yaya.call_sendTextErr(dic)
	local result = dic.result
	local msg = dic.msg
	local gamedata = dic.gamedata

	if gamedata then
		-- Nothing
	end
end

function yaya.call_textNotify(dic)
	local roomID = dic.roomID
	local text = dic.text
	local gamedata = dic.gameData
	local time = dic.time
	local yunvaid = dic.yunvaid
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
	voice.uploadEnd(dic.result, dic.errMsg, dic.url, dic.text, dic.dur, dic.expand)
end

function yaya.call_uploadPicEnd(dic)
	pic.uploadEnd(dic.result, dic.errMsg, dic.url)
end

function yaya_callback(dic)
	if isAndroid then
		local dicstr = dic
		dic = json.decode(dicstr)

		if not dic then
			printError("yaya_callback decode err. ->[%s]", dicstr)

			return
		end
	end

	dump(dic)

	if yaya["call_" .. dic.type] then
		yaya["call_" .. dic.type](dic)
	end

	yaya.call(dic.type, dic)
end

return yaya
