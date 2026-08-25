local items = {}
local value23

function items.initFilt()
	local stringFromFile

	if DEBUG > 0 then
		local instance = cc.FileUtils:getInstance()

		if instance.isFileExist(instance, "wupin.txt") then
			p2("debug", "使用了未打包的道具表")

			stringFromFile = instance.getStringFromFile(instance, "wupin.txt")
		else
			stringFromFile = res.getfile("config/wupin.txt")
		end
	else
		stringFromFile = res.getfile("config/wupin.txt")
	end

	local parts = string.split(stringFromFile, "\n")

	local function callback3(self)
		local parts2 = string.split(self, ",")

		return {
			allowFlag = tonumber(parts2[2]) or 0,
			name = parts2[3] or "",
			stdMode = tonumber(parts2[4]) or 0,
			shape = tonumber(parts2[5]),
			source = tonumber(parts2[6]) or 0,
			outlook = tonumber(parts2[7]),
			looks = tonumber(parts2[8]) or 0,
			weight = tonumber(parts2[9]) or 0,
			duraMax = tonumber(parts2[10]) or 0,
			aniCount = tonumber(parts2[11]) or 0,
			needConf = tonumber(parts2[12]) or 0,
			AC = tonumber(parts2[13]) or 0,
			maxAC = tonumber(parts2[14]) or 0,
			MAC = tonumber(parts2[15]) or 0,
			maxMAC = tonumber(parts2[16]) or 0,
			DC = tonumber(parts2[17]) or 0,
			maxDC = tonumber(parts2[18]) or 0,
			MC = tonumber(parts2[19]) or 0,
			maxMC = tonumber(parts2[20]) or 0,
			SC = tonumber(parts2[21]) or 0,
			maxSC = tonumber(parts2[22]) or 0,
			CC = tonumber(parts2[23]) or 0,
			maxCC = tonumber(parts2[24]) or 0,
			need = tonumber(parts2[25]) or 0,
			needLevel = tonumber(parts2[26]) or 0,
			antiqueLv = tonumber(parts2[27]) or 0,
			wParam1 = tonumber(parts2[28]) or 0,
			wParam2 = tonumber(parts2[29]) or 0,
			intParam = tonumber(parts2[30]) or 0,
			itemScore = tonumber(parts2[31]) or 0,
			price = tonumber(parts2[32]) or 0,
			itemType1 = tonumber(parts2[33]) or 0,
			itemType2 = tonumber(parts2[34]) or 0,
			itemType3 = tonumber(parts2[35]) or 0,
			itemLevel = tonumber(parts2[36]) or 0,
			suitEquipType = tonumber(parts2[37]) or 0,
			intparam2 = tonumber(parts2[38]) or 0,
			intparam3 = tonumber(parts2[39]) or 0,
			maxSteelLv = tonumber(parts2[40]) or 0,
			maxVeinsLv = tonumber(parts2[41]) or 0,
			baseEffectID = tonumber(parts2[42]) or 0,
			itemExtAbil = parts2[43],
			needJob = tonumber(parts2[44]) or 7,
			ItemConf = tonumber(parts2[45]) or 0,
			get = function(value, value29)
				return value[value29]
			end,
			getVar = function(value)
				return record:get(value)
			end
		}, tonumber(parts2[1])
	end

	local name2Index = {}

	for _, item in ipairs(parts) do
		if item ~= "" then
			local nameOwner, value = callback3(item)

			items[value] = nameOwner
			name2Index[nameOwner.name] = value
		end
	end

	items.name2Index = name2Index
	items.defaultItem = callback3(",,未知物品")

	local file = res.getfile("config/itemdesc.txt")
	local parts2 = string.split(file, "\n")

	items.desc = {}

	for _2, item2 in ipairs(parts2) do
		if item2 ~= "" then
			local parts3 = string.split(item2, "=")

			items.desc[parts3[1]] = parts3[2]
		end
	end
end

function items.initFilt()
	local text = "config/itemFilt180.txt"

	if def.gameVersionType == "176" then
		text = "config/itemFilt176.txt"
	elseif def.gameVersionType == "185" then
		text = "config/itemFilt185.txt"
	end

	local file = res.getfile(text)
	local parts = string.split(file, "\n")

	items.filt = {}

	local items18 = {}

	for _, item in ipairs(parts) do
		if item ~= "" then
			local parts2 = string.split(item, ",")

			items.filt[parts2[1]] = {
				category = parts2[2],
				pickOnRatting = string.find(parts2[3], "1") ~= nil,
				pickUp = string.find(parts2[4], "1") ~= nil,
				hintName = string.find(parts2[5], "1") ~= nil,
				isGood = string.find(parts2[6], "1") ~= nil
			}
			items18[parts2[2]] = true
		end
	end

	items.category = {}

	for itemId, _2 in pairs(items18) do
		table.insert(items.category, itemId)
	end
end

function items.getItemByName(self)
	if items.name2Index then
		local value = items.name2Index[self]

		if value and value <= #items then
			return items[value]
		else
			return nil
		end
	end
end

function items.getItemById(self)
	if self and self <= #items then
		return items[self]
	else
		return nil
	end
end

function items.getStdItemById(self)
	return items.setStdItemData(items.getItemById(self), self)
end

function items.setStdItemData(self, FIndex)
	local items18 = {
		FItemIdent = 1,
		FIndex = FIndex,
		FDura = self and self.duraMax or 0,
		FDuraMax = self and self.duraMax or 0,
		FItemValueList = {}
	}

	setmetatable(items18, {
		__index = gItemOp
	})

	local function callback3(self2)
		self2._item = self

		if not self2._item then
			return
		end

		self2.extendField = {}

		if self.AC then
			print("items.AC------", self.AC)

			self2.extendField.AC = self.AC
		end

		if self.maxAC then
			self2.extendField.maxAC = self.maxAC
		end

		if self.MAC then
			self2.extendField.MAC = self.MAC
		end

		if self.DC then
			print("items.DC------", self.DC)

			self2.extendField.MAC = self.DC
		end

		if self.maxDC then
			print("items.maxDC------", self.maxDC)

			self2.extendField.MAC = self.maxDC
		end

		return self2
	end

	items18 = items18 and callback3(items18)

	return items18
end

items.valueType2Key = {
	[0] = "AC",
	"maxAC",
	"MAC",
	"maxMAC",
	"DC",
	"maxDC",
	"MC",
	"maxMC",
	"SC",
	"maxSC",
	"CC",
	"maxCC",
	"normalStateSet",
	"need",
	"needLevel",
	"antiqueLv",
	"maxDura",
	"hitSpeed",
	"quickRate",
	"accurate",
	"posiAC",
	"HP",
	"MP",
	"price",
	"strength",
	"AttributeDC",
	"AttributeAC",
	"AttributeMAC",
	"AttributeMaxMC",
	"AttributeMaxSC",
	"AttributeLucky",
	"AttributeStrength",
	"AttributeHitSpeed",
	"AttributeSTONE_DEF",
	"AttributePOIS_RESUME",
	"AttributeAccurate",
	"AttributeDura",
	"AttributeQuickRate",
	"AttributeMaxDura",
	"AttributeMcAvoid",
	"JewelType",
	"JewelAbil",
	"JewelDC",
	"JewelMC",
	"JewelSC",
	"JewelAC",
	"JewelMAC",
	"JewelDura",
	"JewelHitSpeed",
	"JewelQuickRate",
	"JewelAccurate",
	"JewelPoisAc",
	"JewelDownSpeed",
	"JewelStrength",
	"VTGiftProp"
}

local value7
local value11
local value14
local value9
local value15
local items15 = {
	ctor = function(skills)
		g_data.mark.playerName = value11.getPlayerName()

		local diy = cache.getDiy(value11.getPlayerName(), skills.saveCurrent)
		local kcDiy = cache.getKcDiy()

		diy = diy or kcDiy or clone(value9.default)
		g_data.setting.chat.whisperLimit = 40

		if WIN32_OPERATE then
			for _, default_pc in ipairs(value9.default_pc) do
				local enabled = false

				for _2, item in ipairs(diy) do
					if default_pc.key == item.key then
						enabled = true
					end
				end

				if not enabled then
					table.insert(diy, default_pc)
				end
			end

			g_data.bag.customs = cache.getCustoms(value11.getPlayerName())
		end

		skills.widgets = {}

		for _3, item2 in ipairs(diy) do
			if value9.getConfig(item2).btntype ~= "custom" or WIN32_OPERATE then
				skills.addWidget(skills, item2)
			end
		end

		skills.size(skills, display.width, display.height)

		skills.controller = import(".controller", value7).new(skills)
		skills.skills = import(".skills", value7).new(skills)
		skills.btnCallbacks = import(".btnCallbacks", value7).new(skills)
		skills.autoRat = import(".autoRat", value7).new(skills)
	end,
	resetAutoRat = function(autoRat)
		autoRat.autoRat = import(".autoRat", value7).new(autoRat)
	end,
	get = function(widgetsOwner, value)
		return widgetsOwner.widgets[value]
	end,
	setWidgetSelect = function(value, value29, value30)
		local btnOwner = value.get(value, value29)

		if btnOwner and btnOwner.btn.setIsSelect then
			btnOwner.btn:setIsSelect(value30)
		end
	end,
	call = function(value, value30, value31, ...)
		local value29 = value.get(value, value30)

		if value29 and value29[value31] then
			value29[value31](value29, ...)
		end
	end,
	addWidget = function(value, data, value30)
		local config = value9.getConfig(data)

		if config then
			if config.fixedX then
				data.x = config.fixedX
			end

			if config.fixedY then
				data.y = config.fixedY
			end

			local value29 = import(".widget." .. config.class, value7).new(config, data):add2(value, config.z or value.z.widget)

			value29.data = data
			value29.config = config
			btn = value29.btn or value29

			if config.key == "btnSkillTemp" then
				btn:setName("diy_" .. data.key)
			else
				btn:setName("diy_" .. config.name)
			end

			value.widgets[data.key] = value15.extend(value29, value)

			value.resetBtnAreaBtnPos(value, value29, value30)

			if value.editting then
				value29._startEdit(value29)
			end
		end

		if main_scene.ui and main_scene.ui.panels.diy then
			main_scene.ui.panels.diy:checkSelect(data.key, value)
		end
	end,
	addWidgetByPanel = function(value, point, value29)
		if value.get(value, point.key) then
			return "exist"
		end

		local config = value9.getConfig(point)

		if not config then
			return
		end

		if config.class == "btnMove" then
			local btnpos = value.pos2btnpos(value, point.x, point.y)

			if btnpos then
				local widgetWithBtnpos = value.findWidgetWithBtnpos(value, btnpos)

				if widgetWithBtnpos then
					value14.new(widgetWithBtnpos, function(value2)
						if value2 == "replace" then
							value:removeWidget(widgetWithBtnpos.data.key)

							point.btnpos = btnpos

							value:addWidget(point, true)
						end
					end, value29):setName("replaceAskNode")
				else
					point.btnpos = btnpos

					value.addWidget(value, point, true)
				end
			else
				value.addWidget(value, point)
			end

			return
		end

		value.addWidget(value, point)
	end,
	removeWidget = function(widgetsOwner, value)
		if widgetsOwner.widgets[value] then
			widgetsOwner.widgets[value]:removeSelf()

			widgetsOwner.widgets[value] = nil
		end

		if main_scene.ui and main_scene.ui.panels.diy then
			main_scene.ui.panels.diy:checkSelect(value, widgetsOwner)
		end
	end,
	btnpos2pos = function(value, parts)
		parts = string.split(parts, "-")

		local value29 = display.width - (parts[2] - 0.5) * value.btnAreaSpace - value.btnAreaBegin
		local value30 = (parts[1] - 0.5) * value.btnAreaSpace + value.btnAreaBegin

		return value29, value30
	end,
	pos2btnpos = function(value, x, y)
		local btnAreaRect = value.getBtnAreaRect(value)

		if not cc.rectContainsPoint(btnAreaRect, cc.p(x, y)) then
			return
		end

		x = x - btnAreaRect.x
		x = value.btnAreaLineNum - math.modf(x / value.btnAreaSpace)
		x = math.max(1, math.min(x, value.btnAreaLineNum))
		y = y - value.btnAreaBegin
		y = math.modf(y / value.btnAreaSpace) + 1
		y = math.max(1, math.min(y, value.btnAreaMaxLine))

		return y .. "-" .. x
	end,
	findWidgetWithBtnpos = function(widgetsOwner, value)
		for _, widget in pairs(widgetsOwner.widgets) do
			if widget.__cname == "btnMove" and widget.data.btnpos and widget.data.btnpos == value then
				return widget
			end
		end
	end,
	resetBtnAreaBtnPos = function(value, x, value30)
		if x.__cname == "btnMove" and x.data.btnpos then
			local y, value29 = value.btnpos2pos(value, x.data.btnpos)

			if y ~= x.getPositionX(x) or value29 ~= x.getPositionY(x) then
				if value30 then
					x.moveTo(x, 0.1, y, value29)
				else
					x.pos(x, y, value29)
				end
			end
		end
	end,
	resetAllBtnAreaBtnPos = function(value, value29)
		for _, widget in pairs(value.widgets) do
			value.resetBtnAreaBtnPos(value, widget, value29)
		end
	end,
	startEdit = function(value)
		value.call(value, "btnMode", "showModeSelect")

		for _, widget in pairs(value.widgets) do
			widget._startEdit(widget)
			widget.show(widget)
		end

		value.editting = true
	end,
	endEdit = function(value)
		for _, widget in pairs(value.widgets) do
			widget._endEdit(widget)
		end

		value.editting = false

		value.saveEdit(value)
	end,
	saveEdit = function(value, value29)
		local items18 = {}
		local value30 = sortNodes(table.values(value.widgets))

		for _, item in ipairs(value30) do
			table.insert(items18, 1, item.data)
		end

		cache.saveDiy(value11.getPlayerName(), value29 or value.saveCurrent, items18)
	end,
	saveKcUi = function(widgetsOwner)
		local items18 = {}
		local value = sortNodes(table.values(widgetsOwner.widgets))

		for _, item in ipairs(value) do
			table.insert(items18, 1, item.data)
		end

		cache.saveKcDiy(items18)
	end,
	showRect = function(value, value29, value30)
		value.hideAllRect(value)

		value29 = value29 or value.get(value, value30)

		if not value29 then
			return
		end

		value29._showRect(value29)
	end,
	hideAllRect = function(widgetsOwner)
		for _, widget in pairs(widgetsOwner.widgets) do
			widget._hideRect(widget)
		end
	end,
	showEditBg = function(editBg, value)
		if not editBg.editBg then
			editBg.editBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 128)):size(display.width, display.height):add2(editBg, editBg.z.editBg)

			display.newNode():size(editBg.editBg:getContentSize()):add2(editBg.editBg):enableClick(function()
				editBg:hideAllRect()
			end)
		end

		editBg.editBg:setVisible(value)
	end,
	getBtnAreaRect = function(value)
		return cc.rect(display.width - value.btnAreaSpace * value.btnAreaLineNum - value.btnAreaBegin, 0, value.btnAreaSpace * value.btnAreaLineNum + value.btnAreaBegin, value.btnAreaSpace * value.btnAreaMaxLine + value.btnAreaBegin)
	end,
	checkBtnAreaShow = function(btnBg, value, value29)
		local size = btnBg.getBtnAreaRect(btnBg)

		if value then
			value29 = value29 or not cc.rectContainsPoint(size, value)
		end

		if not btnBg.btnBg then
			btnBg.btnBg = display.newScale9Sprite(res.getframe2("pic/scale/scale6.png"), size.x, size.y, cc.size(size.width, size.height)):anchor(0, 0):add2(btnBg, btnBg.z.btnAreaBg)
		end

		btnBg.btnBg:setVisible(not value29)
	end,
	fillPropTest = function(widgetsOwner)
		for _, widget in pairs(widgetsOwner.widgets) do
			if widget.config.btntype == "prop" then
				widget.prop_fill_test(widget)
			end

			if widget.config.btntype == "custom" then
				widget.custom_fill_test(widget)
			end
		end
	end,
	update = function(value, value29)
		for _, widget in pairs(value.widgets) do
			if widget.update then
				widget.update(widget, value29)
			end
		end

		value.controller:update(value29)
	end,
	hidePet = function(value)
		return
	end
}
local value16
local value8
local width
local value12
local value24
local height2
local items16 = {
	hide = function(value)
		value:removeSelf()

		if main_scene then
			main_scene:stopAllActions()
			main_scene:moveTo(0.2, 0, 0)
			main_scene.ground:stopAllActions()
			main_scene.ground:moveTo(0.2, 0, 0)
		end
	end,
	ctor = function(bg, from)
		if main_scene then
			main_scene:stopAllActions()
			main_scene:moveTo(0.2, 0, height2)
			main_scene.ground:stopAllActions()
			main_scene.ground:moveTo(0.2, 0, -height2 / 2)
		end

		bg:size(display.width, display.height):add2(display.getRunningScene(), an.z.max)
		bg:setTouchEnabled(true)
		bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(nameOwner)
			if nameOwner.name == "began" then
				bg:hide()
			end
		end)

		bg.bg = display.newScale9Sprite(res.getframe2("pic/scale/scale1.png")):anchor(0, 1):pos(-4, 0):add2(bg):size(display.width + 8, height2 + 4)
		bg.from = from

		bg:loadMain()
	end,
	loadMain = function(content)
		content.content = display.newNode():pos(0, -height2):size(display.cx, height2):add2(content):enableClick(function()
			return
		end)

		for index = 1, value16 do
			local x = (index - 1) % value12
			local value = math.modf((index - 1) / value12)
			local text = "pic/emoji/" .. index .. ".png"
			local btn = an.newBtn(res.gettex2(text), function()
				print(content.from)

				if content.from == "console" then
					main_scene.ui.console:call("chat", "addEmoji", text)
				elseif content.from == "guild" then
					if main_scene.ui.panels.guild then
						main_scene.ui.panels.guild:addEmoji(text)
					end
				elseif content.from == "relation" then
					if main_scene.ui.panels.relation then
						main_scene.ui.panels.relation:addEmoji(text)
					end
				elseif main_scene.ui.panels.chat then
					main_scene.ui.panels.chat:addEmoji(text)
				end
			end, {
				pressBig = true,
				size = {
					value8,
					value8
				}
			}):pos(x * value8 + value8 / 2, content.content:geth() - value * value8 - value8 / 2):add2(content.content)
		end

		display.newScale9Sprite(res.getframe2("pic/scale/scale6.png")):anchor(1, 0):pos(display.width, 0):size(width - 5, height2):add2(content.content):enableClick(function()
			if content.from == "console" then
				main_scene.ui.console:call("chat", "say")
			elseif content.from == "relation" then
				if main_scene.ui.panels.relation then
					main_scene.ui.panels.relation:say()
				end
			elseif main_scene.ui.panels.chat then
				main_scene.ui.panels.chat:say()
			end

			content:hide()
		end)
		an.newLabel("发", 24, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0.5, 0.5):pos(display.width - (width - 5) / 2, height2 / 2 + 15):add2(content.content)
		an.newLabel("送", 24, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0.5, 0.5):pos(display.width - (width - 5) / 2, height2 / 2 - 15):add2(content.content)
	end
}
local tileOwner
local value5
local items4 = {
	maxFrame = 10,
	cache = {}
}

local function callback3()
	return main_scene and main_scene.ground.map or nil
end

local function callback4(self, value, value29, value30)
	local mapPos, mapPos2 = self:getMapPos(value29, value30)

	value:addto(self.layers.obj, mapPos2 + tileOwner.tile.h)
	__position(value, mapPos, mapPos2 + tileOwner.tile.h)
end

local items6 = {}

local function callback5(self, value29, value30)
	local value = self .. "-" .. value29 .. "-" .. value30
	local time = socket.gettime()
	local value31 = items6[value]

	items6[value] = time

	return not value31 or time - value31 > 0.3
end

local function callback6(self, value29, value31, value32, value33, value34, value35)
	local value, value30 = m2spr.playAnimation(self, value29, value31, value32, value33.blend, value33.autoRemove, value33.playOnce, value34, value33.disableSetOffset, value33.loadPriority, value33.frameStep)

	if value33.black or black then
		value:setBlendFunc(gl.ONE, gl.ONE)
	end

	return value, value30
end

local items7 = {
	autoRemove = true,
	blend = true,
	playOnce = true
}
local items5 = {
	autoRemove = false,
	blend = true,
	playOnce = true
}
local items8 = {
	autoRemove = false,
	blend = true,
	playOnce = false
}
local items9 = {
	autoRemove = false,
	black = true,
	playOnce = false
}
local number = 60

local function callback7(self, value29, value31, value33)
	local value = value33 + tileOwner.tile.h
	local value30 = value31 - self
	local value32 = value - value29
	local value34 = math.max(1, math.abs(value30))
	local value35 = math.max(1, math.abs(value32))
	local count = 1

	if value35 <= value34 then
		count = (value34 - number) / value34
	else
		count = (value35 - number) / value35
	end

	local value36 = math.max(0, count)

	return self + value30 * value36, value29 + value32 * value36
end

function items4.showMagic(self, data, options, options2, options3, options4)
	local magicConfig = def.magic.getMagicConfig(options4)

	if not magicConfig then
		return
	end

	local magicId = magicConfig.uid

	sound.play("skillPlay", {
		magicId = magicId
	})

	if options4 == 177 then
		local value = main_scene.ui.console.controller.lock

		if value.target.select == data.roleid then
			value:stop()
		end
	end

	if not magicConfig.beatenFrame and not magicConfig.flyFrame then
		return
	end

	if options4 == 8 then
		local value29 = magicConfig.beatenFrame.begin + data.dir * items4.maxFrame
		local value30 = callback6(magicConfig.rsc, value29, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, items7)

		callback4(self, value30, data.x, data.y)
	elseif options4 == 7 or options4 == 114 then
		local number2 = 8
		local value31 = def.role.dir["_" .. data.dir]
		local value32 = data.x + value31[1] * number2
		local value33 = data.y + value31[2] * number2
		local mapPos, mapPos2 = self:getMapPos(value32, value33)
		local mapPos3, mapPos4 = self:getMapPos(data.x, data.y)

		value5.easyProjectile(magicConfig.par, self.layers.obj, 0.56, mapPos3, mapPos4 + tileOwner.tile.h, mapPos, mapPos2 + tileOwner.tile.h)

		for index = 1, number2 do
			local mapPos5, mapPos6 = self:getMapPos(data.x + index * value31[1], data.y + index * value31[2])
			local value34 = m2spr.new(nil, nil, {
				blend = true,
				setOffset = true
			}):addto(self.layers.bg, mapPos6 + tileOwner.tile.h):pos(mapPos5, mapPos6 + tileOwner.tile.h)

			value34:runs({
				cc.DelayTime:create((index - 1) * 0.13),
				cc.Show:create(),
				cc.CallFunc:create(function()
					value34:playAni(magicConfig.rsc, magicConfig.beatenFrame.begin, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, true, true, false)
				end),
				cc.DelayTime:create((magicConfig.beatenFrame.frame - 4) * magicConfig.beatenFrame.delay),
				cc.CallFunc:create(function()
					if options4 == 7 then
						value34:playAni("magic", 2460, 10, 0.25, true, true, true)
					end

					if options4 == 114 then
						value34:playAni("proguse", 261, 1, 2, true, true, true)
					end
				end)
			})
		end
	elseif options4 == 172 then
		local number3 = 5
		local value35
		local mapPos7, mapPos8 = self:getMapPos(data.x, data.y)

		for index2 = 1, 3 do
			if index2 == 1 then
				value35 = def.role.dir["_" .. (data.dir + 1) % 8]
			elseif index2 == 2 then
				value35 = def.role.dir["_" .. (data.dir + 7) % 8]
			else
				value35 = def.role.dir["_" .. data.dir]
			end

			local mapPos9, mapPos10 = self:getMapPos(data.x + value35[1] * number3, data.y + value35[2] * number3)

			value5.easyProjectile(magicConfig.par, self.layers.obj, 0.56, mapPos7, mapPos8 + tileOwner.tile.h, mapPos9, mapPos10 + tileOwner.tile.h)
			print(mapPos7, mapPos8, mapPos9, mapPos10)

			for index3 = 1, number3 do
				local mapPos11, mapPos12 = self:getMapPos(data.x + index3 * value35[1], data.y + index3 * value35[2])
				local value36 = m2spr.new(nil, nil, {
					blend = true,
					setOffset = true
				}):addto(self.layers.mid0, mapPos12 + tileOwner.tile.h):pos(mapPos11, mapPos12 + tileOwner.tile.h)

				value36:runs({
					cc.DelayTime:create((index3 - 1) * 0.08),
					cc.Show:create(),
					cc.CallFunc:create(function()
						value36:playAni(magicConfig.rsc, magicConfig.beatenFrame.begin, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, true, true, false)
					end),
					cc.DelayTime:create((magicConfig.beatenFrame.frame - 4) * magicConfig.beatenFrame.delay),
					cc.CallFunc:create(function()
						value36:playAni("proguse", 260, 1, 2, true, true, true)
					end)
				})
			end
		end
	elseif options4 == 134 then
		local number4 = 8
		local value37 = def.role.dir["_" .. data.dir]
		local value38 = data.x + value37[1] * number4
		local value39 = data.y + value37[2] * number4
		local mapPos13, mapPos14 = self:getMapPos(value38, value39)
		local y = mapPos14 + tileOwner.tile.h
		local value40 = callback6(magicConfig.rsc, magicConfig.beatenFrame.begin, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, items5)

		callback4(self, value40, data.x, data.y)

		local value41 = value5.easyBegin(magicConfig.par, value40, mapPos13, y)

		value40:runs({
			cca.delay(0.4),
			cca.show(),
			cca.moveTo(0.3, cc.p(mapPos13, y)),
			cca.callFunc(function()
				value5.easyEnd(value41)
				value40:removeSelf()
			end)
		})
	elseif options4 == 11 or options4 == 12 then
		if not magicConfig.flyFrame then
			return
		end

		local value42 = magicConfig.flyFrame.begin + data.dir * items4.maxFrame * 2
		local mapPos15, mapPos16 = self:getMapPos(options2, options3)
		local duration = 0.15
		local value43 = callback6(magicConfig.rsc, value42, magicConfig.flyFrame.frame, magicConfig.flyFrame.delay, items8)

		callback4(self, value43, data.x, data.y)

		local value44 = value5.easyBegin(magicConfig.par, value43, mapPos15, mapPos16)

		value43:runs({
			cc.MoveTo:create(duration, cc.p(mapPos15, mapPos16 + tileOwner.tile.h)),
			cc.CallFunc:create(function()
				sound.play("skillPlay", {
					idx = 3,
					magicId = magicId
				})
				value5.easyEnd(value44)
				value43:removeSelf()

				local value, value29 = m2spr.playAnimation(magicConfig.rsc, magicConfig.beatenFrame.begin, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, true, true, true)
				local value30 = mapPos16 + tileOwner.tile.h

				value:addto(self.layers.obj, value30)
				__position(value, mapPos15, value30)
			end)
		})
	elseif options4 == 1 or options4 == 3 or options4 == 11 or options4 == 17 or options4 == 39 or options4 == 63 or options4 == 98 or options4 == 99 or options4 == 100 or options4 == 101 or options4 == 102 or options4 == 128 or options4 == 174 then
		if not magicConfig.flyFrame then
			return
		end

		local value45 = magicConfig.flyFrame.begin + data.dir * items4.maxFrame * (magicConfig.flyFrame.dir or 2)
		local roelWithPos

		if options4 == 17 then
			roelWithPos = self:findRoelWithPos(options2, options3)
		else
			roelWithPos = self:findRole(options)
		end

		local mapPos17
		local mapPos18
		local duration2
		local value46
		local value47
		local mapPos19, mapPos20 = self:getMapPos(data.x, data.y)

		if roelWithPos then
			local value48, value49 = roelWithPos.x, roelWithPos.y

			mapPos17, mapPos18, duration2 = self:getMapPos(value48, value49)

			local value50 = self:gameDistance(data, roelWithPos)

			duration2 = 0.3 * math.min(1, value50 / 10)
		else
			local value51 = def.role.dir["_" .. data.dir]
			local value52, value53 = data.x + value51[1] * 12, data.y + value51[2] * 12

			mapPos17, mapPos18 = self:getMapPos(value52, value53)
			duration2 = 1
		end

		local value54 = callback6(magicConfig.rsc, value45, magicConfig.flyFrame.frame, magicConfig.flyFrame.delay, items9)

		callback4(self, value54, data.x, data.y)

		local x, y2 = callback7(mapPos19, mapPos20, mapPos17, mapPos18)
		local value55 = value5.easyBegin(magicConfig.par, value54, x, y2)

		value54:runs({
			cc.MoveTo:create(duration2, cc.p(x, y2)),
			cc.CallFunc:create(function()
				value5.easyEnd(value55)
				value54:removeSelf()

				if roelWithPos and roelWithPos.node and not tolua.isnull(roelWithPos.node) and (callback5(options4, mapPos19, mapPos20) or options4 == 174) then
					sound.play("skillPlay", {
						idx = 3,
						magicId = magicId
					})

					local value, value29 = m2spr.playAnimation(magicConfig.rsc, magicConfig.beatenFrame.begin, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, true, true, true)

					value:addto(self.layers.obj, mapPos18 + tileOwner.tile.h)
					__position(value, mapPos17, mapPos18 + tileOwner.tile.h)
				end
			end)
		})
	else
		if options4 == 35 then
			options2, options3 = data.x, data.y
		end

		if callback5(options4, options2, options3) then
			local mapPos21, mapPos22 = self:getMapPos(options2, options3)
			local value56
			local value57

			value56, value57 = callback6(magicConfig.rsc, magicConfig.beatenFrame.begin, magicConfig.beatenFrame.frame, magicConfig.beatenFrame.delay, items5, function()
				local value = magicConfig.beatenFrame.next

				if value then
					value57:playAni(magicConfig.rsc, value.begin, value.frame, value.delay, true, true, true)
				else
					value56:removeSelf()
				end
			end)

			value56:addto(self.layers.obj, options3 + tileOwner.tile.h)
			__position(value56, mapPos21, mapPos22 + tileOwner.tile.h)

			if tonumber(magicId) == 6 and self:findRole(options) then
				sound.play("skillPlay", {
					idx = 3,
					magicId = magicId
				})
			end
		end
	end
