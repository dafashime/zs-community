local ByteArray = require("framework.cc.utils.ByteArray")
local socketTCP = require("an.overwrite.SocketTCP")
local count = 0
local text = "1Y0lSUQMH+mbKXRTBtFiWvLx32/gNAzGr674oeyn5dCEp8jDqasI9VcwJPhufkOZ"
local count3 = 0
local count4 = 0
local count2 = 0

local function callback(self, value)
	local text2 = text

	count3 = value
	count4 = 1

	if value ~= 0 then
		text2 = string.sub(text, value % 63 + 1, 64) .. string.sub(text, 1, value % 63)
	end

	local text3 = ""
	local items = self

	while #items > 0 do
		local count5 = 0
		local count6 = 0

		for index = 1, 3 do
			count6 = count6 * 256

			if #items > 0 then
				count6 = count6 + string.byte(items, 1, 1)
				items = string.sub(items, 2)
				count5 = count5 + 1
			end
		end

		for index2 = 1, count5 + 1 do
			local value2 = math.fmod(math.floor(count6 / 262144), 64) + 1

			text3 = text3 .. string.sub(text2, value2, value2)
			count6 = count6 * 64
		end

		for index3 = 1, 3 - count5 do
			text3 = text3 .. "="
		end
	end

	return text3 .. "|LH"
end

local function onUpdate()
	local record = getRecord("TClientMessage", {
		cmd = 29,
		sign = net.SEGMENTATION_IDENT,
		dataIndex = socket.gettime()
	})

	if count4 == 1 then
		net.server:send(callback(record.encode(record), count3))

		count = net.dataIndex
	else
		net.server:send(record.encode(record))
	end
end

local net2 = {
	clientMsgSize,
	defaultMsgSize,
	willCode = false,
	buflen = 0,
	SEGMENTATION_IDENT = 4282711876,
	DYNBUFFSIZE = 32768,
	LM_DYN_ENCRYPT_CODE = 23,
	LM_PING = 25,
	useLuasocket = false,
	first = true,
	MAX_SEND_BUFFER_SIZE = 16384,
	LM_GET_ENCRYPT = 24,
	match_msg = false,
	MAX_RECEIVE_BUFFER_SIZE = 32768,
	msgs = newList(),
	buf = {}
}

function net2.connect(ip, port, target, sessionid, areaid)
	net2.close()

	net2.clientMsgSize = getRecordSize("TClientMessage")
	net2.defaultMsgSize = getRecordSize("TDefaultMessage")

	if areaid then
		net2.dataIndex = areaid
		count = 0
		count2 = 0
	else
		net2.dataIndex = sessionid
		count = 0
		count2 = 1
	end

	if target then
		net2.add(target)
	end

	if net2.useLuasocket then
		p2("net", "use luasocket")

		net2.server = socketTCP.new(ip, port)

		net2.server:addEventListener(socketTCP.EVENT_DATA, net2.callback)
		net2.server:addEventListener(socketTCP.EVENT_CLOSE, net2.callback)
		net2.server:addEventListener(socketTCP.EVENT_CLOSED, net2.callback)
		net2.server:addEventListener(socketTCP.EVENT_CONNECTED, net2.callback)
		net2.server:addEventListener(socketTCP.EVENT_CONNECT_FAILURE, net2.callback)
		net2.server:connect()
	else
		p2("net", "use ODSocket")

		net2.server = ycSocket:create(net2.SEGMENTATION_IDENT, net2.LM_DYN_ENCRYPT_CODE)

		net2.server:connect(ip, port)

		function net_socket_event(eventType, client, default, buf, bufLen)
			net2.handler(eventType, client, default, buf, bufLen)
		end
	end

	p2("net", "connect: " .. ip .. ":" .. port)
end

