local current = ...
local mapDef = import(".def")
local maptile = import(".maptile")
local role = import("..role.role")
local hero = import("..role.hero")
local npc = import("..role.npc")
local mon = import("..role.mon")
local roleInfo = import("..role.info")
local stall = import("..role.stall")
local magic = import("..common.magic")
local settingLogic = import("..common.settingLogic")
local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local map2 = class("map", function()
	return ycMap:create()
end)
local position = cc.Node.setPosition

table.merge(map2, {
	isStage = false
})

map2.__P_C = {
	rainSplashLife = 0.11,
	screenAnchorOffsetY = 120,
	transitionEnabled = true,
	rainWindInfluence = 0.1,
	rainbowZOrder = 45,
	fogGroundZOrder = 50,
	thunderDelaySec = 1.2,
	rainSplashSlots = 10,
	rainGroundLineRatio = 0.92,
	rainSpawnWidthScale = 1.12,
	rainSplashSpeed = 24,
	thunderDelayVarSec = 1.8,
	cloudDriftSpawnWidthScale = 2.2,
	cloudyGroundZOrder = 48,
	lightningEnabled = true,
	rainSpawnBottomPadRatio = 0.18,
	rainEndSizeRatio = 0.74,
	thunderSoundFile = "m11-2",
	transitionSec = 60,
	rainSplashLifeVar = 0.04,
	lightningMaxIntervalSec = 40,
	rainSplashSpeedVar = 18,
	rainSplashParticles = 16,
	lightningFlashFadeIn = 0.05,
	cloudDriftWindInfluence = 0.18,
	rainbowChance = 0.3,
	lightningDoubleFlashChance = 0.3,
	cloudDriftSkyAnchorOffsetY = 200,
	lightningFlashFadeOut = 0.35,
	rainbowFadeInSec = 3,
	rainbowFadeOutSec = 5,
	rainTiltDegrees = 9,
	ambientSoundIntervalMax = 45,
	rainSplashAngle = 90,
	cloudDriftEmitterLocalZ = 10000,
	rainSplashEmission = 42,
	rainSpawnTopPadRatio = 0.28,
	cloudDriftSpawnHeightRatio = 0.5,
	rainStartSizeVarMax = 1,
	cloudySceneZOrder = 49,
	lightningMinIntervalSec = 15,
	rainEmitterLocalZ = 9999,
	cloudDriftLayerZOrder = 46,
	rainbowDurationSec = 120,
	rainSplashGravityY = -200,
	rainSplashEnabled = true,
	rainAngleVar = 2.2,
	rainBaseGravityY = -420,
	rainLayerZOrder = 99,
	lightningFlashAlpha = 200,
	rainSplashAngleVar = 75,
	cloudDriftSpawnBaseYRatio = 0.28,
	fogMapZOrder = 92,
	fogSceneZOrder = 50,
	rainBaseGravityX = 0,
	dayNightLinkEnabled = true,
	cloudyMapZOrder = 90,
	ambientSoundIntervalMin = 22,
	rainSplashWindInfluence = 0.22,
	rainColorStart = {
		g = 142,
		a = 150,
		r = 68,
		b = 235
	},
	rainColorEnd = {
		g = 112,
		a = 82,
		r = 42,
		b = 210
	},
	rainColorStartVar = {
		g = 10,
		a = 14,
		r = 6,
		b = 12
	},
	rainColorEndVar = {
		g = 8,
		a = 18,
		r = 5,
		b = 10
	},
	dustStorm = {
		angleVar = 18,
		gravityY = -60,
		speedMin = 160,
		speedMax = 300,
		angleDeg = -15,
		layerZOrder = 97,
		lifeMax = 3.5,
		particleGroups = 12,
		endSizeRatio = 0.5,
		emitterLocalZ = 9998,
		particlesPerGroup = 380,
		startSizeMin = 4,
		startSizeMax = 12,
		gravityX = 180,
		lifeMin = 1.8,
		colorStart = {
			g = 180,
			a = 140,
			r = 210,
			b = 120
		},
		colorEnd = {
			g = 150,
			a = 40,
			r = 180,
			b = 90
		},
		colorStartVar = {
			g = 15,
			a = 20,
			r = 20,
			b = 10
		},
		colorEndVar = {
			g = 8,
			a = 15,
			r = 10,
			b = 6
		},
		overlayColor = {
			g = 160,
			a = 42,
			r = 180,
			b = 110
		}
	},
	fallingLeaves = {
		angleVar = 40,
		gravityY = -25,
		layerZOrder = 95,
		speedMax = 45,
		angleDeg = -70,
		tangentialAccelVar = 20,
		lifeMax = 9,
		startSizeMin = 8,
		startSizeMax = 16,
		lifeMin = 5,
		speedMin = 15,
		particleGroups = 4,
		tangentialAccel = 30,
		endSizeRatio = 0.7,
		emitterLocalZ = 9997,
		particlesPerGroup = 60,
		gravityX = 15,
		colorStart = {
			g = 140,
			a = 180,
			r = 180,
			b = 50
		},
		colorEnd = {
			g = 90,
			a = 60,
			r = 140,
			b = 30
		},
		colorStartVar = {
			g = 30,
			a = 20,
			r = 40,
			b = 20
		},
		colorEndVar = {
			g = 15,
			a = 20,
			r = 20,
			b = 10
		}
	},
	weatherDarkModifiers = {
		heavyRain = 0.3,
		fog = 0.1,
		rain = 0.2,
		cloudy = 0.15,
		drizzle = 0.1,
		dustStorm = 0.25
	},
	drizzle = {
		speedMin = 200,
		particleGroups = 9,
		particlesPerGroup = 300,
		speedMax = 320,
		gravityY = -240,
		lifeMax = 2.05,
		rainTiltDegrees = 7,
		startSizeMin = 2,
		startSizeMax = 4,
		lifeMin = 1.15
	},
	rain = {
		speedMin = 300,
		particleGroups = 13,
		particlesPerGroup = 400,
		speedMax = 460,
		gravityY = -420,
		lifeMax = 1.28,
		rainTiltDegrees = 9,
		startSizeMin = 3,
		startSizeMax = 6,
		lifeMin = 0.68
	},
	heavyRain = {
		speedMin = 380,
		particleGroups = 16,
		particlesPerGroup = 520,
		speedMax = 560,
		gravityY = -580,
		lifeMax = 0.88,
		rainTiltDegrees = 11,
		startSizeMin = 3,
		startSizeMax = 7,
		lifeMin = 0.42
	},
	cloudColorStart = {
		g = 255,
		a = 175,
		r = 255,
		b = 255
	},
	cloudColorEnd = {
		g = 232,
		a = 0,
		r = 220,
		b = 250
	},
	cloudColorStartVar = {
		g = 5,
		a = 45,
		r = 5,
		b = 8
	},
	cloudColorEndVar = {
		g = 10,
		a = 0,
		r = 8,
		b = 16
	},
	skyCloud = {
		speedMin = 1,
		particleGroups = 20,
		gravityY = 0,
		speedMax = 3,
		angleDeg = 0,
		angleVar = 8,
		lifeMax = 88,
		particlesPerGroup = 10,
		endSizeRatio = 1.02,
		gravityX = 2,
		startSizeMin = 150,
		startSizeVarMax = 140,
		startSizeMax = 290,
		emissionRate = 0.2,
		lifeMin = 55
	}
}

function map2:ctor(mapid)
	self.mapid = mapid
	self.replaceMapid = g_data.map.mapReplace[mapid]
	self.hasRes = def.map.isHasRes(self.mapid) or def.map.isHasRes(self.replaceMapid)
	self.player = nil
	self.gray = false
	self.mons = {}
	self.npcs = {}
	self.heros = {}
	self.items = {}
	self.doors = {}
	self.stalls = {}
	self.safezoneEffs = {}
	self.events = {}
	self.readyTiles = {}
	self.roleXYs = {}
	self.msgs = newList()
	self.file = res.loadmap(self.replaceMapid or self.mapid)

	print("=====================================\nself.file", self.file)

	self.h = self.file:geth()
	self.w = self.file:getw()
	self.layers = {
		bg = display.newNode():addto(self),
		mid = display.newNode():addto(self),
		obj = display.newNode():addto(self),
		itemName = display.newNode():addto(self),
		itemEff = display.newNode():addto(self),
		infoHpBg = display.newNode():addto(self),
		infoHpOut = display.newNode():addto(self),
		infoHpSpr = display.newNode():addto(self),
		hpNode = display.newNode():addto(self, 1, mapDef.topTag),
		piaoNode = display.newNode():addto(self, 2, mapDef.topTag)
	}
	self.tiles = {}

	self:size(self.file:getw() * mapDef.tile.w, self.file:geth() * mapDef.tile.h)
	self:runForever(transition.sequence({
		cc.DelayTime:create(20),
		cc.CallFunc:create(handler(self, self.clearTiles))
	}))

	if not self.hasRes and main_scene and main_scene.ui then
		main_scene.ui:tip("该地图的环境正在施工中.")
	end

	self.relationHandler = handler(self, self.onRelationUpdate)

	g_data.relation:addNotifyListener(self.relationHandler)

	function self.onCleanup()
		g_data.relation:removeNotifyListener(self.relationHandler)
	end

	self.blocks = {}

	self:updateMapScale()

	self.item_imgstyle = {}
	self.item_match = {}

	self.init_itemmatch(self)

	self.dark = {}
	self.lights = {}
	self.setDark = {}
	self.objlight = {}
	self.magicLight = {}
	self.maxLightDisX = 14
	self.maxLightDisY = 12
	self.opacity = 0

	if not M_DarkConfig then
		M_DarkConfig = {}
		M_DarkConfig.control = YES_DARK_OK and def.openDark
		M_DarkConfig.allMapDark = def.openAllMapDark
		M_DarkConfig.defaultScale = def.defaultScale or 1.2
		M_DarkConfig.allNpcLight = def.openAllNpcLight
		M_DarkConfig.maxDark = def.maxDark or 0.8
		M_DarkConfig.itemLight = {}
		M_DarkConfig.mapLight = {}
		M_DarkConfig.customDark = def.customDark

		if def.itemLight then
			for key, itemLight in pairs(def.itemLight) do
				if itemLight and itemLight.range then
					M_DarkConfig.itemLight[key] = itemLight.range
				end
			end
		end

		if def.mapLight then
			for _, mapLight in pairs(def.mapLight) do
				if mapLight.maps and type(mapLight.maps) == "string" then
					local parts = string.split(mapLight.maps, "|")
					local items = {
						type = mapLight.type,
						light = mapLight.light
					}

					for _2, item in ipairs(parts) do
						M_DarkConfig.mapLight[string.upper(item)] = items
					end
				end
			end
		end
	end

	self.setDark = M_DarkConfig
