if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("SendAberrationDamage")
end

function ROLE:PreInitialize()
  self.color = Color(48, 15, 13, 255)

  self.abbr = "abe" -- abbreviation
  self.surviveBonus = 0.5 -- bonus multiplier for every survive while another player was killed
  self.scoreKillsMultiplier = 5 -- multiplier for kill of player of another team
  self.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
  self.preventFindCredits = false
  self.preventKillCredits = false
  self.preventTraitorAloneCredits = false
  
  self.isOmniscientRole = true

  self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
  self.defaultTeam = TEAM_TRAITOR

  self.conVarData = {
    pct = 0.17, -- necessary: percentage of getting this role selected (per player)
    maximum = 1, -- maximum amount of roles in a round
    minPlayers = 6, -- minimum amount of players until this role is able to get selected
    credits = 1, -- the starting credits of a specific role
    togglable = true, -- option to toggle a role for a client if possible (F1 menu)
    random = 50,
    traitorButton = 1, -- can use traitor buttons
    shopFallback = SHOP_DISABLED
  }
end

-- now link this subrole with its baserole
function ROLE:Initialize()
  roles.SetBaseRole(self, ROLE_TRAITOR)
end

if SERVER then
   -- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if not GetConVar("ttt2_abe_firedmg"):GetBool() then
			ply:GiveEquipmentItem("item_ttt_nofiredmg")
		end
		if not GetConVar("ttt2_abe_explosivedmg"):GetBool() then
			ply:GiveEquipmentItem("item_ttt_noexplosiondmg")
		end
		if not GetConVar("ttt2_abe_falldmg"):GetBool() then
			ply:GiveEquipmentItem("item_ttt_nofalldmg")
		end
		if not GetConVar("ttt2_abe_propdmg"):GetBool() then
			ply:GiveEquipmentItem("item_ttt_nopropdmg")
		end
		--Give aberration the default status
		STATUS:AddStatus(ply, "ttt2_abe1_icon", false)
		STATUS:AddStatus(ply, "ttt2_abe_regen", false)
		ply.aberration_damage_taken = 0
		ply.aberration_credits_awarded = 0
		AberrationSendDamageTaken(ply,0)
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		if not GetConVar("ttt2_abe_firedmg"):GetBool() then
			ply:RemoveEquipmentItem("item_ttt_nofiredmg")
		end
		if not GetConVar("ttt2_abe_explosivedmg"):GetBool() then
			ply:RemoveEquipmentItem("item_ttt_noexplosiondmg")
		end
		if not GetConVar("ttt2_abe_falldmg"):GetBool() then
			ply:RemoveEquipmentItem("item_ttt_nofalldmg")
		end
		if not GetConVar("ttt2_abe_propdmg"):GetBool() then
			ply:RemoveEquipmentItem("item_ttt_nopropdmg")
		end
		if not GetConVar("ttt2_abe_shop"):GetBool() then
			ply:RemoveEquipmentItem("item_ttt_radar")
			ply:RemoveItem("item_abe_speed")
		end
		ply:SetMaxHealth(100)
		timer.Remove("ttt2_abe_regen_timer")
		STATUS:RemoveStatus(ply, "ttt2_abe1_icon")
		STATUS:RemoveStatus(ply, "ttt2_abe2_icon")
		STATUS:RemoveStatus(ply, "ttt2_abe3_icon")
		STATUS:RemoveStatus(ply, "ttt2_abe4_icon")
		STATUS:RemoveStatus(ply, "ttt2_abe_regen")
		STATUS:RemoveStatus(ply, "ttt2_abe_maxhp")
		ply.aberration_damage_taken = 0		
		ply.aberration_credits_awarded = 0
		AberrationSendDamageTaken(ply,0)
	end
		function AberrationSendDamageTaken(aberration_ply, aberration_damage_taken)
		print("Aberration Receive Damage: "..aberration_damage_taken)
		net.Start("SendAberrationDamage")
		net.WriteInt(aberration_damage_taken or 0, 32) -- Send the number (32-bit signed integer)
		net.Send(aberration_ply)
		end
end


