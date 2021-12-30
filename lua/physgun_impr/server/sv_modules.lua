include("_settings.lua")

PhysImpr.Modules = PhysImpr.Modules or {}

local mods = PhysImpr.Modules
mods.Registered = mods.Registered or {}

PhysImpr.Module = PhysImpr.Module or {}
local mod = PhysImpr.Module
mod.IsModule = true
local meta = {__index = PhysImpr.Module}

function mods.Register(id)
	local stKey = "Module_" .. id
	local state = PhysImpr.Settings.Get(stKey)

	if state == nil then -- no setting; initial add
		state = true
		PhysImpr.Settings.Set(stKey, state)
	end

	mods.Registered[id] = setmetatable({
		ID = id,
		Name = id, -- default
		State = state,
		IsSubModule = false,
		SubModules = {},
		Known = {} -- table of what players are aware of this module
	}, meta)


	return mods.Registered[id]
end

function mod:AddSubModule(name)
	local subName = "sub_" .. self.ID .. "_" .. name
	local sub = mods.Register(subName)
	sub.IsSubModule = true

	self.SubModules[name] = sub
	self.SubModules[subName] = sub

	self.Known = {}

	return sub
end

function mod:GetSubState(name)
	if not self.State then return false end

	if istable(name) and name.IsModule then
		-- passed submodule? see if its ours, and if it is, return its' state
		return self.SubModules[name.ID] and name.State
	elseif isstring(name) then
		-- match by submodule name
		return self.SubModules[name] and self.SubModules[name].State
	end
end

function mods.SwitchState(id, to)
	if not mods.Registered[id] then
		ErrorNoHalt("ERROR: No such PhysImpr module: " .. tostring(id) .. "\n")
		return
	end

	mods.Registered[id].State = to

	local stKey = "Module_" .. id
	local state = PhysImpr.Settings.Set(stKey, to)

	net.Start("Phys_UpdateModule")
		net.WriteString(id)
		net.WriteBool(to)
	net.Broadcast()
end

PhysImpr.RecursiveInclude("server/modules", false, true)