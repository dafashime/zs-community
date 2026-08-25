local item = import("..common.item")
local common = import("..common.common")
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

	local bg = res.get2("pic/panels/bag/bg.png"):anchor(0, 0):addto(self, 1)

	self:anchor(1, 1):pos(display.cx + 5, display.height - 50):size(cc.size(bg:getContentSize().width, bg:getContentSize().height)):scale(1)
	res.get2("pic/panels/storage/title.png"):add2(bg):pos(bg:getw() / 2, bg:geth() - 22)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(bg:getw() - 12, bg:geth() - 9):addto(self, 2)
	an.newBtn(res.gettex2("pic/common/btn10.png"), function()
		self.quick = not self.quick
	end, {
		manual = true,
		sprite = res.gettex2("pic/panels/storage/quick.png"),
		select = {
			res.gettex2("pic/common/btn11.png")
		}
	}):addTo(self, 2):pos(20, 36):anchor(0, 0.5)
	an.newBtn(res.gettex2("pic/common/btn70.png"), function()
		if g_data.client:checkLastTime("orderStorage", 1) then
			g_data.client:setLastTime("orderStorage", true)
			self:copybak()
			self:reload()
		else
			main_scene.ui:tip("你整理的太快了。")
		end
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		sprite = res.gettex2("pic/panels/storage/sort.png")
	}):pos(310, 36):add2(self, 2)

	local scaleBtn

	scaleBtn = an.newBtn(res.gettex2("pic/common/scaleBig20.png"), function()
		sound.playSound("103")
		self:stopAllActions()

		local scale = self:getScale() + 0.1

		if scale > 1.6 then
			scale = 1
		end

		self._scale = scale

		self:scaleTo(0.3, scale)
		g_data.client:setLastScale("storage", scale)
		scaleBtn.label:setString("x" .. string.format("%01d", (scale - 1) * 10 + 1))
	end, {
		pressImage = res.gettex2("pic/common/scaleBig21.png"),
		label = {
			"x" .. string.format("%01d", (self:getScale() - 1) * 10 + 1),
			20,
			1,
			{
				color = def.colors.btn40
			}
		}
	}):pos(385, 32):add2(self, 2)

	scaleBtn.label:pos(68, 30)

	self.gridCnt = gridCnt
	self.items = {}
	self.itemDatas = {}
	self.itemDatasBak = {}

	for i = 1, count do
		local item

		item, buf, bufLen = net.record("TClientItem", buf, bufLen)
		self.itemDatasBak[#self.itemDatasBak + 1] = item

		self:copybak()
	end

	local sprs = {
		"pic/panels/storage/tab_one.png",
		"pic/panels/storage/tab_two.png",
		"pic/panels/storage/tab_three.png",
		"pic/panels/storage/tab_four.png"
	}

	self.tabs = common.tabs(self, {
		oy = 10,
		sprs = sprs
	}, function(idx, btn)
		self.currentTab = idx

		self:reload()
	end, {
		tabTp = 1,
		pos = {
			x = 5,
			offset = 70,
			y = 365,
			anchor = cc.p(1, 1)
		}
	})

	if main_scene.ground.player then
		self.x = main_scene.ground.player.x
		self.y = main_scene.ground.player.y
	end

	main_scene.ui:hidePanel("npc")
	main_scene.ui:showPanel("bag")
	main_scene.ui.panels.bag:resetPanelPosition("storage")
	main_scene.ui.panels.bag:setScaleMul(1)
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
	for k, v in pairs(self.items) do
		v:removeSelf()
	end

	self.items = {}

	for i = 1, self.gridMax do
		local idx = i + (self.currentTab - 1) * self.gridMax
		local x, y = self:idx2pos(idx)

		if self:gridIsOpen(idx) then
			res.get2("pic/common/grid.png"):addTo(self, 2):pos(x, y)

			local v = self.itemDatas[idx]

			if v then
				self.items[i] = item.new(v, self, {
					idx = idx
				}):addto(self, 2):pos(x, y)
			end
		else
			local item = res.get2("pic/panels/storage/icon_lock_bg.png"):addto(self, 2):pos(x, y)

			res.get2("pic/common/lock.png"):addto(item):pos(item:getw() / 2, item:geth() / 2)

			item.block = true
			self.items[i] = item
		end
	end
end

function storage:idx2pos(idx)
	local newIdx = idx - 1 - (self.currentTab - 1) * self.gridMax
	local h = newIdx % 8
	local v = math.modf(newIdx / 8)

	return 48 + h * 46.5, 321 - v * 46.5
end

function storage:pos2idx(x, y)
	local h = (x - 48) / 46.5 + 0.5
	local v = (321 - y) / 46.5 + 0.5

	if h > 0 and h < 8 and v > 0 and v < 6 then
		return math.floor(v) * 8 + math.floor(h) + 1 + (self.currentTab - 1) * self.gridMax
	end

	return -1
end

function storage:gridIsOpen(idx)
	local open = idx <= self.gridCnt

	return open
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
				idx = idx
			}):addto(self, 2):pos(self:idx2pos(idx))
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

	for i, v in ipairs(self.itemDatasBak) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			table.remove(self.itemDatasBak, i)

			break
		end
	end
end

function storage:changePos(idx1, idx2)
	self.itemDatas[idx1], self.itemDatas[idx2] = self.itemDatas[idx2], self.itemDatas[idx1]
end

function storage:duraChange(makeIndex, dura, duraMax, price)
	for k, v in pairs(self.itemDatas) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			v:set("dura", dura)
			v:set("duraMax", duraMax)

			break
		end
	end

	for k, v in ipairs(self.itemDatasBak) do
		if v:get("makeIndex") == tonumber(makeIndex) then
			v:set("dura", dura)
			v:set("duraMax", duraMax)

			break
		end
	end

	for k, v in pairs(self.items) do
		if v.data:get("makeIndex") == tonumber(makeIndex) then
			v:duraChange()

			break
		end
	end
end

function storage:putInItem(item)
	if not g_data.client.storageItem then
		local data = item.data

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

function storage:getBackItem(item)
	if not g_data.client.storageGetBackItem then
		local data = item.data

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

function storage:putItem(item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		self:putInItem(item)
	elseif form == "storage" then
		local putIdx = self:pos2idx(x / self:getScale(), y / self:getScale())

		if putIdx == -1 or item.params.idx == putIdx or putIdx > self.gridMax * 4 then
			return
		end

		if not self:gridIsOpen(putIdx) then
			return
		end

		local srcIdx = item.params.idx

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
			item.params.idx = putIdx

			item:pos(self:idx2pos(putIdx))

			if putItem then
				putItem.params.idx = srcIdx

				putItem:pos(self:idx2pos(srcIdx))
			end

			putIdx = (putIdx - 1) % self.gridMax + 1
			srcIdx = (srcIdx - 1) % self.gridMax + 1
			self.items[putIdx] = srcItem
			self.items[srcIdx] = putItem

			self:changePos(srcIdx, putIdx)
		end

		return true
	end
end

function storage:splitNemItem(msg, buf, bufLen)
	if bufLen > 0 then
		local item

		item, buf, bufLen = net.record("TClientItem", buf, bufLen)

		self:addItem(item)
	end
end

return storage
