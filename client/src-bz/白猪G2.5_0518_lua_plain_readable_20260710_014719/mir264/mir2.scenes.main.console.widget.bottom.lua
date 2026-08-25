local bzUIConfig = require("mir2.bzUIConfig")
local extendUI = require("mir2.scenes.main.common.extendUI")
local cc2 = require("mir2.cc")
local bottom = class("bottom", function()
	return display.newNode()
end)

table.merge(bottom, {
	config,
	data,
	progress,
	mapTitle,
	mapPos,
	zoneInfo,
	showJyValue
})

local function callback()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

function bottom:ctor(config, data)
	self.size(self, display.width, 28):anchor(0.5, 0.5):pos(data.x, data.y)

	local value = bzUIConfig.bottomCfg

	if value then
		local items = {
			x = 4,
			y = 4
		}
		local x = _get2("pic/bzmir/newui/bottom/bg1.png"):anchor(0, 0):add2(self)
		local value2 = _get2("pic/bzmir/newui/bottom/bg2.png"):anchor(0, 0):pos(x.getw(x), 0):add2(self)
		local value3 = _get2("pic/bzmir/newui/bottom/bg3.png"):anchor(1, 0):pos(display.width, 0):add2(self)

		value2.scalex(value2, (display.width - x.getw(x) - value3.getw(value3)) / value2.getw(value2))

		local h = self.geth(self) / 2 - 2
		local number = 4
		local x2 = 10

		if callback() then
			x2 = getSafeAreaInsets() / 2
		end

		self.signal = display.newSprite():anchor(0, 0.5):pos(x2, h):add2(self):scale(0.8)

		self:uptSignal()

		local x3 = x2 + self.signal:getw() + 5

		if device.platform == "ios" or def.openBettery and device.platform == "android" then
			self.battery = an.newProgress(_gettex2("pic/bzmir/newui/bottom/full.png"), _gettex2("pic/bzmir/newui/bottom/empty.png"), items):addTo(self):anchor(0, 0.5):pos(x3, h):scale(0.8)
			x3 = x3 + self.battery:getw() + 5
		end

		self.time = an.newLabel("", 14, 1):pos(x3, h):add2(self):anchor(0, 0.5)

		self.time:setString(os.date("%H:%M:%S"))

		local x4 = x3 + self.time:getw() + 5

		self.zoneInfo = an.newLabel("", 16, 1):pos(x4, 2):add2(self)

		if value.showLevel then
			local x5 = _get2("pic/bzmir/newui/bottom/" .. value.lv.lvbg .. ".png"):add2(self)
			local x6 = display.cx + value.lv.lvPosOffsetx
			local y = h + value.lv.lvPosOffsety

			x5:pos(x6, y)

			local value4 = _get2("pic/bzmir/newui/bottom/" .. value.lv.lvTextbg .. ".png"):add2(self)
			local x7 = x6 - x5:getw() - number + 13

			value4:pos(x7, y)

			self.lvText = an.newLabel("-", value.lv.lvTextSize, 1):anchor(0.5, 0.5):pos(x5:getw() / 2, x5:geth() / 2):add2(x5, 1)

			self.lvText:setColor(def.role.string2Color(value.lv.lvTextColor))
		end

		local x8 = display.cx + (value.jingyan.jyPosOffsetx or 0)
		local y2 = value.jingyan.jyPosOffsety or -1

		self.progress = an.newProgress(_gettex2("pic/bzmir/newui/bottom/" .. value.jingyan.expbar .. ".png"), _gettex2("pic/bzmir/newui/bottom/" .. value.jingyan.expbg .. ".png"), value.jingyan.expPos):pos(x8, y2):add2(self)
		self.text = an.newLabel("", value.jingyan.jyTextSize, 1):anchor(0.5, 0.5):pos(self.progress:getw() / 2, self.progress:geth() / 2):add2(self.progress, 1)

		self.text:setColor(def.role.string2Color(value.jingyan.jyTextColor))

		self.showJyValue = value.jingyan.showJyValue

		if value.showCopyright then
			local x9 = display.width - value.copyrignt.cpPosOffsetx
			local number2 = 2
			local value5 = value.copyrignt.cpCustomText or "独家版本"

			if value.copyrignt.showZonename and g_data.login.localLastSer then
				value5 = g_data.login.localLastSer.zoneid .. "区 " .. g_data.login.localLastSer.zonename
			end

			self.copyText = an.newLabel(value5, value.copyrignt.cpTextSize, 1):anchor(1, 0.5):pos(x9, h):add2(self)

			self.copyText:setColor(def.role.string2Color(value.copyrignt.cpTextColor))
		end

		self.getEventDispatcher(self):addEventListenerWithSceneGraphPriority(cc.EventListenerCustom:create("CONNECTIVITY_ACTION", function()
			return
		end), self)
	end

	if not safeAreaTimer then
		safeAreaTimer = def.role.createRepeater(function()
			if not main_scene then
				def.role.stopRepeater(safeAreaTimer)

				safeAreaTimer = nil

				print("safeAreaTimer stoped")

				return
			end

			if main_scene and main_scene.ui and main_scene.ground then
				self:uptZoneinfo()
			end
		end, 1)
	end
