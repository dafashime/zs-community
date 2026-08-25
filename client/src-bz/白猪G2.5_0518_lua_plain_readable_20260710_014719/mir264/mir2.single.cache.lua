local current = ...
local cache = {
	verifyKey = "mir2VersionCheck",
	safeKey = "H\aOwKaN^7{?!a2v",
	serializeCaches = {}
}
local map_version = "0.1"
local minimap_version = "0.1"
local bigmap_version = "0.1.2"
local setting_version = "0.1.6"
local diy_version = "0.1.3"
local debug_version = "0.1.1"
local helper_version = "0.1"
local cg_version = "0.1"
local relation_version = "0.1"
local serialize = require("mir2.data.serialize")

function cache.checkAll()
	print("checkAll")

	local tasks = {
		"cache",
		"verify",
		"history",
		"res",
		"data",
		"setting",
		"map",
		"minimap",
		"bigmap",
		"chat",
		"diy",
		"debug",
		"helper",
		"relation",
		"iap"
	}

	local function check()
		if #tasks > 0 then
			cache["check_" .. tasks[1]](function()
				table.remove(tasks, 1)
				check()
			end)
		end
	end

	check()
	cache.init_launch()
end

function cache.check_uuid(temp)
	local path = device.writablePath .. "cache/lg"
	local t = io.readfile(path)

	if not t then
		io.writefile(path, crypto.encryptXXTEA(temp, cache.safeKey))

		return temp
	else
		t = crypto.decryptXXTEA(t, cache.safeKey)
	end

	return t
end

function cache.check_verify(func)
	func()
end

function cache.check_history(func)
	func()
end

function cache.check_res(func)
	if not io.exists(device.writablePath .. "res") then
		ycFunction:mkdir(device.writablePath .. "res")
	end

	func()
end

function cache.check_data(func)
	func()
end

function cache.check_cache(func)
	if not io.exists(device.writablePath .. "cache") then
		ycFunction:mkdir(device.writablePath .. "cache")
	end

	func()
end

function cache.getSerialize(filename)
	local ser = cache.serializeCaches[filename]

	if not ser then
		ser = serialize.new()

		ser:open(filename, true)

		cache.serializeCaches[filename] = ser
	end

	return ser.data
end

function cache.getAccount()
	local data = io.readfile(device.writablePath .. "cache/ac")

	if data then
		return json.decode(crypto.decryptXXTEA(data, cache.safeKey))
	end
end

function cache.saveAccount(ac, pw)
	if not pw then
		local account = cache.getAccount()

		if account and account.ac == ac then
			pw = account.pw
		end

		pw = pw or ""
	end

	io.writefile(device.writablePath .. "cache/ac", crypto.encryptXXTEA(json.encode({
		ac = ac,
		pw = pw
	}), cache.safeKey))
end

function cache.saveLastPlayerName(name)
	name = name or ""

	io.writefile(device.writablePath .. "cache/lastPlayer", json.encode({
		lastPlayer = name
	}))
end

function cache.getLastPlayerName()
	local data = io.readfile(device.writablePath .. "cache/lastPlayer")

	if data then
		local data2 = json.decode(data)

		if data2 then
			return data2.lastPlayer
		end
	end
end

function cache.check_setting(func)
	if not io.exists(device.writablePath .. "cache/setting" .. setting_version) then
		ycFunction:mkdir(device.writablePath .. "cache/setting" .. setting_version)
	end

	func()
end

function cache.genSettingPath(playerName, key)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	key = crypto.encodeBase64(key)

	local dirPath = device.writablePath .. "cache/setting" .. setting_version

	return string.format("%s/%s/%s", dirPath, playerName, key), playerName, key, dirPath
end

function cache.getSetting(playerName, key)
	local data = io.readfile(cache.genSettingPath(playerName, key))

	if data then
		return json.decode(data)
	end
end

function cache.saveSetting(playerName, key)
	local settingPath, playerName2, _, dirPath = cache.genSettingPath(playerName, key)
	local path = string.format("%s/%s", dirPath, playerName2)

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	io.writefile(settingPath, json.encode(g_data.setting[key]))
end

function cache.removeSetting(playerName, key)
	os.remove(cache.genSettingPath(playerName, key))
end

