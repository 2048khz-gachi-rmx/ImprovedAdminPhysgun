--
PhysImpr.Vis = PhysImpr.Vis or {}
local vis = PhysImpr.Vis

local sfx_freeze = {
	"physics/glass/glass_strain1.wav",
	"physics/glass/glass_strain2.wav",
	"physics/glass/glass_strain3.wav",
}

local sfx_unfreeze = {
	"physics/glass/glass_impact_bullet1.wav",
	"physics/glass/glass_impact_bullet2.wav",
	"physics/glass/glass_impact_bullet3.wav",
	"physics/glass/glass_impact_bullet4.wav",
}

function vis.PlayerFreeze()
	local snd = sfx_freeze[math.random(#sfx_freeze)]
	local ply = net.ReadEntity()

	ply:EmitSound(snd)

	local ef = EffectData()
	ef:SetEntity(ply)
	ef:SetOrigin(ply:GetPos())

	util.Effect("phys_freeze", ef)
end

function vis.PlayerUnfreeze()
	local snd = sfx_unfreeze[math.random(#sfx_unfreeze)]
	local ply = net.ReadEntity()

	ply:EmitSound(snd)

	local ef = EffectData()
	ef:SetEntity(ply)
	ef:SetOrigin(ply:GetPos())

	util.Effect("phys_unfreeze", ef)
end

local sfx_impsoft = {
	"npc/dog/dog_footstep1.wav",
	"npc/dog/dog_footstep2.wav",
	"npc/dog/dog_footstep3.wav",
	"npc/dog/dog_footstep4.wav",
}

local sfx_imphard = {
	"physics/concrete/boulder_impact_hard1.wav",
	"physics/concrete/boulder_impact_hard2.wav",
	"physics/concrete/boulder_impact_hard3.wav",
	"physics/concrete/boulder_impact_hard4.wav"
}

function vis.PlayerLand()
	local pos = net.ReadVector()
	local int = net.ReadUInt(16)

	local snd
	local efName = "ThumperDust"

	if int < 140 then
		snd = sfx_impsoft[math.random(#sfx_impsoft)]
		efName = nil
	else
		snd = sfx_imphard[math.random(#sfx_imphard)]
	end

	sound.Play(snd, pos, 90, 100, 1)

	if efName then
		local ef = EffectData()
		ef:SetOrigin(pos)
		ef:SetNormal(vector_up)
		ef:SetScale(int)

		util.Effect(efName, ef)
	end
end