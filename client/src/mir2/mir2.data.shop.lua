local shop = {
	goods = {},
	payOrders = {},
	init = function (self)
		IAP.setEvtListener(self)
	end
}

function shop:setEvtListener(ui)
	if ui then
		assert(ui.onPaymentEvent)
	end

	self.ui = ui
end

function shop:getCurTypePageGoods(type, page)
	return self.goods[type] and self.goods[type] or {}
end

function shop:getSpecially()
	return self.specially
end

function shop:parseContent(msg, buf, bufLen)
	return self:parseBody(buf, bufLen)
end

function shop:parseBody(buf, bufLen)
	local items = {}
	local count = bufLen / getRecordSize("TClientShop")
	local item = nil
	local pageInfo = 0

	for i = 1, count do
		item, buf, bufLen = net.record("TClientShop", buf, bufLen)
		pageInfo = item:get("page")

		if item:get("looks") ~= 0 then
			items[#items + 1] = item
		end
	end

	if #items > 0 then
		self.goods[pageInfo] = items
	else
		items = self.goods[pageInfo] or {}
	end

	return items
end

function shop:parseSpecially(buf, bufLen)
	local items = {}
	local count = bufLen / getRecordSize("TClientShop")
	local item = nil

	for i = 1, count do
		item, buf, bufLen = net.record("TClientShop", buf, bufLen)

		if item:get("looks") ~= 0 then
			items[#items + 1] = item
		end
	end

	items = items or {}
	self.goods[5] = items

	return items
end

function shop:hasPayingOrder()
	print("hasPayingOrder", self.payOrder)

	return self.payOrder and self.payOrder.roleIdentify == IAP.roleIdentify
end

function shop:checkPaidOrder()
	local order, product = IAP.checkOleVerify()

	if not order then
		return
	end

	local payOrder = self:resetPayOrder(tonumber(order), product, IAP.roleIdentify)

	return true
end

function shop:getProducts()
	return IAP:getProductsInfo()
end

function shop:checkUnfinishOrder()
	if not IAP.hasUnfinishPayment() then
		print("has unfinish payment")
		net.send({
			CM_GHOME_PAY_FAILED
		})

		self.payOrder = nil

		return true
	else
		print("have unfinish payment")
	end
end

function shop:addPayOrder(product)
	if not self.payOrder or self.payOrder.roleIdentify ~= IAP.roleIdentify then
		self:resetPayOrder(nil, product, IAP.roleIdentify)
		net.send({
			CM_GHOME_PAY_READY
		})
	else
		self:notifyOrderState("onPayReady", -1)
	end
end

function shop:notifyOrderState(step, code, msg)
	if not tolua.isnull(self.ui) then
		self.ui:onPaymentEvent(step, code, msg)
	else
		if msg and main_scene then
			main_scene.ui:tip(msg)
		end

		print(step, code, msg, self.ui)
	end
end

function shop:resetPayOrder(order, product, id)
	if self.payOrder and self.payOrder.checkHandler then
		scheduler.unscheduleGlobal(self.payOrder.checkHandler)
	end

	self.payOrder = {
		orderId = order,
		product = product,
		roleIdentify = IAP.roleIdentify
	}

	return self.payOrder
end

function shop:onPayReady(recog, buf, playername)
	print("onPayReady", recog, buf)

	if not self.payOrder then
		self:checkUnfinishOrder()
		self:notifyOrderState("onPayReady", -999)

		return
	end

	if recog < 0 and not IAP.hasUnfinishPayment() then
		local product = self.payOrder.product

		if self:checkUnfinishOrder() then
			self:addPayOrder(product)
		end

		return
	end

	local payOrder = self.payOrder
	payOrder.extend = buf
	payOrder.orderId = recog

	IAP.paymentWithProduct(payOrder.product, payOrder.quantity or 1, tostring(recog), buf, playername)
end

function shop:onPurchaed(order, identifier)
	print("onPurchaed", order, identifier)

	if not order then
		self.payOrder = nil

		self:notifyOrderState("onPayEnd", -1, "充值订单验证通过，但不属于当前角色，稍后将充值到所属角色。")

		return
	end

	scheduler.performWithDelayGlobal(function ()
		local payorder = self.payOrder
		payorder = payorder or self:resetPayOrder(order, product, IAP.roleIdentify)
		payorder.checkHandler = scheduler.scheduleGlobal(function ()
			net.send({
				CM_QUERY_GHOME_ORDER,
				recog = order
			})
		end, 12)

		net.send({
			CM_QUERY_GHOME_ORDER,
			recog = order
		})
	end, 0)
end

function shop:onPaymentFailed(order, identifier, error)
	print("onPaymentFailed")
	net.send({
		CM_GHOME_PAY_FAILED,
		recog = order
	})

	self.payOrder = nil

	self:notifyOrderState("onPayEnd", code, error)
end

function shop:onPaymentRemoved(quantity, identifier)
	self.payOrder = nil
end

function shop:onUpdatedProducts()
	self:notifyOrderState("onUpdatedProducts")
end

function shop:onVerifyFailed(code, desc)
	self:notifyOrderState("onPayEnd", code, desc)
end

local errCodes = {
	OP_LC_SETSTATUS_SYSTEM_BUSY = -14,
	OP_LC_AUTH_SYSTEM_ERROR = -9,
	OP_ERR_GHOMEPAY_SYSTEM_BUSY = -98,
	OP_LC_AUTH_SYSTEM_BUSY = -10,
	OP_LC_SETSTATUS_SYSTEM_ERROR = -13,
	OP_LC_SETSTATUS_FAILED = -11,
	OP_LC_AUTH_TIMEOUT = -8,
	OP_LC_SETSTATUS_TIMEOUT = -12,
	OP_LC_AUTH_FAILED = -7
}

function shop:onPayResult(recog, buf)
	print("onPayResult", recog, buf)

	local retry = false

	for k, v in pairs(errCodes) do
		if recog == v then
			print("retry", v)

			return
		end
	end

	local payOrder = self.payOrder

	if payOrder then
		if payOrder and payOrder.checkHandler then
			scheduler.unscheduleGlobal(payOrder.checkHandler)
		end

		print("remove payOrder")

		self.payOrder = nil
	end

	self:notifyOrderState("onPayResult", recog)
end

return shop
