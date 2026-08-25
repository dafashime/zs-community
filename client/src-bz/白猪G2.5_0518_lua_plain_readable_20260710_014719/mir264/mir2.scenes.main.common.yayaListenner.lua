local common = import(".common")
local yayaListenner = {}

function yayaListenner.authEnd(dic)
	return
end

function yayaListenner.loginEnd(dic)
	main_scene.ui.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
end

function yayaListenner.micEnd(dic)
	if result ~= 0 then
		main_scene.ui:tip(dic.msg or "")
	elseif dic.ison then
		main_scene.ui:tip("上麦成功, 你现在可以说话了...")
	end

	main_scene.ui.console:call("btnVoiceJIT", "voice_call", "setSaying", yaya.isonMic)
end

function yayaListenner.micModeEnd(dic)
	main_scene.ui.console:call("btnVoiceJIT", "voice_call", "loadingCheck")
end

function yayaListenner.micModeNotify(dic)
	main_scene.ui.console:call("btnVoiceJIT", "voice_call", "loadingCheck")
end

function yayaListenner.realtimeVoice(dic)
	if main_scene.ui.panels.voice then
		main_scene.ui.panels.voice:addOnMicMember(dic.gamedata)
	end
end

function yayaListenner.realtimeVoiceErr(dic)
	main_scene.ui:tip("实时语音错误: " .. dic.msg)
end

return yayaListenner
