-- mfw no funny lib
PhysImpr = PhysImpr or {}

local root = "physgun_impr/"

local function recInc(sub, cl, sv)
	local path = (root .. sub):gsub("/$", "") .. "/" -- force a / at the end

	local should_inc =
		CLIENT and (cl == nil or cl) or
		SERVER and (sv == nil or sv)

	local should_share = SERVER and (cl == nil or cl)

	for k,v in ipairs(file.Find(path .. "*.lua", "LUA")) do
		local fn = path .. v
		if fn:match("/_.+%.lua$") then continue end -- ignore lua files starting with _

		if should_inc then
			include(fn)
		end

		if should_share then
			AddCSLuaFile(fn)
		end
	end
end

PhysImpr.RecursiveInclude = recInc

recInc("", true, true) -- everything in root is shared
recInc("server", false, true)
recInc("client", true, false)
