return {
	show = function(items, value, spaceOwner)
		spaceOwner = spaceOwner or {}

		local node = display.newNode():size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.textInfo)

		node:setTouchEnabled(true)
		node:setTouchSwallowEnabled(false)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(nameOwner)
			if nameOwner.name == "ended" then
				node:removeSelf()
			end

			return true
		end)

		local background = display.newScale9Sprite(res.getframe2("pic/scale/scale4.png")):addto(node):anchor(0, 1)
		local count = 0
		local y = 7
		local value2 = spaceOwner.space or -2

		for index = #items, 1, -1 do
			local value3 = items[index]:addto(background, 99):anchor(0, 0):pos(10, y)

			count = math.max(count, value3:getw())
			y = y + value3:geth() + value2
		end

		local width = count + 20
		local y2 = y + 10
		local x = value

		if x.x < 0 then
			x.x = 0
		end

		if display.width < x.x + width then
			x.x = display.width - width
		end

		if display.height < x.y then
			x.y = display.height
		end

		if x.y - y2 < 0 then
			x.y = y2
		end

		background:size(width, y2):pos(x.x, x.y)

		return node
	end
}
