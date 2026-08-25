local cx = 62
local cy = 45
local labelx = 23
local labely = 96
local x2 = 22
local y2 = 116
local network = require("mir2.network")
local lock = class("widget.lock", function()
	return display.newNode()
end)

local function updateVisible()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

local cc2 = require("mir2.cc")

table.merge(lock, {
	roleNameLabel,
	roleHP,
	roleHPBg,
	roleHPText,
	isSelect,
	target,
	skill,
	role,
	killNum,
	say_mode,
	lock_name,
	locked_player,
	old_lockplayer,
	locked_player_color,
	looks,
	lock_mon,
	autoATCOpenting
})

function lock:ctor(config, data)
	if not def.closeLock then
		self.bgSpr = res.get2("pic/console/lock_bg.png"):pos(cx, cy):add2(self)

		if updateVisible() then
			data.x = data.x + getSafeAreaInsets()
		end

		self.bgSpr:anchor(cx / self.bgSpr:getw(), cy / self.bgSpr:geth()):enableClick(function()
			if self:isEnable() then
				self:stop()
			else
				self:startSelect()
			end
		end)
		self.anchor(self, 0.5, 0.5):pos(data.x, data.y):size(self.bgSpr:getContentSize())

		self.lockSpr = res.get2("pic/console/lock.png"):pos(cx + 1, cy + 1):add2(self)
		self.lockSkillText = res.get2("pic/console/lock-single.png"):pos(cx, cy - 20):add2(self):hide()
		self.roleNameLabel = an.newLabel("", 18, 1, {
			color = cc.c3b(0, 255, 0)
		}):anchor(0, 0.5):pos(labelx, labely):add2(self)
		self.roleHP = an.newProgress(res.gettex2("pic/console/lock/lockblood.png"), res.gettex2("pic/console/lock/lockbloodbg.png"), {
			x = 1,
			y = 1
		}):anchor(0, 0.5):pos(x2, y2):addTo(self)

		self.roleHP:setp(1)

		self.roleHPText = an.newLabel("", 12, 1, {
			color = cc.c3b(240, 240, 240)
		}):anchor(0.5, 0.5):pos(self.roleHP:getw() / 2, self.roleHP:geth() / 2):add2(self.roleHP, 1)

		self.roleHP:setVisible(false)
		display.newNode():anchor(0, 0.5):pos(self.roleNameLabel:getPosition()):size(self.bgSpr:getw(), 42):add2(self):enableClick(function()
			if not self.roleNameLabel.roleid then
				return
			end

			local role = main_scene.ground.map:findRole(self.roleNameLabel.roleid)

			if not role then
				return
			end

			if role.__cname ~= "hero" then
				return
			end

			if self.roleNameLabel and tolua.cast(self.roleNameLabel, "cc.Node") then
				self.roleNameLabel:stopAllActions()
				self.roleNameLabel:runs({
					cc.ScaleTo:create(0.1, 1.5),
					cc.ScaleTo:create(0.1, 1)
				})
			end

			if not main_scene.ground:smr() and g_data.client:checkLastTime("queryOther", 1) then
				g_data.client:setLastTime("queryOther", true)
				net.send({
					CM_QUERYUSERSTATE,
					recog = role.roleid,
					param = role.x,
					tag = role.y
				})
				net.send({
					CM_QUERY_TITLE,
					0,
					recog = role.roleid,
					param = role.x,
					tag = role.y
				})
			else
				main_scene.ui:tip("操作太快")
			end
		end)
	end

	self.exLabels = {}
	self.target = {}
	self.skill = {}
	self.killNum = 0
	self.lock_name = nil
	self.autoATCOpenting = false
	self.old_lockplayer = nil
end

function lock:killEffAni()
	cc2.ms({
		function()
			if not g_data.client:checkLastTime("latestKill", def.role.kill.timeInterval) then
				self.killNum = self.killNum + 1

				if def.role.kill.maxKillStyle and self.killNum > def.role.kill.maxKillStyle then
					self.killNum = def.role.kill.maxKillStyle
				end
			else
				self.killNum = 1
			end

			self.showKillEffAni(self, self.killNum)
			g_data.client:setLastTime("latestKill", true)
		end
	})
end

