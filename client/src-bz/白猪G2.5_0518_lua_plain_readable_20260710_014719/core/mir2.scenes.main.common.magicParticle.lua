local magicParticle = {}
local text = "[magicParticle] "
local enabled = false

local function callback4()
	local text2 = def and def.openMagicParticle and Fun and type(Fun) == "string" and Fun:find("Sprite") ~= nil

	if not enabled then
		enabled = true

		print(text .. "openMagicParticle=" .. tostring(text2) .. " quality=" .. tostring(def and def.magicParticleQuality or "high"))
	end

	return text2
end

local items12 = {
	high = 1,
	medium = 0.65,
	low = 0.35
}

local function callback5()
	local value2 = def and def.magicParticleQuality or "high"

	return items12[value2] or 1
end

local function callback6(self)
	return math.max(1, math.floor(self * callback5() + 0.5))
end

local function callback7()
	return main_scene and main_scene.ui or nil
end

magicParticle.presets = setmetatable({}, {
	__index = function(value2, value3)
		local p_BOwner = callback7()
		local value4 = p_BOwner and p_BOwner.__P_B or nil

		return value4 and value4[value3] or nil
	end
})

local function callback8(self, value2)
	if not value2 then
		return self
	end

	if not self then
		return value2
	end

	local items16 = {}

	for itemId, item in pairs(self) do
		items16[itemId] = item
	end

	for itemId2, item2 in pairs(value2) do
		items16[itemId2] = item2
	end

	return items16
end

function magicParticle.getParams(self, value3, particleOwner)
	local value2 = magicParticle.presets[self] and magicParticle.presets[self][value3]
	local value4 = particleOwner and particleOwner.particle and particleOwner.particle[value3]

	return (callback8(value2, value4))
end

local function callback9(self)
	local value2, value3 = pcall(function()
		return cc.ParticleFire:createWithTotalParticles(self)
	end)

	if value2 and value3 then
		print(text .. "safeCreateParticle: ParticleFire OK, count=" .. self)

		return value3
	end

	local value4, value5 = pcall(function()
		return cc.ParticleSystemQuad:createWithTotalParticles(self)
	end)
	local value6 = value5

	if value4 and value6 then
		pcall(function()
			local instance = cc.Director:getInstance():getTextureCache()

			if instance then
				local value22 = instance:addImage("fire.png") or instance:addImage("particle_fire.png") or instance:addImage("__firePngData")

				if value22 and value6.setTexture then
					value6:setTexture(value22)
				end
			end
		end)
		print(text .. "safeCreateParticle: ParticleSystemQuad fallback, count=" .. self)

		return value6
	end

	print(text .. "safeCreateParticle: FAILED, all methods exhausted")

	return nil
end

local function callback10(self, x)
	if not self or not x then
		return
	end

	if self.stopSystem then
		self:stopSystem()
	end

	if self.setEmitterMode then
		self:setEmitterMode(0)
	end

	if self.setRadialAccel then
		self:setRadialAccel(0)
	end

	if self.setRadialAccelVar then
		self:setRadialAccelVar(0)
	end

	if self.setTangentialAccel then
		self:setTangentialAccel(0)
	end

	if self.setTangentialAccelVar then
		self:setTangentialAccelVar(0)
	end

	if self.setSourcePosition then
		self:setSourcePosition(cc.p(0, 0))
	end

	if self.setLife then
		self:setLife(x.life or 1)
	end

	if self.setLifeVar then
		self:setLifeVar(x.lifeVar or 0)
	end

	if self.setStartSize then
		self:setStartSize(x.startSize or 10)
	end

	if self.setStartSizeVar then
		self:setStartSizeVar(x.startSizeVar or 0)
	end

	if self.setEndSize then
		self:setEndSize(x.endSize or 1)
	end

	if self.setEndSizeVar then
		self:setEndSizeVar(x.endSizeVar or 0)
	end

	if self.setSpeed then
		self:setSpeed(x.speed or 20)
	end

	if self.setSpeedVar then
		self:setSpeedVar(x.speedVar or 0)
	end

	if self.setAngle then
		self:setAngle(x.angle or 0)
	end

	if self.setAngleVar then
		self:setAngleVar(x.angleVar or 0)
	end

	if self.setPosVar then
		self:setPosVar(cc.p(x.posVarX or 0, x.posVarY or 0))
	end

	if (x.gravityX or x.gravityY) and self.setGravity then
		self:setGravity(cc.p(x.gravityX or 0, x.gravityY or 0))
	end

	if self.setStartColor and cc.c4f then
		local value2 = cc.c4f(x.startR or 1, x.startG or 1, x.startB or 1, x.startA or 1)

		if value2 then
			self:setStartColor(value2)
		end
	end

	if self.setStartColorVar and cc.c4f then
		local value3 = cc.c4f(0.05, 0.05, 0.05, 0)

		if value3 then
			self:setStartColorVar(value3)
		end
	end

	if self.setEndColor and cc.c4f then
		local value4 = cc.c4f(x.endR or 0, x.endG or 0, x.endB or 0, x.endA or 0)

		if value4 then
			self:setEndColor(value4)
		end
	end

	if self.setEndColorVar and cc.c4f then
		local value5 = cc.c4f(0.02, 0.02, 0.02, 0)

		if value5 then
			self:setEndColorVar(value5)
		end
	end

	if x.blend then
		if self.setBlendAdditive then
			self:setBlendAdditive(true)
		elseif self.setBlendFunc then
			pcall(function()
				self:setBlendFunc(cc.blendFunc(cc.SRC_ALPHA or 770, cc.ONE or 1))
			end)
		end
	end

	if self.setDuration then
		self:setDuration(x.duration or -1)
	end

	if self.setAutoRemoveOnFinish then
		self:setAutoRemoveOnFinish(x.autoRemove ~= false)
	end

	if self.resetSystem then
		self:resetSystem()
	end
end

function magicParticle.attachTrail(self, x, y, x2, y2, duration2, value3, text3, value4)
	if not callback4() or not self then
		return nil
	end

	local duration = magicParticle.getParams(text3, "trail", value4)

	if not duration then
		return nil
	end

	print(text .. "attachTrail -> preset=" .. tostring(text3) .. " from=(" .. tostring(x) .. "," .. tostring(y) .. ") to=(" .. tostring(x2) .. "," .. tostring(y2) .. ") fly=" .. tostring(duration2))

	local value2, text2 = pcall(function()
		local value2 = callback6(duration.total or 40)
		local node = callback9(value2)

		if not node then
			print(text .. "attachTrail FAILED: safeCreateParticle returned nil")

			return nil
		end

		print(text .. "attachTrail OK: created " .. value2 .. " particles")
		callback10(node, duration)

		if node.setPositionType then
			node:setPositionType(cc and cc.POSITION_TYPE_RELATIVE or 1)
		end

		if node.setDuration then
			node:setDuration(-1)
		end

		if node.setAutoRemoveOnFinish then
			node:setAutoRemoveOnFinish(false)
		end

		node:setPosition(cc.p(x, y))

		if self.addChild then
			self:addChild(node, value3 or 9999)
		end

		node:runAction(cc.Sequence:create(cc.MoveTo:create(duration2, cc.p(x2, y2)), cc.CallFunc:create(function()
			if not tolua.isnull(node) then
				if node.stopSystem then
					node:stopSystem()
				end

				node:runAction(cc.Sequence:create(cc.DelayTime:create(duration.life or 0.5), cc.RemoveSelf:create()))
			end
		end)))

		return node
	end)

	if value2 then
		return text2
	end

	print(text .. "attachTrail ERROR: " .. tostring(text2))

	return nil
end

function magicParticle.burstAt(self, x, y, text3, value3, value4)
	if not callback4() or not self then
		return nil
	end

	local params = magicParticle.getParams(text3, "burst", value3)

	if not params then
		return nil
	end

	print(text .. "burstAt -> preset=" .. tostring(text3) .. " pos=(" .. tostring(x) .. "," .. tostring(y) .. ") total=" .. tostring(params.total))

	local value2, text2 = pcall(function()
		local value2 = callback6(params.total or 50)
		local node = callback9(value2)

		if not node then
			print(text .. "burstAt FAILED: safeCreateParticle returned nil")

			return nil
		end

		print(text .. "burstAt OK: created " .. value2 .. " particles at (" .. tostring(x) .. "," .. tostring(y) .. ")")
		callback10(node, params)

		if node.setDuration then
			node:setDuration(params.duration or 0.3)
		end

		if node.setAutoRemoveOnFinish then
			node:setAutoRemoveOnFinish(true)
		end

		if node.setPositionType then
			node:setPositionType(cc and cc.POSITION_TYPE_RELATIVE or 1)
		end

		node:setPosition(cc.p(x, y))

		if self.addChild then
			self:addChild(node, value4 or 9999)
		end

		return node
	end)

	if value2 then
		return text2
	end

	print(text .. "burstAt ERROR: " .. tostring(text2))

	return nil
end

function magicParticle.auraCaster(self, text2, value2, value4, value5)
	if not callback4() then
		return nil
	end

	if not self or not self.node or tolua.isnull(self.node) then
		return nil
	end

	local duration = magicParticle.getParams(text2, "caster", value2)

	if not duration then
		return nil
	end

	local duration2 = value4 or duration.duration or 0.5

	print(text .. "auraCaster -> preset=" .. tostring(text2) .. " duration=" .. tostring(duration2))

	local value3, text3 = pcall(function()
		local node = display.newNode()

		if not node then
			return nil
		end

		local value22 = duration.orbitRadius or 40
		local value3 = duration.orbitSpeed or 6
		local value42 = duration.orbitCount or 2
		local value52 = value5 or 32
		local value6 = duration.offsetX or 16
		local value7 = (duration.offsetY or 45) + value52
		local items16 = {}

		for index2 = 1, value42 do
			local value8 = callback6(duration.total or 25)
			local node2 = callback9(value8)

			if node2 then
				callback10(node2, duration)

				if node2.setDuration then
					node2:setDuration(duration2)
				end

				if node2.setAutoRemoveOnFinish then
					node2:setAutoRemoveOnFinish(false)
				end

				if node2.setPositionType then
					node2:setPositionType(cc and cc.POSITION_TYPE_GROUPED or 2)
				end

				node:addChild(node2, 9999)

				items16[#items16 + 1] = {
					node = node2,
					phase = (index2 - 1) * 2 * math.pi / value42
				}
			end
		end

		if #items16 == 0 then
			node:removeSelf()

			return nil
		end

		print(text .. "auraCaster OK: " .. #items16 .. " orbiting emitters, radius=" .. value22)

		local count = 0

		node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(function()
			if tolua.isnull(node) then
				return
			end

			count = count + 0.016

			for _, item in ipairs(items16) do
				if not tolua.isnull(item.node) then
					local value23 = item.phase + count * value3
					local x = math.cos(value23) * value22 + value6
					local y = math.sin(value23) * value22 * 0.5 + value7

					item.node:setPosition(cc.p(x, y))
				end
			end
		end))))
		node:runAction(cc.Sequence:create(cc.DelayTime:create(duration2), cc.CallFunc:create(function()
			if tolua.isnull(node) then
				return
			end

			for _, item in ipairs(items16) do
				if not tolua.isnull(item.node) and item.node.stopSystem then
					item.node:stopSystem()
				end
			end

			node:runAction(cc.Sequence:create(cc.DelayTime:create(duration.life or 0.5), cc.RemoveSelf:create()))
		end)))

		if self.node.addChild then
			self.node:addChild(node, duration.localZOrder or 9999)
		end

		return node
	end)

	if value3 then
		return text3
	end

	print(text .. "auraCaster ERROR: " .. tostring(text3))

	return nil
end

local function callback11()
	if main_scene and main_scene.ground then
		local value2 = main_scene.ground

		if value2.player then
			return value2.player
		end

		if value2.map then
			if value2.map.heros then
				for _, hero in pairs(value2.map.heros) do
					return hero
				end
			end

			if value2.map.mons then
				for _2, mon in pairs(value2.map.mons) do
					return mon
				end
			end
		end
	end

	return nil
end

local function callback12(self)
	local value2 = callback11()

	if value2 and type(value2.__boltColor) == "function" then
		return value2.__boltColor(self)
	end

	return {
		core = {
			1,
			1,
			1,
			1
		},
		glow = {
			0.7,
			0.82,
			1,
			0.55
		},
		outerGlow = {
			0.45,
			0.55,
			0.9,
			0.1
		},
		atmosphere = {
			0.55,
			0.65,
			1,
			0.08
		},
		afterimage = {
			0.4,
			0.5,
			1,
			0.3
		},
		burstCloud = {
			0.5,
			0.6,
			1,
			0.18
		},
		spark = {
			0.85,
			0.92,
			1
		}
	}
end

local function callback13(x, y, x2, y2, value3, value4, value5)
	local value2 = callback11()

	if value2 and type(value2.__genBolt) == "function" then
		return value2.__genBolt(x, y, x2, y2, value3, value4, value5)
	end

	return {
		{
			x = x,
			y = y
		},
		{
			x = x2,
			y = y2
		}
	}
end

local function callback14(self, value3, value4, value5, value6, value7, value8)
	local value2 = callback11()

	if value2 and type(value2.__drawBolt) == "function" then
		value2.__drawBolt(self, value3, value4, value5, value6, value7, value8)
	end
end

local function callback15(self, value3, value4, value5)
	local value2 = callback11()

	if value2 and type(value2.__drawGroundArc) == "function" then
		value2.__drawGroundArc(self, value3, value4, value5)
	end
end

local function callback16(self, value3, value4, value5, value6)
	local value2 = callback11()

	if value2 and type(value2.__drawWanderArc) == "function" then
		value2.__drawWanderArc(self, value3, value4, value5, value6)
	end
end

local function callback17(self)
	local value2 = callback11()

	if value2 and type(value2.__genFullBolt) == "function" then
		return value2.__genFullBolt(self)
	end

	return {
		{
			x = 0,
			y = self and self.height or 0
		},
		{
			x = 0,
			y = 0
		}
	}, {}
end

function magicParticle.lightningStrike(self, x, y, text2, particleOwner, value3)
	if not callback4() or not self then
		return nil
	end

	local size = magicParticle.getParams(text2, "bolt", particleOwner)

	if not size then
		return nil
	end

	local params = magicParticle.getParams(text2, "hit", particleOwner)

	print(text .. "lightningStrike -> preset=" .. tostring(text2) .. " at=(" .. tostring(x) .. "," .. tostring(y) .. ")")

	local value2, text3 = pcall(function()
		if not cc.DrawNode or not cc.DrawNode.create or not cc.c4f then
			print(text .. "lightningStrike: cc.DrawNode 不可用")

			return nil
		end

		local value2 = callback12(size.lightningColor)

		if particleOwner and particleOwner.particle and particleOwner.particle.lightningColor then
			value2 = callback12(particleOwner.particle.lightningColor)
		end

		local node = display.newNode()

		if not node then
			return nil
		end

		node:setPosition(cc.p(x, y - 12))
		self:addChild(node, value3 or 9999)

		local value32 = size.phase1Duration or 0.08
		local value4 = size.phase2Duration or 0.08
		local value5 = size.phase3Duration or 0.14
		local value6 = size.phase4Duration or 0.1
		local value7 = size.wanderDuration or 1
		local value8 = size.afterimageDuration or 0.4
		local value9 = size.flickerInterval or 0.035
		local value10 = value32
		local duration = value10 + value4
		local value11 = duration + value5
		local value12 = value11 + value6
		local value13 = value12 + value7
		local duration2 = value13 + value8
		local node2 = cc.DrawNode:create()

		node2:add2(node, -1)

		local node3 = cc.DrawNode:create()

		node3:add2(node)

		if node3.setBlendFunc and gl then
			pcall(function()
				node3:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
			end)
		end

		local node4 = cc.DrawNode:create()

		node4:add2(node, 2)
		node4:setOpacity(0)

		if node4.setBlendFunc and gl then
			pcall(function()
				node4:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
			end)
		end

		local count = 1
		local count4 = 0
		local count5 = 0
		local value14

		local function callback42(self2)
			if self2 == 1 then
				return size.phase1Core or 0.8, size.phase1Glow or 3, 0, size.phase1Atmo or 35
			end

			if self2 == 2 then
				return size.phase2Core or 2, size.phase2Glow or 10, 0, size.phase2Atmo or 50
			end

			if self2 == 3 then
				return size.phase3Core or 3.5, size.phase3Glow or 14, 0, size.phase3Atmo or 65
			end

			if self2 == 4 then
				return size.phase4Core or 1, size.phase4Glow or 4, 0, size.phase4Atmo or 40
			end

			return 0, 0, 0, 0
		end

		local function callback52(self2)
			if tolua.isnull(node3) then
				return
			end

			node3:clear()
			node2:clear()

			local value22, value33 = callback17(size)

			value14 = value22

			local value42, value52, value62, value72 = callback42(self2)

			callback14(node3, value22, value2, value42, value52, value62, 0)

			if self2 >= 2 and self2 <= 3 then
				for _, item in ipairs(value33) do
					local value82 = item.pts
					local value92 = item.depth or 1
					local value102 = math.pow(0.4, value92)
					local value112 = value42 * value102
					local value122 = value52 * value102

					callback14(node3, value82, value2, value112, value122, 0, 0)
				end
			end

			if self2 >= 2 and self2 <= 4 then
				callback15(node3, node2, value2, size)
			end
		end

		local function updateVisible()
			if tolua.isnull(node4) or not value14 then
				return
			end

			node4:clear()

			local core = value2.afterimage or value2.glow
			local items16 = {
				core = core,
				glow = core,
				outerGlow = core
			}

			callback14(node4, value14, items16, size.afterimageCoreWidth or 0.5, size.afterimageGlowWidth or 2, 0, 0)
		end

		callback52(1)

		if params then
			node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
				if tolua.isnull(node) then
					return
				end

				local value22 = callback6(params.total or 40)
				local node5 = callback9(value22)

				if node5 then
					local value33 = value2.spark
					local items16 = {}

					for itemId, item in pairs(params) do
						items16[itemId] = item
					end

					items16.startR = value33[1]
					items16.startG = value33[2]
					items16.startB = value33[3]
					items16.startA = 1
					items16.endR = value33[1] * 0.4
					items16.endG = value33[2] * 0.4
					items16.endB = value33[3] * 0.4
					items16.endA = 0

					callback10(node5, items16)

					if node5.setPositionType then
						node5:setPositionType(cc and cc.POSITION_TYPE_RELATIVE or 1)
					end

					node5:setPosition(cc.p(0, 0))
					node:addChild(node5, 10)
				end
			end)))
		end

		local node5 = cc.DrawNode:create()

		node5:add2(node, 3)
		node5:setVisible(false)

		if node5.setBlendFunc and gl then
			pcall(function()
				node5:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
			end)
		end

		local node6 = cc.DrawNode:create()

		node6:add2(node, -1)
		node6:setVisible(false)
		node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(function()
			if tolua.isnull(node) then
				return
			end

			count4 = count4 + 0.016
			count5 = count5 + 0.016

			local value22 = count
			local value33 = count4 < value10 and 1 or count4 < duration and 2 or count4 < value11 and 3 or count4 < value12 and 4 or count4 < value13 and 5 or 6

			if value33 ~= count then
				count = value33

				if count <= 4 then
					callback52(count)
				elseif count == 5 then
					if not tolua.isnull(node3) then
						node3:clear()
						node3:setVisible(false)
					end

					if not tolua.isnull(node2) then
						node2:clear()
						node2:setVisible(false)
					end

					node5:setVisible(true)
					node6:setVisible(true)
					updateVisible()
					node4:setOpacity(180)
				elseif count == 6 then
					if not tolua.isnull(node5) then
						node5:clear()
						node5:setVisible(false)
					end

					if not tolua.isnull(node6) then
						node6:clear()
						node6:setVisible(false)
					end
				end

				count5 = 0
			end

			if count5 >= value9 then
				count5 = 0

				if count >= 1 and count <= 4 then
					callback52(count)
				elseif count == 5 then
					local value42 = (count4 - value12) / value7

					if not tolua.isnull(node5) then
						node5:clear()
						node6:clear()
						callback16(node5, node6, value2, size, math.min(1, value42))
					end

					if not tolua.isnull(node4) then
						local value52 = math.max(0, 1 - value42 * 0.5)

						node4:setOpacity(math.floor(value52 * 180))
					end
				elseif count == 6 then
					local value62 = (count4 - value13) / value8

					if value62 < 1 then
						if not tolua.isnull(node4) then
							node4:setOpacity(math.max(0, math.floor((1 - value62) * 90)))
						end
					elseif not tolua.isnull(node4) then
						node4:clear()
					end
				end
			end

			if count4 >= duration2 + 0.3 and not tolua.isnull(node) then
				node:stopAllActions()
				node:removeSelf()
			end
		end))))
		node:runAction(cc.Sequence:create(cc.DelayTime:create(duration2 + 0.5), cc.RemoveSelf:create()))
		print(text .. "lightningStrike OK: 5-phase bolt, height=" .. (size.height or 350) .. " color=" .. tostring(size.lightningColor or "white"))

		return node
	end)

	if value2 then
		return text3
	end

	print(text .. "lightningStrike ERROR: " .. tostring(text3))

	return nil
end

