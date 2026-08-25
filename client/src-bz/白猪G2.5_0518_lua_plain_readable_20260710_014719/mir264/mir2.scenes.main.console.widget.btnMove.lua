local current = ...
local item = import("...common.item")
local iconFunc = import("..iconFunc")
local common = import("...common.common")
local btnMove = class("btnMove", function()
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

function btnMove:customSkicon(number2)
	local number = def.magic.getMagicConfigByUid(tonumber(number2.magicId), main_scene.ground.player) or nil

	if number and number.picId then
		return "pic/console/skill-icons/" .. number.picId .. ".png"
	elseif number and number.name and string.find(number.name, "|") ~= nil then
		return "pic/console/skill-icons/" .. number2.magicId .. "-" .. g_data.player.job .. ".png"
	end

	return nil
end

function btnMove:isCusSkill(skillData)
	local number = def.magic.getMagicConfigByUid(tonumber(skillData.magicId), main_scene.ground.player) or nil

	if number then
		return number.picId or number.name and string.find(number.name, "|") ~= nil
	end

	return false
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

		local filter
		local value = config.btntype == "skill" and self:isCusSkill(data)

		if config.btntype == "skill" then
			self.skillData = g_data.player:getMagic(tonumber(data.magicId))

			if not self.skillData then
				filter = res.getFilter("gray")
			end

			if value then
				def.role.autoRun(function()
					if main_scene and main_scene.ui and self.customSkicon then
						local value = self:customSkicon(data)

						if value then
							self.btn.sprite:setTex(res.gettex2(value))
						else
							local filenames = iconFunc:getFilenames(config, data, true)

							self.btn.sprite:setTex(res.gettex2(filenames.sprite))
						end
					end
				end, 0.5)
			end
		end

		local sprite = files.sprite and res.gettex2(files.sprite)

		if config.btntype == "skill" and value then
			sprite = res.gettex2("public/empty.png")
		end

		self.btn = an.newBtn(res.gettex2(files.bg), function()
			if config.btntype == "skill" or config.btntype == "base" then
				self:playClickEffect()
			end

			main_scene.ui.console.btnCallbacks:handle(config.btntype, self)
		end, {
			pressBig = true,
			sprite = sprite,
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

		if config.showSpr then
			config.showSpr(self)
		end
	end

	self.propSets = {
		offsetY = 40,
		tagFontSize = 16,
		offsetX = -10,
		tagColor = display.COLOR_GREEN
	}

	if def.btnTags and def.btnTags.propSets then
		self.propSets = def.btnTags.propSets
	end

	self.data = data
	self.config = config

	self:size(self.btn:getContentSize()):anchor(0.5, 0.5):pos(data.x or 0, data.y or 0)
	self:scale(config.btntype == "panel" and 0.8533333333333334 or 1)
	self:setNodeEventEnabled(true)

	if def.showItemNums and def.btnTags and def.btnTags[self.config.key] then
		local value2 = def.btnTags[self.config.key]
		local itemCount = g_data.bag:getItemCount(value2.tagItem) + g_data.bag:getBindCount(value2.tagItem)

		self.lbItemNum = an.newLabel(itemCount, value2.tagFontSize or 16, 1, {
			color = value2.tagColor or display.COLOR_GREEN,
			sc = display.COLOR_BLACK
		}):anchor(1, 0):pos(self:getw() + value2.offsetX or 0, value2.offsetY or 0):addTo(self, 1)
	end

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

	local spr

	spr = res.get2("pic/effect/btnclick/1.png"):pos(self:centerPos()):add2(self):scale(0.55):runs({
		cc.Animate:create(self.clickEffAni),
		cc.CallFunc:create(function()
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
	if self.data.magicId == def.SBSkill and g_data.player.job == 0 then
		g_data.player.hitEnables.tenKill = true
	end

	self.btn:select()
end

function btnMove:unselect()
	if self.data.magicId == def.SBSkill and g_data.player.job == 0 and g_data.player.hitEnables.tenKill then
		g_data.player.hitEnables.tenKill = false
	end

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
	g_data.bag:bindQuickItem(self.config.btnid, self.config.use, function(makeIndex)
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

function btnMove:createItemNumsTex()
	if def.showItemNums and not self.lbItemNum then
		self.lbItemNum = an.newLabel("", self.propSets.tagFontSize or 16, 1, {
			color = self.propSets.tagColor or display.COLOR_GREEN,
			sc = display.COLOR_BLACK
		}):anchor(1, 0):pos(self:getw() + self.propSets.offsetX or -10, self.propSets.offsetY or 40):addTo(self, 1)
	end
end

function btnMove:getDuraBase(value, value2, value3)
	if value == 1 then
		if checkExist(value2, 1, 2, 5, 6, 7) then
			return nil
		elseif checkExist(value2, 3, 4, 8, 9, 10) then
			return nil
		elseif value2 == 30 then
			return 10
		elseif value2 == 34 then
			return 1
		elseif value2 == 35 then
			return 1
		end
	elseif value == 2 then
		if value2 == 9 then
			return 100
		else
			return nil
		end
	elseif value == 25 then
		if value2 == 9 then
			return 1
		elseif value2 == 10 or value2 == 11 then
			return 100
		elseif value2 == 8 then
			if value3 == "祝福罐" or value3 == "魔令包" then
				return 100
			else
				return 10
			end
		else
			return 100
		end
	end

	return nil
end

function btnMove:duraCount(value, value2)
	local function callback(self)
		local value, value2 = math.modf(self)

		return value2 >= 0.5 and value + 1 or value
	end

	value = value or 1000

	return callback(Word(value2) / value)
end

function btnMove:itemUptNums()
	if not def.showItemNums then
		return
	end

	if self.btn.empty and self.lbItemNum then
		self.lbItemNum:setString("")

		return
	end

	local value
	local data

	if self.makeIndex then
		local btnid

		btnid, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self:createItemNumsTex()

		local var = data.getVar("name")
		local value2 = data:get("dura")
		local var2 = data.getVar("stdMode")
		local var3 = data.getVar("shape")
		local itemCount = g_data.bag:getItemCount(var) + g_data.bag:getBindCount(var)

		if Word(data:get("duraMax")) > 1000 then
			itemCount = self:duraCount(self:getDuraBase(var2, var3, var), value2)
		end

		self.lbItemNum:setString(itemCount)
	elseif self.lbItemNum then
		self.lbItemNum:setString("")
	end
end

function btnMove:prop_upt()
	if not self.btn.sprite then
		self.btn.sprite = display.newSprite("public/empty.png"):pos(self.btn:centerPos()):add2(self.btn)
		self.btn.empty = true
	end

	local value
	local data

	if self.makeIndex then
		local item2

		item2, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self.btn.empty = false

		self.btn.sprite:setTex(res.gettex("items", data.getVar("looks"))):scale(1.2)
	else
		self.btn.empty = true

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

function btnMove:checkItemType(item2)
	local _2, data = g_data.bag:getItem(item2:get("makeIndex"))
	local where = getTakeOnPosition(item2.getVar("stdMode"))
	local stdMode = item2.getVar("stdMode")
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
		}, custom.makeIndex, function(makeIndex)
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

function btnMove:setCustomProps(item2, source)
	g_data.bag:unbindQuickItem(self.config.btnid)

	self.makeIndex = nil
	self.source = source

	g_data.bag:bindCustomsItem(self.config.btnid, {
		item2.getVar("name")
	}, item2:get("makeIndex"), function(makeIndex)
		self.makeIndex = makeIndex

		self:custom_upt()
	end)
	g_data.bag:addCustoms(self.config.id, item2:get("makeIndex"), item2.getVar("name"), source)
	cache.saveCustoms(common.getPlayerName())
end

function btnMove:custom_addItem(makeIndex)
	if self.btn.item then
		self.btn.item:removeSelf()

		self.btn.item = nil
	end

	local i, v = g_data.bag:getItem(makeIndex)
	local center_x, center_y = self.btn:centerPos()

	self.btn.item = item.new(v, self, {
		showbg = false,
		showEffect = true
	}):pos(self:getPositionX(), self:getPositionY()):addto(main_scene.ui)

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
	local value
	local data

	if self.makeIndex then
		local btnid

		btnid, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self.btn.empty = false

		self:custom_addItem(self.makeIndex)
	else
		self.btn.empty = true

		self:custom_delItem()
	end
end

return btnMove