function lock:showKillEffAni(data)
	if not def.role.kill or not def.role.kill.killStyle then
		return
	end

	local text = "kill" .. tostring(data)
	local text2 = def.role.kill.killStyle[text]

	if text2 then
		local value = _getani2("pic/bzmir/effect/killstyle/%d.png", text2.start or 1, text2.endidx or 1, text2.interval or 0.1)

		if value then
			value.retain(value)

			local value2 = display.height / 2
			local x = display.width / 2 - def.role.kill.offsetx or 0
			local y = value2 - def.role.kill.offsety or 0
			local text3 = _get2("pic/bzmir/effect/killstyle/" .. tostring(text2.start or 1) .. ".png"):pos(x, y):add2(self, 9)

			if text3 then
				if def.role.kill.needSound then
					sound.playSound("kill" .. tostring(data))
				end

				text3.runs(text3, {
					cc.Animate:create(value),
					cc.CallFunc:create(function()
						if text3 then
							text3:removeSelf()

							text3 = nil
						end
					end)
				})
			end
		end
	end
end

function lock:stop()
	self.skill = {}
	self.target = {}
	self.isSelect = nil
	self.locked_player = nil
	self.lock_mon = nil
	self.role = nil

	self.setActionType(self)
	self.setRoleName(self)
	main_scene.ui.console.skills:select()
	self.uptEnable(self)

	if main_scene.ui.panels.nicehp then
		main_scene.ui:hidePanel("nicehp")
	elseif main_scene.ui.panels.yiyimonhp then
		main_scene.ui:hidePanel("yiyimonhp")
	end
end

function lock:startSelect()
	self.isSelect = true

	self.setActionType(self, "lock")
	self.setRoleName(self, "<请选择锁定目标>")
	self.uptEnable(self)
end

function lock:cancelSelect()
	self.target.select = nil
	self.isSelect = nil
end

function lock:setSelectTarget(role)
	if self.target.select == role.roleid then
		main_scene.ui:tip("目标已锁定，请选择攻击方式")
	else
		if not self.isSelect then
			self.startSelect(self)
		end

		self.target.select = role.roleid

		self.setRoleName(self, self.getRoleName(self, role), role)
	end

	self.role = role

	if def.gameVersionType == "185" then
		self:heroAttack()
	end

	if main_scene.ui.console.controller.quickGroup and role.__cname == "hero" then
		g_data.client:setLastTime("group", true)
		net.send({
			#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
		}, {
			role.info:getRealName()
		})
	end
end

function lock:setAttackTarget(role)
	self.target.attack = role and role.roleid

	if self.target.attack then
		self.setActionType(self, "attack")
		self.setRoleName(self, self.getRoleName(self, role), role)

		self.role = role

		if def.gameVersionType == "185" then
			self:heroAttack()
		end

		if role.getRace(role) == 0 and g_data.player:getHasGuild() and g_data.setting.base.guild and g_data.client:checkLastTime("guild", 10) then
			g_data.client:setLastTime("guild", true)

			local player = main_scene.ground.player
			local str = "!~我正在[" .. g_data.map.mapTitle .. "]坐标:[" .. player.x .. "," .. player.y .. "]与[" .. self.getRoleName(self, role) .. "]进行战斗"

			net.send({
				CM_SAY
			}, {
				str
			})
		end
	elseif not self.skill.enable and not self.isSelect then
		self.setActionType(self)
		self.setRoleName(self)
	end

	self.uptEnable(self)
end

function lock:setSkillTarget(role)
	self.target.skill = role.roleid

	if def.gameVersionType == "185" then
		self:heroAttack()
	end

	self.role = role

	self.setRoleName(self, self.getRoleName(self, role), role)
end

function lock:attackUseMagicById(value)
	if self.role then
		self:attackUseMagic(self.role, value)
	end
end

