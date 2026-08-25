local top = class("top", function ()
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
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg:getw() - 9, bg:geth() - 8):anchor(1, 1)

	local sprs = nil

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
	}, function (idx, btn)
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

	common.tabs(self.tag1Node, {
		sprs = sprs
	}, function (idx, btn)
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
			"等级"
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
			"英雄名",
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
		sortType = msg.tag
		orderType = msg.param
		pageCount = msg.series
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
			local tmpLabel = nil

			if sortType == 2 then
				local bufSize = getRecordSize("TXinfaNormalOrderItem")
				local listSize = bufLen / bufSize
				local h = 42
				local item = nil
				local items = {}

				for i = 1, listSize do
					item, buf, bufLen = net.record("TXinfaNormalOrderItem", buf, bufLen)

					if item:get("value") > 0 then
						items[#items + 1] = item
					end
				end

				listSize = #items

				print(listSize)
				infoView:setScrollSize(492, math.max(300, listSize * h))
				infoView:enableTouch(false)
				infoView:enableClick(function ()
				end)

				for i, v in ipairs(items) do
					if tmpPlayerName == v:get("charName") then
						minePos = i
					end

					if tmpPlayerName ~= v:get("charName") or not {
						color = cc.c3b(255, 0, 0)
					} then
						local tmpColor = {
							color = def.colors.labelGray
						}
					end

					local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i * h):add2(infoView)

					an.newLabel(page * 7 + i, 18, 1, tmpColor):anchor(0.5, 0.5):pos(81, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("charName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(242, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("value"), 18, 1, tmpColor):anchor(0, 0.5):pos(390, cell:geth() * 0.5):add2(cell)

					local xinfa = v:get("xinfaLv")

					if xinfa > 0 then
						an.newLabel("+" .. v:get("xinfaLv"), 18, 1, {
							color = cc.c3b(255, 255, 0)
						}):anchor(0, 0.5):pos(430, cell:geth() * 0.5):add2(cell)
					end
				end
			end
		end

		if orderType >= 4 and orderType <= 7 then
			local tmpPlayerName = common.getPlayerName()
			local tmpLabel = nil

			if sortType == 2 then
				local bufSize = getRecordSize("TXFHeroOrderItem")
				local listSize = bufLen / bufSize
				local h = 42
				local item = nil
				local items = {}

				for i = 1, listSize do
					item, buf, bufLen = net.record("TXFHeroOrderItem", buf, bufLen)

					if item:get("level") > 0 then
						items[#items + 1] = item
					end
				end

				listSize = #items

				print(listSize)
				infoView:setScrollSize(492, math.max(300, listSize * h))
				infoView:enableTouch(false)
				infoView:enableClick(function ()
				end)

				for i, v in ipairs(items) do
					if tmpPlayerName ~= v:get("masterName") or not {
						color = cc.c3b(255, 0, 0)
					} then
						local tmpColor = {
							color = def.colors.labelGray
						}
					end

					if tmpPlayerName == v:get("charName") then
						minePos = i
					end

					local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i * h):add2(infoView)

					an.newLabel(page * 7 + i, 18, 1, tmpColor):anchor(0.5, 0.5):pos(36, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("masterName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(152, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("heroName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(312, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("level"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(442, cell:geth() * 0.5):add2(cell)
				end
			end
		end

		if orderType == 8 then
			local tmpPlayerName = common.getPlayerName()
			local tmpLabel = nil

			if sortType == 2 then
				local bufSize = getRecordSize("TXinfaNormalOrderItem")
				local listSize = bufLen / bufSize
				local h = 42
				local item = nil
				local items = {}

				for i = 1, listSize do
					item, buf, bufLen = net.record("TXinfaNormalOrderItem", buf, bufLen)

					if item:get("value") > 0 then
						items[#items + 1] = item
					end
				end

				listSize = #items

				print(listSize)
				infoView:setScrollSize(492, math.max(300, listSize * h))
				infoView:enableTouch(false)
				infoView:enableClick(function ()
				end)

				for i, v in ipairs(items) do
					if tmpPlayerName ~= v:get("charName") or not {
						color = cc.c3b(255, 0, 0)
					} then
						local tmpColor = {
							color = def.colors.labelGray
						}
					end

					if tmpPlayerName == v:get("charName") then
						minePos = i
					end

					local cell = display.newScale9Sprite(res.getframe2(i % 2 == 0 and "pic/scale/scale18.png" or "pic/scale/scale19.png"), 0, 0, cc.size(530, h)):anchor(0, 0):pos(0, infoView:getScrollSize().height - i * h):add2(infoView)

					an.newLabel(page * 7 + i, 18, 1, tmpColor):anchor(0.5, 0.5):pos(81, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("charName"), 18, 1, tmpColor):anchor(0.5, 0.5):pos(242, cell:geth() * 0.5):add2(cell)
					an.newLabel(v:get("value"), 18, 1, tmpColor):anchor(0, 0.5):pos(390, cell:geth() * 0.5):add2(cell)
				end
			end
		end
	else
		an.newLabel("你没有上榜或不在该榜", 22, 1, def.colors.labelGray):anchor(0.5, 0.5):pos(infoView:getw() / 2, infoView:geth() * 0.5):add2(infoView)
	end

	local tmpDixY = minePos

	if minePos > 7 then
		infoView:setScrollOffset(0, (tmpDixY - 7) * 42)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:query(0, orderType)
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/sy.png")
	}):pos(self:getw() + 34 - 400, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if page ~= -1 and page > 0 then
			self:query(page - 1, orderType)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/syy.png")
	}):pos(self:getw() + 34 - 300, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")

		if page < 200 then
			self:query(page + 1, orderType)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/guild/xyy.png")
	}):pos(self:getw() + 34 - 200, 38):addto(self.tag2Node)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
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
		main_scene.ui:tip("你操作太快了, 请稍候再试.")
	end
end

return top
