local common = import("..common.common")
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local mail = class("mail", function()
	return display.newNode()
end)

table.merge(mail, {
	container = {}
})

local function getStateStr(mailState, attachState)
	local str = "未读"

	if mailState ~= 1 then
		str = attachState == 1 and "已读" or attachState == 2 and "已领" or "空"
	end

	return str
end

local function getStateColor(mailState, attachState)
	local color = display.COLOR_RED

	if mailState ~= 1 then
		if attachState == 1 then
			color = display.COLOR_GREEN
		elseif attachState == 2 then
			color = cc.c3b(100, 100, 100)
		else
			color = cc.c3b(100, 100, 100)
		end
	end

	return color
end

function mail:operatorMail(action, id)
	if action == "list" then
		net.send({
			CM_FETCH_MAIL_LIST,
			param = self.tag
		})
	elseif action == "get" then
		net.send({
			CM_FETCH_MAIL_INFO,
			recog = id,
			param = self.tag
		})
	elseif action == "attach" then
		g_data.client:setLastMail(id)
		net.send({
			CM_FETCH_ATTACH,
			recog = id,
			param = self.tag
		})
	elseif action == "attachOfftm" then
		net.send({
			CM_FETCH_ATTACH_OFFTM,
			recog = id,
			param = self.tag
		})
	elseif action == "del" then
		g_data.client:setLastMail(id)
		net.send({
			CM_DEL_MAIL,
			recog = id,
			param = self.tag
		})
	elseif action == "clear" then
		net.send({
			CM_CLEAR_ALLMAIL,
			param = self.tag
		})
	end
end

function mail:startAuto()
	if self.auto and self.tag == g_data.mail:cfg().sell then
		local find

		for i, v in ipairs(g_data.mail.sell) do
			if v.attachState == 1 then
				self:operatorMail("get", v.id)

				find = true

				break
			end
		end

		self.auto = find
	end
end

function mail:stopAuto()
	self.auto = false
end

