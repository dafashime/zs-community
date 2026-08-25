local cx = 62
local cy = 45
local labelx = 23
local labely = 96
local lock = class("widget.lock", function ()
	return display.newNode()
end)

table.merge(lock, {
	roleNameLabel,
	isSelect,
	target,
	skill
})

function lock:ctor(config, data)
	self.bgSpr = res.get2("pic/console/lock_bg.png"):pos(cx, cy):add2(self)

	self.bgSpr:anchor(cx / self.bgSpr:getw(), cy / self.bgSpr:geth()):enableClick(function ()
		local b = self:isEnable()

		if b then
			self:stop()
		else
			self:startSelect()
		end
	end)
	self:anchor(0.5, 0.5):pos(data.x, data.y):size(self.bgSpr:getContentSize())

	self.lockSpr = res.get2("pic/console/lock.png"):pos(cx + 1, cy + 1):add2(self)
	self.lockSkillText = res.get2("pic/console/lock-single.png"):pos(cx, cy - 20):add2(self):hide()
	self.roleNameLabel = an.newLabel("", 18, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(labelx, labely):add2(self)

	display.newNode():anchor(0, 0.5):pos(self.roleNameLabel:getPosition()):size(self.bgSpr:getw(), 42):add2(self):enableClick(function ()
		if not self.roleNameLabel.roleid then
			return
		end

		local role = main_scene.ground.map:findRole(self.roleNameLabel.roleid)

		if not role then
			return
		end

		if role.__cname ~= "hero" then
			return
		end

		self.roleNameLabel:stopAllActions()
		self.roleNameLabel:runs({
			cc.ScaleTo:create(0.1, 1.5),
			cc.ScaleTo:create(0.1, 1)
		})

		if g_data.client:checkLastTime("queryOther", 1) then
			g_data.client:setLastTime("queryOther", true)
			net.send({
				CM_QUERYUSERSTATE,
				recog = role.roleid,
				param = role.x,
				tag = role.y
			})
			net.send({
				CM_QUERY_TITLE,
				0,
				recog = role.roleid,
				param = role.x,
				tag = role.y
			})
		else
			main_scene.ui:tip("你查看太快了!!!")
		end
	end)

	self.exLabels = {}
	self.target = {}
	self.skill = {}
end

function lock:stop()
	self.skill = {}
	self.target = {}
	self.isSelect = nil

	self:setActionType()
	self:setRoleName()
	main_scene.ui.console.skills:select()
	self:uptEnable()
end

function lock:startSelect()
	self.isSelect = true

	self:setActionType("lock")
	self:setRoleName("<请选择锁定目标>")
	self:uptEnable()
end

function lock:cancelSelect()
	self.target.select = nil
	self.isSelect = nil
end

function lock:setSelectTarget(role)
	if self.target.select == role.roleid then
		main_scene.ui:tip("目标已锁定，请选择攻击方式")
	else
		if not self.isSelect then
			self:startSelect()
		end

		self.target.select = role.roleid

		self:setRoleName(self:getRoleName(role), role.roleid)
	end

	if main_scene.ui.console.controller.quickGroup and role.__cname == "hero" then
		g_data.client:setLastTime("group", true)
		net.send({
			#g_data.player.groupMembers == 0 and CM_CREATEGROUP or CM_ADDGROUPMEMBER
		}, {
			role.info:getName()
		})
	end
end

function lock:setAttackTarget(role)
	self.target.attack = role and role.roleid

	if self.target.attack then
		self:setActionType("attack")
		self:setRoleName(self:getRoleName(role), role.roleid)

		if role:getRace() == 0 and g_data.player:getHasGuild() and g_data.setting.base.guild and g_data.client:checkLastTime("guild", 10) then
			g_data.client:setLastTime("guild", true)

			local player = main_scene.ground.player
			local str = "!~我正在[" .. g_data.map.mapTitle .. "]坐标:[" .. player.x .. "," .. player.y .. "]与[" .. self:getRoleName(role) .. "]进行战斗"

			net.send({
				CM_SAY
			}, {
				str
			})
		end
	elseif not self.skill.enable and not self.isSelect then
		self:setActionType()
		self:setRoleName()
	end

	self:uptEnable()
end

function lock:setSkillTarget(role)
	self.target.skill = role.roleid

	self:setRoleName(self:getRoleName(role), role.roleid)
end

function lock:useSkill(data, config)
	self.skill.enable = true
	self.skill.data = data
	self.skill.config = config
	local skillID = data:get("magicId")
	local skilltype = checkExist("area", config.type) and "mutil" or "single"

	self:setActionType("skill", skillID, skilltype)

	self.target.skill = self.target.skill or self.target.select or self.target.attack

	if self.target.skill then
		local role = main_scene.ground.map:findRole(self.target.skill)

		if role then
			self:setRoleName(self:getRoleName(role), role.roleid)
		else
			self:setRoleName("<目标失去>")
		end
	else
		self:setRoleName("<请选择技能目标>")
	end

	self:uptEnable()
end

function lock:skillTargetDie()
	self.target.skill = nil

	self:setRoleName("<请选择技能目标>")
end

function lock:isEnable()
	return self.target.attack or self.skill.enable or self.isSelect
end

function lock:uptEnable()
	local b = self:isEnable()

	self.bgSpr:stopAllActions()

	if b then
		self.bgSpr:rotateTo(0.15, 90)
	else
		self.bgSpr:rotateTo(0.15, 0)
	end
end

function lock:setActionType(type, skillid, skilltype)
	if not type then
		self.lockSkillText:hide()
		self.lockSpr:setTex(res.gettex2("pic/console/lock.png"))
	elseif type == "attack" then
		self.lockSkillText:hide()
		self.lockSpr:setTex(res.gettex2("pic/console/skill_base-icons/attack.png"))
	elseif type == "lock" then
		self.lockSkillText:hide()
		self.lockSpr:setTex(res.gettex2("pic/console/skill_base-icons/lock.png"))
	elseif type == "skill" then
		self.lockSkillText:show()
		self.lockSkillText:setTex(res.gettex2("pic/console/lock-" .. skilltype .. ".png"))
		self.lockSpr:setTex(res.gettex2("pic/console/skill-icons/" .. skillid .. ".png"))
	end
end

function lock:setRoleName(t, roleid)
	self.roleNameLabel.roleid = roleid

	self:setLabelText(self.roleNameLabel, t or "")
end

function lock:getRoleName(role)
	if role.info:getName() then
		return role.info:getName()
	elseif role.__cname == "hero" then
		return "[人物]"
	else
		return "[怪物]"
	end
end

function lock:setLabelText(label, text)
	label:setString(text)

	if label:getw() < 80 then
		label:pos(labelx + (80 - label:getw()) / 2, label:getPositionY())
	else
		label:pos(labelx, label:getPositionY())
	end
end

return lock
