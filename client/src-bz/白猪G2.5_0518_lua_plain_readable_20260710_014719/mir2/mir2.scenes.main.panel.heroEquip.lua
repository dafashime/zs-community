local equip = import(".equip")
local heroEquip = class("heroEquip", equip)

table.merge(heroEquip, {
	isHero = true
})

function heroEquip:ctor(params)
	heroEquip.super.ctor(self, params)

	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("left")
	end
end

function heroEquip:putItem(item, x, y)
	local form = item.formPanel.__cname

	if self.page == "main" and form == "heroBag" then
		local anchor = self.content.bg:getAnchorPoint()
		local offset = cc.p(self.content.bg:getw() * anchor.x, self.content.bg:geth() * anchor.y)

		x, y = x - self.content.bg:getPositionX() + offset.x, y - self.content.bg:getPositionY() + offset.y

		local putIdx = self:pos2idx(x, y)

		if putIdx == "-1" then
			return
		end

		item:use(putIdx)
	end
end

return heroEquip
