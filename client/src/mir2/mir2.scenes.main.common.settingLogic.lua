local common = import(".common")
local settingLogic = {}
local protectedInfo = {}
local protectedCache = {}
protectedInfo["比奇传送石"] = {
	"比奇传送石",
	"比奇传送石(赠)",
	"比奇传送石(福)",
	"比奇传送石(绑)",
	"比奇传送石(礼)",
	"比奇传送石(佑)"
}
protectedInfo["盟重传送石"] = {
	"盟重传送石",
	"盟重传送石(赠)",
	"盟重传送石(福)",
	"盟重传送石(绑)",
	"盟重传送石(礼)",
	"盟重传送石(佑)"
}
protectedInfo["随机传送石"] = {
	"随机传送石",
	"随机传送石(赠)",
	"随机传送石(福)",
	"随机传送石(绑)",
	"随机传送石(礼)",
	"随机传送石(佑)"
}

function settingLogic.initDrugs()
	settingLogic.initedDrugs = true

	local function func(drugs)
		local new = clone(drugs)

		for k, v in pairs(drugs) do
			local itemName, newItem = nil

			if type(v) == "table" then
				itemName = v[1] .. "(赠)"
				newItem = clone(v)
				newItem[1] = itemName
			else
				itemName = v .. "(赠)"
				newItem = itemName
			end

			for k, v in pairs(def.items) do
				if type(v) == "table" and v.get and v:get("name") == itemName then
					table.insert(new, newItem)
				end
			end
		end

		return new
	end

	settingLogic.hpObjList = func({
		"新手金创药",
		"强效金创药",
		"金创药中量",
		"金创药(中量)",
		"金创药(小量)"
	})
	settingLogic.mpObjList = func({
		"新手魔法药",
		"强效魔法药",
		"魔法药中量",
		"魔法药(中量)",
		"魔法药(小量)"
	})
	settingLogic.hpObjListWithDelay = func({
		{
			"新手金创药",
			2
		},
		{
			"强效金创药",
			4
		},
		{
			"金创药中量",
			3
		},
		{
			"金创药(中量)",
			3
		},
		{
			"金创药(小量)",
			2
		}
	})
	settingLogic.mpObjListWithDelay = func({
		{
			"新手魔法药",
			3
		},
		{
			"强效魔法药",
			5
		},
		{
			"魔法药中量",
			4
		},
		{
			"魔法药(中量)",
			4
		},
		{
			"魔法药(小量)",
			3
		}
	})
	settingLogic.instantDrug = func({
		"太阳水",
		"强效太阳水",
		"万年雪霜",
		"疗伤药",
		"疗伤药(任务)"
	})
end

