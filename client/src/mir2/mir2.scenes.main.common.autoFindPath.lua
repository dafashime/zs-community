local mapDef = import("..map.def")
local autoFindPath = class("autoFindPath")
autoFindPath.pathFinder = pathFinder:create()

table.merge(autoFindPath, {
	sprMark,
	openlist,
	closelist,
	points,
	destx,
	desty,
	destmap,
	scriptAuto
})

function autoFindPath:singleMapPathStop()
	if self.sprMark then
		self.sprMark:removeSelf()

		self.sprMark = nil
	end

	self.points = nil
	self.destx = nil
	self.desty = nil

	if main_scene and main_scene.ui.panels.bigmap then
		main_scene.ui.panels.bigmap:removeAllFindPath()
	end

	if main_scene and main_scene.ui.panels.bigmapOther then
		main_scene.ui.panels.bigmapOther:removeAllFindPath()
	end
end

function autoFindPath:multiMapPathStop()
	self.destmap = nil
	self.scriptAuto = false

	self:singleMapPathStop()
end

function autoFindPath:removePoint()
	if self.points and #self.points > 0 then
		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:removePoint(self:key(self.points[1].x, self.points[1].y))
		end

		if main_scene.ui.panels.bigmapOther then
			main_scene.ui.panels.bigmapOther:removePoint(self:key(self.points[1].x, self.points[1].y))
		end

		table.remove(self.points, 1)
	end
end

function autoFindPath:key(x, y)
	return x * 10000 + y
end

