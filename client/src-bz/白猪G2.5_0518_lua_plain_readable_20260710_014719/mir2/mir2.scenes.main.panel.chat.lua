local chat = require("mir2.scenes.main.panel.chatNew")
local chat2 = require("mir2.scenes.main.panel.chatOld")

if def.openChatLeftPanel then
	return chat
else
	return chat2
end
