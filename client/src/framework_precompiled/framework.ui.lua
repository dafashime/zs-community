local ui = {
	DEFAULT_TTF_FONT = "Arial",
	DEFAULT_TTF_FONT_SIZE = 24,
	TEXT_ALIGN_LEFT = cc.TEXT_ALIGNMENT_LEFT,
	TEXT_ALIGN_CENTER = cc.TEXT_ALIGNMENT_CENTER,
	TEXT_ALIGN_RIGHT = cc.TEXT_ALIGNMENT_RIGHT,
	TEXT_VALIGN_TOP = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	TEXT_VALIGN_CENTER = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
	TEXT_VALIGN_BOTTOM = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM
}

function ui.newEditBox(params)
	PRINT_DEPRECATED(string.format("%s() is deprecated, please use %s()", "ui.newEditBox", "cc.ui.UIInput"))

	if params then
		params.UIInputType = 1
	end

	return cc.ui.UIInput.new(params)
end

function ui.newTextField(params)
	PRINT_DEPRECATED(string.format("%s() is deprecated, please use %s()", "ui.newTextField", "cc.ui.UIInput"))

	params = params or {}

	if params then
		params.UIInputType = 2
	end

	return cc.ui.UIInput.new(params)
end

function ui.newBMFontLabel(params)
	PRINT_DEPRECATED(string.format("%s() is deprecated, please use %s()", "ui.newBMFontLabel", "cc.ui.UILabel"))

	return cc.ui.UILabel.newBMFontLabel_(params)
end

function ui.newTTFLabel(params)
	PRINT_DEPRECATED(string.format("%s() is deprecated, please use %s()", "ui.newTTFLabel", "cc.ui.UILabel"))

	return cc.ui.UILabel.newTTFLabel_(params)
end

function ui.newTTFLabelWithShadow(params)
	PRINT_DEPRECATED(string.format("%s() is deprecated, please use %s()", "ui.newTTFLabelWithShadow", "cc.ui.UILabel"))

	local label = cc.ui.UILabel.newTTFLabel_(params)

	label:enableShadow(params.shadowColor, cc.size(2, -2))

	return label
end

function ui.newTTFLabelWithOutline(params)
	PRINT_DEPRECATED(string.format("%s() is deprecated, please use %s()", "ui.newTTFLabelWithOutline", "cc.ui.UILabel"))

	local label = cc.ui.UILabel.newTTFLabel_(params)

	label:enableOutline(params.outlineColor, 2)

	return label
end

return ui
