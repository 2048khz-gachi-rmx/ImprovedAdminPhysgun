-- e
PhysImpr.Modules = PhysImpr.Modules or {}

local function tryOpen(ply)
	local has_access = ply:IsSuperAdmin()
	if not has_access and CAMI then
		has_access = PhysImpr.HasCAMIAccess(ply, PhysImpr.SettingsPriv.Name)
	end

	if not has_access then
		ply:ChatPrint("No access!")
		return
	end

	gui.HideGameUI()

	net.Start("Phys_RequestModules")
	net.SendToServer()
end

concommand.Add("improved_physgun_settings", function(...) coroutine.wrap(tryOpen)(...) end)

surface.CreateFont("PhysImp_SettingFont", {
	font = "Roboto", -- bundled with gmod, ez
	size = 16,
	weight = 400,
})

surface.CreateFont("PhysImp_SettingTitleFont", {
	font = "Roboto",
	size = 24,
	weight = 800,
})


local function Ease(num, how) --garry easing
	num = math.Clamp(num, 0, 1)
	local Frac = 0

	if ( how < 0 ) then
		Frac = num ^ ( 1.0 - ( num - 0.5 ) ) ^ -how
	elseif ( how > 0 and how < 1 ) then
		Frac = 1 - ( ( 1 - num ) ^ ( 1 / how ) )
	else --how > 1 = ease in
		Frac = num ^ how
	end

	return Frac
end

local function LerpColor(frac, col, dest, src)
	col.r = Lerp(frac, src.r, dest.r)
	col.g = Lerp(frac, src.g, dest.g)
	col.b = Lerp(frac, src.b, dest.b)

	local sA, c1A, c2A = src.a, col.a, dest.a

	if sA ~= c2A or c1A ~= c2A then
		col.a = Lerp(frac, sA, c2A)
	end
end

local function btnThink(self)
	-- mfw no :To
	local hov = self:IsHovered()
	local appr = FrameTime() * (hov and -4 or 4)
	self.HovFrac = math.Approach(self.HovFrac, hov and 1 or 0, appr)

	-- the maths behind this make 0 sense but whatever
	self.EasedFrac = hov and Ease(self.HovFrac, 0.3) or Ease(self.HovFrac, 2.3)

	local dat = PhysImpr.Modules[self.ID]
	appr = FrameTime() * (dat.State and -4 or 4)

	self.KnobFrac = math.Approach(self.KnobFrac, dat.State and 1 or 0, appr)
	self.EasedKnobFrac = dat.State and Ease(self.KnobFrac, 0.3) or Ease(self.KnobFrac, 2.3)
end


local active = Color(60, 100, 175)
local deactive = Color(75, 75, 75)

local knobactive = Color(110, 170, 245)
local knobdeactive = Color(105, 105, 105)

local cur = Color(0, 0, 0)
local knobcur = Color(0, 0, 0)
local white = Color(255, 255, 255)

local function btnPaint(self, w, h)
	local fr = self.EasedFrac or 0

	-- dim
	surface.SetDrawColor(0, 0, 0, fr * 120)
	surface.DrawRect(0, 0, w, h)

	local kfr = self.EasedKnobFrac or 0

	-- knob
	LerpColor(1 - kfr, cur, deactive, active)
	LerpColor(1 - kfr, knobcur, knobdeactive, knobactive)

	local knob = 16
	local kw = 42
	local kh = 8

	local x = 8
	local x1 = x + kw * 0.05
	local x2 = x + kw * 0.95 - knob / 2
	local kx = Lerp(kfr, x1, x2)

	draw.RoundedBox(kh / 2, x + knob / 2, h / 2 - kh / 2, kw - knob / 2, kh, cur)
	draw.RoundedBox(knob / 2, kx, h / 2 - knob / 2, knob, knob, knobcur)

	local tx = kw + x + knob / 2 + 8

	white.a = 65 + fr * (255 - 65)
	draw.SimpleText(self.Name, "PhysImp_SettingFont", tx, h / 2, white, 0, 1)
end

local function makeSetting(scr, dat)
	local btn = vgui.Create("DButton", scr)
	btn:SetTall(32)
	btn:Dock(TOP)

	btn.HovFrac = 0
	btn.KnobFrac = dat.State and 1 or 0

	btn.Name = dat.Name
	btn.ID = dat.ID -- tables may be replaced; index by ID

	btn.Paint = btnPaint
	btn.Think = btnThink
	btn:SetText("")

	function btn:DoClick()
		net.Start("Phys_UpdateModule")
			net.WriteString(self.ID)
			net.WriteBool(not dat.State)
		net.SendToServer()
	end
end

function PhysImpr.OpenSettingsGUI()
	local f = vgui.Create("PhysFrame")
	f:SetSize(400, 350)
	f:Center()
	f:MakePopup()

	f:SetAlpha(0)
	f:AlphaTo(255, 0.1, 0)

	-- move right to left
	f:SetX(f:GetX() + 16)
	f:MoveBy(-16, 0, 1.2, 0, 0.1)

	local lbl = vgui.Create("DLabel", f)
	lbl:Dock(TOP)
	lbl:SetText("Improved Physgun Settings")
	lbl:SetFont("PhysImp_SettingTitleFont")
	lbl:SizeToContents()
	lbl:SetContentAlignment(5)
	lbl:DockMargin(0, 4, 0, 8)

	local scr = vgui.Create("DScrollPanel", f)
	scr:Dock(FILL)

	for id, dat in SortedPairs(PhysImpr.Modules) do
		makeSetting(scr, dat)
	end
end


net.Receive("Phys_RequestModules", function()
	local new = net.ReadUInt(8)
	for i=1, new do
		local id, name = net.ReadString(), net.ReadString()

		PhysImpr.Modules[id] = {
			ID = id,
			Name = name,
			State = net.ReadBool()
		}
	end

	PhysImpr.OpenSettingsGUI()
end)

net.Receive("Phys_UpdateModule", function()
	local id = net.ReadString()
	if not PhysImpr.Modules[id] then
		PhysImpr.Modules[id] = {
			Name = id,
			ID = id,
		}
	end

	PhysImpr.Modules[id].State = net.ReadBool()
end)