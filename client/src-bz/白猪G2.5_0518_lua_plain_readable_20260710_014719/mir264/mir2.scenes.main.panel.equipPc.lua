local equipBase = import(".equip")
local equipPc = class("equipPc", equipBase)

function equipPc:ctor(params)
	equipBase.ctor(self, params)

	self.__cname = "equip"
	self.updateKey = gameEvent:addEventListener(gameEvent.skillHotKey, function(event)
		self:updateHotKeyUI()
	end)

	self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
end

function equipPc:onExit()
	if self.updateKey ~= nil then
		gameEvent:removeEventListener(self.updateKey)
	end
end

function equipPc:updateMagic(magicId, node)
	equipBase.updateMagic(self, magicId, node)

	local magicData = self.baseData:getMagic(tonumber(magicId))

	if magicData then
		local hasKey, keyid = g_data.hotKey:magicIsHotKey(magicId)

		if keyid and (keyid < 6 or keyid > 29) then
			return
		end

		local strKey

		if hasKey then
			if keyid < 18 then
				strKey = "F" .. keyid - 5
			else
				strKey = "F" .. keyid - 17 .. "\nCtrl"
			end
		else
			strKey = "设置"
		end

		local button = an.newBtn(res.gettex2("pic/common/btn101.png"), function()
			main_scene.ui:togglePanel("magicKeySetting", {
				magicId = magicId
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
		}):pos(240, node:geth() / 2):add2(node)
	end
end

function equipPc:updateHotKeyUI()
	if self.page == "skill" then
		self:showContent("skill")
	end
end

return equipPc