function net2.close()
	if net2.server then
		net2.server:close()

		net2.server = nil
	end

	net2.targets = {}
	net2.code = 1
	net2.willCode = false
	net2.waitMsg = nil

	net2.clearBuf()
	net2.clearMsgs()
end

function net2.clearMsgs()
	net2.msgs.clear()
end

function net2.platformCode()
	return 2
end

function net2.handler(eventType, client, default, buf, bufLen)
	if eventType == 0 then
		if SM_RUNGATEDYN == default.ident then
			local sendLen = net2.clientMsgSize + net2.defaultMsgSize + bufLen

			ycByteStream:startWrite(sendLen)

			local pos = net2.newClientMsg(net2.defaultMsgSize + bufLen):encode(0)
			local pos2 = getRecord("TDefaultMessage", {
				recog = default.recog,
				ident = default.ident,
				param = default.param,
				tag = default.tag,
				series = default.series
			}):encode(pos)

			ycByteStream:writeCString(pos2, buf, bufLen)

			if count2 == 1 and def.openNewTigerGate then
				net2.server:send(callback(ycByteStream:endWrite(sendLen), count))
			else
				net2.server:send(ycByteStream:endWrite(sendLen), sendLen)
			end
		elseif SM_ACT_GOOD == default.ident or SM_ACT_FAIL == default.ident then
			net2.processMsg(client, default, buf, bufLen)
		else
			net2.msgs.pushBack({
				client = client,
				default = default,
				buf = buf,
				bufLen = bufLen or 0
			})
		end
	else
		if eventType == 1 then
			p2("net", "connect success!!!")

			net2.code = math.random(65535) + 1000

			if not net2.willCode then
				local client2 = getRecord("TClientMessage", {
					reservationByte = net2.platformCode(),
					sign = net2.SEGMENTATION_IDENT,
					cmd = net2.LM_GET_ENCRYPT,
					dataIndex = net2.dataIndex
				})

				if count2 == 1 and def.openNewTigerGate then
					net2.server:send(callback(client2:encode(), count))

					count = net2.dataIndex
				else
					net2.server:send(client2:encode())
				end

				if not Timer then
					Timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onUpdate, 30, false)
				end

				net2.willCode = true
			end
		else
			p2("net", "connect event[" .. eventType .. "]")
		end

		for i, v in ipairs(net2.targets) do
			if v.socketEvent then
				v:socketEvent(nil, eventType)
			end
		end
	end
end

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function net2.processLoop()
	if net2.waitMsg then
		local ident = net2.waitMsg.ident
		local allowList = net2.waitMsg.allowList
		local tmpList = newList()

		while not net2.msgs.isEmpty() do
			local msg = net2.msgs.popFront()

			if msg.default and (msg.default.ident == ident or allowList[msg.default.ident]) then
				if msg.default.ident == ident then
					net2.waitMsg = nil
				end

				net2.processMsg(msg.client, msg.default, msg.buf, msg.bufLen)
			else
				tmpList.pushBack(msg)
			end
		end

		net2.msgs = tmpList

		return
	end

	local begin = socket.gettime()

	while not net2.msgs.isEmpty() do
		local msg2 = net2.msgs.popFront()

		if net2.LM_DYN_ENCRYPT_CODE == msg2.client.cmd then
			net2.processMsg(msg2.client, msg2.default, msg2.buf, msg2.bufLen)
		elseif net2.LM_GET_ENCRYPT == msg2.client.cmd then
			p2("net", "net.LM_GET_ENCRYPT")
		elseif net2.LM_PING == msg2.client.cmd then
			if g_data.client.lastTime.ping then
				local time = math.floor((socket.gettime() - g_data.client.lastTime.ping) * 1000)

				if main_scene and main_scene.ui then
					if def and def.openPing then
						if not main_scene.ui.pingNode then
							local x = 10

							if g_data.setting.base.liuhaier and needsSafeAreaAdjustment() then
								x = getSafeAreaInsets() / 2
							end

							main_scene.ui.pingNode = display.newNode():addTo(main_scene.ui)
							main_scene.ui.pingNode.label = an.newLabel("", 14, 0.8, {
								sd = true,
								color = display.COLOR_GREEN
							}):addTo(main_scene.ui.pingNode):pos(x, 31)
						end

						if time <= 110 then
							main_scene.ui.pingNode.label:setColor(display.COLOR_GREEN)
						elseif time > 110 and time <= 160 then
							main_scene.ui.pingNode.label:setColor(cc.c3b(250, 210, 100))
						elseif time > 160 then
							main_scene.ui.pingNode.label:setColor(display.COLOR_RED)
						end

						local text2 = tostring(time) .. "ms"

						main_scene.ui.pingNode.label:setText(text2)
					end

					if m2debug then
						local instance = cc.Director:getInstance():getNotificationNode()
						local label = instance and instance.pingNode and instance.pingNode.label

						if label then
							label:setText("ping值: " .. time .. "ms")
						end
					end
				end
			end
		else
			print("discard msg:", msg2.default.ident)
		end

		if socket.gettime() - begin > 0.03 then
			break
		end
	end
