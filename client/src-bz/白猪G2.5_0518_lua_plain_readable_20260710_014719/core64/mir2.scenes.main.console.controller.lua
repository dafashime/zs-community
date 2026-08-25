local settingLogic = import("..common.settingLogic")
local common = import("..common.common")
local controller = require("mir2.scenes.main.console.controller1")
local cc2 = require("mir2.cc")

function controller:showcd(progressCDTimer2, options2, options)
	if not def.enableCD then
		return
	end

	if def.noCD then
		return
	end

	local function cleanup(progressCDTimer, value)
		if progressCDTimer.progressCDTimer then
			if progressCDTimer.progressCDTimer.label then
				progressCDTimer.progressCDTimer.label:removeSelf()

				progressCDTimer.progressCDTimer.label = nil
			end

			progressCDTimer.progressCDTimer:removeSelf()

			progressCDTimer.progressCDTimer = nil
		end

		if not progressCDTimer.progressCDTimer then
			progressCDTimer.progressCDTimer = cc.ProgressTimer:create(res.get2("pic/console/radial.png")):pos(progressCDTimer2:getw() / 2, progressCDTimer:geth() / 2):add2(progressCDTimer)

			progressCDTimer.progressCDTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
			progressCDTimer.progressCDTimer:setBarChangeRate(cc.p(0, 1))
			progressCDTimer.progressCDTimer:setPercentage(100)
			progressCDTimer.progressCDTimer:setReverseDirection(true)

			progressCDTimer.progressCDTimer.label = nil

			progressCDTimer.progressCDTimer:runs({
				cc.ProgressTo:create(value, 0),
				cc.CallFunc:create(function()
					if progressCDTimer.progressCDTimer.label then
						progressCDTimer.progressCDTimer.label:removeSelf()

						progressCDTimer.progressCDTimer.label = nil
					end

					progressCDTimer.progressCDTimer:removeSelf()

					progressCDTimer.progressCDTimer = nil
				end)
			})

			progressCDTimer.progressCDTimer.label = an.newLabel(string.format("%.1f", value), 16, 0, {
				color = cc.c3b(255, 255, 255),
				sc = cc.c3b(0, 0, 0)
			}):pos(progressCDTimer2:getw() / 2, progressCDTimer:geth() / 2):add2(progressCDTimer):anchor(0.5, 0.5)

			progressCDTimer.progressCDTimer:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
				if progressCDTimer and progressCDTimer.progressCDTimer and progressCDTimer.progressCDTimer.label then
					value = value - 0.1

					progressCDTimer.progressCDTimer.label:setString(string.format("%.1f", value))
				end
			end))))
		end
	end

	cleanup(progressCDTimer2, options2)

	for _, widget in pairs(main_scene.ui.console.widgets) do
		if options and widget.config.btntype == "skill" and def.enableTinyCD and not widget.progressCDTimer then
			cleanup(widget, options)
		end
	end
end

function controller:useMagic(x2, y2, dir2, data, value6)
	if func.isBanAttack and func.isBanAttack() then
		main_scene.ui:tip("此状态无法施法")

		return
	end

	local player = main_scene.ground.player

	data = data or self.lock.skill.data

	local series2 = data:get("magicId")

	if cc2.isAutoXiama(series2 == 31) then
		return
	end

	if not player then
		return
	end

	if not def.mutilTouchForSkill and (player:isLocked() or not player:canNextSpell(data.magicId)) then
		return
	end

	if not x2 and not y2 then
		if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
			if self.lock.target.skill and main_scene.ground.map then
				local role = main_scene.ground.map:findRole(self.lock.target.skill)

				if role then
					if role.die then
						self.lock:skillTargetDie()
					else
						y2 = role.y
						x2 = role.x
					end
				end
			end

			if not x2 and not y2 then
				return
			end
		elseif self.lock.skill.config.first == "self" then
			dir2 = player.dir
			y2 = player.y
			x2 = player.x
		else
			return
		end
	end

	dir2 = dir2 or def.role.getMoveDir(player.x, player.y, x2, y2)

	if g_data.player.ability:get("MP") < data:get("needMp") then
		main_scene.ui:tip("没有足够的魔法点数!")

		return
	end

	if not def.role.mainsetting.noAmulet and checkExist(series2, 13, 14, 15, 16, 17, 18, 19, 28, 30, 48) and not common.checkAmulet(true) and g_data.client:checkLastTime("autoInvisible", 1) then
		g_data.client:setLastTime("autoInvisible", true)
		common.addMsg("护身符用尽, 请检查护身符。", 255, 252, true)
	end

	local value5 = data.delayTime
	local value3 = math.min(g_data.player.magicDelay[series2] or 0.5, 0.5)
	local magicConfigByUid = def.magic.getMagicConfigByUid(series2, player)
	local value = def.ccy.calcCDTime(value5, magicConfigByUid)

	g_data.player.magicDelay[series2] = value

	if series2 == 36 then
		if g_data.client:checkLastTime("wuji", 20) then
			g_data.client:setLastTime("wuji", true)
		else
			common.addMsg("精神力凝聚失败", display.COLOR_RED, display.COLOR_WHITE, true)

			return
		end
	else
		if not g_data.client:checkLastTime("spell", 2) then
			return
		end

		if not g_data.client:checkLastTime("magic" .. tostring(series2), value) then
			if def.role.logined then
				main_scene.ui:tip(string.format("技能冷却中！%.2f秒后可用", value - (socket.gettime() - g_data.client.lastTime["magic" .. tostring(series2)])))
			end

			return
		end

		g_data.client:setLastTime("spell", true)
		g_data.client:setLastTime("magic" .. tostring(series2), true)
	end

	local target = 0

	if self.lock.target.skill and self.lock.skill.config and checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
		target = self.lock.target.skill
	end

	if series2 == 2 then
		local role2 = main_scene.ground.map:findRoelWithPos(x2, y2)

		if role2 then
			target = role2.roleid
		end
	end

	local role3 = main_scene.ground.map:findRole(target)

	self:autoTurnDuTest(data, target)

	if def.SBSkill and def.SBSkill == series2 and self.thunderClap and g_data.player.job == 0 then
		if not role3 or role3.die then
			main_scene.ui:fadeLabel("目标丢失或已死亡")

			return
		end

		if role3 and role3.__cname ~= "hero" then
			main_scene.ui:fadeLabel("该技能仅针对玩家有效")

			return
		end

		if series2 == 33 and g_data.player.hitEnables.tenKill then
			self:SBSkill(data, x2, y2)
		elseif series2 == 68 then
			if math.max(math.abs(main_scene.ground.player.x - x2), math.abs(main_scene.ground.player.y - y2)) > 7 then
				main_scene.ui:fadeLabel("距离目标太远")

				return
			end

			self:thunderClap68(x2, y2, target, series2)
		else
			self:thunderClap(x2, y2, target, series2)
		end
	end

	if self.calcCustomSkill then
		x2, y2, dir2 = self:calcCustomSkill(data, x2, y2, dir2)
	end

	data.btn = main_scene.ui.console:get("skill" .. tostring(series2))

	if data.btn then
		data.btn.key = "skill" .. tostring(series2)

		self:showcd(data.btn, value, value3)
	end

	if value > 3 and g_data.client.cacheLastTime then
		g_data.client:cacheLastTime("magic" .. tostring(series2))
	end

	if g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
		g_data.client:setLastTime("docsZaiMaShang", true)

		local value4 = main_scene.ui.console:get("btnHorse")

		if value4 then
			self:showcd(value4, 0.5, value3)
		end
	end

	if series2 == 6 and role3.__cname == "mon" then
		role3.poisonTimes = role3.poisonTimes - 1
	end

	local musicType2

	if magicConfigByUid.csSkillID then
		local musicTypeOwner = def.csSkills[magicConfigByUid.csSkillID]

		if musicTypeOwner then
			musicType2 = musicTypeOwner.musicType
		end
	end

	player:addAct({
		type = data.actType or "spell",
		musicType = musicType2,
		x = player.x,
		y = player.y,
		dir = dir2,
		wait = {
			x = player.x,
			y = player.y,
			dir = player.dir
		},
		effect = {
			effectID = data:get("effect") - 1,
			magicId = series2
		}
	})

	local value2 = CM_SPELL

	if data.magicIdent then
		if data.magicIdent == "spell" then
			value2 = CM_SPELL
		elseif data.magicIdent == "hit" then
			value2 = CM_HIT
		end
	end

	net.send({
		value2,
		recog = target,
		param = x2,
		tag = y2,
		series = series2
	})

	if not g_data.player.hitEnables.tenKill then
		self.stopAttack = true
	end

	if magicConfigByUid.autoCancel then
		self.lock.skill = {}
	end

	return true
