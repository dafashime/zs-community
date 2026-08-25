local display = {}
local sharedDirector = cc.Director:getInstance()
local sharedTextureCache = cc.Director:getInstance():getTextureCache()
local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local sharedAnimationCache = cc.AnimationCache:getInstance()
local glview = sharedDirector:getOpenGLView()

if glview == nil then
	glview = cc.GLViewImpl:createWithRect("QuickCocos", cc.rect(0, 0, CONFIG_SCREEN_WIDTH or 900, CONFIG_SCREEN_HEIGHT or 640))

	sharedDirector:setOpenGLView(glview)
end

local size = glview:getFrameSize()
display.sizeInPixels = {
	width = size.width,
	height = size.height
}
local w = display.sizeInPixels.width
local h = display.sizeInPixels.height

if CONFIG_SCREEN_WIDTH == nil or CONFIG_SCREEN_HEIGHT == nil then
	CONFIG_SCREEN_WIDTH = w
	CONFIG_SCREEN_HEIGHT = h
end

if not CONFIG_SCREEN_AUTOSCALE then
	if h < w then
		CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
	else
		CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
	end
else
	CONFIG_SCREEN_AUTOSCALE = string.upper(CONFIG_SCREEN_AUTOSCALE)
end

local scale, scaleX, scaleY = nil

if CONFIG_SCREEN_AUTOSCALE and CONFIG_SCREEN_AUTOSCALE ~= "NONE" then
	if type(CONFIG_SCREEN_AUTOSCALE_CALLBACK) == "function" then
		scaleX, scaleY = CONFIG_SCREEN_AUTOSCALE_CALLBACK(w, h, device.model)
	end

	if CONFIG_SCREEN_AUTOSCALE == "EXACT_FIT" then
		scale = 1

		glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.EXACT_FIT)
	elseif CONFIG_SCREEN_AUTOSCALE == "FILL_ALL" then
		CONFIG_SCREEN_WIDTH = w
		CONFIG_SCREEN_HEIGHT = h
		scale = 1

		if cc.bPlugin_ then
			glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)
		else
			glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.SHOW_ALL)
		end
	else
		if not scaleX or not scaleY then
			scaleY = h / CONFIG_SCREEN_HEIGHT
			scaleX = w / CONFIG_SCREEN_WIDTH
		end

		if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
			scale = scaleX
			CONFIG_SCREEN_HEIGHT = h / scale
		elseif CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
			scale = scaleY
			CONFIG_SCREEN_WIDTH = w / scale
		else
			scale = 1

			printError(string.format("display - invalid CONFIG_SCREEN_AUTOSCALE \"%s\"", CONFIG_SCREEN_AUTOSCALE))
		end

		glview:setDesignResolutionSize(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT, cc.ResolutionPolicy.NO_BORDER)
	end
else
	CONFIG_SCREEN_WIDTH = w
	CONFIG_SCREEN_HEIGHT = h
	scale = 1
end

local winSize = sharedDirector:getWinSize()
display.screenScale = 2
display.contentScaleFactor = scale
display.size = {
	width = winSize.width,
	height = winSize.height
}
display.width = display.size.width
display.height = display.size.height
display.cx = display.width / 2
display.cy = display.height / 2
display.c_left = -display.width / 2
display.c_right = display.width / 2
display.c_top = display.height / 2
display.c_bottom = -display.height / 2
display.left = 0
display.right = display.width
display.top = display.height
display.bottom = 0
display.widthInPixels = display.sizeInPixels.width
display.heightInPixels = display.sizeInPixels.height