function mail:ctor(params)
	self._supportMove = true
	params = params or {}
	params.tag = g_data.mail:tag2Var(params.tag)

	local bg = res.get2("pic/common/black_0.png"):addTo(self):anchor(0, 0)

	self:size(bg:getContentSize()):anchor(0.5, 0.5):center()
	res.get2("pic/panels/mail/title.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 10):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg:getw() - 5, bg:geth() - 9):anchor(1, 1)

	local cfg = g_data.mail:cfg()
	local sprs = {
		"pic/panels/mail/tab_sys.png",
		"pic/panels/mail/tab_sell.png",
		"pic/panels/mail/tab_stall.png",
		"pic/panels/mail/tab_msg.png"
	}

	self.tabs = common.tabs(bg, {
		sprs = sprs
	}, function(idx, btn)
		self:stopAuto()

		self.tag = btn.data

		self:operatorMail("list")
	end, {
		tabTp = 2,
		repeatClk = true,
		pos = {
			offset = 50,
			x = 18,
			y = self:geth() - 85,
			anchor = cc.p(0, 0.5)
		},
		datas = {
			cfg.sys,
			cfg.sell,
			cfg.offtm,
			cfg.msg
		}
	})

	for i, v in ipairs(self.tabs.btns) do
		if v.data == params.tag then
			self.tabs.click(v)

			break
		end
	end

	main_scene.ui.notice:removeMailCnt()
end

function mail:refresh()
	for i, v in ipairs(self.tabs.btns) do
		if v.data == self.tag then
			self.tabs.click(v)

			break
		end
	end
end

function mail:newLayer()
	self.container = {}

	if self.layer then
		self.layer:removeSelf()
	end

	self.layer = display.newNode():addTo(self)

	return self.layer
end

function mail:showContentByTag(tag)
	local layer = self:newLayer()
	local cfg = g_data.mail:cfg()
	local msgs = {
		{
			tag = "sys",
			str = "当前暂无系统邮件。"
		},
		{
			tag = "sell",
			str = "当前暂无物品售卖信息。"
		},
		{
			tag = "offtm",
			str = "当前暂无摊位退回物品。"
		},
		{
			tag = "msg",
			str = "当前暂无玩家留言。"
		}
	}

	for i = 1, #msgs do
		if tag == cfg[msgs[i].tag] then
			if table.nums(g_data.mail[msgs[i].tag]) == 0 then
				an.newLabel(msgs[i].str, 24, 1, {
					color = def.colors.labelGray
				}):addTo(layer):pos(380, 235):anchor(0.5, 0.5)
			else
				self[msgs[i].tag .. "MailShow"](self)
			end
		end
	end
end

function mail:sysMailShow()
	local layer = self.layer
	local scroll = an.newScroll(142, 68, 483, 334):addTo(layer):anchor(0, 0)
	local w = 484
	local h = 60
	local value
	local value2
	local value3

	for i = 1, #g_data.mail.sys do
		local data = setmetatable({}, {
			__index = g_data.mail.sys[i]
		})
		local y = 334 - (i - 1) * h - h / 2
		local node = display.newScale9Sprite(res.getframe2("pic/scale/scale" .. (i % 2 == 1 and 18 or 19) .. ".png"), 0, 0, cc.size(w, h)):addTo(scroll):pos(0, y):anchor(0, 0.5)

		node.data = data

		self:extendNode(node, "sys")
		an.newLabel(data.title, 20, 1, {
			color = def.colors.labelGray
		}):addTo(node):pos(15, h / 2):anchor(0, 0.5)
		an.newLabel(os.date("%Y-%m-%d", data.time), 20, 1, {
			color = def.colors.labelGray
		}):addTo(node):pos(195, h / 2):anchor(0, 0.5)
		an.newLabel(os.date("%X", data.time), 20, 1, {
			color = def.colors.labelGray
		}):addTo(node):pos(320, h / 2):anchor(0, 0.5)

		local str = getStateStr(data.mailState, data.attachState)
		local color = getStateColor(data.mailState, data.attachState)

		an.newLabel(str, 20, 1, {
			color = color
		}):addTo(node):pos(420, h / 2):anchor(0, 0.5)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		self:operatorMail("clear")
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mail/clear.png")
	}):addTo(layer):pos(565, 38)
end

function mail:sellMailShow()
	local layer = self.layer
	local scroll = an.newScroll(142, 68, 483, 334):addTo(layer):anchor(0, 0)
	local w = 483
	local h = 60
	local value
	local value2
	local value3

	for i = 1, #g_data.mail.sell do
		local data = setmetatable({}, {
			__index = g_data.mail.sell[i]
		})
		local y = 334 - (i - 1) * h - h / 2
		local node = display.newScale9Sprite(res.getframe2("pic/scale/scale" .. (i % 2 == 1 and 18 or 19) .. ".png"), 0, 0, cc.size(w, h)):addTo(scroll):pos(0, y):anchor(0, 0.5)

		node.data = data

		self:extendNode(node, "sell")
		self:addMail2Container(node)
		an.newLabel(os.date("%Y-%m-%d", data.time), 20, 1, {
			color = def.colors.labelGray
		}):addTo(node):pos(75, 42):anchor(0.5, 0.5)
		an.newLabel(os.date("%X", data.time), 20, 1, {
			color = def.colors.labelGray
		}):addTo(node):pos(75, 18):anchor(0.5, 0.5)

		local name = an.newLabel(data.sender, 20, 1, {
			color = cc.c3b(212, 100, 63)
		}):addTo(node):pos(155, h / 2):anchor(0, 0.5)

		an.newLabel("购买了", 20, 1, {
			color = display.COLOR_WHITE
		}):addTo(node):pos(160 + name:getw(), h / 2):anchor(0, 0.5)

		local itembg = res.get2("pic/common/itembg3.png"):addTo(node):pos(400, h / 2):anchor(0.5, 0.5)

		item.new(data.itemEx, self, {
			showbg = false,
			showEffect = true,
			donotMove = true
		}):addTo(itembg):pos(itembg:centerPos()):anchor(0.5, 0.5)

		local str = getStateStr(data.mailState, data.attachState)
		local color = getStateColor(data.mailState, data.attachState)

		node.stateStr = an.newLabel(str, 20, 1, {
			color = color
		}):addTo(node):pos(430, h / 2):anchor(0, 0.5)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		self:operatorMail("clear")
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mail/clear.png")
	}):addTo(layer):pos(565, 38)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function()
		self.auto = true

		self:startAuto()
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mail/getall.png")
	}):addTo(layer):pos(445, 38)
