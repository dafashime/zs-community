local current = ...
uiEditor = class("uiEditor")
local serialize = require("mir2.data.serialize")

table.merge(uiEditor, {})

uiEditor.sers__ = {}

function uiEditor:ctor()
end

function uiEditor:startEdit(name, cfg_key, root)
	local ser = uiEditor.sers__[name]

	if root:getName() == "" or root:getName() == nil then
		root:setName("root")
	end

	if DEBUG > 0 then
		if not ser then
			local filename = "src/mir2/scenes/main/panel/UIConfig/" .. name .. ".lua"
			ser = serialize.new()

			ser:open(filename, true)
		end

		self.ser = ser.data
		self.root = root
		self.cfg_key = cfg_key
		self.ser[cfg_key] = self.ser[cfg_key] or {}

		if not self.debug_ then
			self:debug()
		end
	else
		local mod = package.preload["mir2.scenes.main.panel.UIConfig." .. name]

		if not mod then
			print("target cofnig not exist")

			return
		end

		local data = {}

		setfenv(mod, data)
		mod()

		data = data.v
		self.ser = data
	end

	self.id_ = self.ser.id_ or 0

	self:setConfig(root)
end

function uiEditor:setConfig(root)
	local data = self.ser[self.cfg_key]

	traversalNodeTree(root, function (n)
		local name = n:getName()
		local cfg = name and data[name]

		if cfg then
			if cfg.pos then
				n:pos(cfg.pos.x, cfg.pos.y)
			end

			if cfg.anchor then
				n:anchor(cfg.anchor.x, cfg.anchor.y)
			end

			if cfg.scale then
				n:setScaleX(cfg.scale.x)
				n:setScaleY(cfg.scale.y)
			end

			if cfg.size then
				n:size(cfg.size.w, cfg.size.h)
			end

			if cfg.color then
				n:color(cfg.color)
			end

			if cfg.children then
				for k, v in pairs(cfg.children) do
					local child = nil

					if v.type == "label" then
						child = an.newLabel(v.text, v.fontSize or 18, v.stroke or 1, {
							color = v.color,
							sc = v.sc
						})
					elseif v.type == "sprite" then
						child = res.get2(v.imgPath)
					elseif v.type == "node" then
						child = display.newNode()
					elseif v.type == "layer" then
						child = cc.LayerColor:create(v.color)
					end
				end
			end
		end

		return true
	end)
end

