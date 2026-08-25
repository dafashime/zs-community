local def2 = import("..map.def")
local magicParticle = import("..common.magicParticle")
local magic = {
	maxFrame = 10,
	cache = {},
	getEffect = function(value)
		return
	end
}
local callback = cc.Node.setPosition

function magic:getMagicLight(value, value2, value4)
	local items2 = {}

	if not value.setDark.control or value.opacity <= 0 then
		return items2
	end

	local value5 = self.roleid
	local value3 = def.role.dir["_" .. self.dir]

	for index = value2, value4 do
		local value6 = self.y + value3[2] * index
		local value7 = self.x + value3[1] * index
		local x2, y2 = value.getMapPos(value, value7, value6)

		items2[#items2 + 1] = {
			roleid = value5 .. x2 .. y2,
			x = x2,
			y = y2
		}

		if value2 == value4 then
			break
		end
	end

	return items2
end

function magic:showMagic(data, options4, options3, options2, options)
	local magicConfig = def.magic.getMagicConfig(options, data)

	if not magicConfig then
		return
	end

	local magicId2 = magicConfig.uid
	local text = data.job and tostring(data.job) or "-1"
	local actMusicOwner = magicConfig.actFrame and magicConfig.actFrame[text]
	local enabled = false

	if actMusicOwner and actMusicOwner.actMusic then
		enabled = true
	else
		sound.play("skillPlay", {
			magicId = magicId2
		})
	end

	if not magicConfig.beatenFrame and not magicConfig.flyFrame then
		return
	end

	local count3 = 0
	local value = magicConfig.rsc
	local number = -1
	local count = 0
	local count2 = 0

	if magicConfig.beatenFrame and magicConfig.beatenFrame[text] then
		local value2 = magicConfig.beatenFrame[text]

		if value2.rsc and value2.rsc ~= "" then
			value = value2.rsc
			count3 = count3 + 1
		end

		number = value2.begin
		count = value2.frame
		count2 = value2.delay
	elseif magicConfig.beatenFrame and magicConfig.beatenFrame.begin then
		value = magicConfig.beatenFrame.rsc or value
		number = magicConfig.beatenFrame.begin
		count = magicConfig.beatenFrame.frame
		count2 = magicConfig.beatenFrame.delay
	end

	if not number or number == -1 then
		return
	end

	local value4 = magicConfig.rsc
	local count4 = 0
	local count5 = 0
	local count6 = 0

	if magicConfig.flyFrame and magicConfig.flyFrame[text] then
		local value3 = magicConfig.flyFrame[text]

		if value3.rsc and value3.rsc ~= "" then
			value4 = value3.rsc
			count3 = count3 + 1
		end

		count4 = value3.begin
		count5 = value3.frame
		count6 = value3.delay
	elseif magicConfig.flyFrame then
		value4 = magicConfig.flyFrame.rsc or value4
		count4 = magicConfig.flyFrame.begin or 0
		count5 = magicConfig.flyFrame.frame
		count6 = magicConfig.flyFrame.delay
	end

	if options == 8 then
		local value23 = count3 < 1 and number + data.dir * magic.maxFrame * 2 or number + data.dir * magic.maxFrame
		local mapPos6, mapPos4 = self.getMapPos(self, data.x, data.y)
		local value37
		local value38
		local items3 = {}
		local node
		local node9, value39 = m2spr.playAnimation(value, value23, count, count2, not magicConfig.noBlend, true, true):addto(self.layers.obj, mapPos4 + def2.tile.h)

		if self.setDark.control and self.opacity > 0 then
			items3 = magic.getMagicLight(data, self, 2, 8)

			local value7 = count2 * count

			node = display.newNode():addto(self.layers.obj, mapPos4 + def2.tile.h)

			node:run(cc.RepeatForever:create(transition.sequence({
				cc.DelayTime:create(0.01),
				cc.CallFunc:create(function()
					if value7 > 0 then
						for _2, item2 in ipairs(items3) do
							local items5 = {
								roleid = item2.roleid,
								x = item2.x,
								y = item2.y
							}

							self:addLight2(items5, "magic", 1.3)
						end
					else
						for _3, item3 in ipairs(items3) do
							self:removeLight("magic", item3.roleid)
						end

						if not tolua.isnull(node) and tolua.cast(node, "cc.Node") then
							node:stopAllActions()
							node:removeSelf()
						end
					end

					value7 = value7 - 0.01
				end)
			})))
		end

		callback(node9, mapPos6, mapPos4 + def2.tile.h)

		local value15 = magicParticle.resolvePreset(magicConfig)

		if value15 then
			local value24 = math.floor(def2.tile.w * 0.33)

			if magicParticle.burstAt(self.layers.obj, mapPos6 + value24, mapPos4 + def2.tile.h + def2.tile.h, value15, magicConfig, mapPos4 + def2.tile.h) and node9 and not tolua.isnull(node9) then
				node9:setVisible(false)
			end
		end
	elseif options == 7 then
		local number2 = 4
		local value16 = def.role.dir["_" .. data.dir]
		local value25 = data.x + value16[1] * number2
		local value26 = data.y + value16[2] * number2

		options3, options2 = self.getMapPos(self, data.x, data.y)

		local mapPos10, mapPos11 = self.getMapPos(self, value25, value26)

		for index = 1, number2 do
			local value40
			local value8 = m2spr.playAnimation(value, number, count, count2, not magicConfig.noBlend)

			value8.addto(value8, self.layers.obj, options2 + def2.tile.h):runs({
				cca.hide(),
				cca.delay((index - 1) * 0.1),
				cca.show(),
				cca.moveTo(0.4, cc.p(mapPos10, mapPos11)),
				cca.removeSelf()
			})
			callback(value8, options3, options2 + def2.tile.h)
		end

		if self.setDark.control and self.opacity > 0 then
			local node2 = display.newNode():addto(self.layers.obj, options2 + def2.tile.h)
			local magicLight = magic.getMagicLight(data, self, 2, number2)
			local value9 = magicConfig.beatenFrame.delay * magicConfig.beatenFrame.frame or 0.5

			node2:run(cc.RepeatForever:create(transition.sequence({
				cc.DelayTime:create(0.01),
				cc.CallFunc:create(function()
					if value9 <= 0 then
						for _4, item4 in ipairs(magicLight) do
							self:removeLight("magic", item4.roleid)
						end

						if not tolua.isnull(node2) and tolua.cast(node2, "cc.Node") then
							node2:stopAllActions()
							node2:removeSelf()
						end

						return
					end

					value9 = value9 - 0.02
				end)
			})))

			if node2 then
				for _, item in ipairs(magicLight) do
					local items4 = {
						roleid = item.roleid,
						x = item.x,
						y = item.y
					}

					self:addLight2(items4, "magic", 1.3)
				end
			end
		end
	else
		if options == 11 or options == 12 then
			if not magicConfig.flyFrame then
				return
			end

			local value27 = count4 + data.dir * magic.maxFrame * 2
			local x4, mapPos7 = self.getMapPos(self, options3, options2)
			local mapPos12, mapPos8 = self.getMapPos(self, data.x, data.y)
			local duration2 = 0.15
			local value10
			local value41
			local value28

			value10, value28 = m2spr.playAnimation(value4, value27, count5, count6, not magicConfig.noBlend):addto(self.layers.obj, mapPos8 + def2.tile.h):runs({
				cc.MoveTo:create(duration2, cc.p(x4, mapPos7 + def2.tile.h)),
				cc.CallFunc:create(function()
					if not enabled then
						sound.play("skillPlay", {
							idx = 3,
							magicId = magicId2
						})
					end

					value10:removeSelf()

					local value49
					local node4
					local value6 = mapPos7 + def2.tile.h
					local y3 = value6 - def2.tile.h
					local value12 = m2spr.playAnimation(value, number, count, count2, not magicConfig.noBlend, true, true)

					if self.setDark.control and self.opacity > 0 then
						local roleid4 = data.roleid .. x4 .. y3
						local value13 = count2 * count

						node4 = display.newNode():addto(self.layers.obj, value6)

						node4:run(cc.RepeatForever:create(transition.sequence({
							cc.DelayTime:create(0.01),
							cc.CallFunc:create(function()
								if value13 > 0 then
									self:addLight2({
										roleid = roleid4,
										x = x4,
										y = y3
									}, "magic", 2)
								else
									self:removeLight("magic", roleid4)

									if not tolua.isnull(node4) and tolua.cast(node4, "cc.Node") then
										node4:stopAllActions()
										node4:removeSelf()
									end
								end

								value13 = value13 - 0.01
							end)
						})))
					end

					value12.addto(value12, self.layers.obj, value6)
					callback(value12, x4, value6)
				end)
			})

			callback(value10, mapPos12, mapPos8 + def2.tile.h)

			return
		end

		if magicConfig.customFlyFrame or options == 1 or options == 3 or options == 10 or options == 17 or options == 39 or options == 63 or options == 100 or options == 101 then
			if not magicConfig.flyFrame then
				return
			end

			local value29 = count4 + data.dir * magic.maxFrame * (magicConfig.flyFrame.dir or 2)
			local roelWithPos

			if options == 17 then
				roelWithPos = self.findRoelWithPos(self, options3, options2)
			else
				roelWithPos = self.findRole(self, options4)
			end

			local x2
			local mapPos
			local duration
			local value42
			local value43

			if roelWithPos then
				local value30 = roelWithPos.y
				local value31 = roelWithPos.x

				x2, mapPos, duration = self.getMapPos(self, value31, value30)
				duration = 0.3 * (data:getDis(roelWithPos) / 9)
			else
				local value17 = def.role.dir["_" .. data.dir]
				local value32 = data.y + value17[2] * 12
				local value33 = data.x + value17[1] * 12

				x2, mapPos = self.getMapPos(self, value33, value32)
				duration = 1
			end

			local mapPos5, mapPos2 = self.getMapPos(self, data.x, data.y)
			local node6
			local node7
			local value44
			local value34
			local value45
			local roleid2 = data.roleid .. mapPos5 .. mapPos2

			node6 = m2spr.playAnimation(value4, value29, count5, count6, not magicConfig.noBlend):addto(self.layers.obj, mapPos2 + def2.tile.h):runs({
				cc.MoveTo:create(duration, cc.p(x2, mapPos)),
				cc.CallFunc:create(function()
					if not tolua.isnull(node6) and tolua.cast(node6, "cc.Node") then
						node6:stopAllActions()
						node6:removeSelf()
					end

					self:removeLight("magic", roleid2)

					if roelWithPos and checkMagicLastPlayTime(options, mapPos5, mapPos2) then
						if not enabled then
							sound.play("skillPlay", {
								idx = 3,
								magicId = magicId2
							})
						end

						node7, value34 = m2spr.playAnimation(value, number, count, count2, not magicConfig.noBlend, true, true)

						if self.setDark.control and self.opacity > 0 then
							local y4 = mapPos + def2.tile.h
							local roleid5 = data.roleid .. x2 .. y4
							local value50
							local value14 = count2 * count
							local node5 = display.newNode():addto(self.layers.obj, mapPos + def2.tile.h)

							node5:run(cc.RepeatForever:create(transition.sequence({
								cc.DelayTime:create(0.01),
								cc.CallFunc:create(function()
									if value14 > 0 then
										self:addLight2({
											roleid = roleid5,
											x = x2,
											y = y4
										}, "magic", 1.5)
									else
										self:removeLight("magic", roleid5)

										if not tolua.isnull(node5) and tolua.cast(node5, "cc.Node") then
											node5:stopAllActions()
											node5:removeSelf()
										end
									end

									value14 = value14 - 0.01
								end)
							})))
						end

						node7.addto(node7, self.layers.obj, mapPos + def2.tile.h)
						callback(node7, x2, mapPos + def2.tile.h)

						local value22 = magicParticle.resolvePreset(magicConfig)

						if value22 then
							local value35 = math.floor(def2.tile.w * 0.33)
							local value36 = def2.tile.h

							if magicParticle.burstAt(self.layers.obj, x2 + value35, mapPos + def2.tile.h + value36, value22, magicConfig, mapPos + def2.tile.h) and node7 and not tolua.isnull(node7) then
								node7:setVisible(false)
							end
						end
					end
				end)
			})

			if self.setDark.control and self.opacity > 0 then
				node6:run(cc.RepeatForever:create(transition.sequence({
					cc.DelayTime:create(0.01),
					cc.CallFunc:create(function()
						if node6 then
							local x6, y5 = node6:getPosition()
							local items6 = {
								roleid = roleid2,
								x = x6,
								y = y5
							}

							self:addLight2(items6, "magic", 1.3)
						end
					end)
				})))
			end

			callback(node6, mapPos5, mapPos2 + def2.tile.h)

			local value18 = magicParticle.resolvePreset(magicConfig)

			if value18 then
				local value19 = math.floor(def2.tile.w * 0.33)
				local value20 = def2.tile.h

				if magicParticle.attachTrail(self.layers.obj, mapPos5 + value19, mapPos2 + def2.tile.h + value20, x2 + value19, mapPos + value20, duration, mapPos2 + def2.tile.h, value18, magicConfig) and node6 and not tolua.isnull(node6) then
					node6:setVisible(false)
				end
			end
		else
			if options == 35 then
				options2 = data.y
				options3 = data.x
			end

			if checkMagicLastPlayTime(options, options3, options2) then
				local x3, mapPos3 = self.getMapPos(self, options3, options2)
				local value46
				local value47
				local node3
				local node8, value48 = m2spr.playAnimation(value, number, count, count2, not magicConfig.noBlend, true, true)

				if self.setDark.control and self.opacity > 0 then
					local y2 = mapPos3 + def2.tile.h
					local roleid3 = data.roleid .. x3 .. y2
					local items2 = {}

					if magicId2 == 59 or magicId2 == 11 then
						for index2 = 2, 20, 2 do
							local x5, mapPos9 = self.getMapPos(self, options3, options2 - index2)

							items2[#items2 + 1] = {
								roleid = data.roleid .. x5 .. mapPos9,
								x = x5,
								y = mapPos9 + def2.tile.h
							}
						end
					end

					local value11 = count2 * count

					node3 = display.newNode():addto(self.layers.obj, options2 + def2.tile.h)

					node3:run(cc.RepeatForever:create(transition.sequence({
						cc.DelayTime:create(0.01),
						cc.CallFunc:create(function()
							if value11 > 0 then
								if magicId2 == 59 or magicId2 == 11 then
									local number3 = 1.8

									for _5, item5 in ipairs(items2) do
										self:addLight2(item5, "magic", number3)

										if number3 > 1 then
											number3 = number3 - 0.1
										end
									end
								end

								self:addLight2({
									roleid = roleid3,
									x = x3,
									y = y2
								}, "magic", 2)
							else
								for _6, item6 in ipairs(items2) do
									self:removeLight("magic", item6.roleid)
								end

								self:removeLight("magic", roleid3)

								if not tolua.isnull(node3) and tolua.cast(node3, "cc.Node") then
									node3:stopAllActions()
									node3:removeSelf()
								end
							end

							value11 = value11 - 0.02
						end)
					})))
				end

				node8.addto(node8, self.layers.obj, options2 + def2.tile.h)
				callback(node8, x3, mapPos3 + def2.tile.h)

				local value5 = magicParticle.resolvePreset(magicConfig)

				if value5 then
					local value21 = math.floor(def2.tile.w * 0.33)
					local enabled2 = false

					if value5 == "lightning" and magicParticle.lightningStrike then
						enabled2 = magicParticle.lightningStrike(self.layers.obj, x3 + value21, mapPos3 + def2.tile.h + def2.tile.h, value5, magicConfig, mapPos3 + def2.tile.h) ~= nil
					else
						enabled2 = magicParticle.burstAt(self.layers.obj, x3 + value21, mapPos3 + def2.tile.h + def2.tile.h, value5, magicConfig, mapPos3 + def2.tile.h) ~= nil
					end

					if enabled2 and node8 and not tolua.isnull(node8) then
						node8:setVisible(false)
					end
				end

				if tonumber(magicId2) == 6 and self.findRole(self, options4) and not enabled then
					sound.play("skillPlay", {
						idx = 3,
						magicId = magicId2
					})
				end
			end
		end
	end
