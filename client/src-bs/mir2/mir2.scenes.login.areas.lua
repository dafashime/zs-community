local areas = class("areas", function ()
	return display.newNode()
end)

table.merge(areas, {})

function areas:ctor(scene, forceSelect, serverlistCallback)
	self.scene = scene
	self.serverlistCallback = serverlistCallback

	self:requestServerList()
end

function areas:requestServerList()
	local url = string.format("http://%s:%s/account", def.loginCenterIP, def.loginCenterPort)

	print("requestServerList", url)

	local httpReq = network.createHTTPRequest(function (event)
		if event.name ~= "completed" then
			if event.name == "failed" then
				an.newMsgbox("获取服务器列表失败. ", function (idx)
					if idx == 1 then
						os.exit(0)
					elseif idx == 2 then
						self:requestServerList()
					end
				end, {
					center = true,
					btnTexts = {
						"退出",
						"重试"
					}
				})
			end

			return
		end

		local request = event.request
		local code = request:getResponseStatusCode()

		if code ~= 200 then
			an.newMsgbox("获取服务器列表失败. ", function ()
				os.exit(0)
			end, {
				center = true
			})

			return
		end

		p2("login", request:getResponseData())

		local ret = json.decode(request:getResponseData()) or {}

		g_data.login:setVerInfo(ret.serverlist.verinfo)
		g_data.login:setShopUrl(ret.serverlist.shopurl)
		g_data.login:setServerList(ret.serverlist.servers)
		g_data.login:setNotice(ret.serverlist.notice)
		g_data.login:setNetLastName(ret.last)
		self:loadServer()
	end, url, "POST")

	httpReq:start()
end

function areas:loadLayer()
	if self.layer then
		self.layer:removeSelf()
	end

	self.layer = display.newNode():addTo(self):size(display.width, display.height):anchor(0, 0)

	self:size(self.layer:getContentSize()):anchor(0.5, 0.5):center()

	return self.layer
end

