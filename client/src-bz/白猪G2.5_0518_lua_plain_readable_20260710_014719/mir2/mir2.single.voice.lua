local function callback2(text)
	if text then
		text = string.gsub(text, "\n", "\r\n")
		text = string.gsub(text, "([^%w %-%_%.%~])", function(value)
			return string.format("%%%02X", string.byte(value))
		end)
		text = string.gsub(text, " ", "+")
	end

	return text
end

local voice = {
	listenner,
	apiUrl = "https://www.bzmir2.com/voice/api.php",
	downloads = {},
	cache = {}
}

function voice.setListenner(listenner2)
	voice.listenner = listenner2
end

function voice.removeListenner()
	voice.listenner = nil
end

function voice.call(key, ...)
	if voice.listenner and voice.listenner[key] then
		voice.listenner[key](...)
	end
end

function voice.filename(user, msgID2)
	return string.sub(crypto.md5(user .. msgID2 .. "mir2voice"), 1, 16)
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

function voice.startRecord(player2)
	local msgID2 = string.sub(crypto.md5(socket.gettime()), 1, 8)
	local filename = voice.filename(player2, msgID2)

	voice.record = {
		player = player2,
		msgID = msgID2,
		wav = cache.getVoiceWav() .. filename .. ".wav",
		amr = cache.getVoiceAmr() .. filename .. ".amr"
	}

	if g_data.chat.style.channel == "千里传音" then
		main_scene.ui:fadeLabel("暂时无法在该频道发送语音")

		return
	end

	local number = g_data.player.cmAbil.OpenVoice

	if def.closeVoice and not number then
		main_scene.ui:fadeLabel("你暂时无法发送语音")

		return
	end

	if number and tonumber(number) == -1 then
		main_scene.ui:fadeLabel("暂时无法发送语音，请联系游戏管理员")

		return
	else
		if g_data.chat.style.channel == "附近" and (not number or tonumber(number) < 2) then
			main_scene.ui:fadeLabel("暂时无法在该频道发送语音")

			return
		end

		if g_data.chat.style.channel == "喊话" and (not number or tonumber(number) < 3) then
			main_scene.ui:fadeLabel("暂时无法在该频道发送语音")

			return
		end
	end

	audio.stopAllSounds()

	if voice.recordHandle then
		scheduler.unscheduleGlobal(voice.recordHandle)

		voice.recordHandle = nil
	end

	voice.recordHandle = scheduler.performWithDelayGlobal(function()
		voice.stopRecord()
		voice.call("onRecordTimeout")
	end, VOICE_SEND_TIME or 60)

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

	local ok
	local ret

	if device.platform == "mac" or device.platform == "ios" then
		ok, ret = luaoc.callStaticMethod("voice", "call", {
			type = "stop:"
		})
	elseif device.platform == "android" then
		ok, ret = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "voice", "stop", {}, "()F")
	end

	if not ok or not ret then
		voice.record = nil

		voice.call("onRecordEnd", false, "请退出游戏，通过手机设置开启游戏麦克风权限.")

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

		local file = io.open(record.amr, "rb")

		if not file then
			voice.call("onRecordEnd", false, "文件读取失败!")

			return
		end

		local value = file:read("*a")

		file:close()

		local value2 = crypto.encodeBase64(value)

		voice.uploadCompleteFile(record, value2, ret)
		voice.call("onRecordEnd", true, record)
	end

	if device.platform == "mac" or device.platform == "ios" then
		luaoc.callStaticMethod("voice", "call", {
			type = "convert2amr:",
			inPath = voice.record.wav,
			outPath = voice.record.amr,
			callback = function(ok2)
				if ok2 then
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

function voice:uploadCompleteFile(items, value)
	local value3 = voice.apiUrl

	if TEST then
		print("上传调试信息")
		print("请求URL：" .. value3)
		print("fileId：" .. voice.filename(self.player, self.msgID))
		print("数据大小：" .. #items .. "字节（Base64）")
		print("原始文件大小：" .. #crypto.decodeBase64(items) .. "字节")
	end

	local text = string.format("action=uploadComplete&fileId=%s&filename=%s&duration=%d&player=%s&fileData=%s&key=%s&cid=%s", callback2(voice.filename(self.player, self.msgID)), callback2(self.msgID .. ".amr"), value, callback2(self.player), callback2(items), callback2(def.role.stuff), callback2(CID or ""))
	local hTTPRequest = network.createHTTPRequest(function(value2)
		if value2.name == "failed" then
			local text4 = value2.error or "未知错误"

			if string.find(text4, "timeout") then
				voice.call("onUploadEnd", false, "请求超时（服务器无响应）", nil, self.msgID, value, nil)
			elseif string.find(text4, "connection") then
				voice.call("onUploadEnd", false, "连接失败（服务器不可达）", nil, self.msgID, value, nil)
			else
				voice.call("onUploadEnd", false, "网络错误：" .. text4, nil, self.msgID, value, nil)
			end

			return
		end

		if value2.name ~= "completed" then
			if TEST then
				print("请求未完成：" .. value2.name)
			end

			return
		end

		local value4 = value2.request
		local code = value4:getResponseStatusCode()

		if TEST then
			print("服务端响应码：" .. code)
		end

		local jsonText = value4:getResponseData()

		if TEST then
			print("服务端响应内容：" .. jsonText)
		end

		if code ~= 200 then
			voice.call("onUploadEnd", false, "网络错误：" .. code, nil, self.msgID, value, nil)

			return
		end

		local data = json.decode(jsonText) or {}

		if data.code == 0 then
			if not data.data or not data.data.fileId then
				local text5 = ""
			end

			local text3 = string.format("%02d", value)
			local value5 = self.msgID .. text3
			local text2 = string.format("{@vi%s}", value5)

			if TEST then
				print("voiceMsg：", text2)
			end

			require("mir2.scenes.main.common.common").say(text2)

			voice.cache[self.msgID] = {}
			voice.cache[self.msgID].getTime = socket.gettime()

			main_scene.ui:fadeLabel(data.msg or "发送成功")
		else
			main_scene.ui:fadeLabel(string.format("%s(%s)", data.msg, data.code) or "发送失败")
		end
	end, value3, "POST")

	hTTPRequest:setTimeout(60)
	hTTPRequest:addRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	hTTPRequest:addRequestHeader("Content-Length", #text)
	hTTPRequest:setPOSTData(text)
	hTTPRequest:start()
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

function voice.upload(path2, dur2, msgID2)
	return
end

function voice.uploadEnd(result, errMsg, url, text, dur2, expand)
	voice.call("onUploadEnd", result, errMsg, url, text, dur2, expand)
end

function voice.isPlaying()
	return voice.playing and not voice.playing.loading
end

function voice.play(user, msgID2, channel2, url, dur2)
	if voice.isPlaying() then
		local isLastMsg = voice.playing.msgID == msgID2

		voice.stopPlay(voice.playing.msgID, voice.playing.channel)

		if isLastMsg then
			voice.call("onPlayEndSound")

			return
		end
	end

	voice.playing = {
		msgID = msgID2,
		channel = channel2,
		dur = dur2
	}

	local filename = voice.filename(user, msgID2)
	local path2

	if device.platform == "mac" or device.platform == "ios" then
		path2 = cache.getVoiceWav() .. filename .. ".wav"
	else
		path2 = cache.getVoiceAmr() .. filename .. ".amr"
	end

	if io.exists(path2) then
		if voice.cache[msgID2] then
			local value = VOICE_VAILED_TIME or 30

			if voice.cache[msgID2].getTime and value < socket.gettime() - voice.cache[msgID2].getTime then
				main_scene.ui:fadeLabel("信息已过时(-10)")

				return
			end
		end

		voice.startPlay(msgID2, channel2, dur2, path2)
	else
		voice.playing.loading = true

		local url2 = url

		voice.download(msgID2, channel2, filename, url2)
	end

	voice.call("onPlayStartSound")
end

function voice.autoPlay(user, msgID2, channel2, url, dur2)
	if voice.playing then
		return
	end

	voice.play(user, msgID2, channel2, url, dur2)
end

function voice.startPlay(msgID2, channel2, dur2, path2)
	if voice.playHandle then
		scheduler.unscheduleGlobal(voice.playHandle)

		voice.playHandle = nil
	end

	voice.playHandle = scheduler.performWithDelayGlobal(function()
		voice.stopPlay(msgID2, channel2)
		voice.call("onPlayEndSound")
	end, dur2 + 0.5)

	audio.stopAllSounds()
	audio.playSound(path2)
	voice.call("onStartPlay", msgID2, channel2)
end

function voice.stopPlay(msgID2, channel2)
	if voice.playHandle then
		scheduler.unscheduleGlobal(voice.playHandle)

		voice.playHandle = nil
	end

	audio.stopAllSounds()

	voice.playing = nil

	voice.call("onStopPlay", msgID2, channel2)
end

function voice.download(msgID2, channel2, filename, url)
	if voice.downloads[msgID2] then
		return
	end

	if TEST then
		dump(voice.cache[msgID2])
	end

	if voice.cache[msgID2] then
		if voice.cache[msgID2].code then
			main_scene.ui:fadeLabel(string.format("%s(%s)", voice.cache[msgID2].msg, voice.cache[msgID2].code) or "读取失败")

			return
		end

		local value = VOICE_VAILED_TIME or 30

		if voice.cache[msgID2].getTime and value < socket.gettime() - voice.cache[msgID2].getTime then
			main_scene.ui:fadeLabel("信息已过时(-10)")

			return
		end
	end

	voice.downloads[msgID2] = true

	voice.call("onDownloading", msgID2, channel2)

	local path2 = cache.getVoiceAmr() .. filename .. ".amr"

	if not io.exists(path2) then
		local text = string.format("action=download&fileId=%s&key=%s", callback2(filename), callback2(def.role.stuff))

		if TEST then
			print("下载文件信息：", text, filename, msgID2, url)
		end

		local request = network.createHTTPRequest(function(event)
			if event.name == "failed" then
				local value2 = ({
					[-4] = "SSL证书错误",
					[-1] = "URL无效/解析失败",
					[-3] = "请求超时",
					[-5] = "网络不可用",
					[-2] = "连接失败（服务器不可达/端口关闭）"
				})[event.errorCode] or "未知错误"

				if TEST then
					print(string.format("下载失败：%s（码：%d，信息：%s）", value2, event.errorCode or -999, event.error or "无"))
				end

				voice.downloadEnd(false, msgID2, channel2)

				return
			end

			if event.name ~= "completed" then
				return
			end

			local request2 = event.request
			local code = request2:getResponseStatusCode()

			if TEST then
				print("服务端响应码：" .. code)
			end

			local jsonText = request2:getResponseData()

			if not jsonText or #jsonText < 10 then
				if TEST then
					print("下载失败：无有效数据返回")
				end

				voice.downloadEnd(false, msgID2, channel2)

				return
			end

			local text2 = string.sub(jsonText, 1, 5)

			if text2 ~= "#!AMR" then
				local data = json.decode(jsonText)

				if data and data.code and data.code < 0 then
					main_scene.ui:fadeLabel(string.format("%s(%s)", data.msg, data.code) or "读取失败")

					voice.cache[msgID2] = {}
					voice.cache[msgID2].code = data.code
					voice.cache[msgID2].msg = data.msg
				end

				if TEST then
					dump(jsonText)
					print(string.format("下载失败：非AMR文件（头：%s，数据长度：%d）", text2, #jsonText))
				end

				voice.downloadEnd(false, msgID2, channel2)

				return
			end

			local voiceAmr = cache.getVoiceAmr()

			if not io.exists(voiceAmr) then
				lfs.mkdir(voiceAmr)
			end

			io.writefile(path2, jsonText)

			if TEST then
				print("下载成功：保存至 " .. path2 .. "（大小：" .. #jsonText .. "字节）")
			end

			voice.playing = {
				msgID = msgID2,
				channel = channel2,
				dur = url
			}
			voice.cache[msgID2] = {}
			voice.cache[msgID2].getTime = socket.gettime()

			voice.downloadEnd(true, msgID2, channel2, filename, path2)
		end, voice.apiUrl, "POST")

		request:addRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
		request:addRequestHeader("Accept", "*/*")
		request:addRequestHeader("Accept-Encoding", "identity")
		request:addRequestHeader("Connection", "close")
		request:addRequestHeader("Content-Length", #text)
		request:setPOSTData(text)
		request:setTimeout(60)
		request:start()
	else
		voice.downloadEnd(true, msgID2, channel2, filename, path2)
	end
end

function voice.downloadEnd(result, msgID2, channel2, filename, amrPath)
	if result then
		local function finish(ok, path2)
			voice.downloads[msgID2] = nil

			voice.call("onDownloadEnd", msgID2, channel2, ok)

			if ok and voice.playing and voice.playing.msgID == msgID2 then
				voice.playing.loading = nil

				voice.startPlay(msgID2, voice.playing.channel, voice.playing.dur, path2)
			end
		end

		if device.platform == "mac" or device.platform == "ios" then
			local wavPath = cache.getVoiceWav() .. filename .. ".wav"

			luaoc.callStaticMethod("voice", "call", {
				type = "convert2wav:",
				inPath = amrPath,
				outPath = wavPath,
				callback = function(ok2)
					finish(ok2, wavPath)
				end
			})
		elseif device.platform == "android" then
			finish(true, amrPath)
		end

		return
	end

	voice.downloads[msgID2] = nil

	voice.call("onDownloadEnd", msgID2, channel2, false)
end

return voice
