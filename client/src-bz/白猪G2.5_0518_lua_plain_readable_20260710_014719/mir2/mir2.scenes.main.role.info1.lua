local mapDef = import("..map.def")
local common = import("..common.common")
local info = class("role.info")

table.merge(info, {
	map,
	role,
	x,
	y,
	hp,
	name,
	sayLabel,
	buf,
	isShow,
	dirty,
	forceShowName
})

function info:ctor(role, map)
	self.map = map
	self.role = role
	self.name = {
		color = role.__cname == "npc" and 250,
		texts = {},
		labels = {}
	}
	self.hp = {}
	self.buf = {}

	self:showName(true)

	self.x, self.y = role.x, role.y
	self.dirty = true
end

function info:remove()
	if self.hp.spr then
		self.hp.spr:removeSelf()
	end

	if self.hp.sprBg then
		self.hp.sprBg:removeSelf()
	end

	if self.hp.label then
		self.hp.label:removeSelf()
	end

	if self.name.node then
		self.name.node:removeSelf()
	end
end

function info:show()
	if self.isShow then
		return
	end

	if self.hp.spr then
		self.hp.spr:show()
	end

	if self.hp.sprBg then
		self.hp.sprBg:show()
	end

	if self.hp.label then
		self.hp.label:show()
	end

	self:showName(true)

	self.isShow = true
	self.dirty = true

	return self
end

function info:hide()
	if not self.isShow then
		return
	end

	if self.hp.spr then
		self.hp.spr:hide()
	end

	if self.hp.sprBg then
		self.hp.sprBg:hide()
	end

	if self.hp.label then
		self.hp.label:hide()
	end

	self:showName(false)

	self.isShow = false
	self.dirty = true

	return self
end

local __position = cc.Node.setPosition

function info:uptPos(x, y)
	local size = def.role.size

	if self.hp.spr then
		__position(self.hp.spr, x + size.w / 2 - 16, y + size.h)
	end

	if self.hp.sprBg then
		__position(self.hp.sprBg, x + size.w / 2 - 16, y + size.h)
	end

	if self.hp.label then
		__position(self.hp.label, x + size.w / 2, y + size.h + 2)
	end

	if self.name.node then
		__position(self.name.node, x, y)
	end

	if self.sayLabel then
		__position(self.sayLabel, x + size.w / 2, y + size.h + 20)
	end

	self.x, self.y = x, y

	return self
end

function info:createHpSpr()
	if self.noHp then
		return
	end

	local size = def.role.size

	if not self.hp.sprBg then
		self.hp.sprBg = res.getui(3, 0):anchor(0, 0):pos(self.x + size.w / 2 - 16, self.y + size.h):addto(self.map.layers.infoHpBg)
	end

	if not self.hp.spr then
		local hptex

		if self.role.isPlayer then
			if g_data.setting.base.hiBlood then
				hptex = res.gettex2("pic/common/hp_green.png")
			else
				hptex = res.getuitex(3, 1)
			end
		elseif self.role.__cname == "npc" then
			hptex = res.gettex2("pic/common/hp_blue.png")
		else
			hptex = res.getuitex(3, 1)
		end

		self.hp.spr = display.newSprite(hptex):anchor(0, 0):pos(self.x + size.w / 2 - 16, self.y + size.h):addto(self.map.layers.infoHpSpr)
	end

	if self.isShow then
		self.hp.sprBg:setVisible(not not self.hp.max)
		self.hp.spr:setVisible(not not self.hp.max)
	end
end

function info:setName(name, force)
	self.name.texts = {}
	self.name.labels = {}

	if type(name) == "string" then
		self.name.texts = {
			name
		}
	else
		for i, v in ipairs(name) do
			if v == "" then
				break
			end

			self.name.texts[#self.name.texts + 1] = v
		end
	end

	if force then
		self:updateSetName()
	else
		self.buf.name = true
	end

	self:setDirty(true)
end

function info:updateSetName()
	if self.name.node then
		self.name.node:removeSelf()

		self.name.node = nil
	end

	if not self:isShowName() then
		return
	end

	self.name.node = display.newNode():add2(self.map, 0, mapDef.topTag):pos(self.x, self.y):hide()

	local nameLine = g_data.setting.base.showNameOnly and 1 or #self.name.texts
	local size = def.role.size

	for i, v in ipairs(self.name.texts) do
		local color = self.name.color

		if type(color) ~= "table" then
			color = def.colors.get(self.name.color) or display.COLOR_WHITE
		end

		self.name.labels[#self.name.labels + 1] = an.newLabel(v, 14, 1, {
			bufferChannel = 1,
			color = color,
			needSave = i == 1 and self.role.__cname == "mon"
		}):anchor(0.5, 0.5):pos(size.w / 2, size.h / 2 - ((nameLine - 1) / 2 - (i - 1)) * 15):addTo(self.name.node)

		if g_data.setting.base.showNameOnly then
			break
		end
	end

	self:showName(true)