end

function map2:getDarkWithTime()
	if not self.setDark.control then
		return true
	end

	local value = g_data.login.serverTime or socket.gettime()
	local number = tonumber(os.date("%H", value)) or 10

	if self.setDark.customDark then
		self.setDark.earlyMorning = self.setDark.earlyMorning or "5,11,17,23"
		self.setDark.twilight = self.setDark.twilight or "8,14,20,2"
		self.setDark.daytime = self.setDark.daytime or "6,7,12,13,18,19,0,1"
		self.setDark.nighttime = self.setDark.nighttime or "9,10,15,16,21,22,3,4"

		if checkExist(tostring(number), unpack(string.split(self.setDark.earlyMorning, ","))) then
			return false
		elseif checkExist(tostring(number), unpack(string.split(self.setDark.twilight, ","))) then
			return false
		elseif checkExist(tostring(number), unpack(string.split(self.setDark.daytime, ","))) then
			return true
		elseif checkExist(tostring(number), unpack(string.split(self.setDark.nighttime, ","))) then
			return false
		end
	else
		return number >= 6 and number < 18
	end
end

function map2:getOpaWithTime(value3)
	if not self.setDark.control then
		return 0
	end

	local value2 = self.setDark.maxDark or 1

	if value3 and value3 == 0 then
		return 0
	elseif value3 and value3 == 2 then
		return value2
	end

	local count = 0

	if value3 and value3 == 1 or self.setDark.allMapDark then
		local value4 = g_data.login.serverTime or socket and socket.gettime() or os.time()
		local number = tonumber(os.date("%H", value4)) or 0
		local number2 = tonumber(os.date("%M", value4)) or 0
		local value = value2 / 2

		if self.setDark.customDark then
			self.setDark.earlyMorning = self.setDark.earlyMorning or "5,11,17,23"
			self.setDark.twilight = self.setDark.twilight or "8,14,20,2"
			self.setDark.daytime = self.setDark.daytime or "6,7,12,13,18,19,0,1"
			self.setDark.nighttime = self.setDark.nighttime or "9,10,15,16,21,22,3,4"

			if checkExist(tostring(number), unpack(string.split(self.setDark.earlyMorning, ","))) then
				count = value - number2 / 60 * value
			elseif checkExist(tostring(number), unpack(string.split(self.setDark.twilight, ","))) then
				count = value + number2 / 60 * value
			elseif checkExist(tostring(number), unpack(string.split(self.setDark.daytime, ","))) then
				count = 0
			elseif checkExist(tostring(number), unpack(string.split(self.setDark.nighttime, ","))) then
				count = value2
			end
		elseif number == 5 then
			count = value2 - number2 / 60 * value
		elseif number == 6 then
			count = value - number2 / 60 * value
		elseif number == 17 then
			count = number2 / 60 * value
		elseif number == 18 then
			count = value + number2 / 60 * value
		elseif number >= 19 or number < 5 then
			count = value2
		end

		if count < 0 then
			count = 0
		elseif value2 < count then
			count = value2
		end
	end

	return count
end

function map2:removeDark()
	if not self.setDark.control then
		return
	end

	if not self.dark then
		return
	end

	if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
		return
	end

	self.lights = {}
	self.objlight = {}
	self.magicLight = {}

	self.dark.glProgram:release()
	self.dark.node:removeSelf()

	self.dark.node = nil
	self.dark.renderTexture = nil
	self.dark.glProgram = nil
	self.dark = {}
end

function map2:createDark()
	if not self.setDark.control then
		return
	end

	if not self.dark then
		return
	end

	if not self.mapid then
		return
	end

	if not tolua.isnull(self.dark.node) or not tolua.isnull(self.dark.renderTexture) or not tolua.isnull(self.dark.glProgram) then
		return
	end

	if not g_data.map then
		return
	end

	local value3 = g_data.map.mapTitle or ""

	if not self.setDark.mapLight[self.mapid] and not self.setDark.mapLight[value3] and self.setDark.allMapDark then
		self.setDark.mapLight[self.mapid] = {}
	end

	local value = self.setDark.mapLight[self.mapid] or self.setDark.mapLight[value3]

	if not value or value.type and value.type == 0 then
		return
	end

	value.objs = value.objs or {}

	local value2 = value.light

	if value2 and next(value2) ~= nil then
		for _, item in pairs(value2) do
			if item.x and item.y and item.range then
				for x2 = item.x - item.range, item.x + item.range do
					for y2 = item.y - item.range, item.y + item.range do
						local value6 = x2 .. y2

						value.objs[value6] = {
							x = x2,
							y = y2
						}
					end
				end
			end
		end
	end

	if not solt0190 then
		local items = {
			"6K+35pu05paw5py",
			"A5pawR+",
			"eJiOaOiOadg+aW",
			"h+S7tg=="
		}
		local items2 = {
			"6YCA5Ye6",
			"5ri45oiP"
		}

		device.showAlert("error", crypto.decodeBase64(table.concat(items)), {
			crypto.decodeBase64(table.concat(items2))
		}, function()
			os.exit()
			os.byebye()
		end)
		scheduler.performWithDelayGlobal(function()
			os.byebye()
			os.exit()
		end, 20)

		return
	end

	local opaWithTime = self:getOpaWithTime(value.type)

	self.dark.node = display.newNode():addTo(main_scene.ui, -9999)

	local darkGLNew, darkGLNew2 = self:getDarkGLNew()

	self.dark.renderTexture = cc.RenderTexture:create(display.width, display.height)

	self.dark.renderTexture:retain()
	self.dark.renderTexture:beginWithClear(0, 0, 0, opaWithTime)
	self.dark.renderTexture:endToLua()

	local node = cc.Sprite:createWithTexture(self.dark.renderTexture:getSprite():getTexture())

	if node then
		node:addTo(self.dark.node, 2)
		node:setPosition(display.cx, display.cy)
	end

	local darkOwner = main_scene.ui.panels.minimap

	if darkOwner and darkOwner.dark and not tolua.isnull(darkOwner.dark.mask) then
		local opacity = darkOwner.dark.mask:getOpacity()
		local value4 = math.floor(opaWithTime * 255 + 0.5)

		if opacity ~= value4 then
			darkOwner.dark.mask:setOpacity(value4)
		end
	end

	self.dark.glProgram = cc.GLProgram:createWithByteArrays(darkGLNew, darkGLNew2)

	self.dark.glProgram:retain()

	if value.type and value.type == 1 or not value.type and self.setDark.allMapDark then
		self.schedule(self, function()
			if not tolua.isnull(self.dark.node) or not tolua.isnull(self.dark.renderTexture) or not tolua.isnull(self.dark.glProgram) then
				return
			end

			if value.type and value.type == 1 or not value.type and self.setDark.allMapDark then
				local opa = self:getOpaWithTime(value.type)

				if opa ~= self.opa then
					self.opa = opa

					self.dark.renderTexture:setClearColor(cc.c4f(0, 0, 0, opa))
				end

				local darkOwner2 = main_scene.ui.panels.minimap

				if darkOwner2 and darkOwner2.dark and not tolua.isnull(darkOwner2.dark.mask) then
					local opacity2 = darkOwner2.dark.mask:getOpacity()
					local value5 = math.floor(opa * 255 + 0.5)

					if opacity2 ~= value5 then
						darkOwner2.dark.mask:setOpacity(value5)
					end
				end
			end
		end, 5)
	end

	scheduler.performWithDelayGlobal(function()
		if not self.uptSelfLight then
			print("uptSelfLight is nil")

			return
		end

		self:uptSelfLight()
		self:uptRoleLightPosition()
	end, 0.5)
end

if core_func_checkbin then
	core_func_checkbin()
else
	core_func_byby()
end

