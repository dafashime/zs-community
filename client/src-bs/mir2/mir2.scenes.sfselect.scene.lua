local current = ...
local common = import("..main.common.common")
local scene = class("sfselectScene", function ()
	return display.newScene("sfselect")
end)
local sflistitem = import(".sflistitem")
local sflist_list = import(".sflist")
local scheduler = require("framework.scheduler")

table.merge(scene, {})

function scene:ctor(params)
	self:setNodeEventEnabled(true)

	self.params = params
	self.curPageIndex = 1

	sound.playMusic("game_over2", true)
	res.get2("pic/login/bg.png"):addTo(self):center():fit()

	if device.platform == "android" then
		self:setKeypadEnabled(true)
		self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
			if event.key == "back" then
				an.newMsgbox("是否退出游戏?", function (idx)
					if idx == 1 then
						os.exit(1)
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end)
	end

	self:requestSfList()
end

function scene:showFirstLaunch()
	local function exitCallback()
		self.accPanel:removeSelf()
	end

	self:showPanel("请输入你要进入的传奇名称", {
		{
			text = "服务器名"
		}
	}, {
		{
			text = "进　入",
			cb = function (inputs)
				if inputs and inputs[1] then
					self:searchServer(inputs[1])
				end
			end
		}
	}, exitCallback)
	self:showRightBtns()
end

function scene:showCommonLaunch()
	local w = 600
	local pageH = display.height / 3 - 10
	local bgNode = display.newNode():addTo(self):pos(display.cx - w * 0.5, display.top - pageH):anchor(0.5, 1)

	display.newRect(cc.rect(0, 0, w, pageH), {
		borderWidth = 2,
		borderColor = cc.c4f(0, 0, 0, 1)
	}):add2(bgNode)

	local adPageView = cc.ui.UIPageView.new({
		row = 1,
		rowSpace = 0,
		columnSpace = 0,
		column = 1,
		bCirc = true,
		viewRect = cc.rect(0, 0, w, pageH),
		padding = {
			top = 0,
			left = 0,
			bottom = 0,
			right = 0
		}
	}):addTo(bgNode):onTouch(handler(self, self.onTouchAdPageView))
	self.adPageView = adPageView

	display.newRect(cc.rect(display.cx - w * 0.5, 0, w, display.height * 2 / 3), {
		borderWidth = 2,
		borderColor = cc.c4f(0, 0, 0, 1)
	}):add2(self)

	local sflist = sflist_list.new(cc.size(w, display.height * 2 / 3)):add2(self):anchor(0.5, 0):pos(display.cx, 0)
	self.sflistView = sflist

	self:showRightBtns()
end