end

local function callback8(self, value)
	if #self == 1 then
		return self[1]
	end

	if not value then
		return
	end

	for _, item in ipairs(self) do
		if item.job == value then
			return item
		end
	end
end

function items4.showSpellEffect(self, data)
	self = self + 1

	local value = callback3()

	if not value then
		return
	end

	local magicConfig = def.magic.getMagicConfig(self)

	if not magicConfig then
		return
	end

	if not magicConfig.startFrame then
		return
	end

	local value29 = callback8(magicConfig.startFrame, data.job)

	if not value29 then
		p2("error", "get start effect frame info error")

		return
	end

	local value30 = value29.begin

	if data.dir and value29.dir and value29.dir ~= 0 then
		value30 = value30 + data.dir * ((value29.skip or 0) + value29.frame)
	end

	local value31

	if value29.rsc then
		value31 = value29.rsc
	else
		value31 = magicConfig.rsc
	end

	local value32 = callback6(value31, value30, value29.frame, data.delay / value29.frame, items7)
	local value33 = data.elmt

	if value33 and value33 ~= 0 then
		value32:setColor(def.role.EeltColor[value33])
	end

	callback4(value, value32, data.x, data.y)
end

local function cleanup(self, value)
	if #self == 1 then
		return self[1]
	end

	if not value then
		return
	end

	for _, item in ipairs(self) do
		if item.type == value then
			return item
		end
	end
end

local function cleanup2(self, value)
	for _, item in ipairs(self) do
		if item.name == value then
			return item
		end
	end
end

function items4.showStruckEffect(self, data)
	local value = callback3()

	if not value then
		return
	end

	if not data then
		data = def.magic.getStruckEffectByType(self.elmt or 0)

		if not data then
			return
		end
	end

	local value29 = data.begin
	local value30 = data.rsc or "magicex"
	local value31

	value31 = callback6(value30, value29, data.frame, data.delay or self.delay / data.frame, items5, function()
		value31:removeSelf()
	end, true)

	callback4(value, value31, self.x, self.y)
end

function items4.showHitEffect(self, data, rsc)
	self = self or 0

	local value = callback3()

	if not value then
		return
	end

	if not rsc then
		local magicConfigByUid = def.magic.getMagicConfigByUid(self)

		if not magicConfigByUid or not magicConfigByUid.hitFrame then
			return
		end

		rsc = cleanup(magicConfigByUid.hitFrame, data.type)

		if rsc then
			rsc.rsc = magicConfigByUid.rsc
			rsc.otherFrame = magicConfigByUid.otherFrame
		else
			return
		end
	end

	local value29 = rsc.begin

	if not rsc.nodir then
		value29 = value29 + data.dir * ((rsc.skip or 0) + rsc.frame)
	end

	local value30

	value30 = callback6(rsc.rsc, value29, rsc.frame, rsc.delay or data.delay / rsc.frame, items5, function()
		value30:removeSelf()

		if rsc.next then
			if not rsc.otherFrame then
				p2("error", "otherFrame is null next frame can not find")

				return
			end

			local value2 = cleanup2(info.otherFrame, rsc.next)

			value2.rsc = rsc.rsc
			value2.otherFrame = rsc.otherFrame

			items4.showHitEffect(self, data, value2)
		end
	end)

	local value31 = data.elmt

	if value31 and value31 ~= 0 then
		value30:setColor(def.role.EeltColor[value31])
	end

	callback4(value, value30, data.x, data.y)
end

function items4.showWithName(self, data, player)
	for _, item in ipairs(def.magic.getConfig("mapMagic")) do
		local race
		local appr

		if player.role then
			race = player.role:getRace()
			appr = player.role:getAppr()
		end

		if item.name == data and (not item.byID or item.byID == def.role.getRoleId(race, appr)) then
			if item.sound then
				sound.playSound(tostring(item.sound))
			end

			if item.playType == 1 then
				local role = self:findRole(player.roleid)

				if not role then
					return
				end

				if not callback5(item.name, role.x, role.y) then
					return
				end

				player.x, player.y = role.x, role.y
			elseif item.playType == 2 then
				if not item.skip then
					p2("show map magic " .. item.name .. " not find key skip")
				end

				local count = 0

				if not item.dircount or item.dircount == 8 then
					count = item.rscIdx + (item.frame + item.skip) * player.role.dir
				elseif item.dircount == 1 then
					count = item.rscIdx
				elseif item.dircount == 16 then
					count = item.rscIdx + (item.frame + item.skip) * player.role.dir * 2
				end

				local mapPos, mapPos2 = self:getMapPos(player.x, player.y)
				local duration = 0.2

				if item.alltime then
					duration = item.alltime
				end

				local value
				local value29 = m2spr.playAnimation(item.rsc, count, item.frame, item.delay, not item.noBlend)

				if item.colorR or item.colorG or item.colorB then
					value29:setColor(cc.c3b(item.colorR, item.colorG, item.colorB))
				end

				value29:runs({
					cc.MoveTo:create(duration, cc.p(mapPos, mapPos2 + tileOwner.tile.h)),
					cc.CallFunc:create(function()
						value29:removeSelf()

						if item.otherEffect then
							local value2, value292 = m2spr.playAnimation(item.otherEffect.img, item.otherEffect.begin, item.otherEffect.frame, item.otherEffect.delay, true, true, true)
							local value30 = mapPos2 + tileOwner.tile.h

							value2:addto(self.layers.obj, value30)
							__position(value2, mapPos, value30)
						end
					end)
				})
				callback4(self, value29, player.role.x, player.role.y)

				return
			elseif item.playType == 3 then
				local role2 = self:findRole(player.roleid)

				if not role2 then
					return
				end

				local value30 = item.rscIdx + role2.dir * 10
				local value31

				value31 = m2spr.playAnimation(item.rsc, value30, item.frame, item.delay, not item.noBlend, nil, true, function()
					value31:removeSelf()

					if item.next then
						items4:showWithName(self, item.next, player)
					end
				end)

				callback4(self, value31, player.x, player.y)

				return
			end

			local value32
			local value33

			value32, value33 = m2spr.playAnimation(item.rsc, item.rscIdx, item.frame, item.delay, not item.noBlend, false, true, function()
				local value = item.trace

				if value then
					value33:playAni(value.rsc, value.rscIdx, value.frame, value.delay, false, true, true)
				else
					value32:removeSelf()
				end
			end)

			callback4(self, value32, player.x, player.y)

			return
		end
	end
end

local fashionidOwner
local value4
local value25
local value26
local value17
local value18
local value19
local value27
local value20
local items3 = {}
local value6

function items3.resetPanelPosition(self, type)
	if type == "right" then
		self.anchor(self, 1, 1):pos(display.width - 360, display.height - 60)
	elseif type == "right2" then
		self.anchor(self, 1, 1):pos(display.width - 340, display.height - 60)
	end

	return self
end

function items3.ctor(self, value)
	if tostring(327795123) ~= def.shouquan1 then
		return
	end

	if self.isHero then
		self.baseData = g_data.hero
		self.equipData = g_data.heroEquip
	else
		self.baseData = g_data.player
		self.equipData = g_data.equip
	end

	value = value or {}

	local bg = res.get2("pic/panels/equip/bg.png"):anchor(0, 0):addto(self)

	self.bg = bg

	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):resetPanelPosition(self.isHero and value.from == "equip" and "right2" or "right")

	self._scale = 1
	self._supportMove = true

	if not self.isHero or not (self.geth(self) - 50) then
		local h = self.geth(self) - 40
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self), self.geth(self) - 48):addto(self, 1)

	local text = ""

	if self.isHero then
		local text2 = "bag"

		an.newLabel(self.baseData.name, 22, 1):anchor(0.5, 0.5):pos(self.getw(self) / 2, self.geth(self) - 34):addto(self)
	else
		local text3 = "hero"

		if main_scene.ground.map and main_scene.ground.map.player then
			local value29 = main_scene.ground.map.player.info.name

			an.newLabel(value29.texts[1], 22, 1, {
				color = def.colors.get(value29.color)
			}):anchor(0.5, 0.5):pos(self.getw(self) / 2, self.geth(self) - 34):addto(self)
		end
	end

	self.guildLabel = an.newLabel("", 22, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self) * 0.5, 395)
	self.clanLabel = an.newLabel("", 20, 1, {
		color = cc.c3b(191, 173, 126)
	}):anchor(0.5, 0.5):addto(self):pos(self.getw(self) * 0.5, 360)

	local items18 = {
		"equip",
		"state",
		"attributes",
		"skill"
	}
	local items19 = {
		"装\n备",
		"状\n态",
		"属\n性",
		"技\n能"
	}
	local width2 = {}

	local function cleanup3(self2)
		sound.playSound("103")

		for index, item in ipairs(width2) do
			if item == self2 then
				item.select(item)
				item.setLocalZOrder(item, 5)
				item.label:setColor(cc.c3b(249, 237, 215))
			else
				item.setLocalZOrder(item, index - 5)
				item.unselect(item)
				item.label:setColor(cc.c3b(166, 161, 151))
			end
		end

		if self2.page ~= self.page then
			self:showContent(self2.page)
		end
	end

	for index, page in ipairs(items18) do
		width2[index] = an.newBtn(res.gettex2("pic/common/btn140.png"), function()
			return
		end, {
			label = {
				items19[index],
				22,
				1,
				cc.c3b(166, 161, 151)
			},
			labelOffset = {
				x = 2,
				y = 12
			},
			select = {
				res.gettex2("pic/common/btn141.png"),
				manual = true
			}
		}):add2(self, index - 5):anchor(1, 1):pos(7, 412 - (index - 1) * 86)

		width2[index]:setTouchEnabled(false)
		display.newNode():size(width2[index]:getw(), width2[index]:geth() - 30):pos(0, 30):add2(width2[index]):enableClick(function()
			cleanup3(width2[index])
		end)

		width2[index].page = page

		if (value.page or items18[1]) == page then
			width2[index]:select()
			width2[index]:setLocalZOrder(5)
			width2[index].label:setColor(cc.c3b(249, 237, 215))
			self.showContent(self, page)
		end
	end
end