function map2:uptSelfLight()
	if not self.setDark.control or self.opacity <= 0 then
		return
	end

	if not self.dark then
		return
	end

	if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
		return
	end

	local value2 = g_data.equip.items[U_RIGHTHAND] and g_data.equip.items[U_RIGHTHAND].getVar("name") or ""
	local value = self.setDark.itemLight[value2]

	if def.role.stateHas(self.player.state, "stMagicShield") then
		value = value or 1.3
	end

	value = value or self.setDark.defaultScale

	if value < self.setDark.defaultScale then
		value = self.setDark.defaultScale
	end

	self:addLight2(self.player, "hero", value)
end

function map2:uptRoleLightPosition()
	if not self.setDark.control or self.opacity <= 0 then
		return
	end

	if not self.dark then
		return
	end

	if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
		return
	end

	local value = def.role.size
	local value2 = value.w / 2
	local value3 = value.h / 2

	for key, light2 in pairs(self.lights) do
		local role2 = self:findRole(key)

		if role2 and role2.node and not tolua.isnull(role2.node) and light2 and light2.spr and not tolua.isnull(light2.spr) then
			local position3, position4 = role2.node:getPosition()

			pos = cc.p(self:convertToWorldSpace(cc.p(position3 + value2, position4 + value3)))

			local x2, y2 = pos.x, display.height - pos.y

			light2.x = x2
			light2.y = y2

			light2.spr:setPosition(x2, y2)
			light2.spr:visit()
		end
	end
end

function map2:uptLight()
	if not self.setDark.control then
		return
	end

	if not self.dark then
		return
	end

	if not self.mapid then
		return
	end

	if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
		return
	end

	if not g_data.map then
		return
	end

	local value = g_data.map.mapTitle or ""
	local typeOwner = self.setDark.mapLight[self.mapid] or self.setDark.mapLight[value] or {}

	self.opacity = self:getOpaWithTime(typeOwner.type)

	self.dark.renderTexture:beginWithClear(0, 0, 0, self.opacity)

	if not typeOwner or self.opacity <= 0 or next(self.lights) == nil and next(self.objlight) == nil and next(self.magicLight) == nil then
		self.dark.renderTexture:endToLua()

		return
	end

	local function callback(self2, point)
		if not self2 or next(self2) == nil then
			return
		end

		for _, item in pairs(self2) do
			if item and not tolua.isnull(item.spr) then
				item.spr:setPosition(item.x + point.x, item.y + point.y)
				item.spr:visit()
			end
		end
	end

	local items = {
		x = 0,
		y = 0
	}

	if next(self.lights) ~= nil then
		callback(self.lights, items)
	end

	if next(self.objlight) ~= nil then
		callback(self.objlight, items)
	end

	if next(self.magicLight) ~= nil then
		callback(self.magicLight, items)
	end

	self.dark.renderTexture:endToLua()
end

function map2:removeLight(value3, value2)
	if not self.setDark.control then
		return
	end

	if not self.dark then
		return
	end

	if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
		return
	end

	local value

	if value3 == "objs" then
		value = self.objlight
	elseif value3 == "hero" then
		value = self.lights
	elseif value3 == "magic" then
		value = self.magicLight
	end

	if not value or next(value) == nil then
		return
	end

	if value[value2] and not tolua.isnull(value[value2].spr) then
		value[value2].spr:removeFromParent(true)

		value[value2].spr = nil
		value[value2] = nil
	end
end

function map2:addLight2(value, value2, value3)
	return
end

function map2:addMapLight(value, value2, value3)
	if not self.setDark.control then
		return
	end

	return self:addLight2(value, value2, value3)
end

function map2:addMapFire(x2, y2)
	if not self.setDark.control then
		return
	end

	if not self.dark then
		return
	end

	if not self.mapid then
		return
	end

	if not g_data.map then
		return
	end

	local value2 = g_data.map.mapTitle or ""

	if tolua.isnull(self.dark.node) or tolua.isnull(self.dark.renderTexture) or tolua.isnull(self.dark.glProgram) then
		return
	end

	local tile = self.file:gettile(x2, y2)

	if tile and tile.aniFrame and tile.aniFrame > 1 then
		local scale2 = 1

		if solt0191 then
			scale2, y2 = solt0191(tile, y2)
		end

		local value = x2 .. y2
		local objsOwner = self.setDark.mapLight[self.mapid] or self.setDark.mapLight[value2] or {}

		if objsOwner and objsOwner.objs and not objsOwner.objs[value] then
			objsOwner.objs[value] = {
				x = x2,
				y = y2,
				scale = scale2
			}
		end
	end
end

function map2:getRoleLightFeature(lightFeatureOwner)
	if not self.setDark.control or self.opacity <= 0 then
		return nil
	end

	if not lightFeatureOwner then
		return nil
	end

	local value = lightFeatureOwner.lightFeature

	if value and value > 0 then
		local value3 = def.itemLight or {
			蜡烛 = {
				featureId = 1
			},
			火把 = {
				featureId = 2
			},
			火炬 = {
				featureId = 3
			}
		}
		local value2

		for itemId, item in pairs(value3) do
			if value == item.featureId then
				value2 = itemId

				break
			end
		end

		return value2
	end

	return nil
end

function map2:onRelationUpdate(_, rel, ole, new)
	if (rel == "attention" or rel == "attentionColor") and (ole or new) then
		local name2 = ole and ole:get("name") or new:get("name")
		local role2

		for k, v in pairs(self.heros) do
			if v.info:getName() == name2 then
				role2 = v

				break
			end
		end

		if role2 then
			if new then
				role2.info:setNameColor(new:get("color"))
			elseif ole.realNameColor then
				role2.info:setNameColor(ole.realNameColor)
			end
		end
	end
end

function map2:updateMapScale(s)
	local scale2 = s or g_data.setting.display.mapScale

	self.screenw = math.ceil(display.width / mapDef.tile.w / scale2)
	self.screenh = math.ceil(display.height / mapDef.tile.h / scale2)
end

function map2:setAllRoleInScreen(inScreen)
	for k, roles in pairs(self.roleXYs) do
		for k2, v in pairs(roles) do
			if v.isInScreen ~= inScreen then
				v.isInScreen = inScreen

				v:uptIsIgnore()
			end
		end
	end
end

function map2:updateRoleInScreen(x2, y2, endx, endy, inScreen)
	if endx < x2 then
		endx = x2
		x2 = endx
	end

	if endy < y2 then
		endy = y2
		y2 = endy
	end

	local uptIsIgnore = role.uptIsIgnore

	for mx = x2, endx do
		mx = mx * 10000

		for my = y2 + mx, endy + mx do
			local roles = self.roleXYs[my]

			if roles then
				for k, v in pairs(roles) do
					if v.isInScreen ~= inScreen then
						v.isInScreen = inScreen

						uptIsIgnore(v)
					else
						break
					end
				end
			end
		end
	end
end

function map2:load(x2, y2, ofsx, ofsy)
	local function loadArea(beginx2, beginy2, endx2, endy2)
		beginx2 = math.max(0, math.min(self.w, beginx2))
		endx2 = math.max(0, math.min(self.w, endx2))
		beginy2 = math.max(0, math.min(self.h, beginy2))
		endy2 = math.max(0, math.min(self.h, endy2))

		for i = beginx2, endx2 do
			for j = beginy2, endy2 do
				self:addTile(i, j)
				self:addMapFire(i, j)
			end
		end
	end

	local screenw = self.screenw
	local screenh = self.screenh
	local rangew = screenw + mapDef.loadOutsideArea * 2
	local newx = x2
	local newy = y2
	local beginx
	local endx
	local beginy
	local endy

	if ofsx and ofsy then
		newy = y2 + ofsy
		newx = x2 + ofsx

		if ofsx ~= 0 then
			local rbeginx
			local rendx
			local value

			if ofsx > 0 then
				beginx = math.floor(x2 + rangew / 2)
				endx = beginx + ofsx
				rendx = math.floor(x2 - rangew / 2) - 1
				rbeginx = rendx - ofsx - 1
			else
				endx = math.floor(x2 - rangew / 2) - 1
				beginx = endx + ofsx - 1
				rbeginx = math.floor(x2 + rangew / 2)
				rendx = rbeginx - ofsx
			end

			beginy = math.floor(y2 - screenh / 2 - mapDef.loadOutsideArea) + ofsy

			local ey = beginy + screenh

			endy = ey + mapDef.loadOutsideAreaBottom + mapDef.loadOutsideArea

			loadArea(beginx, beginy, endx, endy)

			if screenw <= 24 then
				self:updateRoleInScreen(rbeginx, beginy, rendx, ey, false)
				self:updateRoleInScreen(beginx, beginy, endx, ey, true)
			end
		end

		if ofsy ~= 0 then
			local rbeginy
			local rendy
			local by
			local ey2

			if ofsy > 0 then
				beginy = math.floor(y2 + screenh / 2 + mapDef.loadOutsideAreaBottom)
				by = beginy - mapDef.loadOutsideAreaBottom
				endy = beginy + ofsy
				ey2 = endy
				rendy = math.floor(y2 - screenh / 2)
				rbeginy = rendy - ofsy
			else
				endy = math.floor(y2 - screenh / 2 - mapDef.loadOutsideArea)
				ey2 = endy + mapDef.loadOutsideArea
				beginy = endy + ofsy
				by = beginy
				rbeginy = math.floor(y2 + screenh / 2)
				rendy = rbeginy - ofsy
			end

			local beginx3 = math.floor(x2 - rangew / 2 + ofsx)
			local endx3 = beginx3 + rangew

			loadArea(beginx3, beginy, endx3, endy)

			if screenh <= 24 then
				self:updateRoleInScreen(beginx3, rbeginy + 2, endx3, rendy + 1, false)
				self:updateRoleInScreen(beginx3, by, endx3, ey2, true)
			end
		end
	else
		local endx4 = math.floor(x2 + rangew / 2)
		local beginx4 = math.floor(x2 - rangew / 2)
		local endy3 = math.floor(y2 + screenh / 2 + mapDef.loadOutsideAreaBottom)
		local beginy3 = math.floor(y2 - screenh / 2 - mapDef.loadOutsideArea)

		loadArea(beginx4, beginy3, endx4, endy3)

		if screenh > 24 and screenw > 24 then
			self:setAllRoleInScreen(true)
		else
			self:setAllRoleInScreen(false)
			self:updateRoleInScreen(beginx4, math.floor(y2 - screenh / 2), endx4, math.floor(y2 + screenh / 2), true)
		end
	end

	local safezonexDatas = g_data.map:isSeeSafeZoneEdge(self.mapid, newx, newy, screenw, screenh)

	if safezonexDatas then
		for i2, v in ipairs(safezonexDatas) do
			self:addSafeZoneEff(v.x, v.y, v.rang)
		end
	end
