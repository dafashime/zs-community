local c = cc
local Scene = c.Scene

function Scene:setAutoCleanupEnabled()
	self:addNodeEventListener(c.NODE_EVENT, function (event)
		if event.name == "exit" and self.autoCleanupImages_ then
			for imageName, v in pairs(self.autoCleanupImages_) do
				display.removeSpriteFrameByImageName(imageName)
			end

			self.autoCleanupImages_ = nil
		end
	end)
end

function Scene:markAutoCleanupImage(imageName)
	if not self.autoCleanupImages_ then
		self.autoCleanupImages_ = {}
	end

	self.autoCleanupImages_[imageName] = true

	return self
end
