local current = ...
local magic = import("..common.magic")
local common = import("..common.common")
local settingLogic = import("..common.settingLogic")
local controller = class("controller")
local operate = import("..pc.operate")

table.merge(controller, {
	console,
	autoMining = false,
	stopAttack = false,
	quickGroup = false
})

function controller:ctor(console)
	self.console = console
	self.lock = console:get("lock")
	self.isWalk = not g_data.setting.base.touchRun
	self.move = {}
	self.touchTarget = nil

	local AutoFindPath = import("..common.autoFindPath", current)

	self.autoFindPath = AutoFindPath.new()

	self:processTouchForMutil()
end

function controller:processTouchForMutil()
	local beginNodes = {}

	local function handler(event)
		if event.name == "began" or event.name == "added" then
			if IS_PC_SIMUALTOR or IS_PLAYER_DEBUG then
				self:changeMouseMode("left")
			end

			for k, v in pairs(beginNodes) do
				if self == v then
					return true
				end
			end

			local id, point

			for k, v in pairs(event.points) do
				id, point = k, v
			end

			if id and point then
				local onceEvent = {
					name = "began",
					x = point.x,
					y = point.y
				}
				local nodes = sortNodes(table.values(self.console.widgets))

				for i, v in ipairs(nodes) do
					if v.__cname == "btnMove" and not v.donotMutilTouch and v:isVisible() and cc.rectContainsPoint(v:getClickRect(), cc.p(point.x, point.y)) then
						beginNodes[id] = v.btn

						v.btn:handleTouch(onceEvent)

						return true
					end
				end

				local rocker = self.console:get("rocker")

				if rocker and rocker:isVisible() and cc.rectContainsPoint(rocker:getBoundingBox(), cc.p(point.x, point.y)) then
					beginNodes[id] = rocker

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
			for id, point in pairs(event.points) do
				local node = beginNodes[id]

				if node then
					local onceEvent = {
						name = "moved",
						x = point.x,
						y = point.y
					}

					node:handleTouch(onceEvent)
				end
			end
		elseif event.name == "ended" or event.name == "removed" then
			for id, point in pairs(event.points) do
				local node = beginNodes[id]

				if node then
					local onceEvent = {
						name = "ended",
						x = point.x,
						y = point.y
					}

					node:handleTouch(onceEvent)
				end

				beginNodes[id] = nil
			end

			if event.name == "ended" then
				beginNodes = {}
			end
		end
	end

	local touchNode = display.newNode():size(display.width, display.height):add2(self.console, self.console.z.mutilTouch)

	touchNode:setTouchEnabled(true)
	touchNode:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
	touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler)
end

