local role = import(".role")
local common = import("..main.common.common")
local baseScene = import("..baseScene", ...)
local scene = class("select", baseScene)

table.merge(scene, {})

local sceneW = 800
local sceneH = 600
local dew = display.width / sceneW
local deh = display.height / sceneH
local rolePos = {
	function ()
		return 221 * dew, 230 * deh
	end,
	function ()
		return 565 * dew, 230 * deh
	end
}
local namepos = {
	function ()
		return 95 * dew, 90 * deh
	end,
	function ()
		return 645 * dew, 88 * deh
	end
}
local editPos = {
	function ()
		return 221 * dew, 375 * deh
	end,
	function ()
		return 565 * dew, 375 * deh
	end
}

local function recoveryPos()
	return 221 * dew, 375 * deh
end

local roleUpperLimit = 4

function scene:ctor()
	self.mask = nil
	self.area = nil
	self.closedMsgbox = nil
	self.entered = false
	self.roles = {}
	self.del_roles = {}
	self.del_selectIdx = nil

	if device.platform == "android" then
		self:setKeypadEnabled(true)
		self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
			if event.key == "back" then
				an.newMsgbox("确定要退出游戏吗?", function (idx)
					if idx == 1 then
						os.exit(1)
					end
				end, {
					center = true,
					hasCancel = true
				})
			end
		end)
	end

	net.setMatchMode(true)
end

function scene:onEnter()
	print("select.scene:onEnter")
	self.super.onEnter(self)
	_G.def.items.initFilt()
end

function scene:onExit()
	net.setMatchMode(false)
	print("select.scene:onExit")
	self.super.onExit(self)
end

