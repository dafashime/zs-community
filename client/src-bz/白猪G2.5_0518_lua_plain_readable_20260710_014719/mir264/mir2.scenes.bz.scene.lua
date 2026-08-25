import("mir2.bzconfig")

local bzUIConfig = require("mir2.bzUIConfig")
local scene = require("mir2.scenes.sfselect.scene")

local function updateVisible()
	def.setLoginCenter(def.gateIP, def.gatePort, "君临复古", "1997dw")
	cache.setIsFirstLaunchGame(false)
	cache.setLastSfServer("君临复古")
	game.gotoscene("login", {
		logout = false
	}, "fade", 0.5, display.COLOR_BLACK)
end

function scene:gotoLogin(delayF)
	if def.skipSFselect then
		self.delayF = scheduler.performWithDelayGlobal(updateVisible, delayF or 3)
	else
		if device.platform == "android" then
			self:setKeypadEnabled(true)
			self:addNodeEventListener(cc.KEYPAD_EVENT, function(keyOwner)
				if keyOwner.key == "back" then
					an.newMsgbox("是否退出游戏?", function(value)
						if value == 1 then
							os.exit(1)
						end
					end, {
						center = true,
						hasCancel = true
					})
				end
			end)
		end

		self:requestSfList()
	end
end

function scene:playVideo(value)
	if not value then
		return
	end

	local instance = cc.FileUtils:getInstance():fullPathForFilename("res/mp4/" .. value .. ".mp4")

	if io.exists(instance) then
		local node = display.newNode():addTo(self):size(display.width, display.height):anchor(0, 0)
		local instance2 = cc.Director:getInstance():getOpenGLView():getVisibleRect()
		local node2 = ccexp.VideoPlayer:create()
		local items = {
			STOPPED = 2,
			PLAYING = 0,
			PAUSED = 1,
			COMPLETED = 3
		}

		local function updateVisible(self2, value2)
			if value2 == items.PAUSED then
				node2:performWithDelay(function()
					node2:resume()
					node2:play()
				end, 0)
			elseif value2 == items.COMPLETED or device.platform == "mac" or device.platform == "windows" then
				node2:stop()
				node2:run(cca.removeSelf())
				self:gotoLogin(0)
			end
		end

		node2:setContentSize(cc.size(display.width, display.height))
		node2:setAnchorPoint(cc.p(0.5, 0.5))
		node2:setPosition(cc.p(display.cx, display.cy))
		node2:setFileName(instance)
		node2:setKeepAspectRatioEnabled(false)
		node2:setTouchEnabled(false)
		node2:setFullScreenEnabled(true)
		node2:setVisible(true)
		node2:addEventListener(updateVisible)
		node2:addto(node)
		node2:play()
	end
end

function scene:ctor(params)
	self:setNodeEventEnabled(true)

	self.params = params
	self.curPageIndex = 1

	local duration = bzUIConfig.loginScene

	if duration.isPlayMuisc then
		sound.playMusic(duration.playMusic, duration.playMusicAways)
	end

	if duration.playAni then
		if duration.mp4 then
			self:playVideo(duration.mp4)
		else
			local ani2 = res.getani2("pic/bzmir/newui/login/animate/%d.png", 1, duration.playAniMax, duration.playAniInterval)

			if ani2 then
				ani2:retain()

				local value_2 = res.get2("pic/bzmir/newui/login/animate/1.png"):addTo(self):center():fit()

				value_2:runForever(cc.Animate:create(ani2))
				value_2:runs({
					cc.DelayTime:create(duration.playAniMax * duration.playAniInterval / 2),
					cc.CallFunc:create(function()
						if value_2 then
							value_2:removeSelf()

							value_2 = nil
						end

						self:gotoLogin(0.5)
					end)
				})
			else
				res.get2("pic/bzmir/newui/login/" .. duration.defaultBackground .. ".png"):addTo(self):center():fit()
				self:gotoLogin()
			end
		end
	else
		res.get2("pic/bzmir/newui/login/" .. duration.defaultBackground .. ".png"):addTo(self):center():fit()
		self:gotoLogin()
	end
end

function scene:onExit()
	if self.pageHandler then
		scheduler.unscheduleGlobal(self.pageHandler)

		self.pageHandler = nil
	end

	if self.delayF then
		scheduler.unscheduleGlobal(self.delayF)

		self.delayF = nil
	end
end

return scene
