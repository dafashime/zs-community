local guild = {
	serach = false,
	guildNotice = "",
	clanNotice = "",
	hasGuild = true,
	hasClan = true,
	page = 0,
	corpsList = {},
	guildList = {},
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
	}
}

function guild:getClanName()
	return self.clanInfo and self.clanInfo:get("corpsName") or ""
end

function guild:getGuildName()
	return self.guildInfo and self.guildInfo:get("gildName") or ""
end

function guild:decodeArray_(num, recordName, buf, bufLen)
	local list = {}

	for k = 1, num do
		local record = nil
		record, buf, bufLen = net.record(recordName, buf, bufLen)
		list[k] = record
	end

	return list
end

function guild:initGuildInfo(msg, buf, bufLen)
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
end

function guild:isPresident()
	if self.posInfo then
		return self.posInfo == 4
	end

	return false
end

function guild:isVicePresident()
	if self.posInfo then
		return self.posInfo == 3
	end

	return false
end

function guild:isLeader()
	if self.posInfo then
		return self.posInfo == 2 or self.posInfo == 4 or self.posInfo == 3
	end

	return false
end

function guild:isViceLeader()
	if self.posInfo then
		return self.posInfo == 1
	end

	return false
end

function guild:initClanInfo(msg, buf, bufLen)
	if bufLen == 0 then
		self.clanInfo = nil
	end

	if bufLen ~= getRecordSize("TCorpsDesc") then
		return
	end

	self.clanInfo = getRecord("TCorpsDesc")

	net.record(self.clanInfo, buf, bufLen)
	g_data.mark:addGuild(self.clanInfo:get("captainName"))
end

function guild:initClanList(msg, buf, bufLen)
	self.corpsList = {}

	if bufLen ~= getRecordSize("TCorpsDesc") * msg.series then
		return
	end

	self.corpsList = self:decodeArray_(msg.series, "TCorpsDesc", buf, bufLen)
end

function guild:initGuildList(msg, buf, bufLen)
	self.guildList = {}

	if bufLen ~= getRecordSize("TGuildDesc") * msg.series then
		return
	end

	self.guildList = self:decodeArray_(msg.series, "TGuildDesc", buf, bufLen)
end

function guild:getCorpsMem(msg, buf, bufLen)
	self.corpsMem = {}

	if bufLen ~= getRecordSize("TCorpsMemDesc") * msg.tag then
		return
	end

	self.corpsMem = self:decodeArray_(msg.tag, "TCorpsMemDesc", buf, bufLen)

	print("获取战队成员列表 职业数据")

	for i, v in ipairs(self.corpsMem) do
		if v:get("status") == 0 then
			v:set("status", 1)
		else
			v:set("status", 0)
		end

		print(v:get("name"), g_data.player:getOtherJobStr(v:get("job")), " job 数值 ", v:get("job"))
	end
end

function guild:getCorpsQueryRequests(msg, buf, bufLen)
	self.corpsQueryMem = {}

	if bufLen ~= getRecordSize("TCorpsRequests") * msg.tag then
		return
	end

	self.corpsQueryMem = self:decodeArray_(msg.tag, "TCorpsRequests", buf, bufLen)

	print("获取申请加入战队的玩家列表 职业数据")

	for i, v in ipairs(self.corpsQueryMem) do
		print(v:get("name"), g_data.player:getOtherJobStr(v:get("job")), " job 数值 ", v:get("job"))
	end
end

function guild:acceptCorpsQueryRequests(msg, buf, bufLen)
	if not self.corpsQueryMem or #self.corpsQueryMem == 0 then
		return
	end

	local id, _, _ = net.record("TGuildID", buf, bufLen)

	for i, v in ipairs(self.corpsQueryMem) do
		if v:get("ID") == id:get("ID") then
			table.remove(self.corpsQueryMem, i)

			return
		end
	end
end

function guild:refuseCorpsQueryRequests(msg, buf, bufLen)
	if not self.corpsQueryMem or #self.corpsQueryMem == 0 then
		return
	end

	local id, _, _ = net.record("TGuildID", buf, bufLen)

	for i, v in ipairs(self.corpsQueryMem) do
		if v:get("ID") == id:get("ID") then
			table.remove(self.corpsQueryMem, i)

			return
		end
	end
end

function guild:refushCurClan(msg, buf, bufLen)
	if bufLen == 0 then
		return
	end

	local id = getRecord("TGuildID")

	print("id ", id:get("ID"))
	net.record(id, buf, bufLen)
	print("id ", id:get("ID"))

	if id:get("ID") ~= 0 then
		self.curApplyclan = id:get("ID")

		print("refushCurClan ", self.curApplyclan)
	else
		self.curApplyclan = nil
	end
end

function guild:refushCurGuild(msg, buf, bufLen)
	if bufLen == 0 then
		return
	end

	local id = getRecord("TGuildID")

	print("id ", id:get("ID"))
	net.record(id, buf, bufLen)
	print("id ", id:get("ID"))

	if id:get("ID") ~= 0 then
		self.curApplyguild = id:get("ID")

		print("refushCurGuild ", self.curApplyguild)
	else
		self.curApplyguild = nil
	end
