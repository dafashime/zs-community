local open = require("mir2.scenes.main.panel.storage8")
local storage = require("mir2.scenes.main.panel.storage9")

if def.openBigBag then
	return storage
else
	return open
end