function magicParticle.lightningCasterArc(self, text2, particleOwner, value3, value4)
	if not callback4() then
		return nil
	end

	if not self or not self.node or tolua.isnull(self.node) then
		return nil
	end

	local params = magicParticle.getParams(text2, "caster", particleOwner)

	if not params then
		return nil
	end

	if params.style ~= "spark" then
		return magicParticle.auraCaster(self, text2, particleOwner, value3, value4)
	end

	local duration = value3 or params.duration or 0.5

	print(text .. "lightningCasterArc -> preset=" .. tostring(text2) .. " dur=" .. tostring(duration))

	local value2, text3 = pcall(function()
		local params2 = magicParticle.getParams(text2, "bolt", particleOwner)
		local text22 = "white"

		if params2 and params2.lightningColor then
			text22 = params2.lightningColor
		end

		if particleOwner and particleOwner.particle and particleOwner.particle.lightningColor then
			text22 = particleOwner.particle.lightningColor
		end

		local value2 = callback12(text22)
		local value32 = value2.spark
		local value42 = value4 or 32
		local x = params.offsetX or 16
		local y = (params.offsetY or 55) + value42
		local node = display.newNode()

		if not node then
			return nil
		end

		node:setPosition(cc.p(x, y))
		self.node:addChild(node, 9999)

		local value5 = callback6(params.total or 60)
		local node2 = callback9(value5)

		if node2 then
			local items16 = {}

			for itemId, item in pairs(params) do
				items16[itemId] = item
			end

			items16.startR = value32[1]
			items16.startG = value32[2]
			items16.startB = value32[3]
			items16.startA = 1
			items16.endR = value32[1] * 0.35
			items16.endG = value32[2] * 0.35
			items16.endB = value32[3] * 0.35
			items16.endA = 0

			callback10(node2, items16)

			if node2.setDuration then
				node2:setDuration(duration)
			end

			if node2.setAutoRemoveOnFinish then
				node2:setAutoRemoveOnFinish(false)
			end

			if node2.setPositionType then
				node2:setPositionType(cc and cc.POSITION_TYPE_GROUPED or 2)
			end

			node2:setPosition(cc.p(0, 0))
			node:addChild(node2, 10)
		end

		if cc.DrawNode and cc.DrawNode.create and cc.c4f then
			local node3 = cc.DrawNode:create()

			node3:setPosition(cc.p(0, 0))
			node:addChild(node3, 1)

			local node4 = cc.DrawNode:create()

			node4:setPosition(cc.p(0, 0))

			if node4.setBlendFunc then
				node4:setBlendFunc(gl.ONE, gl.ONE)
			end

			node:addChild(node4, 5)

			local count = 1
			local number2 = 12
			local number3 = 40
			local number4 = 18
			local number5 = 12
			local number6 = 4
			local number7 = 0.5
			local duration2 = 0.045
			local count4 = 0

			local function callback42()
				if tolua.isnull(node4) or tolua.isnull(node3) then
					return
				end

				node4:clear()
				node3:clear()

				local value22 = math.min(1, count4 / duration)
				local value33 = 0.35 + value22 * 0.65
				local value43 = 0.2 + value22 * 0.3
				local value52 = 0.5 + value22 * 0.8
				local value6 = (math.random() - 0.5) * number4 * 0.8
				local value7 = (math.random() - 0.5) * 4
				local value8 = (number2 + (number3 - number2) * value33) * (0.7 + math.random() * 0.3)
				local value9 = value6 + (math.random() - 0.5) * number4 * 0.8
				local x2 = callback13(value6, value7, value9, value8, number5 * (0.6 + value33 * 0.4), number6, number7)
				local value10 = #x2 - 1

				if value10 > 0 then
					local value11 = value2.glow
					local value12 = value2.core

					for index2 = 1, value10 do
						local value13 = (index2 - 0.5) / value10
						local value14 = 0.3 + 0.7 * math.sin(value13 * math.pi)
						local value15 = value43 * value14
						local value16 = value52 * value14
						local point = cc.p(x2[index2].x, x2[index2].y)
						local point2 = cc.p(x2[index2 + 1].x, x2[index2 + 1].y)

						if value2.voidRim then
							local value17 = value2.voidRim

							node4:drawSegment(point, point2, value16 * 0.6 * value14, cc.c4f(value17[1], value17[2], value17[3], value17[4]))
						end

						node4:drawSegment(point, point2, value16, cc.c4f(value11[1], value11[2], value11[3], value11[4]))
						node4:drawSegment(point, point2, value15, cc.c4f(value12[1], value12[2], value12[3], value12[4]))
					end
				end
			end

			node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(duration2), cc.CallFunc:create(function()
				if tolua.isnull(node) then
					return
				end

				count4 = count4 + duration2

				callback42()
			end))))
			callback42()
		end

		node:runAction(cc.Sequence:create(cc.DelayTime:create(duration + (params.life or 0.3)), cc.RemoveSelf:create()))
		print(text .. "lightningCasterArc OK: DrawNode arcs + sparks, color=" .. text22)

		return node
	end)

	if value2 then
		return text3
	end

	print(text .. "lightningCasterArc ERROR: " .. tostring(text3))

	return nil
end

local function callback18()
	return callback11()
end

local countOwner = setmetatable({
	wanderPauseMin = 3.5,
	afkSleepDelay = 60,
	followSpringK = 10,
	followToIdleDelay = 0.4,
	wanderPauseMax = 6,
	followBehindDist = 50,
	wanderRadiusMin = 42,
	pauseHoverAmp = 4,
	followDamping = 5.5,
	wanderRadiusMax = 62,
	wanderSpeed = 1.4
}, {
	__index = function(value2, value3)
		local p_AOwner = callback18()
		local value4 = p_AOwner and p_AOwner.__P_A or nil

		return value4 and value4[value3] or nil
	end
})
local items = {
	SLEEP = "sleep",
	FOLLOW = "follow",
	ORBIT = "orbit",
	PAUSE = "pause",
	WANDER = "wander"
}
local items9 = {
	[0] = {
		x = 0,
		y = -0.5
	},
	{
		x = -0.707,
		y = -0.354
	},
	{
		x = -1,
		y = 0
	},
	{
		x = -0.707,
		y = 0.354
	},
	{
		x = 0,
		y = 0.5
	},
	{
		x = 0.707,
		y = 0.354
	},
	{
		x = 1,
		y = 0
	},
	{
		x = 0.707,
		y = -0.354
	}
}
local items13 = {
	[0] = -90,
	-27,
	0,
	27,
	90,
	153,
	180,
	-153
}
local items3 = {}

local function callback19()
	if cc and cc.utils and cc.utils.gettime then
		return cc.utils.gettime() * 1000
	end

	if os and os.time then
		return os.time() * 1000
	end

	return 0
end

local items2 = {
	picksLastMin = 0,
	picks = 0,
	_windowStart = 0,
	overflowAssigns = 0,
	hitsLastMin = 0,
	hits = 0,
	overflowLastMin = 0
}
local count3 = 0

local function callback20()
	local windowStart = callback19()

	if items2._windowStart == 0 then
		items2._windowStart = windowStart

		return
	end

	if windowStart - items2._windowStart >= 60000 then
		items2.hitsLastMin = items2.hits
		items2.picksLastMin = items2.picks
		items2.overflowLastMin = items2.overflowAssigns
		items2.hits = 0
		items2.picks = 0
		items2.overflowAssigns = 0
		items2._windowStart = windowStart
	end
end

local function callback21(self, text3, text5)
	if (def and def.fairyHitProbability or 100) < math.random(100) then
		return false
	end

	text5 = text5 or {}

	local text2 = text5.targetId or ""

	if text5.targetType == "player" then
		text2 = ""
	end

	local text4 = string.format("@spriteHit~%s~%s~%s~%s~%s~%s~%s", tostring(self), tostring(text3), tostring(text5.styleIdx or 0), tostring(text5.targetType or ""), tostring(text2), tostring(text5.targetName or ""), tostring(text5.orbSeqId or 0))

	def.role.call(text4)

	items2.hits = items2.hits + 1

	callback20()

	return true
end

local function callback22(self, value3)
	if not self then
		return
	end

	local value2 = value3 == "hit" and self.hitSound or value3 == "pickup" and self.pickupSound or nil

	if not value2 or value2 == "" then
		return
	end

	if not sound or not sound.playSound then
		return
	end

	pcall(sound.playSound, value2)
end

local function callback23()
	return main_scene and main_scene.ground or nil
end

local function callback24(self)
	local value2 = callback23()

	if value2 and type(value2.__bn_has) == "function" then
		return value2.__bn_has(self) == true
	end

	return false
end

function magicParticle.setFairyBan(self)
	local value2 = callback23()

	if value2 and type(value2.__bn_set) == "function" then
		value2.__bn_set(self)
	end
end

function magicParticle.refreshFairyBan()
	local value2 = callback23()

	if value2 and type(value2.__bn_rebuild) == "function" then
		value2.__bn_rebuild()
	end
end

function magicParticle.getFairyBanSnapshot()
	local value2 = callback23()

	if value2 and type(value2.__bn_snapshot) == "function" then
		return value2.__bn_snapshot()
	end

	return {}
end

local function callback25()
	if not main_scene or not main_scene.ground or not main_scene.ground.player then
		return true
	end

	if not g_data or not g_data.map or not g_data.map.isInSafeZone then
		return false
	end

	local point = main_scene.ground.player
	local mapidOwner = main_scene.ground.map

	return g_data.map:isInSafeZone(mapidOwner.mapid, point.x, point.y)
end

local function callback26()
	if not g_data or not g_data.player then
		return true
	end

	local value2 = g_data.player.attackMode

	if not value2 or type(value2) ~= "string" then
		return true
	end

	return value2:find("和平攻击模式") ~= nil
end

local function callback27()
	if not g_data or not g_data.player then
		return 5
	end

	local value2 = g_data.player.attackMode

	if not value2 or type(value2) ~= "string" then
		return 5
	end

	if value2:find("全体攻击模式") then
		return 0
	elseif value2:find("行会攻击模式") then
		return 1
	elseif value2:find("组队攻击模式") then
		return 2
	elseif value2:find("善恶攻击模式") then
		return 3
	elseif value2:find("战队攻击模式") then
		return 4
	else
		return 5
	end
end

local function callback28(self, value2, enableAttackMonOwner)
	local items16 = {}

	if not enableAttackMonOwner or enableAttackMonOwner.enableAttackMon ~= true then
		return items16
	end

	local monsOwner = self.map

	if not monsOwner or not monsOwner.mons then
		return items16
	end

	for _, mon in pairs(monsOwner.mons) do
		if mon and not mon.die and not mon.isDummy and not mon.isHaveMaster and (not mon.isPolice or not mon:isPolice()) and (not mon.info or not mon.info.isPet or not mon.info:isPet()) then
			local dist = self:getDis(mon)

			if dist <= value2 then
				items16[#items16 + 1] = {
					role = mon,
					dist = dist
				}
			end
		end
	end

	table.sort(items16, function(distOwner, distOwner2)
		return distOwner.dist < distOwner2.dist
	end)

	return items16
end

local function callback29(self, value2, enableAttackPlayerOwner)
	local items16 = {}

	if not enableAttackPlayerOwner or enableAttackPlayerOwner.enableAttackPlayer ~= true then
		return items16
	end

	if callback26() or callback25() then
		return items16
	end

	local herosOwner = self.map

	if not herosOwner or not herosOwner.heros then
		return items16
	end

	if not main_scene or not main_scene.ground or not main_scene.ground.player then
		return items16
	end

	local value3 = callback27()
	local infoOwner = main_scene.ground.player
	local value4 = infoOwner.info and infoOwner.info.getRealName and infoOwner.info:getRealName() or ""
	local value5 = g_data.hero and g_data.hero.name or ""
	local value6 = infoOwner.info and infoOwner.info.guildName or nil
	local value7 = infoOwner.info and infoOwner.info.campId or nil

	for _, hero in pairs(herosOwner.heros) do
		if not hero.die and not hero.isPlayer and (not hero.info or not hero.info.checkHeroFromCache or not hero.info:checkHeroFromCache()) and not def.stateIsHave(hero.last and hero.last.state or 0, "stRealHidden") and not hero.isDummy then
			local value8 = hero.info and hero.info.getRealName and hero.info:getRealName() or nil

			if value8 and value8 ~= value4 and value8 ~= value5 then
				local enabled2 = false

				if value7 then
					enabled2 = hero.info.campId ~= value7
				elseif value3 == 0 then
					enabled2 = true
				elseif value3 == 1 then
					enabled2 = true

					if value6 and g_data.guild and g_data.guild.allGuildMems then
						for _2, allGuildMem in pairs(g_data.guild.allGuildMems) do
							if allGuildMem.name == value8 then
								enabled2 = false

								break
							end
						end
					end
				elseif value3 == 2 then
					enabled2 = true

					if g_data.player.groupMembers then
						for _3, groupMember in ipairs(g_data.player.groupMembers) do
							if value8 == groupMember.name then
								enabled2 = false

								break
							end
						end
					end
				elseif value3 == 3 then
					if g_data.guild and g_data.guild.guildHostile then
						for _4, guildHostile in ipairs(g_data.guild.guildHostile) do
							if hero.info.guildName == guildHostile.name then
								enabled2 = true

								break
							end
						end
					end
				elseif value3 == 4 then
					enabled2 = true

					if g_data.guild and g_data.guild.allCorpsMem then
						for _5, allCorpsMem in pairs(g_data.guild.allCorpsMem) do
							if value8 == allCorpsMem.name then
								enabled2 = false

								break
							end
						end
					end
				end

				if enabled2 and callback24(value8) then
					enabled2 = false
				end

				if enabled2 then
					local dist = self:getDis(hero)

					if dist <= value2 then
						items16[#items16 + 1] = {
							role = hero,
							dist = dist
						}
					end
				end
			end
		end
	end

	table.sort(items16, function(distOwner, distOwner2)
		return distOwner.dist < distOwner2.dist
	end)

	return items16
end

local items10 = {
	attack = {
		core = {
			1,
			0.3,
			0.2,
			1
		},
		glow = {
			1,
			0.4,
			0.3,
			0.55
		}
	},
	pickup = {
		core = {
			0.3,
			0.5,
			1,
			1
		},
		glow = {
			0.3,
			0.55,
			1,
			0.55
		}
	},
	returning = {
		core = {
			1,
			1,
			1,
			1
		},
		glow = {
			0.7,
			0.82,
			1,
			0.55
		}
	}
}

local function callback30(self, value3, value4)
	value4 = math.max(0, math.min(1, value4))

	local value2 = 1 - value4

	return {
		core = {
			self.core[1] * value2 + value3.core[1] * value4,
			self.core[2] * value2 + value3.core[2] * value4,
			self.core[3] * value2 + value3.core[3] * value4,
			self.core[4] * value2 + value3.core[4] * value4
		},
		glow = {
			self.glow[1] * value2 + value3.glow[1] * value4,
			self.glow[2] * value2 + value3.glow[2] * value4,
			self.glow[3] * value2 + value3.glow[3] * value4,
			self.glow[4] * value2 + value3.glow[4] * value4
		}
	}
end

local items14 = {
	white = {
		1,
		1,
		1
	},
	blue = {
		0.4,
		0.65,
		1.4
	},
	red = {
		1.45,
		0.4,
		0.35
	},
	green = {
		0.45,
		1.4,
		0.55
	},
	purple = {
		1.1,
		0.4,
		1.45
	},
	gold = {
		1.45,
		1.15,
		0.35
	},
	silver = {
		0.95,
		1,
		1.2
	},
	cyan = {
		0.35,
		1.3,
		1.4
	},
	black = {
		0.4,
		0.4,
		0.55
	},
	dark = {
		0.55,
		0.45,
		0.65
	},
	blood = {
		1.4,
		0.25,
		0.18
	},
	orange = {
		1.45,
		0.85,
		0.3
	},
	jade = {
		0.55,
		1.3,
		0.95
	},
	pink = {
		1.4,
		0.75,
		1.1
	}
}
local items11 = {}

local function callback31(self)
	if type(self) == "string" then
		local value2 = items14[self]

		if not value2 and not items11[self] then
			items11[self] = true

			print(string.format("[magicParticle] unknown tint preset %q, fallback to no-tint", self))
		end

		return value2
	end

	if type(self) == "table" then
		return self
	end

	return nil
end

local function callback32(self)
	if not self then
		return nil
	end

	local value2 = callback31(self.tint)

	if not value2 then
		return nil
	end

	local value3 = value2[1] or 1
	local value4 = value2[2] or 1
	local value5 = value2[3] or 1

	if value3 == 1 and value4 == 1 and value5 == 1 then
		return nil
	end

	local value6 = self.tintStrength or 0.65
	local value7 = 1 - value6
	local callback42 = cc.c4f

	return function(value22, value32, value42, value52)
		return callback42(value22 * value7 + value22 * value3 * value6, value32 * value7 + value32 * value4 * value6, value42 * value7 + value42 * value5 * value6, value52)
	end
end

local value
local number = 22
local items15 = {
	1.375,
	1.375,
	0.6666666666666666,
	1,
	1,
	0.8148148148148148,
	0.8461538461538461,
	1.2222222222222223,
	1,
	0.6451612903225806
}
local items5 = {
	_cy = 0,
	_k = 1,
	_cx = 0
}
local index = {
	drawDot = function(value2, point, value4, value6)
		local value3 = value2._k
		local x = value2._cx
		local value5 = value2._cy

		value2._dn:drawDot(cc.p(x + (point.x - x) * value3, value5 + (point.y - value5) * value3), value4 * value3, value6)
	end,
	drawSegment = function(value2, point, point2, value5, value6)
		local value3 = value2._k
		local x = value2._cx
		local value4 = value2._cy

		value2._dn:drawSegment(cc.p(x + (point.x - x) * value3, value4 + (point.y - value4) * value3), cc.p(x + (point2.x - x) * value3, value4 + (point2.y - value4) * value3), value5 * value3, value6)
	end
}

index.__index = index

setmetatable(items5, index)

local items4 = {}

local function callback33(self, x, y, value4, value6, value8)
	local callback42 = value or cc.c4f
	local value2 = math.sin(value6 * (value8.freq or 7) + (value8.phase or 0)) * 0.5 + 0.5
	local value3 = y + (value8.shoulderY or 4)
	local value5 = value8.shoulderGap or 4
	local value7 = (value8.span or 16) * (0.78 + value2 * 0.48)
	local value9 = (value8.rise or 8) * (0.55 + value2 * 0.75)
	local value10 = (value8.drop or 4) * (0.85 - value2 * 0.35)
	local value11 = value8.thickness or 2.6
	local value12 = value8.fillLines or 4
	local value13 = value8.outer or {
		0.7,
		0.7,
		0.7
	}
	local value14 = value8.inner or value13
	local value15 = value8.highlight or value14
	local value16 = value8.shape == "membrane"

	for index2 = -1, 1, 2 do
		local x2 = x + index2 * value5
		local y2 = value3
		local point = cc.p(x + index2 * value7, y + value9)
		local point2 = cc.p(x + index2 * (value7 * 0.82), y - value10)
		local point3 = cc.p(x + index2 * (value7 * 0.52), y + (value9 - value10) * 0.2 + (value8.midLift or 1.5))

		self:drawSegment(cc.p(x2, y2), point, value11, callback42(value13[1], value13[2], value13[3], value4 * (value8.outerAlpha or 0.78)))
		self:drawSegment(cc.p(x2, y2), point2, value11 * 0.82, callback42(value14[1], value14[2], value14[3], value4 * (value8.innerAlpha or 0.56)))

		if value16 then
			self:drawSegment(point, point2, value11 * 0.52, callback42(value15[1], value15[2], value15[3], value4 * (value8.edgeAlpha or 0.45)))

			for index3 = 1, value12 do
				local value17 = index3 / (value12 + 1)
				local value18 = point.x + (point2.x - point.x) * value17
				local value19 = point.y + (point2.y - point.y) * value17

				self:drawSegment(cc.p(x2, y2), cc.p(value18, value19), value11 * 0.26, callback42(value14[1], value14[2], value14[3], value4 * (value8.fillAlpha or 0.28)))
			end
		else
			self:drawSegment(cc.p(x2, y2), point3, value11 * 0.9, callback42(value14[1], value14[2], value14[3], value4 * (value8.midAlpha or 0.65)))
			self:drawSegment(point3, point, value11 * 0.52, callback42(value15[1], value15[2], value15[3], value4 * (value8.edgeAlpha or 0.52)))
			self:drawSegment(point3, point2, value11 * 0.46, callback42(value15[1], value15[2], value15[3], value4 * (value8.edgeAlpha or 0.44)))

			for index4 = 1, value12 do
				local value20 = index4 / (value12 + 1)
				local x3 = x2 + (point3.x - x2) * (0.28 + value20 * 0.55)
				local y3 = y2 + (point3.y - y2) * (0.25 + value20 * 0.6)
				local value21 = point3.x + (point.x - point3.x) * (0.18 + value20 * 0.62)
				local value22 = point3.y + (point.y - point3.y) * (0.1 + value20 * 0.72)

				self:drawSegment(cc.p(x3, y3), cc.p(value21, value22), value11 * 0.2, callback42(value15[1], value15[2], value15[3], value4 * (value8.featherAlpha or 0.26)))
			end
		end

		self:drawDot(point, value8.tipRadius or 1.5, callback42(value15[1], value15[2], value15[3], value4 * (value8.tipAlpha or 0.6)))
	end
end

items4[1] = function(value2, x, y, value5, value7, value8, value9)
	local callback42 = value or cc.c4f

	value2:drawDot(cc.p(x, y), 16, callback42(0.9, 0.7, 0.2, value8 * 0.08))
	callback33(value2, x, y, value8, value9, {
		outerAlpha = 0.84,
		shoulderGap = 4,
		freq = 7,
		shoulderY = 3,
		innerAlpha = 0.62,
		fillLines = 4,
		drop = 5,
		tipAlpha = 0.72,
		rise = 8,
		featherAlpha = 0.3,
		span = 14,
		thickness = 2.8,
		outer = {
			0.42,
			0.28,
			0.12
		},
		inner = {
			0.58,
			0.4,
			0.18
		},
		highlight = {
			0.88,
			0.72,
			0.3
		}
	})
	value2:drawDot(cc.p(x, y), 10, callback42(0.42, 0.28, 0.15, value8))
	value2:drawDot(cc.p(x, y + 1), 8, callback42(0.55, 0.38, 0.2, value8))
	value2:drawDot(cc.p(x, y + 2), 6, callback42(0.68, 0.5, 0.28, value8))
	value2:drawDot(cc.p(x, y - 1), 4.5, callback42(0.82, 0.72, 0.52, value8 * 0.9))
	value2:drawDot(cc.p(x, y - 2), 3, callback42(0.9, 0.82, 0.65, value8 * 0.85))
	value2:drawDot(cc.p(x - 3.5, y + 4), 4, callback42(0.38, 0.22, 0.1, value8 * 0.6))
	value2:drawDot(cc.p(x + 3.5, y + 4), 4, callback42(0.38, 0.22, 0.1, value8 * 0.6))
	value2:drawDot(cc.p(x - 3.5, y + 4), 3.2, callback42(0.92, 0.75, 0.08, value8))
	value2:drawDot(cc.p(x + 3.5, y + 4), 3.2, callback42(0.92, 0.75, 0.08, value8))
	value2:drawDot(cc.p(x - 3.5, y + 4), 1.8, callback42(0.1, 0.06, 0.02, value8))
	value2:drawDot(cc.p(x + 3.5, y + 4), 1.8, callback42(0.1, 0.06, 0.02, value8))
	value2:drawDot(cc.p(x - 3, y + 4.5), 0.8, callback42(1, 1, 1, value8 * 0.9))
	value2:drawDot(cc.p(x + 3, y + 4.5), 0.8, callback42(1, 1, 1, value8 * 0.9))
	value2:drawDot(cc.p(x, y + 1.5), 1.8, callback42(0.85, 0.62, 0.12, value8))
	value2:drawSegment(cc.p(x, y + 1.5), cc.p(x + 0.5, y - 0.5), 1, callback42(0.75, 0.55, 0.1, value8))
	value2:drawSegment(cc.p(x - 2.5, y + 8), cc.p(x - 3.5, y + 12), 1.5, callback42(0.42, 0.28, 0.15, value8))
	value2:drawSegment(cc.p(x + 2.5, y + 8), cc.p(x + 3.5, y + 12), 1.5, callback42(0.42, 0.28, 0.15, value8))

	local value3 = math.sin(value9 * 4.5)
	local value4 = math.cos(value9 * 5)
	local value6 = math.sin(value9 * 3.8)

	value2:drawDot(cc.p(x - 13 + value3 * 2, y + 9 + value4 * 3), 1.5, callback42(1, 0.9, 0.2, value8 * (0.5 + math.abs(value3) * 0.4)))
	value2:drawDot(cc.p(x + 14 + value4 * 2, y + 7 + value3 * 2), 1.2, callback42(1, 0.85, 0.15, value8 * (0.4 + math.abs(value4) * 0.4)))
	value2:drawDot(cc.p(x + 5 + value6, y + 14 + value4 * 2), 1, callback42(1, 0.92, 0.25, value8 * (0.3 + math.abs(value6) * 0.4)))
