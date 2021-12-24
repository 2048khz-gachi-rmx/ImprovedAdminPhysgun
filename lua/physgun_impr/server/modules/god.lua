local mod = PhysImpr.Modules.Register("God", "God")
mod.Name = "Held players are immune to damage"

local sfx_ric = {
	"weapons/fx/rics/ric1.wav",
	"weapons/fx/rics/ric2.wav",
	"weapons/fx/rics/ric3.wav",
	"weapons/fx/rics/ric4.wav",
	"weapons/fx/rics/ric5.wav",
}

hook.Add("PlayerShouldTakeDamage", "PhysImpr_NoDying", function(ply, atk)
	if not mod.State then return end
	if PhysImpr.IsHeld(ply) then
		local snd = sfx_ric[math.random(#sfx_ric)]
		ply:EmitSound(snd, 70, math.random(90, 110), 0.8)
		return false
	end
end)
