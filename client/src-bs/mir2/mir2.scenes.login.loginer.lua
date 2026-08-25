local cls = class("loginer")

function cls:ctor(uuid)
	self.ip = nil
	self.host = nil
	self.uuid = uuid
end

function cls:_getXhr()
	if self.xhr then
		self.xhr:release()

		self.xhr = nil
	end

	local xhr = cc.XMLHttpRequest:new()

	xhr:registerScriptHandler(handler(self, self.onReadyStateChange))
	xhr:retain()

	self.xhr = xhr

	return xhr
end

function cls:destroy()
	if self.xhr then
		self.xhr:release()

		self.xhr = nil
	end
end

function cls:selectServer(ip, port)
	self.ip = ip
	self.port = port
	local url = string.format("http://%s:%s/", ip, port)
	self.serverUrl = url
end

function cls:genUrl(operator, data)
	local url = self.serverUrl .. operator
	local s = "?"

	for k, v in pairs(data or {}) do
		url = string.format("%s%s%s", url, s, k .. "=" .. v)
		s = "&"
	end

	return url
end

function cls:send_(op, params, reqfunc)
	local xhr = self:_getXhr()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	reqfunc = reqfunc or "GET"
	local url, body = nil

	if reqfunc == "GET" then
		url = self:genUrl(op, params)
	else
		url = self:genUrl(op)
	end

	print(url)

	local req = network.createHTTPRequest(handler(self, self.onRequestEvent), url, reqfunc)

	if reqfunc == "POST" then
		for k, v in pairs(params) do
			req:addPOSTValue(k, v)
		end
	end

	print("#####################")
	print(reqfunc)
	req:start()
end

function cls:send(op, params, reqfunc, ex)
	print(ex)

	if self.sending then
		return
	end

	self.retry = 3

	self:send_(op, params, reqfunc)

	self.sending = {
		op,
		params,
		reqfunc,
		ex
	}
end

function cls:onRequestEvent(event)
	local ok = event.name == "completed"
	local request = event.request

	if event.name == "progress" then
		return
	end

	print("onRequestEvent", event.name)

	local code = ok and request:getResponseStatusCode()

	if ok and code >= 200 and code <= 300 then
		local response = request:getResponseString()

		print(response)
		print("response:\n", response)

		local r = json.decode(response)

		if r then
			dump(self.sending[4])
			self:onEvt(r.code, r.des, r, self.sending[4])
		else
			print("decode faild!")
		end
	elseif self.retry > 0 then
		print("network error", code)

		self.retry = self.retry - 1

		scheduler.performWithDelayGlobal(function ()
			self:send_(unpack(self.sending))
		end, 0.5 * math.pow(1.4, 3 - self.retry))

		return
	else
		self:onEvt(request:getErrorCode(), request:getErrorMessage())
	end

	self.sending = false
end

function cls:bind(acc, psw, code)
	self:send("bind", {
		id = acc,
		psw = psw,
		safecode = code,
		machineid = self.uuid
	})
end

function cls:register(acc, psw, safecode)
	self:send("reg", {
		id = acc,
		psw = psw,
		safecode = safecode
	})
end

function cls:chgPsw(acc, psw, safecode)
	self:send("modifypsw", {
		id = acc,
		psw = psw,
		safecode = safecode
	})
end

function cls:login(acc, psw, guest)
	if guest then
		print("guest", self.uuid)
		self:send("account", {
			guest = 1,
			id = self.uuid
		})
	else
		print(id, psw)
		self:send("account", {
			id = acc,
			psw = psw
		})
	end
end

function cls:verifyReceipt(gameorderid, productid, iosreceipt, extend, transaction_id, identify)
	print("verifyReceipt", identify)
	self:send("paycb", {
		productid = productid,
		gameorderid = gameorderid,
		iosreceipt = iosreceipt,
		extend = extend,
		tid = transaction_id
	}, "POST", identify)
end

function cls:setEvtListener(obj)
	print("setEvtListener", obj and obj.onCetSvrEvt)

	self.evtListener = obj

	assert(obj and obj.onCetSvrEvt, "should imp onLoginEvt")
end

function cls:onEvt(code, desc, res, ex)
	print("onEvt", self.evtListener)

	if self.evtListener then
		local evtListener = self.evtListener

		evtListener:onCetSvrEvt(code, desc, res, ex)
	end
end

return cls