end

function mail:offtmMailShow()
	local layer = self.layer
	local bg = display.newNode():size(483, 334):addTo(layer):pos(142, self:geth() - 54):anchor(0, 1)
	local data = g_data.mail.offtm[1]
	local sw = 11
	local sh = 16
	local value
	local value2

	for j = 1, 4 do
		for i = 1, 5 do
			local w = bg:getw() / 2 - 2 * sw - 117.5 + (i - 1) * (47 + sw)
			local h = bg:geth() - 22 - (j - 1) * (47 + sh)
			local itembg = res.get2("pic/common/itembg3.png"):addTo(bg):pos(w, h):anchor(0, 1)

			if data.items and data.items[(j - 1) * 5 + i] then
				item.new(data.items[(j - 1) * 5 + i], self, {
					showbg = false,
					showEffect = true,
					donotMove = true
				}):addTo(itembg):pos(itembg:centerPos()):anchor(0.5, 0.5)
			end
		end
	end

	res.get2("pic/panels/mail/line.png"):addTo(bg):pos(bg:getw() / 2, 65):anchor(0.5, 0.5)
	an.newLabel("您的摊位已过期,物品已退回", 20, 1):addTo(bg):pos(bg:getw() / 2, 35):anchor(0.5, 0.5)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function(btn)
		sound.playSound("103")

		if data.id then
			self:operatorMail("attachOfftm", data.id)
		else
			main_scene.ui:fadeLabel("没有过期摊位物品.")
		end
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/mail/getall.png")
	}):addTo(layer):pos(575, 35):anchor(0.5, 0.5)
end

function mail:msgMailShow()
	local layer = self.layer
	local scroll = an.newScroll(142, 68, 483, 334):addTo(layer):anchor(0, 0)
	local w = 483
	local h = 80
	local value
	local value2
	local value3
	local value4

	for i = 1, #g_data.mail.msg do
		local data = g_data.mail.msg[i]
		local y = 334 - (i - 1) * h - h / 2
		local node = display.newScale9Sprite(res.getframe2("pic/scale/scale" .. (i % 2 == 1 and 18 or 19) .. ".png"), 0, 0, cc.size(w, h)):addTo(scroll):pos(0, y):anchor(0, 0.5)
		local sx = 15
		local label = sx + an.newLabel(data.name, 20, 1, {
			color = cc.c3b(212, 100, 63)
		}):addTo(node):pos(sx, 65):anchor(0, 0.5):enableClick(function()
			common.changeChatStyle({
				{
					"target",
					data.name
				},
				{
					"channel",
					"私聊"
				}
			})
		end):getw() + 2
		local label2 = label + an.newLabel("在", 20, 1):addTo(node):pos(label, 65):anchor(0, 0.5):getw() + 2
		local label3 = label2 + an.newLabel(os.date("%Y-%m-%d", TDateTimeToUnixDate(data.time)), 20, 1, {
			color = cc.c3b(212, 100, 63)
		}):addTo(node):pos(label2, 65):anchor(0, 0.5):getw() + 2

		lable = an.newLabel("给你留言:", 20, 1):addTo(node):pos(label3, 65):anchor(0, 0.5)

		an.newLabelM(450, 20, 1):addTo(node):pos(15, 52):anchor(0, 1):nextLine():addLabel(data.msg)
	end
end

function mail:showMail(id, from)
	if from == "sys" then
		self:sysMail(id)
	elseif from == "sell" then
		self:sellMail(id)
	else
		p2("error", "[Sys mail] function showMail: Invalid mail id, the mail from is unknow !")
	end
