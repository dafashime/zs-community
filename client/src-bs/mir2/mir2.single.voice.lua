local voice = {
	listenner,
	downloads = {}
}

function voice.setListenner(listenner)
	voice.listenner = listenner
end

function voice.removeListenner()
	voice.listenner = nil
end

function voice.call(key, ...)
	if voice.listenner and voice.listenner[key] then
		voice.listenner[key](...)
	end
end

function voice.filename(user, msgID)
	return string.sub(crypto.md5(user .. msgID .. "mir2voice"), 1, 16)
end

function voice.isRecording()
	return voice.record ~= nil
end

function voice.canRecord()
	if voice.record then
		return false, "语音控件正在处理上一条信息, 请稍候再试！"
	end

	return true
end

function voice.startRecord(player)
	local msgID = string.sub(crypto.md5(socket.gettime()), 1, 8)
	local filename = voice.filename(player, msgID)
	voice.record = {
		player = player,
		msgID = msgID,
		wav = cache.getVoiceWav() .. filename .. ".wav",
		amr = cache.getVoiceAmr() .. filename .. ".amr"
	}

	audio.stopAllSounds()

	if voice.recordHandle then
		scheduler.unscheduleGlobal(voice.recordHandle)

		voice.recordHandle = nil
	end

	voice.recordHandle = scheduler.performWithDelayGlobal(function ()
		voice.stopRecord()
		voice.call("onRecordTimeout")
	end, 60)

	if device.platform == "mac" or device.platform == "ios" then
		luaoc.callStaticMethod("voice", "call", {
			type = "start:",
			path = voice.record.wav
		})
	elseif device.platform == "android" then
		luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "voice", "start", {
			voice.record.amr
		})
	end
end

function voice.stopRecord()
	if voice.recordHandle then
		scheduler.unscheduleGlobal(voice.recordHandle)

		voice.recordHandle = nil
	end

	local ok, ret = nil

	if device.platform == "mac" or device.platform == "ios" then
		ok, ret = luaoc.callStaticMethod("voice", "call", {
			type = "stop:"
		})
	elseif device.platform == "android" then
		ok, ret = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "voice", "stop", {}, "()F")
	end

	if not ok or not ret then
		voice.record = nil

		voice.call("onRecordEnd", false, "发生未知错误.")

		return
	end

	if ret < 1 then
		voice.record = nil

		voice.call("onRecordEnd", false, "录制时间过短!")

		return
	end

	local function finish()
		local record = voice.record
		voice.record = nil

		voice.call("onRecordEnd", true, record)
		voice.upload(record.amr, ret, record.msgID)
	end

	if device.platform == "mac" or device.platform == "ios" then
		luaoc.callStaticMethod("voice", "call", {
			type = "convert2amr:",
			inPath = voice.record.wav,
			outPath = voice.record.amr,
			callback = function (ok)
				if ok then
					finish()
				else
					voice.record = nil

					voice.call("onRecordEnd", false, "语音录制失败!")
				end
			end
		})
	elseif device.platform == "android" then
		finish()
	end
end

function voice.cancelRecord()
	if voice.recordHandle then
		scheduler.unscheduleGlobal(voice.recordHandle)

		voice.recordHandle = nil
	end

	if device.platform == "mac" or device.platform == "ios" then
		luaoc.callStaticMethod("voice", "call", {
			type = "cancel:"
		})
	elseif device.platform == "android" then
		luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "voice", "cancel")
	end

	voice.record = nil
end

function voice.upload(path, dur, msgID)
	yaya.uploadVoice(path, dur, msgID)
end

function voice.uploadEnd(result, errMsg, url, text, dur, expand)
	voice.call("onUploadEnd", result, errMsg, text, url, dur, expand)
end

function voice.isPlaying()
	return voice.playing and not voice.playing.loading
end

function voice.play(user, msgID, channel, url, dur)
	if voice.isPlaying() then
		local isLastMsg = voice.playing.msgID == msgID

		voice.stopPlay(voice.playing.msgID, voice.playing.channel)

		if isLastMsg then
			voice.call("onPlayEndSound")

			return
		end
	end

	voice.playing = {
		msgID = msgID,
		channel = channel,
		dur = dur
	}
	local filename = voice.filename(user, msgID)

	if device.platform == "mac" or device.platform == "ios" then
		path = cache.getVoiceWav() .. filename .. ".wav"
	elseif device.platform == "android" then
		path = cache.getVoiceAmr() .. filename .. ".amr"
	end

	if io.exists(path) then
		voice.startPlay(msgID, channel, dur, path)
	else
		voice.playing.loading = true

		voice.download(msgID, channel, filename, url)
	end

	voice.call("onPlayStartSound")
end

function voice.autoPlay(user, msgID, channel, url, dur)
	if voice.playing then
		return
	end

	voice.play(user, msgID, channel, url, dur)
end

function voice.startPlay(msgID, channel, dur, path)
	if voice.playHandle then
		scheduler.unscheduleGlobal(voice.playHandle)

		voice.playHandle = nil
	end

	voice.playHandle = scheduler.performWithDelayGlobal(function ()
		voice.stopPlay(msgID, channel)
		voice.call("onPlayEndSound")
	end, dur + 0.5)

	audio.stopAllSounds()
	audio.playSound(path)
	voice.call("onStartPlay", msgID, channel)
end

function voice.stopPlay(msgID, channel)
	if voice.playHandle then
		scheduler.unscheduleGlobal(voice.playHandle)

		voice.playHandle = nil
	end

	audio.stopAllSounds()

	voice.playing = nil

	voice.call("onStopPlay", msgID, channel)
end

function voice.download(msgID, channel, filename, url)
	if voice.downloads[msgID] then
		return
	end

	voice.downloads[msgID] = true

	voice.call("onDownloading", msgID, channel)

	local path = cache.getVoiceAmr() .. filename .. ".amr"

	if not io.exists(path) then
		local request = network.createHTTPRequest(function (event)
			if event.name ~= "completed" then
				return
			end

			local request = event.request
			local code = request:getResponseStatusCode()

			if code ~= 200 then
				voice.downloadEnd(false, msgID, channel)

				return
			end

			io.writefile(path, request:getResponseData())
			voice.downloadEnd(true, msgID, channel, filename, path)
		end, url)

		request:start()
	else
		voice.downloadEnd(true, msgID, channel, filename, path)
	end
end

function voice.downloadEnd(result, msgID, channel, filename, amrPath)
	if result then
		local function finish(ok, path)
			voice.downloads[msgID] = nil

			voice.call("onDownloadEnd", msgID, channel, ok)

			if ok and voice.playing and voice.playing.msgID == msgID then
				voice.playing.loading = nil

				voice.startPlay(msgID, voice.playing.channel, voice.playing.dur, path)
			end
		end

		if device.platform == "mac" or device.platform == "ios" then
			local wavPath = cache.getVoiceWav() .. filename .. ".wav"

			luaoc.callStaticMethod("voice", "call", {
				type = "convert2wav:",
				inPath = amrPath,
				outPath = wavPath,
				callback = function (ok)
					finish(ok, wavPath)
				end
			})
		elseif device.platform == "android" then
			finish(true, amrPath)
		end

		return
	end

	voice.downloads[msgID] = nil

	voice.call("onDownloadEnd", msgID, channel, false)
end

return voice
