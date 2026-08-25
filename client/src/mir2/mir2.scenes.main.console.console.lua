local current = ...
local common = import("..common.common")
local replaceAsk = import(".replaceAsk")
local widgetDef = import(".widget._def")
local widgetDelegate = import(".widget._delegate")
local console = class("console", function ()
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
	saveList = "_list",
	btnAreaBegin = 23,
	btnAreaSpace = 75,
	saveCurrent = "_current",
	btnAreaLineNum = display.width - 960 > 80 and 4 or 3,
	z = {
		btnAreaBg = 2,
		editBg = 1,
		widget = 10
	}
})

function console:ctor()
	g_data.mark.playerName = common.getPlayerName()
	local datas = cache.getDiy(common.getPlayerName(), self.saveCurrent)
	datas = datas or clone(widgetDef.default)

	if WIN32_OPERATE then
		for _, info in ipairs(widgetDef.default_pc) do
			local exist = false

			for _, v in ipairs(datas) do
				if info.key == v.key then
					exist = true
				end
			end

			if not exist then
				table.insert(datas, info)
			end
		end

		g_data.bag.customs = cache.getCustoms(common.getPlayerName())
	end

	self.widgets = {}

	for i, v in ipairs(datas) do
		local config = widgetDef.getConfig(v)

		if config.btntype ~= "custom" or WIN32_OPERATE then
			self:addWidget(v)
		end
	end

	self:size(display.width, display.height)

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
	local config = widgetDef.getConfig(data)

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
		btn = node.btn or node

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
				replaceAsk.new(existBtn, function (operator)
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
	pos = string.split(pos, "-")
	local x = display.width - (pos[2] - 0.5) * self.btnAreaSpace - self.btnAreaBegin
	local y = (pos[1] - 0.5) * self.btnAreaSpace + self.btnAreaBegin

	return x, y
end

function console:pos2btnpos(x, y)
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

		if x ~= v:getPositionX() or y ~= v:getPositionY() then
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
		v:show()
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

function console:showEditBg(b)
	if not self.editBg then
		self.editBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 128)):size(display.width, display.height):add2(self, self.z.editBg)

		display.newNode():size(self.editBg:getContentSize()):add2(self.editBg):enableClick(function ()
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
		self.btnBg = display.newScale9Sprite(res.getframe2("pic/scale/scale6.png"), rect.x, rect.y, cc.size(rect.width, rect.height)):anchor(0, 0):add2(self, self.z.btnAreaBg)
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
	if g_data.player.job == 0 then
		self.widgets.btnPet:hide()
	end
end

return console
