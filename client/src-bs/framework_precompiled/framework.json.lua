local json = {}
local cjson = nil

local function safeLoad()
	cjson = require("cjson")
end

if not pcall(safeLoad) then
	cjson = nil
end

function json.encode_sparse_array(cfg, radio, safe)
	cjson.encode_sparse_array(cfg, radio, safe)
end

function json.encode(var)
	local status, result = pcall(cjson.encode, var)

	if status then
		return result
	end

	if DEBUG > 1 then
		printError("json.encode() - encoding failed: %s", tostring(result))
	end
end

function json.decode(text)
	local status, result = pcall(cjson.decode, text)

	if status then
		return result
	end

	if DEBUG > 1 then
		printError("json.decode() - decoding failed: %s", tostring(result))
	end
end

if cjson then
	json.null = cjson.null
else
	json = nil
end

return json
