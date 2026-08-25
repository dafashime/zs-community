local UILoaderUtilitys = import(".UILoaderUtilitys")
local CCSUILoader = class("CCSUILoader")

function CCSUILoader:load(json, params)
	if params then
		self.bUseEditBox = params.bUseEditBox or false
	else
		self.bUseEditBox = false
	end

	if cc.bPlugin_ and self.bUseEditBox then
		self.bUseEditBox = false

		print("Error! not support CCEditbox in cocostudio layout file")
	end

	self.texturesPng = json.texturesPng

	self:loadTexture(json)

	local node, bAdaptScreen = self:parserJson(json)
	self.texturesPng = nil

	if bAdaptScreen then
		return node, display.width, display.height
	else
		return node, json.designWidth, json.designHeight
	end
end

function CCSUILoader:loadFile(jsonFile, params)
	local fileUtil = cc.FileUtils:getInstance()
	local fullPath = fileUtil:fullPathForFilename(jsonFile)
	local jsonStr = fileUtil:getStringFromFile(fullPath)
	local jsonVal = json.decode(jsonStr)

	UILoaderUtilitys.addSearchPathIf(io.pathinfo(fullPath).dirname)

	local node, w, h = self:load(jsonVal, params)

	UILoaderUtilitys.clearPath()

	return node, w, h
end

function CCSUILoader:parserJson(jsonVal)
	local root = jsonVal.nodeTree
	root = root or jsonVal.widgetTree

	if not root then
		printInfo("CCSUILoader - parserJson havn't found root node")

		return
	end

	self:prettyJson(root)

	local uiRoot = self:generateUINode(root)

	return uiRoot, root.options.adaptScreen
end

function CCSUILoader:generateUINode(jsonNode, transX, transY, parent)
	transX = transX or 0
	transY = transY or 0
	local clsName = jsonNode.classname
	local options = jsonNode.options
	options.x = options.x or 0
	options.y = options.y or 0
	options.x = options.x + transX
	options.y = options.y + transY
	local uiNode = self:createUINode(clsName, options, parent)

	if not uiNode then
		return
	end

	self:modifyPanelChildPos_(clsName, options.adaptScreen, options.sizeType, uiNode:getContentSize(), jsonNode.children)

	local posTrans = uiNode:getAnchorPoint()
	local parentSize = uiNode:getContentSize()
	posTrans.x = posTrans.x * parentSize.width
	posTrans.y = posTrans.y * parentSize.height
	uiNode.name = options.name or "unknow node"
	uiNode.subChildren = {}

	if parent then
		parent.subChildren[uiNode.name] = uiNode
	end

	if options.fileName then
		uiNode:setSpriteFrame(options.fileName)
	end

	if options.flipX and uiNode.setFlippedX then
		uiNode:setFlippedX(options.flipX)
	end

	if options.flipY and uiNode.setFlippedY then
		uiNode:setFlippedY(options.flipY)
	end

	uiNode:setRotation(options.rotation or 0)
	uiNode:setScaleX((options.scaleX or 1) * uiNode:getScaleX())
	uiNode:setScaleY((options.scaleY or 1) * uiNode:getScaleY())
	uiNode:setVisible(options.visible)
	uiNode:setLocalZOrder(options.ZOrder or 0)
	uiNode:setTag(options.tag or 0)

	local emptyNode = nil

	if clsName == "ScrollView" then
		emptyNode = cc.Node:create()

		emptyNode:setPosition(options.x, options.y)
		uiNode:addScrollNode(emptyNode)
	end

	local children = jsonNode.children

	for i, v in ipairs(children) do
		local childrenNode = self:generateUINode(v, posTrans.x, posTrans.y, uiNode)

		if childrenNode then
			if clsName == "ScrollView" then
				emptyNode:addChild(childrenNode)
			elseif clsName == "ListView" then
				local item = uiNode:newItem()

				item:addContent(childrenNode)

				local size = childrenNode:getContentSize()

				item:setItemSize(size.width, size.height)
				uiNode:addItem(item)

				if v.classname == "Button" then
					children:setTouchSwallowEnabled(false)
				end
			elseif clsName == "PageView" then
				local item = uiNode:newItem()

				childrenNode:setPosition(0, 0)
				item:addChild(childrenNode)
				item:setTag(10001)
				uiNode:addItem(item)
			else
				uiNode:addChild(childrenNode)
			end
		end
	end

	if clsName == "ListView" or clsName == "PageView" then
		uiNode:reload()
	elseif clsName == "ScrollView" then
		uiNode:resetPosition()
	end

	return uiNode
