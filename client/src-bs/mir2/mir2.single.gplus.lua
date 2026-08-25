local gplus = {
	phone,
	userid,
	ticket,
	appid = "791000255"
}

function gplus.setListenner(listenner)
	gplus.listenner = listenner
end

function gplus.removeListenner()
	gplus.listenner = nil
end

function gplus.call(key, ...)
end

function gplus.init()
	if device.platform == "ios" then
		-- Nothing
	elseif device.platform == "android" then
		-- Nothing
	end
end

function gplus.login()
end

function gplus.logout()
end

function gplus.getTicket()
end

function gplus.pay(productid, gameOrderId, extendInfo)
end

function gplus.extendFunction(func, parameter)
end

return gplus
