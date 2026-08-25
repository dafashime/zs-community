local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local strengthen = class("strengthen", function()
	return display.newNode()
end)

table.merge(strengthen, {
	items = {},
	effects = {},
	replaces = {
		"祖玛熔锭",
		"赤月熔锭",
		"雷霆熔锭",
		"强雷熔锭",
		"战神熔锭"
	},
	specil = {
		"祖玛助熔剂",
		"赤月助熔剂",
		"雷霆助熔剂",
		"强雷助熔剂",
		"战神助熔剂"
	},
	dec = {
		"祖玛",
		"赤月",
		"雷霆",
		"强雷",
		"战神"
	}
})

function strengthen:ctor()
	self._scale = self:getScale()
	self._supportMove = true

	local bg = res.get2("pic/panels/fusion/bg1.png"):anchor(0, 0):addto(self)
	local center = res.get2("pic/panels/fusion/bg.png"):anchor(0.5, 0):pos(bg:getw() / 2, 12):addto(bg)

	display.newSprite(res.gettex2("pic/panels/fusion/fsqh.png")):anchor(0.5, 0.5):pos(bg:getw() * 0.5, bg:geth() - 20):add2(bg)
	self:size(cc.size(bg:getContentSize().width, bg:getContentSize().height)):anchor(0, 1):pos(10, display.height - 80)
	self:setNodeEventEnabled(true)
	self:showBag()
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw() - 4, self:geth() - 4):addto(self)

	local loopEffAni = res.getani2("pic/panels/fusion/effect/1/%d.png", 1, 8, 0.12)

	loopEffAni:retain()
	res.get2("pic/panels/fusion/effect/1/1.png"):pos(center:getw() * 0.5, center:geth() * 0.5):add2(center, 1):runForever(cc.Animate:create(loopEffAni))

	self.boxs = {}

	local files = {
		"equip",
		"equip",
		"equip",
		"equip",
		"equip",
		"equip2",
		"equip"
	}
	local boxPos = {
		{
			x = 94,
			y = 344
		},
		{
			x = 284,
			y = 344
		},
		{
			x = 94,
			y = 146
		},
		{
			x = 284,
			y = 146
		},
		{
			x = 186,
			y = 248
		}
	}
	local floatLabel = {
		"cyss",
		"cyss",
		"cyss",
		"diamond",
		"cloth"
	}

	res.get2("pic/panels/fusion/equip3.png"):pos(boxPos[5].x, boxPos[5].y):add2(bg, 2)

	for i = 1, 5 do
		self.boxs[i] = res.get2("pic/panels/fusion/" .. files[i] .. ".png"):pos(boxPos[i].x, boxPos[i].y):add2(bg, 2)

		res.get2("pic/panels/fusion/" .. floatLabel[i] .. ".png"):pos(boxPos[i].x, boxPos[i].y):add2(bg, 2)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		local canFusion = true
		local count = 0

		for i = 1, 5 do
			if not self.items[i] then
				if i >= 1 and i <= 3 then
					main_scene.ui:tip("请放入赤月级别首饰")

					return
				end

				if i == 4 then
					main_scene.ui:tip("请放入金刚石x888")

					return
				end

				if i == 5 then
					main_scene.ui:tip("请放入要强化的衣服")

					return
				end
			elseif i == 4 and self.items[i].data:get("dura") < 888 then
				main_scene.ui:tip("金刚石数量少于888")

				return
			end
		end

		local value
		local msgbox = an.newMsgbox("", function(idx)
			if idx == 1 then
				local data = {}

				for i = 1, 4 do
					if self.items[i].isItems then
						data[#data + 1] = {
							"int",
							self.items[i].data:get("makeIndex")
						}
					end
				end

				if #data > 0 then
					dump(data)
					net.send({
						CM_UPDATE_CLOTHES,
						recog = self.items[5].data:get("makeIndex")
					}, nil, data)
				end
			end
		end, {
			disableScroll = true
		})
		local labelInfo = ""
		local labelInfo2 = "你确定并开始强化 \"" .. self.items[5].data.getVar("name") .. "\"吗？"
		local tmpLabel = cc.LabelTTF:create(labelInfo2, "", 18, cc.size(320, 0), 1)

		tmpLabel:anchor(0.5, 1)
		tmpLabel:setPosition(msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 + 18)
		msgbox.bg:addChild(tmpLabel)
		an.newLabel("强化后所有材料,赤月首饰和金刚石将自动消耗", 16, 1, {
			color = cc.c3b(162, 78, 54)
		}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 - 40)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/fusion/ksqh.png")
	}):add2(center, 2):anchor(0.5, 0.5):pos(center:getw() * 0.5, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		self:oneKey()
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/fusion/allin.png")
	}):add2(center, 2):anchor(0.5, 0.5):pos(center:getw() * 0.5 - 114, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		self:itemsBack2bag()
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/fusion/allout.png")
	}):add2(center, 2):anchor(0.5, 0.5):pos(center:getw() * 0.5 + 114, 36)

	local frame = 1
	local tmpTex = ""

	self.effects[1] = res.get2("pic/panels/fusion/effect/4/1.png"):add2(self):pos(62, 208):hide()
	self.effects[2] = res.get2("pic/panels/fusion/effect/4/1.png"):add2(self):pos(128, 126):hide()
	self.effects[3] = res.get2("pic/panels/fusion/effect/4/1.png"):add2(self):pos(258, 126):hide()
	self.effects[4] = res.get2("pic/panels/fusion/effect/3/1.png"):add2(self, 4):pos(190, 228):hide()

	local centerAni = res.getani2("pic/panels/fusion/effect/3/%d.png", 1, 16, 0.26)

	centerAni:retain()
	self.effects[4]:runForever(cc.Animate:create(centerAni))
	display.newNode():add2(self):runForever(transition.sequence({
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(function()
			frame = frame + 1
			frame = frame > 10 and 1 or frame
			tmpTex = "pic/panels/fusion/effect/4/" .. frame .. ".png"

			for i = 1, 3 do
				self.effects[i]:setTex(res.gettex2(tmpTex))
			end
		end)
	}))

	self.items = {}

	self:addNodeEventListener(cc.NODE_EVENT, function(event)
		if event.name == "cleanup" then
			self:itemsBack2bag()
		end
	end)