end

function guild:getCorpsLog(msg, buf, bufLen)
	self.corpsLog = {}

	if bufLen < getRecordSize("TLogDesc") then
		return
	end

	self.corpsLog = self:decodeArray_(bufLen / getRecordSize("TLogDesc"), "TLogDesc", buf, bufLen)
end

function guild:getguildcorpsList(msg, buf, bufLen)
	self.guildcorpsList = {}

	if bufLen ~= getRecordSize("TCorpsDesc") * msg.tag then
		return
	end

	self.guildcorpsList = self:decodeArray_(msg.tag, "TCorpsDesc", buf, bufLen)
end

function guild:getguildMem(msg, buf, bufLen)
	dump(msg)
	print(getRecordSize("TGuildMember"), msg.tag)

	if bufLen ~= getRecordSize("TGuildMember") * msg.tag then
		return
	end

	self.guildMems = self:decodeArray_(msg.tag, "TGuildMember", buf, bufLen)

	print("获取行会成员列表 职业数据")

	for i, v in ipairs(self.guildMems) do
		print(v:get("name"), g_data.player:getOtherJobStr(v:get("job")), " job 数值 ", v:get("job"))
	end
end

function guild:getGuildQueryRequests(msg, buf, bufLen)
	self.guildQueryMem = {}

	if bufLen ~= getRecordSize("TGuildRequestJoinDesc") * msg.tag then
		return
	end

	self.guildQueryMem = self:decodeArray_(msg.tag, "TGuildRequestJoinDesc", buf, bufLen)
end

function guild:acceptGuildQueryRequests(msg, buf, bufLen)
	if not self.guildQueryMem or #self.guildQueryMem == 0 then
		return
	end

	local id, _, _ = net.record("TGuildID", buf, bufLen)

	for i, v in ipairs(self.guildQueryMem) do
		if v:get("ID") == id:get("ID") then
			table.remove(self.guildQueryMem, i)

			return
		end
	end
end

function guild:refuseGuildQueryRequests(msg, buf, bufLen)
	if not self.guildQueryMem or #self.guildQueryMem == 0 then
		return
	end

	local id, _, _ = net.record("TGuildID", buf, bufLen)

	for i, v in ipairs(self.guildQueryMem) do
		if v:get("ID") == id:get("ID") then
			table.remove(self.guildQueryMem, i)

			return
		end
	end
end

function guild:getGuildLog(msg, buf, bufLen)
	self.guildLog = {}

	if bufLen < getRecordSize("TLogDesc") then
		return
	end

	self.guildLog = self:decodeArray_(bufLen / getRecordSize("TLogDesc"), "TLogDesc", buf, bufLen)
end

function guild:getGuildCorpsMem(msg, buf, bufLen)
	self.guildcorpsMem = {}

	if bufLen ~= getRecordSize("TCorpsMemDesc") * msg.tag then
		return
	end

	self.guildcorpsMem = self:decodeArray_(msg.tag, "TCorpsMemDesc", buf, bufLen)

	print("获取战队成员列表 职业数据")

	for i, v in ipairs(self.guildcorpsMem) do
		print(v:get("name"), g_data.player:getOtherJobStr(v:get("job")), " job 数值 ", v:get("job"))
	end
end

function guild:getRequestUnion(msg, buf, bufLen)
	self.guildRequestUnion = {}

	if bufLen ~= getRecordSize("TGuildRequestJoinDesc") * msg.tag then
		return
	end

	self.guildRequestUnion = self:decodeArray_(msg.tag, "TGuildRequestJoinDesc", buf, bufLen)

	print("查询申请联盟行会请求")

	for i, v in ipairs(self.guildRequestUnion) do
		print(v:get("corpsName"), v:get("captainName"), v:get("memberCount"))
	end
end

function guild:getUnion(msg, buf, bufLen)
	self.guildUnion = {}

	print(getRecordSize("TGuildSimpleDesc"), msg.tag)

	if bufLen ~= getRecordSize("TGuildSimpleDesc") * msg.tag then
		return
	end

	self.guildUnion = self:decodeArray_(msg.tag, "TGuildSimpleDesc", buf, bufLen)

	print("查询联盟行会请求")

	for i, v in ipairs(self.guildUnion) do
		print(v:get("name"))
	end
end

function guild:getConcern(msg, buf, bufLen)
	self.guildConcern = {}

	if bufLen ~= getRecordSize("TGildRelation") * msg.tag then
		return
	end

	self.guildConcern = self:decodeArray_(msg.tag, "TGildRelation", buf, bufLen)

	print("查询关注行会请求")

	for i, v in ipairs(self.guildConcern) do
		print(v:get("name"))
	end
end

function guild:getHostile(msg, buf, bufLen)
	self.guildHostile = {}

	if bufLen ~= getRecordSize("TGuildSimpleDesc") * msg.tag then
		return
	end

	self.guildHostile = self:decodeArray_(msg.tag, "TGuildSimpleDesc", buf, bufLen)

	print("查询宣战行会请求")

	for i, v in ipairs(self.guildHostile) do
		print(v:get("name"))
	end
end

return guild