function items3.showContent(self, page)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():addto(self)
	page = page or "equip"
	self.page = page

	self.guildLabel:setString("")
	self.clanLabel:setString("")

	if page == "equip" then
		self.content:setScale(1.2)

		local value = self.isHero and g_data.hero.sex or g_data.player.sex

		self.disY = 0

		if def.gameVersionType == "176" then
			self.disY = -26

			local value29 = value == 0 and "pic/panels/equip/equip176_0.png" or "pic/panels/equip/equip176_1.png"

			self.bg:setTex(res.gettex2(value29))
		else
			bgend = self.isHero and ".png" or ".png"

			local value30 = value == 0 and "pic/panels/equip/sex0" or "pic/panels/equip/sex1"

			self.bg:setTex(res.gettex2(value30 .. bgend))
		end

		self.fashionbg = res.get2("pic/panels/equip/bg2.png"):anchor(0, 0):addto(self.content):pos(self.bg:getw() - 44, 0):hide()

		an.newLabel("时装", 19, 1):anchor(0.5, 0.5):pos(self.fashionbg:getw() / 2, self.fashionbg:geth() - 28):addto(self.fashionbg)

		if not self.isHero or false then
			local text = ""

			if g_data.guild.guildInfo or g_data.guild.clanInfo then
				if g_data.guild.guildInfo then
					local value31 = g_data.guild.guildInfo:get("gildName")

					self.guildLabel:setString(value31)
				end

				if g_data.guild.clanInfo then
					local value32 = g_data.guild.clanInfo:get("corpsName")

					self.clanLabel:setString(value32)
				end
			end
		end

		local value33

		if self.isHero then
			if main_scene.ground.player and main_scene.ground.player.hero then
				value33 = main_scene.ground.player.hero.hair
			end
		elseif main_scene.ground.player then
			value33 = main_scene.ground.player.hair
		end

		if value33 and value33 > 0 then
			local value34 = value33 + 438

			res.getui(1, value34):addto(self.content):anchor(0.5, 1):pos(139, 240)
		end

		self.items = {}
		self.loopEffSpr = {}

		for itemId, item in pairs(self.equipData.items) do
			local count = 0

			if itemId == 2 or itemId == 3 or itemId >= 5 and itemId <= 8 then
				count = self.disY
			end

			local var = item.getVar("looks")
			local var2 = item.getVar("outlook")

			if itemId == 0 or itemId == 1 or itemId == 4 or itemId == 15 then
				local x, y, value35, isSetOffset, value36 = self.idx2pos(self, itemId)

				self.items[itemId] = value4.new(item, self, {
					img = "stateitem",
					isSetOffset = isSetOffset,
					idx = itemId
				}):addto(self.content, value35):pos(x, y + count):size(80, 127)

				local ani2 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

				ani2.retain(ani2)

				self.loopEffSpr[itemId] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(x + 98, y + count):add2(self.content, value35 + 1):anchor(0.5, 0.5)

				self.loopEffSpr[itemId].runForever(self.loopEffSpr[itemId], cc.Animate:create(ani2))
			elseif itemId == 13 and var2 ~= nil then
				if var2 > fashionidOwner.fashionid then
					self.fashionbg:show()

					local value37, value38, value39, isSetOffset2, value40 = self.idx2pos(self, itemId)

					self.items[itemId] = value4.new(item, self, {
						img = "stateitem",
						isSetOffset = isSetOffset2,
						idx = itemId
					}):addto(self.fashionbg):pos(self.fashionbg:getw() / 2, self.fashionbg:geth() / 2)

					local ani22 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

					ani22.retain(ani22)

					self.loopEffSpr[itemId] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(self.fashionbg:getw() / 2, self.fashionbg:geth() / 2):add2(self.fashionbg):anchor(0.5, 0.5)

					self.loopEffSpr[itemId].runForever(self.loopEffSpr[itemId], cc.Animate:create(ani22))
				else
					local x2, y2, value41, isSetOffset3, value42 = self.idx2pos(self, itemId)

					self.items[itemId] = value4.new(item, self, {
						img = "stateitem",
						isSetOffset = isSetOffset3,
						idx = itemId
					}):addto(self.content, value41):pos(x2, y2 + count)

					local ani23 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

					ani23.retain(ani23)

					self.loopEffSpr[itemId] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(x2 - 3, y2 + count):add2(self.content, value41 + 1):anchor(0.5, 0.5)

					self.loopEffSpr[itemId].runForever(self.loopEffSpr[itemId], cc.Animate:create(ani23))
				end
			else
				local x3, y3, value43, isSetOffset4, value44 = self.idx2pos(self, itemId)

				self.items[itemId] = value4.new(item, self, {
					img = "stateitem",
					isSetOffset = isSetOffset4,
					idx = itemId
				}):addto(self.content, value43):pos(x3, y3 + count)

				local ani24 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

				ani24.retain(ani24)

				self.loopEffSpr[itemId] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(x3 - 3, y3 + count):add2(self.content, value43 + 1):anchor(0.5, 0.5)

				self.loopEffSpr[itemId].runForever(self.loopEffSpr[itemId], cc.Animate:create(ani24))
			end

			if attach then
				self.items[itemId .. "_attach"] = value4.new(item, self, {
					idx = itemId
				}):addto(self.content, attach[3]):pos(attach[1], attach[2])
			end
		end

		if not self.isHero and (g_data.security.equipBit or g_data.equip.lockState > 0) then
			self.btnSecurity = an.newBtn(res.gettex2("pic/panels/equip/security0.png"), function()
				sound.playSound("103")

				if g_data.equip.lockState == 0 then
					return
				end

				local time = socket.gettime()

				if g_data.client.lastTime.clickUnlockTime and time - g_data.client.lastTime.clickUnlockTime < 3 then
					return
				end

				local value2 = time - g_data.client.lastTime.equipUnlockTime
				local value29 = math.floor(g_data.equip.serverUnlockTime - value2)

				if value29 > 0 then
					value20.addMsg("请等待" .. value29 .. "秒之后再解锁装备", display.COLOR_WHITE, display.COLOR_RED)
				else
					net.send({
						CM_LOCK_UNLOCK_EQUIP
					})
					g_data.client:setLastTime("clickUnlockTime", true)
				end
			end, {
				support = "easy",
				pressImage = res.gettex2("pic/panels/equip/security1.png"),
				select = {
					res.gettex2("pic/panels/equip/security2.png"),
					manual = true
				}
			}):pos(290, 347):add2(self.content):scale(0.9)
		end
	else
		if page == "state" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local count2 = 0
			local y4 = 372

			local function callback32(self2, value)
				an.newLabel(self2, 20, 0, {
					color = cc.c3b(191, 173, 126)
				}):anchor(0, 0.5):addto(self.content):pos(26, y4 - count2 * 48)
				res.get2("pic/panels/equip/attback.png"):anchor(0, 0.5):pos(90, y4 - count2 * 48):add2(self.content)
				an.newLabel(value, 20, 0, {
					color = cc.c3b(188, 188, 188)
				}):anchor(0, 0.5):addto(self.content):pos(98, y4 - count2 * 48)

				count2 = count2 + 1
			end

			local value45 = self.baseData.ability
			local value46 = self.baseData.ability3
			local items18 = {
				{
					"物防",
					value45.get(value45, "AC") .. "-" .. value45.get(value45, "maxAC")
				},
				{
					"魔防",
					value45.get(value45, "MAC") .. "-" .. value45.get(value45, "maxMAC")
				},
				{
					"攻击",
					value45.get(value45, "DC") .. "-" .. value45.get(value45, "maxDC")
				},
				{
					"魔法",
					value45.get(value45, "MC") .. "-" .. value45.get(value45, "maxMC")
				},
				{
					"道术",
					value45.get(value45, "SC") .. "-" .. value45.get(value45, "maxSC")
				},
				{
					"生命值",
					value45.get(value45, "HP") .. "/" .. value45.get(value45, "maxHP")
				},
				{
					"魔法值",
					value45.get(value45, "MP") .. "/" .. value45.get(value45, "maxMP")
				}
			}

			for _, item2 in ipairs(items18) do
				callback32(item2[1], item2[2])
			end

			return
		end

		if page == "attributes" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local scroll = an.newScroll(28, 34, 278, 368):add2(self.content)
			local number2 = 30
			local items19 = {}

			local function callback42(self2, value)
				items19[#items19 + 1] = {
					self2,
					value
				}
			end

			local value47 = self.baseData.ability
			local value48 = self.baseData.ability3

			callback42("职业", self.baseData:getJobStr())
			callback42("等级", value47.get(value47, "level"))
			callback42("幸运值", value48.get(value48, "attackLuck"))

			if not self.isHero then
				callback42("声望", value48.get(value48, "prestige"))
				callback42("元宝", self.baseData:getIngot())
				callback42("灵符", self.baseData:getGird())
			end

			callback42("当前经验", value47.get(value47, "Exp"))
			callback42("升级经验", value47.get(value47, "maxExp"))

			slot8 = self.isHero or slot8

			callback42("背包负重", value47.get(value47, "weight") .. "/" .. value47.get(value47, "maxWeight"))
			callback42("穿戴负重", value47.get(value47, "wearWeight") .. "/" .. value47.get(value47, "maxWearWeight"))
			callback42("腕力", value47.get(value47, "handWeight") .. "/" .. value47.get(value47, "maxHandWeight"))
			callback42("准确", value47.get(value47, "hitRate"))
			callback42("敏捷", value47.get(value47, "quickRate"))
			callback42("魔法躲避", "+" .. value47.get(value47, "antiMagic") * 10 .. "%")
			callback42("毒物躲避", "+" .. value47.get(value47, "poisAC") .. "%")
			callback42("中毒恢复", "+" .. value47.get(value47, "buPoisResume") * 10 .. "%")
			callback42("体力恢复", "+" .. value47.get(value47, "hpResume") .. "%")
			callback42("魔法恢复", "+" .. value47.get(value47, "mpResume") .. "%")

			slot8 = self.isHero or slot8

			scroll.setScrollSize(scroll, 278, math.max(368, #items19 * number2))

			for index, item3 in ipairs(items19) do
				an.newLabel(item3[1], 20, 0, {
					color = cc.c3b(217, 207, 183)
				}):addto(scroll):pos(16, scroll.getScrollSize(scroll).height - index * number2)
				an.newLabel(item3[2], 20, 0, {
					color = cc.c3b(217, 207, 183)
				}):addto(scroll):pos(133, scroll.getScrollSize(scroll).height - index * number2)
			end

			local background = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.content):anchor(0, 0)
			local value_2 = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(background.getw(background) * 0.5, background.geth(background) - 42):add2(background)

			scroll.setListenner(scroll, function(nameOwner)
				if nameOwner.name == "moved" then
					local scrollOffset, scrollOffset2 = scroll:getScrollOffset()
					local scrollSize = scroll:getScrollSize().height - scroll:geth()

					if scrollOffset2 < 0 then
						scrollOffset2 = 0
					end

					scrollOffset2 = scrollSize < scrollOffset2 and scrollSize or scrollOffset2

					value_2:setPositionY(-(background:geth() - 42) * (scrollOffset2 / scrollSize - 1))
				end
			end)
		elseif page == "skill" then
			self.bg:setTex(res.gettex2("pic/panels/equip/bg.png"))

			local rect = cc.rect(0, 0, 310, 368)
			local magicIds = def.magic.getMagicIds(self.baseData.job, self.isHero)

			if self.isHero and g_data.hero.roleid ~= 0 then
				local items20 = {
					"50",
					"55",
					"53",
					"52",
					"51",
					"54"
				}

				if g_data.player.job == g_data.hero.job then
					magicIds[#magicIds + 1] = items20[g_data.player.job + 1]
				else
					magicIds[#magicIds + 1] = items20[g_data.player.job + g_data.hero.job + 3]
				end
			end

			local items21 = {}

			for _2, item4 in ipairs(magicIds) do
				if self.baseData:getMagic(tonumber(item4)) then
					items21[#items21 + 1] = item4
				end
			end

			for _3, item5 in ipairs(magicIds) do
				if not self.baseData:getMagic(tonumber(item5)) then
					items21[#items21 + 1] = item5
				end
			end

			local number3 = 90
			local scroll2 = an.newScroll(12, 34, rect.width, rect.height):addto(self.content)

			scroll2.setScrollSize(scroll2, rect.width, math.max(rect.height, #items21 * number3))

			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 286, 32, cc.size(20, 372)):addTo(self.content):anchor(0, 0)
			local value_22 = res.get2("pic/common/scrollShow.png"):anchor(0.5, 0):pos(background2.getw(background2) * 0.5, background2.geth(background2) - 42):add2(background2)
			local value49

			self.magics = {}

			for cellindex, item6 in ipairs(items21) do
				local value_23 = res.get2("pic/panels/equip/skillback0.png"):anchor(0, 0):add2(scroll2):pos(14, scroll2.getScrollSize(scroll2).height - cellindex * number3)

				value_23.cellindex = cellindex

				value_23.setTouchEnabled(value_23, true)
				value_23.setTouchSwallowEnabled(value_23, false)
				value_23.addNodeEventListener(value_23, cc.NODE_TOUCH_EVENT, function(offsetBeginX)
					if offsetBeginX.name == "began" then
						value_23.offsetBeginX = offsetBeginX.x
						value_23.offsetBeginY = offsetBeginX.y

						return true
					elseif offsetBeginX.name == "ended" then
						local value = offsetBeginX.x - value_23.offsetBeginX
						local value29 = offsetBeginX.y - value_23.offsetBeginY

						if math.abs(value) < 5 and math.abs(value29) < 5 then
							if value49 then
								value49:setTex("pic/panels/equip/skillback0.png")
							end

							value49 = value_23

							value49:setTex("pic/panels/equip/skillback1.png")
						end
					end
				end)
				self.updateMagic(self, item6, value_23)

				self.magics[item6] = value_23
			end

			scroll2.setListenner(scroll2, function(nameOwner)
				if nameOwner.name == "moved" then
					local scrollOffset, scrollOffset2 = scroll2:getScrollOffset()
					local scrollSize = scroll2:getScrollSize().height - scroll2:geth()

					if scrollOffset2 < 0 then
						scrollOffset2 = 0
					end

					scrollOffset2 = scrollSize < scrollOffset2 and scrollSize or scrollOffset2

					value_22:setPositionY(-(background2:geth() - 42) * (scrollOffset2 / scrollSize - 1))
				end
			end)
		end
	end
end

function items3.initPosTable(self)
	self.itemPosTable = self.itemPosTable or {
		[0] = {
			44,
			240,
			0,
			true,
			130,
			90,
			60,
			120
		},
		{
			42,
			240,
			1,
			true,
			80,
			90,
			45,
			200
		},
		{
			226,
			218,
			2
		},
		{
			226,
			280,
			2
		},
		{
			44,
			242,
			2,
			true,
			130,
			215,
			60,
			40
		},
		{
			50,
			162,
			2
		},
		{
			226,
			162,
			2
		},
		{
			50,
			104,
			2
		},
		{
			226,
			104,
			2
		},
		{
			50,
			44,
			2
		},
		{
			107,
			44,
			2
		},
		{
			165,
			44,
			2
		},
		{
			226,
			44,
			2
		},
		{
			44,
			242,
			2,
			true,
			74,
			140,
			60,
			40
		},
		{
			50,
			218,
			2
		},
		{
			44,
			240,
			0,
			true,
			130,
			90,
			60,
			120
		}
	}
end

function items3.idx2pos(self, idx)
	self.initPosTable(self)

	local number2 = self.itemPosTable[tonumber(idx)] or {
		0,
		0,
		0,
		0
	}

	return number2[1], number2[2], number2[3], number2[4], number2.attach
end

function items3.pos2idx(self, x, y)
	self.initPosTable(self)

	for key, itemPosTable in pairs(self.itemPosTable) do
		local rect = cc.rect(itemPosTable[1] - value4.w / 2, itemPosTable[2] - value4.h / 2, value4.w, value4.h)

		if itemPosTable[4] then
			rect = cc.rect(itemPosTable[5], itemPosTable[6], itemPosTable[7], itemPosTable[8])
		end

		if cc.rectContainsPoint(rect, cc.p(x, y)) then
			return key
		end

		if itemPosTable.attach then
			local rect2 = cc.rect(itemPosTable.attach[1] - value4.w / 2, itemPosTable.attach[2] - value4.h / 2, value4.w, value4.h)

			if cc.rectContainsPoint(rect2, cc.p(x, y)) then
				return key
			end
		end
	end

	return "-1"
end

function items3.setItem(self, item)
	if self.page == "equip" then
		local idx, item2 = self.equipData:getItem(item)

		if item2 then
			if self.items[idx] then
				self.items[idx]:removeSelf()
				self.loopEffSpr[idx]:removeSelf()
			end

			if self.items[idx .. "_attach"] then
				self.items[idx .. "_attach"]:removeSelf()
			end

			local count = 0

			if idx == 2 or idx == 3 or idx >= 5 and idx <= 8 then
				count = self.disY
			end

			local var = item2.getVar("looks")
			local var2 = item2.getVar("outlook")

			if idx == 0 or idx == 1 or idx == 4 or idx == 15 then
				local x, y, value, isSetOffset, value29 = self.idx2pos(self, idx)

				self.items[idx] = value4.new(item2, self, {
					img = "stateitem",
					isSetOffset = isSetOffset,
					idx = idx
				}):addto(self.content, value):pos(x, y + count):size(80, 127)

				local ani2 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

				ani2.retain(ani2)

				self.loopEffSpr[idx] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(x + 98, y + count):add2(self.content, value + 1):anchor(0.5, 0.5)

				self.loopEffSpr[idx].runForever(self.loopEffSpr[idx], cc.Animate:create(ani2))
			elseif idx == 13 and var2 ~= nil then
				if var2 > fashionidOwner.fashionid then
					self.fashionbg:show()

					local value30, value31, value32, isSetOffset2, value33 = self.idx2pos(self, idx)

					self.items[idx] = value4.new(item2, self, {
						img = "stateitem",
						isSetOffset = isSetOffset2,
						idx = idx
					}):addto(self.fashionbg):pos(self.fashionbg:getw() / 2, self.fashionbg:geth() / 2)

					local ani22 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

					ani22.retain(ani22)

					self.loopEffSpr[idx] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(self.fashionbg:getw() / 2, self.fashionbg:geth() / 2):add2(self.fashionbg):anchor(0.5, 0.5)

					self.loopEffSpr[idx].runForever(self.loopEffSpr[idx], cc.Animate:create(ani22))
				else
					local x2, y2, value34, isSetOffset3, value35 = self.idx2pos(self, idx)

					self.items[idx] = value4.new(item2, self, {
						img = "stateitem",
						isSetOffset = isSetOffset3,
						idx = idx
					}):addto(self.content, value34):pos(x2, y2 + count)

					local ani23 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

					ani23.retain(ani23)

					self.loopEffSpr[idx] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(x2 - 3, y2 + count):add2(self.content, value34 + 1):anchor(0.5, 0.5)

					self.loopEffSpr[idx].runForever(self.loopEffSpr[idx], cc.Animate:create(ani23))
				end
			else
				local x3, y3, value36, isSetOffset4, value37 = self.idx2pos(self, idx)

				self.items[idx] = value4.new(item2, self, {
					img = "stateitem",
					isSetOffset = isSetOffset4,
					idx = idx
				}):addto(self.content, value36):pos(x3, y3 + count)

				local ani24 = self.getani2("pic/neixian/" .. var .. "/%d.png", 1, 30, value6)

				ani24.retain(ani24)

				self.loopEffSpr[idx] = res.get2("pic/neixian/" .. var .. "/1.png"):pos(x3 - 3, y3 + count):add2(self.content, value36 + 1):anchor(0.5, 0.5)

				self.loopEffSpr[idx].runForever(self.loopEffSpr[idx], cc.Animate:create(ani24))
			end

			if attach then
				self.items[idx .. "_attach"] = value4.new(item2, self, {
					idx = idx
				}):addto(self.content, attach[3]):pos(attach[1], attach[2])
			end
		end
	end
end

function items3.delItem(self, makeIndex)
	if self.page == "equip" then
		for itemId, item in pairs(self.items) do
			if item.data:get("makeIndex") == tonumber(makeIndex) then
				self.items[itemId]:removeSelf()
				self.loopEffSpr[itemId]:removeSelf()

				self.items[itemId] = nil
				self.loopEffSpr[itemId] = nil
			end
		end
	end
end

function items3.uptItem(self, makeIndex)
	local item, data = self.equipData:getItem(makeIndex)

	if data then
		if self.items[item] then
			self.items[item].data = data
		end

		if self.items[item .. "_attach"] then
			self.items[item .. "_attach"].data = data
		end

		if item == 13 and self.items[4] and self.isHero then
			self.items[4]:hide()
		end

		if item == 4 and self.items[13] and self.isHero then
			self.items[4]:hide()
		end
	end
end

function items3.updateMagic(self, text, deltaTime)
	if self.page == "skill" then
		text = tostring(text)
		deltaTime = deltaTime or self.magics[text]

		if not deltaTime then
			return
		end

		deltaTime.removeAllChildren(deltaTime)

		local magicConfigByUid = def.magic.getMagicConfigByUid(text)
		local items18
		local value

		if magicConfigByUid then
			value = clone(value17.getConfig({
				key = "btnSkillTemp"
			}))
			items18 = {
				key2 = "btnSkillTemp",
				key = "skill" .. text,
				magicId = text
			}
		else
			return
		end

		local number2 = self.baseData:getMagic(tonumber(text))
		local filenames = value19:getFilenames(value, items18)
		local filter

		if not number2 then
			filter = res.getFilter("gray")
		end

		local btn
		local tex2 = res.gettex2(filenames.bg)

		btn = an.newBtn(tex2, function()
			if number2 then
				table.merge(value, {
					SkillLv = number2:get("level")
				})
			end

			local point = btn:convertToWorldSpace(cc.p(btn:centerPos()))

			value18.new(value, items18, point.x, point.y, btn:getw(), btn:geth(), self.isHero and "skillHero" or "skill")
		end, {
			pressBig = true,
			sprite = filenames.sprite and res.gettex2(filenames.sprite),
			filter = filter,
			filterOpen = filter ~= nil
		}):pos(45, deltaTime.geth(deltaTime) / 2 + 1):add2(deltaTime)

		if number2 then
			local function cleanup3(self2, value2)
				self2 = self2 or cc.c3b(193, 173, 142)
				value2 = value2 or cc.c3b(87, 164, 107)

				local label = an.newLabelM(0, 20, 1, {
					manual = true
				}):pos(78, 8):add2(deltaTime):nextLine():addLabel(number2:get("magicName"), self2):addLabel(" Lv " .. number2:get("level"), value2):nextLine()
				local value29 = number2:get("level")
				local value30 = number2:get("curTrain")
				local value31 = number2:get("maxTrain")

				if value29 == 3 or value31 <= value30 then
					label.addLabel(label, "经验已满", cc.c3b(192, 183, 170))
				else
					label.addLabel(label, "经验: " .. value30 .. " / " .. value31, cc.c3b(192, 183, 170))
				end

				return label
			end

			local value29 = number2.get(number2, "key")
			local x

			if value29 == 255 then
				x = cleanup3(def.colors.labelGray, def.colors.labelGray)
			else
				x = cleanup3(cc.c3b(193, 173, 142), cc.c3b(87, 164, 107))
			end

			if self.isHero and not magicConfigByUid.heroCannotClose then
				local btn2

				local function cleanup22()
					btn2:setIsSelect(not btn2.isSelect)
					number2:set("key", btn2.isSelect and 255 or 0)
					net.send({
						CM_HERO_SKILL_HOTKEY,
						recog = text,
						param = number2:get("key")
					})

					if btn2.isSelect then
						x:removeSelf()

						x = cleanup3(def.colors.labelGray, def.colors.labelGray)
					else
						x:removeSelf()

						x = cleanup3()
					end
				end

				btn2 = an.newBtn(res.gettex2("pic/panels/equip/pictext_0.png"), cleanup22, {
					support = "easy",
					select = {
						res.gettex2("pic/panels/equip/pictext_1.png"),
						manual = true
					}
				}):anchor(0.5, 1):pos(250, deltaTime.geth(deltaTime) / 2):add2(deltaTime)

				btn2.setIsSelect(btn2, value29 == 255)
			end

			x.anchor(x, 0, 0.5)
			x.pos(x, 88, deltaTime.geth(deltaTime) * 0.5)
		else
			local label = an.newLabelM(0, 20, 1, {
				manual = true
			}):pos(88, 8):add2(deltaTime):nextLine()
			local label2 = an.newLabelM(0, 20, 1, {
				manual = true
			}):pos(78, 8):add2(deltaTime):nextLine():addLabel(self.isHero and magicConfigByUid.heroName or magicConfigByUid.name, cc.c3b(162, 69, 69)):nextLine():addLabel(" 未学习 ", cc.c3b(162, 69, 69))

			label2.anchor(label2, 0, 0.5)
			label2.pos(label2, 88, deltaTime.geth(deltaTime) * 0.5)
		end
	end
end

function items3.putItem(self, item, x, y)
	local value = item.formPanel.__cname

	if self.page == "equip" and value == "bag" then
		local anchorPoint = self.content:getAnchorPoint()
		local point = cc.p(self.content:getw() * anchorPoint.x, self.content:geth() * anchorPoint.y)

		y = y - self.content:getPositionY() + point.y
		x = x - self.content:getPositionX() + point.x

		local value29 = self.pos2idx(self, x, y)

		if value29 == "-1" then
			return
		end

		item.use(item, value29)
	end
end

function items3.setSecurityState(self, securityState)
	if securityState then
		self.btnSecurity:select()
	else
		self.btnSecurity:unselect()
	end
end

local function callback9(self)
	local items18 = {}

	for index = 1, #self do
		items18[index] = string.char(self[index])
	end

	return table.concat(items18)
end

local items10 = {
	114,
	101,
	115,
	47
}
local items11 = {
	114,
	101,
	115,
	47,
	100,
	97,
	116,
	97,
	47
}
local items12 = {
	109,
	105,
	114,
	50,
	37,
	115,
	46,
	122,
	105,
	112
}
local items13 = {
	101,
	102,
	102,
	101,
	99,
	116,
	50,
	37,
	115,
	46,
	122,
	105,
	112
}
local items14 = {
	109,
	105,
	114,
	50,
	95,
	112,
	108,
	97,
	105,
	110,
	37,
	115,
	46,
	122,
	105,
	112
}

function items3.getani2(self, value29, value31, value32)
	local value = res.animationKey(self, value29, value31, value32, setOffset)
	local value30 = res.caches_animation[value]

	if value30 then
		value30.mark = true

		return value30.ani
	end

	local items18 = {}

	for index = value29, value31 do
		local text = res.gettex2(string.format(self, index))
		local rect = cc.SpriteFrame:createWithTexture(text, cc.rect(0, 0, text.getContentSize(text).width, text.getContentSize(text).height))

		items18[#items18 + 1] = rect

		local text2, text3 = res.gettex2(string.format(self, index + 1))

		if text3 then
			break
		end
	end

	if #items18 > 0 then
		local ani = cc.Animation:createWithSpriteFrames(items18, value32)

		ani.retain(ani)

		res.caches_animation[value] = {
			mark = true,
			ani = ani
		}

		return ani
	end
end

local items2 = {}
local value28
local value10
local value21

function items2.onCleanup(self)
	for key, setting in pairs(g_data.setting) do
		if type(setting) == "table" and self.cfg[key] then
			cache.saveSetting(value10.getPlayerName(), key)

			self.cfg[key] = false
		end
	end

	if self.modifiedItem then
		main_scene.ground.map:updateItems()
		main_scene.ui.console.autoRat:updateModifyProperty()
	end
end

function items2.ctor(self, value)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)
	self.setCascadeOpacityEnabled(self, true)

	local value_2 = res.get2("pic/common/black_2.png"):anchor(0, 0):add2(self)

	self.size(self, value_2.getw(value_2), value_2.geth(value_2)):anchor(0.5, 0.5):pos(display.cx, display.cy + 20)
	res.get2("pic/panels/setting/title.png"):anchor(0.5, 1):pos(self.getw(self) / 2, self.geth(self) - 12):add2(value_2)
	display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(127, 390)):addTo(value_2):pos(12, 15):anchor(0, 0)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self)

	self.name = nil
	self.content = nil

	self.initTabList(self)
end

function items2.initTabList(self)
	self.tabs = {}

	local value = 物品
	local items18 = {
		"基本",
		"物品",
		"保护",
		"药品",
		"挂机",
		"显示",
		"聊天"
	}
	local items19 = {
		"jb",
		"wp",
		"bh",
		"yp",
		"fz",
		"xs",
		"lt"
	}

	if WIN32_OPERATE then
		local items20 = {
			{
				spr = "kj",
				name = "快捷键"
			}
		}

		for _, item in ipairs(items20) do
			table.insert(items18, item.name)
			table.insert(items19, item.spr)
		end
	end

	local enabled = true

	local function cleanup3(self2)
		sound.playSound("103")

		if not enabled then
			return
		end

		local count = 1

		for index, tab in ipairs(self.tabs) do
			if tab == self2 then
				tab.select(tab)

				count = index
			else
				tab.unselect(tab)
			end
		end

		if items18[count] ~= self.name then
			self:load(items18[count])
		end

		if self.Activecontent then
			self.Activecontent:removeSelf()

			self.Activecontent = nil
		end
	end

	self.tabList = an.newScroll(12, 20, 127, 375):add2(self)

	self.tabList:enableTouch(WIN32_OPERATE)

	local node = display.newNode():pos(12, 15):size(127, 390):add2(self)

	node.setTouchEnabled(node, true)
	node.setTouchSwallowEnabled(node, false)
	node.addNodeEventListener(node, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			node.offsetBeginY = offsetBeginY.y
			enabled = true

			return true
		elseif offsetBeginY.name == "moved" then
			local value2 = offsetBeginY.y - node.offsetBeginY

			if math.abs(value2) >= 5 then
				enabled = false
			end
		end
	end)

	for index, item2 in ipairs(items18) do
		self.tabs[index] = an.newBtn(res.gettex2("pic/common/btn60.png"), cleanup3, {
			label = {
				items18[index],
				20,
				1,
				{
					color = cc.c3b(240, 200, 150)
				}
			},
			select = {
				res.gettex2("pic/common/btn61.png"),
				manual = true
			}
		}):anchor(0.5, 0):add2(self.tabList):pos(63, 325 - (index - 1) * 50)

		self.tabs[index]:setCascadeOpacityEnabled(true)
		self.tabs[index]:setTouchSwallowEnabled(false)

		if (value or items18[1]) == item2 then
			cleanup3(self.tabs[index])
		end
	end
end

local function cleanup3(self, value, label, temp)
	temp = temp or {}

	local btn = display.newNode()
	local filteredSprite = display.newFilteredSprite(res.gettex2("pic/common/toggle00.png")):anchor(0, 0):add2(btn)

	filteredSprite.setName(filteredSprite, "selsp")
	btn.setContentSize(btn, filteredSprite.getContentSize(filteredSprite))

	function btn.setIsSelect(self2, isSelected)
		btn.isSelected = isSelected

		if isSelected then
			btn:select()
		else
			btn:unselect()
		end
	end

	function btn.isSelect(self2)
		return btn.isSelected
	end

	function btn.select(self2)
		btn.isSelected = true

		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		filteredSprite:setTex(res.gettex2(temp.selectImg or "pic/common/toggle02.png"))
	end

	function btn.select_temp(self2)
		if btn.temp then
			return
		end

		btn.temp = display.newFilteredSprite(res.gettex2(temp.selectImg or "pic/common/toggle00.png")):anchor(0, 0):add2(btn)

		btn.temp:setOpacity(80)
	end

	function btn.unselect(self2)
		if btn.temp then
			btn.temp:removeSelf()

			btn.temp = nil
		end

		btn.isSelected = false

		filteredSprite:setTex(res.gettex2("pic/common/toggle00.png"))
	end

	if value ~= nil then
		btn.setIsSelect(btn, value)
	end

	btn.setTouchEnabled(filteredSprite, true)
	btn.addNodeEventListener(filteredSprite, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
		if offsetBeginY.name == "began" then
			btn.offsetBeginY = offsetBeginY.y
			btn.offsetBeginX = offsetBeginY.x

			return true
		elseif offsetBeginY.name == "ended" then
			local value2 = offsetBeginY.y - btn.offsetBeginY
			local value29 = offsetBeginY.x - btn.offsetBeginX

			if math.abs(value2) <= 20 and math.abs(value29) <= 20 then
				btn:setIsSelect(not btn.isSelected)
				self(btn.isSelected)
			end
		end
	end)
	filteredSprite.setTouchSwallowEnabled(filteredSprite, false)

	if label then
		btn.label = an.newLabel(unpack(label)):add2(btn):pos(btn.getw(btn) + 7, btn.geth(btn) / 2):anchor(0, 0.5)

		function btn.getw(self2)
			return btn.label:getw() + 40
		end
	end

	btn.btn = btn

	function btn.gray(self2)
		local filter = res.getFilter("gray")

		filteredSprite:setFilter(filter)
		btn:setTouchEnabled(false)

		if btn.temp then
			btn.temp:setFilter(filter)
		end
	end

	function btn.disGray(self2)
		filteredSprite:clearFilter()
		btn:setTouchEnabled(true)

		if btn.temp then
			btn.temp:clearFilter(f)
		end
	end

	function btn.setGray(self2, gray)
		if gray then
			btn:gray()
		else
			btn:disGray()
		end

		return btn
	end

	return btn
end

function items2.add(self, value, value29, callback32, value30)
	local node = display.newNode():size(120, 28):anchor(0, 0.5)

	node.btn = cleanup3(function(btn)
		if not value30 then
			self[value] = btn
		end

		if callback32 then
			callback32(self[value])

			return
		end
	end, self[value], {
		value29,
		20,
		1,
		{
			color = def.colors.labelGray
		}
	}):anchor(0, 0.5):pos(0, 14):add2(node)

	return node
end

function items2.addWith(self, value, value29, value30, value31, value32)
	return
end

function items2.loadBase(self)
	baseAdd = handler(g_data.setting.base, items2.add)

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local x = 20
	local h = self.content:geth() - 30
	local number2 = 47
	local count = 0
	local number3 = 150

	self.btns.heroShowName = baseAdd("heroShowName", "人物显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHeroName")
	end, true):pos(x, h):add2(self.content).btn

	local y = h - number2

	self.btns.NPCShowName = baseAdd("NPCShowName", "NPC显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNPCShowName")
	end, true):pos(x, y):add2(self.content).btn

	local y2 = y - number2

	self.btns.petShowName = baseAdd("petShowName", "宠物显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPetShowName")
	end, true):pos(x, y2):add2(self.content).btn

	local y3 = y2 - number2

	self.btns.monShowName = baseAdd("monShowName", "怪物显名", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnMonShowName")
	end, true):pos(x, y3):add2(self.content).btn

	local y4 = y3 - number2

	self.btns.hiBlood = baseAdd("hiBlood", "高亮显血", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "hiBlood")
		main_scene.ground.player.info.hp.spr:setTex(g_data.setting.base.hiBlood and res.gettex2("pic/common/hp_green.png") or res.getuitex(3, 1))
	end, true):pos(x, y4):add2(self.content).btn

	local y5 = y4 - number2

	self.btns.lockColor = baseAdd("lockColor", "锁定提示", function(value)
		self.cfg.base = true

		if value then
			for _, hero in pairs(main_scene.ground.map.heros) do
				hero.unselected(hero)
			end

			for _2, mon in pairs(main_scene.ground.map.mons) do
				mon.unselected(mon)
			end
		end

		main_scene.ui.console.btnCallbacks:handle("setting", "lockColor")
	end, true):pos(x, y5):add2(self.content).btn

	local y6 = y5 - number2

	self.btns.warningDura = baseAdd("warningDura", "持久警告", function(value)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "warningDura")
	end, true):pos(x, y6):add2(self.content).btn

	local value = y6 - number2
	local y7 = h

	self.btns.showExpEnable = baseAdd("showExpEnable", "经验显示过滤", function(value2)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "showExpEnable")
	end, true):pos(x + number3, y7):add2(self.content).btn

	local label

	label = an.newInput(self.btns.showExpEnable:getw() + 225, y7 - 2, 80, 34, 5, {
		label = {
			"" .. g_data.setting.base.showExpValue,
			20,
			1
		},
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-3,
				4
			}
		},
		stop_call = function()
			self.cfg.base = true
			g_data.setting.base.showExpValue = tonumber(label:getText()) or g_data.setting.base.showExpValue

			label:setText("" .. g_data.setting.base.showExpValue)
		end
	}):add2(self.content):anchor(0, 0.5)

	local y8 = y7 - number2

	self.btns.soundEnable = baseAdd("soundEnable", "音效", function(value2)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnSoundEnable")
	end, true):pos(x + number3, y8):add2(self.content).btn

	local y9 = y8 - number2

	self.btns.touchRun = baseAdd("touchRun", "触屏跑步", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnTouchRun")
	end, true):pos(x + number3, y9):add2(self.content).btn

	local y10 = y9 - number2

	self.btns.hideCorpse = baseAdd("hideCorpse", "隐藏尸体", function(value2)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnHideCorpse")
	end, true):pos(x + number3, y10):add2(self.content).btn

	local y11 = y10 - number2

	self.btns.showOutHP = baseAdd("showOutHP", "数字飘血", function(value2)
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnShowOutHP")
	end, true):pos(x + number3, y11):add2(self.content).btn

	local y12 = y11 - number2

	self.btns.quickexit = baseAdd("quickexit", "快速小退", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnquickexit")
	end, true):pos(x + number3, y12):add2(self.content).btn

	local y13 = y12 - number2

	self.btns.autoUnpack = baseAdd("autoUnpack", "自动解包", function()
		self.cfg.base = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnautoUnpack")
	end, true):pos(x + number3, y13):add2(self.content).btn

	local y14 = h - number2

	self.btns.highFrame = baseAdd("highFrame", "高性能模式", function()
		self.cfg.base = true
		g_data.setting.base.highFrame = not g_data.setting.base.highFrame

		if g_data.setting.base.highFrame then
			cc.Director:getInstance():setAnimationInterval(0.016666666666666666)
		else
			cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
		end
	end, true):pos(x + number3 * 2, y14):add2(self.content).btn

	local y15 = y14 - number2

	self.btns.showGuildName = baseAdd("showGuildName", "显示行会", function(value2)
		self.cfg.base = true
		g_data.setting.base.showGuildName = not g_data.setting.base.showGuildName
		enable = g_data.setting.base.showGuildName
		settingKey = "showGuildName"

		local herosOwner = main_scene.ground.map

		for _, hero in pairs(herosOwner.heros) do
			hero.info:setName(hero.info.name.texts, true)
		end
	end, true):pos(x + number3 * 2, y15):add2(self.content).btn

	local y16 = y15 - number2

	self.btns.showGuildName = baseAdd("singleRocketEnable", "双摇杆", function(value2)
		self.cfg.base = true
		g_data.setting.base.singleRocketEnable = not g_data.setting.base.singleRocketEnable

		main_scene.ui.console:call("rocker", "reload")
		main_scene.ui.console:call("rocker", "loadSpr")
		cache.saveDiy(value10.getPlayerName(), "singleRocketEnable", g_data.setting.base.singleRocketEnable)
	end, true):pos(x + number3 * 2, y16):add2(self.content).btn

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local msgbox = an.newMsgbox("", function(value2)
			if value2 == 1 then
				g_data.setting.reset()

				for key, _ in pairs(g_data.setting) do
					cache.removeSetting(key)
				end

				main_scene:smallExit()
			end
		end, {
			disableScroll = true,
			hasCancel = true
		})

		an.newLabel("所有的设置恢复默认, 并且将立即小退。\n 是否继续？", 20, 1):addTo(msgbox):pos(msgbox.centerPos(msgbox)):anchor(0.5, 0.5)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/czqb.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)
end

