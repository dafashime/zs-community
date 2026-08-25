local yayaListenner = import(".common.yayaListenner")
local yaya = require("mir2.single.yaya")
local btnFixed = class("btnFixed", function()
	return display.newNode()
end)

table.merge(btnFixed, {
	data,
	config,
	modeChooseNode,
	curModeChooseIsShow
})

local function callback()
	if g_data.setting.base.liuhaier then
		return needsSafeAreaAdjustment()
	end

	return false
end

local cc2 = require("mir2.cc")

function btnFixed:ctor(config, data)
	local bg = "pic/console/fixedBtn/btnbg10.png"
	local bg2 = "pic/console/fixedBtn/btnbg11.png"
	local text
	local text_offset
	local count = 0
	local count2 = 0

	if callback() then
		local safeAreaInsets

		count, safeAreaInsets = getSafeAreaInsets()
	end

	if config.key == "btnMap" then
		text = "pic/console/fixedBtn/text_map.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnExit" then
		text = "pic/console/fixedBtn/text_exit.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnMode" then
		text = "pic/console/modes/quanti.png"
		text_offset = cc.p(-3, 0)
		data.x = data.x + count
	elseif config.key == "btnPet" then
		text = "pic/console/fixedBtn/text_pet.png"
		text_offset = cc.p(-3, 0)
		data.x = data.x + count
	elseif config.key == "btnDiy" then
		text = "pic/console/fixedBtn/text_diy.png"
		text_offset = cc.p(-3, 0)
		data.x = data.x + count
	end

	self.btn = an.newBtn(res.gettex2(bg), handler(self, self.click), {
		pressImage = res.gettex2(bg2),
		sprite = res.gettex2(text),
		spriteOffset = text_offset
	}):anchor(0, 0):add2(self)
	self.data = data
	self.config = config

	self.size(self, self.btn:getContentSize()):anchor(0.5, 0.5):pos(data.x, data.y)
	self.upt(self)
end

function btnFixed:click()
	sound.playSound("103")

	if self.config.key == "btnExit" then
		self:exitGame()
	elseif self.config.key == "btnMap" then
		if main_scene.ui.panels.minimap then
			main_scene.ui:hidePanel("minimap")
		else
			main_scene.ui:showPanel("minimap")
		end
	elseif self.config.key == "btnMode" then
		if main_scene.ground:smr() then
			main_scene.ui:tip("乱斗模式无法更改模式")
		elseif def.role.mainsetting.banChgMode then
			main_scene.ui:tip("该地图不支持更改模式")
		else
			self.showModeSelect(self, not self.curModeChooseIsShow)
		end
	elseif self.config.key == "btnPet" then
		net.send({
			CM_SAY
		}, {
			"@b"
		})
		net.send({
			CM_SAY
		}, {
			"@rest"
		})
	elseif self.config.key == "btnDiy" then
		main_scene.ui:togglePanel("diy")
	end
end

function btnFixed:exitGame()
	if SupportOnlineVoice then
		yaya.logout()
	end

	local function callback()
		if g_data.player.mailSched then
			scheduler.unscheduleGlobal(g_data.player.mailSched)

			g_data.player.mailSched = nil
		end

		if def.role.timer then
			for key, timer in pairs(def.role.timer) do
				def.role.stopRepeater(timer)

				def.role.timer[key] = nil
			end
		end

		def.role.roleStatus.buffs = ""
		def.role.roleStatus.canRecover = false
		def.role.roleStatus.canLostHPCall = false
		def.role.currWeapon = {}
		g_data.guild.initialization = false
		g_data.player.isLogined = false
	end

	if self.config.key == "btnExit" then
		if g_data.setting.base.quickexit then
			callback()

			if main_scene.ui.console.controller.lock then
				main_scene.ui.console.controller.lock:onExit()
			end

			main_scene:smallExit()
		elseif def.offToSaftyOnline then
			an.newMsgbox("选择退出方式。\n可以「切换账号」或「退出游戏」", function(value)
				if value == 1 then
					callback()

					if main_scene.ui.console.controller.lock then
						main_scene.ui.console.controller.lock:onExit()
					end

					main_scene:smallExit()
				elseif value == 2 then
					net.send({
						1314
					})
					os.exit(1)
				end
			end, {
				disableScroll = true,
				btnTexts = {
					"切换账号",
					"退出游戏"
				}
			})
		else
			an.newMsgbox("是否退出游戏?", function(value)
				if value == 1 then
					callback()

					if main_scene.ui.console.controller.lock then
						main_scene.ui.console.controller.lock:onExit()
					end

					main_scene:smallExit()
				end
			end, {
				center = true,
				hasCancel = true
			})
		end
	end
