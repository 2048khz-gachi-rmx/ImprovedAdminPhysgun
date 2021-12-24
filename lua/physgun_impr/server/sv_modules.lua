include("_settings.lua")

PhysImpr.Modules = PhysImpr.Modules or {}

local mod = PhysImpr.Modules
mod.Registered = mod.Registered or {}

function mod.Register(id, perm)
	local stKey = "Module_" .. id
	local state = PhysImpr.Settings.Get(stKey)

	if state == nil then -- no setting; initial add
		state = true
		PhysImpr.Settings.Set(stKey, state)
	end

	mod.Registered[id] = {
		ID = id,
		Name = id, -- default
		Permissions = istable(perm) and perm or {perm}, -- table-ify `perm`
		State = state,
	}


	return mod.Registered[id]
end

function mod.SwitchState(id, to)
	if not mod.Registered[id] then
		ErrorNoHalt("ERROR: No such PhysImpr module: " .. tostring(id) .. "\n")
		return
	end

	mod.Registered[id].State = to

	local stKey = "Module_" .. id
	local state = PhysImpr.Settings.Set(stKey, to)

	net.Start("Phys_UpdateModule")
		net.WriteString(id)
		net.WriteBool(to)
	net.Broadcast()
end

PhysImpr.RecursiveInclude("server/modules", false, true)