end

function info:getName()
	return self.name.texts[1]
end

function info:isHero()
	return self.name.color == 147
end

function info:setNameColor(color)
	if self.role.__cname == "npc" then
		return
	end

	self.name.color = color

	if type(color) == "number" then
		color = def.colors.get(color)
	end

	for i, v in ipairs(self.name.labels) do
		v:setColor(color)
	end

	self:setDirty(true)
end

function info:setForceName(force)
	self.forceShowName = force
end

function info:isShowName()
	if self.forceShowName then
		return true
	end

	local show = true
	local race = self.role:getRace()

	if race == 98 or race == 99 or race == 153 then
		return false
	end

	if self.role.__cname == "npc" then
		show = g_data.setting.base.NPCShowName
	elseif self.role.__cname == "hero" then
		show = g_data.setting.base.heroShowName
	elseif self.role.__cname == "mon" then
		show = g_data.setting.base.monShowName
	end

	if string.find(self:getName() or "", "%(") then
		show = g_data.setting.base.petShowName
	end

	return show
end

function info:showName(b)
	if self.name.node then
		local show = b

		if b then
			show = self:isShowName()
		end

		self.name.node:setVisible(show)
	end
end

function info:showOutHP(outHP)
	if not outHP or outHP <= 0 or self.role.isPlayer then
		return
	end

	if not g_data.setting.base.showOutHP then
		return
	end

	local size = def.role.size
	local label

	label = cc.Label:createWithCharMap(res.gettex2("pic/common/num1.png"), 20, 33, string.byte("0")):scale(0.7):anchor(0.5, 0.5):pos(self.x + size.w / 2, self.y + size.h / 2 + 40):add2(self.map.layers.infoHpOut):fadeOut(1):runs({
		cc.MoveBy:create(1, cc.p(0, 40)),
		cc.CallFunc:create(function()
			label:removeSelf()
		end)
	})

	label:setString(tostring(outHP))
end

function info:setHP(hp, maxhp, outHP)
	self:setDirty(true)

	self.buf.hp = {
		hp,
		maxhp
	}
	self.buf.hpOut = outHP
end

function info:updateSetHp(hp, maxhp)
	self.hp.cur = hp
	self.hp.max = maxhp

	if self.hp.spr then
		local size = def.role.size
		local value = math.min(1, math.max(hp / (maxhp == 0 and 1 or maxhp), 0))

		self.hp.spr:setTextureRect(cc.rect(0, 0, self.hp.sprBg:getw() * value, self.hp.sprBg:geth()))

		if not self.hp.label then
			self.hp.label = an.newLabel("", 11, 1, {
				bufferChannel = 0
			}):pos(self.x + size.w / 2, self.y + size.h + 2):anchor(0.5, 0):addTo(self.map, 0, mapDef.topTag)
		end

		local level = ""

		if g_data.setting.base.levelShow and self.role.__cname == "hero" and not self:isHero() then
			level = "/" .. def.role.hp2level(maxhp, self.role.isPlayer and g_data.player.job)
		end

		self.hp.label:setString(hp .. "/" .. maxhp .. level)
	end
end

function info:updateHpOut(outHP)
	self:showOutHP(outHP)
end

function info:say(msg)
	self:setDirty(true)

	self.buf.msg = msg
end

function info:setDirty(b)
	self.dirty = b
end

function info:updateSay(msg)
	if self.sayLabel then
		self.sayLabel:removeSelf()
	end

	local size = def.role.size

	self.sayLabel = common.createChatLabel(msg)

	if msg.adapt then
		self.sayLabel = msg.adapt(self.sayLabel) or self.sayLabel
	end

	self.sayLabel:add2(self.map, 0, mapDef.topTag):anchor(0.5, 0):pos(self.x + size.w / 2, self.y + size.h + 20):runs({
		cc.DelayTime:create(msg.duration or 5),
		cc.CallFunc:create(function()
			self.sayLabel:removeSelf()

			self.sayLabel = nil
		end)
	})
end

function info:update(dt)
	if not self.dirty and not self.role.isPlayer then
		return
	end

	self.dirty = false

	if not self.role.isIgnore and self.isShow then
		if self.buf.hp then
			self:updateSetHp(unpack(self.buf.hp))

			self.buf.hp = nil
		end

		if self.buf.name then
			self:updateSetName()

			self.buf.name = nil
		end

		self:createHpSpr()
	end

	if self.buf.hpOut then
		self:updateHpOut(self.buf.hpOut)

		self.buf.hpOut = nil
	end

	if self.buf.msg then
		self:updateSay(self.buf.msg)

		self.buf.msg = nil
	end
end

return info
