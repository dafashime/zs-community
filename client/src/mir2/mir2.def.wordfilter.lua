local wordfilter = {}
local configs = {}

scheduler.performWithDelayGlobal(function ()
	local file = res.getfile("config/wordfilter.txt")
	local datas = string.split(file, "\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local function fill(group, words, idx)
				if idx > #words then
					group[1] = true

					return
				end

				local word = words[idx]
				local subGroup = group[word]

				if not subGroup then
					subGroup = {}
					group[word] = subGroup
				end

				fill(subGroup, words, idx + 1)
			end

			fill(configs, utf8strs(string.trim(v)), 1)
		end
	end
end, 0)

function wordfilter.run(text, replaceWrod)
	if not text or text == "" then
		return text
	end

	text = utf8strs(text)

	local function check(group, i, plies, cnt)
		if group[1] then
			cnt = plies
		end

		if i > #text then
			return cnt
		end

		local subGroup = group[text[i]]

		if not subGroup then
			return cnt
		end

		return check(subGroup, i + 1, plies + 1, cnt)
	end

	local i = 1

	while true do
		local cnt = check(configs, i, 0, 0)

		if cnt > 0 then
			for j = i, i + cnt - 1 do
				text[j] = replaceWrod or "*"
			end

			i = i + cnt
		else
			i = i + 1
		end

		if i > #text then
			break
		end
	end

	return table.concat(text)
end

function wordfilter.check(text)
	if not text or text == "" then
		return true
	end

	text = utf8strs(text)

	local function check(group, i, plies, cnt)
		if group[1] then
			cnt = plies
		end

		if i > #text then
			return cnt
		end

		local subGroup = group[text[i]]

		if not subGroup then
			return cnt
		end

		return check(subGroup, i + 1, plies + 1, cnt)
	end

	local i = 1

	while true do
		if check(configs, i, 0, 0) > 0 then
			return
		end

		i = i + 1

		if i > #text then
			break
		end
	end

	return true
end

return wordfilter
