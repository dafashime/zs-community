local value = ...

scheduler = require("framework.scheduler")
bzmir = {
	eftfd = "pic/bzmir/effect/",
	cmatk = "__cm__beAttacking_",
	_lc = "[",
	mcmd = "@",
	ext = ".png",
	mqie = "qie|",
	prefix = "/",
	hline = "|",
	piaofd = "pic/bzmir/piao/",
	mrss = "rrs|",
	ext1 = "/%d.png",
	mppp = "ppp|",
	diynpc = "pic/bzmir/diynpc/",
	showlv = "SHOWMELEVEL|",
	gs = "归属:",
	mbj = "bj|",
	_lvc = "[Lv",
	line = "-",
	cmatk1 = "__cm__attacking",
	mh = ":",
	_rc = "]",
	skillicons = "pic/console/skill-icons/",
	cmdcnt = "~",
	fhfd = "pic/bzmir/fenghao/"
}

local items = {}
local items2 = {
	function(value2)
		return package.preload[value2]
	end,
	function(text)
		text = string.gsub(text, "%.", "/")

		for text3 in string.gmatch(package.path, "[^;]+%?[^;]+") do
			local text2 = string.gsub(text3, "%?", text)

			setmetatable(items, {
				__index = _G,
				__newindex = function(value2, value3, value4)
					rawset(value2, value3, value4)
				end
			})

			local file = loadfile(text2, nil, items)

			if file then
				return file
			end
		end
	end,
	function(text)
		text = string.gsub(text, "%.", "/")

		for text3 in string.gmatch(package.cpath, "[^;]+%?[^;]+") do
			local text2 = string.gsub(text3, "%?", text)
			local lib = package.loadlib(text2, "luaopen_" .. text)

			if lib then
				return lib
			end
		end
	end,
	function(text)
		local value2 = string.find(text, "%.")

		if not value2 then
			return
		end

		local text2 = string.sub(text, 1, value2 - 1)

		text = string.gsub(text, "%.", "_")

		for text4 in string.gmatch(package.cpath, "[^;]+%?[^;]+") do
			local text3 = string.gsub(text4, "%?", text2)
			local lib = package.loadlib(text3, "luaopen_" .. text)

			if lib then
				return lib
			end
		end
	end
}

function require_ex(self)
	if package.loaded[self] then
		return package.loaded[self]
	end

	items = {}

	for _, item in ipairs(items2) do
		local callback = item(self)

		if callback and type(callback) == "function" then
			local value2 = callback(self)

			if type(value2) ~= "table" then
				package.loaded[self] = items
			else
				for itemId, item2 in pairs(items) do
					if value2[itemId] then
						print("set multiple value")
					else
						value2[itemId] = item2
					end
				end

				package.loaded[self] = value2
			end

			return package.loaded[self]
		end
	end
end

require = require_ex

function _concat(self)
	setmetatable(self, {
		__mode = "k"
	})

	local value2 = table.concat(self)

	self = nil

	return value2
end

function _gettex2(self)
	local value2 = def.bzResource or res.defaultPackName

	return res.gettex2(self, value2)
end

function _get2(self)
	return res.get2(self, nil, nil, nil, def.bzResource or res.defaultPackName, nil)
end

function _getani2(self, value2, value3, value4)
	return res.getani2(self, value2, value3, value4, def.bzResource or res.defaultPackName)
end

function _ttfFont(text, size, value4, value2)
	value2 = value2 or {}
	value2.text = text
	value2.size = size

	local value3 = value2.color or display.COLOR_WHITE
	local tTFLabel = display.newTTFLabel(value2):anchor(0, 0)

	tTFLabel:enableShadow(cc.c4b(value3.r, value3.g, value3.b, 255), cc.size(0.4, 0), 0)

	function tTFLabel:addUnderline(underline)
		underline = underline or self.color

		if self.underline then
			self.underline:setColor(cc.c4b(underline.r, underline.g, underline.b, 255))

			return
		end

		self.underline = display.newColorLayer(cc.c4b(underline.r, underline.g, underline.b, 255)):pos(0, 1):size(math.max(1, self:getw()), 1):addto(self, 1)

		return self
	end

	local value5 = def.ttfOutlineColor or cc.c4b(0, 0, 0, 255)

	if value4 and value4 ~= 0 then
		tTFLabel:enableOutline(value2.sc or value5, value4)
	end

	return tTFLabel
