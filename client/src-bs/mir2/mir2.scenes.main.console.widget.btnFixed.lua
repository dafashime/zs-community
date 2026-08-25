local btnFixed = class("btnFixed", function ()
	return display.newNode()
end)

table.merge(btnFixed, {
	data,
	config,
	modeChooseNode,
	curModeChooseIsShow
})

function btnFixed:ctor(config, data)
	local bg = "pic/console/fixedBtn/btnbg10.png"
	local bg2 = "pic/console/fixedBtn/btnbg11.png"
	local text, text_offset = nil

	if config.key == "btnMap" then
		text = "pic/console/fixedBtn/text_map.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnExit" then
		text = "pic/console/fixedBtn/text_exit.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnMode" then
		text = "pic/console/modes/quanti.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnPet" then
		text = "pic/console/fixedBtn/text_pet.png"
		text_offset = cc.p(-3, 0)
	elseif config.key == "btnDiy" then
		text = "pic/console/fixedBtn/text_diy.png"
		text_offset = cc.p(-3, 0)
	end

	self.btn = an.newBtn(res.gettex2(bg), handler(self, self.click), {
		pressImage = res.gettex2(bg2),
		sprite = res.gettex2(text),
		spriteOffset = text_offset
	}):anchor(0, 0):add2(self)
	self.data = data
	self.config = config

	self:size(self.btn:getContentSize()):anchor(0.5, 0.5):pos(data.x, data.y)
	self:upt()
end

function btnFixed:click()
	sound.playSound("103")

	if self.config.key == "btnExit" then
		if g_data.setting.base.quickexit then
			main_scene:smallExit()
		else
			an.newMsgbox("是否确定退出?", function (isOk)
				if isOk == 1 then
					main_scene:smallExit()
				end
			end, {
				center = true,
				hasCancel = true
			})
		end
	elseif self.config.key == "btnMap" then
		if main_scene.ui.panels.minimap then
			main_scene.ui:hidePanel("minimap")
		else
			main_scene.ui:showPanel("minimap")
		end
	elseif self.config.key == "btnMode" then
		self:showModeSelect(not self.curModeChooseIsShow)
	elseif self.config.key == "btnPet" then
		net.send({
			CM_SAY
		}, {
			"@rest"
		})
	elseif self.config.key == "btnDiy" then
		main_scene.ui:togglePanel("diy")
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
				"编组"
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
		self.modeChooseNode = res.get2("pic/console/modesBg.png"):anchor(1, 0):pos(self.data.x - self:getw() / 2 + 2, self.data.y - self:geth() / 2):add2(main_scene.ui.console, self:getLocalZOrder())

		for i, v in ipairs(texts) do
			res.get2("pic/console/modes/" .. v[1] .. ".png"):pos((i - 1) * space + space / 2, self.modeChooseNode:geth() / 2):add2(self.modeChooseNode, 9):enableClick(function ()
				net.send({
					CM_ATTACKMODE,
					tag = i - 1
				})
				self:showModeSelect()
			end, {
				size = cc.size(space, self.modeChooseNode:geth())
			})
		end
	end

	self.modeChooseNode:stopAllActions()
	self:stopAllActions()

	if b then
		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - self:getw() / 2 + 2 + self.modeChooseNode:getw() + 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self:getw() / 2 + 2 + self.modeChooseNode:getw(), self.modeChooseNode:getPositionY()))
		})
		self:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.modeChooseNode:getw() + 20, self:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x + self.modeChooseNode:getw(), self:getPositionY()))
		})
	else
		self.modeChooseNode:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - self:getw() / 2 + 2 - 20, self.modeChooseNode:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x - self:getw() / 2 + 2, self.modeChooseNode:getPositionY()))
		})
		self:runs({
			cc.MoveTo:create(0.1, cc.p(self.data.x - 20, self:getPositionY())),
			cc.MoveTo:create(0.1, cc.p(self.data.x, self:getPositionY()))
		})
	end
end

function btnFixed:mode2filename(mode)
	local names = {
		["全体"] = "quanti",
		["行会"] = "hanghui",
		["和平"] = "heping",
		["编组"] = "bianzu",
		["战队"] = "shitu",
		["敌对"] = "shane"
	}
	local filename = nil

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
		self.btn.sprite:setTex(res.gettex2("pic/console/modes/" .. self:mode2filename(g_data.player.attackMode) .. ".png"))
	end
end

function btnFixed:update(dt)
	if self.config.key == "btnExit" then
		if main_scene.ui.panels.minimap then
			self:pos(self.data.x, self.data.y - 50)
		else
			self:pos(self.data.x, self.data.y)
		end
	elseif self.config.key == "btnMap" then
		if main_scene.ui.panels.minimap then
			self:pos(self.data.x - main_scene.ui.panels.minimap:getw(), self.data.y)
		else
			self:pos(self.data.x, self.data.y)
		end
	end
end

return btnFixed
