local assetUpter = class("uptScene")

table.merge(assetUpter, {
	assetMgr,
	eventAssetManagerlistener,
	listener,
	hasNewVersion
})

assetUpter.maxRetryTimes = 30

function assetUpter:ctor(versionManifest, storagePath)
	self._versionManifest = versionManifest
	self._storagePath = storagePath

	self:reset()
end

function assetUpter:destroy()
	if self.assetMgr then
		self.assetMgr:release()
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.eventAssetManagerlistener)

		self.assetMgr = nil
	end
end

function assetUpter:reset()
	self:destroy()

	self.errAssetCnt = 0

	local assetMgr = cc.AssetsManagerEx:create(self._versionManifest, self._storagePath)

	assetMgr:retain()

	self.assetMgr = assetMgr
	self.eventAssetManagerlistener = cc.EventListenerAssetsManagerEx:create(self.assetMgr, handler(self, self.onUpdateEvent))

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.eventAssetManagerlistener, 1)

	self.downloading = false
	self.downloadingFilesSize = {}
	self.downloadFileCnt = 0
end

function assetUpter:checkUpt()
	self.assetMgr:checkUpdate()
end

function assetUpter:startUpt()
	self.downloading = true

	self.assetMgr:update()
end

function assetUpter:retryUptFaildAssets()
	self.assetMgr:downloadFailedAssets()
end

function assetUpter:getCurVersion()
	return self.assetMgr:getLocalManifest():getVersion()
end

function assetUpter:getRemoteVersion()
	local manifest = self.assetMgr:getRemoteManifest()

	if manifest then
		return manifest:getVersion()
	else
		return ""
	end
end

function assetUpter:checkNative()
	local cur = string.split(self:getCurVersion(), ".")
	local newVersion = self:getRemoteVersion()

	if newVersion == "" then
		return false
	else
		local new = string.split(newVersion, ".")

		if cur[2] ~= new[2] then
			return true
		end
	end
end

function assetUpter:getDownloadingFilenames()
	return self.assetMgr:getDownloadingFilenames()
end

function assetUpter:getDiffFileTotalSize()
	local manifest = self.assetMgr:getRemoteManifest()
	local downloading = self.assetMgr:getDownloadingFilenames()

	for k, v in ipairs(downloading) do
		if not self.downloadingFilesSize[v] then
			local sz = manifest:getAssetSize(v)

			self.downloadingFilesSize[v] = sz
		end

		self.downloadFileCnt = self.downloadFileCnt + 1
	end

	local totalSize = 0

	for k2, v2 in pairs(self.downloadingFilesSize) do
		totalSize = totalSize + v2
	end

	return totalSize
end

function assetUpter:getDownloadSize()
	return self.assetMgr:getDownloadSize()
end

assetUpter.EventCode = {
	ERROR_DECOMPRESS = 10,
	ERROR_NO_LOCAL_MANIFEST = 0,
	ERROR_UPDATING = 7,
	ERROR_PARSE_MANIFEST = 2,
	UPDATE_FINISHED = 8,
	NEW_VERSION_FOUND = 3,
	ERROR_DOWNLOAD_MANIFEST = 1,
	UPDATE_FAILED = 9,
	ALREADY_UP_TO_DATE = 4,
	ASSET_UPDATED = 6,
	UPDATE_PROGRESSION = 5
}
assetUpter.AssetsManagerExStatic = {
	VERSION_ID = "@version",
	MANIFEST_ID = "@manifest"
}