function settingLogic.update(dt)
	if not main_scene then
		return
	end

	local player = main_scene.ground.player
	local map = main_scene.ground.map

	if not player or not map then
		return
	end

	if not player.die and main_scene then
		local function useItem(isHero, data, objList)
			local obj, space = nil
			local bag = isHero and g_data.heroBag or g_data.bag

			if type(objList) == "table" then
				for i, v in ipairs(objList) do
					local item = v
					local sp = nil

					if type(v) == "table" then
						sp = item[2]
						item = item[1]
					end

					local count = bag:getItemCount(item)

					if count > 0 then
						obj = item
						space = sp

						break
					end
				end

				obj = obj or ""
			else
				obj = objList
			end

			if space then
				data.space = space * 1000
			end

			local itemData, where = bag:getItemWithName(obj)

			if where == "quick" then
				itemData = itemData.item
			end

			if itemData and bag:use("eat", itemData:get("makeIndex"), {
				quick = where == "quick"
			}) then
				data.lastTime = socket.gettime()

				net.send({
					isHero and CM_HERO_EAT or CM_EAT,
					recog = itemData:get("makeIndex")
				}, {
					itemData.getVar("name")
				})

				if isHero then
					if main_scene.ui.panels.heroBag then
						main_scene.ui.panels.heroBag:delItem(itemData:get("makeIndex"))
					end
				elseif main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:delItem(itemData:get("makeIndex"))
				end
			end
		end

		local function check(isHero, data, cur, max, objList, autoDisable)
			if data.enable then
				local tmpUsers = protectedInfo[data.uses] or data.uses
				objList = objList or tmpUsers
				local min = nil

				if data.isPercent then
					min = data.value * max
				else
					min = data.value
				end

				if cur <= min and (not data.lastTime or socket.gettime() - data.lastTime > data.space / 1000) then
					if type(objList) == "function" then
						objList()
					elseif data.uses == "回城" then
						common.backHome()
					else
						if autoDisable and #objList == 1 and not string.find(objList[1], "随机") then
							data.enable = false

							cache.saveSetting(common.getPlayerName(), "protected")
						end

						useItem(isHero, data, objList)
					end

					return true
				end
			end
		end

		local function checkMiss(isHero, data, cur, max, objList)
			if data.enable then
				objList = objList or data.uses
				local min = nil

				if data.isPercent then
					min = data.value / 100 * max
				else
					min = data.value
				end

				min = max - min

				if cur <= min and (not data.lastTime or socket.gettime() - data.lastTime > data.space / 1000) then
					if type(objList) == "function" then
						objList()
					else
						useItem(isHero, data, objList)
					end
				end
			end
		end

		local function checkMissTime(isHero, data, objList)
			if data.enable and (not data.lastTime or socket.gettime() - data.lastTime > data.space / 1000) then
				useItem(isHero, data, objList)
			end
		end

		if not g_data.player.initedAbility then
			return
		end

		local curHP = g_data.player.ability:get("HP")
		protectedCache.lastHP = protectedCache.lastHP or curHP

		if curHP and curHP - protectedCache.lastHP < 0 then
			check(false, g_data.setting.protected.role.hp, curHP, nil)
		end

		protectedCache.lastHP = curHP
		local curMP = g_data.player.ability:get("MP")
		protectedCache.lastMP = protectedCache.lastMP or curMP

		if curMP - protectedCache.lastMP < 0 then
			check(false, g_data.setting.protected.role.mp, g_data.player.ability:get("MP"), g_data.player.ability:get("MP"), nil)
		end

		protectedCache.lastMP = curMP

		if not settingLogic.initedDrugs then
			settingLogic.initDrugs()
		end

		local function checkDrug(isHero, type)
			local withPercent = g_data.setting.drugs[type .. "Setting"].withPercent
			local data = nil
			local hpObj = settingLogic.hpObjList
			local mpObj = settingLogic.mpObjList

			if withPercent then
				data = g_data.setting.drugs[type].percentDrug
				hpObj = settingLogic.hpObjListWithDelay
				mpObj = settingLogic.mpObjListWithDelay
			else
				data = g_data.setting.drugs[type].numberDrug
			end

			local playerData = isHero and g_data.hero or g_data.player
			local tmpHP = playerData.ability:get("HP")
			local tmpMP = playerData.ability:get("MP")

			check(isHero, data.normalHP, tmpHP, playerData.ability:get("maxHP"), hpObj)
			check(isHero, data.normalMP, tmpMP, playerData.ability:get("maxMP"), mpObj)
			check(isHero, data.quickHP, tmpHP, playerData.ability:get("maxHP"), settingLogic.instantDrug)
			check(isHero, data.quickMP, tmpMP, playerData.ability:get("maxMP"), settingLogic.instantDrug)
		end

		if def.gameVersionType == "185" then
			checkDrug(false, "role")
			checkDrug(true, "hero")
		else
			checkDrug(false, "role")
		end

		if g_data.setting.base.firePeral and g_data.client:checkLastTime("firePeral", 0.1) then
			g_data.client:setLastTime("firePeral", true)
			useItem(false, {}, "火龙珠")
		end

		local function autoUnpack(isHero, data)
			if data:getFreeCount() >= 5 then
				for k, v in pairs(g_data.setting.autoUnpack) do
					if v.enable then
						local cnt = data:getItemCount(v.name)

						if cnt <= v.min then
							local itemData = data:getItemWithName(v.pack)

							if itemData and data:use("eat", itemData:get("makeIndex")) then
								net.send({
									isHero and CM_HERO_EAT or CM_EAT,
									recog = itemData:get("makeIndex")
								}, {
									itemData.getVar("name")
								})

								if isHero then
									if main_scene.ui.panels.heroBag then
										main_scene.ui.panels.heroBag:delItem(itemData:get("makeIndex"))
									end
								elseif main_scene.ui.panels.bag then
									main_scene.ui.panels.bag:delItem(itemData:get("makeIndex"))
								end
							end
						end
					end
				end
			end
		end

		if g_data.setting.base.autoUnpack then
			autoUnpack(false, g_data.bag)
			autoUnpack(true, g_data.heroBag)
		end

		if g_data.setting.base.warningDura and g_data.client:checkLastTime("warningDura", 60) then
			g_data.client:setLastTime("warningDura", true)

			for k, v in pairs(g_data.equip.items) do
				if tonumber(k) ~= U_BUJUK and Word(v:get("dura")) / Word(v:get("duraMax")) < 0.2 then
					common.addMsg("提示:您的[" .. (v.getVar("name") or "") .. "]持久力低于20%,请及时进行修理或更换!", def.colors.clRed, def.colors.clWhite)
				end
			end

			for k, v in pairs(g_data.heroEquip.items) do
				if tonumber(k) ~= U_BUJUK and Word(v:get("dura")) / Word(v:get("duraMax")) < 0.2 then
					common.addMsg("提示:您英雄的[" .. (v.getVar("name") or "") .. "]持久力低于20%,请及时进行修理或更换!", def.colors.clRed, def.colors.clWhite)
				end
			end
		end

		if g_data.setting.base.lockColor then
			local roleid = nil

			for k, v in pairs(main_scene.ui.console.controller.lock.target) do
				if v then
					roleid = v

					break
				end
			end

			local preSelected = settingLogic.preSelect

			if not preSelected or preSelected.roleid ~= roleid then
				if preSelected then
					preSelected:unselected()
				end

				if roleid then
					local role = map:findRole(roleid)

					if role then
						role:selected()

						settingLogic.preSelect = role
					end
				end
			end
		end

		if g_data.player.job == 0 then
			if g_data.setting.job.autoFire and g_data.client:checkLastTime("fire", 11) then
				local data = g_data.player:getMagic(26)

				if data and data:get("needMp") <= g_data.player.ability:get("MP") then
					g_data.client:setLastTime("fire", true)
					net.send({
						CM_SPELL,
						recog = target,
						param = player.x,
						tag = player.y,
						series = data:get("magicId")
					})
				end
			end

			if g_data.setting.job.autoSword and g_data.client:checkLastTime("swordhit", 11) then
				local data = g_data.player:getMagic(58)

				if data and data:get("needMp") <= g_data.player.ability:get("MP") then
					g_data.client:setLastTime("swordhit", true)
					net.send({
						CM_SPELL,
						recog = target,
						param = player.x,
						tag = player.y,
						series = data:get("magicId")
					})
				end
			end

			local target = main_scene.ui.console.controller.lock.target.attack

			if g_data.setting.job.autoWide and g_data.client:checkLastTime("spell", 1) and target then
				local data = g_data.player:getMagic(25)

				if data then
					local role = map:findRole(main_scene.ui.console.controller.lock.target.attack)

					if role and math.max(math.abs(role.x - player.x), math.abs(role.y - player.y)) == 1 then
						local open = false
						local dir = def.role.getMoveDir(player.x, player.y, role.x, role.y)
						local check = {
							-1,
							1,
							2
						}

						for i, v in ipairs(check) do
							local nearDir = dir + v

							if nearDir < 0 then
								nearDir = nearDir + 8
							end

							if nearDir > 7 then
								nearDir = nearDir - 8
							end

							local config = def.role.dir["_" .. nearDir]
							local role = map:findRoelWithPos(player.x + config[1], player.y + config[2])
							open = role and not role.die and role.__cname ~= "npc"

							if open then
								break
							end
						end

						if not open ~= not g_data.player.hitEnables.wide then
							g_data.client:setLastTime("spell", true)
							net.send({
								CM_SPELL,
								recog = target,
								param = player.x,
								tag = player.y,
								series = data:get("magicId")
							})
						end
					end
				end
			end
		end

		if g_data.setting.job.autoSkill.enable then
			local data = g_data.player:getMagic(g_data.setting.job.autoSkill.magicId)

			if data and g_data.client:checkLastTime("autoSkill", g_data.setting.job.autoSkill.space) then
				g_data.client:setLastTime("autoSkill", true)
				main_scene.ui.console.btnCallbacks:handle("skill", g_data.setting.job.autoSkill.magicId, data)
			end
		end
	end
