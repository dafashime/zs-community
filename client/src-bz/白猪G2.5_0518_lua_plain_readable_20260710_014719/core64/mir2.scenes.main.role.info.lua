local mapDef = import("..map.def")
local common = import("..common.common")
local magicParticle = import("..common.magicParticle")
local info = require("mir2.scenes.main.role.info1")
local value = cc.Node.setPosition

function info:setLock(islocked)
	self.islocked = islocked
end

local cc2 = require("mir2.cc")

function info:ctor(role, map)
	self.islocked = false
	self.map = map
	self.role = role

	local value2 = role.__cname

	self.name = {
		color = value2 == "npc" and 250,
		texts = {},
		labels = {}
	}
	self.fenghaoSpirts = {}
	self.hp = {}
	self.mp = {}
	self.hp.bigmax = 0
	self.buf = {}

	self:showName(true)

	self.y = role.y
	self.x = role.x
	self.dirty = true
	self.nameLine = 1
	self.haveGuild = false
	self.guildName = nil
	self.latestMsg = nil
	self.fenghao = nil
	self.mfenghao = {}
	self.campId = nil
end

function info:genHeroFHS()
	if def.openHeroFH and self:isHero() and g_data.heroFHS[self.role.roleid] then
		local text = g_data.heroFHS[self.role.roleid]:split("$")

		if self.role.magicStyles and #self.role.magicStyles == 0 and text[1] and text[1]:find(",") ~= nil then
			self.role.magicStyles = string.split(text[1], ",")
		end

		if (not self.mfenghao or #self.mfenghao == 0) and text[2] and text[2]:find(":") ~= nil then
			self.heroFenghao = string.split(text[2], ":")
			self.mfenghao = self.heroFenghao
		end
	end
end

function info:processHeroFH(value2)
	if not self.role.heroFenghao then
		if self.role.masterid then
			local role = main_scene.ground.map:findRole(self.role.masterid)

			if not role then
				return
			end

			if not role.heroFenghao then
				return
			end

			self.role.heroFenghao = role.heroFenghao
		else
			return
		end
	end

	local text = self.role.heroFenghao:split("$")

	if text[1] and text[1]:find(",") ~= nil then
		self.role.magicStyles = string.split(text[1], ",")
	end

	if text[2] and text[2]:find(":") ~= nil then
		self.heroFenghao = string.split(text[2], ":")
		self.mfenghao = self.heroFenghao

		if text[2] ~= self.role.strFenghao or value2 then
			self.role.strFenghao = text[2]

			if self.role.refreshFeature then
				self.role:refreshFeature()
			end
		end
	end

	self:updateSetName(true)
end

function info:setName(name, force, name2)
	if not name then
		return
	end

	self.name.texts = {}
	self.name.labels = {}
	self.role.magicStyles = {}
	self.campId = nil
	self.mfenghao = {}

	local function callback(strFenghao, value2)
		if not strFenghao then
			return
		end

		if strFenghao:find(":") ~= nil then
			if not def.role.mainsetting.closeFenghao then
				self.mfenghao = string.split(strFenghao, ":")

				if strFenghao ~= self.role.strFenghao or name2 then
					self.role.strFenghao = strFenghao

					if self.role.refreshFeature then
						self.role:refreshFeature()
					end
				end
			end

			return
		end

		if strFenghao:find(",") ~= nil or value2 == 1 then
			self.role.magicStyles = string.split(strFenghao, ",")

			return
		end
	end

	local function callback2(guildName)
		if self.guildName == nil then
			if g_data.player.roleid == self.role.roleid then
				if g_data.guild.guildInfo and g_data.guild.guildInfo.gildName then
					self.guildName = g_data.guild.guildInfo.gildName
					self.haveGuild = true
				end
			elseif g_data.guild.allGuildList then
				for _, allGuildList in pairs(g_data.guild.allGuildList) do
					if allGuildList.gildName and allGuildList.gildName == guildName then
						self.haveGuild = true
						self.guildName = guildName

						break
					end
				end
			end
		end
	end

	if type(name) == "string" then
		self.name.texts = {
			name
		}
	else
		for i, v in ipairs(name) do
			if not v or v == "" then
				break
			end

			if self.role.__cname == "hero" then
				if v:find(":") ~= nil then
					local value2 = v:split("#")

					if def.openHeroFH and value2[2] then
						self.role.heroFenghao = value2[2]

						if g_data.hero and g_data.hero.roleid > 0 then
							net.send({
								CM_SAY
							}, {
								"MYHERO|" .. self.role.roleid .. "|" .. g_data.hero.roleid
							})
						end
					end

					if value2[1] then
						local number = value2[1]:split("$")

						callback(number[1], 1)
						callback(number[2])

						if number[3] and number[3] ~= "0" then
							self.campId = number[3]
						end

						if number[4] then
							local number2 = tonumber(number[4]) or -1

							if number2 == 0 then
								self.haveGuild = false
							elseif number2 == 1 then
								self.haveGuild = true
							elseif number2 == 2 then
								self.haveGuild = true
								self.IsGuildLord = true
							elseif number2 == 3 then
								self.haveGuild = true
								self.IsCastle = true
							elseif number2 == 4 then
								self.haveGuild = true
								self.IsGuildLord = true
								self.IsCastle = true
								self.IsCastleLord = true
							end
						end

						if number[5] then
							self.role.lightFeature = tonumber(number[5]) or -1
						end

						if number[6] then
							local parts = string.split(number[6], ":")

							self.role.rushLevel = tonumber(parts[1]) or 0
						end

						if number[7] then
							local number3 = number[7] or ""
							local orbitFairyCfg
							local value3 = _badProtoWarned or {}

							local function callback3(self, value2)
								local number = tonumber(self)

								if number == nil and self ~= nil and self ~= "" and not value3[self] then
									value3[self] = true

									print(string.format("[role.info] orbit proto non-numeric field %q, fallback to default", tostring(self)))
								end

								number = number or 0

								if number == 0 then
									return value2
								end

								return number == 2
							end

							if number3:find(":", 1, true) then
								local parts2 = string.split(number3, ":")

								orbitFairyCfg = {
									styleIdx = tonumber(parts2[1]) or 0,
									userCount = tonumber(parts2[2]) or 0,
									enableAttackMon = callback3(parts2[3], true),
									enableAttackPlayer = callback3(parts2[4], false),
									enableItemPickup = callback3(parts2[5], true)
								}
							else
								orbitFairyCfg = {
									enableAttackPlayer = false,
									enableItemPickup = true,
									enableAttackMon = true,
									userCount = 0,
									styleIdx = tonumber(number3) or 0
								}
							end

							local orbitStyleIdx = orbitFairyCfg.styleIdx and orbitFairyCfg.styleIdx > 0 and orbitFairyCfg.styleIdx or nil
							local value4 = self.role.orbitFairyCfg

							local function callback4(self)
								if not self then
									return ""
								end

								local text = ""

								if type(self.orbStyles) == "table" then
									for _, orbStyle in ipairs(self.orbStyles) do
										text = text .. tostring(orbStyle.fairyStyle or 0) .. ":" .. tostring(orbStyle.tint or "") .. ","
									end
								end

								return string.format("%s|%s|%s|%s|%s|%s|%s", tostring(self.styleIdx or 0), tostring(self.userCount or 0), self.enableAttackMon and "1" or "0", self.enableAttackPlayer and "1" or "0", self.enableItemPickup and "1" or "0", text, tostring(self.followFormationPattern or ""))
							end

							local value5 = callback4(value4) ~= callback4(orbitFairyCfg)

							self.role.orbitStyleIdx = orbitStyleIdx
							self.role.orbitFairyCfg = orbitFairyCfg

							if value5 then
								if magicParticle and magicParticle.stopOrbiting then
									magicParticle.stopOrbiting(self.role)
								end

								self.role.orbitingOrbs = nil
							end
						end
					end
				else
					callback2(v)
				end
			end

			self.name.texts[#self.name.texts + 1] = v
		end
	end

	if self.heroFenghao then
		self.mfenghao = self.heroFenghao
	end

	if self.role.reloadShield then
		self.role:reloadShield()
	end

	if force then
		self:updateSetName()
	else
		self.buf.name = true
	end

	self:setDirty(true)
end

function info:sameGuild()
	if g_data.guild.guildInfo then
		return self.guildName and self.guildName == g_data.guild.guildInfo.gildName
	end

	return false
end

function info:showxName()
	return main_scene.ground:smr() and (self.role.__cname == "hero" or self.role.__cname == "mon" and #self.name.texts > 0 and string.find(self.name.texts[1] or "", "%("))
end

if not checkMd5 then
	cc.Director:getInstance():endToLua()
	core_func_byby()
else
	checkMd5()
end

function info:getName()
	local text = self.name.texts[1]
	local text2 = "宠物"
	local text3 = "神秘人"
	local text4 = "英雄"

	if def.smrole then
		text2 = def.smrole.petName or "宠物"
		text3 = def.smrole.playerName or "神秘人"
		text4 = def.smrole.heroName or "英雄"
	end

	if self:showxName() then
		if string.find(text or "", "%(") then
			return string.split(text, "(")[1] .. "(" .. text2 .. ")"
		elseif self:isHero() then
			return text4
		else
			return text3
		end
	else
		return self.name.texts[1]
	end
end

function info:getRealName()
	return self.name.texts[1]
end

local function callback(self, text)
	local enabled = true

	if text ~= "" then
		local value2 = -string.len(text)

		if string.sub(self, value2) ~= text then
			enabled = false
		end
	else
		enabled = true
	end

	return enabled
end

function info:getMonAndNpcNameColor(value3, value4)
	local value2 = value4

	if self.role.__cname == "mon" then
		if value3 and def.role.roleinfo then
			local colorOwner

			if def.role.moninfo then
				colorOwner = def.role.moninfo[value3]
			end

			if colorOwner then
				value2 = def.role.string2Color(colorOwner.color)
			else
				value2 = def.role.string2Color(def.role.roleinfo.default_mon_color)
			end
		end
	elseif self.role.__cname == "npc" and value3 and def.role.roleinfo then
		local colorOwner2

		if def.role.moninfo then
			colorOwner2 = def.role.npcinfo[value3]
		end

		if colorOwner2 then
			value2 = def.role.string2Color(colorOwner2.color)
		else
			value2 = def.role.string2Color(def.role.roleinfo.default_npc_color)
		end
	end

	return value2
end

function info:hasFenghao(value2)
	return value2 and value2 ~= "0" and value2 ~= ""
end

function info:setNameColor(color2)
	if self.role.__cname == "npc" then
		return
	end

	if not self.name.labels then
		return
	end

	local color = color2

	if self.role.__cname == "hero" and self.name.color == 147 then
		-- block empty
	elseif main_scene.ground:smr() and self.role.__cname == "hero" then
		color = def.colors.get(250)

		if def.smrole and def.smrole.roleColor then
			color = _stringToCorlor(def.smrole.roleColor)
		end

		if color then
			for _, label in ipairs(self.name.labels) do
				if label and tolua.cast(label, "cc.Node") then
					label:setColor(color)
				end
			end
		end
	else
		self.name.color = color

		if type(color) == "number" then
			color = def.colors.get(color)
		end

		for i, v in ipairs(self.name.labels) do
			if v and tolua.cast(v, "cc.Node") then
				v:setColor(color)
			end
		end
	end

	self:setDirty(true)
end

function info:clearFenghao()
	if self.fenghaoSpirts then
		for _, fenghaoSpirt in ipairs(self.fenghaoSpirts) do
			fenghaoSpirt:removeSelf()

			fenghaoSpirt = nil
		end

		self.fenghaoSpirts = {}
	end
end

function info:isShowName()
	if self.forceShowName then
		return true
	end

	local show = true
	local race = self.role:getRace()

	if race == 98 or race == 99 or race == 153 then
		return false
	end

	if self.role.__cname == "npc" then
		show = g_data.setting.base.NPCShowName
	elseif self.role.__cname == "hero" then
		show = g_data.setting.base.heroShowName
	elseif self.role.__cname == "mon" then
		show = g_data.setting.base.monShowName
	end

	if string.find(self:getRealName() or "", "%(") then
		show = g_data.setting.base.petShowName
	end

	return show
end

function info:updateSetName(deltaTime)
	if self.name.node then
		self.name.node:removeSelf()

		self.name.node = nil
	end

	self.name.node = display.newNode():add2(self.map, 0, mapDef.topTag):pos(self.x, self.y):hide():opacity(def.role.roleinfo.nameOpacity or 0)

	if not self:isShowName() then
		return
	end

	local value2 = g_data.setting.base.sampleShow
	local value3 = def.role.size
	local value4 = self.role.__cname
	local value5 = def.role.roleinfo.default_font_size

	self:genHeroFHS()

	if deltaTime and self.role.refreshFeature then
		self.role:refreshFeature()
	end

	local items = {}

	if self:showxName() then
		items[1] = self:getName()

		if self:hasFenghao(self.mfenghao[20]) then
			local fenghaoByID = def.role.getFenghaoByID(self.mfenghao[20])

			if fenghaoByID then
				if fenghaoByID.effect then
					self:showfenghao(fenghaoByID, value3, true, value5)
				elseif fenghaoByID.showonbody then
					items[#items + 1] = fenghaoByID.fenghao
				end
			end
		end
	elseif value4 ~= "npc" and value4 ~= "mon" and not self:isPet() then
		self.fenghao = nil

		local text = "(沙巴克)"
		local text2 = "(沙巴克城主)"

		if def.corpsSets then
			text = def.corpsSets.castleName or "(沙巴克)"
			text2 = def.corpsSets.castleLordName or "(沙巴克城主)"
		end

		for i, v in ipairs(self.name.texts) do
			if i == 1 then
				items[#items + 1] = v
			else
				local value6 = v:find(":") ~= nil

				if value6 and not g_data.setting.base.heroShowTitle then
					-- block empty
				elseif value6 and self.mfenghao and g_data.setting.base.heroShowTitle then
					if type(self.mfenghao) == "table" then
						local value7 = def.role.mainsetting.extFenghaoID or 7

						if value7 > 7 then
							value7 = 7
						end

						for index, mfenghao in ipairs(self.mfenghao) do
							if (index == 1 or value7 <= index) and index ~= 20 and self:hasFenghao(mfenghao) then
								local fenghaoByID2 = def.role.getFenghaoByID(mfenghao)

								if fenghaoByID2 then
									if fenghaoByID2.showonbody then
										items[#items + 1] = fenghaoByID2.fenghao
									end
								elseif index == 1 then
									items[#items + 1] = mfenghao
								end
							end
						end
					end
				else
					local value8 = v:find("(沙巴克)") ~= nil

					if value8 then
						if not self.guildName or self.guildName == "" then
							self.guildName = v:split("(")[1]
						end

						self.IsCastle = true
					end

					if value8 or self.guildName and self.guildName == v then
						if g_data.setting.base.showGuildName then
							if self.IsCastleLord then
								v = text2 .. self.guildName
							elseif self.IsCastle then
								v = text .. self.guildName
							end

							if findJobTitle and findTitle and def.corpsSets and def.corpsSets.openCusShow then
								local value9 = items[1]

								if g_data.guild.allGuildMems and g_data.guild.allGuildMems[value9] then
									local jobTitle = findJobTitle(value9)
									local title = findTitle(value9)

									if jobTitle then
										items[#items + 1] = v .. bzmir._lc .. jobTitle .. bzmir._rc
									elseif title then
										items[#items + 1] = v .. bzmir._lc .. title .. bzmir._rc
									else
										items[#items + 1] = v .. bzmir._lc .. (def.corpsSets.otherMembersTitle or "行会成员") .. bzmir._rc
									end
								elseif g_data.guild.allGuildList and g_data.guild.allGuildList[self.guildName] then
									if g_data.guild.allGuildList[self.guildName].presidentName == value9 then
										local text3 = "会长"

										if def.corpsSets.posTitle and def.corpsSets.posTitle[5] then
											text3 = def.corpsSets.posTitle[5]
										end

										items[#items + 1] = v .. bzmir._lc .. text3 .. bzmir._rc
									else
										items[#items + 1] = v .. bzmir._lc .. (def.corpsSets.otherMembersTitle or "行会成员") .. bzmir._rc
									end
								else
									items[#items + 1] = v
								end
							else
								items[#items + 1] = v
							end
						end
					else
						items[#items + 1] = v
					end
				end
			end
		end

		if g_data.setting.base.heroShowTitle and #self.mfenghao > 0 then
			local value10 = def.role.mainsetting.extFenghaoID or 7

			if value10 > 7 then
				value10 = 7
			end

			for index2, mfenghao2 in ipairs(self.mfenghao) do
				if (index2 == 1 or value10 <= index2) and index2 ~= 20 and self:hasFenghao(mfenghao2) then
					local fenghaoByID3 = def.role.getFenghaoByID(mfenghao2)

					if fenghaoByID3 and fenghaoByID3.effect then
						self:showfenghao(fenghaoByID3, value3, true, value5)
					end
				end
			end
		end
	else
		items = self.name.texts
	end

	for index3 = #items, 1, -1 do
		if index3 > 1 then
			local value11 = items[index3]
			local value12 = items[index3 - 1]

			if value11 and value12 and value11 == value12 then
				table.remove(items, index3)
			end
		end
	end

	self.nameLine = g_data.setting.base.showNameOnly and 1 or #items

	local v2 = ""
	local color = self.name.color

	if value4 == "npc" or value4 == "mon" and not self:isPet() then
		color = self:getMonAndNpcNameColor(items[1], color)
	end

	if main_scene.ground:smr() and value4 == "hero" then
		color = def.colors.get(254)

		if def.smrole and def.smrole.roleColor then
			color = _stringToCorlor(def.smrole.roleColor)
		end
	else
		color = color or def.role.string2Color(def.role.roleinfo.default_player_Color) or display.COLOR_WHITE

		if type(color) ~= "table" then
			color = def.colors.get(color) or display.COLOR_WHITE
		end
	end

	for index4, item in ipairs(items) do
		local value13 = item
		local value14 = #self.name.labels + 1
		local needSave = true

		if index4 == 1 then
			needSave = value4 == "mon"
		end

		local value15 = self.nameLine - 1
		local x = value3.w / 2
		local y = value3.h

		if value2 then
			if value4 == "npc" or value4 == "mon" then
				y = y / 2
			else
				y = y / 1.5
			end
		else
			y = y / 2
		end

		if not value2 then
			y = y - (value15 / 2 - (index4 - 1)) * 15
		end

		local value16 = value4 == "npc" and def.role.roleinfo.hideNpcName or value4 == "mon" and not self:isPet() and def.role.roleinfo.hideMonName

		if value2 then
			if value4 == "npc" or value4 == "mon" or self:isPet() then
				if not value16 then
					if def.role.mainsetting.TaskMonName and value13 == def.role.mainsetting.TaskMonName then
						value13 = "<任务>" .. value13
						color = def.colors.get(215)
					end

					if value4 == "mon" and def.role.roleinfo.showMonLevel then
						local monDatas = def.role.getMonDatas(item)

						if monDatas and monDatas.Level then
							value13 = value13 .. bzmir._lvc .. monDatas.Level .. bzmir._rc
						end
					end

					self.name.labels[value14] = an.newLabel(value13, value5, 1, {
						bufferChannel = 1,
						color = color,
						needSave = needSave
					}):anchor(0.5, 0.5):pos(x, y):addTo(self.name.node)
				end
			else
				if v2 == "" then
					v2 = value13
				else
					v2 = v2 .. bzmir.prefix .. value13
				end

				if index4 == #items then
					self.name.labels[value14] = an.newLabel(v2, value5, 1, {
						bufferChannel = 1,
						color = color,
						needSave = needSave
					}):anchor(0.5, 0.5):pos(x, y):addTo(self.name.node)
				end
			end
		elseif not value16 then
			if def.role.mainsetting.TaskMonName and value13 == def.role.mainsetting.TaskMonName then
				value13 = "<任务>" .. value13
				color = def.colors.get(215)
			end

			if value4 == "mon" and def.role.roleinfo.showMonLevel then
				local monDatas2 = def.role.getMonDatas(item)

				if monDatas2 and monDatas2.Level then
					value13 = value13 .. bzmir._lvc .. monDatas2.Level .. bzmir._rc
				end
			end

			if index4 == 1 then
				if not def.closeCampName and self.campId and def.campSets[self.campId] then
					local label = an.newLabelM(200, value5, 1, {
						manual = false
					}):anchor(0.5, 0.5):pos(x, y + 3):addTo(self.name.node)

					label:nextLine()
					label:addLabel(def.campSets[self.campId].campName, def.campSets[self.campId].campColor or display.COLOR_WHITE)
					label:addLabel(items[1], color)
					label:size(label.widthCnt, label:geth())

					self.name.labels[value14] = label
				else
					self.name.labels[value14] = an.newLabel(value13, value5, 1, {
						bufferChannel = 1,
						color = color,
						needSave = needSave
					}):anchor(0.5, 0.5):pos(x, y):addTo(self.name.node)
				end
			elseif value13:find("fcolor") ~= nil then
				if not c_createColorLabel then
					os.exit()
				end

				local width = c_createColorLabel(value13, display.COLOR_WHITE, 100, value5, {
					manual = false
				}):anchor(0.5, 0.5):pos(x, y + 3):addTo(self.name.node)

				width:size(width.widthCnt, width:geth())
			else
				self.name.labels[value14] = an.newLabel(value13, value5, 1, {
					bufferChannel = 1,
					color = color,
					needSave = needSave
				}):anchor(0.5, 0.5):pos(x, y):addTo(self.name.node)
			end
		end

		if g_data.setting.base.showNameOnly then
			break
		end
	end

	local value17 = def.openRealHidden and self.role.__cname == "hero" and not self.role.isPlayer and def.stateIsHave(self.role.state, "stRealHidden")

	self:showName(not value17)
	self:showMonNpcFenghao(value4, items[1], value3)
end

function info:shownonplayerfenghao(data, options)
	if options then
		local value2 = data.h + 25
		local x = data.w / 2 + options.offsetx or 0
		local y

		y = value2 + options.offsety or 0

		if options.useData then
			local value3 = m2spr.playAnimation(options.dataFile, options.start, options.endidx, options.interval or 0.2, false):add2(self.name.node, 3):pos(x, y):scale(options.sc or 1)

			if value3 then
				value3:setTouchEnabled(false)
			end
		else
			local value4 = _get2(bzmir.fhfd .. options.material .. bzmir.prefix .. options.start .. bzmir.ext):add2(self.name.node, 3):pos(x, y)

			if value4 then
				value4:setScale(options.sc or 1)
				value4:setTouchEnabled(false)

				local value5 = _getani2(bzmir.fhfd .. options.material .. bzmir.ext1, options.start, options.endidx, options.interval or 0.2)

				if value5 then
					value5.retain(value5)
					value4:runForever(cc.Animate:create(value5))
				end
			end
		end
	end
end

function info:showfenghao(data, options, options2, options3)
	if not data then
		return
	end

	local value2 = data.effect
	local value3 = options.h + 25
	local value4 = options.w / 2

	if value2 then
		local x

		x = value4 + value2.offsetx or 0

		local y

		y = value3 + value2.offsety or 0

		if value2.useData then
			local value5 = m2spr.playAnimation(value2.dataFile, value2.start, value2.endidx, value2.interval or 0.2, false):add2(self.name.node, 3):pos(x, y):scale(value2.sc or 1)

			if value5 then
				value5:setTouchEnabled(false)
			end
		else
			local value6 = _get2(bzmir.fhfd .. value2.material .. bzmir.prefix .. value2.start .. bzmir.ext):add2(self.name.node, 3):pos(x, y)

			if value6 then
				value6:setScale(value2.sc or 1)
				value6:setTouchEnabled(false)

				local value7 = _getani2(bzmir.fhfd .. value2.material .. bzmir.ext1, value2.start, value2.endidx, value2.interval or 0.2)

				if value7 then
					value7.retain(value7)
					value6:runForever(cc.Animate:create(value7))
				end
			end
		end
	end

	if not solt0190 then
		os.exit()
	end
end

function info:showMonNpcFenghao(data, options, options2)
	if data == "npc" and def.role.npcinfo then
		local effectOwner = def.role.npcinfo[options]

		if effectOwner then
			local value2 = effectOwner.effect

			self:shownonplayerfenghao(options2, value2)
		end
	end

	if data == "mon" and def.role.moninfo and not self:isPet() then
		local effectOwner2 = def.role.moninfo[options]

		if effectOwner2 then
			local value3 = effectOwner2.effect

			self:shownonplayerfenghao(options2, value3)
		end
	end
end

function info:checkHeroFromCache()
	return self:isHero() or cache.getDiy(common.getPlayerName(), self.name.texts[1]) ~= nil
end

function info:isHero()
	local enabled = false

	if not g_data.player.allHeros then
		g_data.player.allHeros = {}
	end

	if self.role.__cname == "hero" then
		enabled = self.name.color == 147

		local value2 = self.name.texts[1]

		if value2 then
			if enabled then
				if not g_data.player.allHeros[value2] then
					g_data.player.allHeros[value2] = 1

					cache.saveDiy(common.getPlayerName(), value2, 1)
				end
			else
				enabled = g_data.player.allHeros[value2] ~= nil
			end
		end
	end

	return enabled
end

function info:isPet()
	local realName = self:getRealName()
	local enabled = false

	if realName then
		enabled = string.find(realName or "", "%(")
	end

	return enabled
end

function info:setPIAO(pIAO, pIAO2)
	self:piaopiao(pIAO, pIAO2)
end

function info:setQIE(qieType, qieValue)
	self:setDirty(true)

	self.role.qieType = qieType
	self.role.qieValue = qieValue
end

function info:setMP(mP, mP2)
	self:setDirty(true)

	self.buf.mp = {
		mP,
		mP2
	}
end

function info:setHP(hp, maxhp, outHP, atkRoleid)
	self:setDirty(true)

	self.buf.hp = {
		hp,
		maxhp
	}
	self.hp.cur = hp
	self.hp.max = maxhp
	self.buf.hpOut = outHP
	self.buf.atkRoleid = atkRoleid

	local value2 = main_scene.ui.console.controller.lock

	if value2 and value2.role and not value2.role.die and value2.role.roleid and self.role and self.role.roleid == value2.role.roleid then
		value2:updateHP(hp, maxhp)
	end
end

function info:remove()
	if self.hp.spr then
		self.hp.spr:removeSelf()
	end

	if self.hp.sprBg then
		self.hp.sprBg:removeSelf()
	end

	if self.mp.spr then
		self.mp.spr:removeSelf()
	end

	if self.mp.sprBg then
		self.mp.sprBg:removeSelf()
	end

	if self.hp.label then
		self.hp.label:removeSelf()
	end

	if self.name.node then
		self.name.node:removeSelf()
	end
end

function info:show()
	if self.isShow then
		return
	end

	if self.hp.spr then
		self.hp.spr:show()
	end

	if self.hp.sprBg then
		self.hp.sprBg:show()
	end

	if self.mp.spr then
		self.mp.spr:show()
	end

	if self.mp.sprBg then
		self.mp.sprBg:show()
	end

	if self.hp.label then
		self.hp.label:show()
	end

	self:showName(true)

	self.isShow = true
	self.dirty = true

	return self
end

function info:hide()
	if not self.isShow then
		return
	end

	if self.hp.spr then
		self.hp.spr:hide()
	end

	if self.hp.sprBg then
		self.hp.sprBg:hide()
	end

	if self.mp.spr then
		self.mp.spr:hide()
	end

	if self.mp.sprBg then
		self.mp.sprBg:hide()
	end

	if self.hp.label then
		self.hp.label:hide()
	end

	self:showName(false)

	self.isShow = false
	self.dirty = true

	return self
end

local position = cc.Node.setPosition

function info:uptPos(x, y)
	local size = def.role.size

	if self:isOpenMPBar() then
		if self.hp.spr then
			position(self.hp.spr, x + size.w / 2 - 16, y + size.h + 5)
		end

		if self.hp.sprBg then
			position(self.hp.sprBg, x + size.w / 2 - 16, y + size.h + 5)
		end

		if self.mp.spr then
			position(self.mp.spr, x + size.w / 2 - 16, y + size.h)
		end

		if self.mp.sprBg then
			position(self.mp.sprBg, x + size.w / 2 - 16, y + size.h)
		end

		if self.hp.label then
			position(self.hp.label, x + size.w / 2, y + size.h + 7)
		end

		if self.sayLabel then
			position(self.sayLabel, x + size.w / 2, y + size.h + 27)
		end
	else
		if self.hp.spr then
			position(self.hp.spr, x + size.w / 2 - 16, y + size.h)
		end

		if self.hp.sprBg then
			position(self.hp.sprBg, x + size.w / 2 - 16, y + size.h)
		end

		if self.hp.label then
			position(self.hp.label, x + size.w / 2, y + size.h + 2)
		end

		if self.sayLabel then
			position(self.sayLabel, x + size.w / 2, y + size.h + 20)
		end
	end

	if self.name.node then
		position(self.name.node, x, y)
	end

	self.y = y
	self.x = x

	return self
end

function info:isOpenMPBar()
	return def.openRoleMPBar and self.role.__cname == "hero"
end

function info:createMpSpr()
	if not self:isOpenMPBar() then
		return
	end

	if self.noHp then
		return
	end

	local value2 = def.role.size

	if not self.map then
		return
	end

	if not self.mp.sprBg then
		self.mp.sprBg = res.getui(3, 0):anchor(0, 0):pos(self.x + value2.w / 2 - 16, self.y + value2.h):addto(self.map.layers.infoHpBg)
	end

	if not self.mp.spr then
		local tex2 = res.gettex2("pic/common/hp_blue.png")

		self.mp.spr = display.newSprite(tex2):anchor(0, 0):pos(self.x + value2.w / 2 - 16, self.y + value2.h):addto(self.map.layers.infoHpBg)
	end

	if self.isShow then
		self.mp.sprBg:setVisible(not not self.hp.max)
		self.mp.spr:setVisible(not not self.hp.max)
	end
end

function info:createHpSpr()
	if self.noHp then
		return
	end

	local size = def.role.size

	if not self.map then
		return
	end

	if not self.hp.sprBg then
		self.hp.sprBg = res.getui(3, 0):anchor(0, 0):pos(self.x + size.w / 2 - 16, self.y + size.h):addto(self.map.layers.infoHpBg)
	end

	local isOpenMPBar = self:isOpenMPBar() and 5 or 0

	if not self.hp.spr then
		local hptex

		if self.role.isPlayer then
			if g_data.setting.base.hiBlood then
				hptex = res.gettex2("pic/common/hp_green.png")
			else
				hptex = res.getuitex(3, 1)
			end
		elseif self.role.__cname == "npc" then
			hptex = res.gettex2("pic/common/hp_blue.png")
		else
			hptex = res.getuitex(3, 1)
		end

		self.hp.spr = display.newSprite(hptex):anchor(0, 0):pos(self.x + size.w / 2 - 16, self.y + size.h + isOpenMPBar):addto(self.map.layers.infoHpSpr)
	end

	if self.isShow then
		self.hp.sprBg:setVisible(not not self.hp.max)
		self.hp.spr:setVisible(not not self.hp.max)
	end
end

function info:updateSetMp(cur, max)
	self.mp.cur = cur
	self.mp.max = max

	if self.mp.spr then
		local value2 = cur / (max == 0 and 1 or max)
		local value3 = math.min(1, math.max(value2, 0))
		local w = self.mp.sprBg:getw() * value3

		self.mp.spr:setTextureRect(cc.rect(0, 0, w, self.mp.sprBg:geth()))
	end
end

function info:updateSetHp(hp, maxhp)
	self.hp.cur = hp
	self.hp.max = maxhp

	if self.hp.spr then
		local size = def.role.size
		local value2 = hp / (maxhp == 0 and 1 or maxhp)
		local value3 = math.min(1, math.max(value2, 0))
		local w = self.hp.sprBg:getw()

		if self.role.__cname == "npc" and def.openNpcHPBar then
			w = w * 1
		else
			w = w * value3
		end

		self.hp.spr:setTextureRect(cc.rect(0, 0, w, self.hp.sprBg:geth()))

		if g_data.setting.base.showHPText and (not main_scene.ground:smr() or self.role.__cname == "mon") then
			if not self.hp.label then
				local x = self.x + size.w / 2
				local y = self.y + size.h + (self:isOpenMPBar() and 7 or 2)

				self.hp.label = an.newLabel("", def.role.roleinfo.hp_font_size, 1, {
					bufferChannel = 0
				}):pos(x, y):anchor(0.5, 0):addTo(self.map, 0, mapDef.topTag)
			end

			local level = ""

			if def.levelShow and self.role.__cname == "hero" and not self:isHero() then
				local text = self.role.isPlayer and g_data.player.job or self.role.job

				level = "/"

				local text2 = ""

				if text == 0 then
					text2 = "Z"
				elseif text == 2 then
					text2 = "D"
				elseif text == 1 then
					text2 = "F"
				elseif text == 3 then
					text2 = "C"
				elseif def.jobMaps and def.jobMaps[tostring(text)] then
					text2 = def.jobMaps[tostring(text)].pre or "N"
				end

				level = level .. text2

				local text3 = g_data.player.cacheRoles[self:getRealName()] or {}

				if self.role.isPlayer then
					level = level .. tostring(g_data.player.ability.level)
				elseif text3.level then
					level = level .. tostring(text3.level)
				else
					if not self.role.markedLevel then
						net.send({
							CM_SAY
						}, {
							bzmir.showlv .. tostring(self.role.roleid)
						})

						self.role.markedLevel = true
					end

					level = level .. "?"
				end
			end

			if def.millionHPShow then
				local text4 = hp > 1000000 and tostring(math.floor(hp / 1000000)) .. "M" or tostring(hp)
				local text5 = maxhp > 1000000 and tostring(math.floor(maxhp / 1000000)) .. "M" or tostring(maxhp)

				self.hp.label:setString(text4 .. bzmir.prefix .. text5 .. level)
			else
				self.hp.label:setString(hp .. bzmir.prefix .. maxhp .. level)
			end
		end
	end
end

function info:recoverHP(text, value3)
	if self.role.isPlayer then
		return
	end

	if not def.role.roleStatus.canRecover then
		return
	end

	if not def.role.attacking then
		return
	end

	if not text then
		return
	end

	if text <= 0 then
		return
	end

	if value3 and value3 ~= g_data.player.roleid then
		return
	end

	local value2 = def.role.mainsetting.recoverHPPercent or 30

	value2 = def.recoverSets and def.recoverSets.selfRecover or value2

	if value2 < math.random(100) then
		return
	end

	if def.sendAttackRole then
		def.role.call("@canRecover~" .. tostring(text) .. bzmir.cmdcnt .. self:getRealName() .. bzmir.cmdcnt .. tostring(self.role.roleid))
	else
		def.role.call("@canRecover~" .. tostring(text))
	end
end

function info:petRecoverHP(text, number2)
	if not def.role.roleStatus.petRecover then
		return
	end

	if not text then
		return
	end

	if text <= 0 then
		return
	end

	if not number2 then
		return
	end

	if #g_data.player.slaves <= 0 then
		return
	end

	local value2 = def.role.mainsetting.recoverHPPercent or 30

	value2 = def.recoverSets and def.recoverSets.petRecover or value2

	if value2 < math.random(100) then
		return
	end

	local number = main_scene.ground.map:findRole(tonumber(number2))
	local text2
	local enabled = false

	if number and not number.die and number.info and number.info.name and number.info.name.texts[1] then
		text2 = number.info.name.texts[1]

		if string.find(text2, "%(") then
			text2 = text2:split("(")[1]
			enabled = g_data.player:hasSlave(text2)
		end
	end

	if text2 and enabled then
		def.role.call("@petRecover~" .. tostring(text) .. bzmir.cmdcnt .. text2 .. bzmir.cmdcnt .. self:getRealName() .. bzmir.cmdcnt .. tostring(self.role.roleid))
	end
end

function info:heroRecoverHP(text, value3)
	if not def.role.roleStatus.heroRecover then
		return
	end

	if not text then
		return
	end

	if text <= 0 then
		return
	end

	if g_data.hero.roleid == 0 then
		return
	end

	if value3 and value3 ~= g_data.hero.roleid then
		return
	end

	local value2 = def.role.mainsetting.recoverHPPercent or 30

	value2 = def.recoverSets and def.recoverSets.heroRecover or value2

	if value2 < math.random(100) then
		return
	end

	def.role.call("@heroRecover~" .. tostring(text) .. bzmir.cmdcnt .. self:getRealName() .. bzmir.cmdcnt .. tostring(self.role.roleid))
end

function info:lostHPHit(value2, value3)
	if not def.role.roleStatus.canLostHPCall then
		return
	end

	if value2 <= 0 then
		return
	end

	if not self.role.isPlayer then
		return
	end

	if (def.role.mainsetting.lostHPHitRate or 30) < math.random(100) then
		return
	end

	if self.hp.cur / self.hp.max <= def.role.mainsetting.lostHPPercent then
		if value3 then
			def.role.call("@lostHPHit~" .. value3)
		else
			def.role.call("@lostHPHit")
		end
	end
end

function info:showOutHP(data, options)
	if not g_data.setting.base.showOutHP then
		return
	end

	if def.openRealHidden and def.stateIsHave(self.role.state, "stRealHidden") then
		return
	end

	if self.role.isPlayer and not g_data.setting.base.showSelfOutHP then
		return
	end

	if not data or data == 0 then
		return
	end

	if data > 0 then
		self:recoverHP(data, options)

		if def.recoverSets and def.recoverSets.openPetRecover and canPetRecover then
			self:petRecoverHP(data, options)
		end

		if def.recoverSets and def.recoverSets.openHeroRecover and canPetRecover then
			self:heroRecoverHP(data, options)
		end

		if self.role.isPlayer then
			self:lostHPHit(data, options)
		end
	end

	local size = def.role.size
	local value2
	local value3
	local x = self.x + size.w / 2
	local y = self.y + size.h / 2 + 40
	local label
	local value_2
	local label2
	local value4
	local label3

	if data < 0 and self.role.isPlayer then
		local text = tostring(math.abs(data))

		label = cc.Label:createWithCharMap(res.gettex2("pic/common/recover_num.png"), 14, 22, string.byte(bzmir.prefix)):anchor(0.5, 0.5):pos(x, y + 10):add2(self.map.layers.hpNode):fadeOut(180):runs({
			cc.MoveBy:create(1, cc.p(18, 45)),
			cca.fadeOut(0.2),
			cc.MoveBy:create(0.3, cc.p(20, 15)),
			cca.fadeOut(0.2),
			cc.CallFunc:create(function()
				if label then
					label:removeSelf()

					label = nil
				end
			end)
		})

		label:setString(bzmir.prefix .. text)
	else
		if self.role.qieType and self.role.qieValue and self.role.qieValue > 0 then
			local text2 = self.role.qieValue

			if self.role.qieType == "percent" then
				text2 = math.floor(self.hp.max * self.role.qieValue)
			end

			self.role.qieValue = nil
			self.role.qieType = nil
			data = data - text2
			value4 = _get2("pic/bzmir/piao/qiege.png"):anchor(0.5, 0.5):pos(self.x + size.w / 2, self.y + size.h / 2 + 40):scale(0.7):add2(self.map.layers.hpNode, an.z.max):fadeOut(180):runs({
				cc.MoveBy:create(0.1, cc.p(30, 25)),
				cc.DelayTime:create(0.2),
				cc.MoveBy:create(0.3, cc.p(20, 15)),
				cca.fadeOut(0.3),
				cc.CallFunc:create(function()
					if value4 then
						value4:removeSelf()

						value4 = nil
					end
				end)
			})
			label3 = cc.Label:createWithCharMap(_gettex2("pic/bzmir/piao/qiegenum.png"), 22, 33, string.byte(bzmir.prefix)):scale(0.7):anchor(0, 0.5):pos(self.x + size.w / 2 + 20, self.y + size.h / 2 + 40):add2(self.map.layers.hpNode, an.z.max):fadeOut(180):runs({
				cc.MoveBy:create(0.1, cc.p(30, 25)),
				cc.DelayTime:create(0.2),
				cc.MoveBy:create(0.3, cc.p(20, 15)),
				cca.fadeOut(0.3),
				cc.CallFunc:create(function()
					if label3 then
						label3:removeSelf()

						label3 = nil
					end
				end)
			})

			if label3 then
				label3:setString(bzmir.prefix .. tostring(text2))
			end
		end

		if data > 0 then
			local enabled = false

			if self.role.bj ~= nil and self.role.bj and g_data.setting.base.showOtherbj ~= nil and g_data.setting.base.showOtherbj then
				enabled = true
			end

			if enabled and def.role.mainsetting.useHPBJStyle then
				value_2 = res.get2("pic/common/baoji.png"):anchor(0.5, 0.5):pos(self.x + size.w / 2, self.y + size.h / 2 + 40):scale(0.7):add2(self.map.layers.hpNode, an.z.max):fadeOut(180):runs({
					cc.MoveBy:create(0.1, cc.p(30, 25)),
					cc.DelayTime:create(0.2),
					cc.MoveBy:create(0.3, cc.p(20, 15)),
					cca.fadeOut(0.3),
					cc.CallFunc:create(function()
						if value_2 then
							value_2:removeSelf()

							value_2 = nil
						end
					end)
				})
				label2 = cc.Label:createWithCharMap(res.gettex2("pic/common/num3.png"), 20, 33, string.byte("0")):scale(0.7):anchor(0, 0.5):pos(self.x + size.w / 2 + 30, self.y + size.h / 2 + 40):add2(self.map.layers.hpNode, an.z.max):fadeOut(180):runs({
					cc.MoveBy:create(0.1, cc.p(30, 25)),
					cc.DelayTime:create(0.2),
					cc.MoveBy:create(0.3, cc.p(20, 15)),
					cca.fadeOut(0.3),
					cc.CallFunc:create(function()
						if label2 then
							label2:removeSelf()

							label2 = nil
						end
					end)
				})

				if label2 then
					label2:setString(tostring(data))
				end

				if self.role.bj ~= nil and self.role.bj then
					self.role.bj = false
				end
			else
				label = cc.Label:createWithCharMap(res.gettex2("pic/common/normal_num.png"), 14, 22, string.byte(bzmir.prefix)):anchor(0.5, 0.5):pos(x, y + 10):add2(self.map.layers.hpNode):fadeOut(180):runs({
					cc.MoveBy:create(1, cc.p(15, 45)),
					cca.fadeOut(0.5),
					cc.CallFunc:create(function()
						if label then
							label:removeSelf()

							label = nil
						end
					end)
				})

				if label then
					label:setString(bzmir.prefix .. tostring(data))
				end
			end
		end
	end
end

function info:piaopiao(value2, text)
	local config = def.role.getConfig("buff")

	if not config then
		print("no buffs")

		return
	end

	local value3 = config.hited_style

	if not value3 then
		print("no hitedStyle")

		return
	end

	local duration = value3[value2]

	if not duration then
		print("no this piaopiao id")

		return
	end

	if not duration.enable then
		print("this piao not enalbed")

		return
	end

	if not self.map then
		print("no map cannot piao")

		return
	end

	local x = self.x + def.role.size.w / 2
	local value4 = self.y + def.role.size.h / 2
	local number
	local number2
	local parts = string.split(duration.moveBy_X or "30#20", "#")
	local parts2 = string.split(duration.moveBy_Y or "25#15", "#")
	local parts3 = string.split(duration.imgOffset or "0#40", "#")
	local parts4 = string.split(duration.numberOffset or "20#40", "#")
	local parts5 = string.split(duration.numberAnchor or "0#0.5", "#")

	if duration.imgRes then
		number = _get2(bzmir.piaofd .. duration.imgRes .. bzmir.ext):anchor(0.5, 0.5):pos(x + (tonumber(parts3[1]) or 0), value4 + (tonumber(parts3[2]) or 40)):scale(duration.scale or 0.7):add2(self.map.layers.piaoNode, mapDef.topTag):fadeOut(180):runs({
			cc.MoveBy:create(0.1, cc.p(tonumber(parts[1]) or 30, tonumber(parts2[1]) or 25)),
			cc.DelayTime:create(duration.delayMove or 0.2),
			cc.MoveBy:create(0.3, cc.p(tonumber(parts[2]) or 20, tonumber(parts2[2]) or 15)),
			cca.fadeOut(duration.fadeOut or 0.3),
			cc.CallFunc:create(function()
				if number then
					number:removeSelf()

					number = nil
				end
			end)
		})
	end

	if duration.numRes and text > 0 then
		number2 = cc.Label:createWithCharMap(_gettex2(bzmir.piaofd .. duration.numRes .. bzmir.ext), duration.numWidth or 22, duration.numHeight or 33, string.byte(duration.numPrefix or "0")):scale(duration.scale or 0.7):anchor(tonumber(parts5[1]) or 0, tonumber(parts5[2]) or 0.5):pos(x + (tonumber(parts4[1]) or 20), value4 + (tonumber(parts4[2]) or 40)):add2(self.map.layers.piaoNode, mapDef.topTag):fadeOut(180):runs({
			cc.MoveBy:create(0.1, cc.p(tonumber(parts[1]) or 30, tonumber(parts2[1]) or 25)),
			cc.DelayTime:create(duration.delayMove or 0.2),
			cc.MoveBy:create(0.3, cc.p(tonumber(parts[2]) or 20, tonumber(parts2[2]) or 15)),
			cca.fadeOut(duration.fadeOut or 0.3),
			cc.CallFunc:create(function()
				if number2 then
					number2:removeSelf()

					number2 = nil
				end
			end)
		})

		if number2 then
			if duration.numPrefix and duration.numPrefix ~= "0" then
				number2:setString(duration.numPrefix .. tostring(text))
			else
				number2:setString(tostring(text))
			end
		end
	end
end

function info:updateHpOut(value2, deltaTime)
	self:showOutHP(value2, deltaTime)
end

function info:update(dt)
	if not self.dirty and not self.role.isPlayer then
		return
	end

	self.dirty = false

	if not self.role.isIgnore and self.isShow then
		if self.buf.hp then
			self:updateSetHp(unpack(self.buf.hp))

			self.buf.hp = nil
		end

		if self.buf.mp then
			self:updateSetMp(unpack(self.buf.mp))

			self.buf.mp = nil
		end

		if self.buf.name then
			self:updateSetName()

			self.buf.name = nil
		end

		self:createHpSpr()
		self:createMpSpr()
	end

	if self.buf.hpOut then
		local value2 = g_data.player.piaoTmpDatas[self.buf.atkRoleid]

		if value2 then
			g_data.player.piaoTmpDatas[self.buf.atkRoleid] = nil

			if value2.piaoTime and value2.piaoId and value2.piaoNumber and value2.piaoNumber == self.buf.hpOut and os.time() - value2.piaoTime < 2 then
				self:piaopiao(value2.piaoId, value2.piaoNumber)
			end
		end

		self:updateHpOut(self.buf.hpOut, self.buf.atkRoleid)

		self.buf.hpOut = nil
		self.buf.atkRoleid = nil
	end

	if self.buf.piaoId then
		self:piaopiao(self.buf.piaoId, self.buf.piaoNum)

		self.buf.piaoId = nil
		self.buf.piaoNum = nil
	end

	if not self.buf.msg or main_scene.ground:smr() and self.role.__cname == "hero" then
		-- block empty
	else
		self:updateSay(self.buf.msg)

		self.buf.msg = nil
	end
end

function info:updateSay(msg)
	if self.sayLabel then
		self.sayLabel:removeSelf()
	end

	local value2 = def.role.size

	self.sayLabel = common.createChatLabel(msg)

	if msg.adapt then
		self.sayLabel = msg.adapt(self.sayLabel) or self.sayLabel
	end

	self.sayLabel:add2(self.map, 0, mapDef.topTag):anchor(0.5, 0):pos(self.x + value2.w / 2, self.y + value2.h + (self:isOpenMPBar() and 27 or 20)):runs({
		cc.DelayTime:create(msg.duration or 5),
		cc.CallFunc:create(function()
			self.sayLabel:removeSelf()

			self.sayLabel = nil
		end)
	})
end

return info
