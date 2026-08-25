import("timer.callbacks")

func = {}

function printf(self, ...)
	print(string.format(tostring(self), ...))
end

function gmprint(self, ...)
	if def.advbzm2debug then
		print(string.format(tostring(self), ...))
	end
end

function checknumber(self, value)
	return tonumber(self, value) or 0
end

function checkint(self)
	return math.round(checknumber(self))
end

function checkbool(self)
	return self ~= nil and self ~= false
end

function fixuint(self)
	if self < 0 then
		local value = g_data.player.ability

		return value:get("Exp") + value:get("maxExp") + 4294967296
	end

	return self
end

function checktable(self)
	if type(self) ~= "table" then
		self = {}
	end

	return self
end

function isset(self, value2)
	local value = type(self)

	return (value == "table" or value == "userdata") and self[value2] ~= nil
end

function clone(self2)
	local items = {}

	local function callback2(self)
		if type(self) ~= "table" then
			return self
		elseif items[self] then
			return items[self]
		end

		local items2 = {}

		items[self] = items2

		for itemId, item in pairs(self) do
			items2[callback2(itemId)] = callback2(item)
		end

		return setmetatable(items2, getmetatable(self))
	end

	return callback2(self2)
end

function class(cname, super)
	local value = type(super)
	local class2

	if value ~= "function" and value ~= "table" then
		value = nil
		super = nil
	end

	if value == "function" or super and super.__ctype == 1 then
		class2 = {}

		if value == "table" then
			for itemId, item in pairs(super) do
				class2[itemId] = item
			end

			class2.__create = super.__create
			class2.super = super
		else
			class2.__create = super

			function class2.ctor()
				return
			end
		end

		class2.__cname = cname
		class2.__ctype = 1

		function class2.new(...)
			local value2 = class2.__create(...)

			for itemId2, item2 in pairs(class2) do
				value2[itemId2] = item2
			end

			value2.class = class2

			value2:ctor(...)

			return value2
		end
	else
		if super then
			class2 = {}

			setmetatable(class2, {
				__index = super
			})

			class2.super = super
		else
			class2 = {
				ctor = function()
					return
				end
			}
		end

		class2.__cname = cname
		class2.__ctype = 2
		class2.__index = class2

		function class2.new(...)
			local value3 = setmetatable({}, class2)

			value3.class = class2

			value3:ctor(...)

			return value3
		end
	end

	return class2
end

function iskindof(self, value2)
	local value = type(self)
	local metatable

	if value == "table" then
		metatable = getmetatable(self)
	elseif value == "userdata" then
		metatable = tolua.getpeer(self)
	end

	while metatable do
		if metatable.__cname == value2 then
			return true
		end

		metatable = metatable.super
	end

	return false
end

function handler(self, callback2)
	return function(...)
		return callback2(self, ...)
	end
end

function math.newrandomseed()
	local value, text2 = pcall(function()
		return require("socket")
	end)

	if value then
		math.randomseed(tonumber(tostring(text2.gettime() / 1000):reverse():sub(1, 10)))
	else
		math.randomseed(os.time())
	end

	math.random()
	math.random()
	math.random()
	math.random()
end

function math:round()
	self = checknumber(self)

	return math.floor(self + 0.5)
end

function math:angle2radian()
	return self * math.pi / 180
end

function math:radian2angle()
	return self / math.pi * 180
end

function io:exists()
	local file = io.open(self, "r")

	if file then
		io.close(file)

		return true
	end

	return false
end

function io.readfile(path)
	local file = io.open(path, "r")

	if file then
		local value = file:read("*a")

		io.close(file)

		return value
	end

	return nil
end

function io:writefile(path, data2)
	data2 = data2 or "w+b"

	local file = io.open(self, data2)

	if file then
		if file:write(path) == nil then
			return false
		end

		io.close(file)

		return true
	else
		return false
	end
end

function io:pathinfo()
	local value = string.len(self)
	local value2 = value + 1

	while value > 0 do
		local value3 = string.byte(self, value)

		if value3 == 46 then
			value2 = value
		elseif value3 == 47 then
			break
		end

		value = value - 1
	end

	local text3 = string.sub(self, 1, value)
	local text2 = string.sub(self, value + 1)
	local value4 = value2 - value
	local text4 = string.sub(text2, 1, value4 - 1)
	local text5 = string.sub(text2, value4)

	return {
		dirname = text3,
		filename = text2,
		basename = text4,
		extname = text5
	}
end

function printInfo()
	return
end

function io:filesize()
	local enabled = false
	local file = io.open(self, "r")

	if file then
		local value = file:seek()

		enabled = file:seek("end")

		file:seek("set", value)
		io.close(file)
	end

	return enabled
end

function table:nums()
	local count = 0

	for _, _2 in pairs(self) do
		count = count + 1
	end

	return count
end