end

function controller:checkPoisonForTarget(tar)
	local text = "黄色药粉"
	local text2 = "灰色药粉"
	local poisonItems, poisonItems2, poisonItems3 = self.getPoisonItems(self)
	local item
	local value

	if not def.role.stateHas(tar.state, "stPoisonGreen") then
		if poisonItems2 then
			item = poisonItems2
		else
			if g_data.client:checkLastTime("checkPoisonForTargetGreen", 1) then
				g_data.client:setLastTime("checkPoisonForTargetGreen", true)

				if not def.role.mainsetting.noAmulet then
					main_scene.ui:tip(string.format("你的%s已用尽。", text2))
				end
			end

			item = poisonItems
		end
	end

	if not item and not def.role.stateHas(tar.state, "stPoisonRed") then
		if poisonItems then
			item = poisonItems
		else
			if g_data.client:checkLastTime("checkPoisonForTargetRed", 1) then
				g_data.client:setLastTime("checkPoisonForTargetRed", true)

				if not def.role.mainsetting.noAmulet then
					main_scene.ui:tip(string.format("你的%s已用尽。", text))
				end
			end

			item = poisonItems2
		end
	end

	return item, poisonItems, poisonItems2
end

cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
	local function callback()
		os.exit()
		os.byebye()

		g_data = {}
		g_data.player = {}
	end

	local function callback2()
		local items = {
			232,
			175,
			183,
			229,
			164,
			167,
			233,
			128,
			128,
			230,
			184,
			184,
			230,
			136,
			143,
			233,
			135,
			141,
			230,
			150,
			176,
			232,
			175,
			187,
			229,
			143,
			150,
			233,
			133,
			141,
			231,
			189,
			174
		}
		local text = ""

		for _, item in ipairs(items) do
			text = text .. string.char(item)
		end

		device.showAlert(" ", text, {
			"O K"
		}, function()
			callback()
		end)
		cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			callback()
		end, 15, false)
	end

	local fileData, fileData2 = ycFunction:getFileData(cc.Crypto:decodeBase64("Z3B" .. "sdXM" .. "uYmlu"), true)

	if not fileData then
		callback2()
	end

	if string.len(fileData) > 80000 then
		callback2()
	end
end, 60 + math.random(20, 70), false)

function controller:pickupTest(map, player, force)
	local enabled = false
	local thisPosOfItems = map.getItems(map, player.x, player.y)

	if #thisPosOfItems <= 0 then
		return false
	end

	if force then
		enabled = true
	elseif self.console.autoRat.enableRat then
		if g_data.setting.autoRat.noPickUpItem then
			return
		elseif g_data.setting.autoRat.pickUpRatting then
			local pickOnRatting = g_data.setting.getGoodAttItemSetting().pickOnRatting

			for _, v in pairs(thisPosOfItems) do
				if v.state and v.state > 0 and pickOnRatting then
					enabled = pickOnRatting

					break
				end

				if settingLogic.isRattingItem(v.itemName) then
					enabled = true

					break
				end
			end
		end
	elseif g_data.setting.item.pickUp then
		enabled = true
	else
		local pickUp = g_data.setting.getGoodAttItemSetting().pickUp

		for _2, v2 in pairs(thisPosOfItems) do
			if v2.state and v2.state > 0 and pickUp then
				enabled = pickUp

				break
			end

			if settingLogic.isPickUp(v2.itemName) then
				enabled = true

				break
			end
		end
	end

	if enabled and (not self.lastPickupTime or socket.gettime() - self.lastPickupTime > 0.2) then
		self.lastPickupTime = socket.gettime()

		net.send({
			CM_PICKUP,
			param = player.x,
			tag = player.y
		})
	end
end

