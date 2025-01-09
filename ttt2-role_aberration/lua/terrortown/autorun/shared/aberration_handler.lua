--Download icons automatically
if SERVER then
	resource.AddFile("materials/vgui/ttt/icon_aberration_health.vmt")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_abe.vmt")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_abe1.png")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_abe2.png")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_abe3.png")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_abe4.png")
	resource.AddFile("materials/vgui/ttt/dynamic/roles/regen_abe.png")
end

--heal timer that sets the time to the current time plus the number of seconds we want to wait
heal_time = (CurTime() + GetConVar("ttt2_abe_healing_interval"):GetInt())

--Think hook that iterates through players
--Heals each abeant every time we need to
hook.Add("Think","abeHealThink", function()
	if GetRoundState() ~= ROUND_ACTIVE then return end
	if heal_time > CurTime() then return end
	for _, ply in ipairs( player.GetAll() ) do
		if not ply:Alive() or ply:IsSpec() then continue end
		if ply:GetSubRole() ~= ROLE_ABERRATION then continue end
		if ply:Health() <= ply:GetMaxHealth() - GetConVar("ttt2_abe_healing_amount"):GetInt() then
			ply:SetHealth(ply:Health()+ GetConVar("ttt2_abe_healing_amount"):GetInt())
			STATUS:AddStatus(ply, "ttt2_abe_regen", false)
		else 
			ply:SetHealth(math.max(ply:GetMaxHealth(),ply:Health()))
			STATUS:AddStatus(ply, "ttt2_abe_regen", false)
		end
	end
	heal_time = (CurTime() + GetConVar("ttt2_abe_healing_interval"):GetInt())
end) 