local res = {
	defaultPackName = "rs",
	imgs = {},
	maps = {},
	packs = {},
	caches_m2texs = {},
	caches_m2texs_fbo = {},
	caches_tex2 = {},
	caches_animation = {},
	caches_filters = {},
	defaults = {},
	WDUpts = {},
	remoteResDownTask = {},
	resDataPath = device.writablePath .. "res/data/"
}

function res.perload()
	if IS_PLAYER_DEBUG then
		return
	end

	if res.perloaded then
		return
	end

	res.perloaded = true

	for i, v in ipairs(def.perload) do
		local frame = v[3] or 1

		if v[4] then
			local skip = v[5] or 0

			for j = 0, 7 do
				for k = 1, frame do
					local tex, info = res.gettex(v[1], v[2] + j * (frame + skip) + k - 1, 1)

					if info.loading then
						info.loading[#info.loading + 1] = {
							call = function(value)
								if value then
									value:retain()
								end
							end
						}
					end

					if def.openWD and info.download then
						info.download[#info.download + 1] = {
							call = function(tex)
								if tex then
									tex:retain()
								end
							end
						}
					end
				end
			end
		else
			for j2 = 1, frame do
				local tex2, info2 = res.gettex(v[1], v[2] + j2 - 1, 1)

				if info2.loading then
					info2.loading[#info2.loading + 1] = {
						call = function(tex)
							if tex then
								tex:retain()
							end
						end
					}
				end

				if def.openWD and info2.download then
					info2.download[#info2.download + 1] = {
						call = function(value)
							if value then
								value:retain()
							end
						end
					}
				end
			end
		end
	end
end

function res.addSpriteFrameLists()
	if def.plists then
		for _, plist in ipairs(def.plists) do
			display.addSpriteFrames("pic/bzmir/plist/" .. plist .. ".plist", "pic/bzmir/plist/" .. plist .. ".png")
		end
	end
end

local position = cc.Node.setPosition

function res.makeTexForFBO(imgid, idxbegin, frame)
	if res.caches_m2texs_fbo[imgid] and res.caches_m2texs_fbo[imgid][idxbegin] then
		return
	end

	local texs = {}
	local wcnt = 0
	local hmax = 0

	for i = 1, frame do
		local tex, info = res.gettex(imgid, idxbegin + i - 1)
		local detail = clone(info)

		texs[#texs + 1] = detail

		if not info.err then
			detail.pos = wcnt
			wcnt = wcnt + info.w
			hmax = math.max(hmax, info.h)
		end

		res.removeinfo(imgid, idxbegin + i - 1)
	end

	if wcnt == 0 or hmax == 0 then
		return
	end

	local canvas = cc.RenderTexture:create(wcnt, hmax, cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)

	canvas:begin()

	for i2, v in ipairs(texs) do
		if not v.err then
			local spr = display.newSprite(v.tex):flipY(true)

			position(spr, v.pos + spr:getw() / 2, hmax - spr:geth() / 2)
			spr:visit()
		end
	end

	canvas:endToLua()

	local tex2 = canvas:getSprite():getTexture()

	tex2:retain()

	if not res.caches_m2texs_fbo[imgid] then
		res.caches_m2texs_fbo[imgid] = {}
	end

	res.caches_m2texs_fbo[imgid][idxbegin] = {
		tex = tex2,
		frame = frame,
		details = texs
	}

	for i3, v2 in ipairs(texs) do
		if v2 and v2.tex then
			v2.tex:release()

			v2.tex = nil
		end
	end
end

function res.getFBO(imgid, idxbegin, frame)
	local fbos = res.caches_m2texs_fbo[imgid]

	if fbos then
		local fbo = fbos[idxbegin]

		return fbo and fbo.frame == frame and fbo
	end
end

scheduler.scheduleGlobal(function()
	if main_scene and main_scene.ui and def.bzm2debugFullinfo then
		print("===资源统计与优化===")
		print("caches_m2texs:", table.nums(res.caches_m2texs))
		print("caches_tex2:", table.nums(res.caches_tex2))
		print("caches_animation:", table.nums(res.caches_animation))
		print("imgs:", table.nums(res.imgs))
		print("packs:", table.nums(res.packs))
		print("maps:", table.nums(res.maps))
		print(string.format("当前内存占用: %0.2f KB", collectgarbage("count")))
		print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
		print("===资源统计与优化===")
	end

	for k, v in pairs(res.caches_animation) do
		if not v.mark and v.ani:getReferenceCount() == 1 then
			v.ani:release()

			res.caches_animation[k] = nil
		end

		v.mark = nil
	end

	for imgid, v2 in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v2) do
			if not texinfo.loading and not texinfo.err and not texinfo.download then
				if texinfo.mark then
					texinfo.mark = nil
				elseif texinfo.tex and not tolua.isnull(texinfo.tex) and texinfo.tex:getReferenceCount() == 1 then
					texinfo.tex:release()

					v2[idx] = nil
				end
			end
		end
	end
end, 60)

