local mod = PhysImpr.Modules.Register("FallProtect", "FallProtect")
mod.Name = "Released players don't take fall damage"

PhysImpr.FallPrevent = PhysImpr.FallPrevent or {}

function PhysImpr.PreventNextFall(ent)
	PhysImpr.FallPrevent[ent] = true
end

function PhysImpr.PreventFallDamage(ent)
	if not mod.State then return end
	if not PhysImpr.FallPrevent[ent] then return end

	local tick = PhysImpr.FallPrevent[ent]

	-- not number = didnt hit ground before taking fall damage (!?)
	-- number = what tick they hit the ground; if they hit it this tick
	-- then we're taking damage from that landing (=> prevent it)

	if not isnumber(tick) or tick == engine.TickCount() then
		return 0
	else
		-- didnt match; clean up any data we had
		PhysImpr.FallPrevent[ent] = nil
	end
end

function PhysImpr.ResetFallProtection(ent)
	PhysImpr.FallPrevent[ent] = engine.TickCount()
end

hook.Add("GetFallDamage", "PhysImpr_NoFall", PhysImpr.PreventFallDamage)
hook.Add("OnPlayerHitGround", "PhysImpr_FallUnprotect", function(ply)
	PhysImpr.ResetFallProtection(ply)
end)

hook.Add("OnPhysgunPickup", "PhysImpr_ProtectFall", function(pick, ent)
	if not ent:IsPlayer() then return end
	if not PhysImpr.Perms.Has(pick, "ProtectFall") then return end

	PhysImpr.PreventNextFall(ent)
end)
