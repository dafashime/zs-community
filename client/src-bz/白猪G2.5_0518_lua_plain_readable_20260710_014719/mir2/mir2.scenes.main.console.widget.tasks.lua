local count = 0
local value = display.height - 50
local height = 188
local width = 270
local widget_tasks = class("widget.tasks", function()
	return display.newNode()
end)

local function updateVisible()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

local function updateVisible2(self, value2, value3, value4)
	return math.sqrt((self - value3)^2 + (value2 - value4)^2)
end

local function updateVisible3(self, value2, value3, value4)
	local items = {}

	for _, item in pairs(value3) do
		local distance = updateVisible2(self, value2, item.x, item.y)

		table.insert(items, {
			distance = distance,
			mon = item
		})
	end

	table.sort(items, function(distanceOwner, distanceOwner2)
		return distanceOwner.distance < distanceOwner2.distance
	end)

	local items2 = {}

	for index = 1, math.min(value4, #items) do
		table.insert(items2, items[index].mon)
	end

	local items3 = {}

	return items2
end

table.merge(widget_tasks, {
	tspr,
	modeChooseNode,
	curModeChooseIsShow,
	baseDir = "pic/bzmir/newui/tasks/",
	taskShow = true,
	taskOn = true
})

function widget_tasks.ctor(self, config, data)
	local x = data.x

	if updateVisible() then
		x = x + getSafeAreaInsets()
	end

	self:pos(x, data.y)
	self:size(width, height)

	self.taskShow = g_data.setting.base.taskShow
	self.btnTask = an.newBtn(res.gettex2(self.baseDir .. "taskon.png"), function()
		self.btnTask.sprite:setTex(res.gettex2(self.baseDir .. "taskon.png"))
		self.funTask.sprite:setTex(res.gettex2(self.baseDir .. "funoff.png"))

		self.taskOn = true

		self:switchTab(self.taskOn)
	end, {
		sprite = res.gettex2(self.baseDir .. "taskon.png")
	}):addTo(self):pos(0, self:geth()):anchor(0, 1)
	self.tspr = res.get2(self.baseDir .. "bg.png"):add2(self):pos(self.btnTask:getw(), self:geth()):anchor(0, 1)

	local value2 = g_data.setting.base.defaultTaskTab == nil or g_data.setting.base.defaultTaskTab

	self.taskView = display.newNode():addto(self.tspr):pos(0, 0):size(self.tspr:getw(), self.tspr:geth())

	self.taskView:setVisible(value2)

	self.taskView.scroll = an.newScroll(0, 0, self.tspr:getw(), self.tspr:geth()):addTo(self.taskView):anchor(0, 1):pos(0, self.tspr:geth())
	self.nearView = display.newNode():addto(self.tspr):pos(0, 0):size(self.tspr:getw(), self.tspr:geth())

	self.nearView:setVisible(false)

	self.nearView.scroll = an.newScroll(0, 0, self.tspr:getw(), self.tspr:geth() - 30):addTo(self.nearView):anchor(0, 1):pos(0, self.tspr:geth() - 30)

	self:initNearView()

	self.funView = display.newNode():addto(self.tspr):pos(0, 0):size(self.tspr:getw(), self.tspr:geth())

	self.funView:setVisible(not value2)
	self:initFunViews()

	self.btnModes = an.newBtn(res.gettex2(self.baseDir .. "mode/quanti.png"), function()
		if main_scene.ground:smr() then
			main_scene.ui:tip("乱斗模式无法更改模式")
		elseif def.role.mainsetting.banChgMode then
			main_scene.ui:tip("该地图不支持更改模式")
		else
			self:showModeSelect(not self.curModeChooseIsShow)
		end
	end, {
		sprite = res.gettex2(self.baseDir .. "mode/quanti.png")
	}):addTo(self, 99):pos(self.btnTask:getw() / 2, self.tspr:geth() / 2):anchor(0.5, 0.5)
	self.funTask = an.newBtn(res.gettex2(self.baseDir .. "funoff.png"), function()
		self.funTask.sprite:setTex(res.gettex2(self.baseDir .. "funon.png"))
		self.btnTask.sprite:setTex(res.gettex2(self.baseDir .. "taskoff.png"))

		self.taskOn = false

		self:switchTab(self.taskOn)
	end, {
		sprite = res.gettex2(self.baseDir .. "funoff.png")
	}):addTo(self):pos(0, 0):anchor(0, 0)
	self.menu = an.newBtn(res.gettex2(self.baseDir .. "menu.png"), function()
		self:resetTaskPanel(self.taskShow)
	end, {
		pressImage = res.gettex2(self.baseDir .. "menu-press.png")
	}):add2(self):pos(self.btnTask:getw() + self.tspr:getw() + 5, self:geth()):anchor(0, 1)
	self.menuon = res.get2(self.baseDir .. "menuoff.png"):add2(self.menu):pos(self.menu:getw() / 2, self.menu:geth() / 2)
	self.data = data
	self.config = config

	self.upt(self)

	if not self.taskShow then
		local position, position2 = self.tspr:getPosition()

		self.tspr:run(cc.MoveTo:create(0.3, cc.p(position - display.width, position2)))

		local position3, position4 = self.menu:getPosition()

		self.menu:run(cc.MoveTo:create(0.3, cc.p(position3 - 205, position4)))
		self.menuon:setTex(res.gettex2(self.baseDir .. "menuon.png"))
	end

	if g_data.setting.base.defaultTaskTab then
		self.btnTask.sprite:setTex(res.gettex2(self.baseDir .. "taskon.png"))
		self.funTask.sprite:setTex(res.gettex2(self.baseDir .. "funoff.png"))
	else
		self.btnTask.sprite:setTex(res.gettex2(self.baseDir .. "taskoff.png"))
		self.funTask.sprite:setTex(res.gettex2(self.baseDir .. "funon.png"))
	end

	self:findNears()
end

function widget_tasks.getLockState(self, infoOwner)
	if not main_scene or not main_scene.ground or not main_scene.ground.player or not main_scene.ground.player.info then
		return "", display.COLOR_WHITE
	end

	if not infoOwner or not infoOwner.info then
		return "", display.COLOR_WHITE
	end

	local function callback()
		local count2 = 0

		if g_data.player.attackMode and type(g_data.player.attackMode) == "string" then
			count2 = (g_data.player.attackMode:find("全体攻击模式") ~= nil or g_data.player.attackMode:find("和平攻击模式") ~= nil) and 0 or g_data.player.attackMode:find("行会攻击模式") ~= nil and 1 or g_data.player.attackMode:find("组队攻击模式") ~= nil and 2 or g_data.player.attackMode:find("善恶攻击模式") ~= nil and 3 or g_data.player.attackMode:find("战队攻击模式") ~= nil and 4 or 5
		end

		return count2
	end

	local value2
	local value3 = callback()
	local value4 = main_scene.ground.player.info.guildName
	local value5 = main_scene.ground.player.info.campId

	if g_data.hero and g_data.hero.name then
		value2 = g_data.hero.name
	end

	local realName = infoOwner.info:getRealName()

	if realName then
		if realName == value2 or realName == main_scene.ground.player.info:getRealName() then
			return "", display.COLOR_WHITE
		elseif value5 then
			return "[敌]", display.COLOR_RED
		elseif value3 == 0 then
			return "", display.COLOR_WHITE
		elseif value3 == 1 then
			if value4 and g_data.guild.allGuildMems then
				local enabled = false

				for _, allGuildMem in pairs(g_data.guild.allGuildMems) do
					if allGuildMem.name == realName then
						enabled = true

						break
					end
				end

				if enabled then
					return "[会]", display.COLOR_GREEN
				else
					return "", display.COLOR_WHITE
				end
			else
				return "", display.COLOR_WHITE
			end
		elseif value3 == 2 then
			if g_data.player.groupMembers then
				local enabled2 = false

				for _2, groupMember in ipairs(g_data.player.groupMembers) do
					if realName == groupMember.name then
						enabled2 = true

						break
					end
				end

				if enabled2 then
					return "[队]", display.COLOR_GREEN
				else
					return "", display.COLOR_WHITE
				end
			else
				return "", display.COLOR_WHITE
			end
		elseif value3 == 3 then
			if g_data.guild.guildHostile then
				local enabled3 = false

				for _3, guildHostile in ipairs(g_data.guild.guildHostile) do
					if infoOwner.info.guildName == guildHostile.name then
						enabled3 = true

						break
					end
				end

				if enabled3 then
					return "[敌]", display.COLOR_RED
				else
					return "", display.COLOR_WHITE
				end
			end

			return "", display.COLOR_WHITE
		elseif value3 == 4 then
			if g_data.guild.allCorpsMem then
				local enabled4 = false

				for _4, allCorpsMem in pairs(g_data.guild.allCorpsMem) do
					if realName == allCorpsMem.name then
						enabled4 = true

						break
					end
				end

				if enabled4 then
					return "[会]", display.COLOR_GREEN
				else
					return "", display.COLOR_WHITE
				end
			else
				return "", display.COLOR_WHITE
			end
		elseif value3 == 5 then
			return "", display.COLOR_WHITE
		end
	end

	return "", display.COLOR_WHITE
end

function widget_tasks.findNears(self)
	g_data.nearTimer = scheduler.scheduleGlobal(function()
		if not main_scene or not main_scene.ground or not main_scene.ground.map then
			scheduler.unscheduleGlobal(g_data.nearTimer)

			g_data.nearTimer = nil

			return
		end

		if not self or not self.nearView then
			scheduler.unscheduleGlobal(g_data.nearTimer)

			g_data.nearTimer = nil

			return
		end

		if self.finding then
			return
		end

		self.finding = true

		for index = 1, 10 do
			local player = self.nearView.roleItems[index]

			player.roleLabel:setString("")
			player.roleLabel:setColor(display.COLOR_WHITE)

			if player.roleBg.selectPic then
				player.roleBg.selectPic:removeSelf()

				player.roleBg.selectPic = nil
			end

			player.roleid = nil

			player.sprhp:setVisible(false)
			player.sprhp:setp(1)
			player.lblhp:setString("")
			player.rolePosLabel:setString("")
		end

		local function updateVisible4(roleid, value2)
			local player = self.nearView.roleItems[value2]
			local name = roleid.info:getName()

			if name then
				player.roleLabel:setString(name)
				player.rolePosLabel:setString("(" .. roleid.x .. ":" .. roleid.y .. ")")
				player.rolePosLabel:setPositionX(8 + player.roleLabel:getw())

				player.roleid = roleid.roleid

				player.sprhp:setVisible(true)

				if roleid.info.hp.cur and roleid.info.hp.max then
					local value3 = roleid.info.hp.cur / roleid.info.hp.max

					if value3 > 1 then
						value3 = 1
					end

					if value3 < 0 then
						value3 = 0
					end

					player.sprhp:setp(value3)
					player.lblhp:setString(roleid.info.hp.cur .. "/" .. roleid.info.hp.max)
				end

				local player2 = main_scene.ui.console.controller.lock.role

				if player2 and player2.roleid == roleid.roleid then
					player.roleBg.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(190, 42)):add2(player.roleBg):pos(0, 0):anchor(0, 0)
				end

				if roleid.__cname == "hero" then
					local lockState, lockState2 = self:getLockState(roleid)

					player.roleLabel:setString(lockState .. player.roleLabel:getString())
					player.rolePosLabel:setPositionX(8 + player.roleLabel:getw())
					player.roleLabel:setColor(lockState2)
				end

				return true
			end
		end

		if self.nearView.show == "mon" then
			local point = main_scene.ground.player
			local value2 = updateVisible3(point.x, point.y, main_scene.ground.map.mons, 10)
			local count2 = 1

			for _, item in pairs(value2) do
				if item and not item.die and not item:isPolice() and not item.isDummy and not item.info:isPet() and not item.isHaveMaster and updateVisible4(item, count2) then
					count2 = count2 + 1
				end
			end

			local items = {}
		else
			local point2 = main_scene.ground.player
			local value3 = updateVisible3(point2.x, point2.y, main_scene.ground.map.heros, 10)
			local value4

			if g_data.hero and g_data.hero.name then
				value4 = g_data.hero.name
			end

			local count3 = 1

			for _2, item2 in pairs(value3) do
				if item2 and not item2.die and not item2.isPlayer and item2.info:getRealName() ~= value4 and not def.stateIsHave(item2.state, "stRealHidden") and updateVisible4(item2, count3) then
					count3 = count3 + 1
				end
			end

			local items2 = {}
		end

		self.finding = false
	end, 0.5)