end

function CCSUILoader:createUINode(clsName, options, parent)
	if not clsName then
		return
	end

	local node = nil

	if clsName == "Node" then
		node = self:createNode(options)
	elseif clsName == "Sprite" or clsName == "Scale9Sprite" then
		node = self:createSprite(options)
	elseif clsName == "ImageView" then
		node = self:createImage(options)
	elseif clsName == "Button" then
		node = self:createButton(options)
	elseif clsName == "LoadingBar" then
		node = self:createLoadingBar(options)
	elseif clsName == "Slider" then
		node = self:createSlider(options)
	elseif clsName == "CheckBox" then
		node = self:createCheckBox(options)
	elseif clsName == "LabelBMFont" then
		node = self:createBMFontLabel(options)
	elseif clsName == "Label" then
		node = self:createLabel(options)
	elseif clsName == "LabelAtlas" then
		node = self:createLabelAtlas(options)
	elseif clsName == "TextField" then
		node = self:createEditBox(options)
	elseif clsName == "Panel" then
		node = self:createPanel(options)
	elseif clsName == "ScrollView" then
		node = self:createScrollView(options)
	elseif clsName == "ListView" then
		node = self:createListView(options)
	elseif clsName == "PageView" then
		node = self:createPageView(options)
	else
		printInfo("CCSUILoader not support node:" .. clsName)
	end

	return node
end

function CCSUILoader:getChildOptionJson(json)
	return json.options.layoutParameter
end

function CCSUILoader:newWapperNode(oldNode, layoutParameter)
	local newNode = display.newNode()
	local size = oldNode:getContentSize()
	size.width = size.width + layoutParameter.marginLeft + layoutParameter.marginRight
	size.height = size.height + layoutParameter.marginTop + layoutParameter.marginDown

	newNode:setContentSize(size)
	newNode:addChild(oldNode)
	oldNode:setPosition()
end

function CCSUILoader:getButtonStateImages(options)
	local images = {}

	if options.normalData and options.normalData.path then
		images.normal = self:transResName(options.normalData)
	end

	if options.pressedData and options.pressedData.path then
		images.pressed = self:transResName(options.pressedData)
	end

	if options.disabledData and options.disabledData.path then
		images.disabled = self:transResName(options.disabledData)
	end

	return images
end

function CCSUILoader:getAnchorType(anchorX, anchorY)
	if anchorX == 1 then
		if anchorY == 1 then
			return display.RIGHT_TOP
		elseif anchorY == 0.5 then
			return display.RIGHT_CENTER
		else
			return display.RIGHT_BOTTOM
		end
	elseif anchorX == 0.5 then
		if anchorY == 1 then
			return display.CENTER_TOP
		elseif anchorY == 0.5 then
			return display.CENTER
		else
			return display.CENTER_BOTTOM
		end
	elseif anchorY == 1 then
		return display.LEFT_TOP
	elseif anchorY == 0.5 then
		return display.LEFT_CENTER
	else
		return display.LEFT_BOTTOM
	end
end

function CCSUILoader:getCheckBoxImages(options)
	local images = {}

	local function getBackgroundImage(state)
		local image = options.backGroundBoxData

		if state == "pressed" then
			image = options.backGroundBoxSelectedData
		elseif state == "disabled" then
			image = options.backGroundBoxDisabledData
		end

		return image
	end

	images.off = self:transResName(getBackgroundImage("normal"))
	images.off_pressed = self:transResName(getBackgroundImage("pressed"))
	images.off_disabled = self:transResName(getBackgroundImage("disabled"))
	images.on = {
		images.off,
		self:transResName(options.frontCrossData)
	}
	images.on_pressed = images.on
	images.on_disabled = {
		images.off_disabled,
		self:transResName(options.frontCrossDisabledData)
	}

	return images
end

