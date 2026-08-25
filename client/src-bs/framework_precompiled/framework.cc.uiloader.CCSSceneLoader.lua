local CCSUILoader = import(".CCSUILoader")
local CCSSceneLoader = class("CCSSceneLoader")

function CCSSceneLoader:load(json, params)
	self.params_ = params
	local node = self:createGameObject(json)
	var_4 = json.CanvasSize._width
	var_5 = json.CanvasSize._height
	self.params_ = nil

	return node
end

function CCSSceneLoader:createGameObject(jsonNode)
	local node = display.newNode()
	node.name = jsonNode.name or "no name"

	node:setRotation(jsonNode.rotation or 0)
	node:setScaleX(jsonNode.scalex or 1)
	node:setScaleY(jsonNode.scaley or 1)

	if not jsonNode.visible or jsonNode.visible == 0 then
		node:setVisible(false)
	else
		node:setVisible(true)
	end

	node:setLocalZOrder(jsonNode.zorder or 0)
	node:setTag(jsonNode.objecttag or 0)
	node:setPosition(jsonNode.x, jsonNode.y)

	if jsonNode.components then
		for i, v in ipairs(jsonNode.components) do
			self:addComponent(node, v, i)
		end
	end

	if jsonNode.gameobjects then
		local subNode = nil

		for i, v in ipairs(jsonNode.gameobjects) do
			subNode = self:createGameObject(v)

			if subNode then
				node:addChild(subNode)
			end
		end
	end

	return node
end

function CCSSceneLoader:addComponent(gameObject, component, idx)
	local node = nil

	if component.fileData then
		self:loadTexture(component.fileData.plistFile)
	end

	if component.classname == "CCScene" then
		node = self:createScene(component)
	elseif component.classname == "CCSprite" then
		node = self:createSprite(component)
	elseif component.classname == "CCArmature" then
		node = self:createArmature(component)
	elseif component.classname == "GUIComponent" then
		node = self:createGUIComponent(component)
	elseif component.classname == "CCParticleSystemQuad" then
		node = self:createParticleSystem(component)
	else
		print("CCSSceneLoader - not support classname:" .. component.classname)
	end

	if node then
		node.name = "Component" .. idx

		gameObject:addChild(node)
	end

	return gameObject
end

function CCSSceneLoader:createScene(comp)
	local scene = cc.Scene:create()

	return scene
end

function CCSSceneLoader:createBackgroundAudio(comp)
end

function CCSSceneLoader:createSprite(comp)
	local name = nil

	if self:isNil(comp.fileData.plistFile) then
		name = comp.fileData.path
	else
		name = "#" .. comp.fileData.path
	end

	local sp = display.newSprite(name)

	return sp
end

function CCSSceneLoader:createArmature(comp)
	local manager = ccs.ArmatureDataManager:getInstance()

	manager:addArmatureFileInfo(comp.fileData.path)

	local armature = ccs.Armature:create(io.pathinfo(comp.fileData.path).basename)

	return armature
end

function CCSSceneLoader:createGUIComponent(comp)
	local ui = CCSUILoader:loadFile(comp.fileData.path, self.params_)

	return ui
end

function CCSSceneLoader:createParticleSystem(comp)
	local particleSys = cc.ParticleSystemQuad:create(comp.fileData.path)

	particleSys:setPosition(0, 0)

	return particleSys
end

function CCSSceneLoader:loadTexture(plist, png)
	if not plist or string.utf8len(plist) == 0 then
		return
	end

	local spCache = cc.SpriteFrameCache:getInstance()

	if png then
		spCache:addSpriteFrames(plist, png)
	else
		spCache:addSpriteFrames(plist)
	end
end

function CCSSceneLoader:isNil(str)
	if not str or string.utf8len(str) == 0 then
		return true
	else
		return false
	end
end

return CCSSceneLoader
