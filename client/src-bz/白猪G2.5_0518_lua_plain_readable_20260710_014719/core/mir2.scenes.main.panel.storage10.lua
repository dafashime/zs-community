local item = import("..common.item")
local common = import("..common.common")
local cc2 = require("mir2.cc")
local storage = class("storage", function()
	return display.newNode()
end)

table.merge(storage, {
	merchant,
	quick,
	tabs,
	currentTab,
	gridCnt,
	gridMax
})

function storage:ctor(merchant, count, gridCnt, buf, bufLen)
	self._scale = self:getScale()
	self._supportMove = true

	self:setNodeEventEnabled(true)

	self.merchant = merchant
	self.quick = false
	self.gridMax = 48

	local value_2 = res.get2("pic/panels/bag/bg_storage.png"):anchor(0, 0):addto(self, 1)

	self:anchor(1, 1):pos(display.cx - 50, display.height - 50):size(cc.size(value_2:getContentSize().width, value_2:getContentSize().height)):scale(1)
	an.newBtn(res.gettex2("pic/panels/bag/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/panels/bag/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(value_2:getw() + 10, value_2:geth()):addto(self, 2)
	an.newBtn(res.gettex2("pic/panels/bag/zlbb.png"), function()
		self.quick = not self.quick

		if self.quick then
			main_scene.ui:fadeLabel("仓库快速存取：开")
		else
			main_scene.ui:fadeLabel("仓库快速存取：关")
		end
	end, {
		manual = true,
		sprite = res.gettex2("pic/panels/storage/quick.png"),
		select = {
			res.gettex2("pic/panels/bag/zlbb2.png")
		}
	}):addTo(self, 2):pos(45, 38):anchor(0, 0.5)
	an.newBtn(res.gettex2("pic/panels/bag/zlbb.png"), function()
		sound.playSound("103")

		if g_data.client:checkLastTime("orderStorage", 1) then
			g_data.client:setLastTime("orderStorage", true)
			self:copybak()
			self:reload()
		else
			main_scene.ui:tip("点击过快")
		end
	end, {
		pressImage = res.gettex2("pic/panels/bag/zlbb2.png"),
		sprite = res.gettex2("pic/panels/bag/bz_zhenli.png")
	}):pos(350, 38):add2(self, 2)

	self.gridCnt = gridCnt
	self.items = {}
	self.itemDatas = {}
	self.itemDatasBak = {}

	for i = 1, count do
		local value
		local item2

		item2, buf, bufLen = net.record("TClientItem", buf, bufLen)
		self.itemDatasBak[#self.itemDatasBak + 1] = item2

		self:copybak()
	end

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
	}, function(idx, btn)
		self.currentTab = idx

		self:reload()
	end, {
		tabTp = 1,
		pos = {
			offset = 65,
			y = 378,
			x = self:getw() + 20,
			anchor = cc.p(1, 1)
		},
		file = {
			normal = "pic/panels/bag/bz_4.png",
			select = "pic/panels/bag/bz_3.png"
		}
	})

	if main_scene.ground.player then
		self.x = main_scene.ground.player.x
		self.y = main_scene.ground.player.y
	end

	main_scene.ui:hidePanel("npc")
	main_scene.ui:showPanel("bag")
	main_scene.ui.panels.bag:resetPanelPosition("storage")
end

function storage:copybak()
	self.itemDatas = {}

	for i, v in ipairs(self.itemDatasBak) do
		self.itemDatas[i] = v
	end
end

function storage:onCleanup()
	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:resetPanelPosition("left")
	end
end

function storage:reload()
	if def.openItemAuthPass and g_data.player.bagNeedPass and not g_data.player.passOK then
		return
	end

	for k, v in pairs(self.items) do
		v:removeSelf()
	end

	self.items = {}

	for i = 1, self.gridMax do
		local idx = i + (self.currentTab - 1) * self.gridMax
		local x, y = self:idx2pos(idx)

		if self:gridIsOpen(idx) then
			local v2 = self.itemDatas[idx]

			if v2 then
				self.items[i] = item.new(v2, self, {
					showbg = false,
					showEffect = true,
					idx = idx
				}):addto(self, 2):pos(x, y)

				self.items[i]:runs({
					cc.DelayTime:create(0.2),
					cc.CallFunc:create(function()
						local takeOnPosition = getTakeOnPosition(v2.getVar("stdMode"))

						if takeOnPosition then
							local value = v2
							local value2 = g_data.equip.items

							if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
								self.items[i].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[i], 3):pos(12, -12)
							end
						end
					end)
				})
			end
		else
			local item2 = res.get2("pic/panels/storage/icon_lock_bg.png"):addto(self, 2):pos(x, y)

			res.get2("pic/common/lock.png"):addto(item2):pos(item2:getw() / 2, item2:geth() / 2)

			item2.block = true
			self.items[i] = item2
		end
	end
end

function storage:idx2pos(idx)
	local newIdx = idx - 1 - (self.currentTab - 1) * self.gridMax
	local h = newIdx % 8
	local v = math.modf(newIdx / 8)

	return 60 + h * 51, 392 - v * 52
end

function storage:pos2idx(x, y)
	local h = (x - 51) / 51
	local v = (392 - y) / 52

	if h > 0 and h < 8 and v > 0 and v < 6 then
		return math.floor(v) * 8 + math.floor(h) + 1 + (self.currentTab - 1) * self.gridMax
	end

	return -1
