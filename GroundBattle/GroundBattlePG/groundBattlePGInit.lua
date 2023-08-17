
-- init groundBattle tables
do
    groundBattle = {}
    groundBattle.combatZones = {}
    groundBattle.combatZoneLinks = {}
    
    --enum zoneFactions
    groundBattle.combatZones.factions.red = "red"
    groundBattle.combatZones.factions.blue = "blue"
    groundBattle.combatZones.factions.neutral = "neutral"
end

-- init combat zones
do
    for i=1, 34 do
        zoneName = string.format("CombatZone-%d", i)
        groundBattle.combatZones[zoneName] = {name=zoneName, faction=groundBattle.combatZones.factions.neutral, links={}}
    end
    --zone 1
    table.insert(groundBattle.combatZones["CombatZone-1"].links, "CombatZone-21")
    table.insert(groundBattle.combatZones["CombatZone-1"].links, "CombatZone-2")
    table.insert(groundBattle.combatZones["CombatZone-1"].links, "CombatZone-12")

    --zone 2
    table.insert(groundBattle.combatZones["CombatZone-2"].links, "CombatZone-21")

    table.insert(groundBattle.combatZoneLinks, {"CombatZone-9", "CombatZone-8"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-8", "CombatZone-7"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-7", "CombatZone-34"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-34", "CombatZone-6"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-6", "CombatZone-32"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-6", "CombatZone-5"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-5", "CombatZone-4"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-32", "CombatZone-4"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-32", "CombatZone-31"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-32", "CombatZone-33"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-33", "CombatZone-11"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-11", "CombatZone-12"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-11", "CombatZone-10"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-31", "CombatZone-10"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-10", "CombatZone-13"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-12", "CombatZone-13"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-13", "CombatZone-14"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-14", "CombatZone-15"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-14", "CombatZone-19"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-4", "CombatZone-3"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-3", "CombatZone-2"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-31", "CombatZone-2"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-2", "CombatZone-1"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-12", "CombatZone-1"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-3", "CombatZone-22"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-1", "CombatZone-21"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-22", "CombatZone-21"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-21", "CombatZone-20"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-19", "CombatZone-20"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-19", "CombatZone-15"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-20", "CombatZone-30"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-15", "CombatZone-16"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-30", "CombatZone-16"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-16", "CombatZone-17"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-17", "CombatZone-18"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-20", "CombatZone-23"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-23", "CombatZone-24"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-24", "CombatZone-26"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-26", "CombatZone-25"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-27", "CombatZone-25"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-24", "CombatZone-29"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-16", "CombatZone-29"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-29", "CombatZone-28"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-17", "CombatZone-28"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-28", "CombatZone-27"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-29", "CombatZone-27"})
    table.insert(groundBattle.combatZoneLinks, {"CombatZone-29", "CombatZone-26"})
end

function groundBattle.isCombatZoneFrontline(zoneName)
    for z1, z2 in pairs(groundBattle.combatZoneLinks) do
        if z1 == zoneName or z2 == zoneName then                            
            if groundBattle.getZoneFaction(z1) ~= groundBattle.getZoneFaction(z2) then
                return true
            end
        end
    end
    return false 
end

function groundBattle.getZoneFaction(zoneName)
    return groundBattle.combatzones[zoneName].faction
end

