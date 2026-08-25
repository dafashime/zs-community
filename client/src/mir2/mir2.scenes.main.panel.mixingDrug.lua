local common = import("..common.common")
local item = import("..common.item")
local mixingDrug = class("mixingDrug", function ()
	return display.newNode()
end)

table.merge(mixingDrug, {})

function mixingDrug:resetPanelPosition(type)
	if type == "center" then
		self:anchor(0.5, 0.5):center()
	end

	return self
end

function mixingDrug:ctor()
	self._supportMove = true

	self:setNodeEventEnabled(true)

	local bg = res.get2("pic/common/black_2.png"):addTo(self):pos(0, 0):anchor(0, 0)

	res.get2("pic/panels/mixingDrug/title.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 14):anchor(0.5, 1)
	self:size(cc.size(bg:getw(), bg:geth())):resetPanelPosition("center")
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):anchor(1, 1):pos(bg:getw() - 5, bg:geth() - 8)
	display.newScale9Sprite(res.getframe2("pic/scale/scale26.png")):size(127, 390):addTo(bg):pos(12, 15):anchor(0, 0)
	an.newBtn(res.gettex2("pic/common/help.png"), function ()
	end, {
		pressBig = true
	}):addTo(bg):anchor(0, 1):pos(6, bg:geth() - 8)

	local sprs = {}
	local datas = {}

	for i, v in ipairs(g_data.mixingDrug.lst) do
		local cfg = g_data.mixingDrug:getConfig(v.id)
		sprs[#sprs + 1] = "pic/panels/mixingDrug/tab_" .. cfg.resid .. ".png"
	end

	self.tabs = common.tabs(bg, {
		oy = 10,
		sprs = sprs
	}, function (idx, btn)
		self:stopHandler()

		self.idx = idx

		net.send({
			CM_MAKEDRUG_STATUS_QUERY,
			recog = btn.data.id
		})

		if btn.data.state == 0 then
			self:showDetail("learn", nil, btn.data.id)
		end
	end, {
		tabTp = 2,
		repeatClk = true,
		pos = {
			offset = 50,
			x = 18,
			y = self:geth() - 85,
			anchor = cc.p(0, 0.5)
		},
		datas = setmetatable({}, {
			__index = g_data.mixingDrug.lst
		})
	})

	for _, v in ipairs(self.tabs.btns) do
		v.text = an.newLabel("", 15, 2):addTo(v):pos(v:getw() / 2, 2):anchor(0.5, 0)
	end

	self:updateTabsLabel()
end

function mixingDrug:onCleanup()
	self:stopHandler()
end

function mixingDrug:updateTabsLabel()
	for _, v in ipairs(self.tabs.btns) do
		local str = ({
			"（未学习）",
			"（未炼制）",
			"（炼制中）",
			"（已完成）"
		})[v.data.state + 1]
		local color = ({
			def.colors.labelGray,
			def.colors.labelGray,
			def.colors.labelYellow,
			display.COLOR_GREEN
		})[v.data.state + 1]

		v.text:setString(str)
		v.text:setColor(color)
	end
end

function mixingDrug:getLayer(mask)
	if self.layer then
		self.layer:removeSelf()
	end

	self.layer = res.get2("pic/panels/mixingDrug/" .. (mask and "bg1.png" or "bg2.png")):addTo(self):pos(144, 17):anchor(0, 0)

	display.newScale9Sprite(res.getframe2("pic/scale/scale27.png")):size(480, 390):addTo(self.layer):pos(self.layer:centerPos())

	return self.layer
end

function mixingDrug:showDetail(action, data, id)
	if action ~= "learn" then
		self:updateTabsLabel()
	end

	local act = string.ucfirst(action)

	if self["showMixing" .. act] then
		self["showMixing" .. act](self, data, id)
	end
end

function mixingDrug:showDesc(str)
	local layer = self.layer
	local desc = display.newScale9Sprite(res.getframe2("pic/panels/mixingDrug/strip.png")):size(layer:getw() - 20, 70):addTo(layer):pos(layer:getw() / 2, layer:geth() - 8):anchor(0.5, 1)

	an.newLabelM(desc:getw() - 30, 20, 1):addTo(desc):pos(15, desc:geth() - 10):anchor(0, 1):nextLine():addLabel(str, cc.c3b(196, 186, 137))
end

function mixingDrug:showMixingLv(lv, curExp, maxExp)
	local layer = self.layer
	local w = 15
	local h = 5
	local label = an.newLabel("熟练度:" .. curExp .. "/" .. maxExp, 18, 1, {
		color = cc.c3b(196, 186, 137)
	}):addTo(layer):pos(w, 5):anchor(0, 0)
	h = h + label:geth() + 5

	an.newLabel("炼制等级:" .. lv, 18, 1, {
		color = cc.c3b(196, 186, 137)
	}):addTo(layer):pos(w, h):anchor(0, 0)
end

function mixingDrug:showMixingLearn(data, id)
	local cfg = g_data.mixingDrug:getConfig(id)
	local layer = self:getLayer(true)

	self:showDesc(cfg.name .. "：" .. cfg.desc)
	an.newLabel("配方未学习", 24, 1, {
		color = def.colors.labelGray
	}):addTo(layer):pos(layer:centerPos()):anchor(0.5, 0.5)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		net.send({
			CM_LEARN_LIVINGSKILL,
			recog = id
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mixingDrug/learn.png")
	}):addTo(layer):pos(layer:getw() / 2, 50)
end

function mixingDrug:showMixingBegin(data, id)
	local cfg = g_data.mixingDrug:getConfig(id)
	local layer = self:getLayer(true)
	local consumeNum = g_data.bag:getItemCount(def.items[cfg.consume].getVar("name"))
	local max = math.floor(consumeNum / cfg.input)
	local cnt = consumeNum > 0 and 1 or 0
	local price = data.price

	self:showDesc(cfg.name .. "：" .. cfg.desc)
	an.newLabel("炼制选项", 20, 2, {
		color = def.colors.labelYellow
	}):addTo(layer):pos(layer:getw() / 2, 270):anchor(0.5, 0.5)

	local itembg = res.get2("pic/panels/mixingDrug/frame.png"):addTo(layer):pos(layer:getw() / 2, 200)

	an.newLabel("材料", 18, 2, {
		color = def.colors.labelYellow
	}):addTo(itembg):pos(32, itembg:geth() + 5):anchor(0.5, 0)
	an.newLabel("成品药", 18, 2, {
		color = def.colors.labelYellow
	}):addTo(itembg):pos(itembg:getw() - 30, itembg:geth() + 5):anchor(0.5, 0)

	local time = an.newLabel(data.time * cnt .. "分钟", 18, 1):addTo(itembg):pos(itembg:getw() / 2, itembg:geth() / 2 + 9):anchor(0.5, 0)
	local gold = an.newLabel("需要金币" .. data.price * cnt, 18, 1, {
		color = cc.c3b(225, 98, 13)
	}):addTo(layer):pos(layer:getw() / 2, 65):anchor(0.5, 0)
	local lGrid = res.get2("pic/common/itembg3.png"):addTo(itembg):pos(32, itembg:geth() / 2)
	local rGrid = res.get2("pic/common/itembg3.png"):addTo(itembg):pos(itembg:getw() - 30, itembg:geth() / 2)

	item.new(def.items[cfg.consume], self, {
		donotMove = true
	}):addTo(lGrid):pos(lGrid:centerPos())
	item.new(def.items[cfg.generate], self, {
		donotMove = true
	}):addTo(rGrid):pos(rGrid:centerPos())
	an.newLabel("背包中材料可炼制" .. max .. "次", 18, 1, {
		color = cc.c3b(0, 124, 182)
	}):addTo(layer):pos(layer:getw() / 2, 150):anchor(0.5, 0.5)

	local modify, input = nil
	input = an.newInput(layer:getw() / 2, 110, 75, 40, 3, {
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale23.png")
		},
		label = {
			"" .. cnt,
			18
		},
		stop_call = function ()
			local text = input:getText()

			if text and text ~= "" and tonumber(text) and tonumber(text) <= max then
				modify(tonumber(text))
			else
				main_scene.ui:tip("输入次数有误,请重新输入")
			end
		end
	}):addTo(layer):anchor(0.5, 0.5)

	function modify(num)
		cnt = num

		input:setText(cnt .. "")
		time:setText(data.time * cnt .. "分钟")
		gold:setText("需要金币" .. data.price * cnt)
	end

	local cfg = {
		{
			select = "btn71.png",
			sprite = "pic/panels/mixingDrug/min.png",
			normal = "btn70.png",
			x = layer:getw() / 2 - 150,
			callback = function ()
				modify(math.min(1, max))
			end
		},
		{
			select = "btn71.png",
			sprite = "pic/panels/mixingDrug/max.png",
			normal = "btn70.png",
			x = layer:getw() / 2 + 150,
			callback = function ()
				modify(max)
			end
		},
		{
			select = "btn101.png",
			sprite = "pic/common/minus.png",
			normal = "btn100.png",
			x = layer:getw() / 2 - 75,
			callback = function ()
				modify(cnt == math.min(1, max) and cnt or cnt - 1)
			end
		},
		{
			select = "btn101.png",
			sprite = "pic/common/plus.png",
			normal = "btn100.png",
			x = layer:getw() / 2 + 75,
			callback = function ()
				modify(cnt == max and cnt or cnt + 1)
			end
		}
	}

	for _, v in ipairs(cfg) do
		an.newBtn(res.gettex2("pic/common/" .. v.normal), function ()
			v.callback()
		end, {
			pressImage = res.gettex2("pic/common/" .. v.select),
			sprite = res.gettex2(v.sprite)
		}):addTo(layer):pos(v.x, 110)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		if cnt > 0 then
			if g_data.player.gold < cnt * price then
				main_scene.ui:tip("金币不足")
			else
				net.send({
					CM_CAN_MAKEDRUG_QUERY,
					recog = id,
					param = cnt
				})
			end
		else
			main_scene.ui:tip("没有足够的材料")
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mixingDrug/mix.png")
	}):addTo(layer):pos(layer:getw() / 2, 35)
	self:showMixingLv(data.lv, data.curExp, data.maxExp)
