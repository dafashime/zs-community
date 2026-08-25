local detail = import("..detail")
local replaceAsk = import("..replaceAsk")
local widgetDelegate = {
	extend = function (target, console)
		local mask, rect, beganPos, beganTouchPos, hasMove, beganTime = nil

		function target:_startEdit()
			if mask then
				mask:removeSelf()
			end

			mask = display.newNode():size(self:getContentSize()):addto(self, 999999999)

			mask:setTouchEnabled(true)
			mask:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					beganPos = cc.p(self:getPosition())
					beganTouchPos = cc.p(event.x, event.y)
					beganTime = socket.gettime()
					hasMove = false

					self:setLocalZOrder(self:getLocalZOrder() + 1)
					console:showRect(self)
				elseif event.name == "moved" then
					if hasMove or math.abs(beganTouchPos.x - event.x) > 10 or math.abs(beganTouchPos.y - event.y) > 10 or socket.gettime() - beganTime > 1 then
						hasMove = true
						local x = beganPos.x
						local y = beganPos.y

						if not self.config.fixedX then
							x = event.x - beganTouchPos.x + beganPos.x
							x = self:_checkx(x)
							self.data.x = x
						end

						if not self.config.fixedY then
							y = event.y - beganTouchPos.y + beganPos.y
							y = self:_checky(y)
							self.data.y = y
						end

						self:pos(x, y)

						if self.config.class == "btnMove" then
							console:checkBtnAreaShow(cc.p(x, y))
						end
					end
				elseif event.name == "ended" then
					self:setLocalZOrder(self:getLocalZOrder() - 1)

					if hasMove then
						console:checkBtnAreaShow(nil, true)

						if self.config.class == "btnMove" then
							local btnpos = console:pos2btnpos(self:getPosition())

							if btnpos then
								local existBtn = console:findWidgetWithBtnpos(btnpos)

								if existBtn then
									if existBtn == self then
										console:resetBtnAreaBtnPos(self, true)

										return
									end

									replaceAsk.new(existBtn, function (operator)
										if operator == "swap" then
											existBtn.data.btnpos = self.data.btnpos
											self.data.btnpos = existBtn.data.btnpos

											console:resetBtnAreaBtnPos(self, true)

											if not existBtn.data.btnpos then
												existBtn:moveTo(0.1, beganPos.x, beganPos.y)
											else
												console:resetBtnAreaBtnPos(existBtn, true)
											end
										elseif operator == "replace" then
											console:removeWidget(existBtn.data.key)

											self.data.btnpos = btnpos

											console:resetBtnAreaBtnPos(self, true)
										elseif operator == "cancel" then
											if not self.data.btnpos then
												self:moveTo(0.1, beganPos.x, beganPos.y)
											else
												console:resetBtnAreaBtnPos(self, true)
											end
										end
									end, "console")
								else
									self.data.btnpos = btnpos

									console:resetBtnAreaBtnPos(self, true)
								end
							else
								self.data.btnpos = nil
							end
						end
					else
						detail.new(self.config, self.data, self:getPositionX(), self:getPositionY(), self:getw(), self:geth(), "console", self)
					end
				end

				return true
			end)
		end

		function target:_endEdit()
			if mask then
				mask:removeSelf()

				mask = nil
			end
		end

		function target:_showRect()
			if not rect then
				rect = display.newRect(cc.rect(0, 0, self:getw(), self:geth()), {
					borderWidth = 1,
					borderColor = cc.c4f(0, 1, 0, 1)
				}):add2(self, 999999999)
			end
		end

		function target:_hideRect()
			if rect then
				rect:removeSelf()

				rect = nil
			end
		end

		function target:_checkx(x)
			if x < self:getw() / 2 then
				x = self:getw() / 2 or x
			end

			if x > display.width - self:getw() / 2 then
				x = display.width - self:getw() / 2 or x
			end

			return x
		end

		function target:_checky(y)
			if y < self:geth() / 2 then
				y = self:geth() / 2 or y
			end

			if y > display.height - self:geth() / 2 then
				y = display.height - self:geth() / 2 or y
			end

			return y
		end

		function target:_checkPos(x, y)
			return self:_checkx(x), self:_checky(y)
		end

		function target:_sizeChanged()
			if mask then
				mask:size(self:getContentSize())
			end

			self:_hideRect()
			self:_showRect()
			self:pos(self:_checkPos(self:getPosition()))
		end

		return target
	end
}

return widgetDelegate