function scene:showRightBtns()
	an.newBtn(res.gettex2("pic/login/notice.png"), function ()
		sound.playSound("104")
		self:showNotice()
	end, {
		pressBig = true
	}):addTo(self):pos(display.width - 90, display.height - 180)
	an.newBtn(res.gettex2("pic/login/bVLogin1.png"), function ()
		sound.playSound("104")

		local name = cache.getLastSfServer()

		if name ~= nil and name ~= "" then
			self:searchServer(name)
		else
			an.newMsgbox("您还未进入过服务器!", nil, {
				center = true
			})
		end
	end, {
		pressBig = true,
		label = {
			"上次登录的服务器",
			20,
			2,
			{
				color = cc.c3b(217, 200, 179)
			}
		}
	}):addTo(self):pos(display.width - 90, display.height - 230)

	if self.serverListData and self.serverListData.kaifubiao == 0 then
		return
	end

	an.newBtn(res.gettex2("pic/login/bVLogin1.png"), function ()
		sound.playSound("104")

		if self.serverListData and self.serverListData then
			local serverData = self.serverListData.servers[1]
			local w = 550
			local h = 215
			local node = display.newNode():addTo(self, 2):size(display.width, display.height)

			node:setTouchEnabled(true)

			local layer = display.newScale9Sprite(res.getframe2("pic/login/netease_bg.png"), 0, 0, cc.size(w, h)):add2(node):anchor(0.5, 0.5):pos(display.cx, display.cy)

			layer:setTouchEnabled(true)
			an.newLabel("请输入开发者地址", 24, nil, {
				color = cc.c3b(0, 176, 240)
			}):addTo(layer):anchor(0.5, 0.5):pos(w / 2, h - 30)
			an.newBtn(res.gettex2("pic/login/netease_close.png"), function ()
				node:removeSelf()
			end, {
				pressBig = true
			}):addTo(layer):anchor(1, 0.5):pos(w - 15, h - 30)

			local input = an.newInput(0, 0, 200, 30, 30, {
				label = {
					"",
					16
				}
			}):addTo(layer, 1):pos(175, h / 2):anchor(0, 0)
			local base = display.newColorLayer(cc.c4b(55, 62, 64, 255)):addto(layer):pos(175, h / 2):size(input:getContentSize())

			an.newBtn(res.gettex2("pic/login/netease_btn.png"), function ()
				sound.playSound("104")

				local address = input:getString()

				if address ~= nil and address ~= "" then
					an.newMsgbox("即将进入:" .. (serverData.servername or ""), function (idx)
						if idx == 1 then
							local serverConfig = address

							if serverConfig then
								local configs = string.split(serverConfig, ":")

								if configs then
									def.setLoginCenter(configs[1], configs[2] or 8088, serverData.servername or "servername", serverData.serverid)
									game.gotoscene("login", {
										logout = false
									}, "crossFade", 1)
								end
							end
						elseif idx == 2 then
							-- Nothing
						end
					end, {
						center = true,
						btnTexts = {
							"确定",
							"取消"
						}
					})
				end
			end, {
				pressBig = true,
				scale9 = cc.size(100, 35),
				label = {
					"进入测试",
					18,
					0,
					{
						color = cc.c3b(255, 255, 255)
					}
				}
			}):pos(w / 2, 20):add2(layer):anchor(0.5, 0)
		end
	end, {
		pressBig = true,
		label = {
			"开发者测试入口",
			20,
			2,
			{
				color = cc.c3b(217, 200, 179)
			}
		}
	}):addTo(self):pos(display.width - 90, display.height - 280)
end

function scene:onTouchAdPageView(event)
	print("onTouchAdPageView", event.pageIdx)

	self.curPageIndex = event.pageIdx

	if event.pageIdx == 1 then
		-- Nothing
	elseif event.pageIdx == 2 then
		-- Nothing
	elseif event.pageIdx == 3 then
		-- Nothing
	end
end

function scene:requestSfList()
	local url = def.sfAuthUrl

	print("requestSfList", url)

	local httpReq = network.createHTTPRequest(function (event)
		if event.name ~= "completed" then
			if event.name == "failed" then
				an.newMsgbox("获取开发者区服信息失败. ", function (idx)
					if idx == 1 then
						os.exit(0)
					elseif idx == 2 then
						self:requestSfList()
					end
				end, {
					center = true,
					btnTexts = {
						"退出",
						"重试"
					}
				}, self)
			end

			return
		end

		local request = event.request
		local code = request:getResponseStatusCode()

		if code ~= 200 then
			an.newMsgbox("获取开发者区服信息失败. ", function ()
				os.exit(0)
			end, {
				center = true
			}, self)

			return
		end

		p2("normal", request:getResponseData())

		local ret = json.decode(request:getResponseData()) or {}

		dump(ret)

		if ret and ret.serverlist and ret.serverlist.kaifubiao == 0 then
			cache.setIsFirstLaunchGame(true)
		end

		self.serverListData = ret.serverlist

		if cache.getIsFirstLaunchGame() then
			self:showFirstLaunch()
		else
			self:showCommonLaunch()

			if ret and ret.serverlist.imglist then
				self:updateAdPageView(ret.serverlist.imglist)
			end

			if ret and ret.serverlist then
				self.sflistView:setServerListData(ret.serverlist)
			end
		end

		if ret and ret.serverlist and ret.serverlist.notice then
			def.setSFNotice(ret.serverlist.notice)
		end
	end, url, "GET")

	httpReq:start()
end

function scene:searchServer(name)
	if name == nil or name == "" then
		return
	end

	if self.serverListData then
		if not self.itemDatas then
			local itemDatas = {}

			for i, v in ipairs(self.serverListData.servers) do
				if v.isactive > 0 then
					table.insert(itemDatas, v)
				end
			end

			self.itemDatas = itemDatas
		end

		local bHave = false

		for i, v in ipairs(self.itemDatas) do
			local p1, p2 = string.find(v.servername, name)

			if p1 == 1 and p2 == string.len(v.servername) then
				bHave = true

				self:gotoServer(i)

				break
			end
		end

		if not bHave then
			an.newMsgbox("未搜索到该服务器!", nil, {
				center = true
			})
		end
	end
