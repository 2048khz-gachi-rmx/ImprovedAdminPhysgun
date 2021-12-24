PhysImpr.Admin = PhysImpr.Admin or {}

-- async coroutine
function PhysImpr.TryFreeze(actor, target, unfreeze)
	local permName = unfreeze and "unfreeze" or "freeze"

	local has = PhysImpr.HasCAMIAccess(actor, permName, target)
	if not has then return end

	--[[if ulx then
		ulx.freeze(actor, {target}, unfreeze)
	else
		ply:Freeze(not unfreeze)
	end]]

	-- using ULX seemed like a good idea, however,
	-- it prevents you from picking up players frozen via ulx
	-- (which kills unfreeze-on-pickup)

	target:Freeze(not unfreeze)
end

PhysImpr.TryFreeze = PhysImpr.Util.Coroutinify(PhysImpr.TryFreeze)