function controller:handleTouch(event)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player then
		return false
	end

	local x, y = map:getMapPosWithScreenPos(event.x, event.y)

	local function getTouchTarget()
		local roles = {}

		table.merge(roles, map.heros)
		table.merge(roles, map.mons)
		table.merge(roles, map.npcs)

		local roles = self:sortRoles(table.values(roles))

		for i, v in ipairs(roles) do
			if cc.rectContainsPoint(v.node:getBoundingBox(), cc.p(x, y)) and not v.die then
				return v.roleid
			end
		end

		for i, v in pairs(map.stalls) do
			if cc.rectContainsPoint(v.npc:getBoundingBox(), v:convertToNodeSpace(cc.p(event.x, event.y))) or cc.rectContainsPoint(v.stall:getBoundingBox(), v:convertToNodeSpace(cc.p(event.x, event.y))) then
				v.type = "stall"

				return v
			end
		end
	end

	if DEBUG > 0 and m2debug.catch then
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			local roles = {}

			table.merge(roles, map.heros)
			table.merge(roles, map.mons)

			local roles = self:sortRoles(table.values(roles))

			for i, v in ipairs(roles) do
				if cc.rectContainsPoint(v.node:getBoundingBox(), cc.p(x, y)) and not v.die then
					m2debug.catchName = v.info:getName()
				end
			end
		end

		m2debug.catch = false

		if m2debug.node.catchNode then
			m2debug.node.catchNode.btn:setIsSelect(false)
		end

		return
	end

	if event.name == "began" then
		self.autoFindPath:multiMapPathStop()

		self.autoMining = false
		self.touchTarget = getTouchTarget()

		if self.heroLock then
			if self.touchTarget and g_data.client:checkLastTime("heroLock", 1) and g_data.hero.bNoTarget then
				g_data.client:setLastTime("heroLock", true)

				local gameX, gameY = map:getGamePos(x, y)

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

				local gameX, gameY = map:getGamePos(x, y)

				net.send({
					CM_HERO_APPTARG,
					series = 1,
					param = gameX,
					tag = gameY
				})
			end
		elseif self.openShift then
			-- block empty
		elseif self.autoWa then
			local gameX, gameY = map:getGamePos(x, y)
			local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

			if dir ~= player.dir then
				net.send({
					CM_TURN,
					recog = player.x,
					param = player.y,
					series = dir
				})
				player:addAct({
					type = "stand",
					dir = dir,
					x = player.x,
					y = player.y
				})
			end
		elseif not self.touchTarget and not self.lock.skill.enable then
			self.move.enable = "pos"
			self.move.x, self.move.y = event.x, event.y
		end

		return true
	end

	if event.name == "moved" then
		if self.autoWa or self.openShift or self.heroGuard or self.heroLock or self.quickGroup then
			return
		end

		if self.touchTarget then
			local role = map:findRole(self.touchTarget)

			if role then
				if not cc.rectContainsPoint(role.node:getBoundingBox(), cc.p(x, y)) then
					self.touchTarget = nil
				end
			else
				self.touchTarget = nil
			end
		end

		if not self.touchTarget then
			self.touchTarget = getTouchTarget()
		end

		self.move.x, self.move.y = event.x, event.y
	elseif event.name == "ended" then
		self.touchTarget = getTouchTarget()

		if self.touchTarget then
			if type(self.touchTarget) == "number" then
				local role = map:findRole(self.touchTarget)

				if role then
					if role.__cname == "npc" then
						if self.lock.target and self.lock.target.attack then
							local selectRole = self.lock.target.attack

							if type(self.lock.target.attack) == "number" then
								selectRole = map:findRole(selectRole)
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
						if self.lock.skill.enable then
							local last_attack = self.lock.target.skill

							if type(last_attack) == "number" then
								last_attack = map:findRole(last_attack)
							end

							if last_attack and self.openShift and last_attack.roleid ~= role.roleid then
								if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
									self.lock:setSkillTarget(role)
								end
							else
								if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
									self.lock:setSkillTarget(role)
								end

								self:useMagic(role.x, role.y)
							end
						elseif self.lock.isSelect and not WIN32_OPERATE then
							self.lock:setAttackTarget()
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
							local last_attack = self.lock.target.target

							if type(last_attack) == "number" then
								last_attack = map:findRole(last_attack)
							end

							if last_attack and last_attack.roleid ~= role.roleid then
								if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
									self.lock:setSkillTarget(role)
								end
							else
								self.lock:setSelectTarget(role)
							end
						end
					elseif role.isPlayer then
						local pos = role.node:convertToNodeSpace(event)

						if pos.y >= 0 and pos.y < 30 then
							local map = main_scene.ground.map
							local player = main_scene.ground.player

							self:pickupTest(map, player, true)
						end
					end
				end
			elseif self.touchTarget.type and self.touchTarget.type == "stall" then
				if self.lock.target and self.lock.target.attack then
					local selectRole = self.lock.target.attack

					if type(self.lock.target.attack) == "number" then
						selectRole = map:findRole(selectRole)
					end

					self.lock:setSelectTarget(selectRole)
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
				local map = main_scene.ground.map

				if map then
					self:useMagic(map:getGamePos(x, y))
				end
			elseif self.openShift then
				local gameX, gameY = map:getGamePos(x, y)
				local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

				self:forceAttackTest(dir)
			end
		end

		self.move.enable = false
	end
end

function controller:sortRoles(roles)
	table.sort(roles, function(a, b)
		return a.node:getPositionY() < b.node:getPositionY()
	end)

	return roles
end

function controller:setTouchRun(enable)
	self.isWalk = not enable

	if IS_PC_SIMUALTOR or IS_PLAYER_DEBUG then
		self.isWalk = true
	end
end

