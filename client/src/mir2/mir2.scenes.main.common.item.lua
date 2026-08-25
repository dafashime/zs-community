local itemInfo = import(".itemInfo")
local item = class("item", function ()
	return display.newNode()
end)
local common = import(".common")

table.merge(item, {
	w = 45,
	mute = false,
	h = 45
})

function item:ctor(data, formPanel, params)
	self.data = data
	self.formPanel = formPanel
	self.params = params or {}
	params = params or {}
	local form = formPanel.__cname
	local isSetOffset = params.isSetOffset

	if params.tex then
		self.sprite = display.newSprite(params.tex):addto(self)
	else
		self.sprite = res.get(params.img or "items", self.data.getVar("looks") or 0):addto(self)
	end

	if isSetOffset then
		local info = res.getinfo(params.img or "items", self.data.getVar("looks"))

		if info and info.x and info.y then
			self.sprite:anchor(0, 1):pos(info.x * formPanel._scale, -info.y * formPanel._scale):scale(formPanel._scale)
		end

		self.sprite2 = res.get("items", self.data.getVar("looks")):addto(self):hide()
	else
		display.newNode():size(item.w, item.h):anchor(0.5, 0.5):addto(self)
	end

	if data.isPileUp and data.isPileUp() then
		self.dura = an.newLabel("" .. data:get("dura"), 12, 1, {
			color = cc.c3b(0, 255, 0)
		}):anchor(1, 0):pos(16, -20):add2(self, 1)
	end

	if WIN32_OPERATE then
		self:registerMouseEvent()
	else
		self:registerTouchEvent()
	end
end

function item:registerTouchEvent()
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			return self:onTouchBegan(event)
		elseif event.name == "moved" then
			self:onTouchMoved(event)
		elseif event.name == "ended" then
			self:onTouchEnded(event)
		elseif event.name == "exit" then
			self:onExit()
		end
	end)
end

function item:onTouchBegan(event)
	if self.handler then
		self.clicked = true

		return false
	end

	self.beganPos = cc.p(self:getPosition())
	self.beganTouchPos = cc.p(event.x, event.y)
	self.hasMove = false

	self:setLocalZOrder(self:getLocalZOrder() + 1)

	return true
end

function item:onTouchMoved(event)
	if not self.params.donotMove and (math.abs(self.beganTouchPos.x - event.x) > 10 or math.abs(self.beganTouchPos.y - event.y) > 10) then
		if not self.hasMove then
			if self.params.isGold then
				sound.playSound(sound.s_money)
			else
				sound.play("item", self.data)
			end
		end

		self.hasMove = true
		local scale = not self.params.isSetOffset and self.formPanel._scale or 1

		if self.params.isSetOffset then
			self.sprite:hide()
			self.sprite2:show()

			local p = self:getParent():convertToWorldSpace(cc.p(0, 0))

			self:pos((event.x - p.x) / scale, (event.y - p.y) / scale)
		else
			self:pos((event.x - self.beganTouchPos.x) / scale + self.beganPos.x, (event.y - self.beganTouchPos.y) / scale + self.beganPos.y)
		end
	end
end

