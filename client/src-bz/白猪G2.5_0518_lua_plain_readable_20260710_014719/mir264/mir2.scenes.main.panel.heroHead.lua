local lblInfo = import("..common.lblInfo")
local heroHead = class("heroHead", function()
	return display.newNode()
end)

table.merge(heroHead, {})

local function callback()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

local x2 = {
	x = 48,
	y = display.height - 30
}
local cc2 = require("mir2.cc")

function heroHead:resetPanelPosition(key)
	local count = 0

	if self.safeAreaAdjustment then
		count = self.safeAreaLeft
	end

	if def.showTasks and main_scene.ui.console.widgets.tasks then
		if key then
			self:pos(x2.x + count - 46, x2.y - 193):anchor(0, 1)
		else
			self:pos(x2.x + count + 16, x2.y - 5):anchor(0, 1)
		end
	else
		self:pos(x2.x + count, x2.y - 5):anchor(0, 1)
	end

	return self
end

function heroHead:isInPos(key)
	local count = 0

	if self.safeAreaAdjustment then
		count = self.safeAreaLeft
	end

	local positionX = self:getPositionX()
	local positionY = self:getPositionY()

	return positionX == x2.x + count - 46 and positionY == x2.y - 193 or positionX == x2.x + count + 16 and positionY == x2.y - 5 or positionX == x2.x + count and positionY == x2.y - 5
end

function heroHead:ctor()
	self._supportMove = true
	self.heroNode = display.newNode():addTo(self, 1)
	self.safeAreaAdjustment = callback()
	self.safeAreaLeft = getSafeAreaInsets()

	local bg = res.get2("pic/console/head-icons/head_info.png"):addTo(self.heroNode):pos(0, 0):anchor(0, 0)

	self:size(bg:getw(), bg:geth())
	self:resetPanelPosition(g_data.setting.base.taskShow)
	self.heroNode:size(bg:getw(), bg:geth())

	self.name = an.newLabel("", 18, 1):addTo(self.heroNode):pos(137, 69):anchor(0.5, 0.5)
	self.lv = an.newLabel("", 14, 1):addTo(self.heroNode):pos(14, 14):anchor(0.5, 0.5)

	self:createFunBtn(bg)

	self.prog = {}

	local config = {
		{
			posY = 46,
			key = "HP",
			pic = "head_HP",
			posX = 74,
			text = {
				posY = 52,
				posX = 140
			}
		},
		{
			posY = 30,
			key = "MP",
			pic = "head_MP",
			posX = 80,
			text = {
				posY = 35,
				posX = 140
			}
		},
		{
			posY = 14,
			key = "EXP",
			pic = "head_Exp",
			posX = 71,
			text = {
				posY = 20,
				posX = 140
			}
		},
		{
			posY = 5,
			key = "DRINK",
			pic = "head_drink",
			posX = 48,
			text = {
				posY = 0,
				posX = 0
			}
		}
	}

	for k, v in pairs(config) do
		self.prog[v.key] = res.get2("pic/console/head-icons/" .. v.pic .. ".png"):addTo(self.heroNode):pos(v.posX, v.posY):anchor(0, 0)
	end

	self:upt()
end

function heroHead:createFunBtn(x)
	self.head = an.newBtn(res.gettex2("pic/console/hero-icons/head_normal.png"), function()
		main_scene.ui:togglePanel("heroEquip")
	end, {
		pressImage = res.gettex2("pic/console/hero-icons/head_press.png")
	}):addTo(self):pos(x:getw() + 4, x:geth()):anchor(0, 1)
	self.bag = an.newBtn(res.gettex2("pic/console/hero-icons/bag_normal.png"), function()
		main_scene.ui:togglePanel("heroBag")
	end, {
		pressImage = res.gettex2("pic/console/hero-icons/bag_press.png")
	}):addTo(self):pos(x:getw() + 4, 44):anchor(0, 1)
	self.call = an.newBtn(res.gettex2("pic/console/hero-icons/callhero.png"), function()
		main_scene.ui.console.btnCallbacks:handle("hero", "call")

		if g_data.hero.roleid == 0 then
			self.call.sprite:setTex(res.gettex2("pic/console/hero-icons/callhero.png"))
		else
			self.call.sprite:setTex(res.gettex2("pic/console/hero-icons/dismisshero.png"))
		end
	end, {
		pressBig = true,
		sprite = res.gettex2("pic/console/hero-icons/callhero.png")
	}):addTo(self):pos(55, 10):anchor(0, 1)

	if g_data.hero.roleid == 0 then
		self.call.sprite:setTex(res.gettex2("pic/console/hero-icons/callhero.png"))
	else
		self.call.sprite:setTex(res.gettex2("pic/console/hero-icons/dismisshero.png"))
	end

	self.mode = an.newBtn(res.gettex2("pic/console/hero-icons/heromode.png"), function()
		main_scene.ui.console.btnCallbacks:handle("hero", "mode")
	end, {
		pressBig = true
	}):addTo(self):pos(self.call:getw() + 62, 10):anchor(0, 1)
