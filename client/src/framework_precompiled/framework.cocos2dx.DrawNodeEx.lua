local c = cc
local DrawNode = c.DrawNode
local drawPolygon = DrawNode.drawPolygon

function DrawNode:drawPolygon(points, params)
	local segments = #points
	fillColor = cc.c4f(1, 1, 1, 1)
	borderWidth = 0
	borderColor = cc.c4f(0, 0, 0, 1)

	if params then
		if params.fillColor then
			fillColor = params.fillColor
		end

		if params.borderWidth then
			borderWidth = params.borderWidth
		end

		if params.borderColor then
			borderColor = params.borderColor
		end
	end

	drawPolygon(self, points, #points, fillColor, borderWidth, borderColor)

	return self
end

local drawDot = DrawNode.drawDot

function DrawNode:drawDot(point, radius, color)
	drawDot(self, point, radius, color)

	return self
end
