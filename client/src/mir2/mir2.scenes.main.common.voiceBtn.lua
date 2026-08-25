local common = import(".common")
local voiceTip = import(".voiceTip")
local btn = class("voiceBtn", function ()
	return display.newNode()
end)

table.merge(btn, {
	tex1,
	tex2,
	recording
})

function btn:ctor(tex1, tex2, size, otherTouchRect)
	tex1:retain()
	tex2:retain()
	self:setNodeEventEnabled(true)

	function self.onCleanup()
		tex1:release()
		tex2:release()
	end

	self.tex1 = tex1
	self.tex2 = tex2
	size = size or self.tex1:getContentSize()

	self:size(size)

	self.bg = display.newSprite(tex1):anchor(0, 0):add2(self)

	self.bg:scalex(size.width / self.bg:getw())
	self.bg:scaley(size.height / self.bg:geth())

	local touchobject = self
	otherTouchRect = otherTouchRect or {
		x = 0,
		y = 0,
		width = size.width + 60,
		height = size.height * 2 + 30
	}

	if otherTouchRect then
		touchobject = display.newNode():pos(otherTouchRect.x - 30, otherTouchRect.y - size.height + 30):size(otherTouchRect.width, otherTouchRect.height):add2(self)
	end

	touchobject:setTouchEnabled(true)
	touchobject:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if g_data.chat.style.channel == "私聊" and g_data.chat.style.target == "" then
				an.newMsgbox("未设置对方名字.", nil, {
					center = true
				})

				return
			end

			local ok, msg = voice.canRecord()

			if not ok then
				main_scene.ui:tip(msg)

				return
			end

			self:setState("start")

			self.recording = true

			return true
		end

		if not self.recording then
			return
		end

		local rect = self:getCascadeBoundingBox()
		local isInArea = rect.x <= event.x and event.x <= rect.x + rect.width and rect.y <= event.y and event.y <= rect.y + rect.height

		if event.name == "moved" then
			if isInArea then
				self:setState("press")
			else
				self:setState("release")
			end
		elseif event.name == "ended" then
			if isInArea then
				self:setState("ok")
			else
				self:setState("cancel")
			end
		end
	end)
end

function btn:setState(state)
	if not main_scene.ui.voiceTip then
		main_scene.ui.voiceTip = voiceTip.new():add2(main_scene.ui, main_scene.ui.z.voiceTip)
	end

	main_scene.ui.voiceTip:upt(state)

	if state == "start" then
		self.bg:setTex(self.tex2)
		voice.startRecord(common.getPlayerName())
	elseif state == "ok" then
		self.bg:setTex(self.tex1)

		self.recording = nil

		voice.stopRecord()
	elseif state == "cancel" then
		self.bg:setTex(self.tex1)

		self.recording = nil

		voice.cancelRecord()
		main_scene.ui:tip("已取消发送！")
	end
end

return btn