end

function bottom:uptData()
	local ability = g_data.player.ability
	local value = fixuint(ability:get("Exp"))
	local value2 = fixuint(ability:get("maxExp"))
	local p = value / value2

	if p > 1 then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	self.progress:setp(p)

	if self.showJyValue then
		self.text:setString(string.format("%s / %s (%.2f", value, value2, p * 100) .. "%)")
	else
		self.text:setString(string.format("%.2f", p * 100) .. "%")
	end

	if self.lvText then
		local text = string.format("%s级", ability.level)

		self.lvText:setString(text)
	end

	def.newUIBtm = true
end

function bottom:uptAbility()
	return
end

function bottom:upt()
	if self.uptData then
		self:uptData()
	end
end

function bottom:update(dt)
	return
end

function bottom:uptMap()
	local text = ""

	cc2.ms({
		function()
			sound.stopMusic()

			if def.role.darking and g_data.setting.base.musicEnalbe then
				sound.playMusic("night", true)
			end

			g_data.setting.base.mapMusic = nil

			local items = def.role.mainsetting.map_Set

			if items and #items > 0 then
				def.role.mainsetting.canrelive = true
				def.role.mainsetting.canshiqu = true
				def.role.mainsetting.disableAutoRat = false
				def.role.mainsetting.banChgMode = false
				def.role.mainsetting.banShuiji = false
				def.role.mainsetting.banProtect = false

				if g_data.player then
					g_data.player:setUnlimitedMoveState(def.unLimitedMoveState or 0)
				end

				local value = g_data.map.mapTitle

				if value and value ~= "" then
					for _, item in ipairs(items) do
						if string.find(item.mapname, value) ~= nil then
							if item.relive ~= nil and not item.relive then
								def.role.mainsetting.canrelive = false

								if text == "" then
									text = "禁止复活"
								else
									text = text .. " 复活"
								end
							end

							if item.shiqu ~= nil and not item.shiqu then
								def.role.mainsetting.canshiqu = false

								if text == "" then
									text = "禁止拾取"
								else
									text = text .. " 拾取"
								end
							end

							if item.banChgMode ~= nil and item.banChgMode then
								def.role.mainsetting.banChgMode = true
							end

							if item.banShuiji ~= nil and item.banShuiji then
								def.role.mainsetting.banShuiji = true
							end

							if item.banProtect ~= nil and item.banProtect then
								def.role.mainsetting.banProtect = true
							end

							if item.openAutoRat ~= nil and not item.openAutoRat then
								def.role.mainsetting.disableAutoRat = true

								if main_scene.ui.console.autoRat.enableRat then
									main_scene.ui.console.autoRat:stop()
								end

								if text == "" then
									text = "禁止挂机"
								else
									text = text .. " 挂机"
								end
							end

							if item.unLimitedMoveState then
								g_data.player:setUnlimitedMoveState(tonumber(item.unLimitedMoveState) or def.unLimitedMoveState or 0)
							end

							if not def.role.darking then
								if item.music ~= nil then
									g_data.setting.base.mapMusic = item.music

									if g_data.setting.base.musicEnalbe and not def.role.darking then
										sound.playMusic(item.music, true)
									end

									break
								end

								sound.stopMusic()
							end

							break
						end
					end
				end
			end
		end
	})
	self.zoneInfo:setString("")

	self.mapState = ""

	if main_scene.ui.panels.minimap and main_scene.ui.panels.minimap.uptMapInfo and text then
		main_scene.ui.panels.minimap:uptMapInfo(text)
	end

	main_scene.ui.console:call("infoBar", "uptMap", g_data.map.mapTitle, g_data.map.mapState)
