local sconfig = {
	deathColor = 0,
	allowMaxLevel = 999
}

function sconfig:set(msg, body)
	self.deathColor = math.min(Lobyte(msg.param), 8)
end

return sconfig
