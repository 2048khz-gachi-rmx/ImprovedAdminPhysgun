PhysImpr.Perms = PhysImpr.Perms or {}

function PhysImpr.Perms.Has(ply, what)
	return ply:IsAdmin() or ply:IsSuperAdmin() -- ??
end