function item:onTouchEnded(event)
	if self.hasMove then
		local ret = false
		local isInPanel = false
		local form = self.formPanel.__cname
		local pos = cc.p(event.x, event.y)
		local panels = sortNodes(table.values(main_scene.ui.panels))

		for i, v in ipairs(panels) do
			if v:checkInPanel(pos) then
				if v.putItem and not self.params.isGold then
					local p = v:convertToWorldSpace(cc.p(0, 0))
					ret = v:putItem(self, pos.x - p.x, pos.y - p.y)
				elseif v.putGold and self.params.isGold then
					v:putGold(self)
				end

				isInPanel = true

				break
			end
		end

		local isInCustom = false

		if not isInPanel then
			local customs = sortNodes(table.values(main_scene.ui.customs))

			for i, v in ipairs(customs) do
				if v:checkInButton(pos) then
					isInCustom = true
				end

				if isInCustom then
					if v:checkItemType(self.data) then
						local data = self.data
						local owner = self.owner

						if self.customNode and v ~= self.customNode then
							self.customNode:custom_delItem()
						end

						v:setCustomProps(data, owner)
					end

					break
				end
			end
		end

		if self.customNode and not isInCustom then
			local customs = sortNodes(table.values(main_scene.ui.customs))

			for i, v in ipairs(customs) do
				if v.btn.item == self then
					v:custom_delItem()

					break
				end
			end
		end

		if not isInPanel and not isInCustom and (form == "bag" or form == "heroBag") then
			self:throw()
		end

		if self.params and self.params.isSetOffset and self.sprite then
			self.sprite:show()
			self.sprite2:hide()
		end

		if not ret and self.beganPos then
			self:pos(self.beganPos.x, self.beganPos.y)
		else
			return
		end
	else
		self.handler = scheduler.performWithDelayGlobal(handler(self, self.click), 0.25)
	end

	self.hasMove = false

	self:setLocalZOrder(self:getLocalZOrder() - 1)
end

function item:click()
	local form = self.formPanel.__cname
	local quick = nil

	if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
		quick = true
	end

	if quick and (form == "storage" or form == "bag") then
		if form == "bag" then
			main_scene.ui.panels.storage:putItem(self)
		else
			main_scene.ui.panels.bag:putItem(self)
		end
	elseif self.clicked then
		if not self.params.mute then
			sound.play("item", self.data)
		end

		if form == "bag" or form == "heroBag" then
			self:use()
		elseif form == "equip" or form == "heroEquip" then
			self:takeOff()
		elseif self.customNode then
			main_scene.ui.console.btnCallbacks:handle("custom", self.customNode)
		end
	elseif not self.params.isGold and self.sprite then
		local p = self.sprite:convertToWorldSpace(cc.p(self.sprite:getw() / 2, self.sprite:geth() / 2))

		itemInfo.show(self.data, p, {
			from = form,
			extend = self.params.extend
		})

		if self.params.clickcb then
			self.params.clickcb(self)
		end
	end

	self.handler = nil
	self.clicked = nil
end

