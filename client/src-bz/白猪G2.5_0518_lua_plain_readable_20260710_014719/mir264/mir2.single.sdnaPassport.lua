local sdnaPassport = {
	appid = "4"
}

function sdnaPassport.setListenner(listenner)
	sdnaPassport.listenner = listenner
end

function sdnaPassport.removeListenner()
	sdnaPassport.listenner = nil
end

function sdnaPassport.call(key, ...)
	if sdnaPassport.listenner and sdnaPassport.listenner[key] then
		sdnaPassport.listenner[key](sdnaPassport.listenner, ...)
	end
end

function sdnaPassport.init()
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("sndaPassportSDK", "call", {
			type = "initSDK:",
			appid = sdnaPassport.appid,
			callback = function(dic)
				sdnaPassport.call("sdnaInitEnd", dic.code, dic.msg)
			end
		})
	elseif device.platform == "android" then
		luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "sndaPassportSDK", "initSDK", {
			sdnaPassport.appid,
			function(msg)
				local dic = json.decode(msg)

				sdnaPassport.call("sdnaInitEnd", dic.code, dic.msg)
			end
		})
	end
end

function sdnaPassport.login()
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("sndaPassportSDK", "call", {
			type = "login:",
			areaid = tostring(def.areaID),
			callback = function(dic)
				sdnaPassport.call("sdnaLoginEnd", dic.code, dic.msg, dic.ticket, dic.userid)
			end
		})
	elseif device.platform == "android" then
		luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "sndaPassportSDK", "login", {
			tostring(def.areaID),
			function(msg)
				local dic = json.decode(msg)

				sdnaPassport.call("sdnaLoginEnd", dic.code, dic.msg, dic.ticket, dic.userid)
			end
		})
	end
end

function sdnaPassport.logout()
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("sndaPassportSDK", "call", {
			type = "loginOut:",
			callback = function(dic)
				sdnaPassport.call("sdnaLogoutEnd", dic.code, dic.msg)
			end
		})
	elseif device.platform == "android" then
		luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "sndaPassportSDK", "logout", {
			function(msg)
				local dic = json.decode(msg)

				sdnaPassport.call("sdnaLogoutEnd", dic.code, dic.msg)
			end
		})
	end
end

function sdnaPassport.getTicket()
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("sndaPassportSDK", "call", {
			type = "getTicket:",
			appid = sdnaPassport.appid,
			areaid = tostring(def.areaID),
			callback = function(dic)
				sdnaPassport.call("sdnaGetTicketEnd", dic.code, dic.msg, dic.ticket)
			end
		})
	elseif device.platform == "android" then
		luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "sndaPassportSDK", "getTicket", {
			tostring(def.areaID),
			function(msg)
				local dic = json.decode(msg)

				sdnaPassport.call("sdnaGetTicketEnd", dic.code, dic.msg, dic.ticket)
			end
		})
	end
end

return sdnaPassport
