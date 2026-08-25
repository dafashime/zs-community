local CURRENT_MODULE_NAME = ...
cc.Registry = import(".Registry")
cc.GameObject = import(".GameObject")
cc.EventProxy = import(".EventProxy")
cc.Component = import(".components.Component")
local components = {
	"components.behavior.StateMachine",
	"components.behavior.EventProtocol",
	"components.ui.BasicLayoutProtocol",
	"components.ui.LayoutProtocol",
	"components.ui.DraggableProtocol"
}

for _, packageName in ipairs(components) do
	cc.Registry.add(import("." .. packageName, CURRENT_MODULE_NAME), packageName)
end

local GameObject = cc.GameObject
local ccmt = {
	__call = function (self, target)
		if target then
			return GameObject.extend(target)
		end

		printError("cc() - invalid target")
	end
}

setmetatable(cc, ccmt)

cc.mvc = import(".mvc.init")
cc.ui = import(".ui.init")
cc.uiloader = import(".uiloader.init")
