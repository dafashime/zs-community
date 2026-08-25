local UIButton = import(".UIButton")
local UIPushButton = class("UIPushButton", UIButton)
UIPushButton.NORMAL = "normal"
UIPushButton.PRESSED = "pressed"
UIPushButton.DISABLED = "disabled"

function UIPushButton:ctor(images, options)
	UIPushButton.super.ctor(self, {
		{
			name = "disable",
			to = "disabled",
			from = {
				"normal",
				"pressed"
			}
		},
		{
			name = "enable",
			to = "normal",
			from = {
				"disabled"
			}
		},
		{
			name = "press",
			to = "pressed",
			from = "normal"
		},
		{
			name = "release",
			to = "normal",
			from = "pressed"
		}
	}, "normal", options)

	if type(images) ~= "table" then
		images = {
			normal = images
		}
	end

	self:setButtonImage(UIPushButton.NORMAL, images.normal, true)
	self:setButtonImage(UIPushButton.PRESSED, images.pressed, true)
	self:setButtonImage(UIPushButton.DISABLED, images.disabled, true)

	self.args_ = {
		images,
		options
	}
end

function UIPushButton:setButtonImage(state, image, ignoreEmpty)
	assert(state == UIPushButton.NORMAL or state == UIPushButton.PRESSED or state == UIPushButton.DISABLED, string.format("UIPushButton:setButtonImage() - invalid state %s", tostring(state)))
	UIPushButton.super.setButtonImage(self, state, image, ignoreEmpty)

	if state == UIPushButton.NORMAL then
		if not self.images_[UIPushButton.PRESSED] then
			self.images_[UIPushButton.PRESSED] = image
		end

		if not self.images_[UIPushButton.DISABLED] then
			self.images_[UIPushButton.DISABLED] = image
		end
	end

	return self
end

function UIPushButton:onTouch_(event)
	local name = event.name
	local x = event.x
	local y = event.y

	if name == "began" then
		self.touchBeganX = x
		self.touchBeganY = y

		if not self:checkTouchInSprite_(x, y) then
			return false
		end

		self.fsm_:doEvent("press")
		self:dispatchEvent({
			touchInTarget = true,
			name = UIButton.PRESSED_EVENT,
			x = x,
			y = y
		})

		return true
	end

	local touchInTarget = self:checkTouchInSprite_(self.touchBeganX, self.touchBeganY) and self:checkTouchInSprite_(x, y)

	if name == "moved" then
		if touchInTarget and self.fsm_:canDoEvent("press") then
			self.fsm_:doEvent("press")
			self:dispatchEvent({
				touchInTarget = true,
				name = UIButton.PRESSED_EVENT,
				x = x,
				y = y
			})
		elseif not touchInTarget and self.fsm_:canDoEvent("release") then
			self.fsm_:doEvent("release")
			self:dispatchEvent({
				touchInTarget = false,
				name = UIButton.RELEASE_EVENT,
				x = x,
				y = y
			})
		end
	else
		if self.fsm_:canDoEvent("release") then
			self.fsm_:doEvent("release")
			self:dispatchEvent({
				name = UIButton.RELEASE_EVENT,
				x = x,
				y = y,
				touchInTarget = touchInTarget
			})
		end

		if name == "ended" and touchInTarget then
			self:dispatchEvent({
				touchInTarget = true,
				name = UIButton.CLICKED_EVENT,
				x = x,
				y = y
			})
		end
	end
end

function UIPushButton:createCloneInstance_()
	return UIPushButton.new(unpack(self.args_))
end

return UIPushButton