function item:canUseEquip(item, dataFrom, weight, isPlayer)
	if not item then
		return
	end

	local function chargeNeed(info, value)
		if value then
			return true
		else
			common.addMsg(info, display.COLOR_RED, display.COLOR_WHITE, true)
		end
	end

	local playerData = isPlayer and g_data.player or g_data.hero
	local need = item.getVar("need")
	local needLevel = item.getVar("needLevel")
	local where = getTakeOnPosition(item.getVar("stdMode"))

	if where then
		local ret = true

		if need == 0 then
			ret = chargeNeed("等级不够", needLevel <= playerData.ability:get("level"))
		elseif need == 1 then
			ret = chargeNeed("攻击力不足", needLevel <= playerData.ability:get("maxDC"))
		elseif need == 2 then
			ret = chargeNeed("魔法力不足", needLevel <= playerData.ability:get("maxMC"))
		elseif need == 3 then
			ret = chargeNeed("精神力不足", needLevel <= playerData.ability:get("maxSC"))
		elseif need == 5 and isPlayer then
			ret = chargeNeed("你的声望不足，不能佩戴", g_data.player.ability3:get("prestige") <= needLevel)
		end

		if not ret then
			return
		end
	end

	if playerData.ability:get("maxHandWeight") < item.getVar("weight") then
		-- Nothing
	end

	if item.getVar("stdMode") == 4 then
		local shape = item.getVar("shape") or 0

		if shape ~= 3 then
			if shape == 4 then
				-- Nothing
			elseif shape ~= playerData.job then
				common.addMsg("不能学习其他职业技能书", display.COLOR_RED, display.COLOR_WHITE, true)

				return false
			end
		end

		local needLevel = math.modf(Word(item.getVar("duraMax")))

		if playerData.ability:get("level") < needLevel then
			common.addMsg("等级不够", display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end
	end

	return true
end

function item:getItemSourceInfo()
	if self.formPanel.__cname == "bag" then
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	else
		isPlayer = false
		equipData = g_data.heroEquip
		bagData = g_data.heroBag
		takeonMsg = CM_HERO_TAKEON
		eatMsg = CM_HERO_EAT
	end

	return bagData, equipData, eatMsg, takeonMsg
end

local cBox2Names = {
	"紫铜天赐",
	"白银天赐",
	"赤金天赐",
	"神秘天赐",
	"新年天赐",
	"节日天赐",
	"春节天赐",
	"火龙天赐",
	"王者天赐",
	"玛法天赐"
}
local cBox2KeyNames = {
	"紫铜钥匙",
	"白银钥匙",
	"赤金钥匙",
	"神秘钥匙",
	"新年钥匙",
	"节日钥匙",
	"春节钥匙",
	"火龙钥匙",
	"王者钥匙",
	"玛法钥匙"
}

function item:useTreasureBox(item, bagData)
	local name = item.getVar("name")
	local boxIndex = item:get("makeIndex")
	local keyIndex = item:get("makeIndex")
	local findName = nil
	local isKey = true

	for k, v in pairs(cBox2Names) do
		print(v, name, cBox2KeyNames[k])

		if v == name then
			findName = cBox2KeyNames[k]
			isKey = false
			g_data.usingTreasureKeyName = findName
		elseif cBox2KeyNames[k] == name then
			findName = v
			g_data.usingTreasureKeyName = name
		end
	end

	print(findName, name, boxIndex, keyIndex, g_data.usingTreasureKeyName)

	if not findName then
		return
	end

	for k, v in pairs(bagData.items) do
		if v.getVar("name") == findName then
			print(name, findName)

			if isKey then
				boxIndex = v:get("makeIndex")
			else
				keyIndex = v:get("makeIndex")
			end
		end
	end

	print(findName, name, boxIndex, keyIndex)

	if keyIndex == boxIndex then
		return
	end

	net.send({
		CM_BOX2_TRYOPEN,
		flag = 0,
		recog = boxIndex,
		param = Loword(keyIndex),
		tag = Hiword(keyIndex)
	})
end

function item:use(equipIdx)
	local bagData, equipData, eatMsg, takeonMsg = nil
	local isPlayer = true

	if self.formPanel.__cname == "bag" then
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	else
		isPlayer = false
		equipData = g_data.heroEquip
		bagData = g_data.heroBag
		takeonMsg = CM_HERO_TAKEON
		eatMsg = CM_HERO_EAT
	end

	local where = getTakeOnPosition(self.data.getVar("stdMode"))

	if where then
		if U_RINGL == where or U_RINGR == where then
			if equipIdx then
				where = equipIdx
			elseif not equipData.items[U_RINGL] then
				where = U_RINGL
			elseif not equipData.items[U_RINGR] then
				where = U_RINGR
			elseif equipData.lastTakeOnRingIsLeft then
				equipData.lastTakeOnRingIsLeft = false
				where = U_RINGR
			else
				equipData.lastTakeOnRingIsLeft = true
				where = U_RINGL
			end
		elseif U_ARMRINGL == where or U_ARMRINGR == where then
			if equipIdx then
				where = equipIdx
			elseif not equipData.items[U_ARMRINGL] then
				where = U_ARMRINGL
			elseif not equipData.items[U_ARMRINGR] then
				where = U_ARMRINGR
			elseif equipData.lastTakeOnBraceletIsLeft then
				equipData.lastTakeOnBraceletIsLeft = false
				where = U_ARMRINGR
			else
				equipData.lastTakeOnBraceletIsLeft = true
				where = U_ARMRINGL
			end
		elseif equipIdx then
			where = equipIdx
		end

		local weight = equipData.items[where] and equipData.items[where].getVar("weight") or 0

		if self:canUseEquip(self.data, bagData, weight, isPlayer) and bagData:use("take", self.data:get("makeIndex"), {
			where = where
		}) then
			net.send({
				takeonMsg,
				recog = self.data:get("makeIndex"),
				param = where
			}, {
				self.data.getVar("name")
			})
			self.formPanel:delItem(self.data:get("makeIndex"))
		end
	else
		if equipIdx then
			return
		end

		if not self:canUseEquip(self.data, bagData, 0, isPlayer) then
			return
		end

		local function use()
			if bagData:use("eat", self.data:get("makeIndex")) then
				net.send({
					eatMsg,
					recog = self.data:get("makeIndex")
				})
				self.formPanel:delItem(self.data:get("makeIndex"))
			end
		end

		if self.data.getVar("stdMode") == 4 then
			an.newMsgbox(string.format("[%s] 你想要开始训练吗? ", self.data.getVar("name")), function (isOk)
				if isOk == 1 then
					use()
				end
			end, {
				center = true,
				hasCancel = true
			}):setName("msgBoxLearnSkill")
		elseif self.data.getVar("stdMode") == 47 then
			if self.data.getVar("name") == "传情烟花" then
				local msgbox = nil
				msgbox = an.newMsgbox("请输入传情烟花文字", function (idx)
					if idx == 2 then
						if msgbox.input:getString() == "" then
							return
						end

						net.send({
							CM_YANHUA_TEXT,
							recog = self.data:get("makeIndex")
						}, {
							msgbox.input:getString()
						})
					end
				end, {
					disableScroll = true,
					input = 20,
					btnTexts = {
						"关闭",
						"确定"
					}
				})
			elseif self.data.getVar("name") == "金条" then
				an.newMsgbox("确定使用一根金条兑换998000金币吗？", function ()
					if g_data.bag:use("eat", self.data:get("makeIndex"), {
						quick = false
					}) then
						net.send({
							eatMsg,
							recog = self.data:get("makeIndex")
						})
						self.formPanel:delItem(self.data:get("makeIndex"))
					end
				end, {
					center = true
				})
			end
		elseif self.data.getVar("stdMode") == 159 then
			net.send({
				CM_V_POWERSTONE,
				recog = self.data:get("makeIndex")
			})
		elseif self.data.getVar("stdMode") == 46 then
			print(self.data:get("makeIndex"))
			self:useTreasureBox(self.data, bagData)
		else
			use()
		end
	end
end

function item:takeOff()
	if self.formPanel.__cname == "equip" then
		if g_data.equip:takeOff(self.data:get("makeIndex"), {
			where = self.params.idx
		}) then
			net.send({
				CM_TAKEOFFITEM,
				recog = self.data:get("makeIndex"),
				param = self.params.idx
			}, {
				self.data.getVar("name")
			})
			self.formPanel:delItem(self.data:get("makeIndex"))
		end
	elseif g_data.heroEquip:takeOff(self.data:get("makeIndex"), {
		where = self.params.idx
	}) then
		net.send({
			CM_HERO_TAKEOFF,
			recog = self.data:get("makeIndex"),
			param = self.params.idx
		}, {
			self.data.getVar("name")
		})
		self.formPanel:delItem(self.data:get("makeIndex"))
	end
end

function item:throw()
	local function dropItem(cmd, from)
		net.send({
			cmd,
			recog = self.data:get("makeIndex")
		}, {
			self.data.getVar("name")
		})
		from:throw(self.data:get("makeIndex"))
		self.formPanel:delItem(self.data:get("makeIndex"))
	end

	if self.formPanel.__cname == "bag" then
		if self.params.isGold then
			local msgbox = nil
			msgbox = an.newMsgbox("请输入你要丢的金币数量", function ()
				if msgbox.nameInput:getString() == "" then
					return
				end

				local num = tonumber(msgbox.nameInput:getString())

				if num then
					net.send({
						CM_DROPGOLD,
						recog = num
					})
				end
			end, {
				disableScroll = true
			})
			msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 14, {
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
			}):add2(msgbox.bg):pos(msgbox.bg:getw() * 0.5 + 10, msgbox.bg:geth() * 0.5 + 20)

			return
		end

		local cfg = def.items.filt[self.data.getVar("name")]

		if cfg and cfg.isGood then
			local extStr = g_data.credit.isAuthen and "" or "\n未验证角色丢弃物品后其他玩家无法拾取"
			local str = string.format("确认丢弃%s?%s", self.data.getVar("name"), extStr)

			an.newMsgbox(str, function ()
				dropItem(CM_DROPITEM, g_data.bag)
			end, {
				center = true
			})
		else
			dropItem(CM_DROPITEM, g_data.bag)
		end
	else
		local cfg = def.items.filt[self.data.getVar("name")]

		if cfg and cfg.isGood then
			local extStr = g_data.credit.isAuthen and "" or "\n未验证角色丢弃物品后其他玩家无法拾取"
			local str = string.format("确认丢弃%s?%s", self.data.getVar("name"), extStr)

			an.newMsgbox(str, function ()
				dropItem(CM_HERO_DROPITEM, g_data.heroBag)
			end, {
				center = true
			})
		else
			dropItem(CM_HERO_DROPITEM, g_data.heroBag)
		end
	end
