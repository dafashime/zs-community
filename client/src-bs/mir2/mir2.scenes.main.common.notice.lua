local notice = class("notice", function ()
	return display.newNode()
end)
local common = import(".common")

table.merge(notice, {})

function notice:ctor()
	local w = 66
	local h = 66

	self:size(w * 2, h)
	self:pos(50, display.height - 50 - h)

	self.mails = nil
	self.msgs = {}
	self.maxLine = 10
	self.btn_mail = an.newBtn(res.gettex2("pic/console/notice/mail.png"), function ()
		self.mails = nil

		self:checkShow()
		main_scene.ui:showPanel("mail", {
			tag = self.mailTag
		})
	end, {
		pressBig = true
	}):addTo(self, 1):pos(w / 2, h / 2):anchor(0.5, 0.5)
	local numbg = res.get2("pic/console/notice/num.png"):addTo(self.btn_mail):pos(self.btn_mail:getw() + 7, self.btn_mail:geth() + 9):anchor(1, 1)
	self.btn_mail.num = an.newLabel("", 16, 1):addTo(numbg):pos(numbg:getw() / 2, numbg:geth() / 2):anchor(0.5, 0.5)
	self.btn_msgs = an.newBtn(res.gettex2("pic/console/notice/icon.png"), function ()
		if #self.msgs > 0 then
			local msg = nil

			repeat
				msg = self.msgs[1]

				if msg then
					table.remove(self.msgs, 1)

					if type(msg.fun) == "function" then
						msg.fun()
						self:checkShow()

						return
					end
				end
			until not msg

			self:checkShow()
		end
	end, {
		pressBig = true
	}):addTo(self, 1):pos(w / 2 * 3, h / 2):anchor(0.5, 0.5)

	self:checkShow()
end

function notice:checkShow()
	local w = 66
	local h = 66
	local show = false

	if #self.msgs > 0 then
		self.btn_msgs:show()
		self.btn_msgs:pos(w / 2, h / 2)

		show = true
	else
		self.btn_msgs:hide()
	end

	if self.mails then
		self.btn_mail:show()
		self.btn_mail:pos(w / 2, h / 2)
		self.btn_msgs:pos(w / 2 * 3, h / 2)

		show = true
	else
		self.btn_mail:hide()
	end

	if show then
		self:show()
	else
		self:hide()
	end
end

function notice:uptMailCnt(cnt, tag)
	self.mails = cnt
	self.mailTag = tag

	self.btn_mail.num:setString(self.mails .. "")
	self:checkShow()
end

function notice:removeMailCnt()
	self.mails = nil

	self:checkShow()
end

function notice:addMsg(funName, msg)
	self.msgs[#self.msgs + 1] = self["add" .. funName](self, msg)

	self:checkShow()
end

function notice:removeMsg(funName, msg)
	for i, v in ipairs(self.msgs) do
		if self["remove" .. funName](self, v, msg) then
			table.remove(self.msgs, i)
		end
	end

	self:checkShow()
end

function notice:addFriendApply(msg)
	local function fun()
		local info = {
			[0] = " 邀请您加入队伍！",
			" 请求加入您的队伍！",
			" 请求添加您为好友，是否同意？"
		}
		local name = msg[1]
		local cmd = info[msg[2]]

		local function reply(idx)
			net.send({
				CM_ReplyGroupMessage,
				recog = idx - 1,
				param = msg[2]
			}, {
				msg[1]
			})
		end

		local msgbox = an.newMsgbox(name .. cmd, function (idx)
			if idx == 1 then
				reply(2)
			else
				reply(1)
			end
		end, {
			manualRemoved = true,
			btnTexts = {
				"同  意",
				"拒  绝"
			}
		})
	end

	return {
		fun = fun,
		name = msg[1],
		cmd = msg[2]
	}
end

function notice:removeFriendApply(listMsg, msg)
	if listMsg.name and listMsg.name == msg[1] and listMsg.cmd and listMsg.cmd == msg[2] then
		return true
	end

	return false
end

return notice
