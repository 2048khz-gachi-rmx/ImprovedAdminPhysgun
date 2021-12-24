PhysImpr.Vis = PhysImpr.Vis or {}

PhysImpr.Vis.Enums = {
	"PlayerFreeze",
	"PlayerUnfreeze",
	"PlayerLand",
}

for k,v in ipairs(PhysImpr.Vis.Enums) do
	if isstring(v) then
		PhysImpr.Vis.Enums[v] = k
	end
end

if SERVER then
	util.AddNetworkString("PhysImpr_Vis")

	function PhysImpr.StartVis(what)
		-- this is only here so i dont have to make a separate file
		assert(isnumber(PhysImpr.Vis.Enums[what]), "no such vis registered: " .. tostring(what))

		net.Start("PhysImpr_Vis")
			net.WriteUInt(PhysImpr.Vis.Enums[what], 8)
	end

	function PhysImpr.SendVis(to)
		if to then
			net.Send(to)
		else
			net.Broadcast()
		end
	end

	--[[
	PhysImpr.StartVis("PlayerFreeze")
		net.Write...
	PhysImpr.SendVis()
	]]
else
	net.Receive("PhysImpr_Vis", function()
		local id = net.ReadUInt(8)
		local name = PhysImpr.Vis.Enums[id]

		assert(isstring(name), "received unknown vis ID: " .. id)
		assert(PhysImpr.Vis[name], "unhandled vis function: " .. tostring(name))

		PhysImpr.Vis[name]()
	end)
end