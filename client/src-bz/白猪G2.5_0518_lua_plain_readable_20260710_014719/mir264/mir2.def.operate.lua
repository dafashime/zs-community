local operate = {}

function operate.getConfig(key)
	if not operate[key] then
		operate[key] = parseJson("config/" .. key .. ".json")
	end

	return operate[key]
end

function operate.init()
	operate.hotKey = def.operate.getConfig("hotKey")
	operate.hotKeySet = def.operate.getConfig("hotKeySet")
end

return operate