function CCSUILoader:loadTexture(json)
	for i, v in ipairs(json.textures) do
		self.bUseTexture = true

		UILoaderUtilitys.loadTexture(v)
	end
end

function CCSUILoader:getTexturePng(plist)
	if not plist then
		return
	end

	local info = io.pathinfo(plist)
	local png = nil

	if info.dirname then
		png = info.dirname .. info.basename .. ".png"
	else
		png = info.basename .. ".png"
	end

	return png
end

function CCSUILoader:transResName(fileData)
	if not fileData then
		return
	end

	local name = fileData.path

	if not name then
		return name
	end

	UILoaderUtilitys.loadTexture(fileData.plistFile)

	if fileData.resourceType == 1 then
		return "#" .. name
	else
		return UILoaderUtilitys.getFileFullName(name)
	end
end

function CCSUILoader:createNode(options)
	local node = cc.Node:create()

	if not options.ignoreSize then
		node:setContentSize(cc.size(options.width or 0, options.height or 0))
	end

	node:setPositionX(options.x or 0)
	node:setPositionY(options.y or 0)
	node:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	return node
end

function CCSUILoader:createSprite(options)
	local node = cc.Sprite:create()

	if not options.ignoreSize then
		node:setContentSize(cc.size(options.width, options.height))
	end

	if options.opacity then
		node:setOpacity(options.opacity)
	end

	node:setPositionX(options.x or 0)
	node:setPositionY(options.y or 0)
	node:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	return node
end

function CCSUILoader:createImage(options)
	local params = {
		scale9 = options.scale9Enable
	}

	if params.scale9 then
		params.capInsets = cc.rect(options.capInsetsX, options.capInsetsY, options.capInsetsWidth, options.capInsetsHeight)
	end

	local node = cc.ui.UIImage.new(self:transResName(options.fileNameData), params)

	if not options.scale9Enable then
		local originSize = node:getContentSize()

		if options.width then
			options.scaleX = (options.scaleX or 1) * options.width / originSize.width
		end

		if options.height then
			options.scaleY = (options.scaleY or 1) * options.height / originSize.height
		end
	end

	if not options.ignoreSize then
		node:setLayoutSize(options.width, options.height)

		options.scaleX = 1
		options.scaleY = 1
	end

	node:setPositionX(options.x or 0)
	node:setPositionY(options.y or 0)
	node:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	if options.touchAble then
		node:setTouchEnabled(true)
		node:setTouchSwallowEnabled(true)
	end

	if options.opacity then
		node:setOpacity(options.opacity)
	end

	return node
end

function CCSUILoader:createButton(options)
	local node = cc.ui.UIPushButton.new(self:getButtonStateImages(options), {
		scale9 = options.scale9Enable,
		flipX = options.flipX,
		flipY = options.flipY
	})

	if options.opacity then
		node:setCascadeOpacityEnabled(true)
		node:setOpacity(options.opacity)
	end

	if options.text then
		node:setButtonLabel(cc.ui.UILabel.new({
			text = options.text,
			size = options.fontSize,
			font = options.fontName,
			color = cc.c3b(options.textColorR, options.textColorG, options.textColorB)
		}))
	end

	if not options.ignoreSize then
		node:setButtonSize(options.width, options.height)
	end

	node:align(self:getAnchorType(options.anchorPointX or 0.5, options.anchorPointY or 0.5), options.x or 0, options.y or 0)

	return node
end

function CCSUILoader:createLoadingBar(options)
	local params = {
		image = self:transResName(options.textureData),
		scale9 = options.scale9Enable,
		capInsets = cc.rect(options.capInsetsX, options.capInsetsY, options.capInsetsWidth, options.capInsetsHeight),
		direction = options.direction,
		percent = options.percent or 100,
		viewRect = cc.rect(options.x, options.y, options.width, options.height)
	}
	local node = cc.ui.UILoadingBar.new(params)

	node:setDirction(options.direction)
	node:setPositionX(options.x or 0)
	node:setPositionY(options.y or 0)
	node:setContentSize(options.width, options.height)
	node:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	return node
end

