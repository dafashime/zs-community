local item = import("..common.item")
local common = import("..common.common")
local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local number = 48
local bag = class("bag", function()
	return display.newNode()
end)

table.merge(bag, {})

function bag:resetPanelPosition(type)
	if type == "left" then
		self:anchor(0, 1):pos(80, display.height)
	elseif type == "right" then
		self:anchor(1, 1):pos(display.width - 50, display.height - 50)
	elseif type == "stall" then
		self:anchor(0, 0.5):pos(display.cx - 120, display.cy + 50)
	elseif type == "ybdeal" then
		self:anchor(0, 0.5):pos(display.cx + 65, display.cy)
	elseif type == "storage" then
		self:anchor(0, 1):pos(display.cx + 30, display.height - 50)
	end

	if self.setFocus then
		self:setFocus()
	end

	return self
end

function bag:gotoPage(pageIdx)
	self.pageIdx = pageIdx

	self:reload()
end

function bag:ctor()
	self._scale = g_data.client.lastScale.bag or 1
	self.pageIdx = 1
	self._supportMove = true

	self:setNodeEventEnabled(true)

	local bg = res.get2("pic/panels/bag/bg.png"):anchor(0, 0):addto(self)

	self:size(cc.size(bg:getContentSize().width, bg:getContentSize().height)):resetPanelPosition("left"):scale(1)
	display.newNode():size(self:getw() - 40, self:geth() - 110):pos(20, 60):add2(self):enableClick(function()
		return
	end)

	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("right")
	end

	an.newBtn(res.gettex2("pic/panels/bag/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/panels/bag/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(self:getw(), self:geth()):addto(self):setName("bag_close")

	if def.enableHuishou then
		an.newBtn(res.gettex2("pic/panels/bag/zlbb.png"), function()
			sound.playSound("103")
			def.role.call("@huishou")
		end, {
			sprite = res.gettex2("pic/panels/bag/bz_huishou.png"),
			pressImage = res.gettex2("pic/panels/bag/zlbb2.png")
		}):pos(257, 89):add2(self)
	end

	an.newBtn(res.gettex2("pic/panels/bag/zlbb.png"), function()
		sound.playSound("103")

		if g_data.client:checkLastTime("queryBag", 1) then
			g_data.client:setLastTime("queryBag", true)
			net.send({
				CM_QUERYBAGITEMS
			})
			self:gotoPage(1)
		else
			main_scene.ui:tip("点击过快")
		end
	end, {
		sprite = res.gettex2("pic/panels/bag/bz_zhenli.png"),
		pressImage = res.gettex2("pic/panels/bag/zlbb2.png")
	}):pos(348, 89):add2(self)

	if def.enableRemoteWarehouse then
		an.newBtn(res.gettex2("pic/panels/bag/btn600.png"), function()
			sound.playSound("103")
			def.role.call("@cangku")
		end, {
			pressImage = res.gettex2("pic/panels/bag/btn601.png")
		}):pos(430, 83):add2(self)
	end

	self.items = {}
	self.locks = {}

	if g_data.bag.max > number then
		local sprs = {
			"pic/panels/bag/bz_yi.png",
			"pic/panels/bag/bz_er.png",
			"pic/panels/bag/bz_san.png",
			"pic/panels/bag/bz_si.png"
		}

		self.tabs = common.tabs(self, {
			oy = 10,
			size = 20,
			sprs = sprs,
			lc = {
				normal = cc.c3b(194, 182, 148),
				select = cc.c3b(194, 182, 148)
			},
			sc = {
				normal = cc.c3b(0, 0, 0),
				select = cc.c3b(0, 0, 0)
			}
		}, function(value, value2)
			sound.playSound("103")
			self:gotoPage(value)
		end, {
			tabTp = 1,
			pos = {
				offset = 70,
				x = 5,
				y = 420,
				anchor = cc.p(1, 1)
			},
			file = {
				normal = "pic/common/btn110.png",
				select = "pic/common/btn111.png"
			}
		})
	end

	local gold = getRecord("TClientItem")

	gold.setIndex(1)

	local value = g_data.player.gold

	if def.customBagGold and g_data.player.cmAbil[def.customBagGold] then
		value = g_data.player.cmAbil[def.customBagGold]
	end

	local value2 = g_data.player.goldNum.gold

	if def.customBagYB and g_data.player.cmAbil[def.customBagYB] then
		value2 = g_data.player.cmAbil[def.customBagYB]
	end

	local value3 = g_data.player.goldNum.gird

	if def.customBagLF and g_data.player.cmAbil[def.customBagYB] then
		value3 = g_data.player.cmAbil[def.customBagLF]
	end

	item.new(gold, self, {
		isGold = true,
		tex = res.gettex2("pic/panels/bag/gold.png")
	}):addto(self):pos(25, 82)

	self.gold = an.newLabel(change2GoldStyle(value), 14, 0, {
		color = cc.c3b(255, 255, 255)
	}):pos(60, 82):addto(self)

	if def.openBagYB then
		res.get2("pic/panels/bag/bz_diy_yb.png"):addTo(self):pos(55, 37):anchor(0, 0):scale(0.75)

		self.yb = an.newLabel(change2GoldStyle(value2), 14, 0, {
			color = cc.c3b(255, 255, 255)
		}):pos(105, 39):addto(self)
	end

	if def.openBagLF then
		res.get2("pic/panels/bag/bz_diy_lf.png"):addTo(self):pos(55, 16):anchor(0, 0):scale(0.75)

		self.lingfu = an.newLabel(change2GoldStyle(value3), 14, 0, {
			color = cc.c3b(255, 255, 255)
		}):pos(105, 18):addto(self)
	end

	self.uptCurrency = def.role.createRepeater(function()
		local value = g_data.player.goldNum.gold

		if def.customBagYB and g_data.player.cmAbil[def.customBagYB] then
			value = g_data.player.cmAbil[def.customBagYB]
		end

		local value2 = g_data.player.goldNum.gird

		if def.customBagLF and g_data.player.cmAbil[def.customBagYB] then
			value2 = g_data.player.cmAbil[def.customBagLF]
		end

		if def.openBagYB then
			self.yb:setString(change2GoldStyle(value))
		end

		if def.openBagLF then
			self.lingfu:setString(change2GoldStyle(value2))
		end

		if def.customBagGold and g_data.player.cmAbil[def.customBagGold] then
			self.gold:setString(change2GoldStyle(g_data.player.cmAbil[def.customBagGold]))
		else
			self.gold:setString(change2GoldStyle(g_data.player.gold))
		end
	end, 0.1)

	if g_data.hero and g_data.hero.roleid > 0 then
		display.newScale9Sprite(res.getframe2("pic/scale/scale22.png")):size(50, 48):addto(self):pos(self:getw() - 57, 36)

		self.heroBtn = an.newBtn(res.gettex2("pic/panels/bag/hero1.png"), function()
			sound.playSound("103")
			main_scene.ui:togglePanel("heroBag")
		end, {
			pressImage = res.gettex2("pic/panels/bag/hero2.png")
		}):pos(self:getw() - 58, 35):add2(self)
	end

	if not self.isEventProxyRegd then
		cc.EventProxy.new(_Events, self):addEventListener(_Events.CM_PASS_OK, function(response)
			if response.data.OK then
				g_data.player.passOK = true

				if main_scene.ui.panels.storage then
					main_scene.ui.panels.storage:reload()
				end

				self:reload()
			else
				an.newMsgbox("你输入的二级密码错误。", nil, {
					center = true
				})
			end
		end)
		self:reload()
		self:cm_ext()

		self.isEventProxyRegd = true
	end
end

function bag:onCleanup()
	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("left")
	end

	if self.uptCurrency then
		def.role.stopRepeater(self.uptCurrency)
	end
end

function bag:showPassDialog()
	local text = "pic/common/msgtitle.png"
	local label
	local value, x = common.msgbox("", {
		okFunc = function()
			local text = label:getText()

			def.role.call("@callItemAuthPass~" .. text)
		end
	})

	an.newLabel("请输入二级密码", 20, 1):addTo(x):pos(x:getw() / 2, 180):anchor(0.5, 0.5)

	label = an.newInput(x:getw() / 2, 140, 250, 36, 14, {
		checkCLen = true,
		password = true,
		bg = {
			h = 36,
			tex = res.gettex2("pic/scale/scale16.png"),
			offset = {
				-10,
				2
			}
		}
	}):addTo(x):anchor(0.5, 0.5)
end

function bag:reload()
	if def.openItemAuthPass and g_data.player.bagNeedPass and not g_data.player.passOK then
		self:showPassDialog()

		return
	end

	for k, v2 in pairs(self.items) do
		v2:removeSelf()
	end

	for _, lock in pairs(self.locks) do
		lock:removeSelf()
	end

	self.items = {}
	self.locks = {}

	for i = (self.pageIdx - 1) * number + 1, self.pageIdx * number do
		local v = g_data.bag.items[i]

		if v and not g_data.bag.inBox[v:get("makeIndex")] then
			self.items[i] = item.new(v, self, {
				showbg = false,
				showEffect = true,
				idx = i
			}):addto(self):pos(self:idx2pos(i))

			self.items[i].sprite:setName("bag_" .. v.getVar("name"))

			self.items[i].owner = "bag"

			self.items[i]:runs({
				cc.DelayTime:create(0.2),
				cc.CallFunc:create(function()
					local takeOnPosition = getTakeOnPosition(v.getVar("stdMode"))

					if takeOnPosition then
						local value = v
						local value2 = g_data.equip.items

						if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
							self.items[i].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[i]):pos(12, -12)
						end
					end
				end)
			})
		elseif def.openExtndBagCall and i > g_data.bag.max then
			self.locks[i] = an.newBtn(res.gettex2("pic/common/lock.png"), function()
				sound.playSound("103")
				an.newMsgbox("是否增加背包格子？", function(value)
					if value == 1 then
						def.role.call("@expendBox")
					end
				end, {
					center = true,
					hasCancel = true
				})
			end):add2(self):pos(self:idx2pos(i))
		end
	end
end

function bag:uptGold(gold)
	self.gold:setString(change2GoldStyle(g_data.player.gold))
end

function bag:idx2pos(idx)
	idx = idx - 1
	idx = idx - math.modf(idx / number) * number

	local h = idx % 8
	local v = math.modf(idx / 8)

	return 45 + h * 51, 392 - v * 52
end

function bag:pos2idx(x, y)
	local h = (x - 51) / 51
	local v = (392 - y) / 52
	local number2 = -1

	if h > 0 and h < 8 and v > 0 and v < 6 then
		return math.floor(v) * 8 + math.floor(h) + 1 + (self.pageIdx - 1) * number
	end

	return -1
end

function bag:getItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			return v
		end
	end
end

function bag:addItem(makeIndex)
	if def.openItemAuthPass and g_data.player.bagNeedPass and not g_data.player.passOK then
		return
	end

	local i, v = g_data.bag:getItem(makeIndex)

	if v and self.pageIdx == math.modf((i - 1) / number) + 1 then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		self.items[i] = item.new(v, self, {
			showbg = false,
			showEffect = true,
			idx = i
		}):addto(self):pos(self:idx2pos(i))

		self.items[i].sprite:setName("bag_" .. v.getVar("name"))

		self.items[i].owner = "bag"

		self.items[i]:runs({
			cc.DelayTime:create(0.2),
			cc.CallFunc:create(function()
				local takeOnPosition = getTakeOnPosition(v.getVar("stdMode"))

				if takeOnPosition then
					local value = v
					local value2 = g_data.equip.items

					if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
						self.items[i].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[i]):pos(12, -12)
					end
				end
			end)
		})
	end
