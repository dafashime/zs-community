function Byte(num)
	return ycFunction:band(num, 255)
end

function Word(num)
	return ycFunction:band(num, 65535)
end

function Hibyte(num)
	return ycFunction:band(num, 65280) / 256
end

function Lobyte(num)
	return ycFunction:band(num, 255)
end

function Hiword(num)
	return ycFunction:band(num, 4294901760) / 65536
end

function Loword(num)
	return ycFunction:band(num, 65535)
end

function MakeLong(a, b)
	b = Word(b)
	a = Word(a)

	return ycFunction:bor(a, ycFunction:lshift(b, 16))
end

function MakeWord(a, b)
	b = Byte(b)
	a = Byte(a)

	return ycFunction:bor(a, ycFunction:lshift(b, 8))
end

function getJobStr(job)
	if job == 0 then
		return "战士"
	elseif job == 1 then
		return "法师"
	elseif job == 2 then
		return "道士"
	elseif job == 3 then
		return "刺客"
	elseif def.jobMaps then
		return def.jobMaps[tostring(job)].name or "未知职业"
	else
		return "未知职业"
	end
end

function getSexStr(sex)
	if sex == 0 then
		return "男"
	end

	return "女"
end

function getMapStateStr(state)
	if state == cAreaStateFight then
		return "[战斗]"
	elseif state == cAreaStateSafe then
		return "[安全]"
	elseif state == cAreaStateGuildWar then
		return "[攻城]"
	elseif state == cAreaStateDareWar then
		return "[挑战]"
	elseif state == cAreaStateReliveable then
		return "[可复活]"
	end

	return ""
end

function getTakeOnPosition(smode)
	if smode == 5 or smode == 6 then
		return U_WEAPON
	elseif smode == 10 or smode == 11 then
		return U_DRESS
	elseif smode == 30 then
		return U_RIGHTHAND
	elseif smode == 19 or smode == 20 or smode == 21 then
		return U_NECKLACE
	elseif smode == 15 then
		return U_HELMET
	elseif smode == 16 then
		return U_MASK
	elseif smode == 24 or smode == 26 then
		return U_ARMRINGR
	elseif smode == 22 or smode == 23 then
		return U_RINGL
	elseif smode == 25 then
		return U_BUJUK
	elseif smode == 27 then
		return U_BELT
	elseif smode == 28 then
		return U_BOOTS
	elseif smode == 7 then
		return U_CHARM
	elseif smode == 29 then
		return U_YuPei
	elseif smode == 34 then
		return U_Horse
	elseif smode == 75 then
		return U_XueYu
	end
end

function newList()
	local first
	local last
	local list
	local listManager = {
		pushFront = function(value)
			first = first - 1
			list[first] = value
		end,
		pushBack = function(value)
			last = last + 1
			list[last] = value
		end,
		popFront = function()
			if first <= last then
				local value = list[first]

				list[first] = nil
				first = first + 1

				return value
			end
		end,
		popBack = function()
			if first <= last then
				local value = list[last]

				list[last] = nil
				last = last - 1

				return value
			end
		end,
		clear = function()
			list = {}
			last = 0
			first = 1
		end,
		isEmpty = function()
			if last < first then
				last = 0
				first = 1
			end

			return last < first
		end,
		size = function()
			if last < first then
				return 0
			end

			return last - first + 1
		end
	}

	listManager.clear()

	return listManager
end

function checkMd5()
	local items = {
		"636F7",
		"2652E6",
		"2696E"
	}
	local items2 = ""

	for _, item in ipairs(items) do
		items2 = items2 .. item
	end

	local text = ""

	for index = 1, #items2, 2 do
		text = text .. string.char(tonumber(string.sub(items2, index, index + 1), 16))
	end

	local fileData, fileData2 = ycFunction:getFileData(text, true)
	local items3 = {
		"598eaa67b",
		"00deb",
		"9b566db",
		"baeabcb1699"
	}
	local text2 = ""

	for _2, item2 in ipairs(items3) do
		text2 = text2 .. item2
	end

	if string.lower(fileData2) ~= text2 then
		cc.Director:getInstance():endToLua()
		core_func_byby()
	end
end

function testNetList()
	local lst = newList()

	for k = 1, 100 do
		lst.pushBack(k)
	end

	while not lst.isEmpty() do
		local k3 = lst.popFront()

		print("testNetList", k3)

		if k3 < 50 and k3 > 40 then
			lst.pushBack(k3 + 23487)
		end
	end

	for k2 = 1, 100 do
		lst.pushBack(k2)
	end

	while not lst.isEmpty() do
		print("testNetList", lst.popFront())
	end

	print("testNetList", lst.popFront())
end

function printscreen(node, args)
	local sp = true
	local file
	local filters
	local filterParams

	if args then
		if args.sprite ~= nil then
			sp = args.sprite
		end

		file = args.file
		filters = args.filters
		filterParams = args.filterParams
	end

	local size = node.getContentSize(node)
	local canvas = cc.RenderTexture:create(size.width, size.height)

	canvas.begin(canvas)
	node.visit(node)
	canvas.endToLua(canvas)

	if sp then
		local texture = canvas.getSprite(canvas):getTexture()

		if filters then
			sp = display.newFilteredSprite(texture, filters, filterParams)
		else
			sp = display.newSprite(texture)
		end

		sp.flipY(sp, true)
	end

	if file then
		canvas.saveToFile(canvas, file)
	end

	return sp, file