function lock:attackUseMagic(value, value2)
	if value then
		self.setSkillTarget(self, value)
	end

	local point = main_scene.ground.map.player
	local magicIdOwner = g_data.setting.autoRat.defaultAtkMagic

	if not point then
		return
	end

	if def.role.stateHas(point.state, "stPoisonStone") then
		return
	end

	local value3
	local text = value2 or magicIdOwner.magicId
	local magic = g_data.player:getMagic(text)

	if not text or not magic then
		return
	end

	if checkExist(text, 3, 4, 7, 67) then
		return
	end

	if g_data.player.ability:get("MP") < magic.get(magic, "needMp") then
		main_scene.ui:tip("没有足够的魔法点数!")

		return
	end

	local magicConfigByUid = def.magic.getMagicConfigByUid(text, main_scene.ground.player)

	if not magicConfigByUid then
		return
	end

	if cc2.isAutoXiama() then
		return
	end

	if magicConfigByUid.type == "immediate" then
		local value4 = def.role.dir["_" .. point.dir]

		main_scene.ui.console.controller:useMagic(point.x + value4[1], point.y + value4[2], point.dir, magic)

		return
	end

	if magic.get(magic, "effectType") == 0 then
		if text == 26 and not g_data.client:checkLastTime("fire", 10) then
			return
		end

		if text == 27 and not g_data.client:checkLastTime("rush", 3.1) then
			return
		end

		if not g_data.client:checkLastTime("spell", 2) then
			return
		end

		local param = point.x
		local tag = point.y

		if text == 27 then
			g_data.client:setLastTime("rush", true)

			tag = 0
			param = point.dir
		end

		g_data.client:setLastTime("spell", true)
		net.send({
			CM_SPELL,
			param = param,
			tag = tag,
			series = magic.get(magic, "magicId")
		})
	else
		main_scene.ui.console.skills:select(tostring(text))

		if not WIN32_OPERATE then
			self:useSkill(magic, magicConfigByUid)
			main_scene.ui.console.controller:useMagic()
		end
	end
end

function lock:useSkill(data, config)
	self.skill.enable = true
	self.skill.data = data
	self.skill.config = config

	local value = data.get(data, "magicId")
	local skilltype = checkExist("area", config.type) and "mutil" or "single"

	self.setActionType(self, "skill", value, skilltype)

	self.target.skill = self.target.skill or self.target.select or self.target.attack

	if self.target.skill then
		local role = main_scene.ground.map:findRole(self.target.skill)

		if role then
			self.setRoleName(self, self.getRoleName(self, role), role)
		else
			self.setRoleName(self, "<目标失去>")
		end
	else
		self.setRoleName(self, "<请选择技能目标>")
	end

	self.uptEnable(self)
end

function lock:skillTargetDie()
	self.target.skill = nil

	self.setRoleName(self, "<请选择技能目标>")
end

function lock:isEnable()
	return self.target.attack or self.skill.enable or self.isSelect
end

function lock:uptEnable()
	if self.bgSpr and self.roleHP then
		local b = self.isEnable(self)

		self.bgSpr:stopAllActions()

		if b then
			self.bgSpr:rotateTo(0.15, 90)
		else
			self.bgSpr:rotateTo(0.15, 0)
			self.roleHP:setVisible(false)
		end
	end
end

function lock:setActionType(type, skillid, skilltype)
	if self.lockSpr and self.lockSkillText and not def.closeLock then
		if not type then
			self.lockSkillText:hide()
			self.lockSpr:setTex(res.gettex2("pic/console/lock.png"))
		elseif type == "attack" then
			self.lockSkillText:hide()
			self.lockSpr:setTex(res.gettex2("pic/console/skill_base-icons/attack.png"))
		elseif type == "lock" then
			self.lockSkillText:hide()
			self.lockSpr:setTex(res.gettex2("pic/console/skill_base-icons/lock.png"))
		elseif type == "skill" then
			if g_data.player.job ~= 0 then
				self.lockSkillText:show()
				self.lockSkillText:setTex(res.gettex2("pic/console/lock-" .. skilltype .. ".png"))
			end

			if def.magic.buildSkillIcon then
				self.lockSpr:setTex(res.gettex2(def.magic.buildSkillIcon(skillid)))
			else
				self.lockSpr:setTex(res.gettex2("pic/console/skill-icons/" .. skillid .. ".png"))
			end
		end
	end
end

function lock:getSelectRole()
	local value = self.locked_player or self.lock_mon

	value = value or main_scene.ground.map:findRole(self.target.attack)
	value = value or main_scene.ground.map:findRole(self.target.skill)

	if not value and self.roleNameLabel then
		value = main_scene.ground.map:findRole(self.roleNameLabel.roleid)
	end

	value = value or self.role

	return value
end