function table:keys()
	local items = {}

	for itemId, _ in pairs(self) do
		items[#items + 1] = itemId
	end

	return items
end

function table:values()
	local items = {}

	for _, item in pairs(self) do
		items[#items + 1] = item
	end

	return items
end

function table:merge(value)
	for itemId, item in pairs(value) do
		self[itemId] = item
	end
end

function table:insertto(items, value)
	value = checkint(value)

	if value <= 0 then
		value = #self + 1
	end

	local value2 = #items

	for index = 0, value2 - 1 do
		self[index + value] = items[index + 1]
	end
end

function table:indexof(value, value2)
	for index = value2 or 1, #self do
		if self[index] == value then
			return index
		end
	end

	return false
end

function table:keyof(value)
	for itemId, item in pairs(self) do
		if item == value then
			return itemId
		end
	end

	return nil
end

function table:removebyvalue(value2, value3)
	local count2 = 0
	local count = 1
	local value = #self

	while count <= value do
		if self[count] == value2 then
			table.remove(self, count)

			count2 = count2 + 1
			count = count - 1
			value = value - 1

			if not value3 then
				break
			end
		end

		count = count + 1
	end

	return count2
end

function table:map(callback2)
	for itemId, item in pairs(self) do
		self[itemId] = callback2(item, itemId)
	end
end

function table:walk(callback2)
	for itemId, item in pairs(self) do
		callback2(item, itemId)
	end
end

function table:filter(callback2)
	for itemId, item in pairs(self) do
		if not callback2(item, itemId) then
			self[itemId] = nil
		end
	end
end

function table:unique(value)
	local items2 = {}
	local items = {}
	local count = 1

	for itemId, item in pairs(self) do
		if not items2[item] then
			if value then
				items[count] = item
				count = count + 1
			else
				items[itemId] = item
			end

			items2[item] = true
		end
	end

	return items
end

string._htmlspecialchars_set = {
	["'"] = "&#039;",
	[">"] = "&gt;",
	["<"] = "&lt;",
	["&"] = "&amp;",
	["\""] = "&quot;"
}

function string.htmlspecialchars(text2)
	for key2, htmlspecialchars_set in pairs(string._htmlspecialchars_set) do
		text2 = string.gsub(text2, key2, htmlspecialchars_set)
	end

	return text2
end

function string.restorehtmlspecialchars(text2)
	for key2, htmlspecialchars_set in pairs(string._htmlspecialchars_set) do
		text2 = string.gsub(text2, htmlspecialchars_set, key2)
	end

	return text2
end

function string:nl2br()
	return string.gsub(self, "\n", "<br />")
end

function string.text2html(text2)
	text2 = string.gsub(text2, "\t", "    ")
	text2 = string.htmlspecialchars(text2)
	text2 = string.gsub(text2, " ", "&nbsp;")
	text2 = string.nl2br(text2)

	return text2
end

function string:ltrim()
	return string.gsub(self, "^[ \t\n\r]+", "")
end

function string:rtrim()
	return string.gsub(self, "[ \t\n\r]+$", "")
end

function string.trim(text2)
	text2 = string.gsub(text2, "^[ \t\n\r]+", "")

	return string.gsub(text2, "[ \t\n\r]+$", "")
end

function string:ucfirst()
	return string.upper(string.sub(self, 1, 1)) .. string.sub(self, 2)
end

local function callback2(self)
	if string.byte(self) == 0 then
		return ""
	end

	return "%" .. string.format("%02X", string.byte(self))
end

function string.urlencode(text2)
	text2 = string.gsub(tostring(text2), "\n", "\r\n")
	text2 = string.gsub(text2, "([^%w%.%- ])", callback2)

	return string.gsub(text2, " ", "+")
end

function string.urldecode(text2)
	text2 = string.gsub(text2, "+", " ")
	text2 = string.gsub(text2, "%%(%x%x)", function(value)
		return string.char(checknumber(value, 16))
	end)
	text2 = string.gsub(text2, "\r\n", "\n")

	return text2
end

function string:utf8len()
	local value2 = string.len(self)
	local count = 0
	local items = {
		0,
		192,
		224,
		240,
		248,
		252
	}

	while value2 ~= 0 do
		local value3 = string.byte(self, -value2)
		local value = #items

		while items[value] do
			if value3 >= items[value] then
				value2 = value2 - value

				break
			end

			value = value - 1
		end

		count = count + 1
	end

	return count
end

function string:encode2hex()
	local text3 = ""

	for index = 1, string.len(self) do
		local text2 = string.byte(string.sub(self, index, index))

		text3 = text3 .. string.format("%02x", text2)
	end

	return text3
end

function string:decodeFromHex()
	local text3 = ""

	for index = 1, string.len(self), 2 do
		local text2 = tonumber(string.sub(self, index, index + 1), 16)

		if text2 ~= nil then
			text3 = text3 .. string.char(text2)
		end
	end

	return text3
end

function string:parseContent(text6, value, value2)
	value = value or "<"
	value2 = value2 or ">"

	local function callback2(text3)
		while true do
			local value3 = string.find(text3, value)
			local value4 = string.find(text3, value2)

			if value3 and value4 then
				self:addLabel(string.sub(text3, 1, value3 - 1))

				local text4 = string.sub(text3, value3 + 1, value4 - 1)

				if string.upper(text4) ~= "C" and string.upper(text4) ~= "/C" then
					local text7 = ""
					local text2
					local text5
					local value5 = string.find(text4, "/")

					if value5 then
						text7 = string.sub(text4, 1, value5 - 1)
						text2 = string.sub(text4, value5 + 1, #text4)

						local value6 = string.find(text2, ":")

						if value6 then
							text5 = string.sub(text2, value6 + 1, #text2)
							text2 = string.sub(text2, 1, value6 - 1)

							if text5 == "red" then
								text5 = 249
							end
						end
					else
						text7 = text4
					end

					if text2 and string.upper(text2) == "FONTSIZE" then
						self:setFSize(tonumber(text5))
					elseif text2 and string.upper(text2) == "WIDTH" then
						self.maxWidth = tonumber(text5)
					else
						local value7 = text5 and _stringToCorlor(text5) or text2 ~= nil and def.colors.clYellow or def.colors.clRed
						local items

						if text2 then
							if string.upper(text2) == "SCOLOR" then
								items = {
									ani = true,
									easyTouch = true,
									addTouchSizeY = 12,
									callback = function()
										return
									end
								}
							elseif text2:find(bzmir.mcmd) ~= nil then
								items = {
									ani = true,
									easyTouch = true,
									addTouchSizeY = 12,
									callback = function()
										def.role.call(bzmir.mcmd .. text2)
									end
								}
							end
						end

						self:addLabel(text7, value7, nil, nil, items):setName(text7)
					end
				end

				text3 = string.sub(text3, value4 + 1, string.len(text3))
			else
				self:addLabel(text3)

				break
			end
		end
	end

	local parts = string.split(text6, "\\")

	for _, item in ipairs(parts) do
		self:nextLine()
		callback2(item)
	end
end

function string:formatnumberthousands()
	local text2 = tostring(checknumber(self))
	local value

	repeat
		local text3

		text2, text3 = string.gsub(text2, "^(-?%d+)(%d%d%d)", "%1,%2")
	until text3 == 0

	return text2
end

function func.callUrl(self2, value2, value3)
	if not self2 then
		print("no url")

		return
	end

	if network.getInternetConnectionStatus() == cc.kCCNetworkStatusNotReachable then
		return
	end

	local value5

	local function callback2(self)
		local value4 = self.name == "completed"
		local value = self.request

		if self.name == "failed" and value ~= nil then
			value:release()

			value = nil
			callback2 = nil
		end

		if not value4 then
			return
		end

		if value:getResponseStatusCode() ~= 200 then
			return
		end

		local responseData = value:getResponseData()

		if value2 then
			def.role.call(bzmir.mcmd .. value2 .. "~" .. responseData)
		end

		if value3 then
			loadstring(value3 .. "(" .. responseData .. ")")
		end

		if value ~= nil then
			value:release()

			local value6

			callback2 = nil
		end
	end

	local withUrl = cc.HTTPRequest:createWithUrl(callback2, self2, cc.kCCHTTPRequestMethodGET)

	withUrl:retain()
	withUrl:setTimeout(200)
	withUrl:start()
end

function string:contans(value)
	return string.match(self, value) ~= nil
end

function func:filterNameFlag()
	if def.hideString then
		for _, hideString in ipairs(def.hideString) do
			self = self:gsub(hideString, "")
		end
	end

	if def.openMultiJob then
		self = self:gsub("N0", "")
		self = self:gsub("N1", "")
		self = self:gsub("N2", "")

		if def.jobMaps then
			for key2, _2 in pairs(def.jobMaps) do
				self = self:gsub("N" .. key2, "")
			end
		end
	end

	return self
end

function func:calcAlert(value, text6)
	local value3
	local text2, text5 = string.gsub(text6, "{p}", tostring(self))
	local text3, text4 = string.gsub(text2, "{c}", value)
	local value2 = text4

	return text3, value2
end

function func:makeValues()
	local parts = string.split(self, bzmir.hline)

	if parts[2] and parts[2] ~= "" then
		if not def.makeValues then
			def.makeValues = {}
		end

		def.makeValues[tonumber(parts[2])] = {
			key = parts[3],
			v1 = parts[4]
		}
	end

	return true
end

function func:qie()
	local parts = string.split(self, bzmir.hline)

	if #parts == 4 then
		main_scene.ground.map:addMsg({
			roleid = tonumber(parts[4]),
			qieType = parts[2],
			qieValue = tonumber(parts[3])
		})
	end

	return true
end

function func:LMPiao()
	local parts = string.split(self, ":")
	local value = parts[2]:gsub("^%s*(.-)%s*$", "%1")

	if #parts == 4 then
		func.customhpStyle(bzmir.mppp .. value .. bzmir.hline .. parts[4] .. bzmir.hline .. parts[3])
	end

	return true
end

function func:customhpStyle()
	local parts = string.split(self, bzmir.hline)

	if #parts == 4 then
		main_scene.ground.map:addMsg({
			roleid = tonumber(parts[4]),
			piaoId = parts[2],
			piaoNumber = tonumber(parts[3])
		})
	end

	return true
end

function func:customhpStyle1()
	local parts = string.split(self, bzmir.hline)

	if #parts == 4 then
		local player = main_scene.ground.map:findHeroWithName(parts[4])

		if player then
			g_data.player.piaoTmpDatas[player.roleid] = {
				piaoId = parts[2],
				piaoNumber = tonumber(parts[3]),
				piaoTime = os.time()
			}
		end
	end

	return true
end

function func:bjStyle()
	local parts = string.split(self, bzmir.hline)

	if parts[2] and parts[2] ~= "" then
		main_scene.ground.map:addMsg({
			baoji = true,
			roleid = tonumber(parts[2])
		})
	end

	return true
end

function func:showRoleStyle()
	local parts = string.split(self, bzmir.hline)

	if parts[2] and parts[2] ~= "" then
		main_scene.ground.map:addMsg({
			buff = true,
			roleid = tonumber(parts[2]),
			buffName = parts[3],
			dir = parts[4],
			lockid = parts[5]
		})
	end

	return true
end

function func:qieActive()
	if g_data.player.qieType and g_data.player.qieValue then
		local parts

		if self:find("=") ~= nil then
			parts = string.split(self, "=")[2]
		else
			local player = main_scene.ui.console.controller.lock.role

			if player and player.isInScreen and not player.die then
				parts = player.roleid
			end
		end

		if parts then
			net.send({
				CM_SAY
			}, {
				bzmir.mqie .. g_data.player.qieType .. bzmir.hline .. g_data.player.qieValue .. bzmir.hline .. parts
			})
		end
	end

	return true
end

function func:qieSaveTypes()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		if parts[1] and parts[2] then
			g_data.player.qieType = parts[1]
			g_data.player.qieValue = parts[2]
		end
	end

	return true
end

function func:piaoActive()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		if parts[1] then
			local text2

			if parts[3] and parts[3] ~= "nil" then
				if parts[3] == "1" then
					text2 = tostring(main_scene.ground.player.roleid)
				else
					text2 = parts[3]
				end
			else
				local player = main_scene.ui.console.controller.lock.role

				if player and player.isInScreen and not player.die then
					text2 = tostring(player.roleid)
				end
			end

			if parts[4] and parts[4] == "1" then
				if text2 then
					func.customhpStyle(bzmir.mppp .. parts[1] .. bzmir.hline .. (parts[2] or "0") .. bzmir.hline .. text2)
				end
			elseif text2 then
				net.send({
					CM_SAY
				}, {
					bzmir.mppp .. parts[1] .. bzmir.hline .. (parts[2] or "0") .. bzmir.hline .. text2
				})
			end
		end
	end

	return true
end

function func:bzalert()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		if #parts >= 7 then
			if parts[8] and g_data.login.localLastSer.smallzone and parts[8] ~= g_data.login.localLastSer.smallzone then
				return true
			end

			local value2 = parts[1] or "bg"
			local number2 = tonumber(parts[2]) or 0.6
			local number3 = tonumber(parts[3]) or 35
			local number = tonumber(parts[4]) or 300
			local value3 = parts[5] or "251"
			local value4 = parts[6] or "20"
			local value = parts[7] or "无内容"

			if main_scene.ui.alertbars[tostring(number)] then
				main_scene.ui.alertbars[tostring(number)]:addMsg(value)
			else
				local text2 = main_scene.ui.barCreater.new(string.format("pic/bzmir/alert/%s.png", value2), number2, number3, number, true, value3, value4):add2(main_scene.ui, 3)

				main_scene.ui.alertbars[tostring(number)] = text2

				text2:addMsg(value)
			end
		end
	end

	return true
end

function func:bjActive()
	local roleOwner = main_scene.ui.console.controller.lock

	if roleOwner then
		local player = roleOwner.role

		if player and player.isInScreen and not player.die then
			player.bj = true

			net.send({
				CM_SAY
			}, {
				bzmir.mbj .. tostring(player.roleid)
			})
		end
	end

	return true
end

function func:buffme()
	local parts = string.split(self, "=")

	if parts[2] and main_scene and main_scene.ground.player then
		local value = parts[2]:split(":")
		local text3 = "1000"

		if value[2] and value[2] == "hero" then
			if g_data.hero then
				net.send({
					CM_SAY
				}, {
					bzmir.mrss .. tostring(g_data.hero.roleid) .. bzmir.hline .. value[1] .. bzmir.hline .. tostring(g_data.hero.dir) .. bzmir.hline .. text3
				})
			end
		else
			local text2 = main_scene.ui.console.controller.lock

			if text2 and text2.role and text2.role.isInScreen and not text2.role.die then
				text3 = tostring(text2.role.roleid)
			end

			net.send({
				CM_SAY
			}, {
				bzmir.mrss .. tostring(main_scene.ground.player.roleid) .. bzmir.hline .. value[1] .. bzmir.hline .. tostring(main_scene.ground.player.dir) .. bzmir.hline .. text3
			})
		end
	end

	return true
end

function func:buff()
	local parts = string.split(self, "=")

	if parts[2] then
		local number2 = parts[2]:split(":")

		if number2[2] then
			if number2[2] == "1" then
				net.send({
					CM_SAY
				}, {
					bzmir.mrss .. tostring(main_scene.ground.player.roleid) .. bzmir.hline .. number2[1]
				})
			else
				local number = main_scene.ground.map:findRole(tonumber(number2[2]))

				if number and number.isInScreen and not number.die then
					net.send({
						CM_SAY
					}, {
						bzmir.mrss .. number2[2] .. bzmir.hline .. number2[1]
					})
				end
			end
		else
			local roleOwner = main_scene.ui.console.controller.lock

			if roleOwner then
				local player = roleOwner.role

				if player and player.isInScreen and not player.die then
					net.send({
						CM_SAY
					}, {
						bzmir.mrss .. tostring(player.roleid) .. bzmir.hline .. number2[1]
					})
				end
			end
		end
	end

	return true
end

function func:cnpc()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ui.panels.npc then
		main_scene.ui.panels.npc:refresh(parts[2])
	end

	return true
end

function func:cdyp()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ui.panels.dynamicPanel then
		main_scene.ui.panels.dynamicPanel:refresh(parts[2])
	end

	return true
end

function func:dyp()
	local parts = string.split(self, "=")

	if parts[2] then
		local items = {
			body = parts[2]
		}

		if main_scene.ui.panels.dynamicPanel then
			main_scene.ui.panels.dynamicPanel:hidePanel()
		end

		main_scene.ui:togglePanel("dynamicPanel", items)
	end

	return true
end

function func:nc()
	local parts = string.split(self, "=")

	if parts[2] then
		local items = {
			body = parts[2]
		}

		if main_scene.ui.panels.notice then
			def.role.cancelAutoRun(main_scene.ui.panels.notice.timer)
			main_scene.ui.panels.notice:hidePanel()
		end

		main_scene.ui:togglePanel("notice", items)
	end

	return true
end

function func:bossAlert()
	local items = {
		body = "Bg:alert:bg:center:0:nil:220|AutoHide:10|1:Text:1000:nil:18:" .. self .. "@250:left:-750:nil:10"
	}

	if main_scene.ui.panels.notice then
		def.role.cancelAutoRun(main_scene.ui.panels.notice.timer)
		main_scene.ui.panels.notice:hidePanel()
	end

	main_scene.ui:togglePanel("notice", items)

	return false
end

function func:eqOther()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ui.panels.equipOther then
		main_scene.ui.panels.equipOther:genExtend(parts[2])
	end

	return true
end

function func:eqOtherTab()
	local parts = string.split(self, "=")

	if parts[2] then
		local value = parts[1]:split(":")

		if main_scene.ui.panels.equipOther then
			main_scene.ui.panels.equipOther:updateContent(parts[2], value[2])
		end
	end

	return true
end

function func:eq()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ui.panels.equip then
		main_scene.ui.panels.equip:genExtend(parts[2])
	end

	return true
end

function func:eqTab()
	local parts = string.split(self, "=")

	if parts[2] then
		local value = parts[1]:split(":")

		if main_scene.ui.panels.equip then
			main_scene.ui.panels.equip:updateContent(parts[2], value[2])
		end
	end

	return true
end

function func:bztask()
	local parts = string.split(self, "=")

	if parts[2] then
		main_scene.ui.console:call("tasks", "updateContent", parts[2])
	end

	return true
end

function func:mapExtend()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ground.map then
		main_scene.ground.map:genExtend(parts[2])
	end

	return true
end

function func:consoleExtend()
	local parts = string.split(self, "=")
	local parts2 = string.split(parts[1], ":")

	if parts[2] and main_scene.ui.console then
		main_scene.ui.console:genExtend(parts[2], parts2[2])
	end

	return true
end

function func:bagExtend()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:genExtend(parts[2])
	end

	return true
end

function func:bigmapExtend()
	local parts = string.split(self, "=")

	if parts[2] and main_scene.ui.panels.bigmap then
		main_scene.ui.panels.bigmap:genExtend(parts[2])
	end

	return true
end

function func:bottomExtend()
	local parts = string.split(self, "=")
	local parts2 = string.split(parts[1], ":")

	if parts[2] and main_scene.ui.console.widgets.bottom then
		main_scene.ui.console.widgets.bottom:genExtend(parts[2], parts2[2])
	end

	return true
end

function func:cdtp()
	local parts2 = string.split(self, "=")
	local parts = string.split(parts2[1], ":")

	if parts2[2] and parts[2] and main_scene.ui.panels[parts[2]] then
		main_scene.ui.panels[parts[2]].isLoaded = true

		main_scene.ui.panels[parts[2]]:refresh(parts2[2])
	end

	return true
end

function func:dtp()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		def.role.PF:togglePanel(parts[1], parts[2], parts[3])
	end

	return true
end

function func:togglePanel()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		if parts[2] then
			if main_scene.ui.panels[parts[1]] then
				main_scene.ui:togglePanel(parts[1])
			end
		else
			main_scene.ui:togglePanel(parts[1])
		end
	end

	return true
end

function func:reloadBag()
	net.send({
		CM_QUERYBAGITEMS
	})

	return true
end

function func:openLink()
	local parts = string.split(self, "$")

	if parts[2] then
		parts[2] = string.gsub(parts[2], "@", "://")
		parts[2] = string.gsub(parts[2], "~", "/")

		device.openURL(parts[2])
	end

	return true
end

function func:delayCall()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		if parts[1] and parts[2] then
			def.role.autoRun(function()
				if main_scene and main_scene.ui then
					def.role.call(bzmir.mcmd .. parts[1])
				end
			end, tonumber(parts[2]))
		end
	end

	return true
end

function func:timer()
	local parts2 = string.split(self, "=")
	local parts = string.split(parts2[2], ":")
	local number = tonumber(parts[1]) or 0
	local value = parts[2] or "normal"
	local number2 = tonumber(parts[3]) or 1
	local value2 = parts[4]
	local enabled = false

	if number == 0 then
		if def.role.timer and def.role.timer[value] then
			def.role.stopRepeater(def.role.timer[value])

			def.role.timer[value] = nil
		end
	else
		if not def.role.timer then
			def.role.timer = {}
		end

		local value3 = def.role.timer[value]

		if value3 then
			def.role.stopRepeater(value3)

			def.role.timer[value] = nil
		end

		def.role.timer[value] = def.role.createRepeater(function()
			if main_scene and main_scene.ui then
				if value2 then
					local callback2 = load("return " .. value2 .. "()")

					if callback2 then
						enabled = callback2()

						local value4

						if enabled then
							def.role.call(bzmir.mcmd .. value)
						end
					else
						def.role.call(bzmir.mcmd .. value)
					end
				else
					def.role.call(bzmir.mcmd .. value)
				end
			end
		end, number2)
	end

	return true
end

function func:openDark()
	local parts2 = string.split(self, "=")
	local parts = string.split(parts2[2], ":")

	if parts[1] and parts[1] == "1" then
		main_scene.ui.console:showDark(true, tonumber(parts[2]))
	else
		main_scene.ui.console:showDark(false, tonumber(parts[2]))
	end

	return true
end

function func:status()
	local parts2 = string.split(self, "=")
	local parts = string.split(parts2[2], ":")

	if parts[1] then
		if parts[1]:find("HeroRecover") ~= nil then
			if parts[2] == "1" then
				def.role.roleStatus.heroRecover = true
			else
				def.role.roleStatus.heroRecover = false
			end
		elseif parts[1]:find("PetRecover") ~= nil then
			if parts[2] == "1" then
				def.role.roleStatus.petRecover = true
			else
				def.role.roleStatus.petRecover = false
			end
		elseif parts[1]:find("Recover") ~= nil then
			if parts[2] == "1" then
				def.role.roleStatus.canRecover = true
			else
				def.role.roleStatus.canRecover = false
			end
		elseif parts[1]:find("EQChanged") ~= nil then
			def.role.initCurrWeapon()
		elseif parts[1]:find("canLostHPHit") ~= nil then
			if parts[2] == "1" then
				def.role.roleStatus.canLostHPCall = true
			else
				def.role.roleStatus.canLostHPCall = false
			end
		elseif parts[1]:find("buffs") ~= nil then
			def.role.roleStatus.buffs = parts[2]
		else
			g_data.player.cmAbil[parts[1]] = parts[2]
		end
	end

	return true
end

function func:autoRat()
	local parts = string.split(self, "=")

	if parts[2] then
		if parts[2] == "0" then
			main_scene.ui.console.autoRat:stop()
		elseif parts[2] == "1" then
			main_scene.ui.console.autoRat:enable()
		end
	elseif main_scene.ui.console.autoRat.enableRat then
		main_scene.ui.console.autoRat:stop()
	else
		main_scene.ui.console.autoRat:enable()
	end

	local btnOwner = main_scene.ui.console:get("btnAutoRat")

	if btnOwner then
		btnOwner.btn:setIsSelect(main_scene.ui.console.autoRat.enableRat)
	end

	return true
end

function func:autopick()
	if not def.role.mainsetting.funAoths then
		return true
	end

	if def.role.mainsetting.funAoths[2] ~= "999" then
		return true
	end

	if g_data.setting.autoRat.noAutoPickup then
		return true
	end

	if not main_scene then
		return true
	end

	if g_data.setting.autoRat.noPickUpItem then
		main_scene.ui.console.btnCallbacks:handle("setting", "btnNoPickUpItem")
	end

	return true
end

function func:go()
	if main_scene.ui.console.autoRat.enableRat then
		main_scene.ui.console.autoRat:stop()
	end

	local parts = string.split(self, ":")

	def.role.autoPath(parts[2], tonumber(parts[3]), tonumber(parts[4]))

	return true
end

function func:talkWithNPC()
	if main_scene.ui.console.autoRat.enableRat then
		main_scene.ui.console.autoRat:stop()
	end

	local parts = string.split(self, ":")

	def.role.talkWithNPC(parts[2], parts[3], parts[4], parts[5])

	return true
end

function func:MIG()
	local parts = string.split(self, ":")

	main_scene.ui.console.controller.lock:attackUseMagicById(tonumber(parts[2]))

	return true
end

function func:taskMonOff()
	def.role.mainsetting.TaskMonName = nil

	local monsOwner = main_scene.ground.map

	for _, mon in pairs(monsOwner.mons) do
		mon.info:setName(mon.info.name.texts, true, true)
	end

	return true
end

function func:taskMonOn()
	local parts = string.split(self, "=")

	def.role.mainsetting.TaskMonName = parts[2]

	local monsOwner = main_scene.ground.map

	for _, mon in pairs(monsOwner.mons) do
		mon.info:setName(mon.info.name.texts, true, true)
	end

	return true
end

function func:use()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], ":")

		if parts[2] then
			def.ccy.useItem(true, parts[1])
		else
			def.ccy.useItem(false, parts[1])
		end
	end

	return true
end

function func:makeValuesActive()
	return true
end

function func:initialization()
	for _, hero in pairs(main_scene.ground.map.heros) do
		hero.info:setName(hero.info.name.texts, true)
	end

	return true
end

function func:hideAbil()
	local parts = string.split(self, ":")

	if parts[2] and parts[3] and parts[4] then
		local value = parts[2]

		g_data.player.cmAbil[value] = tonumber(parts[3]) or 0
		g_data.player.cmAbil["max" .. value] = tonumber(parts[4]) or 0
	end

	return true
end

function func:refershSkillIcon()
	if main_scene then
		for _, widget in pairs(main_scene.ui.console.widgets) do
			if widget.btn and widget.__cname == "btnMove" and widget.config.btntype == "skill" then
				if def.magic.buildSkillIcon then
					widget.btn.sprite:setTex(res.gettex2(def.magic.buildSkillIcon(widget.data.magicId)))
				else
					widget.btn.sprite:setTex(res.gettex2(bzmir.skillicons .. tostring(widget.data.magicId) .. bzmir.ext))
				end
			end
		end
	end

	return true
end

function func:joinCorps()
	local parts = string.split(self, "=")
	local value = g_data.guild.allCorpsList

	if value then
		for _, item in pairs(value) do
			if item:get("corpsName") == parts[2] then
				net.send({
					CM_CORPS_REQUEST_JOIN
				}, nil, {
					{
						"ID",
						item:get("corpsID")
					}
				})
			end
		end
	end

	return true
end

function func:markFly()
	g_data.client:setLastTime("gofly", true)

	return true
end

function func:warFinsh()
	net.send({
		CM_GILD_QUERY_HOSTILE,
		tag = 30,
		series = 0
	})

	return false
end

function func:goodTips()
	local parts = string.split(self, "\"")
	local str2 = parts[6]

	if not def.showItemNameWithPlus and parts[6]:find("+") ~= nil then
		str2 = string.split(parts[6], "+")[1]
	end

	if not def.alertTips then
		return false, str2
	end

	if not main_scene.ui.tipsBar then
		return false, str2
	end

	if def.hideOtherZoneMsg and g_data.login.localLastSer.smallzone and parts[2]:sub(1, 2) ~= g_data.login.localLastSer.smallzone then
		return true, str2
	end

	local str3 = parts[2]

	if def.smallzoneCfg then
		local value = parts[2]:sub(1, 2)

		if def.smallzoneCfg[value] then
			str3 = "(" .. def.smallzoneCfg[value] .. ") " .. parts[2]
		end
	end

	local items = {
		fontSize = def.alertTips.fontSize or 18,
		msgs = {
			{
				str = str3,
				color = main_scene.ui.tipsBar.color1
			},
			{
				str = parts[3],
				color = main_scene.ui.tipsBar.color2
			},
			{
				str = parts[4],
				color = main_scene.ui.tipsBar.color3 or main_scene.ui.tipsBar.color1
			},
			{
				str = parts[5],
				color = main_scene.ui.tipsBar.color4 or main_scene.ui.tipsBar.color2
			},
			{
				str = str2,
				color = main_scene.ui.tipsBar.color5 or main_scene.ui.tipsBar.color1
			}
		}
	}

	if not main_scene.ui.tipsBar:addMsg(items) then
		return false, str2
	end

	return def.hideAlertInChat, str2
end

function func:goodTipsold()
	local value5 = string.len(self)
	local number = 5.7
	local value6 = value5 * number
	local number2 = 10
	local value = 275 - value6 / 2 - 15
	local parts = string.split(self, "\"")

	if not def.showItemNameWithPlus and parts[6]:find("+") ~= nil then
		parts[6] = string.split(parts[6], "+")[1]
	end

	local config = def.role.getConfig("alert")

	if config and config.panel then
		local content2 = clone(config.panel)
		local value13
		local value7

		content2[3], value7 = func.calcAlert(value, parts[2], content2[3])

		local value2 = value + string.len(parts[2]) * number + number2
		local value8

		content2[4], value8 = func.calcAlert(value2, parts[3], content2[4])

		local value3 = value2 + string.len(parts[3]) * number + number2
		local value9

		content2[5], value9 = func.calcAlert(value3, parts[4], content2[5])

		local value4 = value3 + string.len(parts[4]) * number + number2
		local value10

		content2[6], value10 = func.calcAlert(value4, parts[5], content2[6])

		local value11 = value4 + string.len(parts[5]) * number + number2
		local value12

		content2[7], value12 = func.calcAlert(value11, parts[6], content2[7])

		local items = {
			content = content2
		}

		items.noFile = true
		items.cannotMove = true

		def.role.PF:createPanel("alert", items)
	end

	return def.hideAlertInChat
end

function func:showEffectforName()
	local parts2 = string.split(self, "=")
	local value = main_scene.ground.map

	if parts2[2] and value then
		local parts = string.split(parts2[2], ":")

		if parts[5] then
			local text2 = def.ccy.md("EFID_" .. parts[1] .. parts[2] .. tostring(parts[3]) .. tostring(parts[4]))

			if value.runForeverEffects and value.runForeverEffects[text2] then
				value.runForeverEffects[text2]:removeSelf()

				value.runForeverEffects[text2] = nil
			end
		elseif g_data.map.mapTitle == parts[1] then
			value:showEffectForName(parts[2], {
				x = tonumber(parts[3]),
				y = tonumber(parts[4])
			})
		end
	end

	return true
end

function func:remoteCall()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], bzmir.hline)

		if parts[1] then
			local text5 = parts[1]
			local text2 = string.gsub(text5, "@", "://")
			local text3 = string.gsub(text2, "~", "/")
			local text4 = string.gsub(text3, "#", "=")

			func.callUrl(text4, parts[2], parts[3])
		end
	end

	return true
