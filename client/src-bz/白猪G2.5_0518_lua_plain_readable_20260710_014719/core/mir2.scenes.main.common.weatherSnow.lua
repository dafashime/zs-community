local weatherSnow = {}
local items2 = {
	high = 1,
	medium = 0.65,
	low = 0.35
}

local function callback()
	local value3 = def.weatherQuality or "high"

	return items2[value3] or items2.high
end

local function callback2(self)
	return math.max(6, math.floor(self * callback()))
end

local items3 = {
	snowSplashParticles = 12,
	screenAnchorOffsetY = 120,
	softBlur = true,
	layerZOrder = 99,
	naturalWindMinDurationSec = 600,
	baseGravityX = 0,
	lifeMax = 4.2,
	baseGravityY = -14,
	snowSplashAngle = 85,
	naturalWindMaxDurationSec = 1200,
	snowGroundLineRatio = 0.62,
	startSizeVarMax = 12,
	naturalWindEnabled = true,
	startSizeMax = 10,
	naturalWindStrengthMin = 10,
	lifeMin = 2.2,
	snowSplashLife = 0.2,
	particleGroups = 10,
	snowSplashGravityY = -90,
	emitterOpacity = 255,
	emitterLocalZ = 9999,
	snowSplashLifeVar = 0.06,
	startSizeVarMin = 4,
	naturalWindStrengthMax = 38,
	snowSplashSlots = 8,
	snowSplashEmission = 26,
	layerOpacity = 255,
	startSizeMin = 5,
	snowGroundSplash = true,
	snowSplashSpeed = 12,
	snowSplashSpeedVar = 10,
	snowSplashAngleVar = 65,
	particlesPerGroup = 240,
	caveTitlePatterns = {
		"洞",
		"穴",
		"矿洞",
		"矿坑",
		"牢",
		"监狱",
		"狱",
		"古墓",
		"尸魔",
		"石窟",
		"密道",
		"地下城",
		"地牢",
		"神殿",
		"藏宝阁"
	}
}
local value = 1 / math.sqrt(2)
local value2 = cc and cc.POSITION_TYPE_GROUPED or 2

weatherSnow._naturalWindPhase = nil
weatherSnow._windStartTime = nil

local function callback3()
	if socket and socket.gettime then
		return socket.gettime()
	end

	return os.time()
end

local function callback4(self)
	local number2 = tonumber(self.naturalWindMinDurationSec) or 600
	local number3 = tonumber(self.naturalWindMaxDurationSec) or number2

	if number3 < number2 then
		number2, number3 = number3, number2
	end

	if number3 <= number2 then
		return number2
	end

	return number2 + math.random() * (number3 - number2)
end

local function callback5(self)
	local number2 = tonumber(self.naturalWindStrengthMin) or 0
	local number3 = tonumber(self.naturalWindStrengthMax) or number2

	if number3 < number2 then
		number2, number3 = number3, number2
	end

	if number3 <= number2 then
		return number2
	end

	return number2 + math.random() * (number3 - number2)
end

local function callback6(self)
	if not self.naturalWindEnabled then
		return 0, 0
	end

	local windStartTime = callback3()
	local value3 = weatherSnow._naturalWindPhase

	if not value3 or windStartTime >= value3.untilTime then
		weatherSnow._naturalWindPhase = {
			untilTime = windStartTime + callback4(self),
			kind = math.random(1, 2),
			strength = callback5(self),
			phaseOffset1 = math.random() * math.pi * 2,
			phaseOffset2 = math.random() * math.pi * 2
		}
		value3 = weatherSnow._naturalWindPhase

		if not weatherSnow._windStartTime then
			weatherSnow._windStartTime = windStartTime
		end
	end

	local value4 = windStartTime - (weatherSnow._windStartTime or windStartTime)
	local value5 = value3.strength or 0
	local value6 = math.sin(value4 * 0.157 + (value3.phaseOffset1 or 0))
	local value7 = math.sin(value4 * 0.898 + (value3.phaseOffset2 or 0))
	local value8 = 0.5 + 0.3 * value6 + 0.2 * value7
	local value9 = value5 * math.max(0, math.min(1, value8))

	if value3.kind == 1 then
		return -value * value9, -value * value9
	end

	return value * value9, -value * value9
end

local function callback7(self)
	for itemId, item in pairs(items3) do
		if type(item) == "number" and type(self[itemId]) ~= "number" then
			self[itemId] = tonumber(self[itemId]) or item
		end
	end
end

