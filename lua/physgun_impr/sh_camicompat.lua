

-- actually screw that, if your admin mod sucks and cant do sync permissions, then you should swap it out
function PhysImpr.HasCAMIAccess(actor, permName, target)
	local perm = permName

	if ULib and ulx then
		-- use ULX's permissions
		perm = "ulx " .. perm
	end

	return CAMI.PlayerHasAccess(actor, perm, nil, target)
end


--[==================================[
	old async code below
--]==================================]

-- CAMI access is async and requires a coroutine

--[[
function PhysImpr.HasCAMIAccess(actor, permName, target)
	if not CAMI then
		-- !?
		return actor:IsAdmin()
	end

	local cor = coroutine.running()
	if not cor then
		ErrorNoHalt("ERROR: PhysImpr.HasAccess can only be called from a coroutine!\n")
		return false
	end

	local perm = permName

	if ULib and ulx then
		-- use ULX's permissions
		perm = "ulx " .. perm
	end

	local done = false
	local yielded = false

	CAMI.PlayerHasAccess(actor, perm, function(...) -- ew, cami is async?
		-- im guessing cami allows instant returns, so we'd resume before yielding
		-- so we have to do this ugliness instead
		done = {...}

		if yielded then
			coroutine.resume(cor, ...)
		end
	end, target)

	if not done then
		-- CAMI callback still running; yield and wait for it
		yielded = true
		return coroutine.yield()
	else
		-- CAMI callback ran instantly; just return what it gave us
		return unpack(done)
	end
end
]]