end

function mixingDrug:showMixingDuring(data, id)
	local cfg = g_data.mixingDrug:getConfig(id)
	local layer = self:getLayer()

	self:showDesc(cfg.name .. "：" .. cfg.desc)
	an.newLabel("炼制" .. data.cnt .. "个材料", 18, 1, {
		color = cc.c3b(0, 173, 254)
	}):addTo(layer):pos(15, 280):anchor(0, 0.5)

	local time = an.newLabel("剩余" .. math.ceil((data.time or 1) / 60) .. "分钟", 18, 1, {
		color = cc.c3b(225, 98, 13)
	}):addTo(layer):pos(15, 250):anchor(0, 0.5)
	self.handler = scheduler.scheduleGlobal(function ()
		data.time = data.time - 1

		if data.time > 0 then
			time:setString("剩余" .. math.ceil((data.time or 1) / 60) .. "分钟")
		else
			self:stopHandler()
			self:refresh()
		end
	end, 1)

	self:showMixingLv(data.lv, data.curExp, data.maxExp)

	local frames = {}

	for i = 1, 20 do
		local frame = res.getframe2("pic/panels/mixingDrug/effect_" .. i .. ".png")
		frames[#frames + 1] = frame
	end

	local effect = res.get2("pic/panels/mixingDrug/effect_1.png"):addTo(layer):pos(layer:centerPos()):anchor(0.5, 0.5)

	effect:playAnimationForever(display.newAnimation(frames, 0.125))
end

function mixingDrug:showMixingEnded(data, id)
	local cfg = g_data.mixingDrug:getConfig(id)
	local layer = self:getLayer(true)

	self:showDesc(cfg.name .. "：" .. cfg.desc)
	self:showMixingLv(data.lv, data.curExp, data.maxExp)
	an.newLabel("炼制结果", 20, 1, {
		color = def.colors.labelYellow
	}):addTo(layer):pos(layer:getw() / 2, 285):anchor(0.5, 0.5)

	local second = false

	local function showitem(info, cnt)
		if not info then
			return
		end

		local itembg = res.get2("pic/common/itembg3.png"):addTo(layer):pos(layer:getw() / 2, second and 145 or 235)

		item.new(info, self, {
			donotMove = true
		}):addTo(itembg):pos(itembg:centerPos())
		an.newLabel(info.getVar("name") .. "x" .. cnt, 18, 1, {
			color = second and cc.c3b(225, 98, 13) or cc.c3b(0, 173, 254)
		}):addTo(layer):pos(layer:getw() / 2, second and 105 or 195):anchor(0.5, 0.5)

		second = true
	end

	local generate, fail = nil
	local g_cnt = 0
	local f_cnt = 0

	for _, v in pairs(data.items or {}) do
		if v.getVar("name") == def.items[cfg.generate].getVar("name") then
			generate = generate or v
			g_cnt = g_cnt + (v:get("dura") ~= 0 and v:get("dura") or 1)
		else
			fail = fail or v
			f_cnt = f_cnt + (v:get("dura") ~= 0 and v:get("dura") or 1)
		end
	end

	showitem(generate, g_cnt)
	showitem(fail, f_cnt)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		net.send({
			CM_GAIN_MAKEDDRUG,
			param = 0,
			recog = id
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mixingDrug/savestorage.png")
	}):addTo(layer):pos(layer:getw() / 2 - 65, 55)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		net.send({
			CM_GAIN_MAKEDDRUG,
			param = 1,
			recog = id
		})
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mixingDrug/savebag.png")
	}):addTo(layer):pos(layer:getw() / 2 + 65, 55)
end

function mixingDrug:refresh()
	self.tabs.click(self.idx)
end

function mixingDrug:stopHandler()
	if self.handler then
		scheduler.unscheduleGlobal(self.handler)

		self.handler = nil
	end
end

return mixingDrug