printInfo(string.format("# CONFIG_SCREEN_AUTOSCALE      = %s", CONFIG_SCREEN_AUTOSCALE))
printInfo(string.format("# CONFIG_SCREEN_WIDTH          = %0.2f", CONFIG_SCREEN_WIDTH))
printInfo(string.format("# CONFIG_SCREEN_HEIGHT         = %0.2f", CONFIG_SCREEN_HEIGHT))
printInfo(string.format("# display.widthInPixels        = %0.2f", display.widthInPixels))
printInfo(string.format("# display.heightInPixels       = %0.2f", display.heightInPixels))
printInfo(string.format("# display.contentScaleFactor   = %0.2f", display.contentScaleFactor))
printInfo(string.format("# display.width                = %0.2f", display.width))
printInfo(string.format("# display.height               = %0.2f", display.height))
printInfo(string.format("# display.cx                   = %0.2f", display.cx))
printInfo(string.format("# display.cy                   = %0.2f", display.cy))
printInfo(string.format("# display.left                 = %0.2f", display.left))
printInfo(string.format("# display.right                = %0.2f", display.right))
printInfo(string.format("# display.top                  = %0.2f", display.top))
printInfo(string.format("# display.bottom               = %0.2f", display.bottom))
printInfo(string.format("# display.c_left               = %0.2f", display.c_left))
printInfo(string.format("# display.c_right              = %0.2f", display.c_right))
printInfo(string.format("# display.c_top                = %0.2f", display.c_top))
printInfo(string.format("# display.c_bottom             = %0.2f", display.c_bottom))
printInfo("#")

display.COLOR_WHITE = cc.c3b(255, 255, 255)
display.COLOR_BLACK = cc.c3b(0, 0, 0)
display.COLOR_RED = cc.c3b(255, 0, 0)
display.COLOR_GREEN = cc.c3b(0, 255, 0)
display.COLOR_BLUE = cc.c3b(0, 0, 255)
display.AUTO_SIZE = 0
display.FIXED_SIZE = 1
display.LEFT_TO_RIGHT = 0
display.RIGHT_TO_LEFT = 1
display.TOP_TO_BOTTOM = 2
display.BOTTOM_TO_TOP = 3
display.CENTER = 1
display.LEFT_TOP = 2
display.TOP_LEFT = 2
display.CENTER_TOP = 3
display.TOP_CENTER = 3
display.RIGHT_TOP = 4
display.TOP_RIGHT = 4
display.CENTER_LEFT = 5
display.LEFT_CENTER = 5
display.CENTER_RIGHT = 6
display.RIGHT_CENTER = 6
display.BOTTOM_LEFT = 7
display.LEFT_BOTTOM = 7
display.BOTTOM_RIGHT = 8
display.RIGHT_BOTTOM = 8
display.BOTTOM_CENTER = 9
display.CENTER_BOTTOM = 9
display.ANCHOR_POINTS = {
	cc.p(0.5, 0.5),
	cc.p(0, 1),
	cc.p(0.5, 1),
	cc.p(1, 1),
	cc.p(0, 0.5),
	cc.p(1, 0.5),
	cc.p(0, 0),
	cc.p(1, 0),
	cc.p(0.5, 0)
}
display.SCENE_TRANSITIONS = {
	CROSSFADE = {
		cc.TransitionCrossFade,
		2
	},
	FADE = {
		cc.TransitionFade,
		3,
		cc.c3b(0, 0, 0)
	},
	FADEBL = {
		cc.TransitionFadeBL,
		2
	},
	FADEDOWN = {
		cc.TransitionFadeDown,
		2
	},
	FADETR = {
		cc.TransitionFadeTR,
		2
	},
	FADEUP = {
		cc.TransitionFadeUp,
		2
	},
	FLIPANGULAR = {
		cc.TransitionFlipAngular,
		3,
		cc.TRANSITION_ORIENTATION_LEFT_OVER
	},
	FLIPX = {
		cc.TransitionFlipX,
		3,
		cc.TRANSITION_ORIENTATION_LEFT_OVER
	},
	FLIPY = {
		cc.TransitionFlipY,
		3,
		cc.TRANSITION_ORIENTATION_UP_OVER
	},
	JUMPZOOM = {
		cc.TransitionJumpZoom,
		2
	},
	MOVEINB = {
		cc.TransitionMoveInB,
		2
	},
	MOVEINL = {
		cc.TransitionMoveInL,
		2
	},
	MOVEINR = {
		cc.TransitionMoveInR,
		2
	},
	MOVEINT = {
		cc.TransitionMoveInT,
		2
	},
	PAGETURN = {
		cc.TransitionPageTurn,
		3,
		false
	},
	ROTOZOOM = {
		cc.TransitionRotoZoom,
		2
	},
	SHRINKGROW = {
		cc.TransitionShrinkGrow,
		2
	},
	SLIDEINB = {
		cc.TransitionSlideInB,
		2
	},
	SLIDEINL = {
		cc.TransitionSlideInL,
		2
	},
	SLIDEINR = {
		cc.TransitionSlideInR,
		2
	},
	SLIDEINT = {
		cc.TransitionSlideInT,
		2
	},
	SPLITCOLS = {
		cc.TransitionSplitCols,
		2
	},
	SPLITROWS = {
		cc.TransitionSplitRows,
		2
	},
	TURNOFFTILES = {
		cc.TransitionTurnOffTiles,
		2
	},
	ZOOMFLIPANGULAR = {
		cc.TransitionZoomFlipAngular,
		2
	},
	ZOOMFLIPX = {
		cc.TransitionZoomFlipX,
		3,
		cc.TRANSITION_ORIENTATION_LEFT_OVER
	},
	ZOOMFLIPY = {
		cc.TransitionZoomFlipY,
		3,
		cc.TRANSITION_ORIENTATION_UP_OVER
	}
}
display.TEXTURES_PIXEL_FORMAT = {}
display.DEFAULT_TTF_FONT = "STHeitiSC"
display.DEFAULT_TTF_FONT_SIZE = 24

