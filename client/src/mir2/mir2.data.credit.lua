local credit = {
	isAuthen = false
}

function credit:setAuthen(msg)
	self.isAuthen = msg.recog == 0
end

return credit