function res:joinDownQueue(key)
	if self == "layer" then
		return
	end

	for _, remoteResDownTask in pairs(res.remoteResDownTask) do
		if remoteResDownTask and remoteResDownTask.imgid == self then
			return
		end
	end

	table.insert(res.remoteResDownTask, {
		imgid = self,
		key = key
	})
	gmprint("join down queue<" .. self .. ">")
end

function res.purgeCachedData()
	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err and texinfo.tex and texinfo.tex:getReferenceCount() == 1 then
				texinfo.tex:release()

				v[idx] = nil
			end
		end
	end

	for k, v2 in pairs(res.caches_tex2) do
		if not v2.err and v2.tex:getReferenceCount() == 1 then
			v2.tex:release()

			res.caches_tex2[k] = nil
		end
	end

	for k2, v3 in pairs(res.caches_animation) do
		v3.ani:release()
	end

	res.caches_animation = {}

	for k3, v4 in pairs(res.imgs) do
		ycRes:release(v4)
	end

	res.imgs = {}

	for k4, v5 in pairs(res.packs) do
		ycRes:release(v5)
	end

	res.packs = {}

	for k5, v6 in pairs(res.maps) do
		if k5 ~= g_using_map_id then
			mir2map:release(v6)
		end
	end

	res.maps = {}
end

function res_loadEndForAsync(imgid, idx, tex)
	local infos = res.caches_m2texs[imgid]
	local info

	if infos then
		info = infos[idx]
	end

	if not info then
		p2("res", "res_loadEndForAsync -> info not found!", key)

		if tex then
			tex:release()
		end

		return
	end

	info.tex = tex
	info.err = tex == nil

	if info.loading then
		for i, v in ipairs(info.loading) do
			v.call(tex)
		end
	end

	info.loading = nil
end

function res.getMir2TexCount()
	local cnt = 0

	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err and texinfo.tex then
				cnt = cnt + 1
			end
		end
	end

	return cnt
end

function res.reloadAllTex(tasks)
	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err and texinfo.tex then
				local tex = texinfo.tex
				local image

				if def.newResCompiledV8 then
					image = res.loadimage(imgid):makeImage(idx, false)
				else
					image = res.loadimg(imgid):makeImage(idx, false)
				end

				tex:releaseGLTexture()
				tex:initWithImage(image)
			end
		end
	end

	for k, v2 in pairs(res.caches_tex2) do
		if not v2.err then
			local tex2 = v2.tex
			local image2

			if def.newResCompiledV8 then
				image2 = res.getpackage(v2.packname):makeImageWithFilename(v2.filename)
			else
				image2 = res.getpack(v2.packname):makeImageWithFilename(v2.filename)
			end

			tex2:releaseGLTexture()
			tex2:initWithImage(image2)
		end
	end

	res.remoteResDownTask = {}
end

function res.tex2Key(filename, packname)
	return filename .. bzmir.line .. packname
end

function res.frameKey(imgid, idx, setOffset2)
	return imgid .. bzmir.line .. idx .. bzmir.line .. (setOffset2 and "1" or "0")
end

function res:animationKey(value, value2, value3, value4)
	return self .. bzmir.line .. value .. bzmir.line .. value2 .. bzmir.line .. value3 .. bzmir.line .. (value4 and "1" or "0")
end

function res.default()
	if not res.defaults.tex1 then
		res.defaults.tex1 = cc.Director:getInstance():getTextureCache():addImage("public/default.png")

		res.defaults.tex1:retain()
	end

	return res.defaults.tex1
end

function res.default2()
	if not res.defaults.tex2 then
		res.defaults.tex2 = cc.Director:getInstance():getTextureCache():addImage("public/empty.png")

		res.defaults.tex2:retain()
	end

	return res.defaults.tex2
end

function res.defaultFrame()
	if not res.defaults.frame then
		res.defaults.frame = cc.SpriteFrame:createWithTexture(res.default2(), cc.rect(0, 0, 32, 32))

		res.defaults.frame:retain()
	end

	return res.defaults.frame
