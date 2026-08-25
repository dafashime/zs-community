local msgbox = class("an.msgbox", function ()
	return display.newNode()
end)
local config = nil

table.merge(msgbox, {
	scroll,
	input,
	bg
})

function msgbox.init(_config)
	assert(_config.bg, "[bg] not found.")
	assert(_config.content, "[content] not found.")
	assert(_config.confirm, "[confirm] not found.")

	config = _config or {}

	for k, v in pairs(config) do
		if type(v) == "userdata" and tolua.type(v) == "cc.Texture2D" then
			v:retain()
		end
	end

	config.cancel = config.cancel or _config.confirm
	config.inputListBgScale = config.inputListBgScale or 1
	config.contentLabelSize = config.contentLabelSize or 18
	config.btny = config.btny or 0
	config.btnColor = config.btnColor or display.COLOR_WHITE
	config.btnSColor = config.btnSColor or display.COLOR_BLACK
	config.btnLabelSize = config.btnLabelSize or 18
	config.btnAlignStyle = config.btnAlignStyle or "center"
	config.btnSpace = config.btnSpace or 0
end

function msgbox:ctor(text, func, params, node)
	assert(config, "msgbox not inited.")

	params = params or {}

	self:size(display.width, display.height):addto(display.getRunningScene() or node, an.z.msgbox)
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ()
	end)

	local bg = display.newSprite(config.bg):center():addto(self)
	local title = params.title or config.title

	if title then
		assert(config.titlepos, "titlepos not inited.")
		display.newSprite(title):add2(bg):pos(config.titlepos.x, config.titlepos.y)
	end

	if config.close then
		an.newBtn(config.close, function ()
			self:removeSelf()
		end, {
			pressImage = config.close2
		}):anchor(1, 1):pos(bg:getw() - 5, bg:geth() - 5):add2(bg)
	end

	local btnw = config.confirm:getContentSize().width
	local btnh = config.confirm:getContentSize().height
	local spacex = config.btnSpace
	local btns = {}
	local centerpos = cc.p(config.content.x + config.content.w / 2, config.content.y + config.content.h / 2)

	local function clickBtn(idx)
		if config.sound then
			audio.playSound(config.sound)
		end

		if func then
			func(idx)
		end

		if not params.manualRemove then
			self:removeSelf()
		end
	end

	local function btnPosx(i, cnt)
		if config.btnAlignStyle == "center" then
			return bg:getw() / (cnt + 1) * i
		elseif config.btnAlignStyle == "left" then
			return config.content.x + btnw / 2 + (i - 1) * (btnw + spacex)
		elseif config.btnAlignStyle == "right" then
			return config.content.x + config.content.w - btnw / 2 - (i - 1) * (btnw + spacex)
		end
	end

	local btnConfigs = nil

	if params.btnTexts then
		btnConfigs = {}

		for i, v in ipairs(params.btnTexts) do
			btnConfigs[#btnConfigs + 1] = {
				v,
				i,
				config.confirm,
				config.confirm2
			}
		end
	elseif params.hasCancel then
		btnConfigs = {
			{
				"",
				1,
				config.confirm,
				config.confirm2,
				config.confirmText
			},
			{
				"",
				0,
				config.cancel,
				config.cancel2,
				config.cancelText
			}
		}

		if config.btnAlignStyle == "right" then
			btnConfigs[2] = btnConfigs[1]
			btnConfigs[1] = btnConfigs[2]
		end
	else
		btnConfigs = {
			{
				"",
				1,
				config.confirm,
				config.confirm2,
				config.confirmText
			}
		}
	end

	for i, v in ipairs(btnConfigs) do
		btns[#btns + 1] = an.newBtn(v[3], function ()
			clickBtn(v[2])
		end, {
			pressImage = v[4],
			label = not v[5] and {
				v[1],
				config.btnLabelSize,
				1,
				{
					color = config.btnColor,
					sc = config.btnSColor
				}
			},
			sprite = v[5]
		}):pos(btnPosx(i, #btnConfigs), config.btny + btnh / 2):add2(bg)
	end

	local labelM = nil

	if params.center then
		labelM = an.newLabelM(config.content.w, params.fontSize or config.contentLabelSize, 1, {
			center = true
		}):anchor(0.5, 0.5):pos(bg:centerPos()):add2(bg)
	else
		self.scroll = an.newScroll(config.content.x, config.content.y, config.content.w, config.content.h, {
			labelM = {
				params.fontSize or config.contentLabelSize,
				1
			}
		}):add2(bg)

		if params.disableScroll then
			self.scroll:enableTouch(false)
		end

		labelM = self.scroll.labelM
	end

	if type(text) == "string" then
		labelM:addLabel(text)
	else
		for i, v in ipairs(text) do
			labelM:addLabel(unpack(v))
		end
	end

	self.labelM = labelM

	if params.input then
		if params.center then
			self.input = an.newInput(centerpos.x, centerpos.y, config.content.w, 40, params.input, {
				label = {
					"",
					18,
					1
				},
				bg = {
					h = 24
				}
			}):anchor(0, 1):add2(self.scroll)
		else
			local size = self.scroll:getScrollSize()
			self.input = an.newInput(0, size.height - self.scroll.labelM:geth(), size.width, 40, params.input, {
				label = {
					"",
					18,
					1
				},
				bg = {
					h = 24
				}
			}):anchor(0, 1):add2(self.scroll)
		end

		if params.inputNow then
			self.input:startInput()
		end

		if params.inputList then
			display.newSprite(config.inputListBg):pos(display.cx + 315, display.cy):scale(config.inputListBgScale or 1):add2(self)
			an.newLabel(params.inputList[1], 18, 1, {
				color = cc.c3b(255, 255, 0)
			}):anchor(0.5, 0.5):pos(display.cx + 315, display.cy + 140):add2(self)

			local select, scroll = nil
			scroll = an.newScroll(display.cx + 250, display.cy - 155, 130, 280, {
				labelM = {
					18,
					1,
					params = {
						manual = true,
						center = true,
						clickLine_call = function (data)
							select:show():pos(0, scroll:getScrollSize().height - data.i * scroll.labelM.wordSize.height)
							self.input:setString(data.v)
						end
					}
				}
			}):addTo(self)
			select = display.newColorLayer(cc.c4b(0, 200, 200, 255)):size(scroll:getw(), scroll.labelM.wordSize.height):add2(scroll, -1):hide()

			for i, v in ipairs(params.inputList[2]) do
				scroll.labelM:nextLine({
					i = i,
					v = v
				}):addLabel(v)
			end
		end
	end

	self.bg = bg
	self.btns = btns
end

return msgbox