end

function bag:delItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end
end

function bag:uptItem(makeIndex)
	local i, v = g_data.bag:getItem(makeIndex)

	if v and self.items[i] then
		self.items[i].data = v
	end
end

function bag:putItem(item2, x, y)
	if def.openItemAuthPass and g_data.player.bagNeedPass and not g_data.player.passOK then
		return
	end

	local form = item2.formPanel.__cname

	if form == "equip" then
		item2:takeOff()
	elseif form == "bag" then
		if g_data.hero and g_data.hero.roleid > 0 and cc.pGetDistance(cc.p(x, y), cc.p(480, 35)) <= 60 then
			if not g_data.client.heroPutInItem then
				local value = item2.data

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:delItem(value:get("makeIndex"))
				end

				g_data.bag:delItem(value:get("makeIndex"))
				g_data.client:setHeroPutInItem(value)

				local recog = value:get("makeIndex")

				net.send({
					CM_HERO_TOHEROBAG,
					recog = recog
				}, {
					value.getVar("name")
				})
				main_scene.ui:fadeLabel("放入英雄背包")
			end
		else
			local putIdx = self:pos2idx(x / self:getScale(), y / self:getScale())

			if def.openExtndBagCall and putIdx > g_data.bag.max then
				an.newMsgbox("此处为锁定区域，无法存放物品", function(value)
					return
				end, {
					center = true,
					hasCancel = false
				})

				return
			end

			if putIdx == -1 or item2.params.idx == putIdx then
				return
			end

			local srcIdx = item2.params.idx

			if g_data.bag:isAallCanPileUp(srcIdx, putIdx) then
				local item1 = self.items[putIdx].data
				local makeIndex2 = self.items[srcIdx].data:get("makeIndex")

				if item1.isNeedResetPos(self.items[srcIdx].data) then
					self.items[putIdx]:pos(self:idx2pos(putIdx))
					self.items[srcIdx]:pos(self:idx2pos(srcIdx))
				end

				net.send({
					CM_PILEUPITEM,
					series = 0,
					recog = item1:get("makeIndex"),
					param = Loword(makeIndex2),
					tag = Hiword(makeIndex2)
				})
				g_data.player:setIsinPileUping(true)
			else
				item2.params.idx = putIdx

				item2:pos(self:idx2pos(putIdx))

				local target = self.items[putIdx]

				if target then
					target.params.idx = srcIdx

					target:pos(self:idx2pos(srcIdx))
				end

				self.items[putIdx] = item2
				self.items[srcIdx] = target

				g_data.bag:changePos(srcIdx, putIdx)
			end
		end

		return true
	elseif form == "customPanel" then
		item2.formPanel:delItem(item2.boxLayer)
	elseif form == "npc" then
		item2.formPanel:delSellItem()
	elseif form == "deal" then
		an.newMsgbox("交易的物品不可以取回，要取回物品请取消再重新交易！！！")
	elseif form == "storage" or form == "heroBag" then
		item2.formPanel:getBackItem(item2)
	elseif form == "stall" then
		item2.formPanel:getBackItem(item2)
	elseif form == "ybdeal" then
		item2.formPanel:getBackItem(item2)
	elseif form == "fusion" then
		item2.formPanel:getBackItem(item2)
	elseif form == "strengthen" then
		item2.formPanel:getBackItem(item2)
	end
end

function bag:duraChange(makeindex)
	for k, v in pairs(self.items) do
		if makeindex == v.data:get("makeIndex") then
			v:duraChange()

			return
		end
	end
end

function bag:setScaleMul(num)
	return
end

function bag:cm_ext()
	def.role.call("@bagExtend")
end

function bag:genExtend(value)
	cc2.ms({
		function()
			extendUI.create(self, value, "bag_ext")
		end
	})
end

return bag
