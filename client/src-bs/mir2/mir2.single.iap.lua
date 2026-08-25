local iap = {
	productsIdentifies = {},
	curPurchaedVerifyData = {},
	cachedPaymentEvents = {}
}
local evt = {
	IOSIAP_PAYMENT_PURCHAED = 1,
	IOSIAP_PAYMENT_PURCHASING = 0,
	IOSIAP_PAYMENT_FAILED = 2,
	IOSIAP_PAYMENT_RESTORED = 3,
	IOSIAP_PAYMENT_REMOVED = 4
}

for k, v in pairs(evt) do
	evt[v] = k
end

local function encode2hex(str)
	assert(str, "encode2hex arg should be valid")

	local ret = ""

	for k = 1, string.len(str) do
		local t = string.byte(string.sub(str, k, k))
		ret = ret .. string.format("%02x", t)
	end

	return ret
end

local function decodeFromHex(str)
	assert(str, "decodeFromHex arg should be valid")

	local ret = ""

	for k = 1, string.len(str), 2 do
		local t = tonumber(string.sub(str, k, k + 1), 16)

		if t ~= nil then
			ret = ret .. string.char(t)
		end
	end

	return ret
end

local function en(temp)

	local str = crypto.encryptXXTEA(temp, "ec_umir2_payment")

	return encode2hex(str)
end

local function de(temp)

	local str = crypto.decryptXXTEA(decodeFromHex(temp), "ec_umir2_payment")

	return str
end

local function safeFunc(cb)
	local traceback = debug.traceback()

	return function (...)
		xpcall(cb, function (...)
			print(traceback)
			__G__TRACKBACK__(...)
		end, ...)
	end
end

local productsInfo = {
	{
		price = 6,
		name = "6元宝"
	},
	{
		price = 18,
		name = "18元宝"
	},
	{
		price = 28,
		name = "28元宝"
	},
	{
		price = 68,
		name = "68元宝"
	},
	{
		price = 100,
		name = "100元宝"
	},
	{
		price = 198,
		name = "198元宝"
	},
	{
		price = 328,
		name = "328元宝"
	},
	{
		price = 498,
		name = "498元宝"
	},
	{
		price = 648,
		name = "648元宝"
	}
}

function iap.init()
	game.loginer:setEvtListener(iap)

	if device.platform == "ios" then
		if not iap.inited then
			print("iap.init")

			local ok, ret = luaoc.callStaticMethod("IAP", "call", {
				type = "init:"
			})

			if ok then
				ok, ret = luaoc.callStaticMethod("IAP", "call", {
					type = "addCallbacks:",
					onRequestProductsFinish = safeFunc(iap.onRequestProductsFinish),
					onRequestProductsError = safeFunc(iap.onRequestProductsError),
					onPaymentEvent = safeFunc(iap.onPaymentEvent)
				})
			end

			iap.inited = ok
		end

		if #iap.productsIdentifies <= 0 then
			iap.updateValidProductsIdentifies()
		end

		iap.checkOleVerify()
	end
end

function iap.checkOleVerify()
	local data = iap.curPurchaedVerifyData[iap.roleIdentify]

	print("iap.checkOleVerify", data)
	dump(iap.curPurchaedVerifyData, iap.roleIdentify)

	if data then
		iap.onPurchaed(unpack(data))

		return data[1], data[2]
	end
end

function iap.paymentWithProduct(ident, quantity, order, extend, playername)
	local requestdata = en(json.encode({
		o = order,
		e = extend,
		id = iap.roleIdentify,
		name = playername
	}))

	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAP", "call", {
			type = "paymentWithProduct:",
			identifier = ident,
			quantity = quantity,
			requestData = requestdata
		})
	end
end

function iap.finishPayment(key)
	print(key)

	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAP", "call", {
			type = "finishPayment:",
			key = key
		})
	end
end

function iap.setEvtListener(l)
	print("iap.setEvtListener")

	iap.evtListener = l

	for k, v in pairs(iap.cachedPaymentEvents) do
		iap.onPaymentEvent(v)
	end

	iap.cachedPaymentEvents = {}
end

function iap.hasUnfinishPayment()
	local data = iap.curPurchaedVerifyData[iap.roleIdentify]

	if data then
		return data[1]
	end
end

function iap.updateValidProductsIdentifies()
	if iap.updatingProducts then
		return
	end

	iap.updatingProducts = true

	print("updateValidProductsIdentifies")

	for k, v in pairs(productsInfo) do
		v.identifier = "com.umir2.no1.YB" .. v.price
	end

	local identifies = {}

	for k, v in pairs(productsInfo) do
		table.insert(identifies, v.identifier)
	end

	iap.requestProducts(identifies)