end
items4[3] = function(value2, x, y, value5, value7, value9, value10)
	local callback42 = value or cc.c4f
	local value3 = math.sin(value10 * 8) * 0.5 + 0.5

	value2:drawDot(cc.p(x, y), 30, callback42(0.25, 0.75, 1, value9 * 0.06))
	value2:drawDot(cc.p(x, y), 22, callback42(0.4, 0.88, 1, value9 * 0.12))
	value2:drawDot(cc.p(x, y), 15, callback42(0.55, 0.95, 1, value9 * 0.18))
	callback33(value2, x, y, value9, value10, {
		shoulderGap = 5,
		rise = 15,
		freq = 5,
		shoulderY = 4,
		featherAlpha = 0.28,
		innerAlpha = 0.74,
		fillLines = 5,
		drop = 7,
		tipAlpha = 0.82,
		outerAlpha = 0.56,
		midLift = 3,
		span = 28,
		thickness = 3.8,
		outer = {
			0.3,
			0.75,
			1
		},
		inner = {
			0.55,
			0.9,
			1
		},
		highlight = {
			0.88,
			0.98,
			1
		}
	})

	local value4 = 11 + (math.sin(value10 * 5) * 0.5 + 0.5) * 9

	for index2 = -1, 1, 2 do
		value2:drawSegment(cc.p(x + index2 * 10, y + 7), cc.p(x + index2 * 16, y + value4 * 0.85), 1.9, callback42(0.78, 0.96, 1, value9 * 0.8))
		value2:drawSegment(cc.p(x + index2 * 17, y + value4 * 0.35), cc.p(x + index2 * 24, y + value4 * 0.72), 1.5, callback42(0.72, 0.94, 1, value9 * 0.74))
		value2:drawSegment(cc.p(x + index2 * 24, y + value4 * 0.82), cc.p(x + index2 * 22, y + value4 + 6), 1.2, callback42(0.92, 0.99, 1, value9 * 0.82))
	end

	value2:drawDot(cc.p(x, y), 11, callback42(0.18, 0.55, 0.88, value9))
	value2:drawDot(cc.p(x, y + 2), 9, callback42(0.28, 0.7, 0.98, value9))
	value2:drawDot(cc.p(x, y + 4), 6, callback42(0.45, 0.85, 1, value9))
	value2:drawDot(cc.p(x, y + 6), 4, callback42(0.65, 0.95, 1, value9))
	value2:drawDot(cc.p(x, y + 8), 5, callback42(0.25, 0.68, 0.95, value9))
	value2:drawDot(cc.p(x, y + 10), 4, callback42(0.38, 0.78, 1, value9))
	value2:drawDot(cc.p(x, y + 13), 6, callback42(0.2, 0.62, 0.92, value9))
	value2:drawDot(cc.p(x, y + 14), 4, callback42(0.38, 0.78, 1, value9))
	value2:drawSegment(cc.p(x - 3, y + 16), cc.p(x - 6, y + 25), 2, callback42(0.65, 0.92, 1, value9))
	value2:drawSegment(cc.p(x, y + 16), cc.p(x, y + 28), 2.5, callback42(0.8, 0.98, 1, value9))
	value2:drawSegment(cc.p(x + 3, y + 16), cc.p(x + 6, y + 25), 2, callback42(0.65, 0.92, 1, value9))
	value2:drawSegment(cc.p(x - 5, y + 12), cc.p(x - 12, y + 14), 1.5, callback42(0.55, 0.88, 1, value9 * 0.85))
	value2:drawSegment(cc.p(x + 5, y + 12), cc.p(x + 12, y + 14), 1.5, callback42(0.55, 0.88, 1, value9 * 0.85))
	value2:drawDot(cc.p(x - 2.8, y + 14.5), 2.2, callback42(0.9, 0.98, 1, value9))
	value2:drawDot(cc.p(x + 2.8, y + 14.5), 2.2, callback42(0.9, 0.98, 1, value9))
	value2:drawDot(cc.p(x - 2.8, y + 14.5), 1, callback42(0.2, 0.85, 1, value9))
	value2:drawDot(cc.p(x + 2.8, y + 14.5), 1, callback42(0.2, 0.85, 1, value9))

	for index3 = 1, 5 do
		local value6 = value10 * 1.8 + index3 * math.pi * 0.4
		local value8 = 20 + math.sin(value10 * 3 + index3 * 1.2) * 3

		value2:drawDot(cc.p(x + math.cos(value6) * value8, y + math.sin(value6) * value8 * 0.45), 1.2 + value3 * 0.5, callback42(0.85, 0.98, 1, value9 * (0.5 + value3 * 0.4)))
	end
end
items4[4] = function(value2, x, y, value5, value6, value7, value8)
	local callback42 = value or cc.c4f

	value2:drawDot(cc.p(x, y), 18, callback42(0.12, 0.3, 0.85, value7 * 0.07))
	callback33(value2, x, y, value7, value8, {
		shoulderGap = 4,
		rise = 10,
		freq = 8.2,
		shoulderY = 4,
		featherAlpha = 0.28,
		innerAlpha = 0.62,
		fillLines = 4,
		drop = 6,
		tipAlpha = 0.55,
		outerAlpha = 0.88,
		midLift = 2,
		span = 18,
		thickness = 3.2,
		outer = {
			0.08,
			0.15,
			0.58
		},
		inner = {
			0.15,
			0.28,
			0.75
		},
		highlight = {
			0.38,
			0.58,
			1
		}
	})
	value2:drawSegment(cc.p(x - 1, y - 4), cc.p(x - 6, y - 14), 2.8, callback42(0.08, 0.15, 0.58, value7))
	value2:drawSegment(cc.p(x, y - 5), cc.p(x, y - 15), 2.2, callback42(0.1, 0.18, 0.65, value7))
	value2:drawSegment(cc.p(x + 1, y - 4), cc.p(x + 6, y - 14), 2.8, callback42(0.08, 0.15, 0.58, value7))

	local value3 = 8 + math.abs(math.sin(value8 * 8.2)) * 7

	value2:drawSegment(cc.p(x - 4, y + 3), cc.p(x - 18, y + value3 + 2), 1.5, callback42(0.18, 0.35, 0.8, value7 * 0.6))
	value2:drawSegment(cc.p(x + 4, y + 3), cc.p(x + 18, y + value3 + 2), 1.5, callback42(0.18, 0.35, 0.8, value7 * 0.6))
	value2:drawDot(cc.p(x, y), 8, callback42(0.1, 0.18, 0.6, value7))
	value2:drawDot(cc.p(x, y + 1), 6, callback42(0.15, 0.25, 0.72, value7))
	value2:drawDot(cc.p(x, y + 2), 4, callback42(0.22, 0.35, 0.82, value7))
	value2:drawDot(cc.p(x, y + 9), 7, callback42(0.08, 0.15, 0.58, value7))
	value2:drawDot(cc.p(x, y + 10), 5.5, callback42(0.12, 0.22, 0.68, value7))
	value2:drawDot(cc.p(x - 1, y + 11), 4, callback42(0.15, 0.28, 0.75, value7))
	value2:drawSegment(cc.p(x + 4, y + 11), cc.p(x + 12, y + 11.5), 3, callback42(1, 0.78, 0.05, value7))
	value2:drawSegment(cc.p(x + 4, y + 9.5), cc.p(x + 11, y + 9.5), 2, callback42(0.88, 0.62, 0.04, value7 * 0.9))
	value2:drawDot(cc.p(x + 5.5, y + 12), 0.8, callback42(0.5, 0.3, 0.02, value7 * 0.8))
	value2:drawDot(cc.p(x + 2.5, y + 12.5), 2.2, callback42(0.05, 0.05, 0.05, value7))
	value2:drawDot(cc.p(x + 2.5, y + 12.5), 1, callback42(0.15, 0.4, 0.95, value7 * 0.5))
	value2:drawDot(cc.p(x + 3, y + 13), 0.9, callback42(1, 1, 1, value7 * 0.9))

	local value4 = 8 + math.abs(math.sin(value8 * 8.2)) * 6

	value2:drawDot(cc.p(x - 12, y + 3), value4 * 0.25, callback42(0.35, 0.55, 1, value7 * 0.3))
	value2:drawDot(cc.p(x + 12, y + 3), value4 * 0.25, callback42(0.35, 0.55, 1, value7 * 0.3))
end
items4[5] = function(value2, x, y, value5, value7, value9, value10)
	local callback42 = value or cc.c4f
	local value3 = callback42(0.38, 0.25, 0.18, value9 * 0.82)
	local value4 = callback42(0.5, 0.35, 0.24, value9 * 0.55)

	callback33(value2, x, y, value9, value10, {
		rise = 11,
		span = 22,
		edgeAlpha = 0.52,
		shoulderY = 3,
		freq = 7,
		shoulderGap = 3,
		fillLines = 5,
		innerAlpha = 0.58,
		drop = 6,
		tipAlpha = 0.34,
		outerAlpha = 0.84,
		shape = "membrane",
		fillAlpha = 0.3,
		thickness = 2.6,
		outer = {
			0.38,
			0.25,
			0.18
		},
		inner = {
			0.46,
			0.3,
			0.22
		},
		highlight = {
			0.62,
			0.42,
			0.3
		}
	})

	local value6 = 16 + (math.sin(value10 * 7) * 0.5 + 0.5) * 7
	local value8 = 7 + (math.sin(value10 * 7) * 0.5 + 0.5) * 7

	for index2 = -1, 1, 2 do
		value2:drawSegment(cc.p(x + index2 * (value6 * 0.28), y + value8 * 0.62), cc.p(x + index2 * (value6 * 0.55), y + value8 + 3), 1.1, callback42(0.5, 0.35, 0.24, value9 * 0.85))
		value2:drawSegment(cc.p(x + index2 * (value6 * 0.55), y + value8 + 3), cc.p(x + index2 * (value6 * 0.84), y + value8 * 0.68), 0.9, callback42(0.42, 0.28, 0.18, value9 * 0.78))
	end

	value2:drawDot(cc.p(x, y - 2), 5.5, callback42(0.38, 0.25, 0.16, value9))
	value2:drawDot(cc.p(x, y), 7, callback42(0.42, 0.28, 0.18, value9))
	value2:drawDot(cc.p(x, y + 1), 5.5, callback42(0.55, 0.38, 0.26, value9))
	value2:drawDot(cc.p(x, y + 2.5), 4, callback42(0.62, 0.45, 0.32, value9))
	value2:drawDot(cc.p(x, y + 8), 6, callback42(0.38, 0.25, 0.16, value9))
	value2:drawDot(cc.p(x, y + 9), 4.5, callback42(0.48, 0.32, 0.22, value9))
	value2:drawSegment(cc.p(x - 3.5, y + 11), cc.p(x - 2.5, y + 19), 1.8, callback42(0.35, 0.22, 0.14, value9))
	value2:drawSegment(cc.p(x + 3.5, y + 11), cc.p(x + 2.5, y + 19), 1.8, callback42(0.35, 0.22, 0.14, value9))
	value2:drawSegment(cc.p(x - 2.5, y + 19), cc.p(x - 4, y + 14), 1, callback42(0.7, 0.35, 0.35, value9 * 0.5))
	value2:drawSegment(cc.p(x + 2.5, y + 19), cc.p(x + 4, y + 14), 1, callback42(0.7, 0.35, 0.35, value9 * 0.5))
	value2:drawDot(cc.p(x - 2.5, y + 9.5), 2.5, callback42(0.85, 0.08, 0.05, value9))
	value2:drawDot(cc.p(x + 2.5, y + 9.5), 2.5, callback42(0.85, 0.08, 0.05, value9))
	value2:drawDot(cc.p(x - 2.5, y + 9.5), 1.2, callback42(1, 0.4, 0.25, value9))
	value2:drawDot(cc.p(x + 2.5, y + 9.5), 1.2, callback42(1, 0.4, 0.25, value9))
	value2:drawDot(cc.p(x, y + 7), 1.5, callback42(0.3, 0.18, 0.12, value9))
end
items4[6] = function(value2, x, y, value5, value7, value9, value11)
	local callback42 = value or cc.c4f
	local value3 = math.sin(value11 * 4) * 0.5 + 0.5
	local value4 = callback42(0.38, 0.78, 1, value9 * 0.92)
	local value6 = callback42(0.6, 0.92, 1, value9 * 0.72)

	value2:drawDot(cc.p(x, y), 26, callback42(0.15, 0.6, 1, value9 * (0.06 + value3 * 0.04)))
	value2:drawDot(cc.p(x, y), 17, callback42(0.25, 0.75, 1, value9 * (0.12 + value3 * 0.06)))

	local value8 = 9 + (math.sin(value11 * 5.5) * 0.5 + 0.5) * 11

	for index2 = -1, 1, 2 do
		value2:drawSegment(cc.p(x + index2 * 3, y + 4), cc.p(x + index2 * 22, y + value8), 2, value4)
		value2:drawSegment(cc.p(x + index2 * 3, y + 4), cc.p(x + index2 * 24, y + value8 * 0.48), 1.8, value4)
		value2:drawSegment(cc.p(x + index2 * 3, y + 4), cc.p(x + index2 * 19, y - 5), 1.6, value4)
		value2:drawSegment(cc.p(x + index2 * 9, y + value8 * 0.55), cc.p(x + index2 * 16, y + value8 * 0.45), 1.2, value6)
		value2:drawSegment(cc.p(x + index2 * 15, y + value8 * 0.3), cc.p(x + index2 * 20, y + value8 * 0.2), 1, value6)
		value2:drawSegment(cc.p(x + index2 * 22, y + value8), cc.p(x + index2 * 25, y + value8 + 5), 1.3, value4)
		value2:drawSegment(cc.p(x + index2 * 24, y + value8 * 0.48), cc.p(x + index2 * 27, y + value8 * 0.48 + 4), 1.1, value4)
	end

	local value10 = callback42(0.5, 0.85, 1, value9)

	for index3 = 0, 3 do
		local y2 = y - index3 * 3.8
		local value12 = 3.8 - index3 * 0.5

		value2:drawDot(cc.p(x, y2), value12, value10)
		value2:drawSegment(cc.p(x - value12 * 1.2, y2), cc.p(x + value12 * 1.2, y2), 1, value6)
	end

	value2:drawSegment(cc.p(x - 6, y + 0.5), cc.p(x + 6, y + 0.5), 1, value6)
	value2:drawSegment(cc.p(x - 6.5, y - 2), cc.p(x + 6.5, y - 2), 1, value6)
	value2:drawDot(cc.p(x, y + 5), 4.5, value10)
	value2:drawDot(cc.p(x, y + 7), 3.5, value4)
	value2:drawDot(cc.p(x, y + 12), 6.5, value4)
	value2:drawDot(cc.p(x, y + 13), 5, callback42(0.65, 0.9, 1, value9))
	value2:drawDot(cc.p(x - 2.8, y + 13.5), 2.5, callback42(0.15, 0.7, 1, value9 * (0.8 + value3 * 0.2)))
	value2:drawDot(cc.p(x + 2.8, y + 13.5), 2.5, callback42(0.15, 0.7, 1, value9 * (0.8 + value3 * 0.2)))
	value2:drawDot(cc.p(x - 2.8, y + 13.5), 1.2, callback42(0.85, 0.98, 1, value9))
	value2:drawDot(cc.p(x + 2.8, y + 13.5), 1.2, callback42(0.85, 0.98, 1, value9))
	value2:drawSegment(cc.p(x - 3.5, y + 8.5), cc.p(x + 3.5, y + 8.5), 1.5, value4)
	value2:drawSegment(cc.p(x - 3.5, y + 8.5), cc.p(x - 4.5, y + 10.5), 1.2, value4)
	value2:drawSegment(cc.p(x + 3.5, y + 8.5), cc.p(x + 4.5, y + 10.5), 1.2, value4)

	for index4 = -2, 2 do
		value2:drawSegment(cc.p(x + index4 * 1.4, y + 8.5), cc.p(x + index4 * 1.4, y + 7.2), 0.7, callback42(0.75, 0.95, 1, value9 * 0.9))
	end
end
items4[7] = function(value2, x, y, value5, value6, value7, value8)
	local callback42 = value or cc.c4f
	local value3 = math.sin(value8 * 13) * 0.5 + 0.5

	value2:drawDot(cc.p(x, y), 26, callback42(1, 0.3, 0.02, value7 * (0.08 + value3 * 0.04)))
	value2:drawDot(cc.p(x, y), 17, callback42(1, 0.52, 0.05, value7 * (0.14 + value3 * 0.06)))
	value2:drawDot(cc.p(x, y), 10, callback42(1, 0.72, 0.1, value7 * 0.2))
	value2:drawSegment(cc.p(x - 2, y - 4), cc.p(x - 10, y - 20), 3, callback42(1, 0.42, 0.04, value7 * 0.92))
	value2:drawSegment(cc.p(x, y - 5), cc.p(x, y - 22), 2.5, callback42(1, 0.65, 0.08, value7 * 0.92))
	value2:drawSegment(cc.p(x + 2, y - 4), cc.p(x + 10, y - 20), 3, callback42(1, 0.42, 0.04, value7 * 0.92))
	value2:drawSegment(cc.p(x - 1, y - 4), cc.p(x - 15, y - 17), 2, callback42(1, 0.62, 0.08, value7 * 0.8))
	value2:drawSegment(cc.p(x + 1, y - 4), cc.p(x + 15, y - 17), 2, callback42(1, 0.62, 0.08, value7 * 0.8))
	value2:drawDot(cc.p(x - 10, y - 20), 2, callback42(1, 0.9, 0.3, value7 * (0.6 + value3 * 0.4)))
	value2:drawDot(cc.p(x, y - 22), 2, callback42(1, 0.92, 0.35, value7 * (0.7 + value3 * 0.3)))
	value2:drawDot(cc.p(x + 10, y - 20), 2, callback42(1, 0.9, 0.3, value7 * (0.6 + value3 * 0.4)))
	callback33(value2, x, y, value7, value8, {
		shoulderGap = 5,
		featherAlpha = 0.34,
		freq = 7.2,
		shoulderY = 5,
		innerAlpha = 0.72,
		fillLines = 5,
		drop = 5,
		tipAlpha = 0.86,
		rise = 15,
		midLift = 2.8,
		span = 24,
		thickness = 4,
		outer = {
			1,
			0.35,
			0.03
		},
		inner = {
			1,
			0.62,
			0.08
		},
		highlight = {
			1,
			0.9,
			0.24
		},
		outerAlpha = 0.92 + value3 * 0.05
	})

	local value4 = 11 + math.abs(math.sin(value8 * 7.2)) * 9

	value2:drawSegment(cc.p(x - 4, y + 4), cc.p(x - 16, y + value4), 2, callback42(1, 0.9, 0.24, value7 * 0.72))
	value2:drawSegment(cc.p(x + 4, y + 4), cc.p(x + 16, y + value4), 2, callback42(1, 0.9, 0.24, value7 * 0.72))
	value2:drawDot(cc.p(x, y), 9, callback42(0.82, 0.22, 0.04, value7))
	value2:drawDot(cc.p(x, y + 1), 7, callback42(0.98, 0.38, 0.06, value7))
	value2:drawDot(cc.p(x, y + 3), 5, callback42(1, 0.6, 0.1, value7))
	value2:drawDot(cc.p(x, y + 4), 3, callback42(1, 0.8, 0.2, value7))
	value2:drawDot(cc.p(x + 1, y + 10), 6, callback42(0.8, 0.2, 0.04, value7))
	value2:drawDot(cc.p(x + 1, y + 11), 4.5, callback42(0.98, 0.35, 0.06, value7))
	value2:drawDot(cc.p(x + 1, y + 12), 3, callback42(1, 0.58, 0.1, value7))
	value2:drawSegment(cc.p(x, y + 14), cc.p(x - 2, y + 21 + value3 * 2), 2, callback42(1, 0.72, 0.08, value7))
	value2:drawSegment(cc.p(x + 1, y + 14), cc.p(x + 4, y + 20 + value3 * 1.5), 1.5, callback42(1, 0.55, 0.05, value7))
	value2:drawDot(cc.p(x - 2, y + 21 + value3 * 2), 1.5, callback42(1, 0.95, 0.4, value7 * (0.6 + value3 * 0.4)))
	value2:drawSegment(cc.p(x + 5, y + 12), cc.p(x + 11, y + 12.5), 2, callback42(1, 0.82, 0.1, value7))
	value2:drawDot(cc.p(x + 4, y + 13.5), 2, callback42(1, 0.9, 0.15, value7))
	value2:drawDot(cc.p(x + 4, y + 13.5), 0.9, callback42(0.05, 0.02, 0.02, value7))
