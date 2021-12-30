--
PhysImpr.Settings = PhysImpr.Settings or {}
PhysImpr.Settings.Data = PhysImpr.Settings.Data or {}

local fn = "physimpr_settings.dat"

function PhysImpr.Settings.Get(key, def)
	local ret = PhysImpr.Settings.Data[key]
	if ret == nil then return def end

	return ret
end

function PhysImpr.Settings.Set(key, val)
	PhysImpr.Settings.Data[key] = val

	if not timer.Exists("Phys_SettingsFlush") then
		timer.Create("Phys_SettingsFlush", 1, 1, PhysImpr.Settings.Flush)
	end
end

function PhysImpr.Settings.Flush()
	local json = util.TableToJSON(PhysImpr.Settings.Data, true)
	file.Write(fn, json)
end

-- load initial settings
local datJson = file.Read(fn, "DATA")
local dat = datJson and util.JSONToTable(datJson) or {}
for k,v in pairs(dat) do
	PhysImpr.Settings.Data[k] = v
end


PhysImpr.Known = {}

util.AddNetworkString("Phys_RequestModules")
util.AddNetworkString("Phys_UpdateModule")

local function writeModule(mod)
	net.WriteString(mod.ID)
	net.WriteString(mod.Name)
	net.WriteBool(mod.State)
end

function PhysImpr.Net_SendModules(ply)
	local has_access = ply:IsSuperAdmin()
	if not has_access and CAMI then
		has_access = PhysImpr.HasCAMIAccess(ply, PhysImpr.SettingsPriv.Name)
	end

	if not has_access then
		return
	end

	-- is this a good idea? probably not, but it can only be used
	-- by admins anyways, so this should be fine

	local toAdd = {}
	local toAddSubs = {}


	for k,v in pairs(PhysImpr.Modules.Registered) do
		if v.IsSubModule then continue end -- dont care

		local subs = {}

		for _, sub in pairs(v.SubModules) do
			if not sub.Known[ply] and
				hook.Run("PhysImpr_ShouldSendSubmodule", ply, v, sub) ~= false then
				subs[#subs + 1] = sub
				sub.Known[ply] = true -- yea
			end
		end

		-- player knows about module; any new submodules tho?
		if v.Known[ply] and #subs == 0 then
			continue -- skip this module; no new submodules either
		end

		if hook.Run("PhysImpr_ShouldSendModule", ply, v) == false then
			continue
		end

		-- either the module is new or there are new submodules

		toAddSubs[#toAddSubs + 1] = subs
		toAdd[#toAdd + 1] = v
		v.Known[ply] = true
	end

	net.Start("Phys_RequestModules")
		net.WriteUInt(#toAdd, 8)

		for k, mod in ipairs(toAdd) do
			writeModule(mod)

			local subs = toAddSubs[k]

			net.WriteUInt(#subs, 8)
			for _, sub in ipairs(subs) do
				writeModule(sub)
			end
		end
	net.Send(ply)
end

PhysImpr.Net_SendModules = PhysImpr.Util.Coroutinify(PhysImpr.Net_SendModules)



function PhysImpr.Net_UpdateModule(ply)
	local has_access = ply:IsSuperAdmin()
	if not has_access and CAMI then
		has_access = PhysImpr.HasCAMIAccess(ply, PhysImpr.SettingsPriv.Name)
	end

	if not has_access then
		return
	end

	local what = net.ReadString()
	local to = net.ReadBool()

	PhysImpr.Modules.SwitchState(what, to)
end

PhysImpr.Net_UpdateModule = PhysImpr.Util.Coroutinify(PhysImpr.Net_UpdateModule)

net.Receive("Phys_RequestModules", function(len, ply) PhysImpr.Net_SendModules(ply) end)
net.Receive("Phys_UpdateModule", function(len, ply) PhysImpr.Net_UpdateModule(ply) end)


hook.Add("PhysImpr_ShouldSendModule", "HideRP", function(ply, mod)
	if mod.IsRP and not DarkRP then
		return false
	end
end)

hook.Add("PhysImpr_ShouldSendSubmodule", "HideRP", function(ply, mod, sub)
	if sub.IsRP and not DarkRP then
		return false
	end
end)