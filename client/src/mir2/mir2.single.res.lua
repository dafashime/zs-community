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
	defaults = {}
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
		local is8 = v[4]

		if is8 then
			local skip = v[5] or 0

			for j = 0, 7 do
				for k = 1, frame do
					local tex, info = res.gettex(v[1], v[2] + j * (frame + skip) + k - 1, 1)

					if info.loading then
						info.loading[#info.loading + 1] = {
							call = function (tex)
								if tex then
									tex:retain()
								end
							end
						}
					end
				end
			end
		else
			for j = 1, frame do
				local tex, info = res.gettex(v[1], v[2] + j - 1, 1)

				if info.loading then
					info.loading[#info.loading + 1] = {
						call = function (tex)
							if tex then
								tex:retain()
							end
						end
					}
				end
			end
		end
	end
end

local __position = cc.Node.setPosition

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

	for i, v in ipairs(texs) do
		if not v.err then
			local spr = display.newSprite(v.tex):flipY(true)

			__position(spr, v.pos + spr:getw() / 2, hmax - spr:geth() / 2)
			spr:visit()
		end
	end

	canvas:endToLua()

	local tex = canvas:getSprite():getTexture()

	tex:retain()

	if not res.caches_m2texs_fbo[imgid] then
		res.caches_m2texs_fbo[imgid] = {}
	end

	res.caches_m2texs_fbo[imgid][idxbegin] = {
		tex = tex,
		frame = frame,
		details = texs
	}

	for i, v in ipairs(texs) do
		v.tex:release()

		v.tex = nil
	end
end

function res.getFBO(imgid, idxbegin, frame)
	local fbos = res.caches_m2texs_fbo[imgid]

	if fbos then
		local fbo = fbos[idxbegin]

		return fbo and fbo.frame == frame and fbo
	end
end

scheduler.scheduleGlobal(function ()
	for k, v in pairs(res.caches_animation) do
		if not v.mark and v.ani:getReferenceCount() == 1 then
			v.ani:release()

			res.caches_animation[k] = nil
		end

		v.mark = nil
	end

	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err then
				if texinfo.mark then
					texinfo.mark = nil
				elseif texinfo.tex and texinfo.tex:getReferenceCount() == 1 then
					texinfo.tex:release()

					v[idx] = nil
				end
			end
		end
	end

	if DEBUG > 0 then
		local bytesCnt = 0
		local cnt = 0

		for imgid, v in pairs(res.caches_m2texs) do
			for idx, texinfo in pairs(v) do
				if not texinfo.loading and not texinfo.err and texinfo.tex.getPixelsWide then
					bytesCnt = bytesCnt + texinfo.tex:getPixelsWide() * texinfo.tex:getPixelsHigh() * texinfo.tex:getBitsPerPixelForFormat() / 8
				end

				cnt = cnt + 1
			end
		end

		p2("res", "caches_m2texs:", cnt)
		p2("res", "caches_animation:", table.nums(res.caches_animation))
		p2("res", string.format("use texture memory: %.02f MB", bytesCnt / 1048576))
	end
end, 60)

function res.purgeCachedData()
	for imgid, v in pairs(res.caches_m2texs) do
		for idx, texinfo in pairs(v) do
			if not texinfo.loading and not texinfo.err and texinfo.tex and texinfo.tex:getReferenceCount() == 1 then
				texinfo.tex:release()

				v[idx] = nil
			end
		end
	end

	for k, v in pairs(res.caches_tex2) do
		if not v.err and v.tex:getReferenceCount() == 1 then
			v.tex:release()

			res.caches_tex2[k] = nil
		end
	end

	for k, v in pairs(res.caches_animation) do
		v.ani:release()
	end

	res.caches_animation = {}

	for k, v in pairs(res.imgs) do
		ycRes:release(v)
	end

	res.imgs = {}

	for k, v in pairs(res.packs) do
		ycRes:release(v)
	end

	res.packs = {}

	for k, v in pairs(res.maps) do
		mir2map:release(v)
	end

	res.maps = {}
end

function res_loadEndForAsync(imgid, idx, tex)
	local infos = res.caches_m2texs[imgid]
	local info = nil

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
				local image = res.loadimg(imgid):makeImage(idx, false)

				tex:releaseGLTexture()
				tex:initWithImage(image)
			end
		end
	end

	for k, v in pairs(res.caches_tex2) do
		if not v.err then
			local tex = v.tex
			local image = res.getpack(v.packname):makeImageWithFilename(v.filename)

			tex:releaseGLTexture()
			tex:initWithImage(image)
		end
	end
end

function res.tex2Key(filename, packname)
	return filename .. "-" .. packname
end

function res.frameKey(imgid, idx, setOffset)
	return imgid .. "-" .. idx .. "-" .. (setOffset and "1" or "0")
end

function res.animationKey(imgid, beginidx, endidx, delay)
	return imgid .. "-" .. beginidx .. "-" .. endidx .. "-" .. delay .. "-" .. (setOffset and "1" or "0")
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
	local info = nil

	if infos then
		info = infos[idx]

		if info then
			return info
		end
	end

	if needLoad then
		local x, y, w, h = res.loadimg(imgid):getTexInfo(idx)

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

	if infos then
		infos[idx] = nil
	end
end

