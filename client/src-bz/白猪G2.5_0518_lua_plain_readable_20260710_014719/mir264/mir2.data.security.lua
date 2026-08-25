local security = {}

function security:setLoginBit(msg, buf, buflen)
	if not msg then
		self.loginBit = nil
	else
		self.loginBit = net.strSplitWithLen(buf, 1, 4)
	end
end

function security:setEquipBit(bit)
	self.equipBit = bit
end

return security
