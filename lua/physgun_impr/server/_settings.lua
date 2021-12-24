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
	PhysImpr.Known[ply] = PhysImpr.Known[ply] or {}

	for k,v in pairs(PhysImpr.Modules.Registered) do
		if not PhysImpr.Known[ply][k] then
			toAdd[#toAdd + 1] = v
		end
	end

	net.Start("Phys_RequestModules")
		net.WriteUInt(#toAdd, 8)
		for k,v in ipairs(toAdd) do
			net.WriteString(v.ID)
			net.WriteString(v.Name)
			net.WriteBool(v.State)
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