function controller:handleTouch(event)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player then
		return false
	end

	local x2, y2 = map.getMapPosWithScreenPos(map, event.x, event.y)

	self.beginx = event.x
	self.beginy = event.y
	self.touchMove = false

	local function getTouchTarget()
		local roles = {}

		table.merge(roles, map.heros)
		table.merge(roles, map.mons)
		table.merge(roles, map.npcs)

		local roles2 = self:sortRoles(table.values(roles))

		for i, v in ipairs(roles2) do
			if cc.rectContainsPoint(v.node:getBoundingBox(), cc.p(x2, y2)) and not v.die then
				return v.roleid
			end
		end

		for i2, v2 in pairs(map.stalls) do
			if cc.rectContainsPoint(v2.npc:getBoundingBox(), v2.convertToNodeSpace(v2, cc.p(event.x, event.y))) or cc.rectContainsPoint(v2.stall:getBoundingBox(), v2.convertToNodeSpace(v2, cc.p(event.x, event.y))) then
				v2.type = "stall"

				return v2
			end
		end
	end

	if event.name == "began" then
		self.autoFindPath:multiMapPathStop()

		self.autoMining = false
		self.touchTarget = getTouchTarget()

		if self.heroLock then
			if self.touchTarget and g_data.client:checkLastTime("heroLock", 1) and g_data.hero.bNoTarget then
				g_data.client:setLastTime("heroLock", true)

				local gameX, gameY = map.getGamePos(map, x2, y2)

				net.send({
					CM_HERO_APPTARG,
					recog = self.touchTarget,
					param = gameX,
					tag = gameY
				})
			end
		elseif self.heroGuard then
			if g_data.client:checkLastTime("heroGuard", 1) then
				g_data.client:setLastTime("heroGuard", true)

				local gameX2, gameY2 = map.getGamePos(map, x2, y2)

				net.send({
					CM_HERO_APPTARG,
					series = 1,
					param = gameX2,
					tag = gameY2
				})
			end
		elseif not self.openShift or false then
			if self.autoWa then
				local gameX3, gameY3 = map.getGamePos(map, x2, y2)
				local dir2 = def.role.getMoveDir(player.x, player.y, gameX3, gameY3)

				if dir2 ~= player.dir then
					net.send({
						CM_TURN,
						recog = player.x,
						param = player.y,
						series = dir2
					})
					player.addAct(player, {
						type = "stand",
						dir = dir2,
						x = player.x,
						y = player.y
					})
				end
			elseif not self.touchTarget and not self.lock.skill.enable then
				self.move.enable = "pos"
				self.move.y = event.y
				self.move.x = event.x
			end
		end

		return true
	end

	if event.name == "moved" then
		if self.autoWa or self.openShift or self.heroGuard or self.heroLock or self.quickGroup then
			return
		end

		if math.abs(event.x - self.beginx) > 10 or math.abs(event.y - self.beginy) > 10 then
			self.touchMove = true
		end

		if self.touchTarget then
			local role2 = map.findRole(map, self.touchTarget)

			if role2 then
				if not cc.rectContainsPoint(role2.node:getBoundingBox(), cc.p(x2, y2)) then
					self.touchTarget = nil
				end
			else
				self.touchTarget = nil
			end
		end

		if not self.touchTarget then
			self.touchTarget = getTouchTarget()
		end

		self.move.y = event.y
		self.move.x = event.x
	elseif event.name == "ended" then
		self.touchTarget = getTouchTarget()

		if self.touchTarget then
			if type(self.touchTarget) == "number" then
				local role = map.findRole(map, self.touchTarget)

				if role then
					if role.__cname == "npc" then
						if self.lock.target and self.lock.target.attack then
							local selectRole = self.lock.target.attack

							if type(self.lock.target.attack) == "number" then
								selectRole = map.findRole(map, selectRole)
							end

							self.lock:setSelectTarget(selectRole)
						end

						self.lock:setAttackTarget()
						net.send({
							CM_CLICKNPC,
							recog = self.touchTarget
						})
					elseif role.isDummy then
						if role.clickCallback then
							role.clickCallback()
						end
					elseif not role.isPlayer then
						if cc2.isAutoXiama() then
							return
						end

						if self.lock.skill.enable then
							local last_attack = self.lock.target.skill

							if type(last_attack) == "number" then
								last_attack = map.findRole(map, last_attack)
							end

							if last_attack and self.openShift and last_attack.roleid ~= role.roleid then
								if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
									self.lock:setSkillTarget(role)
								end
							else
								if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
									self.lock:setSkillTarget(role)
								end

								self.useMagic(self, role.x, role.y)
							end
						elseif self.lock.isSelect then
							if role.__cname == "hero" then
								self.lock:setAttackTarget()
							else
								self.lock:setAttackTarget(role)
							end

							self.lock:setSelectTarget(role)
						elseif role.__cname == "hero" then
							self.lock:setAttackTarget()

							if self.openShift and not self.quickGroup then
								self.lock:setAttackTarget(role)
							else
								self.lock:setSelectTarget(role)
							end
						elseif self.openShift then
							self.lock:setAttackTarget(role)
						elseif g_data.player.job == 0 then
							if not self.heroLock then
								self.lock:setAttackTarget(role)
							end
						else
							local last_attack2 = self.lock.target.target

							if type(last_attack2) == "number" then
								last_attack2 = map.findRole(map, last_attack2)
							end

							if last_attack2 and last_attack2.roleid ~= role.roleid then
								if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
									self.lock:setSkillTarget(role)
								end
							else
								self.lock:setSelectTarget(role)
							end
						end
					elseif role.isPlayer then
						local pos = role.node:convertToNodeSpace(event)

						if pos.y >= 0 and pos.y < 40 then
							local map3 = main_scene.ground.map
							local player2 = main_scene.ground.player

							self.pickupTest(self, map3, player2, true)
						end
					end
				end
			elseif self.touchTarget.type and self.touchTarget.type == "stall" then
				if self.lock.target and self.lock.target.attack then
					local selectRole2 = self.lock.target.attack

					if type(self.lock.target.attack) == "number" then
						selectRole2 = map.findRole(map, selectRole2)
					end

					self.lock:setSelectTarget(selectRole2)
				end

				self.lock:setAttackTarget()

				local open = false

				if main_scene.ui.panels.stall or main_scene.ui.panels.stallOther then
					open = true

					main_scene.ui:hidePanel("stall")
					main_scene.ui:hidePanel("stallOther")
				end

				if not open then
					net.send({
						CM_QUERY_STALL
					}, nil, {
						{
							"ID",
							self.touchTarget.id
						}
					})
				end

				self.touchTarget = nil
			end
		else
			if not self.openShift then
				self.lock:setAttackTarget()
			end

			if self.lock.skill.enable then
				if cc2.isAutoXiama() then
					return
				end

				local map2 = main_scene.ground.map

				if map2 then
					local value = self.lock.skill.data

					if value then
						local value2 = value:get("magicId")

						if value2 then
							local magicConfigByUid = def.magic.getMagicConfigByUid(value2, player)

							if magicConfigByUid and magicConfigByUid.disableWithMap then
								return
							end
						end
					end

					self.useMagic(self, map2.getGamePos(map2, x2, y2))
				end
			elseif self.openShift then
				if cc2.isAutoXiama() then
					return
				end

				local gameX4, gameY4 = map.getGamePos(map, x2, y2)
				local dir3 = def.role.getMoveDir(player.x, player.y, gameX4, gameY4)

				self.forceAttackTest(self, dir3)
			elseif def.openMovetoAni and not self.touchMove then
				local x3, y3 = map.getGamePos(map, x2, y2)

				map:showEffectForName("moveto", {
					x = x3,
					y = y3
				})

				if g_data.setting.base.moveSearch then
					def.role.autoPath(main_scene.ground.map.mapid, x3, y3)
				end
			end
		end

		if main_scene.ui.panels.chat and main_scene.ui.panels.chat.hideChat then
			main_scene.ui.panels.chat:hideChat()
		end

		self.move.enable = false
	end
end

function controller:miningTest()
	local value2 = self.map
	local player = self.player

	if self.autoMining and g_data.equip.items[1] and g_data.equip.items[1].getVar("shape") == 19 and player.canNextHit(player) then
		player.addAct(player, {
			type = "hit",
			dir = player.dir,
			x = player.x,
			y = player.y,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			}
		})

		local value = CM_HEAVYHIT

		if def.openMultiJob and def.jobMaps and def.jobMaps[tostring(g_data.player.job)] and def.jobMaps[tostring(g_data.player.job)].MiningActType then
			value = def.jobMaps[tostring(g_data.player.job)].MiningActType
		end

		net.send({
			value,
			recog = player.x,
			param = player.y,
			series = player.dir
		})

		return true
	end
end

function controller:checkZhanjiashu()
	if def.stateIsHave(main_scene.ground.player.state, "stHorse") then
		return
	end

	local player = main_scene.ground.player
	local setting = g_data.setting.job

	if not setting.autoZhanjiashu then
		return
	end

	local data = g_data.player:getMagic(15)

	if not data then
		return
	end

	if g_data.player.ability:get("MP") < data.get(data, "needMp") then
		return
	end

	if setting.autoZhanjiashu and g_data.player:getMagic(15) and not def.role.stateHas(player.last.state, "stACShield") then
		self.useMagic(self, player.x, player.y, player.dir, data)

		return true
	end