end

function item:duraChange()
	if self.data.isPileUp() and self.dura then
		self.dura:setString("" .. self.data:get("dura"))
	end
end

item.isChose = nil
item.isShowInfo = nil

function item:registerMouseEvent()
	self:registerScriptHandler(function (event)
		if event == "exit" then
			self:onExit()
		end
	end)

	self.mouseListener = cc.EventListenerMouse:create()

	self.mouseListener:registerScriptHandler(function (evt)
		if g_data.hotKey.isSettingKey then
			return
		end

		self:onMouseDown(evt)
	end, cc.Handler.EVENT_MOUSE_DOWN)
	self.mouseListener:registerScriptHandler(function (evt)
		if g_data.hotKey.isSettingKey then
			return
		end

		self:onMouseMoved(evt)
	end, cc.Handler.EVENT_MOUSE_MOVE)
	self.mouseListener:registerScriptHandler(function (evt)
		if g_data.hotKey.isSettingKey then
			return
		end

		self:onMouseUp(evt)
	end, cc.Handler.EVENT_MOUSE_UP)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.mouseListener, 1)
end

function item:onExit()
	if self.isChose then
		main_scene.ui.isChoseItem = false
	end

	self:removeItemInfo()

	if self.mouseListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.mouseListener)

		self.mouseListener = nil
	end
