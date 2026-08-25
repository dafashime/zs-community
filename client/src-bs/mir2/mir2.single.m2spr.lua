local m2sprMgr = {
	aniIdCnt = 0,
	debuginfo = "",
	texIdCnt = 0,
	texQueue = {},
	aniQueue = {},
	lasttime = socket.gettime(),
	aniTimeCache = {},
	aniNextTimeCache = {}
}

setmetatable(m2sprMgr.aniTimeCache, {
	__mode = "k"
})
setmetatable(m2sprMgr.aniNextTimeCache, {
	__mode = "k"
})

local m2spr = nil

function m2sprMgr.new(...)
	return m2spr.new(...)
end

function m2sprMgr.playAnimation(...)
	return m2spr.playAnimation(...)
end

local syncLoads = {}
local syncMustLoads = {}
local asyncLoads = {}

setmetatable(syncLoads, {
	__mode = "kv"
})
setmetatable(syncMustLoads, {
	__mode = "kv"
})
setmetatable(asyncLoads, {
	__mode = "kv"
})

function m2sprMgr:loop()
	local nowtime = socket.gettime()
	local dt = nowtime - self.lasttime
	self.lasttime = nowtime
	local needUpt = m2spr.needUpt
	local upt = m2spr.upt
	local aniUpt = m2spr.aniUpt
	local texQueue = self.texQueue
	local aniTimeCache = m2sprMgr.aniTimeCache
	local aniNextTimeCache = m2sprMgr.aniNextTimeCache

	for v, k in pairs(self.aniQueue) do
		local delay = nil
		local start = aniTimeCache[v]

		if aniNextTimeCache[v] <= nowtime then
			delay = aniUpt(v, nowtime - start)
			aniNextTimeCache[v] = nowtime + delay
		end
	end

	syncLoads.num = 0
	syncMustLoads.num = 0
	asyncLoads.num = 0
	local texQueueNums = nil

	if DEBUG > 0 then
		texQueueNums = table.nums(texQueue)
	end

	local insert = table.insert

	for v, k in pairs(texQueue) do
		local info = res.getinfo(v.imgid, v.idx)

		if info then
			if info.loading then
				v.asyncRequested = true
			else
				upt(v, info)

				texQueue[v] = nil
			end
		elseif v.asyncPriority then
			if not v.asyncRequested then
				asyncLoads.num = asyncLoads.num + 1

				insert(asyncLoads, asyncLoads.num, v)
			end
		elseif v.ani and not v.ani.noForever then
			syncLoads.num = syncLoads.num + 1

			insert(syncLoads, syncLoads.num, v)
		else
			syncMustLoads.num = syncMustLoads.num + 1

			insert(syncMustLoads, syncMustLoads.num, v)
		end
	end

	local resGetTex = res.gettex
	local resGetInfo = res.getinfo
	local begin = socket.gettime()

	for k = 1, syncMustLoads.num do
		local v = syncMustLoads[k]
		local _, info = resGetTex(v.imgid, v.idx)

		upt(v, info)

		texQueue[v] = nil
	end

	for k = 1, syncLoads.num do
		local v = syncLoads[k]
		local _, info = resGetTex(v.imgid, v.idx)

		upt(v, info)

		texQueue[v] = nil
		syncLoads[k] = nil

		if socket.gettime() - begin > 0.02 then
			break
		end
	end

	for k = 1, syncLoads.num do
		local v = syncLoads[k]

		if v then
			local info = resGetInfo(v.imgid, v.idx)

			if info then
				upt(v, info)

				texQueue[v] = nil
			end
		end
	end

	for k = 1, asyncLoads.num do
		local v = asyncLoads[k]
		v.asyncRequested = true
		local _, info = resGetTex(v.imgid, v.idx, v.asyncPriority)

		if not info.loading then
			upt(v, info)

			texQueue[v] = nil
		end
	end

	if DEBUG > 0 then
		self.debuginfo = {
			table.nums(texQueue) .. "/" .. texQueueNums,
			table.nums(self.aniQueue),
			string.format("%.4f", socket.gettime() - nowtime)
		}
		self.debuginfo = table.concat(self.debuginfo, "-")
	end
end

function m2sprMgr.printAni()
	local st = {}

	for k, v in pairs(m2sprMgr.aniQueue) do
		st[k.ctorStack] = st[k.ctorStack] or {
			setIdx0 = 0,
			num = 0,
			frame = {}
		}
		st[k.ctorStack].num = st[k.ctorStack].num + 1
		st[k.ctorStack].frame[k.ani.lastIdx or "??"] = st[k.ctorStack].frame[k.ani.lastIdx or "??"] or 0
		st[k.ctorStack].frame[k.ani.lastIdx or "??"] = st[k.ctorStack].frame[k.ani.lastIdx or "??"] + 1

		if k.tozero > 2 then
			st[k.ctorStack].setIdx0 = st[k.ctorStack].setIdx0 + 1
		end
	end

	print("#####################################################")
	print("#####################################################")
	print("#####################################################")

	for k, v in pairs(st) do
		if v.num > 1000 then
			local str = "### "

			for k, v in pairs(v.frame) do
				str = str .. k .. "," .. v .. "   #"
			end

			print(v.num, str, v.setIdx0, k)
		end
	end