end

function btnFixed:showModeSelect(b)
	if self.curModeChooseIsShow == b then
		return
	end

	self.curModeChooseIsShow = b

	local space = 40

	if not self.modeChooseNode then
		local texts = {
			{
				"quanti",
				"全体"
			},
			{
				"heping",
				"和平"
			},
			{
				"bianzu",
				"组队"
			},
			{
				"hanghui",
				"行会"
			},
			{
				"shane",
				"善恶"
			},
			{
				"shitu",
				"战队"
			}
		}

		self.modeChooseNode = res.get2("pic/console/modesBg.png"):anchor(1, 0):pos(self.data.x - self.getw(self) / 2 + 2, self.data.y - self.geth(self) / 2):add2(main_scene.ui.console, self.getLocalZOrder(self))

		for i, v in ipairs(texts) do
			local text = "pic/console/modes/" .. v[1] .. ".png"

			if i == 1 and main_scene.ground:smr() then
				local text2 = "pic/console/modes/luandou.png"
			end

			res.get2("pic/console/modes/" .. v[1] .. ".png"):pos((i - 1) * space + space / 2, self.modeChooseNode:geth() / 2):add2(self.modeChooseNode, 9):enableClick(function()
				if def.role.mainsetting.banChgMode then
					main_scene.ui:tip("该地图不支持更改模式")

					return
				end

				if main_scene.ground:smr() then
					net.send({
						CM_ATTACKMODE,
						tag = 0
					})
				else
					net.send({
						CM_ATTACKMODE,
						tag = i - 1
					})
					self:showModeSelect()
				end
			end, {
				size = cc.size(space, self.modeChooseNode:geth())
			})
		end
	end

	self.modeChooseNode:stopAllActions()
	self.stopAllActions(self)

	if b then
		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self) / 2 + 2 + self.modeChooseNode:getw() + 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self) / 2 + 2 + self.modeChooseNode:getw(), self.modeChooseNode:getPositionY()))
		})
		self.runs(self, {
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.modeChooseNode:getw() + 20, self.getPositionY(self))),
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.modeChooseNode:getw(), self.getPositionY(self)))
		})
	else
		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self) / 2 + 2 - 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self.getw(self) / 2 + 2, self.modeChooseNode:getPositionY()))
		})
		self.runs(self, {
			cc.MoveTo:create(0.1, cc.p(self.data.x - 20, self.getPositionY(self))),
			cc.MoveTo:create(0.1, cc.p(self.data.x, self.getPositionY(self)))
		})
	end
end

function btnFixed:mode2filename(mode)
	local names = {
		战队攻击模式 = "shitu",
		全体攻击模式 = "quanti",
		乱斗攻击模式 = "luandou",
		阵营对战模式 = "zhenying",
		和平攻击模式 = "heping",
		善恶攻击模式 = "shane",
		行会攻击模式 = "hanghui",
		组队攻击模式 = "bianzu"
	}
	local filename

	for k, v in pairs(names) do
		if string.find(mode, k) then
			filename = v

			break
		end
	end

	return filename or "heping"
end

function btnFixed:upt()
	if self.config.key == "btnMode" then
		self.btn.sprite:setTex(res.gettex2("pic/console/modes/" .. self.mode2filename(self, g_data.player.attackMode) .. ".png"))
	end
end

function btnFixed:update(dt)
	if self.config.key == "btnExit" then
		if main_scene.ui.panels.minimap then
			self.pos(self, self.data.x, self.data.y - 50)
		else
			self.pos(self, self.data.x, self.data.y)
		end
	elseif self.config.key == "btnMap" then
		if main_scene.ui.panels.minimap then
			self.pos(self, self.data.x - main_scene.ui.panels.minimap:getw(), self.data.y)
		else
			self.pos(self, self.data.x, self.data.y)
		end
	end
end

return btnFixed