function CCSUILoader:createSlider(options)
	local node = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, {
		bar = self:transResName(options.barFileNameData),
		barfg = self:transResName(options.progressBarData),
		button = self:transResName(options.ballNormalData),
		button_pressed = self:transResName(options.ballPressedData),
		button_disabled = self:transResName(options.ballDisabledData)
	}, {
		scale9 = options.scale9Enable
	})

	if not options.ignoreSize then
		node:setSliderSize(options.width, options.height)
	end

	node:align(self:getAnchorType(options.anchorPointX, options.anchorPointY), options.x or 0, options.y or 0)
	node:setSliderValue(options.percent)

	return node
end

function CCSUILoader:createCheckBox(options)
	local node = cc.ui.UICheckBoxButton.new(self:getCheckBoxImages(options), {
		scale9 = not options.ignoreSize
	})

	if not options.ignoreSize then
		node:setButtonSize(options.width, options.height)
	end

	node:align(self:getAnchorType(options.anchorPointX or 0.5, options.anchorPointY or 0.5), options.x or 0, options.y or 0)

	return node
end

function CCSUILoader:createBMFontLabel(options)
	local node = cc.ui.UILabel.new({
		UILabelType = 1,
		text = options.text,
		font = options.fileNameData.path,
		textAlign = cc.ui.TEXT_ALIGN_CENTER
	})

	node:align(self:getAnchorType(options.anchorPointX or 0.5, options.anchorPointY or 0.5), options.x or 0, options.y or 0)

	return node
end

function CCSUILoader:createLabel(options)
	local node = cc.ui.UILabel.new({
		text = options.text,
		font = options.fontName,
		size = options.fontSize,
		color = cc.c3b(options.colorR or 255, options.colorG or 255, options.colorB or 255),
		align = options.hAlignment,
		valign = options.vAlignment,
		dimensions = cc.size(options.areaWidth or 0, options.areaHeight or 0),
		x = options.x,
		y = options.y
	})

	if not options.ignoreSize then
		node:setLayoutSize(options.areaWidth, options.areaHeight)
	end

	node:align(self:getAnchorType(options.anchorPointX or 0.5, options.anchorPointY or 0.5), options.x or 0, options.y or 0)

	return node
end

function CCSUILoader:createLabelAtlas(options)
	local labelAtlas = nil

	if type(cc.LabelAtlas._create) == "function" then
		labelAtlas = cc.LabelAtlas:_create()

		labelAtlas:initWithString(options.stringValue, options.charMapFileData.path, options.itemWidth, options.itemHeight, string.byte(options.startCharMap))
	else
		labelAtlas = cc.LabelAtlas:create(options.stringValue, options.charMapFileData.path, options.itemWidth, options.itemHeight, string.byte(options.startCharMap))
	end

	labelAtlas:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))
	labelAtlas:setPosition(options.x, options.y)

	if not options.ignoreSize then
		labelAtlas:setContentSize(options.width, options.height)
	end

	return labelAtlas
end

function CCSUILoader:createEditBox(options)
	local editBox = nil

	if self.bUseEditBox then
		editBox = cc.ui.UIInput.new({
			UIInputType = 1,
			size = cc.size(options.width, options.height)
		})

		editBox:setPlaceHolder(options.placeHolder)
		editBox:setFontName(options.fontName)
		editBox:setFontSize(options.fontSize or 20)
		editBox:setText(options.text)

		if options.passwordEnable then
			editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		end

		if options.maxLengthEnable then
			editBox:setMaxLength(options.maxLength)
		end

		editBox:setPosition(options.x, options.y)
	else
		if not options.maxLengthEnable then
			options.maxLength = 0
		end

		editBox = cc.ui.UIInput.new({
			UIInputType = 2,
			placeHolder = options.placeHolder,
			x = options.x,
			y = options.y,
			text = options.text,
			size = cc.size(options.width, options.height),
			passwordEnable = options.passwordEnable,
			font = options.fontName,
			fontSize = options.fontSize,
			maxLength = options.maxLength
		})
	end

	editBox:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	return editBox
end

