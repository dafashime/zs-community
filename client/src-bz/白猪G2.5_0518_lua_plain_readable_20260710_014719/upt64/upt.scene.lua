local lfs = require("lfs")
local def = import(".def")
local assetUpter = import(".assetUpter")
local msgbox = import(".msgbox")
local scene = class("upt", function()
	return display.newScene("upt")
end)
local socket = require("socket")
local scheduler = require("framework.scheduler")

table.merge(scene, {
	endFunc,
	newVerConfig,
	tasks,
	curBytes,
	allBytes,
	errCount,
	layer,
	bar,
	text,
	newVer
})

if device.platform == "mac" or device.platform == "windows" then
	scene.storagePath = device.writablePath .. "uptTest/"
else
	scene.storagePath = device.writablePath
end

scene.packageManifest = "project.manifest"

function scene:ctor(endFunc, force)
	self:checkResourceVersion()

	self.force = force
	self.endFunc = endFunc

	local n = display.newColorLayer(cc.c4b(255, 255, 255, 255)):size(display.width, display.height):addTo(self)

	n:setLocalZOrder(99999999)
	n:setTouchSwallowEnabled(true)
	n:setTouchEnabled(true)
	n:setCascadeOpacityEnabled(true)
	n:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
		return true
	end)

	local bg1 = display.newSprite("public/logo/LOGO.jpg"):center():addTo(n):opacity(0)

	bg1:setScaleX(display.width / 960)
	bg1:setScaleY(display.height / 640)

	local bg2 = display.newSprite("public/logo/LOGO.jpg"):center():addTo(n):opacity(0)

	bg2:setScaleX(display.width / 960)
	bg2:setScaleY(display.height / 640)

	local speedScale = 2

	bg1:runAction(cca.seq({
		cca.fadeIn(speedScale),
		cca.delay(speedScale),
		cca.fadeOut(speedScale),
		cca.callFunc(function()
			if self.force then
				scheduler.performWithDelayGlobal(endFunc, 0)
			end

			bg1:stopAllActions()
			bg2:runAction(cca.seq({
				cca.fadeIn(speedScale),
				cca.delay(speedScale * 0.4),
				cca.callFunc(function()
					if self.skipCheck then
						scheduler.performWithDelayGlobal(endFunc, 0)
						bg2:stopAllActions()
					end
				end),
				cca.delay(speedScale * 0.4),
				cca.callFunc(function()
					if not self.skipCheck then
						local bg = self.bg

						self:playAni(bg, "public/smoke/", 20, 0.1):pos(bg:getContentSize().width / 2 - 325, 335)
						self:playAni(bg, "public/hero/", 20, 0.1):pos(bg:getContentSize().width / 2 + 89, 270):scale(0.88)
						self:playAni(bg, "public/patricle/", 20, 0.1, true):pos(bg:getContentSize().width / 2 + 224, 237)
						self:playAni(bg, "public/fire/", 20, 0.1, true):pos(bg:getContentSize().width / 2 + 15, 70)
					end
				end),
				cca.callFunc(function()
					if self.skipCheck then
						scheduler.performWithDelayGlobal(endFunc, 0)
					else
						bg1:removeSelf()
						n:runAction(cca.seq({
							cca.fadeOut(1),
							cca.callFunc(function()
								n:removeAllNodeEventListeners()

								if self.skipCheck then
									scheduler.performWithDelayGlobal(endFunc, 0.1)
								else
									n:removeSelf()

									if device.platform == "android" and self.copyRes then
										scheduler.performWithDelayGlobal(self.copyRes, 0)
									end
								end
							end)
						}))
					end
				end)
			}))
		end)
	}))

	self.assetUpter = assetUpter.new(scene.packageManifest, scene.storagePath)

	self.assetUpter:setListener(self)

	if DEBUG > 0 then
		self.assetUpter:setCachePath(scene.storagePath, "globalUpdate")
		self.assetUpter:updateRemoteUrl()
	end

	self.layer = display.newNode():addTo(self)

	local bg = display.newSprite("public/uptbg.png"):addTo(self.layer):center()

	bg:setScaleX(display.width / bg:getContentSize().width)
	bg:setScaleY(display.height / bg:getContentSize().height)

	self.bg = bg

	display.newSprite("public/p1.png", bg:getContentSize().width / 2, 64):addTo(bg):setLocalZOrder(1)

	self.bar = self:playAni(bg, "public/progress/", 20, 0.1):pos(bg:getContentSize().width / 2 - 319, 64)

	self.bar:setLocalZOrder(1)
	self.bar:setAnchorPoint(cc.p(0, 0.5))

	local curVer = display.newTTFLabel({
		size = 20,
		x = 5,
		y = 630,
		text = "当前版本: " .. self.assetUpter:getCurVersion(),
		color = cc.c3b(222, 222, 150)
	}):addTo(self.layer)

	curVer:setAnchorPoint(cc.p(0, 1))

	self.curVer = curVer
	self.newVer = display.newTTFLabel({
		text = "",
		size = 20,
		x = 5,
		y = 600,
		color = cc.c3b(222, 222, 150)
	}):addTo(self.layer)

	self.newVer:setAnchorPoint(cc.p(0, 1))

	self.text = display.newTTFLabel({
		text = "",
		size = 20,
		y = 15,
		color = cc.c3b(222, 222, 150),
		x = display.cx
	}):addTo(self.layer)
	self.err = display.newTTFLabel({
		text = "",
		size = 20,
		x = 5,
		y = 570,
		color = cc.c3b(222, 222, 150)
	}):addTo(self.layer)

	self.err:setAnchorPoint(cc.p(0, 1))
