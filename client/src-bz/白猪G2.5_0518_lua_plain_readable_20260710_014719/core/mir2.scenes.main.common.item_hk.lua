local itemInfo = import(".itemInfo")
local item = class("item", function()
	return display.newNode()
end)
local common = import(".common")

table.merge(item, {
	mute = false,
	w = 45,
	h = 45
})

function item:ctor(data, formPanel, params)
	self.data = data
	self.formPanel = formPanel
	self.params = params or {}
	params = params or {}

	local form = formPanel.__cname
	local isSetOffset = params.isSetOffset
	local value = params.showbg
	local value2 = params.showEffect

	if params.tex then
		self.sprite = display.newSprite(params.tex):addto(self)
	else
		self.sprite = res.getItemsWithBg(params.img or "items", self.data.getVar("name"), self.data.getVar("looks") or 0, value, value2):addto(self)
	end

	if isSetOffset then
		local info = res.getinfo(params.img or "items", self.data.getVar("looks"))

		if info and info.x and info.y then
			self.sprite:anchor(0, 1):pos(info.x * formPanel._scale, -info.y * formPanel._scale):scale(formPanel._scale)
		end

		self.sprite2 = res.getItemsWithBg(params.img or "items", self.data.getVar("name"), self.data.getVar("looks"), value, value2):addto(self):hide()
	else
		display.newNode():size(item.w, item.h):anchor(0.5, 0.5):addto(self)
	end

	if data.isPileUp and data.isPileUp() then
		self.dura = an.newLabel("" .. data.get(data, "dura"), 12, 1, {
			color = cc.c3b(0, 255, 0)
		}):anchor(1, 0):pos(16, -20):add2(self, 1)
	end

	if def.showJPItemTips and not params.hideJPTips and _is_equip_item(data) then
		local text = def.ccy.jpior(data)

		if text > 0 then
			an.newLabel("+" .. tostring(text), 14, 0, {
				color = display.COLOR_GREEN
			}):addTo(self, 4):pos(-22, 22):anchor(0, 1)
		end
	end

	if def.showYsItemTips and _is_equip_item(data) then
		local value3 = def.showYsItemTips

		if value3.open and (not value3.allowItems or checkExist(data.getVar("name"), unpack(value3.allowItems:split(",")))) and value3.allowYs then
			local ipush = require("mir2.single.ipush")[2]
			local value4 = (ipush and ipush(data) or {}).元素1
			local value5

			if not _getysNew2 then
				os.exit()
			end

			local value6 = _getysNew2(data)

			if value3.allowYs == 1 then
				if value4 and value4 > 0 then
					value5 = value4
				elseif value6[141] and value6[141] > 0 then
					value5 = value6[141]
				end
			else
				value5 = value6[112 + value3.allowYs]
				value5 = value5 or value6[140 + value3.allowYs]
			end

			if not value5 or (form == "equip" or form == "heroEquip") and checkExist(self.data.getVar("stdMode"), 5, 6, 10, 11, 15) then
				-- block empty
			elseif value3.picBindYs then
				res.get2("pic/bzmir/effect/ysflag/ys" .. value5 .. ".png"):addTo(self, 5):pos(self:getw() / 2 + value3.OfstX or 0, self:geth() / 2 + value3.OfstY or 0):anchor(0.5, 0.5)
			elseif value5 == 1 then
				res.get2("pic/bzmir/effect/ysflag/" .. (value3.ys1pic or "ys1.png")):addTo(self, 5):pos(self:getw() / 2 + value3.OfstX or 0, self:geth() / 2 + value3.OfstY or 0):anchor(0.5, 0.5)
			elseif value5 > 1 then
				res.get2("pic/bzmir/effect/ysflag/" .. (value3.ys2pic or "ys2.png")):addTo(self, 5):pos(self:getw() / 2 + value3.OfstX or 0, self:geth() / 2 + value3.OfstY or 0):anchor(0.5, 0.5)
			end
		end
	end

	if WIN32_OPERATE then
		self.registerMouseEvent(self)
	else
		self.registerTouchEvent(self)
	end
end