end

local function callback2(self)
	if self == cAreaStateFight then
		return "[战斗]"
	elseif self == cAreaStateSafe or g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
		return "[安全]"
	elseif self == cAreaStateGuildWar then
		return "[攻城]"
	elseif self == cAreaStateDareWar then
		return "[挑战]"
	elseif self == cAreaStateReliveable then
		return "[复活]"
	else
		return "[激情]"
	end
end

local function callback3(self)
	if self == cAreaStateFight then
		return display.COLOR_RED
	elseif self == cAreaStateSafe or g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
		return display.COLOR_GREEN
	elseif self == cAreaStateGuildWar then
		return cc.c3b(250, 210, 100)
	elseif self == cAreaStateDareWar then
		return display.COLOR_RED
	elseif self == cAreaStateReliveable then
		return display.COLOR_GREEN
	end

	return def.colors.get(149)
end

function bottom:uptZoneinfo()
	local mapState = callback2(g_data.map.mapState)

	if self.mapState ~= mapState then
		if not main_scene.ui.panels.minimap or not main_scene.ui.panels.minimap.uptZoneSafe then
			self.zoneInfo:setString(mapState)
			self.zoneInfo:setColor(callback3(g_data.map.mapState))
		else
			self.zoneInfo:setString("")
		end

		self.mapState = mapState
	end
end

function bottom:genExtend(value, value2)
	cc2.ms({
		function()
			extendUI.create(self, value, "bottom_ext", nil, nil, nil, value2)
		end
	})
end

function bottom:uptTime()
	if g_data.login.serverTime then
		self.time:setString(os.date("%H:%M:%S", g_data.login.serverTime))
	else
		self.time:setString(os.date("%H:%M:%S"))
	end
end

function bottom:uptSignal()
	local enabled
	local value

	if device.platform == "ios" then
		local internetConnectionStatus = network.getInternetConnectionStatus()

		value = ({
			"wifi",
			"mobile"
		})[internetConnectionStatus] or "null"
		enabled = true
	elseif device.platform == "android" then
		enabled, value = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "DeviceUtil", "getCurrentNetType", {}, "()Ljava/lang/String;")
	end

	if enabled and value then
		local value2 = string.lower(value)

		self.signal:setTex(_gettex2("pic/bzmir/newui/bottom/" .. (value2 == "wifi" and "wifi" or "3g") .. ".png"))
	end
end

function bottom:uptBattery()
	local value
	local value2

	if device.platform == "ios" then
		value, value2 = luaoc.callStaticMethod("iosFuncs", "getBattery")
	elseif def.openBettery and device.platform == "android" then
		value, value2 = luaj.callStaticMethod(ANDROID_PACKAGE_NAME .. "Mir2", "getBattery", {}, "()I")
	end

	if value and value2 then
		local value3 = value2 / 100

		if value3 > 1 then
			value3 = 1
		end

		if value3 < 0 then
			value3 = 0
		end

		self.battery:setp(value3)
	end
end

return bottom