end

function magic:showSpellNextEffect(data)
	local map = getMap()

	if not map then
		return
	end

	if not self.otherFrame then
		p2("error", "otherFrame is null next frame can not find")

		return
	end

	local value
	local value7
	local items2 = {}
	local node
	local mapPos2, mapPos = map.getMapPos(map, data.x, data.y)

	for _, otherFrame in ipairs(self.otherFrame) do
		if otherFrame.name == data.next then
			local value4 = otherFrame.begin

			if otherFrame.withDir then
				value4 = otherFrame.begin + data.dir * ((otherFrame.skip or 0) + otherFrame.frame)
			end

			if otherFrame.useTarget then
				local point = main_scene.ui.console.controller.lock.role

				if point and not point.die then
					mapPos2, mapPos = map.getMapPos(map, point.x, point.y)
				else
					return
				end
			end

			local value6

			value, value6 = m2spr.playAnimation(otherFrame.rsc or data.rsc, value4, otherFrame.frame, otherFrame.delay or 0.08, not self.noBlend, true, true, function()
				value:removeSelf()

				if otherFrame.next then
					magic.showSpellNextEffect(self, {
						dir = data.dir,
						next = otherFrame.next,
						rsc = data.rsc,
						x = data.x,
						y = data.y,
						role = data.role,
						asyncPriority = data.asyncPriority
					})
				end
			end, nil, data.asyncPriority)

			if map.setDark.control and map.opacity > 0 then
				if otherFrame.withDir then
					items2 = magic.getMagicLight(data.role, map, 2, 4)

					local value2 = otherFrame.frame * (otherFrame.delay or 0.08)

					node = display.newNode():addto(map.layers.obj, mapPos + def2.tile.h)

					node:run(cc.RepeatForever:create(transition.sequence({
						cc.DelayTime:create(0.01),
						cc.CallFunc:create(function()
							if value2 > 0 then
								for _2, item in ipairs(items2) do
									local items3 = {
										roleid = item.roleid,
										x = item.x,
										y = item.y
									}
									local value5 = ({
										[0] = {
											0,
											30
										},
										{
											-60,
											0
										},
										{
											-60,
											30
										},
										{
											-60,
											60
										},
										{
											0,
											60
										},
										{
											60,
											60
										},
										{
											60,
											30
										},
										{
											90,
											0
										}
									})[data.dir]

									items3.w, items3.h = value5[1], value5[2]

									map:addLight2(items3, "magic", 1.3)
								end
							else
								for _3, item3 in ipairs(items2) do
									map:removeLight("magic", item3.roleid)
								end

								if not tolua.isnull(node) and tolua.cast(node, "cc.Node") then
									node:stopAllActions()
									node:removeSelf()
								end
							end

							value2 = value2 - 0.01
						end)
					})))
				else
					if data.role and data.role.roleid and data.x and data.y then
						items2[#items2 + 1] = {
							roleid = data.role.roleid .. data.x .. data.y,
							x = data.x,
							y = data.y
						}
					end

					node = display.newNode():addto(map.layers.obj, mapPos + def2.tile.h)

					local value3 = otherFrame.frame * (otherFrame.delay or 0.08)

					node:run(cc.RepeatForever:create(transition.sequence({
						cc.DelayTime:create(0.01),
						cc.CallFunc:create(function()
							if value3 > 0 then
								for _4, item2 in ipairs(items2) do
									local items4 = {
										roleid = item2.roleid,
										x = item2.x,
										y = item2.y
									}

									map:addLight2(items4, "magic", 1.5)
								end
							else
								for _5, item4 in ipairs(items2) do
									map:removeLight("magic", item4.roleid)
								end

								if not tolua.isnull(node) and tolua.cast(node, "cc.Node") then
									node:stopAllActions()
									node:removeSelf()
								end
							end

							value3 = value3 - 0.01
						end)
					})))
				end
			end

			value:addto(map.layers.obj, mapPos + def2.tile.h)
			callback(value, mapPos2, mapPos + def2.tile.h)

			break
		end
	end
