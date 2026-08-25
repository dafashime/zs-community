local stall = import(".stall")
local stallOther = clone(stall)

stallOther.isOther = true

function stallOther:uptDelItem(msg)
	for k, v in pairs(self.items) do
		if v.info:get("makeIndex") == tonumber(msg.recog) then
			v.cnt = msg.param

			if v.info.isPileUp() then
				v.info:set("dura", msg.param)
			end

			if msg.param == 0 then
				self.items[k] = nil
			end

			return k, v
		end
	end
end

return stallOther