function CCSUILoader:createPanel(options)
	local node = nil

	if options.clipAble then
		node = cc.ClippingRegionNode:create()
	else
		node = display.newNode()
	end

	local clrLayer, bgLayer = nil

	if options.colorType == 1 then
		clrLayer = cc.LayerColor:create()

		if not cc.bPlugin_ then
			clrLayer:resetCascadeBoundingBox()
		end

		clrLayer:setTouchEnabled(false)
		clrLayer:setColor(cc.c3b(options.bgColorR, options.bgColorG, options.bgColorB))
	elseif options.colorType == 2 then
		clrLayer = cc.LayerGradient:create()

		if not cc.bPlugin_ then
			clrLayer:resetCascadeBoundingBox()
		end

		clrLayer:setTouchEnabled(false)
		clrLayer:setStartColor(cc.c3b(options.bgStartColorR, options.bgStartColorG, options.bgStartColorB))
		clrLayer:setEndColor(cc.c3b(options.bgEndColorR, options.bgEndColorG, options.bgEndColorB))
		clrLayer:setVector(cc.p(options.vectorX or 0, options.vectorY or -0.5))
	end

	if clrLayer then
		clrLayer:setAnchorPoint(cc.p(0, 0))
		clrLayer:setOpacity(options.bgColorOpacity or 100)
	end

	if options.backGroundScale9Enable then
		if options.backGroundImageData and options.backGroundImageData.path then
			local capInsets = cc.rect(options.capInsetsX, options.capInsetsY, options.capInsetsWidth, options.capInsetsHeight)
			local scale9sp = ccui.Scale9Sprite or cc.Scale9Sprite

			if self.bUseTexture then
				bgLayer = scale9sp:createWithSpriteFrameName(options.backGroundImageData.path, capInsets)

				bgLayer:setContentSize(cc.size(options.width, options.height))
			else
				bgLayer = scale9sp:create(capInsets, options.backGroundImageData.path)

				bgLayer:setContentSize(cc.size(options.width, options.height))
			end
		end
	elseif options.backGroundImageData and options.backGroundImageData.path then
		bgLayer = display.newSprite(self:transResName(options.backGroundImageData))
	end

	local conSize = nil

	if options.adaptScreen then
		options.width = display.width
		options.height = display.height
	end

	conSize = cc.size(options.width, options.height)

	if options.clipAble then
		node:setClippingRegion(cc.rect(0, 0, options.width, options.height))
	end

	if not options.ignoreSize and clrLayer then
		clrLayer:setContentSize(conSize)
	end

	if bgLayer then
		bgLayer:setPosition(conSize.width / 2, conSize.height / 2)
	end

	node:setContentSize(conSize)

	if clrLayer then
		node:addChild(clrLayer)
	end

	if bgLayer then
		node:addChild(bgLayer)
	end

	node:setPositionX(options.x or 0)
	node:setPositionY(options.y or 0)
	node:setAnchorPoint(cc.p(options.anchorPointX or 0.5, options.anchorPointY or 0.5))

	return node
end

function CCSUILoader:createScrollView(options)
	local params = {
		viewRect = cc.rect(options.x, options.y, options.width, options.height)
	}

	if options.colorType == 1 then
		params.bgColor = cc.c4b(options.bgColorR, options.bgColorG, options.bgColorB, options.bgColorOpacity)
	elseif options.colorType == 2 then
		params.bgStartColor = cc.c4b(options.bgStartColorR, options.bgStartColorG, options.bgStartColorB, options.bgColorOpacity)
		params.bgEndColor = cc.c4b(options.bgEndColorR, options.bgEndColorG, options.bgEndColorB, options.bgColorOpacity)
		params.bgVector = cc.p(options.vectorX, options.vectorY)
	end

	params.bg = self:transResName(options.backGroundImageData)

	if options.backGroundScale9Enable then
		params.bgScale9 = options.backGroundScale9Enable
		params.capInsets = cc.rect(options.capInsetsX, options.capInsetsY, options.capInsetsWidth, options.capInsetsHeight)
	end

	local node = cc.ui.UIScrollView.new(params)
	local dir = options.direction

	if dir == 0 then
		dir = 0
	elseif dir == 3 then
		dir = 0
	end

	node:setDirection(dir)
	node:setBounceable(options.bounceEnable or false)

	return node
end