if DEBUG > 0 then
	function uiEditor:debug()
		self.debug_ = true
		self._mouseEventListener = cc.EventListenerMouse:create()

		self._mouseEventListener:registerScriptHandler(handler(self, self.onMouseDown), cc.Handler.EVENT_MOUSE_DOWN)

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

		eventDispatcher:addEventListenerWithFixedPriority(self._mouseEventListener, 1000)
	end

	function uiEditor:disDebug()
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

		eventDispatcher:removeEventListener(self._mouseEventListener)
	end

	function uiEditor:getNodesByPos(pos)
		local nodes = {}

		traversalNodeTree(self.root, function (n)
			if n:getName() and n:getName() ~= "" and n:hitTest(pos, false) then
				table.insert(nodes, n)
			end

			return true
		end)

		return nodes
	end

	function uiEditor:getAllChildren()
		local nodes = {}

		traversalNodeTree(self.root, function (n)
			if n:getName() and n:getName() ~= "" then
				table.insert(nodes, n)
			end

			return true
		end)

		return nodes
	end

	local common = import("..common.common", current)

	function uiEditor:showOperators()
		if not self.pre then
			return nil
		end

		function createInputCell(name, w, default, max, callback)
			local lb = an.newLabel(name, 22, 1):pos(3, 20):anchor(0, 0.5)
			local inputBack = display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):anchor(0, 0.5):size(w - lb:getw() - 6, 34):pos(lb:getw() + 3, 20)
			local valueInput = nil
			valueInput = an.newInput(10, 3, w - 25, 38, max, {
				label = {
					tostring(default),
					20,
					1
				}
			}):add2(inputBack):anchor(0, 0):pos(10, -5)
			valueInput.preValue__ = tostring(default)

			valueInput:schedule(function ()
				if valueInput.preValue__ ~= valueInput:getString() then
					valueInput.preValue__ = valueInput:getString()

					callback(valueInput.preValue__)
				end
			end, 0.1)

			local n = display.newColorLayer(cc.c4b(128, 128, 128, 65)):size(w, 40)

			n:addChild(lb)
			n:addChild(inputBack)

			function n:setValue(v)
				valueInput:setString(tostring(v))
			end

			function n:getValue()
				return valueInput:getString()
			end

			return n
		end

		local function craeteNode(creator, clsName)
			local name = string.format("%s_%d", clsName, self.id_)
			self.ser.id_ = self.id_ + 1
			self.id_ = self.ser.id_
			local pname = self.pre:getName()
			local children = self:getData(pname, "children") or {}

			self:save(pname, "children", children)
			self:save(name, "type", clsName)
			self:save(name, "parent", self:get(pname))

			children[name] = self:get(name)
			local n = creator():add2(self.pre)

			n:setName(name)

			return n
		end

		local ops = {}

		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg1 = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(125, 50):add2(n)
				local lb1 = an.newLabel("添加Label", 22, 1):add2(bg1):pos(10, 10)

				lb1:setTouchEnabled(true)
				lb1:enableClick(function ()
					local p = self.pre
					local n = craeteNode(function ()
						return an.newLabel("", 22, 1)
					end, "label")

					main_scene.ui:tip("添加成功")
				end)

				local bg2 = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(125, 50):add2(n):pos(126, 0)
				local lb2 = an.newLabel("添加Sprite", 22, 1):add2(bg2):pos(10, 10)

				lb2:setTouchEnabled(true)
				lb2:enableClick(function ()
					local p = self.pre
					local n = craeteNode(function ()
						return cc.Sprite:create()
					end, "sprite")

					main_scene.ui:tip("添加成功")
				end)

				return n
			end
		})
		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg1 = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(125, 50):add2(n)
				local lb1 = an.newLabel("添加Node", 22, 1):add2(bg1):pos(10, 10)

				lb1:setTouchEnabled(true)
				lb1:enableClick(function ()
					local p = self.pre
					local n = craeteNode(function ()
						return display.newNode()
					end, "node")

					main_scene.ui:tip("添加成功")
				end)

				local bg2 = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(125, 50):add2(n):pos(126, 0)
				local lb2 = an.newLabel("添加ColorLayer", 22, 1):add2(bg2):pos(10, 10)

				lb2:setTouchEnabled(true)
				lb2:enableClick(function ()
					local p = self.pre
					local n = craeteNode(function ()
						return display.newColorLayer(cc.c4b(0, 0, 0, 128))
					end, "layer")

					main_scene.ui:tip("添加成功")
				end)

				return n
			end
		})
		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

				local function setPos(key, value)
					local x, y = nil

					if key == "x" then
						x = tonumber(value)
						y = self.pre:getPositionY()
					else
						y = tonumber(value)
						x = self.pre:getPositionX()
					end

					self.pre:pos(x, y)
					self:save(self.pre:getName(), "pos", cc.p(x, y))
				end

				local xi = createInputCell("  x:", 120, 0, 6, handler("x", setPos)):add2(bg):pos(4, 5)
				local yi = createInputCell("  y:", 120, 0, 6, handler("y", setPos)):add2(bg):pos(126, 5)

				return n
			end
		})
		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

				local function setAnchor(key, value)
					local x, y = nil

					if key == "x" then
						x = tonumber(value)
						y = self.pre:getAnchorPoint().y
					else
						y = tonumber(value)
						x = self.pre:getAnchorPoint().x
					end

					self.pre:anchor(x, y)
					self:save(self.pre:getName(), "anchor", cc.p(x, y))
				end

				local xi = createInputCell("ax:", 120, 0, 6, handler("x", setAnchor)):add2(bg):pos(4, 5)
				local yi = createInputCell("ay:", 120, 0, 6, handler("y", setAnchor)):add2(bg):pos(126, 5)

				return n
			end
		})
		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

				local function setScale(key, value)
					local x, y = nil

					if key == "x" then
						x = tonumber(value)
						y = self.pre:getScaleY()
					else
						y = tonumber(value)
						x = self.pre:getScaleX()
					end

					self.pre:setScaleX(x)
					self.pre:setScaleY(y)
					self:save(self.pre:getName(), "scale", cc.p(x, y))
				end

				local xi = createInputCell("sx:", 120, 0, 6, handler("x", setScale)):add2(bg):pos(4, 5)
				local yi = createInputCell("sy:", 120, 0, 6, handler("y", setScale)):add2(bg):pos(126, 5)

				return n
			end
		})
		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

				local function setSize(key, value)
					local w, h = nil

					if key == "w" then
						w = tonumber(value)
						h = self.pre:geth()
					else
						h = tonumber(value)
						w = self.pre:getw()
					end

					self.pre:size(w, h)
					self:save(self.pre:getName(), "size", cc.size(w, h))
				end

				local xi = createInputCell("  w:", 120, 0, 6, handler("w", setSize)):add2(bg):pos(4, 5)
				local yi = createInputCell("  h:", 120, 0, 6, handler("h", setSize)):add2(bg):pos(126, 5)

				return n
			end
		})
		table.insert(ops, {
			w = 250,
			h = 52,
			cellCls = function ()
				local n = display.newNode():size(250, 50)
				local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

				local function setColor(key, value)
					local color = self.pre:getColor()
					color[key] = value

					self.pre:setColor(color)
					self:save(self.pre:getName(), "color", color)
				end

				local xi = createInputCell("r", 60, 0, 3, handler("r", setColor)):add2(bg):pos(3, 5)
				local yi = createInputCell("g", 60, 0, 3, handler("g", setColor)):add2(bg):pos(64, 5)
				local yi = createInputCell("b", 60, 0, 3, handler("b", setColor)):add2(bg):pos(126, 5)
				local yi = createInputCell("a", 60, 0, 3, handler("a", setColor)):add2(bg):pos(188, 5)

				return n
			end
		})

		local n = display.newNode():size(50, 50):debug():add2(main_scene, 999998):center()
		self.operatorNode = n

		n:setTouchEnabled(true)
		n:enableClick(function ()
			if not tolua.isnull(n.menu) then
				n.menu:removeFromParent()

				n.menu = nil
			end

			print(self.pre.__cname, tolua.type(self.pre))

			if tolua.type(self.pre) == "cc.Sprite" or tolua.type(self.pre) == "ccui.Scale9Sprite" then
				table.insert(ops, {
					w = 250,
					h = 52,
					cellCls = function ()
						local n = display.newNode():size(250, 50)
						local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

						local function setFile(key, value)
							self.pre:setTex(res.gettex2(value))
							self:save(self.pre:getName(), "tex", value)
						end

						local xi = createInputCell("file:", 244, 0, 3, handler("tex", setColor)):add2(bg):pos(3, 5)

						return n
					end
				})
			elseif self.pre.__cname == "an.label" then
				table.insert(ops, {
					w = 250,
					h = 52,
					cellCls = function ()
						local n = display.newNode():size(250, 50)
						local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

						local function setString(key, value)
							self.pre:setString(value)
							self:save(self.pre:getName(), "text", value)
						end

						local xi = createInputCell("text:", 244, 0, 256, handler("text", setString)):add2(bg):pos(3, 5)

						return n
					end
				})
				table.insert(ops, {
					w = 250,
					h = 52,
					cellCls = function ()
						local n = display.newNode():size(250, 50)
						local bg = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(250, 50):add2(n)

						local function fontSize(key, value)
							self.pre.fontSize = tonumber(value)

							self.pre:upt()
							self:save(self.pre:getName(), "fontSize", value)
						end

						local xi = createInputCell("fontSize:", 244, 0, 3, handler("text", fontSize)):add2(bg):pos(3, 5)

						return n
					end
				})
			end

			if self:getData(self.pre:getName(), "parent") then
				table.insert(ops, {
					w = 250,
					h = 52,
					cellCls = function ()
						local n = display.newNode():size(250, 50)
						local bg1 = display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(244, 50):add2(n)
						local lb1 = an.newLabel("删除节点", 22, 1):add2(bg1):pos(10, 10)

						lb1:setTouchEnabled(true)
						lb1:enableClick(function ()
							local function delByName(name)
								local data = self:get(name)
								local index = 1

								if data.children then
									for k, v in pairs(data.children) do
										delByName(k)
									end
								end

								self:delData(name)
							end

							local p = self.pre
							local name = p:getName()
							local parent = self:getData(name, "parent")

							self:delByName(name)

							parent.children[name] = nil

							p:removeSelf()
						end)

						return n
					end
				})
			end

			n.menu = common.createOperationMenu(ops, 3, function (pnl, cell)
			end):add2(n):anchor(1, 0):pos(50, 50)
		end, {
			support = "drag"
		})
		display.newColorLayer(cc.c4b(255, 255, 0, 128)):size(50, 50):add2(n)
		an.newLabel("编辑", 26, 1):pos(25, 25):anchor(0.5, 0.5):add2(n)
	end

	function uiEditor:onMouseDown(event)
		if event:getMouseButton() == 1 and self.root then
			local mousePos = cc.p(event:getCursorX(), event:getCursorY())

			if self.pre then
				self.pre:disableDebugdraw()
			end

			local nodes = self:getAllChildren(mousePos)
			local cells = {}

			for k, v in pairs(nodes) do
				local cell = {
					w = 250,
					h = 25
				}

				function cell.cellCls()
					local lb = v:getName()

					if not lb or lb == "" then
						lb = v.listener_id__
					end

					cell.stack = cell.node.stack__
					cell.lb = lb

					return an.newLabel(lb, 22, 1):anchor(0.5, 0.5)
				end

				cell.node = v

				table.insert(cells, cell)
			end

			if #cells <= 0 then
				return
			end

			local menu = common.createOperationMenu(cells, 5, function (pnl, cell)
				if self.pre then
					self.pre:setTouchEnabled(false)
					self.pre:disableDebugdraw()
				end

				if not tolua.isnull(cell.node) then
					self.pre = cell.node
				end

				self.pre:debug()
				self.pre:setTouchEnabled(true)
				cell.node:enableClick(function ()
				end, {
					support = "drag",
					size = cc.size(display.width, display.height),
					call_drag_moving = function (x, y)
						cell.node:disableDebugdraw()
					end,
					call_drag_end = function (pos)
						cell.node:debug()

						local name = cell.node:getName()

						self:save(name, "pos", pos)
					end
				})
			end, {
				scroll = {
					w = 300,
					h = display.height
				}
			}):add2(main_scene, 999999):anchor(0, 0):pos(0, 0)

			if not tolua.isnull(self.preMenu) then
				self.preMenu:removeSelf()
			end

			self.preMenu = menu

			self:showOperators()
		end
	end

	function uiEditor:save(name, key, value)
		self.ser[self.cfg_key][name] = self.ser[self.cfg_key][name] or {}
		self.ser[self.cfg_key][name][key] = value
	end

	function uiEditor:get(name)
		self.ser[self.cfg_key][name] = self.ser[self.cfg_key][name] or {}

		return self.ser[self.cfg_key][name]
	end

	function uiEditor:getData(name, key)
		return self.ser[self.cfg_key][name] and self.ser[self.cfg_key][name][key]
	end

	function uiEditor:delData(name)
		self.ser[self.cfg_key][name] = nil
	end

	function uiEditor:chgDataName(name, new)
		if self.ser[self.cfg_key][new] then
			return name
		end

		self.ser[self.cfg_key][new] = self.ser[self.cfg_key][name]
		self.ser[self.cfg_key][name] = nil
	end
end

return uiEditor
