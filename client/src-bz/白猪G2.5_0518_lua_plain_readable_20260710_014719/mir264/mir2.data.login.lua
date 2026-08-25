local login = {
	verinfo,
	shopUrl,
	servers,
	notice = {},
	forces,
	netLastName,
	localLastSer,
	groups = {},
	serverMsg,
	serverMsg2,
	loginRet1,
	loginRet2,
	isSDKLogin,
	queue,
	selectIndex = 1,
	pw = "",
	type = "",
	ac = "",
	groupIndex = 1,
	ipLine = 1
}

function login:resetLogin()
	self.shopUrl = nil
	self.verinfo = nil
	self.servers = nil
	self.notice = nil
	self.forces = nil
	self.netLastName = nil
	self.localLastSer = nil
end

function login:setShopUrl(url)
	self.shopUrl = url
end

function login:setVerInfo(verinfo)
	self.verinfo = verinfo
end

function login:getVerName(verid)
	for i, v in ipairs(self.verinfo) do
		if v.verid == verid then
			return v.vername
		end
	end

	return ""
end

function login:getClientVer(verid)
	for i, v in ipairs(self.verinfo) do
		if v.verid == verid then
			return v.clientver
		end
	end

	return nil
end

function login:setServerList(data)
	self.servers = data
end

function login:setNotice(data)
	self.notice = data
end

function login:setForceList(data)
	self.forces = data
end

function login:setNetLastName(name)
	self.netLastName = name
end

function login:setLocalLastServer(data)
	self.localLastSer = data
end

function login:setGroupList(msg, buf, buflen)
	if msg.param > 0 then
		assert(msg.series ~= 1, "sdoa登录方式已淘汰！")

		self.groups = {}

		for i = 1, msg.param do
			self.groups[#self.groups + 1], buf, buflen = net.record("TServerGroupInfo", buf, buflen)
		end
	end
end

function login:getSelectGroup()
	if self.groupIndex <= #self.groups then
		return self.groups[self.groupIndex]
	end

	return {}
end

function login:setSDKLogin(b)
	self.isSDKLogin = b
end

function login:setQueueData(msg)
	if not msg then
		self.queue = nil
	else
		self.queue = {
			pos = msg.param,
			cnt = msg.tag,
			sec = msg.series
		}
	end
end

if IOS_REVIEW then
	login.servers = {
		{
			name = "雷霆",
			ip = "center.peiban.com",
			area = 504,
			ver = 185
		}
	}
end

if VERSION_REVIEW then
	login.servers = {
		{
			name = "热血传奇",
			ip = "center.peiban.com",
			area = 0,
			ver = 185
		}
	}
end

return login
