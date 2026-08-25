local self = require("mir2.scenes.main.panel.bag8")
local bag = require("mir2.scenes.main.panel.bag9")

if def.openBigBag then
	return bag
else
	return self
end