end

function scene:saveRemoteAddress(addr)
	self.assetUpter:saveRemoteAddress(addr)
end

function scene:playAni(parent, pattern, frame, delay, blend, isProg)
	if not parent or not pattern then
		return
	end

	local texs = {}
	local textureCache = cc.Director:getInstance():getTextureCache()

	for i = 1, frame do
		local index = i

		textureCache:addImageAsync(string.format(pattern .. "0_%05d.png", i - 1), function(tex)
			if tex then
				texs[index] = tex
			end
		end)
	end

	local texIdx = 1
	local sprite = display.newSprite(string.format(pattern .. "0_%05d.png", 1)):addTo(parent)

	local function uptBlendFunc()
		if blend then
			sprite:setBlendFunc(gl.ONE, gl.ONE_MINUS_SRC_COLOR)
		end
	end

	uptBlendFunc()
	sprite:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
		if sprite.lasttime then
			local nowtime = socket.gettime()

			if nowtime - sprite.lasttime >= (delay or 0.3) then
				sprite.lasttime = nowtime
				texIdx = texIdx + 1
				texIdx = frame < texIdx and 1 or texIdx

				if texs[texIdx] then
					sprite:setTexture(texs[texIdx])
				end

				uptBlendFunc()
			end
		else
			sprite.lasttime = socket.gettime()
		end
	end)
	sprite:scheduleUpdate()

	return sprite
end

function scene:onAssetError(code, msg, curle, curlm)
	if code == assetUpter.EventCode.ERROR_NO_LOCAL_MANIFEST then
		self:setTitle("获取本地资源信息失败")
	elseif code == assetUpter.EventCode.ERROR_DOWNLOAD_MANIFEST or eventCode == assetUpter.EventCode.ERROR_PARSE_MANIFEST then
		local box
		local str = "获取版本信息失败, 请检查网络连接, 是否重试? "

		if DEBUG > 0 then
			str = str .. "\n(当前为调试版本,取消可跳过更新.)"
		end

		box = msgbox.new(str, function(isRetry)
			if isRetry then
				self.assetUpter:reset()
				self.assetUpter:checkUpt()
				box:removeSelf()
			elseif DEBUG > 0 then
				self.endFunc()
			else
				os.exit(0)
			end
		end)

		return
	elseif code == assetUpter.EventCode.ERROR_UPDATING or eventCode == assetUpter.EventCode.UPDATE_FAILED then
		local box2

		box2 = msgbox.new("网络状态不佳或远程服务器繁忙, 是否重试? ", function(isRetry)
			if isRetry then
				self.assetUpter:reset()
				self.assetUpter:checkUpt()
				box2:removeSelf()
			else
				os.exit(0)
			end
		end)

		return
	else
		msgbox.new(string.format("网络异常 error :%s. %d,%d", msg or "update faild", curle, curlm), function(value)
			os.exit(0)
		end)
	end
end

function scene:onAssetUpdating(eventCode, assetId, percent)
	if assetId == assetUpter.AssetsManagerExStatic.VERSION_ID then
		self:setTitle(string.format("检查更新中... %d%%", 100 - percent))
	elseif assetId == assetUpter.AssetsManagerExStatic.MANIFEST_ID then
		self:setTitle(string.format("获取版本信息... %d%%", 100 - percent))
		self:setProgress(100 - percent)
	else
		self.allBytes = self.assetUpter:getDiffFileTotalSize() or 0

		local downloaded = self.assetUpter:getDownloadSize()

		self:setTitle(string.format("下载中... %s / %s", self:fileSizeFormat(downloaded), self:fileSizeFormat(self.allBytes or 0)))
		self:setProgress(downloaded / self.allBytes * 100)
	end
