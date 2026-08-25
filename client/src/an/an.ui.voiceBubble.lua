local unreadUseW = 20
local voiceBubble = class("an.voiceBubble", function ()
	return display.newNode()
end)

table.merge(voiceBubble, {
	config,
	msgID,
	horn,
	loading,
	err,
	unread
})

function voiceBubble.init(config)
	voiceBubble.config = config or {}

	for k, v in pairs(config) do
		if type(v) == "userdata" and (tolua.type(v) == "cc.Texture2D" or tolua.type(v) == "cc.Animation") then
			v:retain()
		end
	end

	if config.bg then
		for k, v in pairs(config.bg) do
			if type(v) == "userdata" and (tolua.type(v) == "cc.Texture2D" or tolua.type(v) == "cc.Animation") then
				v:retain()
			end
		end
	end
end

function voiceBubble:ctor(h, bgkey, dur, msgID, state, readed)
	assert(self.config, "voiceBubble not inited.")

	local w = 100 + math.min(1, dur / 60) * 80
	local size = cc.size(w, h)
	self.msgID = msgID

	self:size(w + unreadUseW, h)

	local tex = self.config.bg[bgkey] or self.config.bg.default
	local texSize = tex:getContentSize()
	local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, texSize.width, texSize.height))

	display.newScale9Sprite(frame):anchor(0, 0):size(size):add2(self)
	an.newLabel(" " .. dur .. "''", 16, 1, {
		color = cc.c3b(0, 255, 255)
	}):anchor(1, 0.5):pos(self:getw() - unreadUseW - 5, self:geth() / 2):add2(self)

	self.horn = display.newSprite(self.config.hornAni:getFrames()[1]:getSpriteFrame()):scale((self:geth() - 6) / self.config.hornAni:getFrames()[1]:getSpriteFrame():getRect().height):pos(25, self:geth() / 2):add2(self)

	self:setState(state)

	if not readed then
		self:showUnread()
	end
end

function voiceBubble:setState(state)
	if state == "start" then
		self:playHorn()
	elseif state == "stop" then
		self:stopHorn()
	elseif state == "loading" then
		self:showLoading()
	elseif state == "loadOk" then
		self:hideLoading()
	elseif state == "loadErr" then
		self:showErr()
	end
end

function voiceBubble:playHorn()
	self:stopHorn()
	self.horn:run(cc.RepeatForever:create(cc.Animate:create(self.config.hornAni)))
end

function voiceBubble:stopHorn()
	self.horn:stopAllActions()
	self.horn:setSpriteFrame(self.config.hornAni:getFrames()[1]:getSpriteFrame())
end

function voiceBubble:showLoading()
	if not self.loading then
		self.loading = display.newSprite(self.config.loadingAni:getFrames()[1]:getSpriteFrame()):scale((self:geth() - 6) / self.config.loadingAni:getFrames()[1]:getSpriteFrame():getRect().height):pos((self:getw() - unreadUseW + 5) / 2, self:geth() / 2):add2(self):run(cc.RepeatForever:create(cc.Animate:create(self.config.loadingAni)))
	end

	self:hideErr()
end

function voiceBubble:hideLoading()
	if self.loading then
		self.loading:removeSelf()

		self.loading = nil
	end
end

function voiceBubble:showErr()
	if not self.err then
		self.err = display.newSprite(self.config.errTex):scale((self:geth() - 6) / self.config.errTex:getContentSize().height):pos((self:getw() - unreadUseW + 5) / 2, self:geth() / 2):add2(self)
	end

	self:hideLoading()
end

function voiceBubble:hideErr()
	if self.err then
		self.err:removeSelf()

		self.err = nil
	end
end

function voiceBubble:showUnread()
	if not self.unread then
		self.unread = display.newSprite(self.config.unreadTex):pos(self:getw() - 10, self:geth() / 2):add2(self)
	end
end

function voiceBubble:hideUnread()
	if self.unread then
		self.unread:removeSelf()

		self.unread = nil
	end
end

return voiceBubble