--does the math to determine what buffs to give, and what status to give
local function AberrationComputeBuffs(aberration_ply)

	local aberration_damage_taken = aberration_ply.aberration_damage_taken
	if GetConVar("ttt2_abe_shop"):GetBool() then
		local aberration_credits_awarded = aberration_ply.aberration_credits_awarded
		while aberration_damage_taken >= GetConVar("ttt2_abe_damage_per_credit"):GetInt() * (1 + aberration_credits_awarded) do
			aberration_ply:AddCredits(1)
			aberration_ply:PrintMessage(HUD_PRINTTALK, (GetConVar("ttt2_abe_damage_per_credit"):GetInt().." Damage Taken! You earned 1 credit."))
			aberration_credits_awarded = aberration_credits_awarded + 1
			aberration_ply.aberration_credits_awarded = aberration_credits_awarded
			--Update dmg status
			if (1 + aberration_credits_awarded) > 4 then return end
			STATUS:AddStatus(aberration_ply, "ttt2_abe"..(1 + aberration_credits_awarded).."_icon",false)
			STATUS:RemoveStatus(aberration_ply, "ttt2_abe"..( aberration_credits_awarded ).."_icon")
		end		
		return
	end

	if aberration_damage_taken >= 50 and not aberration_ply:HasEquipmentItem("item_ttt_radar") then
		aberration_ply:GiveEquipmentItem("item_ttt_radar")
		aberration_ply:PrintMessage(HUD_PRINTTALK, "50 Damage Taken! You now have a radar.")
		if aberration_damage_taken <= 74 then
			STATUS:RemoveStatus(aberration_ply, "ttt2_abe1_icon")
			STATUS:AddStatus(aberration_ply, "ttt2_abe2_icon", false)
		end
	end
	if aberration_damage_taken >= 75 and aberration_ply:GetMaxHealth() <= 100 then
		aberration_ply:SetMaxHealth(150)
		aberration_ply:PrintMessage(HUD_PRINTTALK, "75 Damage Taken! You now have 150 max health")
		STATUS:AddStatus(aberration_ply, "ttt2_abe_maxhp", false)
		if aberration_damage_taken <= 99 then
			STATUS:RemoveStatus(aberration_ply, "ttt2_abe1_icon")
			STATUS:RemoveStatus(aberration_ply, "ttt2_abe2_icon")
			STATUS:AddStatus(aberration_ply, "ttt2_abe3_icon", false)
		end
	end
	if aberration_damage_taken >= 100 and not aberration_ply:HasEquipmentItem("item_abe_speed") then
		aberration_ply:GiveItem("item_abe_speed")
		aberration_ply:PrintMessage(HUD_PRINTTALK, "100 Damage Taken! You are faster.")
		STATUS:RemoveStatus(aberration_ply, "ttt2_abe1_icon")
		STATUS:RemoveStatus(aberration_ply, "ttt2_abe2_icon")
		STATUS:RemoveStatus(aberration_ply, "ttt2_abe3_icon")
		STATUS:AddStatus(aberration_ply, "ttt2_abe4_icon", false)
	end
	--for every 10 dmg the aberration takes after taking 100 damage, increase its health by 1
	if aberration_ply:HasEquipmentItem("item_abe_speed") then
		if(aberration_damage_taken - 100) / 10 >= 1 then 
			local computeNewHealth = math.floor(150 + (aberration_damage_taken - 100) / 10)
			aberration_ply:PrintMessage(HUD_PRINTTALK, "Max Health increased by " .. (computeNewHealth - aberration_ply:GetMaxHealth()))
			aberration_ply:SetMaxHealth(computeNewHealth)
		end
	end
end

if CLIENT then
    net.Receive("SendAberrationDamage", function()
        local aberration_damage_taken = net.ReadInt(32) -- Receive the number and set the variable
		LocalPlayer().aberration_damage_taken = aberration_damage_taken
    end)
end

--calls this hook when someone takes damage
--if the player that took damage is the aberration, only add damage to that player, then run the compute buffs function
hook.Add("EntityTakeDamage", "ttt2_abe_damage_taken", function(target,dmginfo)
	if not IsValid(target) or not target:IsPlayer() then return end
	if target:GetSubRole() ~= ROLE_ABERRATION then return end
	if dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GetTeam() == target:GetTeam() then return end
	local dmgtaken =  dmginfo:GetDamage()
	if GetConVar("ttt2_abe_attribute_plydmg_only"):GetBool() then --Check if aberration attribute damage is only applied from other players
		if not dmginfo:GetAttacker():IsPlayer() or dmginfo:GetAttacker() == target then return end --If damage is not from another player or is the aberration, do not add to damage
	end
	--End function if damage is fire/explosive/fall with cvar
	if not GetConVar("ttt2_abe_firedmg"):GetBool() and dmginfo:IsDamageType( 8 ) then return end
	if not GetConVar("ttt2_abe_explosivedmg"):GetBool() and dmginfo:IsDamageType( 64 ) then return end
	if not GetConVar("ttt2_abe_falldmg"):GetBool() and dmginfo:IsDamageType( 32 ) then return end
	if not GetConVar("ttt2_abe_propdmg"):GetBool() and dmginfo:IsDamageType( 1 ) then return end
	--round float to nearest integer
	dmgtaken = math.floor(dmgtaken + 0.5)
	target.aberration_damage_taken = target.aberration_damage_taken + dmgtaken
	--target:PrintMessage(HUD_PRINTTALK, "Total Dmg: " .. target.aberration_damage_taken)
	AberrationSendDamageTaken(target, target.aberration_damage_taken)
	AberrationComputeBuffs(target)
	--no healing for 5 seconds after taking damage
	heal_time = (CurTime() + 5)
	STATUS:AddTimedStatus(target, "ttt2_abe_healing_cooldown", 5, true)
	STATUS:RemoveStatus(target, "ttt2_abe_regen")
end)

