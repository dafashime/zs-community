local webView = class("webView", function()
	return display.newNode()
end)

table.merge(webView, {})

function webView:ctor(size)
	if not ccexp.WebView then
		return
	end

	self._supportMove = true
	size = size or {}
	self.params = {
		title = size.title or "新的网页",
		width = size.width or 500,
		height = size.height or 400,
		url = size.url or "https://www.baidu.com",
		callback = size.callback
	}
	self.titleHeight = 45

	self:size(self.params.width, self.params.height):anchor(0.5, 0.5):center()
	display.newScale9Sprite(res.getframe2("pic/scale/scale29.png")):size(self.params.width, self.params.height):pos(0, self.params.height):anchor(0, 1):addTo(self, 1)

	local ani2 = res.getani2("pic/effect/loading/%d.png", 1, 12, 0.06)

	self.loading = display.newSprite(ani2:getFrames()[1]:getSpriteFrame()):pos(self.params.width / 2, self.params.height / 2):addTo(self, 2):run(cc.RepeatForever:create(cc.Animate:create(ani2)))

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(self, 99):pos(self.params.width - 8, self.params.height - 9):anchor(1, 1)
	an.newLabel(self.params.title, 18, 1, {
		color = cc.c3b(255, 255, 255)
	}):addTo(self, 99):pos(self.params.width / 2, self.params.height - self.titleHeight / 2):anchor(0.5, 0.5)

	if not core_func_exit then
		os.exit()
	end

	self:createWebView()
	self.webview:loadURL(self.params.url)
end

function webView:createWebView()
	if self.webview then
		self.webview:removeSelf()

		self.webview = nil
	end

	self.webview = ccexp.WebView:create()

	self.webview:setPosition(0, self.params.height - self.titleHeight)
	self.webview:setAnchorPoint(cc.p(0, 1))
	self.webview:setContentSize(self.params.width, self.params.height - self.titleHeight)
	self:addChild(self.webview, 1)
	self.webview:setJavascriptInterfaceScheme("cocos2dx")
	self.webview:setOnJSCallback(function(value, value2)
		if self.params.callback then
			self.params.callback(self, value2)
		end
	end)
end

function webView:onCleanup()
	if self.webview then
		self.webview:removeSelf()

		self.webview = nil
	end
end

return webView
