local attrTips = class("attrTips", function()
	return display.newNode()
end)

table.merge(attrTips, {
	msgs = {}
})

function attrTips:ctor()
	self.msgs = {}
	self.maxLine = 10

	self:pos(380, display.cy - 200)
end

function attrTips:getSpace()
	return 24
end

function attrTips:upt()
	for index, msg in ipairs(self.msgs) do
		msg:pos(0, (self.maxLine - index) * 35)
	end
end

function attrTips:show(scenePos, params)
	local value_2

	value_2 = res.get2("pic/common/attrTips/fightnum_bg2.png"):add2(self):scale(0.7):runs({
		cc.DelayTime:create(3),
		cc.FadeOut:create(0.3),
		cc.CallFunc:create(function()
			table.removebyvalue(self.msgs, value_2)
			value_2:removeSelf()
			self:upt()
		end)
	})

	local enabled

	if params < 0 then
		params = -params
		enabled = true
	end

	res.get2(enabled and "pic/common/sx_num_p2.png" or "pic/common/sx_num_p.png"):add2(value_2):pos(0, value_2:geth() / 2):anchor(0, 0.5)

	local value_22 = res.get2("pic/common/attrTips/" .. (attrTips_Img[scenePos] or "numsx_44") .. ".png"):add2(value_2):anchor(0, 0):pos(40, 11)

	cc.Label:createWithCharMap(res.gettex2("pic/common/num8.png"), 20, 26, string.byte("0")):anchor(0, 0):pos(value_22:getw() + 45, 11):add2(value_2):setString(tostring(params))
	value_2:setCascadeOpacityEnabled(true)

	self.msgs[#self.msgs + 1] = value_2

	if self.maxLine < #self.msgs then
		self.msgs[1]:removeSelf()
		table.remove(self.msgs, 1)
	end

	self:upt()
end

return attrTips
