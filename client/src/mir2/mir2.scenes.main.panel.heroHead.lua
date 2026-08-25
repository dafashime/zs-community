local textInfo = import("..common.textInfo")
local heroHead = class("heroHead", function ()
	return display.newNode()
end)

table.merge(heroHead, {})

local poses = {
	openMap = {
		x = display.width - 160,
		y = display.height - 21
	},
	hideMap = {
		x = display.width - 40,
		y = display.height - 21
	}
}

function heroHead:resetPanelPosition(key)
	self:pos(poses[key].x, poses[key].y):anchor(1, 1)

	return self
end

function heroHead:isInPos(key)
	return self:getPositionX() == poses[key].x and self:getPositionY() == poses[key].y
end

function heroHead:ctor()
	self._supportMove = true
	local node = display.newNode():addTo(self, 1)
	local bg = res.get2("pic/console/head-icons/head_info.png"):addTo(node):pos(0, 0):anchor(0, 0)

	self:size(bg:getw(), bg:geth())
	self:resetPanelPosition(main_scene.ui.panels.minimap and "openMap" or "hideMap")
	node:size(bg:getw(), bg:geth())

	self.name = an.newLabel("", 18, 1):addTo(node):pos(137, 69):anchor(0.5, 0.5)
	self.lv = an.newLabel("", 14, 1):addTo(node):pos(14, 14):anchor(0.5, 0.5)
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
		self.prog[v.key] = res.get2("pic/console/head-icons/" .. v.pic .. ".png"):addTo(node):pos(v.posX, v.posY):anchor(0, 0)
	end

	self:upt()
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

	if params.cur and params.max then
		p = params.cur / params.max or p
	end

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

function heroHead:showHeroInfo()
	local labels = {}

	local function addLabel(str)
		labels[#labels + 1] = an.newLabel(str, 15, 1)
	end

	addLabel("体力值: " .. g_data.hero.ability:get("HP") .. "/" .. g_data.hero.ability:get("maxHP"))
	addLabel("魔法值: " .. g_data.hero.ability:get("MP") .. "/" .. g_data.hero.ability:get("maxMP"))
	addLabel("经验值: " .. string.format("%.2f%%", g_data.hero.ability:get("Exp") / g_data.hero.ability:get("maxExp") * 100))
	addLabel("忠诚度: " .. string.format("%.2f%%", g_data.hero.fealty / 100))
	addLabel("醉酒度: " .. string.format("%d%%", g_data.hero.drinkStatusValue / g_data.hero.drinkStatusMaxValue * 100))

	self.heroInfo = textInfo.show(labels, cc.p(self:getPositionX(), self:getPositionY() + 3))
end

function heroHead:upt()
	self.name:setString(g_data.hero.name)

	if not self.headshot and g_data.hero.sex and g_data.hero.job then
		local img = string.format("pic/console/head-icons/%d_%d.png", g_data.hero.sex, g_data.hero.job)
		self.headshot = display.newSprite(res.gettex2(img), nil, nil, {
			class = cc.FilteredSpriteWithOne
		}):addTo(self):pos(45, 40):anchor(0.5, 0.5)

		self.headshot:setTouchEnabled(true)
		self.headshot:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				self.isMoved = false
				self.initPos = cc.p(self:getPosition())
				self.touchPos = cc.p(event.x, event.y)
			elseif event.name == "moved" then
				self.isMoved = true

				self:pos(self.initPos.x + event.x - self.touchPos.x, self.initPos.y + event.y - self.touchPos.y)
			elseif event.name == "ended" then
				if not self.isMoved then
					self:showHeroInfo()
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