end

function func:markLevel()
	local parts2 = string.split(self, "=")

	if parts2[2] then
		local parts = string.split(parts2[2], bzmir.hline)

		if parts[1] then
			local value = parts[1]

			if parts[2] then
				local level = tonumber(parts[2])

				if level then
					local levelOwner = g_data.player.cacheRoles[value]

					if not levelOwner then
						levelOwner = {}
						g_data.player.cacheRoles[value] = levelOwner
					end

					levelOwner.level = level
				end
			end
		end
	end

	return true
end

function func:showMeLevel()
	local parts = string.split(self, bzmir.hline)

	if parts[2] and parts[2] == tostring(g_data.player.roleid) and g_data.player.name and g_data.player.name.texts then
		net.send({
			CM_SAY
		}, {
			"MARKLEVEL=" .. g_data.player.name.texts[1] .. bzmir.hline .. tostring(g_data.player.ability.level)
		})
	end

	return true
end

function func:SetVitality()
	local parts = string.split(self, bzmir.hline)

	if parts[2] then
		net.send({
			CM_SAY
		}, {
			"@SetVitality " .. parts[2] .. " " .. parts[3] .. " 1"
		})
	end

	return true
end

function func:saveJob(job2)
	local function callback2(name2, job3)
		return {
			name = name2,
			job = job3
		}
	end

	local value2 = device.writablePath .. "cache/" .. def.ccy.md(g_data.login.localLastSer.zonename .. "_job") .. "/"

	if not io.exists(value2) then
		ycFunction:mkdir(value2)
	end

	local job4 = func.getJob()

	job4[self] = callback2(self, job2)

	local text2 = string.format("%s/%s", value2, def.ccy.md(g_data.login.localLastSer.zonename .. "_job"))
	local value

	for itemId, item in pairs(job4) do
		if value then
			value = value .. "@@@"
		else
			value = ""
		end

		value = value .. itemId .. "$" .. crypto.encodeBase64(json.encode(callback2(item.name, item.job)))
	end

	if value then
		io.writefile(text2, value)
	end

	local heroWithName = main_scene.ground.map:findHeroWithName(self)

	if heroWithName and not heroWithName.die then
		heroWithName.job = job2

		heroWithName:refreshFeature()
	end
