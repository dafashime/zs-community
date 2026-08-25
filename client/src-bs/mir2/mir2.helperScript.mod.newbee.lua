function main(evt)
	print("onNewbee", evt)


	function guideTouch(nodeName, hightLight, twinkle, tipText, params)
		if not GUIDE:isNodeExist(nodeName) then
			local time = 0

			while not GUIDE:isNodeExist(name) do
				delay(0.1)

				time = time + 0.1

				if time > 5 then
					return false
				end
			end
		end

		if hightLight then
			GUIDE:hightLightNode(nodeName)
		end

		if twinkle then
			local flashHandler = GUIDE:twinkleNodeWidthName(nodeName, twinkle)
		end

		if tipText then
			local align = "right"
			local off = pos(-30, 0)
			local text = tipText

			if type(tipText) ~= "table" or not tipText.align then
				local n = GUIDE:getNodeByName(nodeName)

				if not n then
					print(nodeName, "not exist")
				end

				if n and n:convertToWorldSpace(pos(0, 0)).x < display.width / 2 then
					align = "left"
					off = pos(30, 0)
				end

				if type(tipText) == "table" then
					text = tipText.text

					if tipText.pos then
						off = tipText.pos

						if align ~= "left" then
							off.x = -off.x
						end
					end
				end
			else
				text = tipText.text
				align = tipText.align or align
				off = tipText.pos or off
			end

			GUIDE:showTipText(nodeName, {
				text,
				tipText.fontSize or 22,
				1,
				align = align
			}, off)
		end

		local lockOther = true
		lockOther = (not params or type(params.lockOther) == "nil") and true or params.lockOther
		local evt = nil

		GUIDE:focusToNode(nodeName, lockOther, nil, params)

		local endedEvt = "ended," .. nodeName
		evt = waitEvt({
			endedEvt,
			"clean," .. nodeName,
			"timeout"
		})

		GUIDE:stop()

		return evt == endedEvt
	end

	function guideUseItem(itemName, tipText, params)
		local isBook = params
		local lockOther = true
		local timeout = 999

		if type(params) == "table" then
			isBook = params.isBook
			lockOther = params.lockOther
			timeout = params.timeout or timeout
		end

		local nodeName = "bag_" .. itemName
		local cnt = getItemCount(itemName)

		if cnt > 0 and isPanelOpenning("bag") then
			local align = "left"
			local off = pos(30, 0)

			if GUIDE:getNodeByName(nodeName):getPositionX() > display.width / 2 then
				align = "right"
				off = pos(-30, 0)
			end

			if lockOther then
				GUIDE:hightLightNode(nodeName)
			end

			GUIDE:showTipText(nodeName, {
				tipText,
				22,
				1,
				align = align
			}, off)
			GUIDE:twinkleNodeWidthName(nodeName, {
				circle = true,
				radio = 35
			})

			if isBook then
				while not GUIDE:isNodeExist("msgBoxLearnSkill") do
					if not GUIDE:isNodeExist(nodeName) then
						return false
					end

					GUIDE:focusToNode(nodeName, lockOther, nil, 0.1)
					waitEvt({
						"ended," .. nodeName,
						"timeout"
					})
				end

				GUIDE:stop()

				while GUIDE:isNodeExist("msgBoxLearnSkill") do
					delay(0.1)
				end
			else
				params = params or {}
				params.timeout = 0.1
				local t = 0

				while cnt == getItemCount(itemName) and GUIDE:isNodeExist(nodeName) do
					GUIDE:focusToNode(nodeName, lockOther, nil, params)

					evt = waitEvt({
						"ended," .. nodeName,
						"timeout"
					})
					t = t + 0.1

					if evt ~= "timeout" or timeout <= t then
						break
					end
				end
			end

			GUIDE:stop()

			return true
		end
	end

	function guideTip(text, hightLight, timeout, btns)
		local tip = GUIDE:showGuideBoard(text, hightLight, btns)
		local evt = nil

		if btns then
			evt = waitEvt({
				"GuideBoardEvt_confirm",
				"GuideBoardEvt_cancel",
				"timeout"
			})
		elseif hightLight then
			tip:setName("welcome")
			guideTouch("welcome", false, nil, nil, {
				lockOther = true,
				swallowAnyway = true
			})
		elseif timeout then
			delay(timeout)

			evt = "timeout"
		else
			return tip
		end

		tip:removeSelf()

		return evt, evt == "GuideBoardEvt_confirm"
	end

	function untilClosed(target)
		while true do
			delay(0.1)

			local x, y, mapid = getPlayerLocation()

			if math.abs(x - target.x) <= 2 and math.abs(y - target.y) <= 2 then
				return true
			elseif not isPlayerMoving() then
				return
			end
		end
	end

	function untilNodeExist(name)
		GUIDE:untilNodeExist(name)
	end

	function untilNodeNotExist(name)
		while GUIDE:isNodeExist(name) do
			delay(0.1)
		end
	end

	function utilNPCExist(name, timeout)
		timeout = timeout or 999

		for k = 0.1, 999, 0.1 do
			if findNPCWithName(name) then
				break
			end

			delay(0.1)
		end
	end

	function guideOpenPanel(btnName, panelName, tipText, twinkle, timeout)
		timeout = timeout or 30

		if not GUIDE:isNodeExist(btnName) or isPanelOpenning(panelName) then
			return isPanelOpenning(panelName)
		end

		if tipText then
			local align = "right"
			local off = pos(-30, 0)
			local text = tipText

			if type(tipText) ~= "table" or not tipText.align then
				local n = GUIDE:getNodeByName(btnName)

				if not n then
					print(btnName, "not exist")
				end

				if n and n:convertToWorldSpace(pos(0, 0)).x < display.width / 2 then
					align = "left"
					off = pos(30, 0)
				end

				if type(tipText) == "table" then
					text = tipText.text

					if tipText.pos then
						off = tipText.pos

						if align ~= "left" then
							off.x = -off.x
						end
					end
				end
			else
				text = tipText.text
				align = tipText.align or align
				off = tipText.pos or off
			end

			GUIDE:showTipText(btnName, {
				text,
				tipText.fontSize or 22,
				1,
				align = align
			}, off)
		end

		GUIDE:twinkleNodeWidthName(btnName, twinkle or {
			circle = true,
			radio = 45
		})

		local t = 0

		while not isPanelOpenning(panelName) do
			delay(0.1)

			t = t + 0.1

			if not GUIDE:isNodeExist(btnName) or timeout < t then
				break
			end
		end

		GUIDE:stop()

		return isPanelOpenning(panelName)
	end

	if evt == "firstLogin" then
		if GUIDE:isNodeExist("diy_背包") then
			local tip = GUIDE:showGuideBoard("欢迎来到原始版热血传奇。我是你的助手阿妍。让我告诉你一些基本的操作吧。", true)

			tip:setName("welcome")
			guideTouch("welcome", false, nil, nil, {
				swallowAnyway = true
			})
			tip:removeSelf()

			if not isPanelOpenning("bag") and not guideOpenPanel("diy_背包", "bag", "点击打开背包") then
				return
			end

			if PLAYERSEX == 0 then
				dressName = "布衣(男)"
			else
				dressName = "布衣(女)"
			end

			for _, dress in pairs({
				dressName,
				"木剑"
			}) do
				if hasItem(dress) and not hasEquip(dress) and not guideUseItem(dress, string.format("双击%s进行装备", dress), {
					lockOther = false
				}) then
					break
				end
			end

			if isPanelOpenning("bag") then
				guideTouch("bag_close", false, nil, {
					text = "关闭背包"
				}, {
					lockOther = false
				})
			end

			guideTip("已经学习过基本的装备穿戴啦。去和比奇野外的怪物较量一番。", true)

			local x, y, mapid = getPlayerLocation()

			if mapid == "0" then
				local npc1 = "银杏老兵"
				local npc2 = "边界老兵"
				local npc = nil
				npcRole = findNPCWithName(npc1)

				if not npcRole then
					npcRole = findNPCWithName(npc2)
					npc = npc2
				else
					npc = npc1
				end

				if not npcRole then
					if GUIDE:isNodeExist("diy_普通攻击") then
						guideTouch("diy_普通攻击", false, nil, "普通攻击按钮能够帮你自动选择\n最近的怪物作为攻击目标", {
							lockOther = false,
							timeout = 5
						})
					end

					return
				end

				playerMoveTo(npcRole.x, npcRole.y, mapid, 2)

				if not untilClosed(npcRole) then
					guideTouch("diy_普通攻击", false, nil, "普通攻击按钮能够帮你自动选择\n最近的怪物作为攻击目标", {
						lockOther = false,
						timeout = 5
					})

					return
				end

				stopPlayerMove()

				if GUIDE:talkWithNPC(npc) then
					untilNodeExist("npc_去周围看看")
					guideTouch("npc_去周围看看", false, nil, {
						text = string.format("让%s带你去周围看看吧", npc),
						pos = pos(65, 0)
					}, {
						lockOther = false
					})
					untilNodeNotExist("npc_去周围看看")

					if GUIDE:isNodeExist("diy_普通攻击") then
						guideTouch("diy_普通攻击", false, nil, "普通攻击按钮能够帮你自动选择\n最近的怪物作为攻击目标", {
							lockOther = false,
							timeout = 5
						})
					end
				end
			end
		end

		return
	end

	if evt == "level_3" then
		if not hasItem("3级礼盒") then
			guideTip("新手礼包中有技能书、药品等超值礼品，到达等级后记得开启。", true, 5)

			return
		end

		if not isPanelOpenning("bag") then
			if GUIDE:isNodeExist("diy_背包") then
				if not guideOpenPanel("diy_背包", "bag", "您的礼盒可以打开了") then
					return
				end
			elseif GUIDE:isNodeExist("diyhp") then
				guideTouch("diyhp", false, nil, {
					text = "您的礼盒可以打开了"
				})
				guideTouch("btnEx_bag", true, nil, {
					text = "您的礼盒可以打开了"
				})
				openPanel("bag")
				delay(0.5)
			else
				faild()
			end
		end

		if hasItem("3级礼盒") then
			guideUseItem("3级礼盒", "双击打开")

			while not hasItem("7级礼盒") do
				if not isPanelOpenning("bag") then
					faild()

					return
				end

				delay(0.1)
			end
		end
	end

	if evt == "level_7" then
		local skillName, skillIdx = nil

		if PlayerJob == 0 then
			skillName = "基本剑术"
			skillIdx = 3
		elseif PlayerJob == 1 then
			skillName = "火球术"
			skillIdx = 1
		else
			skillName = "治愈术"
			skillIdx = 2
		end

		local skillNodeName = "diyPanel_skill" .. skillIdx
		local skillQuickNodeName = "diy_skill" .. skillIdx

		function faild()
			guideTip(string.format("7级礼盒中有技能书%s，双击可以学习提升自己。", skillName), true, 5)
		end

		if not hasItem("3级礼盒") and not hasItem("7级礼盒") and not checkPlayerSkill(skillIdx) then
			faild()

			return
		end

		if not isPanelOpenning("bag") then
			if GUIDE:isNodeExist("diy_背包") then
				if not guideOpenPanel("diy_背包", "bag", "您的礼盒可以打开了") then
					return
				end
			elseif GUIDE:isNodeExist("diyhp") then
				guideTouch("diyhp", false, nil, {
					text = "您的礼盒可以打开了"
				})
				guideTouch("btnEx_bag", true, nil, {
					text = "您的礼盒可以打开了"
				})
				openPanel("bag")
				delay(0.5)
			else
				faild()
			end
		end

		if isPanelOpenning("bag") then
			if hasItem("3级礼盒") then
				guideUseItem("3级礼盒", "双击打开", {
					lockOther = false
				})

				while not hasItem("7级礼盒") do
					if not isPanelOpenning("bag") then
						faild()

						return
					end

					delay(0.1)
				end
			end

			if hasItem("7级礼盒") then
				guideUseItem("7级礼盒", "双击打开")

				while not hasItem(skillName) do
					if not isPanelOpenning("bag") then
						faild()

						return
					end

					delay(0.1)
				end
			end
		end

		if hasItem(skillName) and isPanelOpenning("bag") then
			guideUseItem(skillName, "双击学习", {
				lockOther = false,
				isBook = true
			})
			guideTouch("bag_close", false, {
				circle = true,
				radio = 25
			}, {
				text = "关闭背包"
			}, {
				lockOther = false
			})
		else
			faild()
		end
	end

	if evt == "level_9" then
		if GUIDE:isNodeExist("diy_挂机") then
			return
		end

		guideOpenPanel("diy_布局", "diy", "布局功能可以定制游戏界面\n帮助您更高效地应对各种场景", {
			w = 40,
			circle = false,
			h = 75
		})

		dragHandler = GUIDE:dragGuide("diyPanel_btnAutoRat", "diyPanel_ScrollView", {
			goalOffset = pos(500, -75)
		})

		GUIDE:hightLightNode("diyPanel_btnAutoRat")
		GUIDE:showTipText("diyPanel_btnAutoRat", {
			"拖动快捷按钮到合适的位置",
			22,
			1,
			align = "left"
		}, pos(30, 0))
		GUIDE:focusToNode("diyPanel_btnAutoRat", true)
		GUIDE:untilNodeExist("diy_挂机")
		GUIDE:stop()
		guideTouch("diy_close", true, {
			circle = true,
			radio = 25
		}, {
			text = "关闭布局界面"
		})
		guideTouch("diy_挂机", false, {
			circle = true,
			radio = 45
		}, {
			text = "使用挂机功能方便轻松升级"
		}, {
			lockOther = false,
			timeout = 60
		})
	end

	if evt == "level_10" then
		local function faild1()
			guideTip("引导已取消，通过各个城镇的传送员可以帮您快速到达玛法大陆各个地区，当前建议您通过比奇传送员传送到兽人古墓进行挑战。", true, 5)
		end

		local function faild2()
			guideTip("引导已取消，兽人古墓传送员可以帮您传送到兽人古墓各个区域。为了养活自己，他也会做一些买卖，价格公道童受无欺。", true, 5)
		end

		guideTip("你的等级已经达到了10级，可以挑战游戏中较为强悍的怪物了。接下来我将带领你走到那里。", true, nil)

		local npc = "比奇老兵"
		local npcRole = findNPCWithName(npc)

		if not npcRole then
			GUIDE:useOnceAct(1)
			utilNPCExist(npc, 5)

			npcRole = findNPCWithName(npc)

			if not npcRole then
				return
			end
		end

		playerMoveTo(npcRole.x, npcRole.y, "0", 2)

		if not untilClosed(npcRole) then
			faild1()

			return
		end

		stopPlayerMove()
		GUIDE:stop()
		GUIDE:talkWithNPC(npc)
		untilNodeExist("npc_洞穴传送")

		local ret = guideTouch("npc_洞穴传送", false, nil, {
			text = "点击进行地图传送",
			pos = pos(45, 0)
		}, {
			lockOther = false,
			timeout = 60
		})

		if not ret then
			faild1()

			return
		end

		untilNodeExist("npc_前往兽人古墓")

		ret = guideTouch("npc_前往兽人古墓", false, nil, {
			text = "传送到兽人古墓",
			pos = pos(70, 0)
		}, {
			lockOther = false,
			timeout = 60
		})

		if not ret then
			faild1()

			return
		end

		npc = "兽人古墓传送员"

		utilNPCExist(npc, 5)

		npcRole = findNPCWithName(npc)

		if not npcRole then
			GUIDE:stop()
			faild2()

			return
		end

		playerMoveTo(npcRole.x, npcRole.y, "0", 2)

		if not untilClosed(npcRole) then
			faild2()

			return
		end

		stopPlayerMove()
		delay(0.6)
		GUIDE:stop()
		npcRole.node:setName("newbee_guideTouchRole")

		ret = guideTouch("newbee_guideTouchRole", false, nil, "点击传送员进行对话", {
			lockOther = false,
			timeout = 60,
			swallowAnyway = true
		})

		if not ret then
			faild2()

			return
		end

		GUIDE:talkWithNPC(npc)
		untilNodeExist("npc_前往兽人古墓二层")

		local ret = guideTouch("npc_前往兽人古墓二层", false, nil, {
			text = "前往兽人古墓二层",
			pos = pos(70, 0)
		}, {
			lockOther = false,
			timeout = 60
		})

		if not ret then
			faild2()

			return
		end
	end

	if evt == "low_hp" and GUIDE:isNodeExist("diy_红药") then
		guideTouch("diy_红药", false, {
			circle = true,
			radio = 45
		}, {
			text = "使用红药回血"
		}, {
			lockOther = false,
			timeout = 35
		})
	end
end
