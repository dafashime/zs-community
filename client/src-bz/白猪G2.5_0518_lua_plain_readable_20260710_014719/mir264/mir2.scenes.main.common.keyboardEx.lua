local common = import(".common")
local itemInfo = import(".itemInfo")
local rightBtnW = 45
local edge = 15
local minh = 200
local keyboardEx = class("keyboardEx", function()
	return display.newNode()
end)

table.merge(keyboardEx, {
	input,
	bar,
	content
})

function keyboardEx.create(input)
	if main_scene.keyboardEx then
		return main_scene.keyboardEx
	end

	main_scene.keyboardEx = keyboardEx.new(input):anchor(0, 1):add2(main_scene, an.z.inputtool)

	return main_scene.keyboardEx
end

function keyboardEx.destory()
	if main_scene.keyboardEx then
		main_scene.keyboardEx:removeSelf()

		main_scene.keyboardEx = nil
	end
end

function keyboardEx:ctor(input)
	local bg = res.get2("pic/keyboard/bar.png"):anchor(0, 0):scalex(display.width / 960):add2(self):enableClick(function()
		return
	end)

	self:size(display.width, bg:geth())

	self.input = input

	self:loadMain()
end

function keyboardEx:addRightBtns()
	an.newBtn(res.gettex2("pic/keyboard/btn11.png"), function()
		self.input:callback({
			text = "\n",
			type = "insertText"
		})
	end, {
		pressImage = res.gettex2("pic/keyboard/btn22.png"),
		scale9 = cc.size(rightBtnW, self.content:geth() / 2 - edge),
		sprite = res.gettex2("pic/keyboard/send.png")
	}):add2(self.content):anchor(1, 1):pos(self.content:getw() - edge, self.content:geth() / 2)
	an.newBtn(res.gettex2("pic/keyboard/btn11.png"), function()
		self.input:callback({
			type = "deleteBackward"
		})
	end, {
		pressImage = res.gettex2("pic/keyboard/btn22.png"),
		scale9 = cc.size(rightBtnW, self.content:geth() / 2 - edge),
		sprite = res.gettex2("pic/keyboard/delete.png")
	}):add2(self.content):anchor(1, 0):pos(self.content:getw() - edge, self.content:geth() / 2)
end

function keyboardEx:loadMain()
	if self.bar then
		self.bar:removeSelf()
	end

	self.bar = display.newNode():size(self:getContentSize()):add2(self)

	local btnw = 83
	local configs = {
		{
			"key",
			btnw / 2 + 0 * btnw,
			self:geth() / 2,
			function()
				self.input:setKeyboardVisable(true)

				if self.content then
					self.content:removeSelf()

					self.content = nil
				end
			end
		},
		{
			"face",
			btnw / 2 + 1 * btnw,
			self:geth() / 2,
			function()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					type = "keyboardWillShow",
					duration = 0.3,
					eh = self:loadFace()
				})
			end
		},
		{
			"cmd",
			btnw / 2 + 2 * btnw,
			self:geth() / 2,
			function()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					type = "keyboardWillShow",
					duration = 0.3,
					eh = self:loadCMD()
				})
			end
		},
		{
			"bag",
			btnw / 2 + 3 * btnw,
			self:geth() / 2,
			function()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					type = "keyboardWillShow",
					duration = 0.3,
					eh = self:loadBag()
				})
			end
		},
		{
			"equip",
			btnw / 2 + 4 * btnw,
			self:geth() / 2,
			function()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					type = "keyboardWillShow",
					duration = 0.3,
					eh = self:loadEquip()
				})
			end
		},
		{
			"pos",
			btnw / 2 + 5 * btnw,
			self:geth() / 2,
			function()
				local text = string.format("[%s:%s,%s]", g_data.map.mapTitle, main_scene.ground.player.x, main_scene.ground.player.y)

				self.input:addLabel(text, cc.c3b(0, 0, 255), display.COLOR_WHITE, common.encodeRich({
					type = "pos",
					mapID = main_scene.ground.map.mapid,
					mapTitle = g_data.map.mapTitle,
					x = main_scene.ground.player.x,
					y = main_scene.ground.player.y
				}))
			end,
			true
		},
		{
			"screen",
			btnw / 2 + 6 * btnw,
			self:geth() / 2,
			function()
				self.input:stopInput()

				local ok, msg = pic.canScreenshot()

				if g_data.chat.style.channel == "私聊" and g_data.chat.style.target == "" then
					an.newMsgbox("未设置对方名字.", nil, {
						center = true
					})
				elseif not ok then
					main_scene.ui:tip(msg)
				else
					main_scene.ui:hidePanel("screenshot")
					main_scene.ui:showPanel("screenshot")
				end
			end,
			true
		},
		{
			"voice2text",
			btnw / 2 + 7 * btnw,
			self:geth() / 2,
			function()
				return
			end
		}
	}
	local btns = {}

	local function setSelected(key)
		for k, v in pairs(btns) do
			v:setIsSelect(k == key)
		end
	end

	for i, v in ipairs(configs) do
		local key, x, y, func, isOnce = unpack(v)
		local callback = an.newBtn
		local tex2 = res.gettex2("pic/keyboard/btn1.png")

		local function cleanup()
			if not isOnce then
				setSelected(key)
			end

			func()
		end

		local items = {
			pressImage = isOnce and res.gettex2("pic/keyboard/btn2.png")
		}
		local select

		select = not isOnce and {
			res.gettex2("pic/keyboard/btn2.png"),
			manual = true
		}
		items.select = select
		items.sprite = res.gettex2("pic/keyboard/" .. key .. ".png")
		btns[key] = callback(tex2, cleanup, items):pos(x, y):add2(self.bar)
	end

	setSelected("key")
