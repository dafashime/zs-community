local video = class("videoPlayer")

function video:setRunner(runner)
	video.runner = runner
end

function video:setEvtCallback(func)
	self.evtCallback = func
end

local VideoPlayerEvent = {
	PLAYING = 0,
	STOPPED = 2,
	PAUSED = 1,
	COMPLETED = 3
}

function video:play(fileName, params)
	params = params or {}

	local affix

	if device.platform == "windows" then
		fileName = fileName .. ".avi"
	else
		fileName = fileName .. ".mp4"
	end

	local fileutils = cc.FileUtils:getInstance()

	if device.platform ~= "android" then
		fileName = fileutils:fullPathForFilename(fileName)
	end

	print("playVideo:", fileName)

	if not fileutils:isFileExist(fileName) then
		print("Err file not exist", fileName)

		return
	end

	local video
	local evtCallback = self.evtCallback

	local function videoEventListener(sender, tag)
		if tag == VideoPlayerEvent.PAUSED then
			video:performWithDelay(function()
				video:resume()
				video:play()
			end, 0)
		elseif tag == VideoPlayerEvent.COMPLETED or device.platform == "mac" or device.platform == "windows" then
			if evtCallback then
				evtCallback("VideoComplete")
			end

			video:stop()
			video:run(cca.removeSelf())
		end
	end

	local scene = cc.Director:getInstance():getRunningScene().s

	scheduler.performWithDelayGlobal(function()
		if device.platform == "mac" or device.platform == "windows" then
			video = display.newNode():add2(scene):center()

			video:performWithDelay(handler(video, videoEventListener), 5)
			an.newLabel(string.format("假装这里在播视频。。。\n%s\n(MAC模拟器下暂无播放视频接口)", fileName)):add2(video):anchor(0.5, 0.5)
		else
			video = ccexp.VideoPlayer:create():add2(scene)

			video:addEventListener(videoEventListener)
			video:size(display.width, display.height):center()
			video:setFullScreenEnabled(true)

			if params.keepAspectRatio then
				video:setKeepAspectRatioEnabled(true)
			end

			video:setFileName(fileName)
			video:play()
		end
	end, 0)
end

function video:test()
	return
end

return video