end

function magic:showSpellEffect(data)
	local map = getMap()

	if not map then
		return
	end

	self = self + 1

	for _, item in ipairs(def.magic.getConfig("skillMagic")) do
		if self == item.effectID then
			local items2 = def.magic.checkGroupStyle(item, data.role)

			if not items2.startFrame then
				return
			end

			local value2 = magicParticle.resolvePreset(items2)
			local enabled = false

			if value2 and data.role then
				local value6 = data.delay or 0.5

				if value2 == "lightning" and magicParticle.lightningCasterArc then
					enabled = magicParticle.lightningCasterArc(data.role, value2, items2, value6, def2.tile.h) ~= nil
				else
					enabled = magicParticle.auraCaster(data.role, value2, items2, value6, def2.tile.h) ~= nil
				end
			end

			local value

			if #items2.startFrame == 1 then
				local jobOwner = items2.startFrame[1]

				if not jobOwner.job or jobOwner.job and data.job and jobOwner.job == data.job then
					value = jobOwner
				end
			else
				for _2, startFrame in ipairs(items2.startFrame) do
					if startFrame.job and data.job and startFrame.job == data.job then
						value = startFrame

						break
					end
				end
			end

			if not value then
				return p2("error", "get start effect frame info error")
			end

			if def.ccy.isOpenCSSkill() then
				local rsc2 = items2.rsc
				local value3 = data.delay

				if value.rsc then
					rsc2 = value.rsc
				end

				if value.delay then
					value3 = value.delay * value.frame
				end

				local mapPos3, mapPos = map.getMapPos(map, data.x, data.y)
				local node3
				local value15
				local value16
				local value17
				local node
				local value7 = value.begin

				if value.withDir then
					value7 = value.begin + data.dir * ((value.skip or 0) + value.frame)
				end

				local value12

				node3, value12 = m2spr.playAnimation(rsc2, value7, value.frame, value3 / value.frame, not item.noBlend, false, true, function()
					node3:removeSelf()

					if value.next then
						if not items2.otherFrame then
							p2("error", "otherFrame is null next frame can not find")

							return
						end

						magic.showSpellNextEffect(items2, {
							dir = data.dir,
							next = value.next,
							rsc = rsc2,
							x = data.x,
							y = data.y,
							role = data.role,
							asyncPriority = data.asyncPriority
						})
					end
				end, nil, data.asyncPriority)

				if map.setDark.control and map.opacity > 0 then
					local magicConfig = def.magic.getMagicConfig(self)

					if magicConfig then
						local value8 = magicConfig.uid
						local x2, position = data.role.node:getPosition()
						local value13 = value8 == 24 and 2 or 1.3
						local value9 = value8 == 24 and 35 or 50

						if self == 7 or self == 8 then
							value9 = 0
						end

						local value4 = value.frame * (value3 / value.frame)

						node = display.newNode():addto(map.layers.obj, mapPos + def2.tile.h)

						node:run(cc.RepeatForever:create(transition.sequence({
							cc.DelayTime:create(0.01),
							cc.CallFunc:create(function()
								if value4 > 0 then
									local items3 = {
										roleid = data.role.roleid,
										x = x2,
										y = position + value9
									}

									map:addLight2(items3, "magic", value13)
								else
									map:removeLight("magic", data.role.roleid)

									if not tolua.isnull(node) and tolua.cast(node, "cc.Node") then
										node:stopAllActions()
										node:removeSelf()
									end
								end

								value4 = value4 - 0.01
							end)
						})))
					end
				end

				node3.addto(node3, map.layers.obj, mapPos + def2.tile.h)
				callback(node3, mapPos3, mapPos + def2.tile.h)

				if enabled and node3 and not tolua.isnull(node3) then
					node3:setVisible(false)
				end
			else
				local mapPos4, mapPos2 = map.getMapPos(map, data.x, data.y)
				local value18
				local value19
				local node2
				local node4, value20 = m2spr.playAnimation(items2.rsc, value.begin, value.frame, data.delay / value.frame, not item.noBlend, true, true, nil, nil, data.asyncPriority)

				if map.setDark.control and map.opacity > 0 then
					local magicConfig2 = def.magic.getMagicConfig(self)

					if magicConfig2 then
						local value10 = magicConfig2.uid
						local x3, position2 = data.role.node:getPosition()
						local value14 = value10 == 24 and 2 or 1.3
						local value11 = value10 == 24 and 35 or 50

						if self == 7 or self == 8 then
							value11 = 0
						end

						local value5 = value.frame * (data.delay / value.frame)

						node2 = display.newNode():addto(map.layers.obj, mapPos2 + def2.tile.h)

						node2:run(cc.RepeatForever:create(transition.sequence({
							cc.DelayTime:create(0.01),
							cc.CallFunc:create(function()
								if value5 > 0 then
									local items4 = {
										roleid = data.role.roleid,
										x = x3,
										y = position2 + value11
									}

									map:addLight2(items4, "magic", value14)
								else
									map:removeLight("magic", data.role.roleid)

									if not tolua.isnull(node2) and tolua.cast(node2, "cc.Node") then
										node2:stopAllActions()
										node2:removeSelf()
									end
								end

								value5 = value5 - 0.01
							end)
						})))
					end
				end

				node4.addto(node4, map.layers.obj, mapPos2 + def2.tile.h)
				callback(node4, mapPos4, mapPos2 + def2.tile.h)

				if enabled and node4 and not tolua.isnull(node4) then
					node4:setVisible(false)
				end
			end

			break
		end
	end