function lock:updateHP(text, deltaTime)
	cc2.ms({
		function()
			if self.role and not self.role.die and self:isEnable() then
				if self.role.info and text and deltaTime then
					if not def.role.mainsetting.closeHPBar and self.roleHP and self.roleHPText then
						local value = text / deltaTime

						self.roleHP:setVisible(true)
						self.roleHP:setp(value)

						if deltaTime >= 1000000 or main_scene.ground:smr() then
							local value2 = value * 100
							local text = string.format("%d", value2)

							self.roleHPText:setString(text .. "%")
						else
							self.roleHPText:setString(tostring(text) .. "/" .. tostring(deltaTime))
						end
					elseif main_scene.ui.panels.nicehp then
						main_scene.ui.panels.nicehp:updateHP(text, deltaTime)
					elseif main_scene.ui.panels.yiyimonhp then
						main_scene.ui.panels.yiyimonhp:updateHP(text, deltaTime)
					end
				end
			elseif not def.role.mainsetting.closeHPBar and self.roleHP then
				self.roleHP:setVisible(false)
			elseif main_scene.ui.panels.nicehp then
				main_scene.ui:hidePanel("nicehp")
			elseif main_scene.ui.panels.yiyimonhp then
				main_scene.ui:hidePanel("yiyimonhp")
			end
		end
	})
end

function lock:setRoleName(t, roleid)
	if self.roleNameLabel then
		if roleid then
			self.roleNameLabel.roleid = roleid.roleid
		end

		self.setLabelText(self, self.roleNameLabel, func.filterNameFlag(t or ""))
	end
end

function lock:getRoleName(role)
	local lock = role.info:getName()

	if lock then
		if def.role.mainsetting.closeHPBar then
			if def.nicehp then
				if not main_scene.ui.panels.nicehp then
					main_scene.ui:showPanel("nicehp", role, lock)
				elseif role ~= g_data.nicerole then
					main_scene.ui:hidePanel("nicehp")
					main_scene.ui:showPanel("nicehp", role, lock)
				end
			elseif not main_scene.ui.panels.yiyimonhp then
				main_scene.ui:showPanel("yiyimonhp", role, lock)
			elseif role ~= g_data.yiyirole then
				main_scene.ui:hidePanel("yiyimonhp")
				main_scene.ui:showPanel("yiyimonhp", role, lock)
			end
		end

		return lock
	elseif role.__cname == "hero" then
		return "[人物]"
	else
		return "[怪物]"
	end
end

function lock:setLabelText(label, text)
	label.setString(label, text)

	if label.getw(label) < 80 then
		label.pos(label, labelx + (80 - label.getw(label)) / 2, label.getPositionY(label))
	else
		label.pos(label, labelx, label.getPositionY(label))
	end
end

function lock:checkMode()
	local count = 0
	local text = "附近没有可攻击玩家"

	if g_data.player.attackMode and type(g_data.player.attackMode) == "string" then
		if g_data.player.attackMode:find("全体攻击模式") ~= nil or g_data.player.attackMode:find("全体攻击模式") ~= nil then
			count = 0
			text = "附近没有可攻击玩家"
		elseif g_data.player.attackMode:find("行会攻击模式") ~= nil then
			count = 1
			text = "附近没有其他行会玩家"
		elseif g_data.player.attackMode:find("组队攻击模式") ~= nil then
			text = "附近没有其他队伍玩家"
			count = 2
		elseif g_data.player.attackMode:find("善恶攻击模式") ~= nil then
			count = 3
			text = "附近没有敌对势力玩家"
		elseif g_data.player.attackMode:find("战队攻击模式") ~= nil then
			count = 4
			text = "附近没有其他战队玩家"
		else
			count = 5
			text = "附近没有可攻击玩家"
		end
	end

	return count, text
end

