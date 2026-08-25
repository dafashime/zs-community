local p = cc.PACKAGE_NAME .. ".cocos2dx."

if not cc.p then
	require(p .. "Cocos2dConstants")
	require(p .. "OpenglConstants")
	require(p .. "Cocos2d")
	require(p .. "StudioConstants")
end

require(p .. "Event")
require(p .. "ActionEx")
require(p .. "NodeEx")
require(p .. "SceneEx")
require(p .. "SpriteEx")
require(p .. "DrawNodeEx")