end

function func.getJob()
	local value3 = device.writablePath .. "cache/" .. def.ccy.md(g_data.login.localLastSer.zonename .. "_job") .. "/"
	local text2 = string.format("%s/%s", value3, def.ccy.md(g_data.login.localLastSer.zonename .. "_job"))

	if io.exists(text2) then
		local value = io.readfile(text2)
		local items = {}

		if value then
			local value4 = value:split("@@@")

			for _, item in ipairs(value4) do
				local value2 = item:split("$")

				items[value2[1]] = json.decode(crypto.decodeBase64(value2[2]))
			end

			return items
		end
	end

	return {}
end

function func.getJobbyName(name2)
	local job2 = func.getJob()[name2]

	if not job2 and def.openMultiJob then
		local text2 = "^N(%d?)"
		local number = string.match(name2, text2)

		if number then
			job2 = {
				name = name2,
				job = tonumber(number)
			}
		end
	end

	return job2
end

function func:playsound(value)
	sound.playSound(self, value)
end

function func:SetAttrPanel(attrPanel)
	if attrPanel == "equip" then
		def.role.mainPanel = {}
	elseif attrPanel == "hero" then
		def.role.heroPanel = {}
	elseif attrPanel == "equipOther" then
		def.role.OtherPanel = {}
	elseif attrPanel then
		def.role.mainPanel = {}
	else
		def.role.heroPanel = {}
	end

	local items = self:split(":")

	for index = 1, #items do
		if items and items[index] then
			local value = items[index]:split("#")

			if value and value[1] and value[2] then
				if attrPanel == "equip" then
					def.role.mainPanel[#def.role.mainPanel + 1] = {
						value[1],
						value[2]
					}
				elseif attrPanel == "hero" then
					def.role.heroPanel[#def.role.heroPanel + 1] = {
						value[1],
						value[2]
					}
				elseif attrPanel == "equipOther" then
					def.role.OtherPanel[#def.role.OtherPanel + 1] = {
						value[1],
						value[2]
					}
				elseif attrPanel then
					def.role.mainPanel[#def.role.mainPanel + 1] = {
						value[1],
						value[2]
					}
				else
					def.role.heroPanel[#def.role.heroPanel + 1] = {
						value[1],
						value[2]
					}
				end
			end
		end
	end