function controller:changeMouseMode(type)
	if type == "left" then
		self.isWalk = true
	elseif type == "right" then
		self.isWalk = false
	end
end

function controller:toggleShift()
	self.openShift = true

	if self.openShift then
		self:forceAttackTest(main_scene.ground.player.dir)
	end

	self.openShift = false
end

function controller:setQuickGroup()
	self.quickGroup = not self.quickGroup
end

function controller:toggleWa()
	self.autoWa = not self.autoWa
end

function controller:closeHeroLock()
	local btn = main_scene.ui.console:get("btnHeroLock")

	if btn then
		btn:unselect()
	end

	self.heroLock = nil
end

function controller:toggleHeroLock()
	self.heroLock = not self.heroLock
end

function controller:closeHeroGuard(btn)
	local btn = main_scene.ui.console:get("btnHeroGuard")

	if btn then
		btn:unselect()
	end

	self.heroGuard = nil
end

function controller:toggleHeroGuard(btn)
	self.heroGuard = not self.heroGuard
end

function controller:useMagic(x, y, dir, data)
	local player = main_scene.ground.player

	data = data or self.lock.skill.data

	if not player or player:isLocked() or not player:canNextSpell(data.magicId) then
		return
	end

	if not x and not y then
		if checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
			if self.lock.target.skill and main_scene.ground.map then
				local role = main_scene.ground.map:findRole(self.lock.target.skill)

				if role then
					if role.die then
						self.lock:skillTargetDie()
					else
						x, y = role.x, role.y
					end
				end
			end

			if not x and not y then
				return
			end
		elseif self.lock.skill.config.first == "self" then
			x, y, dir = player.x, player.y, player.dir
		else
			return
		end
	end

	dir = dir or def.role.getMoveDir(player.x, player.y, x, y)

	if data:get("needMp") > g_data.player.ability:get("MP") then
		main_scene.ui:tip("没有足够的魔法点数!!")

		return
	end

	if checkExist(data:get("magicId"), 13, 14, 15, 16, 17, 18, 19, 28, 30, 48) and not common.checkAmulet(true) and g_data.client:checkLastTime("autoInvisible", 1) then
		g_data.client:setLastTime("autoInvisible", true)
		common.addMsg("护身符用尽, 请检查护身符。", 255, 252, true)
	end

	if data:get("magicId") == 36 then
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

		g_data.client:setLastTime("spell", true)
	end

	local target = 0

	if self.lock.target.skill and self.lock.skill.config and checkExist("lock", self.lock.skill.config.type, self.lock.skill.config.first) then
		target = self.lock.target.skill
	end

	if data:get("magicId") == 2 then
		local role = main_scene.ground.map:findRoelWithPos(x, y)

		if role then
			target = role.roleid
		end
	end

	self:autoTurnDuTest(data, target)
	player:addAct({
		type = "spell",
		x = player.x,
		y = player.y,
		dir = dir,
		wait = {
			x = player.x,
			y = player.y,
			dir = player.dir
		},
		effect = {
			effectID = data:get("effect") - 1,
			magicId = data:get("magicId")
		}
	})
	net.send({
		CM_SPELL,
		recog = target,
		param = x,
		tag = y,
		series = data:get("magicId")
	})

	self.stopAttack = true
end

function controller:getPoisonItems()
	local strRed = "黄色药粉"
	local strGreen = "灰色药粉"
	local redPoison, greenPoison
	local itemEquiped = g_data.equip.items[U_BUJUK]

	for k, items in pairs({
		{
			itemEquiped
		},
		g_data.bag.items
	}) do
		for k, v in pairs(items) do
			if v.getVar("stdMode") == 25 then
				if string.find(v.getVar("name"), strRed) then
					redPoison = v
				elseif string.find(v.getVar("name"), strGreen) then
					greenPoison = v
				end

				if redPoison and greenPoison then
					break
				end
			end
		end
	end

	return redPoison, greenPoison, itemEquiped
end