end

function res.loadimg(imgid)
	local img = res.imgs[imgid]

	if not img then
		img = ycRes:create(1, imgid, "data/" .. imgid .. ".zip", "")
		res.imgs[imgid] = img
	end

	return img
end

function res.getinfo(imgid, idx, needLoad)
	local infos = res.caches_m2texs[imgid]
	local value

	if infos then
		local info = infos[idx]

		if info then
			return info
		end
	end

	if needLoad then
		local x
		local y
		local w
		local h

		if def.newResCompiledV8 then
			x, y, w, h = res.loadimage(imgid):getTexInfo(idx)
		else
			x, y, w, h = res.loadimg(imgid):getTexInfo(idx)
		end

		if x then
			return {
				x = x,
				y = y,
				w = w,
				h = h
			}
		end
	end
end

function res.removeinfo(imgid, idx)
	local infos = res.caches_m2texs[imgid]

	if infos and infos[idx] then
		infos[idx] = nil
	end
end

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function res:getItems(item, index, index2, index3)
	return res.get(self, index)
end

function res.get(imgid, idx, setOffset2, asyncPriority, blend, class)
	local spriteClass = class or cc.Sprite
	local sprite
	local tex, info = res.gettex(imgid, idx, asyncPriority)

	if info.err then
		sprite = spriteClass:createWithTexture(res.default2(), cc.rect(0, 0, info.w or 2, info.h or 2))
	else
		if info.loading or info.download then
			sprite = spriteClass:createWithTexture(res.default(), cc.rect(0, 0, info.w, info.h))
		else
			sprite = spriteClass:createWithTexture(tex)
		end

		if setOffset2 then
			sprite:anchor(0, 1)
			position(sprite, info.x, -info.y)
		end
	end

	if asyncPriority and info.loading then
		sprite:setNodeEventEnabled(true)

		function sprite.onCleanup()
			for i, v in ipairs(info.loading) do
				if v.sprite == sprite then
					table.remove(info.loading, i)

					break
				end
			end
		end

		info.loading[#info.loading + 1] = {
			sprite = sprite,
			call = function(tex)
				sprite:setNodeEventEnabled(false)

				if tex then
					sprite:setTex(tex)
				end
			end
		}
	end

	if def.openWD and info.download then
		sprite:setNodeEventEnabled(true)

		function sprite.onCleanup()
			for index, download in ipairs(info.download) do
				if download.sprite == sprite then
					table.remove(info.download, index)

					break
				end
			end
		end

		info.download[#info.download + 1] = {
			sprite = sprite,
			call = function(value)
				sprite:setNodeEventEnabled(false)

				if value then
					sprite:setTex(value)
				end
			end
		}
	end

	return sprite
end

function res:remoteResDownComplate()
	if not self then
		return
	end

	cache.removeDiy("needWDUpts", self)
	gmprint("remove upt log<" .. self .. ">")

	for _, remoteResDownTask in pairs(res.remoteResDownTask) do
		if remoteResDownTask and remoteResDownTask.imgid == self and remoteResDownTask.key and res.caches_tex2 then
			res.caches_tex2[remoteResDownTask.key] = nil

			break
		end
	end

	if not res.caches_m2texs then
		return
	end

	local value = res.caches_m2texs[self]

	if not value then
		return
	end

	for itemId, item in pairs(value) do
		local tex
		local items

		if item.fromCUS then
			tex = res.gettexforCUS(self, itemId, true)
			items = {
				w = 2,
				x = 0,
				h = 2,
				y = 0,
				tex = tex
			}
		else
			tex, items = res.gettex(self, itemId, nil, nil, true)
		end

		if not tex then
			return
		end

		if item.download then
			for _2, download in ipairs(item.download) do
				download.call(items.tex)
			end
		end

		item.download = nil
		item = items
	end

	for _3, remoteResDownTask2 in pairs(res.remoteResDownTask) do
		if remoteResDownTask2 and remoteResDownTask2.imgid == self then
			table.removebyvalue(res.remoteResDownTask, remoteResDownTask2)

			return
		end
	end
end