local function callback8()
	local items4 = {}

	for itemId, item in pairs(items3) do
		items4[itemId] = item
	end

	local number2 = def.weatherSnow

	if type(number2) == "table" then
		for itemId2, item2 in pairs(number2) do
			items4[itemId2] = item2
		end

		local layerOpacity = tonumber(number2.snowOpacity)

		if layerOpacity then
			items4.layerOpacity = layerOpacity
			items4.emitterOpacity = layerOpacity
		end
	end

	callback7(items4)

	return items4
end

local function callback9(self, value3)
	if not self or self == "" then
		return false
	end

	for _, item in ipairs(value3) do
		if item ~= "" and string.find(self, item, 1, true) then
			return true
		end
	end

	return false
end

local function callback10(self)
	if type(self) ~= "table" then
		return false
	end

	for _ in pairs(self) do
		return true
	end

	return false
end

local function callback11()
	local items4 = {}

	local function callback(mapIdWhitelist)
		if type(mapIdWhitelist) ~= "table" then
			return
		end

		if mapIdWhitelist.mapIdWhitelist ~= nil then
			items4.mapIdWhitelist = mapIdWhitelist.mapIdWhitelist
		end

		if mapIdWhitelist.mapIdBlacklist ~= nil then
			items4.mapIdBlacklist = mapIdWhitelist.mapIdBlacklist
		end

		if mapIdWhitelist.caveTitlePatterns ~= nil then
			items4.caveTitlePatterns = mapIdWhitelist.caveTitlePatterns
		end
	end

	callback(def.weatherSnow)
	callback(def.natureWeather)

	return items4
end

function weatherSnow:shouldShowSnow()
	if not self then
		return false
	end

	if not def.openClientSnow and not def.openNatureWeather then
		return false
	end

	local value3 = callback11()
	local text = tostring(self.mapid or "")
	local value4 = g_data and g_data.map and g_data.map.mapTitle or ""

	if value3.mapIdBlacklist and (value3.mapIdBlacklist[text] or value4 ~= "" and value3.mapIdBlacklist[value4]) then
		return false
	end

	local value5 = value3.caveTitlePatterns

	if not value5 and callback8().caveTitlePatterns then
		value5 = callback8().caveTitlePatterns
	end

	if callback9(value4, value5 or {}) then
		return false
	end

	if callback10(value3.mapIdWhitelist) then
		return value3.mapIdWhitelist[text] == true or value4 ~= "" and value3.mapIdWhitelist[value4] == true
	end

	return true
end

local items = {}
local number = 64

local function cleanup()
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

local function cleanup2(node)
	if node and not tolua.isnull(node) then
		local value3 = #items < number

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

function weatherSnow:stopForMap()
	if not self then
		return
	end

	local value3 = self._weatherSnowWS

	if value3 and value3.splashEmitters then
		for _, splashEmitter in ipairs(value3.splashEmitters) do
			cleanup2(splashEmitter)
		end
	end

	if value3 and value3.layer and not tolua.isnull(value3.layer) then
		value3.layer:removeSelf()
	end

	self._weatherSnowWS = nil

	if self.weatherlayer then
		self.weatherlayer = nil
	end
end

local function callback12(node, emitterOpacityOwner)
	if node.setOpacity then
		node:setOpacity(math.min(255, math.max(0, math.floor(emitterOpacityOwner.emitterOpacity or 255))))
	end
end

local function callback13(self, value3)
	if self.setBlendAdditive then
		self:setBlendAdditive(false)
	end

	if gl and self.setBlendFunc then
		self:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	end
end

local function callback14(self)
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

	if self.setPositionType then
		self:setPositionType(value2)
	end
end