end

function strengthen:showResult()
	local loopEffAni = res.getani2("pic/panels/fusion/effect/2/%d.png", 1, 8, 0.16)

	loopEffAni:retain()

	local loopEffSpr = res.get2("pic/panels/fusion/effect/2/1.png"):pos(self:getw() * 0.5, self:geth() * 0.5):add2(self, 9)

	loopEffSpr:runs({
		cc.Animate:create(loopEffAni),
		cc.CallFunc:create(function()
			loopEffSpr:removeSelf()
		end)
	})
end

function strengthen:showBag()
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:pos(self:getw() + 10, display.height - 80)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(self:getw() + 10, display.height - 80)
		end
	end
end

function strengthen:showEffect(bShow)
	for i = 1, 4 do
		if bShow then
			self.effects[i]:show()
		else
			self.effects[i]:hide()
		end
	end
end

function strengthen:uptItem(makeIndex)
	local item2 = g_data.bag:getItemStrengthen(makeIndex)

	if not item2 then
		return
	end

	for i, v in pairs(self.items) do
		if v and v.isItems and v.data:get("makeIndex") == makeIndex then
			v.data = item2

			break
		end
	end
end

function strengthen:putItem(item2, x, y)
	local form = item2.formPanel.__cname
	local target

	for i = 1, 5 do
		local tmpX, tmpY = self:idx2pos(i)

		if (tmpX - x) * (tmpX - x) < 1600 and (tmpY - y) * (tmpY - y) < 1600 then
			target = i
		end
	end

	if not target then
		return
	end

	if form == "bag" and g_data.client:checkLastTime("strengthen", 2) then
		local data = item2.data

		self:getItemFromBg(data, target)
	end
end

function strengthen:getBackItem(item2)
	local data = item2.data

	if not data then
		return
	end

	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data:get("makeIndex"))
	end

	local value

	for i, v in pairs(self.items) do
		if v and v.isItems and v.data:get("makeIndex") == data:get("makeIndex") then
			local value2 = i

			v:removeSelf()

			self.items[i] = nil
			g_data.bag.strengthen[i] = nil

			break
		end
	end
end

function strengthen:getItemFromBg(data, pos)
	local tmpItem = self.items[pos]

	g_data.bag:delItem(data:get("makeIndex"))

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
	end

	g_data.client:setLastTime("strengthen", true)
	self:addItem(pos, data)
end

function strengthen:delItem(itemIndex)
	for i, v in pairs(self.items) do
		if v and v.isItems and v.data:get("makeIndex") == itemIndex then
			v:removeSelf()

			self.items[i] = nil
			g_data.bag.strengthen[i] = nil

			break
		end
	end
end