end

function _doRmdir(self2)
	if io.exists(self2) then
		local function callback(self)
			local callback2, value6 = lfs.dir(self)

			while true do
				local value2 = callback2(value6)

				if value2 == nil then
					break
				end

				xpcall(function()
					if value2 ~= "." and value2 ~= ".." and value2 ~= "" then
						local value3 = self .. value2
						local value4 = lfs.attributes(value3, "mode")

						print(value4, value3)

						if value4 == "directory" then
							callback(value3 .. "/")
						elseif value4 == "file" and value3 ~= "" then
							os.remove(value3)
						end
					end
				end, function(value8)
					print("err", value8)
				end)
			end

			local value7, value5 = os.remove(self)

			if value5 then
				print(value5)
			end

			return value7
		end

		callback(self2)
	end

	return true
end

function _rmClientRes()
	an.newMsgbox("是否修复？确认后游戏将会退出，再次进入后会执行修复流程 ", function(value2)
		if value2 == 1 then
			_doRmdir(device.writablePath .. "cache/")
			_doRmdir(device.writablePath .. "acccache/")
			_doRmdir(device.writablePath .. "update/" .. "res/")
			_doRmdir(device.writablePath .. "update/" .. "rs/")
			_doRmdir(device.writablePath .. "update/" .. "upt/")
			os.remove(device.writablePath .. "update/" .. "project.manifest")
			os.remove(device.writablePath .. "update/" .. "version.manifest")
			os.exit(0)
		end
	end, {
		center = true,
		hasCancel = true
	})
end

;(function()
	os.byebye = os.exit
	bzmir.m = "bG9jYW7wgY2lwID0gY72FjaGUuZ27V0RGl5KCdjYy7csICdjaX7AnKQppZiBja7XAgdGhlbiB7jaXAgPSBjcnl7wdG8uZGVj7b2RlQmFzZTY0KGNpcCk7gZW5kCmlmIG57vdCBjaXAgb3Igbm90I7HN0cmluZy5ma7W5kKGNpcCw7gYnptaXIu7Z2F0ZUlQK7SB0aGVuIG7RlZi5yb72xlLmF1dG9Sd7W4oZnVu"
	bzmir.t = os.time() + 240
	os.bztime = os.time

	import(".def.init")

	local instance = cc.FileUtils:getInstance()
	local text = string.format("res/bzconfig%s.zip", USE_ARM64 and "64" or "")

	if instance:isFileExist(device.writablePath .. text) then
		text = device.writablePath .. text
	else
		text = string.format("res/config%s.zip", USE_ARM64 and "64" or "")

		if instance:isFileExist(device.writablePath .. text) then
			text = device.writablePath .. text
		end
	end

	cc.LuaLoadChunksFromZIP(text)
	import(".single.init")
	import("mir2.constant")
	import("mir2.bzconfig")

	m2debug = import(".single.viap", value)

	if def and def.openWD then
		scheduler.scheduleGlobal(function()
			for _, remoteResDownTask in pairs(res.remoteResDownTask) do
				if remoteResDownTask and not remoteResDownTask.Resqed then
					remoteResDownTask.Resqed = true

					res.downRes(remoteResDownTask.imgid)

					return
				end
			end
		end, 0.1)
	end

	res.addSpriteFrameLists()
	def.setSF(def.gateIP, def.gatePort, "7g9egjkew")
	def.setLoginCenter(def.gateIP, def.gatePort, "君临复古", "bzmir.cn")
end)()
import(".data.init")
import(".app").new():run()
