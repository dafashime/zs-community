jpush = {}

function jpush.init()
	local listener = cc.EventListenerCustom:create("JPUSH_EVENT", jpush.onJPushEvent)

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

	jpush.inited = true

	jpush.initSDK()
end

function jpush.onJPushEvent(event)
	local str = event:getDataString()
	local ret = json.decode(str)

	if not ret then
		print("onJPushEvent :dataString is not a valid JSONString", str)

		return
	end

	print("JPUSH EVENT:", ret.action)

	if ret.action == "REGISTRATION_ID" then
		jpush.regId = ret.regId
	elseif ret.action == "MESSAGE_RECEIVED" then
		-- Nothing
	elseif ret.action == "NOTIFICATION_RECEIVED" then
		-- Nothing
	elseif ret.action == "NOTIFICATION_OPENED" then
		-- Nothing
	elseif ret.action == "RICHPUSH_CALLBACK" then
		-- Nothing
	elseif ret.action == "CONNECTION_CHANGE" then
		-- Nothing
	elseif ret.action == "UNKNOW" then
		-- Nothing
	elseif ret.action == "gotSetAliasAndTagsResult" then
		jpush.tags = jpush.str2tags(ret.tags)
	end
end

function jpush.tags2str(tags)
	local tagStr = ""

	for k, v in pairs(tags) do
		if tagStr == "" then
			tagStr = v
		else
			tagStr = string.format("%s,%s", tostring(tagStr), tostring(v))
		end
	end

	return tagStr
end

function jpush.str2tags(str)
	if str and string.find(str, ",") then
		return string.split(str, ",")
	else
		return {
			str
		}
	end
end

function jpush.test()
	dump(jpush.str2tags(nil))
	dump(jpush.str2tags(""))
	dump(jpush.str2tags("123"))
	dump(jpush.str2tags("123,23,52"))

	local tags2str = jpush.tags2str

	print(tags2str({}))
	print(tags2str({
		"123",
		13,
		1,
		4
	}))
	print(tags2str({
		"123",
		"13,1,4",
		"3333",
		"123"
	}))
end

local IGNORE_JPUSH = true

if device.platform == "android" and not IGNORE_JPUSH then
	jpush.jClassName = ANDROID_PACKAGE_NAME .. "jpushSDK"

	function jpush.initSDK()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "ready", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.stopPush()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "stopPush", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.resumePush()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "resumePush", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.isPushStopped()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "isPushStopped", {}, "()Z")

		if not ok then
			print(ok, ret)
		end

		return ok, ret
	end

	function jpush.setAliasAndTags(alias, tags)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "setAliasAndTags", {
			alias,
			tags
		}, "(Ljava/lang/String;Ljava/lang/String;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.setAlias(alias)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "setAlias", {
			alias
		}, "(Ljava/lang/String;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.setTags(tags)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "setTags", {
			tags
		}, "(Ljava/lang/String;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.filterValidTags(tags)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "filterValidTags", {
			tags
		}, "(Ljava/lang/String;)Ljava/lang/String")

		if not ok then
			print(ok, ret)
		end

		return jpush.str2tags(ret)
	end

	function jpush.getRegistrationID()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "getRegistrationID", {}, "()Ljava/lang/String")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.clearAllNotifications()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "clearAllNotifications", {}, "(Ljava/lang/String;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.clearNotificationById(notificationId)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "clearNotificationById", {
			notificationId
		}, "(I;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.setPushTime(weekDays, startHour, endHour)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "setPushTime", {
			weekDays,
			startHour,
			endHour
		}, "(Ljava/lang/String;I;I;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.setSilenceTime(startHour, startMinute, endHour, endMinute)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "setSilenceTime", {
			startHour,
			startMinute,
			endHour,
			endMinute
		}, "(I;I;I;I;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.setLatestNotificationNumber(num)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "setLatestNotificationNumber", {
			num
		}, "(I;)V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.requestPermission()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "requestPermission", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.stopCrashHandler()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "stopCrashHandler", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.initCrashHandler()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "initCrashHandler", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok
	end

	function jpush.getConnectionState()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "getConnectionState", {}, "()Z")

		if not ok then
			print(ok, ret)
		end

		return ok, ret
	end

	function jpush.addLocalNotification(notificationId, title, content, extras, broadCastTime)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "addLocalNotification", {
			notificationId,
			title,
			content,
			extras,
			broadCastTime
		}, "(J;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)Z")

		if not ok then
			print(ok, ret)
		end

		return ok, ret
	end

	function jpush.removeLocalNotification(notificationId)
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "removeLocalNotification", {
			notificationId
		}, "(I;)V")

		if not ok then
			print(ok, ret)
		end

		return ok, ret
	end

	function jpush.clearLocalNotifications()
		local ok, ret = luaj.callStaticMethod(jpush.jClassName, "clearLocalNotifications", {}, "()V")

		if not ok then
			print(ok, ret)
		end

		return ok, ret
	end
elseif device.platform == "ios" and not IGNORE_JPUSH then
	function jpush.initSDK()
		local ok, ret = luaoc.callStaticMethod("JPush", "ready")
	end

	function jpush.stopPush()
	end

	function jpush.resumePush()
	end

	function jpush.isPushStopped()
	end

	function jpush.setAliasAndTags(alias, tags)
		local ok, ret = luaoc.callStaticMethod("JPush", "setAliasAndTags", {
			alias = alias,
			tags = tags
		})
	end

	function jpush.setAlias(alias)
		jpush.setAliasAndTags(alias)
	end

	function jpush.setTags(tags)
		jpush.setAliasAndTags(nil, tags)
	end

	function jpush.filterValidTags(tags)
		for k, v in pairs(tags) do
			tags[k] = nil
			tags[tostring(k)] = v
		end

		local ok, ret = luaoc.callStaticMethod("JPush", "filterValidTags", tags)

		if ok then
			return jpush.str2tags(ret)
		end
	end

	function jpush.getRegistrationID()
		local ok, ret = luaoc.callStaticMethod("JPush", "getRegistrationID")

		if ok then
			return ret
		end
	end

	function jpush.clearAllNotifications()
	end

	function jpush.clearNotificationById()
	end

	function jpush.setPushTime()
	end

	function jpush.setSilenceTime()
	end

	function jpush.setLatestNotificationNumber()
	end

	function jpush.requestPermission()
	end

	function jpush.stopCrashHandler()
	end

	function jpush.initCrashHandler()
	end

	function jpush.getConnectionState()
	end

	function jpush.addLocalNotification()
	end

	function jpush.removeLocalNotification()
	end

	function jpush.clearLocalNotifications()
	end
else
	function jpush.initSDK()
	end

	function jpush.stopPush()
	end

	function jpush.resumePush()
	end

	function jpush.isPushStopped()
	end

	function jpush.setAliasAndTags()
	end

	function jpush.setAlias()
	end

	function jpush.setTags()
	end

	function jpush.filterValidTags()
	end

	function jpush.getRegistrationID()
	end

	function jpush.clearAllNotifications()
	end

	function jpush.clearNotificationById()
	end

	function jpush.setPushTime()
	end

	function jpush.setSilenceTime()
	end

	function jpush.setLatestNotificationNumber()
	end

	function jpush.requestPermission()
	end

	function jpush.stopCrashHandler()
	end

	function jpush.initCrashHandler()
	end

	function jpush.getConnectionState()
	end

	function jpush.addLocalNotification()
	end

	function jpush.removeLocalNotification()
	end

	function jpush.clearLocalNotifications()
	end
end

return jpush