end
items4[8] = function(value2, x, value4, value6, value7, value9, value11)
	local callback42 = value or cc.c4f
	local value3 = math.sin(value11 * 5.5) * 0.4
	local value5 = math.sin(value11 * 4.5) * 3
	local y = value4 + math.sin(value11 * 3) * 1.5

	value2:drawDot(cc.p(x, y), 18, callback42(1, 0.65, 0.7, value9 * 0.08))
	value2:drawDot(cc.p(x, y), 12, callback42(1, 0.72, 0.78, value9 * 0.12))

	local value8 = callback42(0.95, 0.52, 0.6, value9 * 0.85)

	value2:drawSegment(cc.p(x - 7, y + value5 * 0.3), cc.p(x - 17, y + 8 + value5), 2.5, value8)
	value2:drawSegment(cc.p(x - 7, y + value5 * 0.3), cc.p(x - 18, y - 5 + value5), 2.5, value8)
	value2:drawSegment(cc.p(x - 17, y + 8 + value5), cc.p(x - 18, y - 5 + value5), 1.5, value8)

	for index2 = 0.1, 0.9, 0.2 do
		local value10 = (y + 8 + value5) * index2 + (y - 5 + value5) * (1 - index2)

		value2:drawSegment(cc.p(x - 7, y + value5 * 0.3), cc.p(x - 17, value10), 1, callback42(1, 0.62, 0.7, value9 * 0.35))
	end

	value2:drawDot(cc.p(x - 2, y), 9, callback42(0.96, 0.68, 0.73, value9))
	value2:drawDot(cc.p(x, y), 8, callback42(1, 0.74, 0.78, value9))
	value2:drawDot(cc.p(x + 3, y), 7, callback42(1, 0.78, 0.82, value9))
	value2:drawDot(cc.p(x + 5, y), 5.5, callback42(1, 0.82, 0.85, value9))
	value2:drawDot(cc.p(x + 1, y - 2), 5, callback42(1, 0.9, 0.92, value9 * 0.88))
	value2:drawDot(cc.p(x + 2, y - 3), 3, callback42(1, 0.94, 0.96, value9 * 0.8))

	local value12 = callback42(0.9, 0.52, 0.6, value9 * 0.88)

	value2:drawSegment(cc.p(x - 2, y + 7), cc.p(x - 4, y + 16 + value3 * 3), 1.8, value12)
	value2:drawSegment(cc.p(x + 1, y + 7), cc.p(x, y + 15 + value3 * 2), 1.8, value12)
	value2:drawSegment(cc.p(x + 4, y + 7), cc.p(x + 5, y + 13 + value3 * 2), 1.8, value12)
	value2:drawSegment(cc.p(x - 4, y + 16 + value3 * 3), cc.p(x + 5, y + 13 + value3 * 2), 1.2, value12)

	local value13 = callback42(1, 0.7, 0.76, value9 * 0.8)

	value2:drawSegment(cc.p(x - 1, y + 2), cc.p(x - 11, y + 5 + value3 * 2), 2, value13)
	value2:drawSegment(cc.p(x - 1, y - 1), cc.p(x - 11, y + 1 + value3 * 1.5), 1.5, value13)
	value2:drawSegment(cc.p(x - 11, y + 5 + value3 * 2), cc.p(x - 11, y + 1 + value3 * 1.5), 1, value13)
	value2:drawDot(cc.p(x + 9, y + 1), 5, callback42(1, 0.78, 0.82, value9))
	value2:drawDot(cc.p(x + 12, y), 3.5, callback42(1, 0.8, 0.84, value9))
	value2:drawDot(cc.p(x + 14, y - 0.5), 2, callback42(0.96, 0.76, 0.8, value9))
	value2:drawDot(cc.p(x + 14.5, y - 0.5), 1.5, callback42(0.85, 0.42, 0.5, value9 * 0.8))
	value2:drawDot(cc.p(x + 8.5, y + 3.5), 3.5, callback42(1, 0.62, 0.68, value9 * 0.4))
	value2:drawDot(cc.p(x + 8.5, y + 3.5), 2.5, callback42(0.15, 0.08, 0.08, value9))
	value2:drawDot(cc.p(x + 8.5, y + 3.5), 1.2, callback42(0.38, 0.15, 0.15, value9 * 0.8))
	value2:drawDot(cc.p(x + 9, y + 4.2), 0.6, callback42(1, 1, 1, value9 * 0.95))

	local value14 = math.sin(value11 * 1.8) * 3

	value2:drawDot(cc.p(x + 16, y + value14 + 2), 1.2, callback42(0.88, 0.72, 0.82, value9 * 0.55))
	value2:drawDot(cc.p(x + 18, y + value14 - 1), 0.8, callback42(0.92, 0.78, 0.85, value9 * 0.45))
end
items4[9] = function(value2, value3, y, value5, value7, value9, value10)
	local callback42 = value or cc.c4f
	local value4 = math.sin(value10 * 18) * 0.8
	local x = value3 + value4 * 0.4

	value2:drawDot(cc.p(x, y), 22, callback42(0.5, 0.1, 0.8, value9 * 0.08))
	value2:drawDot(cc.p(x, y), 14, callback42(0.62, 0.18, 0.95, value9 * 0.15))
	callback33(value2, x, y, value9, value10, {
		outerAlpha = 0.54,
		span = 19,
		edgeAlpha = 0.66,
		shoulderY = 6,
		freq = 14,
		shoulderGap = 3,
		fillLines = 4,
		shape = "membrane",
		drop = 3,
		innerAlpha = 0.42,
		tipAlpha = 0.4,
		rise = 11,
		midLift = 1,
		fillAlpha = 0.24,
		thickness = 2.8,
		outer = {
			0.68,
			0.52,
			1
		},
		inner = {
			0.82,
			0.7,
			1
		},
		highlight = {
			0.95,
			0.88,
			1
		}
	})

	local value6 = 10 + (math.sin(value10 * 14) * 0.5 + 0.5) * 8

	value2:drawSegment(cc.p(x - 10, y + value6 * 0.5), cc.p(x - 18, y + value6 * 0.8), 0.8, callback42(0.9, 0.8, 1, value9 * 0.6))
	value2:drawSegment(cc.p(x - 14, y + value6 * 0.25), cc.p(x - 19, y + value6 * 0.5), 0.7, callback42(0.9, 0.8, 1, value9 * 0.5))
	value2:drawSegment(cc.p(x + 10, y + value6 * 0.5), cc.p(x + 18, y + value6 * 0.8), 0.8, callback42(0.9, 0.8, 1, value9 * 0.6))
	value2:drawSegment(cc.p(x + 14, y + value6 * 0.25), cc.p(x + 19, y + value6 * 0.5), 0.7, callback42(0.9, 0.8, 1, value9 * 0.5))
	value2:drawDot(cc.p(x, y - 2), 6, callback42(0.58, 0.42, 0.05, value9))
	value2:drawDot(cc.p(x, y - 2), 4.5, callback42(0.78, 0.6, 0.08, value9))
	value2:drawSegment(cc.p(x - 5, y - 1.5), cc.p(x + 5, y - 1.5), 1.2, callback42(0.22, 0.15, 0.02, value9 * 0.9))
	value2:drawSegment(cc.p(x - 5.5, y - 4), cc.p(x + 5.5, y - 4), 1.2, callback42(0.22, 0.15, 0.02, value9 * 0.9))
	value2:drawDot(cc.p(x, y - 7), 4, callback42(0.72, 0.55, 0.1, value9))
	value2:drawDot(cc.p(x, y - 10), 2.8, callback42(0.65, 0.48, 0.08, value9))
	value2:drawDot(cc.p(x, y - 13), 1.5, callback42(0.4, 0.28, 0.05, value9 * 0.9))
	value2:drawDot(cc.p(x, y + 4), 8, callback42(0.38, 0.1, 0.62, value9))
	value2:drawDot(cc.p(x, y + 5), 6, callback42(0.5, 0.15, 0.8, value9))
	value2:drawDot(cc.p(x, y + 6), 4, callback42(0.62, 0.22, 0.95, value9))
	value2:drawSegment(cc.p(x - 5, y + 5), cc.p(x + 5, y + 5), 0.8, callback42(0.72, 0.45, 1, value9 * 0.5))
	value2:drawSegment(cc.p(x - 4, y + 2), cc.p(x + 4, y + 2), 0.8, callback42(0.72, 0.45, 1, value9 * 0.4))
	value2:drawDot(cc.p(x, y + 11), 6, callback42(0.35, 0.08, 0.58, value9))
	value2:drawDot(cc.p(x, y + 12), 4.5, callback42(0.48, 0.14, 0.75, value9))
	value2:drawSegment(cc.p(x - 2.5, y + 14.5), cc.p(x - 7, y + 22), 1.3, callback42(0.55, 0.25, 0.8, value9))
	value2:drawSegment(cc.p(x + 2.5, y + 14.5), cc.p(x + 7, y + 22), 1.3, callback42(0.55, 0.25, 0.8, value9))
	value2:drawDot(cc.p(x - 7, y + 22), 2, callback42(0.8, 0.5, 1, value9 * (0.8 + value4 * 0.1)))
	value2:drawDot(cc.p(x + 7, y + 22), 2, callback42(0.8, 0.5, 1, value9 * (0.8 + value4 * 0.1)))
	value2:drawDot(cc.p(x - 3.5, y + 12.5), 2.5, callback42(0.15, 0.75, 1, value9))
	value2:drawDot(cc.p(x + 3.5, y + 12.5), 2.5, callback42(0.15, 0.75, 1, value9))
	value2:drawDot(cc.p(x - 3.5, y + 12.5), 1, callback42(0.9, 0.98, 1, value9 * 0.9))
	value2:drawDot(cc.p(x + 3.5, y + 12.5), 1, callback42(0.9, 0.98, 1, value9 * 0.9))

	local value8 = math.sin(value10 * 6 + 1.2)

	value2:drawDot(cc.p(x - 20 + value8, y + value6 * 0.7), 1.2, callback42(0.9, 0.8, 1, value9 * (0.5 + math.abs(value8) * 0.3)))
	value2:drawDot(cc.p(x + 20 - value8, y + value6 * 0.5), 1, callback42(0.9, 0.8, 1, value9 * (0.4 + math.abs(value8) * 0.2)))
end
items4[10] = function(value2, x, y, value5, value7, value8, value9)
	local callback42 = value or cc.c4f

	value2:drawDot(cc.p(x, y), 22, callback42(0.62, 0.06, 0.02, value8 * 0.08))

	local value3 = 9 + (math.sin(value9 * 5.5) * 0.5 + 0.5) * 10
	local value4 = callback42(0.42, 0.18, 0.06, value8 * 0.88)
	local value6 = callback42(0.62, 0.28, 0.1, value8 * 0.92)

	for index2 = -1, 1, 2 do
		value2:drawSegment(cc.p(x + index2 * 4, y + 5), cc.p(x + index2 * 22, y + value3), 3.5, value4)
		value2:drawSegment(cc.p(x + index2 * 4, y + 5), cc.p(x + index2 * 25, y + value3 * 0.48), 3, value4)
		value2:drawSegment(cc.p(x + index2 * 4, y + 5), cc.p(x + index2 * 18, y - 4), 2.5, value4)
		value2:drawSegment(cc.p(x + index2 * 22, y + value3), cc.p(x + index2 * 25, y + value3 * 0.48), 1.8, value6)
		value2:drawSegment(cc.p(x + index2 * 25, y + value3 * 0.48), cc.p(x + index2 * 18, y - 4), 1.8, value6)
		value2:drawSegment(cc.p(x + index2 * 12, y + value3 * 0.55), cc.p(x + index2 * 16, y + value3 * 0.92), 2, value6)
		value2:drawSegment(cc.p(x + index2 * 18, y + value3 * 0.28), cc.p(x + index2 * 23, y + value3 * 0.62), 1.8, value6)
		value2:drawSegment(cc.p(x + index2 * 22, y + value3), cc.p(x + index2 * 26, y + value3 + 7), 2, value6)
	end

	value2:drawDot(cc.p(x, y - 2), 7, callback42(0.32, 0.1, 0.04, value8))
	value2:drawDot(cc.p(x, y), 10, callback42(0.35, 0.12, 0.05, value8))
	value2:drawDot(cc.p(x, y + 2), 8, callback42(0.45, 0.16, 0.06, value8))
	value2:drawDot(cc.p(x, y + 4), 6.5, callback42(0.55, 0.22, 0.08, value8))
	value2:drawDot(cc.p(x, y + 5.5), 4.5, callback42(0.65, 0.28, 0.1, value8))
	value2:drawSegment(cc.p(x - 7.5, y + 2), cc.p(x + 7.5, y + 2), 1.2, callback42(0.22, 0.07, 0.03, value8 * 0.92))
	value2:drawSegment(cc.p(x - 7, y - 1), cc.p(x + 7, y - 1), 1.2, callback42(0.22, 0.07, 0.03, value8 * 0.92))
	value2:drawSegment(cc.p(x - 6, y - 4), cc.p(x + 6, y - 4), 1, callback42(0.22, 0.07, 0.03, value8 * 0.85))
	value2:drawSegment(cc.p(x - 5, y + 4.5), cc.p(x - 1, y + 4), 0.8, callback42(0.75, 0.38, 0.14, value8 * 0.7))
	value2:drawSegment(cc.p(x + 1, y + 4), cc.p(x + 5, y + 4.5), 0.8, callback42(0.75, 0.38, 0.14, value8 * 0.7))
	value2:drawDot(cc.p(x, y + 8), 7, callback42(0.38, 0.14, 0.06, value8))
	value2:drawDot(cc.p(x, y + 10), 5.5, callback42(0.48, 0.18, 0.07, value8))
	value2:drawDot(cc.p(x, y + 12), 4.5, callback42(0.55, 0.22, 0.08, value8))
	value2:drawSegment(cc.p(x - 4.5, y + 9), cc.p(x + 4.5, y + 9), 1, callback42(0.22, 0.07, 0.03, value8 * 0.85))
	value2:drawSegment(cc.p(x - 4, y + 11.5), cc.p(x + 4, y + 11.5), 0.9, callback42(0.22, 0.07, 0.03, value8 * 0.85))
	value2:drawDot(cc.p(x, y + 16), 8, callback42(0.38, 0.14, 0.06, value8))
	value2:drawDot(cc.p(x, y + 17), 6.5, callback42(0.48, 0.18, 0.07, value8))
	value2:drawDot(cc.p(x, y + 18), 5, callback42(0.58, 0.24, 0.09, value8))
	value2:drawSegment(cc.p(x - 3.5, y + 14), cc.p(x + 3.5, y + 14), 1.5, callback42(0.42, 0.16, 0.06, value8))
	value2:drawSegment(cc.p(x - 4, y + 20), cc.p(x - 6, y + 29), 2.5, callback42(0.4, 0.14, 0.05, value8))
	value2:drawSegment(cc.p(x, y + 21), cc.p(x, y + 31), 2.8, callback42(0.5, 0.18, 0.07, value8))
	value2:drawSegment(cc.p(x + 4, y + 20), cc.p(x + 6, y + 29), 2.5, callback42(0.4, 0.14, 0.05, value8))
	value2:drawDot(cc.p(x - 6, y + 29), 1.2, callback42(0.75, 0.4, 0.15, value8 * 0.8))
	value2:drawDot(cc.p(x, y + 31), 1.5, callback42(0.8, 0.45, 0.18, value8 * 0.9))
	value2:drawDot(cc.p(x + 6, y + 29), 1.2, callback42(0.75, 0.4, 0.15, value8 * 0.8))
	value2:drawDot(cc.p(x - 3.2, y + 18), 3, callback42(0.92, 0.38, 0.02, value8))
	value2:drawDot(cc.p(x + 3.2, y + 18), 3, callback42(0.92, 0.38, 0.02, value8))
	value2:drawDot(cc.p(x - 3.2, y + 18), 1.5, callback42(1, 0.82, 0.08, value8))
	value2:drawDot(cc.p(x + 3.2, y + 18), 1.5, callback42(1, 0.82, 0.08, value8))
	value2:drawDot(cc.p(x - 3.2, y + 18), 0.6, callback42(1, 1, 0.6, value8 * 0.9))
	value2:drawDot(cc.p(x + 3.2, y + 18), 0.6, callback42(1, 1, 0.6, value8 * 0.9))
end
items4[2] = function(value2, x, y, value3, value4, value5, value6)
	local callback42 = value or cc.c4f

	callback33(value2, x, y, value5, value6, {
		outerAlpha = 0.86,
		shoulderGap = 3,
		freq = 8.5,
		shoulderY = 3,
		innerAlpha = 0.62,
		fillLines = 4,
		drop = 5,
		tipAlpha = 0.6,
		rise = 7,
		featherAlpha = 0.3,
		span = 12,
		thickness = 2.5,
		outer = {
			0.52,
			0.2,
			0.08
		},
		inner = {
			0.68,
			0.32,
			0.12
		},
		highlight = {
			0.92,
			0.62,
			0.22
		}
	})
	value2:drawSegment(cc.p(x - 1, y - 4), cc.p(x - 7, y - 15), 2.5, callback42(0.48, 0.18, 0.07, value5))
	value2:drawSegment(cc.p(x, y - 5), cc.p(x, y - 16), 2, callback42(0.55, 0.22, 0.09, value5))
	value2:drawSegment(cc.p(x + 1, y - 4), cc.p(x + 7, y - 15), 2.5, callback42(0.48, 0.18, 0.07, value5))
	value2:drawSegment(cc.p(x - 1, y - 4), cc.p(x - 13, y - 13), 1.5, callback42(0.6, 0.28, 0.1, value5 * 0.7))
	value2:drawSegment(cc.p(x + 1, y - 4), cc.p(x + 13, y - 13), 1.5, callback42(0.6, 0.28, 0.1, value5 * 0.7))
	value2:drawDot(cc.p(x, y), 7, callback42(0.58, 0.22, 0.09, value5))
	value2:drawDot(cc.p(x, y + 1), 5, callback42(0.72, 0.32, 0.13, value5))
	value2:drawDot(cc.p(x, y + 2), 3, callback42(0.82, 0.42, 0.18, value5))
	value2:drawDot(cc.p(x - 1, y - 1), 2.8, callback42(0.78, 0.55, 0.3, value5 * 0.8))
	value2:drawDot(cc.p(x + 1, y + 8), 5.5, callback42(0.55, 0.2, 0.08, value5))
	value2:drawDot(cc.p(x + 1, y + 9), 4, callback42(0.68, 0.28, 0.11, value5))
	value2:drawSegment(cc.p(x, y + 12), cc.p(x - 1, y + 16), 1.3, callback42(0.72, 0.3, 0.12, value5 * 0.9))
	value2:drawSegment(cc.p(x + 1, y + 12), cc.p(x + 3, y + 15), 1, callback42(0.65, 0.25, 0.1, value5 * 0.8))
	value2:drawSegment(cc.p(x + 4.5, y + 9.5), cc.p(x + 11, y + 10), 2, callback42(0.88, 0.68, 0.15, value5))
	value2:drawSegment(cc.p(x + 4.5, y + 8), cc.p(x + 10, y + 8.5), 1.3, callback42(0.75, 0.58, 0.12, value5 * 0.9))
	value2:drawDot(cc.p(x + 3.5, y + 10.5), 1.8, callback42(0.05, 0.05, 0.05, value5))
	value2:drawDot(cc.p(x + 4, y + 11), 0.7, callback42(1, 1, 1, value5 * 0.9))
end
items4[11] = function(value2, x, y, value5, value7, value8, value9)
	local callback42 = value or cc.c4f

	value2:drawDot(cc.p(x, y + 2), 14, callback42(0.8, 1, 0.85, value8 * 0.07))
	value2:drawDot(cc.p(x, y + 2), 10, callback42(0.85, 1, 0.9, value8 * 0.12))

	local value3 = math.sin(value9 * 4.5) * 1.5

	value2:drawSegment(cc.p(x - 3, y - 3), cc.p(x - 4 + value3, y - 14), 1.2, callback42(0.55, 0.78, 0.6, value8))
	value2:drawSegment(cc.p(x + 3, y - 3), cc.p(x + 4 - value3, y - 14), 1.2, callback42(0.55, 0.78, 0.6, value8))
	value2:drawSegment(cc.p(x - 2, y - 2), cc.p(x - 3 + value3 * 0.6, y - 11), 1, callback42(0.48, 0.7, 0.55, value8 * 0.8))
	value2:drawSegment(cc.p(x + 2, y - 2), cc.p(x + 3 - value3 * 0.6, y - 11), 1, callback42(0.48, 0.7, 0.55, value8 * 0.8))
	value2:drawDot(cc.p(x, y), 6.5, callback42(0.5, 0.75, 0.58, value8))
	value2:drawDot(cc.p(x, y + 1), 5, callback42(0.65, 0.88, 0.72, value8))
	value2:drawDot(cc.p(x, y + 2), 3.5, callback42(0.82, 0.98, 0.88, value8))
	value2:drawDot(cc.p(x, y + 7), 3.8, callback42(0.55, 0.8, 0.63, value8))
	value2:drawDot(cc.p(x, y + 11), 3.5, callback42(0.7, 0.92, 0.78, value8))
	value2:drawDot(cc.p(x, y + 12), 2.8, callback42(0.88, 1, 0.92, value8))

	local value4 = math.sin(value9 * 2) * 0.5

	value2:drawSegment(cc.p(x - 1, y + 14), cc.p(x - 6, y + 22 + value4), 1, callback42(0.62, 0.85, 0.68, value8))
	value2:drawSegment(cc.p(x - 4, y + 19 + value4), cc.p(x - 9, y + 23 + value4), 0.8, callback42(0.55, 0.78, 0.62, value8 * 0.85))
	value2:drawSegment(cc.p(x - 4, y + 19 + value4), cc.p(x - 2, y + 24 + value4), 0.8, callback42(0.55, 0.78, 0.62, value8 * 0.85))
	value2:drawSegment(cc.p(x + 1, y + 14), cc.p(x + 6, y + 22 + value4), 1, callback42(0.62, 0.85, 0.68, value8))
	value2:drawSegment(cc.p(x + 4, y + 19 + value4), cc.p(x + 9, y + 23 + value4), 0.8, callback42(0.55, 0.78, 0.62, value8 * 0.85))
	value2:drawSegment(cc.p(x + 4, y + 19 + value4), cc.p(x + 2, y + 24 + value4), 0.8, callback42(0.55, 0.78, 0.62, value8 * 0.85))
	value2:drawDot(cc.p(x + 2, y + 12), 1.5, callback42(0.2, 0.9, 0.6, value8))
	value2:drawDot(cc.p(x + 2, y + 12), 0.6, callback42(1, 1, 1, value8 * 0.85))

	local value6 = math.sin(value9 * 5) * 0.3 + 0.7

	value2:drawDot(cc.p(x + 5, y - 1), 2, callback42(0.9, 1, 0.95, value8 * value6))