end

function settingLogic.missHp(value, isHp, isHero)
	if value < 0 then
		return
	end

	local function useItem(data, objList)
		local obj = nil
		local bag = isHero and g_data.heroBag or g_data.bag

		if type(objList) == "table" then
			for i, v in ipairs(objList) do
				local count = bag:getItemCount(v)

				if count > 0 then
					obj = v

					break
				end
			end

			obj = obj or ""
		else
			obj = objList
		end

		local itemData, where = bag:getItemWithName(obj)

		if where == "quick" then
			itemData = itemData.item
		end

		if itemData and bag:use("eat", itemData:get("makeIndex"), {
			quick = where == "quick"
		}) then
			data.lastTime = socket.gettime()

			net.send({
				isHero and CM_HERO_EAT or CM_EAT,
				recog = itemData:get("makeIndex")
			}, {
				itemData.getVar("name")
			})

			if where == "bag" then
				if isHero then
					if main_scene.ui.panels.heroBag then
						main_scene.ui.panels.heroBag:delItem(itemData:get("makeIndex"))
					end
				elseif main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:delItem(itemData:get("makeIndex"))
				end
			end
		end
	end

	local function check2(data, cur, objList)
		if data.enable then
			objList = objList or data.uses

			if cur >= 10 and data.value <= cur and (not data.lastTime or socket.gettime() - data.lastTime > data.space / 1000) then
				if type(objList) == "function" then
					objList()
				else
					useItem(data, objList)
				end
			end
		end
	end

	local function smallExit(data, cur)
		if data.enable and data.uses == "小退" then
			local min = data.value

			if cur <= min then
				main_scene:smallExit()
			end
		end
	end

	local function heroExit(data, cur)
		if data.enable and main_scene.ground.player.hero then
			local min = data.value

			if cur <= min then
				net.send({
					CM_HERO_LOGOUT,
					recog = main_scene.ground.player.hero.roleid
				})
			end
		end
	end

	if isHero then
		if isHp then
			heroExit(g_data.setting.protected.hero.hp, g_data.hero.ability:get("HP") - value)
		else
			heroExit(g_data.setting.protected.hero.mp, g_data.hero.ability:get("MP") - value)
		end
	elseif isHp then
		smallExit(g_data.setting.protected.role.hp, g_data.player.ability:get("HP") - value)
	else
		smallExit(g_data.setting.protected.role.mp, g_data.player.ability:get("MP") - value)
	end
end

function settingLogic.isRattingItem(itemName)
	if g_data.setting.item.pickOnRatting or not g_data.setting.item.filt[itemName] or g_data.setting.item.filt[itemName].pickOnRatting then
		return true
	end
end

function settingLogic.isGoodItem(itemName)
	if g_data.setting.item.hindGood or not g_data.setting.item.filt[itemName] or g_data.setting.item.filt[itemName].isGood then
		return true
	end
end

function settingLogic.showItemName(itemName)
	if g_data.setting.item.showName or not g_data.setting.item.filt[itemName] or g_data.setting.item.filt[itemName].hintName then
		return true
	end
end

function settingLogic.isPickUp(itemName)
	if g_data.setting.item.pickUp or not g_data.setting.item.filt[itemName] or g_data.setting.item.filt[itemName].pickUp then
		return true
	end
end

function settingLogic.filterChat(text, ident, msg)
	if SM_WHISPER == ident and (g_data.setting.chat.whisperLimit == 0 or msg.tag < g_data.setting.chat.whisperLimit) then
		return false
	end

	return true
end

return settingLogic
