local mod = PhysImpr.Modules.Register("ResetVelocity", "ResetVelocity")
mod.Name = "Reset velocity of dropped players"

function PhysImpr.ResetVelocity(dropper, ent)
	if not mod.State then return end
	if not ent:IsPlayer() then return end

	local vel = -ent:GetVelocity()
	vel.x = 0
	vel.y = 0

	ent:SetVelocity(vel) -- only touch their z velocity
end

hook.Add("PhysgunDrop", "PhysImpr_ResetVelocity", PhysImpr.ResetVelocity)