function controller:checkPoisonForTarget(tar)
	local strRed = "黄色药粉"
	local strGreen = "灰色药粉"
	local redPoison, greenPoison, itemEquiped = self:getPoisonItems()
	local item, str

	if not def.role.stateHas(tar.state, "stPoisonGreen") then
		if greenPoison then
			item = greenPoison
		else
			if g_data.client:checkLastTime("checkPoisonForTargetGreen", 1) then
				g_data.client:setLastTime("checkPoisonForTargetGreen", true)
				main_scene.ui:tip(string.format("你的%s已用尽。", strGreen))
			end

			item = redPoison
		end
	end

	if not item and not def.role.stateHas(tar.state, "stPoisonRed") then
		if redPoison then
			item = redPoison
		else
			if g_data.client:checkLastTime("checkPoisonForTargetRed", 1) then
				g_data.client:setLastTime("checkPoisonForTargetRed", true)
				main_scene.ui:tip(string.format("你的%s已用尽。", strRed))
			end

			item = greenPoison
		end
	end

	return item, redPoison, greenPoison
end

function controller:autoTurnDuTest(data, target)
	if data:get("magicId") ~= 6 then
		return
	end

	local tar = main_scene.ground.map:findRole(target)

	if not tar then
		return
	end

	local item, redPoison, greenPoison = self:checkPoisonForTarget(tar)

	if not item then
		if not redPoison and not greenPoison then
			return
		end

		if redPoison and greenPoison then
			if self.lastIsGreen then
				item = redPoison
			else
				item = greenPoison
			end
		else
			item = redPoison or greenPoison
		end
	end

	if itemEquiped and itemEquiped == item then
		return
	end

	local deal = false

	if g_data.bag:use("take", item:get("makeIndex"), {
		force = true,
		where = U_BUJUK
	}) then
		deal = true

		net.send({
			CM_TAKEONITEM,
			recog = item:get("makeIndex"),
			param = U_BUJUK
		}, {
			item.getVar("name")
		})

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(item:get("makeIndex"))
		end
	end
end

function controller:sendMove(map, player, dir, step, byAttack)
	local dis, destx, desty, ret = 0
	local config = def.role.dir["_" .. dir]

	if dis == 0 then
		local isUnlimitedMove = g_data.map:isInSafeZone(map.mapid, player.x, player.y) or g_data.player.isUnlimitedMove

		for i = 1, step do
			ret = map:canWalk(player.x + config[1] * i, player.y + config[2] * i)

			if not ret.block or ret.block ~= "npc" and ret.block ~= "map" and isUnlimitedMove then
				destx, desty = player.x + config[1] * i, player.y + config[2] * i
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
			dir = dir,
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
			series = dir
		})
		main_scene.ground.helper:onUpdateAct(destx, desty)
	elseif dis == 2 then
		player:addAct({
			type = "run",
			dir = dir,
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
			series = dir
		})
		main_scene.ground.helper:onUpdateAct(destx, desty)
	end

	return dis, ret.block
end

function controller:moveTo(map, player, gameX, gameY, dir, type, step)
	local dis = math.max(math.abs(gameX - player.x), math.abs(gameY - player.y))

	if g_data.player.ability:get("HP") < 10 then
		step = 1
	end

	if dis == 1 and step == 1 or dis > 1 or type == "dir" then
		local dis, block = self:sendMove(map, player, dir, step)

		if dis == 0 and block == "map" then
			if type == "pos" and g_data.equip.items[1] and g_data.equip.items[1].getVar("shape") == 19 and player:canNextHit() then
				self.autoMining = true

				player:addAct({
					type = "hit",
					dir = dir,
					x = player.x,
					y = player.y,
					wait = {
						x = player.x,
						y = player.y,
						dir = player.dir
					}
				})
				net.send({
					CM_HEAVYHIT,
					recog = player.x,
					param = player.y,
					tag = dir
				})

				return
			end

			dis = self:sendMove(map, player, dir > 0 and dir - 1 or def.role.dir.leftUp, 1)
		end

		if dis == 0 and block == "map" then
			dis = self:sendMove(map, player, dir < def.role.dir.leftUp and dir + 1 or def.role.dir.up, 1)
		end

		if dis == 0 then
			if dir ~= player.dir then
				net.send({
					CM_TURN,
					recog = player.x,
					param = player.y,
					series = dir
				})
			end

			player:addAct({
				type = "stand",
				dir = dir,
				x = player.x,
				y = player.y
			})
		end
	else
		if dir ~= player.dir then
			net.send({
				CM_TURN,
				recog = player.x,
				param = player.y,
				series = dir
			})
		end

		player:addAct({
			type = "stand",
			dir = dir,
			x = player.x,
			y = player.y
		})
	end