end

function widget_tasks.switchTab(self, value2)
	self.nearView:setVisible(false)
	self.taskView:setVisible(value2)
	self.funView:setVisible(not value2)
end

function widget_tasks.resetTaskPanel(self, taskShow)
	local position, position2 = self.tspr:getPosition()

	if taskShow then
		self.tspr:run(cc.MoveTo:create(0.3, cc.p(position - display.width, position2)))
	else
		self.tspr:run(cc.MoveTo:create(0.3, cc.p(position + display.width, position2)))
	end

	local position3, position4 = self.menu:getPosition()

	if taskShow then
		self.menu:run(cc.MoveTo:create(0.3, cc.p(position3 - 205, position4)))
		self.menuon:setTex(res.gettex2(self.baseDir .. "menuon.png"))
	else
		self.menu:run(cc.MoveTo:create(0.2, cc.p(position3 + 205, position4)))
		self.menuon:setTex(res.gettex2(self.baseDir .. "menuoff.png"))
	end

	self.taskShow = not taskShow

	if main_scene and main_scene.ui and main_scene.ui.panels.heroHead and main_scene.ui.panels.heroHead:isInPos() then
		main_scene.ui.panels.heroHead:resetPanelPosition(self.taskShow)
	end
end

function widget_tasks.initFunViews(self)
	local function updateVisible4(self2, x, y, callback)
		local label = an.newLabel(self2, 18, 1, {
			color = display.COLOR_GREEN
		}):anchor(0.5, 1):addTo(self.funView):pos(x, y)

		label:addUnderline(display.COLOR_GREEN)
		label:setTouchEnabled(true)
		label:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(startPos)
			if startPos.name == "began" then
				label:scale(1.1):setColor(cc.c3b(255, 0, 0))

				label.disable = false
				label.startPos = cc.p(startPos.x, startPos.y)

				return true
			elseif startPos.name == "ended" then
				label:scale(1):setColor(display.COLOR_GREEN)

				if not label.disable and callback then
					callback()
				end
			elseif cc.pGetDistance(label.startPos, startPos) > 35 then
				label:scale(1):setColor(display.COLOR_GREEN)

				label.disable = true
			end
		end)
	end

	updateVisible4("附近玩家", 50, 155, function()
		self:showNear(false)
	end)
	updateVisible4("附近怪物", 145, 155, function()
		self:showNear(true)
	end)
	updateVisible4("我的队伍", 50, 75, function()
		if main_scene.ui.panels.group then
			main_scene.ui.panels.group:showPageInfo("mine", g_data.player.groupMembers)
		else
			main_scene.ui:togglePanel("group")
		end
	end)
	updateVisible4("我的界面", 145, 75, function()
		main_scene.ui:togglePanel("diy")
	end)