end
items4[12] = function(value2, x, y, value5, value6, value7, value8)
	local callback42 = value or cc.c4f
	local value3 = math.sin(value8 * 9) * 6

	value2:drawDot(cc.p(x - 10 - value3, y + 6), 7, callback42(0.72, 0.18, 0.12, value7 * 0.75))
	value2:drawDot(cc.p(x - 10 - value3, y + 6), 5, callback42(0.85, 0.3, 0.2, value7 * 0.6))
	value2:drawDot(cc.p(x + 10 + value3, y + 6), 7, callback42(0.72, 0.18, 0.12, value7 * 0.75))
	value2:drawDot(cc.p(x + 10 + value3, y + 6), 5, callback42(0.85, 0.3, 0.2, value7 * 0.6))
	value2:drawSegment(cc.p(x - 5, y + 8), cc.p(x - 14 - value3 * 1.2, y + 3), 1, callback42(0.9, 0.4, 0.3, value7 * 0.5))
	value2:drawSegment(cc.p(x + 5, y + 8), cc.p(x + 14 + value3 * 1.2, y + 3), 1, callback42(0.9, 0.4, 0.3, value7 * 0.5))
	value2:drawSegment(cc.p(x - 3, y - 5), cc.p(x - 7, y - 10), 2.5, callback42(0.65, 0.15, 0.1, value7))
	value2:drawSegment(cc.p(x - 7, y - 10), cc.p(x - 4, y - 16), 2, callback42(0.58, 0.12, 0.08, value7))
	value2:drawSegment(cc.p(x - 4, y - 16), cc.p(x - 8, y - 20), 1.5, callback42(0.52, 0.1, 0.07, value7 * 0.85))
	value2:drawDot(cc.p(x, y), 8, callback42(0.68, 0.16, 0.11, value7))
	value2:drawDot(cc.p(x, y + 1), 6, callback42(0.8, 0.24, 0.16, value7))
	value2:drawDot(cc.p(x, y + 2), 4, callback42(0.92, 0.38, 0.25, value7))
	value2:drawDot(cc.p(x, y - 1), 4.5, callback42(0.95, 0.7, 0.5, value7 * 0.75))
	value2:drawDot(cc.p(x, y - 2), 3, callback42(1, 0.82, 0.65, value7 * 0.6))
	value2:drawDot(cc.p(x + 2, y + 9), 6.5, callback42(0.65, 0.15, 0.1, value7))
	value2:drawDot(cc.p(x + 2, y + 10), 5, callback42(0.78, 0.22, 0.14, value7))
	value2:drawDot(cc.p(x + 2, y + 11), 3.5, callback42(0.9, 0.35, 0.22, value7))
	value2:drawSegment(cc.p(x, y + 15), cc.p(x - 2, y + 20), 1, callback42(0.82, 0.32, 0.18, value7))
	value2:drawSegment(cc.p(x + 4, y + 15), cc.p(x + 6, y + 20), 1, callback42(0.82, 0.32, 0.18, value7))
	value2:drawDot(cc.p(x + 5, y + 12), 2, callback42(1, 0.85, 0.1, value7))
	value2:drawDot(cc.p(x + 5, y + 12), 0.8, callback42(0.05, 0.05, 0.05, value7))

	local value4 = math.sin(value8 * 14) * 0.4 + 0.6

	value2:drawDot(cc.p(x + 10, y + 10), 4.5, callback42(1, 0.65, 0.08, value7 * value4 * 0.8))
	value2:drawDot(cc.p(x + 13, y + 11), 2.8, callback42(1, 0.85, 0.3, value7 * value4 * 0.65))
	value2:drawDot(cc.p(x + 16, y + 10), 1.5, callback42(1, 0.95, 0.7, value7 * value4 * 0.45))
end
items4[13] = function(value2, x, y, value5, value7, value8, value10)
	local callback42 = value or cc.c4f
	local value3 = math.sin(value10 * 2.8) * 0.5 + 0.5
	local value4 = 10 + value3 * 3

	value2:drawDot(cc.p(x, y + 4), value4 + 8, callback42(0.4, 0.7, 1, value8 * 0.06))
	value2:drawDot(cc.p(x, y + 4), value4 + 4, callback42(0.55, 0.82, 1, value8 * 0.1))
	value2:drawDot(cc.p(x, y + 4), value4, callback42(0.3, 0.6, 0.95, value8 * 0.55))
	value2:drawDot(cc.p(x, y + 5), value4 - 2, callback42(0.5, 0.78, 1, value8 * 0.5))
	value2:drawDot(cc.p(x, y + 7), value4 - 4, callback42(0.7, 0.92, 1, value8 * 0.4))

	local value6 = value10 * 0.5

	value2:drawSegment(cc.p(x - 6, y + 6), cc.p(x + 6, y + 6), 1.2, callback42(0.6 + math.sin(value6) * 0.3, 0.8, 1, value8 * 0.3))
	value2:drawSegment(cc.p(x - 5, y + 4), cc.p(x + 5, y + 4), 1, callback42(0.8, 0.6 + math.sin(value6 + 2) * 0.3, 1, value8 * 0.25))
	value2:drawDot(cc.p(x, y), value4 * 0.7, callback42(0.2, 0.5, 0.88, value8 * 0.45))

	for index2 = 1, 8 do
		local x2 = x + (index2 - 4.5) * 2.8
		local value9 = math.sin(value10 * 3.5 + index2 * 0.8) * 4
		local value11 = 12 + math.sin(value10 * 2.8 + index2 * 0.5) * 4
		local value12 = value8 * (0.3 + math.sin(value10 * 2.5 + index2) * 0.15)

		value2:drawSegment(cc.p(x2, y), cc.p(x2 + value9, y - value11), 0.8, callback42(0.4 + index2 * 0.06, 0.75, 1, value12))
	end

	value2:drawDot(cc.p(x, y + 6), 3, callback42(0.9, 0.98, 1, value8 * (0.5 + value3 * 0.4)))
	value2:drawDot(cc.p(x, y + 6), 1.2, callback42(1, 1, 1, value8 * (0.8 + value3 * 0.2)))
end

local function callback34(dn, value2, cy, value3, value4, value6, value8)
	if not dn or tolua.isnull(dn) then
		return
	end

	local callback42 = cc.c4f

	value8 = value8 or 0

	local cx = value2 + 3
	local text2 = value4 and value4.fairyStyle or 0

	if text2 > 0 and items4[text2] then
		value = value4 and value4.__tintC4f or nil

		local k = value4 and value4.visualScale or items15[text2] or 1
		local value5 = dn

		if k ~= 1 then
			items5._dn = dn
			items5._k = k
			items5._cx = cx
			items5._cy = cy
			value5 = items5
		end

		local value7, text3 = pcall(items4[text2], value5, cx, cy, value3, value4, value6, value8)

		value = nil
		items5._dn = nil

		if not value7 then
			print("[fairy] draw style=" .. tostring(text2) .. " failed: " .. tostring(text3))
		end

		return
	end

	local x = cx
	local value9 = value4.bodyRadius or 5
	local value10 = value4.wingSpan or 11
	local value11 = value4.glowRadius or 24
	local value12 = value3.core
	local value13 = value3.glow

	dn:drawDot(cc.p(x, cy), value11, callback42(value13[1], value13[2], value13[3], value13[4] * value6 * 0.15))
	dn:drawDot(cc.p(x, cy), value11 * 0.6, callback42(value13[1], value13[2], value13[3], value13[4] * value6 * 0.25))

	local value14 = value10 * (math.sin(value8 * 8) * 0.35 + 0.55)
	local value15 = value9 * 0.8
	local value16 = callback42(value13[1], value13[2], value13[3], value13[4] * value6 * 0.75)
	local x2 = x - value15
	local point = cc.p(x2, cy + value14 * 0.3)
	local point2 = cc.p(x2 - value10 * 0.85, cy + value14 * 0.7)
	local point3 = cc.p(x2 - value10 * 0.25, cy - value14 * 0.15)

	for index2 = 0, 1, 0.05 do
		local x3 = point.x + (point2.x - point.x) * index2
		local y = point.y + (point2.y - point.y) * index2
		local value17 = point3.x + (point2.x - point3.x) * index2
		local value18 = point3.y + (point2.y - point3.y) * index2

		dn:drawSegment(cc.p(x3, y), cc.p(value17, value18), 0.8, value16)
	end

	local x4 = x + value15
	local point4 = cc.p(x4, cy + value14 * 0.3)
	local point5 = cc.p(x4 + value10 * 0.85, cy + value14 * 0.7)
	local point6 = cc.p(x4 + value10 * 0.25, cy - value14 * 0.15)

	for index3 = 0, 1, 0.05 do
		local x5 = point4.x + (point5.x - point4.x) * index3
		local y2 = point4.y + (point5.y - point4.y) * index3
		local value19 = point6.x + (point5.x - point6.x) * index3
		local value20 = point6.y + (point5.y - point6.y) * index3

		dn:drawSegment(cc.p(x5, y2), cc.p(value19, value20), 0.8, value16)
	end

	dn:drawDot(cc.p(x, cy), value9, callback42(value12[1], value12[2], value12[3], value12[4] * value6))
	dn:drawDot(cc.p(x - value9 * 0.2, cy + value9 * 0.3), value9 * 0.35, callback42(1, 1, 1, value6 * 0.85))

	local value21 = math.sin(value8 * 5) * 2
	local y3 = cy - value9 - 2

	dn:drawDot(cc.p(x - 2.5 - value21, y3), 2, callback42(value12[1], value12[2], value12[3], value12[4] * value6 * 0.8))
	dn:drawDot(cc.p(x + 2.5 + value21, y3), 2, callback42(value12[1], value12[2], value12[3], value12[4] * value6 * 0.8))
end

local function callback35(self, value3, value5, value6)
	if not self or tolua.isnull(self.node) then
		return
	end

	local value2 = self.sprites

	if not value2 then
		return
	end

	local value4 = cc.c3b(value3, value5, value6)

	for _, item in pairs(value2) do
		if item and item.spr and not tolua.isnull(item.spr) then
			item.spr:setColor(value4)
		end
	end

	self.node:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
		if tolua.isnull(self.node) then
			return
		end

		for _, sprite in pairs(self.sprites) do
			if sprite and sprite.spr and not tolua.isnull(sprite.spr) then
				sprite.spr:setColor(display.COLOR_WHITE)
			end
		end
	end)))
end

local function cleanup(self, value2, value3)
	if not self or not self.items then
		return
	end

	for _, item in pairs(self.items) do
		if item.x == value2 and item.y == value3 and item.spr and not tolua.isnull(item.spr) then
			item.spr:setColor(cc.c3b(80, 140, 255))
			item.spr:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
				if item.spr and not tolua.isnull(item.spr) then
					item.spr:setColor(display.COLOR_WHITE)
				end
			end)))

			return
		end
	end
end

local function cleanup2(node, x, y, value4, value6)
	if not node or tolua.isnull(node) then
		return
	end

	if not cc.DrawNode or not cc.c4f then
		return
	end

	local node2 = cc.DrawNode:create()

	node2:setPosition(cc.p(x, y))

	if node2.setBlendFunc and gl then
		pcall(function()
			node2:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
		end)
	end

	node:addChild(node2, 9999)

	local value2 = value6.explodeDuration or 0.4
	local value3 = value6.explodeArcCount or 6
	local value5 = value6.explodeArcLen or 25
	local count = 0
	local duration = 0.04

	node2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
		if tolua.isnull(node2) then
			return
		end

		count = count + duration

		local value22 = count / value2

		if value22 >= 1 then
			node2:stopAllActions()
			node2:removeSelf()

			return
		end

		node2:clear()

		local value32 = 1 - value22 * value22
		local callback42 = cc.c4f

		for index2 = 1, value3 do
			local value42 = (index2 - 1) / value3 * math.pi * 2 + math.random() * 0.3
			local value52 = value5 * (0.5 + math.random() * 0.5) * (0.3 + value22 * 0.7)
			local value62 = math.cos(value42) * value52
			local value7 = math.sin(value42) * value52 * 0.5
			local x2 = callback13(0, 0, value62, value7, 8, 4, 0.5)
			local value8 = value4.core
			local value9 = value4.glow

			for index3 = 1, #x2 - 1 do
				node2:drawSegment(cc.p(x2[index3].x, x2[index3].y), cc.p(x2[index3 + 1].x, x2[index3 + 1].y), 0.8, callback42(value9[1], value9[2], value9[3], value9[4] * value32))
				node2:drawSegment(cc.p(x2[index3].x, x2[index3].y), cc.p(x2[index3 + 1].x, x2[index3 + 1].y), 0.3, callback42(value8[1], value8[2], value8[3], value8[4] * value32))
			end
		end

		local value10 = value4.core
		local value11 = 4 * (1 - value22)

		node2:drawDot(cc.p(0, 0), value11, callback42(value10[1], value10[2], value10[3], value32))
	end))))
end

local function cleanup3(node, x, y, value2)
	if not node or tolua.isnull(node) then
		return
	end

	if not cc.DrawNode or not cc.c4f then
		return
	end

	local node2 = cc.DrawNode:create()

	node2:setPosition(cc.p(x, y))

	if node2.setBlendFunc and gl then
		pcall(function()
			node2:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
		end)
	end

	node:addChild(node2, 9999)

	local count = 0
	local number2 = 0.35
	local items16 = {}

	for index2 = 1, 8 do
		local angle = (index2 - 1) / 8 * math.pi * 2 + math.random() * 0.3

		items16[index2] = {
			angle = angle,
			speed = 30 + math.random() * 40,
			size = 1 + math.random() * 0.5
		}
	end

	node2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.03), cc.CallFunc:create(function()
		if tolua.isnull(node2) then
			return
		end

		count = count + 0.03

		local value22 = count / number2

		if value22 >= 1 then
			node2:stopAllActions()
			node2:removeSelf()

			return
		end

		node2:clear()

		local value3 = 1 - value22
		local callback42 = cc.c4f
		local value4 = value2.core
		local value5 = value2.glow

		for _, item in ipairs(items16) do
			local value6 = item.speed * count
			local x2 = math.cos(item.angle) * value6
			local y2 = math.sin(item.angle) * value6 * 0.6
			local value7 = item.size * (1 - value22 * 0.5)

			node2:drawDot(cc.p(x2, y2), value7 + 1, callback42(value5[1], value5[2], value5[3], value5[4] * value3 * 0.4))
			node2:drawDot(cc.p(x2, y2), value7, callback42(value4[1], value4[2], value4[3], value4[4] * value3))
		end
	end))))
end

local function callback36(self, value3, value5, value6)
	local value2
	local value4 = (value5.detectRange or 5) + 1
	local enabled2 = false
	local value7 = value5.attackPriority == "player"
	local value8 = callback28(self, value5.detectRange or 5, value5)

	for _, item in ipairs(value8) do
		if not value6[item.role.roleid] and (value4 > item.dist or item.dist == value4 and not enabled2 and not value7) then
			value2 = item.role
			value4 = item.dist
			enabled2 = not value7
		end
	end

	local value9 = callback29(self, value5.detectRange or 5, value5)

	for _2, item2 in ipairs(value9) do
		if not value6[item2.role.roleid] and (value4 > item2.dist or item2.dist == value4 and not enabled2 and value7) then
			value2 = item2.role
			value4 = item2.dist
			enabled2 = value7
		end
	end

	return value2
end

local function cleanup4(self, value3, value5, value7, value8, value9, value10, value11, value12)
	local value2 = 1 - self
	local value4 = value2 * value2
	local value6 = self * self

	return value4 * value2 * value3 + 3 * value4 * self * value7 + 3 * value2 * value6 * value9 + value6 * self * value11, value4 * value2 * value5 + 3 * value4 * self * value8 + 3 * value2 * value6 * value10 + value6 * self * value12
end

local count2 = 0

local function cleanup5(self, x, y, number3)
	if not self or not self.addLight2 then
		return
	end

	if not self.setDark or not self.setDark.control then
		return
	end

	if (self.opacity or 0) <= 0 then
		return
	end

	count2 = count2 + 1

	local roleid = "_fj_hit_" .. count2
	local items16 = {
		roleid = roleid,
		x = x,
		y = y
	}
	local number2 = tonumber(number3.hitLightScaleMin) or 0.5
	local number4 = tonumber(number3.hitLightScaleMax) or 2
	local number5 = tonumber(number3.hitLightExpand) or 0.15
	local number6 = tonumber(number3.hitLightFade) or 0.35
	local value2 = number5 + number6
	local count = 0
	local value3 = number2
	local value4 = self.layers and self.layers.obj

	if not value4 or tolua.isnull(value4) then
		return
	end

	local node = display.newNode()

	node:addto(value4)
	node:run(cc.RepeatForever:create(transition.sequence({
		cc.DelayTime:create(0.01),
		cc.CallFunc:create(function()
			if count < value2 then
				if count < number5 then
					local value22 = count / number5

					value3 = number2 + (number4 - number2) * value22
				else
					local value32 = (count - number5) / number6

					value3 = number4 * (1 - value32 * value32)
				end

				if value3 < 0.05 then
					value3 = 0.05
				end

				self:addLight2(items16, "magic", value3)

				count = count + 0.02
			else
				self:removeLight("magic", roleid)

				if not tolua.isnull(node) and tolua.cast(node, "cc.Node") then
					node:stopAllActions()
					node:removeSelf()
				end
			end
		end)
	})))
end

local callback
local callback3

