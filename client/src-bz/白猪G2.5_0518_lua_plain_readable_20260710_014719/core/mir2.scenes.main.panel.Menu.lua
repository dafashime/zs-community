local menu = class("menu", function()
	return display.newNode()
end)

table.merge(menu, {
	btns
})

function menu:ctor()
	self._supportMove = false
	self.btns = {}

	local items = {
		posy = 335,
		space = 76,
		moremenuScale = 0.9,
		posx = 200
	}

	if def.moremenu.config then
		items = def.moremenu.config
	end

	for index, moremenu in ipairs(def.moremenu) do
		if type(moremenu) == "string" then
			self.btns[moremenu] = an.newBtn(res.gettex2("pic/console/panel-icons/" .. moremenu .. ".png"), function(value)
				main_scene.ui.console.btnCallbacks:handle("panel", moremenu)

				if main_scene.ui.console.widgets.moremenu then
					main_scene.ui.console.widgets.moremenu:toggleMenu()
				end
			end, {
				pressBig = true
			}):scale(items.moremenuScale or 1):addto(self)
			self.btns[moremenu].px = display.width - (items.posx or 260) + math.floor((index - 1) % 3) * (items.space or 80)
			self.btns[moremenu].py = display.height - (items.posy or 260) - math.floor((index - 1) / 3) * (items.space or 80)

			self.btns[moremenu]:pos(self.btns[moremenu].px + 500, self.btns[moremenu].py)
		end
	end

	for _, btn in pairs(self.btns) do
		btn.runs(btn, {
			cc.MoveTo:create(0.3, cc.p(btn.px, btn.py))
		})
	end
end

return menu
