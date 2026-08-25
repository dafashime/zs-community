import("mir2.scenes.main.rocker.single")
local credit = {
	isAuthen = false
}

function credit:setAuthen(msg)
	local slot2 = msg.recog
	slot2 = slot2 == 0
	self.isAuthen = slot2
end

return credit