local function updateVisible(self, value3, x, y, value5, value6, value7, value8, number4, callback42, value11)
	local value2 = self.orbs[value3]

	if not value2 then
		return
	end

	local number2 = value2._perCfg or number4
	local value4 = value2._sprite and not tolua.isnull(value2._sprite)
	local flyNode
	local ghostSprites

	if value4 then
		local node = value2._sprite

		node:retain()
		node:removeFromParent(false)
		value7.layers.obj:addChild(node, 9999)
		node:release()
		node:setVisible(true)
		node:setOpacity(255)
		node:setPosition(cc.p(x, y))

		flyNode = node
		value2._flyUsesSprite = true
		value2._ghostSprites = nil

		callback(value2)

		if value11 ~= "returning" then
			local number3 = tonumber(number2.penetrateDist) or 20
			local value9 = math.sqrt((value5 - x)^2 + (value6 - y)^2)

			if value9 > 1 then
				value5 = value5 + (value5 - x) / value9 * number3
				value6 = value6 + (value6 - y) / value9 * number3
			end
		end

		local number5 = 4

		ghostSprites = {}

		local value10 = value2._spriteScale or 1
		local spriteFrame

		pcall(function()
			spriteFrame = value2._sprite:getSpriteFrame()
		end)

		for index2 = 1, number5 do
			local node2

			pcall(function()
				if spriteFrame then
					node2 = cc.Sprite:createWithSpriteFrame(spriteFrame)
				else
					node2 = cc.Sprite:create()
				end
			end)

			if node2 then
				node2:setAnchorPoint(cc.p(0.5, 0.5))
				node2:setScale(value10)
				node2:setOpacity(0)
				node2:setVisible(false)
				value7.layers.obj:addChild(node2, 9998)

				ghostSprites[index2] = node2
			end
		end

		value2._ghostSprites = ghostSprites
	else
		flyNode = cc.DrawNode:create()

		if flyNode.setBlendFunc and gl then
			pcall(function()
				flyNode:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
			end)
		end

		flyNode:setPosition(cc.p(x, y))
		value7.layers.obj:addChild(flyNode, 9999)
	end

	value2._flyNode = flyNode

	local value12 = value5 - x
	local value13 = value6 - y
	local value14 = math.sqrt(value12 * value12 + value13 * value13)
	local value15 = number2.flySpeed or number4.flySpeed or 600
	local value16 = math.max(0.15, value14 / value15)
	local value17 = number2.flyCurvature or 0.4
	local value18 = -value13 * value17
	local value19 = value12 * value17
	local value20 = x + value12 * 0.5 + value18
	local value21 = y + value13 * 0.5 + value19
	local value22 = number2.flyCurve == "bezier"
	local count = 0
	local count4 = 0
	local count5 = 0
	local count6 = 0

	if value22 then
		local number6 = tonumber(number2.bezierForwardDist) or 200
		local number7 = tonumber(number2.bezierBackDist) or 150
		local value23 = math.min(600, math.max(50, number6))
		local value24 = math.min(600, math.max(50, number7))
		local value25
		local value26

		if value2.angle then
			value25 = -math.sin(value2.angle)
			value26 = math.cos(value2.angle) * (number4.orbYScale or 0.5)

			local value27 = math.sqrt(value25 * value25 + value26 * value26)

			if value27 > 0.001 then
				value25, value26 = value25 / value27, value26 / value27
			else
				value25, value26 = 0, 0
			end
		end

		if not value25 or value25 == 0 and value26 == 0 then
			local value28 = math.max(1, value14)

			value25, value26 = value12 / value28, value13 / value28
		end

		count, count4 = x + value25 * value23, y + value26 * value23
		count5, count6 = value5 + value25 * value24, value6 + value26 * value24
	end

	local number8 = tonumber(number4.maxStrayDistance) or 1000
	local number9 = 0.1
	local count7 = 0
	local count8 = 0
	local t = self.elapsed or 0
	local flyLightKey
	local number10 = tonumber(number4.flyLightScale) or 1.3

	if value7 and value7.addLight2 and value7.setDark and value7.setDark.control and (value7.opacity or 0) > 0 and value4 and value11 == "attack" then
		count2 = count2 + 1
		flyLightKey = "_fj_fly_" .. count2
		value2._flyLightKey = flyLightKey
	end

	local value29 = value11 and items10[value11] and items10[value11] or nil
	local items16 = {}
	local number11 = 6
	local count9 = 0

	flyNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(function()
		if tolua.isnull(flyNode) then
			return
		end

		count8 = count8 + 0.016
		t = t + 0.016

		local value23 = math.min(1, count8 / value16)

		count7 = count7 + 0.016

		if count7 >= number9 then
			count7 = 0

			local point = self.role

			if point and not tolua.isnull(point.node) and value7 and value7.getMapPos then
				local mapPos, mapPos2 = value7:getMapPos(point.x, point.y)
				local positionX = flyNode:getPositionX()
				local positionY = flyNode:getPositionY()
				local value32 = positionX - mapPos
				local value42 = positionY - mapPos2

				if value32 * value32 + value42 * value42 > number8 * number8 then
					value23 = 1
				end
			end
		end

		local x2
		local y2

		if value22 then
			x2, y2 = cleanup4(value23, x, y, count, count4, count5, count6, value5, value6)
		else
			local value52 = 1 - value23

			x2 = value52 * value52 * x + 2 * value52 * value23 * value20 + value23 * value23 * value5
			y2 = value52 * value52 * y + 2 * value52 * value23 * value21 + value23 * value23 * value6
		end

		count9 = count9 + 1

		if count9 % 2 == 0 then
			table.insert(items16, 1, {
				x = x2,
				y = y2,
				t = t
			})

			if #items16 > number11 then
				table.remove(items16)
			end
		end

		flyNode:setPosition(cc.p(x2, y2))

		if flyLightKey then
			value7:addLight2({
				roleid = flyLightKey,
				x = x2,
				y = y2
			}, "magic", number10)
		end

		if value4 then
			local value62
			local value72 = x2 - (items16[1] and items16[1].x or x)
			local value82 = y2 - (items16[1] and items16[1].y or y)

			if value72 ~= 0 or value82 ~= 0 then
				value62 = math.deg(math.atan2(value82, value72))

				local rotateByAngleOwner = value2._perCfg and value2._perCfg.frameAnim or number4.frameAnim

				if rotateByAngleOwner and rotateByAngleOwner.rotateByAngle ~= false then
					flyNode:setRotation(-value62)
				end
			end

			if ghostSprites then
				for index2 = 1, #ghostSprites do
					local node = ghostSprites[index2]

					if node and not tolua.isnull(node) then
						local x22 = items16[index2]

						if x22 then
							node:setVisible(true)
							node:setPosition(cc.p(x22.x, x22.y))
							node:setOpacity(math.floor(180 * (1 - index2 / (#ghostSprites + 1))))

							if value62 then
								node:setRotation(-value62)
							end
						else
							node:setVisible(false)
						end
					end
				end
			end
		else
			flyNode:clear()

			local value9 = value8

			if value29 then
				local value10 = math.min(1, value23 / 0.3)

				value9 = callback30(value8, value29, value10)
			end

			local value112 = value2._perCfg or number4

			for index3 = #items16, 1, -1 do
				local point2 = items16[index3]
				local value122 = (1 - (index3 - 1) / number11) * 0.55
				local value132 = point2.x - x2
				local value142 = point2.y - y2

				callback34(flyNode, value132, value142, value9, value112, value122, point2.t)
			end

			callback34(flyNode, 0, 0, value9, value112, 1, t)
		end

		if value23 >= 1 then
			flyNode:stopAllActions()

			if flyLightKey then
				value7:removeLight("magic", flyLightKey)

				flyLightKey = nil
				value2._flyLightKey = nil
			end

			if ghostSprites then
				for index4 = 1, #ghostSprites do
					local value152 = ghostSprites[index4]

					if value152 and not tolua.isnull(value152) then
						value152:stopAllActions()
						value152:removeSelf()
					end
				end

				ghostSprites = nil
				value2._ghostSprites = nil
			end

			if value4 then
				if value2._m2sprAni then
					local dataAnimOwner = value2._perCfg or number4
					local value162 = dataAnimOwner and dataAnimOwner.dataAnim

					if value162 then
						local lastDir = self.role and self.role.dir or 0

						value2._lastDir = lastDir

						callback3(value2._m2sprAni, value162, lastDir)
					end
				end

				if value2._animData and not tolua.isnull(flyNode) then
					local value172 = value2._animData
					local items162 = {}

					for index5 = value172.frameBegin, value172.frameEnd do
						local text2 = string.format(value172.format, index5)
						local value182, value192 = pcall(res.gettex2, text2)

						if value182 and value192 then
							local size = value192:getContentSize()
							local rect = cc.SpriteFrame:createWithTexture(value192, cc.rect(0, 0, size.width, size.height))

							if rect then
								items162[#items162 + 1] = rect
							end
						end
					end

					if #items162 > 1 then
						local withSpriteFrames = cc.Animation:createWithSpriteFrames(items162, value172.delay)

						if withSpriteFrames then
							flyNode:runForever(cc.Animate:create(withSpriteFrames))
						end
					end
				end

				local node2 = self.container

				if node2 and not tolua.isnull(node2) then
					flyNode:retain()
					flyNode:removeFromParent(false)
					node2:addChild(flyNode)
					flyNode:release()
				end

				flyNode:setRotation(0)
				flyNode:setVisible(false)

				value2._flyUsesSprite = nil
			else
				flyNode:removeSelf()
			end

			value2._flyNode = nil

			if callback42 then
				callback42(value5, value6)
			end
		end
	end))))
end

local function callback37(self, value3, value4, value5, value6, value8, value10)
	local value2 = self.orbs[value3]

	if not value2 then
		return
	end

	local point = self.role

	if not point or tolua.isnull(point.node) then
		return
	end

	local mapPos, mapPos2 = value6:getMapPos(point.x, point.y)
	local value7 = mapPos + (value2.lastScreenX or 0) + 16
	local value9 = mapPos2 + (value2.lastScreenY or 0) + 32

	value2.returning = true

	updateVisible(self, value3, value4, value5, value7, value9, value6, value8, value10, function()
		value2.visible = true
		value2.flying = false
		value2.returning = false
		value2.chainHits = 0
		value2.hitTargets = nil
		value2.lockedTarget = nil
		value2.lockedItemKey = nil
	end, "returning")
end

local function callback38(self, orbSeqId, value3, value5, value6, value7, value8)
	local value2 = self.orbs[orbSeqId]

	if not value2 then
		return
	end

	local nodeOwner = self.role

	if not nodeOwner or tolua.isnull(nodeOwner.node) then
		return
	end

	value2.chainHits = (value2.chainHits or 0) + 1

	local value4 = value8.chainHitMax or 3
	local player

	if value4 > value2.chainHits then
		player = callback36(nodeOwner, value6, value8, value2.hitTargets or {})
	end

	if player then
		value2.hitTargets[player.roleid] = true
		value2.lockedTarget = player.roleid

		local mapPos, mapPos2 = value6:getMapPos(player.x, player.y)
		local value9 = mapPos
		local value10 = mapPos2 + 32
		local value11 = player.x
		local value12 = player.y
		local targetType = player.__cname == "mon" and "mon" or "player"
		local targetName = player.info and player.info.getRealName and player.info:getRealName() or player.name or ""
		local items16 = {
			styleIdx = self.orbitStyleIdx or 0,
			targetType = targetType,
			targetId = player.roleid or "",
			targetName = targetName,
			orbSeqId = orbSeqId
		}

		updateVisible(self, orbSeqId, value3, value5, value9, value10, value6, value7, value8, function(value22, value32)
			if callback21(value11, value12, items16) then
				if value8.hitFlash ~= false then
					callback35(player, 255, 60, 60)
				end

				callback22(value8, "hit")
			end

			callback38(self, orbSeqId, value22, value32, value6, value7, value8)
		end, "attack")
	else
		callback37(self, orbSeqId, value3, value5, value6, value7, value8)
	end
end

local function callback39(self, orbSeqId, lockedTarget, value3, value4, hitFlashOwner)
	local value2 = self.orbs[orbSeqId]

	if not value2 or value2.flying then
		return
	end

	value2.flying = true
	value2.visible = false
	value2.chainHits = 0
	value2.hitTargets = {
		[lockedTarget.roleid] = true
	}
	value2.lockedTarget = lockedTarget.roleid

	local point = self.role

	if not point or tolua.isnull(point.node) then
		return
	end

	local mapPos, mapPos2 = value3:getMapPos(point.x, point.y)
	local value5 = mapPos + value2.lastScreenX + 16
	local value6 = mapPos2 + value2.lastScreenY + 32
	local mapPos3, mapPos4 = value3:getMapPos(lockedTarget.x, lockedTarget.y)
	local value7 = mapPos3
	local value8 = mapPos4 + 32
	local value9 = lockedTarget.x
	local value10 = lockedTarget.y
	local targetType = lockedTarget.__cname == "mon" and "mon" or "player"
	local targetName = lockedTarget.info and lockedTarget.info.getRealName and lockedTarget.info:getRealName() or lockedTarget.name or ""
	local value11 = value2._perCfg
	local items16 = {
		styleIdx = self.orbitStyleIdx or 0,
		targetType = targetType,
		targetId = lockedTarget.roleid or "",
		targetName = targetName,
		orbSeqId = orbSeqId
	}

	updateVisible(self, orbSeqId, value5, value6, value7, value8, value3, value4, hitFlashOwner, function(value22, value32)
		if callback21(value9, value10, items16) then
			if hitFlashOwner.hitFlash ~= false then
				callback35(lockedTarget, 255, 60, 60)
			end

			callback22(hitFlashOwner, "hit")
			cleanup5(value3, value7, value8, hitFlashOwner)
		end

		callback38(self, orbSeqId, value22, value32, value3, value4, hitFlashOwner)
	end, "attack")
end

local function callback40(self, itemsOwner, value3)
	local items16 = {}

	if value3 and value3.enableItemPickup == false then
		return items16
	end

	if def and def.fairyPickupGlobalOff then
		return items16
	end

	if not itemsOwner or not itemsOwner.items then
		return items16
	end

	if not main_scene or not main_scene.ui or not main_scene.ui.console or not main_scene.ui.console.autoRat then
		return items16
	end

	local value2 = value3.itemDetectRange or 8
	local value4 = g_data and g_data.player and g_data.player.ability
	local value5 = value4 and value4.get and value4:get("weight") or 0
	local value6 = (value4 and value4.get and value4:get("maxWeight") or 0) + 100000
	local value7 = g_data and g_data.bag and g_data.bag.getFreeCount and g_data.bag:getFreeCount() or 0
	local value8 = main_scene.ui.console.autoRat
	local value9 = value8.modifyProperty
	local enabled2 = false

	pcall(function()
		enabled2 = g_data.setting.getGoodAttItemSetting().pickOnRatting
	end)

	for _, item in pairs(itemsOwner.items) do
		if item and item.x and item.y then
			local value10 = math.abs(item.x - self.x)
			local value11 = math.abs(item.y - self.y)

			if value10 <= value2 and value11 <= value2 then
				local value12 = item.itemName
				local value13 = value12 == "金币" or value12 == "金币1"

				if not value8:getTempData(item, "cannotPick") and (value13 or value5 < value6 and value7 > 0) then
					local enabled3 = false

					if item.state and item.state > 0 and enabled2 then
						enabled3 = true
					end

					if not enabled3 and value12 and (def.pickAllItems or value9 and value9[value12]) then
						enabled3 = true
					end

					if not enabled3 and value13 then
						enabled3 = true
					end

					if enabled3 then
						items16[#items16 + 1] = item
					end
				end
			end
		end
	end

	return items16
end

local function callback41(self, value3, lockedItemKey, value4, value5, number2)
	local value2 = self.orbs[value3]

	if not value2 or value2.flying then
		return
	end

	value2.flying = true
	value2.visible = false
	value2._pickupCount = 0
	value2.lockedItemKey = tostring(lockedItemKey.x) .. "," .. tostring(lockedItemKey.y)

	local point = self.role

	if not point or tolua.isnull(point.node) then
		return
	end

	local mapPos, mapPos2 = value4:getMapPos(point.x, point.y)
	local value6 = mapPos + value2.lastScreenX + 16
	local value7 = mapPos2 + value2.lastScreenY + 32
	local mapPos3, mapPos4 = value4:getMapPos(lockedItemKey.x, lockedItemKey.y)
	local value8 = mapPos3 + 24
	local value9 = mapPos4 + 16
	local param = lockedItemKey.x
	local tag = lockedItemKey.y
	local number3 = tonumber(number2.maxChainPickup) or 10

	local function callback42(self2, value22)
		if net and net.send and CM_PICKUP then
			net.send({
				CM_PICKUP,
				param = param,
				tag = tag
			})

			items2.picks = items2.picks + 1

			callback20()
			callback22(number2, "pickup")
		end

		cleanup(value4, param, tag)

		value2._pickupCount = (value2._pickupCount or 0) + 1

		if value2._pickupCount < number3 then
			local items16 = callback40(point, value4, number2)
			local pickedKeys = value2._pickedKeys or {}

			pickedKeys[tostring(param) .. "," .. tostring(tag)] = true
			value2._pickedKeys = pickedKeys

			local point2

			for index2 = 1, #items16 do
				if not pickedKeys[tostring(items16[index2].x) .. "," .. tostring(items16[index2].y)] then
					point2 = items16[index2]

					break
				end
			end

			if point2 then
				local mapPos5, mapPos22 = value4:getMapPos(point2.x, point2.y)
				local value32 = mapPos5 + 24
				local value42 = mapPos22 + 16

				param = point2.x
				tag = point2.y
				value2.lockedItemKey = tostring(param) .. "," .. tostring(tag)

				updateVisible(self, value3, self2, value22, value32, value42, value4, value5, number2, callback42, "pickup")

				return
			end
		end

		value2._pickupCount = nil
		value2._pickedKeys = nil

		callback37(self, value3, self2, value22, value4, value5, number2)
	end

	updateVisible(self, value3, value6, value7, value8, value9, value4, value5, number2, callback42, "pickup")
end

local function callback42(followDirX, value2)
	local followDirSmoothOwner = followDirX.cfg
	local value3 = followDirX.role.dir or 4
	local point = items9[value3] or items9[4]
	local value4 = 1 - math.exp(-followDirSmoothOwner.followDirSmooth * value2)

	followDirX.followDirX = followDirX.followDirX + (point.x - followDirX.followDirX) * value4
	followDirX.followDirY = followDirX.followDirY + (point.y - followDirX.followDirY) * value4

	local value5 = math.sqrt(followDirX.followDirX * followDirX.followDirX + followDirX.followDirY * followDirX.followDirY)

	if value5 > 0.001 then
		followDirX.followDirX = followDirX.followDirX / value5
		followDirX.followDirY = followDirX.followDirY / value5
	end
end

local function callback43(self, value3, value5)
	local value2 = self.cfg
	local value4 = value3.lastScreenX or 0
	local value6 = (value3.lastScreenY or 0) / (value2.orbYScale or 0.5)

	value3.wanderAngle = math.atan2(value6, value4)
	value3.wanderProgress = 0
	value3.wanderPhase = math.random() * math.pi * 2
	value3.wanderRadius = value2.wanderRadiusMin + math.random() * (value2.wanderRadiusMax - value2.wanderRadiusMin)
	value3.state = items.WANDER
end

local callback2

local function callback44(self, springX, value4, springX2)
	local value2 = self.cfg
	local value3 = #self.orbs
	local value5 = value2.followBehindDist
	local value6 = value2.followFormationPattern or "fan"
	local value7
	local value8

	if value6 == "v" then
		local value9 = math.floor((value4 - 1) / 2)
		local value10 = (value4 - 1) % 2 == 0 and 1 or -1

		if value4 == 1 then
			value9 = 0
			value10 = 0
		end

		local value11 = -self.followDirY * value10
		local value12 = self.followDirX * value10
		local value13 = 1 + value9 * 0.5

		value7 = self.followDirX * value5 * value13 + value11 * (value9 + (value4 == 1 and 0 or 1)) * 18
		value8 = self.followDirY * value5 * value13 + value12 * (value9 + (value4 == 1 and 0 or 1)) * 18 * (value2.orbYScale or 0.5)
	elseif value6 == "triangle" then
		local count = 0
		local count4 = 0
		local count5 = 0
		local count6 = 0

		while value4 > count5 + count6 + 1 do
			count5 = count5 + count6 + 1
			count6 = count6 + 1
		end

		local value14 = count6
		local value15 = value4 - count5 - 1 - (value14 + 1 - 1) * 0.5
		local value16 = -self.followDirY
		local value17 = self.followDirX

		value7 = self.followDirX * value5 * (1 + value14 * 0.45) + value16 * value15 * 20
		value8 = self.followDirY * value5 * (1 + value14 * 0.45) + value17 * value15 * 20 * (value2.orbYScale or 0.5)
	elseif value6 == "ring" then
		local value18 = math.pi * 2 / value3 * (value4 - 1) + self.elapsed * 0.4
		local value19 = value5 * 0.65

		value7 = math.cos(value18) * value19
		value8 = math.sin(value18) * value19 * (value2.orbYScale or 0.5)
		value7 = value7 + self.followDirX * value5 * 0.55
		value8 = value8 + self.followDirY * value5 * 0.55
	else
		local value20 = math.rad(value2.followFormationSpread)
		local value21 = (value3 > 1 and (value4 - 1) / (value3 - 1) - 0.5 or 0) * value20
		local value22 = math.cos(value21)
		local value23 = math.sin(value21)
		local value24 = self.followDirX * value22 - self.followDirY * value23
		local value25 = self.followDirX * value23 + self.followDirY * value22

		value7 = value24 * value5
		value8 = value25 * value5
	end

	local value26 = springX.lazyFactor or 1
	local value27 = value2.followSpringK * value26
	local value28 = value2.followDamping * math.sqrt(value26)
	local value29 = -value27 * (springX.springX - value7) - value28 * springX.springVX
	local value30 = -value27 * (springX.springY - value8) - value28 * springX.springVY

	springX.springVX = springX.springVX + value29 * springX2
	springX.springVY = springX.springVY + value30 * springX2
	springX.springX = springX.springX + springX.springVX * springX2
	springX.springY = springX.springY + springX.springVY * springX2

	local value31 = math.sin(self.elapsed * 3 + value4 * 2) * 3
	local lastScreenY = springX.springX
	local value32 = springX.springY + value31

	springX.lastScreenX, springX.lastScreenY = lastScreenY, value32

	local value33 = springX.springY / (value2.followBehindDist + 1)
	local value34 = math.max(0.15, 1 - math.max(0, value33) * 0.7)

	callback2(self, springX, lastScreenY, value32, value34, self.elapsed + value4 * 0.5, value4)
end

local function callback45(self, springX, value4, wanderAngle)
	local value2 = self.cfg

	springX.wanderAngle = springX.wanderAngle + value2.wanderSpeed * wanderAngle
	springX.wanderProgress = springX.wanderProgress + value2.wanderSpeed * wanderAngle

	local value3 = math.sin(springX.wanderAngle * value2.wanderWobbleFreq + springX.wanderPhase) * value2.wanderWobbleAmp
	local value5 = springX.wanderRadius * (1 + value3)
	local lastScreenY = math.cos(springX.wanderAngle) * value5 + math.sin(springX.wanderAngle * 1.3 + springX.wanderPhase * 2) * 5
	local value6 = math.sin(springX.wanderAngle) * value5 * (value2.orbYScale or 0.5) + math.cos(springX.wanderAngle * 0.7 + springX.wanderPhase) * 3 + math.sin(self.elapsed * 3 + value4 * 2) * 3

	springX.lastScreenX, springX.lastScreenY = lastScreenY, value6

	local value7 = math.sin(springX.wanderAngle)
	local value8 = value7 > 0 and math.max(0.1, 1 - value7 * 0.7) or 1

	callback2(self, springX, lastScreenY, value6, value8, self.elapsed + value4 * 0.5, value4)

	if springX.wanderProgress >= math.pi * 2 then
		springX.wanderProgress = 0
		springX.springX = springX.lastScreenX
		springX.springY = springX.lastScreenY
		springX.springVX = 0
		springX.springVY = 0
		springX.state = items.PAUSE
	end
end

local function callback46(self, value2, value4, value6)
	local orbYScaleOwner = self.cfg
	local value3 = math.sin(self.elapsed * 0.8 + value4 * 1.1) * 2.5
	local value5 = math.cos(self.elapsed * 0.6 + value4 * 2.3) * 1.5 * (orbYScaleOwner.orbYScale or 0.5)
	local lastScreenY = value2.springX + value3
	local value7 = value2.springY + value5

	value2.lastScreenX, value2.lastScreenY = lastScreenY, value7

	if not value2._perCfg then
		local value8 = orbYScaleOwner
	end

	callback2(self, value2, lastScreenY, value7, 0.55, self.elapsed + value4 * 0.5, value4)

	local value9 = self.colors.glow
	local value10 = self.container
	local value11 = (self.elapsed * 0.45 + value4 * 0.7) % 1

	for index2 = 1, 3 do
		local value12 = (value11 + (index2 - 1) / 3) % 1
		local x = lastScreenY + 6 + value12 * 5 + (index2 - 1) * 3
		local y = value7 + 14 + value12 * 18
		local value13 = (1 - value12) * 0.65
		local value14 = 2.8 - (index2 - 1) * 0.5

		value10:drawSegment(cc.p(x - value14, y + value14), cc.p(x + value14, y + value14), 0.65, cc.c4f(value9[1], value9[2], value9[3], value13))
		value10:drawSegment(cc.p(x + value14, y + value14), cc.p(x - value14, y - value14), 0.65, cc.c4f(value9[1], value9[2], value9[3], value13))
		value10:drawSegment(cc.p(x - value14, y - value14), cc.p(x + value14, y - value14), 0.65, cc.c4f(value9[1], value9[2], value9[3], value13))
	end
end

local function callback47(self, value3, value5, value7)
	local value2 = self.cfg
	local value4 = math.sin(self.elapsed * value2.pauseHoverFreq + value5 * 1.1) * value2.pauseHoverAmp
	local value6 = math.cos(self.elapsed * value2.pauseHoverFreq * 0.7 + value5 * 2.3) * value2.pauseHoverAmp * (value2.orbYScale or 0.5)
	local lastScreenY = value3.springX + value4
	local y = value3.springY + value6

	value3.lastScreenX, value3.lastScreenY = lastScreenY, y

	local fairyStyleOwner = value3._perCfg or value2

	callback2(self, value3, lastScreenY, y, 1, self.elapsed + value5 * 0.5, value5)

	local value8 = fairyStyleOwner.fairyStyle or 0

	if value8 == 6 or value8 == 9 then
		local value9 = math.sin(self.elapsed * 2.2 + value5) * 0.5 + 0.5
		local value10 = self.colors.glow

		self.container:drawDot(cc.p(lastScreenY, y), 28 + value9 * 12, cc.c4f(value10[1], value10[2], value10[3], 0.06 + value9 * 0.08))
	end
end

local items7 = {}

local function callback48(self, value2)
	if not self or type(self) ~= "table" or not self.format then
		return nil
	end

	if not res or not res.gettex2 then
		if not items7._no_res then
			items7._no_res = true

			print(text .. "global 'res' or res.gettex2 unavailable, frameAnim disabled")
		end

		return nil
	end

	local text2 = string.format(self.format, value2)
	local value3, value4 = pcall(res.gettex2, text2)

	if not value3 or not value4 then
		local text3 = tostring(text2)

		if not items7[text3] then
			items7[text3] = true

			print(string.format("%sframeAnim texture load failed: %s, fallback to DrawNode", text, text2))
		end

		return nil
	end

	return value4
end

local function callback49(node, x, value3)
	if not node or tolua.isnull(node) then
		return nil
	end

	if not value3 then
		return nil
	end

	local value2, node2 = pcall(function()
		local size = value3:getContentSize()
		local rect = cc.SpriteFrame:createWithTexture(value3, cc.rect(0, 0, size.width, size.height))

		return cc.Sprite:createWithSpriteFrame(rect)
	end)

	if not value2 or not node2 then
		return nil
	end

	if not pcall(function()
		node2:setAnchorPoint(cc.p(x.anchorX or 0.5, x.anchorY or 0.5))
	end) then
		return nil
	end

	local number2 = tonumber(x.scale) or 1

	pcall(function()
		node2:setScale(number2)
	end)

	if not pcall(function()
		node:addChild(node2)
	end) then
		return nil
	end

	return node2, number2
end

local function callback50(node, x)
	if not node or tolua.isnull(node) then
		return nil
	end

	if not res or not res.gettex2 then
		return nil
	end

	local number2 = tonumber(x.frameBegin) or 1
	local number3 = tonumber(x.frameEnd) or number2
	local number4 = tonumber(x.frameDelay) or 0.1
	local items16 = {}

	for index2 = number2, number3 do
		local text2 = string.format(x.format, index2)
		local value2, value3 = pcall(res.gettex2, text2)

		if value2 and value3 then
			local size = value3:getContentSize()
			local rect = cc.SpriteFrame:createWithTexture(value3, cc.rect(0, 0, size.width, size.height))

			if rect then
				items16[#items16 + 1] = rect
			end
		end
	end

	if #items16 == 0 then
		return nil
	end

	local node2 = cc.Sprite:createWithSpriteFrame(items16[1])

	if not node2 then
		return nil
	end

	pcall(function()
		node2:setAnchorPoint(cc.p(x.anchorX or 0.5, x.anchorY or 0.5))
	end)

	local number5 = tonumber(x.scale) or 1

	pcall(function()
		node2:setScale(number5)
	end)
	pcall(function()
		node:addChild(node2)
	end)

	local items17

	if #items16 > 1 then
		items17 = {
			format = x.format,
			frameBegin = number2,
			frameEnd = number3,
			delay = number4
		}

		local withSpriteFrames = cc.Animation:createWithSpriteFrames(items16, number4)

		if withSpriteFrames then
			node2:runForever(cc.Animate:create(withSpriteFrames))
		end
	end

	return node2, number5, items17
end

local items8 = {}

local function callback51(node, number2, value3)
	if not node or tolua.isnull(node) then
		return nil
	end

	if not m2spr or not m2spr.playAnimation then
		if not items8._no_m2spr then
			items8._no_m2spr = true

			print(text .. "global 'm2spr' unavailable, dataAnim disabled")
		end

		return nil
	end

	local value2 = number2.datafile

	if not value2 or value2 == "" then
		return nil
	end

	local number3 = tonumber(number2.start) or 0
	local number4 = tonumber(number2.frame) or 4
	local number5 = tonumber(number2.skip) or 6
	local number6 = tonumber(number2.interval) or 0.12
	local value4 = number2.blend or false
	local number7 = tonumber(number2.scale) or 1

	value3 = value3 or 0

	local value5 = number3 + (number4 + number5) * value3
	local value6
	local value7
	local value8 = not number2.setOffset

	pcall(function()
		value6, value7 = m2spr.playAnimation(value2, value5, number4, number6, value4, false, false, nil, value8, nil, 1)
	end)

	if not value6 then
		if not items8[value2] then
			items8[value2] = true

			print(string.format("%sdataAnim load failed: %s start=%d, fallback", text, value2, value5))
		end

		return nil
	end

	pcall(function()
		value6:setScale(number7)
	end)
	pcall(function()
		node:addChild(value6)
	end)

	return value6, number7, value7
end

function callback3(self, number3, value2)
	if not self or not number3 then
		return
	end

	local number2 = tonumber(number3.start) or 0
	local number4 = tonumber(number3.frame) or 4
	local number5 = tonumber(number3.skip) or 6
	local number6 = tonumber(number3.interval) or 0.12
	local value3 = number3.blend or false
	local value4 = number2 + (number4 + number5) * value2

	pcall(function()
		self:playAni(number3.datafile, value4, number4, number6, value3, false, false)
	end)
end

local items6 = {}

local function callback52(node, value2)
	if not node or tolua.isnull(node) then
		return nil
	end

	local text2 = value2 and value2.tailParticle

	if not text2 or text2 == "" then
		return nil
	end

	if not cc.ParticleSystemQuad or not cc.ParticleSystemQuad.create then
		if not items6._psq then
			items6._psq = true

			print(text .. "cc.ParticleSystemQuad unavailable, tailParticle disabled")
		end

		return nil
	end

	local enabled2 = false

	pcall(function()
		enabled2 = cc.FileUtils:getInstance():isFileExist(text2)
	end)

	if not enabled2 then
		if not items6[text2] then
			items6[text2] = true

			print(string.format("%stailParticle plist not found: %s", text, tostring(text2)))
		end

		return nil
	end

	local value3, node2 = pcall(cc.ParticleSystemQuad.create, cc.ParticleSystemQuad, text2)

	if not value3 or not node2 then
		if not items6[text2] then
			items6[text2] = true

			print(string.format("%stailParticle plist load failed: %s", text, tostring(text2)))
		end

		return nil
	end

	pcall(function()
		node2:setPosition(cc.p(0, 0))
	end)

	local value4 = callback31(value2.tint)

	if value4 and cc.c4f then
		pcall(function()
			local value22 = cc.c4f(value4[1] or 1, value4[2] or 1, value4[3] or 1, 1)

			node2:setStartColor(value22)
			node2:setEndColor(value22)
		end)
	end

	if not pcall(function()
		node:addChild(node2, 0)
	end) then
		return nil
	end

	return node2
end

local function callback53(self, number2)
	if not self._tail or tolua.isnull(self._tail) then
		return
	end

	local tailMode = self.flying and "attack" or "idle"

	if self._tailMode == tailMode then
		return
	end

	if tailMode == "attack" then
		local number3 = tonumber(number2.tailAttackTotal) or 160
		local number4 = tonumber(number2.tailAttackLife) or 0.8

		pcall(function()
			self._tail:setTotalParticles(number3)
		end)
		pcall(function()
			self._tail:setLife(number4)
		end)
	else
		local number5 = tonumber(number2.tailIdleTotal) or 40
		local number6 = tonumber(number2.tailIdleLife) or 0.4

		pcall(function()
			self._tail:setTotalParticles(number5)
		end)
		pcall(function()
			self._tail:setLife(number6)
		end)
	end

	self._tailMode = tailMode
end

function callback(self)
	if self._followGhosts then
		for _, followGhost in ipairs(self._followGhosts) do
			if followGhost and not tolua.isnull(followGhost) then
				followGhost:runAction(cc.Sequence:create(cc.FadeOut:create(0.15), cc.RemoveSelf:create()))
			end
		end

		self._followGhosts = nil
	end

	self._followTrail = nil
	self._fgTick = nil
	self._fgGhostMode = nil
end

function callback2(self, fgTick, x, y, value2, value3, value4)
	local number2 = self.cfg
	local number3 = fgTick._perCfg or number2
	local number4 = tonumber(number3.offsetX) or 0
	local number5 = tonumber(number3.offsetY) or 0

	x = x + number4
	y = y + number5

	local node = self.container

	if number2.zSwapByAngle and self.containerBack and not tolua.isnull(self.containerBack) and y > 0 then
		node = self.containerBack
	end

	local number6 = tonumber(number3.orbitRadius) or tonumber(number2.orbitRadius) or 60
	local value5 = math.max(-1, math.min(1, -y / math.max(1, number6)))
	local number7 = tonumber(number3.depthScaleMin) or 0.88
	local number8 = 1 + value5 * ((tonumber(number3.depthScaleMax) or 1.12) - 1)

	if value5 < 0 then
		number8 = 1 + value5 * (1 - number7)
	end

	if fgTick._sprite and not tolua.isnull(fgTick._sprite) then
		local node2 = fgTick._sprite

		if node2:getParent() ~= node and not tolua.isnull(node) then
			node2:retain()
			node2:removeFromParent(false)
			node:addChild(node2)
			node2:release()
		end

		node2:setPosition(cc.p(x + 3, y))
		node2:setOpacity(math.max(0, math.min(255, math.floor((value2 or 1) * 255))))
		node2:setScale((fgTick._spriteScale or 1) * number8)

		local curRotation = fgTick._curRotation
		local value6 = number3.dataAnim

		if value6 and fgTick._m2sprAni then
			local lastDir = self.role and self.role.dir or 0

			if lastDir ~= fgTick._lastDir then
				fgTick._lastDir = lastDir

				callback3(fgTick._m2sprAni, value6, lastDir)
			end
		elseif number3.frameAnim and number3.swordFollowDir ~= false then
			local value7 = self.role and self.role.dir or 4
			local value8 = items13[value7] or 0

			curRotation = curRotation or value8

			local value9 = value8 - curRotation

			if value9 > 180 then
				value9 = value9 - 360
			elseif value9 < -180 then
				value9 = value9 + 360
			end

			local number9 = tonumber(number2.swordRotSmooth) or 6

			curRotation = curRotation + value9 * math.min(1, number9 * 0.016)

			if curRotation > 180 then
				curRotation = curRotation - 360
			elseif curRotation < -180 then
				curRotation = curRotation + 360
			end

			fgTick._curRotation = curRotation

			node2:setRotation(curRotation)
		end

		local value10 = self.role
		local value11 = value10 and value10.map
		local value12 = self.followMode
		local value13 = fgTick.state == items.WANDER

		if number3.followMode and (value12 or value13) and (number3.frameAnim or number3.dataAnim) and value11 and value11.layers and value11.layers.obj and value10 and not tolua.isnull(value10.node) and value11.getMapPos then
			local number10 = value12 and (tonumber(number2.followGhostCount) or 4) or tonumber(number2.wanderGhostCount) or 2
			local value14 = value12 and 120 or 60
			local value15 = value12 and 5 or 8

			if fgTick._fgGhostMode ~= (value12 and 1 or 2) then
				callback(fgTick)

				fgTick._fgGhostMode = value12 and 1 or 2
			end

			local value16 = value11.layers.obj
			local size = node2:getContentSize()
			local point = node2:convertToWorldSpace(cc.p(size.width * 0.5, size.height * 0.5))
			local point2 = value16:convertToNodeSpace(point)
			local x2 = point2.x
			local y2 = point2.y
			local s = (fgTick._spriteScale or 1) * number8

			fgTick._fgTick = (fgTick._fgTick or 0) + 1

			if not fgTick._followTrail then
				fgTick._followTrail = {}
			end

			local items16 = fgTick._followTrail

			if fgTick._fgTick % value15 == 0 then
				table.insert(items16, 1, {
					x = x2,
					y = y2,
					s = s
				})

				if number10 < #items16 then
					table.remove(items16)
				end
			end

			if not fgTick._followGhosts then
				fgTick._followGhosts = {}

				local spriteFrame

				pcall(function()
					spriteFrame = node2:getSpriteFrame()
				end)

				for index2 = 1, number10 do
					local node3

					pcall(function()
						if spriteFrame then
							node3 = cc.Sprite:createWithSpriteFrame(spriteFrame)
						else
							node3 = cc.Sprite:create()
						end
					end)

					if node3 then
						node3:setAnchorPoint(cc.p(0.5, 0.5))
						node3:setScale(fgTick._spriteScale or 1)
						node3:setOpacity(0)
						node3:setVisible(false)
						value11.layers.obj:addChild(node3, 9997)

						fgTick._followGhosts[index2] = node3
					end
				end
			end

			if fgTick._followGhosts and fgTick._followTrail then
				local spriteFrame2

				pcall(function()
					spriteFrame2 = node2:getSpriteFrame()
				end)

				for index3 = 1, #fgTick._followGhosts do
					local node4 = fgTick._followGhosts[index3]

					if node4 and not tolua.isnull(node4) then
						local x3 = fgTick._followTrail[index3]

						if x3 then
							node4:setVisible(true)
							node4:setPosition(cc.p(x3.x, x3.y))
							node4:setOpacity(math.floor(value14 * (1 - index3 / (number10 + 1))))
							node4:setScale(x3.s or s)

							if spriteFrame2 then
								pcall(function()
									node4:setSpriteFrame(spriteFrame2)
								end)
							end

							if curRotation then
								node4:setRotation(curRotation)
							end
						else
							node4:setVisible(false)
						end
					end
				end
			end
		else
			callback(fgTick)
		end

		return
	end

	callback34(node, x, y, self.colors, number3, value2, value3)
end

function magicParticle.startOrbiting(self, value3, orbitStyleIdx)
	if not callback4() then
		return false
	end

	if not self or not self.node or tolua.isnull(self.node) then
		return false
	end

	if not cc.DrawNode or not cc.c4f then
		return false
	end

	local value2 = self.roleid

	if self.loops and self.loops.orbitingLightning then
		local value4 = self.loops.orbitingLightning

		if value4 ~= (items3[value2] and items3[value2].container) then
			if not tolua.isnull(value4) then
				value4:stopAllActions()
				value4:removeSelf()
			end

			self.loops.orbitingLightning = nil
		end
	end

	if self.loops and self.loops.orbitingLightning_back then
		local value5 = self.loops.orbitingLightning_back

		if value5 ~= (items3[value2] and items3[value2].containerBack) then
			if not tolua.isnull(value5) then
				value5:stopAllActions()
				value5:removeSelf()
			end

			self.loops.orbitingLightning_back = nil
		end
	end

	if items3[value2] then
		local value6 = items3[value2]
		local value7 = value6.container and not tolua.isnull(value6.container) and value6.role == self
		local value8 = value6.cfg or {}
		local value9 = value3 or {}

		local function callback410(self2)
			if not self2.orbStyles or #self2.orbStyles == 0 then
				return ""
			end

			local items16 = {}

			for _, orbStyle in ipairs(self2.orbStyles) do
				items16[#items16 + 1] = tostring(orbStyle.fairyStyle or 0) .. ":" .. tostring(orbStyle.tint or "")
			end

			return table.concat(items16, ",")
		end

		if value7 and value8.fairyStyle == value9.fairyStyle and value8.colorName == value9.colorName and value8.count == value9.count and value8.tint == value9.tint and value8.tintStrength == value9.tintStrength and (value8.followMode and true or false) == (value9.followMode and true or false) and callback410(value8) == callback410(value9) and (value8.followFormationPattern or "") == (value9.followFormationPattern or "") then
			return true
		end

		magicParticle.stopOrbiting(self)

		self.orbitingOrbs = nil
	end

	local cfg = setmetatable({}, {
		__index = function(value22, value32)
			if value3 and value3[value32] ~= nil then
				return value3[value32]
			end

			return countOwner[value32]
		end
	})
	local value10 = def and def.fairyMaxCount and def.fairyMaxCount > 0 and def.fairyMaxCount or 5
	local value11 = value3 and value3.count or countOwner.count or 3

	cfg.count = math.max(0, math.min(value11, value10))
	cfg.__tintC4f = callback32({
		tint = value3 and value3.tint,
		tintStrength = value3 and value3.tintStrength
	})

	local colors = callback12(cfg.colorName)
	local value12 = cfg.count
	local orbitingLightning = cc.DrawNode:create()

	if orbitingLightning.setBlendFunc and gl then
		pcall(function()
			orbitingLightning:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
		end)
	end

	orbitingLightning:setPosition(cc.p(16, 60))

	local value13 = value3 and value3.frontZ or 9999

	self.node:addChild(orbitingLightning, value13)

	local orbitingLightning_back

	if value3 and value3.zSwapByAngle then
		local value14, value15 = pcall(cc.DrawNode.create, cc.DrawNode)

		if value14 and value15 then
			orbitingLightning_back = value15

			if orbitingLightning_back.setBlendFunc and gl then
				pcall(function()
					orbitingLightning_back:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
				end)
			end

			pcall(function()
				orbitingLightning_back:setPosition(cc.p(16, 60))
			end)

			local value16 = value3 and value3.backZ or -1

			if not pcall(function()
				self.node:addChild(orbitingLightning_back, value16)
			end) and not pcall(function()
				self.node:addChild(orbitingLightning_back, 0)
			end) then
				orbitingLightning_back = nil
			end
		end
	end

	local orbs = {}
	local items16 = value3 and value3.orbStyles

	if items16 and #items16 == 0 then
		items16 = nil
	end

	local value17 = value3 and value3.frameAnim and value3.frameAnim.format

	for index2 = 1, value12 do
		local perCfg = cfg
		local value18 = items16 and (items16[(index2 - 1) % #items16 + 1] or {}) or nil

		if value18 then
			perCfg = setmetatable({
				fairyStyle = value18.fairyStyle,
				dataAnim = value18.dataAnim or cfg.dataAnim,
				frameAnim = value18.frameAnim or cfg.frameAnim,
				orbitSpeed = value18.orbitSpeed,
				orbitRadius = value18.orbitRadius,
				flySpeed = value18.flySpeed,
				flyCurve = value18.flyCurve,
				flyCurvature = value18.flyCurvature,
				penetrateDist = value18.penetrateDist,
				bezierForwardDist = value18.bezierForwardDist,
				bezierBackDist = value18.bezierBackDist,
				swordFollowDir = value18.swordFollowDir ~= nil and value18.swordFollowDir or false,
				offsetX = value18.offsetX,
				offsetY = value18.offsetY,
				depthScaleMin = value18.depthScaleMin,
				depthScaleMax = value18.depthScaleMax,
				enableAttackMon = value18.enableAttackMon,
				enableAttackPlayer = value18.enableAttackPlayer,
				enableItemPickup = value18.enableItemPickup,
				followMode = value18.followMode ~= nil and value18.followMode or false,
				__tintC4f = callback32({
					tint = value18.tint ~= nil and value18.tint or value3.tint,
					tintStrength = value18.tintStrength ~= nil and value18.tintStrength or value3.tintStrength
				})
			}, {
				__index = cfg
			})
		end

		local datafileOwner = value18 and value18.dataAnim or value3 and value3.dataAnim or nil
		local number2 = value18 and value18.frameAnim or value17 and value3.frameAnim or nil
		local sprite
		local spriteScale = 1
		local animData
		local m2sprAni

		if datafileOwner and datafileOwner.datafile then
			local value19 = self.dir or 0

			sprite, spriteScale, m2sprAni = callback51(orbitingLightning, datafileOwner, value19)
		end

		if not sprite and number2 and number2.format then
			local number3 = tonumber(number2.frameBegin) or 1
			local number4 = tonumber(number2.frameEnd) or number3

			if number3 < number4 then
				sprite, spriteScale, animData = callback50(orbitingLightning, number2)
			else
				local value20

				if value18 and value18.frameAnimIdx then
					value20 = value18.frameAnimIdx
				else
					local value21 = number4 - number3 + 1

					value20 = number3 + (index2 - 1) % value21
				end

				local value22 = callback48(number2, value20)

				if value22 then
					sprite, spriteScale = callback49(orbitingLightning, number2, value22)
				end
			end
		end

		local tail

		if sprite and value3 and value3.tailParticle then
			tail = callback52(sprite, value3)
		end

		orbs[index2] = {
			flying = false,
			springVY = 0,
			respawnTimer = 0,
			springX = 0,
			lastScreenX = 0,
			springVX = 0,
			visible = true,
			wanderProgress = 0,
			lastScreenY = 0,
			angle = (index2 - 1) / value12 * math.pi * 2,
			_sprite = sprite,
			_spriteScale = spriteScale,
			_animData = animData,
			_m2sprAni = m2sprAni,
			_lastDir = self.dir or 0,
			_tail = tail,
			_slotIdx = value18 and (index2 - 1) % #items16 + 1 or nil,
			state = (perCfg.followMode ~= nil and perCfg.followMode or cfg.followMode) and items.FOLLOW or items.ORBIT,
			springY = -(cfg.followBehindDist or 55),
			wanderAngle = (index2 - 1) / value12 * math.pi * 2,
			wanderPhase = math.random() * math.pi * 2,
			wanderRadius = cfg.wanderRadiusMin or 50,
			lazyFactor = 0.35 + math.random() * 0.65,
			_perCfg = perCfg
		}
	end

	local items17 = {
		detectTimer = 0,
		elapsed = 0,
		hasFollowOrbs = false,
		afkTimer = 0,
		pauseTimer = 0,
		followDirX = 0,
		idleTimer = 0,
		followDirY = 0.5,
		followMode = false,
		container = orbitingLightning,
		containerBack = orbitingLightning_back,
		orbs = orbs,
		role = self,
		cfg = cfg,
		colors = colors,
		orbitStyleIdx = orbitStyleIdx,
		pauseDuration = cfg.wanderPauseMin or 3
	}

	for _, item in ipairs(orbs) do
		if item.state == items.FOLLOW then
			items17.hasFollowOrbs = true

			break
		end
	end

	items3[value2] = items17

	if self.loops then
		self.loops.orbitingLightning = orbitingLightning

		if orbitingLightning_back then
			self.loops.orbitingLightning_back = orbitingLightning_back
		end
	end

	orbitingLightning:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.016), cc.CallFunc:create(function()
		if tolua.isnull(orbitingLightning) then
			items3[value2] = nil

			return
		end

		if not self or tolua.isnull(self.node) then
			items3[value2] = nil

			return
		end

		if self.die and not items17._dying then
			items17._dying = true

			local value22 = self.map

			if value22 and value22.removeLight then
				if items17._orbitLightKey then
					value22:removeLight("magic", items17._orbitLightKey)

					items17._orbitLightKey = nil
				end

				for _, item in ipairs(orbs) do
					if item._flyLightKey then
						value22:removeLight("magic", item._flyLightKey)

						item._flyLightKey = nil
					end
				end
			end

			items17.detectTimer = -9999

			for index2, item2 in ipairs(orbs) do
				if item2._sprite and not tolua.isnull(item2._sprite) then
					local node = item2._sprite

					if item2._flyNode and not tolua.isnull(item2._flyNode) and item2._flyUsesSprite then
						-- block empty
					elseif node:getParent() == orbitingLightning or items17.containerBack and node:getParent() == items17.containerBack then
						local point = node:getParent():convertToWorldSpace(cc.p(node:getPosition()))
						local node2 = self.map and self.map.layers and self.map.layers.obj

						if node2 and not tolua.isnull(node2) then
							local value32 = node2:convertToNodeSpace(point)

							node:retain()
							node:removeFromParent(false)
							node2:addChild(node, 9999)
							node:release()
							node:setPosition(value32)
						end
					end

					node:setVisible(true)

					local value4 = 30 + math.random(10, 30)
					local duration = index2 * 0.05

					node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0, -value4)), cc.FadeOut:create(0.5)), cc.CallFunc:create(function()
						if not tolua.isnull(node) then
							node:stopAllActions()
							node:removeSelf()
						end
					end)))

					if item2._ghostSprites then
						for _2, ghostSprite in ipairs(item2._ghostSprites) do
							if ghostSprite and not tolua.isnull(ghostSprite) then
								ghostSprite:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.RemoveSelf:create()))
							end
						end

						item2._ghostSprites = nil
					end

					callback(item2)
				end

				item2._sprite = nil
				item2.visible = false
				item2.flying = false
			end

			orbitingLightning:runAction(cc.FadeOut:create(0.5))

			if items17.containerBack and not tolua.isnull(items17.containerBack) then
				items17.containerBack:runAction(cc.FadeOut:create(0.5))
			end

			orbitingLightning:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
				magicParticle.stopOrbiting(self)
			end)))

			return
		end

		if items17._dying then
			return
		end

		local number2 = 0.016

		items17.elapsed = items17.elapsed + number2
		items17.detectTimer = items17.detectTimer + number2

		orbitingLightning:clear()

		if items17.containerBack and not tolua.isnull(items17.containerBack) then
			items17.containerBack:clear()
		end

		if items17.hasFollowOrbs then
			if self.isMoving then
				items17.idleTimer = 0
				items17.pauseTimer = 0
				items17.afkTimer = 0

				if not items17.followMode then
					items17.followMode = true

					for _3, item3 in ipairs(orbs) do
						if item3.state == items.PAUSE or item3.state == items.WANDER or item3.state == items.SLEEP then
							item3.springX = item3.lastScreenX or 0
							item3.springY = item3.lastScreenY or 0
							item3.springVX = 0
							item3.springVY = 0
							item3.state = items.FOLLOW
						end
					end
				end

				callback42(items17, number2)
			elseif items17.followMode then
				items17.idleTimer = items17.idleTimer + number2

				if items17.idleTimer >= cfg.followToIdleDelay then
					items17.followMode = false

					for _4, item4 in ipairs(orbs) do
						if item4.state == items.FOLLOW then
							item4.state = items.PAUSE
						end
					end

					items17.pauseTimer = 0
					items17.pauseDuration = cfg.wanderPauseMin + math.random() * (cfg.wanderPauseMax - cfg.wanderPauseMin)
				else
					callback42(items17, number2)
				end
			else
				local enabled2 = true

				for _5, item5 in ipairs(orbs) do
					if not item5.flying and item5.state ~= items.PAUSE and item5.state ~= items.SLEEP and item5.state ~= items.ORBIT then
						enabled2 = false

						break
					end
				end

				if enabled2 then
					items17.afkTimer = items17.afkTimer + number2

					if (cfg.afkSleepDelay or 60) <= items17.afkTimer then
						local enabled3 = false

						for _6, item6 in ipairs(orbs) do
							if item6.state == items.PAUSE and not item6.flying then
								item6.state = items.SLEEP
								enabled3 = true
							end
						end

						if enabled3 then
							items17.pauseTimer = 0
						end
					end

					local enabled4 = false

					for _7, item7 in ipairs(orbs) do
						if item7.state == items.PAUSE then
							enabled4 = true

							break
						end
					end

					if enabled4 then
						items17.pauseTimer = items17.pauseTimer + number2

						if items17.pauseTimer >= items17.pauseDuration then
							items17.pauseTimer = 0
							items17.pauseDuration = cfg.wanderPauseMin + math.random() * (cfg.wanderPauseMax - cfg.wanderPauseMin)

							for index3, item8 in ipairs(orbs) do
								if item8.state == items.PAUSE and item8.visible and not item8.flying then
									callback43(items17, item8, index3)
								end
							end
						end
					end
				end
			end
		end

		for index4, item9 in ipairs(orbs) do
			if item9.respawnTimer > 0 then
				item9.respawnTimer = item9.respawnTimer - number2

				if item9.respawnTimer <= 0 then
					item9.visible = true
					item9.flying = false
					item9.respawnTimer = 0

					if item9.state == items.WANDER then
						callback43(items17, item9, index4)
					end
				end
			end

			if item9._sprite and not tolua.isnull(item9._sprite) and not item9._flyUsesSprite then
				item9._sprite:setVisible(item9.visible and not item9.flying)
			end

			if item9._tail then
				callback53(item9, cfg)
			end

			if item9.visible and not item9.flying then
				if item9.state == items.ORBIT then
					local value5 = item9._perCfg or cfg

					item9.angle = item9.angle + (value5.orbitSpeed or cfg.orbitSpeed) * number2

					local lastScreenX = math.cos(item9.angle) * (value5.orbitRadius or cfg.orbitRadius)
					local lastScreenY = math.sin(item9.angle) * (value5.orbitRadius or cfg.orbitRadius) * cfg.orbYScale + math.sin(items17.elapsed * 3 + index4 * 2) * 3

					item9.lastScreenX = lastScreenX
					item9.lastScreenY = lastScreenY

					local value6 = math.sin(item9.angle)
					local value7 = value6 > 0 and math.max(0.1, 1 - value6 * 0.7) or 1

					callback2(items17, item9, lastScreenX, lastScreenY, value7, items17.elapsed + index4 * 0.5, index4)
				elseif item9.state == items.FOLLOW then
					callback44(items17, item9, index4, number2)
				elseif item9.state == items.WANDER then
					callback45(items17, item9, index4, number2)
				elseif item9.state == items.PAUSE then
					callback47(items17, item9, index4, number2)
				elseif item9.state == items.SLEEP then
					callback46(items17, item9, index4, number2)
				end
			end
		end

		if items17._orbitLightKey then
			local value8 = self.map

			if value8 and value8.removeLight then
				value8:removeLight("magic", items17._orbitLightKey)
			end

			items17._orbitLightKey = nil
		end

		local value9 = cfg.tickInterval or 0.15

		if (items17._lastNearbyCount or 0) > 50 then
			value9 = value9 * 2
		end

		if value9 <= items17.detectTimer then
			items17.detectTimer = 0

			local value102 = self.map

			if value102 then
				local lastNearbyCount = 0

				if value102.mons then
					for _8 in pairs(value102.mons) do
						lastNearbyCount = lastNearbyCount + 1
					end
				end

				if value102.heros then
					for _9 in pairs(value102.heros) do
						lastNearbyCount = lastNearbyCount + 1
					end
				end

				items17._lastNearbyCount = lastNearbyCount
			end

			local itemsOwner = self.map

			if itemsOwner then
				local items162 = {}
				local items172 = {}
				local items18 = {}

				for index5, item10 in ipairs(orbs) do
					if item10.visible and not item10.flying then
						items162[#items162 + 1] = index5
					elseif item10.flying then
						if item10.lockedTarget then
							items172[item10.lockedTarget] = (items172[item10.lockedTarget] or 0) + 1
						end

						if item10.lockedItemKey then
							items18[item10.lockedItemKey] = true
						end
					end
				end

				if #items162 == 0 then
					return
				end

				local text2 = cfg.maxOrbsPerTarget or 0
				local items19 = {}

				local function callback410(self2)
					for index2 = 1, #items162 do
						local value22 = items162[index2]

						if not items19[value22] then
							local value32 = orbs[value22]._perCfg

							if not self2 or self2(value32) then
								items19[value22] = true

								return value22
							end
						end
					end

					return nil
				end

				if cfg.enableItemPickup and itemsOwner.items then
					local items20 = callback40(self, itemsOwner, cfg)

					for index6 = 1, #items20 do
						local point2 = items20[index6]
						local text3 = tostring(point2.x) .. "," .. tostring(point2.y)

						if not items18[text3] then
							local value112 = callback410(function(enableItemPickupOwner)
								return not enableItemPickupOwner or enableItemPickupOwner.enableItemPickup ~= false
							end)

							if not value112 then
								break
							end

							callback41(items17, value112, point2, itemsOwner, colors, cfg)

							items18[text3] = true
						end
					end
				end

				if cfg.standbyMode then
					return
				end

				local items21 = callback28(self, cfg.detectRange, cfg)
				local items22 = callback29(self, cfg.detectRange, cfg)
				local items23
				local items24
				local callback54
				local callback62

				if cfg.attackPriority == "player" then
					items23, items24 = items22, items21

					function callback54(self2)
						return not self2 or self2.enableAttackPlayer ~= false
					end

					function callback62(self2)
						return not self2 or self2.enableAttackMon ~= false
					end
				else
					items23, items24 = items21, items22

					function callback54(self2)
						return not self2 or self2.enableAttackMon ~= false
					end

					function callback62(self2)
						return not self2 or self2.enableAttackPlayer ~= false
					end
				end

				for index7 = 1, #items23 do
					local player = items23[index7].role
					local value122 = player.roleid

					if (items172[value122] or 0) < 1 then
						local value132 = callback410(callback54)

						if not value132 then
							break
						end

						callback39(items17, value132, player, itemsOwner, colors, cfg)

						items172[value122] = 1
					end
				end

				for index8 = 1, #items24 do
					local player2 = items24[index8].role
					local value14 = player2.roleid

					if (items172[value14] or 0) < 1 then
						local value15 = callback410(callback62)

						if not value15 then
							break
						end

						callback39(items17, value15, player2, itemsOwner, colors, cfg)

						items172[value14] = 1
					end
				end

				local enabled5 = false

				for index9 = 1, #items162 do
					if not items19[items162[index9]] then
						enabled5 = true

						break
					end
				end

				if enabled5 then
					local value16 = callback19()
					local items25 = {}
					local items26 = {}

					for index10 = 1, #items21 do
						items25[#items25 + 1] = items21[index10].role
						items26[items21[index10].role.roleid] = true
					end

					if items22 then
						for index11 = 1, #items22 do
							items25[#items25 + 1] = items22[index11].role
						end
					end

					while #items25 > 0 do
						local enabled6 = false

						for index12 = 1, #items162 do
							if not items19[items162[index12]] then
								enabled6 = true

								break
							end
						end

						if not enabled6 then
							break
						end

						local player3
						local value172 = math.huge
						local count = 0

						for index13 = 1, #items25 do
							local player4 = items25[index13]
							local value18 = items172[player4.roleid] or 0

							if value18 < value172 and (text2 == 0 or value18 < text2) then
								player3, value172, count = player4, value18, index13
							end
						end

						if not player3 then
							break
						end

						local value19 = items26[player3.roleid]
						local value20 = callback410(function(value22)
							if not value22 then
								return true
							end

							if value19 then
								return value22.enableAttackMon ~= false
							end

							return value22.enableAttackPlayer ~= false
						end)

						if not value20 then
							table.remove(items25, count)
						else
							callback39(items17, value20, player3, itemsOwner, colors, cfg)

							items172[player3.roleid] = value172 + 1
							items2.overflowAssigns = items2.overflowAssigns + 1

							callback20()

							if value16 - (count3 or 0) > 60000 then
								count3 = value16

								print(text .. "overflow assign fired: combinedTargets=" .. #items25 .. " availOrbs=" .. #items162 .. " maxPerTarget=" .. tostring(text2))
							end
						end
					end
				end
			end
		end
	end))))

	return true
