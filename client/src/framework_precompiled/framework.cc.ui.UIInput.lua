local UIInput = nil
UIInput = class("UIInput", function (options)
	local inputLabel = nil

	if not options or not options.UIInputType or options.UIInputType == 1 then
		inputLabel = UIInput.newEditBox_(options)
		inputLabel.UIInputType = 1
	elseif options.UIInputType == 2 then
		inputLabel = UIInput.newTextField_(options)
		inputLabel.UIInputType = 2
	end

	return inputLabel
end)

function UIInput:ctor(options)
	if options.UIInputType == 2 then
		self.getText = self.getStringValue
	end

	self.args_ = options
end

function UIInput.newEditBox_(params)
	local imageNormal = params.image
	local imagePressed = params.imagePressed
	local imageDisabled = params.imageDisabled

	if type(imageNormal) == "string" then
		imageNormal = display.newScale9Sprite(imageNormal)
	end

	if type(imagePressed) == "string" then
		imagePressed = display.newScale9Sprite(imagePressed)
	end

	if type(imageDisabled) == "string" then
		imageDisabled = display.newScale9Sprite(imageDisabled)
	end

	local editbox = ccui.EditBox:create(params.size, imageNormal, imagePressed, imageDisabled)

	if editbox then
		if params.listener then
			editbox:registerScriptEditBoxHandler(params.listener)
		end

		if params.x and params.y then
			editbox:setPosition(params.x, params.y)
		end
	end

	return editbox
end

function UIInput.newTextField_(params)
	local textfieldCls = nil

	if cc.bPlugin_ then
		textfieldCls = ccui.TextField
	else
		textfieldCls = cc.TextField
	end

	local editbox = textfieldCls:create()

	editbox:setPlaceHolder(params.placeHolder)

	if params.x and params.y then
		editbox:setPosition(params.x, params.y)
	end

	if params.listener then
		editbox:addEventListener(params.listener)
	end

	if params.size then
		editbox:setTextAreaSize(params.size)
		editbox:setTouchSize(params.size)
		editbox:setTouchAreaEnabled(true)
	end

	if params.text then
		if editbox.setString then
			editbox:setString(params.text)
		else
			editbox:setText(params.text)
		end
	end

	if params.font then
		editbox:setFontName(params.font)
	end

	if params.fontSize then
		editbox:setFontSize(params.fontSize)
	end

	if params.fontColor then
		editbox:setTextColor(cc.c4b(params.fontColor.R or 255, params.fontColor.G or 255, params.fontColor.B or 255, 255))
	end

	if params.maxLength and params.maxLength ~= 0 then
		editbox:setMaxLengthEnabled(true)
		editbox:setMaxLength(params.maxLength)
	end

	if params.passwordEnable then
		editbox:setPasswordEnabled(true)
	end

	if params.passwordChar then
		editbox:setPasswordStyleText(params.passwordChar)
	end

	return editbox
end

function UIInput:createcloneInstance_()
	return UIInput.new(unpack(self.args_))
end

return UIInput
