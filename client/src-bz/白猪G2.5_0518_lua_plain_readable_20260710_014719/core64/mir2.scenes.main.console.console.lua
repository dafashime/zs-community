local current = ...
local common = import("..common.common")
local replaceAsk = import(".replaceAsk")
local widgetDef = import(".widget._def")
local widgetDelegate = import(".widget._delegate")
local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local console = class("console", function()
	return display.newNode()
end)

table.merge(console, {
	widgets,
	editting,
	controller,
	skills,
	btnCallbacks,
	editBg,
	btnBg,
	btnAreaMaxLine = 6,
	btnAreaBegin = 23,
	btnAreaSpace = 75,
	saveList = "_list",
	saveCurrent = "_current",
	btnAreaLineNum = display.width - 960 > 80 and 4 or 3,
	z = {
		editBg = 1,
		btnAreaBg = 2,
		widget = 10
	}
})

function console:ctor()
	g_data.mark.playerName = common.getPlayerName()

	local datas = cache.getDiy(common.getPlayerName(), self.saveCurrent) or clone(widgetDef.default)

	g_data.setting.chat.whisperLimit = 1
	g_data.setting.base.heroFollow = false
	self.widgets = {}

	for i, v in ipairs(datas) do
		if widgetDef.getConfig(v) ~= nil then
			self.addWidget(self, v)
		end
	end

	self.size(self, display.width, display.height)

	self.controller = import(".controller", current).new(self)
	self.skills = import(".skills", current).new(self)
	self.btnCallbacks = import(".btnCallbacks", current).new(self)
	self.autoRat = import(".autoRat", current).new(self)
end

function console:resetAutoRat()
	self.autoRat = import(".autoRat", current).new(self)
end

function console:get(key)
	return self.widgets[key]
end

function console:setWidgetSelect(key, select)
	local wid = self:get(key)

	if wid and wid.btn.setIsSelect then
		wid.btn:setIsSelect(select)
	end
end

function console:call(key, method, ...)
	local inst = self:get(key)

	if inst and inst[method] then
		inst[method](inst, ...)
	end
end

function console:addWidget(data, ani)
	local config = widgetDef.getConfig(data) or data

	if config then
		if config.fixedX then
			data.x = config.fixedX
		end

		if config.fixedY then
			data.y = config.fixedY
		end

		local node = import(".widget." .. config.class, current).new(config, data):add2(self, config.z or self.z.widget)

		node.data = data
		node.config = config

		local btn = node.btn or node

		if config.key == "btnSkillTemp" then
			btn:setName("diy_" .. data.key)
		else
			btn:setName("diy_" .. config.name)
		end

		self.widgets[data.key] = widgetDelegate.extend(node, self)

		self:resetBtnAreaBtnPos(node, ani)

		if self.editting then
			node:_startEdit()
		end
	end

	if main_scene.ui and main_scene.ui.panels.diy then
		main_scene.ui.panels.diy:checkSelect(data.key, self)
	end
end

function console:addWidgetByPanel(data, form)
	if self:get(data.key) then
		return "exist"
	end

	local config = widgetDef.getConfig(data)

	if not config then
		return
	end

	if config.class == "btnMove" then
		local btnpos = self:pos2btnpos(data.x, data.y)

		if btnpos then
			local existBtn = self:findWidgetWithBtnpos(btnpos)

			if existBtn then
				replaceAsk.new(existBtn, function(operator)
					if operator == "replace" then
						self:removeWidget(existBtn.data.key)

						data.btnpos = btnpos

						self:addWidget(data, true)
					end
				end, form):setName("replaceAskNode")
			else
				data.btnpos = btnpos

				self:addWidget(data, true)
			end
		else
			self:addWidget(data)
		end

		return
	end

	self:addWidget(data)
end

function console:removeWidget(key)
	if self.widgets[key] then
		self.widgets[key]:removeSelf()

		self.widgets[key] = nil
	end

	if main_scene.ui and main_scene.ui.panels.diy then
		main_scene.ui.panels.diy:checkSelect(key, self)
	end
end

function console:btnpos2pos(pos)
	if self.btnpos2pos1 and self:openAreaRange() then
		return self:btnpos2pos1(pos)
	end

	pos = string.split(pos, "-")

	local x = display.width - (pos[2] - 0.5) * self.btnAreaSpace - self.btnAreaBegin
	local y = (pos[1] - 0.5) * self.btnAreaSpace + self.btnAreaBegin

	return x, y
end

function console:pos2btnpos(x, y)
	if self.pos2btnpos1 and self:openAreaRange() then
		return self:pos2btnpos1(x, y)
	end

	local rect = self:getBtnAreaRect()

	if not cc.rectContainsPoint(rect, cc.p(x, y)) then
		return
	end

	x = x - rect.x
	x = self.btnAreaLineNum - math.modf(x / self.btnAreaSpace)
	x = math.max(1, math.min(x, self.btnAreaLineNum))
	y = y - self.btnAreaBegin
	y = math.modf(y / self.btnAreaSpace) + 1
	y = math.max(1, math.min(y, self.btnAreaMaxLine))

	return y .. "-" .. x
