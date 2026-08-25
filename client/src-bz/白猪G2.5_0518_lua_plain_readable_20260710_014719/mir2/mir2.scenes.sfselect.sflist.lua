local sflist = class("sflist", function()
	return display.newNode()
end)
local sflistitem = import(".sflistitem")

table.merge(sflist, {})

function sflist:ctor(size)
	self:setContentSize(size)

	local bg = display.newColorLayer(cc.c4b(255, 255, 255, 255)):size(size):add2(self)
	local toggle1, toggle2

	toggle1 = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(bSelect)
		print("toggle1")
		self:selectRank(1)
	end, {
		label = {
			"新服榜",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self):pos(10, self:geth() - 15):anchor(0, 1)
	toggle2 = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function(bSelect)
		print("toggle2")
		self:selectRank(2)
	end, {
		label = {
			"人气榜",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self):pos(130, self:geth() - 15):anchor(0, 1)
	self.toggle1 = toggle1
	self.toggle2 = toggle2

	local posX = self.toggle2:getPositionX() + self.toggle2:getw() + 15
	local posY = self:geth() - 25

	self.input = an.newInput(0, 0, 150, 30, 12, {
		label = {
			"",
			16
		}
	}):addTo(self, 1):pos(posX, posY):anchor(0, 0.5)

	local base = display.newColorLayer(cc.c4b(55, 62, 64, 255)):addto(self):pos(posX, posY - 18):size(self.input:getContentSize())

	posX = base:getPositionX() + base:getw() + 5
	posY = self:geth() - 13

	an.newBtn(res.gettex2("pic/common/btn10.png"), function()
		sound.playSound("104")
		self:searchServer(self.input:getString())
	end, {
		pressBig = true,
		scale9 = cc.size(50, 30),
		label = {
			"搜索",
			18
		}
	}):pos(posX, posY):add2(self):anchor(0, 1)

	self.scroll = an.newScroll(0, 0, size.width, size.height - 60):add2(self)
end

function sflist:setServerListData(data)
	self.serverlistData = data

	self:selectRank(1)
end

function sflist:searchServer(name)
	if name == nil or name == "" then
		return
	end

	if self.serverlistData then
		if not self.itemDatas then
			return
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

function sflist:gotoServer(index)
	print("gotoServer", index)

	local itemDatas = self.itemDatas

	an.newMsgbox("即将进入:" .. (itemDatas[index].servername or ""), function(idx)
		if idx == 1 then
			local serverConfig = itemDatas[index].serverip

			if serverConfig then
				local configs = string.split(serverConfig, ":")

				def.setLoginCenter(configs[1], configs[2] or 8088, itemDatas[index].servername or "servername", itemDatas[index].serverid)
				cache.setLastSfServer(itemDatas[index].servername)
				game.gotoscene("login", {
					logout = false
				}, "crossFade", 1)
			end
		elseif idx == 2 then
			-- block empty
		end
	end, {
		center = true,
		btnTexts = {
			"确定",
			"取消"
		}
	})
end

function sflist:selectRank(rankIndex)
	if rankIndex == 1 then
		self.toggle1:setIsSelect(true)
		self.toggle2:setIsSelect(false)

		if self.lastRankIndex == rankIndex then
			return
		end

		table.sort(self.serverlistData.servers, function(a, b)
			return a.rank1 < b.rank1
		end)
	else
		self.toggle1:setIsSelect(false)
		self.toggle2:setIsSelect(true)

		if self.lastRankIndex == rankIndex then
			return
		end

		table.sort(self.serverlistData.servers, function(a, b)
			return a.rank2 < b.rank2
		end)
	end

	self:refreshScrollView()

	self.lastRankIndex = rankIndex
end

function sflist:refreshScrollView()
	if not self.serverlistData.servers then
		return
	end

	local itemDatas = {}

	for i, v in ipairs(self.serverlistData.servers) do
		if v.isactive > 0 then
			table.insert(itemDatas, v)
		end
	end

	self.itemDatas = itemDatas

	if self.items and type(self.items) == "table" then
		for i, v in ipairs(self.items) do
			v:removeSelf()
		end
	end

	self.items = {}

	local scrollH = math.max(self.scroll:geth(), (#itemDatas + 1) * 31)

	self.scroll:setScrollSize(self.scroll:getw(), scrollH)

	for i, v in ipairs(itemDatas) do
		local sfitem = sflistitem.new(self, cc.size(self:getw(), 30)):add2(self.scroll):pos(0, scrollH - (i - 1) * 31 - 1):anchor(0, 1)
		local data = {
			serverName = v.servername,
			introduce = v.desc
		}

		sfitem:setData(data)
		sfitem:setScrollIndex(i)
		table.insert(self.items, sfitem)
	end
end

function sflist:onTouchSfList(scrollIndex)
	print("onTouchSfList", scrollIndex)
	self:gotoServer(scrollIndex)
end

return sflist