function display.newScene(name)
	local scene = cc.Scene:create()

	scene:setNodeEventEnabled(true)
	scene:setAutoCleanupEnabled()

	scene.name = name or "<unknown-scene>"

	return scene
end

function display.newPhysicsScene(name)
	local scene = cc.Scene:createWithPhysics()

	scene:setNodeEventEnabled(true)
	scene:setAutoCleanupEnabled()

	scene.name = name or "<unknown-scene>"

	return scene
end

function display.wrapSceneWithTransition(scene, transitionType, time, more)
	local key = string.upper(tostring(transitionType))

	if string.sub(key, 1, 12) == "CCTRANSITION" then
		key = string.sub(key, 13)
	end

	if key == "RANDOM" then
		local keys = table.keys(display.SCENE_TRANSITIONS)
		key = keys[math.random(1, #keys)]
	end

	if display.SCENE_TRANSITIONS[key] then
		local cls, count, default = unpack(display.SCENE_TRANSITIONS[key])
		time = time or 0.2

		if count == 3 then
			scene = cls:create(time, scene, more or default)
		else
			scene = cls:create(time, scene)
		end
	else
		printError("display.wrapSceneWithTransition() - invalid transitionType %s", tostring(transitionType))
	end

	return scene
end

function display.replaceScene(newScene, transitionType, time, more)
	newScene:setNodeEventEnabled(true)

	local s = display.newScene()

	s:addChild(newScene)

	s.s = newScene

	if sharedDirector:getRunningScene() then
		if transitionType then
			s = display.wrapSceneWithTransition(s, transitionType, time, more)
		end

		sharedDirector:replaceScene(s)
	else
		sharedDirector:runWithScene(s)
	end
end

function display.getRunningScene()
	return sharedDirector:getRunningScene().s
end

function display.pause()
	sharedDirector:pause()
end

function display.resume()
	sharedDirector:resume()
end

function display.newLayer()
	local layer = nil

	if cc.bPlugin_ then
		layer = display.newNode()

		layer:setContentSize(display.width, display.height)
		layer:setTouchEnabled(true)
	else
		layer = cc.Layer:create()
	end

	return layer
end

function display.newColorLayer(color)
	local node = nil

	if cc.bPlugin_ then
		node = display.newNode()
		local layer = cc.LayerColor:create(color)

		node:addChild(layer)
		node:setTouchEnabled(true)
		node:setTouchSwallowEnabled(true)

		function node.setContentSize(_, ...)
			layer:setContentSize(...)
		end

		function node.getContentSize()
			return layer:getContentSize()
		end

		return node
	end

	node = cc.LayerColor:create(color)
	return node
end

function display.newNode()
	return cc.Node:create()
end

if cc.ClippingRectangleNode then
	cc.ClippingRegionNode = cc.ClippingRectangleNode
else
	cc.ClippingRectangleNode = cc.ClippingRegionNode
end

function display.newClippingRectangleNode(rect)
	if rect then
		return cc.ClippingRegionNode:create(rect)
	else
		return cc.ClippingRegionNode:create()
	end
end

display.newClippingRegionNode = display.newClippingRectangleNode

function display.newSprite(filename, x, y, params)
	local spriteClass, size = nil

	if params then
		spriteClass = params.class
		size = params.size
	end

	spriteClass = spriteClass or cc.Sprite
	local t = type(filename)

	if t == "userdata" then
		t = tolua.type(filename)
	end

	local sprite = nil

	if not filename then
		sprite = spriteClass:create()
	elseif t == "string" then
		if string.byte(filename) == 35 then
			local frame = display.newSpriteFrame(string.sub(filename, 2))

			if frame then
				if params and params.capInsets then
					sprite = spriteClass:createWithSpriteFrame(frame, params.capInsets)
				else
					sprite = spriteClass:createWithSpriteFrame(frame)
				end
			end
		elseif display.TEXTURES_PIXEL_FORMAT[filename] then
			cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[filename])

			sprite = spriteClass:create(filename)

			cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)
		elseif params and params.capInsets then
			sprite = spriteClass:create(params.capInsets, filename)
		else
			sprite = spriteClass:create(filename)
		end
	elseif t == "cc.SpriteFrame" then
		sprite = spriteClass:createWithSpriteFrame(filename)
	elseif t == "cc.Texture2D" then
		sprite = spriteClass:createWithTexture(filename)
	else
		printError("display.newSprite() - invalid filename value type" .. t)

		sprite = spriteClass:create()
	end

	if sprite then
		if x and y then
			sprite:setPosition(x, y)
		end

		if size then
			sprite:setContentSize(size)
		end
	else
		printError("display.newSprite() - create sprite failure, filename %s", tostring(filename))

		sprite = spriteClass:create()
	end

	return sprite