end

function mail:delMail(id, from)
	if from == "sell" then
		self:delMailFromContainer(id)
	else
		p2("error", "[Sys mail] function delMail: Invalid mail id, the mail from is unknow !")
	end
end

function mail:sysMail(id)
	if not id then
		main_scene.ui:fadeLabel("已经是最后一封邮件.")
		self:operatorMail("list")

		return
	end

	local data = g_data.mail.infos.sys[id]

	if not data then
		self:operatorMail("get", id)

		return
	end

	local layer = self:newLayer()
	local bg = display.newNode():size(483, 334):addTo(layer):pos(142, self:geth() - 53):anchor(0, 1)

	res.get2("pic/panels/mail/line.png"):addTo(bg):pos(bg:getw() / 2, 140):anchor(0.5, 0.5)
	an.newLabel(data.title, 20, 1):addTo(bg):pos(bg:getw() / 2, bg:geth() - 15):anchor(0.5, 0.5)
	an.newLabelM(460, 20, 1):addTo(bg):pos(15, bg:geth() - 30):anchor(0, 1):nextLine():addLabel(data.context)

	local items = {}

	for i = 1, 6 do
		items[#items + 1] = res.get2("pic/common/itembg3.png"):addTo(bg):pos(i <= 3 and bg:getw() / 2 - 5 - (3 - i) * 57 or bg:getw() / 2 + 5 + (i - 4) * 57, 100):anchor(i <= 3 and 1 or 0, 0.5)
	end

	if data.attachState == 1 then
		for i2 = 1, #data.items do
			item.new(data.items[i2], self, {
				showbg = false,
				showEffect = true,
				donotMove = true
			}):addTo(items[i2]):pos(items[i2]:centerPos()):anchor(0.5, 0.5)
		end

		if data.gold > 0 or data.yb > 0 then
			res.get2("pic/console/infobar/" .. (data.gold > 0 and "gold" or "yb") .. ".png"):addTo(bg):pos(160, 35):anchor(0.5, 0.5)
			an.newLabel(data.gold > 0 and data.gold or data.yb .. "", 20, 1, {
				color = def.colors.labelGray
			}):addTo(bg):pos(183, 35):anchor(0, 0.5)
		end
	end

	local imgs = {
		"pic/panels/mail/return.png",
		"pic/panels/mail/getall.png",
		"pic/panels/mail/delete.png"
	}

	for i3 = 1, #imgs do
		an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			sound.playSound("103")

			if i3 == 1 then
				self:operatorMail("list")
			elseif i3 == 2 then
				if data.attachState ~= 1 then
					main_scene.ui:fadeLabel("没有奖励可以领取.")
				else
					self:operatorMail("attach", id)
				end
			elseif data.attachState == 1 then
				an.newMsgbox("还有未领取的附件,删除后无法恢复。\n确认是否删除邮件?", function(idx)
					if idx == 1 then
						self:operatorMail("del", id)
					end
				end, {
					center = true,
					hasCancel = true
				})
			else
				self:operatorMail("del", id)
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2(imgs[i3])
		}):addTo(layer):pos(350 + (i3 - 1) * 110, 35):anchor(0.5, 0.5)
	end
end

function mail:sellMail(id)
	for _, v in ipairs(self.container) do
		if v.show then
			self:hideSellInfo(v)
		end
	end

	for _2, v2 in ipairs(self.container) do
		if id == v2.data.id then
			self:showSellInfo(v2)

			break
		end
	end
end