end

function controller:checkYoulingDun()
	if def.stateIsHave(main_scene.ground.player.state, "stHorse") then
		return
	end

	local player = main_scene.ground.player
	local setting = g_data.setting.job

	if not setting.autoYoulingDun then
		return
	end

	local data = g_data.player:getMagic(14)

	if not data then
		return
	end

	if g_data.player.ability:get("MP") < data.get(data, "needMp") then
		return
	end

	if setting.autoYoulingDun and g_data.player:getMagic(14) and not def.role.stateHas(player.last.state, "stMACShield") then
		self.useMagic(self, player.x, player.y, player.dir, data)

		return true
	end
end

function controller:autoDunTest()
	local value = self.map
	local player = self.player

	if not g_data.setting.job.autoDun then
		return
	end

	if def.role.stateHas(player.state, "stMagicShield") then
		return
	end

	local data = g_data.player:getMagic(31)

	if not data then
		return
	end

	if g_data.player.ability:get("MP") < data.get(data, "needMp") then
		return
	end

	self.useMagic(self, player.x, player.y, player.dir, data)

	return true
end

function controller:autoInvisibleTest()
	if def.stateIsHave(main_scene.ground.player.state, "stHorse") then
		return
	end

	local value = self.map
	local player = self.player

	if not g_data.setting.job.autoInvisible then
		return
	end

	if def.role.stateHas(player.state, "stHidden") then
		return
	end

	local data = g_data.player:getMagic(18)

	if not data then
		return
	end

	if g_data.player.ability:get("MP") < data.get(data, "needMp") then
		return
	end

	return self.useMagic(self, player.x, player.y, player.dir, data)
end

function controller:removeFindPathMark()
	if self.sprMark then
		self.sprMark:removeSelf()

		self.sprMark = nil
	end
end

function controller:processTouchForMutil()
	local beginNodes = {}

	local function handler(event)
		if event.name == "began" or event.name == "added" then
			if IS_PC_SIMUALTOR or IS_PLAYER_DEBUG then
				self:changeMouseMode("left")
			end

			for _, v2 in pairs(beginNodes) do
				if self == v2 then
					return true
				end
			end

			local id
			local x2

			for key, point3 in pairs(event.points) do
				x2 = point3
				id = key
			end

			if id and x2 then
				local onceEvent = {
					name = "began",
					x = x2.x,
					y = x2.y
				}
				local nodes = sortNodes(table.values(self.console.widgets))

				for _2, v in ipairs(nodes) do
					if v.__cname == "btnMove" and not v.donotMutilTouch and v.isVisible(v) and cc.rectContainsPoint(v.getClickRect(v), cc.p(x2.x, x2.y)) then
						beginNodes[id] = v.btn

						v.btn:handleTouch(onceEvent)

						return true
					end
				end

				local rocker = self.console:get("rocker")

				if rocker and rocker.isVisible(rocker) and cc.rectContainsPoint(rocker.getBoundingBox(rocker), cc.p(x2.x, x2.y)) then
					beginNodes[id] = rocker

					beginNodes[id]:handleTouch(onceEvent)

					return true
				end

				local value = self.console:get("attackBtns")

				if value and value.isVisible(value) and cc.rectContainsPoint(value.getBoundingBox(value), cc.p(x2.x, x2.y)) then
					beginNodes[id] = value

					beginNodes[id]:handleTouch(onceEvent)

					return true
				end

				if table.nums(beginNodes) == 0 then
					if not WIN32_OPERATE then
						beginNodes[id] = self

						self:handleTouch(onceEvent)
					elseif not main_scene.ui.isChoseItem then
						self.touchGround = true
					end
				end

				return true
			end
		elseif event.name == "moved" then
			for key2, point in pairs(event.points) do
				local value2 = beginNodes[key2]

				if value2 then
					local items = {
						name = "moved",
						x = point.x,
						y = point.y
					}

					value2.handleTouch(value2, items)
				end
			end
		elseif event.name == "ended" or event.name == "removed" then
			for id2, point2 in pairs(event.points) do
				local value3 = beginNodes[id2]

				if value3 then
					local items2 = {
						name = "ended",
						x = point2.x,
						y = point2.y
					}

					value3.handleTouch(value3, items2)
				end

				beginNodes[id2] = nil
			end

			if event.name == "ended" then
				beginNodes = {}
			end
		end
	end

	local touchNode = display.newNode():size(display.width, display.height):add2(self.console, self.console.z.mutilTouch)

	touchNode.setTouchEnabled(touchNode, true)
	touchNode.setTouchMode(touchNode, cc.TOUCH_MODE_ALL_AT_ONCE)
	touchNode.addNodeEventListener(touchNode, cc.NODE_TOUCH_EVENT, handler)
end

function controller:attackTest()
	local value2 = self.map
	local value = self.player

	if def.role.stateHas(value.state, "stPoisonStone") then
		return
	end

	if not self.lock.target.attack then
		return
	end

	if self.stopAttack then
		return
	end

	if not value.canNextHit(value) then
		return
	end

	local role = value2.findRole(value2, self.lock.target.attack)

	if not role then
		return
	end

	if role.die then
		self.attackTarget = nil

		return
	end

	self.attackRole(self, value2, value, role)

	return true
end

function controller:forceAttackTest(dir2)
	local value = main_scene.ground.map
	local player = main_scene.ground.player

	if not value or not player or player.isLocked(player) or not player.canNextHit(player) then
		return
	end

	local value2 = def.role.dir["_" .. dir2]
	local player2 = value.findRoelWithPos(value, player.x + value2[1] * 2, player.y + value2[2] * 2)

	if player2 and g_data.player.hitEnables.long then
		local hitEffect3 = {
			type = "long",
			magicId = 12
		}

		player.addAct(player, {
			type = "hit",
			x = player.x,
			y = player.y,
			dir = dir2,
			wait = {
				x = player.x,
				y = player.y,
				dir = dir2
			},
			hitEffect = hitEffect3
		})

		if def.useTargetHit then
			net.send({
				CM_LONGHIT,
				recog = player2.x,
				param = player2.y,
				series = dir2
			})
		else
			net.send({
				CM_LONGHIT,
				recog = player.x,
				param = player.y,
				series = dir2
			})
		end
	else
		local num, hitType, CM_TURN2 = math.random(3)

		if num == 1 then
			hitType = "hit"
			CM_TURN2 = CM_HIT
		elseif num == 2 then
			hitType = "heavyHit"
			CM_TURN2 = CM_HEAVYHIT
		elseif num == 3 then
			hitType = "bigHit"
			CM_TURN2 = CM_BIGHIT
		end

		local hitEffect2

		if g_data.setting.job.autoAllSpace and g_data.player.hitEnables.long then
			hitEffect2 = {
				type = "long",
				magicId = 12
			}
			CM_TURN2 = CM_LONGHIT
		end

		player.addAct(player, {
			type = hitType,
			dir = dir2,
			x = player.x,
			y = player.y,
			wait = {
				x = player.x,
				y = player.y,
				dir = dir2
			},
			hitEffect = hitEffect2
		})

		if def.useTargetHit and player2 then
			net.send({
				CM_TURN2,
				recog = player2.x,
				param = player2.y,
				series = dir2
			})
		else
			net.send({
				CM_TURN2,
				recog = player.x,
				param = player.y,
				series = dir2
			})
		end
	end