function cache.getCustoms(playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")

	local dirPath = device.writablePath .. "cache/customItem"
	local data = io.readfile(string.format("%s/%s", dirPath, playerName))

	if data then
		return json.decode(data)
	end
end

function cache.saveCustoms(playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")

	local dirPath = device.writablePath .. "cache/customItem"

	if not io.exists(dirPath) then
		ycFunction:mkdir(dirPath)
	end

	local path = string.format("%s/%s", dirPath, playerName)

	io.writefile(path, json.encode(g_data.bag.customs))
end

function cache.getHotKey(playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")

	local dirPath = device.writablePath .. "cache/hotKey"
	local data = io.readfile(string.format("%s/%s", dirPath, playerName))

	if data then
		return json.decode(data)
	end
end

function cache.saveHotKey(playerName)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")

	local dirPath = device.writablePath .. "cache/hotKey"

	if not io.exists(dirPath) then
		ycFunction:mkdir(dirPath)
	end

	local path = string.format("%s/%s", dirPath, playerName)

	io.writefile(path, json.encode(g_data.hotKey.keyInfos))
end

function cache.copy_map()
	if device.platform == "android" then
		local mapVersionPath = device.writablePath .. "res/map" .. map_version .. "/version"
		local mapZipPath = device.writablePath .. "res/map.zip"

		if io.exists(mapVersionPath) and io.exists(mapZipPath) then
			return
		end

		local data, md5 = ycFunction:getFileData("map.zip", true)

		if data and md5 then
			io.writefile(mapZipPath, data)

			if crypto.md5file(mapZipPath) == md5 then
				io.writefile(mapVersionPath, "")
			end
		end

		cc.FileUtils:getInstance():purgeCachedEntries()
	end
end

function cache.check_map(func)
	if not io.exists(device.writablePath .. "res/map" .. map_version) then
		ycFunction:mkdir(device.writablePath .. "res/map" .. map_version)
	end

	cache.copy_map()
	func()
end

function cache.getMapFilePath(mapid)
	return device.writablePath .. "res/map" .. map_version .. "/" .. string.lower(mapid) .. ".map"
end

function cache.unzipMapFile(mapid)
	local path = cache.getMapFilePath(mapid)

	if io.exists(path) then
		return
	end

	cache.copy_map()

	local zipPath = cc.FileUtils:getInstance():fullPathForFilename("map.zip")

	return ycFunction:unzipWithFilename(zipPath, string.lower(mapid) .. ".map", path, true)
end

function cache.minimapPath()
	return device.writablePath .. "cache/minimap" .. minimap_version .. "/"
end

function cache.check_minimap(func)
	local path = cache.minimapPath()

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	func()
end

function cache.minimapFullPath(minimapID)
	print(cache.minimapPath() .. minimapID .. ".png")

	return cache.minimapPath() .. minimapID .. ".png"
end

function cache.getMinimap(minimapID)
	local path = cache.minimapFullPath(minimapID)

	if io.exists(path) then
		return cc.Director:getInstance():getTextureCache():addImage(path)
	end
end

function cache.check_bigmap(func)
	if not io.exists(device.writablePath .. "cache/bigmap" .. bigmap_version) then
		ycFunction:mkdir(device.writablePath .. "cache/bigmap" .. bigmap_version)
	end

	func()
end

function cache.getBigmap(key)
	local data = io.readfile(device.writablePath .. "cache/bigmap" .. bigmap_version .. "/" .. key)

	if data then
		return json.decode(data)
	end
end

function cache.saveBigmap(key)
	io.writefile(device.writablePath .. "cache/bigmap" .. bigmap_version .. "/" .. key, json.encode(g_data.bigmap.maps[key]))
end

function cache.check_chat(func)
	local path = device.writablePath .. "cache/chat/"

	if io.exists(path) then
		rmdir(path)
	end

	ycFunction:mkdir(path)
	ycFunction:mkdir(path .. "wav")
	ycFunction:mkdir(path .. "amr")
	ycFunction:mkdir(path .. "pic")
	func()
end

function cache.getVoiceWav()
	return device.writablePath .. "cache/chat/wav/"
end

function cache.getVoiceAmr()
	return device.writablePath .. "cache/chat/amr/"
end

function cache.getPicPathFull()
	return device.writablePath .. "cache/chat/pic/"
end

function cache.removePicTmp()
	local path = cache.getPicTmp()

	if io.exists(path) then
		os.remove(path)
	end
end

function cache.getPicTmp()
	return device.writablePath .. "cache/chat/pic/tmp.png"
end

function cache.diyPath()
	return device.writablePath .. "cache/diy" .. diy_version .. "/"
end

function cache.check_diy(func)
	local path = cache.diyPath()

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	func()
end

function cache.removeDiy(playerName, key)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	key = crypto.encodeBase64(key)

	local path = string.format("%s/%s/%s", cache.diyPath(), playerName, key)

	if io.exists(path) then
		os.remove(path)
	end
end

function cache.getDiy(playerName, key)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	key = crypto.encodeBase64(key)

	local path = string.format("%s/%s/%s", cache.diyPath(), playerName, key)
	local data = io.readfile(path)

	if data then
		return json.decode(crypto.decodeBase64(data))
	end
end

function cache.saveDiy(playerName, key, value)
	playerName = crypto.encodeBase64(playerName)
	playerName = string.gsub(playerName, "/", "#")
	key = crypto.encodeBase64(key)

	local path = string.format("%s/%s", cache.diyPath(), playerName)

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	local path2 = string.format("%s/%s", path, key)

	io.writefile(path2, crypto.encodeBase64(json.encode(value)))
end

function cache.check_helper(func)
	if not io.exists(device.writablePath .. "cache/helper" .. helper_version) then
		ycFunction:mkdir(device.writablePath .. "cache/helper" .. helper_version)
	end

	func()
end

function cache.getHelper(key)
	local data = io.readfile(device.writablePath .. "cache/helper" .. helper_version .. "/" .. key)

	if data then
		return json.decode(data)
	end
end

function cache.getHelperSerialize(key)
	local filename = device.writablePath .. "cache/helper" .. helper_version .. "/" .. key

	return cache.getSerialize(filename)
end

function cache.saveHelper(key, data)
	io.writefile(device.writablePath .. "cache/helper" .. helper_version .. "/" .. key, json.encode(data))
end

function cache.removeHelper(key)
	os.remove(device.writablePath .. "cache/helper" .. helper_version .. "/" .. key)
end

function cache.debugPath()
	return device.writablePath .. "cache/debug" .. debug_version .. "/"
end

function cache.check_debug(func)
	local path = cache.debugPath()

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	func()
end

function cache.getDebug(key)
	local path = cache.debugPath()
	local data = io.readfile(path .. key)

	if data then
		return json.decode(data)
	end
end

function cache.saveDebug(key, value)
	local path = cache.debugPath()

	io.writefile(path .. key, json.encode(value))
end

function cache.saveDebugLog(folder, key, value)
	local path = cache.debugPath() .. folder .. "/"

	if not io.exists(path) then
		ycFunction:mkdir(path)
	end

	local file = io.open(path .. key, "w+b")

	for i, v in ipairs(value) do
		file:write(v .. "\r\n")
	end

	io.close(file)
end

function cache.cgPath()
	return device.writablePath .. "cache/cg" .. cg_version
end

function cache.cgCheckFirstIn()
	return false
end

function cache.cgClear()
	if DEBUG > 0 then
		local path = cache.cgPath()

		os.remove(path)
	end
end

function cache.check_relation(func)
	if not io.exists(device.writablePath .. "cache/relation" .. relation_version) then
		ycFunction:mkdir(device.writablePath .. "cache/relation" .. relation_version)
	end

	func()
end

function cache.getFriendChatRecord(playerName, target)
	print(playerName, target, "123")

	local f = crypto.encodeBase64(playerName .. target)
	local f2 = string.gsub(f, "/", "#")
	local filename = device.writablePath .. "cache/relation" .. relation_version .. "/" .. f2

	return cache.getSerialize(filename)
end

local verifieds = {}
local iap_cache_path = device.writablePath .. "cache/verifieds"

function cache.check_iap(func)
	if io.exists(iap_cache_path) then
		verifieds = json.decode(io.readfile(iap_cache_path))
	end

	dump(verifieds)
	func()
end

function cache.storage_verifiedTransaction(id, roleid)
	if not verifieds[id] then
		verifieds[id] = roleid

		local data = json.encode(verifieds)

		io.writefile(iap_cache_path, data)
	end
end

function cache.check_verifiedTransaction(id)
	return verifieds[id]
end

function cache.init_launch()
	if not io.exists(device.writablePath .. "cache/launch.json") then
		io.writefile(device.writablePath .. "cache/launch.json", json.encode({
			init = "success"
		}))
	end
end

function cache.setIsFirstLaunchGame(b)
	local data = io.readfile(device.writablePath .. "cache/launch.json")
	local jsonData = json.decode(data)

	jsonData.bIsFirstLaunch = b

	io.writefile(device.writablePath .. "cache/launch.json", json.encode(jsonData))
end

function cache.getIsFirstLaunchGame()
	local data = io.readfile(device.writablePath .. "cache/launch.json")

	if data then
		local jsonData = json.decode(data)

		if jsonData.bIsFirstLaunch == nil then
			return true
		else
			return jsonData.bIsFirstLaunch
		end
	end
end

function cache.setLastSfServer(name)
	local data = io.readfile(device.writablePath .. "cache/launch.json")
	local jsonData = json.decode(data)

	name = utf8strs(name)
	jsonData.lastSfServer = name

	io.writefile(device.writablePath .. "cache/launch.json", json.encode(jsonData))
end

function cache.getLastSfServer()
	local data = io.readfile(device.writablePath .. "cache/launch.json")

	if data then
		local jsonData = json.decode(data)
		local name = ""

		if jsonData.lastSfServer then
			for i, v in ipairs(jsonData.lastSfServer) do
				name = name .. v
			end
		end

		return name
	end

	return nil
end

return cache
