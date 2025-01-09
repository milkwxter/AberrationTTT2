local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[ABERRATION.name] = "Aberration"
L["info_popup_" .. ABERRATION.name] = [[]]
L["body_found_" .. ABERRATION.abbr] = "They were a Aberration."
L["search_role_" .. ABERRATION.abbr] = "This person was a Aberration!"
L["target_" .. ABERRATION.name] = "Aberration"
L["ttt2_desc_" .. ABERRATION.name] = [[You are the Aberration! You regen health and get buffs the more damage you take!]]

--CONVAR LANGUAGE STRINGS
L["label_abe_healing_interval"] = "How often the aberration heals(in seconds): "
L["label_abe_healing_amount"] = "How much the aberration heals for: "
L["label_abe_speed_multiplier"] = "The speed multiplier after taking 100 damage: "
L["label_abe_firedmg"] = "Aberration receives fire damage"
L["label_abe_explosivedmg"] = "Aberration receives exposive damage"
L["label_abe_falldmg"] = "Aberration receives fall damage"
L["label_abe_propdmg"] = "Aberration receives prop damage"
L["label_abe_attribute_plydmg_only"] = "Aberration damage only attributed by other player damage" 
L["label_abe_shop"] = "Aberration is rewarded credits and has a shop instead of getting buffs directly for damage" 
L["label_mut_damage_per_credit"] = "[Requires Aberration Shop enabled] Damager per credit" 


L["status_abe1_icon"] = "Take damage to receive buffs!"
L["status_abe2_icon"] = "You have taken 50 damage and received a radar!"
L["status_abe3_icon"] = "You have taken 75 damage and received a health buff!"
L["status_abe4_icon"] = "You have taken 100 damage and received a speed buff! For every 10 damage, gain 1 hp."
L["status_abe_regen"] = "You regenerate health every couple seconds..."
L["status_abe_regen_cooldown"] = "You took damage and must wait before regenerating health again."
L["status_abe_maxhp"] = "You have increased your maximum health."


L["title_item_aberration_health"] = "Aberration Health"
L["desc_item_aberration_health"] = "Increase your maximum Health by 10."
L["title_item_aberration_speed"] = "Aberration Speed"
L["desc_item_aberration_speed"] = "Increase your speed by "..math.Round(GetConVar("ttt2_abe_speed_multiplier"):GetFloat()*100).."%,"