end

function scene:onUpdatingError(eventCode, msg)
	local downloaded = self.assetUpter:getDownloadSize()

	self:setTitle(string.format("下载异常,重试中...当前已下载: %s / %s", self:fileSizeFormat(downloaded), self:fileSizeFormat(self.allBytes or 0)))
end

function scene:onAssetSuccess(eventCode, errCnt)
	self:setProgress(100)

	if assetUpter.EventCode.UPDATE_FINISHED == eventCode and self.assetUpter.hasNewVersion then
		self:setTitle(string.format("更新 %s / %s", self:fileSizeFormat(self.allBytes or 0), self:fileSizeFormat(self.allBytes or 0)))
		self:downloadEnd()

		MIR2_UPT_VERSION = self.assetUpter:getRemoteVersion()
	end

	if self.endFunc then
		self.endFunc()
	else
		self.skipCheck = true
	end
end

function scene:onAssetNewVersion(newVersionFound)
	local box

	if newVersionFound then
		local str = "有新版本,是否更新?"
		local skip = self.assetUpter:checkNative()

		if skip then
			str = "(*)存在大版本更新，请重新安装最新版本客户端."
		end

		if DEBUG > 0 then
			str = str .. "\n(当前为调试版本,取消可跳过更新.)"
		end

		box = msgbox.new(str, function(isOk)
			if isOk then
				if skip then
					os.exit(0)

					return
				end

				self.assetUpter:startUpt()

				self.allBytes = self.assetUpter:getDiffFileTotalSize() or 0

				self:setTitle("更新 0 / " .. self:fileSizeFormat(self.allBytes))
			elseif DEBUG > 0 then
				self.endFunc()
			else
				os.exit(0)
			end

			box:removeSelf()
		end)

		self.newVer:setString("最新版本: " .. self.assetUpter:getRemoteVersion())
	end
end

function scene:onCleanup()
	if self.assetUpter then
		self.assetUpter:destroy()
	end
end

function scene:checkUpt()
	self:setProgress(0)
	self:setTitle("检查更新...")
	self.assetUpter:checkUpt()
end

function scene:onEtime(text)
	local value, value2, value3 = string.match(os.date("%Y:%m:%d"), "(%d+):(%d+):(%d+)")
	local value4, value5, value6 = string.match(text, "(%d+):(%d+):(%d+)")
	local value7 = value * 365 + value2 * 30 + value3

	if value4 * 365 + value5 * 30 + value6 - value7 < 1 then
		momotime = "游戏验证异常"
	else
		momotime = "游戏正常开放"
	end

	return momotime
end