end

function console:findWidgetWithBtnpos(pos)
	for k, v in pairs(self.widgets) do
		if v.__cname == "btnMove" and v.data.btnpos and v.data.btnpos == pos then
			return v
		end
	end
end

function console:resetBtnAreaBtnPos(v, ani)
	if v.__cname == "btnMove" and v.data.btnpos then
		local x, y = self:btnpos2pos(v.data.btnpos)

		if x and y and (x ~= v:getPositionX() or y ~= v:getPositionY()) then
			if ani then
				v:moveTo(0.1, x, y)
			else
				v:pos(x, y)
			end
		end
	end
end

function console:resetAllBtnAreaBtnPos(ani)
	for k, v in pairs(self.widgets) do
		self:resetBtnAreaBtnPos(v, ani)
	end
end

function console:startEdit()
	self:call("btnMode", "showModeSelect")

	for k, v in pairs(self.widgets) do
		v:_startEdit()

		if not v.hide then
			v:show()
		end
	end

	self:hidePet()

	self.editting = true
end

function console:endEdit()
	for k, v in pairs(self.widgets) do
		v:_endEdit()
	end

	self.editting = false

	self:saveEdit()
end

function console:saveEdit(filename)
	local datas = {}
	local nodes = sortNodes(table.values(self.widgets))

	for i, v in ipairs(nodes) do
		table.insert(datas, 1, v.data)
	end

	cache.saveDiy(common.getPlayerName(), filename or self.saveCurrent, datas)
end

function console:showRect(widget, key)
	self:hideAllRect()

	widget = widget or self:get(key)

	if not widget then
		return
	end

	widget:_showRect()
end

function console:hideAllRect()
	for k, v in pairs(self.widgets) do
		v:_hideRect()
	end
end

function console:openAreaRange()
	return def.openArangeSkills and self:getjson() ~= nil
end

function console:showEditBg(b)
	if not self.editBg then
		if self:openAreaRange() then
			self.editBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 50)):size(display.width, display.height):add2(self, self.z.editBg)

			for _, skillbg in pairs(self:getjson().skillbg) do
				self.skillbg = res.get2("pic/console/newskill/Skill_bg.png"):addto(self.editBg):anchor(0.5, 0.5)

				self.skillbg:pos(display.width - skillbg.x, skillbg.y)
			end
		else
			self.editBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 128)):size(display.width, display.height):add2(self, self.z.editBg)
		end

		display.newNode():size(self.editBg:getContentSize()):add2(self.editBg):enableClick(function()
			self:hideAllRect()
		end)
	end

	self.editBg:setVisible(b)
end

function console:getBtnAreaRect()
	return cc.rect(display.width - self.btnAreaSpace * self.btnAreaLineNum - self.btnAreaBegin, 0, self.btnAreaSpace * self.btnAreaLineNum + self.btnAreaBegin, self.btnAreaSpace * self.btnAreaMaxLine + self.btnAreaBegin)
end

function console:checkBtnAreaShow(p, isHide)
	local rect = self:getBtnAreaRect()

	if p then
		isHide = isHide or not cc.rectContainsPoint(rect, p)
	end

	if not self.btnBg then
		if def.openArangeSkills then
			self.btnBg = display.newScale9Sprite(res.getframe2("pic/scale/skill11.png"), rect.x, rect.y, cc.size(rect.width, rect.height)):anchor(0, 0):add2(self, self.z.btnAreaBg)
		else
			self.btnBg = display.newScale9Sprite(res.getframe2("pic/scale/scale6.png"), rect.x, rect.y, cc.size(rect.width, rect.height)):anchor(0, 0):add2(self, self.z.btnAreaBg)
		end
	end

	self.btnBg:setVisible(not isHide)
end

function console:fillPropTest()
	for k, v in pairs(self.widgets) do
		if v.config.btntype == "prop" then
			v:prop_fill_test()
		end

		if v.config.btntype == "custom" then
			v:custom_fill_test()
		end
	end
end

function console:update(dt)
	for k, v in pairs(self.widgets) do
		if v.update then
			v:update(dt)
		end
	end

	self.controller:update(dt)
end

function console:hidePet()
	return
end

function console:showDark(data, dark1)
	if data then
		self.dark1 = cc.LayerColor:create(cc.c4b(0, 0, 0, dark1)):size(display.width, display.height)
	end

	if self.dark1 then
		self.dark1:setVisible(data)
	end

	local background = display.newScale9Sprite("pic/common/alphaAtkBg.png", 0, 0, cc.size(200, 200)):anchor(0, 0)
	local node = cc.ClippingNode:create(background)

	node:addChild(self.dark1)
	node:setAlphaThreshold(0.1)
	node:add2(self, self.z.editBg)
end

