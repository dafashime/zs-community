local npc = import("..panel.npc1")
local dialogue = require("mir2.scenes.main.common.dialogue")
local labelM = require("an.ui.labelM")
local item = import("..common.item")
local textInfo = import("..common.textInfo")
local itemInfo = import("..common.itemInfo")
local extendUI = require("mir2.scenes.main.common.extendUI")
local extendUINew = require("mir2.scenes.main.common.extendUINew")
local callback2 = npc.ctor

npc.mainbg = nil
npc.mainBgh = nil
npc.merchant = nil
npc.extUIParams = {}

table.merge(npc, {
	list = {},
	sell = {},
	bg
})

local function callback3()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

function labelM:addNodeItem(widthCnt, color2)
	local number = 40

	if not self.manualNextLine and self.maxWidth < self.widthCnt + number * widthCnt:getScale() then
		self:nextLine()
	end

	local y2 = self.lines[#self.lines]

	widthCnt:pos(self.widthCnt + color2.offsetX, y2:getPositionY() + 7 + color2.offsetY):add2(self.lines[#self.lines])

	if color2.showText then
		local label = an.newLabel(color2.showText, tonumber(color2.showTextFontSize) or 12, 1, {
			bufferChannel = 0,
			color = _stringToCorlor(color2.showTextColor or 255)
		}):pos(widthCnt:getw() / 2 + color2.showTextX, widthCnt:geth() / 2 + color2.showTextY):add2(widthCnt)
	end

	self.widthCnt = self.widthCnt + number * widthCnt:getScale()
end

function labelM:addCusNode(value, tag2)
	value.tag = tag2.tag

	local y2 = self.lines[#self.lines]

	value:pos(self.widthCnt + tag2.offsetX, y2:getPositionY() + tag2.offsetY):add2(self.lines[#self.lines]):scale(tag2.scale)

	if tag2.showText then
		value:setTouchEnabled(true)
		value:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
			if event.name == "began" then
				value._pos = cc.p(event.x, event.y)

				return true
			elseif event.name == "ended" and cc.pGetDistance(value._pos, event) <= 10 then
				local items2 = {}
				local items = {
					texts = {},
					btns = {}
				}

				if tag2.showText:find("\\") ~= nil then
					items2 = tag2.showText:split("\\")
				else
					items2[1] = tag2.showText
				end

				for _, item2 in ipairs(items2) do
					local items3 = {
						text = item2
					}

					if item2:find(bzmir.mcmd) ~= nil then
						items3.color = _stringToCorlor(item2:split(bzmir.mcmd)[2])
						items3.text = item2:split(bzmir.mcmd)[1]
					end

					items.texts[#items.texts + 1] = items3
				end

				if tag2.showButton.buttonCmds then
					local value2 = tag2.showButton.buttonCmds:split(bzmir.mcmd)

					if value2[1] and value2[2] then
						local items4 = {
							name = value2[1],
							click = function()
								tag2.showButton.click(bzmir.mcmd .. value2[2])
							end
						}

						items.btns[#items.btns + 1] = items4
					end
				end

				textInfo.create(items, {
					x = event.x,
					y = event.y
				}, {
					from = "npc"
				})
			end
		end)
	end
end

function npc:ctor(params)
	local value23 = string.find(params.body, "Helper:1")
	local value24 = string.find(params.body, "Bg")
	local value25 = string.find(params.body, "diyNpc")
	local value28 = string.find(params.body, "HIDETITLE") or def.hideNpcTitle

	self.itemBoxs = {}

	if value28 then
		params.npcName = "NPC"
	end

	if string.find(params.body, "INTFREEITEM") then
		if main_scene.ui.panels.freedeal then
			main_scene.ui.panels.freedeal:intItem(params)
		end

		return
	elseif string.find(params.body, "INTFREENOWSELL") then
		if main_scene.ui.panels.freedeal then
			main_scene.ui.panels.freedeal:intNowSell(params)
		end

		return
	elseif string.find(params.body, "INTFREEREQUST") then
		if main_scene.ui.panels.freedeal then
			main_scene.ui.panels.freedeal:intRequest(params)
		end

		return
	elseif string.find(params.body, "INTFREERECEIVE") then
		if main_scene.ui.panels.freedeal then
			main_scene.ui.panels.freedeal:intReceiveItem(params)
		end

		return
	elseif string.find(params.body, "ISFREEDEAL") then
		main_scene.ui:togglePanel("freedeal", params)

		return
	elseif string.find(params.body, "OPENPANEL") then
		local parts2 = string.split(params.body, ":")

		if parts2[2] then
			main_scene.ui:togglePanel(parts2[2])
		end

		return
	end

	if not value24 and not value23 and not value25 then
		callback2(self, params)

		if callback3() then
			local safeAreaInsets = getSafeAreaInsets()

			self:pos(safeAreaInsets, display.height - 20)
		end

		if def.npcFontSize then
			local children = self:getChildren()

			for _, item5 in ipairs(children) do
				for _2, item3 in ipairs(item5:getChildren()) do
					local name2 = item3:getName()

					if name2 and name2:find("npc_") ~= nil then
						item3:scale(def.npcFontSize / 20)
					end
				end
			end
		end

		self.cc = def.role.createRepeater(function()
			if def.npcFontSize then
				local children2 = self:getChildren()

				for _4, item6 in ipairs(children2) do
					for _5, item4 in ipairs(item6:getChildren()) do
						local name3 = item4:getName()

						if name3 and name3:find("npc_") ~= nil then
							item4:scale(def.npcFontSize / 20)
						end
					end
				end
			end
		end, 0)

		if def.supportNpcMove then
			self._supportMove = true
		end

		return
	end

	if main_scene.ui.panels.freedeal then
		main_scene.ui:hidePanel("freedeal")
	end

	self.merchant = params.merchant
	self._supportMove = true

	if value23 then
		def.role.helperID = self.merchant
	end

	if value25 then
		self:THB_ctor(params)
	elseif value24 then
		self.__cname = "customPanel"

		local enabled2 = false
		local parts3 = string.split(params.body, "|")
		local enabled = false

		for _3, item2 in ipairs(parts3) do
			if def.debug then
				print(item2)
			end

			if item2 == "CUSUI" then
				enabled = true
			else
				local parts = string.split(item2, ":")
				local value2 = parts[1]

				if value2 == "CUSUI" then
					enabled = true
				elseif value2 == "Bg" then
					local value3
					local value7
					local value8
					local value9
					local value4
					local x2
					local y4
					local value16
					local value26

					if enabled then
						local string2 = loadstring("return {" .. parts[2] .. "}")()

						value3 = string2.dir
						value7 = string2.pic
						value8 = string2.anchor or "left"
						value9 = string2.pointWith or 0
						x2 = string2.x or display.cx
						y4 = string2.y or display.cy
						value4 = string2.selfAlign or "center"
						value16 = string2.nomove or 0
						value26 = string2.full
					else
						value3 = parts[2]
						value7 = parts[3]
						value8 = parts[4] or "center"
						value9 = tonumber(parts[5]) or 0
						value4 = parts[8] or "center"
						x2 = tonumber(parts[6]) or display.cx
						y4 = tonumber(parts[7]) or display.cy
						value16 = tonumber(parts[9]) or 0
					end

					local text2 = "pic/bzmir/diynpc/" .. value3 .. "/" .. value7 .. ".png"

					if string.byte(value3) == 35 then
						text2 = value3 .. "/" .. value7 .. ".png"
					end

					local number = 0.5
					local number2 = 0.5

					if value4 == "left" then
						number = 0
						number2 = 0
					elseif value4 == "topleft" then
						number = 0
						number2 = 1
					elseif value4 == "right" then
						number = 1
						number2 = 0
					end

					if value16 == 1 then
						self._supportMove = false
					end

					self.mainbg = _get2(text2)

					local w = self.mainbg:getw()
					local h = self.mainbg:geth()

					if value26 then
						w, h = display.width, display.height
					end

					self:anchor(number, number2):pos(x2, y4):size(cc.size(w, h))
					self:setNodeEventEnabled(true)
					self.mainbg:anchor(0, 0):pos(0, 0):add2(self)

					self.mainBgh = self:geth()

					if enabled then
						self.extUIParams = extendUINew.init(self, "dynpc_ext", self.merchant, value8, value9)
					else
						self.extUIParams = extendUI.init(self, "dynpc_ext", self.merchant, value8, value9)
					end
				elseif value2 == "DBg" then
					local value17
					local value18
					local value5
					local value10
					local value11
					local value6
					local value19
					local x3
					local y5
					local value12
					local height
					local size
					local value27

					if enabled then
						size = loadstring("return {" .. parts[2] .. "}")()
						value17 = size.dir
						value18 = size.pic
						value5 = size.scale or 1
						value10 = size.anchor or "left"
						value11 = size.pointWith or 0
						x3 = size.x or display.cx
						y5 = size.y or display.cy
						value6 = size.selfAlign or "center"
						value19 = size.nomove or 0
						value27 = size.full
					else
						value17 = parts[2]
						value18 = parts[3]
						value5 = tonumber(parts[4])
						value10 = parts[5] or "center"
						value11 = tonumber(parts[6]) or 0
						value6 = parts[9] or "center"
						value19 = tonumber(parts[12]) or 0
						x3 = tonumber(parts[7]) or display.cx
						y5 = tonumber(parts[8]) or display.cy
					end

					local number3 = 0.5
					local number4 = 0.5

					if value6 == "left" then
						number3 = 0
						number4 = 0
					elseif value6 == "topleft" then
						number3 = 0
						number4 = 1
					elseif value6 == "right" then
						number3 = 1
						number4 = 0
					end

					if value19 == 1 then
						self._supportMove = false
					end

					self.mainbg = display.newSprite(res.gettexforCUS(value17, value18))

					if enabled then
						value12 = size.width or self.mainbg:getw()
						height = size.height or self.mainbg:geth()
					else
						value12 = tonumber(parts[10]) or self.mainbg:getw()
						height = tonumber(parts[11]) or self.mainbg:geth()
					end

					if value27 then
						value12, height = display.width, display.height
					end

					self:anchor(number3, number4):pos(x3, y5):size(cc.size(value12 * value5, height * value5))
					self:setNodeEventEnabled(true)
					self.mainbg:scale(value5):anchor(0, 0):pos(0, 0):add2(self)

					self.mainBgh = self:geth()

					if enabled then
						self.extUIParams = extendUINew.init(self, "dynpc_ext", self.merchant, value10, value11)
					else
						self.extUIParams = extendUI.init(self, "dynpc_ext", self.merchant, value10, value11)
					end
				elseif value2 == "DExit" then
					local value13
					local value20
					local value21
					local value22
					local x4
					local y2

					if enabled then
						local string3 = loadstring("return {" .. parts[2] .. "}")()

						value13 = string3.dir
						value20 = string3.pic
						value21 = string3.scale or 1
						x4 = string3.x or self:getw() - 9
						y2 = string3.y or self:geth() - 8
						value22 = string3.pressPic
					else
						value13 = parts[2]
						value20 = parts[3]
						value21 = tonumber(parts[4])
						value22 = parts[5]
						x4 = tonumber(parts[6]) or self:getw() - 9
						y2 = tonumber(parts[7]) or self:geth() - 8
					end

					local count = 0
					local count2 = 0

					if self.extUIParams then
						if self.extUIParams.align == "left" then
							count = 0
							count2 = 0
						elseif self.extUIParams.align == "topleft" then
							count = 0
							count2 = 1
						elseif self.extUIParams.align == "right" then
							count = 1
							count2 = 0
						elseif self.extUIParams.align == "center" then
							count = 0.5
							count2 = 0.5
						end

						if self.extUIParams.pointWith == 0 then
							y2 = self.mainBgh - y2
						end
					end

					an.newBtn(res.gettexforCUS(value13, value20), function()
						sound.playSound("103")
						self:hidePanel()
					end, {
						pressImage = res.gettexforCUS(value13, value22)
					}):anchor(count, count2):pos(x4, y2):addto(self, 9999):scale(value21)
				elseif value2 == "Exit" then
					local value
					local value14
					local value15
					local x5
					local y3

					if enabled then
						local string4 = loadstring("return {" .. parts[2] .. "}")()

						value = string4.dir
						value14 = string4.pic
						value15 = string4.pressPic
						x5 = string4.x or self:getw() - 9
						y3 = string4.y or self:geth() - 8
					else
						value = parts[2]
						value14 = parts[3]
						value15 = parts[4]
						x5 = tonumber(parts[5]) or self:getw() - 9
						y3 = tonumber(parts[6]) or self:geth() - 8
					end

					local text3 = "pic/bzmir/diynpc/" .. value .. "/" .. value14 .. ".png"
					local text4 = "pic/bzmir/diynpc/" .. value .. "/" .. value15 .. ".png"

					if string.byte(value) == 35 then
						text3 = value .. "/" .. value14 .. ".png"
						text4 = value .. "/" .. value15 .. ".png"
					end

					local count3 = 0
					local count4 = 0

					if self.extUIParams then
						if self.extUIParams.align == "left" then
							count3 = 0
							count4 = 0
						elseif self.extUIParams.align == "topleft" then
							count3 = 0
							count4 = 1
						elseif self.extUIParams.align == "right" then
							count3 = 1
							count4 = 0
						elseif self.extUIParams.align == "center" then
							count3 = 0.5
							count4 = 0.5
						end

						if self.extUIParams.pointWith == 0 then
							y3 = self.mainBgh - y3
						end
					end

					an.newBtn(_gettex2(text3), function()
						sound.playSound("103")
						self:hidePanel()
					end, {
						pressImage = _gettex2(text4)
					}):anchor(count3, count4):pos(x5, y3):addto(self, 9999)
				elseif value2 == "Helper" then
					-- block empty
				elseif enabled then
					extendUINew.load(item2, self.extUIParams)
				else
					extendUI.load(item2, self.extUIParams)
				end

				if item2:find("PUTBOX") ~= nil then
					enabled2 = true
				end
			end
		end

		main_scene.ui:hidePanel("storage")

		main_scene.ui.panels.npc = npc

		if enabled2 then
			self:showBag()
		end
	end
end

function npc:refresh(data2)
	local parts = string.split(data2, "|")
	local enabled = false
	local enabled2 = false

	for _, item2 in ipairs(parts) do
		if item2 == "CUSUI" then
			enabled2 = true
		elseif enabled2 then
			extendUINew.load(item2, self.extUIParams)
		else
			extendUI.load(item2, self.extUIParams)
		end

		if item2:find("PUTBOX") ~= nil then
			enabled = true
		end
	end

	if enabled then
		self:showBag()
	end
end

function npc:clickCMD(merchant, cmdstr)
	sound.playSound("105")

	if cmdstr ~= nil then
		local sendstr = cmdstr

		local function send()
			if g_data.client:checkLastTime("npc_cm", 0.1) then
				g_data.client:setLastTime("npc_cm", true)
				print(sendstr)
				net.send({
					CM_MERCHANTDLGSELECT,
					recog = merchant
				}, {
					sendstr
				})
			else
				main_scene.ui:tip("点击过快")
			end
		end

		if string.byte(cmdstr, 1) == string.byte("@", 1) and string.byte(cmdstr, 2) == string.byte("@", 1) then
			if cmdstr == "@@buildguildnow" then
				local msgbox3

				msgbox3 = an.newMsgbox("\n请输入建立这个行会名称.\n", function()
					if msgbox3.input:getString() == "" then
						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox3.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			elseif cmdstr == "@@guildwar" then
				local msgbox4

				msgbox4 = an.newMsgbox("\n请输入建立这个行会名称\n", function()
					if msgbox4.input:getString() == "" then
						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox4.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			elseif string.find(cmdstr, "@@InPutInteger") then
				local msgbox2

				msgbox2 = an.newMsgbox("\n输入信息.\n", function()
					if msgbox2.input:getString() == "" then
						an.newMsgbox("信息不能为空！")

						return
					end

					local num = tonumber(msgbox2.input:getString())

					if not num then
						an.newMsgbox("输入数据中包含了非法符号，请重新输入!")

						return
					end

					if num < 0 or num > 2147483646 then
						an.newMsgbox("输入数字范围必须在0到21亿之间，请重新输入！")

						return
					end

					sendstr = cmdstr .. string.char(13) .. msgbox2.input:getString()

					send()
				end, {
					disableScroll = true,
					input = 20
				})
			elseif string.find(cmdstr, "@@helper") then
				local helper2 = main_scene.ground.helper
				local hCmd = string.sub(cmdstr, 3)
				local cmds = string.split(hCmd, "@")

				if #cmds > 0 then
					local proc = loadstring(cmds[1])

					setfenv(proc, {
						helper = helper2
					})
					proc()
				end

				if cmds[2] then
					if g_data.client:checkLastTime("npc_cm", 0.1) then
						g_data.client:setLastTime("npc_cm", true)
						net.send({
							CM_MERCHANTDLGSELECT,
							recog = merchant
						}, {
							"@" .. cmds[2]
						})
					else
						main_scene.ui:tip("点击过快")
					end
				end
			elseif string.find(cmdstr, "@@openPanel") then
				local parts = string.split(cmdstr, ":")

				if parts[2] then
					main_scene.ui:togglePanel(parts[2])
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

function npc:onCleanup()
	if main_scene.ui.panels.bag and not main_scene.ui.panels.fusion and not main_scene.ui.panels.strengthen then
		main_scene.ui.panels.bag:resetPanelPosition("left")
	end

	self:delSellItem()

	for _, itemBox in pairs(self.itemBoxs) do
		self:delItem(itemBox)
	end

	def.role.stopRepeater(self.cc)
end

function npc:parseContent(content, params)
	local count = 0
	local value3 = content.wordSize.height

	if def.npcFontSize then
		content:setFSize(def.npcFontSize)
	end

	if def.npcOFFSETH then
		count = def.npcOFFSETH
		content.wordSize.height = value3 + count
	end

	local function callback3(v)
		while true do
			local pos1 = string.find(v, "<")
			local value4 = string.find(v, ">")

			if pos1 and value4 then
				content:addLabel(string.sub(v, 1, pos1 - 1))

				local text3 = string.sub(v, pos1 + 1, value4 - 1)

				if string.upper(text3) ~= "C" and string.upper(text3) ~= "/C" then
					local text4 = ""
					local text2
					local color2
					local value5 = string.find(text3, "/")

					if value5 then
						text4 = string.sub(text3, 1, value5 - 1)
						text2 = string.sub(text3, value5 + 1, #text3)

						local value6 = string.find(text2, "=")

						if value6 then
							color2 = string.sub(text2, value6 + 1, #text2)
							text2 = string.sub(text2, 1, value6 - 1)

							if color2 == "red" then
								color2 = 249
							end
						end
					else
						text4 = text3
					end

					if text2 and string.upper(text2) == "OFFSETH" then
						count = tonumber(color2)
						content.wordSize.height = value3 + count
					elseif text2 and string.upper(text2) == "FONTSIZE" then
						content:setFSize(tonumber(color2))

						value3 = content.wordSize.height

						if count > 0 then
							content.wordSize.height = value3 + count
						end
					elseif text2 and string.upper(text2) == "WIDTH" then
						content.maxWidth = tonumber(color2)
					elseif text2 and string.upper(text2) == "ITEM" then
						local number8 = color2:split(":")
						local item3
						local value11
						local number2 = tonumber(number8[1])

						if number2 and number2 > 0 then
							local item4

							item4, item3 = g_data.bag:getItem(number2)
						else
							item3 = def.items.getItemByName(number8[1], 3, 3)
						end

						if item3 then
							content:addNodeItem(item.new(item3, self, {
								showbg = true,
								showEffect = true
							}), {
								offsetX = tonumber(number8[2]) or 0,
								offsetY = tonumber(number8[3]) or 0,
								showText = number8[4],
								showTextX = tonumber(number8[5]) or 0,
								showTextY = tonumber(number8[6]) or 0,
								showTextFontSize = number8[7],
								showTextColor = number8[8]
							})
						end
					elseif text2 and string.upper(text2) == "DIMG" then
						local number9 = color2:split(":")

						if number9[1] and number9[2] then
							local node2 = display.newNode()

							display.newSprite(res.gettexforCUS(number9[1], number9[2])):add2(node2)
							content:addCusNode(node2, {
								offsetX = tonumber(number9[4]) or 0,
								offsetY = tonumber(number9[5]) or 0,
								scale = tonumber(number9[3]) or 1,
								showText = number9[6],
								showButton = {
									buttonCmds = number9[7],
									click = function(value9)
										sound.playSound("103")
										self:clickCMD(params.merchant, value9)
									end
								}
							})
						end
					elseif text2 and string.upper(text2) == "DSPR" then
						local number7 = color2:split(":")

						if number7[1] and number7[2] and number7[3] then
							local node = display.newNode()
							local number10 = number7[4]:split("@")
							local number4 = tonumber(number10[1]) or 0.1
							local number3
							local enabled = true

							if number10[2] then
								number3 = tonumber(number10[2])
							end

							if number10[3] and number10[3] == "1" then
								enabled = false
							end

							local number
							local value

							if number3 then
								number = m2spr.new(number7[1], tonumber(number7[2]), {
									setOffset = true
								})
								value = number.spr

								value:add2(node):runs({
									cc.DelayTime:create(number3),
									cc.CallFunc:create(function()
										if enabled then
											if value then
												value:removeSelf()

												value = nil
												number = nil
											end
										else
											number:stopAnimation()
										end
									end)
								})
								number:playAni(number7[1], tonumber(number7[2]), tonumber(number7[3]), number4, false)
							else
								m2spr.playAnimation(number7[1], tonumber(number7[2]), tonumber(number7[3]), number4, false):add2(node)
							end

							content:addCusNode(node, {
								offsetX = tonumber(number7[6]) or 0,
								offsetY = tonumber(number7[7]) or 0,
								scale = tonumber(number7[5]) or 1,
								showText = number7[8],
								showButton = {
									buttonCmds = number7[9],
									click = function(value10)
										sound.playSound("103")
										self:clickCMD(params.merchant, value10)
									end
								}
							})
						end
					elseif text2 and string.upper(text2) == "DBTN" then
						local color3 = color2:split(":")

						if color3[1] and color3[2] then
							local items = {}
							local value7 = color3[2]:split(bzmir.mcmd)
							local value2

							if color3[6] then
								value2 = color3[6]:split(bzmir.mcmd)
							end

							local texforCUS = res.gettexforCUS(color3[1], value7[1])

							if value2 then
								items.label = {
									value2[1],
									tonumber(color3[7]) or 18,
									1,
									{
										color = _stringToCorlor(color3[8]) or display.COLOR_WHITE
									}
								}
							end

							if value7[2] then
								items.pressImage = res.gettexforCUS(color3[1], value7[2])
							else
								items.pressBig = true
							end

							content:addCusNode(an.newBtn(texforCUS, function()
								sound.playSound("103")

								if value2 then
									self:clickCMD(params.merchant, bzmir.mcmd .. value2[2])
								end
							end, items), {
								offsetX = color3[4] and tonumber(color3[4]) or nil,
								offsetY = color3[5] and tonumber(color3[5]) or nil,
								scale = color3[3] and tonumber(color3[3]) or 1
							})
						end
					elseif text2 and string.upper(text2) == "C9Sprite" then
						local frameName = color2:split(":")
						local number5 = tonumber(frameName[2]) or 0
						local number6 = tonumber(frameName[3]) or 0
						local background = display.newScale9Sprite(res.getframe2(frameName[1])):size(number5, number6)

						if background then
							content:addCusNode(background, {
								offsetX = tonumber(frameName[4]),
								offsetY = tonumber(frameName[5])
							})
						end
					else
						local value8 = color2 and _stringToCorlor(color2) or text2 ~= nil and def.colors.clYellow or def.colors.clRed
						local items2

						if text2 then
							if string.upper(text2) == "SCOLOR" then
								items2 = {
									ani = true,
									easyTouch = true,
									addTouchSizeY = 12,
									callback = function()
										return
									end
								}
							elseif text2:find("@") ~= nil then
								items2 = {
									ani = true,
									easyTouch = true,
									addTouchSizeY = 12,
									callback = function()
										self:clickCMD(params.merchant, text2)
									end
								}
							end
						end

						content:addLabel(text4, value8, nil, nil, items2):setName(text4)
					end
				end

				v = string.sub(v, value4 + 1, string.len(v))
			else
				content:addLabel(v)

				break
			end
		end
	end

	params.body = string.gsub(params.body, "\\", "")

	local parts2 = string.split(params.body, "|")

	for _, line in ipairs(parts2) do
		local parts = string.split(line, "^")
		local space = content:getw() / #parts

		for i, item2 in ipairs(parts) do
			if i > 1 then
				content:setCurLineWidthCnt((i - 1) * space)
			end

			callback3(item2)
		end

		content:nextLine()
	end
end

function npc:parseCcmd(content, params)
	if def.npcFontSize then
		content:setFSize(def.npcFontSize)
	end

	local function parseCMD(v, cmdList)
		local tmdCmd = {}

		while true do
			local value3 = string.find(v, "<")
			local value = string.find(v, ">")

			if value3 and value then
				local text2 = string.sub(v, value3 + 1, value - 1)

				if string.upper(text2) ~= "C" and string.upper(text2) ~= "/C" then
					local title2 = ""
					local cmdstr
					local value5
					local value2 = string.find(text2, "/")

					if value2 then
						title2 = string.sub(text2, 1, value2 - 1)
						cmdstr = string.sub(text2, value2 + 1, #text2)

						local value4 = string.find(cmdstr, "=")

						if value4 then
							cmdstr = string.sub(cmdstr, 1, value4 - 1)
						end
					else
						title2 = text2
					end

					if string.upper(title2) == "FONTSIZE" then
						content:setFSize(tonumber(cmdstr))
					elseif cmdstr and string.upper(cmdstr) ~= "FCOLOR" then
						tmdCmd[#tmdCmd + 1] = {
							title = title2,
							cmd = cmdstr
						}
					end
				end

				v = string.sub(v, value + 1, string.len(v))
			else
				break
			end
		end

		cmdList[#cmdList + 1] = tmdCmd
	end

	local items = {}

	params.body = string.gsub(params.body, "\\", "")
	params.body = string.gsub(params.body, "{cmd}", "")
	params.body = string.gsub(params.body, "^", "")

	local parts = string.split(params.body, "|")

	for _, item2 in ipairs(parts) do
		parseCMD(item2, items)
	end

	return items
end

function npc:delSellItem()
	if self.sell.item then
		self.sell.item:removeSelf()

		self.sell.item = nil
	end

	if self.sell.itemData then
		g_data.bag:addItem(self.sell.itemData, true)

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:addItem(self.sell.itemData:get("makeIndex"))
		end

		self.sell.itemData = nil
	end

	self:setSellText()
end

function npc:clickSellOk(sp)
	if self.sell.itemData and (not g_data.client.lastTime.sell or socket.gettime() - g_data.client.lastTime.sell > 5) then
		local value

		if self.sell.type == "repair" then
			value = CM_USERREPAIRITEM
		elseif self.sell.type == "sell" then
			value = CM_USERSELLITEM
		elseif self.sell.type == "storage" then
			value = CM_USERSTORAGEITEM
		elseif self.sell.type == "playDrink" then
			value = CM_USERPLAYDRINKITEM
		elseif self.sell.type == "exchange" then
			value = CM_COMMIT_ITEM
		end

		if value then
			g_data.client:setLastTime("sell", true)
			g_data.client:setLastSellItem(self.sell.itemData)

			local makeIndex = self.sell.itemData:get("makeIndex")

			net.send({
				value,
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

function npc:putItem(item2, x2, y2)
	if item2.formPanel.__cname == "bag" then
		if self.sellLayer then
			local rect = self.sellLayer:getBoundingBox()
			local rect2 = cc.rect(rect.x * self:getScale(), rect.y * self:getScale(), rect.width * self:getScale(), rect.height * self:getScale())

			if cc.rectContainsPoint(rect2, cc.p(x2, y2)) then
				self:addSellItem(item2)

				return true
			end
		elseif putitem then
			return putitem(self, item2, x2, y2)
		end
	end
end

function npc:addSellItem(bagItem)
	self:delSellItem()

	local data2 = bagItem.data

	g_data.bag:delItem(data2:get("makeIndex"))

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data2:get("makeIndex"))
	end

	self.sell.itemData = data2
	self.sell.item = item.new(data2, self, {
		showbg = false,
		showEffect = true
	}):pos(77, 102):scale(1.2):add2(self.sellLayer)

	if self.sell.type == "repair" then
		local value = data2:get("makeIndex")

		net.send({
			CM_MERCHANTQUERYREPAIRCOST,
			recog = self.sell.merchant,
			param = Loword(value),
			tag = Hiword(value)
		}, {
			data2.getVar("name")
		})
	elseif self.sell.type == "sell" then
		local value2 = data2:get("makeIndex")

		net.send({
			CM_MERCHANTQUERYSELLPRICE,
			recog = self.sell.merchant,
			param = Loword(value2),
			tag = Hiword(value2)
		}, {
			data2.getVar("name")
		})
	end
end

function npc:addItem(item2, boxLayer)
	self:delItem(boxLayer)

	local itemData = item2.data

	g_data.bag:delItem(itemData:get("makeIndex"))

	g_data.bag.inBox[itemData:get("makeIndex")] = true

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(itemData:get("makeIndex"))
	end

	boxLayer.itemData = itemData
	boxLayer.item = item.new(itemData, self, {
		showbg = false,
		showEffect = true
	}):pos(boxLayer:getw() / 2, boxLayer:geth() / 2):anchor(0.5, 0.5):scale(1.2):add2(boxLayer)
	boxLayer.item.boxLayer = boxLayer

	local value = itemData:get("makeIndex")

	net.send({
		CM_COMMIT_ITEM,
		series = 1,
		recog = self.merchant,
		param = Loword(value),
		tag = Hiword(value)
	}, {
		itemData.getVar("name")
	})

	if boxLayer.putItemCmd then
		local itemDiff = def.ccy.getItemDiff(itemData)

		def.role.sendCM("@" .. boxLayer.putItemCmd .. "~" .. itemData.getVar("name") .. "~" .. tostring(itemData:get("makeIndex")) .. "~" .. itemDiff)
	end
end

function npc:delItem(makeIndex)
	if makeIndex.item then
		makeIndex.item:removeSelf()

		makeIndex.item = nil
	end

	if makeIndex.itemData then
		g_data.bag:addItem(makeIndex.itemData, true)

		g_data.bag.inBox[makeIndex.itemData:get("makeIndex")] = false

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:addItem(makeIndex.itemData:get("makeIndex"))
		end

		makeIndex.itemData = nil
	end
end

function npc:showBag(data2, options)
	if not data2 then
		data2, options = display.cx + 100, display.cy

		if self.extUIParams then
			if self.extUIParams.align == "left" then
				data2 = self:getw() + self:getPositionX() + 10
				options = self:getPositionY() * 2
			elseif self.extUIParams.align == "topleft" then
				data2 = self:getw() + self:getPositionX() + 10
				options = self:getPositionY()
			elseif self.extUIParams.align == "right" then
				data2 = self:getPositionX() + 10
				options = self:getPositionY() * 2
			else
				data2 = self:getPositionX() + self:getw() / 2 + 10
				options = self:getPositionY() + self:geth() / 2
			end
		end
	end

	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:pos(data2, options)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(data2, options)
		end
	end
end

function npc:initItems(selectIdx)
	if self.list.layer then
		self.list.layer:removeSelf()
	end

	self.list.layer = display.newNode():add2(self.listLayer)
	self.list.selectIdx = nil

	local items = {}

	local function clickItem(item3)
		for i3, v in ipairs(items) do
			if v.node == item3.node then
				v.name:setColor(display.COLOR_RED)

				if v.text1 then
					v.text1:setColor(display.COLOR_RED)
				end

				if v.text2 then
					v.text2:setColor(display.COLOR_RED)
				end

				self.list.selectIdx = item3.idx

				local p = item3.node:convertToWorldSpace(cc.p(item3.node:getw() - 30, item3.node:geth()))

				if self.list.type == "goods" or self.list.type == "synthesis" then
					itemInfo.show(item3.data.s, p, {
						onlyStdItem = true
					})
				else
					itemInfo.show(item3.data, p, {
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

		local data2 = self.list.datas[i]
		local name2
		local text1
		local text2
		local looks

		if self.list.type == "goods" then
			name2 = data2.name
			text1 = data2.price .. " 金币"
			looks = data2.s:get("looks")
		elseif self.list.type == "goods_detail" then
			name2 = data2.getVar("name")
			text1 = Word(data2:get("duraMax")) .. " 金币"
			text2 = "持久: " .. math.modf(Word(data2:get("dura")) / 1000)
			looks = data2.getVar("looks")
		elseif self.list.type == "synthesis" then
			name2 = data2.name
			text1 = data2.price .. " 金币"
			looks = data2.s:get("looks")
		else
			name2 = data2.getVar("name")
			text1 = "持久: " .. math.modf(Word(data2:get("dura")) / 1000) .. "/" .. math.modf(Word(data2:get("duraMax")) / 1000)
			looks = data2.getVar("looks")
		end

		local item2 = {
			idx = i,
			data = data2
		}

		item2.node = display.newNode():size(168, 54):add2(self.list.layer):pos(16 + ((i - begin + 1) % 2 == 0 and 167 or -3), 283 - math.modf((i - begin) / 2) * 54):enableClick(function()
			sound.playSound("105")
			clickItem(item2)
		end)

		if looks then
			res.get("items", looks):pos(23, 25):addto(item2.node)
		end

		if name2 then
			item2.name = an.newLabel(name2, 16, 1):pos(52, 32):add2(item2.node)
		end

		if text1 then
			item2.text1 = an.newLabel(text1, 16, 1):pos(52, text2 and 18 or 8):add2(item2.node)
		end

		if text2 then
			item2.text2 = an.newLabel(text2, 16, 1):pos(52, text1 and 3 or 8):add2(item2.node)
		end

		items[#items + 1] = item2
	end

	self.pageLabel:setString(string.format("%d/%d", self.list.page, math.ceil(#self.list.datas / 10)))

	if selectIdx then
		local finded = false

		for i2, v2 in ipairs(items) do
			if v2.idx == selectIdx then
				finded = true

				clickItem(v2)

				break
			end
		end

		if not finded and #items > 0 then
			clickItem(items[#items])
		end
	end
end

function npc:THB_ctor(body)
	local text2 = body.body

	function getAnchor(self2)
		if type(self2) ~= "string" then
			return 0.5, 0.5
		end

		if self2 == "leftTop" then
			return 0, 1
		elseif self2 == "rightTop" then
			return 1, 1
		elseif self2 == "leftBottom" then
			return 0, 0
		elseif self2 == "rightBottom" then
			return 1, 0
		elseif self2 == "center" then
			return 0.5, 0.5
		end

		return 0, 0
	end

	local node = display.newNode():pos(display.width / 2, display.height / 2):anchor(0.5, 0.5):addTo(self)
	local items = {}
	local node2 = res.get2("pic/panels/npc/bg_sales_03.png"):addTo(node):enableClick(function()
		if items.bg then
			items.bg:setVisible(false)

			items.show = false
		end
	end)

	self.scroll = {}

	node2:setTouchEnabled(true)

	items.bg = display.newScale9Sprite(res.getframe2("pic/console/common/tipBG.png"), 0, 0, cc.size(0, 0)):add2(node2, 99):anchor(0, 0)
	items.layer = display.newColorLayer(cc.c4b(100, 100, 100, 100)):add2(items.bg):size(0, 0)

	items.bg:setVisible(false)

	items.labelM = an.newLabelM(150, 18, 1):add2(items.layer):pos(8, 8)
	items.show = false

	local value_2 = res.get2("pic/common/close10.png"):anchor(0, 1):pos(node2:getw(), node2:geth()):addto(node2):enableClick(function()
		sound.playSound("103")
		self:hidePanel()
	end)
	local parts2 = string.split(text2, "|")

	for _, item2 in ipairs(parts2) do
		if string.find(item2, "design:") then
			dialogue.design(node2)
		end

		if string.find(item2, "bg:") then
			local parts3 = string.split(item2, "bg:")[2]
			local string2 = loadstring("return {" .. parts3 .. "}")()

			node2:setTex(res.gettex2("pic/" .. string2.dir .. "/" .. string2.image .. ".png"))
			node2:setAnchorPoint(getAnchor(string2.anchor))

			if string2.posx then
				node2:setPositionX(string2.posx)
			end

			if string2.posy then
				node2:setPositionY(string2.posy)
			end

			if string2.scale then
				node2:scale(string2.scale)
			end

			value_2:setPositionX(node2:getw())
			value_2:setPositionY(node2:geth())
		end

		if string.find(item2, "cls:") then
			local parts = loadstring("return {" .. string.split(item2, "cls:")[2] .. "}")()

			if parts.image and parts.dir then
				value_2:setTex(res.gettex2("pic/" .. parts.dir .. "/" .. parts.image .. ".png"))
			end

			if parts.posx then
				value_2:setPositionX(parts.posx)
			end

			if parts.posy then
				value_2:setPositionY(parts.posy)
			end

			if parts.scale then
				value_2:scale(parts.scale)
			end
		end

		if string.find(item2, "slider:") then
			dialogue.createSprite(self, node2, string.split(item2, "slider:")[2], "slider", body, items)
		end

		if string.find(item2, "items:") then
			dialogue.createSprite(self, node2, string.split(item2, "items:")[2], "items", body, items)
		end

		if string.find(item2, "label:") then
			dialogue.createSprite(self, node2, string.split(item2, "label:")[2], "label", body, items)
		end

		if string.find(item2, "text:") then
			dialogue.createSprite(self, node2, string.split(item2, "text:")[2], "text", body, items)
		end

		if string.find(item2, "btn:") then
			dialogue.createSprite(self, node2, string.split(item2, "btn:")[2], "btn", body, items)
		end

		if string.find(item2, "image:") then
			dialogue.createSprite(self, node2, string.split(item2, "image:")[2], "image", body, items)
		end

		if string.find(item2, "spr:") then
			dialogue.createSprite(self, node2, string.split(item2, "spr:")[2], "spr", body, items)
		end

		if string.find(item2, "ani:") then
			dialogue.createSprite(self, node2, string.split(item2, "ani:")[2], "ani", body, items)
		end

		if string.find(item2, "sprAni:") then
			dialogue.createSprite(self, node2, string.split(item2, "sprAni:")[2], "sprAni", body, items)
		end

		body.body = string.gsub(body.body, item2 .. "|", "", 1)
	end

	self:size(cc.size(node2:getw(), node2:geth()))

	self.list = {}
	self.sell = {}

	main_scene.ui:hidePanel("storage")
end

return npc
