local X8Check = {}
local text
local number = 15
local number2 = 10
local number3 = 8
local items = {
	speed = -1,
	timeOut = 1,
	initErr = 2,
	sendTimeLong = 3
}

PLUG_CHECK_DATA = PLUG_CHECK_DATA or {
	slowlyCount = 0
}

scheduler.scheduleGlobal(function()
	if PLUG_CHECK_DATA.serverTime then
		PLUG_CHECK_DATA.serverTime = PLUG_CHECK_DATA.serverTime + 1
	end
end, 1)

function X8Check.update(dt)
	return
end

function X8Check.verify(serverTime)
	if not PLUG_CHECK_DATA.inited then
		PLUG_CHECK_DATA.inited = true
		PLUG_CHECK_DATA.errCount = 0
		PLUG_CHECK_DATA.serverTime = serverTime
		text = "normal"

		return
	end

	local value = PLUG_CHECK_DATA.serverTime - serverTime

	if value < 0 then
		PLUG_CHECK_DATA.slowlyCount = PLUG_CHECK_DATA.slowlyCount + 1

		if PLUG_CHECK_DATA.slowlyCount > number2 then
			PLUG_CHECK_DATA.slowlyCount = 0
			PLUG_CHECK_DATA.inited = false

			return
		end
	end

	if value > number then
		print(value, "监测到疑似加速行为", PLUG_CHECK_DATA.errCount)

		PLUG_CHECK_DATA.errCount = PLUG_CHECK_DATA.errCount + 1

		if PLUG_CHECK_DATA.errCount > number3 then
			X8Check.kill("speed")
		end
	else
		PLUG_CHECK_DATA.errCount = 0
	end
end

function X8Check.iskilled()
	return text == "kill"
end

function X8Check:kill()
	if self == "speed" then
		an.newMsgbox("检测到你存在非法加速行为，有封号风险！\n你的行为服务器记录！", function()
			os.exit(0)
		end, {
			center = true,
			noTouchRemove = true
		})
	else
		an.newMsgbox("与服务器断开连接. (错误码: " .. items[self] .. ")", function()
			os.exit(0)
		end, {
			center = true,
			noTouchRemove = true
		})
	end

	if main_scene and main_scene.ground and main_scene.ground.player and main_scene.ground.player.info then
		def.role.call("@speeder~" .. main_scene.ground.player.info:getRealName())
	end

	def.role.autoRun(function()
		net.send({
			CM_SOFTCLOSE
		})
	end, 2)

	text = "kill"
end

return X8Check
