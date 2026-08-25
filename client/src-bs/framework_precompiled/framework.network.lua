local network = {
	isLocalWiFiAvailable = function ()
		return cc.Network:isLocalWiFiAvailable()
	end,
	isInternetConnectionAvailable = function ()
		return cc.Network:isInternetConnectionAvailable()
	end,
	isHostNameReachable = function (hostname)
		if type(hostname) ~= "string" then
			printError("network.isHostNameReachable() - invalid hostname %s", tostring(hostname))

			return false
		end

		return cc.Network:isHostNameReachable(hostname)
	end,
	getInternetConnectionStatus = function ()
		return cc.Network:getInternetConnectionStatus()
	end,
	createHTTPRequest = function (callback, url, method)
		method = method or "GET"

		if string.upper(tostring(method)) == "GET" then
			method = cc.kCCHTTPRequestMethodGET
		else
			method = cc.kCCHTTPRequestMethodPOST
		end

		return cc.HTTPRequest:createWithUrl(callback, url, method)
	end
}

function network.uploadFile(callback, url, datas)
	assert(datas or datas.fileFieldName or datas.filePath, "Need file datas!")

	local request = network.createHTTPRequest(callback, url, "POST")
	local fileFieldName = datas.fileFieldName
	local filePath = datas.filePath
	local contentType = datas.contentType

	if contentType then
		request:addFormFile(fileFieldName, filePath, contentType)
	else
		request:addFormFile(fileFieldName, filePath)
	end

	if datas.extra then
		for i in ipairs(datas.extra) do
			local data = datas.extra[i]

			request:addFormContents(data[1], data[2])
		end
	end

	request:start()

	return request
end

local function parseTrueFalse(t)
	t = string.lower(tostring(t))

	if t == "yes" or t == "true" then
		return true
	end

	return false
end

function network.makeCookieString(cookie)
	local arr = {}

	for name, value in pairs(cookie) do
		if type(value) == "table" then
			value = tostring(value.value)
		else
			value = tostring(value)
		end

		arr[#arr + 1] = tostring(name) .. "=" .. string.urlencode(value)
	end

	return table.concat(arr, "; ")
end

function network.parseCookie(cookieString)
	local cookie = {}
	local arr = string.split(cookieString, "\n")

	for _, item in ipairs(arr) do
		item = string.trim(item)

		if item ~= "" then
			local parts = string.split(item, "\t")
			local c = {
				domain = parts[1],
				access = parseTrueFalse(parts[2]),
				path = parts[3],
				secure = parseTrueFalse(parts[4]),
				expire = checkint(parts[5]),
				name = parts[6],
				value = string.urldecode(parts[7])
			}
			cookie[c.name] = c
		end
	end

	return cookie
end

return network