end

function heroHead:putItem(item, x, y)
	if item.formPanel.__cname == "heroBag" then
		return
	end

	if not g_data.client.heroPutInItem then
		local data = item.data

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
		end

		g_data.bag:delItem(data:get("makeIndex"))
		g_data.client:setHeroPutInItem(data)

		local makeIndex = data:get("makeIndex")

		net.send({
			CM_HERO_TOHEROBAG,
			recog = makeIndex
		}, {
			data.getVar("name")
		})
	end
end

function heroHead:setPercent(key, params)
	local p = 0

	p = params.cur and params.max and params.cur / params.max or p

	if p > 1 then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	if self.prog and self.prog[key] then
		local w = self.prog[key]:getTexture():getContentSize().width
		local h = self.prog[key]:getTexture():getContentSize().height

		if key == "DRINK" then
			self.prog[key]:setTextureRect(cc.rect(0, h * (1 - p), w, h * p))
		else
			self.prog[key]:setTextureRect(cc.rect(0, 0, w * p, h))
		end
	end
end

function heroHead:showHeroInfo(heroInfo)
	local labels = {}

	local function addLabel(str)
		labels[#labels + 1] = an.newLabel(str, 15, 1)
	end

	cc2.ms({
		function()
			addLabel(CS_DC .. ": " .. g_data.hero.ability:get("DC") .. "/" .. g_data.hero.ability:get("maxDC"))
			addLabel(CS_MC .. ": " .. g_data.hero.ability:get("MC") .. "/" .. g_data.hero.ability:get("maxMC"))
			addLabel(CS_SC .. ": " .. g_data.hero.ability:get("SC") .. "/" .. g_data.hero.ability:get("maxSC"))
			addLabel(CS_HP .. ": " .. g_data.hero.ability:get("HP") .. "/" .. g_data.hero.ability:get("maxHP"))
			addLabel(CS_MP .. ": " .. g_data.hero.ability:get("MP") .. "/" .. g_data.hero.ability:get("maxMP"))
			addLabel(string.format("经验: %.2f%%", g_data.hero.ability:get("Exp") / g_data.hero.ability:get("maxExp") * 100))
			addLabel(string.format("忠诚: %.2f%%", g_data.hero.fealty / 100))
		end
	})

	self.heroInfo = lblInfo.show(labels, heroInfo)
end

function heroHead:upt()
	self.name:setString(g_data.hero.name)

	if not self.headshot and g_data.hero.sex and g_data.hero.job then
		local img = string.format("pic/console/head-icons/%d_%d.png", g_data.hero.sex, g_data.hero.job)

		self.headshot = display.newSprite(res.gettex2(img), nil, nil, {
			class = cc.FilteredSpriteWithOne
		}):addTo(self):pos(45, 40):anchor(0.5, 0.5)

		self.headshot:setTouchEnabled(true)
		self.headshot:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				self.isMoved = false
				self.initPos = cc.p(self:getPosition())
				self.touchPos = cc.p(event.x, event.y)
			elseif event.name == "moved" then
				self.isMoved = true

				self:pos(self.initPos.x + event.x - self.touchPos.x, self.initPos.y + event.y - self.touchPos.y)
			elseif event.name == "ended" then
				if not self.isMoved then
					self:showHeroInfo(cc.p(event.x, event.y))
				end

				self.isMoved = false
			end

			return true
		end)
	end

	self.lv:setString(g_data.hero.ability:get("level") .. "")
	self:setPercent("HP", {
		cur = g_data.hero.ability:get("HP"),
		max = g_data.hero.ability:get("maxHP")
	})
	self:setPercent("MP", {
		cur = g_data.hero.ability:get("MP"),
		max = g_data.hero.ability:get("maxMP")
	})
	self:setPercent("EXP", {
		cur = g_data.hero.ability:get("Exp"),
		max = g_data.hero.ability:get("maxExp")
	})
	self:setPercent("DRINK", {
		cur = g_data.hero.drinkStatusValue,
		max = g_data.hero.drinkStatusMaxValue
	})
end

return heroHead
