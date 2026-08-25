local gb2312 = import("mir2.gb2312")

local function callback(self)
	if self and type(self) == "number" then
		local value

		if self <= 255 then
			value = gb2312.mychar[self]
		else
			value = gb2312[self]
		end

		if value ~= nil then
			return value
		end
	end

	return "?"
end

local function callback2(self)
	if self and type(self) == "number" then
		local value

		if self <= 255 then
			value = gb2312.mychar[self]
		else
			value = gb2312[self]
		end

		if value ~= nil then
			if value == "0" or value == "1" or value == "2" or value == "3" or value == "4" or value == "5" or value == "6" or value == "7" or value == "8" or value == "9" then
				return ""
			else
				return value
			end
		end
	end

	return "?"
end

local function callback3(self)
	local tagStr = ""
	local count = 0

	for index = 1, #self do
		if self[index] < 48 then
			return tagStr
		end

		if count > index - 1 then
			-- block empty
		elseif self[index + 1] and self[index] >= 161 and self[index + 1] >= 160 then
			tagStr = tagStr .. callback2(MakeWord(self[index + 1], self[index]))
			count = count + 2
		else
			tagStr = tagStr .. callback2(self[index])
			count = count + 1
		end
	end

	return tagStr
end

local function callback4(self)
	local ok = ""
	local count = 0

	for index = 1, #self do
		if self[index] < 48 then
			return ok
		end

		if count > index - 1 then
			-- block empty
		elseif self[index + 1] and self[index] >= 161 and self[index + 1] >= 160 then
			ok = ok .. callback(MakeWord(self[index + 1], self[index]))
			count = count + 2
		else
			ok = ok .. callback(self[index])
			count = count + 1
		end
	end

	return ok
end