end

function storage:gridIsOpen(idx)
	return idx <= self.gridCnt
end

function storage:addItem(data)
	self.itemDatasBak[#self.itemDatasBak + 1] = data

	local function add(idx)
		self.itemDatas[idx] = data

		local belongTab = math.ceil(idx / self.gridMax)

		if belongTab ~= self.currentTab then
			self.tabs.click(belongTab)
		else
			local itemidx = (idx - 1) % self.gridMax + 1

			self.items[itemidx] = item.new(data, self, {
				showbg = false,
				showEffect = true,
				idx = idx
			}):addto(self, 2):pos(self:idx2pos(idx))

			self.items[itemidx]:runs({
				cc.DelayTime:create(0.2),
				cc.CallFunc:create(function()
					local takeOnPosition = getTakeOnPosition(data.getVar("stdMode"))

					if takeOnPosition then
						local value = data
						local value2 = g_data.equip.items

						if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
							self.items[itemidx].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[itemidx], 3):pos(12, -12)
						end
					end
				end)
			})
		end
	end

	for i = 1, self.gridMax * 4 do
		if not self.itemDatas[i] then
			add(i)

			break
		end
	end
end

function storage:delItem(makeIndex)
	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end
end

function storage:findItem(idx)
	for k, v in pairs(self.items) do
		if not v.block and idx == v.params.idx then
			return v
		end
	end
end

function storage:delItemData(makeIndex)
	for k, v in pairs(self.itemDatas) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			self.itemDatas[k] = nil

			break
		end
	end

	for i, v2 in ipairs(self.itemDatasBak) do
		if v2:get("makeIndex") == tonumber(makeIndex) then
			table.remove(self.itemDatasBak, i)

			break
		end
	end
end

function storage:changePos(idx1, idx2)
	self.itemDatas[idx2] = self.itemDatas[idx1]
	self.itemDatas[idx1] = self.itemDatas[idx2]
end

function storage:duraChange(makeIndex, dura, duraMax, price)
	for k, v in pairs(self.itemDatas) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			v:set("dura", dura)
			v:set("duraMax", duraMax)

			break
		end
	end

	for k2, v2 in ipairs(self.itemDatasBak) do
		if v2:get("makeIndex") == tonumber(makeIndex) then
			v2:set("dura", dura)
			v2:set("duraMax", duraMax)

			break
		end
	end

	for k3, v3 in pairs(self.items) do
		if v3.data:get("makeIndex") == tonumber(makeIndex) then
			v3:duraChange()

			break
		end
	end
end

function storage:putInItem(item2)
	if not g_data.client.storageItem then
		local data = item2.data

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data:get("makeIndex"))
		end

		g_data.bag:delItem(data:get("makeIndex"))
		g_data.client:setStorageItem(data)

		local makeIndex = data:get("makeIndex")

		net.send({
			CM_USERSTORAGEITEM,
			recog = self.merchant,
			param = Loword(makeIndex),
			tag = Hiword(makeIndex)
		}, {
			data.getVar("name")
		})
	end
end

function storage:getBackItem(item2)
	if not g_data.client.storageGetBackItem then
		local data = item2.data

		self:delItem(data:get("makeIndex"))
		self:delItemData(data:get("makeIndex"))
		g_data.client:setStorageGetBackItem(data)

		local makeIndex = data:get("makeIndex")
		local name = data.getVar("name")

		net.send({
			CM_USERTAKEBACKSTORAGEITEM,
			recog = self.merchant,
			param = Loword(makeIndex),
			tag = Hiword(makeIndex)
		}, {
			name
		})
	end
end

function storage:putItem(item2, x, y)
	local form = item2.formPanel.__cname

	if form == "bag" then
		self:putInItem(item2)
	elseif form == "storage" then
		local putIdx = self:pos2idx(x / self:getScale(), y / self:getScale())

		if putIdx == -1 or item2.params.idx == putIdx or putIdx > self.gridMax * 4 then
			return
		end

		if not self:gridIsOpen(putIdx) then
			return
		end

		local srcIdx = item2.params.idx

		local function canPileUp(data1, data2)
			if data1 and data2 and data1.isCanPileUp(data2) then
				return true
			end

			return false
		end

		local srcItem = self:findItem(srcIdx)
		local putItem = self:findItem(putIdx)

		if putItem and canPileUp(srcItem.data, putItem.data) then
			local item1 = putItem.data
			local makeIndex2 = srcItem.data:get("makeIndex")

			if item1.isNeedResetPos(srcItem.data) then
				putItem:pos(self:idx2pos(putIdx))
				srcItem:pos(self:idx2pos(srcIdx))
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

			if putItem then
				putItem.params.idx = srcIdx

				putItem:pos(self:idx2pos(srcIdx))
			end

			local putIdx2 = (putIdx - 1) % self.gridMax + 1
			local srcIdx2 = (srcIdx - 1) % self.gridMax + 1

			self.items[putIdx2] = srcItem
			self.items[srcIdx2] = putItem

			self:changePos(srcIdx2, putIdx2)
		end

		return true
	end
end

function storage:splitNemItem(msg, buf, bufLen)
	if bufLen > 0 then
		local value
		local item2

		item2, buf, bufLen = net.record("TClientItem", buf, bufLen)

		self:addItem(item2)
	end
end

return storage
