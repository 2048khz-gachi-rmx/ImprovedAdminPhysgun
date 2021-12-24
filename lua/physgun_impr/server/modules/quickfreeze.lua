local mod = PhysImpr.Modules.Register("PlayerFreeze", "PlayerFreeze")
mod.Name = "Freeze players via RMB"

PhysImpr.Frozen = {}

function PhysImpr.UnfreezeIfFrozen(adm)
	local ply = PhysImpr.GetHeldPlayer(adm)

	local frozen = ply and PhysImpr.Frozen[ply]

	if frozen and engine.TickCount() > frozen then
		PhysImpr.TryFreeze(adm, ply, true)
		PhysImpr.Frozen[ply] = nil
	end
end

hook.Add("PhysImpr_ReleasePlayer", "PhysImpr_FreezeUntrack", function(adm, ent)
	if not mod.State then return end
	if not ent:IsPlayer() then return end
	if not PhysImpr.Perms.Has(adm, "PlayerFreeze") then return end

	PhysImpr.UnfreezeIfFrozen(adm)
end)

-- Using SetupMove because addons may decide to prevent keys from StartCommand
hook.Add("SetupMove", "PhysImpr_Freeze", function(ply, mv, cmd)
	if not mod.State then return end

	if PhysImpr.Frozen[ply] and PhysImpr.IsHeld(ply) then
		-- dumb bug where frozen players get negative vertical velocity,
		-- even if held by physgun
		mv:SetVelocity(vector_origin)
		return
	end

	local tgt = PhysImpr.GetHeldPlayer(ply)
	if not tgt then return end

	if bit.band(cmd:GetButtons(), IN_ATTACK2) == 0 then return end

	-- RMB pressed, do the epic freeze
	PhysImpr.TryFreeze(ply, tgt, false)
	PhysImpr.Frozen[tgt] = engine.TickCount()
end)