function CCSUILoader:createListView(options)
	local params = {
		viewRect = cc.rect(options.x, options.y, options.width, options.height)
	}

	if options.colorType == 1 then
		params.bgColor = cc.c4b(options.bgColorR, options.bgColorG, options.bgColorB, options.bgColorOpacity)
	elseif options.colorType == 2 then
		params.bgStartColor = cc.c4b(options.bgStartColorR, options.bgStartColorG, options.bgStartColorB, options.bgColorOpacity)
		params.bgEndColor = cc.c4b(options.bgEndColorR, options.bgEndColorG, options.bgEndColorB, options.bgColorOpacity)
		params.bgVector = cc.p(options.vectorX, options.vectorY)
	end

	local node = cc.ui.UIListView.new(params)
	local dir = options.direction or 1

	if dir == 0 then
		dir = 1
	elseif dir == 3 then
		dir = 0
	end

	node:setDirection(dir)
	node:setAlignment(options.gravity)
	node:setBounceable(options.bounceEnable or false)

	return node
end

function CCSUILoader:createPageView(options)
	local params = {
		column = 1,
		row = 1,
		viewRect = cc.rect(options.x, options.y, options.width, options.height)
	}
	local node = cc.ui.UIPageView.new(params)

	return node
end

function CCSUILoader:prettyJson(json)
	local prettyNode = nil

	function prettyNode(node, parent)
		if not node then
			return
		end

		local options = node.options
		local parentOption = parent and parent.options

		if options.adaptScreen then
			options.width = display.width
			options.height = display.height
		elseif options.sizeType == 1 and parentOption then
			options.width = parentOption.width * options.sizePercentX
			options.height = parentOption.height * options.sizePercentY
		end

		if parentOption and parentOption.scale9Enable then
			node.options.ZOrder = node.options.ZOrder or 3
		end

		if not node.children then
			return
		end

		if #node.children == 0 then
			return
		end

		for i, v in ipairs(node.children) do
			prettyNode(v, node)
		end
	end

	prettyNode(json)
end

function CCSUILoader:modifyPanelChildPos_(clsType, bAdaptScreen, sizeType, parentSize, children)
	if clsType ~= "Panel" or not bAdaptScreen and sizeType == 0 or not children then
		return
	end

	self:modifyLayoutChildPos_(parentSize, children)
end

function CCSUILoader:modifyLayoutChildPos_(parentSize, children)
	for _, v in ipairs(children) do
		self:calcChildPosByName_(children, v.options.name, parentSize)
	end
end