end

function TDateTimeToUnixDate(time)
	local startTm = 25569.33333333

	return math.floor((time - startTm) * 86400)
end

function makeMinimap(mapid, path, w)
	local file = res.loadmap(mapid)

	if not file or file.getw(file) == 0 or file.geth(file) == 0 then
		return
	end

	local def = require("mir2.scenes.main.map.def")
	local maptile = require("mir2.scenes.main.map.maptile")
	local mapw = file.getw(file)
	local maph = file.geth(file)

	w = w or math.max(math.min(mapw * def.tile.w / 8, math.max(2048, mapw)), 256)

	local mapNode = display.newNode():scale(w / (mapw * def.tile.w))
	local bgLayer = display.newNode():addto(mapNode)
	local midLayer = display.newNode():addto(mapNode)
	local objLayer = display.newNode():addto(mapNode)
	local maxh = 0

	for i = 1, mapw do
		for j = 1, maph do
			local data = file.gettile(file, i, j)

			if data then
				maxh = maptile.addTile(data, i, j, bgLayer, midLayer, objLayer, maph, maxh)
			end
		end
	end

	local maxh2 = maxh * mapNode.getScale(mapNode)
	local node = display.newNode():size(w, maxh2):add(mapNode, 1)

	display.newColorLayer(cc.c4b(0, 0, 0, 255)):size(node.getContentSize(node)):add2(node)
	printscreen(node, {
		file = path
	})

	return true
end

function trim0str(str)
	local ret = ""

	for s in string.gmatch(str, "[^%z]") do
		ret = ret .. s
	end

	return ret
end

function traversalNodeTree(n, cb)
	if tolua.isnull(n) then
		return true
	end

	if not cb(n) then
		return false
	end

	for _, v in ipairs(n.getChildren(n)) do
		if not traversalNodeTree(v, cb) then
			return false
		end
	end

	return true
end

function setGlobalZOrderCascade(n, zorder)
	traversalNodeTree(n, function(n)
		n.setGlobalZOrder(n, zorder)
	end)
end

function isChildOf(testNode, parent)
	local ok = false

	traversalNodeTree(parent, function(n)
		if n == testNode then
			ok = true
		else
			return true
		end
	end)

	return ok
end

function parseJson(jsonFile)
	local config_json = res.getfile(jsonFile)

	if config_json == "" then
		assert(false, "can't find file " .. jsonFile)

		return nil
	end

	assert(jsonFile ~= config_json, "WTF???")

	return (require("cjson").decode(config_json))
end

function playAni(parent, pattern, frame, delay, blend, isProg)
	local texs = {}

	for i = 1, frame do
		local tex = cc.Director:getInstance():getTextureCache():addImage(string.format(pattern .. "0_%05d.png", i - 1))

		if tex then
			texs[#texs + 1] = tex
		end
	end

	local texIdx = 1
	local sprite = display.newSprite(texs[texIdx]):addTo(parent)

	local function uptBlendFunc()
		if blend then
			sprite:setBlendFunc(gl.ONE, gl.ONE_MINUS_SRC_COLOR)
		end
	end

	uptBlendFunc()
	sprite.addNodeEventListener(sprite, cc.NODE_ENTER_FRAME_EVENT, function(value)
		if sprite.lasttime then
			local nowtime = socket.gettime()

			if (delay or 0.3) <= nowtime - sprite.lasttime then
				sprite.lasttime = nowtime
				texIdx = texIdx + 1
				texIdx = frame < texIdx and 1 or texIdx

				sprite:setTexture(texs[texIdx])
				uptBlendFunc()
			end
		else
			sprite.lasttime = socket.gettime()
		end
	end)
	sprite.scheduleUpdate(sprite)

	return sprite
end

valueScopeTimer = class("valueScopeTimer")

function valueScopeTimer:ctor(from, to, cb, duration)
	self.from = from
	self.to = to
	self.cb = cb
	self.duration = duration
	self.consume = 0
	self.isRunning = nil
end

function valueScopeTimer:start(host)
	self.host = host

	local listener = handler(self, self.update)

	if host then
		self.handler = host.schedule(host, listener, 0)
	else
		self.handler = scheduler.scheduleUpdateGlobal(listener)
	end

	self.isRunning = true
	self.consume = 0
end

function valueScopeTimer:stop()
	if self.isRunning then
		if self.host then
			self.host:stopAction(self.handler)
		else
			scheduler.unscheduleGlobal(self.handler)
		end

		self.isRunning = false
	end
end

function valueScopeTimer:update(dt)
	if type(dt) ~= "number" then
		dt = cc.Director:getInstance():getDeltaTime()
	end

	self.consume = self.consume + dt

	local per = self.consume / self.duration

	if per >= 1 then
		per = 1

		self.stop(self)
	end

	self.cb(self.from + per * (self.to - self.from))
end
