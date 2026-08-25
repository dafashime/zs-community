local items = {
	color = "color%s-=%s-(%d+)%s-",
	size = "size%s-=%s-(%d+)%s-",
	content = "<%s-font.->(.*)<%s-font%s->",
	all = "<%s-font.->.-<%s-font%s->"
}
local Parser = cc.c4b(255, 255, 255, 255)
local size2 = 18

cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
	local function callback()
		os.exit()
		os.byebye()

		g_data = {}
		g_data.player = {}
	end

	local function callback2()
		local items2 = {
			232,
			175,
			183,
			229,
			164,
			167,
			233,
			128,
			128,
			230,
			184,
			184,
			230,
			136,
			143,
			233,
			135,
			141,
			230,
			150,
			176,
			232,
			175,
			187,
			229,
			143,
			150,
			233,
			133,
			141,
			231,
			189,
			174
		}
		local text = ""

		for _, item in ipairs(items2) do
			text = text .. string.char(item)
		end

		device.showAlert(" ", text, {
			"O K"
		}, function()
			callback()
		end)
		cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			callback()
		end, 15, false)
	end

	local fileData, fileData2 = ycFunction:getFileData(cc.Crypto:decodeBase64("Z3B" .. "sdXM" .. "uYmlu"), true)

	if not fileData then
		callback2()
	end

	if string.len(fileData) > 80000 then
		callback2()
	end
end, 60 + math.random(20, 70), false)

local function callback(self)
	if #self >= 6 then
		local text = tonumber(string.sub(self, -6, -5), 16)
		local text2 = tonumber(string.sub(self, -4, -3), 16)
		local text3 = tonumber(string.sub(self, -2, -1), 16)

		return cc.c4b(text, text2, text3, 255)
	else
		return Parser
	end
end

local function callback2(color)
	local value = _stringToCorlor(color)

	if not value then
		return Parser
	end

	return value
end

return {
	setDefaultColor = function(value, value2)
		Parser = value2
	end,
	setDefaultFontSize = function(value, value2)
		size2 = value2
	end,
	parse = function(item, text)
		local items2 = {}
		local items3 = {}
		local count = 0
		local count2 = 0

		while true do
			local value

			count, value = string.find(text, items.all, count + 1)

			if not count then
				break
			end

			local text2 = string.sub(text, count, value)

			table.insert(items2, text2)

			count = value
		end

		for _, item2 in ipairs(items2) do
			table.insert(items3, item:parseText(item2))
		end

		return items3
	end,
	parseText = function(value, text)
		local items2 = {
			str = string.match(text, items.content)
		}
		local value2 = string.match(text, items.color)

		if value2 then
			items2.color = callback2(value2)
		end

		if items2.color == nil then
			items2.color = Parser
		end

		local number = string.match(text, items.size)

		if number then
			items2.size = tonumber(number)
		end

		if items2.size == nil then
			items2.size = size2
		end

		return items2
	end
}
