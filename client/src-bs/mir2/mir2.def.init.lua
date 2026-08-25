local current = ...

import(".globa1")
import(".globa2")
import(".globa3")

def = {}

print("init def")

def.colors = import(".colors")
def.cmds = import(".cmds")
def.perload = import(".perload")
def.guild = import(".guild")
def.magic = import(".magic")
def.operate = import(".operate")
def.font = "STHeitiSC"
def.gameName = "热血传奇"
def.gameVersionType = "185"
def.useIGW = 1
def.gameType = "gametea"
def.MIR_VERSION_NUMBER = 131532307

function def.lazyLoadConfig()
	def.role = import(".role", current)

	def.role.init()

	def.items = import(".items", current)
	def.map = import(".map", current)
	def.skill = import(".skill", current)
	def.titledesc = import(".titledesc", current)
	def.wordfilter = import(".wordfilter", current)
	def.gmCmd = import(".gmCmd", current)
	def.bigmap = import(".bigmap", current)
end

function def.setSF(ip, port, password, notice)
	def.sfIp = ip
	def.sfPort = pert
	def.sfPassword = password
	def.sfAuthUrl = "http://" .. ip .. ":" .. port .. "/serverlist?password=" .. password
end

-- me changed
-- def.setSF("1234.sydjscc.top", 8088, "7g9egjkew")
def.setSF("127.0.0.1", 8089, "mir2666")

function def.setSFNotice(notice)
	def.sfNotice = notice
end

function def.setLoginCenter(ip, port, serverName, serverid)
	def.loginCenter = "http://" .. ip .. ":" .. port
	def.loginCenterIP = ip
	def.loginCenterPort = port
	def.serverName = serverName
	def.serverId = serverid
end

def.setLoginCenter("127.0.0.1", 8088, "君临复古", "1997dw")

function def.resetLoginCenter()
	def.loginCenter = nil
	def.loginCenterIP = nil
	def.loginCenterPort = nil
	def.serverName = nil
	def.serverId = nil
end

function def.setGameServer(zoneid, ip, areaID, gameVersion, info, configName, configVer)
	def.zoneid = zoneid
	def.ip = ip
	def.areaID = tonumber(areaID) or 0
	def.gameVersionType = tostring(gameVersion or "185")
	def.isSelectServer = true
	def.serverinfo = info
	def.configName = configName
	def.configVer = configVer
end

function def.resetGameServer()
	def.zoneid = nil
	def.ip = nil
	def.areaID = nil
	def.gameVersionType = nil
	def.isSelectServer = false
	def.serverinfo = nil
	def.configName = nil
	def.configVer = nil
end

function def.setIsLazyLoadConfig(b)
	def.bLazyLoadConfig = b
end