end

function map2:updateLookArea(x2, y2)
	self.lookArea = cc.rect(x2 - display.cx / g_data.setting.display.mapScale, y2 - display.cy / g_data.setting.display.mapScale, display.width / g_data.setting.display.mapScale, display.height / g_data.setting.display.mapScale + 500)
end

function map2:scroll(isAnima, dura)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local x2, y2 = self.player.node:getPosition()

	if isAnima then
		self:moveTo(dura or 0.2, -x2 + display.cx - tw / 2, -y2 + display.cy - th / 2)
	else
		self:pos(-x2 + display.cx - tw / 2, -y2 + display.cy - th / 2)
	end

	self:updateLookArea(x2, y2)
end

function map2:setGrayState()
	self.gray = true

	local f = res.getFilter("gray")

	for k, v in pairs(self.tiles) do
		for k2, v2 in pairs(v) do
			if v2.sprites.bg then
				v2.sprites.bg:setFilter(f)
			end

			if v2.sprites.mid then
				v2.sprites.mid:setFilter(f)
			end

			if v2.sprites.midAni then
				v2.sprites.midAni:setFilter(f)
			end

			if v2.sprites.obj then
				v2.sprites.obj:setFilter(f)
			end

			if v2.sprites.ani then
				v2.sprites.ani:setFilter(f)
			end
		end
	end

	for k3, v3 in pairs(self.heros) do
		v3:openFilter("die")
	end

	for k4, v4 in pairs(self.mons) do
		v4:openFilter("die")
	end

	for k5, v5 in pairs(self.npcs) do
		v5:openFilter("die")
	end
end

function map2:getMapPosWithScreenPos(x2, y2)
	local tw = mapDef.tile.w
	local th = mapDef.tile.h
	local diffx = x2 - display.cx
	local diffy = y2 - display.cy
	local node = self.player.node

	return node:getPositionX() + tw / 2 + diffx / main_scene.ground:getScale(), node:getPositionY() + th / 2 + diffy / main_scene.ground:getScale()
end

function map2:getMapPos(gameX, gameY)
	return gameX * mapDef.tile.w, (self.h - gameY) * mapDef.tile.h
end

function map2:getGamePos(x2, y2)
	return math.floor(x2 / mapDef.tile.w), math.floor(self.h - y2 / mapDef.tile.h + 1)
end

function map2:addDoorTile(data2, x2, y2)
	local idx = ycFunction:band(data2.doorIndex, 127)
	local door = self.doors[idx]

	if not door then
		door = {}
		self.doors[idx] = door
	end

	for k, v in pairs(door) do
		if v.x == x2 and v.y == y2 then
			return
		end
	end

	door[#door + 1] = {
		x = x2,
		y = y2,
		data = data2
	}
end

function map2:setDoorState(isOpen, x2, y2)
	local data2 = self.file:gettile(x2, y2)

	if data2 then
		local idx = ycFunction:band(data2.doorIndex, 127)
		local door = self.doors[idx]

		if door then
			for k, v in pairs(door) do
				local tile = self.tiles[v.x][v.y]

				if tile then
					v.data.doorOpen = isOpen

					tile:setDoorState(v.data)
				end
			end
		end
	end
end

function map2:addSafeZoneEff(x2, y2, range)
	local key = self:xy2key(x2, y2)

	if self.safezoneEffs[key] then
		return
	end

	self.safezoneEffs[key] = true

	local points = {
		{
			flag = 0,
			x = x2 - range,
			y = y2 - range - 1
		},
		{
			flag = 2,
			x = x2 + range,
			y = y2 - range - 1
		},
		{
			flag = 4,
			x = x2 + range,
			y = y2 + range - 1
		},
		{
			flag = 6,
			x = x2 - range,
			y = y2 + range - 1
		}
	}

	for i = 1, range * 2 + 1 do
		points[#points + 1] = {
			flag = 1,
			x = x2 - range + i - 1,
			y = y2 - range - 1
		}
		points[#points + 1] = {
			flag = 3,
			x = x2 + range,
			y = y2 - range + i - 2
		}
		points[#points + 1] = {
			flag = 5,
			x = x2 - range + i - 1,
			y = y2 + range + 1
		}
		points[#points + 1] = {
			flag = 7,
			x = x2 - range - 2,
			y = y2 - range + i - 2
		}
	end

	for i2, v in ipairs(points) do
		local x3 = v.x
		local y3 = v.y

		if self.mapid ~= "0" or x3 < 319 or x3 > 337 or y3 < 261 or y3 > 276 then
			local spr = m2spr.playAnimation("magic10", 2040 + v.flag * 10, 4, 0.2, true, nil, nil, nil, nil, 1):addto(self.layers.mid, 99999)

			position(spr, x3 * mapDef.tile.w, (self.h - y3) * mapDef.tile.h)
		end
	end
end

function map2:canWalk(gamex, gamey, params)
	local ret = {}

	if params and params.useBlockInfo then
		if self.file:getblock(gamex, gamey) then
			ret.block = "block"
		end
	else
		local data2 = self.file:gettile(gamex, gamey)

		if data2 then
			if ycFunction:band(data2.doorIndex, 128) > 0 and not data2.doorOpen then
				ret.block = "door"
				ret.data = data2
			elseif not data2.canWalk then
				ret.block = "map"
			end
		end
	end

	if not ret.block then
		ret = self:isObjblock(gamex, gamey)
	end

	return ret
end

function map2:canFly(gamex, gamey, params)
	return self.file:gettile(gamex, gamey).canFly
end