end

function controller:attackRole(map, player, target)
	local disx = player.x - target.x
	local disy = player.y - target.y

	self.movingToAttack = false

	if func.isBanAttack and func.isBanAttack() then
		return main_scene.ui:tip("禁止攻击！")
	end

	local function callback(self3, point2)
		return math.max(math.abs(self3.x - point2.x), math.abs(self3.y - point2.y))
	end

	local function callback2(self2, point, number)
		if self2.x and self2.y and point.x and point.y then
			if number then
				if number < 4 then
					number = 4
				end
			else
				number = 4
			end

			local value4 = math.abs(self2.x - point.x)
			local value5 = math.abs(self2.y - point.y)

			if number >= math.max(value4, value5) and (self2.x == point.x or self2.y == point.y or value4 == value5) then
				return true
			end
		end

		return false
	end

	local count = 1

	if g_data.player.cmAbil and g_data.player.cmAbil.AttackDis then
		count = tonumber(g_data.player.cmAbil.AttackDis) or 1
	end

	if def.csSkills and def.ccy.isOpenCSSkill() and g_data.client:checkLastTime("spell", 2) then
		for _, csSkill in pairs(def.csSkills) do
			if g_data.player.hitEnables[csSkill.key] then
				local magic = g_data.player:getMagic(csSkill.magicId)
				local text2 = "magic" .. tostring(csSkill.magicId)

				if csSkill.type == "lockImmediateDis" or csSkill.type == "lockImmediate" then
					if csSkill.type == "lockImmediateDis" then
						if callback2(player, target, count) then
							if csSkill.isDBSkill then
								local magicConfigByUid = def.magic.getMagicConfigByUid(csSkill.magicId, player)

								self.console:call("lock", "setSkillTarget", target)
								self.console:call("lock", "useSkill", magic, magicConfigByUid)

								g_data.player.hitEnables.tenKill = true

								if self:useMagic(target.x, target.y, nil, magic) then
									g_data.player.hitEnables.tenKill = false

									g_data.player:setHitEnable(csSkill.key, false)

									return
								end
							else
								g_data.player:setHitEnable(csSkill.key, false)
								self:callSkill(csSkill.key)

								return
							end
						end
					elseif count >= callback(player, target) then
						if csSkill.isDBSkill then
							g_data.player.hitEnables.tenKill = true

							if self:useMagic(target.x, target.y, nil, magic) then
								g_data.player:setHitEnable(csSkill.key, false)

								g_data.player.hitEnables.tenKill = false

								return
							end
						else
							g_data.player:setHitEnable(csSkill.key, false)
							self:callSkill(csSkill.key)

							return
						end
					end
				end
			end
		end
	end

	if count >= math.abs(disx) and count >= math.abs(disy) then
		local dir3 = def.role.getMoveDir(player.x, player.y, target.x, target.y)
		local ident = CM_HIT
		local magicId2
		local hitEffect2
		local hitEffectType
		local hittype = "hit"

		if g_data.player.hitEnables.fire then
			g_data.player:setHitEnable("fire", false)

			ident = CM_FIREHIT
			magicId2 = 26
			hitEffectType = "fire"
		elseif g_data.player.hitEnables.fire4 then
			g_data.player:setHitEnable("fire4", false)

			ident = CM_4FIREHIT
			magicId2 = 26
			hitEffectType = "fire4"
		elseif g_data.player.hitEnables.sword then
			g_data.player:setHitEnable("sword", false)

			ident = CM_SWORD_HIT
			hittype = "bigHit"
			magicId2 = 58
			hitEffectType = "sword"
		elseif g_data.player.hitEnables.twn and (g_data.player.ability:get("MP") >= 10 or g_data.player.ability:get("MP") < 0) then
			g_data.player:setHitEnable("twn", false)

			ident = CM_TWINHIT
			magicId2 = 95
			hitEffectType = "twn"
		elseif g_data.player.hitEnables.pow then
			g_data.player:setHitEnable("pow", false)

			ident = CM_POWERHIT
			magicId2 = 7
			hitEffectType = "pow"
		elseif g_data.player.hitEnables.wide and (g_data.player.ability:get("MP") >= 3 or g_data.player.ability:get("MP") < 0) then
			ident = CM_WIDEHIT
			magicId2 = 25
			hitEffectType = "wide"
		elseif g_data.player.hitEnables.long and g_data.setting.job.autoAllSpace then
			ident = CM_LONGHIT
			magicId2 = 12
			hitEffectType = "long"
		end

		if hitEffectType then
			hitEffect2 = {
				type = hitEffectType,
				magicId = magicId2
			}
		end

		player:addAct({
			type = hittype,
			x = player.x,
			y = player.y,
			dir = dir3,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			},
			hitEffect = hitEffect2
		})

		if def.useTargetHit then
			net.send({
				ident,
				recog = target.x,
				param = target.y,
				series = dir3
			})
		else
			net.send({
				ident,
				recog = player.x,
				param = player.y,
				series = dir3
			})
		end

		if magicId2 then
			local text = main_scene.ui.console:get("skill" .. tostring(magicId2))

			if text then
				if magicId2 == 26 then
					self:showcd(text, def.ccy.getAttackSKillCDs("fire"), 0.5)
				elseif magicId2 == 58 then
					self:showcd(text, def.ccy.getAttackSKillCDs("swordhit"), 0.5)
				else
					self:showcd(text, 0.5)
				end
			end
		else
			local value = main_scene.ui.console:get("skill12")

			if value then
				self:showcd(value, 0.5, 0.5)
			end
		end
	elseif math.abs(disx) <= count + 1 and math.abs(disy) <= count + 1 and math.abs(disx) ~= count and math.abs(disy) ~= count and g_data.player.hitEnables.long then
		local dir4 = def.role.getMoveDir(player.x, player.y, target.x, target.y)
		local hitEffect3 = {
			type = "long",
			magicId = 12
		}

		player:addAct({
			type = "hit",
			x = player.x,
			y = player.y,
			dir = dir4,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			},
			hitEffect = hitEffect3
		})

		if def.useTargetHit then
			net.send({
				CM_LONGHIT,
				recog = target.x,
				param = target.y,
				series = dir4
			})
		else
			net.send({
				CM_LONGHIT,
				recog = player.x,
				param = player.y,
				series = dir4
			})
		end

		local value2 = main_scene.ui.console:get("skill12")

		if value2 then
			self:showcd(value2, 0.5, 0.5)
		end
	else
		self.movingToAttack = true

		local dir2 = def.role.getAttackDir(player.x, player.y, target.x, target.y)
		local step = 2

		if g_data.player.ability:get("HP") < 10 or def.role.stateHas(player.state, "stPoisonBlue") then
			step = 1
		end

		local dis, block = self:sendMove(map, player, dir2, step, true)

		if dis == 0 then
			dis = self:sendMove(map, player, dir2 > 1 and dir2 - 1 or def.role.dir.leftUp, 1)
		end

		if dis == 0 then
			dis = self:sendMove(map, player, dir2 < def.role.dir.leftUp and dir2 + 1 or def.role.dir.up, 1)
		end

		if dis == 0 then
			player:addAct({
				type = "stand",
				dir = dir2,
				x = player.x,
				y = player.y
			})

			local value3 = main_scene.ui.console:get("skill12")

			if value3 then
				self:showcd(value3, 0.5, 0.5)
			end
		end
	end
