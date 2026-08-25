local common = import(".common")
local settingLogic = {}
local protectedInfo = {}
local protectedCache = {}

protectedInfo.比奇传送石 = {
	"比奇传送石",
	"比奇传送石(赠)",
	"比奇传送石(福)",
	"比奇传送石(绑)",
	"比奇传送石(礼)",
	"比奇传送石(佑)"
}
protectedInfo.盟重传送石 = {
	"盟重传送石",
	"盟重传送石(赠)",
	"盟重传送石(福)",
	"盟重传送石(绑)",
	"盟重传送石(礼)",
	"盟重传送石(佑)"
}
protectedInfo.随机传送石 = {
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
			local itemName
			local newItem

			if type(v) == "table" then
				itemName = v[1] .. "(赠)"
				newItem = clone(v)
				newItem[1] = itemName
			else
				itemName = v .. "(赠)"
				newItem = itemName
			end

			for k2, v2 in pairs(def.items) do
				if type(v2) == "table" and v2.get and v2:get("name") == itemName then
					table.insert(new, newItem)
				end
			end
		end

		return new
	end

	settingLogic.hpObjList = func(def.drugsHP or {
		"强效金创药",
		"金创药中量",
		"金创药(中量)",
		"金创药(小量)"
	})
	settingLogic.mpObjList = func(def.drugsMP or {
		"强效魔法药",
		"魔法药中量",
		"魔法药(中量)",
		"魔法药(小量)"
	})
	settingLogic.hpObjListWithDelay = func(def.drugsDelayOfHP or {
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
	settingLogic.mpObjListWithDelay = func(def.drugsDelayOfMP or {
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
	settingLogic.instantDrug = func(def.drugsInstant or {
		"太阳水",
		"强效太阳水",
		"万年雪霜",
		"疗伤药",
		"疗伤药(任务)"
	})
end

local function useItem(isHero, data, objList)
	local obj
	local space
	local bag = isHero and g_data.heroBag or g_data.bag

	if type(objList) == "table" then
		for i, v in ipairs(objList) do
			local item = v
			local sp

			if type(v) == "table" then
				sp = item[2]
				item = item[1]
			end

			if bag:getItemCount(item) > 0 then
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

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

local function check(isHero, data, cur, max, value2, value3, value4)
	if data.enable then
		local tmpUsers = protectedInfo[data.uses] or data.uses
		local objList = value2 or tmpUsers
		local min

		if data.isPercent then
			if value4 then
				min = data.value / 100 * max
			else
				min = data.value * max
			end
		else
			min = data.value
		end

		local value = def.forbiddenProWhenLogin and def.role.logined

		if cur <= min and value4 and not isHero and not value then
			if data.uses == "小退" then
				main_scene:smallExit()
			elseif data.uses == "回城" then
				common.backHome()
			end
		end

		if cur <= min and (not data.lastTime or socket.gettime() - data.lastTime > data.space / 1000) then
			if type(objList) == "function" then
				if not value then
					objList()
				end
			else
				if value3 and objList == 1 and not string.find(objList[1], "随机") then
					data.enable = false

					cache.saveSetting(common.getPlayerName(), "protected")
				end

				useItem(isHero, data, objList)
			end

			return true
		end
	end
end

local function callback(self, value)
	if self.enable and self.uses == "小退" and value <= self.value then
		main_scene:smallExit()
	end
end

function settingLogic.missHp(value, isHp, isHero)
	if value < 0 then
		return
	end

	if def.role.mainsetting.banProtect then
		return
	end

	local function callback(self, value)
		if self.enable and main_scene.ground.player.hero and value <= self.value then
			net.send({
				CM_HERO_LOGOUT,
				recog = main_scene.ground.player.hero.roleid
			})
		end
	end

	if isHero then
		if isHp then
			callback(g_data.setting.protected.hero.hp, g_data.hero.ability:get("HP"))
		else
			callback(g_data.setting.protected.hero.mp, g_data.hero.ability:get("MP"))
		end
	elseif isHp then
		check(false, g_data.setting.protected.role.hp, g_data.player.ability:get("HP"), g_data.player.ability:get("maxHP"), nil, nil, true)
	else
		check(false, g_data.setting.protected.role.mp, g_data.player.ability:get("MP"), g_data.player.ability:get("maxMP"), nil, nil, true)
	end
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
		local function checkMiss(isHero, data, cur, max, objList2)
			if data.enable then
				local objList = objList2 or data.uses
				local min

				if data.isPercent then
					min = data.value / 100 * max
				else
					min = data.value
				end

				if cur <= max - min and (not data.lastTime or socket.gettime() - data.lastTime > data.space / 1000) then
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

		if not def.role.mainsetting.banProtect then
			local curHP = g_data.player.ability:get("HP")

			protectedCache.lastHP = protectedCache.lastHP or curHP

			if curHP and curHP - protectedCache.lastHP < 0 then
				check(false, g_data.setting.protected.role.hp, curHP, g_data.player.ability:get("maxHP"), nil, nil, true)
			end

			protectedCache.lastHP = curHP

			local curMP = g_data.player.ability:get("MP")

			protectedCache.lastMP = protectedCache.lastMP or curMP

			if curMP - protectedCache.lastMP < 0 then
				check(false, g_data.setting.protected.role.mp, curMP, g_data.player.ability:get("maxMP"), nil, nil, true)
			end

			protectedCache.lastMP = curMP
		end

		if not settingLogic.initedDrugs then
			settingLogic.initDrugs()
		end

		local function checkDrug(isHero, type)
			local withPercent = g_data.setting.drugs[type .. "Setting"].withPercent
			local data
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

		if main_scene.ground.player.hero then
			checkDrug(false, "role")
			checkDrug(true, "hero")
		else
			checkDrug(false, "role")
		end

		if g_data.setting.base.firePeral and g_data.client:checkLastTime("firePeral", 0.1) then
			g_data.client:setLastTime("firePeral", true)
			useItem(false, {}, "火龙珠")
		end

		if g_data.setting.autoRat.autoStuffs and def.role.mainsetting.autoStuffs then
			local text = def.role.mainsetting.autoStuffs

			if type(text) == "string" and text:find(",") ~= nil then
				text = string.split(text, ",")

				if g_data.client:checkLastTime("jyzz", 5) then
					g_data.client:setLastTime("jyzz", true)

					for _, item in ipairs(text) do
						useItem(false, {}, item)
					end
				end
			elseif g_data.client:checkLastTime("jyzz", 5) then
				g_data.client:setLastTime("jyzz", true)
				useItem(false, {}, text)
			end
		end

		if g_data.setting.base.autoUseRepair and g_data.client:checkLastTime("repair", 60) then
			g_data.client:setLastTime("repair", true)
			useItem(false, {}, "修复神水")

			if g_data.hero.roleid ~= 0 then
				useItem(true, {}, "修复神水")
			end
		end

		local function autoUnpack(isHero, data)
			if data:getFreeCount() >= 6 then
				for k, v in pairs(g_data.setting.autoUnpack) do
					if v.enable and data:getItemCount(v.name) <= v.min then
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

			for k2, v2 in pairs(g_data.heroEquip.items) do
				if tonumber(k2) ~= U_BUJUK and Word(v2:get("dura")) / Word(v2:get("duraMax")) < 0.2 then
					common.addMsg("提示:您英雄的[" .. (v2.getVar("name") or "") .. "]持久力低于20%,请及时进行修理或更换!", def.colors.clRed, def.colors.clWhite)
				end
			end
		end

		if g_data.setting.base.lockColor then
			local roleid

			for k3, v3 in pairs(main_scene.ui.console.controller.lock.target) do
				if v3 then
					roleid = v3

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

		local function callback(self, point)
			return math.max(math.abs(self.x - point.x), math.abs(self.y - point.y))
		end

		local function callback2()
			if not AutoCusSkills or LocalAutoCusSkills then
				AutoCusSkills = {}

				for _, csSkill in pairs(def.csSkills) do
					if (csSkill.job == 3 or csSkill.job == g_data.player.job) and csSkill.autoSkill then
						local response = csSkill
						local data = g_data.player:getMagic(csSkill.magicId)

						if data then
							response.data = data

							local config = def.magic.getMagicConfigByUid(csSkill.magicId, player)

							if config then
								response.config = config
								AutoCusSkills[csSkill.key] = response
							end
						end
					end
				end

				LocalAutoCusSkills = false
			end

			if def.csSkills and def.ccy.isOpenCSSkill and def.ccy.isOpenCSSkill() and AutoCusSkills and g_data.client:checkLastTime("spell", 2) then
				for _2, autoCusSkill in pairs(AutoCusSkills) do
					if g_data.setting.job[autoCusSkill.key] and (autoCusSkill.type == "lockImmediateDis" or autoCusSkill.type == "lockImmediate" or autoCusSkill.type == "lockImmediateSill") then
						local value = def.ccy.calcCDTime(autoCusSkill.data.delayTime, autoCusSkill.config, autoCusSkill.cdtime)

						if g_data.client:checkLastTime("magic" .. tostring(autoCusSkill.magicId), value) and not g_data.player.hitEnables[autoCusSkill.key] then
							g_data.player:setHitEnable(autoCusSkill.key, true)

							if autoCusSkill.manualSelect then
								common.addMsg(autoCusSkill.name .. "已经自动开启.", 219, 256)
							end

							break
						end
					end
				end
			end

			if AutoCusSkills and g_data.client:checkLastTime("spell", 2) then
				for _3, autoCusSkill2 in pairs(AutoCusSkills) do
					if g_data.setting.job[autoCusSkill2.key] then
						local value2 = def.ccy.calcCDTime(autoCusSkill2.data.delayTime, autoCusSkill2.config, autoCusSkill2.cdtime)
						local text = "magic" .. tostring(autoCusSkill2.magicId)

						if autoCusSkill2.type == "immediate" and g_data.client:checkLastTime(text, value2) and main_scene.ui.console.controller.callAutoSkill and main_scene.ui.console.autoRat.enableRat then
							if autoCusSkill2.isDBSkill then
								if main_scene.ui.console.controller:useMagic(player.x, player.y, player.dir, autoCusSkill2.data) then
									g_data.player:setHitEnable(autoCusSkill2.key, false)

									break
								end
							else
								main_scene.ui.console.controller:callAutoSkill(autoCusSkill2.key)

								break
							end
						end
					end
				end
			end
		end

		if g_data.player.job == 0 and (not def.openHorse or not def.stateIsHave(player.state, "stHorse")) then
			local value
			local value2
			local value3
			local target = main_scene.ui.console.controller.lock.target.attack
			local magicConfigByUid = def.magic.getMagicConfigByUid(26, player)
			local value4

			if magicConfigByUid and magicConfigByUid.cmDelaytime then
				value4 = magicConfigByUid.cmDelaytime
			end

			if g_data.setting.job.autoFire and g_data.client:checkLastTime("fire", value4 or def.ccy.getAttackSKillCDs("fire")) then
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

			local magicConfigByUid2 = def.magic.getMagicConfigByUid(58, player)
			local value5

			if magicConfigByUid2 and magicConfigByUid2.cmDelaytime then
				value5 = magicConfigByUid2.cmDelaytime
			end

			if g_data.setting.job.autoSword and g_data.client:checkLastTime("swordhit", value5 or def.ccy.getAttackSKillCDs("swordhit")) then
				local data2 = g_data.player:getMagic(58)

				if data2 and data2:get("needMp") <= g_data.player.ability:get("MP") then
					g_data.client:setLastTime("swordhit", true)
					net.send({
						CM_SPELL,
						recog = target,
						param = player.x,
						tag = player.y,
						series = data2:get("magicId")
					})
				end
			end

			if g_data.setting.job.autoWide and g_data.client:checkLastTime("spell", 1) and target then
				local data3 = g_data.player:getMagic(25)

				if data3 then
					local role2 = map:findRole(target)
					local count = 1

					if g_data.player.cmAbil and g_data.player.cmAbil.AttackDis then
						count = tonumber(g_data.player.cmAbil.AttackDis) or 1
					end

					if role2 and math.max(math.abs(role2.x - player.x), math.abs(role2.y - player.y)) == count then
						local open = false
						local dir = def.role.getMoveDir(player.x, player.y, role2.x, role2.y)
						local check = {
							-1,
							1,
							2
						}

						for i, v4 in ipairs(check) do
							local nearDir = dir + v4

							if nearDir < 0 then
								nearDir = nearDir + 8
							end

							if nearDir > 7 then
								nearDir = nearDir - 8
							end

							local config = def.role.dir["_" .. nearDir]
							local role3 = map:findRoelWithPos(player.x + config[1], player.y + config[2])

							open = role3 and not role3.die and role3.__cname ~= "npc"

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
								series = data3:get("magicId")
							})
						end
					end
				end
			end
		end

		if def.csSkills and def.ccy.isOpenCSSkill and def.ccy.isOpenCSSkill() and (not def.openHorse or not def.stateIsHave(player.state, "stHorse")) then
			callback2()
		end

		if g_data.setting.job.autoSkill.enable and (not def.openHorse or not def.stateIsHave(player.state, "stHorse")) then
			local data4 = g_data.player:getMagic(g_data.setting.job.autoSkill.magicId)

			if data4 and g_data.client:checkLastTime("autoSkill", g_data.setting.job.autoSkill.space) then
				g_data.client:setLastTime("autoSkill", true)

				data4.isAuto = true

				main_scene.ui.console.btnCallbacks:handle("skill", g_data.setting.job.autoSkill.magicId, data4)
			end
		end

		if def.showItemNums and def.btnTags then
			for key, btnTag in pairs(def.btnTags) do
				local lbItemNumOwner = main_scene.ui.console:get(key)

				if lbItemNumOwner and lbItemNumOwner.lbItemNum then
					local itemCount = g_data.bag:getItemCount(btnTag.tagItem) + g_data.bag:getBindCount(btnTag.tagItem)

					lbItemNumOwner.lbItemNum:setText(tostring(itemCount))
				end
			end

			for _2, widget in pairs(main_scene.ui.console.widgets) do
				if widget.config.class == "btnMove" and (widget.config.btntype == "prop" or widget.config.btntype == "custom") then
					widget:itemUptNums()
				end
			end
		end
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