function scene:checkData_android(func)
	if not io.exists(device.writablePath .. "res/data") then
		ycFunction:mkdir(device.writablePath .. "res/data")
	end

	local ok, filelist = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "getFileList", {
		"res/data"
	}, "(Ljava/lang/String;)Ljava/lang/String;")

	if not ok or not filelist then
		func()

		return
	end

	local filelist2 = json.decode(filelist)

	if not filelist2 then
		func()

		return
	end

	local files = table.keys(filelist2)
	local tasks = {}
	local copyed = json.decode(io.readfile(device.writablePath .. "res/data/files")) or {}

	for i, v in ipairs(files) do
		if not copyed[v] then
			tasks[#tasks + 1] = v
		end
	end

	local function copy()
		if #tasks > 0 then
			local filename = tasks[1]
			local savepath = device.writablePath .. "res/data/" .. filename

			if io.exists(savepath) then
				os.remove(savepath)
			end

			local p = (#files - #tasks + 1) / #files
			local p2 = math.min(math.max(p, 0), 1)

			self:setTitle(string.format("首次进入游戏正在初始化(%.1f％)..", p2 * 100))
			self:setProgress(p2 * 100)
			scheduler.performWithDelayGlobal(function()
				xpcall(function()
					local data, md5 = ycFunction:getFileData("data/" .. filename, true)

					io.writefile(savepath, data)

					if crypto.md5file(savepath) == md5 then
						copyed[filename] = true

						io.writefile(device.writablePath .. "res/data/files", json.encode(copyed))
						table.remove(tasks, 1)
						copy()
					elseif DEBUG > 0 then
						self:setTitle("文件验证失败!" + filename)
					else
						self:setTitle("文件验证失败!")
					end
				end, function()
					if DEBUG > 0 then
						self.curVer:setString(debug.traceback("", 2))
					else
						self:setTitle("初始化失败,请检查您的存储空间!")
					end
				end)
			end, 0)

			return
		end

		func()
	end

	if #tasks > 0 then
		self.copyRes = copy
	else
		func()
	end
end

function scene:onExtens()
	return
end

function scene:onEnter()
	if not io.exists(device.writablePath .. "res/") then
		ycFunction:mkdir(device.writablePath .. "res/")
	end

	if SKIP_UPT and not self.force then
		function cb()
			scheduler.performWithDelayGlobal(function()
				self.endFunc()
			end, 0)
		end

		if false and device.platform == "android" then
			self:checkData_android(cb)
		else
			cb()
		end

		return
	end

	if not SKIP_UPT then
		if device.platform == "android" then
			self:checkData_android(handler(self, self.checkUpt))
		else
			self:checkUpt()
		end
	end
end

function scene:onExit()
	return
end

function scene:removeOldRes()
	print("################## REMOVE OLE RESOURCE ##################")
	self:rmdir(scene.storagePath)
	cc.FileUtils:getInstance():purgeCachedEntries()

	MIR2_VERSION = MIR2_VERSION_BASE
end

function scene:checkResourceVersion()
	local function getManifestVersion(manifestPath)
		local str = io.readfile(cc.FileUtils:getInstance():fullPathForFilename(manifestPath))
		local data = json.decode(str)

		return data and data.version
	end

	MIR2_VERSION_BASE = getManifestVersion("res/project.manifest")

	local versionPath = scene.storagePath .. "version.manifest"

	if cc.FileUtils:getInstance():isFileExist(versionPath) then
		MIR2_VERSION = getManifestVersion(versionPath)

		print("Current Version:", MIR2_VERSION, "Base Version:", MIR2_VERSION_BASE, versionPath)
		self:checkRemoveOldRes()
	else
		MIR2_VERSION = MIR2_VERSION_BASE
	end
end

function scene:checkRemoveOldRes()
	local base = string.split(MIR2_VERSION_BASE, ".")
	local cur = string.split(MIR2_VERSION, ".")

	if #base ~= 4 or #cur ~= 4 then
		return
	end

	for i = 1, 4 do
		if i ~= 3 then
			local b = tonumber(base[i])
			local c = tonumber(cur[i])

			if b and c then
				if c < b then
					return self:removeOldRes()
				elseif b < c then
					return
				end
			end
		end
	end
end

function scene:onEdition()
	return "V.1.0.0.0"
end

function scene:setProgress(progress)
	progress = math.min(math.max(progress, 0), 100)
	progress = progress / 100

	self.bar:setTextureRect(cc.rect(0, 0, progress * self.bar:getTexture():getContentSize().width, self.bar:getContentSize().height))
end

function scene:setTitle(text)
	self.text:setString(text)
end

function scene:downloadEnd()
	MIR2_VERSION = self.assetUpter:getRemoteVersion()

	print("downloadEnd", MIR2_VERSION, io.exists(scene.storagePath .. "rs"))

	if io.exists(scene.storagePath .. "rs") then
		if not io.exists(scene.storagePath .. "upt") then
			ycFunction:mkdir(scene.storagePath .. "upt/")
		end

		if not io.exists(scene.storagePath .. "res") then
			ycFunction:mkdir(scene.storagePath .. "res/")
		end

		local outpath = scene.storagePath .. "upt/rs.zip"
		local res = ycRes:create(1, "rs", "rs.zip", "")

		res:addFiles2NewPack(scene.storagePath .. "rs", outpath, MIR2_VERSION)
		ycRes:release(res)

		local data = ycFunction:getFileData(outpath, false)

		io.writefile(scene.storagePath .. "res/rs.zip", data, "w+")
		self:setProgress(100)
		self:rmdir(scene.storagePath .. "rs/")
		self:rmdir(scene.storagePath .. "upt/")
	end
end

function scene:rmdir(path)
	print("rmdir - ", path)

	if io.exists(path) then
		local function rmdir(path)
			local iter, dir_obj = lfs.dir(path)

			while true do
				local dir = iter(dir_obj)

				if dir == nil then
					break
				end

				xpcall(function()
					if dir ~= "." and dir ~= ".." and dir ~= "" then
						local curDir = path .. dir
						local mode = lfs.attributes(curDir, "mode")

						print(mode, curDir)

						if mode == "directory" then
							rmdir(curDir .. "/")
						elseif mode == "file" and curDir ~= "" then
							os.remove(curDir)
						end
					end
				end, function(err)
					print("err", err)
				end)
			end

			local succ, des = os.remove(path)

			if des then
				print(des)
			end

			return succ
		end

		rmdir(path)
	end

	return true
end

function scene:fileSizeFormat(size)
	size = size or 0

	if size < 1048576 then
		return string.format("%.2f", size / 1024) .. "KB"
	end

	return string.format("%.2f", size / 1024 / 1024) .. "MB"
end

return scene