end

function magicParticle.stopOrbiting(self)
	if not self then
		return
	end

	local value2 = self.roleid
	local value3 = items3[value2]

	if value3 then
		if value3.orbs then
			for _, orb in ipairs(value3.orbs) do
				if orb._ghostSprites then
					for _2, ghostSprite in ipairs(orb._ghostSprites) do
						if ghostSprite and not tolua.isnull(ghostSprite) then
							ghostSprite:stopAllActions()
							ghostSprite:removeSelf()
						end
					end

					orb._ghostSprites = nil
				end

				callback(orb)

				if orb._flyUsesSprite then
					if orb._sprite and not tolua.isnull(orb._sprite) then
						orb._sprite:stopAllActions()
						orb._sprite:removeFromParent(false)
					end

					orb._flyNode = nil
					orb._flyUsesSprite = nil
				else
					if orb._flyNode and not tolua.isnull(orb._flyNode) then
						orb._flyNode:stopAllActions()
						orb._flyNode:removeSelf()

						orb._flyNode = nil
					end

					if orb._sprite and not tolua.isnull(orb._sprite) then
						orb._sprite:stopAllActions()
					end
				end
			end
		end

		if value3.container and not tolua.isnull(value3.container) then
			value3.container:stopAllActions()
			value3.container:removeSelf()
		end

		if value3.containerBack and not tolua.isnull(value3.containerBack) then
			value3.containerBack:stopAllActions()
			value3.containerBack:removeSelf()
		end

		if value3._orbitLightKey then
			local value4 = self.map

			if value4 and value4.removeLight then
				value4:removeLight("magic", value3._orbitLightKey)
			end
		end

		items3[value2] = nil
	end

	if self.loops then
		self.loops.orbitingLightning = nil
		self.loops.orbitingLightning_back = nil
	end
