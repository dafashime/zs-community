local itemInfo = import(".itemInfo")
local chatItem = class("chatItem", function()
	return display.newNode()
end)

function chatItem:ctor(h, labelM, data, noTouch, x, y)
	local h = labelM.wordSize.height * 2 - 2
	local w = h
	local bg = res.get2("pic/common/itembg.png"):anchor(0, 0):add2(self)

	bg:scalex(w / bg:getw())
	bg:scaley(h / bg:geth())
	res.get("items", data.lookID):pos(w / 2, h / 2):add2(self)

	if not noTouch then
		bg:enableClick(function()
			local p = self:convertToWorldSpace(cc.p(self:centerPos()))

			if data.itemData then
				itemInfo.show(data.itemData, p)
			else
				g_data.client:setLastQueryChatItem(data.makeIndex, data.name, p.x, p.y)
				net.send({
					CM_QUERY_FOCUS_ITEM,
					recog = data.makeIndex
				})
			end
		end)
	end

	local fontSize = math.min(labelM.fontSize, 18)
	local title = an.newLabel(data.name, fontSize, 1, {
		color = cc.c3b(0, 255, 255)
	}):pos(w + 2, h / 2):add2(self)
	local weight = an.newLabel(string.format("重量: %s", data.weight), fontSize, 1, {
		color = cc.c3b(0, 255, 255)
	}):pos(w + 2, 0):add2(self)

	self:size(w + math.max(title:getw(), weight:getw()), h)
end

return chatItem