function assetUpter:onUpdateEvent(event)
	local eventCode = event

	if type(event) == "table" or type(event) == "userdata" then
		eventCode = event:getEventCode()
	else
		print(event)
	end

	local ok = false

	for k, v in pairs(assetUpter.EventCode) do
		if v == eventCode then
			print(k)

			break
		end
	end

	if eventCode == assetUpter.EventCode.ERROR_NO_LOCAL_MANIFEST then
		print("No local manifest file found. state: faild")
		self.listener:onAssetError(eventCode, event:getMessage())
	elseif eventCode == assetUpter.EventCode.ERROR_DOWNLOAD_MANIFEST or eventCode == assetUpter.EventCode.ERROR_PARSE_MANIFEST then
		print("Fail to download manifest file. state: faild, errorCode:" .. eventCode)
		self.listener:onAssetError(eventCode, event:getMessage(), event:getCURLECode(), event:getCURLMCode())
	elseif eventCode == assetUpter.EventCode.ERROR_DECOMPRESS then
		self.listener:onAssetError(eventCode, event:getMessage())
	elseif eventCode == assetUpter.EventCode.UPDATE_PROGRESSION or eventCode == assetUpter.EventCode.ASSET_UPDATED then
		local assetId = event:getAssetId()
		local percent = event:getPercent()
		local percentByFile = event:getPercentByFile()

		if assetId == assetUpter.AssetsManagerExStatic.VERSION_ID then
			print("Version file: %d%%", percent)
		elseif assetId == assetUpter.AssetsManagerExStatic.MANIFEST_ID then
			print(string.format("Manifest file: %d%%", percent))
		else
			print(string.format("%s: %d%%", assetId, percent))
		end

		self.listener:onAssetUpdating(eventCode, assetId, percent)
	elseif eventCode == assetUpter.EventCode.ALREADY_UP_TO_DATE or eventCode == assetUpter.EventCode.UPDATE_FINISHED then
		print("Update finished.", event:getAssetId(), eventCode)
		self.listener:onAssetSuccess(eventCode, self.errAssetCnt)
	elseif eventCode == assetUpter.EventCode.ERROR_UPDATING or eventCode == assetUpter.EventCode.UPDATE_FAILED then
		print("Asset ", event:getAssetId(), ", ", event:getMessage(), event:getCURLECode(), event:getCURLMCode())

		self.errAssetCnt = self.errAssetCnt + 1

		local retryTimes = self.downloadFileCnt

		if retryTimes <= 0 then
			retryTimes = assetUpter.maxRetryTimes
		end

		if retryTimes > self.errAssetCnt then
			self:retryUptFaildAssets()
			self.listener:onUpdatingError(eventCode, event:getMessage())
		else
			self.listener:onAssetError(eventCode, event:getMessage())
		end
	elseif eventCode == assetUpter.EventCode.NEW_VERSION_FOUND then
		if not self.downloading then
			self.listener:onAssetNewVersion(true)
		end

		self.hasNewVersion = true
	else
		print("unknow event:", eventCode)
	end
end

if DEBUG > 0 then
	assetUpter.salt = "yMnNhbHRkJTNha2Zq"

	function assetUpter:setCachePath(storagePath, key)
		ycFunction:mkdir(storagePath)

		self.cachePath = storagePath .. crypto.encodeBase64("uptAssetUpter" .. key)
	end

	function assetUpter:saveRemoteAddress(addr)
		local cache = crypto.encodeBase64(addr)
		local cache2 = crypto.encodeBase64(assetUpter.salt .. cache)
		local cache3 = crypto.encodeBase64(cache2)

		io.writefile(self.cachePath, cache3)
	end

	function assetUpter:getFileServerAddr()
		local data = io.readfile(self.cachePath)

		if data then
			local cache = crypto.decodeBase64(data)
			local cache2 = crypto.decodeBase64(cache)
			local addr = string.sub(cache2, string.len(assetUpter.salt) + 1)

			return (crypto.decodeBase64(addr))
		end
	end

	function assetUpter:updateRemoteUrl()
		local addr = self:getFileServerAddr()

		if addr then
			self:setRemoteAddress(addr)
		end
	end

	function assetUpter:setRemoteAddress(addr)
		print("setRemoteAddress", addr)
		self.assetMgr:getLocalManifest():setRemoteAddress(addr)
	end
end

function assetUpter:setListener(l)
	self.listener = l
end

return assetUpter
