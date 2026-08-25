local map = {
	mapTitle = "",
	mapState = 0,
	mapReplace = {},
	safezones = {}
}

function map:setSafeZone(count, buf, bufLen)
	self.safezones = {}

	for i = 1, count do
		local point

		point, buf, bufLen = net.record("TStartPoint", buf, bufLen)

		local points = self.safezones[point:get("startMap")]

		if not points then
			points = {}
			self.safezones[point:get("startMap")] = points
		end

		points[#points + 1] = {
			x = point:get("x"),
			y = point:get("y"),
			rang = point:get("rang") == 0 and 9 or point:get("rang")
		}
	end
end

function map:isInSafeZone(mapid, x, y)
	if ycFunction:band(cAreaStateSafe, self.mapState) ~= 0 then
		return true
	end

	local points = self.safezones[mapid]

	if not points then
		return
	end

	for i, v in ipairs(points) do
		if math.abs(v.x - x) <= v.rang and math.abs(v.y - y) <= v.rang then
			return true
		end
	end
end

function map:isSeeSafeZoneEdge(mapid, x, y, w, h)
	local points = self.safezones[mapid]

	if not points then
		return
	end

	local ret

	for i, v in ipairs(points) do
		if math.abs(v.x - x) <= v.rang + w and math.abs(v.y - y) <= v.rang + h then
			ret = ret or {}
			ret[#ret + 1] = v
		end
	end

	return ret
end

function map:setMapState(state)
	self.mapState = state
end

function map:setMapTitle(title)
	self.mapTitle = title
end

function map:setMapReplaceTable(buf, bufLen)
	self.mapReplace = {}

	local strs = net.strs(buf or "", ";")

	for i, v in ipairs(strs) do
		local arr = string.split(v, ",")

		if #arr == 2 then
			self.mapReplace[string.trim(arr[1])] = string.trim(arr[2])
		end
	end
end

return map