function CCSUILoader:calcChildPosByName_(children, name, parentSize)
	local child = self:getPanelChild_(children, name)

	if not child then
		return
	end

	if child.posFixed_ then
		return
	end

	local layoutParameter = nil
	local options = child.options
	local x, y = nil
	local bUseOrigin = false
	local width = options.width
	local height = options.height
	layoutParameter = options.layoutParameter

	if not layoutParameter then
		return
	end

	if layoutParameter.type == 1 then
		if layoutParameter.gravity == 1 then
			x = width * 0.5
		elseif layoutParameter.gravity == 2 then
			y = parentSize.height - height * 0.5
		elseif layoutParameter.gravity == 3 then
			x = parentSize.width - width * 0.5
		elseif layoutParameter.gravity == 4 then
			y = height * 0.5
		elseif layoutParameter.gravity == 5 then
			y = parentSize.height * 0.5
		elseif layoutParameter.gravity == 6 then
			x = parentSize.width * 0.5
		else
			x = options.x
			y = options.y
			bUseOrigin = true

			print("CCSUILoader - modifyLayoutChildPos_ not support gravity:" .. layoutParameter.type)
		end

		if layoutParameter.gravity == 1 or layoutParameter.gravity == 3 or layoutParameter.gravity == 6 then
			x = ((options.anchorPointX or 0.5) - 0.5) * width + x
			y = options.y
		else
			x = options.x
			y = ((options.anchorPointY or 0.5) - 0.5) * height + y
		end
	elseif layoutParameter.type == 2 then
		local relativeChild = self:getPanelChild_(children, layoutParameter.relativeToName)
		local relativeRect = nil

		if relativeChild then
			self:calcChildPosByName_(children, layoutParameter.relativeToName, parentSize)

			relativeRect = cc.rect(relativeChild.options.x - (relativeChild.options.anchorPointX or 0.5) * relativeChild.options.width or 0, relativeChild.options.y - (relativeChild.options.anchorPointY or 0.5) * relativeChild.options.height or 0, relativeChild.options.width or 0, relativeChild.options.height or 0)
		end

		if layoutParameter.align == 1 then
			x = width * 0.5
			y = parentSize.height - height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 2 then
			x = parentSize.width * 0.5
			y = parentSize.height - height * 0.5
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 3 then
			x = parentSize.width - width * 0.5
			y = parentSize.height - height * 0.5
			x = x - (layoutParameter.marginRight or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 4 then
			x = width * 0.5
			y = parentSize.height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
		elseif layoutParameter.align == 5 then
			x = parentSize.width * 0.5
			y = parentSize.height * 0.5
		elseif layoutParameter.align == 6 then
			x = parentSize.width - width * 0.5
			y = parentSize.height * 0.5
			x = x - (layoutParameter.marginRight or 0)
		elseif layoutParameter.align == 7 then
			x = width * 0.5
			y = height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 8 then
			x = parentSize.width * 0.5
			y = height * 0.5
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 9 then
			x = parentSize.width - width * 0.5
			y = height * 0.5
			x = x - (layoutParameter.marginRight or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 10 then
			x = relativeRect.x + width * 0.5
			y = relativeRect.y + relativeRect.height + height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 11 then
			x = relativeRect.x + relativeRect.width * 0.5
			y = relativeRect.y + relativeRect.height + height * 0.5
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 12 then
			x = relativeRect.x + relativeRect.width - width * 0.5
			y = relativeRect.y + relativeRect.height + height * 0.5
			x = x - (layoutParameter.marginRight or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 13 then
			x = relativeRect.x - width * 0.5
			y = relativeRect.y + relativeRect.height - height * 0.5
			x = x - (layoutParameter.marginRight or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 14 then
			x = relativeRect.x - width * 0.5
			y = relativeRect.y + relativeRect.height * 0.5
			x = x - (layoutParameter.marginRight or 0)
		elseif layoutParameter.align == 15 then
			x = relativeRect.x - width * 0.5
			y = relativeRect.y + height * 0.5
			x = x - (layoutParameter.marginRight or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 16 then
			x = relativeRect.x + relativeRect.width + width * 0.5
			y = relativeRect.y + relativeRect.height - height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 17 then
			x = relativeRect.x + relativeRect.width + width * 0.5
			y = relativeRect.y + relativeRect.height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
		elseif layoutParameter.align == 18 then
			x = relativeRect.x + relativeRect.width + width * 0.5
			y = relativeRect.y + height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
			y = y + (layoutParameter.marginDown or 0)
		elseif layoutParameter.align == 19 then
			x = relativeRect.x + width * 0.5
			y = relativeRect.y - height * 0.5
			x = x + (layoutParameter.marginLeft or 0)
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 20 then
			x = relativeRect.x + relativeRect.width * 0.5
			y = relativeRect.y - height * 0.5
			y = y - (layoutParameter.marginTop or 0)
		elseif layoutParameter.align == 21 then
			x = relativeRect.x + relativeRect.width - width * 0.5
			y = relativeRect.y - height * 0.5
			x = x - (layoutParameter.marginRight or 0)
			y = y - (layoutParameter.marginTop or 0)
		else
			x = options.x
			y = options.y
			bUseOrigin = true

			print("CCSUILoader - modifyLayoutChildPos_ not support align:" .. layoutParameter.align)
		end

		x = ((options.anchorPointX or 0.5) - 0.5) * width + x
		y = ((options.anchorPointY or 0.5) - 0.5) * height + y
	elseif layoutParameter.type == 0 then
		x = options.x
		y = options.y
	else
		print("CCSUILoader - modifyLayoutChildPos_ not support type:" .. layoutParameter.type)
	end

	options.x = x
	options.y = y
	child.posFixed_ = true
end

function CCSUILoader:getPanelChild_(children, name)
	for _, v in ipairs(children) do
		if v.options.name == name then
			return v
		end
	end
end

return CCSUILoader