end

function controller:attackRole(map, player, target)
	local disx, disy = player.x - target.x, player.y - target.y

	if math.abs(disx) <= 1 and math.abs(disy) <= 1 then
		local dir = def.role.getMoveDir(player.x, player.y, target.x, target.y)
		local ident, magicId, hitEffect, hitEffectType = CM_HIT
		local hittype = "hit"

		if g_data.player.hitEnables.fire then
			g_data.player:setHitEnable("fire", false)

			ident = CM_FIREHIT
			magicId = 26
			hitEffectType = "fire"
		elseif g_data.player.hitEnables.fire4 then
			g_data.player:setHitEnable("fire4", false)

			ident = CM_4FIREHIT
			magicId = 26
			hitEffectType = "fire4"
		elseif g_data.player.hitEnables.sword then
			g_data.player:setHitEnable("sword", false)

			ident = CM_SWORD_HIT
			hittype = "bigHit"
			magicId = 58
			hitEffectType = "sword"
		elseif g_data.player.hitEnables.twn and (g_data.player.ability:get("MP") >= 10 or g_data.player.ability:get("MP") < 0) then
			g_data.player:setHitEnable("twn", false)

			ident = CM_TWINHIT
			magicId = 95
			hitEffectType = "twn"
		elseif g_data.player.hitEnables.pow then
			g_data.player:setHitEnable("pow", false)

			ident = CM_POWERHIT
			magicId = 7
			hitEffectType = "pow"
		elseif g_data.player.hitEnables.wide and (g_data.player.ability:get("MP") >= 3 or g_data.player.ability:get("MP") < 0) then
			ident = CM_WIDEHIT
			magicId = 25
			hitEffectType = "wide"
		elseif g_data.player.hitEnables.long and g_data.setting.job.autoAllSpace then
			ident = CM_LONGHIT
			magicId = 12
			hitEffectType = "long"
		end

		if hitEffectType then
			hitEffect = {
				type = hitEffectType,
				magicId = magicId
			}
		end

		player:addAct({
			type = hittype,
			x = player.x,
			y = player.y,
			dir = dir,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			},
			hitEffect = hitEffect
		})
		net.send({
			ident,
			recog = player.x,
			param = player.y,
			series = dir
		})
	elseif math.abs(disx) <= 2 and math.abs(disy) <= 2 and math.abs(disx) ~= 1 and math.abs(disy) ~= 1 and g_data.player.hitEnables.long then
		local dir = def.role.getMoveDir(player.x, player.y, target.x, target.y)
		local hitEffect = {
			type = "long",
			magicId = 12
		}

		player:addAct({
			type = "hit",
			x = player.x,
			y = player.y,
			dir = dir,
			wait = {
				x = player.x,
				y = player.y,
				dir = player.dir
			},
			hitEffect = hitEffect
		})
		net.send({
			CM_LONGHIT,
			recog = player.x,
			param = player.y,
			series = dir
		})
	else
		local dir = def.role.getAttackDir(player.x, player.y, target.x, target.y)
		local step = 2

		if g_data.player.ability:get("HP") < 10 then
			step = 1
		end

		local dis, block = self:sendMove(map, player, dir, step, true)

		if dis == 0 then
			dis = self:sendMove(map, player, dir > 1 and dir - 1 or def.role.dir.leftUp, 1)
		end

		if dis == 0 then
			dis = self:sendMove(map, player, dir < def.role.dir.leftUp and dir + 1 or def.role.dir.up, 1)
		end

		if dis == 0 then
			player:addAct({
				type = "stand",
				dir = dir,
				x = player.x,
				y = player.y
			})
		end
	end
end