function res.gettexforCUS(imgid, idx, value)
	local infos = res.caches_m2texs[imgid]

	if not infos then
		infos = {}
		res.caches_m2texs[imgid] = infos
	end

	local info = infos[idx]

	if not info or value then
		local tex
		local x = 0
		local y = 0
		local w = 2
		local h = 2

		if def.newResCompiledV8 then
			tex = res.loadimage(imgid):getTexWithFilename(idx .. ".png")
		else
			tex = res.loadimg(imgid):getTexWithFilename(idx .. ".png")
		end

		if tex then
			info = {
				err = false,
				tex = tex,
				x = x,
				y = y,
				w = w,
				h = h
			}
		elseif def.openWD then
			if cache.getDiy("needWDUpts", imgid) or not io.exists(res.resDataPath .. imgid .. ".zip") then
				res.joinDownQueue(imgid)
			end

			info = {
				err = true,
				h = 2,
				y = 0,
				w = 2,
				fromCUS = true,
				x = 0,
				tex = res.default2(),
				download = {}
			}
		else
			info = {
				err = true
			}
		end

		infos[idx] = info
	end

	info.mark = true

	if def.openWD and info.tex then
		info.tex.imgid = imgid
		info.tex.idx = idx
	end

	return info.tex, info
end

function res.gettex(imgid, idx, asyncPriority, value, value2)
	local infos = res.caches_m2texs[imgid]

	if not infos then
		infos = {}
		res.caches_m2texs[imgid] = infos
	end

	local info = infos[idx]

	if not info or value2 then
		local tex
		local x
		local y
		local w
		local h

		if def.newResCompiledV8 then
			tex, x, y, w, h = res.loadimage(imgid):getTex(idx, asyncPriority or 0)
		else
			tex, x, y, w, h = res.loadimg(imgid):getTex(idx, asyncPriority or 0)
		end

		if tex then
			info = {
				tex = tex,
				x = x,
				y = y,
				w = w,
				h = h
			}
		elseif w > 0 and asyncPriority and asyncPriority > 0 then
			info = {
				x = x,
				y = y,
				w = w,
				h = h,
				loading = {}
			}
		elseif def.openWD then
			if cache.getDiy("needWDUpts", imgid) or not io.exists(res.resDataPath .. imgid .. ".zip") then
				res.joinDownQueue(imgid)
			end

			info = {
				err = true,
				h = 2,
				y = 0,
				w = 2,
				x = 0,
				tex = res.default2(),
				download = {}
			}

			if asyncPriority and asyncPriority > 0 then
				info.loading = {}
			end
		else
			p2("res", "res.gettex faild!", imgid, idx, w, asyncPriority)

			info = {
				err = true
			}
		end

		infos[idx] = info
	end

	info.mark = true

	if def.openWD and info.tex then
		info.tex.imgid = imgid
		info.tex.idx = idx
	end

	return info.tex, info
end

function res:getCusUi(value)
	return res.gettex(self, value)
end

function res.getui(uiidx, idx)
	local imgid = "prguse"

	if uiidx > 1 then
		imgid = imgid .. uiidx
	end

	return res.get(imgid, idx)
end

function res.getuitex(uiidx, idx)
	local imgid = "prguse"

	if uiidx > 1 then
		imgid = imgid .. uiidx
	end

	return res.gettex(imgid, idx)
end

local setOffset = cc.SpriteFrame.setOffset
local setTexture = cc.SpriteFrame.setTexture
local getReferenceCount = cc.Ref.getReferenceCount
local release = cc.Ref.release

function res.getframe(imgid, idx, setOffset2, asyncPriority, blend)
	local frame
	local tex, info = res.gettex(imgid, idx, asyncPriority, blend)

	if info and tex then
		if info.err then
			frame = res.defaultFrame()
		else
			if info.loading or info.download then
				frame = cc.SpriteFrame:createWithTexture(res.default(), cc.rect(0, 0, info.w, info.h))
			else
				frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getContentSize().width, tex:getContentSize().height))
			end

			if setOffset2 then
				setOffset(frame, cc.p(info.x, -info.y))
			end
		end

		if asyncPriority and info.loading then
			frame:retain()

			info.loading[#info.loading + 1] = {
				call = function(tex)
					if getReferenceCount(frame) > 1 then
						frame:setTexture(tex)
					end

					release(frame)
				end
			}
		end

		if def.openWD and info.download then
			frame:retain()

			info.download[#info.download + 1] = {
				call = function(value)
					if getReferenceCount(frame) > 1 then
						frame:setTexture(value)
					end

					release(frame)
				end
			}
		end
	end

	return frame
end

