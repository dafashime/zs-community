local role = import(".role")
local npc = class("npc", role)

function npc:ctor(params)
	npc.super.ctor(self, params)
	self:initEnd()
end

function npc:getParts(feature)
	local parts = {}
	local race = feature:get("race")
	local appr = feature:get("dress")
	local npcId = def.role.getRoleId(race, appr)
	local dressFrame = def.role.getDressFrame(npcId)

	if appr < 256 then
		local dargon = appr >= 70 and appr <= 75

		if dargon then
			parts.hair = {
				blend = true,
				cannotMove = true,
				id = appr,
				imgid = def.role.getNpc(npcId).img,
				offset = def.role.getNpcOffset(npcId) + 4,
				frame = dressFrame,
				direction = def.role.getNpc(npcId).direction
			}
		end

		parts.dress = {
			id = appr,
			imgid = def.role.getNpc(npcId).img,
			offset = def.role.getNpcOffset(npcId),
			frame = dressFrame,
			cannotMove = dargon,
			direction = def.role.getNpc(npcId).direction
		}
	else
		print("暂不支持的npc类型:", appr)
	end

	return parts
end

function npc:updateSpriteForState(type, sprite)
	local function update(t, spr)
		local state = self.last.state
		local npcId = def.role.getRoleId(self:getRace(), self:getAppr())

		if def.role.stateHas(state, "stCeleb") then
			def.role.changeStandFrame(npcId, "dress", "stCeleb")

			self.parts.dress.frame = def.role.getDressFrame(npcId)
		else
			def.role.resetRoleFrame(npcId)

			self.parts.dress.frame = def.role.getDressFrame(npcId)
		end
	end

	if type and sprite then
		return update(type, sprite)
	end

	for k, v in pairs(self.sprites) do
		update(k, v)
	end
end

return npc
