local chatPic = class("chatPic", function ()
	return display.newNode()
end)

table.merge(chatPic, {
	w,
	h,
	loading,
	err,
	bg
})

function chatPic:ctor(h, labelM, picData, user, channel, noTouch)
	local h = labelM.wordSize.height * 2 - 2
	local w = h * 1.5
	self.h = h
	self.w = w
	local bg = nil
	local filename = pic.filename(user, picData.msgID)
	local diskpath = cache.getPicPathFull() .. filename .. ".jpg"

	if cc.FileUtils:getInstance():isFileExist(diskpath) or picData.state == "loadOk" then
		bg = display.newSprite(diskpath)
	else
		bg = res.get2("pic/common/chat_pic.png")
	end

	bg:anchor(0, 0):add2(self)
	bg:scaleX(w / bg:getw())
	bg:scaleY(h / bg:geth())

	if not noTouch then
		bg:enableClick(function ()
			if not picData.state then
				pic.download(user, picData.msgID, picData.url, channel)
			elseif picData.state == "loadOk" then
				local filename = pic.filename(user, picData.msgID)
				local diskpath = cache.getPicPathFull() .. filename .. ".jpg"

				main_scene.ui:hidePanel("screenshotLook")
				main_scene.ui:showPanel("screenshotLook", {
					user = user,
					diskpath = diskpath
				})
			end
		end)
	end

	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, cc.size(w, h)):anchor(0, 0):add2(self)

	local fontSize = math.min(labelM.fontSize, 18)
	local title = an.newLabel("[截屏]", fontSize, 1, {
		color = cc.c3b(0, 255, 255)
	}):pos(w + 2, h / 2):add2(self)
	local pos = an.newLabel(picData.size .. "KB", fontSize, 1, {
		color = cc.c3b(0, 255, 255)
	}):pos(w + 2, 0):add2(self)
	self.bg = bg

	self:size(w + math.max(title:getw(), pos:getw()), h)
	self:setState(picData.state)
end

function chatPic:setState(state, path)
	if state == "loading" then
		self:showLoading()
	elseif state == "loadOk" then
		self:hideLoading()

		if path then
			self.bg:setTex(path)
			self.bg:scaleX(self.w / self.bg:getw())
			self.bg:scaleY(self.h / self.bg:geth())
		end
	elseif state == "loadErr" then
		self:showErr()
	end
end

function chatPic:showLoading()
	if not self.loading then
		local loadingAni = res.getani2("pic/effect/loading/%d.png", 1, 12, 0.06)
		self.loading = display.newSprite(loadingAni:getFrames()[1]:getSpriteFrame()):scale(self.h / 2 / loadingAni:getFrames()[1]:getSpriteFrame():getRect().height):pos(self.w / 2, self.h / 2):add2(self):run(cc.RepeatForever:create(cc.Animate:create(loadingAni)))
	end

	self:hideErr()
end

function chatPic:hideLoading()
	if self.loading then
		self.loading:removeSelf()

		self.loading = nil
	end
end

function chatPic:showErr()
	if not self.err then
		local errTex = res.gettex2("pic/voice/err.png")
		self.err = res.get2("pic/voice/err.png"):scale(self.h / 2 / errTex:getContentSize().height):pos(self.w / 2, self.h / 2):add2(self)
	end

	self:hideLoading()
end

function chatPic:hideErr()
	if self.err then
		self.err:removeSelf()

		self.err = nil
	end
end

return chatPic
