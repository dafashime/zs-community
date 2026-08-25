local current = ...

import(".globa1")
import(".globa2")
import(".globa3")

def = {}
def.colors = import(".colors")
def.cmds = import(".cmds")
def.perload = import(".perload")
def.guild = import(".guild")
def.magic = import(".magic")
def.operate = import(".operate")
def.ccy = require("mir2.cc")
def.role = import(".bzinit", current)
def.gameName = "君临复古"
def.gameVersionType = "176"
def.useIGW = 1
def.gameType = "gametea"
def.MIR_VERSION_NUMBER = 131532307

function def.lazyLoadConfig()
	def.role.init()

	def.items = import(".items", current)
	def.map = import(".map", current)
	def.skill = import(".skill", current)
	def.titledesc = import(".titledesc", current)
	def.wordfilter = import(".wordfilter", current)
	def.gmCmd = import(".gmCmd", current)
	def.bigmap = import(".bigmap", current)
end

function def.setSFNotice(notice)
	def.sfNotice = notice
end

function def.setLoginCenter(ip, port, serverName, serverid)
	local text = "http://"
	local value = ip
	local text2 = ":"
	local value2 = port

	def.loginCenter = text .. value .. text2 .. value2
	bzmir.gateIP = ip
	bzmir.gatePort = port
	def.serverName = serverName
	def.serverId = serverid
end

function def.setSF(ip, port, password, notice)
	def.sfIp = ip
	def.sfPort = port
	def.sfPassword = password
	def.sfAuthUrl = "http://" .. ip .. ":" .. port .. "/serverlist?password=" .. password
end

function def.resetLoginCenter()
	def.loginCenter = nil
	bzmir.gateIP = nil
	bzmir.gatePort = nil
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
