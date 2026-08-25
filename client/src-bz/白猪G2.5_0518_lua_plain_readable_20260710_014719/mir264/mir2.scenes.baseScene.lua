local baseScene = class("baseScene", function()
	return display.newNode()
end)

table.merge(baseScene, {})

function baseScene:onEnter()
	print("baseScene:onEnter")

	local lastNetState = network.getInternetConnectionStatus()
	local listener = cc.EventListenerCustom:create("CONNECTIVITY_ACTION", function()
		local currentState = network.getInternetConnectionStatus()

		print("CONNECTIVITY_ACTION", lastNetState, currentState)

		if lastNetState ~= currentState then
			if currentState == cc.kCCNetworkStatusNotReachable then
				lastNetState = 0

				self:onLoseConnect()
			else
				lastNetState = currentState

				self:onNetworkStateChange(currentState)
			end
		end
	end)

	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

	self.networkStatuListener = listener
end

function baseScene:onExit()
	self:getEventDispatcher():removeEventListener(self.networkStatuListener)
end

function baseScene:onLoseConnect()
	print("baseScene:onLoseConnect")
	assert(false, "should override me")
end

function baseScene:onNetworkStateChange()
	print("baseScene:onNetworkStateChange")
	assert(false, "should override me")
end

return baseScene
