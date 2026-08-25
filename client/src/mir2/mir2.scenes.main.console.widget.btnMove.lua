local current = ...
local item = import("...common.item")
local iconFunc = import("..iconFunc")
local common = import("...common.common")
local btnMove = class("btnMove", function ()
	return display.newNode()
end)

table.merge(btnMove, {
	data,
	config,
	btn,
	donotMutilTouch,
	clickEffAni,
	loopEffAni,
	loopEffSpr,
	progressTimer,
	isHide,
	looks,
	skillData,
	makeIndex
})

function btnMove:onCleanup()
	if self.clickEffAni then
		self.clickEffAni:release()

		self.clickEffAni = nil
	end

	if self["remove_" .. self.data.key] then
		self["remove_" .. self.data.key](self)
	end

	if self["remove_btntype_" .. self.config.btntype] then
		self["remove_btntype_" .. self.config.btntype](self)
	end
end

function btnMove:ctor(config, data)
	if config.btntype == "normal" and config.key == "btnVoice" then
		self.donotMutilTouch = true
		self.btn = import("...common.voiceBtn", current).new(res.gettex2("pic/console/btn_voice.png"), res.gettex2("pic/console/btn_voice.png"), cc.size(53, 53)):anchor(0, 0):add2(self)
	elseif config.btntype == "normal" and config.key == "btnVoiceJIT" then
		self.donotMutilTouch = true
		self.btn = import(".voiceBtnJIT", current).new():anchor(0, 0):add2(self)
	else
		local files = iconFunc:getFilenames(config, data, true)

		if files.select then
			files.select = {
				res.gettex2(files.select),
				manual = true
			}
		end

		if config.btntype == "prop" or config.btntype == "custom" then
			files.sprite = nil
		end

		local filter = nil

		if config.btntype == "skill" then
			self.skillData = g_data.player:getMagic(tonumber(data.magicId))

			if not self.skillData then
				filter = res.getFilter("gray")
			end
		end

		self.btn = an.newBtn(res.gettex2(files.bg), function ()
			if config.btntype == "skill" or config.btntype == "base" then
				self:playClickEffect()
			end

			main_scene.ui.console.btnCallbacks:handle(config.btntype, self)
		end, {
			pressBig = true,
			externTouch = true,
			sprite = files.sprite and res.gettex2(files.sprite),
			select = files.select,
			filter = filter,
			filterOpen = filter ~= nil
		}):anchor(0, 0):add2(self)

		if files.text then
			res.get2(files.text):pos(self.btn:getw() / 2, 10):add2(self.btn, 1)
		end

		if config.btntype == "custom" then
			self.btn:setTouchEnabled(true)
		end
	end

	self.data = data
	self.config = config

	self:size(self.btn:getContentSize()):anchor(0.5, 0.5):pos(data.x or 0, data.y or 0)
	self:scale(config.btntype == "panel" and 0.8533333333333334 or 1)
	self:setNodeEventEnabled(true)

	if self["init_" .. data.key] then
		self["init_" .. data.key](self)
	end

	if self["init_btntype_" .. config.btntype] then
		self["init_btntype_" .. config.btntype](self)
	end
end

function btnMove:onEnter(args)
	if self.config.btntype == "custom" then
		table.insert(main_scene.ui.customs, self)
	end
end

function btnMove:getClickRect()
	if self.data.btnpos then
		local add = 0

		if string.split(self.data.btnpos, "-")[2] == "1" then
			add = main_scene.ui.console.btnAreaBegin
		end

		local s = main_scene.ui.console.btnAreaSpace

		return cc.rect(self:getPositionX() - s / 2, self:getPositionY() - s / 2, s + add, s)
	else
		return self:getCascadeBoundingBox()
	end
end