end

function magic:showHitEffect(data, rsc2)
	local map = getMap()

	if not map then
		return
	end

	if not rsc2 then
		for _, item2 in ipairs(def.magic.getConfig("skillMagic")) do
			if item2.uid == self then
				local value = def.magic.checkGroupStyle(item2, data.role)

				if not value.hitFrame then
					return
				end

				for _2, hitFrame in ipairs(value.hitFrame) do
					if hitFrame.type then
						if hitFrame.type == data.type then
							rsc2 = hitFrame
							rsc2.rsc = hitFrame.rsc or value.rsc
							rsc2.otherFrame = value.otherFrame
						end
					elseif hitFrame.job and data.job and hitFrame.job == data.job and def.ccy.isOpenCSSkill() then
						rsc2 = hitFrame
						rsc2.rsc = hitFrame.rsc or value.rsc
						rsc2.otherFrame = value.otherFrame
					else
						rsc2 = hitFrame
						rsc2.rsc = hitFrame.rsc or value.rsc
						rsc2.otherFrame = value.otherFrame
					end
				end

				break
			end
		end

		if not rsc2 then
			return
		end
	end

	local value2 = rsc2.begin

	if not rsc2.nodir then
		value2 = value2 + data.dir * ((rsc2.skip or 0) + rsc2.frame)
	end

	local mapPos2, mapPos = map.getMapPos(map, data.x, data.y)
	local value3
	local value9
	local node
	local items2 = {}
	local value6

	value3, value6 = m2spr.playAnimation(rsc2.rsc, value2, rsc2.frame, rsc2.delay or data.delay / rsc2.frame, not rsc2.noBlend, false, true, function()
		value3:removeSelf()

		if rsc2.next then
			if not rsc2.otherFrame then
				p2("error", "otherFrame is null next frame can not find")

				return
			end

			for _3, otherFrame in ipairs(rsc2.otherFrame) do
				if otherFrame.name == rsc2.next then
					otherFrame.rsc = rsc2.rsc
					otherFrame.otherFrame = rsc2.otherFrame

					magic.showHitEffect(self, data, otherFrame)

					break
				end
			end
		end
	end, nil, data.asyncPriority):addto(map.layers.obj, mapPos + def2.tile.h)

	if map.setDark.control and map.opacity > 0 and self ~= 7 then
		local value7 = self == 58 and 4 or 2
		local value8 = self == 58 and 1.3 or checkExist(self, 25, 26) and 1.5 or 1.3

		items2 = magic.getMagicLight(data.role, map, 2, value7)

		local value4 = (rsc2.delay or data.delay / rsc2.frame) * (rsc2.frame / 3)

		node = display.newNode():addto(map.layers.obj, mapPos + def2.tile.h)

		node:run(cc.RepeatForever:create(transition.sequence({
			cc.DelayTime:create(0.01),
			cc.CallFunc:create(function()
				if value4 > 0 then
					for _4, item in ipairs(items2) do
						local items3 = {
							roleid = item.roleid,
							x = item.x,
							y = item.y
						}
						local value5 = ({
							[0] = {
								0,
								30
							},
							{
								-60,
								0
							},
							{
								-60,
								30
							},
							{
								-60,
								60
							},
							{
								0,
								60
							},
							{
								60,
								60
							},
							{
								60,
								30
							},
							{
								90,
								0
							}
						})[data.role.dir]

						items3.w, items3.h = value5[1], value5[2]

						map:addLight2(items3, "magic", value8)
					end
				else
					for _5, item3 in ipairs(items2) do
						map:removeLight("magic", item3.roleid)
					end

					if not tolua.isnull(node) and tolua.cast(node, "cc.Node") then
						node:stopAllActions()
						node:removeSelf()
					end
				end

				value4 = value4 - 0.01
			end)
		})))
	end

	callback(value3, mapPos2, mapPos + def2.tile.h)