end

function func:process_bz_cmd(response)
	if string.contans(self, "ccc") then
		return func.customhpStyle1(self)
	elseif string.contans(self, "BL") then
		return func.makeValues(self)
	elseif string.contans(self, "qie") then
		return func.qie(self)
	elseif string.contans(self, "ppp") then
		return func.customhpStyle(self)
	elseif string.contans(self, "bj") then
		return func.bjStyle(self)
	elseif string.contans(self, "rrs") then
		return func.showRoleStyle(self)
	elseif string.contans(self, "MARKLEVEL") then
		return func.markLevel(self)
	elseif string.contans(self, "SHOWMELEVEL") then
		return func.showMeLevel(self)
	elseif string.contans(self, "QIE%d+") then
		return func.LMPiao(self)
	elseif string.contans(self, "BJ%d+") then
		return func.LMPiao(self)
	elseif string.contans(self, "FU%d+") then
		return func.LMPiao(self)
	elseif string.contans(self, "OSSGS") then
		local parts = string.split(self, bzmir.mh)
		local number7 = tonumber(parts[2])
		local value13 = parts[3]
		local role = main_scene.ground.map:findRole(number7)

		if role and not role.die then
			role.guishu = bzmir.gs .. value13
		end

		return true
	elseif string.contans(self, "FROFF") then
		local number14 = self:split(bzmir.hline)
		local number3 = main_scene.ground.map:findRole(tonumber(number14[3]), nil, true)

		if number3 and not number3.die then
			number3:closeFilter(number14[2])
		end

		return true
	elseif string.contans(self, "FLTR") then
		local number13 = self:split(bzmir.hline)
		local number = main_scene.ground.map:findRole(tonumber(number13[3]), nil, true)

		if number and not number.die then
			number:openFilter(number13[2])
			def.role.autoRun(function()
				if number and not number.die then
					number:closeFilter(number13[2])
				end
			end, tonumber(number13[4]))
		end

		return true
	end

	if self and response.user and def.hideOtherZoneMsg and def.hideString and g_data.login.localLastSer.smallzone and SM_BROADCASTMESSAGE ~= response.ident and response.user ~= "" then
		local value5 = response.user:sub(1, 2)
		local value14 = g_data.login.localLastSer.smallzone

		for _, hideString in ipairs(def.hideString) do
			if value5 == hideString and value5 ~= value14 then
				return true
			end
		end
	end

	if response.channel == "战队" then
		if string.contans(self, "已经正式加入了本战队") then
			if g_data.client:checkLastTime(self, 6) then
				g_data.client:setLastTime(self, true)

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
				net.send({
					CM_GILDMEMBER_LIST
				})

				return false
			end

			return true
		elseif string.contans(self, "的入队请求") then
			return true
		elseif string.contans(self, "被逐出战队") then
			return true
		elseif string.contans(self, "战队") and string.contans(self, "击杀了") then
			if main_scene.ground:smr() then
				return true
			end

			return false
		end
	elseif response.channel == "行会" then
		if string.contans(self, "战队") and string.contans(self, "击杀了") then
			if main_scene.ground:smr() then
				return true
			end

			return false
		end
	elseif SM_BROADCASTMESSAGE == response.ident then
		if def.smallzoneCfg then
			local value6 = self:sub(1, 2)

			if def.smallzoneCfg[value6] then
				self = "(" .. def.smallzoneCfg[value6] .. ") " .. self
			end
		end

		if def.BroadcastShow and main_scene.ui.alertbar then
			main_scene.ui.alertbar:addMsg(string.format("<font color=251 size=20>%s<font>", self))
		end

		return false
	elseif response.channel == "系统" and SM_BROADCASTMESSAGE ~= response.ident then
		if string.contans(self, "bzaction") then
			local color2 = self:split(bzmir.hline)

			if color2[2] then
				if color2[2] == "SHAKE" then
					scheduler.performWithDelayGlobal(function()
						def.ccy.sceneShake()
					end, tonumber(color2[3]) or 1)
				elseif color2[2] == "RMBUFF" then
					local number4 = main_scene.ground.map:findRole(tonumber(color2[3]), nil, true)

					if number4 and not number4.die then
						number4:removeLoop(color2[4])
					end
				elseif color2[2] == "SETSKILLBTN" then
					g_data.setting.autoRat.defaultAtkMagic.enable = true
					g_data.setting.autoRat.defaultAtkMagic.magicId = tonumber(color2[3])

					cache.saveSetting(main_scene.ui.common.getPlayerName(), "autoRat")
					main_scene.ui.console:call("attackBtns", "chgAttackType")
				elseif color2[2] == "SETSKILLAUTO" then
					g_data.setting.autoRat.atkMagic.enable = true
					g_data.setting.autoRat.atkMagic.magicId = tonumber(color2[3])

					cache.saveSetting(main_scene.ui.common.getPlayerName(), "autoRat")
				elseif color2[2] == "TIPSBAR" then
					if main_scene.ui.customBar then
						if color2[4] and color2[5] then
							main_scene.ui.customBar:setPos(display.cx + tonumber(color2[4]), display.cy + tonumber(color2[5]))
						end

						main_scene.ui.customBar:addMsg(color2[3])
					end
				elseif color2[2] == "FADELB" then
					if color2[3] then
						main_scene.ui:fadeLabel(color2[3])
					end
				elseif color2[2] == _Events.CM_CHANGEBAG then
					if color2[3] then
						local max = tonumber(color2[3])

						if max then
							g_data.bag.max = max
						end
					end
				elseif color2[2] == _Events.CM_TAKEOFF then
					if color2[3] then
						local number5 = g_data.equip.items[tonumber(color2[3])]

						if number5 then
							local recog2 = number5:get("makeIndex")
							local number8 = tonumber(color2[3])
							local var2 = number5.getVar("name")

							net.send({
								CM_TAKEOFFITEM,
								recog = recog2,
								param = number8
							}, {
								var2
							})
						end
					end
				elseif color2[2] == _Events.CM_RSITEM then
					if color2[3] then
						local number6 = g_data.equip.items[tonumber(color2[3])]

						if number6 then
							local recog3 = number6:get("makeIndex")
							local number2 = tonumber(color2[3])
							local var = number6.getVar("name")

							net.send({
								CM_TAKEOFFITEM,
								recog = recog3,
								param = number2
							}, {
								var
							})
							def.role.autoRun(function()
								local value2 = g_data.bag.curItem

								if value2 and value2.getVar("name") == var and getTakeOnPosition(value2.getVar("stdMode")) == number2 and g_data.bag:use("take", value2:get("makeIndex"), {
									where = number2
								}) then
									net.send({
										CM_TAKEONITEM,
										recog = value2:get("makeIndex"),
										param = number2
									}, {
										var
									})

									g_data.bag.curItem = nil
								end
							end, 0.2)
						end
					end
				elseif color2[2] == _Events.CM_CACHEJOB then
					func.saveJob(color2[3], tonumber(color2[4]))
				elseif color2[2] == _Events.CM_SETABIL then
					g_data.player.cmAbil[color2[3]] = color2[4]
				elseif color2[2] == _Events.CM_ZONEMSG then
					if g_data.login.localLastSer.smallzone and color2[3] == g_data.login.localLastSer.smallzone then
						for index, data2 in ipairs(response.data) do
							if type(data2) == "string" then
								response.data[index] = color2[4]

								break
							end
						end

						return false
					end
				elseif color2[2] == _Events.CM_NO_BACKCD then
					g_data.player.cmAbil.noBackCD = color2[3] == "1"
				elseif color2[2] == _Events.CM_UNLIMITEDMOVE then
					if color2[3] == "0" then
						main_scene.ui.common.addMsg("移动中不允许穿人穿怪", display.COLOR_WHITE, display.COLOR_BLUE)
					elseif color2[3] == "1" then
						main_scene.ui.common.addMsg("移动中允许穿怪", display.COLOR_WHITE, display.COLOR_BLUE)
					elseif color2[3] == "2" then
						main_scene.ui.common.addMsg("移动中允许穿人", display.COLOR_WHITE, display.COLOR_BLUE)
					elseif color2[3] == "3" then
						main_scene.ui.common.addMsg("移动中允许穿人穿怪", display.COLOR_WHITE, display.COLOR_BLUE)
					end

					g_data.player:setUnlimitedMoveState(tonumber(color2[3]))
				elseif color2[2] == _Events.CM_BAN_ATTACK then
					g_data.player.cmAbil.banAttack = color2[3] == "1"

					if color2[4] then
						local number9 = tonumber(color2[4]) or 1

						def.role.autoRun(function()
							if main_scene and main_scene.ui then
								g_data.player.cmAbil.banAttack = false
							end
						end, number9)
					end
				elseif color2[2] == _Events.CM_BANMOVE then
					g_data.player.cmAbil.banMove = color2[3] == "1"

					if color2[4] then
						local number10 = tonumber(color2[4]) or 1

						if not color2[5] then
							net.send({
								CM_SAY
							}, {
								"FLTR|gray|" .. tostring(main_scene.ground.player.roleid) .. bzmir.hline .. color2[4]
							})
						else
							net.send({
								CM_SAY
							}, {
								"FLTR|" .. color2[5] .. "|" .. tostring(main_scene.ground.player.roleid) .. bzmir.hline .. color2[4]
							})
						end

						def.role.autoRun(function()
							if main_scene and main_scene.ui then
								g_data.player.cmAbil.banMove = false
							end
						end, number10)
					end
				elseif color2[2] == "OFFFILTER" then
					net.send({
						CM_SAY
					}, {
						"FROFF|" .. color2[3] .. bzmir.hline .. tostring(main_scene.ground.player.roleid)
					})
				elseif color2[2] == _Events.CM_FILTER then
					net.send({
						CM_SAY
					}, {
						"FLTR|" .. color2[4] .. bzmir.hline .. color2[3] .. bzmir.hline .. color2[5]
					})
				elseif color2[2] == _Events.CM_FIX_RUN then
					g_data.player.cmAbil.fixRun = color2[3] == "1"

					if color2[4] then
						local number11 = tonumber(color2[4]) or 1

						def.role.autoRun(function()
							if main_scene and main_scene.ui then
								g_data.player.cmAbil.fixRun = false
							end
						end, number11)
					end
				elseif color2[2] == _Events.CM_MSGBOX then
					an.newMsgbox(color2[3], nil, {
						center = true
					})
				elseif color2[2] == "随机CD" then
					def.openShuijiCD = tonumber(color2[3]) or 1.5
				elseif color2[2] == _Events.CM_NEED_BAG_PASS then
					g_data.player.bagNeedPass = true
				elseif color2[2] == "SM_SEND_DATA" then
					local value4 = main_scene.ui.panels[color2[3]]

					if value4 and value4.processMsg then
						value4:processMsg(color2[4], color2[5]:split(":"))
					end
				elseif color2[2] == _Events.CM_PASS_OK then
					_Events:dispatchEvent({
						name = _Events.CM_PASS_OK,
						data = {
							OK = color2[3] == "1"
						}
					})
				elseif color2[2] == _Events.CM_TIPS_SHOW then
					if color2[3] then
						main_scene.ui:tip(color2[3])
					end
				elseif color2[2] == _Events.AC_SET_TEXT then
					_Events:dispatchEvent({
						name = _Events.AC_SET_TEXT,
						data = {
							elmtName = color2[3],
							text = color2[4]
						}
					})
				elseif color2[2] == _Events.AC_SET_TEXTCOLOR then
					_Events:dispatchEvent({
						name = _Events.AC_SET_TEXTCOLOR,
						data = {
							elmtName = color2[3],
							color = _stringToCorlor(color2[4])
						}
					})
				elseif color2[2] == _Events.AC_SET_TEXTM then
					_Events:dispatchEvent({
						name = _Events.AC_SET_TEXTM,
						data = {
							elmtName = color2[3],
							textLines = color2[4]
						}
					})
				elseif color2[2] == _Events.AC_SET_IMG then
					_Events:dispatchEvent({
						name = _Events.AC_SET_IMG,
						data = {
							elmtName = color2[3],
							filePath = color2[4],
							fileName = color2[5]
						}
					})
				elseif color2[2] == _Events.AC_SET_DIMG then
					_Events:dispatchEvent({
						name = _Events.AC_SET_DIMG,
						data = {
							elmtName = color2[3],
							dataFile = color2[4],
							fileName = color2[5]
						}
					})
				elseif color2[2] == _Events.AC_SET_RBTN then
					_Events:dispatchEvent({
						name = _Events.AC_SET_RBTN,
						data = {
							elmtName = color2[3],
							filePath = color2[4],
							btnFile = color2[5],
							pressFile = color2[6],
							textOrSprite = color2[7],
							isSprite = color2[8] == "1"
						}
					})
				elseif color2[2] == _Events.AC_STOP_SPR then
					_Events:dispatchEvent({
						name = _Events.AC_STOP_SPR,
						data = {
							elmtName = color2[3]
						}
					})
				elseif color2[2] == _Events.AC_SET_DRBTN then
					_Events:dispatchEvent({
						name = _Events.AC_SET_DRBTN,
						data = {
							elmtName = color2[3],
							dataFile = color2[4],
							btnFile = color2[5],
							pressFile = color2[6],
							textOrSprite = color2[7],
							isSprite = color2[8] == "1"
						}
					})
				elseif color2[2] == _Events.AC_SET_RCMD then
					_Events:dispatchEvent({
						name = _Events.AC_SET_RCMD,
						data = {
							elmtName = color2[3],
							text = color2[4],
							fontColor = _stringToCorlor(color2[5])
						}
					})
				elseif color2[2] == _Events.AC_SET_ITEM then
					_Events:dispatchEvent({
						name = _Events.AC_SET_ITEM,
						data = {
							elmtName = color2[3],
							itemName = color2[4],
							scale = tonumber(color2[5]),
							showBg = color2[6],
							showEffect = color2[7]
						}
					})
				elseif color2[2] == _Events.AC_SET_ITEMM then
					_Events:dispatchEvent({
						name = _Events.AC_SET_ITEMM,
						data = {
							elmtName = color2[3],
							itemName = color2[4]
						}
					})
				elseif color2[2] == _Events.AC_SET_INPUT then
					_Events:dispatchEvent({
						name = _Events.AC_SET_INPUT,
						data = {
							elmtName = color2[3],
							inputText = color2[4]
						}
					})
				elseif color2[2] == _Events.AC_SET_CHECK then
					_Events:dispatchEvent({
						name = _Events.AC_SET_CHECK,
						data = {
							elmtName = color2[3],
							check = color2[4] == "1",
							setGray = color2[5] == "1"
						}
					})
				elseif color2[2] == _Events.AC_DEL_ITEM then
					_Events:dispatchEvent({
						name = _Events.AC_DEL_ITEM,
						data = {
							elmtName = color2[3],
							boxid = color2[4]
						}
					})
				elseif color2[2] == "sendData" then
					_Events:dispatchEvent({
						name = color2[3],
						data = color2[4]
					})
				elseif color2[2] == "转职" then
					_doRmdir(device.writablePath .. "cache/")
					net.send({
						CM_SOFTCLOSE
					})
					an.newMsgbox("你已成功转职\n需重新进入游戏，祝您游戏愉快！ ", function(value17)
						if value17 == 1 then
							os.exit(0)
						end
					end, {
						center = true,
						close = false
					})
				elseif color2[2] == "JSHSucess" then
					_Events:dispatchEvent({
						name = _Events.JSH_BUY_SUC,
						data = {
							typename = color2[3],
							idx = color2[4]
						}
					})
				elseif color2[2] == "JSHDown" then
					_Events:dispatchEvent({
						name = _Events.JSH_DOWN_SUC,
						data = {
							typename = color2[3],
							idx = color2[4]
						}
					})
				elseif color2[2] == "JSHQuest" then
					_Events:dispatchEvent({
						name = _Events.JSH_QUEST_SUC,
						data = {
							typename = color2[3],
							idx = color2[4]
						}
					})
				elseif color2[2] == "removeQuickView" then
					_Events:dispatchEvent({
						name = _Events.CLOSE_QUICKBUY,
						data = {
							name = color2[3]
						}
					})
				elseif color2[2] == "JSHRqeustGive" then
					_Events:dispatchEvent({
						name = _Events.JSH_REQ_GIVE_SUC,
						data = {
							idx = color2[3]
						}
					})
				elseif color2[2] == "JSHRqeustDown" then
					_Events:dispatchEvent({
						name = _Events.JSH_REQ_DOWN_SUC,
						data = {
							idx = color2[3]
						}
					})
				elseif color2[2] == "JSHDeleteItem" then
					_Events:dispatchEvent({
						name = _Events.JSH_DeleteItem,
						data = {
							makeIndex = tonumber(color2[3])
						}
					})
				elseif color2[2] == "JSHRqeustGet" then
					_Events:dispatchEvent({
						name = _Events.JSH_REQ_GET_SUC,
						data = {
							idx = color2[3]
						}
					})
				elseif color2[2] == "HHCRquestGet" then
					_Events:dispatchEvent({
						name = _Events.HHC_GET_SUC,
						data = {
							idx = color2[3]
						}
					})
				elseif color2[2] == "commitItem" then
					_Events:dispatchEvent({
						name = _Events.COMMIT_REQ,
						data = {
							npcName = color2[3],
							itemName = color2[4]
						}
					})
				elseif color2[2] == _Events.JSH_GO_PAGE then
					_Events:dispatchEvent({
						name = _Events.JSH_GO_PAGE,
						data = {}
					})
				elseif color2[2] == _Events.JSH_SELL then
					_Events:dispatchEvent({
						name = _Events.JSH_SELL,
						data = {
							makeIndex = tonumber(color2[3])
						}
					})
				elseif color2[2] == _Events.JSH_DOWN then
					_Events:dispatchEvent({
						name = _Events.JSH_DOWN,
						data = {}
					})
				elseif color2[2] == _Events.JSH_TIMEOUT_DOWN then
					_Events:dispatchEvent({
						name = _Events.JSH_TIMEOUT_DOWN,
						data = {}
					})
				elseif color2[2] == _Events.JSH_SAVING then
					_Events:dispatchEvent({
						name = _Events.JSH_SAVING,
						data = {}
					})
				elseif color2[2] == _Events.JSH_BUY then
					_Events:dispatchEvent({
						name = _Events.JSH_BUY,
						data = {}
					})
				elseif color2[2] == "commitThis" then
					if NEWITEM and NEWITEM.getVar("name") == color2[3] and main_scene.ui.panels.freedeal then
						main_scene.ui.panels.freedeal:commitByData(NEWITEM)
					end
				elseif color2[2] == "playsound" then
					func.playsound(color2[3], color2[4] == "1")
				elseif color2[2] == "music" then
					local value15 = string.trim(color2[3])
					local number12 = tonumber(color2[4]) == 1

					sound.playMusic(value15, number12)
				elseif color2[2] == "SetAttr" then
					if color2[3] then
						func.SetAttrPanel(color2[3], true)
					end
				elseif color2[2] == "SetAttrHero" then
					if color2[3] then
						func.SetAttrPanel(color2[3], false)
					end
				elseif color2[2] == "OpenPanel" then
					local value7 = color2[3]

					if value7 then
						local value16 = color2[4]

						main_scene.ui:togglePanel(value7, value16)
					end
				elseif color2[2] == "PanelCall" then
					if color2[3] then
						local value3 = main_scene.ui.panels[color2[3]]

						if value3 and color2[4] and value3[color2[4]] then
							value3[color2[4]](value3, color2[5])
						end
					end
				elseif color2[2] == "OpenVoice" then
					if color2[3] and color2[3] == "0" then
						g_data.player.cmAbil.OpenVoice = nil
					else
						g_data.player.cmAbil.OpenVoice = color2[3]
					end
				elseif color2[2] == "OpenCharge" then
					local function callback2(text2)
						text2 = string.gsub(text2, "([^%w%.%- ])", function(value18)
							return string.format("%%%02X", string.byte(value18))
						end)

						return string.gsub(text2, " ", "+")
					end

					local value = g_data.login.shopUrl

					if color2[3] then
						value = value .. "&ex=" .. callback2(color2[3])
					end

					if color2[4] then
						value = value .. "&money=" .. color2[4]
					end

					device.openURL(value)
				elseif color2[2] == "WXMAP" then
					local weatherNature = require("mir2.scenes.main.common.weatherNature")

					if weatherNature and weatherNature.setMapWeather then
						weatherNature.setMapWeather(color2[3], color2[4])
					end
				elseif color2[2] == "FAIRYBAN" then
					local magicParticle = require("mir2.scenes.main.common.magicParticle")

					if magicParticle and magicParticle.setFairyBan then
						magicParticle.setFairyBan(color2[3] or "")
					end
				elseif color2[2] == "FAIRYATK" then
					local magicParticle2 = require("mir2.scenes.main.common.magicParticle")

					if magicParticle2 and magicParticle2.triggerAttack and main_scene and main_scene.ground then
						local value8 = main_scene.ground.player

						if value8 then
							magicParticle2.triggerAttack(value8)
						end
					end
				end
			end

			return true
		elseif string.contans(self, "chargefinished") then
			return true
		elseif string.contans(self, "隐身模式") and string.contans(self, "开") then
			g_data.player.isGMUnlimitedMove = true
		elseif string.contans(self, "隐身模式") and string.contans(self, "关") then
			g_data.player.isGMUnlimitedMove = false
		elseif string.contans(self, "恭喜：你获得了：") and string.contans(self, "+") then
			main_scene.ui.common.addMsg(string.split(self, "+")[1], display.COLOR_WHITE, display.COLOR_BLUE)

			return true
		elseif string.contans(self, "学会技能") then
			main_scene.ui.common.addMsg("新技能学习成功！", display.COLOR_WHITE, display.COLOR_BLUE)

			return true
		elseif string.contans(self, "技能等级变更为") then
			main_scene.ui.common.addMsg("你的技能等级成功变化了！", display.COLOR_GREEN, display.COLOR_WHITE)

			return true
		elseif string.contans(self, "职业变更为") then
			main_scene.ui.common.addMsg("职业变更成功！", display.COLOR_GREEN, display.COLOR_WHITE)

			return true
		elseif string.contans(self, "修补成功。") and string.contans(self, "+") then
			local parts2 = string.split(self, "+")

			main_scene.ui.common.addMsg(parts2[1] .. "修补成功。", display.COLOR_GREEN, display.COLOR_WHITE)

			return true
		elseif string.contans(self, "切割触发") then
			return func.qieActive(self)
		elseif string.contans(self, "BZQG") then
			return func.qieSaveTypes(self)
		elseif string.contans(self, "PIAO") then
			return func.piaoActive(self)
		elseif string.contans(self, "BACKHOME") then
			main_scene.ui.common.backHome()

			return true
		elseif string.contans(self, "BZALERT") then
			return func.bzalert(self)
		elseif string.contans(self, "您被") and string.contans(self, "杀害了") then
			if main_scene.ground:smr() then
				return true
			end

			return false
		elseif string.contans(self, "触发暴击") then
			return func.bjActive(self)
		elseif string.contans(self, "BUFFME") then
			return func.buffme(self)
		elseif string.contans(self, "BUFF") then
			return func.buff(self)
		elseif string.contans(self, "RNPC") or string.contans(self, "CNPC") then
			return func.cnpc(self)
		elseif string.contans(self, "RPNL") or string.contans(self, "CDYP") then
			return func.cdyp(self)
		elseif string.contans(self, "PNL") or string.contans(self, "DYP") then
			return func.dyp(self)
		elseif string.contans(self, "NC") then
			return func.nc(self)
		elseif string.contans(self, "BOSS刷新") then
			return func.bossAlert(self)
		elseif string.contans(self, "REQPO") or string.contans(self, "EQPO") then
			return func.eqOther(self)
		elseif string.contans(self, "REQPC") then
			return func.eqOtherTab(self)
		elseif string.contans(self, "REQP") or string.contans(self, "EQP") then
			return func.eq(self)
		elseif string.contans(self, "REQC") then
			return func.eqTab(self)
		elseif string.contans(self, "BZTSK") then
			return func.bztask(self)
		elseif string.contans(self, "RMGP") or string.contans(self, "MGP") then
			return func.mapExtend(self)
		elseif string.contans(self, "RUDP") or string.contans(self, "UGP") then
			return func.consoleExtend(self)
		elseif string.contans(self, "RBGP") or string.contans(self, "BGP") then
			return func.bagExtend(self)
		elseif string.contans(self, "RMP") or string.contans(self, "MP") then
			return func.bigmapExtend(self)
		elseif string.contans(self, "RBTM") or string.contans(self, "BTM") then
			return func.bottomExtend(self)
		elseif string.contans(self, "RDPNL") or string.contans(self, "CDTP") then
			return func.cdtp(self)
		elseif string.contans(self, "DPNL") or string.contans(self, "DTP") then
			return func.dtp(self)
		elseif string.contans(self, "TP") then
			return func.togglePanel(self)
		elseif string.contans(self, "RELOADBAG") then
			return func.reloadBag(self)
		elseif string.contans(self, "LINK") then
			return func.openLink(self)
		elseif string.contans(self, "DELAYCALL") then
			return func.delayCall(self)
		elseif string.contans(self, "TIM") or string.contans(self, "TIMER") then
			return func.timer(self)
		elseif string.contans(self, "DARK") then
			return func.openDark(self)
		elseif string.contans(self, "STATUS") then
			return func.status(self)
		elseif string.contans(self, "AUTORAT") then
			return func.autoRat(self)
		elseif string.contans(self, "AUTOPICK") then
			return func.autopick(self)
		elseif string.contans(self, "GO") then
			return func.go(self)
		elseif string.contans(self, "TALK") then
			return func.talkWithNPC(self)
		elseif string.contans(self, "MIG") then
			return func.MIG(self)
		elseif string.contans(self, "NOTASK") then
			return func.taskMonOff(self)
		elseif string.contans(self, "TASK") then
			return func.taskMonOn(self)
		elseif string.contans(self, "USE") then
			return func.use(self)
		elseif string.contans(self, "FM") then
			return func.makeValuesActive(self)
		elseif string.contans(self, "MAPEFFECT") then
			return func.showEffectforName(self)
		elseif string.contans(self, "autorelive") then
			g_data.setting.base.relive = true

			return true
		elseif string.contans(self, "killedsomebody") then
			local value9 = main_scene.ui.console.controller.lock

			value9.killEffAni(value9)

			return true
		elseif string.contans(self, "initialization") then
			return func.initialization(self)
		elseif string.contans(self, "openfun") then
			def.role.mainsetting.funAoths = string.split(self, ":")

			return true
		elseif string.contans(self, "HIDEABIL") then
			return func.hideAbil(self)
		elseif string.contans(self, "cSkilPicRf") then
			return func.refershSkillIcon(self)
		elseif string.contans(self, "JPP") then
			return func.joinCorps(self)
		elseif string.contans(self, "IAMFLY") then
			return func.markFly(self)
		elseif string.contans(self, "行会战结束") then
			return func.warFinsh(self)
		elseif string.contans(self, "成功给予封号") then
			return true
		elseif string.contans(self, "成功清除封号") then
			return true
		elseif string.contans(self, "嗜血杀戮") then
			return true
		elseif g_data.setting.base.heroFollow and string.contans(self, "攻击目标") then
			return true
		elseif g_data.setting.base.goodsTip and string.contans(self, "时发现了") and string.contans(self, "击杀") then
			local value10, value11 = func.goodTips(self)

			if not value10 and def.dropItemTipCostom and def.dropItemTipCostom[value11] then
				local value12 = def.dropItemTipCostom[value11]

				main_scene.ui.common.addMsg(string.gsub(self, "时发现了", "时掉落了"), value12.fontColor or display.COLOR_WHITE, value12.bgColor or display.COLOR_RED)

				return true
			end

			return value10
		elseif string.contans(self, "REMOTECALL") then
			return func.remoteCall(self)
		elseif string.contans(self, "SETVITALITY") then
			return func.SetVitality(self)
		end
	end

	return false
end

function solta95(self, ...)
	return mm445(self, ...)
end

function func.isBanAttack()
	if g_data.player.cmAbil and g_data.player.cmAbil.banAttack then
		return true
	end

	return false
end

function func:fixRun()
	if g_data.player.cmAbil and g_data.player.cmAbil.fixRun then
		return 1
	end

	return self
end
