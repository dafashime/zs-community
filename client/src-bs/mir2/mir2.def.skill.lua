local skill = {}

scheduler.performWithDelayGlobal(function ()
	local file = res.getfile("config/skilldesc.txt")
	local datas = string.split(file, "\r\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, ";")

			if data[2] ~= "" then
				skill[data[2]] = data
			end

			if data[3] ~= "" then
				skill[data[3]] = data
			end
		end
	end
end, 0)

return skill