local function callback15(self, value3, y)
	local items4 = {}

	if y.snowGroundSplash == false then
		return items4
	end

	if not cc.ParticleSystemQuad or not cc.ParticleSystemQuad.createWithTotalParticles then
		return items4
	end

	local value4 = math.max(3, math.floor(y.snowSplashSlots or 8))
	local value5 = -(display.height or 1136) * (y.snowGroundLineRatio or 0.62)
	local value6 = (display.width or 960) * 0.48

	for index = 1, value4 do
		local value7 = ((index - 0.5) / value4 - 0.5) * 2 * value6 + (math.random() - 0.5) * 36
		local value8 = callback2(y.snowSplashParticles or 12)
		local node = cleanup()

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

			node:setPosition(value7, value5 + math.random(-6, 6))
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

			callback14(node)
			node:setPosition(value7, value5 + math.random(-6, 6))
			node:add2(self)
		end

		node:setLife(y.snowSplashLife or 0.2)

		if node.setLifeVar then
			node:setLifeVar(y.snowSplashLifeVar or 0.06)
		end

		if node.setSpeed then
			node:setSpeed(y.snowSplashSpeed or 12)
		end

		if node.setSpeedVar then
			node:setSpeedVar(y.snowSplashSpeedVar or 10)
		end

		if node.setAngle then
			node:setAngle(y.snowSplashAngle or 85)
		end

		if node.setAngleVar then
			node:setAngleVar(y.snowSplashAngleVar or 65)
		end

		node:setGravity(cc.p(0, y.snowSplashGravityY or -90))

		if node.setStartSize then
			node:setStartSize(2)
		end

		if node.setStartSizeVar then
			node:setStartSizeVar(1)
		end

		if node.setEndSize then
			node:setEndSize(0.2)
		end

		if node.setEmissionRate then
			node:setEmissionRate(y.snowSplashEmission or 26)
		end

		node:setDuration(-1)

		if node.setOpacity then
			node:setOpacity(210)
		end

		if gl and node.setBlendFunc then
			node:setBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
		end

		node:setLocalZOrder((y.emitterLocalZ or 9999) + 2)

		items4[#items4 + 1] = node
	end

	return items4
end

function weatherSnow:startForMap()
	if not self or not weatherSnow.shouldShowSnow(self) then
		return
	end

	weatherSnow.stopForMap(self)

	local cfg = callback8()
	local weatherlayer = display.newNode():addto(self, cfg.layerZOrder):anchor(0.5, 1)

	if main_scene and not tolua.isnull(main_scene) then
		local value3 = cfg.screenAnchorOffsetY or 120
		local point = cc.p(display.cx, display.top + value3)
		local value4 = main_scene:convertToWorldSpace(point)
		local point2 = self:convertToNodeSpace(value4)

		weatherlayer:setPosition(math.floor(point2.x + 0.5), math.floor(point2.y + 0.5))
	end

	if weatherlayer.setOpacity then
		weatherlayer:setOpacity(math.min(255, math.max(0, math.floor(cfg.layerOpacity or 255))))
	end

	local emitters = {}
	local value5 = math.max(1, math.floor(callback2(cfg.particleGroups)))
	local value6 = math.max(20, math.floor(callback2(cfg.particlesPerGroup)))

	if not cc.ParticleSnow or not cc.ParticleSnow.createWithTotalParticles then
		print("[weatherSnow] cc.ParticleSnow 不可用，请确认引擎是否编译粒子模块")
		weatherlayer:removeSelf()

		return
	end

	local value7 = (display.width or 960) * 0.45
	local x = (display.width or 960) * 2
	local y = (display.height or 1136) * 0.5

	for index = 1, value5 do
		local node = cc.ParticleSnow:createWithTotalParticles(value6)

		if not node then
			print("[weatherSnow] ParticleSnow:createWithTotalParticles 失败")

			break
		end

		callback14(node)
		node:setPosition(cc.p((math.random() - 0.5) * 2 * value7 + math.random(-50, 50), -math.random(0, 160)))

		if node.setPosVar then
			node:setPosVar(cc.p(x, y))
		end

		node:setLocalZOrder(cfg.emitterLocalZ)

		local value8 = cfg.lifeMin or 2
		local value9 = cfg.lifeMax or 4

		if value9 < value8 then
			value8, value9 = value9, value8
		end

		node:setLife(value8 + math.random() * math.max(0.05, value9 - value8))

		if node.setSpeed then
			node:setSpeed(math.random(20, 55))
		end

		if node.setSpeedVar then
			node:setSpeedVar(18)
		end

		if node.setAngle then
			node:setAngle(-90)
		end

		if node.setAngleVar then
			node:setAngleVar(25)
		end

		node:setGravity(cc.p(cfg.baseGravityX, cfg.baseGravityY))
		node:setStartSize(math.random(cfg.startSizeMin, cfg.startSizeMax))
		node:setDuration(-1)
		node:setStartSizeVar(math.random(cfg.startSizeVarMin, cfg.startSizeVarMax))
		node:setAutoRemoveOnFinish(false)
		callback12(node, cfg)

		if cfg.softBlur then
			callback13(node, cfg)
		end

		node:add2(weatherlayer)

		emitters[#emitters + 1] = node
	end

	if #emitters == 0 then
		weatherlayer:removeSelf()

		return
	end

	local texture

	for _, item in ipairs(emitters) do
		if item.getTexture then
			texture = item:getTexture()

			break
		end
	end

	local splashEmitters = callback15(weatherlayer, texture, cfg)

	self.weatherlayer = weatherlayer
	self._weatherSnowWS = {
		layer = weatherlayer,
		emitters = emitters,
		splashEmitters = splashEmitters,
		cfg = cfg
	}

	if not def.openNatureWeather and not weatherSnow._sched and scheduler and scheduler.scheduleUpdateGlobal and handler then
		weatherSnow._sched = scheduler.scheduleUpdateGlobal(handler(weatherSnow, weatherSnow._tick))
	end
end

function weatherSnow:tickMapWeather(deltaTime)
	if not self or tolua.isnull(self) then
		return
	end

	local value3 = self._weatherSnowWS

	if not value3 or not value3.emitters then
		return
	end

	local value4 = value3.cfg or callback8()

	if value3.layer and main_scene and not tolua.isnull(main_scene) and not tolua.isnull(value3.layer) then
		local value5 = value4.screenAnchorOffsetY or 120
		local point = cc.p(display.cx, display.top + value5)
		local value6 = main_scene:convertToWorldSpace(point)
		local point2 = self:convertToNodeSpace(value6)
		local position, position2 = value3.layer:getPosition()
		local value7 = point2.x - position
		local value8 = point2.y - position2
		local value9 = (display.width or 960) * 1.5

		if value7 * value7 + value8 * value8 > value9 * value9 then
			weatherSnow.startForMap(self)

			return
		end
	end

	local x = value4.baseGravityX
	local y = value4.baseGravityY
	local x2, value10 = callback6(value4)

	for _, emitter in ipairs(value3.emitters) do
		if emitter and not tolua.isnull(emitter) and emitter.setGravity then
			emitter:setGravity(cc.p(x + x2, y + value10))
		end
	end

	local y2 = value4.snowSplashGravityY or -90

	for _2, item in ipairs(value3.splashEmitters or {}) do
		if item and not tolua.isnull(item) and item.setGravity then
			item:setGravity(cc.p(x2, y2 + value10))
		end
	end
end

function weatherSnow:_tick()
	if def.openNatureWeather then
		return
	end

	if not main_scene or tolua.isnull(main_scene) then
		return
	end

	local mapOwner = main_scene.ground

	if not mapOwner or tolua.isnull(mapOwner) then
		return
	end

	weatherSnow.tickMapWeather(mapOwner.map, self)
end

function weatherSnow:syncMap()
	if not self then
		return
	end

	if def.openNatureWeather then
		return
	end

	if not def.openClientSnow then
		weatherSnow.stopForMap(self)

		return
	end

	if weatherSnow.shouldShowSnow(self) then
		if self._weatherSnowWS then
			return
		end

		weatherSnow.startForMap(self)
	else
		weatherSnow.stopForMap(self)
	end
end

function weatherSnow.syncCurrentMap()
	if not main_scene or tolua.isnull(main_scene) then
		return
	end

	local mapOwner = main_scene.ground

	if not mapOwner or tolua.isnull(mapOwner) then
		return
	end

	if mapOwner.map and not tolua.isnull(mapOwner.map) then
		weatherSnow.syncMap(mapOwner.map)
	end
end

function weatherSnow:onMapCreated()
	if not self or tolua.isnull(self) then
		return
	end

	weatherSnow.syncMap(self)

	if not scheduler or not scheduler.performWithDelayGlobal then
		return
	end

	scheduler.performWithDelayGlobal(function()
		if main_scene and not tolua.isnull(main_scene) and main_scene.ground and not tolua.isnull(main_scene.ground) and main_scene.ground.map == self then
			weatherSnow.syncMap(self)
		end
	end, 0.22)
	scheduler.performWithDelayGlobal(function()
		if main_scene and not tolua.isnull(main_scene) and main_scene.ground and not tolua.isnull(main_scene.ground) and main_scene.ground.map == self then
			weatherSnow.syncMap(self)
		end
	end, 0.55)
end

function weatherSnow:getNaturalWindDelta()
	return callback6(self or callback8())
end

function weatherSnow.shutdown()
	if weatherSnow._sched and scheduler and scheduler.unscheduleGlobal then
		pcall(scheduler.unscheduleGlobal, weatherSnow._sched)
	end

	weatherSnow._sched = nil
end

return weatherSnow