function lock:getCanLockPlayers(value)
	local text = ""
	local text2 = ""
	local enabled = false
	local value2 = main_scene.ground.player.info.guildName
	local value3 = main_scene.ground.player.info.campId
	local items = {}

	if self.locked_player then
		text = self.locked_player.info:getRealName()
	end

	if g_data.hero and g_data.hero.name then
		text2 = g_data.hero.name
	end

	for _, locked_player in pairs(main_scene.ground.map.heros) do
		if not locked_player.die and not locked_player.isPlayer and not locked_player.info:checkHeroFromCache() and not def.stateIsHave(locked_player.last.state, "stRealHidden") and not locked_player.isDummy then
			local realName = locked_player.info:getRealName()

			if realName then
				if realName == text2 or realName == main_scene.ground.player.info:getRealName() then
					-- block empty
				elseif value3 then
					if locked_player.info.campId ~= value3 then
						items[#items + 1] = locked_player
					end
				elseif value == 0 then
					items[#items + 1] = locked_player
				elseif value == 1 then
					if value2 and g_data.guild.allGuildMems then
						local enabled2 = false

						for _2, allGuildMem in pairs(g_data.guild.allGuildMems) do
							if allGuildMem.name == realName then
								enabled2 = true

								break
							end
						end

						if not enabled2 then
							items[#items + 1] = locked_player
						end
					else
						items[#items + 1] = locked_player
					end
				elseif value == 2 then
					if g_data.player.groupMembers then
						local enabled3 = false

						for _3, groupMember in ipairs(g_data.player.groupMembers) do
							if realName == groupMember.name then
								enabled3 = true

								break
							end
						end

						if not enabled3 then
							items[#items + 1] = locked_player
						end
					else
						items[#items + 1] = locked_player
					end
				elseif value == 3 then
					if g_data.guild.guildHostile then
						local enabled4 = false

						for _4, guildHostile in ipairs(g_data.guild.guildHostile) do
							if locked_player.info.guildName == guildHostile.name then
								enabled4 = true

								break
							end
						end

						if enabled4 then
							items[#items + 1] = locked_player
						end
					end
				elseif value == 4 then
					if g_data.guild.allCorpsMem then
						local enabled5 = false

						for _5, allCorpsMem in pairs(g_data.guild.allCorpsMem) do
							if realName == allCorpsMem.name then
								enabled5 = true

								break
							end
						end

						if not enabled5 then
							items[#items + 1] = locked_player
						end
					else
						items[#items + 1] = locked_player
					end
				elseif value == 5 then
					items[#items + 1] = locked_player
				end

				if realName == text then
					enabled = true
					self.locked_player = locked_player
				end
			end
		end
	end

	if not enabled then
		self.locked_player = nil
	end

	return items
end

function lock:getLockPlayers(value2)
	local value, value3 = self:checkMode()
	local canLockPlayers = self:getCanLockPlayers(value)

	table.sort(canLockPlayers, function(value, value2)
		return main_scene.ground.player:getDis(value) < main_scene.ground.player:getDis(value2)
	end)

	return canLockPlayers
end

function lock:doLockPlayer(value2)
	if not self.looks then
		self.looks = {}
	end

	local value
	local value3, value4 = self:checkMode()
	local canLockPlayers = self:getCanLockPlayers(value3)
	local locked_player = self:findNear(canLockPlayers)

	self.stop(self)

	if self.skill.enable then
		self.skill = {}

		main_scene.ui.console.skills:select()
	end

	if self.target.skill then
		local locked_player2 = main_scene.ground.map:findRole(self.target.skill)

		if locked_player2 then
			self.locked_player = locked_player2

			self.setSelectTarget(self, locked_player2)

			return
		end
	end

	if locked_player then
		self.setSelectTarget(self, locked_player)

		if g_data.setting.base.lockHeroTips then
			local lock_name = locked_player.info:getRealName()

			if lock_name and type(lock_name) == "string" and (not self.lock_name or self.lock_name ~= lock_name) then
				local value5 = locked_player.job
				local jobName = def.ccy.getJobName(value5)

				main_scene.ui:fadeLabel("锁定玩家: " .. locked_player.info:getName() .. " (" .. jobName .. ")")

				self.lock_name = lock_name
			end
		end

		self.locked_player = locked_player
	else
		if g_data.client:checkLastTime("nodidui", 2) and not value2 then
			g_data.client:setLastTime("nodidui", true)
			main_scene.ui:tip(value4)
		end

		self.stop(self)
	end
end

function lock:lockPlayer(value)
	cc2.ms({
		function()
			self.doLockPlayer(self, value)
		end
	})
end

function lock:doLockMon(value2)
	if not self.looks then
		self.looks = {}
	end

	local value
	local items = {}

	for _, mon in pairs(main_scene.ground.map.mons) do
		if main_scene.ground.player:getDis(mon) < 10 then
			local realName = mon.info:getRealName()

			if not mon.die and realName and not mon:isPolice() and not mon.isDummy and not mon.isHaveMaster and not mon.info:isPet() then
				table.insert(items, mon)
			end
		end
	end

	local lock_mon = self:findNear(items)

	self.stop(self)

	if self.skill.enable then
		self.skill = {}

		main_scene.ui.console.skills:select()
	end

	if self.target.skill then
		local lock_mon2 = main_scene.ground.map:findRole(self.target.skill)

		if lock_mon2 then
			self.lock_mon = lock_mon2

			self.setSelectTarget(self, lock_mon2)

			return
		end
	end

	if lock_mon then
		self.lock_mon = lock_mon

		self.setSelectTarget(self, lock_mon)
		main_scene.ui:fadeLabel("锁定怪物: " .. lock_mon.info:getName())
	else
		if g_data.client:checkLastTime("nodidui", 1) and not value2 then
			g_data.client:setLastTime("nodidui", true)
			main_scene.ui:tip("附近没有怪物.")
		end

		self.stop(self)
	end
end

function lock:lockMon(value)
	cc2.ms({
		function()
			self.doLockMon(self, value)
		end
	})
end

function lock:findNear(items)
	local player

	table.sort(items, function(value, value2)
		return main_scene.ground.player:getDis(value) < main_scene.ground.player:getDis(value2)
	end)

	for _, item in ipairs(items) do
		if not self.looks[item.roleid] then
			player = item

			break
		end
	end

	if not player then
		self.looks = {}

		if #items > 0 then
			player = items[1]
		end
	end

	if player then
		self.looks[player.roleid] = true
	end

	return player
end

function lock:lockEveryBody(value2)
	if not self.looks then
		self.looks = {}
	end

	local value
	local value3, value4 = self:checkMode()
	local canLockPlayers = self:getCanLockPlayers(value3)

	for _, mon in pairs(main_scene.ground.map.mons) do
		if main_scene.ground.player:getDis(mon) < 10 then
			local realName = mon.info:getRealName()

			if not mon.die and realName and not mon:isPolice() and not mon.isDummy and not mon.isHaveMaster and not mon.info:isPet() then
				mon.mon = true

				table.insert(canLockPlayers, mon)
			end
		end
	end

	local lock_mon = self:findNear(canLockPlayers)

	self.stop(self)

	if self.skill.enable then
		self.skill = {}

		main_scene.ui.console.skills:select()
	end

	if self.target.skill then
		local lock_mon2 = main_scene.ground.map:findRole(self.target.skill)

		if lock_mon2 then
			if lock_mon2.__cname == "mon" then
				self.lock_mon = lock_mon2
			else
				self.locked_player = lock_mon2
			end

			self.setSelectTarget(self, lock_mon2)

			return
		end
	end

	if lock_mon then
		self.setSelectTarget(self, lock_mon)

		if lock_mon.player then
			self.locked_player = lock_mon

			if g_data.setting.base.lockHeroTips then
				local lock_name = lock_mon.info:getRealName()

				if lock_name and type(lock_name) == "string" and (not self.lock_name or self.lock_name ~= lock_name) then
					local value5 = lock_mon.job
					local jobName = def.ccy.getJobName(value5)

					main_scene.ui:fadeLabel("锁定玩家: " .. lock_mon.info:getName() .. " (" .. jobName .. ")")

					self.lock_name = lock_name
				end
			end
		else
			self.lock_mon = lock_mon

			self.setSelectTarget(self, lock_mon)
			main_scene.ui:fadeLabel("锁定怪物: " .. lock_mon.info:getName())
		end
	else
		if g_data.client:checkLastTime("nodidui", 2) and not value2 then
			g_data.client:setLastTime("nodidui", true)
			main_scene.ui:tip(value4)
		end

		self.stop(self)
	end
end

function lock:lockEB(value)
	cc2.ms({
		function()
			self.lockEveryBody(self, value)
		end
	})
end

function lock:canAttack()
	if not self.role then
		return false
	end

	if self.role and self.role.die then
		return false
	end

	if self.role.roleid == main_scene.ground.player.roleid then
		return false
	end

	if not g_data.setting.base.aotoChangeLock then
		return true
	end

	local enabled = false

	cc2.ms({
		function()
			local point = main_scene.ground.player

			if math.max(math.abs(point.x - self.role.x), math.abs(point.y - self.role.y)) <= 9 then
				enabled = true
			end
		end
	})

	return enabled
end

function lock:attackAny(value)
	self:lockAnyOnly()
	self:goAttack()
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function lock:goAttack()
	if self.role and not self.role.die then
		if g_data.setting.base.autoatk then
			cc2.ms({
				function()
					local text = g_data.setting.autoRat.defaultAtkMagic

					if text and text.enable then
						local magic = g_data.player:getMagic(text.magicId)

						if magic then
							local magicConfigByUid = def.magic.getMagicConfigByUid(text.magicId, main_scene.ground.player)

							if magicConfigByUid then
								self.setSkillTarget(self, self.role)
								main_scene.ui.console.skills:select(tostring(text.magicId))
								self.useSkill(self, magic, magicConfigByUid)
								main_scene.ui.console.controller:useMagic()
							end
						end
					else
						self.setAttackTarget(self, self.role)
					end
				end
			})
		else
			self.setAttackTarget(self, self.role)
		end
	end
end

function lock:lockAnyOnly()
	if not self:canAttack() then
		if g_data.setting.base.lockPlayerFirst then
			self:lockPlayer(false)

			if not self.role or self.role.die then
				self:lockMon(false)
			end
		else
			self:lockEB(false)
		end
	end
end

function lock:heroAttack()
	if not g_data.setting.base.heroFollow then
		return
	end

	local enabled = false

	if self.target.skill then
		net.send({
			CM_HERO_APPTARG,
			recog = self.target.skill
		})

		enabled = true
	elseif self.target.select then
		net.send({
			CM_HERO_APPTARG,
			recog = self.target.select
		})

		enabled = true
	elseif self.target.attack then
		g_data.hero:setNoTarget(false)
		net.send({
			CM_HERO_APPTARG,
			recog = self.target.attack
		})

		enabled = true
	else
		g_data.hero:setNoTarget(true)
	end

	if enabled and main_scene.ui.console.autoRat.enableRat and g_data.client:checkLastTime("heroSkill", 15) then
		g_data.client:setLastTime("heroSkill", true)
		net.send({
			CM_HERO_POWERUP
		})
	end
end

function lock:openHeroFollow(data)
	if not data.tselect then
		local value = _getani2("pic/bzmir/effect/btnquan/%d.png", 1, 13, 0.1)

		if value then
			value:retain()

			local tselect = _get2("pic/bzmir/effect/btnquan/1.png"):pos(31, 32):add2(data, 1)

			if tselect then
				tselect:setScale(0.6)
				tselect:runForever(cc.Animate:create(value))

				data.tselect = tselect

				data.tselect:setVisible(false)
			end
		end
	end

	if not g_data.setting.base.heroFollow then
		g_data.setting.base.heroFollow = false
	end

	g_data.setting.base.heroFollow = not g_data.setting.base.heroFollow

	if data.tselect then
		data.tselect:setVisible(g_data.setting.base.heroFollow)
	end
end

function atccallback(self)
	if not main_scene then
		return
	end

	local value = main_scene.ui.console.controller.lock

	if value then
		if not value.role or value.role.die then
			value:attackAny()
		else
			value:goAttack()
		end
	end
end

function lock:autoAttack(tselectOwner)
	if cc2.isAutoXiama() then
		return
	end

	if def.role.status.openPKAssitent then
		if not tselectOwner.tselect then
			local value = _getani2("pic/bzmir/effect/4/%d.png", 4, 8, 0.3)

			if value then
				value:retain()

				local tselect = _get2("pic/bzmir/effect/4/1.png"):pos(30, 30):add2(tselectOwner, 1)

				if tselect then
					tselect:runForever(cc.Animate:create(value))

					tselectOwner.tselect = tselect

					tselectOwner.tselect:setVisible(false)
				end
			end
		end

		if not g_data.setting.base.autoatk then
			g_data.setting.base.autoatk = false
		end

		g_data.setting.base.autoatk = not g_data.setting.base.autoatk

		if tselectOwner.tselect then
			tselectOwner.tselect:setVisible(g_data.setting.base.autoatk)
		end

		if g_data.setting.base.autoatk then
			atccallback()

			if def.role.timer.__autoattack__ then
				def.role.stopRepeater(def.role.timer.__autoattack__)

				def.role.timer.__autoattack__ = nil
			end

			def.role.timer.__autoattack__ = def.role.createRepeater(atccallback, 0.1)
		else
			self.stopAttack(self)
		end
	end
end

function lock:stopAttack()
	if def.role.timer.__autoattack__ then
		def.role.stopRepeater(def.role.timer.__autoattack__)

		def.role.timer.__autoattack__ = nil

		self:stop()
	end
end

function lock:onExit()
	self:stopAttack()

	g_data.setting.base.autoatk = false
end

return lock
