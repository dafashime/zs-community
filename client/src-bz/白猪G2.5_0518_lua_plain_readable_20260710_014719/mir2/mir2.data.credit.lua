import("mir2.scenes.main.rocker.single")

return {
	isAuthen = false,
	setAuthen = function(self, msg)
		self.isAuthen = msg.recog == 0
	end
}
