local net = import("mir2.single.net")

return {
	fuc = function(value, value3, text, number)
		local value2
		local value4

		if not value3 then
			return value, value3, text, number, value2, value4
		end

		local value5 = value3.ident

		if value5 == SM_STRUCK and number > 32 then
			local text2 = string.sub(text, 33)
			local text3 = net.str(text2)
			local parts = string.split(text3, ":")

			if #parts >= 2 and parts[1] == "|newhp" then
				number = 32

				local series = tonumber(parts[2])

				if series then
					value3.series = series
				end
			end
		end

		if value5 == 1314 then
			if value3.param == 0 then
				value2 = net.str(text)
			else
				value4 = net.str(text)
			end
		end

		return value, value3, text, number, value2, value4
	end
}