end

function iap.getProductsInfo()
	local ret = {}

	for k, ident in pairs(iap.productsIdentifies) do
		for k, v in pairs(productsInfo) do
			if v.identifier == ident then
				table.insert(ret, v)
			end
		end
	end

	return ret
end

function iap.requestProducts(identifies)
	local ok, ret = luaoc.callStaticMethod("IAP", "call", {
		type = "requestProducts:",
		identifies = json.encode(identifies)
	})

	print(ok)
end

function iap.onRequestProductsFinish(ret)
	print("iap.onRequestProductsFinish")

	iap.updatingProducts = false
	iap.productsIdentifies = ret.validProducts

	iap.evtListener:onUpdatedProducts()
end

function iap.onRequestProductsError(data)
	local code = data.code
	iap.updatingProducts = false

	dump(code)
end

function iap.onPurchaed(order, identifier, receipt, extend, roleIdentify, transaction_id, playername)
	print("iap.onPurchead")

	if not roleIdentify then
		print("unknow target")
		iap.finishPayment(transaction_id)

		return
	end

	iap.curPurchaedVerifyData[roleIdentify] = {
		order,
		identifier,
		receipt,
		extend,
		roleIdentify,
		transaction_id,
		playername
	}

	if roleIdentify ~= iap.roleIdentify then
		print("不是当前玩家的订单")
		iap.evtListener:onVerifyFailed(1, "存在未完成的充值订单，所属玩家" .. (playername or "") .. "，请前往处理")

		return
	end

	if cache.check_verifiedTransaction(transaction_id) then
		print("订单已验证", transaction_id, roleIdentify)

		if roleIdentify == iap.roleIdentify then
			iap.notifyPurchaed(transaction_id, order, identifier, transaction_id)
		end
	else
		print("验证中:", transaction_id, roleIdentify)
		game.loginer:verifyReceipt(order, identifier, receipt, extend, transaction_id, {
			roleIdentify = roleIdentify,
			transaction_id = transaction_id
		})
	end
end

function iap.onPaymentEvent(data)
	local identifier = data.identifier
	local event = data.event
	local quantity = data.quantity
	local transaction_id = data.index

	print("onPaymentEvent", evt[event], order, data.error)

	if string.len(data.requestData) <= 1 or not transaction_id then
		print("unknow error", data.error)

		return
	end

	local requestData = json.decode(de(data.requestData))
	local order = tonumber(requestData.o)
	local extend = requestData.e

	if not iap.evtListener then
		print("not lisetner")
		table.insert(iap.cachedPaymentEvents, data)
	elseif event == evt.IOSIAP_PAYMENT_PURCHAED then
		print(requestData.id, iap.roleIdentify, transaction_id)
		iap.onPurchaed(order, data.identifier, data.receipt, extend, requestData.id, transaction_id, requestData.name)
	elseif event == evt.IOSIAP_PAYMENT_FAILED then
		print(requestData.id, iap.roleIdentify)

		if requestData.id == iap.roleIdentify then
			iap.evtListener:onPaymentFailed(order, identifier, data.error)
			IAP.finishPayment(transaction_id)
		end
	elseif event == evt.IOSIAP_PAYMENT_RESTORED then
		-- Nothing
	elseif event == evt.IOSIAP_PAYMENT_REMOVED then
		-- Nothing
	end
end

function iap.notifyPurchaed(roleIdentify, order, identifier, transaction_id)
	iap.evtListener:onPurchaed(order, identifier, roleIdentify)
	iap.finishPayment(transaction_id)

	iap.curPurchaedVerifyData[roleIdentify] = nil
end

function iap:onCetSvrEvt(code, desc, res, ex)
	print(code, desc, res, ex)
	dump(res)

	if code == -112 or res and res.status == 0 then
		print(ex.roleIdentify, iap.roleIdentify)

		if ex.roleIdentify ~= iap.roleIdentify then
			print("不是当前玩家的订单", ex.roleIdentify, iap.roleIdentify)

			local id = res.tid

			cache.storage_verifiedTransaction(id, ex.roleIdentify)
			iap.evtListener:onPurchaed()
		elseif iap.curPurchaedVerifyData[ex.roleIdentify] then
			print("验证完成", ex.roleIdentify, ex.transaction_id)

			local order, identifier, receipt, extend = unpack(iap.curPurchaedVerifyData[ex.roleIdentify])

			iap.notifyPurchaed(iap.roleIdentify, order, identifier, ex.transaction_id)
		end
	elseif code ~= 0 then
		iap.evtListener:onVerifyFailed(code, desc)
	elseif not res then
		-- Nothing
	end
end

return iap
