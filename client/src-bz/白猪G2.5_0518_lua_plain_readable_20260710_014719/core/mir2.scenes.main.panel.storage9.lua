local v = require("mir2.scenes.main.panel.storage1")
local item = import("..common.item")
local common = import("..common.common")
local cc2 = require("mir2.cc")

function v:ctor(merchant, count, gridCnt, buf, bufLen)
	self._scale = self:getScale()
	self._supportMove = true

	self:setNodeEventEnabled(true)

	self.merchant = merchant
	self.quick = false
	self.gridMax = 48

	local bg = res.get2("pic/panels/bag9/bg_storage.png"):anchor(0, 0):addto(self, 1)

	self:anchor(1, 1):pos(display.cx + 5, display.height - 50):size(cc.size(bg:getContentSize().width, bg:getContentSize().height)):scale(1)
	an.newBtn(res.gettex2("pic/panels/bag9/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/panels/bag9/close11.png"),
		size = cc.size(64, 64)
	}):anchor(1, 1):pos(bg:getw() + 25, bg:geth() - 9):addto(self, 2)
	an.newBtn(res.gettex2("pic/panels/bag9/zlbb.png"), function()
		self.quick = not self.quick

		if self.quick then
			main_scene.ui:fadeLabel("仓库快速存取：开")
		else
			main_scene.ui:fadeLabel("仓库快速存取：关")
		end
	end, {
		manual = true,
		sprite = res.gettex2("pic/panels/bag9/quick.png"),
		select = {
			res.gettex2("pic/panels/bag9/zlbb2.png")
		}
	}):addTo(self, 2):pos(60, 41):anchor(0, 0.5)
	an.newBtn(res.gettex2("pic/panels/bag9/zlbb.png"), function()
		if g_data.client:checkLastTime("orderStorage", 1) then
			g_data.client:setLastTime("orderStorage", true)
			self:copybak()
			self:reload()
		else
			main_scene.ui:tip("点击过快")
		end
	end, {
		pressImage = res.gettex2("pic/panels/bag9/zlbb2.png"),
		sprite = res.gettex2("pic/panels/bag9/sort.png")
	}):pos(440, 41):add2(self, 2)

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
		"pic/panels/bag9/bz_yi.png",
		"pic/panels/bag9/bz_er.png",
		"pic/panels/bag9/bz_san.png",
		"pic/panels/bag9/bz_si.png"
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
			offset = 70,
			x = 10,
			y = 450,
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
end

function v:reload()
	if def.openItemAuthPass and g_data.player.bagNeedPass and not g_data.player.passOK then
		return
	end

	for k, v2 in pairs(self.items) do
		v2:removeSelf()
	end

	self.items = {}

	for i = 1, self.gridMax do
		local idx = i + (self.currentTab - 1) * self.gridMax
		local x, y = self:idx2pos(idx)

		if self:gridIsOpen(idx) then
			local v3 = self.itemDatas[idx]

			if v3 then
				self.items[i] = item.new(v3, self, {
					showbg = false,
					showEffect = true,
					idx = idx
				}):addto(self, 2):pos(x, y)

				self.items[i]:runs({
					cc.DelayTime:create(0.2),
					cc.CallFunc:create(function()
						local takeOnPosition = getTakeOnPosition(v3.getVar("stdMode"))

						if takeOnPosition then
							local value = v3
							local value2 = g_data.equip.items

							if cc2.superior(value, value2[takeOnPosition]) or takeOnPosition == 6 and cc2.superior(value, value2[takeOnPosition - 1]) or takeOnPosition == 7 and cc2.superior(value, value2[takeOnPosition + 1]) then
								self.items[i].superior = res.get2("pic/common/diffbetter.png"):addTo(self.items[i], 3):pos(12, -12)
							end
						end
					end)
				})
			end
		else
			local item2 = res.get2("pic/panels/bag9/icon_lock_bg.png"):addto(self, 2):pos(x, y)

			res.get2("pic/common/lock.png"):addto(item2):pos(item2:getw() / 2, item2:geth() / 2)

			item2.block = true
			self.items[i] = item2
		end
	end
end

function v:idx2pos(idx)
	local newIdx = idx - 1 - (self.currentTab - 1) * self.gridMax
	local h = newIdx % 8
	local v2 = math.modf(newIdx / 8)

	return 55 + h * 63, 420 - v2 * 65
end

function v:pos2idx(x, y)
	local h = (x - 65) / 65 + 0.5
	local v2 = (420 - y) / 60 + 0.5

	if h > 0 and h < 8 and v2 > 0 and v2 < 6 then
		return math.floor(v2) * 8 + math.floor(h) + 1 + (self.currentTab - 1) * self.gridMax
	end

	return -1
end

function v:addItem(data)
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

return v
