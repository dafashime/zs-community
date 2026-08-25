local screenshotLook = class("screenshotLook", function ()
	return display.newNode()
end)

table.merge(screenshotLook, {})

function screenshotLook:ctor(params)
	self._supportMove = true
	local screen = display.newSprite(params.diskpath)
	local picw = 615
	local picscale = picw / screen:getw()
	local pich = screen:geth() * picscale
	local size = cc.size(picw, pich)

	screen:scale(picscale):anchor(0, 0):pos(13, 14):add2(self)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, size):pos(screen:getPosition()):anchor(0, 0):add2(self)

	local controlHeight = 70
	local b1 = res.get2("pic/panels/bigmap/bg1.png")
	local b2 = res.get2("pic/panels/bigmap/bg2.png")
	local b3 = res.get2("pic/panels/bigmap/bg3.png")

	self:size(b1:getw(), size.height + controlHeight):anchor(0.5, 0.5):center()
	self:scale(0.01):scaleTo(0.2, 1)
	b3:anchor(0, 0):add2(self, -1)
	b2:anchor(0, 0):pos(0, b3:geth()):scaleY((self:geth() - b1:geth() - b3:geth()) / b2:geth()):add2(self, -1)
	b1:anchor(0, 1):pos(0, self:geth()):add2(self, -1)
	res.get2("pic/panels/screenshot/title.png"):add2(b1):pos(b1:getw() / 2, b1:geth() - 23)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}):anchor(1, 1):pos(self:getw() - 8, self:geth() - 8):addto(self, 1)

	local title = an.newLabelM(self:getw() - 30, 18, 1, {
		manual = true
	}):anchor(0, 0.5):pos(20, self:geth() - 32):add2(self):nextLine():addLabel(params.user, cc.c3b(0, 255, 0)):addLabel("的屏幕")
end

return screenshotLook
