if SERVER then
    AddCSLuaFile()
end

ITEM.EquipMenuData = {
    type = "item_passive",
    name = "title_item_aberration_speed",
    desc = "desc_item_aberration_speed",
}
ITEM.CanBuy = { }

ITEM.material = "vgui/ttt/icon_speedrun"
ITEM.CanBuy = { ROLE_ABERRATION }
ITEM.builtin = false

hook.Add("TTTPlayerSpeedModifier", "TTT2AberrationSpeedrunGood", function(ply, _, _, speedMultiplierModifier)
    if not IsValid(ply) or not ply:HasEquipmentItem("item_abe_speed") then
        return
    end

    speedMultiplierModifier[1] = speedMultiplierModifier[1] * GetConVar("ttt2_abe_speed_multiplier"):GetFloat()
end)