-- -- -- -- --
-- STATUSES -- 
-- -- -- -- --
if CLIENT then
	hook.Add("Initialize", "ttt2_abe_init", function()		
		STATUS:RegisterStatus("ttt2_abe1_icon", {
			hud = Material("vgui/ttt/icons/icon_abe1.png"),
			type = "good",
			DrawInfo = function()
				if LocalPlayer().aberration_damage_taken then
					return math.floor(LocalPlayer().aberration_damage_taken)
				else
					return 0
				end
			end,
			name = "Aberration",
			sidebarDescription = "status_abe1_icon"
		})
		STATUS:RegisterStatus("ttt2_abe2_icon", {
			hud = Material("vgui/ttt/icons/icon_abe2.png"),
			type = "good",
			DrawInfo = function()
				if LocalPlayer().aberration_damage_taken then
					return math.floor(LocalPlayer().aberration_damage_taken)
				else
					return 0
				end
			end,
			name = "Aberration",
			sidebarDescription = "status_abe2_icon"
		})	
		STATUS:RegisterStatus("ttt2_abe3_icon", {
			hud = Material("vgui/ttt/icons/icon_abe3.png"),
			type = "good",
			DrawInfo = function()
				if LocalPlayer().aberration_damage_taken then
					return math.floor(LocalPlayer().aberration_damage_taken)
				else
					return 0
				end
			end,
			name = "Aberration",
			sidebarDescription = "status_abe3_icon"
		})	
		STATUS:RegisterStatus("ttt2_abe4_icon", {
			hud = Material("vgui/ttt/icons/icon_abe4.png"),
			type = "good",
			DrawInfo = function()
				if LocalPlayer().aberration_damage_taken then
					return math.floor(LocalPlayer().aberration_damage_taken)
				else
					return 0
				end
			end,
			name = "Aberration",
			sidebarDescription = "status_abe4_icon"
		})
		STATUS:RegisterStatus("ttt2_abe_regen", {
			hud = Material("vgui/ttt/icons/regen_abe.png"),
			type = "good",
			DrawInfo = function()
				if GetConVar("ttt2_abe_healing_amount"):GetInt() then
					return "+"..(math.Round(GetConVar("ttt2_abe_healing_amount"):GetInt() * 100 / GetConVar("ttt2_abe_healing_interval"):GetInt())/100).."/s"
				else
					return 0
				end
			end,
			name = "Aberration",
			sidebarDescription = "status_abe_regen"
		})
		STATUS:RegisterStatus("ttt2_abe_healing_cooldown", {
			hud = Material("vgui/ttt/icons/regen_abe.png"),
			type = "bad",
			name = "Aberration",
			sidebarDescription = "status_abe_regen_cooldown"
		})
		STATUS:RegisterStatus("ttt2_abe_maxhp", {
			hud = Material("vgui/ttt/icons/hpmax_abe.png"),
			type = "good",
			DrawInfo = function()
				return "+"..(LocalPlayer():GetMaxHealth() - 100)
			end,
			name = "Aberration",
			sidebarDescription = "status_abe_maxhp"
		})
		
	end) 
end


-- -- -- -- -
-- CONVARS --
-- -- -- -- -
CreateConVar("ttt2_abe_healing_interval", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_healing_amount", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_speed_multiplier", "1.2", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_firedmg", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_explosivedmg", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_falldmg", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_propdmg", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_attribute_plydmg_only", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_shop", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_abe_damage_per_credit", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

--Adds convars to the F1 menu
if CLIENT then
  function ROLE:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_roles_additional")
	
    form:MakeSlider({
      serverConvar = "ttt2_abe_healing_interval",
      label = "label_abe_healing_interval",
      min = 1,
      max = 10,
      decimal = 0
	})
	
	form:MakeSlider({
      serverConvar = "ttt2_abe_healing_amount",
      label = "label_abe_healing_amount",
      min = 1,
      max = 10,
      decimal = 0
	})
	
	form:MakeSlider({
      serverConvar = "ttt2_abe_speed_multiplier",
      label = "label_abe_speed_multiplier",
      min = 1.0,
      max = 2.0,
      decimal = 2
	})
	
	form:MakeCheckBox({
      serverConvar = "ttt2_abe_firedmg",
      label = "label_abe_firedmg"
    })
	
	form:MakeCheckBox({
      serverConvar = "ttt2_abe_explosivedmg",
      label = "label_abe_explosivedmg"
    })
	
	form:MakeCheckBox({
      serverConvar = "ttt2_abe_falldmg",
      label = "label_abe_falldmg"
    })
	
	form:MakeCheckBox({
      serverConvar = "ttt2_abe_propdmg",
      label = "label_abe_propdmg"
    })
	
	form:MakeCheckBox({
      serverConvar = "ttt2_abe_attribute_plydmg_only",
      label = "label_abe_attribute_plydmg_only"
    })
	
	form:MakeCheckBox({
      serverConvar = "ttt2_abe_shop",
      label = "label_abe_shop"
    })

	form:MakeSlider({
      serverConvar = "ttt2_abe_damage_per_credit",
      label = "label_abe_damage_per_credit",
      min = 1,
      max = 100,
      decimal = 0
	})
	
  end
end