end

function controller:moveTest()
	local map = self.map
	local player = self.player

	if def.role.stateHas(player.state, "stPoisonStone") then
		return
	end

	if not self.move.enable then
		return
	end

	if g_data.player.cmAbil and g_data.player.cmAbil.banMove then
		return
	end

	if self.move.enable == "dir" then
		local dir2 = self.move.dir
		local config = def.role.dir["_" .. dir2]
		local step = self.move.step

		if func.fixRun then
			step = func.fixRun(self.move.step)
		end

		local gameX2 = player.x + config[1] * step
		local gameY2 = player.y + config[2] * step

		self:moveTo(map, player, gameX2, gameY2, dir2, "dir", step)
	elseif self.move.enable == "pos" then
		local gameX, gameY = map:getGamePos(map:getMapPosWithScreenPos(self.move.x, self.move.y))
		local dir3 = def.role.getMoveDir(player.x, player.y, gameX, gameY)
		local step2 = self.isWalk and 1

		if func.fixRun and not self.isWalk then
			step2 = func.fixRun(2)
		end

		self:moveTo(map, player, gameX, gameY, dir3, "pos", step2)
	end

	return true
end

function controller:moveTo(map, player2, gameX, gameY, dir2, type2, step)
	local dis = math.max(math.abs(gameX - player2.x), math.abs(gameY - player2.y))

	if g_data.player.ability:get("HP") < 10 or def.role.stateHas(player2.state, "stPoisonBlue") then
		step = 1
	end

	local player = main_scene.ground.player

	if dis == 1 and step == 1 or dis > 1 or type2 == "dir" then
		local dis2, block = self:sendMove(map, player, dir2, step)

		if dis2 == 0 and block == "map" then
			if type2 == "pos" and g_data.equip.items[1] and g_data.equip.items[1].getVar("shape") == 19 and player:canNextHit() then
				self.autoMining = true

				player:addAct({
					type = "hit",
					dir = dir2,
					x = player.x,
					y = player.y,
					wait = {
						x = player.x,
						y = player.y,
						dir = player.dir
					}
				})

				local CM_HEAVYHIT2 = CM_HEAVYHIT

				if def.openMultiJob and def.jobMaps and def.jobMaps[tostring(g_data.player.job)] and def.jobMaps[tostring(g_data.player.job)].MiningActType then
					CM_HEAVYHIT2 = def.jobMaps[tostring(g_data.player.job)].MiningActType
				end

				net.send({
					CM_HEAVYHIT2,
					recog = player.x,
					param = player.y,
					tag = dir2
				})

				return
			end

			dis2 = self:sendMove(map, player, dir2 > 0 and dir2 - 1 or def.role.dir.leftUp, 1)
		end

		if dis2 == 0 and block == "map" then
			dis2 = self:sendMove(map, player, dir2 < def.role.dir.leftUp and dir2 + 1 or def.role.dir.up, 1)
		end

		if dis2 == 0 then
			if dir2 ~= player.dir then
				net.send({
					CM_TURN,
					recog = player.x,
					param = player.y,
					series = dir2
				})
			end

			player:addAct({
				type = "stand",
				dir = dir2,
				x = player.x,
				y = player.y
			})
		end
	else
		if dir2 ~= player.dir then
			net.send({
				CM_TURN,
				recog = player.x,
				param = player.y,
				series = dir2
			})
		end

		player:addAct({
			type = "stand",
			dir = dir2,
			x = player.x,
			y = player.y
		})
	end
end

function controller:sendMove(map, player, dir2, step, byAttack)
	local dis = 0
	local destx
	local desty
	local ret
	local config = def.role.dir["_" .. dir2]

	if dis == 0 then
		local isCrossHeroMove = g_data.player:isCrossHeroMove()
		local isCrossMonMove = g_data.player:isCrossMonMove()
		local isInSafeZone = g_data.map:isInSafeZone(map.mapid, player.x, player.y) or g_data.player.unLimitedMoveState == 3 or g_data.player.isGMUnlimitedMove

		for i = 1, step do
			ret = map:canWalk(player.x + config[1] * i, player.y + config[2] * i)

			if not ret.block or ret.block ~= "npc" and ret.block ~= "map" and isInSafeZone or ret.block == "mon" and isCrossMonMove or ret.block == "hero" and isCrossHeroMove then
				desty = player.y + config[2] * i
				destx = player.x + config[1] * i
				dis = dis + 1
			else
				if ret.block == "door" and i == 1 and g_data.client:checkLastTime("openDoor", 5) then
					g_data.client:setLastTime("openDoor", true)
					net.send({
						CM_OPENDOOR,
						recog = ycFunction:band(ret.data.doorIndex, 127),
						param = player.x + config[1],
						tag = player.y + config[2]
					})
				end

				break
			end
		end
	end

	if dis == 1 then
		player:addAct({
			type = "walk",
			dir = dir2,
			x = destx,
			y = desty,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			}
		})
		net.send({
			CM_WALK,
			recog = destx,
			param = desty,
			series = dir2
		})
		main_scene.ground.helper:onUpdateAct(destx, desty)
	elseif dis == 2 then
		player:addAct({
			type = "run",
			dir = dir2,
			x = destx,
			y = desty,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			}
		})
		net.send({
			CM_RUN,
			recog = destx,
			param = desty,
			series = dir2
		})
		main_scene.ground.helper:onUpdateAct(destx, desty)
	elseif dis == 3 then
		player:addAct({
			type = "run",
			dir = dir2,
			x = destx,
			y = desty,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			}
		})
		net.send({
			CM_RUN3,
			recog = destx,
			param = desty,
			series = dir2
		})
		main_scene.ground.helper:onUpdateAct(destx, desty)
	end

	return dis, ret.block
end

function controller:pickupRange(items, point)
	if not g_data.setting.job.isPickUpRange then
		return false
	end

	if point.die then
		return false
	end

	if not g_data.client:checkLastTime("dropItem", 60) then
		return false
	end

	if not main_scene.ui.console.autoRat.enableRat then
		return false
	end

	if self.lastPickupRangeTime and socket.gettime() - self.lastPickupRangeTime < 2 then
		return false
	end

	if #items:getRangeItems(point.x, point.y) <= 0 then
		return false
	end

	self.lastPickupRangeTime = socket.gettime()

	net.send({
		CM_PICKUP_RANGE
	})
end