end

function display.newScale9Sprite(filename, x, y, size, capInsets)
	local scale9sp = ccui.Scale9Sprite or cc.Scale9Sprite

	return display.newSprite(filename, x, y, {
		class = scale9sp,
		size = size,
		capInsets = capInsets
	})
end

function display.newTilesSprite(filename, rect)
	rect = rect or cc.rect(0, 0, display.width, display.height)
	local sprite = cc.Sprite:create(filename, rect)

	if not sprite then
		printError("display.newTilesSprite() - create sprite failure, filename %s", tostring(filename))

		return
	end

	sprite:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
	display.align(sprite, display.LEFT_BOTTOM, 0, 0)

	return sprite
end

function display.newTiledBatchNode(filename, plistFile, size, hPadding, vPadding)
	size = size or cc.size(display.width, display.height)
	hPadding = hPadding or 0
	vPadding = vPadding or 0
	local __sprite = display.newSprite(filename)
	local __sliceSize = __sprite:getContentSize()
	__sliceSize.width = __sliceSize.width - hPadding
	__sliceSize.height = __sliceSize.height - vPadding
	local __xRepeat = math.ceil(size.width / __sliceSize.width)
	local __yRepeat = math.ceil(size.height / __sliceSize.height)
	local __capacity = __xRepeat * __yRepeat
	local __batch = display.newBatchNode(plistFile, __capacity)
	local __newSize = cc.size(0, 0)

	for y = 0, __yRepeat - 1 do
		for x = 0, __xRepeat - 1 do
			__newSize.width = __newSize.width + __sliceSize.width
			__sprite = display.newSprite(filename):align(display.LEFT_BOTTOM, x * __sliceSize.width, y * __sliceSize.height):addTo(__batch)
		end

		__newSize.height = __newSize.height + __sliceSize.height
	end

	__batch:setContentSize(__newSize)

	return __batch, __newSize.width, __newSize.height