end

function magicParticle.shutdownAll()
	for itemId, item in pairs(items3) do
		if item then
			if item.orbs then
				for _, orb in ipairs(item.orbs) do
					if orb._ghostSprites then
						for _2, ghostSprite in ipairs(orb._ghostSprites) do
							if ghostSprite and not tolua.isnull(ghostSprite) then
								ghostSprite:stopAllActions()
								ghostSprite:removeSelf()
							end
						end

						orb._ghostSprites = nil
					end

					if orb._flyUsesSprite then
						if orb._sprite and not tolua.isnull(orb._sprite) then
							orb._sprite:stopAllActions()
							orb._sprite:removeFromParent(false)
						end

						orb._flyNode = nil
						orb._flyUsesSprite = nil
					else
						if orb._flyNode and not tolua.isnull(orb._flyNode) then
							orb._flyNode:stopAllActions()
							orb._flyNode:removeSelf()

							orb._flyNode = nil
						end

						if orb._sprite and not tolua.isnull(orb._sprite) then
							orb._sprite:stopAllActions()
						end
					end

					if orb._frameAni then
						pcall(function()
							orb._frameAni:release()
						end)

						orb._frameAni = nil
					end
				end
			end

			if item.container and not tolua.isnull(item.container) then
				item.container:stopAllActions()
				item.container:removeSelf()
			end

			if item.containerBack and not tolua.isnull(item.containerBack) then
				item.containerBack:stopAllActions()
				item.containerBack:removeSelf()
			end

			if item.role and item.role.loops then
				item.role.loops.orbitingLightning = nil
				item.role.loops.orbitingLightning_back = nil
			end

			if item.role then
				item.role.orbitingOrbs = nil
			end
		end

		items3[itemId] = nil
	end
end

function magicParticle.hasOrbiting(self)
	if not self then
		return false
	end

	local value2 = items3[self.roleid]

	if not value2 then
		return false
	end

	if not value2.container or tolua.isnull(value2.container) or value2.role ~= self then
		if value2.container and not tolua.isnull(value2.container) then
			value2.container:stopAllActions()
			value2.container:removeSelf()
		end

		if value2.containerBack and not tolua.isnull(value2.containerBack) then
			value2.containerBack:stopAllActions()
			value2.containerBack:removeSelf()
		end

		if value2.orbs then
			for _, orb in ipairs(value2.orbs) do
				if orb._flyNode and not tolua.isnull(orb._flyNode) then
					orb._flyNode:stopAllActions()
					orb._flyNode:removeSelf()

					orb._flyNode = nil
				end
			end
		end

		items3[self.roleid] = nil

		return false
	end

	return true
end

function magicParticle.getActiveOrbitIdx(self)
	if not self then
		return nil
	end

	local value2 = items3[self.roleid]

	if not value2 or not value2.container or tolua.isnull(value2.container) or value2.role ~= self then
		return nil
	end

	return value2.orbitStyleIdx
end

function magicParticle.getActiveOrbitDigest(self)
	if not self then
		return nil
	end

	local value2 = items3[self.roleid]

	if not value2 or not value2.container or tolua.isnull(value2.container) or value2.role ~= self then
		return nil
	end

	local value3 = value2.cfg or {}
	local banSize = 0

	for _ in pairs(_fairyBanSet) do
		banSize = banSize + 1
	end

	return {
		idx = value2.orbitStyleIdx,
		count = value3.count,
		atkMon = value3.enableAttackMon,
		atkPlr = value3.enableAttackPlayer,
		pickup = value3.enableItemPickup,
		banSize = banSize
	}
end

function magicParticle.getStats()
	local activeRoleCount = 0

	for _, item in pairs(items3) do
		if item and item.container and not tolua.isnull(item.container) then
			activeRoleCount = activeRoleCount + 1
		end
	end

	callback20()

	return {
		activeRoleCount = activeRoleCount,
		hitsThisMin = items2.hits,
		picksThisMin = items2.picks,
		overflowThisMin = items2.overflowAssigns,
		hitsLastMin = items2.hitsLastMin,
		picksLastMin = items2.picksLastMin,
		overflowLastMin = items2.overflowLastMin,
		fairyBanSize = (function()
			local count = 0

			for _ in pairs(_fairyBanSet) do
				count = count + 1
			end

			return count
		end)()
	}
end

function magicParticle.resolvePreset(self)
	if not self or not self.particle then
		return nil
	end

	local text2 = self.particle.preset

	if text2 then
		print(text .. "resolvePreset -> found preset=" .. tostring(text2) .. " for effectID=" .. tostring(self.effectID or "?"))
	end

	return text2
end

function magicParticle.triggerAttack(self)
	if not self then
		return 0
	end

	local value2 = items3[self.roleid]

	if not value2 or not value2.orbs then
		return 0
	end

	local value3 = value2.cfg
	local value4 = self.map

	if not value4 then
		return 0
	end

	local value5 = value2.colors
	local value6 = value2.orbs
	local items16 = {}
	local items17 = {}

	for index2, item in ipairs(value6) do
		if item.visible and not item.flying then
			items16[#items16 + 1] = index2
		elseif item.flying and item.lockedTarget then
			items17[item.lockedTarget] = (items17[item.lockedTarget] or 0) + 1
		end
	end

	if #items16 == 0 then
		return 0
	end

	local value7 = value3.maxOrbsPerTarget or 0
	local items18 = {}
	local count = 0

	local function callback410(self2)
		for index2 = 1, #items16 do
			local value22 = items16[index2]

			if not items18[value22] then
				local value32 = value6[value22]._perCfg

				if not self2 or self2(value32) then
					items18[value22] = true

					return value22
				end
			end
		end

		return nil
	end

	local player

	pcall(function()
		local player2 = main_scene.ui.console.lock.role

		if player2 and not tolua.isnull(player2.node) and not player2.die then
			if player2.__cname == "mon" then
				if value3.enableAttackMon == true and not player2.isDummy and not player2.isHaveMaster and (not player2.isPolice or not player2:isPolice()) and (not player2.info or not player2.info.isPet or not player2.info:isPet()) then
					player = player2
				end
			elseif value3.enableAttackPlayer == true then
				local value22 = callback29(self, value3.detectRange or 5, value3)

				for _, item in ipairs(value22) do
					if item.role.roleid == player2.roleid then
						player = player2

						break
					end
				end
			end
		end
	end)

	if player then
		local value8 = player.roleid
		local value9 = value7 == 0 and #items16 or value7

		for index3 = 1, value9 do
			if value9 <= (items17[value8] or 0) then
				break
			end

			local value10 = player.__cname == "mon"
			local value11 = callback410(function(value22)
				if not value22 then
					return true
				end

				if value10 then
					return value22.enableAttackMon ~= false
				end

				return value22.enableAttackPlayer ~= false
			end)

			if not value11 then
				break
			end

			callback39(value2, value11, player, value4, value5, value3)

			items17[value8] = (items17[value8] or 0) + 1
			count = count + 1
		end
	end

	local items19 = callback28(self, value3.detectRange or 5, value3)
	local items20 = callback29(self, value3.detectRange or 5, value3)
	local items21
	local items22
	local callback54
	local callback62

	if value3.attackPriority == "player" then
		items21, items22 = items20, items19

		function callback54(self2)
			return not self2 or self2.enableAttackPlayer ~= false
		end

		function callback62(self2)
			return not self2 or self2.enableAttackMon ~= false
		end
	else
		items21, items22 = items19, items20

		function callback54(self2)
			return not self2 or self2.enableAttackMon ~= false
		end

		function callback62(self2)
			return not self2 or self2.enableAttackPlayer ~= false
		end
	end

	for index4 = 1, #items21 do
		local player2 = items21[index4].role
		local value12 = player2.roleid

		if (items17[value12] or 0) < 1 then
			local value13 = callback410(callback54)

			if not value13 then
				break
			end

			callback39(value2, value13, player2, value4, value5, value3)

			items17[value12] = 1
			count = count + 1
		end
	end

	for index5 = 1, #items22 do
		local player3 = items22[index5].role
		local value14 = player3.roleid

		if (items17[value14] or 0) < 1 then
			local value15 = callback410(callback62)

			if not value15 then
				break
			end

			callback39(value2, value15, player3, value4, value5, value3)

			items17[value14] = 1
			count = count + 1
		end
	end

	local items23 = {}
	local items24 = {}

	for index6 = 1, #items19 do
		items23[#items23 + 1] = items19[index6].role
		items24[items19[index6].role.roleid] = true
	end

	for index7 = 1, #items20 do
		items23[#items23 + 1] = items20[index7].role
	end

	while #items23 > 0 do
		local enabled2 = false

		for index8 = 1, #items16 do
			if not items18[items16[index8]] then
				enabled2 = true

				break
			end
		end

		if not enabled2 then
			break
		end

		local player4
		local value16 = math.huge
		local count4 = 0

		for index9 = 1, #items23 do
			local player5 = items23[index9]
			local value17 = items17[player5.roleid] or 0

			if value17 < value16 and (value7 == 0 or value17 < value7) then
				player4, value16, count4 = player5, value17, index9
			end
		end

		if not player4 then
			break
		end

		local value18 = items24[player4.roleid]
		local value19 = callback410(function(value22)
			if not value22 then
				return true
			end

			if value18 then
				return value22.enableAttackMon ~= false
			end

			return value22.enableAttackPlayer ~= false
		end)

		if not value19 then
			table.remove(items23, count4)
		else
			callback39(value2, value19, player4, value4, value5, value3)

			items17[player4.roleid] = value16 + 1
			count = count + 1
		end
	end

	return count
end

function magicParticle.triggerPickup(self)
	if not self then
		return 0
	end

	local value2 = items3[self.roleid]

	if not value2 or not value2.orbs then
		return 0
	end

	local value3 = value2.cfg
	local value4 = self.map

	if not value4 then
		return 0
	end

	local value5 = value2.colors
	local value6 = value2.orbs
	local items16 = {}
	local items17 = {}

	for index2, item in ipairs(value6) do
		if item.visible and not item.flying then
			items16[#items16 + 1] = index2
		elseif item.flying and item.lockedItemKey then
			items17[item.lockedItemKey] = true
		end
	end

	if #items16 == 0 then
		return 0
	end

	local items18 = callback40(self, value4, value3)
	local count = 0
	local items19 = {}

	for index3 = 1, #items18 do
		local point = items18[index3]
		local text2 = tostring(point.x) .. "," .. tostring(point.y)

		if not items17[text2] then
			local value7

			for index4 = 1, #items16 do
				if not items19[items16[index4]] then
					local enableItemPickupOwner = value6[items16[index4]]._perCfg

					if not enableItemPickupOwner or enableItemPickupOwner.enableItemPickup ~= false then
						value7 = items16[index4]
						items19[value7] = true

						break
					end
				end
			end

			if not value7 then
				break
			end

			callback41(value2, value7, point, value4, value5, value3)

			items17[text2] = true
			count = count + 1
		end
	end

	return count
end

return magicParticle
