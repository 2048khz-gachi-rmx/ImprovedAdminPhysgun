-- a e o
PhysImpr.Util = PhysImpr.Util or {}

function PhysImpr.Util.Coroutinify(fn)
	return function(...)
		return coroutine.wrap(fn)(...)
	end
end

PhysImpr.HoldingPlayers = {} -- [admin] = holdingWho
PhysImpr.HeldPlayers = {} -- [holdingWho] = admin (don't rely on multi-admin holding)

hook.Add("OnPhysgunPickup", "PhysImpr_FreezeTrack", function(adm, ent)
	if not ent:IsPlayer() then return end

	hook.Run("PhysImpr_HoldPlayer", adm, ent)
	PhysImpr.HoldingPlayers[adm] = ent
	PhysImpr.HeldPlayers[ent] = adm
end)

hook.Add("PhysgunDrop", "PhysImpr_FreezeUntrack", function(adm, ent)
	if not ent:IsPlayer() then return end
	if not PhysImpr.HoldingPlayers[adm] then return end

	hook.Run("PhysImpr_ReleasePlayer", adm, PhysImpr.HoldingPlayers[adm])
	PhysImpr.HoldingPlayers[adm] = nil
	PhysImpr.HeldPlayers[ent] = nil
end)

function PhysImpr.GetHeldPlayer(adm)
	local ply = PhysImpr.HoldingPlayers[adm]
	return (ply and ply:IsValid()) and ply
end

function PhysImpr.IsHeld(ply)
	local ply = PhysImpr.HeldPlayers[ply]
	return ply and true
end

include("sh_cami.lua")
PhysImpr.SettingsPriv = CAMI.RegisterPrivilege({
	Name = "ImprovedPhysgunSettings",
	MinAccess = "superadmin"
})