local device = {
	platform = "unknown",
	model = "unknown"
}
local sharedApplication = cc.Application:getInstance()
local target = sharedApplication:getTargetPlatform()

if target == cc.PLATFORM_OS_WINDOWS then
	device.platform = "windows"
elseif target == cc.PLATFORM_OS_MAC then
	device.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
	device.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
	device.platform = "ios"

	if target == cc.PLATFORM_OS_IPHONE then
		device.model = "iphone"
	else
		device.model = "ipad"
	end
end

local language_ = sharedApplication:getCurrentLanguage()

if language_ == cc.LANGUAGE_CHINESE then
	language_ = "cn"
elseif language_ == cc.LANGUAGE_FRENCH then
	language_ = "fr"
elseif language_ == cc.LANGUAGE_ITALIAN then
	language_ = "it"
elseif language_ == cc.LANGUAGE_GERMAN then
	language_ = "gr"
elseif language_ == cc.LANGUAGE_SPANISH then
	language_ = "sp"
elseif language_ == cc.LANGUAGE_RUSSIAN then
	language_ = "ru"
elseif language_ == cc.LANGUAGE_KOREAN then
	language_ = "kr"
elseif language_ == cc.LANGUAGE_JAPANESE then
	language_ = "jp"
elseif language_ == cc.LANGUAGE_HUNGARIAN then
	language_ = "hu"
elseif language_ == cc.LANGUAGE_PORTUGUESE then
	language_ = "pt"
elseif language_ == cc.LANGUAGE_ARABIC then
	language_ = "ar"
else
	language_ = "en"
end

device.language = language_
device.writablePath = cc.FileUtils:getInstance():getWritablePath()
device.directorySeparator = "/"
device.pathSeparator = ":"

if device.platform == "windows" then
	device.directorySeparator = "\\"
	device.pathSeparator = ";"
end

printInfo("# device.platform              = " .. device.platform)
printInfo("# device.model                 = " .. device.model)
printInfo("# device.language              = " .. device.language)
printInfo("# device.writablePath          = " .. device.writablePath)
printInfo("# device.directorySeparator    = " .. device.directorySeparator)
printInfo("# device.pathSeparator         = " .. device.pathSeparator)
printInfo("#")

function device.showActivityIndicator()
	if DEBUG > 1 then
		printInfo("device.showActivityIndicator()")
	end

	cc.Native:showActivityIndicator()
end

function device.hideActivityIndicator()
	if DEBUG > 1 then
		printInfo("device.hideActivityIndicator()")
	end

	cc.Native:hideActivityIndicator()
end

function device.showAlert(title, message, buttonLabels, listener)
	if type(buttonLabels) ~= "table" then
		buttonLabels = {
			tostring(buttonLabels)
		}
	else
		table.map(buttonLabels, function (v)
			return tostring(v)
		end)
	end

	if DEBUG > 1 then
		printInfo("device.showAlert() - title: %s", title)
		printInfo("    message: %s", message)
		printInfo("    buttonLabels: %s", table.concat(buttonLabels, ", "))
	end

	if device.platform == "android" then
		local function tempListner(event)
			if type(event) == "string" then
				event = require("framework.json").decode(event)
				event.buttonIndex = tonumber(event.buttonIndex)
			end

			if listener then
				listener(event)
			end
		end

		luaj.callStaticMethod("org/cocos2dx/utils/PSNative", "createAlert", {
			title,
			message,
			buttonLabels,
			tempListner
		}, "(Ljava/lang/String;Ljava/lang/String;Ljava/util/Vector;I)V")
	else
		local defaultLabel = ""

		if #buttonLabels > 0 then
			defaultLabel = buttonLabels[1]

			table.remove(buttonLabels, 1)
		end

		cc.Native:createAlert(title, message, defaultLabel)

		for i, label in ipairs(buttonLabels) do
			cc.Native:addAlertButton(label)
		end

		if type(listener) ~= "function" then
			function listener()
			end
		end

		cc.Native:showAlert(listener)
	end
end

function device.cancelAlert()
	if DEBUG > 1 then
		printInfo("device.cancelAlert()")
	end

	cc.Native:cancelAlert()
end

function device.getOpenUDID()
	local ret = cc.Native:getOpenUDID()

	if DEBUG > 1 then
		printInfo("device.getOpenUDID() - Open UDID: %s", tostring(ret))
	end

	return ret
end

function device.openURL(url)
	if DEBUG > 1 then
		printInfo("device.openURL() - url: %s", tostring(url))
	end

	cc.Native:openURL(url)
end

function device.showInputBox(title, message, defaultValue)
	title = tostring(title or "INPUT TEXT")
	message = tostring(message or "INPUT TEXT, CLICK OK BUTTON")
	defaultValue = tostring(defaultValue or "")

	if DEBUG > 1 then
		printInfo("device.showInputBox() - title: %s", tostring(title))
		printInfo("    message: %s", tostring(message))
		printInfo("    defaultValue: %s", tostring(defaultValue))
	end

	return cc.Native:getInputText(title, message, defaultValue)
end

return device
