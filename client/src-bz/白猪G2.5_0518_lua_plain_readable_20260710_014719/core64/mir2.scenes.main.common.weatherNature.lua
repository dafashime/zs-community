local weatherSnow = require("mir2.scenes.main.common.weatherSnow")
local weatherNature = {}
local items3 = {}

local function callback(self, value3)
	if items3[self] then
		return
	end

	items3[self] = true

	print("[weatherNature] " .. value3)
end

local items2 = {}

function weatherNature:setMapWeather(mapWeather)
	if not self then
		return
	end

	local text = tostring(self)

	if not mapWeather or mapWeather == "" or mapWeather == "clear" then
		items2[text] = nil
	else
		items2[text] = mapWeather
	end

	weatherNature.syncCurrentMap()
end

local items4 = {
	high = 1,
	medium = 0.65,
	low = 0.35
}

local function callback2()
	local value3 = def.weatherQuality or "high"

	return items4[value3] or items4.high
end

local function callback3(self)
	return math.max(6, math.floor(self * callback2()))
end

local function callback4(self)
	return math.max(1, math.floor(self * callback2()))
end

local weatherNature2
local weatherNature3

local function callback5()
	if weatherNature2 then
		return weatherNature2
	end

	local value3, p_COwner = pcall(require, "mir2.scenes.main.map.map")

	weatherNature2 = value3 and p_COwner and p_COwner.__P_C or {}

	return weatherNature2
end

local function callback6()
	if weatherNature3 then
		return weatherNature3
	end

	local value3, p_DOwner = pcall(require, "mir2.scenes.main.ground")

	weatherNature3 = value3 and p_DOwner and p_DOwner.__P_D or {}

	return weatherNature3
end

local function callback7(self)
	local items5 = {}

	for itemId, item in pairs(self) do
		items5[itemId] = item
	end

	return items5
end

local weatherNature4

local function callback8()
	if weatherNature4 then
		return weatherNature4
	end

	local value3 = callback5()
	local value4 = callback6()
	local items5 = {}

	for itemId, item in pairs(value3) do
		items5[itemId] = type(item) == "table" and callback7(item) or item
	end

	for itemId2, item2 in pairs(value4) do
		items5[itemId2] = type(item2) == "table" and callback7(item2) or item2
	end

	weatherNature4 = items5

	return items5
end

local value = setmetatable({}, {
	__index = function(value3, value4)
		return callback8()[value4]
	end,
	__pairs = function(value3)
		return pairs(callback8())
	end
})

weatherNature._phase = nil
weatherNature._sched = nil
weatherNature._transition = nil
weatherNature._lightningState = nil
weatherNature._rainbowState = nil
weatherNature._prevKind = nil
weatherNature._darkModifier = 0

local function callback9()
	if socket and socket.gettime then
		return socket.gettime()
	end

	return os.time()
end

local function callback10()
	local number3 = {}

	for itemId, item in pairs(callback8()) do
		number3[itemId] = item
	end

	local typeWeightsOwner = def.natureWeather

	if type(typeWeightsOwner) == "table" then
		for itemId2, item2 in pairs(typeWeightsOwner) do
			if itemId2 ~= "typeWeights" then
				number3[itemId2] = item2
			end
		end

		if type(typeWeightsOwner.typeWeights) == "table" then
			number3.typeWeights = {}

			for key, typeWeight in pairs(value.typeWeights) do
				number3.typeWeights[key] = typeWeight
			end

			for key2, typeWeight2 in pairs(typeWeightsOwner.typeWeights) do
				number3.typeWeights[key2] = typeWeight2
			end
		end
	end

	if number3.testMode then
		local phaseMinDurationSec = tonumber(number3.testPhaseSec) or 60

		if phaseMinDurationSec < 5 then
			phaseMinDurationSec = 5
		end

		number3.phaseMinDurationSec = phaseMinDurationSec
		number3.phaseMaxDurationSec = phaseMinDurationSec

		if number3.testVerbose == nil then
			number3.testVerbose = true
		end
	end

	return number3
end

function weatherNature:shouldShowOnMap()
	if not self then
		return false
	end

	local callback = self.__q7vis or self.class and self.class.__q7vis

	if type(callback) == "function" then
		return callback(self)
	end

	return true
end

local function callback11()
	local items5 = {}
	local items6 = {
		"naturalWindEnabled",
		"naturalWindMinDurationSec",
		"naturalWindMaxDurationSec",
		"naturalWindStrengthMin",
		"naturalWindStrengthMax"
	}
	local value3 = def.weatherSnow
	local value4 = def.natureWeather

	for _, item in ipairs(items6) do
		if type(value3) == "table" and value3[item] ~= nil then
			items5[item] = value3[item]
		end
	end

	if type(value4) == "table" then
		for _2, item2 in ipairs(items6) do
			if value4[item2] ~= nil then
				items5[item2] = value4[item2]
			end
		end
	end

	items5.naturalWindEnabled = items5.naturalWindEnabled ~= false

	return items5
end

local function callback12(self)
	if not main_scene or not self or tolua.isnull(main_scene) or tolua.isnull(self) then
		return 0, 0
	end

	local point = cc.p(display.cx, display.cy)
	local value3 = main_scene:convertToWorldSpace(point)
	local point2 = self:convertToNodeSpace(value3)

	return point2.x, point2.y
end

local function callback13()
	if not main_scene or tolua.isnull(main_scene) then
		return 0, 0
	end

	local value3 = main_scene.ground

	if not value3 or tolua.isnull(value3) then
		return 0, 0
	end

	local point = cc.p(display.cx, display.cy)
	local value4 = main_scene:convertToWorldSpace(point)
	local point2 = value3:convertToNodeSpace(value4)

	return point2.x, point2.y
end

if not cc or not cc.POSITION_TYPE_RELATIVE then
	local count = 1
end

local value2 = cc and cc.POSITION_TYPE_GROUPED or 2

local function callback14(self, node)
	if not node or tolua.isnull(node) or not self then
		return
	end

	local value3, value4 = callback12(self)

	node:setPosition(math.floor(value3 + 0.5), math.floor(value4 + 0.5))
end

local function callback15(self, x, y)
	if not main_scene or not self or tolua.isnull(main_scene) or tolua.isnull(self) then
		return 0, 0
	end

	local point = cc.p(x, y)
	local value3 = main_scene:convertToWorldSpace(point)
	local point2 = self:convertToNodeSpace(value3)

	return point2.x, point2.y
end

local function callback16(self, node, value5, value6)
	if not node or tolua.isnull(node) or not self then
		return
	end

	local value3, value4 = callback15(self, value5, value6)

	node:setPosition(math.floor(value3 + 0.5), math.floor(value4 + 0.5))
end

local number = 1.5

local function callback17(self, node)
	if not node or tolua.isnull(node) or not self or tolua.isnull(self) then
		return false
	end

	local value3, value4 = callback12(self)
	local position, position2 = node:getPosition()
	local value5 = value3 - position
	local value6 = value4 - position2
	local value7 = (display.width or 960) * number

	return value5 * value5 + value6 * value6 > value7 * value7
end

