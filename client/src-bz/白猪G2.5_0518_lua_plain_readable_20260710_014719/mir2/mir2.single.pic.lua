local pic = {
	listenner,
	downloads = {}
}

function pic.setListenner(listenner)
	pic.listenner = listenner
end

function pic.removeListenner()
	pic.listenner = nil
end

function pic.call(key, ...)
	if pic.listenner and pic.listenner[key] then
		pic.listenner[key](...)
	end
end

function pic.filename(user, msgID)
	return string.sub(crypto.md5(user .. msgID .. "mir2pic"), 1, 16)
end

function pic.canScreenshot()
	if pic.uploadMsg then
		return false, "您的上一张截屏正在发送中, 请稍候!"
	end

	return true
end

function pic.upload(node, player)
	local msgID = string.sub(crypto.md5(socket.gettime()), 1, 8)
	local filename = pic.filename(player, msgID)
	local diskpath = cache.getPicPathFull() .. filename .. ".jpg"

	printscreen(node, {
		file = diskpath
	})
	scheduler.performWithDelayGlobal(function()
		if device.platform == "ios" then
			luaoc.callStaticMethod("iosFuncs", "compressJPG", {
				input = diskpath,
				output = diskpath
			})
		end

		local size = math.modf(io.filesize(diskpath) / 1000)

		size = math.min(size, 999)

		yaya.uploadPic(diskpath, size, msgID)

		pic.uploadMsg = {
			size = size,
			msgID = msgID
		}
	end, 1)
end

function pic.uploadEnd(result, errmsg, url)
	if not pic.uploadMsg then
		return
	end

	pic.call("onUploadEnd", result, errmsg, url, pic.uploadMsg.size, pic.uploadMsg.msgID)

	pic.uploadMsg = nil
end

function pic.download(user, msgID, url, channel)
	if pic.downloads[msgID] then
		return
	end

	pic.downloads[msgID] = true

	pic.call("onDownloading", msgID, channel)

	local filename = pic.filename(user, msgID)
	local path = cache.getPicPathFull() .. filename .. ".jpg"

	if not io.exists(path) then
		local request = network.createHTTPRequest(function(event)
			if event.name ~= "completed" then
				return
			end

			local request = event.request
			local code = request:getResponseStatusCode()

			if code ~= 200 then
				pic.downloadEnd(false, msgID, channel)

				return
			end

			io.writefile(path, request:getResponseData())
			pic.downloadEnd(true, msgID, channel, path, user)
		end, url)

		request:start()
	else
		pic.downloadEnd(true, msgID, channel, path, user)
	end
end

function pic.downloadEnd(result, msgID, channel, path, user)
	pic.downloads[msgID] = nil

	pic.call("onDownloadEnd", msgID, channel, result, path, user)
end

return pic
