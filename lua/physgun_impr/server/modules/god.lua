local mod = PhysImpr.Modules.Register("God", "God")
mod.Name = "Held players are immune to damage"

hook.Add("PlayerShouldTakeDamage", "PhysImpr_NoDying", function(ply, atk)
	if not mod.State then return end
	if PhysImpr.IsHeld(ply) then return false end
end)
