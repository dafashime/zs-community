local def = import(".def")
local maptile = class("maptile")

table.merge(maptile, {})

local __position = cc.Node.setPosition
local __AnchorPoint = cc.Node.setAnchorPoint

function maptile:remove()
	for k, v in pairs(self.sprites) do
		v:removeSelf()
	end
end

function maptile:ctor(map, x, y)
	self.sprites = {}

	local data = map.file:gettile(x, y)

	if map.hasRes then
		if not data then
			return
		end

		if data.bgidx > 0 and x % 2 == 0 and y % 2 == 0 then
			local img = "tiles"

			if data.tileLib > 0 then
				img = img .. data.tileLib + 1
			end

			local bg = m2spr.new(img, data.bgidx - 1, {
				asyncPriority = 2
			}).spr:anchor(0, 0):flipX(data.r1):addto(map.layers.bg, y)

			self.sprites.bg = bg

			__position(bg, x * def.tile.w, (map.h - y - 1) * def.tile.h)
		end

		if data.mididx > 0 then
			local img = "smtiles"

			if data.smTileLib > 0 then
				img = img .. data.smTileLib + 1
			end

			local mid = m2spr.new(img, data.mididx - 1, {
				asyncPriority = 1
			}).spr:anchor(0, 0):flipX(data.r2):addto(map.layers.mid, y)

			self.sprites.mid = mid

			__position(mid, x * def.tile.w, (map.h - y) * def.tile.h)

			if data.smTilesAniFrameAndSpeed ~= 0 and data.midAniOfs > 0 and data.midAniCnt > 0 then
				self.sprites.midAni = m2spr.playAnimation(img, data.mididx - 1, data.midAniCnt, nil, data.midAniBlend, nil, nil, nil, nil, 1, data.midAniOfs):anchor(0, 0):flipX(reverse):addto(map.layers.mid, y)

				__position(self.sprites.midAni, x * def.tile.w, (map.h - y) * def.tile.h)
			end
		end

		if data.objidx > 0 then
			local img = "objects"

			if data.objFileIdx > 0 then
				img = img .. data.objFileIdx + 1
			end

			if data.aniFrame > 1 then
				self.sprites.obj = m2spr.playAnimation(img, data.objidx - 1, data.aniFrame, nil, data.blend, nil, nil, nil, nil, 1)

				local yoff = 0

				if data.aniTick == 1 then
					yoff = -3
				end

				__position(self.sprites.obj, x * def.tile.w, (map.h - y + yoff) * def.tile.h)
				__AnchorPoint(self.sprites.obj, cc.p(0, 0))
			else
				self.sprites.obj = m2spr.new(img, data.objidx - 1, {
					asyncPriority = 1
				})

				__position(self.sprites.obj.spr, x * def.tile.w, (map.h - y) * def.tile.h)
				__AnchorPoint(self.sprites.obj.spr, cc.p(0, 0))
			end

			if self.sprites.obj then
				self.sprites.obj:flipX(data.r3):addto(map.layers.obj, y)
			end

			if data.doorIndex ~= 0 then
				data.doorOpen = false

				map:addDoorTile(data, x, y)
			end
		end

		if data.aniNo > 0 and data.aniOfs > 0 and data.aniCnt > 0 then
			self.sprites.ani = m2spr.playAnimation("anitiles" .. data.aniLib + 1, data.aniNo - 1, data.aniCnt - 1, nil, data.aniBlend, nil, nil, nil, nil, 1, data.aniOfs):anchor(0, 0):flipX(data.r4):addto(map.layers.obj, y)

			__position(self.sprites.ani, x * def.tile.w, (map.h - y) * def.tile.h)
			__AnchorPoint(self.sprites.ani, cc.p(0, 0))
		end
	else
		self.sprites.bg = res.get2("pic/maptile/bg.png", nil, nil, {
			class = cc.FilteredSpriteWithOne
		}):anchor(0, 0):addto(map.layers.bg, y)

		__position(self.sprites.bg, x * def.tile.w, (map.h - y) * def.tile.h)

		if data and not data.canWalk then
			self.sprites.obj = res.get2("pic/maptile/obj" .. math.random(3) .. ".png", nil, nil, {
				class = cc.FilteredSpriteWithOne
			}):anchor(0, 0):addto(map.layers.bg, y)

			__position(self.sprites.obj, x * def.tile.w, (map.h - y) * def.tile.h)
		end
	end
end

function maptile:setDoorState(data)
	local img = "objects"

	if data.objFileIdx > 0 then
		img = img .. data.objFileIdx + 1
	end

	self.sprites.obj:setImg(img, data.objidx - 1 + (data.doorOpen and data.doorOffset or 0))
end

function maptile.addTile(data, x, y, bgLayer, midLayer, objLayer, maph, maxh)
	if data.bgidx > 0 and x % 2 == 0 and y % 2 == 0 then
		local img = "tiles"

		if data.tileLib > 0 then
			img = img .. data.tileLib + 1
		end

		local spr = res.get(img, data.bgidx - 1):anchor(0, 0):pos(x * def.tile.w, (maph - y - 1) * def.tile.h):flipX(data.r1):addto(bgLayer, y)

		maxh = math.max(maxh, spr:getPositionY() + spr:getContentSize().height)
	end

	if data.mididx > 0 then
		local img = "smtiles"

		if data.smTileLib > 0 then
			img = img .. data.smTileLib + 1
		end

		local spr = res.get(img, data.mididx - 1):anchor(0, 0):pos(x * def.tile.w, (maph - y) * def.tile.h):flipX(data.r2):addto(midLayer, y)

		maxh = math.max(maxh, spr:getPositionY() + spr:getContentSize().height)
	end

	if data.objidx > 0 then
		local img = "objects"

		if data.objFileIdx > 0 then
			img = img .. data.objFileIdx + 1
		end

		if data.aniFrame <= 1 then
			local spr = res.get(img, data.objidx - 1):anchor(0, 0):pos(x * def.tile.w, (maph - y) * def.tile.h):flipX(data.r3):addto(objLayer, y)

			maxh = math.max(maxh, spr:getPositionY() + spr:getContentSize().height)
		end
	end

	return maxh
end

return maptile
