local bzUIConfig = require("mir2.bzUIConfig")
local areas = class("areas", function()
	return display.newNode()
end)

table.merge(areas, {})

function areas:ctor(scene, forceSelect, serverlistCallback)
	self.scene = scene
	self.serverlistCallback = serverlistCallback

	self.requestServerList(self)

	self.reqTimes = 5
	self.curTimes = 0
	self.areaCfg = bzUIConfig.loginArea
	self.mlastServer = nil
	self.latestServer = nil
	self.firstVisit = true
	self.baseDir = "pic/bzmir/newui/login/"
end

function areas:getPath(value)
	return self.baseDir .. value
end

function areas.getVerid()
	if def.verid then
		return def.verid
	end

	if io.exists(device.writablePath .. "res/data/ver.zip") then
		local number = io.readfile(device.writablePath .. "res/data/ver.zip")

		def.verid = tonumber(number)
	end

	return def.verid
end

function areas:requestServerList()
	local text = string.format("http://%s:%s/account", bzmir.gateIP, bzmir.gatePort)
	local httpReq = network.createHTTPRequest(function(event)
		if event.name ~= "completed" then
			if event.name == "failed" then
				if self.curTimes < self.reqTimes then
					self:requestServerList()

					self.curTimes = self.curTimes + 1
				else
					an.newMsgbox("获取服务器信息失败. ", function(idx)
						if idx == 1 then
							os.exit(0)
						elseif idx == 2 then
							self.curTimes = 0

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
			end

			return
		end

		local request = event.request

		if request.getResponseStatusCode(request) ~= 200 then
			an.newMsgbox("获取服务器信息失败. ", function()
				os.exit(0)
			end, {
				center = true
			})

			return
		end

		local ret = json.decode(request.getResponseData(request)) or {}

		g_data.login:setVerInfo(ret.serverlist.verinfo)
		g_data.login:setShopUrl(ret.serverlist.shopurl)
		g_data.login:setServerList(ret.serverlist.servers)
		g_data.login:setNotice(ret.serverlist.notice)

		if ret.stime then
			g_data.login.serverTime = tonumber(ret.stime)
		end

		self:getVerid()

		if def.skipLastServer then
			self:loadServer()
		else
			self:loadLastServer()
		end
	end, text, "POST")

	httpReq.start(httpReq)
	scheduler.scheduleGlobal(function()
		local text = string.format("http://%s:%s/account", bzmir.gateIP, bzmir.gatePort)
		local hTTPRequest = network.createHTTPRequest(function(value)
			if value.name ~= "completed" then
				return
			end

			local jsonText = value.request

			if jsonText.getResponseStatusCode(jsonText) ~= 200 then
				return
			end

			local data = json.decode(jsonText.getResponseData(jsonText)) or {}

			if data and data.stime then
				g_data.login.serverTime = tonumber(data.stime)

				print("serverTime:", g_data.login.serverTime)
			end
		end, text, "POST")

		hTTPRequest.start(hTTPRequest)
	end, 500 + math.random(50, 100))
end

function areas:loadLayer()
	if self.layer then
		self.layer:removeSelf()
	end

	self.layer = display.newNode():addTo(self):size(display.width, display.height):anchor(0, 0)

	self.size(self, self.layer:getContentSize()):anchor(0.5, 0.5):center()

	return self.layer
end

function areas:loadLastServer(path)
	local layer = self.loadLayer(self)

	an.newBtn(res.gettex2(self:getPath(self.areaCfg.btnReturn.pic .. ".png")), function()
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
	}):add2(layer):pos(self.areaCfg.btnReturn.posx, self.areaCfg.btnReturn.posy)

	if def.isSelectServer then
		an.newBtn(res.gettex2(self:getPath(self.areaCfg.changeAccount.pic .. ".png")), function()
			sound.playSound("104")
			game.gotoscene("login", {
				logout = true
			})
		end, {
			pressBig = true
		}):addTo(layer):pos(self.areaCfg.changeAccount.posx, self.areaCfg.changeAccount.posy)
	end

	an.newBtn(res.gettex2(self:getPath(self.areaCfg.notice.pic .. ".png")), function()
		sound.playSound("104")
		self:showNotice()
	end, {
		pressBig = true
	}):addTo(layer):pos(self.areaCfg.notice.posx, self.areaCfg.notice.posy)

	if not g_data.login.localLastSer and self.firstVisit then
		self.showNotice(self)
	end

	res.get2(self:getPath("PA.png")):addTo(self):pos(display.width - 90, 150)

	self.firstVisit = false

	local value = self.areaCfg.info.text

	an.newLabel(value, self.areaCfg.info.fontSize, 1, {
		color = self.areaCfg.info.fontColor
	}):anchor(0.5, 0.5):pos(self.areaCfg.info.posx, self.areaCfg.info.posy):add2(layer)

	if WIN32_OPERATE then
		self.extend(self)
	end

	local servers = {}
	local suggest = {}
	local value2
	local value3

	for i, v in ipairs(g_data.login.verinfo) do
		if v.verid then
			if not def.verid then
				value2 = value2 or v.verid
				servers[v.verid] = {}
			elseif v.verid == def.verid then
				value2 = v.verid
				servers[v.verid] = {}
			end
		end
	end

	local value4 = g_data.login.servers or {}
	local value5 = self.mlastServer or cache.getDiy("server", "lastServer")

	for _, v2 in ipairs(value4) do
		if v2.verid and servers[v2.verid] then
			local value6 = v2.name or v2.zonename

			table.insert(servers[v2.verid], v2)

			if v2.suggest > 0 then
				table.insert(suggest, v2)
			end

			if value5 and value5 == value6 .. tostring(v2.zoneid) then
				self.latestServer = v2
			end
		end
	end

	for k, v3 in pairs(servers) do
		table.sort(v3, function(a, b)
			return a.zoneid < b.zoneid
		end)
	end

	table.sort(suggest, function(a, b)
		return a.suggest > b.suggest
	end)

	local latestServer = path or suggest[1]

	latestServer = latestServer or servers[value2][1]

	if not self.latestServer then
		self.latestServer = latestServer
	end

	if self.areaCfg.mainlogo.logoPlayAni then
		local ani2 = res.getani2("pic/bzmir/newui/logo/%d.png", 1, self.areaCfg.mainlogo.logoPlayAniMax, self.areaCfg.mainlogo.logoPlayAniInterval)

		if ani2 then
			ani2:retain()

			local value_2 = res.get2("pic/bzmir/newui/logo/1.png"):addTo(layer):pos(self.areaCfg.mainlogo.posx, self.areaCfg.mainlogo.posy)

			if value_2 then
				value_2:runForever(cc.Animate:create(ani2))
			end
		end
	else
		res.get2(self:getPath(self.areaCfg.mainlogo.pic .. ".png")):addTo(layer):pos(self.areaCfg.mainlogo.posx, self.areaCfg.mainlogo.posy)
	end

	local x = (function(data, value, x)
		local tex2 = res.gettex2(self:getPath(self.areaCfg.mainAeea.suggestBtnPic .. ".png"))
		local btn = an.newBtn(tex2, function()
			if not data then
				return
			end

			if data.force then
				an.newMsgbox(data.zoneid .. "区 " .. data.zonename .. "\n" .. g_data.login.forces[data.force], nil, {
					center = true
				})
			else
				self:loadServer()
			end
		end, {
			support = "scroll",
			pressImage = res.gettex2(self:getPath(self.areaCfg.mainAeea.suggestBtnPicPress .. ".png")),
			label = {
				data and data.zoneid .. "区 " .. data.zonename or "无最近登陆",
				20,
				2
			}
		}):addTo(value):pos(x.x, x.y):anchor(0.5, 0.5)

		if data then
			btn.label:setPositionX(btn.label:getPositionX() + 9)

			if data.heat then
				res.get2(self:getPath("heat_" .. data.heat .. ".png")):addTo(btn):pos(18, btn.geth(btn) / 2):anchor(0.5, 0.5)
			end
		end

		return btn
	end)(latestServer, layer, cc.p(self.areaCfg.mainAeea.suggestServerPosx, self.areaCfg.mainAeea.suggestServerPosy))

	if latestServer and latestServer.suggest > 0 then
		res.get2(self:getPath(self.areaCfg.mainAeea.suggestNewPic .. ".png")):addTo(x):pos(x:getw() + self.areaCfg.mainAeea.suggestNewPicOffsetx, x:geth() + self.areaCfg.mainAeea.suggestNewPicOffsety):anchor(1, 1)
	end

	an.newBtn(res.gettex2(self:getPath("fix_client.png")), function()
		sound.playSound("104")
		_rmClientRes()
	end, {
		pressBig = true
	}):addTo(self):pos(display.width - 90, display.height - 280)
	an.newBtn(res.gettex2(self:getPath(self.areaCfg.mainAeea.moreZoneBtnPic .. ".png")), function()
		self:loadServer()
	end, {
		support = "scroll",
		pressImage = res.gettex2(self:getPath(self.areaCfg.mainAeea.moreZoneBtnPicPress .. ".png")),
		label = {
			"更多区服",
			20,
			2
		}
	}):addTo(layer):pos(self.areaCfg.mainAeea.moreZonePosx, self.areaCfg.mainAeea.moreZonePosy):anchor(0.5, 0.5)

	if self.latestServer then
		an.newLabel(self.areaCfg.mainAeea.currentZoneText .. self.latestServer.zoneid .. "区 " .. self.latestServer.zonename, self.areaCfg.mainAeea.currentZoneFontSize, 1, {
			color = self.areaCfg.mainAeea.currentZoneFontColor
		}):anchor(0.5, 0.5):pos(self.areaCfg.mainAeea.currentZoneFontPosx, self.areaCfg.mainAeea.currentZoneFontPosy):add2(layer)

		local tex2 = res.gettex2(self:getPath(self.areaCfg.mainAeea.loginPic .. ".png"))

		an.newBtn(tex2, function()
			self:goLoginAccount(self.latestServer)
		end, {
			support = "scroll",
			pressImage = res.gettex2(self:getPath(self.areaCfg.mainAeea.loginPicPress .. ".png")),
			label = {
				"",
				20,
				2
			}
		}):addTo(layer):pos(self.areaCfg.mainAeea.loginPicPosx, self.areaCfg.mainAeea.loginPicPosy):anchor(0.5, 0.5)
	end