function autoFindPath:search__(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	local start = cc.p(startX, startY)
	start.priority = 0
	local startKey = self:key(startX, startY)
	local openlist = {
		[startKey] = start
	}
	local costlist = {
		[startKey] = 0
	}
	local map = main_scene.ground.map
	local toBanPoint = def.map.isBanPoint(destX, destY, main_scene.ground.map.mapid)
	local checkBlock = nil

	if ignoreRole then
		function checkBlock(block, banBlock)
			return not block and not banBlock or block == "hero" or block == "mon" or block == "npc"
		end
	else
		function checkBlock(block, banBlock)
			return not block and not banBlock
		end
	end

	local function getNeighbors(x, y)
		local n = {}

		for ox = -1, 1 do
			for oy = -1, 1 do
				n[self:key(x + ox, y + oy)] = cc.p(x + ox, y + oy)
			end
		end

		n[self:key(x, y)] = nil

		return n
	end

	local diagCost = math.sqrt(2)

	local function getCost(pre, next)
		if pre.x == next.x or pre.y == next.y then
			return 1
		else
			return diagCost
		end
	end

	local function heuristic(from)
		local dx = from.x - destX
		local dy = from.y - destY

		return math.sqrt(dx * dx + dy * dy)
	end

	local last = nil
	local cnt = 0

	while true do
		if searchLimit then
			cnt = cnt + 1

			if searchLimit < cnt then
				return nil
			end
		end

		local bestf = inf
		local current, curkey = nil

		for k, v in pairs(openlist) do
			if v.priority < bestf then
				bestf = v.priority
				current = v
				curkey = k
			end
		end

		if not current then
			return nil
		end

		local x = current.x
		local y = current.y

		if x == destX and y == destY then
			last = current

			break
		end

		if closeTo and math.max(math.abs(x - destX), math.abs(y - destY)) < closeTo then
			last = current

			break
		end

		openlist[curkey] = nil

		for _, neiPos in pairs(getNeighbors(x, y)) do
			local banBlock = not toBanPoint and def.map.isBanPoint(neiPos.x, neiPos.y, main_scene.ground.map.mapid) or nil
			local neikey = self:key(neiPos.x, neiPos.y)
			local curCost = getCost(current, neiPos) + costlist[curkey]

			if (not costlist[neikey] or curCost < costlist[neikey]) and checkBlock(map:canWalk(neiPos.x, neiPos.y, {
				useBlockInfo = true
			}).block, banBlock) then
				costlist[neikey] = curCost
				neiPos.priority = heuristic(neiPos)
				openlist[neikey] = neiPos
				neiPos.parent = current
			end
		end
	end

	if not last then
		return nil
	end

	local points = {}

	while last do
		table.insert(points, 1, {
			x = last.x,
			y = last.y,
			key = self:key(last.x, last.y)
		})

		last = last.parent
	end

	return points
end

function autoFindPath:getPath(startX, startY, destX, destY, map, searchLimit)
	local map = map or main_scene.ground.map

	if not map.file:isValid() then
		return nil
	end

	local start = cc.p(startX, startY)
	local goal = cc.p(destX, destY)

	if self.pathFinder:find({}, map.file, start, goal, 1, searchLimit or -1) then
		return self.pathFinder:getCurrentPath()
	end
end

function autoFindPath:search(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo, ignoreDoorPoint)
	if device.platform == "windows" and IS_PLAYER_DEBUG then
		return self:search__(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	else
		local map = main_scene.ground.map

		if not map.file:isValid() then
			return nil
		end

		closeTo = closeTo or 1

		if closeTo <= 1 and map:canWalk(destX, destY).block then
			return nil
		end

		local objBlocks = nil

		if ignoreRole then
			objBlocks = {}
		else
			objBlocks = map:getObjeBlocks()
		end

		if not ignoreDoorPoint then
			local map = main_scene.ground.map

			if mapDef.doorPoint[map.mapid] then
				for k, v in pairs(mapDef.doorPoint[map.mapid]) do
					if v.x ~= destX and v.y ~= destY then
						table.insert(objBlocks, cc.p(v.x, v.y))
					end
				end
			end
		end

		local start = cc.p(startX, startY)
		local dest = cc.p(destX, destY)

		if self.pathFinder:find(objBlocks, map.file, start, dest, closeTo, searchLimit or -1) then
			return self.pathFinder:getCurrentPath()
		end
	end
end

function autoFindPath:checkClose(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	if device.platform == "windows" and IS_PLAYER_DEBUG then
		return self:search__(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	else
		local roles = nil
		local map = main_scene.ground.map

		if not map.file:isValid() then
			return nil
		end

		if ignoreRole then
			roles = {}
		else
			roles = map:getObjeBlocks()
		end

		local start = cc.p(startX, startY)
		local goal = cc.p(destX, destY)

		return self.pathFinder:find(roles, map.file, start, goal, closeTo or 1, searchLimit or -1)
	end
end

function autoFindPath:getNeighbors(prex, prey, map, blockChecker, toBanPoint)
	local neighbors = {}

	for i = 0, 7 do
		local cfg = def.role.dir["_" .. i]
		local x = prex + cfg[1]
		local y = prey + cfg[2]
		local info = map:canWalk(x, y, {
			useBlockInfo = true
		})
		local banBlock = not toBanPoint and def.map.isBanPoint(x, y, main_scene.ground.map.mapid) or nil

		if blockChecker(info.block, banBlock) then
			table.insert(neighbors, cc.p(x, y))

			local x = prex + cfg[1] * 2
			local y = prey + cfg[2] * 2
			local info = map:canWalk(x, y, {
				useBlockInfo = true
			})
			local banBlock = not toBanPoint and def.map.isBanPoint(x, y, main_scene.ground.map.mapid) or nil

			if blockChecker(info.block, banBlock) then
				local pos = cc.p(x, y)
				pos.isRun = true

				table.insert(neighbors, cc.p(x, y))
			end
		end
	end

	return neighbors
end

function autoFindPath:search__(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	self.closelist = {}
	self.openlist = {
		[self:key(startX, startY)] = {
			g = 0,
			h = 0,
			f = 0,
			x = startX,
			y = startY
		}
	}
	local map = main_scene.ground.map
	local player = main_scene.ground.player
	local x = destX
	local y = destY

	local function getg(dir)
		return 10
	end

	local function geth(x, y)
		return math.sqrt(x * x + y * y)
	end

	local checkBlock = nil

	if ignoreRole then
		function checkBlock(block, banBlock)
			return not block and not banBlock or block == "hero" or block == "mon" or block == "npc"
		end
	else
		function checkBlock(block, banBlock)
			return not block and not banBlock
		end
	end

	local toBanPoint = def.map.isBanPoint(x, y, main_scene.ground.map.mapid)
	local stepCnt = 0

	local function go()
		while true do
			local best = nil
			local fbest = inf
			stepCnt = stepCnt + 1

			if searchLimit and searchLimit < stepCnt then
				return false
			end

			for _, v in pairs(self.openlist) do
				local f = v.f

				if f < fbest then
					fbest = f
					best = v
				end
			end

			if not best then
				return false
			end

			if closeTo then
				if math.abs(best.x - x) < closeTo and math.abs(best.y - y) < closeTo then
					return best
				end
			elseif best.x == x and best.y == y then
				return best
			end

			local key = self:key(best.x, best.y)
			self.closelist[key] = best
			self.openlist[key] = nil

			for i = 0, 7 do
				local config = def.role.dir["_" .. i]
				local nextx = best.x + config[1]
				local nexty = best.y + config[2]
				local info = map:canWalk(nextx, nexty, {
					useBlockInfo = true
				})
				local banBlock = not toBanPoint and def.map.isBanPoint(nextx, nexty, main_scene.ground.map.mapid) or nil

				if checkBlock(info.block, banBlock, nextx, nexty) then
					local key = self:key(nextx, nexty)

					if not self.closelist[key] then
						if not self.openlist[key] then
							self.openlist[key] = {
								x = nextx,
								y = nexty,
								g = getg(i),
								h = geth(nextx - x, nexty - y),
								f = getg(i) + geth(nextx - x, nexty - y),
								parent = best
							}
						end
					end
				end
			end
		end
	end

	local last = nil

	if not closeTo then
		local block = map:canWalk(x, y, {
			useBlockInfo = true
		}).block
		local isBanPoint = not toBanPoint and def.map.isBanPoint(x, y, main_scene.ground.map.mapid) or nil

		if checkBlock(block, isBanPoint) then
			last = go()
		end
	else
		last = go()
	end

	self.openlist = nil
	self.closelist = nil

	if not last then
		return nil
	end

	local points = {}

	while last do
		table.insert(points, 1, {
			x = last.x,
			y = last.y,
			key = self:key(last.x, last.y)
		})

		last = last.parent
	end

	return points
end

function autoFindPath:mergeRoute(startX, startY, points)
	local tmp = {
		x = startX,
		y = startY,
		key = self:key(startX, startY)
	}
	local tpoints = {}
	local i = 1

	while i <= #points do
		local v = points[i]
		local v2 = points[i + 1]

		if v and v2 then
			if v.x - tmp.x == v2.x - v.x and v.y - tmp.y == v2.y - v.y and math.max(math.abs(v2.x - tmp.x), math.abs(v2.y - tmp.y)) <= 2 then
				tpoints[#tpoints + 1] = v2
				tmp = v2
				i = i + 2
			else
				tpoints[#tpoints + 1] = v
				tmp = v
				i = i + 1
			end
		else
			tpoints[#tpoints + 1] = v
			i = i + 1
		end
	end

	return tpoints
end

function autoFindPath:searchForRun(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)
	self.closeTo = closeTo
	local points = self:search(startX, startY, destX, destY, searchLimit, ignoreRole, closeTo)

	if not points then
		return false
	end

	self.destx = destX
	self.desty = destY
	self.points = self:mergeRoute(startX, startY, points)

	return true
end

function autoFindPath:searching(x, y, destMapid, searchLimit, closeTo)
	self:singleMapPathStop()

	local map = main_scene.ground.map
	local player = main_scene.ground.player
	local destx = x
	local desty = y

	if not destMapid or destMapid == main_scene.ground.map.mapid then
		self.destmap = nil
	else
		local transferPoints = def.map.getTransferPoint(main_scene.ground.map.mapid, destMapid)

		if not transferPoints then
			self:multiMapPathStop()

			return main_scene.ui:tip("目标地图不支持自动寻路.")
		else
			local destblock = true

			for _, v in ipairs(transferPoints) do
				if not map:isObjblock(v.x, v.y).block then
					y = v.y
					x = v.x
					destblock = false

					break
				end
			end

			if destblock then
				self:multiMapPathStop()

				return main_scene.ui:tip("寻找不到前往目标点的路径.")
			end
		end

		self.destmap = {
			id = destMapid,
			x = destx,
			y = desty
		}
	end

	if self:searchForRun(player.x, player.y, x, y, searchLimit, false, closeTo) then
		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:change2CurMap()
			main_scene.ui.panels.bigmap:loadFindPathPoint(self.points)
		end

		if main_scene.ui.panels.bigmapOther then
			main_scene.ui.panels.bigmapOther:loadFindPathPoint(self.points)
		end
	else
		main_scene.ui:tip("寻找不到前往目标点的路径.")
	end
end

function autoFindPath:research()
	if self.scriptAuto then
		self:scriptAutoPath()
	elseif self.destmap then
		self:searching(self.destmap.x, self.destmap.y, self.destmap.id)
	elseif self.destx and self.desty then
		self:searching(self.destx, self.desty, nil, nil, self.closeTo)
	else
		self:multiMapPathStop()
	end
end

function autoFindPath:scriptAutoPath()
	local path = g_data.bigmap:getScriptPath(main_scene.ground.map.mapid)

	if path then
		self.scriptAuto = true

		self:searching(path.x, path.y)
	else
		self.scriptAuto = false
	end
end

return autoFindPath
