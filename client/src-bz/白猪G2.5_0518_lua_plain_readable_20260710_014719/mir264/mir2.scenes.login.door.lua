local bzUIConfig = require("mir2.bzUIConfig")
local door = class("door", function()
	return display.newNode()
end)

table.merge(door, {})

function door:playVideo(value2, value3)
	local instance = cc.FileUtils:getInstance():fullPathForFilename("res/mp4/" .. value2 .. ".mp4")

	if io.exists(instance) then
		layer = display.newNode():addTo(self):size(display.width, display.height):anchor(0, 0)

		local instance2 = cc.Director:getInstance():getOpenGLView():getVisibleRect()
		local node = ccexp.VideoPlayer:create()
		local items = {
			STOPPED = 2,
			PLAYING = 0,
			PAUSED = 1,
			COMPLETED = 3
		}

		local function updateVisible(self2, value)
			if value == items.PAUSED then
				node:performWithDelay(function()
					node:resume()
					node:play()
				end, 0)
			elseif value == items.COMPLETED or device.platform == "mac" or device.platform == "windows" then
				node:stop()
				node:run(cca.removeSelf())
				self:gotoSelect(value3)
			end
		end

		node:setContentSize(cc.size(display.width, display.height))
		node:setAnchorPoint(cc.p(0.5, 0.5))
		node:setPosition(cc.p(display.cx, display.cy))
		node:setFileName(instance)
		node:setKeepAspectRatioEnabled(false)
		node:setTouchEnabled(false)
		node:setFullScreenEnabled(true)
		node:setVisible(true)
		node:addEventListener(updateVisible)
		node:addto(layer)
	end
end

function door:ctor(scene)
	local duration = bzUIConfig.openDoor

	if duration.mp4 then
		g_data.player.smallExit = true

		if duration.playSound then
			sound.preloadSound(duration.sound)
		end

		if scene.loseConnect then
			return
		end

		net.remove(scene)
		self:playVideo(duration.mp4, scene)
	elseif duration.customAni then
		local ani2 = res.getani2("pic/bzmir/newui/login/door/%d.png", duration.start, duration.start + duration.frame, duration.interval)

		if ani2 then
			ani2:retain()

			if duration.playSound then
				sound.playSound(duration.sound, true)
			end

			local pic = res.get2("pic/bzmir/newui/login/door/" .. duration.start .. ".png"):addTo(self):center()

			pic.setScaleX(pic, duration.scalex)
			pic.setScaleY(pic, duration.scaley)
			pic:runForever(cc.Animate:create(ani2))
			pic:runs({
				cc.DelayTime:create(duration.frame * duration.interval),
				cc.CallFunc:create(function()
					if pic then
						pic:removeSelf()

						pic = nil
					end

					self:gotoSelect(scene)
				end)
			})
		end
	else
		local value = m2spr.new(duration.whichLib, duration.start):addto(self):pos(duration.posx, duration.posy)

		value.setScaleX(value, duration.scalex)
		value.setScaleY(value, duration.scaley)

		g_data.player.smallExit = true

		if duration.playSound then
			sound.preloadSound(duration.sound)
		end

		value.runs(value, {
			cc.DelayTime:create(0.7),
			cc.CallFunc:create(function()
				if duration.playSound then
					sound.playSound(duration.sound, true)
				end

				value:playAni(duration.whichLib, duration.start, duration.frame, duration.interval, nil, nil, true, function()
					self:gotoSelect(scene)
				end)
			end)
		})
	end
end

function door:gotoSelect(sender)
	audio.stopAllSounds()
	game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
end

return door
