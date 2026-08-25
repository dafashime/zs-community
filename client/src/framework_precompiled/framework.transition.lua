local transition = {}
local ACTION_EASING = {
	BACKIN = {
		cc.EaseBackIn,
		1
	},
	BACKINOUT = {
		cc.EaseBackInOut,
		1
	},
	BACKOUT = {
		cc.EaseBackOut,
		1
	},
	BOUNCE = {
		cc.EaseBounce,
		1
	},
	BOUNCEIN = {
		cc.EaseBounceIn,
		1
	},
	BOUNCEINOUT = {
		cc.EaseBounceInOut,
		1
	},
	BOUNCEOUT = {
		cc.EaseBounceOut,
		1
	},
	ELASTIC = {
		cc.EaseElastic,
		2,
		0.3
	},
	ELASTICIN = {
		cc.EaseElasticIn,
		2,
		0.3
	},
	ELASTICINOUT = {
		cc.EaseElasticInOut,
		2,
		0.3
	},
	ELASTICOUT = {
		cc.EaseElasticOut,
		2,
		0.3
	},
	EXPONENTIALIN = {
		cc.EaseExponentialIn,
		1
	},
	EXPONENTIALINOUT = {
		cc.EaseExponentialInOut,
		1
	},
	EXPONENTIALOUT = {
		cc.EaseExponentialOut,
		1
	},
	IN = {
		cc.EaseIn,
		2,
		1
	},
	INOUT = {
		cc.EaseInOut,
		2,
		1
	},
	OUT = {
		cc.EaseOut,
		2,
		1
	},
	RATEACTION = {
		cc.EaseRateAction,
		2,
		1
	},
	SINEIN = {
		cc.EaseSineIn,
		1
	},
	SINEINOUT = {
		cc.EaseSineInOut,
		1
	},
	SINEOUT = {
		cc.EaseSineOut,
		1
	}
}
local actionManager = cc.Director:getInstance():getActionManager()

function transition.newEasing(action, easingName, more)
	local key = string.upper(tostring(easingName))

	if string.sub(key, 1, 6) == "CCEASE" then
		key = string.sub(key, 7)
	end

	local easing = nil

	if ACTION_EASING[key] then
		local cls, count, default = unpack(ACTION_EASING[key])
		easing = (count ~= 2 or cls:create(action, more or default)) and cls:create(action)
	end

	return easing or action
end

function transition.create(action, args)
	args = checktable(args)

	if args.easing then
		if type(args.easing) == "table" then
			action = transition.newEasing(action, unpack(args.easing))
		else
			action = transition.newEasing(action, args.easing)
		end
	end

	local actions = {}
	local delay = checknumber(args.delay)

	if delay > 0 then
		actions[#actions + 1] = cc.DelayTime:create(delay)
	end

	actions[#actions + 1] = action
	local onComplete = args.onComplete

	if type(onComplete) ~= "function" then
		onComplete = nil
	end

	if onComplete then
		actions[#actions + 1] = cc.CallFunc:create(onComplete)
	end

	if #actions > 1 then
		return transition.sequence(actions)
	else
		return actions[1]
	end
end

function transition.execute(target, action, args)
	assert(not tolua.isnull(target), "transition.execute() - target is not cc.Node")

	local action = transition.create(action, args)

	target:runAction(action)

	return action
end

function transition.rotateTo(target, args)
	assert(not tolua.isnull(target), "transition.rotateTo() - target is not cc.Node")

	local action = cc.RotateTo:create(args.time, args.rotate)

	return transition.execute(target, action, args)
end

function transition.moveTo(target, args)
	assert(not tolua.isnull(target), "transition.moveTo() - target is not cc.Node")

	local tx, ty = target:getPosition()
	local x = args.x or tx
	local y = args.y or ty
	local action = cc.MoveTo:create(args.time, cc.p(x, y))

	return transition.execute(target, action, args)
end

function transition.moveBy(target, args)
	assert(not tolua.isnull(target), "transition.moveBy() - target is not cc.Node")

	local x = args.x or 0
	local y = args.y or 0
	local action = cc.MoveBy:create(args.time, cc.p(x, y))

	return transition.execute(target, action, args)
end

function transition.fadeIn(target, args)
	assert(not tolua.isnull(target), "transition.fadeIn() - target is not cc.Node")

	local action = cc.FadeIn:create(args.time)

	return transition.execute(target, action, args)
end

function transition.fadeOut(target, args)
	assert(not tolua.isnull(target), "transition.fadeOut() - target is not cc.Node")

	local action = cc.FadeOut:create(args.time)

	return transition.execute(target, action, args)
end

function transition.fadeTo(target, args)
	assert(not tolua.isnull(target), "transition.fadeTo() - target is not cc.Node")

	local opacity = checkint(args.opacity)

	if opacity < 0 then
		opacity = 0
	elseif opacity > 255 then
		opacity = 255
	end

	local action = cc.FadeTo:create(args.time, opacity)

	return transition.execute(target, action, args)
end

function transition.scaleTo(target, args)
	assert(not tolua.isnull(target), "transition.scaleTo() - target is not cc.Node")

	local action = nil

	if args.scale then
		action = cc.ScaleTo:create(checknumber(args.time), checknumber(args.scale))
	elseif args.scaleX or args.scaleY then
		local scaleX, scaleY = nil

		if args.scaleX then
			scaleX = checknumber(args.scaleX)
		else
			scaleX = target:getScaleX()
		end

		if args.scaleY then
			scaleY = checknumber(args.scaleY)
		else
			scaleY = target:getScaleY()
		end

		action = cc.ScaleTo:create(checknumber(args.time), scaleX, scaleY)
	end

	return transition.execute(target, action, args)
end

function transition.sequence(actions)
	if #actions < 1 then
		return
	end

	if #actions < 2 then
		return actions[1]
	end

	local prev = actions[1]

	for i = 2, #actions do
		prev = cc.Sequence:create(prev, actions[i])
	end

	return prev
end

function transition.playAnimationOnce(target, animation, removeWhenFinished, onComplete, delay)
	local actions = {}

	if type(delay) == "number" and delay > 0 then
		target:setVisible(false)

		actions[#actions + 1] = cc.DelayTime:create(delay)
		actions[#actions + 1] = cc.Show:create()
	end

	actions[#actions + 1] = cc.Animate:create(animation)

	if removeWhenFinished then
		actions[#actions + 1] = cc.RemoveSelf:create()
	end

	if onComplete then
		actions[#actions + 1] = cc.CallFunc:create(onComplete)
	end

	local action = nil

	if #actions > 1 then
		action = transition.sequence(actions)
	else
		action = actions[1]
	end

	target:runAction(action)

	return action
end

function transition.playAnimationForever(target, animation, delay)
	local animate = cc.Animate:create(animation)
	local action = nil

	if type(delay) == "number" and delay > 0 then
		target:setVisible(false)

		local sequence = transition.sequence({
			cc.DelayTime:create(delay),
			cc.Show:create(),
			animate
		})
		action = cc.RepeatForever:create(sequence)
	else
		action = cc.RepeatForever:create(animate)
	end

	target:runAction(action)

	return action
end

function transition.removeAction(action)
	if not tolua.isnull(action) then
		actionManager:removeAction(action)
	end
end

function transition.stopTarget(target)
	if not tolua.isnull(target) then
		actionManager:removeAllActionsFromTarget(target)
	end
end

function transition.pauseTarget(target)
	if not tolua.isnull(target) then
		actionManager:pauseTarget(target)
	end
end

function transition.resumeTarget(target)
	if not tolua.isnull(target) then
		actionManager:resumeTarget(target)
	end
end

return transition