end

function m2sprMgr.addTexQueue(node)
	m2sprMgr.texQueue[node] = true
end

function m2sprMgr.removeTexQueue(node)
	m2sprMgr.texQueue[node] = nil
end

function m2sprMgr.addAniQueue(node)
	m2sprMgr.aniQueue[node] = true
end

function m2sprMgr.removeAniQueue(node)
	m2sprMgr.aniQueue[node] = nil
end

m2spr = class("m2spr")
local __setVisible = cc.Node.setVisible
local __getIsInsideBounds = ycM2Sprite.getIsInsideBounds
local __setCenterOffset = ycM2Sprite.setCenterOffset
local __setContentSize = cc.Node.setContentSize
local __getContentSize = cc.Node.getContentSize
local __setPosition = cc.Node.setPosition
local __setBlendFunc = cc.Sprite.setBlendFunc
local __setTextureAutoSetRect = ycM2Sprite.setTextureAutoSetRect
local __setFlippedX = cc.Sprite.setFlippedX
local __setAnchorPoint = cc.Node.setAnchorPoint
local __addTextureFrame = ycM2Sprite.addTextureFrame
local __playAniAction = ycM2Sprite.playAniAction

table.merge(m2spr, {
	imgid,
	idx,
	setOffset,
	blend,
	syncPriority,
	asyncPriority,
	asyncRequested,
	unknowSize,
	texQueueID,
	aniQueueID,
	ani,
	isShow
})

local etcVer = [[
//ver
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec2 v_alphaCoord;  
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_alphaCoord;  
#endif

void main()
{
    gl_Position = CC_PMatrix * a_position;
    v_fragmentColor = a_color;
    v_texCoord = a_texCoord;
    v_alphaCoord = v_texCoord + vec2(0.0, 0.5);  
}
]]
local etcFrag = [[
//Frag

#ifdef GL_ES
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_texCoord;
varying mediump vec2 v_alphaCoord;
#else
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_alphaCoord;  
#endif

void main()
{
    if(v_texCoord.y >= 0.5){
    	gl_FragColor = vec4(0,0,0,0);
    	return;
    }
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);
    texColor.a = texture2D(CC_Texture0, v_alphaCoord).r;
    gl_FragColor = texColor * v_fragmentColor;
}
]]
local etcProgram = cc.GLProgram:createWithByteArrays(etcVer, etcFrag)

etcProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, 4)
etcProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
etcProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
etcProgram:link()
etcProgram:updateUniforms()
etcProgram:retain()

function m2spr:add2(...)
	self.spr:add2(...)

	return self
end

function m2spr:addto(...)
	self.spr:add2(...)

	return self
end

function m2spr:addTo(...)
	self.spr:add2(...)

	return self
end

function m2spr:hide()
	self:setVisible(false)

	return self
end

function m2spr:show()
	self:setVisible(true)

	return self
end

function m2spr:anchor(...)
	__setAnchorPoint(self.spr, ...)

	return self
end

function m2spr:runs(...)
	self.spr:runs(...)

	return self
end

function m2spr:pos(x, y)
	__setPosition(self.spr, x, y)

	return self
end

function m2spr:flipX(...)
	__setFlippedX(self.spr, ...)

	return self
end

function m2spr:flipY(...)
	__setFlippedY(self.spr, ...)

	return self
end

function m2spr:run(...)
	self.spr:run(...)

	return self
end

function m2spr:runs(...)
	self.spr:runs(...)

	return self
end

function m2spr:setScaleX(...)
	self.spr:setScaleX(...)

	return self
end

function m2spr:setScaleY(...)
	self.spr:setScaleY(...)

	return self
end

function m2spr:setFilter(...)
	self.spr:setFilter(...)

	return self
end

function m2spr:removeSelf()
	self.spr:removeSelf()
end

function m2spr:ctor(imgid, idx, params)
	local inst = ycM2Sprite:create(res.default2(), params and params.setOffset, params and params.blend)

	function inst.onCleanup()
		self:onCleanup()
	end

	self.spr = inst
	params = params or {}
	self.imgid = imgid
	self.idx = idx
	self.setOffset = params.setOffset
	self.blend = params.blend
	self.asyncPriority = params.asyncPriority
	self.isShow = true

	inst:setNodeEventEnabled(true)

	self.onctor = true

	self:texChanged()
end

function m2spr:onCleanup()
	self.cleared = true

	m2sprMgr.removeTexQueue(self)
	m2sprMgr.removeAniQueue(self)
end

function m2spr:needUpt()
	return __getIsInsideBounds(self.spr)
end

