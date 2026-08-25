local iconFunc = import(".iconFunc")
local widgetDef = import(".widget._def")
local common = import("..common.common")
local skills = class("skills")

table.merge(skills, {
	console,
	max = 20
})

function skills:ctor(console)
	self.console = console
end

function skills:upt()
	local function get(magicId)
		for i, v in ipairs(g_data.player.magicList) do
			if v:get("magicId") == tonumber(magicId) then
				return v
			end
		end
	end

	for k, v in pairs(self.console.widgets) do
		if v.__cname == "btnMove" and v.config.btntype == "skill" then
			v:skill_upt(get(v.data.magicId))
		end
	end
end

function skills:select(magicId)
	for k, v in pairs(self.console.widgets) do
		if v.__cname == "btnMove" and v.config.btntype == "skill" then
			if magicId and v.data.magicId == tonumber(magicId) then
				if magicId == def.SBSkill and g_data.player.job == 0 then
					g_data.player.hitEnables.tenKill = true
				end

				v:select()
			else
				if magicId == def.SBSkill and g_data.player.job == 0 and g_data.player.hitEnables.tenKill then
					g_data.player.hitEnables.tenKill = false
				end

				v:unselect()
			end
		end
	end
end

function skills:defLayout()
	for i, v in ipairs(g_data.player.magicList) do
		self:layout(v:get("magicId"), true)
	end
end

function skills:layout(magicId, hasLearn)
	local config = def.magic.getMagicConfigByUid(magicId, main_scene.ground.player)

	if not config or not config.btnpos then
		return
	end

	local exist = self.console:findWidgetWithBtnpos(config.btnpos)
	local cover = false

	if def.openArangeSkills then
		local magicpos = self:getMagicpos(magicId) or nil

		for _, v in pairs(self.console.widgets) do
			if v.__cname == "btnMove" and v.config.btntype == "skill" and v.data.btnpos == config.btnpos then
				local magicConfigByUid = def.magic.getMagicConfigByUid(v.data.magicId, main_scene.ground.player)

				if magicpos and config.btnpos == magicConfigByUid.btnpos and magicConfigByUid.priority < config.priority then
					self.console:removeWidget(v.data.key)

					cover = true

					break
				end
			end
		end

		if magicpos and (not exist or exist and cover) and not WIN32_OPERATE then
			local parts = string.split(config.btnpos, "-")
			local items = {
				key2 = "btnSkillTemp",
				btnpos = magicpos .. "-0",
				key = "skill" .. config.uid,
				magicId = config.uid,
				priority = config.priority
			}

			self.console:addWidget(items)
			self.console:saveEdit()

			if cover and not cache.getDiy(common.getPlayerName(), "diy_skill") then
				local value = main_scene.ground.helper.runner.guide:showTipText("diy_skill" .. config.uid, {
					"同类型更强技能自动覆盖",
					22,
					1,
					align = "right"
				}, cc.p(-30, 0))
				local node = display.newNode():size(display.width, display.height):addTo(display.getRunningScene())

				node:setTouchEnabled(true)
				node:setTouchSwallowEnabled(false)
				node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(nameOwner)
					if nameOwner.name == "ended" then
						value:removeSelf()
						node:removeSelf()
					end

					return true
				end)
				cache.saveDiy(common.getPlayerName(), "diy_skill", {
					diy_skill = true
				})
			end
		elseif not hasLearn then
			main_scene.ui:tip("新技能学习成功")
		end
	else
		for _2, v2 in pairs(self.console.widgets) do
			if v2.__cname == "btnMove" and v2.config.btntype == "skill" and v2.data.btnpos == config.btnpos then
				local magicdata = def.magic.getMagicConfigByUid(v2.data.magicId, main_scene.ground.player)

				if config.btnpos == magicdata.btnpos and magicdata.priority < config.priority then
					self.console:removeWidget(v2.data.key)

					cover = true

					break
				end
			end
		end

		if (not exist or exist and cover) and not WIN32_OPERATE then
			local data = {
				key2 = "btnSkillTemp",
				btnpos = config.btnpos,
				key = "skill" .. config.uid,
				magicId = config.uid,
				priority = config.priority
			}

			self.console:addWidget(data)
			self.console:saveEdit()

			if cover and not cache.getDiy(common.getPlayerName(), "diy_skill") then
				local node2 = main_scene.ground.helper.runner.guide:showTipText("diy_skill" .. config.uid, {
					"同类型更强技能自动覆盖",
					22,
					1,
					align = "right"
				}, cc.p(-30, 0))
				local layer = display.newNode():size(display.width, display.height):addTo(display.getRunningScene())

				layer:setTouchEnabled(true)
				layer:setTouchSwallowEnabled(false)
				layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
					if event.name == "ended" then
						node2:removeSelf()
						layer:removeSelf()
					end

					return true
				end)
				cache.saveDiy(common.getPlayerName(), "diy_skill", {
					diy_skill = true
				})
			end
		elseif not hasLearn then
			main_scene.ui:tip("新技能学习成功")
		end
	end
end

function skills:getMagicpos(number)
	local json = main_scene.ui.console:getjson()

	if json then
		for _, skillpo in ipairs(json.skillpos) do
			if skillpo.uid == tonumber(number) then
				return skillpo.idx
			end
		end
	end
end

return skills
