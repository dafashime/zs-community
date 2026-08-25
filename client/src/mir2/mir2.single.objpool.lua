local objpool = {
	objs = {}
}

function objpool.perload(class, cnt, ...)
	local objs = objpool.objs[class.__cname]

	if not objs then
		objs = {}
		objpool.objs[class.__cname] = objs
	end

	for i = 1, cnt do
		local obj = class.new(...)

		obj:retain()
		obj:setNodeEventEnabled(true)

		function obj.onCleanup()
			obj:objpool_delegate_cleanup()

			objs[#objs + 1] = obj
		end
	end
end

function objpool.new(class, ...)
	local objs = objpool.objs[class.__cname]

	if not objs then
		objs = {}
		objpool.objs[class.__cname] = objs
	end

	local ret = nil

	if #objs > 0 then
		ret = objs[1]

		table.remove(objs, 1)
	else
		ret = class.new()

		ret:retain()
		ret:setNodeEventEnabled(true)

		function ret.onCleanup()
			ret:objpool_delegate_cleanup()

			objs[#objs + 1] = ret
		end
	end

	ret:objpool_delegate_init(...)

	return ret
end

function objpool.clear(classname)
	local objs = objpool.objs[classname]

	if objs then
		for i, v in ipairs(objs) do
			v:release()
		end

		objpool.objs[classname] = nil
	end
end

return objpool
