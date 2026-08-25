local c = cc
local Sprite = c.Sprite

function Sprite:playAnimationOnce(animation, removeWhenFinished, onComplete, delay)
	return transition.playAnimationOnce(self, animation, removeWhenFinished, onComplete, delay)
end

function Sprite:playAnimationForever(animation, delay)
	return transition.playAnimationForever(self, animation, delay)
end
