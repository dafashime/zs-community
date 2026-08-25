local common = import(".common")
local yaya = require("mir2.single.yaya")

return {
	authEnd = function(dic)
		return
	end,
	loginEnd = function(dic)
		main_scene.ui.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
	end,
	micEnd = function(dic)
		if result ~= 0 then
			main_scene.ui:tip(dic.msg or "")
		elseif dic.ison then
			main_scene.ui:tip("上麦成功, 你现在可以说话了...")
		end

		main_scene.ui.console:call("btnVoiceJIT", "voice_call", "setSaying", yaya.isonMic)
	end,
	micModeEnd = function(dic)
		main_scene.ui.console:call("btnVoiceJIT", "voice_call", "loadingCheck")
	end,
	micModeNotify = function(dic)
		main_scene.ui.console:call("btnVoiceJIT", "voice_call", "loadingCheck")
	end,
	realtimeVoice = function(dic)
		if main_scene.ui.panels.voice then
			main_scene.ui.panels.voice:addOnMicMember(dic.gamedata)
		end
	end,
	realtimeVoiceErr = function(dic)
		main_scene.ui:tip("实时语音错误: " .. dic.msg)
	end
}
