local value = display.width - 25
local value2 = display.height - 260
local widget_moremenu = class("widget.moremenu", function()
	return display.newNode()
end)

table.merge(widget_moremenu, {
	menuspr
})

function widget_moremenu:ctor(value3, x)
	self:pos(x.x, x.y)

	self.menubg = res.get2("pic/console/menu.png"):add2(self)
	self.menuspr = res.get2("pic/console/menu_on.png"):add2(self.menubg):pos(38, 56)

	self.menuspr:enableClick(function()
		sound.playSound("103")
		self:toggleMenu()
	end)
end

function widget_moremenu:toggleMenu()
	main_scene.ui:togglePanel("Menu")

	local value3 = main_scene.ui.panels.Menu

	local function callback(self, value3)
		if self > display.width - 350 and self < display.width and value3 > 0 and value3 < display.height - 210 then
			return true
		end

		return false
	end

	local function callback2(self, value3)
		if self > display.width and value3 > 0 and value3 < display.height - 210 then
			return true
		end

		return false
	end

	if value3 then
		self.menuspr:rotateTo(0.15, -90)
	else
		self.menuspr:rotateTo(0.15, 0)
	end

	for key, widget in pairs(main_scene.ui.console.widgets) do
		local x
		local y

		if widget.data.btnpos then
			x, y = main_scene.ui.console:btnpos2pos(widget.data.btnpos)
		else
			y = widget.data.y
			x = widget.data.x
		end

		if x ~= nil and y ~= nil and key ~= "moremenu" then
			if callback(x, y) then
				if value3 then
					widget.runs(widget, {
						cc.MoveTo:create(0.1, cc.p(x - 50, y)),
						cc.MoveTo:create(0.3, cc.p(x + display.width, y))
					})
				else
					widget.run(widget, cc.MoveTo:create(0.2, cc.p(x, y)))
				end
			end

			if callback2(x, y) then
				if value3 then
					widget.run(widget, cc.MoveTo:create(0.2, cc.p(x - display.width, y)))
				else
					widget.runs(widget, {
						cc.MoveTo:create(0.1, cc.p(x - display.width - 50, y)),
						cc.MoveTo:create(0.3, cc.p(x, y))
					})
				end
			end
		end
	end
end

return widget_moremenu
