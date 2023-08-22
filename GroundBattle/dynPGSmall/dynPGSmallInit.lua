
--init factions
groundBattle.factions.red.aaaCount = 0.3
groundBattle.factions.blue.aaaCount = 0.2

--init group templates
groundBattle.factions.red.groundGroupsLimit = 10
groundBattle.factions.red.hdgmin = 190
groundBattle.factions.red.hdgmax = 240
groundBattle.factions.red.apcPerc = {30, 50}
groundBattle.factions.red.ifvPerc = {30, 30}
groundBattle.factions.red.mbtPerc = {40, 20}
groundBattle.factions.red.groundTemplates.apc = {"RED_APC_T", "RED_APC_T-1", "RED_APC_T-2", "RED_APC_T-3"}
groundBattle.factions.red.groundTemplates.ifv = {"RED_IFV_T", "RED_IFV_T-1", "RED_IFV_T-2"}
groundBattle.factions.red.groundTemplates.mbt = {"RED_MBT_T", "RED_MBT_T-1", "RED_MBT_T-2"}
--groundBattle.factions.red.groundTemplates.spa = {"RED_SPA_T"}
groundBattle.factions.red.groundTemplates.aaa = {"RED_AAA_T", "RED_AAA_T-1", "RED_AAA_T-2", "RED_AAA_T-3", "RED_AAA_T-4", "RED_AAA_T-5", "RED_AAA_T-6"}
-- groundBattle.factions.red.groundTemplates.INF = {"RED_ATSQ_T"}

groundBattle.factions.red.inactCAP = {"T_CAP_F4E_1", "T_CAP_F4E_2", "T_CAP_F4E_3", "T_CAP_F4E_4", "T_CAP_F14A_1"}
groundBattle.factions.red.inactCAS = {"T_CAS_SU25_1", "T_CAS_SU25_2", "T_CAS_SU25_3", "T_SEAD_SU24_1", "T_SEAD_SU24_2"}

groundBattle.factions.blue.groundGroupsLimit = 8
groundBattle.factions.blue.hdgmin = 10
groundBattle.factions.blue.hdgmax = 60
groundBattle.factions.blue.apcPerc = {35, 60}
groundBattle.factions.blue.ifvPerc = {35, 30}
groundBattle.factions.blue.mbtPerc = {30, 10}
groundBattle.factions.blue.groundTemplates.apc = {"BLUE_APC_T", "BLUE_APC_T-1", "BLUE_APC_T-2"}
groundBattle.factions.blue.groundTemplates.ifv = {"BLUE_IFV_T", "BLUE_IFV_T-1", "BLUE_IFV_T-2"}
groundBattle.factions.blue.groundTemplates.mbt = {"BLUE_MBT_T", "BLUE_MBT_T-1", "BLUE_MBT_T-2"}
groundBattle.factions.blue.groundTemplates.aaa = {"BLUE_AAA_T", "BLUE_AAA_T-1", "BLUE_AAA_T-2"}
--groundBattle.factions.red.groundTemplates.INF = {"BLUE_ATSQ_T"}
--groundBattle.factions.blue.groundTemplates.spa = {"BLUE_SPA_T"}

-- init combat zones
for i=1, 18 do
    local zoneName = string.format("CombatZone-%d", i)
    if i < 9 then 
        table.insert(groundBattle.combatZones, {name=zoneName, faction=groundBattle.factions.red, defences={}, links={}})
        groundBattle.spawnAAA("red", zoneName)
        groundBattle.spawnDefences("red", zoneName, 0)
    elseif i > 10 then
        table.insert(groundBattle.combatZones, {name=zoneName, faction=groundBattle.factions.blue, defences={}, links={}})
        groundBattle.spawnAAA("blue", zoneName)
        groundBattle.spawnDefences("blue", zoneName, 0)
    else
        table.insert(groundBattle.combatZones, {name=zoneName, faction=groundBattle.factions.neutral, defences={}, links={}})
    end 
end

-- add links 
groundBattle.combatZones.addLink("CombatZone-1", "CombatZone-2")
groundBattle.combatZones.addLink("CombatZone-1", "CombatZone-3")
groundBattle.combatZones.addLink("CombatZone-2", "CombatZone-3")
groundBattle.combatZones.addLink("CombatZone-2", "CombatZone-4")
groundBattle.combatZones.addLink("CombatZone-3", "CombatZone-4")
groundBattle.combatZones.addLink("CombatZone-2", "CombatZone-5")
groundBattle.combatZones.addLink("CombatZone-4", "CombatZone-6")
groundBattle.combatZones.addLink("CombatZone-5", "CombatZone-6")
groundBattle.combatZones.addLink("CombatZone-5", "CombatZone-7")
groundBattle.combatZones.addLink("CombatZone-5", "CombatZone-8")
groundBattle.combatZones.addLink("CombatZone-6", "CombatZone-8")
groundBattle.combatZones.addLink("CombatZone-7", "CombatZone-8")
groundBattle.combatZones.addLink("CombatZone-8", "CombatZone-9")
groundBattle.combatZones.addLink("CombatZone-7", "CombatZone-10")
groundBattle.combatZones.addLink("CombatZone-9", "CombatZone-10")
groundBattle.combatZones.addLink("CombatZone-10", "CombatZone-11")
groundBattle.combatZones.addLink("CombatZone-10", "CombatZone-12")
groundBattle.combatZones.addLink("CombatZone-9", "CombatZone-12")
groundBattle.combatZones.addLink("CombatZone-9", "CombatZone-13")
groundBattle.combatZones.addLink("CombatZone-11", "CombatZone-12")
groundBattle.combatZones.addLink("CombatZone-12", "CombatZone-13")
groundBattle.combatZones.addLink("CombatZone-11", "CombatZone-14")
groundBattle.combatZones.addLink("CombatZone-12", "CombatZone-15")
groundBattle.combatZones.addLink("CombatZone-12", "CombatZone-16")
groundBattle.combatZones.addLink("CombatZone-13", "CombatZone-15")
groundBattle.combatZones.addLink("CombatZone-13", "CombatZone-16")
groundBattle.combatZones.addLink("CombatZone-14", "CombatZone-17")
groundBattle.combatZones.addLink("CombatZone-15", "CombatZone-17")
groundBattle.combatZones.addLink("CombatZone-17", "CombatZone-18")



-- production zones
groundBattle.prodZoneNames = {"CombatZone-1", "CombatZone-18"}

groundBattle.initiated = true
groundBattle.debug = false
groundBattle.debugMessage(string.format("Init done. Combat zones: %d.", #groundBattle.combatZones))

groundBattle.debugMessage("Executing groundBattle.run()")
groundBattle.run()

-- initial units placement
groundBattle.produceGroup(groundBattle.factions.blue, "CombatZone-11")
groundBattle.produceGroup(groundBattle.factions.blue, "CombatZone-12")
groundBattle.produceGroup(groundBattle.factions.blue, "CombatZone-12")
groundBattle.produceGroup(groundBattle.factions.blue, "CombatZone-13")
groundBattle.produceGroup(groundBattle.factions.blue, "CombatZone-13")
groundBattle.produceGroup(groundBattle.factions.red, "CombatZone-7")
groundBattle.produceGroup(groundBattle.factions.red, "CombatZone-7")
groundBattle.produceGroup(groundBattle.factions.red, "CombatZone-8")
groundBattle.produceGroup(groundBattle.factions.red, "CombatZone-8")