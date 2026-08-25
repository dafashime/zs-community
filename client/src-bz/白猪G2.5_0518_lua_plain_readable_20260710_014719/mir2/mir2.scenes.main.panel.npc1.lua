local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local npc = class("npc", function()
	return display.newNode()
end)

table.merge(npc, {
	list = {},
	sell = {}
})

function npc:ctor(params)
	local bg1 = res.get2("pic/panels/npc/bg1.png")
	local bg2 = res.get2("pic/panels/npc/bg2.png")
	local bg3 = res.get2("pic/panels/npc/bg3.png")
	local showName = params.npcName ~= "NPC"
	local content = an.newLabelM(bg1:getw() - 40, 20, 1)
	local pos = string.find(params.body, "{cmd}")
	local cmdStr

	if pos then
		local text = string.sub(params.body, 1, pos - 1)

		cmdStr = string.sub(params.body, pos, string.len(params.body))
		params.body = text
	end

	self:parseContent(content, params)

	local tmpList = {}
	local btnLayer = display.newNode():addTo(self, 1):debug()

	if cmdStr then
		params.body = cmdStr
		tmpList = self:parseCcmd(content, params)

		for i, v in ipairs(tmpList) do
			local offsetX = (bg1:getw() - 40) / #v

			for k, cmd in ipairs(v) do
				if cmd.title ~= "" then
					res.get2("pic/panels/npc/icon.png"):addTo(btnLayer):anchor(1, 0.5):pos(50 + (k - 1) * offsetX, -(i - 1) * 40)

					local lb = an.newLabel(cmd.title, 20, 1, {
						color = cc.c3b(255, 255, 0)
					}):addTo(btnLayer):anchor(0, 0.5):pos(54 + (k - 1) * offsetX, -(i - 1) * 40)

					lb:setTouchEnabled(true)
					lb:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
						if event.name == "began" then
							lb:scale(1.1):setColor(cc.c3b(255, 0, 0))

							lb.startPos = cc.p(event.x, event.y)

							return true
						elseif event.name == "ended" then
							lb:scale(1):setColor(cc.c3b(255, 255, 0))

							if not lb.disable then
								self:clickCMD(params.merchant, cmd.cmd)
							end
						elseif cc.pGetDistance(lb.startPos, event) > 35 then
							lb:scale(1):setColor(cc.c3b(255, 255, 0))

							lb.disable = true
						end
					end)
					lb:setName("npc_" .. cmd.title)
				end
			end
		end
	end

	local maxHeight = math.max(content:geth() + (showName and 40 or 20) + #tmpList * 40, 200)

	self:anchor(0, 1):pos(0, display.height - 20):size(cc.size(bg1:getw(), maxHeight))
	self:setNodeEventEnabled(true)
	bg1:anchor(0, 1):pos(0, self:geth()):add2(self)
	bg2:anchor(0, 0):scaley((self:geth() - bg1:geth() - bg3:geth()) / bg2:geth()):pos(0, bg3:geth()):add2(self)
	bg3:anchor(0, 0):add2(self)

	if showName then
		an.newLabel(params.npcName, 20, 1, {
			color = cc.c3b(83, 215, 119)
		}):addTo(self):anchor(0, 0.5):pos(25, self:geth() - 36)
	end

	content:anchor(0, 1):pos(25, self:geth() - (showName and 54 or 34)):addto(self)
	btnLayer:pos(0, self:geth() - (showName and 34 or 14) - content:geth())
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 9, self:geth() - 8):addto(self)

	self.list = {}
	self.sell = {}

	if main_scene.ground.player then
		self.x = main_scene.ground.player.x
		self.y = main_scene.ground.player.y
	end

	main_scene.ui:hidePanel("storage")
end

function npc:onCleanup()
	if main_scene.ui.panels.bag and not main_scene.ui.panels.fusion and not main_scene.ui.panels.strengthen then
		main_scene.ui.panels.bag:resetPanelPosition("left")
	end

	print("npc:onCleanup()")
	self:delSellItem()
end