end

function item:onMouseDown(evt)
	if evt:getMouseButton() == 1 then
		return
	end

	if main_scene.ui.isChoseItem and not self.isChose then
		return
	end

	self.mouseDown = true
	local x = evt:getCursorX()
	local y = evt:getCursorY()

	if self:isInRect(cc.p(x, y)) then
		if self.handler then
			scheduler.unscheduleGlobal(self.handler)

			self.handler = nil
			self.clicked = true
			self.isChose = false
			main_scene.ui.isChoseItem = false
		end

		if not self.isChose then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(x, y)
			self.hasMove = false

			self:setLocalZOrder(self:getLocalZOrder() + 1)
		end
	end
end

function item:onMouseMoved(evt)
	local x = evt:getCursorX()
	local y = evt:getCursorY()

	if self.isChose then
		if not self.beganTouchPos then
			return
		end

		if math.abs(self.beganTouchPos.x - x) > 5 or math.abs(self.beganTouchPos.y - y) > 5 then
			if self.handler then
				scheduler.unscheduleGlobal(self.handler)

				self.handler = nil
			end

			self:followMouse(x, y)
			self:setLocalZOrder(main_scene.ui.z.focus + 1)
		end
	elseif self:isInRect(cc.p(x, y)) then
		if not self.infoLayer and not self.params.isGold and self.sprite then
			local p = self.sprite:convertToWorldSpace(cc.p(self.sprite:getw() / 2, self.sprite:geth() / 2))
			self.infoLayer = itemInfo.show(self.data, p, {
				from = form,
				extend = self.params.extend
			})

			if self.infoLayer then
				self.infoLayer:setTouchEnabled(false)
			end

			if self.params.clickcb then
				self.params.clickcb(self)
			end
		end
	else
		self:removeItemInfo()
	end