end

function display.newFilteredSprite(filename, filters, params)
	local __one = {
		class = cc.FilteredSpriteWithOne
	}
	local __multi = {
		class = cc.FilteredSpriteWithMulti
	}

	if not filters then
		return display.newSprite(filename, nil, nil, __one)
	end

	local __sp = nil
	local __type = type(filters)

	if __type == "userdata" then
		__type = tolua.type(filters)
	end

	if __type == "string" then
		__sp = display.newSprite(filename, nil, nil, __one)
		filters = filter.newFilter(filters, params)

		__sp:setFilter(filters)
	elseif __type == "table" then
		assert(#filters > 1, "display.newFilteredSprite() - Please give me 2 or more filters!")

		__sp = display.newSprite(filename, nil, nil, __multi)

		if type(filters[1]) == "string" then
			__sp:setFilters(filter.newFilters(filters, params))
		else
			local __filters = cc.Array:create()

			for i in ipairs(filters) do
				__filters:addObject(filters[i])
			end

			__sp:setFilters(__filters)
		end
	elseif __type == "Array" then
		__sp = display.newSprite(filename, nil, nil, __multi)

		__sp:setFilters(filters)
	else
		__sp = display.newSprite(filename, nil, nil, __one)

		__sp:setFilter(filters)
	end

	return __sp
end

function display.newGraySprite(filename, params)
	return display.newFilteredSprite(filename, "GRAY", params)
end

function display.newDrawNode()
	return cc.DrawNode:create()
end

function display.newSolidCircle(radius, params)
	local circle = display.newDrawNode()

	circle:drawDot(cc.p(params.x or 0, params.y or 0), radius or 0, params.color or cc.c4f(0, 0, 0, 1))

	return circle
end

function display.newCircle(radius, params)
	params = checktable(params)

	local function makeVertexs(radius)
		local segments = params.segments or 32
		local startRadian = 0
		local endRadian = math.pi * 2
		local posX = params.x or 0
		local posY = params.y or 0

		if params.startAngle then
			startRadian = math.angle2radian(params.startAngle)
		end

		if params.endAngle then
			endRadian = startRadian + math.angle2radian(params.endAngle)
		end

		local radianPerSegm = 2 * math.pi / segments
		local points = {}

		for i = 1, segments do
			local radii = startRadian + i * radianPerSegm

			if endRadian < radii then
				break
			end

			points[#points + 1] = {
				posX + radius * math.cos(radii),
				posY + radius * math.sin(radii)
			}
		end

		return points
	end

	local points = makeVertexs(radius)
	local circle = display.newPolygon(points, params)

	if circle then
		circle.radius = radius
		circle.params = params

		function circle:setRadius(radius)
			self:clear()

			local points = makeVertexs(radius)

			display.newPolygon(points, params, self)
		end

		function circle:setLineColor(color)
			self:clear()

			local points = makeVertexs(radius)
			params.borderColor = color

			display.newPolygon(points, params, self)
		end
	end

	return circle
end

function display.newRect(rect, params)
	local x = 0
	local y = 0
	local width, height = nil
	x = rect.x or 0
	y = rect.y or 0
	height = rect.height
	width = rect.width
	local points = {
		{
			x,
			y
		},
		{
			x + width,
			y
		},
		{
			x + width,
			y + height
		},
		{
			x,
			y + height
		}
	}

	return display.newPolygon(points, params)
end

function display.newLine(points, params)
	local radius, borderColor, scale = nil

	if not params then
		borderColor = cc.c4f(0, 0, 0, 1)
		radius = 0.5
		scale = 1
	else
		borderColor = params.borderColor or cc.c4f(0, 0, 0, 1)
		radius = params.borderWidth and params.borderWidth / 2 or 0.5
		scale = checknumber(params.scale or 1)
	end

	for i, p in ipairs(points) do
		p = cc.p(p[1] * scale, p[2] * scale)
		points[i] = p
	end

	local drawNode = cc.DrawNode:create()

	drawNode:drawSegment(points[1], points[2], radius, borderColor)

	return drawNode
end

function display.newPolygon(points, params, drawNode)
	params = checktable(params)
	local scale = checknumber(params.scale or 1)
	local borderWidth = checknumber(params.borderWidth or 0.5)
	local fillColor = params.fillColor or cc.c4f(1, 1, 1, 0)
	local borderColor = params.borderColor or cc.c4f(0, 0, 0, 1)
	local pts = {}

	for i, p in ipairs(points) do
		pts[i] = {
			x = p[1] * scale,
			y = p[2] * scale
		}
	end

	drawNode = drawNode or cc.DrawNode:create()

	drawNode:drawPolygon(pts, {
		fillColor = fillColor,
		borderWidth = borderWidth,
		borderColor = borderColor
	})

	if drawNode then
		function drawNode:setLineStipple()
		end

		function drawNode:setLineStippleEnabled()
		end

		function drawNode:setLineColor(color)
		end
	end

	return drawNode
end

function display.newBMFontLabel(params)
	assert(type(params) == "table", "[framework.display] newBMFontLabel() invalid params")

	local text = tostring(params.text)
	local font = params.font
	local textAlign = params.align or cc.TEXT_ALIGNMENT_LEFT
	local maxLineW = params.maxLineWidth or 0
	local offsetX = params.offsetX or 0
	local offsetY = params.offsetY or 0
	local x = params.x
	local y = params.y

	assert(font ~= nil, "framework.display.newBMFontLabel() - not set font")

	local label = cc.Label:createWithBMFont(font, text, textAlign, maxLineW, cc.p(offsetX, offsetY))

	if not label then
		return
	end

	if type(x) == "number" and type(y) == "number" then
		label:setPosition(x, y)
	end

	return label
end

function display.newTTFLabel(params)
	assert(type(params) == "table", "[framework.display] newTTFLabel() invalid params")

	local text = tostring(params.text)
	local font = params.font or display.DEFAULT_TTF_FONT
	local size = params.size or display.DEFAULT_TTF_FONT_SIZE
	local color = params.color or display.COLOR_WHITE
	local textAlign = params.align or cc.TEXT_ALIGNMENT_LEFT
	local textValign = params.valign or cc.VERTICAL_TEXT_ALIGNMENT_TOP
	local x = params.x
	local y = params.y
	local dimensions = params.dimensions or cc.size(0, 0)

	assert(type(size) == "number", "[framework.display] newTTFLabel() invalid params.size")

	local label = nil

	if cc.FileUtils:getInstance():isFileExist(font) then
		label = cc.Label:createWithTTF(text, font, size, dimensions, textAlign, textValign)

		if label then
			label:setColor(color)
		end

		if params.outline then
			params.outline.color.a = 255

			label:enableOutline(params.outline.color, params.outline.size)
		end
	else
		label = cc.Label:createWithSystemFont(text, font, size, dimensions, textAlign, textValign)

		if label then
			label:setTextColor(color)
		end
	end

	if label and x and y then
		label:setPosition(x, y)
	end

	return label
end

function display.align(target, anchorPoint, x, y)
	target:setAnchorPoint(display.ANCHOR_POINTS[anchorPoint])

	if x and y then
		target:setPosition(x, y)
	end
end

function display.addImageAsync(imagePath, callback)
	sharedTextureCache:addImageAsync(imagePath, callback)
end

function display.addSpriteFrames(plistFilename, image, handler)
	local async = type(handler) == "function"
	local asyncHandler = nil

	if async then
		function asyncHandler()
			local texture = sharedTextureCache:getTextureForKey(image)

			assert(texture, string.format("The texture %s, %s is unavailable.", plistFilename, image))
			sharedSpriteFrameCache:addSpriteFrames(plistFilename, texture)
			handler(plistFilename, image)
		end
	end

	if display.TEXTURES_PIXEL_FORMAT[image] then
		cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[image])

		if async then
			sharedTextureCache:addImageAsync(image, asyncHandler)
		else
			sharedSpriteFrameCache:addSpriteFrames(plistFilename, image)
		end

		cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)
	elseif async then
		sharedTextureCache:addImageAsync(image, asyncHandler)
	else
		sharedSpriteFrameCache:addSpriteFrames(plistFilename, image)
	end