end

scheduler.scheduleUpdateGlobal(net2.processLoop)

function net2.processMsg(clientMsg, defaultMsg, buf, bufLen)
	local hasProcess = false

	for i, v in ipairs(net2.targets) do
		if v.processMsg and v:processMsg(defaultMsg, buf, bufLen) then
			hasProcess = true
		end
	end

	if defaultMsg and DEBUG > 0 and not hasProcess then
		p2("net", string.format("unprocessed: %s [%d], dataLen: %d , param:[%d]", name, defaultMsg.ident, bufLen or 0, defaultMsg.param))
	end
end

function net2.setWaitMsg(ident, ...)
	net2.waitMsg = {
		ident = ident,
		allowList = {}
	}

	local params = {
		...
	}

	for i, v in ipairs(params) do
		net2.waitMsg.allowList[v] = true
	end
end

function net2.add(target)
	for i, v in ipairs(net2.targets) do
		if target == v then
			return
		end
	end

	net2.targets[#net2.targets + 1] = target
end

function net2.remove(target)
	table.removebyvalue(net2.targets, target)
end

function net2.send_old(msg, strs, bufs, strIsEncodeSpace)
	if msg and msg[1] then
		p2("net", "use old:", msg[1])
	end
end

function net2.sendPing()
	local client = getRecord("TClientMessage", {
		sign = net2.SEGMENTATION_IDENT,
		cmd = net2.LM_PING
	})

	if count2 == 1 and def.openNewTigerGate then
		net2.server:send(callback(client:encode(), count))
	else
		net2.server:send(client:encode())
	end
end

function net2.setMatchMode(mode)
	net2.match_msg = mode
end

function net2.match(ident)
	return checkExist(ident, CM_SELCHR, CM_DELCHR, CM_QUERYDELCHR, CM_SELCHR_EXIT, CM_NEWCHR, CM_RECOVERCHR, CM_SUBMIT_MIBAO, CM_RECONNECT, CM_LOGIN_ALREADY_ONLINE)
end

function net2.send(msg, strs, data)
	if not net2.server then
		print("server failed")

		return
	end

	if net2.match_msg and not net2.match(msg[1]) then
		p2("net", "The message being sent is not matched with the current scene")

		return
	end

	local dataLen = 0

	if strs then
		for i, v in ipairs(strs) do
			strs[i] = ycFunction:u2a(v, #v)
		end

		for i2, v2 in ipairs(strs) do
			if i2 > 1 then
				dataLen = dataLen + 1
			end

			dataLen = dataLen + string.len(v2)
		end
	end

	if data then
		if data._class == "record" then
			dataLen = data:size()
		else
			for i3, v3 in ipairs(data) do
				if v3._class == "record" then
					dataLen = dataLen + v3:size()
				else
					dataLen = dataLen + baseVarSize(v3[1], v3[3])
				end
			end
		end
	end

	if strs or data then
		dataLen = dataLen + 1
	end

	local sendLen = net2.clientMsgSize + net2.defaultMsgSize + dataLen

	ycByteStream:startWrite(sendLen)

	local pos = 0
	local pos2 = net2.newClientMsg(net2.defaultMsgSize + dataLen):encode(pos)
	local pos3 = getRecord("TDefaultMessage", {
		recog = msg.recog,
		ident = msg[1],
		param = msg.param,
		tag = msg.tag,
		series = msg.series
	}):encode(pos2)

	if strs then
		for i4, v4 in ipairs(strs) do
			if i4 > 1 then
				pos3 = pos3 + 1
			end

			ycByteStream:writeCString(pos3, v4, string.len(v4))

			pos3 = pos3 + string.len(v4)
		end
	end

	if data then
		if data._class == "record" then
			pos3 = data:encode(pos3)
		else
			for i5, v5 in ipairs(data) do
				if v5._class == "record" then
					pos3 = v5:encode(pos3)
				else
					if v5[1] == "byte" then
						ycByteStream:writeByte(pos3, v5[2])
					elseif v5[1] == "short" then
						ycByteStream:writeShort(pos3, v5[2])
					elseif v5[1] == "int" then
						ycByteStream:writeInt(pos3, v5[2])
					elseif v5[1] == "uint" then
						ycByteStream:writeUInt(pos3, v5[2])
					elseif v5[1] == "ID" or v5[1] == "double" then
						ycByteStream:writeDouble(pos3, v5[2])
					elseif v5[1] == "char*" then
						ycByteStream:writeChars(pos3, v5[2], v5[3])
					elseif v5[1] == "string" then
						ycByteStream:writeString(pos3, v5[2], v5[3])
					end

					pos3 = pos3 + baseVarSize(v5[1], v5[3])
				end
			end
		end
	end

	if count2 == 1 and def.openNewTigerGate then
		net2.server:send(callback(ycByteStream:endWrite(sendLen), count))
	else
		net2.server:send(ycByteStream:endWrite(sendLen), sendLen)
	end

	if DEBUG > 0 then
		local name = m2debug.cmNames[msg[1]] or ""

		p2("net", string.format("send: %s [%d], dataLen: %d", name, msg[1], dataLen))
	end
end

if DEBUG then
	local ole = net2.send

	function net2.send(msg, strs, data)
		if net2.dumpProt == msg[1] then
			print("head")
			dump(msg)
			print("string buffers")
			dump(strs)
			print("key-value")
			dump(data)
		end

		return ole(msg, strs, data)
	end
end

function net2.newClientMsg(dataLen)
	local ret = getRecord("TClientMessage", {
		sign = net2.SEGMENTATION_IDENT,
		cmd = net2.LM_DYN_ENCRYPT_CODE,
		dataLength = dataLen,
		dataIndex = net2.code
	})

	net2.code = net2.code + 1

	return ret
end

local DEFBLOCKSIZE = 22

function net2.findByte(buf, byte)
	local src = ByteArray.new():writeString(buf):setPos(1)

	while src:getAvailable() > 0 do
		if src:readByte() == byte then
			return src:getPos()
		end
	end

	return -1
end

function net2.str(buf)
	ycByteStream:startRead(buf, #buf)

	return ycByteStream:readChars(0, #buf)
end

function net2.strs(body, c, len)
	return string.split(net2.str(body), c or "/")
end

function net2.strSplitWithLen(buf, len, cnt)
	ycByteStream:startRead(buf, #buf)

	local ret = {}

	for i = 1, cnt do
		ret[#ret + 1] = ycByteStream:readChars((i - 1) * len, len)
	end

	return ret
end

function net2.record(name, buf, bufLen)
	local record

	if type(name) == "string" then
		record = getRecord(name)
	else
		record = name
	end

	return record:decode(buf, bufLen, true)
end

function net2.byte(buf, bufLen)
	if bufLen < 1 then
		p2("error", "net.byte -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 1)

	return ycByteStream:readByte(0), string.sub(buf, 2, bufLen), bufLen - 1
end

function net2.int(buf, bufLen)
	if bufLen < 4 then
		p2("error", "net.int -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 4)

	return ycByteStream:readInt(0), string.sub(buf, 5, bufLen), bufLen - 4
end

function net2.uint(buf, bufLen)
	if bufLen < 4 then
		p2("error", "net.uint -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 4)

	return ycByteStream:readUInt(0), string.sub(buf, 5, bufLen), bufLen - 4
end

function net2.double(buf, bufLen)
	if bufLen < 4 then
		p2("error", "net.int -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 8)

	return ycByteStream:readDouble(0), string.sub(buf, 9, bufLen), bufLen - 8
end

function net2.clearBuf()
	net2.buf = {}
	net2.buflen = 0
end

function net2.insertBuf(buf, len)
	table.insert(net2.buf, 1, buf)

	net2.buflen = net2.buflen + len
end

function net2.appendBuf(buf, len)
	net2.buf[#net2.buf + 1] = buf
	net2.buflen = net2.buflen + len
end

function net2.popBuf(len)
	local cnt = 0
	local ret = {}

	while true do
		local size = cnt + #net2.buf[1]

		if size == len then
			ret[#ret + 1] = net2.buf[1]

			table.remove(net2.buf, 1)

			break
		elseif len < size then
			ret[#ret + 1] = string.sub(net2.buf[1], 1, len - cnt)
			net2.buf[1] = string.sub(net2.buf[1], len - cnt + 1, #net2.buf[1])

			break
		else
			ret[#ret + 1] = net2.buf[1]
			cnt = cnt + #net2.buf[1]

			table.remove(net2.buf, 1)
		end
	end

	net2.buflen = net2.buflen - len

	return table.concat(ret)
end

function net2.callback(data)
	if data.name == socketTCP.EVENT_DATA then
		if data.datalen > 0 then
			net2.appendBuf(data.data, data.datalen)

			while true do
				if net2.buflen < net2.clientMsgSize then
					break
				end

				local clientMsgBuf = net2.popBuf(net2.clientMsgSize)
				local clientMsg = getRecord("TClientMessage"):decode(clientMsgBuf)

				if clientMsg:get("sign") == net2.SEGMENTATION_IDENT then
					local datalen = clientMsg:get("dataLength")

					if datalen > net2.buflen then
						net2.insertBuf(clientMsgBuf, net2.clientMsgSize)

						break
					end

					local default
					local buf
					local bufLen

					if net2.LM_DYN_ENCRYPT_CODE == clientMsg.cmd then
						local defaultMsgBuf = net2.popBuf(net2.defaultMsgSize)

						default = getRecord("TDefaultMessage"):decode(defaultMsgBuf)
						bufLen = datalen - net2.defaultMsgSize

						if bufLen > 0 then
							buf = net2.popBuf(bufLen)
						end
					else
						default = {}
						bufLen = datalen

						if bufLen > 0 then
							buf = net2.popBuf(bufLen)
						end
					end

					net2.handler(0, clientMsg, default, buf, bufLen)
				else
					p2("error", "net sign error!")
					net2.insertBuf(string.sub(clientMsgBuf, 2, net2.clientMsgSize), net2.clientMsgSize - 1)
				end
			end
		end
	elseif data.name == socketTCP.EVENT_CONNECTED then
		net2.handler(1)
	elseif data.name == socketTCP.EVENT_CONNECT_FAILURE then
		net2.handler(2)
	elseif data.name == socketTCP.EVENT_CLOSED then
		net2.handler(3)
	end
end

return net2