function controller:pickupTest(map, player, force)
	local pick = false
	local thisPosOfItems = map:getItems(player.x, player.y)

	if #thisPosOfItems <= 0 then
		return false
	end

	if force then
		pick = true
	elseif self.console.autoRat.enableRat then
		if g_data.setting.autoRat.noPickUpItem then
			return
		elseif g_data.setting.autoRat.pickUpRatting then
			local pickOnRatting = g_data.setting.getGoodAttItemSetting().pickOnRatting

			for k, v in pairs(thisPosOfItems) do
				if v.state > 0 then
					print("pickupTest", v.name)

					if pickOnRatting then
						pick = pickOnRatting

						break
					end
				end

				if settingLogic.isRattingItem(v.itemName) then
					pick = true

					break
				end
			end
		end
	elseif g_data.setting.item.pickUp then
		pick = true
	else
		local pickUp = g_data.setting.getGoodAttItemSetting().pickUp

		for k, v in pairs(thisPosOfItems) do
			if v.state and v.state > 0 and pickUp then
				pick = pickUp

				break
			end

			if settingLogic.isPickUp(v.itemName) then
				pick = true

				break
			end
		end
	end

	if pick and (not self.lastPickupTime or socket.gettime() - self.lastPickupTime > 0.3) then
		self.lastPickupTime = socket.gettime()

		net.send({
			CM_PICKUP,
			param = player.x,
			tag = player.y
		})
	end
end

function controller:forceAttackTest(dir)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player or player:isLocked() or not player:canNextHit() then
		return
	end

	local config = def.role.dir["_" .. dir]
	local role = map:findRoelWithPos(player.x + config[1] * 2, player.y + config[2] * 2)

	if role and g_data.player.hitEnables.long then
		local hitEffect = {
			type = "long",
			magicId = 12
		}

		player:addAct({
			type = "hit",
			x = player.x,
			y = player.y,
			dir = dir,
			wait = {
				x = player.x,
				y = player.y,
				dir = dir
			},
			hitEffect = hitEffect
		})
		net.send({
			CM_LONGHIT,
			recog = player.x,
			param = player.y,
			series = dir
		})
	else
		local num, hitType, ident = math.random(3)

		if num == 1 then
			hitType = "hit"
			ident = CM_HIT
		elseif num == 2 then
			hitType = "heavyHit"
			ident = CM_HEAVYHIT
		elseif num == 3 then
			hitType = "bigHit"
			ident = CM_BIGHIT
		end

		local hitEffect

		if g_data.setting.job.autoAllSpace and g_data.player.hitEnables.long then
			hitEffect = {
				type = "long",
				magicId = 12
			}
			ident = CM_LONGHIT
		end

		player:addAct({
			type = hitType,
			dir = dir,
			x = player.x,
			y = player.y,
			wait = {
				x = player.x,
				y = player.y,
				dir = dir
			},
			hitEffect = hitEffect
		})
		net.send({
			ident,
			recog = player.x,
			param = player.y,
			series = dir
		})
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

	if self.move.enable == "dir" then
		local dir = self.move.dir
		local config = def.role.dir["_" .. dir]
		local step = self.move.step
		local gameX, gameY = player.x + config[1] * step, player.y + config[2] * step

		self:moveTo(map, player, gameX, gameY, dir, "dir", step)
	elseif self.move.enable == "pos" then
		local gameX, gameY = map:getGamePos(map:getMapPosWithScreenPos(self.move.x, self.move.y))
		local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)
		local step = self.move.step

		step = step or self.isWalk and 1 or 2

		self:moveTo(map, player, gameX, gameY, dir, "pos", step)
	end

	return true
end

function controller:attackTest()
	local map = self.map
	local player = self.player

	if def.role.stateHas(player.state, "stPoisonStone") then
		return
	end

	if not self.lock.target.attack then
		return
	end

	if self.stopAttack then
		return
	end

	if not player:canNextHit() then
		return
	end

	local attackTarget = map:findRole(self.lock.target.attack)

	if not attackTarget then
		return
	end

	if attackTarget.die then
		self.attackTarget = nil

		return
	end

	self:attackRole(map, player, attackTarget)

	return true
end

function controller:executeTest()
	local map = self.map
	local player = self.player

	if #player.acts == 0 and not player.isExecuteEnd then
		player:allExecuteEnd()
	end
end