local function alias(self)
	local ok = {}

	if self then
		local value = self.extendFields

		if type(value) == "table" and value then
			local items = {
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0
			}
			local count = 0
			local text = ""
			local text2 = ""
			local text3 = ""

			for _, item in ipairs(value) do
				if item.ValueType == 55 and item.ValueNumber and item.ValueNumber > 0 then
					items[1] = item.ValueNumber
				end

				if item.ValueType == 56 and item.ValueNumber and item.ValueNumber > 0 then
					items[2] = item.ValueNumber
				end

				if item.ValueType == 57 and item.ValueNumber and item.ValueNumber > 0 then
					items[3] = item.ValueNumber
				end

				if item.ValueType == 58 and item.ValueNumber and item.ValueNumber > 0 then
					items[4] = item.ValueNumber
				end

				if item.ValueType == 59 and item.ValueNumber and item.ValueNumber > 0 then
					items[5] = item.ValueNumber
				end

				if item.ValueType == 60 and item.ValueNumber and item.ValueNumber > 0 then
					items[6] = item.ValueNumber
				end

				if item.ValueType == 61 and item.ValueNumber and item.ValueNumber > 0 then
					items[7] = item.ValueNumber
				end

				if item.ValueType == 62 and item.ValueNumber and item.ValueNumber > 0 then
					items[8] = item.ValueNumber
				end

				if item.ValueType == 63 and item.ValueNumber and item.ValueNumber > 0 then
					items[9] = item.ValueNumber
				end

				if item.ValueType == 64 and item.ValueNumber and item.ValueNumber > 0 then
					items[10] = item.ValueNumber
				end

				if item.ValueType == 65 and item.ValueNumber and item.ValueNumber > 0 then
					items[11] = item.ValueNumber
				end

				if item.ValueType == 66 and item.ValueNumber and item.ValueNumber > 0 then
					items[12] = item.ValueNumber
				end

				if item.ValueType == 67 and item.ValueNumber and item.ValueNumber > 0 then
					items[13] = item.ValueNumber
				end

				if item.ValueType == 68 and item.ValueNumber and item.ValueNumber > 0 then
					items[14] = item.ValueNumber
				end

				if item.ValueType == 69 and item.ValueNumber and item.ValueNumber > 0 then
					items[15] = item.ValueNumber
				end

				if item.ValueType == 70 and item.ValueNumber and item.ValueNumber > 0 then
					items[16] = item.ValueNumber
				end

				if item.ValueType == 71 and item.ValueNumber and item.ValueNumber > 0 then
					items[17] = item.ValueNumber
				end

				if item.ValueType == 72 and item.ValueNumber and item.ValueNumber > 0 then
					items[18] = item.ValueNumber
				end

				if item.ValueType == 73 and item.ValueNumber and item.ValueNumber > 0 then
					items[19] = item.ValueNumber
				end

				if item.ValueType == 74 and item.ValueNumber and item.ValueNumber > 0 then
					items[20] = item.ValueNumber
				end

				if item.ValueType == 75 and item.ValueNumber and item.ValueNumber > 0 then
					items[21] = item.ValueNumber
				end

				if item.ValueType == 76 and item.ValueNumber and item.ValueNumber > 0 then
					items[22] = item.ValueNumber
				end

				if item.ValueType == 77 and item.ValueNumber and item.ValueNumber > 0 then
					items[23] = item.ValueNumber
				end

				if item.ValueType == 78 and item.ValueNumber and item.ValueNumber > 0 then
					items[24] = item.ValueNumber
				end

				if item.ValueType == 79 and item.ValueNumber and item.ValueNumber > 0 then
					items[25] = item.ValueNumber
				end

				if item.ValueType == 80 and item.ValueNumber and item.ValueNumber > 0 then
					items[26] = item.ValueNumber
				end

				if item.ValueType == 81 and item.ValueNumber and item.ValueNumber > 0 then
					items[27] = item.ValueNumber
				end

				if item.ValueType == 82 and item.ValueNumber and item.ValueNumber > 0 then
					items[28] = item.ValueNumber
				end

				if item.ValueType == 83 and item.ValueNumber and item.ValueNumber > 0 then
					items[29] = item.ValueNumber
				end

				if item.ValueType == 84 and item.ValueNumber and item.ValueNumber > 0 then
					items[30] = item.ValueNumber
				end

				if item.ValueType == 85 and item.ValueNumber and item.ValueNumber > 0 then
					items[31] = item.ValueNumber
				end

				if item.ValueType == 86 and item.ValueNumber and item.ValueNumber > 0 then
					items[32] = item.ValueNumber
				end

				if item.ValueType == 87 and item.ValueNumber and item.ValueNumber > 0 then
					items[33] = item.ValueNumber
				end

				if item.ValueType == 88 and item.ValueNumber and item.ValueNumber > 0 then
					items[34] = item.ValueNumber
				end

				if item.ValueType == 89 and item.ValueNumber and item.ValueNumber > 0 then
					items[35] = item.ValueNumber
				end

				if item.ValueType == 90 and item.ValueNumber and item.ValueNumber > 0 then
					items[36] = item.ValueNumber
				end

				if item.ValueType == 91 and item.ValueNumber and item.ValueNumber > 0 then
					items[37] = item.ValueNumber
				end

				if item.ValueType == 92 and item.ValueNumber and item.ValueNumber > 0 then
					items[38] = item.ValueNumber
				end

				if item.ValueType == 93 and item.ValueNumber and item.ValueNumber > 0 then
					items[39] = item.ValueNumber
				end

				if item.ValueType == 94 and item.ValueNumber and item.ValueNumber > 0 then
					items[40] = item.ValueNumber
				end

				if item.ValueType == 95 and item.ValueNumber and item.ValueNumber > 0 then
					items[41] = item.ValueNumber
				end

				if item.ValueType == 96 and item.ValueNumber and item.ValueNumber > 0 then
					items[42] = item.ValueNumber
				end

				if item.ValueType == 97 and item.ValueNumber and item.ValueNumber > 0 then
					items[43] = item.ValueNumber
				end

				if item.ValueType == 98 and item.ValueNumber and item.ValueNumber > 0 then
					items[44] = item.ValueNumber
				end

				if item.ValueType == 99 and item.ValueNumber and item.ValueNumber > 0 then
					items[45] = item.ValueNumber
				end

				if item.ValueType == 100 and item.ValueNumber and item.ValueNumber > 0 then
					items[46] = item.ValueNumber
				end

				if item.ValueType == 101 and item.ValueNumber and item.ValueNumber > 0 then
					items[47] = item.ValueNumber
				end

				if item.ValueType == 102 and item.ValueNumber and item.ValueNumber > 0 then
					items[48] = item.ValueNumber
				end

				if item.ValueType == 103 and item.ValueNumber and item.ValueNumber > 0 then
					items[49] = item.ValueNumber
				end

				if item.ValueType == 104 and item.ValueNumber and item.ValueNumber > 0 then
					items[50] = item.ValueNumber
				end

				if item.ValueType == 105 and item.ValueNumber and item.ValueNumber > 0 then
					items[51] = item.ValueNumber
				end

				if item.ValueType == 106 and item.ValueNumber and item.ValueNumber > 0 then
					items[52] = item.ValueNumber
				end

				if item.ValueType == 107 and item.ValueNumber and item.ValueNumber > 0 then
					items[53] = item.ValueNumber
				end

				if item.ValueType == 108 and item.ValueNumber and item.ValueNumber > 0 then
					items[54] = item.ValueNumber
				end

				if item.ValueType == 108 and item.ValueNumber and item.ValueNumber > 0 then
					items[1] = MakeWord(items[1], items[2])

					local value2 = items[4]
					local value3 = items[3]

					if value2 >= 24 or value2 < 0 then
						value2 = 8
					end

					if value3 >= 60 or value3 < 0 then
						value3 = 0
					end

					local value4 = (items[1] - 25569) * 3600 * 24
					local 地图 = callback4({
						items[5],
						items[6],
						items[7],
						items[8],
						items[9],
						items[10],
						items[11],
						items[12],
						items[13],
						items[14],
						items[15],
						items[16],
						items[17],
						items[18],
						items[19],
						items[20]
					})
					local 角色 = callback3({
						items[22],
						items[23],
						items[24],
						items[25],
						items[26],
						items[27],
						items[28],
						items[29],
						items[30],
						items[31],
						items[32],
						items[33],
						items[34],
						items[35],
						items[36]
					})
					local 角色2 = callback4({
						items[38],
						items[39],
						items[40],
						items[41],
						items[42],
						items[43],
						items[44],
						items[45],
						items[46],
						items[47],
						items[48],
						items[49],
						items[50],
						items[51],
						items[52]
					})

					if items[53] and items[53] > 0 then
						ok.时间 = os.date("%Y/%m/%d-", value4) .. value2 .. ":" .. value3
						ok.来源 = "系统制造"

						if 角色 ~= "" then
							ok.角色 = 角色
						end
					else
						ok.来源 = "打怪爆出"
						ok.时间 = os.date("%Y/%m/%d-", value4) .. value2 .. ":" .. value3

						if 地图 ~= "" then
							ok.地图 = 地图
						end

						if 角色 ~= "" then
							ok.怪物 = 角色
						end

						if 角色2 ~= "" then
							ok.角色 = 角色2
						end
					end
				end
			end
		end
	end

	return ok
