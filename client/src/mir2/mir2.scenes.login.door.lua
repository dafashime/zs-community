local door = class("door", function ()
	return display.newNode()
end)

table.merge(door, {})

function door:ctor(scene)
	local pic = m2spr.new("chrsel", 23):addto(self):pos(display.cx, display.cy + 25)

	pic:setScaleX(display.width / 800)
	pic:setScaleY(display.height / 600)

	g_data.player.smallExit = true

	sound.preloadSound("100")
	pic:runs({
		cc.DelayTime:create(0.7),
		cc.CallFunc:create(function ()
			sound.playSound("100", true)
			pic:playAni("chrsel", 23, 9, 0.08, nil, nil, true, function ()
				audio.stopAllSounds()

				if scene.loseConnect then
					return
				end

				net.remove(scene)
				game.gotoscene("select", nil, "fade", 0.5, display.COLOR_BLACK)
			end)
		end)
	})
end

return door
