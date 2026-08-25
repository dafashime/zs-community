local common = import("...common.common")
local voiceBtnJIT = class("voiceBtnJIT", function()
	return display.newNode()
end)

table.merge(voiceBtnJIT, {
	bg,
	stateChanged,
	isloading,
	loadingspr,
	issaying,
	sayingspr
})

function voiceBtnJIT:ctor()
	self:size(60, 60)

	self.bg = res.get2("pic/console/btn_voice_normal.png"):pos(self:centerPos()):add2(self)

	self:refreshIcon()

	local function setScale(b)
		self.bg:scaleTo(0.1, b and 1.3 or 1)
	end

	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			if self.isloading then
				main_scene.ui:tip("语音控件初始化中...")

				return
			end

			setScale(true)

			self.stateChanged = nil

			return true
		end

		if self.stateChanged then
			setScale(false)

			return
		end

		local touchIn = self:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

		if event.name == "moved" then
			setScale(touchIn)
		elseif event.name == "ended" then
			setScale(false)

			if touchIn then
				if not g_data.voice.roomData then
					main_scene.ui:tip("未加入任何语音频道.")
				elseif g_data.voice.roomData:get("mode") == 1 then
					if g_data.voice.playerData and g_data.voice.playerData:get("isAdmin") == 1 then
						yaya.mic(not yaya.isonMic, common.getPlayerName())
					else
						main_scene.ui:tip("你没有指挥权限..")
					end
				elseif g_data.voice.roomData:get("mode") == 0 then
					if g_data.voice.playerData and g_data.voice.playerData:get("isMute") == 0 then
						yaya.mic(not yaya.isonMic, common.getPlayerName())
					else
						main_scene.ui:tip("你被禁言了..")
					end
				end
			end
		end
	end)
end

function voiceBtnJIT:stateHasChanged()
	self.stateChanged = true

	self:refreshIcon()
	self:setSaying()
	self:loadingCheck()
end

function voiceBtnJIT:loadingCheck()
	self:setLoading(g_data.voice.roomData and not yaya.logined and yaya.freeMode)
end

function voiceBtnJIT:refreshIcon()
	if not g_data.voice.roomData then
		self.bg:setTex(res.gettex2("pic/console/btn_voice_normal.png"))

		return
	end

	local mode = g_data.voice.roomData:get("mode")

	if mode == 0 then
		if g_data.voice.playerData and g_data.voice.playerData:get("isMute") == 0 then
			self.bg:setTex(res.gettex2("pic/console/btn_voice_free.png"))
		else
			self.bg:setTex(res.gettex2("pic/console/btn_voice_free_mute.png"))
		end
	elseif g_data.voice.playerData and g_data.voice.playerData:get("isAdmin") == 1 then
		self.bg:setTex(res.gettex2("pic/console/btn_voice_command.png"))
	else
		self.bg:setTex(res.gettex2("pic/console/btn_voice_command2.png"))
	end
end

function voiceBtnJIT:setLoading(isloading)
	if device.platform == "mac" or device.platform == "windows" then
		isloading = nil
	end

	self.isloading = isloading

	if self.isloading and not self.loadingspr then
		local ani = res.getani2("pic/effect/loading/%d.png", 1, 12, 0.06)

		self.loadingspr = res.get2("pic/effect/loading/1.png"):pos(self:centerPos()):add2(self):runForever(cc.Animate:create(ani))
	elseif not self.isloading and self.loadingspr then
		self.loadingspr:removeSelf()

		self.loadingspr = nil
	end
end

function voiceBtnJIT:setSaying(issaying)
	self.issaying = issaying

	if self.issaying and not self.sayingspr then
		local ani = res.getani2("pic/effect/btnselect/%d.png", 1, 15, 0.06)

		self.sayingspr = res.get2("pic/effect/btnselect/1.png"):pos(self:centerPos()):add2(self):runForever(cc.Animate:create(ani))
	elseif not self.issaying and self.sayingspr then
		self.sayingspr:removeSelf()

		self.sayingspr = nil
	end
end

return voiceBtnJIT