end

function widget_tasks.initNearView(self)
	local color = cc.c3b(189, 186, 185)

	an.newBtn(res.gettex2(self.baseDir .. "near/navback.png"), function()
		self.nearView:setVisible(false)
		self.taskView:setVisible(false)
		self.funView:setVisible(true)
	end, {
		pressBig = true
	}):addTo(self.nearView):pos(5, self.nearView:geth() - 18):anchor(0, 0.5)

	self.nearRole = an.newLabel("附近玩家", 18, 1, {
		color = color
	}):anchor(0, 0.5):addTo(self.nearView):pos(25, self.nearView:geth() - 18)

	self.nearRole:addUnderline(color)
	self.nearRole:setTouchEnabled(true)
	self.nearRole:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x)
		if x.name == "began" then
			self.nearRole.preColor = self.nearRole.color

			self.nearRole:scale(1.1):setColor(cc.c3b(255, 0, 0))

			self.nearRole.disable = false
			self.nearRole.startPos = cc.p(x.x, x.y)

			return true
		elseif x.name == "ended" then
			self.nearRole:scale(1):setColor(display.COLOR_GREEN)

			if not self.nearRole.disable then
				self.nearMon:setColor(color)

				self.nearView.show = "role"
			end
		elseif cc.pGetDistance(self.nearRole.startPos, x) > 35 then
			self.nearRole:scale(1):setColor(self.nearRole.preColor)

			self.nearRole.disable = true
		end
	end)

	self.nearMon = an.newLabel("附近怪物", 18, 1, {
		color = color
	}):anchor(0, 0.5):addTo(self.nearView):pos(115, self.nearView:geth() - 18)

	self.nearMon:addUnderline(color)
	self.nearMon:setTouchEnabled(true)
	self.nearMon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(x)
		if x.name == "began" then
			self.nearMon.preColor = self.nearMon.color

			self.nearMon:scale(1.1):setColor(cc.c3b(255, 0, 0))

			self.nearMon.disable = false
			self.nearMon.startPos = cc.p(x.x, x.y)

			return true
		elseif x.name == "ended" then
			self.nearMon:scale(1):setColor(display.COLOR_GREEN)

			if not self.nearMon.disable then
				self.nearRole:setColor(color)

				self.nearView.show = "mon"
			end
		elseif cc.pGetDistance(self.nearMon.startPos, x) > 35 then
			self.nearMon:scale(1):setColor(self.nearMon.preColor)

			self.nearMon.disable = true
		end
	end)

	self.nearView.show = "mon"
	self.nearView.roleItems = {}

	local h = self.nearView.scroll:geth()

	for index = 1, 10 do
		local node = display.newNode():addto(self.nearView.scroll):pos(7, h):size(self.tspr:getw() - 20, 45):anchor(0, 1)

		node.roleLabel = an.newLabel("" .. index, 15, 1, {
			color = display.COLOR_WHITE
		}):anchor(0, 1):addTo(node):pos(8, node:geth() - 5)
		node.rolePosLabel = an.newLabel("", 13, 1, {
			color = cc.c3b(222, 217, 169)
		}):anchor(0, 1):addTo(node):pos(8 + node.roleLabel:getw(), node:geth() - 8)
		node.sprhp = an.newProgress(res.gettex2(self.baseDir .. "near/hp.png"), res.gettex2(self.baseDir .. "near/hp1.png"), {
			x = 0,
			y = 0
		}):anchor(0, 1):pos(8, 17):add2(node)
		node.lblhp = an.newLabel("", 10, 1, {
			bufferChannel = 0
		}):pos(node.sprhp:getw() / 2, node.sprhp:geth() / 2 - 1):anchor(0.5, 0.5):add2(node.sprhp, 1)

		node.sprhp:setp(1)

		node.roleBg = display.newScale9Sprite(res.getframe2("pic/scale/scale22.png"), 0, 0, cc.size(190, 42)):add2(node):pos(0, 0):anchor(0, 0)

		node.roleBg:setTouchEnabled(true)
		node.roleBg:setTouchSwallowEnabled(false)
		node.roleBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(point)
			if point.name == "began" then
				node.roleBg.offsetBeginY = point.y

				return true
			elseif point.name == "ended" then
				if not node.roleid then
					return
				end

				local value2 = point.y - node.roleBg.offsetBeginY

				if math.abs(value2) <= 5 then
					if node.roleBg.selectPic then
						node.roleBg.selectPic:removeSelf()

						node.roleBg.selectPic = nil
					end

					node.roleBg.selectPic = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(190, 42)):add2(node.roleBg):pos(0, 0):anchor(0, 0)

					self:lockRole(node.roleid)
				end
			end
		end)

		self.nearView.roleItems[#self.nearView.roleItems + 1] = node
		h = h - 45
	end
end

function widget_tasks.lockRole(self, value3)
	if not value3 then
		return
	end

	local value2 = main_scene.ui.console.controller.lock
	local locked_player = main_scene.ground.map:findRole(value3)

	if not locked_player or locked_player.die then
		return
	end

	if value2.target.skill then
		value2.locked_player = locked_player

		value2:setSelectTarget(locked_player)

		return
	end

	value2:setSelectTarget(locked_player)

	value2.locked_player = locked_player
end

function widget_tasks.showNear(self, data)
	self.nearView:setVisible(true)
	self.taskView:setVisible(false)
	self.funView:setVisible(false)

	local value2 = cc.c3b(189, 186, 185)

	if data then
		self.nearView.show = "mon"

		self.nearRole:setColor(value2)
		self.nearMon:setColor(display.COLOR_GREEN)
	else
		self.nearView.show = "hero"

		self.nearRole:setColor(display.COLOR_GREEN)
		self.nearMon:setColor(value2)
	end
end

function widget_tasks.showModeSelect(self, curModeChooseIsShow)
	if self.curModeChooseIsShow == curModeChooseIsShow then
		return
	end

	self.curModeChooseIsShow = curModeChooseIsShow

	local width2 = 40

	if not self.modeChooseNode then
		local items = {
			{
				"quanti",
				"全体"
			},
			{
				"heping",
				"和平"
			},
			{
				"bianzu",
				"组队"
			},
			{
				"hanghui",
				"行会"
			},
			{
				"shane",
				"善恶"
			},
			{
				"shitu",
				"战队"
			}
		}

		self.modeChooseNode = res.get2("pic/console/modesBg.png"):anchor(1, 0):pos(self.data.x - self.getw(self), display.height - self.geth(self) + 27):add2(main_scene.ui.console, self.getLocalZOrder(self))

		for index, item in ipairs(items) do
			local value2 = self.baseDir .. "mode/" .. item[1] .. ".png"

			if index == 1 and main_scene.ground:smr() then
				local value3 = self.baseDir .. "mode/luandou.png"
			end

			res.get2(self.baseDir .. "mode/" .. item[1] .. ".png"):pos((index - 1) * width2 + width2 / 2, self.modeChooseNode:geth() / 2):add2(self.modeChooseNode, 9):enableClick(function()
				if def.role.mainsetting.banChgMode then
					main_scene.ui:tip("该地图不支持更改模式")

					return
				end

				if main_scene.ground:smr() then
					net.send({
						CM_ATTACKMODE,
						tag = 0
					})
				else
					net.send({
						CM_ATTACKMODE,
						tag = index - 1
					})
				end

				self:showModeSelect(not self.curModeChooseIsShow)
			end, {
				size = cc.size(width2, self.modeChooseNode:geth())
			})
		end
	end

	self.modeChooseNode:stopAllActions()
	self.stopAllActions(self)

	if curModeChooseIsShow then
		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.getw(self) + 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.getw(self) + 10, self.modeChooseNode:getPositionY()))
		})
	else
		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self), self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self), self.modeChooseNode:getPositionY()))
		})
	end