end

function magic:showWithName(data, player)
	if data == "bloodlust" then
		local items3 = {}
		local role2 = self.findRole(self, player.roleid)

		if not role2 then
			return
		end

		if not checkMagicLastPlayTime(data, role2.x, role2.y) then
			return
		end

		player.y = role2.y
		player.x = role2.x

		local items2 = {
			rscIdx = 1090,
			noBlend = false,
			delay = 0.14,
			rsc = "magic2",
			frame = 10
		}
		local mapPos5, mapPos = self.getMapPos(self, player.x, player.y)
		local value4 = m2spr.playAnimation(items2.rsc, items2.rscIdx, items2.frame, items2.delay, not items2.noBlend, true, true):addto(self.layers.obj, mapPos + def2.tile.h)

		callback(value4, mapPos5, mapPos + def2.tile.h)
	else
		for _, item in ipairs(def.magic.getConfig("mapMagic")) do
			if item.name == data and (not item.byRace or item.byRace == player.role:getRace()) then
				if item.sound then
					sound.playSound(tostring(item.sound))
				end

				if item.playType == 1 then
					local role3 = self.findRole(self, player.roleid)

					if not role3 then
						return
					end

					if not checkMagicLastPlayTime(item.name, role3.x, role3.y) then
						return
					end

					player.y = role3.y
					player.x = role3.x
				elseif item.playType == 2 then
					if not item.skip then
						p2("show map magic " .. item.name .. " not find key skip")
					end

					local value5 = item.rscIdx + (item.frame + item.skip) * player.role.dir * 2
					local mapPos6, mapPos2 = self.getMapPos(self, player.role.x, player.role.y)
					local mapPos7, mapPos8 = self.getMapPos(self, player.x, player.y)
					local value8
					local value6 = m2spr.playAnimation(item.rsc, value5, item.frame, item.delay, not item.noBlend):addto(self.layers.obj, mapPos2 + def2.tile.h):runs({
						cc.MoveTo:create(0.2, cc.p(mapPos7, mapPos8 + def2.tile.h)),
						cca.removeSelf()
					})

					callback(value6, mapPos6, mapPos2 + def2.tile.h)

					return
				elseif item.playType == 3 then
					local role4 = self.findRole(self, player.roleid)

					if not role4 then
						return
					end

					local mapPos9, mapPos3 = self.getMapPos(self, player.x, player.y)
					local value7 = item.rscIdx + role4.dir * 10
					local value

					value = m2spr.playAnimation(item.rsc, value7, item.frame, item.delay, not item.noBlend, nil, true, function()
						value:removeSelf()

						if item.next then
							magic:showWithName(self, item.next, player)
						end
					end):addto(self.layers.obj, mapPos3 + def2.tile.h)

					callback(value, mapPos9, mapPos3 + def2.tile.h)

					return
				end

				local mapPos10, mapPos4 = self.getMapPos(self, player.x, player.y)
				local value2 = item.runForever or false
				local text

				if value2 then
					if not self.runForeverEffects then
						self.runForeverEffects = {}
					end

					text = def.ccy.md("EFID_" .. g_data.map.mapTitle .. data .. tostring(player.x) .. tostring(player.y))

					if self.runForeverEffects[text] then
						self.runForeverEffects[text]:removeSelf()

						self.runForeverEffects[text] = nil
					end
				end

				local value3 = m2spr.playAnimation(item.rsc, item.rscIdx, item.frame, item.delay, not item.noBlend, true, not value2):addto(self.layers.obj, mapPos4 + def2.tile.h)

				if text then
					self.runForeverEffects[text] = value3
				end

				callback(value3, mapPos10, mapPos4 + def2.tile.h)

				return
			end
		end
	end
end

local items = {}

function checkMagicLastPlayTime(self, value3, value4)
	local value = self .. "-" .. value3 .. "-" .. value4
	local time = socket.gettime()
	local value2 = items[value]

	items[value] = time

	return not value2 or time - value2 > 0.3
end

function getMap()
	if not main_scene then
		return
	end

	return main_scene.ground.map
end

return magic