function scene:onEnterTransitionFinish()
	print("onEnterTransitionFinish")

	local layer = display.newNode():size(sceneW, sceneH):anchor(0.5, 0.5):center():fit():addTo(self)

	if g_data.security.loginBit then
		self:showSecurity()
	end

	res.get2("pic/login/select.png"):addTo(layer):pos(layer:getw() / 2, layer:geth() / 2)

	self.area = an.newLabel(g_data.login:getSelectGroup():get("groupName"), 18, 1):anchor(0.5, 1):pos(display.cx, display.height - 3):addto(self):hide()

	local function clickBtn(i)
		sound.playSound("103")

		if self.mask and i ~= 1 and i ~= 5 then
			return
		end

		if i == 1 then
			if #g_data.select.roles == 0 then
				an.newMsgbox("你还没创建角色.", nil, {
					center = true
				})
			else
				if self.mask ~= nil then
					self.mask:removeSelf()
				else
					net.send({
						CM_SELCHR
					}, {
						g_data.select:getCurName()
					})
				end

				self.mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 0)):addto(self):runs({
					cc.FadeTo:create(0.3, 192),
					cc.DelayTime:create(1)
				})
			end
		elseif i == 2 then
			if #g_data.select.roles >= 20 and IS_PLAYER_DEBUG then
				an.newMsgbox("您的角色已满20个", nil, {
					center = true
				})
			elseif roleUpperLimit <= #g_data.select.roles and not IS_PLAYER_DEBUG then
				an.newMsgbox("您的角色已满" .. roleUpperLimit .. "个", nil, {
					center = true
				})
			else
				self:showCreate()
			end
		elseif i == 3 then
			if #g_data.select.roles == 0 then
				return
			end

			an.newMsgbox("[" .. g_data.select:getCurName() .. "]删除的角色是不能被恢复的,\n一段时间内您将不能使用相同的角色名称.\n你真的确定要删除吗？", function (idx)
				if idx == 1 then
					an.newMsgbox("再次确认你真的确定要删除吗？", function (idx)
						if idx == 1 then
							net.send({
								CM_DELCHR
							}, {
								g_data.select.roles[g_data.select.selectIndex].name
							})
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end, {
				hasCancel = true
			})
		elseif i == 4 then
			net.send({
				CM_QUERYDELCHR
			})
		elseif i == 5 then
			net.send({
				CM_SELCHR_EXIT
			})
		end
	end

	for i = 1, 5 do
		local x, y = nil

		if i == 1 or i == 5 then
			y = layer:geth() / 2 - 200
			x = layer:getw() / 2 + (i == 1 and -100 or 100)
		else
			y = layer:geth() / 2 - 135 - 40 * (i - 1)
			x = layer:getw() / 2
		end

		if i == 1 then
			local btn = nil
			btn = an.newBtn(res.gettex2("pic/login/tab1.png"), function ()
				clickBtn(i)
			end, {
				pressImage = res.gettex2("pic/login/tab2.png")
			}):pos(x, y):addto(layer)

			if not g_data.player.smallExit then
				btn:setTouchEnabled(false)

				local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 180)):anchor(0, 0):pos(0, 0):addto(btn):size(btn:getContentSize().width, btn:getContentSize().height)
				local percent = 0

				mask:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
					percent = percent + 2

					if percent > 100 then
						btn:setTouchEnabled(true)
						mask:stopAllActions()
						mask:removeSelf()
					else
						mask:pos(0, 0):size(btn:getContentSize().width, btn:getContentSize().height * (1 - percent / 100))
					end
				end))))
			end
		elseif i == 5 then
			an.newBtn(res.gettex2("pic/login/tab9.png"), function ()
				self.returnBtn = true

				clickBtn(i)
			end, {
				pressImage = res.gettex2("pic/login/tab10.png")
			}):pos(x, y):addto(layer)
		else
			an.newBtn(res.gettex2("pic/login/tab" .. 2 * i - 1 .. ".png"), function ()
				clickBtn(i)
			end, {
				pressImage = res.gettex2("pic/login/tab" .. 2 * i .. ".png")
			}):pos(x, y):addto(layer)
		end
	end

	local function clickSelect(idx)
		sound.playSound("104")

		if not self.roles[idx] or idx == g_data.select.selectIndex then
			return
		end

		sound.playSound("101")

		for k, v in pairs(self.roles) do
			if k == g_data.select.selectIndex then
				v.model:setState("unselected")
			elseif k == idx then
				v.model:setState("selected")
			end
		end

		g_data.select:setSelectIndex(idx)
	end

	for i = 1, 2 do
		an.newBtn(res.getuitex(1, 66), function ()
			clickSelect((self.pageIdx - 1) * 2 + i)
		end, {
			pressShow = true
		}):pos(172 + (i - 1) * 551, 130):addto(layer)
	end

	local function clickPage(idx)
		local pages = math.ceil(#g_data.select.roles / 2)

		if idx == 1 then
			self.pageIdx = self.pageIdx - 1 > 0 and self.pageIdx - 1 or pages
		else
			self.pageIdx = pages >= self.pageIdx + 1 and self.pageIdx + 1 or 1
		end

		self:getRoleListSuccess()
	end

	self.pageIdx = math.ceil(g_data.select.selectIndex / 2)
	self.pageBtn = {}

	for i = 1, 2 do
		self.pageBtn[i] = an.newBtn(res.getuitex(3, 401 + (i - 1) * 2), function ()
			clickPage(i)
		end, {
			pressImage = res.getuitex(3, 402 + (i - 1) * 2)
		}):addTo(layer):pos(layer:getw() / 2 + 3, 400 - (i - 1) * 60)

		self.pageBtn[i]:setVisible(#g_data.select.roles > 2)
	end

	sound.playMusic("main_theme", true)
	net.add(self)
	self:getRoleListSuccess()

	if g_data.login.queue then
		self:queueUp(g_data.login.queue.pos, g_data.login.queue.cnt, g_data.login.queue.sec)
		g_data.login:setQueueData()
	end
end

function scene:getRoleListSuccess()
	for k, v in pairs(self.roles) do
		if v.layer then
			v.layer:removeSelf()
		end
	end

	self.roles = {}

	for i = 1, 2 do
		local idx = (self.pageIdx - 1) * 2 + i

		if g_data.select.roles[idx] then
			self:createPlayer(idx, g_data.select.roles[idx])
		end
	end

	self.area:setVisible(table.nums(self.roles) > 0)
end

function scene:showCreate()
	for i, v in pairs(self.roles) do
		if v.model then
			v.model:setVisible(false)
		end
	end

	self.area:show()

	local layer = display.newNode():size(display.width, display.height):addto(self):enableClick(function ()
	end)
	local createIndex = table.nums(g_data.select.roles) % 2 == 0 and 1 or 2
	local edit = res.getui(1, 73):pos(editPos[({
		2,
		1
	})[createIndex]]()):addto(layer):scaleX(dew):scaleY(deh)
	local _ = display.newScale9Sprite("public/black.png", 141, 302, cc.size(142, 21)):addto(edit)
	local editBox1 = an.newInput(145, 300, 150, 30, 14, {
		donotMove = true,
		donotClip = true
	}):addTo(edit)
	local model, workIndex, sexIndex = nil
	local btns = {}

	local function clickBtn(idx)
		if workIndex == idx or idx - 3 == sexIndex then
			return
		end

		if idx > 3 then
			sexIndex = idx - 3
		else
			workIndex = idx
		end

		for i = 1, 3 do
			btns[i]:setIsSelect(workIndex == i)
		end

		for i = 4, 5 do
			btns[i]:setIsSelect(sexIndex == i - 3)
		end

		if model then
			model:removeSelf()
		end

		if workIndex and sexIndex then
			model = role.new(workIndex, sexIndex):setState("new"):pos(rolePos[createIndex]()):addto(layer)
		end
	end

	for i = 1, 5 do
		btns[i] = an.newBtn(res.getuitex(1, 74 + i - 1), function ()
			sound.playSound("104")
			clickBtn(i)
		end, {
			pressBig = true,
			select = {
				res.getuitex(1, 55 + i - 1),
				manual = true
			}
		}):pos(69 + (i <= 3 and (i - 1) * 45 or (i - 3) * 45), i <= 3 and 242 or 170):addto(edit)
	end

	clickBtn(1)
	clickBtn(4)

	local function hideCreate()
		self.area:setVisible(#self.roles > 0)
		layer:removeSelf()
	end

	local firstName = json.decode(res.getfile("config/nameFirst.txt"))
	local boyName = json.decode(res.getfile("config/nameBoy.txt"))
	local girlName = json.decode(res.getfile("config/nameGirl.txt"))

	local function random()
		local first = firstName[math.random(#firstName)]
		local name = nil

		if sexIndex == 1 then
			name = boyName[math.random(#boyName)]
		else
			name = girlName[math.random(#girlName)]
		end

		editBox1:setString(first .. name)
	end

	an.newBtn(res.gettex2("pic/common/random.png"), function ()
		sound.playSound("103")
		random()
	end, {
		pressBig = true
	}):pos(235, 305):add2(edit)
	an.newBtn(res.getuitex(1, 64), function (event)
		sound.playSound("103")
		hideCreate()
		self:getRoleListSuccess()
	end, {
		pressShow = true,
		size = {
			48,
			48
		}
	}):pos(256, 375):addto(edit)
	an.newBtn(res.getuitex(1, 62), function ()
		sound.playSound("104")

		if editBox1:getText() ~= "" then
			self.newRoleName = editBox1:getText()

			net.send({
				CM_NEWCHR
			}, nil, getRecord("TMirCharInfo", {
				hair = 1,
				name = editBox1:getText(),
				job = workIndex - 1,
				sex = sexIndex - 1
			}))
			hideCreate()
		else
			an.newMsgbox("提示角色名没输入", nil, {
				center = true
			})
		end
	end, {
		pressShow = true
	}):pos(140, 40):addto(edit)
end

function scene:createPlayer(idx, info)
	self.roles[idx] = {
		name = info.name,
		work = info.job + 1,
		sex = info.sex + 1,
		level = info.level
	}

	self:createInfo(idx, self.roles[idx])
end

function scene:createInfo(idx, info)
	info.layer = display.newNode():addto(self)
	info.model = role.new(info.work, info.sex):setState(g_data.select.selectIndex == idx and "normal" or "stone")

	info.model:pos(rolePos[(idx - 1) % 2 + 1]()):addto(info.layer)

	local x, y = namepos[(idx - 1) % 2 + 1]()

	an.newLabel(info.name, 18, 1):pos(x, y):addto(info.layer)
	an.newLabel(info.level .. "", 16, 1):pos(x, y - 31):addto(info.layer)
	an.newLabel(({
		"战士",
		"法师",
		"道士"
	})[info.work], 16, 1):pos(x, y - 62):addto(info.layer)
end

function scene:receiveDelChrs(msg, buf, bufLen)
	self.del_selectIdx = nil
	self.del_roles = {}
	local count = msg.param
	local info = getRecord("TMirCharInfo")
	local infoEx = getRecord("TMirCharinfoEx")
	local temp = bufLen >= infoEx:size() * count and infoEx or info

	for i = 1, count do
		_, buf, bufLen = net.record(temp, buf, bufLen)
		self.del_roles[#self.del_roles + 1] = {
			name = temp:get("name"),
			job = temp:get("job"),
			hair = temp:get("hair"),
			level = temp:get("level"),
			sex = temp:get("sex")
		}
	end
end

function scene:getCurDelName()
	if self.del_selectIdx <= #self.del_roles then
		return self.del_roles[self.del_selectIdx].name
	end

	return ""
end

function scene:ShowDelChrList()
	if #self.del_roles <= 0 then
		return
	end

	local layer = display.newNode():size(display.width, display.height):addto(self):enableClick(function ()
	end)
	local del = res.getui(3, 406):pos(recoveryPos()):addTo(layer)
	local scroll = an.newScroll(24, 70, 222, 225, {}):addTo(del)
	local cells = {}

	for k, v in ipairs(self.del_roles) do
		local cell = display.newNode():addTo(scroll):size(scroll:getw(), 26):pos(0, scroll:geth() - 25 * k)
		cells[#cells + 1] = cell
		local labels = {
			[#labels + 1] = an.newLabel(v.name, 14, 1):addTo(cell):pos(45, cell:geth() / 2):anchor(0.5, 0.5),
			[#labels + 1] = an.newLabel(v.level, 14, 1):addTo(cell):pos(113, cell:geth() / 2):anchor(0.5, 0.5),
			[#labels + 1] = an.newLabel(getJobStr(v.job), 14, 1):addTo(cell):pos(155, cell:geth() / 2):anchor(0.5, 0.5),
			[#labels + 1] = an.newLabel(getSexStr(v.sex), 14, 1):addTo(cell):pos(200, cell:geth() / 2):anchor(0.5, 0.5)
		}

		function cell:setColor(color)
			for k, v in ipairs(labels) do
				v:setColor(color)
			end
		end

		cell:enableClick(function ()
			if self.del_selectIdx then
				cells[self.del_selectIdx]:setColor(display.COLOR_WHITE)
			end

			self.del_selectIdx = k

			cell:setColor(display.COLOR_RED)
		end, {
			support = "scroll"
		})
	end

	local function hideDel()
		layer:removeSelf()
	end

	an.newBtn(res.getuitex(1, 64), function (event)
		sound.playSound("103")
		hideDel()
	end, {
		pressShow = true,
		size = {
			48,
			48
		}
	}):pos(256, 375):addto(del)
	an.newBtn(res.getuitex(3, 407), function ()
		if self.del_selectIdx then
			sound.playSound("104")

			if not IS_PLAYER_DEBUG and roleUpperLimit <= #g_data.select.roles then
				an.newMsgbox("您的角色已满" .. roleUpperLimit .. "个", nil, {
					center = true
				})

				return
			end

			net.send({
				CM_RECOVERCHR
			}, {
				self:getCurDelName()
			})
			hideDel()
		end
	end, {
		pressImage = res.getuitex(3, 408)
	}):pos(140, 35):addto(del)
end

function scene:showSecurity()
	self.security = display.newNode():size(sceneW, sceneH):anchor(0.5, 0.5):center():addTo(self):zorder(100)

	self.security:setTouchEnabled(true)
	self.security:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		return true
	end)

	local bg = res.get2("pic/panels/equip/validate.png"):addTo(self.security):pos(self.security:getw() / 2, self.security:geth() / 2):anchor(0.5, 0.5)

	bg:enableClick(function ()
	end, {
		support = "drag"
	})

	local str = "请依次输入密保的第 "

	for i = 1, 4 do
		str = str .. g_data.security.loginBit[i] .. (i == 4 and "" or ",")
	end

	str = str .. " 位"

	an.newLabel(str, 21, 1, {
		color = def.colors.labelYellow
	}):addTo(bg):pos(bg:getw() / 2, 170):anchor(0.5, 0.5)

	local edit = an.newInput(60, 122, 235, 38, 4, {
		label = {
			"",
			20,
			1
		}
	}):addTo(bg):anchor(0, 0.5)

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		os.exit(0)
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg:getw() - 6, bg:geth() - 3):anchor(1, 1)
	an.newBtn(res.gettex2("pic/common/btn30.png"), function ()
		sound.playSound("104")

		local text = edit:getString()

		if string.len(text) == 4 and tonumber(text) then
			net.send({
				CM_SUBMIT_MIBAO,
				param = 1
			}, {
				text
			})
		else
			an.newMsgbox("[失败] 输入密保格式有误，请重新输入。", function ()
				edit:setString("")
			end)
		end
	end, {
		pressImage = res.gettex2("pic/common/btn31.png"),
		label = {
			"确定",
			20,
			1,
			{
				color = def.colors.btn30
			}
		}
	}):addTo(bg):pos(bg:getw() / 2 - 20, 36):anchor(1, 0.5)
	an.newBtn(res.gettex2("pic/common/btn30.png"), function ()
		sound.playSound("104")
		edit:setString("")
	end, {
		pressImage = res.gettex2("pic/common/btn31.png"),
		label = {
			"清除",
			20,
			1,
			{
				color = def.colors.btn30
			}
		}
	}):addTo(bg):pos(bg:getw() / 2 + 20, 36):anchor(0, 0.5)
end

function scene:closeSecurity()
	if self.security then
		self.security:removeSelf()
	end
end

function scene:ekeyErrorMsg(key)
	local ret = nil

	if key == 13 then
		ret = "通行证锁定"
	elseif key == 1001 then
		ret = "网络状况不稳定，请输入\"盛大密宝\"用户" .. "服务卡上\"用户服务号\"的最后6位进行登录。如" .. "有疑问，请访问网站http://ekey.sdo.com，或" .. "与我们的客服热线（021-50504729）联系。"
	elseif key == 1003 then
		ret = "您输入的密宝密码错误。请您访问网站https://ekey.sdo.com" .. "查询您的密宝资料，确定您绑定了此帐号。如有" .. "疑问，请和我们的客服热线（021-50504729）联系。"
	elseif key == 1006 then
		ret = "您的密宝没有与任何帐号绑定。如有疑问，请访" .. "问网站http://ekey.sdo.com，或与我们的客服" .. "热线（021-50504729）联系。"
	elseif key == 1007 then
		ret = "没有相应的绑定信息。如有疑问，请访问网站" .. "http://ekey.sdo.com，或与我们的客服热线" .. "（021-50504729）联系。"
	elseif key == 1011 then
		ret = "请检查您的输入是否有问题，然后请重试一次。"
	elseif key == 1012 then
		ret = "由于网络状况不稳定，请输入\"盛大密宝\"用户服" .. "务卡上\"用户服务号\"的最后6位进行登录。如有疑" .. "问，请访问网站http://ekey.sdo.com，或与我们" .. "的客服热线（021-50504729）联系。"
	elseif key == 1013 then
		ret = "由于网络状况不稳定，请输入\"盛大密宝\"用户服" .. "务卡上\"用户服务号\"的最后6位进行登录。如有疑" .. "问，请访问网站http://ekey.sdo.com，或与我们" .. "的客服热线（021-50504729）联系。"
	elseif key == 1019 then
		ret = "游戏编号错误"
	elseif key == 1020 then
		ret = "游戏区号错误"
	elseif key == 1021 then
		ret = "游戏帐号错误"
	elseif key == 1023 then
		ret = "证件ID错误"
	elseif key == 5 or key == 1024 then
		ret = "密宝时间漂移过大，请稍后再试一次或访问网站" .. "http://ekey.sdo.com校正时间"
	elseif key == 1025 then
		ret = "预留口令错误"
	elseif key == 1027 then
		ret = "修改服务号的次数超过规定"
	elseif key == 1028 then
		ret = "等候处理"
	elseif key == 1000 then
		ret = "密宝状态错误：您的密宝不能使用。如有疑问，" .. "请与我们的客服热线（021-50504729）联系。"
	elseif key == 20 then
		ret = "密宝状态错误：您必须首先启用这个密宝，才能" .. "进行相应的操作。请访问http://ekey.sdo.com，" .. "进行相应的启用操作。如有疑问，请与我们的客" .. "服热线（021-50504729）联系。"
	elseif key == 40 then
		ret = "密宝状态错误：您所操作的\"盛大密宝\"已被挂失，" .. "您选择的挂失后帐号状态为解除保护，帐号可以仅" .. "使用静态密码登录。如果您找回了您的密宝，请先" .. "访问http://ekey.sdo.com，进行解除挂失操作。如" .. "有疑问，请与我们的客服热线（021-50504729）联系。"
	elseif key == 50 then
		ret = "密宝状态错误：您所操作的\"盛大密宝\"已被挂失，" .. "您选择的挂失后帐号状态为帐号锁定，不能访问。" .. "如果您找回了您的密宝，请先访问http://ekey.sdo.com，" .. "进行解除挂失操作。如有疑问，请与我们的客服热" .. "线（021-50504729）联系。"
	elseif key == 60 then
		ret = "密宝状态错误：这个密宝无法使用。如有疑问，请" .. "访问网站http://ekey.sdo.com，或与我们的客服" .. "热线（021-50504729）联系。"
	elseif key == 70 then
		ret = "密宝状态错误：这个密宝无法使用。如有疑问，请" .. "访问网站http://ekey.sdo.com，或与我们的客服" .. "热线（021-50504729）联系。"
	elseif key == 80 then
		ret = "密宝状态错误：由于短时间多次输入错误密码，您" .. "的密宝已经被锁定，请稍后再试。如有疑问，请访" .. "问网站http://ekey.sdo.com，或与我们的客服热" .. "线（021-50504729）联系。"
	elseif key == 90 then
		ret = "密宝状态错误：您所操作的密宝已经停用。如有疑" .. "问，请访问网站http://ekey.sdo.com，或与我们" .. "的客服热线（021-50504729）联系。"
	elseif key == 100 then
		ret = "密宝状态错误：您使用的密宝已经超过了服务期，" .. "无法使用。如有疑问，请访问网站http://ekey.sdo.com，" .. "或与我们的客服热线（021-50504729）联系。"
	elseif key == 110 then
		ret = "密宝状态错误：您所申请操作的密宝已经被新的密" .. "宝替换，请使用新的密宝进行相应操作。如有疑问，" .. "请访问网站http://ekey.sdo.com，或与我们的客" .. "服热线（021-50504729）联系。"
	elseif key == 3 then
		ret = "因为短时间内多次输入错误密码或其它原因，暂时被禁止登录"
	else
		ret = "未知密宝验证错误[" .. key .. "]"
	end

	return ret
end

function scene:reconectFuc(info)
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	if not self.reconnectBox then
		self.reconnectBox = an.newMsgbox(info .. "\n确定重连?", function (idx)
			if idx == 0 then
				common.gotoLogin({
					logout = true
				})
			elseif idx == 1 then
				self.reconnect = true
				g_data.login.reconnectState = true

				scheduler.performWithDelayGlobal(function ()
					net.connect(g_data.login.recIP, g_data.login.recPort, self, g_data.login.recSession)
				end, 0)
			end

			self.reconnectBox = nil
		end, {
			center = true,
			hasCancel = true
		})
	end
end

function scene:onLoseConnect()
	if self.reconnectBox then
		self.reconnectBox:removeSelf()

		self.reconnectBox = nil
	end

	print("scene:onLoseConnect")

	self.reconnectBox = self:reconectFuc("网络连接已断开!")
end

function scene:onNetworkStateChange(currentState)
	local connectable = network.isHostNameReachable("www.baidu.com")

	if not tolua.isnull(self.reconnectBox) then
		if connectable then
			self.reconnectBox:removeSelf()

			self.reconnectBox = nil
		else
			return
		end
	end

	if connectable then
		self:reconectFuc("切换到 " .. (currentState == cc.kCCNetworkStatusReachableViaWiFi and "WIFI网络" or "蜂窝网络"))
	end
end

function scene:queueUp(pos, cnt, sec)
	if pos == 0 then
		if self.layer then
			self.layer:removeSelf()

			self.layer = nil
		end

		return
	end

	if not self.layer then
		self.layer = display.newNode():addTo(self):size(display.width, display.height):setTouchEnabled(true)

		self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ()
		end)
	end

	local layer = self.layer
	local posStr = "您排在第" .. pos .. "位"
	local waitStr = sec == 0 and "正在估算..." or "预计等待" .. (sec > 60 and math.ceil(sec / 60) .. "分钟" or sec .. "秒")

	if not layer.queueUpTip then
		local bg = res.get2("pic/common/msgbox.png"):addTo(layer):pos(display.cx, display.cy)

		bg:setTouchEnabled(true)
		bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ()
		end)
		res.get2("pic/login/queue.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 6):anchor(0.5, 1)

		local function cancel()
			net.send({
				CM_SELCHR_EXIT
			})
		end

		an.newBtn(res.gettex2("pic/common/close10.png"), cancel, {
			pressImage = res.gettex2("pic/common/close11.png")
		}):addTo(bg):pos(bg:getw() - 8, bg:geth() - 5):anchor(1, 1)
		an.newBtn(res.gettex2("pic/common/btn20.png"), cancel, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/common/cancel.png")
		}):addTo(bg):pos(bg:getw() / 2, 30):anchor(0.5, 0.5)
		an.newLabel("服务器爆满需要排队", 20, 1):addTo(bg):pos(bg:getw() / 2, 190):anchor(0.5, 0.5)

		bg.pos = an.newLabel(posStr, 20, 1):addTo(bg):pos(bg:getw() / 2, 150):anchor(0.5, 0.5)
		bg.wait = an.newLabel(waitStr, 20, 1):addTo(bg):pos(bg:getw() / 2, 110):anchor(0.5, 0.5)
		layer.queueUpTip = bg
	else
		layer.queueUpTip.pos:setText(posStr)
		layer.queueUpTip.wait:setText(waitStr)
	end
end

function scene:socketEvent(data, status)
	if status == 3 then
		if self.returnBtn then
			return
		end

		self:reconectFuc(self.reconnect and "连接超时中断，重连失败" or "与服务器断开连接")
	elseif status == 2 then
		self:reconectFuc("连接服务器失败，请检查网络并稍后再试")
	end
end

function scene:processMsg(msg, buf, bufLen)
	if not msg then
		return
	end

	local function tip(str, func)
		an.newMsgbox(str, func, {
			center = true
		})
	end

	local ident = msg.ident

	if SM_NEWCHR == ident then
		if msg.param == 2 then
			tip("这个名字已存在")
		elseif msg.param == 3 then
			tip("你最多只能为一个帐号设置2个角色")
		elseif msg.param == 4 then
			tip("角色创建失败\n角色名中不能包含特殊字符,只允许数字、英文和简体汉字字符。且最少为两个汉字或者4个英文，数字")
		elseif msg.param == 5 then
			tip("你所创建的角色总数已达上限")
		elseif msg.param == 6 then
			tip("跨服申请中，无法新建、删除、恢复角色")
		elseif msg.param == 7 then
			tip("跨服不允许新建、删除、恢复角色")
		end

		self:getRoleListSuccess()
	elseif SM_CHR_LIST == ident then
		if g_data.login.reconnectState then
			g_data.select:receiveChrs(msg, buf, bufLen)

			g_data.login.roleInfo = {
				msg = msg,
				buf = buf,
				bufLen = bufLen
			}
		elseif msg.recog == 1 then
			g_data.select:receiveChrs(msg, buf, bufLen)

			self.pageIdx = math.ceil(g_data.select.selectIndex / 2)

			self.pageBtn[1]:setVisible(#g_data.select.roles > 2)
			self.pageBtn[2]:setVisible(#g_data.select.roles > 2)
			self:getRoleListSuccess()
		end
	elseif SM_DELCHR == ident then
		if msg.param == 0 then
			tip("删除角色失败")
		elseif msg.param == 2 then
			tip("一天内只能删除" .. roleUpperLimit .. "个角色")
		elseif msg.param == 6 then
			tip("跨服申请中，无法新建、删除、恢复角色")
		elseif msg.param == 7 then
			tip("跨服不允许新建、删除、恢复角色")
		end
	elseif SM_SELCHR == ident then
		if msg.param == 1 then
			print(g_data.select:getCurName(), msg.param)
			audio.stopMusic(true)
			net.remove(self)
			g_data.setting.init(g_data.select:getCurName())

			if g_data.areaChange then
				g_data.areaChange = nil

				game.gotoscene("main", nil, "fade", 0.5, display.COLOR_BLACK)
			else
				game.gotoscene("notice", nil, "fade", 0.5, display.COLOR_BLACK)
			end
		elseif msg.param == 2 then
			tip("客户端版本错误")
		elseif msg.param == 3 then
			tip("你没有这个角色")
		elseif msg.param == 4 then
			tip("角色已被删除")
		elseif msg.param == 5 then
			tip("角色数据读取失败，请稍候再试")
		elseif msg.param == 6 then
			tip("角色已锁定")
		else
			tip("你选择的服务器用户满员")
		end
	elseif SM_QUERYDELCHR == ident then
		if msg.param > 0 then
			self:receiveDelChrs(msg, buf, bufLen)
			self:ShowDelChrList()
		else
			tip("没有找到被删除的角色")
		end
	elseif SM_RECOVERCHR == ident then
		if msg.param == 2 then
			tip("角色并未被删除")
		elseif msg.param == 3 then
			tip("你最多只能为一个帐号设置2个角色")
		elseif msg.param == 4 then
			tip("找不到需要恢复的角色")
		elseif msg.param == 6 then
			tip("跨服申请中，无法新建、删除、恢复角色")
		elseif msg.param == 7 then
			tip("跨服不允许新建、删除、恢复角色")
		end
	elseif SM_VAILDATE_PPWD == ident then
		-- Nothing
	elseif SM_ACK_TRANSFER_AREA == ident then
		if bufLen - 1 == getRecordSize("TRetTransferAreaInfo") then
			local transferArea = getRecord("TRetTransferAreaInfo")

			net.record(transferArea, buf, bufLen)

			local add1 = ycFunction:band(transferArea.param1, 255)
			local add2 = ycFunction:band(ycFunction:rshift(transferArea.param1, 8), 255)
			local add3 = ycFunction:band(ycFunction:rshift(transferArea.param1, 16), 255)
			local add4 = ycFunction:band(ycFunction:rshift(transferArea.param1, 24), 255)
			local ip = string.format("%d.%d.%d.%d", add1, add2, add3, add4)
			g_data.areaChange = true

			scheduler.performWithDelayGlobal(function ()
				net.connect(ip, transferArea.param2 .. "", self, transferArea.param)
			end, 0)
		end
	elseif SM_OUTOFCONNECTION == ident then
		self:reconectFuc("与服务器断开连接")
	elseif SM_SELCHR_EXIT == ident then
		common.gotoLogin({
			logout = false
		})
	elseif SM_LOGIN == ident then
		net.send({
			CM_RECONNECT
		}, {
			g_data.reconnctID
		})
	elseif SM_LOGIN_AUTH == ident then
		if msg.param == 2 then
			-- Nothing
		elseif msg.param == 1 then
			local ret1 = getRecord("TLoginIdResult")
			local ret2 = getRecord("TLoginIdResult2")

			if ret1:size() < bufLen then
				net.record(ret2, buf, bufLen)

				g_data.reconnctID = ret2:get("reconnectID")
				g_data.login.loginRet2 = ret2
			else
				net.record(ret1, buf, bufLen)

				g_data.login.loginRet1 = ret1
			end
		end
	elseif SM_OUTOFCONNECTION == ident then
		-- Nothing
	elseif SM_OUTOFCONNECTION_KICKOUT == ident then
		self:reconectFuc("已经被其他用户踢下线")
	elseif SM_RECONNECT == ident then
		-- Nothing
	elseif SM_LOGIN_ALREADY_ONLINE == ident then
		if msg.recog == 1 then
			self.kickoutBox = an.newMsgbox("此账号目前在线，是否强行登录?", function (idx)
				if idx == 1 then
					game.gotoscene("reconnect", nil, "fade", 0.5, display.COLOR_BLACK)
				else
					common.gotoLogin({
						logout = true
					})
				end

				self.kickoutBox = nil

				net.send({
					CM_LOGIN_ALREADY_ONLINE,
					param = idx == 1 and 1 or 0
				})
			end, {
				center = true,
				hasCancel = true
			})
		else
			scheduler.performWithDelayGlobal(function ()
				game.gotoscene("reconnect", nil, "fade", 0.5, display.COLOR_BLACK)
			end, 0)
		end
	elseif SM_LOGIN_QUEUE == ident then
		self:queueUp(msg.param, msg.tag, msg.series)
	elseif SM_SELCHR_ERR == ident then
		an.newMsgbox("服务器维护中，请稍后再试", function ()
			common.gotoLogin({
				logout = true
			})
		end, {
			center = true
		})
	else
		return false
	end

	return true
end

return scene
