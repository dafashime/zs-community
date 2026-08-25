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
				v:select()
			else
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
	local config = def.magic.getMagicConfigByUid(magicId)

	if not config or not config.btnpos then
		return
	end

	local exist = self.console:findWidgetWithBtnpos(config.btnpos)
	local cover = false

	for _, v in pairs(self.console.widgets) do
		if v.__cname == "btnMove" and v.config.btntype == "skill" and v.data.btnpos == config.btnpos then
			local magicdata = def.magic.getMagicConfigByUid(v.data.magicId)

			if config.btnpos == magicdata.btnpos and magicdata.priority < config.priority then
				self.console:removeWidget(v.data.key)

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
			local node = main_scene.ground.helper.runner.guide:showTipText("diy_skill" .. config.uid, {
				"同类型更强技能自动覆盖",
				22,
				1,
				align = "right"
			}, cc.p(-30, 0))
			local layer = display.newNode():size(display.width, display.height):addTo(display.getRunningScene())

			layer:setTouchEnabled(true)
			layer:setTouchSwallowEnabled(false)
			layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "ended" then
					node:removeSelf()
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

return skills
