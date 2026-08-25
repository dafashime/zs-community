return {
	calltime = 0,
	clanNotice = "",
	serach = false,
	guildNotice = "",
	hasGuild = true,
	hasClan = true,
	page = 0,
	corpsList = {},
	guildList = {},
	allGuildList = {},
	allCorpsList = {},
	allCorpsMem = {},
	allGuildMems = {},
	config = {
		clanmain = {
			needreset = true,
			receive = false
		},
		clanmem = {
			needreset = true,
			receive = false
		},
		clanjobs = {
			needreset = true,
			receive = false
		},
		clanlog = {
			needreset = true,
			receive = false
		},
		guildmain = {
			needreset = true,
			receive = false
		},
		mem = {
			needreset = true,
			receive = false
		},
		claninfo = {
			needreset = true,
			receive = false
		},
		clanrecruit = {
			needreset = true,
			receive = false
		},
		diplomatic = {
			needreset = true,
			receive = false
		},
		log = {
			needreset = true,
			receive = false
		}
	},
	saveCache = function(value, value2, value4)
		local function callback(self)
			if value2 == "corps" then
				return {
					_class = self._class,
					_name = self._name,
					captainName = self.captainName,
					corpsID = self.corpsID,
					corpsName = self.corpsName,
					gildName = self.gildName,
					memberCount = self.memberCount,
					onlineCount = self.onlineCount
				}
			elseif value2 == "guilds" then
				return {
					_class = self._class,
					_name = self._name,
					corpsCount = self.corpsCount,
					enableUnion = self.enableUnion,
					guildID = self.guildID,
					gildName = self.gildName,
					playerCount = self.playerCount,
					onlineCount = self.onlineCount,
					presidentName = self.presidentName
				}
			end
		end

		local value3 = device.writablePath .. "cache/" .. value:getCacheFile(value2) .. "/"

		if not io.exists(value3) then
			ycFunction:mkdir(value3)
		end

		local text = string.format("%s/%s", value3, value:getCacheFile(value2))
		local value5

		for itemId, item in pairs(value4) do
			if value5 then
				value5 = value5 .. "@@@"
			else
				value5 = ""
			end

			value5 = value5 .. itemId .. "$" .. crypto.encodeBase64(json.encode(callback(item)))
		end

		if value5 then
			io.writefile(text, value5)
		end
	end,
	getCache = function(value, value3)
		local value2 = device.writablePath .. "cache/" .. value:getCacheFile(value3) .. "/"
		local text = string.format("%s/%s", value2, value:getCacheFile(value3))

		if io.exists(text) then
			local value4 = io.readfile(text)
			local list = {}

			if value4 then
				local value5 = value4:split("@@@")

				for _, item in ipairs(value5) do
					local value6 = item:split("$")

					list[value6[1]] = json.decode(crypto.decodeBase64(value6[2]))
				end

				return list
			end
		end

		return nil
	end,
	cacheGuildDatas = function(calltime)
		net.send({
			CM_PLAYER_GILD
		})
		net.send({
			CM_CORPS_LIST,
			param = 0,
			tag = 7
		})
		net.send({
			CM_GILD_LIST,
			tag = 7,
			param = 0
		})

		calltime.calltime = 0

		if not def.role.timer.__refreshCoprs__ then
			def.role.timer.__refreshCoprs__ = def.role.createRepeater(function()
				if not main_scene or not main_scene.ui then
					return
				end

				net.send({
					CM_CORPS_LIST,
					tag = 7,
					param = calltime.calltime
				})
				net.send({
					CM_GILD_LIST,
					tag = 7,
					param = calltime.calltime
				})

				calltime.calltime = calltime.calltime + 1

				if calltime.calltime > 30 then
					def.role.stopRepeater(def.role.timer.__refreshCoprs__)

					def.role.timer.__refreshCoprs__ = nil

					g_data.guild:saveCache("corps", g_data.guild.allCorpsList)
					g_data.guild:saveCache("guilds", g_data.guild.allGuildList)
				end
			end, 1)
		end

		net.send({
			CM_GILDMEMBER_LIST
		})
		net.send({
			CM_GILD_QUERY_HOSTILE,
			tag = 30,
			series = 0
		})
		net.send({
			CM_GILD_QUERY_UNION,
			tag = 30,
			series = 0
		})

		if g_data.guild.clanInfo then
			net.send({
				CM_CORPS_MEMBER_LIST,
				tag = 30,
				series = 0,
				recog = 0
			}, nil, {
				{
					"ID",
					g_data.guild.clanInfo:get("corpsID")
				}
			})
		end
	end,
	runAutoCache = function(value)
		if not value.cacheTimer then
			value.cacheTimer = def.role.createRepeater(function()
				if main_scene and main_scene.ui then
					value:cacheGuildDatas()
				end
			end, 300)
		end
	end,
	getCacheFile = function(value, value2)
		return def.ccy.md(def.ccy.md(g_data.login.localLastSer.zonename) .. value2)
	end,
	getClanName = function(self)
		return self.clanInfo and self.clanInfo:get("corpsName") or ""
	end,
	getGuildName = function(self)
		return self.guildInfo and self.guildInfo:get("gildName") or ""
	end,
	decodeArray_ = function(value, num, value3, value4, value5)
		local items = {}

		for k = 1, num do
			local value2

			items[k], value4, value5 = net.record(value3, value4, value5)
		end

		return items
	end,
	initGuildInfo = function(self, msg, buf, bufLen)
		if bufLen == 0 then
			self.guildInfo = nil
		end

		if bufLen ~= getRecordSize("TGuildDesc") then
			return
		end

		self.guildInfo = getRecord("TGuildDesc")

		net.record(self.guildInfo, buf, bufLen)

		self.guildInfo.allMemCount = msg.tag

		g_data.mark:addGuild(self.guildInfo:get("presidentName"))
	end,
	isPresident = function(self)
		if self.posInfo then
			return self.posInfo == 4
		end

		return false
	end,
	isVicePresident = function(self)
		if self.posInfo then
			return self.posInfo == 3
		end

		return false
	end,
	isLeader = function(self)
		if self.posInfo then
			return self.posInfo == 2 or self.posInfo == 4 or self.posInfo == 3
		end

		return false
	end,
	isViceLeader = function(self)
		if self.posInfo then
			return self.posInfo == 1
		end

		return false
	end,
	initClanInfo = function(self, value, buf, bufLen)
		if bufLen == 0 then
			self.clanInfo = nil
		end

		if bufLen ~= getRecordSize("TCorpsDesc") then
			return
		end

		self.clanInfo = getRecord("TCorpsDesc")

		net.record(self.clanInfo, buf, bufLen)
		g_data.mark:addGuild(self.clanInfo:get("captainName"))
	end,
	initClanList = function(self, msg, buf, bufLen)
		self.corpsList = {}

		if bufLen ~= getRecordSize("TCorpsDesc") * msg.series then
			return
		end

		self.corpsList = self:decodeArray_(msg.series, "TCorpsDesc", buf, bufLen)

		for _, corpsList in ipairs(self.corpsList) do
			self.allCorpsList[corpsList.corpsName] = corpsList
		end
	end,
	initGuildList = function(self, msg, buf, bufLen)
		self.guildList = {}

		if bufLen ~= getRecordSize("TGuildDesc") * msg.series then
			return
		end

		self.guildList = self:decodeArray_(msg.series, "TGuildDesc", buf, bufLen)

		for _, guildList in ipairs(self.guildList) do
			self.allGuildList[guildList.gildName] = guildList
		end
	end,
	getCorpsMem = function(self, msg, buf, bufLen)
		self.corpsMem = {}

		if bufLen ~= getRecordSize("TCorpsMemDesc") * msg.tag then
			return
		end

		self.corpsMem = self:decodeArray_(msg.tag, "TCorpsMemDesc", buf, bufLen)

		for i, v in ipairs(self.corpsMem) do
			if v:get("status") == 0 then
				v:set("status", 1)
			else
				v:set("status", 0)
			end

			self.allCorpsMem[v.name] = v
		end
	end,
	getCorpsQueryRequests = function(self, msg, buf, bufLen)
		self.corpsQueryMem = {}

		if bufLen ~= getRecordSize("TCorpsRequests") * msg.tag then
			return
		end

		self.corpsQueryMem = self:decodeArray_(msg.tag, "TCorpsRequests", buf, bufLen)
	end,
	acceptCorpsQueryRequests = function(self, value, buf, bufLen)
		if not self.corpsQueryMem or #self.corpsQueryMem == 0 then
			return
		end

		local id, _, _2 = net.record("TGuildID", buf, bufLen)

		for i, v in ipairs(self.corpsQueryMem) do
			if v:get("ID") == id:get("ID") then
				table.remove(self.corpsQueryMem, i)

				return
			end
		end
	end,
	refuseCorpsQueryRequests = function(self, value, buf, bufLen)
		if not self.corpsQueryMem or #self.corpsQueryMem == 0 then
			return
		end

		local id, _, _2 = net.record("TGuildID", buf, bufLen)

		for i, v in ipairs(self.corpsQueryMem) do
			if v:get("ID") == id:get("ID") then
				table.remove(self.corpsQueryMem, i)

				return
			end
		end
	end,
	refushCurClan = function(self, value, buf, bufLen)
		if bufLen == 0 then
			return
		end

		local id = getRecord("TGuildID")

		net.record(id, buf, bufLen)

		if id:get("ID") ~= 0 then
			self.curApplyclan = id:get("ID")
		else
			self.curApplyclan = nil
		end
	end,
	refushCurGuild = function(self, value, buf, bufLen)
		if bufLen == 0 then
			return
		end

		local id = getRecord("TGuildID")

		net.record(id, buf, bufLen)

		if id:get("ID") ~= 0 then
			self.curApplyguild = id:get("ID")
		else
			self.curApplyguild = nil
		end
	end,
	getCorpsLog = function(self, value, buf, bufLen)
		self.corpsLog = {}

		if bufLen < getRecordSize("TLogDesc") then
			return
		end

		self.corpsLog = self:decodeArray_(bufLen / getRecordSize("TLogDesc"), "TLogDesc", buf, bufLen)
	end,
	getguildcorpsList = function(self, msg, buf, bufLen)
		self.guildcorpsList = {}

		if bufLen ~= getRecordSize("TCorpsDesc") * msg.tag then
			return
		end

		self.guildcorpsList = self:decodeArray_(msg.tag, "TCorpsDesc", buf, bufLen)
	end,
	getguildMem = function(self, msg, buf, bufLen)
		self.guildMems = {}

		if bufLen ~= getRecordSize("TGuildMember") * msg.tag then
			return
		end

		self.guildMems = self:decodeArray_(msg.tag, "TGuildMember", buf, bufLen)

		for i, v in ipairs(self.guildMems) do
			self.allGuildMems[v.name] = v
		end
	end,
	getGuildQueryRequests = function(self, msg, buf, bufLen)
		self.guildQueryMem = {}

		if bufLen ~= getRecordSize("TGuildRequestJoinDesc") * msg.tag then
			return
		end

		self.guildQueryMem = self:decodeArray_(msg.tag, "TGuildRequestJoinDesc", buf, bufLen)
	end,
	acceptGuildQueryRequests = function(self, value, buf, bufLen)
		if not self.guildQueryMem or #self.guildQueryMem == 0 then
			return
		end

		local id, _, _2 = net.record("TGuildID", buf, bufLen)

		for i, v in ipairs(self.guildQueryMem) do
			if v:get("ID") == id:get("ID") then
				table.remove(self.guildQueryMem, i)

				return
			end
		end
	end,
	refuseGuildQueryRequests = function(self, value, buf, bufLen)
		if not self.guildQueryMem or #self.guildQueryMem == 0 then
			return
		end

		local id, _, _2 = net.record("TGuildID", buf, bufLen)

		for i, v in ipairs(self.guildQueryMem) do
			if v:get("ID") == id:get("ID") then
				table.remove(self.guildQueryMem, i)

				return
			end
		end
	end,
	getGuildLog = function(self, value, buf, bufLen)
		self.guildLog = {}

		if bufLen < getRecordSize("TLogDesc") then
			return
		end

		self.guildLog = self:decodeArray_(bufLen / getRecordSize("TLogDesc"), "TLogDesc", buf, bufLen)
	end,
	getGuildCorpsMem = function(self, msg, buf, bufLen)
		self.guildcorpsMem = {}

		if bufLen ~= getRecordSize("TCorpsMemDesc") * msg.tag then
			return
		end

		self.guildcorpsMem = self:decodeArray_(msg.tag, "TCorpsMemDesc", buf, bufLen)
	end,
	getRequestUnion = function(self, msg, buf, bufLen)
		self.guildRequestUnion = {}

		if bufLen ~= getRecordSize("TGuildRequestJoinDesc") * msg.tag then
			return
		end

		self.guildRequestUnion = self:decodeArray_(msg.tag, "TGuildRequestJoinDesc", buf, bufLen)
	end,
	getUnion = function(self, msg, buf, bufLen)
		self.guildUnion = {}

		if bufLen ~= getRecordSize("TGuildSimpleDesc") * msg.tag then
			return
		end

		self.guildUnion = self:decodeArray_(msg.tag, "TGuildSimpleDesc", buf, bufLen)
	end,
	getConcern = function(self, msg, buf, bufLen)
		self.guildConcern = {}

		if bufLen ~= getRecordSize("TGildRelation") * msg.tag then
			return
		end

		self.guildConcern = self:decodeArray_(msg.tag, "TGildRelation", buf, bufLen)
	end,
	getHostile = function(self, msg, buf, bufLen)
		self.guildHostile = {}

		if bufLen ~= getRecordSize("TGuildSimpleDesc") * msg.tag then
			return
		end

		self.guildHostile = self:decodeArray_(msg.tag, "TGuildSimpleDesc", buf, bufLen)
	end
}
