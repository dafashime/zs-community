local common = import(".common")
local picListenner = {
	onUploadEnd = function (result, errMsg, url, size, msgID)
		if result ~= 0 then
			main_scene.ui:tip(errMsg)

			return
		end

		common.say({
			{
				common.encodeRich({
					type = "pic",
					url = url or "",
					size = size or 0,
					msgID = msgID or ""
				})
			}
		})
	end,
	onDownloading = function (msgID, channel)
		common.uptPicMsgState(msgID, channel, "loading")
	end,
	onDownloadEnd = function (msgID, channel, result, path, user)
		common.uptPicMsgState(msgID, channel, result and "loadOk" or "loadErr", path, user)
	end
}

return picListenner