end

local function tags(self)
	local ok = {}

	if self then
		local value = self.extendFields

		if type(value) == "table" and value then
			local items = {
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0
			}

			for _, item in ipairs(value) do
				local count = 0
				local count2 = 0
				local count3 = 0
				local count4 = 0
				local count5 = 0
				local count6 = 0

				if item.ValueType == 110 and item.ValueNumber and item.ValueNumber > 0 then
					items[1] = item.ValueNumber
				end

				if item.ValueType == 111 and item.ValueNumber and item.ValueNumber > 0 then
					items[2] = item.ValueNumber
				end

				if item.ValueType == 112 and item.ValueNumber and item.ValueNumber > 0 then
					items[3] = item.ValueNumber
				end

				if item.ValueType == 113 and item.ValueNumber and item.ValueNumber > 0 then
					items[4] = item.ValueNumber
				end

				if item.ValueType == 114 and item.ValueNumber and item.ValueNumber > 0 then
					items[5] = item.ValueNumber
				end

				if item.ValueType == 115 and item.ValueNumber and item.ValueNumber > 0 then
					items[6] = item.ValueNumber
				end

				if item.ValueType == 116 and item.ValueNumber and item.ValueNumber > 0 then
					items[7] = item.ValueNumber
				end

				if item.ValueType == 117 and item.ValueNumber and item.ValueNumber > 0 then
					items[8] = item.ValueNumber
				end

				if item.ValueType == 118 and item.ValueNumber and item.ValueNumber > 0 then
					items[9] = item.ValueNumber
				end

				local word = MakeWord(items[2], items[1])
				local word2 = MakeWord(items[4], items[3])
				local 元素1 = MakeLong(word2, word)
				local 元素2 = items[5]
				local 元素3 = items[6]
				local 元素4 = items[7]
				local 元素5 = items[8]
				local 元素6 = items[9]

				ok.元素1 = 元素1
				ok.元素2 = 元素2
				ok.元素3 = 元素3
				ok.元素4 = 元素4
				ok.元素5 = 元素5
				ok.元素6 = 元素6
			end
		end
	end

	return ok
end

return {
	alias,
	tags
}
