
--init group templates

groundBattle.factions.red.groundGroupsLimit = 5
groundBattle.factions.red.apcPerc = 0
groundBattle.factions.red.ifvPerc = 85
groundBattle.factions.red.mbtPerc = 15
groundBattle.factions.red.groundTemplates.ifv = {"RED_IFV_T"}
groundBattle.factions.red.groundTemplates.mbt = {"RED_MBT_T"}
--groundBattle.factions.red.groundTemplates.spa = {"RED_SPA_T"}
groundBattle.factions.red.groundTemplates.aaa = {"RED_AAA_T", "RED_AAA_T-1", "RED_AAA_T-2"}
groundBattle.factions.red.groundTemplates.inf = {"RED_ATSQ_T"}

groundBattle.factions.blue.groundGroupsLimit = 5
groundBattle.factions.blue.apcPerc = 0
groundBattle.factions.blue.ifvPerc = 50
groundBattle.factions.blue.mbtPerc = 50
groundBattle.factions.blue.groundTemplates.ifv = {"BLUE_IFV_T"}
groundBattle.factions.blue.groundTemplates.mbt = {"BLUE_MBT_T"}
--groundBattle.factions.blue.groundTemplates.spa = {"BLUE_SPA_T"}
groundBattle.factions.blue.groundTemplates.inf = {}


-- init combat zoness

for i=1, 9 do
    zoneName = string.format("CombatZone-%d", i)
    table.insert(groundBattle.combatZones, {name=zoneName, faction=groundBattle.factions.neutral, defences={}, links={}})
end

zone = {}
--zone 1
zone = groundBattle.combatZones.getZoneByName("CombatZone-1")
table.insert(zone.links, "CombatZone-2")
table.insert(zone.links, "CombatZone-4")
table.insert(zone.links, "CombatZone-5")

--zone 2
zone = groundBattle.combatZones.getZoneByName("CombatZone-2")
table.insert(zone.links, "CombatZone-1")
table.insert(zone.links, "CombatZone-3")
table.insert(zone.links, "CombatZone-4")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-6")

--zone 3
zone = groundBattle.combatZones.getZoneByName("CombatZone-3")
table.insert(zone.links, "CombatZone-2")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-6")

--zone 4
zone = groundBattle.combatZones.getZoneByName("CombatZone-4")
table.insert(zone.links, "CombatZone-1")
table.insert(zone.links, "CombatZone-2")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-7")
table.insert(zone.links, "CombatZone-8")

--zone 5
zone = groundBattle.combatZones.getZoneByName("CombatZone-5")
table.insert(zone.links, "CombatZone-1")
table.insert(zone.links, "CombatZone-2")
table.insert(zone.links, "CombatZone-3")
table.insert(zone.links, "CombatZone-4")
table.insert(zone.links, "CombatZone-6")
table.insert(zone.links, "CombatZone-7")
table.insert(zone.links, "CombatZone-8")
table.insert(zone.links, "CombatZone-9")

--zone 6
zone = groundBattle.combatZones.getZoneByName("CombatZone-6")
table.insert(zone.links, "CombatZone-2")
table.insert(zone.links, "CombatZone-3")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-8")
table.insert(zone.links, "CombatZone-9")

--zone 7
zone = groundBattle.combatZones.getZoneByName("CombatZone-7")
table.insert(zone.links, "CombatZone-4")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-8")

--zone 8
zone = groundBattle.combatZones.getZoneByName("CombatZone-8")
table.insert(zone.links, "CombatZone-4")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-6")
table.insert(zone.links, "CombatZone-7")
table.insert(zone.links, "CombatZone-9")

--zone 9
zone = groundBattle.combatZones.getZoneByName("CombatZone-9")
table.insert(zone.links, "CombatZone-5")
table.insert(zone.links, "CombatZone-6")
table.insert(zone.links, "CombatZone-8")

groundBattle.prodZoneNames = {"CombatZone-1", "CombatZone-9"}

groundBattle.combatZones.getZoneByName("CombatZone-1").faction = groundBattle.factions.red
groundBattle.combatZones.getZoneByName("CombatZone-8").faction = groundBattle.factions.red
groundBattle.combatZones.getZoneByName("CombatZone-5").faction = groundBattle.factions.red
groundBattle.combatZones.getZoneByName("CombatZone-6").faction = groundBattle.factions.red
groundBattle.combatZones.getZoneByName("CombatZone-9").faction = groundBattle.factions.blue

groundBattle.spawnInfantry("red", "CombatZone-8")
groundBattle.spawnInfantry("red", "CombatZone-5")
groundBattle.spawnInfantry("red", "CombatZone-6")



groundBattle.initiated = true
groundBattle.debug = true
groundBattle.debugMessage(string.format("Init done. Combat zones: %d.", #groundBattle.combatZones))
groundBattle.debugMessage("Executing groundBattle.run()")
groundBattle.run()