function btnMove:playClickEffect()
	if not self.clickEffAni then
		self.clickEffAni = res.getani2("pic/effect/btnclick/%d.png", 1, 5, 0.06)

		self.clickEffAni:retain()
	end

	local spr = nil
	spr = res.get2("pic/effect/btnclick/1.png"):pos(self:centerPos()):add2(self):scale(0.55):runs({
		cc.Animate:create(self.clickEffAni),
		cc.CallFunc:create(function ()
			spr:removeSelf()

			spr = nil
		end)
	})
end

function btnMove:playLoopEffect()
	if not self.loopEffAni then
		self.loopEffAni = res.getani2("pic/effect/btnselect/%d.png", 1, 15, 0.06)

		self.loopEffAni:retain()
	end

	if not self.loopEffSpr then
		self.loopEffSpr = res.get2("pic/effect/btnselect/1.png"):pos(self:centerPos()):add2(self):runForever(cc.Animate:create(self.loopEffAni))
	end
end

function btnMove:stopLoopEffect()
	if self.loopEffSpr then
		self.loopEffSpr:removeSelf()

		self.loopEffSpr = nil
	end
end

function btnMove:setProgress(p, filename)
	if not self.progressTimer then
		local spr = display.newSprite(res.gettex2(filename or "pic/console/radial.png"))
		self.progressTimer = display.newProgressTimer(spr, display.PROGRESS_TIMER_RADIAL):pos(self:centerPos()):add2(self)
	end

	self.progressTimer:setPercentage(p)
end

function btnMove:select()
	self.btn:select()
end

function btnMove:unselect()
	self.btn:unselect()
end

function btnMove:init_btnFullname()
	if g_data.setting.base.heroShowName then
		self.btn:select()
	end
end

function btnMove:init_btnOnlyname()
	if g_data.setting.base.showNameOnly then
		self.btn:select()
	end
end

function btnMove:init_btnSoundEnable()
	if g_data.setting.base.soundEnable then
		self.btn:select()
	end
end

function btnMove:init_btnTouchRun()
	if g_data.setting.base.touchRun then
		self.btn:select()
	end
end

function btnMove:init_btnAutoSpace()
	if g_data.setting.job.autoSpace then
		self.btn:select()
	end
end

function btnMove:init_btnAutoWide()
	if g_data.setting.job.autoWide then
		self.btn:select()
	end
end

function btnMove:init_btnAutoFire()
	if g_data.setting.job.autoFire then
		self.btn:select()
	end
end

function btnMove:init_btnAutoDun()
	if g_data.setting.job.autoDun then
		self.btn:select()
	end
end

function btnMove:init_btnAutoInvisible()
	if g_data.setting.job.autoInvisible then
		self.btn:select()
	end
end

function btnMove:init_btnAutoSkill()
	if g_data.setting.job.autoSkill.enable then
		self.btn:select()
	end
end

function btnMove:init_btntype_prop()
	g_data.bag:bindQuickItem(self.config.btnid, self.config.use, function (makeIndex)
		self.makeIndex = makeIndex

		self:prop_upt()
	end)
	self:prop_fill_test()
end

function btnMove:remove_btntype_prop(btnid)
	if self.makeIndex then
		local _, data = g_data.bag:getItem(self.makeIndex)

		if data then
			g_data.bag:addItem(data)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(self.makeIndex)
			end
		end
	end

	if not btnid then
		g_data.bag:unbindQuickItem(self.config.btnid)
	else
		g_data.bag:fillQuickItemTest(btnid)
	end
end

function btnMove:prop_fill_test()
	if self.makeIndex then
		return
	end

	g_data.bag:fillQuickItemTest(self.config.btnid)
end

function btnMove:prop_upt()
	if not self.btn.sprite then
		self.btn.sprite = display.newSprite("public/empty.png"):pos(self.btn:centerPos()):add2(self.btn)
	end

	local btnid, data = nil

	if self.makeIndex then
		btnid, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self.btn.sprite:setTex(res.gettex("items", data.getVar("looks"))):scale(1.2)
	else
		self.btn.sprite:setTex("public/empty.png")
	end