function res.getani(imgid, beginidx, endidx, delay, setOffset2, isReversed, asyncPriority, blend)
	local step = 1

	if isReversed then
		beginidx = endidx
		endidx = beginidx
		step = -1
	end

	local key = res.animationKey(imgid, beginidx, endidx, delay, setOffset2)
	local animationInfo = res.caches_animation[key]

	if animationInfo then
		animationInfo.mark = true

		return animationInfo.ani
	end

	local frames = {}

	for index = beginidx, endidx, step do
		local frame = res.getframe(imgid, index, setOffset2, asyncPriority, blend)

		if frame then
			frames[#frames + 1] = frame
		else
			break
		end
	end

	if #frames > 0 then
		local animation = cc.Animation:createWithSpriteFrames(frames, delay)

		animation:retain()

		res.caches_animation[key] = {
			mark = true,
			ani = animation
		}

		return animation
	end
end

function res.loadmap(mapid)
	local map = res.maps[mapid]

	if not map then
		local value = cache.unzipMapFile(mapid)
		local fullpath = cache.getMapFilePath(mapid)

		map = mir2map:create(fullpath)
		res.maps[mapid] = map
	end

	return map
end

function res.unLoadmap(mapid)
	for k, v in pairs(res.maps) do
		if mapid == k then
			mir2map:release(v)

			res.maps[mapid] = nil

			break
		end
	end
end

function res.getpack(packname)
	local pack = res.packs[packname]

	if not pack then
		pack = ycRes:create(1, packname, packname .. ".zip", "")
		res.packs[packname] = pack
	end

	return pack
end

local function callback(self, value, value2)
	value2 = value2 or "wb"

	local file = io.open(self, value2)

	if file then
		if file:write(value) == nil then
			return false
		end

		io.close(file)

		return true
	else
		return false
	end
end

local function callback2(self, value2)
	local value = core_func_md5(self .. "_sme" .. value2, false)
	local value3 = (device.writablePath .. "res/") .. value .. "/"
	local value4 = value3 .. value .. ".zip"

	if io.exists(value4) then
		return value .. "/" .. value
	end

	if not io.exists(value3) then
		ycFunction:mkdir(value3)
	end

	local fileData, fileData2 = ycFunction:getFileData(self .. ".zip", true)

	if fileData then
		local text = "GJ@*8" .. core_func_md5(cache.getDiy("cc", "cip"), false)
		local value5 = core_func_decryptTEA(fileData, text)

		callback(value4, value5)

		return value .. "/" .. value
	end

	return self
end

local function callback3(self, value2)
	local value = core_func_md5(self .. "_sme" .. value2, false)
	local value3 = device.writablePath .. "res/data/"

	if not io.exists(value3) then
		ycFunction:mkdir(value3)
	end

	local value4 = value3 .. value .. "/"
	local value5 = value4 .. value .. ".zip"

	if io.exists(value5) then
		return value .. "/" .. value
	end

	if not io.exists(value4) then
		ycFunction:mkdir(value4)
	end

	local fileData, fileData2 = ycFunction:getFileData("data/" .. self .. ".zip", true)

	if fileData then
		local text = "GJ@*8" .. core_func_md5(cache.getDiy("cc", "cip"), false)
		local value6 = core_func_decryptTEA(fileData, text)

		callback(value5, value6)

		return value .. "/" .. value
	end

	return self
end

function res.getpackage(packname)
	local pack = res.packs[packname]

	if not pack then
		local packname2 = packname

		if def.compiledPack and def.compiledPack[packname] then
			packname2 = callback2(packname, def.compiledPack[packname])
		end

		pack = ycRes:create(1, packname, packname2 .. ".zip", "")
		res.packs[packname] = pack
	end

	return pack
end

function res:loadimage()
	local rawData = res.imgs[self]

	if not rawData then
		local value = self

		if def.compiledRes and def.compiledRes[self] then
			value = callback3(self, def.compiledRes[self])
		end

		rawData = ycRes:create(1, self, "data/" .. value .. ".zip", "")
		res.imgs[self] = rawData
	end

	return rawData
end

function res.getfile(filename, packname)
	if def.bLazyLoadConfig then
		local value = (device.writablePath .. "config/" .. def.serverId .. "/" .. def.zoneid .. "/") .. filename

		return (io.readfile(value))
	elseif USE_SOURCE_RES then
		return ycFunction:getFileData(filename, false)
	elseif def.newResCompiledV8 then
		return res.getpackage(packname or res.defaultPackName):getFileData(filename)
	else
		return res.getpack(packname or res.defaultPackName):getFileData(filename)
	end
end

function res.get2_helper(filename, x, y, params, packname)
	return res.get2(filename, x, y, params, packname)
end

function res:get2(value, value2, value3, value4, value5)
	return display.newSprite(res.gettex2(self, value4, value5), value, value2, value3)
end

function res:getaniframe(value, value3, value5)
	value3 = value3 or 10
	value = value or 1
	value5 = value5 or 1

	local text = "pic/bzmir/plist/ani/"
	local value2 = self .. "%02d.png"
	local value4 = text .. self .. ".plist"
	local value6 = text .. self .. ".png"

	display.addSpriteFrames(value4, value6)

	local frames = display.newFrames(value2, value, value3)
	local animation = display.newAnimation(frames, value5 / value3)

	return display.newSprite(frames[1]), animation
end

function res.gettex2(filename, packname2, value)
	if USE_SOURCE_RES and (not packname2 or packname2 == res.defaultPackName) then
		return cc.Director:getInstance():getTextureCache():addImage(filename)
	end

	packname2 = packname2 or res.defaultPackName

	if packname2 == res.defaultPackName and type(filename) == "string" and string.byte(filename) == 35 then
		return display.newSpriteFrame(string.sub(filename, 2))
	end

	if type(filename) == "string" and string.find(filename, "resource") then
		return cc.Director:getInstance():getTextureCache():addImage(filename)
	end

	local packname = value or packname2
	local key = res.tex2Key(filename, packname)
	local info = res.caches_tex2[key]

	if not info then
		local tex

		if def.newResCompiledV8 then
			tex = res.getpackage(packname2):getTexWithFilename(filename)
		else
			tex = res.getpack(packname2):getTexWithFilename(filename)
		end

		if tex then
			info = {
				tex = tex,
				packname = packname2,
				filename = filename
			}
		else
			info = {
				err = true,
				tex = res.default2()
			}
		end

		res.caches_tex2[key] = info
	end

	if def.openWD and packname2 ~= res.defaultPackName then
		local text = string.gsub(packname2, "data/", "")

		if cache.getDiy("needWDUpts", text) or not io.exists(res.resDataPath .. text .. ".zip") then
			res.joinDownQueue(text, key)
		end
	end

	return info.tex, info.err
end

function res.getframe2(filename, packname)
	local tex = res.gettex2(filename, packname)

	if tex then
		return cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getContentSize().width, tex:getContentSize().height))
	end
