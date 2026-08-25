local tip = class("leftTopTip", function ()
	return display.newNode()
end)

table.merge(tip, {
	msgs = {}
})

function tip:ctor()
	self.msgs = {}
	self.maxLine = 10

	self:pos(40, display.height - 50 - self.maxLine * 22)
end

function tip:getSpace()
	return 24
end

function tip:upt()
	for i, v in ipairs(self.msgs) do
		v:pos(0, (self.maxLine - i) * 22)
	end
end

function tip:show(text, color)
	local msg = nil
	msg = an.newLabel(text, 20, 1, {
		color = color or display.COLOR_GREEN
	}):add2(self):runs({
		cc.DelayTime:create(3),
		cc.FadeOut:create(0.3),
		cc.CallFunc:create(function ()
			table.removebyvalue(self.msgs, msg)
			msg:removeSelf()
			self:upt()
		end)
	})

	msg:setCascadeOpacityEnabled(true)

	self.msgs[#self.msgs + 1] = msg

	if self.maxLine < #self.msgs then
		self.msgs[1]:removeSelf()
		table.remove(self.msgs, 1)
	end

	self:upt()
end

return tip