end

function areas:loadServer()
	local layer = self.loadLayer(self)
	local value_2 = res.get2(self:getPath(self.areaCfg.moreZone.bgpic .. ".png")):addTo(layer):pos(layer.getw(layer) / 2, layer.geth(layer) / 2)

	if WIN32_OPERATE then
		self.extend(self)
	end

	local servers = {}
	local items = {}

	for _, verinfo in ipairs(g_data.login.verinfo) do
		if verinfo.verid then
			if not def.verid then
				servers[verinfo.verid] = {}
			elseif verinfo.verid == def.verid then
				servers[verinfo.verid] = {}
			end
		end
	end

	local value = g_data.login.servers or {}

	for _2, item in ipairs(value) do
		if item.verid and servers[item.verid] then
			table.insert(servers[item.verid], item)

			if item.suggest > 0 then
				table.insert(items, item)
			end
		end
	end

	for _3, item2 in pairs(servers) do
		table.sort(item2, function(zoneidOwner, zoneidOwner2)
			return zoneidOwner.zoneid > zoneidOwner2.zoneid
		end)
	end

	table.sort(items, function(suggestOwner, suggestOwner2)
		return suggestOwner.suggest < suggestOwner2.suggest
	end)

	local scroll = an.newScroll(self.areaCfg.moreZone.leftScrollRect.x, self.areaCfg.moreZone.leftScrollRect.y, self.areaCfg.moreZone.leftScrollRect.w, self.areaCfg.moreZone.leftScrollRect.h):add2(value_2):pos(self.areaCfg.moreZone.leftScrollPos.x, self.areaCfg.moreZone.leftScrollPos.y):anchor(0, 0)
	local list
	local btns = {}

	local function cleanup(data, parent, pos)
		local btn = an.newBtn(res.gettex2(self:getPath(self.areaCfg.moreZone.zonebg .. ".png")), function()
			if not data then
				return
			end

			if data.force then
				an.newMsgbox(data.zoneid .. "区 " .. data.zonename .. "\n" .. g_data.login.forces[data.force], nil, {
					center = true
				})
			else
				self.mlastServer = data.zonename .. tostring(data.zoneid)

				if def.skipLastServer then
					self:goLoginAccount(data)
				else
					self:loadLastServer(data)
				end
			end
		end, {
			support = "scroll",
			pressImage = res.gettex2(self:getPath(self.areaCfg.moreZone.zonebgPress .. ".png")),
			label = {
				data and data.zoneid .. "区 " .. data.zonename or "暂无记录",
				20,
				2
			}
		}):addTo(parent):pos(pos.x, pos.y):anchor(0, 1)

		if data then
			btn.label:setPositionX(btn.label:getPositionX() + 9)

			if data.heat then
				res.get2(self:getPath("heat_" .. data.heat .. ".png")):addTo(btn):pos(18, btn.geth(btn) / 2):anchor(0.5, 0.5)
			end
		end
	end

	local function click(btn)
		if list then
			list:removeSelf()
		end

		list = an.newScroll(self.areaCfg.moreZone.zoneScrollRect.x, self.areaCfg.moreZone.zoneScrollRect.y, self.areaCfg.moreZone.zoneScrollRect.w, self.areaCfg.moreZone.zoneScrollRect.h):add2(value_2):pos(self.areaCfg.moreZone.zoneScrollPos.x, self.areaCfg.moreZone.zoneScrollPos.y):anchor(0, 0)

		if btn.data then
			for i, v in pairs(btn.data) do
				table.sort(v, function(zoneidOwner, zoneidOwner2)
					return zoneidOwner.zoneid > zoneidOwner2.zoneid
				end)
			end

			for i2, data in ipairs(btn.data) do
				if self.areaCfg.moreZone.rows == 2 then
					if i2 % 2 == 1 then
						cleanup(data, list, cc.p(0, list:geth() - math.floor((i2 - 1) / 2) * self.areaCfg.moreZone.rowStep))
					else
						cleanup(data, list, cc.p(self.areaCfg.moreZone.row2Xpos, list:geth() - math.floor((i2 - 1) / 2) * self.areaCfg.moreZone.rowStep))
					end
				else
					cleanup(data, list, cc.p(0, list:geth() - (i2 - 1) * self.areaCfg.moreZone.rowStep))
				end
			end
		end

		for i3, v2 in ipairs(btns) do
			if btn == v2 then
				v2.select(v2)
			else
				v2.unselect(v2)
			end
		end
	end

	local function addVerCategoryBtn(data, title, isSuggest)
		local btn = an.newBtn(res.gettex2(self:getPath(self.areaCfg.moreZone.leftBtnNormal .. ".png")), click, {
			support = "scroll",
			select = {
				res.gettex2(self:getPath(self.areaCfg.moreZone.leftBtnOn .. ".png"))
			},
			label = {
				title,
				20,
				2
			}
		}):addTo(scroll):pos(self.areaCfg.moreZone.leftBtnPosx, self.areaCfg.moreZone.leftBtnStartPosy - #btns * self.areaCfg.moreZone.leftBtnPosyStep):anchor(0.5, 0.5)

		btn.data = data
		btn.suggest = isSuggest
		btns[#btns + 1] = btn
	end

	addVerCategoryBtn(items, "推荐区组" or "推荐区组", true)

	for i, v in ipairs(g_data.login.verinfo) do
		if servers[v.verid] then
			addVerCategoryBtn(servers[v.verid], v.vername)
		end
	end

	click(btns[1])
end

function areas:goLoginAccount(data)
	if IS_PLAYER_DEBUG and DEBUG > 0 then
		m2debug.setting.last = data

		cache.saveDebug("setting", m2debug.setting)
	end

	if data.heat and data.heat == 1 then
		an.newMsgbox("当前大区正在维护", function()
			return
		end, {
			center = true
		})

		return
	end

	g_data.login:setLocalLastServer(data)
	sound.playSound("104")
	g_data.login:setNetLastName(data.zonename)
	cache.saveDiy("server", "lastServer", data.zonename .. tostring(data.zoneid))

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
				local ver
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

function areas:selectServer(data)
	if data.heat and data.heat == 1 then
		an.newMsgbox("当前大区正在维护", function()
			return
		end, {
			center = true
		})

		return
	end

	local layer = self.loadLayer(self)

	an.newBtn(res.gettex2(self:getPath("return.png")), function()
		sound.playSound("104")
		self:loadServer()
	end, {
		pressBig = true
	}):add2(layer):pos(90, display.height - 80)

	local value_2 = res.get2(self:getPath("curren_ser.png")):addTo(layer):pos(layer.getw(layer) / 2, 250)

	an.newLabel(g_data.login:getVerName(data.verid), 20, 2, {
		color = def.colors.labelYellow
	}):addTo(value_2):pos(value_2.getw(value_2) / 2, 130):anchor(0.5, 0.5)

	local scene = self.scene

	local function callback()
		if IS_PLAYER_DEBUG and DEBUG > 0 then
			m2debug.setting.last = data

			cache.saveDebug("setting", m2debug.setting)
		end

		g_data.login:setLocalLastServer(data)
		sound.playSound("104")
		g_data.login:setNetLastName(data.zonename)
		cache.saveDiy("server", "lastServer", data.zonename .. tostring(data.zoneid))

		local clientVer = g_data.login:getClientVer(data.verid)

		def.setGameServer(data.zoneid or "", data.zoneip or "", data.area or "", clientVer or 180, data.serverinfo, data.ConfigName, data.ConfigVer)

		local enabled = false

		if data.ConfigName and data.ConfigVer then
			local value = device.writablePath .. "config/"

			if not io.exists(value) then
				ycFunction:mkdir(value)
			end

			local value2 = device.writablePath .. "config/" .. def.serverId .. "/"

			if not io.exists(value2) then
				ycFunction:mkdir(value2)
			end

			local configFileDir = self:getConfigFileDir()

			if not io.exists(configFileDir) then
				ycFunction:mkdir(configFileDir)
			end

			local value3 = configFileDir .. data.ConfigName
			local value4 = configFileDir .. "configver.json"

			if io.exists(value3) then
				if io.exists(value4) then
					local value5
					local jsonText = io.readfile(value4)

					if jsonText then
						local data = json.decode(jsonText)

						if data then
							value5 = data.ver
						end
					end

					if value5 and data.ConfigVer ~= value5 then
						enabled = true
					else
						enabled = false
					end
				else
					enabled = true
				end
			else
				enabled = true
			end

			def.setIsLazyLoadConfig(true)
		else
			enabled = false

			def.setIsLazyLoadConfig(false)
		end

		if enabled then
			self:requestConfigZip()
		elseif self.serverlistCallback then
			self.serverlistCallback()
		end
	end

	local btn = an.newBtn(res.gettex2(self:getPath("/b7.png")), callback, {
		pressImage = res.gettex2(self:getPath("b8.png")),
		label = {
			string.format("%s区 %s", data.zoneid, data.zonename),
			20,
			2,
			cc.c3b(206, 191, 165)
		}
	}):addTo(value_2):pos(value_2.getw(value_2) / 2, 80)

	btn.label:setPositionX(btn.label:getPositionX() + 9)
	res.get2(self:getPath("heat_" .. data.heat .. ".png")):addTo(btn):pos(18, btn.geth(btn) / 2)
	an.newLabel("点击进入游戏", 16, 2):addTo(value_2):pos(value_2.getw(value_2) / 2, 40):anchor(0.5, 0.5)
end

function areas:requestConfigZip()
	local url = def.loginCenter .. "/downloadconfig/" .. def.configName
	local maskLayer = display.newNode():addTo(self):enableClick(function()
		return
	end):size(display.width, display.height)
	local label = an.newLabel("正在更新游戏配置...", 25, 1, {
		color = cc.c3b(255, 0, 0)
	}):anchor(0.5, 0.5):pos(display.cx, display.cy - 80):add2(maskLayer)
	local httpReq = network.createHTTPRequest(function(event)
		if event.name ~= "completed" then
			if event.name == "failed" then
				if maskLayer then
					maskLayer:removeSelf()
				end

				an.newMsgbox("配置文件获取失败", function()
					return
				end, {
					center = true
				})
			end

			return
		end

		local request = event.request

		if request.getResponseStatusCode(request) ~= 200 then
			if maskLayer then
				maskLayer:removeSelf()
			end

			an.newMsgbox("配置文件获取失败", function()
				return
			end, {
				center = true
			})

			return
		end

		;(function()
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

			ycFunction:unzip(zipFilePath, unzipDir, false)
		end)()

		if maskLayer then
			maskLayer:removeSelf()
		end

		if self.serverlistCallback then
			self.serverlistCallback()
		end
	end, url, "GET")

	httpReq.setTimeout(httpReq, 200)
	httpReq.start(httpReq)
end

function areas:getConfigFileDir()
	if not def.serverId or not def.zoneid or def.serverId == "" or def.zoneid == "" then
		return ""
	end

	return device.writablePath .. "config/" .. def.serverId .. "/" .. def.zoneid .. "/"
end

function areas:showNotice()
	local content = g_data.login.notice or ""
	local node = display.newNode():size(display.width, display.height):addTo(self)
	local noticebg = res.get2("pic/common/black_2.png"):addTo(node):pos(node.centerPos(node)):anchor(0.5, 0.5):scale(0.1)

	noticebg.runAction(noticebg, cc.ScaleTo:create(0.2, 1))
	res.get2(self:getPath("notice_title.png")):addTo(noticebg):pos(noticebg.getw(noticebg) / 2, noticebg.geth(noticebg) - 25)
	node.setTouchEnabled(node, true)
	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "ended" and not cc.rectContainsPoint(noticebg:getBoundingBox(), cc.p(event.x, event.y)) then
			node:removeSelf()
		end

		return true
	end)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		node:removeSelf()
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):addTo(noticebg):pos(noticebg.getw(noticebg) - 8, noticebg.geth(noticebg) - 8):anchor(1, 1)
	display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), 14, 14, cc.size(noticebg.getw(noticebg) - 28, noticebg.geth(noticebg) - 68)):addTo(noticebg):anchor(0, 0)

	local scroll = an.newScroll(25, 20, noticebg.getw(noticebg) - 50, noticebg.geth(noticebg) - 80):addTo(noticebg):anchor(0, 0)
	local labelM = an.newLabelM(noticebg.getw(noticebg) - 50, 20, 1, {
		manual = false
	}):addTo(scroll):pos(0, noticebg.geth(noticebg) - 80):anchor(0, 1):nextLine()
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
		local number = cc.c3b(tonumber(urlcolor[1] or 255) or 255, tonumber(urlcolor[2] or 255), tonumber(urlcolor[3] or 255))
		local textcolor = string.split(params.textcolor, "|")
		local textcolor2 = cc.c3b(tonumber(textcolor[1] or 255) or 255, tonumber(textcolor[2] or 255), tonumber(textcolor[3] or 255))

		if params.urladdr then
			labelM:addLabel(params.urltext or params.urladdr, number, nil, nil, function()
				device.openURL(params.urladdr)
			end)
		end

		block = string.sub(block, p + 2)

		local p1 = string.find(block, "<t")
		local p2 = string.find(block, "/>")

		if p1 and p2 then
			local text = string.sub(block, p1 + 3, p2 - 1)
			local szText2 = string.gsub(text, "\\n", "\n")

			labelM:addLabel(szText2, textcolor2)
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
	local data = parseJson("config/serverlist.json")

	g_data.login:setServerList(data.servers)
end

return areas