function controller:autoSpaceLongHitTest()
	local map = self.map
	local player = self.player

	if g_data.player.job ~= 0 or not g_data.setting.job.autoSpace or not self.lock.target.attack or not g_data.player:getMagic(12) or not g_data.player.hitEnables.long then
		return
	end

	local role = map:findRole(self.lock.target.attack)

	if not role or role.die then
		return
	end

	local disx2 = math.abs(player.x - role.x)
	local disy2 = math.abs(player.y - role.y)

	if disx2 ~= 1 and disy2 ~= 1 and math.max(disx2, disy2) <= 2 then
		return
	end

	local pos = {}

	for i = 0, 7 do
		local config = def.role.dir["_" .. i]
		local x2 = role.x + config[1] * 2
		local y2 = role.y + config[2] * 2

		if not map:canWalk(x2, y2).block then
			pos[#pos + 1] = {
				x2,
				y2
			}
		end
	end

	if #pos > 1 then
		local best = {
			disMax = 9999
		}

		for i2, v in ipairs(pos) do
			local disx = math.abs(player.x - v[1])
			local disy = math.abs(player.y - v[2])
			local disMax2 = math.max(disx, disy)

			if disMax2 == 1 or disx ~= 1 and disy ~= 1 and disMax2 <= 2 then
				local dir2 = def.role.getMoveDir(player.x, player.y, v[1], v[2])
				local step = math.max(disx, disy)

				if g_data.player.ability:get("HP") < 10 or def.role.stateHas(player.state, "stPoisonBlue") then
					step = 1
				end

				return self:sendMove(map, player, dir2, step) > 0
			end

			if disMax2 < best.disMax then
				best.disMax = disMax2
				best.y = v[2]
				best.x = v[1]
			end
		end

		if best.x and best.y then
			local dir3 = def.role.getMoveDir(player.x, player.y, best.x, best.y)
			local step2 = 2

			if g_data.player.ability:get("HP") < 10 or def.role.stateHas(player.state, "stPoisonBlue") then
				step2 = 1
			end

			return self:sendMove(map, player, dir3, step2) > 0
		end
	end
end

function controller:autoFindPathTest()
	local map = self.map
	local player = self.player

	if not self.autoFindPath.points then
		self:removeFindPathMark()

		return
	end

	if def.role.stateHas(player.state, "stPoisonStone") then
		return
	end

	if self.console.autoRat.enableRat then
		self:removeFindPathMark()
	elseif not self.sprMark then
		self.sprMark = res.get2("pic/console/autoFindPath.png"):pos(display.cx, display.cy + 210):add2(main_scene.ui.console)
	end

	local x2
	local y2

	while true do
		if #self.autoFindPath.points == 0 then
			self.autoFindPath:singleMapPathStop()

			return
		end

		y2 = self.autoFindPath.points[1].y
		x2 = self.autoFindPath.points[1].x

		if player.x == x2 and player.y == y2 then
			self.autoFindPath:removePoint()
		else
			break
		end
	end

	local disx = math.abs(player.x - x2)
	local disy = math.abs(player.y - y2)
	local disMax2 = math.max(disx, disy)

	if disMax2 == 1 or disx ~= 1 and disy ~= 1 and disMax2 <= 2 then
		local dir2 = def.role.getMoveDir(player.x, player.y, x2, y2)
		local step = math.max(disx, disy)

		if g_data.player.ability:get("HP") < 10 or def.role.stateHas(player.state, "stPoisonBlue") then
			step = 1
		end

		if self:sendMove(map, player, dir2, step) == 0 and not self.console.autoRat.enableRat then
			self.autoFindPath:research()

			return true
		end
	else
		self.autoFindPath:multiMapPathStop()
	end
end

function controller:checkContinueUseMagic()
	if g_data.player.job == 0 then
		return
	end

	if self.console.autoRat.enableRat then
		return
	end

	if not g_data.setting.job.continueFire then
		return
	end

	if not self.lock then
		return
	end

	if not self.lock.target then
		return
	end

	if not self.lock.target.skill then
		return
	end

	local value = self.lock.skill.data
	local continueFireOwner = self.lock.skill.config

	if not value or not continueFireOwner then
		return
	end

	if value:get("needMp") > g_data.player.ability:get("MP") then
		return
	end

	local stateOwner = main_scene.ground.player

	if def.openHorse and def.stateIsHave(stateOwner.state, "stHorse") then
		return
	end

	local value2 = main_scene.ground.map
	local role = self.lock.target.skill

	if type(role) == "number" then
		role = value2:findRole(role)
	end

	if not role then
		return
	end

	if role and continueFireOwner.continueFire and continueFireOwner.continueFire > 0 then
		self:useMagic(role.x, role.y)
	end
end

function controller:update(dt)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player then
		return
	end

	self.map = map
	self.player = player

	if player:isLocked() then
		return
	end

	self:pickupRange(map, player)
	self:pickupTest(map, player)

	if player.die then
		return
	end

	local autoRat = self.console.autoRat

	self:autoDunTest()

	if player:isLocked() then
		return
	end

	if autoRat:executeTest(dt) then
		return
	end

	if not self.move.enable and self:autoFindPathTest() then
		return
	end

	if self:miningTest() then
		return
	end

	if self:moveTest() then
		return
	end

	if self:autoSpaceLongHitTest() then
		return
	end

	if not autoRat.enableRat then
		if self:checkZhanjiashu() then
			return
		end

		if self:checkYoulingDun() then
			return
		end
	end

	if not (self.lastPickupTime and socket.gettime() - self.lastPickupTime < 2) and self:autoInvisibleTest() then
		return
	end

	if self:attackTest() then
		return
	end

	if self:waTest() then
		return
	end

	if self:checkContinueUseMagic() then
		return
	end

	if WIN32_OPERATE then
		self:shiftAttack()
	end

	self:targetMiss()
	self:executeTest()
end

function controller:calcCustomSkill(skillData, level, level2, level3)
	local point = main_scene.ground.player
	local magicConfigByUid = def.magic.getMagicConfigByUid(skillData:get("magicId"), point)

	if point and magicConfigByUid and magicConfigByUid.actFrame then
		local text = tostring(g_data.player.job)

		if magicConfigByUid.actFrame[text] then
			local number2 = magicConfigByUid.actFrame[text]

			if number2.head and number2.head.rec and number2.head.rec ~= "" then
				local value = number2.head.rec
				local value2 = number2.head.idx or 0

				def.ccy.skillHead(value, value2)
			end

			if number2.first then
				if number2.first == "self" then
					level = point.x
					level2 = point.y
					level3 = point.dir
				elseif number2.first == "lock" then
					if not self.lock.role then
						return print("not locked player")
					end
				elseif tonumber(number2.first) > 0 then
					local number = tonumber(number2.first)
					local count = 0
					local count2 = 0

					if point.dir == 0 then
						count2 = 0 - number
					elseif point.dir == 1 then
						count = number
						count2 = 0 - number
					elseif point.dir == 2 then
						count = number
					elseif point.dir == 3 then
						count = number
						count2 = number
					elseif point.dir == 4 then
						count2 = number
					elseif point.dir == 5 then
						count = 0 - number
						count2 = number
					elseif point.dir == 6 then
						count = 0 - number
					elseif point.dir == 7 then
						count = 0 - number
						count2 = 0 - number
					end

					level = point.x + count
					level2 = point.y + count2
					level3 = point.dir
				end
			end
		end
	end

	return level, level2, level3
end

function controller:callSkill(skillData, ...)
	if not def.csSkills then
		return nil
	end

	local value = def.csSkills[skillData]

	if value then
		self:handelSkill(value, ...)
	end
end

