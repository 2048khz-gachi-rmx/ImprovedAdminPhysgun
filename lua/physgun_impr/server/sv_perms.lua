PhysImpr.Perms = PhysImpr.Perms or {}

-- This should not be used; use CAMI instead
local complained = false

function PhysImpr.Perms.Has(ply, what)
	if not complained then
		MsgC(Color(50, 150, 250), "[ImprovedPhysgun] ",
			color_white, "PhysImpr.Perms.Has is deprecated, and will be (eventually) removed. Stop using it.")

		debug.Trace()
		complained = true
	end

	return ply:IsAdmin() or ply:IsSuperAdmin() -- ??
end