end

function btnMove:skill_upt(data)
	if data then
		self.skillData = data

		self.btn:closeFilter()
	end
end

function btnMove:init_btnHeroSkill()
	self:hero_upt_union()
end

function btnMove:hero_upt_union()
	if g_data.hero.unionState > 0 then
		self:playLoopEffect()
	else
		self:stopLoopEffect()
	end

	local value = 200 - g_data.hero.unionProgress
	local p = math.min(100, math.max(0, value / 2))

	self:setProgress(p, "pic/console/heroUnion.png")
end

function btnMove:voice_call(m, ...)
	self.btn[m](self.btn, ...)
end

function btnMove:checkInButton(pos)
	local p = self:convertToWorldSpace(cc.p(0, 0))
	local rect = cc.rect(0, 0, self.btn:getContentSize().width, self.btn:getContentSize().height)

	if cc.rectContainsPoint(cc.rect(p.x + rect.x * self.btn:getScale(), p.y + rect.y * self.btn:getScale(), rect.width * self.btn:getScale(), rect.height * self.btn:getScale()), pos) then
		return true
	end
end

function btnMove:checkItemType(item)
	local _, data = g_data.bag:getItem(item:get("makeIndex"))
	local where = getTakeOnPosition(item.getVar("stdMode"))
	local stdMode = item.getVar("stdMode")
	local canCustoms = {
		0,
		1,
		2,
		3
	}

	if not where then
		for _, mode in ipairs(canCustoms) do
			if tonumber(stdMode) == mode then
				return true
			end
		end
	end

	return false
end

function btnMove:init_btntype_custom()
	local custom = g_data.bag:getCustom(self.config.id)

	if custom then
		self.source = custom.source

		g_data.bag:bindCustomsItem(self.config.btnid, {
			custom.name
		}, custom.makeIndex, function (makeIndex)
			self.makeIndex = makeIndex

			self:custom_upt()
		end)
	end
end

function btnMove:custom_fill_test()
	if self.makeIndex then
		return
	end

	g_data.bag:fillQuickItemTest(self.config.btnid)
end

function btnMove:setCustomProps(item, source)
	g_data.bag:unbindQuickItem(self.config.btnid)

	self.makeIndex = nil
	self.source = source

	g_data.bag:bindCustomsItem(self.config.btnid, {
		item.getVar("name")
	}, item:get("makeIndex"), function (makeIndex)
		self.makeIndex = makeIndex

		self:custom_upt()
	end)
	g_data.bag:addCustoms(self.config.id, item:get("makeIndex"), item.getVar("name"), source)
	cache.saveCustoms(common.getPlayerName())
end

function btnMove:custom_addItem(makeIndex)
	if self.btn.item then
		self.btn.item:removeSelf()

		self.btn.item = nil
	end

	local i, v = g_data.bag:getItem(makeIndex)
	local center_x, center_y = self.btn:centerPos()
	self.btn.item = item.new(v, self):pos(self:getPositionX(), self:getPositionY()):addto(main_scene.ui)

	self.btn.item:setLocalZOrder(main_scene.ui.z.focus)
	self.btn.item:setName("custom_" .. v.getVar("name"))

	self.btn.item.owner = self.source
	self.btn.item.customNode = self
end

function btnMove:custom_delItem()
	if self.makeIndex then
		g_data.bag:unbindQuickItem(self.config.btnid)

		self.makeIndex = nil

		g_data.bag:delCustoms(self.config.id)
		cache.saveCustoms(common.getPlayerName())
	end

	if self.btn.item then
		self.btn.item:removeSelf()

		self.btn.item = nil
	end
end

function btnMove:custom_upt()
	local btnid, data = nil

	if self.makeIndex then
		btnid, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self:custom_addItem(self.makeIndex)
	else
		self:custom_delItem()
	end
end

return btnMove
