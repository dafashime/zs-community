return {
	doublekt = false,
	encryptAES256 = function(text, text2)
		text = tostring(text)
		text2 = tostring(text2)

		return cc.Crypto:encryptAES256(text, string.len(text), text2, string.len(text2))
	end,
	decryptAES256 = function(text, text2)
		text = tostring(text)
		text2 = tostring(text2)

		return cc.Crypto:decryptAES256(text, string.len(text), text2, string.len(text2))
	end,
	encxx = function(text, text2)
		text = tostring(text)
		text2 = tostring(text2)

		return cc.Crypto:encryptXXTEA(text, string.len(text), text2, string.len(text2))
	end,
	decxx = function(text, text2)
		text = tostring(text)
		text2 = tostring(text2)

		return cc.Crypto:decryptXXTEA(text, string.len(text), text2, string.len(text2))
	end,
	encb = function(text)
		text = tostring(text)

		return cc.Crypto:encodeBase64(text, string.len(text))
	end,
	decb = function(text)
		text = tostring(text)

		return cc.Crypto:decodeBase64(text)
	end,
	md = function(text, enabled)
		text = tostring(text)

		if type(enabled) ~= "boolean" then
			enabled = false
		end

		return cc.Crypto:MD5(text, enabled)
	end,
	mdf = function(text)
		if not text then
			printError("crypto.md5file() - invalid filename")

			return nil
		end

		text = tostring(text)

		if DEBUG > 1 then
			printInfo("crypto.md5file() - filename: %s", text)
		end

		return cc.Crypto:MD5File(text)
	end,
	ms = function(value)
		local value2, value3 = pcall(value[1])

		if not value2 then
			__G__TRACKBACK__(value3)
		end
	end,
	jpior = function(value)
		local function callback(self, value2)
			local function callback2(self3)
				return self.getVar(self3)
			end

			local function callback3(self2)
				if self.getStd then
					return self:getStd():get(self2)
				else
					return self.getVar(self2)
				end
			end

			local value10 = callback2(value2) or 0
			local value3 = callback2("max" .. value2) or 0

			if value10 > 0 or value3 > 0 then
				local value4 = callback3("max" .. value2)

				if value4 < value3 then
					return value3 - value4
				end
			end

			return 0
		end

		local value5 = callback(value, "DC")
		local value6 = callback(value, "MC")
		local value7 = callback(value, "SC")
		local value8 = callback(value, "AC")
		local value9 = callback(value, "MAC")

		return math.max(value5, value6, value7, value8, value9)
	end,
	canUseEquip = function(value3, value6, value7, value4)
		if not value3 or not g_data.player then
			return false
		end

		if value4 and not g_data.hero then
			return false
		end

		local value = value4 and g_data.hero or g_data.player
		local var = value3.getVar("need")
		local var2 = value3.getVar("needLevel")
		local var3 = value3.getVar("needJob")
		local value5 = value.sex
		local value2
		local var4 = value3.getVar("stdMode")
		local takeOnPosition = getTakeOnPosition(var4)

		if var4 == 10 and value5 == 1 then
			return false
		end

		if var4 == 11 and value5 == 0 then
			return false
		end

		if var4 ~= 5 and var4 ~= 6 and value.ability:get("maxWearWeight") - value.ability:get("wearWeight") < value3.getVar("weight") then
			return false
		end

		if takeOnPosition then
			if var == 0 then
				value2 = var2 <= value.ability:get("level")
			elseif var == 1 then
				value2 = var2 <= value.ability:get("maxDC")
			elseif var == 2 then
				value2 = var2 <= value.ability:get("maxMC")
			elseif var == 3 then
				value2 = var2 <= value.ability:get("maxSC")
			elseif var == 5 and value6 then
				value2 = var2 >= value.ability3:get("prestige", value7)
			end

			if var3 >= 8 then
				value2 = var3 == value.job
			elseif var3 == 1 then
				value2 = value.job == 0
			elseif var3 == 2 then
				value2 = value.job == 1
			elseif var3 == 4 then
				value2 = value.job == 2
			end
		end

		return value2
	end,
	superior = function(value, value2, value8, value6)
		if not def.ccy.canUseEquip(value, true, true, value6) then
			return
		end

		if not value2 then
			return 1
		end

		local var2 = value.getVar("stdMode")

		local function callback(self2, value7)
			return self2.getVar(value7) or 0
		end

		local function callback2(self, value4, ...)
			local value3 = callback(value, "AC") + callback(value, "maxAC") + callback(value, "MAC") + callback(value, "maxMAC") - (callback(value2, "AC") + callback(value2, "maxAC") + callback(value2, "MAC") + callback(value2, "maxMAC"))
			local var3 = value.getVar(self) + value.getVar(value4)
			local var = value2.getVar(self) + value2.getVar(value4)
			local value5 = var3 - var

			if value5 > 0 then
				return value5
			elseif value3 > 0 and var == 0 then
				return value3
			end
		end

		if var2 == 7 then
			if value.getVar("duraMax") > value2.getVar("duraMax") then
				return 1
			end
		elseif g_data.player.job == 0 or def.ccy.useDC() then
			return callback2("DC", "maxDC")
		elseif g_data.player.job == 1 or def.ccy.useMC() then
			return callback2("MC", "maxMC")
		elseif g_data.player.job == 2 or def.ccy.useSC() then
			return callback2("SC", "maxSC")
		end
	end,
	getItemDiff = function(value)
		local var = value.getVar("maxDC") - value.getStd():get("maxDC")
		local var2 = value.getVar("maxMC") - value.getStd():get("maxMC")
		local var3 = value.getVar("maxSC") - value.getStd():get("maxSC")
		local var4 = value.getVar("maxAC") - value.getStd():get("maxAC")
		local var5 = value.getVar("maxMAC") - value.getStd():get("maxMAC")
		local var6 = value.getVar("AC") - value.getStd():get("AC")
		local var7 = value.getVar("MAC") - value.getStd():get("MAC")

		return var .. "~" .. var2 .. "~" .. var3 .. "~" .. var6 .. "~" .. var7 .. "~" .. var4 .. "~" .. var5
	end,
	equipChgTrigger = function(value3, value, value2)
		if def.closeEquipChgTrigger then
			return
		end

		local var = value2.getVar("name") .. "~" .. def.ccy.getItemDiff(value2)

		if value3 == "on" then
			def.role.call("@equipChgTrigger~on~" .. value .. "~" .. var)
		else
			def.role.autoRun(function()
				def.role.call("@equipChgTrigger~off~" .. value .. "~" .. var)
			end, 0.5)
		end
	end,
	useItem = function(value, value2)
		if not value2 then
			return
		end

		if main_scene.ui.panels.deal then
			main_scene.ui:tip("面对面交易无法穿戴")

			return
		end

		local value3 = value and g_data.heroBag or g_data.bag
		local itemWithName, itemWithName2 = value3:getItemWithName(value2)

		if itemWithName then
			sound.play("item", itemWithName)

			local var = itemWithName.getVar("stdMode")
			local recog2 = itemWithName:get("makeIndex")

			if checkExist(var, 5, 7, 10, 11, 15, 16, 19, 20, 22, 24, 25, 26, 27, 28, 29, 30) then
				local where2 = getTakeOnPosition(var)

				if value3:use("take", recog2, {
					force = true,
					where = where2
				}) then
					net.send({
						value and CM_HERO_TAKEON or CM_TAKEONITEM,
						recog = recog2,
						param = where2
					}, {
						value2
					})
					def.ccy.equipChgTrigger("on", tostring(where2), itemWithName)

					if value then
						if main_scene.ui.panels.heroBag then
							main_scene.ui.panels.heroBag:delItem(recog2)
						end
					elseif main_scene.ui.panels.bag then
						main_scene.ui.panels.bag:delItem(recog2)
					end
				end
			elseif g_data.bag:use("eat", recog2, {
				quick = true
			}) then
				net.send({
					value and CM_HERO_EAT or CM_EAT,
					recog = recog2
				}, {
					value2
				})

				if value then
					if main_scene.ui.panels.heroBag then
						main_scene.ui.panels.heroBag:delItem(recog2)
					end
				elseif main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:delItem(recog2)
				end
			end
		end
	end,
	switchHorse = function()
		if not g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
			return
		end

		if not def.openHorse then
			main_scene.ui:tip("没开启骑马功能")

			return
		end

		local value = main_scene.ground.player

		if not value or value.die then
			return
		end

		if (def.role.attacking or def.role.beAttacking) and not def.stateIsHave(value.state, "stHorse") then
			main_scene.ui:tip("未脱离攻击状态无法上马")

			return
		end

		if g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
			g_data.client:setLastTime("docsZaiMaShang", true)

			local value2 = main_scene.ui.console:get("btnHorse")

			if value2 then
				main_scene.ui.console.controller:showcd(value2, 0.5, 0.5)
			end

			main_scene.ui.console.controller.autoFindPath:multiMapPathStop()

			if not def.stateIsHave(value.state, "stHorse") then
				def.role.call("@shangma")
			elseif def.stateIsHave(value.state, "stHorse") then
				def.role.call("@xiama")
			end

			main_scene.ui.console.autoRat:stop()
			main_scene.ui.console.controller.lock:stop()
			main_scene.ui.console.controller.lock:stopAttack()
		else
			main_scene.ui:tip("操作太快")
		end
	end,
	isAutoXiama = function(value2)
		if value2 or def.attackOnHourse then
			return false
		end

		if not def.openHorse then
			return
		end

		local value = main_scene.ground.player

		if not value or value.die then
			return false
		end

		if not g_data.client:checkLastTime("docsZaiMaShang", 0.5) and not def.stateIsHave(value.state, "stHorse") then
			return true
		end

		if def.stateIsHave(value.state, "stHorse") then
			main_scene.ui:tip("骑马状态，不允许攻击")

			return true
		end

		return false
	end,
	priceFormat = function(value, value2)
		if value2 == 1 then
			value = value * 10000
		end

		if value >= 10000 then
			if value % 10000 < 1000 then
				return string.format("%d万", math.floor(value / 10000))
			else
				return string.format("%.1f万", (value - value % 1000) / 10000)
			end
		else
			return change2GoldStyle(value)
		end
	end,
	sceneShake = function()
		if not main_scene or not main_scene.ground.map then
			return
		end

		local node = main_scene.ground.map

		node:runs({
			cc.JumpTo:create(0.4, cc.p(node:getPosition()), 10, 2)
		})
	end,
	skillHead = function(value2, value3)
		if not value2 or value2 == "" then
			return print("head img is nil")
		end

		local x = display.width + display.cx
		local value4
		local value = res.get(value2, value3):pos(x, display.cy):addTo(main_scene.ui, 99999)

		if value and value:getw() > 1 and value:geth() > 1 then
			value:runs({
				cc.MoveTo:create(0.1, cc.p(200, display.cy)),
				cc.DelayTime:create(0.6),
				cc.MoveTo:create(0.1, cc.p(-display.cx, display.cy)),
				cc.CallFunc:create(function()
					if value then
						value:removeSelf()

						value = nil
					end
				end)
			})
		end
	end,
	getTwinDis = function(point, point2)
		if point.x and point.y and point2.x and point2.y then
			local number = 4
			local value = math.abs(point.x - point2.x)
			local value2 = math.abs(point.y - point2.y)

			if number >= math.max(value, value2) and (point.x == point2.x or point.y == point2.y or value == value2) then
				return true
			end
		end

		return false
	end,
	findCsSkillbyMagic = function(value, value2)
		if def.csSkills then
			for _, csSkill in pairs(def.csSkills) do
				if value == csSkill.magicId and value2 == csSkill.job then
					return csSkill
				end
			end
		end

		return nil
	end,
	getCopiedStartFrame = function(items, value)
		local value2 = items.startFrame[1]

		value = value or g_data.player.job

		if #items.startFrame > 1 then
			for _, startFrame in ipairs(items.startFrame) do
				if startFrame.job and startFrame.job == value then
					value2 = startFrame

					break
				end
			end
		end

		return value2
	end,
	getAttackSKillCDs = function(value)
		local items = {
			swordhit = 22,
			fire = 15,
			rush = 6
		}

		if def.attackSkillCDs then
			return def.attackSkillCDs[value] or items[value]
		end

		return items[value]
	end,
	isOpenCSSkill = function()
		return main_scene and main_scene.ui.console.controller.callSkill ~= nil
	end,
	getItemName = function(response)
		if not response then
			return ""
		end

		if not def.showItemNameWithPlus then
			return string.split(response.data.getVar("name"), "+")[1]
		else
			return response.data.getVar("name")
		end
	end,
	changeMode = function(attackModeId)
		local items = {
			"「全体攻击模式」可攻击所有玩家",
			"「和平攻击模式」攻击所有玩家均无效",
			"「组队攻击模式」非组队成员均可被攻击",
			"「行会攻击模式」非本行会成员可被攻击",
			"「善恶攻击模式」仅攻击宣战行会成员",
			"「战队攻击模式」非本战队成员可被攻击",
			"当前「未知攻击模式」模式不详",
			"「乱斗攻击模式」可攻击所有玩家",
			"「阵营对战模式」可攻击非本阵营成员"
		}
		local value = items[attackModeId + 1] or items[7] or "当前「未知攻击模式」模式不详"

		if main_scene.ground:smr() then
			value = items[8] or "「乱斗攻击模式」可攻击所有玩家"
		end

		if main_scene.ground.player.info and main_scene.ground.player.info.campId then
			value = items[9] or "「阵营对战模式」可攻击非本阵营成员"
		end

		g_data.player:setAttackMode(value)

		g_data.player.attackModeId = attackModeId

		require("mir2.scenes.main.common.common").addMsg(value, 255, 70)
		main_scene.ui.console:call("btnMode", "upt")
		main_scene.ui.console:call("tasks", "upt")
	end,
	useDC = function()
		if def.jobMaps then
			local text = def.jobMaps[tostring(g_data.player.job)]

			if text and text.use == "DC" then
				return true
			end
		end

		return false
	end,
	useMC = function()
		if def.jobMaps then
			local text = def.jobMaps[tostring(g_data.player.job)]

			if text and text.use == "MC" then
				return true
			end
		end

		return false
	end,
	useSC = function()
		if def.jobMaps then
			local text = def.jobMaps[tostring(g_data.player.job)]

			if text and text.use == "SC" then
				return true
			end
		end

		return false
	end,
	getJobName = function(text)
		if text == 0 then
			return "战士"
		elseif text == 1 then
			return "法师"
		elseif text == 2 then
			return "道士"
		elseif text == 3 then
			return "刺客"
		elseif def.jobMaps and def.jobMaps[tostring(text)] then
			return def.jobMaps[tostring(text)].name or "未知职业"
		else
			return "未知职业"
		end
	end,
	calcCDTime = function(value5, value2, value6)
		local value = value5

		if not value or value <= 0 then
			value = g_data.player.ability.attSpeed * g_data.player.ability.mpResume

			if value > 2000 then
				value = 2000
			end

			value = 2000 - value
		end

		local value4 = value / 1000
		local value3 = value6

		if value2.cmDelaytime then
			value3 = value2.cmDelaytime
		end

		if value2.actFrame and value2.actFrame[tostring(g_data.player.job)] then
			local text = value2.actFrame[tostring(g_data.player.job)]

			if text.cmDelaytime then
				value3 = text.cmDelaytime
			end
		end

		if value3 and value4 < value3 then
			value4 = value3
		end

		return value4
	end
}
