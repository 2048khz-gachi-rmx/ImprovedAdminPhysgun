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

