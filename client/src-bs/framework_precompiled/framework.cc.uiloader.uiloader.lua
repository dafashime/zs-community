local UILoaderUtilitys = import(".UILoaderUtilitys")
local uiloader = class("uiloader")
local CCSUILoader = import(".CCSUILoader")
local CCSUILoader2 = import(".CCSUILoader2")
local CCSSceneLoader = import(".CCSSceneLoader")

function uiloader:ctor()
end

function uiloader:load(jsonFile, params)
	local json = nil

	if not params or not params.bJsonStruct then
		local pathInfo = io.pathinfo(jsonFile)

		if pathInfo.extname == ".csb" then
			return cc.CSLoader:getInstance():createNodeWithFlatBuffersFile(jsonFile)
		else
			json = self:loadFile_(jsonFile)
		end
	else
		json = jsonFile
	end

	if not json then
		print("uiloader - load file fail:" .. jsonFile)

		return
	end

	local node = nil

	if self:isScene_(json) then
		node, w, h = CCSSceneLoader:load(json, params)
	else
		local l = self:getCompileUILoader(json, params)

		if l then
			node, w, h = l.new():load(json, params)
		end
	end

	UILoaderUtilitys.clearPath()

	return node, w, h
end

function uiloader:seekNodeByTag(parent, tag)
	if not parent then
		return
	end

	if tag == parent:getTag() then
		return parent
	end

	local findNode = nil
	local children = parent:getChildren()
	local childCount = parent:getChildrenCount()

	if childCount < 1 then
		return
	end

	for i = 1, childCount do
		if type(children) == "table" then
			parent = children[i]
		elseif type(children) == "userdata" then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			findNode = self:seekNodeByTag(parent, tag)

			if findNode then
				return findNode
			end
		end
	end
end

function uiloader:seekNodeByName(parent, name)
	if not parent then
		return
	end

	if name == parent.name then
		return parent
	end

	local findNode = nil
	local children = parent:getChildren()
	local childCount = parent:getChildrenCount()

	if childCount < 1 then
		return
	end

	for i = 1, childCount do
		if type(children) == "table" then
			parent = children[i]
		elseif type(children) == "userdata" then
			parent = children:objectAtIndex(i - 1)
		end

		if parent and name == parent.name then
			return parent
		end
	end

	for i = 1, childCount do
		if type(children) == "table" then
			parent = children[i]
		elseif type(children) == "userdata" then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			findNode = self:seekNodeByName(parent, name)

			if findNode then
				return findNode
			end
		end
	end
end

function uiloader:seekNodeByNameFast(parent, name)
	if not parent then
		return
	end

	if not parent.subChildren then
		return
	end

	if name == parent.name then
		return parent
	end

	local findNode = parent.subChildren[name]

	if findNode then
		return findNode
	end

	for i, v in ipairs(parent.subChildren) do
		findNode = self:seekNodeByName(v, name)

		if findNode then
			return findNode
		end
	end
end

function uiloader:seekNodeByPath(parent, path)
	if not parent then
		return
	end

	local names = string.split(path, "/")

	for i, v in ipairs(names) do
		parent = self:seekNodeByNameFast(parent, v)

		if not parent then
			return
		end
	end

	return parent
end

function uiloader:seekComponents(parent, nodeName, componentIdx)
	local node = self:seekNodeByName(parent, nodeName)

	if not node then
		return
	end

	node = self:seekNodeByName(node, "Component" .. componentIdx)

	return node
end

function uiloader:loadFile_(jsonFile)
	local fileUtil = cc.FileUtils:getInstance()
	local fullPath = fileUtil:fullPathForFilename(jsonFile)
	local pathinfo = io.pathinfo(fullPath)

	UILoaderUtilitys.addSearchPathIf(pathinfo.dirname)

	local jsonStr = fileUtil:getStringFromFile(fullPath)
	local jsonVal = json.decode(jsonStr)

	return jsonVal
end

function uiloader:isScene_(json)
	if json.components then
		return true
	else
		return false
	end
end

function uiloader:getCompileUILoader(json)
	local ver = json.Version or json.version
	local vers = string.split(ver, ".")
	local mainVer = tonumber(vers[1])

	if not mainVer then
		printError("can't found version")

		return
	end

	if mainVer > 1 then
		return CCSUILoader2
	else
		return CCSUILoader
	end
end

return uiloader
