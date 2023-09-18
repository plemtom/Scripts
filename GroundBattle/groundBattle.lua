
-- initialize LUA tables
groundBattle = {}
groundBattle.prodTime = 450
groundBattle.debug = true
groundBattle.dmt = 10 -- debug message time
groundBattle.combatZones = {}
groundBattle.combatZones.frontlineZones = {}
groundBattle.prodZoneNames = {}
groundBattle.initiated = false 
groundBattle.productionInitiated = false
groundBattle.redAirOn = true
    
--init Factions
groundBattle.factions = {}
groundBattle.factions.red = {}
groundBattle.factions.red.aaaCount = 0
groundBattle.factions.red.defCount = 0
groundBattle.factions.red.prodTimePerc = 100
groundBattle.factions.red.name = "red"
groundBattle.factions.red.groundTemplates = {}
groundBattle.factions.red.groundGroups = {}     -- group structure {name, zoneName, order, factionName, type}. Orders: none, move (between friendly zones), attack
groundBattle.factions.red.groundGroupsLimit = 0
groundBattle.factions.red.airGroupNames = {}
groundBattle.factions.red.actCAP = {}
groundBattle.factions.red.inactCAP = {}
groundBattle.factions.red.actCAS = {}
groundBattle.factions.red.inactCAS = {}
groundBattle.factions.red.targetCAP = 0
groundBattle.factions.red.targetCAS = 0
groundBattle.factions.red.targetCAPRatio = 0.5
groundBattle.factions.red.hdgmin = 0
groundBattle.factions.red.hdgmax = 0


groundBattle.factions.blue = {}
groundBattle.factions.blue.aaaCount = 0
groundBattle.factions.blue.defCount = 0
groundBattle.factions.blue.prodTimePerc = 100
groundBattle.factions.blue.name = "blue"
groundBattle.factions.blue.groundTemplates = {}
groundBattle.factions.blue.groundGroups = {}
groundBattle.factions.blue.groundGroupsLimit = 0
groundBattle.factions.blue.airGroupNames = {}
groundBattle.factions.blue.actCAP = {}
groundBattle.factions.blue.inactCAP = {}
groundBattle.factions.blue.actCAS = {}
groundBattle.factions.blue.inactCAS = {}
groundBattle.factions.blue.targetCAP = 0
groundBattle.factions.blue.targetCAS = 0
groundBattle.factions.blue.targetCAPRatio = 0.5
groundBattle.factions.blue.hdgmin = 0
groundBattle.factions.blue.hdgmax = 0

groundBattle.factions.neutral = {}
groundBattle.factions.neutral.name = "neutral"

-- events handler 
function groundBattle.eventHandler(event)
    if event.id == 19 then -- engine shutdown event
        local unit = event.initiator
        if unit.getCoalition(unit) == 1 then -- only destroys RED units
            unit.destroy(unit)
        end
    end 
end 