function controller:miningTest()
	local map = self.map
	local player = self.player

	if self.autoMining and g_data.equip.items[1] and g_data.equip.items[1].getVar("shape") == 19 and player:canNextHit() then
		player:addAct({
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
		net.send({
			CM_HEAVYHIT,
			recog = player.x,
			param = player.y,
			series = player.dir
		})

		return true
	end
end

function controller:waTest()
	local map = self.map
	local player = self.player

	if self.autoWa and player:canNextHit() then
		player:addAct({
			type = "sitdown",
			dir = player.dir,
			x = player.x,
			y = player.y
		})

		local config = def.role.dir["_" .. player.dir]
		local destx, desty = player.x + config[1], player.y + config[2]
		local role = map:findRoelWithPos(destx, desty, "mon")

		role = role or map:findRoelWithPos(destx, desty, "hero")

		if role then
			net.send({
				CM_BUTCH,
				recog = role and role.roleid or player.roleid,
				param = destx,
				tag = desty,
				series = player.dir
			})
		end

		return true
	end
end

function controller:checkZhanjiashu()
	if g_data.player.job ~= 2 then
		return
	end

	local setting = g_data.setting.job

	if not setting.autoZhanjiashu then
		return
	end

	local data = g_data.player:getMagic(15)

	if not data then
		return
	end

	if data:get("needMp") > g_data.player.ability:get("MP") then
		return
	end

	local player = main_scene.ground.player

	if setting.autoZhanjiashu and g_data.player:getMagic(15) and not def.role.stateHas(player.last.state, "stACShield") then
		self:useMagic(player.x, player.y, player.dir, data)

		return true
	end
end

function controller:checkYoulingDun()
	if g_data.player.job ~= 2 then
		return
	end

	local setting = g_data.setting.job

	if not setting.autoYoulingDun then
		return
	end

	local data = g_data.player:getMagic(14)

	if not data then
		return
	end

	if data:get("needMp") > g_data.player.ability:get("MP") then
		return
	end

	local player = main_scene.ground.player

	if setting.autoYoulingDun and g_data.player:getMagic(14) and not def.role.stateHas(player.last.state, "stMACShield") then
		self:useMagic(player.x, player.y, player.dir, data)

		return true
	end
end

function controller:autoDunTest()
	local map = self.map
	local player = self.player

	if g_data.player.job ~= 1 then
		return
	end

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

	if data:get("needMp") > g_data.player.ability:get("MP") then
		return
	end

	self:useMagic(player.x, player.y, player.dir, data)

	return true
end

function controller:autoInvisibleTest()
	local map = self.map
	local player = self.player

	if g_data.player.job ~= 2 then
		return
	end

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

	if data:get("needMp") > g_data.player.ability:get("MP") then
		return
	end

	return self:useMagic(player.x, player.y, player.dir, data)
end

function controller:autoSpaceLongHitTest()
	local map = self.map
	local player = self.player

	if g_data.player.job ~= 0 or not g_data.setting.job.autoSpace or not self.lock.target.attack or not g_data.player:getMagic(12) then
		return
	end

	local role = map:findRole(self.lock.target.attack)

	if not role or role.die then
		return
	end

	local disx, disy = math.abs(player.x - role.x), math.abs(player.y - role.y)

	if disx ~= 1 and disy ~= 1 and math.max(disx, disy) <= 2 then
		return
	end

	local pos = {}

	for i = 0, 7 do
		local config = def.role.dir["_" .. i]
		local x, y = role.x + config[1] * 2, role.y + config[2] * 2

		if not map:canWalk(x, y).block then
			pos[#pos + 1] = {
				x,
				y
			}
		end
	end

	if #pos > 1 then
		local best = {
			disMax = 9999
		}

		for i, v in ipairs(pos) do
			local disx, disy = math.abs(player.x - v[1]), math.abs(player.y - v[2])
			local disMax = math.max(disx, disy)

			if disMax == 1 or disx ~= 1 and disy ~= 1 and disMax <= 2 then
				local dir = def.role.getMoveDir(player.x, player.y, v[1], v[2])
				local step = math.max(disx, disy)

				if g_data.player.ability:get("HP") < 10 then
					step = 1
				end

				return self:sendMove(map, player, dir, step) > 0
			end

			if disMax < best.disMax then
				best.disMax = disMax
				best.x, best.y = v[1], v[2]
			end
		end

		if best.x and best.y then
			local dir = def.role.getMoveDir(player.x, player.y, best.x, best.y)
			local step = 2

			if g_data.player.ability:get("HP") < 10 then
				step = 1
			end

			return self:sendMove(map, player, dir, step) > 0
		end
	end
end

function controller:removeFindPathMark()
	if self.sprMark then
		self.sprMark:removeSelf()

		self.sprMark = nil
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

	local x, y

	while true do
		if #self.autoFindPath.points == 0 then
			self.autoFindPath:singleMapPathStop()

			return
		end

		x, y = self.autoFindPath.points[1].x, self.autoFindPath.points[1].y

		if player.x == x and player.y == y then
			self.autoFindPath:removePoint()
		else
			break
		end
	end

	local disx, disy = math.abs(player.x - x), math.abs(player.y - y)
	local disMax = math.max(disx, disy)

	if disMax == 1 or disx ~= 1 and disy ~= 1 and disMax <= 2 then
		local dir = def.role.getMoveDir(player.x, player.y, x, y)
		local step = math.max(disx, disy)

		if g_data.player.ability:get("HP") < 10 then
			step = 1
		end

		if self:sendMove(map, player, dir, step) == 0 and not self.console.autoRat.enableRat then
			self.autoFindPath:research()

			return true
		end
	else
		self.autoFindPath:multiMapPathStop()
	end
end

function controller:targetMiss()
	local map = main_scene.ground.map
	local player = main_scene.ground.player
	local player_game_pos = cc.p(map:getGamePos(player.x, player.y))
	local dis

	if self.lock.target.attack then
		local target

		if type(self.lock.target.attack) == "number" then
			target = map:findRole(self.lock.target.attack)
		else
			target = self.lock.target.attack
		end

		if target then
			local attack_game_pos = cc.p(map:getGamePos(target.x, target.y))

			dis = math.sqrt(math.pow(player_game_pos.x - attack_game_pos.x, 2) + math.pow(player_game_pos.y - attack_game_pos.y, 2))

			if dis > 15 then
				self.lock.target.attack = nil
			end
		else
			self.lock.target.attack = nil
		end
	end

	if self.lock.target.skill then
		local target = map:findRole(self.lock.target.skill)

		if target then
			local skill_game_pos = cc.p(map:getGamePos(target.x, target.y))

			dis = math.sqrt(math.pow(player_game_pos.x - skill_game_pos.x, 2) + math.pow(player_game_pos.y - skill_game_pos.y, 2))

			if dis > 15 then
				self.lock.target.skill = nil
			end
		else
			self.lock.target.skill = nil
		end
	end

	if self.lock.target.select then
		local target = map:findRole(self.lock.target.select)

		if target then
			local select_game_pos = cc.p(map:getGamePos(target.x, target.y))

			dis = math.sqrt(math.pow(player_game_pos.x - select_game_pos.x, 2) + math.pow(player_game_pos.y - select_game_pos.y, 2))

			if dis > 15 then
				self.lock:cancelSelect()
			end
		else
			self.lock:cancelSelect()
		end
	end

	return true
end

function controller:shiftAttack()
	local map = self.map
	local player = self.player

	if def.role.stateHas(player.state, "stPoisonStone") then
		return
	end

	if not self.openShift then
		return
	end

	if self.lock.target.attack then
		return
	end

	if self.stopAttack then
		return
	end

	if not player:canNextHit() then
		return
	end

	local i_x, i_y = map:getMapPosWithScreenPos(operate.mouseX, operate.mouseY)
	local gameX, gameY = map:getGamePos(i_x, i_y)
	local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

	self:forceAttackTest(dir)

	return true
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

	self:pickupTest(map, player)

	if player.die then
		return
	end

	local autoRat = self.console.autoRat

	if autoRat.enable then
		self:autoDunTest()

		if player:isLocked() then
			return
		end

		if autoRat:executeTest(dt) then
			return
		end
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

	if self:checkZhanjiashu() then
		return
	end

	if self:checkYoulingDun() then
		return
	end

	if self:autoDunTest() then
		return
	end

	if self:autoInvisibleTest() then
		return
	end

	if self:attackTest() then
		return
	end

	if self:waTest() then
		return
	end

	if WIN32_OPERATE then
		self:shiftAttack()
	end

	self:targetMiss()
	self:executeTest()
end

return controller