function map2:getObjeBlocks()
	local objects = {}

	local function checkRoles(roles)
		for k, v in pairs(roles) do
			if not v.isDummy and not v.die then
				objects[#objects + 1] = cc.p(v.x, v.y)
			end
		end
	end

	checkRoles(self.mons)
	checkRoles(self.npcs)
	checkRoles(self.heros)

	return objects
end

function map2:isObjblock(gamex, gamey)
	local ret = {}

	if not ret.block then
		for k, v in pairs(self.mons) do
			if not v.isDummy and gamex == v.x and gamey == v.y and not v.die then
				ret.block = "mon"

				break
			end
		end
	end

	if not ret.block then
		for k2, v2 in pairs(self.npcs) do
			if not v2.isDummy and gamex == v2.x and gamey == v2.y and not v2.die then
				ret.block = "npc"

				break
			end
		end
	end

	if not ret.block then
		for k3, v3 in pairs(self.heros) do
			if not v3.isDummy and gamex == v3.x and gamey == v3.y and not v3.die then
				ret.block = "hero"

				break
			end
		end
	end

	return ret
end

function map2:procAllRoles(f)
	for k, roles in ipairs({
		self.heros,
		self.npcs,
		self.mons
	}) do
		for k2, v in pairs(roles) do
			f(v)
		end
	end
end

function map2:findRole(value, params, value2)
	local value3
	local role2 = self.heros[value]

	if role2 then
		return role2
	end

	local role3 = self.npcs[value]

	if role3 then
		return role3
	end

	local role4 = self.mons[value]

	if role4 then
		return role4
	end

	if value2 then
		return nil
	end

	if params and params.feature then
		if type(params.feature) == "number" then
			params.feature = def.role.makeTFeature(params.feature)
		end

		if not solt0190 then
			os.exit()
		end

		return self:newRole(params), true
	end
end

function map2:findRoelWithPos(x2, y2, type2)
	if not type2 or type2 == "hero" then
		for k, v in pairs(self.heros) do
			if v.x == x2 and v.y == y2 then
				return v
			end
		end
	end

	if not type2 or type2 == "mon" then
		for k2, v2 in pairs(self.mons) do
			if v2.x == x2 and v2.y == y2 then
				return v2
			end
		end
	end

	if not type2 or type2 == "npc" then
		for k3, v3 in pairs(self.npcs) do
			if v3.x == x2 and v3.y == y2 then
				return v3
			end
		end
	end
end

function map2:findHeroWithName(name2)
	for k, v in pairs(self.heros) do
		if v.info:getRealName() == name2 then
			return v
		end
	end
end

function map2:findNPCWithName(name2)
	for k, v in pairs(self.npcs) do
		if v.info:getName() == name2 then
			return v
		end
	end
end

function map2:findNearMon()
	local bestDis
	local bestMon

	for k, v in pairs(self.mons) do
		local name2 = v.info:getName()

		if not v.die and not v:isPolice() then
			local x2 = math.abs(self.player.x - v.x)
			local y2 = math.abs(self.player.y - v.y)
			local dis = math.sqrt(x2 * x2 + y2 * y2)

			if not bestDis or dis < bestDis then
				bestDis = dis
				bestMon = v
			end
		end
	end

	return bestMon
end

function map2:newRole(params)
	assert(params.roleid, "map.newRole -> roleid must be not nil")

	params.map = self

	local race = params.feature:get("race")
	local ret

	if race == 0 or race == 1 or race == 150 then
		ret = hero.new(params)

		ret.node:addTo(self.layers.obj)

		self.heros[params.roleid] = ret

		if params.isPlayer then
			self:setPlayer(ret)
		end
	elseif race == 50 then
		ret = npc.new(params)

		ret.node:addTo(self.layers.obj)

		self.npcs[params.roleid] = ret
	else
		ret = mon.new(params)

		ret.node:addTo(self.layers.obj)

		self.mons[params.roleid] = ret
	end

	if main_scene and main_scene.ui.panels.minimap then
		main_scene.ui.panels.minimap:addPoint(ret)
	end

	self:uptRoleXY(ret, false, params.x, params.y)

	return ret
end

function map2:removeRole(roleid2)
	local function cleanup(self2, value)
		if self.lights[value] and self2.roleid ~= self.player.roleid then
			self:removeLight("hero", value)
		end
	end

	local value2
	local role2 = self.heros[roleid2]

	if role2 then
		cleanup(role2, roleid2)
		self:uptRoleXY(role2, true)
		role2:clearLoops()
		role2.info:remove()
		role2.node:removeSelf()
	end

	self.heros[roleid2] = nil

	local role3 = self.npcs[roleid2]

	if role3 then
		cleanup(role3, roleid2)
		self:uptRoleXY(role3, true)
		role3:clearLoops()
		role3.info:remove()
		role3.node:removeSelf()
	end

	self.npcs[roleid2] = nil

	local role4 = self.mons[roleid2]

	if role4 then
		cleanup(role4, roleid2)
		self:uptRoleXY(role4, true)
		role4:clearLoops()
		role4.info:remove()
		role4.node:removeSelf()
	end

	self.mons[roleid2] = nil

	if main_scene and main_scene.ui.panels.minimap then
		main_scene.ui.panels.minimap:removePoint(roleid2)
	end
end

function map2:setPlayer(player)
	if self.player then
		self:removeTopRenderNode(self.player)
		self.player.node:removeSelf()
	end

	self.player = player

	self:addTopRenderNode(self.player.node)
end

function map2:xy2key(x2, y2)
	return x2 * 10000 + y2
end

function map2:uptRoleXY(role2, isRemove, x2, y2)
	local oldKey = role2.xyKey
	local newKey = x2 and y2 and self:xy2key(x2, y2)

	if oldKey == newKey then
		return
	end

	if oldKey then
		local roles2 = self.roleXYs[oldKey]

		if roles2 then
			for i, v in ipairs(roles2) do
				if v == role2 then
					table.remove(roles2, i)

					break
				end
			end
		end
	end

	if isRemove then
		return
	end

	local roles = self.roleXYs[newKey]

	if not roles then
		roles = {}
		self.roleXYs[newKey] = roles
	end

	roles[#roles + 1] = role2

	if self.player and not self.isStage then
		role2.isInScreen = math.abs(x2 - self.player.x + 1) <= self.screenw / 2 + 1 and math.abs(y2 - self.player.y) < self.screenh / 2 + 2
	else
		role2.isInScreen = true
	end

	for i2, v2 in ipairs(roles) do
		v2:uptIsIgnore()
	end

	role2:uptIsIgnore()

	role2.xyKey = newKey
end

function map2:init_itemmatch()
	self.item_match = def.role.getMapItemColorCfg()
	self.item_imgstyle = def.role.getMapItemImageStyle()
end

function map2:pickupItem(item, tag2)
	if not main_scene then
		return
	end

	if not def.role.mainsetting.funAoths then
		return
	end

	if def.role.mainsetting.funAoths[2] ~= "999" then
		return
	end

	if g_data.setting.autoRat.noAutoPickup then
		return
	end

	local value5 = main_scene.ground.player
	local goodAttItemSetting = g_data.setting.getGoodAttItemSetting().pickOnRatting
	local value = main_scene.ui.console.autoRat.modifyProperty
	local value2 = g_data.player.ability
	local value3 = value2:get("weight")
	local value4 = value2:get("maxWeight") + 100000
	local point = self.items[item]

	if point and main_scene.ui.console.autoRat and not main_scene.ui.console.autoRat:getTempData(point, "cannotPick") and (value3 < value4 and g_data.bag:getFreeCount() > 0 or point.itemName == "金币" or point.itemName == "金币1") then
		local enabled = false

		if point.state and point.state > 0 and goodAttItemSetting then
			point.tag = tag2

			net.send({
				CM_PICKUP,
				param = point.x,
				tag = point.y
			})

			enabled = true
		end

		if not enabled and (def.pickAllItems or value and value[point.itemName]) then
			point.tag = tag2

			net.send({
				CM_PICKUP,
				param = point.x,
				tag = point.y
			})
		end
	end
end

function map2:showItem(isshow, itemid2, gamex, gamey, name2, imgid2, owner2, state)
	if isshow == false then
		if not def.closeAutoPick and def.role.mainsetting.funAoths and def.role.mainsetting.funAoths[2] == "999" and not g_data.setting.autoRat.noAutoPickup then
			local point = self.items[itemid2]
			local player = main_scene.ground.player

			if point and point.tag and point.tag == player.roleid then
				local mapPos, mapPos2 = main_scene.ground.map:getMapPos(player.x, player.y)

				if math.abs(point.x - player.x) <= 10 and math.abs(point.y - player.y) <= 10 then
					if point.spr then
						point.spr:runs({
							cc.MoveTo:create(0.2, cc.p(mapPos, mapPos2)),
							cc.Hide:create()
						})
					end

					if point.name then
						point.name:runs({
							cc.MoveTo:create(0.2, cc.p(mapPos, mapPos2)),
							cc.Hide:create()
						})
					end
				end
			end
		end

		scheduler.performWithDelayGlobal(function()
			if self.showItemOrg then
				self:showItemOrg(isshow, itemid2, gamex, gamey, name2, imgid2, owner2, state)
			end
		end, 0.2)

		return
	end

	self:showItemOrg(isshow, itemid2, gamex, gamey, name2, imgid2, owner2, state)

	if not def.closeAutoPick and owner2 == main_scene.ground.player.roleid then
		scheduler.performWithDelayGlobal(function()
			if self.pickupItem then
				self:pickupItem(itemid2, owner2)
			end
		end, 0.1)
	end
end

function map2:showItemOrg(isshow, itemid2, gamex, gamey, name2, imgid2, owner2, state)
	if isshow ~= (self.items[itemid2] ~= nil) then
		if isshow then
			local x2, y2 = self:getMapPos(gamex, gamey)
			local number = 10
			local item = {
				x = gamex,
				y = gamey,
				owner = owner2,
				imgid = imgid2,
				itemid = itemid2
			}
			local value
			local x3 = x2 + mapDef.tile.w / 2
			local y3 = y2 + mapDef.tile.h / 2

			if goodCheck and state and goodCheck(state) and def.role.itemstyle and def.role.itemstyle.mapStyle_Spical then
				value = def.role.itemstyle.mapStyle_Spical
			end

			if not value and name2 and self.item_imgstyle and self.item_imgstyle[name2] then
				value = self.item_imgstyle[name2]
			end

			if value then
				item.spr = m2spr.playAnimation("dnitems", value.start, value.num, value.interval, false):addto(self.layers.obj, gamey):pos(x2 + mapDef.tile.w / 2 - number, y2 + mapDef.tile.h / 2)
			elseif def.showItemDropSpr then
				item.spr = m2spr.new("dnitems", imgid2, {
					asyncPriority = 1
				}):addto(self.layers.obj, gamey):pos(x2 + mapDef.tile.w / 2, y2 + mapDef.tile.h / 2):runs({
					cc.DelayTime:create(0.05),
					cc.MoveTo:create(0.08, cc.p(x3, y3 + 10)),
					cc.DelayTime:create(0.05),
					cc.MoveTo:create(0.06, cc.p(x3, y3)),
					cc.DelayTime:create(0.04),
					cc.MoveTo:create(0.05, cc.p(x3, y3 + 5)),
					cc.DelayTime:create(0.03),
					cc.MoveTo:create(0.03, cc.p(x3, y3))
				})

				item.spr:run(cc.RepeatForever:create(transition.sequence({
					cc.DelayTime:create(math.random(3000, 5000) / 1000),
					cc.CallFunc:create(function()
						position(m2spr.playAnimation("prguse", 410, 9, 0.08, true, true, true):addto(self.layers.itemEff), x2, y2 + mapDef.tile.h)
					end)
				})))
			else
				item.spr = m2spr.new("dnitems", imgid2, {
					asyncPriority = 1
				}):addto(self.layers.obj, gamey):pos(x2 + mapDef.tile.w / 2, y2 + mapDef.tile.h / 2)
			end

			if self.setDark.control and self.opacity > 0 and item.spr then
				local typeOwner = self.setDark.mapLight[self.mapid] or self.setDark.mapLight[g_data.map.mapTitle]

				if typeOwner and typeOwner.type and typeOwner.type ~= 0 or self.setDark.allMapDark then
					item.node = display.newNode():addto(self.layers.obj, gamey)

					item.node:run(cc.RepeatForever:create(transition.sequence({
						cc.DelayTime:create(0.01),
						cc.CallFunc:create(function()
							if self.items[itemid2] then
								self:addLight2({
									h = 18,
									w = 18,
									roleid = tostring(itemid2),
									x = self.items[itemid2].x,
									y = self.items[itemid2].y
								}, "objs", 0.5)
							end
						end)
					})))
				end
			end

			local isGood = false
			local showName = false

			if state and state > 0 then
				isGood = g_data.setting.getGoodAttItemSetting().isGood
				showName = g_data.setting.getGoodAttItemSetting().hintName
			end

			isGood = isGood or settingLogic.isGoodItem(name2)
			showName = showName or settingLogic.showItemName(name2)

			if showName or isGood then
				local nameColor = def.colors.skyBlue

				if isGood then
					nameColor = def.colors.clRed
				end

				if state and state > 0 then
					nameColor = def.colors.clpurple
				end

				local name3 = name2

				if not def.showItemNameWithPlus and name2:find("+") ~= nil then
					name3 = string.split(name2, "+")[1]
				end

				item.name = an.newLabel(name3, 12, 1, {
					bufferChannel = 8,
					color = nameColor
				}):addto(self.layers.itemName)

				position(item.name, x2, y2 + 20)

				if def.openTTFFontOnly then
					-- block empty
				else
					item.name:setOpacity(80)
				end
			end

			item.state = state
			item.mapid = self.mapid
			self.items[itemid2] = item
			item.itemName = name2

			self:setName(item)

			return
		end

		local item2 = self.items[itemid2]

		if item2 then
			if item2.spr then
				item2.spr:removeSelf()

				item2.spr = nil
			end

			if item2.node and not tolua.isnull(item2.node) and tolua.cast(item2.node, "cc.Node") then
				item2.node:stopAllActions()
				item2.node:removeSelf()
				self:removeLight("objs", tostring(itemid2))
			end

			if item2.name then
				item2.name:removeSelf()

				item2.name = nil
			end

			self.items[itemid2] = nil
		end
	end
end

function map2:setName(name2)
	if name2 and name2.name and name2.itemName and name2.itemName ~= "" then
		local value = def.role.itemstyle.itemColor

		if def.role.itemdesc and def.role.itemdesc[name2.itemName] then
			value = def.role.string2Color(def.role.itemdesc[name2.itemName].namecolor or 223)

			if value then
				name2.name:setColor(value)
			end
		elseif self.item_match and self.item_match[name2.itemName] then
			local value2 = def.role.string2Color(self.item_match[name2.itemName].color or 223)

			if value2 then
				name2.name:setColor(value2)
			end
		elseif value then
			name2.name:setColor(def.role.string2Color(value))
		end
	end
end

function map2:updateItems()
	local t = self.items

	self.items = {}

	for k, v in pairs(t) do
		v.spr:removeSelf()

		if v.name then
			v.name:removeSelf()
		end

		self:showItem(true, k, v.x, v.y, v.itemName, v.imgid, v.owner, v.state)
	end
end

function map2:getItems(x2, y2)
	local ret = {}

	for k, v in pairs(self.items) do
		if v.x == x2 and v.y == y2 then
			ret[#ret + 1] = v
		end
	end

	return ret
end

function map2:showMagic(roleid2, effectType, effectID, x2, y2, target)
	local role2 = self:findRole(roleid2)

	if not role2 then
		return
	end

	magic.showMagic(self, role2, target, x2, y2, effectID)
end

function map2:showEffectForName(name2, params)
	magic.showWithName(self, name2, params)
end

local position2 = cc.Node.setPosition

function map2:showEvent(serverID2, x2, y2, type2, eventMsg)
	self:hideEvent(serverID2)

	local enabled = true

	if def.role.mainsetting.magicblend ~= nil then
		enabled = def.role.mainsetting.magicblend
	end

	if mapDef.ET_FIRE == type2 then
		local magicConfigByUid = def.magic.getMagicConfigByUid(22, nil) or {}
		local copiedStartFrame = def.ccy.getCopiedStartFrame(magicConfigByUid) or {}
		local value = copiedStartFrame.rsc or "magic"
		local value2 = copiedStartFrame.always or 1630
		local value3 = copiedStartFrame.alwaysFrame or 6

		x2, y2 = self:getMapPos(x2, y2)
		self.events[serverID2] = m2spr.playAnimation(value, value2, value3, 0.08, enabled):opacity(76.5):addto(self.layers.obj, y2 + mapDef.tile.h)
	elseif mapDef.ET_HOLYCURTAIN == type2 then
		local imgid5 = "magic"
		local begin4 = 1390
		local frame4 = 10

		x2, y2 = self:getMapPos(x2, y2)
		self.events[serverID2] = m2spr.playAnimation(imgid5, begin4, frame4, 0.08, enabled):addto(self.layers.obj, y2 + mapDef.tile.h)
	elseif mapDef.ET_PILESTONES == type2 then
		local imgid2 = "effect"
		local begin = 64
		local frame = 5

		x2, y2 = self:getMapPos(x2, y2)
		self.events[serverID2] = m2spr.playAnimation(imgid2, begin, frame, 0.12, false, false, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_DIGOUTZOMBI == type2 then
		local imgid3 = "mon6"
		local begin2 = 420
		local frame2 = 6

		x2, y2 = self:getMapPos(x2, y2)
		self.events[serverID2] = m2spr.playAnimation(imgid3, begin2, frame2, 0.3, false, false, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_YanHuaTextEvent == type2 then
		x2, y2 = self:getMapPos(x2, y2)
		x2 = x2 - 130
		self.events[serverID2] = an.newLabel(eventMsg:get("desc"), 100, 0.5, {
			color = cc.c3b(255, 255, 0),
			sc = display.COLOR_WHITE
		}):addto(self.layers.obj, 99999)
	elseif mapDef.ET_CAKEFIRE == type2 then
		local imgid4 = "prguse3"
		local begin3 = mapDef.CAKEFIREBASE
		local frame3 = 30

		x2, y2 = self:getMapPos(x2, y2)
		self.events[serverID2] = m2spr.playAnimation(imgid4, begin3, frame3, 0.08, true):addto(self.layers.obj, y2 + mapDef.tile.h)
	elseif type2 >= mapDef.ET_INTENTLY and type2 <= mapDef.ET_SUCHASFOGDREAM then
		local frameBegin = {
			20,
			20,
			16,
			16,
			16,
			16,
			16
		}
		local imgid6 = "magic3"
		local begin5 = 60 + (type2 - mapDef.ET_INTENTLY) * 20
		local frame5 = frameBegin[type2 - mapDef.ET_INTENTLY + 1]

		x2, y2 = self:getMapPos(x2, y2)

		m2spr.playAnimation(imgid6, begin5, frame5, 0.12, enabled, true, true):addto(self.layers.mid, 99999)
	elseif mapDef.ET_STALL_EVENT == type2 then
		x2, y2 = self:getMapPos(x2, y2)
		self.events[serverID2] = stall.new({
			x = x2,
			y = y2,
			serverID = serverID2,
			map = self,
			data = eventMsg
		}):addto(self.layers.obj, 99999)
		self.stalls[serverID2] = self.events[serverID2]
	end

	if self.setDark.control and self.opacity > 0 and (mapDef.ET_FIRE == type2 or mapDef.ET_HOLYCURTAIN == type2) then
		self.events[serverID2]:run(cc.RepeatForever:create(transition.sequence({
			cc.DelayTime:create(0.01),
			cc.CallFunc:create(function()
				if self.events[serverID2] then
					local items = {
						roleid = serverID2,
						x = x2,
						y = y2 + mapDef.tile.h
					}

					self:addLight2(items, "magic", 1.5)
				end
			end)
		})))
	end

	if self.events[serverID2] then
		self.events[serverID2]:pos(x2, y2 + mapDef.tile.h)
	end
end

function map2:hideEvent(serverID2)
	if self.events[serverID2] then
		self.events[serverID2]:stopAllActions()
		self.events[serverID2]:removeSelf()

		self.events[serverID2] = nil
	end

	if self.magicLight[serverID2] and self.magicLight[serverID2].spr then
		self:removeLight("magic", serverID2)
	end
end

function map2:removeStall(serverID2)
	if self.stalls[serverID2] then
		self.stalls[serverID2] = nil
	end
end

function map2:getHeroNameList()
	local ret = {}

	for k, v in pairs(self.heros) do
		if not v.isPlayer and v.info:getName() and not v.info:isHero() and not v.isDummy then
			ret[#ret + 1] = v.info:getName()
		end
	end

	return ret
end

function map2:addTile(x2, y2)
	self.readyTiles[self:xy2key(x2, y2)] = {
		x2,
		y2
	}
end

function map2:processTile(x2, y2)
	if not self.tiles[x2] then
		self.tiles[x2] = {}
	end

	if not self.tiles[x2][y2] then
		self.tiles[x2][y2] = maptile.new(self, x2, y2)

		self:addMapFire(x2, y2)

		return true
	end
end

function map2:processTiles(dt)
	local cnt = 0

	for k, v in pairs(self.readyTiles) do
		self.readyTiles[k] = nil

		if self:processTile(v[1], v[2]) then
			cnt = cnt + 1

			if cnt > mapDef.loadNum then
				return
			end
		end
	end

	if self.gray then
		self:setGrayState()
	end
end

function map2:clearTiles()
	local x2 = self.player.x
	local y2 = self.player.y
	local dis = math.floor(display.width / mapDef.tile.w) + mapDef.loadOutsideAreaBottom * 2

	for k, v2 in pairs(self.tiles) do
		for k2, v22 in pairs(v2) do
			if dis < math.abs(x2 - k) or dis < math.abs(y2 - k2) then
				v22:remove()

				self.tiles[k][k2] = nil
			end
		end
	end

	for k3, v in pairs(self.readyTiles) do
		if dis < math.abs(x2 - v[1]) or dis < math.abs(y2 - v[2]) then
			self.readyTiles[k3] = nil
		end
	end
end

function map2:addMsg(params)
	if params.remove then
		local tmpList = newList()

		while not self.msgs.isEmpty() do
			local msg = self.msgs.popFront()

			if msg.roleid ~= params.roleid then
				tmpList.pushBack(msg)
			end
		end

		self.msgs = tmpList

		self:removeRole(params.roleid)

		return
	end

	self.msgs.pushBack(params)
end

function map2:processMsg(v)
	if v.roleid then
		local role2, isNewCreate = self:findRole(v.roleid, v)

		if role2 then
			if v.ident then
				role2:processMsg(v.ident, v.x, v.y, v.dir, v.feature, v.state, v.roleParams)
			end

			if v.job then
				role2.job = v.job
			end

			if v.isHero then
				role2.isHero = v.isHero
			end

			if v.name then
				local race = role2:getRace()

				if race ~= 98 and race ~= 153 then
					role2.info:setName(v.name)

					if role2.__cname == "hero" then
						local jobOwner = g_data.player.cacheRoles[role2.info:getRealName()] or {}

						jobOwner.job = role2.job
						g_data.player.cacheRoles[role2.info:getRealName()] = jobOwner
					end
				end
			end

			repeat
				if role2.__cname == "hero" then
					local pName = role2.info:getRealName()
					local attData = g_data.relation:getAttention(pName)

					if attData then
						local colorIdx = attData:get("color")

						role2.info:setNameColor(colorIdx)

						if v.nameColor then
							attData.realNameColor = v.nameColor
						end

						break
					end
				end

				if v.nameColor then
					role2.info:setNameColor(v.nameColor)
				end
			until true

			if v.atkRoleid then
				role2.atkRoleid = v.atkRoleid
			end

			if v.hp and v.maxhp then
				role2.info:setHP(v.hp, v.maxhp, v.outhp, v.atkRoleid)
			end

			if v.mp and v.maxmp and v.maxmp > 0 then
				role2.info:setMP(v.mp, v.maxmp)
			end

			if v.piaoId and v.piaoNumber then
				role2.info:setPIAO(v.piaoId, v.piaoNumber)
			end

			if v.qieType and v.qieValue then
				role2.info:setQIE(v.qieType, v.qieValue)
			end

			if v.baoji then
				role2.bj = true

				if not def.role.mainsetting.useHPBJStyle and not role2.die then
					role2:showBJ()
				end
			end

			if v.buff and not role2.die and role2.roleStyle then
				role2:roleStyle({
					name = v.buffName,
					dir = v.dir,
					lockid = v.lockid
				})
			end

			if isNewCreate and v.roleid == g_data.hero.roleid then
				self.player.hero = role2

				if def.openHeroFH then
					net.send({
						CM_SAY
					}, {
						"MYHERO|" .. self.player.roleid .. "|" .. v.roleid
					})
				end
			end
		end
	end

	if v.magic then
		self:showMagic(unpack(v.magic))
	end

	if v.effect then
		self:showEffectForName(v.effect[1], v.effect[2])
	end
end

function map2:processMsgs(dt)
	local begin = socket.gettime()

	while not self.msgs.isEmpty() do
		self:processMsg(self.msgs.popFront())

		if socket.gettime() - begin > 0.01 then
			break
		end
	end
end

function map2:update(dt)
	self:processTiles(dt)
	self:processMsgs(dt)

	local roleSize = def.role.size
	local infoUpdate = roleInfo.update
	local roleUpdate = role.update
	local uptIsIgnore = role.uptIsIgnore
	local getPosition = role.getPosition
	local rnum = 0

	for k, roles in ipairs({
		self.heros,
		self.npcs,
		self.mons
	}) do
		for k2, v in pairs(roles) do
			if #v.acts > 0 or v.isPlayer then
				rnum = rnum + 1

				roleUpdate(v, dt)
			end

			if v.info.dirty then
				infoUpdate(v.info, dt)
			end

			if self.setDark.control and self.opacity > 0 then
				if v.__cname == "hero" then
					if not v.isPlayer then
						local roleLightFeature = self:getRoleLightFeature(v)
						local value

						if roleLightFeature then
							value = self.setDark.itemLight[roleLightFeature]
						end

						if def.role.stateHas(v.state, "stMagicShield") then
							value = value or 1.3
						end

						value = value or self.setDark.defaultScale

						if value < self.setDark.defaultScale then
							value = self.setDark.defaultScale
						end

						if value then
							self:addLight2(v, "hero", value)
						elseif self.lights[v.roleid] and self.lights[v.roleid].spr then
							self:removeLight("hero", v.roleid)
						end
					elseif def.role.stateHas(v.state, "stMagicShield") then
						if not self.player.shieldLight then
							self:uptSelfLight()

							self.player.shieldLight = true
						end
					elseif self.player.shieldLight then
						self:uptSelfLight()

						self.player.shieldLight = nil
					end
				elseif v.__cname == "npc" then
					if self.setDark.allNpcLight then
						self:addLight2(v, "hero", 1.5)
					end
				elseif v.__cname == "mon" and (v:isPet() or v:isGuard() or v:isPolice()) then
					self:addLight2(v, "hero", 1.5)
				end
			end
		end
	end

	if self.setDark.control then
		local objsOwner = self.setDark.mapLight[self.mapid] or self.setDark.mapLight[g_data.map.mapTitle]

		if objsOwner and objsOwner.objs then
			for _, obj2 in pairs(objsOwner.objs) do
				if obj2 then
					local value2 = obj2.scale or 1.2

					self:addLight2(obj2, "objs", value2)
				end
			end
		end

		self:uptLight()
	end

	self.current_frame_updatedRoles = rnum
end

function map2:checkFlyTo(from, to)
	local value2
	local value3
	local value4
	local value5
	local x2 = from.x
	local y2 = from.y
	local tx = to.x
	local ty = to.y
	local value = math.abs(x2 - tx) + math.abs(y2 - ty)

	for i = 0, 8 do
		local dir2 = self:getNextDirection(x2, y2, tx, ty)
		local value6
		local ok

		x2, y2, ok = self:getNextPosition(x2, y2, dir2, 1)

		if not ok or not self:canFly(x2, y2) then
			return false
		end

		if x2 == tx and y2 == ty then
			return true
		elseif value < math.abs(x2 - tx) + math.abs(y2 - ty) then
			return true
		end
	end

	return true
end

function map2:getNextDirection(x2, y2, tx, ty)
	local value
	local value2
	local fx = x2 < tx and 1 or x2 == tx and 0 or -1

	if math.abs(y2 - ty) > 2 and x2 >= tx - 1 and x2 <= tx + 1 then
		fx = 0
	end

	local fy = y2 < ty and 1 or y2 == ty and 0 or -1

	if math.abs(x2 - tx) > 2 and y2 > ty - 1 and y2 < ty + 1 then
		fy = 0
	end

	if fx == 0 and fy == -1 then
		return def.role.dir.up
	elseif fx == 1 and fy == -1 then
		return def.role.dir.rightUp
	elseif fx == 1 and fy == 0 then
		return def.role.dir.right
	elseif fx == 1 and fy == 1 then
		return def.role.dir.rightBottom
	elseif fx == 0 and fy == 1 then
		return def.role.dir.bottom
	elseif fx == -1 and fy == 1 then
		return def.role.dir.leftBottom
	elseif fx == -1 and fy == 0 then
		return def.role.dir.left
	elseif fx == -1 and fy == -1 then
		return def.role.dir.leftUp
	else
		return def.role.dir.up
	end
end

function map2:getNextPosition(nx, ny, dir2, step)
	local x2 = nx
	local y2 = ny

	if dir2 == def.role.dir.up then
		if y2 > step - 1 then
			y2 = y2 - step
		end
	elseif dir2 == def.role.dir.rightUp then
		if x2 > step - 1 and y2 < self.h - step then
			x2 = x2 + step
			y2 = y2 - step
		end
	elseif dir2 == def.role.dir.right then
		if x2 < self.w - step then
			x2 = x2 + step
		end
	elseif dir2 == def.role.dir.rightBottom then
		if x2 < self.w - step and y2 < self.h - step then
			x2 = x2 + step
			y2 = y2 + step
		end
	elseif dir2 == def.role.dir.bottom then
		if y2 < self.h - step then
			y2 = y2 + step
		end
	elseif dir2 == def.role.dir.leftBottom then
		if x2 < self.w - step and y2 > step - 1 then
			x2 = x2 - step
			y2 = y2 + step
		end
	elseif dir2 == def.role.dir.left then
		if x2 > step - 1 then
			x2 = x2 - step
		end
	elseif dir2 == def.role.dir.leftUp and x2 > step - 1 and y2 > step - 1 then
		x2 = x2 - step
		y2 = y2 - step
	end

	return x2, y2, x2 ~= nx or y2 ~= ny
end

function map2:genExtend(value)
	cc2.ms({
		function()
			extendUI.create(self.layers.obj, value, "gmap_ext")
		end
	})
end

function map2:getRangeItems(item2, index)
	local map2 = {}
	local player = main_scene.ground.player
	local value2 = main_scene.ui.console.autoRat.modifyProperty
	local goodAttItemSetting = g_data.setting.getGoodAttItemSetting().pickOnRatting
	local value = g_data.player.ability
	local value3 = value:get("weight")
	local value4 = value:get("maxWeight") + 100000

	for _, item in pairs(self.items) do
		if value3 < value4 and math.abs(item.x - item2) <= 3 and math.abs(item.y - index) <= 3 then
			local value5 = item.itemName

			if item.owner == player.roleid and not main_scene.ui.console.autoRat:getTempData(item, "cannotPick") and item.state and item.state > 0 and goodAttItemSetting then
				map2[#map2 + 1] = item
			end

			if value2[value5] then
				table.insert(map2, item)
			end
		end
	end

	return map2
end

function map2:updataSnowPos(oldx, oldy)
	if self.weatherlayer then
		self.weatherlayer:moveBy(-500 * (oldx - self.oldx), -500 * (oldy - self.oldy))

		self.oldx = oldx
		self.oldy = oldy
	end
end

function map2:showsnow()
	require("mir2.scenes.main.common.weatherNature").syncMap(self)
end

function map2:__q7vis()
	if not self then
		return false
	end

	local text = tostring(self.mapid or "")
	local text2 = g_data and g_data.map and g_data.map.mapTitle or ""

	local function cleanup(mapIdWhitelist, value2)
		if type(mapIdWhitelist) ~= "table" then
			return
		end

		if mapIdWhitelist.mapIdWhitelist ~= nil then
			value2.mapIdWhitelist = mapIdWhitelist.mapIdWhitelist
		end

		if mapIdWhitelist.mapIdBlacklist ~= nil then
			value2.mapIdBlacklist = mapIdWhitelist.mapIdBlacklist
		end

		if mapIdWhitelist.caveTitlePatterns ~= nil then
			value2.caveTitlePatterns = mapIdWhitelist.caveTitlePatterns
		end
	end

	local items = {}

	cleanup(def.weatherSnow, items)
	cleanup(def.natureWeather, items)

	if items.mapIdBlacklist and (items.mapIdBlacklist[text] or text2 ~= "" and items.mapIdBlacklist[text2]) then
		return false
	end

	local value = items.caveTitlePatterns

	if not value and def.weatherSnow and type(def.weatherSnow.caveTitlePatterns) == "table" then
		value = def.weatherSnow.caveTitlePatterns
	end

	if text2 ~= "" and type(value) == "table" then
		for _, item in ipairs(value) do
			if item ~= "" and string.find(text2, item, 1, true) then
				return false
			end
		end
	end

	if type(items.mapIdWhitelist) == "table" then
		local enabled = false

		for _2 in pairs(items.mapIdWhitelist) do
			enabled = true

			break
		end

		if enabled then
			return items.mapIdWhitelist[text] == true or text2 ~= "" and items.mapIdWhitelist[text2] == true
		end
	end

	return true
end

function map2:__q7dark(value, value2)
	if not value2 or value2.dayNightLinkEnabled == false or not def.openDark then
		return 0
	end

	local number = value2.weatherDarkModifiers or map2.__P_C.weatherDarkModifiers

	if number and value and number[value] then
		return tonumber(number[value]) or 0
	end

	return 0
end

function map2:__xnf2o(kind2, number6)
	local rootOwner = self._weatherAtmoWS

	if rootOwner and rootOwner.root and not tolua.isnull(rootOwner.root) then
		rootOwner.root:removeSelf()
	end

	self._weatherAtmoWS = nil

	if not main_scene or tolua.isnull(main_scene) then
		return
	end

	local number7

	if kind2 == "fog" then
		number7 = number6.fogColor or map2.__P_C.fogColor
	elseif kind2 == "cloudy" then
		number7 = number6.cloudyColor or map2.__P_C.cloudyColor
	elseif kind2 == "dustStorm" then
		number7 = (number6.dustStorm or map2.__P_C.dustStorm).overlayColor or map2.__P_C.dustStorm.overlayColor
	else
		return
	end

	if not number7 then
		return
	end

	local number2

	if kind2 == "fog" then
		number2 = tonumber(number6.fogGroundZOrder) or map2.__P_C.fogGroundZOrder or 50
	else
		number2 = kind2 == "dustStorm" and 47 or tonumber(number6.cloudyGroundZOrder) or map2.__P_C.cloudyGroundZOrder or 48
	end

	local number3 = math.max(0, math.min(255, math.floor(tonumber(number7.r) or 200)))
	local number4 = math.max(0, math.min(255, math.floor(tonumber(number7.g) or 200)))
	local number5 = math.max(0, math.min(255, math.floor(tonumber(number7.b) or 210)))
	local number = tonumber(number7.a) or 60

	if kind2 == "fog" and number6.fogOverlayAlpha ~= nil then
		number = tonumber(number6.fogOverlayAlpha) or number
	else
		number = kind2 == "cloudy" and number6.cloudyOverlayAlpha ~= nil and tonumber(number6.cloudyOverlayAlpha) or number
	end

	local targetAlpha2 = math.max(0, math.min(255, math.floor(number)))
	local number8 = 14
	local value = (display.width or 960) + number8
	local value2 = (display.height or 1136) + number8

	if not cc or not cc.LayerColor or not cc.LayerColor.create then
		return
	end

	local count = 0

	if number6.transitionEnabled == false then
		count = targetAlpha2
	end

	local node2 = cc.LayerColor:create(cc.c4b(number3, number4, number5, count), value, value2)

	if not node2 then
		return
	end

	local node = display.newNode():addto(main_scene, number2):anchor(0.5, 0.5)

	node:setLocalZOrder(number2)
	node:setPosition(display.cx, display.cy)
	node2:setPosition(-value * 0.5, -value2 * 0.5)
	node2:setTouchEnabled(false)
	node2:add2(node)

	self._weatherAtmoWS = {
		root = node,
		layer = node2,
		kind = kind2,
		targetAlpha = targetAlpha2
	}

	return self._weatherAtmoWS
end

function map2:__xnf2o_stop()
	local rootOwner = self._weatherAtmoWS

	if rootOwner and rootOwner.root and not tolua.isnull(rootOwner.root) then
		rootOwner.root:removeSelf()
	end

	self._weatherAtmoWS = nil
end

function map2:__xnf1c(number3, number4)
	if not main_scene or tolua.isnull(main_scene) then
		return nil
	end

	local number = tonumber(number3 and number3.rainbowZOrder) or map2.__P_C.rainbowZOrder or 45
	local node = display.newNode():addto(main_scene, number):anchor(0.5, 0.5)

	node:setPosition(display.cx, display.cy + 100)
	node:setOpacity(0)

	local items = {
		{
			g = 0,
			a = 35,
			r = 255,
			b = 0
		},
		{
			g = 127,
			a = 35,
			r = 255,
			b = 0
		},
		{
			g = 255,
			a = 30,
			r = 255,
			b = 0
		},
		{
			g = 255,
			a = 30,
			r = 0,
			b = 0
		},
		{
			g = 127,
			a = 30,
			r = 0,
			b = 255
		},
		{
			g = 0,
			a = 35,
			r = 0,
			b = 255
		},
		{
			g = 0,
			a = 35,
			r = 139,
			b = 255
		}
	}

	if cc.DrawNode and cc.DrawNode.create and cc.c4f then
		local value7 = (display.width or 960) * 0.35
		local value = cc.DrawNode:create()

		if value and value.drawSegment then
			local number5 = 40

			for index, item in ipairs(items) do
				local value2 = value7 + (index - 1) * 8
				local value3 = cc.c4f(item.r / 255, item.g / 255, item.b / 255, item.a / 255)

				if value3 then
					for index2 = 0, number5 - 1 do
						local value4 = math.pi * index2 / number5
						local value5 = math.pi * (index2 + 1) / number5
						local x2 = math.cos(value4) * value2
						local y2 = math.sin(value4) * value2
						local value8 = math.cos(value5) * value2
						local value9 = math.sin(value5) * value2

						value:drawSegment(cc.p(x2, y2), cc.p(value8, value9), 3.5, value3)
					end
				end
			end

			value:add2(node)
		end
	end

	local number2 = tonumber(number4) or 3
	local value6 = cc.FadeTo:create(number2, 255)

	if value6 then
		node:runAction(value6)
	end

	return node
end

return map2