function console:getjson()
	local skillbgOwner = parseJson("config/Skillconfig.json")

	if skillbgOwner and def.calcRange then
		if not def.rangeCorPos then
			def.rangeCorPos = {}

			local function callback(self, value2, value4, value6, value7, value8)
				local value = self
				local value3 = value2
				local value5 = value4 or 50
				local count = 0
				local count2 = 0
				local console = {}
				local value9 = (value7 - value6) / value8
				local count3 = 0

				for index = value6, value7, value9 do
					count3 = count3 + 1

					if value8 < count3 then
						break
					end

					local x = value + value5 * math.cos(-index * math.pi / 180)
					local y = value3 + value5 * math.sin(-index * math.pi / 180)

					table.insert(console, {
						x = x,
						y = y
					})
				end

				return console
			end

			local function callback2(self, value2, value4, value6, value7, value8)
				local value = self
				local value3 = value2
				local value5 = value4 or 50
				local count = 0
				local count2 = 0
				local items = {}
				local value9 = (value7 - value6) / value8
				local count3 = 0

				for index = value6, value7, value9 do
					count3 = count3 + 1

					if value8 < count3 then
						break
					end

					local x = value + value5 * math.cos(-index * math.pi / 180)
					local y = value3 + value5 * math.sin(-index * math.pi / 180)

					table.insert(items, {
						x = x,
						y = y
					})
				end

				return items
			end

			local items = {
				display.width - 50,
				75,
				160,
				180,
				300,
				4
			}
			local items2 = {
				display.width - 55,
				75,
				230,
				180,
				298,
				5
			}

			if def.rangePosParams then
				items = def.rangePosParams.range1 or items
				items2 = def.rangePosParams.range2 or items2
			end

			local value = callback(unpack(items))
			local value2 = callback2(unpack(items2))
			local idx = 1

			for _, item in ipairs(value) do
				table.insert(def.rangeCorPos, {
					idx = idx,
					x = display.width - item.x,
					y = item.y
				})

				idx = idx + 1
			end

			for _2, item2 in ipairs(value2) do
				table.insert(def.rangeCorPos, {
					idx = idx,
					x = display.width - item2.x,
					y = item2.y
				})

				idx = idx + 1
			end
		end

		skillbgOwner.skillbg = def.rangeCorPos
	end

	return skillbgOwner
end

function console:skillrectpos(skillData)
	return cc.rect(skillData.x - 26, skillData.y - 26, 52, 52)
end

function console:skillrectpos1(skillData)
	return cc.rect(skillData.x - 26, skillData.y - 26, 75, 75)
end

function console:openRange()
	return self:getjson() ~= nil
end

function console:skillBtnShow(skillData, level)
	local value, y = self:skillShowpos(skillData, level)

	if self.skillBg then
		self.skillBg:removeSelf()

		self.skillBg = nil
	end

	if value and y then
		self.skillBg = display.newScale9Sprite(res.getframe2("pic/console/newskill/skillcore.png")):anchor(0.5, 0.5):add2(self, 999)

		self.skillBg:size(80, 80):pos(display.width - value, y)

		return btns
	end
end

function console:skillShowpos(skillData, level)
	if self:getjson() ~= nil then
		for _, curAtkpo in ipairs(self:getjson().curAtkpos) do
			if cc.rectContainsPoint(self:skillrectpos1(curAtkpo), cc.p(math.ceil(display.width - skillData), level)) then
				return curAtkpo.x, curAtkpo.y
			end
		end
	end
end

function console:btnpos2pos1(parts)
	parts = string.split(parts, "-")

	if tonumber(parts[2]) > 0 then
		local value = display.width - (parts[2] - 0.5) * self.btnAreaSpace - self.btnAreaBegin
		local value2 = (parts[1] - 0.5) * self.btnAreaSpace + self.btnAreaBegin

		return value, value2
	elseif self:getjson() ~= nil then
		for _, skillbg in ipairs(self:getjson().skillbg) do
			if skillbg.idx == tonumber(parts[1]) then
				return display.width - skillbg.x, skillbg.y
			end
		end
	end
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function console:pos2btnpos1(x, y)
	local btnAreaRect = self:getBtnAreaRect()

	if self:getjson() ~= nil then
		for _, skillbg in ipairs(self:getjson().skillbg) do
			if cc.rectContainsPoint(self:skillrectpos(skillbg), cc.p(math.ceil(display.width - x), y)) then
				return skillbg.idx .. "-0"
			end
		end

		for _2, curAtkpo in ipairs(self:getjson().curAtkpos) do
			if cc.rectContainsPoint(self:skillrectpos1(curAtkpo), cc.p(math.ceil(display.width - x), y)) then
				return curAtkpo.idx .. "-10"
			end
		end
	end

	if not cc.rectContainsPoint(btnAreaRect, cc.p(x, y)) then
		return
	end

	x = x - btnAreaRect.x
	x = self.btnAreaLineNum - math.modf(x / self.btnAreaSpace)
	x = math.max(1, math.min(x, self.btnAreaLineNum))
	y = y - self.btnAreaBegin
	y = math.modf(y / self.btnAreaSpace) + 1
	y = math.max(1, math.min(y, self.btnAreaMaxLine))

	return y .. "-" .. x
end

function console:genExtend(value, value2)
	cc2.ms({
		function()
			extendUI.create(self, value, "console_ext", nil, nil, nil, value2)
		end
	})
end

return console