end

function display.removeSpriteFramesWithFile(plistFilename, imageName)
	sharedSpriteFrameCache:removeSpriteFramesFromFile(plistFilename)

	if imageName then
		display.removeSpriteFrameByImageName(imageName)
	end
end

function display.setTexturePixelFormat(filename, format)
	display.TEXTURES_PIXEL_FORMAT[filename] = format
end

function display.removeSpriteFrameByImageName(imageName)
	sharedSpriteFrameCache:removeSpriteFrameByName(imageName)
	cc.Director:getInstance():getTextureCache():removeTextureForKey(imageName)
end

function display.newBatchNode(image, capacity)
	return cc.SpriteBatchNode:create(image, capacity or 100)
end

function display.newSpriteFrame(frameName)
	local frame = sharedSpriteFrameCache:getSpriteFrame(frameName)

	if not frame then
		printError("display.newSpriteFrame() - invalid frameName %s", tostring(frameName))
	end

	return frame
end

function display.newFrames(pattern, begin, length, isReversed)
	local frames = {}
	local step = 1
	local last = begin + length - 1

	if isReversed then
		begin = last
		last = begin
		step = -1
	end

	for index = begin, last, step do
		local frameName = string.format(pattern, index)
		local frame = sharedSpriteFrameCache:getSpriteFrame(frameName)

		if not frame then
			printError("display.newFrames() - invalid frame, name %s", tostring(frameName))

			return
		end

		frames[#frames + 1] = frame
	end

	return frames
end

function display.newAnimation(frames, time)
	local count = #frames
	time = time or 1 / count

	return cc.Animation:createWithSpriteFrames(frames, time)
end

function display.setAnimationCache(name, animation)
	sharedAnimationCache:addAnimation(animation, name)
end

function display.getAnimationCache(name)
	return sharedAnimationCache:getAnimation(name)
end

function display.removeAnimationCache(name)
	sharedAnimationCache:removeAnimation(name)
end

function display.removeUnusedSpriteFrames()
	sharedSpriteFrameCache:removeUnusedSpriteFrames()
	sharedTextureCache:removeUnusedTextures()
end

display.PROGRESS_TIMER_BAR = 1
display.PROGRESS_TIMER_RADIAL = 0

function display.newProgressTimer(image, progresssType)
	if type(image) == "string" then
		image = display.newSprite(image)
	end

	local progress = cc.ProgressTimer:create(image)

	progress:setType(progresssType)

	return progress
end

function display.captureScreen(callback, fileName)
	cc.utils:captureScreen(callback, fileName)
end

return display
