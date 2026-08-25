local tip = class("centerTopTip", function()
	return display.newNode()
end)

table.merge(tip, {
	curNode,
	timeLabel,
	isDie
})

function tip:ctor()
	self.curNode = nil
	self.timeLabel = nil
	self.isDie = false
end

function tip:doRelive()
	local value
	local btnTexts = {}

	if def.role.kill.reliveType == 1 then
		btnTexts = {
			def.role.kill.reliveBTN1,
			"小退"
		}
	else
		btnTexts = {
			def.role.kill.reliveBTN1,
			def.role.kill.reliveBTN2,
			"小退"
		}
	end

	local msgbox = an.newMsgbox("", function(value)
		if def.role.kill.reliveType == 1 then
			if value == 1 and self:canDoRelive(value) then
				net.send({
					CM_SAY
				}, {
					"@SetNoKillMapLv " .. tostring(def.role.kill.reliveBTNAct1)
				})
			end

			return
		else
			if value == 1 and self:canDoRelive(value) then
				net.send({
					CM_SAY
				}, {
					"@SetNoKillMapLv " .. tostring(def.role.kill.reliveBTNAct1)
				})
			elseif value == 2 and self:canDoRelive(value) then
				net.send({
					CM_SAY
				}, {
					"@SetNoKillMapLv " .. tostring(def.role.kill.reliveBTNAct2)
				})
			elseif value == 3 then
				main_scene:smallExit()
			end

			return
		end
	end, {
		disableScroll = true,
		btnTexts = btnTexts
	})
	local text = ""
	local value2 = def.role.kill.reliveMainText
	local size = cc.LabelTTF:create(value2, "", 20, cc.size(320, 0), 1)

	size.anchor(size, 0.5, 1)
	size.setPosition(size, msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 + 30)
	msgbox.bg:addChild(size)
	an.newLabel(def.role.kill.reliveSubText, 16, 1, {
		color = cc.c3b(162, 78, 54)
	}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw() * 0.5, msgbox.bg:geth() * 0.5 - 10)
end

function tip:canDoRelive(value)
	local function cleanup(self, value)
		if self ~= nil and self ~= "" then
			if self == CS_GRID then
				if value > g_data.player.goldNum.gird then
					main_scene.ui:fadeLabel(CS_GRID .. "不足，无法复活")

					return false
				end
			elseif self == CS_YB then
				if value > g_data.player.goldNum.gold then
					main_scene.ui:fadeLabel(CS_YB .. "不足，无法复活")

					return false
				end
			elseif self == "金币" then
				if value > g_data.player.gold then
					main_scene.ui:fadeLabel("金币不足，无法复活")

					return false
				end
			elseif not g_data.bag:getItemWithNameAndDura(self, value) then
				main_scene.ui:fadeLabel(self .. "不足，无法复活")

				return false
			end
		end

		return true
	end

	if def.role.kill.reliveType == 1 then
		return cleanup(def.role.kill.relive1useitem, def.role.kill.relive1itemneed)
	elseif value == 1 then
		return cleanup(def.role.kill.relive1useitem, def.role.kill.relive1itemneed)
	else
		return cleanup(def.role.kill.relive2useitem, def.role.kill.relive2itemneed)
	end

	return true
end

function tip:show(type)
	if self.curNode then
		self.curNode:removeSelf()

		self.curNode = nil
	end

	self.isDie = true

	local enabled = true
	local text = "60秒内点击复活按钮进行复活"
	local text2 = "秒内点击复活按钮进行复活"
	local text3 = "pic/common/relive0.png"
	local text4 = "pic/common/relive1.png"

	if def.role.kill.closeRelive then
		text = "60秒内点击快速小退后重新进入游戏"
		text2 = "秒内点击快速小退后重新进入游戏"
		text3 = "pic/common/relive2.png"
		text4 = "pic/common/relive3.png"
		enabled = false
	end

	local text5 = 60
	local btn = an.newBtn(res.gettex2(text3), function()
		sound.playSound("103")

		if text5 > 0 and enabled then
			self:doRelive(self)
		else
			main_scene:smallExit()

			return
		end
	end, {
		pressImage = res.gettex2(text4)
	}):anchor(0, 0)

	self.curNode = display.newNode():add(btn):size(btn:getw(), btn:geth()):anchor(0.5, 0.5):opacity(0):add2(self)
	self.timeLabel = an.newLabel(text, 20, 1, {
		color = display.COLOR_YELLOW
	}):anchor(0.5, 0.5):pos(self.curNode:getw() * 0.5, -10):opacity(255):add2(self.curNode):run(cc.RepeatForever:create(transition.sequence({
		cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			if g_data.setting.base.relive ~= nil and g_data.setting.base.relive then
				g_data.setting.base.relive = false
				self.isDie = false

				def.role.runonce(self.curNode, function()
					if not self.isDie then
						self.curNode:removeSelf()

						self.curNode = nil
					end
				end, 0.1)
			end

			text5 = text5 - 1

			if text5 > 10 and text5 <= 60 then
				self.timeLabel:setString(tostring(text5) .. text2)
			elseif text5 <= 1 then
				self.timeLabel:setString("超时后请尝试小退或大退重新登录")
			end
		end)
	})))

	self.curNode:pos(display.cx, display.height - 120)
	self.curNode:moveTo(0.3, display.cx, display.height - 80)
end

function tip:hide()
	if self.curNode then
		self.curNode:removeSelf()

		self.curNode = nil
	end
end

return tip