function strengthen:duraChange(makeindex)
	local data = g_data.bag:getItemStrengthen(makeindex)

	for k, v in pairs(self.items) do
		if makeindex == v.data:get("makeIndex") then
			v.data = data

			if k == 4 then
				self:rebackBag(data)

				g_data.bag.strengthen[k] = nil

				v:removeSelf()

				self.items[k] = nil
			end

			return
		end
	end
end

function strengthen:rebackBag(data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data:get("makeIndex"))
	end
end

function strengthen:oneKey()
	local itemsName = {
		"圣战",
		"法神",
		"天尊",
		"项链",
		"手镯",
		"戒指"
	}

	local function getJew()
		for i = 1, 3 do
			for k = 4, 6 do
				local name = itemsName[i] .. itemsName[k]
				local bagItem = g_data.bag:getItemWithName(name)

				if bagItem then
					return bagItem
				end
			end
		end
	end

	for i = 1, 3 do
		if not self.items[i] then
			local target = getJew()

			if target then
				self:getItemFromBg(target, i)
			else
				main_scene.ui:tip("赤月装备不足")
			end
		end
	end

	if not self.items[4] then
		local target2 = g_data.bag:getItemWithNameAndDura("金刚石", 888)

		if not target2 then
			main_scene.ui:tip("金刚石不足")
		else
			self:getItemFromBg(target2, 4)
		end
	end

	if not self.items[5] then
		local cloth = {
			"雷霆战甲",
			"烈焰魔衣",
			"光芒道袍"
		}
		local target3 = g_data.bag:getItemWithShortName(cloth)

		if not target3 then
			main_scene.ui:tip("包裹中没有\"雷霆战甲\",\"烈焰魔衣\",\"光芒道袍\"中的一件")
		else
			self:getItemFromBg(target3, 5)
		end
	end
end