local function callback18(self)
	local value3 = self.typeWeights or value.typeWeights
	local items5

	if type(self.enabledTypes) == "table" and #self.enabledTypes > 0 then
		items5 = {}

		for _, enabledType in ipairs(self.enabledTypes) do
			items5[enabledType] = true
		end
	end

	local count2 = 0

	for itemId, item in pairs(value3) do
		if type(item) == "number" and item > 0 and (not items5 or items5[itemId]) then
			count2 = count2 + item
		end
	end

	if count2 <= 0 then
		return "clear"
	end

	local items6 = {}

	for itemId2, item2 in pairs(value3) do
		if type(item2) == "number" and item2 > 0 and (not items5 or items5[itemId2]) then
			items6[#items6 + 1] = itemId2
		end
	end

	table.sort(items6, function(text, text2)
		return tostring(text) < tostring(text2)
	end)

	local value4 = math.random() * count2

	for _2, item3 in ipairs(items6) do
		value4 = value4 - value3[item3]

		if value4 <= 0 then
			return item3
		end
	end

	return "clear"
end

local function callback19(self)
	local number3 = tonumber(self.phaseMinDurationSec) or 600
	local number4 = tonumber(self.phaseMaxDurationSec) or number3

	if number4 < number3 then
		number3, number4 = number4, number3
	end

	local value3 = number4 <= number3 and number3 or number3 + math.random() * (number4 - number3)
	local fromKind = weatherNature._prevKind
	local prevKind = callback18(self)
	local value4 = weatherNature._prevKind
	local count2 = 0

	while prevKind == value4 and count2 < 3 do
		prevKind = callback18(self)
		count2 = count2 + 1
	end

	if fromKind and (fromKind == "rain" or fromKind == "heavyRain") and (prevKind == "clear" or prevKind == "cloudy" or prevKind == "skyCloud") and (tonumber(self.rainbowChance) or value.rainbowChance or 0.3) > math.random() then
		weatherNature._rainbowState = {
			active = true,
			startTime = callback9(),
			duration = tonumber(self.rainbowDurationSec) or value.rainbowDurationSec or 120,
			fadeIn = tonumber(self.rainbowFadeInSec) or value.rainbowFadeInSec or 3,
			fadeOut = tonumber(self.rainbowFadeOutSec) or value.rainbowFadeOutSec or 5
		}

		local value5 = self.rainbowAmbientSound or value.rainbowAmbientSound

		if value5 and sound and sound.playSound then
			pcall(sound.playSound, sound, value5)
		end

		if self.testMode and self.testVerbose then
			print("[weatherNature:test] 雨后彩虹触发！")
		end
	end

	weatherNature._phase = {
		untilTime = callback9() + value3,
		kind = prevKind,
		startTime = callback9()
	}

	if self.transitionEnabled ~= false then
		local number5 = tonumber(self.transitionSec) or value.transitionSec or 60

		weatherNature._transition = {
			startTime = callback9(),
			duration = number5,
			fromKind = fromKind,
			toKind = prevKind
		}
	end

	weatherNature._prevKind = prevKind

	if self.testMode and self.testVerbose then
		print(string.format("[weatherNature:test] 天气 = %s，本段持续 %.0f 秒（reroll=%d）", prevKind, value3, count2))
	end
end

local function cleanup()
	local value3 = weatherNature._transition

	if not value3 then
		return 1
	end

	local value4 = callback9() - value3.startTime

	if value4 >= value3.duration then
		weatherNature._transition = nil

		return 1
	end

	return math.max(0, math.min(1, value4 / value3.duration))
end

local function cleanup2(self, value4, value6)
	if not self then
		return
	end

	local value3 = value4 * value6
	local value5 = math.floor(255 * value6)

	for _, item in ipairs(self) do
		if item and not tolua.isnull(item) then
			if item.setEmissionRate then
				item:setEmissionRate(value3)
			end

			if item.setOpacity then
				item:setOpacity(value5)
			end
		end
	end
end

local function cleanup3(node, value4, value5)
	if not node or tolua.isnull(node) then
		return
	end

	local value3 = math.floor(value4 * value5)

	if node.setOpacity then
		node:setOpacity(value3)
	end
end

local function cleanup4(self)
	local number3 = tonumber(self.lightningMinIntervalSec) or value.lightningMinIntervalSec
	local number4 = tonumber(self.lightningMaxIntervalSec) or value.lightningMaxIntervalSec

	if number4 < number3 then
		number3, number4 = number4, number3
	end

	weatherNature._lightningState = {
		nextTime = callback9() + number3 + math.random() * (number4 - number3)
	}
end

local function cleanup5()
	local flashNodeOwner = weatherNature._lightningState

	if flashNodeOwner and flashNodeOwner.flashNode and not tolua.isnull(flashNodeOwner.flashNode) then
		flashNodeOwner.flashNode:removeSelf()

		flashNodeOwner.flashNode = nil
	end

	weatherNature._lightningState = nil
end

local function cleanup6(self)
	local value3 = weatherNature._lightningState

	if not value3 then
		return
	end

	if not main_scene or tolua.isnull(main_scene) then
		return
	end

	local value4 = main_scene.ground

	if not value4 or tolua.isnull(value4) then
		return
	end

	if not cc or not cc.LayerColor or not cc.LayerColor.create then
		callback("lightning_LayerColor", "cc.LayerColor.create unavailable, lightning flash skipped")

		return
	end

	local number3 = tonumber(self.lightningFlashAlpha) or value.lightningFlashAlpha
	local number4 = tonumber(self.lightningFlashFadeIn) or value.lightningFlashFadeIn
	local number5 = tonumber(self.lightningFlashFadeOut) or value.lightningFlashFadeOut
	local value5 = (display.width or 960) + 40
	local value6 = (display.height or 1136) + 40
	local flashNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 0), value5, value6)

	if not flashNode then
		return
	end

	if flashNode.add2 then
		flashNode:add2(main_scene, 200)
	else
		return
	end

	flashNode:setPosition(-20, -20)
	flashNode:setTouchEnabled(false)

	value3.flashNode = flashNode

	local value7 = cc.FadeTo and cc.FadeTo.create and cc.FadeTo:create(number4, number3)
	local value8 = cc.FadeTo and cc.FadeTo.create and cc.FadeTo:create(number5, 0)

	if not value7 or not value8 then
		flashNode:removeSelf()

		value3.flashNode = nil

		return
	end

	local number6 = tonumber(self.lightningDoubleFlashChance) or value.lightningDoubleFlashChance
	local items5 = {
		value7,
		value8
	}

	if number6 > math.random() then
		local action = cc.DelayTime and cc.DelayTime.create and cc.DelayTime:create(0.12)
		local value9 = cc.FadeTo:create(number4 * 0.7, math.floor(number3 * 0.6))
		local value10 = cc.FadeTo:create(number5 * 0.6, 0)

		if action then
			items5[#items5 + 1] = action
		end

		if value9 then
			items5[#items5 + 1] = value9
		end

		if value10 then
			items5[#items5 + 1] = value10
		end
	end

	local value11 = cc.CallFunc and cc.CallFunc.create and cc.CallFunc:create(function()
		if flashNode and not tolua.isnull(flashNode) then
			flashNode:removeSelf()
		end

		if value3 then
			value3.flashNode = nil
		end
	end)

	if value11 then
		items5[#items5 + 1] = value11
	end

	if #items5 >= 2 then
		local action2 = cc.Sequence:create(items5)

		if action2 then
			flashNode:runAction(action2)
		end
	end

	local number7 = (tonumber(self.thunderDelaySec) or value.thunderDelaySec) + math.random() * (tonumber(self.thunderDelayVarSec) or value.thunderDelayVarSec)
	local value12 = self.thunderSoundFile or value.thunderSoundFile

	if value12 and sound and sound.playSound and scheduler and scheduler.performWithDelayGlobal then
		scheduler.performWithDelayGlobal(function()
			if def.openNatureWeather and sound and sound.playSound then
				sound.playSound(value12)
			end
		end, number7)
	end

	local number8 = tonumber(self.lightningMinIntervalSec) or value.lightningMinIntervalSec
	local number9 = tonumber(self.lightningMaxIntervalSec) or value.lightningMaxIntervalSec

	if number9 < number8 then
		number8, number9 = number9, number8
	end

	value3.nextTime = callback9() + number8 + math.random() * (number9 - number8)
end

local function cleanup7(self, value3)
	if value3 ~= "heavyRain" and value3 ~= "rain" then
		cleanup5()

		return
	end

	if self.lightningEnabled == false then
		return
	end

	if not weatherNature._lightningState then
		cleanup4(self)

		if value3 == "rain" and weatherNature._lightningState then
			weatherNature._lightningState.nextTime = weatherNature._lightningState.nextTime + 20
		end
	end

	local nextTimeOwner = weatherNature._lightningState

	if nextTimeOwner and callback9() >= nextTimeOwner.nextTime then
		cleanup6(self)
	end
end

local function cleanup8()
	local nodeOwner = weatherNature._rainbowState

	if nodeOwner and nodeOwner.node and not tolua.isnull(nodeOwner.node) then
		nodeOwner.node:removeSelf()
	end

	weatherNature._rainbowState = nil
end

local function callback20(self, value4)
	local value3 = weatherNature._rainbowState

	if not value3 or not value3.active then
		return
	end

	if value3.node and not tolua.isnull(value3.node) then
		return
	end

	local map = require("mir2.scenes.main.map.map")
	local callback = map and map.__xnf1c

	if type(callback) ~= "function" then
		return
	end

	local node = callback(map, value4, value3.fadeIn or 3)

	if node then
		value3.node = node
	end
end

local function cleanup9(self)
	local value3 = weatherNature._rainbowState

	if not value3 or not value3.active then
		return
	end

	local value4 = callback9() - value3.startTime
	local value5 = value3.duration
	local value6 = value3.fadeOut or 5

	callback20(nil, self)

	if value4 >= value5 - value6 and value3.node and not tolua.isnull(value3.node) then
		local value7 = value5 - value4
		local value8 = math.max(0, math.floor(255 * value7 / value6))

		value3.node:setOpacity(value8)
	end

	if value5 <= value4 then
		cleanup8()
	end
end

local function cleanup10(self, value3)
	local count2 = 0
	local map = require("mir2.scenes.main.map.map")

	if map and type(map.__q7dark) == "function" then
		count2 = tonumber(map.__q7dark(map, value3, self)) or 0
	end

	local value4 = weatherNature._darkModifier or 0
	local number3 = 0.002

	if value4 < count2 then
		weatherNature._darkModifier = math.min(count2, value4 + number3)
	elseif count2 < value4 then
		weatherNature._darkModifier = math.max(count2, value4 - number3)
	end
end

function weatherNature.getDarkModifier()
	return weatherNature._darkModifier or 0
end

local function cleanup11(self)
	if not self then
		return
	end

	local callback = self.__xnf2o_stop

	if type(callback) == "function" then
		callback(self)
	else
		local rootOwner = self._weatherAtmoWS

		if rootOwner and rootOwner.root and not tolua.isnull(rootOwner.root) then
			rootOwner.root:removeSelf()
		end

		self._weatherAtmoWS = nil
	end
end

local function cleanup12(self, value3, value4)
	if not self then
		return
	end

	local callback = self.__xnf2o

	if type(callback) == "function" then
		callback(self, value4, value3)
	end
end

local function cleanup13(self)
	local value3 = self and self._weatherAtmoWS

	if not value3 or not value3.root or tolua.isnull(value3.root) then
		return
	end

	local value4 = cleanup()

	if value3.layer and not tolua.isnull(value3.layer) and value3.targetAlpha then
		cleanup3(value3.layer, value3.targetAlpha, value4)
	end
end

local items = {}
local number2 = 64

local function cleanup14()
	for index = #items, 1, -1 do
		local value3 = items[index]

		if value3 and not tolua.isnull(value3) then
			table.remove(items, index)

			return value3
		else
			table.remove(items, index)
		end
	end

	return nil
end

local function cleanup15(node)
	if node and not tolua.isnull(node) then
		local value3 = #items < number2

		if value3 and node.retain then
			node:retain()
		end

		if node.stopSystem then
			node:stopSystem()
		end

		if node.removeFromParent then
			node:removeFromParent()
		end

		if value3 then
			items[#items + 1] = node
		end
	end
end

local function cleanup16(self)
	local value3 = self and self._weatherRainWS

	if value3 and value3.splashEmitters then
		for _, splashEmitter in ipairs(value3.splashEmitters) do
			cleanup15(splashEmitter)
		end
	end

	if value3 and value3.layer and not tolua.isnull(value3.layer) then
		value3.layer:removeSelf()
	end

	if self then
		self._weatherRainWS = nil
	end
end

local function callback21(self)
	local value3 = cc.ParticleRain

	if not value3 then
		return nil
	end

	if value3.createWithTotalParticles then
		return value3:createWithTotalParticles(self)
	end

	if value3.create then
		return value3:create()
	end

	return nil
end

local function callback22(self, value4, value6)
	local value3

	if value4 and value4 ~= "" then
		local value5 = cc.Director and cc.Director.getInstance and cc.Director:getInstance()

		value5 = value5 and value5.getTextureCache and value5:getTextureCache()

		if value5 then
			value3 = value5:addImage(value4)
		end
	end

	if not value3 then
		local value7 = value6 ~= nil and value6 or cc.ParticleRain
		local node = value7 and value7.createWithTotalParticles and value7:createWithTotalParticles(2)

		if node then
			value3 = node.getTexture and node:getTexture()

			if node.removeFromParent then
				node:removeFromParent()
			end
		end

		if not value3 and value7 ~= cc.ParticleRain then
			local node2 = cc.ParticleRain and cc.ParticleRain.createWithTotalParticles and cc.ParticleRain:createWithTotalParticles(2)

			if node2 then
				value3 = node2.getTexture and node2:getTexture()

				if node2.removeFromParent then
					node2:removeFromParent()
				end
			end
		end
	end

	if value3 then
		for _, item in ipairs(self) do
			if item and not tolua.isnull(item) and item.setTexture then
				item:setTexture(value3)
			end
		end
	end
end

local function callback23(self, value4)
	if not self then
		return
	end

	local value3 = cc.PARTICLE_MODE_GRAVITY

	if value3 ~= nil and self.setEmitterMode then
		self:setEmitterMode(value3)
	elseif self.setEmitterMode then
		self:setEmitterMode(0)
	end

	if self.setAutoRemoveOnFinish then
		self:setAutoRemoveOnFinish(false)
	end

	if self.resetSystem then
		self:resetSystem()
	end

	local value5 = value4

	if value5 == nil then
		value5 = value2
	end

	if self.setPositionType then
		self:setPositionType(value5)
	end
end

local function callback24(self)
	if not self or not cc or not cc.c4b then
		return nil
	end

	local number3 = math.max(0, math.min(255, math.floor(tonumber(self.r) or 0)))
	local number4 = math.max(0, math.min(255, math.floor(tonumber(self.g) or 0)))
	local number5 = math.max(0, math.min(255, math.floor(tonumber(self.b) or 0)))
	local number6 = math.max(0, math.min(255, math.floor(tonumber(self.a) or 255)))

	return cc.c4b(number3, number4, number5, number6)
end

local function callback25(node, value4)
	if not node then
		return
	end

	local value3 = callback24(value4.rainColorStart or value.rainColorStart)
	local value5 = callback24(value4.rainColorEnd or value.rainColorEnd)

	if value3 and node.setStartColor then
		node:setStartColor(value3)
	end

	if value5 and node.setEndColor then
		node:setEndColor(value5)
	end

	local value6 = value4.rainColorStartVar or value.rainColorStartVar
	local value7 = value4.rainColorEndVar or value.rainColorEndVar
	local value8 = value6 and callback24(value6)
	local value9 = value7 and callback24(value7)

	if value8 and node.setStartColorVar then
		node:setStartColorVar(value8)
	end

	if value9 and node.setEndColorVar then
		node:setEndColorVar(value9)
	end

	if node.setOpacity then
		node:setOpacity(255)
	end

	if node.setRotationIsDir then
		node:setRotationIsDir(true)
	end

	if node.setTangentialAccel then
		node:setTangentialAccel(0)
	end

	if node.setRadialAccel then
		node:setRadialAccel(0)
	end

	if node.setTangentialAccelVar then
		node:setTangentialAccelVar(0)
	end

	if node.setRadialAccelVar then
		node:setRadialAccelVar(0)
	end

	if gl and node.setBlendFunc then
		node:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	end
end

local function callback26(self, value4, number3)
	local value3 = math.floor(value4.startSizeMin or 3)
	local value5 = math.floor(value4.startSizeMax or value3)

	if value5 < value3 then
		value3, value5 = value5, value3
	end

	local value6 = math.random(value3, value5)

	self:setStartSize(value6)

	local value7 = number3.rainStartSizeVarMax

	if value7 == nil then
		value7 = value.rainStartSizeVarMax or 0
	end

	if self.setStartSizeVar then
		self:setStartSizeVar(math.max(0, math.min(4, value7)))
	end

	local number4 = tonumber(number3.rainEndSizeRatio) or value.rainEndSizeRatio or 0.74

	if self.setEndSize then
		self:setEndSize(value6 * number4)
	end

	if self.setEndSizeVar then
		self:setEndSizeVar(0.25)
	end
end

local function callback27(self, number3, number5)
	local value3 = number3.gravityY

	if value3 == nil then
		value3 = number5.rainBaseGravityY or value.rainBaseGravityY
	end

	local number4 = tonumber(number3.rainTiltDegrees) or tonumber(number5.rainTiltDegrees) or value.rainTiltDegrees or 0
	local value4 = math.rad(number4)
	local x = (number5.rainBaseGravityX or 0) + math.abs(value3) * math.sin(value4)
	local y = math.min(value3 * math.cos(value4), -1)

	self:setGravity(cc.p(x, y))

	local value5 = number3.lifeMin or 1
	local value6 = number3.lifeMax or value5

	if value6 < value5 then
		value5, value6 = value6, value5
	end

	self:setLife(value5 + math.random() * math.max(0.01, value6 - value5))

	local value7 = number3.speedMin or 120
	local value8 = number3.speedMax or value7

	if value8 < value7 then
		value7, value8 = value8, value7
	end

	if self.setSpeed then
		self:setSpeed(value7 + math.random() * (value8 - value7))
	end

	if self.setSpeedVar then
		local value9 = value8 - value7

		self:setSpeedVar(value9 * 0.07 + 10)
	end

	if self.setAngle then
		self:setAngle(-90 + number4)
	end

	local number6 = tonumber(number5.rainAngleVar) or value.rainAngleVar or 2.2

	if self.setAngleVar then
		self:setAngleVar(number6)
	end
end

local function callback28(self, value3, y)
	local items5 = {}

	if y.rainSplashEnabled == false then
		return items5
	end

	if not cc.ParticleSystemQuad or not cc.ParticleSystemQuad.createWithTotalParticles then
		callback("rainSplash_PSQ", "cc.ParticleSystemQuad unavailable, rain splash disabled")

		return items5
	end

	local value4 = math.max(3, math.floor(y.rainSplashSlots or 10))
	local value5 = -((display.height or 1136) * 0.5) * (y.rainGroundLineRatio or value.rainGroundLineRatio)
	local value6 = (display.width or 960) * 0.52

	for index = 1, value4 do
		local value7 = ((index - 0.5) / value4 - 0.5) * 2 * value6 + (math.random() - 0.5) * 40
		local value8 = callback3(y.rainSplashParticles or 16)
		local node = cleanup14()

		if node then
			if node.resetSystem then
				node:resetSystem()
			end

			if node.setPositionType then
				node:setPositionType(value2)
			end

			if value3 and node.setTexture then
				node:setTexture(value3)
			end

			node:setPosition(value7, value5 + math.random(-8, 8))
			node:add2(self)

			if node.release then
				node:release()
			end
		else
			node = cc.ParticleSystemQuad:createWithTotalParticles(value8)

			if not node then
				break
			end

			if value3 and node.setTexture then
				node:setTexture(value3)
			end

			callback23(node, value2)
			node:setPosition(value7, value5 + math.random(-8, 8))
			node:add2(self)
		end

		node:setLife(y.rainSplashLife or 0.11)

		if node.setLifeVar then
			node:setLifeVar(y.rainSplashLifeVar or 0.04)
		end

		if node.setSpeed then
			node:setSpeed(y.rainSplashSpeed or 24)
		end

		if node.setSpeedVar then
			node:setSpeedVar(y.rainSplashSpeedVar or 18)
		end

		if node.setAngle then
			node:setAngle(y.rainSplashAngle or 90)
		end

		if node.setAngleVar then
			node:setAngleVar(y.rainSplashAngleVar or 75)
		end

		node:setGravity(cc.p(0, y.rainSplashGravityY or value.rainSplashGravityY))

		if node.setStartSize then
			node:setStartSize(2)
		end

		if node.setStartSizeVar then
			node:setStartSizeVar(1)
		end

		if node.setEndSize then
			node:setEndSize(0.3)
		end

		if node.setEmissionRate then
			node:setEmissionRate(y.rainSplashEmission or 42)
		end

		node:setDuration(-1)

		if node.setOpacity then
			node:setOpacity(220)
		end

		if gl and node.setBlendFunc then
			node:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
		end

		node:setLocalZOrder((y.rainEmitterLocalZ or 9999) + 2)

		items5[#items5 + 1] = node
	end

	return items5
end

local function cleanup17(self, kind, nc)
	cleanup16(self)

	local value3 = nc[kind]

	if type(value3) ~= "table" then
		value3 = nc.rain or value.rain
	end

	local value4 = callback4(value3.particleGroups or 8)
	local baseEmission = callback3(value3.particlesPerGroup or 200)
	local node = display.newNode():addto(self, nc.rainLayerZOrder or 99):anchor(0.5, 0.5)

	callback14(self, node)

	local emitters = {}
	local value5 = display.width or 960
	local value6 = display.height or 1136
	local value7 = value6 * 0.5
	local value8 = value5 * 0.5 * (nc.rainSpawnWidthScale or value.rainSpawnWidthScale or 1.08)
	local value9 = value6 * (nc.rainSpawnTopPadRatio or value.rainSpawnTopPadRatio or 0.25)
	local value10 = value6 * (nc.rainSpawnBottomPadRatio or value.rainSpawnBottomPadRatio or 0.15)
	local value11 = value6 + value9 + value10
	local x = value5 * 2
	local y = value6 * 0.5

	for index = 1, value4 do
		local node2 = callback21(baseEmission)

		if not node2 then
			break
		end

		callback23(node2)

		local x2 = (math.random() - 0.5) * 2 * value8 + (math.random() - 0.5) * 60
		local y2 = value7 + value9 - math.random() * value11

		node2:setPosition(cc.p(x2, y2))

		if node2.setPosVar then
			node2:setPosVar(cc.p(x, y))
		end

		node2:setLocalZOrder(nc.rainEmitterLocalZ or 9999)
		callback27(node2, value3, nc)
		callback25(node2, nc)
		callback26(node2, value3, nc)
		node2:setDuration(-1)
		node2:add2(node)

		emitters[#emitters + 1] = node2
	end

	if #emitters == 0 then
		node:removeSelf()

		return false
	end

	local texture

	for _, item in ipairs(emitters) do
		if item.getTexture then
			texture = item:getTexture()

			break
		end
	end

	local splashEmitters = callback28(node, texture, nc)

	self._weatherRainWS = {
		layer = node,
		emitters = emitters,
		splashEmitters = splashEmitters,
		kind = kind,
		nc = nc,
		baseEmission = baseEmission
	}

	return true
end

local function callback29(self, number3)
	local value3 = self and self._weatherRainWS

	if not value3 or not value3.emitters then
		return
	end

	local value4 = cleanup()

	if value4 < 1 and value3.emitters then
		cleanup2(value3.emitters, value3.baseEmission or 200, value4)
	end

	local naturalWindDelta, naturalWindDelta2 = weatherSnow.getNaturalWindDelta(callback11())
	local number4 = number3[value3.kind or "rain"]

	if type(number4) ~= "table" then
		number4 = number3.rain or value.rain
	end

	local value5 = number4.gravityY

	if value5 == nil then
		value5 = number3.rainBaseGravityY or value.rainBaseGravityY
	end

	local value6 = number3.rainBaseGravityX or 0
	local number5 = tonumber(number4.rainTiltDegrees) or tonumber(number3.rainTiltDegrees) or value.rainTiltDegrees or 0
	local value7 = math.rad(number5)
	local x = value6 + math.abs(value5) * math.sin(value7)
	local y = value5 * math.cos(value7)

	if y > -1 then
		y = value5
	end

	local number6 = tonumber(number3.rainWindInfluence) or value.rainWindInfluence or 0.1
	local number7 = tonumber(number3.rainSplashWindInfluence) or value.rainSplashWindInfluence or 0.22

	for _, emitter in ipairs(value3.emitters) do
		if emitter and not tolua.isnull(emitter) and emitter.setGravity then
			emitter:setGravity(cc.p(x + naturalWindDelta * number6, y + naturalWindDelta2 * number6))
		end
	end

	local y2 = number3.rainSplashGravityY or value.rainSplashGravityY

	for _2, item in ipairs(value3.splashEmitters or {}) do
		if item and not tolua.isnull(item) and item.setGravity then
			item:setGravity(cc.p(naturalWindDelta * number7, y2 + naturalWindDelta2 * number7))
		end
	end
end

local function callback30(self)
	local value3

	if self and self.texturePath and self.texturePath ~= "" then
		local value4 = cc.Director and cc.Director.getInstance and cc.Director:getInstance()

		value4 = value4 and value4.getTextureCache and value4:getTextureCache()

		if value4 then
			value3 = value4:addImage(self.texturePath)
		end
	end

	if not value3 then
		for index, item in ipairs({
			cc.ParticleSnow,
			cc.ParticleFlower,
			cc.ParticleRain
		}) do
			if item and item.createWithTotalParticles then
				local node = item:createWithTotalParticles(2)

				if node then
					value3 = node.getTexture and node:getTexture()

					if node.removeFromParent then
						node:removeFromParent()
					end

					if value3 then
						break
					end
				end
			end
		end
	end

	return value3
end

local function cleanup18(self, value3, value5, value7, value9)
	local node = display.newNode()

	if not self then
		return node
	end

	local value4 = value7 or 5 + math.random(0, 4)
	local value6 = value9 or 120 + math.random(0, 60)

	for index = 1, value4 do
		local value8, node2 = pcall(function()
			return cc.Sprite:createWithTexture(self)
		end)

		if not value8 or not node2 then
			break
		end

		local value10 = 1.4 + math.random() * 2.8
		local value11 = 0.5 + math.random() * 1.2

		node2:setScaleX(value10)
		node2:setScaleY(value11)
		node2:setRotation(math.random(-30, 30))

		local x = (math.random() - 0.5) * value3 * 0.9
		local y = (math.random() - 0.5) * value5 * 0.75

		node2:setPosition(cc.p(x, y))

		local value12 = math.sqrt((x / (value3 * 0.5))^2 + (y / (value5 * 0.5))^2)
		local value13 = math.floor(value6 * (1 - math.min(0.55, value12 * 0.38)))
		local value14 = math.max(50, math.min(240, value13))

		node2:setOpacity(value14)

		if node2.setColor then
			pcall(node2.setColor, node2, cc.c3b and cc.c3b(255, 255, 255) or {
				255,
				255,
				255
			})
		end

		if gl and node2.setBlendFunc then
			node2:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
		end

		node:addChild(node2, index)
	end

	return node
end

local function cleanup19(self)
	local layerOwner = self and self._weatherSkyCloudWS

	if layerOwner and layerOwner.layer and not tolua.isnull(layerOwner.layer) then
		layerOwner.layer:removeSelf()
	end

	if self then
		self._weatherSkyCloudWS = nil
	end
end

local function callback31(self, nc)
	cleanup19(self)

	local number3 = nc.skyCloud

	if type(number3) ~= "table" then
		number3 = value.skyCloud or {}
	end

	local value3 = callback30(number3)
	local number4 = tonumber(nc.cloudDriftLayerZOrder) or value.cloudDriftLayerZOrder or 46
	local node = display.newNode():addto(self, number4):anchor(0.5, 0.5)
	local number5 = tonumber(nc.cloudDriftSkyAnchorOffsetY) or value.cloudDriftSkyAnchorOffsetY or 200

	callback16(self, node, display.cx, display.cy + number5)

	local value4 = display.width or 960
	local value5 = display.height or 1136
	local number6 = tonumber(nc.cloudDriftSpawnWidthScale) or value.cloudDriftSpawnWidthScale or 1.12
	local number7 = tonumber(nc.cloudDriftSpawnHeightRatio) or value.cloudDriftSpawnHeightRatio or 0.26
	local number8 = tonumber(nc.cloudDriftSpawnBaseYRatio) or value.cloudDriftSpawnBaseYRatio or 0.24
	local spreadX = value4 * 0.5 * number6
	local value6 = value5 * number7 * 0.5
	local value7 = value5 * number8
	local value8 = value.skyCloud or {}
	local number9 = tonumber(number3.particleGroups) or value8.particleGroups or 12
	local items5 = {
		{
			minH = 150,
			maxW = 1000,
			maxH = 250,
			puffs = 11,
			minW = 600,
			alphaBase = 170
		},
		{
			minH = 100,
			maxW = 600,
			maxH = 170,
			puffs = 8,
			minW = 350,
			alphaBase = 150
		},
		{
			minH = 60,
			maxW = 350,
			maxH = 110,
			puffs = 6,
			minW = 160,
			alphaBase = 130
		}
	}
	local clouds = {}
	local number10 = tonumber(nc.cloudDriftEmitterLocalZ) or value.cloudDriftEmitterLocalZ or 10000
	local number11 = tonumber(number3.speedMin) or value8.speedMin or 1
	local number12 = tonumber(number3.speedMax) or value8.speedMax or 3

	for index = 1, number9 do
		local value9 = items5[(index - 1) % 3 + 1]
		local width = value9.minW + math.random() * (value9.maxW - value9.minW)
		local value10 = value9.minH + math.random() * (value9.maxH - value9.minH)
		local node2 = cleanup18(value3, width, value10, value9.puffs, value9.alphaBase)

		if not node2 then
			break
		end

		local x = (math.random() - 0.5) * 2 * spreadX
		local y = value7 + (math.random() - 0.5) * 2 * value6

		node2:setPosition(cc.p(x, y))
		node:addChild(node2, number10 + index % 3)

		local vx = number11 + math.random() * math.max(0, number12 - number11)

		if math.random() < 0.15 then
			vx = -vx
		end

		local vy = (math.random() - 0.5) * 0.3

		clouds[#clouds + 1] = {
			node = node2,
			vx = vx,
			vy = vy,
			width = width,
			x = x,
			y = y
		}
	end

	if #clouds == 0 then
		node:removeSelf()

		return false
	end

	self._weatherSkyCloudWS = {
		layer = node,
		clouds = clouds,
		nc = nc,
		spreadX = spreadX
	}

	return true
end

local function cleanup20(self, number3)
	local value3 = self and self._weatherSkyCloudWS

	if not value3 or not value3.clouds then
		return
	end

	local lastTick = callback9()
	local value4 = value3._lastTick and math.min(0.12, lastTick - value3._lastTick) or 0.033

	value3._lastTick = lastTick

	local naturalWindDelta, naturalWindDelta2 = weatherSnow.getNaturalWindDelta(callback11())
	local number4 = tonumber(number3.cloudDriftWindInfluence) or value.cloudDriftWindInfluence or 0.18
	local value5 = value3.spreadX or 600

	for _, cloud in ipairs(value3.clouds) do
		if cloud.node and not tolua.isnull(cloud.node) then
			cloud.x = (cloud.x or 0) + (cloud.vx + naturalWindDelta * number4) * value4 * 60
			cloud.y = (cloud.y or 0) + (cloud.vy + naturalWindDelta2 * number4 * 0.05) * value4 * 60

			local value6 = value5 + (cloud.width or 200) * 0.6

			if value6 < cloud.x then
				cloud.x = cloud.x - value6 * 2
			elseif cloud.x < -value6 then
				cloud.x = cloud.x + value6 * 2
			end

			cloud.node:setPosition(cc.p(cloud.x, cloud.y))
		end
	end
end

local function cleanup21(self)
	local value3 = self and self._weatherDustWS

	if value3 and value3.emitters then
		for _, emitter in ipairs(value3.emitters) do
			if emitter and not tolua.isnull(emitter) and emitter.stopSystem then
				emitter:stopSystem()
			end
		end
	end

	if value3 and value3.layer and not tolua.isnull(value3.layer) then
		value3.layer:removeSelf()
	end

	if self then
		self._weatherDustWS = nil
	end
end

local function callback32(self, nc)
	cleanup21(self)

	local number3 = nc.dustStorm or value.dustStorm

	if not cc.ParticleSystemQuad or not cc.ParticleSystemQuad.createWithTotalParticles then
		callback("dustStorm_PSQ", "cc.ParticleSystemQuad unavailable, dust storm disabled")

		return false
	end

	local value3 = callback4(number3.particleGroups or 12)
	local value4 = callback3(number3.particlesPerGroup or 380)
	local number4 = tonumber(number3.layerZOrder) or 97
	local node = display.newNode():addto(self, number4):anchor(0.5, 0.5)

	callback14(self, node)

	local x = display.width or 960
	local y = display.height or 1136
	local value5 = x * 0.6
	local value6 = y * 0.5
	local emitters = {}
	local number5 = tonumber(number3.emitterLocalZ) or 9998

	for index = 1, value3 do
		local node2 = cc.ParticleSystemQuad:createWithTotalParticles(value4)

		if not node2 then
			break
		end

		callback23(node2)

		local x2 = (math.random() - 0.5) * 2 * value5
		local y2 = (math.random() - 0.5) * 2 * value6

		node2:setPosition(cc.p(x2, y2))

		if node2.setPosVar then
			node2:setPosVar(cc.p(x * 2, y * 0.5))
		end

		node2:setLocalZOrder(number5 + index % 3)

		local number6 = tonumber(number3.gravityX) or 180
		local number7 = tonumber(number3.gravityY) or -60

		node2:setGravity(cc.p(number6, number7))

		local number8 = tonumber(number3.lifeMin) or 1.8
		local number9 = tonumber(number3.lifeMax) or number8

		node2:setLife(number8 + math.random() * math.max(0.01, number9 - number8))

		local number10 = tonumber(number3.speedMin) or 160
		local number11 = tonumber(number3.speedMax) or number10

		if node2.setSpeed then
			node2:setSpeed(number10 + math.random() * (number11 - number10))
		end

		if node2.setSpeedVar then
			node2:setSpeedVar((number11 - number10) * 0.1 + 15)
		end

		local number12 = tonumber(number3.angleDeg) or -15
		local number13 = tonumber(number3.angleVar) or 18

		if node2.setAngle then
			node2:setAngle(number12)
		end

		if node2.setAngleVar then
			node2:setAngleVar(number13)
		end

		local number14 = math.floor(tonumber(number3.startSizeMin) or 4)
		local number15 = math.floor(tonumber(number3.startSizeMax) or 12)
		local value7 = math.random(number14, number15)

		node2:setStartSize(value7)

		if node2.setStartSizeVar then
			node2:setStartSizeVar(math.max(1, value7 * 0.3))
		end

		local number16 = tonumber(number3.endSizeRatio) or 0.5

		if node2.setEndSize then
			node2:setEndSize(value7 * number16)
		end

		local value8 = value.dustStorm or {}
		local value9 = callback24(number3.colorStart or value8.colorStart)
		local value10 = callback24(number3.colorEnd or value8.colorEnd)

		if value9 and node2.setStartColor then
			node2:setStartColor(value9)
		end

		if value10 and node2.setEndColor then
			node2:setEndColor(value10)
		end

		local value11 = number3.colorStartVar or value8.colorStartVar
		local value12 = number3.colorEndVar or value8.colorEndVar
		local value13 = value11 and callback24(value11)
		local value14 = value12 and callback24(value12)

		if value13 and node2.setStartColorVar then
			node2:setStartColorVar(value13)
		end

		if value14 and node2.setEndColorVar then
			node2:setEndColorVar(value14)
		end

		if node2.setRotationIsDir then
			node2:setRotationIsDir(true)
		end

		if gl and node2.setBlendFunc then
			node2:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
		end

		node2:setDuration(-1)
		node2:add2(node)

		emitters[#emitters + 1] = node2
	end

	callback22(emitters, number3.texturePath)

	if #emitters == 0 then
		node:removeSelf()

		return false
	end

	cleanup12(self, nc, "dustStorm")

	self._weatherDustWS = {
		layer = node,
		emitters = emitters,
		nc = nc
	}

	return true
end

local function cleanup22(self, dustStormOwner)
	local emittersOwner = self and self._weatherDustWS

	if not emittersOwner or not emittersOwner.emitters then
		return
	end

	local value3 = cleanup()

	if value3 < 1 and emittersOwner.emitters then
		local value4 = callback3(380)

		cleanup2(emittersOwner.emitters, value4, value3)
	end

	local naturalWindDelta, naturalWindDelta2 = weatherSnow.getNaturalWindDelta(callback11())
	local number3 = dustStormOwner.dustStorm or value.dustStorm
	local number4 = tonumber(number3.gravityX) or 180
	local number5 = tonumber(number3.gravityY) or -60

	for _, emitter in ipairs(emittersOwner.emitters) do
		if emitter and not tolua.isnull(emitter) and emitter.setGravity then
			emitter:setGravity(cc.p(number4 + naturalWindDelta * 2, number5 + naturalWindDelta2 * 0.5))
		end
	end
end

local function cleanup23(self)
	local value3 = self and self._weatherLeavesWS

	if value3 and value3.emitters then
		for _, emitter in ipairs(value3.emitters) do
			if emitter and not tolua.isnull(emitter) and emitter.stopSystem then
				emitter:stopSystem()
			end
		end
	end

	if value3 and value3.layer and not tolua.isnull(value3.layer) then
		value3.layer:removeSelf()
	end

	if self then
		self._weatherLeavesWS = nil
	end
end

local function callback33(self, nc)
	cleanup23(self)

	local number3 = nc.fallingLeaves or value.fallingLeaves

	if not cc.ParticleSystemQuad or not cc.ParticleSystemQuad.createWithTotalParticles then
		callback("fallingLeaves_PSQ", "cc.ParticleSystemQuad unavailable, falling leaves disabled")

		return false
	end

	local value3 = callback4(number3.particleGroups or 4)
	local value4 = callback3(number3.particlesPerGroup or 60)
	local number4 = tonumber(number3.layerZOrder) or 95
	local node = display.newNode():addto(self, number4):anchor(0.5, 0.5)

	callback16(self, node, display.cx, display.cy + 80)

	local x = display.width or 960
	local y = display.height or 1136
	local value5 = x * 0.5
	local emitters = {}
	local number5 = tonumber(number3.emitterLocalZ) or 9997

	for index = 1, value3 do
		local node2 = cc.ParticleSystemQuad:createWithTotalParticles(value4)

		if not node2 then
			break
		end

		callback23(node2)

		local x2 = (math.random() - 0.5) * 2 * value5
		local y2 = y * 0.3 + math.random() * y * 0.2

		node2:setPosition(cc.p(x2, y2))

		if node2.setPosVar then
			node2:setPosVar(cc.p(x * 2, y * 0.5))
		end

		node2:setLocalZOrder(number5 + index % 2)

		local number6 = tonumber(number3.gravityX) or 15
		local number7 = tonumber(number3.gravityY) or -25

		node2:setGravity(cc.p(number6, number7))

		local number8 = tonumber(number3.lifeMin) or 5
		local number9 = tonumber(number3.lifeMax) or 9

		node2:setLife(number8 + math.random() * math.max(0.01, number9 - number8))

		if node2.setLifeVar then
			node2:setLifeVar(1.5)
		end

		local number10 = tonumber(number3.speedMin) or 15
		local number11 = tonumber(number3.speedMax) or 45

		if node2.setSpeed then
			node2:setSpeed(number10 + math.random() * (number11 - number10))
		end

		if node2.setSpeedVar then
			node2:setSpeedVar(12)
		end

		local number12 = tonumber(number3.angleDeg) or -70
		local number13 = tonumber(number3.angleVar) or 40

		if node2.setAngle then
			node2:setAngle(number12)
		end

		if node2.setAngleVar then
			node2:setAngleVar(number13)
		end

		local number14 = tonumber(number3.tangentialAccel) or 30
		local number15 = tonumber(number3.tangentialAccelVar) or 20

		if node2.setTangentialAccel then
			node2:setTangentialAccel(number14)
		end

		if node2.setTangentialAccelVar then
			node2:setTangentialAccelVar(number15)
		end

		local number16 = math.floor(tonumber(number3.startSizeMin) or 8)
		local number17 = math.floor(tonumber(number3.startSizeMax) or 16)
		local value6 = math.random(number16, number17)

		node2:setStartSize(value6)

		if node2.setStartSizeVar then
			node2:setStartSizeVar(math.max(1, value6 * 0.25))
		end

		local number18 = tonumber(number3.endSizeRatio) or 0.7

		if node2.setEndSize then
			node2:setEndSize(value6 * number18)
		end

		local value7 = value.fallingLeaves or {}
		local value8 = callback24(number3.colorStart or value7.colorStart)
		local value9 = callback24(number3.colorEnd or value7.colorEnd)

		if value8 and node2.setStartColor then
			node2:setStartColor(value8)
		end

		if value9 and node2.setEndColor then
			node2:setEndColor(value9)
		end

		local value10 = number3.colorStartVar or value7.colorStartVar
		local value11 = number3.colorEndVar or value7.colorEndVar
		local value12 = value10 and callback24(value10)
		local value13 = value11 and callback24(value11)

		if value12 and node2.setStartColorVar then
			node2:setStartColorVar(value12)
		end

		if value13 and node2.setEndColorVar then
			node2:setEndColorVar(value13)
		end

		if node2.setStartSpin then
			node2:setStartSpin(math.random(0, 360))
		end

		if node2.setStartSpinVar then
			node2:setStartSpinVar(180)
		end

		if node2.setEndSpin then
			node2:setEndSpin(math.random(0, 720))
		end

		if node2.setEndSpinVar then
			node2:setEndSpinVar(360)
		end

		if gl and node2.setBlendFunc then
			node2:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
		end

		node2:setDuration(-1)
		node2:add2(node)

		emitters[#emitters + 1] = node2
	end

	callback22(emitters, number3.leavesTexturePath, cc.ParticleFlower)

	if #emitters == 0 then
		node:removeSelf()

		return false
	end

	self._weatherLeavesWS = {
		layer = node,
		emitters = emitters,
		nc = nc
	}

	return true
end

local function callback34(self, fallingLeavesOwner)
	local emittersOwner = self and self._weatherLeavesWS

	if not emittersOwner or not emittersOwner.emitters then
		return
	end

	local naturalWindDelta, naturalWindDelta2 = weatherSnow.getNaturalWindDelta(callback11())
	local number3 = fallingLeavesOwner.fallingLeaves or value.fallingLeaves
	local number4 = tonumber(number3.gravityX) or 15
	local number5 = tonumber(number3.gravityY) or -25

	for _, emitter in ipairs(emittersOwner.emitters) do
		if emitter and not tolua.isnull(emitter) and emitter.setGravity then
			emitter:setGravity(cc.p(number4 + naturalWindDelta * 0.8, number5 + naturalWindDelta2 * 0.3))
		end
	end
end

local function callback35()
	local value3, value4 = pcall(require, "mir2.scenes.main.ui")

	if value3 and value4 and type(value4.__fx_a0) == "function" then
		value4.__fx_a0(value4)
	end
end

local function callback36(self, number3)
	callback35()

	if not self or self == "" then
		return
	end

	local value3, value4 = pcall(require, "mir2.scenes.main.ui")

	if not value3 or not value4 or type(value4.__fx_a1) ~= "function" then
		return
	end

	local number4 = tonumber(number3.ambientSoundIntervalMin) or value.ambientSoundIntervalMin or 22
	local number5 = tonumber(number3.ambientSoundIntervalMax) or value.ambientSoundIntervalMax or 45

	value4.__fx_a1(value4, self, number4, number5)
end

local function callback37(self)
	cleanup11(self)
	weatherSnow.stopForMap(self)
	cleanup16(self)
	cleanup19(self)
	cleanup21(self)
	cleanup23(self)
	cleanup5()
	cleanup8()
	callback35()

	if self then
		self._natureActiveKind = nil
	end
end

local function callback38(self, value4)
	if not self or self == "" then
		return nil
	end

	local value3 = self .. "AmbientSound"

	return value4[value3] or value[value3]
end

local function callback39(self, natureActiveKind, value4)
	if not self or not weatherNature.shouldShowOnMap(self) then
		callback37(self)

		return
	end

	callback37(self)

	self._natureActiveKind = natureActiveKind

	if natureActiveKind == "clear" or natureActiveKind == "sunny" then
		-- block empty
	elseif natureActiveKind == "snow" then
		weatherSnow.startForMap(self)
	elseif natureActiveKind == "fog" then
		cleanup12(self, value4, "fog")
	elseif natureActiveKind == "cloudy" then
		cleanup12(self, value4, "cloudy")
	elseif natureActiveKind == "drizzle" or natureActiveKind == "rain" or natureActiveKind == "heavyRain" then
		if not cleanup17(self, natureActiveKind, value4) then
			self._natureActiveKind = "clear"

			return
		end
	elseif natureActiveKind == "skyCloud" then
		if not callback31(self, value4) then
			self._natureActiveKind = "clear"

			return
		end
	elseif natureActiveKind == "dustStorm" then
		if not callback32(self, value4) then
			self._natureActiveKind = "clear"

			return
		end
	elseif natureActiveKind == "fallingLeaves" then
		if not callback33(self, value4) then
			self._natureActiveKind = "clear"

			return
		end
	else
		self._natureActiveKind = "clear"

		return
	end

	local value3 = callback38(self._natureActiveKind, value4)

	if value3 then
		callback36(value3, value4)
	end
end

function weatherNature:_tick()
	if not def.weatherEnabled then
		return
	end

	local value3 = callback10()
	local value4 = callback9()

	if not weatherNature._phase then
		callback19(value3)
	elseif value4 >= weatherNature._phase.untilTime and value3.autoRotate ~= false then
		callback19(value3)
	end

	local value5 = weatherNature._phase and weatherNature._phase.kind or "clear"

	if not main_scene or tolua.isnull(main_scene) then
		return
	end

	local mapOwner = main_scene.ground

	if not mapOwner or tolua.isnull(mapOwner) then
		return
	end

	local text = mapOwner.map

	if not text or tolua.isnull(text) then
		return
	end

	local value6 = value3.mapWeather
	local text2 = tostring(text.mapid or "")
	local value7 = g_data and g_data.map and g_data.map.mapTitle or ""
	local value8 = value6 and (value6[text2] or value7 ~= "" and value6[value7]) or items2[text2] or value7 ~= "" and items2[value7]

	if value8 then
		value5 = value8
	end

	if text._natureActiveKind ~= value5 then
		callback39(text, value5, value3)

		return
	end

	if not weatherNature.shouldShowOnMap(text) then
		if text._natureActiveKind then
			callback37(text)
		end

		return
	end

	if value5 == "snow" or value5 == "skyCloud" or value5 == "dustStorm" or value5 == "fallingLeaves" or value5 == "drizzle" or value5 == "rain" or value5 == "heavyRain" then
		local layerOwner

		if value5 == "snow" then
			layerOwner = text._weatherSnowWS
		elseif value5 == "skyCloud" then
			layerOwner = text._weatherSkyCloudWS
		elseif value5 == "dustStorm" then
			layerOwner = text._weatherDustWS
		elseif value5 == "fallingLeaves" then
			layerOwner = text._weatherLeavesWS
		elseif value5 == "drizzle" or value5 == "rain" or value5 == "heavyRain" then
			layerOwner = text._weatherRainWS
		end

		if layerOwner and layerOwner.layer and callback17(text, layerOwner.layer) then
			callback39(text, value5, value3)

			return
		end
	end

	if value5 == "snow" and text._weatherSnowWS then
		weatherSnow.tickMapWeather(text, self)
	elseif (value5 == "drizzle" or value5 == "rain" or value5 == "heavyRain") and text._weatherRainWS then
		callback29(text, value3)
	elseif value5 == "skyCloud" and text._weatherSkyCloudWS then
		cleanup20(text, value3)
	elseif (value5 == "fog" or value5 == "cloudy") and text._weatherAtmoWS then
		cleanup13(text)
	elseif value5 == "dustStorm" and text._weatherDustWS then
		cleanup22(text, value3)
		cleanup13(text)
	elseif value5 == "fallingLeaves" and text._weatherLeavesWS then
		callback34(text, value3)
	end

	cleanup7(value3, value5)
	cleanup9(value3)
	cleanup10(value3, value5)
end

function weatherNature:syncMap()
	if not def.weatherEnabled then
		callback37(self)

		return
	end

	if not self then
		return
	end

	if not weatherNature.shouldShowOnMap(self) then
		callback37(self)

		return
	end

	local value3 = callback10()

	if not weatherNature._phase then
		callback19(value3)
	end

	local value4 = weatherNature._phase and weatherNature._phase.kind or "clear"

	callback39(self, value4, value3)

	if not weatherNature._sched and scheduler and scheduler.scheduleUpdateGlobal and handler then
		weatherNature._sched = scheduler.scheduleUpdateGlobal(handler(weatherNature, weatherNature._tick))
	end
end

function weatherNature.syncCurrentMap()
	if not main_scene or tolua.isnull(main_scene) then
		return
	end

	local mapOwner = main_scene.ground

	if not mapOwner or tolua.isnull(mapOwner) then
		return
	end

	if mapOwner.map and not tolua.isnull(mapOwner.map) then
		weatherNature.syncMap(mapOwner.map)
	end
end

function weatherNature:onMapCreated()
	if not self or tolua.isnull(self) then
		return
	end

	if not def.weatherEnabled then
		return
	end

	weatherNature.syncMap(self)

	if not scheduler or not scheduler.performWithDelayGlobal then
		return
	end

	scheduler.performWithDelayGlobal(function()
		if main_scene and not tolua.isnull(main_scene) and main_scene.ground and not tolua.isnull(main_scene.ground) and main_scene.ground.map == self then
			weatherNature.syncMap(self)
		end
	end, 0.22)
	scheduler.performWithDelayGlobal(function()
		if main_scene and not tolua.isnull(main_scene) and main_scene.ground and not tolua.isnull(main_scene.ground) and main_scene.ground.map == self then
			weatherNature.syncMap(self)
		end
	end, 0.55)
end

function weatherNature:cleanupMap()
	if not self then
		return
	end

	callback37(self)
end

function weatherNature.shutdown()
	if weatherNature._sched and scheduler and scheduler.unscheduleGlobal then
		pcall(scheduler.unscheduleGlobal, weatherNature._sched)
	end

	weatherNature._sched = nil

	if weatherSnow and weatherSnow.shutdown then
		weatherSnow.shutdown()
	end
end

function weatherNature.getCurrentWeather()
	if weatherNature._phase then
		return weatherNature._phase.kind
	end

	return "clear"
end

function weatherNature.forceWeather(prevKind)
	local fromKind = weatherNature._phase and weatherNature._phase.kind or nil

	weatherNature._phase = {
		untilTime = callback9() + 9999999,
		kind = prevKind,
		startTime = callback9()
	}
	weatherNature._transition = {
		duration = 3,
		startTime = callback9(),
		fromKind = fromKind,
		toKind = prevKind
	}
	weatherNature._prevKind = prevKind

	weatherNature.syncCurrentMap()
	print(string.format("[weatherNature] 强制切换天气 → %s", prevKind))
end

return weatherNature
