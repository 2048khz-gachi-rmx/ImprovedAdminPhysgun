local mod = PhysImpr.Modules.Register("PlayerFreeze", "PlayerFreeze")
mod.Name = "Freeze players via RMB"

local nomove = mod:AddSubModule("DisableMovement")
nomove.Name = "Freeze players in-place, disabling movement entirely"

local nodmg = mod:AddSubModule("Damage")
nodmg.Name = "Frozen players don't take damage"

local noarr = mod:AddSubModule("NoArrest")
noarr.Name = "[experimental] Frozen players cannot be arrested"
noarr.IsRP = true

PhysImpr.Frozen = {}

function PhysImpr.FreezeEffect(ply)
	PhysImpr.StartVis("PlayerFreeze")
		net.WriteEntity(ply)
	PhysImpr.SendVis()
end

function PhysImpr.UnfreezeEffect(ply)
	PhysImpr.StartVis("PlayerUnfreeze")
		net.WriteEntity(ply)
	PhysImpr.SendVis()
end

function PhysImpr.UnfreezeIfFrozen(adm)
	local ply = PhysImpr.GetHeldPlayer(adm)

	local frozen = ply and PhysImpr.Frozen[ply]

	if frozen and engine.TickCount() > frozen then
		PhysImpr.TryFreeze(adm, ply, true)
		PhysImpr.UnfreezeEffect(ply)
		PhysImpr.Frozen[ply] = nil
	end
end

hook.Add("PhysImpr_ReleasePlayer", "PhysImpr_FreezeUntrack", function(adm, ent)
	if not mod.State then return end
	if not ent:IsPlayer() then return end
	if not PhysImpr.Perms.Has(adm, "PlayerFreeze") then return end

	PhysImpr.UnfreezeIfFrozen(adm)
end)

hook.Add("FinishMove", "PhysImpr_Freeze", function(ply, mv)
	if not mod.State then return end
	if not nomove.State then return end
	if not PhysImpr.Frozen[ply] then return end

	return true -- sauce engine drops the player slowly unless i do this
end)

-- Using SetupMove because addons may decide to prevent keys from StartCommand
hook.Add("SetupMove", "PhysImpr_Freeze", function(ply, mv, cmd)
	if not mod.State then return end

	-- dumb bug where frozen players get negative vertical velocity,
	-- even if held by physgun             VVV
	if PhysImpr.Frozen[ply] and PhysImpr.IsHeld(ply) then
		mv:SetVelocity(vector_origin)
		return
	end

	local tgt = PhysImpr.GetHeldPlayer(ply)
	if not tgt then return end

	if bit.band(cmd:GetButtons(), IN_ATTACK2) == 0 then return end

	-- RMB pressed, do the epic freeze
	local ok = PhysImpr.TryFreeze(ply, tgt, false)
	if ok then
		PhysImpr.FreezeEffect(tgt)
		PhysImpr.Frozen[tgt] = engine.TickCount()
	end
end)

local sfx_ric = {
	"physics/glass/glass_impact_bullet1.wav",
	"physics/glass/glass_impact_bullet2.wav",
	"physics/glass/glass_impact_bullet3.wav",
	"physics/glass/glass_impact_bullet4.wav",
}

hook.Add("PlayerShouldTakeDamage", "PhysImpr_FreezeDamage", function(ply, atk)
	if not mod:GetSubState(nodmg) then return end

	if PhysImpr.Frozen[ply] then
		local snd = sfx_ric[math.random(#sfx_ric)]
		ply:EmitSound(snd, 70, math.random(90, 110), 0.8)
		return false
	end
end)

hook.Add("canArrest", "PhysImpr_FreezeNoArrest", function(arrester, arrestee)
	if not mod:GetSubState(noarr) then return end

	if PhysImpr.Frozen[arrestee] then
		return false, "Arresting frozen players was disabled."
	end
end)