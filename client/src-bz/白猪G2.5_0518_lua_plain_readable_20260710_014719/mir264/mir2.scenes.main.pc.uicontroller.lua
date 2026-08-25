local uicontroller = class("uicontroller")
local magicSetting = import(".magicSetting")

function uicontroller:ctor()
	self:hideSomeUI()
end

function uicontroller:hideSomeUI()
	local rocker = main_scene.ui.console:get("rocker")

	if rocker then
		rocker:setVisible(false)
	end

	local lock = main_scene.ui.console:get("lock")

	if lock then
		lock:setVisible(false)
	end
end

function uicontroller:initUI()
	return
end

function uicontroller:magichHotKey(target, magicId)
	local magic_setting = magicSetting.new()
end

function uicontroller:updateHotKeyUI(target)
	if target.page == "skill" then
		for magic_id, node in pairs(target.magic) do
			if def.operate.magicIsHotKey(magic_id) then
				-- block empty
			end
		end
	end
end

return uicontroller
