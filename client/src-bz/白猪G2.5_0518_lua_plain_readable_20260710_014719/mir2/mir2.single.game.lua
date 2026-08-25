local current = ...

import("mir2.bz.functions")

local game = {
	deviceInfo,
	loopBegin,
	sourceSize
}

function game.init()
	game.sourceSize = display.size

	if display.width < 960 then
		CONFIG_SCREEN_WIDTH = 960
		CONFIG_SCREEN_HEIGHT = 640

		local sharedDirector = cc.Director:getInstance()
		local glview = sharedDirector:getOpenGLView()
		local size = glview:getFrameSize()

		display.sizeInPixels = {
			width = size.width,
			height = size.height
		}

		local w = display.sizeInPixels.width
		local h = display.sizeInPixels.height
		local scale = w / CONFIG_SCREEN_WIDTH, h / CONFIG_SCREEN_HEIGHT

		CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
		CONFIG_SCREEN_HEIGHT = h / scale

		glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)

		local winSize = sharedDirector:getWinSize()

		display.screenScale = 2
		display.contentScaleFactor = scale
		display.size = {
			width = winSize.width,
			height = winSize.height
		}
		display.width = display.size.width
		display.height = display.size.height
		display.cx = display.width / 2
		display.cy = display.height / 2
		display.c_left = -display.width / 2
		display.c_right = display.width / 2
		display.c_top = display.height / 2
		display.c_bottom = -display.height / 2
		display.left = 0
		display.right = display.width
		display.top = display.height
		display.bottom = 0
		display.widthInPixels = display.sizeInPixels.width
		display.heightInPixels = display.sizeInPixels.height

		printInfo(string.format("# CONFIG_SCREEN_AUTOSCALE      = %s", CONFIG_SCREEN_AUTOSCALE))
		printInfo(string.format("# CONFIG_SCREEN_WIDTH          = %0.2f", CONFIG_SCREEN_WIDTH))
		printInfo(string.format("# CONFIG_SCREEN_HEIGHT         = %0.2f", CONFIG_SCREEN_HEIGHT))
		printInfo(string.format("# display.widthInPixels        = %0.2f", display.widthInPixels))
		printInfo(string.format("# display.heightInPixels       = %0.2f", display.heightInPixels))
		printInfo(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
		printInfo(string.format("# display.width                = %0.2f", display.width))
		printInfo(string.format("# display.height               = %0.2f", display.height))
		printInfo(string.format("# display.cx                   = %0.2f", display.cx))
		printInfo(string.format("# display.cy                   = %0.2f", display.cy))
		printInfo(string.format("# display.left                 = %0.2f", display.left))
		printInfo(string.format("# display.right                = %0.2f", display.right))
		printInfo(string.format("# display.top                  = %0.2f", display.top))
		printInfo(string.format("# display.bottom               = %0.2f", display.bottom))
		printInfo(string.format("# display.c_left               = %0.2f", display.c_left))
		printInfo(string.format("# display.c_right              = %0.2f", display.c_right))
		printInfo(string.format("# display.c_top                = %0.2f", display.c_top))
		printInfo(string.format("# display.c_bottom             = %0.2f", display.c_bottom))
		printInfo("#")
	end

	if device.platform == "mac" then
		luaoc = require(cc.PACKAGE_NAME .. ".luaoc")
	end

	if not BZ_VERSION and device.platform == "android" then
		if not luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "startFilterConnectivityAction", {}, "()V") then
			p2("warnning", "startFilterConnectivityAction faild")
		end

		if not luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "startFilterBatteryAction", {}, "()V") then
			p2("warnning", "startFilterBatteryAction faild")
		end
	end

	function _G.MAIN_LOOP_BEGIN()
		game.loopBegin = socket.gettime()
	end

	if device.platform == "windows" then
		scheduler.scheduleUpdateGlobal(function()
			_G.MAIN_LOOP_BEGIN()
		end)
	end

	cc.FileUtils:getInstance():purgeCachedEntries()
	math.randomseed(os.time())
	cc.Director:getInstance():setAnimationInterval(0.016666666666666666)

	display.DEFAULT_TTF_FONT = def.font
	display.DEFAULT_TTF_FONT_SIZE = def.fontSize or 16

	jpush.init()
	an.msgbox.init({
		inputListBgScale = 1,
		contentLabelSize = 20,
		btny = 13,
		btnAlignStyle = "center",
		btnLabelSize = 20,
		bg = res.gettex2("pic/common/msgbox.png"),
		confirm = res.gettex2("pic/common/btn20.png"),
		confirm2 = res.gettex2("pic/common/btn21.png"),
		confirmText = res.gettex2("pic/common/confirm.png"),
		cancel = res.gettex2("pic/common/btn20.png"),
		cancel2 = res.gettex2("pic/common/btn21.png"),
		cancelText = res.gettex2("pic/common/cancel.png"),
		close = res.gettex2("pic/common/close10.png"),
		close2 = res.gettex2("pic/common/close11.png"),
		title = res.gettex2("pic/common/msgtitle.png"),
		titlepos = cc.p(210, 269),
		inputListBg = res.gettex2("pic/console/guessbg.png"),
		sound = sound.root .. "104" .. sound.suffix,
		content = {
			w = 370,
			x = 25,
			h = 150,
			y = 74
		},
		btnColor = def.colors.btn20,
		btnSColor = def.colors.btn20s
	})
	an.voiceBubble.init({
		bg = {
			附近 = res.gettex2("pic/scale/msg1.png"),
			喊话 = res.gettex2("pic/scale/msg2.png"),
			组队 = res.gettex2("pic/scale/msg3.png"),
			行会 = res.gettex2("pic/scale/msg4.png"),
			私聊self = res.gettex2("pic/scale/msg5.png"),
			私聊 = res.gettex2("pic/scale/msg6.png"),
			default = res.gettex2("pic/scale/msg7.png")
		},
		hornAni = res.getani2("pic/voice/play%d.png", 1, 3, 0.2),
		loadingAni = res.getani2("pic/effect/loading/%d.png", 1, 12, 0.06),
		errTex = res.gettex2("pic/voice/err.png"),
		unreadTex = res.gettex2("pic/voice/unread.png")
	})
	cache.checkAll()

	if cache.cgCheckFirstIn() then
		local scene = display.newScene("CGScene")
		local entered = false

		function scene:onEnterTransitionFinish()
			game.gotoscene("login")
		end

		display.replaceScene(scene, "fade", 0.2)
	else
		local value
		local s = require("upt.scene").new(function()
			game.gotoscene("bz", {
				logout = false
			}, "crossFade", 0.2)
		end, true)

		display.replaceScene(s)
	end
end

function game.gotoscene(name, params, ...)
	display.replaceScene(import("..scenes." .. name .. ".scene", current).new(params), ...)
end

function game.loadDeviceInfo()
	if game.deviceInfo then
		return game.deviceInfo
	end

	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("iosFuncs", "devicesInfo")

		if ok and ret then
			game.deviceInfo = json.decode(ret)
		end
	elseif def.openBettery and device.platform == "android" then
		local ok2, ret2 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "DeviceUtil", "getJsonDeviceInfo", {}, "()Ljava/lang/String;")

		if ok2 and ret2 then
			game.deviceInfo = json.decode(ret2)
		end
	end

	game.deviceInfo = game.deviceInfo or {}
	game.deviceInfo._platform = device.platform

	return game.deviceInfo
end

function game.initLoginer(cls, ...)
	if not game.loginer then
		game.loginer = cls.new(...)
	end

	return game.loginer
end

return game