function item:registerTouchEvent()
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function(event)
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

	self.beganPos = cc.p(self.getPosition(self))
	self.beganTouchPos = cc.p(event.x, event.y)
	self.hasMove = false

	self.setLocalZOrder(self, self.getLocalZOrder(self) + 1)

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

			local point = self.getParent(self):convertToWorldSpace(cc.p(0, 0))

			self.pos(self, (event.x - point.x) / scale, (event.y - point.y) / scale)
		else
			self.pos(self, (event.x - self.beganTouchPos.x) / scale + self.beganPos.x, (event.y - self.beganTouchPos.y) / scale + self.beganPos.y)
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
			if v.checkInPanel(v, pos) then
				if v.putItem and not self.params.isGold then
					local point = v.convertToWorldSpace(v, cc.p(0, 0))

					ret = v.putItem(v, self, pos.x - point.x, pos.y - point.y)
				elseif v.putGold and self.params.isGold then
					v.putGold(v, self)
				end

				isInPanel = true

				break
			end
		end

		local isInCustom = false

		if not isInPanel then
			local customs = sortNodes(table.values(main_scene.ui.customs))

			for i2, v2 in ipairs(customs) do
				if v2.checkInButton(v2, pos) then
					isInCustom = true
				end

				if isInCustom then
					if v2.checkItemType(v2, self.data) then
						local data = self.data
						local owner = self.owner

						if self.customNode and v2 ~= self.customNode then
							self.customNode:custom_delItem()
						end

						v2.setCustomProps(v2, data, owner)
					end

					break
				end
			end
		end

		if self.customNode and not isInCustom then
			local customs2 = sortNodes(table.values(main_scene.ui.customs))

			for i3, v3 in ipairs(customs2) do
				if v3.btn.item == self then
					v3.custom_delItem(v3)

					break
				end
			end
		end

		if not isInPanel and not isInCustom and (form == "bag" or form == "heroBag") then
			self.throw(self)
		end

		if self.params and self.params.isSetOffset and self.sprite then
			self.sprite:show()
			self.sprite2:hide()
		end

		if not ret and self.beganPos then
			self.pos(self, self.beganPos.x, self.beganPos.y)
		else
			return
		end
	else
		local enabled = false

		if self.sprite.centerPos then
			local point2 = self.sprite:convertToWorldSpace(self.sprite.centerPos)

			if math.abs(event.x - point2.x) <= math.max(self.sprite:getw() / 2, 25) and math.abs(event.y - point2.y) <= math.max(self.sprite:geth() / 2, 25) then
				enabled = true
			end
		else
			enabled = true
		end

		if enabled then
			self.handler = scheduler.performWithDelayGlobal(handler(self, self.click), 0.25)
		end
	end

	self.hasMove = false

	self.setLocalZOrder(self, self.getLocalZOrder(self) - 1)
end

