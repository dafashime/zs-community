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
	return
end

function gplus.init()
	if device.platform == "ios" then
		-- block empty
	elseif device.platform == "android" then
		-- block empty
	end
end

function gplus.login()
	return
end

function gplus.logout()
	return
end

function gplus.getTicket()
	return
end

function gplus.pay(productid, gameOrderId, extendInfo)
	return
end

function gplus.extendFunction(func, parameter)
	return
end

return gplus