function areas:loadServer()
	local bg = self:loadLayer()
	local areabg = res.get2("pic/login/areabg.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() / 2)

	res.get2("pic/login/line1.png"):addTo(areabg):pos(155, 182)
	res.get2("pic/login/line2.png"):addTo(areabg):pos(372, 282)
	an.newBtn(res.gettex2("pic/login/return.png"), function ()
		sound.playSound("104")
		g_data.login:resetLogin()
		def.setIsLazyLoadConfig(false)
		def.resetGameServer()
		def.resetLoginCenter()
		game.gotoscene("sfselect", {
			logout = false
		})
	end, {
		pressBig = true
	}):add2(bg):pos(90, display.height - 80)

	if def.isSelectServer then
		an.newBtn(res.gettex2("pic/login/manage.png"), function ()
			sound.playSound("104")
			game.gotoscene("login", {
				logout = true
			})
		end, {
			pressBig = true
		}):addTo(bg):pos(display.width - 90, display.height - 80)
	end

	an.newBtn(res.gettex2("pic/login/notice.png"), function ()
		sound.playSound("104")
		self:showNotice()
	end, {
		pressBig = true
	}):addTo(bg):pos(display.width - 90, display.height - 180)

	if not g_data.login.localLastSer then
		self:showNotice()
	end

	local info = "抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。适度游戏益脑，\n沉迷游戏伤身。合理安排时间，享受健康生活。严厉打击赌博，营造和谐环境。"

	an.newLabel(info, 18, 1, {
		color = cc.c3b(245, 243, 202)
	}):anchor(0.5, 0.5):pos(display.cx, 55):add2(bg)

	if WIN32_OPERATE then
		self:extend()
	end

	local servers = {}
	local suggest = {}
	local last = nil

	for i, v in ipairs(g_data.login.verinfo) do
		if v.verid then
			servers[v.verid] = {}
		end
	end

	for i, v in ipairs(g_data.login.servers or {}) do
		if v.verid then
			table.insert(servers[v.verid], v)
		end

		if v.suggest > 0 then
			table.insert(suggest, v)
		end

		if v.name == g_data.login.netLastName then
			last = v
		end
	end

	for k, v in pairs(servers) do
		table.sort(v, function (a, b)
			return a.zoneid < b.zoneid
		end)
	end

	table.sort(suggest, function (a, b)
		return a.zoneid < b.zoneid
	end)

	local scroll = an.newScroll(27, 31, 125, 305):addTo(areabg)
	local list = nil
	local suggestMark = res.get2("pic/login/new.png"):addTo(areabg):pos(370, 265)

	suggestMark:setVisible(false)

	local btns = {}

	local function newServerBtn(data, parent, pos)
		local btn = an.newBtn(res.gettex2("pic/login/b9.png"), function ()
			if not data then
				return
			end

			if data.force then
				an.newMsgbox(data.zoneid .. "区" .. data.zonename .. "\n" .. g_data.login.forces[data.force], nil, {
					center = true
				})
			else
				self:selectServer(data)
			end
		end, {
			support = "scroll",
			pressImage = res.gettex2("pic/login/b10.png"),
			label = {
				data and data.zoneid .. "区 " .. data.zonename or "暂无记录",
				20,
				2
			}
		}):addTo(parent):pos(pos.x, pos.y):anchor(0, 1)

		if data then
			btn.label:setPositionX(btn.label:getPositionX() + 9)

			if data.heat then
				res.get2("pic/login/heat_" .. data.heat .. ".png"):addTo(btn):pos(18, btn:geth() / 2):anchor(0.5, 0.5)
			end
		end
	end

	local function click(btn)
		if list then
			list:removeSelf()
		end

		if btn.suggest then
			suggestMark:setVisible(true)
		else
			suggestMark:setVisible(false)
		end

		list = an.newScroll(165, 25, 420, 220):add2(areabg):pos(165, 30):anchor(0, 0)

		if btn.data then
			for i, v in ipairs(btn.data) do
				if i % 2 == 1 then
					newServerBtn(v, list, cc.p(0, list:geth() - math.floor((i - 1) / 2) * 45))
				else
					newServerBtn(v, list, cc.p(225, list:geth() - math.floor((i - 1) / 2) * 45))
				end
			end
		end

		for i, v in ipairs(btns) do
			if btn == v then
				v:select()
			else
				v:unselect()
			end
		end
	end

	local function addVerCategoryBtn(data, title, isSuggest)
		local btn = an.newBtn(res.gettex2("pic/login/b5.png"), click, {
			support = "scroll",
			select = {
				res.gettex2("pic/login/b6.png")
			},
			label = {
				title,
				20,
				2
			}
		}):addTo(scroll):pos(62, 300 - #btns * 40):anchor(0.5, 1)
		btn.data = data
		btn.suggest = isSuggest
		btns[#btns + 1] = btn
	end

	addVerCategoryBtn(suggest, "推荐区组", true)

	for i, v in ipairs(g_data.login.verinfo) do
		addVerCategoryBtn(servers[v.verid], v.vername)
	end

	click(btns[1])
	res.get2("pic/login/last.png"):addTo(areabg):pos(230, 312):anchor(0.5, 0.5)
	newServerBtn(last, areabg, cc.p(306.5, 332.5))
end

function areas:selectServer(data)
	local bg = self:loadLayer()

	an.newBtn(res.gettex2("pic/login/return.png"), function ()
		sound.playSound("104")
		self:loadServer()
	end, {
		pressBig = true
	}):add2(bg):pos(90, display.height - 80)

	local panel = res.get2("pic/login/curren_ser.png"):addTo(bg):pos(bg:getw() / 2, 250)

	an.newLabel(g_data.login:getVerName(data.verid), 20, 2, {
		color = def.colors.labelYellow
	}):addTo(panel):pos(panel:getw() / 2, 130):anchor(0.5, 0.5)

	local scene = self.scene

	local function enterGame()
		if IS_PLAYER_DEBUG and DEBUG > 0 then
			m2debug.setting.last = data

			cache.saveDebug("setting", m2debug.setting)
		end

		g_data.login:setLocalLastServer(data)
		sound.playSound("104")

		local clientVer = g_data.login:getClientVer(data.verid)

		def.setGameServer(data.zoneid or "", data.zoneip or "", data.area or "", clientVer or 180, data.serverinfo, data.ConfigName, data.ConfigVer)

		local bNeedRequest = false

		if data.ConfigName and data.ConfigVer then
			local configDir = device.writablePath .. "config/"

			if not io.exists(configDir) then
				ycFunction:mkdir(configDir)
			end

			local serveridDir = device.writablePath .. "config/" .. def.serverId .. "/"

			if not io.exists(serveridDir) then
				ycFunction:mkdir(serveridDir)
			end

			local dir = self:getConfigFileDir()

			if not io.exists(dir) then
				ycFunction:mkdir(dir)
			end

			local zipFilePath = dir .. data.ConfigName
			local verFilePath = dir .. "configver.json"

			if io.exists(zipFilePath) then
				if io.exists(verFilePath) then
					local ver = nil
					local rawData = io.readfile(verFilePath)

					if rawData then
						local data2 = json.decode(rawData)

						if data2 then
							ver = data2.ver
						end
					end

					if ver and data.ConfigVer ~= ver then
						bNeedRequest = true
					else
						bNeedRequest = false
					end
				else
					bNeedRequest = true
				end
			else
				bNeedRequest = true
			end

			def.setIsLazyLoadConfig(true)
		else
			bNeedRequest = false

			def.setIsLazyLoadConfig(false)
		end

		if bNeedRequest then
			self:requestConfigZip()
		elseif self.serverlistCallback then
			self.serverlistCallback()
		end
	end

	local btn = an.newBtn(res.gettex2("pic/login/b7.png"), enterGame, {
		pressImage = res.gettex2("pic/login/b8.png"),
		label = {
			data.zoneid .. "区 " .. data.zonename,
			20,
			2,
			cc.c3b(206, 191, 165)
		}
	}):addTo(panel):pos(panel:getw() / 2, 80)

	btn.label:setPositionX(btn.label:getPositionX() + 9)
	res.get2("pic/login/heat_" .. data.heat .. ".png"):addTo(btn):pos(18, btn:geth() / 2)
	an.newLabel("点击进入游戏", 16, 2):addTo(panel):pos(panel:getw() / 2, 40):anchor(0.5, 0.5)
end

function areas:requestConfigZip()
	local url = def.loginCenter .. "/downloadconfig/" .. def.configName
	local maskLayer = display.newNode():addTo(self):enableClick(function ()
	end):size(display.width, display.height)
	local progressLabel = an.newLabel("正在更新该区补丁...", 25, 1, {
		color = cc.c3b(255, 0, 0)
	}):anchor(0.5, 0.5):pos(display.cx, display.cy):add2(maskLayer)

	print("requestConfigZip", url)

	local httpReq = network.createHTTPRequest(function (event)
		if event.name ~= "completed" then
			if event.name == "failed" then
				if maskLayer then
					maskLayer:removeSelf()
				end

				an.newMsgbox("获取该区补丁失败.", function ()
				end, {
					center = true
				})
			end

			return
		end

		local request = event.request
		local code = request:getResponseStatusCode()

		if code ~= 200 then
			if maskLayer then
				maskLayer:removeSelf()
			end

			an.newMsgbox("获取该区补丁失败.", function ()
			end, {
				center = true
			})

			return
		end

		local function saveConfigFileAndVer()
			local dir = self:getConfigFileDir()
			local zipFilePath = dir .. def.configName
			local verFilePath = dir .. "configver.json"

			request:saveResponseData(zipFilePath)
			io.writefile(verFilePath, json.encode({
				ver = def.configVer
			}))

			local unzipDir = dir .. "config/"

			if not io.exists(unzipDir) then
				ycFunction:mkdir(unzipDir)
			end

			print("unzip", unzipDir)
			ycFunction:unzip(zipFilePath, unzipDir, false)
		end

		saveConfigFileAndVer()
		print("requestConfigZip success")

		if maskLayer then
			maskLayer:removeSelf()
		end

		if self.serverlistCallback then
			self.serverlistCallback()
		end
	end, url, "GET")

	httpReq:setTimeout(200)
	httpReq:start()
end

function areas:getConfigFileDir()
	if not def.serverId or not def.zoneid or def.serverId == "" or def.zoneid == "" then
		return ""
	end

	local dir = device.writablePath .. "config/" .. def.serverId .. "/" .. def.zoneid .. "/"

	return dir
end

function areas:showNotice()
	local content = g_data.login.notice or ""
	local node = display.newNode():size(display.width, display.height):addTo(self)
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

function areas:removeMask()
	if self.mask then
		self.mask:removeSelf()

		self.mask = nil
	end
end

function areas:extend()
	if IS_PLAYER_DEBUG then
		g_data.login:setServerList({
			{
				heat = 2,
				name = "内网98",
				id = 3,
				suggest = true,
				ip = "172.30.10.98",
				area = 0,
				ver = 180,
				group = {
					min = 1,
					max = 10
				}
			}
		})
	else
		local data = parseJson("config/serverlist.json")

		g_data.login:setServerList(data.servers)
	end
end

return areas