function res.get(imgid, idx, setOffset, asyncPriority, blend, class)
	local spriteClass = class or cc.Sprite
	local sprite = nil
	local tex, info = res.gettex(imgid, idx, asyncPriority)

	if info.err then
		sprite = spriteClass:createWithTexture(res.default2(), cc.rect(0, 0, 2, 2))
	else
		if info.loading then
			sprite = spriteClass:createWithTexture(res.default(), cc.rect(0, 0, info.w, info.h))
		else
			sprite = spriteClass:createWithTexture(tex)
		end

		if setOffset then
			sprite:anchor(0, 1)
			__position(sprite, info.x, -info.y)
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
			call = function (tex)
				sprite:setNodeEventEnabled(false)

				if tex then
					sprite:setTex(tex)
				end
			end
		}
	end

	return sprite
end

function res.gettex(imgid, idx, asyncPriority)
	local infos = res.caches_m2texs[imgid]

	if not infos then
		infos = {}
		res.caches_m2texs[imgid] = infos
	end

	local info = infos[idx]

	if not info then
		local tex, x, y, w, h = res.loadimg(imgid):getTex(idx, asyncPriority or 0)

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
		else
			p2("res", "res.gettex faild!", imgid, idx, w, asyncPriority)

			info = {
				err = true
			}
		end

		infos[idx] = info
	end

	info.mark = true

	return info.tex, info
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

local __setOffset = cc.SpriteFrame.setOffset
local __setTexture = cc.SpriteFrame.setTexture
local __getReferenceCount = cc.Ref.getReferenceCount
local __release = cc.Ref.release

function res.getframe(imgid, idx, setOffset, asyncPriority, blend)
	local frame = nil
	local tex, info = res.gettex(imgid, idx, asyncPriority, blend)

	if info.err then
		frame = res.defaultFrame()
	else
		if info.loading then
			frame = cc.SpriteFrame:createWithTexture(res.default(), cc.rect(0, 0, info.w, info.h))
		else
			frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getContentSize().width, tex:getContentSize().height))
		end

		if setOffset then
			__setOffset(frame, cc.p(info.x, -info.y))
		end
	end

	if asyncPriority and info.loading then
		frame:retain()

		info.loading[#info.loading + 1] = {
			call = function (tex)
				if __getReferenceCount(frame) > 1 then
					frame:setTexture(tex)
				end

				__release(frame)
			end
		}
	end

	return frame
end

function res.getani(imgid, beginidx, endidx, delay, setOffset, isReversed, asyncPriority, blend)
	local step = 1

	if isReversed then
		beginidx = endidx
		endidx = beginidx
		step = -1
	end

	local key = res.animationKey(imgid, beginidx, endidx, delay, setOffset)
	local animationInfo = res.caches_animation[key]

	if animationInfo then
		animationInfo.mark = true

		return animationInfo.ani
	end

	local frames = {}

	for index = beginidx, endidx, step do
		local frame = res.getframe(imgid, index, setOffset, asyncPriority, blend)

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
		cache.unzipMapFile(mapid)

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
		print("Create Pack:", packname)

		pack = ycRes:create(1, packname, packname .. ".zip", "")
		res.packs[packname] = pack
	end

	return pack
end

function res.getfile(filename, packname)
	if def.bLazyLoadConfig then
		local dir = device.writablePath .. "config/" .. def.serverId .. "/" .. def.zoneid .. "/"
		local filePath = dir .. filename

		print("bLazyLoadConfig filePath", filePath)

		local rawData = io.readfile(filePath)

		return rawData
	elseif USE_SOURCE_RES then
		return ycFunction:getFileData(filename, false)
	else
		return res.getpack(packname or res.defaultPackName):getFileData(filename)
	end
end

function res.get2_helper(filename, x, y, params, packname)
	if DEBUG > 0 and not IS_PLAYER_DEBUG then
		local tex = cc.Director:getInstance():getTextureCache():addImage(filename)
		tex = tex or res.gettex2(filename, packname)

		return display.newSprite(tex, x, y, params)
	else
		return res.get2(filename, x, y, params, packname)
	end
end

function res.get2(filename, x, y, params, packname)
	return display.newSprite(res.gettex2(filename, packname), x, y, params)
end

function res.gettex2(filename, packname)
	if USE_SOURCE_RES and (not packname or packname == res.defaultPackName) then
		return cc.Director:getInstance():getTextureCache():addImage(filename)
	end

	packname = packname or res.defaultPackName
	local key = res.tex2Key(filename, packname)
	local info = res.caches_tex2[key]

	if not info then
		local tex = res.getpack(packname):getTexWithFilename(filename)

		if tex then
			info = {
				tex = tex,
				packname = packname,
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

	return info.tex, info.err
end

function res.getframe2(filename, packname)
	local tex = res.gettex2(filename, packname)

	if tex then
		return cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getContentSize().width, tex:getContentSize().height))
	end
end

function res.getani2(filenameformat, beginidx, endidx, delay)
	local key = res.animationKey(filenameformat, beginidx, endidx, delay, setOffset)
	local animationInfo = res.caches_animation[key]

	if animationInfo then
		animationInfo.mark = true

		return animationInfo.ani
	end

	local frames = {}

	for i = beginidx, endidx do
		local tex = res.gettex2(string.format(filenameformat, i))
		local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getContentSize().width, tex:getContentSize().height))
		frames[#frames + 1] = frame
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
		local params = {
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
		f = filter.newFilter("CUSTOM", json.encode(params))
	elseif key == "outline_role" then
		local params = {
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
		f = filter.newFilter("CUSTOM", json.encode(params))
	elseif key == "high_light" then
		local params = {
			shaderName = "high_light",
			frag = "public/tex_hightlight.fsh"
		}
		f = filter.newFilter("CUSTOM", json.encode(params))
	end

	f:retain()

	res.caches_filters[key] = f

	return f
end

return res
