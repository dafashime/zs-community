local panelDelegate = {}

function panelDelegate.extend(target, name, parent)
	function target:hidePanel()
		parent:hidePanel(name)
	end

	function target:setFocus()
		if not main_scene.ui.isChoseItem then
			if parent.lastFocus then
				parent.lastFocus:setLocalZOrder(0)
			end

			parent.lastFocus = self

			self:setLocalZOrder(parent.z.focus)
		else
			self:setLocalZOrder(0)
		end
	end

	function target:checkInPanel(pos)
		local p = self:convertToWorldSpace(cc.p(0, 0))

		for k, v in pairs(self._touchFrames) do
			local rect = v.rect

			if cc.rectContainsPoint(cc.rect(p.x + rect.x * self:getScale(), p.y + rect.y * self:getScale(), rect.width * self:getScale(), rect.height * self:getScale()), pos) then
				return true
			end
		end
	end

	function target:addTouchFrame(rect, name, onlyRect)
		self:removeTouchFrame(name)

		local frame = {
			rect = rect
		}

		if not onlyRect then
			frame.mask1 = display.newNode():pos(rect.x, rect.y):size(rect.width, rect.height):addto(self, -999999999)

			frame.mask1:setTouchEnabled(true)
			frame.mask1:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
				if not self._supportMove then
					return
				end

				if event.name == "began" then
					frame.beganPos = cc.p(self:getPosition())
					frame.beganTouchPos = cc.p(event.x, event.y)

					return true
				end

				if event.name == "moved" or event.name == "ended" then
					self:pos(event.x - frame.beganTouchPos.x + frame.beganPos.x, event.y - frame.beganTouchPos.y + frame.beganPos.y)
				end
			end)

			frame.mask2 = display.newNode():pos(rect.x, rect.y):size(rect.width, rect.height):addto(self, 999999999)

			frame.mask2:setTouchEnabled(true)
			frame.mask2:setTouchSwallowEnabled(false)
			frame.mask2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
				if event.name == "began" then
					self:setFocus()

					return true
				end
			end)
		end

		self._touchFrames[name] = frame
	end

	function target:removeTouchFrame(name)
		if self._touchFrames[name] then
			if self._touchFrames[name].mask1 then
				self._touchFrames[name].mask1:removeSelf()
			end

			if self._touchFrames[name].mask2 then
				self._touchFrames[name].mask2:removeSelf()
			end

			self._touchFrames[name] = nil
		end
	end

	target._touchFrames = {}

	local rect = target._mainRect or cc.rect(0, 0, target:getw(), target:geth())

	target:addTouchFrame(rect, "main")

	return target
end

return panelDelegate