function npc:parseContent(content, params)
	local function parseCMD(v)
		while true do
			local pos1 = string.find(v, "<")
			local pos2 = string.find(v, ">")

			if pos1 and pos2 then
				content:addLabel(string.sub(v, 1, pos1 - 1))

				local cmd = string.sub(v, pos1 + 1, pos2 - 1)

				if string.upper(cmd) ~= "C" and string.upper(cmd) ~= "/C" then
					local text, cmdstr, color = ""
					local pos3 = string.find(cmd, "/")

					if pos3 then
						text = string.sub(cmd, 1, pos3 - 1)
						cmdstr = string.sub(cmd, pos3 + 1, #cmd)

						local pos4 = string.find(cmdstr, "=")

						if pos4 then
							color = string.sub(cmdstr, pos4 + 1, #cmdstr)
							cmdstr = string.sub(cmdstr, 1, pos4 - 1)

							if color == "red" then
								color = 249
							end
						end
					else
						text = cmd
					end

					if string.upper(text) == "FONTSIZE" then
						content:setFontSize(tonumber(cmdstr))
					else
						if color then
							color = def.colors.get(tonumber(color))
						else
							color = cmdstr ~= nil and def.colors.clYellow or def.colors.clRed
						end

						local labelParams

						if cmdstr and string.upper(cmdstr) ~= "FCOLOR" then
							labelParams = {
								ani = true,
								easyTouch = true,
								addTouchSizeY = 12,
								callback = function()
									self:clickCMD(params.merchant, cmdstr)
								end
							}
						end

						content:addLabel(text, color, nil, nil, labelParams):setName(text)
					end
				end

				v = string.sub(v, pos2 + 1, string.len(v))
			else
				content:addLabel(v)

				break
			end
		end
	end

	params.body = string.gsub(params.body, "\\", "")

	local lines = string.split(params.body, "|")

	for i, line in ipairs(lines) do
		local parts = string.split(line, "^")
		local space = content:getw() / #parts

		for i, str in ipairs(parts) do
			if i > 1 then
				content:setCurLineWidthCnt((i - 1) * space)
			end

			parseCMD(str)
		end

		content:nextLine()
	end
end

function npc:parseCcmd(content, params)
	local function parseCMD(v, cmdList)
		local tmdCmd = {}

		while true do
			local pos1 = string.find(v, "<")
			local pos2 = string.find(v, ">")

			if pos1 and pos2 then
				local cmd = string.sub(v, pos1 + 1, pos2 - 1)

				if string.upper(cmd) ~= "C" and string.upper(cmd) ~= "/C" then
					local text, cmdstr, color = ""
					local pos3 = string.find(cmd, "/")

					if pos3 then
						text = string.sub(cmd, 1, pos3 - 1)
						cmdstr = string.sub(cmd, pos3 + 1, #cmd)

						local pos4 = string.find(cmdstr, "=")

						if pos4 then
							cmdstr = string.sub(cmdstr, 1, pos4 - 1)
						end
					else
						text = cmd
					end

					if string.upper(text) == "FONTSIZE" then
						content:setFontSize(tonumber(cmdstr))
					elseif cmdstr and string.upper(cmdstr) ~= "FCOLOR" then
						tmdCmd[#tmdCmd + 1] = {
							title = text,
							cmd = cmdstr
						}
					end
				end

				v = string.sub(v, pos2 + 1, string.len(v))
			else
				break
			end
		end

		cmdList[#cmdList + 1] = tmdCmd
	end

	local cmdList = {}

	params.body = string.gsub(params.body, "\\", "")
	params.body = string.gsub(params.body, "{cmd}", "")
	params.body = string.gsub(params.body, "^", "")

	local lines = string.split(params.body, "|")

	for i, line in ipairs(lines) do
		parseCMD(line, cmdList)
	end

	return cmdList
end

function npc:clickCMD(merchant, cmdstr)
	sound.playSound("105")

	if cmdstr ~= nil then
		local sendstr = cmdstr

		local function send()
			net.send({
				CM_MERCHANTDLGSELECT,
				recog = merchant
			}, {
				sendstr
			})
		end

		if string.byte(cmdstr, 1) == string.byte("@", 1) and string.byte(cmdstr, 2) == string.byte("@", 1) then
			if cmdstr == "@@buildguildnow" then
				local msgbox

				msgbox = an.newMsgbox("\n请输入建立这个行会名称.\n", function()
					if msgbox.input:getString() == "" then
						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			elseif cmdstr == "@@guildwar" then
				local msgbox

				msgbox = an.newMsgbox("\n请输入对方行会名称.\n", function()
					if msgbox.input:getString() == "" then
						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			elseif string.find(cmdstr, "@@InPutInteger") then
				local msgbox

				msgbox = an.newMsgbox("\n输入信息.\n", function()
					if msgbox.input:getString() == "" then
						an.newMsgbox("信息不能为空！")

						return
					end

					local num = tonumber(msgbox.input:getString())

					if not num then
						an.newMsgbox("输入数据中包含了非法符号，请重新输入!")

						return
					end

					if num >= 0 and num > 2147483646 then
						an.newMsgbox("输入数字范围必须在0到21亿之间，请重新输入！")

						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			elseif string.find(cmdstr, "@@helper") then
				local helper = main_scene.ground.helper
				local hCmd = string.sub(cmdstr, 3)
				local cmds = string.split(hCmd, "@")

				if #cmds > 0 then
					print(cmds[1])

					local proc = loadstring(cmds[1])

					setfenv(proc, {
						helper = helper
					})
					proc()
				end

				if cmds[2] then
					net.send({
						CM_MERCHANTDLGSELECT,
						recog = merchant
					}, {
						"@" .. cmds[2]
					})
				end
			elseif string.find(cmdstr, "@@StrengthenEquip") then
				main_scene.ui:togglePanel("fusion")
			elseif string.find(cmdstr, "@@StrengthenCloth") then
				main_scene.ui:togglePanel("strengthen")
			else
				local msgbox

				msgbox = an.newMsgbox("\n输入信息.\n", function()
					if msgbox.input:getString() == "" then
						an.newMsgbox("信息不能为空！")

						return
					end

					if string.find(msgbox.input:getString(), "/") or string.find(msgbox.input:getString(), "\\") then
						an.newMsgbox("输入数据中包含了非法符号，请重新输入!")

						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			end
		else
			send()
		end
	end
end

function npc:showInput(msg, buf, bufLen)
	if msg.tag == 3 then
		return
	end

	local msgbox

	msgbox = an.newMsgbox(net.str(buf) .. "\n", function(idx)
		if idx == 1 then
			local str = ""

			if idx == 1 then
				if msgbox.nameInput:getString() == "" then
					an.newMsgbox("信息不能为空！")

					return
				end

				if string.find(msgbox.nameInput:getString(), "/") or string.find(msgbox.nameInput:getString(), "\\") then
					an.newMsgbox("输入数据中包含了非法符号，请重新输入!")

					return
				end

				if msg.tag == 0 then
					str = msgbox.nameInput:getString()
				end
			end

			msg[1] = CM_MERCHANT_QUERY
			msg.series = idx

			net.send(msg, {
				str
			})
		end
	end, {
		disableScroll = true,
		hasCancel = true
	})
	msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 31, {
		checkCLen = true,
		label = {
			"",
			20,
			1
		},
		bg = {
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		},
		tip = {
			"",
			20,
			1,
			{
				color = cc.c3b(128, 128, 128)
			}
		}
	}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() - 80 - msgbox.labelM:geth())
end

function npc:showList(merchant, count, buf, srcbufLen, type, menuIdx)
	self:scaleTo(0.3, 1)

	if not self.listLayer then
		local bg = res.get2("pic/panels/npc/listbg.png"):anchor(0, 0)

		an.newBtn(res.gettex2("pic/common/close10.png"), function()
			sound.playSound("103")
			self:hideList()
		end, {
			pressImage = res.gettex2("pic/common/close11.png")
		}):anchor(0.5, 1):pos(bg:getw(), bg:geth()):addto(bg)
		an.newBtn(res.gettex2("pic/panels/shop/front.png"), handler(self, self.clickPrev), {
			pressBig = true
		}):pos(53, 37):add2(bg)
		an.newBtn(res.gettex2("pic/panels/shop/after.png"), handler(self, self.clickNext), {
			pressBig = true
		}):pos(175, 37):add2(bg)
		an.newBtn(res.gettex2("pic/common/btn20.png"), handler(self, self.clickBuy), {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/common/confirm.png")
		}):pos(290, 37):add2(bg)

		self.pageLabel = an.newLabel("1/3", 20, 1):pos(96, 27):add2(bg)
		self.listLayer = display.newNode():anchor(0, 1):size(bg:getContentSize()):add(bg):add2(self)

		self:addTouchFrame(self.listLayer:getBoundingBox(), "list")
	end

	self.list.merchant = merchant
	self.list.type = type
	self.list.menuIdx = menuIdx
	self.list.datas = {}
	self.list.page = 1
	self.list.selectIdx = nil
	self.list.count = count

	print("menuIdx ", menuIdx)

	local clientGood

	if type == "goods_detail" or type == "storage" then
		local bufLen = srcbufLen

		for i = 1, count do
			clientGood, buf, bufLen = net.record("TClientItem", buf, bufLen)
			self.list.datas[#self.list.datas + 1] = clientGood
		end
	else
		local bufLen = count * getRecordSize("PNewMarketInfo")

		for i = 1, count do
			clientGood, buf, bufLen = net.record("PNewMarketInfo", buf, bufLen)
			self.list.datas[#self.list.datas + 1] = {
				grade = -1,
				name = clientGood:get("kindName"),
				sub = clientGood:get("nextFlag"),
				price = clientGood:get("mPrice"),
				s = def.items[clientGood:get("itemIndex")],
				serverIdx = clientGood:get("mCount")
			}

			print(clientGood:get("kindName"), clientGood:get("mPrice"), clientGood:get("itemIndex"))
		end
	end

	self:initItems()
end

function npc:hideList()
	if self.listLayer then
		self.listLayer:removeSelf()

		self.listLayer = nil

		self:removeTouchFrame("list")
	end

	self.list = {}
end

function npc:initItems(selectIdx)
	if self.list.layer then
		self.list.layer:removeSelf()
	end

	self.list.layer = display.newNode():add2(self.listLayer)
	self.list.selectIdx = nil

	local items = {}

	local function clickItem(item)
		for i, v in ipairs(items) do
			if v.node == item.node then
				v.name:setColor(display.COLOR_RED)

				if v.text1 then
					v.text1:setColor(display.COLOR_RED)
				end

				if v.text2 then
					v.text2:setColor(display.COLOR_RED)
				end

				self.list.selectIdx = item.idx

				local p = item.node:convertToWorldSpace(cc.p(item.node:getw() - 30, item.node:geth()))

				if self.list.type == "goods" or self.list.type == "synthesis" then
					itemInfo.show(item.data.s, p, {
						onlyStdItem = true
					})
				else
					itemInfo.show(item.data, p, {
						hideMaxDura = self.list.type == "goods_detail"
					})
				end
			else
				v.name:setColor(display.COLOR_WHITE)

				if v.text1 then
					v.text1:setColor(display.COLOR_WHITE)
				end

				if v.text2 then
					v.text2:setColor(display.COLOR_WHITE)
				end
			end
		end
	end

	local begin = (self.list.page - 1) * 10 + 1
	local max = begin + 9

	for i = begin, max do
		if i > #self.list.datas then
			break
		end

		local data = self.list.datas[i]
		local name, text1, text2, looks

		if self.list.type == "goods" then
			name = data.name
			text1 = data.price .. " 金币"
			looks = data.s:get("looks")
		elseif self.list.type == "goods_detail" then
			name = data.getVar("name")
			text1 = Word(data:get("duraMax")) .. " 金币"
			text2 = "持久: " .. math.modf(Word(data:get("dura")) / 1000)
			looks = data.getVar("looks")
		elseif self.list.type == "synthesis" then
			name = data.name
			text1 = data.price .. " 金币"
			looks = data.s:get("looks")
		else
			name = data.getVar("name")
			text1 = "持久: " .. math.modf(Word(data:get("dura")) / 1000) .. "/" .. math.modf(Word(data:get("duraMax")) / 1000)
			looks = data.getVar("looks")
		end

		local item = {
			idx = i,
			data = data
		}

		item.node = display.newNode():size(168, 54):add2(self.list.layer):pos(16 + ((i - begin + 1) % 2 == 0 and 167 or -3), 283 - math.modf((i - begin) / 2) * 54):enableClick(function()
			sound.playSound("105")
			clickItem(item)
		end)

		if looks then
			res.get("items", looks):pos(23, 25):addto(item.node)
		end

		if name then
			item.name = an.newLabel(name, 16, 1):pos(52, 32):add2(item.node)
		end

		if text1 then
			item.text1 = an.newLabel(text1, 16, 1):pos(52, text2 and 18 or 8):add2(item.node)
		end

		if text2 then
			item.text2 = an.newLabel(text2, 16, 1):pos(52, text1 and 3 or 8):add2(item.node)
		end

		items[#items + 1] = item
	end

	self.pageLabel:setString(string.format("%d/%d", self.list.page, math.ceil(#self.list.datas / 10)))

	if selectIdx then
		local finded = false

		for i, v in ipairs(items) do
			if v.idx == selectIdx then
				finded = true

				clickItem(v)

				break
			end
		end

		if not finded and #items > 0 then
			clickItem(items[#items])
		end
	end
end

function npc:clickPrev()
	sound.playSound("103")

	if self.list.type == "goods_detail" then
		if self.list.menuIdx > 0 then
			self.list.menuIdx = math.max(0, self.list.menuIdx - 10)

			net.send({
				CM_USERGETDETAILITEM,
				recog = self.list.merchant,
				param = self.list.menuIdx
			}, {
				self.list.detailName
			})
		end
	elseif self.list.page > 1 then
		self.list.page = self.list.page - 1

		self:initItems()
	end
end

function npc:clickNext()
	sound.playSound("103")

	if self.list.type == "goods_detail" then
		self.list.menuIdx = self.list.menuIdx + 10

		net.send({
			CM_USERGETDETAILITEM,
			recog = self.list.merchant,
			param = self.list.menuIdx
		}, {
			self.list.detailName
		})
	elseif self.list.page < math.ceil(#self.list.datas / 10) then
		self.list.page = self.list.page + 1

		self:initItems()
	end
end

function npc:clickBuy()
	sound.playSound("103")

	if self.list.selectIdx and (not g_data.client.lastTime.buy or socket.gettime() - g_data.client.lastTime.buy > 0.5) then
		local v = self.list.datas[self.list.selectIdx]

		if v then
			g_data.client:setLastTime("buy", true)

			if self.list.type == "goods" and v.sub > 0 then
				self.list.detailName = v.name

				net.send({
					CM_USERGETDETAILITEM,
					recog = self.list.merchant
				}, {
					v.name
				})
			else
				local ident, serverIdx, name

				if self.list.type == "goods" then
					ident, serverIdx, name = CM_USERBUYITEM, v.serverIdx, v.name
				elseif self.list.type == "goods_detail" then
					ident, serverIdx, name = CM_USERBUYITEM, v:get("makeIndex"), v.getVar("name")
				elseif self.list.type == "storage" then
					ident, serverIdx, name = CM_USERTAKEBACKSTORAGEITEM, v:get("makeIndex"), v.getVar("name")
				elseif self.list.type == "synthesis" then
					ident, serverIdx, name = CM_USERMAKEDRUGITEM, v.serverIdx, v.name
				end

				net.send({
					ident,
					recog = self.list.merchant,
					param = Loword(serverIdx),
					tag = Hiword(serverIdx)
				}, {
					name
				})
			end
		end
	end
end

function npc:removeItem(serverIdx)
	if not self.list.datas or self.list.type == "goods" then
		return
	end

	for i, v in ipairs(self.list.datas) do
		if v:get("makeIndex") == serverIdx then
			table.remove(self.list.datas, i)
			self:initItems(self.list.selectIdx)

			break
		end
	end
end

function npc:showSellFrame(merchant, type, sp)
	print("npc:showSellFrame ", type)

	if not self.sellLayer then
		local bg = res.get2("pic/panels/npc/sellbg.png"):anchor(0, 0)
		local layer = display.newNode():anchor(1, 1):pos(self:getw() - 12, 0):size(bg:getw(), bg:geth()):add(bg):add2(self)

		self:addTouchFrame(layer:getBoundingBox(), "sell")
		an.newBtn(res.gettex2("pic/common/close10.png"), function()
			sound.playSound("103")
			self:hideSell()
		end, {
			pressImage = res.gettex2("pic/common/close11.png"),
			size = cc.size(64, 64)
		}):anchor(0, 1):pos(bg:getw() - 16, bg:geth() - 5):addto(bg)
		an.newBtn(res.gettex2("pic/panels/npc/sure0.png"), function()
			sound.playSound("103")
			self:clickSellOk(sp)
		end, {
			pressImage = res.gettex2("pic/panels/npc/sure1.png")
		}):anchor(0, 0):pos(102, 4):addto(bg)

		self.sell.text = an.newLabel("", 16, 1):pos(14, layer:geth() - 27):add2(layer)
		self.sellLayer = layer

		self.sellLayer:show()
	end

	self.sell.merchant = merchant
	self.sell.type = type

	self:setSellText()
end

function npc:hideSell()
	self:delSellItem()

	if self.sellLayer then
		self.sellLayer:removeSelf()

		self.sellLayer = nil

		self:removeTouchFrame("sell")
	end

	self.sell = {}
end

function npc:setSellText(value)
	if not self.sellLayer then
		return
	end

	local texts = {
		exchange = "",
		storage = "保管物品",
		repair = "修理: ",
		sell = "出售: ",
		playDrink = "请酒"
	}
	local text = texts[self.sell.type]

	if text then
		self.sell.text:setString(text .. (value or ""))
	end
end

function npc:addSellItem(bagItem)
	self:delSellItem()

	local data = bagItem.data

	g_data.bag:delItem(data:get("makeIndex"))

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
	end

	self.sell.itemData = data
	self.sell.item = item.new(data, self):pos(77, 102):scale(1.2):add2(self.sellLayer)

	if self.sell.type == "repair" then
		local makeIndex = data:get("makeIndex")

		net.send({
			CM_MERCHANTQUERYREPAIRCOST,
			recog = self.sell.merchant,
			param = Loword(makeIndex),
			tag = Hiword(makeIndex)
		}, {
			data.getVar("name")
		})
	elseif self.sell.type == "sell" then
		local makeIndex = data:get("makeIndex")

		net.send({
			CM_MERCHANTQUERYSELLPRICE,
			recog = self.sell.merchant,
			param = Loword(makeIndex),
			tag = Hiword(makeIndex)
		}, {
			data.getVar("name")
		})
	end
end

function npc:delSellItem()
	if self.sell.item then
		self.sell.item:removeSelf()

		self.sell.item = nil
	end

	if self.sell.itemData then
		g_data.bag:addItem(self.sell.itemData)

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:addItem(self.sell.itemData:get("makeIndex"))
		end

		self.sell.itemData = nil
	end

	self:setSellText()
end

function npc:clickSellOk(sp)
	if self.sell.itemData and (not g_data.client.lastTime.sell or socket.gettime() - g_data.client.lastTime.sell > 5) then
		local ident

		if self.sell.type == "repair" then
			ident = CM_USERREPAIRITEM
		elseif self.sell.type == "sell" then
			ident = CM_USERSELLITEM
		elseif self.sell.type == "storage" then
			ident = CM_USERSTORAGEITEM
		elseif self.sell.type == "playDrink" then
			ident = CM_USERPLAYDRINKITEM
		elseif self.sell.type == "exchange" then
			ident = CM_COMMIT_ITEM
		end

		if ident then
			g_data.client:setLastTime("sell", true)
			g_data.client:setLastSellItem(self.sell.itemData)

			local makeIndex = self.sell.itemData:get("makeIndex")

			print(" CM_COMMIT_ITEM ", makeIndex)
			net.send({
				ident,
				recog = self.sell.merchant,
				param = Loword(makeIndex),
				tag = Hiword(makeIndex),
				series = sp or 0
			}, {
				self.sell.itemData.getVar("name")
			})
		end
	end
end

function npc:putItem(item, x, y)
	if not self.sellLayer then
		return
	end

	local form = item.formPanel.__cname

	if form == "bag" then
		local rect = self.sellLayer:getBoundingBox()

		rect = cc.rect(rect.x * self:getScale(), rect.y * self:getScale(), rect.width * self:getScale(), rect.height * self:getScale())

		if cc.rectContainsPoint(rect, cc.p(x, y)) then
			self:addSellItem(item)

			return true
		end
	end
end

return npc
