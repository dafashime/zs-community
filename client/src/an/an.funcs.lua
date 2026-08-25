local lfs = require("lfs")

function checkExist(t, ...)
	local arr = {
		...
	}

	for i, v in ipairs(arr) do
		if v == t then
			return true
		end
	end
end

function checkIn(t, a, b, ...)
	if type(a) == "number" and type(b) == "number" then
		return a <= t and t <= b
	end

	local array = {
		a,
		b,
		...
	}

	for i, v in ipairs(array) do
		if v[1] <= t and t <= v[2] then
			return true
		end
	end
end

function utf8strs(str)
	local len = #str
	local left = 0
	local arr = {
		0,
		192,
		224,
		240,
		248,
		252
	}
	local t = {}
	local start = 1
	local wordLen = 0

	while len ~= left do
		local tmp = string.byte(str, start)

		if not tmp then
			print("utf8strs -> tmp is nil???", str)

			break
		end

		local i = #arr

		while arr[i] do
			if arr[i] <= tmp then
				break
			end

			i = i - 1
		end

		wordLen = i + wordLen
		local tmpString = string.sub(str, start, wordLen)
		start = start + i
		left = left + i
		t[#t + 1] = tmpString
	end

	return t
end

function string.utf8sub(input, p, l)
	local len = string.len(input)
	local index = 1
	local pp = 0
	local ll = 0
	local cnt = 0
	local arr = {
		0,
		192,
		224,
		240,
		248,
		252
	}

	while index <= len do
		local tmp = string.byte(input, index)
		local i = #arr
		local tt = 0

		while arr[i] do
			if arr[i] <= tmp then
				index = index + i
				tt = i

				break
			end

			i = i - 1
		end

		cnt = cnt + 1

		if p == cnt and pp == 0 then
			pp = index - tt
		end

		if l == cnt and ll == 0 then
			ll = index - 1
		end
	end

	local ret = string.sub(input, pp, ll)

	return ret
end

function int2ip(value)
	local ByteArray = require("framework.cc.utils.ByteArray")
	local src = ByteArray.new():writeUInt(value):setPos(1)
	local a = src:readByte()
	local b = src:readByte()
	local c = src:readByte()
	local d = src:readByte()

	return string.format("%d.%d.%d.%d", a, b, c, d)
end

function sortNodes(t)
	table.sort(t, function (n2, n1)
		return n1:getLocalZOrder() < n2:getLocalZOrder() or n1:getLocalZOrder() == n2:getLocalZOrder() and n1:getOrderOfArrival() < n2:getOrderOfArrival()
	end)

	return t
end

function change2GoldStyle(text)
	text = tonumber(text)
	text = tostring(text)
	local ret = {}
	local cnt = 0

	for i = #text, 1, -1 do
		local v = string.byte(text, i) - string.byte("0")

		table.insert(ret, 1, v)

		cnt = cnt + 1

		if cnt >= 3 then
			cnt = 0

			if i > 1 then
				table.insert(ret, 1, ",")
			end
		end
	end

	return table.concat(ret)
end

function colorIsEqual(c1, c2)
	return c1.r == c2.r and c1.g == c2.g and c1.b == c2.b and c1.a == c1.a
end

function rmdir(path)
	if io.exists(path) then
		local function _rmdir(path)
			local iter, dir_obj = lfs.dir(path)

			while true do
				local dir = iter(dir_obj)

				if dir == nil then
					break
				end

				if dir ~= "." and dir ~= ".." then
					local curDir = path .. dir
					local mode = lfs.attributes(curDir, "mode")

					if mode == "directory" then
						_rmdir(curDir .. "/")
					elseif mode == "file" then
						os.remove(curDir)
					end
				end
			end

			local succ, des = os.remove(path)

			if des then
				print(des)
			end

			return succ
		end

		_rmdir(path)
	end

	return true
end

function avoidPlugValue(value, isDecode)
	if isDecode then
		return crypto.decryptXXTEA(value, "avoidPlugValue")
	else
		return crypto.encryptXXTEA(value, "avoidPlugValue")
	end
end

function display.newRoundRect(rect, params)
	local fillColor = params.fillColor
	local borderColor = params.borderColor
	local borderWidth = params.borderWidth
	local radius = params.radius
	local segments = 100
	local origin = cc.p(rect.x, rect.y)
	local destination = cc.p(rect.x + rect.width, rect.y + rect.height)
	local points = {}
	local coef = math.pi / 2 / segments
	local vertices = {}

	for i = 0, segments do
		local rads = (segments - i) * coef
		local x = radius * math.sin(rads)
		local y = radius * math.cos(rads)

		table.insert(vertices, cc.p(x, y))
	end

	local tagCenter = cc.p(0, 0)
	local minX = math.min(origin.x, destination.x)
	local maxX = math.max(origin.x, destination.x)
	local minY = math.min(origin.y, destination.y)
	local maxY = math.max(origin.y, destination.y)
	local pPolygonPtArr = {}
	tagCenter.x = minX + radius
	tagCenter.y = maxY - radius

	for i = 0, segments do
		local x = tagCenter.x - vertices[i + 1].x
		local y = tagCenter.y + vertices[i + 1].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	tagCenter.x = maxX - radius
	tagCenter.y = maxY - radius

	for i = 0, segments do
		local x = tagCenter.x + vertices[#vertices - i].x
		local y = tagCenter.y + vertices[#vertices - i].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	tagCenter.x = maxX - radius
	tagCenter.y = minY + radius

	for i = 0, segments do
		local x = tagCenter.x + vertices[i + 1].x
		local y = tagCenter.y - vertices[i + 1].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	tagCenter.x = minX + radius
	tagCenter.y = minY + radius

	for i = 0, segments do
		local x = tagCenter.x - vertices[#vertices - i].x
		local y = tagCenter.y - vertices[#vertices - i].y

		table.insert(pPolygonPtArr, cc.p(x, y))
	end

	if fillColor == nil then
		fillColor = cc.c4f(0, 0, 0, 0)
	end

	local drawNode = cc.DrawNode:create()

	drawNode:drawPolygon(pPolygonPtArr, params)

	return drawNode
end