end

function res:getani2(beginidx, endidx, delay, value)
	local key = res.animationKey(self, beginidx, endidx, delay)
	local animationInfo = res.caches_animation[key]

	if animationInfo then
		animationInfo.mark = true

		return animationInfo.ani
	end

	local frames = {}

	for i = beginidx, endidx do
		local text = res.gettex2(string.format(self, i), value)

		if not text or not text.getContentSize(text) or text.getContentSize(text).width == 2 then
			break
		end

		local frame = cc.SpriteFrame:createWithTexture(text, cc.rect(0, 0, text.getContentSize(text).width, text.getContentSize(text).height))

		frames[#frames + 1] = frame
	end

	if #frames > 0 then
		local animation = cc.Animation:createWithSpriteFrames(frames, delay)

		animation.retain(animation)

		res.caches_animation[key] = {
			mark = true,
			ani = animation
		}

		return animation
	end
end

function res.getFilter(key)
	local f = res.caches_filters[key]

	if f then
		return f
	end

	if key == "gray" then
		local params = {
			0.2,
			0.3,
			0.5,
			0.1
		}

		f = filter.newFilter("GRAY", params)
	elseif key == "outline_skill" then
		local params2 = {
			shaderName = "outline_skill",
			u_threshold = 0.75,
			u_radius = 0.02,
			frag = "public/tex_outline.fsh",
			u_outlineColor = {
				1,
				0,
				1
			}
		}

		f = filter.newFilter("CUSTOM", json.encode(params2))
	elseif key == "outline_role" then
		local params3 = {
			shaderName = "outline_role",
			u_threshold = 0.75,
			u_radius = 0.01,
			frag = "public/tex_outline.fsh",
			u_outlineColor = {
				1,
				0.2,
				0.2
			}
		}

		f = filter.newFilter("CUSTOM", json.encode(params3))
	elseif key == "high_light" then
		local params4 = {
			shaderName = "high_light",
			frag = "public/tex_hightlight.fsh"
		}

		f = filter.newFilter("CUSTOM", json.encode(params4))
	end

	f:retain()

	res.caches_filters[key] = f

	return f
end

return res