function item:click()
	local form = self.formPanel.__cname
	local quick
	local quick2

	if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
		quick = true
	end

	if main_scene.ui.panels.heroBag and main_scene.ui.panels.heroBag.quick then
		quick2 = true
	end

	if quick and (form == "storage" or form == "bag") then
		if form == "bag" then
			main_scene.ui.panels.storage:putItem(self)
		else
			main_scene.ui.panels.bag:putItem(self)
		end
	elseif quick2 and (form == "heroBag" or form == "bag") then
		if form == "heroBag" then
			main_scene.ui.panels.bag:putItem(self)
		else
			main_scene.ui.panels.heroBag:putItem(self)
		end
	elseif self.clicked then
		if not self.params.mute then
			sound.play("item", self.data)
		end

		if form == "bag" or form == "heroBag" then
			self.use(self)
		elseif form == "equip" or form == "heroEquip" then
			self.takeOff(self)
		elseif self.customNode then
			main_scene.ui.console.btnCallbacks:handle("custom", self.customNode)
		end
	elseif not self.params.isGold and self.sprite then
		local p = self.sprite:convertToWorldSpace(cc.p(self.sprite:getw() / 2, self.sprite:geth() / 2))

		if self.sprite.centerPos then
			p = self.sprite:convertToWorldSpace(self.sprite.centerPos)
		end

		itemInfo.create(self, p, {
			showBtn = true,
			idx = self.params.idx,
			extend = self.params.extend,
			from = form
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
	local var = item.getVar("needJob")

	if getTakeOnPosition(item.getVar("stdMode")) then
		local ret = true

		if need == 0 then
			ret = chargeNeed("等级不够", needLevel <= playerData.ability:get("level"))
		elseif need == 1 then
			ret = chargeNeed("攻击力不足", needLevel <= playerData.ability:get("maxDC"))
		elseif need == 2 then
			ret = chargeNeed("魔法力不足", needLevel <= playerData.ability:get("maxMC"))
		elseif need == 3 then
			ret = chargeNeed("道术力不足", needLevel <= playerData.ability:get("maxSC"))
		elseif need == 5 and isPlayer then
			ret = chargeNeed("你的" .. CS_PRESTIGE .. "不足，不能佩戴", needLevel >= g_data.player.ability3:get("prestige"))
		end

		if var >= 8 then
			ret = chargeNeed("职业不符合", var == g_data.player.job)
		end

		if g_data.player.job >= 8 and def.newJobNeedNewSuit and checkExist(item.getVar("stdMode"), 5, 10, 11) then
			ret = chargeNeed("职业不符合", var == g_data.player.job)
		end

		if not ret then
			return
		end
	end

	if item.getVar("stdMode") == 4 then
		local shape = item.getVar("shape") or 0

		if shape ~= 3 and (shape ~= 4 or false) and shape ~= playerData.job then
			common.addMsg("不能学习其他职业技能书", display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end

		if math.modf(Word(item.getVar("duraMax"))) > playerData.ability:get("level") then
			common.addMsg("等级不够", display.COLOR_RED, display.COLOR_WHITE, true)

			return false
		end
	end

	return true
end

function item:getItemSourceInfo()
	local bagData
	local equipData
	local eatMsg
	local takeonMsg

	if self.formPanel.__cname == "bag" then
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	else
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
	local boxIndex = item.get(item, "makeIndex")
	local keyIndex = item.get(item, "makeIndex")
	local findName
	local isKey = true

	for k, v in pairs(cBox2Names) do
		if v == name then
			findName = cBox2KeyNames[k]
			isKey = false
			g_data.usingTreasureKeyName = findName
		elseif cBox2KeyNames[k] == name then
			findName = v
			g_data.usingTreasureKeyName = name
		end
	end

	if not findName then
		return
	end

	for k2, v2 in pairs(bagData.items) do
		if v2.getVar("name") == findName then
			if isKey then
				boxIndex = v2.get(v2, "makeIndex")
			else
				keyIndex = v2.get(v2, "makeIndex")
			end
		end
	end

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
	local bagData
	local equipData
	local eatMsg
	local takeonMsg
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
		if main_scene.ui.panels.deal then
			main_scene.ui:tip("面对面交易无法穿戴")

			return
		end

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

		if self.canUseEquip(self, self.data, bagData, weight, isPlayer) and bagData.use(bagData, "take", self.data:get("makeIndex"), {
			where = where
		}) then
			net.send({
				takeonMsg,
				recog = self.data:get("makeIndex"),
				param = where
			}, {
				self.data.getVar("name")
			})
			def.ccy.equipChgTrigger("on", tostring(where), self.data)

			if main_scene.ui.panels.bag or main_scene.ui.panels.heroBag then
				self.formPanel:delItem(self.data:get("makeIndex"))
			end
		end
	else
		if equipIdx then
			return
		end

		if not self.canUseEquip(self, self.data, bagData, 0, isPlayer) then
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
			an.newMsgbox(string.format("[%s] 你想要开始训练吗? ", self.data.getVar("name")), function(isOk)
				if isOk == 1 then
					if def.customLearnSkills and type(def.customLearnSkills) == "string" then
						local var = self.data.getVar("name")

						if def.customLearnSkills:find(var) ~= nil then
							def.role.call("@learnSkill~" .. var)

							return
						end
					end

					use()
				end
			end, {
				center = true,
				hasCancel = true
			}):setName("msgBoxLearnSkill")
		elseif self.data.getVar("stdMode") == 47 then
			if self.data.getVar("name") == "传情烟花" then
				local msgbox

				msgbox = an.newMsgbox("请输入传情烟花文字", function(idx)
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
				an.newMsgbox("确定使用一根金条兑换998000金币吗？", function()
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
			self.useTreasureBox(self, self.data, bagData)
		elseif def.role.mainsetting.banShuiji and self.data.getVar("name") == "随机传送石" then
			main_scene.ui:fadeLabel("该地图能使用随机传送石")
		elseif def.openShuijiCD and (self.data.getVar("name") == "随机传送卷" or self.data.getVar("name") == "随机传送石") then
			if g_data.player.cmAbil.banMove then
				main_scene.ui:tip("您当前无法移动")

				return
			end

			if g_data.client:checkLastTime("shuijicd", def.openShuijiCD) then
				g_data.client:setLastTime("shuijicd", true)
				use()
			else
				main_scene.ui:tip("操作太快")
			end
		elseif self.data.getVar("name"):find("传送石") ~= nil or self.data.getVar("name"):find("回城卷") ~= nil or self.data.getVar("name") == "地牢逃脱卷" then
			if g_data.player.cmAbil.banMove then
				main_scene.ui:tip("您当前无法移动")

				return
			end

			use()
		else
			use()
		end
	end
end

function item:takeOff()
	local where = self.params.idx

	if self.formPanel.__cname == "equip" then
		if g_data.equip:takeOff(self.data:get("makeIndex"), {
			where = where
		}) then
			net.send({
				CM_TAKEOFFITEM,
				recog = self.data:get("makeIndex"),
				param = self.params.idx
			}, {
				self.data.getVar("name")
			})
			def.ccy.equipChgTrigger("off", tostring(where), self.data)
			self.formPanel:delItem(self.data:get("makeIndex"))
		end
	elseif self.formPanel.__cname == "heroEquip" and g_data.heroEquip:takeOff(self.data:get("makeIndex"), {
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

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function item:throw()
	local function dropItem(cmd, from)
		net.send({
			cmd,
			recog = self.data:get("makeIndex")
		}, {
			self.data.getVar("name")
		})
		from.throw(from, self.data:get("makeIndex"))
		self.formPanel:delItem(self.data:get("makeIndex"))
		g_data.client:setLastTime("dropItem", true)
	end

	if self.formPanel.__cname == "bag" then
		if self.params.isGold then
			local msgbox

			msgbox = an.newMsgbox("请输入你要丢的金币数量", function()
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
			local str = string.format("是否确定丢弃贵重物品：%s?", def.ccy.getItemName(self))

			an.newMsgbox(str, function()
				dropItem(CM_DROPITEM, g_data.bag)
			end, {
				center = true
			})
		else
			dropItem(CM_DROPITEM, g_data.bag)
		end
	else
		local cfg2 = def.items.filt[self.data.getVar("name")]

		if cfg2 and cfg2.isGood then
			local str2 = string.format("是否确定丢弃贵重物品：%s?", def.ccy.getItemName(self))

			an.newMsgbox(str2, function()
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
	self.registerScriptHandler(self, function(event)
		if event == "exit" then
			self:onExit()
		end
	end)

	self.mouseListener = cc.EventListenerMouse:create()

	self.mouseListener:registerScriptHandler(function(evt)
		if g_data.hotKey.isSettingKey then
			return
		end

		self:onMouseDown(evt)
	end, cc.Handler.EVENT_MOUSE_DOWN)
	self.mouseListener:registerScriptHandler(function(evt)
		if g_data.hotKey.isSettingKey then
			return
		end

		self:onMouseMoved(evt)
	end, cc.Handler.EVENT_MOUSE_MOVE)
	self.mouseListener:registerScriptHandler(function(evt)
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

	self.removeItemInfo(self)

	if self.mouseListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.mouseListener)

		self.mouseListener = nil
	end
end

function item:onMouseDown(evt)
	if evt.getMouseButton(evt) == 1 then
		return
	end

	if main_scene.ui.isChoseItem and not self.isChose then
		return
	end

	self.mouseDown = true

	local x = evt.getCursorX(evt)
	local y = evt.getCursorY(evt)

	if self.isInRect(self, cc.p(x, y)) then
		if self.handler then
			scheduler.unscheduleGlobal(self.handler)

			self.handler = nil
			self.clicked = true
			self.isChose = false
			main_scene.ui.isChoseItem = false
		end

		if not self.isChose then
			self.beganPos = cc.p(self.getPosition(self))
			self.beganTouchPos = cc.p(x, y)
			self.hasMove = false

			self.setLocalZOrder(self, self.getLocalZOrder(self) + 1)
		end
	end
end

function item:onMouseMoved(evt)
	local x = evt.getCursorX(evt)
	local y = evt.getCursorY(evt)

	if self.isChose then
		if not self.beganTouchPos then
			return
		end

		if math.abs(self.beganTouchPos.x - x) > 5 or math.abs(self.beganTouchPos.y - y) > 5 then
			if self.handler then
				scheduler.unscheduleGlobal(self.handler)

				self.handler = nil
			end

			self.followMouse(self, x, y)
			self.setLocalZOrder(self, main_scene.ui.z.focus + 1)
		end
	elseif self.isInRect(self, cc.p(x, y)) then
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
		self.removeItemInfo(self)
	end
end

function item:onMouseUp(evt)
	self.removeItemInfo(self)

	local x = evt.getCursorX(evt)
	local y = evt.getCursorY(evt)

	if evt.getMouseButton(evt) == 0 then
		if not self.mouseDown then
			return
		end

		if self.clicked then
			if self.isInRect(self, cc.p(x, y)) then
				self.mouseDoubleClick(self)

				self.clicked = nil
			end
		elseif not self.isChose then
			if not main_scene.ui.isChoseItem then
				if self.isInRect(self, cc.p(x, y)) then
					if not self.params.donotMove then
						self.isChose = true
						main_scene.ui.isChoseItem = true
						self.initZorder = self.getLocalZOrder(self)

						if self.params.isGold then
							sound.playSound(sound.s_money)
						else
							sound.play("item", self.data)
						end
					end

					self.handler = scheduler.performWithDelayGlobal(function()
						self.handler = nil
					end, 0.25)
				end
			else
				self.mouseDown = nil
			end
		else
			self.isChose = false
			main_scene.ui.isChoseItem = false
			self.hasMove = true

			self.setLocalZOrder(self, self.initZorder)
			self.onTouchEnded(self, {
				x = x,
				y = y
			})
		end

		self.mouseDown = nil
	elseif self.isChose then
		self.isChose = false
		main_scene.ui.isChoseItem = false

		self.pos(self, self.beganPos.x, self.beganPos.y)

		if self.params and self.params.isSetOffset and self.sprite then
			self.sprite:show()
			self.sprite2:hide()
		end

		self.setLocalZOrder(self, self.initZorder)
	end
end

function item:mouseDoubleClick()
	local form = self.formPanel.__cname
	local quick
	local quick2

	if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
		quick = true
	end

	if main_scene.ui.panels.heroBag and main_scene.ui.panels.heroBag.quick then
		quick2 = true
	end

	if quick and (form == "storage" or form == "bag") then
		if form == "bag" then
			main_scene.ui.panels.storage:putItem(self)
		else
			main_scene.ui.panels.bag:putItem(self)
		end
	elseif quick2 and (form == "heroBag" or form == "bag") then
		if form == "heroBag" then
			main_scene.ui.panels.bag:putItem(self)
		else
			main_scene.ui.panels.heroBag:putItem(self)
		end
	else
		if not self.params.mute then
			sound.play("item", self.data)
		end

		if form == "bag" or form == "heroBag" then
			self.use(self)
		elseif form == "equip" or form == "heroEquip" then
			self.takeOff(self)
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

		local point = self.getParent(self):convertToWorldSpace(cc.p(0, 0))

		self.pos(self, (x - point.x) / scale, (y - point.y) / scale)
	else
		self.pos(self, (x - self.beganTouchPos.x) / scale + self.beganPos.x, (y - self.beganTouchPos.y) / scale + self.beganPos.y)
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
	local topForm
	local panels = sortNodes(table.values(main_scene.ui.panels))

	for i, v in ipairs(panels) do
		if v.checkInPanel(v, pos) and lastZ < v.getLocalZOrder(v) then
			lastZ = v.getLocalZOrder(v)
			topForm = v
		end
	end

	local customs = sortNodes(table.values(main_scene.ui.customs))

	for i2, v2 in ipairs(customs) do
		if v2.checkInButton(v2, pos) and lastZ < 0 then
			lastZ = v2.getLocalZOrder(v2)
			topForm = v2
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