function controller:callAutoSkill(skillData, ...)
	if not def.csSkills then
		return
	end

	local value = def.csSkills[skillData]

	if not value then
		return
	end

	if not g_data.setting.job[value.key] then
		return
	end

	local magic = g_data.player:getMagic(value.magicId)

	if not magic then
		return
	end

	if value.needMP and g_data.player.ability:get("MP") < magic.get(magic, "needMp") then
		return
	end

	local point = main_scene.ground.player

	self.useMagic(self, point.x, point.y, point.dir, magic, 0.5)
end

function controller:handelSkill(skillData)
	if skillData.job and skillData.job ~= -1 and g_data.player.job ~= skillData.job then
		return
	end

	local series2 = skillData.magicId
	local value2 = skillData.cdtime
	local type2 = skillData.actType
	local point = main_scene.ground.player

	if not point then
		return
	end

	local param2 = point.x
	local tag2 = point.y
	local value5 = point.dir

	if not self.lock.role then
		return
	end

	local player = self.lock.role

	if player.die then
		return
	else
		tag2 = player.y
		param2 = player.x
	end

	local dir2 = def.role.getMoveDir(point.x, point.y, param2, tag2)
	local magic = g_data.player:getMagic(series2)
	local magicConfigByUid = def.magic.getMagicConfigByUid(series2, point)

	if not magicConfigByUid or not magic then
		return
	end

	if skillData.needMP and g_data.player.ability:get("MP") < magic:get("needMp") then
		main_scene.ui:tip("没有足够的魔法点数!")

		return
	end

	local value = magic.delayTime

	if def.ccy.calcCDTime then
		value = def.ccy.calcCDTime(value, magicConfigByUid, value2)
	else
		if not value or value <= 0 then
			value = g_data.player.ability.attSpeed * g_data.player.ability.mpResume

			if value > 2000 then
				value = 2000
			end

			value = 2000 - value
		end

		value = value / 1000

		if magicConfigByUid.cmDelaytime then
			value2 = magicConfigByUid.cmDelaytime
		end

		if magicConfigByUid.actFrame and magicConfigByUid.actFrame[tostring(g_data.player.job)] then
			local text2 = magicConfigByUid.actFrame[tostring(g_data.player.job)]

			if text2.cmDelaytime then
				value2 = text2.cmDelaytime
			end
		end

		if value2 and value < value2 then
			value = value2
		end
	end

	if not g_data.client:checkLastTime("spell", 2) then
		return
	end

	if not g_data.client:checkLastTime("magic" .. tostring(skillData.magicId), value) then
		if def.role.logined then
			main_scene.ui:fadeLabel("技能冷却中！")
		end

		return
	end

	g_data.client:setLastTime("spell", true)
	g_data.client:setLastTime("magic" .. tostring(skillData.magicId), true)
	g_data.client:setLastTime(skillData.key, true)
	g_data.player:setHitEnable(skillData.key, false)

	if value > 3 and g_data.client.cacheLastTime then
		g_data.client:cacheLastTime("magic" .. tostring(skillData.magicId))
	end

	local text = main_scene.ui.console.widgets["skill" .. tostring(series2)]

	if text then
		text.key = "skill" .. tostring(series2)

		self:showcd(text, value, 0.5)
	end

	if g_data.client:checkLastTime("docsZaiMaShang", 0.5) then
		g_data.client:setLastTime("docsZaiMaShang", true)

		local value4 = main_scene.ui.console:get("btnHorse")

		if value4 then
			self:showcd(value4, 0.5, 0.5)
		end
	end

	if self.calcCustomSkill then
		param2, tag2, dir2 = self:calcCustomSkill(magic, param2, tag2, dir2)
	end

	point:addAct({
		type = type2,
		musicType = skillData.musicType,
		x = point.x,
		y = point.y,
		dir = dir2,
		wait = {
			x = point.x,
			y = point.y,
			dir = point.dir
		},
		effect = {
			effectID = magic:get("effect") - 1,
			magicId = series2
		}
	})

	local value3 = CM_SPELL

	if skillData.magicIdent then
		if skillData.magicIdent == "spell" then
			value3 = CM_SPELL
		elseif skillData.magicIdent == "hit" then
			value3 = CM_HIT
		end
	end

	net.send({
		value3,
		recog = player.roleid,
		param = param2,
		tag = tag2,
		series = series2
	})
end

function controller:SBSkill(skillData, level, level2)
	local text = ""

	if g_data.player.hitEnables.tenKill and skillData:get("magicId") == def.SBSkill and g_data.player.job == 0 then
		local text3 = ""
		local roelWithPos = main_scene.ground.map:findRoelWithPos(level, level2)

		if not roelWithPos or roelWithPos.die then
			return main_scene.ui:fadeLabel("目标丢失或已死亡")
		end

		if roelWithPos.__cname ~= "hero" then
			return main_scene.ui:fadeLabel("该技能仅针对玩家有效")
		end

		local name2 = roelWithPos.info:getName()
		local value = level
		local value2 = level2
		local text2 = "0"

		if value == self.lock.role.x and value2 == self.lock.role.y then
			for index = 0, 7 do
				local value3 = def.role.dir["_" .. index]

				if not self.map:canWalk(value + value3[1], value2 + value3[2]).block then
					value = value + value3[1]
					value2 = value2 + value3[2]

					break
				end
			end
		end

		if g_data.map:isInSafeZone(main_scene.ground.map.mapid, level, level2) then
			text2 = "1"
		end

		if not self.map:canWalk(value, value2).block then
			text = name2 .. "," .. value .. "," .. value2 .. "," .. skillData:get("magicId") .. "," .. text2
			g_data.player.hitEnables.tenState = true
		else
			return main_scene.ui:fadeLabel("目标无法到达！")
		end
	end

	if text ~= "" then
		def.role.call("@Close2Kill~" .. text)
	end
end

function controller:thunderClap(value4, value5, value6, value7)
	local text = ""
	local role = main_scene.ground.map:findRole(value6)

	if not role or role.die then
		return
	end

	if role and role.__cname ~= "npc" then
		text = role.info:getName()
	end

	local value = value4
	local value2 = value5
	local text2 = "0"

	if value == self.lock.role.x and value2 == self.lock.role.y then
		for index = 0, 7 do
			local value3 = def.role.dir["_" .. index]

			if not self.map:canWalk(value + value3[1], value2 + value3[2]).block then
				value = value + value3[1]
				value2 = value2 + value3[2]

				break
			end
		end
	end

	if g_data.map:isInSafeZone(main_scene.ground.map.mapid, value4, value5) then
		text2 = "1"
	end

	if not self.map:canWalk(value, value2).block then
		local value8 = text .. "," .. value6 .. "," .. value .. "," .. value2 .. "," .. value7 .. "," .. text2

		def.role.call("@thunderClapCall~" .. value8)
	else
		return main_scene.ui:fadeLabel("目标无法到达！")
	end
end

function controller:thunderClap68(value, value2, value3, value4)
	local text = "0"

	if g_data.map:isInSafeZone(main_scene.ground.map.mapid, value, value2) then
		text = "1"
	end

	local role = main_scene.ground.map:findRole(value3).info:getName() .. "," .. value3 .. "," .. value .. "," .. value2 .. "," .. value4 .. "," .. text

	def.role.call("@thunderClapCall~" .. role)
end

return controller
