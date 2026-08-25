if an then
	return
end

an = {}

import(".overwrite.init")
import(".ui.init")
import(".funcs")

function an.init(params)
	params = params or {}
	an.gettex = params.gettex
end
