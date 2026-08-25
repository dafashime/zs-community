local skilldesc = {}

scheduler.performWithDelayGlobal(function()
	local file = res.getfile("config/skilldesc.txt")
	local datas = string.split(file, "\r\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, ",")

			skilldesc[data[2]] = data
		end
	end
end, 0)

return skilldesc
