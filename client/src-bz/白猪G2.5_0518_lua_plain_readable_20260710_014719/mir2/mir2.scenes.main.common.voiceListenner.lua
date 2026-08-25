local common = import(".common")
local voiceListenner = {}

function voiceListenner.onRecordEnd(ok, record)
	if not ok then
		main_scene.ui:tip(record)

		return
	end
end

function voiceListenner.onRecordTimeout()
	if main_scene.ui.voiceTip then
		main_scene.ui.voiceTip:upt("ok")
	end

	if main_scene.ui.console:get("chat") and main_scene.ui.console:get("chat").input.voiceBtn then
		main_scene.ui.console:get("chat").input.voiceBtn.recording = nil
	end

	if main_scene.ui.panels.chat and main_scene.ui.panels.chat.input.voiceBtn then
		main_scene.ui.panels.chat.input.voiceBtn.recording = nil
	end
end

function voiceListenner.onUploadEnd(result, errMsg, text, url, dur, msgID)
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
end

function voiceListenner.onStartPlay(msgID, channel)
	common.uptVoiceMsgState(msgID, channel, "start")

	local msg = g_data.chat:getMsgWithMsgID(msgID, "voice")

	if msg then
		main_scene.ui.console:call("chat", "showSayer", msg)

		if main_scene.ui.panels.chat then
			main_scene.ui.panels.chat:showSayer(msg)
		end
	end
end

function voiceListenner.onStopPlay(msgID, channel)
	common.uptVoiceMsgState(msgID, channel, "stop")
	main_scene.ui.console:call("chat", "hideSayer", msg)

	if main_scene.ui.panels.chat then
		main_scene.ui.panels.chat:hideSayer()
	end

	local hasAuto

	for k, v in pairs(g_data.setting.chat.autoPlayVoice) do
		if v then
			hasAuto = true

			break
		end
	end

	if not hasAuto then
		return
	end

	local finded

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
end

function voiceListenner.onDownloading(msgID, channel)
	common.uptVoiceMsgState(msgID, channel, "loading")
end

function voiceListenner.onDownloadEnd(msgID, channel, result)
	common.uptVoiceMsgState(msgID, channel, result and "loadOk" or "loadErr")
end

function voiceListenner.onPlayStartSound()
	audio.playSound(sound.root .. "104" .. sound.suffix)
end

function voiceListenner.onPlayEndSound()
	audio.playSound(sound.root .. "104" .. sound.suffix)
end

return voiceListenner
