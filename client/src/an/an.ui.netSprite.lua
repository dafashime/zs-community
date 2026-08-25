local lfs = require("lfs")
local NetSprite = class("NetSprite", function ()
	return display.newSprite()
end)

function NetSprite:ctor(url, imageSize)
	self.path = device.writablePath .. "netSprite/"

	if not io.exists(self.path) then
		lfs.mkdir(self.path)
	end

	self.url = url
	self.imageSize = imageSize

	self:createSprite()
end

function NetSprite:getUrlMd5()
	local tempMd5 = crypto.md5(self.url)
	local bExist = false
	local picPath = self.path .. tempMd5 .. ".png"

	if io.exists(picPath) then
		bExist = true
	end

	return bExist, picPath
end

function NetSprite:createSprite()
	local isExist, fileName = self:getUrlMd5()

	if isExist then
		self:updateTexture(fileName)
	else
		local request = network.createHTTPRequest(function (event)
			if self.onRequestFinished then
				self:onRequestFinished(event, fileName)
			end
		end, self.url, "GET")

		request:setTimeout(200)
		request:start()
	end
end

function NetSprite:onRequestFinished(event, fileName)
	local ok = event.name == "completed"
	local request = event.request

	if not ok then
		return
	end

	local code = request:getResponseStatusCode()

	if code ~= 200 then
		print("http status code", code)

		return
	end

	print("NetSprite download success", fileName)

	local times = 1

	while not request:saveResponseData(fileName) and times < 30 do
		times = times + 1
	end

	self:updateTexture(fileName)
end

function NetSprite:updateTexture(fileName)
	local sprite = display.newSprite(fileName)

	if not sprite then
		return
	end

	local texture = sprite:getTexture()
	local size = texture:getContentSize()

	self:setTexture(texture)
	self:setContentSize(size)
	self:setTextureRect(cc.rect(0, 0, size.width, size.height))

	if self.imageSize then
		self:scaleX(self.imageSize.width / size.width)
		self:scaleY(self.imageSize.height / size.height)
		self:setContentSize(self.imageSize)
	end
end

return NetSprite
