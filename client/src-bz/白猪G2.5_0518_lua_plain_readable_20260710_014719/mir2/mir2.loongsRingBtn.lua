local cls = class("loongsRingBtn", function()
	return display.newNode()
end)

function cls:ctor(spriteFilename, clickCb, heightOffsetDiv, heightDiv)
	self.cb = clickCb
	heightDiv = heightDiv or 2
	heightOffsetDiv = heightOffsetDiv or 2

	local tex = res.gettex2(spriteFilename)
	local texsz = tex:getContentSize()
	local height = texsz.height
	local sprFrm = cc.SpriteFrame:createWithTexture(tex, cc.rect(texsz.width / 2, height / heightOffsetDiv, texsz.width / 8, height / heightDiv))
	local spr = display.newSprite(sprFrm):addto(self)

	self.spr = spr
	self.height = height
	self.texsz = texsz
	self.heightOffsetDiv = heightOffsetDiv
	self.heightDiv = heightDiv

	spr:setTouchEnabled(true)
	spr:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			self:setTex(1)

			return true
		elseif event.name == "ended" then
			self:setTex(0)

			if spr:hitTest(event) then
				clickCb()
			end
		end
	end)
end

function cls:setTex(num)
	self.spr:setTextureRect(cc.rect(self.texsz.width / 2 + self.texsz.width / 8 * num, self.height / self.heightOffsetDiv, self.texsz.width / 8, self.height / self.heightDiv))
end

return cls
