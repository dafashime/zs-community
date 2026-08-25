local common = import("..common.common")
local magicKeySetting = class("magicKeySetting", function ()
	return display.newNode()
end)

function magicKeySetting:ctor(params)
	local bg = res.get2("pic/common/black_3.png"):addTo(self):anchor(0, 0)

	self:size(bg:getContentSize()):anchor(0.5, 0.5):center()
	res.get2("pic/panels/mail/title.png"):addTo(bg):pos(bg:getw() / 2, bg:geth() - 10):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}):addTo(bg):pos(bg:getw() - 5, bg:geth() - 9):anchor(1, 1)

	for i = 1, 2 do
		for j = 1, 8 do
			local strKey = ""

			if i == 1 then
				strKey = "F" .. j
			else
				strKey = "F" .. j .. "\nCtrl"
			end

			local button = an.newBtn(res.gettex2("pic/common/btn101.png"), function (owner)
				sound.playSound("103")
				g_data.hotKey:setMagicHotKey(5 + (i - 1) * 12 + j, params.magicId)
				gameEvent:dispatchEvent({
					name = gameEvent.skillHotKey
				})
			end, {
				pressBig = true,
				label = {
					strKey,
					18,
					1,
					{
						color = cc.c3b(255, 255, 0)
					}
				}
			}):pos(60 + 39 * (j - 1) * 1.2, bg:geth() - (80 + 41 * (i - 1) * 1.5)):anchor(0.5, 0.5):add2(self)
			button.index = (i - 1) * 12 + j
			button.keyId = 5 + button.index
		end
	end
end

return magicKeySetting
