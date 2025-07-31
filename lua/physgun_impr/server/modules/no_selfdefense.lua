--har har get abused dummy
local mod = PhysImpr.Modules.Register("NoAttack", "NoAttack")
mod.Name = "Held players cannot attack"

hook.Add("StartCommand", "PhysImpr_NoAttacking", function(ply, cmd)
	if not mod.State then return end
	if not PhysImpr.IsHeld(ply) then return end

	-- held players cant use +attack and +attack2
	local btn = cmd:GetButtons()
	btn = bit.band(btn, bit.bnot(IN_ATTACK, IN_ATTACK2))

	cmd:SetButtons(btn)
end)

-- When grabbed, set ent.l_WeaponUseCooldown to math.huge to prevent the lambda players from firing
-- When released, restore it back to what it was
hook.Add("PhysImpr_HoldPlayer", "PhysImpr_NoAttacking_LambdaCompat", function(adm, ent)
	if not PhysImpr.IsLambdaPlayer(ent) then return end

	ent._realWeaponCooldown = ent.l_WeaponUseCooldown ~= math.huge and ent.l_WeaponUseCooldown or ent._realWeaponCooldown
	ent.l_WeaponUseCooldown = math.huge
end)

hook.Add("PhysImpr_ReleasePlayer", "PhysImpr_NoAttacking_LambdaCompat", function(adm, ent)
	if not PhysImpr.IsLambdaPlayer(ent) then return end
	if not ent._realWeaponCooldown then return end
	if ent.l_WeaponUseCooldown ~= math.huge then return end

	ent.l_WeaponUseCooldown = ent._realWeaponCooldown
	ent._realWeaponCooldown = nil
end)