function mail:showSellInfo(node)
	local data = g_data.mail.infos.sell[node.data.id]

	if not data then
		p2("assert", "Can not get data from mail info, mail id:", node.data.id)

		return
	else
		node.stateStr:setText(getStateStr(data.mailState, data.attachState))
		node.stateStr:setColor(getStateColor(data.mailState, data.attachState))

		local value
		local info = display.newScale9Sprite(res.getframe2("pic/scale/scale26.png"), 2, 0):addTo(node):anchor(0, 1)

		node.info = info

		if data.attachState == 1 and (data.gold > 0 or data.yb > 0) then
			local icon = res.get2("pic/console/infobar/" .. (data.gold > 0 and "gold" or "yb") .. ".png"):addTo(info):pos(20, 30):anchor(0, 0.5)

			an.newLabel(data.gold > 0 and data.gold or data.yb .. "", 20, 1):addTo(info):pos(25 + icon:getw(), 30):anchor(0, 0.5)
			an.newBtn(res.gettex2("pic/common/btn20.png"), function()
				self:operatorMail("attach", data.id)
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				sprite = res.gettex2("pic/panels/mail/get.png")
			}):addTo(info):pos(300, 30):anchor(0.5, 0.5)

			if self.auto then
				self:operatorMail("attach", data.id)
			end
		elseif self.auto then
			self:startAuto()
		end

		local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function()
			if data.attachState == 1 then
				an.newMsgbox("还有未领取的附件,删除后无法恢复,\n确认是否删除邮件?", function(idx)
					if idx == 1 then
						self:operatorMail("del", data.id)
					end
				end, {
					center = true,
					hasCancel = true
				})
			else
				self:operatorMail("del", data.id)
			end
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/panels/mail/delete.png")
		}):addTo(info):pos(420, 30):anchor(0.5, 0.5)
		local positionY = btn:getPositionY() + btn:geth() / 2 + 5
		local h = positionY + an.newLabelM(node:getw() - 40, 20, 1):addTo(info):pos(20, positionY):anchor(0, 0):nextLine():addLabel(data.context):geth() + 5

		for i = self:idxOfNode(node) + 1, #self.container do
			local v = self.container[i]

			v:setPositionY(v:getPositionY() - h)
		end

		info:size(node:getw() - 4, h)

		node.state = true
	end
end

function mail:hideSellInfo(node)
	local h

	if node and node.info then
		h = node.info:geth()

		node.info:removeSelf()

		node.info = nil
	else
		return
	end

	for i = self:idxOfNode(node) + 1, #self.container do
		local v = self.container[i]

		v:setPositionY(v:getPositionY() + h)
	end

	node.state = false
end

function mail:extendNode(node, type)
	node:setTouchEnabled(true)
	node:setTouchSwallowEnabled(false)

	local y
	local move

	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			node.select = display.newScale9Sprite(res.getframe2("pic/scale/scale17.png"), 0, 0, cc.size(node:getw(), node:geth())):anchor(0, 0):addTo(node)
			y = event.y
			move = false

			return true
		elseif event.name == "moved" then
			if math.abs(y - event.y) > 10 then
				move = true

				if node.select then
					node.select:removeSelf()

					node.select = nil
				end
			end
		elseif event.name == "ended" then
			if not move then
				if type == "sys" then
					if g_data.mail.infos.sys[node.data.id] then
						self:showMail(node.data.id, type)
					else
						self:operatorMail("get", node.data.id)
					end
				elseif node.state then
					self:hideSellInfo(node)
				elseif g_data.mail.infos.sell[node.data.id] then
					self:showMail(node.data.id, type)
				else
					self:operatorMail("get", node.data.id)
				end
			end

			if node.select then
				node.select:removeSelf()

				node.select = nil
			end

			y = nil
			move = false
		end
	end)
end

function mail:addMail2Container(node)
	self.container[#self.container + 1] = node
end

function mail:delMailFromContainer(id)
	local h
	local idx

	for i, v in ipairs(self.container) do
		if id == v.data.id then
			idx = i
			h = v:geth()

			if v.state then
				h = h + v.info:geth()
			end

			v:removeSelf()
			table.remove(self.container, i)

			break
		end
	end

	if idx then
		if #self.container > 0 then
			for i2 = idx, #self.container do
				local v2 = self.container[i2]

				v2:setPositionY(v2:getPositionY() + h)
			end
		else
			self:refresh()
		end
	end
end

function mail:idxOfNode(node)
	for i, v in ipairs(self.container) do
		if v == node then
			return i
		end
	end
end

function mail:nodeOfidx(idx)
	return
end

return mail
