local map = import(".map.map")
local magic = import(".common.magic")
local common = import(".common.common")
local ground = class("ground", function ()
	return display.newLayer()
end)
local settingLogic = import(".common.settingLogic")
local helper = import(".common.helper.helper")

table.merge(ground, {})

function ground:ctor()
	self.map = nil
	self.player = nil

	self:scale(g_data.setting.display.mapScale)

	self.helper = helper

	helper:init()
end

function ground:onEnter()
end

function ground:onExit()
end

function ground:update(dt)
	if self.map then
		self.map:update(dt)
	end
end

function ground:processMsg(msg, buf, bufLen)
	if not msg then
		return
	end

	local function tip(str, func)
		an.newMsgbox(str, func)
	end

	local ident = msg.ident

	if SM_LOGON == ident then
		local len1 = getRecordSize("TPlayerState")
		local len2 = getRecordSize("TPlayerStateEx")
		local v = net.record(bufLen == len1 and "TPlayerState" or "TPlayerStateEx", buf, bufLen)
		self.player = self.map:findRole(msg.recog, {
			isPlayer = true,
			roleid = msg.recog,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			feature = v:get("feature"),
			state = v:get("allBodyState")
		})

		self.helper:enterMap(map.mapid)
		net.send({
			CM_QUERYBAGITEMS
		})
		g_data.player:setRoleID(msg.recog)
		g_data.player:setSex(v:get("feature"):get("sex"))
		g_data.player:setAllowGroup(Lobyte(Loword(v:get("state"))) == 1)
		main_scene.ui:show()
		main_scene.ui:showPanel("minimap")
		g_data.mail:startSchedule()
	elseif SM_LOGON_64ID == ident then
		IAP.roleIdentify = buf

		IAP.init()
	elseif SM_NEWMAP == ident then
		if self.map then
			self.map:removeSelf()
		end

		self.map = map.new(net.str(buf)):addto(self)
		self.player = nil

		net.setWaitMsg(SM_LOGON)
	elseif SM_CHANGEMAP == ident then
		local strs = net.strs(buf)
		local params = {
			isPlayer = true,
			roleid = self.player.roleid,
			x = msg.param,
			y = msg.tag,
			dir = self.player.dir,
			feature = self.player.feature,
			state = self.player.state
		}
		local name = self.player.info.name
		local hitSpeed = self.player.hitSpeed

		if self.map then
			self.map:removeSelf()
		end

		self.map = map.new(strs[1]):addto(self)
		self.player = self.map:findRole(params.roleid, params)

		self.player.info:setHP(g_data.player.ability:get("HP"), g_data.player.ability:get("maxHP"))
		self.helper:enterMap(net.str(buf))

		if name.texts then
			self.player.info:setName(name.texts, name.color)
		end

		if name.color then
			self.player.info:setNameColor(name.color)
		end

		self.player.hitSpeed = hitSpeed

		main_scene.ui:hidePanel("npc")
		main_scene.ui:hidePanel("bigmapOther")
		main_scene.ui:hidePanel("stall")

		if main_scene.ui.panels.minimap then
			main_scene.ui.panels.minimap:reload()
		end

		main_scene.ui.console.controller.autoFindPath:singleMapPathStop()
		main_scene.ui.console.controller.autoFindPath:research()
	elseif SM_MAPINFO_EX == ident then
		g_data.map:setMapReplaceTable(buf, bufLen)
	elseif SM_SAFE_ZONE_INFO == ident then
		g_data.map:setSafeZone(msg.param, buf, bufLen)
	elseif SM_AREASTATE == ident then
		g_data.map:setMapState(msg.recog)
		main_scene.ui.console:call("bottom", "uptMap")
	elseif SM_MAPDESCRIPTION == ident then
		g_data.map:setMapTitle(net.strs(buf, string.char(13))[1])
		main_scene.ui.console:call("bottom", "uptMap")

		if main_scene.ui.panels.bigmap then
			main_scene.ui.panels.bigmap:updateTitle()
		end
	elseif SM_LEVELUP == ident then
		self.map:showEffectForName("levelup", {
			x = self.player.x,
			y = self.player.y
		})
	elseif SM_FEATURECHANGED == ident then
		local feature = nil

		if bufLen == getRecordSize("TFeature") then
			feature = net.record("TFeature", buf, bufLen)
		else
			feature = MakeLong(msg.param, msg.tag)
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			feature = feature,
			state = MakeLong(msg.series, 0)
		})
	elseif SM_CHARSTATUSCHANGED == ident then
		local state = net.record("TAllBodyState", buf, bufLen)

		if self.player.roleid == msg.recog then
			self.player:processMsg(ident, nil, nil, nil, nil, state)
		else
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				state = state
			})
		end
	elseif SM_USERNAME == ident then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			name = net.strs(buf, "\\"),
			nameColor = msg.param
		})
	elseif SM_CHANGENAMECOLOR == ident then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			nameColor = msg.param
		})
	elseif SM_CHANGELIGHT == ident then
		print("SM_CHANGELIGHT, 人物的照明程度？")
	elseif checkExist(ident, SM_HIDE, SM_GHOST, SM_DISAPPEAR) then
		if msg.recog ~= g_data.player.roleid and self.map then
			self.map:addMsg({
				remove = true,
				roleid = msg.recog
			})
		end
	elseif SM_ACT_GOOD == ident then
		self.player:executeSuccess()
		main_scene.ui.console.autoRat:onActGood()
	elseif SM_ACT_FAIL == ident then
		local x, y, dir = nil

		if msg.param > 0 and msg.tag > 0 then
			dir = msg.series
			y = msg.tag
			x = msg.param
		end

		self.player:executeFail(x, y, dir)
		main_scene.ui.console.autoRat:onActFail(x, y, dir)
	elseif SM_FIREON == ident then
		g_data.client:setLastTime("fire", true)
		g_data.player:setHitEnable("fire", true)
		common.addMsg("您的武器因精神火球而炙热", 219, 256)
	elseif SM_LNGHITONOFF == ident then
		if msg.recog == 0 then
			g_data.player:setHitEnable("long", true)
			common.addMsg("开启刺杀剑术", 219, 256)
		else
			g_data.player:setHitEnable("long", false)
			common.addMsg("关闭刺杀剑术", 219, 256)
		end
	elseif SM_WIDEHITONOFF == ident then
		if msg.recog == 0 then
			g_data.player:setHitEnable("wide", true)
		else
			g_data.player:setHitEnable("wide", false)
		end

		if not main_scene.ui.console.autoRat.enableRat then
			if msg.recog == 0 then
				common.addMsg("开启半月弯刀", 219, 256)
			else
				common.addMsg("关闭半月弯刀", 219, 256)
			end
		end
	elseif SM_POWER_OK == ident then
		g_data.player:setHitEnable("pow", true)
	elseif SM_SWORDHIT_ON == ident then
		if msg.recog == 0 then
			g_data.client:setLastTime("swordhit", true)
			g_data.player:setHitEnable("sword", true)
			common.addMsg("您的剑气已凝聚成形", 219, 256)
		end
	elseif SM_ITEMSHOW == ident then
		local itemid = msg.recog
		local x = msg.param
		local y = msg.tag
		local looks = msg.series
		local flooritem = net.record("TFloorItem", buf, string.len(buf))

		self.map:showItem(true, itemid, x, y, flooritem:get("name"), looks, flooritem:get("owner"), flooritem:get("state"))
	elseif SM_ITEMHIDE == ident then
		local itemid = msg.recog
		local x = msg.param
		local y = msg.tag

		self.map:showItem(false, itemid)
	elseif SM_DISAPPEAR == ident then
		print("SM_DISAPPEAR, 地上物品消失")
	elseif SM_SHOWEVENT == ident then
		if getRecordSize("TEventMessage") == bufLen then
			self.map:showEvent(msg.recog, Loword(msg.tag), msg.series, msg.param, net.record("TEventMessage", buf, bufLen))
		elseif getRecordSize("TEventMessage2") == bufLen then
			self.map:showEvent(msg.recog, Loword(msg.tag), msg.series, msg.param, net.record("TEventMessage2", buf, bufLen))
		end
	elseif SM_HIDEEVENT == ident then
		self.map:hideEvent(msg.recog)
	elseif SM_USEITEMMAGIC == ident then
		self.map:showEvent(msg.recog, msg.tag, msg.series, msg.param)
	elseif SM_OPENDOOR_OK == ident or SM_CLOSEDOOR == ident then
		self.map:setDoorState(SM_OPENDOOR_OK == ident, msg.param, msg.tag)
		g_data.client:setLastTime("openDoor")
	elseif SM_OPENDOOR_LOCK == ident then
		main_scene.ui:tip("此门被锁定.")
		g_data.client:setLastTime("openDoor")
	elseif SM_TURN == ident then
		local len1 = getRecordSize("TCharDesc")
		local len2 = getRecordSize("TNewCharDesc")
		local len3 = getRecordSize("TNewStateRec")
		local desc, roleMsg, job, name, nameColor = nil

		if bufLen == len1 then
			desc = net.record("TCharDesc", buf, bufLen)
		elseif bufLen == len2 then
			desc = net.record("TNewCharDesc", buf, bufLen)
		elseif len3 <= bufLen then
			desc, buf, bufLen = net.record("TNewStateRec", buf, bufLen)
			roleMsg = true
			job = desc:get("job")
			nameColor = desc:get("nameClr")

			if bufLen > 0 then
				local strs = net.strs(buf)

				if strs[1] then
					name = string.split(strs[1], "\\")
				end

				if strs[2] and string.byte(strs[2]) == string.byte("+") then
					local heroTeam = cWilIdxHeroTeamLord
					local username = string.sub(strs[2], 2, string.len(strs[2]))
				elseif strs[2] and string.byte(strs[2]) == string.byte("-") then
					local heroTeam = cWilIdxHeroTeamMember
					local username = string.sub(strs[2], 2, string.len(strs[2]))
				else
					local heroTeam = 0
					local username = strs[2]
				end
			end
		end

		if desc then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series),
				feature = desc:get("feature"),
				state = desc:get("status"),
				job = job,
				name = name,
				nameColor = nameColor
			})
		end
	elseif checkExist(ident, SM_WALK, SM_RUN, SM_BACKSTEP, SM_SKELETON, SM_ALIVE, SM_DEATH, SM_NOWDEATH, SM_RUSH, SM_RUSHKUNG, SM_HERO_RUSH, SM_HERO_RUSHKUNG, SM_MONRUSH) then
		if self.player and msg.recog ~= self.player.roleid or not checkExist(ident, SM_WALK, SM_RUN) then
			local len1 = getRecordSize("TCharDesc")
			local len2 = getRecordSize("TNewCharDesc")
			local desc = nil

			if bufLen == len1 then
				desc = net.record("TCharDesc", buf, bufLen)
			elseif bufLen == len2 then
				desc = net.record("TNewCharDesc", buf, bufLen)
			end

			if desc then
				self.map:addMsg({
					roleid = msg.recog,
					ident = ident,
					x = msg.param,
					y = msg.tag,
					dir = Lobyte(msg.series),
					feature = desc:get("feature"),
					state = desc:get("status")
				})
			end
		end
	elseif checkExist(ident, SM_HIT, SM_HEAVYHIT, SM_BIGHIT, SM_POWERHIT, SM_LONGHIT, SM_WIDEHIT, SM_HERO_LASTHIT, SM_HERO_LONGHIT, SM_SQUARE_HIT) then
		if msg.recog ~= self.player.roleid then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series)
			})
		end
	elseif SM_PHYSICAL_ATT == ident then
		local v = net.record("TClientPhyAttRec", buf, bufLen)
		local hitMode = v:get("hitMode")
		local newIdent = ident

		if hitMode == 1000 then
			newIdent = SM_HIT
		elseif hitMode == 1001 then
			newIdent = SM_HEAVYHIT
		elseif hitMode == 1002 then
			newIdent = SM_BIGHIT
		elseif hitMode == 1003 then
			newIdent = SM_POWERHIT
		elseif hitMode == 1004 then
			newIdent = SM_LONGHIT
		elseif hitMode == 1005 then
			newIdent = SM_WIDEHIT
		elseif hitMode == 1007 then
			newIdent = SM_FIREHIT
		elseif hitMode == 1011 then
			newIdent = SM_HERO_LONGHIT
		elseif hitMode == 1012 then
			newIdent = SM_HERO_LASTHIT
		elseif hitMode == 1013 then
			newIdent = SM_SQUARE_HIT
		elseif hitMode == 1015 then
			newIdent = SM_SWORD_HIT
		elseif hitMode == 1017 then
			newIdent = SM_HundredHit
		elseif hitMode == 1018 then
			newIdent = SM_HORIZONHIT
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = newIdent,
			x = v:get("x"),
			y = v:get("y"),
			dir = v:get("dir")
		})
	elseif SM_BUTCH == ident then
		if self.player.roleid ~= msg.recog then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series)
			})
		end
	elseif SM_FLYAXE == ident then
		local wl = net.record("TMessageBodyW", buf, bufLen)

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			roleParams = {
				target = MakeLong(wl:get("tag1"), wl:get("tag2")),
				x = wl:get("param1"),
				y = wl:get("param2")
			}
		})
	elseif SM_SPELL == ident then
		local magicId, magicLevel = nil

		if bufLen > 4 then
			magicId, buf, bufLen = net.int(buf, bufLen)

			if bufLen > 4 then
				magicLevel = net.int(buf, bufLen)
			end
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			roleParams = {
				targetX = msg.param,
				targetY = msg.tag,
				effect = {
					effectID = Byte(msg.series - 1),
					magicId = magicId,
					magicLevel = magicLevel
				}
			}
		})
	elseif SM_MAGICFIRE == ident then
		local target, magicLevel = nil

		if bufLen >= 4 then
			target, buf, bufLen = net.int(buf, bufLen)
		end

		if bufLen >= 4 then
			magicLevel = net.int(buf, bufLen)
		end

		self.map:addMsg({
			magic = {
				msg.recog,
				Lobyte(msg.series),
				Hibyte(msg.series),
				msg.param,
				msg.tag,
				target
			}
		})

		if msg.recog == g_data.player.roleid then
			g_data.client:setLastTime("spell", true)
		end
	elseif SM_MAGICFIRE_FAIL == ident then
		print("SM_MAGICFIRE_FAIL")
	elseif SM_DIGUP == ident then
		local wl = net.record("TMessageBodyWL", buf, bufLen)

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			feature = wl:get("param1")
		})
	elseif SM_DIGDOWN == ident then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series)
		})
	elseif SM_STRUCK == ident then
		local hp, mp, maxHp, maxMp = nil

		if bufLen == getRecordSize("TMessageBodyWL") then
			maxHp = msg.tag
			hp = msg.param
		elseif bufLen == getRecordSize("TStruckInfo") then
			local v = net.record("TStruckInfo", buf, bufLen)
			maxMp = v:get("maxMp")
			maxHp = v:get("maxHp")
			mp = v:get("mp")
			hp = v:get("hp")
		end

		if self.player.roleid == msg.recog then
			g_data.player.ability:set("HP", hp)
			g_data.player.ability:set("maxHP", maxHp)

			if mp and maxMp then
				settingLogic.missHp(g_data.player.ability:get("MP") - mp, false)
				g_data.player.ability:set("MP", mp)
				g_data.player.ability:set("maxMP", maxMp)
			end

			self.player.info:setHP(hp, maxHp, msg.series)
			settingLogic.missHp(msg.series, true)
		elseif self.player.hero and self.player.hero.roleid == msg.recog then
			g_data.hero.ability:set("HP", hp)
			g_data.hero.ability:set("maxHP", maxHp)

			if msg.series > 0 then
				settingLogic.missHp(msg.series, true, true)
			end

			if mp and maxMp then
				if g_data.hero.ability:get("MP") - mp > 0 then
					settingLogic.missHp(g_data.hero.ability:get("MP") - mp, false, true)
				end

				g_data.hero.ability:set("MP", mp)
				g_data.hero.ability:set("maxMP", maxMp)
			end

			self.player.hero.info:setHP(hp, maxHp, msg.series)
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			hp = hp,
			maxhp = maxHp,
			outhp = msg.series
		})
	elseif SM_SHOWBODY_EFFECT == ident then
		if msg.param == 11 then
			self.map:showEffectForName("protectionStruck", {
				roleid = msg.recog
			})
		elseif msg.param == 20 then
			self.map:showEffectForName("bloodlust", {
				roleid = msg.recog
			})
		end
	elseif SM_HEALTHSPELLCHANGED == ident then
		local hp, mp, maxHp, maxMp = nil

		if bufLen == getRecordSize("TMessageBodyWL") then
			local v = net.record("TMessageBodyWL", buf, bufLen)
			maxMp = v:get("tag2")
			maxHp = v:get("param2")
			mp = v:get("tag1")
			hp = v:get("param1")
		else
			maxHp = msg.series
			mp = msg.tag
			hp = msg.param
		end

		if self.player.roleid == msg.recog then
			local missHp = g_data.player.ability:get("HP") - hp
			local missMp = g_data.player.ability:get("MP") - mp

			g_data.player.ability:set("HP", hp)
			g_data.player.ability:set("maxHP", maxHp)
			g_data.player.ability:set("MP", mp)

			if maxMp then
				g_data.player.ability:set("maxMP", maxMp)
			end

			self.player.info:setHP(hp, maxHp)

			if missHp > 0 then
				settingLogic.missHp(missHp, true, false)
			end

			if missMp > 0 then
				settingLogic.missHp(missMp, false, false)
			end
		elseif self.player.hero and self.player.hero.roleid == msg.recog then
			local missHp = g_data.hero.ability:get("HP") - hp

			if missHp > 0 then
				settingLogic.missHp(missHp, true, true)
			end

			missHp = g_data.hero.ability:get("MP") - mp

			if missHp > 0 then
				settingLogic.missHp(missHp, false, true)
			end

			g_data.hero.ability:set("HP", hp)
			g_data.hero.ability:set("maxHP", maxHp)
			g_data.hero.ability:set("MP", mp)

			if maxMp then
				g_data.hero.ability:set("maxMP", maxMp)
			end

			self.player.hero.info:setHP(hp, maxHp)

			if main_scene.ui.panels.heroHead then
				main_scene.ui.panels.heroHead:upt()
			end
		else
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				hp = hp,
				maxhp = maxHp
			})
		end
	elseif SM_OPENHEALTH == ident then
		if self.player.roleid ~= msg.recog then
			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				hp = hp,
				maxhp = maxHp
			})
		end
	elseif SM_CLOSEHEALTH == ident then
		print("SM_CLOSEHEALTH")
	elseif SM_COMMON_INFORMATION == ident then
		if msg.param == 6 then
			g_data.player:setIsUnlimitedMove(msg.tag == 1)

			if msg.tag == 1 then
				common.addMsg("进入安全区!", display.COLOR_WHITE, display.COLOR_RED)
			else
				common.addMsg("离开安全区!", display.COLOR_WHITE, display.COLOR_RED)
			end
		end
	elseif checkExist(ident, SM_SPACEMOVE_SHOW, SM_SPACEMOVE_SHOW2) then
		local feature = nil

		if bufLen == getRecordSize("TCharDesc") then
			feature = net.record("TCharDesc", buf, bufLen):get("feature")
		elseif bufLen == getRecordSize("TNewCharDesc") then
			feature = net.record("TNewCharDesc", buf, bufLen):get("feature")
		else
			return true
		end

		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series),
			feature = feature,
			effect = {
				SM_SPACEMOVE_SHOW == ident and "spaceMoveShow" or "spaceMoveShow2",
				{
					roleid = msg.recog
				}
			}
		})
	elseif checkExist(ident, SM_SPACEMOVE_HIDE, SM_SPACEMOVE_HIDE2) then
		self.map:addMsg({
			effect = {
				SM_SPACEMOVE_HIDE == ident and "spaceMoveHide" or "spaceMoveHide2",
				{
					roleid = msg.recog
				}
			}
		})
	elseif SM_BIGMONMAGIC == ident then
		self.map:addMsg({
			effect = {
				"effectNum" .. msg.series,
				{
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_DRINKEXP_STATUS == ident then
		if msg.recog == g_data.player.roleid then
			g_data.player:setWineExp(msg.param, msg.tag)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif msg.recog == g_data.hero.roleid then
			g_data.hero:setWineExp(msg.param, msg.tag)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end
		end
	elseif SM_DRINK_STATUS == ident then
		if msg.recog == g_data.player.roleid then
			g_data.player:setdrinkStatus(msg.param, msg.tag)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif msg.recog == g_data.hero.roleid then
			g_data.hero:setdrinkStatus(msg.param, msg.tag)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end

			if main_scene.ui.panels.heroHead then
				main_scene.ui.panels.heroHead:upt()
			end
		end
	elseif SM_DRINK_DRUG_STATUS == ident then
		if msg.recog == g_data.player.roleid then
			g_data.player:setdrinkDrugStatus(msg.param, msg.tag)

			if main_scene.ui.panels.equip and main_scene.ui.panels.equip.page == "state" then
				main_scene.ui.panels.equip:showContent("state")
			end
		elseif msg.recog == g_data.hero.roleid then
			g_data.hero:setdrinkDrugStatus(msg.param, msg.tag)

			if main_scene.ui.panels.heroEquip and main_scene.ui.panels.heroEquip.page == "state" then
				main_scene.ui.panels.heroEquip:showContent("state")
			end

			if main_scene.ui.panels.heroHead then
				main_scene.ui.panels.heroHead:upt()
			end
		end
	elseif SM_HERO_LOGON == ident then
		sound.playSound(sound.hero_login)

		if getRecordSize("TNewHeroLook") == bufLen then
			local desc = net.record("TNewHeroLook", buf, bufLen)

			self.map:addMsg({
				roleid = msg.recog,
				ident = ident,
				x = msg.param,
				y = msg.tag,
				dir = Lobyte(msg.series),
				feature = desc:get("feature"),
				state = desc:get("status")
			})
			g_data.hero:setRoleID(msg.recog)
			g_data.hero:setSex(desc:get("feature"):get("sex"))

			if self.map.player and not self.map.player.hero then
				self.map.player.hero = self.map:findRole(msg.recog)
			end

			main_scene.ui:showPanel("heroHead")
		end
	elseif SM_HERO_LOGOUT == ident then
		sound.playSound(sound.hero_logout)

		self.player.hero = nil

		g_data.hero:_data_reset()
		g_data.heroBag:_data_reset()
		g_data.heroEquip:_data_reset()
		main_scene.ui.console:call("btnHeroSkill", "hero_upt_union")
		main_scene.ui:hidePanel("heroHead")
	elseif SM_HERO_LOGMAGIC == ident then
		self.map:addMsg({
			effect = {
				"heroBorn",
				{
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_HERO_QUITMAGIC == ident then
		self.map:addMsg({
			effect = {
				"heroHide",
				{
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_HERO_NAME == ident then
		local name = net.str(buf)
		local heroType = msg.param
		local heroRank = msg.tag

		g_data.hero:setName(name, heroType, heroRank)
	elseif checkExist(ident, SM_UNITEHIT0, SM_UNITEHIT1, SM_UNITEHIT2) then
		self.map:addMsg({
			roleid = msg.recog,
			ident = ident,
			x = msg.param,
			y = msg.tag,
			dir = Lobyte(msg.series)
		})
	elseif SM_HERO_SPLITSHADOW == ident then
		self.map:addMsg({
			effect = {
				"heroSplistShadow",
				{
					roleid = msg.recog,
					x = msg.param,
					y = msg.tag
				}
			}
		})
	elseif SM_HERO_HELPOP_OK == ident then
		if msg.recog == 1 then
			if main_scene.ui.console.controller.heroLock then
				main_scene.ui.console.controller:toggleHeroLock()
				main_scene.ui.console:setWidgetSelect("btnHeroLock", main_scene.ui.console.controller.heroLock)
			end
		elseif msg.recog == 2 and main_scene.ui.console.controller.heroGuard then
			main_scene.ui.console.controller:toggleHeroGuard()
			main_scene.ui.console:setWidgetSelect("btnHeroGuard", main_scene.ui.console.controller.heroGuard)
		end
	elseif SM_SHOWHELPER == ident then
		if msg.recog == 1 then
			-- Nothing
		elseif msg.recog == 2 then
			self.helper.runner.onKilledMonster(net.str(buf))
		end
	elseif SM_SLAVE_BORN == ident then
		if buf then
			g_data.player:addSlave(net.str(buf))
		end
	elseif SM_SLAVE_VANISH == ident then
		if buf then
			g_data.player:removeSlave(net.str(buf))
		end
	elseif SM_EXEC_FRESHMAN_TASK_CMD == ident then
		local errorMsg = {
			[-3.0] = "不能再次使用",
			[-2.0] = "无此任务",
			[-1.0] = "未知错误"
		}

		if errorMsg[msg.recog] then
			main_scene.ui:tip(errorMsg[msg.recog])
		end
	else
		return false
	end

	return true
end

return ground
