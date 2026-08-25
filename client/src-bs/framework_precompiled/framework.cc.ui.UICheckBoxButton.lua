local UIButton = import(".UIButton")
local UICheckBoxButton = class("UICheckBoxButton", UIButton)
UICheckBoxButton.OFF = "off"
UICheckBoxButton.OFF_PRESSED = "off_pressed"
UICheckBoxButton.OFF_DISABLED = "off_disabled"
UICheckBoxButton.ON = "on"
UICheckBoxButton.ON_PRESSED = "on_pressed"
UICheckBoxButton.ON_DISABLED = "on_disabled"

function UICheckBoxButton:ctor(images, options)
	UICheckBoxButton.super.ctor(self, {
		{
			name = "disable",
			to = "off_disabled",
			from = {
				"off",
				"off_pressed"
			}
		},
		{
			name = "disable",
			to = "on_disabled",
			from = {
				"on",
				"on_pressed"
			}
		},
		{
			name = "enable",
			to = "off",
			from = {
				"off_disabled"
			}
		},
		{
			name = "enable",
			to = "on",
			from = {
				"on_disabled"
			}
		},
		{
			name = "press",
			to = "off_pressed",
			from = "off"
		},
		{
			name = "press",
			to = "on_pressed",
			from = "on"
		},
		{
			name = "release",
			to = "off",
			from = "off_pressed"
		},
		{
			name = "release",
			to = "on",
			from = "on_pressed"
		},
		{
			name = "select",
			to = "on",
			from = "off"
		},
		{
			name = "select",
			to = "on_disabled",
			from = "off_disabled"
		},
		{
			name = "unselect",
			to = "off",
			from = "on"
		},
		{
			name = "unselect",
			to = "off_disabled",
			from = "on_disabled"
		}
	}, "off", options)
	self:setButtonImage(UICheckBoxButton.OFF, images.off, true)
	self:setButtonImage(UICheckBoxButton.OFF_PRESSED, images.off_pressed, true)
	self:setButtonImage(UICheckBoxButton.OFF_DISABLED, images.off_disabled, true)
	self:setButtonImage(UICheckBoxButton.ON, images.on, true)
	self:setButtonImage(UICheckBoxButton.ON_PRESSED, images.on_pressed, true)
	self:setButtonImage(UICheckBoxButton.ON_DISABLED, images.on_disabled, true)

	self.labelAlign_ = display.LEFT_CENTER
	self.args_ = {
		images,
		options
	}
end

function UICheckBoxButton:setButtonImage(state, image, ignoreEmpty)
	assert(state == UICheckBoxButton.OFF or state == UICheckBoxButton.OFF_PRESSED or state == UICheckBoxButton.OFF_DISABLED or state == UICheckBoxButton.ON or state == UICheckBoxButton.ON_PRESSED or state == UICheckBoxButton.ON_DISABLED, string.format("UICheckBoxButton:setButtonImage() - invalid state %s", tostring(state)))
	UICheckBoxButton.super.setButtonImage(self, state, image, ignoreEmpty)

	if state == UICheckBoxButton.OFF then
		if not self.images_[UICheckBoxButton.OFF_PRESSED] then
			self.images_[UICheckBoxButton.OFF_PRESSED] = image
		end

		if not self.images_[UICheckBoxButton.OFF_DISABLED] then
			self.images_[UICheckBoxButton.OFF_DISABLED] = image
		end
	elseif state == UICheckBoxButton.ON then
		if not self.images_[UICheckBoxButton.ON_PRESSED] then
			self.images_[UICheckBoxButton.ON_PRESSED] = image
		end

		if not self.images_[UICheckBoxButton.ON_DISABLED] then
			self.images_[UICheckBoxButton.ON_DISABLED] = image
		end
	end

	return self
end

function UICheckBoxButton:isButtonSelected()
	return self.fsm_:canDoEvent("unselect")
end

function UICheckBoxButton:setButtonSelected(selected)
	if self:isButtonSelected() ~= selected then
		if selected then
			self.fsm_:doEventForce("select")
		else
			self.fsm_:doEventForce("unselect")
		end

		self:dispatchEvent({
			name = UIButton.STATE_CHANGED_EVENT,
			state = self.fsm_:getState()
		})
	end

	return self
end

function UICheckBoxButton:onTouch_(event)
	local name = event.name
	local x = event.x
	local y = event.y

	if name == "began" then
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

	local touchInTarget = self:checkTouchInSprite_(x, y)

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
			self:setButtonSelected(self.fsm_:canDoEvent("select"))
			self:dispatchEvent({
				touchInTarget = true,
				name = UIButton.CLICKED_EVENT,
				x = x,
				y = y
			})
		end
	end
end

function UICheckBoxButton:getDefaultState_()
	local state = self.fsm_:getState()

	if state == UICheckBoxButton.ON or state == UICheckBoxButton.ON_DISABLED or state == UICheckBoxButton.ON_PRESSED then
		return {
			UICheckBoxButton.ON,
			UICheckBoxButton.OFF
		}
	else
		return {
			UICheckBoxButton.OFF,
			UICheckBoxButton.ON
		}
	end
end

function UICheckBoxButton:createCloneInstance_()
	return UICheckBoxButton.new(unpack(self.args_))
end

return UICheckBoxButton
