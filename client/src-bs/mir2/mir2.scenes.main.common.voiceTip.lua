local tip = class("voiceTip", function ()
	return display.newNode()
end)

table.merge(tip, {
	press,
	release,
	volume
})

function tip:ctor()
	local bg = res.get2("pic/voice/bg.png"):center():add2(self)
	self.press = res.get2("pic/voice/press.png"):pos(display.cx - 1, display.cy - 4):add2(self):hide()
	self.release = res.get2("pic/voice/release.png"):pos(display.cx, display.cy):add2(self):hide()
	self.volume = res.get2("pic/voice/volume.png"):anchor(0.5, 0):pos(display.cx + 30, display.cy - 30):add2(self):hide()
	local timecnt = 0

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
		if voice.isRecording() then
			timecnt = timecnt + dt

			if timecnt > 0.2 then
				timecnt = timecnt - 0.2
				local ok, ret = nil

				if device.platform == "mac" or device.platform == "ios" then
					ok, ret = luaoc.callStaticMethod("voice", "call", {
						type = "getVolume:"
					})
				elseif device.platform == "android" then
					ok, ret = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "voice", "getVolume", {}, "()F")
				end

				if ok and ret then
					local value = math.max(1, math.min(10, math.round(ret * 10)))
					local size = self.volume:getTexture():getContentSize()
					local h = size.height / 10 * value

					self.volume:setTextureRect(cc.rect(0, size.height - h, size.width, h))
				end
			end
		end
	end)
	self:scheduleUpdate()
	self:hide()
end

function tip:upt(state)
	if state == "start" or state == "press" then
		self:show()
		self.press:show()
		self.volume:show()
		self.release:hide()
	elseif state == "release" then
		self:show()
		self.press:hide()
		self.volume:hide()
		self.release:show()
	elseif state == "ok" then
		self:hide()
	elseif state == "cancel" then
		self:hide()
	end
end

return tip