function m2spr:setVisible(b)
	__setVisible(self.spr, b)

	self.isShow = b

	if b then
		self:texChanged()

		if self.ani then
			m2sprMgr.addAniQueue(self)
		end
	else
		m2sprMgr.removeAniQueue(self)
		m2sprMgr.removeTexQueue(self)
	end
end

function m2spr:getContentSize()
	if self.unknowSize then
		self.unknowSize = nil
		local info = res.getinfo(self.imgid, self.idx, true)

		if info and not info.err then
			__setContentSize(self.spr, info.w, info.h)
		else
			__setContentSize(self.spr, 0, 0)
		end
	end

	return __getContentSize(self.spr)
end

function m2spr:setBlend(blend)
	if self.blend ~= blend then
		self.blend = blend

		self:updateBlendFunc()
	end
end

function m2spr:updateBlendFunc()
	if self.blend then
		__setBlendFunc(self.spr, gl.ONE, gl.DST_ALPHA)
	else
		__setBlendFunc(self.spr, gl.ONE, gl.ONE_MINUS_SRC_ALPHA)
	end
end

function m2spr:texChanged()
	if self.imgid and self.idx then
		self.unknowSize = true
		self.asyncRequested = nil

		m2sprMgr.addTexQueue(self)
	end
end

local __setGLProgram = cc.Node.setGLProgram

function m2spr:upt(info)
	if info.err then
		__setTextureAutoSetRect(self.spr, res.default2())

		return
	end

	local tex = info.tex
	local x = info.x
	local y = info.y
	local w = info.w
	local h = info.h

	if not tex then
		-- Nothing
	end

	if self.setOffset and y then
		__setCenterOffset(self.spr, x, -y)
	end

	if tolua.type(tex) == "cc.SpriteFrame" then
		__setSpriteFrame(self.spr, tex)
	else
		__setTextureAutoSetRect(self.spr, tex)
	end

	self.unknowSize = nil
end

function m2spr:setImg(imgid, idx)
	if self.imgid ~= imgid or self.idx ~= idx then
		self.imgid = imgid
		self.idx = idx

		self:texChanged()
	end
end

_G.useCppAni = true

function m2spr:playAni(img, begin, frame, delay, blend, autoRemove, noForever, callback, asyncPriority, nextIdxSpace)
	self.asyncPriority = asyncPriority

	if not frame then
		p2("error", "playAni frame nil: img=" .. tostring(img) .. " begin=" .. tostring(begin) .. " delay=" .. tostring(delay) .. " " .. debug.traceback("", 2))
	end

	if _G.useCppAni then
		self.ani = {
			dt = 0,
			img = img,
			begin = begin,
			frame = frame,
			delay = delay or 0.1,
			noForever = noForever,
			callback = callback or noForever and autoRemove and handler(self, self.removeSelf),
			nextIdxSpace = nextIdxSpace or 1
		}

		m2sprMgr.removeTexQueue(self)

		local nt = game.loopBegin or socket.gettime()
		m2sprMgr.aniTimeCache[self] = nt
		m2sprMgr.aniNextTimeCache[self] = nt

		self:setBlend(blend)

		if self.isShow then
			m2sprMgr.addAniQueue(self)
		end
	else
		nextIdxSpace = nextIdxSpace or 1
		delay = delay or 0.1

		for idx = begin, begin + frame * nextIdxSpace do
			local frame = res.getframe(img, idx, self.setOffset, 1)

			__addTextureFrame(self.spr, frame, idx)
		end

		__playAniAction(self.spr, begin, frame, delay, false, nextIdxSpace, not noForever, autoRemove, callback and cc.CallFunc:create(callback))
	end

	return self
end

function m2spr.playAnimation(img, begin, frame, delay, blend, autoRemove, noForever, callback, noSetOffset, asyncPriority, nextIdxSpace)
	local ani = m2spr.new(nil, nil, {
		setOffset = not noSetOffset,
		blend = blend
	}):playAni(img, begin, frame, delay, blend, autoRemove, noForever, callback, asyncPriority, nextIdxSpace)

	return ani.spr, ani
end

function m2spr:stopAnimation()
	self.ani = nil

	m2sprMgr.removeAniQueue(self)
end

function m2spr:aniUpt(dt)
	local data = self.ani
	local delay = data.delay
	local idx = math.floor(dt / delay)

	if idx > data.frame - 1 then
		if data.noForever then
			self:stopAnimation()

			if data.callback then
				data.callback(self)
			end

			return 0
		else
			idx = idx % data.frame
		end
	end

	if data.lastIdx == idx then
		return delay - dt % delay
	end

	data.lastIdx = idx
	local imgIdx = data.begin + idx * data.nextIdxSpace

	self:setImg(data.img, imgIdx)

	return delay - dt % delay
end

local listener = cc.EventListenerCustom:create("director_after_update", handler(m2sprMgr, m2sprMgr.loop))

cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

return m2sprMgr