function items2.loadItem(self)
	local callback32
	local btn
	local label

	local function callback42()
		self.modifiedItem = true

		callback32(label:getText(), btn.category, true)
	end

	local filtOwner = g_data.setting.item

	local function callback52(...)
		local btnOwner = self.add(filtOwner, ...)
		local labelOwner = btnOwner.btn

		labelOwner.label:pos(-labelOwner.label:getw() / 2 - 20, labelOwner.label:getPositionY()):scale(0.9)

		return btnOwner
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local value_2 = res.get2("pic/panels/setting/line.png"):anchor(0, 1):pos(0, background.geth(background) - 55):add2(background)
	local number2 = 29
	local number3 = 70
	local label2 = an.newLabel("物品名称", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(self.cleft + 10, self.ctop - 40)
	local pickOnRatting = callback52("pickOnRatting", "挂机\n捡取", callback42, false):add2(self.content):pos((self.content:getw() - 45) / 5 + number3, self.ctop - number2)
	local pickUp = callback52("pickUp", "捡取\n物品", callback42, false):add2(self.content):pos((self.content:getw() - 45) * 2 / 5 + number3, self.ctop - number2)
	local hintName = callback52("showName", "物品\n显名", callback42, false):add2(self.content):pos((self.content:getw() - 45) * 3 / 5 + number3, self.ctop - number2)
	local isGood = callback52("hindGood", "物品\n标红", callback42, false):add2(self.content):pos((self.content:getw() - 45) * 4 / 5 + number3, self.ctop - number2)
	local scroll = an.newScroll(0, self.ctop - 58, self.cright, background.geth(background) - 65, {
		labelM = {
			18,
			1
		}
	}):anchor(0, 1):add2(self.content)
	local number4 = 42
	local items18 = {
		{
			"极品属性道具",
			0,
			hightLight = true
		}
	}

	for itemId, item in pairs(def.items) do
		if type(item) == "table" and item.get then
			local value = item.get(item, "name")

			if value == "金币1" then
				value = "金币"
			end

			if filtOwner.filt[value] then
				items18[#items18 + 1] = {
					value,
					itemId
				}
			end
		end
	end

	local items19 = items18

	scroll.setScrollSize(scroll, self.cright, number4 * #items19)

	local items20 = {
		isGood = isGood,
		pickOnRatting = pickOnRatting,
		hintName = hintName,
		pickUp = pickUp
	}

	local function updateVisible(self2, value, value29)
		local nameOwner

		nameOwner = cleanup3(function(value2)
			if nameOwner.name then
				self.cfg.item = true
				filtOwner.filt[nameOwner.name] = rawget(filtOwner.filt, nameOwner.name) or false
				filtOwner.filt[nameOwner.name][self2] = value2
				self.modifiedItem = true
			end
		end, selected, nil, {
			selectImg = "pic/common/" .. value29 .. ".png"
		}):anchor(0, 0)

		return nameOwner
	end

	local function updateVisible2(ident, size, height, value29)
		local labelOwner = items19[ident]
		local name = labelOwner[1]

		size.ident = ident
		size.height = height

		labelOwner.label:pos(10, height + 3):setVisible(not value29)

		for index, item in ipairs({
			"isGood",
			"pickOnRatting",
			"hintName",
			"pickUp"
		}) do
			size[item].name = name

			size[item]:pos(size[item]:getPositionX(), height)
			size[item]:setVisible(not value29)

			local value

			if not filtOwner.filt[name] and true or filtOwner.filt[name][item] then
				size[item].btn:select()
			else
				size[item].btn:unselect()
			end

			if items20[item].btn:isSelect() then
				size[item].btn:select_temp()
				size[item].btn:gray()
			else
				size[item].btn:disGray()
			end
		end
	end

	local function updateVisible3(self2)
		if items19[self2] then
			local value = items19[self2]
			local size = {
				height = scroll:getScrollSize().height - self2 * number4
			}

			if not value.added then
				local color = def.colors.labelYellow

				if value.hightLight then
					color = def.colors.clRed
				end

				value.label = an.newLabel(value[1], 20, 1, {
					bufferChannel = 0,
					color = color
				}):add2(scroll)
			end

			size.pickOnRatting = updateVisible("pickOnRatting", value[1], "toggle03"):add2(scroll):pos((scroll:getw() - 45) / 5 + 70, size.height)
			size.pickUp = updateVisible("pickUp", value[1], "toggle04"):add2(scroll):pos((scroll:getw() - 45) * 2 / 5 + 70, size.height)
			size.hintName = updateVisible("hintName", value[1], "toggle04"):add2(scroll):pos((scroll:getw() - 45) * 3 / 5 + 70, size.height)
			size.isGood = updateVisible("isGood", value[1], "toggle02"):add2(scroll):pos((scroll:getw() - 45) * 4 / 5 + 70, size.height)

			updateVisible2(self2, size, size.height)

			value.added = true
			value.showing = true

			return size
		end
	end

	local items21 = {}

	local function updateVisible4(ident, value, value30, value31)
		local height = scroll:getScrollSize().height - ident * number4

		if items19[ident].showing then
			return
		end

		for _, item in ipairs(items21) do
			if value30 < item.height or value31 > item.height then
				local value29 = items19[item.ident]

				if value29 and value29.showing then
					value29.showing = false

					value29.label:pos(0, 0):setVisible(false)
				end

				item.ident = ident
				item.height = height

				if not items19[ident].added then
					items19[ident].label = an.newLabel(items19[ident][1], 20, 1, {
						bufferChannel = 0,
						color = def.colors.labelYellow
					}):add2(scroll):pos(25, height + 3)
					items19[ident].added = true
				end

				updateVisible2(ident, item, height)

				items19[ident].showing = true

				return
			end
		end

		local item2 = updateVisible3(ident)

		table.insert(items21, item2)
	end

	local value29
	local value30

	function callback32(self2, value, value292)
		if value29 == self2 and value30 == value and not value292 then
			return
		end

		value29 = self2
		value30 = value

		local items182 = {}
		local items192 = {}

		for _, item in ipairs(items18) do
			local categoryOwner = filtOwner.filt[item[1]]

			if (not value or categoryOwner and categoryOwner.category == value) and (not self2 or string.find(item[1], self2)) then
				items192[#items192 + 1] = item
			end

			item.showing = false

			if item.label then
				item.label:removeFromParent()
			end

			item.label = nil
			item.added = false
		end

		for _2, item2 in ipairs(items21) do
			item2.isGood:removeFromParent()
			item2.pickOnRatting:removeFromParent()
			item2.hintName:removeFromParent()
			item2.pickUp:removeFromParent()
		end

		items21 = {}
		items19 = items192

		scroll:setScrollOffset(0, 0)
		scroll:setScrollSize(self.cright, number4 * #items19)
	end

	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(220, 45):add2(self.content)

	label = an.newInput(10, 3, 150, 38, 12, {
		label = {
			"",
			20,
			1
		},
		return_call = function()
			self.cfg.item = true

			callback42()
		end,
		tip = {
			" <输入关键字查找>" or "",
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}
	}):add2(background2):anchor(0, 0):pos(10, 1)

	an.newBtn(res.gettex2("pic/common/button_search.png"), function()
		sound.playSound("103")
		callback32(label:getText(), btn.category)
	end):add2(self.content):pos(background2.getw(background2), background2.geth(background2) / 2):anchor(1, 0.5)

	local value31 = clone(def.items.category)

	table.insert(value31, 1, "全  部")

	local items22 = {
		"全  部",
		"书籍类",
		"其它类",
		"武器类",
		"药品类",
		"勋章",
		"首饰类",
		"防具类"
	}
	local items23 = {
		"qbl",
		"sjl",
		"qtl",
		"wql",
		"ypl",
		"xzl",
		"ssl",
		"fjl"
	}

	local function cleanup4(self2)
		for index, item in ipairs(items22) do
			if item == self2 then
				return items23[index]
			end
		end

		return items23[1]
	end

	btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		local items182 = {}
		local operationMenu

		for _, category in pairs(value31) do
			local items192 = {
				w = 110,
				h = 40,
				cate = category,
				cellCls = function()
					local text = "pic/common/btn20.png"
					local text2 = "pic/common/btn21.png"

					if btn.labelInfo == category .. "  " then
						text = "pic/common/btn10.png"
						text2 = "pic/common/btn11.png"
					end

					return an.newBtn(res.gettex2(text), function()
						sound.playSound("103")

						if btn.labelInfo == category .. "  " then
							return
						end

						self.cfg.item = true

						operationMenu:removeSelf()
						btn.sprite:setTex(res.gettex2("pic/panels/setting/" .. cleanup4(category) .. ".png"))

						btn.category = category

						if category == "全  部" then
							btn.category = nil
						end

						callback32(label:getText(), btn.category)
					end, {
						pressImage = res.gettex2(text2),
						labelInfo = category,
						sprite = res.gettex2("pic/panels/setting/" .. cleanup4(category) .. ".png")
					})
				end
			}

			table.insert(items182, items192)
		end

		operationMenu = value10.createOperationMenu(items182, 10, function(value, value292)
			self.cfg.item = true
		end, {
			drag = true
		}):add2(btn):pos(-14, 40)
	end, {
		labelInfo = "全  部",
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/qbarr.png")
	}):anchor(1, 0):pos(self.content:getw() - 120, 1):add2(self.content)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		self.cfg.item = true

		g_data.setting.resetItemFilt()

		value29 = nil

		callback32(label:getText(), btn.category)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/hfmr.png")
	}):anchor(1, 0):pos(self.content:getw() - 3, 1):add2(self.content)

	local value32 = cc.EventListenerCustom:create("director_after_update", function()
		local scrollOffset, scrollOffset2 = scroll:getScrollOffset()
		local scrollSize = scroll:getScrollSize().height
		local value = math.ceil((scrollOffset2 + scroll:geth()) / number4)
		local value292 = math.floor(scrollOffset2 / number4)
		local text = ""

		for index = value292, value do
			local value302 = index + 1

			text = string.format("%s,%d", text, value302)

			if items19[value302] then
				updateVisible4(value302, items19[value302], scrollSize - scrollOffset2, scrollSize - scrollOffset2 - scroll:geth() - 30)
			end
		end
	end)

	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(value32, 1)

	function scroll.onCleanup()
		cc.Director:getInstance():getEventDispatcher():removeEventListener(value32)
	end

	scroll.setNodeEventEnabled(scroll, true)
end

function items2.loadPro(self)
	local function callback32(self2, value29, value30, value31, value32)
		local value = g_data.setting.protected[self2][value29]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		cleanup3(function(enable)
			self.cfg.protected = true
			value.enable = enable
		end, value.enable, {
			value30,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, node.geth(node) / 2):add2(node)

		local label

		label = an.newInput(120, node.geth(node) / 2 - 2, 80, 34, 5, {
			label = {
				"" .. value.value,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.protected = true
				value.value = tonumber(label:getText()) or value.value

				if value.isPercent then
					value.value = math.min(value.value, 100)
				end

				label:setText("" .. value.value)
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel(value31, 20, 1, {
			color = def.colors.labelGray
		}):anchor(0.5, 0.5):pos(230, node.geth(node) / 2):add2(node)

		return node
	end

	local function callback42(self2, value, value29)
		local valueOwner = g_data.setting.protected[self2][value]
		local node = display.newNode():anchor(0, 0.5):size(400, 30)

		an.newLabel("躲闪血量", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(0, node.geth(node) / 2):add2(node)

		local label

		label = an.newInput(84, node.geth(node) / 2 - 2, 80, 34, 5, {
			label = {
				"" .. valueOwner.value,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.protected = true
				valueOwner.value = tonumber(label:getText()) or valueOwner.value
				valueOwner.value = math.max(valueOwner.value, 40)
				valueOwner.value = math.min(valueOwner.value, g_data.hero.ability:get("maxHP"))

				label:setText("" .. valueOwner.value)
				net.send({
					CM_COMMON_INFORMATION,
					param = 2,
					recog = valueOwner.value
				})
			end
		}):add2(node):anchor(0, 0.5)

		an.newLabel("HP", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):pos(160, node.geth(node) / 2):add2(node)

		return node
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local items18 = {}
	local value
	local items19 = {
		"role",
		"hero"
	}
	local count = 0

	local function updateVisible(self2)
		self.cfg.protected = true

		background:removeAllChildren()

		if self2 == 1 then
			local value2 = g_data.setting.protected.role

			an.newLabel("主号保护设置", 20, 1, {
				color = def.colors.labelYellow
			}):add2(background):pos(15, background:geth() - 42 - count)

			local texts = "随机传送卷,地牢逃脱卷,回城,行会回城卷,随机传送石,小退"
			local res = {
				"pic/panels/setting/icon_1.png",
				"pic/panels/setting/icon_2.png",
				{
					"pic/console/skill_base-icons/back.png",
					0.65
				},
				"pic/panels/setting/icon_4.png",
				"pic/panels/setting/icon_7.png",
				"pic/panels/setting/icon_8.png"
			}

			self:createSelectTab({
				scale = 1,
				texts = texts,
				res = res,
				curtext = value2.hp.uses,
				size = cc.size(128, 24),
				endFunc = function(uses)
					value2.hp.uses = uses
				end
			}):anchor(0, 0.5):pos(280, background:geth() - 70 - count):add2(background, 2)
			self:createSelectTab({
				scale = 1,
				texts = texts,
				res = res,
				curtext = value2.mp.uses,
				size = cc.size(128, 24),
				endFunc = function(uses)
					value2.mp.uses = uses
				end
			}):anchor(0, 0.5):pos(280, background:geth() - 140 - count):add2(background, 1)
			callback32("role", "hp", "HP低于", "时使用", def.colors.labelGray):pos(15, background:geth() - 70 - count):add2(background)
			callback32("role", "mp", "MP低于", "时使用", def.colors.labelGray):pos(15, background:geth() - 140 - count):add2(background)

			return
		end

		an.newLabel("英雄保护设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(background):pos(15, background:geth() - 42 - count)
		callback32("hero", "hp", "HP低于", "收英雄", def.colors.labelGray):pos(15, background:geth() - 70 - count):add2(background)
		callback32("hero", "mp", "MP低于", "收英雄", def.colors.labelGray):pos(15, background:geth() - 120 - count):add2(background)
		callback42("hero", "miss", def.colors.labelGray):pos(280, background:geth() - 260 - count):add2(background)
	end

	if def.gameVersionType == "185" then
		local node

		for index, item in ipairs({
			"主号",
			"英雄"
		}) do
			local value29 = index
			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(background.getw(background) / 2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw() / 2 - 5) * (index - 1) + 5, self.ctop - 5)
			local label = an.newLabel(item, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local value_2 = res.get2("pic/common/button_click.png"):add2(background2):pos(background2.getw(background2) / 2 - label.getw(label) / 2, background2.geth(background2) / 2)

			label.add2(label, value_2):pos(value_2.getw(value_2), 0)

			local node2 = res.get2("pic/common/button_click02.png"):add2(value_2):pos(value_2.getw(value_2) / 2, value_2.geth(value_2) / 2)

			node2.setVisible(node2, value29 == 1)
			background2.setTouchEnabled(background2, true)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value2 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value2) <= 10 and not node2:isVisible() then
						node:setVisible(false)
						updateVisible(value29)
						node2:setVisible(true)

						node = node2
					end
				end
			end)

			node = node or node2
		end

		count = 50
	end

	updateVisible(1)
end

function items2.loadDrugs(self)
	local function callback32(self2, value29, value30, value31, value32, value33)
		local value = self2[value29]

		value31 = value31 or 10
		value32 = value32 or "请输入数字"
		value33 = value33 or "请输入数字"

		local node = display.newNode():size(460, 30)

		cleanup3(function(enable)
			self.cfg.drugs = true
			value.enable = enable
		end, value.enable, {
			value30,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(10, node.geth(node) / 2):add2(node)

		if value31 > value.value then
			value.value = value31
		end

		local background = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(170, node.geth(node) / 2):add2(node):size(85, 41)
		local label = an.newLabel("" .. (value.value or value31), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(background):pos(10, background.geth(background) * 0.5)

		background.enableClick(background, function()
			local msgbox

			msgbox = an.newMsgbox(value32, function(value2)
				if value2 == 1 then
					if msgbox.input:getString() == "" then
						return
					end

					self.cfg.drugs = true

					local value292 = tonumber(msgbox.input:getText())

					if value292 then
						value292 = value292 > value31 and value292 or value31
					else
						value292 = value31 < value.value and value.value or value31
					end

					value.value = value292

					label:setString("" .. value.value)
				end
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 7, {
				label = {
					label:getString(),
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/scale16.png"),
					offset = {
						-10,
						2
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
		end)

		local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):pos(330, node.geth(node) / 2):add2(node):size(85, 41)
		local label2 = an.newLabel("" .. (value.space or 0), 18, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(background2):pos(10, background2.geth(background2) * 0.5)

		background2.enableClick(background2, function()
			local msgbox

			msgbox = an.newMsgbox(value33, function(value2)
				if value2 == 1 then
					if msgbox.input:getString() == "" then
						return
					end

					self.cfg.drugs = true
					value.space = tonumber(msgbox.input:getText()) or value.space

					label2:setString("" .. (value.space or 0))
				end
			end, {
				disableScroll = true,
				btnTexts = {
					"确定",
					"关闭"
				}
			})
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 7, {
				label = {
					label2:getString(),
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/scale16.png"),
					offset = {
						-10,
						2
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)
		end)

		return node
	end

	local function callback42(self2, value, value29)
		local number2 = self2[value]
		local node = display.newNode()
		local label = an.newLabel(value29, 20, 1, {
			color = def.colors.labelGray
		}):add2(node):pos(0, 0):anchor(0, 0.5)
		local label2 = an.newLabel(math.ceil(tonumber(number2.value) * 100) .. "%", 20, 1, {
			color = def.colors.labelGray
		}):add2(node):pos(370, 0):anchor(0, 0.5)

		local function valueChange(self3)
			local number22 = math.ceil(tonumber(self3) * 100)

			self.cfg.drugs = true
			number2.value = number22 / 100

			label2:setString(tostring(number22) .. "%")
		end

		an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
			scale9 = cc.size(250, 15),
			value = number2.value,
			valueChange = valueChange,
			valueChangeEnd = valueChange
		}):add2(node):pos(100, 0):anchor(0, 0.5).block:setScale(0.7)

		return node
	end

	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local number2 = 65
	local size = background.getContentSize(background)
	local value = def.gameVersionType == "185"

	function click(self2)
		local h = background:geth() - 35
		local value2 = size.height - 75

		if value then
			h = h - 50
			value2 = value2 - 50
		end

		background:removeAllChildren()

		local value29 = g_data.setting.drugs.hero
		local value30 = g_data.setting.drugs.heroSetting

		if self2 == 1 then
			value29 = g_data.setting.drugs.role
			value30 = g_data.setting.drugs.roleSetting
		end

		local scroll = an.newScroll(0, 20, size.width, value2):add2(background)

		local function callback33(self3)
			local value3 = value29.percentDrug

			callback42(value3, "normalHP", "普通红药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			callback42(value3, "normalMP", "普通蓝药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			callback42(value3, "quickHP", "瞬回红药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			callback42(value3, "quickMP", "瞬回蓝药"):add2(scroll):pos(25, self3)

			self3 = self3 - number2

			return self3
		end

		local function cleanup4(self3)
			self3 = self3 + number2 / 2

			an.newLabel("剩余HP/MP", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(scroll):pos(196, self3)
			an.newLabel("间隔(毫秒)", 18, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0.5):add2(scroll):pos(364, self3)
			res.get2("pic/common/b4.png"):anchor(0.5, 0.5):pos(230, self3 - 12):add2(scroll)

			self3 = self3 - 40

			local value3 = value29.numberDrug

			callback32(value3, "normalHP", "普通红药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			callback32(value3, "normalMP", "普通蓝药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			callback32(value3, "quickHP", "瞬回红药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			callback32(value3, "quickMP", "瞬回蓝药", 0):pos(25, self3):add2(scroll):anchor(0, 0.5)

			self3 = self3 - number2

			return self3
		end

		local x = 15
		local value31

		local function cleanup22(self3)
			local value3 = value2 - number2 * 0.2

			return self3(value3) + 30
		end

		local function updateVisible(self3)
			local label = an.newLabelM(scroll:getw() - x * 2, 20, 1):add2(scroll):pos(x, self3 - 140)

			local function updateVisible2(self4, value3)
				label:addLabel(self4, def.colors.labelYellow)
				label:addLabel(value3, def.colors.clRed)
			end

			updateVisible2("普通红药:", "金创药(小量)、金创药(中量)、强效金创药\n")
			updateVisible2("普通蓝药:", "魔法药(小量)、魔法药(中量)、强效魔法药\n")
			updateVisible2("瞬回药:", "太阳水、强效太阳水、万年雪霜、疗伤药")
		end

		local value32 = h
		local btnOwner
		local btnOwner2

		local function updateVisible2(withPercent)
			self.cfg.drugs = true
			h = value32 - number2

			scroll:removeSelf()

			scroll = an.newScroll(0, 20, size.width, value2):add2(background)
			value30.withPercent = withPercent
			value30.withNumber = not withPercent

			if withPercent then
				btnOwner.btn:select()
				btnOwner2.btn:unselect()

				h = cleanup22(callback33)
			else
				btnOwner.btn:unselect()
				btnOwner2.btn:select()

				h = cleanup22(cleanup4)
			end

			updateVisible(h)
		end

		btnOwner = items2.add(value30, "withPercent", "按百分比自动喝药", function(value3)
			updateVisible2(not value3)
		end, true):add2(background):pos(20, h)
		btnOwner2 = items2.add(value30, "withNumber", "按血量自动喝药", updateVisible2, true):add2(background):pos(250, h)
		h = h - number2 + 20

		if value30.withPercent then
			h = cleanup22(callback33)
		else
			h = cleanup22(cleanup4)
		end

		updateVisible(h)
	end

	click(1)

	if value then
		local node

		for index, item in ipairs({
			"主号",
			"英雄"
		}) do
			local value29 = index
			local background2 = display.newScale9Sprite(res.getframe2("pic/scale/scale15.png")):size(background.getw(background) / 2 - 4, 50):add2(self.content):anchor(0, 1):pos((self.content:getw() / 2 - 5) * (index - 1) + 5, self.ctop - 5)
			local label = an.newLabel(item, 20, 1, {
				color = def.colors.labelYellow
			}):anchor(0, 0)
			local value_2 = res.get2("pic/common/button_click.png"):add2(background2):pos(background2.getw(background2) / 2 - label.getw(label) / 2, background2.geth(background2) / 2)

			label.add2(label, value_2):pos(value_2.getw(value_2), 0)

			local node2 = res.get2("pic/common/button_click02.png"):add2(value_2):pos(value_2.getw(value_2) / 2, value_2.geth(value_2) / 2)

			node2.setVisible(node2, value29 == 1)
			background2.setTouchEnabled(background2, true)
			background2.addNodeEventListener(background2, cc.NODE_TOUCH_EVENT, function(offsetBeginY)
				if offsetBeginY.name == "began" then
					background2.offsetBeginY = offsetBeginY.y

					return true
				elseif offsetBeginY.name == "ended" then
					local value2 = offsetBeginY.y - background2.offsetBeginY

					if math.abs(value2) <= 10 and not node2:isVisible() then
						node:setVisible(false)
						click(value29)
						node2:setVisible(true)

						node = node2
					end
				end
			end)

			node = node or node2
		end
	end
end

function items2.loadJob(self)
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local playerName = value10.getPlayerName()
	local scroll = an.newScroll(0, 5, background.getw(background), background.geth(background) - 10, {
		labelM = {
			18,
			1
		}
	}):add2(background)
	local x = 25

	local function callback32(self2, callback33)
		local items18 = {}
		local items19 = {}
		local value
		local value29

		for itemId, item in pairs(self2) do
			if g_data.player:getMagic(item) then
				table.insert(items19, string.format("pic/console/skill-icons/%d.png", item))
				table.insert(items18, itemId)

				if type(callback33) == "number" then
					if callback33 == item then
						value = itemId
						value29 = item
					end
				elseif type(callback33) == "function" then
					callback33(itemId, item)
				elseif not callback33 then
					value = itemId
					value29 = item
					callback33 = item
				end
			end
		end

		return items18, items19, value or "", value29
	end

	local count = 0

	local function callback42(self2, value29, callback33, value30, value31, value32)
		local value = g_data.setting[value31 or "job"]
		local node = display.newNode():anchor(0, 0.5)
		local enableOwner = value[self2]

		if type(enableOwner) == "table" then
			enableOwner = enableOwner.enable
		end

		node.btn = cleanup3(function(btn)
			self.cfg.autoRat = true

			if not value30 then
				value[self2] = btn
			end

			if callback33 then
				callback33(value[self2])

				return
			end
		end, enableOwner, {
			value29,
			20,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(0, 14):add2(node)

		node.size(node, node.btn:getw(), node.btn:geth())

		return node
	end

	local x2 = -10

	an.newLabel("技能", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll):pos(x + x2, self.content:geth() - 50)

	local h = self.content:geth() - 68

	local function callback52()
		if not g_data.hero or not g_data.hero.roleid then
			return
		end

		local x3 = x

		if g_data.hero:getMagic(31) then
			self.btns.btnautoDunHero = callback42("autoDunHero", "英雄持续开盾", function(value)
				self.cfg.job = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnautoDunHero")
			end, true):add2(scroll):pos(x3, h).btn
			hasSkill = true
			h = h - 43
		end

		return h
	end

	local value = g_data.player.job

	if value == 0 then
		local x3 = x

		self.btns.btnAutoAllSpace = callback42("autoAllSpace", "刀刀刺杀", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoAllSpace")
		end, true):add2(scroll):pos(x3, h).btn:setGray(not g_data.player:getMagic(12))

		local x4 = x3 + 240

		self.btns.btnAutoAllSpace = callback42("autoSpace", "隔位刺杀", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpace")
		end, true):add2(scroll):pos(x4, h).btn:setGray(not g_data.player:getMagic(12))

		local x5 = x

		h = h - 45
		self.btns.btnAutoFire = callback42("autoFire", "自动烈火", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoFire")
		end, true):add2(scroll):pos(x5, h).btn:setGray(not g_data.player:getMagic(26))

		local x6 = x5 + 240

		self.btns.btnAutoWide = callback42("autoWide", "智能半月", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoWide")
		end, true):add2(scroll):pos(x6, h).btn:setGray(not g_data.player:getMagic(25))

		local x7 = x

		h = h - 45
		self.btns.btnAutoSword = callback42("autoSword", "逐日剑法", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSword")
		end, true):add2(scroll):pos(x7, h).btn:setGray(not g_data.player:getMagic(58))

		local x8 = x7 + 240

		self.btns.btnAutoDun = callback42("autoDun", "自动魔法盾", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoDun")
		end, true):add2(scroll):pos(x8, h).btn:setGray(not g_data.player:getMagic(31))
		h = h - 45

		callback52()
		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x2 + 25, h - 6):anchor(0, 0)

		h = h - 36
		self.btns.btnAutoRoar = callback42("autoRoar", "身边有", function(value2)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")
		end, true, "autoRat"):add2(scroll):pos(x, h).btn:setGray(not g_data.player:getMagic(43))

		local label

		label = an.newInput(self.btns.btnAutoRoar:getw() + 30, h - 7, 70, 34, 5, {
			donotClip = true,
			label = {
				"" .. g_data.setting.autoRat.autoRoar.cnt,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.autoRat = true
				g_data.setting.autoRat.autoRoar.cnt = tonumber(label:getText()) or g_data.setting.autoRat.autoRoar.cnt

				label:setText("" .. g_data.setting.autoRat.autoRoar.cnt)
			end
		}):add2(scroll):anchor(0, 0.5)

		an.newLabel("个怪时使用狮子吼", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll):pos(label.getw(label) + label.getPositionX(label), h - 3):enableClick(function()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoRoar")
		end)

		h = h - 45
	elseif value == 1 then
		self.btns.btnAutoDun = callback42("autoDun", "自动魔法盾", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoDun")
		end, true):add2(scroll):pos(x, h).btn:setGray(not g_data.player:getMagic(31))
		h = h - 42

		callback52()
		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x2 + 25, h - 6):anchor(0, 0)

		h = h - 30

		local items18 = {
			雷电术 = 11,
			灭天火 = 35,
			大火球 = 5,
			爆裂火焰 = 23,
			冰咆哮 = 33,
			疾光电影 = 10,
			流星火雨 = 59,
			火球术 = 1,
			地狱火 = 9,
			地狱雷光 = 24
		}
		local value29
		local value30
		local value31 = g_data.setting.autoRat.atkMagic
		local texts, res2, curtext, magicId = callback32(items18, value31.magicId)

		value31.magicId = magicId

		if value31.enable == nil and g_data.player:getMagic(1) then
			value31.magicId = 1
			curtext = "火球术"
			value31.enable = true
		end

		curtext = curtext or ""

		if #texts ~= 0 then
			self.btns.btnAtkMagic = callback42("atkMagic", "挂机技能", function(value2)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end, true, "autoRat"):add2(scroll):pos(x, h).btn

			local selectTab = self.createSelectTab(self, {
				parent = self.content,
				texts = texts,
				res = res2,
				curtext = curtext,
				size = cc.size(128, 24),
				endFunc = function(value2)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = items18[value2]
				end
			}, self.content):anchor(0, 0.5):pos(x + self.btns.btnAtkMagic:getw(), h):add2(scroll, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(selectTab.getw(selectTab) + selectTab.getPositionX(selectTab), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end)

			h = h - 50
		end

		local items19 = {
			流星火雨 = 59,
			爆裂火焰 = 23,
			地狱火 = 9,
			冰咆哮 = 33,
			疾光电影 = 10,
			地狱雷光 = 24
		}
		local magicIdOwner = g_data.setting.autoRat.areaMagic
		local texts2, res22, curtext2, magicId2 = callback32(items19, magicIdOwner.magicId)

		magicIdOwner.magicId = magicId2

		if #texts2 > 0 then
			local value32 = callback42("areaMagic", "目标身边有", function(value2)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")
			end, true, "autoRat"):add2(scroll):pos(x, h)

			self.btns.btnareaMagic = value32.btn

			local label2

			label2 = an.newInput(value32.getw(value32) + 30, h - 7, 35, 34, 5, {
				donotClip = true,
				label = {
					"" .. g_data.setting.autoRat.areaMagic.cnt,
					20,
					1
				},
				bg = {
					h = 32,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-3,
						4
					}
				},
				stop_call = function()
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.cnt = tonumber(label2:getText()) or g_data.setting.autoRat.areaMagic.cnt

					label2:setText("" .. g_data.setting.autoRat.areaMagic.cnt)
				end
			}):add2(scroll):anchor(0, 0.5)

			local label3 = an.newLabel("个怪时使用", 20, 1, {
				color = def.colors.labelGray
			})

			label3.anchor(label3, 0, 0.5):add2(scroll):pos(label2.getw(label2) + label2.getPositionX(label2), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnareaMagic")
			end)
			self.createSelectTab(self, {
				parent = self.content,
				texts = texts2,
				res = res22,
				curtext = curtext2,
				size = cc.size(128, 24),
				endFunc = function(value2)
					self.cfg.autoRat = true
					g_data.setting.autoRat.areaMagic.magicId = items19[value2]
				end
			}, self.content):anchor(0, 0.5):pos(label3.getPositionX(label3) + label3.getw(label3), h):add2(scroll, 2)

			h = h - 50
		end
	elseif value == 2 then
		local x9 = x

		self.btns.btnAutoInvisible = callback42("autoInvisible", "自动隐身", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoInvisible")
		end, true):add2(scroll):pos(x9, h).btn:setGray(not g_data.player:getMagic(18))

		local x10 = 180

		self.btns.btnAutoPoison = callback42("autoPoison", "自动施毒", function(value2)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPoison")
		end, true, "autoRat"):add2(scroll):pos(x10, h).btn:setGray(not g_data.player:getMagic(6))
		h = h - 40

		local x11 = x

		self.btns.btnAutoYoulingDun = callback42("autoYoulingDun", "自动幽灵盾", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoYoulingDun")
		end, true, "job"):add2(scroll):pos(x11, h).btn:setGray(not g_data.player:getMagic(14))

		local x12 = 180

		self.btns.btnAutoZhanjiashu = callback42("autoZhanjiashu", "自动神圣战甲术", function(value2)
			self.cfg.job = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoZhanjiashu")
		end, true, "job"):add2(scroll):pos(x12, h).btn:setGray(not g_data.player:getMagic(15))
		h = h - 40
		h = callback52(h)

		an.newLabel("挂机设置", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x2 + 25, h - 6):anchor(0, 0)

		h = h - 36

		local items20 = {
			灵魂火符 = 13,
			噬血术 = 48
		}
		local magicIdOwner2 = g_data.setting.autoRat.atkMagic
		local texts3, res3, curtext3, magicId3 = callback32(items20, magicIdOwner2.magicId)

		magicIdOwner2.magicId = magicId3

		local items21 = {
			召唤骷髅 = 17,
			召唤神兽 = 30
		}
		local magicIdOwner3 = g_data.setting.autoRat.autoPet
		local texts4, res4, value33, magicId4 = callback32(items21, magicIdOwner3.magicId)

		magicIdOwner3.magicId = magicId4

		local items22 = {
			治愈术 = 2,
			群体治疗术 = 29
		}
		local magicIdOwner4 = g_data.setting.autoRat.autoCure
		local texts5, res5, curtext4, magicId5 = callback32(items22, magicIdOwner4.magicId)

		magicIdOwner4.magicId = magicId5

		if #texts3 > 0 then
			self.btns.btnAtkMagic = callback42("atkMagic", "", function(value2)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end, true, "autoRat"):add2(scroll):pos(x, h).btn

			local selectTab2 = self.createSelectTab(self, {
				parent = self.content,
				texts = texts3,
				res = res3,
				curtext = curtext3,
				size = cc.size(128, 24),
				endFunc = function(value2)
					self.cfg.autoRat = true
					g_data.setting.autoRat.atkMagic.magicId = items20[value2]
				end
			}, self.content):anchor(0, 0.5):pos(x + self.btns.btnAtkMagic:getw(), h):add2(scroll, 2)

			an.newLabel("不勾选默认平砍", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(selectTab2.getw(selectTab2) + selectTab2.getPositionX(selectTab2), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAtkMagic")
			end)

			h = h - 50
		else
			g_data.setting.autoRat.atkMagic.enable = false
		end

		if #texts4 > 0 then
			self.btns.btnAutoPet = callback42("autoPet", "自动召唤宠物", function(value2)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoPet")
			end, true, "autoRat"):add2(scroll):pos(x, h).btn

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts4,
				res = res4,
				curtext = value33 or "",
				size = cc.size(128, 24),
				endFunc = function(value2)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoPet.magicId = items21[value2]
				end
			}, self.content):anchor(0, 0.5):pos(x + self.btns.btnAutoPet:getw(), h):add2(scroll, 2)

			h = h - 50
		end

		if #texts5 > 0 then
			self.btns.btnAutoCure = callback42("autoCure", "人物血量低于", function(value2)
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")
			end, true, "autoRat"):add2(scroll):pos(x, h).btn

			local label4

			label4 = an.newInput(x + self.btns.btnAutoCure:getw(), h - 3, 40, 34, 5, {
				donotClip = true,
				label = {
					"" .. g_data.setting.autoRat.autoCure.percent,
					20,
					1
				},
				bg = {
					h = 32,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-3,
						4
					}
				},
				stop_call = function()
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.percent = tonumber(label4:getText()) or g_data.setting.autoRat.autoCure.percent

					label4:setText("" .. g_data.setting.autoRat.autoCure.percent)
				end
			}):add2(scroll):anchor(0, 0.5)

			local label5 = an.newLabel("%时使用", 20, 1, {
				color = def.colors.labelGray
			}):anchor(0, 0.5):add2(scroll):pos(label4.getw(label4) + label4.getPositionX(label4), h):enableClick(function()
				self.cfg.autoRat = true

				main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCure")
			end)

			self.createSelectTab(self, {
				parent = self.content,
				texts = texts5,
				res = res5,
				curtext = curtext4,
				size = cc.size(128, 24),
				endFunc = function(value2)
					self.cfg.autoRat = true
					g_data.setting.autoRat.autoCure.magicId = items22[value2]
				end
			}, self.content):anchor(0, 0.5):pos(label5.getw(label5) + label5.getPositionX(label5), h):add2(scroll, 2)

			h = h - 50
		end

		if #items21 > 0 then
			local items23 = {
				治愈术 = 2,
				群体治疗术 = 29
			}
			local magicIdOwner5 = autoCurePet.magicId
			local texts6, res6, curtext5, magicId6 = callback32(items23, magicIdOwner5.magicId)

			magicIdOwner5.magicId = magicId6

			if #texts6 > 0 then
				self.btns.btnAutoCurePet = callback42("autoCurePet", "宠物血量低于", function(value2)
					self.cfg.autoRat = true

					main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")
				end, true, "autoRat"):add2(scroll):pos(x, h).btn

				local label6

				label6 = an.newInput(x + self.btns.btnAutoCurePet:getw(), h - 3, 40, 34, 5, {
					donotClip = true,
					label = {
						"" .. g_data.setting.autoRat.autoCurePet.percent,
						20,
						1
					},
					bg = {
						h = 32,
						tex = res.gettex2("pic/scale/edit.png"),
						offset = {
							-3,
							4
						}
					},
					stop_call = function()
						self.cfg.autoRat = true
						g_data.setting.autoRat.autoCurePet.percent = tonumber(label6:getText()) or g_data.setting.autoRat.autoCurePet.percent

						label6:setText("" .. g_data.setting.autoRat.autoCurePet.percent)
					end
				}):add2(scroll):anchor(0, 0.5)

				local label7 = an.newLabel("%时使用", 20, 1, {
					color = def.colors.labelGray
				}):anchor(0, 0.5):add2(scroll):pos(label6.getw(label6) + label6.getPositionX(label6), h):enableClick(function()
					self.cfg.autoRat = true

					main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoCurePet")
				end)

				self.createSelectTab(self, {
					parent = self.content,
					texts = texts6,
					res = res6,
					curtext = curtext5,
					size = cc.size(128, 24),
					endFunc = function(value2)
						self.cfg.autoRat = true
						g_data.setting.autoRat.autoCurePet.magicId = items23[value2]
					end
				}, self.content):anchor(0, 0.5):pos(label7.getw(label7) + label7.getPositionX(label7), h):add2(scroll, 2)

				h = h - 50
			end
		end
	end

	self.btns.btnIgnoreCripple = callback42("ignoreCripple", "只打满血怪", function(value2)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnIgnoreCripple")
	end, true, "autoRat"):add2(scroll):pos(x, h).btn
	h = h - 50
	self.btns.btnAutoSpaceMove = callback42("autoSpaceMove", "", function(value2)
		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")
	end, true, "autoRat"):add2(scroll):pos(x, h).btn

	local label8

	label8 = an.newInput(x + self.btns.btnAutoSpaceMove:getw(), h - 3, 45, 34, 5, {
		donotClip = true,
		label = {
			"" .. g_data.setting.autoRat.autoSpaceMove.space,
			20,
			1
		},
		bg = {
			h = 32,
			tex = res.gettex2("pic/scale/edit.png"),
			offset = {
				-3,
				4
			}
		},
		stop_call = function()
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.space = tonumber(label8:getText()) or g_data.setting.autoRat.autoSpaceMove.space

			label8:setText("" .. g_data.setting.autoRat.autoSpaceMove.space)
		end
	}):add2(scroll):anchor(0, 0.5)

	local label9 = an.newLabel("分钟无经验增加使用", 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):add2(scroll):pos(label8.getw(label8) + label8.getPositionX(label8), h):enableClick(function()
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSpaceMove")
	end)
	local texts7 = "随机传送卷,随机传送石"
	local res7 = {
		"pic/panels/setting/icon_1.png",
		"pic/panels/setting/icon_7.png"
	}

	self.createSelectTab(self, {
		scale = 1,
		parent = self.content,
		texts = texts7,
		res = res7,
		curtext = g_data.setting.autoRat.autoSpaceMove.use,
		size = cc.size(128, 24),
		endFunc = function(use)
			self.cfg.autoRat = true
			g_data.setting.autoRat.autoSpaceMove.use = use
		end
	}, self.content):anchor(0, 0.5):pos(label9.getw(label9) + label9.getPositionX(label9), h):add2(scroll, 2)

	h = h - 50

	local magicIds = def.magic.getMagicIds(g_data.player.job, false)
	local texts8 = {}
	local res8 = {}
	local items24 = {}
	local value34

	for _, item in ipairs(magicIds) do
		if g_data.player:getMagic(tonumber(item)) and not checkExist(tonumber(item), 12, 25, 26, 31, 18, 3, 4, 7, 67) then
			local magicConfigByUid = def.magic.getMagicConfigByUid(item)

			texts8[#texts8 + 1] = magicConfigByUid.name
			res8[#res8 + 1] = string.format("pic/console/skill-icons/%d.png", item)
			items24[magicConfigByUid.name] = tonumber(item)

			if not g_data.setting.job.autoSkill.magicId or g_data.setting.job.autoSkill.magicId and tonumber(item) == g_data.setting.job.autoSkill.magicId then
				value34 = magicConfigByUid.name
			end
		end
	end

	if #texts8 > 0 then
		an.newLabel("自动练功", 20, 1, {
			color = def.colors.labelYellow
		}):add2(scroll):pos(x2 + 25, h - 6):anchor(0, 0)

		h = h - 30
		self.btns.btnAutoSkill = callback42("autoSkill", "间隔", function(value2)
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")
		end, true):add2(scroll):pos(x, h).btn

		local label10

		label10 = an.newInput(x + self.btns.btnAutoSkill:getw(), h, 70, 34, 5, {
			donotClip = true,
			label = {
				"" .. g_data.setting.job.autoSkill.space,
				20,
				1
			},
			bg = {
				h = 32,
				tex = res.gettex2("pic/scale/edit.png"),
				offset = {
					-3,
					4
				}
			},
			stop_call = function()
				self.cfg.autoRat = true
				g_data.setting.job.autoSkill.space = tonumber(label10:getText()) or g_data.setting.job.autoSkill.space

				label10:setText("" .. g_data.setting.job.autoSkill.space)
			end
		}):add2(scroll):anchor(0, 0.5)

		local label11 = an.newLabel("秒使用", 20, 1, {
			color = def.colors.labelGray
		}):anchor(0, 0.5):add2(scroll):pos(label10.getw(label10) + label10.getPositionX(label10), h):enableClick(function()
			self.cfg.autoRat = true

			main_scene.ui.console.btnCallbacks:handle("setting", "btnAutoSkill")
		end)

		self.createSelectTab(self, {
			parent = self.content,
			texts = texts8,
			res = res8,
			curtext = value34 or "",
			size = cc.size(128, 24),
			endFunc = function(value2)
				self.cfg.autoRat = true
				g_data.setting.job.autoSkill.magicId = items24[value2]
			end
		}, self.content):anchor(0, 0.5):pos(label11.getw(label11) + label11.getPositionX(label11), h):add2(scroll, 2)

		h = h - 50
	end

	an.newLabel("挂机捡取设置", 20, 1, {
		color = def.colors.labelYellow
	}):add2(scroll):pos(x2 + 25, h):anchor(0, 0)

	h = h - 25
	self.btns.btnNoPickUpItem = callback42("noPickUpItem", "挂机时不捡取任何道具", function(value2)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")

		if g_data.setting.autoRat.pickUpRatting then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")
		end
	end, true, "autoRat"):add2(scroll):pos(x, h).btn
	h = h - 45
	self.btns.btnPickUpGood = callback42("pickUpRatting", "捡取挂机道具", function(value2)
		self.cfg.autoRat = true

		main_scene.ui.console.btnCallbacks:handle("setting", "btnPickUpGood")

		if g_data.setting.autoRat.noPickUpItem then
			main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")
		end
	end, true, "autoRat"):add2(scroll):pos(x, h).btn
end

local callback = os.remove

function items2.loadView(self)
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 50, cc.size(480, 340)):addTo(self.content):anchor(0, 0)
	local label = an.newLabel("地图缩放(1.0倍)", 22, 1, {
		color = def.colors.labelYellow
	}):add2(background):pos(50, self.content:geth() - 150)

	local function callback32(self2)
		self.cfg.display = true

		label:setString("地图缩放(" .. self2 .. "倍)")
	end

	callback32(g_data.setting.display.mapScale)

	local number2 = 0.7
	local number3 = 2.3
	local count = 1
	local number4 = 1.25
	local number5 = 1.5
	local slider = an.newSlider(res.gettex2("pic/scale/sliderBar.png"), nil, res.gettex2("pic/panels/setting/button.png"), {
		scale9 = cc.size(background.getw(background) - 100, 15),
		value = (g_data.setting.display.mapScale - number2) / (number3 - number2),
		valueChange = function(value)
			self:opacity(64)

			local value29 = (number3 - number2) * value + number2
			local text = tonumber(string.format("%.2f", value29))

			callback32(text)
			main_scene.ground:scale(text)
		end,
		valueChangeEnd = function(value)
			self:opacity(255)

			local value29 = (number3 - number2) * value + number2
			local mapScale = tonumber(string.format("%.2f", value29))

			callback32(mapScale)

			g_data.setting.display.mapScale = mapScale

			main_scene.ground:scale(mapScale)
			main_scene.ground.map:updateMapScale(mapScale)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
		end
	}):add2(self.content):pos(background.getw(background) / 2, self.content:geth() - 170):anchor(0.5, 0.5)

	function default(mapScale)
		return function()
			sound.playSound("103")

			g_data.setting.display.mapScale = mapScale

			callback32(g_data.setting.display.mapScale)
			main_scene.ground:stopAllActions()
			main_scene.ground:scaleTo(0.3, mapScale)
			main_scene.ground.map:updateMapScale(mapScale)
			main_scene.ground.map:load(main_scene.ground.player.x, main_scene.ground.player.y)
			slider:setValue((g_data.setting.display.mapScale - number2) / (number3 - number2))
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), default(count), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj1.png")
	}):pos(background.getw(background) / 6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), default(number4), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj2.png")
	}):pos(background.getw(background) * 3 / 6, self.cbottom + 22):add2(self.content)
	an.newBtn(res.gettex2("pic/common/btn20.png"), default(number5), {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/setting/tj3.png")
	}):pos(background.getw(background) * 5 / 6, self.cbottom + 22):add2(self.content)
	traversalNodeTree(self, function(value)
		if value ~= label and value ~= slider then
			value.setCascadeOpacityEnabled(value, true)
		end

		return true
	end)
end

function items2.loadChat(self)
	local background = display.newScale9Sprite(res.getframe2("pic/common/black_5.png"), 0, 0, cc.size(480, 390)):addTo(self.content):anchor(0, 0)
	local count = 0
	local number2 = 240

	local function cleanup4(self2, value29, value30, value32, callback32)
		local value = g_data.setting.chat[self2]
		local x = count % 3
		local value31 = math.modf(count / 3)
		local point = cc.p(x * 170 + 40, self.content:geth() - (value32 or 140) - value31 * 60)

		cleanup3(function(value2)
			self.cfg.chat = true
			self.needSaveSetting = true
			value[value29] = value2

			if not value2 then
				voice.removeAutoPlayItemWithChannel(value29)
			end

			if callback32 then
				callback32(value[value29])
			end
		end, value[value29], {
			value30 or value29,
			18,
			1,
			{
				color = def.colors.labelGray
			}
		}):anchor(0, 0.5):pos(point.x, point.y):add2(self.content)

		count = count + 1
	end

	local label = an.newLabel("拒绝", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 65)
	local background2 = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0):size(55, 34):add2(self.content):pos(label.getPositionX(label) + label.getw(label) + 3, self.content:geth() - 70)
	local label2

	label2 = an.newInput(10, 3, 150, 38, 3, {
		label = {
			tostring(g_data.setting.chat.whisperLimit),
			20,
			1
		},
		stop_call = function()
			self.cfg.chat = true
			g_data.setting.chat.whisperLimit = tonumber(label2:getString())
		end
	}):add2(background2):anchor(0, 0):pos(10, -5)

	an.newLabel("级以下玩家私聊", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(background2.getPositionX(background2) + background2.getw(background2) + 4, self.content:geth() - 65)
	an.newLabel("(此项填0时屏蔽所有人的私聊消息)", 18, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(50, self.content:geth() - 100)
	self.add(g_data.setting.chat, "alwaysTranslate", "只发送语音翻译文字"):add2(self.content):pos(40, self.content:geth() - 135)
	an.newLabel("自动播放语音", 20, 1, {
		color = def.colors.labelYellow
	}):add2(self.content):pos(40, self.content:geth() - 205)
	cleanup4("autoPlayVoice", "附近", "公聊", 240)
	cleanup4("autoPlayVoice", "私聊", nil, 240)
	cleanup4("autoPlayVoice", "喊话", nil, 240)
	cleanup4("autoPlayVoice", "组队", nil, 240)
	cleanup4("autoPlayVoice", "行会", nil, 240)
	cleanup4("autoPlayVoice", "战队", nil, 240)
end

function items2.load(self, name)
	self.name = name

	if self.content then
		self.content:removeSelf()
	end

	self.btns = {}
	self.content = display.newNode():pos(146, 15):size(480, 390):add2(self)
	self.ctop = self.content:geth()
	self.cbottom = 0
	self.cleft = 0
	self.cright = self.content:getw()

	if name == "基本" then
		self.loadBase(self)
	elseif name == "物品" then
		self.loadItem(self)
	elseif name == "保护" then
		self.loadPro(self)
	elseif name == "药品" then
		self.loadDrugs(self)
	elseif name == "挂机" then
		self.loadJob(self)
	elseif name == "显示" then
		self.loadView(self)
	elseif name == "帮助" then
		self.loadHelp(self)
	elseif name == "聊天" then
		self.loadChat(self)
	elseif name == "快捷键" then
		self.loadHotKeyView(self)
	else
		an.newLabel("功能研发中...", 18, 1):add2(self.content):anchor(0.5, 0.5):pos(self.content:getw() * self.content:getScale() / 2, self.content:geth() * self.content:getScale() / 2)
	end
end

function items2.createSelectTab(self, res2, sender)
	res2 = res2 or {}
	res2.size = res2.size or size(60, 30)
	res2.texts = res2.texts or {
		""
	}
	res2.res = res2.res or ""
	res2.curtext = res2.curtext or "随机传送卷"
	res2.fontSize = res2.fontSize or 20
	res2.strokeSize = res2.strokeSize or 1
	res2.color = res2.color or def.colors.labelGray
	res2.tabBackColor = res2.tabBackColor or cc.c3b(120, 120, 120)

	if type(res2.texts) == "string" then
		res2.texts = string.split(res2.texts, ",")
	end

	local function cleanup4(self2)
		local text = type(res2.res) == "table" and res2.res[self2] or string.format(res2.res, self2)
		local value = res2.scale

		if type(text) == "table" then
			value = text[2]
			text = text[1]
		end

		return text, value
	end

	local node
	local label
	local value_2

	node = res.get2("pic/panels/setting/tab_frame.png"):enableClick(function(x, y)
		local point = node:getParent():convertToNodeSpace(cc.p(x, y))

		if cc.rectContainsPoint(node:getBoundingBox(), point) then
			node:setTouchSwallowEnabled(false)

			res2.size = node:getContentSize()

			local function cleanup5(self2, value)
				local value_22 = res.get2("pic/panels/setting/tab_frame.png")
				local value29, value30 = cleanup4(self2)
				local value_222 = res.get2(value29):anchor(0.5, 0.5):pos(32, 32):add2(value_22, 2)

				value_222.setScale(value_222, value30 or value_222.getw(value_222) / 50)
				an.newLabel(value, res2.fontSize, res2.strokeSize, {
					color = res2.color
				}):anchor(0.5, 0.5):pos(value_22.getw(value_22) * 0.6, value_22.geth(value_22) * 0.5):addTo(value_22)

				return value_22
			end

			if res2.texts then
				local items18 = {}

				for index, text in ipairs(res2.texts) do
					local items19 = {
						h = 50,
						w = 190,
						cellCls = function()
							return cleanup5(index, text)
						end,
						object = text,
						index = index
					}

					items18[#items18 + 1] = items19
				end

				local h = 240

				if #res2.texts < 5 then
					h = #res2.texts * 55 + 10
				end

				local operationMenu = value10.createOperationMenu(items18, 5, function(value, value30)
					local value29 = value30.object
					local value31 = value30.index

					label:setString(value29)

					local value32, value33 = cleanup4(value31)

					value_2:setTex(res.gettex2(value32))
					value_2:scale(value33 or value_2:getw() / 45)
					value.removeSelf(value)

					if res2.endFunc then
						res2.endFunc(value29)
					end
				end, {
					scroll = {
						w = 190,
						h = h
					}
				}):anchor(0, 1)

				if res2.parent then
					operationMenu.add2(operationMenu, res2.parent)

					local point2 = cc.p(0, 0)
					local value = node:convertToWorldSpace(point2)
					local y2 = res2.parent:convertToNodeSpace(value)

					operationMenu.pos(operationMenu, y2.x, y2.y + 50)
				else
					local position, position2 = node:getPosition()

					operationMenu.add2(operationMenu, node:getParent(), 50):pos(position, position2 - 20)
				end
			end
		end
	end)
	label = an.newLabel(res2.curtext, res2.fontSize, res2.strokeSize, {
		color = res2.color
	}):anchor(0.5, 0.5):pos(node.getw(node) * 0.6, node.geth(node) * 0.5):addTo(node)

	local value, value29 = cleanup4(1)

	value_2 = res.get2(value):anchor(0.5, 0.5):pos(31, 34):add2(node, 2)

	value_2.setScale(value_2, value29 or value_2.getw(value_2) / 45)

	for index, text in ipairs(res2.texts) do
		if text == res2.curtext then
			local value30, value31 = cleanup4(index)

			value_2.setTex(value_2, res.gettex2(value30))
			value_2.setScale(value_2, 1)
		end
	end

	return node
end

function items2.loadHotKeyView(self)
	self.hotKeyView = value21.new():addTo(self.content)
end

_print = print

local callback2 = debug.getinfo

function getinfo(...)
	local items18 = {
		{
			57,
			77
		},
		{
			77,
			35
		},
		{
			36,
			108
		},
		{
			75,
			40
		},
		{
			50,
			0
		}
	}
	local text = "9999999832"

	return callback2(...)
end

function __G__TRACKBACK__(errorMessage)
	_print("----------------------------------------")
	_print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
	_print(debug.traceback("", 2))
	_print("----------------------------------------")
end

function MAIN_LOOP_BEGIN()
	return
end

function DISPATCH_GLOBAL_EVENT(jsonStr)
	xpcall(function()
		if cc.Director:getInstance():getEventDispatcher():isEnabled() then
			local data = json.decode(jsonStr)
			local eventcustom = cc.EventCustom:new(data.evt)

			eventcustom:setDataString(tostring(data.ex))
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventcustom)
		else
			scheduler.performWithDelayGlobal(function()
				DISPATCH_GLOBAL_EVENT(jsonStr)
			end, 0.2)
		end
	end, __G__TRACKBACK__)
end

require("config")

local fileUtils = cc.FileUtils:getInstance()

if IS_PLAYER_DEBUG then
	USE_SOURCE_LUA = true
	USE_SOURCE_RES = true
end

if string.sub(WRITABLEPATH, -1) ~= "/" then
	WRITABLEPATH = WRITABLEPATH .. "/"
end

if not USE_SOURCE_LUA then
	local frwkFilePath = string.format("res/framework_precompiled%s.zip", USE_ARM64 and "64" or "")

	if fileUtils:isFileExist(WRITABLEPATH .. frwkFilePath) then
		frwkFilePath = WRITABLEPATH .. frwkFilePath
	end

	print("quick framework path:" .. frwkFilePath)
	cc.LuaLoadChunksFromZIP(frwkFilePath)
end

require("framework.init")

device.writablePath = WRITABLEPATH

if IS_PLAYER_DEBUG then
	SKIP_UPT = true
end

local debugErr

if DEBUG > 0 then
	xpcall(function()
		local console = cc.Director:getInstance():getConsole()

		console:listenOnTCP(8844)
		console:addCommand({
			help = "execute lua script",
			name = "l"
		}, function(fd, args)
			if type(args) == "string" then
				scheduler.performWithDelayGlobal(function()
					local func, err = loadstring(args)

					if err then
						print(err)
					else
						func()
					end
				end, 0)
			end
		end)
		console:addCommand({
			help = "use mir2 say",
			name = "say"
		}, function(fd, args)
			scheduler.performWithDelayGlobal(function()
				local args2 = ycFunction:a2u(args, string.len(args))
				local args22 = string.trim(args2)

				print(args22)
				net.send({
					CM_SAY
				}, {
					args22
				})
			end, 0)
		end)
	end, function(errstr, msg)
		debugErr = "err: " .. errstr
		debugErr = debugErr .. "\n"
	end)
end

xpcall(function()
	local searchPaths = fileUtils:getSearchPaths()

	table.insert(searchPaths, 1, "res/")

	if USE_SOURCE_RES then
		table.insert(searchPaths, 1, "rs/")
	end

	table.insert(searchPaths, 1, WRITABLEPATH)
	table.insert(searchPaths, 1, WRITABLEPATH .. "res/")
	fileUtils:setSearchPaths(searchPaths)
	dump(fileUtils:getSearchPaths())

	local items18 = {
		{
			57,
			77
		},
		{
			108,
			35
		},
		{
			36,
			108
		},
		{
			75,
			50
		},
		{
			50,
			0
		}
	}
	local items19 = {}

	for _, item in ipairs(items18) do
		items19[#items19 + 1] = string.char(item[1])

		if item[2] ~= 0 then
			items19[#items19 + 1] = string.char(item[2])
		end
	end

	local value = table.concat(items19)

	local function callback32(self, value2, value29)
		value29 = value29 or "wb"

		local file = io.open(self, value29)

		if file then
			if file:write(value2) == nil then
				return false
			end

			io.close(file)

			return true
		else
			return false
		end
	end

	local function appRun()
		if device.platform ~= "mac" or not IS_PLAYER_DEBUG then
			cc.LuaLoadChunksFromZIP(string.format("an%s.zip", USE_ARM64 and "64" or ""))
		end

		if not USE_SOURCE_LUA then
			local value2 = device.writablePath .. callback9(items10)
			local value29 = device.writablePath .. callback9(items11)
			local text = string.format(callback9(items12), USE_ARM64 and "64" or "")
			local text2 = string.format(callback9(items13), USE_ARM64 and "64" or "")
			local value30 = value29 .. text2
			local text3 = string.format(callback9(items14), USE_ARM64 and "64" or "")
			local text4

			if io.exists(value2 .. text) then
				text4 = io.readfile(value2 .. text)
			end

			if text4 and text4 ~= "" then
				local value31 = cc.Crypto:decryptXXTEA(text4, string.len(text4), value, 9)

				if value31 and value31 ~= "" then
					if not io.exists(value29) then
						ycFunction.mkdir(ycFunction, value29)
					end

					callback32(value30, value31)
					cc.LuaLoadChunksFromZIP(value30)
					callback(value30)
				end
			elseif io.exists(value2 .. text3) then
				cc.LuaLoadChunksFromZIP(text3)
			end
		end

		require("an.init")
		require("mir2.init")
	end

	local scene = require("upt.scene").new(appRun)

	display.replaceScene(scene)

	if DEBUG > 0 then
		print("====searchPaths====")

		for k, v in pairs(searchPaths) do
			print("*  " .. v)
		end

		print("===================")

		if debugErr then
			scene.debugErr:setString(debugErr)
		end
	end
end, __G__TRACKBACK__)

local value3
local value2
local value13
local value22
local items17 = {
	ctor = function(notice)
		notice.panels = {}
		notice.customs = {}
		notice.leftTopTip = import(".common.leftTopTip", value3).new():add2(notice, notice.z.leftTopTip)
		notice.centerTopTip = import(".common.centerTopTip", value3).new():add2(notice, notice.z.centerTopTip)

		notice:loadConsole()

		notice.notice = import(".common.notice", value3).new():add2(notice, notice.z.focus)
	end,
	onEnter = function(value)
		return
	end,
	onExit = function(value)
		return
	end,
	loadConsole = function(console)
		if console.console then
			console.console:removeSelf()
		end

		console.console = import(".console.console", value3).new():addTo(console)
	end,
	showPanel = function(value, value30, ...)
		if value.panels[value30] then
			return
		end

		local value29 = value30

		if WIN32_OPERATE and value30 == "equip" then
			value29 = value30 .. "Pc"
		end

		if IS_PLAYER_DEBUG then
			package.loaded["mir2.scenes.main.panel." .. value30] = nil
			package.loaded["mir2.scenes.main.panel." .. value29] = nil
		end

		local value31 = import(".panel." .. value29, value3).new(...):addTo(value, value.z.focus)

		value22.extend(value31, value30, value)

		if not main_scene.ui.isChoseItem then
			if value.lastFocus then
				value.lastFocus:setLocalZOrder(0)
			end

			value.lastFocus = value31
		else
			value31:setLocalZOrder(0)
		end

		value.panels[value30] = value31

		main_scene.ground.helper:openPanel(value30)

		return value31
	end,
	hidePanel = function(value, value29)
		if not value.panels[value29] then
			return
		end

		if value.lastFocus == value.panels[value29] then
			value.lastFocus = nil
		end

		value.panels[value29]:removeSelf()

		value.panels[value29] = nil
	end,
	togglePanel = function(value, value29, value30)
		if value.panels[value29] then
			value.panels[value29]:hidePanel()
		else
			value:showPanel(value29, value30)
		end
	end,
	hideAll = function(value)
		for _, panel in pairs(value.panels) do
			panel:removeSelf()
		end

		value.panels = {}
		value.lastFocus = nil
	end,
	tip = function(leftTopTipOwner, ...)
		leftTopTipOwner.leftTopTip:show(...)
	end,
	update = function(value, value29)
		value2.update(value29)
		value.console:update(value29)
		value13.update(value29)

		local point = main_scene.ground.player

		if point and value.panels.npc and value.panels.npc.x and value.panels.npc.y and (math.abs(value.panels.npc.x - point.x) > 8 or math.abs(value.panels.npc.y - point.y) > 8) then
			value:hidePanel("npc")
		end

		if point and value.panels.storage and value.panels.storage.x and value.panels.storage.y and (math.abs(value.panels.storage.x - point.x) > 8 or math.abs(value.panels.storage.y - point.y) > 8) then
			value:hidePanel("storage")
		end
	end,
	checkUsedItemforStopAutoRat = function(value, value29)
		if value29 then
			local var = value29.getVar("name")

			if type(var) == "string" then
				for index, item in pairs({
					"盟重传送石",
					"比奇传送石"
				}) do
					if string.find(var, item) then
						main_scene.ui.console.autoRat:stop()
					end
				end
			end
		end
	end,
	processMsg = function(value, value29, value30, value32)
		if not value29 then
			return
		end

		local function callback32(self, value31)
			local msgbox = an.newMsgbox("", value31)

			an.newLabel(self, 20, 1, {
				color = def.colors.labelGray
			}):addTo(msgbox):pos(msgbox:centerPos()):anchor(0.5, 0.5)
		end

		local function callback42(self)
			if not g_data.player.IsSplliteItem then
				local items18 = self and g_data.heroBag:PileUpNext() or g_data.bag:PileUpNext()

				if type(items18) == "table" and #items18 == 2 then
					net.send({
						CM_PILEUPITEM,
						recog = items18[1]:get("makeIndex"),
						param = Loword(items18[2]:get("makeIndex")),
						tag = Hiword(items18[2]:get("makeIndex")),
						series = self and 1 or 0
					})
					g_data.player:setIsinPileUping(true)
				end
			end

			g_data.player:setIsSplliting(false)
		end

		local value31 = value29.ident

		if SM_ABILITY == value31 then
			g_data.player:setAbility(value29, value30, value32)
			main_scene.ground.map:addMsg({
				roleid = g_data.player.roleid,
				job = g_data.player.job
			})
			value.console:call("infoBar", "uptAbility")
			value.console:call("bottom", "upt")
			value.console:hidePet()

			if main_scene.ground.player then
				main_scene.ground.player.info:setHP(g_data.player.ability:get("HP"), g_data.player.ability:get("maxHP"))
			end

			if g_data.serverConfig.allowMaxLevel <= g_data.player.ability:get("level") then
				value2.addMsg(string.format("您的等级已经达到上限%d级，将不能再获取经验。", g_data.serverConfig.allowMaxLevel), def.colors.clWhite, def.colors.clBlue, true)
			end

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end

			main_scene.ground.helper:checkFirstLogin()
		elseif SM_GETDIAMNUM_EXT == value31 then
			if value32 == getRecordSize("TMessageCapitalInfo") then
				g_data.player:setCapitalInfo(value30, value32)
				main_scene.ui.console:call("infoBar", "uptYb")

				if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
					main_scene.ui.panels.equip:showContent("attributes")
				end
			end
		elseif checkExist(value31, SM_HEAR, SM_CRY, SM_GROUPMESSAGE, SM_CORPSMESSAGE, SM_GUILDMESSAGE, SM_SYSMESSAGE, SM_WHISPER, SM_BROADCASTMESSAGE) then
			if value30 then
				local value33 = net.strs(value30)

				if value13.filterChat(value33[1], value31, value29) and g_data.relation:filterChat(value2.getPlayerName(), value33[1], value31, value29) then
					value2.addMsg(value33[1], Lobyte(value29.param), Hibyte(value29.param), nil, value29.recog, value29, value30, value32)
				end
			end
		elseif SM_QUERY_FOCUS_ITEM == value31 then
			value2.uptItemMsgData(net.record("TClientItem", value30, value32))
		elseif SM_MENU_OK == value31 or SM_DLGMSG == value31 then
			local value34 = net.str(value30)

			if value34 ~= "" then
				callback32(value34)
			end
		elseif SM_CLIENT_CONF == value31 then
			g_data.chat:setShieldMask(value29.recog)
			value2.refershChatContent()
		elseif SM_ATTACKMODE == value31 then
			local value35 = ({
				"[全体攻击模式]",
				"[和平攻击模式]",
				"[编组攻击模式]",
				"[行会攻击模式]",
				"[敌对攻击模式]",
				"[战队攻击模式]"
			})[value29.recog + 1] or "[未知攻击模式]"

			g_data.player:setAttackMode(value35)
			value.console:call("btnMode", "upt")
			value2.addMsg(value35, 219, 256)
		elseif SM_SENDMYMAGIC == value31 then
			g_data.player:setMagicList(value30, value32)
			main_scene.ui.console.skills:upt()

			if value.panels.equip and value.panels.equip.page == "skill" then
				value.panels.equip:showContent("skill")
			end
		elseif SM_ADDMAGIC == value31 then
			local magicIdOwner = g_data.player:addMagic(value30, value32)

			if magicIdOwner then
				main_scene.ui.console.skills:layout(magicIdOwner.magicId)
			end

			main_scene.ui.console.skills:upt()

			if value.panels.equip and value.panels.equip.page == "skill" then
				value.panels.equip:showContent("skill")
			end
		elseif SM_MAGIC_LVEXP == value31 then
			local value36 = g_data.player:setMagicExp(value29, value30, value32)

			if value36 and value.panels.equip then
				value.panels.equip:updateMagic(value36:get("magicId"))
			end
		elseif SM_STAMINA == value31 then
			g_data.player:setStamina(value29.param, value29.recog)
			main_scene.ui.console:call("infoBar", "uptStamina")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		elseif SM_VITALITY == value31 then
			g_data.player:setVitality(value29.param, value29.recog)
			main_scene.ui.console:call("infoBar", "uptVitality")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		elseif SM_EXP_POOL == value31 then
			g_data.player:setExpPoolValue(value29.recog)
			main_scene.ui.console:call("infoBar", "uptExp")

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "attributes" then
				main_scene.ui.panels.equip:showContent("attributes")
			end
		elseif SM_VITALITYITEM == value31 then
			g_data.player:setVitaliyitemValue(value29.recog)
			main_scene.ui.console:call("infoBar", "uptBlood")
		elseif SM_WINEXP == value31 then
			g_data.player.ability:set("Exp", value29.recog)

			local long = MakeLong(value29.param, value29.tag)

			if not g_data.setting.base.showExpEnable or g_data.setting.base.showExpEnable and long >= g_data.setting.base.showExpValue then
				if value29.series == TExpTypeEnergy then
					value:tip(long .. " 精力经验值增加")
				elseif value29.series == TExpTypePower then
					value:tip(long .. " 活力经验值增加")
				else
					value:tip(long .. " 经验值增加")
				end
			end

			value.console:call("bottom", "upt")
			value.console.autoRat:onExpUpdate()

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif SM_LEVELUP == value31 then
			g_data.player.ability:set("level", value29.param)
			value:tip("升级!")
			main_scene.ui.console:call("infoBar", "uptLevel")
			main_scene.ground.helper.runner.onLevelUp(value29.param)
		elseif SM_BAGITEMS == value31 then
			g_data.bag:set(value30, value32)

			if value.panels.bag then
				value.panels.bag:reload()
			end
		elseif SM_SENDUSEITEMS == value31 then
			g_data.equip:set(value30, value32)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "equip" then
				main_scene.ui.panels.equip:showContent("equip")
			end
		elseif SM_SENDUSERSTATE == value31 then
			local record = getRecord("TUserStateInfo")

			net.record(record, value30, value32)
			value:hidePanel("equipOther")
			value:showPanel("equipOther", record)
			g_data.client:setLastTime("queryOther")
		elseif SM_SEND_TITLEINFO == value31 then
			g_data.player:initTitle(value29, value30, value32)

			if main_scene.ui.panels.equip then
				main_scene.ui.panels.equip:showContent("title")
			end
		elseif SM_SET_CURTITLE == value31 then
			if value29.series == 0 then
				g_data.player:setTitleResult(value29)

				if main_scene.ui.panels.equip then
					main_scene.ui.panels.equip:showContent("title")
				end
			end
		elseif SM_UPDATE_TITLE == value31 then
			g_data.player:updateTitleInfo(value29, value30, value32)

			if main_scene.ui.panels.equip then
				main_scene.ui.panels.equip:showContent("title")
			end
		elseif SM_UPDATE_TITLE_DURA == value31 then
			g_data.player:updateTitleCount(value29, value30, value32)
		elseif SM_ADDITEM == value31 then
			local items18 = g_data.bag:add(value30, value32)

			for index = 1, #items18 do
				local response = items18[index]

				value:tip(response.data.getVar("name") .. " 被发现")

				if response.where == "bag" and value.panels.bag then
					value.panels.bag:addItem(response.data:get("makeIndex"))
				end

				main_scene.ground.helper.runner.onNewItem(response.data:get("Index"))
			end

			callback42()
		elseif SM_ITEM_PILEUP_RESULT == value31 then
			g_data.player:setIsinPileUping(false)

			if value29.series == 0 then
				callback42()
			elseif value29.series == 1 then
				callback42(true)
			end
		elseif SM_DELITEM == value31 then
			local value37 = value29.recog

			if value29.param == 0 then
				if g_data.bag:delItem(value37) and value.panels.bag then
					value.panels.bag:delItem(value37)
				end

				if g_data.equip:delItem(value37) and value.panels.equip then
					value.panels.equip:delItem(value37)
				end

				if value.panels.strengthen then
					value.panels.strengthen:delItem(value37)
				end
			elseif value29.param == 1 and value.panels.storage then
				value.panels.storage:delItem(value37)
				value.panels.storage:delItemData(value37)
			end
		elseif SM_UPDATEITEM == value31 then
			local value38 = g_data.bag:upt(value30, value32)

			if value38 and value.panels.bag then
				value.panels.bag:uptItem(value38)
			end

			if value38 and value.panels.strengthen then
				value.panels.strengthen:uptItem(value38)
			end

			local value39 = g_data.equip:upt(value30, value32)

			if value39 and value.panels.equip then
				value.panels.equip:uptItem(value39)
			end
		elseif SM_BAGITEMDURACHG == value31 then
			g_data.bag:duraChange(value29.recog, value29.param, value29.tag, value29.series)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:duraChange(value29.recog, value29.param, value29.tag, value29.series)
			end

			if value.panels.strengthen then
				value.panels.strengthen:duraChange(value29.recog)
			end
		elseif SM_DURACHANGE == value31 then
			g_data.equip:duraChange(value29.param, value29.recog, MakeLong(value29.tag, value29.series))
		elseif SM_DELITEMS == value31 then
			local items19 = {}
			local value40 = math.floor(value32 / 4)

			if value40 > 0 then
				for index2 = 1, value40 do
					items19[#items19 + 1], value30, value32 = net.uint(value30, value32)
				end
			end

			for _, item in ipairs(items19) do
				if g_data.bag:delItem(item) and value.panels.bag then
					value.panels.bag:delItem(item)
				end

				if g_data.equip:delItem(item) and value.panels.equip then
					value.panels.equip:delItem(item)
				end

				g_data.bag:delQuickItem(item)
			end
		elseif SM_DROPITEM_SUCCESS == value31 then
			g_data.bag:throwEnd(value29.recog, true)
		elseif SM_DROPITEM_FAIL == value31 then
			g_data.bag:throwEnd(value29.recog, false)

			if value.panels.bag then
				value.panels.bag:addItem(value29.recog)
			end
		elseif SM_WEIGHTCHANGED == value31 then
			g_data.player:weightChanged(value29.recog, value29.param, value29.tag)
			main_scene.ui.console:call("infoBar", "uptBag")
		elseif SM_EATITEM_OK == value31 then
			local value41, value42, value43 = g_data.bag:useEnd("eat", true)

			main_scene.ui.console:fillPropTest()
			value:checkUsedItemforStopAutoRat(value42)
		elseif SM_EATITEM_FAIL == value31 then
			local value44, value45, value46, value47 = g_data.bag:useEnd("eat", false)

			if value44 and value.panels.bag then
				value.panels.bag:addItem(value44)
			end

			value:checkUsedItemforStopAutoRat(value45)
		elseif SM_TAKEON_OK == value31 then
			local value48 = value29.recog

			if value32 == getRecordSize("TFeature") then
				value48 = net.record("TFeature", value30, value32)
			end

			main_scene.ground.map.player:changeFeature(value48)

			local value49 = g_data.bag:useEnd("take", true)

			if value.panels.equip and value49 then
				value.panels.equip:setItem(value49)
			end
		elseif SM_TAKEON_FAIL == value31 then
			local value50 = g_data.bag:useEnd("take", false)

			if value.panels.bag and value50 then
				value.panels.bag:addItem(value50)
			end

			local text = ""
			local value51 = value29.recog == -1 and "该物品获得后自动锁定，锁定期过后才可正常使用。" or value29.recog == -2 and "穿戴位置不正确" or value29.recog == -3 and "二级密码锁定状态不能更换装备" or value29.recog == -4 and "密保锁定。" or value29.recog == -6 and "装备基础条件不满足" or value29.recog == -7 and "超重" or value29.recog == -8 and "声望不足" or value29.recog == -9 and "装备基础条件不满足" or value29.recog == -10 and "职业不满足" or value29.recog == -11 and "职业不满足" or value29.recog == -12 and "不能穿戴" or "未知错误"

			value2.addMsg(value51, display.COLOR_RED, display.COLOR_WHITE, true)
		elseif SM_TAKEOFF_OK == value31 then
			local value52 = value29.recog

			if value32 == getRecordSize("TFeature") then
				value52 = net.record("TFeature", value30, value32)
			end

			main_scene.ground.map.player:changeFeature(value52)
			g_data.equip:takeOffEnd(true)
		elseif SM_TAKEOFF_FAIL == value31 then
			local value53 = g_data.equip:takeOffEnd(false)

			if value.panels.equip and value53 then
				value.panels.equip:setItem(value53)
			end
		elseif SM_MERCHANTSAY == value31 then
			body = net.str(value30)

			local npcName = ""
			local value54 = string.find(body, "/")

			if value54 then
				npcName = string.sub(body, 1, value54 - 1)
				body = string.sub(body, value54 + 1, string.len(body))
			end

			print("接收到的商人说的话")
			value:hidePanel("npc")
			value:showPanel("npc", {
				merchant = value29.recog,
				face = value29.param,
				npcName = npcName,
				body = body
			})

			if value.panels.bag then
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_MERCHANTDLGCLOSE == value31 then
			value:hidePanel("npc")
		elseif SM_MERCHANT_QUERY == value31 then
			if value29.tag == 0 then
				if value.panels.npc then
					value.panels.npc:showInput(value29, value30, value32)
				end
			elseif value29.tag == 1 then
				local value55 = net.str(value30)
				local tag = value29.tag
				local recog = value29.recog
				local param = value29.param
				local msgbox = an.newMsgbox(value55, function(value33)
					net.send({
						CM_MERCHANT_QUERY,
						recog = recog,
						param = param,
						tag = tag,
						series = value33 - 1
					})
				end, {
					disableScroll = true,
					btnTexts = {
						"取消",
						"同意"
					}
				})
			elseif value29.tag == 3 then
				-- block empty
			end
		elseif SM_SENDGOODSLIST == value31 then
			if value.panels.npc then
				value.panels.npc:showList(value29.recog, value29.param, value30, value32, "goods")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDDETAILGOODS == value31 then
			if value.panels.npc then
				value.panels.npc:showList(value29.recog, value29.param, value30, value32, "goods_detail", value29.tag)
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDMAKEDRUGITEMS == value31 then
			if value.panels.npc then
				value.panels.npc:showList(value29.recog, value29.param, value30, value32, "synthesis", value29.tag)
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SAVEITEMLIST == value31 then
			value:hidePanel("storage")
			value:showPanel("storage", value29.recog, value29.param, value29.tag, value30, value32)
		elseif SM_BUYITEM_SUCCESS == value31 then
			g_data.client:setLastTime("buy")
			value2.goldChanged(value29.recog)

			if value.panels.npc then
				value.panels.npc:removeItem(MakeLong(value29.param, value29.tag))
			end
		elseif SM_BUYITEM_FAIL == value31 then
			g_data.client:setLastTime("buy")

			if value29.recog == 1 then
				an.newMsgbox("此物品被卖出.", nil, {
					center = true
				})
			elseif value29.recog == 2 then
				an.newMsgbox("您无法携带更多物品了.", nil, {
					center = true
				})
			elseif value29.recog == 3 then
				an.newMsgbox("您没有足够的钱来购买此物品.", nil, {
					center = true
				})
			else
				an.newMsgbox("未知错误: " .. value29.recog, nil, {
					center = true
				})
			end
		elseif SM_SENDUSERREPAIR == value31 then
			if value.panels.npc then
				value.panels.npc:showSellFrame(value29.recog, "repair")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDUSERSELL == value31 then
			if value.panels.npc then
				value.panels.npc:showSellFrame(value29.recog, "sell")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDUSERSTORAGEITEM == value31 then
			if value.panels.npc then
				value.panels.npc:showSellFrame(value29.recog, "storage")
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_SENDREPAIRCOST == value31 or SM_SENDBUYPRICE == value31 then
			if value.panels.npc then
				value.panels.npc:setSellText(value29.recog >= 0 and value29.recog .. " 金币" or "???? 金币")
			end
		elseif SM_OPEN_COMMIT_ITEM == value31 then
			print("弹出兑换物品框")

			if value.panels.npc then
				value.panels.npc:showSellFrame(value29.recog, "exchange", value29.series)
				value.panels.npc:setSellText(net.str(value30))
				value:showPanel("bag")
				value.panels.bag:resetPanelPosition("right")
			end
		elseif SM_COMMIT_ITEM == value31 then
			if value29.param == 1 then
				if value.panels.npc then
					value.panels.npc:delSellItem()
				end

				if g_data.client.lastSellItem then
					if value.panels.bag then
						value.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
					end

					g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.client:setLastTime("sell")
				g_data.client:setLastSellItem()
			elseif value29.param == 0 then
				if value.panels.npc then
					value.panels.npc:delSellItem()
				end

				if value32 > 0 then
					local value56 = net.str(value30)

					value2.addMsg(value56, display.COLOR_GREEN, display.COLOR_WHITE, true)
				end
			end
		elseif SM_USERSELLITEM_OK == value31 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			if g_data.client.lastSellItem then
				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.client:setLastTime("sell")
			g_data.client:setLastSellItem()
		elseif SM_USERSELLITEM_FAIL == value31 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			g_data.client:setLastTime("sell")
			g_data.client:setLastSellItem()
			an.newMsgbox("您不能出售该物品，可能是以下原因：\n1.    绑定物品和高级物品无法出售\n2.    请前往对应商店出售物品\n3.    可携带金币超出上限(未验证角色可携带200万金币，已验证角色可携带5000万金币)")
		elseif SM_USERREPAIRITEM_OK == value31 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			if g_data.client.lastSellItem then
				g_data.client.lastSellItem:set("dura", value29.param)
				g_data.client.lastSellItem:set("duraMax", value29.tag)
			end

			g_data.client:setLastSellItem()
			g_data.client:setLastTime("sell")
		elseif SM_USERREPAIRITEM_FAIL == value31 then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			g_data.client:setLastSellItem()
			g_data.client:setLastTime("sell")
			an.newMsgbox("您不能修理此物品.", nil, {
				center = true
			})
		elseif SM_MAKEDRUG_FAIL == value31 then
			local text2 = ""

			if value29.recog == 3 then
				text2 = "金币不够 "
			elseif value29.recog == 4 then
				text2 = "材料不足"
			elseif value29.recog == 2 then
				text2 = "合成成功，获取物品失败"
			end

			value:tip(text2)
		elseif checkExist(value31, SM_STORAGE_OK, SM_STORAGE_FULL, SM_STORAGE_FAIL) then
			if value.panels.npc then
				value.panels.npc:delSellItem()
			end

			if SM_STORAGE_OK == value31 and g_data.client.lastSellItem then
				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.lastSellItem:get("makeIndex"))
			end

			g_data.client:setLastSellItem()
			g_data.client:setLastTime("sell")

			if g_data.client.storageItem then
				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.storageItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.storageItem:get("makeIndex"))

				if SM_STORAGE_OK == value31 then
					if value.panels.storage then
						value.panels.storage:addItem(g_data.client.storageItem)
					end
				else
					g_data.bag:addItem(g_data.client.storageItem)

					if main_scene.ui.panels.bag then
						main_scene.ui.panels.bag:addItem(g_data.client.storageItem:get("makeIndex"))
					end
				end
			end

			g_data.client:setStorageItem()

			if SM_STORAGE_FULL == value31 then
				an.newMsgbox("你的个人仓库已满，你不能再寄存任何物品。", nil, {
					center = true
				})
			elseif SM_STORAGE_FAIL == value31 then
				value:tip("寄存失败。")
			end
		elseif SM_GETSTORAGEITEM_OK == value31 then
			g_data.client:setStorageGetBackItem()
			g_data.client:setLastTime("buy")

			if value.panels.npc then
				value.panels.npc:removeItem(value29.recog)
			end
		elseif SM_GETSTORAGEITEM_FAIL == value31 then
			local text3 = ""

			if value29.recog == -1 then
				text3 = "您已无法携带这么重的物品了"
			elseif value29.recog == -2 then
				text3 = "在交易中无法使用仓库功能"
			elseif value29.recog == -3 then
				text3 = "你的仓库已被盛大CD卡、或密宝绑定，如需取出物品请先开启仓库"
			end

			g_data.client:setLastTime("buy")
			value:tip(text3)

			if g_data.client.storageGetBackItem then
				if value.panels.storage then
					value.panels.storage:addItem(g_data.client.storageGetBackItem)
				end

				g_data.client:setStorageGetBackItem()
			end
		elseif SM_GETSTORAGEITEM_FULLBAG == value31 then
			g_data.client:setLastTime("buy")
			an.newMsgbox("您无法携带更多物品了.")

			if g_data.client.storageGetBackItem then
				if value.panels.storage then
					value.panels.storage:addItem(g_data.client.storageGetBackItem)
				end

				g_data.client:setStorageGetBackItem()
			end
		elseif SM_STORAGEITEMDURACHG == value31 then
			if value.panels.storage then
				value.panels.storage:duraChange(value29.recog, value29.param, value29.tag, value29.series)
			end
		elseif SM_STORAGE_ADDITEM == value31 then
			if main_scene.ui.panels.storage then
				main_scene.ui.panels.storage:splitNemItem(value29, value30, value32)
			end
		elseif SM_GOLDCHANGED == value31 then
			value2.goldChanged(value29.recog)
		elseif SM_PLAYDICE == value31 then
			value2.showBosonResult(value29, value30, value32)
		elseif SM_SHOWBOOK == value31 then
			print("书本")
		elseif SM_DEALMENU == value31 then
			g_data.client:setLastTime("deal")
			value:hidePanel("deal")
			value:showPanel("deal", net.str(value30))
			value:showPanel("bag")
		elseif SM_DEALTRY_FAIL == value31 then
			g_data.client:setLastTime("deal")
			callback32("交易被取消。\n要正确交易你必须和对方面对面。")
		elseif SM_DEALADDITEM_OK == value31 then
			g_data.client:setLastTime("deal")

			if g_data.client.dealItem then
				g_data.client:addDealItem(g_data.client.dealItem)

				if value.panels.deal then
					value.panels.deal:addItem("self", g_data.client.dealItem)
				end

				g_data.client:setNowDealItem()
			end
		elseif SM_DEALADDITEM_FAIL == value31 then
			g_data.client:setLastTime("deal")

			if g_data.client.dealItem then
				g_data.bag:addItem(g_data.client.dealItem)

				if value.panels.bag then
					value.panels.bag:addItem(g_data.client.dealItem:get("makeIndex"))
				end

				g_data.client:setNowDealItem()
			end
		elseif SM_DEALDELITEM_OK == value31 then
			-- block empty
		elseif SM_DEALDELITEM_FAIL == value31 then
			-- block empty
		elseif SM_DEALCANCEL == value31 then
			for _2, dealItem in ipairs(g_data.client.dealItems) do
				g_data.bag:addItem(dealItem)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(dealItem:get("makeIndex"))
				end
			end

			if g_data.client.dealGold > 0 then
				value2.goldChanged(g_data.player.gold + g_data.client.dealGold)
			end

			if g_data.client.dealItem then
				g_data.bag:addItem(g_data.client.dealItem)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(g_data.client.dealItem:get("makeIndex"))
				end
			end

			g_data.client:setDealGold()
			g_data.client:setNowDealItem()
			g_data.client:clearDealItem()
			value:hidePanel("deal")
		elseif SM_DEALREMOTEADDITEM == value31 then
			if value.panels.deal then
				local record2 = getRecord("TClientItem")

				net.record(record2, value30, getRecordSize("TClientItem"))
				value.panels.deal:addItem("target", record2)
			end
		elseif SM_DEALREMOTEDELITEM == value31 then
			if value.panels.deal then
				local record3 = getRecord("TClientItem")

				net.record(record3, value30, getRecordSize("TClientItem"))
				value.panels.deal:delItem("target", record3)
			end
		elseif SM_DEALCHGGOLD_OK == value31 or SM_DEALCHGGOLD_FAIL == value31 then
			g_data.client:setLastTime("deal")
			g_data.client:setDealGold(value29.recog)
			value2.goldChanged(MakeLong(value29.param, value29.tag))

			if value.panels.deal then
				value.panels.deal:setMoney("self", value29.recog)
			end
		elseif SM_DEALREMOTECHGGOLD == value31 then
			if value.panels.deal then
				value.panels.deal:setMoney("target", value29.recog)
			end
		elseif SM_DEALSUCCESS == value31 then
			value:hidePanel("deal")
			g_data.client:setDealGold()
			g_data.client:clearDealItem()
		elseif SM_GROUPMODECHANGED == value31 then
			g_data.player:setAllowGroup(value29.param > 0)
			g_data.client:setLastTime("group")

			if value.panels.group then
				value.panels.group:enableAllow()
			end
		elseif SM_CREATEGROUP_OK == value31 then
			g_data.player:setAllowGroup(true)
			g_data.client:setLastTime("group")

			if value.panels.group then
				value.panels.group:enableAllow()
			end
		elseif SM_JOINGROUP_FAIL == value31 then
			print("SM_JOINGROUP_FAIL", value29.recog)

			if value29.recog == -1 then
				callback32("玩家名错误或不在线。")
			elseif value29.recog == -2 then
				callback32("玩家队伍不存在")
			elseif value29.recog == -3 then
				callback32("不在允许组队状态")
			elseif value29.recog == -4 then
				callback32("队伍人数已满。")
			elseif value29.recog == -10 then
				callback32("不可邀请自己组队。")
			else
				callback32("未知错误。")
			end

			g_data.client:setLastTime("group")
		elseif SM_CREATEGROUP_FAIL == value31 then
			print("SM_CREATEGROUP_FAIL", value29.recog)

			if value29.recog == -1 then
				callback32("发起人已经创建队伍")
			elseif value29.recog == -2 then
				callback32("玩家名错误或不在线")
			elseif value29.recog == -6 then
				callback32("发起人不允许创建队伍")
			elseif value29.recog == -3 then
				callback32("该玩家已有队伍")
			elseif value29.recog == -4 then
				callback32("接受人不允许组队")
			elseif value29.recog == -10 then
				callback32("不可邀请自己组队")
			else
				callback32("未知错误")
			end

			g_data.client:setLastTime("group")
		elseif SM_GROUPADDMEM_OK == value31 then
			g_data.client:setLastTime("group")
			print("SM_GROUPADDMEM_OK 添加组员成功", value32)
		elseif SM_GROUPADDMEM_FAIL == value31 then
			print("SM_GROUPADDMEM_FAIL", value29.recog)

			if value29.recog == -1 then
				callback32("发起人不是队长")
			elseif value29.recog == -2 then
				callback32("玩家名错误或不在线")
			elseif value29.recog == -3 then
				callback32("该玩家已有队伍")
			elseif value29.recog == -4 then
				callback32("接受人不允许组队")
			elseif value29.recog == -5 then
				callback32("队伍已满")
			elseif value29.recog == -10 then
				callback32("不可邀请自己组队")
			else
				callback32("未知错误。")
			end

			g_data.client:setLastTime("group")
		elseif SM_GROUPDELMEM_OK == value31 then
			g_data.client:setLastTime("group")
			print("SM_GROUPDELMEM_OK 删除组员成功", value32, net.str(value30))
			g_data.player:delGroupMember(value30)

			if value.panels.group and value.panels.group.page == "mine" then
				value.panels.group:showPageInfo("mine", g_data.player.groupMembers)
			end
		elseif SM_GROUPDELMEM_FAIL == value31 then
			if value29.recog == -1 then
				callback32("队员不能删除其他成员")
			elseif value29.recog == -2 then
				callback32("输入的人物名称不正确")
			elseif value29.recog == -3 then
				callback32("删除目标不是队伍成员")
			else
				callback32("未知错误")
			end

			g_data.client:setLastTime("group")
		elseif SM_GROUPCANCEL == value31 then
			print("SM_GROUPCANCEL 解散队伍")
			g_data.player:setGroupMembers(nil)
			g_data.player:setTeamLeader(false)

			if value.panels.group and value.panels.group.page == "mine" then
				value.panels.group:showPageInfo("mine", g_data.player.groupMembers)
			end
		elseif SM_GROUPMEMBERS == value31 then
			print("SM_GROUPMEMBERS", value32, value29.param, getRecordSize("TClientGroupMemInfo"))
			g_data.player:initGroupMembers(value29, value30, value32)
			g_data.player:setTeamLeader(false)

			for _3, groupMember in ipairs(g_data.player.groupMembers) do
				if groupMember:get("name") == value2.getPlayerName() and groupMember:get("isCaptain") == 1 then
					g_data.player:setTeamLeader(true)

					break
				end
			end

			if value.panels.group and value.panels.group.page == "mine" then
				value.panels.group:showPageInfo("mine", g_data.player.groupMembers)
			end
		elseif SM_QUERY_NEARBYGROUP == value31 then
			print("SM_QUERY_NEARBYGROUP")
			g_data.player:initNearGroup(value29, value30, value32)

			if value.panels.group then
				value.panels.group:showPageInfo("group", g_data.player.nearGroupInfo)
			end
		elseif SM_QUERY_NEARBYPLAYER == value31 then
			print("SM_QUERY_NEARBYPLAYER", getRecordSize("TClientNearbyPlayerInfo"), value32)

			local value57 = g_data.relation:decodeNearPlayerBuf(value29, value30, value32)

			if value.panels.group and value.panels.group.page == "near" then
				value.panels.group:showPageInfo("near", value57)
			end

			if value.panels.relation and value.panels.relation.page == "near" then
				value.panels.relation:showContent("near", value57)
			end
		elseif SM_NotifyGroupMessage == value31 then
			print("SM_NotifyGroupMessage")

			local value58 = net.str(value30)
			local value59 = value29.param

			if value29.recog == 1 then
				value.notice:addMsg("FriendApply", {
					value58,
					value59
				})
			else
				value.notice:removeMsg("FriendApply", {
					value58,
					value59
				})
			end
		elseif SM_ORDER_LIST == value31 then
			g_data.client:setLastTime("top")

			if value.panels.top then
				value.panels.top:processUpt(value29.param, value29, value30, value32)
			end
		elseif SM_CORPS_NOTICE == value31 then
			dump(value29)
			print(" SM_CORPS_NOTICE ", value32 > 0 and net.str(value30) or "nil", value32)

			if value29.param == 0 then
				g_data.guild.clanNotice = value32 > 0 and net.str(value30) or ""
			end
		elseif SM_GILD_NOTICE == value31 then
			if value29.param == 0 then
				g_data.guild.guildNotice = value32 > 0 and net.str(value30) or ""
			end
		elseif SM_FIND_CORPS_BYNAME == value31 then
			print("模糊查找战队返回")
			dump(value29)

			g_data.guild.serach = true

			g_data.guild:initClanList(value29, value30, value32)

			if value.panels.guild and value.panels.guild.page == "clan" then
				value.panels.guild:uirefushContent("clan")
			end
		elseif SM_FIND_GILD_BYNAME == value31 then
			print("模糊查找行会返回")
			dump(value29)

			g_data.guild.serach = true

			g_data.guild:initGuildList(value29, value30, value32)

			if value.panels.guild and value.panels.guild.page == "tguild" then
				if value.panels.guild.showGuildListNode then
					value.panels.guild:showGuildList()
				else
					value.panels.guild:uirefushContent("tguild")
				end
			end
		elseif SM_CORPS_GET_RECRUIT_CONDITION == value31 then
			if value29.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value29.param)
				end
			else
				value.panels.guild:recruitCondition(value29, value30, value32)
			end
		elseif SM_PLAYER_POSITION == value31 then
			g_data.guild.posInfo = value29.tag

			local items20 = {
				"",
				"副队长",
				"队长",
				"副会长",
				"会长"
			}
		elseif SM_PLAYER_GILD == value31 then
			g_data.guild:initGuildInfo(value29, value30, value32)

			if value.panels.guild and value.panels.guild.page == "tguild" then
				value.panels.guild.subpage = nil

				value.panels.guild:uirefushContent("tguild")
			end
		elseif SM_PLAYER_CORPS == value31 then
			g_data.guild:initClanInfo(value29, value30, value32)

			if value.panels.guild and value.panels.guild.page == "clan" then
				value.panels.guild.subpage = nil

				value.panels.guild:uirefushContent("clan")
			end
		elseif SM_REFRESH_GILDINFO == value31 then
			g_data.guild:initGuildInfo(value29, value30, value32)

			if value.panels.guild and value.panels.guild.page == "tguild" and value.panels.guild.subpage == "guildmain" then
				value.panels.guild:refush("guildmain")
			end
		elseif SM_REFRESH_CORPSINFO == value31 then
			g_data.guild:initClanInfo(value29, value30, value32)

			if value.panels.guild and value.panels.guild.page == "clan" and value.panels.guild.subpage == "clanmain" then
				value.panels.guild:refush("clanmain")
			end
		elseif SM_CORPS_LIST == value31 then
			if value29.param == 0 then
				g_data.guild.serach = false
				g_data.guild.page = value29.recog

				g_data.guild:initClanList(value29, value30, value32)

				g_data.guild.getCorpsList = true

				if value.panels.guild and value.panels.guild.page == "clan" then
					value.panels.guild:uirefushContent("clan")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_REQUEST_JOIN == value31 then
			if value29.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value29.param)
				end
			else
				value:tip("申请加入战队成功")
			end
		elseif SM_CORPS_CANCEL_JOIN == value31 then
			if value29.param == 0 then
				value:tip("取消申请加入战队成功")
			end
		elseif SM_CORPS_TRANSFER_CAPTAIN == value31 then
			if value29.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value29.param)
				end
			else
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end
		elseif SM_CORPS_APPOINT_VICE_CAPTAIN == value31 or SM_CORPS_DISMISS_VICE_CAPTAIN == value31 then
			if value29.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value29.param)
				end
			else
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end
		elseif SM_CORPS_STEPDOWN == value31 then
			if value29.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value29.param)
				end
			else
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			end
		elseif SM_CORPS_EXIT == value31 then
			if value29.param ~= 0 then
				if value.panels.guild then
					value.panels.guild:showError(value29.param)
				end
			else
				g_data.guild.guildInfo = nil
				g_data.guild.clanInfo = nil

				if value.panels.guild and value.panels.guild.page == "clan" then
					value.panels.guild.subpage = nil

					value.panels.guild:uirefushContent("clan")
				end
			end
		elseif SM_CORPS_QUERY_REQUESTS == value31 then
			g_data.guild:getCorpsQueryRequests(value29, value30, value32)

			if value.panels.guild and value.panels.guild.subpage == "clanjobs" then
				value.panels.guild:refush("clanjobs")
			end
		elseif SM_CORPS_ACCEPT_REQUEST == value31 then
			if value29.param == 0 then
				net.send({
					CM_CORPS_QUERY_REQUESTS,
					tag = 30,
					param = 0
				})
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_REFUSE_REQUEST == value31 then
			if value29.param == 0 then
				net.send({
					CM_CORPS_QUERY_REQUESTS,
					tag = 30,
					param = 0
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_DISMISS_MEMBER == value31 then
			if value29.param == 0 then
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_CREATE == value31 then
			if value29.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_MEMBER_LIST == value31 then
			if value29.param == 0 then
				if value29.recog == 0 then
					g_data.guild:getCorpsMem(value29, value30, value32)

					if value.panels.guild then
						value.panels.guild:refush("clanmem")
					end
				else
					g_data.guild:getGuildCorpsMem(value29, value30, value32)

					if value.panels.guild then
						value.panels.guild:showOtherClanMem()
					end
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_SET_MEMBER_TITLE == value31 then
			if value29.param == 0 then
				net.send({
					CM_CORPS_MEMBER_LIST,
					tag = 30,
					series = 0,
					recog = 0
				}, nil, {
					{
						"ID",
						g_data.guild.clanInfo:get("corpsID")
					}
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_SEND_APPLYCORPS_ID == value31 then
			g_data.guild:refushCurClan(value29, value30, value32)

			local instance = cc.Director:getInstance():getEventDispatcher()
			local value60 = cc.EventCustom:new("UpdateNilClanState")

			instance:dispatchEvent(value60)
		elseif SM_SEND_APPLYGILD_ID == value31 then
			g_data.guild:refushCurGuild(value29, value30, value32)

			local instance2 = cc.Director:getInstance():getEventDispatcher()
			local value61 = cc.EventCustom:new("UpdateNilGuildState")

			instance2:dispatchEvent(value61)
		elseif SM_CORPS_DIRECT_ADD_MEMBER == value31 then
			if value29.param == 0 then
				value:tip("面对面找人请求发送成功！")
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CORPS_QUERY_LOG == value31 then
			g_data.guild:getCorpsLog(value29, value30, value32)

			if value.panels.guild then
				value.panels.guild:refush("clanlog")
			end
		elseif SM_GILD_LIST == value31 then
			if value29.param == 0 then
				g_data.guild.serach = false
				g_data.guild.page = value29.recog

				g_data.guild:initGuildList(value29, value30, value32)

				g_data.guild.getguildList = true

				if value.panels.guild and value.panels.guild.page == "tguild" then
					if value.panels.guild.showGuildListNode then
						value.panels.guild:showGuildList()
					else
						value.panels.guild:uirefushContent("tguild")
					end
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_EXIT == value31 then
			if value29.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_QUERY_CORPS == value31 then
			if value29.param == 0 then
				g_data.guild:getguildcorpsList(value29, value30, value32)

				if value.panels.guild then
					value.panels.guild:refush("claninfo")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_QUERY_REQUEST_JOIN_LIST == value31 then
			if value29.param == 0 then
				g_data.guild:getGuildQueryRequests(value29, value30, value32)

				if value.panels.guild and value.panels.guild.subpage == "clanrecruit" then
					value.panels.guild:refush("clanrecruit")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_REQUEST_JOIN == value31 then
			if value29.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_ACCEPT_REQUEST == value31 then
			if value29.param == 0 then
				print("------")

				if value29.recog == 1 then
					net.send({
						CM_GILD_QUERY_REQUEST_JOIN_LIST,
						tag = 30,
						series = 0
					})
				elseif value29.recog == 2 then
					net.send({
						CM_GILD_QUERY_REQUEST_UNION_LIST,
						tag = 30,
						series = 0
					})
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_REFUSE_REQUEST == value31 then
			if value29.param == 0 then
				print("------")

				if value29.recog == 1 then
					net.send({
						CM_GILD_QUERY_REQUEST_JOIN_LIST,
						tag = 30,
						series = 0
					})
				elseif value29.recog == 2 then
					net.send({
						CM_GILD_QUERY_REQUEST_UNION_LIST,
						tag = 30,
						series = 0
					})
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_DISMISS_CORPS == value31 then
			if value29.param == 0 then
				print("+++++++++++++++++++++++")
				net.send({
					CM_GILD_QUERY_CORPS
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_CHANGE_MEMBER == value31 then
			-- block empty
		elseif SM_GILDMEMBER_LIST == value31 then
			if value29.param == 0 then
				g_data.guild:getguildMem(value29, value30, value32)

				if value.panels.guild then
					value.panels.guild:refush("mem")
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_QUERY_LOG == value31 then
			g_data.guild:getGuildLog(value29, value30, value32)

			if value.panels.guild then
				value.panels.guild:refush("log")
			end
		elseif SM_GILD_QUERY_REQUEST_UNION_LIST == value31 then
			g_data.guild:getRequestUnion(value29, value30, value32)

			if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
				print(value.panels.guild.subpage or " nil ")
				print("")
				value.panels.guild:showSubDiplomatic4()
			end
		elseif SM_GILD_REQUEST_UNION == value31 then
			if value29.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_BREAK_UNION == value31 then
			if value29.param ~= 0 and value.panels.guild then
				value.panels.guild:showError(value29.param)
			end

			net.send({
				CM_GILD_QUERY_UNION,
				tag = 30,
				series = 0
			})
		elseif SM_GILD_QUERY_HOSTILE == value31 then
			if value29.param == 0 then
				g_data.guild:getHostile(value29, value30, value32)

				if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
					value.panels.guild:showSubDiplomatic2()
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_QUERY_UNION == value31 then
			g_data.guild:getUnion(value29, value30, value32)

			if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
				if value.panels.guild.showGuildListNode then
					value.panels.guild:showGuildList()
				else
					value.panels.guild:showSubDiplomatic1()
				end
			end
		elseif SM_GILD_QUERY_CONCERN == value31 then
			if value29.param == 0 then
				g_data.guild:getConcern(value29, value30, value32)

				if value.panels.guild and value.panels.guild.subpage == "diplomatic" then
					value.panels.guild:showSubDiplomatic3()
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_VICECAPTAIN_STEPDOWN == value31 or SM_GILD_DISMISS_VICECAPTAIN == value31 or SM_GILD_APPOINT_VICE_PRESIDENT == value31 or SM_GILD_TRANSFER_PRESIDENT == value31 then
			if value29.param == 0 then
				net.send({
					CM_GILDMEMBER_LIST
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_CONCERN_GILD_ID == value31 then
			if value29.param == 0 then
				net.send({
					CM_GILD_QUERY_CONCERN,
					tag = 30,
					series = 0
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_CANCLE_CONCERN == value31 then
			if value29.param == 0 then
				net.send({
					CM_GILD_QUERY_CONCERN,
					tag = 30,
					series = 0
				})
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_DECLARE_WAR == value31 then
			if value29.param == 0 then
				if value.panels.guild then
					if value.panels.guild.threeSub == 2 then
						net.send({
							CM_GILD_QUERY_HOSTILE,
							tag = 30,
							series = 0
						})
					elseif value.panels.guild.threeSub == 3 then
						net.send({
							CM_GILD_QUERY_CONCERN,
							tag = 30,
							series = 0
						})
					end
				end
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_GILD_ENABLE_UNION == value31 then
			if value29.param == 0 then
				local value62 = g_data.guild.guildInfo:get("enableUnion")

				g_data.guild.guildInfo:set("enableUnion", value62 == 0 and 1 or 0)
			elseif value.panels.guild then
				value.panels.guild:showError(value29.param)
			end
		elseif SM_SEND_REFUSE_REQUEST == value31 then
			if value32 == getRecordSize("TRefuseRequestType") then
				local record4 = getRecord("TRefuseRequestType")

				net.record(record4, value30, value32)

				local text4 = ""

				if record4:get("type") == 3 then
					text4 = record4:get("name") .. " 拒绝了您的联盟请求！"
				else
					text4 = "您加入" .. (record4:get("type") == 1 and "战队 " or "行会 ") .. record4:get("name") .. " 的请求已经被拒绝!"
				end

				value:tip(text4)
				value:tip(text4)
				value:tip(text4)
			end
		elseif SM_STRENGTHEN_EQUIP_QUEST == value31 then
			if value.panels.fusion then
				value.panels.fusion:addItems(value29, value30, value32)
			end
		elseif SM_STRENGTHEN_EQUIP == value31 then
			if value.panels.fusion then
				value.panels.fusion:fusionEquip(value29, value30, value32)
			end
		elseif SM_UPDATE_CLOTHES == value31 then
			if value29.recog == 0 then
				value:tip("强化成功")

				if value.panels.strengthen then
					value.panels.strengthen:showResult()
				end
			elseif value.panels.strengthen then
				value.panels.strengthen:showError(value29)
			end
		elseif SM_SHOPITEMS == value31 then
			if value32 == 0 then
				return
			end

			local value63 = g_data.shop:parseContent(value29, value30, value32)

			if value.panels.shop then
				value.panels.shop:processUpt(value29.param, value63)
			end
		elseif SM_FIRSTSHOP == value31 then
			if value32 == 0 then
				return
			end

			local value64 = g_data.shop:parseSpecially(value30, value32)

			if value.panels.shop then
				value.panels.shop:processUpt(5, value64)
			end
		elseif SM_DOSHOP_FAIL == value31 then
			import(".panel.shop", value3).onDoShopFail(value31, value29.recog, value29.param)
		elseif SM_HERO_ABILITY == value31 then
			g_data.hero:setAbility(value29, value30, value32)
			main_scene.ground.map:addMsg({
				roleid = g_data.hero.roleid,
				job = g_data.hero.job
			})

			if value.panels.heroHead then
				value.panels.heroHead:upt()
			end
		elseif SM_GLORYFEALTY == value31 then
			g_data.hero:setGloryFealty(value29.param, value29.tag)
		elseif SM_HERO_BAGITEMS == value31 then
			g_data.hero:setBagSize(value29.series)
			g_data.heroBag:set(value30, value32)

			if value.panels.heroBag and not value.panels.heroBag:reloadAll(g_data.hero.bagSize) then
				value.panels.heroBag:reload()
			end
		elseif SM_HERO_BAGITEMDURACHG == value31 then
			g_data.heroBag:duraChange(value29.recog, value29.param, value29.tag, value29.series)

			if main_scene.ui.panels.heroBag then
				main_scene.ui.panels.heroBag:duraChange(value29.recog, value29.param, value29.tag, value29.series)
			end
		elseif SM_HERO_SENDUSEITEMS == value31 then
			g_data.heroEquip:set(value30, value32)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "equip" then
				main_scene.ui.panels.heroEquip:showContent("equip")
			end
		elseif SM_HERO_SENDMYMAGIC == value31 then
			g_data.hero:setMagicList(value30, value32)

			if value.panels.heroEquip and value.panels.heroEquip.page == "skill" then
				value.panels.heroEquip:showContent("skill")
			end
		elseif SM_HERO_ADDMAGIC == value31 then
			g_data.hero:addMagic(value30, value32)

			if value.panels.heroEquip and value.panels.heroEquip.page == "skill" then
				value.panels.heroEquip:showContent("skill")
			end
		elseif SM_HERO_WINEXP == value31 then
			g_data.hero.ability:set("Exp", value29.recog)

			local long2 = MakeLong(value29.param, value29.tag)

			value:tip(long2 .. " 英雄经验值增加")

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end
		elseif SM_HERO_MAGIC_LVEXP == value31 then
			local value65 = g_data.hero:setMagicExp(value29, value30, value32)

			if value65 and value.panels.heroEquip then
				value.panels.heroEquip:updateMagic(value65:get("magicId"))
			end
		elseif SM_HERO_UNIONSTATUS == value31 then
			g_data.hero:setUnionState(value29.recog, value29.param)
			main_scene.ui.console:call("btnHeroSkill", "hero_upt_union")
		elseif SM_HERO_DURACHANGE == value31 then
			g_data.heroEquip:duraChange(value29.param, value29.recog, MakeLong(value29.tag, value29.series))
		elseif SM_HERO_LEVELUP == value31 then
			g_data.hero:setBagSize(value29.tag)
			g_data.hero.ability:set("level", value29.param)
			value:tip("你的英雄升级了")

			if value.panels.heroBag then
				value.panels.heroBag:reloadAll(g_data.hero.bagSize)
			end

			if value.panels.heroHead then
				value.panels.heroHead:upt()
			end
		elseif SM_TOHEROBAG_OK == value31 then
			if g_data.client.heroPutInItem then
				g_data.client.heroPutInItem:set("makeIndex", MakeLong(value29.param, value29.tag))

				if value.panels.bag then
					value.panels.bag:delItem(g_data.client.heroPutInItem:get("makeIndex"))
				end

				g_data.bag:delItem(g_data.client.heroPutInItem:get("makeIndex"))
				g_data.heroBag:addItem(g_data.client.heroPutInItem)

				if value.panels.heroBag then
					value.panels.heroBag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
				end

				g_data.client:setHeroPutInItem()
				callback42(true)
			end
		elseif SM_TOHEROBAG_FAIL == value31 then
			if g_data.client.heroPutInItem then
				g_data.bag:addItem(g_data.client.heroPutInItem)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:addItem(g_data.client.heroPutInItem:get("makeIndex"))
				end

				g_data.client:setHeroPutInItem()
			end
		elseif SM_TOHUMBAG_OK == value31 then
			if g_data.client.heroGetBackItem then
				g_data.client.heroGetBackItem:set("makeIndex", MakeLong(value29.param, value29.tag))

				if value.panels.heroBag then
					value.panels.heroBag:delItem(g_data.client.heroGetBackItem:get("makeIndex"))
				end

				g_data.heroBag:delItem(g_data.client.heroGetBackItem:get("makeIndex"))
				g_data.bag:addItem(g_data.client.heroGetBackItem)

				if value.panels.bag then
					value.panels.bag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
				end

				g_data.client:setHeroGetBackItem()
				callback42()
			end
		elseif SM_TOHUMBAG_FAIL == value31 then
			if g_data.client.heroGetBackItem then
				g_data.heroBag:addItem(g_data.client.heroGetBackItem)

				if main_scene.ui.panels.heroBag then
					main_scene.ui.panels.heroBag:addItem(g_data.client.heroGetBackItem:get("makeIndex"))
				end

				g_data.client:setHeroGetBackItem()
			end
		elseif SM_HERO_ADDITEM == value31 then
			local items21 = g_data.heroBag:add(value30, value32)

			for index3 = 1, #items21 do
				local response2 = items21[index3]

				if response2.where == "bag" and value.panels.heroBag then
					value.panels.heroBag:addItem(response2.data:get("makeIndex"))
				end
			end

			callback42(true)
		elseif SM_HERO_DELITEM == value31 then
			local value66 = value29.recog

			if g_data.heroBag:delItem(value66) and value.panels.heroBag then
				value.panels.heroBag:delItem(value66)
			end

			if g_data.heroEquip:delItem(value66) and value.panels.heroEquip then
				value.panels.heroEquip:delItem(value66)
			end
		elseif SM_HERO_DROPITEM_SUCCESS == value31 then
			g_data.heroBag:throwEnd(value29.recog, true)
		elseif SM_HERO_DROPITEM_FAIL == value31 then
			g_data.heroBag:throwEnd(value29.recog, false)

			if value.panels.heroBag then
				value.panels.heroBag:addItem(value29.recog)
			end
		elseif SM_HERO_EAT_OK == value31 then
			g_data.heroBag:useEnd("eat", true)
		elseif SM_HERO_EAT_FAIL == value31 then
			local value67, value68, value69, value70 = g_data.heroBag:useEnd("eat", false)

			if value67 and value.panels.heroBag and value70 == "bag" then
				value.panels.heroBag:addItem(value67)
			end
		elseif SM_HERO_TAKEON_OK == value31 then
			local value71 = g_data.heroBag:useEnd("take", true)

			if value.panels.heroEquip and value71 then
				value.panels.heroEquip:setItem(value71)
			end
		elseif SM_HERO_TAKEON_FAIL == value31 then
			local value72 = g_data.heroBag:useEnd("take", false)

			if value.panels.heroBag and value72 then
				value.panels.heroBag:addItem(value72)
			end
		elseif SM_HERO_TAKEOFF_OK == value31 then
			g_data.heroEquip:takeOffEnd(true)
		elseif SM_HERO_TAKEOFF_FAIL == value31 then
			local value73 = g_data.heroEquip:takeOffEnd(false)

			if value.panels.heroEquip and value73 then
				value.panels.heroEquip:setItem(value73)
			end
		elseif SM_LOCK_EQUIP_STATE == value31 then
			value2.setLockEquipState(value29, value30, value32)
		elseif SM_LOCKEQUIP == value31 then
			value2.setBindEquipState(value29, value30, value32)
		elseif SM_SEND_RELATION_FRIEND == value31 then
			g_data.relation:setFriends(value29, value30, value32)
		elseif SM_SEND_RELATION_ATTENTION == value31 then
			g_data.relation:setAttentions(value29, value30, value32)
		elseif SM_SEND_RELATION_NORMBLACKLIST == value31 then
			g_data.relation:setBlackList(value29, value30, value32)
		elseif SM_ADD_RELATION_FRIEND_OK == value31 then
			import(".panel.relation", value3).onAddFriendOk(value30, value29.recog)
		elseif SM_ADD_RELATION_FRIEND_FAIL == value31 then
			import(".panel.relation", value3).onAddFriendFail(value30, value29.recog)
		elseif SM_ADD_RELATION_ATTENTION == value31 then
			import(".panel.relation", value3).onAddAtt(value29.recog)
		elseif SM_ADD_RELATION_NORMBLACKLIST == value31 then
			import(".panel.relation", value3).onAddBlack(value29.recog)
		elseif SM_DEL_RELATION_FRIEND == value31 then
			import(".panel.relation", value3).onDelFriend(value29.recog)
		elseif SM_DEL_RELATION_ATTENTION == value31 then
			import(".panel.relation", value3).onDelAtt(value29.recog)
		elseif SM_DEL_RELATION_NORMBLACKLIST == value31 then
			import(".panel.relation", value3).onDelBlack(value29.recog)
		elseif SM_UPDATE_ATTENTION_COLOR == value31 then
			import(".panel.relation", value3).onUptAttClr(value29.recog)
		elseif SM_UPDATE_RELATION_FRIEND == value31 then
			g_data.relation:updateFriend(value29, value30, value32)
		elseif SM_UPDATE_RELATION_ATTENTION == value31 then
			g_data.relation:updateAttention(value29, value30, value32)
		elseif SM_UPDATE_RELATION_NORMBLACKLIST == value31 then
			g_data.relation:updateBlackList(value29, value30, value32)
		elseif SM_RELATION_MEMBER_ONLINE == value31 then
			g_data.relation:online(value29, value30, value32)
		elseif SM_RELATION_MEMBER_OFFLINE == value31 then
			g_data.relation:offline(value29, value30, value32)
		elseif SM_QUERY_STALL == value31 then
			if value29.recog == 1 then
				if value29.tag == 0 then
					g_data.stall:set(value29, value30, value32)
					value:showPanel("stall")
				else
					g_data.stallOther:set(value29, value30, value32)
					value:showPanel("stallOther")
				end
			elseif value29.recog == -1 and value29.tag == 1 then
				value:tip("查询摊位失败！")
			elseif value29.recog == -2 and value29.tag == 0 then
				value:tip("有摊位物品未处理，请先领取再进行摆摊！")
			elseif value29.recog == -3 and value29.tag == 0 then
				value:tip("服务器发生错误！")
			end
		elseif SM_SET_STALL_TIMELV == value31 then
			if value29.recog == 1 then
				if value.panels.stall then
					value.panels.stall:upt()
				end
			elseif value29.recog == -1 then
				value:tip("金币不足！")
			elseif value29.recog == -2 then
				value:tip("设置摆摊的时间超过上限！")
			elseif value29.recog == -3 then
				value:tip("设置摆摊的等级超过上限！")
			end
		elseif SM_SET_STALL_NAME == value31 then
			if value29.recog == 1 then
				value:tip("修改摊位名称成功.")
			elseif value29.recog == -1 then
				value:tip("摊位名称过长！")
			elseif value29.recog == -2 then
				value:tip("摊位名称不合法！")
			elseif value29.recog == -3 then
				value:tip("摆摊中无法进行修改！")
			end
		elseif SM_ADD_STALLITEM == value31 then
			if value29.recog == -1 then
				value:tip("增加物品失败！")
			elseif value29.recog == -2 then
				value:tip("摊位不存在！")
			elseif value29.recog == -3 then
				value:tip("物品不存在！")
			elseif value29.recog == -4 then
				value:tip("输入的数量不正确！")
			elseif value29.recog == -5 then
				value:tip("绑定的物品不可出售！")
			end
		elseif SM_DEL_STALLITEM == value31 then
			if value29.recog == -1 then
				value:tip("物品已售出！")
			end
		elseif SM_CANCEL_STALL == value31 then
			if value29.recog == -1 then
				p2("other", "[stall sys]: stall isn't exist or stall time is over")
			elseif value29.recog == -2 then
				value:tip("您的包裹空间不足,请到邮件收回物品！")
			end
		elseif SM_UPT_ADD_STALLITEM == value31 then
			local value74 = g_data.stall:uptAddItem(value29, value30, value32)

			if value.panels.stall then
				value.panels.stall:addItem(value74)
			end
		elseif SM_UPT_DEL_STALLITEM == value31 then
			g_data.stall:uptDelItem(value29.recog)

			if value.panels.stall then
				value.panels.stall:delItem(value29.recog)
			end
		elseif SM_START_STALL == value31 then
			if value29.recog == 1 then
				value:tip("摆摊成功.")
				g_data.stall:start()
			elseif value29.recog == -1 then
				value:tip("已有摊位，不能重复摆摊！")
			elseif value29.recog == -2 then
				value:tip("缺少摆摊材料！")
			elseif value29.recog == -3 then
				value:tip("金币不足！")
			elseif value29.recog == -4 then
				value:tip("创建摊位失败！")
			elseif value29.recog == -5 then
				value:tip("该范围内有其他玩家！")
			elseif value29.recog == -6 then
				value:tip("该范围不足以进行摆摊！")
			elseif value29.recog == -7 then
				value:tip("摊位时间已结束！")
			elseif value29.recog == -8 then
				value:tip("没有摆放物品售卖！")
			elseif value29.recog == -9 then
				value:tip("边界城区外无法摆摊！")
			end
		elseif SM_PAUSE_STALL == value31 then
			if value29.recog == 1 then
				value:tip("暂停摆摊成功.")
				g_data.stall:pause()
			end
		elseif SM_BUY_STALLITEM == value31 then
			if value29.recog == -1 then
				value:tip("包裹空间不足！")
			elseif value29.recog == -2 then
				value:tip("元宝不足！")
			elseif value29.recog == -3 then
				value:tip("金币不足！")
			elseif value29.recog == -4 then
				value:tip("已售完！")
			elseif value29.recog == -5 then
				value:tip("摊位已取消或不存在！")
			elseif value29.recog == -6 then
				value:tip("购买的物品数量超过出售数量！")
			elseif value29.recog == -7 then
				value:tip("扣除元宝失败！")
			end
		elseif SM_UPT_OTHER_DEL_STALLITEM == value31 then
			g_data.stallOther:uptDelItem(value29)

			if value.panels.stallOther then
				value.panels.stallOther:delItem(value29.recog)
			end
		elseif SM_MESSAGE_STALL == value31 then
			if value29.recog == 1 then
				value:tip("留言成功.")
			elseif value29.recog == -1 then
				value:tip("留言失败！")
			end
		elseif SM_QUERY_STALL_STATUS == value31 then
			g_data.stall:setTime(value29.recog)
		elseif SM_FETCH_MAIL_LIST == value31 then
			if value29.recog == 1 then
				g_data.mail:set(value29, value30, value32)

				if value.panels.mail then
					value.panels.mail:showContentByTag(value29.tag)
				end
			elseif value29.recog == -1 then
				value:tip("数据出错！")
			end
		elseif SM_FETCH_MAIL_INFO == value31 then
			if value29.recog == 1 then
				local value75, value76 = g_data.mail:parseMail(value29, value30, value32)

				if value.panels.mail then
					value.panels.mail:showMail(value75, value76)
				end
			elseif value31 == -1 then
				value:tip("邮件查询失败！")
			end
		elseif SM_FETCH_ATTACH == value31 then
			if value29.recog == 1 then
				local value77, value78 = g_data.mail:attach()

				if value77 and value78 and value.panels.mail then
					value.panels.mail:showMail(value77, value78)
				end

				value:tip("领取附件成功.")
			elseif value29.recog == -1 then
				value:tip("您的包裹空间不足！")
			elseif value29.recog == -2 then
				value:tip("没有奖励可以领取！")
			elseif value29.recog == -3 then
				value:tip("金币超过上限！")
			elseif value29.recog == -4 then
				value:tip("领取元宝失败！")
			elseif value29.recog == -5 then
				value:tip("不在安全区无法领取附件！")
			end

			if value29.recog ~= 1 and value.panels.mail then
				value.panels.mail:stopAuto()
			end
		elseif SM_DEL_MAIL == value31 then
			if value29.recog == 1 then
				local value79, value80, value81 = g_data.mail:del()

				if value79 and value81 and value.panels.mail then
					if value81 == "sys" then
						value.panels.mail:showMail(value80, value81)
					elseif value81 == "sell" then
						value.panels.mail:delMail(value79, value81)
					end
				end
			elseif value29.recog == -1 then
				value:tip("删除邮件失败！")
			end
		elseif SM_FETCH_ATTACH_OFFTM == value31 then
			if value29.recog == 1 then
				local value82 = g_data.mail:attachOfftm()

				if value.panels.mail then
					value.panels.mail:showContentByTag(value82)
				end
			elseif value29.recog == -1 then
				value:tip("您的包裹空间不足！")
			elseif value29.recog == -2 then
				value:tip("没有过期摊位物品！")
			end
		elseif SM_MAIL_INFO == value31 then
			g_data.mail:setUnreadMailCnt(value29.recog)
			value.notice:uptMailCnt(g_data.mail.unreadCnt, value29.tag)
		elseif CM_CLEAR_ALLMAIL == value31 then
			if value29.recog == 1 then
				value:tip("清除成功")
			elseif value29.recog == -1 then
				value:tip("清除失败！")
			end

			if value.panels.mail then
				value.panels.mail:refresh()
			end
		elseif checkExist(value31, SM_YBDEAL_QUERY_BUY, SM_YBDEAL_QUERY_SELL, SM_YBDEAL_HISTROY_BUY, SM_YBDEAL_HISTROY_SELL) then
			local tag2 = g_data.ybdeal:parseMsg(value29, value30, value32)

			if value.panels.ybdeal then
				value.panels.ybdeal:upt(tag2)
			else
				value:showPanel("ybdeal", {
					tag = tag2
				})
			end
		elseif SM_YBDEAL_BUY == value31 then
			if value29.recog > 0 then
				g_data.ybdeal:removeBuyUnit(value29.recog)

				if value.panels.ybdeal then
					value.panels.ybdeal:upt(1)
				end
			elseif value29.recog == -1 then
				value:tip("包裹没有足够空间！")
			elseif value29.recog == -2 then
				value:tip("对方已取消！")
			elseif value29.recog == -3 then
				value:tip("元宝不足！")
			elseif value29.recog == -4 then
				value:tip("发生未知错误！")
			elseif value29.recog == -5 then
				value:tip("订单号错误！")
			elseif value29.recog == -6 then
				value:tip("卖家不存在！")
			elseif value29.recog == -8 then
				value:tip("未找到订单信息！")
			elseif value29.recog == -9 then
				value:tip("未找到订单信息！")
			end
		elseif SM_YBDEAL_BUY_CANCEL == value31 then
			if value29.recog > 0 then
				g_data.ybdeal:removeBuyUnit(value29.recog)

				if value.panels.ybdeal then
					value.panels.ybdeal:upt(1)
				end
			elseif value29.recog == -1 then
				value:tip("对方已取消！")
			elseif value29.recog == -2 then
				value:tip("发生未知错误！")
			end
		elseif SM_YBDEAL_REFER_ITEMS1 == value31 then
			if value29.recog == 1 then
				g_data.ybdeal:setSign(value29)

				if g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS1] and g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS2] and value.panels.ybdeal then
					value.panels.ybdeal:sellUpt()
				end
			elseif value29.recog == -1 then
				value:tip("买家账号不存在！")
			elseif value29.recog == -2 then
				value:tip("请输入买家姓名！")
			elseif value29.recog == -3 then
				value:tip("买家姓名含有非法字符！")
			elseif value29.recog == -4 then
				value:tip("不能出售给自己！")
			elseif value29.recog == -5 then
				value:tip("出售的物品不存在！")
			elseif value29.recog == -6 then
				value:tip("出售的装备处于锁定状态！")
			elseif value29.recog == -7 then
				value:tip("已经在交易状态！")
			elseif value29.recog == -8 then
				value:tip("输入的价格超出范围！")
			elseif value29.recog == -11 then
				value:tip("未达到对方设定的交易等级！")
			end
		elseif SM_YBDEAL_REFER_ITEMS2 == value31 then
			if value29.recog == 1 then
				g_data.ybdeal:setSign(value29)

				if g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS1] and g_data.ybdeal.sign[SM_YBDEAL_REFER_ITEMS2] and value.panels.ybdeal then
					value.panels.ybdeal:sellUpt()
				end
			elseif value29.recog == -1 then
				value:tip("输入的买家不合法！")
			elseif value29.recog == -2 then
				value:tip("输入的价格超出范围！")
			elseif value29.recog == -5 then
				value:tip("只能同时出售4单！")
			elseif value29.recog == -6 then
				value:tip("对方购买订单已满4单,无法接受新的订单！")
			elseif value29.recog == -7 then
				value:tip("出售的物品不存在！")
			end
		elseif SM_YBDEAL_SELL_CANCEL == value31 then
			if value29.recog > 0 then
				g_data.ybdeal:removeSellUnit(value29.recog)

				if value.panels.ybdeal then
					value.panels.ybdeal:upt(2)
				end
			elseif value29.recog == -1 then
				value:tip("物品已售出！")
			elseif value29.recog == -2 then
				value:tip("超时无法取回！")
			end
		elseif SM_DISPLAY_YBDEAL_SET == value31 then
			local tag3 = g_data.ybdeal:parseSetting(value29)

			if value.panels.ybdeal then
				value.panels.ybdeal:upt(tag3)
			else
				value:showPanel("ybdeal", {
					tag = tag3
				})
			end
		elseif SM_YBDEAL_Set_Operate == value31 then
			if value29.recog == 0 then
				value:tip("设置成功.")
			elseif value29.recog == -1 then
				value:tip("设置错误,设定等级超过最大等级999！")
			end
		elseif SM_CHANNEL_CREATE == value31 then
			if value29.recog ~= 0 then
				local voice, voice2 = import(".panel.voice", value3).handleCode(value29.recog)

				an.newMsgbox(voice2)
			end
		elseif SM_CHANNEL_ENTER == value31 then
			if value29.recog ~= 0 then
				local voice3, voice4 = import(".panel.voice", value3).handleCode(value29.recog)

				an.newMsgbox(voice4)
			end
		elseif SM_CHANNEL_EXIT == value31 then
			if value29.recog ~= 0 then
				local voice5, voice6 = import(".panel.voice", value3).handleCode(value29.recog)

				an.newMsgbox(voice6)
			end
		elseif SM_CHANNEL_CHANGE_MODE == value31 then
			if value29.recog ~= 0 then
				local voice7, voice8 = import(".panel.voice", value3).handleCode(value29.recog)

				an.newMsgbox(voice8)
			end
		elseif SM_CHANNEL_CHANGE_MUTE == value31 then
			if value29.recog ~= 0 then
				local voice9, voice10 = import(".panel.voice", value3).handleCode(value29.recog)

				an.newMsgbox(voice10)
			end
		elseif SM_CHANNEL_KICK_OUT == value31 then
			if value29.recog ~= 0 then
				local voice11, voice12 = import(".panel.voice", value3).handleCode(value29.recog)

				an.newMsgbox(voice12)
			end
		elseif SM_SEND_CHANNEL_LIST == value31 then
			if value.panels.voice then
				value.panels.voice:recvChannelList(value29, value30, value32)
			end
		elseif SM_SEND_CHANNEL_MEMBERS == value31 then
			if value29.series == 1 then
				g_data.voice:setMembers(value29, value30, value32, value29.tag, value2.getPlayerName())
			end

			if value.panels.voice then
				value.panels.voice:recvMemberList(value29, value30, value32, value29.tag, value29.series == 1)
			end
		elseif SM_NOTIFY_CHANNEL_ENTER == value31 then
			local value83 = net.str(value30)
			local value84, value85 = g_data.voice:memberJoin(value29.param, value83, value29.tag)

			if value84 and value.panels.voice then
				value.panels.voice:memberJoin(value84, value85)
			end
		elseif SM_NOTIFY_CHANNEL_EXIT == value31 then
			local value86 = net.str(value30)
			local value87, value88 = g_data.voice:memberExit(value86, value29.tag, value2.getPlayerName())

			if value87 then
				local text5

				if value29.tag == 1 then
					text5 = "你被管理员踢出语音频道"
				elseif value29.tag == 2 then
					text5 = "你已退出语音频道"
				elseif value29.tag == 3 then
					text5 = "你所在的语音频道已解散"
				end

				if value.panels.voice then
					value.panels.voice:exitChannel(value29.tag)

					if text5 then
						an.newMsgbox(text5)
					end
				elseif text5 then
					value2.addMsg(text5, display.COLOR_RED, display.COLOR_WHITE, true)
				end

				value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
			elseif value.panels.voice then
				value.panels.voice:memberExit(value86, value88)
			end
		elseif SM_NOTIFY_CHANNEL_CHANGE_MODE == value31 then
			local value89, value90 = g_data.voice:setMode(value29.param)

			if value89 and value.panels.voice then
				value.panels.voice:modeChanged(value90)
			end

			yaya.mic(false, value2.getPlayerName())
			value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
		elseif SM_NOTIFY_CHANNEL_CHANGE_MUTE == value31 then
			local value91 = net.str(value30)
			local value92, value93 = g_data.voice:setIsMute(value29.param, value91)

			if value92 and value.panels.voice then
				value.panels.voice:setIsMute(value92, value93)
			end

			if value91 == value2.getPlayerName() then
				yaya.mic(false, value2.getPlayerName())
				value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
			end
		elseif SM_NOTIFY_CHANNEL_CHANGE_ADMIN == value31 then
			local value94 = net.str(value30)
			local value95, value96 = g_data.voice:setIsAdmin(value29.param, value94)

			if value95 and value.panels.voice then
				value.panels.voice:setIsAdmin(value95, value96)
			end

			if value94 == value2.getPlayerName() then
				yaya.mic(false, value2.getPlayerName())
				value.console:call("btnVoiceJIT", "voice_call", "stateHasChanged")
			end
		elseif SM_QUERY_MAP_NPC == value31 then
			g_data.bigmap:addNpcs(value29, value30, value32)

			if value.panels.bigmap then
				value.panels.bigmap:uptNpcCell()
			end
		elseif SM_MEMBERS_POSITION_INFO == value31 then
			if value29.recog == 0 then
				g_data.bigmap:getGroupInfo(value29, value30, value32)

				if value.panels.bigmap then
					value.panels.bigmap:uptGroupPos()
				end
			end
		elseif SM_AUTOMOVE_MAPPATH == value31 then
			g_data.bigmap:scriptAutoPath(value29, value30, value32)
			main_scene.ui.console.controller.autoFindPath:scriptAutoPath()
		elseif SM_GHOME_PAY_READY == value31 then
			g_data.shop:onPayReady(value29.recog, value30, value2.getPlayerName())
		elseif SM_SEND_GHOME_ORDER_RESULT == value31 then
			g_data.shop:onPayResult(value29.recog, value30)
		elseif SM_GHOME_UNFINISH_ORDER == value31 then
			-- block empty
		elseif SM_PLAYER_AUTHEN == value31 then
			g_data.credit:setAuthen(value29)
		elseif SM_NOWDEATH == value31 then
			if value29.recog == g_data.player.roleid then
				value.centerTopTip:show("relive")
			end
		elseif SM_SEND_MAKEDDRUG_CONFIG == value31 then
			g_data.mixingDrug:saveConfig(value29, value30, value32)
		elseif SM_ALL_MAKEDRUG_STATUS == value31 then
			g_data.mixingDrug:set(value29, value30, value32)

			if value.panels.mixingDrug then
				value:hidePanel("mixingDrug")
			end

			value:showPanel("mixingDrug")
		elseif SM_MAKEDRUG_STATUS == value31 then
			local value97, value98 = g_data.mixingDrug:query(value29, value30, value32)

			if value97 and value98 and value.panels.mixingDrug then
				value.panels.mixingDrug:showDetail(value97, value98, value29.recog)
			end
		elseif SM_CAN_MAKEDRUG == value31 then
			if value29.param == 0 then
				value:tip("开始炼制")

				if value.panels.mixingDrug then
					value.panels.mixingDrug:refresh()
				end
			elseif value29.param == 1 then
				value:tip("材料不足")
			elseif value29.param == 2 then
				value:tip("金币不足")
			end
		elseif SM_GAIN_MAKEDDRUG == value31 then
			if value29.param == 1 then
				value:tip("存放成功")

				if value.panels.mixingDrug then
					value.panels.mixingDrug:refresh()
				end
			else
				value:tip("存放失败")
			end
		elseif SM_LEARN_LIVINGSKILL == value31 then
			if value29.recog == 1 then
				value:tip("学习成功")

				if value.panels.mixingDrug then
					value.panels.mixingDrug:refresh()
				end
			else
				value:tip("学习失败")
			end
		elseif SM_V_POWERSTONE == value31 then
			local text6 = ""

			if value29.param == 0 then
				local text7 = "充满着能量波动的神秘水晶，使用它可以使你增加1点活力值。"

				text6 = string.format("%s\n每个角色一天只能使用12个活力水晶,今日还可以使用%d个。", text7, value29.tag)
			elseif value29.param == 1 then
				text6 = "活力值已达上限"
			elseif value29.param == 2 then
				text6 = "今日使用个数已达上限"
			end

			an.newMsgbox(text6, function(value33)
				if value33 == 1 and value29.param == 0 and g_data.bag:use("eat", value29.recog, {
					quick = false
				}) then
					net.send({
						CM_EAT,
						recog = value29.recog
					})

					if value29.series == 1 then
						value.panels.bag:delItem(value29.recog)
					end
				end
			end, {
				center = true,
				btnTexts = {
					"确定",
					value29.param == 0 and "取消" or nil
				}
			})
		elseif SM_BOX2_TRYOPEN == value31 then
			if value29.recog == 0 then
				value:showPanel("treasureBox", value29.param, value30, value32)
			else
				value:tip(net.str(value30))
			end
		elseif SM_BOX2_ROTATE == value31 then
			if value29.recog == 0 then
				if value.panels.treasureBox then
					print(value29.param)
					value.panels.treasureBox:onRotate(value29.param)
				end
			else
				value:tip(net.str(value30))
			end
		elseif SM_BOX2_GETPRIZE == value31 then
			if value29.recog == 0 then
				if value.panels.treasureBox then
					value.panels.treasureBox:onGetPrize(value29.param)
				end
			else
				value:tip(net.str(value30))
			end
		else
			return false
		end

		return true
	end
}