function groundBattle.logTable(tbl, indLevel)
    local retVal = {}
    local ind = ""

    for i=1, indLevel do
        ind = ind .. " "
    end
    
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            retVal[#retVal+1] = ind .. k .. ": \n" .. groundBattle.logTable(v, indLevel+1)
        else
            retVal[#retVal+1] = ind .. k .. ": " .. v .. "\n"
        end
    end
    return table.concat(retVal)
end

-- some assorted functions
function groundBattle.isCombatZoneFrontline(zoneName)
    local zone = groundBattle.combatZones.getZoneByName(zoneName)
    for i=1, #zone.links do
        local linkedZone = groundBattle.combatZones.getZoneByName(zone.links[i])
        if zone.faction ~= linkedZone.faction then 
            return true
        end
    end
    return false
end

function groundBattle.getRandomLinkedFriendlyZone(zoneName) -- return string of random linked friendly zone name
    local zones = {}
    local zone = groundBattle.combatZones.getZoneByName(zoneName)
    -- groundBattle.debugMessage(string.format("getRandomLinkedFriendlyZone. Zone: %s, linked zones: %d", zone.name, #zone.links))

    for i = 1, #zone.links do 
        if groundBattle.combatZones.getZoneByName(zone.links[i]).faction == zone.faction then
            table.insert(zones, zone.links[i])
        end
    end
    if #zones > 0 then 
        local retZone = zones[math.random(1, #zones)]
        -- groundBattle.debugMessage(string.format("Random friendly zone: %s", retZone))
        return retZone
    else
        -- groundBattle.debugMessage(string.format("Random friendly zone: nil"))
        return nil 
    end
end

function groundBattle.getRandomLinkedHostileZone(zoneName)
    local zones = {}
    local zone = groundBattle.combatZones.getZoneByName(zoneName)
    -- groundBattle.debugMessage(string.format("getRandomLinkedFriendlyZone. Zone: %s, linked zones: %d", zone.name, #zone.links))

    for i = 1, #zone.links do 
        if groundBattle.combatZones.getZoneByName(zone.links[i]).faction ~= zone.faction then
            table.insert(zones, zone.links[i])
        end
    end
    if #zones > 0 then 
        local retZone = zones[math.random(1, #zones)]
        -- groundBattle.debugMessage(string.format("Random friendly zone: %s", retZone))
        return retZone
    else
        -- -- groundBattle.debugMessage(string.format("Random friendly zone: nil"))
        return nil 
    end
end

function groundBattle.getZoneFaction(zoneName)
    return groundBattle.combatZones.getZoneByName(zoneName).faction
end

function groundBattle.debugMessage(msg)
    if groundBattle.debug then
        trigger.action.outText(msg, groundBattle.dmt)
        env.info(msg)
    end
end

function groundBattle.combatZones.getZoneByName(zoneName)
    for i=1, #groundBattle.combatZones do
        if groundBattle.combatZones[i].name == zoneName then
            return groundBattle.combatZones[i]
        end
    end
end

function groundBattle.combatZones.updateFaction(zoneName, factionName)
    for i=1, #groundBattle.combatZones do
        if groundBattle.combatZones[i].name == zoneName then
            if factionName == "red" then 
                groundBattle.combatZones[i].faction = groundBattle.factions.red
                --groundBattle.debugMessage(string.format("Updating zone %s faction to red.", zoneName))
            elseif factionName == "blue" then
                groundBattle.combatZones[i].faction = groundBattle.factions.blue
                --groundBattle.debugMessage(string.format("Updating zone %s faction to blue.", zoneName))
            elseif factionName == "neutral" then
                groundBattle.combatZones[i].faction = groundBattle.factions.neutral
            end
            break
        end
    end
    local params = {factionName, zoneName}
    mist.scheduleFunction(groundBattle.spawnAAA, params, timer.getTime()+300, nil, nil)
    groundBattle.spawnDefences(factionName, zoneName, 300)
    --mist.scheduleFunction(groundBattle.spawnInfantry, params, timer.getTime()+300, nil, nil)
end

function groundBattle.getGroupInfoByName(groupName)
    for i = 1, #groundBattle.factions.blue.groundGroups do
        if groundBattle.factions.blue.groundGroups[i].name == groupName then 
            return groundBattle.factions.blue.groundGroups[i]
        end 
    end 
    for i = 1, #groundBattle.factions.red.groundGroups do
        if groundBattle.factions.red.groundGroups[i].name == groupName then 
            return groundBattle.factions.red.groundGroups[i]
        end 
    end 
    return nil
end 

function groundBattle.checkConflict(zoneName)
    local blufor = false
    local redfor = false

    local redgrps = groundBattle.factions.red.groundGroups
    local blugrps = groundBattle.factions.blue.groundGroups

    local zone = groundBattle.combatZones.getZoneByName(zoneName)

    if #zone.defences > 0 then 
        if zone.faction.name == "red" then 
            redfor = true
        elseif zone.faction.name == "blue" then 
            blufor = true
        end 
    end

    if redgrps and #redgrps > 0 and not redfor then 
        for i=1, #redgrps do
            if redgrps[i].zoneName == zoneName then 
                --- check distance to zone ComCenter
                local zoneData = trigger.misc.getZone(zoneName)
                local units = Group.getByName(redgrps[i].name):getUnits()
                if units and #units > 0 then 
                    for i=1, #units do
                        local upos = Unit.getPosition(units[i]).p
                        local dist = math.sqrt(math.pow(zoneData.point.x - upos.x, 2) + math.pow(zoneData.point.y - upos.y, 2) + math.pow(zoneData.point.z - upos.z, 2))
                        if dist < zoneData.radius then 
                            redfor = true
                            break
                        end
                    end
                end 
            end 
        end
    end 

    if blugrps and #blugrps > 0 and not blufor then 
        -- groundBattle.debugMessage(string.format("Found %d blue groups.", #blugrps))
        for i=1, #blugrps do
            if blugrps[i].zoneName == zoneName then 
                --- check distance to zone ComCenter
                local zoneData = trigger.misc.getZone(zoneName)
                local units = Group.getByName(blugrps[i].name):getUnits()

                if units and #units > 0 then 
                    for i=1, #units do
                        local upos = Unit.getPosition(units[i]).p
                        local dist = math.sqrt(math.pow(zoneData.point.x - upos.x, 2) + math.pow(zoneData.point.y - upos.y, 2) + math.pow(zoneData.point.z - upos.z, 2))
                        
                        if dist < zoneData.radius then 
                            blufor = true
                            break
                        end
                    end
                end 
            end 
        end
    end 

    if blufor and redfor then 
        if zone.faction.name ~= "neutral" then 
            groundBattle.combatZones.updateFaction(zoneName, "neutral")
        end
        return true
    elseif blufor then
        if zone.faction.name ~= "blue" then 
            groundBattle.combatZones.updateFaction(zoneName, "blue")
        end
        return false 
    elseif redfor then
        if zone.faction.name ~= "red" then 
            groundBattle.combatZones.updateFaction(zoneName, "red")
        end
        return false
    else
        return true
    end
end 

function groundBattle.redrawMapMarks()
    groundBattle.debugMessage("Redrawing markers")
    local zones = groundBattle.combatZones
    if zones and #zones > 0 then 
        for i=1, #zones do
            local zoneColor = {0.8, 0.8, 0.8, 0.5}
            local fillCol = {0.8, 0.8, 0.8, 0.2}

            if zones[i].faction.name == groundBattle.factions.red.name then 
                zoneColor = {0.8, 0.2, 0.2, 0.5}
                fillCol = {0.8, 0.2, 0.2, 0.2}
            elseif zones[i].faction.name == groundBattle.factions.blue.name then 
                zoneColor = {0.2, 0.2, 0.8, 0.5}
                fillCol = {0.2, 0.2, 0.8, 0.2}
            end

            if mist.marker.get(i) then 
                mist.marker.remove(i)
                --groundBattle.debugMessage("Removing marker " .. i)
            end 
            mist.marker.drawZone(zones[i].name, {id=i, color=zoneColor, fillColor=fillCol, text=zones[i].name})
            --groundBattle.debugMessage("Drawing marker " .. i)
        end
    end
end

function groundBattle.listCombatZones()
    msg = {}
    msg[#msg+1] = "Combat zones:"
    for i=1, #groundBattle.combatZones do
        msg[#msg+1] = groundBattle.combatZones[i].name .. " - " .. groundBattle.combatZones[i].faction.name
    end
    groundBattle.debugMessage(table.concat(msg, "\n"))
end

function groundBattle.updateZoneFactions()
    groundBattle.updateDefences()

    for i=1, #groundBattle.combatZones do
        groundBattle.checkConflict(groundBattle.combatZones[i].name)
    end
    groundBattle.redrawMapMarks()
end

function groundBattle.combatZones.addLink(zoneName1, zoneName2)
    local zone1 = groundBattle.combatZones.getZoneByName(zoneName1)
    local zone2 = groundBattle.combatZones.getZoneByName(zoneName2)
    table.insert(zone1.links, zoneName2)
    table.insert(zone2.links, zoneName1)
end

function groundBattle.updateFrontlineZones()
    local newZones = {}
    for i=1, #groundBattle.combatZones do 
        if groundBattle.isCombatZoneFrontline(groundBattle.combatZones[i].name) then 
            table.insert(newZones, groundBattle.combatZones[i])
        end
    end
    groundBattle.combatZones.frontlineZones = newZones
end

function groundBattle.getFriendlyFrontlineZones(factionName)
    local retZones = {}
    for i=1, #groundBattle.combatZones.frontlineZones do
        if groundBattle.combatZones.frontlineZones[i].faction.name == factionName then
            table.insert(retZones, groundBattle.combatZones.frontlineZones[i])
        end
    end
    return retZones
end 

function groundBattle.getClosestFriendlyFrontlineZone(factionName, startZone)
    local zones = {}
    zones = groundBattle.getFriendlyFrontlineZones(factionName)
end

function groundBattle.isGroupinZone(grpName, zoneName)
    local zoneData = trigger.misc.getZone(zoneName)
    local units = Group.getByName(grpName):getUnits()
    if units and #units > 0 then 
        for i=1, #units do
            local upos = Unit.getPosition(units[i]).p
            local dist = math.sqrt(math.pow(zoneData.point.x - upos.x, 2) + math.pow(zoneData.point.z - upos.z, 2))
            if dist < zoneData.radius then 
                return true 
            end
        end
    end 
    return false
end

function groundBattle.setInvisible(grpName)
    local grp = Group.getByName(grpName)
    if grp then
        local cmd = {id = 'SetInvisible', params = {value = true}}
        local cntr = Group.getController(grp)
        Controller.setCommand(cntr, cmd)
    end
end

function groundBattle.setVisible(grpName)
    local grp = Group.getByName(grpName)
    if grp then
        local cmd = {id = 'SetInvisible', params = {value = false}}
        local cntr = Group.getController(grp)
        if cntr == nil then 
            groundBattle.debugMessage("Controller is nil!")
        end
        Controller.setCommand(cntr, cmd)
    end
end

function groundBattle.sendMessageToPlayers(message)
    trigger.action.outTextForCoalition(2, message, 30)
end

function groundBattle.printStatus()
    local msg = groundBattle.prepareStatusString()
    trigger.action.outText(table.concat(msg, "\n"), groundBattle.dmt)
end

function groundBattle.logStatus()
    env.info(groundBattle.prepareStatusString())
end 

function groundBattle.prepareStatusString()
    local msg = {}
    msg[#msg+1] = "------ Red Air Assets ------"
    msg[#msg+1] = "CAP (Target/Active/Inactive): " .. groundBattle.factions.red.targetCAP .. "/" .. #groundBattle.factions.red.actCAP .. "/" .. #groundBattle.factions.red.inactCAP
    msg[#msg+1] = "CAS (Target/Active/Inactive): " .. groundBattle.factions.red.targetCAS .. "/" .. #groundBattle.factions.red.actCAS .. "/" .. #groundBattle.factions.red.inactCAS
    msg[#msg+1] = "------ Settings ------"
    if groundBattle.redAirOn then msg[#msg+1] = "Red air assets: ON" else msg[#msg+1] = "Red air assets: OFF" end
    msg[#msg+1] = "Blue platers: " .. #coalition.getPlayers(2)

    return table.concat(msg, "\n")
end

-- production functions ------------------------------------------------------------------------------------------------

function groundBattle.initiateProduction()
    --schedule production runs for each faction
    mist.scheduleFunction(groundBattle.produceGroup, {groundBattle.factions.red}, timer.getTime() + 5, groundBattle.prodTime/100*groundBattle.factions.red.prodTimePerc)
    mist.scheduleFunction(groundBattle.produceGroup, {groundBattle.factions.blue}, timer.getTime() + 5, groundBattle.prodTime/100*groundBattle.factions.blue.prodTimePerc)
end 

function groundBattle.oldProduceGroup(faction, zoneName, defence)

    --remove entries for dead groups
    groundBattle.freeProdSlots(faction)

    --check if max ground groups reached
    if #faction.groundGroups >= faction.groundGroupsLimit then 
        return
    end

    --randomize group type, get proper faction groups templates and randomize the template to clone
    local groupTemplates = {}
    local groupType = ""

    if defence then
        local randomNumber = math.random(1, 100)
        if randomNumber <= faction.apcPerc[2] then
            groupTemplates = faction.groundTemplates.apc
            groupType = "apc"
        elseif randomNumber <= (faction.apcPerc[2] + faction.ifvPerc[2]) then
            groupTemplates = faction.groundTemplates.ifv
            groupType = "ifv"
        elseif randomNumber <= (faction.apcPerc[2] + faction.ifvPerc[2] + faction.mbtPerc[2]) then
            groupTemplates = faction.groundTemplates.mbt
            groupType = "mbt"
        end
    else
        local randomNumber = math.random(1, 100)
        if randomNumber <= faction.apcPerc[1] then
            groupTemplates = faction.groundTemplates.apc
            groupType = "apc"
        elseif randomNumber <= (faction.apcPerc[1] + faction.ifvPerc[1]) then
            groupTemplates = faction.groundTemplates.ifv
            groupType = "ifv"
        elseif randomNumber <= (faction.apcPerc[1] + faction.ifvPerc[1] + faction.mbtPerc[1]) then
            groupTemplates = faction.groundTemplates.mbt
            groupType = "mbt"
        end
    end
    

    local groupToSpawnName = groupTemplates[math.random(1, #groupTemplates)]
    ---- groundBattle.debugMessage("Ground group to spawn: " .. groupToSpawnName, 5)
    
    --get faction controlled zones and randomize zone to spawn the group in
    local zoneNames = {}
    if zoneName then
        zoneNames[#zoneNames+1] = zoneName
        groundBattle.debugMessage("Spawning group in explicit zone " .. zoneName)
    else
        zoneNames = groundBattle.getFactionProdZoneNames(faction.name)
    end
    if #zoneNames == 0 then
        return 
    end

    local spawnZoneName = zoneNames[math.random(1, #zoneNames)]
    local spawnZoneNameSp = spawnZoneName .. "sp"
    groundBattle.debugMessage("Spawn zone name: " .. spawnZoneName, 5)

    --spawn the group
    local grp = mist.cloneInZone(groupToSpawnName, spawnZoneNameSp)
    groundBattle.debugMessage("Group spawned. Name: " .. grp.name, 5)

    -- local g = Group.getByName(grp.name)
    -- for i=1, #g:getUnits() do 
    --     local u = Group.getUnit(g, i)
    --     u.name = u.name .. u:getType()
    -- end

    --register the group in faction or zone defences
    if defence then 
        local zone = groundBattle.combatZones.getZoneByName(spawnZoneName)
        table.insert(zone.defences, grp.name)
        local hdg = math.random(faction.hdgmin, faction.hdgmax)
        groundBattle.giveMoveOrder(grp.name, spawnZoneName, hdg)
    else
        table.insert(faction.groundGroups, {name=grp.name, zoneName=spawnZoneName, order="none", factionName=faction.name, type=groupType})
    end
    -- groundBattle.debugMessage(string.format("Faction groups: %d", #faction.groundGroups))
end

function groundBattle.produceGroup(faction)
    --remove entries for dead groups
    groundBattle.freeProdSlots(faction)

    --check if max ground groups reached
    if #faction.groundGroups >= faction.groundGroupsLimit then 
        return
    end

    --get the unit template
    local randomNumber = math.random(1, 100)
    if randomNumber <= faction.apcPerc[1] then
        groupTemplates = faction.groundTemplates.apc
        groupType = "apc"
    elseif randomNumber <= (faction.apcPerc[1] + faction.ifvPerc[1]) then
        groupTemplates = faction.groundTemplates.ifv
        groupType = "ifv"
    else --if randomNumber <= (faction.apcPerc[1] + faction.ifvPerc[1] + faction.mbtPerc[1]) then
        groupTemplates = faction.groundTemplates.mbt
        groupType = "mbt"
    end
    local groupToSpawnName = groupTemplates[math.random(1, #groupTemplates)]

    --get the zone to spawn group to
    local zoneNames = groundBattle.getFactionProdZoneNames(faction.name)
    if #zoneNames == 0 then
        return 
    end
    local spawnZoneName = zoneNames[math.random(1, #zoneNames)] .. "sp"
    groundBattle.debugMessage("Spawn zone name: " .. spawnZoneName, 5)

    --spawn the group
    local grp = mist.cloneInZone(groupToSpawnName, spawnZoneName)
    groundBattle.debugMessage("Group spawned. Name: " .. grp.name, 5)

    --register the group in faction or zone defences
    table.insert(faction.groundGroups, {name=grp.name, zoneName=spawnZoneName, order="none", factionName=faction.name, type=groupType})
end

function groundBattle.getFactionProdZoneNames(factionName)
    local returnZoneNames = groundBattle.getFriendlyFrontlineZones(factionName)
    for i = #returnZoneNames, 1, -1 do 
        if not StaticObject.isExist(StaticObject.getByName(returnZonesNames[i] .. "Depot")) then 
            table.remove(returnZoneNames, i)
        end
    end
    return returnZoneNames
end 

function groundBattle.freeProdSlots(faction)
    local toRemove = {}

    for i = #faction.groundGroups, 1, -1 do
        local grp = Group.getByName(faction.groundGroups[i].name)

        if grp == nil then 
            table.remove(faction.groundGroups, i)
        elseif #Group.getUnits(grp) == 0 then
            Group.destroy(grp)
            table.remove(faction.groundGroups, i)
        end 
    end
end

function groundBattle.updateDefences()
    for i=1, #groundBattle.combatZones do 
        local zone = groundBattle.combatZones[i]
        
        for j=#zone.defences, 1, -1 do 
            local grp = Group.getByName(zone.defences[j])

            if grp == nil or #Group.getUnits(grp) == 0 then
                table.remove(zone.defences, j)
            end
        end 
        groundBattle.debugMessage(zone.name .. " has " .. #zone.defences .. " defending groups")
    end 
end

function groundBattle.spawnAAA(factionName, zoneName)
    local zone = groundBattle.combatZones.getZoneByName(zoneName)

    if zone.faction.name == factionName then
        local faction = {}
        if factionName == "red"  then
            faction = groundBattle.factions.red
        elseif factionName == "blue" then 
            faction = groundBattle.factions.blue
        else
            return
        end 
        if faction.aaaCount >= 1 then 
            for i=1, faction.aaaCount do
                if #faction.groundTemplates.aaa > 0 then
                    local template = faction.groundTemplates.aaa[math.random(1, #faction.groundTemplates.aaa)]
                    local grp = mist.cloneInZone(template, zoneName, true, 100)

                    table.insert(zone.defences, grp.name)
                end
            end
        else
            local rnd = math.random(1, 100)
            if rnd <= (faction.aaaCount * 100) then 
                local template = faction.groundTemplates.aaa[math.random(1, #faction.groundTemplates.aaa)]
                local grp = mist.cloneInZone(template, zoneName, true, 100)

                table.insert(zone.defences, grp.name)
            end 
        end
    end
end 

function groundBattle.spawnInfantry(factionName, zoneName)
    local faction = {}
    if factionName == "red"  then
        faction = groundBattle.factions.red
    elseif factionName == "blue" then 
        faction = groundBattle.factions.blue
    else
        return
    end 

    for i=1, faction.infCount do
        -- groundBattle.debugMessage("Iterating infCount for zone " .. zoneName)
        if #faction.groundTemplates.inf > 0 then
            local template = faction.groundTemplates.inf[math.random(1, #faction.groundTemplates.inf)]
            local grp = mist.cloneInZone(template, zoneName, true, 30)

            -- if grp then 
                -- groundBattle.debugMessage("Spawning infantry group in zone " .. zoneName)
            -- end
            groundBattle.setInvisible(grp.name)
            local zone = groundBattle.combatZones.getZoneByName(zoneName)
            table.insert(zone.defences, grp.name)
        -- else
            -- groundBattle.debugMessage("No infantry templates in faction " .. factionName)
        end
    end
end

function groundBattle.spawnDefences(factionName, zoneName, delay)
    local faction = {}
    if factionName == "red" then
        faction = groundBattle.factions.red
    else
        faction = groundBattle.factions.blue
    end

    local tmr = timer.getTime()
    local params = {faction, zoneName, true}
    for i=1, faction.defCount do
        if delay > 0 then 
            tmr = tmr + delay
            mist.scheduleFunction(groundBattle.produceGroup, params, tmr, nil, nil)
        else
            groundBattle.produceGroup(faction, zoneName, true)
        end
    end
end

-- ground groups orders system
function groundBattle.initiateOrdersProcessing()
    mist.scheduleFunction(groundBattle.processOrders, {groundBattle.factions.red}, timer.getTime() + 10, 300)
    mist.scheduleFunction(groundBattle.processOrders, {groundBattle.factions.blue}, timer.getTime() + 10, 300)
end

function groundBattle.processOrders(faction)
    if #faction.groundGroups == 0 then 
        return
    end 
    
    --iterate through all faction groups
    -- groundBattle.debugMessage(string.format("Processing orders for %d units of faction %s", #faction.groundGroups, faction.name))
    for i=1, #faction.groundGroups do
        --check if previous orders completed
        groundBattle.checkOrderCompleted(faction.groundGroups[i].name)
        -- groundBattle.debugMessage(string.format("Order for group %s: %s", faction.groundGroups[i].name, faction.groundGroups[i].order))
        local hdg = math.random(faction.hdgmin, faction.hdgmax)
        if faction.groundGroups[i].order == "none" then -- only process idle groups
            --check if combat zone is frontline
            local isFrontline = groundBattle.isCombatZoneFrontline(faction.groundGroups[i].zoneName)
            -- groundBattle.debugMessage(string.format("Processing order for group %s. Frontline zone: %s", faction.groundGroups[i].name, tostring(isFrontline)))

            --generate order 
            local order = groundBattle.decideOrder(isFrontline, faction.groundGroups[i].type)
            if order == "move" then
                local linkedZoneName = groundBattle.getRandomLinkedFriendlyZone(faction.groundGroups[i].zoneName)
                if linkedZoneName then 
                    groundBattle.giveMoveOrder(faction.groundGroups[i].name, linkedZoneName, hdg)
                    -- groundBattle.debugMessage(string.format("Move to %s order for group %s", linkedZoneName, faction.groundGroups[i].name))
                end 
            elseif order == "front" then 
                local frontlineZones = groundBattle.getFriendlyFrontlineZones(faction.name)
                if #frontlineZones > 0 then 
                    local frontlineZone = frontlineZones[math.random(1, #frontlineZones)]
                    groundBattle.giveMoveOrder(faction.groundGroups[i].name, frontlineZone.name, hdg)
                end
            elseif order == "attack" then
                local linkedZoneName = groundBattle.getRandomLinkedHostileZone(faction.groundGroups[i].zoneName)
                if linkedZoneName then 
                    groundBattle.giveAttackOrder(faction.groundGroups[i].name, linkedZoneName, hdg)
                    local message = {}
                    message[#message+1] = "New objective: "
                    if faction.name == "red" then 
                        message[#message+1] = "enemy advancing on " .. linkedZoneName .. ". Support ground forces defending the area."
                    else
                        message[#message+1] = "perform CAS in " .. linkedZoneName .. "."
                    end
                    groundBattle.sendMessageToPlayers(table.concat(message))
                end
            end
        elseif faction.groundGroups[i].order == "attack" then
            groundBattle.giveAttackOrder(faction.groundGroups[i].name, faction.groundGroups[i].zoneName, hdg)
        end
    end
end

function groundBattle.decideOrder(isFrontline, groupType)
    local rnd = math.random(1, 100)
    local order = "none"

    if groupType == "apc" then 
        if isFrontline and rnd > 95 then 
            order = "attack"
        elseif isFrontline and rnd > 50 then 
            order = "move"
        elseif not isFrontline and rnd > 75 then 
            order = "front"
        elseif not isFrontline and rnd > 45 then
            order = "move"
        end
    elseif groupType == "ifv" then 
        if isFrontline and rnd > 95 then 
            order = "attack"
        elseif not isFrontline then 
            order = "front"
        end 
    elseif groupType == "mbt" then 
        if isFrontline and rnd > 85 then
            order = "attack"
        elseif not isFrontline then 
            order = "front"
        end
    end

    return order
end 

function groundBattle.giveMoveOrder(groupName, zoneName, hdg)
    mist.groupToRandomZone(groupName, zoneName, "column", hdg, 80, false)
    local group = groundBattle.getGroupInfoByName(groupName)
    if group then 
        group.zoneName = zoneName
        group.order = "move"
        -- groundBattle.debugMessage("Order updated to move.")
    end
end

function groundBattle.giveAttackOrder(groupName, zoneName, hdg)
    mist.groupToRandomZone(groupName, zoneName, "line", hdg, 20, true)
    local group = groundBattle.getGroupInfoByName(groupName)
    if group then 
        group.zoneName = zoneName
        group.order = "attack"
        -- groundBattle.debugMessage("Order updated to attack.")
    end
end 

function groundBattle.checkOrderCompleted(groupName)
    local group = groundBattle.getGroupInfoByName(groupName)
    local zoneName = group.zoneName

    if group.order == "move" then
        if groundBattle.isGroupinZone(group.name, zoneName) then 
            group.order = "none"
        end
    elseif group.order == "attack" then
        local zoneFactionName = groundBattle.combatZones.getZoneByName(group.zoneName).faction.name
        if zoneFactionName == group.factionName and groundBattle.isGroupinZone(group.name, zoneName) then
            group.order = "none" -- battle won, order reset to none
        end
        -- groundBattle.debugMessage(string.format("Attack order completed for group: %s", groupName))
    end 
end

-- air groups orders system
function groundBattle.initiateAirManagement()
    mist.scheduleFunction(groundBattle.processAirGroups, {"red"}, timer.getTime() + 5)
end

function groundBattle.processAirGroups(factionName)
    groundBattle.debugMessage("AIR!!! Executing processAirGroups.")
    if groundBattle.redAirOn == false then
        mist.scheduleFunction(groundBattle.processAirGroups, {"red"}, timer.getTime() + 180)
        groundBattle.debugMessage("AIR!!! redAirOn is false. Breaking.")
        return 
    else
        mist.scheduleFunction(groundBattle.processAirGroups, {"red"}, timer.getTime() + 900)
    end

    groundBattle.updateAirGroupsCount(factionName)

    local faction = {}
    if factionName == "red" then
        faction = groundBattle.factions.red
    elseif factionName == "blue" then
        faction = groundBattle.factions.blue
    else 
        return
    end

    groundBattle.debugMessage("AIR!!! Target CAP: " .. faction.targetCAP)
    groundBattle.debugMessage("AIR!!! Active CAP: " .. #faction.actCAP)
    groundBattle.debugMessage("AIR!!! Inactive CAP: " .. #faction.inactCAP)
    groundBattle.debugMessage("AIR!!! Target CAS: " .. faction.targetCAS)
    groundBattle.debugMessage("AIR!!! Active CAS: " .. #faction.actCAS)
    groundBattle.debugMessage("AIR!!! Inactive CAS: " .. #faction.inactCAS)

    local indexesToRemove = {}
    for i=1, #faction.actCAP do
        local name = faction.actCAP[i]
        if mist.groupIsDead(name) then
            groundBattle.debugMessage("Group is dead: " .. name)
            table.insert(indexesToRemove, i)
            --table.remove(faction.actCAP, index)
            table.insert(faction.inactCAP, name)
        else
            groundBattle.debugMessage("Group is not dead: " .. name)
        end 
    end
    for i=1, #indexesToRemove do 
        table.remove(faction.actCAP, indexesToRemove[i])
    end
    indexesToRemove = {}
    for i=1, #faction.actCAS do
        local name = faction.actCAS[i]
        if mist.groupIsDead(name) then
            table.insert(indexesToRemove, i)
            --table.remove(faction.actCAS, index)
            table.insert(faction.inactCAS, name)
        end
    end
    for i=1, #indexesToRemove do 
        table.remove(faction.actCAS, indexesToRemove[i])
    end

    -- 2) check if enough caps active and activate if needed
    while faction.targetCAP > #faction.actCAP do
        if #faction.inactCAP > 0 then 
            local rnd = math.random(1, #faction.inactCAP)
            local gName = faction.inactCAP[rnd]
            local grp = Group.getByName(gName)
            if grp then 
                if mist.groupIsDead(gName) then
                    mist.respawnGroup(gName, false)
                    groundBattle.debugMessage("AIR!!! Respawning group " .. gName)
                end
                grp.activate(grp)
                groundBattle.debugMessage("AIR!!! Activating group " .. gName)
                table.insert(faction.actCAP, gName)
                table.remove(faction.inactCAP, rnd)
                if groundBattle.debug then
                    groundBattle.debugMessage(string.format("CAP: %d/%d, target: %d. Activating group %s", #faction.actCAP, #faction.inactCAP, faction.targetCAP, gName) , 20)
                end
            else
                groundBattle.debugMessage("AIR!!! Group not found: " .. gName)
            end
        else 
            groundBattle.debugMessage("AIR!!! No inactive CAP groups. Breaking.")
            break
        end 
    end 
    
    -- 3) check if enough cass active and activate if needed
    while faction.targetCAS > #faction.actCAS do
        if #faction.inactCAS > 0 then 
            local rnd = math.random(1, #faction.inactCAS)
            local gName = faction.inactCAS[rnd]
            local grp = Group.getByName(gName)
            if grp then 
                if mist.groupIsDead(gName) then
                    mist.respawnGroup(gName, false)
                    groundBattle.debugMessage("AIR!!! Respawning group " .. gName)
                end
                grp.activate(grp)
                groundBattle.debugMessage("AIR!!! Activating group " .. gName)
                table.insert(faction.actCAS, gName)
                table.remove(faction.inactCAS, rnd)
                if groundBattle.debug then
                    groundBattle.debugMessage(string.format("CAS: %d/%d, target: %d. Activating group %s", #faction.actCAS, #faction.inactCAS, faction.targetCAS, gName) , 20)
                end
            else
                groundBattle.debugMessage("AIR!!! Group not found: " .. gName)
            end
        else 
            groundBattle.debugMessage("AIR!!! No inactive CAS groups. Breaking.")
            break
        end 
    end
end

function groundBattle.updateAirGroupsCount(factionName)
    local faction = {}
    if factionName == "red" then
        faction = groundBattle.factions.red
    elseif factionName == "blue" then
        faction = groundBattle.factions.blue
    else 
        return
    end

    local playerCount = #coalition.getPlayers(2)
    local maxCap = #faction.actCAP + #faction.inactCAP
    local maxCas = #faction.actCas + #faction.inactCAS
    faction.targetCAP = math.min(math.random(0, math.floor(playerCount/2) + 1), maxCap)
    faction.targetCAS = math.min(playerCount - faction.targetCAP, maxCas)
end

-- function groundBattle.modifyAirRoute(grpName, mission, factionName)
--     local points = mist.getGroupRoute(grpName, true)
--     local tmpFrontlineZones = {}
--     local tgtZone = ""
--     local opforFactionName = ""

--     if factionName == "red" then
--         opforFactionName = "blue"
--     else
--         opforFactionName = "red"
--     end

--     if mission == "CAP" then 
--         tmpFrontlineZones = groundBattle.getFriendlyFrontlineZones(factionName)
--         groundBattle.debugMessage("AIR!!! CAP friendly frontlines: " .. #tmpFrontlineZones)
--         tgtZone = tmpFrontlineZones[math.random(1, #tmpFrontlineZones)]
--         groundBattle.debugMessage("AIR!!! CAP target zone: " .. tgtZone.name)
--         local p = mist.getRandomPointInZone(tgtZone.name)
--         points[3].x = p.x
--         points[3].y = p.y
--     elseif mission == "CAS" then 
--         tmpFrontlineZones = groundBattle.getFriendlyFrontlineZones(opforFactionName)
--         tgtZone = tmpFrontlineZones[math.random(1, #tmpFrontlineZones)]
--         local p = mist.getRandomPointInZone(tgtZone.name)
--         local wp = mist.fixedWing.buildWP(p, "turningpoint", 243, 5490, "baro")
--         table.insert(points, 3, wp)
--     else
--         return nil
--     end 
--     return points
-- end


-- main function to be executed after initialization is done
function groundBattle.run()
    if not groundBattle.initiated then 
        -- groundBattle.debugMessage("groundBattle not initiated.")
        return 
    end 

    mist.addEventHandler(groundBattle.eventHandler)

    groundBattle.updateFrontlineZones()

    groundBattle.redrawMapMarks()
    mist.scheduleFunction(groundBattle.updateZoneFactions, {}, timer.getTime()+5, 600)

    if not groundBattle.productionInitiated then 
        groundBattle.initiateProduction()
        groundBattle.productionInitiated = true 
    end

    groundBattle.initiateOrdersProcessing()
    groundBattle.initiateAirManagement()    

    mist.scheduleFunction(groundBattle.logStatus, {}, timer.getTime()+300, 300)

    --mist.scheduleFunction(groundBattle.listCombatZones, {}, timer.getTime()+5, 60)
end 
