local filter = {}
local FILTERS = {
	GRAY = {
		cc.GrayFilter
	},
	RGB = {
		cc.RGBFilter,
		3,
		{
			1,
			1,
			1
		}
	},
	HUE = {
		cc.HueFilter,
		1,
		{
			0
		}
	},
	BRIGHTNESS = {
		cc.BrightnessFilter,
		1,
		{
			0
		}
	},
	SATURATION = {
		cc.SaturationFilter,
		1,
		{
			1
		}
	},
	CONTRAST = {
		cc.ContrastFilter,
		1,
		{
			1
		}
	},
	EXPOSURE = {
		cc.ExposureFilter,
		1,
		{
			0
		}
	},
	GAMMA = {
		cc.GammaFilter,
		1,
		{
			1
		}
	},
	HAZE = {
		cc.HazeFilter,
		2,
		{
			0,
			0
		}
	},
	SEPIA = {
		cc.SepiaFilter
	},
	GAUSSIAN_VBLUR = {
		cc.GaussianVBlurFilter,
		1,
		{
			0
		}
	},
	GAUSSIAN_HBLUR = {
		cc.GaussianHBlurFilter,
		1,
		{
			0
		}
	},
	ZOOM_BLUR = {
		cc.ZoomBlurFilter,
		3,
		{
			1,
			0.5,
			0.5
		}
	},
	MOTION_BLUR = {
		cc.MotionBlurFilter,
		2,
		{
			1,
			0
		}
	},
	SHARPEN = {
		cc.SharpenFilter,
		2,
		{
			0,
			0
		}
	},
	MASK = {
		cc.MaskFilter,
		1
	},
	DROP_SHADOW = {
		cc.DropShadowFilter,
		1
	},
	CUSTOM = {
		cc.CustomFilter,
		1
	}
}
local MULTI_FILTERS = {
	GAUSSIAN_BLUR = {}
}

function filter.newFilter(__filterName, __param)
	local __filterData = FILTERS[__filterName]

	assert(__filterData, "filter.newFilter() - filter " .. __filterName .. " is not found.")

	local __cls, __count, __default = unpack(__filterData)

	if __filterName == "CUSTOM" then
		return __cls:create(__param)
	end

	local __paramCount = __param and #__param or 0

	print("filter.newFilter:", __paramCount, __filterName, __count)
	print("filter.newFilter __param:", __param)

	if __count == nil then
		if __paramCount == 0 then
			return __cls:create()
		end
	elseif __count == 0 then
		return __cls:create()
	else
		if __paramCount == 0 then
			return __cls:create(unpack(__default))
		end

		assert(__paramCount == __count, string.format("filter.newFilter() - the parameters have a wrong amount! Expect %d, get %d.", __count, __paramCount))
	end

	return __cls:create(unpack(__param))
end

function filter.newFilters(__filterNames, __params)
	assert(#__filterNames == #__params, "filter.newFilters() - Please ensure the filters and the parameters have the same amount.")

	local __filters = {}

	for i in ipairs(__filterNames) do
		table.insert(__filters, filter.newFilter(__filterNames[i], __params[i]))
	end

	return __filters
end

return filter