end

function scene:gotoServer(index)
	print("gotoServer", index)

	local itemDatas = self.itemDatas

	an.newMsgbox("即将进入:" .. (itemDatas[index].servername or ""), function (idx)
		if idx == 1 then
			local serverConfig = itemDatas[index].serverip

			if serverConfig then
				local configs = string.split(serverConfig, ":")

				def.setLoginCenter(configs[1], configs[2] or 8088, itemDatas[index].servername or "servername", itemDatas[index].serverid)
				cache.setIsFirstLaunchGame(false)
				cache.setLastSfServer(itemDatas[index].servername)
				game.gotoscene("login", {
					logout = false
				}, "crossFade", 1)
			end
		elseif idx == 2 then
			-- Nothing
		end
	end, {
		center = true,
		btnTexts = {
			"确定",
			"取消"
		}
	})
end

function scene:updateAdPageView(imgList)
	local adPageView = self.adPageView

	adPageView:removeAllItems()

	local w = 600
	local pageH = display.height / 3 - 10

	for i, v in ipairs(imgList) do
		local item = adPageView:newItem()
		local netSprite = an.newNetSprite(v.url, cc.size(w, pageH))

		netSprite:anchor(0, 0)
		item:addChild(netSprite)
		adPageView:addItem(item)
	end

	adPageView:reload()

	if self.pageHandler then
		scheduler.unscheduleGlobal(self.pageHandler)
	end

	local function onInterval(dt)
		if self.curPageIndex == self.adPageView:getPageCount() then
			self.curPageIndex = 0
		end

		adPageView:gotoPage(self.curPageIndex + 1, true)
	end

	self.pageHandler = scheduler.scheduleGlobal(onInterval, 2)
end

function scene:onCleanup()
end

function scene:onEnterTransitionFinish()
end

function scene:onEnter()
end

function scene:onExit()
	if self.pageHandler then
		scheduler.unscheduleGlobal(self.pageHandler)
	end
end

function scene:showNotice()
	local content = def.sfNotice or ""
	local node = display.newNode():size(display.width, display.height):addTo(self, 10)
	local noticebg = res.get2("pic/common/black_2.png"):addTo(node):pos(node:centerPos()):anchor(0.5, 0.5):scale(0.1)

	noticebg:runAction(cc.ScaleTo:create(0.2, 1))
	res.get2("pic/login/notice_title.png"):addTo(noticebg):pos(noticebg:getw() / 2, noticebg:geth() - 25)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "ended" and not cc.rectContainsPoint(noticebg:getBoundingBox(), cc.p(event.x, event.y)) then
			node:removeSelf()
		end

		return true
	end)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		node:removeSelf()
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):addTo(noticebg):pos(noticebg:getw() - 8, noticebg:geth() - 8):anchor(1, 1)
	display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), 14, 14, cc.size(noticebg:getw() - 28, noticebg:geth() - 68)):addTo(noticebg):anchor(0, 0)

	local scroll = an.newScroll(25, 20, noticebg:getw() - 50, noticebg:geth() - 80):addTo(noticebg):anchor(0, 0)
	local labelM = an.newLabelM(noticebg:getw() - 50, 20, 1, {
		manual = false
	}):addTo(scroll):pos(0, noticebg:geth() - 80):anchor(0, 1):nextLine()
	local parseing = true

	local function parseContent(block)
		local p = string.find(block, "/>")
		local szText = string.trim(string.sub(block, 1, p + 1))
		local data = string.split(szText, " ")
		local params = {}

		for i, v in ipairs(data) do
			local temp = string.split(v, "=")

			if temp[1] and temp[2] then
				params[temp[1]] = temp[2]
			end
		end

		labelM:setFontSize(tonumber(params.size) or 20)

		local urlcolor = string.split(params.urlcolor, "|")
		urlcolor = cc.c3b(tonumber(urlcolor[1] or 255) or 255, tonumber(urlcolor[2] or 255), tonumber(urlcolor[3] or 255))
		local textcolor = string.split(params.textcolor, "|")
		textcolor = cc.c3b(tonumber(textcolor[1] or 255) or 255, tonumber(textcolor[2] or 255), tonumber(textcolor[3] or 255))

		if params.urladdr then
			labelM:addLabel(params.urltext or params.urladdr, urlcolor, nil, nil, function ()
				device.openURL(params.urladdr)
			end)
		end

		block = string.sub(block, p + 2)
		local p1 = string.find(block, "<t")
		local p2 = string.find(block, "/>")

		if p1 and p2 then
			szText = string.sub(block, p1 + 3, p2 - 1)
			szText = string.gsub(szText, "\\n", "\n")

			labelM:addLabel(szText, textcolor)
		end
	end

	while true do
		if content == "" then
			break
		end

		local p1 = string.find(content, "<b")
		local p2 = string.find(content, "</b>")

		if p1 and p2 then
			local block = string.sub(content, p1 + 3, p2 - 1)

			parseContent(block)

			if string.len(content) <= p2 + 4 then
				break
			else
				content = string.sub(content, p2 + 4)
			end
		end
	end