end

function keyboardEx:loadFace()
	if self.content then
		self.content:removeSelf()
	end

	local emojiCount = 79
	local space = 55
	local lineMax = math.modf((display.width - rightBtnW - edge) / space)
	local lineCnt = math.ceil(emojiCount / lineMax)
	local h = math.max(minh, lineCnt * space + edge * 2)

	self.content = display.newNode():size(self:getw(), h):anchor(0, 1):add2(self):enableClick(function()
		return
	end)

	display.newScale9Sprite(res.getframe2("pic/keyboard/bg.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)
	self:addRightBtns()

	for i = 1, emojiCount do
		local col = (i - 1) % lineMax
		local line = math.modf((i - 1) / lineMax)
		local tex = res.gettex2("pic/emoji/" .. i .. ".png")
		local btn = an.newBtn(tex, function()
			self.input:addEmoji(tex, common.encodeRich({
				type = "emoji",
				id = i
			}))
		end, {
			pressBig = true,
			size = {
				space,
				space
			}
		}):pos(edge + col * space + space / 2, self.content:geth() - edge - line * space - space / 2):add2(self.content)
	end

	return h
end

function keyboardEx:loadCMD()
	if self.content then
		self.content:removeSelf()
	end

	local h = minh

	self.content = display.newNode():size(self:getw(), h):anchor(0, 1):add2(self):enableClick(function()
		return
	end)

	display.newScale9Sprite(res.getframe2("pic/keyboard/bg.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)
	self:addRightBtns()

	for i, v in ipairs(def.cmds.all) do
		local col = math.modf((i - 1) / 2)
		local line = (i - 1) % 2
		local addSpace = (display.width - 960) / math.modf(#def.cmds.all / 2)
		local pos = cc.p(35 + col * (190 + addSpace), h - 60 - line * 39)
		local color = cc.c3b(255, 255, 0)
		local label = an.newLabel(v[1], 18, 1, {
			color = color
		}):pos(pos.x, pos.y):addUnderline(color):add2(self.content)

		label:enableClick(function()
			self.input:callback({
				type = "insertText",
				text = v[2] .. " "
			})
		end, {
			ani = true,
			size = cc.size(label:getw(), 39)
		})
	end

	return h
end

function keyboardEx:loadItems(datas, emptyTip)
	if self.content then
		self.content:removeSelf()
	end

	local itemCount = table.nums(datas)
	local space = 60
	local lineMax = math.modf((display.width - rightBtnW - edge) / space)
	local lineCnt = math.ceil(itemCount / lineMax)
	local h = minh

	if itemCount > 0 then
		h = math.max(h, lineCnt * space + edge * 2 + 50)
	end

	local items = {}

	local function click(data, pos)
		for i, v in ipairs(items) do
			if data == v.data then
				v.bg:setTex(res.gettex2("pic/chatEx/item_bg2.png"))
			else
				v.bg:setTex(res.gettex2("pic/chatEx/item_bg.png"))
			end
		end

		if data and pos then
			local p = cc.p(pos.x, pos.y)

			local function callback()
				local text = string.format("[%s]", data.getVar("name"))

				self.input:addLabel(text, cc.c3b(0, 0, 255), display.COLOR_WHITE, common.encodeRich({
					type = "item",
					makeIndex = data:get("makeIndex"),
					name = data.getVar("name"),
					lookID = data.getVar("looks"),
					weight = data.getVar("weight")
				}))
			end

			itemInfo.show(data, p, {
				parent = display.getRunningScene(),
				z = an.z.max + 1,
				miny = -h,
				itemLink = callback
			})
		end
	end

	self.content = display.newNode():size(self:getw(), h):anchor(0, 1):add2(self):enableClick(function()
		click()
	end)

	display.newScale9Sprite(res.getframe2("pic/keyboard/bg.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)
	self:addRightBtns()

	if itemCount > 0 then
		local cnt = 1

		local function add(data)
			local col = (cnt - 1) % lineMax
			local line = math.modf((cnt - 1) / lineMax)
			local pos = cc.p(edge + space / 2 + col * space, self.content:geth() - edge - space / 2 - line * space)
			local item = {
				data = data
			}

			item.bg = res.get2("pic/chatEx/item_bg.png"):pos(pos.x, pos.y):add2(self.content):enableClick(function()
				click(data, pos)
			end, {
				size = cc.size(space, space)
			})

			res.get("items", data.getVar("looks")):pos(pos.x, pos.y):add2(self.content)

			items[#items + 1] = item
			cnt = cnt + 1
		end

		for k, v in pairs(datas) do
			add(v)
		end
	else
		an.newLabel(emptyTip, 24, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(self.content:centerPos()):add2(self.content)
	end

	return h
end

function keyboardEx:loadBag()
	return self:loadItems(g_data.bag.items, "当前背包暂无物品可以分享.")
end

function keyboardEx:loadEquip()
	return self:loadItems(g_data.equip.items, "当前装备暂无物品可以分享.")
end

return keyboardEx