end

function item:onMouseUp(evt)
	self:removeItemInfo()

	local x = evt:getCursorX()
	local y = evt:getCursorY()

	if evt:getMouseButton() == 0 then
		if not self.mouseDown then
			return
		end

		if self.clicked then
			print("----双击------")

			if self:isInRect(cc.p(x, y)) then
				self:mouseDoubleClick()

				self.clicked = nil
			end
		elseif not self.isChose then
			if not main_scene.ui.isChoseItem then
				if self:isInRect(cc.p(x, y)) then
					if not self.params.donotMove then
						print("----选中------")

						self.isChose = true
						main_scene.ui.isChoseItem = true
						self.initZorder = self:getLocalZOrder()

						if self.params.isGold then
							sound.playSound(sound.s_money)
						else
							sound.play("item", self.data)
						end
					end

					self.handler = scheduler.performWithDelayGlobal(function ()
						self.handler = nil
					end, 0.25)
				end
			else
				self.mouseDown = nil
			end
		else
			print("----放下------")

			self.isChose = false
			main_scene.ui.isChoseItem = false
			self.hasMove = true

			self:setLocalZOrder(self.initZorder)
			self:onTouchEnded({
				x = x,
				y = y
			})
		end

		self.mouseDown = nil
	elseif self.isChose then
		print("----撤销------")

		self.isChose = false
		main_scene.ui.isChoseItem = false

		self:pos(self.beganPos.x, self.beganPos.y)

		if self.params and self.params.isSetOffset and self.sprite then
			self.sprite:show()
			self.sprite2:hide()
		end

		self:setLocalZOrder(self.initZorder)
	end
end

function item:mouseDoubleClick()
	local form = self.formPanel.__cname
	local quick = nil

	if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
		quick = true
	end

	if quick and (form == "storage" or form == "bag") then
		if form == "bag" then
			main_scene.ui.panels.storage:putItem(self)
		else
			main_scene.ui.panels.bag:putItem(self)
		end
	else
		if not self.params.mute then
			sound.play("item", self.data)
		end

		if form == "bag" or form == "heroBag" then
			self:use()
		elseif form == "equip" or form == "heroEquip" then
			self:takeOff()
		elseif self.customNode then
			main_scene.ui.console.btnCallbacks:handle("custom", self.customNode)
		end
	end
end

function item:followMouse(x, y)
	local scale = not self.params.isSetOffset and self.formPanel._scale or 1

	if self.params.isSetOffset then
		self.sprite:hide()
		self.sprite2:show()

		local p = self:getParent():convertToWorldSpace(cc.p(0, 0))

		self:pos((x - p.x) / scale, (y - p.y) / scale)
	else
		self:pos((x - self.beganTouchPos.x) / scale + self.beganPos.x, (y - self.beganTouchPos.y) / scale + self.beganPos.y)
	end
end

function item:removeItemInfo()
	if self.infoLayer then
		g_data.player.showTips = false

		self.infoLayer:removeSelf()

		self.infoLayer = nil
	end
end

function item:isInRect(pos)
	local lastZ = -1
	local topForm = nil
	local panels = sortNodes(table.values(main_scene.ui.panels))

	for i, v in ipairs(panels) do
		if v:checkInPanel(pos) and lastZ < v:getLocalZOrder() then
			lastZ = v:getLocalZOrder()
			topForm = v
		end
	end

	local customs = sortNodes(table.values(main_scene.ui.customs))

	for i, v in ipairs(customs) do
		if v:checkInButton(pos) and lastZ < 0 then
			lastZ = v:getLocalZOrder()
			topForm = v
		end
	end

	local p = self.sprite:convertToWorldSpace(cc.p(0, 0))
	local rect = cc.rect(p.x, p.y, self.sprite:getw(), self.sprite:geth())

	if cc.rectContainsPoint(rect, pos) and topForm and topForm.__cname == self.formPanel.__cname then
		return true
	end

	return false
end

return item