end

function scene:showPanel(title, inputs, btnsCfg, exitCallback)
	local internal = 55
	local w = 550
	local h = internal * #inputs + 160
	local colorTitle = cc.c3b(0, 176, 240)
	local colorInputBg = cc.c4b(55, 62, 64, 255)
	local colorInputTitle = cc.c3b(0, 179, 140)
	local colorBtnBg = cc.c4b(241, 76, 75, 255)
	local colorBtnTitle = cc.c3b(255, 255, 255)
	self.accPanel = display.newNode():size(display.size):addto(self, 1)

	self.accPanel:setTouchEnabled(false)

	local layer = display.newScale9Sprite(res.getframe2("pic/login/netease_bg.png"), 0, 0, cc.size(w, h)):add2(self.accPanel):anchor(0.5, 0.5):pos(display.cx, display.cy)

	layer:setTouchEnabled(true)
	an.newLabel(title, 24, nil, {
		color = colorTitle
	}):addTo(layer):anchor(0.5, 0.5):pos(w / 2, h - 30)

	local off = 90
	local inputWids = {}

	for k, v in pairs(inputs) do
		local iw = 180
		local ih = 32
		local ip = an.newInput(0, 0, iw, ih, 12, {
			label = {
				"",
				24
			},
			password = v.password
		}):addTo(layer, 1):pos(w / 2 + 20, h - off)
		local base = display.newColorLayer(colorInputBg):addto(layer)

		base:setContentSize(ip:getContentSize())
		base:setPosition(w / 2 - iw / 2 + 20, h - off - ih / 2)
		an.newLabel(tostring(v.text), 22, nil, {
			color = colorInputTitle
		}):addto(base):pos(-10, ih / 2):anchor(1, 0.5)

		inputWids[k] = ip
		off = off + internal
	end

	local btns = {}
	local totalWidth = 0

	for k, v in pairs(btnsCfg) do
		local text = an.newLabel(v.text, 24, nil, {
			color = colorBtnTitle
		})
		local sz = text:getContentSize()
		local btn = display.newScale9Sprite(res.getframe2("pic/login/netease_btn.png"), 0, 0, cc.size(sz.width + 24, sz.height + 5)):add2(layer):anchor(0, 0)

		btn:addChild(text)
		text:pos(sz.width / 2 + 10, sz.height / 2 + 2.5):anchor(0.5, 0.5)

		btns[k] = btn
		totalWidth = totalWidth + btn:getw()

		text:enableClick(function ()
			local inputStrings = {}

			for k, v in pairs(inputWids) do
				inputStrings[k] = v:getString()
			end

			v.cb(inputStrings)
		end)
	end

	local gap = (w - totalWidth) / (#btnsCfg + 1)
	local btnY = 30
	local off = 0

	for k, v in pairs(btns) do
		v:pos(off + gap, btnY)

		off = off + gap + v:getw()
	end
end

function scene:showLayer(name, ...)
	if self.layer then
		if self.layer.__cname == name then
			return
		else
			self.layer:removeSelf()
		end
	end

	self.layer = import("." .. name, current).new(self, ...):addto(self)
end

function scene:hideLayer(name)
	if self.layer and self.layer.__cname == name then
		self.layer:removeSelf()

		self.layer = nil
	end
end

function scene:getSfList()
end

return scene
