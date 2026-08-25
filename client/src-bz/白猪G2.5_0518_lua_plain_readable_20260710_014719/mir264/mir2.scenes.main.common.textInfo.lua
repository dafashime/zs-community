local info = {}
local enabled2 = true
local enabled = false

function info.create(value, value3, value5)
	value5.offsetX = 0
	value5.bgCount = 1

	local value2, value4 = info.show(value, value3, value5)

	return value2
end

function info.show(labels, scenePos, params)
	params = params or {}

	local number = 220
	local height = 350
	local layer = display.newNode():size(display.width, display.height):addto(params.parent or display.getRunningScene(), params.z or an.z.max)

	info.layer = layer

	layer:setTag(2020)

	layer.params = params

	layer.setTouchEnabled(layer, true)
	layer.setTouchSwallowEnabled(layer, false)
	layer.addNodeEventListener(layer, cc.NODE_TOUCH_CAPTURE_EVENT, function(nameOwner)
		if nameOwner.name == "began" then
			enabled = false
		elseif nameOwner.name == "ended" and not enabled then
			g_data.player.showTips = false

			info.layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local node = display.newNode()
	local background = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(layer):anchor(0, 1)

	background:setName("tipsTxtBg1")

	local labels2 = {}

	local function callback(self)
		local node = {}

		for index in string.gfind(self, "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*") do
			node[#node + 1] = index
		end

		return node
	end

	local function callback2(self, color, value2)
		self = self or ""
		labels2[#labels2 + 1] = an.newLabel(self, value2 or 18, 1, {
			color = color
		})

		local text = ""
		local value = callback(self)
		local text2 = ""

		if number < labels2[#labels2]:getw() then
			for _, item in pairs(value) do
				local value3 = text2 .. item

				labels2[#labels2]:setString(value3)

				if number < labels2[#labels2]:getw() then
					text2 = ""
					labels2[#labels2 + 1] = an.newLabel(text2, value2 or 18, 1, {
						color = color
					})
				else
					text2 = value3
				end
			end
		end
	end

	if labels and labels.labels then
		labels2 = labels.labels
	end

	if labels and labels.texts then
		for _, text in ipairs(labels.texts) do
			if text.text then
				callback2(text.text, text.color or cc.c3b(245, 245, 245), text.fontSize or 18)
			end
		end
	end

	local x = 0
	local h = 7
	local number2 = -2
	local items = {}

	if labels and labels.btns then
		for _2, btn in ipairs(labels.btns) do
			local items2 = {
				pressImage = res.gettex2("pic/common/btn91.png")
			}

			if btn.name then
				items2.label = {
					btn.name or "",
					20,
					1,
					{
						color = def.colors.btn30
					}
				}
			elseif btn.sprite then
				items2.sprite = res.gettex2(btn.sprite)
			end

			local btn2 = an.newBtn(res.gettex2("pic/common/btn90.png"), function()
				btn.click()
			end, items2):anchor(0.5, 0):pos(x * 0.5, h):add2(background, 999):scale(0.9)

			x = math.max(x, btn2.getw(btn2))
			items[#items + 1] = btn2
			h = h + btn2.geth(btn2) + number2
		end
	end

	for i = #labels2, 1, -1 do
		local count = 0

		x = math.max(x, labels2[i]:getw())

		local value = labels2[i]:geth()

		labels2[i]:addto(node, 99):pos(10, h):anchor(0, 0)

		local value2 = utf8strs(labels2[i]:getString())

		h = h + value + number2
	end

	local label = an.newLabelM(number, 18, 1):anchor(0, 0):addto(node, 99):pos(10, h):anchor(0, 0)
	local w = math.max(x, label.widthCnt) + 20
	local height2 = h + 5

	;(function()
		node:size(w, height2)

		if height2 > height then
			local scroll = an.newScroll(0, 5, w, height - 5):addto(background)

			node:addTo(scroll):anchor(0, 0):pos(0, 0)
			scroll:setScrollSize(w, height2)
			scroll:setListenner(function(nameOwner)
				if nameOwner.name == "moved" and not enabled then
					enabled = true
				end
			end)

			height2 = height

			background:size(w + 2, height + 2)
		else
			node:addTo(background):anchor(0, 0):pos(0, 0)
			background:size(w + 2, height2 + 2)
		end
	end)()

	for _3, item in ipairs(items) do
		item.setPositionX(item, w * 0.5)
	end

	local display = cc.rect(params.minx or 0, params.miny or 0, params.maxx or display.width, params.maxy or display.height)

	if params.extra then
		if enabled2 then
			scenePos.x = scenePos.x - w
		else
			scenePos.x = scenePos.x + params.xOffset
		end
	end

	local p = scenePos

	if p.x < display.x then
		p.x = display.x
	end

	if display.width < p.x + w then
		p.x = p.x - w
	end

	if p.y - height2 < display.y then
		p.y = p.y + (height2 - p.y + 10)
	end

	if display.height < p.y then
		p.y = display.height - 10
	end

	background.pos(background, p.x, p.y)

	return layer, background
end

return info