end

function widget_tasks.mode2filename(self, text)
	local items = {
		战队攻击模式 = "shitu",
		全体攻击模式 = "quanti",
		乱斗攻击模式 = "luandou",
		阵营对战模式 = "zhenying",
		和平攻击模式 = "heping",
		善恶攻击模式 = "shane",
		行会攻击模式 = "hanghui",
		组队攻击模式 = "bianzu"
	}
	local value2

	for itemId, item in pairs(items) do
		if string.find(text, itemId) then
			value2 = item

			break
		end
	end

	return value2 or "heping"
end

function widget_tasks.upt(self)
	if g_data.player.isLogined and self.config and self.config.key == "tasks" and self.btnModes and self.btnModes.sprite then
		self.btnModes.sprite:setTex(res.gettex2(self.baseDir .. "mode/" .. self.mode2filename(self, g_data.player.attackMode) .. ".png"))
	end
end

function widget_tasks.updateContent(self, deltaTime)
	if self.taskView then
		require("mir2.scenes.main.common.extendUI").create(self.taskView.scroll, deltaTime, "tasks_extview")
	end
end

function widget_tasks.onExit(self)
	if g_data.nearTimer then
		scheduler.unscheduleGlobal(g_data.nearTimer)

		g_data.nearTimer = nil
	end
end

return widget_tasks
