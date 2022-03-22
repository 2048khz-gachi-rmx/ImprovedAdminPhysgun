PhysImpr.Admin = PhysImpr.Admin or {}


function PhysImpr.TryFreeze(actor, target, unfreeze)
	if unfreeze then
		return PhysImpr.TryUnfreeze(actor, target)
	end

	local permName = "freeze"

	if actor then
		local has = PhysImpr.HasCAMIAccess(actor, permName, target)
		if not has then return false end
	end

	--[[if ulx then
		ulx.freeze(actor, {target}, unfreeze)
	else
		ply:Freeze(not unfreeze)
	end]]

	-- using ULX seemed like a good idea, however,
	-- it prevents you from picking up players frozen via ulx
	-- (which kills unfreeze-on-pickup)

	target:Freeze(true)

	return true
end

-- PhysImpr.TryFreeze = PhysImpr.Util.Coroutinify(PhysImpr.TryFreeze)

function PhysImpr.TryUnfreeze(actor, target)
	local permName = unfreeze and "unfreeze"

	if actor then
		local has = PhysImpr.HasCAMIAccess(actor, permName, target)
		if not has then return false end
	end

	target:Freeze(false)

	return true
end