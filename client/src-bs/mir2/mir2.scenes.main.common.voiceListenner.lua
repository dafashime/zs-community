local common = import(".common")
local voiceListenner = {
	onRecordEnd = function (ok, record)
		if not ok then
			main_scene.ui:tip(record)

			return
		end
	end,
	onRecordTimeout = function ()
		if main_scene.ui.voiceTip then
			main_scene.ui.voiceTip:upt("ok")
		end

		if main_scene.ui.console:get("chat") and main_scene.ui.console:get("chat").input.voiceBtn then
			main_scene.ui.console:get("chat").input.voiceBtn.recording = nil
		end

		if main_scene.ui.panels.chat and main_scene.ui.panels.chat.input.voiceBtn then
			main_scene.ui.panels.chat.input.voiceBtn.recording = nil
		end
	end,
	onUploadEnd = function (result, errMsg, text, url, dur, msgID)
		if result ~= 0 then
			main_scene.ui:tip(errMsg)

			return
		end

		common.say({
			{
				common.encodeRich({
					type = "voice",
					text = text or "",
					url = url or "",
					dur = dur or 0,
					expand = msgID or ""
				})
			}
		})
	end,
	onStartPlay = function (msgID, channel)
		common.uptVoiceMsgState(msgID, channel, "start")

		local msg = g_data.chat:getMsgWithMsgID(msgID, "voice")

		if msg then
			main_scene.ui.console:call("chat", "showSayer", msg)

			if main_scene.ui.panels.chat then
				main_scene.ui.panels.chat:showSayer(msg)
			end
		end
	end,
	onStopPlay = function (msgID, channel)
		common.uptVoiceMsgState(msgID, channel, "stop")
		main_scene.ui.console:call("chat", "hideSayer", msg)

		if main_scene.ui.panels.chat then
			main_scene.ui.panels.chat:hideSayer()
		end

		local hasAuto = nil

		for k, v in pairs(g_data.setting.chat.autoPlayVoice) do
			if v then
				hasAuto = true

				break
			end
		end

		if not hasAuto then
			return
		end

		local finded = nil

		for i, v in ipairs(g_data.chat.msgs) do
			for i2, v2 in ipairs(v.data) do
				if v2.type == "voice" then
					if finded then
						if not v2.readed and g_data.setting.chat.autoPlayVoice[v.channel] then
							voice.autoPlay(v.user, v2.msgID, v.channel, v2.url, v2.dur)
						end
					else
						finded = v2.msgID == msgID
					end
				end
			end
		end
	end,
	onDownloading = function (msgID, channel)
		common.uptVoiceMsgState(msgID, channel, "loading")
	end,
	onDownloadEnd = function (msgID, channel, result)
		common.uptVoiceMsgState(msgID, channel, result and "loadOk" or "loadErr")
	end,
	onPlayStartSound = function ()
		audio.playSound(sound.root .. "104" .. sound.suffix)
	end,
	onPlayEndSound = function ()
		audio.playSound(sound.root .. "104" .. sound.suffix)
	end
}

return voiceListenner
