local top = class("top", function()
	return display.newNode()
end)
local common = import("..common.common")

table.merge(top, {
	content,
	currentpage,
	ordertype
})

local tags = {
	mafa = {
		var = 4,
		tag1 = "single"
	},
	mars = {
		var = 1,
		tag1 = "single"
	},
	fasheng = {
		var = 2,
		tag1 = "single"
	},
	respect = {
		var = 3,
		tag1 = "single"
	},
	heroall = {
		var = 8,
		tag1 = "hero"
	},
	zhanshi = {
		var = 5,
		tag1 = "hero"
	},
	fashi = {
		var = 6,
		tag1 = "hero"
	},
	daoshi = {
		var = 7,
		tag1 = "hero"
	}
}

function top:ctor(params)
	self._supportMove = true
	params = params or {}

	if type(params.tag2) ~= "string" or tag[params.tag2] then
		params.tag2 = "mafa"
	end

	params.tag1 = tags[params.tag2].tag1

	local bg = res.get2("pic/common/black_0.png"):addTo(self):anchor(0, 0)

	self:size(bg:getContentSize()):anchor(0.5, 0.5):center()
	res.get2("pic/panels/top/title.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 12):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg:getw() - 9, bg:geth() - 8):anchor(1, 1)

	local sprs

	if def.gameVersionType == "185" then
		sprs = {
			"pic/panels/top/grph.png",
			"pic/panels/top/yxph.png"
		}
	else
		sprs = {
			"pic/panels/top/grph.png"
		}
	end

	common.tabs(bg, {
		oy = 10,
		sprs = sprs
	}, function(idx, btn)
		if idx == 1 then
			self.tag1 = "single"

			self:load("mafa")
		elseif idx == 2 then
			self.tag1 = "hero"

			self:load("heroall")
		elseif idx == 3 then
			self.tag1 = "prestige"

			self:load("master")
		end
	end, {
		tabTp = 3,
		pos = {
			offset = 100,
			x = 1,
			y = bg:geth() - 38,
			anchor = cc.p(1, 1)
		}
	})
end

function top:load(tag2)
	if self.tag1Node then
		self.tag1Node:removeSelf()
	end

	self.tag1Node = display.newNode():addTo(self)

	local sprs = ({
		single = {
			"pic/panels/top/mafa.png",
			"pic/panels/top/mars.png",
			"pic/panels/top/fasheng.png",
			"pic/panels/top/respect.png"
		},
		hero = {
			"pic/panels/top/mafa.png",
			"pic/panels/top/mars.png",
			"pic/panels/top/fasheng.png",
			"pic/panels/top/respect.png"
		},
		prestige = {
			"pic/panels/top/mafa.png"
		}
	})[self.tag1]

	if def.jobMaps then
		sprs = ({
			single = {
				"pic/panels/top/mafa.png"
			},
			hero = {
				"pic/panels/top/mafa.png"
			},
			prestige = {
				"pic/panels/top/mafa.png"
			}
		})[self.tag1]
	end

	common.tabs(self.tag1Node, {
		sprs = sprs
	}, function(idx, btn)
		self.tag2 = ({
			single = {
				"mafa",
				"mars",
				"fasheng",
				"respect"
			},
			hero = {
				"heroall",
				"zhanshi",
				"fashi",
				"daoshi"
			},
			prestige = {
				"master"
			}
		})[self.tag1][idx]

		if def.jobMaps then
			self.tag2 = ({
				single = {
					"mafa"
				},
				hero = {
					"heroall"
				},
				prestige = {
					"master"
				}
			})[self.tag1][idx]
		end

		self.curSubIdx = tags[self.tag2].var - 1

		sound.playSound("103")
		self:query(0, self.curSubIdx)
	end, {
		tabTp = 2,
		pos = {
			offset = 54,
			x = 18,
			y = self:geth() - 85,
			anchor = cc.p(0, 0.5)
		}
	})
	self:processUpt(-1)
end

function top:load2(tag2)
	if self.tag1Node then
		self.tag1Node:removeSelf()
	end

	self.tag1Node = display.newNode():addTo(self)

	if self.tag2Node then
		self.tag2Node:removeSelf()
	end

	self.tag2Node = display.newNode():addTo(self)
	self.curSubIdx = nil

	display.newScale9Sprite(res.getframe2("pic/scale/scale14.png")):addto(self.tag2Node):anchor(0, 0):pos(14, 14):size(self:getw() - 28, self:geth() - 60)
end

function top:processUpt(tag2Var, msg, buf, bufLen)
	if self.tag2Node then
		self.tag2Node:removeSelf()
	end

	self.tag2Node = display.newNode():addTo(self)

	local width = {}
	local Titlelabel = {}
	local infoView = an.newScroll(143, 68, 482, 296):add2(self.tag2Node)

	if tag2Var >= 0 and tag2Var <= 3 then
		width = {
			162,
			162,
			159
		}
		Titlelabel = {
			"序位",
			"角色名",
			CS_LEVEL
		}
	elseif tag2Var >= 4 and tag2Var <= 7 then
		width = {
			72,
			160,
			160,
			91
		}
		Titlelabel = {
			"序位",
			"角色名",
			"英雄",
			"英雄等级"
		}
	elseif tag2Var == 8 then
		width = {
			162,
			162,
			159
		}
		Titlelabel = {
			"序位",
			"角色名",
			"出师玩家数"
		}
	end

	local posOffset = 142

	for i, v in ipairs(width) do
		display.newScale9Sprite(res.getframe2("pic/scale/scale15.png"), 0, 0, cc.size(v + 2, 42)):anchor(0.5, 0.5):pos(posOffset + v * 0.5, self:geth() - 72):add2(self.tag2Node)
		an.newLabel(Titlelabel[i], 20, 1, {
			color = def.colors.labelTitle
		}):anchor(0.5, 0.5):pos(posOffset + v * 0.5, self:geth() - 72):add2(self.tag2Node)

		posOffset = posOffset + v

		print(Titlelabel[i])
	end

	local sortType = 0
	local orderType = tag2Var
	local pageCount = 0
	local page = 0
	local minePos = -1
	local trueCount = 0

	if msg and buf then
		local sortType2 = msg.tag

		orderType = msg.param

		local value = msg.series

		page = msg.recog

		if page == -2 then
			if orderType >= 4 and orderType <= 7 then
				main_scene.ui.leftTopTip:show("你的英雄没有上榜或不在该榜。")
			else
				main_scene.ui.leftTopTip:show("你没有上榜或不在该榜。")
			end

			return
		end

		if page == -1 or bufLen == 0 then
			return
		end

		if orderType >= 0 and orderType <= 3 then
			local tmpPlayerName = common.getPlayerName()
			local value2

			if sortType2 == 2 then
				local listSize = bufLen / getRecordSize("TXinfaNormalOrderItem")
				local h = 42
				local value3
				local items = {}

				for i2 = 1, listSize do
					local item

					item, buf, bufLen = net.record("TXinfaNormalOrderItem", buf, bufLen)

					if item:get("value") > 0 then
						items[#items + 1] = item
					end
				end

				local listSize2 = #items

				print(listSize2)
				infoView:setScrollSize(492, math.max(300, listSize2 * h))
				infoView:enableTouch(false)
				infoView:enableClick(function()
					return
				end)

				for i3, v2 in ipairs(items) do
					if tmpPlayerName == v2:get("charName") then
						minePos = i3
					end

					if tmpPlayerName ~= v2:get("charName") or not {
						color = cc.c3b(255, 0, 0)
					} then
						({}).color = def.colors.labelGray
					end

					local cell = display.newScale9Sprite(res.getframe2(i3 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i3 * h):add2(infoView)

					an.newLabel(page * 7 + i3, 18, 1, tmpColor):anchor(0.5, 0.5):pos(81, cell:geth() * 0.5):add2(cell)
					an.newLabel(v2:get("charName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(242, cell:geth() * 0.5):add2(cell)
					an.newLabel(v2:get("value"), 18, 1, tmpColor):anchor(0, 0.5):pos(390, cell:geth() * 0.5):add2(cell)

					if v2:get("xinfaLv") > 0 then
						an.newLabel("+" .. v2:get("xinfaLv"), 18, 1, {
							color = cc.c3b(255, 255, 0)
						}):anchor(0, 0.5):pos(430, cell:geth() * 0.5):add2(cell)
					end
				end
			end
		end

		if orderType >= 4 and orderType <= 7 then
			local tmpPlayerName2 = common.getPlayerName()
			local value4

			if sortType2 == 2 then
				local listSize3 = bufLen / getRecordSize("TXFHeroOrderItem")
				local h2 = 42
				local value5
				local items2 = {}

				for i4 = 1, listSize3 do
					local item2

					item2, buf, bufLen = net.record("TXFHeroOrderItem", buf, bufLen)

					if item2:get("level") > 0 then
						items2[#items2 + 1] = item2
					end
				end

				local listSize4 = #items2

				print(listSize4)
				infoView:setScrollSize(492, math.max(300, listSize4 * h2))
				infoView:enableTouch(false)
				infoView:enableClick(function()
					return
				end)

				for i5, v3 in ipairs(items2) do
					if tmpPlayerName2 ~= v3:get("masterName") or not {
						color = cc.c3b(255, 0, 0)
					} then
						({}).color = def.colors.labelGray
					end

					if tmpPlayerName2 == v3:get("charName") then
						minePos = i5
					end

					local cell2 = display.newScale9Sprite(res.getframe2(i5 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h2)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i5 * h2):add2(infoView)

					an.newLabel(page * 7 + i5, 18, 1, tmpColor):anchor(0.5, 0.5):pos(36, cell2:geth() * 0.5):add2(cell2)
					an.newLabel(v3:get("masterName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(152, cell2:geth() * 0.5):add2(cell2)
					an.newLabel(v3:get("heroName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(312, cell2:geth() * 0.5):add2(cell2)
					an.newLabel(v3:get("level"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(442, cell2:geth() * 0.5):add2(cell2)
				end
			end
		end

		if orderType == 8 then
			local tmpPlayerName3 = common.getPlayerName()
			local value6

			if sortType2 == 2 then
				local listSize5 = bufLen / getRecordSize("TXinfaNormalOrderItem")
				local h3 = 42
				local value7
				local items3 = {}

				for i6 = 1, listSize5 do
					local item3

					item3, buf, bufLen = net.record("TXinfaNormalOrderItem", buf, bufLen)

					if item3:get("value") > 0 then
						items3[#items3 + 1] = item3
					end
				end

				local listSize6 = #items3

				print(listSize6)
				infoView:setScrollSize(492, math.max(300, listSize6 * h3))
				infoView:enableTouch(false)
				infoView:enableClick(function()
					return
				end)

				for i7, v4 in ipairs(items3) do
					if tmpPlayerName3 ~= v4:get("charName") or not {
						color = cc.c3b(255, 0, 0)
					} then
						({}).color = def.colors.labelGray
					end

					if tmpPlayerName3 == v4:get("charName") then
						minePos = i7
					end

					local cell3 = display.newScale9Sprite(res.getframe2(i7 % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h3)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i7 * h3):add2(infoView)

					an.newLabel(page * 7 + i7, 18, 1, tmpColor):anchor(0.5, 0.5):pos(81, cell3:geth() * 0.5):add2(cell3)
					an.newLabel(v4:get("charName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(242, cell3:geth() * 0.5):add2(cell3)
					an.newLabel(v4:get("value"), 18, 1, tmpColor):anchor(0, 0.5):pos(390, cell3:geth() * 0.5):add2(cell3)
				end
			end
		end
	else
		an.newLabel("你没有上榜或不在该榜。", 22, 1, def.colors.labelGray):anchor(0.5, 0.5):pos(infoView:getw() / 2, infoView:geth() * 0.5):add2(infoView)
	end

	local tmpDixY = minePos

	if minePos > 7 then
		infoView:setScrollOffset(0, (tmpDixY - 7) * 42)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")
		self:query(0, orderType)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/sy.png")
	}):pos(self:getw() + 34 - 400, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if page ~= -1 and page > 0 then
			self:query(page - 1, orderType)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):pos(self:getw() + 34 - 300, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")

		if page < 200 then
			self:query(page + 1, orderType)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):pos(self:getw() + 34 - 200, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		sound.playSound("103")
		self:query(-1, orderType)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/top/wdpm.png")
	}):pos(self:getw() + 34 - 100, 38):addto(self.tag2Node)
end

function top:query(page, type)
	if g_data.client:checkLastTime("top", 4) then
		g_data.client:setLastTime("top", true)
		net.send({
			CM_QUEST_ORDER,
			recog = page,
			param = type
		})
	else
		main_scene.ui:tip("操作太快")
	end
end

return top
