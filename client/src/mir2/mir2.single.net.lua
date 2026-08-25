local ByteArray = require("framework.cc.utils.ByteArray")
local socketTCP = require("an.overwrite.SocketTCP")
local net = {
	clientMsgSize,
	defaultMsgSize,
	SEGMENTATION_IDENT = 4282711876.0,
	buflen = 0,
	willCode = false,
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

function net.connect(ip, port, target, sessionid, areaid)
	net.close()

	net.clientMsgSize = getRecordSize("TClientMessage")
	net.defaultMsgSize = getRecordSize("TDefaultMessage")

	if areaid then
		net.dataIndex = areaid
	else
		net.dataIndex = sessionid
	end

	if target then
		net.add(target)
	end

	if net.useLuasocket then
		p2("net", "use luasocket")

		net.server = socketTCP.new(ip, port)

		net.server:addEventListener(socketTCP.EVENT_DATA, net.callback)
		net.server:addEventListener(socketTCP.EVENT_CLOSE, net.callback)
		net.server:addEventListener(socketTCP.EVENT_CLOSED, net.callback)
		net.server:addEventListener(socketTCP.EVENT_CONNECTED, net.callback)
		net.server:addEventListener(socketTCP.EVENT_CONNECT_FAILURE, net.callback)
		net.server:connect()
	else
		p2("net", "use ODSocket")

		net.server = ycSocket:create(net.SEGMENTATION_IDENT, net.LM_DYN_ENCRYPT_CODE)

		net.server:connect(ip, port)

		function net_socket_event(eventType, client, default, buf, bufLen)
			net.handler(eventType, client, default, buf, bufLen)
		end
	end

	p2("net", "connect: " .. ip .. ":" .. port)
end

function net.close()
	if net.server then
		net.server:close()

		net.server = nil
	end

	net.targets = {}
	net.code = 1
	net.willCode = false
	net.waitMsg = nil

	net.clearBuf()
	net.clearMsgs()
end

function net.clearMsgs()
	net.msgs.clear()
end

function net.platformCode()
	return 2
end

function net.handler(eventType, client, default, buf, bufLen)
	if eventType == 0 then
		if SM_RUNGATEDYN == default.ident then
			local sendLen = net.clientMsgSize + net.defaultMsgSize + bufLen

			ycByteStream:startWrite(sendLen)

			local pos = net.newClientMsg(net.defaultMsgSize + bufLen):encode(0)
			pos = getRecord("TDefaultMessage", {
				recog = default.recog,
				ident = default.ident,
				param = default.param,
				tag = default.tag,
				series = default.series
			}):encode(pos)

			ycByteStream:writeCString(pos, buf, bufLen)
			net.server:send(ycByteStream:endWrite(sendLen), sendLen)
		elseif SM_ACT_GOOD == default.ident or SM_ACT_FAIL == default.ident then
			net.processMsg(client, default, buf, bufLen)
		else
			net.msgs.pushBack({
				client = client,
				default = default,
				buf = buf,
				bufLen = bufLen or 0
			})
		end
	else
		if eventType == 1 then
			p2("net", "connect success!!!")

			net.code = math.random(65535) + 1000

			if not net.willCode then
				local client = getRecord("TClientMessage", {
					reservationByte = net.platformCode(),
					sign = net.SEGMENTATION_IDENT,
					cmd = net.LM_GET_ENCRYPT,
					dataIndex = net.dataIndex
				})

				net.server:send(client:encode())

				net.willCode = true

				dump(client)
			end
		else
			p2("net", "connect event[" .. eventType .. "]")
		end

		for i, v in ipairs(net.targets) do
			if v.socketEvent then
				v:socketEvent(nil, eventType)
			end
		end
	end
end

function net.processLoop()
	if net.waitMsg then
		local ident = net.waitMsg.ident
		local allowList = net.waitMsg.allowList
		local tmpList = newList()

		while not net.msgs.isEmpty() do
			local msg = net.msgs.popFront()

			if msg.default and (msg.default.ident == ident or allowList[msg.default.ident]) then
				if msg.default.ident == ident then
					net.waitMsg = nil
				end

				net.processMsg(msg.client, msg.default, msg.buf, msg.bufLen)
			else
				tmpList.pushBack(msg)
			end
		end

		net.msgs = tmpList

		return
	end

	local begin = socket.gettime()

	while not net.msgs.isEmpty() do
		local msg = net.msgs.popFront()

		if net.LM_DYN_ENCRYPT_CODE == msg.client.cmd then
			net.processMsg(msg.client, msg.default, msg.buf, msg.bufLen)
		elseif net.LM_GET_ENCRYPT == msg.client.cmd then
			p2("net", "net.LM_GET_ENCRYPT")
		elseif net.LM_PING == msg.client.cmd then
			if m2debug and g_data.client.lastTime.ping then
				local time = math.floor((socket.gettime() - g_data.client.lastTime.ping) * 1000)

				cc.Director:getInstance():getNotificationNode().pingNode.label:setText("ping值: " .. time .. "ms")
			end
		else
			print("discard msg:", msg.default.ident)
		end

		if socket.gettime() - begin > 0.03 then
			break
		end
	end
end

scheduler.scheduleUpdateGlobal(net.processLoop)

function net.processMsg(clientMsg, defaultMsg, buf, bufLen)
	if DEBUG > 0 then
		local name = m2debug.smNames[defaultMsg.ident] or ""

		p2("net", string.format("recv：%s [%d], dataLen: %d", name, defaultMsg.ident, bufLen or 0))
	end

	local hasProcess = false

	for i, v in ipairs(net.targets) do
		if v.processMsg and v:processMsg(defaultMsg, buf, bufLen) then
			hasProcess = true
		end
	end

	if defaultMsg and DEBUG > 0 and not hasProcess then
		p2("net", string.format("unprocessed: %s [%d], dataLen: %d , param:[%d]", name, defaultMsg.ident, bufLen or 0, defaultMsg.param))
	end
end

function net.setWaitMsg(ident, ...)
	net.waitMsg = {
		ident = ident,
		allowList = {}
	}
	local params = {
		...
	}

	for i, v in ipairs(params) do
		net.waitMsg.allowList[v] = true
	end
end

function net.add(target)
	for i, v in ipairs(net.targets) do
		if target == v then
			return
		end
	end

	net.targets[#net.targets + 1] = target
end

function net.remove(target)
	table.removebyvalue(net.targets, target)
end

function net.send_old(msg, strs, bufs, strIsEncodeSpace)
	if msg and msg[1] then
		p2("net", "use old:", msg[1])
	end
end

function net.sendPing()
	local client = getRecord("TClientMessage", {
		sign = net.SEGMENTATION_IDENT,
		cmd = net.LM_PING
	})

	net.server:send(client:encode())
end

function net.setMatchMode(mode)
	net.match_msg = mode
end

function net.match(ident)
	return checkExist(ident, CM_SELCHR, CM_DELCHR, CM_QUERYDELCHR, CM_SELCHR_EXIT, CM_NEWCHR, CM_RECOVERCHR, CM_SUBMIT_MIBAO, CM_RECONNECT, CM_LOGIN_ALREADY_ONLINE)
end

function net.send(msg, strs, data)
	if net.match_msg and not net.match(msg[1]) then
		p2("net", "The message being sent is not matched with the current scene")

		return
	end

	local dataLen = 0

	if strs then
		for i, v in ipairs(strs) do
			strs[i] = ycFunction:u2a(v, #v)
		end

		for i, v in ipairs(strs) do
			if i > 1 then
				dataLen = dataLen + 1
			end

			dataLen = dataLen + string.len(v)
		end
	end

	if data then
		if data._class == "record" then
			dataLen = data:size()
		else
			for i, v in ipairs(data) do
				if v._class == "record" then
					dataLen = dataLen + v:size()
				else
					dataLen = dataLen + baseVarSize(v[1], v[3])
				end
			end
		end
	end

	if strs or data then
		dataLen = dataLen + 1
	end

	local sendLen = net.clientMsgSize + net.defaultMsgSize + dataLen

	ycByteStream:startWrite(sendLen)

	local pos = 0
	pos = net.newClientMsg(net.defaultMsgSize + dataLen):encode(pos)
	pos = getRecord("TDefaultMessage", {
		recog = msg.recog,
		ident = msg[1],
		param = msg.param,
		tag = msg.tag,
		series = msg.series
	}):encode(pos)

	if strs then
		for i, v in ipairs(strs) do
			if i > 1 then
				pos = pos + 1
			end

			ycByteStream:writeCString(pos, v, string.len(v))

			pos = pos + string.len(v)
		end
	end

	if data then
		if data._class == "record" then
			pos = data:encode(pos)
		else
			for i, v in ipairs(data) do
				if v._class == "record" then
					pos = v:encode(pos)
				else
					if v[1] == "byte" then
						ycByteStream:writeByte(pos, v[2])
					elseif v[1] == "short" then
						ycByteStream:writeShort(pos, v[2])
					elseif v[1] == "int" then
						ycByteStream:writeInt(pos, v[2])
					elseif v[1] == "uint" then
						ycByteStream:writeUInt(pos, v[2])
					elseif v[1] == "ID" or v[1] == "double" then
						ycByteStream:writeDouble(pos, v[2])
					elseif v[1] == "char*" then
						ycByteStream:writeChars(pos, v[2], v[3])
					elseif v[1] == "string" then
						ycByteStream:writeString(pos, v[2], v[3])
					end

					pos = pos + baseVarSize(v[1], v[3])
				end
			end
		end
	end

	net.server:send(ycByteStream:endWrite(sendLen), sendLen)

	if DEBUG > 0 then
		local name = m2debug.cmNames[msg[1]] or ""

		p2("net", string.format("send: %s [%d], dataLen: %d", name, msg[1], dataLen))
	end
end

if DEBUG then
	local ole = net.send

	function net.send(msg, strs, data)
		if net.dumpProt == msg[1] then
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

function net.newClientMsg(dataLen)
	local ret = getRecord("TClientMessage", {
		sign = net.SEGMENTATION_IDENT,
		cmd = net.LM_DYN_ENCRYPT_CODE,
		dataLength = dataLen,
		dataIndex = net.code
	})
	net.code = net.code + 1

	return ret
end

local DEFBLOCKSIZE = 22

function net.findByte(buf, byte)
	local src = ByteArray.new():writeString(buf):setPos(1)

	while src:getAvailable() > 0 do
		if src:readByte() == byte then
			return src:getPos()
		end
	end

	return -1
end

function net.str(buf)
	ycByteStream:startRead(buf, #buf)

	return ycByteStream:readChars(0, #buf)
end

function net.strs(body, c, len)
	return string.split(net.str(body), c or "/")
end

function net.strSplitWithLen(buf, len, cnt)
	ycByteStream:startRead(buf, #buf)

	local ret = {}

	for i = 1, cnt do
		ret[#ret + 1] = ycByteStream:readChars((i - 1) * len, len)
	end

	return ret
end

function net.record(name, buf, bufLen)
	local record = nil

	if type(name) == "string" then
		record = getRecord(name)
	else
		record = name
	end

	return record:decode(buf, bufLen, true)
end

function net.byte(buf, bufLen)
	if bufLen < 1 then
		p2("error", "net.byte -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 1)

	return ycByteStream:readByte(0), string.sub(buf, 2, bufLen), bufLen - 1
end

function net.int(buf, bufLen)
	if bufLen < 4 then
		p2("error", "net.int -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 4)

	return ycByteStream:readInt(0), string.sub(buf, 5, bufLen), bufLen - 4
end

function net.uint(buf, bufLen)
	if bufLen < 4 then
		p2("error", "net.uint -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 4)

	return ycByteStream:readUInt(0), string.sub(buf, 5, bufLen), bufLen - 4
end

function net.double(buf, bufLen)
	if bufLen < 4 then
		p2("error", "net.int -> readFail")

		return -1
	end

	ycByteStream:startRead(buf, 8)

	return ycByteStream:readDouble(0), string.sub(buf, 9, bufLen), bufLen - 8
end

function net.clearBuf()
	net.buf = {}
	net.buflen = 0
end

function net.insertBuf(buf, len)
	table.insert(net.buf, 1, buf)

	net.buflen = net.buflen + len
end

function net.appendBuf(buf, len)
	net.buf[#net.buf + 1] = buf
	net.buflen = net.buflen + len
end

function net.popBuf(len)
	local cnt = 0
	local ret = {}

	while true do
		local size = cnt + #net.buf[1]

		if size == len then
			ret[#ret + 1] = net.buf[1]

			table.remove(net.buf, 1)

			break
		elseif len < size then
			ret[#ret + 1] = string.sub(net.buf[1], 1, len - cnt)
			net.buf[1] = string.sub(net.buf[1], len - cnt + 1, #net.buf[1])

			break
		else
			ret[#ret + 1] = net.buf[1]
			cnt = cnt + #net.buf[1]

			table.remove(net.buf, 1)
		end
	end

	net.buflen = net.buflen - len

	return table.concat(ret)
end

function net.callback(data)
	if data.name == socketTCP.EVENT_DATA then
		if data.datalen > 0 then
			net.appendBuf(data.data, data.datalen)

			while true do
				if net.buflen < net.clientMsgSize then
					break
				end

				local clientMsgBuf = net.popBuf(net.clientMsgSize)
				local clientMsg = getRecord("TClientMessage"):decode(clientMsgBuf)

				if clientMsg:get("sign") == net.SEGMENTATION_IDENT then
					local datalen = clientMsg:get("dataLength")

					if net.buflen < datalen then
						net.insertBuf(clientMsgBuf, net.clientMsgSize)

						break
					end

					local default, buf, bufLen = nil

					if net.LM_DYN_ENCRYPT_CODE == clientMsg.cmd then
						local defaultMsgBuf = net.popBuf(net.defaultMsgSize)
						default = getRecord("TDefaultMessage"):decode(defaultMsgBuf)
						bufLen = datalen - net.defaultMsgSize

						if bufLen > 0 then
							buf = net.popBuf(bufLen)
						end
					else
						default = {}
						bufLen = datalen

						if bufLen > 0 then
							buf = net.popBuf(bufLen)
						end
					end

					net.handler(0, clientMsg, default, buf, bufLen)
				else
					p2("error", "net sign error!")
					net.insertBuf(string.sub(clientMsgBuf, 2, net.clientMsgSize), net.clientMsgSize - 1)
				end
			end
		end
	elseif data.name == socketTCP.EVENT_CONNECTED then
		net.handler(1)
	elseif data.name == socketTCP.EVENT_CONNECT_FAILURE then
		net.handler(2)
	elseif data.name == socketTCP.EVENT_CLOSED then
		net.handler(3)
	end
end

return net