function strengthen:itemsBack2bag()
	local makeIndexs = {}

	for i, v in pairs(self.items) do
		if v.isItems then
			g_data.bag:addItem(v.data)

			makeIndexs[#makeIndexs + 1] = v.data:get("makeIndex")
		end

		v:removeSelf()
	end

	self.items = {}

	if main_scene.ui.panels.bag then
		for i2, v2 in ipairs(makeIndexs) do
			main_scene.ui.panels.bag:addItem(v2)
		end
	end

	g_data.bag.strengthen = {}
end

function strengthen:addItem(idx, data)
	sound.play("item", data)

	if idx >= 1 and idx <= 3 and not self:isNeedJewelry(data) then
		main_scene.ui:tip("请放入正确的赤月级首饰")
		self:rebackBag(data)

		return
	end

	if idx == 4 and data.getVar("name") ~= "金刚石" then
		main_scene.ui:tip("请放入金刚石")
		self:rebackBag(data)

		return
	end

	if idx == 5 then
		local cloth = {
			"雷霆战甲",
			"烈焰魔衣",
			"光芒道袍"
		}
		local isIn = false
		local name = data.getVar("name")

		for i, v in ipairs(cloth) do
			if string.find(name, v) then
				isIn = true
			end
		end

		if not isIn then
			main_scene.ui:tip("请放入\"雷霆战甲\",\"烈焰魔衣\",\"光芒道袍\"中的一件")
			self:rebackBag(data)

			return
		end
	end

	local tmpItem = self.items[idx]

	if tmpItem then
		if tmpItem.isItems then
			g_data.bag:addItem(tmpItem.data)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(tmpItem.data:get("makeIndex"))
			end
		end

		tmpItem:removeSelf()
	end

	self.items[idx] = item.new(data, self, {
		showbg = false,
		showEffect = true,
		idx = idx
	}):addto(self, 3):pos(self:idx2pos(idx))
	self.items[idx].isItems = true
	g_data.bag.strengthen[idx] = data
end

function strengthen:isNeedJewelry(data)
	local jewelry = {
		"戒指",
		"项链",
		"手镯"
	}
	local job = {
		"天尊",
		"圣战",
		"法神"
	}

	local function isInName(name, list)
		if type(list) == "table" and type(name) == "string" then
			for i, v in ipairs(list) do
				if string.find(name, v) then
					return true
				end
			end
		end
	end

	if isInName(data.getVar("name"), jewelry) and isInName(data.getVar("name"), job) then
		return true
	end
end

function strengthen:idx2pos(idx)
	local boxPos = {
		{
			x = 94,
			y = 344
		},
		{
			x = 284,
			y = 344
		},
		{
			x = 94,
			y = 146
		},
		{
			x = 284,
			y = 146
		},
		{
			x = 186,
			y = 248
		}
	}

	return boxPos[idx].x, boxPos[idx].y
end

function strengthen:showReplaceTips(scenePos)
	if not self.items[1] or not self.items[1].isItems then
		return
	end

	local name = self.items[1].data.getVar("name")
	local layer = display.newNode():size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.textInfo)

	layer:setTouchEnabled(true)
	layer:setTouchSwallowEnabled(false)
	layer:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
		if event.name == "ended" then
			layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local labels = {
		an.newLabel(self.replaces[self.level], 20, 1, {
			color = cc.c3b(255, 255, 0)
		}),
		an.newLabel("可替换" .. name .. "进行装备合成。", 20, 1),
		an.newLabel("价格：" .. self.price .. "元宝。", 20, 1),
		an.newLabel("装备拖入可直接替换。", 20, 1)
	}
	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale4.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i = #labels, 1, -1 do
		local v = labels[i]:addto(bg, 99):anchor(0, 0):pos(10, h)

		w = math.max(w, v:getw())
		h = h + v:geth() + space
	end

	local w2 = w + 20
	local h2 = h + 10
	local rect = cc.rect(0, 0, display.width, display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w2 then
		p.x = rect.width - w2
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h2 < rect.y then
		p.y = h2 + rect.y
	end

	bg:size(w2, h2):pos(p.x, p.y)
end

function strengthen:showSimpleTips(targetList, scenePos)
	local layer = display.newNode():size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.textInfo)

	layer:setTouchEnabled(true)
	layer:setTouchSwallowEnabled(false)
	layer:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
		if event.name == "ended" then
			layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local labels = {}

	function add(text, color)
		text = text or ""
		labels[#labels + 1] = an.newLabel(text, 20, 1, {
			color = color
		})
	end

	function addAttr(data, text, key)
		local front = data[key] or 0
		local after = data["max" .. key] or 0

		if front > 0 or after > 0 then
			add(text .. front .. "-" .. after)
		end
	end

	function addAttr2(text, value, normalValue, color, attachText)
		attachText = attachText or ""

		add(text .. value .. attachText, color)
	end

	function needColor(a, b)
		return b <= a and display.COLOR_GREEN or display.COLOR_RED
	end

	function addNeed(data)
		local need = data.need
		local needLevel = data.needLevel

		if need == 0 then
			add("需要等级: " .. needLevel .. "级", display.COLOR_RED)
		elseif need == 1 then
			add("需要攻击力: " .. needLevel, display.COLOR_RED)
		elseif need == 2 then
			add("需要魔法力: " .. needLevel, display.COLOR_RED)
		elseif need == 3 then
			add("需要精神力: " .. needLevel, display.COLOR_RED)
		elseif need == 4 then
			add("需要转生等级: " .. needLevel, display.COLOR_GREEN)
		elseif need == 40 then
			add("需要转生&等级: " .. needLevel, display.COLOR_GREEN)
		elseif need == 41 then
			add("需要转生&攻击力: " .. needLevel, display.COLOR_GREEN)
		elseif need == 42 then
			add("需要转生&魔法力: " .. needLevel, display.COLOR_GREEN)
		elseif need == 43 then
			add("需要转生&精神力力: " .. needLevel, display.COLOR_GREEN)
		elseif need == 44 then
			add("需要转生&声望点: " .. needLevel, display.COLOR_GREEN)
		elseif need == 5 then
			add("需要声望点: " .. needLevel, display.COLOR_GREEN)
		elseif need == 6 then
			add("行会成员专用", display.COLOR_GREEN)
		elseif need == 60 then
			add("行会掌门专用", display.COLOR_GREEN)
		elseif need == 7 then
			add("沙城成员专用", display.COLOR_GREEN)
		elseif need == 70 then
			add("沙城掌门专用", display.COLOR_GREEN)
		elseif need == 8 then
			add("会员专用", display.COLOR_GREEN)
		elseif need == 81 then
			add("会员类型 =" .. Loword(needLevel) .. "并等级>=" .. Hiword(needLevel), display.COLOR_GREEN)
		elseif need == 82 then
			add("会员类型 >= " .. Loword(needLevel) .. "并等级>=" .. Hiword(needLevel), display.COLOR_GREEN)
		end
	end

	local function tmpModf(value)
		local int, f = math.modf(value)

		return f >= 0.5 and int + 1 or int
	end

	if #targetList > 1 then
		labels[#labels + 1] = an.newLabel("可获得以下物品中的随机一件", 20, 1, {
			color = cc.c3b(255, 0, 0)
		})
	end

	for i, v in ipairs(targetList) do
		local data = def.items[v] or {}

		if #targetList > 1 then
			labels[#labels + 1] = an.newLabel("     ", 20, 1, {
				color = cc.c3b(255, 255, 0)
			})
		end

		labels[#labels + 1] = an.newLabel(data.name, 20, 1, {
			color = cc.c3b(255, 255, 0)
		})
		labels[#labels + 1] = an.newLabel("重量: " .. data.weight, 20, 1)

		add("持久: " .. data.duraMax / 1000 .. "/" .. data.duraMax / 1000)

		local AC = data:getVar("AC")
		local maxAC = data:getVar("maxAC")
		local MAC = data:getVar("MAC")
		local maxMAC = data:getVar("maxMAC")
		local ACN = data:getVar("AC")
		local maxACN = data:getVar("maxAC")
		local MACN = data:getVar("MAC")
		local maxMACN = data:getVar("maxMAC")
		local stdMode = data:getVar("stdMode")

		if stdMode == 19 or stdMode == 53 then
			if maxAC > 0 then
				addAttr2("魔法躲避: +", maxAC, maxACN, display.COLOR_GREEN, "0％")
			end

			if maxMAC > 0 then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_GREEN)
			end

			if MAC > 0 then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 20 or stdMode == 24 then
			if AC > 0 then
				addAttr2("准确: +", maxAC, maxACN, display.COLOR_GREEN)
			end

			if MAC > 0 then
				addAttr2("敏捷: +", maxMAC, maxMACN, display.COLOR_GREEN)
			end
		elseif stdMode == 21 then
			if maxAC > 0 then
				addAttr2("体力恢复: +", maxAC, maxACN, display.COLOR_GREEN, "0％")
			end

			if maxMAC > 0 then
				addAttr2("魔法恢复: +", maxMAC, maxMACN, display.COLOR_GREEN, "0％")
			end

			if AC > 0 then
				addAttr2("攻击速度: +", AC, ACN, display.COLOR_GREEN)
			end

			if MAC > 0 then
				add("攻击速度: -" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 23 then
			if maxAC > 0 then
				addAttr2("毒物躲避: +", maxAC, maxACN, display.COLOR_GREEN, "0％")
			end

			if maxMAC > 0 then
				addAttr2("中毒恢复: +", maxMAC, maxMACN, display.COLOR_GREEN, "0％")
			end

			if AC > 0 then
				addAttr2("攻击速度: +", AC, ACN, display.COLOR_GREEN)
			end

			if MAC > 0 then
				add("攻击速度: -" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 28 or stdMode == 27 then
			addAttr("防御: ", "AC")
			addAttr("魔御: ", "MAC")

			if getData("aniCount") > 0 then
				add("负重: +" .. getData("aniCount"), display.COLOR_GREEN)
			end
		elseif stdMode == 63 then
			if AC > 0 then
				add("HP: +" .. AC, display.COLOR_GREEN)
			end

			if maxAC > 0 then
				add("MP: +" .. maxAC, display.COLOR_GREEN)
			end

			if maxMAC > 0 then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_GREEN)
			end

			if MAC > 0 then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end
		else
			addAttr(data, "防御: ", "AC")
			addAttr(data, "魔御: ", "MAC")
		end

		addAttr(data, "攻击: ", "DC")
		addAttr(data, "魔法: ", "MC")
		addAttr(data, "道术: ", "SC")

		if stdMode ~= 52 then
			addNeed(data)
		end
	end

	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale4.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i2 = #labels, 1, -1 do
		local v2 = labels[i2]:addto(bg, 99):anchor(0, 0):pos(10, h)

		w = math.max(w, v2:getw())
		h = h + v2:geth() + space
	end

	local w2 = w + 20
	local h2 = h + 10
	local rect = cc.rect(0, 0, display.width, display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w2 then
		p.x = rect.width - w2
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h2 < rect.y then
		p.y = h2 + rect.y
	end

	bg:size(w2, h2):pos(p.x, p.y)
end

function strengthen:showError(msg)
	local errorCode = msg.recog
	local errorMsg = {
		[-6] = "很遗憾升级失败",
		[-4] = "未提供足够的赤月装备",
		[-1] = "未在背包中找到这件装备",
		[-3] = "这件装备已经升级了三次，不能再升级了",
		[-5] = "提交的金刚石不足",
		[-2] = "放入的衣服不符合要求"
	}

	main_scene.ui:tip(errorMsg[errorCode] or "未知错误")
end

return strengthen
