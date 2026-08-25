local common = import(".common")
local picListenner = {}

function picListenner.onUploadEnd(result, errMsg, url, size, msgID)
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
end

function picListenner.onDownloading(msgID, channel)
	common.uptPicMsgState(msgID, channel, "loading")
end

function picListenner.onDownloadEnd(msgID, channel, result, path, user)
	common.uptPicMsgState(msgID, channel, result and "loadOk" or "loadErr", path, user)
end

return picListenner
